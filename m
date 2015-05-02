From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next v3 6/9] ipv6: Set FLOWI_FLAG_KNOWN_NH at flowi6_flags
Date: Fri, 1 May 2015 17:26:55 -0700
Message-ID: <1430526418-3132761-7-git-send-email-kafai@fb.com>
References: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59010 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750866AbbEBA2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 20:28:21 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t420QfAU014305
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 17:28:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u4djf8uf0-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 17:28:21 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 21bfba26f06211e4bc040002c9521c9e-cb2dd1e0 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 17:28:19 -0700
In-Reply-To: <1430526418-3132761-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The neighbor look-up used to depend on the rt6i_gateway (if
there is a gateway) or the rt6i_dst (if it is a RTF_CACHE clone)
as the nexthop address.  Note that rt6i_dst is set to fl6->daddr
for the RTF_CACHE clone where fl6->daddr is the one used to do
the route look-up.

Now, we only create RTF_CACHE clone after encountering exception.
When doing the neighbor look-up with a route that is neither a gateway
nor a RTF_CACHE clone, the daddr in skb will be used as the nexthop.

In some cases, the daddr in skb is not the one used to do
the route look-up.  One example is in ip_vs_dr_xmit_v6() where the
real nexthop server address is different from the one in the skb.

This patch is going to follow the IPv4 approach and ask the
ip6_pol_route() callers to set the FLOWI_FLAG_KNOWN_NH properly.

In the next patch, ip6_pol_route() will honor the FLOWI_FLAG_KNOWN_NH
and create a RTF_CACHE clone.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 net/ipv6/raw.c                  |  3 +++
 net/netfilter/ipvs/ip_vs_xmit.c | 13 +++++++++----
 net/netfilter/xt_TEE.c          |  1 +
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8072bd4..484a5c1 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -865,6 +865,9 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		fl6.flowi6_oif = np->ucast_oif;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
 
+	if (inet->hdrincl)
+		fl6.flowi6_flags |= FLOWI_FLAG_KNOWN_NH;
+
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 5eff9f6..bf66a86 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -364,13 +364,16 @@ err_unreach:
 #ifdef CONFIG_IP_VS_IPV6
 static struct dst_entry *
 __ip_vs_route_output_v6(struct net *net, struct in6_addr *daddr,
-			struct in6_addr *ret_saddr, int do_xfrm)
+			struct in6_addr *ret_saddr, int do_xfrm, int rt_mode)
 {
 	struct dst_entry *dst;
 	struct flowi6 fl6 = {
 		.daddr = *daddr,
 	};
 
+	if (rt_mode & IP_VS_RT_MODE_KNOWN_NH)
+		fl6.flowi6_flags = FLOWI_FLAG_KNOWN_NH;
+
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error)
 		goto out_err;
@@ -427,7 +430,7 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 			}
 			dst = __ip_vs_route_output_v6(net, &dest->addr.in6,
 						      &dest_dst->dst_saddr.in6,
-						      do_xfrm);
+						      do_xfrm, rt_mode);
 			if (!dst) {
 				__ip_vs_dst_set(dest, NULL, NULL, 0);
 				spin_unlock_bh(&dest->dst_lock);
@@ -446,7 +449,8 @@ __ip_vs_get_out_rt_v6(int skb_af, struct sk_buff *skb, struct ip_vs_dest *dest,
 			*ret_saddr = dest_dst->dst_saddr.in6;
 	} else {
 		noref = 0;
-		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm);
+		dst = __ip_vs_route_output_v6(net, daddr, ret_saddr, do_xfrm,
+					      rt_mode);
 		if (!dst)
 			goto err_unreach;
 		rt = (struct rt6_info *) dst;
@@ -1164,7 +1168,8 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	local = __ip_vs_get_out_rt_v6(cp->af, skb, cp->dest, &cp->daddr.in6,
 				      NULL, ipvsh, 0,
 				      IP_VS_RT_MODE_LOCAL |
-				      IP_VS_RT_MODE_NON_LOCAL);
+				      IP_VS_RT_MODE_NON_LOCAL |
+				      IP_VS_RT_MODE_KNOWN_NH);
 	if (local < 0)
 		goto tx_error;
 	if (local) {
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 292934d..a747eb4 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -152,6 +152,7 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	fl6.daddr = info->gw.in6;
 	fl6.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
 			   (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
+	fl6.flowi6_flags = FLOWI_FLAG_KNOWN_NH;
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (dst->error) {
 		dst_release(dst);
-- 
1.8.1
