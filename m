From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH 3/3 v2] ibm_newemac: MAL support for PowerPC 405EZ
Date: Thu, 4 Sep 2008 10:08:20 -0400
Message-ID: <6c8102b136b709af32d5f5ceeb113b1943af29d3.1220877899.git.jwboyer@linux.vnet.ibm.com>
References: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:28221 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbYIHNEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 09:04:42 -0400
Received: by py-out-1112.google.com with SMTP id p76so870772pyb.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 06:04:41 -0700 (PDT)
In-Reply-To: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PowerPC 405EZ SoC has some differences in the interrupt layout and
handling for the MAL.  The SERR, TXDE, and RXDE interrupts are OR'd into
a single interrupt.  Also, due to the possibility for interrupt coalescing,
the TXEOB and RXEOB interrupts require an interrupt bit to be cleared in
the ICINTSTAT SDR.

This sets the proper MAL feature bits for 405EZ boards, and adds a common
shared handler for SERR, TXDE, and RXDE.  The defines for the ICINTSTAT DCR
are added to the proper header file as well.

This has been adapted from code originally written by Stefan Roese.

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/dcr-regs.h |    7 ++++
 drivers/net/ibm_newemac/mal.c       |   60 ++++++++++++++++++++++++++++++++---
 2 files changed, 62 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/include/asm/dcr-regs.h b/arch/powerpc/include/asm/dcr-regs.h
index 29b0ece..7b833ff 100644
--- a/arch/powerpc/include/asm/dcr-regs.h
+++ b/arch/powerpc/include/asm/dcr-regs.h
@@ -68,6 +68,13 @@
 #define SDR0_UART3		0x0123
 #define SDR0_CUST0		0x4000
 
+/* SDR for 405EZ */
+#define DCRN_SDR_ICINTSTAT	0x4510
+#define ICINTSTAT_ICRX	0x80000000
+#define ICINTSTAT_ICTX0	0x40000000
+#define ICINTSTAT_ICTX1 0x20000000
+#define ICINTSTAT_ICTX	0x60000000
+
 /*
  * All those DCR register addresses are offsets from the base address
  * for the SRAM0 controller (e.g. 0x20 on 440GX). The base address is
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 10c267b..1839d3f 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -28,6 +28,7 @@
 #include <linux/delay.h>
 
 #include "core.h"
+#include <asm/dcr-regs.h>
 
 static int mal_count;
 
@@ -279,6 +280,10 @@ static irqreturn_t mal_txeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_TXEOBISR, r);
 
+	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
+		mtdcri(SDR0, DCRN_SDR_ICINTSTAT,
+				(mfdcri(SDR0, DCRN_SDR_ICINTSTAT) | ICINTSTAT_ICTX));
+
 	return IRQ_HANDLED;
 }
 
@@ -293,6 +298,10 @@ static irqreturn_t mal_rxeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_RXEOBISR, r);
 
+	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
+		mtdcri(SDR0, DCRN_SDR_ICINTSTAT,
+				(mfdcri(SDR0, DCRN_SDR_ICINTSTAT) | ICINTSTAT_ICRX));
+
 	return IRQ_HANDLED;
 }
 
@@ -336,6 +345,25 @@ static irqreturn_t mal_rxde(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t mal_int(int irq, void *dev_instance)
+{
+	struct mal_instance *mal = dev_instance;
+	u32 esr = get_mal_dcrn(mal, MAL_ESR);
+
+	if (esr & MAL_ESR_EVB) {
+		/* descriptor error */
+		if (esr & MAL_ESR_DE) {
+			if (esr & MAL_ESR_CIDT)
+				return mal_rxde(irq, dev_instance);
+			else
+				return mal_txde(irq, dev_instance);
+		} else { /* SERR */
+			return mal_serr(irq, dev_instance);
+		}
+	}
+	return IRQ_HANDLED;
+}
+
 void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 {
 	/* Spinlock-type semantics: only one caller disable poll at a time */
@@ -493,6 +521,8 @@ static int __devinit mal_probe(struct of_device *ofdev,
 	unsigned int dcr_base;
 	const u32 *prop;
 	u32 cfg;
+	unsigned long irqflags;
+	irq_handler_t hdlr_serr, hdlr_txde, hdlr_rxde;
 
 	mal = kzalloc(sizeof(struct mal_instance), GFP_KERNEL);
 	if (!mal) {
@@ -542,11 +572,21 @@ static int __devinit mal_probe(struct of_device *ofdev,
 		goto fail;
 	}
 
+	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez"))
+		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT |
+				MAL_FTR_COMMON_ERR_INT);
+
 	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
 	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
 	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
-	mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
-	mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
+
+	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
+		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
+	} else {
+		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
+		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
+	}
+
 	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
 	    mal->serr_irq == NO_IRQ || mal->txde_irq == NO_IRQ ||
 	    mal->rxde_irq == NO_IRQ) {
@@ -608,16 +648,26 @@ static int __devinit mal_probe(struct of_device *ofdev,
 			     sizeof(struct mal_descriptor) *
 			     mal_rx_bd_offset(mal, i));
 
-	err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
+	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
+		irqflags = IRQF_SHARED;
+		hdlr_serr = hdlr_txde = hdlr_rxde = mal_int;
+	} else {
+		irqflags = 0;
+		hdlr_serr = mal_serr;
+		hdlr_txde = mal_txde;
+		hdlr_rxde = mal_rxde;
+	}
+
+	err = request_irq(mal->serr_irq, hdlr_serr, irqflags, "MAL SERR", mal);
 	if (err)
 		goto fail2;
-	err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
+	err = request_irq(mal->txde_irq, hdlr_txde, irqflags, "MAL TX DE", mal);
 	if (err)
 		goto fail3;
 	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
 	if (err)
 		goto fail4;
-	err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
+	err = request_irq(mal->rxde_irq, hdlr_rxde, irqflags, "MAL RX DE", mal);
 	if (err)
 		goto fail5;
 	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
-- 
1.5.5.1

