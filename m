From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 16/16] batman-adv: add bridge loop avoidance
	compile option
Date: Wed, 11 Apr 2012 14:50:49 +0200
Message-ID: <1334148649-25443-17-git-send-email-ordex@autistici.org>
References: <1334148649-25443-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1334148649-25443-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

From: Simon Wunderlich <simon.wunderlich-Y4E02TeZ33kaBlGTGt4zH4SGEyLTKazZ@public.gmane.org>

The define CONFIG_BATMAN_ADV_BLA switches the bridge loop avoidance
on - skip it, and the bridge loop avoidance is not compiled in.

This is useful if binary size should be saved or the feature is
not needed.

Signed-off-by: Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>
Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
---
 net/batman-adv/Kconfig                 |   12 ++++++-
 net/batman-adv/Makefile                |    2 +-
 net/batman-adv/bat_debugfs.c           |    7 +++-
 net/batman-adv/bat_sysfs.c             |    4 +++
 net/batman-adv/bridge_loop_avoidance.h |   57 ++++++++++++++++++++++++++++++++
 net/batman-adv/soft-interface.c        |    4 +--
 net/batman-adv/types.h                 |    8 +++++
 7 files changed, 89 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 6ff977c..53f5244 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -4,7 +4,7 @@
 
 config BATMAN_ADV
 	tristate "B.A.T.M.A.N. Advanced Meshing Protocol"
-	depends on NET && INET
+	depends on NET
 	select CRC16
         default n
 	help
@@ -14,6 +14,16 @@ config BATMAN_ADV
           http://www.open-mesh.org/ for more information and user space
           tools.
 
+config BATMAN_ADV_BLA
+	bool "Bridge Loop Avoidance"
+	depends on BATMAN_ADV && INET
+	default y
+	help
+	  This option enables BLA (Bridge Loop Avoidance), a mechanism
+	  to avoid Ethernet frames looping when mesh nodes are connected
+	  to both the same LAN and the same mesh. If you will never use
+	  more than one mesh node in the same LAN, you can safely remove
+	  this feature and save some space.
 
 config BATMAN_ADV_DEBUG
 	bool "B.A.T.M.A.N. debugging"
diff --git a/net/batman-adv/Makefile b/net/batman-adv/Makefile
index 94b67fd..6d5c194 100644
--- a/net/batman-adv/Makefile
+++ b/net/batman-adv/Makefile
@@ -23,7 +23,7 @@ batman-adv-y += bat_debugfs.o
 batman-adv-y += bat_iv_ogm.o
 batman-adv-y += bat_sysfs.o
 batman-adv-y += bitarray.o
-batman-adv-y += bridge_loop_avoidance.o
+batman-adv-$(CONFIG_BATMAN_ADV_BLA) += bridge_loop_avoidance.o
 batman-adv-y += gateway_client.o
 batman-adv-y += gateway_common.o
 batman-adv-y += hard-interface.o
diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index 0e35177..916380c 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -245,12 +245,13 @@ static int transtable_global_open(struct inode *inode, struct file *file)
 	return single_open(file, tt_global_seq_print_text, net_dev);
 }
 
+#ifdef CONFIG_BATMAN_ADV_BLA
 static int bla_claim_table_open(struct inode *inode, struct file *file)
 {
 	struct net_device *net_dev = (struct net_device *)inode->i_private;
 	return single_open(file, bla_claim_table_seq_print_text, net_dev);
 }
-
+#endif
 
 static int transtable_local_open(struct inode *inode, struct file *file)
 {
@@ -285,7 +286,9 @@ static BAT_DEBUGINFO(routing_algos, S_IRUGO, bat_algorithms_open);
 static BAT_DEBUGINFO(originators, S_IRUGO, originators_open);
 static BAT_DEBUGINFO(gateways, S_IRUGO, gateways_open);
 static BAT_DEBUGINFO(transtable_global, S_IRUGO, transtable_global_open);
+#ifdef CONFIG_BATMAN_ADV_BLA
 static BAT_DEBUGINFO(bla_claim_table, S_IRUGO, bla_claim_table_open);
+#endif
 static BAT_DEBUGINFO(transtable_local, S_IRUGO, transtable_local_open);
 static BAT_DEBUGINFO(vis_data, S_IRUGO, vis_data_open);
 
@@ -293,7 +296,9 @@ static struct bat_debuginfo *mesh_debuginfos[] = {
 	&bat_debuginfo_originators,
 	&bat_debuginfo_gateways,
 	&bat_debuginfo_transtable_global,
+#ifdef CONFIG_BATMAN_ADV_BLA
 	&bat_debuginfo_bla_claim_table,
+#endif
 	&bat_debuginfo_transtable_local,
 	&bat_debuginfo_vis_data,
 	NULL,
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index 824bfe7..c6efd68 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -386,7 +386,9 @@ static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 
 BAT_ATTR_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
+#ifdef CONFIG_BATMAN_ADV_BLA
 BAT_ATTR_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
+#endif
 BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
 BAT_ATTR_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
@@ -405,7 +407,9 @@ BAT_ATTR_UINT(log_level, S_IRUGO | S_IWUSR, 0, 15, NULL);
 static struct bat_attribute *mesh_attrs[] = {
 	&bat_attr_aggregated_ogms,
 	&bat_attr_bonding,
+#ifdef CONFIG_BATMAN_ADV_BLA
 	&bat_attr_bridge_loop_avoidance,
+#endif
 	&bat_attr_fragmentation,
 	&bat_attr_ap_isolation,
 	&bat_attr_vis_mode,
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 9468c24..4a8e4fc 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -22,6 +22,7 @@
 #ifndef _NET_BATMAN_ADV_BLA_H_
 #define _NET_BATMAN_ADV_BLA_H_
 
+#ifdef CONFIG_BATMAN_ADV_BLA
 int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb, short vid);
 int bla_is_backbone_gw(struct sk_buff *skb,
@@ -37,5 +38,61 @@ int bla_init(struct bat_priv *bat_priv);
 void bla_free(struct bat_priv *bat_priv);
 
 #define BLA_CRC_INIT	0
+#else /* ifdef CONFIG_BATMAN_ADV_BLA */
+
+static inline int bla_rx(struct bat_priv *bat_priv, struct sk_buff *skb,
+			 short vid)
+{
+	return 0;
+}
+
+static inline int bla_tx(struct bat_priv *bat_priv, struct sk_buff *skb,
+			 short vid)
+{
+	return 0;
+}
+
+static inline int bla_is_backbone_gw(struct sk_buff *skb,
+				     struct orig_node *orig_node,
+				     int hdr_size)
+{
+	return 0;
+}
+
+static inline int bla_claim_table_seq_print_text(struct seq_file *seq,
+						 void *offset)
+{
+	return 0;
+}
+
+static inline int bla_is_backbone_gw_orig(struct bat_priv *bat_priv,
+					  uint8_t *orig)
+{
+	return 0;
+}
+
+static inline int bla_check_bcast_duplist(struct bat_priv *bat_priv,
+					  struct bcast_packet *bcast_packet,
+					  int hdr_size)
+{
+	return 0;
+}
+
+static inline void bla_update_orig_address(struct bat_priv *bat_priv,
+					   struct hard_iface *primary_if,
+					   struct hard_iface *oldif)
+{
+}
+
+static inline int bla_init(struct bat_priv *bat_priv)
+{
+	return 1;
+}
+
+static inline void bla_free(struct bat_priv *bat_priv)
+{
+}
+
+#endif /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 #endif /* ifndef _NET_BATMAN_ADV_BLA_H_ */
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 10ab49a..efe0fba 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -134,7 +134,7 @@ static int interface_tx(struct sk_buff *skb, struct net_device *soft_iface)
 						   0x00};
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
-	short vid = -1;
+	short vid __maybe_unused = -1;
 	bool do_bcast = false;
 
 	if (atomic_read(&bat_priv->mesh_state) != MESH_ACTIVE)
@@ -256,7 +256,7 @@ void interface_rx(struct net_device *soft_iface,
 	struct bat_priv *bat_priv = netdev_priv(soft_iface);
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
-	short vid = -1;
+	short vid __maybe_unused = -1;
 
 	/* check if enough space is available for pulling, and pull */
 	if (!pskb_may_pull(skb, hdr_size))
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7f7f610..a5b1a63 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -140,11 +140,13 @@ struct neigh_node {
 	spinlock_t tq_lock;	/* protects: tq_recv, tq_index */
 };
 
+#ifdef CONFIG_BATMAN_ADV_BLA
 struct bcast_duplist_entry {
 	uint8_t orig[ETH_ALEN];
 	uint16_t crc;
 	unsigned long entrytime;
 };
+#endif
 
 struct bat_priv {
 	atomic_t mesh_state;
@@ -186,14 +188,18 @@ struct bat_priv {
 	struct hashtable_t *orig_hash;
 	struct hashtable_t *tt_local_hash;
 	struct hashtable_t *tt_global_hash;
+#ifdef CONFIG_BATMAN_ADV_BLA
 	struct hashtable_t *claim_hash;
 	struct hashtable_t *backbone_hash;
+#endif
 	struct list_head tt_req_list; /* list of pending tt_requests */
 	struct list_head tt_roam_list;
 	struct hashtable_t *vis_hash;
+#ifdef CONFIG_BATMAN_ADV_BLA
 	struct bcast_duplist_entry bcast_duplist[DUPLIST_SIZE];
 	int bcast_duplist_curr;
 	struct bla_claim_dst claim_dest;
+#endif
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t tt_changes_list_lock; /* protects tt_changes */
@@ -261,6 +267,7 @@ struct tt_orig_list_entry {
 	struct hlist_node list;
 };
 
+#ifdef CONFIG_BATMAN_ADV_BLA
 struct backbone_gw {
 	uint8_t orig[ETH_ALEN];
 	short vid;		/* used VLAN ID */
@@ -282,6 +289,7 @@ struct claim {
 	atomic_t refcount;
 	struct hlist_node hash_entry;
 };
+#endif
 
 struct tt_change_node {
 	struct list_head list;
-- 
1.7.9.4
