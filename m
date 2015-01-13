From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/15] i40evf: enable interrupt 0 appropriately
Date: Tue, 13 Jan 2015 11:58:05 -0800
Message-ID: <1421179093-10932-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753568AbbAMT6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:17 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Don't enable vector 0 in the ISR, just schedule the adminq task and let
it enable the vector. This prevents the task from being called
reentrantly. Make sure that the vector is enabled on all exit paths of
the adminq task, including error exits.

Change-ID: I53f3d14f91ed7a9e90291ea41c681122a5eca5b5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index c960ef5..e2311af 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -313,10 +313,6 @@ static irqreturn_t i40evf_msix_aq(int irq, void *data)
 	val = val | I40E_PFINT_DYN_CTL0_CLEARPBA_MASK;
 	wr32(hw, I40E_VFINT_DYN_CTL01, val);
 
-	/* re-enable interrupt causes */
-	wr32(hw, I40E_VFINT_ICR0_ENA1, ena_mask);
-	wr32(hw, I40E_VFINT_DYN_CTL01, I40E_VFINT_DYN_CTL01_INTENA_MASK);
-
 	/* schedule work on the private workqueue */
 	schedule_work(&adapter->adminq_task);
 
@@ -1620,12 +1616,12 @@ static void i40evf_adminq_task(struct work_struct *work)
 	u16 pending;
 
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED)
-		return;
+		goto out;
 
 	event.buf_len = I40EVF_MAX_AQ_BUF_SIZE;
 	event.msg_buf = kzalloc(event.buf_len, GFP_KERNEL);
 	if (!event.msg_buf)
-		return;
+		goto out;
 
 	v_msg = (struct i40e_virtchnl_msg *)&event.desc;
 	do {
@@ -1675,10 +1671,10 @@ static void i40evf_adminq_task(struct work_struct *work)
 	if (oldval != val)
 		wr32(hw, hw->aq.asq.len, val);
 
+	kfree(event.msg_buf);
+out:
 	/* re-enable Admin queue interrupt cause */
 	i40evf_misc_irq_enable(adapter);
-
-	kfree(event.msg_buf);
 }
 
 /**
-- 
1.9.3
