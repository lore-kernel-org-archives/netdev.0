From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 13/20] batman-adv: Place kref_get for hard_iface near use
Date: Mon, 22 Aug 2016 15:56:13 +0200
Message-ID: <20160822135620.15337-14-sw@simonwunderlich.de>
References: <20160822135620.15337-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:39002 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755478AbcHVN55 (ORCPT
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
 net/batman-adv/hard-interface.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 43c9a3e..9284c73 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -694,6 +694,7 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 	INIT_HLIST_HEAD(&hard_iface->neigh_list);
 
 	spin_lock_init(&hard_iface->neigh_list_lock);
+	kref_init(&hard_iface->refcount);
 
 	hard_iface->num_bcasts = BATADV_NUM_BCASTS_DEFAULT;
 	if (batadv_is_wifi_netdev(net_dev))
@@ -701,11 +702,8 @@ batadv_hardif_add_interface(struct net_device *net_dev)
 
 	batadv_v_hardif_init(hard_iface);
 
-	/* extra reference for return */
-	kref_init(&hard_iface->refcount);
-	kref_get(&hard_iface->refcount);
-
 	batadv_check_known_mac_addr(hard_iface->net_dev);
+	kref_get(&hard_iface->refcount);
 	list_add_tail_rcu(&hard_iface->list, &batadv_hardif_list);
 
 	return hard_iface;
-- 
2.9.3
