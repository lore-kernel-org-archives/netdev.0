From: Eric Wong <normalperson-rMlxZR9MS24@public.gmane.org>
Subject: [RFC] net: support SOCK_DONTWAIT for non-blocking accept4
Date: Wed, 13 May 2015 02:37:12 +0000
Message-ID: <20150513023712.GA4206@dcvr.yhbt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

It may occasionally be useful to share a listen socket between two
or more tasks with different processing models (blocking and
non-blocking).

This may happen during a software upgrade when an older process
(using blocking I/O) shares the listen socket with a new process
which wants to use non-blocking I/O, but still provides a path for
the old process to fall back to blocking I/O and avoiding poll()
for exclusive wakeup if the upgrade does not work out.

Proposed manpage addtion:

  SOCK_DONTWAIT

  Enable non-blocking operation on the listen socket for this call only.
  Unlike SOCK_NONBLOCK, this does not affect the accepted socket, nor does
  it change the file status flag of the listen socket for other calls.

Signed-off-by: Eric Wong <normalperson-rMlxZR9MS24@public.gmane.org>
---
  RFC since this seems a bit esoteric, and I'm not sure if it'd be
  useful to others.  I've certainly wished I've had it a few times
  along with an opposite SOCK_MUSTWAIT flag to ignore O_NONBLOCK on
  a listen socket.

 include/linux/net.h |  3 +++
 net/socket.c        | 10 ++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 17d8339..9a71654 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -76,6 +76,9 @@ enum sock_type {
 #ifndef SOCK_NONBLOCK
 #define SOCK_NONBLOCK	O_NONBLOCK
 #endif
+#ifndef SOCK_DONTWAIT
+#define SOCK_DONTWAIT	MSG_DONTWAIT
+#endif
 
 #endif /* ARCH_HAS_SOCKET_TYPES */
 
diff --git a/net/socket.c b/net/socket.c
index 245330c..52395df 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1294,6 +1294,7 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	BUILD_BUG_ON((SOCK_MAX | SOCK_TYPE_MASK) != SOCK_TYPE_MASK);
 	BUILD_BUG_ON(SOCK_CLOEXEC & SOCK_TYPE_MASK);
 	BUILD_BUG_ON(SOCK_NONBLOCK & SOCK_TYPE_MASK);
+	BUILD_BUG_ON(SOCK_DONTWAIT & SOCK_TYPE_MASK);
 
 	flags = type & ~SOCK_TYPE_MASK;
 	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
@@ -1502,8 +1503,9 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	struct file *newfile;
 	int err, len, newfd, fput_needed;
 	struct sockaddr_storage address;
+	int f_flags;
 
-	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
+	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK | SOCK_DONTWAIT))
 		return -EINVAL;
 
 	if (SOCK_NONBLOCK != O_NONBLOCK && (flags & SOCK_NONBLOCK))
@@ -1513,6 +1515,10 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	if (!sock)
 		goto out;
 
+	f_flags = sock->file->f_flags;
+	if (flags & SOCK_DONTWAIT)
+		f_flags |= O_NONBLOCK;
+
 	err = -ENFILE;
 	newsock = sock_alloc();
 	if (!newsock)
@@ -1545,7 +1551,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	if (err)
 		goto out_fd;
 
-	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
+	err = sock->ops->accept(sock, newsock, f_flags);
 	if (err < 0)
 		goto out_fd;
 
-- 
EW
