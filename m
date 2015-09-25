From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 3/5] netfilter: ipt_SYNPROXY: Pass snet into synproxy_send_tcp
Date: Fri, 25 Sep 2015 15:07:29 -0500
Message-ID: <1443211651-22154-3-git-send-email-ebiederm@xmission.com>
References: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87si62gteh.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip6t_SYNPROXY already does this and this is needed so that we have a
struct net that can be passed down into ip_route_me_harder, so
that ip_route_me_harder can stop guessing it's context.

Along the way pass snet into synproxy_send_client_synack as this
is the only caller of synprox_send_tcp that is not passed snet
already.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/netfilter/ipt_SYNPROXY.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index d7021f28c3f0..0060d9abd514 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -39,7 +39,8 @@ synproxy_build_ip(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 }
 
 static void
-synproxy_send_tcp(const struct sk_buff *skb, struct sk_buff *nskb,
+synproxy_send_tcp(const struct synproxy_net *snet,
+		  const struct sk_buff *skb, struct sk_buff *nskb,
 		  struct nf_conntrack *nfct, enum ip_conntrack_info ctinfo,
 		  struct iphdr *niph, struct tcphdr *nth,
 		  unsigned int tcp_hdr_size)
@@ -68,7 +69,8 @@ free_nskb:
 }
 
 static void
-synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
+synproxy_send_client_synack(const struct synproxy_net *snet,
+			    const struct sk_buff *skb, const struct tcphdr *th,
 			    const struct synproxy_options *opts)
 {
 	struct sk_buff *nskb;
@@ -104,7 +106,7 @@ synproxy_send_client_synack(const struct sk_buff *skb, const struct tcphdr *th,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
 			  niph, nth, tcp_hdr_size);
 }
 
@@ -148,7 +150,7 @@ synproxy_send_server_syn(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
+	synproxy_send_tcp(snet, skb, nskb, &snet->tmpl->ct_general, IP_CT_NEW,
 			  niph, nth, tcp_hdr_size);
 }
 
@@ -188,7 +190,7 @@ synproxy_send_server_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
+	synproxy_send_tcp(snet, skb, nskb, NULL, 0, niph, nth, tcp_hdr_size);
 }
 
 static void
@@ -226,7 +228,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 
 	synproxy_build_options(nth, opts);
 
-	synproxy_send_tcp(skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
+	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
 	                  niph, nth, tcp_hdr_size);
 }
 
@@ -287,7 +289,7 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 					  XT_SYNPROXY_OPT_SACK_PERM |
 					  XT_SYNPROXY_OPT_ECN);
 
-		synproxy_send_client_synack(skb, th, &opts);
+		synproxy_send_client_synack(snet, skb, th, &opts);
 		return NF_DROP;
 
 	} else if (th->ack && !(th->fin || th->rst || th->syn)) {
-- 
2.2.1

