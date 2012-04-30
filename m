From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 10/10 net-next] l2tp: let iproute2 create L2TPv3 IP tunnels using IPv6
Date: Mon, 30 Apr 2012 08:48:55 +0100
Message-ID: <1335772135-27910-11-git-send-email-jchapman@katalix.com>
References: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:53476 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab2D3HtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 03:49:01 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 68CD5A620CB
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 08:49:00 +0100 (BST)
In-Reply-To: <1335772135-27910-1-git-send-email-jchapman@katalix.com>
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
