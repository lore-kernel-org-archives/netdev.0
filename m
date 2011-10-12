From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Wed, 12 Oct 2011 06:06:35 +0200
Message-ID: <1318392395.3686.12.camel@edumazet-laptop>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com>
	 <20111011143348.GA20605@gospo.rdu.redhat.com> <23119.1318348739@death>
	 <20111012025137.GB20605@gospo.rdu.redhat.com>
	 <CAN17JHVsgRqkOgeJ0+vvQe3kN1W0ue0vKHa3uebFHa9oH2ngXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	John Eaglesham <johneagl@yahoo-inc.com>
To: Yinglin Sun <yinglin.s@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46925 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab1JLEGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 00:06:42 -0400
Received: by wwf22 with SMTP id 22so420004wwf.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 21:06:41 -0700 (PDT)
In-Reply-To: <CAN17JHVsgRqkOgeJ0+vvQe3kN1W0ue0vKHa3uebFHa9oH2ngXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 octobre 2011 =C3=A0 20:39 -0700, Yinglin Sun a =C3=A9crit :
> On Tue, Oct 11, 2011 at 7:51 PM, Andy Gospodarek <andy@greyhouse.net>=
 wrote:
> >
> >        if (skb->protocol =3D=3D htons(ETH_P_IP)) {
> > +               struct iphdr *iph =3D ip_hdr(skb);
> > +               __be16 *layer4hdr =3D (__be16 *)((u32 *)iph + iph->=
ihl);
> >                if (!ip_is_fragment(iph) &&
> >                    (iph->protocol =3D=3D IPPROTO_TCP ||
> >                     iph->protocol =3D=3D IPPROTO_UDP)) {
> > @@ -3398,7 +3407,18 @@ static int bond_xmit_hash_policy_l34(struct =
sk_buff *skb, int count)
> >                }
> >                return (layer4_xor ^
> >                        ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff))=
 % count;
> > -
> > +       } else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
> > +               struct ipv6hdr *ipv6h =3D ipv6_hdr(skb);
> > +               __be16 *layer4hdrv6 =3D (__be16 *)((u8 *)ipv6h + si=
zeof(*ipv6h));
> > +               if (ipv6h->nexthdr =3D=3D IPPROTO_TCP || ipv6h->nex=
thdr =3D=3D IPPROTO_UDP) {
>=20
> Does this work if this is a fragmentation packet? and if
> ipv6h->nexthdr is not IPPROTO_TCP/IPPROTO_UDP, it doesn't mean this i=
s
> not TCP/UDP packet. We need to go through the extension header chain
> and look at the last one. It's likely there are some other extension
> headers before L4 header.
>=20

Its a best effort.

If first header is not IPPROTO_TCP/UDP, I am not sure its wise to spend
time in hope to find layer4 info (missing anyway in fragments)

By the way I see no bound checking on SKB head : malicious packet could
make bond_xmit_hash_policy_l34() access unitialized memory.

We have same 'fastpath' in __skb_get_rxhash()
