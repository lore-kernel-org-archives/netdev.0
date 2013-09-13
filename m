From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc layer
Date: Fri, 13 Sep 2013 11:03:07 +0800
Message-ID: <5232806B.6050601@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61527 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752300Ab3IMDED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 23:04:03 -0400
In-Reply-To: <52327F00.4040802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Do the whole verification and route updating in ndisc
lay and then just call into icmpv6_notify() to notify
the upper protocols.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 include/net/ip6_route.h |  3 ---
 net/ipv6/ndisc.c        |  6 ++----
 net/ipv6/route.c        | 29 ++---------------------------
 3 files changed, 4 insertions(+), 34 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f525e70..5db259e 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -133,9 +133,6 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 			       __be32 mtu);
 extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
-extern void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
-				   u32 mark);
-extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
 struct netlink_callback;
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f8a55ff..6bd1b41 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1368,11 +1368,9 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	if (!ndisc_parse_options(msg->opt, ndoptlen, &ndopts))
 		return;
 
-	if (!ndopts.nd_opts_rh) {
-		ip6_redirect_no_header(skb, dev_net(skb->dev),
-					skb->dev->ifindex, 0);
+	ip6_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0);
+	if (!ndopts.nd_opts_rh)
 		return;
-	}
 
 	hdr = (u8 *)ndopts.nd_opts_rh;
 	hdr += 8;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c979dd9..151bd6c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1227,27 +1227,7 @@ static struct dst_entry *ip6_route_redirect(struct net *net,
 				flags, __ip6_route_redirect);
 }
 
-void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
-{
-	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
-	struct dst_entry *dst;
-	struct flowi6 fl6;
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
-	fl6.flowi6_mark = mark;
-	fl6.flowi6_flags = 0;
-	fl6.daddr = iph->daddr;
-	fl6.saddr = iph->saddr;
-	fl6.flowlabel = ip6_flowinfo(iph);
-
-	dst = ip6_route_redirect(net, &fl6, &ipv6_hdr(skb)->saddr);
-	rt6_do_redirect(dst, NULL, skb);
-	dst_release(dst);
-}
-EXPORT_SYMBOL_GPL(ip6_redirect);
-
-void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif,
 			    u32 mark)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -1266,12 +1246,7 @@ void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
 	rt6_do_redirect(dst, NULL, skb);
 	dst_release(dst);
 }
-
-void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
-{
-	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
-}
-EXPORT_SYMBOL_GPL(ip6_sk_redirect);
+EXPORT_SYMBOL_GPL(ip6_redirect);
 
 static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 {
-- 
1.8.3.1
