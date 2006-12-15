From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH 6/6] d80211: add sysfs interface for QoS functions
Date: Thu, 14 Dec 2006 21:35:18 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B4@dhost002-46.dex002.intermedia.net>
References: <20061214040302.GA10689@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:21603 "EHLO
	dhost002-46.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750760AbWLOFs6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 00:48:58 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061214040302.GA10689@mail.intel.com>
To: <yi.zhu@intel.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is all part of the client MLME - it would be much better to add
this functionality to wpa_supplicant, rather than adding it to the
kernel. Nothing here needs to be in the kernel for any reason.

The client MLME functions that are in the kernel were put in there for
test and debugging convenience only - the right client MLME to use is
the one in wpa_supplicant. Especially with all the new and very complex
MLME functions that are being added to 802.11 we do not want this huge
amount of code in the kernel when it does not need to be there.

The client MLME in the kernel should be #ifdefed out and made a kernel
option - off by default.

Simon
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Zhu Yi
Sent: Wednesday, December 13, 2006 8:03 PM
To: netdev@vger.kernel.org
Subject: [PATCH 6/6] d80211: add sysfs interface for QoS functions

The sysfs interface here is only a proof of concept. It provides a way
for the userspace applications to use the advanced QoS features
supported by
d80211 stack. The finial solution should be switched to cfg80211.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/d80211/ieee80211_i.h     |   13 ++
 net/d80211/ieee80211_sysfs.c |  245
++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 258 insertions(+), 0 deletions(-)

83d49f70af1f38c152d8bd3abd69756ec087622e
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h index
d09f65e..7904033 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -20,6 +20,7 @@
 #include <linux/workqueue.h>
 #include <linux/types.h>
 #include <linux/spinlock.h>
+#include <net/d80211_mgmt.h>
 #include "ieee80211_key.h"
 #include "sta_info.h"
 
@@ -329,6 +330,7 @@ struct ieee80211_sub_if_data {
         int channel_use_raw;
 
 	struct attribute_group *sysfs_group;
+	struct attribute_group *sysfs_qos_group;
 };
 
 #define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev) @@ -702,6 +704,17
@@ struct sta_info * ieee80211_ibss_add_sta
 					 u8 *addr);
 int ieee80211_sta_deauthenticate(struct net_device *dev, u16 reason);
int ieee80211_sta_disassociate(struct net_device *dev, u16 reason);
+void ieee80211_send_addts(struct net_device *dev,
+			  struct ieee802_11_elem_tspec *tspec); void
wmm_send_addts(struct 
+net_device *dev,
+		    struct ieee802_11_elem_tspec *tspec); void 
+ieee80211_send_delts(struct net_device *dev, u8 tsid, u8 direction,
+			  u32 medium_time);
+void wmm_send_delts(struct net_device *dev, u8 tsid, u8 direction,
+		    u32 medium_time);
+void ieee80211_send_dls_req(struct net_device *dev, struct dls_info 
+*dls); void ieee80211_send_dls_teardown(struct net_device *dev, u8 
+*mac, u16 reason); void dls_info_add(struct ieee80211_local *local, 
+struct dls_info *dls);
 void dls_info_stop(struct ieee80211_local *local);  int
dls_link_status(struct ieee80211_local *local, u8 *addr);
 
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 6a60077..31dc1f4 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -13,6 +13,7 @@
 #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
+#include <net/d80211_mgmt.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 
@@ -21,6 +22,15 @@
 #define to_net_dev(class) \
 	container_of(class, struct net_device, class_dev)
 
+/* For sysfs and debug only */
+static struct ieee802_11_elem_tspec _tspec; static u8 
+_dls_mac[ETH_ALEN];
+
+#define TSID _tspec.ts_info.tsid
+#define TSDIR _tspec.ts_info.direction
+#define TSUP _tspec.ts_info.up
+
+
 static inline int rtnl_lock_local(struct ieee80211_local *local)  {
 	rtnl_lock();
@@ -657,6 +667,230 @@ static struct class ieee80211_class = {  #endif
};
 
+
+/* QoS sysfs entries */
+static ssize_t show_ts_info(struct class_device *dev, char *buf) {
+	/* TSID, Direction, UP */
+	return sprintf(buf, "%u %u %u\n", TSID, TSDIR, TSUP); }
+
+static ssize_t store_ts_info(struct class_device *dev, const char *buf,
+			     size_t len)
+{
+	unsigned int id, index, up;
+
+	if (sscanf(buf, "%u, %u, %u", &id, &index, &up) != 3) {
+		printk(KERN_ERR "%s: sscanf error\n", __FUNCTION__);
+		return -EINVAL;
+	}
+	if (id < 8 || id > 15) {
+		printk(KERN_ERR "invalid tsid %d\n", id);
+		return -EINVAL;
+	}
+	if ((index != 0) && (index != 1) && (index != 3)) {
+		printk(KERN_ERR "invalid direction %d\n", index);
+		return -EINVAL;
+	}
+	if (up < 0 || up > 7) {
+		printk(KERN_ERR "invalid UP %d\n", up);
+		return -EINVAL;
+	}
+	TSID = id;
+	TSDIR = index;
+	TSUP = up;
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(ts_info, S_IWUSR|S_IRUGO, show_ts_info, 
+store_ts_info);
+
+static ssize_t show_tspec(struct class_device *dev, char *buf) {
+	/* Nominal MSDU, Max MSDU, Min int, Max int, Inact int,
+	 * susp int, start, min rate, mean rate, peak rate,
+	 * max burst, delay, min phy, surp band, medium time */
+	return sprintf(buf,"%hu %hu %u %u %u %u %u %u %u %u %u %u %u %hu
%hu\n",
+		       _tspec.nominal_msdu_size,
+		       _tspec.max_msdu_size,
+		       _tspec.min_service_interval,
+		       _tspec.max_service_interval,
+		       _tspec.inactivity_interval,
+		       _tspec.suspension_interval,
+		       _tspec.service_start_time,
+		       _tspec.min_data_rate,
+		       _tspec.mean_data_rate,
+		       _tspec.peak_data_rate,
+		       _tspec.burst_size,
+		       _tspec.delay_bound,
+		       _tspec.min_phy_rate,
+		       _tspec.surplus_band_allow,
+		       _tspec.medium_time);
+}
+
+static ssize_t store_tspec(struct class_device *dev, const char *buf,
+			   size_t len)
+{
+	if (sscanf(buf, "%hu %hu %u %u %u %u %u %u %u %u %u %u %u %hu
%hu",
+		   &_tspec.nominal_msdu_size,
+		   &_tspec.max_msdu_size,
+		   &_tspec.min_service_interval,
+		   &_tspec.max_service_interval,
+		   &_tspec.inactivity_interval,
+		   &_tspec.suspension_interval,
+		   &_tspec.service_start_time,
+		   &_tspec.min_data_rate,
+		   &_tspec.mean_data_rate,
+		   &_tspec.peak_data_rate,
+		   &_tspec.burst_size,
+		   &_tspec.delay_bound,
+		   &_tspec.min_phy_rate,
+		   &_tspec.surplus_band_allow,
+		   &_tspec.medium_time) != 15) {
+		printk(KERN_ERR "%s: sscanf error\n", __FUNCTION__);
+		return -EINVAL;
+	}
+	/* Set default TSPEC Values */
+	_tspec.ts_info.access_policy = WLAN_TSINFO_EDCA;
+	_tspec.ts_info.apsd = WLAN_TSINFO_PSB_LEGACY;
+
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(tspec, S_IWUSR|S_IRUGO, show_tspec, 
+store_tspec);
+
+static ssize_t store_addts(struct class_device *dev, const char *buf,
+			   size_t len)
+{
+	struct net_device *netdev;
+
+	netdev = to_net_dev(dev);
+	ieee80211_send_addts(netdev, &_tspec);
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(addts, S_IWUSR, NULL, store_addts);
+
+static ssize_t store_addts_wmm(struct class_device *dev, const char
*buf,
+			       size_t len)
+{
+	struct net_device *netdev;
+
+	netdev = to_net_dev(dev);
+	wmm_send_addts(netdev, &_tspec);
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(addts_wmm, S_IWUSR, NULL, store_addts_wmm);
+
+static ssize_t store_delts(struct class_device *dev, const char *buf,
+			   size_t len)
+{
+	struct net_device *netdev;
+
+	netdev = to_net_dev(dev);
+	ieee80211_send_delts(netdev, TSID, TSDIR, _tspec.medium_time);
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(delts, S_IWUSR, NULL, store_delts);
+
+static ssize_t store_delts_wmm(struct class_device *dev, const char
*buf,
+			       size_t len)
+{
+	struct net_device *netdev;
+
+	netdev = to_net_dev(dev);
+	wmm_send_delts(netdev, TSID, TSDIR, _tspec.medium_time);
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(delts_wmm, S_IWUSR, NULL, store_delts_wmm);
+
+static ssize_t show_dls_mac(struct class_device *dev, char *buf) {
+	return sprintf(buf, "%02X:%02X:%02X:%02X:%02X:%02X\n",
+		       _dls_mac[0], _dls_mac[1], _dls_mac[2],
+		       _dls_mac[3], _dls_mac[4], _dls_mac[5]); }
+
+static ssize_t store_dls_mac(struct class_device *dev, const char *buf,
+			     size_t len)
+{
+	if (sscanf(buf, "%x:%x:%x:%x:%x:%x",
+		   (int *)&_dls_mac[0], (int *)&_dls_mac[1],
+		   (int *)&_dls_mac[2], (int *)&_dls_mac[3],
+		   (int *)&_dls_mac[4], (int *)&_dls_mac[5]) != 6) {
+		printk(KERN_ERR "%s: sscanf error\n", __FUNCTION__);
+		return -EINVAL;
+	}
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(dls_mac, S_IWUSR|S_IRUGO, show_dls_mac, 
+store_dls_mac);
+
+static ssize_t show_dls_op(struct class_device *dev, char *buf) {
+	return sprintf(buf, "DLS Operation: Setup = 1; Teardown = 2\n");
}
+
+static ssize_t store_dls_op(struct class_device *dev, const char *buf,
+			    size_t len)
+{
+	struct ieee80211_local *local;
+	struct net_device *netdev;
+	struct dls_info *dls;
+	unsigned int opt;
+
+	netdev = to_net_dev(dev);
+	local = netdev->ieee80211_ptr;
+
+	if (sscanf(buf, "%u", &opt) != 1) {
+		printk(KERN_ERR "%s: sscanf error\n", __FUNCTION__);
+		return -EINVAL;
+	}
+	switch (opt) {
+	case 1:
+		dls = kzalloc(sizeof(struct dls_info), GFP_KERNEL);
+		if (!dls) {
+			printk(KERN_ERR "No memory to allocate
dls_info\n");
+			return -ENOMEM;
+		}
+		atomic_set(&dls->refcnt, 1);
+		dls->status = DLS_STATUS_SETUP;
+		dls->timeout = 0;
+		memcpy(dls->addr, _dls_mac, ETH_ALEN);
+		dls_info_add(local, dls);
+		ieee80211_send_dls_req(netdev, dls);
+		break;
+	case 2:
+		ieee80211_send_dls_teardown(netdev, _dls_mac,
+					    WLAN_REASON_QSTA_NOT_USE);
+		break;
+	default:
+		printk(KERN_ERR "Unknown DLS Operation: %d\n", opt);
+		break;
+	}
+	return len;
+}
+
+static CLASS_DEVICE_ATTR(dls_op, S_IWUSR|S_IRUGO, show_dls_op, 
+store_dls_op);
+
+static struct attribute *ieee80211_qos_attrs[] = {
+	&class_device_attr_ts_info.attr,
+	&class_device_attr_tspec.attr,
+	&class_device_attr_addts.attr,
+	&class_device_attr_addts_wmm.attr,
+	&class_device_attr_delts.attr,
+	&class_device_attr_delts_wmm.attr,
+	&class_device_attr_dls_mac.attr,
+	&class_device_attr_dls_op.attr,
+	NULL
+};
+	
+static struct attribute_group ieee80211_qos_group = {
+	.name = "qos",
+	.attrs = ieee80211_qos_attrs,
+};
 void ieee80211_dev_sysfs_init(struct ieee80211_local *local)  {
 	local->class_dev.class = &ieee80211_class; @@ -696,6 +930,10 @@
void ieee80211_dev_sysfs_del(struct ieee  static void
__ieee80211_remove_if_group(struct kobject *kobj,
 					struct ieee80211_sub_if_data
*sdata)  {
+	if (sdata->sysfs_qos_group) {
+		sysfs_remove_group(kobj, sdata->sysfs_qos_group);
+		sdata->sysfs_qos_group = NULL;
+	}
 	if (sdata->sysfs_group) {
 		sysfs_remove_group(kobj, sdata->sysfs_group);
 		sdata->sysfs_group = NULL;
@@ -718,6 +956,7 @@ static int ieee80211_add_if_group(struct
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_STA:
 		sdata->sysfs_group = &ieee80211_sta_group;
+		sdata->sysfs_qos_group = &ieee80211_qos_group;
 		break;
 	case IEEE80211_IF_TYPE_AP:
 		sdata->sysfs_group = &ieee80211_ap_group; @@ -737,6
+976,12 @@ static int ieee80211_add_if_group(struct
 	res = sysfs_create_group(kobj, sdata->sysfs_group);
 	if (res)
 		sdata->sysfs_group = NULL;
+	if (sdata->sysfs_qos_group) {
+		res = sysfs_create_group(kobj, sdata->sysfs_qos_group);
+		if (res)
+			sdata->sysfs_qos_group = NULL;
+	}
+
 out:
 	return res;
 }
--
1.2.6
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
