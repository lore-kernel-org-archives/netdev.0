From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Subject: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI
	Express adapters...
Date: Tue, 12 Jun 2007 16:44:31 -0700
Message-ID: <20070612234431.5102.33880.stgit@localhost.localdomain>
References: <20070612234417.5102.29147.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, ayyappan.veeraiyan@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60879 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754688AbXFLXog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 19:44:36 -0400
In-Reply-To: <20070612234417.5102.29147.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the 82598 based Intel PCI Express 10GbE
adapters. This driver uses MSIX and enables multiple Rx queus, uses Packet
split in Rx side for Jumbo frame configurations, uses "adavanced
descriptors" for both Tx & Rx.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
---

 Documentation/networking/ixgbe.txt |  155 ++
 MAINTAINERS                        |   15 
 drivers/net/Kconfig                |   22 
 drivers/net/Makefile               |    1 
 drivers/net/ixgbe/Makefile         |   36 
 drivers/net/ixgbe/ixgbe.h          |  213 +++
 drivers/net/ixgbe/ixgbe_82598.c    |  555 ++++++++
 drivers/net/ixgbe/ixgbe_api.c      |  635 +++++++++
 drivers/net/ixgbe/ixgbe_api.h      |   89 +
 drivers/net/ixgbe/ixgbe_common.c   | 1725 ++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.h   |   74 +
 drivers/net/ixgbe/ixgbe_ethtool.c  |  491 +++++++
 drivers/net/ixgbe/ixgbe_main.c     | 2623 ++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_osdep.h    |   76 +
 drivers/net/ixgbe/ixgbe_param.c    |  510 +++++++
 drivers/net/ixgbe/ixgbe_phy.c      |  574 ++++++++
 drivers/net/ixgbe/ixgbe_phy.h      |   61 +
 drivers/net/ixgbe/ixgbe_type.h     | 1385 +++++++++++++++++++
 18 files changed, 9240 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
new file mode 100644
index 0000000..99db4a5
--- /dev/null
+++ b/Documentation/networking/ixgbe.txt
@@ -0,0 +1,155 @@
+Linux* Base Driver for the 10 Gigabit PCI Express Family of Adapters
+================================================================
+
+June 3, 2007
+
+
+Contents
+========
+
+- In This Release
+- Identifying Your Adapter
+- Command Line Parameters
+- Support
+
+In This Release
+===============
+
+This file describes the Linux* Base Driver for the 10 Gigabit PCI Express
+Family of Adapters.  This driver supports the 2.6.x kernel. This driver
+includes support for Itanium(R)2-based systems.
+
+The following features are now available in supported kernels:
+ - Native VLANs
+ - Channel Bonding (teaming)
+ - SNMP
+
+Channel Bonding documentation can be found in the Linux kernel source:
+/Documentation/networking/bonding.txt
+
+Instructions on updating ethtool can be found in the section "Additional
+Configurations" later in this document.
+
+
+Identifying Your Adapter
+========================
+
+The following Intel network adapters are compatible with the drivers in this
+release:
+
+Controller  Adapter Name                 Physical Layer
+----------  ------------                 --------------
+82598       Intel(R) 10GbE-LR/LRM/SR
+            Server Adapters              10G Base -SR (850 nm optical fiber)
+                                         10G Base -LRM (850 nm optical fiber)
+                                         10G Base -LR (1310 nm optical fiber)
+
+For more information on how to identify your adapter, go to the Adapter &
+Driver ID Guide at:
+
+    http://support.intel.com/support/network/sb/CS-012904.htm
+
+For the latest Intel network drivers for Linux, refer to the following
+website.  In the search field, enter your adapter name or type, or use the
+networking link on the left to search for your adapter:
+
+    http://downloadfinder.intel.com/scripts-df/support_intel.asp
+
+Command Line Parameters
+=======================
+
+If the driver is built as a module, the  following optional parameters are
+used by entering them on the command line with the modprobe command using
+this syntax:
+
+     modprobe ixgbe [<option>=<VAL1>,<VAL2>,...]
+
+For example, with two PRO/10GbE PCI Express adapters, entering:
+
+     modprobe ixgbe TxDescriptors=80,128
+
+loads the ixgbe driver with 80 TX resources for the first adapter and 128 TX
+resources for the second adapter.
+
+The default value for each parameter is generally the recommended setting,
+unless otherwise noted.
+
+RxDescriptors
+Valid Range: 64-4096
+Default Value: 1024
+    This value is the number of receive descriptors allocated by the driver.
+    Increasing this value allows the driver to buffer more incoming packets.
+    Each descriptor is 16 bytes.  A receive buffer is also allocated for
+    each descriptor and can be either 1522 or 4096 bytes,
+    depending on the MTU setting.  When the MTU size is 1500 or less, the
+    receive buffer size is 1522 bytes. When the MTU is greater than 1500 the
+    receive buffer size will be either 4096 bytes.  The
+    maximum MTU size is 16110.
+
+TxDescriptors
+Valid Range: 64-4096
+Default Value: 1024
+    This value is the number of transmit descriptors allocated by the driver.
+    Increasing this value allows the driver to queue more transmits.  Each
+    descriptor is 16 bytes.
+
+RxQueues
+Valid Range: 1-8
+Default Value: 8
+    Rx Queues count.
+   
+RxFCHighThresh
+Valid Range: 1,536 - 262,136 (0x600 - 0x3FFF8, 8 byte granularity)
+Default Value: 196,608 (0x30000)
+    Receive Flow control high threshold (when we send a pause frame)
+
+RxFCLowThresh
+Valid Range: 64 - 262,136 (0x40 - 0x3FFF8, 8 byte granularity)
+             *  must be less than high threshold by at least 8 bytes
+Default Value:  163,840 (0x28000)
+Receive Flow control low threshold (when we send a resume frame)
+
+InterruptType
+Valid Range: 0-2 0 = Legacy Int, 1 = MSI and 2 = MSIX
+Default Value: 2
+    Interrupt type
+
+FCReqTimeout
+Valid Range: 1 - 65535
+Default Value:  65535 (0xffff) (will send an xon if we recover)
+    Flow control request timeout (how long to pause the link partner's tx)
+    
+InterruptThrottleRate
+Valid Range: 100-100000 (0=off, 1=dynamic)
+Default Value: 
+    Interrupt Throttle Rate (interrupts/sec)
+
+FlowControl
+Valid Range: 0-3
+0 - No Flow Control
+1 - Rx only, respond to PAUSE frames but do not generate them
+2 - Tx only, generate PAUSE frames but ignore them on receive
+3 - Full Flow Control Support
+Default Value: 1 - Rx only 
+    User Specified Flow Control Override
+
+XsumRX
+Valid Range: 0-1
+Default Value: 1
+    A value of '1' indicates that the driver should enable IP checksum
+    offload for received packets (both UDP and TCP) to the adapter hardware.
+
+Support
+=======
+
+For general information, go to the Intel support website at:
+
+    http://support.intel.com
+
+or the Intel Wired Networking project hosted by Sourceforge at:
+
+    http://sourceforge.net/projects/e1000
+
+If an issue is identified with the released source code on the supported
+kernel with a supported adapter, email the specific information related
+to the issue to e1000-devel@lists.sf.net
diff --git a/MAINTAINERS b/MAINTAINERS
index 4c715a7..517da6e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1945,6 +1945,21 @@ L:	e1000-devel@lists.sourceforge.net
 W:	http://sourceforge.net/projects/e1000/
 S:	Supported
 
+INTEL PRO/10GbE PCI Express SUPPORT
+P:	Jeff Kirsher
+M:	jeffrey.t.kirsher@intel.com
+P:	Ayyappan Veeraiyan
+M:	ayyappan.veeraiyan@intel.com
+P:	John Ronciak
+M:	john.ronciak@intel.com
+P:	Jesse Brandeburg
+M:	jesse.brandeburg@intel.com
+P:	Auke Kok
+M:	auke-jan.h.kok@intel.com
+L:	e1000-devel@lists.sourceforge.net
+W:	http://sourceforge.net/projects/e1000/
+S:	Supported
+
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
 P:	Yi Zhu
 M:	yi.zhu@intel.com
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7d57f4a..b616e64 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2445,6 +2445,28 @@ config IXGB_NAPI
 
 	  If in doubt, say N.
 
+config IXGBE
+	tristate "Intel(R) PRO/10GbE PCI Express adapters support"
+	depends on PCI
+	---help---
+	  This driver supports Intel(R) PRO/10GbE PCI Express family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in 
+	  <file:Documentation/networking/ixgbe.txt>.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>.  The module
+	  will be called ixgbe.
+
 config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a77affa..427c8b6 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IXGB) += ixgb/
+obj-$(CONFIG_IXGBE) += ixgbe/
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_EHEA) += ehea/
diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
new file mode 100644
index 0000000..e06d5a7
--- /dev/null
+++ b/drivers/net/ixgbe/Makefile
@@ -0,0 +1,36 @@
+################################################################################
+#
+# Intel PRO/10GbE PCI Express Linux driver
+# Copyright(c) 1999 - 2007 Intel Corporation.
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+# Contact Information:
+# Linux NICS <linux.nics@intel.com>
+# e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+# Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+#
+################################################################################
+
+#
+# Makefile for the Intel(R) PRO/10GbE PCI Express ethernet driver
+#
+
+obj-$(CONFIG_IXGBE) += ixgbe.o
+
+ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_api.o ixgbe_ethtool.o \
+              ixgbe_param.o ixgbe_82598.o ixgbe_phy.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
new file mode 100644
index 0000000..8f8ec58
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -0,0 +1,213 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_H_
+#define _IXGBE_H_
+
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/vmalloc.h>
+
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+
+#include "ixgbe_api.h"
+
+#define IXGBE_ERR(args...) printk(KERN_ERR "ixgbe: " args)
+
+#define PFX "ixgbe: "
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
+	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
+		__FUNCTION__ , ## args))
+
+/* TX/RX descriptor defines */
+#define IXGBE_DEFAULT_TXD			   1024
+#define IXGBE_MAX_TXD				   4096
+#define IXGBE_MIN_TXD				     64
+
+#define IXGBE_DEFAULT_RXD			   1024
+#define IXGBE_MAX_RXD				   4096
+#define IXGBE_MIN_RXD				     64
+
+#define IXGBE_DEFAULT_RXQ			   8
+#define IXGBE_MAX_RXQ				   8
+#define IXGBE_MIN_RXQ				   1
+
+#define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
+
+/* Used for packet split */
+#define IXGBE_RXBUFFER_64    64
+#define IXGBE_RXBUFFER_128   128
+#define IXGBE_RXBUFFER_256   256
+/* Supported Rx Buffer Sizes */
+#define IXGBE_RXBUFFER_2048  2048
+
+#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
+
+/* How many Tx Descriptors do we need to call netif_wake_queue? */
+#define IXGBE_TX_QUEUE_WAKE 16
+
+/* How many Rx Buffers do we bundle into one write to the hardware ? */
+#define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
+
+#define IXGBE_TX_FLAGS_CSUM		0x00000001
+#define IXGBE_TX_FLAGS_VLAN		0x00000002
+#define IXGBE_TX_FLAGS_TSO		0x00000004
+#define IXGBE_TX_FLAGS_IPV4		0x00000008
+#define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
+#define IXGBE_TX_FLAGS_VLAN_SHIFT	16
+
+/* wrapper around a pointer to a socket buffer,
+ * so a DMA handle can be stored along with the buffer */
+struct ixgbe_tx_buffer {
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	unsigned long time_stamp;
+	u16 length;
+	u16 next_to_watch;
+};
+
+struct ixgbe_rx_buffer {
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	struct page *page;
+	dma_addr_t page_dma;
+};
+
+struct ixgbe_queue_stats {
+	u64 packets;
+	u64 bytes;
+};
+
+struct ixgbe_ring {
+	struct ixgbe_adapter *adapter;	/* backlink */
+	void *desc;			/* descriptor ring memory */
+	dma_addr_t dma;			/* phys. address of descriptor ring */
+	unsigned int size;		/* length in bytes */
+	unsigned int count;		/* amount of descriptors */
+	unsigned int next_to_use;
+	unsigned int next_to_clean;
+
+	union {
+		struct ixgbe_tx_buffer *tx_buffer_info;
+		struct ixgbe_rx_buffer *rx_buffer_info;
+	};
+
+	u16 head;
+	u16 tail;
+
+	union {
+		/* To protect race between sender and clean_tx_irq */
+		spinlock_t tx_lock;
+		struct net_device netdev;
+	};
+
+	struct ixgbe_queue_stats stats;
+
+	u32 eims_value;
+	u32 itr_val;
+	u16 itr_range;
+	u16 itr_register;
+
+	char name[IFNAMSIZ + 5];
+};
+
+
+#define IXGBE_DESC_UNUSED(R) \
+	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
+	(R)->next_to_clean - (R)->next_to_use - 1)
+
+#define IXGBE_RX_DESC_ADV(R, i)	    \
+	(&(((union ixgbe_adv_rx_desc *)((R).desc))[i]))
+#define IXGBE_TX_DESC_ADV(R, i)	    \
+	(&(((union ixgbe_adv_tx_desc *)((R).desc))[i]))
+#define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
+	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
+
+#define IXGBE_MAX_JUMBO_FRAME_SIZE	16128
+
+/* board specific private data structure */
+struct ixgbe_adapter {
+	struct timer_list watchdog_timer;
+	struct vlan_group *vlgrp;
+	u16 bd_number;
+	u16 rx_buf_len;
+	u32 part_num;
+	u32 link_speed;
+	unsigned long io_base;
+	atomic_t irq_sem;
+	struct work_struct reset_task;
+
+	/* TX */
+	struct ixgbe_ring *tx_ring;	/* One per active queue */
+	u64 restart_queue;
+	u64 lsc_int;
+	u32 txd_cmd;
+	u64 hw_tso_ctxt;
+	u64 hw_tso6_ctxt;
+	u32 tx_timeout_count;
+	boolean_t detect_tx_hung;
+
+	/* RX */
+	struct ixgbe_ring *rx_ring;	/* One per active queue */
+	u64 hw_csum_tx_good;
+	u64 hw_csum_rx_error;
+	u64 hw_csum_rx_good;
+	u64 non_eop_descs;
+	int num_tx_queues;
+	int num_rx_queues;
+	struct msix_entry *msix_entries;
+
+	u64 rx_hdr_split;
+	u32 alloc_rx_page_failed;
+	u32 alloc_rx_buff_failed;
+	struct {
+		unsigned int rx_csum_enabled	:1;
+		unsigned int msi_capable	:1;
+		unsigned int msi_enabled	:1;
+		unsigned int msix_capable	:1;
+		unsigned int msix_enabled	:1;
+		unsigned int imir_enabled	:1;
+		unsigned int in_netpoll		:1;
+	} flags;
+	u32 max_frame_size;	/* Maximum frame size supported */
+	u32 eitr;		/* Interrupt Throttle Rate */
+
+	/* OS defined structs */
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct net_device_stats net_stats;
+
+	/* structs defined in ixgbe_hw.h */
+	struct ixgbe_hw hw;
+	u16 msg_enable;
+	struct ixgbe_hw_stats stats;
+	char lsc_name[IFNAMSIZ + 5];
+};
+#endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
new file mode 100644
index 0000000..d03866f
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -0,0 +1,555 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe_type.h"
+#include "ixgbe_api.h"
+#include "ixgbe_common.h"
+#include "ixgbe_phy.h"
+
+#define IXGBE_82598_MAX_TX_QUEUES 32
+#define IXGBE_82598_MAX_RX_QUEUES 64
+#define IXGBE_82598_RAR_ENTRIES   16
+
+s32 ixgbe_82598_init_shared_code(struct ixgbe_hw *hw);
+s32 ixgbe_82598_assign_func_pointers(struct ixgbe_hw *hw);
+s32 ixgbe_82598_link_get_settings(struct ixgbe_hw *hw,
+				  u32 *speed, boolean_t *autoneg);
+enum ixgbe_media_type ixgbe_82598_adapter_get_media_type(struct ixgbe_hw *hw);
+u32 ixgbe_82598_adapter_get_num_of_tx_queues(struct ixgbe_hw *hw);
+u32 ixgbe_82598_adapter_get_num_of_rx_queues(struct ixgbe_hw *hw);
+s32 ixgbe_82598_mac_link_setup(struct ixgbe_hw *hw);
+s32 ixgbe_82598_mac_link_check(struct ixgbe_hw *hw,
+			       u32 *speed, boolean_t *link_up);
+s32 ixgbe_82598_mac_link_setup_speed(struct ixgbe_hw *hw,
+				     u32 speed,
+				     boolean_t autoneg,
+				     boolean_t autoneg_wait_to_complete);
+s32 ixgbe_82598_link_setup_copper(struct ixgbe_hw *hw);
+s32 ixgbe_82598_link_check_copper(struct ixgbe_hw *hw,
+				  u32 *speed, boolean_t *link_up);
+s32 ixgbe_82598_link_setup_speed_copper(struct ixgbe_hw *hw,
+					u32 speed,
+					boolean_t autoneg,
+					boolean_t autoneg_wait_to_complete);
+s32 ixgbe_82598_hw_reset(struct ixgbe_hw *hw);
+u32 ixgbe_82598_get_num_rx_addrs(struct ixgbe_hw *hw);
+
+/**
+ *  ixgbe_init_shared_code_82598 - Inits func ptrs and MAC type
+ *  @hw: pointer to hardware structure
+ *
+ *  Initialize the shared code for 82598. This will assign function pointers
+ *  and assign the MAC type.  Does not touch the hardware.
+ **/
+s32 ixgbe_82598_init_shared_code(struct ixgbe_hw *hw)
+{
+	u32 reg;
+
+	/* Set MAC type */
+	hw->mac_type = ixgbe_mac_82598EB;
+
+	/* Assign function pointers */
+	ixgbe_82598_assign_func_pointers(hw);
+
+	/*
+	 * Read the AUTOC register and store the link type. This allows it to
+	 * be changed afterwards
+	 */
+	reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	hw->link_attach_type = (reg & IXGBE_AUTOC_LMS_ATTACH_TYPE);
+	hw->link_mode_select = (reg & IXGBE_AUTOC_LMS_MASK);
+	hw->autoneg = TRUE;
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_82598_assign_func_pointers - Assigns 82598-specific funtion pointers
+ *  @hw: pointer to hardware structure
+ *
+ *  Note - Generic function pointers have already been assigned, so the
+ *  function pointers set here are only for 82598-specific functions.
+ **/
+s32 ixgbe_82598_assign_func_pointers(struct ixgbe_hw *hw)
+{
+
+	hw->func_table.ixgbe_func_adapter_get_media_type =
+	    &ixgbe_82598_adapter_get_media_type;
+	hw->func_table.ixgbe_func_adapter_get_num_of_tx_queues =
+	    &ixgbe_82598_adapter_get_num_of_tx_queues;
+	hw->func_table.ixgbe_func_adapter_get_num_of_rx_queues =
+	    &ixgbe_82598_adapter_get_num_of_rx_queues;
+	hw->func_table.ixgbe_func_link_get_settings =
+	    &ixgbe_82598_link_get_settings;
+	hw->func_table.ixgbe_func_hw_reset = &ixgbe_82598_hw_reset;
+
+	hw->func_table.ixgbe_func_get_num_rx_addrs =
+	    &ixgbe_82598_get_num_rx_addrs;
+
+	/* Link */
+	if (ixgbe_adapter_get_media_type(hw) == ixgbe_media_type_copper) {
+		hw->func_table.ixgbe_func_link_setup =
+		    &ixgbe_82598_link_setup_copper;
+		hw->func_table.ixgbe_func_link_check =
+		    &ixgbe_82598_link_check_copper;
+		hw->func_table.ixgbe_func_link_setup_speed =
+		    &ixgbe_82598_link_setup_speed_copper;
+	} else {
+		hw->func_table.ixgbe_func_link_setup =
+		    &ixgbe_82598_mac_link_setup;
+		hw->func_table.ixgbe_func_link_check =
+		    &ixgbe_82598_mac_link_check;
+		hw->func_table.ixgbe_func_link_setup_speed =
+		    &ixgbe_82598_mac_link_setup_speed;
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_82598_set_default_link_settings - Determines default link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines the default link settings by reading the AUTOC register.
+ **/
+s32 ixgbe_82598_link_get_settings(struct ixgbe_hw *hw, u32 *speed,
+				  boolean_t *autoneg)
+{
+	s32 status = IXGBE_SUCCESS;
+	s32 autoc_reg;
+
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc_reg &= ~IXGBE_AUTOC_LMS_ATTACH_TYPE;
+	autoc_reg &= ~IXGBE_AUTOC_LMS_MASK;
+	autoc_reg |= hw->link_attach_type;
+	autoc_reg |= hw->link_mode_select;
+
+	switch (autoc_reg & IXGBE_AUTOC_LMS_MASK) {
+	case IXGBE_AUTOC_LMS_1G_LINK_NO_AN:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		break;
+
+	case IXGBE_AUTOC_LMS_10G_LINK_NO_AN:
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+		break;
+
+	case IXGBE_AUTOC_LMS_1G_AN:
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+		break;
+
+	case IXGBE_AUTOC_LMS_KX4_AN:
+	case IXGBE_AUTOC_LMS_KX4_AN_1G_AN:
+		*speed = IXGBE_LINK_SPEED_UNKNOWN;
+		if (autoc_reg & IXGBE_AUTOC_KX4_SUPP) {
+			*speed |= IXGBE_LINK_SPEED_10GB_FULL;
+		}
+		if (autoc_reg & IXGBE_AUTOC_KX_SUPP) {
+			*speed |= IXGBE_LINK_SPEED_1GB_FULL;
+		}
+		break;
+
+	default:
+		status = IXGBE_ERR_LINK_SETUP;
+		break;
+	}
+
+	if (autoc_reg & IXGBE_AUTOC_FLU)
+		*autoneg = FALSE;
+	else
+		*autoneg = TRUE;
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_adapter_get_media_type - Determines media type
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the media type (fiber, copper, backplane)
+ **/
+enum ixgbe_media_type ixgbe_82598_adapter_get_media_type(struct ixgbe_hw *hw)
+{
+	enum ixgbe_media_type media_type;
+
+	/* Media type for I82598 is based on device ID */
+	switch (hw->device_id) {
+	case IXGBE_DEV_ID_82598:
+		/* Default device ID is mezzanine card KX/KX4 */
+		media_type = ixgbe_media_type_backplane;
+		break;
+	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+		media_type = ixgbe_media_type_fiber;
+		break;
+	default:
+		media_type = ixgbe_media_type_unknown;
+		break;
+	}
+
+	return media_type;
+}
+
+/**
+ *  ixgbe_82598_adapter_get_num_of_tx_queues - Get number of TX queues
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the number of transmit queues for the given adapter.
+ **/
+u32 ixgbe_82598_adapter_get_num_of_tx_queues(struct ixgbe_hw *hw)
+{
+	return IXGBE_82598_MAX_TX_QUEUES;
+}
+
+/**
+ *  ixgbe_82598_adapter_get_num_of_rx_queues - Get number of RX queues
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the number of receive queues for the given adapter.
+ **/
+u32 ixgbe_82598_adapter_get_num_of_rx_queues(struct ixgbe_hw *hw)
+{
+	return IXGBE_82598_MAX_RX_QUEUES;
+}
+
+/**
+ *  ixgbe_82598_mac_link_setup - Configures MAC link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Configures link settings based on values in the ixgbe_hw struct.
+ *  Restarts the link.  Performs autonegotiation if needed.
+ **/
+s32 ixgbe_82598_mac_link_setup(struct ixgbe_hw *hw)
+{
+	u32 autoc_reg;
+	u32 links_reg;
+	u32 i;
+	s32 status = IXGBE_SUCCESS;
+
+	/* Set up link based on AUTOC settings */
+	autoc_reg = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc_reg &= ~IXGBE_AUTOC_LMS_ATTACH_TYPE;
+	autoc_reg &= ~IXGBE_AUTOC_LMS_MASK;
+	autoc_reg |= hw->link_attach_type;
+	autoc_reg |= hw->link_mode_select;
+
+	if (hw->autoneg)
+		autoc_reg &= ~IXGBE_AUTOC_FLU;
+	else
+		autoc_reg |= IXGBE_AUTOC_FLU;
+
+	/* Restart link */
+	autoc_reg |= IXGBE_AUTOC_AN_RESTART;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+
+	/* Only poll for autoneg to complete if specified to do so */
+	if (hw->autoneg_wait_to_complete) {
+		if (hw->link_mode_select == IXGBE_AUTOC_LMS_KX4_AN ||
+		    hw->link_mode_select == IXGBE_AUTOC_LMS_KX4_AN_1G_AN) {
+			for (i = 0; i < IXGBE_AUTO_NEG_TIME; i++) {
+				links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+				if (links_reg & IXGBE_LINKS_KX_AN_COMP)
+					break;
+				msleep(100);
+			}
+			if (!(links_reg & IXGBE_LINKS_KX_AN_COMP)) {
+				status = IXGBE_ERR_AUTONEG_NOT_COMPLETE;
+				DEBUGOUT("Autonegotiation did not complete.\n");
+			}
+		}
+	}
+
+	/* Add delay to filter out noises during initial link setup */
+	msleep(50);
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_mac_link_check - Get link/speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the links register to determine if link is up and the current speed
+ **/
+s32 ixgbe_82598_mac_link_check(struct ixgbe_hw *hw, u32 *speed,
+			       boolean_t *link_up)
+{
+	u32 links_reg;
+
+	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+
+	if (links_reg & IXGBE_LINKS_UP)
+		*link_up = TRUE;
+	else
+		*link_up = FALSE;
+
+	if (links_reg & IXGBE_LINKS_SPEED)
+		*speed = IXGBE_LINK_SPEED_10GB_FULL;
+	else
+		*speed = IXGBE_LINK_SPEED_1GB_FULL;
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_82598_mac_link_setup_speed - Set MAC link speed
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: TRUE if autonegotiation enabled
+ *
+ *  Set the link speed in the AUTOC register and restarts link.
+ **/
+s32 ixgbe_82598_mac_link_setup_speed(struct ixgbe_hw *hw,
+				     u32 speed, boolean_t autoneg,
+				     boolean_t autoneg_wait_to_complete)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	/* If speed is 10G, then check for CX4 or XAUI. */
+	if ((speed == IXGBE_LINK_SPEED_10GB_FULL) &&
+	    (!(hw->link_attach_type & IXGBE_AUTOC_10G_KX4)))
+		hw->link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
+	else if ((speed == IXGBE_LINK_SPEED_1GB_FULL) && (!autoneg))
+		hw->link_mode_select = IXGBE_AUTOC_LMS_1G_LINK_NO_AN;
+	else if (autoneg) {
+		/* BX mode - Autonegotiate 1G */
+		if (!(hw->link_attach_type & IXGBE_AUTOC_1G_PMA_PMD))
+			hw->link_mode_select = IXGBE_AUTOC_LMS_1G_AN;
+		else		/* KX/KX4 mode */
+			hw->link_mode_select = IXGBE_AUTOC_LMS_KX4_AN_1G_AN;
+	} else {
+		status = IXGBE_ERR_LINK_SETUP;
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		/* Store the new values for autoneg/forced */
+		hw->autoneg = autoneg;
+		hw->autoneg_wait_to_complete = autoneg_wait_to_complete;
+
+		/*
+		 * Setup and restart the link based on the new values in
+		 * ixgbe_hw This will write the AUTOC register based on the new
+		 * stored values
+		 */
+		ixgbe_82598_mac_link_setup(hw);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_link_setup_copper - Setup copper link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Configures link settings based on values in the ixgbe_hw struct.
+ *  Restarts the link.  Performs autonegotiation if needed.  Restart
+ *  phy and wait for autonegotiate to finish.  Then synchronize the
+ *  MAC and PHY.
+ **/
+s32 ixgbe_82598_link_setup_copper(struct ixgbe_hw *hw)
+{
+	s32 status;
+	u32 speed = 0;
+	boolean_t link_up = FALSE;
+
+	/* Set up MAC */
+	ixgbe_82598_mac_link_setup(hw);
+
+	/* Restart autonegotiation on PHY */
+	status = ixgbe_phy_link_setup(hw);
+
+	/* Synchronize MAC to PHY speed */
+	if (status == IXGBE_SUCCESS)
+		status = ixgbe_link_check(hw, &speed, &link_up);
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_link_check_copper - Syncs MAC & PHY link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the mac link, phy link, and synchronizes the MAC to PHY.
+ **/
+s32 ixgbe_82598_link_check_copper(struct ixgbe_hw *hw, u32 *speed,
+				  boolean_t *link_up)
+{
+	s32 status;
+	u32 phy_speed = 0;
+	boolean_t phy_link = FALSE;
+
+	/* This is the speed and link the MAC is set at */
+	ixgbe_82598_mac_link_check(hw, speed, link_up);
+
+	/*
+	 * Check current speed and link status of the PHY register.
+	 * This is a vendor specific register and may have to
+	 * be changed for other copper PHYs.
+	 */
+	status = ixgbe_phy_link_check(hw, &phy_speed, &phy_link);
+
+	if ((status == IXGBE_SUCCESS) && (phy_link)) {
+		/*
+		 * Check current link status of the MACs link's register
+		 * matches that of the speed in the PHY register
+		 */
+		if (*speed != phy_speed) {
+			/*
+			 * The copper PHY requires 82598 attach type to be XAUI
+			 * for 10G and BX for 1G
+			 */
+			hw->link_attach_type =
+			    (IXGBE_AUTOC_10G_XAUI | IXGBE_AUTOC_1G_BX);
+
+			/* Synchronize the MAC speed to the PHY speed */
+			status = ixgbe_82598_mac_link_setup_speed(hw, phy_speed,
+								  TRUE, TRUE);
+			if (status == IXGBE_SUCCESS)
+				ixgbe_82598_mac_link_check(hw, speed, link_up);
+			else
+				status = IXGBE_ERR_LINK_SETUP;
+		}
+	} else {
+		*link_up = phy_link;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_link_setup_speed_copper - Set the PHY autoneg advertised field
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: TRUE if autonegotiation enabled
+ *
+ *  Sets the link speed in the AUTOC register in the MAC and restarts link.
+ **/
+s32 ixgbe_82598_link_setup_speed_copper(struct ixgbe_hw *hw,
+					u32 speed,
+					boolean_t autoneg,
+					boolean_t autoneg_wait_to_complete)
+{
+	s32 status;
+	boolean_t link_up = 0;
+
+	/* Setup the PHY according to input speed */
+	status = ixgbe_phy_link_setup_speed(hw, speed, autoneg,
+					    autoneg_wait_to_complete);
+
+	/* Synchronize MAC to PHY speed */
+	if (status == IXGBE_SUCCESS)
+		status = ixgbe_link_check(hw, &speed, &link_up);
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_hw_reset - Performs hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  Resets the hardware by reseting the transmit and receive units, masks and
+ *  clears all interrupts, performing a PHY reset, and performing a link (MAC)
+ *  reset.
+ **/
+s32 ixgbe_82598_hw_reset(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_SUCCESS;
+	u32 ctrl;
+	u32 gheccr;
+	u32 i;
+	u32 autoc;
+
+	/* Call adapter stop to disable tx/rx and clear interrupts */
+	ixgbe_adapter_stop(hw);
+
+	/* Reset PHY */
+	ixgbe_phy_reset(hw);
+
+	/*
+	 * Prevent the PCI-E bus from from hanging by disabling PCI-E master
+	 * access and verify no pending requests before reset
+	 */
+	if (ixgbe_pcie_master_disable(hw) != IXGBE_SUCCESS) {
+		status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+		DEBUGOUT("PCI-E Master disable polling has failed.\n");
+	}
+
+	/*
+	 * Issue global reset to the MAC.  This needs to be a SW reset.
+	 * If link reset is used, it might reset the MAC when mng is using it
+	 */
+	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, (ctrl | IXGBE_CTRL_RST));
+	IXGBE_WRITE_FLUSH(hw);
+
+	/* Poll for reset bit to self-clear indicating reset is complete */
+	for (i = 0; i < 10; i++) {
+		udelay(1);
+		ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+		if (!(ctrl & IXGBE_CTRL_RST))
+			break;
+	}
+	if (ctrl & IXGBE_CTRL_RST) {
+		status = IXGBE_ERR_RESET_FAILED;
+		DEBUGOUT("Reset polling failed to complete.\n");
+	}
+
+	msleep(50);
+
+	gheccr = IXGBE_READ_REG(hw, IXGBE_GHECCR);
+	gheccr &= ~((1 << 21) | (1 << 18) | (1 << 9) | (1 << 6));
+	IXGBE_WRITE_REG(hw, IXGBE_GHECCR, gheccr);
+
+	/*
+	 * AUTOC register which stores attach type gets cleared
+	 * and reloaded from EEPROM after reset. We need to restore
+	 * our stored value from init in case SW changed the attach
+	 * type or speed.
+	 */
+	autoc = IXGBE_READ_REG(hw, IXGBE_AUTOC);
+	autoc &= ~(IXGBE_AUTOC_LMS_ATTACH_TYPE);
+	autoc &= ~(IXGBE_AUTOC_LMS_MASK);
+	autoc |= hw->link_attach_type;
+	autoc |= hw->link_mode_select;
+	IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc);
+
+	/* Store the permanent mac address */
+	ixgbe_adapter_get_mac_addr(hw, hw->perm_mac_addr);
+
+	return status;
+}
+
+/**
+ *  ixgbe_82598_get_num_rx_addrs - Get RX address registers
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the of RAR entries for the given adapter.
+ **/
+u32 ixgbe_82598_get_num_rx_addrs(struct ixgbe_hw *hw)
+{
+	return IXGBE_82598_RAR_ENTRIES;
+}
diff --git a/drivers/net/ixgbe/ixgbe_api.c b/drivers/net/ixgbe/ixgbe_api.c
new file mode 100644
index 0000000..c1e1d4e
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_api.c
@@ -0,0 +1,635 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe_api.h"
+#include "ixgbe_common.h"
+
+extern s32 ixgbe_82598_init_shared_code(struct ixgbe_hw *hw);
+extern s32 ixgbe_phy_init_shared_code(struct ixgbe_hw *hw);
+
+/**
+ *  ixgbe_init_shared_code - Initialize the shared code
+ *  @hw: pointer to hardware structure
+ *
+ *  This will assign function pointers and assign the MAC type and PHY code.
+ *  Does not touch the hardware. This function must be called prior to any
+ *  other function in the shared code. The ixgbe_hw structure should be
+ *  memset to 0 prior to calling this function.  The following fields in
+ *  hw structure should be filled in prior to calling this function:
+ *  hw_addr, back, device_id, vendor_id, subsystem_id, subsystem_vendor_id,
+ *  and revision_id
+ **/
+s32 ixgbe_init_shared_code(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_DEVICE_NOT_SUPPORTED;
+
+	/*
+	 * Assign generic function pointers before entering adapter-specific
+	 * init
+	 */
+	ixgbe_generic_assign_func_pointers(hw);
+
+	if (hw->vendor_id == IXGBE_INTEL_VENDOR_ID) {
+		switch (hw->device_id) {
+		case IXGBE_DEV_ID_82598:
+		case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
+		case IXGBE_DEV_ID_82598AF_DUAL_PORT:
+			status = ixgbe_82598_init_shared_code(hw);
+			status = ixgbe_phy_init_shared_code(hw);
+			break;
+		default:
+			status = IXGBE_ERR_DEVICE_NOT_SUPPORTED;
+			break;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_hw_init - Initialize the hardware
+ *  @hw: pointer to hardware structure
+ *
+ *  Initialize the hardware by resetting and then starting the hardware
+ **/
+s32 ixgbe_hw_init(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_hw_init, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_hw_reset - Performs a hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  Resets the hardware by resetting the transmit and receive units, masks and
+ *  clears all interrupts, performs a PHY reset, and performs a MAC reset
+ **/
+s32 ixgbe_hw_reset(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_hw_reset, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_hw_start - Prepares hardware for TX/TX
+ *  @hw: pointer to hardware structure
+ *
+ *  Starts the hardware by filling the bus info structure and media type,
+ *  clears all on chip counters, initializes receive address registers,
+ *  multicast table, VLAN filter table, calls routine to setup link and
+ *  flow control settings, and leaves transmit and receive units disabled
+ *  and uninitialized.
+ **/
+s32 ixgbe_hw_start(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_hw_start, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_hw_clear_cntrs - Clear hardware counters
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears all hardware statistics counters by reading them from the hardware
+ *  Statistics counters are clear on read.
+ **/
+s32 ixgbe_hw_clear_cntrs(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_hw_clear_cntrs, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_adapter_get_media_type - Get media type
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the media type (fiber, copper, backplane)
+ **/
+enum ixgbe_media_type ixgbe_adapter_get_media_type(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_get_media_type, (hw),
+			       ixgbe_media_type_unknown);
+}
+
+/**
+ *  ixgbe_adapter_get_mac_addr - Get MAC address
+ *  @hw: pointer to hardware structure
+ *  @mac_addr: Adapter MAC address
+ *
+ *  Reads the adapter's MAC address from the first Receive Address Register
+ *  (RAR0) A reset of the adapter must have been performed prior to calling this
+ *  function in order for the MAC address to have been loaded from the EEPROM
+ *  into RAR0
+ **/
+s32 ixgbe_adapter_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_get_mac_addr,
+			       (hw, mac_addr), IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_adapter_determine_bus_info - Set PCI bus info
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the PCI bus info (speed, width, type) within the ixgbe_hw structure
+ **/
+s32 ixgbe_adapter_determine_bus_info(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_determine_bus_info, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_adapter_get_num_of_tx_queues - Get TX queues
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the number of transmit queues for the given adapter.
+ **/
+u32 ixgbe_adapter_get_num_of_tx_queues(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_get_num_of_tx_queues,
+			       (hw), 0);
+}
+
+/**
+ *  ixgbe_adapter_get_num_of_rx_queues - Get RX queues
+ *  @hw: pointer to hardware structure
+ *
+ *  Returns the number of receive queues for the given adapter.
+ **/
+u32 ixgbe_adapter_get_num_of_rx_queues(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_get_num_of_rx_queues,
+			       (hw), 0);
+}
+
+/**
+ *  ixgbe_adapter_stop - Disable TX/TX units
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the adapter_stopped flag within ixgbe_hw struct. Clears interrupts,
+ *  disables transmit and receive units. The adapter_stopped flag is used by
+ *  the shared code and drivers to determine if the adapter is in a stopped
+ *  state and should not touch the hardware.
+ **/
+s32 ixgbe_adapter_stop(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_adapter_stop, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_phy_identify - Get PHY type
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines the physical layer module found on the current adapter.
+ **/
+s32 ixgbe_phy_identify(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_phy_identify,
+					 (hw), IXGBE_NOT_IMPLEMENTED);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_phy_reset - Perform a PHY reset
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_phy_reset(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		if (ixgbe_phy_identify(hw) != IXGBE_SUCCESS) {
+			status = IXGBE_ERR_PHY;
+		}
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_phy_reset,
+					 (hw), IXGBE_NOT_IMPLEMENTED);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_phy_read_reg - Read PHY register
+ *  @hw: pointer to hardware structure
+ *  @reg_addr: 32 bit address of PHY register to read
+ *  @phy_data: Pointer to read data from PHY register
+ *
+ *  Reads a value from a specified PHY register
+ **/
+s32 ixgbe_phy_read_reg(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type,
+		       u16 *phy_data)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		if (ixgbe_phy_identify(hw) != IXGBE_SUCCESS) {
+			status = IXGBE_ERR_PHY;
+		}
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_phy_read_reg,
+					 (hw, reg_addr, device_type, phy_data),
+					 IXGBE_NOT_IMPLEMENTED);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_phy_write_reg - Write PHY register
+ *  @hw: pointer to hardware structure
+ *  @reg_addr: 32 bit PHY register to write
+ *  @phy_data: Data to write to the PHY register
+ *
+ *  Writes a value to specified PHY register
+ **/
+s32 ixgbe_phy_write_reg(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type,
+			u16 phy_data)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		if (ixgbe_phy_identify(hw) != IXGBE_SUCCESS) {
+			status = IXGBE_ERR_PHY;
+		}
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_phy_write_reg,
+					 (hw, reg_addr, device_type, phy_data),
+					 IXGBE_NOT_IMPLEMENTED);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_link_setup - Configure link settings
+ *  @hw: pointer to hardware structure
+ *
+ *  Configures link settings based on values in the ixgbe_hw struct.
+ *  Restarts the link.  Performs autonegotiation if needed.
+ **/
+s32 ixgbe_link_setup(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_link_setup, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_link_check - Get link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the links register to determine if link is up and the current speed
+ **/
+s32 ixgbe_link_check(struct ixgbe_hw *hw, u32 *speed, boolean_t *link_up)
+{
+	return ixgbe_call_func(hw, ixgbe_func_link_check, (hw, speed, link_up),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_link_setup_speed - Set link speed
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: TRUE if autonegotiation enabled
+ *
+ *  Set the link speed and restarts the link.
+ **/
+s32 ixgbe_link_setup_speed(struct ixgbe_hw *hw, u32 speed,
+			   boolean_t autoneg,
+			   boolean_t autoneg_wait_to_complete)
+{
+	return ixgbe_call_func(hw, ixgbe_func_link_setup_speed,
+			       (hw, speed, autoneg, autoneg_wait_to_complete),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_link_set_default_settings - Set link settings to default
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the default link settings based on attach type in the hw struct.
+ **/
+s32 ixgbe_link_get_settings(struct ixgbe_hw *hw, u32 *speed,
+			    boolean_t *autoneg)
+{
+	return ixgbe_call_func(hw, ixgbe_func_link_get_settings, (hw, speed,
+								  autoneg),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_led_on - Turn on LED's
+ *  @hw: pointer to hardware structure
+ *  @index: led number to turn on
+ *
+ *  Turns on the software controllable LEDs.
+ **/
+s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index)
+{
+	return ixgbe_call_func(hw, ixgbe_func_led_on, (hw, index),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_led_off - Turn off LED's
+ *  @hw: pointer to hardware structure
+ *  @index: led number to turn off
+ *
+ *  Turns off the software controllable LEDs.
+ **/
+s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index)
+{
+	return ixgbe_call_func(hw, ixgbe_func_led_off, (hw, index),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_led_blink_start - Blink LED's
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ *
+ *  Blink LED based on index.
+ **/
+s32 ixgbe_led_blink_start(struct ixgbe_hw *hw, u32 index)
+{
+	return ixgbe_call_func(hw, ixgbe_func_led_blink_start, (hw, index),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_led_blink_stop - Stop blinking LED's
+ *  @hw: pointer to hardware structure
+ *
+ *  Stop blinking LED based on index.
+ **/
+s32 ixgbe_led_blink_stop(struct ixgbe_hw *hw, u32 index)
+{
+	return ixgbe_call_func(hw, ixgbe_func_led_blink_stop, (hw, index),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_eeprom_init_params - Initialiaze EEPROM parameters
+ *  @hw: pointer to hardware structure
+ *
+ *  Initializes the EEPROM parameters ixgbe_eeprom_info within the
+ *  ixgbe_hw struct in order to set up EEPROM access.
+ **/
+s32 ixgbe_eeprom_init_params(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_eeprom_init_params, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_eeprom_write - Write word to EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @data: 16 bit word to be written to the EEPROM
+ *
+ *  Writes 16 bit value to EEPROM. If ixgbe_eeprom_update_checksum is not
+ *  called after this function, the EEPROM will most likely contain an
+ *  invalid checksum.
+ **/
+s32 ixgbe_eeprom_write(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	s32 status;
+
+	/*
+	 * Initialize EEPROM parameters.  This will not do anything if the
+	 * EEPROM structure has already been initialized
+	 */
+	ixgbe_eeprom_init_params(hw);
+
+	/* Check for invalid offset */
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+	} else {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_eeprom_write,
+					 (hw, offset, data),
+					 IXGBE_NOT_IMPLEMENTED);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_read - Read word from EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @data: read 16 bit value from EEPROM
+ *
+ *  Reads 16 bit value from EEPROM
+ **/
+s32 ixgbe_eeprom_read(struct ixgbe_hw *hw, u16 offset, u16 *data)
+{
+	s32 status;
+
+	/*
+	 * Initialize EEPROM parameters.  This will not do anything if the
+	 * EEPROM structure has already been initialized
+	 */
+	ixgbe_eeprom_init_params(hw);
+
+	/* Check for invalid offset */
+	if (offset >= hw->eeprom.word_size) {
+		status = IXGBE_ERR_EEPROM;
+	} else {
+		status = ixgbe_call_func(hw,
+					 ixgbe_func_eeprom_read,
+					 (hw, offset, data),
+					 IXGBE_NOT_IMPLEMENTED);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_validate_checksum - Validate EEPROM checksum
+ *  @hw: pointer to hardware structure
+ *  @checksum_val: calculated checksum
+ *
+ *  Performs checksum calculation and validates the EEPROM checksum
+ **/
+s32 ixgbe_eeprom_validate_checksum(struct ixgbe_hw *hw, u16 *checksum_val)
+{
+	return ixgbe_call_func(hw, ixgbe_func_eeprom_validate_checksum,
+			       (hw, checksum_val), IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_eeprom_update_checksum - Updates the EEPROM checksum
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_eeprom_update_checksum(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_eeprom_update_checksum, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_rar_set - Set RX address register
+ *  @hw: pointer to hardware structure
+ *  @addr: Address to put into receive address register
+ *  @index: Receive address register to write
+ *  @vind: Vind to set RAR to
+ *  @enable_addr: set flag that address is active
+ *
+ *  Puts an ethernet address into a receive address register.
+ **/
+s32 ixgbe_rar_set(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
+		  u32 enable_addr)
+{
+	return ixgbe_call_func(hw, ixgbe_func_rar_set, (hw, index, addr, vind,
+							enable_addr),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_init_rx_addrs - Initializes receive address filters.
+ *  @hw: pointer to hardware structure
+ *
+ *  Places the MAC address in receive address register 0 and clears the rest
+ *  of the receive addresss registers. Clears the multicast table. Assumes
+ *  the receiver is in reset when the routine is called.
+ **/
+s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_init_rx_addrs, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_get_num_rx_addrs - Returns the number of RAR entries.
+ *  @hw: pointer to hardware structure
+ **/
+u32 ixgbe_get_num_rx_addrs(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_get_num_rx_addrs, (hw), 0);
+}
+
+/**
+ *  ixgbe_mc_addr_list_update - Updates the MAC's list of multicast addresses
+ *  @hw: pointer to hardware structure
+ *  @mc_addr_list: the list of new multicast addresses
+ *  @mc_addr_count: number of addresses
+ *  @pad: number of bytes between addresses in the list
+ *
+ *  The given list replaces any existing list. Clears the MC addrs from receive
+ *  address registers and the multicast table. Uses unsed receive address
+ *  registers for the first multicast addresses, and hashes the rest into the
+ *  multicast table.
+ **/
+s32 ixgbe_mc_addr_list_update(struct ixgbe_hw *hw, u8 *mc_addr_list,
+			      u32 mc_addr_count, u32 pad)
+{
+	return ixgbe_call_func(hw, ixgbe_func_mc_addr_list_update,
+			       (hw, mc_addr_list, mc_addr_count, pad),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_mc_enable - Enable multicast address in RAR
+ *  @hw: pointer to hardware structure
+ *
+ *  Enables multicast address in RAR and the use of the multicast hash table.
+ **/
+s32 ixgbe_mc_enable(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_mc_enable, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_mc_disable - Disable multicast address in RAR
+ *  @hw: pointer to hardware structure
+ *
+ *  Disables multicast address in RAR and the use of the multicast hash table.
+ **/
+s32 ixgbe_mc_disable(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_mc_disable, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_vfta_clear - Clear VLAN filter table
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ **/
+s32 ixgbe_vfta_clear(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_vfta_clear, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_vfta_set - Set VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vlan: VLAN id to write to VLAN filter
+ *  @vind: VMDq output index that maps queue to VLAN id in VFTA
+ *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
+ *
+ *  Turn on/off specified VLAN in the VLAN filter table.
+ **/
+s32 ixgbe_vfta_set(struct ixgbe_hw *hw, u32 vlan, u32 vind, boolean_t vlan_on)
+{
+	return ixgbe_call_func(hw, ixgbe_func_vfta_set, (hw, vlan, vind,
+							 vlan_on),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_fc_setup - Set flow control
+ *  @hw: pointer to hardware structure
+ *  @packetbuf_num: packet buffer number (0-7)
+ *
+ *  Configures the flow control settings based on SW configuration.
+ **/
+s32 ixgbe_fc_setup(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	return ixgbe_call_func(hw, ixgbe_func_fc_setup, (hw, packetbuf_num),
+			       IXGBE_NOT_IMPLEMENTED);
+}
diff --git a/drivers/net/ixgbe/ixgbe_api.h b/drivers/net/ixgbe/ixgbe_api.h
new file mode 100644
index 0000000..79ba858
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_api.h
@@ -0,0 +1,89 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_API_H_
+#define _IXGBE_API_H_
+
+#include "ixgbe_type.h"
+
+s32 ixgbe_init_shared_code(struct ixgbe_hw *hw);
+
+s32 ixgbe_hw_init(struct ixgbe_hw *hw);
+s32 ixgbe_hw_reset(struct ixgbe_hw *hw);
+s32 ixgbe_hw_start(struct ixgbe_hw *hw);
+s32 ixgbe_hw_clear_cntrs(struct ixgbe_hw *hw);
+enum ixgbe_media_type ixgbe_adapter_get_media_type(struct ixgbe_hw *hw);
+s32 ixgbe_adapter_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr);
+s32 ixgbe_adapter_determine_bus_info(struct ixgbe_hw *hw);
+u32 ixgbe_adapter_get_num_of_tx_queues(struct ixgbe_hw *hw);
+u32 ixgbe_adapter_get_num_of_rx_queues(struct ixgbe_hw *hw);
+s32 ixgbe_adapter_stop(struct ixgbe_hw *hw);
+
+s32 ixgbe_phy_identify(struct ixgbe_hw *hw);
+s32 ixgbe_phy_reset(struct ixgbe_hw *hw);
+s32 ixgbe_phy_read_reg(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type,
+		       u16 *phy_data);
+s32 ixgbe_phy_write_reg(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type,
+			u16 phy_data);
+
+s32 ixgbe_link_setup(struct ixgbe_hw *hw);
+s32 ixgbe_link_setup_speed(struct ixgbe_hw *hw, u32 speed,
+			   boolean_t autoneg,
+			   boolean_t autoneg_wait_to_complete);
+s32 ixgbe_link_check(struct ixgbe_hw *hw, u32 *speed,
+		     boolean_t *link_up);
+s32 ixgbe_link_get_settings(struct ixgbe_hw *hw, u32 *speed,
+			    boolean_t *autoneg);
+s32 ixgbe_led_on(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_led_off(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_led_blink_start(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_led_blink_stop(struct ixgbe_hw *hw, u32 index);
+
+s32 ixgbe_eeprom_init_params(struct ixgbe_hw *hw);
+s32 ixgbe_eeprom_write(struct ixgbe_hw *hw, u16 offset, u16 data);
+s32 ixgbe_eeprom_read(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_eeprom_validate_checksum(struct ixgbe_hw *hw, u16 *checksum_val);
+s32 ixgbe_eeprom_update_checksum(struct ixgbe_hw *hw);
+
+s32 ixgbe_rar_set(struct ixgbe_hw *hw, u32 index, u8 *addr,
+		  u32 vind, u32 enable_addr);
+s32 ixgbe_init_rx_addrs(struct ixgbe_hw *hw);
+u32 ixgbe_get_num_rx_addrs(struct ixgbe_hw *hw);
+s32 ixgbe_mc_addr_list_update(struct ixgbe_hw *hw, u8 *mc_addr_list,
+			      u32 mc_addr_count, u32 pad);
+s32 ixgbe_mc_enable(struct ixgbe_hw *hw);
+s32 ixgbe_mc_disable(struct ixgbe_hw *hw);
+s32 ixgbe_vfta_clear(struct ixgbe_hw *hw);
+s32 ixgbe_vfta_set(struct ixgbe_hw *hw, u32 vlan,
+		   u32 vind, boolean_t vlan_on);
+
+s32 ixgbe_fc_setup(struct ixgbe_hw *hw, s32 packetbuf_num);
+
+void ixgbe_mta_set(struct ixgbe_hw *hw, u8 *mc_addr);
+
+#endif /* _IXGBE_API_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
new file mode 100644
index 0000000..d00ec5f
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -0,0 +1,1725 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe_common.h"
+#include "ixgbe_api.h"
+
+static s32 ixgbe_eeprom_poll_eerd_done(struct ixgbe_hw *hw);
+static s32 ixgbe_eeprom_acquire(struct ixgbe_hw *hw);
+static s32 ixgbe_eeprom_get_semaphore(struct ixgbe_hw *hw);
+static void ixgbe_eeprom_release_semaphore(struct ixgbe_hw *hw);
+static s32 ixgbe_eeprom_ready(struct ixgbe_hw *hw);
+static void ixgbe_eeprom_standby(struct ixgbe_hw *hw);
+static void ixgbe_eeprom_shift_out_bits(struct ixgbe_hw *hw, u16 data,
+					u16 count);
+static u16 ixgbe_eeprom_shift_in_bits(struct ixgbe_hw *hw, u16 count);
+static void ixgbe_eeprom_raise_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_eeprom_lower_clk(struct ixgbe_hw *hw, u32 *eec);
+static void ixgbe_eeprom_release(struct ixgbe_hw *hw);
+static u16 ixgbe_eeprom_calc_checksum(struct ixgbe_hw *hw);
+
+static void ixgbe_rar_enable(struct ixgbe_hw *hw, u32 index);
+static void ixgbe_rar_disable(struct ixgbe_hw *hw, u32 index);
+static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr);
+void ixgbe_mc_addr_add(struct ixgbe_hw *hw, u8 *mc_addr);
+
+/**
+ *  ixgbe_generic_assign_func_pointers - Set generic func ptrs
+ *  @hw: pointer to hardware structure
+ *
+ *  Assigns generic function pointers.  Adapter-specific functions can
+ *  override the assignment of generic function pointers by assigning
+ *  their own adapter-specific function pointers.
+ **/
+s32 ixgbe_generic_assign_func_pointers(struct ixgbe_hw *hw)
+{
+	struct ixgbe_function_table *f = &hw->func_table;
+
+	f->ixgbe_func_hw_init = &ixgbe_generic_hw_init;
+	f->ixgbe_func_hw_start = &ixgbe_generic_hw_start;
+	f->ixgbe_func_hw_clear_cntrs = &ixgbe_generic_hw_clear_cntrs;
+	f->ixgbe_func_adapter_get_mac_addr =
+			&ixgbe_generic_adapter_get_mac_addr;
+	f->ixgbe_func_adapter_stop = &ixgbe_generic_adapter_stop;
+	f->ixgbe_func_adapter_determine_bus_info =
+			&ixgbe_generic_adapter_determine_bus_info;
+	/* LED */
+	f->ixgbe_func_led_on = &ixgbe_generic_led_on;
+	f->ixgbe_func_led_off = &ixgbe_generic_led_off;
+	/* EEPROM */
+	f->ixgbe_func_eeprom_init_params = &ixgbe_generic_eeprom_init_params;
+	f->ixgbe_func_eeprom_read = &ixgbe_generic_eeprom_read_bit_bang;
+	f->ixgbe_func_eeprom_write = &ixgbe_generic_eeprom_write;
+	f->ixgbe_func_eeprom_validate_checksum =
+			&ixgbe_generic_eeprom_validate_checksum;
+	f->ixgbe_func_eeprom_update_checksum =
+			&ixgbe_generic_eeprom_update_checksum;
+	/* RAR, Multicast, VLAN */
+	f->ixgbe_func_rar_set = &ixgbe_generic_rar_set;
+	f->ixgbe_func_init_rx_addrs = &ixgbe_generic_init_rx_addrs;
+	f->ixgbe_func_mc_addr_list_update = &ixgbe_generic_mc_addr_list_update;
+	f->ixgbe_func_mc_enable = &ixgbe_generic_mc_enable;
+	f->ixgbe_func_mc_disable = &ixgbe_generic_mc_disable;
+	f->ixgbe_func_vfta_clear = &ixgbe_generic_vfta_clear;
+	f->ixgbe_func_vfta_set = &ixgbe_generic_vfta_set;
+	f->ixgbe_func_fc_setup = &ixgbe_generic_fc_setup;
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_hw_start - Prepare hardware for TX/RX
+ *  @hw: pointer to hardware structure
+ *
+ *  Starts the hardware by filling the bus info structure and media type, clears
+ *  all on chip counters, initializes receive address registers, multicast
+ *  table, VLAN filter table, calls routine to set up link and flow control
+ *  settings, and leaves transmit and receive units disabled and uninitialized
+ **/
+s32 ixgbe_generic_hw_start(struct ixgbe_hw *hw)
+{
+	u32 ctrl_ext;
+
+	/* Set the media type */
+	hw->media_type = ixgbe_adapter_get_media_type(hw);
+
+	/* Set bus info */
+	ixgbe_adapter_determine_bus_info(hw);
+
+	/* Identify the PHY */
+	ixgbe_phy_identify(hw);
+
+	/*
+	 * Store MAC address from RAR0, clear receive address registers, and
+	 * clear the multicast table
+	 */
+	ixgbe_init_rx_addrs(hw);
+
+	/* Clear the VLAN filter table */
+	ixgbe_vfta_clear(hw);
+
+	/* Set up link */
+	ixgbe_link_setup(hw);
+
+	/* Clear statistics registers */
+	ixgbe_hw_clear_cntrs(hw);
+
+	/* Set up flow control */
+	ixgbe_fc_setup(hw, 0);
+
+	/* Set No Snoop Disable */
+	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
+	ctrl_ext |= IXGBE_CTRL_EXT_NS_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+
+	/* Clear adapter stopped flag */
+	hw->adapter_stopped = FALSE;
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_hw_init - Generic hardware initialization
+ *  @hw: pointer to hardware structure
+ *
+ *  Initialize the hardware by reseting the hardware, filling the bus info
+ *  structure and media type, clears all on chip counters, initializes receive
+ *  address registers, multicast table, VLAN filter table, calls routine to set
+ *  up link and flow control settings, and leaves transmit and receive units
+ *  disabled and uninitialized
+ **/
+s32 ixgbe_generic_hw_init(struct ixgbe_hw *hw)
+{
+	/* Reset the hardware */
+	ixgbe_hw_reset(hw);
+
+	/* Start the HW */
+	ixgbe_hw_start(hw);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_hw_clear_cntrs - Generic clear hardware counters
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears all hardware statistics counters by reading them from the hardware
+ *  Statistics counters are clear on read.
+ **/
+s32 ixgbe_generic_hw_clear_cntrs(struct ixgbe_hw *hw)
+{
+	u16 i = 0;
+
+	IXGBE_READ_REG(hw, IXGBE_CRCERRS);
+	IXGBE_READ_REG(hw, IXGBE_ILLERRC);
+	IXGBE_READ_REG(hw, IXGBE_ERRBC);
+	IXGBE_READ_REG(hw, IXGBE_MSPDC);
+	for (i = 0; i < 8; i++)
+		IXGBE_READ_REG(hw, IXGBE_MPC(i));
+
+	IXGBE_READ_REG(hw, IXGBE_MLFC);
+	IXGBE_READ_REG(hw, IXGBE_MRFC);
+	IXGBE_READ_REG(hw, IXGBE_RLEC);
+	IXGBE_READ_REG(hw, IXGBE_LXONTXC);
+	IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+	IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+
+	for (i = 0; i < 8; i++) {
+		IXGBE_READ_REG(hw, IXGBE_PXONTXC(i));
+		IXGBE_READ_REG(hw, IXGBE_PXONRXC(i));
+		IXGBE_READ_REG(hw, IXGBE_PXOFFTXC(i));
+		IXGBE_READ_REG(hw, IXGBE_PXOFFRXC(i));
+	}
+
+	IXGBE_READ_REG(hw, IXGBE_PRC64);
+	IXGBE_READ_REG(hw, IXGBE_PRC127);
+	IXGBE_READ_REG(hw, IXGBE_PRC255);
+	IXGBE_READ_REG(hw, IXGBE_PRC511);
+	IXGBE_READ_REG(hw, IXGBE_PRC1023);
+	IXGBE_READ_REG(hw, IXGBE_PRC1522);
+	IXGBE_READ_REG(hw, IXGBE_GPRC);
+	IXGBE_READ_REG(hw, IXGBE_BPRC);
+	IXGBE_READ_REG(hw, IXGBE_MPRC);
+	IXGBE_READ_REG(hw, IXGBE_GPTC);
+	IXGBE_READ_REG(hw, IXGBE_GORCL);
+	IXGBE_READ_REG(hw, IXGBE_GORCH);
+	IXGBE_READ_REG(hw, IXGBE_GOTCL);
+	IXGBE_READ_REG(hw, IXGBE_GOTCH);
+	for (i = 0; i < 8; i++)
+		IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+	IXGBE_READ_REG(hw, IXGBE_RUC);
+	IXGBE_READ_REG(hw, IXGBE_RFC);
+	IXGBE_READ_REG(hw, IXGBE_ROC);
+	IXGBE_READ_REG(hw, IXGBE_RJC);
+	IXGBE_READ_REG(hw, IXGBE_MNGPRC);
+	IXGBE_READ_REG(hw, IXGBE_MNGPDC);
+	IXGBE_READ_REG(hw, IXGBE_MNGPTC);
+	IXGBE_READ_REG(hw, IXGBE_TORL);
+	IXGBE_READ_REG(hw, IXGBE_TORH);
+	IXGBE_READ_REG(hw, IXGBE_TPR);
+	IXGBE_READ_REG(hw, IXGBE_TPT);
+	IXGBE_READ_REG(hw, IXGBE_PTC64);
+	IXGBE_READ_REG(hw, IXGBE_PTC127);
+	IXGBE_READ_REG(hw, IXGBE_PTC255);
+	IXGBE_READ_REG(hw, IXGBE_PTC511);
+	IXGBE_READ_REG(hw, IXGBE_PTC1023);
+	IXGBE_READ_REG(hw, IXGBE_PTC1522);
+	IXGBE_READ_REG(hw, IXGBE_MPTC);
+	IXGBE_READ_REG(hw, IXGBE_BPTC);
+	for (i = 0; i < 16; i++) {
+		IXGBE_READ_REG(hw, IXGBE_QPRC(i));
+		IXGBE_READ_REG(hw, IXGBE_QBRC(i));
+		IXGBE_READ_REG(hw, IXGBE_QPTC(i));
+		IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_adapter_get_mac_addr - Generic get MAC address
+ *  @hw: pointer to hardware structure
+ *  @mac_addr: Adapter MAC address
+ *
+ *  Reads the adapter's MAC address from first Receive Address Register (RAR0)
+ *  A reset of the adapter must be performed prior to calling this function
+ *  in order for the MAC address to have been loaded from the EEPROM into RAR0
+ **/
+s32 ixgbe_generic_adapter_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr)
+{
+	u32 rar_high;
+	u32 rar_low;
+	u16 i;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(0));
+	rar_low = IXGBE_READ_REG(hw, IXGBE_RAL(0));
+
+	for (i = 0; i < 4; i++)
+		mac_addr[i] = (u8)(rar_low >> (i*8));
+
+	for (i = 0; i < 2; i++)
+		mac_addr[i+4] = (u8)(rar_high >> (i*8));
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_adapter_determine_bus_info - Generic set PCI bus info
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the PCI bus info (speed, width, type) within the ixgbe_hw structure
+ **/
+s32 ixgbe_generic_adapter_determine_bus_info(struct ixgbe_hw *hw)
+{
+	u16 link_status;
+
+	hw->bus.type = ixgbe_bus_type_pci_express;
+
+	/* Get the negotiated link width and speed from PCI config space */
+	link_status = IXGBE_READ_PCIE_WORD(hw, IXGBE_PCI_LINK_STATUS);
+
+	switch (link_status & IXGBE_PCI_LINK_WIDTH) {
+	case IXGBE_PCI_LINK_WIDTH_1:
+		hw->bus.width = ixgbe_bus_width_pciex_1;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_2:
+		hw->bus.width = ixgbe_bus_width_pciex_2;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_4:
+		hw->bus.width = ixgbe_bus_width_pciex_4;
+		break;
+	case IXGBE_PCI_LINK_WIDTH_8:
+		hw->bus.width = ixgbe_bus_width_pciex_8;
+		break;
+	default:
+		hw->bus.width = ixgbe_bus_width_unknown;
+		break;
+	}
+
+	switch (link_status & IXGBE_PCI_LINK_SPEED) {
+	case IXGBE_PCI_LINK_SPEED_2500:
+		hw->bus.speed = ixgbe_bus_speed_2500;
+		break;
+	case IXGBE_PCI_LINK_SPEED_5000:
+		hw->bus.speed = ixgbe_bus_speed_5000;
+		break;
+	default:
+		hw->bus.speed = ixgbe_bus_speed_unknown;
+		break;
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_adapter_stop - Generic stop TX/RX units
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the adapter_stopped flag within ixgbe_hw struct. Clears interrupts,
+ *  disables transmit and receive units. The adapter_stopped flag is used by
+ *  the shared code and drivers to determine if the adapter is in a stopped
+ *  state and should not touch the hardware.
+ **/
+s32 ixgbe_generic_adapter_stop(struct ixgbe_hw *hw)
+{
+	u32 number_of_queues;
+	u32 reg_val;
+	u16 i;
+
+	/*
+	 * Set the adapter_stopped flag so other driver functions stop touching
+	 * the hardware
+	 */
+	hw->adapter_stopped = TRUE;
+
+	/* Disable the receive unit */
+	reg_val = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	reg_val &= ~(IXGBE_RXCTRL_RXEN);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_val);
+	msleep(2);
+
+	/* Clear interrupt mask to stop from interrupts being generated */
+	IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_IRQ_CLEAR_MASK);
+
+	/* Clear any pending interrupts */
+	IXGBE_READ_REG(hw, IXGBE_EICR);
+
+	/* Disable the transmit unit.  Each queue must be disabled. */
+	number_of_queues = ixgbe_adapter_get_num_of_tx_queues(hw);
+	for (i = 0; i < number_of_queues; i++) {
+		reg_val = IXGBE_READ_REG(hw, IXGBE_TXDCTL(i));
+		if (reg_val & IXGBE_TXDCTL_ENABLE) {
+			reg_val &= ~IXGBE_TXDCTL_ENABLE;
+			IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(i), reg_val);
+		}
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_led_on - Turns on the software controllable LEDs.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to turn on
+ **/
+s32 ixgbe_generic_led_on(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/* To turn on the LED, set mode to ON. */
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_ON << IXGBE_LED_MODE_SHIFT(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_led_off - Turns off the software controllable LEDs.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to turn off
+ **/
+s32 ixgbe_generic_led_off(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	/* To turn off the LED, set mode to OFF. */
+	led_reg &= ~IXGBE_LED_MODE_MASK(index);
+	led_reg |= IXGBE_LED_OFF << IXGBE_LED_MODE_SHIFT(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+
+	return IXGBE_SUCCESS;
+}
+
+
+/**
+ *  ixgbe_generic_led_blink_start - Blink LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to blink
+ **/
+s32 ixgbe_generic_led_blink_start(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	led_reg |= IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_led_blink_stop - Stop blinking LED based on index.
+ *  @hw: pointer to hardware structure
+ *  @index: led number to stop blinking
+ **/
+s32 ixgbe_generic_led_blink_stop(struct ixgbe_hw *hw, u32 index)
+{
+	u32 led_reg = IXGBE_READ_REG(hw, IXGBE_LEDCTL);
+
+	led_reg &= ~IXGBE_LED_BLINK(index);
+	IXGBE_WRITE_REG(hw, IXGBE_LEDCTL, led_reg);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_eeprom_init_params - Initialize EEPROM params
+ *  @hw: pointer to hardware structure
+ *
+ *  Initializes the EEPROM parameters ixgbe_eeprom_info within the
+ *  ixgbe_hw struct in order to set up EEPROM access.
+ **/
+s32 ixgbe_generic_eeprom_init_params(struct ixgbe_hw *hw)
+{
+	struct ixgbe_eeprom_info *eeprom = &hw->eeprom;
+	u32 eec;
+	u16 eeprom_size;
+
+	if (eeprom->type == ixgbe_eeprom_uninitialized) {
+		eeprom->type = ixgbe_eeprom_none;
+
+		/*
+		 * Check for EEPROM present first.
+		 * If not present leave as none
+		 */
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+		if (eec & IXGBE_EEC_PRES) {
+			eeprom->type = ixgbe_eeprom_spi;
+
+			/*
+			 * SPI EEPROM is assumed here.  This code would need to
+			 * change if a future EEPROM is not SPI.
+			 */
+			eeprom_size = (u16)((eec & IXGBE_EEC_SIZE) >>
+					     IXGBE_EEC_SIZE_SHIFT);
+			eeprom->word_size = 1 << (eeprom_size +
+						  IXGBE_EEPROM_WORD_SIZE_SHIFT);
+		}
+
+		if (eec & IXGBE_EEC_ADDR_SIZE)
+			eeprom->address_bits = 16;
+		else
+			eeprom->address_bits = 8;
+		DEBUGOUT3("Eeprom params: type = %d, size = %d, address bits: "
+			  "%d\n", eeprom->type, eeprom->word_size,
+			  eeprom->address_bits);
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_eeprom_write - Writes 16 bit value to EEPROM
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @data: 16 bit word to be written to the EEPROM
+ *
+ *  If ixgbe_eeprom_update_checksum is not called after this function, the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+s32 ixgbe_generic_eeprom_write(struct ixgbe_hw *hw, u16 offset, u16 data)
+{
+	s32 status;
+	u8 write_opcode = IXGBE_EEPROM_WRITE_OPCODE_SPI;
+
+	/* Prepare the EEPROM for writing  */
+	status = ixgbe_eeprom_acquire(hw);
+
+	if (status == IXGBE_SUCCESS) {
+		if (ixgbe_eeprom_ready(hw) != IXGBE_SUCCESS) {
+			ixgbe_eeprom_release(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		ixgbe_eeprom_standby(hw);
+
+		/*  Send the WRITE ENABLE command (8 bit opcode )  */
+		ixgbe_eeprom_shift_out_bits(hw, IXGBE_EEPROM_WREN_OPCODE_SPI,
+					    IXGBE_EEPROM_OPCODE_BITS);
+
+		ixgbe_eeprom_standby(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
+			write_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+		/* Send the Write command (8-bit opcode + addr) */
+		ixgbe_eeprom_shift_out_bits(hw, write_opcode,
+					    IXGBE_EEPROM_OPCODE_BITS);
+		ixgbe_eeprom_shift_out_bits(hw, (u16)(offset*2),
+					    hw->eeprom.address_bits);
+
+		/* Send the data */
+		data = (data >> 8) | (data << 8);
+		ixgbe_eeprom_shift_out_bits(hw, data, 16);
+		ixgbe_eeprom_standby(hw);
+
+		msleep(10);
+
+		/* Done with writing - release the EEPROM */
+		ixgbe_eeprom_release(hw);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_generic_eeprom_read_bit_bang - Read EEPROM word using bit-bang
+ *  @hw: pointer to hardware structure
+ *  @offset: offset within the EEPROM to be read
+ *  @data: read 16 bit value from EEPROM
+ *
+ *  Reads 16 bit value from EEPROM through bit-bang method
+ **/
+s32 ixgbe_generic_eeprom_read_bit_bang(struct ixgbe_hw *hw, u16 offset,
+				       u16 *data)
+{
+	s32 status;
+	u16 word_in;
+	u8 read_opcode = IXGBE_EEPROM_READ_OPCODE_SPI;
+
+	/* Prepare the EEPROM for reading  */
+	status = ixgbe_eeprom_acquire(hw);
+
+	if (status == IXGBE_SUCCESS) {
+		if (ixgbe_eeprom_ready(hw) != IXGBE_SUCCESS) {
+			ixgbe_eeprom_release(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	if (status == IXGBE_SUCCESS) {
+		ixgbe_eeprom_standby(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((hw->eeprom.address_bits == 8) && (offset >= 128))
+			read_opcode |= IXGBE_EEPROM_A8_OPCODE_SPI;
+
+		/* Send the READ command (opcode + addr) */
+		ixgbe_eeprom_shift_out_bits(hw, read_opcode,
+					    IXGBE_EEPROM_OPCODE_BITS);
+		ixgbe_eeprom_shift_out_bits(hw, (u16)(offset*2),
+					    hw->eeprom.address_bits);
+
+		/* Read the data. */
+		word_in = ixgbe_eeprom_shift_in_bits(hw, 16);
+		*data = (word_in >> 8) | (word_in << 8);
+
+		/* End this read operation */
+		ixgbe_eeprom_release(hw);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_generic_eeprom_read - Read EEPROM word using EERD
+ *  @hw: pointer to hardware structure
+ *  @offset: offset of  word in the EEPROM to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM using the EERD register.
+ **/
+s32 ixgbe_generic_eeprom_read(struct ixgbe_hw *hw, u16 offset, u16 *data)
+{
+	u32 eerd;
+	s32 status;
+
+	eerd = (offset << IXGBE_EEPROM_READ_ADDR_SHIFT) +
+	       IXGBE_EEPROM_READ_REG_START;
+
+	IXGBE_WRITE_REG(hw, IXGBE_EERD, eerd);
+	status = ixgbe_eeprom_poll_eerd_done(hw);
+
+	if (status == IXGBE_SUCCESS)
+		*data = (IXGBE_READ_REG(hw, IXGBE_EERD) >>
+			 IXGBE_EEPROM_READ_REG_DATA);
+	else
+		DEBUGOUT("Eeprom read timed out\n");
+
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_poll_eerd_done - Poll EERD status
+ *  @hw: pointer to hardware structure
+ *
+ *  Polls the status bit (bit 1) of the EERD to determine when the read is done.
+ **/
+static s32 ixgbe_eeprom_poll_eerd_done(struct ixgbe_hw *hw)
+{
+	u32 i;
+	u32 reg;
+	s32 status = IXGBE_ERR_EEPROM;
+
+	for (i = 0; i < IXGBE_EERD_ATTEMPTS; i++) {
+		reg = IXGBE_READ_REG(hw, IXGBE_EERD);
+		if (reg & IXGBE_EEPROM_READ_REG_DONE) {
+			status = IXGBE_SUCCESS;
+			break;
+		}
+		udelay(5);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_aquire - Aquire EEPROM using bit-bang
+ *  @hw: pointer to hardware structure
+ *
+ *  Prepares EEPROM for access using bit-bang method. This function should
+ *  be called before issuing a command to the EEPROM.
+ **/
+static s32 ixgbe_eeprom_acquire(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_SUCCESS;
+	u32 eec;
+	u32 i;
+
+	if (ixgbe_swfw_sync_acquire(hw, IXGBE_GSSR_EEP_SM) != IXGBE_SUCCESS)
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	if (status == IXGBE_SUCCESS) {
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		/* Request EEPROM Access */
+		eec |= IXGBE_EEC_REQ;
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+		for (i = 0; i < IXGBE_EEPROM_GRANT_ATTEMPTS; i++) {
+			eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+			if (eec & IXGBE_EEC_GNT)
+				break;
+			udelay(5);
+		}
+
+		/* Release if grant not aquired */
+		if (!(eec & IXGBE_EEC_GNT)) {
+			eec &= ~IXGBE_EEC_REQ;
+			IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+			DEBUGOUT("Could not acquire EEPROM grant\n");
+
+			ixgbe_swfw_sync_release(hw, IXGBE_GSSR_EEP_SM);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	/* Setup EEPROM for Read/Write */
+	if (status == IXGBE_SUCCESS) {
+		/* Clear CS and SK */
+		eec &= ~(IXGBE_EEC_CS | IXGBE_EEC_SK);
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+		udelay(1);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_get_semaphore - Get hardware semaphore
+ *  @hw: pointer to hardware structure
+ *
+ *  Sets the hardware semaphores so EEPROM access can occur for bit-bang method
+ **/
+static s32 ixgbe_eeprom_get_semaphore(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_EEPROM;
+	u32 timeout;
+	u32 i;
+	u32 swsm;
+
+	/* Set timeout value based on size of EEPROM */
+	timeout = hw->eeprom.word_size + 1;
+
+	/* Get SMBI software semaphore between device drivers first */
+	for (i = 0; i < timeout; i++) {
+		/*
+		 * If the SMBI bit is 0 when we read it, then the bit will be
+		 * set and we have the semaphore
+		 */
+		swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+		if (!(swsm & IXGBE_SWSM_SMBI)) {
+			status = IXGBE_SUCCESS;
+			break;
+		}
+		msleep(1);
+	}
+
+	/* Now get the semaphore between SW/FW through the SWESMBI bit */
+	if (status == IXGBE_SUCCESS) {
+		for (i = 0; i < timeout; i++) {
+			swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+
+			/* Set the SW EEPROM semaphore bit to request access */
+			swsm |= IXGBE_SWSM_SWESMBI;
+			IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
+
+			/*
+			 * If we set the bit successfully then we got the
+			 * semaphore.
+			 */
+			swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+			if (swsm & IXGBE_SWSM_SWESMBI)
+				break;
+
+			udelay(50);
+		}
+
+		/*
+		 * Release semaphores and return error if SW EEPROM semaphore
+		 * was not granted because we don't have access to the EEPROM
+		 */
+		if (i >= timeout) {
+			DEBUGOUT("Driver can't access the Eeprom - Semaphore "
+				 "not granted.\n");
+			ixgbe_eeprom_release_semaphore(hw);
+			status = IXGBE_ERR_EEPROM;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_release_semaphore - Release hardware semaphore
+ *  @hw: pointer to hardware structure
+ *
+ *  This function clears hardware semaphore bits.
+ **/
+static void ixgbe_eeprom_release_semaphore(struct ixgbe_hw *hw)
+{
+	u32 swsm;
+
+	swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+
+	/* Release both semaphores by writing 0 to the bits SWESMBI and SMBI */
+	swsm &= ~(IXGBE_SWSM_SWESMBI | IXGBE_SWSM_SMBI);
+	IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
+}
+
+/**
+ *  ixgbe_eeprom_ready - Polls for EEPROM ready
+ *  @hw: pointer to hardware structure
+ **/
+static s32 ixgbe_eeprom_ready(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_SUCCESS;
+	u16 i;
+	u8 spi_stat_reg;
+
+	/*
+	 * Read "Status Register" repeatedly until the LSB is cleared.  The
+	 * EEPROM will signal that the command has been completed by clearing
+	 * bit 0 of the internal status register.  If it's not cleared within
+	 * 5 milliseconds, then error out.
+	 */
+	for (i = 0; i < IXGBE_EEPROM_MAX_RETRY_SPI; i += 5) {
+		ixgbe_eeprom_shift_out_bits(hw, IXGBE_EEPROM_RDSR_OPCODE_SPI,
+					    IXGBE_EEPROM_OPCODE_BITS);
+		spi_stat_reg = (u8)ixgbe_eeprom_shift_in_bits(hw, 8);
+		if (!(spi_stat_reg & IXGBE_EEPROM_STATUS_RDY_SPI))
+			break;
+
+		udelay(5);
+		ixgbe_eeprom_standby(hw);
+	};
+
+	/*
+	 * On some parts, SPI write time could vary from 0-20mSec on 3.3V
+	 * devices (and only 0-5mSec on 5V devices)
+	 */
+	if (i >= IXGBE_EEPROM_MAX_RETRY_SPI) {
+		DEBUGOUT("SPI EEPROM Status error\n");
+		status = IXGBE_ERR_EEPROM;
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_eeprom_standby - Returns EEPROM to a "standby" state
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_eeprom_standby(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/* Toggle CS to flush commands */
+	eec |= IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+	eec &= ~IXGBE_EEC_CS;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_eeprom_shift_out_bits - Shift data bits out to the EEPROM.
+ *  @hw: pointer to hardware structure
+ *  @data: data to send to the EEPROM
+ *  @count: number of bits to shift out
+ **/
+static void ixgbe_eeprom_shift_out_bits(struct ixgbe_hw *hw, u16 data,
+					u16 count)
+{
+	u32 eec;
+	u32 mask;
+	u32 i;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	/*
+	 * Mask is used to shift "count" bits of "data" out to the EEPROM
+	 * one bit at a time.  Determine the starting bit based on count
+	 */
+	mask = 0x01 << (count - 1);
+
+	for (i = 0; i < count; i++) {
+		/*
+		 * A "1" is shifted out to the EEPROM by setting bit "DI" to a
+		 * "1", and then raising and then lowering the clock (the SK
+		 * bit controls the clock input to the EEPROM).  A "0" is
+		 * shifted out to the EEPROM by setting "DI" to "0" and then
+		 * raising and then lowering the clock.
+		 */
+		if (data & mask)
+			eec |= IXGBE_EEC_DI;
+		else
+			eec &= ~IXGBE_EEC_DI;
+
+		IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+		IXGBE_WRITE_FLUSH(hw);
+
+		udelay(1);
+
+		ixgbe_eeprom_raise_clk(hw, &eec);
+		ixgbe_eeprom_lower_clk(hw, &eec);
+
+		/*
+		 * Shift mask to signify next bit of data to shift in to the
+		 * EEPROM
+		 */
+		mask = mask >> 1;
+	};
+
+	/* We leave the "DI" bit set to "0" when we leave this routine. */
+	eec &= ~IXGBE_EEC_DI;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+}
+
+/**
+ *  ixgbe_eeprom_shift_in_bits - Shift data bits in from the EEPROM
+ *  @hw: pointer to hardware structure
+ **/
+static u16 ixgbe_eeprom_shift_in_bits(struct ixgbe_hw *hw, u16 count)
+{
+	u32 eec;
+	u32 i;
+	u16 data = 0;
+
+	/*
+	 * In order to read a register from the EEPROM, we need to shift
+	 * 'count' bits in from the EEPROM. Bits are "shifted in" by raising
+	 * the clock input to the EEPROM (setting the SK bit), and then reading
+	 * the value of the "DO" bit.  During this "shifting in" process the
+	 * "DI" bit should always be clear.
+	 */
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec &= ~(IXGBE_EEC_DO | IXGBE_EEC_DI);
+
+	for (i = 0; i < count; i++) {
+		data = data << 1;
+		ixgbe_eeprom_raise_clk(hw, &eec);
+
+		eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+		eec &= ~(IXGBE_EEC_DI);
+		if (eec & IXGBE_EEC_DO)
+			data |= 1;
+
+		ixgbe_eeprom_lower_clk(hw, &eec);
+	}
+
+	return data;
+}
+
+/**
+ *  ixgbe_eeprom_raise_clk - Raises the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eec: EEC register's current value
+ **/
+static void ixgbe_eeprom_raise_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Raise the clock input to the EEPROM
+	 * (setting the SK bit), then delay
+	 */
+	*eec = *eec | IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_eeprom_lower_clk - Lowers the EEPROM's clock input.
+ *  @hw: pointer to hardware structure
+ *  @eecd: EECD's current value
+ **/
+static void ixgbe_eeprom_lower_clk(struct ixgbe_hw *hw, u32 *eec)
+{
+	/*
+	 * Lower the clock input to the EEPROM (clearing the SK bit), then
+	 * delay
+	 */
+	*eec = *eec & ~IXGBE_EEC_SK;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, *eec);
+	IXGBE_WRITE_FLUSH(hw);
+	udelay(1);
+}
+
+/**
+ *  ixgbe_eeprom_release - Release EEPROM, release semaphores
+ *  @hw: pointer to hardware structure
+ **/
+static void ixgbe_eeprom_release(struct ixgbe_hw *hw)
+{
+	u32 eec;
+
+	eec = IXGBE_READ_REG(hw, IXGBE_EEC);
+
+	eec |= IXGBE_EEC_CS;  /* Pull CS high */
+	eec &= ~IXGBE_EEC_SK; /* Lower SCK */
+
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+	IXGBE_WRITE_FLUSH(hw);
+
+	udelay(1);
+
+	/* Stop requesting EEPROM access */
+	eec &= ~IXGBE_EEC_REQ;
+	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
+
+	ixgbe_swfw_sync_release(hw, IXGBE_GSSR_EEP_SM);
+}
+
+/**
+ *  ixgbe_eeprom_calc_checksum - Calculates and returns the checksum
+ *  @hw: pointer to hardware structure
+ **/
+static u16 ixgbe_eeprom_calc_checksum(struct ixgbe_hw *hw)
+{
+	u16 i;
+	u16 j;
+	u16 checksum = 0;
+	u16 length = 0;
+	u16 pointer = 0;
+	u16 word = 0;
+
+	/* Include 0x0-0x3F in the checksum */
+	for (i = 0; i < IXGBE_EEPROM_CHECKSUM; i++) {
+		if (ixgbe_eeprom_read(hw, i, &word) != IXGBE_SUCCESS) {
+			DEBUGOUT("EEPROM read failed\n");
+			break;
+		}
+		checksum += word;
+	}
+
+	/* Include all data from pointers except for the fw pointer */
+	for (i = IXGBE_PCIE_ANALOG_PTR; i < IXGBE_FW_PTR; i++) {
+		ixgbe_eeprom_read(hw, i, &pointer);
+
+		/* Make sure the pointer seems valid */
+		if (pointer != 0xFFFF && pointer != 0) {
+			ixgbe_eeprom_read(hw, pointer, &length);
+
+			if (length != 0xFFFF && length != 0) {
+				for (j = pointer+1; j <= pointer+length; j++) {
+					ixgbe_eeprom_read(hw, j, &word);
+					checksum += word;
+				}
+			}
+		}
+	}
+
+	checksum = (u16)IXGBE_EEPROM_SUM - checksum;
+
+	return checksum;
+}
+
+/**
+ *  ixgbe_generic_eeprom_validate_checksum - Validate EEPROM checksum
+ *  @hw: pointer to hardware structure
+ *  @checksum_val: calculated checksum
+ *
+ *  Performs checksum calculation and validates the EEPROM checksum.  If the
+ *  caller does not need checksum_val, the value can be NULL.
+ **/
+s32 ixgbe_generic_eeprom_validate_checksum(struct ixgbe_hw *hw,
+					   u16 *checksum_val)
+{
+	s32 status;
+	u16 checksum;
+	u16 read_checksum = 0;
+
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = ixgbe_eeprom_read(hw, 0, &checksum);
+
+	if (status == IXGBE_SUCCESS) {
+		checksum = ixgbe_eeprom_calc_checksum(hw);
+
+		ixgbe_eeprom_read(hw, IXGBE_EEPROM_CHECKSUM, &read_checksum);
+
+		/*
+		 * Verify read checksum from EEPROM is the same as
+		 * calculated checksum
+		 */
+		if (read_checksum != checksum) {
+			status = IXGBE_ERR_EEPROM_CHECKSUM;
+		}
+
+		/* If the user cares, return the calculated checksum */
+		if (checksum_val) {
+			*checksum_val = checksum;
+		}
+	} else {
+		DEBUGOUT("EEPROM read failed\n");
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_generic_eeprom_update_checksum - Updates the EEPROM checksm
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_generic_eeprom_update_checksum(struct ixgbe_hw *hw)
+{
+	s32 status;
+	u16 checksum;
+
+	/*
+	 * Read the first word from the EEPROM. If this times out or fails, do
+	 * not continue or we could be in for a very long wait while every
+	 * EEPROM read fails
+	 */
+	status = ixgbe_eeprom_read(hw, 0, &checksum);
+
+	if (status == IXGBE_SUCCESS) {
+		checksum = ixgbe_eeprom_calc_checksum(hw);
+		status = ixgbe_eeprom_write(hw, IXGBE_EEPROM_CHECKSUM,
+						checksum);
+	} else {
+		DEBUGOUT("EEPROM read failed\n");
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_mac_addr_valid - Validate MAC address
+ *  @mac_addr: pointer to MAC address.
+ *
+ *  Tests a MAC address to ensure it is a valid Individual Address
+ **/
+s32 ixgbe_mac_addr_valid(u8 *mac_addr)
+{
+	s32 status = IXGBE_SUCCESS;
+
+	if (IXGBE_IS_MULTICAST(mac_addr)) {
+		DEBUGOUT("MAC address is multicast\n");
+		status = IXGBE_ERR_INVALID_MAC_ADDR;
+	} else if (IXGBE_IS_BROADCAST(mac_addr)) {
+		DEBUGOUT("MAC address is broadcast\n");
+		status = IXGBE_ERR_INVALID_MAC_ADDR;
+	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 && mac_addr[2] == 0 &&
+		 mac_addr[3] == 0 && mac_addr[4] == 0 && mac_addr[5] == 0) {
+		DEBUGOUT("MAC address is all zeros\n");
+		status = IXGBE_ERR_INVALID_MAC_ADDR;
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_generic_rar_set - Set RX address register
+ *  @hw: pointer to hardware structure
+ *  @addr: Address to put into receive address register
+ *  @index: Receive address register to write
+ *  @vind: Vind to set RAR to
+ *  @enable_addr: set flag that address is active
+ *
+ *  Puts an ethernet address into a receive address register.
+ **/
+s32 ixgbe_generic_rar_set(struct ixgbe_hw *hw, u32 index, u8 *addr, u32 vind,
+			  u32 enable_addr)
+{
+	u32 rar_low, rar_high;
+
+	/*
+	 * HW expects these in little endian so we reverse the byte order from
+	 * network order (big endian) to little endian
+	 */
+	rar_low = ((u32)addr[0] |
+		   ((u32)addr[1] << 8) |
+		   ((u32)addr[2] << 16) |
+		   ((u32)addr[3] << 24));
+
+	rar_high = ((u32)addr[4] |
+		    ((u32)addr[5] << 8) |
+		    ((vind << IXGBE_RAH_VIND_SHIFT) & IXGBE_RAH_VIND_MASK));
+
+	if (enable_addr != 0)
+		rar_high |= IXGBE_RAH_AV;
+
+	IXGBE_WRITE_REG(hw, IXGBE_RAL(index), rar_low);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_rar_enable - Enable RX address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Enables the select receive address register.
+ **/
+static void ixgbe_rar_enable(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high |= IXGBE_RAH_AV;
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_rar_disable - Disable RX address register
+ *  @hw: pointer to hardware structure
+ *  @index: index into the RAR table
+ *
+ *  Disables the select receive address register.
+ **/
+static void ixgbe_rar_disable(struct ixgbe_hw *hw, u32 index)
+{
+	u32 rar_high;
+
+	rar_high = IXGBE_READ_REG(hw, IXGBE_RAH(index));
+	rar_high &= (~IXGBE_RAH_AV);
+	IXGBE_WRITE_REG(hw, IXGBE_RAH(index), rar_high);
+}
+
+/**
+ *  ixgbe_generic_init_rx_addrs - Initializes receive address filters.
+ *  @hw: pointer to hardware structure
+ *
+ *  Places the MAC address in receive address register 0 and clears the rest
+ *  of the receive addresss registers. Clears the multicast table. Assumes
+ *  the receiver is in reset when the routine is called.
+ **/
+s32 ixgbe_generic_init_rx_addrs(struct ixgbe_hw *hw)
+{
+	u32 i;
+	u32 rar_entries = ixgbe_get_num_rx_addrs(hw);
+
+	/*
+	 * If the current mac address is valid, assume it is a software override
+	 * to the permanent address.
+	 * Otherwise, use the permanent address from the eeprom.
+	 */
+	if (ixgbe_mac_addr_valid(hw->curr_mac_addr) ==
+	    IXGBE_ERR_INVALID_MAC_ADDR) {
+		/* Get the MAC address from the RAR0 for later reference */
+		ixgbe_adapter_get_mac_addr(hw, hw->curr_mac_addr);
+
+		DEBUGOUT3(" Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
+			  hw->curr_mac_addr[0], hw->curr_mac_addr[1],
+			  hw->curr_mac_addr[2]);
+		DEBUGOUT3("%.2X %.2X %.2X\n", hw->curr_mac_addr[3],
+			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+	} else {
+		/* Setup the receive address. */
+		DEBUGOUT("Overriding MAC Address in RAR[0]\n");
+		DEBUGOUT3(" New MAC Addr =%.2X %.2X %.2X ",
+			  hw->curr_mac_addr[0], hw->curr_mac_addr[1],
+			  hw->curr_mac_addr[2]);
+		DEBUGOUT3("%.2X %.2X %.2X\n", hw->curr_mac_addr[3],
+			  hw->curr_mac_addr[4], hw->curr_mac_addr[5]);
+
+		ixgbe_rar_set(hw, 0, hw->curr_mac_addr, 0, IXGBE_RAH_AV);
+	}
+
+	hw->addr_ctrl.rar_used_count = 1;
+
+	/* Zero out the other receive addresses. */
+	DEBUGOUT("Clearing RAR[1-15]\n");
+	for (i = 1; i < rar_entries; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
+	}
+
+	/* Clear the MTA */
+	hw->addr_ctrl.mc_addr_in_rar_count = 0;
+	hw->addr_ctrl.mta_in_use = 0;
+	IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mc_filter_type);
+
+	DEBUGOUT(" Clearing MTA\n");
+	for (i = 0; i < IXGBE_MC_TBL_SIZE; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_mta_vector - Determines bit-vector in multicast table to set
+ *  @hw: pointer to hardware structure
+ *  @mc_addr: the multicast address
+ *
+ *  Extracts the 12 bits, from a multicast address, to determine which
+ *  bit-vector to set in the multicast table. The hardware uses 12 bits, from
+ *  incoming rx multicast addresses, to determine the bit-vector to check in
+ *  the MTA. Which of the 4 combination, of 12-bits, the hardware uses is set
+ *  by the MO field of the MCSTCTRL. The MO field is set during initalization
+ *  to mc_filter_type.
+ **/
+static s32 ixgbe_mta_vector(struct ixgbe_hw *hw, u8 *mc_addr)
+{
+	u32 vector = 0;
+
+	switch (hw->mc_filter_type) {
+	case 0:          /* use bits [47:36] of the address */
+		vector = ((mc_addr[4] >> 4) | (((u16)mc_addr[5]) << 4));
+		break;
+	case 1:          /* use bits [46:35] of the address */
+		vector = ((mc_addr[4] >> 3) | (((u16)mc_addr[5]) << 5));
+		break;
+	case 2:          /* use bits [45:34] of the address */
+		vector = ((mc_addr[4] >> 2) | (((u16)mc_addr[5]) << 6));
+		break;
+	case 3:          /* use bits [43:32] of the address */
+		vector = ((mc_addr[4]) | (((u16)mc_addr[5]) << 8));
+		break;
+	default:         /* Invalid mc_filter_type */
+		DEBUGOUT("MC filter type param set incorrectly\n");
+		break;
+	}
+
+	/* vector can only be 12-bits or boundary will be exceeded */
+	vector &= 0xFFF;
+	return vector;
+}
+
+/**
+ *  ixgbe_mta_set - Set bit-vector in multicast table
+ *  @hw: pointer to hardware structure
+ *  @hash_value: Multicast address hash value
+ *
+ *  Sets the bit-vector in the multicast table.
+ **/
+void ixgbe_mta_set(struct ixgbe_hw *hw, u8 *mc_addr)
+{
+	u32 vector;
+	u32 vector_bit;
+	u32 vector_reg;
+	u32 mta_reg;
+
+	hw->addr_ctrl.mta_in_use++;
+
+	vector = ixgbe_mta_vector(hw, mc_addr);
+	DEBUGOUT1(" bit-vector = 0x%03X\n", vector);
+
+	/*
+	 * The MTA is a register array of 128 32-bit registers. It is treated
+	 * like an array of 4096 bits.  We want to set bit
+	 * BitArray[vector_value]. So we figure out what register the bit is
+	 * in, read it, OR in the new bit, then write back the new value.  The
+	 * register is determined by the upper 7 bits of the vector value and
+	 * the bit within that register are determined by the lower 5 bits of
+	 * the value.
+	 */
+	vector_reg = (vector >> 5) & 0x7F;
+	vector_bit = vector & 0x1F;
+	mta_reg = IXGBE_READ_REG(hw, IXGBE_MTA(vector_reg));
+	mta_reg |= (1 << vector_bit);
+	IXGBE_WRITE_REG(hw, IXGBE_MTA(vector_reg), mta_reg);
+}
+
+/**
+ *  ixgbe_mc_addr_add - Adds a multicast address.
+ *  @hw: pointer to hardware structure
+ *  @mc_addr: new multicast address
+ *
+ *  Adds it to unused receive address register or to the multicast table.
+ **/
+void ixgbe_mc_addr_add(struct ixgbe_hw *hw, u8 *mc_addr)
+{
+	u32 rar_entries = ixgbe_get_num_rx_addrs(hw);
+
+	DEBUGOUT6(" MC Addr =%.2X %.2X %.2X %.2X %.2X %.2X\n",
+		  mc_addr[0], mc_addr[1], mc_addr[2],
+		  mc_addr[3], mc_addr[4], mc_addr[5]);
+
+	/*
+	 * Place this multicast address in the RAR if there is room,
+	 * else put it in the MTA
+	 */
+	if (hw->addr_ctrl.rar_used_count < rar_entries) {
+		ixgbe_rar_set(hw, hw->addr_ctrl.rar_used_count,
+			      mc_addr, 0, IXGBE_RAH_AV);
+		DEBUGOUT1("Added a multicast address to RAR[%d]\n",
+			  hw->addr_ctrl.rar_used_count);
+		hw->addr_ctrl.rar_used_count++;
+		hw->addr_ctrl.mc_addr_in_rar_count++;
+	} else {
+		ixgbe_mta_set(hw, mc_addr);
+	}
+
+	DEBUGOUT("ixgbe_mc_addr_add Complete\n");
+}
+
+/**
+ *  ixgbe_generic_mc_addr_list_update - Updates MAC list of multicast addresses
+ *  @hw: pointer to hardware structure
+ *  @mc_addr_list: the list of new multicast addresses
+ *  @mc_addr_count: number of addresses
+ *  @pad: number of bytes between addresses in the list
+ *
+ *  The given list replaces any existing list. Clears the MC addrs from receive
+ *  address registers and the multicast table. Uses unsed receive address
+ *  registers for the first multicast addresses, and hashes the rest into the
+ *  multicast table.
+ **/
+s32 ixgbe_generic_mc_addr_list_update(struct ixgbe_hw *hw, u8 *mc_addr_list,
+				      u32 mc_addr_count, u32 pad)
+{
+	u32 i;
+	u32 rar_entries = ixgbe_get_num_rx_addrs(hw);
+
+	/*
+	 * Set the new number of MC addresses that we are being requested to
+	 * use.
+	 */
+	hw->addr_ctrl.num_mc_addrs = mc_addr_count;
+	hw->addr_ctrl.rar_used_count -= hw->addr_ctrl.mc_addr_in_rar_count;
+	hw->addr_ctrl.mc_addr_in_rar_count = 0;
+	hw->addr_ctrl.mta_in_use = 0;
+
+	/* Zero out the other receive addresses. */
+	DEBUGOUT("Clearing RAR[1-15]\n");
+	for (i = hw->addr_ctrl.rar_used_count; i < rar_entries; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_RAL(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RAH(i), 0);
+	}
+
+	/* Clear the MTA */
+	DEBUGOUT(" Clearing MTA\n");
+	for (i = 0; i < IXGBE_MC_TBL_SIZE; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_MTA(i), 0);
+
+	/* Add the new addresses */
+	for (i = 0; i < mc_addr_count; i++) {
+		DEBUGOUT(" Adding the multicast addresses:\n");
+		ixgbe_mc_addr_add(hw, mc_addr_list +
+				  (i * (IXGBE_ETH_LENGTH_OF_ADDRESS + pad)));
+	}
+
+	/* Enable mta */
+	if (hw->addr_ctrl.mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL,
+				IXGBE_MCSTCTRL_MFE | hw->mc_filter_type);
+
+	DEBUGOUT("ixgbe_generic_mc_addr_list_update Complete\n");
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_mc_enable - Enable multicast address in RAR
+ *  @hw: pointer to hardware structure
+ *
+ *  Enables multicast address in RAR and the use of the multicast hash table.
+ **/
+s32 ixgbe_generic_mc_enable(struct ixgbe_hw *hw)
+{
+	u32 i;
+	struct ixgbe_addr_filter *a = &hw->addr_ctrl;
+
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (a->rar_used_count - a->mc_addr_in_rar_count);
+		     i < a->rar_used_count; i++)
+			ixgbe_rar_enable(hw, i);
+
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, IXGBE_MCSTCTRL_MFE |
+				hw->mc_filter_type);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_mc_disable - Disable mutlicast address in RAR
+ *  @hw: pointer to hardware structure
+ *
+ *  Disables multicast address in RAR and the use of the multicast hash table.
+ **/
+s32 ixgbe_generic_mc_disable(struct ixgbe_hw *hw)
+{
+	u32 i;
+	struct ixgbe_addr_filter *a = &hw->addr_ctrl;
+
+	if (a->mc_addr_in_rar_count > 0)
+		for (i = (a->rar_used_count - a->mc_addr_in_rar_count);
+		     i < a->rar_used_count; i++)
+			ixgbe_rar_disable(hw, i);
+
+	if (a->mta_in_use > 0)
+		IXGBE_WRITE_REG(hw, IXGBE_MCSTCTRL, hw->mc_filter_type);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_vfta_clear - Clear VLAN filter table
+ *  @hw: pointer to hardware structure
+ *
+ *  Clears the VLAN filer table, and the VMDq index associated with the filter
+ **/
+s32 ixgbe_generic_vfta_clear(struct ixgbe_hw *hw)
+{
+	u32 offset;
+	u32 vlanbyte;
+
+	for (offset = 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+		IXGBE_WRITE_REG(hw, IXGBE_VFTA(offset), 0);
+
+	for (vlanbyte = 0; vlanbyte < 4; vlanbyte++)
+		for (offset = 0; offset < IXGBE_VLAN_FILTER_TBL_SIZE; offset++)
+			IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(vlanbyte,
+							   offset), 0);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_vfta_set - Set VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vlan: VLAN id to write to VLAN filter
+ *  @vind: VMDq output index that maps queue to VLAN id in VFTA
+ *  @vlan_on: boolean flag to turn on/off VLAN in VFTA
+ *
+ *  Turn on/off specified VLAN in the VLAN filter table.
+ **/
+s32 ixgbe_generic_vfta_set(struct ixgbe_hw *hw, u32 vlan, u32 vind,
+			   boolean_t vlan_on)
+{
+	u32 VftaIndex;
+	u32 BitOffset;
+	u32 VftaReg;
+	u32 VftaByte;
+
+	/* Determine 32-bit word position in array */
+	VftaIndex = (vlan >> 5) & 0x7F;   /* upper seven bits */
+
+	/* Determine the location of the (VMD) queue index */
+	VftaByte =  ((vlan >> 3) & 0x03); /* bits (4:3) indicating byte array */
+	BitOffset = (vlan & 0x7) << 2;    /* lower 3 bits indicate nibble */
+
+	/* Set the nibble for VMD queue index */
+	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex));
+	VftaReg &= (~(0x0F << BitOffset));
+	VftaReg |= (vind << BitOffset);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTAVIND(VftaByte, VftaIndex), VftaReg);
+
+	/* Determine the location of the bit for this VLAN id */
+	BitOffset = vlan & 0x1F;           /* lower five bits */
+
+	VftaReg = IXGBE_READ_REG(hw, IXGBE_VFTA(VftaIndex));
+	if (vlan_on)
+		/* Turn on this VLAN id */
+		VftaReg |= (1 << BitOffset);
+	else
+		/* Turn off this VLAN id */
+		VftaReg &= ~(1 << BitOffset);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTA(VftaIndex), VftaReg);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_fc_setup - Configure flow control settings
+ *  @hw: pointer to hardware structure
+ *  @packetbuf_num: packet buffer number (0-7)
+ *
+ *  Configures the flow control settings based on SW configuration.
+ *  This function is used for 802.3x flow control configuration only.
+ **/
+s32 ixgbe_generic_fc_setup(struct ixgbe_hw *hw, s32 packetbuf_num)
+{
+	u32 frctl_reg;
+	u32 rmcs_reg;
+
+	if (packetbuf_num < 0 || packetbuf_num > 7) {
+		DEBUGOUT1("Invalid packet buffer number [%d], expected range is"
+			  " 0-7\n", packetbuf_num);
+	}
+
+	frctl_reg = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+	frctl_reg &= ~(IXGBE_FCTRL_RFCE | IXGBE_FCTRL_RPFCE);
+
+	rmcs_reg = IXGBE_READ_REG(hw, IXGBE_RMCS);
+	rmcs_reg &= ~(IXGBE_RMCS_TFCE_PRIORITY | IXGBE_RMCS_TFCE_802_3X);
+
+	/*
+	 * We want to save off the original Flow Control configuration just in
+	 * case we get disconnected and then reconnected into a different hub
+	 * or switch with different Flow Control capabilities.
+	 */
+	hw->fc.type = hw->fc.original_type;
+
+	/*
+	 * The possible values of the "flow_control" parameter are:
+	 * 0: Flow control is completely disabled
+	 * 1: Rx flow control is enabled (we can receive pause frames but not
+	 *    send pause frames).
+	 * 2: Tx flow control is enabled (we can send pause frames but we do not
+	 *    support receiving pause frames)
+	 * 3: Both Rx and TX flow control (symmetric) are enabled.
+	 * other: Invalid.
+	 */
+	switch (hw->fc.type) {
+	case ixgbe_fc_none:
+		break;
+	case ixgbe_fc_rx_pause:
+		/*
+		 * RX Flow control is enabled,
+		 * and TX Flow control is disabled.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		break;
+	case ixgbe_fc_tx_pause:
+		/*
+		 * TX Flow control is enabled, and RX Flow control is disabled,
+		 * by a software over-ride.
+		 */
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	case ixgbe_fc_full:
+		/*
+		 * Flow control (both RX and TX) is enabled by a software
+		 * over-ride.
+		 */
+		frctl_reg |= IXGBE_FCTRL_RFCE;
+		rmcs_reg |= IXGBE_RMCS_TFCE_802_3X;
+		break;
+	default:
+		/* We should never get here.  The value should be 0-3. */
+		DEBUGOUT("Flow control param set incorrectly\n");
+		break;
+	}
+
+	/* Enable 802.3x based flow control settings. */
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, frctl_reg);
+	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
+
+	/*
+	 * We need to set up the Receive Threshold high and low water
+	 * marks as well as (optionally) enabling the transmission of
+	 * XON frames.
+	 */
+	if (hw->fc.type & ixgbe_fc_tx_pause) {
+		if (hw->fc.send_xon) {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+					(hw->fc.low_water | IXGBE_FCRTL_XONE));
+		} else {
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTL(packetbuf_num),
+					hw->fc.low_water);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH(packetbuf_num),
+				(hw->fc.high_water)|IXGBE_FCRTH_FCEN);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCTTV(0), hw->fc.pause_time);
+	IXGBE_WRITE_REG(hw, IXGBE_FCRTV, (hw->fc.pause_time >> 1));
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_pcie_master_disable - Disable PCI-express master access
+ *  @hw: pointer to hardware structure
+ *
+ *  Disables PCI-Express master access and verifies there are no pending
+ *  requests. IXGBE_ERR_MASTER_REQUESTS_PENDING is returned if master disable
+ *  bit hasn't caused the master requests to be disabled, else IXGBE_SUCCESS
+ *  is returned signifying master requests disabled.
+ **/
+s32 ixgbe_pcie_master_disable(struct ixgbe_hw *hw)
+{
+	u32 ctrl;
+	s32 i;
+	s32 status = IXGBE_ERR_MASTER_REQUESTS_PENDING;
+
+	ctrl = IXGBE_READ_REG(hw, IXGBE_CTRL);
+	ctrl |= IXGBE_CTRL_GIO_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL, ctrl);
+
+	for (i = 0; i < IXGBE_PCI_MASTER_DISABLE_TIMEOUT; i++) {
+		if (!(IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_GIO)) {
+			status = IXGBE_SUCCESS;
+			break;
+		}
+		udelay(100);
+	}
+
+	return status;
+}
+
+
+/**
+ *  ixgbe_swfw_sync_acquire - Aquire SWFW semaphore
+ *  @hw: pointer to hardware structure
+ *  @mask: Mask to specify wich semaphore to acquire
+ *
+ *  Aquires the SWFW semaphore throught the GSSR register for the specified
+ *  function (CSR, PHY0, PHY1, EEPROM, Flash)
+ **/
+s32 ixgbe_swfw_sync_acquire(struct ixgbe_hw *hw, u16 mask)
+{
+	u32 gssr;
+	u32 swmask = mask;
+	u32 fwmask = mask << 5;
+	s32 timeout = 200;
+
+	while (timeout) {
+		if (ixgbe_eeprom_get_semaphore(hw))
+			return -IXGBE_ERR_SWFW_SYNC;
+
+		gssr = IXGBE_READ_REG(hw, IXGBE_GSSR);
+		if (!(gssr & (fwmask | swmask)))
+			break;
+
+		/*
+		 * Firmware currently using resource (fwmask) or other software
+		 * thread currently using resource (swmask)
+		 */
+		ixgbe_eeprom_release_semaphore(hw);
+		msleep(5);
+		timeout--;
+	}
+
+	if (!timeout) {
+		DEBUGOUT("Driver can't access resource, GSSR timeout.\n");
+		return -IXGBE_ERR_SWFW_SYNC;
+	}
+
+	gssr |= swmask;
+	IXGBE_WRITE_REG(hw, IXGBE_GSSR, gssr);
+
+	ixgbe_eeprom_release_semaphore(hw);
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_swfw_sync_release - Release SWFW semaphore
+ *  @hw: pointer to hardware structure
+ *  @mask: Mask to specify wich semaphore to release
+ *
+ *  Releases the SWFW semaphore throught the GSSR register for the specified
+ *  function (CSR, PHY0, PHY1, EEPROM, Flash)
+ **/
+void ixgbe_swfw_sync_release(struct ixgbe_hw *hw, u16 mask)
+{
+	u32 gssr;
+	u32 swmask = mask;
+
+	ixgbe_eeprom_get_semaphore(hw);
+
+	gssr = IXGBE_READ_REG(hw, IXGBE_GSSR);
+	gssr &= ~swmask;
+	IXGBE_WRITE_REG(hw, IXGBE_GSSR, gssr);
+
+	ixgbe_eeprom_release_semaphore(hw);
+}
+
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
new file mode 100644
index 0000000..959b302
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -0,0 +1,74 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_COMMON_H_
+#define _IXGBE_COMMON_H_
+
+#include "ixgbe_type.h"
+
+s32 ixgbe_generic_assign_func_pointers(struct ixgbe_hw *hw);
+s32 ixgbe_generic_hw_init(struct ixgbe_hw *hw);
+s32 ixgbe_generic_hw_start(struct ixgbe_hw *hw);
+s32 ixgbe_generic_hw_clear_cntrs(struct ixgbe_hw *hw);
+s32 ixgbe_generic_adapter_get_mac_addr(struct ixgbe_hw *hw, u8 *mac_addr);
+s32 ixgbe_generic_adapter_determine_bus_info(struct ixgbe_hw *hw);
+s32 ixgbe_generic_adapter_stop(struct ixgbe_hw *hw);
+
+s32 ixgbe_generic_led_on(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_generic_led_off(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_generic_led_blink_start(struct ixgbe_hw *hw, u32 index);
+s32 ixgbe_generic_led_blink_stop(struct ixgbe_hw *hw, u32 index);
+
+s32 ixgbe_generic_eeprom_init_params(struct ixgbe_hw *hw);
+s32 ixgbe_generic_eeprom_write(struct ixgbe_hw *hw, u16 offset, u16 data);
+s32 ixgbe_generic_eeprom_read(struct ixgbe_hw *hw, u16 offset, u16 *data);
+s32 ixgbe_generic_eeprom_read_bit_bang(struct ixgbe_hw *hw, u16 offset,
+				       u16 *data);
+s32 ixgbe_generic_eeprom_validate_checksum(struct ixgbe_hw *hw,
+					   u16 *checksum_val);
+s32 ixgbe_generic_eeprom_update_checksum(struct ixgbe_hw *hw);
+
+s32 ixgbe_generic_rar_set(struct ixgbe_hw *hw, u32 index, u8 *addr,
+			  u32 vind, u32 enable_addr);
+s32 ixgbe_generic_init_rx_addrs(struct ixgbe_hw *hw);
+s32 ixgbe_generic_mc_addr_list_update(struct ixgbe_hw *hw, u8 *mc_addr_list,
+				      u32 mc_addr_count, u32 pad);
+s32 ixgbe_generic_mc_enable(struct ixgbe_hw *hw);
+s32 ixgbe_generic_mc_disable(struct ixgbe_hw *hw);
+s32 ixgbe_generic_vfta_clear(struct ixgbe_hw *hw);
+s32 ixgbe_generic_vfta_set(struct ixgbe_hw *hw, u32 vlan,
+			   u32 vind, boolean_t vlan_on);
+
+s32 ixgbe_generic_fc_setup(struct ixgbe_hw *hw, s32 packtetbuf_num);
+
+s32 ixgbe_mac_addr_valid(u8 *mac_addr);
+s32 ixgbe_swfw_sync_acquire(struct ixgbe_hw *hw, u16 mask);
+void ixgbe_swfw_sync_release(struct ixgbe_hw *hw, u16 mask);
+s32 ixgbe_pcie_master_disable(struct ixgbe_hw *hw);
+
+#endif /* IXGBE_COMMON */
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
new file mode 100644
index 0000000..1a81be1
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -0,0 +1,491 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+/* ethtool support for ixgbe */
+
+#include "ixgbe.h"
+
+#include <linux/uaccess.h>
+
+extern char ixgbe_driver_name[];
+extern char ixgbe_driver_version[];
+
+extern int ixgbe_up(struct ixgbe_adapter *adapter);
+extern void ixgbe_down(struct ixgbe_adapter *adapter);
+extern void ixgbe_reset(struct ixgbe_adapter *adapter);
+extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
+				    struct ixgbe_ring *rxdr);
+extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
+				    struct ixgbe_ring *txdr);
+extern void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter);
+extern void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter);
+extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
+
+
+#define IXGBE_ALL_RAR_ENTRIES 16
+
+struct ixgbe_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define IXGBE_STAT(m) sizeof(((struct ixgbe_adapter *)0)->m), \
+		      offsetof(struct ixgbe_adapter, m)
+static struct ixgbe_stats ixgbe_gstrings_stats[] = {
+	{"rx_packets", IXGBE_STAT(net_stats.rx_packets)},
+	{"tx_packets", IXGBE_STAT(net_stats.tx_packets)},
+	{"rx_bytes", IXGBE_STAT(net_stats.rx_bytes)},
+	{"tx_bytes", IXGBE_STAT(net_stats.tx_bytes)},
+	{"lsc_int", IXGBE_STAT(lsc_int)},
+	{"non_eop_descs", IXGBE_STAT(non_eop_descs)},
+	{"rx_errors", IXGBE_STAT(net_stats.rx_errors)},
+	{"tx_errors", IXGBE_STAT(net_stats.tx_errors)},
+	{"rx_dropped", IXGBE_STAT(net_stats.rx_dropped)},
+	{"tx_dropped", IXGBE_STAT(net_stats.tx_dropped)},
+	{"multicast", IXGBE_STAT(net_stats.multicast)},
+	{"collisions", IXGBE_STAT(net_stats.collisions)},
+	{"rx_over_errors", IXGBE_STAT(net_stats.rx_over_errors)},
+	{"rx_crc_errors", IXGBE_STAT(net_stats.rx_crc_errors)},
+	{"rx_frame_errors", IXGBE_STAT(net_stats.rx_frame_errors)},
+	{"rx_fifo_errors", IXGBE_STAT(net_stats.rx_fifo_errors)},
+	{"rx_missed_errors", IXGBE_STAT(net_stats.rx_missed_errors)},
+	{"tx_aborted_errors", IXGBE_STAT(net_stats.tx_aborted_errors)},
+	{"tx_carrier_errors", IXGBE_STAT(net_stats.tx_carrier_errors)},
+	{"tx_fifo_errors", IXGBE_STAT(net_stats.tx_fifo_errors)},
+	{"tx_heartbeat_errors", IXGBE_STAT(net_stats.tx_heartbeat_errors)},
+	{"tx_timeout_count", IXGBE_STAT(tx_timeout_count)},
+	{"tx_restart_queue", IXGBE_STAT(restart_queue)},
+	{"rx_long_length_errors", IXGBE_STAT(stats.roc)},
+	{"rx_short_length_errors", IXGBE_STAT(stats.ruc)},
+	{"tx_tcp4_seg_ctxt", IXGBE_STAT(hw_tso_ctxt)},
+	{"tx_tcp6_seg_ctxt", IXGBE_STAT(hw_tso6_ctxt)},
+	{"tx_flow_control_xon", IXGBE_STAT(stats.lxontxc)},
+	{"rx_flow_control_xon", IXGBE_STAT(stats.lxonrxc)},
+	{"tx_flow_control_xoff", IXGBE_STAT(stats.lxofftxc)},
+	{"rx_flow_control_xoff", IXGBE_STAT(stats.lxoffrxc)},
+	{"rx_csum_offload_good", IXGBE_STAT(hw_csum_rx_good)},
+	{"rx_csum_offload_errors", IXGBE_STAT(hw_csum_rx_error)},
+	{"tx_csum_offload_ctxt", IXGBE_STAT(hw_csum_tx_good)},
+	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
+	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
+	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
+};
+
+#define IXGBE_QUEUE_STATS_LEN ( \
+		(((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
+		((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
+		(sizeof(struct ixgbe_queue_stats) / sizeof(u64)) \
+	)
+#define IXGBE_GLOBAL_STATS_LEN	\
+	sizeof(ixgbe_gstrings_stats) / sizeof(struct ixgbe_stats)
+#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
+
+static int ixgbe_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+	ecmd->port = PORT_FIBRE;
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(adapter->netdev)) {
+		ecmd->speed = SPEED_10000;
+		ecmd->duplex = DUPLEX_FULL;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = AUTONEG_DISABLE;
+	return 0;
+}
+
+static int ixgbe_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (ecmd->autoneg == AUTONEG_ENABLE ||
+	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
+		return -EINVAL;
+
+	if (netif_running(adapter->netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_reset(adapter);
+		ixgbe_up(adapter);
+	} else {
+		ixgbe_reset(adapter);
+	}
+
+	return 0;
+}
+
+static void ixgbe_get_pauseparam(struct net_device *netdev,
+				 struct ethtool_pauseparam *pause)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	pause->autoneg = AUTONEG_DISABLE;
+
+	if (hw->fc.type == ixgbe_fc_rx_pause) {
+		pause->rx_pause = 1;
+	} else if (hw->fc.type == ixgbe_fc_tx_pause) {
+		pause->tx_pause = 1;
+	} else if (hw->fc.type == ixgbe_fc_full) {
+		pause->rx_pause = 1;
+		pause->tx_pause = 1;
+	}
+}
+
+static int ixgbe_set_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (pause->autoneg == AUTONEG_ENABLE)
+		return -EINVAL;
+
+	if (pause->rx_pause && pause->tx_pause)
+		hw->fc.type = ixgbe_fc_full;
+	else if (pause->rx_pause && !pause->tx_pause)
+		hw->fc.type = ixgbe_fc_rx_pause;
+	else if (!pause->rx_pause && pause->tx_pause)
+		hw->fc.type = ixgbe_fc_tx_pause;
+	else if (!pause->rx_pause && !pause->tx_pause)
+		hw->fc.type = ixgbe_fc_none;
+
+	hw->fc.original_type = hw->fc.type;
+
+	if (netif_running(adapter->netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_up(adapter);
+	} else {
+		ixgbe_reset(adapter);
+	}
+
+	return 0;
+}
+
+static u32 ixgbe_get_rx_csum(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	return adapter->flags.rx_csum_enabled;
+}
+
+static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	adapter->flags.rx_csum_enabled = data;
+
+	if (netif_running(netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_up(adapter);
+	} else {
+		ixgbe_reset(adapter);
+	}
+
+	return 0;
+}
+
+static u32 ixgbe_get_tx_csum(struct net_device *netdev)
+{
+	return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
+{
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
+}
+
+static int ixgbe_set_tso(struct net_device *netdev, u32 data)
+{
+
+	if (data) {
+		netdev->features |= NETIF_F_TSO;
+		netdev->features |= NETIF_F_TSO6;
+	} else {
+		netdev->features &= ~NETIF_F_TSO;
+		netdev->features &= ~NETIF_F_TSO6;
+	}
+	return 0;
+}
+
+static u32 ixgbe_get_msglevel(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	return adapter->msg_enable;
+}
+
+static void ixgbe_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	adapter->msg_enable = data;
+}
+
+static int ixgbe_get_regs_len(struct net_device *netdev)
+{
+#define IXGBE_REG_DUMP_LEN  136*sizeof(u32)
+	return IXGBE_REG_DUMP_LEN;
+}
+
+static void ixgbe_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *drvinfo)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	strncpy(drvinfo->driver, ixgbe_driver_name, 32);
+	strncpy(drvinfo->version, ixgbe_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	drvinfo->n_stats = IXGBE_STATS_LEN;
+	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
+}
+
+static void ixgbe_get_ringparam(struct net_device *netdev,
+				struct ethtool_ringparam *ring)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_ring *tx_ring = adapter->tx_ring;
+	struct ixgbe_ring *rx_ring = adapter->rx_ring;
+
+	ring->rx_max_pending = IXGBE_MAX_RXD;
+	ring->tx_max_pending = IXGBE_MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rx_ring->count;
+	ring->tx_pending = tx_ring->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int ixgbe_set_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_tx_buffer *old_buf;
+	struct ixgbe_rx_buffer *old_rx_buf;
+	void *old_desc;
+	int i, err;
+	u32 new_rx_count, new_tx_count, old_size;
+	dma_addr_t old_dma;
+
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+		return -EINVAL;
+
+	new_rx_count = max(ring->rx_pending, (u32)IXGBE_MIN_RXD);
+	new_rx_count = min(new_rx_count, (u32)IXGBE_MAX_RXD);
+	new_rx_count = ALIGN(new_rx_count, IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE);
+
+	new_tx_count = max(ring->tx_pending, (u32)IXGBE_MIN_TXD);
+	new_tx_count = min(new_tx_count, (u32)IXGBE_MAX_TXD);
+	new_tx_count = ALIGN(new_tx_count, IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
+
+	if ((new_tx_count == adapter->tx_ring->count) &&
+	    (new_rx_count == adapter->rx_ring->count)) {
+		/* nothing to do */
+		return 0;
+	}
+
+	if (netif_running(adapter->netdev))
+		ixgbe_down(adapter);
+
+	/*
+	 * We can't just free everything and then setup again,
+	 * because the ISRs in MSI-X mode get passed pointers
+	 * to the tx and rx ring structs.
+	 */
+	if (new_tx_count != adapter->tx_ring->count) {
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			/* Save existing descriptor ring */
+			old_buf = adapter->tx_ring[i].tx_buffer_info;
+			old_desc = adapter->tx_ring[i].desc;
+			old_size = adapter->tx_ring[i].size;
+			old_dma = adapter->tx_ring[i].dma;
+			/* Try to allocate a new one */
+			adapter->tx_ring[i].tx_buffer_info = NULL;
+			adapter->tx_ring[i].desc = NULL;
+			adapter->tx_ring[i].count = new_tx_count;
+			err = ixgbe_setup_tx_resources(adapter,
+						       &adapter->tx_ring[i]);
+			if (err) {
+				/* Restore the old one so at least
+				   the adapter still works, even if
+				   we failed the request */
+				adapter->tx_ring[i].tx_buffer_info = old_buf;
+				adapter->tx_ring[i].desc = old_desc;
+				adapter->tx_ring[i].size = old_size;
+				adapter->tx_ring[i].dma = old_dma;
+				goto err_setup;
+			}
+			/* Free the old buffer manually */
+			vfree(old_buf);
+			pci_free_consistent(adapter->pdev, old_size,
+					    old_desc, old_dma);
+		}
+	}
+
+	if (new_rx_count != adapter->rx_ring->count) {
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+
+			old_rx_buf = adapter->rx_ring[i].rx_buffer_info;
+			old_desc = adapter->rx_ring[i].desc;
+			old_size = adapter->rx_ring[i].size;
+			old_dma = adapter->rx_ring[i].dma;
+
+			adapter->rx_ring[i].rx_buffer_info = NULL;
+			adapter->rx_ring[i].desc = NULL;
+			adapter->rx_ring[i].dma = 0;
+			adapter->rx_ring[i].count = new_rx_count;
+			err = ixgbe_setup_rx_resources(adapter,
+						       &adapter->rx_ring[i]);
+			if (err) {
+				adapter->rx_ring[i].rx_buffer_info = old_rx_buf;
+				adapter->rx_ring[i].desc = old_desc;
+				adapter->rx_ring[i].size = old_size;
+				adapter->rx_ring[i].dma = old_dma;
+				goto err_setup;
+			}
+
+			vfree(old_rx_buf);
+			pci_free_consistent(adapter->pdev, old_size, old_desc,
+					    old_dma);
+		}
+	}
+
+	err = 0;
+err_setup:
+	if (netif_running(adapter->netdev))
+		ixgbe_up(adapter);
+
+	return err;
+}
+
+static int ixgbe_get_stats_count(struct net_device *netdev)
+{
+	return IXGBE_STATS_LEN;
+}
+
+static void ixgbe_get_ethtool_stats(struct net_device *netdev,
+				    struct ethtool_stats *stats, u64 *data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u64 *queue_stat;
+	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
+	int j, k;
+	int i;
+
+	ixgbe_update_stats(adapter);
+	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
+		char *p = (char *)adapter + ixgbe_gstrings_stats[i].stat_offset;
+		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
+			   sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+	for (j = 0; j < adapter->num_tx_queues; j++) {
+		queue_stat = (u64 *)&adapter->tx_ring[j].stats;
+		for (k = 0; k < stat_count; k++)
+			data[i + k] = queue_stat[k];
+		i += k;
+	}
+	for (j = 0; j < adapter->num_rx_queues; j++) {
+		queue_stat = (u64 *)&adapter->rx_ring[j].stats;
+		for (k = 0; k < stat_count; k++)
+			data[i + k] = queue_stat[k];
+		i += k;
+	}
+}
+
+static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
+			      u8 *data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, ixgbe_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			sprintf(p, "tx_queue_%u_packets", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_queue_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			sprintf(p, "rx_queue_%u_packets", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_queue_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+/*		BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
+		break;
+	}
+}
+
+static struct ethtool_ops ixgbe_ethtool_ops = {
+	.get_settings           = ixgbe_get_settings,
+	.set_settings           = ixgbe_set_settings,
+	.get_drvinfo            = ixgbe_get_drvinfo,
+	.get_link               = ethtool_op_get_link,
+	.get_ringparam          = ixgbe_get_ringparam,
+	.set_ringparam          = ixgbe_set_ringparam,
+	.get_pauseparam         = ixgbe_get_pauseparam,
+	.set_pauseparam         = ixgbe_set_pauseparam,
+	.get_rx_csum            = ixgbe_get_rx_csum,
+	.set_rx_csum            = ixgbe_set_rx_csum,
+	.get_tx_csum            = ixgbe_get_tx_csum,
+	.set_tx_csum            = ixgbe_set_tx_csum,
+	.get_sg                 = ethtool_op_get_sg,
+	.set_sg                 = ethtool_op_set_sg,
+	.get_msglevel           = ixgbe_get_msglevel,
+	.set_msglevel           = ixgbe_set_msglevel,
+	.get_tso                = ethtool_op_get_tso,
+	.set_tso                = ixgbe_set_tso,
+	.get_strings            = ixgbe_get_strings,
+	.get_stats_count        = ixgbe_get_stats_count,
+	.get_ethtool_stats      = ixgbe_get_ethtool_stats,
+	.get_perm_addr          = ethtool_op_get_perm_addr,
+};
+
+void ixgbe_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &ixgbe_ethtool_ops);
+}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
new file mode 100644
index 0000000..1ba451c
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -0,0 +1,2623 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
+#include <net/checksum.h>
+#include <net/ip6_checksum.h>
+
+#include "ixgbe.h"
+
+char ixgbe_driver_name[] = "ixgbe";
+static char ixgbe_driver_string[] =
+			"Intel(R) PRO/10GbE PCI Express Network Driver";
+#define DRV_VERSION "1.0.0"
+char ixgbe_driver_version[] = DRV_VERSION;
+static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
+
+/* ixgbe_pci_tbl - PCI Device ID Table
+ *
+ * Wildcard entries (PCI_ANY_ID) should come last
+ * Last entry must be all 0s
+ *
+ * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
+ *   Class, Class Mask, private data (not used) }
+ */
+static struct pci_device_id ixgbe_pci_tbl[] = {
+	{PCI_DEVICE(PCI_VENDOR_ID_INTEL, IXGBE_DEV_ID_82598)},
+	{PCI_DEVICE(PCI_VENDOR_ID_INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT)},
+	{PCI_DEVICE(PCI_VENDOR_ID_INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT)},
+
+	/* required last entry */
+	{0, }
+};
+MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
+
+/* Exported from other modules */
+extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
+extern s32 ixgbe_mac_addr_valid(u8 *mac_addr);
+extern void ixgbe_mta_set(struct ixgbe_hw *hw, u8 *mc_addr);
+extern void ixgbe_mc_addr_add(struct ixgbe_hw *hw, u8 *mc_addr);
+extern void ixgbe_check_options(struct ixgbe_adapter *adapter);
+
+MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
+MODULE_DESCRIPTION("Intel(R) PRO/10GbE PCI Express Network Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+
+static void ixgbe_set_ivar(struct ixgbe_adapter *adapter, u16 int_alloc_entry,
+			   u8 msix_vector)
+{
+	u32 ivar, index;
+
+	msix_vector |= IXGBE_IVAR_ALLOC_VAL;
+	index = (int_alloc_entry >> 2) & 0x1F;
+	ivar = IXGBE_READ_REG_ARRAY(&adapter->hw, IXGBE_IVAR(0), index);
+	ivar |= (msix_vector << (8 * (int_alloc_entry & 0x3)));
+	IXGBE_WRITE_REG_ARRAY(&adapter->hw, IXGBE_IVAR(0), index, ivar);
+}
+
+static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
+					     struct ixgbe_tx_buffer
+					     *tx_buffer_info)
+{
+	if (tx_buffer_info->dma) {
+		pci_unmap_page(adapter->pdev,
+			       tx_buffer_info->dma,
+			       tx_buffer_info->length, PCI_DMA_TODEVICE);
+		tx_buffer_info->dma = 0;
+	}
+	if (tx_buffer_info->skb) {
+		dev_kfree_skb_any(tx_buffer_info->skb);
+		tx_buffer_info->skb = NULL;
+	}
+	/* tx_buffer_info must be completely set up in the transmit path */
+}
+
+static inline boolean_t ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
+					    struct ixgbe_ring *tx_ring,
+					    unsigned int eop,
+					    union ixgbe_adv_tx_desc *eop_desc)
+{
+	/* Detect a transmit hang in hardware, this serializes the
+	 * check with the clearing of time_stamp and movement of i */
+	adapter->detect_tx_hung = FALSE;
+	if (tx_ring->tx_buffer_info[eop].dma &&
+		     time_after(jiffies,
+				tx_ring->tx_buffer_info[eop].time_stamp
+				+ HZ)
+		     && !(IXGBE_READ_REG(&adapter->hw, IXGBE_TFCS) &
+			  IXGBE_TFCS_TXOFF)) {
+
+		/* detected Tx unit hang */
+		DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+			"  TDH                  <%x>\n"
+			"  TDT                  <%x>\n"
+			"  next_to_use          <%x>\n"
+			"  next_to_clean        <%x>\n"
+			"tx_buffer_info[next_to_clean]\n"
+			"  time_stamp           <%lx>\n"
+			"  next_to_watch        <%x>\n"
+			"  jiffies              <%lx>\n"
+			"  next_to_watch.status <%x>\n",
+			readl(adapter->hw.hw_addr + tx_ring->head),
+			readl(adapter->hw.hw_addr + tx_ring->tail),
+			tx_ring->next_to_use,
+			tx_ring->next_to_clean,
+			tx_ring->tx_buffer_info[eop].time_stamp,
+			eop, jiffies, eop_desc->wb.status);
+		return TRUE;
+	}
+
+	return FALSE;
+}
+
+/**
+ * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
+ * @adapter: board private structure
+ **/
+static boolean_t ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
+				    struct ixgbe_ring *tx_ring)
+{
+	struct net_device *netdev = adapter->netdev;
+	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	unsigned int i, eop;
+	boolean_t cleaned = FALSE;
+
+	i = tx_ring->next_to_clean;
+	eop = tx_ring->tx_buffer_info[i].next_to_watch;
+	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+	while (eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) {
+		for (cleaned = FALSE; !cleaned;) {
+			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+			tx_buffer_info = &tx_ring->tx_buffer_info[i];
+			cleaned = (i == eop);
+
+			tx_ring->stats.bytes += tx_buffer_info->length;
+			ixgbe_unmap_and_free_tx_resource(adapter,
+							 tx_buffer_info);
+			tx_desc->wb.status = 0;
+
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+		}
+
+		tx_ring->stats.packets++;
+
+		eop = tx_ring->tx_buffer_info[i].next_to_watch;
+		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+	}
+
+	tx_ring->next_to_clean = i;
+
+	spin_lock(&tx_ring->tx_lock);
+
+	if (cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
+		netif_wake_queue(netdev);
+
+	spin_unlock(&tx_ring->tx_lock);
+
+	if (adapter->detect_tx_hung)
+		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
+			netif_stop_queue(netdev);
+
+	return cleaned;
+}
+
+/**
+ * ixgbe_receive_skb - Send a completed packet up the stack
+ * @adapter: board private structure
+ * @skb: packet to send up
+ * @is_vlan: packet has a VLAN tag
+ * @tag: VLAN tag from descriptor
+ **/
+static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
+			      struct sk_buff *skb, boolean_t is_vlan,
+			      u16 tag)
+{
+	if (!adapter->flags.in_netpoll) {
+		if (adapter->vlgrp && is_vlan)
+			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
+		else
+			netif_receive_skb(skb);
+	} else {
+
+		if (adapter->vlgrp && is_vlan)
+			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
+		else
+			netif_rx(skb);
+	}
+}
+
+static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
+					 u32 status_err,
+					 struct sk_buff *skb)
+{
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Ignore Checksum bit is set */
+	if ((status_err & IXGBE_RXD_STAT_IXSM) ||
+		     !adapter->flags.rx_csum_enabled)
+		return;
+	/* TCP/UDP checksum error bit is set */
+	if (status_err & (IXGBE_RXDADV_ERR_TCPE | IXGBE_RXDADV_ERR_IPE)) {
+		/* let the stack verify checksum errors */
+		adapter->hw_csum_rx_error++;
+		return;
+	}
+	/* It must be a TCP or UDP packet with a valid checksum */
+	if (status_err & (IXGBE_RXD_STAT_L4CS | IXGBE_RXD_STAT_UDPCS))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	adapter->hw_csum_rx_good++;
+}
+
+/**
+ * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
+ * @adapter: address of board private structure
+ **/
+static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
+				       struct ixgbe_ring *rx_ring,
+				       int cleaned_count)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	union ixgbe_adv_rx_desc *rx_desc;
+	struct ixgbe_rx_buffer *rx_buffer_info;
+	struct sk_buff *skb;
+	unsigned int i, ps_mode;
+	unsigned int bufsz = adapter->rx_buf_len + NET_IP_ALIGN;
+
+	i = rx_ring->next_to_use;
+	rx_buffer_info = &rx_ring->rx_buffer_info[i];
+	ps_mode = adapter->rx_buf_len == IXGBE_RX_HDR_SIZE;
+
+	while (cleaned_count--) {
+		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+
+		if (!rx_buffer_info->page && ps_mode) {
+			rx_buffer_info->page = alloc_page(GFP_ATOMIC);
+			if (!rx_buffer_info->page) {
+				adapter->alloc_rx_page_failed++;
+				goto no_buffers;
+			}
+			rx_buffer_info->page_dma =
+			    pci_map_page(pdev, rx_buffer_info->page,
+					 0, PAGE_SIZE, PCI_DMA_FROMDEVICE);
+		}
+
+		if (!rx_buffer_info->skb) {
+			skb = netdev_alloc_skb(netdev, bufsz);
+
+			if (!skb) {
+				adapter->alloc_rx_buff_failed++;
+				goto no_buffers;
+			}
+
+			/*
+			 * Make buffer alignment 2 beyond a 16 byte boundary
+			 * this will result in a 16 byte aligned IP header after
+			 * the 14 byte MAC header is removed
+			 */
+			skb_reserve(skb, NET_IP_ALIGN);
+
+			rx_buffer_info->skb = skb;
+			rx_buffer_info->dma = pci_map_single(pdev, skb->data,
+							  bufsz,
+							  PCI_DMA_FROMDEVICE);
+		}
+		/* Refresh the desc even if buffer_addrs didn't change because
+		 * each write-back erases this info. */
+		if (ps_mode) {
+			rx_desc->read.pkt_addr =
+			    cpu_to_le64(rx_buffer_info->page_dma);
+			rx_desc->read.hdr_addr =
+					cpu_to_le64(rx_buffer_info->dma);
+		} else {
+			rx_desc->read.pkt_addr =
+					cpu_to_le64(rx_buffer_info->dma);
+		}
+
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+		rx_buffer_info = &rx_ring->rx_buffer_info[i];
+	}
+no_buffers:
+	if (rx_ring->next_to_use != i) {
+		rx_ring->next_to_use = i;
+		if (i-- == 0)
+			i = (rx_ring->count - 1);
+
+		/*
+		 * Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+	}
+}
+
+static boolean_t ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
+					struct ixgbe_ring *rx_ring,
+					int *work_done, int work_to_do)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
+	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
+	struct sk_buff *skb;
+	unsigned int i;
+	u32 upper_len, len, staterr;
+	u16 hdr_info;
+	boolean_t ps_mode;
+	boolean_t cleaned = FALSE;
+	int cleaned_count = 0;
+
+	i = rx_ring->next_to_clean;
+	upper_len = 0;
+	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
+	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+	rx_buffer_info = &rx_ring->rx_buffer_info[i];
+	ps_mode = adapter->rx_buf_len == IXGBE_RX_HDR_SIZE;
+
+	while (staterr & IXGBE_RXD_STAT_DD) {
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+
+		if (ps_mode) {
+			hdr_info =
+			    le16_to_cpu(rx_desc->wb.lower.lo_dword.hdr_info);
+			len =
+			    ((hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
+			     IXGBE_RXDADV_HDRBUFLEN_SHIFT);
+			if (hdr_info & IXGBE_RXDADV_SPH)
+				adapter->rx_hdr_split++;
+			if (len > IXGBE_RX_HDR_SIZE)
+				len = IXGBE_RX_HDR_SIZE;
+			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
+		} else
+			len = le16_to_cpu(rx_desc->wb.upper.length);
+
+		cleaned = TRUE;
+		skb = rx_buffer_info->skb;
+		prefetch(skb->data - NET_IP_ALIGN);
+		rx_buffer_info->skb = NULL;
+
+		if (len && !skb_shinfo(skb)->nr_frags) {
+			pci_unmap_single(pdev, rx_buffer_info->dma,
+					 adapter->rx_buf_len + NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, len);
+		}
+
+		if (upper_len) {
+			pci_unmap_page(pdev, rx_buffer_info->page_dma,
+				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
+			rx_buffer_info->page_dma = 0;
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+					   rx_buffer_info->page, 0, upper_len);
+			rx_buffer_info->page = NULL;
+
+			skb->len += upper_len;
+			skb->data_len += upper_len;
+			skb->truesize += upper_len;
+		}
+
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+		next_buffer = &rx_ring->rx_buffer_info[i];
+
+		next_rxd = IXGBE_RX_DESC_ADV(*rx_ring, i);
+		prefetch(next_rxd);
+
+		cleaned_count++;
+		if (staterr & IXGBE_RXD_STAT_EOP) {
+			rx_ring->stats.packets++;
+			rx_ring->stats.bytes += skb->len;
+		} else {
+			rx_buffer_info->skb = next_buffer->skb;
+			rx_buffer_info->dma = next_buffer->dma;
+			next_buffer->skb = skb;
+			adapter->non_eop_descs++;
+			goto next_desc;
+		}
+
+		if (staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK) {
+			dev_kfree_skb_irq(skb);
+			goto next_desc;
+		}
+
+		ixgbe_rx_checksum(adapter, staterr, skb);
+		skb->protocol = eth_type_trans(skb, netdev);
+		ixgbe_receive_skb(adapter, skb, (staterr & IXGBE_RXD_STAT_VP),
+				  le16_to_cpu(rx_desc->wb.upper.vlan));
+		netdev->last_rx = jiffies;
+
+next_desc:
+		rx_desc->wb.upper.status_error = 0;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
+			ixgbe_alloc_rx_buffers(adapter, rx_ring,
+						   cleaned_count);
+			cleaned_count = 0;
+		}
+
+		/* use prefetched values */
+		rx_desc = next_rxd;
+		rx_buffer_info = next_buffer;
+
+		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+	}
+
+	rx_ring->next_to_clean = i;
+	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
+
+	if (cleaned_count)
+		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
+
+	return cleaned;
+}
+
+/**
+ * ixgbe_configure_msix - Configure MSI-X hardware
+ * @adapter: board private structure
+ *
+ * ixgbe_configure_msix sets up the hardware to properly generate MSI-X
+ * interrupts.
+ **/
+static void ixgbe_configure_msix(struct ixgbe_adapter *adapter)
+{
+	int i, vector = 0;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(i),
+			       IXGBE_MSIX_VECTOR(vector));
+		if (adapter->eitr != 0)
+			writel(1000000000 / (adapter->eitr * 256),
+			       adapter->hw.hw_addr +
+			       adapter->tx_ring[i].itr_register);
+		else
+			writel(0, adapter->hw.hw_addr +
+			       adapter->tx_ring[i].itr_register);
+		vector++;
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(i),
+			       IXGBE_MSIX_VECTOR(vector));
+		if (adapter->eitr != 0)
+			writel(1000000000 / (adapter->eitr * 256),
+			       adapter->hw.hw_addr +
+			       adapter->rx_ring[i].itr_register);
+		else
+			writel(0, adapter->hw.hw_addr +
+			       adapter->rx_ring[i].itr_register);
+		vector++;
+	}
+
+	vector = adapter->num_tx_queues + adapter->num_rx_queues;
+	ixgbe_set_ivar(adapter, IXGBE_IVAR_OTHER_CAUSES_INDEX,
+		       IXGBE_MSIX_VECTOR(vector));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EITR(vector), 1950);
+}
+
+#define IXGBE_MAX_INTR 10
+static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
+
+	if (eicr & IXGBE_EICR_LSC) {
+		adapter->lsc_int++;
+		mod_timer(&adapter->watchdog_timer, jiffies);
+	}
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
+{
+	struct ixgbe_ring *txr = data;
+	struct ixgbe_adapter *adapter = txr->adapter;
+	int i;
+
+	for (i = 0; i < IXGBE_MAX_INTR; i++) {
+		if (!ixgbe_clean_tx_irq(adapter, txr))
+			break;
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
+{
+	struct ixgbe_ring *rxr = data;
+	struct ixgbe_adapter *adapter = rxr->adapter;
+
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rxr->eims_value);
+	netif_rx_schedule(&rxr->netdev);
+	return IRQ_HANDLED;
+}
+
+static int ixgbe_clean_rxonly(struct net_device *netdev, int *budget)
+{
+	struct ixgbe_ring *rxr = netdev->priv;
+	struct ixgbe_adapter *adapter = rxr->adapter;
+	struct net_device *real_netdev = adapter->netdev;
+	int work_to_do = min(*budget, netdev->quota);
+	int work_done = 0;
+
+	/* Keep link state information with original netdev */
+	if (!netif_carrier_ok(real_netdev))
+		goto quit_polling;
+
+	ixgbe_clean_rx_irq(adapter, rxr, &work_done, work_to_do);
+
+	*budget -= work_done;
+	netdev->quota -= work_done;
+
+	/* If no Tx and not enough Rx work done, exit the polling mode */
+	if ((work_done == 0) || !netif_running(real_netdev)) {
+quit_polling:
+		netif_rx_complete(netdev);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, rxr->eims_value);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * ixgbe_setup_msix - Initialize MSI-X interrupts
+ *
+ * ixgbe_setup_msix allocates MSI-X vectors and requests
+ * interrutps from the kernel.
+ **/
+static int ixgbe_setup_msix(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int i, int_vector = 0, err = 0;
+	int max_msix_count;
+
+	/* +1 for the LSC interrupt */
+	max_msix_count = adapter->num_rx_queues + adapter->num_tx_queues + 1;
+	adapter->msix_entries = kcalloc(max_msix_count,
+					sizeof(struct msix_entry), GFP_KERNEL);
+	if (!adapter->msix_entries)
+		return -ENOMEM;
+
+	for (i = 0; i < max_msix_count; i++)
+		adapter->msix_entries[i].entry = i;
+
+	err = pci_enable_msix(adapter->pdev, adapter->msix_entries,
+			      max_msix_count);
+	if (err)
+		goto out;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		sprintf(adapter->tx_ring[i].name, "%s-tx%d", netdev->name, i);
+		err = request_irq(adapter->msix_entries[int_vector].vector,
+				  &ixgbe_msix_clean_tx,
+				  0,
+				  adapter->tx_ring[i].name,
+				  &(adapter->tx_ring[i]));
+		if (err) {
+			DPRINTK(PROBE, ERR,
+				"request_irq failed for MSIX interrupt "
+				"Error: %d\n", err);
+			goto release_irqs;
+		}
+		adapter->tx_ring[i].eims_value =
+		    (1 << IXGBE_MSIX_VECTOR(int_vector));
+		adapter->tx_ring[i].itr_register = IXGBE_EITR(int_vector);
+		adapter->tx_ring[i].itr_val = adapter->eitr;
+		int_vector++;
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		if (strlen(netdev->name) < (IFNAMSIZ - 5))
+			sprintf(adapter->rx_ring[i].netdev.name,
+				"%s-rx%d", netdev->name, i);
+		else
+			memcpy(adapter->rx_ring[i].netdev.name,
+			       netdev->name, IFNAMSIZ);
+		err = request_irq(adapter->msix_entries[int_vector].vector,
+				  &ixgbe_msix_clean_rx, 0,
+				  adapter->rx_ring[i].netdev.name,
+				  &(adapter->rx_ring[i]));
+		if (err) {
+			DPRINTK(PROBE, ERR,
+				"request_irq failed for MSIX interrupt "
+				"Error: %d\n", err);
+			goto release_irqs;
+		}
+
+		adapter->rx_ring[i].eims_value =
+		    (1 << IXGBE_MSIX_VECTOR(int_vector));
+		adapter->rx_ring[i].itr_register = IXGBE_EITR(int_vector);
+		adapter->rx_ring[i].itr_val = adapter->eitr;
+		int_vector++;
+	}
+
+	sprintf(adapter->lsc_name, "%s-lsc", netdev->name);
+	err = request_irq(adapter->msix_entries[int_vector].vector,
+			  &ixgbe_msix_lsc, 0, adapter->lsc_name, netdev);
+	if (err) {
+		DPRINTK(PROBE, ERR,
+			"request_irq for msix_lsc failed: %d\n", err);
+		goto release_irqs;
+	}
+
+	adapter->netdev->poll = ixgbe_clean_rxonly;
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		adapter->rx_ring[i].netdev.poll = ixgbe_clean_rxonly;
+	adapter->flags.msix_enabled = TRUE;
+	return 0;
+
+release_irqs:
+	int_vector--;
+	for (; int_vector >= adapter->num_tx_queues; int_vector--)
+		free_irq(adapter->msix_entries[int_vector].vector,
+			 &(adapter->rx_ring[int_vector -
+					    adapter->num_tx_queues]));
+
+	for (; int_vector >= 0; int_vector--)
+		free_irq(adapter->msix_entries[int_vector].vector,
+			 &(adapter->tx_ring[int_vector]));
+out:
+	kfree(adapter->msix_entries);
+	adapter->msix_entries = NULL;
+	adapter->flags.msix_enabled = FALSE;
+	return err;
+}
+
+/**
+ * ixgbe_intr - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ * @pt_regs: CPU registers structure
+ **/
+static irqreturn_t ixgbe_intr(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 eicr;
+
+	eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
+
+	if (!eicr)
+		return IRQ_NONE;	/* Not our interrupt */
+
+	if (eicr & IXGBE_EICR_LSC) {
+		adapter->lsc_int++;
+		mod_timer(&adapter->watchdog_timer, jiffies);
+	}
+	if (netif_rx_schedule_prep(netdev)) {
+		/* Disable interrupts and register for poll. The flush of the
+		 * posted write is intentionally left out. */
+		atomic_inc(&adapter->irq_sem);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+		__netif_rx_schedule(netdev);
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * ixgbe_request_irq - initialize interrupts
+ * @adapter: board private structure
+ *
+ * Attempts to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
+static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int flags, err;
+	irqreturn_t(*handler) (int, void *) = &ixgbe_intr;
+
+	flags = IRQF_SHARED;
+
+	if (adapter->flags.msix_capable) {
+		err = ixgbe_setup_msix(adapter);
+		if (!err)
+			goto request_done;
+	}
+
+	/*
+	 * if we can't do MSI-X, fall through and try MSI
+	 * No need to reallocate memory since we're decreasing the number of
+	 * queues. We just won't use the other ones, also it is freed correctly
+	 * on ixgbe_remove.
+	 */
+	adapter->num_rx_queues = 1;
+
+	/* do MSI */
+	if (adapter->flags.msi_capable) {
+		err = pci_enable_msi(adapter->pdev);
+		if (!err) {
+			adapter->flags.msi_enabled = TRUE;
+			flags &= ~IRQF_SHARED;
+			handler = &ixgbe_intr;
+		}
+	}
+
+	err = request_irq(adapter->pdev->irq, handler, flags,
+			  netdev->name, netdev);
+	if (err)
+		DPRINTK(PROBE, ERR, "request_irq failed, Error %d\n", err);
+
+request_done:
+	return err;
+}
+
+static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	if (adapter->flags.msix_enabled) {
+		int i;
+
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			free_irq(adapter->msix_entries[i].vector,
+				 &(adapter->tx_ring[i]));
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			free_irq(adapter->msix_entries[i +
+						adapter->num_tx_queues].vector,
+				&(adapter->rx_ring[i]));
+		i = adapter->num_rx_queues + adapter->num_tx_queues;
+		free_irq(adapter->msix_entries[i].vector, netdev);
+		pci_disable_msix(adapter->pdev);
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+		adapter->flags.msix_enabled = FALSE;
+		return;
+	}
+
+	free_irq(adapter->pdev->irq, netdev);
+	if (adapter->flags.msi_enabled) {
+		pci_disable_msi(adapter->pdev);
+		adapter->flags.msi_enabled = FALSE;
+	}
+}
+
+/**
+ * ixgbe_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
+{
+	atomic_inc(&adapter->irq_sem);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
+	synchronize_irq(adapter->pdev->irq);
+}
+
+/**
+ * ixgbe_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ **/
+static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
+{
+	if (atomic_dec_and_test(&adapter->irq_sem)) {
+		if (adapter->flags.msix_enabled) {
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
+					(IXGBE_EIMS_ENABLE_MASK &
+					 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
+		}
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
+				IXGBE_EIMS_ENABLE_MASK);
+		IXGBE_WRITE_FLUSH(&adapter->hw);
+	}
+}
+
+/**
+ * ixgbe_configure_msi_and_legacy - Initialize PIN (INTA...) and MSI interrupts
+ *
+ **/
+static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
+{
+	int i;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (adapter->eitr)
+		IXGBE_WRITE_REG(hw, IXGBE_EITR(0),
+				1000000000 / (adapter->eitr * 256));
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		ixgbe_set_ivar(adapter, IXGBE_IVAR_RX_QUEUE(i),
+			       IXGBE_MSIX_VECTOR(i));
+	}
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		ixgbe_set_ivar(adapter, IXGBE_IVAR_TX_QUEUE(i),
+			       IXGBE_MSIX_VECTOR(i));
+	}
+}
+
+/**
+ * ixgbe_configure_tx - Configure 8254x Transmit Unit after Reset
+ * @adapter: board private structure
+ *
+ * Configure the Tx unit of the MAC after a reset.
+ **/
+static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
+{
+	u64 tdba;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 i, tdlen;
+
+	/* Setup the HW Tx Head and Tail descriptor pointers */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		tdba = adapter->tx_ring[i].dma;
+		tdlen = adapter->tx_ring[i].count *
+		    sizeof(union ixgbe_adv_tx_desc);
+		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(i), (tdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(i), (tdba >> 32));
+		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(i), tdlen);
+		IXGBE_WRITE_REG(hw, IXGBE_TDH(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_TDT(i), 0);
+		adapter->tx_ring[i].head = IXGBE_TDH(i);
+		adapter->tx_ring[i].tail = IXGBE_TDT(i);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_TIPG, IXGBE_TIPG_FIBER_DEFAULT);
+
+	/* Setup Transmit Descriptor Settings for eop descriptor */
+	adapter->txd_cmd = IXGBE_TXD_CMD_EOP | IXGBE_TXD_CMD_RS |
+							IXGBE_TXD_CMD_IFCS;
+}
+
+#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
+			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+
+#define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
+/**
+ * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
+ * @adapter: board private structure
+ *
+ * Configure the Rx unit of the MAC after a reset.
+ **/
+static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
+{
+	u64 rdba;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 rdlen, rxctrl, rxcsum;
+	u32 random[10];
+	u32 reta, mrqc;
+	int i;
+	u32 fctrl, hlreg0;
+	u32 srrctl;
+	u32 pages, ps_mode;
+
+	ps_mode = adapter->rx_buf_len == IXGBE_RX_HDR_SIZE;
+
+	fctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
+	fctrl |= IXGBE_FCTRL_BAM;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, fctrl);
+
+	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
+	if (adapter->netdev->mtu <= ETH_DATA_LEN)
+		hlreg0 &= ~IXGBE_HLREG0_JUMBOEN;
+	else
+		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
+	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
+
+	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
+
+	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(0));
+	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
+	srrctl &= ~IXGBE_SRRCTL_BSIZEPKT_MASK;
+
+	if (ps_mode) {
+		srrctl |= PAGE_SIZE >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		srrctl |= IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+		srrctl |= ((IXGBE_RX_HDR_SIZE <<
+			    IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
+			   IXGBE_SRRCTL_BSIZEHDR_MASK);
+	} else {
+		srrctl |= IXGBE_RXBUFFER_2048 >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
+		srrctl |= IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF;
+	}
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(0), srrctl);
+
+	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
+	/* disable receives while setting up the descriptors */
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
+	rxctrl |= (IXGBE_RXCTRL_DMBYPS | IXGBE_RXCTRL_RXEN);
+
+	/* Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rdba = adapter->rx_ring[i].dma;
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(i), (rdba & DMA_32BIT_MASK));
+		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(i), (rdba >> 32));
+		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(i), rdlen);
+		IXGBE_WRITE_REG(hw, IXGBE_RDH(i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_RDT(i), 0);
+		adapter->rx_ring[i].head = IXGBE_RDH(i);
+		adapter->rx_ring[i].tail = IXGBE_RDT(i);
+	}
+
+	if (adapter->num_rx_queues > 1) {
+		/* Random 40bytes used as random key in RSS hash function */
+		get_random_bytes(&random[0], 40);
+
+		switch (adapter->num_rx_queues) {
+		case 8:
+		case 4:
+			/* Bits [3:0] in each byte refers the Rx queue no */
+			reta = 0x00010203;
+			break;
+		case 2:
+			reta = 0x00010001;
+			break;
+		default:
+			reta = 0x00000000;
+			break;
+		}
+
+		/* Fill out redirection table */
+		for (i = 0; i < 32; i++) {
+			IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RETA(0), i, reta);
+			if (adapter->num_rx_queues > 4) {
+				i++;
+				IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RETA(0), i,
+						      0x04050607);
+			}
+		}
+
+		/* Fill out hash function seeds */
+		for (i = 0; i < 10; i++)
+			IXGBE_WRITE_REG_ARRAY(hw, IXGBE_RSSRK(0), i, random[i]);
+
+		mrqc = IXGBE_MRQC_RSSEN
+		    /* Perform hash on these packet types */
+		    | IXGBE_MRQC_RSS_FIELD_IPV4
+		    | IXGBE_MRQC_RSS_FIELD_IPV4_TCP
+		    | IXGBE_MRQC_RSS_FIELD_IPV4_UDP
+		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP
+		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX
+		    | IXGBE_MRQC_RSS_FIELD_IPV6
+		    | IXGBE_MRQC_RSS_FIELD_IPV6_TCP
+		    | IXGBE_MRQC_RSS_FIELD_IPV6_UDP
+		    | IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP;
+		IXGBE_WRITE_REG(hw, IXGBE_MRQC, mrqc);
+
+		/* Multiqueue and packet checksumming are mutually exclusive. */
+		rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
+		rxcsum |= IXGBE_RXCSUM_PCSD;
+		IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
+	} else {
+		/* Enable Receive Checksum Offload for TCP and UDP */
+		rxcsum = IXGBE_READ_REG(hw, IXGBE_RXCSUM);
+		if (adapter->flags.rx_csum_enabled) {
+			/* Enable IPv4 payload checksum for UDP fragments
+			 * Must be used in conjunction with packet-split. */
+			rxcsum |= IXGBE_RXCSUM_IPPCSE;
+		} else {
+			/* don't need to clear IPPCSE as it defaults to 0 */
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
+	}
+	/* Enable Receives */
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl);
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+}
+
+static void ixgbe_vlan_rx_register(struct net_device *netdev,
+				   struct vlan_group *grp)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 ctrl;
+
+	ixgbe_irq_disable(adapter);
+	adapter->vlgrp = grp;
+
+	if (grp) {
+		/* enable VLAN tag insert/strip */
+		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
+		ctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
+		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+	}
+
+	ixgbe_irq_enable(adapter);
+}
+
+static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	/* add VID to filter table */
+	ixgbe_vfta_set(&adapter->hw, vid, 0, TRUE);
+}
+
+static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	ixgbe_irq_disable(adapter);
+	vlan_group_set_device(adapter->vlgrp, vid, NULL);
+	ixgbe_irq_enable(adapter);
+
+	/* remove VID from filter table */
+	ixgbe_vfta_set(&adapter->hw, vid, 0, FALSE);
+}
+
+static void ixgbe_restore_vlan(struct ixgbe_adapter *adapter)
+{
+	ixgbe_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+
+	if (adapter->vlgrp) {
+		u16 vid;
+		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+			if (!vlan_group_get_device(adapter->vlgrp, vid))
+				continue;
+			ixgbe_vlan_rx_add_vid(adapter->netdev, vid);
+		}
+	}
+}
+
+/**
+ * ixgbe_set_multi - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_multi entry point is called whenever the multicast address
+ * list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper multicast,
+ * promiscuous mode, and all-multi behavior.
+ **/
+static void ixgbe_set_multi(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct dev_mc_list *mc_ptr;
+	u8 *mta_list;
+	u32 fctrl;
+	int i;
+
+	/* Check for Promiscuous and All Multicast modes */
+
+	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+
+	if (netdev->flags & IFF_PROMISC) {
+		fctrl |= (IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+	} else if (netdev->flags & IFF_ALLMULTI) {
+		fctrl |= IXGBE_FCTRL_MPE;
+		fctrl &= ~IXGBE_FCTRL_UPE;
+	} else {
+		fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
+
+	if (netdev->mc_count) {
+		mta_list = kcalloc(netdev->mc_count, ETH_ALEN, GFP_ATOMIC);
+		if (!mta_list)
+			return;
+
+		/* Shared function expects packed array of only addresses. */
+		mc_ptr = netdev->mc_list;
+
+		for (i = 0; i < netdev->mc_count; i++) {
+			if (!mc_ptr)
+				break;
+			memcpy(mta_list + (i * ETH_ALEN), mc_ptr->dmi_addr,
+			       ETH_ALEN);
+			mc_ptr = mc_ptr->next;
+		}
+
+		ixgbe_mc_addr_list_update(hw, mta_list, i, 0);
+		kfree(mta_list);
+	} else {
+		ixgbe_mc_addr_list_update(hw, NULL, 0, 0);
+	}
+
+}
+
+int ixgbe_up(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int i;
+	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	u32 gpie;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 txdctl, rxdctl, mhadd;
+
+	/* hardware has been reset, we need to reload some things */
+	ixgbe_set_multi(netdev);
+
+	ixgbe_restore_vlan(adapter);
+
+	ixgbe_configure_tx(adapter);
+	ixgbe_configure_rx(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbe_alloc_rx_buffers(adapter, &adapter->rx_ring[i],
+					   (adapter->rx_ring[i].count - 1));
+
+	if (adapter->flags.msix_enabled || adapter->flags.msi_enabled) {
+		gpie = IXGBE_READ_REG(&adapter->hw, IXGBE_GPIE);
+		if (!adapter->flags.msi_enabled)
+			gpie |= IXGBE_GPIE_MSIX_MODE;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_GPIE,
+				(gpie | IXGBE_GPIE_EIAME |
+				 IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD));
+		gpie = IXGBE_READ_REG(&adapter->hw, IXGBE_GPIE);
+
+	}
+
+	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
+	if ((adapter->max_frame_size != max_frame) ||
+	    (adapter->max_frame_size != (mhadd >> IXGBE_MHADD_MFS_SHIFT))) {
+
+		adapter->max_frame_size = max_frame;
+
+		mhadd &= ~IXGBE_MHADD_MFS_MASK;
+		mhadd |= adapter->max_frame_size << IXGBE_MHADD_MFS_SHIFT;
+
+		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
+	}
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		txdctl = IXGBE_READ_REG(&adapter->hw, IXGBE_TXDCTL(i));
+		txdctl |= IXGBE_TXDCTL_ENABLE;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(i), txdctl);
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rxdctl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(i));
+		rxdctl |= IXGBE_RXDCTL_ENABLE;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(i), rxdctl);
+	}
+
+	mod_timer(&adapter->watchdog_timer, jiffies);
+
+	netif_poll_enable(netdev);
+	if (adapter->flags.msix_enabled)
+		ixgbe_configure_msix(adapter);
+	else
+		ixgbe_configure_msi_and_legacy(adapter);
+	ixgbe_irq_enable(adapter);
+
+	return 0;
+}
+
+void ixgbe_reset(struct ixgbe_adapter *adapter)
+{
+	/* Allow time for pending master requests to run */
+	ixgbe_hw_reset(&adapter->hw);
+
+	if (ixgbe_hw_init(&adapter->hw))
+		DPRINTK(PROBE, ERR, "Hardware Error\n");
+}
+
+/**
+ * ixgbe_clean_rx_ring - Free Rx Buffers per Queue
+ * @adapter: board private structure
+ * @rx_ring: ring to free buffers from
+ **/
+static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *rx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned long size;
+	unsigned int i;
+
+	/* Free all the Rx ring sk_buffs */
+
+	for (i = 0; i < rx_ring->count; i++) {
+		struct ixgbe_rx_buffer *rx_buffer_info;
+
+		rx_buffer_info = &rx_ring->rx_buffer_info[i];
+		if (rx_buffer_info->dma) {
+			pci_unmap_single(pdev, rx_buffer_info->dma,
+					 adapter->rx_buf_len,
+					 PCI_DMA_FROMDEVICE);
+			rx_buffer_info->dma = 0;
+		}
+		if (rx_buffer_info->skb) {
+			dev_kfree_skb(rx_buffer_info->skb);
+			rx_buffer_info->skb = NULL;
+		}
+		if (!rx_buffer_info->page)
+			continue;
+		pci_unmap_page(pdev, rx_buffer_info->page_dma, PAGE_SIZE,
+			       PCI_DMA_FROMDEVICE);
+		rx_buffer_info->page_dma = 0;
+
+		put_page(rx_buffer_info->page);
+		rx_buffer_info->page = NULL;
+	}
+
+	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
+	memset(rx_ring->rx_buffer_info, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(rx_ring->desc, 0, rx_ring->size);
+
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+
+	writel(0, adapter->hw.hw_addr + rx_ring->head);
+	writel(0, adapter->hw.hw_addr + rx_ring->tail);
+}
+
+/**
+ * ixgbe_clean_tx_ring - Free Tx Buffers
+ * @adapter: board private structure
+ * @tx_ring: ring to be cleaned
+ **/
+static void ixgbe_clean_tx_ring(struct ixgbe_adapter *adapter,
+				struct ixgbe_ring *tx_ring)
+{
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	unsigned long size;
+	unsigned int i;
+
+	/* Free all the Tx ring sk_buffs */
+
+	for (i = 0; i < tx_ring->count; i++) {
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
+	}
+
+	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
+	memset(tx_ring->tx_buffer_info, 0, size);
+
+	/* Zero out the descriptor ring */
+	memset(tx_ring->desc, 0, tx_ring->size);
+
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+
+	writel(0, adapter->hw.hw_addr + tx_ring->head);
+	writel(0, adapter->hw.hw_addr + tx_ring->tail);
+}
+
+/**
+ * ixgbe_clean_all_tx_rings - Free Tx Buffers for all queues
+ * @adapter: board private structure
+ **/
+static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		ixgbe_clean_tx_ring(adapter, &adapter->tx_ring[i]);
+}
+
+/**
+ * ixgbe_clean_all_rx_rings - Free Rx Buffers for all queues
+ * @adapter: board private structure
+ **/
+static void ixgbe_clean_all_rx_rings(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbe_clean_rx_ring(adapter, &adapter->rx_ring[i]);
+}
+
+void ixgbe_down(struct ixgbe_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	ixgbe_irq_disable(adapter);
+
+	del_timer_sync(&adapter->watchdog_timer);
+
+	netif_poll_disable(netdev);
+	adapter->link_speed = 0;
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	ixgbe_reset(adapter);
+	ixgbe_clean_all_tx_rings(adapter);
+	ixgbe_clean_all_rx_rings(adapter);
+
+}
+
+/**
+ * ixgbe_clean - NAPI Rx polling callback
+ * @adapter: board private structure
+ **/
+static int ixgbe_clean(struct net_device *poll_dev, int *budget)
+{
+	struct ixgbe_adapter *adapter;
+	int work_to_do = min(*budget, poll_dev->quota);
+	int tx_cleaned, i = 0, work_done = 0;
+
+	/* Must NOT use netdev_priv macro here. */
+	adapter = poll_dev->priv;
+
+	/* Keep link state information with original netdev */
+	if (!netif_carrier_ok(adapter->netdev))
+		goto quit_polling;
+
+
+	tx_cleaned = ixgbe_clean_tx_irq(adapter, &adapter->tx_ring[i]);
+	ixgbe_clean_rx_irq(adapter, &adapter->rx_ring[i],
+			       &work_done, work_to_do);
+
+	*budget -= work_done;
+	poll_dev->quota -= work_done;
+
+	/* If no Tx and not enough Rx work done, exit the polling mode */
+	if ((!tx_cleaned && (work_done == 0)) ||
+	    !netif_running(adapter->netdev)) {
+quit_polling:
+		netif_rx_complete(poll_dev);
+		ixgbe_irq_enable(adapter);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * ixgbe_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ **/
+static void ixgbe_tx_timeout(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->reset_task);
+}
+
+static void ixgbe_reset_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter;
+	adapter = container_of(work, struct ixgbe_adapter, reset_task);
+
+	adapter->tx_timeout_count++;
+
+	ixgbe_down(adapter);
+	ixgbe_up(adapter);
+}
+
+/**
+ * ixgbe_alloc_queues - Allocate memory for all rings
+ * @adapter: board private structure to initialize
+ *
+ * We allocate one ring per queue at run-time since we don't know the
+ * number of queues at compile-time.  The polling_netdev array is
+ * intended for Multiqueue, but should work fine with a single queue.
+ **/
+static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
+				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	if (!adapter->tx_ring)
+		return -ENOMEM;
+
+	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
+				   sizeof(struct ixgbe_ring), GFP_KERNEL);
+	if (!adapter->rx_ring) {
+		kfree(adapter->tx_ring);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		adapter->rx_ring[i].adapter = adapter;
+		adapter->rx_ring[i].itr_register = IXGBE_EITR(i);
+		adapter->rx_ring[i].netdev.priv =
+					(void *)(adapter->rx_ring + i);
+		adapter->rx_ring[i].netdev.poll = ixgbe_clean;
+		adapter->rx_ring[i].netdev.weight = 64;
+		dev_hold(&adapter->rx_ring[i].netdev);
+		set_bit(__LINK_STATE_START, &adapter->rx_ring[i].netdev.state);
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ * ixgbe_sw_init - Initialize general software structures (struct ixgbe_adapter)
+ * @adapter: board private structure to initialize
+ *
+ * ixgbe_sw_init initializes the Adapter private data structure.
+ * Fields are initialized based on PCI device information and
+ * OS network device settings (MTU size).
+ **/
+static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+
+	/* PCI config space info */
+
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_id = pdev->subsystem_device;
+
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+
+	adapter->rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
+	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+
+	if (ixgbe_init_shared_code(hw)) {
+		DPRINTK(PROBE, ERR, "Init_shared_code failed\n");
+		return -EIO;
+	}
+
+	hw->autoneg = TRUE;
+	hw->autoneg_wait_to_complete = FALSE;
+	hw->link_mode_select = IXGBE_AUTOC_LMS_10G_LINK_NO_AN;
+	if (ixgbe_hw_init(hw)) {
+		DPRINTK(PROBE, ERR, "HW Init failed\n");
+		return -EIO;
+	}
+	if (ixgbe_link_setup_speed(hw, IXGBE_LINK_SPEED_10GB_FULL, TRUE,
+								FALSE)) {
+		DPRINTK(PROBE, ERR, "link_setup_speed FAILED\n");
+		return -EIO;
+	}
+
+	/* initialize eeprom parameters */
+	if (ixgbe_eeprom_init_params(hw)) {
+		IXGBE_ERR("EEPROM initialization failed\n");
+		return -EIO;
+	}
+
+	/* Number of supported queues */
+	adapter->num_rx_queues = 8;
+	adapter->num_tx_queues = 1;
+
+	if (ixgbe_alloc_queues(adapter)) {
+		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		return -ENOMEM;
+	}
+
+	atomic_set(&adapter->irq_sem, 1);
+
+	return 0;
+}
+
+/**
+ * ixgbe_setup_tx_resources - allocate Tx resources (Descriptors)
+ * @adapter: board private structure
+ * @txdr:    tx descriptor ring (for a specific queue) to setup
+ *
+ * Return 0 on success, negative on failure
+ **/
+int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *txdr)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int size;
+
+	size = sizeof(struct ixgbe_tx_buffer) * txdr->count;
+	txdr->tx_buffer_info = vmalloc(size);
+	if (!txdr->tx_buffer_info) {
+		DPRINTK(PROBE, ERR,
+		"Unable to allocate memory for the transmit descriptor ring\n");
+		return -ENOMEM;
+	}
+	memset(txdr->tx_buffer_info, 0, size);
+
+	/* round up to nearest 4K */
+	txdr->size = txdr->count * sizeof(union ixgbe_adv_tx_desc);
+	txdr->size = ALIGN(txdr->size, 4096);
+
+	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+	if (!txdr->desc) {
+		vfree(txdr->tx_buffer_info);
+		DPRINTK(PROBE, ERR,
+			"Memory allocation failed for the tx desc ring\n");
+		return -ENOMEM;
+	}
+	memset(txdr->desc, 0, txdr->size);
+
+	txdr->adapter = adapter;
+	txdr->next_to_use = 0;
+	txdr->next_to_clean = 0;
+	spin_lock_init(&txdr->tx_lock);
+
+	return 0;
+}
+
+/**
+ * ixgbe_setup_rx_resources - allocate Rx resources (Descriptors)
+ * @adapter: board private structure
+ * @rxdr:    rx descriptor ring (for a specific queue) to setup
+ *
+ * Returns 0 on success, negative on failure
+ **/
+int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *rxdr)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int size, desc_len;
+
+	size = sizeof(struct ixgbe_rx_buffer) * rxdr->count;
+	rxdr->rx_buffer_info = vmalloc(size);
+	if (!rxdr->rx_buffer_info) {
+		DPRINTK(PROBE, ERR,
+			"vmalloc allocation failed for the rx desc ring\n");
+		return -ENOMEM;
+	}
+	memset(rxdr->rx_buffer_info, 0, size);
+
+	desc_len = sizeof(union ixgbe_adv_rx_desc);
+
+	/* Round up to nearest 4K */
+	rxdr->size = rxdr->count * desc_len;
+	rxdr->size = ALIGN(rxdr->size, 4096);
+
+	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+
+	if (!rxdr->desc) {
+		DPRINTK(PROBE, ERR,
+			"Memory allocation failed for the rx desc ring\n");
+		vfree(rxdr->rx_buffer_info);
+		return -ENOMEM;
+	}
+	memset(rxdr->desc, 0, rxdr->size);
+
+	rxdr->next_to_clean = 0;
+	rxdr->next_to_use = 0;
+	rxdr->adapter = adapter;
+	rxdr->netdev.priv = rxdr;
+	rxdr->netdev.poll = adapter->netdev->poll;
+	rxdr->netdev.weight = 64;
+
+	set_bit(__LINK_STATE_START, &rxdr->netdev.state);
+
+	return 0;
+}
+
+/**
+ * ixgbe_free_tx_resources - Free Tx Resources per Queue
+ * @adapter: board private structure
+ * @tx_ring: Tx descriptor ring for a specific queue
+ *
+ * Free all transmit software resources
+ **/
+void ixgbe_free_tx_resources(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *tx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	ixgbe_clean_tx_ring(adapter, tx_ring);
+
+	vfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info = NULL;
+
+	pci_free_consistent(pdev, tx_ring->size, tx_ring->desc, tx_ring->dma);
+
+	tx_ring->desc = NULL;
+}
+
+/**
+ * ixgbe_free_all_tx_resources - Free Tx Resources for All Queues
+ * @adapter: board private structure
+ *
+ * Free all transmit software resources
+ **/
+static void ixgbe_free_all_tx_resources(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		ixgbe_free_tx_resources(adapter, &adapter->tx_ring[i]);
+}
+
+/**
+ * ixgbe_free_rx_resources - Free Rx Resources
+ * @adapter: board private structure
+ * @rx_ring: ring to clean the resources from
+ *
+ * Free all receive software resources
+ **/
+static void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
+				    struct ixgbe_ring *rx_ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	ixgbe_clean_rx_ring(adapter, rx_ring);
+
+	vfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
+
+	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
+
+	rx_ring->desc = NULL;
+}
+
+/**
+ * ixgbe_free_all_rx_resources - Free Rx Resources for All Queues
+ * @adapter: board private structure
+ *
+ * Free all receive software resources
+ **/
+static void ixgbe_free_all_rx_resources(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbe_free_rx_resources(adapter, &adapter->rx_ring[i]);
+}
+
+/**
+ * ixgbe_setup_all_tx_resources - wrapper to allocate Tx resources
+ *				  (Descriptors) for all queues
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		err = ixgbe_setup_tx_resources(adapter, &adapter->tx_ring[i]);
+		if (err) {
+			DPRINTK(PROBE, ERR,
+				"Allocation for Tx Queue %u failed\n", i);
+			break;
+		}
+	}
+
+	return err;
+}
+
+/**
+ * ixgbe_setup_all_rx_resources - wrapper to allocate Rx resources
+ *				  (Descriptors) for all queues
+ * @adapter: board private structure
+ *
+ * If this function returns with an error, then it's possible one or
+ * more of the rings is populated (while the rest are not).  It is the
+ * callers duty to clean those orphaned rings.
+ *
+ * Return 0 on success, negative on failure
+ **/
+
+static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
+{
+	int i, err = 0;
+
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		err = ixgbe_setup_rx_resources(adapter, &adapter->rx_ring[i]);
+		if (err) {
+			DPRINTK(PROBE, ERR,
+				"Allocation for Rx Queue %u failed\n", i);
+			break;
+		}
+	}
+
+	return err;
+}
+
+/**
+ * ixgbe_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+
+	if ((max_frame < (ETH_ZLEN + ETH_FCS_LEN)) ||
+	    (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
+		return -EINVAL;
+
+	netdev->mtu = new_mtu;
+
+	if (netdev->mtu > 1500)
+		adapter->rx_buf_len = IXGBE_RX_HDR_SIZE;
+	else
+		adapter->rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
+	adapter->max_frame_size = max_frame;
+
+	if (netif_running(netdev)) {
+		ixgbe_down(adapter);
+		ixgbe_up(adapter);
+	}
+
+	return 0;
+}
+
+/**
+ * ixgbe_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ **/
+static int ixgbe_open(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int err;
+
+	/* must call request irq first to find out how many queues */
+	err = ixgbe_request_irq(adapter);
+	if (err)
+		goto err_req_irq;
+
+	/* allocate transmit descriptors */
+	err = ixgbe_setup_all_tx_resources(adapter);
+	if (err)
+		goto err_setup_tx;
+
+	/* allocate receive descriptors */
+	err = ixgbe_setup_all_rx_resources(adapter);
+	if (err)
+		goto err_setup_rx;
+
+	err = ixgbe_up(adapter);
+	if (err)
+		goto err_up;
+
+	return IXGBE_SUCCESS;
+
+err_up:
+	ixgbe_free_all_rx_resources(adapter);
+err_setup_rx:
+	ixgbe_free_all_tx_resources(adapter);
+err_setup_tx:
+	ixgbe_free_irq(adapter);
+err_req_irq:
+	ixgbe_reset(adapter);
+
+	return err;
+}
+
+/**
+ * ixgbe_close - Disables a network interface
+ * @netdev: network interface device structure
+ *
+ * Returns 0, this is not allowed to fail
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ **/
+static int ixgbe_close(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 ctrl_ext;
+
+	ixgbe_down(adapter);
+	ixgbe_free_irq(adapter);
+
+	ixgbe_free_all_tx_resources(adapter);
+	ixgbe_free_all_rx_resources(adapter);
+
+	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
+			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+
+	return 0;
+}
+
+/**
+ * ixgbe_update_stats - Update the board statistics counters.
+ * @adapter: board private structure
+ **/
+void ixgbe_update_stats(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 good_rx, missed_rx;
+
+	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
+	good_rx = IXGBE_READ_REG(hw, IXGBE_GPRC);
+	missed_rx = IXGBE_READ_REG(hw, IXGBE_MPC(0));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(1));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(2));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(3));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(4));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(5));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(6));
+	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(7));
+	adapter->stats.gprc += (good_rx - missed_rx);
+
+	adapter->stats.mpc[0] += missed_rx;
+	adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+	adapter->stats.bprc += IXGBE_READ_REG(hw, IXGBE_BPRC);
+	adapter->stats.mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
+	adapter->stats.roc += IXGBE_READ_REG(hw, IXGBE_ROC);
+	adapter->stats.prc64 += IXGBE_READ_REG(hw, IXGBE_PRC64);
+	adapter->stats.prc127 += IXGBE_READ_REG(hw, IXGBE_PRC127);
+	adapter->stats.prc255 += IXGBE_READ_REG(hw, IXGBE_PRC255);
+	adapter->stats.prc511 += IXGBE_READ_REG(hw, IXGBE_PRC511);
+	adapter->stats.prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
+	adapter->stats.prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
+
+	adapter->stats.rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
+	adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
+	adapter->stats.lxontxc += IXGBE_READ_REG(hw, IXGBE_LXONTXC);
+	adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
+	adapter->stats.lxofftxc += IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
+	adapter->stats.gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
+	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+	adapter->stats.rnbc[0] += IXGBE_READ_REG(hw, IXGBE_RNBC(0));
+	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
+	adapter->stats.rfc += IXGBE_READ_REG(hw, IXGBE_RFC);
+	adapter->stats.rjc += IXGBE_READ_REG(hw, IXGBE_RJC);
+	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
+	adapter->stats.tpr += IXGBE_READ_REG(hw, IXGBE_TPR);
+	adapter->stats.ptc64 += IXGBE_READ_REG(hw, IXGBE_PTC64);
+	adapter->stats.ptc127 += IXGBE_READ_REG(hw, IXGBE_PTC127);
+	adapter->stats.ptc255 += IXGBE_READ_REG(hw, IXGBE_PTC255);
+	adapter->stats.ptc511 += IXGBE_READ_REG(hw, IXGBE_PTC511);
+	adapter->stats.ptc1023 += IXGBE_READ_REG(hw, IXGBE_PTC1023);
+	adapter->stats.ptc1522 += IXGBE_READ_REG(hw, IXGBE_PTC1522);
+	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
+	adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
+
+	/* Fill out the OS statistics structure */
+	adapter->net_stats.rx_packets = adapter->stats.gprc;
+	adapter->net_stats.tx_packets = adapter->stats.gptc;
+	adapter->net_stats.rx_bytes = adapter->stats.gorc;
+	adapter->net_stats.tx_bytes = adapter->stats.gotc;
+	adapter->net_stats.multicast = adapter->stats.mprc;
+
+	/* Rx Errors */
+	adapter->net_stats.rx_errors = adapter->stats.crcerrs +
+						adapter->stats.rlec;
+	adapter->net_stats.rx_dropped = 0;
+	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
+	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
+	adapter->net_stats.rx_missed_errors = adapter->stats.mpc[0];
+
+}
+
+/**
+ * ixgbe_watchdog - Timer Call-back
+ * @data: pointer to adapter cast into an unsigned long
+ **/
+static void ixgbe_watchdog(unsigned long data)
+{
+	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
+	struct net_device *netdev = adapter->netdev;
+	boolean_t link_up;
+
+	ixgbe_link_check(&adapter->hw, &(adapter->link_speed), &link_up);
+
+	if (link_up) {
+		if (!netif_carrier_ok(netdev)) {
+			DPRINTK(LINK, INFO,
+				"NIC Link is Up %d Gbps Full Duplex\n",
+				((adapter->link_speed ==
+				  IXGBE_LINK_SPEED_10GB_FULL) ? 10 : 1));
+
+			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
+		}
+	} else {
+		if (netif_carrier_ok(netdev)) {
+			DPRINTK(LINK, INFO, "NIC Link is Down\n");
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+	}
+
+	ixgbe_update_stats(adapter);
+
+	/* Force detection of hung controller every watchdog period */
+	adapter->detect_tx_hung = TRUE;
+
+	/* Reset the timer */
+	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
+}
+
+#define IXGBE_MAX_TXD_PWR	14
+#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
+			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
+#define DESC_NEEDED TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1	/* for context */
+
+static int ixgbe_tso(struct ixgbe_adapter *adapter,
+			 struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+			 u32 tx_flags, u8 *hdr_len)
+{
+	struct ixgbe_adv_tx_context_desc *context_desc;
+	unsigned int i;
+	int err;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
+	u32 mss_l4len_idx = 0, l4len;
+	*hdr_len = 0;
+
+	if (skb_is_gso(skb)) {
+		if (skb_header_cloned(skb)) {
+			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (err)
+				return err;
+		}
+		l4len = tcp_hdrlen(skb);
+		*hdr_len += l4len;
+
+		if (skb->protocol == ntohs(ETH_P_IP)) {
+			struct iphdr *iph = ip_hdr(skb);
+			iph->tot_len = 0;
+			iph->check = 0;
+			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
+								 iph->daddr, 0,
+								 IPPROTO_TCP,
+								 0);
+			adapter->hw_tso_ctxt++;
+		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+			ipv6_hdr(skb)->payload_len = 0;
+			tcp_hdr(skb)->check =
+			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+					     &ipv6_hdr(skb)->daddr,
+					     0, IPPROTO_TCP, 0);
+			adapter->hw_tso6_ctxt++;
+		}
+
+		i = tx_ring->next_to_use;
+
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+
+		/* VLAN MACLEN IPLEN */
+		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
+			vlan_macip_lens |=
+			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
+		vlan_macip_lens |= ((skb_network_offset(skb)) <<
+				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		*hdr_len += skb_network_offset(skb);
+		vlan_macip_lens |=
+		    (skb_transport_header(skb) - skb_network_header(skb));
+		*hdr_len +=
+		    (skb_transport_header(skb) - skb_network_header(skb));
+		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
+		context_desc->seqnum_seed = 0;
+
+		/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
+		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
+				    IXGBE_ADVTXD_DTYP_CTXT);
+
+		if (skb->protocol == ntohs(ETH_P_IP))
+			type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
+		type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
+
+		/* MSS L4LEN IDX */
+		mss_l4len_idx |=
+		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
+		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
+		context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
+
+		tx_buffer_info->time_stamp = jiffies;
+		tx_buffer_info->next_to_watch = i;
+
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+		tx_ring->next_to_use = i;
+
+		return TRUE;
+	}
+	return FALSE;
+}
+
+static boolean_t ixgbe_tx_csum(struct ixgbe_adapter *adapter,
+				   struct ixgbe_ring *tx_ring,
+				   struct sk_buff *skb, u32 tx_flags)
+{
+	struct ixgbe_adv_tx_context_desc *context_desc;
+	unsigned int i;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	u32 vlan_macip_lens = 0, type_tucmd_mlhl = 0;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL ||
+	    (tx_flags & IXGBE_TX_FLAGS_VLAN)) {
+		i = tx_ring->next_to_use;
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		context_desc = IXGBE_TX_CTXTDESC_ADV(*tx_ring, i);
+
+		if (tx_flags & IXGBE_TX_FLAGS_VLAN)
+			vlan_macip_lens |=
+			    (tx_flags & IXGBE_TX_FLAGS_VLAN_MASK);
+		vlan_macip_lens |= (skb_network_offset(skb) <<
+				    IXGBE_ADVTXD_MACLEN_SHIFT);
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			vlan_macip_lens |= (skb_transport_header(skb) -
+					    skb_network_header(skb));
+
+		context_desc->vlan_macip_lens = cpu_to_le32(vlan_macip_lens);
+		context_desc->seqnum_seed = 0;
+
+		type_tucmd_mlhl |= (IXGBE_TXD_CMD_DEXT |
+				    IXGBE_ADVTXD_DTYP_CTXT);
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			if (skb->protocol == ntohs(ETH_P_IP))
+				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
+
+			if (skb->sk->sk_protocol == IPPROTO_TCP)
+				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+		}
+
+		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
+		context_desc->mss_l4len_idx = 0;
+
+		tx_buffer_info->time_stamp = jiffies;
+		tx_buffer_info->next_to_watch = i;
+		adapter->hw_csum_tx_good++;
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+		tx_ring->next_to_use = i;
+
+		return TRUE;
+	}
+	return FALSE;
+}
+
+static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
+			struct ixgbe_ring *tx_ring,
+			struct sk_buff *skb, unsigned int first)
+{
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	unsigned int len = skb->len;
+	unsigned int offset = 0, size, count = 0, i;
+	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned int f;
+
+	len -= skb->data_len;
+
+	i = tx_ring->next_to_use;
+
+	while (len) {
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
+
+		tx_buffer_info->length = size;
+		tx_buffer_info->dma = pci_map_single(adapter->pdev,
+						  skb->data + offset,
+						  size, PCI_DMA_TODEVICE);
+		tx_buffer_info->time_stamp = jiffies;
+		tx_buffer_info->next_to_watch = i;
+
+		len -= size;
+		offset += size;
+		count++;
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+	}
+
+	for (f = 0; f < nr_frags; f++) {
+		struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[f];
+		len = frag->size;
+		offset = frag->page_offset;
+
+		while (len) {
+			tx_buffer_info = &tx_ring->tx_buffer_info[i];
+			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
+
+			tx_buffer_info->length = size;
+			tx_buffer_info->dma = pci_map_page(adapter->pdev,
+							frag->page,
+							offset,
+							size, PCI_DMA_TODEVICE);
+			tx_buffer_info->time_stamp = jiffies;
+			tx_buffer_info->next_to_watch = i;
+
+			len -= size;
+			offset += size;
+			count++;
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+		}
+	}
+	if (i == 0)
+		i = tx_ring->count - 1;
+	else
+		i = i - 1;
+	tx_ring->tx_buffer_info[i].skb = skb;
+	tx_ring->tx_buffer_info[first].next_to_watch = i;
+
+	return count;
+}
+
+static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
+			       struct ixgbe_ring *tx_ring,
+			       int tx_flags, int count, u32 paylen, u8 hdr_len)
+{
+	union ixgbe_adv_tx_desc *tx_desc = NULL;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	u32 olinfo_status = 0, cmd_type_len = 0;
+	unsigned int i, first;
+
+	cmd_type_len |= IXGBE_ADVTXD_DTYP_DATA;
+
+	cmd_type_len |= IXGBE_ADVTXD_DCMD_IFCS | IXGBE_ADVTXD_DCMD_DEXT;
+
+	if (tx_flags & IXGBE_TX_FLAGS_VLAN)
+		cmd_type_len |= IXGBE_ADVTXD_DCMD_VLE;
+
+	if (tx_flags & IXGBE_TX_FLAGS_TSO) {
+		cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
+
+		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
+						IXGBE_ADVTXD_POPTS_SHIFT;
+
+		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
+			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
+						IXGBE_ADVTXD_POPTS_SHIFT;
+
+	} else if (tx_flags & IXGBE_TX_FLAGS_CSUM)
+		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
+						IXGBE_ADVTXD_POPTS_SHIFT;
+
+	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
+
+	i = tx_ring->next_to_use;
+	first = 1;
+	while (count--) {
+		tx_buffer_info = &tx_ring->tx_buffer_info[i];
+		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
+		tx_desc->read.buffer_addr = cpu_to_le64(tx_buffer_info->dma);
+		tx_desc->read.cmd_type_len =
+			cpu_to_le32(cmd_type_len | tx_buffer_info->length);
+		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
+
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+	}
+
+	tx_desc->read.cmd_type_len |= cpu_to_le32(adapter->txd_cmd);
+
+	/*
+	 * Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64).
+	 */
+	wmb();
+
+	tx_ring->next_to_use = i;
+	writel(i, adapter->hw.hw_addr + tx_ring->tail);
+}
+
+static int __ixgbe_maybe_stop_tx(struct net_device *netdev, int size)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_ring *tx_ring = adapter->tx_ring;
+
+	netif_stop_queue(netdev);
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (IXGBE_DESC_UNUSED(tx_ring) < size)
+		return -EBUSY;
+
+	/* A reprieve! */
+	netif_start_queue(netdev);
+	++adapter->restart_queue;
+	return 0;
+}
+
+static int ixgbe_maybe_stop_tx(struct net_device *netdev,
+			       struct ixgbe_ring *tx_ring, int size)
+{
+	if (IXGBE_DESC_UNUSED(tx_ring) >= size)
+		return 0;
+	return __ixgbe_maybe_stop_tx(netdev, size);
+}
+
+static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_ring *tx_ring;
+	unsigned int first;
+	unsigned int tx_flags = 0;
+	unsigned long flags = 0;
+	u8 hdr_len;
+	int tso;
+
+	tx_ring = adapter->tx_ring;
+
+	if (skb->len <= 0) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
+		/* Collision - tell upper layer to requeue */
+		return NETDEV_TX_LOCKED;
+
+	if (ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED)) {
+		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		tx_flags |= IXGBE_TX_FLAGS_VLAN;
+		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
+	}
+
+	if (skb->protocol == ntohs(ETH_P_IP))
+		tx_flags |= IXGBE_TX_FLAGS_IPV4;
+	first = tx_ring->next_to_use;
+	tso = ixgbe_tso(adapter, tx_ring, skb, tx_flags, &hdr_len);
+	if (tso < 0) {
+		dev_kfree_skb_any(skb);
+		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+		return NETDEV_TX_OK;
+	}
+
+	if (tso)
+		tx_flags |= IXGBE_TX_FLAGS_TSO;
+	else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
+		 (skb->ip_summed == CHECKSUM_PARTIAL))
+		tx_flags |= IXGBE_TX_FLAGS_CSUM;
+
+	ixgbe_tx_queue(adapter, tx_ring, tx_flags,
+			   ixgbe_tx_map(adapter, tx_ring, skb, first),
+			   skb->len, hdr_len);
+
+	netdev->trans_start = jiffies;
+
+	/* Make sure there is space in the ring for the next send. */
+	ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
+
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+/**
+ * ixgbe_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ **/
+static struct net_device_stats *ixgbe_get_stats(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	/* only return the current stats */
+	return &adapter->net_stats;
+}
+
+/**
+ * ixgbe_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: network interface device structure
+ * @p: pointer to an address structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int ixgbe_set_mac(struct net_device *netdev, void *p)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adapter->hw.curr_mac_addr, addr->sa_data, netdev->addr_len);
+
+	ixgbe_rar_set(&adapter->hw, 0, adapter->hw.curr_mac_addr, 0, 1);
+	adapter->hw.addr_ctrl.rar_used_count = 1;
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void ixgbe_netpoll(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	disable_irq(adapter->pdev->irq);
+	adapter->flags.in_netpoll = 1;
+	ixgbe_intr(adapter->pdev->irq, netdev);
+	adapter->flags.in_netpoll = 0;
+	enable_irq(adapter->pdev->irq);
+}
+#endif
+
+/**
+ * ixgbe_probe - Device Initialization Routine
+ * @pdev: PCI device information struct
+ * @ent: entry in ixgbe_pci_tbl
+ *
+ * Returns 0 on success, negative on failure
+ *
+ * ixgbe_probe initializes an adapter identified by a pci_dev structure.
+ * The OS initialization, configuring of the adapter private structure,
+ * and a hardware reset occur.
+ **/
+static int __devinit ixgbe_probe(struct pci_dev *pdev,
+				 const struct pci_device_id *ent)
+{
+	struct net_device *netdev;
+	struct ixgbe_adapter *adapter = NULL;
+	unsigned long mmio_start, mmio_len;
+	u32 ctrl_ext;
+	static int cards_found;
+	int i, err, pci_using_dac;
+	struct ixgbe_hw *hw;
+
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+
+	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
+		pci_using_dac = 1;
+	} else {
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (err) {
+			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			if (err) {
+				IXGBE_ERR("No usable DMA configuration,"
+					  "aborting\n");
+				goto err_dma;
+			}
+		}
+		pci_using_dac = 0;
+	}
+
+	err = pci_request_regions(pdev, ixgbe_driver_name);
+	if (err) {
+		IXGBE_ERR("pci_request_regions failed 0x%x\n", err);
+		goto err_pci_reg;
+	}
+
+	pci_set_master(pdev);
+
+	netdev = alloc_etherdev(sizeof(struct ixgbe_adapter));
+	if (!netdev) {
+		err = -ENOMEM;
+		goto err_alloc_etherdev;
+	}
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	pci_set_drvdata(pdev, netdev);
+	adapter = netdev_priv(netdev);
+
+	adapter->netdev = netdev;
+	adapter->pdev = pdev;
+	hw = &adapter->hw;
+	hw->back = adapter;
+	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+
+	mmio_start = pci_resource_start(pdev, 0);
+	mmio_len = pci_resource_len(pdev, 0);
+
+	hw->hw_addr = ioremap(mmio_start, mmio_len);
+	if (!hw->hw_addr) {
+		err = -EIO;
+		goto err_ioremap;
+	}
+
+	for (i = 1; i <= 5; i++) {
+		if (pci_resource_len(pdev, i) == 0)
+			continue;
+		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+			adapter->io_base = pci_resource_start(pdev, i);
+			break;
+		}
+	}
+
+	netdev->open = &ixgbe_open;
+	netdev->stop = &ixgbe_close;
+	netdev->hard_start_xmit = &ixgbe_xmit_frame;
+	netdev->get_stats = &ixgbe_get_stats;
+	netdev->set_multicast_list = &ixgbe_set_multi;
+	netdev->set_mac_address = &ixgbe_set_mac;
+	netdev->change_mtu = &ixgbe_change_mtu;
+	ixgbe_set_ethtool_ops(netdev);
+	netdev->tx_timeout = &ixgbe_tx_timeout;
+	netdev->watchdog_timeo = 5 * HZ;
+	netdev->poll = &ixgbe_clean;
+	netdev->weight = 64;
+	netdev->vlan_rx_register = ixgbe_vlan_rx_register;
+	netdev->vlan_rx_add_vid = ixgbe_vlan_rx_add_vid;
+	netdev->vlan_rx_kill_vid = ixgbe_vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller = ixgbe_netpoll;
+#endif
+	strcpy(netdev->name, pci_name(pdev));
+
+	netdev->mem_start = mmio_start;
+	netdev->mem_end = mmio_start + mmio_len;
+	netdev->base_addr = adapter->io_base;
+
+	adapter->bd_number = cards_found;
+
+	/* setup the private structure */
+	err = ixgbe_sw_init(adapter);
+	if (err)
+		goto err_sw_init;
+
+	netdev->features = NETIF_F_SG |
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_HW_VLAN_FILTER;
+
+	netdev->features |= NETIF_F_TSO;
+
+	netdev->features |= NETIF_F_TSO6;
+	if (pci_using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
+
+	netdev->features |= NETIF_F_LLTX;
+
+	/* make sure the EEPROM is good */
+	if (ixgbe_eeprom_validate_checksum(hw, NULL) < 0) {
+		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+		err = -EIO;
+		goto err_eeprom;
+	}
+
+	/* copy the MAC address out of the RAR[0] */
+	if (ixgbe_adapter_get_mac_addr(hw, hw->perm_mac_addr))
+		DPRINTK(PROBE, ERR, "Mac Addr Read from RAR Error\n");
+
+	memcpy(netdev->dev_addr, hw->perm_mac_addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, hw->perm_mac_addr, netdev->addr_len);
+
+	if (ixgbe_mac_addr_valid(netdev->perm_addr)) {
+		err = -EIO;
+		goto err_eeprom;
+	}
+
+	ixgbe_adapter_determine_bus_info(hw);
+
+	init_timer(&adapter->watchdog_timer);
+	adapter->watchdog_timer.function = &ixgbe_watchdog;
+	adapter->watchdog_timer.data = (unsigned long)adapter;
+
+	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
+
+	ixgbe_check_options(adapter);
+
+	/* print bus type/speed/width info */
+	DPRINTK(PROBE, INFO, "(PCI Express:%s:%s) \n",
+		((hw->bus.speed == ixgbe_bus_speed_2500) ? "2.5Gb/s":"Unknown"),
+		 (hw->bus.width == ixgbe_bus_width_pciex_8) ? "Width x8" :
+		 (hw->bus.width == ixgbe_bus_width_pciex_4) ? "Width x4" :
+		 (hw->bus.width == ixgbe_bus_width_pciex_1) ? "Width x1" :
+		 ("Unknown"));
+
+	/* reset the hardware with the new settings */
+	ixgbe_reset(adapter);
+
+	/* Let firmware know the driver has taken over */
+	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
+
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+	netif_poll_disable(netdev);
+
+	strcpy(netdev->name, "eth%d");
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+
+	cards_found++;
+	return 0;
+
+err_register:
+err_sw_init:
+err_eeprom:
+	iounmap(hw->hw_addr);
+err_ioremap:
+	free_netdev(netdev);
+err_alloc_etherdev:
+	pci_release_regions(pdev);
+err_pci_reg:
+err_dma:
+	pci_disable_device(pdev);
+	return err;
+}
+
+/**
+ * ixgbe_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ *
+ * ixgbe_remove is called by the PCI subsystem to alert the driver
+ * that it should release a PCI device.  The could be caused by a
+ * Hot-Plug event, or because the driver is going to be removed from
+ * memory.
+ **/
+static void __devexit ixgbe_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+
+	iounmap(adapter->hw.hw_addr);
+	pci_release_regions(pdev);
+
+	free_netdev(netdev);
+}
+
+u16 ixgbe_read_pci_cfg_word(struct ixgbe_hw *hw, u32 reg)
+{
+	u16 value;
+	struct ixgbe_adapter *adapter = hw->back;
+
+	pci_read_config_word(adapter->pdev, reg, &value);
+	return value;
+}
+
+static struct pci_driver ixgbe_driver = {
+	.name     = ixgbe_driver_name,
+	.id_table = ixgbe_pci_tbl,
+	.probe    = ixgbe_probe,
+	.remove   = __devexit_p(ixgbe_remove),
+};
+
+/**
+ * ixgbe_init_module - Driver Registration Routine
+ *
+ * ixgbe_init_module is the first routine called when the driver is
+ * loaded. All it does is register with the PCI subsystem.
+ **/
+static int __init ixgbe_init_module(void)
+{
+	int ret;
+	printk(KERN_INFO "%s - version %s\n", ixgbe_driver_string,
+	       ixgbe_driver_version);
+
+	printk(KERN_INFO "%s\n", ixgbe_copyright);
+
+	ret = pci_register_driver(&ixgbe_driver);
+	return ret;
+}
+module_init(ixgbe_init_module);
+
+/**
+ * ixgbe_exit_module - Driver Exit Cleanup Routine
+ *
+ * ixgbe_exit_module is called just before the driver is removed
+ * from memory.
+ **/
+static void __exit ixgbe_exit_module(void)
+{
+	pci_unregister_driver(&ixgbe_driver);
+}
+module_exit(ixgbe_exit_module);
+
+/* ixgbe_main.c */
diff --git a/drivers/net/ixgbe/ixgbe_osdep.h b/drivers/net/ixgbe/ixgbe_osdep.h
new file mode 100644
index 0000000..70b35d7
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_osdep.h
@@ -0,0 +1,76 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+/* glue for the OS independent part of ixgbe
+ * includes register access macros
+ */
+
+#ifndef _IXGBE_OSDEP_H_
+#define _IXGBE_OSDEP_H_
+
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/if_ether.h>
+
+#include <linux/sched.h>
+
+typedef enum {
+#undef FALSE
+	FALSE = 0,
+#undef TRUE
+	TRUE = 1
+} boolean_t;
+
+#define DEBUGOUT(S)             do {} while (0)
+#define DEBUGOUT1(S, A...)      do {} while (0)
+
+#define DEBUGFUNC(F) DEBUGOUT(F)
+#define DEBUGOUT2 DEBUGOUT1
+#define DEBUGOUT3 DEBUGOUT2
+#define DEBUGOUT6 DEBUGOUT3
+#define DEBUGOUT7 DEBUGOUT6
+
+#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
+
+#define IXGBE_READ_REG(a, reg) readl((a)->hw_addr + (reg))
+
+#define IXGBE_WRITE_REG_ARRAY(a, reg, offset, value) ( \
+    writel((value), ((a)->hw_addr + (reg) + ((offset) << 2))))
+
+#define IXGBE_READ_REG_ARRAY(a, reg, offset) ( \
+    readl((a)->hw_addr + (reg) + ((offset) << 2)))
+
+#define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
+struct ixgbe_hw;
+extern u16 ixgbe_read_pci_cfg_word(struct ixgbe_hw *hw, u32 reg);
+#define IXGBE_READ_PCIE_WORD ixgbe_read_pci_cfg_word
+#define IXGBE_EEPROM_GRANT_ATTEMPS 100
+
+#endif /* _IXGBE_OSDEP_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_param.c b/drivers/net/ixgbe/ixgbe_param.c
new file mode 100644
index 0000000..3b7f866
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_param.c
@@ -0,0 +1,510 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe.h"
+
+/* This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+
+#define IXGBE_MAX_NIC 8
+
+#define OPTION_UNSET    -1
+#define OPTION_DISABLED 0
+#define OPTION_ENABLED  1
+
+/* All parameters are treated the same, as an integer array of values.
+ * This macro just reduces the need to repeat the same declaration code
+ * over and over (plus this helps to avoid typo bugs).
+ */
+
+#define IXGBE_PARAM_INIT { [0 ... IXGBE_MAX_NIC] = OPTION_UNSET }
+#define IXGBE_PARAM(X, desc) \
+	static int __devinitdata X[IXGBE_MAX_NIC+1] = IXGBE_PARAM_INIT; \
+	static int num_##X; \
+	module_param_array_named(X, X, int, &num_##X, 0); \
+	MODULE_PARM_DESC(X, desc);
+
+/* Interrupt type
+ *
+ * Valid Range: 0-2 0 = Legacy Int, 1 = MSI and 2 = MSIX
+ *
+ * Default Value: 2
+ */
+IXGBE_PARAM(InterruptType, "Interrupt Type");
+
+/* Rx Queues count
+ *
+ * Valid Range: 1-8
+ *
+ * Default Value: 8
+ */
+IXGBE_PARAM(RxQueues, "Number of RX queues");
+
+/* Transmit Descriptor Count
+ *
+ * Valid Range: 64-4096
+ *
+ * Default Value: 1024
+ */
+IXGBE_PARAM(TxDescriptors, "Number of transmit descriptors");
+
+/* Receive Descriptor Count
+ *
+ * Valid Range: 64-4096
+ *
+ * Default Value: 1024
+ */
+IXGBE_PARAM(RxDescriptors, "Number of receive descriptors");
+
+/* User Specified Flow Control Override
+ *
+ * Valid Range: 0-3
+ *  - 0 - No Flow Control
+ *  - 1 - Rx only, respond to PAUSE frames but do not generate them
+ *  - 2 - Tx only, generate PAUSE frames but ignore them on receive
+ *  - 3 - Full Flow Control Support
+ *
+ * Default Value: 1 - Rx only (silicon transmit bug avoidance)
+ */
+IXGBE_PARAM(FlowControl, "Flow Control setting");
+
+/* XsumRX - Receive Checksum Offload Enable/Disable
+ *
+ * Valid Range: 0, 1
+ *  - 0 - disables all checksum offload
+ *  - 1 - enables receive IP/TCP/UDP checksum offload
+ *        on 82597 based NICs
+ *
+ * Default Value: 1
+ */
+IXGBE_PARAM(XsumRX, "Disable or enable Receive Checksum offload");
+
+/* Receive Flow control high threshold (when we send a pause frame)
+ * (FCRTH)
+ *
+ * Valid Range: 1,536 - 262,136 (0x600 - 0x3FFF8, 8 byte granularity)
+ *
+ * Default Value: 196,608 (0x30000)
+ */
+IXGBE_PARAM(RxFCHighThresh, "Receive Flow Control High Threshold");
+
+/* Receive Flow control low threshold (when we send a resume frame)
+ * (FCRTL)
+ *
+ * Valid Range: 64 - 262,136 (0x40 - 0x3FFF8, 8 byte granularity)
+ *              must be less than high threshold by at least 8 bytes
+ *
+ * Default Value:  163,840 (0x28000)
+ */
+IXGBE_PARAM(RxFCLowThresh, "Receive Flow Control Low Threshold");
+
+/* Flow control request timeout (how long to pause the link partner's tx)
+ * (PAP 15:0)
+ *
+ * Valid Range: 1 - 65535
+ *
+ * Default Value:  65535 (0xffff) (we'll send an xon if we recover)
+ */
+IXGBE_PARAM(FCReqTimeout, "Flow Control Request Timeout");
+
+/* Interrupt Throttle Rate (interrupts/sec)
+ *
+ * Valid Range: 100-100000 (0=off)
+ *
+ * Default Value: 8000
+ */
+IXGBE_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
+
+
+#define IXGBE_INT_LEGACY		      0
+#define IXGBE_INT_MSI			      1
+#define IXGBE_INT_MSIX			      2
+#define IXGBE_DEFAULT_INT	 IXGBE_INT_MSIX
+
+#define DEFAULT_ITR			   8000
+#define MAX_ITR				 500000
+#define MIN_ITR				    100
+
+#define XSUMRX_DEFAULT		 OPTION_ENABLED
+
+#define DEFAULT_FCRTL			0x10000
+#define DEFAULT_FCRTH			0x20000
+#define MIN_FCRTL			      0
+#define MAX_FCRTL			0x7FF80
+#define MIN_FCRTH			      0
+#define MAX_FCRTH			0x7FFF0
+
+#define DEFAULT_FCPAUSE			 0x6800  /* this may be too long */
+#define MIN_FCPAUSE			      0
+#define MAX_FCPAUSE			 0xFFFF
+
+struct ixgbe_option {
+	enum { enable_option, range_option, list_option } type;
+	char *name;
+	char *err;
+	int def;
+	union {
+		struct { /* range_option info */
+			int min;
+			int max;
+		} r;
+		struct { /* list_option info */
+			int nr;
+			struct ixgbe_opt_list {
+				int i;
+				char *str;
+			} *p;
+		} l;
+	} arg;
+};
+
+static int __devinit ixgbe_validate_option(int *value, struct ixgbe_option *opt)
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
+			printk(KERN_INFO "%s Enabled\n", opt->name);
+			return 0;
+		case OPTION_DISABLED:
+			printk(KERN_INFO "%s Disabled\n", opt->name);
+			return 0;
+		}
+		break;
+	case range_option:
+		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+			printk(KERN_INFO "%s set to %i\n", opt->name, *value);
+			return 0;
+		}
+		break;
+	case list_option:{
+			int i;
+			struct ixgbe_opt_list *ent;
+
+			for (i = 0; i < opt->arg.l.nr; i++) {
+				ent = &opt->arg.l.p[i];
+				if (*value == ent->i) {
+					if (ent->str[0] != '\0')
+						printk(KERN_INFO "%s\n",
+						       ent->str);
+					return 0;
+				}
+			}
+		}
+		break;
+	default:
+		BUG();
+	}
+
+	printk(KERN_INFO "Invalid %s specified (%i) %s\n",
+	       opt->name, *value, opt->err);
+	*value = opt->def;
+	return -1;
+}
+
+#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
+
+/**
+ * ixgbe_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ **/
+void __devinit ixgbe_check_options(struct ixgbe_adapter *adapter)
+{
+	int bd = adapter->bd_number, i;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	if (bd >= IXGBE_MAX_NIC) {
+		printk(KERN_NOTICE
+		       "Warning: no configuration for board #%i\n", bd);
+		printk(KERN_NOTICE "Using defaults for all values\n");
+	}
+
+	{ /* Interrupt Type */
+		int int_type;
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Interrupt Type",
+			.err = "using default of "
+					__MODULE_STRING(IXGBE_DEFAULT_INT),
+			.def = IXGBE_DEFAULT_INT,
+			.arg = {.r = {.min = IXGBE_INT_LEGACY,
+				      .max = IXGBE_INT_MSIX}}
+		};
+
+		if (num_InterruptType > bd) {
+			int_type = InterruptType[bd];
+			ixgbe_validate_option(&int_type, &opt);
+			switch (int_type) {
+			case 2:
+				adapter->flags.msix_capable = TRUE;
+				adapter->flags.msi_capable = TRUE;
+				break;
+			case 1:
+				adapter->flags.msi_capable = TRUE;
+				break;
+			case 0:
+			default:
+				break;
+			}
+		} else {
+			adapter->flags.msix_capable = TRUE;
+			adapter->flags.msi_capable = TRUE;
+		}
+	}
+	{ /* Receive Queues Count */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Receive Queues",
+			.err = "using default of "
+					__MODULE_STRING(IXGBE_DEFAULT_RXQ),
+			.def = IXGBE_DEFAULT_RXQ,
+			.arg = {.r = {.min = IXGBE_MIN_RXQ,
+				      .max = IXGBE_MAX_RXQ}}
+		};
+
+		if (num_RxQueues > bd) {
+			adapter->num_rx_queues = RxQueues[bd];
+			ixgbe_validate_option(&adapter->num_rx_queues, &opt);
+			adapter->num_rx_queues =
+			    ALIGN(adapter->num_rx_queues, 2);
+		} else {
+			adapter->num_rx_queues = opt.def;
+		}
+	}
+	{ /* Transmit Descriptor Count */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Transmit Descriptors",
+			.err = "using default of "
+					__MODULE_STRING(IXGBE_DEFAULT_TXD),
+			.def = IXGBE_DEFAULT_TXD,
+			.arg = {.r = {.min = IXGBE_MIN_TXD,
+				      .max = IXGBE_MAX_TXD}}
+		};
+		struct ixgbe_ring *tx_ring = adapter->tx_ring;
+
+		if (num_TxDescriptors > bd) {
+			tx_ring->count = TxDescriptors[bd];
+			ixgbe_validate_option(&tx_ring->count, &opt);
+			tx_ring->count = ALIGN(tx_ring->count,
+					      IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE);
+		} else {
+			tx_ring->count = opt.def;
+		}
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			tx_ring[i].count = tx_ring->count;
+	}
+	{ /* Receive Descriptor Count */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Receive Descriptors",
+			.err = "using default of "
+					__MODULE_STRING(IXGBE_DEFAULT_RXD),
+			.def = IXGBE_DEFAULT_RXD,
+			.arg = {.r = {.min = IXGBE_MIN_RXD,
+				      .max = IXGBE_MAX_RXD}}
+		};
+		struct ixgbe_ring *rx_ring = adapter->rx_ring;
+
+		if (num_RxDescriptors > bd) {
+			rx_ring->count = RxDescriptors[bd];
+			ixgbe_validate_option(&rx_ring->count, &opt);
+			rx_ring->count = ALIGN(rx_ring->count,
+					      IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE);
+		} else {
+			rx_ring->count = opt.def;
+		}
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			rx_ring[i].count = rx_ring->count;
+	}
+	{ /* Receive Checksum Offload Enable */
+		struct ixgbe_option opt = {
+			.type = enable_option,
+			.name = "Receive Checksum Offload",
+			.err = "defaulting to Enabled",
+			.def = OPTION_ENABLED
+		};
+
+		if (num_XsumRX > bd) {
+			int rx_csum = XsumRX[bd];
+			ixgbe_validate_option(&rx_csum, &opt);
+			adapter->flags.rx_csum_enabled = rx_csum;
+		} else {
+			adapter->flags.rx_csum_enabled = opt.def;
+		}
+	}
+	{ /* Flow Control */
+
+		struct ixgbe_opt_list fc_list[] =
+			{{ ixgbe_fc_none,     "Flow Control Disabled" },
+			 { ixgbe_fc_rx_pause, "Flow Control Receive Only" },
+			 { ixgbe_fc_tx_pause, "Flow Control Transmit Only" },
+			 { ixgbe_fc_full,     "Flow Control Enabled" }
+			 };
+
+		struct ixgbe_option opt = {
+			.type = list_option,
+			.name = "Flow Control",
+			.err = "Flow Control enabled by default",
+			.def = ixgbe_fc_full,
+			.arg = {.l = {.nr = LIST_LEN(fc_list),
+				      .p = fc_list}}
+		};
+
+		if (num_FlowControl > bd) {
+			int fc = FlowControl[bd];
+			ixgbe_validate_option(&fc, &opt);
+			hw->fc.original_type = fc;
+			hw->fc.type = fc;
+		} else {
+			hw->fc.original_type = opt.def;
+			hw->fc.type = opt.def;
+		}
+	}
+	{ /* Receive Flow Control High Threshold */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Rx Flow Control High Threshold",
+			.err =
+			    "using default of " __MODULE_STRING(DEFAULT_FCRTH),
+			.def = DEFAULT_FCRTH,
+			.arg = {.r = {.min = MIN_FCRTH,
+				      .max = MAX_FCRTH}}
+		};
+
+		if (num_RxFCHighThresh > bd) {
+			hw->fc.high_water = RxFCHighThresh[bd];
+			ixgbe_validate_option(&hw->fc.high_water, &opt);
+		} else {
+			hw->fc.high_water = opt.def;
+		}
+		if (!(hw->fc.type & ixgbe_fc_tx_pause))
+			printk(KERN_INFO
+			       "Ignoring RxFCHighThresh when no RxFC\n");
+	}
+	{ /* Receive Flow Control Low Threshold */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Rx Flow Control Low Threshold",
+			.err =
+			    "using default of " __MODULE_STRING(DEFAULT_FCRTL),
+			.def = DEFAULT_FCRTL,
+			.arg = {.r = {.min = MIN_FCRTL,
+				      .max = MAX_FCRTL}}
+		};
+
+		if (num_RxFCLowThresh > bd) {
+			hw->fc.low_water = RxFCLowThresh[bd];
+			ixgbe_validate_option(&hw->fc.low_water, &opt);
+		} else {
+			hw->fc.low_water = opt.def;
+		}
+		if (!(hw->fc.type & ixgbe_fc_tx_pause))
+			printk(KERN_INFO
+			       "Ignoring RxFCLowThresh when no RxFC\n");
+	}
+	{ /* Flow Control Pause Time Request */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Flow Control Pause Time Request",
+			.err =
+			    "using default of "
+			    __MODULE_STRING(DEFAULT_FCPAUSE),
+			.def = DEFAULT_FCPAUSE,
+			.arg = {.r = {.min = MIN_FCPAUSE,
+				      .max = MAX_FCPAUSE}}
+		};
+
+		if (num_FCReqTimeout > bd) {
+			int pause_time = FCReqTimeout[bd];
+			ixgbe_validate_option(&pause_time, &opt);
+			hw->fc.pause_time = pause_time;
+		} else {
+			hw->fc.pause_time = opt.def;
+		}
+		if (!(hw->fc.type & ixgbe_fc_tx_pause))
+			printk(KERN_INFO
+			       "Ignoring FCReqTimeout when no RxFC\n");
+	}
+	/* high low and spacing check for rx flow control thresholds */
+	if (hw->fc.type & ixgbe_fc_tx_pause) {
+		/* high must be greater than low */
+		if (hw->fc.high_water < (hw->fc.low_water + 8)) {
+			/* set defaults */
+			printk(KERN_INFO
+			       "RxFCHighThresh must be >= (RxFCLowThresh + 8), "
+			       "Using Defaults\n");
+			hw->fc.high_water = DEFAULT_FCRTH;
+			hw->fc.low_water = DEFAULT_FCRTL;
+		}
+		/* enable the sending of XON frames, otherwise the long pause
+		 * timeout is not good */
+		hw->fc.send_xon = 1;
+	}
+	{ /* Interrupt Throttling Rate */
+		struct ixgbe_option opt = {
+			.type = range_option,
+			.name = "Interrupt Throttling Rate (ints/sec)",
+			.err  = "using default of "__MODULE_STRING(DEFAULT_ITR),
+			.def  = DEFAULT_ITR,
+			.arg  = { .r = { .min = MIN_ITR,
+					 .max = MAX_ITR }}
+		};
+
+		if (num_InterruptThrottleRate > bd) {
+			adapter->eitr = InterruptThrottleRate[bd];
+			switch (adapter->eitr) {
+			case 0:
+				DPRINTK(PROBE, INFO, "%s turned off\n",
+					opt.name);
+				break;
+			case 1:
+				DPRINTK(PROBE, INFO, "%s set to dynamic mode\n",
+					opt.name);
+				adapter->eitr = DEFAULT_ITR;
+				break;
+			default:
+				ixgbe_validate_option(&adapter->eitr, &opt);
+				break;
+			}
+		} else {
+			adapter->eitr = DEFAULT_ITR;
+		}
+	}
+}
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
new file mode 100644
index 0000000..1abfe59
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -0,0 +1,574 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "ixgbe_api.h"
+#include "ixgbe_common.h"
+#include "ixgbe_phy.h"
+
+/**
+ *  ixgbe_init_shared_code_phy - Initialize PHY shared code
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_phy_init_shared_code(struct ixgbe_hw *hw)
+{
+	/* Assign function pointers */
+	ixgbe_phy_assign_func_pointers(hw);
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_phy_assign_func_pointers -  Assigns PHY-specific function pointers
+ *  @hw: pointer to hardware structure
+ *
+ *  Note, generic function pointers have already been assigned, so the
+ *  function pointers set here are only for PHY-specific functions.
+ **/
+s32 ixgbe_phy_assign_func_pointers(struct ixgbe_hw *hw)
+{
+	hw->func_table.ixgbe_func_phy_reset = &ixgbe_generic_phy_reset;
+	hw->func_table.ixgbe_func_phy_read_reg = &ixgbe_generic_phy_read_reg;
+	hw->func_table.ixgbe_func_phy_write_reg = &ixgbe_generic_phy_write_reg;
+	hw->func_table.ixgbe_func_phy_identify = &ixgbe_generic_phy_identify;
+
+	if (ixgbe_adapter_get_media_type(hw) == ixgbe_media_type_copper) {
+		/* Call PHY identify routine to get the phy type */
+		ixgbe_phy_identify(hw);
+
+		switch (hw->phy.type) {
+		case ixgbe_phy_tn:
+			hw->func_table.ixgbe_func_phy_link_setup =
+			    &ixgbe_tnx_phy_link_setup;
+			hw->func_table.ixgbe_func_phy_link_check =
+			    &ixgbe_tnx_phy_link_check;
+			hw->func_table.ixgbe_func_phy_link_setup_speed =
+			    &ixgbe_tnx_phy_link_setup_speed;
+			break;
+		default:
+			break;
+		}
+	}
+
+	return IXGBE_SUCCESS;
+}
+
+/**
+ *  ixgbe_generic_phy_identify - Get physical layer module
+ *  @hw: pointer to hardware structure
+ *
+ *  Determines the physical layer module found on the current adapter.
+ **/
+s32 ixgbe_generic_phy_identify(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_ERR_PHY_ADDR_INVALID;
+	u32 phy_addr;
+
+	for (phy_addr = 0; phy_addr < IXGBE_MAX_PHY_ADDR; phy_addr++) {
+		if (ixgbe_phy_is_addr_valid(hw, phy_addr)) {
+			hw->phy.addr = phy_addr;
+			ixgbe_phy_determine_id(hw);
+			hw->phy.type = ixgbe_phy_get_type_from_id(hw->phy.id);
+			status = IXGBE_SUCCESS;
+			break;
+		}
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_generic_phy_is_addr_valid - Determines phy address is valid
+ *  @hw: pointer to hardware structure
+ *
+ **/
+boolean_t ixgbe_phy_is_addr_valid(struct ixgbe_hw *hw, u32 phy_addr)
+{
+	u16 phy_id = 0;
+	boolean_t valid = FALSE;
+
+	hw->phy.addr = phy_addr;
+	ixgbe_generic_phy_read_reg(hw,
+				   IXGBE_MDIO_PHY_ID_HIGH,
+				   IXGBE_MDIO_PMA_PMD_DEV_TYPE, &phy_id);
+
+	if (phy_id != 0xFFFF && phy_id != 0x0)
+		valid = TRUE;
+
+	return valid;
+}
+
+/**
+ *  ixgbe_generic_get_phy_type_from_id - Get the phy type
+ *  @hw: pointer to hardware structure
+ *
+ **/
+s32 ixgbe_phy_determine_id(struct ixgbe_hw *hw)
+{
+	u32 status;
+	u16 phy_id_high = 0;
+	u16 phy_id_low = 0;
+
+	status = ixgbe_generic_phy_read_reg(hw,
+					    IXGBE_MDIO_PHY_ID_HIGH,
+					    IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+					    &phy_id_high);
+
+	if (status == IXGBE_SUCCESS) {
+		hw->phy.id = (u32) (phy_id_high << 16);
+		status = ixgbe_generic_phy_read_reg(hw,
+						    IXGBE_MDIO_PHY_ID_LOW,
+						    IXGBE_MDIO_PMA_PMD_DEV_TYPE,
+						    &phy_id_low);
+		hw->phy.id |= (u32) (phy_id_low & IXGBE_PHY_REVISION_MASK);
+		hw->phy.revision =
+		    (u32) (phy_id_low & ~IXGBE_PHY_REVISION_MASK);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_generic_get_phy_type_from_id - Get the phy type
+ *  @hw: pointer to hardware structure
+ *
+ **/
+enum ixgbe_phy_type ixgbe_phy_get_type_from_id(u32 phy_id)
+{
+	enum ixgbe_phy_type phy_type;
+
+	switch (phy_id) {
+	case TN1010_PHY_ID:
+		phy_type = ixgbe_phy_tn;
+		break;
+
+	case QT2022_PHY_ID:
+		phy_type = ixgbe_phy_qt;
+		break;
+
+	default:
+		phy_type = ixgbe_phy_unknown;
+		break;
+	}
+
+	return phy_type;
+}
+
+/**
+ *  ixgbe_generic_phy_reset - Performs a PHY reset
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_generic_phy_reset(struct ixgbe_hw *hw)
+{
+	/*
+	 * Perform soft PHY reset to the PHY_XS.
+	 * This will cause a soft reset to the PHY
+	 */
+	return ixgbe_phy_write_reg(hw, IXGBE_MDIO_PHY_XS_CONTROL,
+				   IXGBE_MDIO_PHY_XS_DEV_TYPE,
+				   IXGBE_MDIO_PHY_XS_RESET);
+}
+
+/**
+ *  ixgbe_generic_phy_read_reg - Reads a value from a specified PHY register
+ *  @hw: pointer to hardware structure
+ *  @reg_addr: 32 bit address of PHY register to read
+ *  @phy_data: Pointer to read data from PHY register
+ **/
+s32 ixgbe_generic_phy_read_reg(struct ixgbe_hw *hw, u32 reg_addr,
+			       u32 device_type, u16 *phy_data)
+{
+	u32 command;
+	u32 i;
+	u32 timeout = 10;
+	u32 data;
+	s32 status = IXGBE_SUCCESS;
+	u16 gssr;
+
+	if (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)
+		gssr = IXGBE_GSSR_PHY1_SM;
+	else
+		gssr = IXGBE_GSSR_PHY0_SM;
+
+	if (ixgbe_swfw_sync_acquire(hw, gssr) != IXGBE_SUCCESS)
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	if (status == IXGBE_SUCCESS) {
+		/* Setup and write the address cycle command */
+		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT) |
+			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+
+		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
+
+		/*
+		 * Check every 10 usec to see if the address cycle completed.
+		 * The MDI Command bit will clear when the operation is
+		 * complete
+		 */
+		for (i = 0; i < timeout; i++) {
+			udelay(10);
+
+			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
+
+			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
+				break;
+			}
+		}
+
+		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+			DEBUGFUNC("PHY address command did not complete.\n");
+			status = IXGBE_ERR_PHY;
+		}
+
+		if (status == IXGBE_SUCCESS) {
+			/*
+			 * Address cycle complete, setup and write the read
+			 * command
+			 */
+			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT) |
+				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+				   (IXGBE_MSCA_READ | IXGBE_MSCA_MDI_COMMAND));
+
+			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
+
+			/*
+			 * Check every 10 usec to see if the address cycle
+			 * completed. The MDI Command bit will clear when the
+			 * operation is complete
+			 */
+			for (i = 0; i < timeout; i++) {
+				udelay(10);
+
+				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
+
+				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0)
+					break;
+			}
+
+			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0) {
+				DEBUGFUNC("PHY read command didn't complete\n");
+				status = IXGBE_ERR_PHY;
+			} else {
+				/*
+				 * Read operation is complete.  Get the data
+				 * from MSRWD
+				 */
+				data = IXGBE_READ_REG(hw, IXGBE_MSRWD);
+				data >>= IXGBE_MSRWD_READ_DATA_SHIFT;
+				*phy_data = (u16) (data);
+			}
+		}
+
+		ixgbe_swfw_sync_release(hw, gssr);
+	}
+	return status;
+}
+
+/**
+ *  ixgbe_generic_phy_write_reg - Writes a value to specified PHY register
+ *  @hw: pointer to hardware structure
+ *  @reg_addr: 32 bit PHY register to write
+ *  @device_type: 5 bit device type
+ *  @phy_data: Data to write to the PHY register
+ **/
+s32 ixgbe_generic_phy_write_reg(struct ixgbe_hw *hw, u32 reg_addr,
+				u32 device_type, u16 phy_data)
+{
+	u32 command;
+	u32 i;
+	u32 timeout = 10;
+	s32 status = IXGBE_SUCCESS;
+	u16 gssr;
+
+	if (IXGBE_READ_REG(hw, IXGBE_STATUS) & IXGBE_STATUS_LAN_ID_1)
+		gssr = IXGBE_GSSR_PHY1_SM;
+	else
+		gssr = IXGBE_GSSR_PHY0_SM;
+
+	if (ixgbe_swfw_sync_acquire(hw, gssr) != IXGBE_SUCCESS)
+		status = IXGBE_ERR_SWFW_SYNC;
+
+	if (status == IXGBE_SUCCESS) {
+		/* Put data in the MDI single read and write data register */
+		IXGBE_WRITE_REG(hw, IXGBE_MSRWD, (u32) phy_data);
+
+		/* Setup and write the address cycle command */
+		command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT) |
+			   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+			   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+			   (IXGBE_MSCA_ADDR_CYCLE | IXGBE_MSCA_MDI_COMMAND));
+
+		IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
+
+		/*
+		 * Check every 10 usec to see if the address cycle completed.
+		 * The MDI Command bit will clear when the operation is
+		 * complete
+		 */
+		for (i = 0; i < timeout; i++) {
+			udelay(10);
+
+			command = IXGBE_READ_REG(hw, IXGBE_MSCA);
+
+			if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
+				DEBUGFUNC("PHY address cmd didn't complete\n");
+				break;
+			}
+		}
+
+		if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+			status = IXGBE_ERR_PHY;
+
+		if (status == IXGBE_SUCCESS) {
+			/*
+			 * Address cycle complete, setup and write the write
+			 * command
+			 */
+			command = ((reg_addr << IXGBE_MSCA_NP_ADDR_SHIFT) |
+				   (device_type << IXGBE_MSCA_DEV_TYPE_SHIFT) |
+				   (hw->phy.addr << IXGBE_MSCA_PHY_ADDR_SHIFT) |
+				   (IXGBE_MSCA_WRITE | IXGBE_MSCA_MDI_COMMAND));
+
+			IXGBE_WRITE_REG(hw, IXGBE_MSCA, command);
+
+			/*
+			 * Check every 10 usec to see if the address cycle
+			 * completed. The MDI Command bit will clear when the
+			 * operation is complete
+			 */
+			for (i = 0; i < timeout; i++) {
+				udelay(10);
+
+				command = IXGBE_READ_REG(hw, IXGBE_MSCA);
+
+				if ((command & IXGBE_MSCA_MDI_COMMAND) == 0) {
+					DEBUGFUNC("PHY write command did not "
+						  "complete.\n");
+					break;
+				}
+			}
+
+			if ((command & IXGBE_MSCA_MDI_COMMAND) != 0)
+				status = IXGBE_ERR_PHY;
+		}
+
+		ixgbe_swfw_sync_release(hw, gssr);
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_phy_link_setup - Restart PHY autoneg
+ *  @hw: pointer to hardware structure
+ *
+ *  Restart autonegotiation and PHY and waits for completion.
+ **/
+s32 ixgbe_phy_link_setup(struct ixgbe_hw *hw)
+{
+	return ixgbe_call_func(hw, ixgbe_func_phy_link_setup, (hw),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_phy_link_check - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads a PHY register to determine if link is up and the current speed for
+ *  the PHY.
+ **/
+s32 ixgbe_phy_link_check(struct ixgbe_hw *hw, u32 *speed, boolean_t *link_up)
+{
+	return ixgbe_call_func(hw, ixgbe_func_phy_link_check, (hw, speed,
+							       link_up),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_phy_link_setup_speed - Set auto advertise
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: TRUE if autonegotiation enabled
+ *
+ *  Sets the auto advertised capabilities
+ **/
+s32 ixgbe_phy_link_setup_speed(struct ixgbe_hw *hw, u32 speed,
+			       boolean_t autoneg,
+			       boolean_t autoneg_wait_to_complete)
+{
+	return ixgbe_call_func(hw, ixgbe_func_phy_link_setup_speed,
+			       (hw, speed, autoneg, autoneg_wait_to_complete),
+			       IXGBE_NOT_IMPLEMENTED);
+}
+
+/**
+ *  ixgbe_tnx_phy_link_setup - Set and restart autoneg
+ *  @hw: pointer to hardware structure
+ *
+ *  Restart autonegotiation and PHY and waits for completion.
+ **/
+s32 ixgbe_tnx_phy_link_setup(struct ixgbe_hw *hw)
+{
+	s32 status = IXGBE_NOT_IMPLEMENTED;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 autoneg_speed_selection_register = 0x10;
+	u16 autoneg_restart_mask = 0x0200;
+	u16 autoneg_complete_mask = 0x0020;
+	u16 autoneg_reg = 0;
+
+	/*
+	 * Set advertisement settings in PHY based on autoneg_advertised
+	 * settings. If autoneg_advertised = 0, then advertise default values
+	 * txn devices cannot be "forced" to a autoneg 10G and fail.  But can
+	 * for a 1G.
+	 */
+	ixgbe_phy_read_reg(hw,
+			   autoneg_speed_selection_register,
+			   IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
+
+	if (hw->autoneg_advertised == IXGBE_LINK_SPEED_1GB_FULL)
+		autoneg_reg &= 0xEFFF;	/* 0 in bit 12 is 1G operation */
+	else
+		autoneg_reg |= 0x1000;	/* 1 in bit 12 is 10G/1G operation */
+
+	ixgbe_phy_write_reg(hw,
+			    autoneg_speed_selection_register,
+			    IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
+
+	/* Restart PHY autonegotiation and wait for completion */
+	ixgbe_phy_read_reg(hw,
+			   IXGBE_MDIO_AUTO_NEG_CONTROL,
+			   IXGBE_MDIO_AUTO_NEG_DEV_TYPE, &autoneg_reg);
+
+	autoneg_reg |= autoneg_restart_mask;
+
+	ixgbe_phy_write_reg(hw,
+			    IXGBE_MDIO_AUTO_NEG_CONTROL,
+			    IXGBE_MDIO_AUTO_NEG_DEV_TYPE, autoneg_reg);
+
+	/* Wait for autonegotiation to finish */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		/* Restart PHY autonegotiation and wait for completion */
+		status = ixgbe_phy_read_reg(hw,
+					    IXGBE_MDIO_AUTO_NEG_STATUS,
+					    IXGBE_MDIO_AUTO_NEG_DEV_TYPE,
+					    &autoneg_reg);
+
+		autoneg_reg &= autoneg_complete_mask;
+		if (autoneg_reg == autoneg_complete_mask) {
+			status = IXGBE_SUCCESS;
+			break;
+		}
+	}
+
+	if (time_out == max_time_out)
+		status = IXGBE_ERR_LINK_SETUP;
+
+	return status;
+}
+
+/**
+ *  ixgbe_tnx_phy_link_check - Determine link and speed status
+ *  @hw: pointer to hardware structure
+ *
+ *  Reads the VS1 register to determine if link is up and the current speed for
+ *  the PHY.
+ **/
+s32 ixgbe_tnx_phy_link_check(struct ixgbe_hw *hw, u32 *speed,
+			     boolean_t *link_up)
+{
+	s32 status = IXGBE_SUCCESS;
+	u32 time_out;
+	u32 max_time_out = 10;
+	u16 phy_link = 0;
+	u16 phy_speed = 0;
+	u16 phy_data = 0;
+
+	/* Initialize speed and link to default case */
+	*link_up = FALSE;
+	*speed = IXGBE_LINK_SPEED_10GB_FULL;
+
+	/*
+	 * Check current speed and link status of the PHY register.
+	 * This is a vendor specific register and may have to
+	 * be changed for other copper PHYs.
+	 */
+	for (time_out = 0; time_out < max_time_out; time_out++) {
+		udelay(10);
+		if (phy_link == IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS) {
+			*link_up = TRUE;
+			if (phy_speed ==
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS)
+				*speed = IXGBE_LINK_SPEED_1GB_FULL;
+			break;
+		} else {
+			status = ixgbe_phy_read_reg(hw,
+					IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS,
+					IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE,
+					&phy_data);
+			phy_link = phy_data &
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS;
+			phy_speed = phy_data &
+			    IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS;
+		}
+	}
+
+	return status;
+}
+
+/**
+ *  ixgbe_tnx_phy_link_setup_speed - Sets the auto advertised capabilities
+ *  @hw: pointer to hardware structure
+ *  @speed: new link speed
+ *  @autoneg: TRUE if autonegotiation enabled
+ **/
+s32 ixgbe_tnx_phy_link_setup_speed(struct ixgbe_hw *hw, u32 speed,
+				   boolean_t autoneg,
+				   boolean_t autoneg_wait_to_complete)
+{
+	/*
+	 * Clear autoneg_advertised and set new values based on input link
+	 * speed.
+	 */
+	hw->autoneg_advertised = 0;
+
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
+		hw->autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+	}
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL) {
+		hw->autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
+	}
+
+	/* Setup link based on the new speed settings */
+	ixgbe_tnx_phy_link_setup(hw);
+
+	return IXGBE_SUCCESS;
+}
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/ixgbe/ixgbe_phy.h
new file mode 100644
index 0000000..4873c92
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_phy.h
@@ -0,0 +1,61 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_PHY_H_
+#define _IXGBE_PHY_H_
+
+#include "ixgbe_type.h"
+
+s32 ixgbe_phy_init_shared_code(struct ixgbe_hw *hw);
+s32 ixgbe_phy_assign_func_pointers(struct ixgbe_hw *hw);
+s32 ixgbe_phy_link_setup(struct ixgbe_hw *hw);
+s32 ixgbe_phy_link_check(struct ixgbe_hw *hw, u32 *speed, boolean_t *link_up);
+s32 ixgbe_phy_link_setup_speed(struct ixgbe_hw *hw,
+			       u32 speed,
+			       boolean_t autoneg,
+			       boolean_t autoneg_wait_to_complete);
+boolean_t ixgbe_phy_is_addr_valid(struct ixgbe_hw *hw, u32 phy_addr);
+enum ixgbe_phy_type ixgbe_phy_get_type_from_id(u32 phy_id);
+s32 ixgbe_phy_determine_id(struct ixgbe_hw *hw);
+s32 ixgbe_generic_phy_identify(struct ixgbe_hw *hw);
+s32 ixgbe_generic_phy_reset(struct ixgbe_hw *hw);
+s32 ixgbe_generic_phy_read_reg(struct ixgbe_hw *hw, u32 reg_addr,
+			       u32 device_type, u16 *phy_data);
+s32 ixgbe_generic_phy_write_reg(struct ixgbe_hw *hw, u32 reg_addr,
+				u32 device_type, u16 phy_data);
+
+/* PHY specific */
+s32 ixgbe_tnx_phy_link_setup(struct ixgbe_hw *hw);
+s32 ixgbe_tnx_phy_link_check(struct ixgbe_hw *hw,
+			     u32 *speed, boolean_t *link_up);
+s32 ixgbe_tnx_phy_link_setup_speed(struct ixgbe_hw *hw,
+				   u32 speed,
+				   boolean_t autoneg,
+				   boolean_t autoneg_wait_to_complete);
+
+#endif				/* _IXGBE_PHY_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
new file mode 100644
index 0000000..1e29437
--- /dev/null
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -0,0 +1,1385 @@
+/*******************************************************************************
+
+  Intel PRO/10GbE PCI Express Linux driver
+  Copyright(c) 1999 - 2007 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _IXGBE_TYPE_H_
+#define _IXGBE_TYPE_H_
+
+#include "ixgbe_osdep.h"
+
+/* Vendor ID */
+#define IXGBE_INTEL_VENDOR_ID   0x8086
+
+/* Device IDs */
+#define IXGBE_DEV_ID_82598               0x10B6
+#define IXGBE_DEV_ID_82598AF_DUAL_PORT   0x10C6
+#define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
+
+/* General Registers */
+#define IXGBE_CTRL              0x00000
+#define IXGBE_STATUS            0x00008
+#define IXGBE_CTRL_EXT          0x00018
+#define IXGBE_ESDP              0x00020
+#define IXGBE_EODSDP            0x00028
+#define IXGBE_LEDCTL            0x00200
+#define IXGBE_FRTIMER           0x00048
+#define IXGBE_TCPTIMER          0x0004C
+
+/* NVM Registers */
+#define IXGBE_EEC               0x10010
+#define IXGBE_EERD              0x10014
+#define IXGBE_FLA               0x1001C
+#define IXGBE_EEMNGCTL          0x10110
+#define IXGBE_EEMNGDATA         0x10114
+#define IXGBE_FLMNGCTL          0x10118
+#define IXGBE_FLMNGDATA         0x1011C
+#define IXGBE_FLMNGCNT          0x10120
+#define IXGBE_FLOP              0x1013C
+#define IXGBE_GRC               0x10200
+
+/* Interrupt Registers */
+#define IXGBE_EICR              0x00800
+#define IXGBE_EICS              0x00808
+#define IXGBE_EIMS              0x00880
+#define IXGBE_EIMC              0x00888
+#define IXGBE_EIAC              0x00810
+#define IXGBE_EIAM              0x00890
+#define IXGBE_EITR(_i)          (0x00820 + ((_i) * 4))	/* 0x820-0x86c */
+#define IXGBE_IVAR(_i)          (0x00900 + ((_i) * 4))	/* 24 at 0x900-0x960 */
+#define IXGBE_MSIXT             0x00000	/* MSI-X Table. 0x0000 - 0x01C */
+#define IXGBE_MSIXPBA           0x02000	/* MSI-X Pending bit array */
+#define IXGBE_PBACL             0x11068
+#define IXGBE_GPIE              0x00898
+
+/* Flow Control Registers */
+#define IXGBE_PFCTOP            0x03008
+#define IXGBE_FCTTV(_i)         (0x03200 + ((_i) * 4))	/* 4 of these (0-3) */
+#define IXGBE_FCRTL(_i)         (0x03220 + ((_i) * 8))	/* 8 of these (0-7) */
+#define IXGBE_FCRTH(_i)         (0x03260 + ((_i) * 8))	/* 8 of these (0-7) */
+#define IXGBE_FCRTV             0x032A0
+#define IXGBE_TFCS              0x0CE00
+
+/* Receive DMA Registers */
+#define IXGBE_RDBAL(_i)         (0x01000 + ((_i) * 0x40))	/* 64 (0-63) */
+#define IXGBE_RDBAH(_i)         (0x01004 + ((_i) * 0x40))
+#define IXGBE_RDLEN(_i)         (0x01008 + ((_i) * 0x40))
+#define IXGBE_RDH(_i)           (0x01010 + ((_i) * 0x40))
+#define IXGBE_RDT(_i)           (0x01018 + ((_i) * 0x40))
+#define IXGBE_RXDCTL(_i)        (0x01028 + ((_i) * 0x40))
+#define IXGBE_SRRCTL(_i)        (0x02100 + ((_i) * 4))
+					     /* array of 16 (0x02100-0x0213C) */
+#define IXGBE_DCA_RXCTRL(_i)    (0x02200 + ((_i) * 4))
+					     /* array of 16 (0x02200-0x0223C) */
+#define IXGBE_RDRXCTL           0x02F00
+#define IXGBE_RXPBSIZE(_i)      (0x03C00 + ((_i) * 4))
+					     /* 8 of these 0x03C00 - 0x03C1C */
+#define IXGBE_RXCTRL            0x03000
+#define IXGBE_DROPEN            0x03D04
+#define IXGBE_RXPBSIZE_SHIFT    10
+
+/* Receive Registers */
+#define IXGBE_RXCSUM            0x05000
+#define IXGBE_RFCTL             0x05008
+#define IXGBE_MTA(_i)           (0x05200 + ((_i) * 4))
+				   /* Multicast Table Array - 128 entries */
+#define IXGBE_RAL(_i)           (0x05400 + ((_i) * 8))	/* 16 of these (0-15) */
+#define IXGBE_RAH(_i)           (0x05404 + ((_i) * 8))	/* 16 of these (0-15) */
+#define IXGBE_PSRTYPE           0x05480
+				   /* 0x5480-0x54BC Packet split receive type */
+#define IXGBE_VFTA(_i)          (0x0A000 + ((_i) * 4))
+					 /* array of 4096 1-bit vlan filters */
+#define IXGBE_VFTAVIND(_j, _i)  (0x0A200 + ((_j) * 0x200) + ((_i) * 4))
+				     /*array of 4096 4-bit vlan vmdq indicies */
+#define IXGBE_FCTRL             0x05080
+#define IXGBE_VLNCTRL           0x05088
+#define IXGBE_MCSTCTRL          0x05090
+#define IXGBE_MRQC              0x05818
+#define IXGBE_VMD_CTL           0x0581C
+#define IXGBE_IMIR(_i)          (0x05A80 + ((_i) * 4))	/* 8 of these (0-7) */
+#define IXGBE_IMIREXT(_i)       (0x05AA0 + ((_i) * 4))	/* 8 of these (0-7) */
+#define IXGBE_IMIRVP            0x05AC0
+#define IXGBE_RETA(_i)          (0x05C00 + ((_i) * 4))	/* 32 of these (0-31) */
+#define IXGBE_RSSRK(_i)         (0x05C80 + ((_i) * 4))	/* 10 of these (0-9) */
+
+/* Transmit DMA registers */
+#define IXGBE_TDBAL(_i)         (0x06000 + ((_i) * 0x40))	/* 32 (0-31) */
+#define IXGBE_TDBAH(_i)         (0x06004 + ((_i) * 0x40))
+#define IXGBE_TDLEN(_i)         (0x06008 + ((_i) * 0x40))
+#define IXGBE_TDH(_i)           (0x06010 + ((_i) * 0x40))
+#define IXGBE_TDT(_i)           (0x06018 + ((_i) * 0x40))
+#define IXGBE_TXDCTL(_i)        (0x06028 + ((_i) * 0x40))
+#define IXGBE_TDWBAL(_i)        (0x06038 + ((_i) * 0x40))
+#define IXGBE_TDWBAH(_i)        (0x0603C + ((_i) * 0x40))
+#define IXGBE_DTXCTL            0x07E00
+#define IXGBE_DCA_TXCTRL(_i)    (0x07200 + ((_i) * 4))
+					      /* there are 16 of these (0-15) */
+#define IXGBE_TIPG              0x0CB00
+#define IXGBE_TXPBSIZE(_i)      (0x0CC00 + ((_i) *0x04))
+						      /* there are 8 of these */
+#define IXGBE_MNGTXMAP          0x0CD10
+#define IXGBE_TIPG_FIBER_DEFAULT 3
+#define IXGBE_TXPBSIZE_SHIFT    10
+
+/* Wake up registers */
+#define IXGBE_WUC               0x05800
+#define IXGBE_WUFC              0x05808
+#define IXGBE_WUS               0x05810
+#define IXGBE_IPAV              0x05838
+#define IXGBE_IP4AT             0x05840	/* IPv4 table 0x5840-0x5858 */
+#define IXGBE_IP6AT             0x05880	/* IPv6 table 0x5880-0x588F */
+#define IXGBE_WUPL              0x05900
+#define IXGBE_WUPM              0x05A00	/* wake up pkt memory 0x5A00-0x5A7C */
+#define IXGBE_FHFT              0x09000	/* Flex host filter table 9000-93FC */
+
+/* Music registers */
+#define IXGBE_RMCS              0x03D00
+#define IXGBE_DPMCS             0x07F40
+#define IXGBE_PDPMCS            0x0CD00
+#define IXGBE_RUPPBMR           0x050A0
+#define IXGBE_RT2CR(_i)         (0x03C20 + ((_i) * 4))	/* 8 (0-7) */
+#define IXGBE_RT2SR(_i)         (0x03C40 + ((_i) * 4))	/* 8 (0-7) */
+#define IXGBE_TDTQ2TCCR(_i)     (0x0602C + ((_i) * 0x40))	/* 8 (0-7) */
+#define IXGBE_TDTQ2TCSR(_i)     (0x0622C + ((_i) * 0x40))	/* 8 (0-7) */
+#define IXGBE_TDPT2TCCR(_i)     (0x0CD20 + ((_i) * 4))	/* 8 (0-7) */
+#define IXGBE_TDPT2TCSR(_i)     (0x0CD40 + ((_i) * 4))	/* 8 (0-7) */
+
+/* Stats registers */
+#define IXGBE_CRCERRS           0x04000
+#define IXGBE_ILLERRC           0x04004
+#define IXGBE_ERRBC             0x04008
+#define IXGBE_MSPDC             0x04010
+#define IXGBE_MPC(_i)           (0x03FA0 + ((_i) * 4))	/* 8 (3FA0-3FBC) */
+#define IXGBE_MLFC              0x04034
+#define IXGBE_MRFC              0x04038
+#define IXGBE_RLEC              0x04040
+#define IXGBE_LXONTXC           0x03F60
+#define IXGBE_LXONRXC           0x0CF60
+#define IXGBE_LXOFFTXC          0x03F68
+#define IXGBE_LXOFFRXC          0x0CF68
+#define IXGBE_PXONTXC(_i)       (0x03F00 + ((_i) * 4))	/* 8 (3F00-3F1C) */
+#define IXGBE_PXONRXC(_i)       (0x0CF00 + ((_i) * 4))	/* 8 (CF00-CF1C) */
+#define IXGBE_PXOFFTXC(_i)      (0x03F20 + ((_i) * 4))	/* 8 (3F20-3F3C) */
+#define IXGBE_PXOFFRXC(_i)      (0x0CF20 + ((_i) * 4))	/* 8 (CF20-CF3C) */
+#define IXGBE_PRC64             0x0405C
+#define IXGBE_PRC127            0x04060
+#define IXGBE_PRC255            0x04064
+#define IXGBE_PRC511            0x04068
+#define IXGBE_PRC1023           0x0406C
+#define IXGBE_PRC1522           0x04070
+#define IXGBE_GPRC              0x04074
+#define IXGBE_BPRC              0x04078
+#define IXGBE_MPRC              0x0407C
+#define IXGBE_GPTC              0x04080
+#define IXGBE_GORCL             0x04088
+#define IXGBE_GORCH             0x0408C
+#define IXGBE_GOTCL             0x04090
+#define IXGBE_GOTCH             0x04094
+#define IXGBE_RNBC(_i)          (0x03FC0 + ((_i) * 4))	/* 8 3FC0-3FDC */
+#define IXGBE_RUC               0x040A4
+#define IXGBE_RFC               0x040A8
+#define IXGBE_ROC               0x040AC
+#define IXGBE_RJC               0x040B0
+#define IXGBE_MNGPRC            0x040B4
+#define IXGBE_MNGPDC            0x040B8
+#define IXGBE_MNGPTC            0x0CF90
+#define IXGBE_TORL              0x040C0
+#define IXGBE_TORH              0x040C4
+#define IXGBE_TPR               0x040D0
+#define IXGBE_TPT               0x040D4
+#define IXGBE_PTC64             0x040D8
+#define IXGBE_PTC127            0x040DC
+#define IXGBE_PTC255            0x040E0
+#define IXGBE_PTC511            0x040E4
+#define IXGBE_PTC1023           0x040E8
+#define IXGBE_PTC1522           0x040EC
+#define IXGBE_MPTC              0x040F0
+#define IXGBE_BPTC              0x040F4
+#define IXGBE_XEC               0x04120
+
+#define IXGBE_RQSMR(_i)         (0x02300 + ((_i) * 4))	/* 16 of these */
+#define IXGBE_TQSMR(_i)         (0x07300 + ((_i) * 4))	/* 8 of these */
+
+#define IXGBE_QPRC(_i)          (0x01030 + ((_i) * 0x40))	/* 16 */
+#define IXGBE_QPTC(_i)          (0x06030 + ((_i) * 0x40))	/* 16 */
+#define IXGBE_QBRC(_i)          (0x01034 + ((_i) * 0x40))	/* 16 */
+#define IXGBE_QBTC(_i)          (0x06034 + ((_i) * 0x40))	/* 16 */
+
+/* Management */
+#define IXGBE_MAVTV(_i)        (0x05010 + ((_i) * 4))	/* 8 of these (0-7) */
+#define IXGBE_MFUTP(_i)        (0x05030 + ((_i) * 4))	/* 8 of these (0-7) */
+#define IXGBE_MANC              0x05820
+#define IXGBE_MFVAL             0x05824
+#define IXGBE_MANC2H            0x05860
+#define IXGBE_MDEF(_i)         (0x05890 + ((_i) * 4))	/* 8 of these (0-7) */
+#define IXGBE_MIPAF             0x058B0
+#define IXGBE_MMAL(_i)         (0x05910 + ((_i) * 8))	/* 4 of these (0-3) */
+#define IXGBE_MMAH(_i)         (0x05914 + ((_i) * 8))	/* 4 of these (0-3) */
+#define IXGBE_FTFT              0x09400	/* 0x9400-0x97FC */
+
+/* ARC Subsystem registers */
+#define IXGBE_HICR              0x15F00
+#define IXGBE_FWSTS             0x15F0C
+#define IXGBE_HSMC0R            0x15F04
+#define IXGBE_HSMC1R            0x15F08
+#define IXGBE_SWSR              0x15F10
+#define IXGBE_HFDR              0x15FE8
+#define IXGBE_FLEX_MNG          0x15800	/* 0x15800 - 0x15EFC */
+
+/* PCI-E registers */
+#define IXGBE_GCR               0x11000
+#define IXGBE_GTV               0x11004
+#define IXGBE_FUNCTAG           0x11008
+#define IXGBE_GLT               0x1100C
+#define IXGBE_GSCL_1            0x11010
+#define IXGBE_GSCL_2            0x11014
+#define IXGBE_GSCL_3            0x11018
+#define IXGBE_GSCL_4            0x1101C
+#define IXGBE_GSCN_0            0x11020
+#define IXGBE_GSCN_1            0x11024
+#define IXGBE_GSCN_2            0x11028
+#define IXGBE_GSCN_3            0x1102C
+#define IXGBE_FACTPS            0x10150
+#define IXGBE_PCIEANACTL        0x11040
+#define IXGBE_SWSM              0x10140
+#define IXGBE_FWSM              0x10148
+#define IXGBE_GSSR              0x10160
+#define IXGBE_MREVID            0x11064
+#define IXGBE_DCA_ID            0x11070
+#define IXGBE_DCA_CTRL          0x11074
+
+/* Diagnostic Registers */
+#define IXGBE_RDSTATCTL         0x02C20
+#define IXGBE_RDSTAT(_i)        (0x02C00 + ((_i) * 4))	/* 0x02C00-0x02C1C */
+#define IXGBE_RDHMPN            0x02F08
+#define IXGBE_RIC_DW0           0x02F10
+#define IXGBE_RIC_DW1           0x02F14
+#define IXGBE_RIC_DW2           0x02F18
+#define IXGBE_RIC_DW3           0x02F1C
+#define IXGBE_RDPROBE           0x02F20
+#define IXGBE_TDSTATCTL         0x07C20
+#define IXGBE_TDSTAT(_i)        (0x07C00 + ((_i) * 4))	/* 0x07C00 - 0x07C1C */
+#define IXGBE_TDHMPN            0x07F08
+#define IXGBE_TIC_DW0           0x07F10
+#define IXGBE_TIC_DW1           0x07F14
+#define IXGBE_TIC_DW2           0x07F18
+#define IXGBE_TIC_DW3           0x07F1C
+#define IXGBE_TDPROBE           0x07F20
+#define IXGBE_TXBUFCTRL         0x0C600
+#define IXGBE_TXBUFDATA0        0x0C610
+#define IXGBE_TXBUFDATA1        0x0C614
+#define IXGBE_TXBUFDATA2        0x0C618
+#define IXGBE_TXBUFDATA3        0x0C61C
+#define IXGBE_RXBUFCTRL         0x03600
+#define IXGBE_RXBUFDATA0        0x03610
+#define IXGBE_RXBUFDATA1        0x03614
+#define IXGBE_RXBUFDATA2        0x03618
+#define IXGBE_RXBUFDATA3        0x0361C
+#define IXGBE_PCIE_DIAG(_i)     (0x11090 + ((_i) * 4))	/* 8 of these */
+#define IXGBE_RFVAL             0x050A4
+#define IXGBE_MDFTC1            0x042B8
+#define IXGBE_MDFTC2            0x042C0
+#define IXGBE_MDFTFIFO1         0x042C4
+#define IXGBE_MDFTFIFO2         0x042C8
+#define IXGBE_MDFTS             0x042CC
+#define IXGBE_RXDATAWRPTR(_i)   (0x03700 + ((_i) * 4))	/* 8 (3700-370C) */
+#define IXGBE_RXDESCWRPTR(_i)   (0x03710 + ((_i) * 4))	/* 8 (3710-371C) */
+#define IXGBE_RXDATARDPTR(_i)   (0x03720 + ((_i) * 4))	/* 8 (3720-372C) */
+#define IXGBE_RXDESCRDPTR(_i)   (0x03730 + ((_i) * 4))	/* 8 (3730-373C) */
+#define IXGBE_TXDATAWRPTR(_i)   (0x0C700 + ((_i) * 4))	/* 8 (C700-C70C) */
+#define IXGBE_TXDESCWRPTR(_i)   (0x0C710 + ((_i) * 4))	/* 8 (C710-C71C) */
+#define IXGBE_TXDATARDPTR(_i)   (0x0C720 + ((_i) * 4))	/* 8 (C720-C72C) */
+#define IXGBE_TXDESCRDPTR(_i)   (0x0C730 + ((_i) * 4))	/* 8 (C730-C73C) */
+#define IXGBE_PCIEECCCTL        0x1106C
+#define IXGBE_PBTXECC           0x0C300
+#define IXGBE_PBRXECC           0x03300
+#define IXGBE_GHECCR            0x110B0
+
+/* MAC Registers */
+#define IXGBE_PCS1GCFIG         0x04200
+#define IXGBE_PCS1GLCTL         0x04208
+#define IXGBE_PCS1GLSTA         0x0420C
+#define IXGBE_PCS1GDBG0         0x04210
+#define IXGBE_PCS1GDBG1         0x04214
+#define IXGBE_PCS1GANA          0x04218
+#define IXGBE_PCS1GANLP         0x0421C
+#define IXGBE_PCS1GANNP         0x04220
+#define IXGBE_PCS1GANLPNP       0x04224
+#define IXGBE_HLREG0            0x04240
+#define IXGBE_HLREG1            0x04244
+#define IXGBE_PAP               0x04248
+#define IXGBE_MACA              0x0424C
+#define IXGBE_APAE              0x04250
+#define IXGBE_ARD               0x04254
+#define IXGBE_AIS               0x04258
+#define IXGBE_MSCA              0x0425C
+#define IXGBE_MSRWD             0x04260
+#define IXGBE_MLADD             0x04264
+#define IXGBE_MHADD             0x04268
+#define IXGBE_TREG              0x0426C
+#define IXGBE_PCSS1             0x04288
+#define IXGBE_PCSS2             0x0428C
+#define IXGBE_XPCSS             0x04290
+#define IXGBE_SERDESC           0x04298
+#define IXGBE_MACS              0x0429C
+#define IXGBE_AUTOC             0x042A0
+#define IXGBE_LINKS             0x042A4
+#define IXGBE_AUTOC2            0x042A8
+#define IXGBE_AUTOC3            0x042AC
+#define IXGBE_ANLP1             0x042B0
+#define IXGBE_ANLP2             0x042B4
+#define IXGBE_ATLASCTL          0x04800
+
+/* CTRL Bit Masks */
+#define IXGBE_CTRL_GIO_DIS      0x00000004  /* Global IO Master Disable bit */
+#define IXGBE_CTRL_LNK_RST      0x00000008  /* Link Reset. Resets everything. */
+#define IXGBE_CTRL_RST          0x04000000  /* Reset (SW) */
+
+/* FACTPS */
+#define IXGBE_FACTPS_LFS        0x40000000	/* LAN Function Select */
+
+/* MHADD Bit Masks */
+#define IXGBE_MHADD_MFS_MASK    0xFFFF0000
+#define IXGBE_MHADD_MFS_SHIFT   16
+
+/* Extended Device Control */
+#define IXGBE_CTRL_EXT_NS_DIS    0x00010000	/* No Snoop disable */
+#define IXGBE_CTRL_EXT_RO_DIS    0x00020000	/* Relaxed Ordering disable */
+#define IXGBE_CTRL_EXT_DRV_LOAD  0x10000000	/* Driver loaded bit for FW */
+
+/* Direct Cache Access (DCA) definitions */
+#define IXGBE_DCA_CTRL_DCA_ENABLE  0x00000000	/* DCA Enable */
+#define IXGBE_DCA_CTRL_DCA_DISABLE 0x00000001	/* DCA Disable */
+
+#define IXGBE_DCA_CTRL_DCA_MODE_CB1 0x00	/* DCA Mode CB1 */
+#define IXGBE_DCA_CTRL_DCA_MODE_CB2 0x02	/* DCA Mode CB2 */
+
+#define IXGBE_DCA_RXCTRL_CPUID_MASK 0x0000001F	/* Rx CPUID Mask */
+#define IXGBE_DCA_RXCTRL_DESC_DCA_EN (1 << 5)	/* DCA Rx Desc enable */
+#define IXGBE_DCA_RXCTRL_HEAD_DCA_EN (1 << 6)	/* DCA Rx Desc header enable */
+#define IXGBE_DCA_RXCTRL_DATA_DCA_EN (1 << 7)	/* DCA Rx Desc payload enable */
+
+#define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F	/* Tx CPUID Mask */
+#define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5)	/* DCA Tx Desc enable */
+
+/* MSCA Bit Masks */
+#define IXGBE_MSCA_NP_ADDR_MASK      0x0000FFFF	/* MDI Address (new protocol) */
+#define IXGBE_MSCA_NP_ADDR_SHIFT     0
+#define IXGBE_MSCA_DEV_TYPE_MASK     0x001F0000	/* Device Type (new protocol) */
+#define IXGBE_MSCA_DEV_TYPE_SHIFT    16	/* Register Address (old protocol */
+#define IXGBE_MSCA_PHY_ADDR_MASK     0x03E00000	/* PHY Address mask */
+#define IXGBE_MSCA_PHY_ADDR_SHIFT    21	/* PHY Address shift */
+#define IXGBE_MSCA_OP_CODE_MASK      0x0C000000	/* OP CODE mask */
+#define IXGBE_MSCA_OP_CODE_SHIFT     26	/* OP CODE shift */
+#define IXGBE_MSCA_ADDR_CYCLE        0x00000000	/* OP CODE 00 (addr cycle) */
+#define IXGBE_MSCA_WRITE             0x04000000	/* OP CODE 01 (write) */
+#define IXGBE_MSCA_READ              0x08000000	/* OP CODE 10 (read) */
+#define IXGBE_MSCA_READ_AUTOINC      0x0C000000
+					/* OP CODE 11 (read, auto inc) */
+#define IXGBE_MSCA_ST_CODE_MASK      0x30000000	/* ST Code mask */
+#define IXGBE_MSCA_ST_CODE_SHIFT     28	/* ST Code shift */
+#define IXGBE_MSCA_NEW_PROTOCOL      0x00000000	/* ST CODE 00 (new protocol) */
+#define IXGBE_MSCA_OLD_PROTOCOL      0x10000000	/* ST CODE 01 (old protocol) */
+#define IXGBE_MSCA_MDI_COMMAND       0x40000000	/* Initiate MDI command */
+#define IXGBE_MSCA_MDI_IN_PROG_EN    0x80000000	/* MDI in progress enable */
+
+/* MSRWD bit masks */
+#define IXGBE_MSRWD_WRITE_DATA_MASK  0x0000FFFF
+#define IXGBE_MSRWD_WRITE_DATA_SHIFT 0
+#define IXGBE_MSRWD_READ_DATA_MASK   0xFFFF0000
+#define IXGBE_MSRWD_READ_DATA_SHIFT  16
+
+/* Device Type definitions for new protocol MDIO commands */
+#define IXGBE_MDIO_PMA_PMD_DEV_TYPE               0x1
+#define IXGBE_MDIO_PCS_DEV_TYPE                   0x3
+#define IXGBE_MDIO_PHY_XS_DEV_TYPE                0x4
+#define IXGBE_MDIO_AUTO_NEG_DEV_TYPE              0x7
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_DEV_TYPE     0x1E	/* Device 30 */
+
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_CONTROL      0x0	/* VS1 Control Reg */
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_STATUS       0x1	/* VS1 Status Reg */
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_LINK_STATUS  0x0008 /* 1 = Link Up */
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_SPEED_STATUS 0x0010 /* 0 - 10G, 1 - 1G */
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_10G_SPEED    0x0018
+#define IXGBE_MDIO_VENDOR_SPECIFIC_1_1G_SPEED     0x0010
+
+#define IXGBE_MDIO_AUTO_NEG_CONTROL               0x0 /* AUTO_NEG Control Reg */
+#define IXGBE_MDIO_AUTO_NEG_STATUS                0x1 /* AUTO_NEG Status Reg */
+#define IXGBE_MDIO_PHY_XS_CONTROL                 0x0 /* PHY_XS Control Reg */
+#define IXGBE_MDIO_PHY_XS_RESET                   0x8000 /* PHY_XS Reset */
+#define IXGBE_MDIO_PHY_ID_HIGH                    0x2	/* PHY ID High Reg */
+#define IXGBE_MDIO_PHY_ID_LOW                     0x3	/* PHY ID Low Reg */
+
+#define IXGBE_PHY_REVISION_MASK                   0xFFFFFFF0
+#define IXGBE_MAX_PHY_ADDR                        32
+
+/* PHY IDs*/
+#define TN1010_PHY_ID    0x94A00010
+#define QT2022_PHY_ID    0x0043A400
+
+/* General purpose Interrupt Enable */
+#define IXGBE_GPIE_MSIX_MODE      0x00000010	/* MSI-X mode */
+#define IXGBE_GPIE_OCD            0x00000020	/* Other Clear Disable */
+#define IXGBE_GPIE_EIMEN          0x00000040	/* Immediate Interrupt Enable */
+#define IXGBE_GPIE_EIAME          0x40000000
+#define IXGBE_GPIE_PBA_SUPPORT    0x80000000
+
+/* Transmit Flow Control status */
+#define IXGBE_TFCS_TXOFF          0x00000001
+#define IXGBE_TFCS_TXOFF0         0x00000100
+#define IXGBE_TFCS_TXOFF1         0x00000200
+#define IXGBE_TFCS_TXOFF2         0x00000400
+#define IXGBE_TFCS_TXOFF3         0x00000800
+#define IXGBE_TFCS_TXOFF4         0x00001000
+#define IXGBE_TFCS_TXOFF5         0x00002000
+#define IXGBE_TFCS_TXOFF6         0x00004000
+#define IXGBE_TFCS_TXOFF7         0x00008000
+
+/* TCP Timer */
+#define IXGBE_TCPTIMER_KS               0x00000100
+#define IXGBE_TCPTIMER_COUNT_ENABLE     0x00000200
+#define IXGBE_TCPTIMER_COUNT_FINISH     0x00000400
+#define IXGBE_TCPTIMER_LOOP             0x00000800
+#define IXGBE_TCPTIMER_DURATION_MASK    0x000000FF
+
+/* HLREG0 Bit Masks */
+#define IXGBE_HLREG0_TXCRCEN      0x00000001	/* bit  0 */
+#define IXGBE_HLREG0_RXCRCSTRP    0x00000002	/* bit  1 */
+#define IXGBE_HLREG0_JUMBOEN      0x00000004	/* bit  2 */
+#define IXGBE_HLREG0_TXPADEN      0x00000400	/* bit 10 */
+#define IXGBE_HLREG0_TXPAUSEEN    0x00001000	/* bit 12 */
+#define IXGBE_HLREG0_RXPAUSEEN    0x00004000	/* bit 14 */
+#define IXGBE_HLREG0_LPBK         0x00008000	/* bit 15 */
+#define IXGBE_HLREG0_MDCSPD       0x00010000	/* bit 16 */
+#define IXGBE_HLREG0_CONTMDC      0x00020000	/* bit 17 */
+#define IXGBE_HLREG0_CTRLFLTR     0x00040000	/* bit 18 */
+#define IXGBE_HLREG0_PREPEND      0x00F00000	/* bits 20-23 */
+#define IXGBE_HLREG0_PRIPAUSEEN   0x01000000	/* bit 24 */
+#define IXGBE_HLREG0_RXPAUSERECDA 0x06000000	/* bits 25-26 */
+#define IXGBE_HLREG0_RXLNGTHERREN 0x08000000	/* bit 27 */
+#define IXGBE_HLREG0_RXPADSTRIPEN 0x10000000	/* bit 28 */
+
+/* VMD_CTL bitmasks */
+#define IXGBE_VMD_CTL_VMDQ_EN     0x00000001
+#define IXGBE_VMD_CTL_VMDQ_FILTER 0x00000002
+
+/* RDHMPN and TDHMPN bitmasks */
+#define IXGBE_RDHMPN_RDICADDR       0x007FF800
+#define IXGBE_RDHMPN_RDICRDREQ      0x00800000
+#define IXGBE_RDHMPN_RDICADDR_SHIFT 11
+#define IXGBE_TDHMPN_TDICADDR       0x003FF800
+#define IXGBE_TDHMPN_TDICRDREQ      0x00800000
+#define IXGBE_TDHMPN_TDICADDR_SHIFT 11
+
+/* Receive Checksum Control */
+#define IXGBE_RXCSUM_IPPCSE    0x00001000	/* IP payload checksum enable */
+#define IXGBE_RXCSUM_PCSD      0x00002000	/* packet checksum disabled */
+
+/* FCRTL Bit Masks */
+#define IXGBE_FCRTL_XONE        0x80000000	/* bit 31, XON enable */
+#define IXGBE_FCRTH_FCEN        0x80000000	/* Rx Flow control enable */
+
+/* PAP bit masks*/
+#define IXGBE_PAP_TXPAUSECNT_MASK   0x0000FFFF	/* Pause counter mask */
+
+/* RMCS Bit Masks */
+#define IXGBE_RMCS_RRM           0x00000002	/* Receive Recylce Mode ena */
+/* Receive Arbitration Control: 0 Round Robin, 1 DFP */
+#define IXGBE_RMCS_RAC           0x00000004
+#define IXGBE_RMCS_DFP           IXGBE_RMCS_RAC	/* Deficit Fixed Priority ena */
+#define IXGBE_RMCS_TFCE_802_3X   0x00000008	/* Tx Priority flow ctrl ena */
+#define IXGBE_RMCS_TFCE_PRIORITY 0x00000010	/* Tx Priority flow ctrl ena */
+#define IXGBE_RMCS_ARBDIS        0x00000040	/* Arbitration disable bit */
+
+/* Interrupt register bitmasks */
+
+/* Extended Interrupt Cause Read */
+#define IXGBE_EICR_RTX_QUEUE    0x0000FFFF	/* RTx Queue Interrupt */
+#define IXGBE_EICR_LSC          0x00100000	/* Link Status Change */
+#define IXGBE_EICR_MNG          0x00400000	/* Managability Event Int */
+#define IXGBE_EICR_PBUR         0x10000000	/* Packet Buffer Handler Err */
+#define IXGBE_EICR_DHER         0x20000000	/* Descriptor Handler Error */
+#define IXGBE_EICR_TCP_TIMER    0x40000000	/* TCP Timer */
+#define IXGBE_EICR_OTHER        0x80000000	/* Interrupt Cause Active */
+
+/* Extended Interrupt Cause Set */
+#define IXGBE_EICS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE	/* RTx Queue Int */
+#define IXGBE_EICS_LSC          IXGBE_EICR_LSC	/* Link Status Change */
+#define IXGBE_EICR_GPI_SDP0     0x01000000	/* Gen Purpose Int on SDP0 */
+#define IXGBE_EICS_MNG          IXGBE_EICR_MNG	/* MNG Event Interrupt */
+#define IXGBE_EICS_PBUR         IXGBE_EICR_PBUR	/* Pkt Buf Handler Error */
+#define IXGBE_EICS_DHER         IXGBE_EICR_DHER	/* Desc Handler Error */
+#define IXGBE_EICS_TCP_TIMER    IXGBE_EICR_TCP_TIMER	/* TCP Timer */
+#define IXGBE_EICS_OTHER        IXGBE_EICR_OTHER	/* INT Cause Active */
+
+/* Extended Interrupt Mask Set */
+#define IXGBE_EIMS_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE	/* RTx Queue Int */
+#define IXGBE_EIMS_LSC          IXGBE_EICR_LSC	/* Link Status Change */
+#define IXGBE_EIMS_MNG          IXGBE_EICR_MNG	/* MNG Event Interrupt */
+#define IXGBE_EIMS_PBUR         IXGBE_EICR_PBUR	/* Pkt Buf Handler Error */
+#define IXGBE_EIMS_DHER         IXGBE_EICR_DHER	/* Descr Handler Error */
+#define IXGBE_EIMS_TCP_TIMER    IXGBE_EICR_TCP_TIMER	/* TCP Timer */
+#define IXGBE_EIMS_OTHER        IXGBE_EICR_OTHER	/* INT Cause Active */
+
+/* Extended Interrupt Mask Clear */
+#define IXGBE_EIMC_RTX_QUEUE    IXGBE_EICR_RTX_QUEUE	/* RTx Queue Int */
+#define IXGBE_EIMC_LSC          IXGBE_EICR_LSC	/* Link Status Change */
+#define IXGBE_EIMC_MNG          IXGBE_EICR_MNG	/* MNG Event Interrupt */
+#define IXGBE_EIMC_PBUR         IXGBE_EICR_PBUR	/* Pkt Buf Handler Error */
+#define IXGBE_EIMC_DHER         IXGBE_EICR_DHER	/* Desc Handler Error */
+#define IXGBE_EIMC_TCP_TIMER    IXGBE_EICR_TCP_TIMER	/* TCP Timer */
+#define IXGBE_EIMC_OTHER        IXGBE_EICR_OTHER	/* INT Cause Active */
+
+#define IXGBE_EIMS_ENABLE_MASK ( \
+				IXGBE_EIMS_RTX_QUEUE       | \
+				IXGBE_EIMS_LSC             | \
+				IXGBE_EIMS_TCP_TIMER       | \
+				IXGBE_EIMS_OTHER)
+
+/* Immediate Interrupt RX (A.K.A. Low Latency Interrupt) */
+#define IXGBE_IMIR_PORT_IM_EN     0x00010000	/* TCP port enable */
+#define IXGBE_IMIR_PORT_BP        0x00020000	/* TCP port check bypass */
+#define IXGBE_IMIREXT_SIZE_BP     0x00001000	/* Packet size bypass */
+#define IXGBE_IMIREXT_CTRL_URG    0x00002000	/* Check URG bit in header */
+#define IXGBE_IMIREXT_CTRL_ACK    0x00004000	/* Check ACK bit in header */
+#define IXGBE_IMIREXT_CTRL_PSH    0x00008000	/* Check PSH bit in header */
+#define IXGBE_IMIREXT_CTRL_RST    0x00010000	/* Check RST bit in header */
+#define IXGBE_IMIREXT_CTRL_SYN    0x00020000	/* Check SYN bit in header */
+#define IXGBE_IMIREXT_CTRL_FIN    0x00040000	/* Check FIN bit in header */
+#define IXGBE_IMIREXT_CTRL_BP     0x00080000	/* Bypass check of ctrl bits */
+
+/* Interrupt clear mask */
+#define IXGBE_IRQ_CLEAR_MASK    0xFFFFFFFF
+
+/* Interrupt Vector Allocation Registers */
+#define IXGBE_IVAR_REG_NUM      25
+#define IXGBE_IVAR_TXRX_ENTRY   96
+#define IXGBE_IVAR_RX_ENTRY     64
+#define IXGBE_IVAR_RX_QUEUE(_i)    (0 + (_i))
+#define IXGBE_IVAR_TX_QUEUE(_i)    (64 + (_i))
+#define IXGBE_IVAR_TX_ENTRY     32
+
+#define IXGBE_IVAR_TCP_TIMER_INDEX       96	/* 0 based index */
+#define IXGBE_IVAR_OTHER_CAUSES_INDEX    97	/* 0 based index */
+
+#define IXGBE_MSIX_VECTOR(_i)   (0 + (_i))
+
+#define IXGBE_IVAR_ALLOC_VAL    0x80	/* Interrupt Allocation valid */
+
+/* VLAN Control Bit Masks */
+#define IXGBE_VLNCTRL_VET       0x0000FFFF	/* bits 0-15 */
+#define IXGBE_VLNCTRL_CFI       0x10000000	/* bit 28 */
+#define IXGBE_VLNCTRL_CFIEN     0x20000000	/* bit 29 */
+#define IXGBE_VLNCTRL_VFE       0x40000000	/* bit 30 */
+#define IXGBE_VLNCTRL_VME       0x80000000	/* bit 31 */
+
+#define IXGBE_ETHERNET_IEEE_VLAN_TYPE 0x8100	/* 802.1q protocol */
+
+/* STATUS Bit Masks */
+#define IXGBE_STATUS_LAN_ID     0x0000000C	/* LAN ID */
+#define IXGBE_STATUS_GIO        0x00080000	/* GIO Master Enable Status */
+
+#define IXGBE_STATUS_LAN_ID_0   0x00000000	/* LAN ID 0 */
+#define IXGBE_STATUS_LAN_ID_1   0x00000004	/* LAN ID 1 */
+
+/* ESDP Bit Masks */
+#define IXGBE_ESDP_SDP4         0x00000001	/* SDP4 Data Value */
+#define IXGBE_ESDP_SDP5         0x00000002	/* SDP5 Data Value */
+#define IXGBE_ESDP_SDP4_DIR     0x00000004	/* SDP4 IO direction */
+#define IXGBE_ESDP_SDP5_DIR     0x00000008	/* SDP5 IO direction */
+
+/* LEDCTL Bit Masks */
+#define IXGBE_LED_IVRT_BASE      0x00000040
+#define IXGBE_LED_BLINK_BASE     0x00000080
+#define IXGBE_LED_MODE_MASK_BASE 0x0000000F
+#define IXGBE_LED_OFFSET(_base, _i) (_base << (8 * (_i)))
+#define IXGBE_LED_MODE_SHIFT(_i) (8*(_i))
+#define IXGBE_LED_IVRT(_i)       IXGBE_LED_OFFSET(IXGBE_LED_IVRT_BASE, _i)
+#define IXGBE_LED_BLINK(_i)      IXGBE_LED_OFFSET(IXGBE_LED_BLINK_BASE, _i)
+#define IXGBE_LED_MODE_MASK(_i)  IXGBE_LED_OFFSET(IXGBE_LED_MODE_MASK_BASE, _i)
+
+/* LED modes */
+#define IXGBE_LED_LINK_UP       0x0
+#define IXGBE_LED_LINK_10G      0x1
+#define IXGBE_LED_MAC           0x2
+#define IXGBE_LED_FILTER        0x3
+#define IXGBE_LED_LINK_ACTIVE   0x4
+#define IXGBE_LED_LINK_1G       0x5
+#define IXGBE_LED_ON            0xE
+#define IXGBE_LED_OFF           0xF
+
+/* AUTOC Bit Masks */
+#define IXGBE_AUTOC_KX4_SUPP        0x80000000
+#define IXGBE_AUTOC_KX_SUPP         0x40000000
+#define IXGBE_AUTOC_PAUSE           0x30000000
+#define IXGBE_AUTOC_RF              0x08000000
+#define IXGBE_AUTOC_PD_TMR          0x06000000
+#define IXGBE_AUTOC_AN_RX_LOOSE     0x01000000
+#define IXGBE_AUTOC_AN_RX_DRIFT     0x00800000
+#define IXGBE_AUTOC_AN_RX_ALIGN     0x007C0000
+#define IXGBE_AUTOC_AN_RESTART      0x00001000
+#define IXGBE_AUTOC_FLU             0x00000001
+#define IXGBE_AUTOC_LMS_SHIFT          13
+#define IXGBE_AUTOC_LMS_MASK           (0x7 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_LINK_NO_AN  (0x0 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_10G_LINK_NO_AN (0x1 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_1G_AN          (0x2 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN         (0x4 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_KX4_AN_1G_AN   (0x6 << IXGBE_AUTOC_LMS_SHIFT)
+#define IXGBE_AUTOC_LMS_ATTACH_TYPE    (0x7 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+
+#define IXGBE_AUTOC_1G_PMA_PMD      0x00000200
+#define IXGBE_AUTOC_10G_PMA_PMD     0x00000180
+#define IXGBE_AUTOC_10G_PMA_PMD_SHIFT 7
+#define IXGBE_AUTOC_1G_PMA_PMD_SHIFT 9
+#define IXGBE_AUTOC_10G_XAUI   (0x0 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_10G_KX4    (0x1 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_10G_CX4    (0x2 << IXGBE_AUTOC_10G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_1G_BX      (0x0 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
+#define IXGBE_AUTOC_1G_KX      (0x1 << IXGBE_AUTOC_1G_PMA_PMD_SHIFT)
+
+/* LINKS Bit Masks */
+#define IXGBE_LINKS_KX_AN_COMP      0x80000000
+#define IXGBE_LINKS_UP              0x40000000
+#define IXGBE_LINKS_SPEED           0x20000000
+#define IXGBE_LINKS_MODE            0x18000000
+#define IXGBE_LINKS_RX_MODE         0x06000000
+#define IXGBE_LINKS_TX_MODE         0x01800000
+#define IXGBE_LINKS_XGXS_EN         0x00400000
+#define IXGBE_LINKS_PCS_1G_EN       0x00200000
+#define IXGBE_LINKS_1G_AN_EN        0x00100000
+#define IXGBE_LINKS_KX_AN_IDLE      0x00080000
+#define IXGBE_LINKS_1G_SYNC         0x00040000
+#define IXGBE_LINKS_10G_ALIGN       0x00020000
+#define IXGBE_LINKS_10G_LANE_SYNC   0x00017000
+#define IXGBE_LINKS_TL_FAULT        0x00001000
+#define IXGBE_LINKS_SIGNAL          0x00000F00
+
+#define IXGBE_AUTO_NEG_TIME   45	/* 4.5 Seconds */
+
+/* SW Semaphore Register bitmasks */
+#define IXGBE_SWSM_SMBI         0x00000001	/* Driver Semaphore bit */
+#define IXGBE_SWSM_SWESMBI      0x00000002	/* FW Semaphore bit */
+#define IXGBE_SWSM_WMNG         0x00000004	/* Wake MNG Clock */
+
+/* GSSR definitions */
+#define IXGBE_GSSR_EEP_SM     0x0001
+#define IXGBE_GSSR_PHY0_SM    0x0002
+#define IXGBE_GSSR_PHY1_SM    0x0004
+#define IXGBE_GSSR_MAC_CSR_SM 0x0008
+#define IXGBE_GSSR_FLASH_SM   0x0010
+
+/* EEC Register */
+#define IXGBE_EEC_SK        0x00000001	/* EEPROM Clock */
+#define IXGBE_EEC_CS        0x00000002	/* EEPROM Chip Select */
+#define IXGBE_EEC_DI        0x00000004	/* EEPROM Data In */
+#define IXGBE_EEC_DO        0x00000008	/* EEPROM Data Out */
+#define IXGBE_EEC_FWE_MASK  0x00000030	/* FLASH Write Enable */
+#define IXGBE_EEC_FWE_DIS   0x00000010	/* Disable FLASH writes */
+#define IXGBE_EEC_FWE_EN    0x00000020	/* Enable FLASH writes */
+#define IXGBE_EEC_FWE_SHIFT 4
+#define IXGBE_EEC_REQ       0x00000040	/* EEPROM Access Request */
+#define IXGBE_EEC_GNT       0x00000080	/* EEPROM Access Grant */
+#define IXGBE_EEC_PRES      0x00000100	/* EEPROM Present */
+#define IXGBE_EEC_ARD       0x00000200	/* EEPROM Auto Read Done */
+/* EEPROM Addressing bits based on type (0-small, 1-large) */
+#define IXGBE_EEC_ADDR_SIZE 0x00000400
+#define IXGBE_EEC_SIZE      0x00007800	/* EEPROM Size */
+
+#define IXGBE_EEC_SIZE_SHIFT          11
+#define IXGBE_EEPROM_WORD_SIZE_SHIFT  6
+#define IXGBE_EEPROM_OPCODE_BITS      8
+
+/* Checksum and EEPROM pointers */
+#define IXGBE_EEPROM_CHECKSUM     0x3F
+#define IXGBE_EEPROM_SUM          0xBABA
+#define IXGBE_PCIE_ANALOG_PTR     0x03
+#define IXGBE_ATLAS0_CONFIG_PTR   0x04
+#define IXGBE_ATLAS1_CONFIG_PTR   0x05
+#define IXGBE_PCIE_GENERAL_PTR    0x06
+#define IXGBE_PCIE_CONFIG0_PTR    0x07
+#define IXGBE_PCIE_CONFIG1_PTR    0x08
+#define IXGBE_CORE0_PTR           0x09
+#define IXGBE_CORE1_PTR           0x0A
+#define IXGBE_MAC0_PTR            0x0B
+#define IXGBE_MAC1_PTR            0x0C
+#define IXGBE_CSR0_CONFIG_PTR     0x0D
+#define IXGBE_CSR1_CONFIG_PTR     0x0E
+#define IXGBE_FW_PTR              0x0F
+
+/* EEPROM Commands - SPI */
+#define IXGBE_EEPROM_MAX_RETRY_SPI        5000	/* Max wait 5ms - RDY signal */
+#define IXGBE_EEPROM_STATUS_RDY_SPI       0x01
+#define IXGBE_EEPROM_READ_OPCODE_SPI      0x03	/* EEPROM read opcode */
+#define IXGBE_EEPROM_WRITE_OPCODE_SPI     0x02	/* EEPROM write opcode */
+#define IXGBE_EEPROM_A8_OPCODE_SPI        0x08	/* opcode bit-3 = addr bit-8 */
+#define IXGBE_EEPROM_WREN_OPCODE_SPI      0x06	/* EEPROM set Write Ena latch */
+/* EEPROM reset Write Enbale latch */
+#define IXGBE_EEPROM_WRDI_OPCODE_SPI      0x04
+#define IXGBE_EEPROM_RDSR_OPCODE_SPI      0x05	/* EEPROM read Status reg */
+#define IXGBE_EEPROM_WRSR_OPCODE_SPI      0x01	/* EEPROM write Status reg */
+#define IXGBE_EEPROM_ERASE4K_OPCODE_SPI   0x20	/* EEPROM ERASE 4KB */
+#define IXGBE_EEPROM_ERASE64K_OPCODE_SPI  0xD8	/* EEPROM ERASE 64KB */
+#define IXGBE_EEPROM_ERASE256_OPCODE_SPI  0xDB	/* EEPROM ERASE 256B */
+
+/* EEPROM Read Register */
+#define IXGBE_EEPROM_READ_REG_DATA   16	/* data offset in EEPROM read reg */
+#define IXGBE_EEPROM_READ_REG_DONE   2	/* Offset to READ done bit */
+#define IXGBE_EEPROM_READ_REG_START  1	/* First bit to start operation */
+#define IXGBE_EEPROM_READ_ADDR_SHIFT 2	/* Shift to the address bits */
+
+#define IXGBE_ETH_LENGTH_OF_ADDRESS   6
+
+#ifndef IXGBE_EEPROM_GRANT_ATTEMPTS
+#define IXGBE_EEPROM_GRANT_ATTEMPTS 1000
+				/* EEPROM # attempts to gain grant */
+#endif
+
+#ifndef IXGBE_EERD_ATTEMPTS
+/* Number of 5 microseconds we wait for EERD read to complete */
+#define IXGBE_EERD_ATTEMPTS 100000
+#endif
+
+/* PCI Bus Info */
+#define IXGBE_PCI_LINK_STATUS     0xB2
+#define IXGBE_PCI_LINK_WIDTH      0x3F0
+#define IXGBE_PCI_LINK_WIDTH_1    0x10
+#define IXGBE_PCI_LINK_WIDTH_2    0x20
+#define IXGBE_PCI_LINK_WIDTH_4    0x40
+#define IXGBE_PCI_LINK_WIDTH_8    0x80
+#define IXGBE_PCI_LINK_SPEED      0xF
+#define IXGBE_PCI_LINK_SPEED_2500 0x1
+#define IXGBE_PCI_LINK_SPEED_5000 0x2
+
+/* Number of 100 microseconds we wait for PCI Express master disable */
+#define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800
+
+/* PHY Types */
+#define IXGBE_M88E1145_E_PHY_ID  0x01410CD0
+
+/* Check whether address is multicast.  This is little-endian specific check.*/
+#define IXGBE_IS_MULTICAST(Address) \
+			(boolean_t)(((u8 *)(Address))[0] & ((u8)0x01))
+
+/* Check whether an address is broadcast. */
+#define IXGBE_IS_BROADCAST(Address)               \
+			((((u8 *)(Address))[0] == ((u8)0xff)) && \
+			(((u8 *)(Address))[1] == ((u8)0xff)))
+
+/* RAH */
+#define IXGBE_RAH_VIND_MASK  0x003C0000
+#define IXGBE_RAH_VIND_SHIFT 18
+#define IXGBE_RAH_AV         0x80000000
+
+/* Filters */
+#define IXGBE_MC_TBL_SIZE          128	/* Multicast Filter Table (4096 bits) */
+#define IXGBE_VLAN_FILTER_TBL_SIZE 128	/* VLAN Filter Table (4096 bits) */
+
+/* Header split receive */
+#define IXGBE_RFCTL_ISCSI_DIS           0x00000001
+#define IXGBE_RFCTL_ISCSI_DWC_MASK      0x0000003E
+#define IXGBE_RFCTL_ISCSI_DWC_SHIFT     1
+#define IXGBE_RFCTL_NFSW_DIS            0x00000040
+#define IXGBE_RFCTL_NFSR_DIS            0x00000080
+#define IXGBE_RFCTL_NFS_VER_MASK        0x00000300
+#define IXGBE_RFCTL_NFS_VER_SHIFT       8
+#define IXGBE_RFCTL_NFS_VER_2           0
+#define IXGBE_RFCTL_NFS_VER_3           1
+#define IXGBE_RFCTL_NFS_VER_4           2
+#define IXGBE_RFCTL_IPV6_DIS            0x00000400
+#define IXGBE_RFCTL_IPV6_XSUM_DIS       0x00000800
+#define IXGBE_RFCTL_IPFRSP_DIS          0x00004000
+#define IXGBE_RFCTL_IPV6_EX_DIS         0x00010000
+#define IXGBE_RFCTL_NEW_IPV6_EXT_DIS    0x00020000
+
+/* Transmit Config masks */
+#define IXGBE_TXDCTL_ENABLE        0x02000000	/* Enable specific Tx Queue */
+#define IXGBE_TXDCTL_SWFLSH        0x04000000	/* Tx Desc. WB flushing */
+/* Enable short packet padding to 64 bytes */
+#define IXGBE_TX_PAD_ENABLE        0x00000400
+#define IXGBE_JUMBO_FRAME_ENABLE   0x00000004	/* Allow jumbo frames */
+/* This allows for 16K packets + 4k for vlan */
+#define IXGBE_MAX_FRAME_SZ         0x40040000
+
+#define IXGBE_TDWBAL_HEAD_WB_ENABLE   0x1	/* Tx head write-back enable */
+#define IXGBE_TDWBAL_SEQNUM_WB_ENABLE 0x2	/* Tx seq. # WB enable */
+
+/* Receive Config masks */
+#define IXGBE_RXCTRL_RXEN          0x00000001	/* Enable Receiver */
+#define IXGBE_RXCTRL_DMBYPS        0x00000002	/* Descriptor Monitor Bypass */
+#define IXGBE_RXDCTL_ENABLE        0x02000000	/* Enable specific Rx Queue */
+
+#define IXGBE_FCTRL_SBP             0x00000002	/* Store Bad Packet */
+#define IXGBE_FCTRL_MPE             0x00000100	/* Multicast Promiscuous Ena */
+#define IXGBE_FCTRL_UPE             0x00000200	/* Unicast Promiscuous Ena */
+#define IXGBE_FCTRL_BAM             0x00000400	/* Broadcast Accept Mode */
+#define IXGBE_FCTRL_PMCF            0x00001000	/* Pass MAC Control Frames */
+#define IXGBE_FCTRL_DPF             0x00002000	/* Discard Pause Frame */
+/* Receive Priority Flow Control Enbale */
+#define IXGBE_FCTRL_RPFCE           0x00004000
+#define IXGBE_FCTRL_RFCE            0x00008000	/* Receive Flow Control Ena */
+
+/* Multiple Receive Queue Control */
+#define IXGBE_MRQC_RSSEN                    0x00000001	/* RSS Enable */
+#define IXGBE_MRQC_RSS_FIELD_MASK           0xFFFF0000
+#define IXGBE_MRQC_RSS_FIELD_IPV4_TCP       0x00010000
+#define IXGBE_MRQC_RSS_FIELD_IPV4           0x00020000
+#define IXGBE_MRQC_RSS_FIELD_IPV6_EX_TCP    0x00040000
+#define IXGBE_MRQC_RSS_FIELD_IPV6_EX        0x00080000
+#define IXGBE_MRQC_RSS_FIELD_IPV6           0x00100000
+#define IXGBE_MRQC_RSS_FIELD_IPV6_TCP       0x00200000
+#define IXGBE_MRQC_RSS_FIELD_IPV4_UDP       0x00400000
+#define IXGBE_MRQC_RSS_FIELD_IPV6_UDP       0x00800000
+#define IXGBE_MRQC_RSS_FIELD_IPV6_EX_UDP    0x01000000
+
+#define IXGBE_TXD_POPTS_IXSM 0x01	/* Insert IP checksum */
+#define IXGBE_TXD_POPTS_TXSM 0x02	/* Insert TCP/UDP checksum */
+#define IXGBE_TXD_CMD_EOP    0x01000000	/* End of Packet */
+#define IXGBE_TXD_CMD_IFCS   0x02000000	/* Insert FCS (Ethernet CRC) */
+#define IXGBE_TXD_CMD_IC     0x04000000	/* Insert Checksum */
+#define IXGBE_TXD_CMD_RS     0x08000000	/* Report Status */
+#define IXGBE_TXD_CMD_DEXT   0x20000000	/* Descriptor extension (0 = legacy) */
+#define IXGBE_TXD_CMD_VLE    0x40000000	/* Add VLAN tag */
+#define IXGBE_TXD_STAT_DD    0x00000001	/* Descriptor Done */
+
+/* Receive Descriptor bit definitions */
+#define IXGBE_RXD_STAT_DD       0x01	/* Descriptor Done */
+#define IXGBE_RXD_STAT_EOP      0x02	/* End of Packet */
+#define IXGBE_RXD_STAT_IXSM     0x04	/* Ignore checksum */
+#define IXGBE_RXD_STAT_VP       0x08	/* IEEE VLAN Packet */
+#define IXGBE_RXD_STAT_UDPCS    0x10	/* UDP xsum caculated */
+#define IXGBE_RXD_STAT_L4CS     0x20	/* L4 xsum calculated */
+#define IXGBE_RXD_STAT_IPCS     0x40	/* IP xsum calculated */
+#define IXGBE_RXD_STAT_PIF      0x80	/* passed in-exact filter */
+#define IXGBE_RXD_STAT_CRCV     0x100	/* Speculative CRC Valid */
+#define IXGBE_RXD_STAT_VEXT     0x200	/* 1st VLAN found */
+#define IXGBE_RXD_STAT_UDPV     0x400	/* Valid UDP checksum */
+#define IXGBE_RXD_STAT_DYNINT   0x800	/* Pkt caused INT via DYNINT */
+#define IXGBE_RXD_STAT_ACK      0x8000	/* ACK Packet indication */
+#define IXGBE_RXD_ERR_CE        0x01	/* CRC Error */
+#define IXGBE_RXD_ERR_LE        0x02	/* Length Error */
+#define IXGBE_RXD_ERR_PE        0x08	/* Packet Error */
+#define IXGBE_RXD_ERR_OSE       0x10	/* Oversize Error */
+#define IXGBE_RXD_ERR_USE       0x20	/* Undersize Error */
+#define IXGBE_RXD_ERR_TCPE      0x40	/* TCP/UDP Checksum Error */
+#define IXGBE_RXD_ERR_IPE       0x80	/* IP Checksum Error */
+#define IXGBE_RXDADV_HBO        0x00800000
+#define IXGBE_RXDADV_ERR_CE     0x01000000	/* CRC Error */
+#define IXGBE_RXDADV_ERR_LE     0x02000000	/* Length Error */
+#define IXGBE_RXDADV_ERR_PE     0x08000000	/* Packet Error */
+#define IXGBE_RXDADV_ERR_OSE    0x10000000	/* Oversize Error */
+#define IXGBE_RXDADV_ERR_USE    0x20000000	/* Undersize Error */
+#define IXGBE_RXDADV_ERR_TCPE   0x40000000	/* TCP/UDP Checksum Error */
+#define IXGBE_RXDADV_ERR_IPE    0x80000000	/* IP Checksum Error */
+#define IXGBE_RXD_VLAN_ID_MASK  0x0FFF	/* VLAN ID is in lower 12 bits */
+#define IXGBE_RXD_PRI_MASK      0xE000	/* Priority is in upper 3 bits */
+#define IXGBE_RXD_PRI_SHIFT     13
+#define IXGBE_RXD_CFI_MASK      0x1000	/* CFI is bit 12 */
+#define IXGBE_RXD_CFI_SHIFT     12
+
+/* SRRCTL bit definitions */
+#define IXGBE_SRRCTL_BSIZEPKT_SHIFT                     10
+						/* so many KBs */
+#define IXGBE_SRRCTL_BSIZEPKT_MASK                      0x0000007F
+#define IXGBE_SRRCTL_BSIZEHDR_MASK                      0x00003F00
+#define IXGBE_SRRCTL_DESCTYPE_LEGACY                    0x00000000
+#define IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF                0x02000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT                 0x04000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
+#define IXGBE_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS          0x0A000000
+
+#define IXGBE_RXDPS_HDRSTAT_HDRSP        0x00008000
+#define IXGBE_RXDPS_HDRSTAT_HDRLEN_MASK  0x000003FF
+
+#define IXGBE_RXDADV_RSSTYPE_MASK        0x0000000F
+#define IXGBE_RXDADV_PKTTYPE_MASK        0x0000FFF0
+#define IXGBE_RXDADV_HDRBUFLEN_MASK      0x00007FE0
+#define IXGBE_RXDADV_HDRBUFLEN_SHIFT     5
+#define IXGBE_RXDADV_SPLITHEADER_EN      0x00001000
+#define IXGBE_RXDADV_SPH                 0x8000
+
+/* RSS Hash results */
+#define IXGBE_RXDADV_RSSTYPE_NONE        0x00000000
+#define IXGBE_RXDADV_RSSTYPE_IPV4_TCP    0x00000001
+#define IXGBE_RXDADV_RSSTYPE_IPV4        0x00000002
+#define IXGBE_RXDADV_RSSTYPE_IPV6_TCP    0x00000003
+#define IXGBE_RXDADV_RSSTYPE_IPV6_EX     0x00000004
+#define IXGBE_RXDADV_RSSTYPE_IPV6        0x00000005
+#define IXGBE_RXDADV_RSSTYPE_IPV6_TCP_EX 0x00000006
+#define IXGBE_RXDADV_RSSTYPE_IPV4_UDP    0x00000007
+#define IXGBE_RXDADV_RSSTYPE_IPV6_UDP    0x00000008
+#define IXGBE_RXDADV_RSSTYPE_IPV6_UDP_EX 0x00000009
+
+/* RSS Packet Types as indicated in the receive descriptor. */
+#define IXGBE_RXDADV_PKTTYPE_NONE        0x00000000
+#define IXGBE_RXDADV_PKTTYPE_IPV4        0x00000010	/* IPv4 hdr present */
+#define IXGBE_RXDADV_PKTTYPE_IPV4_EX     0x00000020
+						/* IPv4 hdr + extensions */
+#define IXGBE_RXDADV_PKTTYPE_IPV6        0x00000040	/* IPv6 hdr present */
+#define IXGBE_RXDADV_PKTTYPE_IPV6_EX     0x00000080
+						/* IPv6 hdr + extensions */
+#define IXGBE_RXDADV_PKTTYPE_TCP         0x00000100	/* TCP hdr present */
+#define IXGBE_RXDADV_PKTTYPE_UDP         0x00000200	/* UDP hdr present */
+#define IXGBE_RXDADV_PKTTYPE_SCTP        0x00000400	/* SCTP hdr present */
+#define IXGBE_RXDADV_PKTTYPE_NFS         0x00000800	/* NFS hdr present */
+
+/* Masks to determine if packets should be dropped due to frame errors */
+#define IXGBE_RXD_ERR_FRAME_ERR_MASK ( \
+					IXGBE_RXD_ERR_CE | \
+					IXGBE_RXD_ERR_LE | \
+					IXGBE_RXD_ERR_PE | \
+					IXGBE_RXD_ERR_OSE | \
+					IXGBE_RXD_ERR_USE)
+
+#define IXGBE_RXDADV_ERR_FRAME_ERR_MASK ( \
+					IXGBE_RXDADV_ERR_CE | \
+					IXGBE_RXDADV_ERR_LE | \
+					IXGBE_RXDADV_ERR_PE | \
+					IXGBE_RXDADV_ERR_OSE | \
+					IXGBE_RXDADV_ERR_USE)
+
+/* Multicast bit mask */
+#define IXGBE_MCSTCTRL_MFE        0x4
+
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
+#define IXGBE_REQ_TX_DESCRIPTOR_MULTIPLE  8
+#define IXGBE_REQ_RX_DESCRIPTOR_MULTIPLE  8
+#define IXGBE_REQ_TX_BUFFER_GRANULARITY   1024
+
+/* Vlan-specific macros */
+#define IXGBE_RX_DESC_SPECIAL_VLAN_MASK  0x0FFF	/* VLAN ID in lower 12 bits */
+#define IXGBE_RX_DESC_SPECIAL_PRI_MASK   0xE000	/* Priority in upper 3 bits */
+#define IXGBE_RX_DESC_SPECIAL_PRI_SHIFT  0x000D	/* Priority in upper 3 of 16 */
+#define IXGBE_TX_DESC_SPECIAL_PRI_SHIFT  IXGBE_RX_DESC_SPECIAL_PRI_SHIFT
+
+/* Transmit Descriptor - Legacy */
+struct ixgbe_legacy_tx_desc {
+	u64 buffer_addr;	/* Address of the descriptor's data buffer */
+	union {
+		u32 data;
+		struct {
+			u16 length;	/* Data buffer length */
+			u8 cso;	/* Checksum offset */
+			u8 cmd;	/* Descriptor control */
+		} flags;
+	} lower;
+	union {
+		u32 data;
+		struct {
+			u8 status;	/* Descriptor status */
+			u8 css;	/* Checksum start */
+			u16 vlan;
+		} fields;
+	} upper;
+};
+
+/* Transmit Descriptor - Advanced */
+union ixgbe_adv_tx_desc {
+	struct {
+		u64 buffer_addr;	/* Address of descriptor's data buf */
+		u32 cmd_type_len;
+		u32 olinfo_status;
+	} read;
+	struct {
+		u64 rsvd;	/* Reserved */
+		u32 nxtseq_seed;
+		u32 status;
+	} wb;
+};
+
+/* Receive Descriptor - Legacy */
+struct ixgbe_legacy_rx_desc {
+	u64 buffer_addr;	/* Address of the descriptor's data buffer */
+	u16 length;		/* Length of data DMAed into data buffer */
+	u16 csum;		/* Packet checksum */
+	u8 status;		/* Descriptor status */
+	u8 errors;		/* Descriptor Errors */
+	u16 vlan;
+};
+
+/* Receive Descriptor - Advanced */
+union ixgbe_adv_rx_desc {
+	struct {
+		u64 pkt_addr;	/* Packet buffer address */
+		u64 hdr_addr;	/* Header buffer address */
+	} read;
+	struct {
+		struct {
+			struct {
+				u16 pkt_info;	/* RSS type, Packet type */
+				u16 hdr_info;	/* Split Header, header len */
+			} lo_dword;
+			union {
+				u32 rss;	/* RSS Hash */
+				struct {
+					u16 ip_id;	/* IP id */
+					u16 csum;	/* Packet Checksum */
+				} csum_ip;
+			} hi_dword;
+		} lower;
+		struct {
+			u32 status_error;	/* ext status/error */
+			u16 length;	/* Packet length */
+			u16 vlan;	/* VLAN tag */
+		} upper;
+	} wb;			/* writeback */
+};
+
+/* Context descriptors */
+struct ixgbe_adv_tx_context_desc {
+	u32 vlan_macip_lens;
+	u32 seqnum_seed;
+	u32 type_tucmd_mlhl;
+	u32 mss_l4len_idx;
+};
+
+/* Adv Transmit Descriptor Config Masks */
+#define IXGBE_ADVTXD_DTALEN_MASK      0x0000FFFF
+#define IXGBE_ADVTXD_DTYP_MASK        0x00F00000	/* DTYP mask */
+#define IXGBE_ADVTXD_DTYP_CTXT        0x00200000	/* Adv Context Desc */
+#define IXGBE_ADVTXD_DTYP_DATA        0x00300000	/* Adv Data Des */
+#define IXGBE_ADVTXD_DCMD_EOP         IXGBE_TXD_CMD_EOP	/* End of Packet */
+#define IXGBE_ADVTXD_DCMD_IFCS        IXGBE_TXD_CMD_IFCS	/* Insert FCS */
+#define IXGBE_ADVTXD_DCMD_RDMA        0x04000000	/* RDMA */
+#define IXGBE_ADVTXD_DCMD_RS          IXGBE_TXD_CMD_RS	/* Report Status */
+#define IXGBE_ADVTXD_DCMD_DDTYP_ISCSI 0x10000000	/* DDP hdr type/iSCSI */
+#define IXGBE_ADVTXD_DCMD_DEXT        IXGBE_TXD_CMD_DEXT
+						/* Desc ext (1=Adv) */
+#define IXGBE_ADVTXD_DCMD_VLE         IXGBE_TXD_CMD_VLE	/* VLAN pkt enable */
+#define IXGBE_ADVTXD_DCMD_TSE         0x80000000	/* TCP Seg enable */
+#define IXGBE_ADVTXD_STAT_DD          IXGBE_TXD_STAT_DD	/* Descriptor Done */
+#define IXGBE_ADVTXD_STAT_SN_CRC      0x00000002
+						/* NXTSEQ/SEED present in WB */
+#define IXGBE_ADVTXD_STAT_RSV         0x0000000C	/* STA Reserved */
+#define IXGBE_ADVTXD_IDX_SHIFT        4	/* Adv desc Index shift */
+#define IXGBE_ADVTXD_POPTS_SHIFT      8	/* Adv desc POPTS shift */
+#define IXGBE_ADVTXD_POPTS_IXSM       (IXGBE_TXD_POPTS_IXSM << \
+				       IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_POPTS_TXSM       (IXGBE_TXD_POPTS_TXSM << \
+				       IXGBE_ADVTXD_POPTS_SHIFT)
+#define IXGBE_ADVTXD_POPTS_EOM        0x00000400
+						/* Enable L bit-RDMA DDP hdr */
+#define IXGBE_ADVTXD_POPTS_ISCO_1ST   0x00000000
+						/* 1st TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_MDL   0x00000800
+						/* Middle TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_LAST  0x00001000
+						/* Last TSO of iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_ISCO_FULL 0x00001800
+					/* 1st&Last TSO-full iSCSI PDU */
+#define IXGBE_ADVTXD_POPTS_RSV        0x00002000	/* POPTS Reserved */
+#define IXGBE_ADVTXD_PAYLEN_SHIFT     14	/* Adv desc PAYLEN shift */
+#define IXGBE_ADVTXD_MACLEN_SHIFT  9	/* Adv ctxt desc mac len shift */
+#define IXGBE_ADVTXD_VLAN_SHIFT    16	/* Adv ctxt vlan tag shift */
+#define IXGBE_ADVTXD_TUCMD_IPV4    0x00000400	/* IP Packet Type: 1=IPv4 */
+#define IXGBE_ADVTXD_TUCMD_IPV6    0x00000000	/* IP Packet Type: 0=IPv6 */
+#define IXGBE_ADVTXD_TUCMD_L4T_UDP 0x00000000	/* L4 Packet TYPE of UDP */
+#define IXGBE_ADVTXD_TUCMD_L4T_TCP 0x00000800	/* L4 Packet TYPE of TCP */
+#define IXGBE_ADVTXD_TUCMD_MKRREQ  0x00002000
+					/* Req requires Markers and CRC */
+#define IXGBE_ADVTXD_L4LEN_SHIFT     8	/* Adv ctxt L4LEN shift */
+#define IXGBE_ADVTXD_MSS_SHIFT      16	/* Adv ctxt MSS shift */
+
+/* Link speed */
+#define IXGBE_LINK_SPEED_UNKNOWN   0
+#define IXGBE_LINK_SPEED_1GB_FULL  0x0020
+#define IXGBE_LINK_SPEED_10GB_FULL 0x0080
+
+enum ixgbe_eeprom_type {
+	ixgbe_eeprom_uninitialized = 0,
+	ixgbe_eeprom_spi,
+	ixgbe_eeprom_none	/* No NVM support */
+};
+
+enum ixgbe_mac_type {
+	ixgbe_mac_unknown = 0,
+	ixgbe_mac_82598EB,
+	ixgbe_num_macs
+};
+
+enum ixgbe_phy_type {
+	ixgbe_phy_unknown = 0,
+	ixgbe_phy_tn,
+	ixgbe_phy_qt,
+	ixgbe_phy_xaui
+};
+
+enum ixgbe_media_type {
+	ixgbe_media_type_unknown = 0,
+	ixgbe_media_type_fiber,
+	ixgbe_media_type_copper,
+	ixgbe_media_type_backplane
+};
+
+/* Flow Control Settings */
+enum ixgbe_fc_type {
+	ixgbe_fc_none = 0,
+	ixgbe_fc_rx_pause,
+	ixgbe_fc_tx_pause,
+	ixgbe_fc_full,
+	ixgbe_fc_default
+};
+
+/* PCI bus types */
+enum ixgbe_bus_type {
+	ixgbe_bus_type_unknown = 0,
+	ixgbe_bus_type_pci_express,
+	ixgbe_bus_type_reserved
+};
+
+/* PCI bus speeds */
+enum ixgbe_bus_speed {
+	ixgbe_bus_speed_unknown = 0,
+	ixgbe_bus_speed_2500,
+	ixgbe_bus_speed_5000,
+	ixgbe_bus_speed_reserved
+};
+
+/* PCI bus widths */
+enum ixgbe_bus_width {
+	ixgbe_bus_width_unknown = 0,
+	ixgbe_bus_width_pciex_1,
+	ixgbe_bus_width_pciex_2,
+	ixgbe_bus_width_pciex_4,
+	ixgbe_bus_width_pciex_8,
+	ixgbe_bus_width_reserved
+};
+
+struct ixgbe_eeprom_info {
+	enum ixgbe_eeprom_type type;
+	u16 word_size;
+	u16 address_bits;
+};
+
+struct ixgbe_addr_filter {
+	u32 num_mc_addrs;
+	u32 rar_used_count;
+	u32 mc_addr_in_rar_count;
+	u32 mta_in_use;
+};
+
+/* Bus parameters */
+struct ixgbe_bus {
+	enum ixgbe_bus_speed speed;
+	enum ixgbe_bus_width width;
+	enum ixgbe_bus_type type;
+};
+
+/* Flow control parameters */
+struct ixgbe_fc {
+	u32 high_water;		/* Flow Control High-water */
+	u32 low_water;		/* Flow Control Low-water */
+	u16 pause_time;		/* Flow Control Pause timer */
+	boolean_t send_xon;	/* Flow control send XON */
+	enum ixgbe_fc_type type;	/* Type of flow control */
+	enum ixgbe_fc_type original_type;
+};
+
+/* Statistics counters collected by the MAC */
+struct ixgbe_hw_stats {
+	u64 crcerrs;
+	u64 illerrc;
+	u64 errbc;
+	u64 mspdc;
+	u64 mpctotal;
+	u64 mpc[8];
+	u64 mlfc;
+	u64 mrfc;
+	u64 rlec;
+	u64 lxontxc;
+	u64 lxonrxc;
+	u64 lxofftxc;
+	u64 lxoffrxc;
+	u64 pxontxc[8];
+	u64 pxonrxc[8];
+	u64 pxofftxc[8];
+	u64 pxoffrxc[8];
+	u64 prc64;
+	u64 prc127;
+	u64 prc255;
+	u64 prc511;
+	u64 prc1023;
+	u64 prc1522;
+	u64 gprc;
+	u64 bprc;
+	u64 mprc;
+	u64 gptc;
+	u64 gorc;
+	u64 gotc;
+	u64 rnbc[8];
+	u64 ruc;
+	u64 rfc;
+	u64 roc;
+	u64 rjc;
+	u64 mngprc;
+	u64 mngpdc;
+	u64 mngptc;
+	u64 tor;
+	u64 tpr;
+	u64 tpt;
+	u64 ptc64;
+	u64 ptc127;
+	u64 ptc255;
+	u64 ptc511;
+	u64 ptc1023;
+	u64 ptc1522;
+	u64 mptc;
+	u64 bptc;
+	u64 xec;
+	u64 rqsmr[16];
+	u64 tqsmr[8];
+	u64 qprc[16];
+	u64 qptc[16];
+	u64 qbrc[16];
+	u64 qbtc[16];
+};
+
+/* forward declaration */
+struct ixgbe_hw;
+
+/* Function pointer table */
+struct ixgbe_function_table {
+	s32(*ixgbe_func_hw_init) (struct ixgbe_hw *);
+	s32(*ixgbe_func_hw_reset) (struct ixgbe_hw *);
+	s32(*ixgbe_func_hw_start) (struct ixgbe_hw *);
+	s32(*ixgbe_func_hw_clear_cntrs) (struct ixgbe_hw *);
+	enum ixgbe_media_type (*ixgbe_func_adapter_get_media_type)
+	 (struct ixgbe_hw *);
+	 s32(*ixgbe_func_adapter_get_mac_addr) (struct ixgbe_hw *, u8 *);
+	 u32(*ixgbe_func_adapter_get_num_of_tx_queues) (struct ixgbe_hw *);
+	 u32(*ixgbe_func_adapter_get_num_of_rx_queues) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_adapter_stop) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_adapter_determine_bus_info) (struct ixgbe_hw *);
+
+	/* PHY */
+	 s32(*ixgbe_func_phy_identify) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_phy_reset) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_phy_read_reg) (struct ixgbe_hw *, u32, u32, u16 *);
+	 s32(*ixgbe_func_phy_write_reg) (struct ixgbe_hw *, u32, u32, u16);
+	 s32(*ixgbe_func_phy_link_setup) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_phy_link_setup_speed) (struct ixgbe_hw *,
+						u32, boolean_t, boolean_t);
+	 s32(*ixgbe_func_phy_link_check) (struct ixgbe_hw *, u32 *,
+					  boolean_t *);
+
+	/* Link */
+	 s32(*ixgbe_func_link_setup) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_link_setup_speed) (struct ixgbe_hw *, u32,
+					    boolean_t, boolean_t);
+	 s32(*ixgbe_func_link_check) (struct ixgbe_hw *, u32 *, boolean_t *);
+	 s32(*ixgbe_func_link_get_settings) (struct ixgbe_hw *, u32 *,
+					     boolean_t *);
+
+	/* LED */
+	 s32(*ixgbe_func_led_on) (struct ixgbe_hw *, u32);
+	 s32(*ixgbe_func_led_off) (struct ixgbe_hw *, u32);
+	 s32(*ixgbe_func_led_blink_start) (struct ixgbe_hw *, u32);
+	 s32(*ixgbe_func_led_blink_stop) (struct ixgbe_hw *, u32);
+
+	/* EEPROM */
+	 s32(*ixgbe_func_eeprom_init_params) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_eeprom_read) (struct ixgbe_hw *, u16, u16 *);
+	 s32(*ixgbe_func_eeprom_write) (struct ixgbe_hw *, u16, u16);
+	 s32(*ixgbe_func_eeprom_validate_checksum) (struct ixgbe_hw *, u16 *);
+	 s32(*ixgbe_func_eeprom_update_checksum) (struct ixgbe_hw *);
+
+	/* RAR, Multicast, VLAN */
+	 s32(*ixgbe_func_rar_set) (struct ixgbe_hw *, u32, u8 *, u32, u32);
+	 s32(*ixgbe_func_init_rx_addrs) (struct ixgbe_hw *);
+	 u32(*ixgbe_func_get_num_rx_addrs) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_mc_addr_list_update) (struct ixgbe_hw *, u8 *, u32,
+					       u32);
+	 s32(*ixgbe_func_mc_enable) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_mc_disable) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_vfta_clear) (struct ixgbe_hw *);
+	 s32(*ixgbe_func_vfta_set) (struct ixgbe_hw *, u32, u32, boolean_t);
+
+	/* Flow Control */
+	 s32(*ixgbe_func_fc_setup) (struct ixgbe_hw *, s32);
+};
+
+struct ixgbe_phy_info {
+	enum ixgbe_phy_type type;
+	u32 addr;
+	u32 id;
+	u32 revision;
+};
+
+struct ixgbe_hw {
+	u8 *hw_addr;
+	void *back;
+	struct ixgbe_function_table func_table;
+	struct ixgbe_bus bus;
+	struct ixgbe_eeprom_info eeprom;
+	struct ixgbe_addr_filter addr_ctrl;
+	struct ixgbe_fc fc;
+	struct ixgbe_phy_info phy;
+	enum ixgbe_mac_type mac_type;
+	enum ixgbe_media_type media_type;
+	u32 autoneg_advertised;
+	s32 mc_filter_type;
+	u32 link_attach_type;
+	u32 link_mode_select;
+	u16 device_id;
+	u16 vendor_id;
+	u16 subsystem_id;
+	u16 subsystem_vendor_id;
+	u8 revision_id;
+	u8 curr_mac_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	u8 perm_mac_addr[IXGBE_ETH_LENGTH_OF_ADDRESS];
+	boolean_t autoneg;
+	boolean_t autoneg_wait_to_complete;
+	boolean_t adapter_stopped;
+};
+
+#define ixgbe_func_from_hw_struct(hw, func) hw->func_table.func
+
+#define ixgbe_call_func(hw, func, params, error) \
+			(ixgbe_func_from_hw_struct(hw, func) != NULL) ? \
+			ixgbe_func_from_hw_struct(hw, func) params: error
+
+/* Error Codes */
+#define IXGBE_SUCCESS                     0
+#define IXGBE_ERR_EEPROM                  -1
+#define IXGBE_ERR_EEPROM_CHECKSUM         -2
+#define IXGBE_ERR_PHY                     -3
+#define IXGBE_ERR_CONFIG                  -4
+#define IXGBE_ERR_PARAM                   -5
+#define IXGBE_ERR_MAC_TYPE                -6
+#define IXGBE_ERR_UNKNOWN_PHY             -7
+#define IXGBE_ERR_LINK_SETUP              -8
+#define IXGBE_ERR_ADAPTER_STOPPED         -9
+#define IXGBE_ERR_INVALID_MAC_ADDR        -10
+#define IXGBE_ERR_DEVICE_NOT_SUPPORTED    -11
+#define IXGBE_ERR_MASTER_REQUESTS_PENDING -12
+#define IXGBE_ERR_INVALID_LINK_SETTINGS   -13
+#define IXGBE_ERR_AUTONEG_NOT_COMPLETE    -14
+#define IXGBE_ERR_RESET_FAILED            -15
+#define IXGBE_ERR_SWFW_SYNC               -16
+#define IXGBE_ERR_PHY_ADDR_INVALID        -17
+#define IXGBE_NOT_IMPLEMENTED             0x7FFFFFFF
+
+#endif				/* _IXGBE_TYPE_H_ */
