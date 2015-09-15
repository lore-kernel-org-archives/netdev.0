From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v3 net-next 2/2] ipv4: ICMP packet inspection for multipath
Date: Tue, 15 Sep 2015 22:29:53 +0200
Message-ID: <1442348993-3023-3-git-send-email-pch@ordbogen.com>
References: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:45572 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbbIOUam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 16:30:42 -0400
In-Reply-To: <1442348993-3023-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP packets are inspected to let them route together with the flow the=
y
belong to, minimizing the chance that a problematic path will affect fl=
ows
on other paths, and so that anycast environments can work with ECMP.

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 include/net/route.h | 12 +++++++++++-
 net/ipv4/icmp.c     | 16 ++++++++++++++++
 net/ipv4/route.c    | 54 +++++++++++++++++++++++++++++++++++++++++++++=
++++----
 3 files changed, 77 insertions(+), 5 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index cc61cb9..bbbae2c 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -28,6 +28,7 @@
 #include <net/inetpeer.h>
 #include <net/flow.h>
 #include <net/inet_sock.h>
+#include <net/ip_fib.h>
 #include <linux/in_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/rcupdate.h>
@@ -110,7 +111,16 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp)=
;
+struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 =
*flp,
+					  multipath_hash_func_t hash_func,
+					  void *ctx);
+
+static inline struct rtable *__ip_route_output_key(struct net *net,
+						   struct flowi4 *flp)
+{
+	return __ip_route_output_key_hash(net, flp, NULL, NULL);
+}
+
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    struct sock *sk);
 struct dst_entry *ipv4_blackhole_route(struct net *net,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 79fe05b..9d7c97c 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -440,6 +440,17 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+/* Source and destination is swapped. See ip_multipath_hash_skb */
+static int icmp_multipath_hash_skb(void *ctx)
+{
+	const struct sk_buff *skb =3D (const struct sk_buff *)ctx;
+	const struct iphdr *iph =3D ip_hdr(skb);
+
+	return jhash_2words(iph->daddr, iph->saddr, fib_multipath_secret);
+}
+#endif
+
 static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
@@ -464,7 +475,12 @@ static struct rtable *icmp_route_lookup(struct net=
 *net,
 	fl4->flowi4_oif =3D vrf_master_ifindex(skb_in->dev) ? : skb_in->dev->=
ifindex;
=20
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	rt =3D __ip_route_output_key_hash(net, fl4, icmp_multipath_hash_skb,
+					skb_in);
+#else
 	rt =3D __ip_route_output_key(net, fl4);
+#endif
 	if (IS_ERR(rt))
 		return rt;
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 41d977c..b472d8c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1648,11 +1648,51 @@ out:
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
+static noinline int ip_multipath_icmp_hash_skb(struct sk_buff *skb)
+{
+	const struct iphdr *outer_iph =3D ip_hdr(skb);
+	struct icmphdr _icmph;
+	const struct icmphdr *icmph;
+	struct iphdr _inner_iph;
+	const struct iphdr *inner_iph;
+
+	if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) !=3D 0))
+		goto standard_hash;
+
+	icmph =3D skb_header_pointer(skb, outer_iph->ihl * 4, sizeof(_icmph),
+				   &_icmph);
+	if (!icmph)
+		goto standard_hash;
+
+	if (icmph->type !=3D ICMP_DEST_UNREACH &&
+	    icmph->type !=3D ICMP_REDIRECT &&
+	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
+	    icmph->type !=3D ICMP_PARAMETERPROB) {
+		goto standard_hash;
+	}
+
+	inner_iph =3D skb_header_pointer(skb,
+				       outer_iph->ihl * 4 + sizeof(_icmph),
+				       sizeof(_inner_iph), &_inner_iph);
+	if (!inner_iph)
+		goto standard_hash;
+
+	return jhash_2words(inner_iph->daddr, inner_iph->saddr,
+			    fib_multipath_secret);
+
+standard_hash:
+	return jhash_2words(outer_iph->saddr, outer_iph->daddr,
+			    fib_multipath_secret);
+}
+
 static int ip_multipath_hash_skb(void *ctx)
 {
-	const struct sk_buff *skb =3D (struct sk_buff *)ctx;
+	struct sk_buff *skb =3D (struct sk_buff *)ctx;
 	const struct iphdr *iph =3D ip_hdr(skb);
=20
+	if (unlikely(iph->protocol =3D=3D IPPROTO_ICMP))
+		return ip_multipath_icmp_hash_skb(skb);
+
 	return jhash_2words(iph->saddr, iph->daddr, fib_multipath_secret);
 }
=20
@@ -2056,7 +2096,9 @@ add:
  * Major route resolver routine.
  */
=20
-struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *f=
l4)
+struct rtable *__ip_route_output_key_hash(struct net *net, struct flow=
i4 *fl4,
+					  multipath_hash_func_t hash_func,
+					  void *ctx)
 {
 	struct net_device *dev_out =3D NULL;
 	__u8 tos =3D RT_FL_TOS(fl4);
@@ -2218,8 +2260,12 @@ struct rtable *__ip_route_output_key(struct net =
*net, struct flowi4 *fl4)
 	}
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
-		fib_select_multipath(&res, ip_multipath_hash_fl4, fl4);
+	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0) {
+		if (hash_func)
+			fib_select_multipath(&res, hash_func, ctx);
+		else
+			fib_select_multipath(&res, ip_multipath_hash_fl4, fl4);
+	}
 	else
 #endif
 	if (!res.prefixlen &&
--=20
2.1.4
