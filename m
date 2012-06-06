From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: do not use SCRATCHPAD register
Date: Wed, 6 Jun 2012 11:07:22 +0530
Message-ID: <56dfeda0-d8d4-48bd-99bd-bdaf09ceb068@exht1.ad.emulex.com>
References: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753522Ab2FFFwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:31 -0400
In-Reply-To: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CUST_SCRATCHPAD_CSR register is used for marking if FW cleanup is
needed. This is used in a crash kernel scenario. Do no use this register as
it is not available for some functions. Instead, always issue an FLR when
a function is probed *except* when VFs are preset (enabled in the previous
PF load).

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_hw.h   |    2 --
 drivers/net/ethernet/emulex/benet/be_main.c |   10 +++-------
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index d9fb0c5..7c8a710 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -58,8 +58,6 @@
 
 #define SLI_PORT_CONTROL_IP_MASK	0x08000000
 
-#define PCICFG_CUST_SCRATCHPAD_CSR	0x1EC
-
 /********* Memory BAR register ************/
 #define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
 /* Host Interrupt Enable, if set interrupts are enabled although "PCI Interrupt
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 42ee75b..f29827f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1049,6 +1049,8 @@ static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 	u16 offset, stride;
 
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
+	if (!pos)
+		return 0;
 	pci_read_config_word(pdev, pos + PCI_SRIOV_VF_OFFSET, &offset);
 	pci_read_config_word(pdev, pos + PCI_SRIOV_VF_STRIDE, &stride);
 
@@ -2542,7 +2544,6 @@ static int be_clear(struct be_adapter *adapter)
 	be_cmd_fw_clean(adapter);
 
 	be_msix_disable(adapter);
-	pci_write_config_dword(adapter->pdev, PCICFG_CUST_SCRATCHPAD_CSR, 0);
 	return 0;
 }
 
@@ -2785,8 +2786,6 @@ static int be_setup(struct be_adapter *adapter)
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 	adapter->flags |= BE_FLAGS_WORKER_SCHEDULED;
-
-	pci_write_config_dword(adapter->pdev, PCICFG_CUST_SCRATCHPAD_CSR, 1);
 	return 0;
 err:
 	be_clear(adapter);
@@ -3724,10 +3723,7 @@ reschedule:
 
 static bool be_reset_required(struct be_adapter *adapter)
 {
-	u32 reg;
-
-	pci_read_config_dword(adapter->pdev, PCICFG_CUST_SCRATCHPAD_CSR, &reg);
-	return reg;
+	return be_find_vfs(adapter, ENABLED) > 0 ? false : true;
 }
 
 static int __devinit be_probe(struct pci_dev *pdev,
-- 
1.7.4
