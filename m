From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 09/29] fm10k: Add netdev
Date: Sat, 20 Sep 2014 19:48:10 -0400
Message-ID: <20140920234804.2977.8975.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34030 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbaITX4x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:56:53 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have the ability to configure the basic settings on the device
we can start allocating and configuring a netdev for the interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile       |    2 
 drivers/net/ethernet/intel/fm10k/fm10k.h        |   92 +++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   98 ++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |  230 +++++++++++++++++++++++
 4 files changed, 418 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index 0904bcb..ee4e415 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -28,5 +28,5 @@
 obj-$(CONFIG_FM10K) += fm10k.o
 
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
-	      fm10k_pf.o \
+	      fm10k_netdev.o fm10k_pf.o \
 	      fm10k_mbx.o fm10k_tlv.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 3da3a99..fa3e5e1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -27,15 +27,102 @@
 #include <linux/if_vlan.h>
 #include <linux/pci.h>
 
-#include "fm10k_common.h"
+#include "fm10k_pf.h"
+
+#define FM10K_MAX_JUMBO_FRAME_SIZE	15358	/* Maximum supported size 15K */
+
+enum fm10k_ring_f_enum {
+	RING_F_RSS,
+	RING_F_QOS,
+	RING_F_ARRAY_SIZE  /* must be last in enum set */
+};
+
+struct fm10k_ring_feature {
+	u16 limit;	/* upper limit on feature indices */
+	u16 indices;	/* current value of indices */
+	u16 mask;	/* Mask used for feature to ring mapping */
+	u16 offset;	/* offset to start of feature */
+};
+
+#define fm10k_vxlan_port_for_each(vp, intfc) \
+	list_for_each_entry(vp, &(intfc)->vxlan_port, list)
+struct fm10k_vxlan_port {
+	struct list_head	list;
+	sa_family_t		sa_family;
+	__be16			port;
+};
 
 struct fm10k_intfc {
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	struct net_device *netdev;
 	struct pci_dev *pdev;
+	unsigned long state;
+
+	u32 flags;
+#define FM10K_FLAG_RESET_REQUESTED		(u32)(1 << 0)
+#define FM10K_FLAG_RSS_FIELD_IPV4_UDP		(u32)(1 << 1)
+#define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(1 << 2)
+#define FM10K_FLAG_RX_TS_ENABLED		(u32)(1 << 3)
+#define FM10K_FLAG_SWPRI_CONFIG			(u32)(1 << 4)
+	int xcast_mode;
+
+	u64 rx_overrun_pf;
+	u64 rx_overrun_vf;
 
+	struct fm10k_ring_feature ring_feature[RING_F_ARRAY_SIZE];
+
+	struct fm10k_hw_stats stats;
 	struct fm10k_hw hw;
 	u32 __iomem *uc_addr;
+	u16 msg_enable;
+
+	u32 reta[FM10K_RETA_SIZE];
+	u32 rssrk[FM10K_RSSRK_SIZE];
+
+	/* VXLAN port tracking information */
+	struct list_head vxlan_port;
+
+#if defined(HAVE_DCBNL_IEEE) && defined(CONFIG_DCB)
+	u8 pfc_en;
+#endif
+	u8 rx_pause;
+
+	/* GLORT resources in use by PF */
+	u16 glort;
+	u16 glort_count;
+
+	/* VLAN ID for updating multicast/unicast lists */
+	u16 vid;
+};
+
+enum fm10k_state_t {
+	__FM10K_RESETTING,
+	__FM10K_DOWN,
+	__FM10K_MBX_LOCK,
+	__FM10K_LINK_DOWN,
 };
 
+static inline void fm10k_mbx_lock(struct fm10k_intfc *interface)
+{
+	/* busy loop if we cannot obtain the lock as some calls
+	 * such as ndo_set_rx_mode may be made in atomic context
+	 */
+	while (test_and_set_bit(__FM10K_MBX_LOCK, &interface->state))
+		udelay(20);
+}
+
+static inline void fm10k_mbx_unlock(struct fm10k_intfc *interface)
+{
+	/* flush memory to make sure state is correct */
+	smp_mb__before_clear_bit();
+	clear_bit(__FM10K_MBX_LOCK, &interface->state);
+}
+
+static inline int fm10k_mbx_trylock(struct fm10k_intfc *interface)
+{
+	return !test_and_set_bit(__FM10K_MBX_LOCK, &interface->state);
+}
+
 /* main */
 extern char fm10k_driver_name[];
 extern const char fm10k_driver_version[];
@@ -43,4 +130,7 @@ extern const char fm10k_driver_version[];
 /* PCI */
 int fm10k_register_pci_driver(void);
 void fm10k_unregister_pci_driver(void);
+
+/* Netdev */
+struct net_device *fm10k_alloc_netdev(void);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
new file mode 100644
index 0000000..9a4f3a6
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -0,0 +1,98 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k.h"
+
+static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
+{
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static int fm10k_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < 68 || new_mtu > FM10K_MAX_JUMBO_FRAME_SIZE)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
+static int fm10k_set_mac(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	s32 err = 0;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (!err) {
+		ether_addr_copy(dev->dev_addr, addr->sa_data);
+		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+	}
+
+	return err;
+}
+
+static void fm10k_set_rx_mode(struct net_device *dev)
+{
+}
+
+static const struct net_device_ops fm10k_netdev_ops = {
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_start_xmit		= fm10k_xmit_frame,
+	.ndo_set_mac_address	= fm10k_set_mac,
+	.ndo_change_mtu		= fm10k_change_mtu,
+	.ndo_set_rx_mode	= fm10k_set_rx_mode,
+};
+
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+
+struct net_device *fm10k_alloc_netdev(void)
+{
+	struct fm10k_intfc *interface;
+	struct net_device *dev;
+
+	dev = alloc_etherdev(sizeof(struct fm10k_intfc));
+	if (!dev)
+		return NULL;
+
+	/* set net device and ethtool ops */
+	dev->netdev_ops = &fm10k_netdev_ops;
+
+	/* configure default debug level */
+	interface = netdev_priv(dev);
+	interface->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+
+	/* configure default features */
+	dev->features |= NETIF_F_SG;
+
+	/* all features defined to this point should be changeable */
+	dev->hw_features |= dev->features;
+
+	/* configure VLAN features */
+	dev->vlan_features |= dev->features;
+
+	/* configure tunnel offloads */
+	dev->hw_enc_features = NETIF_F_SG;
+
+	return dev;
+}
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 6d5e33c..5fcbd1d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -22,6 +22,10 @@
 
 #include "fm10k.h"
 
+static const struct fm10k_info *fm10k_info_tbl[] = {
+	[fm10k_device_pf] = &fm10k_pf_info,
+};
+
 /**
  * fm10k_pci_tbl - PCI Device ID Table
  *
@@ -32,7 +36,7 @@
  *   Class, Class Mask, private data (not used) }
  */
 static const struct pci_device_id fm10k_pci_tbl[] = {
-	{ PCI_VDEVICE(INTEL, FM10K_DEV_ID_PF) },
+	{ PCI_VDEVICE(INTEL, FM10K_DEV_ID_PF), fm10k_device_pf },
 	/* required last entry */
 	{ 0, }
 };
@@ -62,12 +66,153 @@ u32 fm10k_read_reg(struct fm10k_hw *hw, int reg)
 		return ~value;
 
 	value = readl(&hw_addr[reg]);
-	if (!(~value) && (!reg || !(~readl(hw_addr))))
+	if (!(~value) && (!reg || !(~readl(hw_addr)))) {
+		struct fm10k_intfc *interface = hw->back;
+		struct net_device *netdev = interface->netdev;
+
 		hw->hw_addr = NULL;
+		netif_device_detach(netdev);
+		netdev_err(netdev, "PCIe link lost, device now detached\n");
+	}
 
 	return value;
 }
 
+static int fm10k_hw_ready(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+
+	fm10k_write_flush(hw);
+
+	return FM10K_REMOVED(hw->hw_addr) ? -ENODEV : 0;
+}
+
+/**
+ * fm10k_sw_init - Initialize general software structures
+ * @interface: host interface private structure to initialize
+ *
+ * fm10k_sw_init initializes the interface private data structure.
+ * Fields are initialized based on PCI device information and
+ * OS network device settings (MTU size).
+ **/
+static int fm10k_sw_init(struct fm10k_intfc *interface,
+			 const struct pci_device_id *ent)
+{
+	static const u32 seed[FM10K_RSSRK_SIZE] = { 0xda565a6d, 0xc20e5b25,
+						    0x3d256741, 0xb08fa343,
+						    0xcb2bcad0, 0xb4307bae,
+						    0xa32dcb77, 0x0cf23080,
+						    0x3bb7426a, 0xfa01acbe };
+	const struct fm10k_info *fi = fm10k_info_tbl[ent->driver_data];
+	struct fm10k_hw *hw = &interface->hw;
+	struct pci_dev *pdev = interface->pdev;
+	struct net_device *netdev = interface->netdev;
+	unsigned int rss;
+	int err;
+
+	/* initialize back pointer */
+	hw->back = interface;
+	hw->hw_addr = interface->uc_addr;
+
+	/* PCI config space info */
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->revision_id = pdev->revision;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_device_id = pdev->subsystem_device;
+
+	/* Setup hw api */
+	memcpy(&hw->mac.ops, fi->mac_ops, sizeof(hw->mac.ops));
+	hw->mac.type = fi->mac;
+
+	/* Set common capability flags and settings */
+	rss = min_t(int, FM10K_MAX_RSS_INDICES, num_online_cpus());
+	interface->ring_feature[RING_F_RSS].limit = rss;
+	fi->get_invariants(hw);
+
+	/* pick up the PCIe bus settings for reporting later */
+	if (hw->mac.ops.get_bus_info)
+		hw->mac.ops.get_bus_info(hw);
+
+	/* limit the usable DMA range */
+	if (hw->mac.ops.set_dma_mask)
+		hw->mac.ops.set_dma_mask(hw, dma_get_mask(&pdev->dev));
+
+	/* update netdev with DMA restrictions */
+	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32)) {
+		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
+
+	/* reset and initialize the hardware so it is in a known state */
+	err = hw->mac.ops.reset_hw(hw) ? : hw->mac.ops.init_hw(hw);
+	if (err) {
+		dev_err(&pdev->dev, "init_hw failed: %d\n", err);
+		return err;
+	}
+
+	/* initialize hardware statistics */
+	hw->mac.ops.update_hw_stats(hw, &interface->stats);
+
+	/* Start with random Ethernet address */
+	eth_random_addr(hw->mac.addr);
+
+	/* Initialize MAC address from hardware */
+	err = hw->mac.ops.read_mac_addr(hw);
+	if (err) {
+		dev_warn(&pdev->dev,
+			 "Failed to obtain MAC address defaulting to random\n");
+		/* tag address assignment as random */
+		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+	}
+
+	memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, hw->mac.addr, netdev->addr_len);
+
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
+		dev_err(&pdev->dev, "Invalid MAC Address\n");
+		return -EIO;
+	}
+
+	/* Only the PF can support VXLAN and NVGRE offloads */
+	if (hw->mac.type != fm10k_mac_pf) {
+		netdev->hw_enc_features = 0;
+		netdev->features &= ~NETIF_F_GSO_UDP_TUNNEL;
+		netdev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
+	}
+
+	/* initialize vxlan_port list */
+	INIT_LIST_HEAD(&interface->vxlan_port);
+
+	/* initialize RSS key */
+	memcpy(interface->rssrk, seed, sizeof(seed));
+
+	/* Start off interface as being down */
+	set_bit(__FM10K_DOWN, &interface->state);
+
+	return 0;
+}
+
+static void fm10k_slot_warn(struct fm10k_intfc *interface)
+{
+	struct device *dev = &interface->pdev->dev;
+	struct fm10k_hw *hw = &interface->hw;
+
+	if (hw->mac.ops.is_slot_appropriate(hw))
+		return;
+
+	dev_warn(dev,
+		 "For optimal performance, a %s %s slot is recommended.\n",
+		 (hw->bus_caps.width == fm10k_bus_width_pcie_x1 ? "x1" :
+		  hw->bus_caps.width == fm10k_bus_width_pcie_x4 ? "x4" :
+		  "x8"),
+		 (hw->bus_caps.speed == fm10k_bus_speed_2500 ? "2.5GT/s" :
+		  hw->bus_caps.speed == fm10k_bus_speed_5000 ? "5.0GT/s" :
+		  "8.0GT/s"));
+	dev_warn(dev,
+		 "A slot with more lanes and/or higher speed is suggested.\n");
+}
+
 /**
  * fm10k_probe - Device Initialization Routine
  * @pdev: PCI device information struct
@@ -82,6 +227,9 @@ u32 fm10k_read_reg(struct fm10k_hw *hw, int reg)
 static int fm10k_probe(struct pci_dev *pdev,
 		       const struct pci_device_id *ent)
 {
+	struct net_device *netdev;
+	struct fm10k_intfc *interface;
+	struct fm10k_hw *hw;
 	int err;
 	u64 dma_mask;
 
@@ -122,8 +270,75 @@ static int fm10k_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
+	netdev = fm10k_alloc_netdev();
+	if (!netdev) {
+		err = -ENOMEM;
+		goto err_alloc_netdev;
+	}
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	interface = netdev_priv(netdev);
+	pci_set_drvdata(pdev, interface);
+
+	interface->netdev = netdev;
+	interface->pdev = pdev;
+	hw = &interface->hw;
+
+	interface->uc_addr = ioremap(pci_resource_start(pdev, 0),
+				     FM10K_UC_ADDR_SIZE);
+	if (!interface->uc_addr) {
+		err = -EIO;
+		goto err_ioremap;
+	}
+
+	err = fm10k_sw_init(interface, ent);
+	if (err)
+		goto err_sw_init;
+
+	/* final check of hardware state before registering the interface */
+	err = fm10k_hw_ready(interface);
+	if (err)
+		goto err_register;
+
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+	/* carrier off reporting is important to ethtool even BEFORE open */
+	netif_carrier_off(netdev);
+
+	/* stop all the transmit queues from transmitting until link is up */
+	netif_tx_stop_all_queues(netdev);
+
+	/* print bus type/speed/width info */
+	dev_info(&pdev->dev, "(PCI Express:%s Width: %s Payload: %s)\n",
+		 (hw->bus.speed == fm10k_bus_speed_8000 ? "8.0GT/s" :
+		  hw->bus.speed == fm10k_bus_speed_5000 ? "5.0GT/s" :
+		  hw->bus.speed == fm10k_bus_speed_2500 ? "2.5GT/s" :
+		  "Unknown"),
+		 (hw->bus.width == fm10k_bus_width_pcie_x8 ? "x8" :
+		  hw->bus.width == fm10k_bus_width_pcie_x4 ? "x4" :
+		  hw->bus.width == fm10k_bus_width_pcie_x1 ? "x1" :
+		  "Unknown"),
+		 (hw->bus.payload == fm10k_bus_payload_128 ? "128B" :
+		  hw->bus.payload == fm10k_bus_payload_256 ? "256B" :
+		  hw->bus.payload == fm10k_bus_payload_512 ? "512B" :
+		  "Unknown"));
+
+	/* print warning for non-optimal configurations */
+	fm10k_slot_warn(interface);
+
 	return 0;
 
+err_register:
+err_sw_init:
+	iounmap(interface->uc_addr);
+err_ioremap:
+	free_netdev(netdev);
+err_alloc_netdev:
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -141,6 +356,17 @@ err_dma:
  **/
 static void fm10k_remove(struct pci_dev *pdev)
 {
+	struct fm10k_intfc *interface = pci_get_drvdata(pdev);
+	struct net_device *netdev = interface->netdev;
+
+	/* free netdev, this may bounce the interrupts due to setup_tc */
+	if (netdev->reg_state == NETREG_REGISTERED)
+		unregister_netdev(netdev);
+
+	iounmap(interface->uc_addr);
+
+	free_netdev(netdev);
+
 	pci_release_selected_regions(pdev,
 				     pci_select_bars(pdev, IORESOURCE_MEM));
 
