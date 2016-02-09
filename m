From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob
Date: Tue, 09 Feb 2016 12:02:24 +0100
Message-ID: <1455015744.3592.46.camel@intel.com>
References: <56ABE3A8.4010602@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RWSzUiCIihgTBVS/HgBj"
To: John Holland <jotihojr@gmail.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29379 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225AbcBILCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 06:02:31 -0500
In-Reply-To: <56ABE3A8.4010602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RWSzUiCIihgTBVS/HgBj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-01-29 at 23:11 +0100, John Holland wrote:
> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an
> OTP=C2=A0
> and has no externel EEPROM interface [1]. The following allows the=C2=A0
> driver to pickup the MAC address from a device tree blob when
> CONFIG_OF=C2=A0
> has been enabled.
>=20
> [1]=C2=A0
> http://www.intel.com/content/www/us/en/embedded/products/networking/i
> 211-ethernet-controller-datasheet.html
>=20
> Signed-off-by: John Holland <jotihojr@gmail.com>
> ---
> =C2=A0 drivers/net/ethernet/intel/igb/igb_main.c | 30=C2=A0
> ++++++++++++++++++++++++++++++
> =C2=A0 1 file changed, 30 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c=C2=A0
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index 31e5f39..9c92443 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -56,6 +56,11 @@
> =C2=A0 #include <linux/i2c.h>
> =C2=A0 #include "igb.h"
>=20
> +#ifdef defined(CONFIG_OF)
> +#include <linux/of_net.h>
> +#include <linux/etherdevice.h>
> +#endif
> +
> =C2=A0 #define MAJ 5
> =C2=A0 #define MIN 3
> =C2=A0 #define BUILD 0
> @@ -2217,6 +2222,26 @@ static s32 igb_init_i2c(struct igb_adapter
> *adapter)
> =C2=A0 }
>=20
> =C2=A0 /**
> + *=C2=A0=C2=A0igb_read_mac_addr_dts - Read mac addres from the device tr=
ee
> blob.

Address is mis-spelled above

> + *=C2=A0=C2=A0@hw: pointer to the e1000 hardware structure
> + **/
> +#ifdef defined(CONFIG_OF)

Minor nitpick, you should have the function comment header wrapped in
the #ifdef as well.

> +static void igb_read_mac_addr_dts(struct e1000_hw *hw)
> +{
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0const u8 *mac;
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct device_node *dn;
> +
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dn =3D of_find_compatible_node=
(NULL, NULL, "intel,i211");
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!dn)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0return;
> +
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0mac =3D of_get_mac_address(dn)=
;
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (mac)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0ether_addr_copy(hw->mac.addr, mac);
> +}
> +#endif
> +
> +/**
> =C2=A0=C2=A0=C2=A0*=C2=A0=C2=A0igb_probe - Device Initialization Routine
> =C2=A0=C2=A0=C2=A0*=C2=A0=C2=A0@pdev: PCI device information struct
> =C2=A0=C2=A0=C2=A0*=C2=A0=C2=A0@ent: entry in igb_pci_tbl
> @@ -2420,6 +2445,11 @@ static int igb_probe(struct pci_dev *pdev,
> const=C2=A0
> struct pci_device_id *ent)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (hw->mac.ops.rea=
d_mac_addr(hw))
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0dev_err(&pdev->dev, "NVM Read Error\n");
>=20
> +#ifdef defined(CONFIG_OF)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is_valid_ether_addr(hw->m=
ac.addr))
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0igb_read_mac_addr_dts(hw);
> +#endif
> +
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0memcpy(netdev->dev_=
addr, hw->mac.addr, netdev->addr_len);
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!is_valid_ether=
_addr(netdev->dev_addr)) {
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan

--=-RWSzUiCIihgTBVS/HgBj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWucdAAAoJEOVv75VaS+3OU5cP/RrGt3Qgmwx53isDsvr3jkb/
7HhbM9KWwubT09nP/n/2pf7h2I5aRr9vuWkHXTaUAFOC/aYPD9L0mgfKCCxCv1/K
BFkA1HZSFhYFXPM7L9O3S2Vj3ia6zBpOY8dx7WwnRzc+5jQgZrhkC+lw7Jo+Zzlv
P21tdHQSW3EZPRY7MKjcECZNd4tJJLbgvdMBVuh7yFvanlwO8/P6WwwJ/SFO/Drd
pPzvXeeSk3f88tprN4ktEwIqVwhM4VYbnyciO7vzfUiT0JMuVDgVLKwrpxN1gX4W
YqXEmwNYot8rRM9bLKiplRhhfzY44B9rPPkQmQMO7JtSG7FF9Itb3xT++O/US/4+
AloSbLSgPGWZT8UCWvPmPuV7oJgLvmaztpq6KOAfehrNpJvivg8vgscHmjVbwOL9
m+8j/rpQ0fCTC4kUT1fPGUZmxI0uGzZUeptbIZxGC3oS84i9fk3opqFhn980Bfsh
hY6IgKeQXFoW6pF/gXpckpUQM+LKVAJfM6+OP2UVxpDKbllBLE0FEznuSBen7Q2n
RxWKHrNRkQGFdh6DE62eyQOJ7VgCOaq2W0o8io9EZIvh/0eJLVO0zggVu3KcdMCA
Ock3B41yKL9xQHUKcxi9gKpD6SO8mwC81ph71VUqLnjZtveemE+r+7aws2xT/67R
V3OZUi+zFQ+0N6ujwz7d
=iWpA
-----END PGP SIGNATURE-----

--=-RWSzUiCIihgTBVS/HgBj--
