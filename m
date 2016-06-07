From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v4] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 7 Jun 2016 09:59:34 +0200
Message-ID: <20160607075934.GY29844@pali>
References: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465233569-13585-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi! Below are my comments, all about coding style.

On Monday 06 June 2016 12:19:29 Mario Limonciello wrote:
> The RTL8153-AD supports a persistent system specific MAC address.
> This means a device plugged into two different systems with host side
> support will show different (but persistent) MAC addresses.
>=20
> This information for the system's persistent MAC address is burned in=
 when
> the system HW is built and available under _SB\AMAC in the DSDT at ru=
ntime.

=46or consistency it would be great to use same ACPI name in whole patc=
h: \_SB.AMAC

> This technology is currently implemented in the Dell TB15 and WD15 Ty=
pe-C
> docks.  More information is available here:
> http://www.dell.com/support/article/us/en/04/SLN301147
>=20
> Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> ---
> Changes from v3:
>  * Add additional comments about functions and what they're doing
>  * Adjust warning calls to use netif instead
>  * Rename function
>=20
>  drivers/net/usb/r8152.c | 70 +++++++++++++++++++++++++++++++++++++++=
++++++++--
>  1 file changed, 68 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 3f9f6ed..b2339d3 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -26,6 +26,7 @@
>  #include <linux/mdio.h>
>  #include <linux/usb/cdc.h>
>  #include <linux/suspend.h>
> +#include <linux/acpi.h>
> =20
>  /* Information for net-next */
>  #define NETNEXT_VERSION		"08"
> @@ -455,6 +456,11 @@
>  /* SRAM_IMPEDANCE */
>  #define RX_DRIVING_MASK		0x6000
> =20
> +/* MAC PASSTHRU */
> +#define AD_MASK			0xfee0
> +#define EFUSE			0xcfdb
> +#define PASS_THRU_MASK		0x1
> +
>  enum rtl_register_content {
>  	_1000bps	=3D 0x10,
>  	_100bps		=3D 0x08,
> @@ -1030,6 +1036,59 @@ out1:
>  	return ret;
>  }
> =20
> +/* Devices containing RTL8153-AD can support a persistent
> + * host system provided MAC address.
> + * Examples of this are Dell TB15 and Dell WD15 docks
> + */
> +static int get_vendor_mac_passthru_addr(struct r8152 *tp, struct soc=
kaddr *sa)
> +{
> +	acpi_status status;
> +	struct acpi_buffer buffer =3D { ACPI_ALLOCATE_BUFFER, NULL };
> +	union acpi_object *obj;
> +	int ret =3D -EINVAL;
> +	u32 ocp_data;
> +	unsigned char buf[6];
> +
> +	/* test for -AD variant of RTL8153 */
> +	ocp_data =3D ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
> +	if ((ocp_data & AD_MASK) !=3D 0x1000)
> +		return -ENODEV;
> +
> +	/* test for MAC address pass-through bit */
> +	ocp_data =3D ocp_read_byte(tp, MCU_TYPE_USB, EFUSE);
> +	if ((ocp_data & PASS_THRU_MASK) !=3D 1)
> +		return -ENODEV;
> +
> +	/* returns _AUXMAC_#AABBCCDDEEFF# */
> +	status =3D acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);

What about?

	if (!ACPI_SUCCESS(status))
		return -ENODEV;

You will save one level of indentation.

> +	obj =3D (union acpi_object *)buffer.pointer;
> +	if (ACPI_SUCCESS(status)) {
> +		if (obj->type !=3D ACPI_TYPE_BUFFER ||
> +		    obj->string.length !=3D 0x17) {
> +			netif_warn(tp, probe, tp->netdev, "Invalid buffer\n");

I would suggest more specific warning messages. These are very general
and if I would see them in dmesg log I would have no idea what that
means.

> +			goto amacout;
> +		}
> +		if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) !=3D 0) {
> +			netif_warn(tp, probe, tp->netdev, "Invalid header\n");
> +			goto amacout;
> +		}

If your specification state that last character is '#' then I think you
should check it too.

> +		ret =3D hex2bin(buf, obj->string.pointer + 9, 6);
> +		if (ret < 0 || !is_valid_ether_addr(buf)) {
> +			netif_warn(tp, probe, tp->netdev, "Invalid MAC\n");
> +			goto amacout;
> +		}
> +		memcpy(sa->sa_data, buf, 6);
> +		ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
> +		netif_info(tp, probe, tp->netdev,
> +			   "Using pass-through MAC addr %pM\n", sa->sa_data);
> +		ret =3D 0;
> +	}
> +
> +amacout:
> +	kfree(obj);
> +	return ret;
> +}
> +
>  static int set_ethernet_addr(struct r8152 *tp)
>  {
>  	struct net_device *dev =3D tp->netdev;
> @@ -1038,8 +1097,15 @@ static int set_ethernet_addr(struct r8152 *tp)
> =20
>  	if (tp->version =3D=3D RTL_VER_01)
>  		ret =3D pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
> -	else
> -		ret =3D pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> +	else {
> +		/* if this is not an RTL8153-AD, no eFuse mac pass thru set,
> +		 * or system doesn't provide valid _SB.AMAC this will be
> +		 * be expected to non-zero
> +		 */
> +		ret =3D get_vendor_mac_passthru_addr(tp, &sa);

You do not "get" (return) any mac address. Personally I would use "read=
"
word in function name (like above pla_ocp_read). What about?

ret =3D vendor_mac_passthru_addr_read(tp, sa.sa_data);

Or something similar... "Get" looks like function "get" something, but
instead it set address in &sa structure.

> +		if (ret < 0)
> +			ret =3D pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> +	}
> =20
>  	if (ret < 0) {
>  		netif_err(tp, probe, dev, "Get ether addr fail\n");

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
