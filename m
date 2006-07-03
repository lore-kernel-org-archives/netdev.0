From: Brent Cook <bcook@bpointsys.com>
Subject: [PATCH 1/3] mv643xx fixes - Disable interrupts on all ports during initialization
Date: Mon, 3 Jul 2006 13:11:54 -0500
Message-ID: <200607031311.54328.bcook@bpointsys.com>
References: <200606270951.59024.bcook@bpointsys.com> <44A54F5B.4030902@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:51731 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S932090AbWGCSL3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 14:11:29 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A54F5B.4030902@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That's the last time I hand-edit a patch - this is really more of a workaround 
since I've learned that the interrupts should have been disabled by the 
firmware anyway. But, it doesn't hurt. Updated description

This patch disable interrupts on all ports during initialization. The
current driver assumes that the firmware has already disabled all interrupts 
on all ports. We have encountered some boards that do not always disable
interrupts (XES XPedite 6200 for instance) on a soft reset on all ethernet 
ports. This patch prevents a kernel panic if a packet is received before the 
DMA ring buffers are setup for a port on which interrupts are left enabled by 
the firmware.

Signed-off-by: Brent Cook <bcook@bpointsys.com>

Index: current/drivers/net/mv643xx_eth.c
===================================================================
--- current/drivers/net/mv643xx_eth.c	(revision 101)
+++ current/drivers/net/mv643xx_eth.c	(working copy)
@@ -777,6 +777,12 @@
 	unsigned int size;
 	int err;
 
+	/* Mask all interrupts on ethernet port */
+	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+		ETH_INT_MASK_ALL);
+	/* wait for previous write to complete */
+	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
