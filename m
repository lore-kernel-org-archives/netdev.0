From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: PHY hardware reset
Date: Sun, 6 Mar 2016 16:54:47 -0800
Message-ID: <56DCD157.80007@gmail.com>
References: <56DB5924.3020206@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:34980 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbcCGAyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 19:54:50 -0500
Received: by mail-ob0-f173.google.com with SMTP id xx9so92543690obc.2
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 16:54:50 -0800 (PST)
In-Reply-To: <56DB5924.3020206@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2016 14:09, Sergei Shtylyov a =C3=A9crit :
> Hello.
>=20
>    I have a need to de-assert the active-low PHY hardware reset signa=
l
> (mapped to a GPIO) before the MDIO bus scansince it's left asserted b=
y
> the bootloader (U-Boot). I have a device tree probed MAX driver (ravb=
)
> and I'm somewhat at a loss about where and how to do this. The existi=
ng
> example (Freescale FEC) has DT props controlling the PHY reset GPIO i=
n
> the MAC device node but it doesn't seem correct at all since this sig=
nal
> has nothing to do with the MAC, only with PHY!=20

Agreed, it is a property of the PHY, but it should however be utilized
by the MAC (and optionaly the MDIO bus driver) so as to make good
choices when it comes to conserving power.

I therefore would like
> this "phy-reset-gpios" property to be defined under the PHY node but
> this way I'll have to add the handling of this prop to the phylib (it
> would be too late if I did that in a a PHY driver method since that).
> I'm also seeing the mii_bus::reset() method and it seems a good place
> but I'm not sure if my PHY's reset signal can be treated as the reset
> signal for the whole bus; if it would, the DT prop should be placed
> under the MAC node anyway...

The MDIO bus reset callback did not really have a very good definition
for its use, but it seems like an appropriate place to release the PHY
from reset to ensure you will be able to scan and attach its driver to
it. In general the MDIO bus reset callback should be seen as an
opportunity for drivers to implement pre-scanning operations that will
ensure a successful PHY probing/binding.

Whether we would want PHYLIB to be taught about phy-reset-gpios is a
little more debatable, on one hand, anything that could put the PHY int=
o
low power is done there, and it would be consistent to release/put the
PHY into reset, on the other hand, the Ethernet MAC driver is the place
where things like Wake-on-LAN are coordinated, but we can still call
into a phy_set_wol() function to avoid putting the PHY in reset or not.
If there is something sensibly generic to be put in PHYLIB wrt.
phy-reset-gpios, please propose a patch doing so and we can see how muc=
h
=46EC and RAVB need to be changed.

Thanks!
--=20
=46lorian
