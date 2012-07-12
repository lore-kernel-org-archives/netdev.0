From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/16] ipv6: Add ip6_redirect() and ip6_sk_redirect()
 helper functions.
Date: Thu, 12 Jul 2012 01:12:02 -0700 (PDT)
Message-ID: <20120712.011202.1528476555909099292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932904Ab2GLIMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:12:03 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id DDA7C5824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:12:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    2 ++
 net/ipv6/route.c        |   27 +++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5cedbd7..6939405 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -139,6 +139,8 @@ extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
 			    int oif, u32 mark);
 extern void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk,
 			       __be32 mtu);
+extern void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark);
+extern void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk);
 
 struct netlink_callback;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 545b152..f52cf83 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1114,6 +1114,33 @@ void ip6_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, __be32 mtu)
 }
 EXPORT_SYMBOL_GPL(ip6_sk_update_pmtu);
 
+void ip6_redirect(struct sk_buff *skb, struct net *net, int oif, u32 mark)
+{
+	const struct ipv6hdr *iph = (struct ipv6hdr *) skb->data;
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_oif = oif;
+	fl6.flowi6_mark = mark;
+	fl6.flowi6_flags = 0;
+	fl6.daddr = iph->daddr;
+	fl6.saddr = iph->saddr;
+	fl6.flowlabel = (*(__be32 *) iph) & IPV6_FLOWINFO_MASK;
+
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (!dst->error)
+		rt6_do_redirect(dst, skb);
+	dst_release(dst);
+}
+EXPORT_SYMBOL_GPL(ip6_redirect);
+
+void ip6_sk_redirect(struct sk_buff *skb, struct sock *sk)
+{
+	ip6_redirect(skb, sock_net(sk), sk->sk_bound_dev_if, sk->sk_mark);
+}
+EXPORT_SYMBOL_GPL(ip6_sk_redirect);
+
 static unsigned int ip6_default_advmss(const struct dst_entry *dst)
 {
 	struct net_device *dev = dst->dev;
-- 
1.7.10.4
