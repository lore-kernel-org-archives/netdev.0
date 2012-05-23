From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NETDEV WATCHDOG: %s (%s): transmit queue %u timed out
Date: Thu, 24 May 2012 00:32:10 +0200
Message-ID: <20120523223210.GA20536@electric-eye.fr.zoreil.com>
References: <20120523012640.GB15255@redhat.com> <20120523015312.14731.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Cc: davej@redhat.com, kernel-team@fedoraproject.org,
	netdev@vger.kernel.org
To: George Spelvin <linux@horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39249 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab2EWWkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 18:40:01 -0400
Content-Disposition: inline
In-Reply-To: <20120523015312.14731.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

George Spelvin <linux@horizon.com> :
[...]
> Unfortunately, the last reboot was on Feb. 26, and the kernel logs don't
> go back that far, so I'm not sure if 3.3-rc5 reported this priblem or not.

You may try the attached patches on top of current -git. A complete dmesg
will be welcome. So will an 'ethtool -d eth0' if the device stops working.

You did not label the problem as a serious one. Does it means that the
driver automatically recovers ?

I'll add some ring and registers debug stuff tomorrow.

-- 
Ueimor

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-avoid-clearing-the-end-of-Tx-descriptor-ring-m.patch"

>From 4fafb314defc9e0cc5da1b58e84bba87686ea2ba Mon Sep 17 00:00:00 2001
Message-Id: <4fafb314defc9e0cc5da1b58e84bba87686ea2ba.1337810811.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 23 May 2012 22:18:35 +0200
Subject: [PATCH 1/2] r8169: avoid clearing the end of Tx descriptor ring
 marker bit.
X-Organisation: Land of Sunshine Inc.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 00b4f56..01f3367 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5345,7 +5345,7 @@ static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
 
 	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
 
-	desc->opts1 = 0x00;
+	desc->opts1 &= cpu_to_le32(RingEnd);
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;
-- 
1.7.7.6


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-r8169-TxPoll-hack-rework.patch"

>From 4cadfce6ba362b5d8d5c193c4896443be575b2b4 Mon Sep 17 00:00:00 2001
Message-Id: <4cadfce6ba362b5d8d5c193c4896443be575b2b4.1337810811.git.romieu@fr.zoreil.com>
In-Reply-To: <4fafb314defc9e0cc5da1b58e84bba87686ea2ba.1337810811.git.romieu@fr.zoreil.com>
References: <4fafb314defc9e0cc5da1b58e84bba87686ea2ba.1337810811.git.romieu@fr.zoreil.com>
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 23 May 2012 23:21:13 +0200
Subject: [PATCH 2/2] r8169: TxPoll hack rework.
X-Organisation: Land of Sunshine Inc.

I don't want to try and convince myself that it is completely safe to
issue a TxPoll request from the NAPI handler right in the middle of
a start_xmit, whence the tx_lock.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   59 +++++++++++++++++++--------------
 1 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 01f3367..655b293 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5544,19 +5544,20 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
+	smp_wmb();
+
 	tp->cur_tx += frags + 1;
 
-	wmb();
+	smp_wmb();
 
 	RTL_W8(TxPoll, NPQ);
 
 	mmiowb();
 
 	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
-		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
-		 * not miss a ring update when it notices a stopped queue.
-		 */
-		smp_wmb();
+		/* rtl_tx thread must not miss a ring update when it notices
+		 * a stopped queue. The TxPoll hack requires the smp_wmb
+		 * above so we can go ahead. */
 		netif_stop_queue(dev);
 		/* Sync with rtl_tx:
 		 * - publish queue status and cur_tx ring index (write barrier)
@@ -5640,22 +5641,36 @@ struct rtl_txc {
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 {
 	struct rtl8169_stats *tx_stats = &tp->tx_stats;
-	unsigned int dirty_tx, tx_left;
+	unsigned int dirty_tx, cur_tx;
 	struct rtl_txc txc = { 0, 0 };
 
 	dirty_tx = tp->dirty_tx;
-	smp_rmb();
-	tx_left = tp->cur_tx - dirty_tx;
-
-	while (tx_left > 0) {
+xmit_race:
+	for (cur_tx = tp->cur_tx; dirty_tx != cur_tx; dirty_tx++) {
 		unsigned int entry = dirty_tx % NUM_TX_DESC;
 		struct ring_info *tx_skb = tp->tx_skb + entry;
 		u32 status;
 
-		rmb();
 		status = le32_to_cpu(tp->TxDescArray[entry].opts1);
-		if (status & DescOwn)
+
+		/* 8168 (only ?) hack: TxPoll requests are lost when the Tx
+		 * packets are too close. Let's kick an extra TxPoll request
+		 * when a burst of start_xmit activity is detected (if it is
+		 * not detected, it is slow enough).
+		 * The NPQ bit is cleared automatically by the chipset.
+		 * The code assumes that the chipset is sane enough to clear
+		 * it at a sensible time.*/
+		if (unlikely(status & DescOwn)) {
+			void __iomem *ioaddr = tp->mmio_addr;
+
+			if (!(RTL_R8(TxPoll) & NPQ)) {
+				netif_tx_lock(dev);
+				RTL_W8(TxPoll, NPQ);
+				netif_tx_unlock(dev);
+				goto done;
+			}
 			break;
+		}
 
 		rtl8169_unmap_tx_skb(&tp->pci_dev->dev, tx_skb,
 				     tp->TxDescArray + entry);
@@ -5667,10 +5682,15 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 			dev_kfree_skb(skb);
 			tx_skb->skb = NULL;
 		}
-		dirty_tx++;
-		tx_left--;
 	}
 
+	/* Rationale: if chipset stopped DMAing, enforce TxPoll write either
+	 * here or in start_xmit. If chipset is still DMAing, this code
+	 * will be run later anyway. */
+	smp_mb();
+	if (cur_tx != tp->cur_tx)
+		goto xmit_race;
+done:
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->packets += txc.packets;
 	tx_stats->bytes += txc.bytes;
@@ -5692,17 +5712,6 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
-		/*
-		 * 8168 hack: TxPoll requests are lost when the Tx packets are
-		 * too close. Let's kick an extra TxPoll request when a burst
-		 * of start_xmit activity is detected (if it is not detected,
-		 * it is slow enough). -- FR
-		 */
-		if (tp->cur_tx != dirty_tx) {
-			void __iomem *ioaddr = tp->mmio_addr;
-
-			RTL_W8(TxPoll, NPQ);
-		}
 	}
 }
 
-- 
1.7.7.6


--opJtzjQTFsWo+cga--
