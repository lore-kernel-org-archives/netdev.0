From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv3 net-next 4/4] tunnel: drop packet if ECN present with
 not-ECT
Date: Tue, 25 Sep 2012 14:02:48 -0700
Message-ID: <20120925140248.79fea8f6@nehalam.linuxnetplumber.net>
References: <20120925041222.056704869@vyatta.com>
	<20120925041259.337491375@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Wright <chrisw@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34675 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736Ab2IYVDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 17:03:22 -0400
In-Reply-To: <20120925041259.337491375@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux tunnels were written before RFC6040 and therefore never
implemented the corner case of ECN getting set in the outer header
and the inner header not being ready for it.

Section 4.2.  Default Tunnel Egress Behaviour.
 o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
      propagate any other ECN codepoint onwards.  This is because the
      inner Not-ECT marking is set by transports that rely on dropped
      packets as an indication of congestion and would not understand or
      respond to any other ECN codepoint [RFC4774].  Specifically:

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         CE, the decapsulator MUST drop the packet.

      *  If the inner ECN field is Not-ECT and the outer ECN field is
         Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
         outgoing packet with the ECN field cleared to Not-ECT.

This patch moves the ECN decap logic out of the individual tunnels
into a common place.

It also adds logging to allow detecting broken systems that
set ECN bits incorrectly when tunneling (or an intermediate
router might be changing the header).

Overloads rx_frame_error to keep track of ECN related error.

Thanks to Chris Wright who caught this while reviewing the new VXLAN
tunnel.

This code was tested by injecting faulty logic in other end GRE
to send incorrectly encapsulated packets.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v3 - add common code and logging for ECN broken encapsulation
v2 - supersedes earlier GRE only version

 include/net/inet_ecn.h |   76 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c      |   38 ++++++++++++++----------
 net/ipv4/ipip.c        |   42 ++++++++++++++++-----------
 net/ipv6/ip6_gre.c     |   54 +++++++++++++++-------------------
 4 files changed, 147 insertions(+), 63 deletions(-)

--- a/net/ipv4/ip_gre.c	2012-09-25 08:37:13.995876570 -0700
+++ b/net/ipv4/ip_gre.c	2012-09-25 11:00:46.918340181 -0700
@@ -120,6 +120,10 @@
    Alexey Kuznetsov.
  */
 
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
 static void ipgre_tunnel_setup(struct net_device *dev);
@@ -204,7 +208,9 @@ static struct rtnl_link_stats64 *ipgre_g
 	tot->rx_crc_errors = dev->stats.rx_crc_errors;
 	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
 	tot->rx_errors = dev->stats.rx_errors;
+
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -587,17 +593,6 @@ static void ipgre_err(struct sk_buff *sk
 	t->err_time = jiffies;
 }
 
-static inline void ipgre_ecn_decapsulate(const struct iphdr *iph, struct sk_buff *skb)
-{
-	if (INET_ECN_is_ce(iph->tos)) {
-		if (skb->protocol == htons(ETH_P_IP)) {
-			IP_ECN_set_ce(ip_hdr(skb));
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
-			IP6_ECN_set_ce(ipv6_hdr(skb));
-		}
-	}
-}
-
 static inline u8
 ipgre_ecn_encapsulate(u8 tos, const struct iphdr *old_iph, struct sk_buff *skb)
 {
@@ -620,6 +615,7 @@ static int ipgre_rcv(struct sk_buff *skb
 	struct ip_tunnel *tunnel;
 	int    offset = 4;
 	__be16 gre_proto;
+	int    err;
 
 	if (!pskb_may_pull(skb, 16))
 		goto drop;
@@ -723,17 +719,27 @@ static int ipgre_rcv(struct sk_buff *skb
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		skb_reset_network_header(skb);
+		err = IP_ECN_decapsulate(iph, skb);
+		if (unlikely(err)) {
+			if (log_ecn_error)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &iph->saddr, iph->tos);
+			if (err > 1) {
+				++tunnel->dev->stats.rx_frame_errors;
+				++tunnel->dev->stats.rx_errors;
+				goto drop;
+			}
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		ipgre_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 
 		return 0;
--- a/net/ipv4/ipip.c	2012-09-25 08:37:14.791868701 -0700
+++ b/net/ipv4/ipip.c	2012-09-25 11:01:41.733794349 -0700
@@ -120,6 +120,10 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
 static int ipip_net_id __read_mostly;
 struct ipip_net {
 	struct ip_tunnel __rcu *tunnels_r_l[HASH_SIZE];
@@ -400,28 +404,18 @@ out:
 	return err;
 }
 
-static inline void ipip_ecn_decapsulate(const struct iphdr *outer_iph,
-					struct sk_buff *skb)
-{
-	struct iphdr *inner_iph = ip_hdr(skb);
-
-	if (INET_ECN_is_ce(outer_iph->tos))
-		IP_ECN_set_ce(inner_iph);
-}
-
 static int ipip_rcv(struct sk_buff *skb)
 {
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph = ip_hdr(skb);
+	int err;
 
 	tunnel = ipip_tunnel_lookup(dev_net(skb->dev), iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
 		struct pcpu_tstats *tstats;
 
-		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			kfree_skb(skb);
-			return 0;
-		}
+		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
+			goto drop;
 
 		secpath_reset(skb);
 
@@ -430,21 +424,35 @@ static int ipip_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IP);
 		skb->pkt_type = PACKET_HOST;
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		err = IP_ECN_decapsulate(iph, skb);
+		if (unlikely(err)) {
+			if (log_ecn_error)
+				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+						     &iph->saddr, iph->tos);
+			if (err > 1) {
+				++tunnel->dev->stats.rx_frame_errors;
+				++tunnel->dev->stats.rx_errors;
+				goto drop;
+			}
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		ipip_ecn_decapsulate(iph, skb);
-
 		netif_rx(skb);
 		return 0;
 	}
 
 	return -1;
+
+drop:
+	kfree_skb(skb);
+	return 0;
 }
 
 /*
--- a/net/ipv6/ip6_gre.c	2012-09-25 08:37:13.995876570 -0700
+++ b/net/ipv6/ip6_gre.c	2012-09-25 11:00:35.478454105 -0700
@@ -56,6 +56,10 @@
 #include <net/ip6_tunnel.h>
 
 
+static bool log_ecn_error = true;
+module_param(log_ecn_error, bool, 0644);
+MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
+
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
 #define IPV6_TCLASS_SHIFT 20
 
@@ -149,7 +153,9 @@ static struct rtnl_link_stats64 *ip6gre_
 	tot->rx_crc_errors = dev->stats.rx_crc_errors;
 	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
 	tot->rx_errors = dev->stats.rx_errors;
+
 	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
@@ -489,28 +495,6 @@ static void ip6gre_err(struct sk_buff *s
 	t->err_time = jiffies;
 }
 
-static inline void ip6gre_ecn_decapsulate_ipv4(const struct ip6_tnl *t,
-		const struct ipv6hdr *ipv6h, struct sk_buff *skb)
-{
-	__u8 dsfield = ipv6_get_dsfield(ipv6h) & ~INET_ECN_MASK;
-
-	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-		ipv4_change_dsfield(ip_hdr(skb), INET_ECN_MASK, dsfield);
-
-	if (INET_ECN_is_ce(dsfield))
-		IP_ECN_set_ce(ip_hdr(skb));
-}
-
-static inline void ip6gre_ecn_decapsulate_ipv6(const struct ip6_tnl *t,
-		const struct ipv6hdr *ipv6h, struct sk_buff *skb)
-{
-	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-		ipv6_copy_dscp(ipv6_get_dsfield(ipv6h), ipv6_hdr(skb));
-
-	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
-		IP6_ECN_set_ce(ipv6_hdr(skb));
-}
-
 static int ip6gre_rcv(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ipv6h;
@@ -522,6 +506,7 @@ static int ip6gre_rcv(struct sk_buff *sk
 	struct ip6_tnl *tunnel;
 	int    offset = 4;
 	__be16 gre_proto;
+	int err;
 
 	if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
 		goto drop;
@@ -625,20 +610,29 @@ static int ip6gre_rcv(struct sk_buff *sk
 			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 		}
 
+		__skb_tunnel_rx(skb, tunnel->dev);
+
+		skb_reset_network_header(skb);
+
+		err = IP6_ECN_decapsulate(ipv6h, skb);
+		if (unlikely(err)) {
+			if (log_ecn_error)
+				net_info_ratelimited("non-ECT from %pI6 with dsfield=%#x\n",
+						     &ipv6h->saddr,
+						     ipv6_get_dsfield(ipv6h));
+			if (err > 1) {
+				++tunnel->dev->stats.rx_frame_errors;
+				++tunnel->dev->stats.rx_errors;
+				goto drop;
+			}
+		}
+
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
 		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 		u64_stats_update_end(&tstats->syncp);
 
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		if (skb->protocol == htons(ETH_P_IP))
-			ip6gre_ecn_decapsulate_ipv4(tunnel, ipv6h, skb);
-		else if (skb->protocol == htons(ETH_P_IPV6))
-			ip6gre_ecn_decapsulate_ipv6(tunnel, ipv6h, skb);
-
 		netif_rx(skb);
 
 		return 0;
--- a/include/net/inet_ecn.h	2012-08-15 08:59:22.766706151 -0700
+++ b/include/net/inet_ecn.h	2012-09-25 10:50:45.408313935 -0700
@@ -15,6 +15,8 @@ enum {
 	INET_ECN_MASK = 3,
 };
 
+extern int sysctl_tunnel_ecn_log;
+
 static inline int INET_ECN_is_ce(__u8 dsfield)
 {
 	return (dsfield & INET_ECN_MASK) == INET_ECN_CE;
@@ -145,4 +147,78 @@ static inline int INET_ECN_set_ce(struct
 	return 0;
 }
 
+/*
+ * RFC 6080 4.2
+ *  To decapsulate the inner header at the tunnel egress, a compliant
+ *  tunnel egress MUST set the outgoing ECN field to the codepoint at the
+ *  intersection of the appropriate arriving inner header (row) and outer
+ *  header (column) in Figure 4
+ *
+ *      +---------+------------------------------------------------+
+ *      |Arriving |            Arriving Outer Header               |
+ *      |   Inner +---------+------------+------------+------------+
+ *      |  Header | Not-ECT | ECT(0)     | ECT(1)     |     CE     |
+ *      +---------+---------+------------+------------+------------+
+ *      | Not-ECT | Not-ECT |Not-ECT(!!!)|Not-ECT(!!!)| <drop>(!!!)|
+ *      |  ECT(0) |  ECT(0) | ECT(0)     | ECT(1)     |     CE     |
+ *      |  ECT(1) |  ECT(1) | ECT(1) (!) | ECT(1)     |     CE     |
+ *      |    CE   |      CE |     CE     |     CE(!!!)|     CE     |
+ *      +---------+---------+------------+------------+------------+
+ *
+ *             Figure 4: New IP in IP Decapsulation Behaviour
+ *
+ *  returns 0 on success
+ *          1 if something is broken and should be logged (!!! above)
+ *          2 if packet should be dropped
+ */
+static inline int INET_ECN_decapsulate(struct sk_buff *skb,
+				       __u8 outer, __u8 inner)
+{
+	if (INET_ECN_is_not_ect(inner)) {
+		switch (outer & INET_ECN_MASK) {
+		case INET_ECN_NOT_ECT:
+			return 0;
+		case INET_ECN_ECT_0:
+		case INET_ECN_ECT_1:
+			return 1;
+		case INET_ECN_CE:
+			return 2;
+		}
+	}
+
+	if (INET_ECN_is_ce(outer))
+		INET_ECN_set_ce(skb);
+
+	return 0;
+}
+
+static inline int IP_ECN_decapsulate(const struct iphdr *oiph,
+				     struct sk_buff *skb)
+{
+	__u8 inner;
+
+	if (skb->protocol == htons(ETH_P_IP))
+		inner = ip_hdr(skb)->tos;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		inner = ipv6_get_dsfield(ipv6_hdr(skb));
+	else
+		return 0;
+
+	return INET_ECN_decapsulate(skb, oiph->tos, inner);
+}
+
+static inline int IP6_ECN_decapsulate(const struct ipv6hdr *oipv6h,
+				      struct sk_buff *skb)
+{
+	__u8 inner;
+
+	if (skb->protocol == htons(ETH_P_IP))
+		inner = ip_hdr(skb)->tos;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		inner = ipv6_get_dsfield(ipv6_hdr(skb));
+	else
+		return 0;
+
+	return INET_ECN_decapsulate(skb, ipv6_get_dsfield(oipv6h), inner);
+}
 #endif
