From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH] batman-adv: do_bcast has to be true for broadcast packets only
Date: Thu, 22 Sep 2011 20:57:16 +0200
Message-ID: <1316717836-19374-2-git-send-email-lindner_marek@yahoo.de>
References: <1316717836-19374-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm16-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.254]:38755
	"HELO nm16-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753529Ab1IVS5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 14:57:30 -0400
In-Reply-To: <1316717836-19374-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

corrects a critical bug of the GW feature. This bug made all the unicast
packets destined to a GW to be sent as broadcast. This bug is present even if
the sender GW feature is configured as OFF. It's an urgent bug fix and should
be committed as soon as possible.

This was a regression introduced by 43676ab590c3f8686fd047d34c3e33803eef71f0

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/soft-interface.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 3e2f91f..05dd351 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -565,7 +565,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	struct orig_node *orig_node = NULL;
 	int data_len = skb->len, ret;
 	short vid = -1;
-	bool do_bcast = false;
+	bool do_bcast;
 
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
 		goto dropped;
@@ -598,15 +598,15 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 	tt_local_add(soft_iface, ethhdr->h_source);
 
 	orig_node = transtable_search(bat_priv, ethhdr->h_dest);
-	if (is_multicast_ether_addr(ethhdr->h_dest) ||
-				(orig_node && orig_node->gw_flags)) {
+	do_bcast = is_multicast_ether_addr(ethhdr->h_dest);
+	if (do_bcast ||	(orig_node && orig_node->gw_flags)) {
 		ret = gw_is_target(bat_priv, skb, orig_node);
 
 		if (ret < 0)
 			goto dropped;
 
-		if (ret == 0)
-			do_bcast = true;
+		if (ret)
+			do_bcast = false;
 	}
 
 	/* ethernet packet should be broadcasted */
-- 
1.7.5.4
