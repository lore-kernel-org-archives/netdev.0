From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 14/20] batman-adv: Place kref_get for softif_vlan near use
Date: Mon, 22 Aug 2016 15:56:14 +0200
Message-ID: <20160822135620.15337-15-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:39003 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755476AbcHVN55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 09:57:57 -0400
In-Reply-To: <20160822135620.15337-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

It is hard to understand why the refcnt is increased when it isn't done
near the actual place the new reference is used. So using kref_get right
before the place which requires the reference and in the same function
helps to avoid accidental problems caused by incorrect reference counting.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e508bf5..49e16b6 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -594,6 +594,7 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 	}
 
 	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
+	kref_get(&vlan->refcount);
 	hlist_add_head_rcu(&vlan->list, &bat_priv->softif_vlan_list);
 	spin_unlock_bh(&bat_priv->softif_vlan_list_lock);
 
@@ -604,6 +605,9 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 			    bat_priv->soft_iface->dev_addr, vid,
 			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
 
+	/* don't return reference to new softif_vlan */
+	batadv_softif_vlan_put(vlan);
+
 	return 0;
 }
 
-- 
2.9.3
