From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH] poll/select performance on datagram sockets
Date: Fri, 29 Oct 2010 19:21:17 +0100
Message-ID: <1288376477-17387-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:33848 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab0J2SYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 14:24:31 -0400
In-Reply-To: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 fs/select.c         |   27 ++++++++++++++++++++++++---
 include/linux/fs.h  |    1 +
 include/linux/net.h |    3 +++
 net/socket.c        |   15 ++++++++++-----
 net/unix/af_unix.c  |   17 +++++++++++------
 5 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 500a669..ff46afa 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -449,9 +449,21 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
 				if (file) {
 					f_op = file->f_op;
 					mask = DEFAULT_POLLMASK;
-					if (f_op && f_op->poll) {
+					if (f_op && f_op->poll2) {
+						unsigned long filter_mask = 0;
+						filter_mask |= (in & bit)
+							? POLLIN_SET : 0;
+						filter_mask |= (out & bit)
+							? POLLOUT_SET : 0;
+						filter_mask |= (ex & bit)
+							? POLLEX_SET : 0;
 						wait_key_set(wait, in, out, bit);
-						mask = (*f_op->poll)(file, wait);
+						mask = (*f_op->poll2)(file,
+							wait, filter_mask);
+					} else if (f_op && f_op->poll) {
+						wait_key_set(wait, in, out, bit);
+						mask = (*f_op->poll)(file,
+							wait);
 					}
 					fput_light(file, fput_needed);
 					if ((mask & POLLIN_SET) && (in & bit)) {
@@ -738,7 +750,16 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
 		mask = POLLNVAL;
 		if (file != NULL) {
 			mask = DEFAULT_POLLMASK;
-			if (file->f_op && file->f_op->poll) {
+			if (file->f_op && file->f_op->poll2) {
+				unsigned long filter_mask;
+				filter_mask = pollfd->events
+						| POLLERR | POLLHUP;
+				if (pwait)
+					pwait->key = pollfd->events |
+							POLLERR | POLLHUP;
+				mask = file->f_op->poll2(file, pwait,
+							filter_mask);
+			} else if (file->f_op && file->f_op->poll) {
 				if (pwait)
 					pwait->key = pollfd->events |
 							POLLERR | POLLHUP;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 509ca14..dd0eb7a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1493,6 +1493,7 @@ struct file_operations {
 	ssize_t (*aio_write) (struct kiocb *, const struct iovec *, unsigned long, loff_t);
 	int (*readdir) (struct file *, void *, filldir_t);
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
+	unsigned int (*poll2) (struct file *, struct poll_table_struct *, unsigned long);
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
diff --git a/include/linux/net.h b/include/linux/net.h
index dee0b11..1f33d1c 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -175,6 +175,9 @@ struct proto_ops {
 				      int *sockaddr_len, int peer);
 	unsigned int	(*poll)	     (struct file *file, struct socket *sock,
 				      struct poll_table_struct *wait);
+	unsigned int	(*poll2)     (struct file *file, struct socket *sock,
+				      struct poll_table_struct *wait,
+				      unsigned long filter_mask);
 	int		(*ioctl)     (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
 #ifdef CONFIG_COMPAT
diff --git a/net/socket.c b/net/socket.c
index 367d547..38b7786 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -113,8 +113,9 @@ static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
 static int sock_mmap(struct file *file, struct vm_area_struct *vma);
 
 static int sock_close(struct inode *inode, struct file *file);
-static unsigned int sock_poll(struct file *file,
-			      struct poll_table_struct *wait);
+static unsigned int sock_poll2(struct file *file,
+			      struct poll_table_struct *wait,
+			      unsigned long filter_mask);
 static long sock_ioctl(struct file *file, unsigned int cmd, unsigned long arg);
 #ifdef CONFIG_COMPAT
 static long compat_sock_ioctl(struct file *file,
@@ -137,7 +138,7 @@ static const struct file_operations socket_file_ops = {
 	.llseek =	no_llseek,
 	.aio_read =	sock_aio_read,
 	.aio_write =	sock_aio_write,
-	.poll =		sock_poll,
+	.poll2 =	sock_poll2,
 	.unlocked_ioctl = sock_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_sock_ioctl,
@@ -1049,7 +1050,8 @@ out_release:
 }
 
 /* No kernel lock held - perfect */
-static unsigned int sock_poll(struct file *file, poll_table *wait)
+static unsigned int sock_poll2(struct file *file, poll_table *wait,
+			       unsigned long filter_mask)
 {
 	struct socket *sock;
 
@@ -1057,7 +1059,10 @@ static unsigned int sock_poll(struct file *file, poll_table *wait)
 	 *      We can't return errors to poll, so it's either yes or no.
 	 */
 	sock = file->private_data;
-	return sock->ops->poll(file, sock, wait);
+	if (sock->ops->poll2)
+		return sock->ops->poll2(file, sock, wait, filter_mask);
+	else
+		return sock->ops->poll(file, sock, wait);
 }
 
 static int sock_mmap(struct file *file, struct vm_area_struct *vma)
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 617bea4..60e30ea 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -489,7 +489,7 @@ static int unix_accept(struct socket *, struct socket *, int);
 static int unix_getname(struct socket *, struct sockaddr *, int *, int);
 static unsigned int unix_poll(struct file *, struct socket *, poll_table *);
 static unsigned int unix_dgram_poll(struct file *, struct socket *,
-				    poll_table *);
+				    poll_table *, unsigned long);
 static int unix_ioctl(struct socket *, unsigned int, unsigned long);
 static int unix_shutdown(struct socket *, int);
 static int unix_stream_sendmsg(struct kiocb *, struct socket *,
@@ -535,7 +535,7 @@ static const struct proto_ops unix_dgram_ops = {
 	.socketpair =	unix_socketpair,
 	.accept =	sock_no_accept,
 	.getname =	unix_getname,
-	.poll =		unix_dgram_poll,
+	.poll2 =	unix_dgram_poll,
 	.ioctl =	unix_ioctl,
 	.listen =	sock_no_listen,
 	.shutdown =	unix_shutdown,
@@ -556,7 +556,7 @@ static const struct proto_ops unix_seqpacket_ops = {
 	.socketpair =	unix_socketpair,
 	.accept =	unix_accept,
 	.getname =	unix_getname,
-	.poll =		unix_dgram_poll,
+	.poll2 =	unix_dgram_poll,
 	.ioctl =	unix_ioctl,
 	.listen =	unix_listen,
 	.shutdown =	unix_shutdown,
@@ -2031,7 +2031,8 @@ static unsigned int unix_poll(struct file *file, struct socket *sock, poll_table
 }
 
 static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
-				    poll_table *wait)
+				    poll_table *wait,
+				    unsigned long filter_mask)
 {
 	struct sock *sk = sock->sk, *other;
 	unsigned int mask, writable;
@@ -2061,8 +2062,12 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 			return mask;
 	}
 
-	/* writable? */
-	writable = unix_writable(sk);
+	/* writable?
+	 * sock_poll_wait() is expensive. Don't bother checking if it is not
+	 * requested.
+	 */
+	writable = (filter_mask & (POLLOUT | POLLWRNORM | POLLWRBAND))
+		    && unix_writable(sk);
 	if (writable) {
 		other = unix_peer_get(sk);
 		if (other) {
-- 
1.7.1

