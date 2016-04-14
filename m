From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 2/2] intel: ixgbevf: Support Windows hosts (Hyper-V)
Date: Thu, 14 Apr 2016 16:55:42 -0700
Message-ID: <1460678142-30353-2-git-send-email-kys@microsoft.com>
References: <1460678121-30308-1-git-send-email-kys@microsoft.com>
 <1460678142-30353-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
 eli@mellanox.com, jackm@mellanox.com, yevgenyp@mellanox.com,
 john.ronciak@intel.com, intel-wired-lan@linuxonhyperv.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460678142-30353-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Hyper-V, the VF/PF communication is a via software mediated path
as opposed to the hardware mailbox. Make the necessary
adjustments to support Hyper-V.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   11 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   56 ++++++---
 drivers/net/ethernet/intel/ixgbevf/mbx.c          |   12 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           |  138 +++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |    2 +
 5 files changed, 201 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 5ac60ee..f8d2a0b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -460,9 +460,13 @@ enum ixbgevf_state_t {
 
 enum ixgbevf_boards {
 	board_82599_vf,
+	board_82599_vf_hv,
 	board_X540_vf,
+	board_X540_vf_hv,
 	board_X550_vf,
+	board_X550_vf_hv,
 	board_X550EM_x_vf,
+	board_X550EM_x_vf_hv,
 };
 
 enum ixgbevf_xcast_modes {
@@ -477,6 +481,13 @@ extern const struct ixgbevf_info ixgbevf_X550_vf_info;
 extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_info;
 extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 
+
+extern const struct ixgbevf_info ixgbevf_82599_vf_hv_info;
+extern const struct ixgbevf_info ixgbevf_X540_vf_hv_info;
+extern const struct ixgbevf_info ixgbevf_X550_vf_hv_info;
+extern const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info;
+extern const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops;
+
 /* needed by ethtool.c */
 extern const char ixgbevf_driver_name[];
 extern const char ixgbevf_driver_version[];
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 007cbe0..4a0ffac 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -49,6 +49,7 @@
 #include <linux/if.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <asm/mshyperv.h>
 
 #include "ixgbevf.h"
 
@@ -62,10 +63,14 @@ static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2015 Intel Corporation.";
 
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
-	[board_82599_vf] = &ixgbevf_82599_vf_info,
-	[board_X540_vf]  = &ixgbevf_X540_vf_info,
-	[board_X550_vf]  = &ixgbevf_X550_vf_info,
-	[board_X550EM_x_vf] = &ixgbevf_X550EM_x_vf_info,
+	[board_82599_vf]	= &ixgbevf_82599_vf_info,
+	[board_82599_vf_hv]	= &ixgbevf_82599_vf_hv_info,
+	[board_X540_vf]		= &ixgbevf_X540_vf_info,
+	[board_X540_vf_hv]	= &ixgbevf_X540_vf_hv_info,
+	[board_X550_vf]		= &ixgbevf_X550_vf_info,
+	[board_X550_vf_hv]	= &ixgbevf_X550_vf_hv_info,
+	[board_X550EM_x_vf]	= &ixgbevf_X550EM_x_vf_info,
+	[board_X550EM_x_vf_hv]	= &ixgbevf_X550EM_x_vf_hv_info,
 };
 
 /* ixgbevf_pci_tbl - PCI Device ID Table
@@ -78,9 +83,13 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
  */
 static const struct pci_device_id ixgbevf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF_HV), board_82599_vf_hv },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF_HV), board_X540_vf_hv },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF), board_X550_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550_VF_HV), board_X550_vf_hv },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF), board_X550EM_x_vf },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X550EM_X_VF_HV), board_X550EM_x_vf_hv},
 	/* required last entry */
 	{0, }
 };
@@ -1809,12 +1818,13 @@ static int ixgbevf_vlan_rx_add_vid(struct net_device *netdev,
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err;
+	int err = 0;
 
 	spin_lock_bh(&adapter->mbx_lock);
 
 	/* add VID to filter table */
-	err = hw->mac.ops.set_vfta(hw, vid, 0, true);
+	if (hw->mac.ops.set_vfta)
+		err = hw->mac.ops.set_vfta(hw, vid, 0, true);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -1835,12 +1845,13 @@ static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev,
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err;
+	int err = 0;
 
 	spin_lock_bh(&adapter->mbx_lock);
 
 	/* remove VID from filter table */
-	err = hw->mac.ops.set_vfta(hw, vid, 0, false);
+	if (hw->mac.ops.set_vfta)
+		err = hw->mac.ops.set_vfta(hw, vid, 0, false);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -1873,14 +1884,16 @@ static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
 		struct netdev_hw_addr *ha;
 
 		netdev_for_each_uc_addr(ha, netdev) {
-			hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
+			if (hw->mac.ops.set_uc_addr)
+				hw->mac.ops.set_uc_addr(hw, ++count, ha->addr);
 			udelay(200);
 		}
 	} else {
 		/* If the list is empty then send message to PF driver to
 		 * clear all MAC VLANs on this VF.
 		 */
-		hw->mac.ops.set_uc_addr(hw, 0, NULL);
+		if (hw->mac.ops.set_uc_addr)
+			hw->mac.ops.set_uc_addr(hw, 0, NULL);
 	}
 
 	return count;
@@ -1908,10 +1921,13 @@ static void ixgbevf_set_rx_mode(struct net_device *netdev)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	hw->mac.ops.update_xcast_mode(hw, netdev, xcast_mode);
+	if (hw->mac.ops.update_mc_addr_list)
+		if (hw->mac.ops.update_xcast_mode)
+			hw->mac.ops.update_xcast_mode(hw, netdev, xcast_mode);
 
 	/* reprogram multicast list */
-	hw->mac.ops.update_mc_addr_list(hw, netdev);
+	if (hw->mac.ops.update_mc_addr_list)
+		hw->mac.ops.update_mc_addr_list(hw, netdev);
 
 	ixgbevf_write_uc_addr_list(netdev);
 
@@ -2074,10 +2090,13 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	if (is_valid_ether_addr(hw->mac.addr))
-		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
-	else
-		hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
+	if (is_valid_ether_addr(hw->mac.addr)) {
+		if (hw->mac.ops.set_rar)
+			hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0);
+	} else {
+		if (hw->mac.ops.set_rar)
+			hw->mac.ops.set_rar(hw, 0, hw->mac.perm_addr, 0);
+	}
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
@@ -3672,14 +3691,15 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
-	int err;
+	int err = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-	err = hw->mac.ops.set_rar(hw, 0, addr->sa_data, 0);
+	if (hw->mac.ops.set_rar)
+		err = hw->mac.ops.set_rar(hw, 0, addr->sa_data, 0);
 
 	spin_unlock_bh(&adapter->mbx_lock);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.c b/drivers/net/ethernet/intel/ixgbevf/mbx.c
index dc68fea..298a0da 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.c
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.c
@@ -346,3 +346,15 @@ const struct ixgbe_mbx_operations ixgbevf_mbx_ops = {
 	.check_for_rst	= ixgbevf_check_for_rst_vf,
 };
 
+/**
+ * Mailbox operations when running on Hyper-V.
+ * On Hyper-V, PF/VF communiction is not through the
+ * hardware mailbox; this communication is through
+ * a software mediated path.
+ * Most mail box operations are noop while running on
+ * Hyper-V.
+ */
+const struct ixgbe_mbx_operations ixgbevf_hv_mbx_ops = {
+	.init_params	= ixgbevf_init_mbx_params_vf,
+	.check_for_rst	= ixgbevf_check_for_rst_vf,
+};
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 4d613a4..92397fd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -27,6 +27,13 @@
 #include "vf.h"
 #include "ixgbevf.h"
 
+/*
+ * On Hyper-V, to reset, we need to read from this offset
+ * from the PCI config space. This is the mechanism used on
+ * Hyper-V to support PF/VF communication.
+ */
+#define IXGBE_HV_RESET_OFFSET           0x201
+
 /**
  *  ixgbevf_start_hw_vf - Prepare hardware for Tx/Rx
  *  @hw: pointer to hardware structure
@@ -126,6 +133,23 @@ static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
 }
 
 /**
+ * Hyper-V variant; the VF/PF communication is through the PCI
+ * config space.
+ */
+static s32 ixgbevf_hv_reset_hw_vf(struct ixgbe_hw *hw)
+{
+	int i;
+	struct ixgbevf_adapter *adapter = hw->back;
+
+	for (i = 0; i < 6; i++)
+		pci_read_config_byte(adapter->pdev,
+				     (i + IXGBE_HV_RESET_OFFSET),
+				     &hw->mac.perm_addr[i]);
+
+	return 0;
+}
+
+/**
  *  ixgbevf_stop_hw_vf - Generic stop Tx/Rx units
  *  @hw: pointer to hardware structure
  *
@@ -656,6 +680,68 @@ out:
 }
 
 /**
+ * Hyper-V variant; there is no mailbox communication.
+ */
+static s32 ixgbevf_hv_check_mac_link_vf(struct ixgbe_hw *hw,
+					ixgbe_link_speed *speed,
+					bool *link_up,
+					bool autoneg_wait_to_complete)
+{
+	struct ixgbe_mbx_info *mbx = &hw->mbx;
+	struct ixgbe_mac_info *mac = &hw->mac;
+	s32 ret_val = 0;
+	u32 links_reg;
+
+	/* If we were hit with a reset drop the link */
+	if (!mbx->ops.check_for_rst(hw) || !mbx->timeout)
+		mac->get_link_status = true;
+
+	if (!mac->get_link_status)
+		goto out;
+
+	/* if link status is down no point in checking to see if pf is up */
+	links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
+	if (!(links_reg & IXGBE_LINKS_UP))
+		goto out;
+
+	/* for SFP+ modules and DA cables on 82599 it can take up to 500usecs
+	 * before the link status is correct
+	 */
+	if (mac->type == ixgbe_mac_82599_vf) {
+		int i;
+
+		for (i = 0; i < 5; i++) {
+			udelay(100);
+			links_reg = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
+
+			if (!(links_reg & IXGBE_LINKS_UP))
+				goto out;
+		}
+	}
+
+	switch (links_reg & IXGBE_LINKS_SPEED_82599) {
+	case IXGBE_LINKS_SPEED_10G_82599:
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+		break;
+	case IXGBE_LINKS_SPEED_1G_82599:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		break;
+	case IXGBE_LINKS_SPEED_100_82599:
+		*speed = IXGBE_LINK_SPEED_100_FULL;
+		break;
+	}
+
+	/* if we passed all the tests above then the link is up and we no
+	 * longer need to check for link
+	 */
+	mac->get_link_status = false;
+
+out:
+	*link_up = !mac->get_link_status;
+	return ret_val;
+}
+
+/**
  *  ixgbevf_rlpml_set_vf - Set the maximum receive packet length
  *  @hw: pointer to the HW structure
  *  @max_size: value to assign to max frame size
@@ -663,6 +749,19 @@ out:
 void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size)
 {
 	u32 msgbuf[2];
+	u32 reg;
+
+	if (x86_hyper == &x86_hyper_ms_hyperv) {
+		/*
+		 * If we are on Hyper-V, we implement
+		 * this functionality differently.
+		 */
+		reg =  IXGBE_READ_REG(hw, IXGBE_VFRXDCTL(0));
+		/* CRC == 4 */
+		reg |= ((max_size + 4) | IXGBE_RXDCTL_RLPML_EN);
+		IXGBE_WRITE_REG(hw, IXGBE_VFRXDCTL(0), reg);
+		return;
+	}
 
 	msgbuf[0] = IXGBE_VF_SET_LPE;
 	msgbuf[1] = max_size;
@@ -679,6 +778,16 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api)
 	int err;
 	u32 msg[3];
 
+	if (x86_hyper == &x86_hyper_ms_hyperv) {
+		/*
+		 * Hyper-V only supports api version ixgbe_mbox_api_10
+		 */
+		if (api != ixgbe_mbox_api_10)
+			return IXGBE_ERR_INVALID_ARGUMENT;
+
+		return 0;
+	}
+
 	/* Negotiate the mailbox API version */
 	msg[0] = IXGBE_VF_API_NEGOTIATE;
 	msg[1] = api;
@@ -776,22 +885,51 @@ static const struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.set_vfta		= ixgbevf_set_vfta_vf,
 };
 
+static const struct ixgbe_mac_operations ixgbevf_hv_mac_ops = {
+	.init_hw		= ixgbevf_init_hw_vf,
+	.reset_hw		= ixgbevf_hv_reset_hw_vf,
+	.start_hw		= ixgbevf_start_hw_vf,
+	.get_mac_addr		= ixgbevf_get_mac_addr_vf,
+	.stop_adapter		= ixgbevf_stop_hw_vf,
+	.setup_link		= ixgbevf_setup_mac_link_vf,
+	.check_link		= ixgbevf_hv_check_mac_link_vf,
+};
 const struct ixgbevf_info ixgbevf_82599_vf_info = {
 	.mac = ixgbe_mac_82599_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
 
+const struct ixgbevf_info ixgbevf_82599_vf_hv_info = {
+	.mac = ixgbe_mac_82599_vf,
+	.mac_ops = &ixgbevf_hv_mac_ops,
+};
+
 const struct ixgbevf_info ixgbevf_X540_vf_info = {
 	.mac = ixgbe_mac_X540_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
 
+const struct ixgbevf_info ixgbevf_X540_vf_hv_info = {
+	.mac = ixgbe_mac_X540_vf,
+	.mac_ops = &ixgbevf_hv_mac_ops,
+};
+
 const struct ixgbevf_info ixgbevf_X550_vf_info = {
 	.mac = ixgbe_mac_X550_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
 
+const struct ixgbevf_info ixgbevf_X550_vf_hv_info = {
+	.mac = ixgbe_mac_X550_vf,
+	.mac_ops = &ixgbevf_hv_mac_ops,
+};
+
 const struct ixgbevf_info ixgbevf_X550EM_x_vf_info = {
 	.mac = ixgbe_mac_X550EM_x_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
+
+const struct ixgbevf_info ixgbevf_X550EM_x_vf_hv_info = {
+	.mac = ixgbe_mac_X550EM_x_vf,
+	.mac_ops = &ixgbevf_hv_mac_ops,
+};
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index ef9f773..7242a97 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -32,7 +32,9 @@
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
+#include <asm/hypervisor.h>
 
+#include <asm/hypervisor.h>
 #include "defines.h"
 #include "regs.h"
 #include "mbx.h"
-- 
1.7.4.1
