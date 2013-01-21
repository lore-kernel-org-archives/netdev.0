From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 15:08:22 +0100
Message-ID: <87r4ley6g9.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<22276933.xSGyXJfOvq@linux-5eaq.site> <871udiur74.fsf@nemi.mork.no>
	<CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:38226 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753759Ab3AUOIn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 09:08:43 -0500
In-Reply-To: <CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A@mail.gmail.com>
	(Alexey Orishko's message of "Sun, 20 Jan 2013 01:21:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexey,

I have another issue with the Sierra firmware which I hope you can help
me with: The MC7710 device requires at ZLP even if we send
dwNtbOutMaxSize sized NTBs. This is a problem because the current code
explicitly prevents this.

The following code in the v3.8 cdc-ncm was written to keep existing
behaviour from the pre-v3.8 driver:

	if (((skb_out->len % le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=
=3D 0) &&
	    (skb_out->len < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)) && skb=
_tailroom(skb_out))
		*skb_put(skb_out, 1) =3D 0;	/* force short packet */



The previous implementaion looked like this:

6c60408e (Alexey Orishko     2011-05-06 03:01:30 +0000  832)    if (((l=
ast_offset < ctx->tx_max) && ((last_offset %
6c60408e (Alexey Orishko     2011-05-06 03:01:30 +0000  833)           =
         le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=3D 0)) ||
6c60408e (Alexey Orishko     2011-05-06 03:01:30 +0000  834)        (((=
last_offset =3D=3D ctx->tx_max) && ((ctx->tx_max %
6c60408e (Alexey Orishko     2011-05-06 03:01:30 +0000  835)           =
 le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=3D 0)) &&
6c60408e (Alexey Orishko     2011-05-06 03:01:30 +0000  836)           =
 (ctx->tx_max < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)))) {
900d495a (Alexey Orishko     2010-11-29 23:23:28 +0000  837)           =
 /* force short packet */
900d495a (Alexey Orishko     2010-11-29 23:23:28 +0000  838)           =
 *(((u8 *)skb_out->data) + last_offset) =3D 0;
900d495a (Alexey Orishko     2010-11-29 23:23:28 +0000  839)           =
 last_offset++;
900d495a (Alexey Orishko     2010-11-29 23:23:28 +0000  840)    }


The effect is the same: We add a 0 byte if the NTB length is a multiplu=
m
of wMaxPacketSize *except* if the length is equal to dwNtbOutMaxSize.
This exception will happen very often because of the way we pad NTBs.

Now, I have tried to find what the above code was based on, and my gues=
s
is that it is this note in table 3-1 in the CDC NCM spec:

   If wBlockLength =3D 0x0000, the block is terminated by a
   short packet. In this case, the USB transfer must still
   be shorter than dwNtbInMaxSize or dwNtbOutMax-
   Size. If exactly dwNtbInMaxSize or dwNtbOutMaxSize
   bytes are sent, and the size is a multiple of wMax-
   PacketSize for the given pipe, then no ZLP shall be
   sent.

Is that correct?  I cannot find any special ZLP handling mentioned
anywhere else in the standard.

If so, then I believe it is a misinterpretation.  The above text deals
only with the exceptional case of wBlockLength =3D 0x0000, which we do =
not
do.  As long as wBlockLength > 0 then I believe the device is in its
full right to expect a ZLP if wBlockLength % wMaxPacketSize is 0.

Would you feel comfortable dropping the additional condition and going
with

	if (((skb_out->len % le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) =3D=
=3D 0) &&
	    skb_tailroom(skb_out))
		*skb_put(skb_out, 1) =3D 0;	/* force short packet */


? I have verified that this is sufficient to make the Sierra device
work.  I will of course test it with the other NCM and MBIM devices I'v=
e
got, but that is a very limited set...

The other option I see is making a device specific quirk for this.  But
I suspect that Sierra is using the current Qualcomm MBIM implemetation
here, and if so then we are likely to see a large number of similar
devices in the near future.  I'd really like to avoid having device
specific quirks for all of them if at all possible.



Bj=C3=B8rn
