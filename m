From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 05/11] netlink: mmaped netlink: ring setup
Date: Mon, 20 Aug 2012 08:18:46 +0200
Message-ID: <1345443532-3707-6-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36023 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab2HTGS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:18:57 -0400
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for mmap'ed RX and TX ring setup and teardown based on the
af_packet.c code. The following patches will use this to add the real
mmap'ed receive and transmit functionality.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netlink.h  |   32 +++++
 net/Kconfig              |    9 ++
 net/netlink/af_netlink.c |  288 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 327 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f74dd13..3600461 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_NETLINK_H
 #define __LINUX_NETLINK_H
 
+#include <linux/kernel.h>
 #include <linux/socket.h> /* for __kernel_sa_family_t */
 #include <linux/types.h>
 
@@ -105,11 +106,42 @@ struct nlmsgerr {
 #define NETLINK_PKTINFO		3
 #define NETLINK_BROADCAST_ERROR	4
 #define NETLINK_NO_ENOBUFS	5
+#define NETLINK_RX_RING		6
+#define NETLINK_TX_RING		7
 
 struct nl_pktinfo {
 	__u32	group;
 };
 
+struct nl_mmap_req {
+	unsigned int	nm_block_size;
+	unsigned int	nm_block_nr;
+	unsigned int	nm_frame_size;
+	unsigned int	nm_frame_nr;
+};
+
+struct nl_mmap_hdr {
+	unsigned int	nm_status;
+	unsigned int	nm_len;
+	__u32		nm_group;
+	/* credentials */
+	__u32		nm_pid;
+	__u32		nm_uid;
+	__u32		nm_gid;
+};
+
+enum nl_mmap_status {
+	NL_MMAP_STATUS_UNUSED,
+	NL_MMAP_STATUS_RESERVED,
+	NL_MMAP_STATUS_VALID,
+	NL_MMAP_STATUS_COPY,
+	NL_MMAP_STATUS_SKIP,
+};
+
+#define NL_MMAP_MSG_ALIGNMENT		NLMSG_ALIGNTO
+#define NL_MMAP_MSG_ALIGN(sz)		__ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
+#define NL_MMAP_HDRLEN			NL_MMAP_MSG_ALIGN(sizeof(struct nl_mmap_hdr))
+
 #define NET_MAJOR 36		/* Major 36 is reserved for networking 						*/
 
 enum {
diff --git a/net/Kconfig b/net/Kconfig
index 245831b..7f48691 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -23,6 +23,15 @@ menuconfig NET
 
 if NET
 
+config NETLINK_MMAP
+	bool "Netlink: mmaped IO"
+	help
+	  This option enables support for memory mapped netlink IO. This
+	  reduces overhead by avoiding copying data between kernel- and
+	  userspace.
+
+	  If unsure, say N.
+
 config WANT_COMPAT_NETLINK_MESSAGES
 	bool
 	help
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e2d0177..e20a918 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -55,6 +55,7 @@
 #include <linux/types.h>
 #include <linux/audit.h>
 #include <linux/mutex.h>
+#include <linux/vmalloc.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -64,6 +65,20 @@
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
+struct netlink_ring {
+	void			**pg_vec;
+	unsigned int		head;
+	unsigned int		frames_per_block;
+	unsigned int		frame_size;
+	unsigned int		frame_max;
+
+	unsigned int		pg_vec_order;
+	unsigned int		pg_vec_pages;
+	unsigned int		pg_vec_len;
+
+	atomic_t		pending;
+};
+
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
@@ -82,6 +97,12 @@ struct netlink_sock {
 	void			(*netlink_rcv)(struct sk_buff *skb);
 	void			(*netlink_bind)(int group);
 	struct module		*module;
+#ifdef CONFIG_NETLINK_MMAP
+	struct mutex		pg_vec_lock;
+	struct netlink_ring	rx_ring;
+	struct netlink_ring	tx_ring;
+	atomic_t		mapped;
+#endif /* CONFIG_NETLINK_MMAP */
 };
 
 struct listeners {
@@ -154,6 +175,234 @@ static inline struct hlist_head *nl_pid_hashfn(struct nl_pid_hash *hash, u32 pid
 	return &hash->table[jhash_1word(pid, hash->rnd) & hash->mask];
 }
 
+#ifdef CONFIG_NETLINK_MMAP
+static __pure struct page *pgvec_to_page(const void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		return vmalloc_to_page(addr);
+	else
+		return virt_to_page(addr);
+}
+
+static void free_pg_vec(void **pg_vec, unsigned int order, unsigned int len)
+{
+	unsigned int i;
+
+	for (i = 0; i < len; i++) {
+		if (pg_vec[i] != NULL) {
+			if (is_vmalloc_addr(pg_vec[i]))
+				vfree(pg_vec[i]);
+			else
+				free_pages((unsigned long)pg_vec[i], order);
+		}
+	}
+	kfree(pg_vec);
+}
+
+static void *alloc_one_pg_vec_page(unsigned long order)
+{
+	void *buffer;
+	gfp_t gfp_flags = GFP_KERNEL | __GFP_COMP | __GFP_ZERO |
+			  __GFP_NOWARN | __GFP_NORETRY;
+
+	buffer = (void *)__get_free_pages(gfp_flags, order);
+	if (buffer != NULL)
+		return buffer;
+
+	buffer = vzalloc((1 << order) * PAGE_SIZE);
+	if (buffer != NULL)
+		return buffer;
+
+	gfp_flags &= ~__GFP_NORETRY;
+	return (void *)__get_free_pages(gfp_flags, order);
+}
+
+static void **alloc_pg_vec(struct netlink_sock *nlk,
+			   struct nl_mmap_req *req, unsigned int order)
+{
+	unsigned int block_nr = req->nm_block_nr;
+	unsigned int i;
+	void **pg_vec, *ptr;
+
+	pg_vec = kcalloc(block_nr, sizeof(void *), GFP_KERNEL);
+	if (pg_vec == NULL)
+		return NULL;
+
+	for (i = 0; i < block_nr; i++) {
+		pg_vec[i] = ptr = alloc_one_pg_vec_page(order);
+		if (pg_vec[i] == NULL)
+			goto err1;
+	}
+
+	return pg_vec;
+err1:
+	free_pg_vec(pg_vec, order, block_nr);
+	return NULL;
+}
+
+static int netlink_set_ring(struct sock *sk, struct nl_mmap_req *req,
+			    bool closing, bool tx_ring)
+{
+	struct netlink_sock *nlk = nlk_sk(sk);
+	struct netlink_ring *ring;
+	struct sk_buff_head *queue;
+	void **pg_vec = NULL;
+	unsigned int order = 0;
+	int err;
+
+	ring  = tx_ring ? &nlk->tx_ring : &nlk->rx_ring;
+	queue = tx_ring ? &sk->sk_write_queue : &sk->sk_receive_queue;
+
+	if (!closing) {
+		if (atomic_read(&nlk->mapped))
+			return -EBUSY;
+		if (atomic_read(&ring->pending))
+			return -EBUSY;
+	}
+
+	if (req->nm_block_nr) {
+		if (ring->pg_vec != NULL)
+			return -EBUSY;
+
+		if ((int)req->nm_block_size <= 0)
+			return -EINVAL;
+		if (!IS_ALIGNED(req->nm_block_size, PAGE_SIZE))
+			return -EINVAL;
+		if (req->nm_frame_size < NL_MMAP_HDRLEN)
+			return -EINVAL;
+		if (!IS_ALIGNED(req->nm_frame_size, NL_MMAP_MSG_ALIGNMENT))
+			return -EINVAL;
+
+		ring->frames_per_block = req->nm_block_size /
+					 req->nm_frame_size;
+		if (ring->frames_per_block == 0)
+			return -EINVAL;
+		if (ring->frames_per_block * req->nm_block_nr !=
+		    req->nm_frame_nr)
+			return -EINVAL;
+
+		order = get_order(req->nm_block_size);
+		pg_vec = alloc_pg_vec(nlk, req, order);
+		if (pg_vec == NULL)
+			return -ENOMEM;
+	} else {
+		if (req->nm_frame_nr)
+			return -EINVAL;
+	}
+
+	err = -EBUSY;
+	mutex_lock(&nlk->pg_vec_lock);
+	if (closing || atomic_read(&nlk->mapped) == 0) {
+		err = 0;
+		spin_lock_bh(&queue->lock);
+
+		ring->frame_max		= req->nm_frame_nr - 1;
+		ring->head		= 0;
+		ring->frame_size	= req->nm_frame_size;
+		ring->pg_vec_pages	= req->nm_block_size / PAGE_SIZE;
+
+		swap(ring->pg_vec_len, req->nm_block_nr);
+		swap(ring->pg_vec_order, order);
+		swap(ring->pg_vec, pg_vec);
+
+		__skb_queue_purge(queue);
+		spin_unlock_bh(&queue->lock);
+
+		WARN_ON(atomic_read(&nlk->mapped));
+	}
+	mutex_unlock(&nlk->pg_vec_lock);
+
+	if (pg_vec)
+		free_pg_vec(pg_vec, order, req->nm_block_nr);
+	return err;
+}
+
+static void netlink_mm_open(struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+
+	if (sk)
+		atomic_inc(&nlk_sk(sk)->mapped);
+}
+
+static void netlink_mm_close(struct vm_area_struct *vma)
+{
+	struct file *file = vma->vm_file;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+
+	if (sk)
+		atomic_dec(&nlk_sk(sk)->mapped);
+}
+
+static const struct vm_operations_struct netlink_mmap_ops = {
+	.open	= netlink_mm_open,
+	.close	= netlink_mm_close,
+};
+
+static int netlink_mmap(struct file *file, struct socket *sock,
+			struct vm_area_struct *vma)
+{
+	struct sock *sk = sock->sk;
+	struct netlink_sock *nlk = nlk_sk(sk);
+	struct netlink_ring *ring;
+	unsigned long start, size, expected;
+	unsigned int i;
+	int err = -EINVAL;
+
+	if (vma->vm_pgoff)
+		return -EINVAL;
+
+	mutex_lock(&nlk->pg_vec_lock);
+
+	expected = 0;
+	for (ring = &nlk->rx_ring; ring <= &nlk->tx_ring; ring++) {
+		if (ring->pg_vec == NULL)
+			continue;
+		expected += ring->pg_vec_len * ring->pg_vec_pages * PAGE_SIZE;
+	}
+
+	if (expected == 0)
+		goto out;
+
+	size = vma->vm_end - vma->vm_start;
+	if (size != expected)
+		goto out;
+
+	start = vma->vm_start;
+	for (ring = &nlk->rx_ring; ring <= &nlk->tx_ring; ring++) {
+		if (ring->pg_vec == NULL)
+			continue;
+
+		for (i = 0; i < ring->pg_vec_len; i++) {
+			struct page *page;
+			void *kaddr = ring->pg_vec[i];
+			unsigned int pg_num;
+
+			for (pg_num = 0; pg_num < ring->pg_vec_pages; pg_num++) {
+				page = pgvec_to_page(kaddr);
+				err = vm_insert_page(vma, start, page);
+				if (err < 0)
+					goto out;
+				start += PAGE_SIZE;
+				kaddr += PAGE_SIZE;
+			}
+		}
+	}
+
+	atomic_inc(&nlk->mapped);
+	vma->vm_ops = &netlink_mmap_ops;
+	err = 0;
+out:
+	mutex_unlock(&nlk->pg_vec_lock);
+	return 0;
+}
+#else /* CONFIG_NETLINK_MMAP */
+#define netlink_mmap			sock_no_mmap
+#endif /* CONFIG_NETLINK_MMAP */
+
 static void netlink_destroy_callback(struct netlink_callback *cb)
 {
 	kfree_skb(cb->skb);
@@ -191,6 +440,18 @@ static void netlink_sock_destruct(struct sock *sk)
 	}
 
 	skb_queue_purge(&sk->sk_receive_queue);
+#ifdef CONFIG_NETLINK_MMAP
+	if (1) {
+		struct nl_mmap_req req;
+
+		memset(&req, 0, sizeof(req));
+		if (nlk->rx_ring.pg_vec)
+			netlink_set_ring(sk, &req, true, false);
+		memset(&req, 0, sizeof(req));
+		if (nlk->tx_ring.pg_vec)
+			netlink_set_ring(sk, &req, true, true);
+	}
+#endif /* CONFIG_NETLINK_MMAP */
 
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		printk(KERN_ERR "Freeing alive netlink socket %p\n", sk);
@@ -452,6 +713,9 @@ static int __netlink_create(struct net *net, struct socket *sock,
 		mutex_init(nlk->cb_mutex);
 	}
 	init_waitqueue_head(&nlk->wait);
+#ifdef CONFIG_NETLINK_MMAP
+	mutex_init(&nlk->pg_vec_lock);
+#endif
 
 	sk->sk_destruct = netlink_sock_destruct;
 	sk->sk_protocol = protocol;
@@ -1246,7 +1510,8 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 	if (level != SOL_NETLINK)
 		return -ENOPROTOOPT;
 
-	if (optlen >= sizeof(int) &&
+	if (optname != NETLINK_RX_RING && optname != NETLINK_TX_RING &&
+	    optlen >= sizeof(int) &&
 	    get_user(val, (unsigned int __user *)optval))
 		return -EFAULT;
 
@@ -1295,6 +1560,25 @@ static int netlink_setsockopt(struct socket *sock, int level, int optname,
 		}
 		err = 0;
 		break;
+#ifdef CONFIG_NETLINK_MMAP
+	case NETLINK_RX_RING:
+	case NETLINK_TX_RING: {
+		struct nl_mmap_req req;
+
+		/* Rings might consume more memory than queue limits, require
+		 * CAP_NET_ADMIN.
+		 */
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		if (optlen < sizeof(req))
+			return -EINVAL;
+		if (copy_from_user(&req, optval, sizeof(req)))
+			return -EFAULT;
+		err = netlink_set_ring(sk, &req, false,
+				       optname == NETLINK_TX_RING);
+		break;
+	}
+#endif /* CONFIG_NETLINK_MMAP */
 	default:
 		err = -ENOPROTOOPT;
 	}
@@ -2124,7 +2408,7 @@ static const struct proto_ops netlink_ops = {
 	.getsockopt =	netlink_getsockopt,
 	.sendmsg =	netlink_sendmsg,
 	.recvmsg =	netlink_recvmsg,
-	.mmap =		sock_no_mmap,
+	.mmap =		netlink_mmap,
 	.sendpage =	sock_no_sendpage,
 };
 
-- 
1.7.7.6
