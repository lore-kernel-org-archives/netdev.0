From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: Re: tcp_shift_skb_data uses wrong mss in non-gso case?
Date: Mon, 23 Aug 2010 15:34:04 -0700
Message-ID: <AANLkTi=ygaa_fV4SwaLY2gP9H+Nn54QdXcGXkfGukSCD@mail.gmail.com>
References: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Robert Evans <robert.evans@nasdaqomx.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37710 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab0HWWeG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 18:34:06 -0400
Received: by yxg6 with SMTP id 6so2330680yxg.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 15:34:04 -0700 (PDT)
In-Reply-To: <D3B72A8DFCA0A8418CB61D1E9E310A99E5F35219@US01XMB01.org.nasdaqomx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC Ilpo, the creator of this patch being discussed:

On Tue, Aug 17, 2010 at 3:35 PM, Robert Evans
<robert.evans@nasdaqomx.com> wrote:
> Hello all,
>
> In reading through the latest SACK code introduced by 832d11c, I have=
 noticed
> that for the in_sack case tcp_shift_skb will take mss =3D tcp_skb_seg=
len(skb).
> This seems to be wrong since the queue might contain small packets (f=
=2Ee.
> TCP_NODELAY). If the collapse succeeds, the resulting skb will have a=
n
> arbitrarily small gso_size equal to the original skb length.

yeah, gso_size really should never be =3D=3D skb->length, because then =
it
implies you're offloading a frame to be segmented with no segmentable
data.

> 8ed88d4:net/ipv4/tcp_input.c
> =A0 1506 =A0 =A0 =A0 =A0 in_sack =3D !after(start_seq, TCP_SKB_CB(skb=
)->seq) &&
> =A0 1507 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !before(end_seq, TCP_SKB=
_CB(skb)->end_seq);
> =A0 1508
> =A0 1509 =A0 =A0 =A0 =A0 if (in_sack) {
> =A0 1510 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len =3D skb->len;
> =A0 1511 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pcount =3D tcp_skb_pcount(sk=
b);
> =A0 1512 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D tcp_skb_seglen(skb);=
 =A0 =A0 /* possibly wrong? */
> =A0 1513
> =A0 1514 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TODO: Fix DSACKs to not f=
ragment already SACKed and w
> =A0 1514 e can
> =A0 1515 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* drop this restriction a=
s unnecessary
> =A0 1516 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 1517 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mss !=3D tcp_skb_seglen(=
prev))
> =A0 1518 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fallbac=
k;
> =A0 1519 =A0 =A0 =A0 =A0 } else {
>
> This ends up being troublesome if the segment is later retransmitted =
and the
> device driver has trouble with very small gso_size (e1000e seems to b=
e an
> example).

I bet lots of other drivers will have issue with this too.

> Is the small gso_size the correct and/or desired behavior? =A0Or am I=
 missing
> something else that prevents this from being a problem?

I believe that this is invalid for the stack to do, Ilpo, Herbert?
what do you think?
