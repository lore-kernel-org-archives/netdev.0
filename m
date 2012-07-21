From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] ixgbevf: Fix namespace issue with ixgbe_write_eitr
Date: Sat, 21 Jul 2012 16:08:55 -0700
Message-ID: <1342912142-11130-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:54382 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751909Ab2GUXJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jul 2012 19:09:10 -0400
In-Reply-To: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Make the function static to cleanup namespace.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <Sibai.li@intel.com
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    1 -
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   43 +++++++++------------
 2 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 66858b5..98cadb0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -286,7 +286,6 @@ extern void ixgbevf_free_rx_resources(struct ixgbevf_adapter *,
 extern void ixgbevf_free_tx_resources(struct ixgbevf_adapter *,
 				      struct ixgbevf_ring *);
 extern void ixgbevf_update_stats(struct ixgbevf_adapter *adapter);
-void ixgbevf_write_eitr(struct ixgbevf_q_vector *);
 extern int ethtool_ioctl(struct ifreq *ifr);
 
 extern void ixgbe_napi_add_all(struct ixgbevf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index ccc801e..3f9841d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -540,6 +540,25 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	return 0;
 }
 
+/**
+ * ixgbevf_write_eitr - write VTEITR register in hardware specific way
+ * @q_vector: structure containing interrupt and ring information
+ */
+static void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
+{
+	struct ixgbevf_adapter *adapter = q_vector->adapter;
+	struct ixgbe_hw *hw = &adapter->hw;
+	int v_idx = q_vector->v_idx;
+	u32 itr_reg = q_vector->itr & IXGBE_MAX_EITR;
+
+	/*
+	 * set the WDIS bit to not clear the timer bits and cause an
+	 * immediate assertion of the interrupt
+	 */
+	itr_reg |= IXGBE_EITR_CNT_WDIS;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VTEITR(v_idx), itr_reg);
+}
 
 /**
  * ixgbevf_configure_msix - Configure MSI-X hardware
@@ -662,30 +681,6 @@ static void ixgbevf_update_itr(struct ixgbevf_q_vector *q_vector,
 	ring_container->itr = itr_setting;
 }
 
-/**
- * ixgbevf_write_eitr - write VTEITR register in hardware specific way
- * @q_vector: structure containing interrupt and ring information
- *
- * This function is made to be called by ethtool and by the driver
- * when it needs to update VTEITR registers at runtime.  Hardware
- * specific quirks/differences are taken care of here.
- */
-void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
-{
-	struct ixgbevf_adapter *adapter = q_vector->adapter;
-	struct ixgbe_hw *hw = &adapter->hw;
-	int v_idx = q_vector->v_idx;
-	u32 itr_reg = q_vector->itr & IXGBE_MAX_EITR;
-
-	/*
-	 * set the WDIS bit to not clear the timer bits and cause an
-	 * immediate assertion of the interrupt
-	 */
-	itr_reg |= IXGBE_EITR_CNT_WDIS;
-
-	IXGBE_WRITE_REG(hw, IXGBE_VTEITR(v_idx), itr_reg);
-}
-
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector)
 {
 	u32 new_itr = q_vector->itr;
-- 
1.7.10.4
