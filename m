From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/2] r6040: fix multicast operations
Date: Thu, 21 Oct 2010 03:55:51 +0100
Message-ID: <1287629751.20865.220.camel@localhost>
References: <201010202309.43812.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-cmbRnZvcrTIPNRsJoUH7"
Cc: netdev@vger.kernel.org, Shawn Lin <shawn@dmp.com.tw>,
	Marc Leclerc <marc-leclerc@signaturealpha.com>,
	Albert Chen <albert.chen@rdc.com.tw>,
	David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49709 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757028Ab0JUC4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 22:56:05 -0400
In-Reply-To: <201010202309.43812.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cmbRnZvcrTIPNRsJoUH7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-10-20 at 22:25 +0100, Florian Fainelli wrote:
> This patch fixes the following issues with the r6040 NIC operating in
> multicast:
>=20
> 1) When the IFF_ALLMULTI flag is set, we should write 0xffff to the NIC h=
ash
>    table registers to make it process multicast traffic
> 2) When the number of multicast address to handle is smaller than MCAST_M=
AX
>    we should use the NIC multicast registers MID1_{L,M,H}.
> 3) The hashing of the address was not correct, due to an invalid substrac=
tion
>    (15 - (crc & 0x0f)) instead of (crc & 0x0f)

> Reported-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> Tested-by: Marc Leclerc <marc-leclerc@signaturealpha.com>
> Signed-off-by: Shawn Lin <shawn@dmp.com.tw>
> Signed-off-by: Albert Chen <albert.chen@rdc.com.tw>
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> CC: stable@kernel.org

Remember you'll need to provide a different version for 2.6.27.y and
2.6.32.y.

> ---
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 68a8419..3843363 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -852,74 +852,90 @@ static void r6040_multicast_list(struct net_device =
*dev)
>  	struct r6040_private *lp =3D netdev_priv(dev);
>  	void __iomem *ioaddr =3D lp->base;
>  	u16 *adrp;
> -	u16 reg;
>  	unsigned long flags;
>  	struct netdev_hw_addr *ha;
>  	int i;
> =20
> -	/* MAC Address */
> -	adrp =3D (u16 *)dev->dev_addr;
> -	iowrite16(adrp[0], ioaddr + MID_0L);
> -	iowrite16(adrp[1], ioaddr + MID_0M);
> -	iowrite16(adrp[2], ioaddr + MID_0H);
> -
> -	/* Promiscous Mode */
>  	spin_lock_irqsave(&lp->lock, flags);
> =20
>  	/* Clear AMCP & PROM bits */
> -	reg =3D ioread16(ioaddr) & ~0x0120;
> -	if (dev->flags & IFF_PROMISC) {
> -		reg |=3D 0x0020;
> +	lp->mcr0 =3D ioread16(ioaddr) & ~0x0120;
> +
> +	/* Promiscuous Mode */
> +	if (dev->flags & IFF_PROMISC)
>  		lp->mcr0 |=3D 0x0020;
> -	}
> -	/* Too many multicast addresses
> -	 * accept all traffic */
> -	else if ((netdev_mc_count(dev) > MCAST_MAX) ||
> -		 (dev->flags & IFF_ALLMULTI))
> -		reg |=3D 0x0020;
> =20
> -	iowrite16(reg, ioaddr);
> -	spin_unlock_irqrestore(&lp->lock, flags);
> +	/* Enable multicast hash table function to
> +	 * receive all multicast packets.
> +	 */
> +	else if (dev->flags & IFF_ALLMULTI) {
> +		lp->mcr0 |=3D 0x0100;

Please give these flags names.

> =20
> -	/* Build the hash table */
> -	if (netdev_mc_count(dev) > MCAST_MAX) {
> -		u16 hash_table[4];
> +		for (i =3D 0; i < MCAST_MAX ; i++) {
> +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> +		}
> +
> +		iowrite16(0xffff, ioaddr + MAR0);
> +		iowrite16(0xffff, ioaddr + MAR1);
> +		iowrite16(0xffff, ioaddr + MAR2);
> +		iowrite16(0xffff, ioaddr + MAR3);
> +	}
> +
> +	/* Use internal multicast address registers
> +	 * if the number of multicast addresses is not greater than MCAST_MAX.
> +	 */
> +	else if (netdev_mc_empty(dev)) {
> +		for (i =3D 0; i < MCAST_MAX ; i++) {
> +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> +		}
> +	} else if (netdev_mc_count(dev) <=3D MCAST_MAX) {
> +		i =3D 0;
> +		netdev_for_each_mc_addr(ha, dev) {
> +			adrp =3D (u16 *) ha->addr;
> +			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> +			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> +			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> +			i++;
> +		}

What about the unused exact match entries?  And why is the empty case
special?

> +	}
> +	/* Otherwise, Enable multicast hash table function. */
> +	else {
> +		u16 hash_table[4] =3D { 0, };
>  		u32 crc;
> =20
> -		for (i =3D 0; i < 4; i++)
> -			hash_table[i] =3D 0;
> +		lp->mcr0 |=3D 0x0100;
> =20
> +		for (i =3D 0; i < MCAST_MAX ; i++) {
> +			iowrite16(0, ioaddr + MID_1L + 8 * i);
> +			iowrite16(0, ioaddr + MID_1M + 8 * i);
> +			iowrite16(0, ioaddr + MID_1H + 8 * i);
> +		}
> +
> +		/* Build multicast hash table */
>  		netdev_for_each_mc_addr(ha, dev) {
>  			char *addrs =3D ha->addr;
> =20
>  			if (!(*addrs & 1))
>  				continue;
> =20
> -			crc =3D ether_crc_le(6, addrs);
> +			crc =3D ether_crc(ETH_ALEN, addrs);

You're reversing the order of bits in the CRC, which is not mentioned in
the commit message; are you sure that's right?

>  			crc >>=3D 26;
> -			hash_table[crc >> 4] |=3D 1 << (15 - (crc & 0xf));
> +			hash_table[crc >> 4] |=3D 1 << (crc & 0xf);
>  		}
> +
>  		/* Fill the MAC hash tables with their values */
>  		iowrite16(hash_table[0], ioaddr + MAR0);
>  		iowrite16(hash_table[1], ioaddr + MAR1);
>  		iowrite16(hash_table[2], ioaddr + MAR2);
>  		iowrite16(hash_table[3], ioaddr + MAR3);
>  	}
> -	/* Multicast Address 1~4 case */
> -	i =3D 0;
> -	netdev_for_each_mc_addr(ha, dev) {
> -		if (i < MCAST_MAX) {
> -			adrp =3D (u16 *) ha->addr;
> -			iowrite16(adrp[0], ioaddr + MID_1L + 8 * i);
> -			iowrite16(adrp[1], ioaddr + MID_1M + 8 * i);
> -			iowrite16(adrp[2], ioaddr + MID_1H + 8 * i);
> -		} else {
> -			iowrite16(0xffff, ioaddr + MID_1L + 8 * i);
> -			iowrite16(0xffff, ioaddr + MID_1M + 8 * i);
> -			iowrite16(0xffff, ioaddr + MID_1H + 8 * i);
> -		}

This conflicts with my patch in
<http://article.gmane.org/gmane.linux.network/174926> which Dave has
already applied (but not pushed out).

Ben.

> -		i++;
> -	}
> +	iowrite16(lp->mcr0, ioaddr);
> +
> +	spin_unlock_irqrestore(&lp->lock, flags);
>  }
> =20
>  static void netdev_get_drvinfo(struct net_device *dev,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-cmbRnZvcrTIPNRsJoUH7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATL+rsee/yOyVhhEJAQJ0gQ//SLa9ugqTikG6D6NkhJYP4Pfp36es48q/
MT9JRlF9IX7zIEFzlNz4pE91ux1fUFa3Xp8NPaPcc4pACkBQRmkKcyS6vmUG9SPm
FcrJLbKww4W5nu2EeUNXNUp62RFSJi5mNJNlzFEyvPTVkEWTwXnbI+XXPYsObhEC
l84PY3ytifRIuLra149QyxohsnnfhouyVdjYSvAwLqstuBGPtsF7meYg5GAHmFp4
aVHjmavnjGBPNsnjiSq9x+LKK+xC7WzGcMq3Zx7wow4peQEVSAHxOg7MSW0KZ9st
Z/FS54uISEoYZaEBlUOUKHfxK/L5+tIpx/IPkUqegledlOag+3dEoFCN/Trya4FG
k+kbgjKjY0Jvj06wMmQL9JskbAptj4GJU4+TDrHar53UnKLqtM7uOoXCZPdTw86S
8uFkOwXceg5SWrjgk5g3xp8uXmiCoDLxG88gJBm1tUT7kreSmYv3ApHxLkInBpJL
2H1ouVU/2WpXyQ9g6xchSeuwLgQmtV+L8/whdw0ELB5h5ko2IQ+9rQ8oxaQin/GN
CuqCYS4ml2zNjPpT2/5kANn3XfhEg2n1JIy22dlhEKrhQCejKkP2JFgG7mXV5yeT
GXOD5ktoYLM2nvq01UhROe5FFids9vPlT+ZwLRi2S/lrEJ1KCB6udyLQxDS7fj8Y
hxz9T+zB5xA=
=96hf
-----END PGP SIGNATURE-----

--=-cmbRnZvcrTIPNRsJoUH7--
