From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 2/4] net: use skb_flow_dissect() in
 __skb_get_rxhash()
Date: Mon, 28 Nov 2011 16:23:23 +0100
Message-ID: <1322493803.2292.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
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

No functional changes.

This uses the code we factorized in skb_flow_dissect()

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/core/dev.c |  125 +++++------------------------------------------
 1 file changed, 14 insertions(+), 111 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8afb244..962e3de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -133,11 +133,9 @@
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
-#include <linux/if_tunnel.h>
-#include <linux/if_pppox.h>
-#include <linux/ppp_defs.h>
 #include <linux/net_tstamp.h>
 #include <linux/jump_label.h>
+#include <net/flow_keys.h>
 
 #include "net-sysfs.h"
 
@@ -2598,123 +2596,28 @@ static inline void ____napi_schedule(struct softnet_data *sd,
  */
 void __skb_get_rxhash(struct sk_buff *skb)
 {
-	int nhoff, hash = 0, poff;
-	const struct ipv6hdr *ip6;
-	const struct iphdr *ip;
-	const struct vlan_hdr *vlan;
-	u8 ip_proto;
-	u32 addr1, addr2;
-	u16 proto;
-	union {
-		u32 v32;
-		u16 v16[2];
-	} ports;
-
-	nhoff = skb_network_offset(skb);
-	proto = skb->protocol;
-
-again:
-	switch (proto) {
-	case __constant_htons(ETH_P_IP):
-ip:
-		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
-			goto done;
-
-		ip = (const struct iphdr *) (skb->data + nhoff);
-		if (ip_is_fragment(ip))
-			ip_proto = 0;
-		else
-			ip_proto = ip->protocol;
-		addr1 = (__force u32) ip->saddr;
-		addr2 = (__force u32) ip->daddr;
-		nhoff += ip->ihl * 4;
-		break;
-	case __constant_htons(ETH_P_IPV6):
-ipv6:
-		if (!pskb_may_pull(skb, sizeof(*ip6) + nhoff))
-			goto done;
-
-		ip6 = (const struct ipv6hdr *) (skb->data + nhoff);
-		ip_proto = ip6->nexthdr;
-		addr1 = (__force u32) ip6->saddr.s6_addr32[3];
-		addr2 = (__force u32) ip6->daddr.s6_addr32[3];
-		nhoff += 40;
-		break;
-	case __constant_htons(ETH_P_8021Q):
-		if (!pskb_may_pull(skb, sizeof(*vlan) + nhoff))
-			goto done;
-		vlan = (const struct vlan_hdr *) (skb->data + nhoff);
-		proto = vlan->h_vlan_encapsulated_proto;
-		nhoff += sizeof(*vlan);
-		goto again;
-	case __constant_htons(ETH_P_PPP_SES):
-		if (!pskb_may_pull(skb, PPPOE_SES_HLEN + nhoff))
-			goto done;
-		proto = *((__be16 *) (skb->data + nhoff +
-				      sizeof(struct pppoe_hdr)));
-		nhoff += PPPOE_SES_HLEN;
-		switch (proto) {
-		case __constant_htons(PPP_IP):
-			goto ip;
-		case __constant_htons(PPP_IPV6):
-			goto ipv6;
-		default:
-			goto done;
-		}
-	default:
-		goto done;
-	}
-
-	switch (ip_proto) {
-	case IPPROTO_GRE:
-		if (pskb_may_pull(skb, nhoff + 16)) {
-			u8 *h = skb->data + nhoff;
-			__be16 flags = *(__be16 *)h;
+	struct flow_keys keys;
+	u32 hash;
 
-			/*
-			 * Only look inside GRE if version zero and no
-			 * routing
-			 */
-			if (!(flags & (GRE_VERSION|GRE_ROUTING))) {
-				proto = *(__be16 *)(h + 2);
-				nhoff += 4;
-				if (flags & GRE_CSUM)
-					nhoff += 4;
-				if (flags & GRE_KEY)
-					nhoff += 4;
-				if (flags & GRE_SEQ)
-					nhoff += 4;
-				goto again;
-			}
-		}
-		break;
-	case IPPROTO_IPIP:
-		goto again;
-	default:
-		break;
-	}
+	if (!skb_flow_dissect(skb, &keys))
+		return;
 
-	ports.v32 = 0;
-	poff = proto_ports_offset(ip_proto);
-	if (poff >= 0) {
-		nhoff += poff;
-		if (pskb_may_pull(skb, nhoff + 4)) {
-			ports.v32 = * (__force u32 *) (skb->data + nhoff);
-			if (ports.v16[1] < ports.v16[0])
-				swap(ports.v16[0], ports.v16[1]);
-			skb->l4_rxhash = 1;
-		}
+	if (keys.ports) {
+		if ((__force u16)keys.port16[1] < (__force u16)keys.port16[0])
+			swap(keys.port16[0], keys.port16[1]);
+		skb->l4_rxhash = 1;
 	}
 
 	/* get a consistent hash (same value on both flow directions) */
-	if (addr2 < addr1)
-		swap(addr1, addr2);
+	if ((__force u32)keys.dst < (__force u32)keys.src)
+		swap(keys.dst, keys.src);
 
-	hash = jhash_3words(addr1, addr2, ports.v32, hashrnd);
+	hash = jhash_3words((__force u32)keys.dst,
+			    (__force u32)keys.src,
+			    (__force u32)keys.ports, hashrnd);
 	if (!hash)
 		hash = 1;
 
-done:
 	skb->rxhash = hash;
 }
 EXPORT_SYMBOL(__skb_get_rxhash);
