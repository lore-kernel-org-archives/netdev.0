From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 13/16] batman-adv: check for more space before accessing the skb
Date: Mon, 29 Oct 2012 09:58:14 +0100
Message-ID: <1351501097-1289-14-git-send-email-ordex@autistici.org>
References: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:54133 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758201Ab2J2I7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:59:06 -0400
In-Reply-To: <1351501097-1289-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In batadv_check_unicast_ttvn() the code accesses both the unicast header and the
Ethernet header in the payload. For this reason pskb_may_pull() must be invoked
to check for the required space.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 456a0a9..46dd5b4 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -908,8 +908,12 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	bool tt_poss_change;
 	int is_old_ttvn;
 
-	/* I could need to modify it */
-	if (skb_cow(skb, sizeof(struct batadv_unicast_packet)) < 0)
+	/* check if there is enough data before accessing it */
+	if (pskb_may_pull(skb, sizeof(*unicast_packet) + ETH_HLEN) < 0)
+		return 0;
+
+	/* create a copy of the skb (in case of for re-routing) to modify it. */
+	if (skb_cow(skb, sizeof(*unicast_packet)) < 0)
 		return 0;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
-- 
1.7.12.4
