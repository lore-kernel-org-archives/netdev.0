From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 3/4 (resend)] mac80211: add debugfs attributes
Date: Sat, 5 May 2007 09:45:28 -0400
Message-ID: <20070505134528.GC4155@tuxdriver.com>
References: <20070505031749.GA5308@tuxdriver.com> <20070505134255.GA4155@tuxdriver.com> <20070505134438.GB4155@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070505134438.GB4155-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>

Export various mac80211 internal variables through debugfs.

Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
 net/mac80211/Kconfig           |    9 +
 net/mac80211/Makefile          |    1 +
 net/mac80211/debugfs.c         |  433 +++++++++++++++++++++++++++++++++++++++
 net/mac80211/debugfs.h         |   16 ++
 net/mac80211/debugfs_key.c     |  252 +++++++++++++++++++++++
 net/mac80211/debugfs_key.h     |   34 +++
 net/mac80211/debugfs_netdev.c  |  440 ++++++++++++++++++++++++++++++++++++++++
 net/mac80211/debugfs_netdev.h  |   30 +++
 net/mac80211/debugfs_sta.c     |  246 ++++++++++++++++++++++
 net/mac80211/debugfs_sta.h     |   12 +
 net/mac80211/ieee80211.c       |   14 ++
 net/mac80211/ieee80211_i.h     |  127 ++++++++++++
 net/mac80211/ieee80211_iface.c |    8 +
 net/mac80211/ieee80211_ioctl.c |   22 ++-
 net/mac80211/ieee80211_key.h   |   17 ++
 net/mac80211/ieee80211_rate.h  |   22 ++
 net/mac80211/rc80211_simple.c  |   71 +++++++
 net/mac80211/sta_info.c        |  108 +++++++++-
 net/mac80211/sta_info.h        |   19 ++
 19 files changed, 1866 insertions(+), 15 deletions(-)
 create mode 100644 net/mac80211/debugfs.c
 create mode 100644 net/mac80211/debugfs.h
 create mode 100644 net/mac80211/debugfs_key.c
 create mode 100644 net/mac80211/debugfs_key.h
 create mode 100644 net/mac80211/debugfs_netdev.c
 create mode 100644 net/mac80211/debugfs_netdev.h
 create mode 100644 net/mac80211/debugfs_sta.c
 create mode 100644 net/mac80211/debugfs_sta.h

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index d761b53..6fffb38 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -20,6 +20,15 @@ config MAC80211_LEDS
 	This option enables a few LED triggers for different
 	packet receive/transmit events.
 
+config MAC80211_DEBUGFS
+	bool "Export mac80211 internals in DebugFS"
+	depends on MAC80211 && DEBUG_FS
+	---help---
+	  Select this to see extensive information about
+	  the internal state of mac80211 in debugfs.
+
+	  Say N unless you know you need this.
+
 config MAC80211_DEBUG
 	bool "Enable debugging output"
 	depends on MAC80211
diff --git a/net/mac80211/Makefile b/net/mac80211/Makefile
index 79dea99..e9738da 100644
--- a/net/mac80211/Makefile
+++ b/net/mac80211/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_MAC80211) += mac80211.o rc80211_simple.o
 
 mac80211-objs-$(CONFIG_MAC80211_LEDS) += ieee80211_led.o
+mac80211-objs-$(CONFIG_MAC80211_DEBUGFS) += debugfs.o debugfs_sta.o debugfs_netdev.o debugfs_key.o
 
 mac80211-objs := \
 	ieee80211.o \
diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
new file mode 100644
index 0000000..bb6c0fe
--- /dev/null
+++ b/net/mac80211/debugfs.c
@@ -0,0 +1,433 @@
+/*
+ * mac80211 debugfs for wireless PHYs
+ *
+ * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * GPLv2
+ *
+ */
+
+#include <linux/debugfs.h>
+#include <linux/rtnetlink.h>
+#include "ieee80211_i.h"
+#include "ieee80211_rate.h"
+#include "debugfs.h"
+
+int mac80211_open_file_generic(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static const char *ieee80211_mode_str(int mode)
+{
+	switch (mode) {
+	case MODE_IEEE80211A:
+		return "IEEE 802.11a";
+	case MODE_IEEE80211B:
+		return "IEEE 802.11b";
+	case MODE_IEEE80211G:
+		return "IEEE 802.11g";
+	case MODE_ATHEROS_TURBO:
+		return "Atheros Turbo (5 GHz)";
+	default:
+		return "UNKNOWN";
+	}
+}
+
+static ssize_t modes_read(struct file *file, char __user *userbuf,
+			  size_t count, loff_t *ppos)
+{
+	struct ieee80211_local *local = file->private_data;
+	struct ieee80211_hw_mode *mode;
+	char buf[150], *p = buf;
+
+	/* FIXME: locking! */
+	list_for_each_entry(mode, &local->modes_list, list) {
+		p += scnprintf(p, sizeof(buf)+buf-p,
+			       "%s\n", ieee80211_mode_str(mode->mode));
+	}
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p-buf);
+}
+
+static const struct file_operations modes_ops = {
+	.read = modes_read,
+	.open = mac80211_open_file_generic,
+};
+
+#define DEBUGFS_READONLY_FILE(name, buflen, fmt, value...)		\
+static ssize_t name## _read(struct file *file, char __user *userbuf,	\
+			    size_t count, loff_t *ppos)			\
+{									\
+	struct ieee80211_local *local = file->private_data;		\
+	char buf[buflen];						\
+	int res;							\
+									\
+	res = scnprintf(buf, buflen, fmt "\n", ##value);		\
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);	\
+}									\
+									\
+static const struct file_operations name## _ops = {			\
+	.read = name## _read,						\
+	.open = mac80211_open_file_generic,				\
+};
+
+#define DEBUGFS_ADD(name)						\
+	local->debugfs.name = debugfs_create_file(#name, 0444, phyd,	\
+						  local, &name## _ops);
+
+#define DEBUGFS_DEL(name)						\
+	debugfs_remove(local->debugfs.name);				\
+	local->debugfs.name = NULL;
+
+
+DEBUGFS_READONLY_FILE(channel, 20, "%d",
+		      local->hw.conf.channel);
+DEBUGFS_READONLY_FILE(frequency, 20, "%d",
+		      local->hw.conf.freq);
+DEBUGFS_READONLY_FILE(radar_detect, 20, "%d",
+		      local->hw.conf.radar_detect);
+DEBUGFS_READONLY_FILE(antenna_sel_tx, 20, "%d",
+		      local->hw.conf.antenna_sel_tx);
+DEBUGFS_READONLY_FILE(antenna_sel_rx, 20, "%d",
+		      local->hw.conf.antenna_sel_rx);
+DEBUGFS_READONLY_FILE(bridge_packets, 20, "%d",
+		      local->bridge_packets);
+DEBUGFS_READONLY_FILE(key_tx_rx_threshold, 20, "%d",
+		      local->key_tx_rx_threshold);
+DEBUGFS_READONLY_FILE(rts_threshold, 20, "%d",
+		      local->rts_threshold);
+DEBUGFS_READONLY_FILE(fragmentation_threshold, 20, "%d",
+		      local->fragmentation_threshold);
+DEBUGFS_READONLY_FILE(short_retry_limit, 20, "%d",
+		      local->short_retry_limit);
+DEBUGFS_READONLY_FILE(long_retry_limit, 20, "%d",
+		      local->long_retry_limit);
+DEBUGFS_READONLY_FILE(total_ps_buffered, 20, "%d",
+		      local->total_ps_buffered);
+DEBUGFS_READONLY_FILE(mode, 20, "%s",
+		      ieee80211_mode_str(local->hw.conf.phymode));
+DEBUGFS_READONLY_FILE(wep_iv, 20, "%#06x",
+		      local->wep_iv & 0xffffff);
+DEBUGFS_READONLY_FILE(tx_power_reduction, 20, "%d.%d dBm",
+		      local->hw.conf.tx_power_reduction / 10,
+		      local->hw.conf.tx_power_reduction & 10);
+DEBUGFS_READONLY_FILE(rate_ctrl_alg, 100, "%s",
+		      local->rate_ctrl ? local->rate_ctrl->ops->name : "<unset>");
+
+/* statistics stuff */
+
+static inline int rtnl_lock_local(struct ieee80211_local *local)
+{
+	rtnl_lock();
+	if (unlikely(local->reg_state != IEEE80211_DEV_REGISTERED)) {
+		rtnl_unlock();
+		return -ENODEV;
+	}
+	return 0;
+}
+
+#define DEBUGFS_STATS_FILE(name, buflen, fmt, value...)			\
+	DEBUGFS_READONLY_FILE(stats_ ##name, buflen, fmt, ##value)
+
+static ssize_t format_devstat_counter(struct ieee80211_local *local,
+	char __user *userbuf,
+	size_t count, loff_t *ppos,
+	int (*printvalue)(struct ieee80211_low_level_stats *stats, char *buf,
+			  int buflen))
+{
+	struct ieee80211_low_level_stats stats;
+	char buf[20];
+	int res;
+
+	if (!local->ops->get_stats)
+		return -EOPNOTSUPP;
+
+	res = rtnl_lock_local(local);
+	if (res)
+		return res;
+
+	res = local->ops->get_stats(local_to_hw(local), &stats);
+	rtnl_unlock();
+	if (!res)
+		res = printvalue(&stats, buf, sizeof(buf));
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+
+#define DEBUGFS_DEVSTATS_FILE(name)					\
+static int print_devstats_##name(struct ieee80211_low_level_stats *stats,\
+				 char *buf, int buflen)			\
+{									\
+	return scnprintf(buf, buflen, "%u\n", stats->name);		\
+}									\
+static ssize_t stats_ ##name## _read(struct file *file,			\
+				     char __user *userbuf,		\
+				     size_t count, loff_t *ppos)	\
+{									\
+	return format_devstat_counter(file->private_data,		\
+				      userbuf,				\
+				      count,				\
+				      ppos,				\
+				      print_devstats_##name);		\
+}									\
+									\
+static const struct file_operations stats_ ##name## _ops = {		\
+	.read = stats_ ##name## _read,					\
+	.open = mac80211_open_file_generic,				\
+};
+
+#define DEBUGFS_STATS_ADD(name)						\
+	local->debugfs.stats.name = debugfs_create_file(#name, 0444, statsd,\
+		local, &stats_ ##name## _ops);
+
+#define DEBUGFS_STATS_DEL(name)						\
+	debugfs_remove(local->debugfs.stats.name);			\
+	local->debugfs.stats.name = NULL;
+
+DEBUGFS_STATS_FILE(transmitted_fragment_count, 20, "%u",
+		   local->dot11TransmittedFragmentCount);
+DEBUGFS_STATS_FILE(multicast_transmitted_frame_count, 20, "%u",
+		   local->dot11MulticastTransmittedFrameCount);
+DEBUGFS_STATS_FILE(failed_count, 20, "%u",
+		   local->dot11FailedCount);
+DEBUGFS_STATS_FILE(retry_count, 20, "%u",
+		   local->dot11RetryCount);
+DEBUGFS_STATS_FILE(multiple_retry_count, 20, "%u",
+		   local->dot11MultipleRetryCount);
+DEBUGFS_STATS_FILE(frame_duplicate_count, 20, "%u",
+		   local->dot11FrameDuplicateCount);
+DEBUGFS_STATS_FILE(received_fragment_count, 20, "%u",
+		   local->dot11ReceivedFragmentCount);
+DEBUGFS_STATS_FILE(multicast_received_frame_count, 20, "%u",
+		   local->dot11MulticastReceivedFrameCount);
+DEBUGFS_STATS_FILE(transmitted_frame_count, 20, "%u",
+		   local->dot11TransmittedFrameCount);
+DEBUGFS_STATS_FILE(wep_undecryptable_count, 20, "%u",
+		   local->dot11WEPUndecryptableCount);
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+DEBUGFS_STATS_FILE(tx_handlers_drop, 20, "%u",
+		   local->tx_handlers_drop);
+DEBUGFS_STATS_FILE(tx_handlers_queued, 20, "%u",
+		   local->tx_handlers_queued);
+DEBUGFS_STATS_FILE(tx_handlers_drop_unencrypted, 20, "%u",
+		   local->tx_handlers_drop_unencrypted);
+DEBUGFS_STATS_FILE(tx_handlers_drop_fragment, 20, "%u",
+		   local->tx_handlers_drop_fragment);
+DEBUGFS_STATS_FILE(tx_handlers_drop_wep, 20, "%u",
+		   local->tx_handlers_drop_wep);
+DEBUGFS_STATS_FILE(tx_handlers_drop_not_assoc, 20, "%u",
+		   local->tx_handlers_drop_not_assoc);
+DEBUGFS_STATS_FILE(tx_handlers_drop_unauth_port, 20, "%u",
+		   local->tx_handlers_drop_unauth_port);
+DEBUGFS_STATS_FILE(rx_handlers_drop, 20, "%u",
+		   local->rx_handlers_drop);
+DEBUGFS_STATS_FILE(rx_handlers_queued, 20, "%u",
+		   local->rx_handlers_queued);
+DEBUGFS_STATS_FILE(rx_handlers_drop_nullfunc, 20, "%u",
+		   local->rx_handlers_drop_nullfunc);
+DEBUGFS_STATS_FILE(rx_handlers_drop_defrag, 20, "%u",
+		   local->rx_handlers_drop_defrag);
+DEBUGFS_STATS_FILE(rx_handlers_drop_short, 20, "%u",
+		   local->rx_handlers_drop_short);
+DEBUGFS_STATS_FILE(rx_handlers_drop_passive_scan, 20, "%u",
+		   local->rx_handlers_drop_passive_scan);
+DEBUGFS_STATS_FILE(tx_expand_skb_head, 20, "%u",
+		   local->tx_expand_skb_head);
+DEBUGFS_STATS_FILE(tx_expand_skb_head_cloned, 20, "%u",
+		   local->tx_expand_skb_head_cloned);
+DEBUGFS_STATS_FILE(rx_expand_skb_head, 20, "%u",
+		   local->rx_expand_skb_head);
+DEBUGFS_STATS_FILE(rx_expand_skb_head2, 20, "%u",
+		   local->rx_expand_skb_head2);
+DEBUGFS_STATS_FILE(rx_handlers_fragments, 20, "%u",
+		   local->rx_handlers_fragments);
+DEBUGFS_STATS_FILE(tx_status_drop, 20, "%u",
+		   local->tx_status_drop);
+
+static ssize_t stats_wme_rx_queue_read(struct file *file,
+				       char __user *userbuf,
+				       size_t count, loff_t *ppos)
+{
+	struct ieee80211_local *local = file->private_data;
+	char buf[NUM_RX_DATA_QUEUES*15], *p = buf;
+	int i;
+
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += scnprintf(p, sizeof(buf)+buf-p,
+			       "%u\n", local->wme_rx_queue[i]);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p-buf);
+}
+
+static const struct file_operations stats_wme_rx_queue_ops = {
+	.read = stats_wme_rx_queue_read,
+	.open = mac80211_open_file_generic,
+};
+
+static ssize_t stats_wme_tx_queue_read(struct file *file,
+				       char __user *userbuf,
+				       size_t count, loff_t *ppos)
+{
+	struct ieee80211_local *local = file->private_data;
+	char buf[NUM_TX_DATA_QUEUES*15], *p = buf;
+	int i;
+
+	for (i = 0; i < NUM_TX_DATA_QUEUES; i++)
+		p += scnprintf(p, sizeof(buf)+buf-p,
+			       "%u\n", local->wme_tx_queue[i]);
+
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p-buf);
+}
+
+static const struct file_operations stats_wme_tx_queue_ops = {
+	.read = stats_wme_tx_queue_read,
+	.open = mac80211_open_file_generic,
+};
+#endif
+
+DEBUGFS_DEVSTATS_FILE(dot11ACKFailureCount);
+DEBUGFS_DEVSTATS_FILE(dot11RTSFailureCount);
+DEBUGFS_DEVSTATS_FILE(dot11FCSErrorCount);
+DEBUGFS_DEVSTATS_FILE(dot11RTSSuccessCount);
+
+
+void debugfs_hw_add(struct ieee80211_local *local)
+{
+	struct dentry *phyd = local->hw.wiphy->debugfsdir;
+	struct dentry *statsd;
+
+	if (!phyd)
+		return;
+
+	local->debugfs.stations = debugfs_create_dir("stations", phyd);
+	local->debugfs.keys = debugfs_create_dir("keys", phyd);
+
+	DEBUGFS_ADD(channel);
+	DEBUGFS_ADD(frequency);
+	DEBUGFS_ADD(radar_detect);
+	DEBUGFS_ADD(antenna_sel_tx);
+	DEBUGFS_ADD(antenna_sel_rx);
+	DEBUGFS_ADD(bridge_packets);
+	DEBUGFS_ADD(key_tx_rx_threshold);
+	DEBUGFS_ADD(rts_threshold);
+	DEBUGFS_ADD(fragmentation_threshold);
+	DEBUGFS_ADD(short_retry_limit);
+	DEBUGFS_ADD(long_retry_limit);
+	DEBUGFS_ADD(total_ps_buffered);
+	DEBUGFS_ADD(mode);
+	DEBUGFS_ADD(wep_iv);
+	DEBUGFS_ADD(tx_power_reduction);
+	DEBUGFS_ADD(modes);
+
+	statsd = debugfs_create_dir("statistics", phyd);
+	local->debugfs.statistics = statsd;
+
+	/* if the dir failed, don't put all the other things into the root! */
+	if (!statsd)
+		return;
+
+	DEBUGFS_STATS_ADD(transmitted_fragment_count);
+	DEBUGFS_STATS_ADD(multicast_transmitted_frame_count);
+	DEBUGFS_STATS_ADD(failed_count);
+	DEBUGFS_STATS_ADD(retry_count);
+	DEBUGFS_STATS_ADD(multiple_retry_count);
+	DEBUGFS_STATS_ADD(frame_duplicate_count);
+	DEBUGFS_STATS_ADD(received_fragment_count);
+	DEBUGFS_STATS_ADD(multicast_received_frame_count);
+	DEBUGFS_STATS_ADD(transmitted_frame_count);
+	DEBUGFS_STATS_ADD(wep_undecryptable_count);
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+	DEBUGFS_STATS_ADD(tx_handlers_drop);
+	DEBUGFS_STATS_ADD(tx_handlers_queued);
+	DEBUGFS_STATS_ADD(tx_handlers_drop_unencrypted);
+	DEBUGFS_STATS_ADD(tx_handlers_drop_fragment);
+	DEBUGFS_STATS_ADD(tx_handlers_drop_wep);
+	DEBUGFS_STATS_ADD(tx_handlers_drop_not_assoc);
+	DEBUGFS_STATS_ADD(tx_handlers_drop_unauth_port);
+	DEBUGFS_STATS_ADD(rx_handlers_drop);
+	DEBUGFS_STATS_ADD(rx_handlers_queued);
+	DEBUGFS_STATS_ADD(rx_handlers_drop_nullfunc);
+	DEBUGFS_STATS_ADD(rx_handlers_drop_defrag);
+	DEBUGFS_STATS_ADD(rx_handlers_drop_short);
+	DEBUGFS_STATS_ADD(rx_handlers_drop_passive_scan);
+	DEBUGFS_STATS_ADD(tx_expand_skb_head);
+	DEBUGFS_STATS_ADD(tx_expand_skb_head_cloned);
+	DEBUGFS_STATS_ADD(rx_expand_skb_head);
+	DEBUGFS_STATS_ADD(rx_expand_skb_head2);
+	DEBUGFS_STATS_ADD(rx_handlers_fragments);
+	DEBUGFS_STATS_ADD(tx_status_drop);
+	DEBUGFS_STATS_ADD(wme_tx_queue);
+	DEBUGFS_STATS_ADD(wme_rx_queue);
+#endif
+	DEBUGFS_STATS_ADD(dot11ACKFailureCount);
+	DEBUGFS_STATS_ADD(dot11RTSFailureCount);
+	DEBUGFS_STATS_ADD(dot11FCSErrorCount);
+	DEBUGFS_STATS_ADD(dot11RTSSuccessCount);
+}
+
+void debugfs_hw_del(struct ieee80211_local *local)
+{
+	DEBUGFS_DEL(channel);
+	DEBUGFS_DEL(frequency);
+	DEBUGFS_DEL(radar_detect);
+	DEBUGFS_DEL(antenna_sel_tx);
+	DEBUGFS_DEL(antenna_sel_rx);
+	DEBUGFS_DEL(bridge_packets);
+	DEBUGFS_DEL(key_tx_rx_threshold);
+	DEBUGFS_DEL(rts_threshold);
+	DEBUGFS_DEL(fragmentation_threshold);
+	DEBUGFS_DEL(short_retry_limit);
+	DEBUGFS_DEL(long_retry_limit);
+	DEBUGFS_DEL(total_ps_buffered);
+	DEBUGFS_DEL(mode);
+	DEBUGFS_DEL(wep_iv);
+	DEBUGFS_DEL(tx_power_reduction);
+	DEBUGFS_DEL(modes);
+
+	DEBUGFS_STATS_DEL(transmitted_fragment_count);
+	DEBUGFS_STATS_DEL(multicast_transmitted_frame_count);
+	DEBUGFS_STATS_DEL(failed_count);
+	DEBUGFS_STATS_DEL(retry_count);
+	DEBUGFS_STATS_DEL(multiple_retry_count);
+	DEBUGFS_STATS_DEL(frame_duplicate_count);
+	DEBUGFS_STATS_DEL(received_fragment_count);
+	DEBUGFS_STATS_DEL(multicast_received_frame_count);
+	DEBUGFS_STATS_DEL(transmitted_frame_count);
+	DEBUGFS_STATS_DEL(wep_undecryptable_count);
+	DEBUGFS_STATS_DEL(num_scans);
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+	DEBUGFS_STATS_DEL(tx_handlers_drop);
+	DEBUGFS_STATS_DEL(tx_handlers_queued);
+	DEBUGFS_STATS_DEL(tx_handlers_drop_unencrypted);
+	DEBUGFS_STATS_DEL(tx_handlers_drop_fragment);
+	DEBUGFS_STATS_DEL(tx_handlers_drop_wep);
+	DEBUGFS_STATS_DEL(tx_handlers_drop_not_assoc);
+	DEBUGFS_STATS_DEL(tx_handlers_drop_unauth_port);
+	DEBUGFS_STATS_DEL(rx_handlers_drop);
+	DEBUGFS_STATS_DEL(rx_handlers_queued);
+	DEBUGFS_STATS_DEL(rx_handlers_drop_nullfunc);
+	DEBUGFS_STATS_DEL(rx_handlers_drop_defrag);
+	DEBUGFS_STATS_DEL(rx_handlers_drop_short);
+	DEBUGFS_STATS_DEL(rx_handlers_drop_passive_scan);
+	DEBUGFS_STATS_DEL(tx_expand_skb_head);
+	DEBUGFS_STATS_DEL(tx_expand_skb_head_cloned);
+	DEBUGFS_STATS_DEL(rx_expand_skb_head);
+	DEBUGFS_STATS_DEL(rx_expand_skb_head2);
+	DEBUGFS_STATS_DEL(rx_handlers_fragments);
+	DEBUGFS_STATS_DEL(tx_status_drop);
+	DEBUGFS_STATS_DEL(wme_tx_queue);
+	DEBUGFS_STATS_DEL(wme_rx_queue);
+#endif
+	DEBUGFS_STATS_DEL(dot11ACKFailureCount);
+	DEBUGFS_STATS_DEL(dot11RTSFailureCount);
+	DEBUGFS_STATS_DEL(dot11FCSErrorCount);
+	DEBUGFS_STATS_DEL(dot11RTSSuccessCount);
+
+	debugfs_remove(local->debugfs.statistics);
+	local->debugfs.statistics = NULL;
+	debugfs_remove(local->debugfs.stations);
+	local->debugfs.stations = NULL;
+	debugfs_remove(local->debugfs.keys);
+	local->debugfs.keys = NULL;
+}
diff --git a/net/mac80211/debugfs.h b/net/mac80211/debugfs.h
new file mode 100644
index 0000000..dd25419
--- /dev/null
+++ b/net/mac80211/debugfs.h
@@ -0,0 +1,16 @@
+#ifndef __MAC80211_DEBUGFS_H
+#define __MAC80211_DEBUGFS_H
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+extern void debugfs_hw_add(struct ieee80211_local *local);
+extern void debugfs_hw_del(struct ieee80211_local *local);
+extern int mac80211_open_file_generic(struct inode *inode, struct file *file);
+#else
+static inline void debugfs_hw_add(struct ieee80211_local *local)
+{
+	return;
+}
+static inline void debugfs_hw_del(struct ieee80211_local *local) {}
+#endif
+
+#endif /* __MAC80211_DEBUGFS_H */
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
new file mode 100644
index 0000000..7d56dc9
--- /dev/null
+++ b/net/mac80211/debugfs_key.c
@@ -0,0 +1,252 @@
+/*
+ * Copyright 2003-2005	Devicescape Software, Inc.
+ * Copyright (c) 2006	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
+ * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kobject.h>
+#include "ieee80211_i.h"
+#include "ieee80211_key.h"
+#include "debugfs.h"
+#include "debugfs_key.h"
+
+#define KEY_READ(name, buflen, format_string)				\
+static ssize_t key_##name##_read(struct file *file,			\
+				 char __user *userbuf,			\
+				 size_t count, loff_t *ppos)		\
+{									\
+	char buf[buflen];						\
+	struct ieee80211_key *key = file->private_data;			\
+	int res = scnprintf(buf, buflen, format_string, key->name);	\
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);	\
+}
+#define KEY_READ_D(name) KEY_READ(name, 20, "%d\n")
+
+#define KEY_OPS(name)							\
+static const struct file_operations key_ ##name## _ops = {		\
+	.read = key_##name##_read,					\
+	.open = mac80211_open_file_generic,				\
+}
+
+#define KEY_FILE(name, format)						\
+		 KEY_READ_##format(name)				\
+		 KEY_OPS(name)
+
+KEY_FILE(keylen, D);
+KEY_FILE(force_sw_encrypt, D);
+KEY_FILE(keyidx, D);
+KEY_FILE(hw_key_idx, D);
+KEY_FILE(tx_rx_count, D);
+
+static ssize_t key_algorithm_read(struct file *file,
+				  char __user *userbuf,
+				  size_t count, loff_t *ppos)
+{
+	char *alg;
+	struct ieee80211_key *key = file->private_data;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		alg = "WEP\n";
+		break;
+	case ALG_TKIP:
+		alg = "TKIP\n";
+		break;
+	case ALG_CCMP:
+		alg = "CCMP\n";
+		break;
+	default:
+		return 0;
+	}
+	return simple_read_from_buffer(userbuf, count, ppos, alg, strlen(alg));
+}
+KEY_OPS(algorithm);
+
+static ssize_t key_tx_spec_read(struct file *file, char __user *userbuf,
+				size_t count, loff_t *ppos)
+{
+	const u8 *tpn;
+	char buf[20];
+	int len;
+	struct ieee80211_key *key = file->private_data;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		len = scnprintf(buf, sizeof(buf), "\n");
+	case ALG_TKIP:
+		len = scnprintf(buf, sizeof(buf), "%08x %04x\n",
+				key->u.tkip.iv32,
+				key->u.tkip.iv16);
+	case ALG_CCMP:
+		tpn = key->u.ccmp.tx_pn;
+		len = scnprintf(buf, sizeof(buf), "%02x%02x%02x%02x%02x%02x\n",
+				tpn[0], tpn[1], tpn[2], tpn[3], tpn[4], tpn[5]);
+	default:
+		return 0;
+	}
+	return simple_read_from_buffer(userbuf, count, ppos, buf, len);
+}
+KEY_OPS(tx_spec);
+
+static ssize_t key_rx_spec_read(struct file *file, char __user *userbuf,
+				size_t count, loff_t *ppos)
+{
+	struct ieee80211_key *key = file->private_data;
+	char buf[14*NUM_RX_DATA_QUEUES+1], *p = buf;
+	int i, len;
+	const u8 *rpn;
+
+	switch (key->alg) {
+	case ALG_WEP:
+		len = scnprintf(buf, sizeof(buf), "\n");
+	case ALG_TKIP:
+		for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+			p += scnprintf(p, sizeof(buf)+buf-p,
+				       "%08x %04x\n",
+				       key->u.tkip.iv32_rx[i],
+				       key->u.tkip.iv16_rx[i]);
+		len = p - buf;
+	case ALG_CCMP:
+		for (i = 0; i < NUM_RX_DATA_QUEUES; i++) {
+			rpn = key->u.ccmp.rx_pn[i];
+			p += scnprintf(p, sizeof(buf)+buf-p,
+				       "%02x%02x%02x%02x%02x%02x\n",
+				       rpn[0], rpn[1], rpn[2],
+				       rpn[3], rpn[4], rpn[5]);
+		}
+		len = p - buf;
+	default:
+		return 0;
+	}
+	return simple_read_from_buffer(userbuf, count, ppos, buf, len);
+}
+KEY_OPS(rx_spec);
+
+static ssize_t key_replays_read(struct file *file, char __user *userbuf,
+				size_t count, loff_t *ppos)
+{
+	struct ieee80211_key *key = file->private_data;
+	char buf[20];
+	int len;
+
+	if (key->alg != ALG_CCMP)
+		return 0;
+	len = scnprintf(buf, sizeof(buf), "%u\n", key->u.ccmp.replays);
+	return simple_read_from_buffer(userbuf, count, ppos, buf, len);
+}
+KEY_OPS(replays);
+
+static ssize_t key_key_read(struct file *file, char __user *userbuf,
+			    size_t count, loff_t *ppos)
+{
+	struct ieee80211_key *key = file->private_data;
+	int i, res, bufsize = 2*key->keylen+2;
+	char *buf = kmalloc(bufsize, GFP_KERNEL);
+	char *p = buf;
+
+	for (i = 0; i < key->keylen; i++)
+		p += scnprintf(p, bufsize+buf-p, "%02x", key->key[i]);
+	p += scnprintf(p, bufsize+buf-p, "\n");
+	res = simple_read_from_buffer(userbuf, count, ppos, buf, p - buf);
+	kfree(buf);
+	return res;
+}
+KEY_OPS(key);
+
+#define DEBUGFS_ADD(name) \
+	key->debugfs.name = debugfs_create_file(#name, 0400,\
+				key->debugfs.dir, key, &key_##name##_ops);
+
+void ieee80211_debugfs_key_add(struct ieee80211_local *local,
+			       struct ieee80211_key *key)
+{
+	char buf[20];
+
+	if (!local->debugfs.keys)
+		return;
+
+	sprintf(buf, "%d", key->keyidx);
+	key->debugfs.dir = debugfs_create_dir(buf,
+					local->debugfs.keys);
+
+	if (!key->debugfs.dir)
+		return;
+
+	DEBUGFS_ADD(keylen);
+	DEBUGFS_ADD(force_sw_encrypt);
+	DEBUGFS_ADD(keyidx);
+	DEBUGFS_ADD(hw_key_idx);
+	DEBUGFS_ADD(tx_rx_count);
+	DEBUGFS_ADD(algorithm);
+	DEBUGFS_ADD(tx_spec);
+	DEBUGFS_ADD(rx_spec);
+	DEBUGFS_ADD(replays);
+	DEBUGFS_ADD(key);
+};
+
+#define DEBUGFS_DEL(name) \
+	debugfs_remove(key->debugfs.name); key->debugfs.name = NULL;
+
+void ieee80211_debugfs_key_remove(struct ieee80211_key *key)
+{
+	if (!key)
+		return;
+
+	DEBUGFS_DEL(keylen);
+	DEBUGFS_DEL(force_sw_encrypt);
+	DEBUGFS_DEL(keyidx);
+	DEBUGFS_DEL(hw_key_idx);
+	DEBUGFS_DEL(tx_rx_count);
+	DEBUGFS_DEL(algorithm);
+	DEBUGFS_DEL(tx_spec);
+	DEBUGFS_DEL(rx_spec);
+	DEBUGFS_DEL(replays);
+	DEBUGFS_DEL(key);
+
+	debugfs_remove(key->debugfs.stalink);
+	key->debugfs.stalink = NULL;
+	debugfs_remove(key->debugfs.dir);
+	key->debugfs.dir = NULL;
+}
+void ieee80211_debugfs_key_add_default(struct ieee80211_sub_if_data *sdata)
+{
+	char buf[50];
+
+	if (!sdata->debugfsdir)
+		return;
+
+	sprintf(buf, "../keys/%d", sdata->default_key->keyidx);
+	sdata->debugfs.default_key =
+		debugfs_create_symlink("default_key", sdata->debugfsdir, buf);
+}
+void ieee80211_debugfs_key_remove_default(struct ieee80211_sub_if_data *sdata)
+{
+	if (!sdata)
+		return;
+
+	debugfs_remove(sdata->debugfs.default_key);
+	sdata->debugfs.default_key = NULL;
+}
+void ieee80211_debugfs_key_sta_link(struct ieee80211_key *key,
+				    struct sta_info *sta)
+{
+	char buf[50];
+
+	if (!key->debugfs.dir)
+		return;
+
+	sprintf(buf, "../sta/" MAC_FMT, MAC_ARG(sta->addr));
+	key->debugfs.stalink =
+		debugfs_create_symlink("station", key->debugfs.dir, buf);
+}
+
+void ieee80211_debugfs_key_sta_del(struct ieee80211_key *key,
+				   struct sta_info *sta)
+{
+	debugfs_remove(key->debugfs.stalink);
+	key->debugfs.stalink = NULL;
+}
diff --git a/net/mac80211/debugfs_key.h b/net/mac80211/debugfs_key.h
new file mode 100644
index 0000000..aecfce3
--- /dev/null
+++ b/net/mac80211/debugfs_key.h
@@ -0,0 +1,34 @@
+#ifndef __MAC80211_DEBUGFS_KEY_H
+#define __MAC80211_DEBUGFS_KEY_H
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+void ieee80211_debugfs_key_add(struct ieee80211_local *local,
+			       struct ieee80211_key *key);
+void ieee80211_debugfs_key_remove(struct ieee80211_key *key);
+void ieee80211_debugfs_key_add_default(struct ieee80211_sub_if_data *sdata);
+void ieee80211_debugfs_key_remove_default(struct ieee80211_sub_if_data *sdata);
+void ieee80211_debugfs_key_sta_link(struct ieee80211_key *key,
+				    struct sta_info *sta);
+void ieee80211_debugfs_key_sta_del(struct ieee80211_key *key,
+				   struct sta_info *sta);
+#else
+static inline void ieee80211_debugfs_key_add(struct ieee80211_local *local,
+					     struct ieee80211_key *key)
+{}
+static inline void ieee80211_debugfs_key_remove(struct ieee80211_key *key)
+{}
+static inline void ieee80211_debugfs_key_add_default(
+	struct ieee80211_sub_if_data *sdata)
+{}
+static inline void ieee80211_debugfs_key_remove_default(
+	struct ieee80211_sub_if_data *sdata)
+{}
+static inline void ieee80211_debugfs_key_sta_link(
+	struct ieee80211_key *key, struct sta_info *sta)
+{}
+static inline void ieee80211_debugfs_key_sta_del(struct ieee80211_key *key,
+						 struct sta_info *sta)
+{}
+#endif
+
+#endif /* __MAC80211_DEBUGFS_KEY_H */
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
new file mode 100644
index 0000000..9e39646
--- /dev/null
+++ b/net/mac80211/debugfs_netdev.c
@@ -0,0 +1,440 @@
+/*
+ * Copyright (c) 2006	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
+ * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/kernel.h>
+#include <linux/device.h>
+#include <linux/if.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/notifier.h>
+#include <net/mac80211.h>
+#include <net/cfg80211.h>
+#include "ieee80211_i.h"
+#include "ieee80211_rate.h"
+#include "debugfs.h"
+#include "debugfs_netdev.h"
+
+static ssize_t ieee80211_if_read(
+	struct ieee80211_sub_if_data *sdata,
+	char __user *userbuf,
+	size_t count, loff_t *ppos,
+	ssize_t (*format)(const struct ieee80211_sub_if_data *, char *, int))
+{
+	char buf[70];
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
+	if (sdata->dev->reg_state == NETREG_REGISTERED) {
+		ret = (*format)(sdata, buf, sizeof(buf));
+		ret = simple_read_from_buffer(userbuf, count, ppos, buf, ret);
+	}
+	read_unlock(&dev_base_lock);
+	return ret;
+}
+
+#define IEEE80211_IF_FMT(name, field, format_string)			\
+static ssize_t ieee80211_if_fmt_##name(					\
+	const struct ieee80211_sub_if_data *sdata, char *buf,		\
+	int buflen)							\
+{									\
+	return scnprintf(buf, buflen, format_string, sdata->field);	\
+}
+#define IEEE80211_IF_FMT_DEC(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%d\n")
+#define IEEE80211_IF_FMT_HEX(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%#x\n")
+#define IEEE80211_IF_FMT_SIZE(name, field)				\
+		IEEE80211_IF_FMT(name, field, "%zd\n")
+
+#define IEEE80211_IF_FMT_ATOMIC(name, field)				\
+static ssize_t ieee80211_if_fmt_##name(					\
+	const struct ieee80211_sub_if_data *sdata,			\
+	char *buf, int buflen)						\
+{									\
+	return scnprintf(buf, buflen, "%d\n", atomic_read(&sdata->field));\
+}
+
+#define IEEE80211_IF_FMT_MAC(name, field)				\
+static ssize_t ieee80211_if_fmt_##name(					\
+	const struct ieee80211_sub_if_data *sdata, char *buf,		\
+	int buflen)							\
+{									\
+	return scnprintf(buf, buflen, MAC_FMT "\n", MAC_ARG(sdata->field));\
+}
+
+#define __IEEE80211_IF_FILE(name)					\
+static ssize_t ieee80211_if_read_##name(struct file *file,		\
+					char __user *userbuf,		\
+					size_t count, loff_t *ppos)	\
+{									\
+	return ieee80211_if_read(file->private_data,			\
+				 userbuf, count, ppos,			\
+				 ieee80211_if_fmt_##name);		\
+}									\
+static const struct file_operations name##_ops = {			\
+	.read = ieee80211_if_read_##name,				\
+	.open = mac80211_open_file_generic,				\
+}
+
+#define IEEE80211_IF_FILE(name, field, format)				\
+		IEEE80211_IF_FMT_##format(name, field)			\
+		__IEEE80211_IF_FILE(name)
+
+/* common attributes */
+IEEE80211_IF_FILE(channel_use, channel_use, DEC);
+IEEE80211_IF_FILE(drop_unencrypted, drop_unencrypted, DEC);
+IEEE80211_IF_FILE(eapol, eapol, DEC);
+IEEE80211_IF_FILE(ieee8021_x, ieee802_1x, DEC);
+
+/* STA/IBSS attributes */
+IEEE80211_IF_FILE(state, u.sta.state, DEC);
+IEEE80211_IF_FILE(bssid, u.sta.bssid, MAC);
+IEEE80211_IF_FILE(prev_bssid, u.sta.prev_bssid, MAC);
+IEEE80211_IF_FILE(ssid_len, u.sta.ssid_len, SIZE);
+IEEE80211_IF_FILE(aid, u.sta.aid, DEC);
+IEEE80211_IF_FILE(ap_capab, u.sta.ap_capab, HEX);
+IEEE80211_IF_FILE(capab, u.sta.capab, HEX);
+IEEE80211_IF_FILE(extra_ie_len, u.sta.extra_ie_len, SIZE);
+IEEE80211_IF_FILE(auth_tries, u.sta.auth_tries, DEC);
+IEEE80211_IF_FILE(assoc_tries, u.sta.assoc_tries, DEC);
+IEEE80211_IF_FILE(auth_algs, u.sta.auth_algs, HEX);
+IEEE80211_IF_FILE(auth_alg, u.sta.auth_alg, DEC);
+IEEE80211_IF_FILE(auth_transaction, u.sta.auth_transaction, DEC);
+
+static ssize_t ieee80211_if_fmt_flags(
+	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
+{
+	return scnprintf(buf, buflen, "%s%s%s%s%s%s%s\n",
+			 sdata->u.sta.ssid_set ? "SSID\n" : "",
+			 sdata->u.sta.bssid_set ? "BSSID\n" : "",
+			 sdata->u.sta.prev_bssid_set ? "prev BSSID\n" : "",
+			 sdata->u.sta.authenticated ? "AUTH\n" : "",
+			 sdata->u.sta.associated ? "ASSOC\n" : "",
+			 sdata->u.sta.probereq_poll ? "PROBEREQ POLL\n" : "",
+			 sdata->u.sta.use_protection ? "CTS prot\n" : "");
+}
+__IEEE80211_IF_FILE(flags);
+
+/* AP attributes */
+IEEE80211_IF_FILE(num_sta_ps, u.ap.num_sta_ps, ATOMIC);
+IEEE80211_IF_FILE(dtim_period, u.ap.dtim_period, DEC);
+IEEE80211_IF_FILE(dtim_count, u.ap.dtim_count, DEC);
+IEEE80211_IF_FILE(num_beacons, u.ap.num_beacons, DEC);
+IEEE80211_IF_FILE(force_unicast_rateidx, u.ap.force_unicast_rateidx, DEC);
+IEEE80211_IF_FILE(max_ratectrl_rateidx, u.ap.max_ratectrl_rateidx, DEC);
+
+static ssize_t ieee80211_if_fmt_num_buffered_multicast(
+	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
+{
+	return scnprintf(buf, buflen, "%u\n",
+			 skb_queue_len(&sdata->u.ap.ps_bc_buf));
+}
+__IEEE80211_IF_FILE(num_buffered_multicast);
+
+static ssize_t ieee80211_if_fmt_beacon_head_len(
+	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
+{
+	if (sdata->u.ap.beacon_head)
+		return scnprintf(buf, buflen, "%d\n",
+				 sdata->u.ap.beacon_head_len);
+	return scnprintf(buf, buflen, "\n");
+}
+__IEEE80211_IF_FILE(beacon_head_len);
+
+static ssize_t ieee80211_if_fmt_beacon_tail_len(
+	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
+{
+	if (sdata->u.ap.beacon_tail)
+		return scnprintf(buf, buflen, "%d\n",
+				 sdata->u.ap.beacon_tail_len);
+	return scnprintf(buf, buflen, "\n");
+}
+__IEEE80211_IF_FILE(beacon_tail_len);
+
+/* WDS attributes */
+IEEE80211_IF_FILE(peer, u.wds.remote_addr, MAC);
+
+/* VLAN attributes */
+IEEE80211_IF_FILE(vlan_id, u.vlan.id, DEC);
+
+/* MONITOR attributes */
+static ssize_t ieee80211_if_fmt_mode(
+	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
+{
+	struct ieee80211_local *local = sdata->local;
+
+	return scnprintf(buf, buflen, "%s\n",
+			 ((local->hw.flags & IEEE80211_HW_MONITOR_DURING_OPER) ||
+			  local->open_count == local->monitors) ?
+			 "hard" : "soft");
+}
+__IEEE80211_IF_FILE(mode);
+
+
+#define DEBUGFS_ADD(name, type)\
+	sdata->debugfs.type.name = debugfs_create_file(#name, 0444,\
+		sdata->debugfsdir, sdata, &name##_ops);
+
+static void add_sta_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_ADD(channel_use, sta);
+	DEBUGFS_ADD(drop_unencrypted, sta);
+	DEBUGFS_ADD(eapol, sta);
+	DEBUGFS_ADD(ieee8021_x, sta);
+	DEBUGFS_ADD(state, sta);
+	DEBUGFS_ADD(bssid, sta);
+	DEBUGFS_ADD(prev_bssid, sta);
+	DEBUGFS_ADD(ssid_len, sta);
+	DEBUGFS_ADD(aid, sta);
+	DEBUGFS_ADD(ap_capab, sta);
+	DEBUGFS_ADD(capab, sta);
+	DEBUGFS_ADD(extra_ie_len, sta);
+	DEBUGFS_ADD(auth_tries, sta);
+	DEBUGFS_ADD(assoc_tries, sta);
+	DEBUGFS_ADD(auth_algs, sta);
+	DEBUGFS_ADD(auth_alg, sta);
+	DEBUGFS_ADD(auth_transaction, sta);
+	DEBUGFS_ADD(flags, sta);
+}
+
+static void add_ap_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_ADD(channel_use, ap);
+	DEBUGFS_ADD(drop_unencrypted, ap);
+	DEBUGFS_ADD(eapol, ap);
+	DEBUGFS_ADD(ieee8021_x, ap);
+	DEBUGFS_ADD(num_sta_ps, ap);
+	DEBUGFS_ADD(dtim_period, ap);
+	DEBUGFS_ADD(dtim_count, ap);
+	DEBUGFS_ADD(num_beacons, ap);
+	DEBUGFS_ADD(force_unicast_rateidx, ap);
+	DEBUGFS_ADD(max_ratectrl_rateidx, ap);
+	DEBUGFS_ADD(num_buffered_multicast, ap);
+	DEBUGFS_ADD(beacon_head_len, ap);
+	DEBUGFS_ADD(beacon_tail_len, ap);
+}
+
+static void add_wds_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_ADD(channel_use, wds);
+	DEBUGFS_ADD(drop_unencrypted, wds);
+	DEBUGFS_ADD(eapol, wds);
+	DEBUGFS_ADD(ieee8021_x, wds);
+	DEBUGFS_ADD(peer, wds);
+}
+
+static void add_vlan_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_ADD(channel_use, vlan);
+	DEBUGFS_ADD(drop_unencrypted, vlan);
+	DEBUGFS_ADD(eapol, vlan);
+	DEBUGFS_ADD(ieee8021_x, vlan);
+	DEBUGFS_ADD(vlan_id, vlan);
+}
+
+static void add_monitor_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_ADD(mode, monitor);
+}
+
+static void add_files(struct ieee80211_sub_if_data *sdata)
+{
+	if (!sdata->debugfsdir)
+		return;
+
+	switch (sdata->type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		add_sta_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		add_ap_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_WDS:
+		add_wds_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		add_monitor_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_VLAN:
+		add_vlan_files(sdata);
+		break;
+	default:
+		break;
+	}
+}
+
+#define DEBUGFS_DEL(name, type)\
+	debugfs_remove(sdata->debugfs.type.name);\
+	sdata->debugfs.type.name = NULL;
+
+static void del_sta_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_DEL(channel_use, sta);
+	DEBUGFS_DEL(drop_unencrypted, sta);
+	DEBUGFS_DEL(eapol, sta);
+	DEBUGFS_DEL(ieee8021_x, sta);
+	DEBUGFS_DEL(state, sta);
+	DEBUGFS_DEL(bssid, sta);
+	DEBUGFS_DEL(prev_bssid, sta);
+	DEBUGFS_DEL(ssid_len, sta);
+	DEBUGFS_DEL(aid, sta);
+	DEBUGFS_DEL(ap_capab, sta);
+	DEBUGFS_DEL(capab, sta);
+	DEBUGFS_DEL(extra_ie_len, sta);
+	DEBUGFS_DEL(auth_tries, sta);
+	DEBUGFS_DEL(assoc_tries, sta);
+	DEBUGFS_DEL(auth_algs, sta);
+	DEBUGFS_DEL(auth_alg, sta);
+	DEBUGFS_DEL(auth_transaction, sta);
+	DEBUGFS_DEL(flags, sta);
+}
+
+static void del_ap_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_DEL(channel_use, ap);
+	DEBUGFS_DEL(drop_unencrypted, ap);
+	DEBUGFS_DEL(eapol, ap);
+	DEBUGFS_DEL(ieee8021_x, ap);
+	DEBUGFS_DEL(num_sta_ps, ap);
+	DEBUGFS_DEL(dtim_period, ap);
+	DEBUGFS_DEL(dtim_count, ap);
+	DEBUGFS_DEL(num_beacons, ap);
+	DEBUGFS_DEL(force_unicast_rateidx, ap);
+	DEBUGFS_DEL(max_ratectrl_rateidx, ap);
+	DEBUGFS_DEL(num_buffered_multicast, ap);
+	DEBUGFS_DEL(beacon_head_len, ap);
+	DEBUGFS_DEL(beacon_tail_len, ap);
+}
+
+static void del_wds_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_DEL(channel_use, wds);
+	DEBUGFS_DEL(drop_unencrypted, wds);
+	DEBUGFS_DEL(eapol, wds);
+	DEBUGFS_DEL(ieee8021_x, wds);
+	DEBUGFS_DEL(peer, wds);
+}
+
+static void del_vlan_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_DEL(channel_use, vlan);
+	DEBUGFS_DEL(drop_unencrypted, vlan);
+	DEBUGFS_DEL(eapol, vlan);
+	DEBUGFS_DEL(ieee8021_x, vlan);
+	DEBUGFS_DEL(vlan_id, vlan);
+}
+
+static void del_monitor_files(struct ieee80211_sub_if_data *sdata)
+{
+	DEBUGFS_DEL(mode, monitor);
+}
+
+static void del_files(struct ieee80211_sub_if_data *sdata, int type)
+{
+	if (!sdata->debugfsdir)
+		return;
+
+	switch (type) {
+	case IEEE80211_IF_TYPE_STA:
+	case IEEE80211_IF_TYPE_IBSS:
+		del_sta_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_AP:
+		del_ap_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_WDS:
+		del_wds_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_MNTR:
+		del_monitor_files(sdata);
+		break;
+	case IEEE80211_IF_TYPE_VLAN:
+		del_vlan_files(sdata);
+		break;
+	default:
+		break;
+	}
+}
+
+static int notif_registered;
+
+void ieee80211_debugfs_add_netdev(struct ieee80211_sub_if_data *sdata)
+{
+	char buf[10+IFNAMSIZ];
+
+	if (!notif_registered)
+		return;
+
+	sprintf(buf, "netdev:%s", sdata->dev->name);
+	sdata->debugfsdir = debugfs_create_dir(buf,
+		sdata->local->hw.wiphy->debugfsdir);
+}
+
+void ieee80211_debugfs_remove_netdev(struct ieee80211_sub_if_data *sdata)
+{
+	del_files(sdata, sdata->type);
+	debugfs_remove(sdata->debugfsdir);
+	sdata->debugfsdir = NULL;
+}
+
+void ieee80211_debugfs_change_if_type(struct ieee80211_sub_if_data *sdata,
+				      int oldtype)
+{
+	del_files(sdata, oldtype);
+	add_files(sdata);
+}
+
+static int netdev_notify(struct notifier_block * nb,
+			 unsigned long state,
+			 void *ndev)
+{
+	struct net_device *dev = ndev;
+	char buf[10+IFNAMSIZ];
+
+	if (state != NETDEV_CHANGENAME)
+		return 0;
+
+	if (!dev->ieee80211_ptr || !dev->ieee80211_ptr->wiphy)
+		return 0;
+
+	if (dev->ieee80211_ptr->wiphy->privid != mac80211_wiphy_privid)
+		return 0;
+
+	/* TODO
+	sprintf(buf, "netdev:%s", dev->name);
+	debugfs_rename(IEEE80211_DEV_TO_SUB_IF(dev)->debugfsdir, buf);
+	*/
+
+	return 0;
+}
+
+static struct notifier_block mac80211_debugfs_netdev_notifier = {
+	.notifier_call = netdev_notify,
+};
+
+void ieee80211_debugfs_netdev_init(void)
+{
+	int err;
+
+	err = register_netdevice_notifier(&mac80211_debugfs_netdev_notifier);
+	if (err) {
+		printk(KERN_ERR
+		       "mac80211: failed to install netdev notifier,"
+		       " disabling per-netdev debugfs!\n");
+	} else
+		notif_registered = 1;
+}
+
+void ieee80211_debugfs_netdev_exit(void)
+{
+	unregister_netdevice_notifier(&mac80211_debugfs_netdev_notifier);
+	notif_registered = 0;
+}
diff --git a/net/mac80211/debugfs_netdev.h b/net/mac80211/debugfs_netdev.h
new file mode 100644
index 0000000..a690071
--- /dev/null
+++ b/net/mac80211/debugfs_netdev.h
@@ -0,0 +1,30 @@
+/* routines exported for debugfs handling */
+
+#ifndef __IEEE80211_DEBUGFS_NETDEV_H
+#define __IEEE80211_DEBUGFS_NETDEV_H
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+void ieee80211_debugfs_add_netdev(struct ieee80211_sub_if_data *sdata);
+void ieee80211_debugfs_remove_netdev(struct ieee80211_sub_if_data *sdata);
+void ieee80211_debugfs_change_if_type(struct ieee80211_sub_if_data *sdata,
+				     int oldtype);
+void ieee80211_debugfs_netdev_init(void);
+void ieee80211_debugfs_netdev_exit(void);
+#else
+static inline void ieee80211_debugfs_add_netdev(
+	struct ieee80211_sub_if_data *sdata)
+{}
+static inline void ieee80211_debugfs_remove_netdev(
+	struct ieee80211_sub_if_data *sdata)
+{}
+static inline void ieee80211_debugfs_change_if_type(
+	struct ieee80211_sub_if_data *sdata, int oldtype)
+{}
+static inline void ieee80211_debugfs_netdev_init(void)
+{}
+
+static inline void ieee80211_debugfs_netdev_exit(void)
+{}
+#endif
+
+#endif /* __IEEE80211_DEBUGFS_NETDEV_H */
diff --git a/net/mac80211/debugfs_sta.c b/net/mac80211/debugfs_sta.c
new file mode 100644
index 0000000..d41e696
--- /dev/null
+++ b/net/mac80211/debugfs_sta.c
@@ -0,0 +1,246 @@
+/*
+ * Copyright 2003-2005	Devicescape Software, Inc.
+ * Copyright (c) 2006	Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
+ * Copyright 2007	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/debugfs.h>
+#include <linux/ieee80211.h>
+#include "ieee80211_i.h"
+#include "debugfs.h"
+#include "debugfs_sta.h"
+#include "sta_info.h"
+
+/* sta attributtes */
+
+#define STA_READ(name, buflen, field, format_string)			\
+static ssize_t sta_ ##name## _read(struct file *file,			\
+				   char __user *userbuf,		\
+				   size_t count, loff_t *ppos)		\
+{									\
+	int res;							\
+	struct sta_info *sta = file->private_data;			\
+	char buf[buflen];						\
+	res = scnprintf(buf, buflen, format_string, sta->field);	\
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);	\
+}
+#define STA_READ_D(name, field) STA_READ(name, 20, field, "%d\n")
+#define STA_READ_U(name, field) STA_READ(name, 20, field, "%u\n")
+#define STA_READ_LU(name, field) STA_READ(name, 20, field, "%lu\n")
+#define STA_READ_S(name, field) STA_READ(name, 20, field, "%s\n")
+
+#define STA_READ_RATE(name, field)					\
+static ssize_t sta_##name##_read(struct file *file,			\
+				 char __user *userbuf,			\
+				 size_t count, loff_t *ppos)		\
+{									\
+	struct sta_info *sta = file->private_data;			\
+	struct ieee80211_local *local = wdev_priv(sta->dev->ieee80211_ptr);\
+	struct ieee80211_hw_mode *mode = local->oper_hw_mode;		\
+	char buf[20];							\
+	int res = scnprintf(buf, sizeof(buf), "%d\n",			\
+			    (sta->field >= 0 &&				\
+			    sta->field < mode->num_rates) ?		\
+			    mode->rates[sta->field].rate : -1);		\
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);	\
+}
+
+#define STA_OPS(name)							\
+static const struct file_operations sta_ ##name## _ops = {		\
+	.read = sta_##name##_read,					\
+	.open = mac80211_open_file_generic,				\
+}
+
+#define STA_FILE(name, field, format)					\
+		STA_READ_##format(name, field)				\
+		STA_OPS(name)
+
+STA_FILE(aid, aid, D);
+STA_FILE(key_idx_compression, key_idx_compression, D);
+STA_FILE(dev, dev->name, S);
+STA_FILE(vlan_id, vlan_id, D);
+STA_FILE(rx_packets, rx_packets, LU);
+STA_FILE(tx_packets, tx_packets, LU);
+STA_FILE(rx_bytes, rx_bytes, LU);
+STA_FILE(tx_bytes, tx_bytes, LU);
+STA_FILE(rx_duplicates, num_duplicates, LU);
+STA_FILE(rx_fragments, rx_fragments, LU);
+STA_FILE(rx_dropped, rx_dropped, LU);
+STA_FILE(tx_fragments, tx_fragments, LU);
+STA_FILE(tx_filtered, tx_filtered_count, LU);
+STA_FILE(txrate, txrate, RATE);
+STA_FILE(last_txrate, last_txrate, RATE);
+STA_FILE(tx_retry_failed, tx_retry_failed, LU);
+STA_FILE(tx_retry_count, tx_retry_count, LU);
+STA_FILE(last_rssi, last_rssi, D);
+STA_FILE(last_signal, last_signal, D);
+STA_FILE(last_noise, last_noise, D);
+STA_FILE(channel_use, channel_use, D);
+STA_FILE(wep_weak_iv_count, wep_weak_iv_count, D);
+
+static ssize_t sta_flags_read(struct file *file, char __user *userbuf,
+			      size_t count, loff_t *ppos)
+{
+	char buf[100];
+	struct sta_info *sta = file->private_data;
+	int res = scnprintf(buf, sizeof(buf), "%s%s%s%s%s%s%s%s%s",
+		sta->flags & WLAN_STA_AUTH ? "AUTH\n" : "",
+		sta->flags & WLAN_STA_ASSOC ? "ASSOC\n" : "",
+		sta->flags & WLAN_STA_PS ? "PS\n" : "",
+		sta->flags & WLAN_STA_TIM ? "TIM\n" : "",
+		sta->flags & WLAN_STA_PERM ? "PERM\n" : "",
+		sta->flags & WLAN_STA_AUTHORIZED ? "AUTHORIZED\n" : "",
+		sta->flags & WLAN_STA_SHORT_PREAMBLE ? "SHORT PREAMBLE\n" : "",
+		sta->flags & WLAN_STA_WME ? "WME\n" : "",
+		sta->flags & WLAN_STA_WDS ? "WDS\n" : "");
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+STA_OPS(flags);
+
+static ssize_t sta_num_ps_buf_frames_read(struct file *file,
+					  char __user *userbuf,
+					  size_t count, loff_t *ppos)
+{
+	char buf[20];
+	struct sta_info *sta = file->private_data;
+	int res = scnprintf(buf, sizeof(buf), "%u\n",
+			    skb_queue_len(&sta->ps_tx_buf));
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+STA_OPS(num_ps_buf_frames);
+
+static ssize_t sta_last_ack_rssi_read(struct file *file, char __user *userbuf,
+				      size_t count, loff_t *ppos)
+{
+	char buf[100];
+	struct sta_info *sta = file->private_data;
+	int res = scnprintf(buf, sizeof(buf), "%d %d %d\n",
+			    sta->last_ack_rssi[0],
+			    sta->last_ack_rssi[1],
+			    sta->last_ack_rssi[2]);
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+STA_OPS(last_ack_rssi);
+
+static ssize_t sta_last_ack_ms_read(struct file *file, char __user *userbuf,
+				    size_t count, loff_t *ppos)
+{
+	char buf[20];
+	struct sta_info *sta = file->private_data;
+	int res = scnprintf(buf, sizeof(buf), "%d\n",
+			    sta->last_ack ?
+			    jiffies_to_msecs(jiffies - sta->last_ack) : -1);
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+STA_OPS(last_ack_ms);
+
+static ssize_t sta_inactive_ms_read(struct file *file, char __user *userbuf,
+				    size_t count, loff_t *ppos)
+{
+	char buf[20];
+	struct sta_info *sta = file->private_data;
+	int res = scnprintf(buf, sizeof(buf), "%d\n",
+			    jiffies_to_msecs(jiffies - sta->last_rx));
+	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
+}
+STA_OPS(inactive_ms);
+
+static ssize_t sta_last_seq_ctrl_read(struct file *file, char __user *userbuf,
+				      size_t count, loff_t *ppos)
+{
+	char buf[15*NUM_RX_DATA_QUEUES], *p = buf;
+	int i;
+	struct sta_info *sta = file->private_data;
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += scnprintf(p, sizeof(buf)+buf-p, "%x ",
+			       sta->last_seq_ctrl[i]);
+	p += scnprintf(p, sizeof(buf)+buf-p, "\n");
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p - buf);
+}
+STA_OPS(last_seq_ctrl);
+
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+static ssize_t sta_wme_rx_queue_read(struct file *file, char __user *userbuf,
+				     size_t count, loff_t *ppos)
+{
+	char buf[15*NUM_RX_DATA_QUEUES], *p = buf;
+	int i;
+	struct sta_info *sta = file->private_data;
+	for (i = 0; i < NUM_RX_DATA_QUEUES; i++)
+		p += scnprintf(p, sizeof(buf)+buf-p, "%u ",
+			       sta->wme_rx_queue[i]);
+	p += scnprintf(p, sizeof(buf)+buf-p, "\n");
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p - buf);
+}
+STA_OPS(wme_rx_queue);
+
+static ssize_t sta_wme_tx_queue_read(struct file *file, char __user *userbuf,
+				     size_t count, loff_t *ppos)
+{
+	char buf[15*NUM_TX_DATA_QUEUES], *p = buf;
+	int i;
+	struct sta_info *sta = file->private_data;
+	for (i = 0; i < NUM_TX_DATA_QUEUES; i++)
+		p += scnprintf(p, sizeof(buf)+buf-p, "%u ",
+			       sta->wme_tx_queue[i]);
+	p += scnprintf(p, sizeof(buf)+buf-p, "\n");
+	return simple_read_from_buffer(userbuf, count, ppos, buf, p - buf);
+}
+STA_OPS(wme_tx_queue);
+#endif
+
+#define DEBUGFS_ADD(name) \
+	sta->debugfs.name = debugfs_create_file(#name, 0444, \
+		sta->debugfs.dir, sta, &sta_ ##name## _ops);
+
+#define DEBUGFS_DEL(name) \
+	debugfs_remove(sta->debugfs.name);\
+	sta->debugfs.name = NULL;
+
+
+void ieee80211_sta_debugfs_add(struct sta_info *sta)
+{
+	char buf[3*6];
+	struct dentry *stations_dir = sta->local->debugfs.stations;
+
+	if (!stations_dir)
+		return;
+
+	sprintf(buf, MAC_FMT, MAC_ARG(sta->addr));
+
+	sta->debugfs.dir = debugfs_create_dir(buf, stations_dir);
+	if (!sta->debugfs.dir)
+		return;
+
+	DEBUGFS_ADD(flags);
+	DEBUGFS_ADD(num_ps_buf_frames);
+	DEBUGFS_ADD(last_ack_rssi);
+	DEBUGFS_ADD(last_ack_ms);
+	DEBUGFS_ADD(inactive_ms);
+	DEBUGFS_ADD(last_seq_ctrl);
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+	DEBUGFS_ADD(wme_rx_queue);
+	DEBUGFS_ADD(wme_tx_queue);
+#endif
+}
+
+void ieee80211_sta_debugfs_remove(struct sta_info *sta)
+{
+	DEBUGFS_DEL(flags);
+	DEBUGFS_DEL(num_ps_buf_frames);
+	DEBUGFS_DEL(last_ack_rssi);
+	DEBUGFS_DEL(last_ack_ms);
+	DEBUGFS_DEL(inactive_ms);
+	DEBUGFS_DEL(last_seq_ctrl);
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+	DEBUGFS_DEL(wme_rx_queue);
+	DEBUGFS_DEL(wme_tx_queue);
+#endif
+
+	debugfs_remove(sta->debugfs.dir);
+	sta->debugfs.dir = NULL;
+}
diff --git a/net/mac80211/debugfs_sta.h b/net/mac80211/debugfs_sta.h
new file mode 100644
index 0000000..574a1cd
--- /dev/null
+++ b/net/mac80211/debugfs_sta.h
@@ -0,0 +1,12 @@
+#ifndef __MAC80211_DEBUGFS_STA_H
+#define __MAC80211_DEBUGFS_STA_H
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+void ieee80211_sta_debugfs_add(struct sta_info *sta);
+void ieee80211_sta_debugfs_remove(struct sta_info *sta);
+#else
+static inline void ieee80211_sta_debugfs_add(struct sta_info *sta) {}
+static inline void ieee80211_sta_debugfs_remove(struct sta_info *sta) {}
+#endif
+
+#endif /* __MAC80211_DEBUGFS_STA_H */
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 48a832d..6e36df6 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -35,6 +35,9 @@
 #include "aes_ccm.h"
 #include "ieee80211_led.h"
 #include "ieee80211_cfg.h"
+#include "debugfs.h"
+#include "debugfs_netdev.h"
+#include "debugfs_key.h"
 
 /* privid for wiphys to determine whether they belong to us or not */
 void *mac80211_wiphy_privid = &mac80211_wiphy_privid;
@@ -108,6 +111,7 @@ static void ieee80211_key_release(struct kref *kref)
 	key = container_of(kref, struct ieee80211_key, kref);
 	if (key->alg == ALG_CCMP)
 		ieee80211_aes_key_free(key->u.ccmp.tfm);
+	ieee80211_debugfs_key_remove(key);
 	kfree(key);
 }
 
@@ -4704,6 +4708,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		goto fail_workqueue;
 	}
 
+	debugfs_hw_add(local);
+
 	local->hw.conf.beacon_int = 1000;
 
 	local->wstats_flags |= local->hw.max_rssi ?
@@ -4731,6 +4737,8 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 	if (result < 0)
 		goto fail_dev;
 
+	ieee80211_debugfs_add_netdev(IEEE80211_DEV_TO_SUB_IF(local->mdev));
+
 	result = ieee80211_init_rate_ctrl_alg(local, NULL);
 	if (result < 0) {
 		printk(KERN_DEBUG "%s: Failed to initialize rate control "
@@ -4765,11 +4773,13 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 fail_wep:
 	rate_control_deinitialize(local);
 fail_rate:
+	ieee80211_debugfs_remove_netdev(IEEE80211_DEV_TO_SUB_IF(local->mdev));
 	unregister_netdevice(local->mdev);
 fail_dev:
 	rtnl_unlock();
 	sta_info_stop(local);
 fail_sta_info:
+	debugfs_hw_del(local);
 	destroy_workqueue(local->hw.workqueue);
 fail_workqueue:
 	wiphy_unregister(local->hw.wiphy);
@@ -4844,6 +4854,7 @@ void ieee80211_unregister_hw(struct ieee80211_hw *hw)
 	ieee80211_clear_tx_pending(local);
 	sta_info_stop(local);
 	rate_control_deinitialize(local);
+	debugfs_hw_del(local);
 
 	for (i = 0; i < NUM_IEEE80211_MODES; i++) {
 		kfree(local->supp_rates[i]);
@@ -4953,6 +4964,8 @@ static int __init ieee80211_init(void)
 		return ret;
 	}
 
+	ieee80211_debugfs_netdev_init();
+
 	return 0;
 }
 
@@ -4960,6 +4973,7 @@ static int __init ieee80211_init(void)
 static void __exit ieee80211_exit(void)
 {
 	ieee80211_wme_unregister();
+	ieee80211_debugfs_netdev_exit();
 }
 
 
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ae94d64..af4d14d 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -307,6 +307,65 @@ struct ieee80211_sub_if_data {
 	} u;
 	int channel_use;
 	int channel_use_raw;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct dentry *debugfsdir;
+	union {
+		struct {
+			struct dentry *channel_use;
+			struct dentry *drop_unencrypted;
+			struct dentry *eapol;
+			struct dentry *ieee8021_x;
+			struct dentry *state;
+			struct dentry *bssid;
+			struct dentry *prev_bssid;
+			struct dentry *ssid_len;
+			struct dentry *aid;
+			struct dentry *ap_capab;
+			struct dentry *capab;
+			struct dentry *extra_ie_len;
+			struct dentry *auth_tries;
+			struct dentry *assoc_tries;
+			struct dentry *auth_algs;
+			struct dentry *auth_alg;
+			struct dentry *auth_transaction;
+			struct dentry *flags;
+		} sta;
+		struct {
+			struct dentry *channel_use;
+			struct dentry *drop_unencrypted;
+			struct dentry *eapol;
+			struct dentry *ieee8021_x;
+			struct dentry *num_sta_ps;
+			struct dentry *dtim_period;
+			struct dentry *dtim_count;
+			struct dentry *num_beacons;
+			struct dentry *force_unicast_rateidx;
+			struct dentry *max_ratectrl_rateidx;
+			struct dentry *num_buffered_multicast;
+			struct dentry *beacon_head_len;
+			struct dentry *beacon_tail_len;
+		} ap;
+		struct {
+			struct dentry *channel_use;
+			struct dentry *drop_unencrypted;
+			struct dentry *eapol;
+			struct dentry *ieee8021_x;
+			struct dentry *peer;
+		} wds;
+		struct {
+			struct dentry *channel_use;
+			struct dentry *drop_unencrypted;
+			struct dentry *eapol;
+			struct dentry *ieee8021_x;
+			struct dentry *vlan_id;
+		} vlan;
+		struct {
+			struct dentry *mode;
+		} monitor;
+		struct dentry *default_key;
+	} debugfs;
+#endif
 };
 
 #define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev)
@@ -444,6 +503,10 @@ struct ieee80211_local {
 	u32 stat_time;
 	struct timer_list stat_timer;
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct work_struct sta_debugfs_add;
+#endif
+
 	enum {
 		STA_ANTENNA_SEL_AUTO = 0,
 		STA_ANTENNA_SEL_SW_CTRL = 1,
@@ -500,6 +563,70 @@ struct ieee80211_local {
 				* (1 << MODE_*) */
 
 	int user_space_mlme;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct local_debugfsdentries {
+		struct dentry *channel;
+		struct dentry *frequency;
+		struct dentry *radar_detect;
+		struct dentry *antenna_sel_tx;
+		struct dentry *antenna_sel_rx;
+		struct dentry *bridge_packets;
+		struct dentry *key_tx_rx_threshold;
+		struct dentry *rts_threshold;
+		struct dentry *fragmentation_threshold;
+		struct dentry *short_retry_limit;
+		struct dentry *long_retry_limit;
+		struct dentry *total_ps_buffered;
+		struct dentry *mode;
+		struct dentry *wep_iv;
+		struct dentry *tx_power_reduction;
+		struct dentry *modes;
+		struct dentry *statistics;
+		struct local_debugfsdentries_statsdentries {
+			struct dentry *transmitted_fragment_count;
+			struct dentry *multicast_transmitted_frame_count;
+			struct dentry *failed_count;
+			struct dentry *retry_count;
+			struct dentry *multiple_retry_count;
+			struct dentry *frame_duplicate_count;
+			struct dentry *received_fragment_count;
+			struct dentry *multicast_received_frame_count;
+			struct dentry *transmitted_frame_count;
+			struct dentry *wep_undecryptable_count;
+			struct dentry *num_scans;
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+			struct dentry *tx_handlers_drop;
+			struct dentry *tx_handlers_queued;
+			struct dentry *tx_handlers_drop_unencrypted;
+			struct dentry *tx_handlers_drop_fragment;
+			struct dentry *tx_handlers_drop_wep;
+			struct dentry *tx_handlers_drop_not_assoc;
+			struct dentry *tx_handlers_drop_unauth_port;
+			struct dentry *rx_handlers_drop;
+			struct dentry *rx_handlers_queued;
+			struct dentry *rx_handlers_drop_nullfunc;
+			struct dentry *rx_handlers_drop_defrag;
+			struct dentry *rx_handlers_drop_short;
+			struct dentry *rx_handlers_drop_passive_scan;
+			struct dentry *tx_expand_skb_head;
+			struct dentry *tx_expand_skb_head_cloned;
+			struct dentry *rx_expand_skb_head;
+			struct dentry *rx_expand_skb_head2;
+			struct dentry *rx_handlers_fragments;
+			struct dentry *tx_status_drop;
+			struct dentry *wme_tx_queue;
+			struct dentry *wme_rx_queue;
+#endif
+			struct dentry *dot11ACKFailureCount;
+			struct dentry *dot11RTSFailureCount;
+			struct dentry *dot11FCSErrorCount;
+			struct dentry *dot11RTSSuccessCount;
+		} stats;
+		struct dentry *stations;
+		struct dentry *keys;
+	} debugfs;
+#endif
 };
 
 static inline struct ieee80211_local *hw_to_local(
diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index 64267d4..cf0f32e 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -14,6 +14,7 @@
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
 #include "sta_info.h"
+#include "debugfs_netdev.h"
 
 void ieee80211_if_sdata_init(struct ieee80211_sub_if_data *sdata)
 {
@@ -73,6 +74,7 @@ int ieee80211_if_add(struct net_device *dev, const char *name,
 	if (ret)
 		goto fail;
 
+	ieee80211_debugfs_add_netdev(sdata);
 	ieee80211_if_set_type(ndev, type);
 
 	write_lock_bh(&local->sub_if_lock);
@@ -126,6 +128,8 @@ int ieee80211_if_add_mgmt(struct ieee80211_local *local)
 	if (ret)
 		goto fail;
 
+	ieee80211_debugfs_add_netdev(nsdata);
+
 	if (local->open_count > 0)
 		dev_open(ndev);
 	local->apdev = ndev;
@@ -142,6 +146,7 @@ void ieee80211_if_del_mgmt(struct ieee80211_local *local)
 
 	ASSERT_RTNL();
 	apdev = local->apdev;
+	ieee80211_debugfs_remove_netdev(IEEE80211_DEV_TO_SUB_IF(apdev));
 	local->apdev = NULL;
 	unregister_netdevice(apdev);
 }
@@ -150,6 +155,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 {
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	int oldtype = sdata->type;
 
 	sdata->type = type;
 	switch (type) {
@@ -195,6 +201,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 		printk(KERN_WARNING "%s: %s: Unknown interface type 0x%x",
 		       dev->name, __FUNCTION__, type);
 	}
+	ieee80211_debugfs_change_if_type(sdata, oldtype);
 	ieee80211_update_default_wep_only(local);
 }
 
@@ -303,6 +310,7 @@ void __ieee80211_if_del(struct ieee80211_local *local,
 {
 	struct net_device *dev = sdata->dev;
 
+	ieee80211_debugfs_remove_netdev(sdata);
 	unregister_netdevice(dev);
 	/* Except master interface, the net_device will be freed by
 	 * net_device->destructor (i. e. ieee80211_if_free). */
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 73909ec..352f03b 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -25,6 +25,7 @@
 #include "ieee80211_rate.h"
 #include "wpa.h"
 #include "aes_ccm.h"
+#include "debugfs_key.h"
 
 static int ieee80211_regdom = 0x10; /* FCC */
 module_param(ieee80211_regdom, int, 0444);
@@ -180,8 +181,11 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 		}
 		kfree(keyconf);
 
-		if (set_tx_key || sdata->default_key == key)
+		if (set_tx_key || sdata->default_key == key) {
+			ieee80211_debugfs_key_remove_default(sdata);
 			sdata->default_key = NULL;
+		}
+		ieee80211_debugfs_key_remove(key);
 		if (sta)
 			sta->key = NULL;
 		else
@@ -221,13 +225,19 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 			}
 		}
 
-		if (set_tx_key || sdata->default_key == old_key)
+		if (set_tx_key || sdata->default_key == old_key) {
+			ieee80211_debugfs_key_remove_default(sdata);
 			sdata->default_key = NULL;
+		}
+		ieee80211_debugfs_key_remove(old_key);
 		if (sta)
 			sta->key = key;
 		else
 			sdata->keys[idx] = key;
 		ieee80211_key_free(old_key);
+		ieee80211_debugfs_key_add(local, key);
+		if (sta)
+			ieee80211_debugfs_key_sta_link(key, sta);
 
 		if (try_hwaccel &&
 		    (alg == ALG_WEP || alg == ALG_TKIP || alg == ALG_CCMP))
@@ -236,6 +246,8 @@ static int ieee80211_set_encryption(struct net_device *dev, u8 *sta_addr,
 
 	if (set_tx_key || (!sta && !sdata->default_key && key)) {
 		sdata->default_key = key;
+		if (key)
+			ieee80211_debugfs_key_add_default(sdata);
 
 		if (local->ops->set_key_idx &&
 		    local->ops->set_key_idx(local_to_hw(local), idx))
@@ -1505,8 +1517,12 @@ static int ieee80211_ioctl_siwencode(struct net_device *dev,
 		alg = ALG_NONE;
 	else if (erq->length == 0) {
 		/* No key data - just set the default TX key index */
-		if (sdata->default_key != sdata->keys[idx])
+		if (sdata->default_key != sdata->keys[idx]) {
+			ieee80211_debugfs_key_remove_default(sdata);
 			sdata->default_key = sdata->keys[idx];
+			if (sdata->default_key)
+				ieee80211_debugfs_key_add_default(sdata);
+		}
 		return 0;
 	}
 
diff --git a/net/mac80211/ieee80211_key.h b/net/mac80211/ieee80211_key.h
index da67d87..c333849 100644
--- a/net/mac80211/ieee80211_key.h
+++ b/net/mac80211/ieee80211_key.h
@@ -83,6 +83,23 @@ struct ieee80211_key {
 					* (used only for broadcast keys). */
 	s8 keyidx; /* WEP key index */
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct {
+		struct dentry *stalink;
+		struct dentry *dir;
+		struct dentry *keylen;
+		struct dentry *force_sw_encrypt;
+		struct dentry *keyidx;
+		struct dentry *hw_key_idx;
+		struct dentry *tx_rx_count;
+		struct dentry *algorithm;
+		struct dentry *tx_spec;
+		struct dentry *rx_spec;
+		struct dentry *replays;
+		struct dentry *key;
+	} debugfs;
+#endif
+
 	u8 key[0];
 };
 
diff --git a/net/mac80211/ieee80211_rate.h b/net/mac80211/ieee80211_rate.h
index 710f568..f021a02 100644
--- a/net/mac80211/ieee80211_rate.h
+++ b/net/mac80211/ieee80211_rate.h
@@ -56,6 +56,9 @@ struct rate_control_ops {
 
 	int (*add_attrs)(void *priv, struct kobject *kobj);
 	void (*remove_attrs)(void *priv, struct kobject *kobj);
+	void (*add_sta_debugfs)(void *priv, void *priv_sta,
+				struct dentry *dir);
+	void (*remove_sta_debugfs)(void *priv, void *priv_sta);
 };
 
 struct rate_control_ref {
@@ -119,4 +122,23 @@ static inline void rate_control_free_sta(struct rate_control_ref *ref,
 	ref->ops->free_sta(ref->priv, priv);
 }
 
+static inline void rate_control_add_sta_debugfs(struct sta_info *sta)
+{
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	if (sta->debugfs.dir && ref->ops->add_sta_debugfs)
+		ref->ops->add_sta_debugfs(ref->priv, sta->rate_ctrl_priv,
+					  sta->debugfs.dir);
+#endif
+}
+
+static inline void rate_control_remove_sta_debugfs(struct sta_info *sta)
+{
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct rate_control_ref *ref = sta->rate_ctrl;
+	if (ref->ops->remove_sta_debugfs)
+		ref->ops->remove_sta_debugfs(ref->priv, sta->rate_ctrl_priv);
+#endif
+}
+
 #endif /* IEEE80211_RATE_H */
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 68bddae..2048cfd 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -18,6 +18,7 @@
 #include <net/mac80211.h>
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
+#include "debugfs.h"
 
 
 /* This is a minimal implementation of TX rate controlling that can be used
@@ -121,6 +122,11 @@ struct sta_rate_control {
 	unsigned long avg_rate_update;
 	u32 tx_avg_rate_sum;
 	u32 tx_avg_rate_num;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct dentry *tx_avg_rate_sum_dentry;
+	struct dentry *tx_avg_rate_num_dentry;
+#endif
 };
 
 
@@ -327,6 +333,67 @@ static void rate_control_simple_free_sta(void *priv, void *priv_sta)
 	kfree(rctrl);
 }
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+
+static int open_file_generic(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t sta_tx_avg_rate_sum_read(struct file *file,
+					char __user *userbuf,
+					size_t count, loff_t *ppos)
+{
+	struct sta_rate_control *srctrl = file->private_data;
+	char buf[20];
+
+	sprintf(buf, "%d\n", srctrl->tx_avg_rate_sum);
+	return simple_read_from_buffer(userbuf, count, ppos, buf, strlen(buf));
+}
+
+static const struct file_operations sta_tx_avg_rate_sum_ops = {
+	.read = sta_tx_avg_rate_sum_read,
+	.open = open_file_generic,
+};
+
+static ssize_t sta_tx_avg_rate_num_read(struct file *file,
+					char __user *userbuf,
+					size_t count, loff_t *ppos)
+{
+	struct sta_rate_control *srctrl = file->private_data;
+	char buf[20];
+
+	sprintf(buf, "%d\n", srctrl->tx_avg_rate_num);
+	return simple_read_from_buffer(userbuf, count, ppos, buf, strlen(buf));
+}
+
+static const struct file_operations sta_tx_avg_rate_num_ops = {
+	.read = sta_tx_avg_rate_num_read,
+	.open = open_file_generic,
+};
+
+static void rate_control_simple_add_sta_debugfs(void *priv, void *priv_sta,
+						struct dentry *dir)
+{
+	struct sta_rate_control *srctrl = priv_sta;
+
+	srctrl->tx_avg_rate_num_dentry =
+		debugfs_create_file("rc_simple_sta_tx_avg_rate_num", 0400,
+				    dir, srctrl, &sta_tx_avg_rate_num_ops);
+	srctrl->tx_avg_rate_sum_dentry =
+		debugfs_create_file("rc_simple_sta_tx_avg_rate_sum", 0400,
+				    dir, srctrl, &sta_tx_avg_rate_sum_ops);
+}
+
+static void rate_control_simple_remove_sta_debugfs(void *priv, void *priv_sta)
+{
+	struct sta_rate_control *srctrl = priv_sta;
+
+	debugfs_remove(srctrl->tx_avg_rate_sum_dentry);
+	debugfs_remove(srctrl->tx_avg_rate_num_dentry);
+}
+#endif
 
 static struct rate_control_ops rate_control_simple = {
 	.module = THIS_MODULE,
@@ -339,6 +406,10 @@ static struct rate_control_ops rate_control_simple = {
 	.free = rate_control_simple_free,
 	.alloc_sta = rate_control_simple_alloc_sta,
 	.free_sta = rate_control_simple_free_sta,
+#ifdef CONFIG_MAC80211_DEBUGFS
+	.add_sta_debugfs = rate_control_simple_add_sta_debugfs,
+	.remove_sta_debugfs = rate_control_simple_remove_sta_debugfs,
+#endif
 };
 
 
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index cddaf57..ab7b1f0 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -19,6 +19,8 @@
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
 #include "sta_info.h"
+#include "debugfs_key.h"
+#include "debugfs_sta.h"
 
 /* Caller must hold local->sta_lock */
 static void sta_info_hash_add(struct ieee80211_local *local,
@@ -120,6 +122,8 @@ static void sta_info_release(struct kref *kref)
 	}
 	rate_control_free_sta(sta->rate_ctrl, sta->rate_ctrl_priv);
 	rate_control_put(sta->rate_ctrl);
+	if (sta->key)
+		ieee80211_debugfs_key_sta_del(sta->key, sta);
 	kfree(sta);
 }
 
@@ -173,9 +177,42 @@ struct sta_info * sta_info_add(struct ieee80211_local *local,
 	       local->mdev->name, MAC_ARG(addr));
 #endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+	if (!in_interrupt()) {
+		sta->debugfs_registered = 1;
+		ieee80211_sta_debugfs_add(sta);
+		rate_control_add_sta_debugfs(sta);
+	} else {
+		/* debugfs entry adding might sleep, so schedule process
+		 * context task for adding entry for STAs that do not yet
+		 * have one. */
+		queue_work(local->hw.workqueue, &local->sta_debugfs_add);
+	}
+#endif
+
 	return sta;
 }
 
+static void finish_sta_info_free(struct ieee80211_local *local,
+				 struct sta_info *sta)
+{
+#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
+	printk(KERN_DEBUG "%s: Removed STA " MAC_FMT "\n",
+	       local->mdev->name, MAC_ARG(sta->addr));
+#endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
+
+	if (sta->key) {
+		ieee80211_debugfs_key_remove(sta->key);
+		ieee80211_key_free(sta->key);
+		sta->key = NULL;
+	}
+
+	rate_control_remove_sta_debugfs(sta);
+	ieee80211_sta_debugfs_remove(sta);
+
+	sta_info_put(sta);
+}
+
 static void sta_info_remove(struct sta_info *sta)
 {
 	struct ieee80211_local *local = sta->local;
@@ -239,17 +276,13 @@ void sta_info_free(struct sta_info *sta, int locked)
 		sta->key_idx_compression = HW_KEY_IDX_INVALID;
 	}
 
-#ifdef CONFIG_MAC80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA " MAC_FMT "\n",
-	       local->mdev->name, MAC_ARG(sta->addr));
-#endif /* CONFIG_MAC80211_VERBOSE_DEBUG */
-
-	if (sta->key) {
-		ieee80211_key_free(sta->key);
-		sta->key = NULL;
-	}
-
-	sta_info_put(sta);
+#ifdef CONFIG_MAC80211_DEBUGFS
+	if (in_atomic()) {
+		list_add(&sta->list, &local->deleted_sta_list);
+		queue_work(local->hw.workqueue, &local->sta_debugfs_add);
+	} else
+#endif
+		finish_sta_info_free(local, sta);
 }
 
 
@@ -322,6 +355,50 @@ static void sta_info_cleanup(unsigned long data)
 	add_timer(&local->sta_cleanup);
 }
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+static void sta_info_debugfs_add_task(struct work_struct *work)
+{
+	struct ieee80211_local *local =
+		container_of(work, struct ieee80211_local, sta_debugfs_add);
+	struct sta_info *sta, *tmp;
+
+	while (1) {
+		spin_lock_bh(&local->sta_lock);
+		if (!list_empty(&local->deleted_sta_list)) {
+			sta = list_entry(local->deleted_sta_list.next,
+					 struct sta_info, list);
+			list_del(local->deleted_sta_list.next);
+		} else
+			sta = NULL;
+		spin_unlock_bh(&local->sta_lock);
+		if (!sta)
+			break;
+		finish_sta_info_free(local, sta);
+	}
+
+	while (1) {
+		sta = NULL;
+		spin_lock_bh(&local->sta_lock);
+		list_for_each_entry(tmp, &local->sta_list, list) {
+			if (!tmp->debugfs_registered) {
+				sta = tmp;
+				__sta_info_get(sta);
+				break;
+			}
+		}
+		spin_unlock_bh(&local->sta_lock);
+
+		if (!sta)
+			break;
+
+		sta->debugfs_registered = 1;
+		ieee80211_sta_debugfs_add(sta);
+		rate_control_add_sta_debugfs(sta);
+		sta_info_put(sta);
+	}
+}
+#endif
+
 void sta_info_init(struct ieee80211_local *local)
 {
 	spin_lock_init(&local->sta_lock);
@@ -332,6 +409,10 @@ void sta_info_init(struct ieee80211_local *local)
 	local->sta_cleanup.expires = jiffies + STA_INFO_CLEANUP_INTERVAL;
 	local->sta_cleanup.data = (unsigned long) local;
 	local->sta_cleanup.function = sta_info_cleanup;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	INIT_WORK(&local->sta_debugfs_add, sta_info_debugfs_add_task);
+#endif
 }
 
 int sta_info_start(struct ieee80211_local *local)
@@ -347,7 +428,10 @@ void sta_info_stop(struct ieee80211_local *local)
 	del_timer(&local->sta_cleanup);
 
 	list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
-		/*  We don't need locking at this point. */
+		/* sta_info_free must be called with 0 as the last
+		 * parameter to ensure all debugfs sta entries are
+		 * unregistered. We don't need locking at this
+		 * point. */
 		sta_info_free(sta, 0);
 	}
 }
diff --git a/net/mac80211/sta_info.h b/net/mac80211/sta_info.h
index f26e1c2..b5591d2 100644
--- a/net/mac80211/sta_info.h
+++ b/net/mac80211/sta_info.h
@@ -98,6 +98,9 @@ struct sta_info {
 				  * filtering; used only if sta->key is not
 				  * set */
 
+#ifdef CONFIG_MAC80211_DEBUGFS
+	int debugfs_registered;
+#endif
 	int assoc_ap; /* whether this is an AP that we are
 		       * associated with as a client */
 
@@ -109,6 +112,22 @@ struct sta_info {
 	int vlan_id;
 
 	u16 listen_interval;
+
+#ifdef CONFIG_MAC80211_DEBUGFS
+	struct sta_info_debugfsdentries {
+		struct dentry *dir;
+		struct dentry *flags;
+		struct dentry *num_ps_buf_frames;
+		struct dentry *last_ack_rssi;
+		struct dentry *last_ack_ms;
+		struct dentry *inactive_ms;
+		struct dentry *last_seq_ctrl;
+#ifdef CONFIG_MAC80211_DEBUG_COUNTERS
+		struct dentry *wme_rx_queue;
+		struct dentry *wme_tx_queue;
+#endif
+	} debugfs;
+#endif
 };
 
 
-- 
1.5.0.6

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
