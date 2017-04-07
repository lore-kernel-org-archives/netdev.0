From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/4] i40e/i40evf: Add capability exchange for outer checksum
Date: Thu,  6 Apr 2017 20:23:22 -0700
Message-ID: <20170407032325.33374-2-jeffrey.t.kirsher@intel.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Alan Brady <alan.brady@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43971 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752115AbdDGDX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:23:29 -0400
In-Reply-To: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

This patch adds a capability negotiation between VF and PF using ENCAP/
ENCAP_CSUM offload flags in order for the VF to support outer checksum
and TSO offloads for encapsulated packets. These capabilities were assumed
by default and enabled in current hardware. Going forward, these features
needs to be negotiated with PF before advertising to the stack.
Additionally, strip out the mac.type checks for X722 since outer checksums
are enabled based on the ENCAP_CSUM offload negotiation flag and maintain
consistency between drivers in how the features are configured.

Change-ID: Ie380a6f57eca557a2bb575b66b12fae36d308920
Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Signed-off-by: Alan Brady <alan.brady@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 52 +++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  7 +++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 61 ++++++++++++----------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  4 +-
 6 files changed, 74 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 703444e92964..7147c67a939d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9253,6 +9253,8 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	u8 broadcast[ETH_ALEN];
 	u8 mac_addr[ETH_ALEN];
 	int etherdev_size;
+	netdev_features_t hw_enc_features;
+	netdev_features_t hw_features;
 
 	etherdev_size = sizeof(struct i40e_netdev_priv);
 	netdev = alloc_etherdev_mq(etherdev_size, vsi->alloc_queue_pairs);
@@ -9263,43 +9265,43 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	np = netdev_priv(netdev);
 	np->vsi = vsi;
 
-	netdev->hw_enc_features |= NETIF_F_SG			|
-				   NETIF_F_IP_CSUM		|
-				   NETIF_F_IPV6_CSUM		|
-				   NETIF_F_HIGHDMA		|
-				   NETIF_F_SOFT_FEATURES	|
-				   NETIF_F_TSO			|
-				   NETIF_F_TSO_ECN		|
-				   NETIF_F_TSO6			|
-				   NETIF_F_GSO_GRE		|
-				   NETIF_F_GSO_GRE_CSUM		|
-				   NETIF_F_GSO_IPXIP4		|
-				   NETIF_F_GSO_IPXIP6		|
-				   NETIF_F_GSO_UDP_TUNNEL	|
-				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
-				   NETIF_F_GSO_PARTIAL		|
-				   NETIF_F_SCTP_CRC		|
-				   NETIF_F_RXHASH		|
-				   NETIF_F_RXCSUM		|
-				   0;
+	hw_enc_features = NETIF_F_SG			|
+			  NETIF_F_IP_CSUM		|
+			  NETIF_F_IPV6_CSUM		|
+			  NETIF_F_HIGHDMA		|
+			  NETIF_F_SOFT_FEATURES		|
+			  NETIF_F_TSO			|
+			  NETIF_F_TSO_ECN		|
+			  NETIF_F_TSO6			|
+			  NETIF_F_GSO_GRE		|
+			  NETIF_F_GSO_GRE_CSUM		|
+			  NETIF_F_GSO_PARTIAL		|
+			  NETIF_F_GSO_UDP_TUNNEL	|
+			  NETIF_F_GSO_UDP_TUNNEL_CSUM	|
+			  NETIF_F_SCTP_CRC		|
+			  NETIF_F_RXHASH		|
+			  NETIF_F_RXCSUM		|
+			  0;
 
 	if (!(pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE))
 		netdev->gso_partial_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
 
 	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
 
+	netdev->hw_enc_features |= hw_enc_features;
+
 	/* record features VLANs can make use of */
-	netdev->vlan_features |= netdev->hw_enc_features |
-				 NETIF_F_TSO_MANGLEID;
+	netdev->vlan_features |= hw_enc_features | NETIF_F_TSO_MANGLEID;
 
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
 		netdev->hw_features |= NETIF_F_NTUPLE;
+	hw_features = hw_enc_features		|
+		      NETIF_F_HW_VLAN_CTAG_TX	|
+		      NETIF_F_HW_VLAN_CTAG_RX;
 
-	netdev->hw_features |= netdev->hw_enc_features	|
-			       NETIF_F_HW_VLAN_CTAG_TX	|
-			       NETIF_F_HW_VLAN_CTAG_RX;
+	netdev->hw_features |= hw_features;
 
-	netdev->features |= netdev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
+	netdev->features |= hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
 	netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
 
 	if (vsi->type == I40E_VSI_MAIN) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 974ba2baf6ea..8552192a5bde 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -163,7 +163,8 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
-#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP		0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00200000
 
 #define I40E_VF_BASE_MODE_OFFLOADS (I40E_VIRTCHNL_VF_OFFLOAD_L2 | \
 				    I40E_VIRTCHNL_VF_OFFLOAD_VLAN | \
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d526940ff951..65c95ffc15ec 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1408,6 +1408,13 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 				I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2;
 	}
 
+	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_ENCAP)
+		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_ENCAP;
+
+	if ((pf->flags & I40E_FLAG_OUTER_UDP_CSUM_CAPABLE) &&
+	    (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM))
+		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM;
+
 	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING) {
 		if (pf->flags & I40E_FLAG_MFP_ENABLED) {
 			dev_err(&pf->pdev->dev,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index f431fbc4a3e7..c5ad0388c3d5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -163,7 +163,8 @@ struct i40e_virtchnl_vsi_resource {
 #define I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING	0x00020000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2	0x00040000
 #define I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF		0X00080000
-#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP		0X00100000
+#define I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM	0X00200000
 
 #define I40E_VF_BASE_MODE_OFFLOADS (I40E_VIRTCHNL_VF_OFFLOAD_L2 | \
 				    I40E_VIRTCHNL_VF_OFFLOAD_VLAN | \
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index fb2811c23024..c690aba8e8d1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2401,6 +2401,8 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct i40e_vsi *vsi = &adapter->vsi;
 	int i;
+	netdev_features_t hw_enc_features;
+	netdev_features_t hw_features;
 
 	/* got VF config message back from PF, now we can parse it */
 	for (i = 0; i < vfres->num_vsis; i++) {
@@ -2412,46 +2414,52 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 		return -ENODEV;
 	}
 
-	netdev->hw_enc_features |= NETIF_F_SG			|
-				   NETIF_F_IP_CSUM		|
-				   NETIF_F_IPV6_CSUM		|
-				   NETIF_F_HIGHDMA		|
-				   NETIF_F_SOFT_FEATURES	|
-				   NETIF_F_TSO			|
-				   NETIF_F_TSO_ECN		|
-				   NETIF_F_TSO6			|
+	hw_enc_features = NETIF_F_SG			|
+			  NETIF_F_IP_CSUM		|
+			  NETIF_F_IPV6_CSUM		|
+			  NETIF_F_HIGHDMA		|
+			  NETIF_F_SOFT_FEATURES	|
+			  NETIF_F_TSO			|
+			  NETIF_F_TSO_ECN		|
+			  NETIF_F_TSO6			|
+			  NETIF_F_SCTP_CRC		|
+			  NETIF_F_RXHASH		|
+			  NETIF_F_RXCSUM		|
+			  0;
+
+	/* advertise to stack only if offloads for encapsulated packets is
+	 * supported
+	 */
+	if (vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_ENCAP) {
+		hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_GRE		|
 				   NETIF_F_GSO_GRE_CSUM		|
 				   NETIF_F_GSO_IPXIP4		|
 				   NETIF_F_GSO_IPXIP6		|
-				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_GSO_PARTIAL		|
-				   NETIF_F_SCTP_CRC		|
-				   NETIF_F_RXHASH		|
-				   NETIF_F_RXCSUM		|
 				   0;
 
-	if (!(adapter->flags & I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE))
-		netdev->gso_partial_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM;
-
-	netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
+		if (!(vfres->vf_offload_flags &
+		      I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM))
+			netdev->gso_partial_features |=
+				NETIF_F_GSO_UDP_TUNNEL_CSUM;
 
+		netdev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
+		netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
+		netdev->hw_enc_features |= hw_enc_features;
+	}
 	/* record features VLANs can make use of */
-	netdev->vlan_features |= netdev->hw_enc_features |
-				 NETIF_F_TSO_MANGLEID;
+	netdev->vlan_features |= hw_enc_features | NETIF_F_TSO_MANGLEID;
 
 	/* Write features and hw_features separately to avoid polluting
-	 * with, or dropping, features that are set when we registgered.
+	 * with, or dropping, features that are set when we registered.
 	 */
-	netdev->hw_features |= netdev->hw_enc_features;
+	hw_features = hw_enc_features;
 
-	netdev->features |= netdev->hw_enc_features | I40EVF_VLAN_FEATURES;
-	netdev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
+	netdev->hw_features |= hw_features;
 
-	/* disable VLAN features if not supported */
-	if (!(vfres->vf_offload_flags & I40E_VIRTCHNL_VF_OFFLOAD_VLAN))
-		netdev->features ^= I40EVF_VLAN_FEATURES;
+	netdev->features |= hw_features | I40EVF_VLAN_FEATURES;
 
 	adapter->vsi.id = adapter->vsi_res->vsi_id;
 
@@ -2592,9 +2600,6 @@ static void i40evf_init_task(struct work_struct *work)
 		goto err_alloc;
 	}
 
-	if (hw->mac.type == I40E_MAC_X722_VF)
-		adapter->flags |= I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE;
-
 	if (i40evf_process_config(adapter))
 		goto err_alloc;
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 032be8d3928a..3bccfbb1db14 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -159,7 +159,9 @@ int i40evf_send_vf_config_msg(struct i40evf_adapter *adapter)
 	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG |
 	       I40E_VIRTCHNL_VF_OFFLOAD_VLAN |
 	       I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR |
-	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2;
+	       I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2 |
+	       I40E_VIRTCHNL_VF_OFFLOAD_ENCAP |
+	       I40E_VIRTCHNL_VF_OFFLOAD_ENCAP_CSUM;
 
 	adapter->current_op = I40E_VIRTCHNL_OP_GET_VF_RESOURCES;
 	adapter->aq_required &= ~I40EVF_FLAG_AQ_GET_CONFIG;
-- 
2.12.2
