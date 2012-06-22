From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Fri, 22 Jun 2012 15:42:26 +0200
Message-ID: <87mx3vlayl.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47932 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762124Ab2FVNnD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 09:43:03 -0400
In-Reply-To: <CACVXFVPkC8NtvOzTsOyNcftZy60fDjtEkV_Da1Z32iYpHFHcUw@mail.gmail.com>
	(Ming Lei's message of "Fri, 22 Jun 2012 20:45:12 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <tom.leiming@gmail.com> writes:

> On Fri, Jun 22, 2012 at 5:11 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>> usbnet_disconnect() will set intfdata to NULL before calling
>> the minidriver unbind function. =C2=A0The cdc_wdm subdriver cannot
>> know that it is disconnecting until the qmi_wwan unbind
>> function has called its disconnect function. =C2=A0This means that
>> we must be able to support the cdc_wdm subdriver operating
>> normally while usbnet_disconnect() is running, and in
>> particular that intfdata may be NULL.
>>
>> The only place this matters is in qmi_wwan_cdc_wdm_manage_power
>> which is called from cdc_wdm. =C2=A0Simply testing for NULL
>> intfdata there is sufficient to allow it to continue working
>> at all times.
>>
>> Fixes this Oops where a cdc-wdm device was closed while the
>> USB device was disconnecting, causing wdm_release to call
>> qmi_wwan_cdc_wdm_manage_power after intfdata was set to
>> NULL by usbnet_disconnect:
>
> In fact, it should be a general problem in usbnet, there are races
> between usbnet_disconnect and .open/.close. Considered that
> unregister_netdev, which will sync with .open/.close,  is called in
> usbnet_disconnect,  the simplest fix is to move usb_set_intfdata(NULL=
)
> after unregister_netdev.

Is there really a race there?  The usbnet .open/.close don't use the
intfdata, do they?  I looked briefly through usbnet for related
potentional problems while fixing this in qmi_wwan, but could only find
suspend/resume.  Which I believe are protected against running on
disconnect.

So I think usbnet in general is OK.

> Considered that usb_set_intfdata(NULL) will be called after
> executing .disconnect in unbind path, it can be removed simply.
>
> So how about the below?
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index e92c057..2eb9e1e 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1286,7 +1286,6 @@ void usbnet_disconnect (struct usb_interface *i=
ntf)
>  	struct net_device	*net;
>
>  	dev =3D usb_get_intfdata(intf);
> -	usb_set_intfdata(intf, NULL);
>  	if (!dev)
>  		return;

I believe that call is there to prevent disconnect from running twice
for the common two-interface CDC ethernet model, like e.g. cdc_ether.
So I don't think it can be removed.  Not without touching the
minidrivers depending on that behaviour, anyway.


Bj=C3=B8rn
