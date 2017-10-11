From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH RFC] Add Microchip KSZ8895 DSA driver
Date: Wed, 11 Oct 2017 23:03:29 +0200
Message-ID: <20171011210329.GA32314@amd>
References: <1507322033-15222-1-git-send-email-Tristram.Ha@microchip.com>
 <1507322033-15222-2-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fdj2RfSjLxBAspz7"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, muvarov@gmail.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507322033-15222-2-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> +static void ksz8895_set_prio_queue(struct ksz_device *dev, int port, int=
 queue)
> +{
> +	u8 hi;
> +	u8 lo;
> +
> +	/* Number of queues can only be 1, 2, or 4. */
> +	switch (queue) {
> +	case 4:
> +	case 3:
> +		queue =3D PORT_QUEUE_SPLIT_4;
> +		break;
> +	case 2:
> +		queue =3D PORT_QUEUE_SPLIT_2;
> +		break;
> +	default:
> +		queue =3D PORT_QUEUE_SPLIT_1;
> +	}
> +	ksz_pread8(dev, port, REG_PORT_CTRL_0, &lo);
> +	ksz_pread8(dev, port, P_DROP_TAG_CTRL, &hi);
> +	lo &=3D ~PORT_QUEUE_SPLIT_L;
> +	if (queue & PORT_QUEUE_SPLIT_2)
> +		lo |=3D PORT_QUEUE_SPLIT_L;
> +	hi &=3D ~PORT_QUEUE_SPLIT_H;
> +	if (queue & PORT_QUEUE_SPLIT_4)
> +		hi |=3D PORT_QUEUE_SPLIT_H;
> +	ksz_pwrite8(dev, port, REG_PORT_CTRL_0, lo);
> +	ksz_pwrite8(dev, port, P_DROP_TAG_CTRL, hi);
> +
> +	/* Default is port based for egress rate limit. */
> +	if (queue !=3D PORT_QUEUE_SPLIT_1)
> +		ksz_cfg(dev, REG_SW_CTRL_19, SW_OUT_RATE_LIMIT_QUEUE_BASED,
> +			true);
> +}

This is same as the other driver, right? Same comments apply here, and
please find a way to make it shared.


> +static void ksz8895_r_mib_cnt(struct ksz_device *dev, int port, u16 addr,
> +			      u64 *cnt)
> +{
> +	u32 data;
> +	u16 ctrl_addr;
> +	u8 check;
> +	int loop;
> +
> +	ctrl_addr =3D addr + SWITCH_COUNTER_NUM * port;
> +	ctrl_addr |=3D IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
> +
> +	mutex_lock(&dev->alu_mutex);
> +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> +
> +	/* It is almost guaranteed to always read the valid bit because of
> +	 * slow SPI speed.
> +	 */
> +	for (loop =3D 2; loop > 0; loop--) {
> +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> +
> +		if (check & MIB_COUNTER_VALID) {
> +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> +			if (check & MIB_COUNTER_OVERFLOW)
> +				*cnt +=3D MIB_COUNTER_VALUE + 1;
> +			*cnt +=3D data & MIB_COUNTER_VALUE;
> +			break;
> +		}
> +	}
> +	mutex_unlock(&dev->alu_mutex);

Again, same function, same review comments.

> +static void ksz8895_r_table(struct ksz_device *dev, int table, u16 addr,
> +			    u64 *data)
> +{
> +	u16 ctrl_addr;
> +
> +	ctrl_addr =3D IND_ACC_TABLE(table | TABLE_READ) | addr;
> +
> +	mutex_lock(&dev->alu_mutex);
> +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> +	ksz_get(dev, REG_IND_DATA_HI, data, sizeof(u64));
> +	mutex_unlock(&dev->alu_mutex);
> +	*data =3D be64_to_cpu(*data);
> +}

I've seen this before; this is duplicated code, it does not make sense
to review.

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--fdj2RfSjLxBAspz7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnehyEACgkQMOfwapXb+vJGTgCgvIgxfgpVy4NX7Sxh2XwQAC+N
aysAoI107AgeN9zGH+Cz4ZXTRcRRq/dp
=VV/O
-----END PGP SIGNATURE-----

--fdj2RfSjLxBAspz7--
