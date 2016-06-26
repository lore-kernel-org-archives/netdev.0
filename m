From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH net 5/5] batman-adv: Clean up untagged vlan when destroying via rtnl-link
Date: Sun, 26 Jun 2016 11:16:13 +0200
Message-ID: <1466932573-23105-5-git-send-email-sven@narfation.org>
References: <10049349.EHEiaYmtBd@sven-edge>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40209 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbcFZJQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2016 05:16:36 -0400
In-Reply-To: <10049349.EHEiaYmtBd@sven-edge>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The untagged vlan object is only destroyed when the interface is removed
via the legacy sysfs interface. But it also has to be destroyed when the
standard rtnl-link interface is used.

Fixes: 5d2c05b21337 ("batman-adv: add per VLAN interface attribute framework")
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 343d2c9..287a387 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -1033,7 +1033,9 @@ void batadv_softif_destroy_sysfs(struct net_device *soft_iface)
 static void batadv_softif_destroy_netlink(struct net_device *soft_iface,
 					  struct list_head *head)
 {
+	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_hard_iface *hard_iface;
+	struct batadv_softif_vlan *vlan;
 
 	list_for_each_entry(hard_iface, &batadv_hardif_list, list) {
 		if (hard_iface->soft_iface == soft_iface)
@@ -1041,6 +1043,13 @@ static void batadv_softif_destroy_netlink(struct net_device *soft_iface,
 							BATADV_IF_CLEANUP_KEEP);
 	}
 
+	/* destroy the "untagged" VLAN */
+	vlan = batadv_softif_vlan_get(bat_priv, BATADV_NO_FLAGS);
+	if (vlan) {
+		batadv_softif_destroy_vlan(bat_priv, vlan);
+		batadv_softif_vlan_put(vlan);
+	}
+
 	batadv_sysfs_del_meshif(soft_iface);
 	unregister_netdevice_queue(soft_iface, head);
 }
-- 
2.8.1
