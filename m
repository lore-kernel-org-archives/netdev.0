From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/2] syncookies: enable by default
Date: Fri, 16 Oct 2009 21:51:00 +0200
Message-ID: <1255722660-12857-1-git-send-email-fw@strlen.de>
References: <1255722570-12803-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51560 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751192AbZJPTv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 15:51:59 -0400
In-Reply-To: <1255722570-12803-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change syncookie sysctl initialization to 1.

Syn cookies have no effect under normal conditions; cookies are
only sent if a sockets syn queue is exhausted (and the connection
request would be dropped with cookies disabled).

sysctl_tcp_syncookies needs to be set to 0 in the CONFIG_SYN_COOKIES=n
case, as tcp_v4_conn_request() evaluates the variable in a conditional
expression (which then would always be false).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/Kconfig         |    7 +++----
 net/ipv4/tcp_minisocks.c |    6 +++---
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 70491d9..86e5bc8 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -289,7 +289,7 @@ config ARPD
 	  If unsure, say N.
 
 config SYN_COOKIES
-	bool "IP: TCP syncookie support (disabled per default)"
+	bool "IP: TCP syncookie support"
 	---help---
 	  Normal TCP/IP networking is open to an attack known as "SYN
 	  flooding". This denial-of-service attack prevents legitimate remote
@@ -314,11 +314,10 @@ config SYN_COOKIES
 	  server is really overloaded. If this happens frequently better turn
 	  them off.
 
-	  If you say Y here, note that SYN cookies aren't enabled by default;
-	  you can enable them by saying Y to "/proc file system support" and
+	  You can disable them by saying Y to "/proc file system support" and
 	  "Sysctl support" below and executing the command
 
-	  echo 1 >/proc/sys/net/ipv4/tcp_syncookies
+	  echo 0 >/proc/sys/net/ipv4/tcp_syncookies
 
 	  at boot time after the /proc file system has been mounted.
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 624c3c9..2b0ddc2 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -26,10 +26,10 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 
-#ifdef CONFIG_SYSCTL
-#define SYNC_INIT 0 /* let the user enable it */
-#else
+#ifdef CONFIG_SYN_COOKIES
 #define SYNC_INIT 1
+#else
+#define SYNC_INIT 0 /* tcp_ipv4.c checks sysctl_tcp_syncookies even if CONFIG_SYN_COOKIES=n */
 #endif
 
 int sysctl_tcp_syncookies __read_mostly = SYNC_INIT;
-- 
1.6.3.3

