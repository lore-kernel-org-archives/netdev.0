From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH v2] ks8842: Support 100Mbps when accessed via timberdale
Date: Mon, 26 Jul 2010 10:51:05 +0200
Message-ID: <1280134265.3498.4.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:51075 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab0GZIvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 04:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the code which disables 100Mbps advertising when
the ks8842 is accessed via timberdale.

At higher speed it's good to be nice to the internal state machine
of timberdale by acking interrupts. That is done by a write to the
interrupt ack register (IAR).

Signed-off-by: Richard R=C3=B6jfors <richard.rojfors@pelagicore.com>
---
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 634dad1..289b0be 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -34,7 +34,12 @@
 #define DRV_NAME "ks8842"
=20
 /* Timberdale specific Registers */
-#define REG_TIMB_RST	0x1c
+#define REG_TIMB_RST		0x1c
+#define REG_TIMB_FIFO		0x20
+#define REG_TIMB_ISR		0x24
+#define REG_TIMB_IER		0x28
+#define REG_TIMB_IAR		0x2C
+#define REQ_TIMB_DMA_RESUME	0x30
=20
 /* KS8842 registers */
=20
@@ -282,10 +287,6 @@ static void ks8842_reset_hw(struct ks8842_adapter =
*adapter)
 	/* restart port auto-negotiation */
 	ks8842_enable_bits(adapter, 49, 1 << 13, REG_P1CR4);
=20
-	if (!(adapter->conf_flags & MICREL_KS884X))
-		/* only advertise 10Mbps */
-		ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
-
 	/* Enable the transmitter */
 	ks8842_enable_tx(adapter);
=20
@@ -543,6 +544,10 @@ void ks8842_tasklet(unsigned long arg)
 	/* Ack */
 	ks8842_write16(adapter, 18, isr, REG_ISR);
=20
+	if (!(adapter->conf_flags & MICREL_KS884X))
+		/* Ack in the timberdale IP as well */
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_IAR);
+
 	if (!netif_running(netdev))
 		return;
=20

