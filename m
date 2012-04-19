From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head()
 calls
Date: Thu, 19 Apr 2012 14:44:50 +0200
Message-ID: <1334839490.2395.160.camel@edumazet-glaptop>
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
	 <1334835613.2395.71.camel@edumazet-glaptop>
	 <alpine.DEB.2.00.1204191443040.735@wel-95.cs.helsinki.fi>
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
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59694 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab2DSMo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 08:44:57 -0400
Received: by bkcik5 with SMTP id ik5so6313827bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:44:55 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1204191443040.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-19 at 14:57 +0300, Ilpo J=C3=A4rvinen wrote:

> I'm not concerned of the output side, that seems to work because=20
> of the in tcp_retransmit_skb getting rid of the extra first.
>=20
> The ACK input stuff is more interesting, e.g., this one in=20
> tcp_mark_head_lost:
>=20
> 	err =3D tcp_fragment(sk, skb, (packets - oldcnt) * mss, mss);
>=20
> It splits from TCP_SKB_CB(skb)->seq + (packets - oldcnt) * mss wherea=
s
> I think the desired point would be: TCP_SKB_CB(skb)->seq + offset_ack=
 +=20
> (packets - oldcnt) * mss?
>=20
> ...There is similar case in sacktag code too while it's aligning to m=
ss=20
> boundaries in tcp_match_skb_to_sack.

Hmm yes, so maybe its safer to update TCP_SKB_CB(skb)->seq in
tcp_tso_acked() (as well as offset_ack) and make needed adjustements in
tcp_fragment() if we find offset_ack being not null.
