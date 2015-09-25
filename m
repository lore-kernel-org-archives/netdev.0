From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 5/5] ipv6: Pass struct net into ip6_route_me_harder
Date: Fri, 25 Sep 2015 15:07:31 -0500
Message-ID: <1443211651-22154-5-git-send-email-ebiederm@xmission.com>
References: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51960 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932976AbbIYUPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 16:15:30 -0400
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't make ip6_route_me_harder guess which network namespace
it is routing in, pass the network namespace in.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netfilter_ipv6.h            | 2 +-
 net/ipv6/netfilter.c                      | 5 ++---
 net/ipv6/netfilter/ip6table_mangle.c      | 2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c  | 2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c | 2 +-
 net/netfilter/ipvs/ip_vs_core.c           | 2 +-
 6 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 771574677e83..2ac8369fa96c 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -22,7 +22,7 @@ struct nf_ipv6_ops {
 };
 
 #ifdef CONFIG_NETFILTER
-int ip6_route_me_harder(struct sk_buff *skb);
+int ip6_route_me_harder(struct net *net, struct sk_buff *skb);
 __sum16 nf_ip6_checksum(struct sk_buff *skb, unsigned int hook,
 			unsigned int dataoff, u_int8_t protocol);
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 26911b93dc7a..d11c46833d61 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -18,9 +18,8 @@
 #include <net/ip6_checksum.h>
 #include <net/netfilter/nf_queue.h>
 
-int ip6_route_me_harder(struct sk_buff *skb)
+int ip6_route_me_harder(struct net *net, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	unsigned int hh_len;
 	struct dst_entry *dst;
@@ -103,7 +102,7 @@ static int nf_ip6_reroute(struct net *net, struct sk_buff *skb,
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr) ||
 		    skb->mark != rt_info->mark)
-			return ip6_route_me_harder(skb);
+			return ip6_route_me_harder(net, skb);
 	}
 	return 0;
 }
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 8745b592b2f6..abe278b07932 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -65,7 +65,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 	     skb->mark != mark ||
 	     ipv6_hdr(skb)->hop_limit != hop_limit ||
 	     flowlabel != *((u_int32_t *)ipv6_hdr(skb)))) {
-		err = ip6_route_me_harder(skb);
+		err = ip6_route_me_harder(state->net, skb);
 		if (err < 0)
 			ret = NF_DROP_ERR(err);
 	}
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 18e835ffbef3..238e70c3f7b7 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -437,7 +437,7 @@ nf_nat_ipv6_local_fn(void *priv, struct sk_buff *skb,
 
 		if (!nf_inet_addr_cmp(&ct->tuplehash[dir].tuple.dst.u3,
 				      &ct->tuplehash[!dir].tuple.src.u3)) {
-			err = ip6_route_me_harder(skb);
+			err = ip6_route_me_harder(state->net, skb);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index d42bbc1d7555..9df75bd7c94a 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -52,7 +52,7 @@ static unsigned int nf_route_table_hook(void *priv,
 	     skb->mark != mark ||
 	     ipv6_hdr(skb)->hop_limit != hop_limit ||
 	     flowlabel != *((u_int32_t *)ipv6_hdr(skb))))
-		return ip6_route_me_harder(skb) == 0 ? ret : NF_DROP;
+		return ip6_route_me_harder(state->net, skb) == 0 ? ret : NF_DROP;
 
 	return ret;
 }
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 800b085242a8..37dd77a3d0fb 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -715,7 +715,7 @@ static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
 		struct dst_entry *dst = skb_dst(skb);
 
 		if (dst->dev && !(dst->dev->flags & IFF_LOOPBACK) &&
-		    ip6_route_me_harder(skb) != 0)
+		    ip6_route_me_harder(ipvs->net, skb) != 0)
 			return 1;
 	} else
 #endif
-- 
2.2.1
