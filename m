From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 13:40:13 +0200
Message-ID: <1334835613.2395.71.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com>
	 <1334776707.2472.316.camel@edumazet-glaptop>
	 <1334778707.2472.333.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi>
	 <1334835018.2395.66.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38168 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab2DSLkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 07:40:21 -0400
Received: by bkcik5 with SMTP id ik5so6256848bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 04:40:20 -0700 (PDT)
In-Reply-To: <1334835018.2395.66.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 13:30 +0200, Eric Dumazet wrote:
> On Thu, 2012-04-19 at 14:10 +0300, Ilpo J=C3=A4rvinen wrote:
>=20
> > Now that you have non-zero offset_ack, are the tcp_fragment() calls=
ites=20
> > safe and working? ...I'm mostly worried about tcp_mark_head_lost wh=
ich=20
> > does some assumptions about tp->snd_una and TCP_SKB_CB(skb)->seq, h=
owever,=20
> > also other fragmenting does not preserve offset_ack properly (which=
 might=20
> > not be end of world though)?
>=20
> Good point, I'll take a look.

Hmm, the only point this could matter is if a packet is retransmitted.
=46or other packets, offset_ack =3D 0 (default value on skb allocation)

And tcp_retransmit_skb() first call tcp_trim_head(sk, skb) if needed so
tcp_fragment() is called with =3D=3D 0

        if (before(TCP_SKB_CB(skb)->seq, tp->snd_una)) {
                if (before(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
                        BUG();
                if (tcp_trim_head(sk, skb))
                        return -ENOMEM;
        }

=2E..
if (skb->len > cur_mss) {
	if (tcp_fragment(sk, skb, cur_mss, cur_mss))



I could add a BUG_ON(offset_ack =3D=3D 0) to make sure this assertion i=
s
true.

What do you think ?
