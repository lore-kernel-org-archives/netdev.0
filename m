From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 1/2] net: fix compat_sys_recvmmsg parameter type
Date: Thu, 10 Dec 2009 07:58:16 +0100
Message-ID: <20091210065815.GA4144@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:48219 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbZLJG6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 01:58:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

compat_sys_recvmmsg has a compat_timespec parameter and not a
timespec parameter. This way we also get rid of an odd cast.

Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 include/net/compat.h |    2 +-
 net/compat.c         |   12 +++++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

Index: linux-2.6/include/net/compat.h
===================================================================
--- linux-2.6.orig/include/net/compat.h
+++ linux-2.6/include/net/compat.h
@@ -46,7 +46,7 @@ extern asmlinkage long compat_sys_sendms
 extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr __user *,unsigned);
 extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghdr __user *,
 					   unsigned, unsigned,
-					   struct timespec __user *);
+					   struct compat_timespec __user *);
 extern asmlinkage long compat_sys_getsockopt(int, int, int, char __user *, int __user *);
 extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
 
Index: linux-2.6/net/compat.c
===================================================================
--- linux-2.6.orig/net/compat.c
+++ linux-2.6/net/compat.c
@@ -754,26 +754,24 @@ asmlinkage long compat_sys_recvfrom(int 
 
 asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __user *mmsg,
 				    unsigned vlen, unsigned int flags,
-				    struct timespec __user *timeout)
+				    struct compat_timespec __user *timeout)
 {
 	int datagrams;
 	struct timespec ktspec;
-	struct compat_timespec __user *utspec;
 
 	if (timeout == NULL)
 		return __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 				      flags | MSG_CMSG_COMPAT, NULL);
 
-	utspec = (struct compat_timespec __user *)timeout;
-	if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
-	    get_user(ktspec.tv_nsec, &utspec->tv_nsec))
+	if (get_user(ktspec.tv_sec, &timeout->tv_sec) ||
+	    get_user(ktspec.tv_nsec, &timeout->tv_nsec))
 		return -EFAULT;
 
 	datagrams = __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 				   flags | MSG_CMSG_COMPAT, &ktspec);
 	if (datagrams > 0 &&
-	    (put_user(ktspec.tv_sec, &utspec->tv_sec) ||
-	     put_user(ktspec.tv_nsec, &utspec->tv_nsec)))
+	    (put_user(ktspec.tv_sec, &timeout->tv_sec) ||
+	     put_user(ktspec.tv_nsec, &timeout->tv_nsec)))
 		datagrams = -EFAULT;
 
 	return datagrams;
