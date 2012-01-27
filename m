From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/7] r8169: stop delaying workqueue.
Date: Fri, 27 Jan 2012 21:56:32 +0100
Message-ID: <20120127205632.GC24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57431 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539Ab2A0VH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:07:27 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Though motivated by the move of the driver to a single work queue of
sequential events and removal of hard irq processing, it looks safe as
a standalone change.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   37 ++++++++++++++++++++++------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4f0856b..6d74931 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -714,7 +714,11 @@ struct rtl8169_private {
 	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
 	unsigned int (*link_ok)(void __iomem *);
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
-	struct delayed_work task;
+
+	struct {
+		struct work_struct work;
+	} wk;
+
 	unsigned features;
 
 	struct mii_if_info mii;
@@ -4194,7 +4198,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 		rtl8168_driver_stop(tp);
 	}
 
-	cancel_delayed_work_sync(&tp->task);
+	cancel_work_sync(&tp->wk.work);
 
 	unregister_netdev(dev);
 
@@ -4255,6 +4259,8 @@ static void rtl_request_firmware(struct rtl8169_private *tp)
 		rtl_request_uncached_firmware(tp);
 }
 
+static void rtl_task(struct work_struct *);
+
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -4282,7 +4288,7 @@ static int rtl8169_open(struct net_device *dev)
 	if (retval < 0)
 		goto err_free_rx_1;
 
-	INIT_DELAYED_WORK(&tp->task, NULL);
+	INIT_WORK(&tp->wk.work, rtl_task);
 
 	smp_mb();
 
@@ -5328,12 +5334,11 @@ static void rtl8169_tx_clear(struct rtl8169_private *tp)
 	tp->cur_tx = tp->dirty_tx = 0;
 }
 
-static void rtl8169_schedule_work(struct net_device *dev, work_func_t task)
+static void rtl8169_schedule_work(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	PREPARE_DELAYED_WORK(&tp->task, task);
-	schedule_delayed_work(&tp->task, 4);
+	schedule_work(&tp->wk.work);
 }
 
 static void rtl8169_wait_for_quiescence(struct net_device *dev)
@@ -5353,10 +5358,8 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	napi_enable(&tp->napi);
 }
 
-static void rtl8169_reset_task(struct work_struct *work)
+static void rtl_reset_work(struct rtl8169_private *tp)
 {
-	struct rtl8169_private *tp =
-		container_of(work, struct rtl8169_private, task.work);
 	struct net_device *dev = tp->dev;
 	int i;
 
@@ -5385,7 +5388,7 @@ out_unlock:
 
 static void rtl8169_tx_timeout(struct net_device *dev)
 {
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	rtl8169_schedule_work(dev);
 }
 
 static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
@@ -5588,7 +5591,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	rtl8169_hw_reset(tp);
 
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	rtl8169_schedule_work(dev);
 }
 
 static void rtl8169_tx_interrupt(struct net_device *dev,
@@ -5707,7 +5710,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			if (status & RxCRC)
 				dev->stats.rx_crc_errors++;
 			if (status & RxFOVF) {
-				rtl8169_schedule_work(dev, rtl8169_reset_task);
+				rtl8169_schedule_work(dev);
 				dev->stats.rx_fifo_errors++;
 			}
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
@@ -5840,6 +5843,14 @@ done:
 	return IRQ_RETVAL(handled);
 }
 
+static void rtl_task(struct work_struct *work)
+{
+	struct rtl8169_private *tp =
+		container_of(work, struct rtl8169_private, wk.work);
+
+	rtl_reset_work(tp);
+}
+
 static int rtl8169_poll(struct napi_struct *napi, int budget)
 {
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
@@ -6046,7 +6057,7 @@ static void __rtl8169_resume(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
-	rtl8169_schedule_work(dev, rtl8169_reset_task);
+	rtl8169_schedule_work(dev);
 }
 
 static int rtl8169_resume(struct device *device)
-- 
1.7.6.5
