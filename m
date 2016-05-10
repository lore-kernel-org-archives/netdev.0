From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 10/17] batman-adv: Use kref_get for batadv_nc_get_nc_node
Date: Wed, 11 May 2016 03:29:58 +0800
Message-ID: <1462908605-27412-11-git-send-email-a@unstable.cc>
References: <1462908605-27412-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:8879 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbcEJTjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:39:15 -0400
In-Reply-To: <1462908605-27412-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_nc_get_nc_node requires that the caller already has a valid
reference for orig_neigh_node. It is therefore not possible that it has an
reference counter of 0 and was still given to this function

The kref_get function instead WARNs (with debug information) when the
reference counter would still be 0. This makes a bug in batman-adv better
visible because kref_get_unless_zero would have ignored this problem.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/network-coding.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
index 1da8e0e1b18f..953dff1ad43b 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -856,8 +856,7 @@ batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
 	if (!nc_node)
 		return NULL;
 
-	if (!kref_get_unless_zero(&orig_neigh_node->refcount))
-		goto free;
+	kref_get(&orig_neigh_node->refcount);
 
 	/* Initialize nc_node */
 	INIT_LIST_HEAD(&nc_node->list);
@@ -884,10 +883,6 @@ batadv_nc_get_nc_node(struct batadv_priv *bat_priv,
 	spin_unlock_bh(lock);
 
 	return nc_node;
-
-free:
-	kfree(nc_node);
-	return NULL;
 }
 
 /**
-- 
2.8.2
