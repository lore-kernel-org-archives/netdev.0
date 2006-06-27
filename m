From: Brent Cook <bcook@bpointsys.com>
Subject: [PATCH 1/3] mv643xx fixes - Disable interrupts on all ports during initialization
Date: Tue, 27 Jun 2006 09:51:58 -0500
Message-ID: <200606270951.59024.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:8725 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1030207AbWF0Ovp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:51:45 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch disable interrupts on all ports during initialization. The current 
assumes that the firmware has already disabled all interrupts on all ports. 
We have encountered some boards that do not always disable interrupts (XES 
XPedite 6200 for instance) on a soft reset. This patch prevents a kernel 
panic if a packet is received before the DMA ring buffers are setup for a 
port on which interrupts are left enabled by the firmware.

Signed-off-by: Brent Cook <bcook@bpointsys.com>

Index: linux-2.6-bps/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6-bps/drivers/net/mv643xx_eth.c	(revision 100)
+++ linux-2.6-bps/drivers/net/mv643xx_eth.c	(revision 101)
@@ -777,6 +777,13 @@
 	unsigned int size;
 	int err;
 
+	/* Mask all interrupts on ethernet port */
+	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+		 ETH_INT_MASK_ALL);
+	/* wait for previous write to complete */
+	mv_read(MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
