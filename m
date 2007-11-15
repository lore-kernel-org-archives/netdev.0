From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NET-2.6.25] Move sock_valbool_flag to socket.c
Date: Thu, 15 Nov 2007 12:43:51 +0300
Message-ID: <473C14D7.80008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:55621 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758775AbXKOJoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 04:44:04 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sock_valbool_flag() helper is used in setsockopt to 
set or reset some flag on the sock. This helper is required
in the net/socket.c only, so move it there.

Besides, patch two places in sys_setsockopt() that repeat
this helper functionality manually.

Since this is not a bugfix, but a trivial cleanup, I
prepared this patch against net-2.6.25, but it also
applies (with a single offset) to the latest net-2.6.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index cfb946a..80ca671 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1393,14 +1393,6 @@ extern int net_msg_warn;
 				lock_sock(sk); \
 				}
 
-static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
-{
-	if (valbool)
-		sock_set_flag(sk, bit);
-	else
-		sock_reset_flag(sk, bit);
-}
-
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 2029d09..98b243a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -419,6 +419,14 @@ out:
 	return ret;
 }
 
+static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
+{
+	if (valbool)
+		sock_set_flag(sk, bit);
+	else
+		sock_reset_flag(sk, bit);
+}
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
@@ -463,11 +471,8 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_DEBUG:
 		if (val && !capable(CAP_NET_ADMIN)) {
 			ret = -EACCES;
-		}
-		else if (valbool)
-			sock_set_flag(sk, SOCK_DBG);
-		else
-			sock_reset_flag(sk, SOCK_DBG);
+		} else
+			sock_valbool_flag(sk, SOCK_DBG, valbool);
 		break;
 	case SO_REUSEADDR:
 		sk->sk_reuse = valbool;
@@ -477,10 +482,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		ret = -ENOPROTOOPT;
 		break;
 	case SO_DONTROUTE:
-		if (valbool)
-			sock_set_flag(sk, SOCK_LOCALROUTE);
-		else
-			sock_reset_flag(sk, SOCK_LOCALROUTE);
+		sock_valbool_flag(sk, SOCK_LOCALROUTE, valbool);
 		break;
 	case SO_BROADCAST:
 		sock_valbool_flag(sk, SOCK_BROADCAST, valbool);
