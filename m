From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 4/5] netxen_nic: Avoid mixed mode interrupts
Date: Thu, 30 May 2013 15:51:37 -0400
Message-ID: <1369943498-1732-5-git-send-email-manish.chopra@qlogic.com>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0186.outbound.messaging.microsoft.com ([213.199.154.186]:2102
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757659Ab3E3URE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:04 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Adapters do not support co-existence of INTx Interrupt with
  MSI-X or MSI among multiple functions. Prevent attaching
  of a function during normal load, if adapter gets into mixed
  mode of interrupts

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    3 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   50 +++++++++++++++++---
 2 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index 28e0769..32c7906 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -734,6 +734,9 @@ enum {
 #define NIC_CRB_BASE_2		(NETXEN_CAM_RAM(0x700))
 #define NETXEN_NIC_REG(X)	(NIC_CRB_BASE+(X))
 #define NETXEN_NIC_REG_2(X)	(NIC_CRB_BASE_2+(X))
+#define NETXEN_INTR_MODE_REG	NETXEN_NIC_REG(0x44)
+#define NETXEN_MSI_MODE		0x1
+#define NETXEN_INTX_MODE	0x2
 
 #define NX_CDRP_CRB_OFFSET		(NETXEN_NIC_REG(0x18))
 #define NX_ARG1_CRB_OFFSET		(NETXEN_NIC_REG(0x1c))
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 927ae9f..20c7b3c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -592,6 +592,22 @@ static const struct net_device_ops netxen_netdev_ops = {
 #endif
 };
 
+static inline bool netxen_function_zero(struct pci_dev *pdev)
+{
+	return (PCI_FUNC(pdev->devfn) == 0) ? true : false;
+}
+
+static inline void netxen_set_interrupt_mode(struct netxen_adapter *adapter,
+					     u32 mode)
+{
+	NXWR32(adapter, NETXEN_INTR_MODE_REG, mode);
+}
+
+static inline u32 netxen_get_interrupt_mode(struct netxen_adapter *adapter)
+{
+	return NXRD32(adapter, NETXEN_INTR_MODE_REG);
+}
+
 static void
 netxen_initialize_interrupt_registers(struct netxen_adapter *adapter)
 {
@@ -654,10 +670,11 @@ static int netxen_setup_msi_interrupts(struct netxen_adapter *adapter,
 		return 0;
 	}
 
+	dev_err(&pdev->dev, "Failed to acquire MSI-X/MSI interrupt vector\n");
 	return -EIO;
 }
 
-static void netxen_setup_intr(struct netxen_adapter *adapter)
+static int netxen_setup_intr(struct netxen_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	int num_msix;
@@ -674,11 +691,24 @@ static void netxen_setup_intr(struct netxen_adapter *adapter)
 	netxen_initialize_interrupt_registers(adapter);
 	netxen_set_msix_bit(pdev, 0);
 
-	if (!netxen_setup_msi_interrupts(adapter, num_msix))
-		return;
+	if (netxen_function_zero(pdev)) {
+		if (!netxen_setup_msi_interrupts(adapter, num_msix))
+			netxen_set_interrupt_mode(adapter, NETXEN_MSI_MODE);
+		else
+			netxen_set_interrupt_mode(adapter, NETXEN_INTX_MODE);
+	} else {
+		if (netxen_get_interrupt_mode(adapter) == NETXEN_MSI_MODE &&
+		    netxen_setup_msi_interrupts(adapter, num_msix)) {
+			dev_err(&pdev->dev, "Co-existence of MSI-X/MSI and INTx interrupts is not supported\n");
+			return -EIO;
+		}
+	}
 
-	adapter->msix_entries[0].vector = pdev->irq;
-	dev_info(&pdev->dev, "using legacy interrupts\n");
+	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
+		adapter->msix_entries[0].vector = pdev->irq;
+		dev_info(&pdev->dev, "using legacy interrupts\n");
+	}
+	return 0;
 }
 
 static void
@@ -1525,7 +1555,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netxen_nic_clear_stats(adapter);
 
-	netxen_setup_intr(adapter);
+	err = netxen_setup_intr(adapter);
+
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to setup interrupts, error = %d\n", err);
+		goto err_out_disable_msi;
+	}
 
 	err = netxen_setup_netdev(adapter, netdev);
 	if (err)
@@ -1613,7 +1649,7 @@ static void netxen_nic_remove(struct pci_dev *pdev)
 	clear_bit(__NX_RESETTING, &adapter->state);
 
 	netxen_teardown_intr(adapter);
-
+	netxen_set_interrupt_mode(adapter, 0);
 	netxen_remove_diag_entries(adapter);
 
 	netxen_cleanup_pci_map(adapter);
-- 
1.7.1
