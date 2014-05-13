From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max
 update of setup
Date: Tue, 13 May 2014 11:09:25 +0200
Message-ID: <1399972165.8278.11.camel@linux-fkkt.site>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
	 <1399736509-1159-2-git-send-email-bjorn@mork.no>
	 <1399968546.8278.2.camel@linux-fkkt.site> <871tvy2hcp.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49101 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759089AbaEMJJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 05:09:27 -0400
In-Reply-To: <871tvy2hcp.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-13 at 10:49 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> writes:
>=20
> > On Sat, 2014-05-10 at 17:41 +0200, Bj=C3=B8rn Mork wrote:

> >> +	/* clamp new_rx to sane values */
> >> +	min =3D min_t(u32, USB_CDC_NCM_NTB_MIN_IN_SIZE, le32_to_cpu(ctx-=
>ncm_parm.dwNtbInMaxSize));
> >> +	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm=
_parm.dwNtbInMaxSize));
> >
> > Are you sure this makes sense? min_t both times?
>=20
> Yes, I am sure.  At least it made sense when I wrote it.  I am more i=
n
> doubt now.

I actually suspected a copy n' paste error; thence the formulation.

> I guess you don't question the max calculation, but just so everyone
> else gets the idea: dwNtbInMaxSize is the buffer size suggested by th=
e
> device. Some devices just specify an insanely large value (132kB has
> been observed). So we need to cap that to CDC_NCM_NTB_MAX_SIZE_RX, wh=
ich
> is the absolutely largest buffer size we are prepared to support.

Good

> USB_CDC_NCM_NTB_MIN_IN_SIZE is the minimum acceptable buffer size
> according to the spec. dwNtbInMaxSize is not allowed to be smaller th=
an
> this.  So if we assume that no device violates the spec, then the abo=
ve
> should simple be
>=20
> 	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
> 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_par=
m.dwNtbInMaxSize));
>=20
> which is the result for all spec conforming devices.
>=20
> The reason I put that min_t() there instead was an attempt to deal wi=
th
> the (not unlikely) event that some buggy device set dwNtbInMaxSize lo=
wer
> than this required minimum value.  We then have the choices:
>=20
>  a) fail to support the buggy device
>  b) attempt to set a larger buffer size than the device supports
>  c) accept the lower size

My preference would be b) > a) > c)
It seems to me that would should respect the spec and if the spec sets
a lower limit then we don't go lower.

> So I chose c) in an attempt to be as gentle as possible.  But I am op=
en
> to go for a) instead if you think that is better. After all
> USB_CDC_NCM_NTB_MIN_IN_SIZE is as low as 2048, so it doesn't fit much
> more than the headers and a single full size ethernet frame.  And I s=
ee
> now that we fail to do further sanity checking after this.  What if
> dwNtbInMaxSize is 0? Or smaller than the necessary headers?

Exactly. Some fool may simply overlook setting it at all.

> Should I rewrite the above to do a) instead?  I.e.
>=20
> 	min =3D USB_CDC_NCM_NTB_MIN_IN_SIZE;
> 	max =3D min_t(u32, CDC_NCM_NTB_MAX_SIZE_RX, le32_to_cpu(ctx->ncm_par=
m.dwNtbInMaxSize));
>         if (min > max)
>            fail;
>=20
> I don't think b) is a good idea.  It might work, but it might also fa=
il
> in surprising ways making it hard to debug.

Users may prefer working devices to clean failures, but
I primarily care about conforming to spec. We just shouldn't
do such violations in a general case.

	Regards
		Oliver
