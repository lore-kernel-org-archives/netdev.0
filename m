From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 12/16] batman-adv: consider network coding overhead when calculating required mtu
Date: Sun, 13 Oct 2013 13:22:57 +0200
Message-ID: <1381663381-626-13-git-send-email-antonio@meshcoding.com>
References: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:39468 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab3JMLtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 07:49:43 -0400
In-Reply-To: <1381663381-626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The module prints a warning when the MTU on the hard interface is too
small to transfer payload traffic without fragmentation. The required
MTU is calculated based on the encapsulation header size. If network
coding is compild into the module its header size is taken into
account as well.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/hard-interface.c | 19 ++++++++++---------
 net/batman-adv/main.c           | 25 +++++++++++++++++++++++++
 net/batman-adv/main.h           |  1 +
 net/batman-adv/soft-interface.c |  2 +-
 net/batman-adv/types.h          |  7 -------
 5 files changed, 37 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 004017c..d564af2 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -269,9 +269,10 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 	const struct batadv_priv *bat_priv = netdev_priv(soft_iface);
 	const struct batadv_hard_iface *hard_iface;
 	/* allow big frames if all devices are capable to do so
-	 * (have MTU > 1500 + BAT_HEADER_LEN)
+	 * (have MTU > 1500 + batadv_max_header_len())
 	 */
 	int min_mtu = ETH_DATA_LEN;
+	int max_header_len = batadv_max_header_len();
 
 	if (atomic_read(&bat_priv->fragmentation))
 		goto out;
@@ -285,8 +286,7 @@ int batadv_hardif_min_mtu(struct net_device *soft_iface)
 		if (hard_iface->soft_iface != soft_iface)
 			continue;
 
-		min_mtu = min_t(int,
-				hard_iface->net_dev->mtu - BATADV_HEADER_LEN,
+		min_mtu = min_t(int, hard_iface->net_dev->mtu - max_header_len,
 				min_mtu);
 	}
 	rcu_read_unlock();
@@ -380,6 +380,7 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 	struct batadv_priv *bat_priv;
 	struct net_device *soft_iface, *master;
 	__be16 ethertype = htons(ETH_P_BATMAN);
+	int max_header_len = batadv_max_header_len();
 	int ret;
 
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
@@ -448,18 +449,18 @@ int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 		    hard_iface->net_dev->name);
 
 	if (atomic_read(&bat_priv->fragmentation) &&
-	    hard_iface->net_dev->mtu < ETH_DATA_LEN + BATADV_HEADER_LEN)
+	    hard_iface->net_dev->mtu < ETH_DATA_LEN + max_header_len)
 		batadv_info(hard_iface->soft_iface,
-			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %zi would solve the problem.\n",
+			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. Packets going over this interface will be fragmented on layer2 which could impact the performance. Setting the MTU to %i would solve the problem.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			    ETH_DATA_LEN + BATADV_HEADER_LEN);
+			    ETH_DATA_LEN + max_header_len);
 
 	if (!atomic_read(&bat_priv->fragmentation) &&
-	    hard_iface->net_dev->mtu < ETH_DATA_LEN + BATADV_HEADER_LEN)
+	    hard_iface->net_dev->mtu < ETH_DATA_LEN + max_header_len)
 		batadv_info(hard_iface->soft_iface,
-			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %zi.\n",
+			    "The MTU of interface %s is too small (%i) to handle the transport of batman-adv packets. If you experience problems getting traffic through try increasing the MTU to %i.\n",
 			    hard_iface->net_dev->name, hard_iface->net_dev->mtu,
-			    ETH_DATA_LEN + BATADV_HEADER_LEN);
+			    ETH_DATA_LEN + max_header_len);
 
 	if (batadv_hardif_is_iface_up(hard_iface))
 		batadv_hardif_activate_interface(hard_iface);
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 519138e..7f3a5c4 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -256,6 +256,31 @@ out:
 }
 
 /**
+ * batadv_max_header_len - calculate maximum encapsulation overhead for a
+ *  payload packet
+ *
+ * Return the maximum encapsulation overhead in bytes.
+ */
+int batadv_max_header_len(void)
+{
+	int header_len = 0;
+
+	header_len = max_t(int, header_len,
+			   sizeof(struct batadv_unicast_packet));
+	header_len = max_t(int, header_len,
+			   sizeof(struct batadv_unicast_4addr_packet));
+	header_len = max_t(int, header_len,
+			   sizeof(struct batadv_bcast_packet));
+
+#ifdef CONFIG_BATMAN_ADV_NC
+	header_len = max_t(int, header_len,
+			   sizeof(struct batadv_coded_packet));
+#endif
+
+	return header_len;
+}
+
+/**
  * batadv_skb_set_priority - sets skb priority according to packet content
  * @skb: the packet to be sent
  * @offset: offset to the packet content
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 6a74a42..54c13d5 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -191,6 +191,7 @@ void batadv_mesh_free(struct net_device *soft_iface);
 int batadv_is_my_mac(struct batadv_priv *bat_priv, const uint8_t *addr);
 struct batadv_hard_iface *
 batadv_seq_print_text_primary_if_get(struct seq_file *seq);
+int batadv_max_header_len(void);
 void batadv_skb_set_priority(struct sk_buff *skb, int offset);
 int batadv_batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 			   struct packet_type *ptype,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 87e7e4e..15c7237 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -626,7 +626,7 @@ static void batadv_softif_init_early(struct net_device *dev)
 	 */
 	dev->mtu = ETH_DATA_LEN;
 	/* reserve more space in the skbuff for our header */
-	dev->hard_header_len = BATADV_HEADER_LEN;
+	dev->hard_header_len = batadv_max_header_len();
 
 	/* generate random address */
 	eth_hw_addr_random(dev);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d517d5d..5cbb0d0 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -24,13 +24,6 @@
 #include "bitarray.h"
 #include <linux/kernel.h>
 
-/**
- * Maximum overhead for the encapsulation for a payload packet
- */
-#define BATADV_HEADER_LEN \
-	(ETH_HLEN + max(sizeof(struct batadv_unicast_packet), \
-			sizeof(struct batadv_bcast_packet)))
-
 #ifdef CONFIG_BATMAN_ADV_DAT
 
 /* batadv_dat_addr_t is the type used for all DHT addresses. If it is changed,
-- 
1.8.3.2
