From: pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org
Subject: [PATCH v2 net-next 2/3] ipv4: L3 and L4 hash-based multipath routing
Date: Fri, 28 Aug 2015 22:00:49 +0200
Message-ID: <1440792050-2109-3-git-send-email-pch@ordbogen.com>
References: <1440792050-2109-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
	Scott Feldman <sfeldma-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Peter=20N=C3=B8rlund?= <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1440792050-2109-1-git-send-email-pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>

This patch adds L3 and L4 hash-based multipath routing, selectable on a
per-route basis with the reintroduced RTA_MP_ALGO attribute. The defaul=
t is
now RT_MP_ALG_L3_HASH.

Signed-off-by: Peter N=C3=B8rlund <pch-chEQUL3jiZBWk0Htik3J/w@public.gmane.org>
---
 include/net/ip_fib.h           | 22 ++++++++++++++++-
 include/uapi/linux/rtnetlink.h | 14 ++++++++++-
 net/ipv4/fib_frontend.c        |  4 +++
 net/ipv4/fib_semantics.c       | 43 +++++++++++++++++++++++++++-----
 net/ipv4/route.c               | 56 ++++++++++++++++++++++++++++++++++=
++++++--
 5 files changed, 129 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 18a3c7f..21e74b5 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -37,6 +37,7 @@ struct fib_config {
 	u32			fc_flags;
 	u32			fc_priority;
 	__be32			fc_prefsrc;
+	int			fc_mp_alg;
 	struct nlattr		*fc_mx;
 	struct rtnexthop	*fc_mp;
 	int			fc_mx_len;
@@ -119,6 +120,7 @@ struct fib_info {
 	int			fib_nhs;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	int			fib_weight;
+	int			fib_mp_alg;
 #endif
 	struct rcu_head		rcu;
 	struct fib_nh		fib_nh[0];
@@ -312,7 +314,25 @@ int ip_fib_check_default(__be32 gw, struct net_dev=
ice *dev);
 int fib_sync_down_dev(struct net_device *dev, unsigned long event);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
-void fib_select_multipath(struct fib_result *res);
+
+struct multipath_flow4 {
+	__be32 saddr;
+	__be32 daddr;
+	union {
+		__be32 ports;
+		struct {
+			__be16 sport;
+			__be16 dport;
+		};
+	};
+};
+
+typedef void (*multipath_flow4_func_t)(struct multipath_flow4 *flow,
+				       void *ctx);
+
+void fib_select_multipath(struct fib_result *res,
+			  multipath_flow4_func_t flow_func,
+			  void *ctx);
=20
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetl=
ink.h
index 0d3d3cc..2563a96 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -271,6 +271,18 @@ enum rt_scope_t {
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
=20
+/* Multipath algorithms */
+
+enum rt_mp_alg_t {
+	RT_MP_ALG_L3_HASH,	/* Was IP_MP_ALG_NONE */
+	RT_MP_ALG_PER_PACKET,	/* Was IP_MP_ALG_RR */
+	RT_MP_ALG_DRR,		/* not used */
+	RT_MP_ALG_RANDOM,	/* not used */
+	RT_MP_ALG_WRANDOM,	/* not used */
+	RT_MP_ALG_L4_HASH,
+	__RT_MP_ALG_MAX
+};
+
 /* Reserved table identifiers */
=20
 enum rt_class_t {
@@ -301,7 +313,7 @@ enum rtattr_type_t {
 	RTA_FLOW,
 	RTA_CACHEINFO,
 	RTA_SESSION, /* no longer used */
-	RTA_MP_ALGO, /* no longer used */
+	RTA_MP_ALGO,
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 7fa2771..5ba4442 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -622,6 +622,7 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1=
] =3D {
 	[RTA_PREFSRC]		=3D { .type =3D NLA_U32 },
 	[RTA_METRICS]		=3D { .type =3D NLA_NESTED },
 	[RTA_MULTIPATH]		=3D { .len =3D sizeof(struct rtnexthop) },
+	[RTA_MP_ALGO]		=3D { .type =3D NLA_U32 },
 	[RTA_FLOW]		=3D { .type =3D NLA_U32 },
 	[RTA_ENCAP_TYPE]	=3D { .type =3D NLA_U16 },
 	[RTA_ENCAP]		=3D { .type =3D NLA_NESTED },
@@ -684,6 +685,9 @@ static int rtm_to_fib_config(struct net *net, struc=
t sk_buff *skb,
 			cfg->fc_mp =3D nla_data(attr);
 			cfg->fc_mp_len =3D nla_len(attr);
 			break;
+		case RTA_MP_ALGO:
+			cfg->fc_mp_alg =3D nla_get_u32(attr);
+			break;
 		case RTA_FLOW:
 			cfg->fc_flow =3D nla_get_u32(attr);
 			break;
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index becb63f..3a80b1a 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -259,6 +259,11 @@ static inline int nh_comp(const struct fib_info *f=
i, const struct fib_info *ofi)
 {
 	const struct fib_nh *onh =3D ofi->fib_nh;
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+	if (fi->fib_mp_alg !=3D ofi->fib_mp_alg)
+		return -1;
+#endif
+
 	for_nexthops(fi) {
 		if (nh->nh_oif !=3D onh->nh_oif ||
 		    nh->nh_gw  !=3D onh->nh_gw ||
@@ -1028,6 +1033,7 @@ struct fib_info *fib_create_info(struct fib_confi=
g *cfg)
=20
 	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
+		fi->fib_mp_alg =3D cfg->fc_mp_alg;
 		err =3D fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
 		if (err !=3D 0)
 			goto failure;
@@ -1245,6 +1251,10 @@ int fib_dump_info(struct sk_buff *skb, u32 porti=
d, u32 seq, int event,
 		struct rtnexthop *rtnh;
 		struct nlattr *mp;
=20
+		if (fi->fib_mp_alg &&
+		    nla_put_u32(skb, RTA_MP_ALGO, fi->fib_mp_alg))
+			goto nla_put_failure;
+
 		mp =3D nla_nest_start(skb, RTA_MULTIPATH);
 		if (!mp)
 			goto nla_put_failure;
@@ -1520,16 +1530,37 @@ int fib_sync_up(struct net_device *dev, unsigne=
d int nh_flags)
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
=20
-/*
- * The algorithm is suboptimal, but it provides really
- * fair weighted route distribution.
- */
-void fib_select_multipath(struct fib_result *res)
+/* Compute multipath hash based on 3- or 5-tuple */
+static int fib_multipath_hash(const struct fib_result *res,
+			      multipath_flow4_func_t flow_func, void *ctx)
+{
+	struct multipath_flow4 flow;
+
+	flow_func(&flow, ctx);
+
+	if (res->fi->fib_mp_alg =3D=3D RT_MP_ALG_L4_HASH)
+		return jhash_3words(flow.saddr, flow.daddr, flow.ports, 0) >> 1;
+	else
+		return jhash_2words(flow.saddr, flow.daddr, 0) >> 1;
+}
+
+static int fib_multipath_perpacket(void)
+{
+	return bitrev32(this_cpu_inc_return(fib_multipath_rr_counter)) >> 1;
+}
+
+void fib_select_multipath(struct fib_result *res,
+			  multipath_flow4_func_t flow_func,
+			  void *ctx)
 {
 	struct fib_info *fi =3D res->fi;
 	int h;
=20
-	h =3D bitrev32(this_cpu_inc_return(fib_multipath_rr_counter)) >> 1;
+	if (res->fi->fib_mp_alg =3D=3D RT_MP_ALG_PER_PACKET) {
+		h =3D fib_multipath_perpacket();
+	} else {
+		h =3D fib_multipath_hash(res, flow_func, ctx);
+	}
=20
 	for_nexthops(fi) {
 		if (h > atomic_read(&nh->nh_upper_bound))
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f3087aa..f50f84f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1643,6 +1643,58 @@ out:
 	return err;
 }
=20
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+
+/* Fill multipath flow key data based on socket buffer */
+static void ip_multipath_flow_skb(struct multipath_flow4 *flow, void *=
ctx)
+{
+	const struct sk_buff *skb =3D (const struct sk_buff *)ctx;
+	const struct iphdr *iph;
+
+	iph =3D ip_hdr(skb);
+
+	flow->saddr =3D iph->saddr;
+	flow->daddr =3D iph->daddr;
+	flow->ports =3D 0;
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
+			flow->sport =3D ports[0];
+			flow->dport =3D ports[1];
+		}
+	}
+}
+
+/* Fill multipath flow key data based on flowi4  */
+static void ip_multipath_flow_fl4(struct multipath_flow4 *flow, void *=
ctx)
+{
+	const struct flowi4 *fl4 =3D (const struct flowi4 *)ctx;
+
+	flow->saddr =3D fl4->saddr;
+	flow->daddr =3D fl4->daddr;
+
+	if (fl4->flowi4_proto =3D=3D IPPROTO_TCP ||
+	    fl4->flowi4_proto =3D=3D IPPROTO_UDP ||
+	    fl4->flowi4_proto =3D=3D IPPROTO_SCTP) {
+		flow->sport =3D fl4->fl4_sport;
+		flow->dport =3D fl4->fl4_dport;
+	} else {
+		flow->ports =3D 0;
+	}
+}
+
+#endif /* CONFIG_IP_ROUTE_MULTIPATH */
+
 static int ip_mkroute_input(struct sk_buff *skb,
 			    struct fib_result *res,
 			    const struct flowi4 *fl4,
@@ -1651,7 +1703,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
 {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi && res->fi->fib_nhs > 1)
-		fib_select_multipath(res);
+		fib_select_multipath(res, ip_multipath_flow_skb, skb);
 #endif
=20
 	/* create a routing cache entry */
@@ -2197,7 +2249,7 @@ struct rtable *__ip_route_output_key(struct net *=
net, struct flowi4 *fl4)
=20
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0)
-		fib_select_multipath(&res);
+		fib_select_multipath(&res, ip_multipath_flow_fl4, fl4);
 	else
 #endif
 	if (!res.prefixlen &&
--=20
2.1.4
