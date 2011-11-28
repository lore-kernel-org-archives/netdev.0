From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 3/4] cls_flow: use skb_flow_dissect()
Date: Mon, 28 Nov 2011 16:24:18 +0100
Message-ID: <1322493858.2292.71.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, herbert-F6s6mLieUQo7FNHlEwC/lvQIK84fMopw@public.gmane.org,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>, Dan Siemon <dan-BZ4SNL/Vixll57MIdRCFDg@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Instead of using a custom flow dissector, use skb_flow_dissect() and
benefit from tunnelling support.

This lack of tunnelling support was mentioned by Dan Siemon.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/sched/cls_flow.c |  180 ++++++++++-------------------------------
 1 file changed, 48 insertions(+), 132 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 7b58230..a120ec5 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -26,6 +26,8 @@
 #include <net/pkt_cls.h>
 #include <net/ip.h>
 #include <net/route.h>
+#include <net/flow_keys.h>
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
 #endif
@@ -66,134 +68,37 @@ static inline u32 addr_fold(void *addr)
 	return (a & 0xFFFFFFFF) ^ (BITS_PER_LONG > 32 ? a >> 32 : 0);
 }
 
-static u32 flow_get_src(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	__be32 *data = NULL, hdata;
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		data = skb_header_pointer(skb,
-					  nhoff + offsetof(struct iphdr,
-							   saddr),
-					  4, &hdata);
-		break;
-	case htons(ETH_P_IPV6):
-		data = skb_header_pointer(skb,
-					 nhoff + offsetof(struct ipv6hdr,
-							  saddr.s6_addr32[3]),
-					 4, &hdata);
-		break;
-	}
-
-	if (data)
-		return ntohl(*data);
+	if (flow->src)
+		return ntohl(flow->src);
 	return addr_fold(skb->sk);
 }
 
-static u32 flow_get_dst(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	__be32 *data = NULL, hdata;
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		data = skb_header_pointer(skb,
-					  nhoff + offsetof(struct iphdr,
-							   daddr),
-					  4, &hdata);
-		break;
-	case htons(ETH_P_IPV6):
-		data = skb_header_pointer(skb,
-					 nhoff + offsetof(struct ipv6hdr,
-							  daddr.s6_addr32[3]),
-					 4, &hdata);
-		break;
-	}
-
-	if (data)
-		return ntohl(*data);
+	if (flow->dst)
+		return ntohl(flow->dst);
 	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
 
-static u32 flow_get_proto(const struct sk_buff *skb, int nhoff)
-{
-	__u8 *data = NULL, hdata;
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP):
-		data = skb_header_pointer(skb,
-					  nhoff + offsetof(struct iphdr,
-							   protocol),
-					  1, &hdata);
-		break;
-	case htons(ETH_P_IPV6):
-		data = skb_header_pointer(skb,
-					 nhoff + offsetof(struct ipv6hdr,
-							  nexthdr),
-					 1, &hdata);
-		break;
-	}
-	if (data)
-		return *data;
-	return 0;
-}
-
-/* helper function to get either src or dst port */
-static __be16 *flow_get_proto_common(const struct sk_buff *skb, int nhoff,
-				     __be16 *_port, int dst)
+static u32 flow_get_proto(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	__be16 *port = NULL;
-	int poff;
-
-	switch (skb->protocol) {
-	case htons(ETH_P_IP): {
-		struct iphdr *iph, _iph;
-
-		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
-		if (!iph)
-			break;
-		if (ip_is_fragment(iph))
-			break;
-		poff = proto_ports_offset(iph->protocol);
-		if (poff >= 0)
-			port = skb_header_pointer(skb,
-					nhoff + iph->ihl * 4 + poff + dst,
-					sizeof(*_port), _port);
-		break;
-	}
-	case htons(ETH_P_IPV6): {
-		struct ipv6hdr *iph, _iph;
-
-		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
-		if (!iph)
-			break;
-		poff = proto_ports_offset(iph->nexthdr);
-		if (poff >= 0)
-			port = skb_header_pointer(skb,
-					nhoff + sizeof(*iph) + poff + dst,
-					sizeof(*_port), _port);
-		break;
-	}
-	}
-
-	return port;
+	return flow->ip_proto;
 }
 
-static u32 flow_get_proto_src(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	__be16 _port, *port = flow_get_proto_common(skb, nhoff, &_port, 0);
-
-	if (port)
-		return ntohs(*port);
+	if (flow->ports)
+		return ntohs(flow->port16[0]);
 
 	return addr_fold(skb->sk);
 }
 
-static u32 flow_get_proto_dst(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	__be16 _port, *port = flow_get_proto_common(skb, nhoff, &_port, 2);
-
-	if (port)
-		return ntohs(*port);
+	if (flow->ports)
+		return ntohs(flow->port16[1]);
 
 	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
 }
@@ -239,7 +144,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 })
 #endif
 
-static u32 flow_get_nfct_src(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_nfct_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -248,10 +153,10 @@ static u32 flow_get_nfct_src(const struct sk_buff *skb, int nhoff)
 		return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
 	}
 fallback:
-	return flow_get_src(skb, nhoff);
+	return flow_get_src(skb, flow);
 }
 
-static u32 flow_get_nfct_dst(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_nfct_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
@@ -260,21 +165,21 @@ static u32 flow_get_nfct_dst(const struct sk_buff *skb, int nhoff)
 		return ntohl(CTTUPLE(skb, dst.u3.ip6[3]));
 	}
 fallback:
-	return flow_get_dst(skb, nhoff);
+	return flow_get_dst(skb, flow);
 }
 
-static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	return ntohs(CTTUPLE(skb, src.u.all));
 fallback:
-	return flow_get_proto_src(skb, nhoff);
+	return flow_get_proto_src(skb, flow);
 }
 
-static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, int nhoff)
+static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	return ntohs(CTTUPLE(skb, dst.u.all));
 fallback:
-	return flow_get_proto_dst(skb, nhoff);
+	return flow_get_proto_dst(skb, flow);
 }
 
 static u32 flow_get_rtclassid(const struct sk_buff *skb)
@@ -314,21 +219,19 @@ static u32 flow_get_rxhash(struct sk_buff *skb)
 	return skb_get_rxhash(skb);
 }
 
-static u32 flow_key_get(struct sk_buff *skb, int key)
+static u32 flow_key_get(struct sk_buff *skb, int key, struct flow_keys *flow)
 {
-	int nhoff = skb_network_offset(skb);
-
 	switch (key) {
 	case FLOW_KEY_SRC:
-		return flow_get_src(skb, nhoff);
+		return flow_get_src(skb, flow);
 	case FLOW_KEY_DST:
-		return flow_get_dst(skb, nhoff);
+		return flow_get_dst(skb, flow);
 	case FLOW_KEY_PROTO:
-		return flow_get_proto(skb, nhoff);
+		return flow_get_proto(skb, flow);
 	case FLOW_KEY_PROTO_SRC:
-		return flow_get_proto_src(skb, nhoff);
+		return flow_get_proto_src(skb, flow);
 	case FLOW_KEY_PROTO_DST:
-		return flow_get_proto_dst(skb, nhoff);
+		return flow_get_proto_dst(skb, flow);
 	case FLOW_KEY_IIF:
 		return flow_get_iif(skb);
 	case FLOW_KEY_PRIORITY:
@@ -338,13 +241,13 @@ static u32 flow_key_get(struct sk_buff *skb, int key)
 	case FLOW_KEY_NFCT:
 		return flow_get_nfct(skb);
 	case FLOW_KEY_NFCT_SRC:
-		return flow_get_nfct_src(skb, nhoff);
+		return flow_get_nfct_src(skb, flow);
 	case FLOW_KEY_NFCT_DST:
-		return flow_get_nfct_dst(skb, nhoff);
+		return flow_get_nfct_dst(skb, flow);
 	case FLOW_KEY_NFCT_PROTO_SRC:
-		return flow_get_nfct_proto_src(skb, nhoff);
+		return flow_get_nfct_proto_src(skb, flow);
 	case FLOW_KEY_NFCT_PROTO_DST:
-		return flow_get_nfct_proto_dst(skb, nhoff);
+		return flow_get_nfct_proto_dst(skb, flow);
 	case FLOW_KEY_RTCLASSID:
 		return flow_get_rtclassid(skb);
 	case FLOW_KEY_SKUID:
@@ -361,6 +264,16 @@ static u32 flow_key_get(struct sk_buff *skb, int key)
 	}
 }
 
+#define FLOW_KEYS_NEEDED ((1 << FLOW_KEY_SRC) | 		\
+			  (1 << FLOW_KEY_DST) |			\
+			  (1 << FLOW_KEY_PROTO) |		\
+			  (1 << FLOW_KEY_PROTO_SRC) |		\
+			  (1 << FLOW_KEY_PROTO_DST) | 		\
+			  (1 << FLOW_KEY_NFCT_SRC) |		\
+			  (1 << FLOW_KEY_NFCT_DST) |		\
+			  (1 << FLOW_KEY_NFCT_PROTO_SRC) |	\
+			  (1 << FLOW_KEY_NFCT_PROTO_DST))
+ 
 static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			 struct tcf_result *res)
 {
@@ -373,16 +286,19 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 	list_for_each_entry(f, &head->filters, list) {
 		u32 keys[f->nkeys];
+		struct flow_keys flow_keys;
 
 		if (!tcf_em_tree_match(skb, &f->ematches, NULL))
 			continue;
 
 		keymask = f->keymask;
+		if (keymask & FLOW_KEYS_NEEDED)
+			skb_flow_dissect(skb, &flow_keys);
 
 		for (n = 0; n < f->nkeys; n++) {
 			key = ffs(keymask) - 1;
 			keymask &= ~(1 << key);
-			keys[n] = flow_key_get(skb, key);
+			keys[n] = flow_key_get(skb, key, &flow_keys);
 		}
 
 		if (f->mode == FLOW_MODE_HASH)
