From: Jim Lewis <jklewis@us.ibm.com>
Subject: [PATCH] Spidernet: add ethtool -S (show statistics)
Date: Thu, 21 Sep 2006 14:02:32 -0500
Message-ID: <1158865352.30496.29.camel@lewis2.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42693 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751464AbWIUTCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 15:02:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8LJ2Rg0023925
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:02:27 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8LJ2Rs4253480
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:02:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8LJ2Qs4029391
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:02:27 -0400
To: jgarzik@pobox.com, akpm@osdl.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the ethtool -S (show statistics) feature to the
Spidernet ethernet driver. I have tested it extensively and believe it
is ready to be applied.


Signed-off-by: James K Lewis


---
 drivers/net/spider_net.c         |   10 ++++++
 drivers/net/spider_net.h         |   11 ++++++-
 drivers/net/spider_net_ethtool.c |   56
+++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 2 deletions(-)

Index: linux-2.6.18-rc2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net.c	2006-09-05
17:56:19.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net.c	2006-09-20
14:03:54.000000000 -0500
@@ -472,6 +472,7 @@ spider_net_prepare_rx_descr(struct spide
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Not enough memory to allocate rx buffer\n");
+		card->spider_stats.alloc_rx_skb_error++;
 		return -ENOMEM;
 	}
 	descr->buf_size = bufsize;
@@ -492,6 +493,7 @@ spider_net_prepare_rx_descr(struct spide
 		dev_kfree_skb_any(descr->skb);
 		if (netif_msg_rx_err(card) && net_ratelimit())
 			pr_err("Could not iommu-map rx buffer\n");
+		card->spider_stats.rx_iommu_map_error++;
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
 		descr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
@@ -721,6 +723,7 @@ spider_net_prepare_tx_descr(struct spide
 		if (netif_msg_tx_err(card) && net_ratelimit())
 			pr_err("could not iommu-map packet (%p, %i). "
 				  "Dropping packet\n", skb->data, skb->len);
+		card->spider_stats.tx_iommu_map_error++;
 		return -ENOMEM;
 	}
 
@@ -942,6 +945,7 @@ spider_net_xmit(struct sk_buff *skb, str
 	}
 
 	if (spider_net_get_descr_status(descr) != SPIDER_NET_DESCR_NOT_IN_USE)
{
+		card->netdev_stats.tx_dropped++;
 		result = NETDEV_TX_LOCKED;
 		netif_stop_queue(netdev);
 		goto out;
@@ -1047,6 +1051,7 @@ spider_net_pass_skb_up(struct spider_net
 			pr_err("error in received descriptor found, "
 			       "data_status=x%08x, data_error=x%08x\n",
 			       data_status, data_error);
+		card->spider_stats.rx_desc_error++;
 		return 0;
 	}
 
@@ -1144,9 +1149,11 @@ spider_net_decode_one_descr(struct spide
 
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
 	     (status != SPIDER_NET_DESCR_FRAME_END) ) {
-		if (netif_msg_rx_err(card))
+		if (netif_msg_rx_err(card)) {
 			pr_err("%s: RX descriptor with state %d\n",
 			       card->netdev->name, status);
+			card->spider_stats.rx_desc_unk_state++;
+		}
 		goto refill;
 	}
 
@@ -2112,6 +2119,7 @@ spider_net_tx_timeout(struct net_device 
 		schedule_work(&card->tx_timeout_task);
 	else
 		atomic_dec(&card->tx_timeout_task_counter);
+	card->spider_stats.tx_timeouts++;
 }
 
 /**
Index: linux-2.6.18-rc2/drivers/net/spider_net.h
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net.h	2006-09-07
17:45:15.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net.h	2006-09-20
14:02:10.000000000 -0500
@@ -438,6 +438,15 @@ struct spider_net_options {
 					  NETIF_MSG_HW | \
 					  NETIF_MSG_WOL )
 
+struct spider_net_extra_stats {
+	unsigned long rx_desc_error;
+	unsigned long tx_timeouts;
+	unsigned long alloc_rx_skb_error;
+	unsigned long rx_iommu_map_error;
+	unsigned long tx_iommu_map_error;
+	unsigned long rx_desc_unk_state;
+};
+
 struct spider_net_card {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
@@ -464,9 +473,9 @@ struct spider_net_card {
 
 	/* for ethtool */
 	int msg_enable;
-
 	int rx_desc;
 	int tx_desc;
+	struct spider_net_extra_stats spider_stats;
 
 	struct spider_net_descr descr[0];
 };
Index: linux-2.6.18-rc2/drivers/net/spider_net_ethtool.c
===================================================================
--- linux-2.6.18-rc2.orig/drivers/net/spider_net_ethtool.c	2006-08-23
19:01:02.000000000 -0500
+++ linux-2.6.18-rc2/drivers/net/spider_net_ethtool.c	2006-09-20
14:06:28.000000000 -0500
@@ -27,6 +27,27 @@
 
 #include "spider_net.h"
 
+
+#define SPIDER_NET_NUM_STATS 13
+
+static struct {
+	const char str[ETH_GSTRING_LEN];
+} ethtool_stats_keys[] = {
+	{ "tx_packets" },
+	{ "tx_bytes" },
+	{ "rx_packets" },
+	{ "rx_bytes" },
+	{ "tx_errors" },
+	{ "tx_dropped" },
+	{ "rx_dropped" },
+	{ "rx_descriptor_error" },
+	{ "tx_timeouts" },
+	{ "alloc_rx_skb_error" },
+	{ "rx_iommu_map_error" },
+	{ "tx_iommu_map_error" },
+	{ "rx_desc_unk_state" },
+};
+
 static int
 spider_net_ethtool_get_settings(struct net_device *netdev,
 			       struct ethtool_cmd *cmd)
@@ -143,6 +164,38 @@ spider_net_ethtool_get_ringparam(struct 
 
 }
 
+static int spider_net_get_stats_count(struct net_device *netdev)
+{
+	return SPIDER_NET_NUM_STATS;
+}
+
+static void spider_net_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, u64 *data)
+{
+	struct spider_net_card *card = netdev->priv;
+
+	data[0] = card->netdev_stats.tx_packets;
+	data[1] = card->netdev_stats.tx_bytes;
+	data[2] = card->netdev_stats.rx_packets;
+	data[3] = card->netdev_stats.rx_bytes;
+	data[4] = card->netdev_stats.tx_errors;
+	data[5] = card->netdev_stats.tx_dropped;
+	data[6] = card->netdev_stats.rx_dropped;
+	data[7] = card->spider_stats.rx_desc_error;
+	data[8] = card->spider_stats.tx_timeouts;
+	data[9] = card->spider_stats.alloc_rx_skb_error;
+	data[10] = card->spider_stats.rx_iommu_map_error;
+	data[11] = card->spider_stats.tx_iommu_map_error;
+	data[12] = card->spider_stats.rx_desc_unk_state;
+}
+
+static void spider_net_get_strings(struct net_device *netdev, u32
stringset,
+				   u8 *data)
+{
+	memcpy(data, ethtool_stats_keys, sizeof(ethtool_stats_keys));
+}
+
+
 struct ethtool_ops spider_net_ethtool_ops = {
 	.get_settings		= spider_net_ethtool_get_settings,
 	.get_drvinfo		= spider_net_ethtool_get_drvinfo,
@@ -155,5 +208,8 @@ struct ethtool_ops spider_net_ethtool_op
 	.get_tx_csum		= spider_net_ethtool_get_tx_csum,
 	.set_tx_csum		= spider_net_ethtool_set_tx_csum,
 	.get_ringparam          = spider_net_ethtool_get_ringparam,
+	.get_strings		= spider_net_get_strings,
+	.get_stats_count	= spider_net_get_stats_count,
+	.get_ethtool_stats	= spider_net_get_ethtool_stats,
 };
 


