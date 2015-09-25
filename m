From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 4/5] ipv4: Pass struct net into ip_route_me_harder
Date: Fri, 25 Sep 2015 15:07:30 -0500
Message-ID: <1443211651-22154-4-git-send-email-ebiederm@xmission.com>
References: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:40139 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933224AbbIYUP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 16:15:28 -0400
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't make ip_route_me_harder guess which network namespace
it is routing in, pass the network namespace in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter_ipv4.h            | 2 +-
 net/ipv4/netfilter.c                      | 5 ++---
 net/ipv4/netfilter/ipt_SYNPROXY.c         | 4 +++-
 net/ipv4/netfilter/iptable_mangle.c       | 2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c  | 2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c       | 2 +-
 net/ipv4/netfilter/nft_chain_route_ipv4.c | 2 +-
 net/netfilter/ipvs/ip_vs_core.c           | 2 +-
 8 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index 6e4591bb54d4..98c03b2462b5 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -6,7 +6,7 @@
 
 #include <uapi/linux/netfilter_ipv4.h>
 
-int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type);
+int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned addr_type);
 __sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
 		       unsigned int dataoff, u_int8_t protocol);
 #endif /*__LINUX_IP_NETFILTER_H*/
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 9e07e6f23398..c3776ff6749f 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -17,9 +17,8 @@
 #include <net/netfilter/nf_queue.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
-int ip_route_me_harder(struct sk_buff *skb, unsigned int addr_type)
+int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_type)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
@@ -116,7 +115,7 @@ static int nf_ip_reroute(struct net *net, struct sk_buff *skb,
 		      skb->mark == rt_info->mark &&
 		      iph->daddr == rt_info->daddr &&
 		      iph->saddr == rt_info->saddr))
-			return ip_route_me_harder(skb, RTN_UNSPEC);
+			return ip_route_me_harder(net, skb, RTN_UNSPEC);
 	}
 	return 0;
 }
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 0060d9abd514..6a6e762ab27f 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -45,6 +45,8 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 		  struct iphdr *niph, struct tcphdr *nth,
 		  unsigned int tcp_hdr_size)
 {
+	struct net *net = nf_ct_net(snet->tmpl);
+
 	nth->check = ~tcp_v4_check(tcp_hdr_size, niph->saddr, niph->daddr, 0);
 	nskb->ip_summed   = CHECKSUM_PARTIAL;
 	nskb->csum_start  = (unsigned char *)nth - nskb->head;
@@ -52,7 +54,7 @@ synproxy_send_tcp(const struct synproxy_net *snet,
 
 	skb_dst_set_noref(nskb, skb_dst(skb));
 	nskb->protocol = htons(ETH_P_IP);
-	if (ip_route_me_harder(nskb, RTN_UNSPEC))
+	if (ip_route_me_harder(net, nskb, RTN_UNSPEC))
 		goto free_nskb;
 
 	if (nfct) {
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 2d6fc911866f..ba5d392a13c4 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -67,7 +67,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 		    iph->daddr != daddr ||
 		    skb->mark != mark ||
 		    iph->tos != tos) {
-			err = ip_route_me_harder(skb, RTN_UNSPEC);
+			err = ip_route_me_harder(state->net, skb, RTN_UNSPEC);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index bc3b9dcbf080..5075b7ecd26d 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -431,7 +431,7 @@ nf_nat_ipv4_local_fn(void *priv, struct sk_buff *skb,
 
 		if (ct->tuplehash[dir].tuple.dst.u3.ip !=
 		    ct->tuplehash[!dir].tuple.src.u3.ip) {
-			err = ip_route_me_harder(skb, RTN_UNSPEC);
+			err = ip_route_me_harder(state->net, skb, RTN_UNSPEC);
 			if (err < 0)
 				ret = NF_DROP_ERR(err);
 		}
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index fb337406b1d2..2f5e925d3264 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -129,7 +129,7 @@ void nf_send_reset(struct net *net, struct sk_buff *oldskb, int hook)
 				   ip4_dst_hoplimit(skb_dst(nskb)));
 	nf_reject_ip_tcphdr_put(nskb, oldskb, oth);
 
-	if (ip_route_me_harder(nskb, RTN_UNSPEC))
+	if (ip_route_me_harder(net, nskb, RTN_UNSPEC))
 		goto free_nskb;
 
 	/* "Never happens" */
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 9f486b302108..2375b0a8be46 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -53,7 +53,7 @@ static unsigned int nf_route_table_hook(void *priv,
 		    iph->daddr != daddr ||
 		    skb->mark != mark ||
 		    iph->tos != tos)
-			if (ip_route_me_harder(skb, RTN_UNSPEC))
+			if (ip_route_me_harder(state->net, skb, RTN_UNSPEC))
 				ret = NF_DROP;
 	}
 	return ret;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index fb6b6c87d841..800b085242a8 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -720,7 +720,7 @@ static int ip_vs_route_me_harder(struct netns_ipvs *ipvs, int af,
 	} else
 #endif
 		if (!(skb_rtable(skb)->rt_flags & RTCF_LOCAL) &&
-		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
+		    ip_route_me_harder(ipvs->net, skb, RTN_LOCAL) != 0)
 			return 1;
 
 	return 0;
-- 
2.2.1
