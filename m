From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 19:46:42 +0200
Message-ID: <1275500802.2519.7.camel@edumazet-laptop>
References: <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
	 <20100602.103102.121237521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:38692 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633Ab0FBRqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:46:46 -0400
Received: by wwb28 with SMTP id 28so3101509wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 10:46:44 -0700 (PDT)
In-Reply-To: <20100602.103102.121237521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 10:31 -0700, David Miller a =C3=A9crit =
:
> Just in case people are really so clueless as to be unable to figure
> this out:
>=20
> echo 1 >/sys/kernel/debug/tracing/events/skb/kfree_skb/enable
> ...do some stuff...
> cat /sys/kernel/debug/tracing/trace
>=20
> You can even trace it using 'perf' by passing "skb:kfree_skb"
> as the event specifier.

Thanks !

Here is the patch I cooked to account for RP_FILTER errors in multicast
path.

I will complete it to also do the unicast part before official
submission.

Christoph, the official counter would be IPSTATS_MIB_INNOROUTES

ipSystemStatsInNoRoutes OBJECT-TYPE
    SYNTAX     Counter32
    MAX-ACCESS read-only
    STATUS     current
    DESCRIPTION
           "The number of input IP datagrams discarded because no route
            could be found to transmit them to their destination.



diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4f0ed45..f207289 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -284,7 +284,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 =
tos, int oif,
 	if (no_addr)
 		goto last_resort;
 	if (rpf =3D=3D 1)
-		goto e_inval;
+		goto e_rpf;
 	fl.oif =3D dev->ifindex;
=20
 	ret =3D 0;
@@ -299,7 +299,7 @@ int fib_validate_source(__be32 src, __be32 dst, u8 =
tos, int oif,
=20
 last_resort:
 	if (rpf)
-		goto e_inval;
+		goto e_rpf;
 	*spec_dst =3D inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
 	*itag =3D 0;
 	return 0;
@@ -308,6 +308,8 @@ e_inval_res:
 	fib_res_put(&res);
 e_inval:
 	return -EINVAL;
+e_rpf:
+	return -ENETUNREACH;
 }
=20
 static inline __be32 sk_extract_addr(struct sockaddr *addr)
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8495bce..8e9e2f9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1851,6 +1851,7 @@ static int ip_route_input_mc(struct sk_buff *skb,=
 __be32 daddr, __be32 saddr,
 	__be32 spec_dst;
 	struct in_device *in_dev =3D in_dev_get(dev);
 	u32 itag =3D 0;
+	int err;
=20
 	/* Primary sanity checks. */
=20
@@ -1865,10 +1866,12 @@ static int ip_route_input_mc(struct sk_buff *sk=
b, __be32 daddr, __be32 saddr,
 		if (!ipv4_is_local_multicast(daddr))
 			goto e_inval;
 		spec_dst =3D inet_select_addr(dev, 0, RT_SCOPE_LINK);
-	} else if (fib_validate_source(saddr, 0, tos, 0,
-					dev, &spec_dst, &itag, 0) < 0)
-		goto e_inval;
-
+	} else {
+		err =3D fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
+					  &itag, 0);
+		if (err < 0)
+			goto e_err;
+	}
 	rth =3D dst_alloc(&ipv4_dst_ops);
 	if (!rth)
 		goto e_nobufs;
@@ -1922,6 +1925,9 @@ e_nobufs:
 e_inval:
 	in_dev_put(in_dev);
 	return -EINVAL;
+e_err:
+	in_dev_put(in_dev);
+	return err;
 }
=20
=20


