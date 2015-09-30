From: =?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
Subject: [PATCH v5 net-next 2/2] ipv4: ICMP packet inspection for multipath
Date: Wed, 30 Sep 2015 10:12:22 +0200
Message-ID: <1443600742-20516-3-git-send-email-pch@ordbogen.com>
References: <1443600742-20516-1-git-send-email-pch@ordbogen.com>
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
Received: from mail.ordbogen.com ([91.240.88.21]:38330 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754515AbbI3IMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 04:12:37 -0400
In-Reply-To: <1443600742-20516-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=C3=B8rlund <pch@ordbogen.com>

ICMP packets are inspected to let them route together with the flow the=
y
belong to, minimizing the chance that a problematic path will affect fl=
ows
on other paths, and so that anycast environments can work with ECMP.

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 include/net/route.h |   11 +++++++++-
 net/ipv4/icmp.c     |   19 ++++++++++++++++-
 net/ipv4/route.c    |   59 +++++++++++++++++++++++++++++++++++++++++++=
++------
 3 files changed, 80 insertions(+), 9 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index f46af25..7d79c05 100644
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
@@ -110,7 +111,15 @@ struct in_device;
 int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
-struct rtable *__ip_route_output_key(struct net *, struct flowi4 *flp)=
;
+struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 =
*flp,
+					  int mp_hash);
+
+static inline struct rtable *__ip_route_output_key(struct net *net,
+						   struct flowi4 *flp)
+{
+	return __ip_route_output_key_hash(net, flp, -1);
+}
+
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    struct sock *sk);
 struct dst_entry *ipv4_blackhole_route(struct net *net,
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5eb8ac..b3a1620 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -440,6 +440,22 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+
+/* Source and destination is swapped. See ip_multipath_icmp_hash */
+static int icmp_multipath_hash_skb(const struct sk_buff *skb)
+{
+	const struct iphdr *iph =3D ip_hdr(skb);
+
+	return fib_multipath_hash(iph->daddr, iph->saddr);
+}
+
+#else
+
+#define icmp_multipath_hash_skb(skb) (-1)
+
+#endif
+
 static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
@@ -464,7 +480,8 @@ static struct rtable *icmp_route_lookup(struct net =
*net,
 	fl4->flowi4_oif =3D vrf_master_ifindex(skb_in->dev);
=20
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt =3D __ip_route_output_key(net, fl4);
+	rt =3D __ip_route_output_key_hash(net, fl4,
+					icmp_multipath_hash_skb(skb_in));
 	if (IS_ERR(rt))
 		return rt;
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 64367f3..a2479a4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1646,6 +1646,48 @@ out:
 	return err;
 }
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+
+/* To make ICMP packets follow the right flow, the multipath hash is
+ * calculated from the inner IP addresses in reverse order.
+ */
+static int ip_multipath_icmp_hash(struct sk_buff *skb)
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
+	return fib_multipath_hash(inner_iph->daddr, inner_iph->saddr);
+
+standard_hash:
+	return fib_multipath_hash(outer_iph->saddr, outer_iph->daddr);
+}
+
+#endif /* CONFIG_IP_ROUTE_MULTIPATH */
+
 static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
 			    const struct flowi4 *fl4,
@@ -1656,7 +1698,10 @@ static int ip_mkroute_input(struct sk_buff *skb,
 	if (res->fi && res->fi->fib_nhs > 1) {
 		int h;
=20
-		h =3D fib_multipath_hash(saddr, daddr);
+		if (unlikely(ip_hdr(skb)->protocol =3D=3D IPPROTO_ICMP))
+			h =3D ip_multipath_icmp_hash(skb);
+		else
+			h =3D fib_multipath_hash(saddr, daddr);
 		fib_select_multipath(res, h);
 	}
 #endif
@@ -2042,7 +2087,8 @@ add:
  * Major route resolver routine.
  */
=20
-struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *f=
l4)
+struct rtable *__ip_route_output_key_hash(struct net *net, struct flow=
i4 *fl4,
+					  int mp_hash)
 {
 	struct net_device *dev_out =3D NULL;
 	__u8 tos =3D RT_FL_TOS(fl4);
@@ -2207,10 +2253,9 @@ struct rtable *__ip_route_output_key(struct net =
*net, struct flowi4 *fl4)
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0) {
-		int h;
-
-		h =3D fib_multipath_hash(fl4->saddr, fl4->daddr);
-		fib_select_multipath(&res, h);
+		if (mp_hash < 0)
+			mp_hash =3D fib_multipath_hash(fl4->saddr, fl4->daddr);
+		fib_select_multipath(&res, mp_hash);
 	}
 	else
 #endif
@@ -2233,7 +2278,7 @@ out:
 	rcu_read_unlock();
 	return rth;
 }
-EXPORT_SYMBOL_GPL(__ip_route_output_key);
+EXPORT_SYMBOL_GPL(__ip_route_output_key_hash);
=20
 static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *ds=
t, u32 cookie)
 {
--=20
1.7.10.4
