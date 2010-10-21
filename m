From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 6/8] r8169: changing mtu clean up
Date: Thu, 21 Oct 2010 10:25:41 +0200
Message-ID: <1287649543-6569-7-git-send-email-sgruszka@redhat.com>
References: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab0JUIXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 04:23:34 -0400
In-Reply-To: <1287649543-6569-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we do not change rx buffer size any longer, we can
clean up rtl8169_change_mtu and in consequence rtl8169_down.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/r8169.c |   47 ++++++-----------------------------------------
 1 files changed, 6 insertions(+), 41 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ef304c5..ad3f37a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3908,31 +3908,11 @@ static void rtl_hw_start_8101(struct net_device *dev)
 
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct rtl8169_private *tp = netdev_priv(dev);
-	int ret = 0;
-
 	if (new_mtu < ETH_ZLEN || new_mtu > SafeMtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
-
-	if (!netif_running(dev))
-		goto out;
-
-	rtl8169_down(dev);
-
-	ret = rtl8169_init_ring(dev);
-	if (ret < 0)
-		goto out;
-
-	napi_enable(&tp->napi);
-
-	rtl_hw_start(dev);
-
-	rtl8169_request_timer(dev);
-
-out:
-	return ret;
+	return 0;
 }
 
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
@@ -4684,7 +4664,6 @@ static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
@@ -4692,11 +4671,14 @@ static void rtl8169_down(struct net_device *dev)
 
 	napi_disable(&tp->napi);
 
-core_down:
 	spin_lock_irq(&tp->lock);
 
 	rtl8169_asic_down(ioaddr);
-
+	/*
+	 * At this point device interrupts can not be enabled in any function,
+	 * as netif_running is not true (rtl8169_interrupt, rtl8169_reset_task,
+	 * rtl8169_reinit_task) and napi is disabled (rtl8169_poll).
+	 */
 	rtl8169_rx_missed(dev, ioaddr);
 
 	spin_unlock_irq(&tp->lock);
@@ -4706,23 +4688,6 @@ core_down:
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 
-	/*
-	 * And now for the 50k$ question: are IRQ disabled or not ?
-	 *
-	 * Two paths lead here:
-	 * 1) dev->close
-	 *    -> netif_running() is available to sync the current code and the
-	 *       IRQ handler. See rtl8169_interrupt for details.
-	 * 2) dev->change_mtu
-	 *    -> rtl8169_poll can not be issued again and re-enable the
-	 *       interruptions. Let's simply issue the IRQ down sequence again.
-	 *
-	 * No loop if hotpluged or major error (0xffff).
-	 */
-	intrmask = RTL_R16(IntrMask);
-	if (intrmask && (intrmask != 0xffff))
-		goto core_down;
-
 	rtl8169_tx_clear(tp);
 
 	rtl8169_rx_clear(tp);
-- 
1.6.5.2

