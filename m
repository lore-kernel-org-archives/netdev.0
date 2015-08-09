From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH] r8169: Filtered data on Rx descriptor status context
Date: Sun,  9 Aug 2015 14:57:29 +0300
Message-ID: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37070 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932919AbbHIL5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 07:57:45 -0400
Received: by wibhh20 with SMTP id hh20so116894700wib.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 04:57:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 We want to start evaluate an RES Receive error summary only 
 when LS (LastFrag) occurred but without FirstFrag


Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8bf8c3f..0ee0107 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7305,12 +7305,15 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 		if (status & DescOwn)
 			break;
 
+		if (!(status & LastFrag))
+			break;
+
 		/* This barrier is needed to keep us from reading
 		 * any other fields out of the Rx descriptor until
 		 * we know the status of DescOwn
 		 */
 		dma_rmb();
-
+               if (!(status & FirstFrag)) {
 		if (unlikely(status & RxRES)) {
 			netif_info(tp, rx_err, dev, "Rx ERROR. status = %08x\n",
 				   status);
@@ -7323,6 +7326,7 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 				dev->stats.rx_fifo_errors++;
 			}
+	       }
 			if ((status & (RxRUNT | RxCRC)) &&
 			    !(status & (RxRWT | RxFOVF)) &&
 			    (dev->features & NETIF_F_RXALL))
-- 
2.1.4
