From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/14] i40e: simplified init string
Date: Fri, 14 Mar 2014 16:34:28 -0700
Message-ID: <1394840075-6851-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35472 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756583AbaCNXfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:35:08 -0400
In-Reply-To: <1394840075-6851-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

In a similar way to how ixgbe works, print a short one-line string
showing what features and number of queues the driver and hardware has
enabled at probe time.

Example (wrapped for the commit message):
i40e 0000:06:00.1: Features: PF-id[1] VFs: 64 VSIs: 66 QP: 32 FDir RSS
ATR NTUPLE DCB

Change-ID: I177bf7f93d1c4c921529c92fdf66e614f6b4f755
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 41 +++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f7b1753ac..79be808 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7851,6 +7851,44 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf)
 	return 0;
 }
 
+#define INFO_STRING_LEN 255
+static void i40e_print_features(struct i40e_pf *pf)
+{
+	struct i40e_hw *hw = &pf->hw;
+	char *buf, *string;
+
+	string = kzalloc(INFO_STRING_LEN, GFP_KERNEL);
+	if (!string) {
+		dev_err(&pf->pdev->dev, "Features string allocation failed\n");
+		return;
+	}
+
+	buf = string;
+
+	buf += sprintf(string, "Features: PF-id[%d] ", hw->pf_id);
+#ifdef CONFIG_PCI_IOV
+	buf += sprintf(buf, "VFs: %d ", pf->num_req_vfs);
+#endif
+	buf += sprintf(buf, "VSIs: %d QP: %d ", pf->hw.func_caps.num_vsis,
+		       pf->vsi[pf->lan_vsi]->num_queue_pairs);
+
+	if (pf->flags & I40E_FLAG_RSS_ENABLED)
+		buf += sprintf(buf, "RSS ");
+	buf += sprintf(buf, "FDir ");
+	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
+		buf += sprintf(buf, "ATR ");
+	if (pf->flags & I40E_FLAG_FD_SB_ENABLED)
+		buf += sprintf(buf, "NTUPLE ");
+	if (pf->flags & I40E_FLAG_DCB_ENABLED)
+		buf += sprintf(buf, "DCB ");
+	if (pf->flags & I40E_FLAG_PTP)
+		buf += sprintf(buf, "PTP ");
+
+	BUG_ON(buf > (string + INFO_STRING_LEN));
+	dev_info(&pf->pdev->dev, "%s\n", string);
+	kfree(string);
+}
+
 /**
  * i40e_probe - Device initialization routine
  * @pdev: PCI device information struct
@@ -8141,6 +8179,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_warn(&pdev->dev, "Please move the device to a different PCI-e link with more lanes and/or higher transfer rate.\n");
 	}
 
+	/* print a string summarizing features */
+	i40e_print_features(pf);
+
 	return 0;
 
 	/* Unwind what we've done if something failed in the setup */
-- 
1.8.3.1
