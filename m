From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH V7 net-next 08/22] net-next/hinic: Add port management commands
Date: Fri, 18 Aug 2017 03:04:42 +0800
Message-ID: <214a8665240828b53c9728e0d8361614ba69982a.1502996306.git.aviad.krawczyk@huawei.com>
References: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <aviad.krawczyk@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502996306.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the port management commands that are sent as management messages.
The port management commands are used for netdev operations.

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/Makefile       |   4 +-
 drivers/net/ethernet/huawei/hinic/hinic_dev.h    |   4 +
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c |  30 +++
 drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h |  29 +++
 drivers/net/ethernet/huawei/hinic/hinic_main.c   | 195 +++++++++++++++++++-
 drivers/net/ethernet/huawei/hinic/hinic_port.c   | 224 +++++++++++++++++++++++
 drivers/net/ethernet/huawei/hinic/hinic_port.h   |  68 +++++++
 7 files changed, 551 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.c
 create mode 100644 drivers/net/ethernet/huawei/hinic/hinic_port.h

diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
index beba90a..dbb1b9d 100644
--- a/drivers/net/ethernet/huawei/hinic/Makefile
+++ b/drivers/net/ethernet/huawei/hinic/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_HINIC) += hinic.o
 
-hinic-y := hinic_main.o hinic_hw_dev.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
-	   hinic_hw_eqs.o hinic_hw_if.o
+hinic-y := hinic_main.o hinic_port.o hinic_hw_dev.o hinic_hw_mgmt.o \
+	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
index 6c2c896..e54a45c 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_dev.h
@@ -18,6 +18,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/types.h>
+#include <linux/semaphore.h>
 
 #include "hinic_hw_dev.h"
 
@@ -28,6 +29,9 @@ struct hinic_dev {
 	struct hinic_hwdev              *hwdev;
 
 	u32                             msg_enable;
+
+	struct semaphore                mgmt_lock;
+	unsigned long                   *vlan_bitmap;
 };
 
 #endif
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
index d430e60..6bb6c33 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
@@ -200,6 +200,36 @@ static void disable_msix(struct hinic_hwdev *hwdev)
 }
 
 /**
+ * hinic_port_msg_cmd - send port msg to mgmt
+ * @hwdev: the NIC HW device
+ * @cmd: the port command
+ * @buf_in: input buffer
+ * @in_size: input size
+ * @buf_out: output buffer
+ * @out_size: returned output size
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
+		       void *buf_in, u16 in_size, void *buf_out, u16 *out_size)
+{
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	struct hinic_pfhwdev *pfhwdev;
+
+	if (!HINIC_IS_PF(hwif) && !HINIC_IS_PPF(hwif)) {
+		dev_err(&pdev->dev, "unsupported PCI Function type\n");
+		return -EINVAL;
+	}
+
+	pfhwdev = container_of(hwdev, struct hinic_pfhwdev, hwdev);
+
+	return hinic_msg_to_mgmt(&pfhwdev->pf_to_mgmt, HINIC_MOD_L2NIC, cmd,
+				 buf_in, in_size, buf_out, out_size,
+				 HINIC_MGMT_MSG_SYNC);
+}
+
+/**
  * init_pfhwdev - Initialize the extended components of PF
  * @pfhwdev: the HW device for PF
  *
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
index feb60138..ee9e76a 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
+++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.h
@@ -30,6 +30,31 @@ struct hinic_cap {
 	u16     num_qps;
 };
 
+enum hinic_port_cmd {
+	HINIC_PORT_CMD_CHANGE_MTU       = 2,
+
+	HINIC_PORT_CMD_ADD_VLAN         = 3,
+	HINIC_PORT_CMD_DEL_VLAN         = 4,
+
+	HINIC_PORT_CMD_SET_MAC          = 9,
+	HINIC_PORT_CMD_GET_MAC          = 10,
+	HINIC_PORT_CMD_DEL_MAC          = 11,
+
+	HINIC_PORT_CMD_SET_RX_MODE      = 12,
+
+	HINIC_PORT_CMD_GET_LINK_STATE   = 24,
+
+	HINIC_PORT_CMD_SET_PORT_STATE   = 41,
+
+	HINIC_PORT_CMD_FWCTXT_INIT      = 69,
+
+	HINIC_PORT_CMD_SET_FUNC_STATE   = 93,
+
+	HINIC_PORT_CMD_GET_GLOBAL_QPN   = 102,
+
+	HINIC_PORT_CMD_GET_CAP          = 170,
+};
+
 struct hinic_hwdev {
 	struct hinic_hwif               *hwif;
 	struct msix_entry               *msix_entries;
@@ -45,6 +70,10 @@ struct hinic_pfhwdev {
 	struct hinic_pf_to_mgmt         pf_to_mgmt;
 };
 
+int hinic_port_msg_cmd(struct hinic_hwdev *hwdev, enum hinic_port_cmd cmd,
+		       void *buf_in, u16 in_size, void *buf_out,
+		       u16 *out_size);
+
 struct hinic_hwdev *hinic_init_hwdev(struct pci_dev *pdev);
 
 void hinic_free_hwdev(struct hinic_hwdev *hwdev);
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index 10df850..f46c2bc 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/pci.h>
 #include <linux/device.h>
@@ -20,9 +21,16 @@
 #include <linux/types.h>
 #include <linux/etherdevice.h>
 #include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/if_vlan.h>
+#include <linux/semaphore.h>
+#include <net/ip.h>
+#include <linux/bitops.h>
+#include <linux/bitmap.h>
 #include <linux/err.h>
 
 #include "hinic_hw_dev.h"
+#include "hinic_port.h"
 #include "hinic_dev.h"
 
 MODULE_AUTHOR("Huawei Technologies CO., Ltd");
@@ -35,10 +43,163 @@
 					 NETIF_MSG_IFUP |                  \
 					 NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
 
+#define VLAN_BITMAP_SIZE(nic_dev)       (ALIGN(VLAN_N_VID, 8) / 8)
+
+static int hinic_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	int err;
+
+	netif_info(nic_dev, drv, netdev, "set_mtu = %d\n", new_mtu);
+
+	err = hinic_port_set_mtu(nic_dev, new_mtu);
+	if (err)
+		netif_err(nic_dev, drv, netdev, "Failed to set port mtu\n");
+	else
+		netdev->mtu = new_mtu;
+
+	return err;
+}
+
+/**
+ * change_mac_addr - change the main mac address of network device
+ * @netdev: network device
+ * @addr: mac address to set
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int change_mac_addr(struct net_device *netdev, const u8 *addr)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	u16 vid = 0;
+	int err;
+
+	if (!is_valid_ether_addr(addr))
+		return -EADDRNOTAVAIL;
+
+	netif_info(nic_dev, drv, netdev, "change mac addr = %02x %02x %02x %02x %02x %02x\n",
+		   addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+
+	down(&nic_dev->mgmt_lock);
+
+	do {
+		err = hinic_port_del_mac(nic_dev, netdev->dev_addr, vid);
+		if (err) {
+			netif_err(nic_dev, drv, netdev,
+				  "Failed to delete mac\n");
+			break;
+		}
+
+		err = hinic_port_add_mac(nic_dev, addr, vid);
+		if (err) {
+			netif_err(nic_dev, drv, netdev, "Failed to add mac\n");
+			break;
+		}
+
+		vid = find_next_bit(nic_dev->vlan_bitmap, VLAN_N_VID, vid + 1);
+	} while (vid != VLAN_N_VID);
+
+	up(&nic_dev->mgmt_lock);
+	return err;
+}
+
+static int hinic_set_mac_addr(struct net_device *netdev, void *addr)
+{
+	unsigned char new_mac[ETH_ALEN];
+	struct sockaddr *saddr = addr;
+	int err;
+
+	memcpy(new_mac, saddr->sa_data, ETH_ALEN);
+
+	err = change_mac_addr(netdev, new_mac);
+	if (!err)
+		memcpy(netdev->dev_addr, new_mac, ETH_ALEN);
+
+	return err;
+}
+
+static int hinic_vlan_rx_add_vid(struct net_device *netdev,
+				 __always_unused __be16 proto, u16 vid)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	int ret, err;
+
+	netif_info(nic_dev, drv, netdev, "add vid = %d\n", vid);
+
+	down(&nic_dev->mgmt_lock);
+
+	err = hinic_port_add_vlan(nic_dev, vid);
+	if (err) {
+		netif_err(nic_dev, drv, netdev, "Failed to add vlan\n");
+		goto err_vlan_add;
+	}
+
+	err = hinic_port_add_mac(nic_dev, netdev->dev_addr, vid);
+	if (err) {
+		netif_err(nic_dev, drv, netdev, "Failed to set mac\n");
+		goto err_add_mac;
+	}
+
+	bitmap_set(nic_dev->vlan_bitmap, vid, 1);
+
+	up(&nic_dev->mgmt_lock);
+	return 0;
+
+err_add_mac:
+	ret = hinic_port_del_vlan(nic_dev, vid);
+	if (ret)
+		netif_err(nic_dev, drv, netdev,
+			  "Failed to revert by removing vlan\n");
+
+err_vlan_add:
+	up(&nic_dev->mgmt_lock);
+	return err;
+}
+
+static int hinic_vlan_rx_kill_vid(struct net_device *netdev,
+				  __always_unused __be16 proto, u16 vid)
+{
+	struct hinic_dev *nic_dev = netdev_priv(netdev);
+	int err;
+
+	netif_info(nic_dev, drv, netdev, "remove vid = %d\n", vid);
+
+	down(&nic_dev->mgmt_lock);
+
+	err = hinic_port_del_vlan(nic_dev, vid);
+	if (err) {
+		netif_err(nic_dev, drv, netdev, "Failed to delete vlan\n");
+		goto err_del_vlan;
+	}
+
+	bitmap_clear(nic_dev->vlan_bitmap, vid, 1);
+
+	up(&nic_dev->mgmt_lock);
+	return 0;
+
+err_del_vlan:
+	up(&nic_dev->mgmt_lock);
+	return err;
+}
+
 static const struct net_device_ops hinic_netdev_ops = {
-	/* Operations are empty, should be filled */
+	.ndo_change_mtu = hinic_change_mtu,
+	.ndo_set_mac_address = hinic_set_mac_addr,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_vlan_rx_add_vid = hinic_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid = hinic_vlan_rx_kill_vid,
+	/* more operations should be filled */
 };
 
+static void netdev_features_init(struct net_device *netdev)
+{
+	netdev->hw_features = NETIF_F_SG | NETIF_F_HIGHDMA;
+
+	netdev->vlan_features = netdev->hw_features;
+
+	netdev->features = netdev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
+}
+
 /**
  * nic_dev_init - Initialize the NIC device
  * @pdev: the NIC pci device
@@ -79,8 +240,36 @@ static int nic_dev_init(struct pci_dev *pdev)
 	nic_dev->hwdev = hwdev;
 	nic_dev->msg_enable = MSG_ENABLE_DEFAULT;
 
+	sema_init(&nic_dev->mgmt_lock, 1);
+
+	nic_dev->vlan_bitmap = devm_kzalloc(&pdev->dev,
+					    VLAN_BITMAP_SIZE(nic_dev),
+					    GFP_KERNEL);
+	if (!nic_dev->vlan_bitmap) {
+		err = -ENOMEM;
+		goto err_vlan_bitmap;
+	}
+
 	pci_set_drvdata(pdev, netdev);
 
+	err = hinic_port_get_mac(nic_dev, netdev->dev_addr);
+	if (err)
+		dev_warn(&pdev->dev, "Failed to get mac address\n");
+
+	err = hinic_port_add_mac(nic_dev, netdev->dev_addr, 0);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to add mac\n");
+		goto err_add_mac;
+	}
+
+	err = hinic_port_set_mtu(nic_dev, netdev->mtu);
+	if (err) {
+		dev_err(&pdev->dev, "Failed to set mtu\n");
+		goto err_set_mtu;
+	}
+
+	netdev_features_init(netdev);
+
 	netif_carrier_off(netdev);
 
 	err = register_netdev(netdev);
@@ -92,7 +281,11 @@ static int nic_dev_init(struct pci_dev *pdev)
 	return 0;
 
 err_reg_netdev:
+err_set_mtu:
+err_add_mac:
 	pci_set_drvdata(pdev, NULL);
+
+err_vlan_bitmap:
 	free_netdev(netdev);
 
 err_alloc_etherdev:
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.c b/drivers/net/ethernet/huawei/hinic/hinic_port.c
new file mode 100644
index 0000000..5b249e8
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.c
@@ -0,0 +1,224 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/errno.h>
+
+#include "hinic_hw_if.h"
+#include "hinic_hw_dev.h"
+#include "hinic_port.h"
+#include "hinic_dev.h"
+
+#define HINIC_MIN_MTU_SIZE              256
+#define HINIC_MAX_JUMBO_FRAME_SIZE      15872
+
+enum mac_op {
+	MAC_DEL,
+	MAC_SET,
+};
+
+/**
+ * change_mac - change(add or delete) mac address
+ * @nic_dev: nic device
+ * @addr: mac address
+ * @vlan_id: vlan number to set with the mac
+ * @op: add or delete the mac
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+static int change_mac(struct hinic_dev *nic_dev, const u8 *addr,
+		      u16 vlan_id, enum mac_op op)
+{
+	struct net_device *netdev = nic_dev->netdev;
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_mac_cmd port_mac_cmd;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	enum hinic_port_cmd cmd;
+	u16 out_size;
+	int err;
+
+	if (vlan_id >= VLAN_N_VID) {
+		netif_err(nic_dev, drv, netdev, "Invalid VLAN number\n");
+		return -EINVAL;
+	}
+
+	if (op == MAC_SET)
+		cmd = HINIC_PORT_CMD_SET_MAC;
+	else
+		cmd = HINIC_PORT_CMD_DEL_MAC;
+
+	port_mac_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+	port_mac_cmd.vlan_id = vlan_id;
+	memcpy(port_mac_cmd.mac, addr, ETH_ALEN);
+
+	err = hinic_port_msg_cmd(hwdev, cmd, &port_mac_cmd,
+				 sizeof(port_mac_cmd),
+				 &port_mac_cmd, &out_size);
+	if (err || (out_size != sizeof(port_mac_cmd)) || port_mac_cmd.status) {
+		dev_err(&pdev->dev, "Failed to change MAC, ret = %d\n",
+			port_mac_cmd.status);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+/**
+ * hinic_port_add_mac - add mac address
+ * @nic_dev: nic device
+ * @addr: mac address
+ * @vlan_id: vlan number to set with the mac
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_add_mac(struct hinic_dev *nic_dev,
+		       const u8 *addr, u16 vlan_id)
+{
+	return change_mac(nic_dev, addr, vlan_id, MAC_SET);
+}
+
+/**
+ * hinic_port_del_mac - remove mac address
+ * @nic_dev: nic device
+ * @addr: mac address
+ * @vlan_id: vlan number that is connected to the mac
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_del_mac(struct hinic_dev *nic_dev, const u8 *addr,
+		       u16 vlan_id)
+{
+	return change_mac(nic_dev, addr, vlan_id, MAC_DEL);
+}
+
+/**
+ * hinic_port_get_mac - get the mac address of the nic device
+ * @nic_dev: nic device
+ * @addr: returned mac address
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_get_mac(struct hinic_dev *nic_dev, u8 *addr)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_mac_cmd port_mac_cmd;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	u16 out_size;
+	int err;
+
+	port_mac_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_GET_MAC,
+				 &port_mac_cmd, sizeof(port_mac_cmd),
+				 &port_mac_cmd, &out_size);
+	if (err || (out_size != sizeof(port_mac_cmd)) || port_mac_cmd.status) {
+		dev_err(&pdev->dev, "Failed to get mac, ret = %d\n",
+			port_mac_cmd.status);
+		return -EFAULT;
+	}
+
+	memcpy(addr, port_mac_cmd.mac, ETH_ALEN);
+	return 0;
+}
+
+/**
+ * hinic_port_set_mtu - set mtu
+ * @nic_dev: nic device
+ * @new_mtu: new mtu
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_set_mtu(struct hinic_dev *nic_dev, int new_mtu)
+{
+	struct net_device *netdev = nic_dev->netdev;
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_mtu_cmd port_mtu_cmd;
+	struct hinic_hwif *hwif = hwdev->hwif;
+	struct pci_dev *pdev = hwif->pdev;
+	int err, max_frame;
+	u16 out_size;
+
+	if (new_mtu < HINIC_MIN_MTU_SIZE) {
+		netif_err(nic_dev, drv, netdev, "mtu < MIN MTU size");
+		return -EINVAL;
+	}
+
+	max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	if (max_frame > HINIC_MAX_JUMBO_FRAME_SIZE) {
+		netif_err(nic_dev, drv, netdev, "mtu > MAX MTU size");
+		return -EINVAL;
+	}
+
+	port_mtu_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwif);
+	port_mtu_cmd.mtu = new_mtu;
+
+	err = hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_CHANGE_MTU,
+				 &port_mtu_cmd, sizeof(port_mtu_cmd),
+				 &port_mtu_cmd, &out_size);
+	if (err || (out_size != sizeof(port_mtu_cmd)) || port_mtu_cmd.status) {
+		dev_err(&pdev->dev, "Failed to set mtu, ret = %d\n",
+			port_mtu_cmd.status);
+		return -EFAULT;
+	}
+
+	return 0;
+}
+
+/**
+ * hinic_port_add_vlan - add vlan to the nic device
+ * @nic_dev: nic device
+ * @vlan_id: the vlan number to add
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_add_vlan(struct hinic_dev *nic_dev, u16 vlan_id)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_vlan_cmd port_vlan_cmd;
+
+	port_vlan_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwdev->hwif);
+	port_vlan_cmd.vlan_id = vlan_id;
+
+	return hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_ADD_VLAN,
+				  &port_vlan_cmd, sizeof(port_vlan_cmd),
+				  NULL, NULL);
+}
+
+/**
+ * hinic_port_del_vlan - delete vlan from the nic device
+ * @nic_dev: nic device
+ * @vlan_id: the vlan number to delete
+ *
+ * Return 0 - Success, negative - Failure
+ **/
+int hinic_port_del_vlan(struct hinic_dev *nic_dev, u16 vlan_id)
+{
+	struct hinic_hwdev *hwdev = nic_dev->hwdev;
+	struct hinic_port_vlan_cmd port_vlan_cmd;
+
+	port_vlan_cmd.func_idx = HINIC_HWIF_FUNC_IDX(hwdev->hwif);
+	port_vlan_cmd.vlan_id = vlan_id;
+
+	return hinic_port_msg_cmd(hwdev, HINIC_PORT_CMD_DEL_VLAN,
+				 &port_vlan_cmd, sizeof(port_vlan_cmd),
+				 NULL, NULL);
+}
diff --git a/drivers/net/ethernet/huawei/hinic/hinic_port.h b/drivers/net/ethernet/huawei/hinic/hinic_port.h
new file mode 100644
index 0000000..4cafb94
--- /dev/null
+++ b/drivers/net/ethernet/huawei/hinic/hinic_port.h
@@ -0,0 +1,68 @@
+/*
+ * Huawei HiNIC PCI Express Linux driver
+ * Copyright(c) 2017 Huawei Technologies Co., Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ */
+
+#ifndef HINIC_PORT_H
+#define HINIC_PORT_H
+
+#include <linux/types.h>
+#include <linux/etherdevice.h>
+
+#include "hinic_dev.h"
+
+struct hinic_port_mac_cmd {
+	u8              status;
+	u8              version;
+	u8              rsvd0[6];
+
+	u16             func_idx;
+	u16             vlan_id;
+	u16             rsvd1;
+	unsigned char   mac[ETH_ALEN];
+};
+
+struct hinic_port_mtu_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     rsvd1;
+	u32     mtu;
+};
+
+struct hinic_port_vlan_cmd {
+	u8      status;
+	u8      version;
+	u8      rsvd0[6];
+
+	u16     func_idx;
+	u16     vlan_id;
+};
+
+int hinic_port_add_mac(struct hinic_dev *nic_dev, const u8 *addr,
+		       u16 vlan_id);
+
+int hinic_port_del_mac(struct hinic_dev *nic_dev, const u8 *addr,
+		       u16 vlan_id);
+
+int hinic_port_get_mac(struct hinic_dev *nic_dev, u8 *addr);
+
+int hinic_port_set_mtu(struct hinic_dev *nic_dev, int new_mtu);
+
+int hinic_port_add_vlan(struct hinic_dev *nic_dev, u16 vlan_id);
+
+int hinic_port_del_vlan(struct hinic_dev *nic_dev, u16 vlan_id);
+
+#endif
-- 
1.9.1
