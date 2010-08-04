From: Sachin Sanap <ssanap@marvell.com>
Subject: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Wed, 4 Aug 2010 16:17:50 +0530
Message-ID: <20100804104750.GA9652@pe-dt013.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akarkare@marvell.com, sarnaik@marvell.com, eric.y.miao@gmail.com,
	prakity@marvell.com, markb@marvell.com, ssanap@marvell.com
To: netdev@vger.kernel.org, buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia2.marvell.com ([65.219.4.35]:47271 "EHLO
	dakia2.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227Ab0HDGTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 02:19:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for PXA168 Fast Ethernet on Aspenite
board. Patch generated against Linux 2.6.35-rc5
commit cd5b8f8755a89a57fc8c408d284b8b613f090345

Signed-off-by: Sachin Sanap <ssanap@marvell.com>
---
 arch/arm/mach-mmp/include/mach/pxa168_eth.h |   18 +
 drivers/net/Kconfig                         |   10 +
 drivers/net/Makefile                        |    1 +
 drivers/net/pxa168_eth.c                    | 1723 +++++++++++++++++++++++++++
 4 files changed, 1752 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-mmp/include/mach/pxa168_eth.h
 create mode 100644 drivers/net/pxa168_eth.c

diff --git a/arch/arm/mach-mmp/include/mach/pxa168_eth.h b/arch/arm/mach-mmp/include/mach/pxa168_eth.h
new file mode 100644
index 0000000..abfd335
--- /dev/null
+++ b/arch/arm/mach-mmp/include/mach/pxa168_eth.h
@@ -0,0 +1,18 @@
+/*
+ *pxa168 ethernet platform device data definition file.
+ */
+#ifndef __LINUX_PXA168_ETH_H
+#define __LINUX_PXA168_ETH_H
+
+struct pxa168_eth_platform_data {
+	int	port_number;
+	u16	phy_addr;
+
+	/* If speed is 0, then speed and duplex are autonegotiated. */
+	u32	speed;		/* 0, SPEED_10, SPEED_100 */
+	u32	duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
+
+	int (*init)(void);
+};
+
+#endif /* __LINUX_PXA168_ETH_H */
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ce2fcdd..5ebf287 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -927,6 +927,16 @@ config SMC91X
 	  The module will be called smc91x.  If you want to compile it as a
 	  module, say M here and read <file:Documentation/kbuild/modules.txt>.
 
+config PXA168_ETH
+	tristate "Marvell pxa168 ethernet support"
+	depends on MACH_ASPENITE
+	select PHYLIB
+	help
+	  This driver supports the pxa168 Ethernet ports.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called pxa168_eth.
+
 config NET_NETX
 	tristate "NetX Ethernet support"
 	select MII
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0a0512a..a42d437 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -244,6 +244,7 @@ obj-$(CONFIG_MYRI10GE) += myri10ge/
 obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_SMSC911X) += smsc911x.o
+obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
new file mode 100644
index 0000000..618e558
--- /dev/null
+++ b/drivers/net/pxa168_eth.c
@@ -0,0 +1,1723 @@
+/*
+ * Driver for PXA168 based boards.
+ * Based on MV643XX driver.
+ *
+ * Initial work by
+ * 		Philip Rakity <prakity@marvell.com>
+ *		Mark Brown <markb@marvell.com>
+ *
+ * Copyright (C) 2010 Marvell International Ltd.
+ *		Sachin Sanap <ssanap@marvell.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#include <linux/init.h>
+#include <linux/dma-mapping.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/etherdevice.h>
+#include <linux/bitops.h>
+#include <linux/delay.h>
+#include <linux/ethtool.h>
+#include <linux/platform_device.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/workqueue.h>
+#include <linux/clk.h>
+#include <linux/phy.h>
+#include <linux/io.h>
+#include <linux/types.h>
+#include <asm/pgtable.h>
+#include <asm/system.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <asm/cacheflush.h>
+
+#include <mach/pxa168_eth.h>
+
+#define DRIVER_NAME	"pxa168-mfu"
+#define DRIVER_VERSION	"0.3"
+
+/*
+ * Registers
+ */
+
+#define PHY_ADDRESS		0x0000
+#define SMI			0x0010
+#define PORT_CONFIG		0x0400
+#define PORT_CONFIG_EXT		0x0408
+#define PORT_COMMAND		0x0410
+#define PORT_STATUS		0x0418
+#define HTPR			0x0428
+#define SDMA_CONFIG		0x0440
+#define SDMA_CMD		0x0448
+#define INT_CAUSE		0x0450
+#define INT_W_CLEAR		0x0454
+#define INT_MASK		0x0458
+#define ETH_F_RX_DESC_0		0x0480
+#define ETH_C_RX_DESC_0		0x04A0
+#define ETH_C_TX_DESC_1		0x04E4
+
+/* smi register */
+#define SMI_BUSY		(1<<28)	/* 0 - Write, 1 - Read  */
+#define SMI_R_VALID		(1<<27)	/* 0 - Write, 1 - Read  */
+#define SMI_OP_W		(0<<26)	/* Write operation      */
+#define SMI_OP_R		(1<<26)	/* Read operation */
+
+#define PHY_WAIT_ITERATIONS	500
+
+#define PXA168_ETH_PHY_ADDR_DEFAULT	0
+/* RX & TX descriptor command */
+#define BUF_OWNED_BY_DMA	(1<<31)
+
+/* RX descriptor status */
+#define RX_EN_INT		(1<<23)
+#define RX_FIRST_DESC		(1<<17)
+#define RX_LAST_DESC		(1<<16)
+#define RX_ERROR		(1<<15)
+
+/* TX descriptor command */
+#define TX_EN_INT		(1<<23)
+#define TX_GEN_CRC		(1<<22)
+#define TX_ZERO_PADDING		(1<<18)
+#define TX_FIRST_DESC		(1<<17)
+#define TX_LAST_DESC		(1<<16)
+#define TX_ERROR		(1<<15)
+
+/* SDMA_CMD */
+#define SDMA_CMD_AT		(1<<31)
+#define SDMA_CMD_TXDL		(1<<24)
+#define SDMA_CMD_TXDH		(1<<23)
+#define SDMA_CMD_AR		(1<<15)
+#define SDMA_CMD_ERD		(1<<7)
+
+/* Bit definitions of the Port Config Reg */
+#define PCR_HS			(1<<12)
+#define PCR_EN			(1<<7)
+#define PCR_PM			(1<<0)
+
+/* Bit definitions of the Port Config Extend Reg */
+#define PCXR_2BSM		(1<<28)
+#define PCXR_DSCP_EN		(1<<21)
+#define PCXR_MFL_1518		(0<<14)
+#define PCXR_MFL_1536		(1<<14)
+#define PCXR_MFL_2048		(2<<14)
+#define PCXR_MFL_64K		(3<<14)
+#define PCXR_FLP		(1<<11)
+#define PCXR_PRIO_TX_OFF	3
+#define PCXR_TX_HIGH_PRI	(7<<PCXR_PRIO_TX_OFF)
+
+/* Bit definitions of the SDMA Config Reg */
+#define SDCR_BSZ_OFF		12
+#define SDCR_BSZ8		(3<<SDCR_BSZ_OFF)
+#define SDCR_BSZ4		(2<<SDCR_BSZ_OFF)
+#define SDCR_BSZ2		(1<<SDCR_BSZ_OFF)
+#define SDCR_BSZ1		(0<<SDCR_BSZ_OFF)
+#define SDCR_BLMR		(1<<6)
+#define SDCR_BLMT		(1<<7)
+#define SDCR_RIFB		(1<<9)
+#define SDCR_RC_OFF		2
+#define SDCR_RC_MAX_RETRANS	(0xf << SDCR_RC_OFF)
+
+/*
+ * Bit definitions of the Interrupt Cause Reg
+ * and Interrupt MASK Reg is the same
+ */
+#define ICR_RXBUF		(1<<0)
+#define ICR_TXBUF_H		(1<<2)
+#define ICR_TXBUF_L		(1<<3)
+#define ICR_TXEND_H		(1<<6)
+#define ICR_TXEND_L		(1<<7)
+#define ICR_RXERR		(1<<8)
+#define ICR_TXERR_H		(1<<10)
+#define ICR_TXERR_L		(1<<11)
+#define ICR_TX_UDR		(1<<13)
+#define ICR_MII_CH		(1<<28)
+
+#define ALL_INTS (ICR_TXBUF_H  | ICR_TXBUF_L  | ICR_TX_UDR |\
+				ICR_TXERR_H  | ICR_TXERR_L |\
+				ICR_TXEND_H  | ICR_TXEND_L |\
+				ICR_RXBUF | ICR_RXERR  | ICR_MII_CH)
+
+#define ETH_HW_IP_ALIGN		2	/* hw aligns IP header */
+#define ETH_EXTRA_HEADER	(6+6+2+4) /* dest+src addr+protocol id+crc */
+#define ETH_DATA_LEN		1500
+#define MAX_PKT_SIZE		1518
+
+#define NUM_RX_DESCS		64
+#define NUM_TX_DESCS		64
+#define MAX_DESCS_PER_HIGH	(60)
+#define TX_DESC_COUNT_LOW	(10)
+
+#define HASH_ADD		0
+#define HASH_DELETE		1
+#define HASH_ADDR_TABLE_SIZE	0x4000	/* 16K (1/2K address - PCR_HS == 1) */
+#define HOP_NUMBER		12
+
+/* Bit definitions for Port status */
+#define PORT_SPEED_100		(1<<0)
+#define FULL_DUPLEX		(1<<1)
+#define FLOW_CONTROL_ENABLED	(1<<2)
+#define LINK_UP			(1<<3)
+
+/* Bit definitions for work to be done */
+#define WORK_LINK		(1<<0)
+#define WORK_TX_DONE		(1<<1)
+
+#define TX_DONE_INTERVAL	30
+
+struct rx_desc {
+	u32 cmd_sts;		/* Descriptor command status            */
+	u16 byte_cnt;		/* Descriptor buffer byte count         */
+	u16 buf_size;		/* Buffer size                          */
+	u32 buf_ptr;		/* Descriptor buffer pointer            */
+	u32 next_desc_ptr;	/* Next descriptor pointer              */
+};
+
+struct tx_desc {
+	u32 cmd_sts;		/* Command/status field                 */
+	u16 reserved;
+	u16 byte_cnt;		/* buffer byte count                    */
+	u32 buf_ptr;		/* pointer to buffer for this descriptor */
+	u32 next_desc_ptr;	/* Pointer to next descriptor           */
+};
+
+struct pxa168_private {
+	int port_num;		/* User Ethernet port number    */
+
+	int rx_resource_err;	/* Rx ring resource error flag */
+
+	/* Next available and first returning Rx resource */
+	int rx_curr_desc_q, rx_used_desc_q;
+
+	/* Next available and first returning Tx resource */
+	int tx_curr_desc_q, tx_used_desc_q;
+
+	struct rx_desc *p_rx_desc_area;
+	dma_addr_t rx_desc_dma;
+	int rx_desc_area_size;
+	struct sk_buff **rx_skb;
+
+	struct tx_desc *p_tx_desc_area;
+	dma_addr_t tx_desc_dma;
+	int tx_desc_area_size;
+	struct sk_buff **tx_skb;
+
+	struct work_struct tx_timeout_task;
+
+	struct net_device *dev;
+	struct napi_struct napi;
+	u8 work_todo;
+
+	struct net_device_stats stats;
+	/* Size of Tx Ring per queue */
+	int tx_ring_size;
+	/* Number of tx descriptors in use */
+	int tx_desc_count;
+	/* Size of Rx Ring per queue */
+	int rx_ring_size;
+	/* Number of rx descriptors in use */
+	int rx_desc_count;
+
+	/*
+	 * Used in case RX Ring is empty, which can be caused when
+	 * system does not have resources (skb's)
+	 */
+	struct timer_list timeout;
+	struct mii_bus *smi_bus;
+	struct phy_device *phy;
+
+	/* clock */
+	struct clk *clk;
+	struct pxa168_eth_platform_data *pd;
+	/*
+	 * Ethernet controller base address.
+	 */
+	void __iomem *base;
+
+	u8 *htpr;		/* hash pointer */
+	dma_addr_t htpr_dma;
+};
+
+struct addr_table_entry {
+	u32 lo;
+	u32 hi;
+};
+
+/* Bit fields of a Hash Table Entry */
+enum hash_table_entry {
+	HASH_ENTRY_VALID = 1,
+	SKIP = 2,
+	HASH_ENTRY_RECEIVE_DISCARD = 4,
+	HASH_ENTRY_RECEIVE_DISCARD_BIT = 2
+};
+
+static int pxa168_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int pxa168_set_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int pxa168_init_hw(struct pxa168_private *mp);
+static void eth_port_reset(struct net_device *dev);
+static void eth_port_start(struct net_device *dev);
+static int pxa168_eth_open(struct net_device *dev);
+static int pxa168_eth_stop(struct net_device *dev);
+static int ethernet_phy_setup(struct net_device *dev);
+
+static char marvell_OUI[3] = { 0x02, 0x50, 0x43 };
+
+static inline u32 rdl(struct pxa168_private *mp, int offset)
+{
+	return readl(mp->base + offset);
+}
+
+static inline void wrl(struct pxa168_private *mp, int offset, u32 data)
+{
+	writel(data, mp->base + offset);
+}
+
+static void abort_dma(struct pxa168_private *mp)
+{
+	int delay;
+	int max_retries = 40;
+
+	do {
+		wrl(mp, SDMA_CMD, SDMA_CMD_AR | SDMA_CMD_AT);
+		udelay(100);
+
+		delay = 10;
+		while ((rdl(mp, SDMA_CMD) & (SDMA_CMD_AR | SDMA_CMD_AT))
+		       && delay-- > 0) {
+			udelay(10);
+		}
+	} while (max_retries-- > 0 && delay <= 0);
+
+	if (max_retries <= 0)
+		printk(KERN_ERR "%s : DMA Stuck\n", __func__);
+}
+
+static int ethernet_phy_get(struct pxa168_private *mp)
+{
+	unsigned int reg_data;
+
+	/* only support 3 ports */
+	BUG_ON(mp->port_num > 2);
+
+	reg_data = rdl(mp, PHY_ADDRESS);
+
+	return (reg_data >> (5 * mp->port_num)) & 0x1f;
+}
+
+static void ethernet_phy_set_addr(struct pxa168_private *mp, int phy_addr)
+{
+	u32 reg_data;
+	int addr_shift = 5 * mp->port_num;
+
+	/* only support 3 ports */
+	BUG_ON(mp->port_num > 2);
+
+	reg_data = rdl(mp, PHY_ADDRESS);
+	reg_data &= ~(0x1f << addr_shift);
+	reg_data |= (phy_addr & 0x1f) << addr_shift;
+	wrl(mp, PHY_ADDRESS, reg_data);
+}
+static void ethernet_phy_reset(struct pxa168_private *mp)
+{
+	int data;
+
+	data = phy_read(mp->phy, MII_BMCR);
+	if (data < 0)
+		return;
+
+	data |= BMCR_RESET;
+	if (phy_write(mp->phy, MII_BMCR, data) < 0)
+		return;
+
+	do {
+		data = phy_read(mp->phy, MII_BMCR);
+	} while (data >= 0 && data & BMCR_RESET);
+
+}
+
+static void rxq_refill(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct sk_buff *skb;
+	struct rx_desc *p_used_rx_desc;
+	int used_rx_desc;
+
+	while (mp->rx_desc_count < mp->rx_ring_size) {
+
+		skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN);
+		if (!skb)
+			break;
+
+		mp->rx_desc_count++;
+
+		/* Get 'used' Rx descriptor */
+		used_rx_desc = mp->rx_used_desc_q;
+		p_used_rx_desc = &mp->p_rx_desc_area[used_rx_desc];
+
+		p_used_rx_desc->buf_ptr = dma_map_single(NULL,
+							 skb->data,
+							 MAX_PKT_SIZE +
+							 ETH_HW_IP_ALIGN,
+							 DMA_FROM_DEVICE);
+
+		p_used_rx_desc->buf_size = MAX_PKT_SIZE + ETH_HW_IP_ALIGN;
+		mp->rx_skb[used_rx_desc] = skb;
+
+		/* Return the descriptor to DMA ownership */
+		wmb();
+		p_used_rx_desc->cmd_sts = BUF_OWNED_BY_DMA | RX_EN_INT;
+		wmb();
+
+		/* Move the used descriptor pointer to the next descriptor */
+		mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
+
+		/* Any Rx return cancels the Rx resource error status */
+		mp->rx_resource_err = 0;
+
+		skb_reserve(skb, ETH_HW_IP_ALIGN);
+	}
+
+	/*
+	 * If RX ring is empty of SKB, set a timer to try allocating
+	 * again at a later time.
+	 */
+	if (mp->rx_desc_count == 0) {
+		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
+		mp->timeout.expires = jiffies + (HZ / 10);	/* 100 mSec */
+		add_timer(&mp->timeout);
+	}
+}
+
+static inline void rxq_refill_timer_wrapper(unsigned long data)
+{
+	struct pxa168_private *mp = (void *)data;
+	napi_schedule(&mp->napi);
+}
+
+static inline u32 nibble_swapping_32_bit(u32 x)
+{
+	return (((x) & 0xf0f0f0f0) >> 4) | (((x) & 0x0f0f0f0f) << 4);
+}
+
+static inline u32 nibble_swapping_16_bit(u32 x)
+{
+	return (((x) & 0x0000f0f0) >> 4) | (((x) & 0x00000f0f) << 4);
+}
+
+static inline u32 flip_4_bits(u32 x)
+{
+	return (((x) & 0x01) << 3) | (((x) & 0x002) << 1)
+	    | (((x) & 0x04) >> 1) | (((x) & 0x008) >> 3);
+}
+
+/*
+ * ----------------------------------------------------------------------------
+ * This function will calculate the hash function of the address.
+ * depends on the hash mode and hash size.
+ * Inputs
+ * mac_high             - the 2 most significant bytes of the MAC address.
+ * mac_low             - the 4 least significant bytes of the MAC address.
+ * Outputs
+ * return the calculated entry.
+ */
+static u32 hash_function(u32 mac_high, u32 mac_low)
+{
+	u32 hash_result;
+	u32 addr_high;
+	u32 addr_low;
+	u32 addr0;
+	u32 addr1;
+	u32 addr2;
+	u32 addr3;
+	u32 addr_high_swapped;
+	u32 addr_low_swapped;
+
+	addr_high = nibble_swapping_16_bit(mac_high);
+	addr_low = nibble_swapping_32_bit(mac_low);
+
+	addr_high_swapped = flip_4_bits(addr_high & 0xf)
+	    + ((flip_4_bits((addr_high >> 4) & 0xf)) << 4)
+	    + ((flip_4_bits((addr_high >> 8) & 0xf)) << 8)
+	    + ((flip_4_bits((addr_high >> 12) & 0xf)) << 12);
+
+	addr_low_swapped = flip_4_bits(addr_low & 0xf)
+	    + ((flip_4_bits((addr_low >> 4) & 0xf)) << 4)
+	    + ((flip_4_bits((addr_low >> 8) & 0xf)) << 8)
+	    + ((flip_4_bits((addr_low >> 12) & 0xf)) << 12)
+	    + ((flip_4_bits((addr_low >> 16) & 0xf)) << 16)
+	    + ((flip_4_bits((addr_low >> 20) & 0xf)) << 20)
+	    + ((flip_4_bits((addr_low >> 24) & 0xf)) << 24)
+	    + ((flip_4_bits((addr_low >> 28) & 0xf)) << 28);
+
+	addr_high = addr_high_swapped;
+	addr_low = addr_low_swapped;
+
+	addr0 = (addr_low >> 2) & 0x03f;
+	addr1 = (addr_low & 0x003) | ((addr_low >> 8) & 0x7f) << 2;
+	addr2 = (addr_low >> 15) & 0x1ff;
+	addr3 = ((addr_low >> 24) & 0x0ff) | ((addr_high & 1) << 8);
+
+	hash_result = (addr0 << 9) | (addr1 ^ addr2 ^ addr3);
+	hash_result = hash_result & 0x07ff;
+	return hash_result;
+}
+
+/*
+ * ----------------------------------------------------------------------------
+ * This function will add an entry to the address table.
+ * depends on the hash mode and hash size that was initialized.
+ * Inputs
+ * mp - ETHERNET .
+ * mac_high - the 2 most significant bytes of the MAC address.
+ * mac_low - the 4 least significant bytes of the MAC address.
+ * skip - if 1, skip this address.
+ * rd   - the RD field in the address table.
+ * Outputs
+ * address table entry is added.
+ * 0 if success.
+ * -ENOSPC if table full
+ */
+static int add_del_hash_entry(struct pxa168_private *mp, u32 mac_high,
+			      u32 mac_low, u32 rd, u32 skip, int del)
+{
+	struct addr_table_entry *entry, *start;
+	u32 new_high;
+	u32 new_low;
+	u32 i;
+
+	new_low = (((mac_high >> 4) & 0xf) << 15)
+	    | (((mac_high >> 0) & 0xf) << 11)
+	    | (((mac_high >> 12) & 0xf) << 7)
+	    | (((mac_high >> 8) & 0xf) << 3)
+	    | (((mac_low >> 20) & 0x1) << 31)
+	    | (((mac_low >> 16) & 0xf) << 27)
+	    | (((mac_low >> 28) & 0xf) << 23)
+	    | (((mac_low >> 24) & 0xf) << 19)
+	    | (skip << SKIP) | (rd << HASH_ENTRY_RECEIVE_DISCARD_BIT)
+	    | HASH_ENTRY_VALID;
+
+	new_high = (((mac_low >> 4) & 0xf) << 15)
+	    | (((mac_low >> 0) & 0xf) << 11)
+	    | (((mac_low >> 12) & 0xf) << 7)
+	    | (((mac_low >> 8) & 0xf) << 3)
+	    | (((mac_low >> 21) & 0x7) << 0);
+
+	/*
+	 * Pick the appropriate table, start scanning for free/reusable
+	 * entries at the index obtained by hashing the specified MAC address
+	 */
+	start = (struct addr_table_entry *)(mp->htpr);
+	entry = start + hash_function(mac_high, mac_low);
+	for (i = 0; i < HOP_NUMBER; i++) {
+		if (!(entry->lo & HASH_ENTRY_VALID)) {
+			break;
+		} else {
+			/* if same address put in same position */
+			if (((entry->lo & 0xfffffff8) == (new_low & 0xfffffff8))
+			    && (entry->hi == new_high)) {
+				break;
+			}
+		}
+		if (entry == start + 0x7ff)
+			entry = start;
+		else
+			entry++;
+	}
+
+	if (((entry->lo & 0xfffffff8) != (new_low & 0xfffffff8)) &&
+	    (entry->hi != new_high) && del)
+		return 0;
+
+	if (i == HOP_NUMBER) {
+		if (!del) {
+			printk(KERN_INFO "%s: table section is full\n",
+			       __FILE__);
+			return -ENOSPC;
+		} else
+			return 0;
+	}
+
+	/*
+	 * Update the selected entry
+	 */
+	if (del) {
+		entry->hi = 0;
+		entry->lo = 0;
+	} else {
+		entry->hi = new_high;
+		entry->lo = new_low;
+	}
+
+	return 0;
+}
+
+/*
+ * ----------------------------------------------------------------------------
+ *  Create an addressTable entry from MAC address info
+ *  found in the specifed net_device struct
+ *
+ *  Input : pointer to ethernet interface network device structure
+ *  Output : N/A
+ */
+static void update_hash_table_mac_address(struct pxa168_private *mp,
+					  u8 *oaddr, u8 *addr)
+{
+	u32 mac_high;
+	u32 mac_low;
+
+	/* Delete old entry */
+	if (oaddr) {
+		mac_high = (oaddr[0] << 8) | oaddr[1];
+		mac_low = (oaddr[2] << 24) | (oaddr[3] << 16) |
+		    (oaddr[4] << 8) | oaddr[5];
+		add_del_hash_entry(mp, mac_high, mac_low, 1, 0, HASH_DELETE);
+	}
+
+	/* Add new entry */
+	mac_high = (addr[0] << 8) | addr[1];
+	mac_low = (addr[2] << 24) | (addr[3] << 16) | (addr[4] << 8) | addr[5];
+	add_del_hash_entry(mp, mac_high, mac_low, 1, 0, HASH_ADD);
+}
+
+static int init_hashtable(struct pxa168_private *mp)
+{
+	u8 *addr;
+	dma_addr_t reg_dma;
+
+	if (mp->htpr == NULL) {
+		mp->htpr = dma_alloc_coherent(NULL,
+					      HASH_ADDR_TABLE_SIZE + 7,
+					      &mp->htpr_dma, GFP_KERNEL);
+		if (mp->htpr == NULL)
+			return -ENOMEM;
+	}
+
+	/* align to 8 byte boundary */
+	addr = (u8 *) (((u32) mp->htpr + 7) & ~0x7);
+	reg_dma = (dma_addr_t) (((u32) mp->htpr_dma + 7) & ~0x7);
+
+	memset(addr, 0, HASH_ADDR_TABLE_SIZE);
+
+	wrl(mp, HTPR, reg_dma);
+	return 0;
+}
+
+static void pxa168_eth_set_rx_mode(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct netdev_hw_addr *ha;
+	u32 val;
+
+	val = rdl(mp, PORT_CONFIG);
+	if (dev->flags & IFF_PROMISC)
+		val |= PCR_PM;
+	else
+		val &= ~PCR_PM;
+	wrl(mp, PORT_CONFIG, val);
+
+	netdev_for_each_mc_addr(ha, dev)
+	    update_hash_table_mac_address(mp, NULL, ha->addr);
+}
+
+static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sa = addr;
+	struct pxa168_private *mp = netdev_priv(dev);
+	unsigned char oldMac[ETH_ALEN];
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EINVAL;
+
+	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+
+	netif_addr_lock_bh(dev);
+	update_hash_table_mac_address(mp, oldMac, dev->dev_addr);
+	netif_addr_unlock_bh(dev);
+	return 0;
+}
+
+static void eth_port_start(struct net_device *dev)
+{
+	unsigned int val = 0;
+	struct pxa168_private *mp = netdev_priv(dev);
+	int tx_curr_desc, rx_curr_desc;
+
+	/* Perform PHY reset, if there is a PHY. */
+	if (mp->phy != NULL) {
+		struct ethtool_cmd cmd;
+
+		pxa168_get_settings(mp->dev, &cmd);
+		ethernet_phy_reset(mp);
+		pxa168_set_settings(mp->dev, &cmd);
+	}
+
+	/* Assignment of Tx CTRP of given queue */
+	tx_curr_desc = mp->tx_curr_desc_q;
+	wrl(mp, ETH_C_TX_DESC_1,
+	    (u32) ((struct tx_desc *)mp->tx_desc_dma + tx_curr_desc));
+
+	/* Assignment of Rx CRDP of given queue */
+	rx_curr_desc = mp->rx_curr_desc_q;
+	wrl(mp, ETH_C_RX_DESC_0,
+	    (u32) ((struct rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+
+	wrl(mp, ETH_F_RX_DESC_0,
+	    (u32) ((struct rx_desc *)mp->rx_desc_dma + rx_curr_desc));
+
+	/* Clear all interrupts */
+	wrl(mp, INT_CAUSE, 0);
+
+	/* Enable all interrupts for receive, transmit and error. */
+	wrl(mp, INT_MASK, ALL_INTS);
+
+	val = rdl(mp, PORT_CONFIG);
+	val |= PCR_EN;
+	wrl(mp, PORT_CONFIG, val);
+
+	/* Start RX DMA engine */
+	val = rdl(mp, SDMA_CMD);
+	val |= SDMA_CMD_ERD;
+	wrl(mp, SDMA_CMD, val);
+
+}
+
+static void eth_port_reset(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	unsigned int val = 0;
+
+	/* Stop all interrupts for receive, transmit and error. */
+	wrl(mp, INT_MASK, 0);
+
+	/* Clear all interrupts */
+	wrl(mp, INT_CAUSE, 0);
+
+	/* Stop RX DMA */
+	val = rdl(mp, SDMA_CMD);
+	val &= ~SDMA_CMD_ERD;	/* abort dma command */
+
+	/* Abort any transmit and receive operations and put DMA
+	 * in idle state.
+	 */
+
+	abort_dma(mp);
+
+	/* Disable port */
+	val = rdl(mp, PORT_CONFIG);
+	val &= ~PCR_EN;
+	wrl(mp, PORT_CONFIG, val);
+
+}
+
+/*
+ * txq_reclaim - Free the tx desc data for completed descriptors
+ * If force is non-zero, frees uncompleted descriptors as well
+ */
+static int txq_reclaim(struct net_device *dev, int force)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct tx_desc *desc;
+	u32 cmd_sts;
+	struct sk_buff *skb;
+	int tx_index;
+	dma_addr_t addr;
+	int count;
+	int released = 0;
+
+	netif_tx_lock(dev);
+
+	mp->work_todo &= ~(WORK_TX_DONE);
+	while (mp->tx_desc_count > 0) {
+
+		tx_index = mp->tx_used_desc_q;
+		desc = &mp->p_tx_desc_area[tx_index];
+		cmd_sts = desc->cmd_sts;
+
+		if (!force && (cmd_sts & BUF_OWNED_BY_DMA)) {
+			if (released > 0) {
+				goto txq_reclaim_end;
+			} else {
+				released = -1;
+				goto txq_reclaim_end;
+			}
+		}
+
+		mp->tx_used_desc_q = (tx_index + 1) % mp->tx_ring_size;
+		mp->tx_desc_count--;
+
+		addr = desc->buf_ptr;
+		count = desc->byte_cnt;
+		skb = mp->tx_skb[tx_index];
+		if (skb)
+			mp->tx_skb[tx_index] = NULL;
+
+		if (cmd_sts & TX_ERROR) {
+			if (net_ratelimit())
+				printk(KERN_ERR "%s: Error in TX\n", dev->name);
+			dev->stats.tx_errors++;
+		}
+
+		dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
+
+		if (skb)
+			dev_kfree_skb_irq(skb);
+
+		released++;
+	}
+txq_reclaim_end:
+	netif_tx_unlock(dev);
+	return released;
+}
+
+static void pxa168_eth_tx_timeout(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	printk(KERN_INFO "%s: TX timeout  desc_count %d\n",
+	       dev->name, mp->tx_desc_count);
+
+	schedule_work(&mp->tx_timeout_task);
+}
+
+static void pxa168_eth_tx_timeout_task(struct work_struct *work)
+{
+	struct pxa168_private *mp = container_of(work,
+						 struct pxa168_private,
+						 tx_timeout_task);
+	struct net_device *dev = mp->dev;
+
+	pxa168_eth_stop(dev);
+	pxa168_eth_open(dev);
+}
+
+static int rxq_process(struct net_device *dev, int budget)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	unsigned int received_packets = 0;
+	struct sk_buff *skb;
+
+	while (budget-- > 0) {
+
+		int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
+		struct rx_desc *rx_desc;
+		unsigned int cmd_sts;
+
+		/* Do not process Rx ring in case of Rx ring resource error */
+		if (mp->rx_resource_err)
+			break;
+
+		rx_curr_desc = mp->rx_curr_desc_q;
+		rx_used_desc = mp->rx_used_desc_q;
+
+		rx_desc = &mp->p_rx_desc_area[rx_curr_desc];
+
+		cmd_sts = rx_desc->cmd_sts;
+		rmb();
+
+		if (cmd_sts & (BUF_OWNED_BY_DMA))
+			break;
+
+		skb = mp->rx_skb[rx_curr_desc];
+		mp->rx_skb[rx_curr_desc] = NULL;
+
+		rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
+		mp->rx_curr_desc_q = rx_next_curr_desc;
+
+		/* Rx descriptors exhausted. */
+		/* Set the Rx ring resource error flag */
+		if (rx_next_curr_desc == rx_used_desc)
+			mp->rx_resource_err = 1;
+
+		mp->rx_desc_count--;
+		dma_unmap_single(NULL, rx_desc->buf_ptr,
+				 MAX_PKT_SIZE + ETH_HW_IP_ALIGN,
+				 DMA_FROM_DEVICE);
+		received_packets++;
+
+		/*
+		 * Update statistics.
+		 * Note byte count includes 4 byte CRC count
+		 */
+		stats->rx_packets++;
+		stats->rx_bytes += rx_desc->byte_cnt;
+		/*
+		 * In case received a packet without first / last bits on OR
+		 * the error summary bit is on, the packets needs to be droped.
+		 */
+		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+		     (RX_FIRST_DESC | RX_LAST_DESC))
+		    || (cmd_sts & RX_ERROR)) {
+
+			stats->rx_dropped++;
+			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+			    (RX_FIRST_DESC | RX_LAST_DESC)) {
+				if (net_ratelimit())
+					printk(KERN_ERR
+					       "%s: Rx pkt on multiple desc\n",
+					       dev->name);
+			}
+			if (cmd_sts & RX_ERROR)
+				stats->rx_errors++;
+
+			dev_kfree_skb_irq(skb);
+
+		} else {
+			/*
+			 * The -4 is for the CRC in the trailer of the
+			 * received packet
+			 */
+
+			skb_put(skb, rx_desc->byte_cnt - 4);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_receive_skb(skb);
+		}
+		dev->last_rx = jiffies;
+	}
+
+	rxq_refill(dev);	/* Fill RX ring with skb's */
+
+	return received_packets;
+}
+
+static int pxa168_eth_collect_events(struct pxa168_private *mp,
+				     struct net_device *dev)
+{
+	u32 icr;
+	int ret = 0;
+
+	icr = rdl(mp, INT_CAUSE);
+	if (0x00 == icr)
+		return IRQ_NONE;
+
+	wrl(mp, INT_CAUSE, icr ^ 0xffffffff);
+
+	if (icr & (ICR_TXBUF_H | ICR_TXBUF_L)) {
+		mp->work_todo |= WORK_TX_DONE;
+		ret = 1;
+	}
+	if (icr & ICR_RXBUF)
+		ret = 1;
+
+	if (icr & ICR_MII_CH) {
+		mp->work_todo |= WORK_LINK;
+		ret = 1;
+	}
+
+	return ret;
+}
+
+static void handle_link_event(struct pxa168_private *mp)
+{
+	struct net_device *dev = mp->dev;
+	u32 port_status;
+	int speed;
+	int duplex;
+	int fc;
+
+	port_status = rdl(mp, PORT_STATUS);
+	if (!(port_status & LINK_UP)) {
+		if (netif_carrier_ok(dev)) {
+			printk(KERN_INFO "%s: link down\n", dev->name);
+			netif_carrier_off(dev);
+			txq_reclaim(dev, 1);
+		}
+		return;
+	}
+
+	if (port_status & PORT_SPEED_100)
+		speed = 100;
+	else
+		speed = 10;
+
+	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
+	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
+
+	printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+	       "flow control %sabled\n", dev->name,
+	       speed, duplex ? "full" : "half", fc ? "en" : "dis");
+
+	if (!netif_carrier_ok(dev))
+		netif_carrier_on(dev);
+}
+
+static irqreturn_t pxa168_eth_int_handler(int irq, void *dev_id)
+{
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	if (unlikely(!pxa168_eth_collect_events(mp, dev)))
+		return IRQ_NONE;
+
+	/* Disable interrupts */
+	wrl(mp, INT_MASK, 0);
+	napi_schedule(&mp->napi);
+
+	return IRQ_HANDLED;
+}
+
+static int set_port_config_ext(struct pxa168_private *mp, int mtu)
+{
+	int mtu_size;
+
+	if ((mtu > ETH_DATA_LEN) || (mtu < 64))
+		return -EINVAL;
+
+	mtu_size = PCXR_MFL_1518;
+
+	/* Extended Port Configuration */
+	wrl(mp, PORT_CONFIG_EXT, PCXR_2BSM | /* Two byte suffix aligns IP hdr */
+	    PCXR_DSCP_EN |	/* Enable DSCP in IP */
+	    mtu_size | PCXR_FLP |	/* do not force link pass */
+	    PCXR_TX_HIGH_PRI);	/* Transmit - high priority queue */
+
+	(mp->dev)->mtu = mtu;
+	return 0;
+}
+
+static int pxa168_init_hw(struct pxa168_private *mp)
+{
+	int err = 0;
+
+	/* Disable interrupts */
+	wrl(mp, INT_MASK, 0);
+	wrl(mp, INT_CAUSE, 0);
+
+	/* Write to ICR to clear interrupts. */
+	wrl(mp, INT_W_CLEAR, 0);
+
+	/* Abort any transmit and receive operations and put DMA
+	 * in idle state.
+	 */
+	abort_dma(mp);
+
+	/* Initialize address hash table */
+	err = init_hashtable(mp);
+	if (err)
+		return err;
+
+	/* SDMA configuration */
+	wrl(mp, SDMA_CONFIG, SDCR_BSZ8 |	/* Burst size = 32 bytes */
+	    SDCR_RIFB |		/* Rx interrupt on frame */
+	    SDCR_BLMT |		/* Little endian transmit */
+	    SDCR_BLMR |		/* Little endian receive */
+	    SDCR_RC_MAX_RETRANS);	/* Max retransmit count */
+
+	/* Port Configuration */
+	wrl(mp, PORT_CONFIG, PCR_HS);	/* Hash size is 1/2kb */
+
+	set_port_config_ext(mp, (mp->dev)->mtu);
+
+	return err;
+}
+
+static int rxq_init(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct rx_desc *p_rx_desc;
+	int size = 0, i = 0;
+	int rx_desc_num = mp->rx_ring_size;
+
+	/* Allocate RX skb rings */
+	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb) * mp->rx_ring_size,
+			     GFP_KERNEL);
+	if (!mp->rx_skb) {
+		printk(KERN_ERR "%s: Cannot alloc RX skb ring\n", dev->name);
+		return -ENOMEM;
+	}
+
+	/* Allocate RX ring */
+	mp->rx_desc_count = 0;
+	size = mp->rx_ring_size * sizeof(struct rx_desc);
+	mp->rx_desc_area_size = size;
+
+	mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
+						&mp->rx_desc_dma, GFP_KERNEL);
+	if (!mp->p_rx_desc_area) {
+		printk(KERN_ERR "%s: Cannot alloc RX ring (size %d bytes)\n",
+		       dev->name, size);
+		goto out;
+	}
+	memset((void *)mp->p_rx_desc_area, 0, size);
+
+	/* initialize the next_desc_ptr links in the Rx descriptors ring */
+	p_rx_desc = (struct rx_desc *)mp->p_rx_desc_area;
+	for (i = 0; i < rx_desc_num; i++) {
+		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
+		    ((i + 1) % rx_desc_num) * sizeof(struct rx_desc);
+	}
+
+	/* Save Rx desc pointer to driver struct. */
+	mp->rx_curr_desc_q = 0;
+	mp->rx_used_desc_q = 0;
+
+	mp->rx_desc_area_size = rx_desc_num * sizeof(struct rx_desc);
+
+	return 0;
+
+out:
+	kfree(mp->rx_skb);
+	return -ENOMEM;
+}
+
+static void rxq_deinit(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	int curr;
+
+	/* Free preallocated skb's on RX rings */
+	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
+		if (mp->rx_skb[curr]) {
+			dev_kfree_skb(mp->rx_skb[curr]);
+			mp->rx_desc_count--;
+		}
+	}
+
+	if (mp->rx_desc_count)
+		printk(KERN_ERR
+		       "Error in freeing Rx Ring. %d skb's still\n",
+		       mp->rx_desc_count);
+
+	/* Free RX ring */
+	if (mp->p_rx_desc_area)
+		dma_free_coherent(NULL, mp->rx_desc_area_size,
+				  mp->p_rx_desc_area, mp->rx_desc_dma);
+
+	kfree(mp->rx_skb);
+
+}
+
+static int txq_init(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct tx_desc *p_tx_desc;
+	int size = 0, i = 0;
+	int tx_desc_num = mp->tx_ring_size;
+
+	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
+			     GFP_KERNEL);
+	if (!mp->tx_skb) {
+		printk(KERN_ERR "%s: Cannot alloc TX skb ring\n", dev->name);
+		return -ENOMEM;
+	}
+
+	/* Allocate TX ring */
+	mp->tx_desc_count = 0;
+	size = mp->tx_ring_size * sizeof(struct tx_desc);
+	mp->tx_desc_area_size = size;
+
+	mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
+						&mp->tx_desc_dma, GFP_KERNEL);
+	if (!mp->p_tx_desc_area) {
+		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
+		       dev->name, size);
+		goto out;
+	}
+	/* check 16-byte alignment */
+	BUG_ON((u32) mp->p_tx_desc_area & 0xf);
+	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
+
+	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
+	p_tx_desc = (struct tx_desc *)mp->p_tx_desc_area;
+	for (i = 0; i < tx_desc_num; i++) {
+		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
+		    ((i + 1) % tx_desc_num) * sizeof(struct tx_desc);
+	}
+
+	mp->tx_curr_desc_q = 0;
+	mp->tx_used_desc_q = 0;
+
+	mp->tx_desc_area_size = tx_desc_num * sizeof(struct tx_desc);
+
+	return 0;
+
+out:
+	kfree(mp->tx_skb);
+	return -ENOMEM;
+
+}
+
+static void txq_deinit(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	/* Free outstanding skb's on TX ring */
+	txq_reclaim(dev, 1);
+
+	BUG_ON(mp->tx_used_desc_q != mp->tx_curr_desc_q);
+
+	/* Free TX ring */
+	if (mp->p_tx_desc_area)
+		dma_free_coherent(NULL, mp->tx_desc_area_size,
+				  mp->p_tx_desc_area, mp->tx_desc_dma);
+
+	kfree(mp->tx_skb);
+}
+
+static int pxa168_eth_open(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	int err;
+
+	err = request_irq(dev->irq, pxa168_eth_int_handler,
+			  IRQF_DISABLED , dev->name, dev);
+	if (err) {
+		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
+		return -EAGAIN;
+	}
+
+	mp->rx_resource_err = 0;
+
+	err = rxq_init(dev);
+	if (err != 0)
+		goto out_free_irq;
+
+	err = txq_init(dev);
+	if (err != 0)
+		goto out_free_rx_skb;
+
+	mp->rx_used_desc_q = 0;
+	mp->rx_curr_desc_q = 0;
+	rxq_refill(dev);	/* Fill RX ring with skb's */
+	mp->rx_used_desc_q = 0;
+	mp->rx_curr_desc_q = 0;
+	netif_carrier_off(dev);
+	eth_port_start(dev);
+
+	napi_enable(&mp->napi);
+
+	return 0;
+
+out_free_rx_skb:
+	rxq_deinit(dev);
+out_free_irq:
+	free_irq(dev->irq, dev);
+
+	return err;
+}
+
+static int pxa168_eth_stop(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	eth_port_reset(dev);
+
+	/* Disable interrupts */
+	wrl(mp, INT_MASK, 0);
+	wrl(mp, INT_CAUSE, 0);
+
+	/* Write to ICR to clear interrupts. */
+	wrl(mp, INT_W_CLEAR, 0);
+
+	napi_disable(&mp->napi);
+
+	del_timer_sync(&mp->timeout);
+
+	netif_carrier_off(dev);
+
+	free_irq(dev->irq, dev);
+
+	rxq_deinit(dev);
+	txq_deinit(dev);
+
+	return 0;
+}
+
+static int pxa168_eth_change_mtu(struct net_device *dev, int mtu)
+{
+	if ((mtu > ETH_DATA_LEN) || (mtu < 64))
+		return -EINVAL;
+	dev->mtu = mtu;
+
+	return 0;
+}
+
+static int eth_alloc_tx_desc_index(struct pxa168_private *mp)
+{
+	int tx_desc_curr;
+
+	tx_desc_curr = mp->tx_curr_desc_q;
+	mp->tx_curr_desc_q = (tx_desc_curr + 1) % mp->tx_ring_size;
+	BUG_ON(mp->tx_curr_desc_q == mp->tx_used_desc_q);
+	mp->tx_desc_count++;
+	return tx_desc_curr;
+}
+
+static void eth_tx_submit_descs_for_skb(struct pxa168_private *mp,
+					struct sk_buff *skb)
+{
+	int tx_index;
+	struct tx_desc *desc;
+	int length;
+
+	tx_index = eth_alloc_tx_desc_index(mp);
+	desc = &mp->p_tx_desc_area[tx_index];
+	length = skb->len;
+	mp->tx_skb[tx_index] = skb;
+	desc->byte_cnt = length;
+	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+	wmb();
+	desc->cmd_sts = BUF_OWNED_BY_DMA | TX_GEN_CRC | TX_FIRST_DESC |
+			TX_ZERO_PADDING | TX_LAST_DESC;
+	if (unlikely(!(mp->tx_desc_count % TX_DONE_INTERVAL)))
+		desc->cmd_sts |= TX_EN_INT;
+	wmb();
+	wrl(mp, SDMA_CMD, SDMA_CMD_TXDH | SDMA_CMD_ERD);
+}
+
+static int pxa168_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct pxa168_private *mp =
+	    container_of(napi, struct pxa168_private, napi);
+	struct net_device *dev = mp->dev;
+	int work_done = 0;
+
+	if (unlikely(mp->work_todo & WORK_LINK)) {
+		mp->work_todo &= ~(WORK_LINK);
+		handle_link_event(mp);
+	}
+	/*
+	 * We call txq_reclaim every time since in NAPI interupts are disabled
+	 * and due to this we miss the TX_DONE interrupt,which is not updated in
+	 * interrupt status register.
+	 */
+	txq_reclaim(dev, 0);
+	if (netif_queue_stopped(dev)
+	    && mp->tx_ring_size - mp->tx_desc_count > 1) {
+		netif_wake_queue(dev);
+	}
+
+	work_done = rxq_process(dev, budget);
+	if (work_done < budget) {
+		napi_complete(napi);
+		wrl(mp, INT_MASK, ALL_INTS);
+	}
+	return work_done;
+}
+
+static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+
+	eth_tx_submit_descs_for_skb(mp, skb);
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+	dev->trans_start = jiffies;
+
+	if (mp->tx_ring_size - mp->tx_desc_count <= 1) {
+		/* We handled the current skb, but now we are out of space.*/
+		if (net_ratelimit())
+			dev_printk(KERN_NOTICE, &dev->dev, "tx queue full?!\n");
+		netif_stop_queue(dev);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int regnum)
+{
+	int val;
+	struct pxa168_private *mp = bus->priv;
+	int i = 0;
+
+	/* wait for the SMI register to become available */
+	for (i = 0; (val = rdl(mp, SMI)) & SMI_BUSY; i++) {
+
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk(KERN_ERR
+			       "pxa168 PHY timeout, port %d, val=0x%x\n",
+			       mp->port_num, val);
+			return -ETIMEDOUT;
+		}
+		udelay(1);
+	}
+
+	wrl(mp, SMI, (phy_addr << 16) | (regnum << 21) | SMI_OP_R);
+
+	/* now wait for the data to be valid */
+	for (i = 0; !((val = rdl(mp, SMI)) & SMI_R_VALID); i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk(KERN_ERR
+			       "pxa168 PHY RD timeout, port %d, val=0x%x\n",
+			       mp->port_num, val);
+			return -ETIMEDOUT;
+		}
+		udelay(1);
+	}
+
+	return val & 0xffff;
+}
+
+static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
+			    u16 value)
+{
+	struct pxa168_private *mp = bus->priv;
+	int i;
+
+	/* wait for the SMI register to become available */
+	for (i = 0; rdl(mp, SMI) & SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk(KERN_ERR "pxa168 PHY busy timeout, port %d\n",
+			       mp->port_num);
+			return -ETIMEDOUT;
+		}
+		udelay(1);
+	}
+
+	wrl(mp, SMI, (phy_addr << 16) | (regnum << 21) |
+	    SMI_OP_W | (value & 0xffff));
+
+	return 0;
+}
+
+static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
+			       int cmd)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	if (mp->phy != NULL)
+		return phy_mii_ioctl(mp->phy, if_mii(ifr), cmd);
+	return -EOPNOTSUPP;
+}
+
+static struct phy_device *phy_scan(struct pxa168_private *mp, int phy_addr)
+{
+	struct mii_bus *bus = mp->smi_bus;
+	struct phy_device *phydev;
+	int start;
+	int num;
+	int i;
+
+	if (phy_addr == PXA168_ETH_PHY_ADDR_DEFAULT) {
+		/* Scan entire range */
+		start = ethernet_phy_get(mp);
+		num = 32;
+	} else {
+		/* Use phy addr specific to platform */
+		start = phy_addr & 0x1f;
+		num = 1;
+	}
+
+	phydev = NULL;
+	for (i = 0; i < num; i++) {
+		int addr = (start + i) & 0x1f;
+		if (bus->phy_map[addr] == NULL)
+			mdiobus_scan(bus, addr);
+
+		if (phydev == NULL) {
+			phydev = bus->phy_map[addr];
+			if (phydev != NULL)
+				ethernet_phy_set_addr(mp, addr);
+		}
+	}
+
+	return phydev;
+}
+
+static void phy_init(struct pxa168_private *mp, int speed, int duplex)
+{
+	struct phy_device *phy = mp->phy;
+	ethernet_phy_reset(mp);
+
+	phy_attach(mp->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_MII);
+
+	if (speed == 0) {
+		phy->autoneg = AUTONEG_ENABLE;
+		phy->speed = 0;
+		phy->duplex = 0;
+		phy->supported &= PHY_BASIC_FEATURES;
+		phy->advertising = phy->supported | ADVERTISED_Autoneg;
+	} else {
+		phy->autoneg = AUTONEG_DISABLE;
+		phy->advertising = 0;
+		phy->speed = speed;
+		phy->duplex = duplex;
+	}
+	phy_start_aneg(phy);
+}
+
+static int ethernet_phy_setup(struct net_device *dev)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	if (mp->pd != NULL) {
+		if (mp->pd->init)
+			mp->pd->init();
+	}
+
+	mp->phy = phy_scan(mp, mp->pd->phy_addr & 0x1f);
+	if (mp->phy != NULL)
+		phy_init(mp, mp->pd->speed, mp->pd->duplex);
+
+	update_hash_table_mac_address(mp, NULL, dev->dev_addr);
+	return 0;
+}
+
+static int get_random_mac_addr(struct net_device *dev)
+{
+	printk(KERN_INFO "%s:Using random mac address\n", dev->name);
+	memcpy(dev->dev_addr, marvell_OUI, sizeof(marvell_OUI));
+	get_random_bytes(&dev->dev_addr[3], 3);
+	return 0;
+}
+
+static int pxa168_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+	int err;
+
+	err = phy_read_status(mp->phy);
+	if (err == 0)
+		err = phy_ethtool_gset(mp->phy, cmd);
+
+	return err;
+}
+
+static int pxa168_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	return phy_ethtool_sset(mp->phy, cmd);
+}
+
+static void pxa168_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	strncpy(info->driver, DRIVER_NAME, 32);
+	strncpy(info->version, DRIVER_VERSION, 32);
+	strncpy(info->fw_version, "N/A", 32);
+	strncpy(info->bus_info, "N/A", 32);
+}
+
+static u32 pxa168_get_link(struct net_device *dev)
+{
+	return !!netif_carrier_ok(dev);
+}
+
+static const struct ethtool_ops pxa168_ethtool_ops = {
+	.get_settings = pxa168_get_settings,
+	.set_settings = pxa168_set_settings,
+	.get_drvinfo = pxa168_get_drvinfo,
+	.get_link = pxa168_get_link,
+};
+
+static const struct net_device_ops pxa168_eth_netdev_ops = {
+	.ndo_open = pxa168_eth_open,
+	.ndo_stop = pxa168_eth_stop,
+	.ndo_start_xmit = pxa168_eth_start_xmit,
+	.ndo_set_rx_mode = pxa168_eth_set_rx_mode,
+	.ndo_set_mac_address = pxa168_eth_set_mac_address,
+	.ndo_validate_addr = eth_validate_addr,
+	.ndo_do_ioctl = pxa168_eth_do_ioctl,
+	.ndo_change_mtu = pxa168_eth_change_mtu,
+	.ndo_tx_timeout = pxa168_eth_tx_timeout,
+};
+
+static int pxa168_eth_probe(struct platform_device *pdev)
+{
+	struct pxa168_private *mp;
+	struct net_device *dev = NULL;
+	struct resource *res;
+	struct clk *clk;
+	int err;
+
+	printk(KERN_NOTICE "PXA168 10/100 Ethernet Driver\n");
+
+	clk = clk_get(&pdev->dev, "MFUCLK");
+	if (IS_ERR(clk)) {
+		printk(KERN_ERR "fast Ethernet failed to get clock\n");
+		return -1;
+	}
+	clk_enable(clk);
+
+	dev = alloc_etherdev(sizeof(struct pxa168_private));
+	if (!dev) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	platform_set_drvdata(pdev, dev);
+
+	mp = netdev_priv(dev);
+	mp->dev = dev;
+	mp->clk = clk;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	mp->base = ioremap(res->start, res->end - res->start + 1);
+	if (mp->base == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	BUG_ON(!res);
+	dev->irq = res->start;
+
+	dev->netdev_ops = &pxa168_eth_netdev_ops;
+
+	dev->watchdog_timeo = 8 * HZ;
+	dev->base_addr = 0;
+	SET_ETHTOOL_OPS(dev, &pxa168_ethtool_ops);
+
+	INIT_WORK(&mp->tx_timeout_task, pxa168_eth_tx_timeout_task);
+
+	mp->rx_ring_size = NUM_RX_DESCS;
+	mp->tx_ring_size = NUM_TX_DESCS;
+	get_random_mac_addr(dev);
+
+	mp->pd = pdev->dev.platform_data;
+	mp->port_num = mp->pd->port_number;
+	netif_napi_add(dev, &mp->napi, pxa168_rx_poll, mp->rx_ring_size);
+
+	memset(&mp->timeout, 0, sizeof(struct timer_list));
+	init_timer(&mp->timeout);
+	mp->timeout.function = rxq_refill_timer_wrapper;
+	mp->timeout.data = (unsigned long)mp;
+
+	mp->smi_bus = mdiobus_alloc();
+	if (mp->smi_bus == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
+	mp->smi_bus->priv = mp;
+	mp->smi_bus->name = "pxa168_eth smi";
+	mp->smi_bus->read = pxa168_smi_read;
+	mp->smi_bus->write = pxa168_smi_write;
+	snprintf(mp->smi_bus->id, MII_BUS_ID_SIZE, "%d", pdev->id);
+	mp->smi_bus->parent = &pdev->dev;
+	mp->smi_bus->phy_mask = 0xffffffff;
+	if (mdiobus_register(mp->smi_bus) < 0) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	pxa168_init_hw(mp);
+	err = ethernet_phy_setup(dev);
+	if (err)
+		goto out;
+
+	SET_NETDEV_DEV(dev, &pdev->dev);
+	err = register_netdev(dev);
+	if (err)
+		goto out;
+
+	return 0;
+
+out:
+	if (mp->clk) {
+		clk_disable(mp->clk);
+		clk_put(mp->clk);
+		mp->clk = NULL;
+	}
+
+	if (mp->base) {
+		iounmap(mp->base);
+		mp->base = NULL;
+	}
+
+	if (dev)
+		free_netdev(dev);
+	return err;
+}
+
+static int pxa168_eth_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct pxa168_private *mp = netdev_priv(dev);
+
+	if (mp->htpr) {
+		dma_free_coherent(NULL, HASH_ADDR_TABLE_SIZE + 7,
+				  mp->htpr, mp->htpr_dma);
+		mp->htpr = NULL;
+	}
+
+	if (mp->clk) {
+		clk_disable(mp->clk);
+		clk_put(mp->clk);
+		mp->clk = NULL;
+	}
+	if (mp->phy != NULL)
+		phy_detach(mp->phy);
+
+	iounmap(mp->base);
+	mp->base = NULL;
+
+	unregister_netdev(dev);
+	flush_scheduled_work();
+
+	free_netdev(dev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static void pxa168_eth_shutdown(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	eth_port_reset(dev);
+}
+
+#ifdef CONFIG_PM
+static int pxa168_eth_resume(struct platform_device *pdev)
+{
+	return -ENOSYS;
+}
+
+static int pxa168_eth_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	return -ENOSYS;
+}
+
+#else
+#define pxa168_eth_resume NULL
+#define pxa168_eth_suspend NULL
+#endif
+
+static struct platform_driver pxa168_eth_driver = {
+	.probe = pxa168_eth_probe,
+	.remove = pxa168_eth_remove,
+	.shutdown = pxa168_eth_shutdown,
+	.resume = pxa168_eth_resume,
+	.suspend = pxa168_eth_suspend,
+	.driver = {
+		   .name = DRIVER_NAME,
+		   },
+};
+
+static int __init pxa168_init_module(void)
+{
+	return platform_driver_register(&pxa168_eth_driver);
+}
+
+static void __exit pxa168_cleanup_module(void)
+{
+	platform_driver_unregister(&pxa168_eth_driver);
+}
+
+module_init(pxa168_init_module);
+module_exit(pxa168_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Ethernet driver for Marvell PXA168");
+MODULE_ALIAS("platform:pxa168_eth");
-- 
1.5.3.3

