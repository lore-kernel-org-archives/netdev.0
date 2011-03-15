From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Tue, 15 Mar 2011 16:34:37 +0100
Message-ID: <1300203277.2927.9.camel@edumazet-laptop>
References: <998769.91206.qm@web39301.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Timo Teras <timo.teras@iki.fi>
To: Doug Kehn <rdkehn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57062 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758035Ab1COPel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 11:34:41 -0400
Received: by fxm17 with SMTP id 17so689453fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 08:34:40 -0700 (PDT)
In-Reply-To: <998769.91206.qm@web39301.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 16:34 -0700, Doug Kehn a =C3=A9crit :
> Hi All,
>=20
> I'm running kernel version 2.6.36 on ARM XSCALE (big-endian) and mult=
icast over a multipoint GRE tunnel isn't working.  For my architecture,=
 this worked on 2.6.26.8.  For x86, multicast over a multipoint GRE tun=
nel worked with kernel version 2.6.31 but failed with version 2.6.35.  =
Multicast over a multipoint GRE tunnel fails because ipgre_header() fai=
ls the 'if (iph->daddr)' check and reutrns -t->hlen.  ipgre_header() is=
 being called, from neigh_connected_output(), with a non-null daddr; th=
e contents of daddr is zero.
>=20
> Reverting the ip_gre.c patch posted in http://marc.info/?l=3Dlinux-ne=
tdev&m=3D126762491525281&w=3D2 resolves the problem.  (Reviewing the HE=
AD of net-next-2.6 it appears that ipgre_header() remains unchanged fro=
m 2.6.36.)
>=20
> The configuration used to discover/diagnose the problem:
>=20
> ip tunnel add tun1 mode gre key 11223344 ttl 64 csum remote any
> ip link set dev tun1 up
> ip link set dev tun1 multicast on
> ip addr flush dev tun1
> ip addr add 10.40.92.114/24 broadcast 10.40.92.255 dev tun1
>=20
> 12: tun1: <MULTICAST,NOARP,UP,10000> mtu 1468 qdisc noqueue
>     link/gre 0.0.0.0 brd 0.0.0.0
>     inet 10.40.92.114/24 brd 10.40.92.255 scope global tun1
>=20
> Then attempt:
> ping -I tun1 224.0.0.9
>=20
> Are additional configuration steps now required for multicast over mu=
ltipoint GRE tunnel or is ipgre_header() in error?

Hi Doug

CC Timo Teras <timo.teras@iki.fi>

I would do a partial revert of Timo patch, but this means initial
concern should be addressed ?

(Timo mentioned :=20
	If the NOARP packets are not dropped, ipgre_tunnel_xmit() will
	take rt->rt_gateway (=3D NBMA IP) and use that for route
	look up (and may lead to bogus xfrm acquires).)


Is the following works for you ?

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index da5941f..47844fa2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1170,8 +1170,10 @@ static int ipgre_header(struct sk_buff *skb, str=
uct net_device *dev,
=20
 	if (saddr)
 		memcpy(&iph->saddr, saddr, 4);
-	if (daddr)
+	if (daddr) {
 		memcpy(&iph->daddr, daddr, 4);
+		return t->hlen;
+	}
 	if (iph->daddr)
 		return t->hlen;
=20


