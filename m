From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 4/8] batman-adv: implement AP-isolation on the receiver side
Date: Wed, 24 Aug 2011 15:00:34 +0200
Message-ID: <1314190838-2273-5-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm5-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.232]:31139 "HELO
	nm5-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752897Ab1HXNBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:01:01 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

When a node receives a unicast packet it checks if the source and the
destination client can communicate or not due to the AP isolation

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 Documentation/ABI/testing/sysfs-class-net-mesh |    8 ++++
 net/batman-adv/bat_sysfs.c                     |    2 +
 net/batman-adv/soft-interface.c                |    4 ++
 net/batman-adv/translation-table.c             |   42 ++++++++++++++++++++++++
 net/batman-adv/translation-table.h             |    1 +
 net/batman-adv/types.h                         |    1 +
 6 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-mesh b/Documentation/ABI/testing/sysfs-class-net-mesh
index 748fe17..b020014 100644
--- a/Documentation/ABI/testing/sysfs-class-net-mesh
+++ b/Documentation/ABI/testing/sysfs-class-net-mesh
@@ -22,6 +22,14 @@ Description:
                 mesh will be fragmented or silently discarded if the
                 packet size exceeds the outgoing interface MTU.
 
+What:		/sys/class/net/<mesh_iface>/mesh/ap_isolation
+Date:		May 2011
+Contact:	Antonio Quartulli <ordex@autistici.org>
+Description:
+		Indicates whether the data traffic going from a
+		wireless client to another wireless client will be
+		silently dropped.
+
 What:           /sys/class/net/<mesh_iface>/mesh/gw_bandwidth
 Date:           October 2010
 Contact:        Marek Lindner <lindner_marek@yahoo.de>
diff --git a/net/batman-adv/bat_sysfs.c b/net/batman-adv/bat_sysfs.c
index cd15deb..b8a7414 100644
--- a/net/batman-adv/bat_sysfs.c
+++ b/net/batman-adv/bat_sysfs.c
@@ -380,6 +380,7 @@ static ssize_t store_gw_bwidth(struct kobject *kobj, struct attribute *attr,
 BAT_ATTR_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 BAT_ATTR_BOOL(fragmentation, S_IRUGO | S_IWUSR, update_min_mtu);
+BAT_ATTR_BOOL(ap_isolation, S_IRUGO | S_IWUSR, NULL);
 static BAT_ATTR(vis_mode, S_IRUGO | S_IWUSR, show_vis_mode, store_vis_mode);
 static BAT_ATTR(gw_mode, S_IRUGO | S_IWUSR, show_gw_mode, store_gw_mode);
 BAT_ATTR_UINT(orig_interval, S_IRUGO | S_IWUSR, 2 * JITTER, INT_MAX, NULL);
@@ -396,6 +397,7 @@ static struct bat_attribute *mesh_attrs[] = {
 	&bat_attr_aggregated_ogms,
 	&bat_attr_bonding,
 	&bat_attr_fragmentation,
+	&bat_attr_ap_isolation,
 	&bat_attr_vis_mode,
 	&bat_attr_gw_mode,
 	&bat_attr_orig_interval,
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 6deed44..9addbab 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -739,6 +739,9 @@ void interface_rx(struct net_device *soft_iface,
 
 	soft_iface->last_rx = jiffies;
 
+	if (is_ap_isolated(bat_priv, ethhdr->h_source, ethhdr->h_dest))
+		goto dropped;
+
 	netif_rx(skb);
 	goto out;
 
@@ -812,6 +815,7 @@ struct net_device *softif_create(const char *name)
 
 	atomic_set(&bat_priv->aggregated_ogms, 1);
 	atomic_set(&bat_priv->bonding, 0);
+	atomic_set(&bat_priv->ap_isolation, 0);
 	atomic_set(&bat_priv->vis_mode, VIS_TYPE_CLIENT_UPDATE);
 	atomic_set(&bat_priv->gw_mode, GW_MODE_OFF);
 	atomic_set(&bat_priv->gw_sel_class, 20);
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index d630564..d0ed931 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -781,6 +781,18 @@ static void tt_global_table_free(struct bat_priv *bat_priv)
 	bat_priv->tt_global_hash = NULL;
 }
 
+static bool _is_ap_isolated(struct tt_local_entry *tt_local_entry,
+			    struct tt_global_entry *tt_global_entry)
+{
+	bool ret = false;
+
+	if (tt_local_entry->flags & TT_CLIENT_WIFI &&
+	    tt_global_entry->flags & TT_CLIENT_WIFI)
+		ret = true;
+
+	return ret;
+}
+
 struct orig_node *transtable_search(struct bat_priv *bat_priv,
 				    const uint8_t *addr)
 {
@@ -1729,3 +1741,33 @@ void tt_commit_changes(struct bat_priv *bat_priv)
 	atomic_inc(&bat_priv->ttvn);
 	bat_priv->tt_poss_change = false;
 }
+
+bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst)
+{
+	struct tt_local_entry *tt_local_entry = NULL;
+	struct tt_global_entry *tt_global_entry = NULL;
+	bool ret = true;
+
+	if (!atomic_read(&bat_priv->ap_isolation))
+		return false;
+
+	tt_local_entry = tt_local_hash_find(bat_priv, dst);
+	if (!tt_local_entry)
+		goto out;
+
+	tt_global_entry = tt_global_hash_find(bat_priv, src);
+	if (!tt_global_entry)
+		goto out;
+
+	if (_is_ap_isolated(tt_local_entry, tt_global_entry))
+		goto out;
+
+	ret = false;
+
+out:
+	if (tt_global_entry)
+		tt_global_entry_free_ref(tt_global_entry);
+	if (tt_local_entry)
+		tt_local_entry_free_ref(tt_local_entry);
+	return ret;
+}
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 4d1ca35..f1d148e 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -63,5 +63,6 @@ void handle_tt_response(struct bat_priv *bat_priv,
 void send_roam_adv(struct bat_priv *bat_priv, uint8_t *client,
 		   struct orig_node *orig_node);
 void tt_commit_changes(struct bat_priv *bat_priv);
+bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst);
 
 #endif /* _NET_BATMAN_ADV_TRANSLATION_TABLE_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index bd0ced8..1ae3557 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -146,6 +146,7 @@ struct bat_priv {
 	atomic_t aggregated_ogms;	/* boolean */
 	atomic_t bonding;		/* boolean */
 	atomic_t fragmentation;		/* boolean */
+	atomic_t ap_isolation;		/* boolean */
 	atomic_t vis_mode;		/* VIS_TYPE_* */
 	atomic_t gw_mode;		/* GW_MODE_* */
 	atomic_t gw_sel_class;		/* uint */
-- 
1.7.5.3
