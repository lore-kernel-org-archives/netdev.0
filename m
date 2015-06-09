From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 7/7] batman-adv: change the MAC of each VLAN upon ndo_set_mac_address
Date: Tue,  9 Jun 2015 12:50:20 +0200
Message-ID: <1433847020-1427-8-git-send-email-antonio@meshcoding.com>
References: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:42954 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932286AbbFIKwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:52:33 -0400
In-Reply-To: <1433847020-1427-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The MAC address of the soft-interface is used to initialise
the "non-purge" TT entry of each existing VLAN. Therefore
when the user invokes ndo_set_mac_address() all the
"non-purge" TT entries have to be updated, not only the one
belonging to the non-tagged network.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/soft-interface.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index a859322..c002961 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -129,6 +129,7 @@ static struct net_device_stats *batadv_interface_stats(struct net_device *dev)
 static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct batadv_priv *bat_priv = netdev_priv(dev);
+	struct batadv_softif_vlan *vlan;
 	struct sockaddr *addr = p;
 	uint8_t old_addr[ETH_ALEN];
 
@@ -139,12 +140,17 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 	ether_addr_copy(dev->dev_addr, addr->sa_data);
 
 	/* only modify transtable if it has been initialized before */
-	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_ACTIVE) {
-		batadv_tt_local_remove(bat_priv, old_addr, BATADV_NO_FLAGS,
+	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
+		return 0;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(vlan, &bat_priv->softif_vlan_list, list) {
+		batadv_tt_local_remove(bat_priv, old_addr, vlan->vid,
 				       "mac address changed", false);
-		batadv_tt_local_add(dev, addr->sa_data, BATADV_NO_FLAGS,
+		batadv_tt_local_add(dev, addr->sa_data, vlan->vid,
 				    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
 	}
+	rcu_read_unlock();
 
 	return 0;
 }
-- 
2.4.2
