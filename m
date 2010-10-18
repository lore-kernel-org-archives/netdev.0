From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/2] netxen: mask correctable error
Date: Mon, 18 Oct 2010 05:03:42 -0700
Message-ID: <1287403422-10431-2-git-send-email-amit.salecha@qlogic.com>
References: <1287403422-10431-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:18164 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750777Ab0JRMDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 08:03:43 -0400
In-Reply-To: <1287403422-10431-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW workaround:
Disable logging of correctable error for some NX3031 based adapter.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |   26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 10e2f13..4b4ac71 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1822,14 +1822,14 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	if (netxen_rom_fast_read(adapter, offset, &board_type))
 		return -EIO;
 
-	adapter->ahw.board_type = board_type;
-
 	if (board_type == NETXEN_BRDTYPE_P3_4_GB_MM) {
 		u32 gpio = NXRD32(adapter, NETXEN_ROMUSB_GLB_PAD_GPIO_I);
 		if ((gpio & 0x8000) == 0)
 			board_type = NETXEN_BRDTYPE_P3_10G_TP;
 	}
 
+	adapter->ahw.board_type = board_type;
+
 	switch (board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 		adapter->ahw.port_type = NETXEN_NIC_GBE;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 83ee554..6f11169 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1249,6 +1249,28 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	return 0;
 }
 
+#ifdef CONFIG_PCIEAER
+static void netxen_mask_aer_correctable(struct netxen_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct pci_dev *root = pdev->bus->self;
+	u32 aer_pos;
+
+	if (adapter->ahw.board_type != NETXEN_BRDTYPE_P3_4_GB_MM &&
+		adapter->ahw.board_type != NETXEN_BRDTYPE_P3_10G_TP)
+		return;
+
+	if (root->pcie_type != PCI_EXP_TYPE_ROOT_PORT)
+		return;
+
+	aer_pos = pci_find_ext_capability(root, PCI_EXT_CAP_ID_ERR);
+	if (!aer_pos)
+		return;
+
+	pci_write_config_dword(root, aer_pos + PCI_ERR_COR_MASK, 0xffff);
+}
+#endif
+
 static int __devinit
 netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1317,6 +1339,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
+#ifdef CONFIG_PCIEAER
+	netxen_mask_aer_correctable(adapter);
+#endif
+
 	/* Mezz cards have PCI function 0,2,3 enabled */
 	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
-- 
1.6.0.2

