From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 04 Feb 2012 17:58:35 +0100
Message-ID: <1328374715.2731.21.camel@edumazet-laptop>
References: <4F2B7DF1.5050303@oktetlabs.ru>
	  <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328358402.2731.11.camel@edumazet-laptop>
	 <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41736 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2BDQ6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 11:58:42 -0500
Received: by wgbdt10 with SMTP id dt10so4854962wgb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 08:58:40 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 17:48 +0200, Julian Anastasov a =C3=
=A9crit :

> 	flowi4_tos is missing from this list but anyways,
> it looks wrong because __ip_route_output_key returns data
> in saddr and daddr, such change will break source address
> autoselection and destination address autoselection. That is
> what ip_route_connect is trying to do. May be
> ip_route_connect should be fixed instead?
>=20

Thanks Julian, this is indeed tricky.

I tested successfully the following patch, maybe we also need
to restore tos bits ?

diff --git a/include/net/route.h b/include/net/route.h
index 91855d1..f27a82d 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -272,7 +272,9 @@ static inline struct rtable *ip_route_connect(struc=
t flowi4 *fl4,
 		ip_rt_put(rt);
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
-	return ip_route_output_flow(net, fl4, sk);
+	rt =3D ip_route_output_flow(net, fl4, sk);
+	fl4->flowi4_oif =3D oif;
+	return rt;
 }
=20
 static inline struct rtable *ip_route_newports(struct flowi4 *fl4, str=
uct rtable *rt,
