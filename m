From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration from device tree
Date: Mon, 10 Feb 2014 09:09:36 -0800
Message-ID: <29007785.iYrLORbRAN@lenovo>
References: <7510122.cayuQ6qt8r@wuerfel> <CAGVrzcZ4TFd=9KP+aoG47QbmqDJ1i23WBcEWDbzNRUfGmPvZHQ@mail.gmail.com> <52F8FB03.6040606@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthew Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
To: Gerlando Falauto <gerlando.falauto-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52F8FB03.6040606-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Gerlando,

Le lundi 10 f=E9vrier 2014, 17:14:59 Gerlando Falauto a =E9crit :
> Hi,
>=20
> I'm currently trying to fix an issue for which this patch provides a
> partial solution, so apologies in advance for jumping into the
> discussion for my own purposes...
>=20
> On 02/04/2014 09:39 PM, Florian Fainelli wrote:> 2014-01-17 Matthew
>=20
> Garrett <matthew.garrett-05XSO3Yj/JvQT0dZR+AlfA@public.gmane.org>:
>  >> Some hardware may be broken in interesting and board-specific way=
s, such
>  >> that various bits of functionality don't work. This patch provide=
s a
>  >> mechanism for overriding mii registers during init based on the
>=20
> contents of
>=20
>  >> the device tree data, allowing board-specific fixups without havi=
ng to
>  >> pollute generic code.
>  >=20
>  > It would be good to explain exactly how your hardware is broken
>  > exactly. I really do not think that such a fine-grained setting wh=
ere
>  > you could disable, e.g: 100BaseT_Full, but allow 100BaseT_Half to
>  > remain usable makes that much sense. In general, Gigabit might be
>  > badly broken, but 100 and 10Mbits/sec should work fine. How about =
the
>  > MASTER-SLAVE bit, is overriding it really required?
>  >=20
>  > Is not a PHY fixup registered for a specific OUI the solution you =
are
>  > looking for? I am also concerned that this creates PHY troubleshoo=
ting
>  > issues much harder to debug than before as we may have no idea abo=
ut
>  > how much information has been put in Device Tree to override that.
>  >=20
>  > Finally, how about making this more general just like the BCM87xx =
PHY
>  > driver, which is supplied value/reg pairs directly? There are 16
>  > common MII registers, and 16 others for vendor specific registers,
>  > this is just covering for about 2% of the possible changes.
>=20
> Good point. That would easily help me with my current issue, which
> requires autoneg to be disabled to begin with (by clearing BMCR_ANENA=
BLE
> from register 0).

Is there a point in time (e.g: after some specific initial configuratio=
n has=20
been made) where BMCR_ANENABLE can be used?

> This would not however fix it entirely (I tried a quick hardwired
> implementation), as the whole PHY machinery would not take that into
> account and would re-enable autoneg anyway.
> I also tried changing the patch so that phydev->support gets updated

There are multiple things that you could try doing here:

- override the PHY state machine in your read_status callback to make s=
ure=20
that you always set phydev->autoneg set to AUTONEG_ENABLE

- clear the SUPPORTED_Autoneg bits from phydev->supported right after P=
HY=20
registration and before the call to phy_start()

- set the PHY_HAS_MAGICANEG bit in your PHY driver flag

>=20
> (instead of phydev->advertising):
>  >> +               if (!of_property_read_u32(np, override->prop, &tm=
p)) {
>  >> +                       if (tmp) {
>  >> +                               *val |=3D override->value;
>  >> +                               phydev->advertising |=3D
>=20
> override->supported;
>=20
>  >> +                       } else {
>  >> +                               phydev->advertising &=3D
>=20
> ~(override->supported);
>=20
>  >> +                       }
>  >> +
>  >> +                       *mask |=3D override->value;
>=20
> What I find weird is that the only way phydev->autoneg could ever be =
set
> to disabled is from here (phy.c):
>=20
> static void phy_sanitize_settings(struct phy_device *phydev)
> {
> 	u32 features =3D phydev->supported;
> 	int idx;
>=20
> 	/* Sanitize settings based on PHY capabilities */
> 	if ((features & SUPPORTED_Autoneg) =3D=3D 0)
> 		phydev->autoneg =3D AUTONEG_DISABLE;
>=20
> which is in turn only called when phydev->autoneg is set to
> AUTONEG_DISABLE to begin with:
>=20
> int phy_start_aneg(struct phy_device *phydev)
> {
> 	int err;
>=20
> 	mutex_lock(&phydev->lock);
>=20
> 	if (AUTONEG_DISABLE =3D=3D phydev->autoneg)
> 		phy_sanitize_settings(phydev);
>=20
> So could someone please help me figure out what I'm missing here?

At first glance it looks like the PHY driver should be reading the phyd=
ev-
>autoneg value when the PHY driver config_aneg() callback is called to =
be=20
allowed to set the forced speed and settings.

The way phy_sanitize_settings() is coded does not make it return a mask=
 of=20
features, but only the forced supported speed and duplex. Then when the=
 link=20
is forced but we are having some issues getting a link status, libphy t=
ries=20
lower speeds and this function is used again to provide the next speed/=
duplex=20
pair to try.
--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
