From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 6/9] pcnet32: Suspend the chip rather than restart when changing multicast/promisc
Date: Thu, 29 Jun 2006 13:55:02 -0700
Message-ID: <20060629205502.GA22021@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:58326 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932524AbWF2Uys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:54:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKslkG016284
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:54:47 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKslXc283574
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:54:47 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKskvR009953
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:54:46 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Suspend the chip if possible rather than stop and discard all tx and rx
frames, when changing the mcast list or entering/leaving promiscuous
mode.  Created common pcnet32_suspend routine.

Tested ia32 and ppc64

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/set.pcnet32.c	Wed Jun 28 13:13:52 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 15:16:58 2006
@@ -1062,6 +1062,43 @@ static int pcnet32_phys_id(struct net_de
 	return 0;
 }
 
+/*
+ * lp->lock must be held.
+ */
+static int pcnet32_suspend(struct net_device *dev, unsigned long *flags,
+		int can_sleep)
+{
+	int csr5;
+	struct pcnet32_private *lp = dev->priv;
+	struct pcnet32_access *a = &lp->a;
+	ulong ioaddr = dev->base_addr;
+	int ticks;
+
+	/* set SUSPEND (SPND) - CSR5 bit 0 */
+	csr5 = a->read_csr(ioaddr, CSR5);
+	a->write_csr(ioaddr, CSR5, csr5 | CSR5_SUSPEND);
+
+	/* poll waiting for bit to be set */
+	ticks = 0;
+	while (!(a->read_csr(ioaddr, CSR5) & CSR5_SUSPEND)) {
+		spin_unlock_irqrestore(&lp->lock, *flags);
+		if (can_sleep)
+			msleep(1);
+		else
+			mdelay(1);
+		spin_lock_irqsave(&lp->lock, *flags);
+		ticks++;
+		if (ticks > 200) {
+			if (netif_msg_hw(lp))
+				printk(KERN_DEBUG
+				       "%s: Error getting into suspend!\n",
+				       dev->name);
+			return 0;
+		}
+	}
+	return 1;
+}
+
 #define PCNET32_REGS_PER_PHY	32
 #define PCNET32_MAX_PHYS	32
 static int pcnet32_get_regs_len(struct net_device *dev)
@@ -1080,32 +1117,13 @@ static void pcnet32_get_regs(struct net_
 	struct pcnet32_private *lp = dev->priv;
 	struct pcnet32_access *a = &lp->a;
 	ulong ioaddr = dev->base_addr;
-	int ticks;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	csr0 = a->read_csr(ioaddr, 0);
-	if (!(csr0 & 0x0004)) {	/* If not stopped */
-		/* set SUSPEND (SPND) - CSR5 bit 0 */
-		a->write_csr(ioaddr, 5, 0x0001);
-
-		/* poll waiting for bit to be set */
-		ticks = 0;
-		while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
-			spin_unlock_irqrestore(&lp->lock, flags);
-			mdelay(1);
-			spin_lock_irqsave(&lp->lock, flags);
-			ticks++;
-			if (ticks > 200) {
-				if (netif_msg_hw(lp))
-					printk(KERN_DEBUG
-					       "%s: Error getting into suspend!\n",
-					       dev->name);
-				break;
-			}
-		}
-	}
+	csr0 = a->read_csr(ioaddr, CSR0);
+	if (!(csr0 & CSR0_STOP))	/* If not stopped */
+		pcnet32_suspend(dev, &flags, 1);
 
 	/* read address PROM */
 	for (i = 0; i < 16; i += 2)
@@ -1142,9 +1160,12 @@ static void pcnet32_get_regs(struct net_
 		}
 	}
 
-	if (!(csr0 & 0x0004)) {	/* If not stopped */
+	if (!(csr0 & CSR0_STOP)) {	/* If not stopped */
+		int csr5;
+
 		/* clear SUSPEND (SPND) - CSR5 bit 0 */
-		a->write_csr(ioaddr, 5, 0x0000);
+		csr5 = a->read_csr(ioaddr, CSR5);
+		a->write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
 	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -2652,6 +2673,7 @@ static void pcnet32_load_multicast(struc
 	volatile struct pcnet32_init_block *ib = &lp->init_block;
 	volatile u16 *mcast_table = (u16 *) & ib->filter;
 	struct dev_mc_list *dmi = dev->mc_list;
+	unsigned long ioaddr = dev->base_addr;
 	char *addrs;
 	int i;
 	u32 crc;
@@ -2660,6 +2682,10 @@ static void pcnet32_load_multicast(struc
 	if (dev->flags & IFF_ALLMULTI) {
 		ib->filter[0] = 0xffffffff;
 		ib->filter[1] = 0xffffffff;
+		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER, 0xffff);
+		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+1, 0xffff);
+		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+2, 0xffff);
+		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+3, 0xffff);
 		return;
 	}
 	/* clear the multicast filter */
@@ -2681,6 +2707,9 @@ static void pcnet32_load_multicast(struc
 		    le16_to_cpu(le16_to_cpu(mcast_table[crc >> 4]) |
 				(1 << (crc & 0xf)));
 	}
+	for (i = 0; i < 4; i++)
+		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER + i,
+				le16_to_cpu(mcast_table[i]));
 	return;
 }
 
@@ -2691,8 +2720,11 @@ static void pcnet32_set_multicast_list(s
 {
 	unsigned long ioaddr = dev->base_addr, flags;
 	struct pcnet32_private *lp = dev->priv;
+	int csr15, suspended;
 
 	spin_lock_irqsave(&lp->lock, flags);
+	suspended = pcnet32_suspend(dev, &flags, 0);
+	csr15 = lp->a.read_csr(ioaddr, CSR15);
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
 		if (netif_msg_hw(lp))
@@ -2701,15 +2733,24 @@ static void pcnet32_set_multicast_list(s
 		lp->init_block.mode =
 		    le16_to_cpu(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
 				7);
+		lp->a.write_csr(ioaddr, CSR15, csr15 | 0x8000);
 	} else {
 		lp->init_block.mode =
 		    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
+		lp->a.write_csr(ioaddr, CSR15, csr15 & 0x7fff);
 		pcnet32_load_multicast(dev);
 	}
 
-	lp->a.write_csr(ioaddr, 0, 0x0004);	/* Temporarily stop the lance. */
-	pcnet32_restart(dev, 0x0042);	/*  Resume normal operation */
-	netif_wake_queue(dev);
+	if (suspended) {
+		int csr5;
+		/* clear SUSPEND (SPND) - CSR5 bit 0 */
+		csr5 = lp->a.read_csr(ioaddr, CSR5);
+		lp->a.write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
+	} else { 
+		lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
+		pcnet32_restart(dev, CSR0_NORMAL);
+		netif_wake_queue(dev);
+	}
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
-- 
Don Fry
brazilnut@us.ibm.com
