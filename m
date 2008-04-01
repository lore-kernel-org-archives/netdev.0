From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 1 Apr 2008 21:36:24 +0400
Message-ID: <20080401173624.GA28217@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <47F26D87.7020006@kolumbus.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Mika =?utf-8?B?UGVudHRpbMOk?= <mika.penttila@kolumbus.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40944 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756347AbYDARge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2008 13:36:34 -0400
Content-Disposition: inline
In-Reply-To: <47F26D87.7020006@kolumbus.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi.

On Tue, Apr 01, 2008 at 08:14:47PM +0300, Mika Penttilä (mika.penttila@kolumbus.fi) wrote:
> Aren't you breaking the other types of splices, like splice to file 
> which doesn't have the wakeup thing.

Do we care about them? Likely we do...

Thanks for pointing!

Inlined fix on top of previous patch, attached full diff.
Not tested with other splices though, but is rather straightforward :)
Is there simple application to run?

--- /tmp/splice.c	2008-04-01 21:30:39.000000000 +0400
+++ ./fs/splice.c	2008-04-01 21:29:53.000000000 +0400
@@ -631,7 +631,8 @@
 	ret = 0;
 	do_wakeup = 0;
 
-	atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
+	if (actor == pipe_to_sendpage)
+		atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
 
 	for (;;) {
 		if (pipe->nrbufs) {
@@ -670,8 +671,9 @@
 			}
 
 			if (!sd->total_len) {
-				wait_event_interruptible(pipe->wait,
-					!atomic_read(&pipe->god_blessed_us));
+				if (actor == pipe_to_sendpage)
+					wait_event_interruptible(pipe->wait,
+						!atomic_read(&pipe->god_blessed_us));
 				break;
 			}
 		}
@@ -679,7 +681,8 @@
 		if (pipe->nrbufs)
 			continue;
 
-		wait_event_interruptible(pipe->wait, !atomic_read(&pipe->god_blessed_us));
+		if (actor == pipe_to_sendpage)
+			wait_event_interruptible(pipe->wait, !atomic_read(&pipe->god_blessed_us));
 
 		if (!pipe->writers)
 			break;


-- 
	Evgeniy Polyakov

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=1

diff --git a/fs/read_write.c b/fs/read_write.c
index 49a9871..8c94e03 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -16,6 +16,7 @@
 #include <linux/syscalls.h>
 #include <linux/pagemap.h>
 #include <linux/splice.h>
+#include <net/sock.h>
 #include "read_write.h"
 
 #include <asm/uaccess.h>
@@ -703,6 +704,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 	loff_t pos;
 	ssize_t retval;
 	int fput_needed_in, fput_needed_out, fl;
+	struct sock *sk;
+	struct socket *sock;
 
 	/*
 	 * Get input file, and verify that it is ok..
@@ -762,6 +765,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 		count = max - pos;
 	}
 
+	sock = out_file->private_data;
+	sk = sock->sk;
+
+	sk->sk_user_data = &skb_splice_destructor;
+	sk->sk_flags |= SO_PRIVATE_CALLBACK;
+
 	fl = 0;
 #if 0
 	/*
diff --git a/fs/splice.c b/fs/splice.c
index 0670c91..e29c485 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -29,6 +29,7 @@
 #include <linux/syscalls.h>
 #include <linux/uio.h>
 #include <linux/security.h>
+#include <net/sock.h>
 
 /*
  * Attempt to steal a page from a pipe buffer. This should perhaps go into
@@ -535,6 +536,7 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
 	if (!ret) {
 		more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
 
+		buf->page->lru.next = (void *)pipe;
 		ret = file->f_op->sendpage(file, buf->page, buf->offset,
 					   sd->len, &pos, more);
 	}
@@ -629,6 +631,9 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
 	ret = 0;
 	do_wakeup = 0;
 
+	if (actor == pipe_to_sendpage)
+		atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
+
 	for (;;) {
 		if (pipe->nrbufs) {
 			struct pipe_buffer *buf = pipe->bufs + pipe->curbuf;
@@ -665,12 +670,20 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
 					do_wakeup = 1;
 			}
 
-			if (!sd->total_len)
+			if (!sd->total_len) {
+				if (actor == pipe_to_sendpage)
+					wait_event_interruptible(pipe->wait,
+						!atomic_read(&pipe->god_blessed_us));
 				break;
+			}
 		}
 
 		if (pipe->nrbufs)
 			continue;
+
+		if (actor == pipe_to_sendpage)
+			wait_event_interruptible(pipe->wait, !atomic_read(&pipe->god_blessed_us));
+
 		if (!pipe->writers)
 			break;
 		if (!pipe->waiting_writers) {
diff --git a/include/asm-x86/socket.h b/include/asm-x86/socket.h
index 80af9c4..a4b047e 100644
--- a/include/asm-x86/socket.h
+++ b/include/asm-x86/socket.h
@@ -54,4 +54,6 @@
 
 #define SO_MARK			36
 
+#define SO_PRIVATE_CALLBACK	37
+
 #endif /* _ASM_SOCKET_H */
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index 8e41202..465405a 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -51,6 +51,7 @@ struct pipe_inode_info {
 	unsigned int waiting_writers;
 	unsigned int r_counter;
 	unsigned int w_counter;
+	atomic_t god_blessed_us;
 	struct fasync_struct *fasync_readers;
 	struct fasync_struct *fasync_writers;
 	struct inode *inode;
diff --git a/include/net/sock.h b/include/net/sock.h
index fd98760..ac7bc52 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -862,6 +862,8 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
 extern void			sock_wfree(struct sk_buff *skb);
 extern void			sock_rfree(struct sk_buff *skb);
 
+extern void skb_splice_destructor(struct sk_buff *skb);
+
 extern int			sock_setsockopt(struct socket *sock, int level,
 						int op, char __user *optval,
 						int optlen);
@@ -1168,6 +1170,8 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	sock_hold(sk);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
+	if (sk->sk_flags & SO_PRIVATE_CALLBACK)
+		skb->destructor = sk->sk_user_data;
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 2654c14..0c10581 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -112,6 +112,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/pipe_fs_i.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -1116,6 +1117,24 @@ void sock_wfree(struct sk_buff *skb)
 	sock_put(sk);
 }
 
+void skb_splice_destructor(struct sk_buff *skb)
+{
+	if (skb_shinfo(skb)->nr_frags) {
+		int i;
+		struct pipe_inode_info *pipe;
+
+		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+			struct page *page = skb_shinfo(skb)->frags[i].page;
+
+			pipe = (struct pipe_inode_info *)page->lru.next;
+			if (atomic_dec_return(&pipe->god_blessed_us) == 0)
+				wake_up(&pipe->wait);
+		}
+	}
+
+	sock_wfree(skb);
+}
+
 /*
  * Read buffer destructor automatically called from kfree_skb.
  */
@@ -2164,6 +2183,7 @@ EXPORT_SYMBOL(sock_no_socketpair);
 EXPORT_SYMBOL(sock_rfree);
 EXPORT_SYMBOL(sock_setsockopt);
 EXPORT_SYMBOL(sock_wfree);
+EXPORT_SYMBOL(skb_splice_destructor);
 EXPORT_SYMBOL(sock_wmalloc);
 EXPORT_SYMBOL(sock_i_uid);
 EXPORT_SYMBOL(sock_i_ino);

--cNdxnHkX5QqsyA0e--
