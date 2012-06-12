From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next 4/4] 6lowpan: len field is not stored and
 accessed properly
Date: Tue, 12 Jun 2012 22:20:13 +0400
Message-ID: <CAJmB2rAYZe9FEfUcxd_g6kX247MExv89h=Cjfxmvfb+=6qGSgQ@mail.gmail.com>
References: <20120611004025.6f6129ca@dualbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Tony Cheneau <tony.cheneauh@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:55424 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752853Ab2FLSUP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 14:20:15 -0400
Received: by lahd3 with SMTP id d3so3743932lah.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 11:20:14 -0700 (PDT)
In-Reply-To: <20120611004025.6f6129ca@dualbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/11 Tony Cheneau <tony.cheneauh@amnesiak.org>:
> Lenght field should be encoded (and accessed) the other way around.
> As it is currently written, it could lead to interroperability issues=
=2E

What kind of "interroperability issues" can occur? Please describe it
in details, I can't read your mind. And again, can these problems be
caused by the byte-order mismatch?

>
> Also, I rewrote the code so that iphc0 argument of
> lowpan_alloc_new_frame could be removed.
> ---
> =A0net/ieee802154/6lowpan.c | =A0 20 ++++++++++++--------
> =A01 files changed, 12 insertions(+), 8 deletions(-)
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index af2f12e..b400156 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -654,7 +654,7 @@ static void lowpan_fragment_timer_expired(unsigne=
d
> long entry_addr) }
>
> =A0static struct lowpan_fragment *
> -lowpan_alloc_new_frame(struct sk_buff *skb, u8 iphc0, u8 len, u16 ta=
g)
> +lowpan_alloc_new_frame(struct sk_buff *skb, u16 len, u16 tag)
> =A0{
> =A0 =A0 =A0 =A0struct lowpan_fragment *frame;
>
> @@ -665,7 +665,7 @@ lowpan_alloc_new_frame(struct sk_buff *skb, u8
> iphc0, u8 len, u16 tag)
> =A0 =A0 =A0 =A0INIT_LIST_HEAD(&frame->list);
>
> - =A0 =A0 =A0 frame->length =3D (iphc0 & 7) | (len << 3);
> + =A0 =A0 =A0 frame->length =3D len;
> =A0 =A0 =A0 =A0frame->tag =3D tag;
>
> =A0 =A0 =A0 =A0/* allocate buffer for frame assembling */
> @@ -721,13 +721,17 @@ lowpan_process_data(struct sk_buff *skb)
> =A0 =A0 =A0 =A0case LOWPAN_DISPATCH_FRAGN:
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct lowpan_fragment *frame;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 len, offset;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 tag;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* slen stores the rightmost 8 bits of =
the 11 bits
> length */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 slen, offset;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 len, tag;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool found =3D false;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D lowpan_fetch_skb_u8(skb); /* fr=
ame length */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slen =3D lowpan_fetch_skb_u8(skb); /* f=
rame length */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tag =3D lowpan_fetch_skb_u16(skb);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* adds the 3 MSB to the 8 LSB to retri=
eve the 11 bits
> length */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D ((iphc0 & 7) << 8) | slen;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * check if frame assembling with the =
same tag is
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * already in progress
> @@ -742,7 +746,7 @@ lowpan_process_data(struct sk_buff *skb)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* alloc new frame structure */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!found) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D lowpan_alloc_=
new_frame(skb, iphc0,
> len, tag);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D lowpan_alloc_=
new_frame(skb, len, tag);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!frame)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto u=
nlock_and_drop;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1000,8 +1004,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb)
> =A0 =A0 =A0 =A0tag =3D fragment_tag++;
>
> =A0 =A0 =A0 =A0/* first fragment header */
> - =A0 =A0 =A0 head[0] =3D LOWPAN_DISPATCH_FRAG1 | (payload_length & 0=
x7);
> - =A0 =A0 =A0 head[1] =3D (payload_length >> 3) & 0xff;
> + =A0 =A0 =A0 head[0] =3D LOWPAN_DISPATCH_FRAG1 | ((payload_length >>=
 8) &
> 0x7);
> + =A0 =A0 =A0 head[1] =3D payload_length & 0xff;
> =A0 =A0 =A0 =A0head[2] =3D tag >> 8;
> =A0 =A0 =A0 =A0head[3] =3D tag & 0xff;
>
> --
> 1.7.3.4
>
