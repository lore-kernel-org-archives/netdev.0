From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 7/9] batman-adv: network coding - code and transmit packets if possible
Date: Wed, 13 Mar 2013 23:56:37 +0100
Message-ID: <1363215399-18875-8-git-send-email-ordex@autistici.org>
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
Received: from contumacia.investici.org ([178.255.144.35]:20245 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934356Ab3CMW6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:58:05 -0400
In-Reply-To: <1363215399-18875-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Martin Hundeb=C3=B8ll <martin@hundeboll.net>

Before adding forward-skbs to the coding buffer, the buffer is searched
for a potential coding opportunity. If one is found, the two packets ar=
e
network coded and transmitted right away. If not, the forward-skb is
added to the buffer.

Network coded packets are transmitted with information about the two
receivers and the two coded packets. The first receiver is given by the
MAC header, while the second is given in the payload/bat-header. The
second receiver uses promiscuous mode to receive the packet and check
the second destination.

Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h           |   6 +
 net/batman-adv/network-coding.c | 401 ++++++++++++++++++++++++++++++++=
++++++++
 net/batman-adv/packet.h         |  33 ++++
 net/batman-adv/soft-interface.c |   6 +
 net/batman-adv/types.h          |  20 ++
 5 files changed, 466 insertions(+)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 8a10619..0afd4ee 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -302,4 +302,10 @@ static inline uint64_t batadv_sum_counter(struct b=
atadv_priv *bat_priv,
 	return sum;
 }
=20
+/* Define a macro to reach the control buffer of the skb. The members =
of the
+ * control buffer are defined in struct batadv_skb_cb in types.h.
+ * The macro is inspired by the similar macro TCP_SKB_CB() in tcp.h.
+ */
+#define BATADV_SKB_CB(__skb)       ((struct batadv_skb_cb *)&((__skb)-=
>cb[0]))
+
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/network-coding.c b/net/batman-adv/network-c=
oding.c
index 2c38c54..fce2846 100644
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -798,6 +798,403 @@ static struct batadv_nc_path *batadv_nc_get_path(=
struct batadv_priv *bat_priv,
 }
=20
 /**
+ * batadv_nc_random_weight_tq - scale the receivers TQ-value to avoid =
unfair
+ *  selection of a receiver with slightly lower TQ than the other
+ * @tq: to be weighted tq value
+ */
+static uint8_t batadv_nc_random_weight_tq(uint8_t tq)
+{
+	uint8_t rand_val, rand_tq;
+
+	get_random_bytes(&rand_val, sizeof(rand_val));
+
+	/* randomize the estimated packet loss (max TQ - estimated TQ) */
+	rand_tq =3D rand_val * (BATADV_TQ_MAX_VALUE - tq);
+
+	/* normalize the randomized packet loss */
+	rand_tq /=3D BATADV_TQ_MAX_VALUE;
+
+	/* convert to (randomized) estimated tq again */
+	return BATADV_TQ_MAX_VALUE - rand_tq;
+}
+
+/**
+ * batadv_nc_memxor - XOR destination with source
+ * @dst: byte array to XOR into
+ * @src: byte array to XOR from
+ * @len: length of destination array
+ */
+static void batadv_nc_memxor(char *dst, const char *src, unsigned int =
len)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < len; ++i)
+		dst[i] ^=3D src[i];
+}
+
+/**
+ * batadv_nc_code_packets - code a received unicast_packet with an nc =
packet
+ *  into a coded_packet and send it
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: data skb to forward
+ * @ethhdr: pointer to the ethernet header inside the skb
+ * @nc_packet: structure containing the packet to the skb can be coded=
 with
+ * @neigh_node: next hop to forward packet to
+ *
+ * Returns true if both packets are consumed, false otherwise.
+ */
+static bool batadv_nc_code_packets(struct batadv_priv *bat_priv,
+				   struct sk_buff *skb,
+				   struct ethhdr *ethhdr,
+				   struct batadv_nc_packet *nc_packet,
+				   struct batadv_neigh_node *neigh_node)
+{
+	uint8_t tq_weighted_neigh, tq_weighted_coding;
+	struct sk_buff *skb_dest, *skb_src;
+	struct batadv_unicast_packet *packet1;
+	struct batadv_unicast_packet *packet2;
+	struct batadv_coded_packet *coded_packet;
+	struct batadv_neigh_node *neigh_tmp, *router_neigh;
+	struct batadv_neigh_node *router_coding =3D NULL;
+	uint8_t *first_source, *first_dest, *second_source, *second_dest;
+	__be32 packet_id1, packet_id2;
+	size_t count;
+	bool res =3D false;
+	int coding_len;
+	int unicast_size =3D sizeof(*packet1);
+	int coded_size =3D sizeof(*coded_packet);
+	int header_add =3D coded_size - unicast_size;
+
+	router_neigh =3D batadv_orig_node_get_router(neigh_node->orig_node);
+	if (!router_neigh)
+		goto out;
+
+	neigh_tmp =3D nc_packet->neigh_node;
+	router_coding =3D batadv_orig_node_get_router(neigh_tmp->orig_node);
+	if (!router_coding)
+		goto out;
+
+	tq_weighted_neigh =3D batadv_nc_random_weight_tq(router_neigh->tq_avg=
);
+	tq_weighted_coding =3D batadv_nc_random_weight_tq(router_coding->tq_a=
vg);
+
+	/* Select one destination for the MAC-header dst-field based on
+	 * weighted TQ-values.
+	 */
+	if (tq_weighted_neigh >=3D tq_weighted_coding) {
+		/* Destination from nc_packet is selected for MAC-header */
+		first_dest =3D nc_packet->nc_path->next_hop;
+		first_source =3D nc_packet->nc_path->prev_hop;
+		second_dest =3D neigh_node->addr;
+		second_source =3D ethhdr->h_source;
+		packet1 =3D (struct batadv_unicast_packet *)nc_packet->skb->data;
+		packet2 =3D (struct batadv_unicast_packet *)skb->data;
+		packet_id1 =3D nc_packet->packet_id;
+		packet_id2 =3D batadv_skb_crc32(skb,
+					      skb->data + sizeof(*packet2));
+	} else {
+		/* Destination for skb is selected for MAC-header */
+		first_dest =3D neigh_node->addr;
+		first_source =3D ethhdr->h_source;
+		second_dest =3D nc_packet->nc_path->next_hop;
+		second_source =3D nc_packet->nc_path->prev_hop;
+		packet1 =3D (struct batadv_unicast_packet *)skb->data;
+		packet2 =3D (struct batadv_unicast_packet *)nc_packet->skb->data;
+		packet_id1 =3D batadv_skb_crc32(skb,
+					      skb->data + sizeof(*packet1));
+		packet_id2 =3D nc_packet->packet_id;
+	}
+
+	/* Instead of zero padding the smallest data buffer, we
+	 * code into the largest.
+	 */
+	if (skb->len <=3D nc_packet->skb->len) {
+		skb_dest =3D nc_packet->skb;
+		skb_src =3D skb;
+	} else {
+		skb_dest =3D skb;
+		skb_src =3D nc_packet->skb;
+	}
+
+	/* coding_len is used when decoding the packet shorter packet */
+	coding_len =3D skb_src->len - unicast_size;
+
+	if (skb_linearize(skb_dest) < 0 || skb_linearize(skb_src) < 0)
+		goto out;
+
+	skb_push(skb_dest, header_add);
+
+	coded_packet =3D (struct batadv_coded_packet *)skb_dest->data;
+	skb_reset_mac_header(skb_dest);
+
+	coded_packet->header.packet_type =3D BATADV_CODED;
+	coded_packet->header.version =3D BATADV_COMPAT_VERSION;
+	coded_packet->header.ttl =3D packet1->header.ttl;
+
+	/* Info about first unicast packet */
+	memcpy(coded_packet->first_source, first_source, ETH_ALEN);
+	memcpy(coded_packet->first_orig_dest, packet1->dest, ETH_ALEN);
+	coded_packet->first_crc =3D packet_id1;
+	coded_packet->first_ttvn =3D packet1->ttvn;
+
+	/* Info about second unicast packet */
+	memcpy(coded_packet->second_dest, second_dest, ETH_ALEN);
+	memcpy(coded_packet->second_source, second_source, ETH_ALEN);
+	memcpy(coded_packet->second_orig_dest, packet2->dest, ETH_ALEN);
+	coded_packet->second_crc =3D packet_id2;
+	coded_packet->second_ttl =3D packet2->header.ttl;
+	coded_packet->second_ttvn =3D packet2->ttvn;
+	coded_packet->coded_len =3D htons(coding_len);
+
+	/* This is where the magic happens: Code skb_src into skb_dest */
+	batadv_nc_memxor(skb_dest->data + coded_size,
+			 skb_src->data + unicast_size, coding_len);
+
+	/* Update counters accordingly */
+	if (BATADV_SKB_CB(skb_src)->decoded &&
+	    BATADV_SKB_CB(skb_dest)->decoded) {
+		/* Both packets are recoded */
+		count =3D skb_src->len + ETH_HLEN;
+		count +=3D skb_dest->len + ETH_HLEN;
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_RECODE, 2);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_RECODE_BYTES, count);
+	} else if (!BATADV_SKB_CB(skb_src)->decoded &&
+		   !BATADV_SKB_CB(skb_dest)->decoded) {
+		/* Both packets are newly coded */
+		count =3D skb_src->len + ETH_HLEN;
+		count +=3D skb_dest->len + ETH_HLEN;
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_CODE, 2);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_CODE_BYTES, count);
+	} else if (BATADV_SKB_CB(skb_src)->decoded &&
+		   !BATADV_SKB_CB(skb_dest)->decoded) {
+		/* skb_src recoded and skb_dest is newly coded */
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_RECODE);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_RECODE_BYTES,
+				   skb_src->len + ETH_HLEN);
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_CODE);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_CODE_BYTES,
+				   skb_dest->len + ETH_HLEN);
+	} else if (!BATADV_SKB_CB(skb_src)->decoded &&
+		   BATADV_SKB_CB(skb_dest)->decoded) {
+		/* skb_src is newly coded and skb_dest is recoded */
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_CODE);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_CODE_BYTES,
+				   skb_src->len + ETH_HLEN);
+		batadv_inc_counter(bat_priv, BATADV_CNT_NC_RECODE);
+		batadv_add_counter(bat_priv, BATADV_CNT_NC_RECODE_BYTES,
+				   skb_dest->len + ETH_HLEN);
+	}
+
+	/* skb_src is now coded into skb_dest, so free it */
+	kfree_skb(skb_src);
+
+	/* avoid duplicate free of skb from nc_packet */
+	nc_packet->skb =3D NULL;
+	batadv_nc_packet_free(nc_packet);
+
+	/* Send the coded packet and return true */
+	batadv_send_skb_packet(skb_dest, neigh_node->if_incoming, first_dest)=
;
+	res =3D true;
+out:
+	if (router_neigh)
+		batadv_neigh_node_free_ref(router_neigh);
+	if (router_coding)
+		batadv_neigh_node_free_ref(router_coding);
+	return res;
+}
+
+/**
+ * batadv_nc_skb_coding_possible - true if a decoded skb is available =
at dst.
+ * @skb: data skb to forward
+ * @dst: destination mac address of the other skb to code with
+ * @src: source mac address of skb
+ *
+ * Whenever we network code a packet we have to check whether we recei=
ved it in
+ * a network coded form. If so, we may not be able to use it for codin=
g because
+ * some neighbors may also have received (overheard) the packet in the=
 network
+ * coded form without being able to decode it. It is hard to know whic=
h of the
+ * neighboring nodes was able to decode the packet, therefore we can o=
nly
+ * re-code the packet if the source of the previous encoded packet is =
involved.
+ * Since the source encoded the packet we can be certain it has all ne=
cessary
+ * decode information.
+ *
+ * Returns true if coding of a decoded packet is allowed.
+ */
+static bool batadv_nc_skb_coding_possible(struct sk_buff *skb,
+					  uint8_t *dst, uint8_t *src)
+{
+	if (BATADV_SKB_CB(skb)->decoded && !batadv_compare_eth(dst, src))
+		return false;
+	else
+		return true;
+}
+
+/**
+ * batadv_nc_path_search - Find the coding path matching in_nc_node an=
d
+ *  out_nc_node to retrieve a buffered packet that can be used for cod=
ing.
+ * @bat_priv: the bat priv with all the soft interface information
+ * @in_nc_node: pointer to skb next hop's neighbor nc node
+ * @out_nc_node: pointer to skb source's neighbor nc node
+ * @skb: data skb to forward
+ * @eth_dst: next hop mac address of skb
+ *
+ * Returns true if coding of a decoded skb is allowed.
+ */
+static struct batadv_nc_packet *
+batadv_nc_path_search(struct batadv_priv *bat_priv,
+		      struct batadv_nc_node *in_nc_node,
+		      struct batadv_nc_node *out_nc_node,
+		      struct sk_buff *skb,
+		      uint8_t *eth_dst)
+{
+	struct batadv_nc_path *nc_path, nc_path_key;
+	struct batadv_nc_packet *nc_packet_out =3D NULL;
+	struct batadv_nc_packet *nc_packet, *nc_packet_tmp;
+	struct batadv_hashtable *hash =3D bat_priv->nc.coding_hash;
+	int idx;
+
+	if (!hash)
+		return NULL;
+
+	/* Create almost path key */
+	batadv_nc_hash_key_gen(&nc_path_key, in_nc_node->addr,
+			       out_nc_node->addr);
+	idx =3D batadv_nc_hash_choose(&nc_path_key, hash->size);
+
+	/* Check for coding opportunities in this nc_path */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(nc_path, &hash->table[idx], hash_entry) {
+		if (!batadv_compare_eth(nc_path->prev_hop, in_nc_node->addr))
+			continue;
+
+		if (!batadv_compare_eth(nc_path->next_hop, out_nc_node->addr))
+			continue;
+
+		spin_lock_bh(&nc_path->packet_list_lock);
+		if (list_empty(&nc_path->packet_list)) {
+			spin_unlock_bh(&nc_path->packet_list_lock);
+			continue;
+		}
+
+		list_for_each_entry_safe(nc_packet, nc_packet_tmp,
+					 &nc_path->packet_list, list) {
+			if (!batadv_nc_skb_coding_possible(nc_packet->skb,
+							   eth_dst,
+							   in_nc_node->addr))
+				continue;
+
+			/* Coding opportunity is found! */
+			list_del(&nc_packet->list);
+			nc_packet_out =3D nc_packet;
+			break;
+		}
+
+		spin_unlock_bh(&nc_path->packet_list_lock);
+		break;
+	}
+	rcu_read_unlock();
+
+	return nc_packet_out;
+}
+
+/**
+ * batadv_nc_skb_src_search - Loops through the list of neighoring nod=
es of the
+ *  skb's sender (may be equal to the originator).
+ * @bat_priv: the bat priv with all the soft interface information
+ * @skb: data skb to forward
+ * @eth_dst: next hop mac address of skb
+ * @eth_src: source mac address of skb
+ * @in_nc_node: pointer to skb next hop's neighbor nc node
+ *
+ * Returns an nc packet if a suitable coding packet was found, NULL ot=
herwise.
+ */
+static struct batadv_nc_packet *
+batadv_nc_skb_src_search(struct batadv_priv *bat_priv,
+			 struct sk_buff *skb,
+			 uint8_t *eth_dst,
+			 uint8_t *eth_src,
+			 struct batadv_nc_node *in_nc_node)
+{
+	struct batadv_orig_node *orig_node;
+	struct batadv_nc_node *out_nc_node;
+	struct batadv_nc_packet *nc_packet =3D NULL;
+
+	orig_node =3D batadv_orig_hash_find(bat_priv, eth_src);
+	if (!orig_node)
+		return NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(out_nc_node,
+				&orig_node->out_coding_list, list) {
+		/* Check if the skb is decoded and if recoding is possible */
+		if (!batadv_nc_skb_coding_possible(skb,
+						   out_nc_node->addr, eth_src))
+			continue;
+
+		/* Search for an opportunity in this nc_path */
+		nc_packet =3D batadv_nc_path_search(bat_priv, in_nc_node,
+						  out_nc_node, skb, eth_dst);
+		if (nc_packet)
+			break;
+	}
+	rcu_read_unlock();
+
+	batadv_orig_node_free_ref(orig_node);
+	return nc_packet;
+}
+
+/**
+ * batadv_nc_skb_dst_search - Loops through list of neighboring nodes =
to dst.
+ * @skb: data skb to forward
+ * @neigh_node: next hop to forward packet to
+ * @ethhdr: pointer to the ethernet header inside the skb
+ *
+ * Loops through list of neighboring nodes the next hop has a good con=
nection to
+ * (receives OGMs with a sufficient quality). We need to find a neighb=
or of our
+ * next hop that potentially sent a packet which our next hop also rec=
eived
+ * (overheard) and has stored for later decoding.
+ *
+ * Returns true if the skb was consumed (encoded packet sent) or false=
 otherwise
+ */
+static bool batadv_nc_skb_dst_search(struct sk_buff *skb,
+				     struct batadv_neigh_node *neigh_node,
+				     struct ethhdr *ethhdr)
+{
+	struct net_device *netdev =3D neigh_node->if_incoming->soft_iface;
+	struct batadv_priv *bat_priv =3D netdev_priv(netdev);
+	struct batadv_orig_node *orig_node =3D neigh_node->orig_node;
+	struct batadv_nc_node *nc_node;
+	struct batadv_nc_packet *nc_packet =3D NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(nc_node, &orig_node->in_coding_list, list) {
+		/* Search for coding opportunity with this in_nc_node */
+		nc_packet =3D batadv_nc_skb_src_search(bat_priv, skb,
+						     neigh_node->addr,
+						     ethhdr->h_source, nc_node);
+
+		/* Opportunity was found, so stop searching */
+		if (nc_packet)
+			break;
+	}
+	rcu_read_unlock();
+
+	if (!nc_packet)
+		return false;
+
+	/* Code and send packets */
+	if (batadv_nc_code_packets(bat_priv, skb, ethhdr, nc_packet,
+				   neigh_node))
+		return true;
+
+	/* out of mem ? Coding failed - we have to free the buffered packet
+	 * to avoid memleaks. The skb passed as argument will be dealt with
+	 * by the calling function.
+	 */
+	batadv_nc_send_packet(nc_packet);
+	return false;
+}
+
+/**
  * batadv_nc_skb_add_to_path - buffer skb for later encoding / decodin=
g
  * @skb: skb to add to path
  * @nc_path: path to add skb to
@@ -862,6 +1259,10 @@ bool batadv_nc_skb_forward(struct sk_buff *skb,
 	if (packet->header.packet_type !=3D BATADV_UNICAST)
 		goto out;
=20
+	/* Try to find a coding opportunity and send the skb if one is found =
*/
+	if (batadv_nc_skb_dst_search(skb, neigh_node, ethhdr))
+		return true;
+
 	/* Find or create a nc_path for this src-dst pair */
 	nc_path =3D batadv_nc_get_path(bat_priv,
 				     bat_priv->nc.coding_hash,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index ed0aa89..a079958 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -30,6 +30,7 @@ enum batadv_packettype {
 	BATADV_TT_QUERY		=3D 0x07,
 	BATADV_ROAM_ADV		=3D 0x08,
 	BATADV_UNICAST_4ADDR	=3D 0x09,
+	BATADV_CODED		=3D 0x0a,
 };
=20
 /**
@@ -278,4 +279,36 @@ struct batadv_tt_change {
 	uint8_t addr[ETH_ALEN];
 } __packed;
=20
+/**
+ * struct batadv_coded_packet - network coded packet
+ * @header: common batman packet header and ttl of first included pack=
et
+ * @reserved: Align following fields to 2-byte boundaries
+ * @first_source: original source of first included packet
+ * @first_orig_dest: original destinal of first included packet
+ * @first_crc: checksum of first included packet
+ * @first_ttvn: tt-version number of first included packet
+ * @second_ttl: ttl of second packet
+ * @second_dest: second receiver of this coded packet
+ * @second_source: original source of second included packet
+ * @second_orig_dest: original destination of second included packet
+ * @second_crc: checksum of second included packet
+ * @second_ttvn: tt version number of second included packet
+ * @coded_len: length of network coded part of the payload
+ */
+struct batadv_coded_packet {
+	struct batadv_header header;
+	uint8_t  first_ttvn;
+	/* uint8_t  first_dest[ETH_ALEN]; - saved in mac header destination *=
/
+	uint8_t  first_source[ETH_ALEN];
+	uint8_t  first_orig_dest[ETH_ALEN];
+	__be32   first_crc;
+	uint8_t  second_ttl;
+	uint8_t  second_ttvn;
+	uint8_t  second_dest[ETH_ALEN];
+	uint8_t  second_source[ETH_ALEN];
+	uint8_t  second_orig_dest[ETH_ALEN];
+	__be32   second_crc;
+	uint16_t coded_len;
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 7188e07..7e463c3 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -665,6 +665,12 @@ static const struct {
 	{ "dat_put_rx" },
 	{ "dat_cached_reply_tx" },
 #endif
+#ifdef CONFIG_BATMAN_ADV_NC
+	{ "nc_code" },
+	{ "nc_code_bytes" },
+	{ "nc_recode" },
+	{ "nc_recode_bytes" },
+#endif
 };
=20
 static void batadv_get_strings(struct net_device *dev, uint32_t string=
set,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 43caf7f..42d7438 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -275,6 +275,10 @@ struct batadv_bcast_duplist_entry {
  * @BATADV_CNT_DAT_PUT_RX: received dht PUT traffic packet counter
  * @BATADV_CNT_DAT_CACHED_REPLY_TX: transmitted dat cache reply traffi=
c packet
  *  counter
+ * @BATADV_CNT_NC_CODE: transmitted nc-combined traffic packet counter
+ * @BATADV_CNT_NC_CODE_BYTES: transmitted nc-combined traffic bytes co=
unter
+ * @BATADV_CNT_NC_RECODE: transmitted nc-recombined traffic packet cou=
nter
+ * @BATADV_CNT_NC_RECODE_BYTES: transmitted nc-recombined traffic byte=
s counter
  * @BATADV_CNT_NUM: number of traffic counters
  */
 enum batadv_counters {
@@ -302,6 +306,12 @@ enum batadv_counters {
 	BATADV_CNT_DAT_PUT_RX,
 	BATADV_CNT_DAT_CACHED_REPLY_TX,
 #endif
+#ifdef CONFIG_BATMAN_ADV_NC
+	BATADV_CNT_NC_CODE,
+	BATADV_CNT_NC_CODE_BYTES,
+	BATADV_CNT_NC_RECODE,
+	BATADV_CNT_NC_RECODE_BYTES,
+#endif
 	BATADV_CNT_NUM,
 };
=20
@@ -797,6 +807,16 @@ struct batadv_nc_packet {
 };
=20
 /**
+ * batadv_skb_cb - control buffer structure used to store private data=
 relevant
+ *  to batman-adv in the skb->cb buffer in skbs.
+ * @decoded: Marks a skb as decoded, which is checked when searching f=
or coding
+ *  opportunities in network-coding.c
+ */
+struct batadv_skb_cb {
+	bool decoded;
+};
+
+/**
  * struct batadv_forw_packet - structure for bcast packets to be sent/=
forwarded
  * @list: list node for batadv_socket_client::queue_list
  * @send_time: execution time for delayed_work (packet sending)
--=20
1.8.1.5
