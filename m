From: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH][RFC] network splice receive v3
Date: Wed, 11 Jul 2007 11:19:27 +0200
Message-ID: <20070711091927.GQ4587@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ZARJHfwaSJQLOEUz"
Cc: olaf.kirch@oracle.com, johnpol@2ka.mipt.ru
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:25540 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756244AbXGKJTV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 05:19:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ZARJHfwaSJQLOEUz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Here's an updated implementation of tcp network splice receive support.
It actually works for me now, no data corruption seen.

For the original announcement and how to test it, see:

http://marc.info/?l=linux-netdev&m=118103093400770&w=2

The splice core changes needed to support this are now merged in
2.6.22-git, so the patchset shrinks to just two patches - one for adding
a release hook, and one for the networking changes.

The code is also available in the splice-net branch here:

git://git.kernel.dk/data/git/linux-2.6-block.git splice-net

There's a third experimental patch in there that allows vmsplice
directly to user memory, that still needs some work though.

Comments, testing welcome!

-- 
Jens Axboe


--ZARJHfwaSJQLOEUz
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-splice-don-t-assume-regular-pages-in-splice_to_pipe.patch"

>From e59a68f2d7d261b301960b97659910aab8e3d776 Mon Sep 17 00:00:00 2001
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
index 3160951..4b4b501 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -254,11 +254,16 @@ ssize_t splice_to_pipe(struct pipe_inode_info *pipe,
 	}
 
 	while (page_nr < spd_pages)
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
@@ -277,6 +282,7 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		.partial = partial,
 		.flags = flags,
 		.ops = &page_cache_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	index = *ppos >> PAGE_CACHE_SHIFT;
@@ -1674,6 +1680,7 @@ static long vmsplice_to_pipe(struct file *file, const struct iovec __user *iov,
 		.partial = partial,
 		.flags = flags,
 		.ops = &user_page_pipe_buf_ops,
+		.spd_release = spd_release_page,
 	};
 
 	pipe = pipe_info(file->f_path.dentry->d_inode);
diff --git a/include/linux/splice.h b/include/linux/splice.h
index 2c08456..b8fa41e 100644
--- a/include/linux/splice.h
+++ b/include/linux/splice.h
@@ -54,6 +54,7 @@ struct splice_pipe_desc {
 	int nr_pages;			/* number of pages in map */
 	unsigned int flags;		/* splice flags */
 	const struct pipe_buf_operations *ops;/* ops associated with output pipe */
+	void (*spd_release)(struct splice_pipe_desc *, unsigned int);
 };
 
 typedef int (splice_actor)(struct pipe_inode_info *, struct pipe_buffer *,
-- 
1.5.3.rc0.90.gbaa79


--ZARJHfwaSJQLOEUz
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0002-TCP-splice-receive-support.patch"

>From b62e4a5a3e3220702e837e556427972dc591ff59 Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 20 Jun 2007 09:54:14 +0200
Subject: [PATCH] TCP splice receive support

Support for network splice receive.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 include/linux/net.h    |    3 +
 include/linux/skbuff.h |    5 +
 include/net/tcp.h      |    3 +
 net/core/skbuff.c      |  246 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/tcp.c         |  129 +++++++++++++++++++++++++
 net/socket.c           |   13 +++
 7 files changed, 400 insertions(+), 0 deletions(-)

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
index 6f0b2f7..177bffc 100644
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
index 3943c3a..158e287 100644
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
+	.confirm = generic_pipe_buf_confirm,
+	.release = sock_pipe_buf_release,
+	.steal = sock_pipe_buf_steal,
+	.get = sock_pipe_buf_get,
+};
+
 /*
  *	Keep out-of-line to prevent kernel bloat.
  *	__builtin_return_address is not used because it is not always
@@ -1116,6 +1151,217 @@ fault:
 	return -EFAULT;
 }
 
+/*
+ * Callback from splice_to_pipe(), if we need to release some pages
+ * at the end of the spd in case we error'ed out in filling the pipe.
+ */
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
+	unsigned int poff, plen, len, toff, tlen;
+	int headlen, seg;
+
+	toff = *offset;
+	tlen = *total_len;
+	if (!tlen)
+		goto err;
+
+	/*
+	 * if the offset is greater than the linear part, go directly to
+	 * the fragments.
+	 */
+	headlen = skb_headlen(skb);
+	if (toff >= headlen) {
+		toff -= headlen;
+		goto map_frag;
+	}
+
+	/*
+	 * first map the linear region into the pages/partial map, skipping
+	 * any potential initial offset.
+	 */
+	len = 0;
+	while (len < headlen) {
+		void *p = skb->data + len;
+
+		poff = (unsigned long) p & (PAGE_SIZE - 1);
+		plen = min_t(unsigned int, headlen - len, PAGE_SIZE - poff);
+		len += plen;
+
+		if (toff) {
+			if (plen <= toff) {
+				toff -= plen;
+				continue;
+			}
+			plen -= toff;
+			poff += toff;
+			toff = 0;
+		}
+
+		plen = min(plen, tlen);
+		if (!plen)
+			break;
+
+		/*
+		 * just jump directly to update and return, no point
+		 * in going over fragments when the output is full.
+		 */
+		if (spd_fill_page(spd, virt_to_page(p), plen, poff, skb))
+			goto done;
+
+		tlen -= plen;
+	}
+
+	/*
+	 * then map the fragments
+	 */
+map_frag:
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
+			poff += toff;
+			toff = 0;
+		}
+
+		plen = min(plen, tlen);
+		if (!plen)
+			break;
+
+		if (spd_fill_page(spd, f->page, plen, poff, skb))
+			break;
+
+		tlen -= plen;
+	}
+
+done:
+	if (spd->nr_pages - nr_pages) {
+		*offset = 0;
+		*total_len = tlen;
+		return 0;
+	}
+err:
+	return 1;
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
+	/*
+	 * __skb_splice_bits() only fails if the output has no room left,
+	 * so no point in going over the frag_list for the error case.
+	 */
+	if (__skb_splice_bits(skb, &offset, &tlen, &spd))
+		goto done;
+	else if (!tlen)
+		goto done;
+
+	/*
+	 * now see if we have a frag_list to map
+	 */
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list && tlen; list = list->next) {
+			if (__skb_splice_bits(list, &offset, &tlen, &spd))
+				break;
+		}
+	}
+
+done:
+	/*
+	 * drop our reference to the clone, the pipe consumption will
+	 * drop the rest.
+	 */
+	kfree_skb(skb);
+
+	if (spd.nr_pages) {
+		int ret;
+
+		/*
+		 * Drop the socket lock, otherwise we have reverse
+		 * locking dependencies between sk_lock and i_mutex
+		 * here as compared to sendfile(). We enter here
+		 * with the socket lock held, and splice_to_pipe() will
+		 * grab the pipe inode lock. For sendfile() emulation,
+		 * we call into ->sendpage() with the i_mutex lock held
+		 * and networking will grab the socket lock.
+		 */
+		release_sock(__skb->sk);
+		ret = splice_to_pipe(pipe, &spd);
+		lock_sock(__skb->sk);
+		return ret;
+	}
+
+	return 0;
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
index 450f44b..63efd7a 100644
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
+ * TCP splice context
+ */
+struct tcp_splice_state {
+	struct pipe_inode_info *pipe;
+	size_t len;
+	unsigned int flags;
+};
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the sk_stream_mem_schedule() is of this nature: accounting
@@ -500,6 +514,120 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
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
+/**
+ *  tcp_splice_read - splice data from TCP socket to a pipe
+ * @sock:	socket to splice from
+ * @ppos:	position (not valid)
+ * @pipe:	pipe to splice to
+ * @len:	number of bytes to splice
+ * @flags:	splice modifier flags
+ *
+ * Description:
+ *    Will read pages from given socket and fill them into a pipe.
+ *
+ **/
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
+	/*
+	 * We can't seek on a socket input
+	 */
+	if (unlikely(*ppos))
+		return -ESPIPE;
+
+	ret = spliced = 0;
+
+	lock_sock(sk);
+
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
@@ -2515,6 +2643,7 @@ EXPORT_SYMBOL(tcp_poll);
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
1.5.3.rc0.90.gbaa79


--ZARJHfwaSJQLOEUz--
