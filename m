From: Eric Garver <e@erig.me>
Subject: [PATCH net-next] geneve: fix fill_info when using collect_metadata
Date: Tue, 23 May 2017 18:37:27 -0400
Message-ID: <20170523223727.15307-1-e@erig.me>
Cc: pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42366 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757598AbdEWWh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 18:37:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 9b4437a5b870 ("geneve: Unify LWT and netdev handling.") fill_info
does not return UDP_ZERO_CSUM6_RX when using COLLECT_METADATA. This is
because it uses ip_tunnel_info_af() with the device level info, which is
not valid for COLLECT_METADATA.

Fix by checking for the presence of the actual sockets.

Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
Signed-off-by: Eric Garver <e@erig.me>
---
 drivers/net/geneve.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index dec5d563ab19..959fd12d2e67 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1293,7 +1293,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_GENEVE_ID, vni))
 		goto nla_put_failure;
 
-	if (ip_tunnel_info_af(info) == AF_INET) {
+	if (rtnl_dereference(geneve->sock4)) {
 		if (nla_put_in_addr(skb, IFLA_GENEVE_REMOTE,
 				    info->key.u.ipv4.dst))
 			goto nla_put_failure;
@@ -1302,8 +1302,10 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			       !!(info->key.tun_flags & TUNNEL_CSUM)))
 			goto nla_put_failure;
 
+	}
+
 #if IS_ENABLED(CONFIG_IPV6)
-	} else {
+	if (rtnl_dereference(geneve->sock6)) {
 		if (nla_put_in6_addr(skb, IFLA_GENEVE_REMOTE6,
 				     &info->key.u.ipv6.dst))
 			goto nla_put_failure;
@@ -1315,8 +1317,8 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		if (nla_put_u8(skb, IFLA_GENEVE_UDP_ZERO_CSUM6_RX,
 			       !geneve->use_udp6_rx_checksums))
 			goto nla_put_failure;
-#endif
 	}
+#endif
 
 	if (nla_put_u8(skb, IFLA_GENEVE_TTL, info->key.ttl) ||
 	    nla_put_u8(skb, IFLA_GENEVE_TOS, info->key.tos) ||
-- 
2.12.0
