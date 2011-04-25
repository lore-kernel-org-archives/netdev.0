From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hight speed data sending from custom IP out of kernel
Date: Mon, 25 Apr 2011 14:14:29 +0200
Message-ID: <1303733669.2747.115.camel@edumazet-laptop>
References: <53f539ea861e1a24bde4aadceff0b3bb.squirrel@www.liukuma.net>
	 <4DAD76F1.40309@monstr.eu>
	 <45cb2254ff23a4977c95b0f9459e39a6.squirrel@www.liukuma.net>
	 <4DAFE4A0.2030905@monstr.eu> <1303373925.3685.6.camel@edumazet-laptop>
	 <4DB55876.2010008@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: juice@swagman.org, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758526Ab1DYMOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 08:14:34 -0400
Received: by wya21 with SMTP id 21so1495870wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 05:14:33 -0700 (PDT)
In-Reply-To: <4DB55876.2010008@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 13:18 +0200, Michal Simek a =C3=A9crit :
> Hi,
>=20
> Eric Dumazet wrote:
> > Le jeudi 21 avril 2011 =C3=A0 10:02 +0200, Michal Simek a =C3=A9cri=
t :
> >=20
> >> Thanks for that. I am looking at pktgen. On UDP my system is able =
to send full=20
> >> bandwidth on 100Mbit/s ethernet and 220Mbit/s on 1G/s.
> >> I will let you know when I have any useful resutls.
> >=20
> > 220Mbits/s in pktgen or an application ?
> > - how many packets per second ? (or packet size ?)
> >=20
> > pktgen has the "clone_skb 100" thing that avoid skb_alloc()/skb_fre=
e()
> > overhead, and permits to really test driver performance.
> >=20
> > It also bypass qdisc management.
> >=20
>=20
> I have reused the part of code from pktgen and I have found that I am=
 missing=20
> some IDs that's why I have done one simple patch(below) in pktgen whi=
ch is=20
> update IP ID field to find out if all packets are sent or not. As you=
 suggest I=20
> am also missing some IDs here.
> My question is if I can use any mechanism to ensure to sending all ID=
s?
>=20
> The next my question about packet fragments. Is it possible to setup =
IP=20
> fragments from higher level? I do it on low level as pktgen and I hav=
e change=20
> page address to memory which I need to send but it in under UDP.
>=20
> The point is to create packet with frags > 1 where the first fragment=
 is IP/TCP=20
> header and the second fragments contains pointer to data which are pr=
epared in=20
> the memory and will be copied directly by network driver. I am doing =
the same=20
> hacked code from pktgen. Is it possible to do it on higher level?
>=20

sendfile() is mostly doing this.

> Thanks,
> Michal
>=20
>=20
> For 2.6.37.6
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 33bc382..3429eb3 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -3500,6 +3500,13 @@ static void pktgen_xmit(struct pktgen_dev *pkt=
_dev)
>                  pkt_dev->last_pkt_size =3D pkt_dev->skb->len;
>                  pkt_dev->allocated_skbs++;
>                  pkt_dev->clone_count =3D 0;       /* reset counter *=
/
> +       } else {
> +               struct iphdr *iph;
> +               iph =3D ip_hdr(pkt_dev->skb);
> +               iph->id =3D htons(pkt_dev->ip_id);
> +               pkt_dev->ip_id++;
> +               iph->check =3D 0;
> +               iph->check =3D ip_fast_csum((void *)iph, iph->ihl);
>          }
>=20
>          if (pkt_dev->delay && pkt_dev->last_ok)
>=20
>=20
>=20


Well, you cant do that in pktgen, since you're changing previous packet
content (it might still be in device TX queue, not yet sent, or being
sent right now)

Now, if all you want to do is send many packets from pktgen (with only
ID changing), you could add a fast path to not rebuild from scratch new
packets.



