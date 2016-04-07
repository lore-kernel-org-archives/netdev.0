From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e/i40evf: Faster RX via avoiding FCoE
Date: Wed,  6 Apr 2016 20:29:31 -0700
Message-ID: <1459999779-22254-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9491 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241AbcDGD3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:44 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As it turns out, calling into other files from hot path hurts
performance a lot.  In this case the majority of the time we
call "check FCoE" and the packet is *not* FCoE, but this call
was taking 5% of our total cycles spent on receive.

Change-ID: I080552c26e7060bc7b78504dc2763f6f0b3d8c76
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c   | 12 +-----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  8 ++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 10 ++++++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  4 +++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 10 ++++++++++
 5 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 92d2208..58e6c15 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2015 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -38,16 +38,6 @@
 #include "i40e_fcoe.h"
 
 /**
- * i40e_rx_is_fcoe - returns true if the rx packet type is FCoE
- * @ptype: the packet type field from rx descriptor write-back
- **/
-static inline bool i40e_rx_is_fcoe(u16 ptype)
-{
-	return (ptype >= I40E_RX_PTYPE_L2_FCOE_PAY3) &&
-	       (ptype <= I40E_RX_PTYPE_L2_FCOE_VFT_FCOTHER);
-}
-
-/**
  * i40e_fcoe_sof_is_class2 - returns true if this is a FC Class 2 SOF
  * @sof: the FCoE start of frame delimiter
  **/
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f4e4d3d..29ffed2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1703,7 +1703,9 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
 			 : 0;
 #ifdef I40E_FCOE
-		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
+		if (unlikely(
+		    i40e_rx_is_fcoe(rx_ptype) &&
+		    !i40e_fcoe_handle_offload(rx_ring, rx_desc, skb))) {
 			dev_kfree_skb_any(skb);
 			continue;
 		}
@@ -1834,7 +1836,9 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
 			 : 0;
 #ifdef I40E_FCOE
-		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
+		if (unlikely(
+		    i40e_rx_is_fcoe(rx_ptype) &&
+		    !i40e_fcoe_handle_offload(rx_ring, rx_desc, skb))) {
 			dev_kfree_skb_any(skb);
 			continue;
 		}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 9e654e6..77ccdde 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -448,4 +448,14 @@ static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
 
 	return __i40e_chk_linearize(skb);
 }
+
+/**
+ * i40e_rx_is_fcoe - returns true if the Rx packet type is FCoE
+ * @ptype: the packet type field from Rx descriptor write-back
+ **/
+static inline bool i40e_rx_is_fcoe(u16 ptype)
+{
+	return (ptype >= I40E_RX_PTYPE_L2_FCOE_PAY3) &&
+	       (ptype <= I40E_RX_PTYPE_L2_FCOE_VFT_FCOTHER);
+}
 #endif /* _I40E_TXRX_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index ec1f447..0c912a4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1160,7 +1160,9 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 			 ? le16_to_cpu(rx_desc->wb.qword0.lo_dword.l2tag1)
 			 : 0;
 #ifdef I40E_FCOE
-		if (!i40e_fcoe_handle_offload(rx_ring, rx_desc, skb)) {
+		if (unlikely(
+		    i40e_rx_is_fcoe(rx_ptype) &&
+		    !i40e_fcoe_handle_offload(rx_ring, rx_desc, skb))) {
 			dev_kfree_skb_any(skb);
 			continue;
 		}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 3ec0ea5..84c28aa6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -430,4 +430,14 @@ static inline bool i40e_chk_linearize(struct sk_buff *skb, int count)
 
 	return __i40evf_chk_linearize(skb);
 }
+
+/**
+ * i40e_rx_is_fcoe - returns true if the Rx packet type is FCoE
+ * @ptype: the packet type field from Rx descriptor write-back
+ **/
+static inline bool i40e_rx_is_fcoe(u16 ptype)
+{
+	return (ptype >= I40E_RX_PTYPE_L2_FCOE_PAY3) &&
+	       (ptype <= I40E_RX_PTYPE_L2_FCOE_VFT_FCOTHER);
+}
 #endif /* _I40E_TXRX_H_ */
-- 
2.5.5
