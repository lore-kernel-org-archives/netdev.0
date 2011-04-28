From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [NEXT PATCH 2/3] qlcnic: support rcv ring configuration through ethtool
Date: Wed, 27 Apr 2011 17:43:45 -0700
Message-ID: <1303951426-4341-3-git-send-email-amit.salecha@qlogic.com>
References: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5275 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757160Ab1D0XoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 19:44:03 -0400
In-Reply-To: <1303951426-4341-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Support ethtool command ETHTOOL_GCHANNELS and ETHTOOL_SCHANNELS.
o Number of rcv rings configuration depend upon number of msix vector.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    9 ++-
 drivers/net/qlcnic/qlcnic_ethtool.c |   45 +++++++++++
 drivers/net/qlcnic/qlcnic_main.c    |  146 +++++++++++++++++++++++++++-------
 3 files changed, 167 insertions(+), 33 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f7acb80..bdebbf5 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -118,7 +118,6 @@
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
 
 #define NUM_RCV_DESC_RINGS	3
-#define NUM_STS_DESC_RINGS	4
 
 #define RCV_RING_NORMAL 0
 #define RCV_RING_JUMBO	1
@@ -871,7 +870,9 @@ struct qlcnic_ipaddr {
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
-#define MSIX_ENTRIES_PER_ADAPTER	NUM_STS_DESC_RINGS
+#define QLCNIC_DEF_NUM_STS_DESC_RINGS	4
+#define QLCNIC_MIN_NUM_RSS_RINGS	2
+#define QLCNIC_MIN_NUM_TX_DESC_RINGS	1
 #define QLCNIC_MSIX_TBL_SPACE		8192
 #define QLCNIC_PCI_REG_MSIX_TBL 	0x44
 #define QLCNIC_MSIX_TBL_PGSIZE		4096
@@ -987,7 +988,7 @@ struct qlcnic_adapter {
 	void __iomem	*crb_int_state_reg;
 	void __iomem	*isr_int_vec;
 
-	struct msix_entry msix_entries[MSIX_ENTRIES_PER_ADAPTER];
+	struct msix_entry *msix_entries;
 
 	struct delayed_work fw_work;
 
@@ -1262,6 +1263,8 @@ u32 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val);
+int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
 
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index de65847..4f3a367 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -474,6 +474,49 @@ qlcnic_set_ringparam(struct net_device *dev,
 	return qlcnic_reset_context(adapter);
 }
 
+static void qlcnic_get_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	channel->max_rx = rounddown_pow_of_two(min_t(int,
+			adapter->max_rx_ques, num_online_cpus()));
+	channel->max_tx = adapter->max_tx_ques;
+
+	channel->rx_count = adapter->max_sds_rings;
+	channel->tx_count = QLCNIC_MIN_NUM_TX_DESC_RINGS;
+}
+
+static int qlcnic_set_channels(struct net_device *dev,
+		struct ethtool_channels *channel)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(dev);
+	int err;
+
+	if (channel->other_count || channel->combined_count)
+		return -EOPNOTSUPP;
+
+	if (channel->tx_count &&
+		(channel->tx_count != QLCNIC_MIN_NUM_TX_DESC_RINGS)) {
+		netdev_info(dev, "valid value for tx_count 0x%x\n",
+				QLCNIC_MIN_NUM_TX_DESC_RINGS);
+		return -EINVAL;
+	}
+
+	if (channel->rx_count == adapter->max_sds_rings)
+		return 0;
+
+
+	err = qlcnic_validate_max_rss(dev, channel->max_rx, channel->rx_count);
+	if (err)
+		return err;
+
+	err = qlcnic_set_max_rss(adapter, channel->rx_count);
+	netdev_info(dev, "allocated 0x%x sds rings\n",
+				 adapter->max_sds_rings);
+	return err;
+}
+
 static void
 qlcnic_get_pauseparam(struct net_device *netdev,
 			  struct ethtool_pauseparam *pause)
@@ -949,6 +992,8 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.get_eeprom = qlcnic_get_eeprom,
 	.get_ringparam = qlcnic_get_ringparam,
 	.set_ringparam = qlcnic_set_ringparam,
+	.get_channels = qlcnic_get_channels,
+	.set_channels = qlcnic_set_channels,
 	.get_pauseparam = qlcnic_get_pauseparam,
 	.set_pauseparam = qlcnic_set_pauseparam,
 	.get_wol = qlcnic_get_wol,
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 6e61951..d6cc4d4 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -18,6 +18,7 @@
 #include <linux/inetdevice.h>
 #include <linux/sysfs.h>
 #include <linux/aer.h>
+#include <linux/log2.h>
 
 MODULE_DESCRIPTION("QLogic 1/10 GbE Converged/Intelligent Ethernet Driver");
 MODULE_LICENSE("GPL");
@@ -350,39 +351,17 @@ static struct qlcnic_nic_template qlcnic_vf_ops = {
 	.start_firmware = qlcnicvf_start_firmware
 };
 
-static void
-qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+static int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 {
-	const struct qlcnic_legacy_intr_set *legacy_intrp;
 	struct pci_dev *pdev = adapter->pdev;
-	int err, num_msix;
-
-	if (adapter->msix_supported) {
-		num_msix = (num_online_cpus() >= MSIX_ENTRIES_PER_ADAPTER) ?
-			MSIX_ENTRIES_PER_ADAPTER : 2;
-	} else
-		num_msix = 1;
+	int err = -1;
 
 	adapter->max_sds_rings = 1;
-
 	adapter->flags &= ~(QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED);
-
-	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
-
-	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
-	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
-			legacy_intrp->tgt_status_reg);
-	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter,
-			legacy_intrp->tgt_mask_reg);
-	adapter->isr_int_vec = qlcnic_get_ioaddr(adapter, ISR_INT_VECTOR);
-
-	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter,
-			ISR_INT_STATE_REG);
-
 	qlcnic_set_msix_bit(pdev, 0);
 
 	if (adapter->msix_supported) {
-
+ enable_msix:
 		qlcnic_init_msix_entries(adapter, num_msix);
 		err = pci_enable_msix(pdev, adapter->msix_entries, num_msix);
 		if (err == 0) {
@@ -392,14 +371,22 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 			adapter->max_sds_rings = num_msix;
 
 			dev_info(&pdev->dev, "using msi-x interrupts\n");
-			return;
+			return err;
 		}
+		if (err > 0) {
+			num_msix = rounddown_pow_of_two(err);
+			if (num_msix)
+				goto enable_msix;
+		}
+	}
+	return err;
+}
 
-		if (err > 0)
-			pci_disable_msix(pdev);
 
-		/* fall through for msi */
-	}
+static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
+{
+	const struct qlcnic_legacy_intr_set *legacy_intrp;
+	struct pci_dev *pdev = adapter->pdev;
 
 	if (use_msi && !pci_enable_msi(pdev)) {
 		adapter->flags |= QLCNIC_MSI_ENABLED;
@@ -410,11 +397,41 @@ qlcnic_setup_intr(struct qlcnic_adapter *adapter)
 		return;
 	}
 
+	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
+
+	adapter->int_vec_bit = legacy_intrp->int_vec_bit;
+	adapter->tgt_status_reg = qlcnic_get_ioaddr(adapter,
+			legacy_intrp->tgt_status_reg);
+	adapter->tgt_mask_reg = qlcnic_get_ioaddr(adapter,
+			legacy_intrp->tgt_mask_reg);
+	adapter->isr_int_vec = qlcnic_get_ioaddr(adapter, ISR_INT_VECTOR);
+
+	adapter->crb_int_state_reg = qlcnic_get_ioaddr(adapter,
+			ISR_INT_STATE_REG);
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
 }
 
 static void
+qlcnic_setup_intr(struct qlcnic_adapter *adapter)
+{
+	int num_msix;
+
+	if (adapter->msix_supported) {
+		num_msix = (num_online_cpus() >=
+			QLCNIC_DEF_NUM_STS_DESC_RINGS) ?
+			QLCNIC_DEF_NUM_STS_DESC_RINGS :
+			QLCNIC_MIN_NUM_RSS_RINGS;
+	} else
+		num_msix = 1;
+
+	if (!qlcnic_enable_msix(adapter, num_msix))
+		return;
+
+	qlcnic_enable_msi_legacy(adapter);
+}
+
+static void
 qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
 {
 	if (adapter->flags & QLCNIC_MSIX_ENABLED)
@@ -1493,6 +1510,19 @@ static int qlcnic_set_dma_mask(struct pci_dev *pdev, u8 *pci_using_dac)
 	return 0;
 }
 
+static int
+qlcnic_alloc_msix_entries(struct qlcnic_adapter *adapter, u16 count)
+{
+	adapter->msix_entries = kcalloc(count, sizeof(struct msix_entry),
+					GFP_KERNEL);
+
+	if (adapter->msix_entries)
+		return 0;
+
+	dev_err(&adapter->pdev->dev, "failed allocating msix_entries\n");
+	return -ENOMEM;
+}
+
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1587,6 +1617,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	qlcnic_clear_stats(adapter);
 
+	err = qlcnic_alloc_msix_entries(adapter, adapter->max_rx_ques);
+	if (err)
+		goto err_out_decr_ref;
+
 	qlcnic_setup_intr(adapter);
 
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
@@ -1615,6 +1649,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 err_out_disable_msi:
 	qlcnic_teardown_intr(adapter);
+	kfree(adapter->msix_entries);
 
 err_out_decr_ref:
 	qlcnic_clr_all_drv_state(adapter, 0);
@@ -1666,6 +1701,7 @@ static void __devexit qlcnic_remove(struct pci_dev *pdev)
 	qlcnic_free_lb_filters_mem(adapter);
 
 	qlcnic_teardown_intr(adapter);
+	kfree(adapter->msix_entries);
 
 	qlcnic_remove_diag_entries(adapter);
 
@@ -3299,6 +3335,56 @@ static struct device_attribute dev_attr_diag_mode = {
 	.store = qlcnic_store_diag_mode,
 };
 
+int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val)
+{
+	if (!use_msi_x && !use_msi) {
+		netdev_info(netdev, "no msix or msi support, hence no rss\n");
+		return -EINVAL;
+	}
+
+	if ((val > max_hw) || (val <  2) || !is_power_of_2(val)) {
+		netdev_info(netdev, "rss_ring valid range [2 - %x] in "
+			" powers of 2\n", max_hw);
+		return -EINVAL;
+	}
+	return 0;
+
+}
+
+int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err = 0;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EBUSY;
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		__qlcnic_down(adapter, netdev);
+	qlcnic_detach(adapter);
+	qlcnic_teardown_intr(adapter);
+
+	if (qlcnic_enable_msix(adapter, data)) {
+		netdev_info(netdev, "failed setting max_rss; rss disabled\n");
+		qlcnic_enable_msi_legacy(adapter);
+	}
+
+	if (netif_running(netdev)) {
+		err = qlcnic_attach(adapter);
+		if (err)
+			goto done;
+		err = __qlcnic_up(adapter, netdev);
+		if (err)
+			goto done;
+		qlcnic_restore_indev_addr(netdev, NETDEV_UP);
+	}
+ done:
+	netif_device_attach(netdev);
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return err;
+}
+
 static int
 qlcnic_sysfs_validate_crb(struct qlcnic_adapter *adapter,
 		loff_t offset, size_t size)
-- 
1.6.3.3

