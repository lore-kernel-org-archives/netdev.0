From: wenxiong@linux.vnet.ibm.com
Subject: [PATCH V2 2/2] bnx2x: Fix kernel crash and data miscompare after EEH recovery
Date: Wed, 28 May 2014 10:56:43 -0500
Message-ID: <20140528155722.361752083@linux.vnet.ibm.com>
References: <20140528155641.920171803@linux.vnet.ibm.com>
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org,
	Milton Miller <miltonm@bga.com>,
	Wen Xiong <wenxiong@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:33208 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1754003AbaE1QAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 12:00:38 -0400
Content-Disposition: inline; filename=bnx2x_rmb_fix
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A rmb() is required to ensure that the CQE is not read before it
is written by the adapter DMA.  PCI ordering rules will make sure
the other fields are written before the marker at the end of struct
eth_fast_path_rx_cqe but without rmb() a weakly ordered processor can
process stale data.

Without the barrier we have observed various crashes including
bnx2x_tpa_start being called on queues not stopped (resulting in message
start of bin not in stop) and NULL pointer exceptions from bnx2x_rx_int.

Signed-off-by: Milton Miller <miltonm@bga.com>
Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
===================================================================
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2014-05-23 10:34:21.000000000 -0500
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2014-05-28 10:54:26.627766086 -0500
@@ -906,6 +906,18 @@ static int bnx2x_rx_int(struct bnx2x_fas
 		bd_prod = RX_BD(bd_prod);
 		bd_cons = RX_BD(bd_cons);
 
+		/* A rmb() is required to ensure that the CQE is not read
+		 * before it is written by the adapter DMA.  PCI ordering
+		 * rules will make sure the other fields are written before
+		 * the marker at the end of struct eth_fast_path_rx_cqe
+		 * but without rmb() a weakly ordered processor can process
+		 * stale data.  Without the barrier TPA state-machine might
+		 * enter inconsistent state and kernel stack might be
+		 * provided with incorrect packet description - these lead
+		 * to various kernel crashed.
+		*/
+		rmb();
+
 		cqe_fp_flags = cqe_fp->type_error_flags;
 		cqe_fp_type = cqe_fp_flags & ETH_FAST_PATH_RX_CQE_TYPE;
 

-- 
