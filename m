From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/4] geneve: move geneve device lookup before iptunnel_pull_header
Date: Thu, 18 Feb 2016 11:22:50 +0100
Message-ID: <814fa7460d505dfdbe84587c9ff157fa1dd7ee20.1455790645.git.jbenc@redhat.com>
References: <cover.1455790645.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1426137AbcBRKXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 05:23:46 -0500
In-Reply-To: <cover.1455790645.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is in preparation for iptunnel_pull_header calling skb_scrub_packet.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/geneve.c | 76 ++++++++++++++++++++++++++++++----------------------
 1 file changed, 44 insertions(+), 32 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index f09de1e30955..4ceccf871b3f 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -158,55 +158,60 @@ static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
 	return (struct genevehdr *)(udp_hdr(skb) + 1);
 }
 
-/* geneve receive/decap routine */
-static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
+static struct geneve_dev *geneve_lookup_skb(struct geneve_sock *gs,
+					    struct sk_buff *skb)
 {
-	struct genevehdr *gnvh = geneve_hdr(skb);
-	struct metadata_dst *tun_dst = NULL;
-	struct geneve_dev *geneve = NULL;
-	struct pcpu_sw_netstats *stats;
-	struct iphdr *iph = NULL;
+	u8 *vni;
 	__be32 addr;
 	static u8 zero_vni[3];
-	u8 *vni;
-	int err = 0;
 #if IS_ENABLED(CONFIG_IPV6)
-	struct ipv6hdr *ip6h = NULL;
-	struct in6_addr addr6;
 	static struct in6_addr zero_addr6;
 #endif
 
 	if (geneve_get_sk_family(gs) == AF_INET) {
+		struct iphdr *iph;
+
 		iph = ip_hdr(skb); /* outer IP header... */
 
 		if (gs->collect_md) {
 			vni = zero_vni;
 			addr = 0;
 		} else {
-			vni = gnvh->vni;
-
+			vni = geneve_hdr(skb)->vni;
 			addr = iph->saddr;
 		}
 
-		geneve = geneve_lookup(gs, addr, vni);
+		return geneve_lookup(gs, addr, vni);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else if (geneve_get_sk_family(gs) == AF_INET6) {
+		struct ipv6hdr *ip6h;
+		struct in6_addr addr6;
+
 		ip6h = ipv6_hdr(skb); /* outer IPv6 header... */
 
 		if (gs->collect_md) {
 			vni = zero_vni;
 			addr6 = zero_addr6;
 		} else {
-			vni = gnvh->vni;
-
+			vni = geneve_hdr(skb)->vni;
 			addr6 = ip6h->saddr;
 		}
 
-		geneve = geneve6_lookup(gs, addr6, vni);
+		return geneve6_lookup(gs, addr6, vni);
 #endif
 	}
-	if (!geneve)
-		goto drop;
+	return NULL;
+}
+
+/* geneve receive/decap routine */
+static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
+		      struct sk_buff *skb)
+{
+	struct genevehdr *gnvh = geneve_hdr(skb);
+	struct metadata_dst *tun_dst = NULL;
+	struct pcpu_sw_netstats *stats;
+	int err = 0;
+	void *oiph;
 
 	if (ip_tunnel_collect_metadata() || gs->collect_md) {
 		__be16 flags;
@@ -243,25 +248,27 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
 		goto drop;
 
+	oiph = skb_network_header(skb);
 	skb_reset_network_header(skb);
 
-	if (iph)
-		err = IP_ECN_decapsulate(iph, skb);
+	if (geneve_get_sk_family(gs) == AF_INET)
+		err = IP_ECN_decapsulate(oiph, skb);
 #if IS_ENABLED(CONFIG_IPV6)
-	if (ip6h)
-		err = IP6_ECN_decapsulate(ip6h, skb);
+	else
+		err = IP6_ECN_decapsulate(oiph, skb);
 #endif
 
 	if (unlikely(err)) {
 		if (log_ecn_error) {
-			if (iph)
+			if (geneve_get_sk_family(gs) == AF_INET)
 				net_info_ratelimited("non-ECT from %pI4 "
 						     "with TOS=%#x\n",
-						     &iph->saddr, iph->tos);
+						     &((struct iphdr *)oiph)->saddr,
+						     ((struct iphdr *)oiph)->tos);
 #if IS_ENABLED(CONFIG_IPV6)
-			if (ip6h)
+			else
 				net_info_ratelimited("non-ECT from %pI6\n",
-						     &ip6h->saddr);
+						     &((struct ipv6hdr *)oiph)->saddr);
 #endif
 		}
 		if (err > 1) {
@@ -323,6 +330,7 @@ static void geneve_uninit(struct net_device *dev)
 static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct genevehdr *geneveh;
+	struct geneve_dev *geneve;
 	struct geneve_sock *gs;
 	int opts_len;
 
@@ -338,16 +346,20 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
 		goto error;
 
+	gs = rcu_dereference_sk_user_data(sk);
+	if (!gs)
+		goto drop;
+
+	geneve = geneve_lookup_skb(gs, skb);
+	if (!geneve)
+		goto drop;
+
 	opts_len = geneveh->opt_len * 4;
 	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
 				 htons(ETH_P_TEB)))
 		goto drop;
 
-	gs = rcu_dereference_sk_user_data(sk);
-	if (!gs)
-		goto drop;
-
-	geneve_rx(gs, skb);
+	geneve_rx(geneve, gs, skb);
 	return 0;
 
 drop:
-- 
1.8.3.1
