From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/5] pcnet32:  remove unnecessary save/restore register accesses.
Date: Wed, 13 Sep 2006 10:15:43 -0700
Message-ID: <20060913171543.GA12746@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:27330 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750797AbWIMRO6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 13:14:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8DHEtnK011520
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 13:14:55 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8DHEtgP259930
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:14:55 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8DHEs4q030590
	for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 11:14:55 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delete unnecessary save/restore of rap in interrupt handler and statistics.

tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.18-rc6/drivers/net/pcnet32.c.orig	Fri Sep  8 14:02:12 2006
+++ linux-2.6.18-rc6/drivers/net/pcnet32.c	Tue Sep 12 10:09:12 2006
@@ -2262,7 +2262,7 @@ pcnet32_interrupt(int irq, void *dev_id,
 	struct net_device *dev = dev_id;
 	struct pcnet32_private *lp;
 	unsigned long ioaddr;
-	u16 csr0, rap;
+	u16 csr0;
 	int boguscnt = max_interrupt_work;
 	int must_restart;
 
@@ -2278,7 +2278,6 @@ pcnet32_interrupt(int irq, void *dev_id,
 
 	spin_lock(&lp->lock);
 
-	rap = lp->a.read_rap(ioaddr);
 	while ((csr0 = lp->a.read_csr(ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
 		if (csr0 == 0xffff) {
 			break;	/* PCMCIA remove happened */
@@ -2434,7 +2433,6 @@ pcnet32_interrupt(int irq, void *dev_id,
 
 	/* Set interrupt enable. */
 	lp->a.write_csr(ioaddr, 0, 0x0040);
-	lp->a.write_rap(ioaddr, rap);
 
 	if (netif_msg_intr(lp))
 		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
@@ -2647,13 +2645,10 @@ static struct net_device_stats *pcnet32_
 {
 	struct pcnet32_private *lp = dev->priv;
 	unsigned long ioaddr = dev->base_addr;
-	u16 saved_addr;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	saved_addr = lp->a.read_rap(ioaddr);
 	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
-	lp->a.write_rap(ioaddr, saved_addr);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return &lp->stats;
-- 
Don Fry
brazilnut@us.ibm.com
