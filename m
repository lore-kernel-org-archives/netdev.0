From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH V2 net-next 2/3] net: introduce socket family constants
Date: Tue, 14 Jul 2015 14:42:34 +0200
Message-ID: <1436877755-23431-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: utz.bacher@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ursula.braun@de.ibm.com,
	ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:42500 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586AbbGNMms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 08:42:48 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 14 Jul 2015 13:42:44 +0100
In-Reply-To: <1436877755-23431-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The new socket family is assigned the next available address / protocol
family constant 41.
Implementing SO_KEEPALIVE for SMC-R requires an extra hook in net/core/sock.c.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 include/linux/socket.h |  4 +++-
 include/net/smc.h      | 13 +++++++++++++
 net/Kconfig            |  1 +
 net/Makefile           |  1 +
 net/core/sock.c        | 15 +++++++++++++--
 5 files changed, 31 insertions(+), 3 deletions(-)
 create mode 100644 include/net/smc.h

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5bf59c8..dd18d32 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -200,7 +200,8 @@ struct ucred {
 #define AF_ALG		38	/* Algorithm sockets		*/
 #define AF_NFC		39	/* NFC sockets			*/
 #define AF_VSOCK	40	/* vSockets			*/
-#define AF_MAX		41	/* For now.. */
+#define AF_SMC		41	/* smc sockets>->------->-------*/
+#define AF_MAX		42	/* For now.. */
 
 /* Protocol families, same as address families. */
 #define PF_UNSPEC	AF_UNSPEC
@@ -246,6 +247,7 @@ struct ucred {
 #define PF_ALG		AF_ALG
 #define PF_NFC		AF_NFC
 #define PF_VSOCK	AF_VSOCK
+#define PF_SMC		AF_SMC
 #define PF_MAX		AF_MAX
 
 /* Maximum queue length specifiable by listen.  */
diff --git a/include/net/smc.h b/include/net/smc.h
new file mode 100644
index 0000000..cd513ee
--- /dev/null
+++ b/include/net/smc.h
@@ -0,0 +1,13 @@
+/*
+ * SMC		Definitions for the SMC protocol.
+ *
+ * Author:	Ursula Braun <ursula.braun@de.ibm.com>
+ */
+#ifndef _SMC_H
+#define _SMC_H
+
+/* SMC socket options - disjunct with TCP socket options */
+#define SMC_KEEPALIVE		99	/* start/stop keepalives */
+
+#endif /* _SMC_H */
+
diff --git a/net/Kconfig b/net/Kconfig
index 57a7c5a..d829694 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -54,6 +54,7 @@ source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
 source "net/iucv/Kconfig"
+source "net/smc/Kconfig"
 
 config INET
 	bool "TCP/IP networking"
diff --git a/net/Makefile b/net/Makefile
index 3995613..33a5f54 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -49,6 +49,7 @@ obj-$(CONFIG_MAC80211)		+= mac80211/
 obj-$(CONFIG_TIPC)		+= tipc/
 obj-$(CONFIG_NETLABEL)		+= netlabel/
 obj-$(CONFIG_IUCV)		+= iucv/
+obj-$(CONFIG_AFSMC)		+= smc/
 obj-$(CONFIG_RFKILL)		+= rfkill/
 obj-$(CONFIG_NET_9P)		+= 9p/
 obj-$(CONFIG_CAIF)		+= caif/
diff --git a/net/core/sock.c b/net/core/sock.c
index 08f16db..5608a70 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -139,6 +139,9 @@
 
 #ifdef CONFIG_INET
 #include <net/tcp.h>
+#if IS_ENABLED(CONFIG_AFSMC)
+#include <net/smc.h>
+#endif /* CONFIG_AFSMC */
 #endif
 
 #include <net/busy_poll.h>
@@ -784,8 +787,16 @@ set_rcvbuf:
 	case SO_KEEPALIVE:
 #ifdef CONFIG_INET
 		if (sk->sk_protocol == IPPROTO_TCP &&
-		    sk->sk_type == SOCK_STREAM)
-			tcp_set_keepalive(sk, valbool);
+		    sk->sk_type == SOCK_STREAM) {
+#if IS_ENABLED(CONFIG_AFSMC)
+			if (sk->sk_family == AF_SMC)
+				sock->ops->setsockopt(sock, SOL_TCP,
+						      SMC_KEEPALIVE,
+						      optval, optlen);
+			else
+#endif
+				tcp_set_keepalive(sk, valbool);
+		}
 #endif
 		sock_valbool_flag(sk, SOCK_KEEPOPEN, valbool);
 		break;
-- 
2.3.8
