From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix vlan tso/checksum offload
Date: Sat, 24 Jan 2009 20:02:58 -0800
Message-ID: <1232856179-15153-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:52640 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756684AbZAYEDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jan 2009 23:03:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o set netdev->vlan_features appropriately.
o fix tso descriptor initialization for vlan case.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index d854f07..645d384 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -735,17 +735,18 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
 
-	/* ScatterGather support */
-	netdev->features = NETIF_F_SG;
-	netdev->features |= NETIF_F_IP_CSUM;
-	netdev->features |= NETIF_F_TSO;
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+
 	if (NX_IS_REVISION_P3(revision_id)) {
-		netdev->features |= NETIF_F_IPV6_CSUM;
-		netdev->features |= NETIF_F_TSO6;
+		netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 	}
 
-	if (adapter->pci_using_dac)
+	if (adapter->pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	/*
 	 * Set the CRB window to invalid. If any register in window 0 is
@@ -1166,6 +1167,14 @@ static bool netxen_tso_check(struct net_device *netdev,
 {
 	bool tso = false;
 	u8 opcode = TX_ETHER_PKT;
+	__be16 protocol = skb->protocol;
+	u16 flags = 0;
+
+	if (protocol == __constant_htons(ETH_P_8021Q)) {
+		struct vlan_ethhdr *vh = (struct vlan_ethhdr *)skb->data;
+		protocol = vh->h_vlan_encapsulated_proto;
+		flags = FLAGS_VLAN_TAGGED;
+	}
 
 	if ((netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
 			skb_shinfo(skb)->gso_size > 0) {
@@ -1174,21 +1183,21 @@ static bool netxen_tso_check(struct net_device *netdev,
 		desc->total_hdr_length =
 			skb_transport_offset(skb) + tcp_hdrlen(skb);
 
-		opcode = (skb->protocol == htons(ETH_P_IPV6)) ?
+		opcode = (protocol == __constant_htons(ETH_P_IPV6)) ?
 				TX_TCP_LSO6 : TX_TCP_LSO;
 		tso = true;
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		u8 l4proto;
 
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (protocol == __constant_htons(ETH_P_IP)) {
 			l4proto = ip_hdr(skb)->protocol;
 
 			if (l4proto == IPPROTO_TCP)
 				opcode = TX_TCP_PKT;
 			else if(l4proto == IPPROTO_UDP)
 				opcode = TX_UDP_PKT;
-		} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		} else if (protocol == __constant_htons(ETH_P_IPV6)) {
 			l4proto = ipv6_hdr(skb)->nexthdr;
 
 			if (l4proto == IPPROTO_TCP)
@@ -1199,7 +1208,7 @@ static bool netxen_tso_check(struct net_device *netdev,
 	}
 	desc->tcp_hdr_offset = skb_transport_offset(skb);
 	desc->ip_hdr_offset = skb_network_offset(skb);
-	netxen_set_tx_flags_opcode(desc, 0, opcode);
+	netxen_set_tx_flags_opcode(desc, flags, opcode);
 	return tso;
 }
 
-- 
1.6.0.2

