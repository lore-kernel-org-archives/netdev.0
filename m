From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 13/13] batman-adv: set the isolation mark in the skb if needed
Date: Thu,  9 Jan 2014 15:53:02 +0100
Message-ID: <1389279182-3256-14-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:43945 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbaAIO5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:57:03 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

If a broadcast packet is coming from a client marked as
isolated, then mark the skb using the isolation mark so
that netfilter (or any other application) can recognise
them.

The mark is written in the skb based on the mask value:
only bits set in the mask are substitued by those in the
mark value

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/soft-interface.c    | 18 ++++++++++++++++--
 net/batman-adv/translation-table.c | 26 ++++++++++++++++++++++++++
 net/batman-adv/translation-table.h |  2 ++
 3 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index e126d74..c50f643 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -399,9 +399,23 @@ void batadv_interface_rx(struct net_device *soft_iface,
 		batadv_tt_add_temporary_global_entry(bat_priv, orig_node,
 						     ethhdr->h_source, vid);
 
-	if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest,
-				  vid))
+	if (is_multicast_ether_addr(ethhdr->h_dest)) {
+		/* set the mark on broadcast packets if AP isolation is ON and
+		 * the packet is coming from an "isolated" client
+		 */
+		if (batadv_vlan_ap_isola_get(bat_priv, vid) &&
+		    batadv_tt_global_is_isolated(bat_priv, ethhdr->h_source,
+						 vid)) {
+			/* save bits in skb->mark not covered by the mask and
+			 * apply the mark on the rest
+			 */
+			skb->mark &= ~bat_priv->isolation_mark_mask;
+			skb->mark |= bat_priv->isolation_mark;
+		}
+	} else if (batadv_is_ap_isolated(bat_priv, ethhdr->h_source,
+					 ethhdr->h_dest, vid)) {
 		goto dropped;
+	}
 
 	netif_rx(skb);
 	goto out;
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 1337b69..63d2570 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3577,3 +3577,29 @@ int batadv_tt_init(struct batadv_priv *bat_priv)
 
 	return 1;
 }
+
+/**
+ * batadv_tt_global_is_isolated - check if a client is marked as isolated
+ * @bat_priv: the bat priv with all the soft interface information
+ * @addr: the mac address of the client
+ * @vid: the identifier of the VLAN where this client is connected
+ *
+ * Returns true if the client is marked with the TT_CLIENT_ISOLA flag, false
+ * otherwise
+ */
+bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
+				  const uint8_t *addr, unsigned short vid)
+{
+	struct batadv_tt_global_entry *tt;
+	bool ret;
+
+	tt = batadv_tt_global_hash_find(bat_priv, addr, vid);
+	if (!tt)
+		return false;
+
+	ret = tt->common.flags & BATADV_TT_CLIENT_ISOLA;
+
+	batadv_tt_global_entry_free_ref(tt);
+
+	return ret;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 0e7023e..daa8ab7 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -48,5 +48,7 @@ bool batadv_tt_add_temporary_global_entry(struct batadv_priv *bat_priv,
 					  struct batadv_orig_node *orig_node,
 					  const unsigned char *addr,
 					  unsigned short vid);
+bool batadv_tt_global_is_isolated(struct batadv_priv *bat_priv,
+				  const uint8_t *addr, unsigned short vid);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
-- 
1.8.5.2
