From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: split main file into pieces
Date: Mon, 29 Sep 2008 03:34:59 +0200
Message-ID: <48E030C3.20605@myri.com>
References: <48E02FD1.2010502@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1986 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753100AbYI2BeX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 21:34:23 -0400
In-Reply-To: <48E02FD1.2010502@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move ethtool-related functions to myri10ge_ethtool.c.
Move firmware-probing/selecting/loading routines to myri10ge_firmware.c.
Move types and defines to myri10ge.h, and add some prototypes.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/Makefile            |    2 +-
 drivers/net/myri10ge/myri10ge.h          |  244 ++++++++++
 drivers/net/myri10ge/myri10ge_ethtool.c  |  362 ++++++++++++++
 drivers/net/myri10ge/myri10ge_firmware.c |  309 ++++++++++++
 drivers/net/myri10ge/myri10ge_main.c     |  779 +-----------------------------
 5 files changed, 926 insertions(+), 770 deletions(-)
 create mode 100644 drivers/net/myri10ge/myri10ge.h
 create mode 100644 drivers/net/myri10ge/myri10ge_ethtool.c
 create mode 100644 drivers/net/myri10ge/myri10ge_firmware.c

diff --git a/drivers/net/myri10ge/Makefile b/drivers/net/myri10ge/Makefile
index 597440c..98bf3bf 100644
--- a/drivers/net/myri10ge/Makefile
+++ b/drivers/net/myri10ge/Makefile
@@ -4,4 +4,4 @@
 
 obj-$(CONFIG_MYRI10GE) += myri10ge.o
 
-myri10ge-objs := myri10ge_main.o
+myri10ge-objs := myri10ge_main.o myri10ge_firmware.o myri10ge_ethtool.o
diff --git a/drivers/net/myri10ge/myri10ge.h b/drivers/net/myri10ge/myri10ge.h
new file mode 100644
index 0000000..a10e01a
--- /dev/null
+++ b/drivers/net/myri10ge/myri10ge.h
@@ -0,0 +1,244 @@
+/*************************************************************************
+ * myri10ge.c: Myricom Myri-10G Ethernet driver.
+ *
+ * Copyright (C) 2005 - 2007 Myricom, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Myricom, Inc. nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * If the eeprom on your board is not recent enough, you will need to get a
+ * newer firmware image at:
+ *   http://www.myri.com/scs/download-Myri10GE.html
+ *
+ * Contact Information:
+ *   <help@myri.com>
+ *   Myricom, Inc., 325N Santa Anita Avenue, Arcadia, CA 91006
+ *************************************************************************/
+
+#ifndef __MYRI10GE_H__
+#define __MYRI10GE_H__
+
+#define MYRI10GE_MAX_ETHER_MTU 9014
+
+#define MYRI10GE_ETH_STOPPED 0
+#define MYRI10GE_ETH_STOPPING 1
+#define MYRI10GE_ETH_STARTING 2
+#define MYRI10GE_ETH_RUNNING 3
+#define MYRI10GE_ETH_OPEN_FAILED 4
+
+#define MYRI10GE_EEPROM_STRINGS_SIZE 256
+#define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
+#define MYRI10GE_MAX_LRO_DESCRIPTORS 8
+#define MYRI10GE_LRO_MAX_PKTS 64
+
+#define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
+#define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
+
+#define MYRI10GE_ALLOC_ORDER 0
+#define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
+#define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
+
+#define MYRI10GE_MAX_SLICES 32
+
+struct myri10ge_rx_buffer_state {
+	struct page *page;
+	int page_offset;
+	 DECLARE_PCI_UNMAP_ADDR(bus)
+	 DECLARE_PCI_UNMAP_LEN(len)
+};
+
+struct myri10ge_tx_buffer_state {
+	struct sk_buff *skb;
+	int last;
+	 DECLARE_PCI_UNMAP_ADDR(bus)
+	 DECLARE_PCI_UNMAP_LEN(len)
+};
+
+struct myri10ge_cmd {
+	u32 data0;
+	u32 data1;
+	u32 data2;
+};
+
+struct myri10ge_rx_buf {
+	struct mcp_kreq_ether_recv __iomem *lanai;	/* lanai ptr for recv ring */
+	struct mcp_kreq_ether_recv *shadow;	/* host shadow of recv ring */
+	struct myri10ge_rx_buffer_state *info;
+	struct page *page;
+	dma_addr_t bus;
+	int page_offset;
+	int cnt;
+	int fill_cnt;
+	int alloc_fail;
+	int mask;		/* number of rx slots -1 */
+	int watchdog_needed;
+};
+
+struct myri10ge_tx_buf {
+	struct mcp_kreq_ether_send __iomem *lanai;	/* lanai ptr for sendq */
+	__be32 __iomem *send_go;	/* "go" doorbell ptr */
+	__be32 __iomem *send_stop;	/* "stop" doorbell ptr */
+	struct mcp_kreq_ether_send *req_list;	/* host shadow of sendq */
+	char *req_bytes;
+	struct myri10ge_tx_buffer_state *info;
+	int mask;		/* number of transmit slots -1  */
+	int req ____cacheline_aligned;	/* transmit slots submitted     */
+	int pkt_start;		/* packets started */
+	int stop_queue;
+	int linearized;
+	int done ____cacheline_aligned;	/* transmit slots completed     */
+	int pkt_done;		/* packets completed */
+	int wake_queue;
+	int queue_active;
+};
+
+struct myri10ge_rx_done {
+	struct mcp_slot *entry;
+	dma_addr_t bus;
+	int cnt;
+	int idx;
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
+};
+
+struct myri10ge_slice_netstats {
+	unsigned long rx_packets;
+	unsigned long tx_packets;
+	unsigned long rx_bytes;
+	unsigned long tx_bytes;
+	unsigned long rx_dropped;
+	unsigned long tx_dropped;
+};
+
+struct myri10ge_slice_state {
+	struct myri10ge_tx_buf tx;	/* transmit ring        */
+	struct myri10ge_rx_buf rx_small;
+	struct myri10ge_rx_buf rx_big;
+	struct myri10ge_rx_done rx_done;
+	struct net_device *dev;
+	struct napi_struct napi;
+	struct myri10ge_priv *mgp;
+	struct myri10ge_slice_netstats stats;
+	__be32 __iomem *irq_claim;
+	struct mcp_irq_data *fw_stats;
+	dma_addr_t fw_stats_bus;
+	int watchdog_tx_done;
+	int watchdog_tx_req;
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+	int cached_dca_tag;
+	int cpu;
+	__be32 __iomem *dca_tag;
+#endif
+	char irq_desc[32];
+};
+
+struct myri10ge_priv {
+	struct myri10ge_slice_state *ss;
+	int tx_boundary;	/* boundary transmits cannot cross */
+	int num_slices;
+	int running;		/* running?             */
+	int csum_flag;		/* rx_csums?            */
+	int small_bytes;
+	int big_bytes;
+	int max_intr_slots;
+	struct net_device *dev;
+	struct net_device_stats stats;
+	spinlock_t stats_lock;
+	u8 __iomem *sram;
+	int sram_size;
+	unsigned long board_span;
+	unsigned long iomem_base;
+	__be32 __iomem *irq_deassert;
+	char *mac_addr_string;
+	struct mcp_cmd_response *cmd;
+	dma_addr_t cmd_bus;
+	struct pci_dev *pdev;
+	int msi_enabled;
+	int msix_enabled;
+	struct msix_entry *msix_vectors;
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+	int dca_enabled;
+#endif
+	u32 link_state;
+	unsigned int rdma_tags_available;
+	int intr_coal_delay;
+	__be32 __iomem *intr_coal_delay_ptr;
+	int mtrr;
+	int wc_enabled;
+	int down_cnt;
+	wait_queue_head_t down_wq;
+	struct work_struct watchdog_work;
+	struct timer_list watchdog_timer;
+	int watchdog_resets;
+	int watchdog_pause;
+	int pause;
+	char *fw_name;
+	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
+	char *product_code_string;
+	char fw_version[128];
+	int fw_ver_major;
+	int fw_ver_minor;
+	int fw_ver_tiny;
+	int adopted_rx_filter_bug;
+	u8 mac_addr[6];		/* eeprom mac address */
+	unsigned long serial_number;
+	int vendor_specific_offset;
+	int fw_multicast_support;
+	unsigned long features;
+	u32 max_tso6;
+	u32 read_dma;
+	u32 write_dma;
+	u32 read_write_dma;
+	u32 link_changes;
+	u32 msg_enable;
+};
+
+extern char *myri10ge_fw_unaligned;
+extern char *myri10ge_fw_aligned;
+extern char *myri10ge_fw_rss_unaligned;
+extern char *myri10ge_fw_rss_aligned;
+extern char *myri10ge_fw_name;
+extern const struct ethtool_ops myri10ge_ethtool_ops;
+extern int myri10ge_tso6;
+
+int myri10ge_load_firmware(struct myri10ge_priv *mgp, int adopt);
+int myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
+		      struct myri10ge_cmd *data, int atomic);
+void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable);
+int myri10ge_change_pause(struct myri10ge_priv *mgp, int pause);
+
+#define MYRI10GE_FW_OFFSET 1024*1024
+#define MYRI10GE_HIGHPART_TO_U32(X) \
+(sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
+#define MYRI10GE_LOWPART_TO_U32(X) ((u32)(X))
+
+#define put_be32(val, p) __raw_writel((__force __u32)(val), (__force void __iomem *)(p))
+
+#define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
+
+#define MYRI10GE_VERSION_STR "1.4.3-1.366"
+
+#endif /* __MYRI10GE_H__ */
diff --git a/drivers/net/myri10ge/myri10ge_ethtool.c b/drivers/net/myri10ge/myri10ge_ethtool.c
new file mode 100644
index 0000000..d095a8c
--- /dev/null
+++ b/drivers/net/myri10ge/myri10ge_ethtool.c
@@ -0,0 +1,362 @@
+/*************************************************************************
+ * myri10ge.c: Myricom Myri-10G Ethernet driver.
+ *
+ * Copyright (C) 2005 - 2008 Myricom, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Myricom, Inc. nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * If the eeprom on your board is not recent enough, you will need to get a
+ * newer firmware image at:
+ *   http://www.myri.com/scs/download-Myri10GE.html
+ *
+ * Contact Information:
+ *   <help@myri.com>
+ *   Myricom, Inc., 325N Santa Anita Avenue, Arcadia, CA 91006
+ *************************************************************************/
+
+#include <linux/string.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <linux/inet_lro.h>
+#include <linux/dca.h>
+#include <linux/ethtool.h>
+#include <linux/firmware.h>
+#include "myri10ge_mcp.h"
+#include "myri10ge.h"
+
+static int
+myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	char *ptr;
+	int i;
+
+	cmd->autoneg = AUTONEG_DISABLE;
+	cmd->speed = SPEED_10000;
+	cmd->duplex = DUPLEX_FULL;
+
+	/*
+	 * parse the product code to deterimine the interface type
+	 * (CX4, XFP, Quad Ribbon Fiber) by looking at the character
+	 * after the 3rd dash in the driver's cached copy of the
+	 * EEPROM's product code string.
+	 */
+	ptr = mgp->product_code_string;
+	if (ptr == NULL) {
+		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
+		       netdev->name);
+		return 0;
+	}
+	for (i = 0; i < 3; i++, ptr++) {
+		ptr = strchr(ptr, '-');
+		if (ptr == NULL) {
+			printk(KERN_ERR "myri10ge: %s: Invalid product "
+			       "code %s\n", netdev->name,
+			       mgp->product_code_string);
+			return 0;
+		}
+	}
+	if (*ptr == 'R' || *ptr == 'Q') {
+		/* We've found either an XFP or quad ribbon fiber */
+		cmd->port = PORT_FIBRE;
+	}
+	return 0;
+}
+
+static void
+myri10ge_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *info)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	strlcpy(info->driver, "myri10ge", sizeof(info->driver));
+	strlcpy(info->version, MYRI10GE_VERSION_STR, sizeof(info->version));
+	strlcpy(info->fw_version, mgp->fw_version, sizeof(info->fw_version));
+	strlcpy(info->bus_info, pci_name(mgp->pdev), sizeof(info->bus_info));
+}
+
+static int
+myri10ge_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	coal->rx_coalesce_usecs = mgp->intr_coal_delay;
+	return 0;
+}
+
+static int
+myri10ge_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	mgp->intr_coal_delay = coal->rx_coalesce_usecs;
+	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
+	return 0;
+}
+
+static void
+myri10ge_get_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *pause)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	pause->autoneg = 0;
+	pause->rx_pause = mgp->pause;
+	pause->tx_pause = mgp->pause;
+}
+
+static int
+myri10ge_set_pauseparam(struct net_device *netdev,
+			struct ethtool_pauseparam *pause)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	if (pause->tx_pause != mgp->pause)
+		return myri10ge_change_pause(mgp, pause->tx_pause);
+	if (pause->rx_pause != mgp->pause)
+		return myri10ge_change_pause(mgp, pause->tx_pause);
+	if (pause->autoneg != 0)
+		return -EINVAL;
+	return 0;
+}
+
+static void
+myri10ge_get_ringparam(struct net_device *netdev,
+		       struct ethtool_ringparam *ring)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	ring->rx_mini_max_pending = mgp->ss[0].rx_small.mask + 1;
+	ring->rx_max_pending = mgp->ss[0].rx_big.mask + 1;
+	ring->rx_jumbo_max_pending = 0;
+	ring->tx_max_pending = mgp->ss[0].rx_small.mask + 1;
+	ring->rx_mini_pending = ring->rx_mini_max_pending;
+	ring->rx_pending = ring->rx_max_pending;
+	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
+	ring->tx_pending = ring->tx_max_pending;
+}
+
+static u32 myri10ge_get_rx_csum(struct net_device *netdev)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	if (mgp->csum_flag)
+		return 1;
+	else
+		return 0;
+}
+
+static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	if (csum_enabled)
+		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
+	else
+		mgp->csum_flag = 0;
+	return 0;
+}
+
+static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	unsigned long flags = mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
+
+	if (tso_enabled)
+		netdev->features |= flags;
+	else
+		netdev->features &= ~flags;
+	return 0;
+}
+
+static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
+	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
+	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
+	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
+	"rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
+	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
+	"tx_heartbeat_errors", "tx_window_errors",
+	/* device-specific stats */
+	"tx_boundary", "WC", "irq", "MSI", "MSIX",
+	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
+	"serial_number", "watchdog_resets",
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+	"dca_capable_firmware", "dca_device_present",
+#endif
+	"link_changes", "link_up", "dropped_link_overflow",
+	"dropped_link_error_or_filtered",
+	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
+	"dropped_unicast_filtered", "dropped_multicast_filtered",
+	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
+	"dropped_no_big_buffer"
+};
+
+static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
+	"----------- slice ---------",
+	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
+	"rx_small_cnt", "rx_big_cnt",
+	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
+	    "LRO flushed",
+	"LRO avg aggr", "LRO no_desc"
+};
+
+#define MYRI10GE_NET_STATS_LEN      21
+#define MYRI10GE_MAIN_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_main_stats)
+#define MYRI10GE_SLICE_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_slice_stats)
+
+static void
+myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *myri10ge_gstrings_main_stats,
+		       sizeof(myri10ge_gstrings_main_stats));
+		data += sizeof(myri10ge_gstrings_main_stats);
+		for (i = 0; i < mgp->num_slices; i++) {
+			memcpy(data, *myri10ge_gstrings_slice_stats,
+			       sizeof(myri10ge_gstrings_slice_stats));
+			data += sizeof(myri10ge_gstrings_slice_stats);
+		}
+		break;
+	}
+}
+
+static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		return MYRI10GE_MAIN_STATS_LEN +
+		    mgp->num_slices * MYRI10GE_SLICE_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void
+myri10ge_get_ethtool_stats(struct net_device *netdev,
+			   struct ethtool_stats *stats, u64 * data)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	struct myri10ge_slice_state *ss;
+	int slice;
+	int i;
+
+	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
+		data[i] = ((unsigned long *)&mgp->stats)[i];
+
+	data[i++] = (unsigned int)mgp->tx_boundary;
+	data[i++] = (unsigned int)mgp->wc_enabled;
+	data[i++] = (unsigned int)mgp->pdev->irq;
+	data[i++] = (unsigned int)mgp->msi_enabled;
+	data[i++] = (unsigned int)mgp->msix_enabled;
+	data[i++] = (unsigned int)mgp->read_dma;
+	data[i++] = (unsigned int)mgp->write_dma;
+	data[i++] = (unsigned int)mgp->read_write_dma;
+	data[i++] = (unsigned int)mgp->serial_number;
+	data[i++] = (unsigned int)mgp->watchdog_resets;
+#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
+	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
+	data[i++] = (unsigned int)(mgp->dca_enabled);
+#endif
+	data[i++] = (unsigned int)mgp->link_changes;
+
+	/* firmware stats are useful only in the first slice */
+	ss = &mgp->ss[0];
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
+	data[i++] =
+	    (unsigned int)ntohl(ss->fw_stats->dropped_link_error_or_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_pause);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_phy);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_crc32);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_unicast_filtered);
+	data[i++] =
+	    (unsigned int)ntohl(ss->fw_stats->dropped_multicast_filtered);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_runt);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_overrun);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
+	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
+
+	for (slice = 0; slice < mgp->num_slices; slice++) {
+		ss = &mgp->ss[slice];
+		data[i++] = slice;
+		data[i++] = (unsigned int)ss->tx.pkt_start;
+		data[i++] = (unsigned int)ss->tx.pkt_done;
+		data[i++] = (unsigned int)ss->tx.req;
+		data[i++] = (unsigned int)ss->tx.done;
+		data[i++] = (unsigned int)ss->rx_small.cnt;
+		data[i++] = (unsigned int)ss->rx_big.cnt;
+		data[i++] = (unsigned int)ss->tx.wake_queue;
+		data[i++] = (unsigned int)ss->tx.stop_queue;
+		data[i++] = (unsigned int)ss->tx.linearized;
+		data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
+		data[i++] = ss->rx_done.lro_mgr.stats.flushed;
+		if (ss->rx_done.lro_mgr.stats.flushed)
+			data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
+			    ss->rx_done.lro_mgr.stats.flushed;
+		else
+			data[i++] = 0;
+		data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
+	}
+}
+
+static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	mgp->msg_enable = value;
+}
+
+static u32 myri10ge_get_msglevel(struct net_device *netdev)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	return mgp->msg_enable;
+}
+
+const struct ethtool_ops myri10ge_ethtool_ops = {
+	.get_settings = myri10ge_get_settings,
+	.get_drvinfo = myri10ge_get_drvinfo,
+	.get_coalesce = myri10ge_get_coalesce,
+	.set_coalesce = myri10ge_set_coalesce,
+	.get_pauseparam = myri10ge_get_pauseparam,
+	.set_pauseparam = myri10ge_set_pauseparam,
+	.get_ringparam = myri10ge_get_ringparam,
+	.get_rx_csum = myri10ge_get_rx_csum,
+	.set_rx_csum = myri10ge_set_rx_csum,
+	.set_tx_csum = ethtool_op_set_tx_hw_csum,
+	.set_sg = ethtool_op_set_sg,
+	.set_tso = myri10ge_set_tso,
+	.get_link = ethtool_op_get_link,
+	.get_strings = myri10ge_get_strings,
+	.get_sset_count = myri10ge_get_sset_count,
+	.get_ethtool_stats = myri10ge_get_ethtool_stats,
+	.set_msglevel = myri10ge_set_msglevel,
+	.get_msglevel = myri10ge_get_msglevel
+};
diff --git a/drivers/net/myri10ge/myri10ge_firmware.c b/drivers/net/myri10ge/myri10ge_firmware.c
new file mode 100644
index 0000000..542fba0
--- /dev/null
+++ b/drivers/net/myri10ge/myri10ge_firmware.c
@@ -0,0 +1,309 @@
+/*************************************************************************
+ * myri10ge.c: Myricom Myri-10G Ethernet driver.
+ *
+ * Copyright (C) 2005 - 2008 Myricom, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Myricom, Inc. nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * If the eeprom on your board is not recent enough, you will need to get a
+ * newer firmware image at:
+ *   http://www.myri.com/scs/download-Myri10GE.html
+ *
+ * Contact Information:
+ *   <help@myri.com>
+ *   Myricom, Inc., 325N Santa Anita Avenue, Arcadia, CA 91006
+ *************************************************************************/
+
+#include <linux/string.h>
+#include <linux/pci.h>
+#include <linux/dma-mapping.h>
+#include <linux/inet_lro.h>
+#include <linux/dca.h>
+#include <linux/io.h>
+#include <linux/ethtool.h>
+#include <linux/crc32.h>
+#include <linux/firmware.h>
+#include "myri10ge_mcp.h"
+#include "myri10ge_mcp_gen_header.h"
+#include "myri10ge.h"
+
+static int
+myri10ge_validate_firmware(struct myri10ge_priv *mgp,
+			   struct mcp_gen_header *hdr)
+{
+	struct device *dev = &mgp->pdev->dev;
+
+	/* check firmware type */
+	if (ntohl(hdr->mcp_type) != MCP_TYPE_ETH) {
+		dev_err(dev, "Bad firmware type: 0x%x\n", ntohl(hdr->mcp_type));
+		return -EINVAL;
+	}
+
+	/* save firmware version for ethtool */
+	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
+
+	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
+	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
+
+	if (!(mgp->fw_ver_major == MXGEFW_VERSION_MAJOR
+	      && mgp->fw_ver_minor == MXGEFW_VERSION_MINOR)) {
+		dev_err(dev, "Found firmware version %s\n", mgp->fw_version);
+		dev_err(dev, "Driver needs %d.%d\n", MXGEFW_VERSION_MAJOR,
+			MXGEFW_VERSION_MINOR);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int myri10ge_load_hotplug_firmware(struct myri10ge_priv *mgp, u32 * size)
+{
+	unsigned crc, reread_crc;
+	const struct firmware *fw;
+	struct device *dev = &mgp->pdev->dev;
+	unsigned char *fw_readback;
+	struct mcp_gen_header *hdr;
+	size_t hdr_offset;
+	int status;
+	unsigned i;
+
+	if ((status = request_firmware(&fw, mgp->fw_name, dev)) < 0) {
+		dev_err(dev, "Unable to load %s firmware image via hotplug\n",
+			mgp->fw_name);
+		status = -EINVAL;
+		goto abort_with_nothing;
+	}
+
+	/* check size */
+
+	if (fw->size >= mgp->sram_size - MYRI10GE_FW_OFFSET ||
+	    fw->size < MCP_HEADER_PTR_OFFSET + 4) {
+		dev_err(dev, "Firmware size invalid:%d\n", (int)fw->size);
+		status = -EINVAL;
+		goto abort_with_fw;
+	}
+
+	/* check id */
+	hdr_offset = ntohl(*(__be32 *) (fw->data + MCP_HEADER_PTR_OFFSET));
+	if ((hdr_offset & 3) || hdr_offset + sizeof(*hdr) > fw->size) {
+		dev_err(dev, "Bad firmware file\n");
+		status = -EINVAL;
+		goto abort_with_fw;
+	}
+	hdr = (void *)(fw->data + hdr_offset);
+
+	status = myri10ge_validate_firmware(mgp, hdr);
+	if (status != 0)
+		goto abort_with_fw;
+
+	crc = crc32(~0, fw->data, fw->size);
+	for (i = 0; i < fw->size; i += 256) {
+		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET + i,
+				  (__force u8 *) fw->data + i,
+				  min(256U, (unsigned)(fw->size - i)));
+		mb();
+		readb(mgp->sram);
+	}
+	fw_readback = vmalloc(fw->size);
+	if (!fw_readback) {
+		status = -ENOMEM;
+		goto abort_with_fw;
+	}
+	/* corruption checking is good for parity recovery and buggy chipset */
+	memcpy_fromio(fw_readback, mgp->sram + MYRI10GE_FW_OFFSET, fw->size);
+	reread_crc = crc32(~0, fw_readback, fw->size);
+	vfree(fw_readback);
+	if (crc != reread_crc) {
+		dev_err(dev, "CRC failed(fw-len=%u), got 0x%x (expect 0x%x)\n",
+			(unsigned)fw->size, reread_crc, crc);
+		status = -EIO;
+		goto abort_with_fw;
+	}
+	*size = (u32) fw->size;
+
+abort_with_fw:
+	release_firmware(fw);
+
+abort_with_nothing:
+	return status;
+}
+
+static int myri10ge_adopt_running_firmware(struct myri10ge_priv *mgp)
+{
+	struct mcp_gen_header *hdr;
+	struct device *dev = &mgp->pdev->dev;
+	const size_t bytes = sizeof(struct mcp_gen_header);
+	size_t hdr_offset;
+	int status;
+
+	/* find running firmware header */
+	hdr_offset = swab32(readl(mgp->sram + MCP_HEADER_PTR_OFFSET));
+
+	if ((hdr_offset & 3) || hdr_offset + sizeof(*hdr) > mgp->sram_size) {
+		dev_err(dev, "Running firmware has bad header offset (%d)\n",
+			(int)hdr_offset);
+		return -EIO;
+	}
+
+	/* copy header of running firmware from SRAM to host memory to
+	 * validate firmware */
+	hdr = kmalloc(bytes, GFP_KERNEL);
+	if (hdr == NULL) {
+		dev_err(dev, "could not malloc firmware hdr\n");
+		return -ENOMEM;
+	}
+	memcpy_fromio(hdr, mgp->sram + hdr_offset, bytes);
+	status = myri10ge_validate_firmware(mgp, hdr);
+	kfree(hdr);
+
+	/* check to see if adopted firmware has bug where adopting
+	 * it will cause broadcasts to be filtered unless the NIC
+	 * is kept in ALLMULTI mode */
+	if (mgp->fw_ver_major == 1 && mgp->fw_ver_minor == 4 &&
+	    mgp->fw_ver_tiny >= 4 && mgp->fw_ver_tiny <= 11) {
+		mgp->adopted_rx_filter_bug = 1;
+		dev_warn(dev, "Adopting fw %d.%d.%d: "
+			 "working around rx filter bug\n",
+			 mgp->fw_ver_major, mgp->fw_ver_minor,
+			 mgp->fw_ver_tiny);
+	}
+	return status;
+}
+
+static int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	int status;
+
+	/* probe for IPv6 TSO support */
+	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
+				   &cmd, 0);
+	if (status == 0) {
+		mgp->max_tso6 = cmd.data0;
+		mgp->features |= NETIF_F_TSO6;
+	}
+
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev,
+			"failed MXGEFW_CMD_GET_RX_RING_SIZE\n");
+		return -ENXIO;
+	}
+
+	mgp->max_intr_slots = 2 * (cmd.data0 / sizeof(struct mcp_dma_addr));
+
+	return 0;
+}
+
+int myri10ge_load_firmware(struct myri10ge_priv *mgp, int adopt)
+{
+	char __iomem *submit;
+	__be32 buf[16] __attribute__ ((__aligned__(8)));
+	u32 dma_low, dma_high, size;
+	int status, i;
+
+	size = 0;
+	status = myri10ge_load_hotplug_firmware(mgp, &size);
+	if (status) {
+		if (!adopt)
+			return status;
+		dev_warn(&mgp->pdev->dev, "hotplug firmware loading failed\n");
+
+		/* Do not attempt to adopt firmware if there
+		 * was a bad crc */
+		if (status == -EIO)
+			return status;
+
+		status = myri10ge_adopt_running_firmware(mgp);
+		if (status != 0) {
+			dev_err(&mgp->pdev->dev,
+				"failed to adopt running firmware\n");
+			return status;
+		}
+		dev_info(&mgp->pdev->dev,
+			 "Successfully adopted running firmware\n");
+		if (mgp->tx_boundary == 4096) {
+			dev_warn(&mgp->pdev->dev,
+				 "Using firmware currently running on NIC"
+				 ".  For optimal\n");
+			dev_warn(&mgp->pdev->dev,
+				 "performance consider loading optimized "
+				 "firmware\n");
+			dev_warn(&mgp->pdev->dev, "via hotplug\n");
+		}
+
+		mgp->fw_name = "adopted";
+		mgp->tx_boundary = 2048;
+		myri10ge_dummy_rdma(mgp, 1);
+		status = myri10ge_get_firmware_capabilities(mgp);
+		return status;
+	}
+
+	/* clear confirmation addr */
+	mgp->cmd->data = 0;
+	mb();
+
+	/* send a reload command to the bootstrap MCP, and wait for the
+	 *  response in the confirmation address.  The firmware should
+	 * write a -1 there to indicate it is alive and well
+	 */
+	dma_low = MYRI10GE_LOWPART_TO_U32(mgp->cmd_bus);
+	dma_high = MYRI10GE_HIGHPART_TO_U32(mgp->cmd_bus);
+
+	buf[0] = htonl(dma_high);	/* confirm addr MSW */
+	buf[1] = htonl(dma_low);	/* confirm addr LSW */
+	buf[2] = MYRI10GE_NO_CONFIRM_DATA;	/* confirm data */
+
+	/* FIX: All newest firmware should un-protect the bottom of
+	 * the sram before handoff. However, the very first interfaces
+	 * do not. Therefore the handoff copy must skip the first 8 bytes
+	 */
+	buf[3] = htonl(MYRI10GE_FW_OFFSET + 8);	/* where the code starts */
+	buf[4] = htonl(size - 8);	/* length of code */
+	buf[5] = htonl(8);	/* where to copy to */
+	buf[6] = htonl(0);	/* where to jump to */
+
+	submit = mgp->sram + MXGEFW_BOOT_HANDOFF;
+
+	myri10ge_pio_copy(submit, &buf, sizeof(buf));
+	mb();
+	msleep(1);
+	mb();
+	i = 0;
+	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 9) {
+		msleep(1 << i);
+		i++;
+	}
+	if (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA) {
+		dev_err(&mgp->pdev->dev, "handoff failed\n");
+		return -ENXIO;
+	}
+	myri10ge_dummy_rdma(mgp, 1);
+	status = myri10ge_get_firmware_capabilities(mgp);
+
+	return status;
+}
diff --git a/drivers/net/myri10ge/myri10ge_main.c b/drivers/net/myri10ge/myri10ge_main.c
index d9fcd2c..2f72db2 100644
--- a/drivers/net/myri10ge/myri10ge_main.c
+++ b/drivers/net/myri10ge/myri10ge_main.c
@@ -1,7 +1,7 @@
 /*************************************************************************
  * myri10ge.c: Myricom Myri-10G Ethernet driver.
  *
- * Copyright (C) 2005 - 2007 Myricom, Inc.
+ * Copyright (C) 2005 - 2008 Myricom, Inc.
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -54,7 +54,6 @@
 #include <linux/inet.h>
 #include <linux/in.h>
 #include <linux/ethtool.h>
-#include <linux/firmware.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
@@ -74,195 +73,19 @@
 
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
-
-#define MYRI10GE_VERSION_STR "1.4.3-1.358"
+#include "myri10ge.h"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
 MODULE_VERSION(MYRI10GE_VERSION_STR);
 MODULE_LICENSE("Dual BSD/GPL");
 
-#define MYRI10GE_MAX_ETHER_MTU 9014
-
-#define MYRI10GE_ETH_STOPPED 0
-#define MYRI10GE_ETH_STOPPING 1
-#define MYRI10GE_ETH_STARTING 2
-#define MYRI10GE_ETH_RUNNING 3
-#define MYRI10GE_ETH_OPEN_FAILED 4
-
-#define MYRI10GE_EEPROM_STRINGS_SIZE 256
-#define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
-#define MYRI10GE_MAX_LRO_DESCRIPTORS 8
-#define MYRI10GE_LRO_MAX_PKTS 64
-
-#define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
-#define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
-
-#define MYRI10GE_ALLOC_ORDER 0
-#define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
-#define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
-
-#define MYRI10GE_MAX_SLICES 32
-
-struct myri10ge_rx_buffer_state {
-	struct page *page;
-	int page_offset;
-	 DECLARE_PCI_UNMAP_ADDR(bus)
-	 DECLARE_PCI_UNMAP_LEN(len)
-};
-
-struct myri10ge_tx_buffer_state {
-	struct sk_buff *skb;
-	int last;
-	 DECLARE_PCI_UNMAP_ADDR(bus)
-	 DECLARE_PCI_UNMAP_LEN(len)
-};
-
-struct myri10ge_cmd {
-	u32 data0;
-	u32 data1;
-	u32 data2;
-};
-
-struct myri10ge_rx_buf {
-	struct mcp_kreq_ether_recv __iomem *lanai;	/* lanai ptr for recv ring */
-	struct mcp_kreq_ether_recv *shadow;	/* host shadow of recv ring */
-	struct myri10ge_rx_buffer_state *info;
-	struct page *page;
-	dma_addr_t bus;
-	int page_offset;
-	int cnt;
-	int fill_cnt;
-	int alloc_fail;
-	int mask;		/* number of rx slots -1 */
-	int watchdog_needed;
-};
+char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
+char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
+char *myri10ge_fw_rss_unaligned = "myri10ge_rss_ethp_z8e.dat";
+char *myri10ge_fw_rss_aligned = "myri10ge_rss_eth_z8e.dat";
 
-struct myri10ge_tx_buf {
-	struct mcp_kreq_ether_send __iomem *lanai;	/* lanai ptr for sendq */
-	__be32 __iomem *send_go;	/* "go" doorbell ptr */
-	__be32 __iomem *send_stop;	/* "stop" doorbell ptr */
-	struct mcp_kreq_ether_send *req_list;	/* host shadow of sendq */
-	char *req_bytes;
-	struct myri10ge_tx_buffer_state *info;
-	int mask;		/* number of transmit slots -1  */
-	int req ____cacheline_aligned;	/* transmit slots submitted     */
-	int pkt_start;		/* packets started */
-	int stop_queue;
-	int linearized;
-	int done ____cacheline_aligned;	/* transmit slots completed     */
-	int pkt_done;		/* packets completed */
-	int wake_queue;
-	int queue_active;
-};
-
-struct myri10ge_rx_done {
-	struct mcp_slot *entry;
-	dma_addr_t bus;
-	int cnt;
-	int idx;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
-};
-
-struct myri10ge_slice_netstats {
-	unsigned long rx_packets;
-	unsigned long tx_packets;
-	unsigned long rx_bytes;
-	unsigned long tx_bytes;
-	unsigned long rx_dropped;
-	unsigned long tx_dropped;
-};
-
-struct myri10ge_slice_state {
-	struct myri10ge_tx_buf tx;	/* transmit ring        */
-	struct myri10ge_rx_buf rx_small;
-	struct myri10ge_rx_buf rx_big;
-	struct myri10ge_rx_done rx_done;
-	struct net_device *dev;
-	struct napi_struct napi;
-	struct myri10ge_priv *mgp;
-	struct myri10ge_slice_netstats stats;
-	__be32 __iomem *irq_claim;
-	struct mcp_irq_data *fw_stats;
-	dma_addr_t fw_stats_bus;
-	int watchdog_tx_done;
-	int watchdog_tx_req;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
-	int cached_dca_tag;
-	int cpu;
-	__be32 __iomem *dca_tag;
-#endif
-	char irq_desc[32];
-};
-
-struct myri10ge_priv {
-	struct myri10ge_slice_state *ss;
-	int tx_boundary;	/* boundary transmits cannot cross */
-	int num_slices;
-	int running;		/* running?             */
-	int csum_flag;		/* rx_csums?            */
-	int small_bytes;
-	int big_bytes;
-	int max_intr_slots;
-	struct net_device *dev;
-	struct net_device_stats stats;
-	spinlock_t stats_lock;
-	u8 __iomem *sram;
-	int sram_size;
-	unsigned long board_span;
-	unsigned long iomem_base;
-	__be32 __iomem *irq_deassert;
-	char *mac_addr_string;
-	struct mcp_cmd_response *cmd;
-	dma_addr_t cmd_bus;
-	struct pci_dev *pdev;
-	int msi_enabled;
-	int msix_enabled;
-	struct msix_entry *msix_vectors;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
-	int dca_enabled;
-#endif
-	u32 link_state;
-	unsigned int rdma_tags_available;
-	int intr_coal_delay;
-	__be32 __iomem *intr_coal_delay_ptr;
-	int mtrr;
-	int wc_enabled;
-	int down_cnt;
-	wait_queue_head_t down_wq;
-	struct work_struct watchdog_work;
-	struct timer_list watchdog_timer;
-	int watchdog_resets;
-	int watchdog_pause;
-	int pause;
-	char *fw_name;
-	char eeprom_strings[MYRI10GE_EEPROM_STRINGS_SIZE];
-	char *product_code_string;
-	char fw_version[128];
-	int fw_ver_major;
-	int fw_ver_minor;
-	int fw_ver_tiny;
-	int adopted_rx_filter_bug;
-	u8 mac_addr[6];		/* eeprom mac address */
-	unsigned long serial_number;
-	int vendor_specific_offset;
-	int fw_multicast_support;
-	unsigned long features;
-	u32 max_tso6;
-	u32 read_dma;
-	u32 write_dma;
-	u32 read_write_dma;
-	u32 link_changes;
-	u32 msg_enable;
-};
-
-static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
-static char *myri10ge_fw_aligned = "myri10ge_eth_z8e.dat";
-static char *myri10ge_fw_rss_unaligned = "myri10ge_rss_ethp_z8e.dat";
-static char *myri10ge_fw_rss_aligned = "myri10ge_rss_eth_z8e.dat";
-
-static char *myri10ge_fw_name = NULL;
+char *myri10ge_fw_name = NULL;
 module_param(myri10ge_fw_name, charp, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
 
@@ -346,22 +169,10 @@ static int myri10ge_dca = 1;
 module_param(myri10ge_dca, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_dca, "Enable DCA if possible");
 
-#define MYRI10GE_FW_OFFSET 1024*1024
-#define MYRI10GE_HIGHPART_TO_U32(X) \
-(sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
-#define MYRI10GE_LOWPART_TO_U32(X) ((u32)(X))
-
-#define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
-
 static void myri10ge_set_multicast_list(struct net_device *dev);
 static int myri10ge_sw_tso(struct sk_buff *skb, struct net_device *dev);
 
-static inline void put_be32(__be32 val, __be32 __iomem * p)
-{
-	__raw_writel((__force __u32) val, (__force void __iomem *)p);
-}
-
-static int
+int
 myri10ge_send_cmd(struct myri10ge_priv *mgp, u32 cmd,
 		  struct myri10ge_cmd *data, int atomic)
 {
@@ -492,7 +303,7 @@ abort:
  * chipsets resend dropped PCIe messages
  */
 
-static void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable)
+void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable)
 {
 	char __iomem *submit;
 	__be32 buf[16] __attribute__ ((__aligned__(8)));
@@ -527,263 +338,6 @@ static void myri10ge_dummy_rdma(struct myri10ge_priv *mgp, int enable)
 			(enable ? "enable" : "disable"));
 }
 
-static int
-myri10ge_validate_firmware(struct myri10ge_priv *mgp,
-			   struct mcp_gen_header *hdr)
-{
-	struct device *dev = &mgp->pdev->dev;
-
-	/* check firmware type */
-	if (ntohl(hdr->mcp_type) != MCP_TYPE_ETH) {
-		dev_err(dev, "Bad firmware type: 0x%x\n", ntohl(hdr->mcp_type));
-		return -EINVAL;
-	}
-
-	/* save firmware version for ethtool */
-	strncpy(mgp->fw_version, hdr->version, sizeof(mgp->fw_version));
-
-	sscanf(mgp->fw_version, "%d.%d.%d", &mgp->fw_ver_major,
-	       &mgp->fw_ver_minor, &mgp->fw_ver_tiny);
-
-	if (!(mgp->fw_ver_major == MXGEFW_VERSION_MAJOR
-	      && mgp->fw_ver_minor == MXGEFW_VERSION_MINOR)) {
-		dev_err(dev, "Found firmware version %s\n", mgp->fw_version);
-		dev_err(dev, "Driver needs %d.%d\n", MXGEFW_VERSION_MAJOR,
-			MXGEFW_VERSION_MINOR);
-		return -EINVAL;
-	}
-	return 0;
-}
-
-static int myri10ge_load_hotplug_firmware(struct myri10ge_priv *mgp, u32 * size)
-{
-	unsigned crc, reread_crc;
-	const struct firmware *fw;
-	struct device *dev = &mgp->pdev->dev;
-	unsigned char *fw_readback;
-	struct mcp_gen_header *hdr;
-	size_t hdr_offset;
-	int status;
-	unsigned i;
-
-	if ((status = request_firmware(&fw, mgp->fw_name, dev)) < 0) {
-		dev_err(dev, "Unable to load %s firmware image via hotplug\n",
-			mgp->fw_name);
-		status = -EINVAL;
-		goto abort_with_nothing;
-	}
-
-	/* check size */
-
-	if (fw->size >= mgp->sram_size - MYRI10GE_FW_OFFSET ||
-	    fw->size < MCP_HEADER_PTR_OFFSET + 4) {
-		dev_err(dev, "Firmware size invalid:%d\n", (int)fw->size);
-		status = -EINVAL;
-		goto abort_with_fw;
-	}
-
-	/* check id */
-	hdr_offset = ntohl(*(__be32 *) (fw->data + MCP_HEADER_PTR_OFFSET));
-	if ((hdr_offset & 3) || hdr_offset + sizeof(*hdr) > fw->size) {
-		dev_err(dev, "Bad firmware file\n");
-		status = -EINVAL;
-		goto abort_with_fw;
-	}
-	hdr = (void *)(fw->data + hdr_offset);
-
-	status = myri10ge_validate_firmware(mgp, hdr);
-	if (status != 0)
-		goto abort_with_fw;
-
-	crc = crc32(~0, fw->data, fw->size);
-	for (i = 0; i < fw->size; i += 256) {
-		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET + i,
-				  fw->data + i,
-				  min(256U, (unsigned)(fw->size - i)));
-		mb();
-		readb(mgp->sram);
-	}
-	fw_readback = vmalloc(fw->size);
-	if (!fw_readback) {
-		status = -ENOMEM;
-		goto abort_with_fw;
-	}
-	/* corruption checking is good for parity recovery and buggy chipset */
-	memcpy_fromio(fw_readback, mgp->sram + MYRI10GE_FW_OFFSET, fw->size);
-	reread_crc = crc32(~0, fw_readback, fw->size);
-	vfree(fw_readback);
-	if (crc != reread_crc) {
-		dev_err(dev, "CRC failed(fw-len=%u), got 0x%x (expect 0x%x)\n",
-			(unsigned)fw->size, reread_crc, crc);
-		status = -EIO;
-		goto abort_with_fw;
-	}
-	*size = (u32) fw->size;
-
-abort_with_fw:
-	release_firmware(fw);
-
-abort_with_nothing:
-	return status;
-}
-
-static int myri10ge_adopt_running_firmware(struct myri10ge_priv *mgp)
-{
-	struct mcp_gen_header *hdr;
-	struct device *dev = &mgp->pdev->dev;
-	const size_t bytes = sizeof(struct mcp_gen_header);
-	size_t hdr_offset;
-	int status;
-
-	/* find running firmware header */
-	hdr_offset = swab32(readl(mgp->sram + MCP_HEADER_PTR_OFFSET));
-
-	if ((hdr_offset & 3) || hdr_offset + sizeof(*hdr) > mgp->sram_size) {
-		dev_err(dev, "Running firmware has bad header offset (%d)\n",
-			(int)hdr_offset);
-		return -EIO;
-	}
-
-	/* copy header of running firmware from SRAM to host memory to
-	 * validate firmware */
-	hdr = kmalloc(bytes, GFP_KERNEL);
-	if (hdr == NULL) {
-		dev_err(dev, "could not malloc firmware hdr\n");
-		return -ENOMEM;
-	}
-	memcpy_fromio(hdr, mgp->sram + hdr_offset, bytes);
-	status = myri10ge_validate_firmware(mgp, hdr);
-	kfree(hdr);
-
-	/* check to see if adopted firmware has bug where adopting
-	 * it will cause broadcasts to be filtered unless the NIC
-	 * is kept in ALLMULTI mode */
-	if (mgp->fw_ver_major == 1 && mgp->fw_ver_minor == 4 &&
-	    mgp->fw_ver_tiny >= 4 && mgp->fw_ver_tiny <= 11) {
-		mgp->adopted_rx_filter_bug = 1;
-		dev_warn(dev, "Adopting fw %d.%d.%d: "
-			 "working around rx filter bug\n",
-			 mgp->fw_ver_major, mgp->fw_ver_minor,
-			 mgp->fw_ver_tiny);
-	}
-	return status;
-}
-
-static int myri10ge_get_firmware_capabilities(struct myri10ge_priv *mgp)
-{
-	struct myri10ge_cmd cmd;
-	int status;
-
-	/* probe for IPv6 TSO support */
-	mgp->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO;
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_TSO6_HDR_SIZE,
-				   &cmd, 0);
-	if (status == 0) {
-		mgp->max_tso6 = cmd.data0;
-		mgp->features |= NETIF_F_TSO6;
-	}
-
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_RX_RING_SIZE, &cmd, 0);
-	if (status != 0) {
-		dev_err(&mgp->pdev->dev,
-			"failed MXGEFW_CMD_GET_RX_RING_SIZE\n");
-		return -ENXIO;
-	}
-
-	mgp->max_intr_slots = 2 * (cmd.data0 / sizeof(struct mcp_dma_addr));
-
-	return 0;
-}
-
-static int myri10ge_load_firmware(struct myri10ge_priv *mgp, int adopt)
-{
-	char __iomem *submit;
-	__be32 buf[16] __attribute__ ((__aligned__(8)));
-	u32 dma_low, dma_high, size;
-	int status, i;
-
-	size = 0;
-	status = myri10ge_load_hotplug_firmware(mgp, &size);
-	if (status) {
-		if (!adopt)
-			return status;
-		dev_warn(&mgp->pdev->dev, "hotplug firmware loading failed\n");
-
-		/* Do not attempt to adopt firmware if there
-		 * was a bad crc */
-		if (status == -EIO)
-			return status;
-
-		status = myri10ge_adopt_running_firmware(mgp);
-		if (status != 0) {
-			dev_err(&mgp->pdev->dev,
-				"failed to adopt running firmware\n");
-			return status;
-		}
-		dev_info(&mgp->pdev->dev,
-			 "Successfully adopted running firmware\n");
-		if (mgp->tx_boundary == 4096) {
-			dev_warn(&mgp->pdev->dev,
-				 "Using firmware currently running on NIC"
-				 ".  For optimal\n");
-			dev_warn(&mgp->pdev->dev,
-				 "performance consider loading optimized "
-				 "firmware\n");
-			dev_warn(&mgp->pdev->dev, "via hotplug\n");
-		}
-
-		mgp->fw_name = "adopted";
-		mgp->tx_boundary = 2048;
-		myri10ge_dummy_rdma(mgp, 1);
-		status = myri10ge_get_firmware_capabilities(mgp);
-		return status;
-	}
-
-	/* clear confirmation addr */
-	mgp->cmd->data = 0;
-	mb();
-
-	/* send a reload command to the bootstrap MCP, and wait for the
-	 *  response in the confirmation address.  The firmware should
-	 * write a -1 there to indicate it is alive and well
-	 */
-	dma_low = MYRI10GE_LOWPART_TO_U32(mgp->cmd_bus);
-	dma_high = MYRI10GE_HIGHPART_TO_U32(mgp->cmd_bus);
-
-	buf[0] = htonl(dma_high);	/* confirm addr MSW */
-	buf[1] = htonl(dma_low);	/* confirm addr LSW */
-	buf[2] = MYRI10GE_NO_CONFIRM_DATA;	/* confirm data */
-
-	/* FIX: All newest firmware should un-protect the bottom of
-	 * the sram before handoff. However, the very first interfaces
-	 * do not. Therefore the handoff copy must skip the first 8 bytes
-	 */
-	buf[3] = htonl(MYRI10GE_FW_OFFSET + 8);	/* where the code starts */
-	buf[4] = htonl(size - 8);	/* length of code */
-	buf[5] = htonl(8);	/* where to copy to */
-	buf[6] = htonl(0);	/* where to jump to */
-
-	submit = mgp->sram + MXGEFW_BOOT_HANDOFF;
-
-	myri10ge_pio_copy(submit, &buf, sizeof(buf));
-	mb();
-	msleep(1);
-	mb();
-	i = 0;
-	while (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA && i < 9) {
-		msleep(1 << i);
-		i++;
-	}
-	if (mgp->cmd->data != MYRI10GE_NO_CONFIRM_DATA) {
-		dev_err(&mgp->pdev->dev, "handoff failed\n");
-		return -ENXIO;
-	}
-	myri10ge_dummy_rdma(mgp, 1);
-	status = myri10ge_get_firmware_capabilities(mgp);
-
-	return status;
-}
-
 static int myri10ge_update_mac_address(struct myri10ge_priv *mgp, u8 * addr)
 {
 	struct myri10ge_cmd cmd;
@@ -798,7 +352,7 @@ static int myri10ge_update_mac_address(struct myri10ge_priv *mgp, u8 * addr)
 	return status;
 }
 
-static int myri10ge_change_pause(struct myri10ge_priv *mgp, int pause)
+int myri10ge_change_pause(struct myri10ge_priv *mgp, int pause)
 {
 	struct myri10ge_cmd cmd;
 	int status, ctl;
@@ -1581,319 +1135,6 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	return (IRQ_HANDLED);
 }
 
-static int
-myri10ge_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	char *ptr;
-	int i;
-
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->speed = SPEED_10000;
-	cmd->duplex = DUPLEX_FULL;
-
-	/*
-	 * parse the product code to deterimine the interface type
-	 * (CX4, XFP, Quad Ribbon Fiber) by looking at the character
-	 * after the 3rd dash in the driver's cached copy of the
-	 * EEPROM's product code string.
-	 */
-	ptr = mgp->product_code_string;
-	if (ptr == NULL) {
-		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
-		       netdev->name);
-		return 0;
-	}
-	for (i = 0; i < 3; i++, ptr++) {
-		ptr = strchr(ptr, '-');
-		if (ptr == NULL) {
-			printk(KERN_ERR "myri10ge: %s: Invalid product "
-			       "code %s\n", netdev->name,
-			       mgp->product_code_string);
-			return 0;
-		}
-	}
-	if (*ptr == 'R' || *ptr == 'Q') {
-		/* We've found either an XFP or quad ribbon fiber */
-		cmd->port = PORT_FIBRE;
-	}
-	return 0;
-}
-
-static void
-myri10ge_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *info)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	strlcpy(info->driver, "myri10ge", sizeof(info->driver));
-	strlcpy(info->version, MYRI10GE_VERSION_STR, sizeof(info->version));
-	strlcpy(info->fw_version, mgp->fw_version, sizeof(info->fw_version));
-	strlcpy(info->bus_info, pci_name(mgp->pdev), sizeof(info->bus_info));
-}
-
-static int
-myri10ge_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	coal->rx_coalesce_usecs = mgp->intr_coal_delay;
-	return 0;
-}
-
-static int
-myri10ge_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	mgp->intr_coal_delay = coal->rx_coalesce_usecs;
-	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
-	return 0;
-}
-
-static void
-myri10ge_get_pauseparam(struct net_device *netdev,
-			struct ethtool_pauseparam *pause)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	pause->autoneg = 0;
-	pause->rx_pause = mgp->pause;
-	pause->tx_pause = mgp->pause;
-}
-
-static int
-myri10ge_set_pauseparam(struct net_device *netdev,
-			struct ethtool_pauseparam *pause)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	if (pause->tx_pause != mgp->pause)
-		return myri10ge_change_pause(mgp, pause->tx_pause);
-	if (pause->rx_pause != mgp->pause)
-		return myri10ge_change_pause(mgp, pause->tx_pause);
-	if (pause->autoneg != 0)
-		return -EINVAL;
-	return 0;
-}
-
-static void
-myri10ge_get_ringparam(struct net_device *netdev,
-		       struct ethtool_ringparam *ring)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	ring->rx_mini_max_pending = mgp->ss[0].rx_small.mask + 1;
-	ring->rx_max_pending = mgp->ss[0].rx_big.mask + 1;
-	ring->rx_jumbo_max_pending = 0;
-	ring->tx_max_pending = mgp->ss[0].rx_small.mask + 1;
-	ring->rx_mini_pending = ring->rx_mini_max_pending;
-	ring->rx_pending = ring->rx_max_pending;
-	ring->rx_jumbo_pending = ring->rx_jumbo_max_pending;
-	ring->tx_pending = ring->tx_max_pending;
-}
-
-static u32 myri10ge_get_rx_csum(struct net_device *netdev)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	if (mgp->csum_flag)
-		return 1;
-	else
-		return 0;
-}
-
-static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	if (csum_enabled)
-		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
-	else
-		mgp->csum_flag = 0;
-	return 0;
-}
-
-static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	unsigned long flags = mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
-
-	if (tso_enabled)
-		netdev->features |= flags;
-	else
-		netdev->features &= ~flags;
-	return 0;
-}
-
-static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] = {
-	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
-	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
-	"rx_length_errors", "rx_over_errors", "rx_crc_errors",
-	"rx_frame_errors", "rx_fifo_errors", "rx_missed_errors",
-	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
-	"tx_heartbeat_errors", "tx_window_errors",
-	/* device-specific stats */
-	"tx_boundary", "WC", "irq", "MSI", "MSIX",
-	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
-	"serial_number", "watchdog_resets",
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
-	"dca_capable_firmware", "dca_device_present",
-#endif
-	"link_changes", "link_up", "dropped_link_overflow",
-	"dropped_link_error_or_filtered",
-	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
-	"dropped_unicast_filtered", "dropped_multicast_filtered",
-	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
-	"dropped_no_big_buffer"
-};
-
-static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
-	"----------- slice ---------",
-	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
-	"rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
-	    "LRO flushed",
-	"LRO avg aggr", "LRO no_desc"
-};
-
-#define MYRI10GE_NET_STATS_LEN      21
-#define MYRI10GE_MAIN_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_main_stats)
-#define MYRI10GE_SLICE_STATS_LEN  ARRAY_SIZE(myri10ge_gstrings_slice_stats)
-
-static void
-myri10ge_get_strings(struct net_device *netdev, u32 stringset, u8 * data)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	int i;
-
-	switch (stringset) {
-	case ETH_SS_STATS:
-		memcpy(data, *myri10ge_gstrings_main_stats,
-		       sizeof(myri10ge_gstrings_main_stats));
-		data += sizeof(myri10ge_gstrings_main_stats);
-		for (i = 0; i < mgp->num_slices; i++) {
-			memcpy(data, *myri10ge_gstrings_slice_stats,
-			       sizeof(myri10ge_gstrings_slice_stats));
-			data += sizeof(myri10ge_gstrings_slice_stats);
-		}
-		break;
-	}
-}
-
-static int myri10ge_get_sset_count(struct net_device *netdev, int sset)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-
-	switch (sset) {
-	case ETH_SS_STATS:
-		return MYRI10GE_MAIN_STATS_LEN +
-		    mgp->num_slices * MYRI10GE_SLICE_STATS_LEN;
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static void
-myri10ge_get_ethtool_stats(struct net_device *netdev,
-			   struct ethtool_stats *stats, u64 * data)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	struct myri10ge_slice_state *ss;
-	int slice;
-	int i;
-
-	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
-		data[i] = ((unsigned long *)&mgp->stats)[i];
-
-	data[i++] = (unsigned int)mgp->tx_boundary;
-	data[i++] = (unsigned int)mgp->wc_enabled;
-	data[i++] = (unsigned int)mgp->pdev->irq;
-	data[i++] = (unsigned int)mgp->msi_enabled;
-	data[i++] = (unsigned int)mgp->msix_enabled;
-	data[i++] = (unsigned int)mgp->read_dma;
-	data[i++] = (unsigned int)mgp->write_dma;
-	data[i++] = (unsigned int)mgp->read_write_dma;
-	data[i++] = (unsigned int)mgp->serial_number;
-	data[i++] = (unsigned int)mgp->watchdog_resets;
-#if (defined CONFIG_DCA) || (defined CONFIG_DCA_MODULE)
-	data[i++] = (unsigned int)(mgp->ss[0].dca_tag != NULL);
-	data[i++] = (unsigned int)(mgp->dca_enabled);
-#endif
-	data[i++] = (unsigned int)mgp->link_changes;
-
-	/* firmware stats are useful only in the first slice */
-	ss = &mgp->ss[0];
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->link_up);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_link_overflow);
-	data[i++] =
-	    (unsigned int)ntohl(ss->fw_stats->dropped_link_error_or_filtered);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_pause);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_phy);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_bad_crc32);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_unicast_filtered);
-	data[i++] =
-	    (unsigned int)ntohl(ss->fw_stats->dropped_multicast_filtered);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_runt);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_overrun);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_small_buffer);
-	data[i++] = (unsigned int)ntohl(ss->fw_stats->dropped_no_big_buffer);
-
-	for (slice = 0; slice < mgp->num_slices; slice++) {
-		ss = &mgp->ss[slice];
-		data[i++] = slice;
-		data[i++] = (unsigned int)ss->tx.pkt_start;
-		data[i++] = (unsigned int)ss->tx.pkt_done;
-		data[i++] = (unsigned int)ss->tx.req;
-		data[i++] = (unsigned int)ss->tx.done;
-		data[i++] = (unsigned int)ss->rx_small.cnt;
-		data[i++] = (unsigned int)ss->rx_big.cnt;
-		data[i++] = (unsigned int)ss->tx.wake_queue;
-		data[i++] = (unsigned int)ss->tx.stop_queue;
-		data[i++] = (unsigned int)ss->tx.linearized;
-		data[i++] = ss->rx_done.lro_mgr.stats.aggregated;
-		data[i++] = ss->rx_done.lro_mgr.stats.flushed;
-		if (ss->rx_done.lro_mgr.stats.flushed)
-			data[i++] = ss->rx_done.lro_mgr.stats.aggregated /
-			    ss->rx_done.lro_mgr.stats.flushed;
-		else
-			data[i++] = 0;
-		data[i++] = ss->rx_done.lro_mgr.stats.no_desc;
-	}
-}
-
-static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	mgp->msg_enable = value;
-}
-
-static u32 myri10ge_get_msglevel(struct net_device *netdev)
-{
-	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	return mgp->msg_enable;
-}
-
-static const struct ethtool_ops myri10ge_ethtool_ops = {
-	.get_settings = myri10ge_get_settings,
-	.get_drvinfo = myri10ge_get_drvinfo,
-	.get_coalesce = myri10ge_get_coalesce,
-	.set_coalesce = myri10ge_set_coalesce,
-	.get_pauseparam = myri10ge_get_pauseparam,
-	.set_pauseparam = myri10ge_set_pauseparam,
-	.get_ringparam = myri10ge_get_ringparam,
-	.get_rx_csum = myri10ge_get_rx_csum,
-	.set_rx_csum = myri10ge_set_rx_csum,
-	.set_tx_csum = ethtool_op_set_tx_hw_csum,
-	.set_sg = ethtool_op_set_sg,
-	.set_tso = myri10ge_set_tso,
-	.get_link = ethtool_op_get_link,
-	.get_strings = myri10ge_get_strings,
-	.get_sset_count = myri10ge_get_sset_count,
-	.get_ethtool_stats = myri10ge_get_ethtool_stats,
-	.set_msglevel = myri10ge_set_msglevel,
-	.get_msglevel = myri10ge_get_msglevel
-};
-
 static int myri10ge_allocate_rings(struct myri10ge_slice_state *ss)
 {
 	struct myri10ge_priv *mgp = ss->mgp;
-- 
1.5.6.5



