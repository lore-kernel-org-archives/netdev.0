From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Tue, 6 May 2014 11:39:24 -0700
Message-ID: <CAGVrzcZBPmcmZAdcmFd7mZ97hsHe0UTArpo0ta0Si3sdfYuSgA@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <20140506181151.GU28564@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brian Lilly <brian@crystalfontz.com>,
	"David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:48499 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaEFSkG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:40:06 -0400
In-Reply-To: <20140506181151.GU28564@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-06 11:11 GMT-07:00 Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengu=
tronix.de>:
> Hello Brian,
>
> On Tue, May 06, 2014 at 09:44:34AM -0700, Brian Lilly wrote:
>> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having et=
h0
>> come up, then brought right back down with an MDIO rx timeout moment=
s
>> after.  Adding back in the removed code keeps the interface alive an=
d
>> it's working afterward without trouble.  I've tested the re-inserted
>> code in 3.12, 3.14 without issue on our boards.
> So you can reliably trigger that problem? You're just doing
>
>         ifconfig eth0 1.2.3.4 up
>
> (or equivalent) and the interface goes down without further
> interference with the above mentioned commit? The exact error you're
> seeing is
>
>         MDIO read timeout
>
> (with some prefix saying something about fec and eth0 I think)?
>
> This error is also present with a264b981f2 reverted, just doesn't aff=
ect
> eth0 being functional? Does the timeout always happen, or only on
> specific addresses?
>
> This is not a proper fix, but does it help to increment FEC_MII_TIMEO=
UT?
>
>> Is there something else that can be done to prevent the MDIO timeout=
s?
>> We are using basically the same schematic for networking as the
>> imx28evk.
> Hard to say, but assuming it works just fine on the imx28evk for you,
> too, there seems to be some hardware difference that makes your machi=
ne
> fail. (That doesn't mean it's not fixable in software.)
>
> I don't know if a mdio read error is intended to make the device go
> down, maybe one the the netdev guys can answer that.

What is likely happening is that you are failing auto-negotiation
(phy_read_status return < 0) because of the MDIO timeout, so we never
call netif_carrier_on(), and so the link is not UP. The reason for
that could be a genuine MDIO read timeout from the bus, or your PHY
might be slightly bogus and need more time to complete
auto-negotiation, or anything that ressembles that. There is some
special MDIO timeout logic in the FEC driver that I would seriously
audit as it seems to be bogus, or it seems at the very least that the
MDIO timeouts are known and need to be worked around.

> Assuming that it's not intended, instrument the code, find out how th=
at
> timeout makes your device go down and find the wrong branch. I'd star=
t
> with adding stackdumps when the mdio timeout happens and when
> fec_enet_start_xmit is called with fep->link =3D=3D 0.

I would also double check fec_enet_adjust_link() which seems to handle
a case where we have a MDIO bus timeout, and tries to do something
that looks incorrect to me. PHY_HALTED basically corresponds to
phy_stop() being called, which means that you won't be running the
adjust_link callback, so I wonder how this situation is actually
happening.

>
> Best regards
> Uwe
>
> --
> Pengutronix e.K.                           | Uwe Kleine-K=C3=B6nig   =
         |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
=46lorian
