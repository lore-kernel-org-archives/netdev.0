From: Mark Brown <broonie@sirena.org.uk>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Tue, 13 Mar 2007 00:14:43 +0000
Message-ID: <20070313001442.GD21302@sirena.org.uk>
References: <200703052310.08359.sshtylyov@ru.mvista.com> <20070305224358.GB16290@sirena.org.uk> <45ECE9AC.3090804@mvista.com> <45F31421.4010908@ru.mvista.com> <20070311121615.GF8133@sirena.org.uk> <45F5A48A.8040903@mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yudcn1FV7Hsu/q59"
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:3929 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbXCMAPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 20:15:10 -0400
Content-Disposition: inline
In-Reply-To: <45F5A48A.8040903@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yudcn1FV7Hsu/q59
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Mar 12, 2007 at 12:05:46PM -0700, Mark Huth wrote:

> Since the interrupts are enabled as the NAPI-callback exits, and the=20
> interrupts are disabled in the isr after the callback is scheduled, this=
=20
> fully avoids the potential race conditions, and requires no locking.  If=
=20

I've benchmarked both approaches and they appear to be much of a
muchness for performance in my tests so I've updated my patch to use
this approach instead.  Thanks for the suggestion, it is simpler.

> If you would like me to prepare formal patches based on any of these=20
> concepts, let me know.

That's OK - unless any further suggestions I'll submit the patch below
after further testing.  The improvements to trace and correctness of the
interupt handler seem useful.

Subject: natsemi: Fix NAPI for interrupt sharing

The interrupt status register for the natsemi chips is clear on read and
was read unconditionally from both the interrupt and from the NAPI poll
routine, meaning that if the interrupt service routine was called (for=20
example, due to a shared interrupt) while a NAPI poll was scheduled
interrupts could be missed.  This patch fixes that by ensuring that the
interrupt status register is only read by the interrupt handler when
interrupts are enabled from the chip.

It also reverts a workaround for this problem from the netpoll hook and
improves the trace for interrupt events.

Thanks to Sergei Shtylyov <sshtylyov@ru.mvista.com> for spotting the
issue, Mark Huth <mhuth@mvista.com> for a simpler method and Simon
Blake <simon@citylink.co.nz> for testing resources.

Signed-Off-By: Mark Brown <broonie@sirena.org.uk>

Index: linux-2.6/drivers/net/natsemi.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/natsemi.c	2007-03-11 02:32:43.000000000 +0000
+++ linux-2.6/drivers/net/natsemi.c	2007-03-13 00:12:29.000000000 +0000
@@ -2119,10 +2119,12 @@
 	struct netdev_private *np =3D netdev_priv(dev);
 	void __iomem * ioaddr =3D ns_ioaddr(dev);
=20
-	if (np->hands_off)
+	/* Reading IntrStatus automatically acknowledges so don't do
+	 * that while interrupts are disabled, (for example, while a
+	 * poll is scheduled).  */
+	if (np->hands_off || !readl(ioaddr + IntrEnable))
 		return IRQ_NONE;
=20
-	/* Reading automatically acknowledges. */
 	np->intr_status =3D readl(ioaddr + IntrStatus);
=20
 	if (netif_msg_intr(np))
@@ -2131,17 +2133,23 @@
 		       dev->name, np->intr_status,
 		       readl(ioaddr + IntrMask));
=20
-	if (!np->intr_status)
-		return IRQ_NONE;
-
-	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
+	if (np->intr_status) {
+		prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
=20
-	if (netif_rx_schedule_prep(dev)) {
 		/* Disable interrupts and register for poll */
-		natsemi_irq_disable(dev);
-		__netif_rx_schedule(dev);
+		if (netif_rx_schedule_prep(dev)) {
+			natsemi_irq_disable(dev);
+			__netif_rx_schedule(dev);
+		} else
+			printk(KERN_WARNING
+		       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
+			       dev->name, np->intr_status,
+			       readl(ioaddr + IntrMask));
+
+		return IRQ_HANDLED;
 	}
-	return IRQ_HANDLED;
+
+	return IRQ_NONE;
 }
=20
 /* This is the NAPI poll routine.  As well as the standard RX handling
@@ -2156,6 +2164,12 @@
 	int work_done =3D 0;
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
@@ -2399,19 +2413,8 @@
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

--yudcn1FV7Hsu/q59
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iQCVAwUBRfXs7w2erOLNe+68AQK0hgP/aHZDyom8XZJYU26AWXuzUJzexjTta0Gl
ZkWENiVVXhTA2OUIyDVUML2u/cIpc7hhmcKdS/mW6HqBIlVlrYAjTaPx/qrWEt3+
sd2HGeHKvR4DJXO+d9gWGf8co2BHftTkiLkso7qszkG4v1MhSXJyLAn/hUrK909U
G1E5DlMp1gc=
=mmra
-----END PGP SIGNATURE-----

--yudcn1FV7Hsu/q59--
