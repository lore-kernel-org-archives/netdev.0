From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  01/14] i40e: do not flush after re-enabling interrupts
Date: Fri, 18 Oct 2013 06:23:05 -0700
Message-ID: <1382102598-11343-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41263 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343Ab3JRNXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:40 -0400
In-Reply-To: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Hot path doesn't need read-flush after interrupt enable, and this
flush really causes a lot of extra cpu utilization.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fbe7fe2..69ed801 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2560,7 +2560,7 @@ void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 	      I40E_PFINT_DYN_CTLN_CLEARPBA_MASK |
 	      (I40E_ITR_NONE << I40E_PFINT_DYN_CTLN_ITR_INDX_SHIFT);
 	wr32(hw, I40E_PFINT_DYN_CTLN(vector - 1), val);
-	i40e_flush(hw);
+	/* skip the flush */
 }
 
 /**
@@ -2709,6 +2709,7 @@ static int i40e_vsi_enable_irq(struct i40e_vsi *vsi)
 		i40e_irq_dynamic_enable_icr0(pf);
 	}
 
+	i40e_flush(&pf->hw);
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index dc89e72..fbc40cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -559,8 +559,6 @@ static void i40e_update_dynamic_itr(struct i40e_q_vector *q_vector)
 	i40e_set_new_dynamic_itr(&q_vector->tx);
 	if (old_itr != q_vector->tx.itr)
 		wr32(hw, reg_addr, q_vector->tx.itr);
-
-	i40e_flush(hw);
 }
 
 /**
-- 
1.8.3.1
