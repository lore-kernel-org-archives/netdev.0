From: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH][RFC] network splice receive v2
Date: Mon, 11 Jun 2007 13:59:26 +0200
Message-ID: <20070611115926.GB18832@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="61jdw2sOBCFtR2d/"
Cc: olaf.kirch@oracle.com, johnpol@2ka.mipt.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:29536 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbXFKMBf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 08:01:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--61jdw2sOBCFtR2d/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Here's an updated implementation of tcp network splice receive support.
It actually works for me now, no data corruption seen.

For the original announcement and how to test it, see:

http://marc.info/?l=linux-netdev&m=118103093400770&w=2

I hang on to the original skb by creating a clone of it and holding
references to that. I really don't need a clone, but tcp_read_sock() is
not being very helpful by calling sk_eat_skb() which blissfully ignores
any reference counts and uncondtionally frees the skb - why is that??
The clone works around that issue.

The current code also gets rid of the data_ready hack, and it should now
handle linear/fragments/fraglist in the skb just fine. Thanks to Olaf
for providing review of that stuff!

Patches are against the #splice branch of the block repo, "official" url
of that is:

git://git.kernel.dk/data/git/linux-2.6-block.git/

and it's based on Linus main tree. Let me know if I should supply netdev
branch patches instead, or even just provide a rolled up patch (or patch
series) for anyone curious to test or play with it.

-- 
Jens Axboe


--61jdw2sOBCFtR2d/
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-splice-don-t-assume-regular-pages-in-splice_to_pipe.patch"

>From fd79bf84fdeb15b72f256c342609257ae8a56235 Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Mon, 11 Jun 2007 13:00:32 +0200
Subject: [PATCH] splice: don't assume regular pages in splice_to_pipe()

Allow caller to pass in a release function, there might be
other resources that need releasing as well. Needed for
network receive.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 fs/splice.c            |    9 ++++++++-
 include/linux/splice.h |    1 +
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index f24e367..25ec9c8 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -247,11 +247,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 	}
 
 	while (page_nr < spd->nr_pages)
-		page_cache_release(spd->pages[page_nr++]);
+		spd->spd_release(spd, page_nr++);
 
 	return ret;
 }
 
+static void spd_release_page(struct splice_pipe_desc *spd, unsigned int i)
+{
+	page_cache_release(spd->pages[i]);
+}
+
 static int
 __generic_file_splice_read(struct file *in, loff_t *ppos,
 			   struct pipe_inode_info *pipe, size_t len,
@@ -270,6 +275,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		.partial = partial,
 		.flags = flags,
 		.ops = &page_cache_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
@@ -1442,6 +1448,7 @@ static long vmsplice_to_pipe(struct file *file, const struct iovec __user *iov,
 		.partial = partial,
 		.flags = flags,
 		.ops = &user_page_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	pipe = pipe_info(file->f_path.dentry->d_inode);
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 1a1182b..04c1068 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -53,6 +53,7 @@ struct splice_pipe_desc {
 	int nr_pages;			/* number of pages in map */
 	unsigned int flags;		/* splice flags */
 	const struct pipe_buf_operations *ops;/* ops associated with output pipe */
+	void (*spd_release)(struct splice_pipe_desc *, unsigned int);
 };
 
 typedef int (splice_actor)(struct pipe_inode_info *, struct pipe_buffer *,
-- 
1.5.2.1.174.gcd03


--61jdw2sOBCFtR2d/
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0002-tcp_read_sock-alloc-recv_actor-return-return-nega.patch"

>From 95a1ee277f2a6df5c95d786b9229ea0ffa46850d Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Mon, 4 Jun 2007 15:06:43 +0200
Subject: [PATCH] tcp_read_sock: alloc recv_actor() return return negative error value

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 net/ipv4/tcp.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cd3c7e9..450f44b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1064,7 +1064,11 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 					break;
 			}
 			used = recv_actor(desc, skb, offset, len);
-			if (used <= len) {
+			if (used < 0) {
+				if (!copied)
+					copied = used;
+				break;
+			} else if (used <= len) {
 				seq += used;
 				copied += used;
 				offset += used;
@@ -1086,7 +1090,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	tcp_rcv_space_adjust(sk);
 
 	/* Clean up data we have read: This will do ACK frames. */
-	if (copied)
+	if (copied > 0)
 		tcp_cleanup_rbuf(sk, copied);
 	return copied;
 }
-- 
1.5.2.1.174.gcd03


--61jdw2sOBCFtR2d/
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0003-TCP-splice-receive-support.patch"

>From f0329226c6c1f521c2069358699bae5ed48f5a43 Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Mon, 11 Jun 2007 13:51:57 +0200
Subject: [PATCH] TCP splice receive support

Support for network splice receive.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 include/linux/net.h    |    3 +
 include/linux/skbuff.h |    5 ++
 include/net/tcp.h      |    3 +
 net/core/skbuff.c      |  175 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/tcp.c         |  122 +++++++++++++++++++++++++++++++++
 net/socket.c           |   13 ++++
 7 files changed, 322 insertions(+), 0 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index efc4517..472ee12 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -19,6 +19,7 @@
 #define _LINUX_NET_H
 
 #include <linux/wait.h>
+#include <linux/splice.h>
 #include <asm/socket.h>
 
 struct poll_table_struct;
@@ -165,6 +166,8 @@ struct proto_ops {
 				      struct vm_area_struct * vma);
 	ssize_t		(*sendpage)  (struct socket *sock, struct page *page,
 				      int offset, size_t size, int flags);
+	ssize_t 	(*splice_read)(struct socket *sock,  loff_t *ppos,
+				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
 };
 
 struct net_proto_family {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e7367c7..64e3eed 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1504,6 +1504,11 @@ extern int	       skb_store_bits(struct sk_buff *skb, int offset,
 extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      __wsum csum);
+extern int             skb_splice_bits(struct sk_buff *skb,
+						unsigned int offset,
+						struct pipe_inode_info *pipe,
+						unsigned int len,
+						unsigned int flags);
 extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a8af9ae..8e86697 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -308,6 +308,9 @@ extern int			tcp_twsk_unique(struct sock *sk,
 
 extern void			tcp_twsk_destructor(struct sock *sk);
 
+extern ssize_t			tcp_splice_read(struct socket *sk, loff_t *ppos,
+					        struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+
 static inline void tcp_dec_quickack_mode(struct sock *sk,
 					 const unsigned int pkts)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7c6a34e..cbbeccb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -52,6 +52,7 @@
 #endif
 #include <linux/string.h>
 #include <linux/skbuff.h>
+#include <linux/splice.h>
 #include <linux/cache.h>
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
@@ -71,6 +72,40 @@
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
+static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
+				  struct pipe_buffer *buf)
+{
+	struct sk_buff *skb = (struct sk_buff *) buf->private;
+
+	kfree_skb(skb);
+}
+
+static void sock_pipe_buf_get(struct pipe_inode_info *pipe,
+				struct pipe_buffer *buf)
+{
+	struct sk_buff *skb = (struct sk_buff *) buf->private;
+
+	skb_get(skb);
+}
+
+static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
+			       struct pipe_buffer *buf)
+{
+	return 1;
+}
+
+
+/* Pipe buffer operations for a socket. */
+static struct pipe_buf_operations sock_pipe_buf_ops = {
+	.can_merge = 0,
+	.map = generic_pipe_buf_map,
+	.unmap = generic_pipe_buf_unmap,
+	.pin = generic_pipe_buf_pin,
+	.release = sock_pipe_buf_release,
+	.steal = sock_pipe_buf_steal,
+	.get = sock_pipe_buf_get,
+};
+
 /*
  *	Keep out-of-line to prevent kernel bloat.
  *	__builtin_return_address is not used because it is not always
@@ -1116,6 +1151,146 @@ fault:
 	return -EFAULT;
 }
 
+static void sock_spd_release(struct splice_pipe_desc *spd, unsigned int i)
+{
+	struct sk_buff *skb = (struct sk_buff *) spd->partial[i].private;
+
+	kfree_skb(skb);
+}
+
+/*
+ * Fill page/offset/length into spd, if it can hold more pages.
+ */
+static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
+				unsigned int len, unsigned int offset,
+				struct sk_buff *skb)
+{
+	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
+		return 1;
+
+	spd->pages[spd->nr_pages] = page;
+	spd->partial[spd->nr_pages].len = len;
+	spd->partial[spd->nr_pages].offset = offset;
+	spd->partial[spd->nr_pages].private = (unsigned long) skb_get(skb);
+	spd->nr_pages++;
+	return 0;
+}
+
+/*
+ * Map linear and fragment data from the skb to spd. Returns number of
+ * pages mapped.
+ */
+static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
+			     unsigned int *total_len,
+			     struct splice_pipe_desc *spd)
+{
+	unsigned int nr_pages = spd->nr_pages;
+	unsigned int poff, plen, len, toff;
+	int headlen, seg;
+
+	toff = *offset;
+
+	/*
+	 * first map the linear region into the pages/partial map, skipping
+	 * any potential initial offset.
+	 */
+	headlen = skb_headlen(skb);
+	len = 0;
+	for (seg = 0; len < headlen; len += PAGE_SIZE - poff) {
+		void *p = skb->data + len;
+
+		poff = (unsigned long) p & (PAGE_SIZE - 1);
+		plen = min_t(unsigned, headlen - len, PAGE_SIZE - poff);
+
+		if (toff) {
+			if (plen <= toff) {
+				toff -= plen;
+				continue;
+			}
+			plen -= toff;
+			toff = 0;
+		}
+
+		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
+			break;
+	}
+
+	/*
+	 * then map the fragments
+	 */
+	for (seg = 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
+		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];
+
+		plen = f->size;
+		poff = f->page_offset;
+
+		if (toff) {
+			if (plen <= toff) {
+				toff -= plen;
+				continue;
+			}
+			plen -= toff;
+			toff = 0;
+		}
+
+		if (spd_fill_page(spd, f->page, plen, poff, skb))
+			break;
+	}
+
+	*offset = toff;
+	return spd->nr_pages - nr_pages;
+}
+
+/*
+ * Map data from the skb to a pipe. Should handle both the linear part,
+ * the fragments, and the frag list. It does NOT handle frag lists within
+ * the frag list, if such a thing exists. We'd probably need to recurse to
+ * handle that cleanly.
+ */
+int skb_splice_bits(struct sk_buff *__skb, unsigned int offset,
+		    struct pipe_inode_info *pipe, unsigned int tlen,
+		    unsigned int flags)
+{
+	struct partial_page partial[PIPE_BUFFERS];
+	struct page *pages[PIPE_BUFFERS];
+	struct splice_pipe_desc spd = {
+		.pages = pages,
+		.partial = partial,
+		.flags = flags,
+		.ops = &sock_pipe_buf_ops,
+		.spd_release = sock_spd_release,
+	};
+	struct sk_buff *skb;
+	ssize_t ret = 0;
+
+	/*
+	 * I'd love to avoid the clone here, but tcp_read_sock()
+	 * ignores reference counts and unconditonally kills the sk_buff
+	 * on return from the actor.
+	 */
+	skb = skb_clone(__skb, GFP_KERNEL);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
+	__skb_splice_bits(skb, &offset, &tlen, &spd);
+
+	/*
+	 * now see if we have a frag_list to map
+	 */
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list && tlen; list = list->next)
+			__skb_splice_bits(skb, &offset, &tlen, &spd);
+	}
+
+	if (spd.nr_pages)
+		ret = splice_to_pipe(pipe, &spd);
+
+	kfree_skb(skb);
+	return ret;
+}
+
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
  *	@skb: destination buffer
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 041fba3..0ff9f86 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -835,6 +835,7 @@ const struct proto_ops inet_stream_ops = {
 	.recvmsg	   = sock_common_recvmsg,
 	.mmap		   = sock_no_mmap,
 	.sendpage	   = tcp_sendpage,
+	.splice_read	   = tcp_splice_read,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_sock_common_setsockopt,
 	.compat_getsockopt = compat_sock_common_getsockopt,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 450f44b..437e77f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -253,6 +253,10 @@
 #include <linux/poll.h>
 #include <linux/init.h>
 #include <linux/fs.h>
+#include <linux/skbuff.h>
+#include <linux/splice.h>
+#include <linux/net.h>
+#include <linux/socket.h>
 #include <linux/random.h>
 #include <linux/bootmem.h>
 #include <linux/cache.h>
@@ -264,6 +268,7 @@
 #include <net/xfrm.h>
 #include <net/ip.h>
 #include <net/netdma.h>
+#include <net/sock.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -291,6 +296,15 @@ EXPORT_SYMBOL(tcp_memory_allocated);
 EXPORT_SYMBOL(tcp_sockets_allocated);
 
 /*
+ *	Create a TCP splice context.
+ */
+struct tcp_splice_state {
+		struct pipe_inode_info *pipe;
+		size_t len;
+		unsigned int flags;
+};
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the sk_stream_mem_schedule() is of this nature: accounting
@@ -500,6 +514,113 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
 	}
 }
 
+int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
+			 unsigned int offset, size_t len)
+{
+	struct tcp_splice_state *tss = rd_desc->arg.data;
+
+	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->flags);
+}
+
+static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state *tss)
+{
+	/* Store TCP splice context information in read_descriptor_t. */
+	read_descriptor_t rd_desc = {
+		.arg.data = tss,
+	};
+
+	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
+}
+
+/*
+ *  tcp_splice_read - splice data from TCP socket to a pipe
+ * @sock:	socket to splice from
+ * @pipe:	pipe to splice to
+ * @len:	number of bytes to splice
+ * @flags:	splice modifier flags
+ *
+ * Will read pages from given socket and fill them into a pipe.
+ */
+ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
+			struct pipe_inode_info *pipe, size_t len,
+			unsigned int flags)
+{
+	struct sock *sk = sock->sk;
+	struct tcp_splice_state tss = {
+		.pipe = pipe,
+		.len = len,
+		.flags = flags,
+	};
+	long timeo;
+	ssize_t spliced;
+	int ret;
+
+	if (*ppos != 0)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	ret = spliced = 0;
+	timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	while (tss.len) {
+		ret = __tcp_splice_read(sk, &tss);
+		if (ret < 0)
+			break;
+		else if (!ret) {
+			if (spliced)
+				break;
+			if (flags & SPLICE_F_NONBLOCK) {
+				ret = -EAGAIN;
+				break;
+			}
+			if (sock_flag(sk, SOCK_DONE))
+				break;
+			if (sk->sk_err) {
+				ret = sock_error(sk);
+				break;
+			}
+			if (sk->sk_shutdown & RCV_SHUTDOWN)
+				break;
+			if (sk->sk_state == TCP_CLOSE) {
+				/*
+				 * This occurs when user tries to read
+				 * from never connected socket.
+				 */
+				if (!sock_flag(sk, SOCK_DONE))
+					ret = -ENOTCONN;
+				break;
+			}
+			if (!timeo) {
+				ret = -EAGAIN;
+				break;
+			}
+			sk_wait_data(sk, &timeo);
+			if (signal_pending(current)) {
+				ret = sock_intr_errno(timeo);
+				break;
+			}
+			continue;
+		}
+		tss.len -= ret;
+		spliced += ret;
+
+		release_sock(sk);
+		lock_sock(sk);
+
+		if (sk->sk_err || sk->sk_state == TCP_CLOSE ||
+		    (sk->sk_shutdown & RCV_SHUTDOWN) || !timeo ||
+		    signal_pending(current))
+			break;
+	}
+
+	release_sock(sk);
+
+	if (spliced)
+		return spliced;
+
+	return ret;
+}
+
 static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
 			 size_t psize, int flags)
 {
@@ -2515,6 +2636,7 @@ EXPORT_SYMBOL(tcp_poll);
 EXPORT_SYMBOL(tcp_read_sock);
 EXPORT_SYMBOL(tcp_recvmsg);
 EXPORT_SYMBOL(tcp_sendmsg);
+EXPORT_SYMBOL(tcp_splice_read);
 EXPORT_SYMBOL(tcp_sendpage);
 EXPORT_SYMBOL(tcp_setsockopt);
 EXPORT_SYMBOL(tcp_shutdown);
diff --git a/net/socket.c b/net/socket.c
index f453019..41240f5 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -111,6 +111,9 @@ static long compat_sock_ioctl(struct file *file,
 static int sock_fasync(int fd, struct file *filp, int on);
 static ssize_t sock_sendpage(struct file *file, struct page *page,
 			     int offset, size_t size, loff_t *ppos, int more);
+static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
+			        struct pipe_inode_info *pipe, size_t len,
+				unsigned int flags);
 
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
@@ -133,6 +136,7 @@ static const struct file_operations socket_file_ops = {
 	.fasync =	sock_fasync,
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
+	.splice_read =	sock_splice_read,
 };
 
 /*
@@ -691,6 +695,15 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 	return sock->ops->sendpage(sock, page, offset, size, flags);
 }
 
+static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
+			        struct pipe_inode_info *pipe, size_t len,
+				unsigned int flags)
+{
+	struct socket *sock = file->private_data;
+
+	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
+}
+
 static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
 					 struct sock_iocb *siocb)
 {
-- 
1.5.2.1.174.gcd03


--61jdw2sOBCFtR2d/--
