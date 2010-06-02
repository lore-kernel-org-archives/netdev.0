From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: add LINUX_MIB_IPRPFILTER snmp counter
Date: Thu, 03 Jun 2010 00:05:27 +0200
Message-ID: <1275516327.29413.34.camel@edumazet-laptop>
References: <1275496439.2725.203.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021140320.30182@router.home>
	 <20100602.101258.134121018.davem@davemloft.net>
	 <20100602.103102.121237521.davem@davemloft.net>
	 <1275500802.2519.7.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021255001.32431@router.home>
	 <1275504070.2519.12.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021355040.32431@router.home>
	 <1275506732.2519.23.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021506560.32431@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:35752 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758048Ab0FBWFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 18:05:33 -0400
Received: by wwb28 with SMTP id 28so3296792wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 15:05:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021506560.32431@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 15:11 -0500, Christoph Lameter a =C3=A9=
crit :=20
> On Wed, 2 Jun 2010, Eric Dumazet wrote:

>=20
> > Here is patch I am currently testing.
> >
> > I finaly created a new counter, because its a linux specific check.
>=20
> Looks good which does not say too much given my limited networking
> knowledge.
>=20
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

I had one correction to do, here is the official submission.

I did unicast tests only.

Thanks !

[PATCH net-next-2.6] ipv4: add LINUX_MIB_IPRPFILTER snmp counter

Christoph Lameter mentioned that packets could be dropped in input path
because of rp_filter settings, without any SNMP counter being
incremented. System administrator can have a hard time to track the
problem.

This patch introduces a new counter, LINUX_MIB_IPRPFILTER, incremented
each time we drop a packet because Reverse Path Filter triggers.

(We receive an IPv4 datagram on a given interface, and find the route t=
o
send an answer would use another interface)

netstat -s | grep IPReversePathFilter
    IPReversePathFilter: 21714

Reported-by: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/snmp.h    |    1 +
 net/ipv4/fib_frontend.c |    6 ++++--
 net/ipv4/ip_input.c     |    3 +++
 net/ipv4/proc.c         |    1 +
 net/ipv4/route.c        |   31 ++++++++++++++++++-------------
 5 files changed, 27 insertions(+), 15 deletions(-)

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
index 8495bce..d377b45 100644
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
@@ -1920,8 +1923,10 @@ e_nobufs:
 	return -ENOBUFS;
=20
 e_inval:
+	err =3D -EINVAL;
+e_err:
 	in_dev_put(in_dev);
-	return -EINVAL;
+	return err;
 }
=20
=20
@@ -1985,7 +1990,6 @@ static int __mkroute_input(struct sk_buff *skb,
 		ip_handle_martian_source(in_dev->dev, in_dev, skb, daddr,
 					 saddr);
=20
-		err =3D -EINVAL;
 		goto cleanup;
 	}
=20
@@ -2157,13 +2161,12 @@ static int ip_route_input_slow(struct sk_buff *=
skb, __be32 daddr, __be32 saddr,
 		goto brd_input;
=20
 	if (res.type =3D=3D RTN_LOCAL) {
-		int result;
-		result =3D fib_validate_source(saddr, daddr, tos,
+		err =3D fib_validate_source(saddr, daddr, tos,
 					     net->loopback_dev->ifindex,
 					     dev, &spec_dst, &itag, skb->mark);
-		if (result < 0)
-			goto martian_source;
-		if (result)
+		if (err < 0)
+			goto martian_source_keep_err;
+		if (err)
 			flags |=3D RTCF_DIRECTSRC;
 		spec_dst =3D daddr;
 		goto local_input;
@@ -2191,7 +2194,7 @@ brd_input:
 		err =3D fib_validate_source(saddr, 0, tos, 0, dev, &spec_dst,
 					  &itag, skb->mark);
 		if (err < 0)
-			goto martian_source;
+			goto martian_source_keep_err;
 		if (err)
 			flags |=3D RTCF_DIRECTSRC;
 	}
@@ -2272,8 +2275,10 @@ e_nobufs:
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


