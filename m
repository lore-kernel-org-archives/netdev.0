From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: Please backport asix (USB Ethernet) fixes
Date: Mon, 19 Oct 2015 11:22:48 +0100
Message-ID: <20151019102248.GC3424@ares>
References: <1444061376.5302.21.camel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@vger.kernel.org, David Miller <davem@davemloft.net>,
	Michel Stam <m.stam@fugro.nl>,
	Charles Keepax <ckeepax@opensource.wolfsonmicro.com>,
	Riku Voipio <riku.voipio@linaro.org>, netdev@vger.kernel.org
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444061376.5302.21.camel@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 05, 2015 at 05:09:36PM +0100, Ian Campbell wrote:
> Hi David + stable@,
>=20
> Please could these two be backported:
> 3cc81d85ee01 "asix: Don't reset PHY on if_up for ASIX 88772"
> 436c2a5036b6 "asix: Do full reset during ax88772_bind"
>=20
> 3cc81d85ee01 was in v3.18-rc1 while 436c2a5036b6 was in v3.18-rc5 so =
both
> should be backported to anything older which still has active longter=
m
> support, please.
>=20
> Our automated test is occasionally tripping over a failure to achieve=
 link
> on the arndale board with 3.16 (both the Debian Jessie kernel used at=
 host
> install time and the 3.16 kernel under test), reporting lots of this:
>     Oct  4 02:01:17.077037 [  411.069293] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:21.037081 [  414.525294] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:24.493057 [  419.773293] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:29.741083 [  423.229292] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:33.197066 [  426.685292] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:36.653128 [  430.141291] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:40.109050 [  440.765293] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:50.733034 [  446.141292] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:01:56.109092 [  471.614170] asix 2-3.2.4:1.0 eth0: link=
 up, 100Mbps, full-duplex, lpa 0xC1E1
>     Oct  4 02:02:21.581182 [  486.973293] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:02:36.941033 [  803.390169] asix 2-3.2.4:1.0 eth0: link=
 up, 100Mbps, full-duplex, lpa 0xC1E1
>     Oct  4 02:07:53.353184 [  805.182045] asix 2-3.2.4:1.0 eth0: link=
 up, 100Mbps, full-duplex, lpa 0xC1E1
>     Oct  4 02:07:55.145152 [  818.109291] asix 2-3.2.4:1.0 eth0: link=
 down
>     Oct  4 02:08:08.073064 [  825.149291] asix 2-3.2.4:1.0 eth0: link=
 down
>=20
> It appears that we no longer see this in 3.18 (although they still us=
e
> Debian's 3.16 at install time, which obscures things a little in the =
data
> mining). These are the only commits to this driver between 3.16 and 3=
=2E18
> and they sound like they might plausibly fix this.
>

Thanks Ian, I'm queuing these 2 commits for the 3.16 kernel.

Cheers,
--
Lu=EDs


> Thanks,
>=20
> Ian.
>=20
> commit 3cc81d85ee01e5a0b7ea2f4190e2ed1165f53c31
> Author: Michel Stam <m.stam@fugro.nl>
> Date:   Thu Oct 2 10:22:02 2014 +0200
>=20
>     asix: Don't reset PHY on if_up for ASIX 88772
>    =20
>     I've noticed every time the interface is set to 'up,', the kernel
>     reports that the link speed is set to 100 Mbps/Full Duplex, even
>     when ethtool is used to set autonegotiation to 'off', half
>     duplex, 10 Mbps.
>     It can be tested by:
>      ifconfig eth0 down
>      ethtool -s eth0 autoneg off speed 10 duplex half
>      ifconfig eth0 up
>    =20
>     Then checking 'dmesg' for the link speed.
>    =20
>     Signed-off-by: Michel Stam <m.stam@fugro.nl>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_de=
vices.c
> index 5d19409..2c05f6c 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -890,7 +890,7 @@ static const struct driver_info ax88772_info =3D =
{
>  	.unbind =3D ax88772_unbind,
>  	.status =3D asix_status,
>  	.link_reset =3D ax88772_link_reset,
> -	.reset =3D ax88772_reset,
> +	.reset =3D ax88772_link_reset,
>  	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MUL=
TI_PACKET,
>  	.rx_fixup =3D asix_rx_fixup_common,
>  	.tx_fixup =3D asix_tx_fixup,
>=20
> commit 436c2a5036b6ffe813310df2cf327d3b69be0734
> Author: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
> Date:   Thu Nov 6 15:49:41 2014 +0000
>=20
>     asix: Do full reset during ax88772_bind
>    =20
>     commit 3cc81d85ee01 ("asix: Don't reset PHY on if_up for ASIX 887=
72")
>     causes the ethernet on Arndale to no longer function. This appear=
s to
>     be because the Arndale ethernet requires a full reset before it w=
ill
>     function correctly, however simply reverting the above patch caus=
es
>     problems with ethtool settings getting reset.
>    =20
>     It seems the problem is that the ethernet is not properly reset d=
uring
>     bind, and indeed the code in ax88772_bind that resets the device =
is a
>     very small subset of the actual ax88772_reset function. This patc=
h uses
>     ax88772_reset in place of the existing reset code in ax88772_bind=
 which
>     removes some code duplication and fixes the ethernet on Arndale.
>    =20
>     It is still possible that the original patch causes some issues w=
ith
>     suspend and resume but that seems like a separate issue and I hav=
en't
>     had a chance to test that yet.
>    =20
>     Signed-off-by: Charles Keepax <ckeepax@opensource.wolfsonmicro.co=
m>
>     Tested-by: Riku Voipio <riku.voipio@linaro.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_de=
vices.c
> index 2c05f6c..816d511 100644
> --- a/drivers/net/usb/asix_devices.c
> +++ b/drivers/net/usb/asix_devices.c
> @@ -465,19 +465,7 @@ static int ax88772_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
>                 return ret;
>         }
> =20
> -       ret =3D asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
> -       if (ret < 0)
> -               return ret;
> -
> -       msleep(150);
> -
> -       ret =3D asix_sw_reset(dev, AX_SWRESET_CLEAR);
> -       if (ret < 0)
> -               return ret;
> -
> -       msleep(150);
> -
> -       ret =3D asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SW=
RESET_PRTE);
> +       ax88772_reset(dev);
> =20
>         /* Read PHYID register *AFTER* the PHY was reset properly */
>         phyid =3D asix_get_phyid(dev);
> --
> To unsubscribe from this list: send the line "unsubscribe stable" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
