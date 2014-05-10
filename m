From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/4] batman-adv: fix removing neigh_ifinfo
Date: Sat, 10 May 2014 17:35:10 +0200
Message-ID: <1399736110-22333-5-git-send-email-antonio@meshcoding.com>
References: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:6330 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaEJPgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 11:36:33 -0400
In-Reply-To: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

When an interface is removed separately, all neighbors need to be
checked if they have a neigh_ifinfo structure for that particular
interface. If that is the case, remove that ifinfo so any references to
a hard interface can be freed.

This is a regression introduced by
89652331c00f43574515059ecbf262d26d885717
("batman-adv: split tq information in neigh_node struct")

Reported-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c | 46 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8104c3c..427c07d 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -707,6 +707,47 @@ free_orig_node:
 }
 
 /**
+ * batadv_purge_neigh_ifinfo - purge obsolete ifinfo entries from neighbor
+ * @bat_priv: the bat priv with all the soft interface information
+ * @neigh_node: orig node which is to be checked
+ */
+static void
+batadv_purge_neigh_ifinfo(struct batadv_priv *bat_priv,
+			  struct batadv_neigh_node *neigh)
+{
+	struct batadv_neigh_ifinfo *neigh_ifinfo;
+	struct batadv_hard_iface *if_outgoing;
+	struct hlist_node *node_tmp;
+
+	spin_lock_bh(&neigh->ifinfo_lock);
+
+	/* for all ifinfo objects for this neighinator */
+	hlist_for_each_entry_safe(neigh_ifinfo, node_tmp,
+				  &neigh->ifinfo_list, list) {
+		if_outgoing = neigh_ifinfo->if_outgoing;
+
+		/* always keep the default interface */
+		if (if_outgoing == BATADV_IF_DEFAULT)
+			continue;
+
+		/* don't purge if the interface is not (going) down */
+		if ((if_outgoing->if_status != BATADV_IF_INACTIVE) &&
+		    (if_outgoing->if_status != BATADV_IF_NOT_IN_USE) &&
+		    (if_outgoing->if_status != BATADV_IF_TO_BE_REMOVED))
+			continue;
+
+		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+			   "neighbor/ifinfo purge: neighbor %pM, iface: %s\n",
+			   neigh->addr, if_outgoing->net_dev->name);
+
+		hlist_del_rcu(&neigh_ifinfo->list);
+		batadv_neigh_ifinfo_free_ref(neigh_ifinfo);
+	}
+
+	spin_unlock_bh(&neigh->ifinfo_lock);
+}
+
+/**
  * batadv_purge_orig_ifinfo - purge obsolete ifinfo entries from originator
  * @bat_priv: the bat priv with all the soft interface information
  * @orig_node: orig node which is to be checked
@@ -805,6 +846,11 @@ batadv_purge_orig_neighbors(struct batadv_priv *bat_priv,
 
 			hlist_del_rcu(&neigh_node->list);
 			batadv_neigh_node_free_ref(neigh_node);
+		} else {
+			/* only neccesary if not the whole neighbor is to be deleted,
+			 * but some interface has been removed.
+			 */
+			batadv_purge_neigh_ifinfo(bat_priv, neigh_node);
 		}
 	}
 
-- 
1.8.5.5
