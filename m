From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] ixgbe: Cleanup configuration of FCoE registers
Date: Thu, 19 Jul 2012 18:24:01 -0700
Message-ID: <1342747446-16132-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55809 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581Ab2GTBYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:14 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so we always use the FCoE redirection table.  We just
set all 8 entries to the same value in the case of only having one queue
for FCoE.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   58 +++++++++++++------------
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 32 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 9b0909f..a994570 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -618,6 +618,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 	unsigned int cpu;
+	u32 etqf;
 
 	if (!fcoe->pool) {
 		spin_lock_init(&fcoe->lock);
@@ -665,40 +666,43 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		}
 	}
 
-	/* Enable L2 eth type filter for FCoE */
-	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE),
-			(ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN));
-	/* Enable L2 eth type filter for FIP */
-	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FIP),
-			(ETH_P_FIP | IXGBE_ETQF_FILTER_EN));
-	if (adapter->ring_feature[RING_F_FCOE].indices) {
-		/* Use multiple rx queues for FCoE by redirection table */
-		for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
-			fcoe_i = f->offset + i % f->indices;
-			fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
-			fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
-			IXGBE_WRITE_REG(hw, IXGBE_FCRETA(i), fcoe_q);
-		}
-		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
-		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
-	} else  {
-		/* Use single rx queue for FCoE */
-		fcoe_i = f->offset;
+	/* Enable L2 EtherType filter for FCoE, necessary for FCoE Rx CRC */
+	etqf = ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		etqf |= IXGBE_ETQF_POOL_ENABLE;
+		etqf |= VMDQ_P(0) << IXGBE_ETQF_POOL_SHIFT;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE), etqf);
+	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
+
+	/* Use one or more Rx queues for FCoE by redirection table */
+	for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
+		fcoe_i = f->offset + (i % f->indices);
+		fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
 		fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
-		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, 0);
-		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE),
-				IXGBE_ETQS_QUEUE_EN |
-				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
+		IXGBE_WRITE_REG(hw, IXGBE_FCRETA(i), fcoe_q);
 	}
-	/* send FIP frames to the first FCoE queue */
-	fcoe_i = f->offset;
-	fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
+	IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
+
+	/* Enable L2 EtherType filter for FIP */
+	etqf = ETH_P_FIP | IXGBE_ETQF_FILTER_EN;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		etqf |= IXGBE_ETQF_POOL_ENABLE;
+		etqf |= VMDQ_P(0) << IXGBE_ETQF_POOL_SHIFT;
+	}
+	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FIP), etqf);
+
+	/* Send FIP frames to the first FCoE queue */
+	fcoe_q = adapter->rx_ring[f->offset]->reg_idx;
 	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FIP),
 			IXGBE_ETQS_QUEUE_EN |
 			(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 
-	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL, IXGBE_FCRXCTRL_FCCRCBO |
+	/* Configure FCoE Rx control */
+	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL,
+			IXGBE_FCRXCTRL_FCCRCBO |
 			(FC_FCOE_VER << IXGBE_FCRXCTRL_FCOEVER_SHIFT));
+
 	return;
 out_pcpu_noddp_extra_buff_alloc_fail:
 	free_percpu(fcoe->pcpu_noddp);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 7416d22..482a33b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1452,6 +1452,7 @@ enum {
 #define IXGBE_ETQF_1588         0x40000000 /* bit 30 */
 #define IXGBE_ETQF_FILTER_EN    0x80000000 /* bit 31 */
 #define IXGBE_ETQF_POOL_ENABLE   (1 << 26) /* bit 26 */
+#define IXGBE_ETQF_POOL_SHIFT		20
 
 #define IXGBE_ETQS_RX_QUEUE     0x007F0000 /* bits 22:16 */
 #define IXGBE_ETQS_RX_QUEUE_SHIFT       16
-- 
1.7.10.4
