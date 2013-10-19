From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/18] batman-adv: make the Distributed ARP Table vlan aware
Date: Sun, 20 Oct 2013 00:22:01 +0200
Message-ID: <1382221330-3769-10-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:27255 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab3JSWXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:23:05 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

The same IP subnet can be used on different VLANs, therefore
DAT has to differentiate whether the IP to resolve belongs
to one or the other virtual LAN.
To accomplish this task DAT has to deal with the VLAN tag
and store it together with each ARP entry.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/distributed-arp-table.c | 153 ++++++++++++++++++++++-----------
 net/batman-adv/types.h                 |   2 +
 2 files changed, 107 insertions(+), 48 deletions(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 1b590f0..47dbe9a 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -19,6 +19,7 @@
 
 #include <linux/if_ether.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include <net/arp.h>
 
 #include "main.h"
@@ -205,15 +206,11 @@ static __be32 batadv_arp_ip_dst(struct sk_buff *skb, int hdr_size)
  */
 static uint32_t batadv_hash_dat(const void *data, uint32_t size)
 {
-	const unsigned char *key = data;
 	uint32_t hash = 0;
-	size_t i;
+	const struct batadv_dat_entry *dat = data;
 
-	for (i = 0; i < 4; i++) {
-		hash += key[i];
-		hash += (hash << 10);
-		hash ^= (hash >> 6);
-	}
+	hash = batadv_hash_bytes(hash, &dat->ip, sizeof(dat->ip));
+	hash = batadv_hash_bytes(hash, &dat->vid, sizeof(dat->vid));
 
 	hash += (hash << 3);
 	hash ^= (hash >> 11);
@@ -227,21 +224,26 @@ static uint32_t batadv_hash_dat(const void *data, uint32_t size)
  * table
  * @bat_priv: the bat priv with all the soft interface information
  * @ip: search key
+ * @vid: VLAN identifier
  *
  * Returns the dat_entry if found, NULL otherwise.
  */
 static struct batadv_dat_entry *
-batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip)
+batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip,
+			   unsigned short vid)
 {
 	struct hlist_head *head;
-	struct batadv_dat_entry *dat_entry, *dat_entry_tmp = NULL;
+	struct batadv_dat_entry to_find, *dat_entry, *dat_entry_tmp = NULL;
 	struct batadv_hashtable *hash = bat_priv->dat.hash;
 	uint32_t index;
 
 	if (!hash)
 		return NULL;
 
-	index = batadv_hash_dat(&ip, hash->size);
+	to_find.ip = ip;
+	to_find.vid = vid;
+
+	index = batadv_hash_dat(&to_find, hash->size);
 	head = &hash->table[index];
 
 	rcu_read_lock();
@@ -265,22 +267,24 @@ batadv_dat_entry_hash_find(struct batadv_priv *bat_priv, __be32 ip)
  * @bat_priv: the bat priv with all the soft interface information
  * @ip: ipv4 to add/edit
  * @mac_addr: mac address to assign to the given ipv4
+ * @vid: VLAN identifier
  */
 static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
-				 uint8_t *mac_addr)
+				 uint8_t *mac_addr, unsigned short vid)
 {
 	struct batadv_dat_entry *dat_entry;
 	int hash_added;
 
-	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip);
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip, vid);
 	/* if this entry is already known, just update it */
 	if (dat_entry) {
 		if (!batadv_compare_eth(dat_entry->mac_addr, mac_addr))
 			memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
 		dat_entry->last_update = jiffies;
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
-			   "Entry updated: %pI4 %pM\n", &dat_entry->ip,
-			   dat_entry->mac_addr);
+			   "Entry updated: %pI4 %pM (vid: %d)\n",
+			   &dat_entry->ip, dat_entry->mac_addr,
+			   BATADV_PRINT_VID(vid));
 		goto out;
 	}
 
@@ -289,12 +293,13 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 		goto out;
 
 	dat_entry->ip = ip;
+	dat_entry->vid = vid;
 	memcpy(dat_entry->mac_addr, mac_addr, ETH_ALEN);
 	dat_entry->last_update = jiffies;
 	atomic_set(&dat_entry->refcount, 2);
 
 	hash_added = batadv_hash_add(bat_priv->dat.hash, batadv_compare_dat,
-				     batadv_hash_dat, &dat_entry->ip,
+				     batadv_hash_dat, dat_entry,
 				     &dat_entry->hash_entry);
 
 	if (unlikely(hash_added != 0)) {
@@ -303,8 +308,8 @@ static void batadv_dat_entry_add(struct batadv_priv *bat_priv, __be32 ip,
 		goto out;
 	}
 
-	batadv_dbg(BATADV_DBG_DAT, bat_priv, "New entry added: %pI4 %pM\n",
-		   &dat_entry->ip, dat_entry->mac_addr);
+	batadv_dbg(BATADV_DBG_DAT, bat_priv, "New entry added: %pI4 %pM (vid: %d)\n",
+		   &dat_entry->ip, dat_entry->mac_addr, BATADV_PRINT_VID(vid));
 
 out:
 	if (dat_entry)
@@ -756,8 +761,8 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 
 	seq_printf(seq, "Distributed ARP Table (%s):\n", net_dev->name);
-	seq_printf(seq, "          %-7s          %-13s %5s\n", "IPv4", "MAC",
-		   "last-seen");
+	seq_printf(seq, "          %-7s          %-9s %4s %11s\n", "IPv4",
+		   "MAC", "VID", "last-seen");
 
 	for (i = 0; i < hash->size; i++) {
 		head = &hash->table[i];
@@ -770,8 +775,9 @@ int batadv_dat_cache_seq_print_text(struct seq_file *seq, void *offset)
 			last_seen_msecs = last_seen_msecs % 60000;
 			last_seen_secs = last_seen_msecs / 1000;
 
-			seq_printf(seq, " * %15pI4 %14pM %6i:%02i\n",
+			seq_printf(seq, " * %15pI4 %14pM %4i %6i:%02i\n",
 				   &dat_entry->ip, dat_entry->mac_addr,
+				   BATADV_PRINT_VID(dat_entry->vid),
 				   last_seen_mins, last_seen_secs);
 		}
 		rcu_read_unlock();
@@ -858,6 +864,31 @@ out:
 }
 
 /**
+ * batadv_dat_get_vid - extract the VLAN identifier from skb if any
+ * @skb: the buffer containing the packet to extract the VID from
+ * @hdr_size: the size of the batman-adv header encapsulating the packet
+ *
+ * If the packet embedded in the skb is vlan tagged this function returns the
+ * VID with the BATADV_VLAN_HAS_TAG flag. Otherwise BATADV_NO_FLAGS is returned.
+ */
+static unsigned short batadv_dat_get_vid(struct sk_buff *skb, int *hdr_size)
+{
+	unsigned short vid;
+
+	vid = batadv_get_vid(skb, *hdr_size);
+
+	/* ARP parsing functions jump forward of hdr_size + ETH_HLEN.
+	 * If the header contained in the packet is a VLAN one (which is longer)
+	 * hdr_size is updated so that the functions will still skip the
+	 * correct amount of bytes.
+	 */
+	if (vid & BATADV_VLAN_HAS_TAG)
+		*hdr_size += VLAN_HLEN;
+
+	return vid;
+}
+
+/**
  * batadv_dat_snoop_outgoing_arp_request - snoop the ARP request and try to
  * answer using DAT
  * @bat_priv: the bat priv with all the soft interface information
@@ -876,26 +907,31 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 	bool ret = false;
 	struct batadv_dat_entry *dat_entry = NULL;
 	struct sk_buff *skb_new;
+	int hdr_size = 0;
+	unsigned short vid;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		goto out;
 
-	type = batadv_arp_get_type(bat_priv, skb, 0);
+	vid = batadv_dat_get_vid(skb, &hdr_size);
+
+	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	/* If the node gets an ARP_REQUEST it has to send a DHT_GET unicast
 	 * message to the selected DHT candidates
 	 */
 	if (type != ARPOP_REQUEST)
 		goto out;
 
-	batadv_dbg_arp(bat_priv, skb, type, 0, "Parsing outgoing ARP REQUEST");
+	batadv_dbg_arp(bat_priv, skb, type, hdr_size,
+		       "Parsing outgoing ARP REQUEST");
 
-	ip_src = batadv_arp_ip_src(skb, 0);
-	hw_src = batadv_arp_hw_src(skb, 0);
-	ip_dst = batadv_arp_ip_dst(skb, 0);
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	hw_src = batadv_arp_hw_src(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
 
-	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src, vid);
 
-	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst, vid);
 	if (dat_entry) {
 		/* If the ARP request is destined for a local client the local
 		 * client will answer itself. DAT would only generate a
@@ -917,11 +953,15 @@ bool batadv_dat_snoop_outgoing_arp_request(struct batadv_priv *bat_priv,
 		if (!skb_new)
 			goto out;
 
+		if (vid & BATADV_VLAN_HAS_TAG)
+			skb_new = vlan_insert_tag(skb_new, htons(ETH_P_8021Q),
+						  vid & VLAN_VID_MASK);
+
 		skb_reset_mac_header(skb_new);
 		skb_new->protocol = eth_type_trans(skb_new,
 						   bat_priv->soft_iface);
 		bat_priv->stats.rx_packets++;
-		bat_priv->stats.rx_bytes += skb->len + ETH_HLEN;
+		bat_priv->stats.rx_bytes += skb->len + ETH_HLEN + hdr_size;
 		bat_priv->soft_iface->last_rx = jiffies;
 
 		netif_rx(skb_new);
@@ -956,11 +996,14 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	struct sk_buff *skb_new;
 	struct batadv_dat_entry *dat_entry = NULL;
 	bool ret = false;
+	unsigned short vid;
 	int err;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		goto out;
 
+	vid = batadv_dat_get_vid(skb, &hdr_size);
+
 	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	if (type != ARPOP_REQUEST)
 		goto out;
@@ -972,9 +1015,9 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	batadv_dbg_arp(bat_priv, skb, type, hdr_size,
 		       "Parsing incoming ARP REQUEST");
 
-	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src, vid);
 
-	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst, vid);
 	if (!dat_entry)
 		goto out;
 
@@ -985,6 +1028,10 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	if (!skb_new)
 		goto out;
 
+	if (vid & BATADV_VLAN_HAS_TAG)
+		skb_new = vlan_insert_tag(skb_new, htons(ETH_P_8021Q),
+					  vid & VLAN_VID_MASK);
+
 	/* To preserve backwards compatibility, the node has choose the outgoing
 	 * format based on the incoming request packet type. The assumption is
 	 * that a node not using the 4addr packet format doesn't support it.
@@ -992,10 +1039,9 @@ bool batadv_dat_snoop_incoming_arp_request(struct batadv_priv *bat_priv,
 	if (hdr_size == sizeof(struct batadv_unicast_4addr_packet))
 		err = batadv_send_skb_unicast_4addr(bat_priv, skb_new,
 						    BATADV_P_DAT_CACHE_REPLY,
-						    BATADV_NO_FLAGS);
+						    vid);
 	else
-		err = batadv_send_skb_unicast(bat_priv, skb_new,
-					      BATADV_NO_FLAGS);
+		err = batadv_send_skb_unicast(bat_priv, skb_new, vid);
 
 	if (!err) {
 		batadv_inc_counter(bat_priv, BATADV_CNT_DAT_CACHED_REPLY_TX);
@@ -1020,23 +1066,28 @@ void batadv_dat_snoop_outgoing_arp_reply(struct batadv_priv *bat_priv,
 	uint16_t type;
 	__be32 ip_src, ip_dst;
 	uint8_t *hw_src, *hw_dst;
+	int hdr_size = 0;
+	unsigned short vid;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		return;
 
-	type = batadv_arp_get_type(bat_priv, skb, 0);
+	vid = batadv_dat_get_vid(skb, &hdr_size);
+
+	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	if (type != ARPOP_REPLY)
 		return;
 
-	batadv_dbg_arp(bat_priv, skb, type, 0, "Parsing outgoing ARP REPLY");
+	batadv_dbg_arp(bat_priv, skb, type, hdr_size,
+		       "Parsing outgoing ARP REPLY");
 
-	hw_src = batadv_arp_hw_src(skb, 0);
-	ip_src = batadv_arp_ip_src(skb, 0);
-	hw_dst = batadv_arp_hw_dst(skb, 0);
-	ip_dst = batadv_arp_ip_dst(skb, 0);
+	hw_src = batadv_arp_hw_src(skb, hdr_size);
+	ip_src = batadv_arp_ip_src(skb, hdr_size);
+	hw_dst = batadv_arp_hw_dst(skb, hdr_size);
+	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
 
-	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
-	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst);
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src, vid);
+	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst, vid);
 
 	/* Send the ARP reply to the candidates for both the IP addresses that
 	 * the node obtained from the ARP reply
@@ -1058,10 +1109,13 @@ bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 	__be32 ip_src, ip_dst;
 	uint8_t *hw_src, *hw_dst;
 	bool ret = false;
+	unsigned short vid;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		goto out;
 
+	vid = batadv_dat_get_vid(skb, &hdr_size);
+
 	type = batadv_arp_get_type(bat_priv, skb, hdr_size);
 	if (type != ARPOP_REPLY)
 		goto out;
@@ -1077,13 +1131,13 @@ bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 	/* Update our internal cache with both the IP addresses the node got
 	 * within the ARP reply
 	 */
-	batadv_dat_entry_add(bat_priv, ip_src, hw_src);
-	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst);
+	batadv_dat_entry_add(bat_priv, ip_src, hw_src, vid);
+	batadv_dat_entry_add(bat_priv, ip_dst, hw_dst, vid);
 
 	/* if this REPLY is directed to a client of mine, let's deliver the
 	 * packet to the interface
 	 */
-	ret = !batadv_is_my_client(bat_priv, hw_dst, BATADV_NO_FLAGS);
+	ret = !batadv_is_my_client(bat_priv, hw_dst, vid);
 out:
 	if (ret)
 		kfree_skb(skb);
@@ -1106,7 +1160,8 @@ bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 	__be32 ip_dst;
 	struct batadv_dat_entry *dat_entry = NULL;
 	bool ret = false;
-	const size_t bcast_len = sizeof(struct batadv_bcast_packet);
+	int hdr_size = sizeof(struct batadv_bcast_packet);
+	unsigned short vid;
 
 	if (!atomic_read(&bat_priv->distributed_arp_table))
 		goto out;
@@ -1117,12 +1172,14 @@ bool batadv_dat_drop_broadcast_packet(struct batadv_priv *bat_priv,
 	if (forw_packet->num_packets)
 		goto out;
 
-	type = batadv_arp_get_type(bat_priv, forw_packet->skb, bcast_len);
+	vid = batadv_dat_get_vid(forw_packet->skb, &hdr_size);
+
+	type = batadv_arp_get_type(bat_priv, forw_packet->skb, hdr_size);
 	if (type != ARPOP_REQUEST)
 		goto out;
 
-	ip_dst = batadv_arp_ip_dst(forw_packet->skb, bcast_len);
-	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst);
+	ip_dst = batadv_arp_ip_dst(forw_packet->skb, hdr_size);
+	dat_entry = batadv_dat_entry_hash_find(bat_priv, ip_dst, vid);
 	/* check if the node already got this entry */
 	if (!dat_entry) {
 		batadv_dbg(BATADV_DBG_DAT, bat_priv,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 99029c5..6954a5d 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -933,6 +933,7 @@ struct batadv_algo_ops {
  * is used to stored ARP entries needed for the global DAT cache
  * @ip: the IPv4 corresponding to this DAT/ARP entry
  * @mac_addr: the MAC address associated to the stored IPv4
+ * @vid: the vlan ID associated to this entry
  * @last_update: time in jiffies when this entry was refreshed last time
  * @hash_entry: hlist node for batadv_priv_dat::hash
  * @refcount: number of contexts the object is used
@@ -941,6 +942,7 @@ struct batadv_algo_ops {
 struct batadv_dat_entry {
 	__be32 ip;
 	uint8_t mac_addr[ETH_ALEN];
+	unsigned short vid;
 	unsigned long last_update;
 	struct hlist_node hash_entry;
 	atomic_t refcount;
-- 
1.8.4
