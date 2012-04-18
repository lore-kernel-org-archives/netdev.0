From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Wed, 18 Apr 2012 21:30:47 +0200
Message-ID: <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com> <1334753296.5185.3.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45597 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab2DRTbI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:31:08 -0400
Received: by ghrr11 with SMTP id r11so3935349ghr.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 12:31:07 -0700 (PDT)
In-Reply-To: <1334753296.5185.3.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Maxime,

On 18 April 2012 14:48, Maxime Bizon <mbizon@freebox.fr> wrote:
>
> On Wed, 2012-04-18 at 14:02 +0200, Jonas Gorski wrote:
>
>> Only connect/disconnect the phy during probe and remove, not during =
open
>> and close. The phy seldom changes during the runtime, and disconnect=
ing
>> the phy during close will prevent the phy driver from keeping any
>> configuration over a down/up cycle.
>>
>> Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
>
> please CC me, I wrote this driver

Oops, sorry, that wasn't intentional. I used get_maintainer.pl, which
didn't catch you, and I never checked the actual file. Duly noted for
v2.

>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phydev =3D phy_connect(d=
ev, phy_id, bcm_enet_adjust_phy_link, 0,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0PHY_INTERFACE_MODE_=
MII);
>
> bcm_enet_adjust_link() may modify some dma registers that are reset b=
y
> bcm_enet_open(), since it can now be called after probe, we may end u=
p
> with broken flow control depending on whatever was called first.

I assume you mean bcm_enet_adjust_phy_link()? bcm_enet_adjust_link()
gets only called if there is no phydev.

I have to admit, I fail to see the race (but feel free to correct me):

On boot:

The phy state machine will start in PHY_READY after phy_connect, which
will result in NOPs, so no call to bcm_enet_adjust_phy_link() after
_probe() and before _open(). The state machine starts doing real work
only after calling phy_start(), which happens only after the dma
register accesses in open(). So no race here.

In case of an down/up cycle:

_close() will call phy_stop() first, which will either block until the
current state machine run is complete if there is one, or will block
the next run until it set the state to PHY_HALTED.

When in PHY_HALTED, bcm_enet_adjust_phy_link() will be called once,
but with phy_dev->link =3D 0, and only phy_dev->link =3D 1 can result i=
n
register writes in bcm_enet_adjust_phy_link():

	if (phydev->link && phydev->duplex !=3D priv->old_duplex) {
		bcm_enet_set_duplex(priv,
				    (phydev->duplex =3D=3D DUPLEX_FULL) ? 1 : 0);
		...
	}

	if (phydev->link && phydev->pause !=3D priv->old_pause) {
		...
		bcm_enet_set_flow(priv, rx_pause_en, tx_pause_en);
		...
	}

So no problem there either.

There is a theoretical race in writing to priv->old_link in _open()
and the bcm_enet_adjust_phy_link() call right after phy_stop(), but
since both write the same value to priv->old_link I see no problem
here.


Regards
Jonas
