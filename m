From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169: Deny functions membet of array rtl_work
Date: Sat, 29 Aug 2015 13:43:49 +0300
Message-ID: <1440845029-3079-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35893 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbH2KoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 06:44:01 -0400
Received: by wicfv10 with SMTP id fv10so25474956wic.1
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 03:44:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deny functions member of array rtl_work to run when link  is
 ok.After rtl8169_init_phy exist 10 sec  timeout.On many  cases link is ok and
 no need to destroy all work.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2d712a4..fc2fe38 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4377,17 +4377,17 @@ static void rtl_phy_work(struct rtl8169_private *tp)
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
 
+	if (tp->link_ok(ioaddr))
+		return;
+
 	if (tp->phy_reset_pending(tp)) {
 		/*
 		 * A busy loop could burn quite a few cycles on nowadays CPU.
 		 * Let's delay the execution of the timer for a few ticks.
 		 */
-		timeout = HZ/10;
 		goto out_mod_timer;
 	}
 
-	if (tp->link_ok(ioaddr))
-		return;
 
 	netif_dbg(tp, link, tp->dev, "PHY reset until link up\n");
 
@@ -6890,8 +6890,12 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 static void rtl_reset_work(struct rtl8169_private *tp)
 {
 	struct net_device *dev = tp->dev;
+	void __iomem *ioaddr = tp->mmio_addr;
 	int i;
 
+	if (tp->link_ok(ioaddr))
+		return;
+
 	napi_disable(&tp->napi);
 	netif_stop_queue(dev);
 	synchronize_sched();
-- 
2.1.4
