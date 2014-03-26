From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Add a fallback debug flow for the driver
Date: Wed, 26 Mar 2014 11:03:29 -0700
Message-ID: <1395857013-7568-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47346 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543AbaCZSEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 14:04:31 -0400
In-Reply-To: <1395857013-7568-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

If the reset fails or the FW is unresponsive instead of failing
module load, load the module in debug mode. In this mode the interfaces
don't exit but the user gets limited access to debugfs hooks. These can
still be used to read/write to registers for debug.

Change-ID: Ie33da80d2f53aaa18eac816196d981fb7a86a02c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 85 ++++++++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 10 ++-
 3 files changed, 55 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index beb7b43..abac6d1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -137,6 +137,7 @@ enum i40e_state_t {
 	__I40E_FILTER_OVERFLOW_PROMISC,
 	__I40E_SUSPENDED,
 	__I40E_BAD_EEPROM,
+	__I40E_DEBUG_MODE,
 };
 
 enum i40e_interrupt_policy {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 3c37386..c28f69c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1061,7 +1061,52 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		count = cmd_buf_tmp - cmd_buf + 1;
 	}
 
-	if (strncmp(cmd_buf, "add vsi", 7) == 0) {
+	if (strncmp(cmd_buf, "read", 4) == 0) {
+		u32 address;
+		u32 value;
+		cnt = sscanf(&cmd_buf[4], "%i", &address);
+		if (cnt != 1) {
+			dev_info(&pf->pdev->dev, "read <reg>\n");
+			goto command_write_done;
+		}
+
+		/* check the range on address */
+		if (address >= I40E_MAX_REGISTER) {
+			dev_info(&pf->pdev->dev, "read reg address 0x%08x too large\n",
+				 address);
+			goto command_write_done;
+		}
+
+		value = rd32(&pf->hw, address);
+		dev_info(&pf->pdev->dev, "read: 0x%08x = 0x%08x\n",
+			 address, value);
+
+	} else if (strncmp(cmd_buf, "write", 5) == 0) {
+		u32 address, value;
+		cnt = sscanf(&cmd_buf[5], "%i %i", &address, &value);
+		if (cnt != 2) {
+			dev_info(&pf->pdev->dev, "write <reg> <value>\n");
+			goto command_write_done;
+		}
+
+		/* check the range on address */
+		if (address >= I40E_MAX_REGISTER) {
+			dev_info(&pf->pdev->dev, "write reg address 0x%08x too large\n",
+				 address);
+			goto command_write_done;
+		}
+		wr32(&pf->hw, address, value);
+		value = rd32(&pf->hw, address);
+		dev_info(&pf->pdev->dev, "write: 0x%08x = 0x%08x\n",
+			 address, value);
+
+	} else if (test_bit(__I40E_DEBUG_MODE, &pf->state)) {
+		dev_info(&pf->pdev->dev, "unknown command '%s'\n", cmd_buf);
+		dev_info(&pf->pdev->dev, "available commands\n");
+		dev_info(&pf->pdev->dev, "  read <reg>\n");
+		dev_info(&pf->pdev->dev, "  write <reg> <value>\n");
+		goto command_write_done;
+	} else if (strncmp(cmd_buf, "add vsi", 7) == 0) {
 		vsi_seid = -1;
 		cnt = sscanf(&cmd_buf[7], "%i", &vsi_seid);
 		if (cnt == 0) {
@@ -1484,44 +1529,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "debugfs: forcing EMPR\n");
 		i40e_do_reset_safe(pf, (1 << __I40E_EMP_RESET_REQUESTED));
 
-	} else if (strncmp(cmd_buf, "read", 4) == 0) {
-		u32 address;
-		u32 value;
-		cnt = sscanf(&cmd_buf[4], "%i", &address);
-		if (cnt != 1) {
-			dev_info(&pf->pdev->dev, "read <reg>\n");
-			goto command_write_done;
-		}
-
-		/* check the range on address */
-		if (address >= I40E_MAX_REGISTER) {
-			dev_info(&pf->pdev->dev, "read reg address 0x%08x too large\n",
-				 address);
-			goto command_write_done;
-		}
-
-		value = rd32(&pf->hw, address);
-		dev_info(&pf->pdev->dev, "read: 0x%08x = 0x%08x\n",
-			 address, value);
-
-	} else if (strncmp(cmd_buf, "write", 5) == 0) {
-		u32 address, value;
-		cnt = sscanf(&cmd_buf[5], "%i %i", &address, &value);
-		if (cnt != 2) {
-			dev_info(&pf->pdev->dev, "write <reg> <value>\n");
-			goto command_write_done;
-		}
-
-		/* check the range on address */
-		if (address >= I40E_MAX_REGISTER) {
-			dev_info(&pf->pdev->dev, "write reg address 0x%08x too large\n",
-				 address);
-			goto command_write_done;
-		}
-		wr32(&pf->hw, address, value);
-		value = rd32(&pf->hw, address);
-		dev_info(&pf->pdev->dev, "write: 0x%08x = 0x%08x\n",
-			 address, value);
 	} else if (strncmp(cmd_buf, "clear_stats", 11) == 0) {
 		if (strncmp(&cmd_buf[12], "vsi", 3) == 0) {
 			cnt = sscanf(&cmd_buf[15], "%i", &vsi_seid);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a1ec793..4b4e0fe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8123,6 +8123,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	pf->next_vsi = 0;
 	pf->pdev = pdev;
+	pci_set_drvdata(pdev, pf);
 	set_bit(__I40E_DOWN, &pf->state);
 
 	hw = &pf->hw;
@@ -8229,7 +8230,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev_info(&pdev->dev, "MAC address: %pM\n", hw->mac.addr);
 	memcpy(hw->mac.perm_addr, hw->mac.addr, ETH_ALEN);
 
-	pci_set_drvdata(pdev, pf);
 	pci_save_state(pdev);
 #ifdef CONFIG_I40E_DCB
 	err = i40e_init_pf_dcb(pf);
@@ -8379,7 +8379,10 @@ err_sw_init:
 err_adminq_setup:
 	(void)i40e_shutdown_adminq(hw);
 err_pf_reset:
-	iounmap(hw->hw_addr);
+	dev_warn(&pdev->dev, "HW reset failed or FW unresponsive, module loaded in debug mode\n");
+	i40e_dbg_pf_init(pf);
+	set_bit(__I40E_DEBUG_MODE, &pf->state);
+	return 0;
 err_ioremap:
 	kfree(pf);
 err_pf_alloc:
@@ -8409,6 +8412,8 @@ static void i40e_remove(struct pci_dev *pdev)
 	int i;
 
 	i40e_dbg_pf_exit(pf);
+	if (test_bit(__I40E_DEBUG_MODE, &pf->state))
+		goto unmap;
 
 	i40e_ptp_stop(pf);
 
@@ -8481,6 +8486,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	kfree(pf->sw_config);
 	kfree(pf->vsi);
 
+unmap:
 	/* force a PF reset to clean anything leftover */
 	reg = rd32(&pf->hw, I40E_PFGEN_CTRL);
 	wr32(&pf->hw, I40E_PFGEN_CTRL, (reg | I40E_PFGEN_CTRL_PFSWR_MASK));
-- 
1.8.3.1
