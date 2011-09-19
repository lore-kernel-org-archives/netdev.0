From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 2/2] netxen: Add pcie workaround
Date: Mon, 19 Sep 2011 11:49:52 -0700
Message-ID: <1316458192-8691-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1316458192-8691-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:21672 "EHLO
	TX2EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451Ab1ISTAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 15:00:52 -0400
In-Reply-To: <1316458192-8691-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o A performance drop was seen with firmware loaded
from flash. This workaround fixes it.
o Updated driver version to 4.0.77

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    4 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   63 +++++++++++++++++++-
 2 files changed, 64 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 196b660..a876dff 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 76
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.76"
+#define _NETXEN_NIC_LINUX_SUBVERSION 77
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.77"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index de18e47..82626d6 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -400,6 +400,63 @@ static void netxen_set_port_mode(struct netxen_adapter *adapter)
 	}
 }
 
+#define PCI_CAP_ID_GEN  0x10
+
+static void netxen_pcie_strap_init(struct netxen_adapter *adapter)
+{
+	u32 pdevfuncsave;
+	u32 c8c9value = 0;
+	u32 chicken = 0;
+	u32 control = 0;
+	int i, pos;
+	struct pci_dev *pdev;
+
+	pdev = adapter->pdev;
+
+	chicken = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_CHICKEN3));
+	/* clear chicken3.25:24 */
+	chicken &= 0xFCFFFFFF;
+	/*
+	 * if gen1 and B0, set F1020 - if gen 2, do nothing
+	 * if gen2 set to F1000
+	 */
+	pos = pci_find_capability(pdev, PCI_CAP_ID_GEN);
+	if (pos == 0xC0) {
+		pci_read_config_dword(pdev, pos + 0x10, &control);
+		if ((control & 0x000F0000) != 0x00020000) {
+			/*  set chicken3.24 if gen1 */
+			chicken |= 0x01000000;
+		}
+		dev_info(&adapter->pdev->dev, "Gen2 strapping detected\n");
+		c8c9value = 0xF1000;
+	} else {
+		/* set chicken3.24 if gen1 */
+		chicken |= 0x01000000;
+		dev_info(&adapter->pdev->dev, "Gen1 strapping detected\n");
+		if (adapter->ahw.revision_id == NX_P3_B0)
+			c8c9value = 0xF1020;
+		else
+			c8c9value = 0;
+	}
+
+	NXWR32(adapter, NETXEN_PCIE_REG(PCIE_CHICKEN3), chicken);
+
+	if (!c8c9value)
+		return;
+
+	pdevfuncsave = pdev->devfn;
+	if (pdevfuncsave & 0x07)
+		return;
+
+	for (i = 0; i < 8; i++) {
+		pci_read_config_dword(pdev, pos + 8, &control);
+		pci_read_config_dword(pdev, pos + 8, &control);
+		pci_write_config_dword(pdev, pos + 8, c8c9value);
+		pdev->devfn++;
+	}
+	pdev->devfn = pdevfuncsave;
+}
+
 static void netxen_set_msix_bit(struct pci_dev *pdev, int enable)
 {
 	u32 control;
@@ -867,7 +924,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	if (err < 0)
 		goto err_out;
 	if (err == 0)
-		goto wait_init;
+		goto pcie_strap_init;
 
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
@@ -910,6 +967,10 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
 	NXWR32(adapter, CRB_DRIVER_VERSION, val);
 
+pcie_strap_init:
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_pcie_strap_init(adapter);
+
 wait_init:
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
-- 
1.6.3.3
