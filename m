From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 1/7] batman-adv: Avoid nullptr dereference in bla after vlan_insert_tag
Date: Fri,  8 Jul 2016 11:49:16 +0200
Message-ID: <1467971362-3607-2-git-send-email-sw@simonwunderlich.de>
References: <1467971362-3607-1-git-send-email-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:37086 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbcGHJte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 05:49:34 -0400
In-Reply-To: <1467971362-3607-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

vlan_insert_tag can return NULL on errors. The bridge loop avoidance code
therefore has to check the return value of vlan_insert_tag for NULL before
it can safely operate on this pointer.

Fixes: 23721387c409 ("batman-adv: add basic bridge loop avoidance code")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 748a9ea..7129780 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -418,9 +418,12 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, u8 *mac,
 		break;
 	}
 
-	if (vid & BATADV_VLAN_HAS_TAG)
+	if (vid & BATADV_VLAN_HAS_TAG) {
 		skb = vlan_insert_tag(skb, htons(ETH_P_8021Q),
 				      vid & VLAN_VID_MASK);
+		if (!skb)
+			goto out;
+	}
 
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, soft_iface);
-- 
2.8.1
