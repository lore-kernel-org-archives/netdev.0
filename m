From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Wed, 20 Jan 2010 14:55:10 -0800
Message-ID: <55a4f86e1001201455j669bc401v56c5f5bf3857d19@mail.gmail.com>
References: <55a4f86e1001071705i33f8c58cubae56f5616216de4@mail.gmail.com>
	 <20100107.171015.29035630.davem@davemloft.net>
	 <b91784ff1001081612g7c15e968u5e77931289af25c@mail.gmail.com>
	 <20100110.131524.241344047.davem@davemloft.net>
	 <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lorenzo@google.com, therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:43074 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab0ATWzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 17:55:11 -0500
Received: by pwj9 with SMTP id 9so3504024pwj.21
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2010 14:55:10 -0800 (PST)
In-Reply-To: <55a4f86e1001131651j102b600fm1552a42866c3c671@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, could you comment on this?

2010/1/13 Maciej =C5=BBenczykowski <zenczykowski@gmail.com>:
> I believe you are looking for the following patch.
>
> I don't think it solves the problem of source based routing to any
> (significantly) greater extent than the previous patch.
> That would actually require iterating over all IPs assigned to any
> interface on our machine.
>
> However, I really don't understand the code (nor the precise issues
> involved) sufficiently well to be certain of that.
>
> I actually think the ipv4 code path suffers from a very similar probl=
em.
>
> Mind you - I don't think these issues are really significant problems=
,
> because they just mean we do PMTU once per (dest ip, src ip) instead
> of once per (dest ip).
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c2bd74c..dd8e3b3 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1562,14 +1562,13 @@ out:
> =C2=A0* =C2=A0 =C2=A0 i.e. Path MTU discovery
> =C2=A0*/
>
> -void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *sad=
dr,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 struct net_device *dev, u32 pmtu)
> +static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr=
 *saddr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct net *net, u32 pmtu, int ifindex)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct rt6_info *rt, *nrt;
> - =C2=A0 =C2=A0 =C2=A0 struct net *net =3D dev_net(dev);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int allfrag =3D 0;
>
> - =C2=A0 =C2=A0 =C2=A0 rt =3D rt6_lookup(net, daddr, saddr, dev->ifin=
dex, 0);
> + =C2=A0 =C2=A0 =C2=A0 rt =3D rt6_lookup(net, daddr, saddr, ifindex, =
0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rt =3D=3D NULL)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
>
> @@ -1637,6 +1636,31 @@ out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dst_release(&rt->u.dst);
> =C2=A0}
>
> +void rt6_pmtu_discovery(struct in6_addr *daddr, struct in6_addr *sad=
dr,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 struct net_device *dev, u32 pmtu)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct net *net =3D dev_net(dev);
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* RFC 1981 states that a node "MUST redu=
ce the size of the packets it
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* is sending along the path" that caused=
 the Packet Too Big message.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Since it's not possible in the general=
 case to determine which
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* interface was used to send the origina=
l packet, we update the MTU
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* on the interface that will be used to =
send future packets. We also
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* update the MTU on the interface that r=
eceived the Packet Too Big in
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* case the original packet was forced ou=
t that interface with
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* SO_BINDTODEVICE or similar. This is th=
e next best thing to the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* correct behaviour, which would be to u=
pdate the MTU on all
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* interfaces.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 rt6_do_pmtu_disc(daddr, saddr, net, pmtu, 0);
> + =C2=A0 =C2=A0 =C2=A0 rt6_do_pmtu_disc(daddr, saddr, net, pmtu, dev-=
>ifindex);
> + =C2=A0 =C2=A0 =C2=A0 /* also support source address based routing *=
/
> + =C2=A0 =C2=A0 =C2=A0 rt6_do_pmtu_disc(daddr, NULL, net, pmtu, 0);
> + =C2=A0 =C2=A0 =C2=A0 rt6_do_pmtu_disc(daddr, NULL, net, pmtu, dev->=
ifindex);
> +}
> +
> +
> =C2=A0/*
> =C2=A0* =C2=A0 =C2=A0 Misc support functions
> =C2=A0*/
>
