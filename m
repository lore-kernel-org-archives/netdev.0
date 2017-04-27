From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 4/9] ipvlan: rework the IP lookup function
Date: Thu, 27 Apr 2017 15:51:37 +0100
Message-ID: <20170427145142.15830-5-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:58459 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755641AbdD0Owk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:40 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions ipvlan_get_L3_hdr and ipvlan_addr_lookup are used to determine
whether a packet belongs to a slave by looking at L3 addresses. Being
tightly coupled, these two functions are always used in pair and have
some duplicated code that could be shared.

This patch combines them into a single ipvlan_get_slave_addr function
and refactor caller functions, streamlining code and improving
readability.

A ipvlan_get_slave_addr_dst utility function is also provided as most
lookups are based on the destination IP address.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
Tested-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 187 +++++++++++----------------------------
 1 file changed, 52 insertions(+), 135 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 4683bad..876ce37 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -116,25 +116,34 @@ bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6)
 	return false;
 }
 
-static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
+static struct ipvl_addr *ipvlan_get_slave_addr(struct sk_buff *skb,
+					       struct ipvl_port *port,
+					       bool use_dest)
 {
-	void *lyr3h = NULL;
+	struct ipvl_addr *addr = NULL;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_ARP): {
-		struct arphdr *arph;
+		u8 *arp_ptr;
+		__be32 dip;
 
-		if (unlikely(!pskb_may_pull(skb, sizeof(*arph))))
+		if (unlikely(!pskb_may_pull(skb, sizeof(struct arphdr))))
 			return NULL;
 
-		arph = arp_hdr(skb);
-		*type = IPVL_ARP;
-		lyr3h = arph;
+		arp_ptr = (u8 *)(arp_hdr(skb) + 1);
+		if (use_dest)
+			arp_ptr += (2 * port->dev->addr_len) + 4;
+		else
+			arp_ptr += port->dev->addr_len;
+
+		memcpy(&dip, arp_ptr, 4);
+		addr = ipvlan_ht_addr_lookup(port, &dip, false);
 		break;
 	}
 	case htons(ETH_P_IP): {
 		u32 pktlen;
 		struct iphdr *ip4h;
+		__be32 *i4addr;
 
 		if (unlikely(!pskb_may_pull(skb, sizeof(*ip4h))))
 			return NULL;
@@ -146,12 +155,14 @@ static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
 		if (skb->len < pktlen || pktlen < (ip4h->ihl * 4))
 			return NULL;
 
-		*type = IPVL_IPV4;
-		lyr3h = ip4h;
+		i4addr = use_dest ? &ip4h->daddr : &ip4h->saddr;
+		addr = ipvlan_ht_addr_lookup(port, i4addr, false);
 		break;
 	}
 	case htons(ETH_P_IPV6): {
 		struct ipv6hdr *ip6h;
+		struct nd_msg *ndmh;
+		struct in6_addr *i6addr;
 
 		if (unlikely(!pskb_may_pull(skb, sizeof(*ip6h))))
 			return NULL;
@@ -160,21 +171,28 @@ static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
 		if (ip6h->version != 6)
 			return NULL;
 
-		*type = IPVL_IPV6;
-		lyr3h = ip6h;
-		/* Only Neighbour Solicitation pkts need different treatment */
+		ndmh = (struct nd_msg *)(ip6h + 1);
 		if (ipv6_addr_any(&ip6h->saddr) &&
-		    ip6h->nexthdr == NEXTHDR_ICMP) {
-			*type = IPVL_ICMPV6;
-			lyr3h = ip6h + 1;
-		}
+		    ip6h->nexthdr == NEXTHDR_ICMP &&
+		    ndmh->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
+			i6addr = &ndmh->target;
+		else
+			i6addr = use_dest ? &ip6h->daddr : &ip6h->saddr;
+
+		addr = ipvlan_ht_addr_lookup(port, i6addr, true);
 		break;
 	}
 	default:
 		return NULL;
 	}
 
-	return lyr3h;
+	return addr;
+}
+
+static inline struct ipvl_addr *ipvlan_get_slave_addr_dst(struct sk_buff *skb,
+							 struct ipvl_port *port)
+{
+	return ipvlan_get_slave_addr(skb, port, true);
 }
 
 unsigned int ipvlan_mac_hash(const unsigned char *addr)
@@ -312,57 +330,6 @@ static int ipvlan_rcv_int_frame(struct ipvl_addr *addr, struct sk_buff **pskb)
 	return RX_HANDLER_CONSUMED;
 }
 
-static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
-					    void *lyr3h, int addr_type,
-					    bool use_dest)
-{
-	struct ipvl_addr *addr = NULL;
-
-	if (addr_type == IPVL_IPV6) {
-		struct ipv6hdr *ip6h;
-		struct in6_addr *i6addr;
-
-		ip6h = (struct ipv6hdr *)lyr3h;
-		i6addr = use_dest ? &ip6h->daddr : &ip6h->saddr;
-		addr = ipvlan_ht_addr_lookup(port, i6addr, true);
-	} else if (addr_type == IPVL_ICMPV6) {
-		struct nd_msg *ndmh;
-		struct in6_addr *i6addr;
-
-		/* Make sure that the NeighborSolicitation ICMPv6 packets
-		 * are handled to avoid DAD issue.
-		 */
-		ndmh = (struct nd_msg *)lyr3h;
-		if (ndmh->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION) {
-			i6addr = &ndmh->target;
-			addr = ipvlan_ht_addr_lookup(port, i6addr, true);
-		}
-	} else if (addr_type == IPVL_IPV4) {
-		struct iphdr *ip4h;
-		__be32 *i4addr;
-
-		ip4h = (struct iphdr *)lyr3h;
-		i4addr = use_dest ? &ip4h->daddr : &ip4h->saddr;
-		addr = ipvlan_ht_addr_lookup(port, i4addr, false);
-	} else if (addr_type == IPVL_ARP) {
-		struct arphdr *arph;
-		unsigned char *arp_ptr;
-		__be32 dip;
-
-		arph = (struct arphdr *)lyr3h;
-		arp_ptr = (unsigned char *)(arph + 1);
-		if (use_dest)
-			arp_ptr += (2 * port->dev->addr_len) + 4;
-		else
-			arp_ptr += port->dev->addr_len;
-
-		memcpy(&dip, arp_ptr, 4);
-		addr = ipvlan_ht_addr_lookup(port, &dip, false);
-	}
-
-	return addr;
-}
-
 static int ipvlan_process_v4_outbound(struct sk_buff *skb)
 {
 	const struct iphdr *ip4h = ip_hdr(skb);
@@ -505,19 +472,12 @@ static void ipvlan_multicast_enqueue(struct ipvl_port *port,
 static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
-	void *lyr3h;
 	struct ipvl_addr *addr;
-	int addr_type;
 
-	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-	if (!lyr3h)
-		goto out;
-
-	addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
+	addr = ipvlan_get_slave_addr_dst(skb, ipvlan->port);
 	if (addr)
 		return ipvlan_rcv_int_frame(addr, &skb);
 
-out:
 	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
 	return ipvlan_process_outbound(skb);
 }
@@ -527,17 +487,12 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct ethhdr *eth = eth_hdr(skb);
 	struct ipvl_addr *addr;
-	void *lyr3h;
-	int addr_type;
 
 	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
-		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-		if (lyr3h) {
-			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h,
-						  addr_type, true);
-			if (addr)
-				return ipvlan_rcv_int_frame(addr, &skb);
-		}
+		addr = ipvlan_get_slave_addr_dst(skb, ipvlan->port);
+		if (addr)
+			return ipvlan_rcv_int_frame(addr, &skb);
+
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (!skb)
 			return NET_XMIT_DROP;
@@ -586,24 +541,10 @@ int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NET_XMIT_DROP;
 }
 
-static bool ipvlan_external_frame(struct sk_buff *skb, struct ipvl_port *port)
+static inline bool ipvlan_external_frame(struct sk_buff *skb,
+					 struct ipvl_port *port)
 {
-	struct ethhdr *eth = eth_hdr(skb);
-	struct ipvl_addr *addr;
-	void *lyr3h;
-	int addr_type;
-
-	if (ether_addr_equal(eth->h_source, skb->dev->dev_addr)) {
-		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-		if (!lyr3h)
-			return true;
-
-		addr = ipvlan_addr_lookup(port, lyr3h, addr_type, false);
-		if (addr)
-			return false;
-	}
-
-	return true;
+	return !ipvlan_get_slave_addr(skb, port, false);
 }
 
 static int ipvlan_rcv_ext_frame(struct ipvl_addr *addr, struct sk_buff *skb)
@@ -621,22 +562,14 @@ static int ipvlan_rcv_ext_frame(struct ipvl_addr *addr, struct sk_buff *skb)
 static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb,
 						 struct ipvl_port *port)
 {
-	void *lyr3h;
-	int addr_type;
 	struct ipvl_addr *addr;
 	struct sk_buff *skb = *pskb;
-	rx_handler_result_t ret = RX_HANDLER_PASS;
 
-	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-	if (!lyr3h)
-		goto out;
-
-	addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
+	addr = ipvlan_get_slave_addr_dst(skb, port);
 	if (addr)
-		ret = ipvlan_rcv_ext_frame(addr, skb);
+		return ipvlan_rcv_ext_frame(addr, skb);
 
-out:
-	return ret;
+	return RX_HANDLER_PASS;
 }
 
 static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
@@ -644,9 +577,6 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 {
 	struct sk_buff *skb = *pskb;
 	struct ethhdr *eth = eth_hdr(skb);
-	rx_handler_result_t ret = RX_HANDLER_PASS;
-	void *lyr3h;
-	int addr_type;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
 		if (ipvlan_external_frame(skb, port)) {
@@ -666,16 +596,12 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 	} else {
 		struct ipvl_addr *addr;
 
-		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-		if (!lyr3h)
-			return ret;
-
-		addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
+		addr = ipvlan_get_slave_addr_dst(skb, port);
 		if (addr)
-			ret = ipvlan_rcv_ext_frame(addr, skb);
+			return ipvlan_rcv_ext_frame(addr, skb);
 	}
 
-	return ret;
+	return RX_HANDLER_PASS;
 }
 
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
@@ -705,25 +631,16 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
 static struct ipvl_addr *ipvlan_skb_to_addr(struct sk_buff *skb,
 					    struct net_device *dev)
 {
-	struct ipvl_addr *addr = NULL;
 	struct ipvl_port *port;
-	void *lyr3h;
-	int addr_type;
 
 	if (!dev || !netif_is_ipvlan_port(dev))
-		goto out;
+		return NULL;
 
 	port = ipvlan_port_get_rcu(dev);
 	if (!port || port->mode != IPVLAN_MODE_L3S)
-		goto out;
-
-	lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
-	if (!lyr3h)
-		goto out;
+		return NULL;
 
-	addr = ipvlan_addr_lookup(port, lyr3h, addr_type, true);
-out:
-	return addr;
+	return ipvlan_get_slave_addr_dst(skb, port);
 }
 
 struct sk_buff *ipvlan_l3_rcv(struct net_device *dev, struct sk_buff *skb,
-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.
