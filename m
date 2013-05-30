From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/5] netxen_nic: netxen_setup_intr() function code cleanup
Date: Thu, 30 May 2013 15:51:36 -0400
Message-ID: <1369943498-1732-4-git-send-email-manish.chopra@qlogic.com>
References: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:7209
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757639Ab3E3URD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:17:03 -0400
In-Reply-To: <1369943498-1732-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   77 ++++++++++++--------
 1 files changed, 46 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 558df46..927ae9f 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -593,47 +593,43 @@ static const struct net_device_ops netxen_netdev_ops = {
 };
 
 static void
-netxen_setup_intr(struct netxen_adapter *adapter)
+netxen_initialize_interrupt_registers(struct netxen_adapter *adapter)
 {
 	struct netxen_legacy_intr_set *legacy_intrp;
-	struct pci_dev *pdev = adapter->pdev;
-	int err, num_msix;
-
-	if (adapter->rss_supported) {
-		num_msix = (num_online_cpus() >= MSIX_ENTRIES_PER_ADAPTER) ?
-			MSIX_ENTRIES_PER_ADAPTER : 2;
-	} else
-		num_msix = 1;
-
-	adapter->max_sds_rings = 1;
-
-	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
+	u32 tgt_status_reg, int_state_reg;
 
 	if (adapter->ahw.revision_id >= NX_P3_B0)
 		legacy_intrp = &legacy_intr[adapter->ahw.pci_func];
 	else
 		legacy_intrp = &legacy_intr[0];
 
+	tgt_status_reg = legacy_intrp->tgt_status_reg;
+	int_state_reg = ISR_INT_STATE_REG;
+
 	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
-	adapter->tgt_status_reg = netxen_get_ioaddr(adapter,
-			legacy_intrp->tgt_status_reg);
+	adapter->tgt_status_reg = netxen_get_ioaddr(adapter, tgt_status_reg);
 	adapter->tgt_mask_reg = netxen_get_ioaddr(adapter,
-			legacy_intrp->tgt_mask_reg);
+						  legacy_intrp->tgt_mask_reg);
 	adapter->pci_int_reg = netxen_get_ioaddr(adapter,
-			legacy_intrp->pci_int_reg);
+						 legacy_intrp->pci_int_reg);
 	adapter->isr_int_vec = netxen_get_ioaddr(adapter, ISR_INT_VECTOR);
 
 	if (adapter->ahw.revision_id >= NX_P3_B1)
 		adapter->crb_int_state_reg = netxen_get_ioaddr(adapter,
-			ISR_INT_STATE_REG);
+							       int_state_reg);
 	else
 		adapter->crb_int_state_reg = netxen_get_ioaddr(adapter,
-			CRB_INT_VECTOR);
+							       CRB_INT_VECTOR);
+}
 
-	netxen_set_msix_bit(pdev, 0);
+static int netxen_setup_msi_interrupts(struct netxen_adapter *adapter,
+				       int num_msix)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	u32 value;
+	int err;
 
 	if (adapter->msix_supported) {
-
 		netxen_init_msix_entries(adapter, num_msix);
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
@@ -644,26 +640,45 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 				adapter->max_sds_rings = num_msix;
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
-			return;
+			return 0;
 		}
-
-		if (err > 0)
-			pci_disable_msix(pdev);
-
 		/* fall through for msi */
 	}
 
 	if (use_msi && !pci_enable_msi(pdev)) {
+		value = msi_tgt_status[adapter->ahw.pci_func];
 		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
-		adapter->tgt_status_reg = netxen_get_ioaddr(adapter,
-				msi_tgt_status[adapter->ahw.pci_func]);
-		dev_info(&pdev->dev, "using msi interrupts\n");
+		adapter->tgt_status_reg = netxen_get_ioaddr(adapter, value);
 		adapter->msix_entries[0].vector = pdev->irq;
-		return;
+		dev_info(&pdev->dev, "using msi interrupts\n");
+		return 0;
 	}
 
-	dev_info(&pdev->dev, "using legacy interrupts\n");
+	return -EIO;
+}
+
+static void netxen_setup_intr(struct netxen_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int num_msix;
+
+	if (adapter->rss_supported)
+		num_msix = (num_online_cpus() >= MSIX_ENTRIES_PER_ADAPTER) ?
+			    MSIX_ENTRIES_PER_ADAPTER : 2;
+	else
+		num_msix = 1;
+
+	adapter->max_sds_rings = 1;
+	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
+
+	netxen_initialize_interrupt_registers(adapter);
+	netxen_set_msix_bit(pdev, 0);
+
+	if (!netxen_setup_msi_interrupts(adapter, num_msix))
+		return;
+
 	adapter->msix_entries[0].vector = pdev->irq;
+	dev_info(&pdev->dev, "using legacy interrupts\n");
 }
 
 static void
-- 
1.7.1
