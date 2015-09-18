From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 13/14] netfilter: Pass net into nf_xfrm_me_harder
Date: Fri, 18 Sep 2015 11:05:59 -0500
Message-ID: <1442592360-2575-13-git-send-email-ebiederm@xmission.com>
References: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87pp1fpy1b.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of calling dev_net on a likley looking network device
pass state->net into nf_xfrm_me_harder.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/nf_nat_core.h      | 2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 4 ++--
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 4 ++--
 net/netfilter/nf_nat_core.c              | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index fbfd1ba4254e..186c54138f35 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -10,7 +10,7 @@
 unsigned int nf_nat_packet(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			   unsigned int hooknum, struct sk_buff *skb);
 
-int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family);
+int nf_xfrm_me_harder(struct net *net, struct sk_buff *skb, unsigned int family);
 
 static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 8593a9d88619..bc3b9dcbf080 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -396,7 +396,7 @@ nf_nat_ipv4_out(void *priv, struct sk_buff *skb,
 		    (ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMP &&
 		     ct->tuplehash[dir].tuple.src.u.all !=
 		     ct->tuplehash[!dir].tuple.dst.u.all)) {
-			err = nf_xfrm_me_harder(skb, AF_INET);
+			err = nf_xfrm_me_harder(state->net, skb, AF_INET);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
@@ -440,7 +440,7 @@ nf_nat_ipv4_local_fn(void *priv, struct sk_buff *skb,
 			 ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMP &&
 			 ct->tuplehash[dir].tuple.dst.u.all !=
 			 ct->tuplehash[!dir].tuple.src.u.all) {
-			err = nf_xfrm_me_harder(skb, AF_INET);
+			err = nf_xfrm_me_harder(state->net, skb, AF_INET);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 357f57ba47e4..18e835ffbef3 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -403,7 +403,7 @@ nf_nat_ipv6_out(void *priv, struct sk_buff *skb,
 		    (ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMPV6 &&
 		     ct->tuplehash[dir].tuple.src.u.all !=
 		     ct->tuplehash[!dir].tuple.dst.u.all)) {
-			err = nf_xfrm_me_harder(skb, AF_INET6);
+			err = nf_xfrm_me_harder(state->net, skb, AF_INET6);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
@@ -446,7 +446,7 @@ nf_nat_ipv6_local_fn(void *priv, struct sk_buff *skb,
 			 ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMPV6 &&
 			 ct->tuplehash[dir].tuple.dst.u.all !=
 			 ct->tuplehash[!dir].tuple.src.u.all) {
-			err = nf_xfrm_me_harder(skb, AF_INET6);
+			err = nf_xfrm_me_harder(state->net, skb, AF_INET6);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 5113dfd39df9..06a9f45771ab 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -83,7 +83,7 @@ out:
 	rcu_read_unlock();
 }
 
-int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
+int nf_xfrm_me_harder(struct net *net, struct sk_buff *skb, unsigned int family)
 {
 	struct flowi fl;
 	unsigned int hh_len;
@@ -99,7 +99,7 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 		dst = ((struct xfrm_dst *)dst)->route;
 	dst_hold(dst);
 
-	dst = xfrm_lookup(dev_net(dst->dev), dst, &fl, skb->sk, 0);
+	dst = xfrm_lookup(net, dst, &fl, skb->sk, 0);
 	if (IS_ERR(dst))
 		return PTR_ERR(dst);
 
-- 
2.2.1

