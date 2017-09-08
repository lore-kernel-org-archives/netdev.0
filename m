From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 11:18:56 +0200
Message-ID: <20170908091856.GB17738@amd>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Cc: andrew@lunn.ch, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu 2017-09-07 21:17:16, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
>=20
> Add KSZ8795 switch support with function code.

English? "Add KSZ8795 switch support." ?

> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/ksz8795.c b/drivers/net/dsa/microc=
hip/ksz8795.c
> new file mode 100644
> index 0000000..e4d4e6a
> --- /dev/null
> +++ b/drivers/net/dsa/microchip/ksz8795.c
> @@ -0,0 +1,2066 @@
> +/*
> + * Microchip KSZ8795 switch driver
> + *
> + * Copyright (C) 2017 Microchip Technology Inc.
> + *	Tristram Ha <Tristram.Ha@microchip.com>
> + *
> + * Permission to use, copy, modify, and/or distribute this software for =
any
> + * purpose with or without fee is hereby granted, provided that the above
> + * copyright notice and this permission notice appear in all copies.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANT=
IES
> + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
> + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE F=
OR
> + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
> + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
> + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT =
OF
> + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
> + */

This is not exactly GPL, right? But tagging below says it is
GPL. Please fix one.

> +/**
> + * Some counters do not need to be read too often because they are less =
likely
> + * to increase much.
> + */

Kerneldoc markup but this does not look like kerneldoc. Use plain /* instea=
d?

> +static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
> +{
> +	u8 data;
> +
> +	ksz_read8(dev, addr, &data);
> +	if (set)
> +		data |=3D bits;
> +	else
> +		data &=3D ~bits;
> +	ksz_write8(dev, addr, data);
> +}
> +
> +static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u=
8 bits,
> +			 bool set)
> +{
> +	u32 addr;
> +	u8 data;
> +
> +	addr =3D PORT_CTRL_ADDR(port, offset);
> +	ksz_read8(dev, addr, &data);
> +
> +	if (set)
> +		data |=3D bits;
> +	else
> +		data &=3D ~bits;
> +
> +	ksz_write8(dev, addr, data);
> +}

Other drivers will need this code, right? Does it make sense to put it
into header?

> +static int chk_last_port(struct ksz_device *dev, int p)
> +{
> +	if (dev->last_port && p =3D=3D dev->last_port)
> +		p =3D dev->cpu_port;
> +	return p;
> +}

We often prefix even static functions with common prefix. Up to you, I
guess.

> +static int ksz_reset_switch(struct ksz_device *dev)
> +{
> +	/* reset switch */
> +	ksz_write8(dev, REG_POWER_MANAGEMENT_1,
> +		   SW_SOFTWARE_POWER_DOWN << SW_POWER_MANAGEMENT_MODE_S);
> +	ksz_write8(dev, REG_POWER_MANAGEMENT_1, 0);
> +
> +	return 0;
> +}

This is going to be same in other drivers, right?

> +
> +	for (timeout =3D 1; timeout > 0; timeout--) {
> +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> +
> +		if (check & MIB_COUNTER_VALID) {
> +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> +			if (addr < 2) {
> +				u64 total;
> +
> +				total =3D check & MIB_TOTAL_BYTES_H;
> +				total <<=3D 32;
> +				*cnt +=3D total;
> +				*cnt +=3D data;
> +				if (check & MIB_COUNTER_OVERFLOW) {
> +					total =3D MIB_TOTAL_BYTES_H + 1;
> +					total <<=3D 32;
> +					*cnt +=3D total;
> +				}
> +			} else {
> +				if (check & MIB_COUNTER_OVERFLOW)
> +					*cnt +=3D MIB_PACKET_DROPPED + 1;
> +				*cnt +=3D data & MIB_PACKET_DROPPED;
> +			}
> +			break;
> +		}
> +	}

Why do you need a loop here? This is quite strange code. (And you have
similar strangeness elsewhere. Please fix.)

> +static int valid_dyn_entry(struct ksz_device *dev, u8 *data)
> +{
> +	int timeout =3D 100;
> +
> +	do {
> +		ksz_read8(dev, REG_IND_DATA_CHECK, data);
> +		timeout--;
> +	} while ((*data & DYNAMIC_MAC_TABLE_NOT_READY) && timeout);
> +
> +	/* Entry is not ready for accessing. */
> +	if (*data & DYNAMIC_MAC_TABLE_NOT_READY) {
> +		return 1;
> +	/* Entry is ready for accessing. */
> +	} else {
> +		ksz_read8(dev, REG_IND_DATA_8, data);
> +
> +		/* There is no valid entry in the table. */
> +		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
> +			return 2;
> +	}
> +	return 0;
> +}

Normal calling convention is 0 / -ERROR, not 0,1,2.

> +static void ksz_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
> +{
> +	struct ksz_port *port;
> +	u8 ctrl;
> +	u8 restart;
> +	u8 link;
> +	u8 speed;
> +	u8 force;
> +	u8 p =3D phy;
> +	u16 data =3D 0;
> +	int processed =3D true;
> +
> +	port =3D &dev->ports[p];
> +	switch (reg) {
> +	case PHY_REG_CTRL:
> +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> +		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
> +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> +		ksz_pread8(dev, p, P_FORCE_CTRL, &force);
> +		if (restart & PORT_PHY_LOOPBACK)
> +			data |=3D PHY_LOOPBACK;
> +		if (force & PORT_FORCE_100_MBIT)
> +			data |=3D PHY_SPEED_100MBIT;
> +		if (!(force & PORT_AUTO_NEG_DISABLE))
> +			data |=3D PHY_AUTO_NEG_ENABLE;
> +		if (restart & PORT_POWER_DOWN)
> +			data |=3D PHY_POWER_DOWN;
> +		if (restart & PORT_AUTO_NEG_RESTART)
> +			data |=3D PHY_AUTO_NEG_RESTART;
> +		if (force & PORT_FORCE_FULL_DUPLEX)
> +			data |=3D PHY_FULL_DUPLEX;
> +		if (speed & PORT_HP_MDIX)
> +			data |=3D PHY_HP_MDIX;
> +		if (restart & PORT_FORCE_MDIX)
> +			data |=3D PHY_FORCE_MDIX;
> +		if (restart & PORT_AUTO_MDIX_DISABLE)
> +			data |=3D PHY_AUTO_MDIX_DISABLE;
> +		if (restart & PORT_TX_DISABLE)
> +			data |=3D PHY_TRANSMIT_DISABLE;
> +		if (restart & PORT_LED_OFF)
> +			data |=3D PHY_LED_DISABLE;
> +		break;
> +	case PHY_REG_STATUS:
> +		ksz_pread8(dev, p, P_LINK_STATUS, &link);
> +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> +		data =3D PHY_100BTX_FD_CAPABLE |
> +			PHY_100BTX_CAPABLE |
> +			PHY_10BT_FD_CAPABLE |
> +			PHY_10BT_CAPABLE |
> +			PHY_AUTO_NEG_CAPABLE;
> +		if (link & PORT_AUTO_NEG_COMPLETE)
> +			data |=3D PHY_AUTO_NEG_ACKNOWLEDGE;
> +		if (link & PORT_STAT_LINK_GOOD) {
> +			data |=3D PHY_LINK_STATUS;
> +			if (!port->link_up) {
> +				port->link_up =3D 1;
> +				dev->live_ports |=3D (1 << phy) & dev->on_ports;
> +			}
> +		} else if (port->link_up) {
> +			port->link_down =3D 1;
> +			port->link_up =3D 0;
> +			dev->live_ports &=3D ~(1 << phy);
> +		}
> +		break;
> +	case PHY_REG_ID_1:
> +		data =3D KSZ8795_ID_HI;
> +		break;
> +	case PHY_REG_ID_2:
> +		data =3D KSZ8795_ID_LO;
> +		break;
> +	case PHY_REG_AUTO_NEGOTIATION:
> +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> +		data =3D PHY_AUTO_NEG_802_3;
> +		if (ctrl & PORT_AUTO_NEG_SYM_PAUSE)
> +			data |=3D PHY_AUTO_NEG_SYM_PAUSE;
> +		if (ctrl & PORT_AUTO_NEG_100BTX_FD)
> +			data |=3D PHY_AUTO_NEG_100BTX_FD;
> +		if (ctrl & PORT_AUTO_NEG_100BTX)
> +			data |=3D PHY_AUTO_NEG_100BTX;
> +		if (ctrl & PORT_AUTO_NEG_10BT_FD)
> +			data |=3D PHY_AUTO_NEG_10BT_FD;
> +		if (ctrl & PORT_AUTO_NEG_10BT)
> +			data |=3D PHY_AUTO_NEG_10BT;
> +		break;
> +	case PHY_REG_REMOTE_CAPABILITY:
> +		ksz_pread8(dev, p, P_REMOTE_STATUS, &link);
> +		data =3D PHY_AUTO_NEG_802_3;
> +		if (link & PORT_REMOTE_SYM_PAUSE)
> +			data |=3D PHY_AUTO_NEG_SYM_PAUSE;
> +		if (link & PORT_REMOTE_100BTX_FD)
> +			data |=3D PHY_AUTO_NEG_100BTX_FD;
> +		if (link & PORT_REMOTE_100BTX)
> +			data |=3D PHY_AUTO_NEG_100BTX;
> +		if (link & PORT_REMOTE_10BT_FD)
> +			data |=3D PHY_AUTO_NEG_10BT_FD;
> +		if (link & PORT_REMOTE_10BT)
> +			data |=3D PHY_AUTO_NEG_10BT;
> +		break;
> +	default:
> +		processed =3D false;
> +		break;
> +	}
> +	if (processed)
> +		*val =3D data;
> +}

Similar code will be needed by other drivers, right?

> +static int ksz_port_bridge_join(struct dsa_switch *ds, int port,
> +				struct net_device *br)
> +{
> +	struct ksz_device *dev =3D ds->priv;
> +
> +	dev->br_member |=3D (1 << port);
> +
> +	/**
> +	 * port_stp_state_set() will be called after to put the port in
> +	 * appropriate state so there is no need to do anything.
> +	 */

/** -> /*. Fix it elsewhere, too. This is not kerneldoc.

> +	/* Topology is changed. */
> +	if (forward !=3D dev->member)

has changed?

Thanks for the patches,

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmyYIAACgkQMOfwapXb+vJoQACguxOMo9ofUWcBTy6XY2U+sxGb
iIMAn2ZV/aU9ESgDdY7nCKaxIBKrmwDi
=Rso0
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
