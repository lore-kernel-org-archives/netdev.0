From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 21:25:32 +0200
Message-ID: <1275506732.2519.23.camel@edumazet-laptop>
References: <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
	 <20100602.103102.121237521.davem@davemloft.net>
	 <1275500802.2519.7.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021255001.32431@router.home>
	 <1275504070.2519.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021355040.32431@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54054 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597Ab0FBTZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 15:25:36 -0400
Received: by wyi11 with SMTP id 11so2159915wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 12:25:34 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021355040.32431@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 13:59 -0500, Christoph Lameter a =C3=A9=
crit :

> The rp_filter is rejecting traffic coming into a NIC for which the ke=
rnel
> has a multicast join list that indicates that this traffic is expecte=
d on
> this NIC. You could consult the MC subscription list to verify that t=
he
> traffic is coming into the right NIC.
>=20
> In the MC case the user can explicitly specify through which NIC the
> traffic is expected. See IP_ADD_MEMBERSHIP.

This has litle to do with MC. We certainly are not going to check MC
membership in fib_validate_source() !

Say we have eth0 on 192.168.0.1/24 and eth1 on 192.168.0.2/24

Then we cannot use rp_filter =3D 1, even with unicast trafic.

I really dont understand why you would setup rp_filter in such a
situation. This wont work.

Now, I agree we should have a counter somewhere to help admins to
understand their error ;)

Here is patch I am currently testing.

I finaly created a new counter, because its a linux specific check.

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 5279771..ebb0c80 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -229,6 +229,7 @@ enum
 	LINUX_MIB_TCPBACKLOGDROP,
 	LINUX_MIB_TCPMINTTLDROP, /* RFC 5082 */
 	LINUX_MIB_TCPDEFERACCEPTDROP,
+	LINUX_MIB_IPRPFILTER, /* IP Reverse Path Filter (rp_filter) */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 4f0ed45..e830f7a 100644
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
+	return -EXDEV;
 }
=20
 static inline __be32 sk_extract_addr(struct sockaddr *addr)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index d930dc5..d52c9da 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -340,6 +340,9 @@ static int ip_rcv_finish(struct sk_buff *skb)
 			else if (err =3D=3D -ENETUNREACH)
 				IP_INC_STATS_BH(dev_net(skb->dev),
 						IPSTATS_MIB_INNOROUTES);
+			else if (err =3D=3D -EXDEV)
+				NET_INC_STATS_BH(dev_net(skb->dev),
+						 LINUX_MIB_IPRPFILTER);
 			goto drop;
 		}
 	}
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3dc9914..e320ca6 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -252,6 +252,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPBacklogDrop", LINUX_MIB_TCPBACKLOGDROP),
 	SNMP_MIB_ITEM("TCPMinTTLDrop", LINUX_MIB_TCPMINTTLDROP),
 	SNMP_MIB_ITEM("TCPDeferAcceptDrop", LINUX_MIB_TCPDEFERACCEPTDROP),
+	SNMP_MIB_ITEM("IPReversePathFilter", LINUX_MIB_IPRPFILTER),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8495bce..3a264f7 100644
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
@@ -1985,7 +1991,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
=20
-		err =3D -EINVAL;
 		goto cleanup;
 	}
=20
@@ -2191,7 +2196,7 @@ brd_input:
 		err =3D fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
 					  &itag, skb->mark);
 		if (err < 0)
-			goto martian_source;
+			goto martian_source_keep_err;
 		if (err)
 			flags |=3D RTCF_DIRECTSRC;
 	}
@@ -2272,8 +2277,10 @@ e_nobufs:
 	goto done;
=20
 martian_source:
+	err =3D -EINVAL;
+martian_source_keep_err:
 	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
-	goto e_inval;
+	goto done;
 }
=20
 int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 sa=
ddr,


