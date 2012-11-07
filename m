From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/12] batman-adv: Distributed ARP Table - add snooping functions for ARP messages
Date: Wed,  7 Nov 2012 20:11:38 +0100
Message-ID: <1352315502-20324-9-git-send-email-ordex@autistici.org>
References: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:44661 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab2KGTMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:12:36 -0500
In-Reply-To: <1352315502-20324-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of an ARP message going in or out the soft_iface, it is intercepted and
a special action is performed. In particular the DHT helper functions previously
implemented are used to store all the ARP entries belonging to the network in
order to provide a fast and unicast lookup instead of the classic broadcast
flooding mechanism.
Each node stores the entries it is responsible for (following the DHT rules) in
its soft_iface ARP table. This makes it possible to reuse the kernel data
structures and functions for ARP management.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 265 +++++++++++++++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |  11 ++
 net/batman-adv/main.h                  |   2 +
 net/batman-adv/routing.c               |  29 +++-
 net/batman-adv/send.c                  |   4 +
 net/batman-adv/soft-interface.c        |  16 +-
 6 files changed, 325 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 49a213c..f43bf8e 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -19,6 +19,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
+#include <net/arp.h>
 
 #include "main.h"
 #include "hash.h"
@@ -27,6 +28,7 @@
 #include "originator.h"
 #include "send.h"
 #include "types.h"
+#include "translation-table.h"
 #include "unicast.h"
 
 static void batadv_dat_purge(struct work_struct *work);
@@ -766,3 +768,266 @@ static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
 out:
 	return type;
 }
+
+/**
+ * batadv_dat_snoop_outgoing_arp_request - snoop the ARP request and try to
+ * answer using DAT
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: packet to check
+ *
+ * Returns true if the message has been sent to the dht candidates, false
+ * otherwise. In case of true the message has to be enqueued to permit the
+ * fallback
+ */
+bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
+					   struct sk_buff *skb)
+{
+	uint16_t type = 0;
+	__be32 ip_dst, ip_src;
+	uint8_t *hw_src;
+	bool ret = false;
+	struct batadv_dat_entry *dat_entry = NULL;
+	struct sk_buff *skb_new;
+	struct batadv_hard_iface *primary_if = NULL;
+
+	type = batadv_arp_get_type(bat_priv, skb, 0);
+	/* If the node gets an ARP_REQUEST it has to send a DHT_GET unicast
+	 * message to the selected DHT candidates
+	 */
+	if (type != ARPOP_REQUEST)
+		goto out;
+
+	batadv_dbg_arp(bat_priv, skb, type, 0, "Parsing outgoing ARP REQUEST");
+
+	ip_src = batadv_arp_ip_src(skb, 0);
+	hw_src = batadv_arp_hw_src(skb, 0);
+	ip_dst = batadv_arp_ip_dst(skb, 0);
+
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	if (dat_entry) {
+		primary_if = batadv_primary_if_get_selected(bat_priv);
+		if (!primary_if)
+			goto out;
+
+		skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
+				     primary_if->soft_iface, ip_dst, hw_src,
+				     dat_entry->mac_addr, hw_src);
+		if (!skb_new)
+			goto out;
+
+		skb_reset_mac_header(skb_new);
+		skb_new->protocol = eth_type_trans(skb_new,
+						   primary_if->soft_iface);
+		bat_priv->stats.rx_packets++;
+		bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
+		primary_if->soft_iface->last_rx = jiffies;
+
+		netif_rx(skb_new);
+		batadv_dbg(BATADV_DBG_DAT, bat_priv, "ARP request replied locally\n");
+		ret = true;
+	} else {
+		/* Send the request on the DHT */
+		ret = batadv_dat_send_data(bat_priv, skb, ip_dst,
+					   BATADV_P_DAT_DHT_GET);
+	}
+out:
+	if (dat_entry)
+		batadv_dat_entry_free_ref(dat_entry);
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	return ret;
+}
+
+/**
+ * batadv_dat_snoop_incoming_arp_request - snoop the ARP request and try to
+ * answer using the local DAT storage
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: packet to check
+ * @hdr_size: size of the encapsulation header
+ *
+ * Returns true if the request has been answered, false otherwise
+ */
+bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
+					   struct sk_buff *skb, int hdr_size)
+{
+	uint16_t type;
+	__be32 ip_src, ip_dst;
+	uint8_t *hw_src;
+	struct sk_buff *skb_new;
+	struct batadv_hard_iface *primary_if = NULL;
+	struct batadv_dat_entry *dat_entry = NULL;
+	bool ret = false;
+	int err;
+
+	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
+	if (type != ARPOP_REQUEST)
+		goto out;
+
+	hw_src = batadv_arp_hw_src(skb, hdr_size);
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
+
+	batadv_dbg_arp(bat_priv, skb, type, hdr_size,
+		       "Parsing incoming ARP REQUEST");
+
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	if (!dat_entry)
+		goto out;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		goto out;
+
+	skb_new = arp_create(ARPOP_REPLY, ETH_P_ARP, ip_src,
+			     primary_if->soft_iface, ip_dst, hw_src,
+			     dat_entry->mac_addr, hw_src);
+
+	if (!skb_new)
+		goto out;
+
+	/* to preserve backwards compatibility, here the node has to answer
+	 * using the same packet type it received for the request. This is due
+	 * to that if a node is not using the 4addr packet format it may not
+	 * support it.
+	 */
+	if (hdr_size == sizeof(struct batadv_unicast_4addr_packet))
+		err = batadv_unicast_4addr_send_skb(bat_priv, skb_new,
+						    BATADV_P_DAT_CACHE_REPLY);
+	else
+		err = batadv_unicast_send_skb(bat_priv, skb_new);
+
+	if (!err)
+		ret = true;
+out:
+	if (dat_entry)
+		batadv_dat_entry_free_ref(dat_entry);
+	if (primary_if)
+		batadv_hardif_free_ref(primary_if);
+	if (ret)
+		kfree_skb(skb);
+	return ret;
+}
+
+/**
+ * batadv_dat_snoop_outgoing_arp_reply - snoop the ARP reply and fill the DHT
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: packet to check
+ */
+void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb)
+{
+	uint16_t type;
+	__be32 ip_src, ip_dst;
+	uint8_t *hw_src, *hw_dst;
+
+	type = batadv_arp_get_type(bat_priv, skb, 0);
+	if (type != ARPOP_REPLY)
+		return;
+
+	batadv_dbg_arp(bat_priv, skb, type, 0, "Parsing outgoing ARP REPLY");
+
+	hw_src = batadv_arp_hw_src(skb, 0);
+	ip_src = batadv_arp_ip_src(skb, 0);
+	hw_dst = batadv_arp_hw_dst(skb, 0);
+	ip_dst = batadv_arp_ip_dst(skb, 0);
+
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst);
+
+	/* Send the ARP reply to the candidates for both the IP addresses that
+	 * the node got within the ARP reply
+	 */
+	batadv_dat_send_data(bat_priv, skb, ip_src, BATADV_P_DAT_DHT_PUT);
+	batadv_dat_send_data(bat_priv, skb, ip_dst, BATADV_P_DAT_DHT_PUT);
+}
+/**
+ * batadv_dat_snoop_incoming_arp_reply - snoop the ARP reply and fill the local
+ * DAT storage only
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: packet to check
+ * @hdr_size: siaze of the encapsulation header
+ */
+bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb, int hdr_size)
+{
+	uint16_t type;
+	__be32 ip_src, ip_dst;
+	uint8_t *hw_src, *hw_dst;
+	bool ret = false;
+
+	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
+	if (type != ARPOP_REPLY)
+		goto out;
+
+	batadv_dbg_arp(bat_priv, skb, type, hdr_size,
+		       "Parsing incoming ARP REPLY");
+
+	hw_src = batadv_arp_hw_src(skb, hdr_size);
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	hw_dst = batadv_arp_hw_dst(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
+
+	/* Update our internal cache with both the IP addresses the node got
+	 * within the ARP reply
+	 */
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst);
+
+	/* if this REPLY is directed to a client of mine, let's deliver the
+	 * packet to the interface
+	 */
+	ret = !batadv_is_my_client(bat_priv, hw_dst);
+out:
+	/* if ret == false -> packet has to be delivered to the interface */
+	return ret;
+}
+
+/**
+ * batadv_dat_drop_broadcast_packet - check if an ARP request has to be dropped
+ * (because the node has already got the reply via DAT) or not
+ * @bat_priv: the bat priv with all the soft interface information
+ * @forw_packet: the broadcast packet
+ *
+ * Returns true if the node can drop the packet, false otherwise
+ */
+bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
+				      struct batadv_forw_packet *forw_packet)
+{
+	uint16_t type;
+	__be32 ip_dst;
+	struct batadv_dat_entry *dat_entry = NULL;
+	bool ret = false;
+	const size_t bcast_len = sizeof(struct batadv_bcast_packet);
+
+	/* If this packet is an ARP_REQUEST and the node already has the
+	 * information that it is going to ask, then the packet can be dropped
+	 */
+	if (forw_packet->num_packets)
+		goto out;
+
+	type = batadv_arp_get_type(bat_priv, forw_packet->skb, bcast_len);
+	if (type != ARPOP_REQUEST)
+		goto out;
+
+	ip_dst = batadv_arp_ip_dst(forw_packet->skb, bcast_len);
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	/* check if the node already got this entry */
+	if (!dat_entry) {
+		batadv_dbg(BATADV_DBG_DAT, bat_priv,
+			   "ARP Request for %pI4: fallback\n", &ip_dst);
+		goto out;
+	}
+
+	batadv_dbg(BATADV_DBG_DAT, bat_priv,
+		   "ARP Request for %pI4: fallback prevented\n", &ip_dst);
+	ret = true;
+
+out:
+	if (dat_entry)
+		batadv_dat_entry_free_ref(dat_entry);
+	return ret;
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index f4e282a..01308ce 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -27,6 +27,17 @@
 
 #define BATADV_DAT_ADDR_MAX ((batadv_dat_addr_t)~(batadv_dat_addr_t)0)
 
+bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
+					   struct sk_buff *skb);
+bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
+					   struct sk_buff *skb, int hdr_size);
+void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb);
+bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
+					 struct sk_buff *skb, int hdr_size);
+bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
+				      struct batadv_forw_packet *forw_packet);
+
 /**
  * batadv_dat_init_orig_node_addr - assign a DAT address to the orig_node
  * @orig_node: the node to assign the DAT address to
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 25adfd2..240c74f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -74,6 +74,8 @@
 
 #define BATADV_LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
+/* msecs after which an ARP_REQUEST is sent in broadcast as fallback */
+#define ARP_REQ_DELAY 250
 /* numbers of originator to contact for any PUT/GET DHT operation */
 #define BATADV_DAT_CANDIDATES_NUM 3
 
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 859679b..1826699 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -28,6 +28,7 @@
 #include "vis.h"
 #include "unicast.h"
 #include "bridge_loop_avoidance.h"
+#include "distributed-arp-table.h"
 
 static int batadv_route_unicast_packet(struct sk_buff *skb,
 				       struct batadv_hard_iface *recv_if);
@@ -985,11 +986,13 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
 	struct batadv_unicast_packet *unicast_packet;
 	int hdr_size = sizeof(*unicast_packet);
+	bool is4addr;
 
 	unicast_packet = (struct batadv_unicast_packet *)skb->data;
 
+	is4addr = unicast_packet->header.packet_type == BATADV_UNICAST_4ADDR;
 	/* the caller function should have already pulled 2 bytes */
-	if (unicast_packet->header.packet_type == BATADV_UNICAST_4ADDR)
+	if (is4addr)
 		hdr_size = sizeof(struct batadv_unicast_4addr_packet);
 
 	if (batadv_check_unicast_packet(skb, hdr_size) < 0)
@@ -1000,9 +1003,17 @@ int batadv_recv_unicast_packet(struct sk_buff *skb,
 
 	/* packet for me */
 	if (batadv_is_my_mac(unicast_packet->dest)) {
+		if (batadv_dat_snoop_incoming_arp_request(bat_priv, skb,
+							  hdr_size))
+			goto rx_success;
+		if (batadv_dat_snoop_incoming_arp_reply(bat_priv, skb,
+							hdr_size))
+			goto rx_success;
+
 		batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size,
 				    NULL);
 
+rx_success:
 		return NET_RX_SUCCESS;
 	}
 
@@ -1038,8 +1049,17 @@ int batadv_recv_ucast_frag_packet(struct sk_buff *skb,
 		if (!new_skb)
 			return NET_RX_SUCCESS;
 
+		if (batadv_dat_snoop_incoming_arp_request(bat_priv, new_skb,
+							  hdr_size))
+			goto rx_success;
+		if (batadv_dat_snoop_incoming_arp_reply(bat_priv, new_skb,
+							hdr_size))
+			goto rx_success;
+
 		batadv_interface_rx(recv_if->soft_iface, new_skb, recv_if,
 				    sizeof(struct batadv_unicast_packet), NULL);
+
+rx_success:
 		return NET_RX_SUCCESS;
 	}
 
@@ -1131,9 +1151,16 @@ int batadv_recv_bcast_packet(struct sk_buff *skb,
 	if (batadv_bla_is_backbone_gw(skb, orig_node, hdr_size))
 		goto out;
 
+	if (batadv_dat_snoop_incoming_arp_request(bat_priv, skb, hdr_size))
+		goto rx_success;
+	if (batadv_dat_snoop_incoming_arp_reply(bat_priv, skb, hdr_size))
+		goto rx_success;
+
 	/* broadcast for me */
 	batadv_interface_rx(recv_if->soft_iface, skb, recv_if, hdr_size,
 			    orig_node);
+
+rx_success:
 	ret = NET_RX_SUCCESS;
 	goto out;
 
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 570a8bc..660d9bf 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -18,6 +18,7 @@
  */
 
 #include "main.h"
+#include "distributed-arp-table.h"
 #include "send.h"
 #include "routing.h"
 #include "translation-table.h"
@@ -209,6 +210,9 @@ static void batadv_send_outstanding_bcast_packet(struct work_struct *work)
 	if (atomic_read(&bat_priv->mesh_state) == BATADV_MESH_DEACTIVATING)
 		goto out;
 
+	if (batadv_dat_drop_broadcast_packet(bat_priv, forw_packet))
+		goto out;
+
 	/* rebroadcast packet */
 	rcu_read_lock();
 	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 2f123a1..9dc0ae1 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -20,6 +20,7 @@
 #include "main.h"
 #include "soft-interface.h"
 #include "hard-interface.h"
+#include "distributed-arp-table.h"
 #include "routing.h"
 #include "send.h"
 #include "debugfs.h"
@@ -155,6 +156,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	short vid __maybe_unused = -1;
 	bool do_bcast = false;
 	uint32_t seqno;
+	unsigned long brd_delay = 1;
 
 	if (atomic_read(&bat_priv->mesh_state) != BATADV_MESH_ACTIVE)
 		goto dropped;
@@ -224,6 +226,13 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		if (!primary_if)
 			goto dropped;
 
+		/* in case of ARP request, we do not immediately broadcasti the
+		 * packet, instead we first wait for DAT to try to retrieve the
+		 * correct ARP entry
+		 */
+		if (batadv_dat_snoop_outgoing_arp_request(bat_priv, skb))
+			brd_delay = msecs_to_jiffies(ARP_REQ_DELAY);
+
 		if (batadv_skb_head_push(skb, sizeof(*bcast_packet)) < 0)
 			goto dropped;
 
@@ -245,7 +254,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 		seqno = atomic_inc_return(&bat_priv->bcast_seqno);
 		bcast_packet->seqno = htonl(seqno);
 
-		batadv_add_bcast_packet_to_list(bat_priv, skb, 1);
+		batadv_add_bcast_packet_to_list(bat_priv, skb, brd_delay);
 
 		/* a copy is stored in the bcast list, therefore removing
 		 * the original skb.
@@ -260,6 +269,11 @@ static int batadv_interface_tx(struct sk_buff *skb,
 				goto dropped;
 		}
 
+		if (batadv_dat_snoop_outgoing_arp_request(bat_priv, skb))
+			goto dropped;
+
+		batadv_dat_snoop_outgoing_arp_reply(bat_priv, skb);
+
 		ret = batadv_unicast_send_skb(bat_priv, skb);
 		if (ret != 0)
 			goto dropped_freed;
-- 
1.8.0
