From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Subject: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 18:56:55 +0900
Message-ID: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>
To: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:20684 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752520Ab0HZJ5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 05:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
Gigabit Ethernet driver of Topcliff PCH

Topcliff PCH is the platform controller hub that is going to be used in
Intel's upcoming general embedded platform. All IO peripherals in
Topcliff PCH are actually devices sitting on AMBA bus. 
Topcliff PCH has Gigabit Ethernet I/F. Using this I/F, it is able to 
access system devices connected to Gigabit Ethernet.

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/Kconfig                   |    5 +
 drivers/net/Makefile                  |    1 +
 drivers/net/pch_gbe/Makefile          |    6 +
 drivers/net/pch_gbe/pch_gbe.h         |  425 ++++++
 drivers/net/pch_gbe/pch_gbe_api.c     |  247 +++
 drivers/net/pch_gbe/pch_gbe_api.h     |   31 +
 drivers/net/pch_gbe/pch_gbe_ethtool.c |  623 ++++++++
 drivers/net/pch_gbe/pch_gbe_main.c    | 2695 +++++++++++++++++++++++++++++++++
 drivers/net/pch_gbe/pch_gbe_param.c   |  516 +++++++
 drivers/net/pch_gbe/pch_gbe_phy.c     |  277 ++++
 drivers/net/pch_gbe/pch_gbe_phy.h     |   32 +
 drivers/net/pch_gbe/pch_gbe_regs.h    |  305 ++++
 12 files changed, 5163 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/pch_gbe/Makefile
 create mode 100644 drivers/net/pch_gbe/Module.symvers
 create mode 100644 drivers/net/pch_gbe/pch_gbe.h
 create mode 100644 drivers/net/pch_gbe/pch_gbe_api.c
 create mode 100644 drivers/net/pch_gbe/pch_gbe_api.h
 create mode 100644 drivers/net/pch_gbe/pch_gbe_ethtool.c
 create mode 100644 drivers/net/pch_gbe/pch_gbe_main.c
 create mode 100644 drivers/net/pch_gbe/pch_gbe_param.c
 create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.c
 create mode 100644 drivers/net/pch_gbe/pch_gbe_phy.h
 create mode 100644 drivers/net/pch_gbe/pch_gbe_regs.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2decc59..fcc6b7b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2004,6 +2004,11 @@ menuconfig NETDEV_1000
 	  If you say N, all options in this submenu will be skipped and disabled.
 
 if NETDEV_1000
+config PCH_GBE
+        tristate "PCH Gigabit Ethernet"
+        ---help---
+          This is an gigabit ethernet driver for PCH.
+          resources.
 
 config ACENIC
 	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0a0512a..3df2467 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -295,3 +295,4 @@ obj-$(CONFIG_WIMAX) += wimax/
 obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
+obj-$(CONFIG_PCH_GBE) += pch_gbe/
diff --git a/drivers/net/pch_gbe/Makefile b/drivers/net/pch_gbe/Makefile
new file mode 100644
index 0000000..008fa22
--- /dev/null
+++ b/drivers/net/pch_gbe/Makefile
@@ -0,0 +1,6 @@
+ifeq ($(CONFIG_PCH_GBE_DEBUG_CORE),y)
+EXTRA_CFLAGS += -DDEBUG
+endif
+
+obj-$(CONFIG_PCH_GBE) += pch_gbe.o
+pch_gbe-objs := pch_gbe_phy.o pch_gbe_ethtool.o pch_gbe_param.o pch_gbe_api.o pch_gbe_main.o
diff --git a/drivers/net/pch_gbe/Module.symvers b/drivers/net/pch_gbe/Module.symvers
new file mode 100644
index 0000000..e69de29
diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
new file mode 100644
index 0000000..a2b92dd
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -0,0 +1,425 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#ifndef _PCH_GBE_H_
+#define _PCH_GBE_H_
+
+#include <linux/netdevice.h>
+#include <linux/mii.h>
+
+#undef FALSE
+#define FALSE	0
+#undef TRUE
+#define TRUE	1
+
+#ifdef DEBUG
+#define PCH_GBE_DEBUG(fmt, args...)\
+	printk(KERN_DEBUG KBUILD_MODNAME ": " fmt, ##args)
+#else
+#define PCH_GBE_DEBUG(fmt, args...)	do { } while (0)
+#endif
+
+/* Device Driver infomation */
+#define DRV_STRING      "PCH Network Driver"
+#define DRV_EXT         "-NAPI"
+#define DRV_VERSION     "0.95"DRV_EXT
+#define DRV_DESCRIPTION \
+	"OKI semiconductor sample Linux driver for PCH Gigabit ethernet"
+#define DRV_COPYRIGHT   "Copyright(c) 2010 OKI semiconductor"
+#define FIRM_VERSION    "N/A"
+/* TX/RX descriptor defines */
+#define PCH_GBE_MAX_TXD                     4096
+#define PCH_GBE_MIN_TXD                        8
+#define PCH_GBE_MAX_RXD                     4096
+#define PCH_GBE_MIN_RXD                        8
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
+#define PCH_GBE_TX_DESC_MULTIPLE               8
+#define PCH_GBE_RX_DESC_MULTIPLE               8
+/* only works for sizes that are powers of 2 */
+#define PCH_GBE_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) - 1)))
+
+
+/* Read operation is done through MII Management IF */
+#define PCH_GBE_HAL_MIIM_READ          ((u32)0x00000000)
+/* Write operation is done through MII Management IF */
+#define PCH_GBE_HAL_MIIM_WRITE         ((u32)0x04000000)
+
+/* flow control values */
+#define PCH_GBE_FC_NONE			0
+#define PCH_GBE_FC_RX_PAUSE		1
+#define PCH_GBE_FC_TX_PAUSE		2
+#define PCH_GBE_FC_FULL			3
+
+#define PCH_GBE_FC_DEFAULT  PCH_GBE_FC_FULL
+#define PCH_GBE_PHY_REGS_LEN    32
+/* IF OPTION */
+#define PCH_GBE_MAC_IFOP_RGMII
+
+struct pch_gbe_hw;
+/**
+ * struct  pch_gbe_functions - HAL APi function pointer
+ * @get_bus_info:	for pch_gbe_hal_get_bus_info
+ * @init_hw:		for pch_gbe_hal_init_hw
+ * @read_phy_reg:	for pch_gbe_hal_read_phy_reg
+ * @write_phy_reg:	for pch_gbe_hal_write_phy_reg
+ * @reset_phy:		for pch_gbe_hal_phy_hw_reset
+ * @sw_reset_phy:	for pch_gbe_hal_phy_sw_reset
+ * @power_up_phy:	for pch_gbe_hal_power_up_phy
+ * @power_down_phy:	for pch_gbe_hal_power_down_phy
+ * @read_mac_addr:	for pch_gbe_hal_read_mac_addr
+ */
+struct pch_gbe_functions {
+	void (*get_bus_info) (struct pch_gbe_hw *);
+	s32(*init_hw) (struct pch_gbe_hw *);
+	s32(*read_phy_reg) (struct pch_gbe_hw *, u32, u16 *);
+	s32(*write_phy_reg) (struct pch_gbe_hw *, u32, u16);
+	void (*reset_phy) (struct pch_gbe_hw *);
+	void (*sw_reset_phy) (struct pch_gbe_hw *);
+	void (*power_up_phy) (struct pch_gbe_hw *hw);
+	void (*power_down_phy) (struct pch_gbe_hw *hw);
+	s32(*read_mac_addr) (struct pch_gbe_hw *);
+};
+
+/**
+ * struct pch_gbe_mac_info - MAC infomation
+ * @addr[6]:		Store the MAC address
+ * @fc:			Mode of flow control
+ * @fc_autoneg:		Auto negotiation enable for flow control setting
+ * @tx_fc_enable:	Enable flag of Transmit flow control
+ * @max_frame_size:	Max transmit frame size
+ * @min_frame_size:	Min transmit frame size
+ * @autoneg:		Auto negotiation enable
+ * @link_speed:		Link speed
+ * @link_duplex:	Link duplex
+ */
+struct pch_gbe_mac_info {
+	u8 addr[6];
+	u8 fc;
+	u8 fc_autoneg;
+	u8 tx_fc_enable;
+	u32 max_frame_size;
+	u32 min_frame_size;
+	u8 autoneg;
+	u16 link_speed;
+	u16 link_duplex;
+};
+
+/**
+ * struct pch_gbe_phy_info - PHY infomation
+ * @addr:		PHY address
+ * @id:			PHY's identifier
+ * @revision:		PHY's revision
+ * @reset_delay_us:	HW reset delay time[us]
+ * @autoneg_advertised:	Autoneg advertised
+ */
+struct pch_gbe_phy_info {
+	u32 addr;
+	u32 id;
+	u32 revision;
+	u32 reset_delay_us;
+	u16 autoneg_advertised;
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_bus_info
+ * @brief   Bus infomation
+ */
+struct pch_gbe_bus_info {
+	u8 type;
+	u8 speed;
+	u8 width;
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_hw
+ * @brief   Hardware infomation
+ */
+struct pch_gbe_hw {
+	void *back;
+
+	struct pch_gbe_regs  __iomem *reg;
+	spinlock_t miim_lock;
+
+	struct pch_gbe_functions func;
+	struct pch_gbe_mac_info mac;
+	struct pch_gbe_phy_info phy;
+	struct pch_gbe_bus_info bus;
+
+	u16 vendor_id;
+	u16 device_id;
+	u16 subsystem_vendor_id;
+	u16 subsystem_device_id;
+	u8 revision_id;
+};
+
+/**
+ * struct pch_gbe_rx_desc - Receive Descriptor
+ * @buffer_addr:	RX Frame Buffer Address
+ * @tcp_ip_status:	TCP/IP Accelerator Status
+ * @rx_words_eob:	RX word count and Byte position
+ * @gbec_status:	GMAC Status
+ * @dma_status:		DMA Status
+ * @reserved1:		Reserved
+ * @reserved2:		Reserved
+ */
+struct pch_gbe_rx_desc {
+	u32 buffer_addr;
+	u32 tcp_ip_status;
+	u16 rx_words_eob;
+	u16 gbec_status;
+	u8 dma_status;
+	u8 reserved1;
+	u16 reserved2;
+};
+
+/**
+ * struct pch_gbe_tx_desc - Transmit Descriptor
+ * @buffer_addr:	TX Frame Buffer Address
+ * @length:		Data buffer length
+ * @reserved1:		Reserved
+ * @tx_words_eob:	TX word count and Byte position
+ * @tx_frame_ctrl:	TX Frame Control
+ * @dma_status:		DMA Status
+ * @reserved2:		Reserved
+ * @gbec_status:	GMAC Status
+ */
+struct pch_gbe_tx_desc {
+	u32 buffer_addr;
+	u16 length;
+	u16 reserved1;
+	u16 tx_words_eob;
+	u16 tx_frame_ctrl;
+	u8 dma_status;
+	u8 reserved2;
+	u16 gbec_status;
+};
+
+
+/**
+ * struct pch_gbe_buffer - Buffer infomation
+ * @skb:	pointer to a socket buffer
+ * @kernel_skb:	pointer to a socket buffer received from the kernel
+ * @dma:	DMA address
+ * @time_stamp:	time stamp
+ * @length:	data size
+ */
+struct pch_gbe_buffer {
+	struct sk_buff *skb;
+	struct sk_buff *kernel_skb;
+	dma_addr_t dma;
+	unsigned long time_stamp;
+	u16 length;
+};
+
+/**
+ * struct pch_gbe_tx_ring - tx ring infomation
+ * @tx_lock:	spinlock structs
+ * @desc:	pointer to the descriptor ring memory
+ * @dma:	physical address of the descriptor ring
+ * @size:	length of descriptor ring in bytes
+ * @count:	number of descriptors in the ring
+ * @next_to_use:	next descriptor to associate a buffer with
+ * @next_to_clean:	next descriptor to check for DD status bit
+ * @buffer_info:	array of buffer information structs
+ */
+struct pch_gbe_tx_ring {
+	spinlock_t tx_lock;
+	struct pch_gbe_tx_desc *desc;
+	dma_addr_t dma;
+	unsigned int size;
+	unsigned int count;
+	unsigned int next_to_use;
+	unsigned int next_to_clean;
+	struct pch_gbe_buffer *buffer_info;
+};
+
+/**
+ * struct pch_gbe_rx_ring - rx ring infomation
+ * @desc:	pointer to the descriptor ring memory
+ * @dma:	physical address of the descriptor ring
+ * @size:	length of descriptor ring in bytes
+ * @count:	number of descriptors in the ring
+ * @next_to_use:	next descriptor to associate a buffer with
+ * @next_to_clean:	next descriptor to check for DD status bit
+ * @buffer_info:	array of buffer information structs
+ */
+struct pch_gbe_rx_ring {
+	struct pch_gbe_rx_desc *desc;
+	dma_addr_t dma;
+	unsigned int size;
+	unsigned int count;
+	unsigned int next_to_use;
+	unsigned int next_to_clean;
+	struct pch_gbe_buffer *buffer_info;
+};
+
+/**
+ * struct pch_gbe_hw_stats - Statistics counters collected by the MAC
+ * @rx_packets:		    total packets received
+ * @tx_packets:		    total packets transmitted
+ * @rx_bytes:		    total bytes received
+ * @tx_bytes:		    total bytes transmitted
+ * @rx_errors:		    bad packets received
+ * @tx_errors:		    packet transmit problems
+ * @rx_dropped:		    no space in Linux buffers
+ * @tx_dropped:		    no space available in Linux
+ * @multicast:		    multicast packets received
+ * @collisions:		    collisions
+ * @rx_crc_errors:	    received packet with crc error
+ * @rx_frame_errors:	    received frame alignment error
+ * @rx_alloc_buff_failed:   allocate failure of a receive buffer
+ * @tx_length_errors:	    transmit length error
+ * @tx_aborted_errors:	    transmit aborted error
+ * @tx_carrier_errors:	    transmit carrier error
+ * @tx_timeout_count:	    Number of transmit timeout
+ * @tx_restart_count:	    Number of transmit restert
+ * @intr_rx_dsc_empty_count:	Interrupt count of receive descriptor empty
+ * @intr_rx_frame_err_count:	Interrupt count of receive frame error
+ * @intr_rx_fifo_err_count:	Interrupt count of receive FIFO error
+ * @intr_rx_dma_err_count:	Interrupt count of receive DMA error
+ * @intr_tx_fifo_err_count:	Interrupt count of transmit FIFO error
+ * @intr_tx_dma_err_count:	Interrupt count of transmit DMA error
+ * @intr_tcpip_err_count:	Interrupt count of TCP/IP Accelerator
+ */
+struct pch_gbe_hw_stats {
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 tx_bytes;
+	u64 rx_errors;
+	u64 tx_errors;
+	u64 rx_dropped;
+	u64 tx_dropped;
+	u64 multicast;
+	u64 collisions;
+	u64 rx_crc_errors;
+	u64 rx_frame_errors;
+	u64 rx_alloc_buff_failed;
+	u64 tx_length_errors;
+	u64 tx_aborted_errors;
+	u64 tx_carrier_errors;
+	u64 tx_timeout_count;
+	u64 tx_restart_count;
+	u64 intr_rx_dsc_empty_count;
+	u64 intr_rx_frame_err_count;
+	u64 intr_rx_fifo_err_count;
+	u64 intr_rx_dma_err_count;
+	u64 intr_tx_fifo_err_count;
+	u64 intr_tx_dma_err_count;
+	u64 intr_tcpip_err_count;
+};
+
+/**
+ * struct pch_gbe_adapter - board specific private data structure
+ * @stats_lock:	Spinlock structure for status
+ * @tx_queue_lock:	Spinlock structure for transmit
+ * @int_en_lock:	Spinlock structure for IRQ enable
+ * @irq_sem:		Semaphore for interrupt
+ * @netdev:		Pointer of network device structure
+ * @pdev:		Pointer of pci device structure
+ * @net_stats:		Network status
+ * @polling_netdev:	Pointer of polling network device structure
+ * @napi:		NAPI structure
+ * @hw:			Pointer of hardware structure
+ * @stats:		Hardware status
+ * @reset_task:		Reset task
+ * @mii:		MII information structure
+ * @watchdog_timer:	Watchdog timer list
+ * @wake_up_evt:	Wake up event
+ * @config_space:	Configuration space
+ * @msg_enable:		Driver message level
+ * @blink_timer:	LED blink timer list
+ * @led_status:		LED status
+ * @tx_ring:		Pointer of Tx descriptor ring structure
+ * @rx_ring:		Pointer of Rx descriptor ring structure
+ * @rx_buffer_len:	Receive buffer length
+ * @tx_queue_len:	Transmit queue length
+ * @rx_csum:		Receive TCP/IP checksum enable/disable
+ * @tx_csum:		Transmit TCP/IP checksum enable/disable
+ * @have_msi:		PCI MSI mode flag
+ * @flags:		Driver status flag
+ */
+
+struct pch_gbe_adapter {
+	spinlock_t stats_lock;
+	spinlock_t tx_queue_lock;
+	spinlock_t int_en_lock;
+	atomic_t irq_sem;
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct net_device_stats net_stats;
+	struct net_device *polling_netdev;
+	struct napi_struct napi;
+	struct pch_gbe_hw hw;
+	struct pch_gbe_hw_stats stats;
+	struct work_struct reset_task;
+	struct mii_if_info mii;
+	struct timer_list watchdog_timer;
+	u32 wake_up_evt;
+	u32 *config_space;
+	struct timer_list blink_timer;
+	unsigned long led_status;
+	struct pch_gbe_tx_ring *tx_ring;
+	struct pch_gbe_rx_ring *rx_ring;
+	unsigned long rx_buffer_len;
+	unsigned long tx_queue_len;
+	unsigned char rx_csum;
+	unsigned char tx_csum;
+	unsigned char have_msi;
+	unsigned long flags;
+};
+
+/**
+ * enum pch_gbe_state_t - Driver Status
+ * @__PCH_GBE_TESTING:		Testing
+ * @__PCH_GBE_RESETTING:	Reseting
+ */
+enum pch_gbe_state_t {
+	__PCH_GBE_TESTING,
+	__PCH_GBE_RESETTING,
+};
+
+/* pch_gbe_main.c */
+int pch_gbe_up(struct pch_gbe_adapter *adapter);
+void pch_gbe_down(struct pch_gbe_adapter *adapter);
+void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter);
+void pch_gbe_reset(struct pch_gbe_adapter *adapter);
+int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_tx_ring *txdr);
+int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_rx_ring *rxdr);
+void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_tx_ring *tx_ring);
+void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_rx_ring *rx_ring);
+void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
+int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
+void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg, int data);
+/* pch_gbe_param.c */
+void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
+
+/* pch_gbe_ethtool.c */
+void pch_gbe_set_ethtool_ops(struct net_device *netdev);
+
+/* pch_gbe_mac.c */
+s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw);
+s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw);
+u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw,
+			  u32 addr, u32 dir, u32 reg, u16 data);
+#endif /* _PCH_GBE_H_ */
diff --git a/drivers/net/pch_gbe/pch_gbe_api.c b/drivers/net/pch_gbe/pch_gbe_api.c
new file mode 100644
index 0000000..7783f09
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_api.c
@@ -0,0 +1,247 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include "pch_gbe.h"
+#include "pch_gbe_phy.h"
+
+/* bus type values */
+#define pch_gbe_bus_type_unknown	0
+#define pch_gbe_bus_type_pci		1
+#define pch_gbe_bus_type_pcix		2
+#define pch_gbe_bus_type_pci_express	3
+#define pch_gbe_bus_type_reserved	4
+
+/* bus speed values */
+#define pch_gbe_bus_speed_unknown	0
+#define pch_gbe_bus_speed_33		1
+#define pch_gbe_bus_speed_66		2
+#define pch_gbe_bus_speed_100		3
+#define pch_gbe_bus_speed_120		4
+#define pch_gbe_bus_speed_133		5
+#define pch_gbe_bus_speed_2500		6
+#define pch_gbe_bus_speed_reserved	7
+
+/* bus width values */
+#define pch_gbe_bus_width_unknown	0
+#define pch_gbe_bus_width_pcie_x1	1
+#define pch_gbe_bus_width_pcie_x2	2
+#define pch_gbe_bus_width_pcie_x4	4
+#define pch_gbe_bus_width_32		5
+#define pch_gbe_bus_width_64		6
+#define pch_gbe_bus_width_reserved	7
+
+/**
+ * pch_gbe_plat_get_bus_info - Obtain bus information for adapter
+ * @hw:	Pointer to the HW structure
+ */
+static void pch_gbe_plat_get_bus_info(struct pch_gbe_hw *hw)
+{
+	hw->bus.type  = pch_gbe_bus_type_pci_express;
+	hw->bus.speed = pch_gbe_bus_speed_2500;
+	hw->bus.width = pch_gbe_bus_width_pcie_x1;
+}
+
+/**
+ * pch_gbe_plat_init_hw - Initialize hardware
+ * @hw:	Pointer to the HW structure
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed-EBUSY
+ */
+static s32 pch_gbe_plat_init_hw(struct pch_gbe_hw *hw)
+{
+	s32 ret_val;
+
+	ret_val = pch_gbe_phy_get_id(hw);
+	if (ret_val) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"pch_gbe_phy_get_id error\n");
+		return ret_val;
+	}
+	pch_gbe_phy_init_setting(hw);
+	/* Setup Mac interface option RGMII */
+#ifdef PCH_GBE_MAC_IFOP_RGMII
+	pch_gbe_phy_set_rgmii(hw);
+#endif
+	return ret_val;
+}
+
+/**
+ * pch_gbe_plat_init_function_pointers - Init func ptrs
+ * @hw:	Pointer to the HW structure
+ */
+void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
+{
+	struct pch_gbe_phy_info *phy = &hw->phy;
+	struct pch_gbe_functions *func = &hw->func;
+
+	/* Set PHY parameter */
+	phy->reset_delay_us     = PCH_GBE_PHY_RESET_DELAY_US;
+	/* Set function pointers */
+	func->get_bus_info             = pch_gbe_plat_get_bus_info;
+	func->init_hw                  = pch_gbe_plat_init_hw;
+	func->read_phy_reg             = pch_gbe_phy_read_reg_miic;
+	func->write_phy_reg            = pch_gbe_phy_write_reg_miic;
+	func->reset_phy                = pch_gbe_phy_hw_reset;
+	func->sw_reset_phy             = pch_gbe_phy_sw_reset;
+	func->power_up_phy             = pch_gbe_phy_power_up;
+	func->power_down_phy           = pch_gbe_phy_power_down;
+	func->read_mac_addr            = pch_gbe_mac_read_mac_addr;
+}
+
+/**
+ * pch_gbe_hal_setup_init_funcs - Initializes function pointers
+ * @hw:	Pointer to the HW structure
+ * Returns
+ *	0:	Successfully
+ *	ENOSYS:	Function is not registered
+ */
+inline s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw)
+{
+	if (hw->reg) {
+		pch_gbe_plat_init_function_pointers(hw);
+		return 0;
+	}
+	printk(KERN_ERR KBUILD_MODNAME ": " "ERROR: Registers not mapped\n");
+	return -ENOSYS;
+}
+
+/**
+ * pch_gbe_hal_get_bus_info - Obtain bus information for adapter
+ * @hw:	Pointer to the HW structure
+ */
+inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
+{
+	if (hw->func.get_bus_info)
+		hw->func.get_bus_info(hw);
+	else
+		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");
+}
+
+/**
+ * pch_gbe_hal_init_hw - Initialize hardware
+ * @hw:	Pointer to the HW structure
+ * Returns
+ *	0:	Successfully
+ *	ENOSYS:	Function is not registered
+ */
+inline s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw)
+{
+	if (hw->func.init_hw) {
+		return hw->func.init_hw(hw);
+	} else {
+		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");
+		return -ENOSYS;
+	}
+}
+
+/**
+ * pch_gbe_hal_read_phy_reg - Reads PHY register
+ * @hw:	    Pointer to the HW structure
+ * @offset: The register to read
+ * @data:   The buffer to store the 16-bit read.
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+inline s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset,
+					u16 *data)
+{
+	if (hw->func.read_phy_reg)
+		return hw->func.read_phy_reg(hw, offset, data);
+	else
+		return 0;
+}
+
+/**
+ * pch_gbe_hal_write_phy_reg - Writes PHY register
+ * @hw:	    Pointer to the HW structure
+ * @offset: The register to read
+ * @data:   The value to write.
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+inline s32 pch_gbe_hal_write_phy_reg(struct pch_gbe_hw *hw, u32 offset,
+					u16 data)
+{
+	if (hw->func.write_phy_reg)
+		return hw->func.write_phy_reg(hw, offset, data);
+	else
+		return 0;
+}
+
+/**
+ * pch_gbe_hal_phy_hw_reset - Hard PHY reset
+ * @hw:	    Pointer to the HW structure
+ */
+inline void pch_gbe_hal_phy_hw_reset(struct pch_gbe_hw *hw)
+{
+	if (hw->func.reset_phy)
+		hw->func.reset_phy(hw);
+	else
+		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");
+}
+
+/**
+ * pch_gbe_hal_phy_sw_reset - Soft PHY reset
+ * @hw:	    Pointer to the HW structure
+ */
+inline void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw)
+{
+	if (hw->func.sw_reset_phy)
+		hw->func.sw_reset_phy(hw);
+	else
+		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");
+}
+
+/**
+ * pch_gbe_hal_read_mac_addr - Reads MAC address
+ * @hw:	Pointer to the HW structure
+ * Returns
+ *	0:	Successfully
+ *	ENOSYS:	Function is not registered
+ */
+inline s32 pch_gbe_hal_read_mac_addr(struct pch_gbe_hw *hw)
+{
+	if (hw->func.read_mac_addr) {
+		return hw->func.read_mac_addr(hw);
+	} else {
+		printk(KERN_ERR KBUILD_MODNAME ": " "Error: configuration\n");
+		return -ENOSYS;
+	}
+}
+
+/**
+ * pch_gbe_hal_power_up_phy - Power up PHY
+ * @hw:	Pointer to the HW structure
+ */
+inline void pch_gbe_hal_power_up_phy(struct pch_gbe_hw *hw)
+{
+	if (hw->func.power_up_phy)
+		hw->func.power_up_phy(hw);
+}
+
+/**
+ * pch_gbe_hal_power_down_phy - Power down PHY
+ * @hw:	Pointer to the HW structure
+ */
+inline void pch_gbe_hal_power_down_phy(struct pch_gbe_hw *hw)
+{
+	if (hw->func.power_down_phy)
+		hw->func.power_down_phy(hw);
+}
diff --git a/drivers/net/pch_gbe/pch_gbe_api.h b/drivers/net/pch_gbe/pch_gbe_api.h
new file mode 100644
index 0000000..abf2e62
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_api.h
@@ -0,0 +1,31 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+#ifndef _PCH_GBE_API_H_
+#define _PCH_GBE_API_H_
+
+s32 pch_gbe_hal_setup_init_funcs(struct pch_gbe_hw *hw);
+void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw);
+s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw);
+s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset, u16 *data);
+s32 pch_gbe_hal_write_phy_reg(struct pch_gbe_hw *hw, u32 offset, u16 data);
+void pch_gbe_hal_phy_hw_reset(struct pch_gbe_hw *hw);
+void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw);
+s32 pch_gbe_hal_read_mac_addr(struct pch_gbe_hw *hw);
+void pch_gbe_hal_power_up_phy(struct pch_gbe_hw *hw);
+void pch_gbe_hal_power_down_phy(struct pch_gbe_hw *hw);
+
+#endif
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
new file mode 100644
index 0000000..15affe6
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -0,0 +1,623 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include <linux/pci.h>
+#include <linux/ethtool.h>
+
+#include "pch_gbe_regs.h"
+#include "pch_gbe.h"
+#include "pch_gbe_api.h"
+
+/**
+ * pch_gbe_stats - Stats item infomation
+ */
+struct pch_gbe_stats {
+	signed char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+#define PCH_GBE_STAT(m)	{#m,\
+			 sizeof(((struct pch_gbe_adapter *)0)->stats.m),\
+			 offsetof(struct pch_gbe_adapter, stats.m)}
+/**
+ * pch_gbe_gstrings_stats - ethtool information status name list
+ */
+static const struct pch_gbe_stats pch_gbe_gstrings_stats[] = {
+	PCH_GBE_STAT(rx_packets),
+	PCH_GBE_STAT(tx_packets),
+	PCH_GBE_STAT(rx_bytes),
+	PCH_GBE_STAT(tx_bytes),
+	PCH_GBE_STAT(rx_errors),
+	PCH_GBE_STAT(tx_errors),
+	PCH_GBE_STAT(rx_dropped),
+	PCH_GBE_STAT(tx_dropped),
+	PCH_GBE_STAT(multicast),
+	PCH_GBE_STAT(collisions),
+	PCH_GBE_STAT(rx_crc_errors),
+	PCH_GBE_STAT(rx_frame_errors),
+	PCH_GBE_STAT(rx_alloc_buff_failed),
+	PCH_GBE_STAT(tx_length_errors),
+	PCH_GBE_STAT(tx_aborted_errors),
+	PCH_GBE_STAT(tx_carrier_errors),
+	PCH_GBE_STAT(tx_timeout_count),
+	PCH_GBE_STAT(tx_restart_count),
+	PCH_GBE_STAT(intr_rx_dsc_empty_count),
+	PCH_GBE_STAT(intr_rx_frame_err_count),
+	PCH_GBE_STAT(intr_rx_fifo_err_count),
+	PCH_GBE_STAT(intr_rx_dma_err_count),
+	PCH_GBE_STAT(intr_tx_fifo_err_count),
+	PCH_GBE_STAT(intr_tx_dma_err_count),
+	PCH_GBE_STAT(intr_tcpip_err_count)
+};
+
+#define PCH_GBE_QUEUE_STATS_LEN 0
+#define PCH_GBE_GLOBAL_STATS_LEN	ARRAY_SIZE(pch_gbe_gstrings_stats)
+#define PCH_GBE_STATS_LEN (PCH_GBE_GLOBAL_STATS_LEN + PCH_GBE_QUEUE_STATS_LEN)
+
+#define PCH_GBE_MAC_REGS_LEN    (sizeof(struct pch_gbe_regs) / 4)
+#define PCH_GBE_REGS_LEN        (PCH_GBE_MAC_REGS_LEN + PCH_GBE_PHY_REGS_LEN)
+/**
+ * pch_gbe_get_settings - Get device-specific settings
+ * @netdev: Network interface device structure
+ * @ecmd:   Ethtool command
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_get_settings(struct net_device *netdev,
+				 struct ethtool_cmd *ecmd)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	int ret;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	ret = mii_ethtool_gset(&adapter->mii, ecmd);
+	ecmd->supported &= (u32) (~SUPPORTED_TP);
+	ecmd->supported &= (u32) (~SUPPORTED_1000baseT_Half);
+	ecmd->advertising &= (u32) (~ADVERTISED_TP);
+	ecmd->advertising &= (u32) (~ADVERTISED_1000baseT_Half);
+
+	if (netif_carrier_ok(adapter->netdev)) {
+		;
+	} else {
+		ecmd->speed = 0xFFFF;
+		ecmd->duplex = 0xFF;
+	}
+	return ret;
+}
+
+/**
+ * pch_gbe_set_settings - Set device-specific settings
+ * @netdev: Network interface device structure
+ * @ecmd:   Ethtool command
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_settings(struct net_device *netdev,
+				 struct ethtool_cmd *ecmd)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	int ret;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	while (test_and_set_bit(__PCH_GBE_RESETTING, &adapter->flags))
+		msleep(1);
+	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
+
+	if (ecmd->speed == 0xFFFF)
+		ecmd->speed = SPEED_1000;
+	if (ecmd->duplex == 0xFF)
+		ecmd->duplex = DUPLEX_FULL;
+	ret = mii_ethtool_sset(&adapter->mii, ecmd);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": Error: mii_ethtool_sset\n");
+		clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+		return ret;
+	}
+	hw->mac.link_speed = ecmd->speed;
+	hw->mac.link_duplex = ecmd->duplex;
+	hw->phy.autoneg_advertised = ecmd->advertising;
+	hw->mac.autoneg = ecmd->autoneg;
+	pch_gbe_hal_phy_sw_reset(hw);
+
+	/* reset the link */
+	if (netif_running(adapter->netdev)) {
+		pch_gbe_down(adapter);
+		ret = pch_gbe_up(adapter);
+	} else {
+		pch_gbe_reset(adapter);
+	}
+
+	clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+	return ret;
+}
+
+/**
+ * pch_gbe_get_regs_len - Report the size of device registers
+ * @netdev: Network interface device structure
+ * Returns: the size of device registers.
+ */
+static int pch_gbe_get_regs_len(struct net_device *netdev)
+{
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	return PCH_GBE_REGS_LEN * (int)sizeof(u32);
+}
+
+/**
+ * pch_gbe_get_drvinfo - Report driver information
+ * @netdev:  Network interface device structure
+ * @drvinfo: Driver information structure
+ */
+static void pch_gbe_get_drvinfo(struct net_device *netdev,
+				 struct ethtool_drvinfo *drvinfo)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	strcpy(drvinfo->driver, KBUILD_MODNAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	strcpy(drvinfo->fw_version, FIRM_VERSION);
+	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));
+	drvinfo->regdump_len = pch_gbe_get_regs_len(netdev);
+}
+
+/**
+ * pch_gbe_get_regs - Get device registers
+ * @netdev: Network interface device structure
+ * @regs:   Ethtool register structure
+ * @p:      Buffer pointer of read device register date
+ */
+static void pch_gbe_get_regs(struct net_device *netdev,
+				struct ethtool_regs *regs, void *p)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 *regs_buff = p;
+	u16 i, reg, tmp;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	regs->version = hw->revision_id;
+	regs->version = 0x1000000 | (regs->version << 16) | hw->device_id;
+
+	memset(p, 0, PCH_GBE_REGS_LEN * (int)sizeof(u32));
+	for (i = 0; i < PCH_GBE_MAC_REGS_LEN; i++)
+		regs_buff[i] = ioread32(&hw->reg->INT_ST + i);
+	/* PHY register */
+	for (i = PCH_GBE_MAC_REGS_LEN, reg = 0; reg < PCH_GBE_PHY_REGS_LEN;
+	     i++, reg++) {
+		pch_gbe_hal_read_phy_reg(&adapter->hw, reg, &tmp);
+		regs_buff[i] = tmp;
+	}
+}
+
+/**
+ * pch_gbe_get_wol - Report whether Wake-on-Lan is enabled
+ * @netdev: Network interface device structure
+ * @wol:    Wake-on-Lan information
+ */
+static void pch_gbe_get_wol(struct net_device *netdev,
+				struct ethtool_wolinfo *wol)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	wol->supported = WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
+	wol->wolopts = 0;
+
+	if ((adapter->wake_up_evt & PCH_GBE_WLC_IND))
+		wol->wolopts |= WAKE_UCAST;
+	if ((adapter->wake_up_evt & PCH_GBE_WLC_MLT))
+		wol->wolopts |= WAKE_MCAST;
+	if ((adapter->wake_up_evt & PCH_GBE_WLC_BR))
+		wol->wolopts |= WAKE_BCAST;
+	if ((adapter->wake_up_evt & PCH_GBE_WLC_MP))
+		wol->wolopts |= WAKE_MAGIC;
+	return;
+}
+
+/**
+ * pch_gbe_set_wol - Turn Wake-on-Lan on or off
+ * @netdev: Network interface device structure
+ * @wol:    Pointer of wake-on-Lan information straucture
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_wol(struct net_device *netdev,
+				struct ethtool_wolinfo *wol)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	if ((wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE)))
+		return -EOPNOTSUPP;
+	/* these settings will always override what we currently have */
+	adapter->wake_up_evt = 0;
+
+	if ((wol->wolopts & WAKE_UCAST))
+		adapter->wake_up_evt |= PCH_GBE_WLC_IND;
+	if ((wol->wolopts & WAKE_MCAST))
+		adapter->wake_up_evt |= PCH_GBE_WLC_MLT;
+	if ((wol->wolopts & WAKE_BCAST))
+		adapter->wake_up_evt |= PCH_GBE_WLC_BR;
+	if ((wol->wolopts & WAKE_MAGIC))
+		adapter->wake_up_evt |= PCH_GBE_WLC_MP;
+	return 0;
+}
+
+/**
+ * pch_gbe_nway_reset - Restart autonegotiation
+ * @netdev: Network interface device structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_nway_reset(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	return mii_nway_restart(&adapter->mii);
+}
+
+/**
+ * pch_gbe_get_ringparam - Report ring sizes
+ * @netdev:  Network interface device structure
+ * @ring:    Ring param structure
+ */
+static void pch_gbe_get_ringparam(struct net_device *netdev,
+					struct ethtool_ringparam *ring)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_tx_ring *txdr = adapter->tx_ring;
+	struct pch_gbe_rx_ring *rxdr = adapter->rx_ring;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	ring->rx_max_pending = PCH_GBE_MAX_RXD;
+	ring->tx_max_pending = PCH_GBE_MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rxdr->count;
+	ring->tx_pending = txdr->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+/**
+ * pch_gbe_set_ringparam - Set ring sizes
+ * @netdev:  Network interface device structure
+ * @ring:    Ring param structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_ringparam(struct net_device *netdev,
+					struct ethtool_ringparam *ring)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_tx_ring *txdr, *tx_old;
+	struct pch_gbe_rx_ring *rxdr, *rx_old;
+	int tx_ring_size, rx_ring_size;
+	int err = 0;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+		return -EINVAL;
+	tx_ring_size = (int)sizeof(struct pch_gbe_tx_ring);
+	rx_ring_size = (int)sizeof(struct pch_gbe_rx_ring);
+
+	while ((test_and_set_bit(__PCH_GBE_RESETTING, &adapter->flags)))
+		msleep(1);
+	if ((netif_running(adapter->netdev)))
+		pch_gbe_down(adapter);
+	tx_old = adapter->tx_ring;
+	rx_old = adapter->rx_ring;
+
+	txdr = kzalloc(tx_ring_size, GFP_KERNEL);
+	if (!txdr) {
+		err = -ENOMEM;
+		goto err_alloc_tx;
+	}
+	rxdr = kzalloc(rx_ring_size, GFP_KERNEL);
+	if (!rxdr) {
+		err = -ENOMEM;
+		goto err_alloc_rx;
+	}
+	adapter->tx_ring = txdr;
+	adapter->rx_ring = rxdr;
+
+	rxdr->count = max(ring->rx_pending, (u32) PCH_GBE_MIN_RXD);
+	rxdr->count = min(rxdr->count, (u32) PCH_GBE_MAX_RXD);
+	PCH_GBE_ROUNDUP(rxdr->count, PCH_GBE_RX_DESC_MULTIPLE);
+
+	txdr->count = max(ring->tx_pending, (u32) PCH_GBE_MIN_TXD);
+	txdr->count = min(txdr->count, (u32) PCH_GBE_MAX_TXD);
+	PCH_GBE_ROUNDUP(txdr->count, PCH_GBE_TX_DESC_MULTIPLE);
+
+	if ((netif_running(adapter->netdev))) {
+		/* Try to get new resources before deleting old */
+		err = pch_gbe_setup_rx_resources(adapter, adapter->rx_ring);
+		if (err)
+			goto err_setup_rx;
+		err = pch_gbe_setup_tx_resources(adapter, adapter->tx_ring);
+		if (err)
+			goto err_setup_tx;
+		/* save the new, restore the old in order to free it,
+		 * then restore the new back again */
+		adapter->rx_ring = rx_old;
+		adapter->tx_ring = tx_old;
+		pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+		pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
+		kfree(tx_old);
+		kfree(rx_old);
+		adapter->rx_ring = rxdr;
+		adapter->tx_ring = txdr;
+		err = pch_gbe_up(adapter);
+	}
+
+	clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+	return err;
+
+err_setup_tx:
+	pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+err_setup_rx:
+	adapter->rx_ring = rx_old;
+	adapter->tx_ring = tx_old;
+	kfree(rxdr);
+err_alloc_rx:
+	kfree(txdr);
+err_alloc_tx:
+	if (netif_running(adapter->netdev))
+		pch_gbe_up(adapter);
+	clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+	return err;
+}
+
+/**
+ * pch_gbe_get_pauseparam - Report pause parameters
+ * @netdev:  Network interface device structure
+ * @pause:   Pause parameters structure
+ */
+static void pch_gbe_get_pauseparam(struct net_device *netdev,
+				       struct ethtool_pauseparam *pause)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	pause->autoneg =
+	    ((hw->mac.fc_autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE);
+
+	if (hw->mac.fc == PCH_GBE_FC_RX_PAUSE) {
+		pause->rx_pause = 1;
+	} else if (hw->mac.fc == PCH_GBE_FC_TX_PAUSE) {
+		pause->tx_pause = 1;
+	} else if (hw->mac.fc == PCH_GBE_FC_FULL) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	}
+}
+
+/**
+ * pch_gbe_set_pauseparam - Set pause paramters
+ * @netdev:  Network interface device structure
+ * @pause:   Pause parameters structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_pauseparam(struct net_device *netdev,
+				       struct ethtool_pauseparam *pause)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	int ret = 0;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	hw->mac.fc_autoneg = pause->autoneg;
+	while ((test_and_set_bit(__PCH_GBE_RESETTING, &adapter->flags)))
+		msleep(1);
+	if ((pause->rx_pause) && (pause->tx_pause))
+		hw->mac.fc = PCH_GBE_FC_FULL;
+	else if ((pause->rx_pause) && (!pause->tx_pause))
+		hw->mac.fc = PCH_GBE_FC_RX_PAUSE;
+	else if ((!pause->rx_pause) && (pause->tx_pause))
+		hw->mac.fc = PCH_GBE_FC_TX_PAUSE;
+	else if ((!pause->rx_pause) && (!pause->tx_pause))
+		hw->mac.fc = PCH_GBE_FC_NONE;
+
+	if (hw->mac.fc_autoneg == AUTONEG_ENABLE) {
+		if ((netif_running(adapter->netdev))) {
+			pch_gbe_down(adapter);
+			ret = pch_gbe_up(adapter);
+		} else {
+			pch_gbe_reset(adapter);
+		}
+	} else {
+		ret = pch_gbe_mac_force_mac_fc(hw);
+	}
+	clear_bit(__PCH_GBE_RESETTING, &adapter->flags);
+	return ret;
+}
+
+/**
+ * pch_gbe_get_rx_csum - Report whether receive checksums are turned on or off
+ * @netdev:  Network interface device structure
+ * Returns
+ *	TRUE(1):  Checksum On
+ *	FALSE(0): Checksum Off
+ */
+static u32 pch_gbe_get_rx_csum(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	return adapter->rx_csum;
+}
+
+/**
+ * pch_gbe_set_rx_csum - Turn receive checksum on or off
+ * @netdev:  Network interface device structure
+ * @data:    Checksum On[TRUE] or Off[FALSE]
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+
+	adapter->rx_csum = data;
+	if ((netif_running(netdev)))
+		pch_gbe_reinit_locked(adapter);
+	else
+		pch_gbe_reset(adapter);
+
+	return 0;
+}
+
+/**
+ * pch_gbe_get_tx_csum - Report whether transmit checksums are turned on or off
+ * @netdev:  Network interface device structure
+ * Returns
+ *	TRUE(1):  Checksum On
+ *	FALSE(0): Checksum Off
+ */
+static u32 pch_gbe_get_tx_csum(struct net_device *netdev)
+{
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+/**
+ * pch_gbe_set_tx_csum - Turn transmit checksums on or off
+ * @netdev: Network interface device structure
+ * @data:   Checksum on[TRUE] or off[FALSE]
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_set_tx_csum(struct net_device *netdev, u32 data)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	adapter->tx_csum = data;
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+	return 0;
+}
+
+/**
+ * pch_gbe_get_strings - Return a set of strings that describe the requested
+ *			 objects
+ * @netdev:    Network interface device structure
+ * @stringset: Select the stringset. [ETH_SS_TEST] [ETH_SS_STATS]
+ * @data:      Pointer of read string data.
+ */
+static void pch_gbe_get_strings(struct net_device *netdev, u32 stringset,
+					u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	switch (stringset) {
+	case (u32) ETH_SS_STATS:
+		for (i = 0; i < PCH_GBE_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, pch_gbe_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+/**
+ * pch_gbe_get_ethtool_stats - Return statistics about the device
+ * @netdev: Network interface device structure
+ * @stats:  Ethtool statue structure
+ * @data:   Pointer of read status area
+ */
+static void pch_gbe_get_ethtool_stats(struct net_device *netdev,
+				  struct ethtool_stats *stats, u64 *data)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
+	pch_gbe_update_stats(adapter);
+	for (i = 0; i < PCH_GBE_GLOBAL_STATS_LEN; i++) {
+		signed char *p =
+			(signed char *)adapter +
+			pch_gbe_gstrings_stats[i].stat_offset;
+		data[i] =
+			(pch_gbe_gstrings_stats[i].sizeof_stat ==
+			(int)sizeof(u64)) ? *(u64 *) p:(*(u32 *) p);
+	}
+}
+
+static int pch_gbe_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return PCH_GBE_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static struct ethtool_ops pch_gbe_ethtool_ops = {
+	.get_settings = pch_gbe_get_settings,
+	.set_settings = pch_gbe_set_settings,
+	.get_drvinfo = pch_gbe_get_drvinfo,
+	.get_regs_len = pch_gbe_get_regs_len,
+	.get_regs = pch_gbe_get_regs,
+	.get_wol = pch_gbe_get_wol,
+	.set_wol = pch_gbe_set_wol,
+	.nway_reset = pch_gbe_nway_reset,
+	.get_link = ethtool_op_get_link,
+	.get_ringparam = pch_gbe_get_ringparam,
+	.set_ringparam = pch_gbe_set_ringparam,
+	.get_pauseparam = pch_gbe_get_pauseparam,
+	.set_pauseparam = pch_gbe_set_pauseparam,
+	.get_rx_csum = pch_gbe_get_rx_csum,
+	.set_rx_csum = pch_gbe_set_rx_csum,
+	.get_tx_csum = pch_gbe_get_tx_csum,
+	.set_tx_csum = pch_gbe_set_tx_csum,
+	.get_strings = pch_gbe_get_strings,
+	.get_ethtool_stats = pch_gbe_get_ethtool_stats,
+	.get_sset_count = pch_gbe_get_sset_count,
+};
+
+void pch_gbe_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &pch_gbe_ethtool_ops);
+}
+
+
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
new file mode 100644
index 0000000..d0e0486
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -0,0 +1,2695 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <net/ip.h>
+
+#include "pch_gbe_regs.h"
+#include "pch_gbe.h"
+#include "pch_gbe_api.h"
+
+#define PCI_DEVICE_ID_INTEL_IOH1_GBE    (u16)(0x8802)	/* Pci device ID */
+#define PCH_GBE_MAR_ENTRIES      16
+#define PCH_GBE_SHORT_PKT        64
+#define DSC_INIT16  0xC000
+#define PCH_GBE_DMA_ALIGN        0
+#define PCH_GBE_WATCHDOG_PERIOD        (1 * HZ)	/* watchdog time */
+#define PCH_GBE_COPYBREAK_DEFAULT           256
+#define PCH_GBE_PCI_BAR                     1
+
+#define PCH_GBE_TX_WEIGHT         64
+#define PCH_GBE_RX_WEIGHT         64
+#define PCH_GBE_RX_BUFFER_WRITE   16
+
+/* Initialize the wake-on-LAN settings */
+#define PCH_GBE_WL_INIT_SETTING    (PCH_GBE_WLC_MP)
+
+#define PCH_GBE_MAC_RGMII_CTRL_SETTING ( \
+    PCH_GBE_CHIP_TYPE_INTERNAL | \
+    PCH_GBE_RGMII_MODE_RGMII   | \
+    PCH_GBE_CRS_SEL              \
+    )
+
+/* Ethertype field values */
+#define PCH_GBE_MAX_JUMBO_FRAME_SIZE    10318
+#define PCH_GBE_FRAME_SIZE_2048         2048
+#define PCH_GBE_FRAME_SIZE_4096         4096
+#define PCH_GBE_FRAME_SIZE_8192         8192
+
+#define PCH_GBE_GET_DESC(R, i, type)    (&(((struct type *)((R).desc))[i]))
+#define PCH_GBE_RX_DESC(R, i)           PCH_GBE_GET_DESC(R, i, pch_gbe_rx_desc)
+#define PCH_GBE_TX_DESC(R, i)           PCH_GBE_GET_DESC(R, i, pch_gbe_tx_desc)
+#define PCH_GBE_DESC_UNUSED(R) \
+	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
+	(R)->next_to_clean - (R)->next_to_use - 1)
+
+/* Pause packet value */
+#define	PCH_GBE_PAUSE_PKT1_VALUE    0x00C28001
+#define	PCH_GBE_PAUSE_PKT2_VALUE    0x00000100
+#define	PCH_GBE_PAUSE_PKT4_VALUE    0x01000888
+#define	PCH_GBE_PAUSE_PKT5_VALUE    0x0000FFFF
+
+#define PCH_GBE_ETH_ALEN            6
+
+/* This defines the bits that are set in the Interrupt Mask
+ * Set/Read Register.  Each bit is documented below:
+ *   o RXT0   = Receiver Timer Interrupt (ring 0)
+ *   o TXDW   = Transmit Descriptor Written Back
+ *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
+ *   o RXSEQ  = Receive Sequence Error
+ *   o LSC    = Link Status Change
+ */
+#define PCH_GBE_INT_ENABLE_MASK ( \
+	PCH_GBE_INT_RX_DMA_CMPLT |    \
+	PCH_GBE_INT_RX_DSC_EMP   |    \
+	PCH_GBE_INT_WOL_DET      |    \
+	PCH_GBE_INT_TX_CMPLT          \
+    )
+
+static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
+
+/**
+ * pch_gbe_mac_read_mac_addr - Read MAC address
+ * @hw:	            Pointer to the HW structure
+ * Returns
+ *	0:			Successful.
+ */
+s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
+{
+	u32  adr1a, adr1b;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_read_mac_addr\n");
+
+	adr1a = ioread32(&hw->reg->mac_adr[0].high);
+	adr1b = ioread32(&hw->reg->mac_adr[0].low);
+
+	hw->mac.addr[0] = (u8)(adr1a & 0xFF);
+	hw->mac.addr[1] = (u8)((adr1a >> 8) & 0xFF);
+	hw->mac.addr[2] = (u8)((adr1a >> 16) & 0xFF);
+	hw->mac.addr[3] = (u8)((adr1a >> 24) & 0xFF);
+	hw->mac.addr[4] = (u8)(adr1b & 0xFF);
+	hw->mac.addr[5] = (u8)((adr1b >> 8) & 0xFF);
+
+	PCH_GBE_DEBUG("hw->mac.addr : 0x%02x %02x %02x %02x %02x %02x\n",
+		hw->mac.addr[0], hw->mac.addr[1], hw->mac.addr[2],
+		hw->mac.addr[3], hw->mac.addr[4], hw->mac.addr[5]);
+	return 0;
+}
+
+/**
+ * pch_gbe_mac_mar_set - Set MAC address register
+ * @hw:	    Pointer to the HW structure
+ * @addr:   Pointer to the MAC address
+ * @index:  MAC address array register
+ */
+void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
+{
+	u32 mar_low, mar_high, adrmask;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_mar_set index : 0x%x\n", index);
+
+	/*
+	 * HW expects these in little endian so we reverse the byte order
+	 * from network order (big endian) to little endian
+	 */
+	mar_high = ((u32) addr[0] | ((u32) addr[1] << 8) |
+		   ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+	mar_low = ((u32) addr[4] | ((u32) addr[5] << 8));
+	/* Stop the MAC Address of index. */
+	adrmask = ioread32(&hw->reg->ADDR_MASK);
+	iowrite32((adrmask | (0x0001 << index)), &hw->reg->ADDR_MASK);
+	/* wait busy */
+	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
+		;
+	/* Set the MAC address to the MAC address 1A/1B register */
+	iowrite32(mar_high, &hw->reg->mac_adr[index].high);
+	iowrite32(mar_low, &hw->reg->mac_adr[index].low);
+	/* Start the MAC address of index */
+	iowrite32((adrmask & ~(0x0001 << index)), &hw->reg->ADDR_MASK);
+	/* wait busy */
+	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
+		;
+}
+
+/**
+ * pch_gbe_mac_reset_hw - Reset hardware
+ * @hw:	Pointer to the HW structure
+ */
+void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
+{
+	u32 tmp = 0;
+
+	/* Read the MAC address. and store to the private data */
+	pch_gbe_mac_read_mac_addr(hw);
+	iowrite32(PCH_GBE_ALL_RST, &hw->reg->RESET);
+#ifdef PCH_GBE_MAC_IFOP_RGMII
+	iowrite32(PCH_GBE_MODE_GMII_ETHER, &hw->reg->MODE);
+#endif
+	while (ioread32(&hw->reg->RESET)) {
+		udelay(1);
+		tmp++;
+		if (tmp == 5) {
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"RESET bit is not cleared\n");
+			break;
+		}
+	}
+	/* Setup the receive address */
+	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+	return;
+}
+
+/**
+ * pch_gbe_mac_init_rx_addrs - Initialize receive address's
+ * @hw:	Pointer to the HW structure
+ * @mar_count: Receive address registers
+ */
+void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count)
+{
+	u32 i;
+	PCH_GBE_DEBUG("pch_gbe_mac_init_rx_addrs\n");
+
+	/* Setup the receive address */
+	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+
+	/* Zero out the other receive addresses */
+	for (i = 1; i < mar_count; i++) {
+		iowrite32(0, &hw->reg->mac_adr[i].high);
+		iowrite32(0, &hw->reg->mac_adr[i].low);
+	}
+	iowrite32(0xFFFE, &hw->reg->ADDR_MASK);
+	/* wait busy */
+	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
+		;
+}
+
+
+/**
+ * pch_gbe_mac_mc_addr_list_update - Update Multicast addresses
+ * @hw:	            Pointer to the HW structure
+ * @mc_addr_list:   Array of multicast addresses to program
+ * @mc_addr_count:  Number of multicast addresses to program
+ * @mar_used_count: The first MAC Address register free to program
+ * @mar_total_num:  Total number of supported MAC Address Registers
+ */
+void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+				u8 *mc_addr_list, u32 mc_addr_count,
+				u32 mar_used_count, u32 mar_total_num)
+{
+	u32 i, adrmask;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_mc_addr_list_update\n");
+
+	/* Load the first set of multicast addresses into the exact
+	 * filters (RAR).  If there are not enough to fill the RAR
+	 * array, clear the filters.
+	 */
+	for (i = mar_used_count; i < mar_total_num; i++) {
+		if (mc_addr_count) {
+			pch_gbe_mac_mar_set(hw, mc_addr_list, i);
+			mc_addr_count--;
+			mc_addr_list += PCH_GBE_ETH_ALEN;
+		} else {
+			/* Clear MAC address mask */
+			adrmask = ioread32(&hw->reg->ADDR_MASK);
+			iowrite32((adrmask | (0x0001 << i)),
+					&hw->reg->ADDR_MASK);
+			/* wait busy */
+			while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
+				;
+			/* Clear MAC address */
+			iowrite32(0, &hw->reg->mac_adr[i].high);
+			iowrite32(0, &hw->reg->mac_adr[i].low);
+
+		}
+	}
+}
+
+/**
+ * pch_gbe_mac_force_mac_fc - Force the MAC's flow control settings
+ * @hw:	            Pointer to the HW structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw)
+{
+	struct pch_gbe_mac_info *mac = &hw->mac;
+	u32 rx_fctrl;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_force_mac_fc  mac->fc = %u\n", mac->fc);
+
+	rx_fctrl = ioread32(&hw->reg->RX_FCTRL);
+
+	switch (mac->fc) {
+	case PCH_GBE_FC_NONE:
+		rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+		mac->tx_fc_enable = FALSE;
+		break;
+	case PCH_GBE_FC_RX_PAUSE:
+		rx_fctrl |= PCH_GBE_FL_CTRL_EN;
+		mac->tx_fc_enable = FALSE;
+		break;
+	case PCH_GBE_FC_TX_PAUSE:
+		rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+		mac->tx_fc_enable = TRUE;
+		break;
+	case PCH_GBE_FC_FULL:
+		rx_fctrl |= PCH_GBE_FL_CTRL_EN;
+		mac->tx_fc_enable = TRUE;
+		break;
+	default:
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Flow control param set incorrectly\n");
+		return -EINVAL;
+	}
+	if (mac->link_duplex == DUPLEX_HALF)
+		rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+	iowrite32(rx_fctrl, &hw->reg->RX_FCTRL);
+	PCH_GBE_DEBUG("RX_FCTRL reg : 0x%08x  mac->tx_fc_enable : %d\n",
+			ioread32(&hw->reg->RX_FCTRL), mac->tx_fc_enable);
+	return 0;
+}
+
+/**
+ * pch_gbe_mac_set_wol_event - Set wake-on-lan event
+ * @hw:     Pointer to the HW structure
+ * @wu_evt: Wake up event
+ */
+void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt)
+{
+	u32 addr_mask;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_set_wol_event"
+		  "wu_evt : 0x%08x  ADDR_MASK reg : 0x%08x\n",
+			wu_evt, ioread32(&hw->reg->ADDR_MASK));
+
+	if (wu_evt) {
+		/* Set Wake-On-Lan address mask */
+		addr_mask = ioread32(&hw->reg->ADDR_MASK);
+		iowrite32(addr_mask, &hw->reg->WOL_ADDR_MASK);
+		/* wait busy */
+		while (ioread32(&hw->reg->WOL_ADDR_MASK) & PCH_GBE_WLA_BUSY)
+			;
+		iowrite32(0, &hw->reg->WOL_ST);
+		iowrite32((wu_evt | PCH_GBE_WLC_WOL_MODE), &hw->reg->WOL_CTRL);
+		iowrite32(0x02, &hw->reg->TCPIP_ACC);
+		iowrite32(PCH_GBE_INT_ENABLE_MASK, &hw->reg->INT_EN);
+	} else {
+		iowrite32(0, &hw->reg->WOL_CTRL);
+		iowrite32(0, &hw->reg->WOL_ST);
+	}
+	return;
+}
+
+/**
+ * pch_gbe_mac_ctrl_miim - Control MIIM interface
+ * @hw:   Pointer to the HW structure
+ * @addr: Address of PHY
+ * @dir:  Operetion. (Write or Read)
+ * @reg:  Access register of PHY
+ * @data: Write data.
+ *
+ * Returns: Read date.
+ */
+u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr, u32 dir, u32 reg,
+			u16 data)
+{
+	u32 data_out = 0;
+	unsigned int i;
+	unsigned long flags;
+
+	spin_lock_irqsave(&hw->miim_lock, flags);
+
+	for (i = 100; i; --i) {
+		if ((ioread32(&hw->reg->MIIM) & PCH_GBE_MIIM_OPER_READY))
+			break;
+		udelay(20);
+	}
+	if (i == 0) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"pch-gbe.miim won't go Ready\n");
+		spin_unlock_irqrestore(&hw->miim_lock, flags);
+		return 0;	/* No way to indicate timeout error */
+	}
+	iowrite32(((reg << PCH_GBE_MIIM_REG_ADDR_SHIFT) |
+		  (addr << PCH_GBE_MIIM_PHY_ADDR_SHIFT) |
+		  dir | data), &hw->reg->MIIM);
+	for (i = 0; i < 100; i++) {
+		udelay(20);
+		data_out = ioread32(&hw->reg->MIIM);
+		if ((data_out & PCH_GBE_MIIM_OPER_READY))
+			break;
+	}
+	spin_unlock_irqrestore(&hw->miim_lock, flags);
+
+	PCH_GBE_DEBUG("PHY %s: reg=%d, data=0x%04X\n",
+			dir == PCH_GBE_MIIM_OPER_READ ? "READ" : "WRITE", reg,
+			dir == PCH_GBE_MIIM_OPER_READ ? data_out : data);
+	return (u16) data_out;
+}
+
+/**
+ * pch_gbe_mac_set_pause_packet - Set pause packet
+ * @hw:   Pointer to the HW structure
+ */
+void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
+{
+	unsigned long tmp2, tmp3;
+
+	PCH_GBE_DEBUG("pch_gbe_mac_set_pause_packet\n");
+
+	/* Set Pause packet */
+	tmp2 = hw->mac.addr[1];
+	tmp2 = (tmp2 << 8) | hw->mac.addr[0];
+	tmp2 = PCH_GBE_PAUSE_PKT2_VALUE | (tmp2 << 16);
+
+	tmp3 = hw->mac.addr[5];
+	tmp3 = (tmp3 << 8) | hw->mac.addr[4];
+	tmp3 = (tmp3 << 8) | hw->mac.addr[3];
+	tmp3 = (tmp3 << 8) | hw->mac.addr[2];
+
+	iowrite32(PCH_GBE_PAUSE_PKT1_VALUE, &hw->reg->PAUSE_PKT1);
+	iowrite32(tmp2, &hw->reg->PAUSE_PKT2);
+	iowrite32(tmp3, &hw->reg->PAUSE_PKT3);
+	iowrite32(PCH_GBE_PAUSE_PKT4_VALUE, &hw->reg->PAUSE_PKT4);
+	iowrite32(PCH_GBE_PAUSE_PKT5_VALUE, &hw->reg->PAUSE_PKT5);
+
+	/* Transmit Pause Packet */
+	iowrite32(PCH_GBE_PS_PKT_RQ, &hw->reg->PAUSE_REQ);
+
+	PCH_GBE_DEBUG
+	    ("PAUSE_PKT1-5 reg : 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x\n",
+	     ioread32(&hw->reg->PAUSE_PKT1), ioread32(&hw->reg->PAUSE_PKT2),
+	     ioread32(&hw->reg->PAUSE_PKT3), ioread32(&hw->reg->PAUSE_PKT4),
+	     ioread32(&hw->reg->PAUSE_PKT5));
+
+	return;
+}
+
+
+/**
+ * pch_gbe_alloc_queues - Allocate memory for all rings
+ * @adapter:  Board private structure to initialize
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
+{
+	int size;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+
+	size = (int)sizeof(struct pch_gbe_tx_ring);
+	adapter->tx_ring = kmalloc(size, GFP_KERNEL);
+	if (!adapter->tx_ring)
+		return -ENOMEM;
+	memset(adapter->tx_ring, 0, size);
+
+	size = (int)sizeof(struct pch_gbe_rx_ring);
+	adapter->rx_ring = kmalloc(size, GFP_KERNEL);
+	if (!adapter->rx_ring) {
+		kfree(adapter->tx_ring);
+		return -ENOMEM;
+	}
+	memset(adapter->rx_ring, 0, size);
+
+	size = (int)sizeof(struct net_device);
+	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+	if (!adapter->polling_netdev) {
+		kfree(adapter->tx_ring);
+		kfree(adapter->rx_ring);
+		return -ENOMEM;
+	}
+	memset(adapter->polling_netdev, 0, size);
+	return 0;
+}
+
+/**
+ * pch_gbe_init_stats - Initialize status
+ * @adapter:  Board private structure to initialize
+ */
+static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw_stats *stats = &adapter->stats;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	stats->rx_packets = 0;
+	stats->tx_packets = 0;
+	stats->rx_bytes = 0;
+	stats->tx_bytes = 0;
+	stats->rx_errors = 0;
+	stats->tx_errors = 0;
+	stats->rx_dropped = 0;
+	stats->tx_dropped = 0;
+	stats->multicast = 0;
+	stats->collisions = 0;
+	stats->rx_crc_errors = 0;
+	stats->rx_frame_errors = 0;
+	stats->rx_alloc_buff_failed = 0;
+	stats->tx_length_errors = 0;
+	stats->tx_aborted_errors = 0;
+	stats->tx_carrier_errors = 0;
+	stats->tx_timeout_count = 0;
+	stats->tx_restart_count = 0;
+	stats->intr_rx_dsc_empty_count = 0;
+	stats->intr_rx_frame_err_count = 0;
+	stats->intr_rx_fifo_err_count = 0;
+	stats->intr_rx_dma_err_count = 0;
+	stats->intr_tx_fifo_err_count = 0;
+	stats->intr_tx_dma_err_count = 0;
+	stats->intr_tcpip_err_count = 0;
+	return;
+}
+
+/**
+ * pch_gbe_init_phy - Initialize PHY
+ * @adapter:  Board private structure to initialize
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	u32 addr;
+	u16 bmcr, stat;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Discover phy addr by searching addrs in order {1,0,2,..., 31} */
+	for (addr = 0; addr < PCH_GBE_PHY_REGS_LEN; addr++) {
+		adapter->mii.phy_id = (addr == 0) ? 1 : (addr == 1) ? 0 : addr;
+		bmcr = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMCR);
+		stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
+		stat = pch_gbe_mdio_read(netdev, adapter->mii.phy_id, MII_BMSR);
+		if (!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
+			break;
+	}
+	adapter->hw.phy.addr = adapter->mii.phy_id;
+	PCH_GBE_DEBUG("phy_addr = %d\n", adapter->mii.phy_id);
+	if (addr == 32)
+		return -EAGAIN;
+	/* Selected the phy and isolate the rest */
+	for (addr = 0; addr < PCH_GBE_PHY_REGS_LEN; addr++) {
+		if (addr != adapter->mii.phy_id) {
+			pch_gbe_mdio_write(netdev, addr, MII_BMCR,
+						BMCR_ISOLATE);
+		} else {
+			bmcr = pch_gbe_mdio_read(netdev, addr, MII_BMCR);
+			pch_gbe_mdio_write(netdev, addr, MII_BMCR,
+						bmcr & ~BMCR_ISOLATE);
+		}
+	}
+
+	/* MII setup */
+	adapter->mii.phy_id_mask = 0x1F;
+	adapter->mii.reg_num_mask = 0x1F;
+	adapter->mii.dev = adapter->netdev;
+	adapter->mii.mdio_read = pch_gbe_mdio_read;
+	adapter->mii.mdio_write = pch_gbe_mdio_write;
+	adapter->mii.supports_gmii = mii_check_gmii_support(&adapter->mii);
+	return 0;
+}
+
+/**
+ * pch_gbe_mdio_read - The read function for mii
+ * @netdev: Network interface device structure
+ * @addr:   Phy ID
+ * @reg:    Access location
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	return pch_gbe_mac_ctrl_miim(hw, addr, PCH_GBE_HAL_MIIM_READ,
+					reg, (u16) 0);
+}
+
+/**
+ * pch_gbe_mdio_write - The write function for mii
+ * @netdev: Network interface device structure
+ * @addr:   Phy ID (not used)
+ * @reg:    Access location
+ * @data:   Write data
+ */
+void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg, int data)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	pch_gbe_mac_ctrl_miim(hw, addr, PCH_GBE_HAL_MIIM_WRITE, reg, data);
+}
+
+/**
+ * pch_gbe_reset_task - Reset processing at the time of transmission timeout
+ * @work:  Pointer of board private structure
+ */
+static void pch_gbe_reset_task(struct work_struct *work)
+{
+	struct pch_gbe_adapter *adapter;
+	adapter = container_of(work, struct pch_gbe_adapter, reset_task);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+	pch_gbe_reinit_locked(adapter);
+}
+
+/**
+ * pch_gbe_reinit_locked- Re-initialization
+ * @adapter:  Board private structure
+ */
+void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	rtnl_lock();
+	if (netif_running(netdev)) {
+		pch_gbe_down(adapter);
+		pch_gbe_up(adapter);
+	}
+	rtnl_unlock();
+}
+
+/**
+ * pch_gbe_reset - Reset GbE
+ * @adapter:  Board private structure
+ */
+void pch_gbe_reset(struct pch_gbe_adapter *adapter)
+{
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	pch_gbe_mac_reset_hw(&adapter->hw);
+	/* Setup the receive address. */
+	pch_gbe_mac_init_rx_addrs(&adapter->hw, PCH_GBE_MAR_ENTRIES);
+	if (pch_gbe_hal_init_hw(&adapter->hw))
+		printk(KERN_ERR KBUILD_MODNAME ": " "Hardware Error\n");
+}
+
+/**
+ * pch_gbe_free_irq - Free an interrupt
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	free_irq(adapter->pdev->irq, netdev);
+	if (adapter->have_msi) {
+		pci_disable_msi(adapter->pdev);
+		PCH_GBE_DEBUG("call pci_disable_msi");
+	}
+}
+
+/**
+ * pch_gbe_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	atomic_inc(&adapter->irq_sem);
+	iowrite32(0, &hw->reg->INT_EN);
+	synchronize_irq(adapter->pdev->irq);
+
+	PCH_GBE_DEBUG("INT_EN reg : 0x%08x\n", ioread32(&hw->reg->INT_EN));
+}
+
+/**
+ * pch_gbe_irq_enable - Enable default interrupt generation settings
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_irq_enable(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	if (likely(atomic_dec_and_test(&adapter->irq_sem)))
+		iowrite32(PCH_GBE_INT_ENABLE_MASK, &hw->reg->INT_EN);
+	PCH_GBE_DEBUG("INT_EN reg : 0x%08x\n", ioread32(&hw->reg->INT_EN));
+}
+
+
+
+/**
+ * pch_gbe_setup_tctl - configure the Transmit control registers
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_setup_tctl(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 tx_mode, tcpip;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	tx_mode = PCH_GBE_TM_LONG_PKT |
+		PCH_GBE_TM_ST_AND_FD |
+		PCH_GBE_TM_SHORT_PKT |
+		PCH_GBE_TM_TH_TX_STRT_8 |
+		PCH_GBE_TM_TH_ALM_EMP_4 | PCH_GBE_TM_TH_ALM_FULL_8;
+
+	iowrite32(tx_mode, &hw->reg->TX_MODE);
+
+	tcpip = ioread32(&hw->reg->TCPIP_ACC);
+	tcpip |= PCH_GBE_TX_TCPIPACC_EN;
+	iowrite32(tcpip, &hw->reg->TCPIP_ACC);
+	return;
+}
+
+/**
+ * pch_gbe_configure_tx - Configure Transmit Unit after Reset
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_configure_tx(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 tdba, tdlen, dctrl;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+	PCH_GBE_DEBUG("dma adr = 0x%08x  size = 0x%08x\n",
+			adapter->tx_ring->dma, adapter->tx_ring->size);
+
+	/* Setup the HW Tx Head and Tail descriptor pointers */
+	tdba = adapter->tx_ring->dma;
+	tdlen = adapter->tx_ring->size - 0x10;
+	iowrite32(tdba, &hw->reg->TX_DSC_BASE);
+	iowrite32(tdlen, &hw->reg->TX_DSC_SIZE);
+	iowrite32(tdba, &hw->reg->TX_DSC_SW_P);
+
+	/* Enables Transmission DMA */
+	dctrl = ioread32(&hw->reg->DMA_CTRL);
+	dctrl |= PCH_GBE_TX_DMA_EN;
+	iowrite32(dctrl, &hw->reg->DMA_CTRL);
+}
+
+/**
+ * pch_gbe_setup_rctl - Configure the receive control registers
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_setup_rctl(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 rx_mode, tcpip;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	rx_mode = PCH_GBE_ADD_FIL_EN | PCH_GBE_MLT_FIL_EN |
+	PCH_GBE_RH_ALM_EMP_4 | PCH_GBE_RH_ALM_FULL_4 | PCH_GBE_RH_RD_TRG_8;
+
+	iowrite32(rx_mode, &hw->reg->RX_MODE);
+
+	tcpip = ioread32(&hw->reg->TCPIP_ACC);
+
+	if (adapter->rx_csum == TRUE) {
+		tcpip &= ~PCH_GBE_RX_TCPIPACC_OFF;
+		tcpip |= PCH_GBE_RX_TCPIPACC_EN;
+	} else {
+		tcpip |= PCH_GBE_RX_TCPIPACC_OFF;
+		tcpip &= ~PCH_GBE_RX_TCPIPACC_EN;
+	}
+	iowrite32(tcpip, &hw->reg->TCPIP_ACC);
+	return;
+}
+
+/**
+ * pch_gbe_configure_rx - Configure Receive Unit after Reset
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_configure_rx(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 rdba, rdlen, rctl, rxdma;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+	PCH_GBE_DEBUG("dma adr = 0x%08x  size = 0x%08x\n",
+			adapter->rx_ring->dma, adapter->rx_ring->size);
+
+	pch_gbe_mac_force_mac_fc(hw);
+
+	/* Disables Receive MAC */
+	rctl = ioread32(&hw->reg->MAC_RX_EN);
+	iowrite32((rctl & ~PCH_GBE_MRE_MAC_RX_EN), &hw->reg->MAC_RX_EN);
+
+	/* Disables Receive DMA */
+	rxdma = ioread32(&hw->reg->DMA_CTRL);
+	rxdma &= ~PCH_GBE_RX_DMA_EN;
+	iowrite32(rxdma, &hw->reg->DMA_CTRL);
+
+	PCH_GBE_DEBUG("MAC_RX_EN reg = 0x%08x  DMA_CTRL reg = 0x%08x\n",
+			ioread32(&hw->reg->MAC_RX_EN),
+			ioread32(&hw->reg->DMA_CTRL));
+
+	/* Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring */
+	rdba = adapter->rx_ring->dma;
+	rdlen = adapter->rx_ring->size - 0x10;
+	iowrite32(rdba, &hw->reg->RX_DSC_BASE);
+	iowrite32(rdlen, &hw->reg->RX_DSC_SIZE);
+	iowrite32((rdba + rdlen), &hw->reg->RX_DSC_SW_P);
+
+	/* Enables Receive DMA */
+	rxdma = ioread32(&hw->reg->DMA_CTRL);
+	rxdma |= PCH_GBE_RX_DMA_EN;
+	iowrite32(rxdma, &hw->reg->DMA_CTRL);
+	/* Enables Receive */
+	iowrite32(PCH_GBE_MRE_MAC_RX_EN, &hw->reg->MAC_RX_EN);
+}
+
+/**
+ * pch_gbe_unmap_and_free_tx_resource - Unmap and free tx socket buffer
+ * @adapter:     Board private structure
+ * @buffer_info: Buffer information structure
+ */
+static void pch_gbe_unmap_and_free_tx_resource(
+	struct pch_gbe_adapter *adapter, struct pch_gbe_buffer *buffer_info)
+{
+	if (buffer_info->dma) {
+		pci_unmap_page(adapter->pdev, buffer_info->dma,
+				buffer_info->length, PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+	if (buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+	if (buffer_info->kernel_skb) {
+		dev_kfree_skb_any(buffer_info->kernel_skb);
+		buffer_info->kernel_skb = NULL;
+	}
+}
+
+/**
+ * pch_gbe_unmap_and_free_rx_resource - Unmap and free rx socket buffer
+ * @adapter:      Board private structure
+ * @buffer_info:  Buffer information structure
+ */
+static void pch_gbe_unmap_and_free_rx_resource(
+					struct pch_gbe_adapter *adapter,
+					struct pch_gbe_buffer *buffer_info)
+{
+	if (buffer_info->dma) {
+		pci_unmap_single(adapter->pdev, buffer_info->dma,
+				 buffer_info->length, PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
+	}
+	if (buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+}
+
+/**
+ * pch_gbe_clean_tx_ring - Free Tx Buffers
+ * @adapter:  Board private structure
+ * @tx_ring:  Ring to be cleaned
+ */
+static void pch_gbe_clean_tx_ring(struct pch_gbe_adapter *adapter,
+					struct pch_gbe_tx_ring *tx_ring)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct pch_gbe_buffer *buffer_info;
+	unsigned long size;
+	unsigned int i;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Free all the Tx ring sk_buffs */
+	for (i = 0; i < tx_ring->count; i++) {
+		buffer_info = &tx_ring->buffer_info[i];
+		pch_gbe_unmap_and_free_tx_resource(adapter, buffer_info);
+	}
+	PCH_GBE_DEBUG("call pch_gbe_unmap_and_free_tx_resource() %d count\n",
+			i);
+
+	size = (unsigned long)sizeof(struct pch_gbe_buffer) * tx_ring->count;
+	memset(tx_ring->buffer_info, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(tx_ring->desc, 0, tx_ring->size);
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+	iowrite32(tx_ring->dma, &hw->reg->TX_DSC_HW_P);
+	iowrite32((tx_ring->size - 0x10), &hw->reg->TX_DSC_SIZE);
+}
+
+/**
+ * pch_gbe_clean_rx_ring - Free Rx Buffers
+ * @adapter:  Board private structure
+ * @rx_ring:  Ring to free buffers from
+ */
+static void
+pch_gbe_clean_rx_ring(struct pch_gbe_adapter *adapter,
+		      struct pch_gbe_rx_ring *rx_ring)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct pch_gbe_buffer *buffer_info;
+	unsigned long size;
+	unsigned int i;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		pch_gbe_unmap_and_free_rx_resource(adapter, buffer_info);
+	}
+	PCH_GBE_DEBUG("call pch_gbe_unmap_and_free_rx_resource() %d count\n",
+			i);
+	size = (unsigned long)sizeof(struct pch_gbe_buffer) * rx_ring->count;
+	memset(rx_ring->buffer_info, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(rx_ring->desc, 0, rx_ring->size);
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+	iowrite32(rx_ring->dma, &hw->reg->RX_DSC_HW_P);
+	iowrite32((rx_ring->size - 0x10), &hw->reg->RX_DSC_SIZE);
+}
+
+static void pch_gbe_set_rgmii_ctrl(struct pch_gbe_adapter *adapter, u16 speed,
+					u16 duplex)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	unsigned long rgmii = 0;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Set the RGMII control. */
+#ifdef PCH_GBE_MAC_IFOP_RGMII
+	switch (speed) {
+	case SPEED_10:
+		rgmii = (PCH_GBE_RGMII_RATE_2_5M |
+			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
+		break;
+	case SPEED_100:
+		rgmii = (PCH_GBE_RGMII_RATE_25M |
+			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
+		break;
+	case SPEED_1000:
+		rgmii = (PCH_GBE_RGMII_RATE_125M |
+			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
+		break;
+	}
+	iowrite32(rgmii, &hw->reg->RGMII_CTRL);
+#else	/* GMII */
+	rgmii = 0;
+	iowrite32(rgmii, &hw->reg->RGMII_CTRL);
+#endif
+}
+static void pch_gbe_set_mode(struct pch_gbe_adapter *adapter, u16 speed,
+				u16 duplex)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pch_gbe_hw *hw = &adapter->hw;
+	unsigned long mode = 0;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Set the communication mode */
+	switch (speed) {
+	case SPEED_10:
+		mode = PCH_GBE_MODE_MII_ETHER;
+		netdev->tx_queue_len = 10;
+		break;
+	case SPEED_100:
+		mode = PCH_GBE_MODE_MII_ETHER;
+		netdev->tx_queue_len = 100;
+		break;
+	case SPEED_1000:
+		mode = PCH_GBE_MODE_GMII_ETHER;
+		break;
+	}
+	if (duplex == DUPLEX_FULL)
+		mode |= PCH_GBE_MODE_FULL_DUPLEX;
+	else
+		mode |= PCH_GBE_MODE_HALF_DUPLEX;
+	iowrite32(mode, &hw->reg->MODE);
+}
+
+/**
+ * pch_gbe_watchdog - Watchdog process
+ * @data:  Board private structure
+ */
+static void pch_gbe_watchdog(unsigned long data)
+{
+	struct pch_gbe_adapter *adapter = (struct pch_gbe_adapter *)data;
+	struct net_device *netdev = adapter->netdev;
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct ethtool_cmd cmd;
+
+	PCH_GBE_DEBUG("%s: right now = %ld\n", __func__, jiffies);
+
+	pch_gbe_update_stats(adapter);
+	if ((mii_link_ok(&adapter->mii)) && (!netif_carrier_ok(netdev))) {
+		netdev->tx_queue_len = adapter->tx_queue_len;
+		/* mii library handles link maintenance tasks */
+		if (mii_ethtool_gset(&adapter->mii, &cmd)) {
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"ethtool get setting Error\n");
+			mod_timer(&adapter->watchdog_timer,
+				  round_jiffies(jiffies +
+						PCH_GBE_WATCHDOG_PERIOD));
+			return;
+		}
+		hw->mac.link_speed = cmd.speed;
+		hw->mac.link_duplex = cmd.duplex;
+		/* Set the RGMII control. */
+		pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
+						hw->mac.link_duplex);
+		/* Set the communication mode */
+		pch_gbe_set_mode(adapter, hw->mac.link_speed,
+						hw->mac.link_duplex);
+		PCH_GBE_DEBUG("NIC Link is Up %d Mbps %s-Duplex\n",
+			cmd.speed, cmd.duplex == DUPLEX_FULL ? "Full" : "Half");
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
+	} else if ((!mii_link_ok(&adapter->mii)) &&
+					(netif_carrier_ok(netdev))) {
+		PCH_GBE_DEBUG("NIC Link is Down\n");
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+	}
+	mod_timer(&adapter->watchdog_timer,
+		  round_jiffies(jiffies + PCH_GBE_WATCHDOG_PERIOD));
+}
+
+/**
+ * pch_gbe_tx_queue - Carry out queuing of the transmission data
+ * @adapter:  Board private structure
+ * @tx_ring:  Tx descriptor ring structure
+ * @skb:      Sockt buffer structure
+ */
+static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
+		 struct pch_gbe_tx_ring *tx_ring, struct sk_buff *skb)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct pch_gbe_tx_desc *tx_desc;
+	struct pch_gbe_buffer *buffer_info;
+	struct sk_buff *tmp_skb;
+	unsigned int frame_ctrl;
+	unsigned int ring_num;
+	unsigned long flags;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+
+	/*-- Set frame control --*/
+	frame_ctrl = 0;
+	if (unlikely(skb->len < PCH_GBE_SHORT_PKT))
+		frame_ctrl |= PCH_GBE_TXD_CTRL_APAD;
+	if (unlikely(adapter->tx_csum == FALSE))
+		frame_ctrl |= PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
+
+	/* Performs checksum processing */
+	/*
+	 * It is because the hardware accelerator does not support a checksum,
+	 * when the received data size is less than 64 bytes.
+	 */
+	if ((skb->len < PCH_GBE_SHORT_PKT) && (adapter->tx_csum == TRUE)) {
+		frame_ctrl |=
+			PCH_GBE_TXD_CTRL_APAD | PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF;
+		if (skb->protocol == htons(ETH_P_IP)) {
+			struct iphdr *iph = ip_hdr(skb);
+			unsigned int offset;
+			iph->check = 0;
+			iph->check = ip_fast_csum((u8 *) iph, iph->ihl);
+			offset = skb_transport_offset(skb);
+			if (iph->protocol == IPPROTO_TCP) {
+				skb->csum = 0;
+				tcp_hdr(skb)->check = 0;
+				skb->csum =
+					skb_checksum(skb, offset,
+						skb->len - offset, 0);
+				tcp_hdr(skb)->check =
+					csum_tcpudp_magic(iph->saddr,
+							iph->daddr,
+							skb->len - offset,
+							IPPROTO_TCP, skb->csum);
+			} else if (iph->protocol == IPPROTO_UDP) {
+				skb->csum = 0;
+				udp_hdr(skb)->check = 0;
+				skb->csum =
+					skb_checksum(skb, offset,
+						skb->len - offset, 0);
+				udp_hdr(skb)->check =
+					csum_tcpudp_magic(iph->saddr,
+							iph->daddr,
+							skb->len - offset,
+							IPPROTO_UDP, skb->csum);
+			}
+		}
+	}
+
+	spin_lock_irqsave(&tx_ring->tx_lock, flags);
+	ring_num = tx_ring->next_to_use;
+	if (unlikely((ring_num + 1) == tx_ring->count))
+		tx_ring->next_to_use = 0;
+	else
+		tx_ring->next_to_use = ring_num + 1;
+
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	buffer_info = &tx_ring->buffer_info[ring_num];
+	tmp_skb = buffer_info->skb;
+
+	/* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
+	memcpy(tmp_skb->data, skb->data, ETH_HLEN);
+	tmp_skb->data[ETH_HLEN] = 0x00;
+	tmp_skb->data[ETH_HLEN + 1] = 0x00;
+	tmp_skb->len = skb->len;
+	memcpy(&tmp_skb->data[ETH_HLEN + 2], &skb->data[ETH_HLEN],
+	       (skb->len - ETH_HLEN));
+	buffer_info->kernel_skb = skb;
+	skb = tmp_skb;
+
+	/*-- Set Buffer infomation --*/
+	buffer_info->length = skb->len;
+	buffer_info->dma =
+	    pci_map_single(adapter->pdev, skb->data, buffer_info->length,
+			   PCI_DMA_TODEVICE);
+	buffer_info->time_stamp = jiffies;
+
+	/*-- Set Tx descriptor --*/
+	tx_desc = PCH_GBE_TX_DESC(*tx_ring, ring_num);
+	tx_desc->buffer_addr = (buffer_info->dma);
+	tx_desc->length = (skb->len);
+	tx_desc->tx_words_eob = ((skb->len + 3));
+	tx_desc->tx_frame_ctrl = (frame_ctrl);
+	tx_desc->gbec_status = (DSC_INIT16);
+
+	if (unlikely(++ring_num == tx_ring->count))
+		ring_num = 0;
+
+	/* Update software pointer of TX descriptor */
+	iowrite32(tx_ring->dma +
+		  (int)sizeof(struct pch_gbe_tx_desc) * ring_num,
+		  &hw->reg->TX_DSC_SW_P);
+}
+
+/**
+ * pch_gbe_update_stats - Update the board statistics counters
+ * @adapter:  Board private structure
+ */
+void pch_gbe_update_stats(struct pch_gbe_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_hw_stats *stats = &adapter->stats;
+	struct net_device_stats *net_stats = &adapter->net_stats;
+	unsigned long flags;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/*
+	 * Prevent stats update while adapter is being reset, or if the pci
+	 * connection is down.
+	 */
+	if ((pdev->error_state) && (pdev->error_state != pci_channel_io_normal))
+		return;
+
+	spin_lock_irqsave(&adapter->stats_lock, flags);
+
+	/* Update device status "adapter->stats" */
+	stats->rx_errors = stats->rx_crc_errors + stats->rx_frame_errors;
+	stats->tx_errors = stats->tx_length_errors +
+	    stats->tx_aborted_errors +
+	    stats->tx_carrier_errors + stats->tx_timeout_count;
+
+	/* Update network device status "adapter->net_stats" */
+	net_stats->rx_packets = stats->rx_packets;
+	net_stats->tx_packets = stats->tx_packets;
+	net_stats->rx_bytes = stats->rx_bytes;
+	net_stats->tx_bytes = stats->tx_bytes;
+	net_stats->rx_errors = stats->rx_errors;
+	net_stats->tx_errors = stats->tx_errors;
+	net_stats->rx_dropped = stats->rx_dropped;
+	net_stats->tx_dropped = stats->tx_dropped;
+	net_stats->multicast = stats->multicast;
+	net_stats->collisions = stats->collisions;
+	net_stats->rx_crc_errors = stats->rx_crc_errors;
+	net_stats->rx_frame_errors = stats->rx_frame_errors;
+	net_stats->tx_aborted_errors = stats->tx_aborted_errors;
+	net_stats->tx_carrier_errors = stats->tx_carrier_errors;
+
+	spin_unlock_irqrestore(&adapter->stats_lock, flags);
+}
+
+/**
+ * pch_gbe_intr - Interrupt Handler
+ * @irq:   Interrupt number
+ * @data:  Pointer to a network interface device structure
+ * Returns
+ *	- IRQ_HANDLED:	Our interrupt
+ *	- IRQ_NONE:	Not our interrupt
+ */
+static irqreturn_t pch_gbe_intr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 int_st;
+	u32 int_en;
+
+	/* Check request status */
+	int_st = ioread32(&hw->reg->INT_ST);
+	int_st = int_st & ioread32(&hw->reg->INT_EN);
+	/* When request status is no interruption factor */
+	if (unlikely(!int_st))
+		return IRQ_NONE;	/* Not our interrupt. End processing. */
+	PCH_GBE_DEBUG("%s occur int_st = 0x%08x\n", __func__, int_st);
+	if (int_st & PCH_GBE_INT_RX_FRAME_ERR)
+		adapter->stats.intr_rx_frame_err_count++;
+	if (int_st & PCH_GBE_INT_RX_FIFO_ERR)
+		adapter->stats.intr_rx_fifo_err_count++;
+	if (int_st & PCH_GBE_INT_RX_DMA_ERR)
+		adapter->stats.intr_rx_dma_err_count++;
+	if (int_st & PCH_GBE_INT_TX_FIFO_ERR)
+		adapter->stats.intr_tx_fifo_err_count++;
+	if (int_st & PCH_GBE_INT_TX_DMA_ERR)
+		adapter->stats.intr_tx_dma_err_count++;
+	if (int_st & PCH_GBE_INT_TCPIP_ERR)
+		adapter->stats.intr_tcpip_err_count++;
+	/* When Rx descriptor is empty  */
+	if ((int_st & PCH_GBE_INT_RX_DSC_EMP)) {
+		adapter->stats.intr_rx_dsc_empty_count++;
+		printk(KERN_ERR KBUILD_MODNAME ": " "Rx descriptor is empty\n");
+		int_en = ioread32(&hw->reg->INT_EN);
+		iowrite32((int_en & ~PCH_GBE_INT_RX_DSC_EMP), &hw->reg->INT_EN);
+		if (hw->mac.tx_fc_enable == TRUE) {
+			/* Set Pause packet */
+			pch_gbe_mac_set_pause_packet(hw);
+		}
+		if ((int_en & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))
+		    == 0) {
+			return IRQ_HANDLED;
+		}
+	}
+
+	/* When request status is Receive interruption */
+	if ((int_st & (PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT))) {
+		if (likely(napi_schedule_prep(&adapter->napi))) {
+			/* Enable only Rx Descriptor empty */
+			atomic_inc(&adapter->irq_sem);
+			int_en = ioread32(&hw->reg->INT_EN);
+			int_en &=
+			    ~(PCH_GBE_INT_RX_DMA_CMPLT | PCH_GBE_INT_TX_CMPLT);
+			iowrite32(int_en, &hw->reg->INT_EN);
+			/* Start polling for NAPI */
+			__napi_schedule(&adapter->napi);
+		}
+	}
+	PCH_GBE_DEBUG("return = 0x%08x  INT_EN reg = 0x%08x\n",
+			IRQ_HANDLED, ioread32(&hw->reg->INT_EN));
+	return IRQ_HANDLED;
+}
+
+/**
+ * pch_gbe_alloc_rx_buffers - Replace used receive buffers; legacy & extended
+ * @adapter:       Board private structure
+ * @rx_ring:       Rx descriptor ring
+ * @cleaned_count: Cleaned count
+ */
+static void
+pch_gbe_alloc_rx_buffers(struct pch_gbe_adapter *adapter,
+			 struct pch_gbe_rx_ring *rx_ring, int cleaned_count)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct pch_gbe_rx_desc *rx_desc;
+	struct pch_gbe_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int bufsz;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+
+	bufsz = adapter->rx_buffer_len + PCH_GBE_DMA_ALIGN;
+	i = rx_ring->next_to_use;
+
+	while ((cleaned_count--)) {
+		buffer_info = &rx_ring->buffer_info[i];
+		skb = buffer_info->skb;
+		if (skb) {
+			skb_trim(skb, 0);
+		} else {
+			skb = netdev_alloc_skb(netdev, bufsz);
+			if (unlikely(!skb)) {
+				/* Better luck next round */
+				adapter->stats.rx_alloc_buff_failed++;
+				break;
+			}
+			/* 64byte align */
+			skb_reserve(skb, PCH_GBE_DMA_ALIGN);
+
+			buffer_info->skb = skb;
+			buffer_info->length = adapter->rx_buffer_len;
+		}
+
+		buffer_info->dma = pci_map_single(pdev,
+						  skb->data,
+						  buffer_info->length,
+						  PCI_DMA_FROMDEVICE);
+
+		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+		rx_desc->buffer_addr = (buffer_info->dma);
+		rx_desc->gbec_status = DSC_INIT16;
+
+		PCH_GBE_DEBUG("i = %d  buffer_info->dma = 0x%x  "
+			 "buffer_info->length = 0x%x\n",
+			 i, buffer_info->dma, buffer_info->length);
+
+		if (unlikely(++i == rx_ring->count))
+			i = 0;
+	}
+	if (likely(rx_ring->next_to_use != i)) {
+		rx_ring->next_to_use = i;
+		if (unlikely(i-- == 0))
+			i = (rx_ring->count - 1);
+		wmb();
+		iowrite32(rx_ring->dma +
+			  (int)sizeof(struct pch_gbe_rx_desc) * i,
+			  &hw->reg->RX_DSC_SW_P);
+	}
+	return;
+}
+
+/**
+ * pch_gbe_alloc_tx_buffers - Allocate transmit buffers
+ * @adapter:   Board private structure
+ * @tx_ring:   Tx descriptor ring
+ */
+static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
+					struct pch_gbe_tx_ring *tx_ring)
+{
+	struct pch_gbe_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int bufsz;
+	struct pch_gbe_tx_desc *tx_desc;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	bufsz =
+	    adapter->hw.mac.max_frame_size + PCH_GBE_DMA_ALIGN + NET_IP_ALIGN;
+
+	for (i = 0; i < tx_ring->count; i++) {
+		buffer_info = &tx_ring->buffer_info[i];
+		skb = netdev_alloc_skb(adapter->netdev, bufsz);
+		skb_reserve(skb, PCH_GBE_DMA_ALIGN);
+		buffer_info->skb = skb;
+		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+		tx_desc->gbec_status = (DSC_INIT16);
+	}
+	return;
+}
+
+/**
+ * pch_gbe_clean_tx - Reclaim resources after transmit completes
+ * @adapter:   Board private structure
+ * @tx_ring:   Tx descriptor ring
+ * Returns
+ *	TRUE:  Cleaned the descriptor
+ *	FALSE: Not cleaned the descriptor
+ */
+static unsigned char
+pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
+		 struct pch_gbe_tx_ring *tx_ring)
+{
+	struct pch_gbe_tx_desc *tx_desc;
+	struct pch_gbe_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	unsigned int cleaned_count = 0;
+	unsigned char cleaned = FALSE;
+
+	PCH_GBE_DEBUG("%s  next_to_clean : %d\n",
+			__func__, tx_ring->next_to_clean);
+
+	i = tx_ring->next_to_clean;
+	tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+	PCH_GBE_DEBUG("gbec_status:0x%04x  dma_status:0x%04x\n",
+			tx_desc->gbec_status, tx_desc->dma_status);
+
+	while ((tx_desc->gbec_status & DSC_INIT16) == 0x0000) {
+		PCH_GBE_DEBUG("gbec_status:0x%04x\n", tx_desc->gbec_status);
+		cleaned = TRUE;
+		buffer_info = &tx_ring->buffer_info[i];
+		skb = buffer_info->skb;
+
+		if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_ABT)) {
+			adapter->stats.tx_aborted_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"Transfer Aboat Error\n");
+		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CRSER)
+			  ) {
+			adapter->stats.tx_carrier_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"Transfer Carrier Sense Error\n");
+		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_EXCOL)
+			  ) {
+			adapter->stats.tx_aborted_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"Transfer Collision Abort Error\n");
+		} else if ((tx_desc->gbec_status &
+			    (PCH_GBE_TXD_GMAC_STAT_SNGCOL |
+			     PCH_GBE_TXD_GMAC_STAT_MLTCOL))) {
+			adapter->stats.collisions++;
+			adapter->stats.tx_packets++;
+			adapter->stats.tx_bytes += skb->len;
+			PCH_GBE_DEBUG("Transfer Collision\n");
+		} else if ((tx_desc->gbec_status & PCH_GBE_TXD_GMAC_STAT_CMPLT)
+			  ) {
+			adapter->stats.tx_packets++;
+			adapter->stats.tx_bytes += skb->len;
+		}
+		if (buffer_info->dma) {
+			PCH_GBE_DEBUG("unmap buffer_info->dma : %d\n", i);
+			pci_unmap_page(adapter->pdev, buffer_info->dma,
+				       buffer_info->length, PCI_DMA_TODEVICE);
+			buffer_info->dma = 0;
+		}
+		if (buffer_info->skb) {
+			PCH_GBE_DEBUG("trim buffer_info->skb : %d\n", i);
+			skb_trim(buffer_info->skb, 0);
+		}
+		if (buffer_info->kernel_skb) {
+			PCH_GBE_DEBUG
+			    ("free buffer_info->kernel_skb adr: 0x%x\n",
+			     (u32)(buffer_info->kernel_skb));
+			dev_kfree_skb(buffer_info->kernel_skb);
+			buffer_info->kernel_skb = NULL;
+		}
+		tx_desc->gbec_status = DSC_INIT16;
+		if (unlikely(++i == tx_ring->count))
+			i = 0;
+		tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
+
+		/* weight of a sort for tx, to avoid endless transmit cleanup */
+		if (cleaned_count++ == PCH_GBE_TX_WEIGHT)
+			break;
+	}
+	PCH_GBE_DEBUG("called pch_gbe_unmap_and_free_tx_resource() %dcount\n",
+			cleaned_count);
+	/* Recover from running out of Tx resources in xmit_frame */
+	if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
+		netif_wake_queue(adapter->netdev);
+		adapter->stats.tx_restart_count++;
+		PCH_GBE_DEBUG("Tx wake queue\n");
+	}
+	spin_lock(&adapter->tx_queue_lock);
+	tx_ring->next_to_clean = i;
+	spin_unlock(&adapter->tx_queue_lock);
+	PCH_GBE_DEBUG("next_to_clean : %d\n", tx_ring->next_to_clean);
+	return cleaned;
+}
+
+/**
+ * pch_gbe_clean_rx - Send received data up the network stack; legacy
+ * @adapter:     Board private structure
+ * @rx_ring:     Rx descriptor ring
+ * @work_done:   Completed count
+ * @work_to_do:  Request count
+ * Returns
+ *	TRUE:  Cleaned the descriptor
+ *	FALSE: Not cleaned the descriptor
+ */
+static unsigned char
+pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
+		 struct pch_gbe_rx_ring *rx_ring,
+		 int *work_done, int work_to_do)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_buffer *buffer_info;
+	struct pch_gbe_rx_desc *rx_desc;
+	u32 length;
+	unsigned char tmp_packet[ETH_HLEN];
+	unsigned int i;
+	unsigned int cleaned_count = 0;
+	unsigned char cleaned = FALSE;
+	struct sk_buff *skb;
+	u8 dma_status;
+	u16 gbec_status;
+	u32 tcp_ip_status;
+	u8 skb_copy_flag = 0;
+	u8 skb_padding_flag = 0;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+
+	i = rx_ring->next_to_clean;
+
+	while (*work_done < work_to_do) {
+		/* Check Rx descriptor status */
+		rx_desc = PCH_GBE_RX_DESC(*rx_ring, i);
+		if (rx_desc->gbec_status == DSC_INIT16)
+			break;
+		cleaned = TRUE;
+		cleaned_count++;
+
+		dma_status = rx_desc->dma_status;
+		gbec_status = rx_desc->gbec_status;
+		tcp_ip_status = rx_desc->tcp_ip_status;
+		rx_desc->gbec_status = DSC_INIT16;
+		buffer_info = &rx_ring->buffer_info[i];
+		skb = buffer_info->skb;
+
+		/* unmap dma */
+		pci_unmap_single(pdev, buffer_info->dma, buffer_info->length,
+				 PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
+		/* Prefetch the packet */
+		prefetch(skb->data);
+
+		PCH_GBE_DEBUG
+			("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
+			 "TCP:0x%08x]  BufInf = 0x%08x\n",
+			 i, dma_status, gbec_status, tcp_ip_status,
+			 (u32) (buffer_info));
+		/* Error check */
+		if (unlikely(gbec_status & PCH_GBE_RXD_GMAC_STAT_NOTOCTAL)) {
+			adapter->stats.rx_frame_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"Receive Not Octal Error\n");
+		} else if (unlikely(gbec_status &
+				PCH_GBE_RXD_GMAC_STAT_NBLERR)) {
+			adapter->stats.rx_frame_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": "
+				"Receive Nibble Error\n");
+		} else if (unlikely(gbec_status &
+				PCH_GBE_RXD_GMAC_STAT_CRCERR)) {
+			adapter->stats.rx_crc_errors++;
+			printk(KERN_ERR KBUILD_MODNAME ": Receive CRC Error\n");
+		} else {
+			/* get receive length */
+			/* length convert[-3], padding[-2] */
+			length = (rx_desc->rx_words_eob) - 3 - 2;
+
+			/* Decide the data conversion method */
+			if (adapter->rx_csum != TRUE) {
+				/* [Header:14][payload] */
+				skb_padding_flag = 0;
+				skb_copy_flag = 1;
+			} else {
+				/* [Header:14][padding:2][payload] */
+				skb_padding_flag = 1;
+				if (length < copybreak)
+					skb_copy_flag = 1;
+				else
+					skb_copy_flag = 0;
+			}
+
+			/* Data conversion */
+			if (skb_copy_flag) {	/* recycle  skb */
+				struct sk_buff *new_skb;
+				new_skb =
+				    netdev_alloc_skb(netdev,
+						     length + NET_IP_ALIGN);
+				if (new_skb) {
+					if (!skb_padding_flag) {
+						skb_reserve(new_skb,
+								NET_IP_ALIGN);
+					}
+					memcpy(new_skb->data, skb->data,
+						length);
+					/* save the skb
+					 * in buffer_info as good */
+					skb = new_skb;
+				} else if (!skb_padding_flag) {
+					/* dorrop error */
+					printk(KERN_ERR KBUILD_MODNAME ": "
+						"New skb allocation Error\n");
+					goto dorrop;
+				}
+			} else {
+				buffer_info->skb = NULL;
+			}
+			if (skb_padding_flag) {
+				memcpy(&tmp_packet[0], &skb->data[0], ETH_HLEN);
+				memcpy(&skb->data[NET_IP_ALIGN], &tmp_packet[0],
+					ETH_HLEN);
+				skb_reserve(skb, NET_IP_ALIGN);
+
+			}
+
+			/* update status of driver */
+			adapter->stats.rx_bytes += length;
+			adapter->stats.rx_packets++;
+			if ((gbec_status & PCH_GBE_RXD_GMAC_STAT_MARMLT))
+				adapter->stats.multicast++;
+			/* Write meta date of skb */
+			skb_put(skb, length);
+			skb->protocol = eth_type_trans(skb, netdev);
+			if ((tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK) ==
+			    PCH_GBE_RXD_ACC_STAT_TCPIPOK) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			} else {
+				skb->ip_summed = CHECKSUM_NONE;
+			}
+
+			if (netif_receive_skb(skb) == NET_RX_DROP) {
+				adapter->stats.rx_dropped++;
+				printk(KERN_ERR KBUILD_MODNAME ": "
+				 "Receive Netif Receive Dropped Error\n");
+			}
+			(*work_done)++;
+			netdev->last_rx = jiffies;
+			PCH_GBE_DEBUG
+			    ("Receive skb->ip_summed: %d length: %d\n",
+			     skb->ip_summed, length);
+		}
+dorrop:
+		/* return some buffers to hardware, one at a time is too slow */
+		if (unlikely(cleaned_count >= PCH_GBE_RX_BUFFER_WRITE)) {
+			pch_gbe_alloc_rx_buffers(adapter, rx_ring,
+						 cleaned_count);
+			cleaned_count = 0;
+		}
+		if (++i == rx_ring->count)
+			i = 0;
+	}
+	rx_ring->next_to_clean = i;
+	if (cleaned_count)
+		pch_gbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
+	return cleaned;
+}
+
+/**
+ * pch_gbe_setup_tx_resources - Allocate Tx resources (Descriptors)
+ * @adapter:  Board private structure
+ * @tx_ring:  Tx descriptor ring (for a specific queue) to setup
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_tx_ring *tx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_tx_desc *tx_desc;
+	int size;
+	int desNo;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	size = (int)sizeof(struct pch_gbe_buffer) * tx_ring->count;
+	tx_ring->buffer_info = vmalloc(size);
+	if (!tx_ring->buffer_info) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate memory "
+			"for the buffer infomation\n");
+		return -ENOMEM;
+	}
+	memset(tx_ring->buffer_info, 0, size);
+
+	tx_ring->size = tx_ring->count * (int)sizeof(struct pch_gbe_tx_desc);
+
+	tx_ring->desc =
+		pci_alloc_consistent(pdev, tx_ring->size, &tx_ring->dma);
+	if (!tx_ring->desc) {
+		vfree(tx_ring->buffer_info);
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate memory "
+			"for the transmit descriptor ring\n");
+		return -ENOMEM;
+	}
+	memset(tx_ring->desc, 0, tx_ring->size);
+
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+	spin_lock_init(&tx_ring->tx_lock);
+
+	for (desNo = 0; desNo < tx_ring->count; desNo++) {
+		tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
+		tx_desc->gbec_status = DSC_INIT16;
+	}
+	PCH_GBE_DEBUG("tx_ring->desc = 0x%08x  tx_ring->dma = 0x%08x\n"
+			"next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+			(u32) tx_ring->desc, tx_ring->dma,
+			tx_ring->next_to_clean, tx_ring->next_to_use);
+	return 0;
+}
+
+/**
+ * pch_gbe_setup_rx_resources - Allocate Rx resources (Descriptors)
+ * @adapter:  Board private structure
+ * @rx_ring:  Rx descriptor ring (for a specific queue) to setup
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+int
+pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_rx_ring *rx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct pch_gbe_rx_desc *rx_desc;
+	int size;
+	int desNo;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	size = (int)sizeof(struct pch_gbe_buffer) * rx_ring->count;
+	rx_ring->buffer_info = vmalloc(size);
+	if (!rx_ring->buffer_info) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate memory "
+			"for the receive descriptor ring\n");
+		return -ENOMEM;
+	}
+	memset(rx_ring->buffer_info, 0, size);
+	rx_ring->size = rx_ring->count * (int)sizeof(struct pch_gbe_rx_desc);
+	rx_ring->desc =
+		pci_alloc_consistent(pdev, rx_ring->size, &rx_ring->dma);
+
+	if (!rx_ring->desc) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate memory "
+			"for the receive descriptor ring\n");
+		vfree(rx_ring->buffer_info);
+		return -ENOMEM;
+	}
+	memset(rx_ring->desc, 0, rx_ring->size);
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+	for (desNo = 0; desNo < rx_ring->count; desNo++) {
+		rx_desc = PCH_GBE_RX_DESC(*rx_ring, desNo);
+		rx_desc->gbec_status = DSC_INIT16;
+	}
+	PCH_GBE_DEBUG("rx_ring->desc = 0x%08x  rx_ring->dma = 0x%08x "
+			"next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
+			(u32) rx_ring->desc, rx_ring->dma,
+			rx_ring->next_to_clean, rx_ring->next_to_use);
+	return 0;
+}
+
+/**
+ * pch_gbe_free_tx_resources - Free Tx Resources
+ * @adapter:  Board private structure
+ * @tx_ring:  Tx descriptor ring for a specific queue
+ */
+void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_tx_ring *tx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	pch_gbe_clean_tx_ring(adapter, tx_ring);
+	vfree(tx_ring->buffer_info);
+	tx_ring->buffer_info = NULL;
+	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
+	tx_ring->desc = NULL;
+}
+
+/**
+ * pch_gbe_free_rx_resources - Free Rx Resources
+ * @adapter:  Board private structure
+ * @rx_ring:  Ring to clean the resources from
+ */
+void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+				struct pch_gbe_rx_ring *rx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	pch_gbe_clean_rx_ring(adapter, rx_ring);
+	vfree(rx_ring->buffer_info);
+	rx_ring->buffer_info = NULL;
+	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+	rx_ring->desc = NULL;
+}
+
+/**
+ * pch_gbe_request_irq - Allocate an interrupt line
+ * @adapter:  Board private structure
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err;
+	int flags;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	flags = IRQF_SHARED;
+	adapter->have_msi = FALSE;
+	err = pci_enable_msi(adapter->pdev);
+	PCH_GBE_DEBUG("call pci_enable_msi\n");
+	if (err) {
+		PCH_GBE_DEBUG("call pci_enable_msi - Error: %d\n", err);
+	} else {
+		flags = 0;
+		adapter->have_msi = TRUE;
+	}
+	err = request_irq(adapter->pdev->irq, &pch_gbe_intr,
+			  flags, netdev->name, netdev);
+	if (err) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate interrupt Error: %d\n", err);
+	}
+	PCH_GBE_DEBUG("adapter->have_msi : %d  flags : 0x%04x  "
+			"return : 0x%04x\n", adapter->have_msi, flags, err);
+	return err;
+}
+
+
+static void pch_gbe_set_multi(struct net_device *netdev);
+/**
+ * pch_gbe_up - Up GbE network device
+ * @adapter:  Board private structure
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+int pch_gbe_up(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
+	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
+	int err;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* hardware has been reset, we need to reload some things */
+	pch_gbe_set_multi(netdev);
+
+	pch_gbe_setup_tctl(adapter);
+	pch_gbe_configure_tx(adapter);
+	pch_gbe_setup_rctl(adapter);
+	pch_gbe_configure_rx(adapter);
+
+	err = pch_gbe_request_irq(adapter);
+	if (err) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Error: can't bring device up\n");
+		return err;
+	}
+	pch_gbe_alloc_tx_buffers(adapter, tx_ring);
+	pch_gbe_alloc_rx_buffers(adapter, rx_ring, rx_ring->count);
+	adapter->tx_queue_len = netdev->tx_queue_len;
+
+	mod_timer(&adapter->watchdog_timer, jiffies);
+
+	napi_enable(&adapter->napi);
+	pch_gbe_irq_enable(adapter);
+	netif_start_queue(adapter->netdev);
+
+	return 0;
+}
+
+/**
+ * pch_gbe_down - Down GbE network device
+ * @adapter:  Board private structure
+ */
+void pch_gbe_down(struct pch_gbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer */
+	napi_disable(&adapter->napi);
+	atomic_set(&adapter->irq_sem, 0);
+
+	pch_gbe_irq_disable(adapter);
+	pch_gbe_free_irq(adapter);
+
+	del_timer_sync(&adapter->watchdog_timer);
+
+	netdev->tx_queue_len = adapter->tx_queue_len;
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	pch_gbe_reset(adapter);
+	pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
+	pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
+}
+
+/**
+ * pch_gbe_sw_init - Initialize general software structures (struct pch_gbe_adapter)
+ * @adapter:  Board private structure to initialize
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* PCI config space info */
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_device_id = pdev->subsystem_device;
+
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+
+	adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_2048;
+	hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->mac.min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
+
+	/* Initialize the hardware-specific values */
+	if (pch_gbe_hal_setup_init_funcs(hw)) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Hardware Initialization Failure\n");
+		return -EIO;
+	}
+	if (pch_gbe_alloc_queues(adapter)) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Unable to allocate memory for queues\n");
+		return -ENOMEM;
+	}
+	dev_hold(adapter->polling_netdev);
+	set_bit(__LINK_STATE_START, &adapter->polling_netdev->state);
+
+	spin_lock_init(&adapter->hw.miim_lock);
+	spin_lock_init(&adapter->stats_lock);
+	atomic_set(&adapter->irq_sem, 0);
+	pch_gbe_irq_disable(adapter);
+
+	pch_gbe_init_stats(adapter);
+
+	PCH_GBE_DEBUG("vendor_id : 0x%08x  device_id : 0x%08x\n",
+			hw->vendor_id, hw->device_id);
+	PCH_GBE_DEBUG("subsystem vendor_id :0x%08x device_id :0x%08x\n"
+			"revision_id :0x%08x\n", hw->subsystem_vendor_id,
+			hw->subsystem_device_id, hw->revision_id);
+	PCH_GBE_DEBUG("rx_buffer_len : %d  mac.max_frame_size : %d  "
+			"mac.min_frame_size : %d\n",
+			(u32) adapter->rx_buffer_len,
+			hw->mac.max_frame_size,	hw->mac.min_frame_size);
+	return 0;
+}
+
+/**
+ * pch_gbe_open - Called when a network interface is made active
+ * @netdev:	Network interface device structure
+ * Returns
+ *	0:		Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_open(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	int err;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* disallow open during test */
+	if ((test_bit(__PCH_GBE_TESTING, &adapter->flags)))
+		return -EBUSY;
+	/* allocate transmit descriptors */
+	err = pch_gbe_setup_tx_resources(adapter, adapter->tx_ring);
+	if (err)
+		goto err_setup_tx;
+	/* allocate receive descriptors */
+	err = pch_gbe_setup_rx_resources(adapter, adapter->rx_ring);
+	if (err)
+		goto err_setup_rx;
+	pch_gbe_hal_power_up_phy(hw);
+	err = pch_gbe_up(adapter);
+	if (err)
+		goto err_up;
+	PCH_GBE_DEBUG("Success End\n");
+	return 0;
+
+err_up:
+	if (!adapter->wake_up_evt)
+		pch_gbe_hal_power_down_phy(hw);
+	pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+err_setup_rx:
+	pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
+err_setup_tx:
+	pch_gbe_reset(adapter);
+	printk(KERN_ERR KBUILD_MODNAME ": " "Error End\n");
+	return err;
+}
+
+/**
+ * pch_gbe_stop - Disables a network interface
+ * @netdev:  Network interface device structure
+ * Returns
+ *	0: Successfully
+ */
+static int pch_gbe_stop(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	pch_gbe_down(adapter);
+	if (!adapter->wake_up_evt)
+		pch_gbe_hal_power_down_phy(hw);
+	pch_gbe_free_tx_resources(adapter, adapter->tx_ring);
+	pch_gbe_free_rx_resources(adapter, adapter->rx_ring);
+	return 0;
+}
+
+/**
+ * pch_gbe_xmit_frame - Packet transmitting start
+ * @skb:     Socket buffer structure
+ * @netdev:  Network interface device structure
+ * Returns
+ *	- NETDEV_TX_OK:   Normal end
+ *	- NETDEV_TX_BUSY: Error end
+ */
+static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
+	unsigned long flags;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	if (unlikely(skb->len <= 0)) {
+		dev_kfree_skb_any(skb);
+		PCH_GBE_DEBUG("Return : OK  skb len : %d\n", skb->len);
+		return NETDEV_TX_OK;
+	}
+	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Transfer length Error: %d over %d\n",
+			skb->len, adapter->hw.mac.max_frame_size);
+		dev_kfree_skb_any(skb);
+		adapter->stats.tx_length_errors++;
+		return NETDEV_TX_BUSY;
+	}
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+	}
+	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring))) {
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+		PCH_GBE_DEBUG
+		("Return : BUSY  next_to use : 0x%08x  "
+		 "next_to clean : 0x%08x\n",
+		 tx_ring->next_to_use, tx_ring->next_to_clean);
+		return NETDEV_TX_BUSY;
+	}
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
+	/* CRC,ITAG no support */
+	pch_gbe_tx_queue(adapter, tx_ring, skb);
+	return NETDEV_TX_OK;
+}
+
+/**
+ * pch_gbe_get_stats - Get System Network Statistics
+ * @netdev:  Network interface device structure
+ * Returns:  The current stats
+ */
+static struct net_device_stats *pch_gbe_get_stats(
+						struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+	/* only return the current stats */
+	return &adapter->net_stats;
+}
+
+/**
+ * pch_gbe_set_multi - Multicast and Promiscuous mode set
+ * @netdev:   Network interface device structure
+ */
+static void pch_gbe_set_multi(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	struct netdev_hw_addr *ha;
+	u8 *mta_list;
+	u32 rctl;
+	int i;
+	int mc_count;
+
+	PCH_GBE_DEBUG("%s  netdev->flags : 0x%08x\n", __func__, netdev->flags);
+
+	/* Check for Promiscuous and All Multicast modes */
+	rctl = ioread32(&hw->reg->RX_MODE);
+	mc_count = netdev_mc_count(netdev);
+	if ((netdev->flags & IFF_PROMISC)) {
+		rctl &= ~PCH_GBE_ADD_FIL_EN;
+		rctl &= ~PCH_GBE_MLT_FIL_EN;
+	} else if ((netdev->flags & IFF_ALLMULTI)) {
+		/* all the multicasting receive permissions */
+		rctl |= PCH_GBE_ADD_FIL_EN;
+		rctl &= ~PCH_GBE_MLT_FIL_EN;
+	} else {
+		if (mc_count >= PCH_GBE_MAR_ENTRIES) {
+			/* all the multicasting receive permissions */
+			rctl |= PCH_GBE_ADD_FIL_EN;
+			rctl &= ~PCH_GBE_MLT_FIL_EN;
+		} else {
+			rctl |= (PCH_GBE_ADD_FIL_EN | PCH_GBE_MLT_FIL_EN);
+		}
+	}
+	iowrite32(rctl, &hw->reg->RX_MODE);
+
+	if (mc_count >= PCH_GBE_MAR_ENTRIES)
+		return;
+	mta_list = kmalloc(mc_count * ETH_ALEN, GFP_ATOMIC);
+	if (!mta_list)
+		return;
+
+	/* The shared function expects a packed array of only addresses. */
+	i = 0;
+	netdev_for_each_mc_addr(ha, netdev) {
+		if (i == mc_count)
+			break;
+		memcpy(mta_list + (i++ * ETH_ALEN), &ha->addr, ETH_ALEN);
+	}
+	pch_gbe_mac_mc_addr_list_update(hw, mta_list, i, 1,
+					PCH_GBE_MAR_ENTRIES);
+	kfree(mta_list);
+
+	PCH_GBE_DEBUG("RX_MODE reg(check bit31,30 ADD,MLT) : 0x%08x  "
+			 "netdev->mc_count : 0x%08x\n",
+			 ioread32(&hw->reg->RX_MODE), mc_count);
+}
+
+/**
+ * pch_gbe_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: Network interface device structure
+ * @addr:   Pointer to an address structure
+ * Returns
+ *	0:		Successfully
+ *	-EADDRNOTAVAIL:	Failed
+ */
+static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *skaddr = addr;
+	int ret_val;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	if (!is_valid_ether_addr(skaddr->sa_data)) {
+		ret_val = -EADDRNOTAVAIL;
+	} else {
+		memcpy(netdev->dev_addr, skaddr->sa_data, netdev->addr_len);
+		memcpy(adapter->hw.mac.addr, skaddr->sa_data, netdev->addr_len);
+		pch_gbe_mac_mar_set(&adapter->hw, adapter->hw.mac.addr, 0);
+		ret_val = 0;
+	}
+	PCH_GBE_DEBUG("ret_val : 0x%08x\n", ret_val);
+	PCH_GBE_DEBUG("dev_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
+			netdev->dev_addr[0], netdev->dev_addr[1],
+			netdev->dev_addr[2], netdev->dev_addr[3],
+			netdev->dev_addr[4], netdev->dev_addr[5]);
+	PCH_GBE_DEBUG("mac_addr : %02x:%02x:%02x:%02x:%02x:%02x\n",
+			adapter->hw.mac.addr[0], adapter->hw.mac.addr[1],
+			adapter->hw.mac.addr[2], adapter->hw.mac.addr[3],
+			adapter->hw.mac.addr[4], adapter->hw.mac.addr[5]);
+	PCH_GBE_DEBUG("MAC_ADR1AB reg : 0x%08x 0x%08x\n",
+			ioread32(&adapter->hw.reg->mac_adr[0].high),
+			ioread32(&adapter->hw.reg->mac_adr[0].low));
+	return ret_val;
+}
+
+/**
+ * pch_gbe_change_mtu - Change the Maximum Transfer Unit
+ * @netdev:   Network interface device structure
+ * @new_mtu:  New value for maximum frame size
+ * Returns
+ *	0:		Successfully
+ *	-EINVAL:	Failed
+ */
+static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	int max_frame;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+		(max_frame > PCH_GBE_MAX_JUMBO_FRAME_SIZE)) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "Invalid MTU setting\n");
+		return -EINVAL;
+	}
+	if (max_frame <= PCH_GBE_FRAME_SIZE_2048)
+		adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_2048;
+	else if (max_frame <= PCH_GBE_FRAME_SIZE_4096)
+		adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_4096;
+	else if (max_frame <= PCH_GBE_FRAME_SIZE_8192)
+		adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_8192;
+	else
+		adapter->rx_buffer_len = PCH_GBE_MAX_JUMBO_FRAME_SIZE;
+	netdev->mtu = new_mtu;
+	adapter->hw.mac.max_frame_size = max_frame;
+
+	if (netif_running(netdev))
+		pch_gbe_reinit_locked(adapter);
+	else
+		pch_gbe_reset(adapter);
+
+	PCH_GBE_DEBUG
+	("max_frame : %d  rx_buffer_len : %d  mtu : %d  max_frame_size : %d\n",
+	 max_frame, (u32) adapter->rx_buffer_len, netdev->mtu,
+	 adapter->hw.mac.max_frame_size);
+	return 0;
+}
+
+/**
+ * pch_gbe_ioctl - Controls register through a MII interface
+ * @netdev:   Network interface device structure
+ * @ifr:      Pointer to ifr structure
+ * @cmd:      Control command
+ * Returns
+ *	0:	Successfully
+ *	Negative value:	Failed
+ */
+static int pch_gbe_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s  cmd : 0x%04x\n", __func__, cmd);
+
+	return generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
+}
+
+/**
+ * pch_gbe_tx_timeout - Respond to a Tx Hang
+ * @netdev:   Network interface device structure
+ */
+static void pch_gbe_tx_timeout(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	/* Do the reset outside of interrupt context */
+	adapter->stats.tx_timeout_count++;
+	schedule_work(&adapter->reset_task);
+}
+
+/**
+ * pch_gbe_napi_poll - NAPI receive and transfer polling callback
+ * @napi:    Pointer of polling device struct
+ * @budget:  The maximum number of a packet
+ * Returns
+ *	0:  Exit the polling mode
+ *	1:  Continue the polling mode
+ */
+static int pch_gbe_napi_poll(struct napi_struct *napi, int budget)
+{
+	struct pch_gbe_adapter *adapter =
+	    container_of(napi, struct pch_gbe_adapter, napi);
+	struct net_device *netdev = adapter->netdev;
+	int work_done = 0;
+	int poll_end_flag = 0;
+	int cleaned = 0;
+
+	PCH_GBE_DEBUG("%s  budget : %d\n", __func__, budget);
+
+	/* Keep link state information with original netdev */
+	if (!netif_carrier_ok(netdev)) {
+		poll_end_flag = 1;
+	} else {
+		cleaned = pch_gbe_clean_tx(adapter, adapter->tx_ring);
+		pch_gbe_clean_rx(adapter, adapter->rx_ring, &work_done, budget);
+
+		if (cleaned)
+			work_done = budget;
+		/* If no Tx and not enough Rx work done,
+		 * exit the polling mode
+		 */
+		if ((work_done < budget) || !netif_running(netdev))
+			poll_end_flag = 1;
+	}
+
+	if (poll_end_flag == 1) {
+		napi_complete(napi);
+		pch_gbe_irq_enable(adapter);
+	}
+
+	PCH_GBE_DEBUG("poll_end_flag : %d  work_done : %d  budget : %d\n",
+			poll_end_flag, work_done, budget);
+	return work_done;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * pch_gbe_netpoll - Used by things like netconsole to send skbs
+ * @netdev:  Network interface device structure
+ */
+static void pch_gbe_netpoll(struct net_device *netdev)
+{
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	disable_irq(adapter->pdev->irq);
+	pch_gbe_intr(adapter->pdev->irq, netdev);
+	enable_irq(adapter->pdev->irq);
+}
+#else
+#define pch_gbe_netpoll NULL
+#endif
+
+static const struct net_device_ops pch_gbe_netdev_ops = {
+	.ndo_open = pch_gbe_open,
+	.ndo_stop = pch_gbe_stop,
+	.ndo_start_xmit = pch_gbe_xmit_frame,
+	.ndo_get_stats = pch_gbe_get_stats,
+	.ndo_set_mac_address = pch_gbe_set_mac,
+	.ndo_tx_timeout = pch_gbe_tx_timeout,
+	.ndo_change_mtu = pch_gbe_change_mtu,
+	.ndo_do_ioctl = pch_gbe_ioctl,
+	.ndo_set_multicast_list = &pch_gbe_set_multi,
+	.ndo_poll_controller = pch_gbe_netpoll,
+};
+
+static pci_ers_result_t pch_gbe_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		pch_gbe_down(adapter);
+	pci_disable_device(pdev);
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t pch_gbe_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	if (pci_enable_device(pdev)) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+	pci_enable_wake(pdev, PCI_D0, 0);
+	pch_gbe_hal_power_up_phy(hw);
+	pch_gbe_reset(adapter);
+	/* Clear wake up status */
+	pch_gbe_mac_set_wol_event(hw, 0);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+static void pch_gbe_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	if (netif_running(netdev)) {
+		if (pch_gbe_up(adapter)) {
+			PCH_GBE_DEBUG("can't bring device back up after reset\n"
+					);
+			return;
+		}
+	}
+	netif_device_attach(netdev);
+}
+
+static int pch_gbe_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 wufc = adapter->wake_up_evt;
+	int retval = 0;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		pch_gbe_down(adapter);
+#ifdef CONFIG_PM
+	/* Implement our own version of pci_save_state(pdev) because pci-
+	 * express adapters have 256-byte config spaces. */
+	retval = pci_save_state(pdev);
+	if (retval) {
+		PCH_GBE_DEBUG("pci_save_state failed\n");
+		return retval;
+	}
+#endif
+	if (wufc) {
+		pch_gbe_set_multi(netdev);
+		pch_gbe_setup_rctl(adapter);
+		pch_gbe_configure_rx(adapter);
+		pch_gbe_set_rgmii_ctrl(adapter, hw->mac.link_speed,
+					hw->mac.link_duplex);
+		pch_gbe_set_mode(adapter, hw->mac.link_speed,
+					hw->mac.link_duplex);
+		pch_gbe_mac_set_wol_event(hw, wufc);
+		pci_disable_device(pdev);
+		retval = pci_set_power_state(pdev, PCI_D0);
+		if (retval)
+			PCH_GBE_DEBUG("pci_set_power_state failed\n");
+		retval = pci_enable_wake(pdev, PCI_D0, 1);
+		if (retval)
+			PCH_GBE_DEBUG("pci_enable_wake failed\n");
+	} else {
+		pch_gbe_hal_power_down_phy(hw);
+		pch_gbe_mac_set_wol_event(hw, wufc);
+		pci_disable_device(pdev);
+		pci_enable_wake(pdev, PCI_D0, 0);
+		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	}
+	return retval;
+}
+
+#ifdef CONFIG_PM
+static int pch_gbe_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+	struct pch_gbe_hw *hw = &adapter->hw;
+	u32 err;
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	pci_enable_wake(pdev, PCI_D0, 0);
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+			"Cannot enable PCI device from suspend\n");
+		return err;
+	}
+	pci_set_master(pdev);
+	pch_gbe_hal_power_up_phy(hw);
+	pch_gbe_reset(adapter);
+	/* Clear wake on lan control and status */
+	pch_gbe_mac_set_wol_event(hw, 0);
+
+	if (netif_running(netdev))
+		pch_gbe_up(adapter);
+	netif_device_attach(netdev);
+
+	return 0;
+}
+#endif /* CONFIG_PM */
+
+static void pch_gbe_shutdown(struct pci_dev *pdev)
+{
+	PCH_GBE_DEBUG("%s\n", __func__);
+	pch_gbe_suspend(pdev, PMSG_SUSPEND);
+}
+
+static void pch_gbe_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
+
+	PCH_GBE_DEBUG("%s\n", __func__);
+
+	flush_scheduled_work();
+	unregister_netdev(netdev);
+	dev_put(adapter->polling_netdev);
+
+	pch_gbe_hal_phy_hw_reset(&adapter->hw);
+
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+	kfree(adapter->polling_netdev);
+
+	iounmap(adapter->hw.reg);
+	pci_release_regions(pdev);
+	free_netdev(netdev);
+	pci_disable_device(pdev);
+}
+
+static int pch_gbe_probe(struct pci_dev *pdev,
+			  const struct pci_device_id *pci_id)
+{
+	struct net_device *netdev;
+	struct pch_gbe_adapter *adapter;
+	unsigned long mmio_start;
+	unsigned long mmio_len;
+	int i, ret;
+
+	PCH_GBE_DEBUG("pch_gbe_probe\n");
+	ret = pci_enable_device(pdev);
+	if (ret)
+		return ret;
+
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))
+		&& !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		;
+	} else {
+		ret = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (ret) {
+			ret = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
+			if (ret) {
+				printk(KERN_ERR KBUILD_MODNAME ": ERR: "
+				    "No usable DMA configuration, aborting\n");
+				goto err_disable_device;
+			}
+		}
+	}
+	ret = pci_request_regions(pdev, KBUILD_MODNAME);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": "
+		    "ERR: Can't reserve PCI I/O and memory resources\n");
+		goto err_disable_device;
+	}
+	pci_set_master(pdev);
+
+	netdev = alloc_etherdev((int)sizeof(struct pch_gbe_adapter));
+	if (!netdev) {
+		ret = -ENOMEM;
+		printk(KERN_ERR KBUILD_MODNAME ": "
+		    "ERR: Can't allocates and sets up an Ethernet device\n");
+		goto err_release_pci;
+	}
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	pci_set_drvdata(pdev, netdev);
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->pdev = pdev;
+	adapter->hw.back = adapter;
+	mmio_start = pci_resource_start(pdev, PCH_GBE_PCI_BAR);
+	mmio_len = pci_resource_len(pdev, PCH_GBE_PCI_BAR);
+	adapter->hw.reg = ioremap_nocache(mmio_start, mmio_len);
+	if (!adapter->hw.reg) {
+		ret = -EIO;
+		printk(KERN_ERR KBUILD_MODNAME ": " "Can't ioremap\n");
+		goto err_free_netdev;
+	}
+
+	netdev->netdev_ops = &pch_gbe_netdev_ops;
+	netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
+	netif_napi_add(netdev, &adapter->napi,
+		       pch_gbe_napi_poll, PCH_GBE_RX_WEIGHT);
+	strncpy(netdev->name, pci_name(pdev), (int)sizeof(netdev->name) - 1);
+	netdev->mem_start = mmio_start;
+	netdev->mem_end = mmio_start + mmio_len;
+	netdev->features = NETIF_F_HW_CSUM;
+	pch_gbe_set_ethtool_ops(netdev);
+
+	pch_gbe_mac_reset_hw(&adapter->hw);
+
+	/* setup the private structure */
+	ret = pch_gbe_sw_init(adapter);
+	if (ret)
+		goto err_iounmap;
+
+	/* Initialize PHY */
+	ret = pch_gbe_init_phy(adapter);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "PHY initialize error\n");
+		goto err_free_adapter;
+	}
+	pch_gbe_hal_get_bus_info(&adapter->hw);
+
+	/* Read the MAC address. and store to the private data */
+	ret = pch_gbe_hal_read_mac_addr(&adapter->hw);
+	if (ret) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "MAC address Read Error\n");
+		goto err_free_adapter;
+	}
+
+	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
+		printk(KERN_ERR KBUILD_MODNAME ": " "Invalid MAC Address\n");
+		ret = -EIO;
+		goto err_free_adapter;
+	}
+
+	init_timer(&adapter->watchdog_timer);
+	adapter->watchdog_timer.function = &pch_gbe_watchdog;
+	adapter->watchdog_timer.data = (unsigned long)adapter;
+
+	INIT_WORK(&adapter->reset_task, pch_gbe_reset_task);
+
+	pch_gbe_check_options(adapter);
+
+	if (adapter->tx_csum)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	/* initialize the wol settings based on the eeprom settings */
+	adapter->wake_up_evt = PCH_GBE_WL_INIT_SETTING;
+	for (i = 0; i < 6; i++)
+		printk(KERN_INFO "%2.2x%c",
+			netdev->dev_addr[i], i == 5 ? '\n' : ':');
+
+	/* reset the hardware with the new settings */
+	pch_gbe_reset(adapter);
+
+	strcpy(netdev->name, "eth%d");
+	ret = register_netdev(netdev);
+	if (ret)
+		goto err_free_adapter;
+	/* tell the stack to leave us alone until pch_gbe_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	PCH_GBE_DEBUG("OKIsemi(R) PCH Network Connection\n");
+
+	device_set_wakeup_enable(&pdev->dev, 1);
+	return 0;
+
+err_free_adapter:
+	pch_gbe_hal_phy_hw_reset(&adapter->hw);
+	dev_put(adapter->polling_netdev);
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+	kfree(adapter->polling_netdev);
+err_iounmap:
+	iounmap(adapter->hw.reg);
+err_free_netdev:
+	free_netdev(netdev);
+err_release_pci:
+	pci_release_regions(pdev);
+err_disable_device:
+	pci_disable_device(pdev);
+	return ret;
+}
+
+static const struct pci_device_id pch_gbe_pcidev_id[] = {
+	{.vendor = PCI_VENDOR_ID_INTEL,
+	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
+	 .subvendor = PCI_ANY_ID,
+	 .subdevice = PCI_ANY_ID,
+	 .class = (PCI_CLASS_NETWORK_ETHERNET << 8),
+	 .class_mask = (0xFFFF00)
+	 },
+	/* required last entry */
+	{0}
+};
+
+static struct pci_error_handlers pch_gbe_err_handler = {
+	.error_detected = pch_gbe_io_error_detected,
+	.slot_reset = pch_gbe_io_slot_reset,
+	.resume = pch_gbe_io_resume
+};
+
+static struct pci_driver pch_gbe_pcidev = {
+	.name = KBUILD_MODNAME,
+	.id_table = pch_gbe_pcidev_id,
+	.probe = pch_gbe_probe,
+	.remove = pch_gbe_remove,
+#ifdef CONFIG_PM
+	.suspend = pch_gbe_suspend,
+	.resume = pch_gbe_resume,
+#endif
+	.shutdown = pch_gbe_shutdown,
+	.err_handler = &pch_gbe_err_handler
+};
+
+
+static int __init pch_gbe_init_module(void)
+{
+	int ret;
+	printk(KERN_INFO "%s - version %s\n", DRV_STRING, DRV_VERSION);
+
+	ret = pci_register_driver(&pch_gbe_pcidev);
+	if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
+		if (copybreak == 0) {
+			printk(KERN_INFO "pch_gbe: copybreak disabled\n");
+		} else {
+			printk(KERN_INFO "pch_gbe: copybreak enabled for "
+				"packets <= %u bytes\n", copybreak);
+		}
+	}
+	return ret;
+}
+
+static void __exit pch_gbe_exit_module(void)
+{
+	PCH_GBE_DEBUG("pch_gbe_exit_module\n");
+	pci_unregister_driver(&pch_gbe_pcidev);
+
+	printk(KERN_INFO "%s - unregister\n", DRV_STRING);
+}
+
+module_init(pch_gbe_init_module);
+module_exit(pch_gbe_exit_module);
+
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_AUTHOR(DRV_COPYRIGHT);
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
+
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
+/* pch_gbe_main.c */
diff --git a/drivers/net/pch_gbe/pch_gbe_param.c b/drivers/net/pch_gbe/pch_gbe_param.c
new file mode 100644
index 0000000..277dd3d
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_param.c
@@ -0,0 +1,516 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include "pch_gbe.h"
+
+#define OPTION_UNSET   -1
+#define OPTION_DISABLED 0
+#define OPTION_ENABLED  1
+
+/**
+ * TxDescriptors - Transmit Descriptor Count
+ * @Valid Range:   PCH_GBE_MIN_TXD - PCH_GBE_MAX_TXD
+ * @Default Value: PCH_GBE_DEFAULT_TXD
+ */
+static int TxDescriptors = OPTION_UNSET;
+module_param(TxDescriptors, int, 0);
+MODULE_PARM_DESC(TxDescriptors, "Number of transmit descriptors");
+
+#define PCH_GBE_DEFAULT_TXD                  256
+
+/**
+ * RxDescriptors -Receive Descriptor Count
+ * @Valid Range:   PCH_GBE_MIN_RXD - PCH_GBE_MAX_RXD
+ * @Default Value: PCH_GBE_DEFAULT_RXD
+ */
+static int RxDescriptors = OPTION_UNSET;
+module_param(RxDescriptors, int, 0);
+MODULE_PARM_DESC(RxDescriptors, "Number of receive descriptors");
+
+#define PCH_GBE_DEFAULT_RXD                  256
+
+/**
+ * Speed - User Specified Speed Override
+ * @Valid Range: 0, 10, 100, 1000
+ *   - 0:    auto-negotiate at all supported speeds
+ *   - 10:   only link at 10 Mbps
+ *   - 100:  only link at 100 Mbps
+ *   - 1000: only link at 1000 Mbps
+ * @Default Value: 0
+ */
+static int Speed = OPTION_UNSET;
+module_param(Speed, int, 0);
+MODULE_PARM_DESC(Speed, "Speed setting");
+
+#define PHY_SPEED_10    10
+#define PHY_SPEED_100   100
+#define PHY_SPEED_1000  1000
+
+/**
+ * Duplex - User Specified Duplex Override
+ * @Valid Range: 0-2
+ *   - 0:  auto-negotiate for duplex
+ *   - 1:  only link at half duplex
+ *   - 2:  only link at full duplex
+ * @Default Value: 0
+ */
+static int Duplex = OPTION_UNSET;
+module_param(Duplex, int, 0);
+MODULE_PARM_DESC(Duplex, "Duplex setting");
+
+#define PHY_HALF_DUPLEX 1
+#define PHY_FULL_DUPLEX 2
+
+/**
+ * AutoNeg - Auto-negotiation Advertisement Override
+ * @Valid Range: 0x01-0x0F, 0x20-0x2F
+ *
+ *       The AutoNeg value is a bit mask describing which speed and duplex
+ *       combinations should be advertised during auto-negotiation.
+ *       The supported speed and duplex modes are listed below
+ *
+ *       Bit           7     6     5      4      3     2     1      0
+ *       Speed (Mbps)  N/A   N/A   1000   N/A    100   100   10     10
+ *       Duplex                    Full          Full  Half  Full   Half
+ *
+ * @Default Value: 0x2F (copper)
+ */
+static int AutoNeg = OPTION_UNSET;
+module_param(AutoNeg, int, 0);
+MODULE_PARM_DESC(AutoNeg, "Advertised auto-negotiation setting");
+
+#define PHY_ADVERTISE_10_HALF      0x0001
+#define PHY_ADVERTISE_10_FULL      0x0002
+#define PHY_ADVERTISE_100_HALF     0x0004
+#define PHY_ADVERTISE_100_FULL     0x0008
+#define PHY_ADVERTISE_1000_HALF    0x0010 /* Not used, just FYI */
+#define PHY_ADVERTISE_1000_FULL    0x0020
+#define PCH_AUTONEG_ADVERTISE_DEFAULT   0x2F
+
+/**
+ * FlowControl - User Specified Flow Control Override
+ * @Valid Range: 0-3
+ *    - 0:  No Flow Control
+ *    - 1:  Rx only, respond to PAUSE frames but do not generate them
+ *    - 2:  Tx only, generate PAUSE frames but ignore them on receive
+ *    - 3:  Full Flow Control Support
+ * @Default Value: Read flow control settings from the EEPROM
+ */
+static int FlowControl = OPTION_UNSET;
+module_param(FlowControl, int, 0);
+MODULE_PARM_DESC(FlowControl, "Flow Control setting");
+
+/*
+ * XsumRX - Receive Checksum Offload Enable/Disable
+ * @Valid Range: 0, 1
+ *    - 0:  disables all checksum offload
+ *    - 1:  enables receive IP/TCP/UDP checksum offload
+ * @Default Value: PCH_GBE_DEFAULT_RX_CSUM
+ */
+static int XsumRX = OPTION_UNSET;
+module_param(XsumRX, int, 0);
+MODULE_PARM_DESC(XsumRX, "Disable or enable Receive Checksum offload");
+
+#define PCH_GBE_DEFAULT_RX_CSUM             TRUE	/* TRUEorFALSE */
+
+/*
+ * XsumTX - Transmit Checksum Offload Enable/Disable
+ * @Valid Range: 0, 1
+ *    - 0:  disables all checksum offload
+ *    - 1:  enables transmit IP/TCP/UDP checksum offload
+ * @Default Value: PCH_GBE_DEFAULT_TX_CSUM
+ */
+static int XsumTX = OPTION_UNSET;
+module_param(XsumTX, int, 0);
+MODULE_PARM_DESC(XsumTX, "Disable or enable Transmit Checksum offload");
+
+#define PCH_GBE_DEFAULT_TX_CSUM             TRUE	/* TRUEorFALSE */
+
+/**
+ * pch_gbe_option - Force the MAC's flow control settings
+ * @hw:	            Pointer to the HW structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+struct pch_gbe_option {
+	enum { enable_option, range_option, list_option } type;
+	signed char *name;
+	signed char *err;
+	int  def;
+	union {
+		struct { /* range_option info */
+			int min;
+			int max;
+		} r;
+		struct { /* list_option info */
+			int nr;
+			struct pch_gbe_opt_list { int i; signed char *str; } *p;
+		} l;
+	} arg;
+};
+
+/**
+ * pch_gbe_validate_option - Validate option
+ * @value:    value
+ * @opt:      option
+ * @adapter:  Board private structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+static int pch_gbe_validate_option(int *value, struct pch_gbe_option *opt,
+		struct pch_gbe_adapter *adapter)
+{
+	if (*value == OPTION_UNSET) {
+		*value = opt->def;
+		return 0;
+	}
+
+	switch (opt->type) {
+	case enable_option:
+		switch (*value) {
+		case OPTION_ENABLED:
+			PCH_GBE_DEBUG("%s Enabled\n", opt->name);
+			return 0;
+		case OPTION_DISABLED:
+			PCH_GBE_DEBUG("%s Disabled\n", opt->name);
+			return 0;
+		}
+		break;
+	case range_option:
+		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+			PCH_GBE_DEBUG(
+					"%s set to %i\n", opt->name, *value);
+			return 0;
+		}
+		break;
+	case list_option: {
+		int i;
+		struct pch_gbe_opt_list *ent;
+
+		for (i = 0; i < opt->arg.l.nr; i++) {
+			ent = &opt->arg.l.p[i];
+			if (*value == ent->i) {
+				if (ent->str[0] != '\0')
+					PCH_GBE_DEBUG("%s\n", ent->str);
+				return 0;
+			}
+		}
+	}
+		break;
+	default:
+		BUG();
+	}
+
+	PCH_GBE_DEBUG("Invalid %s value specified (%i) %s\n",
+			opt->name, *value, opt->err);
+	*value = opt->def;
+	return -1;
+}
+
+/**
+ * pch_gbe_check_copper_options - Range Checking for Link Options, Copper Version
+ * @adapter:  Board private structure
+ */
+static void pch_gbe_check_copper_options(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+	int speed, dplx;
+
+	{ /* Speed */
+		struct pch_gbe_opt_list speed_list[] = {
+				{0, "" },
+				{SPEED_10, ""},
+				{SPEED_100, ""},
+				{SPEED_1000, ""} };
+
+		struct pch_gbe_option opt = {
+			.type = list_option,
+			.name = "Speed",
+			.err  = "parameter ignored",
+			.def  = 0,
+			.arg  = { .l = { .nr = (int)ARRAY_SIZE(speed_list),
+					 .p = speed_list } }
+		};
+		speed = Speed;
+		pch_gbe_validate_option(&speed, &opt, adapter);
+	}
+	{ /* Duplex */
+		struct pch_gbe_opt_list dplx_list[] = {
+				{0, ""},
+				{PHY_HALF_DUPLEX, ""},
+				{PHY_FULL_DUPLEX, ""} };
+
+		struct pch_gbe_option opt = {
+			.type = list_option,
+			.name = "Duplex",
+			.err  = "parameter ignored",
+			.def  = 0,
+			.arg  = { .l = { .nr = (int)ARRAY_SIZE(dplx_list),
+					 .p = dplx_list } }
+		};
+		dplx = Duplex;
+		pch_gbe_validate_option(&dplx, &opt, adapter);
+	}
+
+	{ /* Autoneg */
+		struct pch_gbe_opt_list an_list[] =
+			#define AA "AutoNeg advertising "
+			{{ 0x01, AA "10/HD" },
+			 { 0x02, AA "10/FD" },
+			 { 0x03, AA "10/FD, 10/HD" },
+			 { 0x04, AA "100/HD" },
+			 { 0x05, AA "100/HD, 10/HD" },
+			 { 0x06, AA "100/HD, 10/FD" },
+			 { 0x07, AA "100/HD, 10/FD, 10/HD" },
+			 { 0x08, AA "100/FD" },
+			 { 0x09, AA "100/FD, 10/HD" },
+			 { 0x0a, AA "100/FD, 10/FD" },
+			 { 0x0b, AA "100/FD, 10/FD, 10/HD" },
+			 { 0x0c, AA "100/FD, 100/HD" },
+			 { 0x0d, AA "100/FD, 100/HD, 10/HD" },
+			 { 0x0e, AA "100/FD, 100/HD, 10/FD" },
+			 { 0x0f, AA "100/FD, 100/HD, 10/FD, 10/HD" },
+			 { 0x20, AA "1000/FD" },
+			 { 0x21, AA "1000/FD, 10/HD" },
+			 { 0x22, AA "1000/FD, 10/FD" },
+			 { 0x23, AA "1000/FD, 10/FD, 10/HD" },
+			 { 0x24, AA "1000/FD, 100/HD" },
+			 { 0x25, AA "1000/FD, 100/HD, 10/HD" },
+			 { 0x26, AA "1000/FD, 100/HD, 10/FD" },
+			 { 0x27, AA "1000/FD, 100/HD, 10/FD, 10/HD" },
+			 { 0x28, AA "1000/FD, 100/FD" },
+			 { 0x29, AA "1000/FD, 100/FD, 10/HD" },
+			 { 0x2a, AA "1000/FD, 100/FD, 10/FD" },
+			 { 0x2b, AA "1000/FD, 100/FD, 10/FD, 10/HD" },
+			 { 0x2c, AA "1000/FD, 100/FD, 100/HD" },
+			 { 0x2d, AA "1000/FD, 100/FD, 100/HD, 10/HD" },
+			 { 0x2e, AA "1000/FD, 100/FD, 100/HD, 10/FD" },
+			 { 0x2f, AA "1000/FD, 100/FD, 100/HD, 10/FD, 10/HD" } };
+
+		struct pch_gbe_option opt = {
+			.type = list_option,
+			.name = "AutoNeg",
+			.err  = "parameter ignored",
+			.def  = PCH_AUTONEG_ADVERTISE_DEFAULT,
+			.arg  = { .l = { .nr = (int)ARRAY_SIZE(an_list),
+					 .p = an_list} }
+		};
+		if (speed || dplx) {
+			PCH_GBE_DEBUG(
+			"AutoNeg specified along with Speed or Duplex, "
+			"parameter ignored\n");
+			hw->phy.autoneg_advertised = opt.def;
+		} else {
+			hw->phy.autoneg_advertised = AutoNeg;
+			pch_gbe_validate_option(
+				(int *)(&hw->phy.autoneg_advertised),
+				&opt, adapter);
+		}
+	}
+
+	switch (speed + dplx) {
+	case 0:
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		if ((speed || dplx))
+			PCH_GBE_DEBUG(
+				"Speed and duplex autonegotiation enabled\n");
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_HALF_DUPLEX:
+		PCH_GBE_DEBUG("Half Duplex specified without Speed\n");
+		PCH_GBE_DEBUG("Using Autonegotiation at "
+			"Half Duplex only\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_HALF |
+						PHY_ADVERTISE_100_HALF;
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_FULL_DUPLEX:
+		PCH_GBE_DEBUG("Full Duplex specified without Speed\n");
+		PCH_GBE_DEBUG("Using Autonegotiation at "
+			"Full Duplex only\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_FULL |
+						PHY_ADVERTISE_100_FULL |
+						PHY_ADVERTISE_1000_FULL;
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_FULL;
+		break;
+	case PHY_SPEED_10:
+		PCH_GBE_DEBUG("10 Mbps Speed specified "
+			"without Duplex\n");
+		PCH_GBE_DEBUG("Using Autonegotiation at 10 Mbps only\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		hw->phy.autoneg_advertised = PHY_ADVERTISE_10_HALF |
+						PHY_ADVERTISE_10_FULL;
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_SPEED_10 + PHY_HALF_DUPLEX:
+		PCH_GBE_DEBUG("Forcing to 10 Mbps Half Duplex\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 0;
+		hw->phy.autoneg_advertised = 0;
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_SPEED_10 + PHY_FULL_DUPLEX:
+		PCH_GBE_DEBUG("Forcing to 10 Mbps Full Duplex\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 0;
+		hw->phy.autoneg_advertised = 0;
+		hw->mac.link_speed = SPEED_10;
+		hw->mac.link_duplex = DUPLEX_FULL;
+		break;
+	case PHY_SPEED_100:
+		PCH_GBE_DEBUG("100 Mbps Speed specified "
+			"without Duplex\n");
+		PCH_GBE_DEBUG("Using Autonegotiation at "
+			"100 Mbps only\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		hw->phy.autoneg_advertised = PHY_ADVERTISE_100_HALF |
+						PHY_ADVERTISE_100_FULL;
+		hw->mac.link_speed = SPEED_100;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_SPEED_100 + PHY_HALF_DUPLEX:
+		PCH_GBE_DEBUG("Forcing to 100 Mbps Half Duplex\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 0;
+		hw->phy.autoneg_advertised = 0;
+		hw->mac.link_speed = SPEED_100;
+		hw->mac.link_duplex = DUPLEX_HALF;
+		break;
+	case PHY_SPEED_100 + PHY_FULL_DUPLEX:
+		PCH_GBE_DEBUG("Forcing to 100 Mbps Full Duplex\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 0;
+		hw->phy.autoneg_advertised = 0;
+		hw->mac.link_speed = SPEED_100;
+		hw->mac.link_duplex = DUPLEX_FULL;
+		break;
+	case PHY_SPEED_1000:
+		PCH_GBE_DEBUG("1000 Mbps Speed specified without "
+			"Duplex\n");
+		goto full_duplex_only;
+	case PHY_SPEED_1000 + PHY_HALF_DUPLEX:
+		PCH_GBE_DEBUG(
+			"Half Duplex is not supported at 1000 Mbps\n");
+		/* fall through */
+	case PHY_SPEED_1000 + PHY_FULL_DUPLEX:
+full_duplex_only:
+		PCH_GBE_DEBUG(
+		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
+		hw->mac.autoneg = hw->mac.fc_autoneg = 1;
+		hw->phy.autoneg_advertised = PHY_ADVERTISE_1000_FULL;
+		hw->mac.link_speed = SPEED_1000;
+		hw->mac.link_duplex = DUPLEX_FULL;
+		break;
+	default:
+		BUG();
+	}
+}
+
+/**
+ * pch_gbe_check_options - Range Checking for Command Line Parameters
+ * @adapter:  Board private structure
+ */
+void pch_gbe_check_options(struct pch_gbe_adapter *adapter)
+{
+	struct pch_gbe_hw *hw = &adapter->hw;
+
+	{ /* Transmit Descriptor Count */
+		struct pch_gbe_option opt = {
+			.type = range_option,
+			.name = "Transmit Descriptors",
+			.err  = "using default of "
+				__MODULE_STRING(PCH_GBE_DEFAULT_TXD),
+			.def  = PCH_GBE_DEFAULT_TXD,
+			.arg  = { .r = { .min = PCH_GBE_MIN_TXD } },
+			.arg  = { .r = { .max = PCH_GBE_MAX_TXD } }
+		};
+		struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
+		tx_ring->count = TxDescriptors;
+		pch_gbe_validate_option(&tx_ring->count, &opt, adapter);
+		PCH_GBE_ROUNDUP(tx_ring->count,
+					PCH_GBE_TX_DESC_MULTIPLE);
+	}
+	{ /* Receive Descriptor Count */
+		struct pch_gbe_option opt = {
+			.type = range_option,
+			.name = "Receive Descriptors",
+			.err  = "using default of "
+				__MODULE_STRING(PCH_GBE_DEFAULT_RXD),
+			.def  = PCH_GBE_DEFAULT_RXD,
+			.arg  = { .r = { .min = PCH_GBE_MIN_RXD } },
+			.arg  = { .r = { .max = PCH_GBE_MAX_RXD } }
+		};
+		struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
+		rx_ring->count = RxDescriptors;
+		pch_gbe_validate_option(&rx_ring->count, &opt, adapter);
+		PCH_GBE_ROUNDUP(rx_ring->count,
+				PCH_GBE_RX_DESC_MULTIPLE);
+	}
+	{ /* Checksum Offload Enable/Disable */
+		struct pch_gbe_option opt = {
+			.type = enable_option,
+			.name = "Checksum Offload",
+			.err  = "defaulting to Enabled",
+			.def  = PCH_GBE_DEFAULT_RX_CSUM
+		};
+
+		adapter->rx_csum = XsumRX;
+		pch_gbe_validate_option((int *)(&adapter->rx_csum),
+					&opt, adapter);
+	}
+	{ /* Checksum Offload Enable/Disable */
+		struct pch_gbe_option opt = {
+			.type = enable_option,
+			.name = "Checksum Offload",
+			.err  = "defaulting to Enabled",
+			.def  = PCH_GBE_DEFAULT_TX_CSUM
+		};
+		adapter->tx_csum = XsumTX;
+		pch_gbe_validate_option((int *)(&adapter->tx_csum),
+						&opt, adapter);
+	}
+	{ /* Flow Control */
+
+		struct pch_gbe_opt_list fc_list[] = {
+			{PCH_GBE_FC_NONE, "Flow Control Disabled"},
+			{PCH_GBE_FC_RX_PAUSE, "Flow Control Receive Only"},
+			{PCH_GBE_FC_TX_PAUSE, "Flow Control Transmit Only"},
+			{PCH_GBE_FC_FULL, "Flow Control Enabled"} };
+
+		struct pch_gbe_option opt = {
+			.type = list_option,
+			.name = "Flow Control",
+			.err  = "reading default settings from EEPROM",
+			.def  = PCH_GBE_FC_DEFAULT,
+			.arg  = { .l = { .nr = (int)ARRAY_SIZE(fc_list),
+					 .p = fc_list } }
+		};
+
+		hw->mac.fc = FlowControl;
+		pch_gbe_validate_option((int *)(&hw->mac.fc),
+						&opt, adapter);
+	}
+
+	pch_gbe_check_copper_options(adapter);
+}
+
+
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.c b/drivers/net/pch_gbe/pch_gbe_phy.c
new file mode 100644
index 0000000..e41146a
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_phy.c
@@ -0,0 +1,277 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include <linux/delay.h>
+
+#include "pch_gbe.h"
+#include "pch_gbe_phy.h"
+
+#define PHY_MAX_REG_ADDRESS   0x1F	/* 5 bit address bus (0-0x1F) */
+
+/* PHY 1000 MII Register/Bit Definitions */
+/* PHY Registers defined by IEEE */
+#define PHY_CONTROL           0x00  /* Control Register */
+#define PHY_STATUS            0x01  /* Status Regiser */
+#define PHY_ID1               0x02  /* Phy Id Register (word 1) */
+#define PHY_ID2               0x03  /* Phy Id Register (word 2) */
+#define PHY_AUTONEG_ADV       0x04  /* Autoneg Advertisement */
+#define PHY_LP_ABILITY        0x05  /* Link Partner Ability (Base Page) */
+#define PHY_AUTONEG_EXP       0x06  /* Autoneg Expansion Register */
+#define PHY_NEXT_PAGE_TX      0x07  /* Next Page TX */
+#define PHY_LP_NEXT_PAGE      0x08  /* Link Partner Next Page */
+#define PHY_1000T_CTRL        0x09  /* 1000Base-T Control Register */
+#define PHY_1000T_STATUS      0x0A  /* 1000Base-T Status Register */
+#define PHY_EXT_STATUS        0x0F  /* Extended Status Register */
+#define PHY_PHYSP_CONTROL     0x10  /* PHY Specific Control Register */
+#define PHY_EXT_PHYSP_CONTROL 0x14  /* Extended PHY Specific Control Register */
+#define PHY_LED_CONTROL       0x18  /* LED Control Register */
+#define PHY_EXT_PHYSP_STATUS  0x1B  /* Extended PHY Specific Status Register */
+
+/* PHY Control Register */
+#define MII_CR_SPEED_SELECT_MSB 0x0040	/* bits 6,13: 10=1000, 01=100, 00=10 */
+#define MII_CR_COLL_TEST_ENABLE 0x0080	/* Collision test enable */
+#define MII_CR_FULL_DUPLEX      0x0100	/* FDX =1, half duplex =0 */
+#define MII_CR_RESTART_AUTO_NEG 0x0200	/* Restart auto negotiation */
+#define MII_CR_ISOLATE          0x0400	/* Isolate PHY from MII */
+#define MII_CR_POWER_DOWN       0x0800	/* Power down */
+#define MII_CR_AUTO_NEG_EN      0x1000	/* Auto Neg Enable */
+#define MII_CR_SPEED_SELECT_LSB 0x2000	/* bits 6,13: 10=1000, 01=100, 00=10 */
+#define MII_CR_LOOPBACK         0x4000	/* 0 = normal, 1 = loopback */
+#define MII_CR_RESET            0x8000	/* 0 = normal, 1 = PHY reset */
+#define MII_CR_SPEED_1000       0x0040
+#define MII_CR_SPEED_100        0x2000
+#define MII_CR_SPEED_10         0x0000
+
+/* PHY Status Register */
+#define MII_SR_EXTENDED_CAPS     0x0001	/* Extended register capabilities */
+#define MII_SR_JABBER_DETECT     0x0002	/* Jabber Detected */
+#define MII_SR_LINK_STATUS       0x0004	/* Link Status 1 = link */
+#define MII_SR_AUTONEG_CAPS      0x0008	/* Auto Neg Capable */
+#define MII_SR_REMOTE_FAULT      0x0010	/* Remote Fault Detect */
+#define MII_SR_AUTONEG_COMPLETE  0x0020	/* Auto Neg Complete */
+#define MII_SR_PREAMBLE_SUPPRESS 0x0040	/* Preamble may be suppressed */
+#define MII_SR_EXTENDED_STATUS   0x0100	/* Ext. status info in Reg 0x0F */
+#define MII_SR_100T2_HD_CAPS     0x0200	/* 100T2 Half Duplex Capable */
+#define MII_SR_100T2_FD_CAPS     0x0400	/* 100T2 Full Duplex Capable */
+#define MII_SR_10T_HD_CAPS       0x0800	/* 10T   Half Duplex Capable */
+#define MII_SR_10T_FD_CAPS       0x1000	/* 10T   Full Duplex Capable */
+#define MII_SR_100X_HD_CAPS      0x2000	/* 100X  Half Duplex Capable */
+#define MII_SR_100X_FD_CAPS      0x4000	/* 100X  Full Duplex Capable */
+#define MII_SR_100T4_CAPS        0x8000	/* 100T4 Capable */
+
+/* Phy Id Register (word 2) */
+#define PHY_REVISION_MASK        0x000F
+
+/* PHY Specific Control Register */
+#define PHYSP_CTRL_ASSERT_CRS_TX  0x0800
+
+
+/* Default value of PHY register */
+#define PHY_CONTROL_DEFAULT         0x1140 /* Control Register */
+#define PHY_AUTONEG_ADV_DEFAULT     0x01e0 /* Autoneg Advertisement */
+#define PHY_NEXT_PAGE_TX_DEFAULT    0x2001 /* Next Page TX */
+#define PHY_1000T_CTRL_DEFAULT      0x0300 /* 1000Base-T Control Register */
+#define PHY_PHYSP_CONTROL_DEFAULT   0x01EE /* PHY Specific Control Register */
+
+/**
+ * pch_gbe_phy_get_id - Retrieve the PHY ID and revision
+ * @hw:	       Pointer to the HW structure
+ * Returns
+ *	0:			Successful.
+ *	Negative value:		Failed.
+ */
+s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
+{
+	struct pch_gbe_phy_info *phy = &hw->phy;
+	s32 ret;
+	u16 phy_id1;
+	u16 phy_id2;
+
+	ret = pch_gbe_phy_read_reg_miic(hw, PHY_ID1, &phy_id1);
+	if (ret)
+		return ret;
+	ret = pch_gbe_phy_read_reg_miic(hw, PHY_ID2, &phy_id2);
+	if (ret)
+		return ret;
+	/*
+	 * PHY_ID1: [bit15-0:ID(21-6)]
+	 * PHY_ID2: [bit15-10:ID(5-0)][bit9-4:Model][bit3-0:revision]
+	 */
+	phy->id = (u32)phy_id1;
+	phy->id = ((phy->id << 6) | ((phy_id2 & 0xFC00) >> 10));
+	phy->revision = (u32) (phy_id2 & 0x000F);
+	PCH_GBE_DEBUG("phy->id : 0x%08x  phy->revision : 0x%08x\n",
+			phy->id, phy->revision);
+	return 0;
+}
+
+/**
+ * pch_gbe_phy_read_reg_miic - Read MII control register
+ * @hw:	     Pointer to the HW structure
+ * @offset:  Register offset to be read
+ * @data:    Pointer to the read data
+ * Returns
+ *	0:		Successful.
+ *	-EINVAL:	Invalid argument.
+ */
+s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 *data)
+{
+	struct pch_gbe_phy_info *phy = &hw->phy;
+
+	if (offset > PHY_MAX_REG_ADDRESS) {
+		PCH_GBE_DEBUG("PHY Address %d is out of range\n", offset);
+		return -EINVAL;
+	}
+	*data = pch_gbe_mac_ctrl_miim(hw, phy->addr, PCH_GBE_HAL_MIIM_READ,
+				      offset, (u16)0);
+	return 0;
+}
+
+/**
+ * pch_gbe_phy_write_reg_miic - Write MII control register
+ * @hw:	     Pointer to the HW structure
+ * @offset:  Register offset to be read
+ * @data:    data to write to register at offset
+ * Returns
+ *	0:		Successful.
+ *	-EINVAL:	Invalid argument.
+ */
+s32 pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 data)
+{
+	struct pch_gbe_phy_info *phy = &hw->phy;
+
+	if (offset > PHY_MAX_REG_ADDRESS) {
+		PCH_GBE_DEBUG("PHY Address %d is out of range\n", offset);
+		return -EINVAL;
+	}
+	pch_gbe_mac_ctrl_miim(hw, phy->addr, PCH_GBE_HAL_MIIM_WRITE,
+				 offset, data);
+	return 0;
+}
+
+/**
+ * pch_gbe_phy_sw_reset - PHY software reset
+ * @hw:	            Pointer to the HW structure
+ */
+void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw)
+{
+	u16 phy_ctrl;
+
+	pch_gbe_phy_read_reg_miic(hw, PHY_CONTROL, &phy_ctrl);
+	phy_ctrl |= MII_CR_RESET;
+	pch_gbe_phy_write_reg_miic(hw, PHY_CONTROL, phy_ctrl);
+	udelay(1);
+}
+
+/**
+ * pch_gbe_phy_hw_reset - PHY hardware reset
+ * @hw:	   Pointer to the HW structure
+ */
+void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw)
+{
+	PCH_GBE_DEBUG("pch_gbe_phy_hw_reset\n");
+
+	pch_gbe_phy_write_reg_miic(hw, PHY_CONTROL, PHY_CONTROL_DEFAULT);
+	pch_gbe_phy_write_reg_miic(hw, PHY_AUTONEG_ADV,
+					PHY_AUTONEG_ADV_DEFAULT);
+	pch_gbe_phy_write_reg_miic(hw, PHY_NEXT_PAGE_TX,
+					PHY_NEXT_PAGE_TX_DEFAULT);
+	pch_gbe_phy_write_reg_miic(hw, PHY_1000T_CTRL, PHY_1000T_CTRL_DEFAULT);
+	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL,
+					PHY_PHYSP_CONTROL_DEFAULT);
+}
+
+/**
+ * pch_gbe_phy_power_up - restore link in case the phy was powered down
+ * @hw:	   Pointer to the HW structure
+ */
+void pch_gbe_phy_power_up(struct pch_gbe_hw *hw)
+{
+	u16 mii_reg;
+
+	mii_reg = 0;
+	/* Just clear the power down bit to wake the phy back up */
+	/* according to the manual, the phy will retain its
+	 * settings across a power-down/up cycle */
+	pch_gbe_phy_read_reg_miic(hw, PHY_CONTROL, &mii_reg);
+	mii_reg &= ~MII_CR_POWER_DOWN;
+	pch_gbe_phy_write_reg_miic(hw, PHY_CONTROL, mii_reg);
+}
+
+/**
+ * pch_gbe_phy_power_down - Power down PHY
+ * @hw:	   Pointer to the HW structure
+ */
+void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
+{
+	u16 mii_reg;
+
+	PCH_GBE_DEBUG("pch_gbe_phy_power_down\n");
+
+	mii_reg = 0;
+	/* Power down the PHY so no link is implied when interface is down *
+	 * The PHY cannot be powered down if any of the following is TRUE *
+	 * (a) WoL is enabled
+	 * (b) AMT is active
+	 */
+	pch_gbe_phy_read_reg_miic(hw, PHY_CONTROL, &mii_reg);
+	mii_reg |= MII_CR_POWER_DOWN;
+	pch_gbe_phy_write_reg_miic(hw, PHY_CONTROL, mii_reg);
+	mdelay(1);
+}
+
+/**
+ * pch_gbe_phy_set_rgmii - RGMII interface setting
+ * @hw:	            Pointer to the HW structure
+ */
+inline void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
+{
+	pch_gbe_phy_sw_reset(hw);
+}
+
+/**
+ * pch_gbe_phy_init_setting - PHY initial setting
+ * @hw:	            Pointer to the HW structure
+ */
+void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
+{
+	struct pch_gbe_adapter *adapter;
+	struct ethtool_cmd     cmd;
+	int ret;
+	u16 mii_reg;
+
+	adapter = container_of(hw, struct pch_gbe_adapter, hw);
+	ret = mii_ethtool_gset(&adapter->mii, &cmd);
+	if (ret)
+		printk(KERN_ERR KBUILD_MODNAME ": Error: mii_ethtool_gset\n");
+
+	cmd.speed = hw->mac.link_speed;
+	cmd.duplex = hw->mac.link_duplex;
+	cmd.advertising = hw->phy.autoneg_advertised;
+	cmd.autoneg = hw->mac.autoneg;
+	pch_gbe_phy_write_reg_miic(hw, MII_BMCR, BMCR_RESET);
+	ret = mii_ethtool_sset(&adapter->mii, &cmd);
+	if (ret)
+		printk(KERN_ERR KBUILD_MODNAME ": Error: mii_ethtool_sset\n");
+
+	pch_gbe_phy_sw_reset(hw);
+
+	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
+	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
+	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
+
+}
diff --git a/drivers/net/pch_gbe/pch_gbe_phy.h b/drivers/net/pch_gbe/pch_gbe_phy.h
new file mode 100644
index 0000000..4548cab
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_phy.h
@@ -0,0 +1,32 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+#ifndef _PCH_GBE_PHY_H_
+#define _PCH_GBE_PHY_H_
+
+#define	PCH_GBE_PHY_RESET_DELAY_US  10
+
+s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw);
+s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 *data);
+s32 pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 data);
+void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw);
+void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw);
+void pch_gbe_phy_power_up(struct pch_gbe_hw *hw);
+void pch_gbe_phy_power_down(struct pch_gbe_hw *hw);
+void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw);
+void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw);
+
+#endif /* _PCH_GBE_PHY_H_ */
diff --git a/drivers/net/pch_gbe/pch_gbe_regs.h b/drivers/net/pch_gbe/pch_gbe_regs.h
new file mode 100644
index 0000000..65a17f0
--- /dev/null
+++ b/drivers/net/pch_gbe/pch_gbe_regs.h
@@ -0,0 +1,305 @@
+/*
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
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
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
+ */
+#ifndef _PCH_GBE_REGS_H_
+#define _PCH_GBE_REGS_H_
+
+/**
+ * pch_gbe_regs_mac_adr - Structure holding values of mac address registers
+ * @high	Denotes the 1st to 4th byte from the initial of MAC address
+ * @low		Denotes the 5th to 6th byte from the initial of MAC address
+ */
+struct pch_gbe_regs_mac_adr {
+	u32 high;
+	u32 low;
+};
+/**
+ * pch_udc_regs - Structure holding values of MAC registers
+ */
+struct pch_gbe_regs {
+	u32 INT_ST;
+	u32 INT_EN;
+	u32 MODE;
+	u32 RESET;
+	u32 TCPIP_ACC;
+	u32 EX_LIST;
+	u32 INT_ST_HOLD;
+	u32 PHY_INT_CTRL;
+	u32 MAC_RX_EN;
+	u32 RX_FCTRL;
+	u32 PAUSE_REQ;
+	u32 RX_MODE;
+	u32 TX_MODE;
+	u32 RX_FIFO_ST;
+	u32 TX_FIFO_ST;
+	u32 TX_FID;
+	u32 TX_RESULT;
+	u32 PAUSE_PKT1;
+	u32 PAUSE_PKT2;
+	u32 PAUSE_PKT3;
+	u32 PAUSE_PKT4;
+	u32 PAUSE_PKT5;
+	u32 reserve[2];
+	struct pch_gbe_regs_mac_adr mac_adr[16];
+	u32 ADDR_MASK;
+	u32 MIIM;
+	u32 reserve2;
+	u32 RGMII_ST;
+	u32 RGMII_CTRL;
+	u32 reserve3[3];
+	u32 DMA_CTRL;
+	u32 reserve4[3];
+	u32 RX_DSC_BASE;
+	u32 RX_DSC_SIZE;
+	u32 RX_DSC_HW_P;
+	u32 RX_DSC_HW_P_HLD;
+	u32 RX_DSC_SW_P;
+	u32 reserve5[3];
+	u32 TX_DSC_BASE;
+	u32 TX_DSC_SIZE;
+	u32 TX_DSC_HW_P;
+	u32 TX_DSC_HW_P_HLD;
+	u32 TX_DSC_SW_P;
+	u32 reserve6[3];
+	u32 RX_DMA_ST;
+	u32 TX_DMA_ST;
+	u32 reserve7[2];
+	u32 WOL_ST;
+	u32 WOL_CTRL;
+	u32 WOL_ADDR_MASK;
+};
+
+/* Interrupt Status */
+/* Interrupt Status Hold */
+/* Interrupt Enable */
+#define PCH_GBE_INT_RX_DMA_CMPLT  0x00000001 /* Receive DMA Transfer Complete */
+#define PCH_GBE_INT_RX_VALID      0x00000002 /* MAC Normal Receive Complete */
+#define PCH_GBE_INT_RX_FRAME_ERR  0x00000004 /* Receive frame error */
+#define PCH_GBE_INT_RX_FIFO_ERR   0x00000008 /* Receive FIFO Overflow */
+#define PCH_GBE_INT_RX_DMA_ERR    0x00000010 /* Receive DMA Transfer Error */
+#define PCH_GBE_INT_RX_DSC_EMP    0x00000020 /* Receive Descriptor Empty */
+#define PCH_GBE_INT_TX_CMPLT      0x00000100 /* MAC Transmission Complete */
+#define PCH_GBE_INT_TX_DMA_CMPLT  0x00000200 /* DMA Transfer Complete */
+#define PCH_GBE_INT_TX_FIFO_ERR   0x00000400 /* Transmission FIFO underflow. */
+#define PCH_GBE_INT_TX_DMA_ERR    0x00000800 /* Transmission DMA Error */
+#define PCH_GBE_INT_PAUSE_CMPLT   0x00001000 /* Pause Transmission complete */
+#define PCH_GBE_INT_MIIM_CMPLT    0x00010000 /* MIIM I/F Read completion */
+#define PCH_GBE_INT_PHY_INT       0x00100000 /* Interruption from PHY */
+#define PCH_GBE_INT_WOL_DET       0x01000000 /* Wake On LAN Event detection. */
+#define PCH_GBE_INT_TCPIP_ERR     0x10000000 /* TCP/IP Accelerator Error */
+
+/* Mode */
+#define PCH_GBE_MODE_MII_ETHER      0x00000000  /* GIGA Ethernet Mode [MII] */
+#define PCH_GBE_MODE_GMII_ETHER     0x80000000  /* GIGA Ethernet Mode [GMII] */
+#define PCH_GBE_MODE_HALF_DUPLEX    0x00000000  /* Duplex Mode [half duplex] */
+#define PCH_GBE_MODE_FULL_DUPLEX    0x40000000  /* Duplex Mode [full duplex] */
+#define PCH_GBE_MODE_FR_BST         0x04000000  /* Frame bursting is done */
+
+/* Reset */
+#define PCH_GBE_ALL_RST         0x80000000  /* All reset */
+#define PCH_GBE_TX_RST          0x40000000  /* TX MAC, TX FIFO, TX DMA reset */
+#define PCH_GBE_RX_RST          0x04000000  /* RX MAC, RX FIFO, RX DMA reset */
+
+/* TCP/IP Accelerator Control */
+/* External List Enable */
+#define PCH_GBE_EX_LIST_EN      0x00000008
+/* RX TCP/IP accelerator Disabled (Padding Enable) */
+#define PCH_GBE_RX_TCPIPACC_OFF 0x00000004
+/* TX TCP/IP accelerator and Padding Enable */
+#define PCH_GBE_TX_TCPIPACC_EN  0x00000002
+/* RX TCP/IP accelerator and Padding Enable */
+#define PCH_GBE_RX_TCPIPACC_EN  0x00000001
+
+/* External List */
+/* Interrupt Status Hold */
+/* PHY Interrupt Control */
+
+/* MAC RX Enable */
+#define PCH_GBE_MRE_MAC_RX_EN   0x00000001      /* MAC Receive Enable */
+
+/* RX Flow Control */
+/* Pause packet and Transmission Pause are enabled */
+#define PCH_GBE_FL_CTRL_EN      0x80000000
+
+/* Pause Packet Request */
+#define PCH_GBE_PS_PKT_RQ       0x80000000      /* Pause packet Request */
+
+/* RX Mode */
+/* Address Filtering Enable */
+#define PCH_GBE_ADD_FIL_EN      0x80000000
+/* Multicast Filtering Enable */
+#define PCH_GBE_MLT_FIL_EN      0x40000000
+/* Receive Almost Empty Threshold */
+#define PCH_GBE_RH_ALM_EMP_4    0x00000000      /* 4 words */
+#define PCH_GBE_RH_ALM_EMP_8    0x00004000      /* 8 words */
+#define PCH_GBE_RH_ALM_EMP_16   0x00008000      /* 16 words */
+#define PCH_GBE_RH_ALM_EMP_32   0x0000C000      /* 32 words */
+/* Receive Almost Full Threshold */
+#define PCH_GBE_RH_ALM_FULL_4   0x00000000      /* 4 words */
+#define PCH_GBE_RH_ALM_FULL_8   0x00001000      /* 8 words */
+#define PCH_GBE_RH_ALM_FULL_16  0x00002000      /* 16 words */
+#define PCH_GBE_RH_ALM_FULL_32  0x00003000      /* 32 words */
+/* RX FIFO Read Triger Threshold */
+#define PCH_GBE_RH_RD_TRG_4     0x00000000      /* 4 words */
+#define PCH_GBE_RH_RD_TRG_8     0x00000200      /* 8 words */
+#define PCH_GBE_RH_RD_TRG_16    0x00000400      /* 16 words */
+#define PCH_GBE_RH_RD_TRG_32    0x00000600      /* 32 words */
+#define PCH_GBE_RH_RD_TRG_64    0x00000800      /* 64 words */
+#define PCH_GBE_RH_RD_TRG_128   0x00000A00      /* 128 words */
+#define PCH_GBE_RH_RD_TRG_256   0x00000C00      /* 256 words */
+#define PCH_GBE_RH_RD_TRG_512   0x00000E00      /* 512 words */
+
+	/* Receive Descriptor bit definitions */
+	#define PCH_GBE_RXD_ACC_STAT_BCAST          0x00000400
+	#define PCH_GBE_RXD_ACC_STAT_MCAST          0x00000200
+	#define PCH_GBE_RXD_ACC_STAT_UCAST          0x00000100
+	#define PCH_GBE_RXD_ACC_STAT_TCPIPOK        0x000000C0
+	#define PCH_GBE_RXD_ACC_STAT_IPOK           0x00000080
+	#define PCH_GBE_RXD_ACC_STAT_TCPOK          0x00000040
+	#define PCH_GBE_RXD_ACC_STAT_IP6ERR         0x00000020
+	#define PCH_GBE_RXD_ACC_STAT_OFLIST         0x00000010
+	#define PCH_GBE_RXD_ACC_STAT_TYPEIP         0x00000008
+	#define PCH_GBE_RXD_ACC_STAT_MACL           0x00000004
+	#define PCH_GBE_RXD_ACC_STAT_PPPOE          0x00000002
+	#define PCH_GBE_RXD_ACC_STAT_VTAGT          0x00000001
+	#define PCH_GBE_RXD_GMAC_STAT_PAUSE         0x0200
+	#define PCH_GBE_RXD_GMAC_STAT_MARBR         0x0100
+	#define PCH_GBE_RXD_GMAC_STAT_MARMLT        0x0080
+	#define PCH_GBE_RXD_GMAC_STAT_MARIND        0x0040
+	#define PCH_GBE_RXD_GMAC_STAT_MARNOTMT      0x0020
+	#define PCH_GBE_RXD_GMAC_STAT_TLONG         0x0010
+	#define PCH_GBE_RXD_GMAC_STAT_TSHRT         0x0008
+	#define PCH_GBE_RXD_GMAC_STAT_NOTOCTAL      0x0004
+	#define PCH_GBE_RXD_GMAC_STAT_NBLERR        0x0002
+	#define PCH_GBE_RXD_GMAC_STAT_CRCERR        0x0001
+
+	/* Transmit Descriptor bit definitions */
+	#define PCH_GBE_TXD_CTRL_TCPIP_ACC_OFF      0x0008
+	#define PCH_GBE_TXD_CTRL_ITAG               0x0004
+	#define PCH_GBE_TXD_CTRL_ICRC               0x0002
+	#define PCH_GBE_TXD_CTRL_APAD               0x0001
+	#define PCH_GBE_TXD_WORDS_SHIFT             2
+	#define PCH_GBE_TXD_GMAC_STAT_CMPLT         0x2000
+	#define PCH_GBE_TXD_GMAC_STAT_ABT           0x1000
+	#define PCH_GBE_TXD_GMAC_STAT_EXCOL         0x0800
+	#define PCH_GBE_TXD_GMAC_STAT_SNGCOL        0x0400
+	#define PCH_GBE_TXD_GMAC_STAT_MLTCOL        0x0200
+	#define PCH_GBE_TXD_GMAC_STAT_CRSER         0x0100
+	#define PCH_GBE_TXD_GMAC_STAT_TLNG          0x0080
+	#define PCH_GBE_TXD_GMAC_STAT_TSHRT         0x0040
+	#define PCH_GBE_TXD_GMAC_STAT_LTCOL         0x0020
+	#define PCH_GBE_TXD_GMAC_STAT_TFUNDFLW      0x0010
+	#define PCH_GBE_TXD_GMAC_STAT_RTYCNT_MASK   0x000F
+
+/* TX Mode */
+#define PCH_GBE_TM_NO_RTRY     0x80000000 /* No Retransmission */
+#define PCH_GBE_TM_LONG_PKT    0x40000000 /* Long Packt TX Enable */
+#define PCH_GBE_TM_ST_AND_FD   0x20000000 /* Stare and Forward */
+#define PCH_GBE_TM_SHORT_PKT   0x10000000 /* Short Packet TX Enable */
+#define PCH_GBE_TM_LTCOL_RETX  0x08000000 /* Retransmission at Late Collision */
+/* Frame Start Threshold */
+#define PCH_GBE_TM_TH_TX_STRT_4    0x00000000    /* 4 words */
+#define PCH_GBE_TM_TH_TX_STRT_8    0x00004000    /* 8 words */
+#define PCH_GBE_TM_TH_TX_STRT_16   0x00008000    /* 16 words */
+#define PCH_GBE_TM_TH_TX_STRT_32   0x0000C000    /* 32 words */
+/* Transmit Almost Empty Threshold */
+#define PCH_GBE_TM_TH_ALM_EMP_4    0x00000000    /* 4 words */
+#define PCH_GBE_TM_TH_ALM_EMP_8    0x00000800    /* 8 words */
+#define PCH_GBE_TM_TH_ALM_EMP_16   0x00001000    /* 16 words */
+#define PCH_GBE_TM_TH_ALM_EMP_32   0x00001800    /* 32 words */
+#define PCH_GBE_TM_TH_ALM_EMP_64   0x00002000    /* 64 words */
+#define PCH_GBE_TM_TH_ALM_EMP_128  0x00002800    /* 128 words */
+#define PCH_GBE_TM_TH_ALM_EMP_256  0x00003000    /* 256 words */
+#define PCH_GBE_TM_TH_ALM_EMP_512  0x00003800    /* 512 words */
+/* Transmit Almost Full Threshold */
+#define PCH_GBE_TM_TH_ALM_FULL_4   0x00000000    /* 4 words */
+#define PCH_GBE_TM_TH_ALM_FULL_8   0x00000200    /* 8 words */
+#define PCH_GBE_TM_TH_ALM_FULL_16  0x00000400    /* 16 words */
+#define PCH_GBE_TM_TH_ALM_FULL_32  0x00000600    /* 32 words */
+
+/* RX FIFO Status */
+/* RX FIFO is almost full. */
+#define PCH_GBE_RF_ALM_FULL     0x80000000
+/* RX FIFO is almost empty. */
+#define PCH_GBE_RF_ALM_EMP      0x40000000
+/* that the data within RX FIFO has become more than RH_RD_TRG. */
+#define PCH_GBE_RF_RD_TRG       0x20000000
+/* The word count of the data existing within RX FIFO. */
+#define PCH_GBE_RF_STRWD        0x1FFE0000
+/* that frame which is currently valid/enabled is stored in RX FIFO. */
+#define PCH_GBE_RF_RCVING       0x00010000
+
+/* TX FIFO Status */
+/* TX Frame ID */
+/* TX Result */
+/* Pause Packet1-5 */
+/* MAC Address 1(A/B)- 16*/
+/* MAC Address Mask */
+#define PCH_GBE_BUSY                0x80000000
+
+/* MIIM  */
+#define PCH_GBE_MIIM_OPER_WRITE     0x04000000
+#define PCH_GBE_MIIM_OPER_READ      0x00000000
+#define PCH_GBE_MIIM_OPER_READY     0x04000000
+#define PCH_GBE_MIIM_PHY_ADDR_SHIFT 21
+#define PCH_GBE_MIIM_REG_ADDR_SHIFT 16
+
+/* RGMII Status */
+#define PCH_GBE_LINK_UP             0x80000008
+#define PCH_GBE_RXC_SPEED_MSK       0x00000006
+#define PCH_GBE_RXC_SPEED_2_5M      0x00000000    /* 2.5MHz */
+#define PCH_GBE_RXC_SPEED_25M       0x00000002    /* 25MHz  */
+#define PCH_GBE_RXC_SPEED_125M      0x00000004    /* 100MHz */
+#define PCH_GBE_DUPLEX_FULL         0x00000001
+
+/* RGMII Control */
+#define PCH_GBE_CRS_SEL             0x00000010
+#define PCH_GBE_RGMII_RATE_125M     0x00000000
+#define PCH_GBE_RGMII_RATE_25M      0x00000008
+#define PCH_GBE_RGMII_RATE_2_5M     0x0000000C
+#define PCH_GBE_RGMII_MODE_GMII     0x00000000
+#define PCH_GBE_RGMII_MODE_RGMII    0x00000002
+#define PCH_GBE_CHIP_TYPE_EXTERNAL  0x00000000
+#define PCH_GBE_CHIP_TYPE_INTERNAL  0x00000001
+
+/* DMA Control */
+#define PCH_GBE_RX_DMA_EN           0x00000002   /* Enables Receive DMA */
+#define PCH_GBE_TX_DMA_EN           0x00000001   /* Enables Transmission DMA */
+
+/* Wake On LAN Status */
+#define PCH_GBE_WLS_BR          0x00000008 /* Broadcas Address */
+#define PCH_GBE_WLS_MLT         0x00000004 /* Multicast Address */
+
+/* The Frame registered in Address Recognizer */
+#define PCH_GBE_WLS_IND         0x00000002
+#define PCH_GBE_WLS_MP          0x00000001 /* Magic packet Address */
+
+/* Wake On LAN Control */
+#define PCH_GBE_WLC_WOL_MODE    0x00010000
+#define PCH_GBE_WLC_IGN_TLONG   0x00000100
+#define PCH_GBE_WLC_IGN_TSHRT   0x00000080
+#define PCH_GBE_WLC_IGN_OCTER   0x00000040
+#define PCH_GBE_WLC_IGN_NBLER   0x00000020
+#define PCH_GBE_WLC_IGN_CRCER   0x00000010
+#define PCH_GBE_WLC_BR          0x00000008
+#define PCH_GBE_WLC_MLT         0x00000004
+#define PCH_GBE_WLC_IND         0x00000002
+#define PCH_GBE_WLC_MP          0x00000001
+
+/* Wake On LAN Address Mask */
+#define PCH_GBE_WLA_BUSY        0x80000000
+
+#endif
-- 1.6.2.5 
