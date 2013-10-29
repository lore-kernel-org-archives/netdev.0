From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net/cdc_ncm: fix null pointer panic at usbnet_link_change
Date: Tue, 29 Oct 2013 09:41:26 +0100
Message-ID: <87wqkwii4p.fsf@nemi.mork.no>
References: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "oliver\@neukum.org" <oliver@neukum.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Du\, ChangbinX" <changbinx.du@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
	(ChangbinX Du's message of "Tue, 29 Oct 2013 03:30:42 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Du, ChangbinX" <changbinx.du@intel.com> writes:

> From: "Du, Changbin" <changbinx.du@intel.com>
>
> In cdc_ncm_bind() function, it call cdc_ncm_bind_common() to setup us=
b.
> But cdc_ncm_bind_common() may meet error and cause usbnet_disconnect(=
)
> be called which calls free_netdev(net).

I am sure you are right, but I really don't see how that can happen.

AFAICS, we ensure that the intfdata is set to NULL before calling=20
usb_driver_release_interface() in the error cleanup in=20
cdc_ncm_bind_common():


error2:
	usb_set_intfdata(ctx->control, NULL);
	usb_set_intfdata(ctx->data, NULL);
	if (ctx->data !=3D ctx->control)
		usb_driver_release_interface(driver, ctx->data);
error:
	cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
	dev->data[0] =3D 0;
	dev_info(&dev->udev->dev, "bind() failure\n");
	return -ENODEV;


Thus we hit the test in disconnect, and usbnet_disconnect() is never
called:

static void cdc_ncm_disconnect(struct usb_interface *intf)
{
	struct usbnet *dev =3D usb_get_intfdata(intf);

	if (dev =3D=3D NULL)
		return;		/* already disconnected */

	usbnet_disconnect(intf);
}



So we should really be OK, but we are not????  I would appreciate it if
anyone took the time to feed me why, with a very small spoon...



> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 43afde8..af37ecf 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -603,14 +603,15 @@ static int cdc_ncm_bind(struct usbnet *dev, str=
uct usb_interface *intf)
> =20
>  	/* NCM data altsetting is always 1 */
>  	ret =3D cdc_ncm_bind_common(dev, intf, 1);
> -
> -	/*
> -	 * We should get an event when network connection is "connected" or
> -	 * "disconnected". Set network connection in "disconnected" state
> -	 * (carrier is OFF) during attach, so the IP network stack does not
> -	 * start IPv6 negotiation and more.
> -	 */
> -	usbnet_link_change(dev, 0, 0);
> +	if (!ret) {
> +		/*
> +		 * We should get an event when network connection is "connected"
> +		 * or "disconnected". Set network connection in "disconnected"
> +		 * state (carrier is OFF) during attach, so the IP network stack
> +		 * does not start IPv6 negotiation and more.
> +		 */
> +		usbnet_link_change(dev, 0, 0);
> +	}
>  	return ret;
>  }

This change does of course make sense in any case, so no objections
there.  But maybe you could modify cdc_ncm to set the new FLAG_LINK_INT=
R
instead, and completely drop the usbnet_link_change() from this driver?
This will make usbnet_probe() handle the call, and it will avoid it if
cdc_ncm_bind() failed.



Bj=C3=B8rn
