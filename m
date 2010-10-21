From: kaber@trash.net
Subject: [PATCH 54/72] ipvs: provide address family for debugging
Date: Thu, 21 Oct 2010 17:19:41 +0200
Message-ID: <1287674399-31455-55-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323Ab0JUPUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:14 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

 	As skb->protocol is not valid in LOCAL_OUT add
parameter for address family in packet debugging functions.
Even if ports are not present in AH and ESP change them to
use ip_vs_tcpudp_debug_packet to show at least valid addresses
as before. This patch removes the last user of skb->protocol
in IPVS.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h                     |   17 +++++-----
 net/netfilter/ipvs/ip_vs_core.c         |   41 ++++++++++++++----------
 net/netfilter/ipvs/ip_vs_proto.c        |    8 ++--
 net/netfilter/ipvs/ip_vs_proto_ah_esp.c |   52 +-----------------------------
 net/netfilter/ipvs/ip_vs_proto_sctp.c   |    2 +-
 net/netfilter/ipvs/ip_vs_proto_tcp.c    |    4 +-
 net/netfilter/ipvs/ip_vs_proto_udp.c    |    4 +-
 net/netfilter/ipvs/ip_vs_xmit.c         |   18 ++++++-----
 8 files changed, 54 insertions(+), 92 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 2f88d59..b7bbd6c 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -136,24 +136,24 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
 		if (net_ratelimit())					\
 			printk(KERN_DEBUG pr_fmt(msg), ##__VA_ARGS__);	\
 	} while (0)
-#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)				\
+#define IP_VS_DBG_PKT(level, af, pp, skb, ofs, msg)			\
 	do {								\
 		if (level <= ip_vs_get_debug_level())			\
-			pp->debug_packet(pp, skb, ofs, msg);		\
+			pp->debug_packet(af, pp, skb, ofs, msg);	\
 	} while (0)
-#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)			\
+#define IP_VS_DBG_RL_PKT(level, af, pp, skb, ofs, msg)			\
 	do {								\
 		if (level <= ip_vs_get_debug_level() &&			\
 		    net_ratelimit())					\
-			pp->debug_packet(pp, skb, ofs, msg);		\
+			pp->debug_packet(af, pp, skb, ofs, msg);	\
 	} while (0)
 #else	/* NO DEBUGGING at ALL */
 #define IP_VS_DBG_BUF(level, msg...)  do {} while (0)
 #define IP_VS_ERR_BUF(msg...)  do {} while (0)
 #define IP_VS_DBG(level, msg...)  do {} while (0)
 #define IP_VS_DBG_RL(msg...)  do {} while (0)
-#define IP_VS_DBG_PKT(level, pp, skb, ofs, msg)		do {} while (0)
-#define IP_VS_DBG_RL_PKT(level, pp, skb, ofs, msg)	do {} while (0)
+#define IP_VS_DBG_PKT(level, af, pp, skb, ofs, msg)	do {} while (0)
+#define IP_VS_DBG_RL_PKT(level, af, pp, skb, ofs, msg)	do {} while (0)
 #endif
 
 #define IP_VS_BUG() BUG()
@@ -345,7 +345,7 @@ struct ip_vs_protocol {
 
 	int (*app_conn_bind)(struct ip_vs_conn *cp);
 
-	void (*debug_packet)(struct ip_vs_protocol *pp,
+	void (*debug_packet)(int af, struct ip_vs_protocol *pp,
 			     const struct sk_buff *skb,
 			     int offset,
 			     const char *msg);
@@ -828,7 +828,8 @@ extern int
 ip_vs_set_state_timeout(int *table, int num, const char *const *names,
 			const char *name, int to);
 extern void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
+ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
+			  const struct sk_buff *skb,
 			  int offset, const char *msg);
 
 extern struct ip_vs_protocol ip_vs_protocol_tcp;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5fbcf67..b4e51e9 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -365,7 +365,8 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	 * with persistence the connection is created on SYN+ACK.
 	 */
 	if (pptr[0] == FTPDATA) {
-		IP_VS_DBG_PKT(12, pp, skb, 0, "Not scheduling FTPDATA");
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
+			      "Not scheduling FTPDATA");
 		return NULL;
 	}
 
@@ -376,7 +377,7 @@ ip_vs_schedule(struct ip_vs_service *svc, struct sk_buff *skb,
 	if ((!skb->dev || skb->dev->flags & IFF_LOOPBACK) &&
 	    (svc->flags & IP_VS_SVC_F_PERSISTENT || svc->fwmark) &&
 	    (cp = pp->conn_in_get(svc->af, skb, pp, &iph, iph.len, 1))) {
-		IP_VS_DBG_PKT(12, pp, skb, 0,
+		IP_VS_DBG_PKT(12, svc->af, pp, skb, 0,
 			      "Not scheduling reply for existing connection");
 		__ip_vs_conn_put(cp);
 		return NULL;
@@ -617,10 +618,10 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 	if (inout)
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
 			"Forwarding altered outgoing ICMP");
 	else
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
+		IP_VS_DBG_PKT(11, AF_INET, pp, skb, (void *)ciph - (void *)iph,
 			"Forwarding altered incoming ICMP");
 }
 
@@ -662,11 +663,13 @@ void ip_vs_nat_icmp_v6(struct sk_buff *skb, struct ip_vs_protocol *pp,
 	skb->ip_summed = CHECKSUM_PARTIAL;
 
 	if (inout)
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered outgoing ICMPv6");
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
+			      (void *)ciph - (void *)iph,
+			      "Forwarding altered outgoing ICMPv6");
 	else
-		IP_VS_DBG_PKT(11, pp, skb, (void *)ciph - (void *)iph,
-			"Forwarding altered incoming ICMPv6");
+		IP_VS_DBG_PKT(11, AF_INET6, pp, skb,
+			      (void *)ciph - (void *)iph,
+			      "Forwarding altered incoming ICMPv6");
 }
 #endif
 
@@ -798,7 +801,8 @@ static int ip_vs_out_icmp(struct sk_buff *skb, int *related,
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMP for");
+	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
+		      "Checking outgoing ICMP for");
 
 	offset += cih->ihl * 4;
 
@@ -874,7 +878,8 @@ static int ip_vs_out_icmp_v6(struct sk_buff *skb, int *related,
 	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMPv6 for");
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+		      "Checking outgoing ICMPv6 for");
 
 	offset += sizeof(struct ipv6hdr);
 
@@ -922,7 +927,7 @@ static unsigned int
 handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		struct ip_vs_conn *cp, int ihl)
 {
-	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Outgoing packet");
 
 	if (!skb_make_writable(skb, ihl))
 		goto drop;
@@ -967,7 +972,7 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		    ip_route_me_harder(skb, RTN_LOCAL) != 0)
 			goto drop;
 
-	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
+	IP_VS_DBG_PKT(10, af, pp, skb, 0, "After SNAT");
 
 	ip_vs_out_stats(cp, skb);
 	ip_vs_set_state(cp, IP_VS_DIR_OUTPUT, skb, pp);
@@ -1117,7 +1122,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
 			}
 		}
 	}
-	IP_VS_DBG_PKT(12, pp, skb, 0,
+	IP_VS_DBG_PKT(12, af, pp, skb, 0,
 		      "ip_vs_out: packet continues traversal as normal");
 	return NF_ACCEPT;
 }
@@ -1253,7 +1258,8 @@ ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 		     pp->dont_defrag))
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMP for");
+	IP_VS_DBG_PKT(11, AF_INET, pp, skb, offset,
+		      "Checking incoming ICMP for");
 
 	offset += cih->ihl * 4;
 
@@ -1364,7 +1370,8 @@ ip_vs_in_icmp_v6(struct sk_buff *skb, int *related, unsigned int hooknum)
 	if (unlikely(cih->nexthdr == IPPROTO_FRAGMENT && pp->dont_defrag))
 		return NF_ACCEPT;
 
-	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMPv6 for");
+	IP_VS_DBG_PKT(11, AF_INET6, pp, skb, offset,
+		      "Checking incoming ICMPv6 for");
 
 	offset += sizeof(struct ipv6hdr);
 
@@ -1492,12 +1499,12 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
 
 	if (unlikely(!cp)) {
 		/* sorry, all this trouble for a no-hit :) */
-		IP_VS_DBG_PKT(12, pp, skb, 0,
+		IP_VS_DBG_PKT(12, af, pp, skb, 0,
 			      "ip_vs_in: packet continues traversal as normal");
 		return NF_ACCEPT;
 	}
 
-	IP_VS_DBG_PKT(11, pp, skb, 0, "Incoming packet");
+	IP_VS_DBG_PKT(11, af, pp, skb, 0, "Incoming packet");
 
 	/* Check the server status */
 	if (cp->dest && !(cp->dest->flags & IP_VS_DEST_F_AVAILABLE)) {
diff --git a/net/netfilter/ipvs/ip_vs_proto.c b/net/netfilter/ipvs/ip_vs_proto.c
index 027f654..c539983 100644
--- a/net/netfilter/ipvs/ip_vs_proto.c
+++ b/net/netfilter/ipvs/ip_vs_proto.c
@@ -172,8 +172,8 @@ ip_vs_tcpudp_debug_packet_v4(struct ip_vs_protocol *pp,
 	else if (ih->frag_off & htons(IP_OFFSET))
 		sprintf(buf, "%pI4->%pI4 frag", &ih->saddr, &ih->daddr);
 	else {
-		__be16 _ports[2], *pptr
-;
+		__be16 _ports[2], *pptr;
+
 		pptr = skb_header_pointer(skb, offset + ih->ihl*4,
 					  sizeof(_ports), _ports);
 		if (pptr == NULL)
@@ -223,13 +223,13 @@ ip_vs_tcpudp_debug_packet_v6(struct ip_vs_protocol *pp,
 
 
 void
-ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp,
+ip_vs_tcpudp_debug_packet(int af, struct ip_vs_protocol *pp,
 			  const struct sk_buff *skb,
 			  int offset,
 			  const char *msg)
 {
 #ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == htons(ETH_P_IPV6))
+	if (af == AF_INET6)
 		ip_vs_tcpudp_debug_packet_v6(pp, skb, offset, msg);
 	else
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
index 8956ef3..3a04611 100644
--- a/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_ah_esp.c
@@ -117,54 +117,6 @@ ah_esp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 	return 0;
 }
 
-
-static void
-ah_esp_debug_packet_v4(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		       int offset, const char *msg)
-{
-	char buf[256];
-	struct iphdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "TRUNCATED");
-	else
-		sprintf(buf, "%pI4->%pI4", &ih->saddr, &ih->daddr);
-
-	pr_debug("%s: %s %s\n", msg, pp->name, buf);
-}
-
-#ifdef CONFIG_IP_VS_IPV6
-static void
-ah_esp_debug_packet_v6(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		       int offset, const char *msg)
-{
-	char buf[256];
-	struct ipv6hdr _iph, *ih;
-
-	ih = skb_header_pointer(skb, offset, sizeof(_iph), &_iph);
-	if (ih == NULL)
-		sprintf(buf, "TRUNCATED");
-	else
-		sprintf(buf, "%pI6->%pI6", &ih->saddr, &ih->daddr);
-
-	pr_debug("%s: %s %s\n", msg, pp->name, buf);
-}
-#endif
-
-static void
-ah_esp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
-		    int offset, const char *msg)
-{
-#ifdef CONFIG_IP_VS_IPV6
-	if (skb->protocol == htons(ETH_P_IPV6))
-		ah_esp_debug_packet_v6(pp, skb, offset, msg);
-	else
-#endif
-		ah_esp_debug_packet_v4(pp, skb, offset, msg);
-}
-
-
 static void ah_esp_init(struct ip_vs_protocol *pp)
 {
 	/* nothing to do now */
@@ -195,7 +147,7 @@ struct ip_vs_protocol ip_vs_protocol_ah = {
 	.register_app =		NULL,
 	.unregister_app =	NULL,
 	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
+	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
 	.set_state_timeout =	NULL,
 };
@@ -219,7 +171,7 @@ struct ip_vs_protocol ip_vs_protocol_esp = {
 	.register_app =		NULL,
 	.unregister_app =	NULL,
 	.app_conn_bind =	NULL,
-	.debug_packet =		ah_esp_debug_packet,
+	.debug_packet =		ip_vs_tcpudp_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
 };
 #endif
diff --git a/net/netfilter/ipvs/ip_vs_proto_sctp.c b/net/netfilter/ipvs/ip_vs_proto_sctp.c
index 9ab5232..d254345 100644
--- a/net/netfilter/ipvs/ip_vs_proto_sctp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_sctp.c
@@ -176,7 +176,7 @@ sctp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 
 	if (val != cmp) {
 		/* CRC failure, dump it. */
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 				"Failed checksum for");
 		return 0;
 	}
diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index 85d80a6..f6c5200 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -300,7 +300,7 @@ tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 					    skb->len - tcphoff,
 					    ipv6_hdr(skb)->nexthdr,
 					    skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 						 "Failed checksum for");
 				return 0;
 			}
@@ -311,7 +311,7 @@ tcp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 					      skb->len - tcphoff,
 					      ip_hdr(skb)->protocol,
 					      skb->csum)) {
-				IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+				IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 						 "Failed checksum for");
 				return 0;
 			}
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 5d21f08..9d106a0 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -314,7 +314,7 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 						    skb->len - udphoff,
 						    ipv6_hdr(skb)->nexthdr,
 						    skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 							 "Failed checksum for");
 					return 0;
 				}
@@ -325,7 +325,7 @@ udp_csum_check(int af, struct sk_buff *skb, struct ip_vs_protocol *pp)
 						      skb->len - udphoff,
 						      ip_hdr(skb)->protocol,
 						      skb->csum)) {
-					IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+					IP_VS_DBG_RL_PKT(0, af, pp, skb, 0,
 							 "Failed checksum for");
 					return 0;
 				}
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 97b5361..de04ea3 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -543,7 +543,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, pp, skb, 0, "ip_vs_nat_xmit(): "
+			IP_VS_DBG_RL_PKT(10, AF_INET, pp, skb, 0,
+					 "ip_vs_nat_xmit(): "
 					 "stopping DNAT to local address");
 			goto tx_error_put;
 		}
@@ -552,7 +553,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* From world but DNAT to loopback address? */
 	if (local && ipv4_is_loopback(rt->rt_dst) && skb_rtable(skb)->fl.iif) {
-		IP_VS_DBG_RL_PKT(1, pp, skb, 0, "ip_vs_nat_xmit(): "
+		IP_VS_DBG_RL_PKT(1, AF_INET, pp, skb, 0, "ip_vs_nat_xmit(): "
 				 "stopping DNAT to loopback address");
 		goto tx_error_put;
 	}
@@ -561,7 +562,8 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	mtu = dst_mtu(&rt->dst);
 	if ((skb->len > mtu) && (iph->frag_off & htons(IP_DF))) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0, "ip_vs_nat_xmit(): frag needed for");
+		IP_VS_DBG_RL_PKT(0, AF_INET, pp, skb, 0,
+				 "ip_vs_nat_xmit(): frag needed for");
 		goto tx_error_put;
 	}
 
@@ -593,7 +595,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			goto tx_error;
 	}
 
-	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET, pp, skb, 0, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
@@ -654,7 +656,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		struct nf_conn *ct = ct = nf_ct_get(skb, &ctinfo);
 
 		if (ct && !nf_ct_is_untracked(ct)) {
-			IP_VS_DBG_RL_PKT(10, pp, skb, 0,
+			IP_VS_DBG_RL_PKT(10, AF_INET6, pp, skb, 0,
 					 "ip_vs_nat_xmit_v6(): "
 					 "stopping DNAT to local address");
 			goto tx_error_put;
@@ -665,7 +667,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	/* From world but DNAT to loopback address? */
 	if (local && skb->dev && !(skb->dev->flags & IFF_LOOPBACK) &&
 	    ipv6_addr_type(&rt->rt6i_dst.addr) & IPV6_ADDR_LOOPBACK) {
-		IP_VS_DBG_RL_PKT(1, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(1, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): "
 				 "stopping DNAT to loopback address");
 		goto tx_error_put;
@@ -680,7 +682,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			skb->dev = net->loopback_dev;
 		}
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP_VS_DBG_RL_PKT(0, pp, skb, 0,
+		IP_VS_DBG_RL_PKT(0, AF_INET6, pp, skb, 0,
 				 "ip_vs_nat_xmit_v6(): frag needed for");
 		goto tx_error_put;
 	}
@@ -706,7 +708,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 		dst_release(&rt->dst);
 	}
 
-	IP_VS_DBG_PKT(10, pp, skb, 0, "After DNAT");
+	IP_VS_DBG_PKT(10, AF_INET6, pp, skb, 0, "After DNAT");
 
 	/* FIXME: when application helper enlarges the packet and the length
 	   is larger than the MTU of outgoing device, there will be still
-- 
1.7.1

