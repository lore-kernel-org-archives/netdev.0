From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net,stable-3.8] net: qmi_wwan: set correct altsetting
 for Gobi 1K devices
Date: Wed, 13 Mar 2013 08:43:36 -0500
Message-ID: <1363182216.1415.5.camel@dcbw.foobar.com>
References: <1363177517-23524-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932398Ab3CMNnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 09:43:00 -0400
In-Reply-To: <1363177517-23524-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-13 at 13:25 +0100, Bj=C3=B8rn Mork wrote:
> commit bd877e4 ("net: qmi_wwan: use a single bind function for
> all device types") made Gobi 1K devices fail probing.
>=20
> Using the number of endpoints in the default altsetting to decide
> whether the function use one or two interfaces is wrong.  Other
> altsettings may provide more endpoints.
>=20
> With Gobi 1K devices, USB interface #3's altsetting is 0 by default, =
but
> altsetting 0 only provides one interrupt endpoint and is not sufficen=
t
> for QMI.  Altsetting 1 provides all 3 endpoints required for qmi_wwan
> and works with QMI. Gobi 1K layout for intf#3 is:
>=20
>     Interface Descriptor:  255/255/255
>       bInterfaceNumber        3
>       bAlternateSetting       0
>       Endpoint Descriptor:  Interrupt IN
>     Interface Descriptor:  255/255/255
>       bInterfaceNumber        3
>       bAlternateSetting       1
>       Endpoint Descriptor:  Interrupt IN
>       Endpoint Descriptor:  Bulk IN
>       Endpoint Descriptor:  Bulk OUT
>=20
> Prior to commit bd877e4, we would call usbnet_get_endpoints
> before giving up finding enough endpoints. Removing the early
> endpoint number test and the strict functional descriptor
> requirement allow qmi_wwan_bind to continue until
> usbnet_get_endpoints has made the final attempt to collect
> endpoints.  This restores the behaviour from before commit
> bd877e4 without losing the added benefit of using a single bind
> function.
>=20
> The driver has always required a CDC Union functional descriptor
> for two-interface functions. Using the existence of this
> descriptor to detect two-interface functions is the logically
> correct method.
>=20
> Reported-by: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Bj=C3=B8rn Mork

Works on my UML290, Gobi3K, Gobi1K, Gobi2K, and E362.

Tested-by: Dan Williams <dcbw@redhat.com>

>  <bjorn@mork.no>
> ---
> Dan,
>=20
> could you test this on a Gobi 1K device?  It should fix the problem,
> but I'd like to verify my assumptions for once :)
>=20
> This needs to go to stable-3.8 as well.
>=20
>=20
> Bj=C3=B8rn
>=20
>=20
>  drivers/net/usb/qmi_wwan.c |   49 +++++++++++++++-------------------=
----------
>  1 file changed, 16 insertions(+), 33 deletions(-)
>=20
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index efb5c7c..968d5d5 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -139,16 +139,9 @@ static int qmi_wwan_bind(struct usbnet *dev, str=
uct usb_interface *intf)
> =20
>  	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qm=
i_wwan_state)));
> =20
> -	/* control and data is shared? */
> -	if (intf->cur_altsetting->desc.bNumEndpoints =3D=3D 3) {
> -		info->control =3D intf;
> -		info->data =3D intf;
> -		goto shared;
> -	}
> -
> -	/* else require a single interrupt status endpoint on control intf =
*/
> -	if (intf->cur_altsetting->desc.bNumEndpoints !=3D 1)
> -		goto err;
> +	/* set up initial state */
> +	info->control =3D intf;
> +	info->data =3D intf;
> =20
>  	/* and a number of CDC descriptors */
>  	while (len > 3) {
> @@ -207,25 +200,14 @@ next_desc:
>  		buf +=3D h->bLength;
>  	}
> =20
> -	/* did we find all the required ones? */
> -	if (!(found & (1 << USB_CDC_HEADER_TYPE)) ||
> -	    !(found & (1 << USB_CDC_UNION_TYPE))) {
> -		dev_err(&intf->dev, "CDC functional descriptors missing\n");
> -		goto err;
> -	}
> -
> -	/* verify CDC Union */
> -	if (desc->bInterfaceNumber !=3D cdc_union->bMasterInterface0) {
> -		dev_err(&intf->dev, "bogus CDC Union: master=3D%u\n", cdc_union->b=
MasterInterface0);
> -		goto err;
> -	}
> -
> -	/* need to save these for unbind */
> -	info->control =3D intf;
> -	info->data =3D usb_ifnum_to_if(dev->udev,	cdc_union->bSlaveInterfac=
e0);
> -	if (!info->data) {
> -		dev_err(&intf->dev, "bogus CDC Union: slave=3D%u\n", cdc_union->bS=
laveInterface0);
> -		goto err;
> +	/* Use separate control and data interfaces if we found a CDC Union=
 */
> +	if (cdc_union) {
> +		info->data =3D usb_ifnum_to_if(dev->udev, cdc_union->bSlaveInterfa=
ce0);
> +		if (desc->bInterfaceNumber !=3D cdc_union->bMasterInterface0 || !i=
nfo->data) {
> +			dev_err(&intf->dev, "bogus CDC Union: master=3D%u, slave=3D%u\n",
> +				cdc_union->bMasterInterface0, cdc_union->bSlaveInterface0);
> +			goto err;
> +		}
>  	}
> =20
>  	/* errors aren't fatal - we can live with the dynamic address */
> @@ -235,11 +217,12 @@ next_desc:
>  	}
> =20
>  	/* claim data interface and set it up */
> -	status =3D usb_driver_claim_interface(driver, info->data, dev);
> -	if (status < 0)
> -		goto err;
> +	if (info->control !=3D info->data) {
> +		status =3D usb_driver_claim_interface(driver, info->data, dev);
> +		if (status < 0)
> +			goto err;
> +	}
> =20
> -shared:
>  	status =3D qmi_wwan_register_subdriver(dev);
>  	if (status < 0 && info->control !=3D info->data) {
>  		usb_set_intfdata(info->data, NULL);
