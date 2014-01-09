From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/13] batman-adv: mark a local client as isolated when needed
Date: Thu,  9 Jan 2014 15:52:58 +0100
Message-ID: <1389279182-3256-10-git-send-email-antonio@meshcoding.com>
References: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22473 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbaAIOyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 09:54:50 -0500
In-Reply-To: <1389279182-3256-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

A client sending packets which mark matches the value
configured via sysfs has to be identified as isolated using
the TT_CLIENT_ISOLA flag.

The match is mask based, meaning that only bits set in the
mask are compared with those in the mark value.

If the configured mask is equal to 0 no operation is
performed.

Such flag is then advertised within the classic client
announcement mechanism.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/main.h              |  2 ++
 net/batman-adv/packet.h            |  1 +
 net/batman-adv/soft-interface.c    |  7 ++++---
 net/batman-adv/translation-table.c | 16 +++++++++++++++-
 net/batman-adv/translation-table.h |  2 +-
 5 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 9e76b6c..fa9edbf 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -70,6 +70,8 @@
 
 #define BATADV_NULL_IFINDEX 0 /* dummy ifindex used to avoid iface checks */
 
+#define BATADV_NO_MARK 0
+
 #define BATADV_NUM_WORDS BITS_TO_LONGS(BATADV_TQ_LOCAL_WINDOW_SIZE)
 
 #define BATADV_LOG_BUF_LEN 8192	  /* has to be a power of 2 */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 5e73294..ef2010c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -115,6 +115,7 @@ enum batadv_tt_client_flags {
 	BATADV_TT_CLIENT_DEL     = BIT(0),
 	BATADV_TT_CLIENT_ROAM    = BIT(1),
 	BATADV_TT_CLIENT_WIFI    = BIT(4),
+	BATADV_TT_CLIENT_ISOLA	 = BIT(5),
 	BATADV_TT_CLIENT_NOPURGE = BIT(8),
 	BATADV_TT_CLIENT_NEW     = BIT(9),
 	BATADV_TT_CLIENT_PENDING = BIT(10),
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 35a82e3..e126d74 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -119,7 +119,7 @@ static int batadv_interface_set_mac_addr(struct net_device *dev, void *p)
 		batadv_tt_local_remove(bat_priv, old_addr, BATADV_NO_FLAGS,
 				       "mac address changed", false);
 		batadv_tt_local_add(dev, addr->sa_data, BATADV_NO_FLAGS,
-				    BATADV_NULL_IFINDEX);
+				    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
 	}
 
 	return 0;
@@ -199,7 +199,8 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	/* Register the client MAC in the transtable */
 	if (!is_multicast_ether_addr(ethhdr->h_source)) {
 		client_added = batadv_tt_local_add(soft_iface, ethhdr->h_source,
-						   vid, skb->skb_iif);
+						   vid, skb->skb_iif,
+						   skb->mark);
 		if (!client_added)
 			goto dropped;
 	}
@@ -489,7 +490,7 @@ int batadv_softif_create_vlan(struct batadv_priv *bat_priv, unsigned short vid)
 	 */
 	batadv_tt_local_add(bat_priv->soft_iface,
 			    bat_priv->soft_iface->dev_addr, vid,
-			    BATADV_NULL_IFINDEX);
+			    BATADV_NULL_IFINDEX, BATADV_NO_MARK);
 
 	spin_lock_bh(&bat_priv->softif_vlan_list_lock);
 	hlist_add_head_rcu(&vlan->list, &bat_priv->softif_vlan_list);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 2eaa1e9..669b8b6 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -474,11 +474,13 @@ static void batadv_tt_global_free(struct batadv_priv *bat_priv,
  * @vid: VLAN identifier
  * @ifindex: index of the interface where the client is connected to (useful to
  *  identify wireless clients)
+ * @mark: the value contained in the skb->mark field of the received packet (if
+ *  any)
  *
  * Returns true if the client was successfully added, false otherwise.
  */
 bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
-			 unsigned short vid, int ifindex)
+			 unsigned short vid, int ifindex, uint32_t mark)
 {
 	struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	struct batadv_tt_local_entry *tt_local;
@@ -489,6 +491,7 @@ bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 	int hash_added, table_size, packet_size_max;
 	bool ret = false, roamed_back = false;
 	uint8_t remote_flags;
+	uint32_t match_mark;
 
 	if (ifindex != BATADV_NULL_IFINDEX)
 		in_dev = dev_get_by_index(&init_net, ifindex);
@@ -613,6 +616,17 @@ check_roaming:
 	else
 		tt_local->common.flags &= ~BATADV_TT_CLIENT_WIFI;
 
+	/* check the mark in the skb: if it's equal to the configured
+	 * isolation_mark, it means the packet is coming from an isolated
+	 * non-mesh client
+	 */
+	match_mark = (mark & bat_priv->isolation_mark_mask);
+	if (bat_priv->isolation_mark_mask &&
+	    match_mark == bat_priv->isolation_mark)
+		tt_local->common.flags |= BATADV_TT_CLIENT_ISOLA;
+	else
+		tt_local->common.flags &= ~BATADV_TT_CLIENT_ISOLA;
+
 	/* if any "dynamic" flag has been modified, resend an ADD event for this
 	 * entry so that all the nodes can get the new flags
 	 */
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 08d9bbe..0e7023e 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -20,7 +20,7 @@
 
 int batadv_tt_init(struct batadv_priv *bat_priv);
 bool batadv_tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
-			 unsigned short vid, int ifindex);
+			 unsigned short vid, int ifindex, uint32_t mark);
 uint16_t batadv_tt_local_remove(struct batadv_priv *bat_priv,
 				const uint8_t *addr, unsigned short vid,
 				const char *message, bool roaming);
-- 
1.8.5.2
