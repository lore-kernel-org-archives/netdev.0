From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][BUG-FIX] the problem of checksum checking in UDP protocol
Date: Mon, 28 Jun 2010 22:38:32 +0200
Message-ID: <1277757512.4235.750.camel@edumazet-laptop>
References: <4C19E634.3030703@cn.fujitsu.com>
	 <1277530086.2481.15.camel@edumazet-laptop>  <4C287E40.40906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:52383 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753034Ab0F1Uij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 16:38:39 -0400
Received: by wwi17 with SMTP id 17so3870wwi.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 13:38:36 -0700 (PDT)
In-Reply-To: <4C287E40.40906@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 18:49 +0800, Shan Wei a =C3=A9crit :
> Eric Dumazet wrote, at 06/26/2010 01:28 PM:
> >> (This patch is not complete, it's just for my idea.)
> >> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> >> index 1dd1aff..47f7e86 100644
> >> --- a/net/ipv6/udp.c
> >> +++ b/net/ipv6/udp.c
> >> @@ -723,6 +723,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struc=
t udp_table *udptable,
> >>                 if (ulen < skb->len) {
> >>                         if (pskb_trim_rcsum(skb, ulen))
> >>                                 goto short_packet;
> >> +
> >> +                       if (skb_csum_unnecessary(skb))
> >> +                               skb->ip_summed =3D CHECKSUM_NONE;
> >> +
> >>                         saddr =3D &ipv6_hdr(skb)->saddr;
> >>                         daddr =3D &ipv6_hdr(skb)->daddr;
> >>                         uh =3D udp_hdr(skb);
> >>
> >=20
> > I really dont know if this fix is the right one.
> >=20
> > pskb_trim_rcsum() already contains a check. Should this check be ch=
anged
> > to include yours ?
>=20
> Oh..... I don't think so.
> pskb_trim_rcsum() is also used when IPv4/IPv6 protocol receiving pack=
ets
> and reassembling fragments. IP protocol does the right check and shou=
ld
> trust CHECKSUM_UNNECESSARY flag that drivers set, So we no need to=20
> change IP protocol.
> If we add the skb_csum_unnecessary(skb) check into pskb_trim_rcsum() =
and
> reset ip_summed with CHECKSUM_NONE, the checksum check that NIC hardw=
ard=20
> has done is wasted.
>=20
> Only for UDP protocol over IPv4/IPv6, and length parameter is lower t=
han
> skb->len, We reset ip_summed with CHECKSUM_NONE.
>=20
>=20

I read RFC 768 again, and cannot tell if your patch is ever needed.

NIC validated the UDP checksum including the whole IP data length, not
the udp length.

Linux kernel computes checksum using udp.length, not ip.length, because
only udp.length is delivered to application anyway. Extra padding is
meaningless.

RFC 768 author didnt asserted ip.length =3D udp.length + 8

Both implementations are RFC compliant, but may have different results
with special hand crafted packets.

You add a test for a non issue, my analysis is we should not care at
all, unless you have another valid point (security ???)

If a change is needed, I would vote for a change in NIC firmware,
because RFC 768 gives following pseudo header :

0      7 8     15 16    23 24    31=20
+--------+--------+--------+--------+
|          source address           |
+--------+--------+--------+--------+
|        destination address        |
+--------+--------+--------+--------+
|  zero  |protocol|   UDP length    |
+--------+--------+--------+--------+

Note it mentions UDP length, not IP length.

If NIC reports UDP check sum was verified, it should have used UDP leng=
th as well.



