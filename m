From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: increase command buffer
 size
Date: Wed, 18 Jun 2014 09:03:17 -0500
Message-ID: <1403100197.2266.14.camel@dcbw.local>
References: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Enrico Mioso <mrkiko.rs@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46974 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbaFRODZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 10:03:25 -0400
In-Reply-To: <1403094084-13588-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 14:21 +0200, Bj=C3=B8rn Mork wrote:
> Messages from the modem exceeding 256 bytes cause communication
> failure.
>=20
> The WDM protocol is strictly "read on demand", meaning that we only
> poll for unread data after receiving a notification from the modem.
> Since we have no way to know how much data the modem has to send,
> we must make sure that the buffer we provide is "big enough".
> Message truncation does not work. Truncated messages are left unread
> until the modem has another message to send.  Which often won't
> happen until the userspace application has given up waiting for the
> final part of the last message, and therefore sends another command.
>=20
> With a proper CDC WDM function there is a descriptor telling us
> which buffer size the modem uses. But with this vendor specific
> implementation there is no known way to calculate the exact "big
> enough" number.  It is an unknown property of the modem firmware.
> Experience has shown that 256 is too small.  The discussion of
> this failure ended up concluding that 512 might be too small as
> well. So 1024 seems like a reasonable value for now.
>=20
> Fixes: 41c47d8cfd68 ("net: huawei_cdc_ncm: Introduce the huawei_cdc_n=
cm driver")
> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
> Reported-by: Dan Williams <dcbw@redhat.com>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

Tested-by: Dan Williams <dcbw@redhat.com>

'<CR><LF>^SYSCFGEX:
("00","01","02","03","99"),((400380,"GSM900/GSM1800/WCDMA2100"),(6a8000=
0,"GSM850/GSM1900/WCDMA850/AWS/WCDMA1900"),(3fffffff,"All bands")),(0-2=
),(0-4),((1081b,"LTE_B1/LTE_B2/LTE_B4/LTE_B5/LTE_B12/LTE_B17"),(7ffffff=
fffffffff,"All bands"))<CR><LF><CR><LF>OK<CR><LF>'

I get the last "<LF>" now :)

> ---
>=20
> The problem is a showstopper for anyone hitting it, so I believe this
> fix should go into all maintained stable kernels with this driver.
> That is anything based on v3.13 or newer.
>=20
> Thanks,
> Bj=C3=B8rn
>=20
>=20
>  drivers/net/usb/huawei_cdc_ncm.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/usb/huawei_cdc_ncm.c b/drivers/net/usb/huawe=
i_cdc_ncm.c
> index f9822bc75425..5d95a13dbe2a 100644
> --- a/drivers/net/usb/huawei_cdc_ncm.c
> +++ b/drivers/net/usb/huawei_cdc_ncm.c
> @@ -84,12 +84,13 @@ static int huawei_cdc_ncm_bind(struct usbnet *usb=
net_dev,
>  	ctx =3D drvstate->ctx;
> =20
>  	if (usbnet_dev->status)
> -		/* CDC-WMC r1.1 requires wMaxCommand to be "at least 256
> -		 * decimal (0x100)"
> +		/* The wMaxCommand buffer must be big enough to hold
> +		 * any message from the modem. Experience has shown
> +		 * that some replies are more than 256 bytes long
>  		 */
>  		subdriver =3D usb_cdc_wdm_register(ctx->control,
>  						 &usbnet_dev->status->desc,
> -						 256, /* wMaxCommand */
> +						 1024, /* wMaxCommand */
>  						 huawei_cdc_ncm_wdm_manage_power);
>  	if (IS_ERR(subdriver)) {
>  		ret =3D PTR_ERR(subdriver);
