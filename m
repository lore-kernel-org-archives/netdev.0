From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Limit socket I/O iovec total length to INT_MAX.
Date: Thu, 28 Oct 2010 11:22:31 -0700 (PDT)
Message-ID: <20101028.112231.232747062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761169Ab0J1SWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:22:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This helps protect us from overflow issues down in the
individual protocol sendmsg/recvmsg handlers.  Once
we hit INT_MAX we truncate out the rest of the iovec
by setting the iov_len members to zero.

This works because:

1) For SOCK_STREAM and SOCK_SEQPACKET sockets, partial
   writes are allowed and the application will just continue
   with another write to send the rest of the data.

2) For datagram oriented sockets, where there must be a
   one-to-one correspondance between write() calls and
   packets on the wire, INT_MAX is going to be far larger
   than the packet size limit the protocol is going to
   check for and signal with -EMSGSIZE.

Based upon a patch by Linus Torvalds.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Ok, this is the patch I am testing right now.  It ought to
plug the TIPC holes wrt. handling iovecs given by the
user.

I'll look at the recently discovered RDS crap next :-/

 include/linux/socket.h |    2 +-
 net/compat.c           |   12 +++++++-----
 net/core/iovec.c       |   19 +++++++++----------
 3 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5146b50..86b652f 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -322,7 +322,7 @@ extern int csum_partial_copy_fromiovecend(unsigned char *kdata,
 					  int offset, 
 					  unsigned int len, __wsum *csump);
 
-extern long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
+extern int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode);
 extern int memcpy_toiovec(struct iovec *v, unsigned char *kdata, int len);
 extern int memcpy_toiovecend(const struct iovec *v, unsigned char *kdata,
 			     int offset, int len);
diff --git a/net/compat.c b/net/compat.c
index 63d260e..71bfd8e 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -34,17 +34,19 @@ static inline int iov_from_user_compat_to_kern(struct iovec *kiov,
 					  struct compat_iovec __user *uiov32,
 					  int niov)
 {
-	int tot_len = 0;
+	size_t tot_len = 0;
 
 	while (niov > 0) {
 		compat_uptr_t buf;
 		compat_size_t len;
 
 		if (get_user(len, &uiov32->iov_len) ||
-		   get_user(buf, &uiov32->iov_base)) {
-			tot_len = -EFAULT;
-			break;
-		}
+		    get_user(buf, &uiov32->iov_base))
+			return -EFAULT;
+
+		if (len > INT_MAX - tot_len)
+			len = INT_MAX - tot_len;
+
 		tot_len += len;
 		kiov->iov_base = compat_ptr(buf);
 		kiov->iov_len = (__kernel_size_t) len;
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 72aceb1..e7f5b29 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -35,10 +35,10 @@
  *	in any case.
  */
 
-long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode)
+int verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address, int mode)
 {
 	int size, ct;
-	long err;
+	size_t err;
 
 	if (m->msg_namelen) {
 		if (mode == VERIFY_READ) {
@@ -62,14 +62,13 @@ long verify_iovec(struct msghdr *m, struct iovec *iov, struct sockaddr *address,
 	err = 0;
 
 	for (ct = 0; ct < m->msg_iovlen; ct++) {
-		err += iov[ct].iov_len;
-		/*
-		 * Goal is not to verify user data, but to prevent returning
-		 * negative value, which is interpreted as errno.
-		 * Overflow is still possible, but it is harmless.
-		 */
-		if (err < 0)
-			return -EMSGSIZE;
+		size_t len = iov[ct].iov_len;
+
+		if (len > INT_MAX - err) {
+			len = INT_MAX - err;
+			iov[ct].iov_len = len;
+		}
+		err += len;
 	}
 
 	return err;
-- 
1.7.3.2

