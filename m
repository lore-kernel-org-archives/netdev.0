From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] af_packet:  Add Doorbell transmit mode to AF_PACKET sockets
Date: Thu,  9 Oct 2014 09:36:35 -0400
Message-ID: <1412861795-25045-1-git-send-email-nhorman@tuxdriver.com>
References: <5435724E.5090507@gmail.com>
Cc: John Fastabend <john.fastabend@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com, Willem de Bruijn <willemb@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47583 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbaJINhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 09:37:11 -0400
In-Reply-To: <5435724E.5090507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a variation to the AF_PACKET memory mapped socket transmit
mechanism.  Nominally, when using a memory mapped AF_PACKET socket, frames are
written into the memory mapped buffer, and then the application calls sendmsg
with a NULL buffer which triggers then cleans the mapped space of all pending
buffers.

While this provides clean, synchronous operation, improvements can be made.  To
this end, I've introduced a doorbell mode of operation to memory mapped packet
sockets. When a packet socket is placed into doorbell mode, it write protects
the mappings of any process using the packet socket, so that on the first write
to it, a kernel trap is generated, which returns the mapping to a read-write
state, and forks a task to begin cleaning the buffers on the applications
behalf.  This thread contains some hysterisis to continue running a short while
after the last buffer has been cleaned, allowing subsquent wrtites to be sent
without needing to fork another task.  This allows for additional parallelism in
that an application on an smp system can run in parallel with a cleaning task,
so that the socket buffer can be filled and emptied in parallel without having
to incur multiple system call traps.

I've only done some very rough performance estimates, but early results are
promising.  Using this code here:
http://wiki.ipxwarzone.com/index.php5?title=Linux_packet_mmap

I made some modifications to support using doorbell mode and compared the time
it took to send 1500 packets (each of size 1492 bytes), in basic mmap and
doorbell mmaped mode, and used tcpdump to capture the output.  Results:

trace	packets	start time	end time	delta		p/s	size
ndb	1500	2.755605	3.000886	0.245281	6115.43	1492b
db	1500	4.716448	4.846382	0.129934	11544.32 1492b

Its very rough of course but it would seem I get a 40% increase in throughput
when using this method.  I'm sure thats an overestimate, and so more testing is
required, but initial results look good.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 include/uapi/linux/if_packet.h |   1 +
 net/packet/af_packet.c         | 215 +++++++++++++++++++++++++++++++++++++++--
 net/packet/internal.h          |  10 ++
 3 files changed, 217 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
index bac27fa..efce7e1 100644
--- a/include/uapi/linux/if_packet.h
+++ b/include/uapi/linux/if_packet.h
@@ -54,6 +54,7 @@ struct sockaddr_ll {
 #define PACKET_FANOUT			18
 #define PACKET_TX_HAS_OFF		19
 #define PACKET_QDISC_BYPASS		20
+#define PACKET_MMAP_DOORBELL		21
 
 #define PACKET_FANOUT_HASH		0
 #define PACKET_FANOUT_LB		1
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6a2bb37..27849c5 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -66,6 +66,8 @@
 #include <linux/kmod.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/rmap.h>
+#include <linux/async.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -234,9 +236,18 @@ struct packet_skb_cb {
 	(((x)->kactive_blk_num < ((x)->knum_blocks-1)) ? \
 	((x)->kactive_blk_num+1) : 0)
 
+ASYNC_DOMAIN_EXCLUSIVE(packet_doorbell_domain);
+
 static void __fanout_unlink(struct sock *sk, struct packet_sock *po);
 static void __fanout_link(struct sock *sk, struct packet_sock *po);
 
+
+static void packet_mod_tx_doorbell(struct packet_sock *po,
+				   struct vm_area_struct *vma, bool arm);
+
+#define packet_arm_tx_doorbell(p, v) packet_mod_tx_doorbell(p, v, true)
+#define packet_disarm_tx_doorbell(p, v) packet_mod_tx_doorbell(p, v, false)
+
 static int packet_direct_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
@@ -2215,7 +2226,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	int status = TP_STATUS_AVAILABLE;
 	int hlen, tlen;
 
-	mutex_lock(&po->pg_vec_lock);
+	if (!po->tp_doorbell_mode)
+		mutex_lock(&po->pg_vec_lock);
 
 	if (likely(saddr == NULL)) {
 		dev	= packet_cached_dev_get(po);
@@ -2326,7 +2338,8 @@ out_status:
 out_put:
 	dev_put(dev);
 out:
-	mutex_unlock(&po->pg_vec_lock);
+	if (!po->tp_doorbell_mode)
+		mutex_unlock(&po->pg_vec_lock);
 	return err;
 }
 
@@ -2548,9 +2561,13 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct packet_sock *po = pkt_sk(sk);
 
-	if (po->tx_ring.pg_vec)
-		return tpacket_snd(po, msg);
-	else
+	if (po->tx_ring.pg_vec) {
+		if (po->tp_doorbell_mode) {
+			async_synchronize_full_domain(&packet_doorbell_domain);
+			return 0;
+		} else
+			return tpacket_snd(po, msg);
+	} else
 		return packet_snd(sock, msg, len);
 }
 
@@ -2592,6 +2609,10 @@ static int packet_release(struct socket *sock)
 
 	packet_flush_mclist(sk);
 
+	if (po->tp_doorbell_mode)
+		async_synchronize_full_domain(&packet_doorbell_domain);
+	
+
 	if (po->rx_ring.pg_vec) {
 		memset(&req_u, 0, sizeof(req_u));
 		packet_set_ring(sk, &req_u, 1, 0);
@@ -2772,6 +2793,9 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 	sock_init_data(sock, sk);
 
 	po = pkt_sk(sk);
+	INIT_LIST_HEAD(&po->doorbell_vmas);
+	spin_lock_init(&po->doorbell_lock);
+	atomic_set(&po->doorbell_thread_count, 0);
 	sk->sk_family = PF_PACKET;
 	po->num = proto;
 	po->xmit = dev_queue_xmit;
@@ -3374,6 +3398,21 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
 		return 0;
 	}
+	case PACKET_MMAP_DOORBELL:
+	{
+		unsigned int val;
+		if (optlen != sizeof(val))
+			return -EINVAL;
+		if (atomic_read(&po->mapped))
+			return -EBUSY;
+		if (copy_from_user(&val, optval, sizeof(val)))
+			return -EFAULT;
+
+		po->tp_doorbell_mode = !!val;
+		if (!po->tp_doorbell_mode)
+			async_synchronize_full_domain(&packet_doorbell_domain);
+		return 0;
+	}
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3469,6 +3508,9 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	case PACKET_QDISC_BYPASS:
 		val = packet_use_direct_xmit(po);
 		break;
+	case PACKET_MMAP_DOORBELL:
+		val = po->tp_doorbell_mode;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
@@ -3610,6 +3652,74 @@ static unsigned int packet_poll(struct file *file, struct socket *sock,
 	return mask;
 }
 
+void packet_doorbell_send(void *data, async_cookie_t cookie)
+{
+	struct sock *sk = (struct sock *)data;
+	struct packet_sock *po = pkt_sk(sk);
+	struct msghdr msg;
+	int ret;
+	int retry_count;
+	struct doorbell_vma *db_vma;
+	void *more_work;
+
+	WARN_ON(!po);
+
+restart:
+	for (retry_count = 2; retry_count > 0; retry_count--) {
+		do {
+			msg.msg_flags = 0;
+			msg.msg_name = NULL;
+			ret = tpacket_snd(po, &msg);
+		} while (ret > 0);
+		schedule_timeout(1);
+	}
+	atomic_dec(&po->doorbell_thread_count);
+	rcu_read_lock();
+	list_for_each_entry_rcu(db_vma, &po->doorbell_vmas, list)
+		packet_arm_tx_doorbell(po, db_vma->vma);
+	rcu_read_unlock();
+
+	more_work = packet_current_frame(po, &po->tx_ring, TP_STATUS_SEND_REQUEST);
+
+	if (more_work &&
+	    atomic_add_unless(&po->doorbell_thread_count, 1, 1)) {
+		/*
+		 * We have more to send and we won the race to be the cleaning
+		 * thread.  go back and try again
+		 */
+		rcu_read_lock();
+		list_for_each_entry_rcu(db_vma, &po->doorbell_vmas, list)
+			packet_disarm_tx_doorbell(po, db_vma->vma);
+		rcu_read_unlock();
+		goto restart;
+	}
+	
+}
+
+static int packet_mm_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct file *file = vma->vm_file;
+	struct socket *sock = file->private_data;
+	struct sock *sk = sock->sk;
+	struct doorbell_vma *db_vma;
+	struct packet_sock *po = sk ? pkt_sk(sk) : NULL;
+
+	if (po) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(db_vma, &po->doorbell_vmas, list)
+			packet_disarm_tx_doorbell(po, db_vma->vma);
+		rcu_read_unlock();
+		if (atomic_add_unless(&po->doorbell_thread_count, 1, 1)) {
+			if (po->tp_doorbell_mode)
+				async_schedule_domain(packet_doorbell_send, sk,
+						      &packet_doorbell_domain);
+			else
+				atomic_dec(&po->doorbell_thread_count);
+		}
+
+	}
+	return VM_FAULT_RETRY;
+}
 
 /* Dirty? Well, I still did not learn better way to account
  * for user mmaps.
@@ -3627,17 +3737,29 @@ static void packet_mm_open(struct vm_area_struct *vma)
 
 static void packet_mm_close(struct vm_area_struct *vma)
 {
+	struct doorbell_vma *db_vma;
 	struct file *file = vma->vm_file;
 	struct socket *sock = file->private_data;
 	struct sock *sk = sock->sk;
-
-	if (sk)
-		atomic_dec(&pkt_sk(sk)->mapped);
+	struct packet_sock *po = sk ? pkt_sk(sk) : NULL;
+
+	if (po) {
+		spin_lock(&po->doorbell_lock);
+		list_for_each_entry_rcu(db_vma, &po->doorbell_vmas, list) {
+			if (db_vma->vma == vma) {
+				list_del_rcu(&db_vma->list);
+				kfree_rcu(db_vma, rcu);
+			}
+		}
+		spin_unlock(&po->doorbell_lock);
+		atomic_dec(&po->mapped);
+	}
 }
 
-static const struct vm_operations_struct packet_mmap_ops = {
+const struct vm_operations_struct packet_mmap_ops = {
 	.open	=	packet_mm_open,
 	.close	=	packet_mm_close,
+	.page_mkwrite	=	packet_mm_mkwrite,
 };
 
 static void free_pg_vec(struct pgv *pg_vec, unsigned int order,
@@ -3855,6 +3977,62 @@ out:
 	return err;
 }
 
+static void packet_mod_tx_doorbell(struct packet_sock *po,
+				   struct vm_area_struct *vma, bool arm)
+{
+	void *kaddr;
+	int pg_num;
+	struct packet_ring_buffer *rb;
+	pte_t entry;
+	struct page *page;
+	int i;
+	pte_t *ptep;
+	unsigned long start;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	rb = &po->tx_ring;
+
+	for (i = 0; i < rb->pg_vec_len; i++) {
+		kaddr = rb->pg_vec[i].buffer;
+		start = vma->vm_start;
+		for (pg_num = 0; pg_num < rb->pg_vec_pages; pg_num++) {
+			ptep = NULL;
+			page = pgv_to_page(kaddr);
+
+
+			pgd = pgd_offset(vma->vm_mm, start);
+			if (!pgd_present(*pgd))
+				goto next;
+
+			pud = pud_offset(pgd, start);
+			if (!pud_present(*pud))
+				goto next;
+
+			pmd = pmd_offset(pud, start);
+			if (!pmd_present(*pmd))
+				goto next;
+
+			ptep = pte_offset_kernel(pmd, start);
+
+			if (arm)
+				entry = pte_wrprotect(*ptep);
+			else
+				entry = pte_mkwrite(*ptep);
+
+			flush_dcache_page(page);
+			set_pte_at(vma->vm_mm, start, ptep, entry);
+
+next:
+			kaddr += PAGE_SIZE;
+			start += PAGE_SIZE;
+		}
+	}
+
+	
+}
+
 static int packet_mmap(struct file *file, struct socket *sock,
 		struct vm_area_struct *vma)
 {
@@ -3865,10 +4043,17 @@ static int packet_mmap(struct file *file, struct socket *sock,
 	unsigned long start;
 	int err = -EINVAL;
 	int i;
+	struct doorbell_vma *db_vma = NULL;
 
 	if (vma->vm_pgoff)
 		return -EINVAL;
 
+	if (po->tp_doorbell_mode) {
+		db_vma = kzalloc(sizeof(struct doorbell_vma), GFP_KERNEL);
+		if (!db_vma)
+			return -ENOMEM;
+	}
+
 	mutex_lock(&po->pg_vec_lock);
 
 	expected_size = 0;
@@ -3905,9 +4090,21 @@ static int packet_mmap(struct file *file, struct socket *sock,
 				start += PAGE_SIZE;
 				kaddr += PAGE_SIZE;
 			}
+#ifdef CONFIG_X86
+			set_pages_uc(pgv_to_page(rb->pg_vec[i].buffer), rb->pg_vec_pages);
+#endif
 		}
 	}
 
+	if (po->tp_doorbell_mode) {
+		vma->vm_flags |= VM_SHARED;
+		db_vma->vma = vma;
+		spin_lock(&po->doorbell_lock);
+		list_add_rcu(&db_vma->list, &po->doorbell_vmas);
+		spin_unlock(&po->doorbell_lock);
+		packet_arm_tx_doorbell(po, vma);
+	}
+
 	atomic_inc(&po->mapped);
 	vma->vm_ops = &packet_mmap_ops;
 	err = 0;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index eb9580a..2e1f5f7 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -89,9 +89,17 @@ struct packet_fanout {
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
+struct doorbell_vma {
+	struct list_head list;
+	struct vm_area_struct *vma;
+	struct rcu_head rcu;
+};
+
 struct packet_sock {
 	/* struct sock has to be the first member of packet_sock */
 	struct sock		sk;
+	struct list_head __rcu	doorbell_vmas;
+	spinlock_t	doorbell_lock;
 	struct packet_fanout	*fanout;
 	union  tpacket_stats_u	stats;
 	struct packet_ring_buffer	rx_ring;
@@ -112,6 +120,8 @@ struct packet_sock {
 	unsigned int		tp_reserve;
 	unsigned int		tp_loss:1;
 	unsigned int		tp_tx_has_off:1;
+	unsigned int		tp_doorbell_mode:1;
+	atomic_t		doorbell_thread_count;
 	unsigned int		tp_tstamp;
 	struct net_device __rcu	*cached_dev;
 	int			(*xmit)(struct sk_buff *skb);
-- 
1.9.3
