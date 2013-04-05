From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 3/4] netxen_nic: Add module parameters support to switch interrupts
Date: Fri,  5 Apr 2013 08:36:42 -0400
Message-ID: <1365165403-18348-4-git-send-email-manish.chopra@qlogic.com>
References: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:47363 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1161660Ab3DEM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 08:59:58 -0400
In-Reply-To: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Adapters do not support co-existence of legacy Interrupt with
  MSI-X or MSI among multiple functions. Prevent attaching
  to a function during normal load, if MSI-x or MSI vectors are not available.

o Using use_msi=0 and use_msi_x=0 module parameters driver can be loaded in
  legacy mode as well as in MSI mode for all functions in the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   34 +++++++++++++-------
 1 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index cde5109..ff113e7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -52,9 +52,13 @@ static int port_mode = NETXEN_PORT_MODE_AUTO_NEG;
 /* Default to restricted 1G auto-neg mode */
 static int wol_port_mode = 5;
 
-static int use_msi = 1;
+static int netxen_use_msi = 1;
+MODULE_PARM_DESC(use_msi, "MSI interrupt (0=disabled, 1=enabled)");
+module_param_named(use_msi, netxen_use_msi, int, 0444);
 
-static int use_msi_x = 1;
+static int netxen_use_msi_x = 1;
+MODULE_PARM_DESC(use_msi_x, "MSI-X interrupt (0=disabled, 1=enabled)");
+module_param_named(use_msi_x, netxen_use_msi_x, int, 0444);
 
 static int auto_fw_reset = AUTO_FW_RESET_ENABLED;
 module_param(auto_fw_reset, int, 0644);
@@ -592,8 +596,7 @@ static const struct net_device_ops netxen_netdev_ops = {
 #endif
 };
 
-static void
-netxen_setup_intr(struct netxen_adapter *adapter)
+static int netxen_setup_intr(struct netxen_adapter *adapter)
 {
 	struct netxen_legacy_intr_set *legacy_intrp;
 	struct pci_dev *pdev = adapter->pdev;
@@ -644,7 +647,7 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 				adapter->max_sds_rings = num_msix;
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
-			return;
+			return err;
 		}
 
 		if (err > 0)
@@ -653,17 +656,21 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 		/* fall through for msi */
 	}
 
-	if (use_msi && !pci_enable_msi(pdev)) {
+	if (netxen_use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= NETXEN_NIC_MSI_ENABLED;
 		adapter->tgt_status_reg = netxen_get_ioaddr(adapter,
 				msi_tgt_status[adapter->ahw.pci_func]);
 		dev_info(&pdev->dev, "using msi interrupts\n");
 		adapter->msix_entries[0].vector = pdev->irq;
-		return;
+		return 0;
 	}
 
+	if (netxen_use_msi || netxen_use_msi_x)
+		return -EOPNOTSUPP;
+
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
+	return 0;
 }
 
 static void
@@ -879,8 +886,8 @@ netxen_check_options(struct netxen_adapter *adapter)
 
 	adapter->msix_supported = 0;
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		adapter->msix_supported = !!use_msi_x;
-		adapter->rss_supported = !!use_msi_x;
+		adapter->msix_supported = !!netxen_use_msi_x;
+		adapter->rss_supported = !!netxen_use_msi_x;
 	} else {
 		u32 flashed_ver = 0;
 		netxen_rom_fast_read(adapter,
@@ -891,8 +898,8 @@ netxen_check_options(struct netxen_adapter *adapter)
 			switch (adapter->ahw.board_type) {
 			case NETXEN_BRDTYPE_P2_SB31_10G:
 			case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-				adapter->msix_supported = !!use_msi_x;
-				adapter->rss_supported = !!use_msi_x;
+				adapter->msix_supported = !!netxen_use_msi_x;
+				adapter->rss_supported = !!netxen_use_msi_x;
 				break;
 			default:
 				break;
@@ -1510,7 +1517,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netxen_nic_clear_stats(adapter);
 
-	netxen_setup_intr(adapter);
+	if (netxen_setup_intr(adapter)) {
+		dev_err(&adapter->pdev->dev, "failed to setup interrupts\n");
+		goto err_out_decr_ref;
+	}
 
 	err = netxen_setup_netdev(adapter, netdev);
 	if (err)
-- 
1.5.6
