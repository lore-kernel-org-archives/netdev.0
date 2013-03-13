From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 9/9] batman-adv: network coding - receive coded packets and decode them
Date: Wed, 13 Mar 2013 23:56:39 +0100
Message-ID: <1363215399-18875-10-git-send-email-ordex@autistici.org>
References: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:20362 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934310Ab3CMW6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:08 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

When receiving a network coded packet, the decoding buffer is searched
for a packet to use for decoding. The source, destination, and crc32 fr=
om
the coded packet is used to identify the wanted packet. The decoded
packet is passed to the usual unicast receiver function, as had it neve=
r
been network coded.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/network-coding.c | 232 ++++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/soft-interface.c |   4 +
 net/batman-adv/types.h          |  10 ++
 3 files changed, 246 insertions(+)

diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 3d2ed2f..5728079 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -25,11 +25,14 @@
 #include "send.h"
 #include "originator.h"
 #include "hard-interface.h"
+#include "routing.h"
=20
 static struct lock_class_key batadv_nc_coding_hash_lock_class_key;
 static struct lock_class_key batadv_nc_decoding_hash_lock_class_key;
=20
 static void batadv_nc_worker(struct work_struct *work);
+static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
+				       struct batadv_hard_iface *recv_if);
=20
 /**
  * batadv_nc_start_timer - initialise the nc periodic worker
@@ -67,6 +70,11 @@ int batadv_nc_init(struct batadv_priv *bat_priv)
 	batadv_hash_set_lock_class(bat_priv->nc.coding_hash,
 				   &batadv_nc_decoding_hash_lock_class_key);
=20
+	/* Register our packet type */
+	if (batadv_recv_handler_register(BATADV_CODED,
+					 batadv_nc_recv_coded_packet) < 0)
+		goto err;
+
 	INIT_DELAYED_WORK(&bat_priv->nc.work, batadv_nc_worker);
 	batadv_nc_start_timer(bat_priv);
=20
@@ -1486,11 +1494,235 @@ void batadv_nc_skb_store_sniffed_unicast(struc=
t batadv_priv *bat_priv,
 }
=20
 /**
+ * batadv_nc_skb_decode_packet - decode given skb using the decode dat=
a stored
+ *  in nc_packet
+ * @skb: unicast skb to decode
+ * @nc_packet: decode data needed to decode the skb
+ *
+ * Returns pointer to decoded unicast packet if the packet was decoded=
 or NULL
+ * in case of an error.
+ */
+static struct batadv_unicast_packet *
+batadv_nc_skb_decode_packet(struct sk_buff *skb,
+			    struct batadv_nc_packet *nc_packet)
+{
+	const int h_size =3D sizeof(struct batadv_unicast_packet);
+	const int h_diff =3D sizeof(struct batadv_coded_packet) - h_size;
+	struct batadv_unicast_packet *unicast_packet;
+	struct batadv_coded_packet coded_packet_tmp;
+	struct ethhdr *ethhdr, ethhdr_tmp;
+	uint8_t *orig_dest, ttl, ttvn;
+	unsigned int coding_len;
+
+	/* Save headers temporarily */
+	memcpy(&coded_packet_tmp, skb->data, sizeof(coded_packet_tmp));
+	memcpy(&ethhdr_tmp, skb_mac_header(skb), sizeof(ethhdr_tmp));
+
+	if (skb_cow(skb, 0) < 0)
+		return NULL;
+
+	if (unlikely(!skb_pull_rcsum(skb, h_diff)))
+		return NULL;
+
+	/* Data points to batman header, so set mac header 14 bytes before
+	 * and network to data
+	 */
+	skb_set_mac_header(skb, -ETH_HLEN);
+	skb_reset_network_header(skb);
+
+	/* Reconstruct original mac header */
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+	memcpy(ethhdr, &ethhdr_tmp, sizeof(*ethhdr));
+
+	/* Select the correct unicast header information based on the locatio=
n
+	 * of our mac address in the coded_packet header
+	 */
+	if (batadv_is_my_mac(coded_packet_tmp.second_dest)) {
+		/* If we are the second destination the packet was overheard,
+		 * so the Ethernet address must be copied to h_dest and
+		 * pkt_type changed from PACKET_OTHERHOST to PACKET_HOST
+		 */
+		memcpy(ethhdr->h_dest, coded_packet_tmp.second_dest, ETH_ALEN);
+		skb->pkt_type =3D PACKET_HOST;
+
+		orig_dest =3D coded_packet_tmp.second_orig_dest;
+		ttl =3D coded_packet_tmp.second_ttl;
+		ttvn =3D coded_packet_tmp.second_ttvn;
+	} else {
+		orig_dest =3D coded_packet_tmp.first_orig_dest;
+		ttl =3D coded_packet_tmp.header.ttl;
+		ttvn =3D coded_packet_tmp.first_ttvn;
+	}
+
+	coding_len =3D ntohs(coded_packet_tmp.coded_len);
+
+	if (coding_len > skb->len)
+		return NULL;
+
+	/* Here the magic is reversed:
+	 *   extract the missing packet from the received coded packet
+	 */
+	batadv_nc_memxor(skb->data + h_size,
+			 nc_packet->skb->data + h_size,
+			 coding_len);
+
+	/* Resize decoded skb if decoded with larger packet */
+	if (nc_packet->skb->len > coding_len + h_size)
+		pskb_trim_rcsum(skb, coding_len + h_size);
+
+	/* Create decoded unicast packet */
+	unicast_packet =3D (struct batadv_unicast_packet *)skb->data;
+	unicast_packet->header.packet_type =3D BATADV_UNICAST;
+	unicast_packet->header.version =3D BATADV_COMPAT_VERSION;
+	unicast_packet->header.ttl =3D ttl;
+	memcpy(unicast_packet->dest, orig_dest, ETH_ALEN);
+	unicast_packet->ttvn =3D ttvn;
+
+	batadv_nc_packet_free(nc_packet);
+	return unicast_packet;
+}
+
+/**
+ * batadv_nc_find_decoding_packet - search through buffered decoding d=
ata to
+ *  find the data needed to decode the coded packet
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ethhdr: pointer to the ethernet header inside the coded packet
+ * @coded: coded packet we try to find decode data for
+ *
+ * Returns pointer to nc packet if the needed data was found or NULL o=
therwise.
+ */
+static struct batadv_nc_packet *
+batadv_nc_find_decoding_packet(struct batadv_priv *bat_priv,
+			       struct ethhdr *ethhdr,
+			       struct batadv_coded_packet *coded)
+{
+	struct batadv_hashtable *hash =3D bat_priv->nc.decoding_hash;
+	struct batadv_nc_packet *tmp_nc_packet, *nc_packet =3D NULL;
+	struct batadv_nc_path *nc_path, nc_path_key;
+	uint8_t *dest, *source;
+	__be32 packet_id;
+	int index;
+
+	if (!hash)
+		return NULL;
+
+	/* Select the correct packet id based on the location of our mac-addr=
 */
+	dest =3D ethhdr->h_source;
+	if (!batadv_is_my_mac(coded->second_dest)) {
+		source =3D coded->second_source;
+		packet_id =3D coded->second_crc;
+	} else {
+		source =3D coded->first_source;
+		packet_id =3D coded->first_crc;
+	}
+
+	batadv_nc_hash_key_gen(&nc_path_key, source, dest);
+	index =3D batadv_nc_hash_choose(&nc_path_key, hash->size);
+
+	/* Search for matching coding path */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(nc_path, &hash->table[index], hash_entry) {
+		/* Find matching nc_packet */
+		spin_lock_bh(&nc_path->packet_list_lock);
+		list_for_each_entry(tmp_nc_packet,
+				    &nc_path->packet_list, list) {
+			if (packet_id =3D=3D tmp_nc_packet->packet_id) {
+				list_del(&tmp_nc_packet->list);
+
+				nc_packet =3D tmp_nc_packet;
+				break;
+			}
+		}
+		spin_unlock_bh(&nc_path->packet_list_lock);
+
+		if (nc_packet)
+			break;
+	}
+	rcu_read_unlock();
+
+	if (!nc_packet)
+		batadv_dbg(BATADV_DBG_NC, bat_priv,
+			   "No decoding packet found for %u\n", packet_id);
+
+	return nc_packet;
+}
+
+/**
+ * batadv_nc_recv_coded_packet - try to decode coded packet and enqueu=
e the
+ *  resulting unicast packet
+ * @skb: incoming coded packet
+ * @recv_if: pointer to interface this packet was received on
+ */
+static int batadv_nc_recv_coded_packet(struct sk_buff *skb,
+				       struct batadv_hard_iface *recv_if)
+{
+	struct batadv_priv *bat_priv =3D netdev_priv(recv_if->soft_iface);
+	struct batadv_unicast_packet *unicast_packet;
+	struct batadv_coded_packet *coded_packet;
+	struct batadv_nc_packet *nc_packet;
+	struct ethhdr *ethhdr;
+	int hdr_size =3D sizeof(*coded_packet);
+
+	/* Check if network coding is enabled */
+	if (!atomic_read(&bat_priv->network_coding))
+		return NET_RX_DROP;
+
+	/* Make sure we can access (and remove) header */
+	if (unlikely(!pskb_may_pull(skb, hdr_size)))
+		return NET_RX_DROP;
+
+	coded_packet =3D (struct batadv_coded_packet *)skb->data;
+	ethhdr =3D (struct ethhdr *)skb_mac_header(skb);
+
+	/* Verify frame is destined for us */
+	if (!batadv_is_my_mac(ethhdr->h_dest) &&
+	    !batadv_is_my_mac(coded_packet->second_dest))
+		return NET_RX_DROP;
+
+	/* Update stat counter */
+	if (batadv_is_my_mac(coded_packet->second_dest))
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_SNIFFED);
+
+	nc_packet =3D batadv_nc_find_decoding_packet(bat_priv, ethhdr,
+						   coded_packet);
+	if (!nc_packet) {
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_DECODE_FAILED);
+		return NET_RX_DROP;
+	}
+
+	/* Make skb's linear, because decoding accesses the entire buffer */
+	if (skb_linearize(skb) < 0)
+		goto free_nc_packet;
+
+	if (skb_linearize(nc_packet->skb) < 0)
+		goto free_nc_packet;
+
+	/* Decode the packet */
+	unicast_packet =3D batadv_nc_skb_decode_packet(skb, nc_packet);
+	if (!unicast_packet) {
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_DECODE_FAILED);
+		goto free_nc_packet;
+	}
+
+	/* Mark packet as decoded to do correct recoding when forwarding */
+	BATADV_SKB_CB(skb)->decoded =3D true;
+	batadv_inc_counter(bat_priv, BATADV_CNT_NC_DECODE);
+	batadv_add_counter(bat_priv, BATADV_CNT_NC_DECODE_BYTES,
+			   skb->len + ETH_HLEN);
+	return batadv_recv_unicast_packet(skb, recv_if);
+
+free_nc_packet:
+	batadv_nc_packet_free(nc_packet);
+	return NET_RX_DROP;
+}
+
+/**
  * batadv_nc_free - clean up network coding memory
  * @bat_priv: the bat priv with all the soft interface information
  */
 void batadv_nc_free(struct batadv_priv *bat_priv)
 {
+	batadv_recv_handler_unregister(BATADV_CODED);
 	cancel_delayed_work_sync(&bat_priv->nc.work);
=20
 	batadv_nc_purge_paths(bat_priv, bat_priv->nc.coding_hash, NULL);
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 75204ec..f93ae42 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -671,6 +671,10 @@ static const struct {
 	{ "nc_recode" },
 	{ "nc_recode_bytes" },
 	{ "nc_buffer" },
+	{ "nc_decode" },
+	{ "nc_decode_bytes" },
+	{ "nc_decode_failed" },
+	{ "nc_sniffed" },
 #endif
 };
=20
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 5f3640d..aba8364 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -280,6 +280,12 @@ struct batadv_bcast_duplist_entry {
  * @BATADV_CNT_NC_RECODE: transmitted nc-recombined traffic packet cou=
nter
  * @BATADV_CNT_NC_RECODE_BYTES: transmitted nc-recombined traffic byte=
s counter
  * @BATADV_CNT_NC_BUFFER: counter for packets buffered for later nc de=
coding
+ * @BATADV_CNT_NC_DECODE: received and nc-decoded traffic packet count=
er
+ * @BATADV_CNT_NC_DECODE_BYTES: received and nc-decoded traffic bytes =
counter
+ * @BATADV_CNT_NC_DECODE_FAILED: received and decode-failed traffic pa=
cket
+ *  counter
+ * @BATADV_CNT_NC_SNIFFED: counter for nc-decoded packets received in =
promisc
+ *  mode.
  * @BATADV_CNT_NUM: number of traffic counters
  */
 enum batadv_counters {
@@ -313,6 +319,10 @@ enum batadv_counters {
 	BATADV_CNT_NC_RECODE,
 	BATADV_CNT_NC_RECODE_BYTES,
 	BATADV_CNT_NC_BUFFER,
+	BATADV_CNT_NC_DECODE,
+	BATADV_CNT_NC_DECODE_BYTES,
+	BATADV_CNT_NC_DECODE_FAILED,
+	BATADV_CNT_NC_SNIFFED,
 #endif
 	BATADV_CNT_NUM,
 };
--=20
1.8.1.5
