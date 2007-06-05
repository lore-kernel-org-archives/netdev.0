From: Jens Axboe <jens.axboe@oracle.com>
Subject: [PATCH][RFC] network splice receive
Date: Tue, 5 Jun 2007 10:05:43 +0200
Message-ID: <20070605080542.GA9909@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:11637 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbXFEIHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 04:07:34 -0400
Received: from nelson.home.kernel.dk (nelson.home.kernel.dk [192.168.0.33])
	by kernel.dk (Postfix) with ESMTP id 4A90F2571F0
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2007 10:07:31 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Here's an implementation of tcp network splice receive support. It's
originally based on the patch set that Intel posted some time ago, but
has been (close to) 100% reworked.

Now, I'm not a networking guru by any stretch of the imagination, so I'd
like some input on the direction of the main patch. Is the approach
feasible? Glaring errors? Missing bits?

If you want to test it, I'd suggest downloading the latest splice tools
snapshot here:

http://brick.kernel.dk/snaps/splice-git-latest.tar.gz

Examples:

- Sending a small test message over the network:

  user@host1:~/splice $ ./splice-fromnet 9999 | cat
  user@host2:~ $ echo hello | netcat host1 9999

  should write "hello" on host1. Yeah, complex stuff.

- Sending a file over the network:

  user@host1:~/splice $ ./splice-fromnet 9999 | ./splice out outfile
  user@host2:~ $ cat somefile | netcat host1 9999

  should send somefile over the network, storing it in outfile.

Seems to work reasonably well for me, sometimes I do see small ranges
inside the output file that are not correct, but I haven't been able to
reproduce today. I think it has to do with page reuse, hence the
NET_COPY_SPLICE ifdef that you can enable to just plain copy the data
instead of referencing it.

Patches are against the #splice branch of the block repo, "official" url
of that is:

git://git.kernel.dk/data/git/linux-2.6-block.git/

and it's based on Linus main tree (at 2.6.22-rc4 right now). Let me know
if I should supply netdev branch patches instead.

-- 
Jens Axboe


--bp/iNruPH9dso1Pn
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-NET-tcp_read_sock-alloc-recv_actor-return-retur.patch"

>From 592c46ea813c31c0d6b28bf543ce2f5dd884a75e Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Mon, 4 Jun 2007 15:06:43 +0200
Subject: [PATCH] [NET] tcp_read_sock: alloc recv_actor() return return negative error value

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
1.5.2.rc1


--bp/iNruPH9dso1Pn
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0002-NET-TCP-splice-receive-support.patch"

>From 10d906a9a5a16a022d5067bee3963a0e3a03ae0c Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Tue, 5 Jun 2007 09:54:00 +0200
Subject: [PATCH] [NET] TCP splice receive support

Losely based on original patches from Intel, modified to actually
be zero-copy (the original patches memcpy'ed the data).

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 include/linux/net.h    |    3 +
 include/linux/skbuff.h |    5 ++
 include/net/tcp.h      |    3 +
 net/core/skbuff.c      |  114 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c     |    1 +
 net/ipv4/tcp.c         |  138 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/socket.c           |   13 +++++
 7 files changed, 277 insertions(+), 0 deletions(-)

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
index e7367c7..619dcf5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1504,6 +1504,11 @@ extern int	       skb_store_bits(struct sk_buff *skb, int offset,
 extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      __wsum csum);
+extern int             skb_splice_bits(const struct sk_buff *skb,
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
index 7c6a34e..4e97220 100644
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
@@ -71,6 +72,33 @@
 static struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
 
+static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
+				  struct pipe_buffer *buf)
+{
+#ifdef NET_COPY_SPLICE
+	__free_page(buf->page);
+#else
+	put_page(buf->page);
+#endif
+}
+
+static int sock_pipe_buf_steal(struct pipe_inode_info *pipe,
+			       struct pipe_buffer *buf)
+{
+	return 1;
+}
+
+/* Pipe buffer operations for a socket. */
+static struct pipe_buf_operations sock_pipe_buf_ops = {
+	.can_merge = 0,
+	.map = generic_pipe_buf_map,
+	.unmap = generic_pipe_buf_unmap,
+	.pin = generic_pipe_buf_pin,
+	.release = sock_pipe_buf_release,
+	.steal = sock_pipe_buf_steal,
+	.get = generic_pipe_buf_get,
+};
+
 /*
  *	Keep out-of-line to prevent kernel bloat.
  *	__builtin_return_address is not used because it is not always
@@ -1116,6 +1144,92 @@ fault:
 	return -EFAULT;
 }
 
+/*
+ * Fill page/offset/length into spd, if it can hold more pages.
+ */
+static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
+				unsigned int len, unsigned int offset)
+{
+	struct page *p;
+
+	if (unlikely(spd->nr_pages == PIPE_BUFFERS))
+		return 1;
+
+#ifdef NET_COPY_SPLICE
+	p = alloc_pages(GFP_KERNEL, 0);
+	if (!p)
+		return 1;
+
+	memcpy(page_address(p) + offset, page_address(page) + offset, len);
+#else
+	p = page;
+	get_page(p);
+#endif
+
+	spd->pages[spd->nr_pages] = p;
+	spd->partial[spd->nr_pages].len = len;
+	spd->partial[spd->nr_pages].offset = offset;
+	spd->nr_pages++;
+	return 0;
+}
+
+/*
+ * Map data from the skb to a pipe.
+ */
+int skb_splice_bits(const struct sk_buff *skb, unsigned int offset,
+		    struct pipe_inode_info *pipe, unsigned int len,
+		    unsigned int flags)
+{
+	struct partial_page partial[PIPE_BUFFERS];
+	struct page *pages[PIPE_BUFFERS];
+	int headlen, seg, i;
+	struct page *page;
+	struct splice_pipe_desc spd = {
+		.pages = pages,
+		.partial = partial,
+		.flags = flags,
+		.ops = &sock_pipe_buf_ops,
+	};
+
+	headlen = skb_headlen(skb) - offset;
+	if (headlen <= 0)
+		return 0;
+
+	/*
+	 * first map the linear region into the pages/partial map
+	 */
+	i = seg = 0;
+	while (i < headlen) {
+		void *p = skb->data + i;
+		unsigned int poff = (unsigned long) p & (PAGE_SIZE - 1);
+		unsigned int plen;
+
+		page = virt_to_page(p);
+		poff = (unsigned long) p & (PAGE_SIZE - 1);
+		plen = min_t(unsigned, (unsigned)(headlen - i), PAGE_SIZE - poff);
+
+		if (spd_fill_page(&spd, page, plen, poff))
+			break;
+
+		i += PAGE_SIZE - poff;
+	}
+
+	/*
+	 * then map the fragments
+	 */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++, seg++) {
+		const skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+
+		if (spd_fill_page(&spd, f->page, f->size, f->page_offset))
+			break;
+	}
+
+	if (spd.nr_pages)
+		return splice_to_pipe(pipe, &spd);
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
index 450f44b..34228ca 100644
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
@@ -291,6 +296,17 @@ EXPORT_SYMBOL(tcp_memory_allocated);
 EXPORT_SYMBOL(tcp_sockets_allocated);
 
 /*
+ *	Create a TCP splice context.
+ */
+struct tcp_splice_state {
+		struct pipe_inode_info *pipe;
+		void (*original_data_ready)(struct sock*, int);
+		size_t len;
+		size_t offset;
+		unsigned int flags;
+};
+
+/*
  * Pressure flag: try to collapse.
  * Technical note: it is used by multiple contexts non atomically.
  * All the sk_stream_mem_schedule() is of this nature: accounting
@@ -500,6 +516,127 @@ static inline void tcp_push(struct sock *sk, int flags, int mss_now,
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
+void tcp_splice_data_ready(struct sock *sk, int flag)
+{
+	/*
+	 * Restore splice context/ read_descriptor_t from sk->sk_user_data
+	 */
+	struct tcp_splice_state *tss = sk->sk_user_data;
+	read_descriptor_t rd_desc = {
+		.arg.data = tss,
+		.count = 1,
+	};
+
+	lock_sock(sk);
+	tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
+	release_sock(sk);
+
+	if (tss->len == 0) {
+		/* Restore original sk_data_ready callback. */
+		sk->sk_data_ready = tss->original_data_ready;
+		/* Wakeup user thread. */
+		sk->sk_state_change(sk);
+	}
+}
+
+static int __tcp_splice_read(struct sock *sk, struct tcp_splice_state *tss)
+{
+	/* Store TCP splice context information in read_descriptor_t. */
+	read_descriptor_t rd_desc = {
+		.arg.data = tss,
+	};
+
+	tss->original_data_ready = sk->sk_data_ready;
+	sk->sk_user_data = tss;
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
+	struct tcp_splice_state tss = {
+		.pipe = pipe,
+		.len = len,
+		.flags = flags,
+	};
+	struct sock *sk = sock->sk;
+	ssize_t spliced;
+	int ret;
+
+	if (*ppos != 0)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	ret = spliced = 0;
+	while (tss.len) {
+		ret = __tcp_splice_read(sk, &tss);
+		if (ret < 0)
+			break;
+		else if (!ret) {
+			if (flags & SPLICE_F_NONBLOCK) {
+				ret = -EAGAIN;
+				break;
+			}
+			if (spliced)
+				break;
+			if (sock_flag(sk, SOCK_DONE))
+				break;
+			if (sk->sk_err) {
+				ret = sock_error(sk);
+				break;
+			}
+			if (sk->sk_shutdown & RCV_SHUTDOWN)
+				break;
+			if (sk->sk_state == TCP_CLOSE) {
+				if (!sock_flag(sk, SOCK_DONE)) {
+					/* This occurs when user tries to read
+					 * from never connected socket.
+					 */
+					ret = -ENOTCONN;
+					break;
+				}
+				break;
+			}
+			if (signal_pending(current)) {
+				ret = -EAGAIN;
+				break;
+			}
+			printk("wait for more...\n");
+			sk_wait_data(sk, &sk->sk_rcvtimeo);
+			continue;
+		}
+		tss.len -= ret;
+		spliced += ret;
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
@@ -2515,6 +2652,7 @@ EXPORT_SYMBOL(tcp_poll);
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
1.5.2.rc1


--bp/iNruPH9dso1Pn--
