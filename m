From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-2.6] Revert "net: Support inclusion of <linux/socket.h>
 before <sys/socket.h>"
Date: Thu, 12 Nov 2009 02:00:05 +0000
Message-ID: <1257991205.2237.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, 538372@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53847 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759518AbZKLCAC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 21:00:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305.  That
commit caused <linux/rtnetlink.h> to require that <sys/socket.h> is
included first, breaking autoconf tests for <linux/rtnetlink.h> and
presumably some real programs too.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Please apply this to net-2.6.

I'm not sure what the proper solution is; maybe make <linux/socket.h>
include <sys/socket.h> if __KERNEL__ is not defined?

Ben.

 include/linux/socket.h |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 3273a0c..3b461df 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -16,7 +16,7 @@ struct __kernel_sockaddr_storage {
 				/* _SS_MAXSIZE value minus size of ss_family */
 } __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */
 
-#ifdef __KERNEL__
+#if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
 
 #include <asm/socket.h>			/* arch-dependent defines	*/
 #include <linux/sockios.h>		/* the SIOCxxx I/O controls	*/
@@ -101,6 +101,21 @@ struct cmsghdr {
 			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
 
 /*
+ *	This mess will go away with glibc
+ */
+ 
+#ifdef __KERNEL__
+#define __KINLINE static inline
+#elif  defined(__GNUC__) 
+#define __KINLINE static __inline__
+#elif defined(__cplusplus)
+#define __KINLINE static inline
+#else
+#define __KINLINE static
+#endif
+
+
+/*
  *	Get the next cmsg header
  *
  *	PLEASE, do not touch this function. If you think, that it is
@@ -113,7 +128,7 @@ struct cmsghdr {
  *	ancillary object DATA.				--ANK (980731)
  */
  
-static inline struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __size,
+__KINLINE struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __size,
 					       struct cmsghdr *__cmsg)
 {
 	struct cmsghdr * __ptr;
@@ -125,7 +140,7 @@ static inline struct cmsghdr * __cmsg_nxthdr(void *__ctl, __kernel_size_t __size
 	return __ptr;
 }
 
-static inline struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr *__cmsg)
+__KINLINE struct cmsghdr * cmsg_nxthdr (struct msghdr *__msg, struct cmsghdr *__cmsg)
 {
 	return __cmsg_nxthdr(__msg->msg_control, __msg->msg_controllen, __cmsg);
 }
-- 
1.6.5.2


