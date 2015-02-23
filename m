From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next] ip6_udp_tunnel: add scope id to udp_port_cfg
Date: Mon, 23 Feb 2015 10:35:39 +0100
Message-ID: <1424684139-22810-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:57359 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbBWJjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 04:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

The IPv6 scope id was missing, making it impossible to define
a tunnel endpoint using a linklocal address.
Add it to udp_port_cfg, aswell as a check during tunnel creation
if the address needs to be scoped.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 include/net/udp_tunnel.h  | 7 +++++--
 net/ipv6/ip6_udp_tunnel.c | 7 +++++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 1a20d33..aa642e5 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -16,7 +16,11 @@ struct udp_port_cfg {
 	union {
 		struct in_addr		local_ip;
 #if IS_ENABLED(CONFIG_IPV6)
-		struct in6_addr		local_ip6;
+		struct {
+			struct in6_addr		local_ip6;
+			__be32			scope_ip6;
+		};
+
 #endif
 	};
 
@@ -26,7 +30,6 @@ struct udp_port_cfg {
 		struct in6_addr		peer_ip6;
 #endif
 	};
-
 	__be16			local_udp_port;
 	__be16			peer_udp_port;
 	unsigned int		use_udp_checksums:1,
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
index 32d9b26..e6fad4f 100644
--- a/net/ipv6/ip6_udp_tunnel.c
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -29,6 +29,13 @@ int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
 	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
 	       sizeof(udp6_addr.sin6_addr));
 	udp6_addr.sin6_port = cfg->local_udp_port;
+	if (__ipv6_addr_needs_scope_id(__ipv6_addr_type(&cfg->local_ip6))) {
+		if (!cfg->scope_ip6) {
+			err = -EINVAL;
+			goto error;
+		}
+		udp6_addr.sin6_scope_id = cfg->scope_ip6;
+	}
 	err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
 			  sizeof(udp6_addr));
 	if (err < 0)
-- 
2.1.4
