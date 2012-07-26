From: Andy Cress <andycress@gmail.com>
Subject: [PATCH 2/3] pch_gbe: add extra clean tx
Date: Thu, 26 Jul 2012 12:00:11 -0400
Message-ID: <20120726160011.GC10287@telcoserv5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:63147 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab2GZP6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 11:58:38 -0400
Received: by vcbfk26 with SMTP id fk26so1808795vcb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 08:58:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adds extra cleaning to the pch_gbe_clean_tx routine to avoid 
transmit timeouts on some BCM PHYs that have different timing.
Also update the DRV_VERSION to 1.01, and show it.

Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 8694704..000ef68 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -26,7 +26,7 @@
 #include <linux/ptp_classify.h>
 #endif
 
-#define DRV_VERSION     "1.00"
+#define DRV_VERSION     "1.01"
 const char pch_driver_version[] = DRV_VERSION;
 
 #define PCI_DEVICE_ID_INTEL_IOH1_GBE	0x8802		/* Pci device ID */
@@ -1579,7 +1579,8 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int cleaned_count = 0;
-	bool cleaned = true;
+	bool cleaned = false;
+	int unused, thresh;
 
 	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
 
@@ -1588,10 +1589,36 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	pr_debug("gbec_status:0x%04x  dma_status:0x%04x\n",
 		 tx_desc->gbec_status, tx_desc->dma_status);
 
+	unused = PCH_GBE_DESC_UNUSED(tx_ring);
+	thresh = tx_ring->count - PCH_GBE_TX_WEIGHT;
+	if ((tx_desc->gbec_status == DSC_INIT16) && (unused < thresh))
+	{  /* current marked clean, tx queue filling up, do extra clean */
+		int j, k;
+		if (unused < 8) {  /* tx queue nearly full */
+			pr_debug("clean_tx: transmit queue warning (%x,%x) unused=%d\n",
+				tx_ring->next_to_clean,tx_ring->next_to_use,unused);
+		}
+	   
+		/* current marked clean, scan for more that need cleaning. */
+		k = i;
+		for (j = 0; j < PCH_GBE_TX_WEIGHT; j++) 
+		{
+			tx_desc = PCH_GBE_TX_DESC(*tx_ring, k);
+			if (tx_desc->gbec_status != DSC_INIT16) break; /*found*/
+			if (++k >= tx_ring->count) k = 0;  /*increment, wrap*/
+		}
+		if (j < PCH_GBE_TX_WEIGHT) {
+			pr_debug("clean_tx: unused=%d loops=%d found tx_desc[%x,%x:%x].gbec_status=%04x\n",
+				unused,j, i,k, tx_ring->next_to_use, tx_desc->gbec_status);
+			i = k;  /*found one to clean, usu gbec_status==2000.*/
+		}
+	}
+
 	while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
 		pr_debug("gbec_status:0x%04x\n", tx_desc->gbec_status);
 		buffer_info = &tx_ring->buffer_info[i];
 		skb = buffer_info->skb;
+		cleaned = true;
 
 		if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_ABT)) {
 			adapter->stats.tx_aborted_errors++;
@@ -1639,18 +1666,21 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	}
 	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %d count\n",
 		 cleaned_count);
-	/* Recover from running out of Tx resources in xmit_frame */
-	spin_lock(&tx_ring->tx_lock);
-	if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
-		netif_wake_queue(adapter->netdev);
-		adapter->stats.tx_restart_count++;
-		pr_debug("Tx wake queue\n");
-	}
+	if (cleaned_count > 0)  { /*skip this if nothing cleaned*/
+		/* Recover from running out of Tx resources in xmit_frame */
+		spin_lock(&tx_ring->tx_lock);
+		if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev))))
+		{
+			netif_wake_queue(adapter->netdev);
+			adapter->stats.tx_restart_count++;
+			pr_debug("Tx wake queue\n");
+		}
 
-	tx_ring->next_to_clean = i;
+		tx_ring->next_to_clean = i;
 
-	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
-	spin_unlock(&tx_ring->tx_lock);
+		pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
+		spin_unlock(&tx_ring->tx_lock);
+	}
 	return cleaned;
 }
 
@@ -2387,7 +2417,7 @@ static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
 	pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
 	cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
 
-	if (!cleaned)
+	if (cleaned)
 		work_done = budget;
 	/* If no Tx and not enough Rx work done,
 	 * exit the polling mode
@@ -2793,6 +2823,7 @@ static int __init pch_gbe_init_module(void)
 {
 	int ret;
 
+	pr_info("EG20T PCH Gigabit Ethernet Driver - version %s\n",DRV_VERSION);
 	ret = pci_register_driver(&pch_gbe_driver);
 	if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
 		if (copybreak == 0) {
