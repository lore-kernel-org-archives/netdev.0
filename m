From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/12] d80211: network interface sysfs attributes
Date: Thu,  8 Jun 2006 09:49:10 +0200 (CEST)
Message-ID: <20060608074910.4CC394838F@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51608 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964781AbWFHHr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:59 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add /sys/class/net/X/* attributes for 802.11 interfaces.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_i.h     |    3 
 net/d80211/ieee80211_iface.c |    1 
 net/d80211/ieee80211_sysfs.c |  299 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 301 insertions(+), 2 deletions(-)

ad13a53621edc97c9bfb41a513a674415186c392
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 9fabf17..7c1b621 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -305,6 +305,8 @@ #define NUM_DEFAULT_KEYS 4
         } u;
         int channel_use;
         int channel_use_raw;
+
+	struct attribute_group *sysfs_group;
 };
 
 #define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev)
@@ -616,5 +618,6 @@ int ieee80211_dev_sysfs_add(struct ieee8
 void ieee80211_dev_sysfs_del(struct ieee80211_local *local);
 int ieee80211_sysfs_init(void);
 void ieee80211_sysfs_deinit(void);
+int ieee80211_sysfs_change_if_type(struct net_device *dev);
 
 #endif /* IEEE80211_I_H */
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 8ab2c07..727b5e3 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -202,6 +202,7 @@ void ieee80211_if_set_type(struct net_de
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
 		       dev->name, __FUNCTION__, type);
 	}
+	ieee80211_sysfs_change_if_type(dev);
 }
 
 /* Must be called with rtnl lock held. */
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 07a7036..12d16fd 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -18,6 +18,7 @@ #include "ieee80211_proc.h"
 #include "rate_control.h"
 
 #define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
+#define to_net_dev(class)		container_of(class, struct net_device, class_dev)
 
 static inline int rtnl_lock_local(struct ieee80211_local *local)
 {
@@ -346,6 +347,238 @@ static struct attribute_group ieee80211_
 	.attrs = ieee80211_stats_attrs,
 };
 
+/* attributes in /sys/class/net/X/ */
+
+static ssize_t ieee80211_if_show(struct class_device *cd, char *buf,
+			ssize_t (*format)(const struct ieee80211_sub_if_data *,
+					  char *))
+{
+	struct net_device *dev = to_net_dev(cd);
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
+	if (dev->reg_state == NETREG_REGISTERED) {
+		ret = (*format)(sdata, buf);
+	}
+	read_unlock(&dev_base_lock);
+	return ret;
+}
+
+#define IEEE80211_IF_FMT(name, field, format_string)			\
+static ssize_t ieee80211_if_fmt_##name(const struct			\
+			ieee80211_sub_if_data *sdata, char *buf)	\
+{									\
+	return sprintf(buf, format_string, sdata->field);		\
+}
+#define IEEE80211_IF_FMT_DEC(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%d\n")
+#define IEEE80211_IF_FMT_HEX(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%#x\n")
+#define IEEE80211_IF_FMT_SIZE(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%zd\n")
+
+#define IEEE80211_IF_FMT_ATOMIC(name, field)				\
+static ssize_t ieee80211_if_fmt_##name(const struct			\
+			ieee80211_sub_if_data *sdata, char *buf)	\
+{									\
+	return sprintf(buf, "%d\n", atomic_read(&sdata->field));	\
+}
+
+#define IEEE80211_IF_FMT_MAC(name, field)				\
+static ssize_t ieee80211_if_fmt_##name(const struct			\
+			ieee80211_sub_if_data *sdata, char *buf)	\
+{									\
+	return sprintf(buf, MACSTR "\n", MAC2STR(sdata->field));	\
+}
+
+#define __IEEE80211_IF_SHOW(name)					\
+static ssize_t ieee80211_if_show_##name(struct class_device *cd,	\
+					char *buf)			\
+{									\
+	return ieee80211_if_show(cd, buf, ieee80211_if_fmt_##name);	\
+}									\
+static CLASS_DEVICE_ATTR(name, S_IRUGO, ieee80211_if_show_##name, NULL);
+
+#define IEEE80211_IF_SHOW(name, field, format)				\
+		IEEE80211_IF_FMT_##format(name, field)			\
+		__IEEE80211_IF_SHOW(name)
+
+/* common attributes */
+IEEE80211_IF_SHOW(channel_use, channel_use, DEC);
+IEEE80211_IF_SHOW(drop_unencrypted, drop_unencrypted, DEC);
+IEEE80211_IF_SHOW(eapol, eapol, DEC);
+IEEE80211_IF_SHOW(ieee8021_x, ieee802_1x, DEC);
+
+/* STA/IBSS attributes */
+IEEE80211_IF_SHOW(state, u.sta.state, DEC);
+IEEE80211_IF_SHOW(bssid, u.sta.bssid, MAC);
+IEEE80211_IF_SHOW(prev_bssid, u.sta.prev_bssid, MAC);
+IEEE80211_IF_SHOW(ssid_len, u.sta.ssid_len, SIZE);
+IEEE80211_IF_SHOW(aid, u.sta.aid, DEC);
+IEEE80211_IF_SHOW(ap_capab, u.sta.ap_capab, HEX);
+IEEE80211_IF_SHOW(capab, u.sta.capab, HEX);
+IEEE80211_IF_SHOW(extra_ie_len, u.sta.extra_ie_len, SIZE);
+IEEE80211_IF_SHOW(auth_tries, u.sta.auth_tries, DEC);
+IEEE80211_IF_SHOW(assoc_tries, u.sta.assoc_tries, DEC);
+IEEE80211_IF_SHOW(auth_algs, u.sta.auth_algs, HEX);
+IEEE80211_IF_SHOW(auth_alg, u.sta.auth_alg, DEC);
+IEEE80211_IF_SHOW(auth_transaction, u.sta.auth_transaction, DEC);
+
+static ssize_t ieee80211_if_fmt_flags(const struct
+			ieee80211_sub_if_data *sdata, char *buf)
+{
+	return sprintf(buf, "%s%s%s%s%s%s%s\n",
+		       sdata->u.sta.ssid_set ? "SSID\n" : "",
+		       sdata->u.sta.bssid_set ? "BSSID\n" : "",
+		       sdata->u.sta.prev_bssid_set ? "prev BSSID\n" : "",
+		       sdata->u.sta.authenticated ? "AUTH\n" : "",
+		       sdata->u.sta.associated ? "ASSOC\n" : "",
+		       sdata->u.sta.probereq_poll ? "PROBEREQ POLL\n" : "",
+		       sdata->u.sta.use_protection ? "CTS prot\n" : "");
+}
+__IEEE80211_IF_SHOW(flags);
+
+/* AP attributes */
+IEEE80211_IF_SHOW(max_aid, u.ap.max_aid, DEC);
+IEEE80211_IF_SHOW(num_sta_ps, u.ap.num_sta_ps, ATOMIC);
+IEEE80211_IF_SHOW(dtim_period, u.ap.dtim_period, DEC);
+IEEE80211_IF_SHOW(dtim_count, u.ap.dtim_count, DEC);
+IEEE80211_IF_SHOW(num_beacons, u.ap.num_beacons, DEC);
+IEEE80211_IF_SHOW(force_unicast_rateidx, u.ap.force_unicast_rateidx, DEC);
+IEEE80211_IF_SHOW(max_ratectrl_rateidx, u.ap.max_ratectrl_rateidx, DEC);
+
+static ssize_t ieee80211_if_fmt_num_buffered_multicast(const struct
+			ieee80211_sub_if_data *sdata, char *buf)
+{
+	return sprintf(buf, "%u\n", skb_queue_len(&sdata->u.ap.ps_bc_buf));
+}
+__IEEE80211_IF_SHOW(num_buffered_multicast);
+
+static ssize_t ieee80211_if_fmt_beacon_head_len(const struct
+			ieee80211_sub_if_data *sdata, char *buf)
+{
+	if (sdata->u.ap.beacon_head)
+		return sprintf(buf, "%d\n", sdata->u.ap.beacon_head_len);
+	return sprintf(buf, "\n");
+}
+__IEEE80211_IF_SHOW(beacon_head_len);
+
+static ssize_t ieee80211_if_fmt_beacon_tail_len(const struct
+			ieee80211_sub_if_data *sdata, char *buf)
+{
+	if (sdata->u.ap.beacon_tail)
+		return sprintf(buf, "%d\n", sdata->u.ap.beacon_tail_len);
+	return sprintf(buf, "\n");
+}
+__IEEE80211_IF_SHOW(beacon_tail_len);
+
+/* WDS attributes */
+IEEE80211_IF_SHOW(peer, u.wds.remote_addr, MAC);
+
+/* VLAN attributes */
+IEEE80211_IF_SHOW(vlan_id, u.vlan.id, DEC);
+
+/* MONITOR attributes */
+static ssize_t ieee80211_if_fmt_mode(const struct
+			ieee80211_sub_if_data *sdata, char *buf)
+{
+	struct ieee80211_local *local = sdata->local;
+
+	return sprintf(buf, "%s\n", (local->hw->monitor_during_oper ||
+				     local->open_count == local->monitors) ?
+				    "hard" : "soft");
+}
+__IEEE80211_IF_SHOW(mode);
+
+static struct attribute *ieee80211_sta_attrs[] = {
+	&class_device_attr_channel_use.attr,
+	&class_device_attr_drop_unencrypted.attr,
+	&class_device_attr_eapol.attr,
+	&class_device_attr_ieee8021_x.attr,
+	&class_device_attr_state.attr,
+	&class_device_attr_bssid.attr,
+	&class_device_attr_prev_bssid.attr,
+	&class_device_attr_ssid_len.attr,
+	&class_device_attr_aid.attr,
+	&class_device_attr_ap_capab.attr,
+	&class_device_attr_capab.attr,
+	&class_device_attr_extra_ie_len.attr,
+	&class_device_attr_auth_tries.attr,
+	&class_device_attr_assoc_tries.attr,
+	&class_device_attr_auth_algs.attr,
+	&class_device_attr_auth_alg.attr,
+	&class_device_attr_auth_transaction.attr,
+	&class_device_attr_flags.attr,
+	NULL
+};
+
+static struct attribute *ieee80211_ap_attrs[] = {
+	&class_device_attr_channel_use.attr,
+	&class_device_attr_drop_unencrypted.attr,
+	&class_device_attr_eapol.attr,
+	&class_device_attr_ieee8021_x.attr,
+	&class_device_attr_max_aid.attr,
+	&class_device_attr_num_sta_ps.attr,
+	&class_device_attr_dtim_period.attr,
+	&class_device_attr_dtim_count.attr,
+	&class_device_attr_num_beacons.attr,
+	&class_device_attr_force_unicast_rateidx.attr,
+	&class_device_attr_max_ratectrl_rateidx.attr,
+	&class_device_attr_num_buffered_multicast.attr,
+	&class_device_attr_beacon_head_len.attr,
+	&class_device_attr_beacon_tail_len.attr,
+	NULL
+};
+
+static struct attribute *ieee80211_wds_attrs[] = {
+	&class_device_attr_channel_use.attr,
+	&class_device_attr_drop_unencrypted.attr,
+	&class_device_attr_eapol.attr,
+	&class_device_attr_ieee8021_x.attr,
+	&class_device_attr_peer.attr,
+	NULL
+};
+
+static struct attribute *ieee80211_vlan_attrs[] = {
+	&class_device_attr_channel_use.attr,
+	&class_device_attr_drop_unencrypted.attr,
+	&class_device_attr_eapol.attr,
+	&class_device_attr_ieee8021_x.attr,
+	&class_device_attr_vlan_id.attr,
+	NULL
+};
+
+static struct attribute *ieee80211_monitor_attrs[] = {
+	&class_device_attr_mode.attr,
+	NULL
+};
+
+static struct attribute_group ieee80211_sta_group = {
+	.name = "sta",
+	.attrs = ieee80211_sta_attrs,
+};
+
+static struct attribute_group ieee80211_ap_group = {
+	.name = "ap",
+	.attrs = ieee80211_ap_attrs,
+};
+
+static struct attribute_group ieee80211_wds_group = {
+	.name = "wds",
+	.attrs = ieee80211_wds_attrs,
+};
+
+static struct attribute_group ieee80211_vlan_group = {
+	.name = "vlan",
+	.attrs = ieee80211_vlan_attrs,
+};
+
+static struct attribute_group ieee80211_monitor_group = {
+	.name = "monitor",
+	.attrs = ieee80211_monitor_attrs,
+};
+
 /* /sys/class/ieee80211/phyX functions */
 
 static void ieee80211_class_dev_release(struct class_device *dev)
@@ -415,16 +648,78 @@ void ieee80211_dev_sysfs_del(struct ieee
 
 /* /sys/class/net/X functions */
 
+static void __ieee80211_remove_if_group(struct kobject *kobj,
+					struct ieee80211_sub_if_data *sdata)
+{
+	if (sdata->sysfs_group) {
+		sysfs_remove_group(kobj, sdata->sysfs_group);
+		sdata->sysfs_group = NULL;
+	}
+}
+
+static inline void ieee80211_remove_if_group(struct kobject *kobj,
+					     struct net_device *dev)
+{
+	__ieee80211_remove_if_group(kobj, IEEE80211_DEV_TO_SUB_IF(dev));
+}
+
+static int ieee80211_add_if_group(struct kobject *kobj,
+				  struct net_device *dev)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	int res = 0;
+
+	__ieee80211_remove_if_group(kobj, sdata);
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+		sdata->sysfs_group = &ieee80211_sta_group;
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		sdata->sysfs_group = &ieee80211_ap_group;
+		break;
+	case IEEE80211_IF_TYPE_WDS:
+		sdata->sysfs_group = &ieee80211_wds_group;
+		break;
+	case IEEE80211_IF_TYPE_VLAN:
+		sdata->sysfs_group = &ieee80211_vlan_group;
+		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		sdata->sysfs_group = &ieee80211_monitor_group;
+		break;
+	default:
+		goto out;
+	}
+	res = sysfs_create_group(kobj, sdata->sysfs_group);
+	if (res)
+		sdata->sysfs_group = NULL;
+out:
+	return res;
+}
+
+int ieee80211_sysfs_change_if_type(struct net_device *dev)
+{
+	return ieee80211_add_if_group(&dev->class_dev.kobj, dev);
+}
+
 int ieee80211_sysfs_add_netdevice(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
+	int res;
 
-	return sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
-				 "wiphy");
+	res = sysfs_create_link(&dev->class_dev.kobj, &local->class_dev.kobj,
+				"wiphy");
+	if (res)
+		goto out;
+	res = ieee80211_add_if_group(&dev->class_dev.kobj, dev);
+	if (res)
+		sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
+out:
+	return res;
 }
 
 void ieee80211_sysfs_remove_netdevice(struct net_device *dev)
 {
+	ieee80211_remove_if_group(&dev->class_dev.kobj, dev);
 	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
 }
 
-- 
1.3.0

