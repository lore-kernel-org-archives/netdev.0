From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 4/6] ibmveth: Add ethtool driver stats hooks
Date: Mon, 06 Aug 2007 14:42:34 -0500
Message-ID: <200708061942.l76JgZRK020999@d03av03.boulder.ibm.com>
References: <11864293333377-patch-mail.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48483 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbXHFTmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 15:42:40 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l76JgajB025397
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 15:42:36 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l76JganS266270
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 13:42:36 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l76JgZCK021072
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 13:42:36 -0600
In-Reply-To: <11864293333377-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add ethtool hooks to ibmveth to retrieve driver statistics.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 drivers/net/ibmveth.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 52 insertions(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats	2007-07-19 11:18:41.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-19 11:18:41.000000000 -0500
@@ -112,6 +112,28 @@ MODULE_DESCRIPTION("IBM i/pSeries Virtua
 MODULE_LICENSE("GPL");
 MODULE_VERSION(ibmveth_driver_version);
 
+struct ibmveth_stat {
+	char name[ETH_GSTRING_LEN];
+	int offset;
+};
+
+#define IBMVETH_STAT_OFF(stat) offsetof(struct ibmveth_adapter, stat)
+#define IBMVETH_GET_STAT(a, off) *((u64 *)(((unsigned long)(a)) + off))
+
+struct ibmveth_stat ibmveth_stats[] = {
+	{ "replenish_task_cycles", IBMVETH_STAT_OFF(replenish_task_cycles) },
+	{ "replenish_no_mem", IBMVETH_STAT_OFF(replenish_no_mem) },
+	{ "replenish_add_buff_failure", IBMVETH_STAT_OFF(replenish_add_buff_failure) },
+	{ "replenish_add_buff_success", IBMVETH_STAT_OFF(replenish_add_buff_success) },
+	{ "rx_invalid_buffer", IBMVETH_STAT_OFF(rx_invalid_buffer) },
+	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
+	{ "tx_multidesc_send", IBMVETH_STAT_OFF(tx_multidesc_send) },
+	{ "tx_linearized", IBMVETH_STAT_OFF(tx_linearized) },
+	{ "tx_linearize_failed", IBMVETH_STAT_OFF(tx_linearize_failed) },
+	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
+	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) }
+};
+
 /* simple methods of getting data from the current rxq entry */
 static inline int ibmveth_rxq_pending_buffer(struct ibmveth_adapter *adapter)
 {
@@ -751,6 +773,32 @@ static u32 ibmveth_get_rx_csum(struct ne
 	return adapter->rx_csum;
 }
 
+static void ibmveth_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	int i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++, data += ETH_GSTRING_LEN)
+		memcpy(data, ibmveth_stats[i].name, ETH_GSTRING_LEN);
+}
+
+static int ibmveth_get_stats_count(struct net_device *dev)
+{
+	return ARRAY_SIZE(ibmveth_stats);
+}
+
+static void ibmveth_get_ethtool_stats(struct net_device *dev,
+				      struct ethtool_stats *stats, u64 *data)
+{
+	int i;
+	struct ibmveth_adapter *adapter = dev->priv;
+
+	for (i = 0; i < ARRAY_SIZE(ibmveth_stats); i++)
+		data[i] = IBMVETH_GET_STAT(adapter, ibmveth_stats[i].offset);
+}
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
@@ -761,7 +809,10 @@ static const struct ethtool_ops netdev_e
 	.get_rx_csum		= ibmveth_get_rx_csum,
 	.set_rx_csum		= ibmveth_set_rx_csum,
 	.get_tso			= ethtool_op_get_tso,
-	.get_ufo			= ethtool_op_get_ufo
+	.get_ufo			= ethtool_op_get_ufo,
+	.get_strings		= ibmveth_get_strings,
+	.get_stats_count		= ibmveth_get_stats_count,
+	.get_ethtool_stats	= ibmveth_get_ethtool_stats
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
diff -puN drivers/net/ibmveth.h~ibmveth_ethtool_driver_stats drivers/net/ibmveth.h
_
