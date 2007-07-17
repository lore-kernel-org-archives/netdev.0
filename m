From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 4/4] ibmveth: Add ethtool driver stats hooks
Date: Tue, 17 Jul 2007 10:18:11 -0500
Message-ID: <200707171518.l6HFICqM006034@d03av02.boulder.ibm.com>
References: <11846854701127-patch-mail.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:53588 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981AbXGQPSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:18:21 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l6HFCdKk002924
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 11:12:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6HFIEB5117936
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 09:18:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6HFIDac006153
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 09:18:13 -0600
In-Reply-To: <11846854701127-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add ethtool hooks to ibmveth to retrieve driver statistics.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   53 +++++++++++++++++++++++++++++++-
 1 file changed, 52 insertions(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_driver_stats	2007-07-12 09:39:23.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-12 09:39:23.000000000 -0500
@@ -115,6 +115,28 @@ MODULE_VERSION(ibmveth_driver_version);
 module_param_named(csum_offload, ibmveth_csum_offload, uint, 0);
 MODULE_PARM_DESC(csum_offload, "Checksum offload (0/1). Default: 1");
 
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
@@ -756,6 +778,32 @@ static u32 ibmveth_get_rx_csum(struct ne
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
@@ -766,7 +814,10 @@ static const struct ethtool_ops netdev_e
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
