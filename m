From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 1/7] Topcliff GbE: Add The Main code [1/3]
Date: Fri, 23 Apr 2010 20:56:25 +0900
Message-ID: <002d01cae2dd$1f6e42d0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=3;
	id="01CAE2DD.1F112EB0@tsmail03";
	number=1
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34056 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757309Ab0DWMEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
To: "NETDEV" <netdev@vger.kernel.org>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
Subject: [PATCH 1/7] Topcliff GbE: Add The Main code
Date: Fri, 23 Apr 2010 20:56:25 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2800.1983
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1983

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

This patch adds the Main code of GbE driver for Topcliff.
The GbE driver needs all patch[1/7 to 7/7].

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c         | 2982
+++++++++++++++++++++++++++++++ 1 files changed, 2982 insertions(+)
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_main.c
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_main.c
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_main.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_main.c 2010-04-13
19:24:53.000000000 +0900
@@ -0,0 +1,2982 @@
+/*!
+ * @file pch_gbe_main.c
+ * @brief Linux PCH Gigabit Ethernet Driver main source file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <net/ip.h>
+
+#include "pch_debug.h"
+#include "pch_gbe_osdep.h"
+#include "pch_gbe_regs.h"
+#include "pch_gbe_defines.h"
+#include "pch_gbe_hw.h"
+#include "pch_gbe_api.h"
+#include "pch_gbe.h"
+
+/* ------------------------------------------------------------------------
----
+ Function prototype
+---------------------------------------------------------------------------
- */
+static int
+pch_gbe_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id);
+static void pch_gbe_remove(struct pci_dev *pdev);
+static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state);
+static int pch_gbe_resume(struct pci_dev *pdev);
+static void pch_gbe_shutdown(struct pci_dev *pdev);
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void pch_gbe_netpoll(struct net_device *netdev);
+#endif
+static pci_ers_result_t
+pch_gbe_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state);
+static pci_ers_result_t pch_gbe_io_slot_reset(struct pci_dev *pdev);
+static void pch_gbe_io_resume(struct pci_dev *pdev);
+
+static int pch_gbe_init_module(void);
+static void pch_gbe_exit_module(void);
+static int pch_gbe_open(struct net_device *netdev);
+static int pch_gbe_stop(struct net_device *netdev);
+static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device
*netdev);
+static struct net_device_stats *pch_gbe_get_stats(struct net_device
*netdev);
+static void pch_gbe_set_multi(struct net_device *netdev);
+static int pch_gbe_set_mac(struct net_device *netdev, void *p);
+static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu);
+static int pch_gbe_ioctl(struct net_device *netdev, struct ifreq *ifr, int
cmd);
+static void pch_gbe_tx_timeout(struct net_device *dev);
+
+static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter);
+static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter);
+static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter);
+static int pch_gbe_init_nvm(struct pch_gbe_adapter *adapter);
+static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter);
+static void pch_gbe_reset_task(struct work_struct *work);
+static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter);
+static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter);
+static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter);
+static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter);
+static void pch_gbe_clean_tx_ring(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *tx_ring);
+static void pch_gbe_clean_rx_ring(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring);
+static void
+pch_gbe_unmap_and_free_tx_resource(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_buffer *buffer_info);
+static void
+pch_gbe_unmap_and_free_rx_resource(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_buffer *buffer_info);
+
+static void pch_gbe_setup_tctl(struct pch_gbe_adapter *adapter);
+static void pch_gbe_configure_tx(struct pch_gbe_adapter *adapter);
+static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter);
+static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter);
+static void pch_gbe_set_rgmii_ctrl(struct pch_gbe_adapter *adapter,
+     u16 speed, u16 duplex);
+static void pch_gbe_set_mode(struct pch_gbe_adapter *adapter,
+     u16 speed, u16 duplex);
+static void pch_gbe_watchdog(unsigned long data);
+static irqreturn_t pch_gbe_intr(int irq, void *data);
+static unsigned char pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *tx_ring);
+static int pch_gbe_napi_poll(struct napi_struct *napi, int budget);
+static unsigned char pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring,
+    int *work_done, int work_to_do);
+static void pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring,
+    int cleaned_count);
+static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *tx_ring);
+static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
+   struct pch_gbe_tx_ring *tx_ring,
+   struct sk_buff *skb);
+
+/* ------------------------------------------------------------------------
----
+ Data
+---------------------------------------------------------------------------
- */
+/*!
+ * @ingroup PCI driver Layer
+ * @struct  pch_gbe_pcidev_id
+ * @brief   PCI Device ID Table
+ * @remarks
+ *  This is an instance of pci_device_id structure defined in linux/pci.h,
+ *  and holds information of the PCI devices that are supported by this
driver.
+ */
+static const struct pci_device_id pch_gbe_pcidev_id[3] = {
+ {.vendor = PCI_VENDOR_ID_INTEL,
+  .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
+  .subvendor = PCI_ANY_ID,
+  .subdevice = PCI_ANY_ID,
+  .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+  .class_mask = (0xFFFF00)
+  },
+ /* required last entry */
+ {0}
+};
+
+/*!
+ * @ingroup PCI driver Layer
+ * @struct  pch_gbe_err_handler
+ * @brief   Error handler Table
+ * @remarks
+ *  This is an instance of pci_error_handlers structure defined in
linux/pci.h,
+ *  and holds information of the PCI devices that are supported by this
driver.
+ */
+static struct pci_error_handlers pch_gbe_err_handler = {
+ .error_detected = pch_gbe_io_error_detected,
+ .slot_reset = pch_gbe_io_slot_reset,
+ .resume = pch_gbe_io_resume
+};
+
+/*!
+ * @ingroup PCI driver Layer
+ * @struct  pch_gbe_pcidev
+ * @brief   Store the pointers of pci driver interfaces to kernel
+ */
+static struct pci_driver pch_gbe_pcidev = {
+ .name = DRV_NAME,
+ .id_table = pch_gbe_pcidev_id,
+ .probe = pch_gbe_probe,
+ .remove = pch_gbe_remove,
+ /* Power Managment Hooks */
+#ifdef CONFIG_PM
+ .suspend = pch_gbe_suspend,
+ .resume = pch_gbe_resume,
+#endif
+ .shutdown = pch_gbe_shutdown,
+ .err_handler = &pch_gbe_err_handler
+};
+
+static int debug = PCH_GBE_NETIF_MSG_DEFAULT;
+static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
+
+/* ------------------------------------------------------------------------
----
+ module
+---------------------------------------------------------------------------
- */
+
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_AUTHOR(DRV_COPYRIGHT);
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
+
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+ "Maximum size of packet that is copied to a new buffer on receive");
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
+module_init(pch_gbe_init_module);
+module_exit(pch_gbe_exit_module);
+
+/* ------------------------------------------------------------------------
----
+ Macro Function
+---------------------------------------------------------------------------
- */
+#define PCH_GBE_GET_DESC(R, i, type)    (&(((struct type *)((R).desc))[i]))
+#define PCH_GBE_RX_DESC(R, i)           PCH_GBE_GET_DESC(R, i,
pch_gbe_rx_desc)
+#define PCH_GBE_TX_DESC(R, i)           PCH_GBE_GET_DESC(R, i,
pch_gbe_tx_desc)
+#define PCH_GBE_DESC_UNUSED(R) \
+ ((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
+ (R)->next_to_clean - (R)->next_to_use - 1)
+
+/* ------------------------------------------------------------------------
----
+ Function
+---------------------------------------------------------------------------
- */
+/* ------------------------------------------------------------------------
----
+ PCI driver methods
+---------------------------------------------------------------------------
- */
+
+static const struct net_device_ops pch_gbe_netdev_ops = {
+ .ndo_open = pch_gbe_open,
+ .ndo_stop = pch_gbe_stop,
+ .ndo_start_xmit = pch_gbe_xmit_frame,
+ .ndo_get_stats = pch_gbe_get_stats,
+ .ndo_set_mac_address = pch_gbe_set_mac,
+ .ndo_tx_timeout = pch_gbe_tx_timeout,
+ .ndo_change_mtu = pch_gbe_change_mtu,
+ .ndo_do_ioctl = pch_gbe_ioctl,
+ .ndo_set_multicast_list = &pch_gbe_set_multi,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+ .ndo_poll_controller = pch_gbe_netpoll,
+#endif
+};
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static int pch_gbe_probe(struct pci_dev *pdev,
+ *                                   const struct pci_device_id *pci_id)
+ * @brief   Device Initialization Routine
+ * @param   pdev    [INOUT] PCI device information struct
+ * @param   pci_id  [INOUT] Entry in pch_gbe_pcidev_id
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  This function initializes an adapter identified by a pci_dev structure.
+ *  The OS initialization, configuring of the adapter private structure,
+ *  and a hardware reset occur.
+ */
+static int
+pch_gbe_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
+{
+ struct net_device *netdev;
+ struct pch_gbe_adapter *adapter;
+ unsigned long mmio_start;
+ unsigned long mmio_len;
+ static int cards_found;
+ int i, ret;
+
+ PCH_DEBUG("pch_gbe_probe\n");
+
+ cards_found = 0;
+ ret = pci_enable_device(pdev);
+ if (ret != 0)
+  return ret;
+ ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+ if (ret != 0) {
+  ret = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+  if (ret != 0) {
+   PCH_LOG(KERN_ERR,
+       "ERR: No usable DMA configuration, aborting\n");
+   goto err_disable_device;
+  }
+ }
+ ret = pci_request_regions(pdev, DRV_NAME);
+ if (ret != 0) {
+  PCH_LOG(KERN_ERR,
+      "ERR: Can't reserve PCI I/O and memory resources\n");
+  goto err_disable_device;
+ }
+ pci_set_master(pdev);
+
+ netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
+ if (!netdev) {
+  ret = -ENOMEM;
+  PCH_LOG(KERN_ERR,
+      "ERR: Can't allocates and sets up an Ethernet device\n");
+  goto err_release_pci;
+ }
+ SET_NETDEV_DEV(netdev, &pdev->dev);
+
+ pci_set_drvdata(pdev, netdev);
+ adapter = netdev_priv(netdev);
+ adapter->netdev = netdev;
+ adapter->pdev = pdev;
+ adapter->msg_enable = (1 << debug) - 1;
+ adapter->bd_number = cards_found;
+ adapter->hw.back = adapter;
+ mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
+ mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
+ adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
+ if (!adapter->hw.hw_addr) {
+  ret = -EIO;
+  DPRINTK(PROBE, ERR, "Can't ioremap\n");
+  goto err_free_netdev;
+ }
+
+ netdev->netdev_ops = &pch_gbe_netdev_ops;
+
+ netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
+ netif_napi_add(netdev, &adapter->napi,
+         pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
+ strncpy(netdev->name, pci_name(pdev), (int)sizeof(netdev->name) - 1);
+ netdev->mem_start = mmio_start;
+ netdev->mem_end = mmio_start + mmio_len;
+ netdev->features = NETIF_F_HW_CSUM;
+ pch_gbe_set_ethtool_ops(netdev);
+
+ /* setup the private structure */
+ ret = pch_gbe_sw_init(adapter);
+ if (ret != 0)
+  goto err_iounmap;
+
+ pch_gbe_hal_reset_hw(&adapter->hw);
+ /* Initialize PHY */
+ ret = pch_gbe_init_phy(adapter);
+ if (ret != 0) {
+  DPRINTK(PROBE, ERR, "PHY initialize error\n");
+  goto err_free_adapter;
+ }
+
+ pch_gbe_hal_get_bus_info(&adapter->hw);
+
+ /* Initialize NVM */
+ ret = pch_gbe_init_nvm(adapter);
+ if (ret != 0) {
+  DPRINTK(PROBE, ERR, "NVM initialize error\n");
+  goto err_free_adapter;
+ }
+
+#ifdef CONFIG_PCH_PHUB
+ /* Read the MAC address. and store to the private data */
+ ret = pch_gbe_hal_read_mac_addr(&adapter->hw);
+ if (ret != 0) {
+  DPRINTK(PROBE, ERR, "MAC address Read Error\n");
+  goto err_free_adapter;
+ }
+#endif
+ memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
+ if (!is_valid_ether_addr(netdev->dev_addr)) {
+  DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+  ret = -EIO;
+  goto err_free_adapter;
+ }
+
+ init_timer(&adapter->watchdog_timer);
+ adapter->watchdog_timer.function = &pch_gbe_watchdog;
+ adapter->watchdog_timer.data = (unsigned long)adapter;
+
+ INIT_WORK(&adapter->reset_task, pch_gbe_reset_task);
+
+ pch_gbe_check_options(adapter);
+
+ if (adapter->tx_csum != 0)
+  netdev->features |= NETIF_F_HW_CSUM;
+ else
+  netdev->features &= ~NETIF_F_HW_CSUM;
+
+ /* initialize the wol settings based on the eeprom settings */
+ adapter->wake_up_evt = PCH_GBE_WL_INIT_SETTING;
+
+ /* print bus type/speed/width info */
+ {
+  struct pch_gbe_hw *hw = &adapter->hw;
+  DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
+  ((hw->bus.type == pch_gbe_bus_type_pcix) ? "-X" :
+    (hw->bus.type == pch_gbe_bus_type_pci_express) ? " Express" :
+  ""),
+  ((hw->bus.speed == pch_gbe_bus_speed_2500) ? "2.5Gb/s" :
+    (hw->bus.speed == pch_gbe_bus_speed_133) ? "133MHz" :
+    (hw->bus.speed == pch_gbe_bus_speed_120) ? "120MHz" :
+    (hw->bus.speed == pch_gbe_bus_speed_100) ? "100MHz" :
+    (hw->bus.speed == pch_gbe_bus_speed_66) ? "66MHz" :
+    (hw->bus.speed == pch_gbe_bus_speed_33) ? "33MHz" :
+  ""),
+  ((hw->bus.width == pch_gbe_bus_width_64) ? "64-bit" :
+    (hw->bus.width == pch_gbe_bus_width_32) ? "32-bit" :
+    (hw->bus.width == pch_gbe_bus_width_pcie_x4) ? "Width x4" :
+    (hw->bus.width == pch_gbe_bus_width_pcie_x2) ? "Width x2" :
+    (hw->bus.width == pch_gbe_bus_width_pcie_x1) ? "Width x1" :
+  ""));
+ }
+ for (i = 0; i < 6; i++)
+  printk(KERN_INFO "%2.2x%c",
+   netdev->dev_addr[i], i == 5 ? '\n' : ':');
+
+ /* reset the hardware with the new settings */
+ pch_gbe_reset(adapter);
+
+ strcpy(netdev->name, "eth%d");
+ ret = register_netdev(netdev);
+ if (ret != 0)
+  goto err_free_adapter;
+ /* tell the stack to leave us alone until pch_gbe_open() is called */
+ netif_carrier_off(netdev);
+ netif_stop_queue(netdev);
+
+ DPRINTK(PROBE, INFO, "OKIsemi(R) PCH Network Connection\n");
+
+ cards_found++;
+ device_set_wakeup_enable(&pdev->dev, 1);
+ return PCH_GBE_SUCCESS;
+
+err_free_adapter:
+ pch_gbe_hal_phy_hw_reset(&adapter->hw);
+ dev_put(adapter->polling_netdev);
+ kfree(adapter->tx_ring);
+ kfree(adapter->rx_ring);
+ kfree(adapter->polling_netdev);
+err_iounmap:
+ iounmap(adapter->hw.hw_addr);
+err_free_netdev:
+ free_netdev(netdev);
+err_release_pci:
+ pci_release_regions(pdev);
+err_disable_device:
+ pci_disable_device(pdev);
+ return ret;
+}
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static void pch_gbe_remove(struct pci_dev *pdev)
+ * @brief   Device Removal Routine
+ * @param   pdev     [INOUT] PCI device information struct
+ * @return  None
+ * @remarks
+ *  This function is called by the PCI subsystem to alert the driver
+ *  that it should release a PCI device.  The could be caused by a
+ *  Hot-Plug event, or because the driver is going to be removed from
+ *  memory.
+ */
+static void pch_gbe_remove(struct pci_dev *pdev)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ flush_scheduled_work();
+ unregister_netdev(netdev);
+ dev_put(adapter->polling_netdev);
+
+ pch_gbe_hal_phy_hw_reset(&adapter->hw);
+
+ kfree(adapter->tx_ring);
+ kfree(adapter->rx_ring);
+ kfree(adapter->polling_netdev);
+
+ iounmap(adapter->hw.hw_addr);
+ pci_release_regions(pdev);
+ free_netdev(netdev);
+ pci_disable_device(pdev);
+}
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t
state)
+ * @brief   Device Suspend Routine
+ * @param   pdev     [INOUT] PCI device information struct
+ * @param   state    [IN] Power status
+ * @return  None
+ */
+static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 wufc = adapter->wake_up_evt;
+ int retval = PCH_GBE_SUCCESS;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ netif_device_detach(netdev);
+
+ if (netif_running(netdev) != 0)
+  pch_gbe_down(adapter);
+#ifdef CONFIG_PM
+ /* Implement our own version of pci_save_state(pdev) because pci-
+  * express adapters have 256-byte config spaces. */
+ retval = pci_save_state(pdev);
+ if (retval != 0) {
+  DPRINTK(PROBE, DEBUG, "pci_save_state failed\n");
+  return retval;
+ }
+#endif
+
+ if (wufc != 0) {
+  pch_gbe_set_multi(netdev);
+  pch_gbe_setup_rctl(adapter);
+  pch_gbe_configure_rx(adapter);
+  pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
+     hw->mac.link_duplex);
+  pch_gbe_set_mode(adapter, hw->mac.link_speed,
+     hw->mac.link_duplex);
+  pch_gbe_hal_set_wol_event(hw, wufc);
+  pci_disable_device(pdev);
+  retval = pci_set_power_state(pdev, PCI_D0);
+  if (retval)
+   DPRINTK(PROBE, DEBUG, "pci_set_power_state failed\n");
+  retval = pci_enable_wake(pdev, PCI_D0, 1);
+  if (retval)
+   DPRINTK(PROBE, DEBUG, "pci_enable_wake failed\n");
+ } else {
+  pch_gbe_hal_power_down_phy(hw);
+  pch_gbe_hal_set_wol_event(hw, wufc);
+  pci_disable_device(pdev);
+  pci_enable_wake(pdev, PCI_D0, 0);
+  pci_set_power_state(pdev, pci_choose_state(pdev, state));
+ }
+ return retval;
+}
+
+#ifdef CONFIG_PM
+/*!
+ * @ingroup PCI driver method
+ * @fn      static int pch_gbe_resume(struct pci_dev *pdev)
+ * @brief   Device Resume Routine
+ * @param   pdev     [INOUT] PCI device information struct
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  negative:  Failed
+ */
+static int pch_gbe_resume(struct pci_dev *pdev)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+ u32 err;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ pci_enable_wake(pdev, PCI_D0, 0);
+ pci_set_power_state(pdev, PCI_D0);
+ pci_restore_state(pdev);
+ err = pci_enable_device(pdev);
+ if (err != 0) {
+  DPRINTK(PROBE, ERR, "Cannot enable PCI device from suspend\n");
+  return err;
+ }
+ pci_set_master(pdev);
+ pch_gbe_hal_power_up_phy(hw);
+ pch_gbe_reset(adapter);
+ /* Clear wake on lan control and status */
+ pch_gbe_hal_set_wol_event(hw, 0);
+
+ if (netif_running(netdev) != 0)
+  pch_gbe_up(adapter);
+ netif_device_attach(netdev);
+
+ return PCH_GBE_SUCCESS;
+}
+#endif /* CONFIG_PM */
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static void pch_gbe_shutdown(struct pci_dev *pdev)
+ * @brief   Device shutdown Routine
+ * @param   pdev    [INOUT] PCI device information struct
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:  Failed
+ */
+static void pch_gbe_shutdown(struct pci_dev *pdev)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+ pch_gbe_suspend(pdev, PMSG_SUSPEND);
+}
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static pci_ers_result_t pch_gbe_io_error_detected(
+ *                                  struct pci_dev *pdev,
+ *                                  pci_channel_state_t state)
+ * @brief   Called when PCI error is detected
+ * @param   pdev     [INOUT] PCI device information struct
+ * @param   state    [IN] The current pci connection state
+ * @return  PCI_ERS_RESULT_NEED_RESET
+ * @remarks
+ *   This function is called after a PCI bus error affecting
+ *   this device has been detected.
+ */
+static pci_ers_result_t
+pch_gbe_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ netif_device_detach(netdev);
+
+ if (netif_running(netdev) != 0)
+  pch_gbe_down(adapter);
+ pci_disable_device(pdev);
+
+ /* Request a slot slot reset. */
+ return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static pci_ers_result_t pch_gbe_io_slot_reset(struct pci_dev
*pdev)
+ * @brief   Called after the pci bus has been reset.
+ * @param   pdev    [INOUT] PCI device information struct
+ * @return  PCI_ERS_RESULT_DISCONNECT
+ * @return  PCI_ERS_RESULT_RECOVERED
+ * @remarks
+ *   Restart the card from scratch, as if from a cold-boot. Implementation
+ *   resembles the first-half of the pch_gbe_resume routine.
+ */
+static pci_ers_result_t pch_gbe_io_slot_reset(struct pci_dev *pdev)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ if (pci_enable_device(pdev) != 0) {
+  DPRINTK(PROBE, ERR,
+   "Cannot re-enable PCI device after reset.\n");
+  return PCI_ERS_RESULT_DISCONNECT;
+ }
+ pci_set_master(pdev);
+ pci_enable_wake(pdev, PCI_D0, 0);
+ pch_gbe_hal_power_up_phy(hw);
+ pch_gbe_reset(adapter);
+ /* Clear wake up status */
+ pch_gbe_hal_set_wol_event(hw, 0);
+
+ return PCI_ERS_RESULT_RECOVERED;
+}
+
+/*!
+ * @ingroup PCI driver method
+ * @fn      static void pch_gbe_io_resume(struct pci_dev *pdev)
+ * @brief   Called when traffic can start flowing again.
+ * @param   pdev    [INOUT] PCI device information struct
+ * @return  PCI_ERS_RESULT_DISCONNECT
+ * @return  PCI_ERS_RESULT_RECOVERED
+ * @remarks
+ *   This callback is called when the error recovery driver tells us that
+ *   its OK to resume normal operation. Implementation resembles the
+ *   second-half of the pch_gbe_resume routine.
+ */
+static void pch_gbe_io_resume(struct pci_dev *pdev)
+{
+ struct net_device *netdev = pci_get_drvdata(pdev);
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ if (netif_running(netdev) != 0) {
+  if (pch_gbe_up(adapter) != 0) {
+   DPRINTK(PROBE, DEBUG,
+    "can't bring device back up after reset\n");
+   return;
+  }
+ }
+ netif_device_attach(netdev);
+}
+
+/* ------------------------------------------------------------------------
----
+ Gigabit Ethernet driver methods
+---------------------------------------------------------------------------
- */
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int __init pch_gbe_init_module(void)
+ * @brief   Driver Registration Routine
+ * @return  PCH_GBE_SUCCESS  Successfully
+ * @return  negative value  Failed
+ * @remarks
+ *   pch_gbe_init_module is the first routine called when the driver is
+ *   loaded. All it does is register with the PCI subsystem.
+ */
+static int __init pch_gbe_init_module(void)
+{
+ int ret;
+ PCH_DEBUG("pch_gbe_init_module\n");
+ printk(KERN_INFO "%s - version %s\n", DRV_STRING, DRV_VERSION);
+
+ ret = pci_register_driver(&pch_gbe_pcidev);
+ if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
+  if (copybreak == 0) {
+   printk(KERN_INFO "pch_gbe: copybreak disabled\n");
+  } else {
+   printk(KERN_INFO "pch_gbe: copybreak enabled for "
+    "packets <= %u bytes\n", copybreak);
+  }
+ }
+ return ret;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static void __exit pch_gbe_exit_module(void)
+ * @brief   Driver Exit Cleanup Routine
+ * @return  None
+ * @remarks
+ *   pch_gbe_exit_module is called just before the driver is removed
+ *   from memory.
+ */
+static void __exit pch_gbe_exit_module(void)
+{
+ PCH_DEBUG("pch_gbe_exit_module\n");
+ pci_unregister_driver(&pch_gbe_pcidev);
+
+ printk(KERN_INFO "%s - unregister\n", DRV_STRING);
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_open(struct net_device *netdev)
+ * @brief   Called when a network interface is made active
+ * @param   netdev  [INOUT] network interface device structure
+ * @return  PCH_GBE_SUCCESS - Successfully
+ * @return  negative value - Failed
+ * @remarks
+ *   The open entry point is called when a network interface is made
+ *   active by the system (IFF_UP).  At this point all resources needed
+ *   for transmit and receive operations are allocated, the interrupt
+ *   handler is registered with the OS, the watchdog timer is started,
+ *   and the stack is notified that the interface is ready.
+ */
+static int pch_gbe_open(struct net_device *netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+ int err;
+
+ DPRINTK(IFUP, DEBUG, "\n");
+
+ /* disallow open during test */
+ if ((test_bit(__PCH_GBE_TESTING, &adapter->flags)) != 0)
+  return -EBUSY;
+ /* allocate transmit descriptors */
+ err = pch_gbe_setup_tx_resources(adapter, adapter->tx_ring);
+ if (err != 0)
+  goto err_setup_tx;
+ /* allocate receive descriptors */
+ err = pch_gbe_setup_rx_resources(adapter, adapter->rx_ring);
+ if (err != 0)
+  goto err_setup_rx;
+ pch_gbe_hal_power_up_phy(hw);
+ err = pch_gbe_up(adapter);
+ if (err != 0)
+  goto err_up;
+ DPRINTK(IFUP, DEBUG, "Success End\n");
+ return PCH_GBE_SUCCESS;
+
+err_up:
+ if (!adapter->wake_up_evt)
+  pch_gbe_hal_power_down_phy(hw);
+ pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+err_setup_rx:
+ pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
+err_setup_tx:
+ pch_gbe_reset(adapter);
+ DPRINTK(IFUP, ERR, "Error End\n");
+ return err;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_stop(struct net_device *netdev)
+ * @brief   Disables a network interface
+ * @param   netdev  [INOUT] network interface device structure
+ * @return  PCH_GBE_SUCCESS - Successfully (This is not allowed to fail)
+ * @remarks
+ *   The close entry point is called when an interface is de-activated
+ *   by the OS.  The hardware is still under the drivers control, but
+ *   needs to be disabled.  A global MAC reset is issued to stop the
+ *   hardware, and all transmit and receive resources are freed.
+ */
+static int pch_gbe_stop(struct net_device *netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+
+ DPRINTK(IFDOWN, DEBUG, "\n");
+
+ pch_gbe_down(adapter);
+ if (!adapter->wake_up_evt)
+  pch_gbe_hal_power_down_phy(hw);
+ pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
+ pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_xmit_frame(struct sk_buff *skb,
+ *                                        struct net_device *netdev)
+ * @brief   Packet transmitting start
+ * @param   skb    [INOUT] socket buffer structure
+ * @param   netdev [INOUT] network interface device structure
+ * @return  NETDEV_TX_OK: Normal end
+ * @return  NETDEV_TX_BUSY: Error end
+ */
+static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device
*netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
+ unsigned long flags;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ if (unlikely(skb->len <= 0)) {
+  dev_kfree_skb_any(skb);
+  PCH_DEBUG("Return : OK  skb len : %d\n", skb->len);
+  return NETDEV_TX_OK;
+ }
+ if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
+  DPRINTK(PROBE, ERR, "Transfer length Error: %d over %d\n",
+   skb->len, adapter->hw.mac.max_frame_size);
+  dev_kfree_skb_any(skb);
+  adapter->stats.tx_length_errors++;
+  return NETDEV_TX_BUSY;
+ }
+ if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+  /* Collision - tell upper layer to requeue */
+  return NETDEV_TX_LOCKED;
+ }
+ if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
+  netif_stop_queue(netdev);
+  spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+  PCH_DEBUG
+  ("Return : BUSY  next_to use : 0x%08x  "
+   "next_to clean : 0x%08x\n",
+   tx_ring->next_to_use, tx_ring->next_to_clean);
+  return NETDEV_TX_BUSY;
+ }
+ spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
+ /* CRC,ITAG no support */
+ pch_gbe_tx_queue(adapter, tx_ring, skb);
+ netdev->trans_start = jiffies;
+ return NETDEV_TX_OK;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static struct net_device_stats *pch_gbe_get_stats(
+ *                                          struct net_device *netdev)
+ * @brief   Get System Network Statistics
+ * @param   netdev [INOUT] network interface device structure
+ * @return  The current stats
+ * @remarks
+ *   Returns the address of the device statistics structure.
+ *   The statistics are actually updated from the timer callback.
+ */
+static struct net_device_stats *pch_gbe_get_stats(struct net_device
*netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ /* only return the current stats */
+ return &adapter->net_stats;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static void pch_gbe_set_multi(struct net_device *netdev)
+ * @brief   Multicast and Promiscuous mode set
+ * @param   netdev [INOUT] network interface device structure
+ * @return  None
+ * @remarks
+ *   The set_multi entry point is called whenever the multicast address
+ *   list or the network interface flags are updated.  This routine is
+ *   responsible for configuring the hardware for proper multicast,
+ *   promiscuous mode, and all-multi behavior.
+ */
+static void pch_gbe_set_multi(struct net_device *netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct pch_gbe_hw *hw = &adapter->hw;
+ struct pch_gbe_mac_info *mac = &hw->mac;
+ struct dev_mc_list *mc_ptr;
+ u8 *mta_list;
+ u32 rctl;
+ int i;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+ PCH_DEBUG("netdev->flags : 0x%08x\n", netdev->flags);
+
+ /* Check for Promiscuous and All Multicast modes */
+ rctl = PCH_GBE_READ_REG(hw, RX_MODE);
+
+ if ((netdev->flags & IFF_PROMISC) != 0) {
+  rctl &= ~PCH_GBE_ADD_FIL_EN;
+  rctl &= ~PCH_GBE_MLT_FIL_EN;
+ } else if ((netdev->flags & IFF_ALLMULTI) != 0) {
+  /* all the multicasting receive permissions */
+  rctl |= PCH_GBE_ADD_FIL_EN;
+  rctl &= ~PCH_GBE_MLT_FIL_EN;
+ } else {
+  if (netdev->mc_count >= PCH_GBE_MAR_ENTRIES) {
+   /* all the multicasting receive permissions */
+   rctl |= PCH_GBE_ADD_FIL_EN;
+   rctl &= ~PCH_GBE_MLT_FIL_EN;
+  } else {
+   rctl |= (PCH_GBE_ADD_FIL_EN | PCH_GBE_MLT_FIL_EN);
+  }
+ }
+ PCH_GBE_WRITE_REG(hw, RX_MODE, rctl);
+
+ if (netdev->mc_count >= PCH_GBE_MAR_ENTRIES)
+  return;
+ mta_list = kmalloc(netdev->mc_count * ETH_ALEN, GFP_ATOMIC);
+ if (!mta_list)
+  return;
+ /* The shared function expects a packed array of only addresses. */
+ mc_ptr = netdev->mc_list;
+
+ for (i = 0; i < netdev->mc_count; i++) {
+  if (!mc_ptr)
+   break;
+  memcpy(mta_list + (i * ETH_ALEN), mc_ptr->dmi_addr, ETH_ALEN);
+  mc_ptr = mc_ptr->next;
+ }
+
+ pch_gbe_hal_mc_addr_list_update(hw, mta_list, i, 1,
+     mac->mar_entry_count);
+ kfree(mta_list);
+
+ PCH_DEBUG
+ ("RX_MODE reg(check bit31,30 ADD,MLT) : 0x%08x  "
+  "netdev->mc_count : 0x%08x\n",
+  PCH_GBE_READ_REG(hw, RX_MODE), netdev->mc_count);
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_set_mac(struct net_device *netdev, void
*addr)
+ * @brief   Change the Ethernet Address of the NIC
+ * @param   netdev [INOUT] Network interface device structure
+ * @param   addr   [IN] Pointer to an address structure
+ * @return  PCH_GBE_SUCCESS: Successfully
+ * @return  -EADDRNOTAVAIL:  Failed
+ */
+static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ struct sockaddr *skaddr = addr;
+ int ret_val;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ if (!is_valid_ether_addr(skaddr->sa_data)) {
+  ret_val = -EADDRNOTAVAIL;
+ } else {
+  memcpy(netdev->dev_addr, skaddr->sa_data, netdev->addr_len);
+  memcpy(adapter->hw.mac.addr, skaddr->sa_data, netdev->addr_len);
+  pch_gbe_hal_mar_set(&adapter->hw, adapter->hw.mac.addr, 0);
+  ret_val = PCH_GBE_SUCCESS;
+ }
+#ifdef DEBUG_TEST
+ PCH_DEBUG("ret_val : 0x%08x\n", ret_val);
+ PCH_DEBUG("dev_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
+   netdev->dev_addr[0], netdev->dev_addr[1],
+   netdev->dev_addr[2], netdev->dev_addr[3],
+   netdev->dev_addr[4], netdev->dev_addr[5]);
+ PCH_DEBUG("mac_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
+   adapter->hw.mac.addr[0], adapter->hw.mac.addr[1],
+   adapter->hw.mac.addr[2], adapter->hw.mac.addr[3],
+   adapter->hw.mac.addr[4], adapter->hw.mac.addr[5]);
+ PCH_DEBUG("MAC_ADR1AB reg : 0x%08x 0x%08x\n",
+   PCH_GBE_READ_REG(&adapter->hw, MAC_ADR1A),
+   PCH_GBE_READ_REG(&adapter->hw, MAC_ADR1B));
+#endif
+ return ret_val;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_change_mtu(struct net_device *netdev,
+ *                                        int new_mtu)
+ * @brief   Change the Maximum Transfer Unit
+ * @param   netdev  [INOUT] Network interface device structure
+ * @param   new_mtu [IN] New value for maximum frame size
+ * @return  PCH_GBE_SUCCESS: Successfully
+ * @return  -EINVAL:  Failed
+ */
+static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+ int max_frame;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+
+ max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+ if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+  (max_frame > PCH_GBE_MAX_JUMBO_FRAME_SIZE)) {
+  DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
+  return -EINVAL;
+ }
+ if (max_frame <= PCH_GBE_FRAME_SIZE_2048)
+  adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_2048;
+ else if (max_frame <= PCH_GBE_FRAME_SIZE_4096)
+  adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_4096;
+ else if (max_frame <= PCH_GBE_FRAME_SIZE_8192)
+  adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_8192;
+ else
+  adapter->rx_buffer_len = PCH_GBE_MAX_JUMBO_FRAME_SIZE;
+ netdev->mtu = new_mtu;
+ adapter->hw.mac.max_frame_size = max_frame;
+
+ if (netif_running(netdev) != 0)
+  pch_gbe_reinit_locked(adapter);
+ else
+  pch_gbe_reset(adapter);
+
+ PCH_DEBUG
+ ("max_frame : %d  rx_buffer_len : %d  mtu : %d  max_frame_size : %d\n",
+  max_frame, (u32) adapter->rx_buffer_len, netdev->mtu,
+  adapter->hw.mac.max_frame_size);
+
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_ioctl(struct net_device *netdev,
+ *                                   struct ifreq *ifr, int cmd)
+ * @brief   Controls register through a MII interface
+ * @param   netdev   [INOUT] Network interface device structure
+ * @param   ifr      [IN] Pointer to ifr structure
+ * @param   cmd      [IN] Control command
+ * @return  PCH_GBE_SUCCESS: Successfully
+ * @return  Negative value:  Failed
+ */
+static int pch_gbe_ioctl(struct net_device *netdev, struct ifreq *ifr, int
cmd)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+ PCH_DEBUG("cmd : 0x%04x\n", cmd);
+
+ return generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static void pch_gbe_tx_timeout(struct net_device *netdev)
+ * @brief   Respond to a Tx Hang
+ * @param   netdev   [INOUT] Network interface device structure
+ * @return  None
+ */
+static void pch_gbe_tx_timeout(struct net_device *netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(TX_ERR, DEBUG, "\n");
+
+ /* Do the reset outside of interrupt context */
+ adapter->stats.tx_timeout_count++;
+ schedule_work(&adapter->reset_task);
+}
+
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static int pch_gbe_napi_poll(struct napi_struct *napi, int
budget)
+ * @brief   NAPI receive and transfer polling callback
+ * @param   napi    [INOUT] Pointer of polling device struct
+ * @param   budget  [IN] The maximum number of a packet
+ * @return  0 : Exit the polling mode
+ * @return  1 : Continue the polling mode
+ */
+static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
+{
+ struct pch_gbe_adapter *adapter =
+     container_of(napi, struct pch_gbe_adapter, napi);
+ struct net_device *netdev = adapter->netdev;
+ int work_done = 0;
+ int poll_end_flag = 0;
+ int cleaned = 0;
+
+ DPRINTK(PROBE, DEBUG, "\n");
+ PCH_DEBUG("budget : %d\n", budget);
+
+ /* Keep link state information with original netdev */
+ if (!netif_carrier_ok(netdev)) {
+  poll_end_flag = 1;
+ } else {
+  cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
+  pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
+
+  if (cleaned)
+   work_done = budget;
+  /* If no Tx and not enough Rx work done,
+   * exit the polling mode
+   */
+  if ((work_done < budget) || !netif_running(netdev))
+   poll_end_flag = 1;
+ }
+
+ if (poll_end_flag == 1) {
+  napi_complete(napi);
+  pch_gbe_irq_enable(adapter);
+ }
+
+ PCH_DEBUG("poll_end_flag : %d  work_done : %d  budget : %d\n",
+   poll_end_flag, work_done, budget);
+ return work_done;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*!
+ * @ingroup Gigabit Ethernet driver methods
+ * @fn      static void pch_gbe_netpoll(struct net_device *netdev)
+ * @brief   Used by things like netconsole to send skbs
+ * @param   netdev  [INOUT] Network interface device structure
+ * @return  None
+ * @remarks
+ *   used by things like netconsole to send skbs
+ *   without having to re-enable interrupts.
+ *   It's not called while the interrupt routine is executing.
+ */
+static void pch_gbe_netpoll(struct net_device *netdev)
+{
+ struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+ DPRINTK(PROBE, DEBUG, "\n");
+

