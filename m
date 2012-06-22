From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Fri, 22 Jun 2012 20:45:12 +0800
Message-ID: <CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Marius_Bj=F8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1340356279-3124-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2012 at 5:11 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> usbnet_disconnect() will set intfdata to NULL before calling
> the minidriver unbind function. =A0The cdc_wdm subdriver cannot
> know that it is disconnecting until the qmi_wwan unbind
> function has called its disconnect function. =A0This means that
> we must be able to support the cdc_wdm subdriver operating
> normally while usbnet_disconnect() is running, and in
> particular that intfdata may be NULL.
>
> The only place this matters is in qmi_wwan_cdc_wdm_manage_power
> which is called from cdc_wdm. =A0Simply testing for NULL
> intfdata there is sufficient to allow it to continue working
> at all times.
>
> Fixes this Oops where a cdc-wdm device was closed while the
> USB device was disconnecting, causing wdm_release to call
> qmi_wwan_cdc_wdm_manage_power after intfdata was set to
> NULL by usbnet_disconnect:

In fact, it should be a general problem in usbnet, there are races
between usbnet_disconnect and .open/.close. Considered that
unregister_netdev, which will sync with .open/.close,  is called in
usbnet_disconnect,  the simplest fix is to move usb_set_intfdata(NULL)
after unregister_netdev.

> Reported-by: Marius Bj=F8rnstad Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.4
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> =A0drivers/net/usb/qmi_wwan.c | =A0 =A04 ++++
> =A01 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 3767a12..b01960f 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -197,6 +197,10 @@ err:
> =A0static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *int=
f, int on)
> =A0{
> =A0 =A0 =A0 =A0struct usbnet *dev =3D usb_get_intfdata(intf);
> +
> + =A0 =A0 =A0 /* can be called while disconnecting */
> + =A0 =A0 =A0 if (!dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 =A0 =A0 =A0return qmi_wwan_manage_power(dev, on);
> =A0}

Considered that usb_set_intfdata(NULL) will be called after
executing .disconnect in unbind path, it can be removed simply.

So how about the below?

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e92c057..2eb9e1e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1286,7 +1286,6 @@ void usbnet_disconnect (struct usb_interface *int=
f)
 	struct net_device	*net;

 	dev =3D usb_get_intfdata(intf);
-	usb_set_intfdata(intf, NULL);
 	if (!dev)
 		return;


Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
