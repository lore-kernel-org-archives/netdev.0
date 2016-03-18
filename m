From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 8/9] i40e/i40evf: Add support for GSO partial with
 UDP_TUNNEL_CSUM and GRE_CSUM
Date: Fri, 18 Mar 2016 16:25:29 -0700
Message-ID: <20160318232528.14955.87859.stgit@localhost.localdomain>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35634 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786AbcCRXZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:25:30 -0400
Received: by mail-pf0-f172.google.com with SMTP id n5so186151657pfn.2
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:25:30 -0700 (PDT)
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes it so that i40e and i40evf can use GSO_PARTIAL to support
segmentation for frames with checksums enabled in outer headers.  As a
result we can now send data over these types of tunnels at over 20Gb/s
versus the 12Gb/s that was previously possible on my system.

The advantage with the i40e parts is that this offload is mostly
transparent as the hardware still deals with the inner and/or outer IPv4
headers so the IP ID is still incrementing for both when this offload is
performed.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |    8 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |   14 +++++++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |   14 +++++++++++---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |    8 +++++++-
 4 files changed, 36 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 39b0009253c2..ac3964a9f5c0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9050,6 +9050,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 				   NETIF_F_TSO6		       |
 				   NETIF_F_TSO_ECN	       |
 				   NETIF_F_GSO_GRE	       |
+				   NETIF_F_GSO_GRE_CSUM	       |
 				   NETIF_F_GSO_UDP_TUNNEL      |
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM |
 				   0;
@@ -9074,7 +9075,12 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
 		netdev->features |= NETIF_F_NTUPLE;
 	if (pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE)
-		netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+		netdev->features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
+	else
+		netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
+	netdev->features |= NETIF_F_GSO_PARTIAL | netdev->gso_partial_features;
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5d5fa5359a1d..50aa76d7f92e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2297,9 +2297,16 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_GRE_CSUM |
+					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+		if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL |
+						 SKB_GSO_UDP_TUNNEL_CSUM))
+			l4.udp->len = 0;
+
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)) {
 			/* determine offset of outer transport header */
 			l4_offset = l4.hdr - skb->data;
 
@@ -2470,7 +2477,8 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 
 		/* indicate if we need to offload outer UDP header */
 		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
-		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL))
 			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
 
 		/* record tunnel offload values */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04aabc52ba0d..1bb7c3efa36c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1564,9 +1564,16 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		ip.v6->payload_len = 0;
 	}
 
-	if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE |
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_GRE_CSUM |
+					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+		if (skb_shinfo(skb)->gso_type & (SKB_GSO_UDP_TUNNEL |
+						 SKB_GSO_UDP_TUNNEL_CSUM))
+			l4.udp->len = 0;
+
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)) {
 			/* determine offset of outer transport header */
 			l4_offset = l4.hdr - skb->data;
 
@@ -1695,7 +1702,8 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 
 		/* indicate if we need to offload outer UDP header */
 		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
-		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL))
 			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
 
 		/* record tunnel offload values */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index e3973684746b..ed3c9310c3e0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2331,7 +2331,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 			    NETIF_F_TSO |
 			    NETIF_F_TSO6 |
 			    NETIF_F_TSO_ECN |
-			    NETIF_F_GSO_GRE	       |
+			    NETIF_F_GSO_GRE |
 			    NETIF_F_GSO_UDP_TUNNEL |
 			    NETIF_F_RXCSUM |
 			    NETIF_F_GRO;
@@ -2342,11 +2342,17 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				   NETIF_F_TSO6		       |
 				   NETIF_F_TSO_ECN	       |
 				   NETIF_F_GSO_GRE	       |
+				   NETIF_F_GSO_GRE_CSUM	       |
 				   NETIF_F_GSO_UDP_TUNNEL      |
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM;
 
 	if (adapter->flags & I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE)
 		netdev->features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+	else
+		netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
+	netdev->features |= NETIF_F_GSO_PARTIAL | netdev->gso_partial_features;
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
