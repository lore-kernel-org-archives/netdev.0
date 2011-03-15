From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPsec tunnel forwarding in net-next-2.6 since 452edd59
Date: Tue, 15 Mar 2011 23:16:51 +0100
Message-ID: <1300227411.2565.7.camel@edumazet-laptop>
References: <4D7FB054.2090902@cbnco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Michael Smith <msmith@cbnco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52354 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab1COWRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 18:17:01 -0400
Received: by bwz15 with SMTP id 15so1021709bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 15:17:00 -0700 (PDT)
In-Reply-To: <4D7FB054.2090902@cbnco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 mars 2011 =C3=A0 14:30 -0400, Michael Smith a =C3=A9crit :
> Hi,
>=20
> I'm able to ping across a tunnel to a peer running net-next-2.6, but=20
> only to an interface on the peer; trying to ping a host behind the pe=
er=20
> fails. The incoming packet shows up in encrypted and decrypted form i=
n=20
> tcpdump, but it's not forwarded. None of the XFRM error counters are=20
> incremented; the packets just silently fail to be forwarded.
>=20
> There are no iptables rules and net.ipv4.ip_forward=3D1. The same con=
fig=20
> works on 2.6.38-rc8. git bisect pointed me to commit 452edd59 from Ma=
rch 2:
>=20
>      xfrm: Return dst directly from xfrm_lookup()
>=20
>      Instead of on the stack.
>=20
>=20
> ip xfrm policy:
>=20
> src 192.168.136.0/24 dst 192.168.137.0/24
>          dir out priority 2344 ptype main
>          tmpl src 1.1.1.136 dst 1.1.1.137
>                  proto esp reqid 16385 mode tunnel
>=20
> src 192.168.137.0/24 dst 192.168.136.0/24
>          dir fwd priority 2344 ptype main
>          tmpl src 1.1.1.137 dst 1.1.1.136
>                  proto esp reqid 16385 mode tunnel
>=20
> src 192.168.137.0/24 dst 192.168.136.0/24
>          dir in priority 2344 ptype main
>          tmpl src 1.1.1.137 dst 1.1.1.136
>                  proto esp reqid 16385 mode tunnel
>=20
> net-next-2.6 host is at 1.1.1.136 and 192.168.136.1. 2.6.35.10 host i=
s=20
> at 1.1.1.137 and 192.168.137.1. From that host:
>=20
> ping -I 192.168.137.1 192.168.136.1 -> success
> ping -I 192.168.137.1 192.168.136.2 -> silent failure
>=20
> Thanks,

Thanks for this excellent bug report !

Could you try following patch ?

[PATCH] xfrm: fix __xfrm_route_forward()

This function should return 0 in case of error, 1 if OK
commit 452edd598f60522 (xfrm: Return dst directly from xfrm_lookup())
got it wrong.

Reported-and-bisected-by: Michael Smith <msmith@cbnco.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1ba0258..027e3c6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2175,7 +2175,7 @@ int __xfrm_route_forward(struct sk_buff *skb, uns=
igned short family)
 	struct net *net =3D dev_net(skb->dev);
 	struct flowi fl;
 	struct dst_entry *dst;
-	int res =3D 0;
+	int res =3D 1;
=20
 	if (xfrm_decode_session(skb, &fl, family) < 0) {
 		XFRM_INC_STATS(net, LINUX_MIB_XFRMFWDHDRERROR);
@@ -2186,7 +2186,7 @@ int __xfrm_route_forward(struct sk_buff *skb, uns=
igned short family)
=20
 	dst =3D xfrm_lookup(net, skb_dst(skb), &fl, NULL, 0);
 	if (IS_ERR(dst)) {
-		res =3D 1;
+		res =3D 0;
 		dst =3D NULL;
 	}
 	skb_dst_set(skb, dst);



