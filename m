From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/7] r8169: remove rtl8169_reinit_task.
Date: Fri, 27 Jan 2012 21:55:52 +0100
Message-ID: <20120127205552.GB24507@electric-eye.fr.zoreil.com>
References: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57425 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab2A0VGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 16:06:47 -0500
Content-Disposition: inline
In-Reply-To: <20120127205412.GA24152@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see no good reason to keep both rtl8169_reinit_task and rtl8169_reset_task:
- rtl8169_reinit_task adds a software failure point which does relate to
  any hardware state
- they handle hardware the same. Remember that rtl8169_reinit_task was
  introduced in the 8169 only era to handle PCI errors way before the 8168
  asked for pll and firmware ops and compare :

      rtl8169_reinit_task     |    rtl8169_reset_task
  ----------------------------+--------------------------
  rtl8169_wait_for_quiescence | rtl8169_hw_reset
  rtl8169_update_counters     | rtl8169_wait_for_quiescence
  rtl8169_hw_reset            | rtl_hw_start
  rtl8169_rx_missed           | rtl8169_check_link_status
  rtl_pll_power_down          |
  rtl_request_firmware        |
  rtl8169_init_phy            |
  rtl_pll_power_up            |
  rtl_hw_start                |
  rtl8169_check_link_status   |

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   34 +++-------------------------------
 1 files changed, 3 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ca86e67..4f0856b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5353,34 +5353,6 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	napi_enable(&tp->napi);
 }
 
-static void rtl8169_reinit_task(struct work_struct *work)
-{
-	struct rtl8169_private *tp =
-		container_of(work, struct rtl8169_private, task.work);
-	struct net_device *dev = tp->dev;
-	int ret;
-
-	rtnl_lock();
-
-	if (!netif_running(dev))
-		goto out_unlock;
-
-	rtl8169_wait_for_quiescence(dev);
-	rtl8169_close(dev);
-
-	ret = rtl8169_open(dev);
-	if (unlikely(ret < 0)) {
-		if (net_ratelimit())
-			netif_err(tp, drv, dev,
-				  "reinit failure (status = %d). Rescheduling\n",
-				  ret);
-		rtl8169_schedule_work(dev, rtl8169_reinit_task);
-	}
-
-out_unlock:
-	rtnl_unlock();
-}
-
 static void rtl8169_reset_task(struct work_struct *work)
 {
 	struct rtl8169_private *tp =
@@ -5616,7 +5588,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	rtl8169_hw_reset(tp);
 
-	rtl8169_schedule_work(dev, rtl8169_reinit_task);
+	rtl8169_schedule_work(dev, rtl8169_reset_task);
 }
 
 static void rtl8169_tx_interrupt(struct net_device *dev,
@@ -5923,8 +5895,8 @@ static void rtl8169_down(struct net_device *dev)
 	rtl8169_hw_reset(tp);
 	/*
 	 * At this point device interrupts can not be enabled in any function,
-	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task,
-	 * rtl8169_reinit_task) and napi is disabled (rtl8169_poll).
+	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task)
+	 * and napi is disabled (rtl8169_poll).
 	 */
 	rtl8169_rx_missed(dev, ioaddr);
 
-- 
1.7.6.5
