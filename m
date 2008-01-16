From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: [patch] add net_device_stats support to ethtool
Date: Wed, 16 Jan 2008 07:29:41 -0800
Message-ID: <200801161529.m0GFTfYR005096@sallyv1.ics.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sallyv1.ics.uci.edu ([128.195.1.109]:47601 "EHLO
	sallyv1.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbYAPPls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 10:41:48 -0500
Received: from mothra.ics.uci.edu (mothra.ics.uci.edu [128.195.6.93])
	by sallyv1.ics.uci.edu (8.13.7+Sun/8.13.7) with ESMTP id m0GFTfYR005096
	for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 07:29:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

I have posted this patch in the past with absolutely no reply.
I would appreciate some sort of feedback of the form 
interested/not interested.  Should I just drop it?

"ethtool -S" only supports devices that have custom code written to
print the stats. 

A lot of drivers use "struct net_device_stats", so adding code to
ethtool would make it very easy for such drivers to add support for
"ethtool -S". The drivers would just need to add this:

	.get_strings	   = ethtool_op_net_device_stats_get_strings,
	.get_stats_count   = ethtool_op_net_device_stats_get_stats_count,
	.get_ethtool_stats = ethtool_op_net_device_get_ethtool_stats,

to their struct ethtool_ops. I found this very useful when debugging a
new driver.

(The function names are not the best, suggestions for better names are
welcome).

The code added is very small, and it gives easy access to stats that the
drivers are computing anyway.

This should save code in case the drivers the use net_device_stats
decide they want ethtool stats support.

The patch only adds, it does not modify any existing line of code.

Thanks
        --Dan

--- ethtool.c~	2004-12-24 13:35:50.000000000 -0800
+++ ethtool.c	2006-12-01 08:55:26.000000000 -0800
@@ -809,6 +809,64 @@
 	return -EOPNOTSUPP;
 }
 
+
+#define NET_DEVICE_NUM_STATS (sizeof(struct net_device_stats) / sizeof(unsigned long))
+
+static struct {
+	const char string[ETH_GSTRING_LEN];
+} ethtool_net_device_stats_keys[NET_DEVICE_NUM_STATS] = {
+	{ "rx_packets"},	 
+	{ "tx_packets"},	 
+	{ "rx_bytes"},	 
+	{ "tx_bytes"},	 
+	{ "rx_errors"},	 
+	{ "tx_errors"},	 
+	{ "rx_dropped"},	 
+	{ "tx_dropped"},	 
+	{ "multicast"},	 
+	{ "collisions"},
+	{ "rx_length_errors"},
+	{ "rx_over_errors"},	 
+	{ "rx_crc_errors"},	 
+	{ "rx_frame_errors"}, 
+	{ "rx_fifo_errors"},	 
+	{ "rx_missed_errors"},
+	{ "tx_aborted_errors"},
+	{ "tx_carrier_errors"},
+	{ "tx_fifo_errors"},
+	{ "tx_heartbeat_errors"},
+	{ "tx_window_errors"},
+	{ "rx_compressed"},
+	{ "tx_compressed"}
+};
+
+int ethtool_op_net_device_stats_get_stats_count(struct net_device *dev)
+{
+	return NET_DEVICE_NUM_STATS;
+}
+
+void ethtool_op_net_device_stats_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &ethtool_net_device_stats_keys, sizeof(ethtool_net_device_stats_keys));
+		break;
+	default:
+		WARN_ON(1);	/* we need a WARN() */
+		break;
+	}
+}
+
+void ethtool_op_net_device_get_ethtool_stats(struct net_device *dev,
+					      struct ethtool_stats *estats, u64 *tmp_stats)
+{
+	u32 i;
+	u64 *dest = tmp_stats;
+	unsigned long *src = (unsigned long*)dev->get_stats(dev);
+	for (i = 0; i < estats->n_stats; i++)
+	  *dest++ = *src++;
+}
+
 EXPORT_SYMBOL(dev_ethtool);
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_sg);
@@ -817,3 +875,6 @@
 EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
+EXPORT_SYMBOL(ethtool_op_net_device_stats_get_stats_count);
+EXPORT_SYMBOL(ethtool_op_net_device_stats_get_strings);
+EXPORT_SYMBOL(ethtool_op_net_device_get_ethtool_stats);
--- ethtool.h~	2006-09-05 12:29:45.000000000 -0700
+++ ethtool.h	2006-12-01 08:51:46.000000000 -0800
@@ -260,6 +260,12 @@
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
+int ethtool_op_net_device_stats_get_stats_count(struct net_device *dev);
+void ethtool_op_net_device_stats_get_strings(struct net_device *dev,
+					     u32 stringset, u8 *buf);
+void ethtool_op_net_device_get_ethtool_stats(struct net_device *dev,
+					     struct ethtool_stats *estats,
+					     u64 *tmp_stats);
 
 /**
  * &ethtool_ops - Alter and report network device settings
