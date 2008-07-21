From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge: use ioremap_wc
Date: Mon, 21 Jul 2008 10:26:25 +0200
Message-ID: <48844831.9040102@myri.com>
References: <488447E7.2060505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1872 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754962AbYGUI0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 04:26:54 -0400
In-Reply-To: <488447E7.2060505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to ioremap_wc(). We keep the MTRR code since ioremap_wc()
will use UC_MINUS when falling back to uncachable, and thus let
the MTRR WC take precedence.

Also rename the error path better.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-07-21 09:24:21.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-07-21 09:24:33.000000000 +0200
@@ -3720,14 +3720,14 @@
 	if (mgp->sram_size > mgp->board_span) {
 		dev_err(&pdev->dev, "board span %ld bytes too small\n",
 			mgp->board_span);
-		goto abort_with_wc;
+		goto abort_with_mtrr;
 	}
-	mgp->sram = ioremap(mgp->iomem_base, mgp->board_span);
+	mgp->sram = ioremap_wc(mgp->iomem_base, mgp->board_span);
 	if (mgp->sram == NULL) {
 		dev_err(&pdev->dev, "ioremap failed for %ld bytes at 0x%lx\n",
 			mgp->board_span, mgp->iomem_base);
 		status = -ENXIO;
-		goto abort_with_wc;
+		goto abort_with_mtrr;
 	}
 	memcpy_fromio(mgp->eeprom_strings,
 		      mgp->sram + mgp->sram_size - MYRI10GE_EEPROM_STRINGS_SIZE,
@@ -3828,7 +3828,7 @@
 abort_with_ioremap:
 	iounmap(mgp->sram);
 
-abort_with_wc:
+abort_with_mtrr:
 #ifdef CONFIG_MTRR
 	if (mgp->mtrr >= 0)
 		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);


