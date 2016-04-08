From: Alexander Duyck <aduyck@mirantis.com>
Subject: [next-queue PATCH 1/3] i40e/i40evf: Add support for GSO partial
 with UDP_TUNNEL_CSUM and GRE_CSUM
Date: Fri, 08 Apr 2016 17:06:41 -0400
Message-ID: <20160408210641.13096.8972.stgit@ahduyck-xeon-server>
References: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35058 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758423AbcDHVGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 17:06:50 -0400
Received: by mail-pf0-f170.google.com with SMTP id n1so82524029pfn.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 14:06:50 -0700 (PDT)
In-Reply-To: <20160408210103.13096.77973.stgit@ahduyck-xeon-server>
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
 drivers/net/ethernet/intel/i40e/i40e_main.c     |   10 ++++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     |    7 ++++++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c   |    7 ++++++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   10 ++++++++--
 4 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 07a70c4ac49f..6342fab4d177 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9119,20 +9119,25 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 				   NETIF_F_TSO_ECN		|
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
+				   NETIF_F_GSO_GRE_CSUM		|
 				   NETIF_F_GSO_IPIP		|
 				   NETIF_F_GSO_SIT		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
+				   NETIF_F_GSO_PARTIAL		|
 				   NETIF_F_SCTP_CRC		|
 				   NETIF_F_RXHASH		|
 				   NETIF_F_RXCSUM		|
 				   0;
 
 	if (!(pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE))
-		netdev->hw_enc_features ^= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+		netdev->gso_partial_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
 
 	/* record features VLANs can make use of */
-	netdev->vlan_features |= netdev->hw_enc_features;
+	netdev->vlan_features |= netdev->hw_enc_features |
+				 NETIF_F_TSO_MANGLEID;
 
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
 		netdev->hw_features |= NETIF_F_NTUPLE;
@@ -9142,6 +9147,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			       NETIF_F_HW_VLAN_CTAG_RX;
 
 	netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
+	netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
 
 	if (vsi->type == I40E_VSI_MAIN) {
 		SET_NETDEV_DEV(netdev, &pf->pdev->dev);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6e44cf118843..ede4183468b9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2300,11 +2300,15 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 	}
 
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_GRE_CSUM |
 					 SKB_GSO_IPIP |
 					 SKB_GSO_SIT |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)) {
+			l4.udp->len = 0;
+
 			/* determine offset of outer transport header */
 			l4_offset = l4.hdr - skb->data;
 
@@ -2481,6 +2485,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 
 		/* indicate if we need to offload outer UDP header */
 		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
 		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
 			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index f101895ecf4a..6ce00547c13e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1565,11 +1565,15 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 	}
 
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
+					 SKB_GSO_GRE_CSUM |
 					 SKB_GSO_IPIP |
 					 SKB_GSO_SIT |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM) {
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
+		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM)) {
+			l4.udp->len = 0;
+
 			/* determine offset of outer transport header */
 			l4_offset = l4.hdr - skb->data;
 
@@ -1704,6 +1708,7 @@ static int i40e_tx_enable_csum(struct sk_buff *skb, u32 *tx_flags,
 
 		/* indicate if we need to offload outer UDP header */
 		if ((*tx_flags & I40E_TX_FLAGS_TSO) &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
 		    (skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL_CSUM))
 			tunnel |= I40E_TXD_CTX_QW0_L4T_CS_MASK;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 806da2686623..42be838ce77e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2346,20 +2346,25 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				   NETIF_F_TSO_ECN		|
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
+				   NETIF_F_GSO_GRE_CSUM		|
 				   NETIF_F_GSO_IPIP		|
 				   NETIF_F_GSO_SIT		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
+				   NETIF_F_GSO_PARTIAL		|
 				   NETIF_F_SCTP_CRC		|
 				   NETIF_F_RXHASH		|
 				   NETIF_F_RXCSUM		|
 				   0;
 
 	if (!(adapter->flags & I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE))
-		netdev->hw_enc_features ^= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+		netdev->gso_partial_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
+
+	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
 
 	/* record features VLANs can make use of */
-	netdev->vlan_features |= netdev->hw_enc_features;
+	netdev->vlan_features |= netdev->hw_enc_features |
+				 NETIF_F_TSO_MANGLEID;
 
 	/* Write features and hw_features separately to avoid polluting
 	 * with, or dropping, features that are set when we registgered.
@@ -2367,6 +2372,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	netdev->hw_features |= netdev->hw_enc_features;
 
 	netdev->features |= netdev->hw_enc_features | I40EVF_VLAN_FEATURES;
+	netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
 
 	/* disable VLAN features if not supported */
 	if (!(vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_VLAN))
