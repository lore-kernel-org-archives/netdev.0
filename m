From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] pcnet32: break in 2.6.18-rc1 identified
Date: Thu, 3 Aug 2006 09:06:07 -0700
Message-ID: <20060803160607.GA961@us.ibm.com>
References: <44C65AED.4020508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:41700 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S964832AbWHCQFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 12:05:44 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k73G5hdd002977
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 12:05:43 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k73G5hHS288204
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 12:05:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k73G5gkl020541
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 12:05:43 -0400
To: Jeff Garzik <jeff@garzik.org>, murrayma@citi.umich.edu
Content-Disposition: inline
In-Reply-To: <44C65AED.4020508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A change I made for 2.6.17 and another for 2.6.18 do not work on older
pcnet32 chips which I do not have access to.  Please test this patch if
you have access to a 79C970, 79C974, or 79C965 (VLB) version of the
pcnet32 and let me know if it solves any problems.  I have tested with a
79C970A, 79C971, 79C972, 79C973, 79C975, 79C976, and 79C978 and the
changes work as expected.


--- linux-2.6.18-rc3-git1/drivers/net/orig.pcnet32.c	Tue Aug  1 14:47:07 2006
+++ linux-2.6.18-rc3-git1/drivers/net/pcnet32.c	Thu Aug  3 08:36:26 2006
@@ -202,6 +202,8 @@ static int homepna[MAX_UNITS];
 #define CSR15		15
 #define PCNET32_MC_FILTER	8
 
+#define PCNET32_79C970A	0x2621
+
 /* The PCNET32 Rx and Tx ring descriptors. */
 struct pcnet32_rx_head {
 	u32	base;
@@ -289,6 +291,7 @@ struct pcnet32_private {
 
 	/* each bit indicates an available PHY */
 	u32			phymask;
+	unsigned short		chip_version;	/* which variant this is */
 };
 
 static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
@@ -724,9 +727,11 @@ static u32 pcnet32_get_link(struct net_d
 	spin_lock_irqsave(&lp->lock, flags);
 	if (lp->mii) {
 		r = mii_link_ok(&lp->mii_if);
-	} else {
+	} else if (lp->chip_version >= PCNET32_79C970A) {
 		ulong ioaddr = dev->base_addr;	/* card base I/O address */
 		r = (lp->a.read_bcr(ioaddr, 4) != 0xc0);
+	} else {	/* can not detect link on really old chips */
+		r = 1;
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -1091,6 +1096,10 @@ static int pcnet32_suspend(struct net_de
 	ulong ioaddr = dev->base_addr;
 	int ticks;
 
+	/* really old chips have to be stopped. */
+	if (lp->chip_version < PCNET32_79C970A)
+		return 1;
+
 	/* set SUSPEND (SPND) - CSR5 bit 0 */
 	csr5 = a->read_csr(ioaddr, CSR5);
 	a->write_csr(ioaddr, CSR5, csr5 | CSR5_SUSPEND);
@@ -1529,6 +1538,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	lp->mii_if.reg_num_mask = 0x1f;
 	lp->dxsuflo = dxsuflo;
 	lp->mii = mii;
+	lp->chip_version = chip_version;
 	lp->msg_enable = pcnet32_debug;
 	if ((cards_found >= MAX_UNITS)
 	    || (options[cards_found] > sizeof(options_mapping)))
@@ -1839,10 +1849,7 @@ static int pcnet32_open(struct net_devic
 				val |= 2;
 		} else if (lp->options & PCNET32_PORT_ASEL) {
 			/* workaround of xSeries250, turn on for 79C975 only */
-			i = ((lp->a.read_csr(ioaddr, 88) |
-			      (lp->a.
-			       read_csr(ioaddr, 89) << 16)) >> 12) & 0xffff;
-			if (i == 0x2627)
+			if (lp->chip_version == 0x2627)
 				val |= 3;
 		}
 		lp->a.write_bcr(ioaddr, 9, val);
@@ -1986,9 +1993,11 @@ static int pcnet32_open(struct net_devic
 
 	netif_start_queue(dev);
 
-	/* Print the link status and start the watchdog */
-	pcnet32_check_media(dev, 1);
-	mod_timer(&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
+	if (lp->chip_version >= PCNET32_79C970A) {
+		/* Print the link status and start the watchdog */
+		pcnet32_check_media(dev, 1);
+		mod_timer(&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
+	}
 
 	i = 0;
 	while (i++ < 100)

-- 
Don Fry
brazilnut@us.ibm.com
