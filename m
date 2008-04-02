From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH 5/5] m68knommu: dont allocate unused interrupts
Date: Wed, 02 Apr 2008 22:58:29 +0200
Message-ID: <20080402210104.745627947@linutronix.de>
References: <20080402204417.597098190@linutronix.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org,
	Sebastian Siewior <sebastian@linutronix.de>
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58659 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756722AbYDBU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:58:34 -0400
Content-Disposition: inline; filename=m69knommu-fec_register_only_used_irqs.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After fixing (hopefully) fixing locking I run into this:
|irq 88: nobody cared (try booting with the "irqpoll" option)
|Stack from 00214b74:
|        00214b88 00047940 00179b88 00046c36 00179b88 00214bc8 00047b20 00000058
|        00179b88 00000000 00000058 00179bb8 002cdf40 001415ba 00242000 0014163e
|        00179b88 00046c36 0014163e 000479a6 00179b88 00214bfc 00046da8 00000058
|        00179b88 00000000 00000000 00241c00 00247484 40001000 002473e0 002cf080
|        00247000 002334ac 00214c0c 00020a56 00000058 002cf088 00214c58 000238a6
|        00000058 00214c1c ffff9c00 002cf088 00241c00 00247484 40001000 00214000
|Call Trace:
| [00047940] __report_bad_irq+0x32/0x98
| [00047b20] note_interrupt+0x17a/0x28e
| [00046da8] __do_IRQ+0xe4/0x13a
| [00020a56] do_IRQ+0x26/0x3c
| [000238a6] inthandler+0x6a/0x74
| [000c7da0] fec_enet_start_xmit+0xc0/0x154
| [000ef11e] dev_hard_start_xmit+0x152/0x268
| [000fcba4] __qdisc_run+0x158/0x1e0
| [000f1cb6] dev_queue_xmit+0x218/0x2de
| [0010a284] ip_finish_output+0xe8/0x2c4
| [0010a508] ip_output+0x7a/0x86
| [001097bc] ip_push_pending_frames+0x1d4/0x3bc
| [00129d5e] icmp_push_reply+0xda/0x106
| [00129f40] icmp_reply+0x11c/0x1e4
| [0012a49a] icmp_echo+0x4a/0x50
| [0012a166] icmp_rcv+0x15e/0x174
| [00105e7c] ip_local_deliver+0xac/0x16a
| [001061ae] ip_rcv+0x274/0x4b6
| [000eeb4e] netif_receive_skb+0x166/0x232
| [000f1926] process_backlog+0x74/0x104
| [000f13d4] net_rx_action+0xac/0x188
| [0002e2b0] __do_softirq+0x84/0xae
| [0002e316] do_softirq+0x3c/0x40
| [0002e664] ksoftirqd+0x66/0xf0
| [0003cae2] kthread+0x64/0x80
| [00020ce8] kernel_thread+0x2a/0x3a
|
|handlers:
|[<000c710c>] (fec_enet_interrupt+0x0/0x426)
|Disabling IRQ #88

This is because we register & enable way more interrupt sources than we
actually handle. FEC_ENET_RXF (packet received), FEC_ENET_TXF (packet
trasmitted) and FEC_ENET_MII (mii command done) are handled by the ISR.
In my case FEC_ENET_RXB caused this because it was not handled, registered and
rarely the only flag in the status reg. Registering an interrupt source without
enabling it is also pointless.
This patch removes them all except the three that are handled by the isr.

Signed-off-by: Sebastian Siewior <sebastian@linutronix.de>
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1257,12 +1257,15 @@ static void fec_request_intrs(struct net
 		unsigned short irq;
 		irq_handler_t handler;
 	} *idp, id[] = {
-		{
-		"fec(RX)", 86, fec_enet_interrupt}, {
-		"fec(TX)", 87, fec_enet_interrupt}, {
-		"fec(OTHER)", 88, fec_enet_interrupt}, {
-		"fec(MII)", 66, mii_link_interrupt}, {
-	NULL},};
+		/*
+		 * Available but not allocated because not handled:
+		 * fec(OTHER) 88
+		 */
+		{ "fec(RX)", 86, fec_enet_interrupt},
+		{ "fec(TX)", 87, fec_enet_interrupt},
+		{ "fec(MII)", 66, mii_link_interrupt},
+		{ NULL, 0 },
+	};
 
 	/* Setup interrupt handlers. */
 	for (idp = id; idp->name; idp++) {
@@ -1381,21 +1384,17 @@ static void fec_request_intrs(struct net
 		char *name;
 		unsigned short irq;
 	} *idp, id[] = {
-		{
-		"fec(TXF)", 23}, {
-		"fec(TXB)", 24}, {
-		"fec(TXFIFO)", 25}, {
-		"fec(TXCR)", 26}, {
-		"fec(RXF)", 27}, {
-		"fec(RXB)", 28}, {
-		"fec(MII)", 29}, {
-		"fec(LC)", 30}, {
-		"fec(HBERR)", 31}, {
-		"fec(GRA)", 32}, {
-		"fec(EBERR)", 33}, {
-		"fec(BABT)", 34}, {
-		"fec(BABR)", 35}, {
-	NULL},};
+		/*
+		 * Available but not allocated because not handled:
+		 * fec(TXB) 24, fec(TXFIFO) 25, fec(TXCR) 26, fec(RXB) 28,
+		 * fec(LC) 30, fec(HBERR) 31, fec(GRA) 32, fec(EBERR) 33,
+		 * fec(BABT) 34, fec(BABR), 35
+		 */
+		{ "fec(TXF)", 23},
+		{ "fec(RXF)", 27},
+		{ "fec(MII)", 29},
+		{ NULL, 0},
+	};
 
 	fep = netdev_priv(dev);
 	b = (fep->index) ? 128 : 64;
@@ -1559,21 +1558,17 @@ static void fec_request_intrs(struct net
 		char *name;
 		unsigned short irq;
 	} *idp, id[] = {
-		{
-		"fec(TXF)", 23}, {
-		"fec(TXB)", 24}, {
-		"fec(TXFIFO)", 25}, {
-		"fec(TXCR)", 26}, {
-		"fec(RXF)", 27}, {
-		"fec(RXB)", 28}, {
-		"fec(MII)", 29}, {
-		"fec(LC)", 30}, {
-		"fec(HBERR)", 31}, {
-		"fec(GRA)", 32}, {
-		"fec(EBERR)", 33}, {
-		"fec(BABT)", 34}, {
-		"fec(BABR)", 35}, {
-	NULL},};
+		/*
+		 * Available but not allocated because not handled:
+		 * fec(TXB) 24, fec(TXFIFO) 25, fec(TXCR) 26, fec(RXB) 28,
+		 * fec(LC) 30, fec(HBERR) 31, fec(GRA) 32, fec(EBERR) 33,
+		 * fec(BABT) 34, fec(BABR) 35
+		 */
+		{ "fec(TXF)", 23},
+		{ "fec(RXF)", 27},
+		{ "fec(MII)", 29},
+		{ NULL, 0},
+	};
 
 	fep = netdev_priv(dev);
 	b = 64 + 13;
@@ -1693,21 +1688,17 @@ static void fec_request_intrs(struct net
 		char *name;
 		unsigned short irq;
 	} *idp, id[] = {
-		{
-		"fec(TXF)", 36}, {
-		"fec(TXB)", 37}, {
-		"fec(TXFIFO)", 38}, {
-		"fec(TXCR)", 39}, {
-		"fec(RXF)", 40}, {
-		"fec(RXB)", 41}, {
-		"fec(MII)", 42}, {
-		"fec(LC)", 43}, {
-		"fec(HBERR)", 44}, {
-		"fec(GRA)", 45}, {
-		"fec(EBERR)", 46}, {
-		"fec(BABT)", 47}, {
-		"fec(BABR)", 48}, {
-	NULL},};
+		/*
+		 * Available but not allocated because not handled:
+		 * fec(TXB) 37, fec(TXFIFO) 38, fec(TXCR) 39, fec(RXB) 41,
+		 * fec(LC) 43, fec(HBERR) 44, fec(GRA) 45, fec(EBERR) 46,
+		 * fec(BABT) 47, fec(BABR) 48
+		 */
+		{ "fec(TXF)", 36},
+		{ "fec(RXF)", 40},
+		{ "fec(MII)", 42},
+		{ NULL, 0},
+	};
 
 	fep = netdev_priv(dev);
 	b = (fep->index) ? 128 : 64;
@@ -2503,8 +2494,7 @@ int __init fec_enet_init(struct net_devi
 
 	/* Clear and enable interrupts */
 	fecp->fec_ievent = 0xffc00000;
-	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_TXB |
-			   FEC_ENET_RXF | FEC_ENET_RXB | FEC_ENET_MII);
+	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
 
 	/* Queue up command to detect the PHY and initialize the
 	 * remainder of the interface.
@@ -2630,8 +2620,7 @@ static void fec_restart(struct net_devic
 
 	/* Enable interrupts we wish to service.
 	 */
-	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_TXB |
-			   FEC_ENET_RXF | FEC_ENET_RXB | FEC_ENET_MII);
+	fecp->fec_imask = (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII);
 }
 
 static void fec_stop(struct net_device *dev)

-- 

