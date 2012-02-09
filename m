From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 04/50] adi/blackfin: set addr_assign_type correctly if random
Date: Wed, 8 Feb 2012 23:05:13 -0500
Message-ID: <201202082305.17415.vapier@gentoo.org>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-5-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2532916.jiUJtrOzss";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"Lars-Peter Clausen" <lars@metafoo.de>,
	Scott Jiang <scott.jiang@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-5-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2532916.jiUJtrOzss
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 08 February 2012 16:10:11 Danny Kukawka wrote:
> --- a/arch/blackfin/mach-bf537/boards/cm_bf537e.c
> +++ b/arch/blackfin/mach-bf537/boards/cm_bf537e.c
>=20
> -void bfin_get_ether_addr(char *addr)
> +int bfin_get_ether_addr(char *addr)
>  {
>  	random_ether_addr(addr);
>  	printk(KERN_WARNING "%s:%s: Setting Ethernet MAC to a random one\n",
> 		__FILE__, __func__);
> +	return 1;
>  }

these boards that just call random_ether_addr() should be changed to only=20
return 1 ...

> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -621,6 +621,8 @@
>
>  	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> +	if (dev->addr_assign_type & NET_ADDR_RANDOM)
> +		dev->addr_assign_type ^=3D NET_ADDR_RANDOM;
>  	setup_mac_addr(dev->dev_addr);
>  	return 0;
>  }
> @@ -1496,12 +1498,14 @@
>
> -	if (!is_valid_ether_addr(ndev->dev_addr))
> -		bfin_get_ether_addr(ndev->dev_addr);
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		if (bfin_get_ether_addr(ndev->dev_addr))
> +			ndev->addr_assign_type |=3D NET_ADDR_RANDOM;
> +	}

if it returned non-zero, then the mac addr is still invalid, so down below =
=2E..

>  	/* If still not valid, get a random one */
>  	if (!is_valid_ether_addr(ndev->dev_addr))
> -		random_ether_addr(ndev->dev_addr);
> +		dev_hw_addr_random(ndev, ndev->dev_addr);

=2E.. we call dev_hw_addr_random(), so explicitly setting NET_ADDR_RANDOM=20
ourselves is unnecessary

i think the logic should read:
	if (!is_valid_ether_addr(ndev->dev_addr)) {
		if (bfin_get_ether_addr(ndev->dev_addr))
			goto random_mac;

	if (!is_valid_ether_addr(ndev->dev_addr))
 random_mac:
		dev_hw_addr_random(ndev, ndev->dev_addr);
=2Dmike

--nextPart2532916.jiUJtrOzss
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPM0X9AAoJEEFjO5/oN/WBAhoP/3CYcTypNIBrwxNmxe2O75Tv
ulbnK/GQ4lOLtzguXPtpkJhs1TVFvc+yEMpPnxbn2aEQVWTi+kpEbQnRk50fsRT/
1ynE3VzYAFNYx1PUBwN4p42ib3ILIJpPgZp9EmrQuLS6n4ARiGT712LtJ2z2bt/g
mqQmZxnzvzzTdpOTJ4hgHoGhHtxGRevmQJWYcl23rhj5tR0TqvLeyKWgDt8O6ClT
QPk2kN0JGLzsfpvVS5xyFDYL2fxMWxIM2wuK5do64EL77Dhav43zYj8TTcYhwei9
Bn+Ixh0ik1i//x5tjp47yHDpIwZtFoL+z/owet4Cs2AKPM6Y31QUt1cg++Sy5bSm
x1vHsBpMRDquIwpnPG5OEtGrfqskg7jQBuNfCcBm+z59c/NsnG3BG8PROWZ+GZCU
AjXPclWY2nclFfz6yHLowdie7E4tpCspQR9KGt+dkDL9X1vIVJSOFcYuiNcDwB3O
xBUBwFmOQOSuXFju4eLheIe0a9NqmeI6p/y+e2RDMb7euqiFkYTV+tITE4RFSlJB
PivscXgmt53MuLvlev2P9FDIE6mSs0LEcbjSebp9gIHlN3HEZwMcy/YtoaX/6l9n
+ITt5bIt8QGc/phspTLzksx8itZbIM17cejO+5fdRchznjJQxMmkKxkBBLGitwz9
2j83/DGkLcQQkyReOGzJ
=phjj
-----END PGP SIGNATURE-----

--nextPart2532916.jiUJtrOzss--
