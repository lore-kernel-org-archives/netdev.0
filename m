From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 05/10] net/fec: add dual fec support for mx28
Date: Fri, 14 Jan 2011 13:48:40 +0800
Message-ID: <20110114054838.GA14491@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-6-git-send-email-shawn.guo@freescale.com>
 <20110113144805.GS24920@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>, <w.sang@pengutronix.de>,
	<s.hauer@pengutronix.de>, <jamie@jamieiles.com>,
	<jamie@shareable.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe006.messaging.microsoft.com ([213.199.154.209]:42396
	"EHLO AM1EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751939Ab1ANFpz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 00:45:55 -0500
Received: from mail47-am1 (localhost.localdomain [127.0.0.1])	by
 mail47-am1-R.bigfish.com (Postfix) with ESMTP id 82BF3E783E6	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 05:45:52 +0000 (UTC)
Received: from AM1EHSMHS006.bigfish.com (unknown [10.3.201.241])	by
 mail47-am1.bigfish.com (Postfix) with ESMTP id 2043B1320051	for
 <netdev@vger.kernel.org>; Fri, 14 Jan 2011 05:45:52 +0000 (UTC)
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by de01egw01.freescale.net (8.14.3/8.14.3) with ESMTP id p0E5jemD021038	for
 <netdev@vger.kernel.org>; Thu, 13 Jan 2011 22:45:40 -0700 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id
 p0E5jdPM026843	for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 23:45:40 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110113144805.GS24920@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Uwe,

On Thu, Jan 13, 2011 at 03:48:05PM +0100, Uwe Kleine-K=F6nig wrote:

[...]

> > +/* Controller is ENET-MAC */
> > +#define FEC_QUIRK_ENET_MAC           (1 << 0)
> does this really qualify to be a quirk?
>=20
My understanding is that ENET-MAC is a type of "quirky" FEC
controller.

> > +/* Controller needs driver to swap frame */
> > +#define FEC_QUIRK_SWAP_FRAME         (1 << 1)
> IMHO this is a bit misnamed.  FEC_QUIRK_NEEDS_BE_DATA or similar woul=
d
> be more accurate.
>=20
When your make this change, you may want to pick a better name for
function swap_buffer too.

[...]

> > +static void *swap_buffer(void *bufaddr, int len)
> > +{
> > +     int i;
> > +     unsigned int *buf =3D bufaddr;
> > +
> > +     for (i =3D 0; i < (len + 3) / 4; i++, buf++)
> > +             *buf =3D cpu_to_be32(*buf);
> if len isn't a multiple of 4 this accesses bytes behind len.  Is this
> generally OK here?  (E.g. because skbs always have a length that is a
> multiple of 4?)
The len may not be a multiple of 4.  But I believe bufaddr is always
a buffer allocated in a length that is a multiple of 4, and the 1~3
bytes exceeding the len very likely has no data that matters.  But
yes, it deserves a safer implementation.

[...]

> > +     /*
> > +      * The dual fec interfaces are not equivalent with enet-mac.
> > +      * Here are the differences:
> > +      *
> > +      *  - fec0 supports MII & RMII modes while fec1 only supports=
 RMII
> > +      *  - fec0 acts as the 1588 time master while fec1 is slave
> > +      *  - external phys can only be configured by fec0
> > +      *
> > +      * That is to say fec1 can not work independently. It only wo=
rks
> > +      * when fec0 is working. The reason behind this design is tha=
t the
> > +      * second interface is added primarily for Switch mode.
> > +      *
> > +      * Because of the last point above, both phys are attached on=
 fec0
> > +      * mdio interface in board design, and need to be configured =
by
> > +      * fec0 mii_bus.
> > +      */
> > +     if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id)=
 {
> > +             /* fec1 uses fec0 mii_bus */
> > +             fep->mii_bus =3D fec0_mii_bus;
> > +             return 0;
> What happens if imx28-fec.1 is probed before imx28-fec.0?
It's something that generally should not happen, as these two fec are
not equivalent, and fec.1 should always be added after fec.0 if you
intend to get dual interfaces.  But yes, we should add error checking
for this case in the driver.

--=20
Regards,
Shawn

