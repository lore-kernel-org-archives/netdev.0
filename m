From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net patch 1/2] bnx2x: Move netif_napi_add to the open call
Date: Mon, 27 Aug 2012 16:26:19 +0300
Message-ID: <1346073980-30901-2-git-send-email-meravs@broadcom.com>
References: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2679 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627Ab2H0KS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 06:18:26 -0400
In-Reply-To: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move netif_napi_add for all queues from the probe call to the open call, to
avoid the case that napi objects are added for queues that may eventually not
be initialized and activated. With the former behavior, the driver could crash
when netpoll was calling ndo_poll_controller.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         |    3 ---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |    4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |    4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |    2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    |   10 ++++------
 5 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 77bcd4c..a462cbc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1708,9 +1708,6 @@ struct bnx2x_func_init_params {
 			continue;		\
 		else

-#define for_each_napi_rx_queue(bp, var) \
-	for ((var) = 0; (var) < bp->num_napi_queues; (var)++)
-
 /* Skip OOO FP */
 #define for_each_tx_queue(bp, var) \
 	for ((var) = 0; (var) < BNX2X_NUM_QUEUES(bp); (var)++) \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e879e19..af20c6e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2046,6 +2046,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	 */
 	bnx2x_setup_tc(bp->dev, bp->max_cos);

+	/* Add all NAPI objects */
+	bnx2x_add_all_napi(bp);
 	bnx2x_napi_enable(bp);

 	/* set pf load just before approaching the MCP */
@@ -2408,6 +2410,8 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)

 		/* Disable HW interrupts, NAPI */
 		bnx2x_netif_stop(bp, 1);
+		/* Delete all NAPI objects */
+		bnx2x_del_all_napi(bp);

 		/* Release IRQs */
 		bnx2x_free_irq(bp);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index dfa757e..21b5532 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -792,7 +792,7 @@ static inline void bnx2x_add_all_napi(struct bnx2x *bp)
 	bp->num_napi_queues = bp->num_queues;

 	/* Add NAPI objects */
-	for_each_napi_rx_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
 			       bnx2x_poll, BNX2X_NAPI_WEIGHT);
 }
@@ -801,7 +801,7 @@ static inline void bnx2x_del_all_napi(struct bnx2x *bp)
 {
 	int i;

-	for_each_napi_rx_queue(bp, i)
+	for_each_rx_queue(bp, i)
 		netif_napi_del(&bnx2x_fp(bp, i, napi));
 }

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index fc4e0e3..c37a68d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2888,11 +2888,9 @@ static void bnx2x_get_channels(struct net_device *dev,
  */
 static void bnx2x_change_num_queues(struct bnx2x *bp, int num_rss)
 {
-	bnx2x_del_all_napi(bp);
 	bnx2x_disable_msi(bp);
 	BNX2X_NUM_QUEUES(bp) = num_rss + NON_ETH_CONTEXT_USE;
 	bnx2x_set_int_mode(bp);
-	bnx2x_add_all_napi(bp);
 }

 /**
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index dd451c3..f6d6baf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8441,6 +8441,8 @@ unload_error:

 	/* Disable HW interrupts, NAPI */
 	bnx2x_netif_stop(bp, 1);
+	/* Delete all NAPI objects */
+	bnx2x_del_all_napi(bp);

 	/* Release IRQs */
 	bnx2x_free_irq(bp);
@@ -11915,9 +11917,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	 */
 	bnx2x_set_int_mode(bp);

-	/* Add all NAPI objects */
-	bnx2x_add_all_napi(bp);
-
 	rc = register_netdev(dev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
@@ -11992,9 +11991,6 @@ static void __devexit bnx2x_remove_one(struct pci_dev *pdev)

 	unregister_netdev(dev);

-	/* Delete all NAPI objects */
-	bnx2x_del_all_napi(bp);
-
 	/* Power on: we can't let PCI layer write to us while we are in D3 */
 	bnx2x_set_power_state(bp, PCI_D0);

@@ -12041,6 +12037,8 @@ static int bnx2x_eeh_nic_unload(struct bnx2x *bp)
 	bnx2x_tx_disable(bp);

 	bnx2x_netif_stop(bp, 0);
+	/* Delete all NAPI objects */
+	bnx2x_del_all_napi(bp);

 	del_timer_sync(&bp->timer);

--
1.7.10
