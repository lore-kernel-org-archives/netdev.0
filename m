From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/9] netfilter: move nf_send_resetX() code to nf_reject_ipvX modules
Date: Fri,  3 Oct 2014 19:20:17 +0200
Message-ID: <1412356824-6362-3-git-send-email-pablo@netfilter.org>
References: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1412356824-6362-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move nf_send_reset() and nf_send_reset6() to nf_reject_ipv4 and
nf_reject_ipv6 respectively. This code is shared by x_tables and
nf_tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_reject.h |  118 +----------------------
 net/ipv4/netfilter/Kconfig             |    6 ++
 net/ipv4/netfilter/Makefile            |    3 +
 net/ipv4/netfilter/nf_reject_ipv4.c    |  127 +++++++++++++++++++++++++
 net/ipv6/netfilter/Kconfig             |    6 ++
 net/ipv6/netfilter/Makefile            |    3 +
 net/ipv6/netfilter/nf_reject_ipv6.c    |  163 ++++++++++++++++++++++++++++++++
 7 files changed, 309 insertions(+), 117 deletions(-)
 create mode 100644 net/ipv4/netfilter/nf_reject_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_reject_ipv6.c

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index 8ce0638..e842719 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -1,10 +1,6 @@
 #ifndef _IPV4_NF_REJECT_H
 #define _IPV4_NF_REJECT_H
 
-#include <net/ip.h>
-#include <net/tcp.h>
-#include <net/route.h>
-#include <net/dst.h>
 #include <net/icmp.h>
 
 static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
@@ -12,118 +8,6 @@ static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
 	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
 }
 
-/* Send RST reply */
-static void nf_send_reset(struct sk_buff *oldskb, int hook)
-{
-	struct sk_buff *nskb;
-	const struct iphdr *oiph;
-	struct iphdr *niph;
-	const struct tcphdr *oth;
-	struct tcphdr _otcph, *tcph;
-
-	/* IP header checks: fragment. */
-	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
-		return;
-
-	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
-				 sizeof(_otcph), &_otcph);
-	if (oth == NULL)
-		return;
-
-	/* No RST for RST. */
-	if (oth->rst)
-		return;
-
-	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
-		return;
-
-	/* Check checksum */
-	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
-		return;
-	oiph = ip_hdr(oldskb);
-
-	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
-			 LL_MAX_HEADER, GFP_ATOMIC);
-	if (!nskb)
-		return;
-
-	skb_reserve(nskb, LL_MAX_HEADER);
-
-	skb_reset_network_header(nskb);
-	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
-	niph->version	= 4;
-	niph->ihl	= sizeof(struct iphdr) / 4;
-	niph->tos	= 0;
-	niph->id	= 0;
-	niph->frag_off	= htons(IP_DF);
-	niph->protocol	= IPPROTO_TCP;
-	niph->check	= 0;
-	niph->saddr	= oiph->daddr;
-	niph->daddr	= oiph->saddr;
-
-	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
-	memset(tcph, 0, sizeof(*tcph));
-	tcph->source	= oth->dest;
-	tcph->dest	= oth->source;
-	tcph->doff	= sizeof(struct tcphdr) / 4;
-
-	if (oth->ack)
-		tcph->seq = oth->ack_seq;
-	else {
-		tcph->ack_seq = htonl(ntohl(oth->seq) + oth->syn + oth->fin +
-				      oldskb->len - ip_hdrlen(oldskb) -
-				      (oth->doff << 2));
-		tcph->ack = 1;
-	}
-
-	tcph->rst	= 1;
-	tcph->check = ~tcp_v4_check(sizeof(struct tcphdr), niph->saddr,
-				    niph->daddr, 0);
-	nskb->ip_summed = CHECKSUM_PARTIAL;
-	nskb->csum_start = (unsigned char *)tcph - nskb->head;
-	nskb->csum_offset = offsetof(struct tcphdr, check);
-
-	/* ip_route_me_harder expects skb->dst to be set */
-	skb_dst_set_noref(nskb, skb_dst(oldskb));
-
-	nskb->protocol = htons(ETH_P_IP);
-	if (ip_route_me_harder(nskb, RTN_UNSPEC))
-		goto free_nskb;
-
-	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
-
-	/* "Never happens" */
-	if (nskb->len > dst_mtu(skb_dst(nskb)))
-		goto free_nskb;
-
-	nf_ct_attach(nskb, oldskb);
-
-#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	/* If we use ip_local_out for bridged traffic, the MAC source on
-	 * the RST will be ours, instead of the destination's.  This confuses
-	 * some routers/firewalls, and they drop the packet.  So we need to
-	 * build the eth header using the original destination's MAC as the
-	 * source, and send the RST packet directly.
-	 */
-	if (oldskb->nf_bridge) {
-		struct ethhdr *oeth = eth_hdr(oldskb);
-		nskb->dev = oldskb->nf_bridge->physindev;
-		niph->tot_len = htons(nskb->len);
-		ip_send_check(niph);
-		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
-				    oeth->h_source, oeth->h_dest, nskb->len) < 0)
-			goto free_nskb;
-		dev_queue_xmit(nskb);
-	} else
-#endif
-		ip_local_out(nskb);
-
-	return;
-
- free_nskb:
-	kfree_skb(nskb);
-}
-
+void nf_send_reset(struct sk_buff *oldskb, int hook);
 
 #endif /* _IPV4_NF_REJECT_H */
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 345242a..4c019d5 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -61,8 +61,13 @@ config NFT_CHAIN_ROUTE_IPV4
 	  fields such as the source, destination, type of service and
 	  the packet mark.
 
+config NF_REJECT_IPV4
+	tristate "IPv4 packet rejection"
+	default m if NETFILTER_ADVANCED=n
+
 config NFT_REJECT_IPV4
 	depends on NF_TABLES_IPV4
+	select NF_REJECT_IPV4
 	default NFT_REJECT
 	tristate
 
@@ -208,6 +213,7 @@ config IP_NF_FILTER
 config IP_NF_TARGET_REJECT
 	tristate "REJECT target support"
 	depends on IP_NF_FILTER
+	select NF_REJECT_IPV4
 	default m if NETFILTER_ADVANCED=n
 	help
 	  The REJECT target allows a filtering rule to specify that an ICMP
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 14488cc..f4cef5a 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -23,6 +23,9 @@ obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
 obj-$(CONFIG_NF_LOG_ARP) += nf_log_arp.o
 obj-$(CONFIG_NF_LOG_IPV4) += nf_log_ipv4.o
 
+# reject
+obj-$(CONFIG_NF_REJECT_IPV4) += nf_reject_ipv4.o
+
 # NAT helpers (nf_conntrack)
 obj-$(CONFIG_NF_NAT_H323) += nf_nat_h323.o
 obj-$(CONFIG_NF_NAT_PPTP) += nf_nat_pptp.o
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
new file mode 100644
index 0000000..b023b4e
--- /dev/null
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -0,0 +1,127 @@
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <net/route.h>
+#include <net/dst.h>
+#include <linux/netfilter_ipv4.h>
+
+/* Send RST reply */
+void nf_send_reset(struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	const struct iphdr *oiph;
+	struct iphdr *niph;
+	const struct tcphdr *oth;
+	struct tcphdr _otcph, *tcph;
+
+	/* IP header checks: fragment. */
+	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
+		return;
+
+	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
+				 sizeof(_otcph), &_otcph);
+	if (oth == NULL)
+		return;
+
+	/* No RST for RST. */
+	if (oth->rst)
+		return;
+
+	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return;
+
+	/* Check checksum */
+	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
+		return;
+	oiph = ip_hdr(oldskb);
+
+	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
+			 LL_MAX_HEADER, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	skb_reserve(nskb, LL_MAX_HEADER);
+
+	skb_reset_network_header(nskb);
+	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
+	niph->version	= 4;
+	niph->ihl	= sizeof(struct iphdr) / 4;
+	niph->tos	= 0;
+	niph->id	= 0;
+	niph->frag_off	= htons(IP_DF);
+	niph->protocol	= IPPROTO_TCP;
+	niph->check	= 0;
+	niph->saddr	= oiph->daddr;
+	niph->daddr	= oiph->saddr;
+
+	skb_reset_transport_header(nskb);
+	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
+	memset(tcph, 0, sizeof(*tcph));
+	tcph->source	= oth->dest;
+	tcph->dest	= oth->source;
+	tcph->doff	= sizeof(struct tcphdr) / 4;
+
+	if (oth->ack)
+		tcph->seq = oth->ack_seq;
+	else {
+		tcph->ack_seq = htonl(ntohl(oth->seq) + oth->syn + oth->fin +
+				      oldskb->len - ip_hdrlen(oldskb) -
+				      (oth->doff << 2));
+		tcph->ack = 1;
+	}
+
+	tcph->rst	= 1;
+	tcph->check = ~tcp_v4_check(sizeof(struct tcphdr), niph->saddr,
+				    niph->daddr, 0);
+	nskb->ip_summed = CHECKSUM_PARTIAL;
+	nskb->csum_start = (unsigned char *)tcph - nskb->head;
+	nskb->csum_offset = offsetof(struct tcphdr, check);
+
+	/* ip_route_me_harder expects skb->dst to be set */
+	skb_dst_set_noref(nskb, skb_dst(oldskb));
+
+	nskb->protocol = htons(ETH_P_IP);
+	if (ip_route_me_harder(nskb, RTN_UNSPEC))
+		goto free_nskb;
+
+	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
+
+	/* "Never happens" */
+	if (nskb->len > dst_mtu(skb_dst(nskb)))
+		goto free_nskb;
+
+	nf_ct_attach(nskb, oldskb);
+
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	/* If we use ip_local_out for bridged traffic, the MAC source on
+	 * the RST will be ours, instead of the destination's.  This confuses
+	 * some routers/firewalls, and they drop the packet.  So we need to
+	 * build the eth header using the original destination's MAC as the
+	 * source, and send the RST packet directly.
+	 */
+	if (oldskb->nf_bridge) {
+		struct ethhdr *oeth = eth_hdr(oldskb);
+		nskb->dev = oldskb->nf_bridge->physindev;
+		niph->tot_len = htons(nskb->len);
+		ip_send_check(niph);
+		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
+				    oeth->h_source, oeth->h_dest, nskb->len) < 0)
+			goto free_nskb;
+		dev_queue_xmit(nskb);
+	} else
+#endif
+		ip_local_out(nskb);
+
+	return;
+
+ free_nskb:
+	kfree_skb(nskb);
+}
+EXPORT_SYMBOL_GPL(nf_send_reset);
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index bb1a40d..6af874f 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -40,8 +40,13 @@ config NFT_CHAIN_ROUTE_IPV6
 	  fields such as the source, destination, flowlabel, hop-limit and
 	  the packet mark.
 
+config NF_REJECT_IPV6
+	tristate "IPv6 packet rejection"
+	default m if NETFILTER_ADVANCED=n
+
 config NFT_REJECT_IPV6
 	depends on NF_TABLES_IPV6
+	select NF_REJECT_IPV6
 	default NFT_REJECT
 	tristate
 
@@ -208,6 +213,7 @@ config IP6_NF_FILTER
 config IP6_NF_TARGET_REJECT
 	tristate "REJECT target support"
 	depends on IP6_NF_FILTER
+	select NF_REJECT_IPV6
 	default m if NETFILTER_ADVANCED=n
 	help
 	  The REJECT target allows a filtering rule to specify that an ICMPv6
diff --git a/net/ipv6/netfilter/Makefile b/net/ipv6/netfilter/Makefile
index 0f7e5b3..fbb25f0 100644
--- a/net/ipv6/netfilter/Makefile
+++ b/net/ipv6/netfilter/Makefile
@@ -27,6 +27,9 @@ obj-$(CONFIG_NF_DEFRAG_IPV6) += nf_defrag_ipv6.o
 # logging
 obj-$(CONFIG_NF_LOG_IPV6) += nf_log_ipv6.o
 
+# reject
+obj-$(CONFIG_NF_REJECT_IPV6) += nf_reject_ipv6.o
+
 # nf_tables
 obj-$(CONFIG_NF_TABLES_IPV6) += nf_tables_ipv6.o
 obj-$(CONFIG_NFT_CHAIN_ROUTE_IPV6) += nft_chain_route_ipv6.o
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
new file mode 100644
index 0000000..5f5f043
--- /dev/null
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -0,0 +1,163 @@
+/* (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_checksum.h>
+#include <linux/netfilter_ipv6.h>
+
+void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	struct tcphdr otcph, *tcph;
+	unsigned int otcplen, hh_len;
+	int tcphoff, needs_ack;
+	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
+	struct ipv6hdr *ip6h;
+#define DEFAULT_TOS_VALUE	0x0U
+	const __u8 tclass = DEFAULT_TOS_VALUE;
+	struct dst_entry *dst = NULL;
+	u8 proto;
+	__be16 frag_off;
+	struct flowi6 fl6;
+
+	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
+	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
+		pr_debug("addr is not unicast.\n");
+		return;
+	}
+
+	proto = oip6h->nexthdr;
+	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data), &proto, &frag_off);
+
+	if ((tcphoff < 0) || (tcphoff > oldskb->len)) {
+		pr_debug("Cannot get TCP header.\n");
+		return;
+	}
+
+	otcplen = oldskb->len - tcphoff;
+
+	/* IP header checks: fragment, too short. */
+	if (proto != IPPROTO_TCP || otcplen < sizeof(struct tcphdr)) {
+		pr_debug("proto(%d) != IPPROTO_TCP, "
+			 "or too short. otcplen = %d\n",
+			 proto, otcplen);
+		return;
+	}
+
+	if (skb_copy_bits(oldskb, tcphoff, &otcph, sizeof(struct tcphdr)))
+		BUG();
+
+	/* No RST for RST. */
+	if (otcph.rst) {
+		pr_debug("RST is set\n");
+		return;
+	}
+
+	/* Check checksum. */
+	if (nf_ip6_checksum(oldskb, hook, tcphoff, IPPROTO_TCP)) {
+		pr_debug("TCP checksum is invalid\n");
+		return;
+	}
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	fl6.saddr = oip6h->daddr;
+	fl6.daddr = oip6h->saddr;
+	fl6.fl6_sport = otcph.dest;
+	fl6.fl6_dport = otcph.source;
+	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (dst == NULL || dst->error) {
+		dst_release(dst);
+		return;
+	}
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
+	if (IS_ERR(dst))
+		return;
+
+	hh_len = (dst->dev->hard_header_len + 15)&~15;
+	nskb = alloc_skb(hh_len + 15 + dst->header_len + sizeof(struct ipv6hdr)
+			 + sizeof(struct tcphdr) + dst->trailer_len,
+			 GFP_ATOMIC);
+
+	if (!nskb) {
+		net_dbg_ratelimited("cannot alloc skb\n");
+		dst_release(dst);
+		return;
+	}
+
+	skb_dst_set(nskb, dst);
+
+	skb_reserve(nskb, hh_len + dst->header_len);
+
+	skb_put(nskb, sizeof(struct ipv6hdr));
+	skb_reset_network_header(nskb);
+	ip6h = ipv6_hdr(nskb);
+	ip6_flow_hdr(ip6h, tclass, 0);
+	ip6h->hop_limit = ip6_dst_hoplimit(dst);
+	ip6h->nexthdr = IPPROTO_TCP;
+	ip6h->saddr = oip6h->daddr;
+	ip6h->daddr = oip6h->saddr;
+
+	skb_reset_transport_header(nskb);
+	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
+	/* Truncate to length (no data) */
+	tcph->doff = sizeof(struct tcphdr)/4;
+	tcph->source = otcph.dest;
+	tcph->dest = otcph.source;
+
+	if (otcph.ack) {
+		needs_ack = 0;
+		tcph->seq = otcph.ack_seq;
+		tcph->ack_seq = 0;
+	} else {
+		needs_ack = 1;
+		tcph->ack_seq = htonl(ntohl(otcph.seq) + otcph.syn + otcph.fin
+				      + otcplen - (otcph.doff<<2));
+		tcph->seq = 0;
+	}
+
+	/* Reset flags */
+	((u_int8_t *)tcph)[13] = 0;
+	tcph->rst = 1;
+	tcph->ack = needs_ack;
+	tcph->window = 0;
+	tcph->urg_ptr = 0;
+	tcph->check = 0;
+
+	/* Adjust TCP checksum */
+	tcph->check = csum_ipv6_magic(&ipv6_hdr(nskb)->saddr,
+				      &ipv6_hdr(nskb)->daddr,
+				      sizeof(struct tcphdr), IPPROTO_TCP,
+				      csum_partial(tcph,
+						   sizeof(struct tcphdr), 0));
+
+	nf_ct_attach(nskb, oldskb);
+
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	/* If we use ip6_local_out for bridged traffic, the MAC source on
+	 * the RST will be ours, instead of the destination's.  This confuses
+	 * some routers/firewalls, and they drop the packet.  So we need to
+	 * build the eth header using the original destination's MAC as the
+	 * source, and send the RST packet directly.
+	 */
+	if (oldskb->nf_bridge) {
+		struct ethhdr *oeth = eth_hdr(oldskb);
+		nskb->dev = oldskb->nf_bridge->physindev;
+		nskb->protocol = htons(ETH_P_IPV6);
+		ip6h->payload_len = htons(sizeof(struct tcphdr));
+		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
+				    oeth->h_source, oeth->h_dest, nskb->len) < 0)
+			return;
+		dev_queue_xmit(nskb);
+	} else
+#endif
+		ip6_local_out(nskb);
+}
+EXPORT_SYMBOL_GPL(nf_send_reset6);
-- 
1.7.10.4

