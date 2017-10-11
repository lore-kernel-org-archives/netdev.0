From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v1 RFC 1/1] Add Microchip KSZ8795 DSA driver
Date: Wed, 11 Oct 2017 22:59:16 +0200
Message-ID: <20171011205916.GC31288@amd>
References: <1507322023-15182-1-git-send-email-Tristram.Ha@microchip.com>
 <1507322023-15182-2-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="DIOMP1UsTsWJauNi"
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>,
        muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507322023-15182-2-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--DIOMP1UsTsWJauNi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> +static void ksz8795_set_prio_queue(struct ksz_device *dev, int port, int=
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

If only 1, 2 and 4 are valid, it probably should not accept other
values?

> +static void ksz8795_r_mib_cnt(struct ksz_device *dev, int port, u16 addr,
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

Hmm. Maybe, but should not this at least warn if if it can not get
valid counter?

> +	/* It is almost guaranteed to always read the valid bit because of
> +	 * slow SPI speed.
> +	 */
> +	for (loop =3D 2; loop > 0; loop--) {
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

Same here. Plus, is overflow handling correct? There may be more than
MIB_PACKET_DROPPED + 1 packets dropped between the checks.=20

> +static void ksz8795_r_table(struct ksz_device *dev, int table, u16 addr,
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

It would be a tiny bit nicer to have be64 temporary variable and use
it; having *data change endianness at runtime is "interesting".

> +static int ksz8795_valid_dyn_entry(struct ksz_device *dev, u8 *data)
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
> +		return -EAGAIN;
> +	/* Entry is ready for accessing. */
> +	} else {
> +		ksz_read8(dev, REG_IND_DATA_8, data);
> +
> +		/* There is no valid entry in the table. */
> +		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
> +			return -ENXIO;
> +	}

You can drop else and one indentation level.

> +	/* At least one valid entry in the table. */
> +	} else {
> +		u64 buf;
> +		int cnt;
> +
> +		ksz_get(dev, REG_IND_DATA_HI, &buf, sizeof(buf));
> +		buf =3D be64_to_cpu(buf);

Would it make sense to convert endianness inside ksz_get?

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--DIOMP1UsTsWJauNi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlnehiQACgkQMOfwapXb+vJhCgCfXs5DiTirsoBhX4TNBbCxO9a2
yBYAnAng6lYxCqQ2Futpu24q23Z+vR4T
=DCX1
-----END PGP SIGNATURE-----

--DIOMP1UsTsWJauNi--
