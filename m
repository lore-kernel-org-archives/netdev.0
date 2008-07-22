From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: bug: mutex_lock() in interrupt conntext via phy_stop() in
	gianfar
Date: Tue, 22 Jul 2008 09:54:26 +0200
Message-ID: <20080722075426.GA4302@pengutronix.de>
References: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: Andy Fleming <afleming@freescale.com>,
	Nate Case <ncase@xes-inc.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:44226 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752012AbYGVHyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 03:54:35 -0400
Content-Disposition: inline
In-Reply-To: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Jul 18, 2008 at 02:10:08PM +0200, Sebastian Siewior wrote:
> Commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially sleep=
ing]
> changed the phydev->lock from spinlock into a mutex. Now, the following
> code path got triggered while NFS was unavailable:
[...]
> I found out that the same code path may be trigger in
> - drivers/net/ucc_geth.c
> - drivers/net/fec_mpc52xx.c

Recently, I described a (I think) similar problem:
(http://ozlabs.org/pipermail/linuxppc-dev/2008-July/059686.html)

=3D=3D=3D

Hello,

today, I was debugging a kernel crash on a board with a MPC5200B using
2.6.26-rc9. I found the following code in drivers/net/fec_mpc52xx.c:

static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
{
[...]
	/* on fifo error, soft-reset fec */
	if (ievent & (FEC_IEVENT_RFIFO_ERROR | FEC_IEVENT_XFIFO_ERROR)) {

		if (net_ratelimit() && (ievent & FEC_IEVENT_RFIFO_ERROR))
			dev_warn(&dev->dev, "FEC_IEVENT_RFIFO_ERROR\n");
		if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
			dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");

		mpc52xx_fec_reset(dev);

		netif_wake_queue(dev);
		return IRQ_HANDLED;
	}
[...]
}

Calling mpc52xx_fec_reset() from interrupt context is bad, at least
because

a) it calls phy_write, which contains BUG_ON(in_interrupt())
b) it calls mpc52xx_fec_hw_init, which has a delay-loop to check
   if the reset was successful (1..50 us)

I assume the proper thing to do is to set a flag in the ISR and handle
the soft reset later in some other context. Having never dealt with the
network core and its drivers so far, I am not sure which place would be
the right one to perform the soft reset. To not make things worse, I
hope people with more insight to network stuff can deliver a suitable
solution to this problem.

All the best,

   Wolfram

=3D=3D=3D

--=20
  Dipl.-Ing. Wolfram Sang | http://www.pengutronix.de
 Pengutronix - Linux Solutions for Science and Industry

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIhZIyD27XaX1/VRsRAl+KAJ90tZ1gf9X/tcn0nCEDFlph/voN8QCgrqaA
1NJ/UcRX7VoBXF7k8TjrfvE=
=IA10
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
