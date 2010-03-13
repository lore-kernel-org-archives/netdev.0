From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] timestamping: fix example build
Date: Fri, 12 Mar 2010 21:23:27 -0800
Message-ID: <4B9B214F.4040005@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick Ohly <patrick.ohly@intel.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:62275 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820Ab0CMFY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 00:24:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix Makefiles so that Documentation/networking/timestamping/timestamping.c
will build when using the CONFIG_BUILD_DOCSRC kconfig option.
(timestamping.c does not build currently with its simple Makefile.)

Also fix printf format warnings.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Patrick Ohly <patrick.ohly@intel.com>
---
 Documentation/networking/Makefile                    |    2 +
 Documentation/networking/timestamping/Makefile       |   11 ++++++++--
 Documentation/networking/timestamping/timestamping.c |   10 ++++-----
 3 files changed, 16 insertions(+), 7 deletions(-)

--- lnx-2634-rc1.orig/Documentation/networking/Makefile
+++ lnx-2634-rc1/Documentation/networking/Makefile
@@ -6,3 +6,5 @@ hostprogs-y := ifenslave
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
+
+obj-m := timestamping/
--- lnx-2634-rc1.orig/Documentation/networking/timestamping/Makefile
+++ lnx-2634-rc1/Documentation/networking/timestamping/Makefile
@@ -1,6 +1,13 @@
-CPPFLAGS = -I../../../include
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
 
-timestamping: timestamping.c
+# List of programs to build
+hostprogs-y := timestamping
+
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
+
+HOSTCFLAGS_timestamping.o += -I$(objtree)/usr/include
 
 clean:
 	rm -f timestamping
--- lnx-2634-rc1.orig/Documentation/networking/timestamping/timestamping.c
+++ lnx-2634-rc1/Documentation/networking/timestamping/timestamping.c
@@ -41,9 +41,9 @@
 #include <arpa/inet.h>
 #include <net/if.h>
 
-#include "asm/types.h"
-#include "linux/net_tstamp.h"
-#include "linux/errqueue.h"
+#include <asm/types.h>
+#include <linux/net_tstamp.h>
+#include <linux/errqueue.h>
 
 #ifndef SO_TIMESTAMPING
 # define SO_TIMESTAMPING         37
@@ -164,7 +164,7 @@ static void printpacket(struct msghdr *m
 
 	gettimeofday(&now, 0);
 
-	printf("%ld.%06ld: received %s data, %d bytes from %s, %d bytes control messages\n",
+	printf("%ld.%06ld: received %s data, %d bytes from %s, %zu bytes control messages\n",
 	       (long)now.tv_sec, (long)now.tv_usec,
 	       (recvmsg_flags & MSG_ERRQUEUE) ? "error" : "regular",
 	       res,
@@ -173,7 +173,7 @@ static void printpacket(struct msghdr *m
 	for (cmsg = CMSG_FIRSTHDR(msg);
 	     cmsg;
 	     cmsg = CMSG_NXTHDR(msg, cmsg)) {
-		printf("   cmsg len %d: ", cmsg->cmsg_len);
+		printf("   cmsg len %zu: ", cmsg->cmsg_len);
 		switch (cmsg->cmsg_level) {
 		case SOL_SOCKET:
 			printf("SOL_SOCKET ");
