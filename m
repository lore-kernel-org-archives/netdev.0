From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 5/8] vxlan: allow configuring port range
Date: Tue, 09 Oct 2012 23:35:50 -0700
Message-ID: <20121010063623.694192145@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52292 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956Ab2JJGjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:23 -0400
Content-Disposition: inline; filename=vxlan-port-range.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN bases source UDP port based on flow to help the
receiver to be able to load balance based on outer header flow.

This patch restricts the port range to the normal UDP local
ports, and allows overriding via configuration.

It also uses jhash of Ethernet header when looking at flows
with out know L3 header.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - min/max are non-inclusive so allow min == max

 drivers/net/vxlan.c     |   62 ++++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_link.h |    6 ++++
 2 files changed, 63 insertions(+), 5 deletions(-)

--- a/drivers/net/vxlan.c	2012-10-09 18:08:34.066441861 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 18:08:35.086431755 -0700
@@ -106,6 +106,8 @@ struct vxlan_dev {
 	__be32	          gaddr;	/* multicast group */
 	__be32		  saddr;	/* source address */
 	unsigned int      link;		/* link to multicast over */
+	__u16		  port_min;	/* source port range */
+	__u16		  port_max;
 	__u8		  tos;		/* TOS override */
 	__u8		  ttl;
 	bool		  learn;
@@ -654,12 +656,29 @@ static void vxlan_set_owner(struct net_d
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
@@ -671,8 +690,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	struct udphdr *uh;
 	struct flowi4 fl4;
 	unsigned int pkt_len = skb->len;
-	u32 hash;
 	__be32 dst;
+	__u16 src_port;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
@@ -695,7 +714,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	if (tos == 1)
 		tos = vxlan_get_dsfield(old_iph, skb);
 
-	hash = skb_get_rxhash(skb);
+	src_port = vxlan_src_port(vxlan, skb);
 
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_oif = vxlan->link;
@@ -732,7 +751,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	uh = udp_hdr(skb);
 
 	uh->dest = htons(vxlan_port);
-	uh->source = hash ? :random32();
+	uh->source = htons(src_port);
 
 	uh->len = htons(skb->len);
 	uh->check = 0;
@@ -960,6 +979,7 @@ static void vxlan_setup(struct net_devic
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned h;
+	int low, high;
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
@@ -979,6 +999,10 @@ static void vxlan_setup(struct net_devic
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
+	inet_get_local_port_range(&low, &high);
+	vxlan->port_min = low;
+	vxlan->port_max = high;
+
 	vxlan->dev = dev;
 
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
@@ -995,6 +1019,7 @@ static const struct nla_policy vxlan_pol
 	[IFLA_VXLAN_LEARNING]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_AGEING]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LIMIT]	= { .type = NLA_U32 },
+	[IFLA_VXLAN_PORT_RANGE] = { .len  = sizeof(struct ifla_vxlan_port_range) },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1027,6 +1052,18 @@ static int vxlan_validate(struct nlattr
 			return -EADDRNOTAVAIL;
 		}
 	}
+
+	if (data[IFLA_VXLAN_PORT_RANGE]) {
+		const struct ifla_vxlan_port_range *p
+			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
+
+		if (ntohs(p->high) < ntohs(p->low)) {
+			pr_debug("port range %u .. %u not valid\n",
+				 ntohs(p->low), ntohs(p->high));
+			return -EINVAL;
+		}
+	}
+
 	return 0;
 }
 
@@ -1077,6 +1114,13 @@ static int vxlan_newlink(struct net *net
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
@@ -1105,12 +1149,17 @@ static size_t vxlan_get_size(const struc
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
@@ -1131,6 +1180,9 @@ static int vxlan_fill_info(struct sk_buf
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax))
 		goto nla_put_failure;
 
+	if (nla_put(skb, IFLA_VXLAN_PORT_RANGE, sizeof(ports), &ports))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
--- a/include/linux/if_link.h	2012-10-09 18:08:22.126560329 -0700
+++ b/include/linux/if_link.h	2012-10-09 18:08:35.086431755 -0700
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
