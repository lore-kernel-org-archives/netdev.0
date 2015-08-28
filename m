From: pch@ordbogen.com
Subject: [PATCH v2 net-next 3/3] ipv4: ICMP packet inspection for L3 multipath
Date: Fri, 28 Aug 2015 22:00:50 +0200
Message-ID: <1440792050-2109-4-git-send-email-pch@ordbogen.com>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, linux-api@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch@ordbogen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([91.240.88.21]:39989 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643AbbH1UG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 16:06:59 -0400
In-Reply-To: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=C3=B8rlund <pch@ordbogen.com>

When doing L3 based multipath, ICMP packets are inspected to let them r=
oute
over the same path as the flow they relate to, allowing anycast
environments to work with ECMP.

Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
---
 include/net/ip_fib.h     |  2 +-
 include/net/route.h      | 12 ++++++-
 net/ipv4/fib_semantics.c |  2 +-
 net/ipv4/icmp.c          | 34 +++++++++++++++++++-
 net/ipv4/route.c         | 82 ++++++++++++++++++++++++++++++++++++++--=
--------
 5 files changed, 112 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 21e74b5..3e5d4ed 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -328,7 +328,7 @@ struct multipath_flow4 {
 };
=20
 typedef void (*multipath_flow4_func_t)(struct multipath_flow4 *flow,
-				       void *ctx);
+				       enum rt_mp_alg_t algo, void *ctx);
=20
 void fib_select_multipath(struct fib_result *res,
 			  multipath_flow4_func_t flow_func,
diff --git a/include/net/route.h b/include/net/route.h
index 395d79b..ccb85fc 100644
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
+struct rtable *__ip_route_output_key_flow(struct net *, struct flowi4 =
*flp,
+					  multipath_flow4_func_t flow_func,
+					  void *ctx);
+
+static inline struct rtable *__ip_route_output_key(struct net *net,
+						   struct flowi4 *flp)
+{
+	return __ip_route_output_key_flow(net, flp, NULL, NULL);
+}
+
 struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
 				    struct sock *sk);
 struct dst_entry *ipv4_blackhole_route(struct net *net,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 3a80b1a..000c535 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1536,7 +1536,7 @@ static int fib_multipath_hash(const struct fib_re=
sult *res,
 {
 	struct multipath_flow4 flow;
=20
-	flow_func(&flow, ctx);
+	flow_func(&flow, res->fi->fib_mp_alg, ctx);
=20
 	if (res->fi->fib_mp_alg =3D=3D RT_MP_ALG_L4_HASH)
 		return jhash_3words(flow.saddr, flow.daddr, flow.ports, 0) >> 1;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f16488e..0e25fe4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -439,6 +439,38 @@ out_unlock:
 	icmp_xmit_unlock(sk);
 }
=20
+/* Source and destination is swapped. See ip_multipath_flow_skb */
+static void icmp_multipath_flow(struct multipath_flow4 *flow,
+				enum rt_mp_alg_t algo, void *ctx)
+{
+	const struct sk_buff *skb =3D (const struct sk_buff *)ctx;
+	const struct iphdr *iph =3D ip_hdr(skb);
+
+	flow->saddr =3D iph->daddr;
+	flow->daddr =3D iph->saddr;
+	flow->ports =3D 0;
+
+	if (algo =3D=3D RT_MP_ALG_L4_HASH)
+		return;
+
+	if (unlikely(!(iph->frag_off & htons(IP_DF))))
+		return;
+
+	if (iph->protocol =3D=3D IPPROTO_TCP ||
+	    iph->protocol =3D=3D IPPROTO_UDP ||
+	    iph->protocol =3D=3D IPPROTO_SCTP) {
+		__be16 _ports[2];
+		const __be16 *ports;
+
+		ports =3D skb_header_pointer(skb, iph->ihl * 4, sizeof(_ports),
+					   &_ports);
+		if (ports) {
+			flow->sport =3D ports[1];
+			flow->dport =3D ports[0];
+		}
+	}
+}
+
 static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
@@ -463,7 +495,7 @@ static struct rtable *icmp_route_lookup(struct net =
*net,
 	fl4->flowi4_oif =3D vrf_master_ifindex(skb_in->dev) ? : skb_in->dev->=
ifindex;
=20
 	security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
-	rt =3D __ip_route_output_key(net, fl4);
+	rt =3D __ip_route_output_key_flow(net, fl4, icmp_multipath_flow, skb_=
in);
 	if (IS_ERR(rt))
 		return rt;
=20
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f50f84f..edbeb56 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1646,37 +1646,82 @@ out:
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
 /* Fill multipath flow key data based on socket buffer */
-static void ip_multipath_flow_skb(struct multipath_flow4 *flow, void *=
ctx)
+static void ip_multipath_flow_skb(struct multipath_flow4 *flow,
+				  enum rt_mp_alg_t algo, void *ctx)
 {
 	const struct sk_buff *skb =3D (const struct sk_buff *)ctx;
-	const struct iphdr *iph;
+	struct icmphdr _icmph;
+	struct iphdr _inner_iph;
+	const struct iphdr *outer_iph;
+	const struct icmphdr *icmph;
+	const struct iphdr *inner_iph;
+	unsigned int offset;
=20
-	iph =3D ip_hdr(skb);
+	outer_iph =3D ip_hdr(skb);
=20
-	flow->saddr =3D iph->saddr;
-	flow->daddr =3D iph->daddr;
+	flow->saddr =3D outer_iph->saddr;
+	flow->daddr =3D outer_iph->daddr;
 	flow->ports =3D 0;
=20
-	if (unlikely(!(iph->frag_off & htons(IP_DF))))
-		return;
+	offset =3D outer_iph->ihl * 4;
=20
-	if (iph->protocol =3D=3D IPPROTO_TCP ||
-	    iph->protocol =3D=3D IPPROTO_UDP ||
-	    iph->protocol =3D=3D IPPROTO_SCTP) {
+	if (algo =3D=3D RT_MP_ALG_L4_HASH) {
 		__be16 _ports[2];
 		const __be16 *ports;
=20
-		ports =3D skb_header_pointer(skb, iph->ihl * 4, sizeof(_ports),
+		if (unlikely(!(outer_iph->frag_off & htons(IP_DF))))
+			return;
+
+		if (outer_iph->protocol !=3D IPPROTO_TCP &&
+		    outer_iph->protocol !=3D IPPROTO_UDP &&
+		    outer_iph->protocol !=3D IPPROTO_SCTP) {
+			return;
+		}
+
+		ports =3D skb_header_pointer(skb, offset, sizeof(_ports),
 					   &_ports);
 		if (ports) {
 			flow->sport =3D ports[0];
 			flow->dport =3D ports[1];
 		}
+
+		return;
+	}
+
+	if (outer_iph->protocol !=3D IPPROTO_ICMP)
+		return;
+
+	if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) !=3D 0))
+		return;
+
+	icmph =3D skb_header_pointer(skb, offset, sizeof(_icmph), &_icmph);
+	if (!icmph)
+		return;
+
+	if (icmph->type !=3D ICMP_DEST_UNREACH &&
+	    icmph->type !=3D ICMP_SOURCE_QUENCH &&
+	    icmph->type !=3D ICMP_REDIRECT &&
+	    icmph->type !=3D ICMP_TIME_EXCEEDED &&
+	    icmph->type !=3D ICMP_PARAMETERPROB) {
+		return;
 	}
+
+	offset +=3D sizeof(_icmph);
+	inner_iph =3D skb_header_pointer(skb, offset, sizeof(_inner_iph),
+				       &_inner_iph);
+	if (!inner_iph)
+		return;
+
+	/* Since the ICMP payload contains a packet sent from the current
+	 * recipient, we swap source and destination addresses
+	 */
+	flow->saddr =3D inner_iph->daddr;
+	flow->daddr =3D inner_iph->saddr;
 }
=20
 /* Fill multipath flow key data based on flowi4  */
-static void ip_multipath_flow_fl4(struct multipath_flow4 *flow, void *=
ctx)
+static void ip_multipath_flow_fl4(struct multipath_flow4 *flow,
+				  enum rt_mp_alg_t algo, void *ctx)
 {
 	const struct flowi4 *fl4 =3D (const struct flowi4 *)ctx;
=20
@@ -2086,7 +2131,9 @@ add:
  * Major route resolver routine.
  */
=20
-struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *f=
l4)
+struct rtable *__ip_route_output_key_flow(struct net *net, struct flow=
i4 *fl4,
+					  multipath_flow4_func_t flow_func,
+					  void *ctx)
 {
 	struct net_device *dev_out =3D NULL;
 	__u8 tos =3D RT_FL_TOS(fl4);
@@ -2248,9 +2295,12 @@ struct rtable *__ip_route_output_key(struct net =
*net, struct flowi4 *fl4)
 	}
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
-		fib_select_multipath(&res, ip_multipath_flow_fl4, fl4);
-	else
+	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0) {
+		if (flow_func)
+			fib_select_multipath(&res, flow_func, ctx);
+		else
+			fib_select_multipath(&res, ip_multipath_flow_fl4, fl4);
+	} else
 #endif
 	if (!res.prefixlen &&
 	    res.table->tb_num_default > 1 &&
--=20
2.1.4
