From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/12] d80211: wiphy sysfs attributes
Date: Thu,  8 Jun 2006 09:49:09 +0200 (CEST)
Message-ID: <20060608074909.41B3548393@silver.suse.cz>
References: <20060608094822.014829000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:52632 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964780AbWFHHr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 03:47:58 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060608094822.014829000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add /sys/class/ieee80211/phyX/* attributes.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_proc.c  |    4 -
 net/d80211/ieee80211_proc.h  |    3 
 net/d80211/ieee80211_sysfs.c |  304 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 302 insertions(+), 9 deletions(-)

b049b3afd8db895dd1f6985c1d1051eb733b887b
diff --git a/net/d80211/ieee80211_proc.c b/net/d80211/ieee80211_proc.c
index 4f3a6b9..581b583 100644
--- a/net/d80211/ieee80211_proc.c
+++ b/net/d80211/ieee80211_proc.c
@@ -442,7 +442,7 @@ #endif /* CONFIG_D80211_DEBUG_COUNTERS *
 }
 
 
-static const char * ieee80211_mode_str_short(int mode)
+const char *ieee80211_mode_str_short(int mode)
 {
 	switch (mode) {
 	case MODE_IEEE80211A:
@@ -459,7 +459,7 @@ static const char * ieee80211_mode_str_s
 }
 
 
-static const char * ieee80211_mode_str(int mode)
+const char *ieee80211_mode_str(int mode)
 {
 	switch (mode) {
 	case MODE_IEEE80211A:
diff --git a/net/d80211/ieee80211_proc.h b/net/d80211/ieee80211_proc.h
index 8c76560..4519d26 100644
--- a/net/d80211/ieee80211_proc.h
+++ b/net/d80211/ieee80211_proc.h
@@ -42,4 +42,7 @@ static inline void ieee80211_proc_init(v
 static inline void ieee80211_proc_deinit(void) {}
 #endif /* CONFIG_PROC_FS */
 
+const char *ieee80211_mode_str(int mode);
+const char *ieee80211_mode_str_short(int mode);
+
 #endif /* IEEE80211_PROC_H */
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index e799506..07a7036 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -14,6 +14,8 @@ #include <linux/netdevice.h>
 #include <linux/rtnetlink.h>
 #include <net/d80211.h>
 #include "ieee80211_i.h"
+#include "ieee80211_proc.h"
+#include "rate_control.h"
 
 #define to_ieee80211_local(class)	container_of(class, struct ieee80211_local, class_dev)
 
@@ -27,6 +29,8 @@ static inline int rtnl_lock_local(struct
 	return 0;
 }
 
+/* attributes in /sys/class/ieee80211/phyX/ */
+
 static ssize_t store_add_iface(struct class_device *dev,
 			       const char *buf, size_t len)
 {
@@ -66,6 +70,284 @@ static ssize_t store_remove_iface(struct
 	return res < 0 ? res : len;
 }
 
+static ssize_t ieee80211_local_show(struct class_device *dev, char *buf,
+			ssize_t (*format)(struct ieee80211_local *, char *))
+{
+	struct ieee80211_local *local = to_ieee80211_local(dev);
+	ssize_t ret = -EINVAL;
+
+	if (local->reg_state == IEEE80211_DEV_REGISTERED)
+		ret = (*format)(local, buf);
+	return ret;
+}
+
+#define IEEE80211_LOCAL_FMT(name, field, format_string)			\
+static ssize_t ieee80211_local_fmt_##name(struct ieee80211_local *local,\
+					  char *buf)			\
+{									\
+	return sprintf(buf, format_string, local->field);		\
+}
+
+#define __IEEE80211_LOCAL_SHOW(name)					\
+static ssize_t ieee80211_local_show_##name(struct class_device *cd,	\
+					   char *buf)			\
+{									\
+	return ieee80211_local_show(cd, buf,				\
+				    ieee80211_local_fmt_##name);	\
+}
+
+#define IEEE80211_LOCAL_SHOW(name, field, format)			\
+		IEEE80211_LOCAL_FMT(name, field, format "\n")		\
+		__IEEE80211_LOCAL_SHOW(name)
+
+IEEE80211_LOCAL_SHOW(channel, conf.channel, "%d");
+IEEE80211_LOCAL_SHOW(frequency, conf.freq, "%d");
+IEEE80211_LOCAL_SHOW(radar_detect, conf.radar_detect, "%d");
+IEEE80211_LOCAL_SHOW(antenna_sel, conf.antenna_sel, "%d");
+IEEE80211_LOCAL_SHOW(calib_int, conf.calib_int, "%d");
+IEEE80211_LOCAL_SHOW(bridge_packets, bridge_packets, "%d");
+IEEE80211_LOCAL_SHOW(key_tx_rx_threshold, key_tx_rx_threshold, "%d");
+IEEE80211_LOCAL_SHOW(rts_threshold, rts_threshold, "%d");
+IEEE80211_LOCAL_SHOW(fragmentation_threshold, fragmentation_threshold, "%d");
+IEEE80211_LOCAL_SHOW(short_retry_limit, short_retry_limit, "%d");
+IEEE80211_LOCAL_SHOW(long_retry_limit, long_retry_limit, "%d");
+IEEE80211_LOCAL_SHOW(total_ps_buffered, total_ps_buffered, "%d");
+
+static ssize_t ieee80211_local_fmt_mode(struct ieee80211_local *local,
+					char *buf)
+{
+	return sprintf(buf, "%s\n", ieee80211_mode_str(local->conf.phymode));
+}
+__IEEE80211_LOCAL_SHOW(mode);
+
+static ssize_t ieee80211_local_fmt_wep_iv(struct ieee80211_local *local,
+					  char *buf)
+{
+	return sprintf(buf, "%#06x\n", local->wep_iv & 0xffffff);
+}
+__IEEE80211_LOCAL_SHOW(wep_iv);
+
+static ssize_t ieee80211_local_fmt_tx_power_reduction(struct ieee80211_local
+						      *local, char *buf)
+{
+	short tx_power_reduction = local->conf.tx_power_reduction;
+
+	return sprintf(buf, "%d.%d dBm\n", tx_power_reduction / 10,
+		       tx_power_reduction % 10);
+}
+__IEEE80211_LOCAL_SHOW(tx_power_reduction);
+
+static ssize_t ieee80211_local_fmt_modes(struct ieee80211_local *local,
+					 char *buf)
+{
+	int i;
+	struct ieee80211_hw_modes *mode;
+	char *p = buf;
+
+	/* FIXME: locking against ieee80211_update_hw? */
+	for (i = 0; i < local->hw->num_modes; i++) {
+		mode = &local->hw->modes[i];
+		p += sprintf(p, "%s\n", ieee80211_mode_str_short(mode->mode));
+	}
+	return (p - buf);
+}
+__IEEE80211_LOCAL_SHOW(modes);
+
+static ssize_t ieee80211_local_fmt_rate_ctrl_alg(struct ieee80211_local *local,
+						 char *buf)
+{
+	if (local->rate_ctrl && local->rate_ctrl_priv)
+		return sprintf(buf, "%s\n", local->rate_ctrl->name);
+	return 0;
+}
+__IEEE80211_LOCAL_SHOW(rate_ctrl_alg);
+
+static struct class_device_attribute ieee80211_class_dev_attrs[] = {
+	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
+	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
+	__ATTR(channel, S_IRUGO, ieee80211_local_show_channel, NULL),
+	__ATTR(frequency, S_IRUGO, ieee80211_local_show_frequency, NULL),
+	__ATTR(radar_detect, S_IRUGO, ieee80211_local_show_radar_detect, NULL),
+	__ATTR(antenna_sel, S_IRUGO, ieee80211_local_show_antenna_sel, NULL),
+	__ATTR(calib_int, S_IRUGO, ieee80211_local_show_calib_int, NULL),
+	__ATTR(bridge_packets, S_IRUGO, ieee80211_local_show_bridge_packets, NULL),
+	__ATTR(key_tx_rx_threshold, S_IRUGO, ieee80211_local_show_key_tx_rx_threshold, NULL),
+	__ATTR(rts_threshold, S_IRUGO, ieee80211_local_show_rts_threshold, NULL),
+	__ATTR(fragmentation_threshold, S_IRUGO, ieee80211_local_show_fragmentation_threshold, NULL),
+	__ATTR(short_retry_limit, S_IRUGO, ieee80211_local_show_short_retry_limit, NULL),
+	__ATTR(long_retry_limit, S_IRUGO, ieee80211_local_show_long_retry_limit, NULL),
+	__ATTR(total_ps_buffered, S_IRUGO, ieee80211_local_show_total_ps_buffered, NULL),
+	__ATTR(mode, S_IRUGO, ieee80211_local_show_mode, NULL),
+	__ATTR(wep_iv, S_IRUGO, ieee80211_local_show_wep_iv, NULL),
+	__ATTR(tx_power_reduction, S_IRUGO, ieee80211_local_show_tx_power_reduction, NULL),
+	__ATTR(modes, S_IRUGO, ieee80211_local_show_modes, NULL),
+	__ATTR(rate_ctrl_alg, S_IRUGO, ieee80211_local_show_rate_ctrl_alg, NULL),
+	{}
+};
+
+/* attributes in /sys/class/ieee80211/phyX/statistics/ */
+
+#define IEEE80211_LOCAL_ATTR(name, field, format)			\
+IEEE80211_LOCAL_SHOW(name, field, format)				\
+static CLASS_DEVICE_ATTR(name, S_IRUGO, ieee80211_local_show_##name, NULL);
+
+IEEE80211_LOCAL_ATTR(transmitted_fragment_count, dot11TransmittedFragmentCount, "%u");
+IEEE80211_LOCAL_ATTR(multicast_transmitted_frame_count, dot11MulticastTransmittedFrameCount, "%u");
+IEEE80211_LOCAL_ATTR(failed_count, dot11FailedCount, "%u");
+IEEE80211_LOCAL_ATTR(retry_count, dot11RetryCount, "%u");
+IEEE80211_LOCAL_ATTR(multiple_retry_count, dot11MultipleRetryCount, "%u");
+IEEE80211_LOCAL_ATTR(frame_duplicate_count, dot11FrameDuplicateCount, "%u");
+IEEE80211_LOCAL_ATTR(received_fragment_count, dot11ReceivedFragmentCount, "%u");
+IEEE80211_LOCAL_ATTR(multicast_received_frame_count, dot11MulticastReceivedFrameCount, "%u");
+IEEE80211_LOCAL_ATTR(transmitted_frame_count, dot11TransmittedFrameCount, "%u");
+IEEE80211_LOCAL_ATTR(wep_undecryptable_count, dot11WEPUndecryptableCount, "%u");
+IEEE80211_LOCAL_ATTR(num_scans, scan.num_scans, "%u");
+
+#ifdef CONFIG_D80211_DEBUG_COUNTERS
+IEEE80211_LOCAL_ATTR(tx_handlers_drop, tx_handlers_drop, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_queued, tx_handlers_queued, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_unencrypted, tx_handlers_drop_unencrypted, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_fragment, tx_handlers_drop_fragment, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_wep, tx_handlers_drop_wep, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_rate_limit, tx_handlers_drop_rate_limit, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_not_assoc, tx_handlers_drop_not_assoc, "%u");
+IEEE80211_LOCAL_ATTR(tx_handlers_drop_unauth_port, tx_handlers_drop_unauth_port, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop, rx_handlers_drop, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_queued, rx_handlers_queued, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_nullfunc, rx_handlers_drop_nullfunc, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_defrag, rx_handlers_drop_defrag, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_short, rx_handlers_drop_short, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_drop_passive_scan, rx_handlers_drop_passive_scan, "%u");
+IEEE80211_LOCAL_ATTR(tx_expand_skb_head, tx_expand_skb_head, "%u");
+IEEE80211_LOCAL_ATTR(tx_expand_skb_head_cloned, tx_expand_skb_head_cloned, "%u");
+IEEE80211_LOCAL_ATTR(rx_expand_skb_head, rx_expand_skb_head, "%u");
+IEEE80211_LOCAL_ATTR(rx_expand_skb_head2, rx_expand_skb_head2, "%u");
+IEEE80211_LOCAL_ATTR(rx_handlers_fragments, rx_handlers_fragments, "%u");
+IEEE80211_LOCAL_ATTR(tx_status_drop, tx_status_drop, "%u");
+
+static ssize_t ieee80211_local_fmt_wme_rx_queue(struct ieee80211_local *local,
+						char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += sprintf(p, "%u\n", local->wme_rx_queue[i]);
+	return (p - buf);
+}
+__IEEE80211_LOCAL_SHOW(wme_rx_queue);
+static CLASS_DEVICE_ATTR(wme_rx_queue, S_IRUGO,
+			 ieee80211_local_show_wme_rx_queue, NULL);
+
+static ssize_t ieee80211_local_fmt_wme_tx_queue(struct ieee80211_local *local,
+						char *buf)
+{
+	int i;
+	char *p = buf;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += sprintf(p, "%u\n", local->wme_tx_queue[i]);
+	return (p - buf);
+}
+__IEEE80211_LOCAL_SHOW(wme_tx_queue);
+static CLASS_DEVICE_ATTR(wme_tx_queue, S_IRUGO,
+			 ieee80211_local_show_wme_tx_queue, NULL);
+#endif
+
+static ssize_t ieee80211_stats_show(struct class_device *dev, char *buf,
+		ssize_t (*format)(struct ieee80211_low_level_stats *, char *))
+{
+	struct ieee80211_local *local = to_ieee80211_local(dev);
+	struct ieee80211_low_level_stats stats;
+	ssize_t ret = -EINVAL;
+
+	if (!local->hw->get_stats)
+		return -EOPNOTSUPP;
+	ret = rtnl_lock_local(local);
+	if (ret)
+		return ret;
+	ret = local->hw->get_stats(local->mdev, &stats);
+	rtnl_unlock();
+	if (!ret)
+		ret = (*format)(&stats, buf);
+	return ret;
+}
+
+#define IEEE80211_STATS_FMT(name, field, format_string)			\
+static ssize_t ieee80211_stats_fmt_##name(struct ieee80211_low_level_stats \
+					  *stats, char *buf)		\
+{									\
+	return sprintf(buf, format_string, stats->field);		\
+}
+
+#define __IEEE80211_STATS_SHOW(name)					\
+static ssize_t ieee80211_stats_show_##name(struct class_device *cd,	\
+					   char *buf)			\
+{									\
+	return ieee80211_stats_show(cd, buf,				\
+				    ieee80211_stats_fmt_##name);	\
+}
+
+#define IEEE80211_STATS_ATTR(name, field, format)			\
+IEEE80211_STATS_FMT(name, field, format "\n")				\
+__IEEE80211_STATS_SHOW(name)						\
+static CLASS_DEVICE_ATTR(name, S_IRUGO, ieee80211_stats_show_##name, NULL);
+
+IEEE80211_STATS_ATTR(ack_failure_count, dot11ACKFailureCount, "%u");
+IEEE80211_STATS_ATTR(rts_failure_count, dot11RTSFailureCount, "%u");
+IEEE80211_STATS_ATTR(fcs_error_count, dot11FCSErrorCount, "%u");
+IEEE80211_STATS_ATTR(rts_success_count, dot11RTSSuccessCount, "%u");
+
+static struct attribute *ieee80211_stats_attrs[] = {
+	&class_device_attr_transmitted_fragment_count.attr,
+	&class_device_attr_multicast_transmitted_frame_count.attr,
+	&class_device_attr_failed_count.attr,
+	&class_device_attr_retry_count.attr,
+	&class_device_attr_multiple_retry_count.attr,
+	&class_device_attr_frame_duplicate_count.attr,
+	&class_device_attr_received_fragment_count.attr,
+	&class_device_attr_multicast_received_frame_count.attr,
+	&class_device_attr_transmitted_frame_count.attr,
+	&class_device_attr_wep_undecryptable_count.attr,
+	&class_device_attr_ack_failure_count.attr,
+	&class_device_attr_rts_failure_count.attr,
+	&class_device_attr_fcs_error_count.attr,
+	&class_device_attr_rts_success_count.attr,
+	&class_device_attr_num_scans.attr,
+#ifdef CONFIG_D80211_DEBUG_COUNTERS
+	&class_device_attr_tx_handlers_drop.attr,
+	&class_device_attr_tx_handlers_queued.attr,
+	&class_device_attr_tx_handlers_drop_unencrypted.attr,
+	&class_device_attr_tx_handlers_drop_fragment.attr,
+	&class_device_attr_tx_handlers_drop_wep.attr,
+	&class_device_attr_tx_handlers_drop_rate_limit.attr,
+	&class_device_attr_tx_handlers_drop_not_assoc.attr,
+	&class_device_attr_tx_handlers_drop_unauth_port.attr,
+	&class_device_attr_rx_handlers_drop.attr,
+	&class_device_attr_rx_handlers_queued.attr,
+	&class_device_attr_rx_handlers_drop_nullfunc.attr,
+	&class_device_attr_rx_handlers_drop_defrag.attr,
+	&class_device_attr_rx_handlers_drop_short.attr,
+	&class_device_attr_rx_handlers_drop_passive_scan.attr,
+	&class_device_attr_tx_expand_skb_head.attr,
+	&class_device_attr_tx_expand_skb_head_cloned.attr,
+	&class_device_attr_rx_expand_skb_head.attr,
+	&class_device_attr_rx_expand_skb_head2.attr,
+	&class_device_attr_rx_handlers_fragments.attr,
+	&class_device_attr_tx_status_drop.attr,
+	&class_device_attr_wme_rx_queue.attr,
+	&class_device_attr_wme_tx_queue.attr,
+#endif
+	NULL,
+};
+
+static struct attribute_group ieee80211_stats_group = {
+	.name = "statistics",
+	.attrs = ieee80211_stats_attrs,
+};
+
+/* /sys/class/ieee80211/phyX functions */
+
 static void ieee80211_class_dev_release(struct class_device *dev)
 {
 	ieee80211_release_hw(to_ieee80211_local(dev));
@@ -88,12 +370,6 @@ static int ieee80211_uevent(struct class
 }
 #endif
 
-static struct class_device_attribute ieee80211_class_dev_attrs[] = {
-	__ATTR(add_iface, S_IWUSR, NULL, store_add_iface),
-	__ATTR(remove_iface, S_IWUSR, NULL, store_remove_iface),
-	{}
-};
-
 static struct class ieee80211_class = {
 	.name = "ieee80211",
 	.class_dev_attrs = ieee80211_class_dev_attrs,
@@ -117,16 +393,28 @@ void ieee80211_dev_sysfs_put(struct ieee
 
 int ieee80211_dev_sysfs_add(struct ieee80211_local *local)
 {
+	int res;
+
 	snprintf(local->class_dev.class_id, BUS_ID_SIZE,
 		 "phy%d", local->dev_index);
-	return class_device_add(&local->class_dev);
+	res = class_device_add(&local->class_dev);
+	if (res)
+		return res;
+	res = sysfs_create_group(&local->class_dev.kobj,
+				 &ieee80211_stats_group);
+	if (res)
+		class_device_del(&local->class_dev);
+	return res;
 }
 
 void ieee80211_dev_sysfs_del(struct ieee80211_local *local)
 {
+	sysfs_remove_group(&local->class_dev.kobj, &ieee80211_stats_group);
 	class_device_del(&local->class_dev);
 }
 
+/* /sys/class/net/X functions */
+
 int ieee80211_sysfs_add_netdevice(struct net_device *dev)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
@@ -140,6 +428,8 @@ void ieee80211_sysfs_remove_netdevice(st
 	sysfs_remove_link(&dev->class_dev.kobj, "wiphy");
 }
 
+/* general module functions */
+
 int ieee80211_sysfs_init(void)
 {
 	return class_register(&ieee80211_class);
-- 
1.3.0

