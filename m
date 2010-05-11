From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about more headroom in skb
Date: Tue, 11 May 2010 07:06:27 +0200
Message-ID: <1273554387.10889.23.camel@edumazet-laptop>
References: <682359.68270.qm@web112510.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Sharat Masetty <sharat_masetty@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39221 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab0EKFXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 01:23:30 -0400
In-Reply-To: <682359.68270.qm@web112510.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 13:09 -0700, Sharat Masetty a =C3=A9crit :
> Hello All,

Please dont use too long lines

>=20
> For my project I need 3 words of headroom in the skb in the network

>  driver level, to add a  custom header to the ethernet packet. I=20

> looked into the tcp code and figured out tcp uses sk->sk_prot->max_he=
ader=20

> for header allocation size. But I was not able to confirm that all ot=
her=20

> transport protocol use the same mechanism(?) For example in UDP/ICMP =
I was=20

> not able to figure out from the code where the allocation and header

>  reservation happens(Any light here would be really helpful.)
>=20
> I have also looked at an API in skbuff skb_pad() which does what I wa=
nt

> (add either headroom or tailroom), but I want to avoid that for perfo=
rmance

>  reasons(skb_pad does kmalloc and memcpy). I want to figure out a goo=
d way

> (may be tune some parameters) to allocate extra 3 words for any skbuf=
f=20

> independant of the transport protocol being used.=20

> Any light here would be very much appreciated.

LL_RESERVED_SPACE() is the magic you need.

#define LL_RESERVED_SPACE(dev) \
	((((dev)->hard_header_len+(dev)->needed_headroom)&~(HH_DATA_MOD - 1)) =
+ HH_DATA_MOD)

sendmsg() -> ip_append_data()
=2E..
hh_len =3D LL_RESERVED_SPACE(rt->u.dst.dev);
fragheaderlen =3D sizeof(struct iphdr) + (opt ? opt->optlen : 0);
=2E..

                if (transhdrlen) {
                        skb =3D sock_alloc_send_skb(sk,
                                        alloclen + hh_len + 15,
                                        (flags & MSG_DONTWAIT), &err);
                } else {
                        skb =3D NULL;
                        if (atomic_read(&sk->sk_wmem_alloc) <=3D
                            2 * sk->sk_sndbuf)
                                skb =3D sock_wmalloc(sk,
                                                   alloclen + hh_len + =
15, 1,
                                                   sk->sk_allocation);


