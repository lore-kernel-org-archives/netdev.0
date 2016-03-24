From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [RFT Patch net 1/2] ipv6: invalidate the socket cached route on pmtu events if possible
Date: Thu, 24 Mar 2016 12:25:35 -0700
Message-ID: <1458847536-7729-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: weiwan@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35532 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbcCXTZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 15:25:51 -0400
Received: by mail-pf0-f170.google.com with SMTP id n5so65184312pfn.2
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 12:25:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 9cb3a50c5f63, with this patch we invalidate the
socket cached route if possible. If the socket is owened by the
user, we can't update the cached route directly.

Reported-by: Wei Wang <weiwan@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/route.c | 74 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 65 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed44663..2c16cbc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1346,18 +1346,20 @@ static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
 		(rt->rt6i_flags & RTF_PCPU || rt->rt6i_node);
 }
 
-static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
-				 const struct ipv6hdr *iph, u32 mtu)
+static struct dst_entry *__ip6_rt_update_pmtu(struct dst_entry *dst,
+					      const struct sock *sk,
+					      const struct ipv6hdr *iph,
+					      u32 mtu, bool hold)
 {
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	if (rt6->rt6i_flags & RTF_LOCAL)
-		return;
+		return dst;
 
 	dst_confirm(dst);
 	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
 	if (mtu >= dst_mtu(dst))
-		return;
+		return dst;
 
 	if (!rt6_cache_allowed_for_pmtu(rt6)) {
 		rt6_do_update_pmtu(rt6, mtu);
@@ -1372,11 +1374,13 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 			daddr = &sk->sk_v6_daddr;
 			saddr = &inet6_sk(sk)->saddr;
 		} else {
-			return;
+			return dst;
 		}
 		nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
 		if (nrt6) {
 			rt6_do_update_pmtu(nrt6, mtu);
+			if (hold)
+				dst_hold(&nrt6->dst);
 
 			/* ip6_ins_rt(nrt6) will bump the
 			 * rt6->rt6i_node->fn_sernum
@@ -1384,14 +1388,17 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 			 * invalidate the sk->sk_dst_cache.
 			 */
 			ip6_ins_rt(nrt6);
+			return &nrt6->dst;
 		}
 	}
+
+	return dst;
 }
 
 static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 			       struct sk_buff *skb, u32 mtu)
 {
-	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu);
+	__ip6_rt_update_pmtu(dst, sk, skb ? ipv6_hdr(skb) : NULL, mtu, false);
 }
 
 void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
@@ -1410,15 +1417,64 @@ void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 
 	dst = ip6_route_output(net, NULL, &fl6);
 	if (!dst->error)
-		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu));
+		__ip6_rt_update_pmtu(dst, NULL, iph, ntohl(mtu), false);
 	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_update_pmtu);
 
 void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 {
-	ip6_update_pmtu(skb, sock_net(sk), mtu,
-			sk->sk_bound_dev_if, sk->sk_mark);
+	const struct ipv6hdr *iph = (struct ipv6hdr *)skb->data;
+	struct net *net = sock_net(sk);
+	struct dst_entry *ndst, *dst;
+	struct flowi6 fl6;
+	bool new = false;
+
+	memset(&fl6, 0, sizeof(fl6));
+
+	bh_lock_sock(sk);
+
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	fl6.flowi6_mark = sk->sk_mark ? : IP6_REPLY_MARK(net, skb->mark);
+	fl6.daddr = iph->daddr;
+	fl6.saddr = iph->saddr;
+	fl6.flowlabel = ip6_flowinfo(iph);
+
+	dst = sk_dst_get(sk);
+	if (sock_owned_by_user(sk) || !dst) {
+		ip6_update_pmtu(skb, net, mtu, fl6.flowi6_oif, fl6.flowi6_mark);
+		goto out;
+	}
+
+	if (!dst_check(dst, 0)) {
+		dst_release(dst);
+		dst = ip6_route_output(net, sk, &fl6);
+		if (dst->error)
+			goto out;
+
+		new = true;
+	}
+
+	ndst = __ip6_rt_update_pmtu(dst->path, sk, iph, ntohl(mtu), true);
+	if (!dst_check(ndst, 0)) {
+		if (ndst != dst)
+			dst_release(dst);
+
+		dst = ip6_route_output(net, sk, &fl6);
+		if (dst->error)
+			goto out;
+
+		new = true;
+	} else if (ndst != dst) {
+		new = true;
+	}
+
+	if (new)
+		ip6_dst_store(sk, dst, NULL, NULL);
+
+out:
+	bh_unlock_sock(sk);
+	dst_release(dst);
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
 
-- 
2.1.0
