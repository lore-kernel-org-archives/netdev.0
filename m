From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max update of setup
Date: Tue, 13 May 2014 10:49:42 +0200
Message-ID: <871tvy2hcp.fsf@nemi.mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
	<1399736509-1159-2-git-send-email-bjorn@mork.no>
	<1399968546.8278.2.camel@linux-fkkt.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44656 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754763AbaEMIty convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 04:49:54 -0400
In-Reply-To: <1399968546.8278.2.camel@linux-fkkt.site> (Oliver Neukum's
	message of "Tue, 13 May 2014 10:09:06 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:

> On Sat, 2014-05-10 at 17:41 +0200, Bj=C3=B8rn Mork wrote:
>> Split out the part of setup dealing with updating the rx_max
>> and tx_max buffer sizes so that this code can be reused for
>> dynamically updating the limits.
>>=20
>> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>> ---
>>  drivers/net/usb/cdc_ncm.c | 81 +++++++++++++++++++++++++++++-------=
-----------
>>  1 file changed, 50 insertions(+), 31 deletions(-)
>>=20
>> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
>> index 549dbac710ed..87a32edf7ea5 100644
>> --- a/drivers/net/usb/cdc_ncm.c
>> +++ b/drivers/net/usb/cdc_ncm.c
>> @@ -65,6 +65,54 @@ static void cdc_ncm_tx_timeout_start(struct cdc_n=
cm_ctx *ctx);
>>  static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_=
timer);
>>  static struct usb_driver cdc_ncm_driver;
>> =20
>> +/* handle rx_max and tx_max changes */
>> +static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx,=
 u32 new_tx)
>> +{
>> +	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
>> +	u8 iface_no =3D ctx->control->cur_altsetting->desc.bInterfaceNumbe=
r;
>> +	u32 val, max, min;
>> +
>> +	/* clamp new_rx to sane values */
>> +	min =3D min_t(u32, USB_CDC_NCM_NTB_MIN_IN_SIZE, le32_to_cpu(ctx->n=
cm_parm.dwNtbInMaxSize));
>> +	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_p=
arm.dwNtbInMaxSize));
>
> Are you sure this makes sense? min_t both times?

Yes, I am sure.  At least it made sense when I wrote it.  I am more in
doubt now.

I guess you don't question the max calculation, but just so everyone
else gets the idea: dwNtbInMaxSize is the buffer size suggested by the
device. Some devices just specify an insanely large value (132kB has
been observed). So we need to cap that to CDC_NCM_NTB_MAX_SIZE_RX, whic=
h
is the absolutely largest buffer size we are prepared to support.

USB_CDC_NCM_NTB_MIN_IN_SIZE is the minimum acceptable buffer size
according to the spec. dwNtbInMaxSize is not allowed to be smaller than
this.  So if we assume that no device violates the spec, then the above
should simple be

	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_parm.=
dwNtbInMaxSize));

which is the result for all spec conforming devices.

The reason I put that min_t() there instead was an attempt to deal with
the (not unlikely) event that some buggy device set dwNtbInMaxSize lowe=
r
than this required minimum value.  We then have the choices:

 a) fail to support the buggy device
 b) attempt to set a larger buffer size than the device supports
 c) accept the lower size

So I chose c) in an attempt to be as gentle as possible.  But I am open
to go for a) instead if you think that is better. After all
USB_CDC_NCM_NTB_MIN_IN_SIZE is as low as 2048, so it doesn't fit much
more than the headers and a single full size ethernet frame.  And I see
now that we fail to do further sanity checking after this.  What if
dwNtbInMaxSize is 0? Or smaller than the necessary headers?

Should I rewrite the above to do a) instead?  I.e.

	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_parm.=
dwNtbInMaxSize));
        if (min > max)
           fail;

I don't think b) is a good idea.  It might work, but it might also fail
in surprising ways making it hard to debug.


Bj=C3=B8rn
