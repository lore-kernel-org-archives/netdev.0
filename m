From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 2/3] i40e/i40evf: Drop useless "IN_NETPOLL" flag
Date: Thu, 24 Sep 2015 09:04:32 -0700
Message-ID: <20150924160432.22015.84967.stgit@ahduyck-vm-fedora22>
References: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34432 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755775AbbIXQEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:04:34 -0400
Received: by padhy16 with SMTP id hy16so76939197pad.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 09:04:33 -0700 (PDT)
In-Reply-To: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in i40e and i40evf is using an "IN_NETPOLL" flag that has never
added any value due to the fact that the Rx clean-up is handled in NAPI.
As such the flag was set, the queue was scheduled via NAPI, and then polled
from the netpoll controller and if any Rx packets were processed the were
processed in the wrong context.

In addition the flag itself just added an unneeded conditional to the
hot-path so it can safely be dropped and save us a few instructions.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        |    1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c   |    2 --
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |    7 +------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |    7 +------
 drivers/net/ethernet/intel/i40evf/i40evf.h    |    2 --
 5 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index e1cd8ac19dfc..e87d96788af2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -308,7 +308,6 @@ struct i40e_pf {
 #ifdef I40E_FCOE
 #define I40E_FLAG_FCOE_ENABLED			BIT_ULL(11)
 #endif /* I40E_FCOE */
-#define I40E_FLAG_IN_NETPOLL			BIT_ULL(12)
 #define I40E_FLAG_16BYTE_RX_DESC_ENABLED	BIT_ULL(13)
 #define I40E_FLAG_CLEAN_ADMINQ			BIT_ULL(14)
 #define I40E_FLAG_FILTER_SYNC			BIT_ULL(15)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f048002ad928..56fd4ddbb9a8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3749,14 +3749,12 @@ static void i40e_netpoll(struct net_device *netdev)
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
index 66b1fd26f0fc..fe4ce5a807a3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1345,16 +1345,11 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
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
index c60e9cf016c2..cff9b47a5ebc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -822,16 +822,11 @@ static void i40e_receive_skb(struct i40e_ring *rx_ring,
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
index 132f03a0f87b..e18e4132b61b 100644
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
