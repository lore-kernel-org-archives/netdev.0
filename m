From: David Miller <davem@davemloft.net>
Subject: [PATCH 06/16] ipv4: Add ipv4_redirect() and ipv4_sk_redirect()
 helper functions.
Date: Thu, 12 Jul 2012 01:11:16 -0700 (PDT)
Message-ID: <20120712.011116.1924700314892943604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758746Ab2GLILR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:11:17 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 284785824C8
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h |    3 +++
 net/ipv4/route.c    |   28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/net/route.h b/include/net/route.h
index b140278..6ab93ee 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -180,6 +180,9 @@ static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 s
 extern void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
 			     int oif, u32 mark, u8 protocol, int flow_flags);
 extern void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu);
+extern void ipv4_redirect(struct sk_buff *skb, struct net *net,
+			  int oif, u32 mark, u8 protocol, int flow_flags);
+extern void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk);
 extern void ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned int		inet_addr_type(struct net *net, __be32 addr);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f3d2565..aabece6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1590,6 +1590,34 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
 }
 EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
 
+void ipv4_redirect(struct sk_buff *skb, struct net *net,
+		   int oif, u32 mark, u8 protocol, int flow_flags)
+{
+	const struct iphdr *iph = (const struct iphdr *)skb->data;
+	struct flowi4 fl4;
+	struct rtable *rt;
+
+	flowi4_init_output(&fl4, oif, mark, RT_TOS(iph->tos), RT_SCOPE_UNIVERSE,
+			   protocol, flow_flags, iph->daddr, iph->saddr, 0, 0);
+	rt = __ip_route_output_key(net, &fl4);
+	if (!IS_ERR(rt)) {
+		ip_do_redirect(&rt->dst, skb);
+		ip_rt_put(rt);
+	}
+}
+EXPORT_SYMBOL_GPL(ipv4_redirect);
+
+void ipv4_sk_redirect(struct sk_buff *skb, struct sock *sk)
+{
+	const struct inet_sock *inet = inet_sk(sk);
+
+	return ipv4_redirect(skb, sock_net(sk), sk->sk_bound_dev_if,
+			     sk->sk_mark,
+			     inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
+			     inet_sk_flowi_flags(sk));
+}
+EXPORT_SYMBOL_GPL(ipv4_sk_redirect);
+
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
 	struct rtable *rt = (struct rtable *) dst;
-- 
1.7.10.4
