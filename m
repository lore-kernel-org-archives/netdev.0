From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/16] batman-adv: tvlv - gateway download/upload bandwidth container
Date: Wed,  9 Oct 2013 21:32:42 +0200
Message-ID: <1381347174-3629-5-git-send-email-antonio@meshcoding.com>
References: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Spyros Gasteratos <morfeas3000@gmail.com>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:15221 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753980Ab3JITdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:33:37 -0400
In-Reply-To: <1381347174-3629-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Prior to this patch batman-adv read the advertised uplink bandwidth
from userspace and compressed this information into a single byte
called "gateway class".
Now the download & upload bandwidth information is sent as-is. No
userspace change is necessary since the sysfs API always allowed
to specify a bandwidth.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Spyros Gasteratos <morfeas3000@gmail.com>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c     |  23 +---
 net/batman-adv/gateway_client.c | 197 +++++++++++++++++++++-------------
 net/batman-adv/gateway_client.h |   2 +-
 net/batman-adv/gateway_common.c | 230 +++++++++++++++++++++++++---------------
 net/batman-adv/gateway_common.h |  14 ++-
 net/batman-adv/main.c           |   5 +
 net/batman-adv/originator.c     |   4 +-
 net/batman-adv/packet.h         |  21 +++-
 net/batman-adv/soft-interface.c |   3 +-
 net/batman-adv/sysfs.c          |  15 ++-
 net/batman-adv/types.h          |  12 ++-
 11 files changed, 331 insertions(+), 195 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index f7dd7e5..f0f02d1 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -135,6 +135,7 @@ static int batadv_iv_ogm_iface_enable(struct batadv_hard_iface *hard_iface)
 	batadv_ogm_packet->header.version = BATADV_COMPAT_VERSION;
 	batadv_ogm_packet->header.ttl = 2;
 	batadv_ogm_packet->flags = BATADV_NO_FLAGS;
+	batadv_ogm_packet->reserved = 0;
 	batadv_ogm_packet->tq = BATADV_TQ_MAX_VALUE;
 	batadv_ogm_packet->tt_num_changes = 0;
 	batadv_ogm_packet->ttvn = 0;
@@ -690,7 +691,6 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	int *ogm_buff_len = &hard_iface->bat_iv.ogm_buff_len;
 	int vis_server, tt_num_changes = 0;
 	uint32_t seqno;
-	uint8_t bandwidth;
 	uint16_t tvlv_len = 0;
 
 	vis_server = atomic_read(&bat_priv->vis_mode);
@@ -719,14 +719,6 @@ static void batadv_iv_ogm_schedule(struct batadv_hard_iface *hard_iface)
 	else
 		batadv_ogm_packet->flags &= ~BATADV_VIS_SERVER;
 
-	if (hard_iface == primary_if &&
-	    atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_SERVER) {
-		bandwidth = (uint8_t)atomic_read(&bat_priv->gw_bandwidth);
-		batadv_ogm_packet->gw_flags = bandwidth;
-	} else {
-		batadv_ogm_packet->gw_flags = BATADV_NO_FLAGS;
-	}
-
 	batadv_iv_ogm_slide_own_bcast_window(hard_iface);
 	batadv_iv_ogm_queue_add(bat_priv, hard_iface->bat_iv.ogm_buff,
 				hard_iface->bat_iv.ogm_buff_len, hard_iface, 1,
@@ -861,19 +853,6 @@ update_tt:
 				      batadv_ogm_packet->tt_num_changes,
 				      batadv_ogm_packet->ttvn,
 				      ntohs(batadv_ogm_packet->tt_crc));
-
-	if (orig_node->gw_flags != batadv_ogm_packet->gw_flags)
-		batadv_gw_node_update(bat_priv, orig_node,
-				      batadv_ogm_packet->gw_flags);
-
-	orig_node->gw_flags = batadv_ogm_packet->gw_flags;
-
-	/* restart gateway selection if fast or late switching was enabled */
-	if ((orig_node->gw_flags) &&
-	    (atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_CLIENT) &&
-	    (atomic_read(&bat_priv->gw_sel_class) > 2))
-		batadv_gw_check_election(bat_priv, orig_node);
-
 	goto out;
 
 unlock:
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 1ce4b87..1bce63a 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -118,7 +118,6 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
 	uint32_t gw_divisor;
 	uint8_t max_tq = 0;
-	int down, up;
 	uint8_t tq_avg;
 	struct batadv_orig_node *orig_node;
 
@@ -142,10 +141,9 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
-			batadv_gw_bandwidth_to_kbit(orig_node->gw_flags,
-						    &down, &up);
-
-			tmp_gw_factor = tq_avg * tq_avg * down * 100 * 100;
+			tmp_gw_factor = tq_avg * tq_avg;
+			tmp_gw_factor *= gw_node->bandwidth_down;
+			tmp_gw_factor *= 100 * 100;
 			tmp_gw_factor /= gw_divisor;
 
 			if ((tmp_gw_factor > max_gw_factor) ||
@@ -258,16 +256,22 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 				    NULL);
 	} else if ((!curr_gw) && (next_gw)) {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Adding route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			   "Adding route to gateway %pM (bandwidth: %u.%u/%u.%u MBit, tq: %i)\n",
 			   next_gw->orig_node->orig,
-			   next_gw->orig_node->gw_flags, router->tq_avg);
+			   next_gw->bandwidth_down / 10,
+			   next_gw->bandwidth_down % 10,
+			   next_gw->bandwidth_up / 10,
+			   next_gw->bandwidth_up % 10, router->tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_ADD,
 				    gw_addr);
 	} else {
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Changing route to gateway %pM (gw_flags: %i, tq: %i)\n",
+			   "Changing route to gateway %pM (bandwidth: %u.%u/%u.%u MBit, tq: %i)\n",
 			   next_gw->orig_node->orig,
-			   next_gw->orig_node->gw_flags, router->tq_avg);
+			   next_gw->bandwidth_down / 10,
+			   next_gw->bandwidth_down % 10,
+			   next_gw->bandwidth_up / 10,
+			   next_gw->bandwidth_up % 10, router->tq_avg);
 		batadv_throw_uevent(bat_priv, BATADV_UEV_GW, BATADV_UEV_CHANGE,
 				    gw_addr);
 	}
@@ -337,12 +341,20 @@ out:
 	return;
 }
 
+/**
+ * batadv_gw_node_add - add gateway node to list of available gateways
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: originator announcing gateway capabilities
+ * @gateway: announced bandwidth information
+ */
 static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 			       struct batadv_orig_node *orig_node,
-			       uint8_t new_gwflags)
+			       struct batadv_tvlv_gateway_data *gateway)
 {
 	struct batadv_gw_node *gw_node;
-	int down, up;
+
+	if (gateway->bandwidth_down == 0)
+		return;
 
 	gw_node = kzalloc(sizeof(*gw_node), GFP_ATOMIC);
 	if (!gw_node)
@@ -356,73 +368,116 @@ static void batadv_gw_node_add(struct batadv_priv *bat_priv,
 	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw.list);
 	spin_unlock_bh(&bat_priv->gw.list_lock);
 
-	batadv_gw_bandwidth_to_kbit(new_gwflags, &down, &up);
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
-		   orig_node->orig, new_gwflags,
-		   (down > 2048 ? down / 1024 : down),
-		   (down > 2048 ? "MBit" : "KBit"),
-		   (up > 2048 ? up / 1024 : up),
-		   (up > 2048 ? "MBit" : "KBit"));
+		   "Found new gateway %pM -> gw bandwidth: %u.%u/%u.%u MBit\n",
+		   orig_node->orig,
+		   ntohl(gateway->bandwidth_down) / 10,
+		   ntohl(gateway->bandwidth_down) % 10,
+		   ntohl(gateway->bandwidth_up) / 10,
+		   ntohl(gateway->bandwidth_up) % 10);
 }
 
+/**
+ * batadv_gw_node_get - retrieve gateway node from list of available gateways
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: originator announcing gateway capabilities
+ *
+ * Returns gateway node if found or NULL otherwise.
+ */
+static struct batadv_gw_node *
+batadv_gw_node_get(struct batadv_priv *bat_priv,
+		   struct batadv_orig_node *orig_node)
+{
+	struct batadv_gw_node *gw_node_tmp, *gw_node = NULL;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(gw_node_tmp, &bat_priv->gw.list, list) {
+		if (gw_node_tmp->orig_node != orig_node)
+			continue;
+
+		if (gw_node_tmp->deleted)
+			continue;
+
+		if (!atomic_inc_not_zero(&gw_node_tmp->refcount))
+			continue;
+
+		gw_node = gw_node_tmp;
+		break;
+	}
+	rcu_read_unlock();
+
+	return gw_node;
+}
+
+/**
+ * batadv_gw_node_update - update list of available gateways with changed
+ *  bandwidth information
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig_node: originator announcing gateway capabilities
+ * @gateway: announced bandwidth information
+ */
 void batadv_gw_node_update(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node,
-			   uint8_t new_gwflags)
+			   struct batadv_tvlv_gateway_data *gateway)
 {
-	struct batadv_gw_node *gw_node, *curr_gw;
+	struct batadv_gw_node *gw_node, *curr_gw = NULL;
 
-	/* Note: We don't need a NULL check here, since curr_gw never gets
-	 * dereferenced. If curr_gw is NULL we also should not exit as we may
-	 * have this gateway in our list (duplication check!) even though we
-	 * have no currently selected gateway.
-	 */
-	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
+	gw_node = batadv_gw_node_get(bat_priv, orig_node);
+	if (!gw_node) {
+		batadv_gw_node_add(bat_priv, orig_node, gateway);
+		goto out;
+	}
 
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(gw_node, &bat_priv->gw.list, list) {
-		if (gw_node->orig_node != orig_node)
-			continue;
+	if ((gw_node->bandwidth_down == ntohl(gateway->bandwidth_down)) &&
+	    (gw_node->bandwidth_up == ntohl(gateway->bandwidth_up)))
+		goto out;
 
+	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
+		   "Gateway bandwidth of originator %pM changed from %u.%u/%u.%u MBit to %u.%u/%u.%u MBit\n",
+		   orig_node->orig,
+		   gw_node->bandwidth_down / 10,
+		   gw_node->bandwidth_down % 10,
+		   gw_node->bandwidth_up / 10,
+		   gw_node->bandwidth_up % 10,
+		   ntohl(gateway->bandwidth_down) / 10,
+		   ntohl(gateway->bandwidth_down) % 10,
+		   ntohl(gateway->bandwidth_up) / 10,
+		   ntohl(gateway->bandwidth_up) % 10);
+
+	gw_node->bandwidth_down = ntohl(gateway->bandwidth_down);
+	gw_node->bandwidth_up = ntohl(gateway->bandwidth_up);
+
+	gw_node->deleted = 0;
+	if (ntohl(gateway->bandwidth_down) == 0) {
+		gw_node->deleted = jiffies;
 		batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-			   "Gateway class of originator %pM changed from %i to %i\n",
-			   orig_node->orig, gw_node->orig_node->gw_flags,
-			   new_gwflags);
-
-		gw_node->deleted = 0;
-
-		if (new_gwflags == BATADV_NO_FLAGS) {
-			gw_node->deleted = jiffies;
-			batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-				   "Gateway %pM removed from gateway list\n",
-				   orig_node->orig);
-
-			if (gw_node == curr_gw)
-				goto deselect;
-		}
-
-		goto unlock;
+			   "Gateway %pM removed from gateway list\n",
+			   orig_node->orig);
+
+		/* Note: We don't need a NULL check here, since curr_gw never
+		 * gets dereferenced.
+		 */
+		curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
+		if (gw_node == curr_gw)
+			batadv_gw_deselect(bat_priv);
 	}
 
-	if (new_gwflags == BATADV_NO_FLAGS)
-		goto unlock;
-
-	batadv_gw_node_add(bat_priv, orig_node, new_gwflags);
-	goto unlock;
-
-deselect:
-	batadv_gw_deselect(bat_priv);
-unlock:
-	rcu_read_unlock();
-
+out:
 	if (curr_gw)
 		batadv_gw_node_free_ref(curr_gw);
+	if (gw_node)
+		batadv_gw_node_free_ref(gw_node);
 }
 
 void batadv_gw_node_delete(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node)
 {
-	batadv_gw_node_update(bat_priv, orig_node, 0);
+	struct batadv_tvlv_gateway_data gateway;
+
+	gateway.bandwidth_down = 0;
+	gateway.bandwidth_up = 0;
+
+	batadv_gw_node_update(bat_priv, orig_node, &gateway);
 }
 
 void batadv_gw_node_purge(struct batadv_priv *bat_priv)
@@ -467,9 +522,7 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 {
 	struct batadv_gw_node *curr_gw;
 	struct batadv_neigh_node *router;
-	int down, up, ret = -1;
-
-	batadv_gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
+	int ret = -1;
 
 	router = batadv_orig_node_get_router(gw_node->orig_node);
 	if (!router)
@@ -477,16 +530,15 @@ static int batadv_write_buffer_text(struct batadv_priv *bat_priv,
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
 
-	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %3i - %i%s/%i%s\n",
+	ret = seq_printf(seq, "%s %pM (%3i) %pM [%10s]: %u.%u/%u.%u MBit\n",
 			 (curr_gw == gw_node ? "=>" : "  "),
 			 gw_node->orig_node->orig,
 			 router->tq_avg, router->addr,
 			 router->if_incoming->net_dev->name,
-			 gw_node->orig_node->gw_flags,
-			 (down > 2048 ? down / 1024 : down),
-			 (down > 2048 ? "MBit" : "KBit"),
-			 (up > 2048 ? up / 1024 : up),
-			 (up > 2048 ? "MBit" : "KBit"));
+			 gw_node->bandwidth_down / 10,
+			 gw_node->bandwidth_down % 10,
+			 gw_node->bandwidth_up / 10,
+			 gw_node->bandwidth_up % 10);
 
 	batadv_neigh_node_free_ref(router);
 	if (curr_gw)
@@ -508,7 +560,7 @@ int batadv_gw_client_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 
 	seq_printf(seq,
-		   "      %-12s (%s/%i) %17s [%10s]: gw_class ... [B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
+		   "      %-12s (%s/%i) %17s [%10s]: advertised uplink bandwidth ... [B.A.T.M.A.N. adv %s, MainIF/MAC: %s/%pM (%s)]\n",
 		   "Gateway", "#", BATADV_TQ_MAX_VALUE, "Nexthop", "outgoingIF",
 		   BATADV_SOURCE_VERSION, primary_if->net_dev->name,
 		   primary_if->net_dev->dev_addr, net_dev->name);
@@ -675,7 +727,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 {
 	struct batadv_neigh_node *neigh_curr = NULL, *neigh_old = NULL;
 	struct batadv_orig_node *orig_dst_node = NULL;
-	struct batadv_gw_node *curr_gw = NULL;
+	struct batadv_gw_node *gw_node = NULL, *curr_gw = NULL;
 	struct ethhdr *ethhdr;
 	bool ret, out_of_range = false;
 	unsigned int header_len = 0;
@@ -691,7 +743,8 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	if (!orig_dst_node)
 		goto out;
 
-	if (!orig_dst_node->gw_flags)
+	gw_node = batadv_gw_node_get(bat_priv, orig_dst_node);
+	if (!gw_node->bandwidth_down == 0)
 		goto out;
 
 	ret = batadv_is_type_dhcprequest(skb, header_len);
@@ -742,6 +795,8 @@ out:
 		batadv_orig_node_free_ref(orig_dst_node);
 	if (curr_gw)
 		batadv_gw_node_free_ref(curr_gw);
+	if (gw_node)
+		batadv_gw_node_free_ref(gw_node);
 	if (neigh_old)
 		batadv_neigh_node_free_ref(neigh_old);
 	if (neigh_curr)
diff --git a/net/batman-adv/gateway_client.h b/net/batman-adv/gateway_client.h
index ceef4eb..d95c2d2 100644
--- a/net/batman-adv/gateway_client.h
+++ b/net/batman-adv/gateway_client.h
@@ -29,7 +29,7 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 			      struct batadv_orig_node *orig_node);
 void batadv_gw_node_update(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node,
-			   uint8_t new_gwflags);
+			   struct batadv_tvlv_gateway_data *gateway);
 void batadv_gw_node_delete(struct batadv_priv *bat_priv,
 			   struct batadv_orig_node *orig_node);
 void batadv_gw_node_purge(struct batadv_priv *bat_priv);
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 84bb2b1..b211b0f 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -21,64 +21,23 @@
 #include "gateway_common.h"
 #include "gateway_client.h"
 
-/* calculates the gateway class from kbit */
-static void batadv_kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
-{
-	int mdown = 0, tdown, tup, difference;
-	uint8_t sbit, part;
-
-	*gw_srv_class = 0;
-	difference = 0x0FFFFFFF;
-
-	/* test all downspeeds */
-	for (sbit = 0; sbit < 2; sbit++) {
-		for (part = 0; part < 16; part++) {
-			tdown = 32 * (sbit + 2) * (1 << part);
-
-			if (abs(tdown - down) < difference) {
-				*gw_srv_class = (sbit << 7) + (part << 3);
-				difference = abs(tdown - down);
-				mdown = tdown;
-			}
-		}
-	}
-
-	/* test all upspeeds */
-	difference = 0x0FFFFFFF;
-
-	for (part = 0; part < 8; part++) {
-		tup = ((part + 1) * (mdown)) / 8;
-
-		if (abs(tup - up) < difference) {
-			*gw_srv_class = (*gw_srv_class & 0xF8) | part;
-			difference = abs(tup - up);
-		}
-	}
-}
-
-/* returns the up and downspeeds in kbit, calculated from the class */
-void batadv_gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
-{
-	int sbit = (gw_srv_class & 0x80) >> 7;
-	int dpart = (gw_srv_class & 0x78) >> 3;
-	int upart = (gw_srv_class & 0x07);
-
-	if (!gw_srv_class) {
-		*down = 0;
-		*up = 0;
-		return;
-	}
-
-	*down = 32 * (sbit + 2) * (1 << dpart);
-	*up = ((upart + 1) * (*down)) / 8;
-}
-
+/**
+ * batadv_parse_gw_bandwidth - parse supplied string buffer to extract download
+ *  and upload bandwidth information
+ * @net_dev: the soft interface net device
+ * @buff: string buffer to parse
+ * @down: pointer holding the returned download bandwidth information
+ * @up: pointer holding the returned upload bandwidth information
+ *
+ * Returns false on parse error and true otherwise.
+ */
 static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
-				      int *up, int *down)
+				      uint32_t *down, uint32_t *up)
 {
-	int ret, multi = 1;
+	enum batadv_bandwidth_units bw_unit_type = BATADV_BW_UNIT_KBIT;
 	char *slash_ptr, *tmp_ptr;
 	long ldown, lup;
+	int ret;
 
 	slash_ptr = strchr(buff, '/');
 	if (slash_ptr)
@@ -88,10 +47,10 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 		tmp_ptr = buff + strlen(buff) - 4;
 
 		if (strnicmp(tmp_ptr, "mbit", 4) == 0)
-			multi = 1024;
+			bw_unit_type = BATADV_BW_UNIT_MBIT;
 
 		if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
-		    (multi > 1))
+		    (bw_unit_type == BATADV_BW_UNIT_MBIT))
 			*tmp_ptr = '\0';
 	}
 
@@ -103,20 +62,28 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 		return false;
 	}
 
-	*down = ldown * multi;
+	switch (bw_unit_type) {
+	case BATADV_BW_UNIT_MBIT:
+		*down = ldown * 10;
+		break;
+	case BATADV_BW_UNIT_KBIT:
+	default:
+		*down = ldown / 100;
+		break;
+	}
 
 	/* we also got some upload info */
 	if (slash_ptr) {
-		multi = 1;
+		bw_unit_type = BATADV_BW_UNIT_KBIT;
 
 		if (strlen(slash_ptr + 1) > 4) {
 			tmp_ptr = slash_ptr + 1 - 4 + strlen(slash_ptr + 1);
 
 			if (strnicmp(tmp_ptr, "mbit", 4) == 0)
-				multi = 1024;
+				bw_unit_type = BATADV_BW_UNIT_MBIT;
 
 			if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
-			    (multi > 1))
+			    (bw_unit_type == BATADV_BW_UNIT_MBIT))
 				*tmp_ptr = '\0';
 		}
 
@@ -128,52 +95,149 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 			return false;
 		}
 
-		*up = lup * multi;
+		switch (bw_unit_type) {
+		case BATADV_BW_UNIT_MBIT:
+			*up = lup * 10;
+			break;
+		case BATADV_BW_UNIT_KBIT:
+		default:
+			*up = lup / 100;
+			break;
+		}
 	}
 
 	return true;
 }
 
+/**
+ * batadv_gw_tvlv_container_update - update the gw tvlv container after gateway
+ *  setting change
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_gw_tvlv_container_update(struct batadv_priv *bat_priv)
+{
+	struct batadv_tvlv_gateway_data gw;
+	uint32_t down, up;
+	char gw_mode;
+
+	gw_mode = atomic_read(&bat_priv->gw_mode);
+
+	switch (gw_mode) {
+	case BATADV_GW_MODE_OFF:
+	case BATADV_GW_MODE_CLIENT:
+		batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_GW, 1);
+		break;
+	case BATADV_GW_MODE_SERVER:
+		down = atomic_read(&bat_priv->gw.bandwidth_down);
+		up = atomic_read(&bat_priv->gw.bandwidth_up);
+		gw.bandwidth_down = htonl(down);
+		gw.bandwidth_up = htonl(up);
+		batadv_tvlv_container_register(bat_priv, BATADV_TVLV_GW, 1,
+					       &gw, sizeof(gw));
+		break;
+	}
+}
+
 ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 				size_t count)
 {
 	struct batadv_priv *bat_priv = netdev_priv(net_dev);
-	long gw_bandwidth_tmp = 0;
-	int up = 0, down = 0;
+	uint32_t down_curr, up_curr, down_new = 0, up_new = 0;
 	bool ret;
 
-	ret = batadv_parse_gw_bandwidth(net_dev, buff, &up, &down);
+	down_curr = (unsigned int)atomic_read(&bat_priv->gw.bandwidth_down);
+	up_curr = (unsigned int)atomic_read(&bat_priv->gw.bandwidth_up);
+
+	ret = batadv_parse_gw_bandwidth(net_dev, buff, &down_new, &up_new);
 	if (!ret)
 		goto end;
 
-	if ((!down) || (down < 256))
-		down = 2000;
+	if (!down_new)
+		down_new = 1;
 
-	if (!up)
-		up = down / 5;
+	if (!up_new)
+		up_new = down_new / 5;
 
-	batadv_kbit_to_gw_bandwidth(down, up, &gw_bandwidth_tmp);
+	if (!up_new)
+		up_new = 1;
 
-	/* the gw bandwidth we guessed above might not match the given
-	 * speeds, hence we need to calculate it back to show the number
-	 * that is going to be propagated
-	 */
-	batadv_gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
-
-	if (atomic_read(&bat_priv->gw_bandwidth) == gw_bandwidth_tmp)
+	if ((down_curr == down_new) && (up_curr == up_new))
 		return count;
 
 	batadv_gw_deselect(bat_priv);
 	batadv_info(net_dev,
-		    "Changing gateway bandwidth from: '%i' to: '%ld' (propagating: %d%s/%d%s)\n",
-		    atomic_read(&bat_priv->gw_bandwidth), gw_bandwidth_tmp,
-		    (down > 2048 ? down / 1024 : down),
-		    (down > 2048 ? "MBit" : "KBit"),
-		    (up > 2048 ? up / 1024 : up),
-		    (up > 2048 ? "MBit" : "KBit"));
+		    "Changing gateway bandwidth from: '%u.%u/%u.%u MBit' to: '%u.%u/%u.%u MBit'\n",
+		    down_curr / 10, down_curr % 10, up_curr / 10, up_curr % 10,
+		    down_new / 10, down_new % 10, up_new / 10, up_new % 10);
 
-	atomic_set(&bat_priv->gw_bandwidth, gw_bandwidth_tmp);
+	atomic_set(&bat_priv->gw.bandwidth_down, down_new);
+	atomic_set(&bat_priv->gw.bandwidth_up, up_new);
+	batadv_gw_tvlv_container_update(bat_priv);
 
 end:
 	return count;
 }
+
+/**
+ * batadv_gw_tvlv_ogm_handler_v1 - process incoming gateway tvlv container
+ * @bat_priv: the bat priv with all the soft interface information
+ * @orig: the orig_node of the ogm
+ * @flags: flags indicating the tvlv state (see batadv_tvlv_handler_flags)
+ * @tvlv_value: tvlv buffer containing the gateway data
+ * @tvlv_value_len: tvlv buffer length
+ */
+static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
+					  struct batadv_orig_node *orig,
+					  uint8_t flags,
+					  void *tvlv_value,
+					  uint16_t tvlv_value_len)
+{
+	struct batadv_tvlv_gateway_data gateway, *gateway_ptr;
+
+	/* only fetch the tvlv value if the handler wasn't called via the
+	 * CIFNOTFND flag and if there is data to fetch
+	 */
+	if ((flags & BATADV_TVLV_HANDLER_OGM_CIFNOTFND) ||
+	    (tvlv_value_len < sizeof(gateway))) {
+		gateway.bandwidth_down = 0;
+		gateway.bandwidth_up = 0;
+	} else {
+		gateway_ptr = tvlv_value;
+		gateway.bandwidth_down = gateway_ptr->bandwidth_down;
+		gateway.bandwidth_up = gateway_ptr->bandwidth_up;
+		if ((gateway.bandwidth_down == 0) ||
+		    (gateway.bandwidth_up == 0)) {
+			gateway.bandwidth_down = 0;
+			gateway.bandwidth_up = 0;
+		}
+	}
+
+	batadv_gw_node_update(bat_priv, orig, &gateway);
+
+	/* restart gateway selection if fast or late switching was enabled */
+	if ((gateway.bandwidth_down != 0) &&
+	    (atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_CLIENT) &&
+	    (atomic_read(&bat_priv->gw_sel_class) > 2))
+		batadv_gw_check_election(bat_priv, orig);
+}
+
+/**
+ * batadv_gw_init - initialise the gateway handling internals
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_gw_init(struct batadv_priv *bat_priv)
+{
+	batadv_tvlv_handler_register(bat_priv, batadv_gw_tvlv_ogm_handler_v1,
+				     NULL, BATADV_TVLV_GW, 1,
+				     BATADV_TVLV_HANDLER_OGM_CIFNOTFND);
+}
+
+/**
+ * batadv_gw_free - free the gateway handling internals
+ * @bat_priv: the bat priv with all the soft interface information
+ */
+void batadv_gw_free(struct batadv_priv *bat_priv)
+{
+	batadv_tvlv_container_unregister(bat_priv, BATADV_TVLV_GW, 1);
+	batadv_tvlv_handler_unregister(bat_priv, BATADV_TVLV_GW, 1);
+}
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index 509b2bf..56384a4 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -26,12 +26,24 @@ enum batadv_gw_modes {
 	BATADV_GW_MODE_SERVER,
 };
 
+/**
+ * enum batadv_bandwidth_units - bandwidth unit types
+ * @BATADV_BW_UNIT_KBIT: unit type kbit
+ * @BATADV_BW_UNIT_MBIT: unit type mbit
+ */
+enum batadv_bandwidth_units {
+	BATADV_BW_UNIT_KBIT,
+	BATADV_BW_UNIT_MBIT,
+};
+
 #define BATADV_GW_MODE_OFF_NAME	"off"
 #define BATADV_GW_MODE_CLIENT_NAME	"client"
 #define BATADV_GW_MODE_SERVER_NAME	"server"
 
-void batadv_gw_bandwidth_to_kbit(uint8_t gw_class, int *down, int *up);
 ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
 				size_t count);
+void batadv_gw_tvlv_container_update(struct batadv_priv *bat_priv);
+void batadv_gw_init(struct batadv_priv *bat_priv);
+void batadv_gw_free(struct batadv_priv *bat_priv);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_COMMON_H_ */
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index e2de68a..cb9a446 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -37,6 +37,7 @@
 #include "bridge_loop_avoidance.h"
 #include "distributed-arp-table.h"
 #include "unicast.h"
+#include "gateway_common.h"
 #include "vis.h"
 #include "hash.h"
 #include "bat_algo.h"
@@ -152,6 +153,8 @@ int batadv_mesh_init(struct net_device *soft_iface)
 	if (ret < 0)
 		goto err;
 
+	batadv_gw_init(bat_priv);
+
 	atomic_set(&bat_priv->gw.reselect, 0);
 	atomic_set(&bat_priv->mesh_state, BATADV_MESH_ACTIVE);
 
@@ -190,6 +193,8 @@ void batadv_mesh_free(struct net_device *soft_iface)
 	 */
 	batadv_originator_free(bat_priv);
 
+	batadv_gw_free(bat_priv);
+
 	free_percpu(bat_priv->bat_counters);
 	bat_priv->bat_counters = NULL;
 
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index f50553a..5d53d2f 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -388,9 +388,7 @@ static void _batadv_purge_orig(struct batadv_priv *bat_priv)
 		hlist_for_each_entry_safe(orig_node, node_tmp,
 					  head, hash_entry) {
 			if (batadv_purge_orig_node(bat_priv, orig_node)) {
-				if (orig_node->gw_flags)
-					batadv_gw_node_delete(bat_priv,
-							      orig_node);
+				batadv_gw_node_delete(bat_priv, orig_node);
 				hlist_del_rcu(&orig_node->hash_entry);
 				batadv_orig_node_free_ref(orig_node);
 				continue;
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index b5c21c4..6d0b3a7 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -118,6 +118,14 @@ enum batadv_bla_claimframe {
 	BATADV_CLAIM_TYPE_REQUEST	= 0x03,
 };
 
+/**
+ * enum batadv_tvlv_type - tvlv type definitions
+ * @BATADV_TVLV_GW: gateway tvlv
+ */
+enum batadv_tvlv_type {
+	BATADV_TVLV_GW		= 0x01,
+};
+
 /* the destination hardware field in the ARP frame is used to
  * transport the claim type and the group id
  */
@@ -147,7 +155,7 @@ struct batadv_ogm_packet {
 	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 	uint8_t  prev_sender[ETH_ALEN];
-	uint8_t  gw_flags;  /* flags related to gateway class */
+	uint8_t  reserved;
 	uint8_t  tq;
 	uint8_t  tt_num_changes;
 	uint8_t  ttvn; /* translation table version number */
@@ -352,4 +360,15 @@ struct batadv_tvlv_hdr {
 	__be16  len;
 };
 
+/**
+ * struct batadv_tvlv_gateway_data - gateway data propagated through gw tvlv
+ *  container
+ * @bandwidth_down: advertised uplink download bandwidth
+ * @bandwidth_up: advertised uplink upload bandwidth
+ */
+struct batadv_tvlv_gateway_data {
+	__be32 bandwidth_down;
+	__be32 bandwidth_up;
+};
+
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 813db4e..84623a9 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -472,7 +472,8 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->vis_mode, BATADV_VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
-	atomic_set(&bat_priv->gw_bandwidth, 41);
+	atomic_set(&bat_priv->gw.bandwidth_down, 100);
+	atomic_set(&bat_priv->gw.bandwidth_up, 20);
 	atomic_set(&bat_priv->orig_interval, 1000);
 	atomic_set(&bat_priv->hop_penalty, 30);
 #ifdef CONFIG_BATMAN_ADV_DEBUG
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 4114b96..68793f5 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -390,6 +390,7 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 	 */
 	batadv_gw_check_client_stop(bat_priv);
 	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
+	batadv_gw_tvlv_container_update(bat_priv);
 	return count;
 }
 
@@ -397,15 +398,13 @@ static ssize_t batadv_show_gw_bwidth(struct kobject *kobj,
 				     struct attribute *attr, char *buff)
 {
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
-	int down, up;
-	int gw_bandwidth = atomic_read(&bat_priv->gw_bandwidth);
+	uint32_t down, up;
 
-	batadv_gw_bandwidth_to_kbit(gw_bandwidth, &down, &up);
-	return sprintf(buff, "%i%s/%i%s\n",
-		       (down > 2048 ? down / 1024 : down),
-		       (down > 2048 ? "MBit" : "KBit"),
-		       (up > 2048 ? up / 1024 : up),
-		       (up > 2048 ? "MBit" : "KBit"));
+	down = atomic_read(&bat_priv->gw.bandwidth_down);
+	up = atomic_read(&bat_priv->gw.bandwidth_up);
+
+	return sprintf(buff, "%u.%u/%u.%u MBit\n", down / 10,
+		       down % 10, up / 10, up % 10);
 }
 
 static ssize_t batadv_store_gw_bwidth(struct kobject *kobj,
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 4bdea16..b22a043 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -99,7 +99,6 @@ struct batadv_hard_iface {
  * @last_seen: time when last packet from this node was received
  * @bcast_seqno_reset: time when the broadcast seqno window was reset
  * @batman_seqno_reset: time when the batman seqno window was reset
- * @gw_flags: flags related to gateway class
  * @flags: for now only VIS_SERVER flag
  * @last_ttvn: last seen translation table version number
  * @tt_crc: CRC of the translation table
@@ -147,7 +146,6 @@ struct batadv_orig_node {
 	unsigned long last_seen;
 	unsigned long bcast_seqno_reset;
 	unsigned long batman_seqno_reset;
-	uint8_t gw_flags;
 	uint8_t flags;
 	atomic_t last_ttvn;
 	uint16_t tt_crc;
@@ -189,6 +187,8 @@ struct batadv_orig_node {
  * struct batadv_gw_node - structure for orig nodes announcing gw capabilities
  * @list: list node for batadv_priv_gw::list
  * @orig_node: pointer to corresponding orig node
+ * @bandwidth_down: advertised uplink download bandwidth
+ * @bandwidth_up: advertised uplink upload bandwidth
  * @deleted: this struct is scheduled for deletion
  * @refcount: number of contexts the object is used
  * @rcu: struct used for freeing in an RCU-safe manner
@@ -196,6 +196,8 @@ struct batadv_orig_node {
 struct batadv_gw_node {
 	struct hlist_node list;
 	struct batadv_orig_node *orig_node;
+	uint32_t bandwidth_down;
+	uint32_t bandwidth_up;
 	unsigned long deleted;
 	atomic_t refcount;
 	struct rcu_head rcu;
@@ -420,12 +422,16 @@ struct batadv_priv_debug_log {
  * @list: list of available gateway nodes
  * @list_lock: lock protecting gw_list & curr_gw
  * @curr_gw: pointer to currently selected gateway node
+ * @bandwidth_down: advertised uplink download bandwidth (if gw_mode server)
+ * @bandwidth_up: advertised uplink upload bandwidth (if gw_mode server)
  * @reselect: bool indicating a gateway re-selection is in progress
  */
 struct batadv_priv_gw {
 	struct hlist_head list;
 	spinlock_t list_lock; /* protects gw_list & curr_gw */
 	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	atomic_t bandwidth_down;
+	atomic_t bandwidth_up;
 	atomic_t reselect;
 };
 
@@ -521,7 +527,6 @@ struct batadv_priv_nc {
  * @vis_mode: vis operation: client or server (see batadv_vis_packettype)
  * @gw_mode: gateway operation: off, client or server (see batadv_gw_modes)
  * @gw_sel_class: gateway selection class (applies if gw_mode client)
- * @gw_bandwidth: gateway announced bandwidth (applies if gw_mode server)
  * @orig_interval: OGM broadcast interval in milliseconds
  * @hop_penalty: penalty which will be applied to an OGM's tq-field on every hop
  * @log_level: configured log level (see batadv_dbg_level)
@@ -569,7 +574,6 @@ struct batadv_priv {
 	atomic_t vis_mode;
 	atomic_t gw_mode;
 	atomic_t gw_sel_class;
-	atomic_t gw_bandwidth;
 	atomic_t orig_interval;
 	atomic_t hop_penalty;
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-- 
1.8.3.2
