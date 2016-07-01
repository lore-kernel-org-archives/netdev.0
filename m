From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 10/17] batman-adv: move GW mode and selection
	class to private data structure
Date: Fri,  1 Jul 2016 15:09:02 +0200
Message-ID: <1467378549-9646-11-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Antonio Quartulli <a@unstable.cc>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <a@unstable.cc>

To reduce the field pollution in our main batadv_priv data structure
we've already created some substructures so that we could group fields
in a convenient manner.

However gw_mode and gw_sel_class are still part of the main object.

More both fields to the GW private substructure.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/gateway_client.c | 12 ++++++------
 net/batman-adv/gateway_common.c |  6 +++---
 net/batman-adv/soft-interface.c |  6 +++---
 net/batman-adv/sysfs.c          | 10 +++++-----
 net/batman-adv/types.h          |  8 ++++----
 5 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index b9d72e9..18c3715 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -192,7 +192,7 @@ batadv_gw_get_best_gw_node(struct batadv_priv *bat_priv)
 
 		tq_avg = router_ifinfo->bat_iv.tq_avg;
 
-		switch (atomic_read(&bat_priv->gw_sel_class)) {
+		switch (atomic_read(&bat_priv->gw.sel_class)) {
 		case 1: /* fast connection */
 			tmp_gw_factor = tq_avg * tq_avg;
 			tmp_gw_factor *= gw_node->bandwidth_down;
@@ -255,7 +255,7 @@ void batadv_gw_check_client_stop(struct batadv_priv *bat_priv)
 {
 	struct batadv_gw_node *curr_gw;
 
-	if (atomic_read(&bat_priv->gw_mode) != BATADV_GW_MODE_CLIENT)
+	if (atomic_read(&bat_priv->gw.mode) != BATADV_GW_MODE_CLIENT)
 		return;
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
@@ -283,7 +283,7 @@ void batadv_gw_election(struct batadv_priv *bat_priv)
 	struct batadv_neigh_ifinfo *router_ifinfo = NULL;
 	char gw_addr[18] = { '\0' };
 
-	if (atomic_read(&bat_priv->gw_mode) != BATADV_GW_MODE_CLIENT)
+	if (atomic_read(&bat_priv->gw.mode) != BATADV_GW_MODE_CLIENT)
 		goto out;
 
 	curr_gw = batadv_gw_get_selected_gw_node(bat_priv);
@@ -402,8 +402,8 @@ void batadv_gw_check_election(struct batadv_priv *bat_priv,
 	/* if the routing class is greater than 3 the value tells us how much
 	 * greater the TQ value of the new gateway must be
 	 */
-	if ((atomic_read(&bat_priv->gw_sel_class) > 3) &&
-	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw_sel_class)))
+	if ((atomic_read(&bat_priv->gw.sel_class) > 3) &&
+	    (orig_tq_avg - gw_tq_avg < atomic_read(&bat_priv->gw.sel_class)))
 		goto out;
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
@@ -820,7 +820,7 @@ bool batadv_gw_out_of_range(struct batadv_priv *bat_priv,
 	if (!gw_node)
 		goto out;
 
-	switch (atomic_read(&bat_priv->gw_mode)) {
+	switch (atomic_read(&bat_priv->gw.mode)) {
 	case BATADV_GW_MODE_SERVER:
 		/* If we are a GW then we are our best GW. We can artificially
 		 * set the tq towards ourself as the maximum value
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 4423047..3c26945 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -144,7 +144,7 @@ void batadv_gw_tvlv_container_update(struct batadv_priv *bat_priv)
 	u32 down, up;
 	char gw_mode;
 
-	gw_mode = atomic_read(&bat_priv->gw_mode);
+	gw_mode = atomic_read(&bat_priv->gw.mode);
 
 	switch (gw_mode) {
 	case BATADV_GW_MODE_OFF:
@@ -241,8 +241,8 @@ static void batadv_gw_tvlv_ogm_handler_v1(struct batadv_priv *bat_priv,
 
 	/* restart gateway selection if fast or late switching was enabled */
 	if ((gateway.bandwidth_down != 0) &&
-	    (atomic_read(&bat_priv->gw_mode) == BATADV_GW_MODE_CLIENT) &&
-	    (atomic_read(&bat_priv->gw_sel_class) > 2))
+	    (atomic_read(&bat_priv->gw.mode) == BATADV_GW_MODE_CLIENT) &&
+	    (atomic_read(&bat_priv->gw.sel_class) > 2))
 		batadv_gw_check_election(bat_priv, orig);
 }
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 343d2c9..81665b1 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -255,7 +255,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	if (batadv_compare_eth(ethhdr->h_dest, ectp_addr))
 		goto dropped;
 
-	gw_mode = atomic_read(&bat_priv->gw_mode);
+	gw_mode = atomic_read(&bat_priv->gw.mode);
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		/* if gw mode is off, broadcast every packet */
 		if (gw_mode == BATADV_GW_MODE_OFF) {
@@ -815,8 +815,8 @@ static int batadv_softif_init_late(struct net_device *dev)
 	atomic_set(&bat_priv->mcast.num_want_all_ipv4, 0);
 	atomic_set(&bat_priv->mcast.num_want_all_ipv6, 0);
 #endif
-	atomic_set(&bat_priv->gw_mode, BATADV_GW_MODE_OFF);
-	atomic_set(&bat_priv->gw_sel_class, 20);
+	atomic_set(&bat_priv->gw.mode, BATADV_GW_MODE_OFF);
+	atomic_set(&bat_priv->gw.sel_class, 20);
 	atomic_set(&bat_priv->gw.bandwidth_down, 100);
 	atomic_set(&bat_priv->gw.bandwidth_up, 20);
 	atomic_set(&bat_priv->orig_interval, 1000);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index ef5832f..233abcf 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -427,7 +427,7 @@ static ssize_t batadv_show_gw_mode(struct kobject *kobj, struct attribute *attr,
 	struct batadv_priv *bat_priv = batadv_kobj_to_batpriv(kobj);
 	int bytes_written;
 
-	switch (atomic_read(&bat_priv->gw_mode)) {
+	switch (atomic_read(&bat_priv->gw.mode)) {
 	case BATADV_GW_MODE_CLIENT:
 		bytes_written = sprintf(buff, "%s\n",
 					BATADV_GW_MODE_CLIENT_NAME);
@@ -476,10 +476,10 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 		return -EINVAL;
 	}
 
-	if (atomic_read(&bat_priv->gw_mode) == gw_mode_tmp)
+	if (atomic_read(&bat_priv->gw.mode) == gw_mode_tmp)
 		return count;
 
-	switch (atomic_read(&bat_priv->gw_mode)) {
+	switch (atomic_read(&bat_priv->gw.mode)) {
 	case BATADV_GW_MODE_CLIENT:
 		curr_gw_mode_str = BATADV_GW_MODE_CLIENT_NAME;
 		break;
@@ -508,7 +508,7 @@ static ssize_t batadv_store_gw_mode(struct kobject *kobj,
 	 * state
 	 */
 	batadv_gw_check_client_stop(bat_priv);
-	atomic_set(&bat_priv->gw_mode, (unsigned int)gw_mode_tmp);
+	atomic_set(&bat_priv->gw.mode, (unsigned int)gw_mode_tmp);
 	batadv_gw_tvlv_container_update(bat_priv);
 	return count;
 }
@@ -624,7 +624,7 @@ BATADV_ATTR_SIF_UINT(orig_interval, orig_interval, S_IRUGO | S_IWUSR,
 		     2 * BATADV_JITTER, INT_MAX, NULL);
 BATADV_ATTR_SIF_UINT(hop_penalty, hop_penalty, S_IRUGO | S_IWUSR, 0,
 		     BATADV_TQ_MAX_VALUE, NULL);
-BATADV_ATTR_SIF_UINT(gw_sel_class, gw_sel_class, S_IRUGO | S_IWUSR, 1,
+BATADV_ATTR_SIF_UINT(gw_sel_class, gw.sel_class, S_IRUGO | S_IWUSR, 1,
 		     BATADV_TQ_MAX_VALUE, batadv_post_gw_reselect);
 static BATADV_ATTR(gw_bandwidth, S_IRUGO | S_IWUSR, batadv_show_gw_bwidth,
 		   batadv_store_gw_bwidth);
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index b70b6ae..32c6d0e 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -707,6 +707,8 @@ struct batadv_priv_debug_log {
  * @list: list of available gateway nodes
  * @list_lock: lock protecting gw_list & curr_gw
  * @curr_gw: pointer to currently selected gateway node
+ * @mode: gateway operation: off, client or server (see batadv_gw_modes)
+ * @sel_class: gateway selection class (applies if gw_mode client)
  * @bandwidth_down: advertised uplink download bandwidth (if gw_mode server)
  * @bandwidth_up: advertised uplink upload bandwidth (if gw_mode server)
  * @reselect: bool indicating a gateway re-selection is in progress
@@ -715,6 +717,8 @@ struct batadv_priv_gw {
 	struct hlist_head list;
 	spinlock_t list_lock; /* protects gw_list & curr_gw */
 	struct batadv_gw_node __rcu *curr_gw;  /* rcu protected pointer */
+	atomic_t mode;
+	atomic_t sel_class;
 	atomic_t bandwidth_down;
 	atomic_t bandwidth_up;
 	atomic_t reselect;
@@ -865,8 +869,6 @@ struct batadv_priv_bat_v {
  *  enabled
  * @multicast_mode: Enable or disable multicast optimizations on this node's
  *  sender/originating side
- * @gw_mode: gateway operation: off, client or server (see batadv_gw_modes)
- * @gw_sel_class: gateway selection class (applies if gw_mode client)
  * @orig_interval: OGM broadcast interval in milliseconds
  * @hop_penalty: penalty which will be applied to an OGM's tq-field on every hop
  * @log_level: configured log level (see batadv_dbg_level)
@@ -922,8 +924,6 @@ struct batadv_priv {
 #ifdef CONFIG_BATMAN_ADV_MCAST
 	atomic_t multicast_mode;
 #endif
-	atomic_t gw_mode;
-	atomic_t gw_sel_class;
 	atomic_t orig_interval;
 	atomic_t hop_penalty;
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-- 
2.8.1
