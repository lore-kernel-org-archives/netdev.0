From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 37/51] netfilter: ipv6: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:27 -0400
Message-ID: <1333335521-1348-38-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479Ab2DBDAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:14 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    9 +++++----
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   12 ++++++------
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4111050..fe925e4 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -278,10 +278,11 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 static int ipv6_tuple_to_nlattr(struct sk_buff *skb,
 				const struct nf_conntrack_tuple *tuple)
 {
-	NLA_PUT(skb, CTA_IP_V6_SRC, sizeof(u_int32_t) * 4,
-		&tuple->src.u3.ip6);
-	NLA_PUT(skb, CTA_IP_V6_DST, sizeof(u_int32_t) * 4,
-		&tuple->dst.u3.ip6);
+	if (nla_put(skb, CTA_IP_V6_SRC, sizeof(u_int32_t) * 4,
+		    &tuple->src.u3.ip6) ||
+	    nla_put(skb, CTA_IP_V6_DST, sizeof(u_int32_t) * 4,
+		    &tuple->dst.u3.ip6))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 92cc9f2..3e81904 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -234,10 +234,10 @@ icmpv6_error(struct net *net, struct nf_conn *tmpl,
 static int icmpv6_tuple_to_nlattr(struct sk_buff *skb,
 				  const struct nf_conntrack_tuple *t)
 {
-	NLA_PUT_BE16(skb, CTA_PROTO_ICMPV6_ID, t->src.u.icmp.id);
-	NLA_PUT_U8(skb, CTA_PROTO_ICMPV6_TYPE, t->dst.u.icmp.type);
-	NLA_PUT_U8(skb, CTA_PROTO_ICMPV6_CODE, t->dst.u.icmp.code);
-
+	if (nla_put_be16(skb, CTA_PROTO_ICMPV6_ID, t->src.u.icmp.id) ||
+	    nla_put_u8(skb, CTA_PROTO_ICMPV6_TYPE, t->dst.u.icmp.type) ||
+	    nla_put_u8(skb, CTA_PROTO_ICMPV6_CODE, t->dst.u.icmp.code))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -300,8 +300,8 @@ icmpv6_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_ICMPV6_TIMEOUT, htonl(*timeout / HZ));
-
+	if (nla_put_be32(skb, CTA_TIMEOUT_ICMPV6_TIMEOUT, htonl(*timeout / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
