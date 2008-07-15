From: Dave Jones <davej@redhat.com>
Subject: [3/3] 8139too: Fall back to PIO when MMIO fails.
Date: Tue, 15 Jul 2008 19:54:52 -0400
Message-ID: <200807152354.m6FNsqCd026936@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087AbYGPABZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 20:01:25 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m6G01Onb018276
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01Oj6000653
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from gelk.kernelslacker.org (vpn-12-217.rdu.redhat.com [10.11.12.217])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01Ng7007000
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.2/8.14.2) with ESMTP id m6FNsq58026939
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 19:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.26.noarch/drivers/net/8139too.c~	2008-07-15 18:49:02.000000000 -0400
+++ linux-2.6.26.noarch/drivers/net/8139too.c	2008-07-15 18:53:07.000000000 -0400
@@ -784,6 +784,7 @@ static int __devinit rtl8139_init_board 
 	DPRINTK("PIO region size == 0x%02X\n", pio_len);
 	DPRINTK("MMIO region size == 0x%02lX\n", mmio_len);
 
+retry:
 	if (use_io) {
 		/* make sure PCI base addr 0 is PIO */
 		if (!(pio_flags & IORESOURCE_IO)) {
@@ -832,9 +833,10 @@ static int __devinit rtl8139_init_board 
 		/* ioremap MMIO region */
 		ioaddr = pci_iomap(pdev, 1, 0);
 		if (ioaddr == NULL) {
-			dev_err(&pdev->dev, "cannot remap MMIO, aborting\n");
-			rc = -EIO;
-			goto err_out;
+			dev_err(&pdev->dev, "cannot remap MMIO, trying PIO\n");
+			pci_release_regions(pdev);
+			use_io = 1;
+			goto retry;
 		}
 		dev->base_addr = (long) ioaddr;
 		tp->regs_len = mmio_len;
