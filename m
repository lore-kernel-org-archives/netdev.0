From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 07/20] batman-adv: Prefix gateway-common
	non-static functions with batadv_
Date: Thu, 21 Jun 2012 18:57:43 +0200
Message-ID: <1340297876-29923-8-git-send-email-ordex@autistici.org>
References: <1340297876-29923-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1340297876-29923-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

batman-adv can be compiled as part of the kernel instead of an module. In that
case the linker will see all non-static symbols of batman-adv and all other
non-static symbols of the kernel. This could lead to symbol collisions. A
prefix for the batman-adv symbols that defines their private namespace avoids
such a problem.

Reported-by: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/bat_sysfs.c      |    4 ++--
 net/batman-adv/gateway_client.c |   12 +++++++-----
 net/batman-adv/gateway_common.c |    7 ++++---
 net/batman-adv/gateway_common.h |    5 +++--
 4 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 31d23db..a8fb660 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -409,7 +409,7 @@ static ssize_t show_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 	int down, up;
 	int gw_bandwidth = atomic_read(&bat_priv->gw_bandwidth);
 
-	gw_bandwidth_to_kbit(gw_bandwidth, &down, &up);
+	batadv_gw_bandwidth_to_kbit(gw_bandwidth, &down, &up);
 	return sprintf(buff, "%i%s/%i%s\n",
 		       (down > 2048 ? down / 1024 : down),
 		       (down > 2048 ? "MBit" : "KBit"),
@@ -425,7 +425,7 @@ static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 	if (buff[count - 1] == '\n')
 		buff[count - 1] = '\0';
 
-	return gw_bandwidth_set(net_dev, buff, count);
+	return batadv_gw_bandwidth_set(net_dev, buff, count);
 }
 
 BAT_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index a28d9ce..a3f944b 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -116,13 +116,15 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 	uint32_t max_gw_factor = 0, tmp_gw_factor = 0;
 	uint8_t max_tq = 0;
 	int down, up;
+	struct orig_node *orig_node;
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(gw_node, node, &bat_priv->gw_list, list) {
 		if (gw_node->deleted)
 			continue;
 
-		router = orig_node_get_router(gw_node->orig_node);
+		orig_node = gw_node->orig_node;
+		router = orig_node_get_router(orig_node);
 		if (!router)
 			continue;
 
@@ -131,8 +133,8 @@ static struct gw_node *gw_get_best_gw_node(struct bat_priv *bat_priv)
 
 		switch (atomic_read(&bat_priv->gw_sel_class)) {
 		case 1: /* fast connection */
-			gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags,
-					     &down, &up);
+			batadv_gw_bandwidth_to_kbit(orig_node->gw_flags,
+						    &down, &up);
 
 			tmp_gw_factor = (router->tq_avg * router->tq_avg *
 					 down * 100 * 100) /
@@ -319,7 +321,7 @@ static void gw_node_add(struct bat_priv *bat_priv,
 	hlist_add_head_rcu(&gw_node->list, &bat_priv->gw_list);
 	spin_unlock_bh(&bat_priv->gw_list_lock);
 
-	gw_bandwidth_to_kbit(new_gwflags, &down, &up);
+	batadv_gw_bandwidth_to_kbit(new_gwflags, &down, &up);
 	bat_dbg(DBG_BATMAN, bat_priv,
 		"Found new gateway %pM -> gw_class: %i - %i%s/%i%s\n",
 		orig_node->orig, new_gwflags,
@@ -434,7 +436,7 @@ static int _write_buffer_text(struct bat_priv *bat_priv, struct seq_file *seq,
 	struct neigh_node *router;
 	int down, up, ret = -1;
 
-	gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
+	batadv_gw_bandwidth_to_kbit(gw_node->orig_node->gw_flags, &down, &up);
 
 	router = orig_node_get_router(gw_node->orig_node);
 	if (!router)
diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index a0b0f52..722c932 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -59,7 +59,7 @@ static void kbit_to_gw_bandwidth(int down, int up, long *gw_srv_class)
 }
 
 /* returns the up and downspeeds in kbit, calculated from the class */
-void gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
+void batadv_gw_bandwidth_to_kbit(uint8_t gw_srv_class, int *down, int *up)
 {
 	int sbit = (gw_srv_class & 0x80) >> 7;
 	int dpart = (gw_srv_class & 0x78) >> 3;
@@ -136,7 +136,8 @@ static bool parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 	return true;
 }
 
-ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
+ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
+				size_t count)
 {
 	struct bat_priv *bat_priv = netdev_priv(net_dev);
 	long gw_bandwidth_tmp = 0;
@@ -160,7 +161,7 @@ ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count)
 	 * speeds, hence we need to calculate it back to show the number
 	 * that is going to be propagated
 	 **/
-	gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
+	batadv_gw_bandwidth_to_kbit((uint8_t)gw_bandwidth_tmp, &down, &up);
 
 	if (atomic_read(&bat_priv->gw_bandwidth) == gw_bandwidth_tmp)
 		return count;
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index b8fb11c..e256040 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -32,7 +32,8 @@ enum gw_modes {
 #define GW_MODE_CLIENT_NAME	"client"
 #define GW_MODE_SERVER_NAME	"server"
 
-void gw_bandwidth_to_kbit(uint8_t gw_class, int *down, int *up);
-ssize_t gw_bandwidth_set(struct net_device *net_dev, char *buff, size_t count);
+void batadv_gw_bandwidth_to_kbit(uint8_t gw_class, int *down, int *up);
+ssize_t batadv_gw_bandwidth_set(struct net_device *net_dev, char *buff,
+				size_t count);
 
 #endif /* _NET_BATMAN_ADV_GATEWAY_COMMON_H_ */
-- 
1.7.9.4
