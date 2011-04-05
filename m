From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NETIF_F_TSO vs NETIF_F_TSO{6,_ECN}
Date: Tue, 05 Apr 2011 19:31:38 +0100
Message-ID: <1302028298.2932.76.camel@bwh-desktop>
References: <1302018602.2932.22.camel@bwh-desktop>
	 <20110405180337.GA16977@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18666 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994Ab1DESbl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:31:41 -0400
In-Reply-To: <20110405180337.GA16977@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-05 at 20:03 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Apr 05, 2011 at 04:50:02PM +0100, Ben Hutchings wrote:
> > According to the commit that introduced NETIF_F_TSO6
> > (f83ef8c0b58dac17211a4c0b6df0e2b1bd6637b1):
> >    =20
> >         This patch will introduce a new flag NETIF_F_TSO6 which wil=
l be used
> >         to check whether device supports TSO over IPv6. If device s=
upport TSO
> >         over IPv6 then we don't clear of NETIF_F_TSO and which will=
 make the
> >         TCP layer to create TSO packets. Any device supporting TSO =
over IPv6
> >         will set NETIF_F_TSO6 flag in "dev->features" along with NE=
TIF_F_TSO.
> >    =20
> >         In case when user disables TSO using ethtool, NETIF_F_TSO w=
ill get
> >         cleared from "dev->features". So even if we have NETIF_F_TS=
O6 we don't
> >         get TSO packets created by TCP layer.
> >=20
> > So I think we need to either:
> > 1. Disallow toggling NETIF_F_TSO6 (following the previous rule)
> > 2. Disable NETIF_F_TSO6 when NETIF_F_TSO is disabled
> >=20
> > The same presumably applies to NETIF_F_TSO_ECN.
>=20
> There seems to be no such dependency in the networking code. I.e. TSO=
6
> should just work with TSO4 disabled.

*sigh*  So it seems the commit message was wrong... and it should have
included a change like this:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5203,9 +5203,9 @@ u32 netdev_fix_features(struct net_device *dev, u=
32 features)
 	}
=20
 	/* TSO requires that SG is present as well. */
-	if ((features & NETIF_F_TSO) && !(features & NETIF_F_SG)) {
-		netdev_info(dev, "Dropping NETIF_F_TSO since no SG feature.\n");
-		features &=3D ~NETIF_F_TSO;
+	if ((features & NETIF_F_ALL_TSO) && !(features & NETIF_F_SG)) {
+		netdev_info(dev, "Dropping TSO since no SG feature.\n");
+		features &=3D ~NETIF_F_ALL_TSO;
 	}
=20
 	/* Software GSO depends on SG. */
---

Now that we're relying on these checks for dynamic changes to features,
this is pretty important.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

