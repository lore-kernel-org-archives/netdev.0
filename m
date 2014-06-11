From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40evf: check admin queue error bits
Date: Wed, 11 Jun 2014 09:33:19 -0700
Message-ID: <1402504404-8954-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55587 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468AbaFKQdb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 12:33:31 -0400
In-Reply-To: <1402504404-8954-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

FW can indicate any admin queue error states to the driver via some bits
in the length registers. Each time we process an admin queue message,
check these bits and log any errors we find. Since the VF really can't
do much, we just print the message and depend on the PF driver to clear
things up on our behalf.

Change-ID: I92bc6c53ce3b4400544e0ca19c5de2d27490bd0d
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 36 +++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 8f681caed..12aff07 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1590,6 +1590,7 @@ static void i40evf_adminq_task(struct work_struct *work)
 	struct i40e_arq_event_info event;
 	struct i40e_virtchnl_msg *v_msg;
 	i40e_status ret;
+	u32 val, oldval;
 	u16 pending;
 
 	if (adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED)
@@ -1617,6 +1618,41 @@ static void i40evf_adminq_task(struct work_struct *work)
 		}
 	} while (pending);
 
+	/* check for error indications */
+	val = rd32(hw, hw->aq.arq.len);
+	oldval = val;
+	if (val & I40E_VF_ARQLEN_ARQVFE_MASK) {
+		dev_info(&adapter->pdev->dev, "ARQ VF Error detected\n");
+		val &= ~I40E_VF_ARQLEN_ARQVFE_MASK;
+	}
+	if (val & I40E_VF_ARQLEN_ARQOVFL_MASK) {
+		dev_info(&adapter->pdev->dev, "ARQ Overflow Error detected\n");
+		val &= ~I40E_VF_ARQLEN_ARQOVFL_MASK;
+	}
+	if (val & I40E_VF_ARQLEN_ARQCRIT_MASK) {
+		dev_info(&adapter->pdev->dev, "ARQ Critical Error detected\n");
+		val &= ~I40E_VF_ARQLEN_ARQCRIT_MASK;
+	}
+	if (oldval != val)
+		wr32(hw, hw->aq.arq.len, val);
+
+	val = rd32(hw, hw->aq.asq.len);
+	oldval = val;
+	if (val & I40E_VF_ATQLEN_ATQVFE_MASK) {
+		dev_info(&adapter->pdev->dev, "ASQ VF Error detected\n");
+		val &= ~I40E_VF_ATQLEN_ATQVFE_MASK;
+	}
+	if (val & I40E_VF_ATQLEN_ATQOVFL_MASK) {
+		dev_info(&adapter->pdev->dev, "ASQ Overflow Error detected\n");
+		val &= ~I40E_VF_ATQLEN_ATQOVFL_MASK;
+	}
+	if (val & I40E_VF_ATQLEN_ATQCRIT_MASK) {
+		dev_info(&adapter->pdev->dev, "ASQ Critical Error detected\n");
+		val &= ~I40E_VF_ATQLEN_ATQCRIT_MASK;
+	}
+	if (oldval != val)
+		wr32(hw, hw->aq.asq.len, val);
+
 	/* re-enable Admin queue interrupt cause */
 	i40evf_misc_irq_enable(adapter);
 
-- 
1.9.3
