From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Mon, 14 Sep 2015 12:42:09 +0100
Message-ID: <20150914114209.GL21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:47422 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192AbbINLmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 07:42:21 -0400
Content-Disposition: inline
In-Reply-To: <55F6AA25.2070603@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2015 at 02:06:13PM +0300, Stas Sergeev wrote:
> 14.09.2015 13:32, Russell King - ARM Linux =D0=BF=D0=B8=D1=88=D0=B5=D1=
=82:
> >I've been bringing up the mainline kernel on a new board, which has
> >an Marvell SoC with a mvneta interface connected to a Marvell DSA
> >switch.  The DSA switch is a 88E6176.
> >
> >In the DT block for the interface, I specify:
> >
> >	ethernet@... {
> >	        phy-mode =3D "sgmii";
> >		status =3D "okay";
> >
> >		fixed-link {
> >			speed =3D <1000>;
> >			full-duplex;
> >		};
> >	};
> >
> >However, this doesn't work without patching mvneta to disable the
> >autonegotiation and forcing the link up:
> >
> >diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/eth=
ernet/marvell/mvneta.c
> >index 62e48bc0cb23..e1698731e429 100644
> >--- a/drivers/net/ethernet/marvell/mvneta.c
> >+++ b/drivers/net/ethernet/marvell/mvneta.c
> >@@ -1010,6 +1010,10 @@ static void mvneta_defaults_set(struct mvneta=
_port *pp)
> >  		val |=3D MVNETA_GMAC_INBAND_AN_ENABLE |
> >  		       MVNETA_GMAC_AN_SPEED_EN |
> >  		       MVNETA_GMAC_AN_DUPLEX_EN;
> >+		/* We appear to need the interface forced for DSA switches */
> >+		val &=3D ~(MVNETA_GMAC_AN_DUPLEX_EN |
> >+			 MVNETA_GMAC_AN_SPEED_EN);
> >+		val |=3D MVNETA_GMAC_FORCE_LINK_PASS;
> >  		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
> >  		val =3D mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
> >  		val |=3D MVNETA_GMAC_1MS_CLOCK_ENABLE;
> Hello Russell, just to make sure, aren't you missing this by any chan=
ce:
> https://lkml.org/lkml/2015/7/20/710

Thanks, I think that will solve it.  I have to wonder why that patch
(f8af8e6eb9509 in mainline) didn't made it into v4.2 though, as it's
billed as a regression that occurred in the previous merge window, and
given that it was sent in July, and we're now in September.  As it
wasn't in v4.2, it looks like it should be a stable candidate.

David, any objections to having the stable guys pick this regression
fix up, if not already done so?

--=20
=46TTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
