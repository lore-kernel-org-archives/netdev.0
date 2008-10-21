From: roel kluin <roel.kluin@gmail.com>
Subject: [PATCH] gianfar: fix handle errors returned by platform_get_irq*()
Date: Tue, 21 Oct 2008 01:35:34 -0400
Message-ID: <48FD6A26.9010000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: galak@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:25463 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbYJTXfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 19:35:39 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1054055nfc.21
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 16:35:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

platform_get_irq*() returns on -ENXIO when the resource cannot be
found, but this remains unnoticed if stored in an unsigned.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
since commit 489447380a2921ec0e9154f773c44ab3167ede4b

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b5bb7ae..64b2011 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -161,7 +161,7 @@ static int gfar_probe(struct platform_device *pdev)
 	struct gfar_private *priv = NULL;
 	struct gianfar_platform_data *einfo;
 	struct resource *r;
-	int err = 0;
+	int err = 0, irq;
 	DECLARE_MAC_BUF(mac);
 
 	einfo = (struct gianfar_platform_data *) pdev->dev.platform_data;
@@ -187,15 +187,25 @@ static int gfar_probe(struct platform_device *pdev)
 
 	/* fill out IRQ fields */
 	if (einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
-		priv->interruptTransmit = platform_get_irq_byname(pdev, "tx");
-		priv->interruptReceive = platform_get_irq_byname(pdev, "rx");
-		priv->interruptError = platform_get_irq_byname(pdev, "error");
-		if (priv->interruptTransmit < 0 || priv->interruptReceive < 0 || priv->interruptError < 0)
+		irq = platform_get_irq_byname(pdev, "tx");
+		if (irq < 0)
+			goto regs_fail;
+		priv->interruptTransmit = irq;
+
+		irq = platform_get_irq_byname(pdev, "rx");
+		if (irq < 0)
+			goto regs_fail;
+		priv->interruptReceive = irq;
+
+		irq = platform_get_irq_byname(pdev, "error");
+		if (irq < 0)
 			goto regs_fail;
+		priv->interruptError = irq;
 	} else {
-		priv->interruptTransmit = platform_get_irq(pdev, 0);
-		if (priv->interruptTransmit < 0)
+		irq = platform_get_irq(pdev, 0);
+		if (irq < 0)
 			goto regs_fail;
+		priv->interruptTransmit = irq;
 	}
 
 	/* get a pointer to the register memory */
