From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: Re: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Mon, 22 Oct 2007 15:10:46 +0800
Message-ID: <471C4CF6.1000206@cn.fujitsu.com>
References: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:60344 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbXJVHOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 03:14:20 -0400
In-Reply-To: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 =E5=86=99=E9=81=93:
> Gui Jianfeng wrote on 10/22/2007 11:37:07 AM:
>=20
>> @@ -310,8 +310,12 @@ static inline int ip_rcv_finish(struct s
>>      *   how the packet travels inside Linux networking.
>>      */
>>     if (skb->dst =3D=3D NULL) {
>> -      if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev=
))
>> -         goto drop;
>> +      int err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->=
tos,
> dev);
>> +      if (unlikely(err)) {
>> +         if (err =3D=3D -EHOSTUNREACH)
>> +            IP_INC_STATS_BH(IpInAddrErrors);
>> +      }
>> +      goto drop;
>>     }
>=20
> Shouldn't the "goto drop" be inside the "if (unlikely(err)) {" case?
> And normally it is nice to have a blank line after variable declarati=
on.
sorry for my careless, here is the correct one

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

-------
diff -Narup linux-2.4.35.3/net/ipv4/ip_input.c linux-2.4.35.3-prep/net/=
ipv4/ip_input.c
--- linux-2.4.35.3/net/ipv4/ip_input.c	2007-09-24 06:02:58.000000000 +0=
800
+++ linux-2.4.35.3-prep/net/ipv4/ip_input.c	2007-09-26 11:30:22.0000000=
00 +0800
@@ -310,8 +310,13 @@ static inline int ip_rcv_finish(struct s
 	 *	how the packet travels inside Linux networking.
 	 */=20
 	if (skb->dst =3D=3D NULL) {
-		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))
+		int err =3D ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, de=
v);
+
+		if (unlikely(err)) {
+			if (err =3D=3D -EHOSTUNREACH)
+				IP_INC_STATS_BH(IpInAddrErrors);
 			goto drop;=20
+		}
 	}
=20
 #ifdef CONFIG_NET_CLS_ROUTE
diff -Narup linux-2.4.35.3/net/ipv4/route.c linux-2.4.35.3-prep/net/ipv=
4/route.c
--- linux-2.4.35.3/net/ipv4/route.c	2007-09-24 06:02:58.000000000 +0800
+++ linux-2.4.35.3-prep/net/ipv4/route.c	2007-09-26 11:29:19.000000000 =
+0800
@@ -1450,7 +1450,7 @@ int ip_route_input_slow(struct sk_buff *
 	 */
 	if ((err =3D fib_lookup(&key, &res)) !=3D 0) {
 		if (!IN_DEV_FORWARD(in_dev))
-			goto e_inval;
+			goto e_hostunreach;
 		goto no_route;
 	}
 	free_res =3D 1;
@@ -1499,7 +1499,7 @@ int ip_route_input_slow(struct sk_buff *
 	}
=20
 	if (!IN_DEV_FORWARD(in_dev))
-		goto e_inval;
+		goto e_hostunreach;
 	if (res.type !=3D RTN_UNICAST)
 		goto martian_destination;
=20
@@ -1668,6 +1668,11 @@ martian_destination:
 			"%u.%u.%u.%u, dev %s\n",
 			NIPQUAD(daddr), NIPQUAD(saddr), dev->name);
 #endif
+
+e_hostunreach:
+	err =3D -EHOSTUNREACH;
+	goto done;
+
 e_inval:
 	err =3D -EINVAL;
 	goto done;

>=20
> - KK
>=20
>=20
>=20
