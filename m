From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/3] netfilter: nat: propagate errors from xfrm_me_harder()
Date: Fri,  5 Apr 2013 18:41:12 +0200
Message-ID: <1365180072-6182-4-git-send-email-kaber@trash.net>
References: <1365180072-6182-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365180072-6182-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Propagate errors from ip_xfrm_me_harder() instead of returning EPERM in
all cases.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/iptable_nat.c  | 17 +++++++++++------
 net/ipv6/netfilter/ip6table_nat.c | 17 +++++++++++------
 net/netfilter/nf_nat_core.c       |  9 +++++----
 3 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index c2937c8..6383273 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -176,6 +176,7 @@ nf_nat_ipv4_out(unsigned int hooknum,
 #ifdef CONFIG_XFRM
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
+	int err;
 #endif
 	unsigned int ret;
 
@@ -195,9 +196,11 @@ nf_nat_ipv4_out(unsigned int hooknum,
 		     ct->tuplehash[!dir].tuple.dst.u3.ip) ||
 		    (ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMP &&
 		     ct->tuplehash[dir].tuple.src.u.all !=
-		     ct->tuplehash[!dir].tuple.dst.u.all))
-			if (nf_xfrm_me_harder(skb, AF_INET) < 0)
-				ret = NF_DROP;
+		     ct->tuplehash[!dir].tuple.dst.u.all)) {
+			err = nf_xfrm_me_harder(skb, AF_INET);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 	}
 #endif
 	return ret;
@@ -235,9 +238,11 @@ nf_nat_ipv4_local_fn(unsigned int hooknum,
 		else if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
 			 ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMP &&
 			 ct->tuplehash[dir].tuple.dst.u.all !=
-			 ct->tuplehash[!dir].tuple.src.u.all)
-			if (nf_xfrm_me_harder(skb, AF_INET) < 0)
-				ret = NF_DROP;
+			 ct->tuplehash[!dir].tuple.src.u.all) {
+			err = nf_xfrm_me_harder(skb, AF_INET);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 #endif
 	}
 	return ret;
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 97e2edd..6383f90 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -179,6 +179,7 @@ nf_nat_ipv6_out(unsigned int hooknum,
 #ifdef CONFIG_XFRM
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
+	int err;
 #endif
 	unsigned int ret;
 
@@ -197,9 +198,11 @@ nf_nat_ipv6_out(unsigned int hooknum,
 				      &ct->tuplehash[!dir].tuple.dst.u3) ||
 		    (ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMPV6 &&
 		     ct->tuplehash[dir].tuple.src.u.all !=
-		     ct->tuplehash[!dir].tuple.dst.u.all))
-			if (nf_xfrm_me_harder(skb, AF_INET6) < 0)
-				ret = NF_DROP;
+		     ct->tuplehash[!dir].tuple.dst.u.all)) {
+			err = nf_xfrm_me_harder(skb, AF_INET6);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 	}
 #endif
 	return ret;
@@ -236,9 +239,11 @@ nf_nat_ipv6_local_fn(unsigned int hooknum,
 		else if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
 			 ct->tuplehash[dir].tuple.dst.protonum != IPPROTO_ICMPV6 &&
 			 ct->tuplehash[dir].tuple.dst.u.all !=
-			 ct->tuplehash[!dir].tuple.src.u.all)
-			if (nf_xfrm_me_harder(skb, AF_INET6))
-				ret = NF_DROP;
+			 ct->tuplehash[!dir].tuple.src.u.all) {
+			err = nf_xfrm_me_harder(skb, AF_INET6);
+			if (err < 0)
+				ret = NF_DROP_ERR(err);
+		}
 #endif
 	}
 	return ret;
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 8d5769c..346f871 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -87,9 +87,10 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 	struct flowi fl;
 	unsigned int hh_len;
 	struct dst_entry *dst;
+	int err;
 
-	if (xfrm_decode_session(skb, &fl, family) < 0)
-		return -1;
+	err = xfrm_decode_session(skb, &fl, family);
+		return err;
 
 	dst = skb_dst(skb);
 	if (dst->xfrm)
@@ -98,7 +99,7 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 
 	dst = xfrm_lookup(dev_net(dst->dev), dst, &fl, skb->sk, 0);
 	if (IS_ERR(dst))
-		return -1;
+		return PTR_ERR(dst);
 
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
@@ -107,7 +108,7 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 	hh_len = skb_dst(skb)->dev->hard_header_len;
 	if (skb_headroom(skb) < hh_len &&
 	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
-		return -1;
+		return -ENOMEM;
 	return 0;
 }
 EXPORT_SYMBOL(nf_xfrm_me_harder);
-- 
1.8.1.4

