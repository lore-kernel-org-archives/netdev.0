From: "George Spelvin" <linux@horizon.com>
Subject: v3.5: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: 30 Jul 2012 15:02:36 -0400
Message-ID: <20120730190236.30339.qmail@science.horizon.com>
Cc: linux@horizon.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([71.41.210.146]:13559 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753938Ab2G3TJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 15:09:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This actually isn't new to 3.5, but I figured I'd mention it again
anyway.  The machine serves firewalll duty.  A quad-tulip fast ethernet
card serves the external interfaces and DMZ, while an on-board Realtek
gigabit interface serves the main LAN.  The latter is hitting a transmit
queue timeout.

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev 01)

Soon after startup, the following WARN_ONCE triggers:

r8169 0000:02:00.0: inside: link down
r8169 0000:02:00.0: inside: link down
IPv6: ADDRCONF(NETDEV_UP): inside: link is not ready
r8169 0000:02:00.0: inside: link up
IPv6: ADDRCONF(NETDEV_CHANGE): inside: link becomes ready
net dmz: Setting full-duplex based on MII#1 link partner capability of 45e1
net cable: Setting full-duplex based on MII#1 link partner capability of 41e1
postgres (5652): /proc/5652/oom_adj is deprecated, please use /proc/5652/oom_score_adj instead.
pps pps0: new PPS source serial3 at ID 0
pps pps0: source "/dev/ttyS3" added
pps pps1: new PPS source serial4 at ID 1
pps pps1: source "/dev/ttyS4" added
device cable entered promiscuous mode
device dmz entered promiscuous mode
nf_conntrack: automatic helper assignment is deprecated and it will be removed soon. Use the iptables CT target to attach helpers instead.
ntop[6305]: segfault at 0 ip 00000000f750644b sp 00000000f01fbd50 error 4 in libntop-4.99.3.so[f74bf000+7e000]
device cable left promiscuous mode
device dmz left promiscuous mode
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xe9/0x15c()
Hardware name: MS-7376
NETDEV WATCHDOG: inside (r8169): transmit queue 0 timed out
Pid: 0, comm: swapper/3 Not tainted 3.5.0-00020-g7bd6501 #160
Call Trace:
 <IRQ>  [<ffffffff8131d16e>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff810254bd>] ? warn_slowpath_common+0x71/0x85
 [<ffffffff8131d085>] ? netif_tx_lock+0x7a/0x7a
 [<ffffffff81025535>] ? warn_slowpath_fmt+0x45/0x4a
 [<ffffffff8103ce9c>] ? hrtimer_interrupt+0x100/0x1a4
 [<ffffffff8131d072>] ? netif_tx_lock+0x67/0x7a
 [<ffffffff8131d16e>] ? dev_watchdog+0xe9/0x15c
 [<ffffffff8104e764>] ? clockevents_program_event+0x9a/0xb6
 [<ffffffff8102e9bc>] ? run_timer_softirq+0x17e/0x20b
 [<ffffffff8102a945>] ? __do_softirq+0x80/0x102
 [<ffffffff81411d4c>] ? call_softirq+0x1c/0x30
 [<ffffffff810032f4>] ? do_softirq+0x2c/0x60
 [<ffffffff8102ab78>] ? irq_exit+0x3a/0x91
 [<ffffffff81003141>] ? do_IRQ+0x81/0x97
 [<ffffffff81410367>] ? common_interrupt+0x67/0x67
 <EOI>  [<ffffffff81007d63>] ? default_idle+0x1e/0x32
 [<ffffffff81007e87>] ? amd_e400_idle+0xb7/0xd4
 [<ffffffff81008501>] ? cpu_idle+0x58/0x98
---[ end trace 9ca7e03889ac2abb ]---
r8169 0000:02:00.0: inside: link up
udevd[30490]: starting version 175
UDP: short packet: From 151.60.217.248:59748 27692/73 to 71.41.210.146:43935
r8169 0000:02:00.0: inside: link up

There are a few local patches, but only two are anywhere close to the
network interface, and they are test patches designed to fix this.
Should I get rid of them?

It's a production system, so I don't like to bounce it too often, but I can
test after hours.

One local patch I've thought about writing is something to count
how often this happens (probably in sysfs).

commit 526ef2edd6ffb8f529256a033ca3a266530739d3
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed May 23 22:18:35 2012 +0200

    r8169: avoid clearing the end of Tx descriptor ring marker bit.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d7a04e0..9c35130 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5346,7 +5346,7 @@ static void rtl8169_unmap_tx_skb(struct device *d, struct ring_info *tx_skb,
 
 	dma_unmap_single(d, le64_to_cpu(desc->addr), len, DMA_TO_DEVICE);
 
-	desc->opts1 = 0x00;
+	desc->opts1 &= cpu_to_le32(RingEnd);
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;


commit 7bd6501f52c2c0382b41fe77b9bd003ff768a44c
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed May 23 23:21:13 2012 +0200

    r8169: TxPoll hack rework.
    
    I don't want to try and convince myself that it is completely safe to
    issue a TxPoll request from the NAPI handler right in the middle of
    a start_xmit, whence the tx_lock.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9c35130..be5cd33 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5545,19 +5545,20 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
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
@@ -5641,22 +5642,36 @@ struct rtl_txc {
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
@@ -5668,10 +5683,15 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
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
@@ -5693,17 +5713,6 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
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
 
