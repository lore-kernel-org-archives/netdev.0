From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 9/9] ipvlan: introduce individual MAC addresses
Date: Thu, 27 Apr 2017 15:51:42 +0100
Message-ID: <20170427145142.15830-10-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:49079 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937357AbdD0Oww (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:52 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently all the slave devices belonging to the same port inherit their
MAC address from its master device. This patch removes this limitation
and allows every slave device to obtain a unique MAC address, by default
randomly generated at creation time.

Moreover it is now possible to correctly modify the MAC address at any
time, fixing an existing bug as MAC address changes on the master were
not reflected on the slaves. It also avoids multiple interfaces sharing
the same IPv6 link-local address.

Since ipvlan is designed to expose a single MAC address for external
communications, the driver now behaves as follow:
- L2 mode:
   * Any reference to the internal MAC address of the originating slave
     is replaced with the MAC address of the master for outbound frames.
   * Likewise, the destination MAC address is overwritten with the
     internal one (once the correct slave is determined) for any
     incoming external frame.
   * For any internal slave-to-slave communication, the original MAC
     addresses are preserved (although not used for routing/switching).
- L3/L3s mode:
   * The destination MAC address for incoming external packets is
     replaced with the one belonging to the destination slave device
     (as for L2 mode)
   * Every other path behaves as before.

Being a significant behavioral change, version number has been
increased.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
Tested-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan.h      |   2 +-
 drivers/net/ipvlan/ipvlan_core.c | 113 ++++++++++++++++++++++++++++++++++-----
 drivers/net/ipvlan/ipvlan_main.c |  18 +++----
 3 files changed, 111 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 800a46c..efe4fd1 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -32,7 +32,7 @@
 #include <net/l3mdev.h>
 
 #define IPVLAN_DRV	"ipvlan"
-#define IPV_DRV_VER	"0.1"
+#define IPV_DRV_VER	"0.2"
 
 #define IPVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 #define IPVLAN_HASH_MASK	(IPVLAN_HASH_SIZE - 1)
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 67e342d..a30bc11 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -215,6 +215,89 @@ static void ipvlan_skb_crossing_ns(struct sk_buff *skb, struct net_device *dev)
 		skb->dev = dev;
 }
 
+static inline struct nd_opt_hdr *ipvlan_icmp6_nd_opts(struct icmp6hdr *icmph)
+{
+	return (struct nd_opt_hdr *)((struct nd_msg *)icmph)->opt;
+}
+
+static inline struct nd_opt_hdr *ipvlan_icmp6_rs_opts(struct icmp6hdr *icmph)
+{
+	return (struct nd_opt_hdr *)((struct rs_msg *)icmph)->opt;
+}
+
+static void ipvlan_proxy_l2_update_icmp6(const struct net_device *master,
+					 struct sk_buff *skb,
+					 struct nd_opt_hdr *nd_opt,
+					 u8 opt_type)
+{
+	u32 opts_len = skb_tail_pointer(skb) - (u8 *)nd_opt;
+
+	while (opts_len) {
+		u32 opt_len = nd_opt->nd_opt_len << 3;
+
+		if (nd_opt->nd_opt_type == opt_type) {
+			struct ipv6hdr *ip6h = ipv6_hdr(skb);
+			struct icmp6hdr *icmph = icmp6_hdr(skb);
+			u32 len = ntohs(ip6h->payload_len);
+
+			memcpy(nd_opt + 1, master->dev_addr, master->addr_len);
+			icmph->icmp6_cksum = 0;
+			icmph->icmp6_cksum =
+				csum_ipv6_magic(&ip6h->saddr,
+						&ip6h->daddr, len,
+						IPPROTO_ICMPV6,
+						csum_partial(icmph, len, 0));
+			return;
+		}
+
+		opts_len -= opt_len;
+		nd_opt = ((void *)nd_opt) + opt_len;
+	}
+}
+
+static void ipvlan_proxy_l2_outbound(struct sk_buff *skb,
+				     const struct net_device *master)
+{
+	/* masquerade the source MAC address for every outgoing frame */
+	memcpy(eth_hdr(skb)->h_source, master->dev_addr, master->addr_len);
+
+	/* ARP and some NDISC packets need additional treatment */
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct ipv6hdr *ip6h = ipv6_hdr(skb);
+		struct icmp6hdr *icmph = icmp6_hdr(skb);
+		struct nd_opt_hdr *nd_opt;
+		u8 opt_type;
+
+		if (likely(ip6h->nexthdr != NEXTHDR_ICMP))
+			return;
+
+		switch (icmph->icmp6_type) {
+		case NDISC_NEIGHBOUR_SOLICITATION: {
+			nd_opt = ipvlan_icmp6_nd_opts(icmph);
+			opt_type = ND_OPT_SOURCE_LL_ADDR;
+			break;
+		}
+		case NDISC_NEIGHBOUR_ADVERTISEMENT: {
+			nd_opt = ipvlan_icmp6_nd_opts(icmph);
+			opt_type = ND_OPT_TARGET_LL_ADDR;
+			break;
+		}
+		case NDISC_ROUTER_SOLICITATION: {
+			nd_opt = ipvlan_icmp6_rs_opts(icmph);
+			opt_type = ND_OPT_SOURCE_LL_ADDR;
+			break;
+		}
+		default:
+			return;
+		}
+
+		ipvlan_proxy_l2_update_icmp6(master, skb, nd_opt, opt_type);
+
+	} else if (unlikely(skb->protocol == htons(ETH_P_ARP))) {
+		memcpy(arp_hdr(skb) + 1, master->dev_addr, master->addr_len);
+	}
+}
+
 static void ipvlan_dispatch_multicast(struct ipvl_port *port,
 				      struct sk_buff *skb, u8 pkt_type,
 				      unsigned int mac_hash)
@@ -258,6 +341,7 @@ static void ipvlan_dispatch_multicast(struct ipvl_port *port,
 		/* If the packet originated here, send it out. */
 		skb->dev = port->dev;
 		skb->pkt_type = pkt_type;
+		ipvlan_proxy_l2_outbound(skb, port->dev);
 		dev_queue_xmit(skb);
 	} else {
 		if (consumed)
@@ -489,6 +573,7 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 static inline int ipvlan_process_l2_outbound(struct sk_buff *skb,
 					     struct net_device *dev)
 {
+	ipvlan_proxy_l2_outbound(skb, dev);
 	ipvlan_skb_crossing_ns(skb, dev);
 	return dev_queue_xmit(skb);
 }
@@ -499,27 +584,27 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 	struct ethhdr *ethh = eth_hdr(skb);
 	struct ipvl_addr *addr;
 
-	if (ether_addr_equal(ethh->h_dest, ethh->h_source)) {
-		addr = ipvlan_get_slave_addr_dst(skb, ipvlan->port);
-		if (addr)
-			return ipvlan_rcv_int_frame(addr, &skb);
+	if (is_multicast_ether_addr(ethh->h_dest)) {
+		ipvlan_multicast_enqueue(ipvlan->port, skb, true);
+		return NET_XMIT_SUCCESS;
+	}
 
+	if (ether_addr_equal(ethh->h_dest, ipvlan->phy_dev->dev_addr)) {
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (unlikely(!skb))
 			return NET_XMIT_DROP;
 
-		/* Packet definitely does not belong to any of the
-		 * virtual devices, but the dest is local. So forward
-		 * the skb for the main-dev. At the RX side we just return
-		 * RX_PASS for it to be processed further on the stack.
+		/* Forward the skb for the master device. At the RX side we
+		 * just return RX_HANDLER_PASS for it to be processed further
+		 * on the stack.
 		 */
 		return dev_forward_skb(ipvlan->phy_dev, skb);
-
-	} else if (is_multicast_ether_addr(ethh->h_dest)) {
-		ipvlan_multicast_enqueue(ipvlan->port, skb, true);
-		return NET_XMIT_SUCCESS;
 	}
 
+	addr = ipvlan_get_slave_addr_dst(skb, ipvlan->port);
+	if (addr)
+		return ipvlan_rcv_int_frame(addr, &skb);
+
 	return ipvlan_process_l2_outbound(skb, ipvlan->phy_dev);
 }
 
@@ -562,6 +647,10 @@ static int ipvlan_rcv_ext_frame(struct ipvl_addr *addr, struct sk_buff *skb)
 	struct net_device *dev = ipvlan->dev;
 	unsigned int len = skb->len + ETH_HLEN;
 
+	/* NOTE: although not necessary restore the actual destination
+	 * address; this is also what traffic sniffers will display.
+	 */
+	memcpy(eth_hdr(skb)->h_dest, dev->dev_addr, dev->addr_len);
 	ipvlan_skb_crossing_ns(skb, dev);
 	ipvlan_count_rx(ipvlan, len, true, false);
 
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index b837807..709f27d 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -378,6 +378,7 @@ static const struct net_device_ops ipvlan_netdev_ops = {
 	.ndo_start_xmit		= ipvlan_start_xmit,
 	.ndo_fix_features	= ipvlan_fix_features,
 	.ndo_change_rx_flags	= ipvlan_change_rx_flags,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_set_rx_mode	= ipvlan_set_multicast_mac_filter,
 	.ndo_get_stats64	= ipvlan_get_stats64,
 	.ndo_vlan_rx_add_vid	= ipvlan_vlan_rx_add_vid,
@@ -392,9 +393,10 @@ static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *dev,
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct net_device *phy_dev = ipvlan->phy_dev;
 
-	/* TODO Probably use a different field than dev_addr so that the
-	 * mac-address on the virtual device is portable and can be carried
-	 * while the packets use the mac-addr on the physical device.
+	/* This driver uses (almost exclusively) L3 addresses for
+	 * routing/switching. Use the actual slave's MAC address,
+	 * but overwrite it later during the packet processing for
+	 * frames leaving from master
 	 */
 	return dev_hard_header(skb, phy_dev, type, daddr,
 			       saddr ? : dev->dev_addr, len);
@@ -559,11 +561,8 @@ int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	/* Increment id-base to the next slot for the future assignment */
 	port->dev_id_start = err + 1;
 
-	/* TODO Probably put random address here to be presented to the
-	 * world but keep using the physical-dev address for the outgoing
-	 * packets.
-	 */
-	memcpy(dev->dev_addr, phy_dev->dev_addr, ETH_ALEN);
+	/* TODO: consider storing the original MAC address in dev->perm_addr */
+	eth_hw_addr_random(dev);
 
 	dev->priv_flags |= IFF_IPVLAN_SLAVE;
 
@@ -619,7 +618,8 @@ void ipvlan_link_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
-	dev->priv_flags |= IFF_UNICAST_FLT | IFF_NO_QUEUE;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_NO_QUEUE
+			   | IFF_LIVE_ADDR_CHANGE;
 	dev->netdev_ops = &ipvlan_netdev_ops;
 	dev->destructor = free_netdev;
 	dev->header_ops = &ipvlan_header_ops;
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
