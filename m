From: akpm@linux-foundation.org
Subject: [patch 04/10] baycom_ser_fdx: also allow i/o ports >= 0x1000 and enhanced failure logging
Date: Mon, 26 Mar 2007 21:47:23 -0800
Message-ID: <200703270547.l2R5lN9j008260@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	folkert@vanheusden.com, alan@lxorguk.ukuu.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40126 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbXC0Frg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 01:47:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Folkert van Heusden <folkert@vanheusden.com>

The baycom_ser_fdx driver did not allow i/o ports >= 0x1000.  Now that
there are pci cards (with rs232 ports) which use for example 0xb800 this
limit should not exists.

Also, for non kernel coders find the cause of problems was challenging so I
added extra logging.

Signed-off-by: Folkert van Heusden <folkert@vanheusden.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/hamradio/baycom_ser_fdx.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff -puN drivers/net/hamradio/baycom_ser_fdx.c~baycom_ser_fdx-also-allow-i-o-ports-=-0x1000-and-enhanced drivers/net/hamradio/baycom_ser_fdx.c
--- a/drivers/net/hamradio/baycom_ser_fdx.c~baycom_ser_fdx-also-allow-i-o-ports-=-0x1000-and-enhanced
+++ a/drivers/net/hamradio/baycom_ser_fdx.c
@@ -413,11 +413,18 @@ static int ser12_open(struct net_device 
 
 	if (!dev || !bc)
 		return -ENXIO;
-	if (!dev->base_addr || dev->base_addr > 0x1000-SER12_EXTENT ||
-	    dev->irq < 2 || dev->irq > 15)
+	if (!dev->base_addr || dev->base_addr > 0xffff-SER12_EXTENT ||
+	    dev->irq < 2 || dev->irq > NR_IRQS) {
+		printk(KERN_INFO "baycom_ser_fdx: invalid portnumber (max %u) "
+				"or irq (2 <= irq <= %d)\n",
+				0xffff-SER12_EXTENT, NR_IRQS);
 		return -ENXIO;
-	if (bc->baud < 300 || bc->baud > 4800)
+	}
+	if (bc->baud < 300 || bc->baud > 4800) {
+		printk(KERN_INFO "baycom_ser_fdx: invalid baudrate "
+				"(300...4800)\n");
 		return -EINVAL;
+	}
 	if (!request_region(dev->base_addr, SER12_EXTENT, "baycom_ser_fdx")) {
 		printk(KERN_WARNING "BAYCOM_SER_FSX: I/O port 0x%04lx busy \n", 
 		       dev->base_addr);
_
