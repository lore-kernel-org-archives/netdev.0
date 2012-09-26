From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/7 net-next] tg3: Add support for ethtool -L|-l to
 get/set the number of rings.
Date: Wed, 26 Sep 2012 15:32:48 -0700
Message-ID: <1348698769-760-6-git-send-email-mchan@broadcom.com>
References: <1348698769-760-1-git-send-email-mchan@broadcom.com>
 <1348698769-760-2-git-send-email-mchan@broadcom.com>
 <1348698769-760-3-git-send-email-mchan@broadcom.com>
 <1348698769-760-4-git-send-email-mchan@broadcom.com>
 <1348698769-760-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4336 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678Ab2IZWTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 18:19:36 -0400
In-Reply-To: <1348698769-760-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Default remains the same.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   64 +++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h |    2 +
 2 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3f2197e..74eea2f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10239,11 +10239,15 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	int i, rc;
 	struct msix_entry msix_ent[tp->irq_max];
 
-	tp->rxq_cnt = netif_get_num_default_rss_queues();
+	tp->txq_cnt = tp->txq_req;
+	tp->rxq_cnt = tp->rxq_req;
+	if (!tp->rxq_cnt)
+		tp->rxq_cnt = netif_get_num_default_rss_queues();
 	if (tp->rxq_cnt > tp->rxq_max)
 		tp->rxq_cnt = tp->rxq_max;
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) &&
+	    !tp->txq_req)
 		tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
 
 	tp->irq_cnt = tg3_irq_count(tp);
@@ -11384,6 +11388,58 @@ static int tg3_set_rxfh_indir(struct net_device *dev, const u32 *indir)
 	return 0;
 }
 
+static void tg3_get_channels(struct net_device *dev,
+			     struct ethtool_channels *channel)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	u32 deflt_qs = netif_get_num_default_rss_queues();
+
+	channel->max_rx = tp->rxq_max;
+	channel->max_tx = tp->txq_max;
+
+	if (netif_running(dev)) {
+		channel->rx_count = tp->rxq_cnt;
+		channel->tx_count = tp->txq_cnt;
+	} else {
+		if (tp->rxq_req)
+			channel->rx_count = tp->rxq_req;
+		else
+			channel->rx_count = min(deflt_qs, tp->rxq_max);
+
+		if (tp->txq_req)
+			channel->tx_count = tp->txq_req;
+		else
+			channel->tx_count = min(deflt_qs, tp->txq_max);
+	}
+}
+
+static int tg3_set_channels(struct net_device *dev,
+			    struct ethtool_channels *channel)
+{
+	struct tg3 *tp = netdev_priv(dev);
+
+	if (!tg3_flag(tp, SUPPORT_MSIX))
+		return -EOPNOTSUPP;
+
+	if (channel->rx_count > tp->rxq_max ||
+	    channel->tx_count > tp->txq_max)
+		return -EINVAL;
+
+	tp->rxq_req = channel->rx_count;
+	tp->txq_req = channel->tx_count;
+
+	if (!netif_running(dev))
+		return 0;
+
+	tg3_stop(tp);
+
+	netif_carrier_off(dev);
+
+	tg3_start(tp, true, false);
+
+	return 0;
+}
+
 static void tg3_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	switch (stringset) {
@@ -12632,6 +12688,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.get_rxfh_indir_size    = tg3_get_rxfh_indir_size,
 	.get_rxfh_indir		= tg3_get_rxfh_indir,
 	.set_rxfh_indir		= tg3_set_rxfh_indir,
+	.get_channels		= tg3_get_channels,
+	.set_channels		= tg3_set_channels,
 	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 2abe94c..d9308c3 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3038,6 +3038,7 @@ struct tg3 {
 	void				(*write32_tx_mbox) (struct tg3 *, u32,
 							    u32);
 	u32				dma_limit;
+	u32				txq_req;
 	u32				txq_cnt;
 	u32				txq_max;
 
@@ -3054,6 +3055,7 @@ struct tg3 {
 	u32				rx_std_max_post;
 	u32				rx_offset;
 	u32				rx_pkt_map_sz;
+	u32				rxq_req;
 	u32				rxq_cnt;
 	u32				rxq_max;
 	bool				rx_refill;
-- 
1.7.1
