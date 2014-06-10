From: Andy Green <andy.green@linaro.org>
Subject: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 09:08:03 +0800
Message-ID: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36688 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbaFJBIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 21:08:14 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so85744pad.7
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 18:08:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
Ethernet + PHY IP used in a variety of their ARM-based ASICs.

We are preparing to upstream the main platform support for these chips
which is currently waiting for mailbox driver in v6 now and waiting for
a final ACK

https://lkml.org/lkml/2014/5/15/49

This driver was originally written by guys inside Fujitsu as an abstracted
"you can build this for Windows as well" type code, I've removed all that,
modernized various things, added runtime_pm, and ported it to work with
Device Tree, using only the bindings already mentioned in

./Documentation/devicetree/bindings/net/ethernet.txt

There are only two checkpatch complaints, both about documentation for the
DT name missing.  But we will document vendor "fujitsu" in the main mach
support patches and it seems normal to just use the unified ethernet binding
with no documentation for this subsystem (we don't add any new DT bindings).

The patch is based on net-next fff1f59b1773fcb from today, and the unchanged
patch has been tested on real hardware on an integration tree based on 3.15-rc8

Any comments about how to further improve and align it with current best-
practice for upstream Ethernet drivers are appreciated.

Changes since v1:

 - Followed comments from Francois Romieu about style issues and eliminate
spinlock wrappers

 - Remove remaining excess ()
 - Pass checkpatch --strict now
 - Use netdev_alloc_skb_ip_align as suggested
 - Set hardware endian support according to cpu endianess
 - change error handling targets from "bailX" to "errX"

Signed-off-by: Andy Green <andy.green@linaro.org>
---
 drivers/net/ethernet/fujitsu/Kconfig               |   11 
 drivers/net/ethernet/fujitsu/Makefile              |    1 
 drivers/net/ethernet/fujitsu/ogma/Makefile         |    5 
 drivers/net/ethernet/fujitsu/ogma/ogma.h           |  452 ++++++++++++
 .../ethernet/fujitsu/ogma/ogma_desc_ring_access.c  |  769 ++++++++++++++++++++
 .../net/ethernet/fujitsu/ogma/ogma_gmac_access.c   |  238 ++++++
 drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c    |  599 ++++++++++++++++
 drivers/net/ethernet/fujitsu/ogma/ogma_platform.c  |  729 +++++++++++++++++++
 8 files changed, 2804 insertions(+)
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/Makefile
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/ogma.h
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
 create mode 100755 drivers/net/ethernet/fujitsu/ogma/ogma_platform.c

diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index 1085257..ed949a3 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -28,4 +28,15 @@ config PCMCIA_FMVJ18X
 	  To compile this driver as a module, choose M here: the module will be
 	  called fmvj18x_cs.  If unsure, say N.
 
+config NET_FUJITSU_OGMA
+	tristate "Fujitsu OGMA network support"
+	depends on OF
+	select PHYLIB
+help
+	  Enable for OGMA support of Fujitsu FGAMC4 IP
+	  Provides Gigabit ethernet support
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called ogma.  If unsure, say N.
+
 endif # NET_VENDOR_FUJITSU
diff --git a/drivers/net/ethernet/fujitsu/Makefile b/drivers/net/ethernet/fujitsu/Makefile
index 21561fd..b90a445 100644
--- a/drivers/net/ethernet/fujitsu/Makefile
+++ b/drivers/net/ethernet/fujitsu/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_PCMCIA_FMVJ18X) += fmvj18x_cs.o
+obj-$(CONFIG_NET_FUJITSU_OGMA) += ogma/
diff --git a/drivers/net/ethernet/fujitsu/ogma/Makefile b/drivers/net/ethernet/fujitsu/ogma/Makefile
new file mode 100755
index 0000000..d234504
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/Makefile
@@ -0,0 +1,5 @@
+obj-m := ogma.o
+ogma-objs := ogma_desc_ring_access.o \
+		ogma_netdev.o \
+		ogma_platform.o \
+		ogma_gmac_access.o
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma.h b/drivers/net/ethernet/fujitsu/ogma/ogma.h
new file mode 100755
index 0000000..813e448
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma.h
@@ -0,0 +1,452 @@
+/**
+ * ogma.h
+ *
+ *  Copyright (C) 2011 - 2014 Fujitsu Semiconductor Limited.
+ *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
+ *  All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version 2
+ *  of the License, or (at your option) any later version.
+ */
+#ifndef OGMA_INTERNAL_H
+#define OGMA_INTERNAL_H
+
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <linux/device.h>
+#include <net/sock.h>
+
+#define OGMA_FLOW_CONTROL_START_THRESHOLD	36
+#define OGMA_FLOW_CONTROL_STOP_THRESHOLD	48
+
+#define OGMA_CLK_MHZ				(1000000)
+
+#define OGMA_RX_PKT_BUF_LEN			1522
+#define OGMA_RX_JUMBO_PKT_BUF_LEN		9022
+#define OGMA_DUMMY_DESC_ENTRY_LEN		48
+
+#define OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX		(19)
+
+#define OGMA_TX_SHIFT_OWN_FIELD			(31)
+#define OGMA_TX_SHIFT_LD_FIELD			(30)
+#define OGMA_TX_SHIFT_DRID_FIELD		(24)
+#define OGMA_TX_SHIFT_PT_FIELD			(21)
+#define OGMA_TX_SHIFT_TDRID_FIELD		(16)
+#define OGMA_TX_SHIFT_CC_FIELD			(15)
+#define OGMA_TX_SHIFT_FS_FIELD			(9)
+#define OGMA_TX_LAST			(8)
+#define OGMA_TX_SHIFT_CO_FIELD			(7)
+#define OGMA_TX_SHIFT_SO_FIELD			(6)
+#define OGMA_TX_SHIFT_TRS_FIELD			(4)
+
+#define OGMA_RX_PKT_OWN_FIELD		(31)
+#define OGMA_RX_PKT_LD_FIELD		(30)
+#define OGMA_RX_PKT_SDRID_FIELD	(24)
+#define OGMA_RX_PKT_FR_FIELD		(23)
+#define OGMA_RX_PKT_ER_FIELD		(21)
+#define OGMA_RX_PKT_ERR_FIELD	(16)
+#define OGMA_RX_PKT_TDRID_FIELD	(12)
+#define OGMA_RX_PKT_FS_FIELD		(9)
+#define OGMA_RX_PKT_LS_FIELD		(8)
+#define OGMA_RX_PKT_CO_FIELD		(6)
+
+#define OGMA_RX_PKT_ERR_MASK	(0x3)
+
+#define OGMA_MAX_TX_PKT_LEN			1518
+#define OGMA_MAX_TX_JUMBO_PKT_LEN		9018
+
+#define OGMA_RING_NRM_TX			0
+#define OGMA_RING_NRM_RX			1
+#define OGMA_RING_RESERVED_RX			2
+#define OGMA_RING_RESERVED_TX			3
+#define OGMA_RING_GMAC				15
+#define OGMA_RING_MAX				3
+
+#define OGMA_TCP_SEG_LEN_MAX			1460
+#define OGMA_TCP_JUMBO_SEG_LEN_MAX		8960
+#define OGMA_TCP_SEG_LEN_MIN			536
+
+#define OGMA_RX_CKSUM_RESULT_NOTAVAIL		0
+#define OGMA_RX_CKSUM_RESULT_OK			1
+#define OGMA_RX_CKSUM_RESULT_NG			2
+
+#define OGMA_TOP_IRQ_REG_CODE_LOAD_END		(1 << 20)
+#define OGMA_TOP_IRQ_REG_NRM_RX			(1 <<  1)
+#define OGMA_TOP_IRQ_REG_NRM_TX			(1 <<  0)
+
+#define OGMA_IRQ_EMPTY				(1 << 17)
+#define OGMA_IRQ_ERR				(1 << 16)
+#define OGMA_IRQ_PKT_CNT			(1 << 15)
+#define OGMA_IRQ_TIMEUP				(1 << 14)
+#define OGMA_IRQ_RCV			(OGMA_IRQ_PKT_CNT | OGMA_IRQ_TIMEUP)
+
+#define OGMA_IRQ_TX_DONE			(1 << 15)
+#define OGMA_IRQ_SND			(OGMA_IRQ_TX_DONE | OGMA_IRQ_TIMEUP)
+
+#define OGMA_MODE_TRANS_COMP_IRQ_N2T		(1 << 20)
+#define OGMA_MODE_TRANS_COMP_IRQ_T2N		(1 << 19)
+
+#define OGMA_DESC_MIN				2
+#define OGMA_DESC_MAX				2047
+#define OGMA_INT_PKTCNT_MAX			2047
+
+#define OGMA_PHY_IF_GMII			0
+#define OGMA_PHY_IF_RGMII			1
+#define OGMA_PHY_IF_RMII			4
+
+#define OGMA_PHY_LINK_SPEED_1G			0
+#define OGMA_PHY_LINK_SPEED_100M		1
+#define OGMA_PHY_LINK_SPEED_10M			2
+
+#define OGMA_FLOW_START_TH_MAX			383
+#define OGMA_FLOW_STOP_TH_MAX			383
+#define OGMA_FLOW_PAUSE_TIME_MIN		5
+
+#define OGMA_CLK_EN_REG_DOM_ALL			0x3f
+
+#define OGMA_REG_TOP_STATUS			(0x80)
+#define OGMA_REG_TOP_INTEN			(0x81)
+#define OGMA_REG_TOP_INTEN_SET			(0x8d)
+#define OGMA_REG_TOP_INTEN_CLR			(0x8e)
+#define OGMA_REG_NRM_TX_STATUS			(0x100)
+#define OGMA_REG_NRM_TX_INTEN			(0x101)
+#define OGMA_REG_NRM_TX_INTEN_SET		(0x10a)
+#define OGMA_REG_NRM_TX_INTEN_CLR		(0x10b)
+#define OGMA_REG_NRM_RX_STATUS			(0x110)
+#define OGMA_REG_NRM_RX_INTEN			(0x111)
+#define OGMA_REG_NRM_RX_INTEN_SET		(0x11a)
+#define OGMA_REG_NRM_RX_INTEN_CLR		(0x11b)
+#define OGMA_REG_RESERVED_RX_DESC_START		(0x122)
+#define OGMA_REG_RESERVED_TX_DESC_START		(0x132)
+#define OGMA_REG_CLK_EN				(0x40)
+#define OGMA_REG_SOFT_RST			(0x41)
+#define OGMA_REG_PKT_CTRL			(0x50)
+#define OGMA_REG_COM_INIT			(0x48)
+#define OGMA_REG_DMA_TMR_CTRL			(0x83)
+#define OGMA_REG_F_TAIKI_MC_VER			(0x8b)
+#define OGMA_REG_F_TAIKI_VER			(0x8c)
+#define OGMA_REG_DMA_HM_CTRL			(0x85)
+#define OGMA_REG_DMA_MH_CTRL			(0x88)
+#define OGMA_REG_NRM_TX_PKTCNT			(0x104)
+#define OGMA_REG_NRM_TX_DONE_TXINT_PKTCNT	(0x106)
+#define OGMA_REG_NRM_RX_RXINT_PKTCNT		(0x116)
+#define OGMA_REG_NRM_TX_TXINT_TMR		(0x108)
+#define OGMA_REG_NRM_RX_RXINT_TMR		(0x118)
+#define OGMA_REG_NRM_TX_DONE_PKTCNT		(0x105)
+#define OGMA_REG_NRM_RX_PKTCNT			(0x115)
+#define OGMA_REG_NRM_TX_TMR			(0x107)
+#define OGMA_REG_NRM_RX_TMR			(0x117)
+#define OGMA_REG_NRM_TX_DESC_START		(0x102)
+#define OGMA_REG_NRM_RX_DESC_START		(0x112)
+#define OGMA_REG_NRM_TX_CONFIG			(0x10c)
+#define OGMA_REG_NRM_RX_CONFIG			(0x11c)
+#define MAC_REG_DATA				(0x470)
+#define MAC_REG_CMD				(0x471)
+#define MAC_REG_FLOW_TH				(0x473)
+#define MAC_REG_INTF_SEL			(0x475)
+#define MAC_REG_DESC_INIT			(0x47f)
+#define MAC_REG_DESC_SOFT_RST			(0x481)
+#define OGMA_REG_MODE_TRANS_COMP_STATUS		(0x140)
+
+#define GMAC_REG_MCR				(0x0000)
+#define GMAC_REG_MFFR				(0x0004)
+#define GMAC_REG_GAR				(0x0010)
+#define GMAC_REG_GDR				(0x0014)
+#define GMAC_REG_FCR				(0x0018)
+#define GMAC_REG_BMR				(0x1000)
+#define GMAC_REG_RDLAR				(0x100c)
+#define GMAC_REG_TDLAR				(0x1010)
+#define GMAC_REG_OMR				(0x1018)
+
+#define OGMA_PKT_CTRL_REG_MODE_NRM		(1 << 28)
+#define OGMA_PKT_CTRL_REG_EN_JUMBO		(1 << 27)
+#define OGMA_PKT_CTRL_REG_LOG_CHKSUM_ER		(1 << 3)
+#define OGMA_PKT_CTRL_REG_LOG_HD_INCOMPLETE	(1 << 2)
+#define OGMA_PKT_CTRL_REG_LOG_HD_ER		(1 << 1)
+
+#define OGMA_CLK_EN_REG_DOM_G			(1 << 5)
+#define OGMA_CLK_EN_REG_DOM_C			(1 << 1)
+#define OGMA_CLK_EN_REG_DOM_D			(1 << 0)
+
+#define OGMA_COM_INIT_REG_PKT			(1 << 1)
+#define OGMA_COM_INIT_REG_CORE			(1 << 0)
+#define OGMA_COM_INIT_REG_ALL  (OGMA_COM_INIT_REG_CORE | OGMA_COM_INIT_REG_PKT)
+
+#define OGMA_SOFT_RST_REG_RESET			(0)
+#define OGMA_SOFT_RST_REG_RUN			(1 << 31)
+
+#define OGMA_DMA_CTRL_REG_STOP			1
+#define OGMA_DMA_MH_CTRL_REG_MODE_TRANS		(1 << 20)
+
+#define OGMA_GMAC_CMD_ST_READ			(0)
+#define OGMA_GMAC_CMD_ST_WRITE			(1 << 28)
+#define OGMA_GMAC_CMD_ST_BUSY			(1 << 31)
+
+#define OGMA_GMAC_BMR_REG_COMMON		(0x00412080)
+#define OGMA_GMAC_BMR_REG_RESET			(0x00020181)
+#define OGMA_GMAC_BMR_REG_SWR			(0x00000001)
+
+#define OGMA_GMAC_OMR_REG_ST			(1 << 13)
+#define OGMA_GMAC_OMR_REG_SR			(1 << 1)
+
+#define OGMA_GMAC_MCR_REG_CST			(1 << 25)
+#define OGMA_GMAC_MCR_REG_JE			(1 << 20)
+#define OGMA_GMAC_MCR_PS			(1 << 15)
+#define OGMA_GMAC_MCR_REG_FES			(1 << 14)
+#define OGMA_GMAC_MCR_REG_FULL_DUPLEX_COMMON	(0x0000280c)
+#define OGMA_GMAC_MCR_REG_HALF_DUPLEX_COMMON	(0x0001a00c)
+
+#define OGMA_GMAC_FCR_REG_RFE			(1 << 2)
+#define OGMA_GMAC_FCR_REG_TFE			(1 << 1)
+
+#define OGMA_GMAC_GAR_REG_GW			(1 << 1)
+#define OGMA_GMAC_GAR_REG_GB			(1 << 0)
+
+#define OGMA_GMAC_GAR_REG_SHIFT_PA		(11)
+#define OGMA_GMAC_GAR_REG_SHIFT_GR		(6)
+#define GMAC_REG_SHIFT_CR_GAR			(2)
+
+#define OGMA_GMAC_GAR_REG_CR_25_35_MHZ		(2)
+#define OGMA_GMAC_GAR_REG_CR_35_60_MHZ		(3)
+#define OGMA_GMAC_GAR_REG_CR_60_100_MHZ		(0)
+#define OGMA_GMAC_GAR_REG_CR_100_150_MHZ	(1)
+#define OGMA_GMAC_GAR_REG_CR_150_250_MHZ	(4)
+#define OGMA_GMAC_GAR_REG_CR_250_300_MHZ	(5)
+
+#define OGMA_REG_OGMA_VER_F_TAIKI		0x20000
+
+#define OGMA_REG_DESC_RING_CONFIG_CFG_UP	(31)
+#define OGMA_REG_DESC_RING_CONFIG_CH_RST	(30)
+#define OGMA_REG_DESC_TMR_MODE	(4)
+#define OGMA_REG_DESC_ENDIAN	(0)
+
+#define OGMA_MAC_DESC_SOFT_RST_SOFT_RST 1
+#define OGMA_MAC_DESC_INIT_REG_INIT 1
+
+
+struct ogma_clk_ctrl {
+	u32 dmac_req_num;
+	u32 core_req_num;
+	u8 mac_req_num;
+};
+
+struct ogma_desc_param {
+	u32 valid_flag:1;
+	u32 little_endian_flag:1;
+	u32 tmr_mode_flag:1;
+	u16 entries;
+};
+
+struct ogma_gmac_config {
+	u8 phy_if;
+};
+
+struct ogma_pkt_ctrlaram {
+	u32 log_chksum_er_flag:1;
+	u32 log_hd_imcomplete_flag:1;
+	u32 log_hd_er_flag:1;
+};
+
+struct ogma_param {
+	u32 use_gmac_flag:1;
+	u32 use_jumbo_pkt_flag:1;
+	struct ogma_pkt_ctrlaram pkt_ctrlaram;
+	struct ogma_desc_param desc_param[OGMA_RING_MAX + 1];
+	struct ogma_gmac_config gmac_config;
+};
+
+struct ogma_gmac_mode {
+	u32 half_duplex_flag:1;
+	u32 flow_ctrl_enable_flag:1;
+	u8 link_speed;
+	u16 flow_start_th;
+	u16 flow_stop_th;
+	u16 pause_time;
+};
+
+struct ogma_normal {
+	u32 use_jumbo_pkt_flag:1;
+	u32 tx_little_endian_flag:1;
+	u32 rx_little_endian_flag:1;
+	u32 tx_tmr_mode_flag:1;
+	u32 rx_tmr_mode_flag:1;
+	struct ogma_pkt_ctrlaram pkt_ctrlaram;
+};
+
+struct ogma_desc_ring {
+	unsigned int id;
+	struct ogma_desc_param param;
+	u32 rx_desc_ring_flag:1;
+	u32 tx_desc_ring_flag:1;
+	u32 running_flag:1;
+	u32 full_flag:1;
+	u8 len;
+	u16 head_idx;
+	u16 tail_idx;
+	u16 rx_num;
+	u16 tx_done_num;
+	spinlock_t spinlock_desc; /* protect descriptor access */
+	void *ring_vaddr;
+	phys_addr_t deschys_addr;
+	struct ogma_frag_info *frag;
+	struct sk_buff **priv;
+};
+
+struct ogma_priv {
+	u32 core_enabled_flag:1;
+	u32 gmac_rx_running_flag:1;
+	u32 gmac_tx_running_flag:1;
+	u32 gmac_mode_valid_flag:1;
+	u32 normal_desc_ring_valid:1;
+	void __iomem *ioaddr;
+	struct device *dev;
+	struct ogma_param param;
+	struct ogma_clk_ctrl clk_ctrl;
+	u32 rx_pkt_buf_len;
+	struct ogma_desc_ring desc_ring[OGMA_RING_MAX + 1];
+	struct ogma_gmac_mode gmac_mode;
+	void *dummy_virt;
+	phys_addr_t dummy_phys;
+	struct ogma_normal normal;
+	u32 gmac_hz;
+	int phyads;
+	u32 scb_pkt_ctrl_reg;
+	u32 scb_set_normal_tx_phys_addr;
+	int irq;
+	u8 mac[ETH_ALEN];
+	struct net_device *net_device;
+	struct clk *clk[3];
+	int clock_count;
+	phys_addr_t rdlar_pa, tdlar_pa;
+};
+
+struct ogma_tx_desc_entry {
+	u32 attr;
+	u32 data_buf_addr;
+	u32 buf_len_info;
+	u32 reserved;
+};
+
+struct ogma_rx_de {
+	u32 attr;
+	u32 data_buf_addr;
+	u32 buf_len_info;
+	u32 reserved;
+};
+
+struct ogma_ndev {
+	struct ogma_priv *priv;
+	struct net_device *net_device;
+	struct napi_struct napi;
+
+	struct device *dev_p;
+	spinlock_t tx_queue_lock; /* protect transmit queue */
+	u32 rx_cksum_offload_flag:1;
+
+	unsigned short tx_desc_num;
+	unsigned short rx_desc_num;
+
+	/* Rx IRQ coalesce parameters */
+	unsigned short rxint_tmr_cnt_us;
+	unsigned short rxint_pktcnt;
+
+	unsigned short tx_empty_irq_activation_threshold;
+
+	struct task_struct *phy_handler_kthread_p;
+
+	u32 prev_link_status_flag:1;
+	u32 prev_auto_nego_complete_flag:1;
+};
+
+struct ogma_tx_pkt_ctrl {
+	u32 cksum_offload_flag:1;
+	u32 tcp_seg_offload_flag:1;
+	u8 target_desc_ring_id;
+	u16 tcp_seg_len;
+};
+
+struct ogma_rx_pkt_info {
+	u32 is_fragmented:1;
+	u32 err_flag:1;
+	u32 rx_cksum_result:2;
+	u8 err_code;
+};
+
+struct ogma_frag_info {
+	phys_addr_t phys_addr;
+	void *addr;
+	u32 len;
+};
+
+
+static inline void ogma_write_reg(struct ogma_priv *priv, u32 reg_addr, u32 val)
+{
+	writel(val, priv->ioaddr + (reg_addr << 2));
+}
+
+static inline u32 ogma_read_reg(struct ogma_priv *priv, u32 reg_addr)
+{
+	return readl(priv->ioaddr + (reg_addr << 2));
+}
+
+static inline void ogma_mark_skb_type(void *skb, bool recv_buf_flag)
+{
+	struct sk_buff *skb_p = (struct sk_buff *)skb;
+
+	*(bool *)skb_p->cb = recv_buf_flag;
+}
+
+static inline bool skb_is_rx(void *skb)
+{
+	struct sk_buff *skb_p = (struct sk_buff *)skb;
+
+	return *(bool *)skb_p->cb;
+}
+
+static inline bool ogma_is_pkt_desc_ring(const struct ogma_desc_ring *desc)
+{
+	return desc->rx_desc_ring_flag || desc->tx_desc_ring_flag;
+}
+
+extern const struct net_device_ops ogma_netdev_ops;
+extern const struct ethtool_ops ogma_ethtool_ops;
+
+int ogma_start_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag);
+int ogma_stop_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag);
+int ogma_set_gmac_mode(struct ogma_priv *priv,
+		       const struct ogma_gmac_mode *mode);
+void ogma_set_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr,
+		      u16 value);
+u16 ogma_get_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr);
+int ogma_start_desc_ring(struct ogma_priv *priv, unsigned int id);
+int ogma_stop_desc_ring(struct ogma_priv *priv, unsigned int id);
+u16 ogma_get_rx_num(struct ogma_priv *priv, unsigned int id);
+u16 ogma_get_tx_avail_num(struct ogma_priv *priv, unsigned int id);
+int ogma_clean_tx_desc_ring(struct ogma_priv *priv, unsigned int id);
+int ogma_clean_rx_desc_ring(struct ogma_priv *priv, unsigned int id);
+int ogma_set_tx_pkt_data(struct ogma_priv *priv, unsigned int id,
+			 const struct ogma_tx_pkt_ctrl *tx_ctrl, u8 scat_num,
+			 const struct ogma_frag_info *scat,
+			 struct sk_buff *skb);
+int ogma_get_rx_pkt_data(struct ogma_priv *priv, unsigned int id,
+			 struct ogma_rx_pkt_info *rxpi,
+			 struct ogma_frag_info *frag, u16 *len,
+			 struct sk_buff **skb);
+int ogma_ring_irq_enable(struct ogma_priv *priv,
+			 unsigned int id, u32 irq_factor);
+void ogma_ring_irq_disable(struct ogma_priv *priv, unsigned int id, u32 irqf);
+int ogma_set_irq_coalesce_param(struct ogma_priv *priv, unsigned int id,
+				u16 int_pktcnt, bool int_tmr_unit_ms_flag,
+				u16 int_tmr_cnt);
+int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id);
+void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc);
+int ogma_setup_rx_desc(struct ogma_priv *priv,
+		       struct ogma_desc_ring *desc);
+int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget);
+
+#endif /* OGMA_INTERNAL_H */
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
new file mode 100755
index 0000000..b5a226c
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
@@ -0,0 +1,769 @@
+/**
+ * ogma_desc_ring_access.c
+ *
+ *  Copyright (C) 2011 - 2014 Fujitsu Semiconductor Limited.
+ *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
+ *  All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version 2
+ *  of the License, or (at your option) any later version.
+ */
+
+#include <linux/spinlock.h>
+#include <linux/dma-mapping.h>
+
+#include "ogma.h"
+
+static const u32 ads_irq_set[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_INTEN_SET,
+	OGMA_REG_NRM_RX_INTEN_SET,
+	0,
+	0
+};
+
+static const u32 desc_ring_irq_inten_clr_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_INTEN_CLR,
+	OGMA_REG_NRM_RX_INTEN_CLR,
+	0,
+	0
+};
+
+static const u32 int_tmr_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_TXINT_TMR,
+	OGMA_REG_NRM_RX_RXINT_TMR,
+	0,
+	0
+};
+
+static const u32 rx_pkt_cnt_reg_addr[OGMA_RING_MAX + 1] = {
+	0,
+	OGMA_REG_NRM_RX_PKTCNT,
+	0,
+	0
+};
+
+static const u32 tx_pkt_cnt_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_PKTCNT,
+	0,
+	0,
+	0
+};
+
+static const u32 int_pkt_cnt_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_DONE_TXINT_PKTCNT,
+	OGMA_REG_NRM_RX_RXINT_PKTCNT,
+	0,
+	0
+};
+
+static const u32 tx_done_pkt_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_DONE_PKTCNT,
+	0,
+	0,
+	0
+};
+
+static void ogma_check_desc_own_sanity(const struct ogma_desc_ring *desc,
+				       u16 idx, unsigned int expected_own)
+{
+	u32 tmp = *(u32 *)(desc->ring_vaddr + desc->len * idx);
+
+	BUG_ON((tmp >> 31) != expected_own);
+}
+
+int ogma_ring_irq_enable(struct ogma_priv *priv, unsigned int id, u32 irqf)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	int ret = 0;
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		dev_err(priv->dev, "desc ring not running\n");
+		ret = -ENODEV;
+		goto err;
+	}
+
+	ogma_write_reg(priv, ads_irq_set[id], irqf);
+
+err:
+	spin_unlock(&desc->spinlock_desc);
+
+	return ret;
+}
+
+void ogma_ring_irq_disable(struct ogma_priv *priv, unsigned int id, u32 irqf)
+{
+	ogma_write_reg(priv, desc_ring_irq_inten_clr_reg_addr[id], irqf);
+}
+
+static int alloc_pkt_buf(struct ogma_priv *priv, u16 len, void **addr_p,
+			 phys_addr_t *phys, struct sk_buff **pskb)
+{
+	struct sk_buff *skb = netdev_alloc_skb_ip_align(priv->net_device, len);
+
+	if (!skb)
+		return -ENOMEM;
+
+	*phys = dma_map_single(priv->dev, skb->data, len, DMA_FROM_DEVICE);
+	if (!*phys) {
+		dev_kfree_skb(skb);
+
+		return -ENOMEM;
+	}
+
+	*addr_p = skb->data;
+	*pskb = skb;
+
+	ogma_mark_skb_type(skb, OGMA_RING_NRM_RX);
+
+	return 0;
+}
+
+static void kfree_pkt_buf(struct device *dev, struct ogma_frag_info *frag,
+			  bool last_flag, struct sk_buff *skb)
+{
+	dma_unmap_single(dev, frag->phys_addr, frag->len,
+			 skb_is_rx(skb) ? DMA_FROM_DEVICE : DMA_TO_DEVICE);
+	if (last_flag)
+		dev_kfree_skb(skb);
+}
+
+int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	struct ogma_desc_param *param = &desc->param;
+	struct ogma_desc_param *desc_param = &priv->param.desc_param[id];
+	u8 rx_de_len = 0;
+	int ret = 0;
+
+	if (desc_param->valid_flag && (desc_param->entries < OGMA_DESC_MIN ||
+				       desc_param->entries > OGMA_DESC_MAX)) {
+		dev_err(priv->dev, "%s: Invalid entries\n", __func__);
+		return -EINVAL;
+	}
+
+	desc->id = id;
+
+	memcpy(param, desc_param, sizeof(*param));
+	if (!param->valid_flag) {
+		desc->deschys_addr = priv->dummy_phys;
+		return 0;
+	}
+
+	if (id == OGMA_RING_NRM_RX || id == OGMA_RING_RESERVED_RX)
+		rx_de_len = 16;
+
+	switch (id) {
+	case OGMA_RING_NRM_TX:
+		desc->tx_desc_ring_flag = 1;
+		desc->len = sizeof(struct ogma_tx_desc_entry);
+		break;
+
+	case OGMA_RING_NRM_RX:
+		desc->rx_desc_ring_flag = 1;
+		desc->len = rx_de_len;
+		break;
+
+	case OGMA_RING_RESERVED_RX:
+		desc->rx_desc_ring_flag = 1;
+		desc->len = rx_de_len;
+		break;
+
+	case OGMA_RING_RESERVED_TX:
+		desc->tx_desc_ring_flag = 1;
+		desc->len = sizeof(struct ogma_tx_desc_entry);
+		break;
+
+	default:
+		BUG_ON(1);
+	}
+
+	spin_lock_init(&desc->spinlock_desc);
+
+	desc->ring_vaddr = dma_alloc_coherent(NULL,
+					      desc->len * param->entries,
+					      &desc->deschys_addr, GFP_KERNEL);
+	if (!desc->ring_vaddr) {
+		ret = -ENOMEM;
+		dev_err(priv->dev, "%s: failed to alloc\n", __func__);
+		goto err;
+	}
+
+	memset(desc->ring_vaddr, 0, (u32) desc->len * param->entries);
+	desc->frag = kmalloc(sizeof(*desc->frag) * param->entries,
+			     GFP_NOWAIT);
+	if (!desc->frag) {
+		ret = -ENOMEM;
+		dev_err(priv->dev, "%s: failed to alloc\n", __func__);
+		goto err;
+	}
+
+	memset(desc->frag, 0, sizeof(struct ogma_frag_info) * param->entries);
+	desc->priv = kmalloc(sizeof(struct sk_buff *) * param->entries,
+			     GFP_NOWAIT);
+	if (!desc->priv) {
+		ret = -ENOMEM;
+		dev_err(priv->dev, "%s: failed to alloc priv\n", __func__);
+		goto err;
+	}
+
+	memset(desc->priv, 0, sizeof(struct sk_buff *) * param->entries);
+
+	return 0;
+
+err:
+	ogma_free_desc_ring(priv, desc);
+
+	return ret;
+}
+
+void ogma_uninit_pkt_desc_ring(struct ogma_priv *priv,
+			       struct ogma_desc_ring *desc)
+{
+	int count = desc->param.entries;
+	struct ogma_frag_info *frag;
+	u32 *status;
+	u16 idx;
+
+	for (idx = 0; idx < count; idx++) {
+		frag = &desc->frag[idx];
+		if (!frag->addr)
+			continue;
+
+		status = desc->ring_vaddr + desc->len * idx;
+		kfree_pkt_buf(priv->dev, frag, (*status >> OGMA_TX_LAST) & 1,
+			      desc->priv[idx]);
+	}
+
+	memset(desc->frag, 0, sizeof(struct ogma_frag_info) * count);
+	memset(desc->priv, 0, sizeof(struct sk_buff *) * count);
+	memset(desc->ring_vaddr, 0, desc->len * count);
+}
+
+void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc)
+{
+	if (!desc->param.valid_flag)
+		return;
+
+	if (ogma_is_pkt_desc_ring(desc))
+		if (desc->ring_vaddr && desc->frag && desc->priv)
+			ogma_uninit_pkt_desc_ring(priv, desc);
+
+	if (desc->ring_vaddr)
+		dma_free_coherent(priv->dev, desc->len * desc->param.entries,
+				  desc->ring_vaddr, desc->deschys_addr);
+	kfree(desc->frag);
+	kfree(desc->priv);
+
+	memset(desc, 0, sizeof(*desc));
+}
+
+static void ogma_set_rx_de(struct ogma_priv *priv,
+			   struct ogma_desc_ring *desc, u16 idx,
+			   const struct ogma_frag_info *frag,
+			   struct sk_buff *skb)
+{
+	struct ogma_rx_de de;
+
+	ogma_check_desc_own_sanity(desc, idx, 0);
+	memset(&de, 0, sizeof(de));
+
+	de.attr = 1 << OGMA_RX_PKT_OWN_FIELD | 1 << OGMA_RX_PKT_FS_FIELD |
+					       1 << OGMA_RX_PKT_LS_FIELD;
+	de.data_buf_addr = frag->phys_addr;
+	de.buf_len_info = frag->len;
+
+	if (idx == desc->param.entries - 1)
+		de.attr |= 1 << OGMA_RX_PKT_LD_FIELD;
+
+	memcpy(desc->ring_vaddr + desc->len * idx + 4, &de + 4, desc->len - 4);
+	wmb(); /* make sure descriptor is written */
+	memcpy(desc->ring_vaddr + desc->len * idx, &de, 4);
+
+	desc->frag[idx].phys_addr = frag->phys_addr;
+	desc->frag[idx].addr = frag->addr;
+	desc->frag[idx].len = frag->len;
+
+	desc->priv[idx] = skb;
+}
+
+int ogma_setup_rx_desc(struct ogma_priv *priv, struct ogma_desc_ring *desc)
+{
+	struct ogma_frag_info frag_info = { 0, 0, 0 };
+	struct sk_buff *pkt;
+	int err;
+	int n;
+
+	frag_info.len = priv->rx_pkt_buf_len;
+
+	for (n = 0; n < desc->param.entries; n++) {
+		err = alloc_pkt_buf(priv, frag_info.len, &frag_info.addr,
+				    &frag_info.phys_addr, &pkt);
+		if (err) {
+			ogma_uninit_pkt_desc_ring(priv, desc);
+			dev_err(priv->dev, "%s: Fail ring alloc\n", __func__);
+			return -ENOMEM;
+		}
+		ogma_set_rx_de(priv, desc, n, &frag_info, pkt);
+	}
+
+	return 0;
+}
+
+static void ogma_set_tx_desc_entry(struct ogma_priv *priv,
+				   struct ogma_desc_ring *desc,
+				   const struct ogma_tx_pkt_ctrl *tx_ctrl,
+				   bool first_flag, bool last_flag,
+				   const struct ogma_frag_info *frag,
+				   struct sk_buff *skb)
+{
+	struct ogma_tx_desc_entry tx_desc_entry;
+	int idx = desc->head_idx;
+	u32 attr;
+
+	ogma_check_desc_own_sanity(desc, idx, 0);
+
+	memset(&tx_desc_entry, 0, sizeof(struct ogma_tx_desc_entry));
+
+	attr = 1 << OGMA_TX_SHIFT_OWN_FIELD |
+	       (idx == (desc->param.entries - 1)) << OGMA_TX_SHIFT_LD_FIELD |
+	       desc->id << OGMA_TX_SHIFT_DRID_FIELD |
+	       1 << OGMA_TX_SHIFT_PT_FIELD |
+	       tx_ctrl->target_desc_ring_id << OGMA_TX_SHIFT_TDRID_FIELD |
+	       first_flag << OGMA_TX_SHIFT_FS_FIELD |
+	       last_flag << OGMA_TX_LAST |
+	       tx_ctrl->cksum_offload_flag << OGMA_TX_SHIFT_CO_FIELD |
+	       tx_ctrl->tcp_seg_offload_flag << OGMA_TX_SHIFT_SO_FIELD |
+	       1 << OGMA_TX_SHIFT_TRS_FIELD;
+
+	tx_desc_entry.attr = attr;
+	tx_desc_entry.data_buf_addr = frag->phys_addr;
+	tx_desc_entry.buf_len_info = (tx_ctrl->tcp_seg_len << 16) | frag->len;
+
+	memcpy(desc->ring_vaddr + (desc->len * idx), &tx_desc_entry, desc->len);
+
+	desc->frag[idx].phys_addr = frag->phys_addr;
+	desc->frag[idx].addr = frag->addr;
+	desc->frag[idx].len = frag->len;
+
+	desc->priv[idx] = skb;
+}
+
+static void ogma_get_rx_de(struct ogma_priv *priv,
+			   struct ogma_desc_ring *desc, u16 idx,
+			   struct ogma_rx_pkt_info *rxpi,
+			   struct ogma_frag_info *frag, u16 *len,
+			   struct sk_buff **skb)
+{
+	struct ogma_rx_de de;
+
+	ogma_check_desc_own_sanity(desc, idx, 0);
+	memset(&de, 0, sizeof(struct ogma_rx_de));
+	memset(rxpi, 0, sizeof(struct ogma_rx_pkt_info));
+	memcpy(&de, ((void *)desc->ring_vaddr + desc->len * idx), desc->len);
+
+	dev_dbg(priv->dev, "%08x\n", *(u32 *)&de);
+	*len = de.buf_len_info >> 16;
+
+	rxpi->is_fragmented = (de.attr >> OGMA_RX_PKT_FR_FIELD) & 1;
+	rxpi->err_flag = (de.attr >> OGMA_RX_PKT_ER_FIELD) & 1;
+	rxpi->rx_cksum_result = (de.attr >> OGMA_RX_PKT_CO_FIELD) & 3;
+	rxpi->err_code = (de.attr >> OGMA_RX_PKT_ERR_FIELD) &
+							OGMA_RX_PKT_ERR_MASK;
+	memcpy(frag, &desc->frag[idx], sizeof(*frag));
+	*skb = desc->priv[idx];
+}
+
+static void ogma_inc_desc_head_idx(struct ogma_priv *priv,
+				   struct ogma_desc_ring *desc, u16 increment)
+{
+	u32 sum;
+
+	if ((desc->tail_idx > desc->head_idx) || desc->full_flag)
+		BUG_ON(increment > (desc->tail_idx - desc->head_idx));
+	else
+		BUG_ON(increment > (desc->param.entries + desc->tail_idx -
+							desc->head_idx));
+
+	sum = desc->head_idx + increment;
+
+	if (sum >= desc->param.entries)
+		sum -= desc->param.entries;
+
+	desc->head_idx = sum;
+	desc->full_flag = desc->head_idx == desc->tail_idx;
+}
+
+static void ogma_inc_desc_tail_idx(struct ogma_priv *priv,
+				   struct ogma_desc_ring *desc, u16 increment)
+{
+	u32 sum;
+
+	if ((desc->head_idx >= desc->tail_idx) && (!desc->full_flag))
+		BUG_ON(increment > (desc->head_idx - desc->tail_idx));
+	else
+		BUG_ON(increment > (desc->param.entries +
+					desc->head_idx - desc->tail_idx));
+
+	sum = desc->tail_idx + increment;
+
+	if (sum >= desc->param.entries)
+		sum -= desc->param.entries;
+
+	desc->tail_idx = sum;
+	desc->full_flag = 0;
+}
+
+static u16 ogma_get_tx_avail_num_sub(struct ogma_priv *priv,
+				     const struct ogma_desc_ring *desc)
+{
+	if (desc->full_flag)
+		return 0;
+
+	if (desc->tail_idx > desc->head_idx)
+		return desc->tail_idx - desc->head_idx;
+
+	return desc->param.entries + desc->tail_idx - desc->head_idx;
+}
+
+static u16 ogma_get_tx_done_num_sub(struct ogma_priv *priv,
+				    struct ogma_desc_ring *desc)
+{
+	desc->tx_done_num += ogma_read_reg(priv, tx_done_pkt_addr[desc->id]);
+
+	return desc->tx_done_num;
+}
+
+int ogma_start_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	int ret = 0;
+
+	BUG_ON(!desc->param.valid_flag);
+
+	spin_lock_bh(&desc->spinlock_desc);
+
+	if (desc->running_flag) {
+		ret = -EBUSY;
+		goto err;
+	}
+
+	if (desc->rx_desc_ring_flag) {
+		ogma_write_reg(priv, ads_irq_set[id], OGMA_IRQ_RCV);
+		ogma_write_reg(priv, int_pkt_cnt_reg_addr[id], 1);
+	}
+	if (desc->tx_desc_ring_flag) {
+		ogma_write_reg(priv, ads_irq_set[id], OGMA_IRQ_EMPTY);
+		ogma_write_reg(priv, int_pkt_cnt_reg_addr[id], 1);
+	}
+
+	desc->running_flag = 1;
+
+err:
+	spin_unlock_bh(&desc->spinlock_desc);
+
+	return ret;
+}
+
+int ogma_stop_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	int ret = 0;
+
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!desc->param.valid_flag);
+
+	if (!ogma_is_pkt_desc_ring(desc))
+		return -EINVAL;
+
+	spin_lock_bh(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	ogma_write_reg(priv, desc_ring_irq_inten_clr_reg_addr[id],
+		       OGMA_IRQ_RCV | OGMA_IRQ_EMPTY | OGMA_IRQ_SND);
+
+	desc->running_flag = 0;
+
+err:
+	spin_unlock_bh(&desc->spinlock_desc);
+
+	return ret;
+}
+
+u16 ogma_get_rx_num(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	u8 tmp_ring_id = id;
+	u32 result;
+
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!desc->param.valid_flag);
+	BUG_ON(!desc->rx_desc_ring_flag);
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		spin_unlock(&desc->spinlock_desc);
+		dev_err(priv->dev, "%s: stopped desc ring\n", __func__);
+		return 0;
+	}
+
+	result = ogma_read_reg(priv, rx_pkt_cnt_reg_addr[tmp_ring_id]);
+	desc->rx_num += result;
+	if (desc->rx_desc_ring_flag && result)
+		ogma_inc_desc_head_idx(priv, desc, result);
+
+	spin_unlock(&desc->spinlock_desc);
+
+	return desc->rx_num;
+}
+
+u16 ogma_get_tx_avail_num(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	u16 result;
+
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!desc->param.valid_flag);
+	BUG_ON(!desc->tx_desc_ring_flag);
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		dev_err(priv->dev, "%s: not running tx desc\n", __func__);
+		result = 0;
+		goto err;
+	}
+
+	result = ogma_get_tx_avail_num_sub(priv, desc);
+
+err:
+	spin_unlock(&desc->spinlock_desc);
+
+	return result;
+}
+
+int ogma_clean_tx_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	struct ogma_tx_desc_entry *entry;
+	struct ogma_frag_info *frag;
+	bool is_last;
+
+	BUG_ON(!priv || id > OGMA_RING_MAX);
+	BUG_ON(!desc->param.valid_flag);
+	BUG_ON(!desc->tx_desc_ring_flag);
+
+	spin_lock(&desc->spinlock_desc);
+
+	ogma_get_tx_done_num_sub(priv, desc);
+
+	while ((desc->tail_idx != desc->head_idx || desc->full_flag) &&
+	       desc->tx_done_num) {
+		frag = &desc->frag[desc->tail_idx];
+		entry = desc->ring_vaddr + desc->len * desc->tail_idx;
+		is_last = (entry->attr >> OGMA_TX_LAST) & 1;
+
+		kfree_pkt_buf(priv->dev, frag, is_last,
+			      desc->priv[desc->tail_idx]);
+		memset(frag, 0, sizeof(*frag));
+		ogma_inc_desc_tail_idx(priv, desc, 1);
+
+		if (is_last) {
+			BUG_ON(!desc->tx_done_num);
+			desc->tx_done_num--;
+		}
+	}
+
+	spin_unlock(&desc->spinlock_desc);
+
+	return 0;
+}
+
+int ogma_clean_rx_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!priv->desc_ring[id].param.valid_flag);
+	BUG_ON(!priv->desc_ring[id].rx_desc_ring_flag);
+
+	spin_lock(&desc->spinlock_desc);
+
+	while (desc->full_flag || (desc->tail_idx != desc->head_idx)) {
+		ogma_set_rx_de(priv, desc, desc->tail_idx,
+			       &desc->frag[desc->tail_idx],
+			       desc->priv[desc->tail_idx]);
+		desc->rx_num--;
+		ogma_inc_desc_tail_idx(priv, desc, 1);
+	}
+
+	BUG_ON(desc->rx_num);	/* error check */
+
+	spin_unlock(&desc->spinlock_desc);
+
+	return 0;
+}
+
+int ogma_set_tx_pkt_data(struct ogma_priv *priv, unsigned int id,
+			 const struct ogma_tx_pkt_ctrl *tx_ctrl, u8 scat_num,
+			 const struct ogma_frag_info *scat, struct sk_buff *skb)
+{
+	struct ogma_desc_ring *desc;
+	u32 sum_len = 0;
+	unsigned int i;
+	u16 pend_tx;
+	int ret = 0;
+
+	BUG_ON(tx_ctrl == NULL || scat == NULL || id > OGMA_RING_MAX);
+	BUG_ON(!priv->desc_ring[id].param.valid_flag);
+	BUG_ON(!priv->desc_ring[id].tx_desc_ring_flag);
+
+	if (tx_ctrl->target_desc_ring_id != OGMA_RING_GMAC)
+		return -ENODATA;
+
+	if (tx_ctrl->tcp_seg_offload_flag && (!tx_ctrl->cksum_offload_flag))
+		return -ENODATA;
+
+	if (tx_ctrl->tcp_seg_offload_flag) {
+		if (tx_ctrl->tcp_seg_len < OGMA_TCP_SEG_LEN_MIN)
+			return -ENODATA;
+
+		if (priv->param.use_jumbo_pkt_flag) {
+			if (tx_ctrl->tcp_seg_len > OGMA_TCP_JUMBO_SEG_LEN_MAX)
+				return -ENODATA;
+		} else {
+			if (tx_ctrl->tcp_seg_len > OGMA_TCP_SEG_LEN_MAX)
+				return -ENODATA;
+		}
+	} else
+		if (tx_ctrl->tcp_seg_len)
+			return -ENODATA;
+
+	if (!scat_num)
+		return -ERANGE;
+
+	for (i = 0; i < scat_num; i++) {
+		if ((scat[i].len == 0) || (scat[i].len > 0xffffU)) {
+			dev_err(priv->dev, "%s: bad scat len\n", __func__);
+			return -ENODATA;
+		}
+		sum_len += scat[i].len;
+	}
+
+	if (!tx_ctrl->tcp_seg_offload_flag) {
+		if (priv->param.use_jumbo_pkt_flag) {
+			if (sum_len > OGMA_MAX_TX_JUMBO_PKT_LEN)
+				return -ENODATA;
+		} else
+			if (sum_len > OGMA_MAX_TX_PKT_LEN)
+				return -ENODATA;
+	}
+
+	desc = &priv->desc_ring[id];
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		ret = -ENODEV;
+		goto end;
+	}
+
+	pend_tx = ogma_get_tx_avail_num_sub(priv, desc);
+
+	if (scat_num > pend_tx) {
+		ret = -EBUSY;
+		goto end;
+	}
+
+	for (i = 0; i < scat_num; i++) {
+		ogma_set_tx_desc_entry(priv, desc, tx_ctrl, i == 0,
+				       i == scat_num - 1, &scat[i], skb);
+		ogma_inc_desc_head_idx(priv, desc, 1);
+	}
+
+	wmb(); /* ensure the descriptor is flushed */
+
+	ogma_write_reg(priv, tx_pkt_cnt_reg_addr[id], 1);
+
+end:
+	spin_unlock(&desc->spinlock_desc);
+
+	return ret;
+}
+
+int ogma_get_rx_pkt_data(struct ogma_priv *priv, unsigned int id,
+			 struct ogma_rx_pkt_info *rxpi,
+			 struct ogma_frag_info *frag, u16 *len,
+			 struct sk_buff **skb)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	struct ogma_frag_info tmp_frag_info;
+	struct sk_buff *tmp_pkt_handle;
+	int ret = 0;
+	int err;
+
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!desc->param.valid_flag || !desc->rx_desc_ring_flag);
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running_flag) {
+		ret = -ENODEV;
+		goto err;
+	}
+
+	if (desc->rx_num == 0) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	tmp_frag_info.len = priv->rx_pkt_buf_len;
+	rmb(); /* make sure reads are completed */
+	err = alloc_pkt_buf(priv, tmp_frag_info.len, &tmp_frag_info.addr,
+			    &tmp_frag_info.phys_addr, &tmp_pkt_handle);
+	if (err) {
+		ogma_set_rx_de(priv, desc, desc->tail_idx,
+			       &desc->frag[desc->tail_idx],
+			       desc->priv[desc->tail_idx]);
+		ret = -ENOMEM;
+	} else {
+		ogma_get_rx_de(priv, desc, desc->tail_idx, rxpi, frag, len,
+			       skb);
+		ogma_set_rx_de(priv, desc, desc->tail_idx, &tmp_frag_info,
+			       tmp_pkt_handle);
+	}
+
+	ogma_inc_desc_tail_idx(priv, desc, 1);
+	desc->rx_num--;
+
+err:
+	spin_unlock(&desc->spinlock_desc);
+
+	return ret;
+}
+
+int ogma_set_irq_coalesce_param(struct ogma_priv *priv, unsigned int id,
+				u16 int_pktcnt, bool int_tmr_unit_ms_flag,
+				u16 int_tmr_cnt)
+{
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(int_pktcnt > OGMA_INT_PKTCNT_MAX);
+	BUG_ON(!priv->desc_ring[id].param.valid_flag);
+
+	if (!ogma_is_pkt_desc_ring(&priv->desc_ring[id]))
+		return -EINVAL;
+
+	ogma_write_reg(priv, int_pkt_cnt_reg_addr[id], int_pktcnt);
+	ogma_write_reg(priv, int_tmr_reg_addr[id],
+		       (int_tmr_unit_ms_flag) << 31 | int_tmr_cnt);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c b/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
new file mode 100755
index 0000000..2bb9e78
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
@@ -0,0 +1,238 @@
+/**
+ * ogma_gmac_access.c
+ *
+ *  Copyright (C) 2011 - 2014 Fujitsu Semiconductor Limited.
+ *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
+ *  All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version 2
+ *  of the License, or (at your option) any later version.
+ */
+#include "ogma.h"
+
+static u32 ogma_clk_type(u32 gmac_hz)
+{
+	if (gmac_hz < 35 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_25_35_MHZ;
+
+	if (gmac_hz < 60 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_35_60_MHZ;
+
+	if (gmac_hz < 100 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_60_100_MHZ;
+
+	if (gmac_hz < 150 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_100_150_MHZ;
+
+	if (gmac_hz < 250 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_150_250_MHZ;
+
+	return OGMA_GMAC_GAR_REG_CR_250_300_MHZ;
+}
+
+void ogma_mac_write(struct ogma_priv *priv, u32 addr, u32 value)
+{
+	ogma_write_reg(priv, MAC_REG_DATA, value);
+	ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_WRITE);
+
+	while (ogma_read_reg(priv, MAC_REG_CMD) & OGMA_GMAC_CMD_ST_BUSY)
+		;
+}
+
+u32 ogma_mac_read(struct ogma_priv *priv, u32 addr)
+{
+	ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_READ);
+	while (ogma_read_reg(priv, MAC_REG_CMD) & OGMA_GMAC_CMD_ST_BUSY)
+		;
+	return ogma_read_reg(priv, MAC_REG_DATA);
+}
+
+int ogma_start_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag)
+{
+	u32 value;
+
+	BUG_ON(!priv->gmac_mode_valid_flag);
+
+	if (!rx_flag && !tx_flag)
+		return 0;
+
+	if (priv->gmac_rx_running_flag && priv->gmac_tx_running_flag)
+		return 0;
+
+	if (rx_flag && priv->gmac_rx_running_flag && !tx_flag)
+		return 0;
+
+	if (tx_flag && priv->gmac_tx_running_flag && !rx_flag)
+		return 0;
+
+	if (!priv->gmac_rx_running_flag && !priv->gmac_tx_running_flag) {
+		if (priv->gmac_mode.link_speed == OGMA_PHY_LINK_SPEED_1G)
+			ogma_mac_write(priv, GMAC_REG_MCR, 0);
+		else
+			ogma_mac_write(priv, GMAC_REG_MCR, OGMA_GMAC_MCR_PS);
+
+		ogma_mac_write(priv, GMAC_REG_BMR, OGMA_GMAC_BMR_REG_RESET);
+
+		/* Wait soft reset */
+		usleep_range(1000, 5000);
+
+		if (ogma_mac_read(priv, GMAC_REG_BMR) & OGMA_GMAC_BMR_REG_SWR)
+			return -EAGAIN;
+
+		ogma_write_reg(priv, MAC_REG_DESC_SOFT_RST, 1);
+		while (ogma_read_reg(priv, MAC_REG_DESC_SOFT_RST) & 1)
+			;
+
+		ogma_write_reg(priv, MAC_REG_DESC_INIT, 1);
+		while (ogma_read_reg(priv, MAC_REG_DESC_INIT) & 1)
+			;
+
+		ogma_mac_write(priv, GMAC_REG_BMR, OGMA_GMAC_BMR_REG_COMMON);
+		ogma_mac_write(priv, GMAC_REG_RDLAR, priv->rdlar_pa);
+		ogma_mac_write(priv, GMAC_REG_TDLAR, priv->tdlar_pa);
+		ogma_mac_write(priv, GMAC_REG_MFFR, 0x80000001);
+
+		value = (priv->gmac_mode.half_duplex_flag ?
+			 OGMA_GMAC_MCR_REG_HALF_DUPLEX_COMMON :
+			 OGMA_GMAC_MCR_REG_FULL_DUPLEX_COMMON);
+
+		if (priv->gmac_mode.link_speed != OGMA_PHY_LINK_SPEED_1G)
+			value |= OGMA_GMAC_MCR_PS;
+
+		if ((priv->param.gmac_config.phy_if != OGMA_PHY_IF_GMII) &&
+		    (priv->gmac_mode.link_speed == OGMA_PHY_LINK_SPEED_100M))
+			value |= OGMA_GMAC_MCR_REG_FES;
+
+		value |= OGMA_GMAC_MCR_REG_CST | OGMA_GMAC_MCR_REG_JE;
+		ogma_mac_write(priv, GMAC_REG_MCR, value);
+
+		if (priv->gmac_mode.flow_ctrl_enable_flag) {
+			ogma_write_reg(priv, MAC_REG_FLOW_TH,
+				       (priv->gmac_mode.flow_stop_th << 16) |
+				       priv->gmac_mode.flow_start_th);
+			ogma_mac_write(priv, GMAC_REG_FCR,
+				       (priv->gmac_mode.pause_time << 16) |
+				       OGMA_GMAC_FCR_REG_RFE |
+				       OGMA_GMAC_FCR_REG_TFE);
+		}
+	}
+
+	if ((rx_flag && !priv->gmac_rx_running_flag) ||
+	    (tx_flag && !priv->gmac_tx_running_flag)) {
+		value = ogma_mac_read(priv, GMAC_REG_OMR);
+
+		if (rx_flag && (!priv->gmac_rx_running_flag)) {
+			value |= OGMA_GMAC_OMR_REG_SR;
+			priv->gmac_rx_running_flag = 1;
+		}
+		if (tx_flag && (!priv->gmac_tx_running_flag)) {
+			value |= OGMA_GMAC_OMR_REG_ST;
+			priv->gmac_tx_running_flag = 1;
+		}
+
+		ogma_mac_write(priv, GMAC_REG_OMR, value);
+	}
+
+	return 0;
+}
+
+int ogma_stop_gmac(struct ogma_priv *priv, bool rx_flag, bool tx_flag)
+{
+	u32 value;
+
+	if (!rx_flag && !tx_flag)
+		return 0;
+
+	if ((rx_flag && priv->gmac_rx_running_flag) ||
+	    (tx_flag && priv->gmac_tx_running_flag)) {
+		value = ogma_mac_read(priv, GMAC_REG_OMR);
+
+		if (rx_flag && priv->gmac_rx_running_flag) {
+			value &= (~OGMA_GMAC_OMR_REG_SR);
+			priv->gmac_rx_running_flag = 0;
+		}
+		if (tx_flag && priv->gmac_tx_running_flag) {
+			value &= (~OGMA_GMAC_OMR_REG_ST);
+			priv->gmac_tx_running_flag = 0;
+		}
+
+		ogma_mac_write(priv, GMAC_REG_OMR, value);
+	}
+
+	return 0;
+}
+
+int ogma_set_gmac_mode(struct ogma_priv *priv,
+		       const struct ogma_gmac_mode *mode)
+{
+	if (priv->gmac_rx_running_flag || priv->gmac_tx_running_flag)
+		return -EBUSY;
+
+	if (mode->link_speed != OGMA_PHY_LINK_SPEED_1G &&
+	    mode->link_speed != OGMA_PHY_LINK_SPEED_100M &&
+	    mode->link_speed != OGMA_PHY_LINK_SPEED_10M) {
+		dev_err(priv->dev, "%s: bad link speed\n", __func__);
+		return -ENODATA;
+	}
+
+	if (mode->link_speed == OGMA_PHY_LINK_SPEED_1G &&
+	    mode->half_duplex_flag) {
+		dev_err(priv->dev, "%s: 1G + half duplex\n", __func__);
+		return -ENODATA;
+	}
+
+	if (mode->half_duplex_flag && mode->flow_ctrl_enable_flag) {
+		dev_err(priv->dev, "%s: half duplex + flow\n", __func__);
+		return -ENODATA;
+	}
+
+	if (mode->flow_ctrl_enable_flag) {
+		if (!mode->flow_start_th ||
+		    mode->flow_start_th > OGMA_FLOW_START_TH_MAX)
+			return -ENODATA;
+
+		if (mode->flow_stop_th < mode->flow_start_th ||
+		    mode->flow_stop_th > OGMA_FLOW_STOP_TH_MAX)
+			return -ENODATA;
+
+		if (mode->pause_time < OGMA_FLOW_PAUSE_TIME_MIN)
+			return -ENODATA;
+	}
+
+	memcpy(&priv->gmac_mode, mode, sizeof(struct ogma_gmac_mode));
+	priv->gmac_mode_valid_flag = 1;
+
+	return 0;
+}
+
+void ogma_set_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg, u16 value)
+{
+	BUG_ON(phy_addr >= 32 || reg >= 32);
+
+	ogma_mac_write(priv, GMAC_REG_GDR, value);
+	ogma_mac_write(priv, GMAC_REG_GAR,
+		       phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
+		       reg << OGMA_GMAC_GAR_REG_SHIFT_GR |
+		       ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR |
+		       OGMA_GMAC_GAR_REG_GW | OGMA_GMAC_GAR_REG_GB);
+
+	while (ogma_mac_read(priv, GMAC_REG_GAR) & OGMA_GMAC_GAR_REG_GB)
+		;
+}
+
+u16 ogma_get_phy_reg(struct ogma_priv *priv, u8 phy_addr, u8 reg_addr)
+{
+	BUG_ON(phy_addr >= 32 || reg_addr >= 32);
+
+	ogma_mac_write(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB |
+		       phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
+		       reg_addr << OGMA_GMAC_GAR_REG_SHIFT_GR |
+		       ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR);
+
+	while (ogma_mac_read(priv, GMAC_REG_GAR) & OGMA_GMAC_GAR_REG_GB)
+		;
+
+	return ogma_mac_read(priv, GMAC_REG_GDR);
+}
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
new file mode 100755
index 0000000..5f43713
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
@@ -0,0 +1,599 @@
+/**
+ * ogma_ndev.c
+ *
+ *  Copyright (C) 2013-2014 Fujitsu Semiconductor Limited.
+ *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
+ *  All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version 2
+ *  of the License, or (at your option) any later version.
+ */
+
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
+#include <net/ip6_checksum.h>
+#include <net/rtnetlink.h>
+#include <linux/kernel.h>
+#include <linux/etherdevice.h>
+#include <linux/sched.h>
+#include <linux/pm_runtime.h>
+#include <linux/kthread.h>
+
+#include "ogma.h"
+
+#define OGMA_PHY_SR_REG_AN_C			(0x0020U)
+#define OGMA_PHY_SR_REG_LINK			(0x0004U)
+
+#define OGMA_PHY_1000BASE_REG_FULL		(0x0800U)
+
+#define OGMA_PHY_ANLPA_REG_TXF			(0x0100U)
+#define OGMA_PHY_ANLPA_REG_TXD			(0x0080U)
+#define OGMA_PHY_ANLPA_REG_TF			(0x0040U)
+#define OGMA_PHY_ANLPA_REG_TD			(0x0020U)
+
+#define OGMA_PHY_CTRL_REG_RESET			(1 << 15)
+#define OGMA_PHY_CTRL_REG_LOOPBACK		(1 << 14)
+#define OGMA_PHY_CTRL_REG_SPSEL_LSB		(1 << 13)
+#define OGMA_PHY_CTRL_REG_AUTO_NEGO_EN		(1 << 12)
+#define OGMA_PHY_CTRL_REG_POWER_DOWN		(1 << 11)
+#define OGMA_PHY_CTRL_REG_ISOLATE		(1 << 10)
+#define OGMA_PHY_CTRL_REG_RESTART_AUTO_NEGO	(1 << 9)
+#define OGMA_PHY_CTRL_REG_DUPLEX_MODE		(1 << 8)
+#define OGMA_PHY_CTRL_REG_COL_TEST		(1 << 7)
+#define OGMA_PHY_CTRL_REG_SPSEL_MSB		(1 << 6)
+#define OGMA_PHY_CTRL_REG_UNIDIR_EN		(1 << 5)
+
+#define OGMA_PHY_MSC_REG_1000BASE_FULL		(1 << 9)
+
+#define OGMA_PHY_REG_ADDR_CTRL			(0)
+#define OGMA_PHY_REG_ADDR_SR			(1)
+#define OGMA_PHY_REG_ADDR_ANA			(4)
+#define OGMA_PHY_REG_ADDR_ANLPA			(5)
+#define OGMA_PHY_REG_ADDR_MSC			(9)
+#define OGMA_PHY_REG_ADDR_1000BASE_SR		(10)
+
+static const u32 desc_ring_irq_status_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_STATUS,
+	OGMA_REG_NRM_RX_STATUS,
+	0,
+	0
+};
+
+static int ogma_netdev_set_macaddr(struct net_device *netdev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
+	return 0;
+}
+
+static void ogma_ring_irq_clr(struct ogma_priv *priv,
+			      unsigned int id, u32 value)
+{
+	BUG_ON(id > OGMA_RING_MAX);
+	BUG_ON(!priv->desc_ring[id].param.valid_flag);
+
+	ogma_write_reg(priv, desc_ring_irq_status_reg_addr[id],
+		       (value & (OGMA_IRQ_EMPTY | OGMA_IRQ_ERR)));
+}
+
+int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget)
+{
+	struct ogma_ndev *ndev = container_of(napi_p, struct ogma_ndev, napi);
+	struct net_device *net_device = ndev->net_device;
+	int ret, i = 0, tx_queue_status, rx_num;
+	struct ogma_rx_pkt_info rx_pkt_info;
+	struct ogma_frag_info frag;
+	struct sk_buff *skb;
+	u16 len;
+
+	for (i = 0, rx_num = 0; i < budget; i++, rx_num--) {
+		if (!rx_num) {
+			rx_num = ogma_get_rx_num(ndev->priv,
+						 OGMA_RING_NRM_RX);
+			if (!rx_num)
+				break;
+		}
+
+		ret = ogma_get_rx_pkt_data(ndev->priv, OGMA_RING_NRM_RX,
+					   &rx_pkt_info, &frag, &len, &skb);
+		if (ret == -ENOMEM) {
+			dev_err(ndev->priv->dev, "%s: rx fail %d",
+				__func__, ret);
+			net_device->stats.rx_dropped++;
+			continue;
+		}
+
+		dma_unmap_single(ndev->dev_p, frag.phys_addr, frag.len,
+				 DMA_FROM_DEVICE);
+
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, ndev->net_device);
+		skb->dev = ndev->net_device;
+
+		if (ndev->rx_cksum_offload_flag &&
+		    rx_pkt_info.rx_cksum_result == OGMA_RX_CKSUM_RESULT_OK)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		else
+			skb->ip_summed = CHECKSUM_NONE;
+
+		napi_gro_receive(napi_p, skb);
+
+		net_device->stats.rx_packets++;
+		net_device->stats.rx_bytes += len;
+	}
+
+	ogma_ring_irq_clr(ndev->priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+
+	ogma_clean_tx_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
+	spin_lock(&ndev->tx_queue_lock);
+	tx_queue_status = netif_queue_stopped(ndev->net_device);
+	spin_unlock(&ndev->tx_queue_lock);
+
+	if (tx_queue_status &&
+	    ogma_get_tx_avail_num(ndev->priv, OGMA_RING_NRM_TX) >=
+						OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX)
+		netif_wake_queue(ndev->net_device);
+
+	if (i == budget)
+		return budget;
+
+	napi_complete(napi_p);
+	ogma_write_reg(ndev->priv, OGMA_REG_TOP_INTEN_SET,
+		       OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
+
+	return i;
+}
+
+static void ogma_netdev_stop_sub(struct ogma_ndev *ndev, bool gmac_stop_flag)
+{
+	struct net_device *net_device = ndev->net_device;
+
+	pr_debug("%s\n", __func__);
+
+	if (ndev->phy_handler_kthread_p != NULL) {
+		kthread_stop(ndev->phy_handler_kthread_p);
+		ndev->phy_handler_kthread_p = NULL;
+	}
+
+	ndev->prev_link_status_flag = 0;
+	ndev->prev_auto_nego_complete_flag = 0;
+
+	netif_stop_queue(net_device);
+
+	if (gmac_stop_flag)
+		ogma_stop_gmac(ndev->priv, 1, 1);
+
+	ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
+	ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
+
+	napi_disable(&ndev->napi);
+}
+
+static int ogma_netdev_stop(struct net_device *net_device)
+{
+	struct ogma_ndev *ndev = netdev_priv(net_device);
+
+	ogma_netdev_stop_sub(ndev, 1);
+
+	pm_runtime_mark_last_busy(ndev->priv->dev);
+	pm_runtime_put_autosuspend(ndev->priv->dev);
+
+	return 0;
+}
+
+static netdev_tx_t ogma_netdev_start_xmit(struct sk_buff *skb,
+					  struct net_device *net_device)
+{
+	struct ogma_ndev *ndev = netdev_priv(net_device);
+	struct ogma_priv *priv = ndev->priv;
+	struct ogma_tx_pkt_ctrl tx_ctrl;
+	struct ogma_frag_info *scat;
+	u16 pend_tx, tso_seg_len;
+	skb_frag_t *frag;
+	u8 scat_num;
+	int ret, i;
+
+	memset(&tx_ctrl, 0, sizeof(struct ogma_tx_pkt_ctrl));
+
+	ogma_ring_irq_clr(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+
+	ogma_clean_tx_desc_ring(priv, OGMA_RING_NRM_TX);
+	BUG_ON(skb_shinfo(skb)->nr_frags >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX);
+	scat_num = skb_shinfo(skb)->nr_frags + 1;
+
+	scat = kzalloc(scat_num * sizeof(*scat), GFP_NOWAIT);
+	if (!scat)
+		return NETDEV_TX_BUSY;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ip_hdr(skb)->check = 0;
+		tx_ctrl.cksum_offload_flag = 1;
+	}
+
+	tso_seg_len = 0;
+
+	if (skb_is_gso(skb)) {
+		tso_seg_len = skb_shinfo(skb)->gso_size;
+
+		BUG_ON(skb->ip_summed != CHECKSUM_PARTIAL);
+		BUG_ON(!tso_seg_len);
+		BUG_ON(tso_seg_len > (priv->param.use_jumbo_pkt_flag ?
+			    OGMA_TCP_JUMBO_SEG_LEN_MAX : OGMA_TCP_SEG_LEN_MAX));
+
+		if (tso_seg_len < OGMA_TCP_SEG_LEN_MIN) {
+			tso_seg_len = OGMA_TCP_SEG_LEN_MIN;
+
+			if (skb->data_len < OGMA_TCP_SEG_LEN_MIN)
+				tso_seg_len = 0;
+		}
+	}
+
+	if (tso_seg_len > 0) {
+		if (skb->protocol == htons(ETH_P_IP)) {
+			BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4));
+
+			ip_hdr(skb)->tot_len = 0;
+			tcp_hdr(skb)->check =
+				~tcp_v4_check(0, ip_hdr(skb)->saddr,
+					      ip_hdr(skb)->daddr, 0);
+		} else {
+			BUG_ON(!(skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6));
+			ipv6_hdr(skb)->payload_len = 0;
+			tcp_hdr(skb)->check =
+				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						 &ipv6_hdr(skb)->daddr,
+						 0, IPPROTO_TCP, 0);
+		}
+
+		tx_ctrl.tcp_seg_offload_flag = 1;
+		tx_ctrl.tcp_seg_len = tso_seg_len;
+	}
+
+	scat[0].phys_addr = dma_map_single(ndev->dev_p, skb->data,
+					skb_headlen(skb), DMA_TO_DEVICE);
+	scat[0].addr = skb->data;
+	scat[0].len = skb_headlen(skb);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		scat[i + 1].phys_addr = skb_frag_dma_map(ndev->dev_p, frag, 0,
+				skb_frag_size(frag), DMA_TO_DEVICE);
+		scat[i + 1].addr = skb_frag_address(frag);
+		scat[i + 1].len = frag->size;
+	}
+
+	tx_ctrl.target_desc_ring_id = OGMA_RING_GMAC;
+	ogma_mark_skb_type(skb, OGMA_RING_NRM_TX);
+
+	ret = ogma_set_tx_pkt_data(priv, OGMA_RING_NRM_TX, &tx_ctrl, scat_num,
+				   scat, skb);
+
+	if (ret) {
+		dev_err(priv->dev, "set tx pkt failed %d.", ret);
+		for (i = 0; i < scat_num; i++)
+			dma_unmap_single(ndev->dev_p, scat[i].phys_addr,
+					 scat[i].len, DMA_TO_DEVICE);
+		kfree(scat);
+		net_device->stats.tx_dropped++;
+
+		return NETDEV_TX_BUSY;
+	}
+
+	kfree(scat);
+
+	net_device->stats.tx_packets++;
+	net_device->stats.tx_bytes += skb->len;
+
+	spin_lock(&ndev->tx_queue_lock);
+	pend_tx = ogma_get_tx_avail_num(ndev->priv, OGMA_RING_NRM_TX);
+
+	if (pend_tx < OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX) {
+		ogma_ring_irq_enable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+		netif_stop_queue(net_device);
+		goto err;
+	}
+	if (pend_tx <= ndev->tx_empty_irq_activation_threshold) {
+		ogma_ring_irq_enable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+		goto err;
+	}
+	ogma_ring_irq_disable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+
+err:
+	spin_unlock(&ndev->tx_queue_lock);
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *ogma_netdev_get_stats(struct net_device
+						      *net_device)
+{
+	return &net_device->stats;
+}
+
+static void ogma_ethtool_get_drvinfo(struct net_device *net_device,
+				     struct ethtool_drvinfo *drvinfo)
+{
+}
+
+static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
+{
+	struct ogma_ndev *ndev = netdev_priv(net_device);
+
+	if (!ndev->priv->param.use_jumbo_pkt_flag)
+		return eth_change_mtu(net_device, new_mtu);
+
+	if ((new_mtu < 68) || (new_mtu > 9000))
+		return -EINVAL;
+
+	net_device->mtu = new_mtu;
+
+	return 0;
+}
+
+static int ogma_netdev_set_features(struct net_device *net_device,
+				    netdev_features_t features)
+{
+	struct ogma_ndev *ndev = netdev_priv(net_device);
+
+	ndev->rx_cksum_offload_flag = !!(features & NETIF_F_RXCSUM);
+
+	return 0;
+}
+
+static void ogma_netdev_get_phy_link_status(struct ogma_ndev *ndev,
+					    unsigned int *link_status,
+					    unsigned int *autoneg_done,
+					    unsigned int *link_down,
+					    unsigned int *link_speed,
+					    unsigned int *half_duplex)
+{
+	struct ogma_priv *priv = ndev->priv;
+	u16 sr, u;
+
+	*link_down = 0;
+	*link_speed = OGMA_PHY_LINK_SPEED_10M;
+	*half_duplex = 0;
+
+	sr = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_SR);
+
+	if (!(sr & OGMA_PHY_SR_REG_LINK)) {
+		*link_down = 1;
+		sr = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_SR);
+	}
+
+	*link_status = !!(sr & OGMA_PHY_SR_REG_LINK);
+	*autoneg_done = !!(sr & OGMA_PHY_SR_REG_AN_C);
+
+	if (!*link_status || !*autoneg_done)
+		return;
+
+	if ((ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_MSC) &
+					OGMA_PHY_MSC_REG_1000BASE_FULL) &&
+			(ogma_get_phy_reg(priv, priv->phyads,
+					OGMA_PHY_REG_ADDR_1000BASE_SR) &
+						OGMA_PHY_1000BASE_REG_FULL)) {
+		*link_speed = OGMA_PHY_LINK_SPEED_1G;
+		return;
+	}
+
+	u = ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_ANA) &
+	    ogma_get_phy_reg(priv, priv->phyads, OGMA_PHY_REG_ADDR_ANLPA);
+
+	if (u & OGMA_PHY_ANLPA_REG_TXF) {
+		*link_speed = OGMA_PHY_LINK_SPEED_100M;
+		return;
+	}
+	if (u & OGMA_PHY_ANLPA_REG_TXD) {
+		*link_speed = OGMA_PHY_LINK_SPEED_100M;
+		*half_duplex = 1;
+		return;
+	}
+	if (u & OGMA_PHY_ANLPA_REG_TF) {
+		*link_speed = OGMA_PHY_LINK_SPEED_10M;
+		return;
+	}
+
+	*link_speed = OGMA_PHY_LINK_SPEED_10M;
+	*half_duplex = 1;
+}
+
+static int ogma_netdev_configure_mac(struct ogma_ndev *ndev,
+				     int link_speed, int half_duplex_flag)
+{
+	struct ogma_gmac_mode mode;
+	int ret;
+
+	memcpy(&mode, &ndev->priv->gmac_mode, sizeof(mode));
+
+	mode.link_speed = link_speed;
+	mode.half_duplex_flag = half_duplex_flag;
+
+	ret = ogma_stop_gmac(ndev->priv, true, true);
+	if (ret)
+		return ret;
+
+	ret = ogma_set_gmac_mode(ndev->priv, &mode);
+	if (ret)
+		return ret;
+
+	return ogma_start_gmac(ndev->priv, true, true);
+}
+
+static void net_device_phy_poll(struct ogma_ndev *ndev)
+{
+	unsigned int link_status_flag, auto_nego_complete_flag,
+		latched_link_down_flag, link_speed, half_duplex;
+	int ret;
+
+	if (!(ndev->net_device->flags & IFF_UP))
+		return;
+
+	ogma_netdev_get_phy_link_status(ndev, &link_status_flag,
+					&auto_nego_complete_flag,
+					&latched_link_down_flag,
+					&link_speed, &half_duplex);
+
+	if ((!latched_link_down_flag) &&
+	    (link_status_flag == ndev->prev_link_status_flag) &&
+	    (auto_nego_complete_flag == ndev->prev_auto_nego_complete_flag))
+		return;
+
+	/* Configure GMAC if link is up and auto negotiation is complete */
+	if (link_status_flag && auto_nego_complete_flag) {
+		ret = ogma_netdev_configure_mac(ndev, link_speed, half_duplex);
+		if (ret) {
+			dev_err(ndev->priv->dev, "%s: fail conf mac", __func__);
+			link_status_flag = 0;
+			auto_nego_complete_flag = 0;
+		}
+	}
+
+	if (ndev->prev_link_status_flag != link_status_flag) {
+		if (link_status_flag) {
+			netif_carrier_on(ndev->net_device);
+			netif_start_queue(ndev->net_device);
+		} else {
+			netif_stop_queue(ndev->net_device);
+			netif_carrier_off(ndev->net_device);
+		}
+	}
+
+	/* Update saved PHY status */
+	ndev->prev_link_status_flag = link_status_flag;
+	ndev->prev_auto_nego_complete_flag = auto_nego_complete_flag;
+}
+
+static int netdev_phy_handler(void *argp)
+{
+	struct ogma_ndev *ndev = (struct ogma_ndev *)argp;
+
+	while (!kthread_should_stop()) {
+		rtnl_lock();
+		net_device_phy_poll(ndev);
+		rtnl_unlock();
+		schedule_timeout_interruptible(500 * HZ / 1000);
+	}
+
+	return 0;
+}
+
+static int ogma_netdev_open_sub(struct ogma_ndev *ndev)
+{
+	struct ogma_priv *priv = ndev->priv;
+	int ret;
+
+	napi_enable(&ndev->napi);
+
+	ret = ogma_start_desc_ring(priv, OGMA_RING_NRM_RX);
+	if (ret) {
+		dev_err(priv->dev, "%s: start rx desc fail\n", __func__);
+		ret = -EINVAL;
+		goto disable_napi;
+	}
+
+	ret = ogma_set_irq_coalesce_param(priv, OGMA_RING_NRM_RX,
+					  ndev->rxint_pktcnt, 0,
+					  ndev->rxint_tmr_cnt_us);
+	if (ret) {
+		dev_err(priv->dev, "%s: set irq fail\n", __func__);
+		ret = -EINVAL;
+		goto stop_desc_ring_nrm_rx;
+	}
+
+	ret = ogma_start_desc_ring(priv, OGMA_RING_NRM_TX);
+	if (ret) {
+		dev_err(priv->dev, "%s: start tx desc fail\n", __func__);
+		ret = -EINVAL;
+		goto stop_desc_ring_nrm_rx;
+	}
+
+	/* We adaptively control tx_empty IRQ */
+	ogma_ring_irq_disable(priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+
+	ndev->phy_handler_kthread_p = kthread_run(netdev_phy_handler,
+					(void *)ndev, "netdev_phy_handler");
+	if (IS_ERR(ndev->phy_handler_kthread_p)) {
+		ret = PTR_ERR(ndev->phy_handler_kthread_p);
+		ndev->phy_handler_kthread_p = NULL;
+		goto stop_queue;
+	}
+
+	return 0;
+
+stop_queue:
+
+	ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
+
+stop_desc_ring_nrm_rx:
+	ogma_stop_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
+
+disable_napi:
+	napi_disable(&ndev->napi);
+
+	return ret;
+}
+
+static int ogma_netdev_open(struct net_device *net_device)
+{
+	struct ogma_ndev *ndev = netdev_priv(net_device);
+	int ret;
+
+	pr_debug("%s\n", __func__);
+	pm_runtime_get_sync(ndev->priv->dev);
+
+	ret = ogma_clean_rx_desc_ring(ndev->priv, OGMA_RING_NRM_RX);
+	if (ret) {
+		dev_err(ndev->priv->dev, "%s: clean rx desc fail\n", __func__);
+		goto err;
+	}
+
+	ret = ogma_clean_tx_desc_ring(ndev->priv, OGMA_RING_NRM_TX);
+	if (ret) {
+		dev_err(ndev->priv->dev, "%s: clean tx desc fail\n", __func__);
+		goto err;
+	}
+
+	ogma_ring_irq_clr(ndev->priv, OGMA_RING_NRM_TX, OGMA_IRQ_EMPTY);
+
+	ret = ogma_netdev_open_sub(ndev);
+	if (ret) {
+		dev_err(ndev->priv->dev, "ogma_netdev_open_sub() failed\n");
+		goto err;
+	}
+
+	return ret;
+
+err:
+	pm_runtime_put_sync(ndev->priv->dev);
+
+	return ret;
+}
+
+const struct net_device_ops ogma_netdev_ops = {
+	.ndo_open		= ogma_netdev_open,
+	.ndo_stop		= ogma_netdev_stop,
+	.ndo_start_xmit		= ogma_netdev_start_xmit,
+	.ndo_set_features	= ogma_netdev_set_features,
+	.ndo_get_stats		= ogma_netdev_get_stats,
+	.ndo_change_mtu		= ogma_netdev_change_mtu,
+	.ndo_set_mac_address	= ogma_netdev_set_macaddr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
+const struct ethtool_ops ogma_ethtool_ops = {
+	.get_drvinfo		= ogma_ethtool_get_drvinfo,
+};
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
new file mode 100755
index 0000000..dd5ebf3
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
@@ -0,0 +1,729 @@
+/**
+ * ogma_driver.c
+ *
+ *  Copyright (C) 2013-2014 Fujitsu Semiconductor Limited.
+ *  Copyright (C) 2014 Linaro Ltd  Andy Green <andy.green@linaro.org>
+ *  All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version 2
+ *  of the License, or (at your option) any later version.
+ */
+
+#include <linux/version.h>
+#include <linux/moduleparam.h>
+#include <linux/device.h>
+#include <linux/string.h>
+#include <linux/random.h>
+#include <linux/pci.h>
+#include <linux/ctype.h>
+#include <linux/netdevice.h>
+#include <linux/types.h>
+#include <linux/bitops.h>
+#include <linux/dma-mapping.h>
+#include <linux/module.h>
+#include <linux/sizes.h>
+#include <linux/platform_device.h>
+#include <linux/clk.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/io.h>
+#include <linux/pm_runtime.h>
+#include <linux/kthread.h>
+
+#include "ogma.h"
+
+#define OGMA_F_NETSEC_VER_MAJOR_NUM(x) (x & 0xffff0000)
+
+static const u32 desc_ads[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_CONFIG,
+	OGMA_REG_NRM_RX_CONFIG,
+	0,
+	0
+};
+
+static const u32 ogma_desc_start_reg_addr[OGMA_RING_MAX + 1] = {
+	OGMA_REG_NRM_TX_DESC_START,
+	OGMA_REG_NRM_RX_DESC_START,
+	OGMA_REG_RESERVED_RX_DESC_START,
+	OGMA_REG_RESERVED_TX_DESC_START
+};
+
+static unsigned short tx_desc_num = 128;
+static unsigned short rx_desc_num = 128;
+static int napi_weight = 64;
+unsigned short pause_time = 256;
+
+#define WAIT_FW_RDY_TIMEOUT 50
+
+static u32 ogma_calc_pkt_ctrl_reg_param(const struct ogma_pkt_ctrlaram
+					*pkt_ctrlaram_p)
+{
+	u32 param = OGMA_PKT_CTRL_REG_MODE_NRM;
+
+	if (pkt_ctrlaram_p->log_chksum_er_flag)
+		param |= OGMA_PKT_CTRL_REG_LOG_CHKSUM_ER;
+
+	if (pkt_ctrlaram_p->log_hd_imcomplete_flag)
+		param |= OGMA_PKT_CTRL_REG_LOG_HD_INCOMPLETE;
+
+	if (pkt_ctrlaram_p->log_hd_er_flag)
+		param |= OGMA_PKT_CTRL_REG_LOG_HD_ER;
+
+	return param;
+}
+
+int ogma_configure_normal_mode(struct ogma_priv *priv,
+			       const struct ogma_normal
+			       *normal_p)
+{
+	int ret = 0;
+	int timeout;
+	u32 value;
+
+	if (!priv || !normal_p)
+		return -EINVAL;
+
+	memcpy((void *)&priv->normal,
+	       (const void *)normal_p,
+	       sizeof(struct ogma_normal));
+
+	/* save scb set value  */
+	priv->scb_set_normal_tx_phys_addr = ogma_read_reg(priv,
+			ogma_desc_start_reg_addr[OGMA_RING_NRM_TX]);
+
+	/* set desc_start addr */
+	ogma_write_reg(priv,
+		       ogma_desc_start_reg_addr[OGMA_RING_NRM_RX],
+		       priv->desc_ring[OGMA_RING_NRM_RX].deschys_addr);
+
+	ogma_write_reg(priv,
+		       ogma_desc_start_reg_addr[OGMA_RING_NRM_TX],
+		       priv->desc_ring[OGMA_RING_NRM_TX].deschys_addr);
+
+	/* set normal tx desc ring config */
+	value = priv->normal.tx_tmr_mode_flag << OGMA_REG_DESC_TMR_MODE |
+		priv->normal.tx_little_endian_flag << OGMA_REG_DESC_ENDIAN |
+		1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+	ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_TX], value);
+
+	value = priv->normal.rx_tmr_mode_flag << OGMA_REG_DESC_TMR_MODE |
+		priv->normal.rx_little_endian_flag << OGMA_REG_DESC_ENDIAN |
+		1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+	ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_RX], value);
+
+	timeout = WAIT_FW_RDY_TIMEOUT;
+	while (timeout-- && (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_TX]) &
+				       (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
+		usleep_range(1000, 2000);
+
+	if (timeout < 0)
+		return -ETIME;
+
+	timeout = WAIT_FW_RDY_TIMEOUT;
+	while (timeout-- && (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_RX]) &
+				       (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
+		usleep_range(1000, 2000);
+
+	if (timeout < 0)
+		return -ETIME;
+
+	priv->normal_desc_ring_valid = 1;
+
+	return ret;
+}
+
+int ogma_change_mode_to_normal(struct ogma_priv *priv)
+{
+	int ret = 0;
+	u32 value;
+
+	if (!priv->normal_desc_ring_valid)
+		return -EINVAL;
+
+	priv->scb_pkt_ctrl_reg = ogma_read_reg(priv, OGMA_REG_PKT_CTRL);
+
+	value = ogma_calc_pkt_ctrl_reg_param(&priv->normal. pkt_ctrlaram);
+
+	if (priv->normal.use_jumbo_pkt_flag)
+		value |= OGMA_PKT_CTRL_REG_EN_JUMBO;
+
+	value |= OGMA_PKT_CTRL_REG_MODE_NRM;
+
+	/* change to normal mode */
+	ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL,
+		       OGMA_DMA_MH_CTRL_REG_MODE_TRANS);
+
+	ogma_write_reg(priv, OGMA_REG_PKT_CTRL, value);
+
+	priv->normal_desc_ring_valid = 0;
+
+	return ret;
+}
+
+int ogma_change_mode_to_taiki(struct ogma_priv *priv)
+{
+	int ret = 0;
+	u32 value;
+
+	ogma_write_reg(priv, ogma_desc_start_reg_addr[OGMA_RING_NRM_TX],
+		       priv->scb_set_normal_tx_phys_addr);
+
+	value = 1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+
+	ogma_write_reg(priv, desc_ads[OGMA_RING_NRM_TX], value);
+
+	while (ogma_read_reg(priv, desc_ads[OGMA_RING_NRM_TX]) &
+					(1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP))
+		;
+
+	ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL,
+		       OGMA_DMA_MH_CTRL_REG_MODE_TRANS);
+
+	ogma_write_reg(priv, OGMA_REG_PKT_CTRL, priv->scb_pkt_ctrl_reg);
+
+	return ret;
+}
+
+int ogma_clear_modechange_irq(struct ogma_priv *priv, u32 value)
+{
+	ogma_write_reg(priv, OGMA_REG_MODE_TRANS_COMP_STATUS,
+		       (value & (OGMA_MODE_TRANS_COMP_IRQ_N2T |
+				 OGMA_MODE_TRANS_COMP_IRQ_T2N)));
+
+	return 0;
+}
+
+static int ogma_hw_configure_to_normal(struct ogma_priv *priv)
+{
+	struct ogma_normal normal = { 0 };
+	int err;
+
+	normal.use_jumbo_pkt_flag = true;
+
+	/* set descriptor endianess according to CPU endianess */
+	normal.tx_little_endian_flag = cpu_to_le32(1) == 1;
+	normal.rx_little_endian_flag = cpu_to_le32(1) == 1;
+
+	err = ogma_configure_normal_mode(priv, &normal);
+	if (err) {
+		dev_err(priv->dev, "%s: normal conf fail\n", __func__);
+		return err;
+	}
+	err = ogma_change_mode_to_normal(priv);
+	if (err) {
+		dev_err(priv->dev, "%s: normal set fail\n", __func__);
+		return err;
+	}
+	/* Wait Change mode Complete */
+	usleep_range(2000, 10000);
+
+	return err;
+}
+
+static int ogma_hw_configure_to_taiki(struct ogma_priv *priv)
+{
+	int ret;
+
+	ret = ogma_change_mode_to_taiki(priv);
+	if (ret) {
+		dev_err(priv->dev, "%s: taiki set fail\n", __func__);
+		return ret;
+	}
+
+	/* Wait Change mode to Taiki Complete */
+	usleep_range(2000, 10000);
+
+	/* Clear mode change complete IRQ */
+	ret = ogma_clear_modechange_irq(priv, OGMA_MODE_TRANS_COMP_IRQ_T2N |
+					OGMA_MODE_TRANS_COMP_IRQ_N2T);
+
+	if (ret)
+		dev_err(priv->dev, "%s: clear mode fail\n", __func__);
+
+	return ret;
+}
+
+static irqreturn_t ogma_irq_handler(int irq, void *dev_id)
+{
+	struct ogma_priv *priv = dev_id;
+	struct ogma_ndev *ndev = netdev_priv(priv->net_device);
+	u32 status;
+
+	dev_dbg(priv->dev, "%s\n", __func__);
+
+	status = ogma_read_reg(ndev->priv, OGMA_REG_TOP_STATUS) &
+			ogma_read_reg(ndev->priv, OGMA_REG_TOP_INTEN);
+
+	if (!status)
+		return IRQ_NONE;
+
+	if ((status & (OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX))) {
+		ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR,
+			       OGMA_TOP_IRQ_REG_NRM_TX |
+			       OGMA_TOP_IRQ_REG_NRM_RX);
+		napi_schedule(&ndev->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+static void ogma_terminate(struct ogma_priv *priv)
+{
+	int i;
+
+	for (i = 0; i <= OGMA_RING_MAX; i++)
+		ogma_free_desc_ring(priv, &priv->desc_ring[i]);
+
+	if (priv->dummy_virt)
+		dma_free_coherent(priv->dev, OGMA_DUMMY_DESC_ENTRY_LEN,
+				  priv->dummy_virt, priv->dummy_phys);
+
+	/* Set initial value */
+	ogma_write_reg(priv, OGMA_REG_CLK_EN, 0);
+}
+
+static int ogma_probe(struct platform_device *pdev)
+{
+	struct device_node *phy_np;
+	struct ogma_priv *priv;
+	struct ogma_ndev *ndev;
+	struct resource *res;
+	u32 scb_irq_temp;
+	const char *cp;
+	const u32 *p;
+	u32 hw_ver;
+	int err, i;
+	int ret;
+	int len;
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	platform_set_drvdata(pdev, priv);
+
+	priv->dev = &pdev->dev;
+	priv->clock_count = 0;
+
+	p = of_get_property(pdev->dev.of_node, "local-mac-address", &len);
+	if (!p || len != (ETH_ALEN * sizeof(int))) {
+		dev_err(&pdev->dev, "Missing Mac Address\n");
+		goto err1;
+	}
+	for (i = 0; i < ETH_ALEN; i++)
+		priv->mac[i] = be32_to_cpu(p[i]);
+
+	priv->param.desc_param[OGMA_RING_NRM_TX].little_endian_flag = 1;
+	priv->param.desc_param[OGMA_RING_NRM_TX].valid_flag = 1;
+	priv->param.desc_param[OGMA_RING_NRM_TX].entries = tx_desc_num;
+
+	priv->param.desc_param[OGMA_RING_NRM_RX].little_endian_flag = 1;
+	priv->param.desc_param[OGMA_RING_NRM_RX].valid_flag = 1;
+	priv->param.desc_param[OGMA_RING_NRM_RX].entries = rx_desc_num;
+
+	priv->param.gmac_config.phy_if = OGMA_PHY_IF_RGMII;
+	cp = of_get_property(pdev->dev.of_node, "phy-mode", NULL);
+	if (cp) {
+		if (!strcmp(cp, "gmii")) {
+			priv->param.gmac_config.phy_if = OGMA_PHY_IF_GMII;
+		} else if (!strcmp(cp, "rgmii")) {
+			priv->param.gmac_config.phy_if = OGMA_PHY_IF_RGMII;
+		} else if (!strcmp(cp, "rmii")) {
+			priv->param.gmac_config.phy_if = OGMA_PHY_IF_RMII;
+		} else {
+			dev_err(&pdev->dev, "%s: bad phy-if\n", __func__);
+			goto err1;
+		}
+	}
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "Missing base resource\n");
+		goto err1;
+	}
+
+	priv->ioaddr = ioremap_nocache(res->start,
+						res->end - res->start + 1);
+	if (!priv->ioaddr) {
+		dev_err(&pdev->dev, "ioremap_nocache() failed\n");
+		err = -EINVAL;
+		goto err1;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(&pdev->dev, "Missing rdlar resource\n");
+		goto err1;
+	}
+	priv->rdlar_pa = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (!res) {
+		dev_err(&pdev->dev, "Missing tdlar resource\n");
+		goto err1;
+	}
+	priv->tdlar_pa = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "Missing IRQ resource\n");
+		goto err2;
+	}
+	priv->irq = res->start;
+	err = request_irq(priv->irq, ogma_irq_handler,
+			  IRQF_SHARED, "ogma", priv);
+	if (err) {
+		dev_err(&pdev->dev, "request_irq() failed\n");
+		goto err2;
+	}
+	disable_irq(priv->irq);
+
+	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
+
+	while (priv->clock_count < ARRAY_SIZE(priv->clk)) {
+		priv->clk[priv->clock_count] =
+			of_clk_get(pdev->dev.of_node, priv->clock_count);
+		if (IS_ERR(priv->clk[priv->clock_count])) {
+			if (!priv->clock_count) {
+				dev_err(&pdev->dev, "Failed to get clock\n");
+				goto err3;
+			}
+			break;
+		}
+		priv->clock_count++;
+	}
+
+	pm_runtime_set_autosuspend_delay(&pdev->dev, 2000); /* 2s delay */
+	pm_runtime_use_autosuspend(&pdev->dev);
+	pm_runtime_enable(&pdev->dev);
+
+	/* runtime_pm coverage just for probe, enable/disable also cover it */
+	pm_runtime_get_sync(&pdev->dev);
+
+	priv->param.use_jumbo_pkt_flag = 0;
+	p = of_get_property(pdev->dev.of_node, "max-frame-size", NULL);
+	if (p)
+		priv->param.use_jumbo_pkt_flag = !!(be32_to_cpu(*p) > 8000);
+
+	priv->dummy_virt = dma_alloc_coherent(NULL, OGMA_DUMMY_DESC_ENTRY_LEN,
+						 &priv->dummy_phys, GFP_KERNEL);
+	if (!priv->dummy_virt) {
+		ret = -ENOMEM;
+		dev_err(priv->dev, "%s: failed to alloc\n", __func__);
+		goto err3;
+	}
+
+	memset(priv->dummy_virt, 0, OGMA_DUMMY_DESC_ENTRY_LEN);
+
+	hw_ver = ogma_read_reg(priv, OGMA_REG_F_TAIKI_VER);
+
+	if (OGMA_F_NETSEC_VER_MAJOR_NUM(hw_ver) !=
+	    OGMA_F_NETSEC_VER_MAJOR_NUM(OGMA_REG_OGMA_VER_F_TAIKI)) {
+		ret = -ENODEV;
+		goto err3b;
+	}
+
+	if (priv->param.use_jumbo_pkt_flag)
+		priv->rx_pkt_buf_len = OGMA_RX_JUMBO_PKT_BUF_LEN;
+	else
+		priv->rx_pkt_buf_len = OGMA_RX_PKT_BUF_LEN;
+
+	for (i = 0; i <= OGMA_RING_MAX; i++) {
+		ret = ogma_alloc_desc_ring(priv, (u8) i);
+		if (ret) {
+			dev_err(priv->dev, "%s: alloc ring failed\n", __func__);
+			goto err3b;
+		}
+	}
+
+	if (priv->param.desc_param[OGMA_RING_NRM_RX].valid_flag) {
+		ret = ogma_setup_rx_desc(priv,
+					 &priv->desc_ring[OGMA_RING_NRM_RX]);
+		if (ret) {
+			dev_err(priv->dev, "%s: fail setup ring\n", __func__);
+			goto err3b;
+		}
+	}
+
+	priv->core_enabled_flag = 1;
+
+	dev_info(&pdev->dev, "IP version: 0x%08x\n", hw_ver);
+
+	priv->gmac_mode.flow_start_th = OGMA_FLOW_CONTROL_START_THRESHOLD;
+	priv->gmac_mode.flow_stop_th = OGMA_FLOW_CONTROL_STOP_THRESHOLD;
+	priv->gmac_mode.pause_time = pause_time;
+	priv->gmac_hz = clk_get_rate(priv->clk[0]);
+
+	priv->gmac_mode.half_duplex_flag = 0;
+	priv->gmac_mode.flow_ctrl_enable_flag = 0;
+
+	phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	if (!phy_np) {
+		dev_err(&pdev->dev, "missing phy in DT\n");
+		goto err3b;
+	}
+
+	p = of_get_property(phy_np, "reg", NULL);
+	if (p) {
+		priv->phyads = be32_to_cpu(*p);
+	} else {
+		dev_err(&pdev->dev, "Missing phy address in DT\n");
+		goto err3b;
+	}
+
+	priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_1G;
+	p = of_get_property(pdev->dev.of_node, "max-speed", NULL);
+	if (p) {
+		switch (be32_to_cpu(*p)) {
+		case 1000:
+			priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_1G;
+			break;
+		case 100:
+			priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_100M;
+			break;
+		case 10:
+			priv->gmac_mode.link_speed = OGMA_PHY_LINK_SPEED_10M;
+			break;
+		default:
+			dev_err(&pdev->dev,
+				"link-speed should be 1000, 100 or 10\n");
+			goto err4;
+		}
+	}
+	scb_irq_temp = ogma_read_reg(priv, OGMA_REG_TOP_INTEN);
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR, scb_irq_temp);
+
+	ret = ogma_hw_configure_to_normal(priv);
+	if (ret) {
+		dev_err(&pdev->dev, "%s: normal cfg fail %d", __func__, ret);
+		goto err3b;
+	}
+
+	priv->net_device = alloc_netdev(sizeof(*ndev), "eth%d", ether_setup);
+	if (!priv->net_device)
+		goto err3b;
+
+	ndev = netdev_priv(priv->net_device);
+	ndev->dev_p = &pdev->dev;
+	ndev->phy_handler_kthread_p = NULL;
+	SET_NETDEV_DEV(priv->net_device, &pdev->dev);
+
+	memcpy(priv->net_device->dev_addr, priv->mac, 6);
+
+	netif_napi_add(priv->net_device, &ndev->napi, ogma_netdev_napi_poll,
+		       napi_weight);
+
+	priv->net_device->netdev_ops = &ogma_netdev_ops;
+	priv->net_device->ethtool_ops = &ogma_ethtool_ops;
+	priv->net_device->features = NETIF_F_SG | NETIF_F_IP_CSUM |
+				     NETIF_F_IPV6_CSUM | NETIF_F_TSO |
+				     NETIF_F_TSO6 | NETIF_F_GSO |
+				     NETIF_F_HIGHDMA | NETIF_F_RXCSUM;
+	priv->net_device->hw_features = priv->net_device->features;
+
+	ndev->priv = priv;
+	ndev->net_device = priv->net_device;
+	ndev->rx_cksum_offload_flag = 1;
+	spin_lock_init(&ndev->tx_queue_lock);
+	ndev->tx_desc_num = tx_desc_num;
+	ndev->rx_desc_num = rx_desc_num;
+	ndev->rxint_tmr_cnt_us = 0;
+	ndev->rxint_pktcnt = 1;
+	ndev->tx_empty_irq_activation_threshold = tx_desc_num - 2;
+	ndev->prev_link_status_flag = 0;
+	ndev->prev_auto_nego_complete_flag = 0;
+
+	err = register_netdev(priv->net_device);
+	if (err) {
+		dev_err(priv->dev, "register_netdev() failed");
+		goto err3c;
+	}
+
+	if (err) {
+		dev_err(&pdev->dev, "ogma_netdev_init() failed\n");
+		ogma_terminate(priv);
+		goto err4;
+	}
+	priv->net_device->irq = priv->irq;
+
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET, OGMA_TOP_IRQ_REG_NRM_TX |
+						     OGMA_TOP_IRQ_REG_NRM_RX);
+
+	dev_info(&pdev->dev, "%s initialized\n", priv->net_device->name);
+
+	pm_runtime_mark_last_busy(&pdev->dev);
+	pm_runtime_put_autosuspend(&pdev->dev);
+
+	return 0;
+
+err4:
+	ogma_hw_configure_to_taiki(priv);
+	unregister_netdev(priv->net_device);
+err3c:
+	free_netdev(priv->net_device);
+err3b:
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET, scb_irq_temp);
+	ogma_terminate(priv);
+err3:
+	pm_runtime_put_sync_suspend(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+	while (priv->clock_count > 0) {
+		priv->clock_count--;
+		clk_put(priv->clk[priv->clock_count]);
+	}
+
+	free_irq(priv->irq, priv);
+err2:
+	iounmap(priv->ioaddr);
+err1:
+	kfree(priv);
+
+	dev_err(&pdev->dev, "init failed\n");
+
+	return ret;
+}
+
+static int ogma_remove(struct platform_device *pdev)
+{
+	struct ogma_priv *priv = platform_get_drvdata(pdev);
+	struct ogma_ndev *ndev = netdev_priv(priv->net_device);
+
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR,
+		       OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
+	BUG_ON(ogma_hw_configure_to_taiki(priv));
+
+	pm_runtime_put_sync_suspend(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+	free_irq(priv->irq, priv);
+
+	if (ndev->phy_handler_kthread_p) {
+		kthread_stop(ndev->phy_handler_kthread_p);
+		ndev->phy_handler_kthread_p = NULL;
+	}
+
+	unregister_netdev(priv->net_device);
+
+	ogma_set_phy_reg(priv, priv->phyads, 0,
+			 ogma_get_phy_reg(priv, priv->phyads, 0) | (1 << 15));
+	while ((ogma_get_phy_reg(priv, priv->phyads, 0)) & (1 << 15))
+		;
+
+	free_netdev(priv->net_device);
+
+	ogma_terminate(priv);
+	iounmap(priv->ioaddr);
+	kfree(priv);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+#ifdef CONFIG_PM_RUNTIME
+static int ogma_runtime_suspend(struct device *dev)
+{
+	struct ogma_priv *priv = dev_get_drvdata(dev);
+	int n;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	disable_irq(priv->irq);
+
+	ogma_write_reg(priv, OGMA_REG_CLK_EN, 0);
+
+	for (n = priv->clock_count - 1; n >= 0; n--)
+		clk_disable_unprepare(priv->clk[n]);
+
+	return 0;
+}
+
+static int ogma_runtime_resume(struct device *dev)
+{
+	struct ogma_priv *priv = dev_get_drvdata(dev);
+	int n;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	/* first let the clocks back on */
+
+	for (n = 0; n < priv->clock_count; n++)
+		clk_prepare_enable(priv->clk[n]);
+
+	ogma_write_reg(priv, OGMA_REG_CLK_EN, OGMA_CLK_EN_REG_DOM_D |
+			OGMA_CLK_EN_REG_DOM_C | OGMA_CLK_EN_REG_DOM_G);
+
+	enable_irq(priv->irq);
+
+	return 0;
+}
+#endif
+
+static int ogma_pm_suspend(struct device *dev)
+{
+	dev_dbg(dev, "%s\n", __func__);
+
+	if (pm_runtime_status_suspended(dev))
+		return 0;
+
+	return ogma_runtime_suspend(dev);
+}
+
+static int ogma_pm_resume(struct device *dev)
+{
+	dev_dbg(dev, "%s\n", __func__);
+
+	if (pm_runtime_status_suspended(dev))
+		return 0;
+
+	return ogma_runtime_resume(dev);
+}
+#endif
+
+#ifdef CONFIG_PM
+static const struct dev_pm_ops ogma_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(ogma_pm_suspend, ogma_pm_resume)
+	SET_RUNTIME_PM_OPS(ogma_runtime_suspend, ogma_runtime_resume, NULL)
+};
+#endif
+
+static const struct of_device_id ogma_dt_ids[] = {
+	{.compatible = "fujitsu,ogma"},
+	{ /* sentinel */ }
+};
+
+MODULE_DEVICE_TABLE(of, ogma_dt_ids);
+
+static struct platform_driver ogma_driver = {
+	.probe = ogma_probe,
+	.remove = ogma_remove,
+	.driver = {
+		.name = "ogma",
+		.of_match_table = ogma_dt_ids,
+#ifdef CONFIG_PM
+		.pm = &ogma_pm_ops,
+#endif
+		},
+};
+
+static int __init ogma_module_init(void)
+{
+	return platform_driver_register(&ogma_driver);
+}
+
+static void __exit ogma_module_exit(void)
+{
+	platform_driver_unregister(&ogma_driver);
+}
+
+module_init(ogma_module_init);
+module_exit(ogma_module_exit);
+
+MODULE_AUTHOR("Fujitsu Semiconductor Ltd");
+MODULE_DESCRIPTION("OGMA Ethernet driver");
+MODULE_LICENSE("GPL");
+
+MODULE_ALIAS("platform:ogma");
