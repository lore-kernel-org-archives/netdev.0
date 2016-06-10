From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v7 2/2] ethtool: use netlink socket when AF_INET not available
Date: Thu,  9 Jun 2016 17:55:44 -0700
Message-ID: <1465520144-132788-3-git-send-email-ddecotig@gmail.com>
References: <1465520144-132788-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32780 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbcFJAzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:55:55 -0400
Received: by mail-pa0-f66.google.com with SMTP id di3so3829178pab.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:55:55 -0700 (PDT)
In-Reply-To: <1465520144-132788-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

To benefit from this, kernel commit 025c68186e07 ("netlink: add support
for NIC driver ioctls") is needed.


Signed-off-by: David Decotigny <decot@googlers.com>
---
 configure.ac | 2 +-
 ethtool.c    | 7 +++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 3105415..47d2a0f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -15,7 +15,7 @@ AM_PROG_CC_C_O
 dnl Checks for libraries.
 
 dnl Checks for header files.
-AC_CHECK_HEADERS(sys/ioctl.h)
+AC_CHECK_HEADERS(sys/ioctl.h linux/netlink.h)
 
 dnl Checks for typedefs, structures, and compiler characteristics.
 AC_MSG_CHECKING([whether <linux/types.h> defines big-endian types])
diff --git a/ethtool.c b/ethtool.c
index cb3d971..314b1b8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -42,6 +42,9 @@
 #include <arpa/inet.h>
 
 #include <linux/sockios.h>
+#ifdef HAVE_LINUX_NETLINK_H
+# include <linux/netlink.h>
+#endif
 
 #ifndef MAX_ADDR_LEN
 #define MAX_ADDR_LEN	32
@@ -4645,6 +4648,10 @@ opt_found:
 
 		/* Open control socket. */
 		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
+#ifdef HAVE_LINUX_NETLINK_H
+		if (ctx.fd < 0)
+			ctx.fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
+#endif
 		if (ctx.fd < 0) {
 			perror("Cannot get control socket");
 			return 70;
-- 
2.8.0.rc3.226.g39d4020
