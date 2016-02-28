From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: remove skb_sender_cpu_clear()
Date: Sat, 27 Feb 2016 20:19:54 -0800
Message-ID: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35192 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992685AbcB1EUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 23:20:01 -0500
Received: by mail-pa0-f45.google.com with SMTP id bj10so2857602pad.2
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 20:20:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 52bd2d62ce67 ("net: better skb->sender_cpu and skb->napi_id cohabitation")
skb_sender_cpu_clear() becomes empty and can be removed.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/skbuff.h          | 4 ----
 net/bridge/br_forward.c         | 1 -
 net/core/filter.c               | 2 --
 net/core/skbuff.c               | 1 -
 net/ipv4/ip_forward.c           | 1 -
 net/ipv6/ip6_output.c           | 1 -
 net/netfilter/ipvs/ip_vs_xmit.c | 6 ------
 net/netfilter/nf_dup_netdev.c   | 1 -
 net/sched/act_mirred.c          | 1 -
 9 files changed, 18 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eab4f8f..797cefb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1161,10 +1161,6 @@ static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
 	to->l4_hash = from->l4_hash;
 };
 
-static inline void skb_sender_cpu_clear(struct sk_buff *skb)
-{
-}
-
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index fcdb86d..f47759f 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -44,7 +44,6 @@ int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb
 
 	skb_push(skb, ETH_HLEN);
 	br_drop_fake_rtable(skb);
-	skb_sender_cpu_clear(skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    (skb->protocol == htons(ETH_P_8021Q) ||
diff --git a/net/core/filter.c b/net/core/filter.c
index a3aba15..5e2a3b5 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1597,7 +1597,6 @@ static u64 bpf_clone_redirect(u64 r1, u64 ifindex, u64 flags, u64 r4, u64 r5)
 	}
 
 	skb2->dev = dev;
-	skb_sender_cpu_clear(skb2);
 	return dev_queue_xmit(skb2);
 }
 
@@ -1650,7 +1649,6 @@ int skb_do_redirect(struct sk_buff *skb)
 	}
 
 	skb->dev = dev;
-	skb_sender_cpu_clear(skb);
 	return dev_queue_xmit(skb);
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 488566b..7af7ec6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4302,7 +4302,6 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet)
 	skb->skb_iif = 0;
 	skb->ignore_df = 0;
 	skb_dst_drop(skb);
-	skb_sender_cpu_clear(skb);
 	secpath_reset(skb);
 	nf_reset(skb);
 	nf_reset_trace(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index da0d7ce..af18f1e 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -71,7 +71,6 @@ static int ip_forward_finish(struct net *net, struct sock *sk, struct sk_buff *s
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	skb_sender_cpu_clear(skb);
 	return dst_output(net, sk, skb);
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a163102..9428345 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -332,7 +332,6 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 static inline int ip6_forward_finish(struct net *net, struct sock *sk,
 				     struct sk_buff *skb)
 {
-	skb_sender_cpu_clear(skb);
 	return dst_output(net, sk, skb);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index a3f5cd9..dc196a0 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -531,8 +531,6 @@ static inline int ip_vs_tunnel_xmit_prepare(struct sk_buff *skb,
 	if (ret == NF_ACCEPT) {
 		nf_reset(skb);
 		skb_forward_csum(skb);
-		if (!skb->sk)
-			skb_sender_cpu_clear(skb);
 	}
 	return ret;
 }
@@ -573,8 +571,6 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 
 	if (!local) {
 		skb_forward_csum(skb);
-		if (!skb->sk)
-			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
@@ -595,8 +591,6 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 	if (!local) {
 		ip_vs_drop_early_demux_sk(skb);
 		skb_forward_csum(skb);
-		if (!skb->sk)
-			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, cp->ipvs->net, NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
diff --git a/net/netfilter/nf_dup_netdev.c b/net/netfilter/nf_dup_netdev.c
index 8414ee1..7ec6972 100644
--- a/net/netfilter/nf_dup_netdev.c
+++ b/net/netfilter/nf_dup_netdev.c
@@ -31,7 +31,6 @@ void nf_dup_netdev_egress(const struct nft_pktinfo *pkt, int oif)
 		skb_push(skb, skb->mac_len);
 
 	skb->dev = dev;
-	skb_sender_cpu_clear(skb);
 	dev_queue_xmit(skb);
 }
 EXPORT_SYMBOL_GPL(nf_dup_netdev_egress);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 6b284d9..e8a760c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -182,7 +182,6 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
-	skb_sender_cpu_clear(skb2);
 	err = dev_queue_xmit(skb2);
 
 	if (err) {
-- 
2.1.0
