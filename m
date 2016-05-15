From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 3/4] batman-adv: Fix double neigh_node_put in batadv_v_ogm_route_update
Date: Sun, 15 May 2016 23:11:32 +0800
Message-ID: <1463325093-3927-4-git-send-email-a__25358.1314850182$1463325212$gmane$org@unstable.cc>
References: <1463325093-3927-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:43005 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754279AbcEOPMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 11:12:45 -0400
In-Reply-To: <1463325093-3927-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The router is put down twice when it was non-NULL and either orig_ifinfo is
NULL afterwards or batman-adv receives a packet with the same sequence
number. This will end up in a use-after-free when the batadv_neigh_node is
removed because the reference counter ended up too early at 0.

Fixes: 9323158ef9f4 ("batman-adv: OGMv2 - implement originators logic")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_v_ogm.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index d9bcbe6e7d65..91df28a100f9 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -529,8 +529,10 @@ static void batadv_v_ogm_route_update(struct batadv_priv *bat_priv,
 		goto out;
 	}
 
-	if (router)
+	if (router) {
 		batadv_neigh_node_put(router);
+		router = NULL;
+	}
 
 	/* Update routes, and check if the OGM is from the best next hop */
 	batadv_v_ogm_orig_update(bat_priv, orig_node, neigh_node, ogm2,
-- 
2.8.2
