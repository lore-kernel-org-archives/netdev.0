From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH nf-next] bridge: Pass net into br_validate_ipv4 and br_validate_ipv6
Date: Fri, 25 Sep 2015 16:52:51 -0500
Message-ID: <87si62f9os.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The network namespace is easiliy available in state->net so use it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

This patch plus the 5 ip_route_me_harder patches I sent out today are
the last of my pure netfilter patches in my queue for pushing down
struct net where it is needed.  Everything else seems to involve
elements of the routinting stack (such as fragmentation and
defragmentation) and anything netfilter related about them is secondary.

So after these patches are merged into nf-next I expect the wise thing
to do is wait for nf-next to merge into net-next and send the rest of
the patches through net-next.

 include/net/netfilter/br_netfilter.h |  4 ++--
 net/bridge/br_netfilter_hooks.c      | 19 +++++++++----------
 net/bridge/br_netfilter_ipv6.c       | 11 +++++------
 3 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
index c93c75fa41ad..e8d1448425a7 100644
--- a/include/net/netfilter/br_netfilter.h
+++ b/include/net/netfilter/br_netfilter.h
@@ -45,12 +45,12 @@ struct net_device *setup_pre_routing(struct sk_buff *skb);
 void br_netfilter_enable(void);
 
 #if IS_ENABLED(CONFIG_IPV6)
-int br_validate_ipv6(struct sk_buff *skb);
+int br_validate_ipv6(struct net *net, struct sk_buff *skb);
 unsigned int br_nf_pre_routing_ipv6(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state);
 #else
-static inline int br_validate_ipv6(struct sk_buff *skb)
+static inline int br_validate_ipv6(struct net *net, struct sk_buff *skb)
 {
 	return -1;
 }
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index e21e44c13e07..13f03671c88d 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -189,10 +189,9 @@ static inline void nf_bridge_pull_encap_header_rcsum(struct sk_buff *skb)
  * expected format
  */
 
-static int br_validate_ipv4(struct sk_buff *skb)
+static int br_validate_ipv4(struct net *net, struct sk_buff *skb)
 {
 	const struct iphdr *iph;
-	struct net_device *dev = skb->dev;
 	u32 len;
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
@@ -213,13 +212,13 @@ static int br_validate_ipv4(struct sk_buff *skb)
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
 
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -232,7 +231,7 @@ static int br_validate_ipv4(struct sk_buff *skb)
 	return 0;
 
 inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
 drop:
 	return -1;
 }
@@ -497,7 +496,7 @@ static unsigned int br_nf_pre_routing(void *priv,
 
 	nf_bridge_pull_encap_header_rcsum(skb);
 
-	if (br_validate_ipv4(skb))
+	if (br_validate_ipv4(state->net, skb))
 		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
@@ -609,13 +608,13 @@ static unsigned int br_nf_forward_ip(void *priv,
 	}
 
 	if (pf == NFPROTO_IPV4) {
-		if (br_validate_ipv4(skb))
+		if (br_validate_ipv4(state->net, skb))
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
 	}
 
 	if (pf == NFPROTO_IPV6) {
-		if (br_validate_ipv6(skb))
+		if (br_validate_ipv6(state->net, skb))
 			return NF_DROP;
 		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
 	}
@@ -747,7 +746,7 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 	if (skb->protocol == htons(ETH_P_IP)) {
 		struct brnf_frag_data *data;
 
-		if (br_validate_ipv4(skb))
+		if (br_validate_ipv4(net, skb))
 			goto drop;
 
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
@@ -772,7 +771,7 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 		struct brnf_frag_data *data;
 
-		if (br_validate_ipv6(skb))
+		if (br_validate_ipv6(net, skb))
 			goto drop;
 
 		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index c51cc3fd50d9..d61f56efc8dc 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -100,10 +100,9 @@ bad:
 	return -1;
 }
 
-int br_validate_ipv6(struct sk_buff *skb)
+int br_validate_ipv6(struct net *net, struct sk_buff *skb)
 {
 	const struct ipv6hdr *hdr;
-	struct net_device *dev = skb->dev;
 	struct inet6_dev *idev = __in6_dev_get(skb->dev);
 	u32 pkt_len;
 	u8 ip6h_len = sizeof(struct ipv6hdr);
@@ -123,12 +122,12 @@ int br_validate_ipv6(struct sk_buff *skb)
 
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + ip6h_len > skb->len) {
-			IP6_INC_STATS_BH(dev_net(dev), idev,
+			IP6_INC_STATS_BH(net, idev,
 					 IPSTATS_MIB_INTRUNCATEDPKTS);
 			goto drop;
 		}
 		if (pskb_trim_rcsum(skb, pkt_len + ip6h_len)) {
-			IP6_INC_STATS_BH(dev_net(dev), idev,
+			IP6_INC_STATS_BH(net, idev,
 					 IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
@@ -143,7 +142,7 @@ int br_validate_ipv6(struct sk_buff *skb)
 	return 0;
 
 inhdr_error:
-	IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	return -1;
 }
@@ -224,7 +223,7 @@ unsigned int br_nf_pre_routing_ipv6(void *priv,
 {
 	struct nf_bridge_info *nf_bridge;
 
-	if (br_validate_ipv6(skb))
+	if (br_validate_ipv6(state->net, skb))
 		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
-- 
2.2.1

