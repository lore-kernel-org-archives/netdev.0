From: Greg Ungerer <gerg@snapgear.com>
Subject: [PATCH 2/2] fec: remove ColdFire specific setup code from FEC driver
Date: Tue, 17 Feb 2009 10:53:01 +1000
Message-ID: <200902170053.n1H0r1Zn002066@localhost.localdomain>
Cc: gerg@uclinux.org, netdev@vger.kernel.org
To: s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:49286 "EHLO
	snapgear.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751301AbZBQAxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 19:53:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

m68knommu: remove ColdFire specific setup code from FEC driver

Remove the ColdFire CPU specific setup from here. The ColdFire
CPU platform code now sets up all this.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>


diff a/drivers/net/fec.c b/drivers/net/fec.c
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -57,36 +57,11 @@
 #define FEC_ALIGNMENT	0x3
 #endif
 
-#if defined CONFIG_M5272 || defined CONFIG_M527x || defined CONFIG_M523x \
-	|| defined CONFIG_M528x || defined CONFIG_M532x || defined CONFIG_M520x
-#define FEC_LEGACY
 /*
  * Define the fixed address of the FEC hardware.
  */
 #if defined(CONFIG_M5272)
 #define HAVE_mii_link_interrupt
-#endif
-
-#if defined(CONFIG_FEC2)
-#define	FEC_MAX_PORTS	2
-#else
-#define	FEC_MAX_PORTS	1
-#endif
-
-static unsigned int fec_hw[] = {
-#if defined(CONFIG_M5272)
-	(MCF_MBAR + 0x840),
-#elif defined(CONFIG_M527x)
-	(MCF_MBAR + 0x1000),
-	(MCF_MBAR + 0x1800),
-#elif defined(CONFIG_M523x) || defined(CONFIG_M528x)
-	(MCF_MBAR + 0x1000),
-#elif defined(CONFIG_M520x)
-	(MCF_MBAR+0x30000),
-#elif defined(CONFIG_M532x)
-	(MCF_MBAR+0xfc030000),
-#endif
-};
 
 static unsigned char	fec_mac_default[] = {
 	0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
@@ -109,8 +84,7 @@ static unsigned char	fec_mac_default[] =
 #else
 #define	FEC_FLASHMAC	0
 #endif
-
-#endif /* FEC_LEGACY */
+#endif /* CONFIG_M5272 */
 
 /* Forward declarations of some structures to support different PHYs
 */
@@ -1242,89 +1216,14 @@ static phy_info_t const * const phy_info
 #ifdef HAVE_mii_link_interrupt
 static irqreturn_t
 mii_link_interrupt(int irq, void * dev_id);
-#endif
 
-#if defined(CONFIG_M5272)
 /*
- *	Code specific to Coldfire 5272 setup.
+ *	This is specific to the MII interrupt setup of the M5272EVB.
  */
-static void __inline__ fec_request_intrs(struct net_device *dev)
-{
-	volatile unsigned long *icrp;
-	static const struct idesc {
-		char *name;
-		unsigned short irq;
-		irq_handler_t handler;
-	} *idp, id[] = {
-		{ "fec(RX)", 86, fec_enet_interrupt },
-		{ "fec(TX)", 87, fec_enet_interrupt },
-		{ "fec(OTHER)", 88, fec_enet_interrupt },
-		{ "fec(MII)", 66, mii_link_interrupt },
-		{ NULL },
-	};
-
-	/* Setup interrupt handlers. */
-	for (idp = id; idp->name; idp++) {
-		if (request_irq(idp->irq, idp->handler, IRQF_DISABLED, idp->name, dev) != 0)
-			printk("FEC: Could not allocate %s IRQ(%d)!\n", idp->name, idp->irq);
-	}
-
-	/* Unmask interrupt at ColdFire 5272 SIM */
-	icrp = (volatile unsigned long *) (MCF_MBAR + MCFSIM_ICR3);
-	*icrp = 0x00000ddd;
-	icrp = (volatile unsigned long *) (MCF_MBAR + MCFSIM_ICR1);
-	*icrp = 0x0d000000;
-}
-
-static void __inline__ fec_set_mii(struct net_device *dev, struct fec_enet_private *fep)
+static void __inline__ fec_request_mii_intr(struct net_device *dev)
 {
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
-	fecp->fec_x_cntrl = 0x00;
-
-	/*
-	 * Set MII speed to 2.5 MHz
-	 * See 5272 manual section 11.5.8: MSCR
-	 */
-	fep->phy_speed = ((((MCF_CLK / 4) / (2500000 / 10)) + 5) / 10) * 2;
-	fecp->fec_mii_speed = fep->phy_speed;
-
-	fec_restart(dev, 0);
-}
-
-static void __inline__ fec_get_mac(struct net_device *dev)
-{
-	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile fec_t *fecp;
-	unsigned char *iap, tmpaddr[ETH_ALEN];
-
-	fecp = fep->hwp;
-
-	if (FEC_FLASHMAC) {
-		/*
-		 * Get MAC address from FLASH.
-		 * If it is all 1's or 0's, use the default.
-		 */
-		iap = (unsigned char *)FEC_FLASHMAC;
-		if ((iap[0] == 0) && (iap[1] == 0) && (iap[2] == 0) &&
-		    (iap[3] == 0) && (iap[4] == 0) && (iap[5] == 0))
-			iap = fec_mac_default;
-		if ((iap[0] == 0xff) && (iap[1] == 0xff) && (iap[2] == 0xff) &&
-		    (iap[3] == 0xff) && (iap[4] == 0xff) && (iap[5] == 0xff))
-			iap = fec_mac_default;
-	} else {
-		*((unsigned long *) &tmpaddr[0]) = fecp->fec_addr_low;
-		*((unsigned short *) &tmpaddr[4]) = (fecp->fec_addr_high >> 16);
-		iap = &tmpaddr[0];
-	}
-
-	memcpy(dev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using default MAC address */
-	if (iap == fec_mac_default)
-		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
+	if (request_irq(66, mii_link_interrupt, IRQF_DISABLED, "fec(MII)", dev) != 0)
+		printk("FEC: Could not allocate fec(MII) IRQ(66)!\n");
 }
 
 static void __inline__ fec_disable_phy_intr(void)
@@ -1341,344 +1240,9 @@ static void __inline__ fec_phy_ack_intr(
 	icrp = (volatile unsigned long *) (MCF_MBAR + MCFSIM_ICR1);
 	*icrp = 0x0d000000;
 }
-
-/* ------------------------------------------------------------------------- */
-
-#elif defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x)
-
-/*
- *	Code specific to Coldfire 5230/5231/5232/5234/5235,
- *	the 5270/5271/5274/5275 and 5280/5282 setups.
- */
-static void __inline__ fec_request_intrs(struct net_device *dev)
-{
-	struct fec_enet_private *fep;
-	int b;
-	static const struct idesc {
-		char *name;
-		unsigned short irq;
-	} *idp, id[] = {
-		{ "fec(TXF)", 23 },
-		{ "fec(RXF)", 27 },
-		{ "fec(MII)", 29 },
-		{ NULL },
-	};
-
-	fep = netdev_priv(dev);
-	b = (fep->index) ? 128 : 64;
-
-	/* Setup interrupt handlers. */
-	for (idp = id; idp->name; idp++) {
-		if (request_irq(b+idp->irq, fec_enet_interrupt, IRQF_DISABLED, idp->name, dev) != 0)
-			printk("FEC: Could not allocate %s IRQ(%d)!\n", idp->name, b+idp->irq);
-	}
-
-	/* Unmask interrupts at ColdFire 5280/5282 interrupt controller */
-	{
-		volatile unsigned char  *icrp;
-		volatile unsigned long  *imrp;
-		int i, ilip;
-
-		b = (fep->index) ? MCFICM_INTC1 : MCFICM_INTC0;
-		icrp = (volatile unsigned char *) (MCF_IPSBAR + b +
-			MCFINTC_ICR0);
-		for (i = 23, ilip = 0x28; (i < 36); i++)
-			icrp[i] = ilip--;
-
-		imrp = (volatile unsigned long *) (MCF_IPSBAR + b +
-			MCFINTC_IMRH);
-		*imrp &= ~0x0000000f;
-		imrp = (volatile unsigned long *) (MCF_IPSBAR + b +
-			MCFINTC_IMRL);
-		*imrp &= ~0xff800001;
-	}
-
-#if defined(CONFIG_M528x)
-	/* Set up gpio outputs for MII lines */
-	{
-		volatile u16 *gpio_paspar;
-		volatile u8 *gpio_pehlpar;
-
-		gpio_paspar = (volatile u16 *) (MCF_IPSBAR + 0x100056);
-		gpio_pehlpar = (volatile u16 *) (MCF_IPSBAR + 0x100058);
-		*gpio_paspar |= 0x0f00;
-		*gpio_pehlpar = 0xc0;
-	}
 #endif
 
-#if defined(CONFIG_M527x)
-	/* Set up gpio outputs for MII lines */
-	{
-		volatile u8 *gpio_par_fec;
-		volatile u16 *gpio_par_feci2c;
-
-		gpio_par_feci2c = (volatile u16 *)(MCF_IPSBAR + 0x100082);
-		/* Set up gpio outputs for FEC0 MII lines */
-		gpio_par_fec = (volatile u8 *)(MCF_IPSBAR + 0x100078);
-
-		*gpio_par_feci2c |= 0x0f00;
-		*gpio_par_fec |= 0xc0;
-
-#if defined(CONFIG_FEC2)
-		/* Set up gpio outputs for FEC1 MII lines */
-		gpio_par_fec = (volatile u8 *)(MCF_IPSBAR + 0x100079);
-
-		*gpio_par_feci2c |= 0x00a0;
-		*gpio_par_fec |= 0xc0;
-#endif /* CONFIG_FEC2 */
-	}
-#endif /* CONFIG_M527x */
-}
-
-static void __inline__ fec_set_mii(struct net_device *dev, struct fec_enet_private *fep)
-{
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
-	fecp->fec_x_cntrl = 0x00;
-
-	/*
-	 * Set MII speed to 2.5 MHz
-	 * See 5282 manual section 17.5.4.7: MSCR
-	 */
-	fep->phy_speed = ((((MCF_CLK / 2) / (2500000 / 10)) + 5) / 10) * 2;
-	fecp->fec_mii_speed = fep->phy_speed;
-
-	fec_restart(dev, 0);
-}
-
-static void __inline__ fec_get_mac(struct net_device *dev)
-{
-	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile fec_t *fecp;
-	unsigned char *iap, tmpaddr[ETH_ALEN];
-
-	fecp = fep->hwp;
-
-	if (FEC_FLASHMAC) {
-		/*
-		 * Get MAC address from FLASH.
-		 * If it is all 1's or 0's, use the default.
-		 */
-		iap = FEC_FLASHMAC;
-		if ((iap[0] == 0) && (iap[1] == 0) && (iap[2] == 0) &&
-		    (iap[3] == 0) && (iap[4] == 0) && (iap[5] == 0))
-			iap = fec_mac_default;
-		if ((iap[0] == 0xff) && (iap[1] == 0xff) && (iap[2] == 0xff) &&
-		    (iap[3] == 0xff) && (iap[4] == 0xff) && (iap[5] == 0xff))
-			iap = fec_mac_default;
-	} else {
-		*((unsigned long *) &tmpaddr[0]) = fecp->fec_addr_low;
-		*((unsigned short *) &tmpaddr[4]) = (fecp->fec_addr_high >> 16);
-		iap = &tmpaddr[0];
-	}
-
-	memcpy(dev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using default MAC address */
-	if (iap == fec_mac_default)
-		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
-}
-
-static void __inline__ fec_disable_phy_intr(void)
-{
-}
-
-static void __inline__ fec_phy_ack_intr(void)
-{
-}
-
-/* ------------------------------------------------------------------------- */
-
-#elif defined(CONFIG_M520x)
-/*
- *	Code specific to Coldfire 520x
- */
-static void __inline__ fec_request_intrs(struct net_device *dev)
-{
-	struct fec_enet_private *fep;
-	int b;
-	static const struct idesc {
-		char *name;
-		unsigned short irq;
-	} *idp, id[] = {
-		{ "fec(TXF)", 23 },
-		{ "fec(RXF)", 27 },
-		{ "fec(MII)", 29 },
-		{ NULL },
-	};
-
-	fep = netdev_priv(dev);
-	b = 64 + 13;
-
-	/* Setup interrupt handlers. */
-	for (idp = id; idp->name; idp++) {
-		if (request_irq(b+idp->irq, fec_enet_interrupt, IRQF_DISABLED, idp->name,dev) != 0)
-			printk("FEC: Could not allocate %s IRQ(%d)!\n", idp->name, b+idp->irq);
-	}
-
-	/* Unmask interrupts at ColdFire interrupt controller */
-	{
-		volatile unsigned char  *icrp;
-		volatile unsigned long  *imrp;
-
-		icrp = (volatile unsigned char *) (MCF_IPSBAR + MCFICM_INTC0 +
-			MCFINTC_ICR0);
-		for (b = 36; (b < 49); b++)
-			icrp[b] = 0x04;
-		imrp = (volatile unsigned long *) (MCF_IPSBAR + MCFICM_INTC0 +
-			MCFINTC_IMRH);
-		*imrp &= ~0x0001FFF0;
-	}
-	*(volatile unsigned char *)(MCF_IPSBAR + MCF_GPIO_PAR_FEC) |= 0xf0;
-	*(volatile unsigned char *)(MCF_IPSBAR + MCF_GPIO_PAR_FECI2C) |= 0x0f;
-}
-
-static void __inline__ fec_set_mii(struct net_device *dev, struct fec_enet_private *fep)
-{
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
-	fecp->fec_x_cntrl = 0x00;
-
-	/*
-	 * Set MII speed to 2.5 MHz
-	 * See 5282 manual section 17.5.4.7: MSCR
-	 */
-	fep->phy_speed = ((((MCF_CLK / 2) / (2500000 / 10)) + 5) / 10) * 2;
-	fecp->fec_mii_speed = fep->phy_speed;
-
-	fec_restart(dev, 0);
-}
-
-static void __inline__ fec_get_mac(struct net_device *dev)
-{
-	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile fec_t *fecp;
-	unsigned char *iap, tmpaddr[ETH_ALEN];
-
-	fecp = fep->hwp;
-
-	if (FEC_FLASHMAC) {
-		/*
-		 * Get MAC address from FLASH.
-		 * If it is all 1's or 0's, use the default.
-		 */
-		iap = FEC_FLASHMAC;
-		if ((iap[0] == 0) && (iap[1] == 0) && (iap[2] == 0) &&
-		   (iap[3] == 0) && (iap[4] == 0) && (iap[5] == 0))
-			iap = fec_mac_default;
-		if ((iap[0] == 0xff) && (iap[1] == 0xff) && (iap[2] == 0xff) &&
-		   (iap[3] == 0xff) && (iap[4] == 0xff) && (iap[5] == 0xff))
-			iap = fec_mac_default;
-	} else {
-		*((unsigned long *) &tmpaddr[0]) = fecp->fec_addr_low;
-		*((unsigned short *) &tmpaddr[4]) = (fecp->fec_addr_high >> 16);
-		iap = &tmpaddr[0];
-	}
-
-	memcpy(dev->dev_addr, iap, ETH_ALEN);
-
-	/* Adjust MAC if using default MAC address */
-	if (iap == fec_mac_default)
-		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
-}
-
-static void __inline__ fec_disable_phy_intr(void)
-{
-}
-
-static void __inline__ fec_phy_ack_intr(void)
-{
-}
-
-/* ------------------------------------------------------------------------- */
-#elif defined(CONFIG_M532x)
-/*
- * Code specific for M532x
- */
-static void __inline__ fec_request_intrs(struct net_device *dev)
-{
-	struct fec_enet_private *fep;
-	int b;
-	static const struct idesc {
-		char *name;
-		unsigned short irq;
-	} *idp, id[] = {
-	    { "fec(TXF)", 36 },
-	    { "fec(RXF)", 40 },
-	    { "fec(MII)", 42 },
-	    { NULL },
-	};
-
-	fep = netdev_priv(dev);
-	b = (fep->index) ? 128 : 64;
-
-	/* Setup interrupt handlers. */
-	for (idp = id; idp->name; idp++) {
-		if (request_irq(b+idp->irq, fec_enet_interrupt, IRQF_DISABLED, idp->name,dev) != 0)
-			printk("FEC: Could not allocate %s IRQ(%d)!\n",
-				idp->name, b+idp->irq);
-	}
-
-	/* Unmask interrupts */
-	MCF_INTC0_ICR36 = 0x2;
-	MCF_INTC0_ICR37 = 0x2;
-	MCF_INTC0_ICR38 = 0x2;
-	MCF_INTC0_ICR39 = 0x2;
-	MCF_INTC0_ICR40 = 0x2;
-	MCF_INTC0_ICR41 = 0x2;
-	MCF_INTC0_ICR42 = 0x2;
-	MCF_INTC0_ICR43 = 0x2;
-	MCF_INTC0_ICR44 = 0x2;
-	MCF_INTC0_ICR45 = 0x2;
-	MCF_INTC0_ICR46 = 0x2;
-	MCF_INTC0_ICR47 = 0x2;
-	MCF_INTC0_ICR48 = 0x2;
-
-	MCF_INTC0_IMRH &= ~(
-		MCF_INTC_IMRH_INT_MASK36 |
-		MCF_INTC_IMRH_INT_MASK37 |
-		MCF_INTC_IMRH_INT_MASK38 |
-		MCF_INTC_IMRH_INT_MASK39 |
-		MCF_INTC_IMRH_INT_MASK40 |
-		MCF_INTC_IMRH_INT_MASK41 |
-		MCF_INTC_IMRH_INT_MASK42 |
-		MCF_INTC_IMRH_INT_MASK43 |
-		MCF_INTC_IMRH_INT_MASK44 |
-		MCF_INTC_IMRH_INT_MASK45 |
-		MCF_INTC_IMRH_INT_MASK46 |
-		MCF_INTC_IMRH_INT_MASK47 |
-		MCF_INTC_IMRH_INT_MASK48 );
-
-	/* Set up gpio outputs for MII lines */
-	MCF_GPIO_PAR_FECI2C |= (0 |
-		MCF_GPIO_PAR_FECI2C_PAR_MDC_EMDC |
-		MCF_GPIO_PAR_FECI2C_PAR_MDIO_EMDIO);
-	MCF_GPIO_PAR_FEC = (0 |
-		MCF_GPIO_PAR_FEC_PAR_FEC_7W_FEC |
-		MCF_GPIO_PAR_FEC_PAR_FEC_MII_FEC);
-}
-
-static void __inline__ fec_set_mii(struct net_device *dev, struct fec_enet_private *fep)
-{
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
-	fecp->fec_x_cntrl = 0x00;
-
-	/*
-	 * Set MII speed to 2.5 MHz
-	 */
-	fep->phy_speed = (MCF_CLK / 3) / (2500000 * 2 ) * 2;
-	fecp->fec_mii_speed = fep->phy_speed;
-
-	fec_restart(dev, 0);
-}
-
+#ifdef CONFIG_M5272
 static void __inline__ fec_get_mac(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
@@ -1692,7 +1256,7 @@ static void __inline__ fec_get_mac(struc
 		 * Get MAC address from FLASH.
 		 * If it is all 1's or 0's, use the default.
 		 */
-		iap = FEC_FLASHMAC;
+		iap = (unsigned char *)FEC_FLASHMAC;
 		if ((iap[0] == 0) && (iap[1] == 0) && (iap[2] == 0) &&
 		    (iap[3] == 0) && (iap[4] == 0) && (iap[5] == 0))
 			iap = fec_mac_default;
@@ -1709,17 +1273,8 @@ static void __inline__ fec_get_mac(struc
 
 	/* Adjust MAC if using default MAC address */
 	if (iap == fec_mac_default)
-		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
-}
-
-static void __inline__ fec_disable_phy_intr(void)
-{
-}
-
-static void __inline__ fec_phy_ack_intr(void)
-{
+		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
-
 #endif
 
 /* ------------------------------------------------------------------------- */
@@ -1925,7 +1480,7 @@ mii_discover_phy(uint mii_reg, struct ne
 		printk("FEC: No PHY device found.\n");
 		/* Disable external MII interface */
 		fecp->fec_mii_speed = fep->phy_speed = 0;
-#ifdef FREC_LEGACY
+#ifdef HAVE_mii_link_interrupt
 		fec_disable_phy_intr();
 #endif
 	}
@@ -2148,7 +1703,7 @@ int __init fec_enet_init(struct net_devi
 	udelay(10);
 
 	/* Set the Ethernet address */
-#ifdef FEC_LEGACY
+#ifdef CONFIG_M5272
 	fec_get_mac(dev);
 #else
 	{
@@ -2231,11 +1786,8 @@ int __init fec_enet_init(struct net_devi
 	fecp->fec_r_des_start = fep->bd_dma;
 	fecp->fec_x_des_start = (unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE;
 
-#ifdef FEC_LEGACY
-	/* Install our interrupt handlers. This varies depending on
-	 * the architecture.
-	*/
-	fec_request_intrs(dev);
+#ifdef HAVE_mii_link_interrupt
+	fec_request_mii_intr(dev);
 #endif
 
 	fecp->fec_grp_hash_table_high = 0;
@@ -2261,9 +1813,6 @@ int __init fec_enet_init(struct net_devi
 	mii_free = mii_cmds;
 
 	/* setup MII interface */
-#ifdef FEC_LEGACY
-	fec_set_mii(dev, fep);
-#else
 	fecp->fec_r_cntrl = OPT_FRAME_SIZE | 0x04;
 	fecp->fec_x_cntrl = 0x00;
 
@@ -2274,7 +1823,6 @@ int __init fec_enet_init(struct net_devi
 					/ 2500000) / 2) & 0x3F) << 1;
 	fecp->fec_mii_speed = fep->phy_speed;
 	fec_restart(dev, 0);
-#endif
 
 	/* Clear and enable interrupts */
 	fecp->fec_ievent = 0xffc00000;
@@ -2437,36 +1985,6 @@ fec_stop(struct net_device *dev)
 	fecp->fec_mii_speed = fep->phy_speed;
 }
 
-#ifdef FEC_LEGACY
-static int __init fec_enet_module_init(void)
-{
-	struct net_device *dev;
-	int i, err;
-
-	printk("FEC ENET Version 0.2\n");
-
-	for (i = 0; (i < FEC_MAX_PORTS); i++) {
-		dev = alloc_etherdev(sizeof(struct fec_enet_private));
-		if (!dev)
-			return -ENOMEM;
-		dev->base_addr = (unsigned long)fec_hw[i];
-		err = fec_enet_init(dev, i);
-		if (err) {
-			free_netdev(dev);
-			continue;
-		}
-		if (register_netdev(dev) != 0) {
-			/* XXX: missing cleanup here */
-			free_netdev(dev);
-			return -EIO;
-		}
-
-		printk("%s: ethernet %pM\n", dev->name, dev->dev_addr);
-	}
-	return 0;
-}
-#else
-
 static int __devinit
 fec_probe(struct platform_device *pdev)
 {
@@ -2627,9 +2145,6 @@ fec_enet_cleanup(void)
 }
 
 module_exit(fec_enet_cleanup);
-
-#endif /* FEC_LEGACY */
-
 module_init(fec_enet_module_init);
 
 MODULE_LICENSE("GPL");
