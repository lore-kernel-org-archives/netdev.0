From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 28/29] LMC: Simplify and fix CSR names and logic.
Date: Sat, 31 Jul 2010 17:05:51 +0200
Message-ID: <1280588752-9340-28-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57893 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756595Ab0GaPG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:27 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |  155 ++++++++++++++++++-----------------=
--------
 drivers/net/wan/lmc/media.c |   24 ++++----
 drivers/net/wan/lmc/var.h   |   93 ++++++++++++--------------
 3 files changed, 118 insertions(+), 154 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 13383a5..6635afc 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -26,8 +26,7 @@
  * arround.
  *
  * The initialization portion of this driver (the lmc_reset() and the
- * lmc_dec_reset() functions, as well as the led controls and the
- * lmc_initcsrs() functions.
+ * lmc_dec_reset() functions, as well as the led controls.
  *
  * The watchdog function runs every second and checks to see if
  * we still have link, and that the timing source is what we expected
@@ -96,8 +95,6 @@ static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
 static struct net_device_stats *lmc_get_stats(struct net_device *dev);
 static irqreturn_t lmc_interrupt(int irq, void *dev_instance);
-static void lmc_initcsrs(struct card * const sc, lmc_csrptr_t csr_base=
,
-			 size_t csr_size);
 static void lmc_softreset(struct card * const);
 static void lmc_running_reset(struct net_device *dev);
 static int lmc_ifdown(struct net_device * const);
@@ -329,13 +326,13 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			   to reset that later anyway. */
=20
 			sc->gpio &=3D ~LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			/* hold for more than 10 microseconds */
 			udelay(50);
=20
 			sc->gpio |=3D LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			/* stop driving Xilinx-related signals */
 			lmc_gpio_mkinput(sc, 0xff);
@@ -386,16 +383,16 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			   to reset that later anyway. */
=20
 			sc->gpio &=3D ~(LMC_GEP_RESET | LMC_GEP_DP);
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			/* hold for more than 10 microseconds */
 			udelay(50);
=20
 			sc->gpio |=3D LMC_GEP_DP | LMC_GEP_RESET;
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			/* busy wait for the chip to reset */
-			while ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0 &&
+			while ((csr_read(sc, CSR_GPIO) & LMC_GEP_INIT) =3D=3D 0 &&
 			       (timeout-- > 0))
 				cpu_relax();
=20
@@ -450,7 +447,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			sc->gpio &=3D ~LMC_GEP_DP;
 			sc->gpio &=3D ~LMC_GEP_RESET;
 			sc->gpio |=3D  LMC_GEP_MODE;
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			lmc_gpio_mkoutput(sc, LMC_GEP_MODE | LMC_GEP_DP |
 					  LMC_GEP_RESET);
@@ -477,13 +474,13 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 			sc->gpio |=3D LMC_GEP_MODE;
 			sc->gpio |=3D LMC_GEP_DATA;
 			sc->gpio |=3D LMC_GEP_CLK;
-			LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+			csr_write(sc, CSR_GPIO, sc->gpio);
=20
 			lmc_gpio_mkoutput(sc, LMC_GEP_DATA | LMC_GEP_CLK |
 					  LMC_GEP_MODE);
=20
 			/* busy wait for the chip to reset */
-			while ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0 &&
+			while ((csr_read(sc, CSR_GPIO) & LMC_GEP_INIT) =3D=3D 0 &&
 			       (timeout-- > 0))
 				cpu_relax();
=20
@@ -511,24 +508,25 @@ int lmc_ioctl(struct net_device *dev, struct ifre=
q *ifr, int cmd)
 				/* Clock to zero */
 				sc->gpio &=3D ~LMC_GEP_CLK;
 				sc->gpio |=3D LMC_GEP_MODE;
-				LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+				csr_write(sc, CSR_GPIO, sc->gpio);
 				udelay(1);
=20
 				/* Put the clack back to one */
 				sc->gpio |=3D LMC_GEP_CLK;
 				sc->gpio |=3D LMC_GEP_MODE;
-				LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+				csr_write(sc, CSR_GPIO, sc->gpio);
 				udelay(1);
 			}
-			if ((LMC_CSR_READ(sc, csr_gp) & LMC_GEP_INIT) =3D=3D 0) {
+
+			if ((csr_read(sc, CSR_GPIO) & LMC_GEP_INIT) =3D=3D 0)
 				printk(KERN_WARNING
 				       "%s: Reprogramming FAILED. Needs to be reprogrammed. (corru=
pted data)\n",
 				       dev->name);
-			} else if ((LMC_CSR_READ(sc, csr_gp) &
-				    LMC_GEP_DP) =3D=3D 0){
-				printk(KERN_WARNING "%s: Reprogramming FAILED. Needs to be reprogr=
ammed. (done)\n",
+			else if ((csr_read(sc, CSR_GPIO) & LMC_GEP_DP) =3D=3D 0)
+				printk(KERN_WARNING
+				       "%s: Reprogramming FAILED. Needs to be reprogrammed. (done)=
\n",
 				       dev->name);
-			} else
+			else
 				printk(KERN_DEBUG
 				       "%s: Done reprogramming Xilinx, %d bits, good luck!\n",
 				       dev->name, pos);
@@ -583,9 +581,9 @@ static void lmc_watchdog(unsigned long data)
 	 * and the transmit and receive processes are running.
 	 */
=20
-	LMC_CSR_WRITE(sc, csr_15, 0x00000011);
+	csr_write(sc, CSR_WATCHDOG, 0x00000011);
 	sc->cmdmode |=3D TULIP_CMD_TXRUN | TULIP_CMD_RXRUN;
-	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
+	csr_write(sc, CSR_COMMAND, sc->cmdmode);
=20
 	if (sc->ok =3D=3D 0)
 		goto kick_timer;
@@ -657,7 +655,7 @@ static void lmc_watchdog(unsigned long data)
=20
 	/* Poke the transmitter to make sure it never stops, even if we run
 	   out of mem */
-	LMC_CSR_WRITE(sc, csr_rxpoll, 0);
+	csr_write(sc, CSR_RXPOLL, 0);
=20
 	/* Check for code that failed and try and fix it as appropriate */
 	if (sc->failed_ring =3D=3D 1) {
@@ -678,8 +676,8 @@ static void lmc_watchdog(unsigned long data)
=20
 	/* remember the timer value */
 kick_timer:
-	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
-	LMC_CSR_WRITE(sc, csr_gp_timer, 0xffffffffUL);
+	ticks =3D csr_read(sc, CSR_GP_TIMER);
+	csr_write(sc, CSR_GP_TIMER, 0xffffffffUL);
 	sc->ictl.ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
=20
 	/* restart this timer. */
@@ -776,8 +774,6 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
=20
 	dev_info(&pdev->dev, "%s =3D LMC %s\n", dev->name, sc->media->name);
=20
-	lmc_initcsrs(sc, dev->base_addr, 8);
-
 	lmc_gpio_mkinput(sc, 0xff);
 	sc->gpio =3D 0;		/* drive no signals yet */
=20
@@ -794,7 +790,7 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
 		dev_warn(&pdev->dev, "%s: Invalid model number (%d)",
 			 dev->name, model);
=20
-	LMC_CSR_WRITE(sc, csr_gp_timer, 0xFFFFFFFFUL); /* reset clock */
+	csr_write(sc, CSR_GP_TIMER, 0xFFFFFFFFUL); /* reset clock */
=20
 	sc->extra_stats.check =3D STATCHECK;
 	sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
@@ -901,11 +897,11 @@ static int lmc_open(struct net_device *dev)
 			     TULIP_STS_SYSERROR | TULIP_STS_TXSTOPPED |
 			     TULIP_STS_TXUNDERFLOW | TULIP_STS_RXSTOPPED |
 			     TULIP_STS_RXNOBUF);
-	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
+	csr_write(sc, CSR_INTR, sc->intrmask);
=20
 	sc->cmdmode |=3D TULIP_CMD_TXRUN;
 	sc->cmdmode |=3D TULIP_CMD_RXRUN;
-	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
+	csr_write(sc, CSR_COMMAND, sc->cmdmode);
=20
 	sc->ok =3D 1; /* Run watchdog */
=20
@@ -935,7 +931,7 @@ static void lmc_running_reset(struct net_device *de=
v)
=20
 	/* stop interrupts */
 	/* Clear the interrupt mask */
-	LMC_CSR_WRITE(sc, csr_intr, 0x00000000);
+	csr_write(sc, CSR_INTR, 0x00000000);
=20
 	lmc_dec_reset(sc);
 	lmc_reset(sc);
@@ -951,10 +947,10 @@ static void lmc_running_reset(struct net_device *=
dev)
 	sc->extra_stats.tx_tbusy0++;
=20
 	sc->intrmask =3D TULIP_DEFAULT_INTR_MASK;
-	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
+	csr_write(sc, CSR_INTR, sc->intrmask);
=20
 	sc->cmdmode |=3D (TULIP_CMD_TXRUN | TULIP_CMD_RXRUN);
-	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
+	csr_write(sc, CSR_COMMAND, sc->cmdmode);
=20
 	lmc_trace(dev, "lmc_runnin_reset_out");
 }
@@ -998,16 +994,16 @@ static int lmc_ifdown(struct net_device *dev)
=20
 	/* stop interrupts */
 	/* Clear the interrupt mask */
-	LMC_CSR_WRITE(sc, csr_intr, 0x00000000);
+	csr_write(sc, CSR_INTR, 0x00000000);
=20
 	/* Stop Tx and Rx on the chip */
-	csr6 =3D LMC_CSR_READ(sc, csr_command);
+	csr6 =3D csr_read(sc, CSR_COMMAND);
 	csr6 &=3D ~LMC_DEC_ST;		/* Turn off the Transmission bit */
 	csr6 &=3D ~LMC_DEC_SR;		/* Turn off the Receive bit */
-	LMC_CSR_WRITE(sc, csr_command, csr6);
+	csr_write(sc, CSR_COMMAND, csr6);
=20
 	sc->netdev->stats.rx_missed_errors +=3D
-		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
+		csr_read(sc, CSR_MISSED_FRAMES) & 0xFFFF;
=20
 	/* release the interrupt */
 	if (sc->got_irq =3D=3D 1) {
@@ -1062,7 +1058,7 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 	spin_lock(&sc->lock);
=20
 	/* Read the csr to find what interrupts we have (if any) */
-	csr =3D LMC_CSR_READ(sc, csr_status);
+	csr =3D csr_read(sc, CSR_STATUS);
=20
 	/* Make sure this is our interrupt */
 	if (!(csr & sc->intrmask))
@@ -1075,7 +1071,7 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
 		handled =3D 1;
=20
 		/* Clear interrupt bits, we handle all case below */
-		LMC_CSR_WRITE(sc, csr_status, csr);
+		csr_write(sc, CSR_STATUS, csr);
=20
 		/*
 		 * One of
@@ -1201,7 +1197,7 @@ static irqreturn_t lmc_interrupt(int irq, void *d=
ev_instance)
=20
 		/* Get current csr status to make sure we've cleared all
 		   interrupts */
-		csr =3D LMC_CSR_READ(sc, csr_status);
+		csr =3D csr_read(sc, CSR_STATUS);
 	} /* end interrupt loop */
=20
 lmc_int_fail_out:
@@ -1282,7 +1278,7 @@ static netdev_tx_t lmc_start_xmit(struct sk_buff =
*skb,
 	sc->txring[entry].status =3D 0x80000000;
=20
 	/* send now! */
-	LMC_CSR_WRITE(sc, csr_txpoll, 0);
+	csr_write(sc, CSR_TXPOLL, 0);
=20
 	spin_unlock_irqrestore(&sc->lock, flags);
=20
@@ -1486,7 +1482,7 @@ static struct net_device_stats *lmc_get_stats(str=
uct net_device *dev)
 	spin_lock_irqsave(&sc->lock, flags);
=20
 	sc->netdev->stats.rx_missed_errors +=3D
-		LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
+		csr_read(sc, CSR_MISSED_FRAMES) & 0xFFFF;
=20
 	spin_unlock_irqrestore(&sc->lock, flags);
=20
@@ -1530,10 +1526,10 @@ unsigned lmc_mii_readreg(struct card * const sc=
, unsigned devaddr,
 	for (i =3D 15; i >=3D 0; i--) {
 		int dataval =3D (command & (1 << i)) ? 0x20000 : 0;
=20
-		LMC_CSR_WRITE(sc, csr_9, dataval);
+		csr_write(sc, CSR_SROM_MII, dataval);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
-		LMC_CSR_WRITE(sc, csr_9, dataval | 0x10000);
+		csr_write(sc, CSR_SROM_MII, dataval | 0x10000);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
 	}
@@ -1541,12 +1537,12 @@ unsigned lmc_mii_readreg(struct card * const sc=
, unsigned devaddr,
 	lmc_trace(sc->netdev, "lmc_mii_readreg: done1");
=20
 	for (i =3D 19; i > 0; i--) {
-		LMC_CSR_WRITE(sc, csr_9, 0x40000);
+		csr_write(sc, CSR_SROM_MII, 0x40000);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
-		retval =3D (retval << 1) |
-			((LMC_CSR_READ(sc, csr_9) & 0x80000) ? 1 : 0);
-		LMC_CSR_WRITE(sc, csr_9, 0x40000 | 0x10000);
+		retval <<=3D 1;
+		retval |=3D !!(csr_read(sc, CSR_SROM_MII) & 0x80000);
+		csr_write(sc, CSR_SROM_MII, 0x40000 | 0x10000);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
 	}
@@ -1575,10 +1571,10 @@ void lmc_mii_writereg(struct card * const sc, u=
nsigned devaddr, unsigned regno,
 		else
 			datav =3D 0x00000;
=20
-		LMC_CSR_WRITE(sc, csr_9, datav);
+		csr_write(sc, CSR_SROM_MII, datav);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
-		LMC_CSR_WRITE(sc, csr_9, (datav | 0x10000));
+		csr_write(sc, CSR_SROM_MII, (datav | 0x10000));
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
 		i--;
@@ -1586,10 +1582,10 @@ void lmc_mii_writereg(struct card * const sc, u=
nsigned devaddr, unsigned regno,
=20
 	i =3D 2;
 	while (i > 0) {
-		LMC_CSR_WRITE(sc, csr_9, 0x40000);
+		csr_write(sc, CSR_SROM_MII, 0x40000);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
-		LMC_CSR_WRITE(sc, csr_9, 0x50000);
+		csr_write(sc, CSR_SROM_MII, 0x50000);
 		lmc_delay();
 		/* __SLOW_DOWN_IO; */
 		i--;
@@ -1658,7 +1654,7 @@ static void lmc_softreset(struct card * const sc)
 		sc->rxring[i - 1].buffer2 =3D virt_to_bus(&sc->rxring[0]);
 	}
 	/* write base address */
-	LMC_CSR_WRITE(sc, csr_rxlist, virt_to_bus(sc->rxring));
+	csr_write(sc, CSR_RXLIST, virt_to_bus(sc->rxring));
=20
 	/* Initialize the transmit rings and buffers */
 	for (i =3D 0; i < LMC_TXDESCS; i++) {
@@ -1672,7 +1668,7 @@ static void lmc_softreset(struct card * const sc)
 		sc->txring[i].buffer2 =3D virt_to_bus(&sc->txring[i + 1]);
 	}
 	sc->txring[i - 1].buffer2 =3D virt_to_bus(&sc->txring[0]);
-	LMC_CSR_WRITE(sc, csr_txlist, virt_to_bus(sc->txring));
+	csr_write(sc, CSR_TXLIST, virt_to_bus(sc->txring));
=20
 	lmc_trace(sc->netdev, "lmc_softreset out");
 }
@@ -1681,7 +1677,7 @@ void lmc_gpio_mkinput(struct card * const sc, u32=
 bits)
 {
 	lmc_trace(sc->netdev, "lmc_gpio_mkinput in");
 	sc->gpio_io &=3D ~bits;
-	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->gpio_io));
+	csr_write(sc, CSR_GPIO, TULIP_GP_PINSET | (sc->gpio_io));
 	lmc_trace(sc->netdev, "lmc_gpio_mkinput out");
 }
=20
@@ -1689,7 +1685,7 @@ void lmc_gpio_mkoutput(struct card * const sc, u3=
2 bits)
 {
 	lmc_trace(sc->netdev, "lmc_gpio_mkoutput in");
 	sc->gpio_io |=3D bits;
-	LMC_CSR_WRITE(sc, csr_gp, TULIP_GP_PINSET | (sc->gpio_io));
+	csr_write(sc, CSR_GPIO, TULIP_GP_PINSET | (sc->gpio_io));
 	lmc_trace(sc->netdev, "lmc_gpio_mkoutput out");
 }
=20
@@ -1734,7 +1730,7 @@ static void lmc_reset(struct card * const sc)
 	/* RESET low to force state reset.  This also forces the transmitter
 	   clock to be internal, but we expect to reset that later anyway. */
 	sc->gpio &=3D ~(LMC_GEP_RESET);
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
=20
 	/* hold for more than 10 microseconds */
 	udelay(50);
@@ -1756,20 +1752,20 @@ static void lmc_dec_reset(struct card * const s=
c)
=20
 	/* disable all interrupts */
 	sc->intrmask =3D 0;
-	LMC_CSR_WRITE(sc, csr_intr, sc->intrmask);
+	csr_write(sc, CSR_INTR, sc->intrmask);
=20
 	/* Reset the chip with a software reset command. Wait 10 microseconds
 	   (actually 50 PCI cycles but at 33MHz that comes to two microsecond=
s
 	   but wait a bit longer anyways) */
-	LMC_CSR_WRITE(sc, csr_busmode, TULIP_BUSMODE_SWRESET);
+	csr_write(sc, CSR_BUSMODE, TULIP_BUSMODE_SWRESET);
 	udelay(25);
 #ifdef __sparc__
-	sc->busmode =3D LMC_CSR_READ(sc, csr_busmode);
+	sc->busmode =3D csr_read(sc, CSR_BUSMODE);
 	sc->busmode =3D 0x00100000;
 	sc->busmode &=3D ~TULIP_BUSMODE_SWRESET;
-	LMC_CSR_WRITE(sc, csr_busmode, sc->busmode);
+	csr_write(sc, CSR_BUSMODE, sc->busmode);
 #endif
-	sc->cmdmode =3D LMC_CSR_READ(sc, csr_command);
+	sc->cmdmode =3D csr_read(sc, CSR_COMMAND);
=20
 	/*
 	 * We want:
@@ -1788,39 +1784,16 @@ static void lmc_dec_reset(struct card * const s=
c)
 	sc->cmdmode &=3D ~(TULIP_CMD_OPERMODE | TULIP_CMD_THRESHOLDCTL |
 			     TULIP_CMD_STOREFWD | TULIP_CMD_TXTHRSHLDCTL);
=20
-	LMC_CSR_WRITE(sc, csr_command, sc->cmdmode);
+	csr_write(sc, CSR_COMMAND, sc->cmdmode);
=20
 	/* disable receiver watchdog and transmit jabber */
-	val =3D LMC_CSR_READ(sc, csr_sia_general);
+	val =3D csr_read(sc, CSR_WATCHDOG);
 	val |=3D (TULIP_WATCHDOG_TXDISABLE | TULIP_WATCHDOG_RXDISABLE);
-	LMC_CSR_WRITE(sc, csr_sia_general, val);
+	csr_write(sc, CSR_WATCHDOG, val);
=20
 	lmc_trace(sc->netdev, "lmc_dec_reset out");
 }
=20
-static void lmc_initcsrs(struct card * const sc, lmc_csrptr_t csr_base=
,
-			 size_t csr_size)
-{
-	lmc_trace(sc->netdev, "lmc_initcsrs in");
-	sc->csrs.csr_busmode	=3D csr_base +  0 * csr_size;
-	sc->csrs.csr_txpoll		=3D csr_base +  1 * csr_size;
-	sc->csrs.csr_rxpoll		=3D csr_base +  2 * csr_size;
-	sc->csrs.csr_rxlist		=3D csr_base +  3 * csr_size;
-	sc->csrs.csr_txlist		=3D csr_base +  4 * csr_size;
-	sc->csrs.csr_status		=3D csr_base +  5 * csr_size;
-	sc->csrs.csr_command	=3D csr_base +  6 * csr_size;
-	sc->csrs.csr_intr		=3D csr_base +  7 * csr_size;
-	sc->csrs.csr_missed_frames	=3D csr_base +  8 * csr_size;
-	sc->csrs.csr_9		=3D csr_base +  9 * csr_size;
-	sc->csrs.csr_10		=3D csr_base + 10 * csr_size;
-	sc->csrs.csr_11		=3D csr_base + 11 * csr_size;
-	sc->csrs.csr_12		=3D csr_base + 12 * csr_size;
-	sc->csrs.csr_13		=3D csr_base + 13 * csr_size;
-	sc->csrs.csr_14		=3D csr_base + 14 * csr_size;
-	sc->csrs.csr_15		=3D csr_base + 15 * csr_size;
-	lmc_trace(sc->netdev, "lmc_initcsrs out");
-}
-
 static void lmc_driver_timeout(struct net_device *dev)
 {
 	struct card *sc =3D dev_to_sc(dev);
@@ -1843,12 +1816,12 @@ static void lmc_driver_timeout(struct net_devic=
e *dev)
 	lmc_running_reset(dev);
=20
 	/* restart the tx processes */
-	csr6 =3D LMC_CSR_READ(sc, csr_command);
-	LMC_CSR_WRITE(sc, csr_command, csr6 | 0x0002);
-	LMC_CSR_WRITE(sc, csr_command, csr6 | 0x2002);
+	csr6 =3D csr_read(sc, CSR_COMMAND);
+	csr_write(sc, CSR_COMMAND, csr6 | 0x0002);
+	csr_write(sc, CSR_COMMAND, csr6 | 0x2002);
=20
 	/* immediate transmit */
-	LMC_CSR_WRITE(sc, csr_txpoll, 0);
+	csr_write(sc, CSR_TXPOLL, 0);
=20
 	sc->netdev->stats.tx_errors++;
 	sc->extra_stats.tx_ProcTimeout++;
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index b9fadb4..cad17be 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -46,15 +46,15 @@ static inline void write_av9110_bit(struct card *sc=
, int c)
 		sc->gpio |=3D LMC_GEP_DATA;
 	else
 		sc->gpio &=3D ~(LMC_GEP_DATA);
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
=20
 	/* set the clock to high */
 	sc->gpio |=3D LMC_GEP_CLK;
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
=20
 	/* set the clock to low again. */
 	sc->gpio &=3D ~(LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
 }
=20
 static void write_av9110(struct card *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
@@ -68,14 +68,14 @@ static void write_av9110(struct card *sc, u32 n, u3=
2 m, u32 v, u32 x, u32 r)
=20
 	sc->gpio |=3D LMC_GEP_SSI_GENERATOR;
 	sc->gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
=20
 	/* Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK as outputs. */
 	lmc_gpio_mkoutput(sc, (LMC_GEP_DATA | LMC_GEP_CLK
 				| LMC_GEP_SSI_GENERATOR));
=20
 	sc->gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
-	LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+	csr_write(sc, CSR_GPIO, sc->gpio);
=20
 	/* a shifting we will go... */
 	for (i =3D 0; i < 7; i++)
@@ -118,14 +118,14 @@ static void lmc_ssi_set_clock(struct card * const=
 sc, int ie)
 	old =3D ie;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
 		sc->gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (ie !=3D old)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
 		sc->gpio |=3D LMC_GEP_SSI_TXCLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (ie !=3D old)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
@@ -217,7 +217,7 @@ static int lmc_ssi_get_link_status(struct card * co=
nst sc)
 	link_status =3D lmc_mii_readreg(sc, 0, 16);
=20
 	/* Is the transmit clock still available */
-	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
+	ticks =3D csr_read(sc, CSR_GP_TIMER);
 	ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
=20
 	lmc_led_on(sc, LMC_MII16_LED0);
@@ -347,14 +347,14 @@ static void lmc_hssi_set_clock(struct card * cons=
t sc, int ie)
 	old =3D sc->ictl.clock_source;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
 		sc->gpio |=3D LMC_GEP_HSSI_CLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
 		sc->gpio &=3D ~LMC_GEP_HSSI_CLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
@@ -864,14 +864,14 @@ static void lmc_t1_set_clock(struct card * const =
sc, int ie)
 	old =3D ie;
 	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
 		sc->gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock external\n",
 			       LMC_PRINTF_ARGS);
 	} else {
 		sc->gpio |=3D LMC_GEP_SSI_TXCLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->gpio);
+		csr_write(sc, CSR_GPIO, sc->gpio);
 		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 		if (old !=3D ie)
 			printk(LMC_PRINTF_FMT ": clock internal\n",
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index f62f9a1..582f00e 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -32,56 +32,36 @@
 #define LMC_LINK_UP		1
 #define LMC_LINK_DOWN		0
=20
-/* These macros for generic read and write to and from the dec chip */
-#define LMC_CSR_READ(sc, csr)		inl((sc)->csrs.csr)
-#define LMC_CSR_WRITE(sc, reg, val)	outl((val), (sc)->csrs.reg)
-
-#define lmc_delay()		inl(sc->csrs.csr_9)
-
 /* This macro sync's up with the mii so that reads and writes can take=
 place */
-#define LMC_MII_SYNC(sc)					\
-	do {							\
-		int n =3D 32;					\
-		while (n >=3D 0) {				\
-			LMC_CSR_WRITE((sc), csr_9, 0x20000);	\
-			lmc_delay();				\
-			LMC_CSR_WRITE((sc), csr_9, 0x30000);	\
-			lmc_delay();				\
-			n--;					\
-		}						\
+#define LMC_MII_SYNC(sc)						\
+	do {								\
+		int n =3D 32;						\
+		while (n >=3D 0) {					\
+			csr_write((sc), CSR_SROM_MII, 0x20000);		\
+			lmc_delay();					\
+			csr_write((sc), CSR_SROM_MII, 0x30000);		\
+			lmc_delay();					\
+			n--;						\
+		}							\
 	} while (0)
=20
-struct lmc_regfile_t {
-	lmc_csrptr_t csr_busmode;	/* CSR0 */
-	lmc_csrptr_t csr_txpoll;	/* CSR1 */
-	lmc_csrptr_t csr_rxpoll;	/* CSR2 */
-	lmc_csrptr_t csr_rxlist;	/* CSR3 */
-	lmc_csrptr_t csr_txlist;	/* CSR4 */
-	lmc_csrptr_t csr_status;	/* CSR5 */
-	lmc_csrptr_t csr_command;	/* CSR6 */
-	lmc_csrptr_t csr_intr;		/* CSR7 */
-	lmc_csrptr_t csr_missed_frames;	/* CSR8 */
-	lmc_csrptr_t csr_9;		/* CSR9 */
-	lmc_csrptr_t csr_10;		/* CSR10 */
-	lmc_csrptr_t csr_11;		/* CSR11 */
-	lmc_csrptr_t csr_12;		/* CSR12 */
-	lmc_csrptr_t csr_13;		/* CSR13 */
-	lmc_csrptr_t csr_14;		/* CSR14 */
-	lmc_csrptr_t csr_15;		/* CSR15 */
-};
-
-#define csr_enetrom		csr_9	/* 21040 */
-#define csr_reserved		csr_10	/* 21040 */
-#define csr_full_duplex		csr_11	/* 21040 */
-#define csr_bootrom		csr_10	/* 21041/21140A/?? */
-#define csr_gp			csr_12	/* 21140* */
-#define csr_watchdog		csr_15	/* 21140* */
-#define csr_gp_timer		csr_11	/* 21041/21140* */
-#define csr_srom_mii		csr_9	/* 21041/21140* */
-#define csr_sia_status		csr_12	/* 2104x */
-#define csr_sia_connectivity	csr_13	/* 2104x */
-#define csr_sia_tx_rx		csr_14	/* 2104x */
-#define csr_sia_general		csr_15	/* 2104x */
+/* DC21140 CSRs */
+#define CSR_BUSMODE		0
+#define CSR_TXPOLL		1
+#define CSR_RXPOLL		2
+#define CSR_RXLIST		3
+#define CSR_TXLIST		4
+#define CSR_STATUS		5
+#define CSR_COMMAND		6 /* operation mode */
+#define CSR_INTR		7
+#define CSR_MISSED_FRAMES	8
+#define CSR_SROM_MII		9
+/* #define CSR_RESERVED		10 */
+#define CSR_GP_TIMER		11
+#define CSR_GPIO		12
+/* #define CSR_RESERVED		13 */
+/* #define CSR_RESERVED		14 */
+#define CSR_WATCHDOG		15
=20
 /* tulip length/control transmit descriptor definitions used to define=
 bits
    in the second tulip_desc_t field (length) for the transmit descript=
or */
@@ -270,10 +250,8 @@ typedef struct lmc_xinfo {
 struct card {
 	struct lmc_extra_statistics extra_stats;
 	struct net_device *netdev;
-
-	struct lmc_regfile_t csrs;
-	u32 intrmask;		/* our copy of csr_intr */
-	u32 cmdmode;		/* our copy of csr_cmdmode */
+	u32 intrmask;		/* our copy of CSR_INTR */
+	u32 cmdmode;		/* our copy of CSR_COMMAND */
 	u32 gpio_io;		/* state of in/out settings */
 	u32 gpio;		/* state of outputs */
 	struct sk_buff *txq[LMC_TXDESCS];
@@ -421,6 +399,19 @@ static inline void lmc_trace(struct net_device *de=
v, char *msg)
 #endif
 }
=20
+/* These macros for generic read and write to and from the dec chip */
+static inline u32 csr_read(struct card *sc, int csr)
+{
+	return inl(sc->netdev->base_addr + 8 * csr);
+}
+
+static inline void csr_write(struct card *sc, int csr, u32 val)
+{
+	outl(val, sc->netdev->base_addr + 8 * csr);
+}
+
+#define lmc_delay()		csr_read(sc, CSR_SROM_MII);
+
=20
 void lmc_led_on(struct card * const, u32);
 void lmc_led_off(struct card * const, u32);
--=20
1.7.1.1

