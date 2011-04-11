From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Mon, 11 Apr 2011 08:00:09 -0700
Message-ID: <20110411080009.72c37538@nehalam>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
	<20110410115302.450794c7@nehalam>
	<20110411005100.GA22103@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43842 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753972Ab1DKPAl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 11:00:41 -0400
In-Reply-To: <20110411005100.GA22103@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2011 02:51:00 +0200
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> On Sun, Apr 10, 2011 at 11:53:02AM -0700, Stephen Hemminger wrote:
> > On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
> > Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:
> > > Caveats:
> > >  - driver modifies vlan_features on HW VLAN TX changes
> > >  - broken RX checksum will be reenabled on features change
> > To be more precise. This is acceptable if and only if all cases
> > where features are disabled in response to MTU and chip versions
> > are exactly the same. We don't want to let some user stumble upon
> > cases where hardware features don't work in their configuration.
>=20
> I was referring to the unlikely case detected by sky2_rx_checksum().
> Before this conversion, user could reenable the feature using ethtool=
=2E
> The change is that now, in this case, it's reenabled also when other
> features are changed (i.e. whenever netdev_update_features() gets cal=
led).
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw

Ok.

It does expose a pre-existing issue. If this logic trips (and I have
gotten reports of it happening), then the GRO will not get disabled.
Probably need to mask of GRO as well, since GRO depends on RXCSUM.

--- a/drivers/net/sky2.c	2011-04-11 07:56:50.569361209 -0700
+++ b/drivers/net/sky2.c	2011-04-11 07:57:34.502312648 -0700
@@ -2538,7 +2538,7 @@ static void sky2_rx_checksum(struct sky2
 		 * It will be reenabled on next ndo_set_features, but if it's
 		 * really broken, will get disabled again
 		 */
-		sky2->netdev->features &=3D ~NETIF_F_RXCSUM;
+		sky2->netdev->features &=3D ~(NETIF_F_RXCSUM | NETIF_F_GRO);
 		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
 			     BMU_DIS_RX_CHKSUM);
 	}
