From: Andy Green <andy.green@linaro.org>
Subject: [net-next PATCH v3] net: ethernet driver: Fujitsu OGMA
Date: Sun, 15 Jun 2014 12:21:09 +0800
Message-ID: <20140615042109.30580.8558.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Florian Fainelli <f.fainelli@gmail.com>, patches@linaro.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34067 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaFOEVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 00:21:19 -0400
Received: by mail-pd0-f176.google.com with SMTP id p10so3312300pdj.35
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2014 21:21:18 -0700 (PDT)
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

There is only one checkpatch complaint, both about documentation for the
DT vendor missing.  But we will document vendor "fujitsu" in the main mach
support patches.  Bindings documentation is added by this patch.

The patch is based on net-next f9da455b93f6ba076935 from today, and the unchanged
patch has been tested on real hardware on an integration tree based on
pre-3.16-rc1 from a couple of days ago.

Allmodconfig doesn't generate any warnings (although on current net-next build
is broken by a staging driver).

Any comments about how to further improve and align it with current best-
practice for upstream Ethernet drivers are appreciated.

Changes since v2:

 - Followed comments from Florian Fainelli and Joe Perches
 - Use Phylib
 - Register as mii device
 - Fill out ethtool info
 - Use ethtool coalesce control struct
 - use netdev-related log apis
 - Many other cleanups and normalizations

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
 .../devicetree/bindings/net/fujitsu-ogma.txt       |   43 +
 drivers/net/ethernet/fujitsu/Kconfig               |   12 
 drivers/net/ethernet/fujitsu/Makefile              |    1 
 drivers/net/ethernet/fujitsu/ogma/Makefile         |    6 
 drivers/net/ethernet/fujitsu/ogma/ogma.h           |  387 ++++++++++++
 .../ethernet/fujitsu/ogma/ogma_desc_ring_access.c  |  641 ++++++++++++++++++++
 drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c   |   98 +++
 .../net/ethernet/fujitsu/ogma/ogma_gmac_access.c   |  244 ++++++++
 drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c    |  469 +++++++++++++++
 drivers/net/ethernet/fujitsu/ogma/ogma_platform.c  |  626 ++++++++++++++++++++
 10 files changed, 2527 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/fujitsu-ogma.txt
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/Makefile
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma.h
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
 create mode 100644 drivers/net/ethernet/fujitsu/ogma/ogma_platform.c

diff --git a/Documentation/devicetree/bindings/net/fujitsu-ogma.txt b/Documentation/devicetree/bindings/net/fujitsu-ogma.txt
new file mode 100644
index 0000000..1fd680f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/fujitsu-ogma.txt
@@ -0,0 +1,43 @@
+* Fujistu OGMA Ethernet Controller IP
+
+Required properties:
+- compatible: Should be "fujitsu,ogma"
+- reg: Address and length of the register sets, the first is the main
+	registers, then the rdlar and tdlar regions for the SoC
+- interrupts: Should contain ethernet controller interrupt
+- clocks: phandle to any clocks to be switched by runtime_pm
+- phy-mode: See ethernet.txt file in the same directory
+- max-speed: See ethernet.txt file in the same directory
+- max-frame-size: See ethernet.txt file in the same directory, if 9000 or
+	above jumbo frames are enabled
+- local-mac-address: See ethernet.txt file in the same directory
+- phy-handle: phandle to select child phy
+
+For the child phy
+
+- compatible "ethernet-phy-ieee802.3-c22" is needed
+- device_type "ethernet-phy"
+- reg: phy address
+
+
+Example:
+	eth0: f_taiki {
+                compatible = "fujitsu,ogma";
+		reg = <0 0x31600000 0x10000>, <0 0x31618000 0x4000>, <0 0x3161c000 0x4000>;
+		interrupts = <0 163 0x4>;
+		clocks = <&clk_alw_0_8>;
+		phy-mode = "rgmii";
+		max-speed = <1000>;
+		max-frame-size = <9000>;
+		local-mac-address = [ a4 17 31 00 00 ed ];
+		phy-handle = <&ethphy0>;
+
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy0: ethernet-phy@1 {
+			device_type = "ethernet-phy";
+			compatible = "ethernet-phy-ieee802.3-c22";
+			reg = <1>;
+		};
+	};
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index 1085257..bbe3ee8 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -28,4 +28,16 @@ config PCMCIA_FMVJ18X
 	  To compile this driver as a module, choose M here: the module will be
 	  called fmvj18x_cs.  If unsure, say N.
 
+config NET_FUJITSU_OGMA
+	tristate "Fujitsu OGMA network support"
+	depends on OF
+	select PHYLIB
+	select MII
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
new file mode 100644
index 0000000..8661027
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/Makefile
@@ -0,0 +1,6 @@
+obj-m := ogma.o
+ogma-objs := ogma_desc_ring_access.o \
+		ogma_netdev.o \
+		ogma_ethtool.o \
+		ogma_platform.o \
+		ogma_gmac_access.o
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma.h b/drivers/net/ethernet/fujitsu/ogma/ogma.h
new file mode 100644
index 0000000..b0a07cb
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma.h
@@ -0,0 +1,387 @@
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
+#include <linux/phy.h>
+#include <linux/ethtool.h>
+#include <linux/of_address.h>
+#include <linux/of_mdio.h>
+#include <net/sock.h>
+
+#define OGMA_FLOW_CONTROL_START_THRESHOLD	36
+#define OGMA_FLOW_CONTROL_STOP_THRESHOLD	48
+
+#define OGMA_CLK_MHZ				1000000
+
+#define OGMA_RX_PKT_BUF_LEN			1522
+#define OGMA_RX_JUMBO_PKT_BUF_LEN		9022
+
+#define OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX		19
+
+#define DESC_NUM 128
+
+#define OGMA_TX_SHIFT_OWN_FIELD			31
+#define OGMA_TX_SHIFT_LD_FIELD			30
+#define OGMA_TX_SHIFT_DRID_FIELD		24
+#define OGMA_TX_SHIFT_PT_FIELD			21
+#define OGMA_TX_SHIFT_TDRID_FIELD		16
+#define OGMA_TX_SHIFT_CC_FIELD			15
+#define OGMA_TX_SHIFT_FS_FIELD			9
+#define OGMA_TX_LAST				8
+#define OGMA_TX_SHIFT_CO			7
+#define OGMA_TX_SHIFT_SO			6
+#define OGMA_TX_SHIFT_TRS_FIELD			4
+#define OGMA_RX_PKT_OWN_FIELD			31
+#define OGMA_RX_PKT_LD_FIELD			30
+#define OGMA_RX_PKT_SDRID_FIELD			24
+#define OGMA_RX_PKT_FR_FIELD			23
+#define OGMA_RX_PKT_ER_FIELD			21
+#define OGMA_RX_PKT_ERR_FIELD			16
+#define OGMA_RX_PKT_TDRID_FIELD			12
+#define OGMA_RX_PKT_FS_FIELD			9
+#define OGMA_RX_PKT_LS_FIELD			8
+#define OGMA_RX_PKT_CO_FIELD			6
+
+#define OGMA_RX_PKT_ERR_MASK			3
+
+#define OGMA_MAX_TX_PKT_LEN			1518
+#define OGMA_MAX_TX_JUMBO_PKT_LEN		9018
+
+#define OGMA_RING_TX				0
+#define OGMA_RING_RX				1
+
+#define OGMA_RING_GMAC				15
+#define OGMA_RING_MAX				1
+
+#define OGMA_TCP_SEG_LEN_MAX			1460
+#define OGMA_TCP_JUMBO_SEG_LEN_MAX		8960
+#define OGMA_TCP_SEG_LEN_MIN			536
+
+#define OGMA_RX_CKSUM_NOTAVAIL			0
+#define OGMA_RX_CKSUM_OK			1
+#define OGMA_RX_CKSUM_NG			2
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
+#define OGMA_FLOW_START_TH_MAX			383
+#define OGMA_FLOW_STOP_TH_MAX			383
+#define OGMA_FLOW_PAUSE_TIME_MIN		5
+
+#define OGMA_CLK_EN_REG_DOM_ALL			0x3f
+
+#define OGMA_REG_TOP_STATUS			0x80
+#define OGMA_REG_TOP_INTEN			0x81
+#define OGMA_REG_TOP_INTEN_SET			0x8d
+#define OGMA_REG_TOP_INTEN_CLR			0x8e
+#define OGMA_REG_NRM_TX_STATUS			0x100
+#define OGMA_REG_NRM_TX_INTEN			0x101
+#define OGMA_REG_NRM_TX_INTEN_SET		0x10a
+#define OGMA_REG_NRM_TX_INTEN_CLR		0x10b
+#define OGMA_REG_NRM_RX_STATUS			0x110
+#define OGMA_REG_NRM_RX_INTEN			0x111
+#define OGMA_REG_NRM_RX_INTEN_SET		0x11a
+#define OGMA_REG_NRM_RX_INTEN_CLR		0x11b
+#define OGMA_REG_RESERVED_RX_DESC_START		0x122
+#define OGMA_REG_RESERVED_TX_DESC_START		0x132
+#define OGMA_REG_CLK_EN				0x40
+#define OGMA_REG_SOFT_RST			0x41
+#define OGMA_REG_PKT_CTRL			0x50
+#define OGMA_REG_COM_INIT			0x48
+#define OGMA_REG_DMA_TMR_CTRL			0x83
+#define OGMA_REG_F_TAIKI_MC_VER			0x8b
+#define OGMA_REG_F_TAIKI_VER			0x8c
+#define OGMA_REG_DMA_HM_CTRL			0x85
+#define OGMA_REG_DMA_MH_CTRL			0x88
+#define OGMA_REG_NRM_TX_PKTCNT			0x104
+#define OGMA_REG_NRM_TX_DONE_TXINT_PKTCNT	0x106
+#define OGMA_REG_NRM_RX_RXINT_PKTCNT		0x116
+#define OGMA_REG_NRM_TX_TXINT_TMR		0x108
+#define OGMA_REG_NRM_RX_RXINT_TMR		0x118
+#define OGMA_REG_NRM_TX_DONE_PKTCNT		0x105
+#define OGMA_REG_NRM_RX_PKTCNT			0x115
+#define OGMA_REG_NRM_TX_TMR			0x107
+#define OGMA_REG_NRM_RX_TMR			0x117
+#define OGMA_REG_NRM_TX_DESC_START		0x102
+#define OGMA_REG_NRM_RX_DESC_START		0x112
+#define OGMA_REG_NRM_TX_CONFIG			0x10c
+#define OGMA_REG_NRM_RX_CONFIG			0x11c
+#define MAC_REG_DATA				0x470
+#define MAC_REG_CMD				0x471
+#define MAC_REG_FLOW_TH				0x473
+#define MAC_REG_INTF_SEL			0x475
+#define MAC_REG_DESC_INIT			0x47f
+#define MAC_REG_DESC_SOFT_RST			0x481
+#define OGMA_REG_MODE_TRANS_COMP_STATUS		0x140
+#define GMAC_REG_MCR				0x0000
+#define GMAC_REG_MFFR				0x0004
+#define GMAC_REG_GAR				0x0010
+#define GMAC_REG_GDR				0x0014
+#define GMAC_REG_FCR				0x0018
+#define GMAC_REG_BMR				0x1000
+#define GMAC_REG_RDLAR				0x100c
+#define GMAC_REG_TDLAR				0x1010
+#define GMAC_REG_OMR				0x1018
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
+#define OGMA_SOFT_RST_REG_RESET			0
+#define OGMA_SOFT_RST_REG_RUN			(1 << 31)
+
+#define OGMA_DMA_CTRL_REG_STOP			1
+#define MH_CTRL__MODE_TRANS			(1 << 20)
+
+#define OGMA_GMAC_CMD_ST_READ			0
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
+#define OGMA_FCR_RFE			(1 << 2)
+#define OGMA_FCR_TFE			(1 << 1)
+
+#define OGMA_GMAC_GAR_REG_GW			(1 << 1)
+#define OGMA_GMAC_GAR_REG_GB			(1 << 0)
+
+#define OGMA_GMAC_GAR_REG_SHIFT_PA		11
+#define OGMA_GMAC_GAR_REG_SHIFT_GR		6
+#define GMAC_REG_SHIFT_CR_GAR			2
+
+#define OGMA_GMAC_GAR_REG_CR_25_35_MHZ		2
+#define OGMA_GMAC_GAR_REG_CR_35_60_MHZ		3
+#define OGMA_GMAC_GAR_REG_CR_60_100_MHZ		0
+#define OGMA_GMAC_GAR_REG_CR_100_150_MHZ	1
+#define OGMA_GMAC_GAR_REG_CR_150_250_MHZ	4
+#define OGMA_GMAC_GAR_REG_CR_250_300_MHZ	5
+
+#define OGMA_REG_OGMA_VER_F_TAIKI		0x20000
+
+#define OGMA_REG_DESC_RING_CONFIG_CFG_UP	31
+#define OGMA_REG_DESC_RING_CONFIG_CH_RST	30
+#define OGMA_REG_DESC_TMR_MODE			4
+#define OGMA_REG_DESC_ENDIAN			0
+
+#define OGMA_MAC_DESC_SOFT_RST_SOFT_RST		1
+#define OGMA_MAC_DESC_INIT_REG_INIT		1
+
+struct ogma_clk_ctrl {
+	u32 dmac_req_num;
+	u32 core_req_num;
+	u8 mac_req_num;
+};
+
+struct ogma_pkt_ctrlaram {
+	u32 log_chksum_er_flag:1;
+	u32 log_hd_imcomplete_flag:1;
+	u32 log_hd_er_flag:1;
+};
+
+struct ogma_param {
+	u32 use_jumbo_pkt_flag:1;
+	struct ogma_pkt_ctrlaram pkt_ctrlaram;
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
+struct ogma_desc_ring {
+	unsigned int id;
+	bool running;
+	u32 full:1;
+	u8 len;
+	u16 head;
+	u16 tail;
+	u16 rx_num;
+	u16 tx_done_num;
+	spinlock_t spinlock_desc; /* protect descriptor access */
+	void *ring_vaddr;
+	phys_addr_t desc_phys;
+	struct ogma_frag_info *frag;
+	struct sk_buff **priv;
+};
+
+struct ogma_priv {
+	void __iomem *ioaddr;
+	struct device *dev;
+	struct net_device *net_device;
+	struct mii_bus *mii_bus;
+	struct phy_device *phydev;
+	struct napi_struct napi;
+	struct device_node *phy_np;
+
+	struct ogma_param param;
+	struct ogma_clk_ctrl clk_ctrl;
+	u32 rx_pkt_buf_len;
+	struct ogma_desc_ring desc_ring[OGMA_RING_MAX + 1];
+	struct ogma_gmac_mode gmac_mode;
+	phys_addr_t rdlar_pa, tdlar_pa;
+	u32 gmac_hz;
+	u32 scb_pkt_ctrl_reg;
+	u32 scb_set_normal_tx_paddr;
+	struct clk *clk[3];
+	int clock_count;
+	phy_interface_t phy_interface;
+	struct ethtool_coalesce et_coalesce;
+
+	spinlock_t tx_queue_lock; /* protect transmit queue */
+	u32 rx_cksum_offload_flag:1;
+
+	int actual_link_speed;
+	bool actual_half_duplex;
+
+	u32 msg_enable;
+};
+
+struct ogma_tx_de {
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
+struct ogma_tx_pkt_ctrl {
+	u32 cksum_offload_flag:1;
+	u32 tcp_seg_offload_flag:1;
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
+	phys_addr_t paddr;
+	void *addr;
+	u16 len;
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
+extern const struct net_device_ops ogma_netdev_ops;
+extern const struct ethtool_ops ogma_ethtool_ops;
+
+int ogma_start_gmac(struct ogma_priv *priv);
+int ogma_stop_gmac(struct ogma_priv *priv);
+int ogma_mii_register(struct ogma_priv *priv);
+void ogma_mii_unregister(struct ogma_priv *priv);
+int ogma_start_desc_ring(struct ogma_priv *priv, unsigned int id);
+void ogma_stop_desc_ring(struct ogma_priv *priv, unsigned int id);
+u16 ogma_get_rx_num(struct ogma_priv *priv);
+u16 ogma_get_tx_avail_num(struct ogma_priv *priv);
+int ogma_clean_tx_desc_ring(struct ogma_priv *priv);
+int ogma_clean_rx_desc_ring(struct ogma_priv *priv);
+int ogma_set_tx_pkt_data(struct ogma_priv *priv,
+			 const struct ogma_tx_pkt_ctrl *tx_ctrl, u8 scat_num,
+			 const struct ogma_frag_info *scat,
+			 struct sk_buff *skb);
+int ogma_get_rx_pkt_data(struct ogma_priv *priv,
+			 struct ogma_rx_pkt_info *rxpi,
+			 struct ogma_frag_info *frag, u16 *len,
+			 struct sk_buff **skb);
+int ogma_ring_irq_enable(struct ogma_priv *priv,
+			 unsigned int id, u32 irq_factor);
+void ogma_ring_irq_disable(struct ogma_priv *priv, unsigned int id, u32 irqf);
+int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id);
+void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc);
+int ogma_setup_rx_desc(struct ogma_priv *priv,
+		       struct ogma_desc_ring *desc);
+int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget);
+
+#endif /* OGMA_INTERNAL_H */
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
new file mode 100644
index 0000000..7720d5f
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
@@ -0,0 +1,641 @@
+/**
+ * drivers/net/ethernet/fujitsu/ogma/ogma_desc_ring_access.c
+ *
+ *  Copyright (C) 2011-2014 Fujitsu Semiconductor Limited.
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
+static const u32 ads_irq_set[] = {
+	OGMA_REG_NRM_TX_INTEN_SET,
+	OGMA_REG_NRM_RX_INTEN_SET,
+};
+static const u32 desc_ring_irq_inten_clr_reg_addr[] = {
+	OGMA_REG_NRM_TX_INTEN_CLR,
+	OGMA_REG_NRM_RX_INTEN_CLR,
+};
+static const u32 int_tmr_reg_addr[] = {
+	OGMA_REG_NRM_TX_TXINT_TMR,
+	OGMA_REG_NRM_RX_RXINT_TMR,
+};
+static const u32 rx_pkt_cnt_reg_addr[] = {
+	0,
+	OGMA_REG_NRM_RX_PKTCNT,
+};
+static const u32 tx_pkt_cnt_reg_addr[] = {
+	OGMA_REG_NRM_TX_PKTCNT,
+	0,
+};
+static const u32 int_pkt_cnt_reg_addr[] = {
+	OGMA_REG_NRM_TX_DONE_TXINT_PKTCNT,
+	OGMA_REG_NRM_RX_RXINT_PKTCNT,
+};
+static const u32 tx_done_pkt_addr[] = {
+	OGMA_REG_NRM_TX_DONE_PKTCNT,
+	0,
+};
+
+static const u32 ogma_desc_mask[] = {
+	[OGMA_RING_TX] = OGMA_GMAC_OMR_REG_ST,
+	[OGMA_RING_RX] = OGMA_GMAC_OMR_REG_SR
+};
+
+static void ogma_check_desc_sanity(const struct ogma_desc_ring *desc,
+				   u16 idx, unsigned int expected_own)
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
+	if (!desc->running) {
+		netif_err(priv, drv, priv->net_device,
+			  "desc ring not running\n");
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
+static int alloc_rx_pkt_buf(struct ogma_priv *priv, struct ogma_frag_info *info,
+			    void **addr, phys_addr_t *pa, struct sk_buff **skb)
+{
+	*skb = netdev_alloc_skb_ip_align(priv->net_device, info->len);
+	if (!*skb)
+		return -ENOMEM;
+
+	ogma_mark_skb_type(*skb, OGMA_RING_RX);
+	*addr = (*skb)->data;
+	*pa = dma_map_single(priv->dev, *addr, info->len, DMA_FROM_DEVICE);
+	if (dma_mapping_error(priv->dev, *pa)) {
+		dev_kfree_skb(*skb);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	int ret = 0;
+
+	BUG_ON(id > OGMA_RING_MAX);
+
+	desc->id = id;
+	desc->len = sizeof(struct ogma_tx_de); /* rx and tx desc same size */
+
+	spin_lock_init(&desc->spinlock_desc);
+
+	desc->ring_vaddr = dma_alloc_coherent(priv->dev, desc->len * DESC_NUM,
+					      &desc->desc_phys, GFP_KERNEL);
+	if (!desc->ring_vaddr) {
+		ret = -ENOMEM;
+		netif_err(priv, hw, priv->net_device,
+			  "%s: failed to alloc\n", __func__);
+		goto err;
+	}
+
+	memset(desc->ring_vaddr, 0, desc->len * DESC_NUM);
+	desc->frag = kcalloc(DESC_NUM, sizeof(*desc->frag), GFP_KERNEL);
+	if (!desc->frag) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	desc->priv = kcalloc(DESC_NUM, sizeof(struct sk_buff *), GFP_KERNEL);
+	if (!desc->priv) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	return 0;
+
+err:
+	ogma_free_desc_ring(priv, desc);
+
+	return ret;
+}
+
+static void ogma_uninit_pkt_desc_ring(struct ogma_priv *priv,
+				      struct ogma_desc_ring *desc)
+{
+	struct ogma_frag_info *frag;
+	u32 status;
+	u16 idx;
+
+	for (idx = 0; idx < DESC_NUM; idx++) {
+		frag = &desc->frag[idx];
+		if (!frag->addr)
+			continue;
+
+		status = *(u32 *)(desc->ring_vaddr + desc->len * idx);
+
+		dma_unmap_single(priv->dev, frag->paddr, frag->len,
+				 skb_is_rx(desc->priv[idx]) ? DMA_FROM_DEVICE :
+							      DMA_TO_DEVICE);
+		if ((status >> OGMA_TX_LAST) & 1)
+			dev_kfree_skb(desc->priv[idx]);
+	}
+
+	memset(desc->frag, 0, sizeof(struct ogma_frag_info) * DESC_NUM);
+	memset(desc->priv, 0, sizeof(struct sk_buff *) * DESC_NUM);
+	memset(desc->ring_vaddr, 0, desc->len * DESC_NUM);
+}
+
+void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc)
+{
+	if (desc->ring_vaddr && desc->frag && desc->priv)
+		ogma_uninit_pkt_desc_ring(priv, desc);
+
+	if (desc->ring_vaddr)
+		dma_free_coherent(priv->dev, desc->len * DESC_NUM,
+				  desc->ring_vaddr, desc->desc_phys);
+	kfree(desc->frag);
+	kfree(desc->priv);
+
+	memset(desc, 0, sizeof(*desc));
+}
+
+static void ogma_set_rx_de(struct ogma_priv *priv,
+			   struct ogma_desc_ring *desc, u16 idx,
+			   const struct ogma_frag_info *info,
+			   struct sk_buff *skb)
+{
+	struct ogma_rx_de de;
+
+	ogma_check_desc_sanity(desc, idx, 0);
+	memset(&de, 0, sizeof(de));
+
+	de.attr = 1 << OGMA_RX_PKT_OWN_FIELD | 1 << OGMA_RX_PKT_FS_FIELD |
+					       1 << OGMA_RX_PKT_LS_FIELD;
+	de.data_buf_addr = info->paddr;
+	de.buf_len_info = info->len;
+
+	if (idx == DESC_NUM - 1)
+		de.attr |= 1 << OGMA_RX_PKT_LD_FIELD;
+
+	memcpy(desc->ring_vaddr + desc->len * idx + 4, &de + 4, desc->len - 4);
+	wmb(); /* make sure descriptor is written */
+	memcpy(desc->ring_vaddr + desc->len * idx, &de, 4);
+
+	desc->frag[idx].paddr = info->paddr;
+	desc->frag[idx].addr = info->addr;
+	desc->frag[idx].len = info->len;
+
+	desc->priv[idx] = skb;
+}
+
+int ogma_setup_rx_desc(struct ogma_priv *priv, struct ogma_desc_ring *desc)
+{
+	struct ogma_frag_info info;
+	struct sk_buff *skb;
+	int n;
+
+	info.len = priv->rx_pkt_buf_len;
+
+	for (n = 0; n < DESC_NUM; n++) {
+		if (alloc_rx_pkt_buf(priv, &info, &info.addr, &info.paddr,
+				     &skb)) {
+			ogma_uninit_pkt_desc_ring(priv, desc);
+			netif_err(priv, hw, priv->net_device,
+				  "%s: Fail ring alloc\n", __func__);
+			return -ENOMEM;
+		}
+		ogma_set_rx_de(priv, desc, n, &info, skb);
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
+	struct ogma_tx_de tx_desc_entry;
+	int idx = desc->head;
+
+	ogma_check_desc_sanity(desc, idx, 0);
+
+	memset(&tx_desc_entry, 0, sizeof(struct ogma_tx_de));
+
+	tx_desc_entry.attr = 1 << OGMA_TX_SHIFT_OWN_FIELD |
+			     (idx == (DESC_NUM - 1)) << OGMA_TX_SHIFT_LD_FIELD |
+			     desc->id << OGMA_TX_SHIFT_DRID_FIELD |
+			     1 << OGMA_TX_SHIFT_PT_FIELD |
+			     OGMA_RING_GMAC << OGMA_TX_SHIFT_TDRID_FIELD |
+			     first_flag << OGMA_TX_SHIFT_FS_FIELD |
+			     last_flag << OGMA_TX_LAST |
+			     tx_ctrl->cksum_offload_flag << OGMA_TX_SHIFT_CO |
+			     tx_ctrl->tcp_seg_offload_flag << OGMA_TX_SHIFT_SO |
+			     1 << OGMA_TX_SHIFT_TRS_FIELD;
+
+	tx_desc_entry.data_buf_addr = frag->paddr;
+	tx_desc_entry.buf_len_info = (tx_ctrl->tcp_seg_len << 16) | frag->len;
+
+	memcpy(desc->ring_vaddr + (desc->len * idx), &tx_desc_entry, desc->len);
+
+	desc->frag[idx].paddr = frag->paddr;
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
+	ogma_check_desc_sanity(desc, idx, 0);
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
+				   struct ogma_desc_ring *desc, u16 inc)
+{
+	u32 sum;
+
+	if ((desc->tail > desc->head) || desc->full)
+		BUG_ON(inc > (desc->tail - desc->head));
+	else
+		BUG_ON(inc > (DESC_NUM + desc->tail - desc->head));
+
+	sum = desc->head + inc;
+
+	if (sum >= DESC_NUM)
+		sum -= DESC_NUM;
+
+	desc->head = sum;
+	desc->full = desc->head == desc->tail;
+}
+
+static void ogma_inc_desc_tail_idx(struct ogma_priv *priv,
+				   struct ogma_desc_ring *desc)
+{
+	u32 sum;
+
+	if ((desc->head >= desc->tail) && (!desc->full))
+		BUG_ON(1 > (desc->head - desc->tail));
+	else
+		BUG_ON(1 > (DESC_NUM + desc->head - desc->tail));
+
+	sum = desc->tail + 1;
+
+	if (sum >= DESC_NUM)
+		sum -= DESC_NUM;
+
+	desc->tail = sum;
+	desc->full = 0;
+}
+
+static u16 ogma_get_tx_avail_num_sub(struct ogma_priv *priv,
+				     const struct ogma_desc_ring *desc)
+{
+	if (desc->full)
+		return 0;
+
+	if (desc->tail > desc->head)
+		return desc->tail - desc->head;
+
+	return DESC_NUM + desc->tail - desc->head;
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
+static int ogma_set_irq_coalesce_param(struct ogma_priv *priv, unsigned int id)
+{
+	int max_frames, tmr;
+
+	switch (id) {
+	case OGMA_RING_TX:
+		max_frames = priv->et_coalesce.tx_max_coalesced_frames;
+		tmr = priv->et_coalesce.tx_coalesce_usecs;
+		break;
+	case OGMA_RING_RX:
+		max_frames = priv->et_coalesce.rx_max_coalesced_frames;
+		tmr = priv->et_coalesce.rx_coalesce_usecs;
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	ogma_write_reg(priv, int_pkt_cnt_reg_addr[id], max_frames);
+	ogma_write_reg(priv, int_tmr_reg_addr[id], ((tmr != 0) << 31) | tmr);
+
+	return 0;
+}
+
+int ogma_start_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+	int ret = 0;
+
+	spin_lock_bh(&desc->spinlock_desc);
+
+	if (desc->running) {
+		ret = -EBUSY;
+		goto err;
+	}
+
+	switch (desc->id) {
+	case OGMA_RING_RX:
+		ogma_write_reg(priv, ads_irq_set[id], OGMA_IRQ_RCV);
+		break;
+	case OGMA_RING_TX:
+		ogma_write_reg(priv, ads_irq_set[id], OGMA_IRQ_EMPTY);
+		break;
+	}
+
+	ogma_set_irq_coalesce_param(priv, desc->id);
+	desc->running = 1;
+
+err:
+	spin_unlock_bh(&desc->spinlock_desc);
+
+	return ret;
+}
+
+void ogma_stop_desc_ring(struct ogma_priv *priv, unsigned int id)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[id];
+
+	BUG_ON(id > OGMA_RING_MAX);
+
+	spin_lock_bh(&desc->spinlock_desc);
+	if (desc->running)
+		ogma_write_reg(priv, desc_ring_irq_inten_clr_reg_addr[id],
+			       OGMA_IRQ_RCV | OGMA_IRQ_EMPTY | OGMA_IRQ_SND);
+
+	desc->running = 0;
+	spin_unlock_bh(&desc->spinlock_desc);
+}
+
+u16 ogma_get_rx_num(struct ogma_priv *priv)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[OGMA_RING_RX];
+	u32 result;
+
+	spin_lock(&desc->spinlock_desc);
+	if (desc->running) {
+		result = ogma_read_reg(priv, rx_pkt_cnt_reg_addr[OGMA_RING_RX]);
+		desc->rx_num += result;
+		if (result)
+			ogma_inc_desc_head_idx(priv, desc, result);
+	}
+	spin_unlock(&desc->spinlock_desc);
+
+	return desc->rx_num;
+}
+
+u16 ogma_get_tx_avail_num(struct ogma_priv *priv)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[OGMA_RING_TX];
+	u16 result;
+
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: not running tx desc\n", __func__);
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
+int ogma_clean_tx_desc_ring(struct ogma_priv *priv)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[OGMA_RING_TX];
+	struct ogma_frag_info *frag;
+	struct ogma_tx_de *entry;
+	bool is_last;
+
+	spin_lock(&desc->spinlock_desc);
+
+	ogma_get_tx_done_num_sub(priv, desc);
+
+	while ((desc->tail != desc->head || desc->full) && desc->tx_done_num) {
+		frag = &desc->frag[desc->tail];
+		entry = desc->ring_vaddr + desc->len * desc->tail;
+		is_last = (entry->attr >> OGMA_TX_LAST) & 1;
+
+		dma_unmap_single(priv->dev, frag->paddr, frag->len,
+				 DMA_TO_DEVICE);
+		if (is_last) {
+			priv->net_device->stats.tx_packets++;
+			priv->net_device->stats.tx_bytes +=
+						desc->priv[desc->tail]->len;
+			dev_kfree_skb(desc->priv[desc->tail]);
+		}
+		memset(frag, 0, sizeof(*frag));
+		ogma_inc_desc_tail_idx(priv, desc);
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
+int ogma_clean_rx_desc_ring(struct ogma_priv *priv)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[OGMA_RING_RX];
+
+	spin_lock(&desc->spinlock_desc);
+
+	while (desc->full || (desc->tail != desc->head)) {
+		ogma_set_rx_de(priv, desc, desc->tail, &desc->frag[desc->tail],
+			       desc->priv[desc->tail]);
+		desc->rx_num--;
+		ogma_inc_desc_tail_idx(priv, desc);
+	}
+
+	BUG_ON(desc->rx_num);	/* error check */
+
+	spin_unlock(&desc->spinlock_desc);
+
+	return 0;
+}
+
+int ogma_set_tx_pkt_data(struct ogma_priv *priv,
+			 const struct ogma_tx_pkt_ctrl *tx_ctrl, u8 scat_num,
+			 const struct ogma_frag_info *scat, struct sk_buff *skb)
+{
+	struct ogma_desc_ring *desc;
+	u32 sum_len = 0;
+	unsigned int i;
+	int ret = 0;
+
+	if (tx_ctrl->tcp_seg_offload_flag && !tx_ctrl->cksum_offload_flag)
+		return -EINVAL;
+
+	if (tx_ctrl->tcp_seg_offload_flag) {
+		if (tx_ctrl->tcp_seg_len < OGMA_TCP_SEG_LEN_MIN)
+			return -EINVAL;
+
+		if (priv->param.use_jumbo_pkt_flag) {
+			if (tx_ctrl->tcp_seg_len > OGMA_TCP_JUMBO_SEG_LEN_MAX)
+				return -EINVAL;
+		} else {
+			if (tx_ctrl->tcp_seg_len > OGMA_TCP_SEG_LEN_MAX)
+				return -EINVAL;
+		}
+	} else
+		if (tx_ctrl->tcp_seg_len)
+			return -EINVAL;
+
+	if (!scat_num)
+		return -ERANGE;
+
+	for (i = 0; i < scat_num; i++) {
+		if ((scat[i].len == 0) || (scat[i].len > 0xffff)) {
+			netif_err(priv, drv, priv->net_device,
+				  "%s: bad scat len\n", __func__);
+			return -EINVAL;
+		}
+		sum_len += scat[i].len;
+	}
+
+	if (!tx_ctrl->tcp_seg_offload_flag) {
+		if (priv->param.use_jumbo_pkt_flag) {
+			if (sum_len > OGMA_MAX_TX_JUMBO_PKT_LEN)
+				return -EINVAL;
+		} else
+			if (sum_len > OGMA_MAX_TX_PKT_LEN)
+				return -EINVAL;
+	}
+
+	desc = &priv->desc_ring[OGMA_RING_TX];
+	spin_lock(&desc->spinlock_desc);
+
+	if (!desc->running) {
+		ret = -ENODEV;
+		goto end;
+	}
+
+	smp_rmb(); /* get consistent view of pending tx count */
+	if (scat_num > ogma_get_tx_avail_num_sub(priv, desc)) {
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
+	ogma_write_reg(priv, tx_pkt_cnt_reg_addr[OGMA_RING_TX], 1);
+
+end:
+	spin_unlock(&desc->spinlock_desc);
+
+	return ret;
+}
+
+int ogma_get_rx_pkt_data(struct ogma_priv *priv,
+			 struct ogma_rx_pkt_info *rxpi,
+			 struct ogma_frag_info *frag, u16 *len,
+			 struct sk_buff **skb)
+{
+	struct ogma_desc_ring *desc = &priv->desc_ring[OGMA_RING_RX];
+	struct ogma_frag_info info;
+	struct sk_buff *tmp_skb;
+	int ret = 0;
+
+	spin_lock(&desc->spinlock_desc);
+	BUG_ON(!desc->running);
+
+	if (desc->rx_num == 0) {
+		ret = -EINVAL;
+		goto err;
+	}
+
+	info.len = priv->rx_pkt_buf_len;
+	rmb(); /* make sure reads are completed */
+	if (alloc_rx_pkt_buf(priv, &info, &info.addr, &info.paddr, &tmp_skb)) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: alloc_rx_pkt_buf fail\n", __func__);
+		ogma_set_rx_de(priv, desc, desc->tail, &desc->frag[desc->tail],
+			       desc->priv[desc->tail]);
+		ret = -ENOMEM;
+	} else {
+		ogma_get_rx_de(priv, desc, desc->tail, rxpi, frag, len, skb);
+		ogma_set_rx_de(priv, desc, desc->tail, &info, tmp_skb);
+	}
+
+	ogma_inc_desc_tail_idx(priv, desc);
+	desc->rx_num--;
+
+err:
+	spin_unlock(&desc->spinlock_desc);
+
+	return ret;
+}
+
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c b/drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c
new file mode 100644
index 0000000..8c73555
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c
@@ -0,0 +1,98 @@
+/**
+ * drivers/net/ethernet/fujitsu/ogma/ogma_ethtool.c
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
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+
+#include "ogma.h"
+
+static void ogma_et_get_drvinfo(struct net_device *net_device,
+				struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, "ogma", sizeof(info->driver));
+	strlcpy(info->bus_info, dev_name(net_device->dev.parent),
+		sizeof(info->bus_info));
+}
+
+static int ogma_et_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ogma_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_gset(priv->phydev, cmd);
+}
+
+static int ogma_et_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct ogma_priv *priv = netdev_priv(dev);
+
+	if (!priv->phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(priv->phydev, cmd);
+}
+
+static int ogma_et_get_coalesce(struct net_device *net_device,
+				struct ethtool_coalesce *et_coalesce)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+
+	*et_coalesce = priv->et_coalesce;
+
+	return 0;
+}
+static int ogma_et_set_coalesce(struct net_device *net_device,
+				struct ethtool_coalesce *et_coalesce)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+
+	if (et_coalesce->rx_max_coalesced_frames > OGMA_INT_PKTCNT_MAX)
+		return -EINVAL;
+	if (et_coalesce->tx_max_coalesced_frames > OGMA_INT_PKTCNT_MAX)
+		return -EINVAL;
+	if (!et_coalesce->rx_max_coalesced_frames)
+		return -EINVAL;
+	if (!et_coalesce->tx_max_coalesced_frames)
+		return -EINVAL;
+
+	priv->et_coalesce = *et_coalesce;
+
+	return 0;
+}
+
+static u32 ogma_et_get_msglevel(struct net_device *dev)
+{
+	struct ogma_priv *priv = netdev_priv(dev);
+
+	return priv->msg_enable;
+}
+
+static void ogma_et_set_msglevel(struct net_device *dev, u32 datum)
+{
+	struct ogma_priv *priv = netdev_priv(dev);
+
+	priv->msg_enable = datum;
+}
+
+const struct ethtool_ops ogma_ethtool_ops = {
+	.get_drvinfo		= ogma_et_get_drvinfo,
+	.get_settings		= ogma_et_get_settings,
+	.set_settings		= ogma_et_set_settings,
+	.get_link		= ethtool_op_get_link,
+	.get_coalesce		= ogma_et_get_coalesce,
+	.set_coalesce		= ogma_et_set_coalesce,
+	.get_msglevel		= ogma_et_get_msglevel,
+	.set_msglevel		= ogma_et_set_msglevel,
+};
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c b/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
new file mode 100644
index 0000000..c57b9c3
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
@@ -0,0 +1,244 @@
+/**
+ * drivers/net/ethernet/fujitsu/ogma/ogma_gmac_access.c
+ *
+ *  Copyright (C) 2011-2014 Fujitsu Semiconductor Limited.
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
+#define TIMEOUT_SPINS_MAC 1000000
+
+static u32 ogma_clk_type(u32 gmac_hz)
+{
+	if (gmac_hz < 35 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_25_35_MHZ;
+	if (gmac_hz < 60 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_35_60_MHZ;
+	if (gmac_hz < 100 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_60_100_MHZ;
+	if (gmac_hz < 150 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_100_150_MHZ;
+	if (gmac_hz < 250 * OGMA_CLK_MHZ)
+		return OGMA_GMAC_GAR_REG_CR_150_250_MHZ;
+
+	return OGMA_GMAC_GAR_REG_CR_250_300_MHZ;
+}
+
+static int ogma_wait_while_busy(struct ogma_priv *priv, u32 addr, u32 mask)
+{
+	u32 timeout = TIMEOUT_SPINS_MAC;
+
+	while (--timeout && ogma_read_reg(priv, addr) & mask)
+		;
+	if (!timeout) {
+		netdev_WARN(priv->net_device, "%s: timeout\n", __func__);
+		return -ETIME;
+	}
+
+	return 0;
+}
+
+void ogma_mac_write(struct ogma_priv *priv, u32 addr, u32 value)
+{
+	ogma_write_reg(priv, MAC_REG_DATA, value);
+	ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_WRITE);
+	ogma_wait_while_busy(priv, MAC_REG_CMD, OGMA_GMAC_CMD_ST_BUSY);
+}
+
+u32 ogma_mac_read(struct ogma_priv *priv, u32 addr)
+{
+	ogma_write_reg(priv, MAC_REG_CMD, addr | OGMA_GMAC_CMD_ST_READ);
+	ogma_wait_while_busy(priv, MAC_REG_CMD, OGMA_GMAC_CMD_ST_BUSY);
+
+	return ogma_read_reg(priv, MAC_REG_DATA);
+}
+
+static int ogma_mac_wait_while_busy(struct ogma_priv *priv, u32 addr, u32 mask)
+{
+	u32 timeout = TIMEOUT_SPINS_MAC;
+
+	while (--timeout && ogma_mac_read(priv, addr) & mask)
+		;
+	if (!timeout) {
+		netdev_WARN(priv->net_device, "%s: timeout\n", __func__);
+		return -ETIME;
+	}
+
+	return 0;
+}
+
+int ogma_start_gmac(struct ogma_priv *priv)
+{
+	u32 value;
+
+	if (priv->desc_ring[OGMA_RING_TX].running &&
+	    priv->desc_ring[OGMA_RING_RX].running)
+		return 0;
+
+	if (!priv->desc_ring[OGMA_RING_RX].running &&
+	    !priv->desc_ring[OGMA_RING_TX].running) {
+		if (priv->gmac_mode.link_speed == SPEED_1000)
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
+		if (ogma_wait_while_busy(priv, MAC_REG_DESC_SOFT_RST, 1))
+			return -ETIME;
+
+		ogma_write_reg(priv, MAC_REG_DESC_INIT, 1);
+		if (ogma_wait_while_busy(priv, MAC_REG_DESC_INIT, 1))
+			return -ETIME;
+
+		ogma_mac_write(priv, GMAC_REG_BMR, OGMA_GMAC_BMR_REG_COMMON);
+		ogma_mac_write(priv, GMAC_REG_RDLAR, priv->rdlar_pa);
+		ogma_mac_write(priv, GMAC_REG_TDLAR, priv->tdlar_pa);
+		ogma_mac_write(priv, GMAC_REG_MFFR, 0x80000001);
+
+		value = priv->gmac_mode.half_duplex_flag ?
+			OGMA_GMAC_MCR_REG_HALF_DUPLEX_COMMON :
+			OGMA_GMAC_MCR_REG_FULL_DUPLEX_COMMON;
+
+		if (priv->gmac_mode.link_speed != SPEED_1000)
+			value |= OGMA_GMAC_MCR_PS;
+
+		if ((priv->phy_interface != PHY_INTERFACE_MODE_GMII) &&
+		    (priv->gmac_mode.link_speed == SPEED_100))
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
+				       OGMA_FCR_RFE | OGMA_FCR_TFE);
+		}
+	}
+
+
+	value = ogma_mac_read(priv, GMAC_REG_OMR);
+
+	if (!priv->desc_ring[OGMA_RING_RX].running) {
+		value |= OGMA_GMAC_OMR_REG_SR;
+		priv->desc_ring[OGMA_RING_RX].running = true;
+	}
+	if (!priv->desc_ring[OGMA_RING_TX].running) {
+		value |= OGMA_GMAC_OMR_REG_ST;
+		priv->desc_ring[OGMA_RING_TX].running = true;
+	}
+
+	ogma_mac_write(priv, GMAC_REG_OMR, value);
+
+	return 0;
+}
+
+int ogma_stop_gmac(struct ogma_priv *priv)
+{
+	u32 value;
+
+	if (priv->desc_ring[OGMA_RING_RX].running ||
+	    priv->desc_ring[OGMA_RING_TX].running) {
+		value = ogma_mac_read(priv, GMAC_REG_OMR);
+
+		if (priv->desc_ring[OGMA_RING_RX].running) {
+			value &= (~OGMA_GMAC_OMR_REG_SR);
+			priv->desc_ring[OGMA_RING_RX].running = false;
+		}
+		if (priv->desc_ring[OGMA_RING_TX].running) {
+			value &= (~OGMA_GMAC_OMR_REG_ST);
+			priv->desc_ring[OGMA_RING_TX].running = false;
+		}
+
+		ogma_mac_write(priv, GMAC_REG_OMR, value);
+	}
+
+	return 0;
+}
+
+static int ogma_phy_write(struct mii_bus *bus, int phy_addr, int reg, u16 val)
+{
+	struct ogma_priv *priv = bus->priv;
+
+	BUG_ON(phy_addr >= 32 || reg >= 32);
+
+	ogma_mac_write(priv, GMAC_REG_GDR, val);
+	ogma_mac_write(priv, GMAC_REG_GAR,
+		       phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
+		       reg << OGMA_GMAC_GAR_REG_SHIFT_GR |
+		       ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR |
+		       OGMA_GMAC_GAR_REG_GW | OGMA_GMAC_GAR_REG_GB);
+
+	return ogma_mac_wait_while_busy(priv, GMAC_REG_GAR,
+					OGMA_GMAC_GAR_REG_GB);
+}
+
+static int ogma_phy_read(struct mii_bus *bus, int phy_addr, int reg_addr)
+{
+	struct ogma_priv *priv = bus->priv;
+
+	BUG_ON(phy_addr >= 32 || reg_addr >= 32);
+
+	ogma_mac_write(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB |
+		       phy_addr << OGMA_GMAC_GAR_REG_SHIFT_PA |
+		       reg_addr << OGMA_GMAC_GAR_REG_SHIFT_GR |
+		       ogma_clk_type(priv->gmac_hz) << GMAC_REG_SHIFT_CR_GAR);
+
+	if (ogma_mac_wait_while_busy(priv, GMAC_REG_GAR, OGMA_GMAC_GAR_REG_GB))
+		return 0;
+
+	return ogma_mac_read(priv, GMAC_REG_GDR);
+}
+
+int ogma_mii_register(struct ogma_priv *priv)
+{
+	struct mii_bus *bus = mdiobus_alloc();
+	struct resource res;
+	int ret;
+
+	if (!bus)
+		return -ENOMEM;
+
+	of_address_to_resource(priv->dev->of_node, 0, &res);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%p", (void *)(long)res.start);
+	bus->priv = priv;
+	bus->name = "Fujitsu OGMA MDIO";
+	bus->read = ogma_phy_read;
+	bus->write = ogma_phy_write;
+	bus->parent = priv->dev;
+
+	priv->mii_bus = bus;
+
+	ret = of_mdiobus_register(bus, priv->dev->of_node);
+	if (ret) {
+		mdiobus_free(bus);
+		return ret;
+	}
+
+	return 0;
+}
+
+void ogma_mii_unregister(struct ogma_priv *priv)
+{
+	mdiobus_unregister(priv->mii_bus);
+	mdiobus_free(priv->mii_bus);
+	priv->mii_bus = NULL;
+}
+
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
new file mode 100644
index 0000000..10e60bb
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
@@ -0,0 +1,469 @@
+/**
+ * drivers/net/ethernet/fujitsu/ogma/ogma_netdev.c
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
+#include <linux/netdevice.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
+#include <net/ip6_checksum.h>
+#include <linux/etherdevice.h>
+#include <linux/pm_runtime.h>
+
+#include "ogma.h"
+
+#define OGMA_PHY_SR_REG_AN_C			0x20
+#define OGMA_PHY_SR_REG_LINK			4
+
+#define SR_1GBIT		0x800
+
+#define OGMA_PHY_ANLPA_REG_TXF			0x100
+#define OGMA_PHY_ANLPA_REG_TXD			0x80
+#define OGMA_PHY_ANLPA_REG_TF			0x40
+#define OGMA_PHY_ANLPA_REG_TD			0x20
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
+#define MSC_1GBIT		(1 << 9)
+
+#define OGMA_PHY_ADDR_CTRL			0
+#define OGMA_PHY_ADDR_SR			1
+#define OGMA_PHY_ADDR_ANA			4
+#define OGMA_PHY_ADDR_ANLPA			5
+#define OGMA_PHY_ADDR_MSC			9
+#define OGMA_PHY_ADDR_1000BASE_SR		10
+
+static const u32 desc_ring_irq_status_reg_addr[] = {
+	OGMA_REG_NRM_TX_STATUS,
+	OGMA_REG_NRM_RX_STATUS,
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
+
+	ogma_write_reg(priv, desc_ring_irq_status_reg_addr[id],
+		       (value & (OGMA_IRQ_EMPTY | OGMA_IRQ_ERR)));
+}
+
+int ogma_netdev_napi_poll(struct napi_struct *napi_p, int budget)
+{
+	struct ogma_priv *priv = container_of(napi_p, struct ogma_priv, napi);
+	struct net_device *net_device = priv->net_device;
+	struct ogma_rx_pkt_info rx_info;
+	int ret, done = 0, rx_num = 0;
+	struct ogma_frag_info frag;
+	struct sk_buff *skb;
+	u16 len;
+
+	ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+	ogma_clean_tx_desc_ring(priv);
+
+	if (netif_queue_stopped(priv->net_device) &&
+	    ogma_get_tx_avail_num(priv) >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX)
+		netif_wake_queue(priv->net_device);
+
+	while (done < budget) {
+		if (!rx_num) {
+			rx_num = ogma_get_rx_num(priv);
+			if (!rx_num)
+				break;
+		}
+
+		ret = ogma_get_rx_pkt_data(priv, &rx_info, &frag, &len, &skb);
+		if (unlikely(ret == -ENOMEM)) {
+			netif_err(priv, drv, priv->net_device,
+				  "%s: rx fail %d\n", __func__, ret);
+			net_device->stats.rx_dropped++;
+		} else {
+			dma_unmap_single(priv->dev, frag.paddr, frag.len,
+					 DMA_FROM_DEVICE);
+
+			skb_put(skb, len);
+			skb->protocol = eth_type_trans(skb, priv->net_device);
+
+			if (priv->rx_cksum_offload_flag &&
+			    rx_info.rx_cksum_result == OGMA_RX_CKSUM_OK)
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+			napi_gro_receive(napi_p, skb);
+
+			net_device->stats.rx_packets++;
+			net_device->stats.rx_bytes += len;
+		}
+
+		done++;
+		rx_num--;
+	}
+
+	if (done == budget)
+		return budget;
+
+	napi_complete(napi_p);
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET,
+		       OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
+
+	return done;
+}
+
+static int ogma_netdev_stop(struct net_device *net_device)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+
+	netif_stop_queue(priv->net_device);
+	ogma_stop_gmac(priv);
+	ogma_stop_desc_ring(priv, OGMA_RING_RX);
+	ogma_stop_desc_ring(priv, OGMA_RING_TX);
+	napi_disable(&priv->napi);
+	phy_stop(priv->phydev);
+	phy_disconnect(priv->phydev);
+	priv->phydev = NULL;
+
+	pm_runtime_mark_last_busy(priv->dev);
+	pm_runtime_put_autosuspend(priv->dev);
+
+	return 0;
+}
+
+static netdev_tx_t ogma_netdev_start_xmit(struct sk_buff *skb,
+					  struct net_device *net_device)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+	struct ogma_tx_pkt_ctrl tx_ctrl;
+	u16 pend_tx, tso_seg_len = 0;
+	struct ogma_frag_info *scat;
+	skb_frag_t *frag;
+	u8 scat_num;
+	int ret, i;
+
+	memset(&tx_ctrl, 0, sizeof(struct ogma_tx_pkt_ctrl));
+
+	ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+
+	BUG_ON(skb_shinfo(skb)->nr_frags >= OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX);
+	scat_num = skb_shinfo(skb)->nr_frags + 1;
+
+	scat = kcalloc(scat_num, sizeof(*scat), GFP_NOWAIT);
+	if (!scat)
+		return NETDEV_TX_OK;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ip_hdr(skb)->check = 0;
+		tx_ctrl.cksum_offload_flag = 1;
+	}
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
+	scat[0].paddr = dma_map_single(priv->dev, skb->data,
+					   skb_headlen(skb), DMA_TO_DEVICE);
+	if (dma_mapping_error(priv->dev, scat[0].paddr)) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: DMA mapping failed\n", __func__);
+		kfree(scat);
+		return NETDEV_TX_OK;
+	}
+	scat[0].addr = skb->data;
+	scat[0].len = skb_headlen(skb);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		scat[i + 1].paddr =
+			skb_frag_dma_map(priv->dev, frag, 0,
+					 skb_frag_size(frag), DMA_TO_DEVICE);
+		scat[i + 1].addr = skb_frag_address(frag);
+		scat[i + 1].len = frag->size;
+	}
+
+	ogma_mark_skb_type(skb, OGMA_RING_TX);
+
+	ret = ogma_set_tx_pkt_data(priv, &tx_ctrl, scat_num, scat, skb);
+	if (ret) {
+		netif_err(priv, drv, priv->net_device,
+			  "set tx pkt failed %d\n", ret);
+		for (i = 0; i < scat_num; i++)
+			dma_unmap_single(priv->dev, scat[i].paddr,
+					 scat[i].len, DMA_TO_DEVICE);
+		kfree(scat);
+		net_device->stats.tx_dropped++;
+
+		return NETDEV_TX_OK;
+	}
+
+	kfree(scat);
+
+	spin_lock(&priv->tx_queue_lock);
+	pend_tx = ogma_get_tx_avail_num(priv);
+
+	if (pend_tx < OGMA_NETDEV_TX_PKT_SCAT_NUM_MAX) {
+		ogma_ring_irq_enable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+		netif_stop_queue(net_device);
+		goto err;
+	}
+	if (pend_tx <= DESC_NUM - 2) {
+		ogma_ring_irq_enable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+		goto err;
+	}
+	ogma_ring_irq_disable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+
+err:
+	spin_unlock(&priv->tx_queue_lock);
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
+static int ogma_netdev_change_mtu(struct net_device *net_device, int new_mtu)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+
+	if (!priv->param.use_jumbo_pkt_flag)
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
+	struct ogma_priv *priv = netdev_priv(net_device);
+
+	priv->rx_cksum_offload_flag = !!(features & NETIF_F_RXCSUM);
+
+	return 0;
+}
+
+static int ogma_phy_get_link_speed(struct ogma_priv *priv, bool *half_duplex)
+{
+	int link_speed = SPEED_10;
+	u32 u;
+
+	*half_duplex = false;
+
+	if ((phy_read(priv->phydev, OGMA_PHY_ADDR_MSC) & MSC_1GBIT) &&
+	    (phy_read(priv->phydev, OGMA_PHY_ADDR_1000BASE_SR) & SR_1GBIT))
+		link_speed = SPEED_1000;
+	else {
+		u = phy_read(priv->phydev, OGMA_PHY_ADDR_ANA) &
+		    phy_read(priv->phydev, OGMA_PHY_ADDR_ANLPA);
+
+		if (u & OGMA_PHY_ANLPA_REG_TXF) {
+			link_speed = SPEED_100;
+		} else if (u & OGMA_PHY_ANLPA_REG_TXD) {
+			link_speed = SPEED_100;
+			*half_duplex = true;
+		}
+	}
+
+	return link_speed;
+}
+
+static void ogma_phy_adjust_link(struct net_device *net_device)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+	bool half_duplex = false;
+	int link_speed;
+	u32 sr;
+
+	sr = phy_read(priv->phydev, OGMA_PHY_ADDR_SR);
+
+	if ((sr & OGMA_PHY_SR_REG_LINK) && (sr & OGMA_PHY_SR_REG_AN_C)) {
+		link_speed = ogma_phy_get_link_speed(priv, &half_duplex);
+		if (priv->actual_link_speed != link_speed ||
+		    priv->actual_half_duplex != half_duplex) {
+			netif_info(priv, drv, priv->net_device,
+				   "Autoneg: %uMbps, half-duplex:%d\n",
+				   link_speed, half_duplex);
+			ogma_stop_gmac(priv);
+			priv->gmac_mode.link_speed = link_speed;
+			priv->gmac_mode.half_duplex_flag = half_duplex;
+			ogma_start_gmac(priv);
+
+			priv->actual_link_speed = link_speed;
+			priv->actual_half_duplex = half_duplex;
+		}
+	}
+
+	if (!netif_running(priv->net_device) && (sr & OGMA_PHY_SR_REG_LINK)) {
+		netif_info(priv, drv, priv->net_device,
+			   "%s: link up\n", __func__);
+		netif_carrier_on(net_device);
+		netif_start_queue(net_device);
+	}
+
+	if (netif_running(priv->net_device) && !(sr & OGMA_PHY_SR_REG_LINK)) {
+		netif_info(priv, drv, priv->net_device,
+			   "%s: link down\n", __func__);
+		netif_stop_queue(net_device);
+		netif_carrier_off(net_device);
+		priv->actual_link_speed = 0;
+		priv->actual_half_duplex = 0;
+	}
+}
+
+static int ogma_netdev_open_sub(struct ogma_priv *priv)
+{
+	napi_enable(&priv->napi);
+
+	if (ogma_start_desc_ring(priv, OGMA_RING_RX))
+		goto err1;
+	if (ogma_start_desc_ring(priv, OGMA_RING_TX))
+		goto err2;
+
+	ogma_ring_irq_disable(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+
+	return 0;
+
+err2:
+	ogma_stop_desc_ring(priv, OGMA_RING_RX);
+err1:
+	napi_disable(&priv->napi);
+
+	return -EINVAL;
+}
+
+static int ogma_netdev_open(struct net_device *net_device)
+{
+	struct ogma_priv *priv = netdev_priv(net_device);
+	int ret;
+
+	pm_runtime_get_sync(priv->dev);
+
+	ret = ogma_clean_rx_desc_ring(priv);
+	if (ret) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: clean rx desc fail\n", __func__);
+		goto err;
+	}
+
+	ret = ogma_clean_tx_desc_ring(priv);
+	if (ret) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: clean tx desc fail\n", __func__);
+		goto err;
+	}
+
+	ogma_ring_irq_clr(priv, OGMA_RING_TX, OGMA_IRQ_EMPTY);
+
+	priv->phydev = of_phy_connect(priv->net_device, priv->phy_np,
+				      &ogma_phy_adjust_link, 0,
+				      priv->phy_interface);
+	if (!priv->phydev) {
+		netif_err(priv, link, priv->net_device,
+			  "could not find the PHY\n");
+		goto err;
+	}
+
+	phy_start(priv->phydev);
+
+	ret = ogma_netdev_open_sub(priv);
+	if (ret) {
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+		netif_err(priv, link, priv->net_device,
+			  "ogma_netdev_open_sub() failed\n");
+		goto err;
+	}
+
+	/* mask with MAC supported features */
+	priv->phydev->supported &= PHY_BASIC_FEATURES;
+	priv->phydev->advertising = priv->phydev->supported;
+
+	return ret;
+
+err:
+	pm_runtime_put_sync(priv->dev);
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
diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
new file mode 100644
index 0000000..38278ad
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
@@ -0,0 +1,626 @@
+/**
+ * drivers/net/ethernet/fujitsu/ogma/ogma_platform.c
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
+#include <linux/device.h>
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
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/io.h>
+#include <linux/pm_runtime.h>
+#include <linux/etherdevice.h>
+
+#include "ogma.h"
+
+#define OGMA_F_NETSEC_VER_MAJOR_NUM(x) (x & 0xffff0000)
+
+static const u32 desc_ads[] = {
+	OGMA_REG_NRM_TX_CONFIG,
+	OGMA_REG_NRM_RX_CONFIG,
+};
+
+static const u32 ogma_desc_start_reg_addr[] = {
+	OGMA_REG_NRM_TX_DESC_START,
+	OGMA_REG_NRM_RX_DESC_START,
+};
+
+static int napi_weight = 64;
+unsigned short pause_time = 256;
+
+#define WAIT_FW_RDY_TIMEOUT 50
+
+static int ogma_wait_for_ring_config_ready(struct ogma_priv *priv, int ring)
+{
+	int timeout = WAIT_FW_RDY_TIMEOUT;
+
+	while (--timeout && (ogma_read_reg(priv, desc_ads[ring]) &
+			       (1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP)))
+		usleep_range(1000, 2000);
+
+	if (!timeout) {
+		netif_err(priv, hw, priv->net_device,
+			  "%s: timeout\n", __func__);
+		return -ETIME;
+	}
+
+	return 0;
+}
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
+static int ogma_configure_normal_mode(struct ogma_priv *priv)
+{
+	int ret = 0;
+	u32 value;
+
+	/* save scb set value  */
+	priv->scb_set_normal_tx_paddr = ogma_read_reg(priv,
+			ogma_desc_start_reg_addr[OGMA_RING_TX]);
+
+	/* set desc_start addr */
+	ogma_write_reg(priv, ogma_desc_start_reg_addr[OGMA_RING_RX],
+		       priv->desc_ring[OGMA_RING_RX].desc_phys);
+
+	ogma_write_reg(priv, ogma_desc_start_reg_addr[OGMA_RING_TX],
+		       priv->desc_ring[OGMA_RING_TX].desc_phys);
+
+	/* set normal tx desc ring config */
+	value = 0 << OGMA_REG_DESC_TMR_MODE |
+		(cpu_to_le32(1) == 1) << OGMA_REG_DESC_ENDIAN |
+		1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+	ogma_write_reg(priv, desc_ads[OGMA_RING_TX], value);
+
+	value = 0 << OGMA_REG_DESC_TMR_MODE |
+		(cpu_to_le32(1) == 1) << OGMA_REG_DESC_ENDIAN |
+		1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+	ogma_write_reg(priv, desc_ads[OGMA_RING_RX], value);
+
+	if (ogma_wait_for_ring_config_ready(priv, OGMA_RING_TX) ||
+	    ogma_wait_for_ring_config_ready(priv, OGMA_RING_RX))
+		return -ETIME;
+
+	return ret;
+}
+
+int ogma_change_mode_to_normal(struct ogma_priv *priv)
+{
+	u32 value;
+
+	priv->scb_pkt_ctrl_reg = ogma_read_reg(priv, OGMA_REG_PKT_CTRL);
+
+	value = ogma_calc_pkt_ctrl_reg_param(&priv->param.pkt_ctrlaram);
+
+	if (priv->param.use_jumbo_pkt_flag)
+		value |= OGMA_PKT_CTRL_REG_EN_JUMBO;
+
+	value |= OGMA_PKT_CTRL_REG_MODE_NRM;
+
+	/* change to normal mode */
+	ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL, MH_CTRL__MODE_TRANS);
+	ogma_write_reg(priv, OGMA_REG_PKT_CTRL, value);
+
+	/* Wait Change mode Complete */
+	usleep_range(2000, 10000);
+
+	return 0;
+}
+
+int ogma_change_mode_to_taiki(struct ogma_priv *priv)
+{
+	int ret = 0;
+	u32 value;
+
+	ogma_write_reg(priv, ogma_desc_start_reg_addr[OGMA_RING_TX],
+		       priv->scb_set_normal_tx_paddr);
+
+	value = 1 << OGMA_REG_DESC_RING_CONFIG_CFG_UP |
+		1 << OGMA_REG_DESC_RING_CONFIG_CH_RST;
+
+	ogma_write_reg(priv, desc_ads[OGMA_RING_TX], value);
+
+	if (ogma_wait_for_ring_config_ready(priv, OGMA_RING_TX))
+		return -ETIME;
+
+	ogma_write_reg(priv, OGMA_REG_DMA_MH_CTRL,
+		       MH_CTRL__MODE_TRANS);
+
+	ogma_write_reg(priv, OGMA_REG_PKT_CTRL, priv->scb_pkt_ctrl_reg);
+
+	/* Wait Change mode Complete */
+	usleep_range(2000, 10000);
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
+	int err;
+
+	err = ogma_configure_normal_mode(priv);
+	if (err) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: normal conf fail\n", __func__);
+		return err;
+	}
+	err = ogma_change_mode_to_normal(priv);
+	if (err) {
+		netif_err(priv, drv, priv->net_device,
+			  "%s: normal set fail\n", __func__);
+		return err;
+	}
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
+		netif_err(priv, drv, priv->net_device,
+			  "%s: taiki set fail\n", __func__);
+		return ret;
+	}
+
+	/* Clear mode change complete IRQ */
+	ret = ogma_clear_modechange_irq(priv, OGMA_MODE_TRANS_COMP_IRQ_T2N |
+					OGMA_MODE_TRANS_COMP_IRQ_N2T);
+
+	if (ret)
+		netif_err(priv, drv, priv->net_device,
+			  "%s: clear mode fail\n", __func__);
+
+	return ret;
+}
+
+static irqreturn_t ogma_irq_handler(int irq, void *dev_id)
+{
+	struct ogma_priv *priv = dev_id;
+	u32 status;
+
+	dev_dbg(priv->dev, "%s\n", __func__);
+
+	status = ogma_read_reg(priv, OGMA_REG_TOP_STATUS) &
+			ogma_read_reg(priv, OGMA_REG_TOP_INTEN);
+
+	if (!status)
+		return IRQ_NONE;
+
+	if ((status & (OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX))) {
+		ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR,
+			       OGMA_TOP_IRQ_REG_NRM_TX |
+			       OGMA_TOP_IRQ_REG_NRM_RX);
+		napi_schedule(&priv->napi);
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
+	/* Set initial value */
+	ogma_write_reg(priv, OGMA_REG_CLK_EN, 0);
+}
+
+static int ogma_probe(struct platform_device *pdev)
+{
+	struct net_device *net_device;
+	struct ogma_priv *priv;
+	struct resource *res;
+	u32 scb_irq_temp;
+	const u8 *mac;
+	const u32 *p;
+	u32 hw_ver;
+	int err, i;
+	int ret;
+
+	net_device = alloc_etherdev(sizeof(*priv));
+	if (!net_device)
+		return -ENOMEM;
+
+	priv = netdev_priv(net_device);
+	priv->net_device = net_device;
+	SET_NETDEV_DEV(priv->net_device, &pdev->dev);
+	platform_set_drvdata(pdev, priv);
+	priv->dev = &pdev->dev;
+
+	priv->msg_enable = NETIF_MSG_TX_ERR | NETIF_MSG_HW | NETIF_MSG_DRV |
+			   NETIF_MSG_LINK;
+
+	priv->phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
+	if (!priv->phy_np) {
+		netif_err(priv, probe, priv->net_device,
+			  "missing phy in DT\n");
+		goto err1;
+	}
+
+	mac = of_get_mac_address(pdev->dev.of_node);
+	if (mac)
+		ether_addr_copy(priv->net_device->dev_addr, mac);
+
+	priv->phy_interface = of_get_phy_mode(pdev->dev.of_node);
+	if (priv->phy_interface < 0) {
+		netif_err(priv, probe, priv->net_device,
+			  "%s: bad phy-if\n", __func__);
+		goto err1;
+	}
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		netif_err(priv, probe, priv->net_device,
+			  "Missing base resource\n");
+		goto err1;
+	}
+
+	priv->ioaddr = ioremap_nocache(res->start, res->end - res->start + 1);
+	if (!priv->ioaddr) {
+		netif_err(priv, probe, priv->net_device,
+			  "ioremap_nocache() failed\n");
+		err = -EINVAL;
+		goto err1;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		netif_err(priv, probe, priv->net_device,
+			  "Missing rdlar resource\n");
+		goto err1;
+	}
+	priv->rdlar_pa = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	if (!res) {
+		netif_err(priv, probe, priv->net_device,
+			  "Missing tdlar resource\n");
+		goto err1;
+	}
+	priv->tdlar_pa = res->start;
+
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (!res) {
+		netif_err(priv, probe, priv->net_device,
+			  "Missing IRQ resource\n");
+		goto err2;
+	}
+	priv->net_device->irq = res->start;
+	err = request_irq(priv->net_device->irq, ogma_irq_handler,
+			  IRQF_SHARED, "ogma", priv);
+	if (err) {
+		netif_err(priv, probe, priv->net_device,
+			  "request_irq() failed\n");
+		goto err2;
+	}
+	disable_irq(priv->net_device->irq);
+
+	pdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+	pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
+
+	while (priv->clock_count < ARRAY_SIZE(priv->clk)) {
+		priv->clk[priv->clock_count] =
+			of_clk_get(pdev->dev.of_node, priv->clock_count);
+		if (IS_ERR(priv->clk[priv->clock_count])) {
+			if (!priv->clock_count) {
+				netif_err(priv, probe, priv->net_device,
+					  "Failed to get clock\n");
+				goto err3;
+			}
+			break;
+		}
+		priv->clock_count++;
+	}
+
+	/* disable by default */
+	priv->et_coalesce.rx_coalesce_usecs = 0;
+	priv->et_coalesce.rx_max_coalesced_frames = 1;
+	priv->et_coalesce.tx_coalesce_usecs = 0;
+	priv->et_coalesce.tx_max_coalesced_frames = 1;
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
+			netif_err(priv, probe, priv->net_device,
+				  "%s: alloc ring failed\n", __func__);
+			goto err3b;
+		}
+	}
+
+	ret = ogma_setup_rx_desc(priv, &priv->desc_ring[OGMA_RING_RX]);
+	if (ret) {
+		netif_err(priv, probe, priv->net_device,
+			  "%s: fail setup ring\n", __func__);
+		goto err3b;
+	}
+
+	netif_info(priv, probe, priv->net_device,
+		   "IP version: 0x%08x\n", hw_ver);
+
+	priv->gmac_mode.flow_start_th = OGMA_FLOW_CONTROL_START_THRESHOLD;
+	priv->gmac_mode.flow_stop_th = OGMA_FLOW_CONTROL_STOP_THRESHOLD;
+	priv->gmac_mode.pause_time = pause_time;
+	priv->gmac_hz = clk_get_rate(priv->clk[0]);
+
+	priv->gmac_mode.half_duplex_flag = 0;
+	priv->gmac_mode.flow_ctrl_enable_flag = 0;
+
+	scb_irq_temp = ogma_read_reg(priv, OGMA_REG_TOP_INTEN);
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR, scb_irq_temp);
+
+	ret = ogma_hw_configure_to_normal(priv);
+	if (ret) {
+		netif_err(priv, probe, priv->net_device,
+			  "%s: normal fail %d\n", __func__, ret);
+		goto err3b;
+	}
+
+	netif_napi_add(priv->net_device, &priv->napi, ogma_netdev_napi_poll,
+		       napi_weight);
+
+	net_device->netdev_ops = &ogma_netdev_ops;
+	net_device->ethtool_ops = &ogma_ethtool_ops;
+	net_device->features = NETIF_F_SG | NETIF_F_IP_CSUM |
+			       NETIF_F_IPV6_CSUM | NETIF_F_TSO |
+			       NETIF_F_TSO6 | NETIF_F_GSO |
+			       NETIF_F_HIGHDMA | NETIF_F_RXCSUM;
+	priv->net_device->hw_features = priv->net_device->features;
+
+	priv->rx_cksum_offload_flag = 1;
+	spin_lock_init(&priv->tx_queue_lock);
+
+	err = ogma_mii_register(priv);
+	if (err) {
+		netif_err(priv, probe, priv->net_device,
+			  "mii bus registration failed %d\n", err);
+		goto err3c;
+	}
+
+	err = register_netdev(priv->net_device);
+	if (err) {
+		netif_err(priv, probe, priv->net_device,
+			  "register_netdev() failed\n");
+		goto err4;
+	}
+
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_SET,
+		       OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
+
+	netif_info(priv, probe, priv->net_device,
+		   "%s initialized\n", priv->net_device->name);
+
+	pm_runtime_mark_last_busy(&pdev->dev);
+	pm_runtime_put_autosuspend(&pdev->dev);
+
+	return 0;
+
+err4:
+	ogma_mii_register(priv);
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
+	free_irq(priv->net_device->irq, priv);
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
+	u32 timeout = 1000000;
+
+	pm_runtime_get_sync(&pdev->dev);
+
+	ogma_write_reg(priv, OGMA_REG_TOP_INTEN_CLR,
+		       OGMA_TOP_IRQ_REG_NRM_TX | OGMA_TOP_IRQ_REG_NRM_RX);
+	BUG_ON(ogma_hw_configure_to_taiki(priv));
+
+	phy_write(priv->phydev, 0, phy_read(priv->phydev, 0) | (1 << 15));
+	while (--timeout && (phy_read(priv->phydev, 0)) & (1 << 15))
+		;
+	if (!timeout)
+		netif_err(priv, drv, priv->net_device,
+			  "%s: timeout stopping PHY", __func__);
+
+	unregister_netdev(priv->net_device);
+	free_irq(priv->net_device->irq, priv);
+	free_netdev(priv->net_device);
+	priv->net_device = NULL;
+
+	ogma_mii_unregister(priv);
+	ogma_terminate(priv);
+
+	pm_runtime_put_sync_suspend(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
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
+	netif_dbg(priv, drv, priv->net_device, "%s\n", __func__);
+
+	disable_irq(priv->net_device->irq);
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
+	netif_dbg(priv, drv, priv->net_device, "%s\n", __func__);
+
+	/* first let the clocks back on */
+
+	for (n = 0; n < priv->clock_count; n++)
+		clk_prepare_enable(priv->clk[n]);
+
+	ogma_write_reg(priv, OGMA_REG_CLK_EN, OGMA_CLK_EN_REG_DOM_D |
+			OGMA_CLK_EN_REG_DOM_C | OGMA_CLK_EN_REG_DOM_G);
+
+	enable_irq(priv->net_device->irq);
+
+	return 0;
+}
+#endif
+
+static int ogma_pm_suspend(struct device *dev)
+{
+	struct ogma_priv *priv = dev_get_drvdata(dev);
+
+	netif_dbg(priv, drv, priv->net_device, "%s\n", __func__);
+
+	if (pm_runtime_status_suspended(dev))
+		return 0;
+
+	return ogma_runtime_suspend(dev);
+}
+
+static int ogma_pm_resume(struct device *dev)
+{
+	struct ogma_priv *priv = dev_get_drvdata(dev);
+
+	netif_dbg(priv, drv, priv->net_device, "%s\n", __func__);
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
+module_platform_driver(ogma_driver);
+
+MODULE_AUTHOR("Fujitsu Semiconductor Ltd");
+MODULE_DESCRIPTION("OGMA Ethernet driver");
+MODULE_LICENSE("GPL");
+
+MODULE_ALIAS("platform:ogma");
