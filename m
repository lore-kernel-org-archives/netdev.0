From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 5/5] ipv6: Remove DST_METRICS_FORCE_OVERWRITE and _rt6i_peer
Date: Tue, 28 Apr 2015 13:03:07 -0700
Message-ID: <1430251387-2942539-6-git-send-email-kafai@fb.com>
References: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>,
	Yang Yingliang <yangyingliang@huawei.com>,
	shengyong <shengyong1@huawei.com>,
	Kernel Team <Kernel-team@fb.com>,
	=?UTF-8?q?Michal=20Kube=C4=8Dek?= <mkubecek@suse.cz>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54379 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031038AbbD1UD1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 16:03:27 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3SK28AE011812
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u2bqr0ppr-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:03:27 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a1722e30ede111e4a4fd0002c9521c9e-9ba22c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 13:03:26 -0700
In-Reply-To: <1430251387-2942539-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

_rt6i_peer is no longer needed after the last patch,
'ipv6: Stop rt6_info from using inet_peer's metrics'.

DST_METRICS_FORCE_OVERWRITE is added by
commit e5fd387ad5b3 ("ipv6: do not overwrite inetpeer metrics premature=
ly").
Since inetpeer is no longer used for metrics, this bit is also not need=
ed.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h       |  6 ------
 include/net/ip6_fib.h   | 31 -------------------------------
 net/ipv6/route.c        | 36 +-----------------------------------
 net/ipv6/xfrm6_policy.c | 14 --------------
 4 files changed, 1 insertion(+), 86 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 0fb99a2..22aa93f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -109,7 +109,6 @@ u32 *dst_cow_metrics_generic(struct dst_entry *dst,=
 unsigned long old);
 extern const u32 dst_default_metrics[];
=20
 #define DST_METRICS_READ_ONLY		0x1UL
-#define DST_METRICS_FORCE_OVERWRITE	0x2UL
 #define DST_METRICS_FLAGS		0x3UL
 #define __DST_METRICS_PTR(Y)	\
 	((u32 *)((Y) & ~DST_METRICS_FLAGS))
@@ -120,11 +119,6 @@ static inline bool dst_metrics_read_only(const str=
uct dst_entry *dst)
 	return dst->_metrics & DST_METRICS_READ_ONLY;
 }
=20
-static inline void dst_metrics_set_force_overwrite(struct dst_entry *d=
st)
-{
-	dst->_metrics |=3D DST_METRICS_FORCE_OVERWRITE;
-}
-
 void __dst_destroy_metrics_generic(struct dst_entry *dst, unsigned lon=
g old);
=20
 static inline void dst_destroy_metrics_generic(struct dst_entry *dst)
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 7383a8c..e000180 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -121,7 +121,6 @@ struct rt6_info {
 	struct rt6key			rt6i_prefsrc;
=20
 	struct inet6_dev		*rt6i_idev;
-	unsigned long			_rt6i_peer;
=20
 	u32				rt6i_metric;
 	u32				rt6i_pmtu;
@@ -130,36 +129,6 @@ struct rt6_info {
 	u8				rt6i_protocol;
 };
=20
-static inline struct inet_peer *rt6_peer_ptr(struct rt6_info *rt)
-{
-	return inetpeer_ptr(rt->_rt6i_peer);
-}
-
-static inline bool rt6_has_peer(struct rt6_info *rt)
-{
-	return inetpeer_ptr_is_peer(rt->_rt6i_peer);
-}
-
-static inline void __rt6_set_peer(struct rt6_info *rt, struct inet_pee=
r *peer)
-{
-	__inetpeer_ptr_set_peer(&rt->_rt6i_peer, peer);
-}
-
-static inline bool rt6_set_peer(struct rt6_info *rt, struct inet_peer =
*peer)
-{
-	return inetpeer_ptr_set_peer(&rt->_rt6i_peer, peer);
-}
-
-static inline void rt6_init_peer(struct rt6_info *rt, struct inet_peer=
_base *base)
-{
-	inetpeer_init_ptr(&rt->_rt6i_peer, base);
-}
-
-static inline void rt6_transfer_peer(struct rt6_info *rt, struct rt6_i=
nfo *ort)
-{
-	inetpeer_transfer_peer(&rt->_rt6i_peer, &ort->_rt6i_peer);
-}
-
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 {
 	return ((struct rt6_info *)dst)->rt6i_idev;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d6eb5d..3522711 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -105,36 +105,6 @@ static struct rt6_info *rt6_get_route_info(struct =
net *net,
 					   const struct in6_addr *gwaddr, int ifindex);
 #endif
=20
-static void rt6_bind_peer(struct rt6_info *rt, int create)
-{
-	struct inet_peer_base *base;
-	struct inet_peer *peer;
-
-	base =3D inetpeer_base_ptr(rt->_rt6i_peer);
-	if (!base)
-		return;
-
-	peer =3D inet_getpeer_v6(base, &rt->rt6i_dst.addr, create);
-	if (peer) {
-		if (!rt6_set_peer(rt, peer))
-			inet_putpeer(peer);
-	}
-}
-
-static struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int creat=
e)
-{
-	if (rt6_has_peer(rt))
-		return rt6_peer_ptr(rt);
-
-	rt6_bind_peer(rt, create);
-	return (rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL);
-}
-
-static struct inet_peer *rt6_get_peer_create(struct rt6_info *rt)
-{
-	return __rt6_get_peer(rt, 1);
-}
-
 static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
 {
 	struct rt6_info *rt =3D (struct rt6_info *)dst;
@@ -291,7 +261,6 @@ static inline struct rt6_info *ip6_dst_alloc(struct=
 net *net,
 		struct dst_entry *dst =3D &rt->dst;
=20
 		memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
-		rt6_init_peer(rt, table ? &table->tb6_peers : net->ipv6.peers);
 		INIT_LIST_HEAD(&rt->rt6i_siblings);
 	}
 	return rt;
@@ -1052,7 +1021,6 @@ struct dst_entry *ip6_blackhole_route(struct net =
*net, struct dst_entry *dst_ori
 		new =3D &rt->dst;
=20
 		memset(new + 1, 0, sizeof(*rt) - sizeof(*new));
-		rt6_init_peer(rt, net->ipv6.peers);
=20
 		new->__use =3D 1;
 		new->input =3D dst_discard;
@@ -1597,10 +1565,8 @@ int ip6_route_add(struct fib6_config *cfg)
=20
 	ipv6_addr_prefix(&rt->rt6i_dst.addr, &cfg->fc_dst, cfg->fc_dst_len);
 	rt->rt6i_dst.plen =3D cfg->fc_dst_len;
-	if (rt->rt6i_dst.plen =3D=3D 128) {
+	if (rt->rt6i_dst.plen =3D=3D 128)
 		rt->dst.flags |=3D DST_HOST;
-		dst_metrics_set_force_overwrite(&rt->dst);
-	}
=20
 #ifdef CONFIG_IPV6_SUBTREES
 	ipv6_addr_prefix(&rt->rt6i_src.addr, &cfg->fc_src, cfg->fc_src_len);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f337a90..6ae256b 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -71,13 +71,6 @@ static int xfrm6_get_tos(const struct flowi *fl)
 	return 0;
 }
=20
-static void xfrm6_init_dst(struct net *net, struct xfrm_dst *xdst)
-{
-	struct rt6_info *rt =3D (struct rt6_info *)xdst;
-
-	rt6_init_peer(rt, net->ipv6.peers);
-}
-
 static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *ds=
t,
 			   int nfheader_len)
 {
@@ -106,8 +99,6 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, str=
uct net_device *dev,
 		return -ENODEV;
 	}
=20
-	rt6_transfer_peer(&xdst->u.rt6, rt);
-
 	/* Sheit... I remember I did this right. Apparently,
 	 * it was magically lost, so this code needs audit */
 	xdst->u.rt6.rt6i_flags =3D rt->rt6i_flags & (RTF_ANYCAST |
@@ -255,10 +246,6 @@ static void xfrm6_dst_destroy(struct dst_entry *ds=
t)
 	if (likely(xdst->u.rt6.rt6i_idev))
 		in6_dev_put(xdst->u.rt6.rt6i_idev);
 	dst_destroy_metrics_generic(dst);
-	if (rt6_has_peer(&xdst->u.rt6)) {
-		struct inet_peer *peer =3D rt6_peer_ptr(&xdst->u.rt6);
-		inet_putpeer(peer);
-	}
 	xfrm_dst_destroy(xdst);
 }
=20
@@ -308,7 +295,6 @@ static struct xfrm_policy_afinfo xfrm6_policy_afinf=
o =3D {
 	.get_saddr =3D		xfrm6_get_saddr,
 	.decode_session =3D	_decode_session6,
 	.get_tos =3D		xfrm6_get_tos,
-	.init_dst =3D		xfrm6_init_dst,
 	.init_path =3D		xfrm6_init_path,
 	.fill_dst =3D		xfrm6_fill_dst,
 	.blackhole_route =3D	ip6_blackhole_route,
--=20
1.8.1
