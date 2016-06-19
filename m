From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/5] ip6: move ipip6_err_gen_icmpv6_unreach()
Date: Sat, 18 Jun 2016 21:52:03 -0700
Message-ID: <1466311926-27167-3-git-send-email-edumazet@google.com>
References: <1466311926-27167-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33427 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbcFSEwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 00:52:21 -0400
Received: by mail-pa0-f53.google.com with SMTP id b13so40404391pat.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 21:52:21 -0700 (PDT)
In-Reply-To: <1466311926-27167-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We want to use this helper from GRE as well, so this is
the time to move it in net/ipv6/icmp.c

Also add a @nhs parameter, since SIT and GRE have different
values for the header(s) to skip.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/icmpv6.h |  1 +
 net/ipv6/icmp.c        | 39 +++++++++++++++++++++++++++++++++++++++
 net/ipv6/sit.c         | 38 +-------------------------------------
 3 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 432611a297fb..9796481edbdb 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -18,6 +18,7 @@ typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 			     const struct in6_addr *force_saddr);
 extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
 extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs);
 
 #else
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 6c57e6e90301..07bc63c23712 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -558,6 +558,45 @@ void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
 	kfree_skb(skb);
 }
 
+/* Generate icmpv6 with type/code ICMPV6_DEST_UNREACH/ICMPV6_ADDR_UNREACH
+ * if sufficient data bytes are available
+ * @nhs is the size of the tunnel header(s) :
+ *  Either an IPv4 header for SIT encap
+ *         an IPv4 header + GRE header for GRE encap
+ */
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs)
+{
+	struct rt6_info *rt;
+	struct sk_buff *skb2;
+
+	if (!pskb_may_pull(skb, nhs + sizeof(struct ipv6hdr) + 8))
+		return 1;
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+
+	if (!skb2)
+		return 1;
+
+	skb_dst_drop(skb2);
+	skb_pull(skb2, nhs);
+	skb_reset_network_header(skb2);
+
+	rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
+
+	if (rt && rt->dst.dev)
+		skb2->dev = rt->dst.dev;
+
+	icmpv6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);
+
+	if (rt)
+		ip6_rt_put(rt);
+
+	kfree_skb(skb2);
+
+	return 0;
+}
+EXPORT_SYMBOL(ip6_err_gen_icmpv6_unreach);
+
 static void icmpv6_echo_reply(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d9f2bd6ef72d..78e84d6793ee 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -479,42 +479,6 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 	dev_put(dev);
 }
 
-/* Generate icmpv6 with type/code ICMPV6_DEST_UNREACH/ICMPV6_ADDR_UNREACH
- * if sufficient data bytes are available
- */
-static int ipip6_err_gen_icmpv6_unreach(struct sk_buff *skb)
-{
-	int ihl = ((const struct iphdr *)skb->data)->ihl*4;
-	struct rt6_info *rt;
-	struct sk_buff *skb2;
-
-	if (!pskb_may_pull(skb, ihl + sizeof(struct ipv6hdr) + 8))
-		return 1;
-
-	skb2 = skb_clone(skb, GFP_ATOMIC);
-
-	if (!skb2)
-		return 1;
-
-	skb_dst_drop(skb2);
-	skb_pull(skb2, ihl);
-	skb_reset_network_header(skb2);
-
-	rt = rt6_lookup(dev_net(skb->dev), &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
-
-	if (rt && rt->dst.dev)
-		skb2->dev = rt->dst.dev;
-
-	icmpv6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);
-
-	if (rt)
-		ip6_rt_put(rt);
-
-	kfree_skb(skb2);
-
-	return 0;
-}
-
 static int ipip6_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
@@ -575,7 +539,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		goto out;
 
 	err = 0;
-	if (!ipip6_err_gen_icmpv6_unreach(skb))
+	if (!ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4))
 		goto out;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-- 
2.8.0.rc3.226.g39d4020
