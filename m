From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 6/6] be2net: add a counter for pkts dropped in xmit path
Date: Tue, 1 Oct 2013 16:00:01 +0530
Message-ID: <1380623401-15630-7-git-send-email-sathya.perla@emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:37813 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115Ab3JAK0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:50 -0400
In-Reply-To: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the xmit path, the driver may drop some pkts due to reasons such as
DMA mapping errors, out of memory conditions or to protect HW from
unrecoverable errors. Add a counter in TX-stats for such drops.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    4 +++-
 drivers/net/ethernet/emulex/benet/be_main.c    |    5 ++++-
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index e7cbc56..21b064f 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -225,6 +225,7 @@ struct be_tx_stats {
 	u64 tx_compl;
 	ulong tx_jiffies;
 	u32 tx_stops;
+	u32 tx_drv_drops;	/* pkts dropped by driver */
 	struct u64_stats_sync sync;
 	struct u64_stats_sync sync_compl;
 };
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index a08783c..3dcf817 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -155,7 +155,9 @@ static const struct be_ethtool_stat et_tx_stats[] = {
 	/* Number of times the TX queue was stopped due to lack
 	 * of spaces in the TXQ.
 	 */
-	{DRVSTAT_TX_INFO(tx_stops)}
+	{DRVSTAT_TX_INFO(tx_stops)},
+	/* Pkts dropped in the driver's transmit path */
+	{DRVSTAT_TX_INFO(tx_drv_drops)}
 };
 #define ETHTOOL_TXSTATS_NUM (ARRAY_SIZE(et_tx_stats))
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6691d75..0a168e3 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -935,8 +935,10 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 	u32 start = txq->head;
 
 	skb = be_xmit_workarounds(adapter, skb, &skip_hw_vlan);
-	if (!skb)
+	if (!skb) {
+		tx_stats(txo)->tx_drv_drops++;
 		return NETDEV_TX_OK;
+	}
 
 	wrb_cnt = wrb_cnt_for_skb(adapter, skb, &dummy_wrb);
 
@@ -965,6 +967,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 		be_tx_stats_update(txo, wrb_cnt, copied, gso_segs, stopped);
 	} else {
 		txq->head = start;
+		tx_stats(txo)->tx_drv_drops++;
 		dev_kfree_skb_any(skb);
 	}
 	return NETDEV_TX_OK;
-- 
1.7.1
