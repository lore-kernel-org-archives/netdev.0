From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 03/10] bnx2x: Obtain Bus Device Function from
 register
Date: Thu, 26 Jan 2012 18:01:47 +0200
Message-ID: <1327593714-18358-4-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4223 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab2AZQBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:50 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BDF was obtained from kernel but since in virtualized environment
(e.g. physical device assigment in KVM) the function number may
not be the real one, the info must be obtained from the device.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   17 ++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    3 ++-
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e56b832..115d77a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10546,6 +10546,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 {
 	struct bnx2x *bp;
 	int rc;
+	u32 pci_cfg_dword;
 	bool chip_is_e1x = (board_type == BCM57710 ||
 			    board_type == BCM57711 ||
 			    board_type == BCM57711E);
@@ -10556,7 +10557,6 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	bp->dev = dev;
 	bp->pdev = pdev;
 	bp->flags = 0;
-	bp->pf_num = PCI_FUNC(pdev->devfn);
 
 	rc = pci_enable_device(pdev);
 	if (rc) {
@@ -10623,6 +10623,21 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
+	/* In E1/E1H use pci device function given by kernel.
+	 * In E2/E3 read physical function from ME register since these chips
+	 * support Physical Device Assignment where kernel BDF maybe arbitrary
+	 * (depending on hypervisor).
+	 */
+	if (chip_is_e1x)
+		bp->pf_num = PCI_FUNC(pdev->devfn);
+	else {/* chip is E2/3*/
+		pci_read_config_dword(bp->pdev,
+				      PCICFG_ME_REGISTER, &pci_cfg_dword);
+		bp->pf_num = (u8)((pci_cfg_dword & ME_REG_ABS_PF_NUM) >>
+		    ME_REG_ABS_PF_NUM_SHIFT);
+	}
+	DP(BNX2X_MSG_SP, "me reg PF num: %d\n", bp->pf_num);
+
 	bnx2x_set_power_state(bp, PCI_D0);
 
 	/* clean indirect addresses */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index dddbcf6..8c79e00 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6023,7 +6023,8 @@
 #define PCICFG_MSI_CONTROL_64_BIT_ADDR_CAP	(0x1<<23)
 #define PCICFG_MSI_CONTROL_MSI_PVMASK_CAPABLE	(0x1<<24)
 #define PCICFG_GRC_ADDRESS				0x78
-#define PCICFG_GRC_DATA 				0x80
+#define PCICFG_GRC_DATA				0x80
+#define PCICFG_ME_REGISTER				0x98
 #define PCICFG_MSIX_CAP_ID_OFFSET			0xa0
 #define PCICFG_MSIX_CONTROL_TABLE_SIZE		(0x7ff<<16)
 #define PCICFG_MSIX_CONTROL_RESERVED		(0x7<<27)
-- 
1.7.1
