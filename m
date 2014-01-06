From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/13] netfilter: REJECT: separate reusable code
Date: Mon,  6 Jan 2014 14:46:37 +0100
Message-ID: <1389016002-9116-9-git-send-email-pablo@netfilter.org>
References: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389016002-9116-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Leblond <eric@regit.org>

This patch prepares the addition of TCP reset support in
the nft_reject module by moving reusable code into a header
file.

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_reject.h |  128 +++++++++++++++++++++++
 include/net/netfilter/ipv6/nf_reject.h |  171 ++++++++++++++++++++++++++++++
 net/ipv4/netfilter/ipt_REJECT.c        |  140 ++-----------------------
 net/ipv6/netfilter/ip6t_REJECT.c       |  179 ++------------------------------
 4 files changed, 317 insertions(+), 301 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_reject.h
 create mode 100644 include/net/netfilter/ipv6/nf_reject.h

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
new file mode 100644
index 0000000..931fbf8
--- /dev/null
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -0,0 +1,128 @@
+#ifndef _IPV4_NF_REJECT_H
+#define _IPV4_NF_REJECT_H
+
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <net/route.h>
+#include <net/dst.h>
+
+static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
+{
+	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
+}
+
+/* Send RST reply */
+static void nf_send_reset(struct sk_buff *oldskb, int hook)
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
+#ifdef CONFIG_BRIDGE_NETFILTER
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
+
+
+#endif /* _IPV4_NF_REJECT_H */
diff --git a/include/net/netfilter/ipv6/nf_reject.h b/include/net/netfilter/ipv6/nf_reject.h
new file mode 100644
index 0000000..710d17e
--- /dev/null
+++ b/include/net/netfilter/ipv6/nf_reject.h
@@ -0,0 +1,171 @@
+#ifndef _IPV6_NF_REJECT_H
+#define _IPV6_NF_REJECT_H
+
+#include <net/ipv6.h>
+#include <net/ip6_route.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_checksum.h>
+#include <linux/netfilter_ipv6.h>
+
+static inline void
+nf_send_unreach6(struct net *net, struct sk_buff *skb_in, unsigned char code,
+	     unsigned int hooknum)
+{
+	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
+		skb_in->dev = net->loopback_dev;
+
+	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
+}
+
+/* Send RST reply */
+static void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
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
+#ifdef CONFIG_BRIDGE_NETFILTER
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
+
+#endif /* _IPV6_NF_REJECT_H */
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index b969131..5b6e0df 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -17,10 +17,6 @@
 #include <linux/udp.h>
 #include <linux/icmp.h>
 #include <net/icmp.h>
-#include <net/ip.h>
-#include <net/tcp.h>
-#include <net/route.h>
-#include <net/dst.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv4/ipt_REJECT.h>
@@ -28,128 +24,12 @@
 #include <linux/netfilter_bridge.h>
 #endif
 
+#include <net/netfilter/ipv4/nf_reject.h>
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("Xtables: packet \"rejection\" target for IPv4");
 
-/* Send RST reply */
-static void send_reset(struct sk_buff *oldskb, int hook)
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
-#ifdef CONFIG_BRIDGE_NETFILTER
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
-static inline void send_unreach(struct sk_buff *skb_in, int code)
-{
-	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
-}
-
 static unsigned int
 reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -157,28 +37,28 @@ reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 
 	switch (reject->with) {
 	case IPT_ICMP_NET_UNREACHABLE:
-		send_unreach(skb, ICMP_NET_UNREACH);
+		nf_send_unreach(skb, ICMP_NET_UNREACH);
 		break;
 	case IPT_ICMP_HOST_UNREACHABLE:
-		send_unreach(skb, ICMP_HOST_UNREACH);
+		nf_send_unreach(skb, ICMP_HOST_UNREACH);
 		break;
 	case IPT_ICMP_PROT_UNREACHABLE:
-		send_unreach(skb, ICMP_PROT_UNREACH);
+		nf_send_unreach(skb, ICMP_PROT_UNREACH);
 		break;
 	case IPT_ICMP_PORT_UNREACHABLE:
-		send_unreach(skb, ICMP_PORT_UNREACH);
+		nf_send_unreach(skb, ICMP_PORT_UNREACH);
 		break;
 	case IPT_ICMP_NET_PROHIBITED:
-		send_unreach(skb, ICMP_NET_ANO);
+		nf_send_unreach(skb, ICMP_NET_ANO);
 		break;
 	case IPT_ICMP_HOST_PROHIBITED:
-		send_unreach(skb, ICMP_HOST_ANO);
+		nf_send_unreach(skb, ICMP_HOST_ANO);
 		break;
 	case IPT_ICMP_ADMIN_PROHIBITED:
-		send_unreach(skb, ICMP_PKT_FILTERED);
+		nf_send_unreach(skb, ICMP_PKT_FILTERED);
 		break;
 	case IPT_TCP_RESET:
-		send_reset(skb, par->hooknum);
+		nf_send_reset(skb, par->hooknum);
 	case IPT_ICMP_ECHOREPLY:
 		/* Doesn't happen. */
 		break;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index da00a2e..544b0a9 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -23,181 +23,18 @@
 #include <linux/skbuff.h>
 #include <linux/icmpv6.h>
 #include <linux/netdevice.h>
-#include <net/ipv6.h>
-#include <net/tcp.h>
 #include <net/icmp.h>
-#include <net/ip6_checksum.h>
-#include <net/ip6_fib.h>
-#include <net/ip6_route.h>
 #include <net/flow.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 #include <linux/netfilter_ipv6/ip6t_REJECT.h>
 
+#include <net/netfilter/ipv6/nf_reject.h>
+
 MODULE_AUTHOR("Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>");
 MODULE_DESCRIPTION("Xtables: packet \"rejection\" target for IPv6");
 MODULE_LICENSE("GPL");
 
-/* Send RST reply */
-static void send_reset(struct net *net, struct sk_buff *oldskb, int hook)
-{
-	struct sk_buff *nskb;
-	struct tcphdr otcph, *tcph;
-	unsigned int otcplen, hh_len;
-	int tcphoff, needs_ack;
-	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
-	struct ipv6hdr *ip6h;
-#define DEFAULT_TOS_VALUE	0x0U
-	const __u8 tclass = DEFAULT_TOS_VALUE;
-	struct dst_entry *dst = NULL;
-	u8 proto;
-	__be16 frag_off;
-	struct flowi6 fl6;
-
-	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
-	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
-		pr_debug("addr is not unicast.\n");
-		return;
-	}
-
-	proto = oip6h->nexthdr;
-	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data), &proto, &frag_off);
-
-	if ((tcphoff < 0) || (tcphoff > oldskb->len)) {
-		pr_debug("Cannot get TCP header.\n");
-		return;
-	}
-
-	otcplen = oldskb->len - tcphoff;
-
-	/* IP header checks: fragment, too short. */
-	if (proto != IPPROTO_TCP || otcplen < sizeof(struct tcphdr)) {
-		pr_debug("proto(%d) != IPPROTO_TCP, "
-			 "or too short. otcplen = %d\n",
-			 proto, otcplen);
-		return;
-	}
-
-	if (skb_copy_bits(oldskb, tcphoff, &otcph, sizeof(struct tcphdr)))
-		BUG();
-
-	/* No RST for RST. */
-	if (otcph.rst) {
-		pr_debug("RST is set\n");
-		return;
-	}
-
-	/* Check checksum. */
-	if (nf_ip6_checksum(oldskb, hook, tcphoff, IPPROTO_TCP)) {
-		pr_debug("TCP checksum is invalid\n");
-		return;
-	}
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.saddr = oip6h->daddr;
-	fl6.daddr = oip6h->saddr;
-	fl6.fl6_sport = otcph.dest;
-	fl6.fl6_dport = otcph.source;
-	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
-		dst_release(dst);
-		return;
-	}
-	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
-	if (IS_ERR(dst))
-		return;
-
-	hh_len = (dst->dev->hard_header_len + 15)&~15;
-	nskb = alloc_skb(hh_len + 15 + dst->header_len + sizeof(struct ipv6hdr)
-			 + sizeof(struct tcphdr) + dst->trailer_len,
-			 GFP_ATOMIC);
-
-	if (!nskb) {
-		net_dbg_ratelimited("cannot alloc skb\n");
-		dst_release(dst);
-		return;
-	}
-
-	skb_dst_set(nskb, dst);
-
-	skb_reserve(nskb, hh_len + dst->header_len);
-
-	skb_put(nskb, sizeof(struct ipv6hdr));
-	skb_reset_network_header(nskb);
-	ip6h = ipv6_hdr(nskb);
-	ip6_flow_hdr(ip6h, tclass, 0);
-	ip6h->hop_limit = ip6_dst_hoplimit(dst);
-	ip6h->nexthdr = IPPROTO_TCP;
-	ip6h->saddr = oip6h->daddr;
-	ip6h->daddr = oip6h->saddr;
-
-	skb_reset_transport_header(nskb);
-	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
-	/* Truncate to length (no data) */
-	tcph->doff = sizeof(struct tcphdr)/4;
-	tcph->source = otcph.dest;
-	tcph->dest = otcph.source;
-
-	if (otcph.ack) {
-		needs_ack = 0;
-		tcph->seq = otcph.ack_seq;
-		tcph->ack_seq = 0;
-	} else {
-		needs_ack = 1;
-		tcph->ack_seq = htonl(ntohl(otcph.seq) + otcph.syn + otcph.fin
-				      + otcplen - (otcph.doff<<2));
-		tcph->seq = 0;
-	}
-
-	/* Reset flags */
-	((u_int8_t *)tcph)[13] = 0;
-	tcph->rst = 1;
-	tcph->ack = needs_ack;
-	tcph->window = 0;
-	tcph->urg_ptr = 0;
-	tcph->check = 0;
-
-	/* Adjust TCP checksum */
-	tcph->check = csum_ipv6_magic(&ipv6_hdr(nskb)->saddr,
-				      &ipv6_hdr(nskb)->daddr,
-				      sizeof(struct tcphdr), IPPROTO_TCP,
-				      csum_partial(tcph,
-						   sizeof(struct tcphdr), 0));
-
-	nf_ct_attach(nskb, oldskb);
-
-#ifdef CONFIG_BRIDGE_NETFILTER
-	/* If we use ip6_local_out for bridged traffic, the MAC source on
-	 * the RST will be ours, instead of the destination's.  This confuses
-	 * some routers/firewalls, and they drop the packet.  So we need to
-	 * build the eth header using the original destination's MAC as the
-	 * source, and send the RST packet directly.
-	 */
-	if (oldskb->nf_bridge) {
-		struct ethhdr *oeth = eth_hdr(oldskb);
-		nskb->dev = oldskb->nf_bridge->physindev;
-		nskb->protocol = htons(ETH_P_IPV6);
-		ip6h->payload_len = htons(sizeof(struct tcphdr));
-		if (dev_hard_header(nskb, nskb->dev, ntohs(nskb->protocol),
-				    oeth->h_source, oeth->h_dest, nskb->len) < 0)
-			return;
-		dev_queue_xmit(nskb);
-	} else
-#endif
-		ip6_local_out(nskb);
-}
-
-static inline void
-send_unreach(struct net *net, struct sk_buff *skb_in, unsigned char code,
-	     unsigned int hooknum)
-{
-	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
-		skb_in->dev = net->loopback_dev;
-
-	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
-}
 
 static unsigned int
 reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
@@ -208,25 +45,25 @@ reject_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	pr_debug("%s: medium point\n", __func__);
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
-		send_unreach(net, skb, ICMPV6_NOROUTE, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_NOROUTE, par->hooknum);
 		break;
 	case IP6T_ICMP6_ADM_PROHIBITED:
-		send_unreach(net, skb, ICMPV6_ADM_PROHIBITED, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_ADM_PROHIBITED, par->hooknum);
 		break;
 	case IP6T_ICMP6_NOT_NEIGHBOUR:
-		send_unreach(net, skb, ICMPV6_NOT_NEIGHBOUR, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_NOT_NEIGHBOUR, par->hooknum);
 		break;
 	case IP6T_ICMP6_ADDR_UNREACH:
-		send_unreach(net, skb, ICMPV6_ADDR_UNREACH, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_ADDR_UNREACH, par->hooknum);
 		break;
 	case IP6T_ICMP6_PORT_UNREACH:
-		send_unreach(net, skb, ICMPV6_PORT_UNREACH, par->hooknum);
+		nf_send_unreach6(net, skb, ICMPV6_PORT_UNREACH, par->hooknum);
 		break;
 	case IP6T_ICMP6_ECHOREPLY:
 		/* Do nothing */
 		break;
 	case IP6T_TCP_RESET:
-		send_reset(net, skb, par->hooknum);
+		nf_send_reset6(net, skb, par->hooknum);
 		break;
 	default:
 		net_info_ratelimited("case %u not handled yet\n", reject->with);
-- 
1.7.10.4

