From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/4] net: introduce skb_flow_dissect()
Date: Mon, 28 Nov 2011 16:22:18 +0100
Message-ID: <1322493738.2292.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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

We use at least two flow dissectors in network stack, with known
limitations and code duplication.

Introduce skb_flow_dissect() to factorize this, highly inspired from
existing dissector from __skb_get_rxhash()

Note : We extensively use skb_header_pointer(), this permits us to not
touch skb at all.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/flow_keys.h   |   15 ++++
 net/core/Makefile         |    2 
 net/core/flow_dissector.c |  134 ++++++++++++++++++++++++++++++++++++
 3 files changed, 150 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
new file mode 100644
index 0000000..7a61e21
--- /dev/null
+++ b/include/net/flow_keys.h
@@ -0,0 +1,15 @@
+#ifndef _NET_FLOW_KEYS_H
+#define _NET_FLOW_KEYS_H
+
+struct flow_keys {
+	__be32 src;
+	__be32 dst;
+	union {
+		__be32 ports;
+		__be16 port16[2];
+	};
+	u8 ip_proto;
+};
+
+extern bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
+#endif
diff --git a/net/core/Makefile b/net/core/Makefile
index 3606d40..c4ecc86 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -3,7 +3,7 @@
 #
 
 obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
-	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o
+	 gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
new file mode 100644
index 0000000..d0e085b
--- /dev/null
+++ b/net/core/flow_dissector.c
@@ -0,0 +1,134 @@
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/if_vlan.h>
+#include <net/ip.h>
+#include <linux/if_tunnel.h>
+#include <linux/if_pppox.h>
+#include <linux/ppp_defs.h>
+#include <net/flow_keys.h>
+
+
+bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
+{
+	int poff, nhoff = skb_network_offset(skb);
+	u8 ip_proto;
+	u16 proto = skb->protocol;
+
+	memset(flow, 0, sizeof(*flow));
+
+again:
+	switch (proto) {
+	case __constant_htons(ETH_P_IP): {
+		const struct iphdr *iph;
+		struct iphdr _iph;
+ip:
+		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		if (!iph)
+			return false;
+
+		if (ip_is_fragment(iph))
+			ip_proto = 0;
+		else
+			ip_proto = iph->protocol;
+		flow->src = iph->saddr;
+		flow->dst = iph->daddr;
+		nhoff += iph->ihl * 4;
+		break;
+	}
+	case __constant_htons(ETH_P_IPV6): {
+		const struct ipv6hdr *iph;
+		struct ipv6hdr _iph;
+ipv6:
+		iph = skb_header_pointer(skb, nhoff, sizeof(_iph), &_iph);
+		if (!iph)
+			return false;
+
+		ip_proto = iph->nexthdr;
+		flow->src = iph->saddr.s6_addr32[3];
+		flow->dst = iph->daddr.s6_addr32[3];
+		nhoff += sizeof(struct ipv6hdr);
+		break;
+	}
+	case __constant_htons(ETH_P_8021Q): {
+		const struct vlan_hdr *vlan;
+		struct vlan_hdr _vlan;
+
+		vlan = skb_header_pointer(skb, nhoff, sizeof(_vlan), &_vlan);
+		if (!vlan)
+			return false;
+
+		proto = vlan->h_vlan_encapsulated_proto;
+		nhoff += sizeof(*vlan);
+		goto again;
+	}
+	case __constant_htons(ETH_P_PPP_SES): {
+		struct {
+			struct pppoe_hdr hdr;
+			__be16 proto;
+		} *hdr, _hdr;
+		hdr = skb_header_pointer(skb, nhoff, sizeof(_hdr), &_hdr);
+		if (!hdr)
+			return false;
+		proto = hdr->proto;
+		nhoff += PPPOE_SES_HLEN;
+		switch (proto) {
+		case __constant_htons(PPP_IP):
+			goto ip;
+		case __constant_htons(PPP_IPV6):
+			goto ipv6;
+		default:
+			return false;
+		}
+	}
+	default:
+		return false;
+	}
+
+	switch (ip_proto) {
+	case IPPROTO_GRE: {
+		struct gre_hdr {
+			__be16 flags;
+			__be16 proto;
+		} *hdr, _hdr;
+
+		hdr = skb_header_pointer(skb, nhoff, sizeof(_hdr), &_hdr);
+		if (!hdr)
+			return false;
+		/*
+		 * Only look inside GRE if version zero and no
+		 * routing
+		 */
+		if (!(hdr->flags & (GRE_VERSION|GRE_ROUTING))) {
+			proto = hdr->proto;
+			nhoff += 4;
+			if (hdr->flags & GRE_CSUM)
+				nhoff += 4;
+			if (hdr->flags & GRE_KEY)
+				nhoff += 4;
+			if (hdr->flags & GRE_SEQ)
+				nhoff += 4;
+			goto again;
+		}
+		break;
+	}
+	case IPPROTO_IPIP:
+		goto again;
+	default:
+		break;
+	}
+
+	flow->ip_proto = ip_proto;
+	poff = proto_ports_offset(ip_proto);
+	if (poff >= 0) {
+		__be32 *ports, _ports;
+
+		nhoff += poff;
+		ports = skb_header_pointer(skb, nhoff, sizeof(_ports), &_ports);
+		if (ports)
+			flow->ports = *ports;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(skb_flow_dissect);
