From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 11/13] ixgbe: fix bug where lro settings are per ring
Date: Tue, 26 Aug 2008 04:27:24 -0700
Message-ID: <20080826112724.15787.76769.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:39276 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899AbYHZL1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:25 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099820rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:25 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f37e3eb..6b96c41 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1428,8 +1428,8 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 	union ixgbe_adv_rx_desc *rx_desc = priv;
 
 	/* Verify that this is a valid IPv4 TCP packet */
-	if (!(ixgbe_get_pkt_info(rx_desc) &
-	    (IXGBE_RXDADV_PKTTYPE_IPV4 | IXGBE_RXDADV_PKTTYPE_TCP)))
+	if (!((ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_IPV4) &&
+	     (ixgbe_get_pkt_info(rx_desc) & IXGBE_RXDADV_PKTTYPE_TCP)))
 		return -1;
 
 	/* Set network headers */
@@ -1532,18 +1532,18 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].head = IXGBE_RDH(j);
 		adapter->rx_ring[i].tail = IXGBE_RDT(j);
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+		/* Intitial LRO Settings */
+		adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
+		adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
+		adapter->rx_ring[i].lro_mgr.get_skb_header = ixgbe_get_skb_hdr;
+		adapter->rx_ring[i].lro_mgr.features = LRO_F_EXTRACT_VLAN_ID;
+		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+			adapter->rx_ring[i].lro_mgr.features |= LRO_F_NAPI;
+		adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
+		adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
+		adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 	}
 
-	/* Intitial LRO Settings */
-	adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
-	adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
-	adapter->rx_ring[i].lro_mgr.get_skb_header = ixgbe_get_skb_hdr;
-	adapter->rx_ring[i].lro_mgr.features = LRO_F_EXTRACT_VLAN_ID;
-	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		adapter->rx_ring[i].lro_mgr.features |= LRO_F_NAPI;
-	adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
-	adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
-	adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
@@ -3618,9 +3618,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 
-	netdev->features |= NETIF_F_LRO;
+	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+	netdev->features |= NETIF_F_LRO;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;

