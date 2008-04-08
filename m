From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take 2] Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 8 Apr 2008 16:25:45 +0400
Message-ID: <20080408122545.GA31729@2ka.mipt.ru>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@kernel.dk>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34532 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751363AbYDHM0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 08:26:04 -0400
Content-Disposition: inline
In-Reply-To: <20080401164904.GA2382@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Summary of the previous series with this pompous header:
when sendfile() returns, pages which it sent can still be queued in tcp
stack or hardware, so subsequent write into them will endup in
corrupting data which will be eventually sent. This concerns all
->sendpage() users namely sendfile() and splice().

With this patch it is now guaranteed that data was transferred over the
wire after splice/sendfile returns.

This approach (besides the fact that previous one was not 100% correct
dealing with cloned skbs) uses new destructor field in shared info
structure (introduced by Rusty, afacs they do not collide), which is
invoked each time data is about to be released (but before actual
release of data happens).

Patch works by assigning each page from the sendfile path a couple of
pointers: to page itself to differentiate sendfile pages from all
others and pointer to pipe structure, which wakes up splice code.
It is safe to assign the same callback for sendfile and non-sendfile
pages because of above page pointer - pages which do not have it (slab,
non-sendfile bio layer and others) will not have pipe structure
dereferenced from private pointers.

P.S. Previous patch was not an April 1 joke as long as this one :)

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/read_write.c b/fs/read_write.c
index 49a9871..1961a46 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -16,6 +16,7 @@
 #include <linux/syscalls.h>
 #include <linux/pagemap.h>
 #include <linux/splice.h>
+#include <net/sock.h>
 #include "read_write.h"
 
 #include <asm/uaccess.h>
@@ -695,6 +696,24 @@ sys_writev(unsigned long fd, const struct iovec __user *vec, unsigned long vlen)
 	return ret;
 }
 
+static void skb_splice_destructor(struct skb_shared_info *shi)
+{
+	if (shi->nr_frags) {
+		int i;
+		struct pipe_inode_info *pipe;
+
+		for (i = 0; i < shi->nr_frags; i++) {
+			struct page *page = shi->frags[i].page;
+
+			if (page->lru.prev == (struct list_head *)page) {
+				pipe = (struct pipe_inode_info *)page->lru.next;
+				if (atomic_dec_return(&pipe->god_blessed_us) == 0)
+					wake_up(&pipe->wait);
+			}
+		}
+	}
+}
+
 static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 			   size_t count, loff_t max)
 {
@@ -703,6 +722,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 	loff_t pos;
 	ssize_t retval;
 	int fput_needed_in, fput_needed_out, fl;
+	struct sock *sk;
+	struct socket *sock;
 
 	/*
 	 * Get input file, and verify that it is ok..
@@ -762,6 +783,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 		count = max - pos;
 	}
 
+	sock = out_file->private_data;
+	sk = sock->sk;
+
+	sk->sk_user_data = &skb_splice_destructor;
+	set_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);
+
 	fl = 0;
 #if 0
 	/*
@@ -775,6 +802,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd, loff_t *ppos,
 #endif
 	retval = do_splice_direct(in_file, ppos, out_file, count, fl);
 
+	clear_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);
+
 	if (retval > 0) {
 		add_rchar(current, retval);
 		add_wchar(current, retval);
diff --git a/fs/splice.c b/fs/splice.c
index 0670c91..dcda32e 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -29,6 +29,7 @@
 #include <linux/syscalls.h>
 #include <linux/uio.h>
 #include <linux/security.h>
+#include <net/sock.h>
 
 /*
  * Attempt to steal a page from a pipe buffer. This should perhaps go into
@@ -535,6 +536,8 @@ static int pipe_to_sendpage(struct pipe_inode_info *pipe,
 	if (!ret) {
 		more = (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
 
+		buf->page->lru.next = (void *)pipe;
+		buf->page->lru.prev = (void *)buf->page;
 		ret = file->f_op->sendpage(file, buf->page, buf->offset,
 					   sd->len, &pos, more);
 	}
@@ -629,6 +632,9 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
 	ret = 0;
 	do_wakeup = 0;
 
+	if (actor == pipe_to_sendpage)
+		atomic_set(&pipe->god_blessed_us, pipe->nrbufs);
+
 	for (;;) {
 		if (pipe->nrbufs) {
 			struct pipe_buffer *buf = pipe->bufs + pipe->curbuf;
@@ -665,12 +671,20 @@ ssize_t __splice_from_pipe(struct pipe_inode_info *pipe, struct splice_desc *sd,
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
diff --git a/include/linux/net.h b/include/linux/net.h
index c414d90..5977a5e 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -65,6 +65,7 @@ typedef enum {
 #define SOCK_NOSPACE		2
 #define SOCK_PASSCRED		3
 #define SOCK_PASSSEC		4
+#define SOCK_PRIVATE_CALLBACK	5
 
 #ifndef ARCH_HAS_SOCKET_TYPES
 /**
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
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bbd8d00..bd4e0c3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -147,6 +147,7 @@ struct skb_shared_info {
 	unsigned short  gso_type;
 	__be32          ip6_frag_id;
 	struct sk_buff	*frag_list;
+	void		(* destructor)(struct skb_shared_info *);
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
 
diff --git a/include/net/sock.h b/include/net/sock.h
index fd98760..af4572a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1168,6 +1168,8 @@ static inline void skb_set_owner_w(struct sk_buff *skb, struct sock *sk)
 	sock_hold(sk);
 	skb->sk = sk;
 	skb->destructor = sock_wfree;
+	if (sk->sk_socket && test_bit(SOCK_PRIVATE_CALLBACK, &sk->sk_socket->flags))
+		skb_shinfo(skb)->destructor = sk->sk_user_data;
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 0d0fd28..f69c814 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -218,6 +218,7 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 	shinfo->gso_type = 0;
 	shinfo->ip6_frag_id = 0;
 	shinfo->frag_list = NULL;
+	shinfo->destructor = NULL;
 
 	if (fclone) {
 		struct sk_buff *child = skb + 1;
@@ -294,6 +295,10 @@ static void skb_release_data(struct sk_buff *skb)
 	if (!skb->cloned ||
 	    !atomic_sub_return(skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1,
 			       &skb_shinfo(skb)->dataref)) {
+
+		if (skb_shinfo(skb)->destructor)
+			skb_shinfo(skb)->destructor(skb_shinfo(skb));
+
 		if (skb_shinfo(skb)->nr_frags) {
 			int i;
 			for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
diff --git a/net/core/sock.c b/net/core/sock.c
index 2654c14..bd470c6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -112,6 +112,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/pipe_fs_i.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>

-- 
	Evgeniy Polyakov
