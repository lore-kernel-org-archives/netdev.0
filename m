From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/17] i40e/i40evf: Drop useless "IN_NETPOLL" flag
Date: Fri, 16 Oct 2015 05:10:10 -0700
Message-ID: <1444997425-3396-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14653 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098AbbJPMKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:39 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The code in i40e and i40evf is using an "IN_NETPOLL" flag that has never
added any value due to the fact that the Rx clean-up is handled in NAPI.
As such the flag was set, the queue was scheduled via NAPI, and then polled
from the netpoll controller and if any Rx packets were processed the were
processed in the wrong context.

In addition the flag itself just added an unneeded conditional to the
hot-path so it can safely be dropped and save us a few instructions.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c   | 2 --
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 7 +------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 7 +------
 drivers/net/ethernet/intel/i40evf/i40evf.h    | 2 --
 5 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index d587a05..91f8cbf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -307,7 +307,6 @@ struct i40e_pf {
 #ifdef I40E_FCOE
 #define I40E_FLAG_FCOE_ENABLED			BIT_ULL(11)
 #endif /* I40E_FCOE */
-#define I40E_FLAG_IN_NETPOLL			BIT_ULL(12)
 #define I40E_FLAG_16BYTE_RX_DESC_ENABLED	BIT_ULL(13)
 #define I40E_FLAG_CLEAN_ADMINQ			BIT_ULL(14)
 #define I40E_FLAG_FILTER_SYNC			BIT_ULL(15)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5ed844b..389f110 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3574,14 +3574,12 @@ static void i40e_netpoll(struct net_device *netdev)
 	if (test_bit(__I40E_DOWN, &vsi->state))
 		return;
 
-	pf->flags |= I40E_FLAG_IN_NETPOLL;
 	if (pf->flags & I40E_FLAG_MSIX_ENABLED) {
 		for (i = 0; i < vsi->num_q_vectors; i++)
 			i40e_msix_clean_rings(0, vsi->q_vectors[i]);
 	} else {
 		i40e_intr(pf->pdev->irq, netdev);
 	}
-	pf->flags &= ~I40E_FLAG_IN_NETPOLL;
 }
 #endif
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index b560e02..e1fac3b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1268,16 +1268,11 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
 			     struct sk_buff *skb, u16 vlan_tag)
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
-	struct i40e_vsi *vsi = rx_ring->vsi;
-	u64 flags = vsi->back->flags;
 
 	if (vlan_tag & VLAN_VID_MASK)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
-	if (flags & I40E_FLAG_IN_NETPOLL)
-		netif_rx(skb);
-	else
-		napi_gro_receive(&q_vector->napi, skb);
+	napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 1894cc8..5d3a8bd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -742,16 +742,11 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
 			     struct sk_buff *skb, u16 vlan_tag)
 {
 	struct i40e_q_vector *q_vector = rx_ring->q_vector;
-	struct i40e_vsi *vsi = rx_ring->vsi;
-	u64 flags = vsi->back->flags;
 
 	if (vlan_tag & VLAN_VID_MASK)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 
-	if (flags & I40E_FLAG_IN_NETPOLL)
-		netif_rx(skb);
-	else
-		napi_gro_receive(&q_vector->napi, skb);
+	napi_gro_receive(&q_vector->napi, skb);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 6f42711..c74f614 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -211,7 +211,6 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_RX_1BUF_CAPABLE              BIT(1)
 #define I40EVF_FLAG_RX_PS_CAPABLE                BIT(2)
 #define I40EVF_FLAG_RX_PS_ENABLED                BIT(3)
-#define I40EVF_FLAG_IN_NETPOLL                   BIT(4)
 #define I40EVF_FLAG_IMIR_ENABLED                 BIT(5)
 #define I40EVF_FLAG_MQ_CAPABLE                   BIT(6)
 #define I40EVF_FLAG_NEED_LINK_UPDATE             BIT(7)
@@ -224,7 +223,6 @@ struct i40evf_adapter {
 /* duplicates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		 0
 #define I40E_FLAG_DCB_ENABLED			 0
-#define I40E_FLAG_IN_NETPOLL			 I40EVF_FLAG_IN_NETPOLL
 #define I40E_FLAG_RX_CSUM_ENABLED                I40EVF_FLAG_RX_CSUM_ENABLED
 #define I40E_FLAG_WB_ON_ITR_CAPABLE		I40EVF_FLAG_WB_ON_ITR_CAPABLE
 #define I40E_FLAG_OUTER_UDP_CSUM_CAPABLE	I40EVF_FLAG_OUTER_UDP_CSUM_CAPABLE
-- 
2.4.3
