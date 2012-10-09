From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] VXLAN bases source UDP port based on flow to help the receiver to be able to load balance based on outer header flow.
Date: Tue, 09 Oct 2012 10:56:41 -0700
Message-ID: <20121009175714.682992341@vyatta.com>
References: <20121009175637.048993312@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:51694 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab2JISB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:01:28 -0400
Content-Disposition: inline; filename=vxlan-port-range.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch restricts the port range to the normal UDP local
ports, and allows overriding via configruation.

It also uses jhash of Ethernet header when looking at flows
with out know L3 header.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/vxlan.c     |   62 ++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_link.h |    6 ++++
 2 files changed, 63 insertions(+), 5 deletions(-)

--- a/drivers/net/vxlan.c	2012-10-09 10:49:05.318792637 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 10:49:08.238763697 -0700
@@ -106,6 +106,8 @@ struct vxlan_dev {
 	__be32	          gaddr;	/* multicast group */
 	__be32		  saddr;	/* source address */
 	unsigned int      link;		/* link to multicast over */
+	__u16		  port_min;	/* source port range */
+	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
 	__u8		  ttl;
 	bool		  learn;
@@ -650,12 +652,29 @@ static void vxlan_set_owner(struct net_d
 	skb->destructor = vxlan_sock_free;
 }
 
+/* Compute source port for outgoing packet
+ *   first choice to use L4 flow hash since it will spread
+ *     better and maybe available from hardware
+ *   secondary choice is to use jhash on the Ethernet header
+ */
+static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
+{
+	unsigned int range = (vxlan->port_max - vxlan->port_min) + 1;
+	u32 hash;
+
+	hash = skb_get_rxhash(skb);
+	if (!hash)
+		hash = jhash(skb->data, 2 * ETH_ALEN,
+			     (__force u32) skb->protocol);
+
+	return (((u64) hash * range) >> 32) + vxlan->port_min;
+}
+
 /* Transmit local packets over Vxlan
  *
  * Outer IP header inherits ECN and DF from inner header.
  * Outer UDP destination is the VXLAN assigned port.
- *           source port is based on hash of flow if available
- *                       otherwise use a random value
+ *           source port is based on hash of flow
  */
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -667,8 +686,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	struct udphdr *uh;
 	struct flowi4 fl4;
 	unsigned int pkt_len = skb->len;
-	u32 hash;
 	__be32 dst;
+	__u16 src_port;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
@@ -691,7 +710,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	if (tos == 1)
 		tos = vxlan_get_dsfield(old_iph, skb);
 
-	hash = skb_get_rxhash(skb);
+	src_port = vxlan_src_port(vxlan, skb);
 
 	fl4.flowi4_oif = vxlan->link;
 	fl4.flowi4_tos = RT_TOS(tos);
@@ -726,7 +745,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	uh = udp_hdr(skb);
 
 	uh->dest = htons(vxlan_port);
-	uh->source = hash ? :random32();
+	uh->source = htons(src_port);
 
 	uh->len = htons(skb->len);
 	uh->check = 0;
@@ -954,6 +973,7 @@ static void vxlan_setup(struct net_devic
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned h;
+	int low, high;
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
@@ -973,6 +993,10 @@ static void vxlan_setup(struct net_devic
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
+	inet_get_local_port_range(&low, &high);
+	vxlan->port_min = low;
+	vxlan->port_max = high;
+
 	vxlan->dev = dev;
 
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
@@ -989,6 +1013,7 @@ static const struct nla_policy vxlan_pol
 	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_AGEING]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LIMIT]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_PORT_RANGE] = { .len  = sizeof(struct ifla_vxlan_port_range) },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1021,6 +1046,18 @@ static int vxlan_validate(struct nlattr
 			return -EADDRNOTAVAIL;
 		}
 	}
+
+	if (data[IFLA_VXLAN_PORT_RANGE]) {
+		const struct ifla_vxlan_port_range *p
+			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
+
+		if ((int)(ntohs(p->high) - ntohs(p->low)) < 1) {
+			pr_debug("port range %u .. %u not valid\n",
+				 ntohs(p->low), ntohs(p->high));
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
@@ -1071,6 +1108,13 @@ static int vxlan_newlink(struct net *net
 	if (data[IFLA_VXLAN_LIMIT])
 		vxlan->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
+	if (data[IFLA_VXLAN_PORT_RANGE]) {
+		const struct ifla_vxlan_port_range *p
+			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
+		vxlan->port_min = ntohs(p->low);
+		vxlan->port_max = ntohs(p->high);
+	}
+
 	err = register_netdevice(dev);
 	if (!err)
 		hlist_add_head_rcu(&vxlan->hlist, vni_head(net, vxlan->vni));
@@ -1099,12 +1143,17 @@ static size_t vxlan_get_size(const struc
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
+		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
 		0;
 }
 
 static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
 	const struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct ifla_vxlan_port_range ports = {
+		.low =  htons(vxlan->port_min),
+		.high = htons(vxlan->port_max),
+	};
 
 	if (nla_put_u32(skb, IFLA_VXLAN_ID, vxlan->vni))
 		goto nla_put_failure;
@@ -1125,6 +1174,9 @@ static int vxlan_fill_info(struct sk_buf
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax))
 		goto nla_put_failure;
 
+	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
--- a/include/linux/if_link.h	2012-10-09 10:35:01.403159162 -0700
+++ b/include/linux/if_link.h	2012-10-09 10:49:08.238763697 -0700
@@ -284,10 +284,16 @@ enum {
 	IFLA_VXLAN_LEARNING,
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
+	IFLA_VXLAN_PORT_RANGE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+struct ifla_vxlan_port_range {
+	__be16	low;
+	__be16	high;
+};
+
 /* SR-IOV virtual function management section */
 
 enum {
