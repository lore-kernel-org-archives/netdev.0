From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Sun, 11 Mar 2007 12:16:16 +0000
Message-ID: <20070311121615.GF8133@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cpvLTH7QU4gwfq3S"
Cc: Mark Huth <mhuth@mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:4846 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933279AbXCKMVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 08:21:22 -0400
Content-Disposition: inline
In-Reply-To: <45F31421.4010908@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--cpvLTH7QU4gwfq3S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Mar 10, 2007 at 11:25:05PM +0300, Sergei Shtylyov wrote:

>    Oops, I was going to recast the patch but my attention switched=20
>    elsewhere for couple of days, and it "slipped" into mainline. I'm now=
=20
> preparing a better patch to also protect...

Ah, I was also looking at it.  I enclose my current patch which appears
to work although I have not finished testing it yet.

> >interrupt handler, check the dev->state __LINK_STATE_SCHED flag - if=20
> >it's set, leave immediately, it can't be our interrupt. If it's clear,=
=20
> >read the irq enable hardware register.  If enabled, do the rest of the=
=20
> >interrupt handler.

>    It seems that there's no need to read it, as it gets set to 0=20
> "synchronously" with setting the 'hands_off' flag (except in NAPI=20
> callback)...

hands_off is stronger than that - it's used for sync with some of the
other code paths like suspend/resume and means "don't touch the chip".
I've added a new driver local flag instead.

>    Yeah, it seems currently unjustified.  However IntrEnable would have=
=20
>    been an ultimate criterion on taking or ignoring an interrupt otherwis=
e...

> >I guess the tradeoff depends on the probability=20
> >of getting the isr called when NAPI is active for the device.

>    Didn't get it... :-/

Some systems can provoke this fairly easily - Sokeris have some boards
where at least three natsemis share a single interrupt line, for example
(the model I'm looking at has three, they look to have another
configuration where 5 would end up on the line).

>    BTW, it seems I've found another interrupt lossage path in the driver:

> netdev_poll() -> netdev_rx() -> reset_rx()

> If the netdev_rx() detects an oversized packet, it will call reset_rx()=
=20
> which will spin in a loop "collecting" interrupt status until it sees=20
> RxResetDone there.  The issue is 'intr_status' field will get overwritten=
=20
> and interrupt status lost after netdev_rx() returns to netdev_poll().  Ho=
w=20
> do you think, is this corner case worth fixing (by moving netdev_rx() call
> to the top of a do/while loop)?

Moving netdev_rx() would fix that one but there's some others too -
there's one in the timer routine if the chip crashes.  In the case you
describe above the consequences shouldn't be too bad since it tends to
only occur at high volume so further traffic will tend to occur and
cause things to recover - all the testing of that patch was done with
the bug present and no ill effects.

Subject: natsemi: Fix NAPI for interrupt sharing
To: Jeff Garzik <jeff@garzik.org>
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, Simon Blake <simon@citylink.=
co.nz>, John Philips <johnphilips42@yahoo.com>, netdev@vger.kernel.org

The interrupt status register for the natsemi chips is clear on read and
was read unconditionally from both the interrupt and from the NAPI poll
routine, meaning that if the interrupt service routine was called (for=20
example, due to a shared interrupt) while a NAPI poll was scheduled
interrupts could be missed.  This patch fixes that by ensuring that the
interrupt status register is only read when there is no poll scheduled.

It also reverts a workaround for this problem from the netpoll hook.

Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the
issue and Simon Blake <simon@citylink.co.nz> for testing resources.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

Index: linux-2.6/drivers/net/natsemi.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/natsemi.c	2007-03-11 02:32:43.000000000 +0000
+++ linux-2.6/drivers/net/natsemi.c	2007-03-11 12:09:14.000000000 +0000
@@ -571,6 +571,8 @@
 	int oom;
 	/* Interrupt status */
 	u32 intr_status;
+	int poll_active;
+	spinlock_t intr_lock;
 	/* Do not touch the nic registers */
 	int hands_off;
 	/* Don't pay attention to the reported link state. */
@@ -812,9 +814,11 @@
 	pci_set_drvdata(pdev, dev);
 	np->iosize =3D iosize;
 	spin_lock_init(&np->lock);
+	spin_lock_init(&np->intr_lock);
 	np->msg_enable =3D (debug >=3D 0) ? (1<<debug)-1 : NATSEMI_DEF_MSG;
 	np->hands_off =3D 0;
 	np->intr_status =3D 0;
+	np->poll_active =3D 0;
 	np->eeprom_size =3D natsemi_pci_info[chip_idx].eeprom_size;
 	if (natsemi_pci_info[chip_idx].flags & NATSEMI_FLAG_IGNORE_PHY)
 		np->ignore_phy =3D 1;
@@ -1406,6 +1410,8 @@
 	writel(rfcr, ioaddr + RxFilterAddr);
 }
=20
+/* MUST be called so that both NAPI poll and ISR are excluded due to
+ * use of intr_status. */
 static void reset_rx(struct net_device *dev)
 {
 	int i;
@@ -2118,30 +2124,45 @@
 	struct net_device *dev =3D dev_instance;
 	struct netdev_private *np =3D netdev_priv(dev);
 	void __iomem * ioaddr =3D ns_ioaddr(dev);
+	unsigned long flags;
+	irqreturn_t status =3D IRQ_NONE;
=20
 	if (np->hands_off)
 		return IRQ_NONE;
=20
-	/* Reading automatically acknowledges. */
-	np->intr_status =3D readl(ioaddr + IntrStatus);
-
-	if (netif_msg_intr(np))
-		printk(KERN_DEBUG
-		       "%s: Interrupt, status %#08x, mask %#08x.\n",
-		       dev->name, np->intr_status,
-		       readl(ioaddr + IntrMask));
+	spin_lock_irqsave(&np->intr_lock, flags);
=20
-	if (!np->intr_status)
-		return IRQ_NONE;
+	/* Reading IntrStatus automatically acknowledges so don't do
+	 * that while a poll is scheduled.  */
+	if (!np->poll_active) {
+		np->intr_status =3D readl(ioaddr + IntrStatus);
=20
-	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
+		if (netif_msg_intr(np))
+			printk(KERN_DEBUG
+			       "%s: Interrupt, status %#08x, mask %#08x.\n",
+			       dev->name, np->intr_status,
+			       readl(ioaddr + IntrMask));
+
+		if (np->intr_status) {
+			prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
+
+			/* Disable interrupts and register for poll */
+			if (netif_rx_schedule_prep(dev)) {
+				natsemi_irq_disable(dev);
+				__netif_rx_schedule(dev);
+				np->poll_active =3D 1;
+			} else
+				printk(KERN_WARNING
+			       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
+				       dev->name, np->intr_status,
+				       readl(ioaddr + IntrMask));
=20
-	if (netif_rx_schedule_prep(dev)) {
-		/* Disable interrupts and register for poll */
-		natsemi_irq_disable(dev);
-		__netif_rx_schedule(dev);
+			status =3D IRQ_HANDLED;
+		}
 	}
-	return IRQ_HANDLED;
+
+	spin_unlock_irqrestore(&np->intr_lock, flags);
+	return status;
 }
=20
 /* This is the NAPI poll routine.  As well as the standard RX handling
@@ -2154,8 +2175,15 @@
=20
 	int work_to_do =3D min(*budget, dev->quota);
 	int work_done =3D 0;
+	unsigned long flags;
=20
 	do {
+		if (netif_msg_intr(np))
+			printk(KERN_DEBUG
+			       "%s: Poll, status %#08x, mask %#08x.\n",
+			       dev->name, np->intr_status,
+			       readl(ioaddr + IntrMask));
+
 		if (np->intr_status &
 		    (IntrTxDone | IntrTxIntr | IntrTxIdle | IntrTxErr)) {
 			spin_lock(&np->lock);
@@ -2182,14 +2210,19 @@
 		np->intr_status =3D readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
=20
+	/* We need to ensure that the ISR doesn't run between telling
+	 * NAPI we're done and enabling the interrupt. */
+	spin_lock_irqsave(&np->intr_lock, flags);
+
 	netif_rx_complete(dev);
+	np->poll_active =3D 0;
=20
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
-	spin_lock(&np->lock);
-	if (!np->hands_off && netif_running(dev))
+	if (!np->hands_off)
 		natsemi_irq_enable(dev);
-	spin_unlock(&np->lock);
+
+	spin_unlock_irqrestore(&np->intr_lock, flags);
=20
 	return 0;
 }
@@ -2399,19 +2432,8 @@
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void natsemi_poll_controller(struct net_device *dev)
 {
-	struct netdev_private *np =3D netdev_priv(dev);
-
 	disable_irq(dev->irq);
-
-	/*
-	 * A real interrupt might have already reached us at this point
-	 * but NAPI might still haven't called us back.  As the interrupt
-	 * status register is cleared by reading, we should prevent an
-	 * interrupt loss in this case...
-	 */
-	if (!np->intr_status)
-		intr_handler(dev->irq, dev);
-
+	intr_handler(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif

--=20
"You grabbed my hand and we fell into it, like a daydream - or a fever."



--cpvLTH7QU4gwfq3S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRfPzCw2erOLNe+68AQLIuAP8C3Q42GCR9DykmhjjznRe3Mn0ohoTiThA
SsFC2wQ11vUzefNGRauLnLgpwL4cjX0KuLs9raZaePJkHycchVM1Gh9kEHCZ2tv/
tFEYr4vyHyyRTs6jv1dRt+oMunWVvvs4eEcIfkDOlWlo9uVfjZgji9VVxVgDn+dJ
48j7CwKHAjM=
=7SqR
-----END PGP SIGNATURE-----

--cpvLTH7QU4gwfq3S--
