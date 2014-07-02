From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: fix return values in enic_set_coalesce
Date: Wed,  2 Jul 2014 15:42:15 +0530
Message-ID: <1404295935-13597-1-git-send-email-_govind@gmx.com>
Cc: benve@cisco.com, ssujith@cisco.com, ben@decadent.org.uk,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:62438 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbaGBKNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 06:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic_set_coalesce() has two problems.

* It should return -EINVAL and not -EOPNOTSUPP for invalid coalesce values.

* In case of MSIX, enic_set_coalesce return error after applying requested
  coalescing setting partially. We should either apply all the setting requeste
  and return success or apply non and return error.

* This patch also simplifies the algo.

This was introduced by
'7c2ce6e60f703 enic: Add support for adaptive interrupt coalescing'

These changes were suggested by Ben Hutchings here
http://www.spinics.net/lists/netdev/msg283972.html

Also change enic driver version.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h         |  2 +-
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 27 +++++++++++---------------
 2 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index c8aa9fb..4ecbbb3 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.50"
+#define DRV_VERSION		"2.1.1.67"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 2e50b54..c75f84b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -231,7 +231,7 @@ static int enic_set_coalesce(struct net_device *netdev,
 		if (ecmd->use_adaptive_rx_coalesce	||
 		    ecmd->rx_coalesce_usecs_low		||
 		    ecmd->rx_coalesce_usecs_high)
-			return -EOPNOTSUPP;
+			return -EINVAL;
 
 		intr = enic_legacy_io_intr();
 		vnic_intr_coalescing_timer_set(&enic->intr[intr],
@@ -243,34 +243,29 @@ static int enic_set_coalesce(struct net_device *netdev,
 		if (ecmd->use_adaptive_rx_coalesce	||
 		    ecmd->rx_coalesce_usecs_low		||
 		    ecmd->rx_coalesce_usecs_high)
-			return -EOPNOTSUPP;
+			return -EINVAL;
 
 		vnic_intr_coalescing_timer_set(&enic->intr[0],
 			tx_coalesce_usecs);
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
+		if (ecmd->rx_coalesce_usecs_high &&
+		    (rx_coalesce_usecs_high <
+		     rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
+				return -EINVAL;
+
 		for (i = 0; i < enic->wq_count; i++) {
 			intr = enic_msix_wq_intr(enic, i);
 			vnic_intr_coalescing_timer_set(&enic->intr[intr],
 				tx_coalesce_usecs);
 		}
 
-		if (rxcoal->use_adaptive_rx_coalesce) {
-			if (!ecmd->use_adaptive_rx_coalesce) {
-				rxcoal->use_adaptive_rx_coalesce = 0;
-				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
-			}
-		} else {
-			if (ecmd->use_adaptive_rx_coalesce)
-				rxcoal->use_adaptive_rx_coalesce = 1;
-			else
-				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
-		}
+		rxcoal->use_adaptive_rx_coalesce =
+					!!ecmd->use_adaptive_rx_coalesce;
+		if (!rxcoal->use_adaptive_rx_coalesce)
+			enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
 
 		if (ecmd->rx_coalesce_usecs_high) {
-			if (rx_coalesce_usecs_high <
-			    (rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
-				return -EINVAL;
 			rxcoal->range_end = rx_coalesce_usecs_high;
 			rxcoal->small_pkt_range_start = rx_coalesce_usecs_low;
 			rxcoal->large_pkt_range_start = rx_coalesce_usecs_low +
-- 
2.0.0
