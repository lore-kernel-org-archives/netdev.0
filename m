From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 10/10] l2tp: let iproute2 create L2TPv3 IP tunnels using IPv6
Date: Fri, 20 Apr 2012 10:02:53 +0100
Message-ID: <1334912573-28804-11-git-send-email-jchapman@katalix.com>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:58757 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475Ab2DTJDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2012 05:03:00 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink API lets users create unmanaged L2TPv3 tunnels using
iproute2. Until now, a request to create an unmanaged L2TPv3 IP
encapsulation tunnel over IPv6 would be rejected with
EPROTONOSUPPORT. Now that l2tp_ip6 implements sockets for L2TP IP
encapsulation over IPv6, we can add support for that tunnel type.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   72 ++++++++++++++++++++++++++++++++++---------------
 1 files changed, 50 insertions(+), 22 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 5a7d908..7415620 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1367,6 +1367,7 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 	struct sockaddr_in udp_addr;
 #if IS_ENABLED(CONFIG_IPV6)
 	struct sockaddr_in6 udp6_addr;
+	struct sockaddr_l2tpip6 ip6_addr;
 #endif
 	struct sockaddr_l2tpip ip_addr;
 	struct socket *sock = NULL;
@@ -1436,32 +1437,59 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 	case L2TP_ENCAPTYPE_IP:
 #if IS_ENABLED(CONFIG_IPV6)
 		if (cfg->local_ip6 && cfg->peer_ip6) {
-			/* IP encap over IPv6 not yet supported */
-			err = -EPROTONOSUPPORT;
-			goto out;
-		}
-#endif
-		err = sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP, sockp);
-		if (err < 0)
-			goto out;
+			err = sock_create(AF_INET6, SOCK_DGRAM, IPPROTO_L2TP,
+					  sockp);
+			if (err < 0)
+				goto out;
 
-		sock = *sockp;
+			sock = *sockp;
 
-		memset(&ip_addr, 0, sizeof(ip_addr));
-		ip_addr.l2tp_family = AF_INET;
-		ip_addr.l2tp_addr = cfg->local_ip;
-		ip_addr.l2tp_conn_id = tunnel_id;
-		err = kernel_bind(sock, (struct sockaddr *) &ip_addr, sizeof(ip_addr));
-		if (err < 0)
-			goto out;
+			memset(&ip6_addr, 0, sizeof(ip6_addr));
+			ip6_addr.l2tp_family = AF_INET6;
+			memcpy(&ip6_addr.l2tp_addr, cfg->local_ip6,
+			       sizeof(ip6_addr.l2tp_addr));
+			ip6_addr.l2tp_conn_id = tunnel_id;
+			err = kernel_bind(sock, (struct sockaddr *) &ip6_addr,
+					  sizeof(ip6_addr));
+			if (err < 0)
+				goto out;
 
-		ip_addr.l2tp_family = AF_INET;
-		ip_addr.l2tp_addr = cfg->peer_ip;
-		ip_addr.l2tp_conn_id = peer_tunnel_id;
-		err = kernel_connect(sock, (struct sockaddr *) &ip_addr, sizeof(ip_addr), 0);
-		if (err < 0)
-			goto out;
+			ip6_addr.l2tp_family = AF_INET6;
+			memcpy(&ip6_addr.l2tp_addr, cfg->peer_ip6,
+			       sizeof(ip6_addr.l2tp_addr));
+			ip6_addr.l2tp_conn_id = peer_tunnel_id;
+			err = kernel_connect(sock,
+					     (struct sockaddr *) &ip6_addr,
+					     sizeof(ip6_addr), 0);
+			if (err < 0)
+				goto out;
+		} else
+#endif
+		{
+			err = sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP,
+					  sockp);
+			if (err < 0)
+				goto out;
 
+			sock = *sockp;
+
+			memset(&ip_addr, 0, sizeof(ip_addr));
+			ip_addr.l2tp_family = AF_INET;
+			ip_addr.l2tp_addr = cfg->local_ip;
+			ip_addr.l2tp_conn_id = tunnel_id;
+			err = kernel_bind(sock, (struct sockaddr *) &ip_addr,
+					  sizeof(ip_addr));
+			if (err < 0)
+				goto out;
+
+			ip_addr.l2tp_family = AF_INET;
+			ip_addr.l2tp_addr = cfg->peer_ip;
+			ip_addr.l2tp_conn_id = peer_tunnel_id;
+			err = kernel_connect(sock, (struct sockaddr *) &ip_addr,
+					     sizeof(ip_addr), 0);
+			if (err < 0)
+				goto out;
+		}
 		break;
 
 	default:
-- 
1.7.0.4
