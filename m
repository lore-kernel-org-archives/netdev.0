From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [patch] net: cdc_ncm: fix typo in test for supported formats
Date: Thu, 22 May 2014 10:27:57 +0200
Message-ID: <87oayqw73m.fsf@nemi.mork.no>
References: <20140522075229.GA4346@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38741 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbaEVKwY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 06:52:24 -0400
In-Reply-To: <20140522075229.GA4346@mwanda> (Dan Carpenter's message of "Thu,
	22 May 2014 10:52:29 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> There is a typo here where we test for USB_CDC_NCM_NTH32_SIGN instead
> of USB_CDC_NCM_NTB32_SUPPORTED.  The test probably still works as
> written because 0x686D636E has (1 << 1) set and doesn't have (1 << 0)
> set.
>
> Fixes: f8afb73da375 ('net: cdc_ncm: factor out one-time device initia=
lization')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Static analysis.  Untested.  Applies on -next
>
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index ad2a386..93c9ca9 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -357,7 +357,8 @@ static int cdc_ncm_init(struct usbnet *dev)
>  	 * "The host shall only send this command while the NCM Data
>  	 *  Interface is in alternate setting 0."
>  	 */
> -	if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) & USB_CDC_NCM_=
NTH32_SIGN) {
> +	if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) &
> +						USB_CDC_NCM_NTB32_SUPPORTED) {
>  		dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit\n");
>  		err =3D usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
>  				       USB_TYPE_CLASS | USB_DIR_OUT


Thanks!  Yes, that is correct.

I actually thought I had fixed that bug a while ago, but instead I
managed to just copy it while refactoring.  Impressive...


It doesn't matter whether (1 << 0) is set.  In fact it always will be.
What makes this work despite the bug is that no other bits will ever be
set - they are all reserved and must be zero.  But the spec also
requires us to ignore them, so your fix is definitely needed.


Bj=C3=B8rn
