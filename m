From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: add support for triggering EMPR
Date: Fri,  6 Dec 2013 00:06:26 -0800
Message-ID: <1386317188-13944-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42215 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab3LFIGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:37 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Allow debugfs to trigger a reset called EMPR.

Change-Id: I2f6600a8242759ec60c8198d03f70c2b774e0740
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  4 ++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 18 ++++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8806cab..df685bc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -130,6 +130,7 @@ enum i40e_state_t {
 	__I40E_PF_RESET_REQUESTED,
 	__I40E_CORE_RESET_REQUESTED,
 	__I40E_GLOBAL_RESET_REQUESTED,
+	__I40E_EMP_RESET_REQUESTED,
 	__I40E_FILTER_OVERFLOW_PROMISC,
 };
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index ef4cb1c..9c675b5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1472,6 +1472,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "forcing GlobR\n");
 		i40e_do_reset(pf, (1 << __I40E_GLOBAL_RESET_REQUESTED));
 
+	} else if (strncmp(cmd_buf, "empr", 4) == 0) {
+		dev_info(&pf->pdev->dev, "forcing EMPR\n");
+		i40e_do_reset(pf, (1 << __I40E_EMP_RESET_REQUESTED));
+
 	} else if (strncmp(cmd_buf, "read", 4) == 0) {
 		u32 address;
 		u32 value;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d60673e..5d234a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4056,6 +4056,24 @@ void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags)
 		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
 		i40e_flush(&pf->hw);
 
+	} else if (reset_flags & (1 << __I40E_EMP_RESET_REQUESTED)) {
+
+		/* Request a Firmware Reset
+		 *
+		 * Same as Global reset, plus restarting the
+		 * embedded firmware engine.
+		 */
+		/* enable EMP Reset */
+		val = rd32(&pf->hw, I40E_GLGEN_RSTENA_EMP);
+		val |= I40E_GLGEN_RSTENA_EMP_EMP_RST_ENA_MASK;
+		wr32(&pf->hw, I40E_GLGEN_RSTENA_EMP, val);
+
+		/* force the reset */
+		val = rd32(&pf->hw, I40E_GLGEN_RTRIG);
+		val |= I40E_GLGEN_RTRIG_EMPFWR_MASK;
+		wr32(&pf->hw, I40E_GLGEN_RTRIG, val);
+		i40e_flush(&pf->hw);
+
 	} else if (reset_flags & (1 << __I40E_PF_RESET_REQUESTED)) {
 
 		/* Request a PF Reset
-- 
1.8.3.1
