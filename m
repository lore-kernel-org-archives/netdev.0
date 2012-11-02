From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH V5 14/22] qlcnic: 83xx base driver
Date: Thu,  1 Nov 2012 21:06:46 -0400
Message-ID: <1351818414-25197-15-git-send-email-sony.chacko@qlogic.com>
References: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:44677 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1762560Ab2KBB0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 21:26:15 -0400
In-Reply-To: <1351818414-25197-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify interrupt management and other driver
interface routines to enable base 83xx adapter driver.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  478 +++++++++++++++-------
 2 files changed, 339 insertions(+), 140 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 9b68b52..e0fd655 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1471,6 +1471,7 @@ void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
 
 /* Functions from qlcnic_init.c */
+void qlcnic_schedule_work(struct qlcnic_adapter *, work_func_t, int);
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
 void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a05276a..f9537ca 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2,10 +2,15 @@
  * QLogic qlcnic NIC Driver
  * Copyright (c)  2009-2010 QLogic Corporation
  *
+ * PCI searching functions pci_get_domain_bus_and_slot & pci_channel_offline
+ * Copyright (C) 1993 -- 1997 Drew Eckhardt, Frederic Potter,
+ *					David Mosberger-Tang
+ * Copyright (C) 1997 -- 2000 Martin Mares <mj@ucw.cz>
+ * Copyright (C) 2003 -- 2004 Greg Kroah-Hartman <greg@kroah.com>.
+ *
  * See LICENSE.qlcnic for copyright and licensing details.
  */
 
-#include <linux/slab.h>
 #include <linux/vmalloc.h>
 #include <linux/interrupt.h>
 
@@ -14,10 +19,10 @@
 
 #include <linux/swab.h>
 #include <linux/dma-mapping.h>
+#include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
 #include <linux/inetdevice.h>
-#include <linux/sysfs.h>
 #include <linux/aer.h>
 #include <linux/log2.h>
 
@@ -30,8 +35,6 @@ char qlcnic_driver_name[] = "qlcnic";
 static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
-static struct workqueue_struct *qlcnic_wq;
-
 static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
@@ -52,7 +55,7 @@ int qlcnic_load_fw_file;
 MODULE_PARM_DESC(load_fw_file, "Load firmware from (0=flash, 1=file");
 module_param_named(load_fw_file, qlcnic_load_fw_file, int, 0444);
 
-static int qlcnic_config_npars;
+int qlcnic_config_npars;
 module_param(qlcnic_config_npars, int, 0444);
 MODULE_PARM_DESC(qlcnic_config_npars, "Configure NPARs (0=disabled, 1=enabled");
 
@@ -65,9 +68,6 @@ static void qlcnic_tx_timeout(struct net_device *netdev);
 static void qlcnic_attach_work(struct work_struct *work);
 static void qlcnic_fwinit_work(struct work_struct *work);
 static void qlcnic_fw_poll_work(struct work_struct *work);
-static void qlcnic_schedule_work(struct qlcnic_adapter *adapter,
-		work_func_t func, int delay);
-static void qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev);
 #endif
@@ -87,6 +87,7 @@ static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
 static irqreturn_t qlcnic_intr(int irq, void *data);
 static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data);
 
 static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev);
 static void qlcnic_restore_indev_addr(struct net_device *dev, unsigned long);
@@ -105,15 +106,24 @@ static int qlcnic_vlan_rx_del(struct net_device *, u16);
 #define QLCNIC_IS_TSO_CAPABLE(adapter)	\
 	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
 
+static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	if (adapter->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE824X)
+		return ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX;
+	else
+		return 1;
+}
+
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-#define PCI_DEVICE_ID_QLOGIC_QLE824X  0x8020
-
 static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
+	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	{0,}
 };
 
@@ -203,30 +213,6 @@ void qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 	recv_ctx->sds_rings = NULL;
 }
 
-static void qlcnic_set_msix_bit(struct pci_dev *pdev, int enable)
-{
-	u32 control;
-	int pos;
-
-	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
-	if (pos) {
-		pci_read_config_dword(pdev, pos, &control);
-		if (enable)
-			control |= PCI_MSIX_FLAGS_ENABLE;
-		else
-			control = 0;
-		pci_write_config_dword(pdev, pos, control);
-	}
-}
-
-static void qlcnic_init_msix_entries(struct qlcnic_adapter *adapter, int count)
-{
-	int i;
-
-	for (i = 0; i < count; i++)
-		adapter->msix_entries[i].entry = i;
-}
-
 static int
 qlcnic_read_mac_addr(struct qlcnic_adapter *adapter)
 {
@@ -259,7 +245,7 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 		return -EOPNOTSUPP;
 
 	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+		return -EINVAL;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 		netif_device_detach(netdev);
@@ -363,31 +349,66 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
 	struct pci_dev *pdev = adapter->pdev;
-	int err = -1;
+	int err = -1, i;
+	int max_tx_rings;
+
+	if (!adapter->msix_entries) {
+		adapter->msix_entries = kcalloc(num_msix,
+						sizeof(struct msix_entry),
+						GFP_KERNEL);
+		if (!adapter->msix_entries) {
+			dev_err(&pdev->dev, "failed allocating msix_entries\n");
+			return -ENOMEM;
+		}
+	}
 
 	adapter->max_sds_rings = 1;
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
-	qlcnic_set_msix_bit(pdev, 0);
 
 	if (adapter->ahw->msix_supported) {
  enable_msix:
-		qlcnic_init_msix_entries(adapter, num_msix);
+		for (i = 0; i < num_msix; i++)
+			adapter->msix_entries[i].entry = i;
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
 			adapter->flags |= QLCNIC_MSIX_ENABLED;
-			qlcnic_set_msix_bit(pdev, 1);
-
-			adapter->max_sds_rings = num_msix;
-
+			if (qlcnic_83xx_check(adapter)) {
+				adapter->ahw->num_msix = num_msix;
+				/* subtract mail box and tx ring vectors */
+				max_tx_rings = adapter->max_drv_tx_rings;
+				adapter->max_sds_rings = num_msix -
+							 max_tx_rings - 1;
+			} else {
+				adapter->max_sds_rings = num_msix;
+			}
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
 			return err;
-		}
-		if (err > 0) {
-			num_msix = rounddown_pow_of_two(err);
-			if (num_msix)
+		} else if (err > 0) {
+			dev_info(&pdev->dev,
+				 "Unable to allocate %d MSI-X interrupt vectors\n",
+				 num_msix);
+			if (qlcnic_83xx_check(adapter)) {
+				if (err < QLC_83XX_MINIMUM_VECTOR)
+					return err;
+				err -= (adapter->max_drv_tx_rings + 1);
+				num_msix = rounddown_pow_of_two(err);
+				num_msix += (adapter->max_drv_tx_rings + 1);
+			} else {
+				num_msix = rounddown_pow_of_two(err);
+			}
+
+			if (num_msix) {
+				dev_info(&pdev->dev,
+					 "Trying %d MSI-X interrupt vectors\n",
+					 num_msix);
 				goto enable_msix;
+			}
+		} else {
+			dev_info(&pdev->dev, "Failed to get %d vectors\n",
+				 num_msix);
 		}
 	}
+
 	return err;
 }
 
@@ -440,6 +461,7 @@ int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 	qlcnic_enable_msi_legacy(adapter);
 	return 0;
 }
+
 static void
 qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
@@ -447,6 +469,14 @@ qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 		pci_disable_msix(adapter->pdev);
 	if (adapter->flags & QLCNIC_MSI_ENABLED)
 		pci_disable_msi(adapter->pdev);
+
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+
+	if (adapter->ahw->intr_tbl) {
+		vfree(adapter->ahw->intr_tbl);
+		adapter->ahw->intr_tbl = NULL;
+	}
 }
 
 static void qlcnic_cleanup_pci_map(struct qlcnic_hardware_context *ahw)
@@ -536,8 +566,11 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		j++;
 	}
 
-	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++)
+	for (i = 0; i < QLCNIC_NIU_MAX_XG_PORTS; i++) {
 		adapter->eswitch[i].flags |= QLCNIC_SWITCH_ENABLE;
+		if (qlcnic_83xx_check(adapter))
+			qlcnic_enable_eswitch(adapter, i, 1);
+	}
 
 	kfree(pci_info);
 	return 0;
@@ -620,12 +653,16 @@ static void qlcnic_check_vf(struct qlcnic_adapter *adapter,
 }
 
 #define QLCNIC_82XX_BAR0_LENGTH 0x00200000UL
+#define QLCNIC_83XX_BAR0_LENGTH 0x4000
 static void qlcnic_get_bar_length(u32 dev_id, ulong *bar)
 {
 	switch (dev_id) {
 	case PCI_DEVICE_ID_QLOGIC_QLE824X:
 		*bar = QLCNIC_82XX_BAR0_LENGTH;
 		break;
+	case PCI_DEVICE_ID_QLOGIC_QLE834X:
+		*bar = QLCNIC_83XX_BAR0_LENGTH;
+		break;
 	default:
 		*bar = 0;
 	}
@@ -719,8 +756,9 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		}
 	}
 
-	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
-			fw_major, fw_minor, fw_build);
+	dev_info(&pdev->dev, "Driver v%s, firmware v%d.%d.%d\n",
+		 QLCNIC_LINUX_VERSIONID, fw_major, fw_minor, fw_build);
+
 	if (adapter->ahw->port_type == QLCNIC_XGBE) {
 		if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
@@ -766,6 +804,10 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
 	adapter->ahw->max_mtu = nic_info.max_mtu;
 
+	/* Disable NPAR for 83XX */
+	if (qlcnic_83xx_check(adapter))
+		return err;
+
 	if (adapter->ahw->capabilities & BIT_6)
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
 	else
@@ -848,14 +890,17 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev = adapter->netdev;
-	netdev_features_t features, vlan_features;
+	unsigned long features, vlan_features;
+
+	if (qlcnic_83xx_check(adapter))
+		return;
 
-	features = (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+	features = (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	vlan_features = (NETIF_F_SG | NETIF_F_IP_CSUM |
-			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
+			NETIF_F_IPV6_CSUM);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
 		features |= (NETIF_F_TSO | NETIF_F_TSO6);
 		vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
 	}
@@ -865,12 +910,14 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 
 	if (esw_cfg->offload_flags & BIT_0) {
 		netdev->features |= features;
+		adapter->rx_csum = 1;
 		if (!(esw_cfg->offload_flags & BIT_1))
 			netdev->features &= ~NETIF_F_TSO;
 		if (!(esw_cfg->offload_flags & BIT_2))
 			netdev->features &= ~NETIF_F_TSO6;
 	} else {
 		netdev->features &= ~features;
+		adapter->rx_csum = 0;
 	}
 
 	netdev->vlan_features = (features & vlan_features);
@@ -891,7 +938,7 @@ qlcnic_check_eswitch_mode(struct qlcnic_adapter *adapter)
 		return 0;
 
 	priv_op = adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE;
-	op_mode = readl(priv_op);
+	op_mode = QLCRD(adapter, QLCNIC_DRV_OP_MODE);
 	priv_level = QLC_DEV_GET_DRV(op_mode, adapter->ahw->pci_func);
 
 	if (op_mode == QLC_DEV_DRV_DEFAULT)
@@ -956,6 +1003,7 @@ int qlcnic_set_default_offload_settings(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+
 static int
 qlcnic_reset_eswitch_config(struct qlcnic_adapter *adapter,
 			struct qlcnic_npar_info *npar, int pci_func)
@@ -995,8 +1043,7 @@ int qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 		npar = &adapter->npars[i];
 		pci_func = npar->pci_func;
 		memset(&nic_info, 0, sizeof(struct qlcnic_info));
-		err = qlcnic_get_nic_info(adapter,
-					  &nic_info, pci_func);
+		err = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
 		if (err)
 			return err;
 		nic_info.min_tx_bw = npar->min_bw;
@@ -1059,6 +1106,8 @@ qlcnic_set_mgmt_operations(struct qlcnic_adapter *adapter)
 
 	qlcnic_dev_set_npar_ready(adapter);
 
+	if (qlcnic_83xx_check(adapter))
+		qlcnic_83xx_register_nic_idc_func(adapter, 1);
 	return err;
 }
 
@@ -1133,6 +1182,7 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 {
 	irq_handler_t handler;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 	int err, ring;
 
 	unsigned long flags = 0;
@@ -1140,7 +1190,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
-		handler = qlcnic_tmp_intr;
+		if (qlcnic_82xx_check(adapter))
+			handler = qlcnic_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
 
@@ -1156,15 +1207,32 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	}
 	adapter->irq = netdev->irq;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		sprintf(sds_ring->name, "%s[%d]", netdev->name, ring);
-		err = request_irq(sds_ring->irq, handler,
-				  flags, sds_ring->name, sds_ring);
-		if (err)
-			return err;
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			snprintf(sds_ring->name, sizeof(int) + IFNAMSIZ,
+				 "%s[%d]", netdev->name, ring);
+			err = request_irq(sds_ring->irq, handler, flags,
+					  sds_ring->name, sds_ring);
+			if (err)
+				return err;
+		}
+		if (qlcnic_83xx_check(adapter) &&
+		    (adapter->flags & QLCNIC_MSIX_ENABLED)) {
+			handler = qlcnic_msix_tx_intr;
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+			     ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				snprintf(tx_ring->name, sizeof(int) + IFNAMSIZ,
+					 "%s[%d]", netdev->name,
+				adapter->max_sds_rings + ring);
+				err = request_irq(tx_ring->irq, handler, flags,
+						  tx_ring->name, tx_ring);
+				if (err)
+					return err;
+			}
+		}
 	}
-
 	return 0;
 }
 
@@ -1173,12 +1241,23 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 {
 	int ring;
 	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
 
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		free_irq(sds_ring->irq, sds_ring);
+	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &recv_ctx->sds_rings[ring];
+			free_irq(sds_ring->irq, sds_ring);
+		}
+		if (qlcnic_83xx_check(adapter)) {
+			for (ring = 0; ring < adapter->max_drv_tx_rings;
+			     ring++) {
+				tx_ring = &adapter->tx_ring[ring];
+				if (tx_ring->irq)
+					free_irq(tx_ring->irq, tx_ring);
+			}
+		}
 	}
 }
 
@@ -1186,6 +1265,7 @@ static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
+	u32 capab2;
 	struct qlcnic_host_rds_ring *rds_ring;
 
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
@@ -1197,6 +1277,12 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
+		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
+			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
+	}
+
 	if (qlcnic_fw_create_ctx(adapter))
 		return -EIO;
 
@@ -1229,8 +1315,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 /* Usage: During resume and firmware recovery module.*/
 
-static int
-qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
+int qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int err = 0;
 
@@ -1358,7 +1443,10 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &adapter->recv_ctx->sds_rings[ring];
-			qlcnic_disable_int(sds_ring);
+			if (qlcnic_83xx_check(adapter))
+				writel(1, sds_ring->crb_intr_mask);
+			else
+				qlcnic_disable_int(sds_ring);
 		}
 	}
 
@@ -1486,6 +1574,7 @@ qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
 	netif_device_attach(netdev);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	dev_err(&adapter->pdev->dev, "%s:\n", __func__);
 	return 0;
 }
 
@@ -1529,33 +1618,38 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	int err;
 	struct pci_dev *pdev = adapter->pdev;
 
+	adapter->rx_csum = 1;
 	adapter->ahw->mc_enabled = 0;
-	adapter->ahw->max_mc_count = 38;
+	adapter->ahw->max_mc_count = QLCNIC_MAX_MC_COUNT;
 
 	netdev->netdev_ops	   = &qlcnic_netdev_ops;
-	netdev->watchdog_timeo     = 5*HZ;
+	netdev->watchdog_timeo     = QLCNIC_WATCHDOG_TIMEOUTVALUE * HZ;
 
 	qlcnic_change_mtu(netdev, netdev->mtu);
 
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
 
-	netdev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+			     NETIF_F_IPV6_CSUM | NETIF_F_GRO |
+			     NETIF_F_HW_VLAN_RX);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM |
+				  NETIF_F_IPV6_CSUM);
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
-	if (pci_using_dac)
-		netdev->hw_features |= NETIF_F_HIGHDMA;
+	if (QLCNIC_IS_TSO_CAPABLE(adapter)) {
+		netdev->features |= (NETIF_F_TSO | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO6);
+	}
 
-	netdev->vlan_features = netdev->hw_features;
+	if (pci_using_dac) {
+		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
-		netdev->hw_features |= NETIF_F_HW_VLAN_TX;
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
-		netdev->hw_features |= NETIF_F_LRO;
+	if (qlcnic_vlan_tx_check(adapter))
+		netdev->features |= (NETIF_F_HW_VLAN_TX);
 
-	netdev->features |= netdev->hw_features |
-		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+		netdev->features |= NETIF_F_LRO;
 
 	netdev->irq = adapter->msix_entries[0].vector;
 
@@ -1603,7 +1697,7 @@ void qlcnic_free_tx_rings(struct qlcnic_adapter *adapter)
 int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 			  struct net_device *netdev)
 {
-	int ring, size;
+	int ring, size, vector, index;
 	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_cmd_buffer *cmd_buf_arr;
 
@@ -1630,6 +1724,17 @@ int qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter,
 		tx_ring->cmd_buf_arr = cmd_buf_arr;
 	}
 
+	if (qlcnic_83xx_check(adapter)) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			tx_ring->adapter = adapter;
+			if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+				index = adapter->max_sds_rings + ring;
+				vector = adapter->msix_entries[index].vector;
+				tx_ring->irq = vector;
+			}
+		}
+	}
 	return 0;
 }
 
@@ -1652,7 +1757,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_adapter *adapter = NULL;
 	struct qlcnic_hardware_context *ahw;
 	int err;
-	uint8_t pci_using_dac;
+	uint8_t pci_using_dac = 0;
 	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
@@ -1682,6 +1787,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE824X) {
 		ahw->hw_ops = &qlcnic_hw_ops;
 		ahw->reg_tbl = (u32 *)qlcnic_reg_tbl;
+	} else if (ent->device == PCI_DEVICE_ID_QLOGIC_QLE834X) {
+		qlcnic_83xx_register_map(ahw);
+	} else {
+		goto err_out_free_hw_res;
 	}
 
 	err = qlcnic_setup_pci_map(pdev, ahw);
@@ -1699,6 +1808,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = netdev_priv(netdev);
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
+	adapter->ahw = ahw;
+
+	adapter->qlcnic_wq = create_singlethread_workqueue("qlcnic");
+	if (adapter->qlcnic_wq == NULL) {
+		dev_err(&pdev->dev, "Failed to create workqueue\n");
+		goto err_out_free_netdev;
+	}
 
 	err = qlcnic_alloc_adapter_resources(adapter);
 	if (err)
@@ -1729,6 +1845,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_out_free_hw;
 
 		adapter->flags |= QLCNIC_NEED_FLR;
+	} else if (qlcnic_83xx_check(adapter)) {
+		qlcnic_83xx_check_vf(adapter, ent);
+		adapter->portnum = adapter->ahw->pci_func;
+	} else {
+		dev_err(&pdev->dev,
+			"%s: failed. Please Reboot\n", __func__);
+		goto err_out_free_hw;
 	}
 
 	if (qlcnic_read_mac_addr(adapter))
@@ -1745,6 +1868,11 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_disable_msi;
 
+	if (qlcnic_83xx_check(adapter)) {
+		err = qlcnic_83xx_setup_mbx_intr(adapter);
+		if (err)
+			goto err_out_disable_msi;
+	}
 
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
@@ -1778,6 +1906,11 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 err_out_disable_mbx_intr:
+	if (qlcnic_83xx_check(adapter)) {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			qlcnic_83xx_config_intrpt(adapter, 0);
+		qlcnic_83xx_free_mbx_intr(adapter);
+	}
 
 err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
@@ -1822,6 +1955,12 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
+	if (qlcnic_83xx_check(adapter)) {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			qlcnic_83xx_config_intrpt(adapter, 0);
+		qlcnic_83xx_free_mbx_intr(adapter);
+	}
+
 	qlcnic_detach(adapter);
 
 	if (adapter->npars != NULL)
@@ -1849,11 +1988,14 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 
+	if (adapter->qlcnic_wq) {
+		destroy_workqueue(adapter->qlcnic_wq);
+		adapter->qlcnic_wq = NULL;
+	}
 	qlcnic_free_adapter_resources(adapter);
 	kfree(ahw);
 	free_netdev(netdev);
 }
-
 static int __qlcnic_shutdown(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
@@ -1861,13 +2003,13 @@ static int __qlcnic_shutdown(struct pci_dev *pdev)
 	int retval;
 
 	netif_device_detach(netdev);
-
-	qlcnic_cancel_fw_work(adapter);
+	qlcnic_cancel_idc_work(adapter);
 
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
-	qlcnic_clr_all_drv_state(adapter, 0);
+	if (qlcnic_82xx_check(adapter))
+		qlcnic_clr_all_drv_state(adapter, 0);
 
 	clear_bit(__QLCNIC_RESETTING, &adapter->state);
 
@@ -1921,7 +2063,7 @@ qlcnic_resume(struct pci_dev *pdev)
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 
-	err = adapter->nic_ops->start_firmware(adapter);
+	err = qlcnic_start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "failed to start firmware\n");
 		return err;
@@ -1973,6 +2115,11 @@ static int qlcnic_close(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
 	__qlcnic_down(adapter, netdev);
+	if (qlcnic_83xx_check(adapter)) {
+		qlcnic_83xx_register_nic_idc_func(adapter, 0);
+		cancel_delayed_work_sync(&adapter->idc_aen_work);
+	}
+
 	return 0;
 }
 
@@ -1980,21 +2127,37 @@ void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter)
 {
 	void *head;
 	int i;
+	struct net_device *netdev = adapter->netdev;
+	u32 filter_size = 0;
+	u16 act_pci_func = 0;
 
 	if (adapter->fhash.fmax && adapter->fhash.fhead)
 		return;
 
+	act_pci_func = adapter->ahw->act_pci_func;
 	spin_lock_init(&adapter->mac_learn_lock);
 
-	head = kcalloc(QLCNIC_LB_MAX_FILTERS, sizeof(struct hlist_head),
-								GFP_KERNEL);
+	if (qlcnic_82xx_check(adapter)) {
+		filter_size = QLCNIC_LB_MAX_FILTERS;
+		adapter->fhash.fbucket_size = QLCNIC_LB_BUCKET_SIZE;
+	} else {
+		filter_size = QLC_83XX_LB_MAX_FILTERS;
+		adapter->fhash.fbucket_size = QLC_83XX_LB_BUCKET_SIZE;
+	}
+
+	head = kcalloc(adapter->fhash.fbucket_size,
+		       sizeof(struct hlist_head), GFP_KERNEL);
+
 	if (!head)
 		return;
 
-	adapter->fhash.fmax = QLCNIC_LB_MAX_FILTERS;
+	adapter->fhash.fmax = (filter_size / act_pci_func);
 	adapter->fhash.fhead = head;
 
-	for (i = 0; i < adapter->fhash.fmax; i++)
+	netdev_info(netdev, "active nic func = %d, mac filter size=%d\n",
+		    act_pci_func, adapter->fhash.fmax);
+
+	for (i = 0; i < adapter->fhash.fbucket_size; i++)
 		INIT_HLIST_HEAD(&adapter->fhash.fhead[i]);
 }
 
@@ -2015,6 +2178,9 @@ int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 
 	temp = 0;
 
+	if (qlcnic_83xx_check(adapter))
+		temp = QLCRDX(adapter->ahw, QLC_83XX_ASIC_TEMP);
+
 	if (qlcnic_82xx_check(adapter))
 		temp = QLCRD(adapter, QLCNIC_ASIC_TEMP);
 
@@ -2152,6 +2318,14 @@ static irqreturn_t qlcnic_msix_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t qlcnic_msix_tx_intr(int irq, void *data)
+{
+	struct qlcnic_host_tx_ring *tx_ring = data;
+
+	napi_schedule(&tx_ring->napi);
+	return IRQ_HANDLED;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void qlcnic_poll_controller(struct net_device *netdev)
 {
@@ -2592,28 +2766,15 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 	qlcnic_api_unlock(adapter);
 }
 
-static void
-qlcnic_schedule_work(struct qlcnic_adapter *adapter,
-		work_func_t func, int delay)
+void qlcnic_schedule_work(struct qlcnic_adapter *adapter,
+			  work_func_t func, int delay)
 {
 	if (test_bit(__QLCNIC_AER, &adapter->state))
 		return;
 
 	INIT_DELAYED_WORK(&adapter->fw_work, func);
-	queue_delayed_work(qlcnic_wq, &adapter->fw_work,
-					round_jiffies_relative(delay));
-}
-
-static void
-qlcnic_cancel_fw_work(struct qlcnic_adapter *adapter)
-{
-	while (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		msleep(10);
-
-	if (!adapter->fw_work.work.func)
-		return;
-
-	cancel_delayed_work_sync(&adapter->fw_work);
+	queue_delayed_work(adapter->qlcnic_wq, &adapter->fw_work,
+			   round_jiffies_relative(delay));
 }
 
 static void
@@ -2750,6 +2911,19 @@ reschedule:
 	qlcnic_schedule_work(adapter, qlcnic_fw_poll_work, FW_POLL_DELAY);
 }
 
+struct pci_dev *pci_get_domain_bus_and_slot(int domain, unsigned int bus,
+					    unsigned int devfn)
+{
+	struct pci_dev *dev = NULL;
+
+	while ((dev = pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) != NULL) {
+		if (pci_domain_nr(dev->bus) == domain &&
+		    (dev->bus->number == bus && dev->devfn == devfn))
+			return dev;
+	}
+	return NULL;
+}
+
 static int qlcnic_is_first_func(struct pci_dev *pdev)
 {
 	struct pci_dev *oth_pdev;
@@ -2809,6 +2983,17 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	adapter->msix_entries = NULL;
 	err = qlcnic_setup_intr(adapter, 0);
 
+	if (qlcnic_83xx_check(adapter)) {
+		err = qlcnic_83xx_setup_mbx_intr(adapter);
+		if (err) {
+			dev_err(&adapter->pdev->dev,
+				"failed to setup mbx interrupt\n");
+			qlcnic_clr_all_drv_state(adapter, 1);
+			clear_bit(__QLCNIC_AER, &adapter->state);
+			goto done;
+		}
+	}
+
 	if (netif_running(netdev)) {
 		err = qlcnic_attach(adapter);
 		if (err) {
@@ -2849,6 +3034,12 @@ static pci_ers_result_t qlcnic_io_error_detected(struct pci_dev *pdev,
 	if (netif_running(netdev))
 		qlcnic_down(adapter, netdev);
 
+	if (qlcnic_83xx_check(adapter)) {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			qlcnic_83xx_config_intrpt(adapter, 0);
+		qlcnic_83xx_free_mbx_intr(adapter);
+	}
+
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
 
@@ -3012,21 +3203,34 @@ int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
 
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 {
+	int err;
 	struct net_device *netdev = adapter->netdev;
-	int err = 0;
-
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return -EBUSY;
 
+	rtnl_lock();
 	netif_device_detach(netdev);
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
+
+	if (qlcnic_83xx_check(adapter)) {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			qlcnic_83xx_config_intrpt(adapter, 0);
+		qlcnic_83xx_free_mbx_intr(adapter);
+	}
+
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
+	err = adapter->ahw->hw_ops->setup_intr(adapter, data);
+	if (err)
+		dev_err(&adapter->pdev->dev,
+			"failed setting max_rss; rss disabled\n");
 
-	if (qlcnic_enable_msix(adapter, data)) {
-		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
-		qlcnic_enable_msi_legacy(adapter);
+	if (qlcnic_83xx_check(adapter)) {
+		err = qlcnic_83xx_setup_mbx_intr(adapter);
+		if (err) {
+			dev_err(&adapter->pdev->dev,
+				"failed to setup mbx interrupt\n");
+			goto done;
+		}
 	}
 
 	if (netif_running(netdev)) {
@@ -3040,8 +3244,9 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
 	}
  done:
 	netif_device_attach(netdev);
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	rtnl_unlock();
 	return err;
+
 }
 
 static int
@@ -3911,9 +4116,9 @@ static void qlcnic_82xx_remove_sysfs(struct qlcnic_adapter *adapter)
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
 
-static void
-qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
-			struct net_device *dev, unsigned long event)
+static void qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
+				     struct net_device *dev,
+				     unsigned long event)
 {
 	struct in_device *indev;
 
@@ -3924,12 +4129,12 @@ qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	for_ifa(indev) {
 		switch (event) {
 		case NETDEV_UP:
-			qlcnic_config_ipaddr(adapter,
-					ifa->ifa_address, QLCNIC_IP_UP);
+			qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+					     QLCNIC_IP_UP);
 			break;
 		case NETDEV_DOWN:
-			qlcnic_config_ipaddr(adapter,
-					ifa->ifa_address, QLCNIC_IP_DOWN);
+			qlcnic_config_ipaddr(adapter, ifa->ifa_address,
+					     QLCNIC_IP_DOWN);
 			break;
 		default:
 			break;
@@ -3939,8 +4144,8 @@ qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 	in_dev_put(indev);
 }
 
-static void
-qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
+static void qlcnic_restore_indev_addr(struct net_device *netdev,
+				      unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct net_device *dev;
@@ -4021,9 +4226,11 @@ recheck:
 	switch (event) {
 	case NETDEV_UP:
 		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_UP);
+
 		break;
 	case NETDEV_DOWN:
 		qlcnic_config_ipaddr(adapter, ifa->ifa_address, QLCNIC_IP_DOWN);
+
 		break;
 	default:
 		break;
@@ -4071,12 +4278,6 @@ static int __init qlcnic_init_module(void)
 
 	printk(KERN_INFO "%s\n", qlcnic_driver_string);
 
-	qlcnic_wq = create_singlethread_workqueue("qlcnic");
-	if (qlcnic_wq == NULL) {
-		printk(KERN_ERR "qlcnic: cannot create workqueue\n");
-		return -ENOMEM;
-	}
-
 #ifdef CONFIG_INET
 	register_netdevice_notifier(&qlcnic_netdev_cb);
 	register_inetaddr_notifier(&qlcnic_inetaddr_cb);
@@ -4088,7 +4289,6 @@ static int __init qlcnic_init_module(void)
 		unregister_inetaddr_notifier(&qlcnic_inetaddr_cb);
 		unregister_netdevice_notifier(&qlcnic_netdev_cb);
 #endif
-		destroy_workqueue(qlcnic_wq);
 	}
 
 	return ret;
@@ -4098,14 +4298,12 @@ module_init(qlcnic_init_module);
 
 static void __exit qlcnic_exit_module(void)
 {
-
 	pci_unregister_driver(&qlcnic_driver);
 
 #ifdef CONFIG_INET
 	unregister_inetaddr_notifier(&qlcnic_inetaddr_cb);
 	unregister_netdevice_notifier(&qlcnic_netdev_cb);
 #endif
-	destroy_workqueue(qlcnic_wq);
 }
 
 module_exit(qlcnic_exit_module);
-- 
1.7.1
