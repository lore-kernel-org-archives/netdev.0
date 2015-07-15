From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/2] enic: allow adaptive coalesce setting for msi/legacy intr
Date: Wed, 15 Jul 2015 15:34:40 +0530
Message-ID: <1436954680-10248-2-git-send-email-_govind@gmx.com>
References: <1436954680-10248-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:59320 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756028AbbGOKFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jul 2015 06:05:18 -0400
In-Reply-To: <1436954680-10248-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Allow setting of adaptive coalescing setting for all types of interrupt.

* In msi & legacy intr, we use single interrupt for rx & tx. In this case
  tx_coalesce_usecs is invalid. We should use only rx_coalesce_usecs.
  Do not display tx_coal values for msi/intx. And do not allow user to set
  this as well.

* Driver supports only tx/rx_coalesce_usec and adaptive coalesce settings.
  For other values, driver does not return error. So ethtool succeeds for
  unsupported values. Introduce enic_coalesce_valid() function to validate
  the coalescing values.

* If user requests for coalesce value greater than what adaptor supports,
  driver uses the max value. We should at least log this.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 113 ++++++++++++++-----------
 1 file changed, 65 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index f3f1601..f44a39c 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -224,7 +224,8 @@ static int enic_get_coalesce(struct net_device *netdev,
 	struct enic *enic = netdev_priv(netdev);
 	struct enic_rx_coal *rxcoal = &enic->rx_coalesce_setting;
 
-	ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX)
+		ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
 	ecmd->rx_coalesce_usecs = enic->rx_coalesce_usecs;
 	if (rxcoal->use_adaptive_rx_coalesce)
 		ecmd->use_adaptive_rx_coalesce = 1;
@@ -234,6 +235,53 @@ static int enic_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int enic_coalesce_valid(struct enic *enic,
+			       struct ethtool_coalesce *ec)
+{
+	u32 coalesce_usecs_max = vnic_dev_get_intr_coal_timer_max(enic->vdev);
+	u32 rx_coalesce_usecs_high = min_t(u32, coalesce_usecs_max,
+					   ec->rx_coalesce_usecs_high);
+	u32 rx_coalesce_usecs_low = min_t(u32, coalesce_usecs_max,
+					  ec->rx_coalesce_usecs_low);
+
+	if (ec->rx_max_coalesced_frames		||
+	    ec->rx_coalesce_usecs_irq		||
+	    ec->rx_max_coalesced_frames_irq	||
+	    ec->tx_max_coalesced_frames		||
+	    ec->tx_coalesce_usecs_irq		||
+	    ec->tx_max_coalesced_frames_irq	||
+	    ec->stats_block_coalesce_usecs	||
+	    ec->use_adaptive_tx_coalesce	||
+	    ec->pkt_rate_low			||
+	    ec->rx_max_coalesced_frames_low	||
+	    ec->tx_coalesce_usecs_low		||
+	    ec->tx_max_coalesced_frames_low	||
+	    ec->pkt_rate_high			||
+	    ec->rx_max_coalesced_frames_high	||
+	    ec->tx_coalesce_usecs_high		||
+	    ec->tx_max_coalesced_frames_high	||
+	    ec->rate_sample_interval)
+		return -EINVAL;
+
+	if ((vnic_dev_get_intr_mode(enic->vdev) != VNIC_DEV_INTR_MODE_MSIX) &&
+	    ec->tx_coalesce_usecs)
+		return -EINVAL;
+
+	if ((ec->tx_coalesce_usecs > coalesce_usecs_max)	||
+	    (ec->rx_coalesce_usecs > coalesce_usecs_max)	||
+	    (ec->rx_coalesce_usecs_low > coalesce_usecs_max)	||
+	    (ec->rx_coalesce_usecs_high > coalesce_usecs_max))
+		netdev_info(enic->netdev, "ethtool_set_coalesce: adaptor supports max coalesce value of %d. Setting max value.\n",
+			    coalesce_usecs_max);
+
+	if (ec->rx_coalesce_usecs_high &&
+	    (rx_coalesce_usecs_high <
+	     rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
+		return -EINVAL;
+
+	return 0;
+}
+
 static int enic_set_coalesce(struct net_device *netdev,
 	struct ethtool_coalesce *ecmd)
 {
@@ -244,8 +292,12 @@ static int enic_set_coalesce(struct net_device *netdev,
 	u32 rx_coalesce_usecs_high;
 	u32 coalesce_usecs_max;
 	unsigned int i, intr;
+	int ret;
 	struct enic_rx_coal *rxcoal = &enic->rx_coalesce_setting;
 
+	ret = enic_coalesce_valid(enic, ecmd);
+	if (ret)
+		return ret;
 	coalesce_usecs_max = vnic_dev_get_intr_coal_timer_max(enic->vdev);
 	tx_coalesce_usecs = min_t(u32, ecmd->tx_coalesce_usecs,
 				  coalesce_usecs_max);
@@ -257,59 +309,24 @@ static int enic_set_coalesce(struct net_device *netdev,
 	rx_coalesce_usecs_high = min_t(u32, ecmd->rx_coalesce_usecs_high,
 				       coalesce_usecs_max);
 
-	switch (vnic_dev_get_intr_mode(enic->vdev)) {
-	case VNIC_DEV_INTR_MODE_INTX:
-		if (tx_coalesce_usecs != rx_coalesce_usecs)
-			return -EINVAL;
-		if (ecmd->use_adaptive_rx_coalesce	||
-		    ecmd->rx_coalesce_usecs_low		||
-		    ecmd->rx_coalesce_usecs_high)
-			return -EINVAL;
-
-		intr = enic_legacy_io_intr();
-		vnic_intr_coalescing_timer_set(&enic->intr[intr],
-			tx_coalesce_usecs);
-		break;
-	case VNIC_DEV_INTR_MODE_MSI:
-		if (tx_coalesce_usecs != rx_coalesce_usecs)
-			return -EINVAL;
-		if (ecmd->use_adaptive_rx_coalesce	||
-		    ecmd->rx_coalesce_usecs_low		||
-		    ecmd->rx_coalesce_usecs_high)
-			return -EINVAL;
-
-		vnic_intr_coalescing_timer_set(&enic->intr[0],
-			tx_coalesce_usecs);
-		break;
-	case VNIC_DEV_INTR_MODE_MSIX:
-		if (ecmd->rx_coalesce_usecs_high &&
-		    (rx_coalesce_usecs_high <
-		     rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
-				return -EINVAL;
-
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX) {
 		for (i = 0; i < enic->wq_count; i++) {
 			intr = enic_msix_wq_intr(enic, i);
 			vnic_intr_coalescing_timer_set(&enic->intr[intr],
-				tx_coalesce_usecs);
-		}
-
-		rxcoal->use_adaptive_rx_coalesce =
-					!!ecmd->use_adaptive_rx_coalesce;
-		if (!rxcoal->use_adaptive_rx_coalesce)
-			enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
-
-		if (ecmd->rx_coalesce_usecs_high) {
-			rxcoal->range_end = rx_coalesce_usecs_high;
-			rxcoal->small_pkt_range_start = rx_coalesce_usecs_low;
-			rxcoal->large_pkt_range_start = rx_coalesce_usecs_low +
-							ENIC_AIC_LARGE_PKT_DIFF;
+						       tx_coalesce_usecs);
 		}
-		break;
-	default:
-		break;
+		enic->tx_coalesce_usecs = tx_coalesce_usecs;
+	}
+	rxcoal->use_adaptive_rx_coalesce = !!ecmd->use_adaptive_rx_coalesce;
+	if (!rxcoal->use_adaptive_rx_coalesce)
+		enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
+	if (ecmd->rx_coalesce_usecs_high) {
+		rxcoal->range_end = rx_coalesce_usecs_high;
+		rxcoal->small_pkt_range_start = rx_coalesce_usecs_low;
+		rxcoal->large_pkt_range_start = rx_coalesce_usecs_low +
+						ENIC_AIC_LARGE_PKT_DIFF;
 	}
 
-	enic->tx_coalesce_usecs = tx_coalesce_usecs;
 	enic->rx_coalesce_usecs = rx_coalesce_usecs;
 
 	return 0;
-- 
2.4.5
