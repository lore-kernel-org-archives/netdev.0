From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 20:57:29 +0100
Message-ID: <1268337450-6749-4-git-send-email-jengelh@medozas.de>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56848 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135Ab0CKT5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 14:57:37 -0500
In-Reply-To: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

`ip -s link` shows interface counters truncated to 32 bit. This is
because interface statistics are transported only in 32-bit quantity
to userspace. This commit adds a new IFLA_STATS64 attribute that
exports them in full 64 bit.

References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/0215.html
Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/if_link.h |   33 +++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c    |   42 +++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 74 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c9bf92c..cfd420b 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -37,6 +37,38 @@ struct rtnl_link_stats {
 	__u32	tx_compressed;
 };
 
+struct rtnl_link_stats64 {
+	__u64	rx_packets;		/* total packets received	*/
+	__u64	tx_packets;		/* total packets transmitted	*/
+	__u64	rx_bytes;		/* total bytes received 	*/
+	__u64	tx_bytes;		/* total bytes transmitted	*/
+	__u64	rx_errors;		/* bad packets received		*/
+	__u64	tx_errors;		/* packet transmit problems	*/
+	__u64	rx_dropped;		/* no space in linux buffers	*/
+	__u64	tx_dropped;		/* no space available in linux	*/
+	__u64	multicast;		/* multicast packets received	*/
+	__u64	collisions;
+
+	/* detailed rx_errors: */
+	__u64	rx_length_errors;
+	__u64	rx_over_errors;		/* receiver ring buff overflow	*/
+	__u64	rx_crc_errors;		/* recved pkt with crc error	*/
+	__u64	rx_frame_errors;	/* recv'd frame alignment error */
+	__u64	rx_fifo_errors;		/* recv'r fifo overrun		*/
+	__u64	rx_missed_errors;	/* receiver missed packet	*/
+
+	/* detailed tx_errors */
+	__u64	tx_aborted_errors;
+	__u64	tx_carrier_errors;
+	__u64	tx_fifo_errors;
+	__u64	tx_heartbeat_errors;
+	__u64	tx_window_errors;
+
+	/* for cslip etc */
+	__u64	rx_compressed;
+	__u64	tx_compressed;
+};
+
 /* The struct should be in sync with struct ifmap */
 struct rtnl_link_ifmap {
 	__u64	mem_start;
@@ -83,6 +115,7 @@ enum {
 	IFLA_VF_VLAN,
 	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
 	IFLA_VFINFO,
+	IFLA_STATS64,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 4568120..e1121f0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -600,7 +600,39 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 
 	a->rx_compressed = b->rx_compressed;
 	a->tx_compressed = b->tx_compressed;
-};
+}
+
+static void copy_rtnl_link_stats64(struct rtnl_link_stats64 *a,
+				   const struct net_device_stats *b)
+{
+	a->rx_packets = b->rx_packets;
+	a->tx_packets = b->tx_packets;
+	a->rx_bytes = b->rx_bytes;
+	a->tx_bytes = b->tx_bytes;
+	a->rx_errors = b->rx_errors;
+	a->tx_errors = b->tx_errors;
+	a->rx_dropped = b->rx_dropped;
+	a->tx_dropped = b->tx_dropped;
+
+	a->multicast = b->multicast;
+	a->collisions = b->collisions;
+
+	a->rx_length_errors = b->rx_length_errors;
+	a->rx_over_errors = b->rx_over_errors;
+	a->rx_crc_errors = b->rx_crc_errors;
+	a->rx_frame_errors = b->rx_frame_errors;
+	a->rx_fifo_errors = b->rx_fifo_errors;
+	a->rx_missed_errors = b->rx_missed_errors;
+
+	a->tx_aborted_errors = b->tx_aborted_errors;
+	a->tx_carrier_errors = b->tx_carrier_errors;
+	a->tx_fifo_errors = b->tx_fifo_errors;
+	a->tx_heartbeat_errors = b->tx_heartbeat_errors;
+	a->tx_window_errors = b->tx_window_errors;
+
+	a->rx_compressed = b->rx_compressed;
+	a->tx_compressed = b->tx_compressed;
+}
 
 static inline int rtnl_vfinfo_size(const struct net_device *dev)
 {
@@ -698,6 +730,14 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	stats = dev_get_stats(dev);
 	copy_rtnl_link_stats(nla_data(attr), stats);
 
+	attr = nla_reserve(skb, IFLA_STATS64,
+			sizeof(struct rtnl_link_stats64));
+	if (attr == NULL)
+		goto nla_put_failure;
+
+	stats = dev_get_stats(dev);
+	copy_rtnl_link_stats64(nla_data(attr), stats);
+
 	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
 		int i;
 		struct ifla_vf_info ivi;
-- 
1.7.0

