From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 16:47:19 +0200
Message-ID: <20110728144719.GA11465@electric-eye.fr.zoreil.com>
References: <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com> <20110728114305.GA24549@colin.search.kasperd.net> <20110728115936.GC24549@colin.search.kasperd.net> <20110728122328.GA11424@electric-eye.fr.zoreil.com> <20110728124548.GA24762@colin.search.kasperd.net> <20110728125437.GA24876@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60090 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab1G1PDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 11:03:16 -0400
Content-Disposition: inline
In-Reply-To: <20110728125437.GA24876@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
> On 28/07/11 14.45, Kasper Dupont wrote:
> > On 28/07/11 14.23, Francois Romieu wrote:
> > > You can replace them with plain printk(KERN_{INFO/ERR} "S: ...).
> > 
> > Then it compiles, will let you know shortly how it works out.
> 
> The last 24 lines before network stopped working:
[...]
> S: 000000c0
> FEmp
> S: 000000c0
> FEmp
> S: 00000040
> S: 000000c4
> S: 00000044
> S: 00000040

Can you revert the last patch and apply the one below ?

Network traffic capture at the remote end of the link would be welcome,
especially ethernet MAC control frames.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..b79fa86 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -287,6 +287,7 @@ enum rtl_registers {
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
 
+	TimerCount	= 0x48,
 	RxMissed	= 0x4c,
 	Cfg9346		= 0x50,
 	Config0		= 0x51,
@@ -395,6 +396,7 @@ enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
 	PCSTimeout	= 0x4000,
+	RxFIFOEmpty	= 0x0200,	/* 816x something only ? */
 	SWInt		= 0x0100,
 	TxDescUnavail	= 0x0080,
 	RxFIFOOver	= 0x0040,
@@ -5110,8 +5112,9 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	tp->cur_tx += frags + 1;
 
-	wmb();
+	mmiowb();
 
+	RTL_W32(TimerCount, 12500);
 	RTL_W8(TxPoll, NPQ);
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
@@ -5222,15 +5225,6 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
-		/*
-		 * 8168 hack: TxPoll requests are lost when the Tx packets are
-		 * too close. Let's kick an extra TxPoll request when a burst
-		 * of start_xmit activity is detected (if it is not detected,
-		 * it is slow enough). -- FR
-		 */
-		smp_rmb();
-		if (tp->cur_tx != dirty_tx)
-			RTL_W8(TxPoll, NPQ);
 	}
 }
 
@@ -5379,11 +5373,21 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			break;
 		}
 
+		if (unlikely(status & PCSTimeout)) {
+			printk(KERN_INFO "%08lx %08x %08x %08x %08x %08x\n",
+			       jiffies, status, tp->cur_rx, tp->dirty_rx,
+			       tp->cur_tx, tp->dirty_tx);
+			smp_rmb();
+			if (tp->cur_tx != tp->dirty_tx)
+				RTL_W8(TxPoll, NPQ);
+		}
+
 		if (unlikely(status & RxFIFOOver)) {
 			switch (tp->mac_version) {
+				int i;
+
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
@@ -5399,6 +5403,21 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			case RTL_GIGA_MAC_VER_28:
 			case RTL_GIGA_MAC_VER_31:
 			/* Experimental science. Pktgen proof. */
+			case RTL_GIGA_MAC_VER_22:
+				printk(KERN_INFO "%08lx %08x %08x %08x %08x %08x\n",
+				       jiffies, status,
+				       tp->cur_rx, tp->dirty_rx,
+				       tp->cur_tx, tp->dirty_tx);
+				for (i = 0; i < 4000000; i++) {
+					if (RTL_R16(IntrStatus) & RxFIFOEmpty) {
+						RTL_W16(IntrStatus, RxFIFOOver);
+						printk(KERN_INFO "FEmp %d\n", i);
+						break;
+					}
+					udelay(10);
+				}
+				if (i >= 4000000)
+					printk(KERN_ERR "no FEmp\n");
 			case RTL_GIGA_MAC_VER_12:
 			case RTL_GIGA_MAC_VER_25:
 				if (status == RxFIFOOver)
