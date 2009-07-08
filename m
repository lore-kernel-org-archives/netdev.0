From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] r6040: restore MIER register correctly when IRQ line is shared
Date: Wed, 8 Jul 2009 15:05:14 +0200
Message-ID: <200907081505.14846.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steve Holland <sdh4@iastate.edu>,
	Joe Chou <joe.chou@rdc.com.tw>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:55559 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbZGHNFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 09:05:20 -0400
Received: by ewy26 with SMTP id 26so1566788ewy.37
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2009 06:05:18 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the r6040 device IRQ line is shared we will enter the driver
interrupt service routine, mask off the device interrupt enable
register (MIER) and return with IRQ_NONE, we would then leave the
device with interrupts disabled, this patch fixes that issue.

Reported-by: Steve Holland <sdh4@iastate.edu>
Signed-off-by: Joe Chou <joe.chou@rdc.com.tw>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 57c31b8..e532be4 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -704,8 +704,11 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 	/* Read MISR status and clear */
 	status = ioread16(ioaddr + MISR);
 
-	if (status == 0x0000 || status == 0xffff)
+	if (status == 0x0000 || status == 0xffff) {
+		/* Restore RDC MAC interrupt */
+		iowrite16(misr, ioaddr + MIER);
 		return IRQ_NONE;
+	}
 
 	/* RX interrupt request */
 	if (status & RX_INTS) {
