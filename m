From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH] ks8842: Support 100Mbps when accessed via timberdale
Date: Sun, 25 Jul 2010 22:55:27 +0200
Message-ID: <1280091327.17191.8.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b12.telenor.se ([62.127.194.21]:55502 "EHLO
	smtprelay-b12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0GYUzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 16:55:31 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-b12.telenor.se (Postfix) with ESMTP id B5B3EE9B1B
	for <netdev@vger.kernel.org>; Sun, 25 Jul 2010 22:55:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the code which disabled 100Mbps advertising when
the ks8842 is accessed via timberdale.

At higher speed it's good to be nice to the internal state machine
in timberdale, by acking interrupts, a write to it's interrupt
ack register (IAR).

The flow control setting is removed from TX and RX control
registers. Full duplex flow control was not enabled in SGCR3,
but we tend to get better performance without flow control.

diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 634dad1..9cbf9af 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -34,7 +34,12 @@
 #define DRV_NAME "ks8842"
 
 /* Timberdale specific Registers */
-#define REG_TIMB_RST	0x1c
+#define REG_TIMB_RST		0x1c
+#define REG_TIMB_FIFO		0x20
+#define REG_TIMB_ISR		0x24
+#define REG_TIMB_IER		0x28
+#define REG_TIMB_IAR		0x2C
+#define REQ_TIMB_DMA_RESUME	0x30
 
 /* KS8842 registers */
 
@@ -256,11 +261,8 @@ static void ks8842_reset_hw(struct ks8842_adapter *adapter)
 	/* Enable QMU Transmit flow control / transmit padding / Transmit CRC */
 	ks8842_write16(adapter, 16, 0x000E, REG_TXCR);
 
-	/* enable the receiver, uni + multi + broadcast + flow ctrl
-		+ crc strip */
-	ks8842_write16(adapter, 16, 0x8 | 0x20 | 0x40 | 0x80 | 0x400,
-		REG_RXCR);
-
+	/* enable the receiver, uni + multi + broadcast + crc strip */
+	ks8842_write16(adapter, 16, 0x8 | 0x20 | 0x40 | 0x80, REG_RXCR);
 	/* TX frame pointer autoincrement */
 	ks8842_write16(adapter, 17, 0x4000, REG_TXFDPR);
 
@@ -276,16 +278,12 @@ static void ks8842_reset_hw(struct ks8842_adapter *adapter)
 	/* enable no excessive collison drop */
 	ks8842_enable_bits(adapter, 32, 1 << 3, REG_SGCR2);
 
-	/* Enable port 1 force flow control / back pressure / transmit / recv */
-	ks8842_write16(adapter, 48, 0x1E07, REG_P1CR2);
+	/* Enable port 1 / back pressure / transmit / recv */
+	ks8842_write16(adapter, 48, 0xE07, REG_P1CR2);
 
 	/* restart port auto-negotiation */
 	ks8842_enable_bits(adapter, 49, 1 << 13, REG_P1CR4);
 
-	if (!(adapter->conf_flags & MICREL_KS884X))
-		/* only advertise 10Mbps */
-		ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
-
 	/* Enable the transmitter */
 	ks8842_enable_tx(adapter);
 
@@ -543,6 +541,10 @@ void ks8842_tasklet(unsigned long arg)
 	/* Ack */
 	ks8842_write16(adapter, 18, isr, REG_ISR);
 
+	if (!(adapter->conf_flags & MICREL_KS884X))
+		/* Ack in the timberdale IP as well */
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_IAR);
+
 	if (!netif_running(netdev))
 		return;
 

