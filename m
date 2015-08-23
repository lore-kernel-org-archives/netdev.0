From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169: Keep writting on ChipCmd reg. close
Date: Sun, 23 Aug 2015 12:41:14 +0300
Message-ID: <1440322874-14980-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33070 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbHWJl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 05:41:27 -0400
Received: by wijp15 with SMTP id p15so52136733wij.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 02:41:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep writting on ChipCmd register close and execute before 
 writting on any decriptors.On close the interface same rule.


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b0f7ed2..2ee8bca 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6616,7 +6616,7 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 	RTL_W16(IntrMitigate, 0x0000);
 
-	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
+	//RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
 	rtl_set_rx_mode(dev);
 
@@ -7563,7 +7563,7 @@ static void rtl8169_down(struct net_device *dev)
 	napi_disable(&tp->napi);
 	netif_stop_queue(dev);
 
-	rtl8169_hw_reset(tp);
+	//rtl8169_hw_reset(tp);
 	/*
 	 * At this point device interrupts can not be enabled in any function,
 	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task)
@@ -7585,12 +7585,15 @@ static int rtl8169_close(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
+	void __iomem *ioaddr = tp->mmio_addr;
 
 	pm_runtime_get_sync(&pdev->dev);
 
 	/* Update counters before going down */
 	rtl8169_update_counters(dev);
 	rtl8169_irq_mask_and_ack(tp);
+	rtl_hw_reset(tp);
+	RTL_W8(ChipCmd, ~(CmdTxEnb | CmdRxEnb));
 
 	rtl_lock_work(tp);
 	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
@@ -7646,6 +7649,8 @@ static int rtl_open(struct net_device *dev)
 	if (!tp->RxDescArray)
 		goto err_free_tx_0;
 
+	rtl_hw_reset(tp);
+	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);	
 	rtl8169_set_feat_part2(dev, dev->features);
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
-- 
2.1.4
