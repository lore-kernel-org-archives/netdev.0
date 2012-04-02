From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 39/51] netfilter: ipv4: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:29 -0400
Message-ID: <1333335521-1348-40-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab2DBDAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:22 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    5 +++--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |   12 ++++++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index de9da21..5c45e30 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -303,8 +303,9 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 static int ipv4_tuple_to_nlattr(struct sk_buff *skb,
 				const struct nf_conntrack_tuple *tuple)
 {
-	NLA_PUT_BE32(skb, CTA_IP_V4_SRC, tuple->src.u3.ip);
-	NLA_PUT_BE32(skb, CTA_IP_V4_DST, tuple->dst.u3.ip);
+	if (nla_put_be32(skb, CTA_IP_V4_SRC, tuple->src.u3.ip) ||
+	    nla_put_be32(skb, CTA_IP_V4_DST, tuple->dst.u3.ip))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 7cbe9cb..0847e37 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -228,10 +228,10 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 static int icmp_tuple_to_nlattr(struct sk_buff *skb,
 				const struct nf_conntrack_tuple *t)
 {
-	NLA_PUT_BE16(skb, CTA_PROTO_ICMP_ID, t->src.u.icmp.id);
-	NLA_PUT_U8(skb, CTA_PROTO_ICMP_TYPE, t->dst.u.icmp.type);
-	NLA_PUT_U8(skb, CTA_PROTO_ICMP_CODE, t->dst.u.icmp.code);
-
+	if (nla_put_be16(skb, CTA_PROTO_ICMP_ID, t->src.u.icmp.id) ||
+	    nla_put_u8(skb, CTA_PROTO_ICMP_TYPE, t->dst.u.icmp.type) ||
+	    nla_put_u8(skb, CTA_PROTO_ICMP_CODE, t->dst.u.icmp.code))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
@@ -293,8 +293,8 @@ icmp_timeout_obj_to_nlattr(struct sk_buff *skb, const void *data)
 {
 	const unsigned int *timeout = data;
 
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_ICMP_TIMEOUT, htonl(*timeout / HZ));
-
+	if (nla_put_be32(skb, CTA_TIMEOUT_ICMP_TIMEOUT, htonl(*timeout / HZ)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
