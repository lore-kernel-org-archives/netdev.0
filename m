From: Chen Haiquan <oc@yunify.com>
Subject: [PATCH v2] vxlan: only reduce known arp broadcast request to support
 virtual IP
Date: Thu, 14 Sep 2017 23:14:40 +0800
Message-ID: <20170914151440.GA30675@samsung>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, oc@yunify.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [139.198.2.84] ([139.198.2.84]:40710 "EHLO yunify.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751473AbdINPOo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 11:14:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The purpose of vxlan arp reduce feature is to reply the broadcast
arp request in vtep instead of sending it out to save traffic.
The current implementation drops arp packet, if the ip cannot be
found in neigh table. In the case of virtual IP address, user
defines IP address without management from SDN controller. The IP
address does not exist in neigh table, so the arp broadcast request
from a client can not be sent to the server who owns the virtual IP
address.

This patch allow the arp request to be sent out if:
1. not arp broadcast request
2. cannot be found in neigh table
3. arp record status is not NUD_CONNECTED

The user defined of virtual IP address works while arp reduce still
suppress the arp broadcast for IP address managed by SDN controller
with this patch.

Signed-off-by: Chen Haiquan <oc@yunify.com>
---
Changes in v2:
  - Add config option, arp_reduce_ignore_unknown_ip, to enable
the behavior.
---
 drivers/net/vxlan.c | 42 +++++++++++++++++++++++++++++++++++-------
 1 file changed, 35 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d7c49cf1d5e9..cc9ee28f3481 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -53,6 +53,11 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
+static bool arp_reduce_ignore_unknown_ip;
+module_param(arp_reduce_ignore_unknown_ip, bool, 0644);
+MODULE_PARM_DESC(arp_reduce_ignore_unknown_ip,
+		 "Only reduce known arp broaddcast request to support virtual IP");
+
 static unsigned int vxlan_net_id;
 static struct rtnl_link_ops vxlan_link_ops;
 
@@ -1473,7 +1478,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 	    parp->ar_op != htons(ARPOP_REQUEST) ||
 	    parp->ar_hln != dev->addr_len ||
 	    parp->ar_pln != 4)
-		goto out;
+		goto ignore;
 	arpptr = (u8 *)parp + sizeof(struct arphdr);
 	sha = arpptr;
 	arpptr += dev->addr_len;	/* sha */
@@ -1494,7 +1499,7 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
-			goto out;
+			goto ignore;
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha, vni);
@@ -1526,10 +1531,20 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 		};
 
 		vxlan_ip_miss(dev, &ipa);
+		goto ignore;
+	} else {
+		/* broadcast unknown arp */
+		goto ignore;
 	}
+
 out:
 	consume_skb(skb);
 	return NETDEV_TX_OK;
+
+ignore:
+	if (arp_reduce_ignore_unknown_ip)
+		return 1;
+	goto out;
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1642,7 +1657,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 	msg = (struct nd_msg *)(iphdr + 1);
 	if (msg->icmph.icmp6_code != 0 ||
 	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
-		goto out;
+		goto ignore;
 
 	if (ipv6_addr_loopback(daddr) ||
 	    ipv6_addr_is_multicast(&msg->target))
@@ -1656,7 +1671,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
-			goto out;
+			goto ignore;
 		}
 
 		f = vxlan_find_mac(vxlan, n->ha, vni);
@@ -1684,11 +1699,20 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 		};
 
 		vxlan_ip_miss(dev, &ipa);
+		goto ignore;
+	} else {
+		/* broadcast unknown neigh */
+		goto ignore;
 	}
 
 out:
 	consume_skb(skb);
 	return NETDEV_TX_OK;
+
+ignore:
+	if (arp_reduce_ignore_unknown_ip)
+		return 1;
+	goto out;
 }
 #endif
 
@@ -2266,8 +2290,10 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (vxlan->cfg.flags & VXLAN_F_PROXY) {
 		eth = eth_hdr(skb);
-		if (ntohs(eth->h_proto) == ETH_P_ARP)
-			return arp_reduce(dev, skb, vni);
+		if (ntohs(eth->h_proto) == ETH_P_ARP) {
+			if (arp_reduce(dev, skb, vni) == NETDEV_TX_OK)
+				return NETDEV_TX_OK;
+		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (ntohs(eth->h_proto) == ETH_P_IPV6) {
 			struct ipv6hdr *hdr, _hdr;
@@ -2275,7 +2301,9 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 						      skb_network_offset(skb),
 						      sizeof(_hdr), &_hdr)) &&
 			    hdr->nexthdr == IPPROTO_ICMPV6)
-				return neigh_reduce(dev, skb, vni);
+				if (neigh_reduce(dev,
+						 skb, vni) == NETDEV_TX_OK)
+					return NETDEV_TX_OK;
 		}
 #endif
 	}
-- 
2.7.4
