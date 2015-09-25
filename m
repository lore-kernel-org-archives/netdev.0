From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 1/5] ipv4: Push struct net down into nf_send_reset
Date: Fri, 25 Sep 2015 15:07:27 -0500
Message-ID: <1443211651-22154-1-git-send-email-ebiederm@xmission.com>
References: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is needed so struct net can be pushed down into
ip_route_me_harder.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/netfilter/ipv4/nf_reject.h | 2 +-
 net/ipv4/netfilter/ipt_REJECT.c        | 2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c    | 2 +-
 net/ipv4/netfilter/nft_reject_ipv4.c   | 2 +-
 net/netfilter/nft_reject_inet.c        | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index 77862c3645f0..df7ecd806aba 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -6,7 +6,7 @@
 #include <net/icmp.h>
 
 void nf_send_unreach(struct sk_buff *skb_in, int code, int hook);
-void nf_send_reset(struct sk_buff *oldskb, int hook);
+void nf_send_reset(struct net *net, struct sk_buff *oldskb, int hook);
 
 const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
 					     struct tcphdr *_oth, int hook);
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 87907d4bd259..1d16c0f28df0 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -59,7 +59,7 @@ reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		nf_send_unreach(skb, ICMP_PKT_FILTERED, hook);
 		break;
 	case IPT_TCP_RESET:
-		nf_send_reset(skb, hook);
+		nf_send_reset(par->net, skb, hook);
 	case IPT_ICMP_ECHOREPLY:
 		/* Doesn't happen. */
 		break;
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 3262e41ff76f..fb337406b1d2 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -99,7 +99,7 @@ void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
 EXPORT_SYMBOL_GPL(nf_reject_ip_tcphdr_put);
 
 /* Send RST reply */
-void nf_send_reset(struct sk_buff *oldskb, int hook)
+void nf_send_reset(struct net *net, struct sk_buff *oldskb, int hook)
 {
 	struct sk_buff *nskb;
 	const struct iphdr *oiph;
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index c1582e03b628..c24f41c816b3 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -30,7 +30,7 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 		nf_send_unreach(pkt->skb, priv->icmp_code, pkt->hook);
 		break;
 	case NFT_REJECT_TCP_RST:
-		nf_send_reset(pkt->skb, pkt->hook);
+		nf_send_reset(pkt->net, pkt->skb, pkt->hook);
 		break;
 	default:
 		break;
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 0bc19f97e238..759ca5248a3d 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -31,7 +31,7 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 					pkt->hook);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset(pkt->skb, pkt->hook);
+			nf_send_reset(pkt->net, pkt->skb, pkt->hook);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nf_send_unreach(pkt->skb,
-- 
2.2.1

