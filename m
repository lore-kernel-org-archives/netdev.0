From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH 3/3] ibm_newemac: MAL support for PowerPC 405EZ
Date: Thu, 4 Sep 2008 11:02:16 -0400
Message-ID: <20080904150216.GD2479@yoda.jdub.homelinux.org>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:64147 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbYIDPC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 11:02:57 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3333278rvb.1
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 08:02:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PowerPC 405EZ SoC has some differences in the interrupt layout and
handling for the MAL.  The SERR, TXDE, and RXDE interrupts are OR'd into
a single interrupt.  Also, due to the possibility for interrupt coalescing,
the TXEOB and RXEOB interrupts require an interrupt bit to be cleared in
the ICINTSTAT SDR.

This sets the proper MAL feature bits for 405EZ boards, and adds a common
shared handler for SERR, TXDE, and RXDE.  This has been adapted from code
originally written by Stefan Roese.

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
---
 drivers/net/ibm_newemac/mal.c |   98 ++++++++++++++++++++++++++++++++--------
 1 files changed, 78 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 10c267b..3cef534 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -28,6 +28,7 @@
 #include <linux/delay.h>
 
 #include "core.h"
+#include <asm/dcr-regs.h>
 
 static int mal_count;
 
@@ -279,6 +280,9 @@ static irqreturn_t mal_txeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_TXEOBISR, r);
 
+	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
+		mtdcri(SDR0, 0x4510, (mfdcri(SDR0, 0x4510) | 0x60000000));
+
 	return IRQ_HANDLED;
 }
 
@@ -293,6 +297,9 @@ static irqreturn_t mal_rxeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_RXEOBISR, r);
 
+	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
+		mtdcri(SDR0, 0x4510, (mfdcri(SDR0, 0x4510) | 0x80000000));
+
 	return IRQ_HANDLED;
 }
 
@@ -336,6 +343,25 @@ static irqreturn_t mal_rxde(int irq, void *dev_instance)
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
+				return (mal_rxde(irq, dev_instance));
+			else
+				return (mal_txde(irq, dev_instance));
+		} else { /* SERR */
+			return (mal_serr(irq, dev_instance));
+		}
+	}
+	return IRQ_HANDLED;
+}
+
 void mal_poll_disable(struct mal_instance *mal, struct mal_commac *commac)
 {
 	/* Spinlock-type semantics: only one caller disable poll at a time */
@@ -542,11 +568,22 @@ static int __devinit mal_probe(struct of_device *ofdev,
 		goto fail;
 	}
 
-	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
-	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
-	mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
-	mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
-	mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
+	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez"))
+		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT | MAL_FTR_COMMON_ERR_INT);
+
+	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
+		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
+		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
+		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
+		mal->txde_irq = mal->rxde_irq = mal->serr_irq;
+	} else {
+		mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
+		mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
+		mal->serr_irq = irq_of_parse_and_map(ofdev->node, 2);
+		mal->txde_irq = irq_of_parse_and_map(ofdev->node, 3);
+		mal->rxde_irq = irq_of_parse_and_map(ofdev->node, 4);
+	}
+
 	if (mal->txeob_irq == NO_IRQ || mal->rxeob_irq == NO_IRQ ||
 	    mal->serr_irq == NO_IRQ || mal->txde_irq == NO_IRQ ||
 	    mal->rxde_irq == NO_IRQ) {
@@ -608,21 +645,42 @@ static int __devinit mal_probe(struct of_device *ofdev,
 			     sizeof(struct mal_descriptor) *
 			     mal_rx_bd_offset(mal, i));
 
-	err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
-	if (err)
-		goto fail2;
-	err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
-	if (err)
-		goto fail3;
-	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
-	if (err)
-		goto fail4;
-	err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
-	if (err)
-		goto fail5;
-	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
-	if (err)
-		goto fail6;
+	if (mal_has_feature(mal, MAL_FTR_COMMON_ERR_INT)) {
+		err = request_irq(mal->serr_irq, mal_int, IRQF_SHARED,
+				"MAL SERR", mal);
+		if (err)
+			goto fail2;
+		err = request_irq(mal->txde_irq, mal_int, IRQF_SHARED,
+				"MAL TX DE", mal);
+		if (err)
+			goto fail3;
+		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
+		if (err)
+			goto fail4;
+		err = request_irq(mal->rxde_irq, mal_int, IRQF_SHARED,
+				"MAL RX DE", mal);
+		if (err)
+			goto fail5;
+		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
+		if (err)
+			goto fail6;
+	} else {
+		err = request_irq(mal->serr_irq, mal_serr, 0, "MAL SERR", mal);
+		if (err)
+			goto fail2;
+		err = request_irq(mal->txde_irq, mal_txde, 0, "MAL TX DE", mal);
+		if (err)
+			goto fail3;
+		err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
+		if (err)
+			goto fail4;
+		err = request_irq(mal->rxde_irq, mal_rxde, 0, "MAL RX DE", mal);
+		if (err)
+			goto fail5;
+		err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
+		if (err)
+			goto fail6;
+	}
 
 	/* Enable all MAL SERR interrupt sources */
 	if (mal->version == 2)
-- 
1.5.5.1
