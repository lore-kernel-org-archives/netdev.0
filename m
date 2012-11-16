From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/4] batman-adv: process broadcast packets in BLA earlier
Date: Fri, 16 Nov 2012 09:49:18 +0100
Message-ID: <1353055758-2901-5-git-send-email-ordex@autistici.org>
References: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:35023 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab2KPIu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 03:50:26 -0500
In-Reply-To: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic in the BLA mechanism may decide to drop broadcast packets
because the node may still be in the setup phase. For this reason,
further broadcast processing like the early client detection mechanism
must be done only after the BLA check.

This patches moves the invocation to BLA before any other broadcast
processing.

This was introduced 30cfd02b60e1cb16f5effb0a01f826c5bb7e4c59
("batman-adv: detect not yet announced clients")

Reported-by: Glen Page <glen.page@thet.net>
Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b9a28d2..ce0684a 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -325,6 +325,12 @@ void batadv_interface_rx(struct net_device *soft_iface,
 
 	soft_iface->last_rx = jiffies;
 
+	/* Let the bridge loop avoidance check the packet. If will
+	 * not handle it, we can safely push it up.
+	 */
+	if (batadv_bla_rx(bat_priv, skb, vid, is_bcast))
+		goto out;
+
 	if (orig_node)
 		batadv_tt_add_temporary_global_entry(bat_priv, orig_node,
 						     ethhdr->h_source);
@@ -332,12 +338,6 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest))
 		goto dropped;
 
-	/* Let the bridge loop avoidance check the packet. If will
-	 * not handle it, we can safely push it up.
-	 */
-	if (batadv_bla_rx(bat_priv, skb, vid, is_bcast))
-		goto out;
-
 	netif_rx(skb);
 	goto out;
 
-- 
1.8.0
