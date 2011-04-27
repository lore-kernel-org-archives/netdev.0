From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH rfc 4/5] r8169: remove non-NAPI context invocation of rtl8169_rx_interrupt.
Date: Wed, 27 Apr 2011 22:37:16 +0200
Message-ID: <20110427203716.GG19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39974 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760001Ab1D0Up4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:45:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Invocation of rtl8169_rx_interrupt from rtl8169_reset_task was originally
intended to retrieve as much packets as possible from the rx ring when a
reset was needed. Nowadays rtl8169_reset_task is only scheduled, with
some delay
a. from the tx timeout watchdog
b. when resuming
c. from rtl8169_rx_interrupt itself (no-brainer).

It's dubious that the loss of outdated packets will matter much for a)
and b).

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   32 +++++++++-----------------------
 1 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9acfd65..2606a20 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4585,6 +4585,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 	struct rtl8169_private *tp =
 		container_of(work, struct rtl8169_private, task.work);
 	struct net_device *dev = tp->dev;
+	int i;
 
 	rtnl_lock();
 
@@ -4593,19 +4594,15 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_wait_for_quiescence(dev);
 
-	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
+	for (i = 0; i < NUM_RX_DESC; i++)
+		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
+
 	rtl8169_tx_clear(tp);
 
-	if (tp->dirty_rx == tp->cur_rx) {
-		rtl8169_init_ring_indexes(tp);
-		rtl_hw_start(dev);
-		netif_wake_queue(dev);
-		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
-	} else {
-		if (net_ratelimit())
-			netif_emerg(tp, intr, dev, "Rx buffers shortage\n");
-		rtl8169_schedule_work(dev, rtl8169_reset_task);
-	}
+	rtl8169_init_ring_indexes(tp);
+	rtl_hw_start(dev);
+	netif_wake_queue(dev);
+	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 
 out_unlock:
 	rtnl_unlock();
@@ -4910,20 +4907,12 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 	return skb;
 }
 
-/*
- * Warning : rtl8169_rx_interrupt() might be called :
- * 1) from NAPI (softirq) context
- *	(polling = 1 : we should call netif_receive_skb())
- * 2) from process context (rtl8169_reset_task())
- *	(polling = 0 : we must call netif_rx() instead)
- */
 static int rtl8169_rx_interrupt(struct net_device *dev,
 				struct rtl8169_private *tp,
 				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int count;
-	int polling = (budget != ~(u32)0) ? 1 : 0;
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
@@ -4983,10 +4972,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			rtl8169_rx_vlan_tag(desc, skb);
 
-			if (likely(polling))
-				napi_gro_receive(&tp->napi, skb);
-			else
-				netif_rx(skb);
+			napi_gro_receive(&tp->napi, skb);
 
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
-- 
1.7.4.4

