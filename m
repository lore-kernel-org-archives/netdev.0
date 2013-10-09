From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/16] batman-adv: tvlv - basic infrastructure
Date: Wed,  9 Oct 2013 21:32:41 +0200
Message-ID: <1381347174-3629-4-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Spyros Gasteratos <morfeas3000@gmail.com>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:10428 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3JITfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:35:00 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The goal is to provide the infrastructure for sending, receiving and
parsing information 'containers' while preserving backward
compatibility. TVLV (based on the commonly known Type Length Value
technique) was chosen as the format for those containers. Even if a
node does not know the tvlv type of a certain container it can simply
skip the current container and proceed with the next. Past experience
has shown features evolve over time, so a 'version' field was added
right from the start to allow differentiating between feature
variants - hence the name: T(ype) V(ersion) L(ength) V(alue).

This patch introduces the basic TVLV infrastructure:
 * register / unregister tvlv containers to be sent with each OGM
   (on primary interfaces only)
 * register / unregister callback handlers to be called upon
   finding the corresponding tvlv type in a tvlv buffer
 * unicast tvlv send / receive API calls

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Spyros Gasteratos <morfeas3000@gmail.com>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c |  38 +--
 net/batman-adv/main.c       | 575 ++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/main.h       |  35 +++
 net/batman-adv/packet.h     |  41 ++++
 net/batman-adv/routing.c    |  48 ++++
 net/batman-adv/routing.h    |   2 +
 net/batman-adv/types.h      |  72 ++++++
 7 files changed, 794 insertions(+), 17 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 0a8a80c..f7dd7e5 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -207,12 +207,12 @@ static uint8_t batadv_hop_penalty(uint8_t tq,
 
 /* is there another aggregated packet here? */
 static int batadv_iv_ogm_aggr_packet(int buff_pos, int packet_len,
-				     int tt_num_changes)
+				     __be16 tvlv_len)
 {
 	int next_buff_pos = 0;
 
 	next_buff_pos += buff_pos + BATADV_OGM_HLEN;
-	next_buff_pos += batadv_tt_len(tt_num_changes);
+	next_buff_pos += ntohs(tvlv_len);
 
 	return (next_buff_pos <= packet_len) &&
 	       (next_buff_pos <= BATADV_MAX_AGGREGATION_BYTES);
@@ -240,7 +240,7 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 
 	/* adjust all flags and log packets */
 	while (batadv_iv_ogm_aggr_packet(buff_pos, forw_packet->packet_len,
-					 batadv_ogm_packet->tt_num_changes)) {
+					 batadv_ogm_packet->tvlv_len)) {
 		/* we might have aggregated direct link packets with an
 		 * ordinary base packet
 		 */
@@ -267,7 +267,7 @@ static void batadv_iv_ogm_send_to_if(struct batadv_forw_packet *forw_packet,
 			   hard_iface->net_dev->dev_addr);
 
 		buff_pos += BATADV_OGM_HLEN;
-		buff_pos += batadv_tt_len(batadv_ogm_packet->tt_num_changes);
+		buff_pos += ntohs(batadv_ogm_packet->tvlv_len);
 		packet_num++;
 		packet_pos = forw_packet->skb->data + buff_pos;
 		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
@@ -601,7 +601,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 				  struct batadv_hard_iface *if_incoming)
 {
 	struct batadv_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
-	uint8_t tt_num_changes;
+	uint16_t tvlv_len;
 
 	if (batadv_ogm_packet->header.ttl <= 1) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "ttl exceeded\n");
@@ -621,7 +621,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 			return;
 	}
 
-	tt_num_changes = batadv_ogm_packet->tt_num_changes;
+	tvlv_len = ntohs(batadv_ogm_packet->tvlv_len);
 
 	batadv_ogm_packet->header.ttl--;
 	memcpy(batadv_ogm_packet->prev_sender, ethhdr->h_source, ETH_ALEN);
@@ -642,7 +642,7 @@ static void batadv_iv_ogm_forward(struct batadv_orig_node *orig_node,
 		batadv_ogm_packet->flags &= ~BATADV_DIRECTLINK;
 
 	batadv_iv_ogm_queue_add(bat_priv, (unsigned char *)batadv_ogm_packet,
-				BATADV_OGM_HLEN + batadv_tt_len(tt_num_changes),
+				BATADV_OGM_HLEN + tvlv_len,
 				if_incoming, 0, batadv_iv_ogm_fwd_send_time());
 }
 
@@ -691,16 +691,18 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	int vis_server, tt_num_changes = 0;
 	uint32_t seqno;
 	uint8_t bandwidth;
+	uint16_t tvlv_len = 0;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 
 	if (hard_iface == primary_if)
-		tt_num_changes = batadv_tt_append_diff(bat_priv, ogm_buff,
-						       ogm_buff_len,
-						       BATADV_OGM_HLEN);
+		tvlv_len = batadv_tvlv_container_ogm_append(bat_priv, ogm_buff,
+							    ogm_buff_len,
+							    BATADV_OGM_HLEN);
 
 	batadv_ogm_packet = (struct batadv_ogm_packet *)(*ogm_buff);
+	batadv_ogm_packet->tvlv_len = htons(tvlv_len);
 
 	/* change sequence number to network order */
 	seqno = (uint32_t)atomic_read(&hard_iface->bat_iv.ogm_seqno);
@@ -1254,6 +1256,8 @@ static void batadv_iv_ogm_process(const struct ethhdr *ethhdr,
 		goto out;
 	}
 
+	batadv_tvlv_ogm_receive(bat_priv, batadv_ogm_packet, orig_node);
+
 	/* if sender is a direct neighbor the sender mac equals
 	 * originator mac
 	 */
@@ -1350,9 +1354,9 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 	struct batadv_ogm_packet *batadv_ogm_packet;
 	struct ethhdr *ethhdr;
 	int buff_pos = 0, packet_len;
-	unsigned char *tt_buff, *packet_buff;
+	unsigned char *tvlv_buff, *packet_buff;
+	uint8_t *packet_pos;
 	bool ret;
-	uint8_t *packet_pos;
 
 	ret = batadv_check_management_packet(skb, if_incoming, BATADV_OGM_HLEN);
 	if (!ret)
@@ -1375,14 +1379,14 @@ static int batadv_iv_ogm_receive(struct sk_buff *skb,
 
 	/* unpack the aggregated packets and process them one by one */
 	while (batadv_iv_ogm_aggr_packet(buff_pos, packet_len,
-					 batadv_ogm_packet->tt_num_changes)) {
-		tt_buff = packet_buff + buff_pos + BATADV_OGM_HLEN;
+					 batadv_ogm_packet->tvlv_len)) {
+		tvlv_buff = packet_buff + buff_pos + BATADV_OGM_HLEN;
 
-		batadv_iv_ogm_process(ethhdr, batadv_ogm_packet, tt_buff,
-				      if_incoming);
+		batadv_iv_ogm_process(ethhdr, batadv_ogm_packet,
+				      tvlv_buff, if_incoming);
 
 		buff_pos += BATADV_OGM_HLEN;
-		buff_pos += batadv_tt_len(batadv_ogm_packet->tt_num_changes);
+		buff_pos += ntohs(batadv_ogm_packet->tvlv_len);
 
 		packet_pos = packet_buff + buff_pos;
 		batadv_ogm_packet = (struct batadv_ogm_packet *)packet_pos;
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 1356af6..e2de68a 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -36,6 +36,7 @@
 #include "gateway_client.h"
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
+#include "unicast.h"
 #include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -112,6 +113,8 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	spin_lock_init(&bat_priv->gw.list_lock);
 	spin_lock_init(&bat_priv->vis.hash_lock);
 	spin_lock_init(&bat_priv->vis.list_lock);
+	spin_lock_init(&bat_priv->tvlv.container_list_lock);
+	spin_lock_init(&bat_priv->tvlv.handler_list_lock);
 
 	INIT_HLIST_HEAD(&bat_priv->forw_bat_list);
 	INIT_HLIST_HEAD(&bat_priv->forw_bcast_list);
@@ -119,6 +122,8 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	INIT_LIST_HEAD(&bat_priv->tt.changes_list);
 	INIT_LIST_HEAD(&bat_priv->tt.req_list);
 	INIT_LIST_HEAD(&bat_priv->tt.roam_list);
+	INIT_HLIST_HEAD(&bat_priv->tvlv.container_list);
+	INIT_HLIST_HEAD(&bat_priv->tvlv.handler_list);
 
 	ret = batadv_originator_init(bat_priv);
 	if (ret < 0)
@@ -408,6 +413,8 @@ static void batadv_recv_handler_init(void)
 	batadv_rx_handler[BATADV_TT_QUERY] = batadv_recv_tt_query;
 	/* Roaming advertisement */
 	batadv_rx_handler[BATADV_ROAM_ADV] = batadv_recv_roam_adv;
+	/* unicast tvlv packet */
+	batadv_rx_handler[BATADV_UNICAST_TVLV] = batadv_recv_unicast_tvlv;
 }
 
 int
@@ -536,6 +543,574 @@ __be32 batadv_skb_crc32(struct sk_buff *skb, u8 *payload_ptr)
 	return htonl(crc);
 }
 
+/**
+ * batadv_tvlv_handler_free_ref - decrement the tvlv handler refcounter and
+ *  possibly free it
+ * @tvlv_handler: the tvlv handler to free
+ */
+static void
+batadv_tvlv_handler_free_ref(struct batadv_tvlv_handler *tvlv_handler)
+{
+	if (atomic_dec_and_test(&tvlv_handler->refcount))
+		kfree_rcu(tvlv_handler, rcu);
+}
+
+/**
+ * batadv_tvlv_handler_get - retrieve tvlv handler from the tvlv handler list
+ *  based on the provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv handler type to look for
+ * @version: tvlv handler version to look for
+ *
+ * Returns tvlv handler if found or NULL otherwise.
+ */
+static struct batadv_tvlv_handler
+*batadv_tvlv_handler_get(struct batadv_priv *bat_priv,
+			 uint8_t type, uint8_t version)
+{
+	struct batadv_tvlv_handler *tvlv_handler_tmp, *tvlv_handler = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tvlv_handler_tmp,
+				 &bat_priv->tvlv.handler_list, list) {
+		if (tvlv_handler_tmp->type != type)
+			continue;
+
+		if (tvlv_handler_tmp->version != version)
+			continue;
+
+		if (!atomic_inc_not_zero(&tvlv_handler_tmp->refcount))
+			continue;
+
+		tvlv_handler = tvlv_handler_tmp;
+		break;
+	}
+	rcu_read_unlock();
+
+	return tvlv_handler;
+}
+
+/**
+ * batadv_tvlv_container_free_ref - decrement the tvlv container refcounter and
+ *  possibly free it
+ * @tvlv_handler: the tvlv container to free
+ */
+static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container *tvlv)
+{
+	if (atomic_dec_and_test(&tvlv->refcount))
+		kfree(tvlv);
+}
+
+/**
+ * batadv_tvlv_container_get - retrieve tvlv container from the tvlv container
+ *  list based on the provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type to look for
+ * @version: tvlv container version to look for
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ *
+ * Returns tvlv container if found or NULL otherwise.
+ */
+static struct batadv_tvlv_container
+*batadv_tvlv_container_get(struct batadv_priv *bat_priv,
+			   uint8_t type, uint8_t version)
+{
+	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
+
+	hlist_for_each_entry(tvlv_tmp, &bat_priv->tvlv.container_list, list) {
+		if (tvlv_tmp->tvlv_hdr.type != type)
+			continue;
+
+		if (tvlv_tmp->tvlv_hdr.version != version)
+			continue;
+
+		if (!atomic_inc_not_zero(&tvlv_tmp->refcount))
+			continue;
+
+		tvlv = tvlv_tmp;
+		break;
+	}
+
+	return tvlv;
+}
+
+/**
+ * batadv_tvlv_container_list_size - calculate the size of the tvlv container
+ *  list entries
+ * @bat_priv: the bat priv with all the soft interface information
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ *
+ * Returns size of all currently registered tvlv containers in bytes.
+ */
+static uint16_t batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
+{
+	struct batadv_tvlv_container *tvlv;
+	uint16_t tvlv_len = 0;
+
+	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
+		tvlv_len += sizeof(struct batadv_tvlv_hdr);
+		tvlv_len += ntohs(tvlv->tvlv_hdr.len);
+	}
+
+	return tvlv_len;
+}
+
+/**
+ * batadv_tvlv_container_remove - remove tvlv container from the tvlv container
+ *  list
+ * @tvlv: the to be removed tvlv container
+ *
+ * Has to be called with the appropriate locks being acquired
+ * (tvlv.container_list_lock).
+ */
+static void batadv_tvlv_container_remove(struct batadv_tvlv_container *tvlv)
+{
+	if (!tvlv)
+		return;
+
+	hlist_del(&tvlv->list);
+
+	/* first call to decrement the counter, second call to free */
+	batadv_tvlv_container_free_ref(tvlv);
+	batadv_tvlv_container_free_ref(tvlv);
+}
+
+/**
+ * batadv_tvlv_container_unregister - unregister tvlv container based on the
+ *  provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type to unregister
+ * @version: tvlv container type to unregister
+ */
+void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
+				      uint8_t type, uint8_t version)
+{
+	struct batadv_tvlv_container *tvlv;
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv = batadv_tvlv_container_get(bat_priv, type, version);
+	batadv_tvlv_container_remove(tvlv);
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+}
+
+/**
+ * batadv_tvlv_container_register - register tvlv type, version and content
+ *  to be propagated with each (primary interface) OGM
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv container type
+ * @version: tvlv container version
+ * @tvlv_value: tvlv container content
+ * @tvlv_value_len: tvlv container content length
+ *
+ * If a container of the same type and version was already registered the new
+ * content is going to replace the old one.
+ */
+void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
+				    uint8_t type, uint8_t version,
+				    void *tvlv_value, uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_container *tvlv_old, *tvlv_new;
+
+	if (!tvlv_value)
+		tvlv_value_len = 0;
+
+	tvlv_new = kzalloc(sizeof(*tvlv_new) + tvlv_value_len, GFP_ATOMIC);
+	if (!tvlv_new)
+		return;
+
+	tvlv_new->tvlv_hdr.version = version;
+	tvlv_new->tvlv_hdr.type = type;
+	tvlv_new->tvlv_hdr.len = htons(tvlv_value_len);
+
+	memcpy(tvlv_new + 1, tvlv_value, ntohs(tvlv_new->tvlv_hdr.len));
+	INIT_HLIST_NODE(&tvlv_new->list);
+	atomic_set(&tvlv_new->refcount, 1);
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv_old = batadv_tvlv_container_get(bat_priv, type, version);
+	batadv_tvlv_container_remove(tvlv_old);
+	hlist_add_head(&tvlv_new->list, &bat_priv->tvlv.container_list);
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+}
+
+/**
+ * batadv_tvlv_realloc_packet_buff - reallocate packet buffer to accomodate
+ *  requested packet size
+ * @packet_buff: packet buffer
+ * @packet_buff_len: packet buffer size
+ * @packet_min_len: requested packet minimum size
+ * @additional_packet_len: requested additional packet size on top of minimum
+ *  size
+ *
+ * Returns true of the packet buffer could be changed to the requested size,
+ * false otherwise.
+ */
+static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
+					    int *packet_buff_len,
+					    int min_packet_len,
+					    int additional_packet_len)
+{
+	unsigned char *new_buff;
+
+	new_buff = kmalloc(min_packet_len + additional_packet_len, GFP_ATOMIC);
+
+	/* keep old buffer if kmalloc should fail */
+	if (new_buff) {
+		memcpy(new_buff, *packet_buff, min_packet_len);
+		kfree(*packet_buff);
+		*packet_buff = new_buff;
+		*packet_buff_len = min_packet_len + additional_packet_len;
+		return true;
+	}
+
+	return false;
+}
+
+/**
+ * batadv_tvlv_container_ogm_append - append tvlv container content to given
+ *  OGM packet buffer
+ * @bat_priv: the bat priv with all the soft interface information
+ * @packet_buff: ogm packet buffer
+ * @packet_buff_len: ogm packet buffer size including ogm header and tvlv
+ *  content
+ * @packet_min_len: ogm header size to be preserved for the OGM itself
+ *
+ * The ogm packet might be enlarged or shrunk depending on the current size
+ * and the size of the to-be-appended tvlv containers.
+ *
+ * Returns size of all appended tvlv containers in bytes.
+ */
+uint16_t batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+					  unsigned char **packet_buff,
+					  int *packet_buff_len,
+					  int packet_min_len)
+{
+	struct batadv_tvlv_container *tvlv;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	uint16_t tvlv_value_len;
+	void *tvlv_value;
+	bool ret;
+
+	spin_lock_bh(&bat_priv->tvlv.container_list_lock);
+	tvlv_value_len = batadv_tvlv_container_list_size(bat_priv);
+
+	ret = batadv_tvlv_realloc_packet_buff(packet_buff, packet_buff_len,
+					      packet_min_len, tvlv_value_len);
+
+	if (!ret)
+		goto end;
+
+	if (!tvlv_value_len)
+		goto end;
+
+	tvlv_value = (*packet_buff) + packet_min_len;
+
+	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
+		tvlv_hdr = tvlv_value;
+		tvlv_hdr->type = tvlv->tvlv_hdr.type;
+		tvlv_hdr->version = tvlv->tvlv_hdr.version;
+		tvlv_hdr->len = tvlv->tvlv_hdr.len;
+		tvlv_value = tvlv_hdr + 1;
+		memcpy(tvlv_value, tvlv + 1, ntohs(tvlv->tvlv_hdr.len));
+		tvlv_value = (uint8_t *)tvlv_value + ntohs(tvlv->tvlv_hdr.len);
+	}
+
+end:
+	spin_unlock_bh(&bat_priv->tvlv.container_list_lock);
+	return tvlv_value_len;
+}
+
+/**
+ * batadv_tvlv_call_handler - parse the given tvlv buffer to call the
+ *  appropriate handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @tvlv_handler: tvlv callback function handling the tvlv content
+ * @ogm_source: flag indicating wether the tvlv is an ogm or a unicast packet
+ * @orig_node: orig node emitting the ogm packet
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ *
+ * Returns success if handler was not found or the return value of the handler
+ * callback.
+ */
+static int batadv_tvlv_call_handler(struct batadv_priv *bat_priv,
+				    struct batadv_tvlv_handler *tvlv_handler,
+				    bool ogm_source,
+				    struct batadv_orig_node *orig_node,
+				    uint8_t *src, uint8_t *dst,
+				    void *tvlv_value, uint16_t tvlv_value_len)
+{
+	if (!tvlv_handler)
+		return NET_RX_SUCCESS;
+
+	if (ogm_source) {
+		if (!tvlv_handler->ogm_handler)
+			return NET_RX_SUCCESS;
+
+		if (!orig_node)
+			return NET_RX_SUCCESS;
+
+		tvlv_handler->ogm_handler(bat_priv, orig_node,
+					  BATADV_NO_FLAGS,
+					  tvlv_value, tvlv_value_len);
+		tvlv_handler->flags |= BATADV_TVLV_HANDLER_OGM_CALLED;
+	} else {
+		if (!src)
+			return NET_RX_SUCCESS;
+
+		if (!dst)
+			return NET_RX_SUCCESS;
+
+		if (!tvlv_handler->unicast_handler)
+			return NET_RX_SUCCESS;
+
+		return tvlv_handler->unicast_handler(bat_priv, src,
+						     dst, tvlv_value,
+						     tvlv_value_len);
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * batadv_tvlv_containers_process - parse the given tvlv buffer to call the
+ *  appropriate handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @ogm_source: flag indicating wether the tvlv is an ogm or a unicast packet
+ * @orig_node: orig node emitting the ogm packet
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ *
+ * Returns success when processing an OGM or the return value of all called
+ * handler callbacks.
+ */
+int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
+				   bool ogm_source,
+				   struct batadv_orig_node *orig_node,
+				   uint8_t *src, uint8_t *dst,
+				   void *tvlv_value, uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	uint16_t tvlv_value_cont_len;
+	uint8_t cifnotfound = BATADV_TVLV_HANDLER_OGM_CIFNOTFND;
+	int ret = NET_RX_SUCCESS;
+
+	while (tvlv_value_len >= sizeof(*tvlv_hdr)) {
+		tvlv_hdr = tvlv_value;
+		tvlv_value_cont_len = ntohs(tvlv_hdr->len);
+		tvlv_value = tvlv_hdr + 1;
+		tvlv_value_len -= sizeof(*tvlv_hdr);
+
+		if (tvlv_value_cont_len > tvlv_value_len)
+			break;
+
+		tvlv_handler = batadv_tvlv_handler_get(bat_priv,
+						       tvlv_hdr->type,
+						       tvlv_hdr->version);
+
+		ret |= batadv_tvlv_call_handler(bat_priv, tvlv_handler,
+						ogm_source, orig_node,
+						src, dst, tvlv_value,
+						tvlv_value_cont_len);
+		if (tvlv_handler)
+			batadv_tvlv_handler_free_ref(tvlv_handler);
+		tvlv_value = (uint8_t *)tvlv_value + tvlv_value_cont_len;
+		tvlv_value_len -= tvlv_value_cont_len;
+	}
+
+	if (!ogm_source)
+		return ret;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(tvlv_handler,
+				 &bat_priv->tvlv.handler_list, list) {
+		if ((tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND) &&
+		    !(tvlv_handler->flags & BATADV_TVLV_HANDLER_OGM_CALLED))
+			tvlv_handler->ogm_handler(bat_priv, orig_node,
+						  cifnotfound, NULL, 0);
+
+		tvlv_handler->flags &= ~BATADV_TVLV_HANDLER_OGM_CALLED;
+	}
+	rcu_read_unlock();
+
+	return NET_RX_SUCCESS;
+}
+
+/**
+ * batadv_tvlv_ogm_receive - process an incoming ogm and call the appropriate
+ *  handlers
+ * @bat_priv: the bat priv with all the soft interface information
+ * @batadv_ogm_packet: ogm packet containing the tvlv containers
+ * @orig_node: orig node emitting the ogm packet
+ */
+void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
+			     struct batadv_ogm_packet *batadv_ogm_packet,
+			     struct batadv_orig_node *orig_node)
+{
+	void *tvlv_value;
+	uint16_t tvlv_value_len;
+
+	if (!batadv_ogm_packet)
+		return;
+
+	tvlv_value_len = ntohs(batadv_ogm_packet->tvlv_len);
+	if (!tvlv_value_len)
+		return;
+
+	tvlv_value = batadv_ogm_packet + 1;
+
+	batadv_tvlv_containers_process(bat_priv, true, orig_node, NULL, NULL,
+				       tvlv_value, tvlv_value_len);
+}
+
+/**
+ * batadv_tvlv_handler_register - register tvlv handler based on the provided
+ *  type and version (both need to match) for ogm tvlv payload and/or unicast
+ *  payload
+ * @bat_priv: the bat priv with all the soft interface information
+ * @optr: ogm tvlv handler callback function. This function receives the orig
+ *  node, flags and the tvlv content as argument to process.
+ * @uptr: unicast tvlv handler callback function. This function receives the
+ *  source & destination of the unicast packet as well as the tvlv content
+ *  to process.
+ * @type: tvlv handler type to be registered
+ * @version: tvlv handler version to be registered
+ * @flags: flags to enable or disable TVLV API behavior
+ */
+void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
+				  void (*optr)(struct batadv_priv *bat_priv,
+					       struct batadv_orig_node *orig,
+					       uint8_t flags,
+					       void *tvlv_value,
+					       uint16_t tvlv_value_len),
+				  int (*uptr)(struct batadv_priv *bat_priv,
+					      uint8_t *src, uint8_t *dst,
+					      void *tvlv_value,
+					      uint16_t tvlv_value_len),
+				  uint8_t type, uint8_t version, uint8_t flags)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
+	if (tvlv_handler) {
+		batadv_tvlv_handler_free_ref(tvlv_handler);
+		return;
+	}
+
+	tvlv_handler = kzalloc(sizeof(*tvlv_handler), GFP_ATOMIC);
+	if (!tvlv_handler)
+		return;
+
+	tvlv_handler->ogm_handler = optr;
+	tvlv_handler->unicast_handler = uptr;
+	tvlv_handler->type = type;
+	tvlv_handler->version = version;
+	tvlv_handler->flags = flags;
+	atomic_set(&tvlv_handler->refcount, 1);
+	INIT_HLIST_NODE(&tvlv_handler->list);
+
+	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
+	hlist_add_head_rcu(&tvlv_handler->list, &bat_priv->tvlv.handler_list);
+	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
+}
+
+/**
+ * batadv_tvlv_handler_unregister - unregister tvlv handler based on the
+ *  provided type and version (both need to match)
+ * @bat_priv: the bat priv with all the soft interface information
+ * @type: tvlv handler type to be unregistered
+ * @version: tvlv handler version to be unregistered
+ */
+void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
+				    uint8_t type, uint8_t version)
+{
+	struct batadv_tvlv_handler *tvlv_handler;
+
+	tvlv_handler = batadv_tvlv_handler_get(bat_priv, type, version);
+	if (!tvlv_handler)
+		return;
+
+	batadv_tvlv_handler_free_ref(tvlv_handler);
+	spin_lock_bh(&bat_priv->tvlv.handler_list_lock);
+	hlist_del_rcu(&tvlv_handler->list);
+	spin_unlock_bh(&bat_priv->tvlv.handler_list_lock);
+	batadv_tvlv_handler_free_ref(tvlv_handler);
+}
+
+/**
+ * batadv_tvlv_unicast_send - send a unicast packet with tvlv payload to the
+ *  specified host
+ * @bat_priv: the bat priv with all the soft interface information
+ * @src: source mac address of the unicast packet
+ * @dst: destination mac address of the unicast packet
+ * @type: tvlv type
+ * @version: tvlv version
+ * @tvlv_value: tvlv content
+ * @tvlv_value_len: tvlv content length
+ */
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
+			      uint8_t *dst, uint8_t type, uint8_t version,
+			      void *tvlv_value, uint16_t tvlv_value_len)
+{
+	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
+	struct batadv_tvlv_hdr *tvlv_hdr;
+	struct batadv_orig_node *orig_node;
+	struct sk_buff *skb = NULL;
+	unsigned char *tvlv_buff;
+	unsigned int tvlv_len;
+	ssize_t hdr_len = sizeof(*unicast_tvlv_packet);
+	bool ret = false;
+
+	orig_node = batadv_orig_hash_find(bat_priv, dst);
+	if (!orig_node)
+		goto out;
+
+	tvlv_len = sizeof(*tvlv_hdr) + tvlv_value_len;
+
+	skb = netdev_alloc_skb_ip_align(NULL, ETH_HLEN + hdr_len + tvlv_len);
+	if (!skb)
+		goto out;
+
+	skb->priority = TC_PRIO_CONTROL;
+	skb_reserve(skb, ETH_HLEN);
+	tvlv_buff = skb_put(skb, sizeof(*unicast_tvlv_packet) + tvlv_len);
+	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)tvlv_buff;
+	unicast_tvlv_packet->header.packet_type = BATADV_UNICAST_TVLV;
+	unicast_tvlv_packet->header.version = BATADV_COMPAT_VERSION;
+	unicast_tvlv_packet->header.ttl = BATADV_TTL;
+	unicast_tvlv_packet->reserved = 0;
+	unicast_tvlv_packet->tvlv_len = htons(tvlv_len);
+	unicast_tvlv_packet->align = 0;
+	memcpy(unicast_tvlv_packet->src, src, ETH_ALEN);
+	memcpy(unicast_tvlv_packet->dst, dst, ETH_ALEN);
+
+	tvlv_buff = (unsigned char *)(unicast_tvlv_packet + 1);
+	tvlv_hdr = (struct batadv_tvlv_hdr *)tvlv_buff;
+	tvlv_hdr->version = version;
+	tvlv_hdr->type = type;
+	tvlv_hdr->len = htons(tvlv_value_len);
+	tvlv_buff += sizeof(*tvlv_hdr);
+	memcpy(tvlv_buff, tvlv_value, tvlv_value_len);
+
+	if (batadv_send_skb_to_orig(skb, orig_node, NULL) != NET_XMIT_DROP)
+		ret = true;
+
+out:
+	if (skb && !ret)
+		kfree_skb(skb);
+	if (orig_node)
+		batadv_orig_node_free_ref(orig_node);
+}
+
 static int batadv_param_set_ra(const char *val, const struct kernel_param *kp)
 {
 	struct batadv_algo_ops *bat_algo_ops;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2467552..397722f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -326,4 +326,39 @@ static inline uint64_t batadv_sum_counter(struct batadv_priv *bat_priv,
  */
 #define BATADV_SKB_CB(__skb)       ((struct batadv_skb_cb *)&((__skb)->cb[0]))
 
+void batadv_tvlv_container_register(struct batadv_priv *bat_priv,
+				    uint8_t type, uint8_t version,
+				    void *tvlv_value, uint16_t tvlv_value_len);
+uint16_t batadv_tvlv_container_ogm_append(struct batadv_priv *bat_priv,
+					  unsigned char **packet_buff,
+					  int *packet_buff_len,
+					  int packet_min_len);
+void batadv_tvlv_ogm_receive(struct batadv_priv *bat_priv,
+			     struct batadv_ogm_packet *batadv_ogm_packet,
+			     struct batadv_orig_node *orig_node);
+void batadv_tvlv_container_unregister(struct batadv_priv *bat_priv,
+				      uint8_t type, uint8_t version);
+
+void batadv_tvlv_handler_register(struct batadv_priv *bat_priv,
+				  void (*optr)(struct batadv_priv *bat_priv,
+					       struct batadv_orig_node *orig,
+					       uint8_t flags,
+					       void *tvlv_value,
+					       uint16_t tvlv_value_len),
+				  int (*uptr)(struct batadv_priv *bat_priv,
+					      uint8_t *src, uint8_t *dst,
+					      void *tvlv_value,
+					      uint16_t tvlv_value_len),
+				  uint8_t type, uint8_t version, uint8_t flags);
+void batadv_tvlv_handler_unregister(struct batadv_priv *bat_priv,
+				    uint8_t type, uint8_t version);
+int batadv_tvlv_containers_process(struct batadv_priv *bat_priv,
+				   bool ogm_source,
+				   struct batadv_orig_node *orig_node,
+				   uint8_t *src, uint8_t *dst,
+				   void *tvlv_buff, uint16_t tvlv_buff_len);
+void batadv_tvlv_unicast_send(struct batadv_priv *bat_priv, uint8_t *src,
+			      uint8_t *dst, uint8_t type, uint8_t version,
+			      void *tvlv_value, uint16_t tvlv_value_len);
+
 #endif /* _NET_BATMAN_ADV_MAIN_H_ */
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 11a22c8..b5c21c4 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -20,6 +20,10 @@
 #ifndef _NET_BATMAN_ADV_PACKET_H_
 #define _NET_BATMAN_ADV_PACKET_H_
 
+/**
+ * enum batadv_packettype - types for batman-adv encapsulated packets
+ * @BATADV_UNICAST_TVLV: unicast packet carrying TVLV containers
+ */
 enum batadv_packettype {
 	BATADV_IV_OGM		= 0x01,
 	BATADV_ICMP		= 0x02,
@@ -31,6 +35,7 @@ enum batadv_packettype {
 	BATADV_ROAM_ADV		= 0x08,
 	BATADV_UNICAST_4ADDR	= 0x09,
 	BATADV_CODED		= 0x0a,
+	BATADV_UNICAST_TVLV	= 0x0b,
 };
 
 /**
@@ -131,6 +136,11 @@ struct batadv_header {
 	 */
 };
 
+/**
+ * struct batadv_ogm_packet - ogm (routing protocol) packet
+ * @header: common batman packet header
+ * @tvlv_len: length of tvlv data following the ogm header
+ */
 struct batadv_ogm_packet {
 	struct batadv_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
@@ -142,6 +152,7 @@ struct batadv_ogm_packet {
 	uint8_t  tt_num_changes;
 	uint8_t  ttvn; /* translation table version number */
 	__be16   tt_crc;
+	__be16   tvlv_len;
 } __packed;
 
 #define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
@@ -311,4 +322,34 @@ struct batadv_coded_packet {
 	__be16   coded_len;
 };
 
+/**
+ * struct batadv_unicast_tvlv - generic unicast packet with tvlv payload
+ * @header: common batman packet header
+ * @reserved: reserved field (for packet alignment)
+ * @src: address of the source
+ * @dst: address of the destination
+ * @tvlv_len: length of tvlv data following the unicast tvlv header
+ * @align: 2 bytes to align the header to a 4 byte boundry
+ */
+struct batadv_unicast_tvlv_packet {
+	struct batadv_header header;
+	uint8_t  reserved;
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  src[ETH_ALEN];
+	__be16   tvlv_len;
+	uint16_t align;
+};
+
+/**
+ * struct batadv_tvlv_hdr - base tvlv header struct
+ * @type: tvlv container type (see batadv_tvlv_type)
+ * @version: tvlv container version
+ * @len: tvlv container length
+ */
+struct batadv_tvlv_hdr {
+	uint8_t type;
+	uint8_t version;
+	__be16  len;
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 0439395..9640656 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -1139,6 +1139,54 @@ rx_success:
 	return batadv_route_unicast_packet(skb, recv_if);
 }
 
+/**
+ * batadv_recv_unicast_tvlv - receive and process unicast tvlv packets
+ * @skb: unicast tvlv packet to process
+ * @recv_if: pointer to interface this packet was received on
+ * @dst_addr: the payload destination
+ *
+ * Returns NET_RX_SUCCESS if the packet has been consumed or NET_RX_DROP
+ * otherwise.
+ */
+int batadv_recv_unicast_tvlv(struct sk_buff *skb,
+			     struct batadv_hard_iface *recv_if)
+{
+	struct batadv_priv *bat_priv = netdev_priv(recv_if->soft_iface);
+	struct batadv_unicast_tvlv_packet *unicast_tvlv_packet;
+	unsigned char *tvlv_buff;
+	uint16_t tvlv_buff_len;
+	int hdr_size = sizeof(*unicast_tvlv_packet);
+	int ret = NET_RX_DROP;
+
+	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	/* the header is likely to be modified while forwarding */
+	if (skb_cow(skb, hdr_size) < 0)
+		return NET_RX_DROP;
+
+	/* packet needs to be linearized to access the tvlv content */
+	if (skb_linearize(skb) < 0)
+		return NET_RX_DROP;
+
+	unicast_tvlv_packet = (struct batadv_unicast_tvlv_packet *)skb->data;
+
+	tvlv_buff = (unsigned char *)(skb->data + hdr_size);
+	tvlv_buff_len = ntohs(unicast_tvlv_packet->tvlv_len);
+
+	if (tvlv_buff_len > skb->len - hdr_size)
+		return NET_RX_DROP;
+
+	ret = batadv_tvlv_containers_process(bat_priv, false, NULL,
+					     unicast_tvlv_packet->src,
+					     unicast_tvlv_packet->dst,
+					     tvlv_buff, tvlv_buff_len);
+
+	if (ret != NET_RX_SUCCESS)
+		ret = batadv_route_unicast_packet(skb, recv_if);
+
+	return ret;
+}
 
 int batadv_recv_bcast_packet(struct sk_buff *skb,
 			     struct batadv_hard_iface *recv_if)
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 72a29bd..0a7983b 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -40,6 +40,8 @@ int batadv_recv_tt_query(struct sk_buff *skb,
 			 struct batadv_hard_iface *recv_if);
 int batadv_recv_roam_adv(struct sk_buff *skb,
 			 struct batadv_hard_iface *recv_if);
+int batadv_recv_unicast_tvlv(struct sk_buff *skb,
+			     struct batadv_hard_iface *recv_if);
 struct batadv_neigh_node *
 batadv_find_router(struct batadv_priv *bat_priv,
 		   struct batadv_orig_node *orig_node,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b2c94e1..4bdea16 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -430,6 +430,20 @@ struct batadv_priv_gw {
 };
 
 /**
+ * struct batadv_priv_tvlv - per mesh interface tvlv data
+ * @container_list: list of registered tvlv containers to be sent with each OGM
+ * @handler_list: list of the various tvlv content handlers
+ * @container_list_lock: protects tvlv container list access
+ * @handler_list_lock: protects handler list access
+ */
+struct batadv_priv_tvlv {
+	struct hlist_head container_list;
+	struct hlist_head handler_list;
+	spinlock_t container_list_lock; /* protects container_list */
+	spinlock_t handler_list_lock; /* protects handler_list */
+};
+
+/**
  * struct batadv_priv_vis - per mesh interface vis data
  * @send_list: list of batadv_vis_info packets to sent
  * @hash: hash table containing vis data from other nodes in the network
@@ -531,6 +545,7 @@ struct batadv_priv_nc {
  * @debug_log: holding debug logging relevant data
  * @gw: gateway data
  * @tt: translation table data
+ * @tvlv: type-version-length-value data
  * @vis: vis data
  * @dat: distributed arp table data
  * @network_coding: bool indicating whether network coding is enabled
@@ -583,6 +598,7 @@ struct batadv_priv {
 #endif
 	struct batadv_priv_gw gw;
 	struct batadv_priv_tt tt;
+	struct batadv_priv_tvlv tvlv;
 	struct batadv_priv_vis vis;
 #ifdef CONFIG_BATMAN_ADV_DAT
 	struct batadv_priv_dat dat;
@@ -992,4 +1008,60 @@ struct batadv_dat_candidate {
 	struct batadv_orig_node *orig_node;
 };
 
+/**
+ * struct batadv_tvlv_container - container for tvlv appended to OGMs
+ * @list: hlist node for batadv_priv_tvlv::container_list
+ * @tvlv_hdr: tvlv header information needed to construct the tvlv
+ * @value_len: length of the buffer following this struct which contains
+ *  the actual tvlv payload
+ * @refcount: number of contexts the object is used
+ */
+struct batadv_tvlv_container {
+	struct hlist_node list;
+	struct batadv_tvlv_hdr tvlv_hdr;
+	atomic_t refcount;
+};
+
+/**
+ * struct batadv_tvlv_handler - handler for specific tvlv type and version
+ * @list: hlist node for batadv_priv_tvlv::handler_list
+ * @ogm_handler: handler callback which is given the tvlv payload to process on
+ *  incoming OGM packets
+ * @unicast_handler: handler callback which is given the tvlv payload to process
+ *  on incoming unicast tvlv packets
+ * @type: tvlv type this handler feels responsible for
+ * @version: tvlv version this handler feels responsible for
+ * @flags: tvlv handler flags
+ * @refcount: number of contexts the object is used
+ * @rcu: struct used for freeing in an RCU-safe manner
+ */
+struct batadv_tvlv_handler {
+	struct hlist_node list;
+	void (*ogm_handler)(struct batadv_priv *bat_priv,
+			    struct batadv_orig_node *orig,
+			    uint8_t flags,
+			    void *tvlv_value, uint16_t tvlv_value_len);
+	int (*unicast_handler)(struct batadv_priv *bat_priv,
+			       uint8_t *src, uint8_t *dst,
+			       void *tvlv_value, uint16_t tvlv_value_len);
+	uint8_t type;
+	uint8_t version;
+	uint8_t flags;
+	atomic_t refcount;
+	struct rcu_head rcu;
+};
+
+/**
+ * enum batadv_tvlv_handler_flags - tvlv handler flags definitions
+ * @BATADV_TVLV_HANDLER_OGM_CIFNOTFND: tvlv ogm processing function will call
+ *  this handler even if its type was not found (with no data)
+ * @BATADV_TVLV_HANDLER_OGM_CALLED: interval tvlv handling flag - the API marks
+ *  a handler as being called, so it won't be called if the
+ *  BATADV_TVLV_HANDLER_OGM_CIFNOTFND flag was set
+ */
+enum batadv_tvlv_handler_flags {
+	BATADV_TVLV_HANDLER_OGM_CIFNOTFND = BIT(1),
+	BATADV_TVLV_HANDLER_OGM_CALLED = BIT(2),
+};
+
 #endif /* _NET_BATMAN_ADV_TYPES_H_ */
-- 
1.8.3.2
