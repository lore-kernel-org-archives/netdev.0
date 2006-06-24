From: Kiran Thota <Kiran_Thota@pmc-sierra.com>
Subject: [PATCH 6/6] PMC MSP85x0 gigabit ethernet driver
Date: Fri, 23 Jun 2006 19:19:00 -0700
Message-ID: <C28979E4F697C249ABDA83AC0C33CDF8143EFB@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Raj Palani <Rajesh_Palani@pmc-sierra.com>, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from father.pmc-sierra.com ([216.241.224.13]:29097 "HELO
	father.pmc-sierra.bc.ca") by vger.kernel.org with SMTP
	id S933184AbWFXCTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 22:19:11 -0400
To: linux-mips@linux-mips.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
- Based on linux-2.6.12 from http://www.linux-mips.org/pub/linux/mips/kernel/v2.6/linux-2.6.12.tar.gz
- Rewritten clean driver for PMC MSP85x0 gigabit ethernet driver (planning a rewritten titan driver) \
  source, Kconfig and makefile. Will remove dependency on TITAN_GE flag with future titan driver.

 
Signed-off-by: Kiran Kumar Thota <Kiran_Thota@pmc-sierra.com>

diff -Naur a/drivers/net/Kconfig b/drivers/net/Kconfig
--- a/drivers/net/Kconfig	2005-07-11 11:28:10.000000000 -0700
+++ b/drivers/net/Kconfig	2006-06-22 11:48:21.000000000 -0700
@@ -2098,7 +2098,7 @@
 
 config TITAN_GE
 	bool "PMC-Sierra TITAN Gigabit Ethernet Support"
-	depends on PMC_YOSEMITE
+	depends on PMC_YOSEMITE || PMC_SEQUOIA
 	help
 	  This enables support for the the integrated ethernet of
 	  PMC-Sierra's Titan SoC.
diff -Naur a/drivers/net/Makefile b/drivers/net/Makefile
--- a/drivers/net/Makefile	2005-07-11 11:28:10.000000000 -0700
+++ b/drivers/net/Makefile	2006-06-22 11:48:21.000000000 -0700
@@ -103,7 +103,8 @@
 obj-$(CONFIG_GALILEO_64240_ETH) += gt64240eth.o
 obj-$(CONFIG_MV64340_ETH) += mv64340_eth.o
 obj-$(CONFIG_BIG_SUR_FE) += big_sur_ge.o
-obj-$(CONFIG_TITAN_GE) += titan_mdio.o titan_ge.o
+obj-$(CONFIG_PMC_SEQUOIA) += titan_mdio.o msp85x0_ge.o
+#obj-$(CONFIG_TITAN_GE) += titan_mdio.o titan_ge.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o slhc.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff -Naur a/drivers/net/msp85x0_ge.c b/drivers/net/msp85x0_ge.c
--- a/drivers/net/msp85x0_ge.c	1969-12-31 16:00:00.000000000 -0800
+++ b/drivers/net/msp85x0_ge.c	2006-06-23 15:26:00.000000000 -0700
@@ -0,0 +1,2142 @@
+/*
+ * drivers/net/msp85x0_ge.c - Driver for MSP85x0 ethernet ports
+ *
+ * Copyright (C) 2006 PMC-Sierra Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+/*
+ * The MAC unit of the MSP85x0 consists of the following:
+ *
+ * -> XDMA Engine to move data to from the memory to the MAC packet FIFO
+ * -> FIFO is where the incoming and outgoing data is placed
+ * -> TRTG is the unit that pulls the data from the FIFO for Tx and pushes
+ *    the data into the FIFO for Rx
+ * -> TMAC is the outgoing MAC interface and RMAC is the incoming.
+ * -> AFX is the address filtering block
+ * -> GMII block to communicate with the PHY
+ *
+ * Rx will look like the following:
+ * GMII --> RMAC --> AFX --> TRTG --> Rx FIFO --> XDMA --> CPU memory
+ *
+ * Tx will look like the following:
+ * CPU memory --> XDMA --> Tx FIFO --> TRTG --> TMAC --> GMII
+ *
+ * The MSP85x0 driver has support for the following performance features:
+ * -> Rx side checksumming
+ * -> Jumbo Frames
+ * -> Interrupt Coalscing
+ * -> Rx NAPI
+ * -> SKB Recycling
+ * -> Transmit/Receive descriptors in SRAM
+ * -> Fast routing for IP forwarding
+ *
+ * 19Apr2006 -  Rewritten the code with functions modularized,  
+ *	 	hardcoding registers values removed, cleaned up the code
+ *		to support only the msp85x0. The interrupt handler,
+ *		poll function, descriptor freeing routine and close
+ *		routines are modified. 
+ *
+ */
+
+
+#include <linux/config.h>
+#include <linux/dma-mapping.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/ioport.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/ip.h>
+#include <linux/init.h>
+#include <linux/in.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/mii.h>
+#include <linux/delay.h>
+#include <linux/skbuff.h>
+#include <linux/prefetch.h>
+
+/* For MII specifc registers, msp85x0_mdio.h should be included */
+#include <net/ip.h>
+
+#include <asm/bitops.h>
+#include <asm/io.h>
+#include <asm/types.h>
+#include <asm/pgtable.h>
+#include <asm/system.h>
+#include <asm/pmc_sequoia.h>
+#include <linux/proc_fs.h>
+#include <linux/netpoll.h>
+#include <linux/timer.h>
+
+#include "msp85x0_ge.h"
+#include "titan_mdio.h"
+
+#ifdef MSP85x0_GE_DEBUG
+#define GE_DBG(x,y) 		printk(KERN_DBG x , y) 
+#define DUMP_SKB_DATA(x)	dump_skb_data(x)
+#define DUMP_SKB_FRAME(x)	dump_skb_frame(x)
+#else
+#define DUMP_SKB_DATA(x)
+#define DUMP_SKB_FRAME(x)
+#define GE_DBG(x,y)
+#endif
+
+#define GET_GE_VERSION(x)	(x & 0x0f000000) >> 16
+#define GET_GE_ID(x)		(x & 0x00ffffff)
+#define XDMA_PORT_OFFSET	9
+#define SQDPF_RX_PORT_OFFSET	0x60
+#define SQDPF_TX_PORT_OFFSET	0x0C
+#define XDMA_CHANNEL_OFFSET	16
+#define NO_ADDRESS_FILTERS	16
+#define NO_PORTS 		2
+#define INTERRUPT_HANDLER	msp85x0_ge_sequoia_int_handler
+
+#define PKT_PAD_BYTES(x)	((x) | (x << 8) | ( x << 16) | (x << 24))
+#define	TX_THRESHOLD		8 
+#define	RX_THRESHOLD		32
+#define TRTG2_PORT_OFFSET	12
+#define MAC_PORT_OFFSET		12
+#define MII_PORT_OFFSET		12
+
+	
+#define TX_INT	2
+#define RX_INT	1
+
+#define MSP85x0_GE_WRITE	TITAN_GE_WRITE
+#define MSP85x0_GE_READ		TITAN_GE_READ
+
+#define ETHERNET_FCS_SIZE            4
+
+#define DMA_CACHE_WBACK_INV(x,y)
+#define       IOMAP(x,y)              ioremap_nocache((x),(y))
+
+// Function declared in arch/mips/pmc-sierra/sequoia/setup.c
+extern unsigned long titan_ge_base;
+
+extern unsigned long rm9150_dma_base;
+
+static spinlock_t msp85x0_lock;
+
+static unsigned int port0_pkt_count=0, port1_pkt_count=0;
+
+/* Static Function Declarations	 */
+static int msp85x0_ge_eth_open(struct net_device *);
+static int msp85x0_ge_eth_reopen(struct net_device *netdev);
+static void msp85x0_ge_eth_stop(struct net_device *);
+static struct net_device_stats *msp85x0_ge_get_stats(struct net_device *);
+static int msp85x0_ge_init_rx_desc_ring(msp85x0_ge_port_info *, int, int,
+				      unsigned long, unsigned long,
+				      unsigned long);
+static int msp85x0_ge_init_tx_desc_ring(msp85x0_ge_port_info *, int,
+				      unsigned long, unsigned long);
+
+static int msp85x0_ge_open(struct net_device *);
+static int msp85x0_ge_start_xmit(struct sk_buff *, struct net_device *);
+static int msp85x0_ge_stop(struct net_device *);
+
+static unsigned int msp85x0_ge_tx_coal(int);
+
+static void msp85x0_ge_port_reset(unsigned int);
+static int msp85x0_ge_free_tx_queue(struct net_device *);
+static int msp85x0_ge_rx_task(struct net_device *, msp85x0_ge_port_info *);
+static int msp85x0_ge_port_start(struct net_device *);
+static int msp85x0_eth_setup_tx_rx_fifo(struct net_device *dev);
+static int msp85x0_ge_xdma_reset(void);
+
+/*
+ * Some configuration for the FIFO and the XDMA channel needs
+ * to be done only once for all the ports. This flag controls
+ * that
+ */
+static unsigned long config_done;
+
+/*
+ * One time out of memory flag
+ */
+static unsigned int oom_flag;
+
+static int msp85x0_ge_poll(struct net_device *netdev, int *budget);
+static int msp85x0_ge_receive_queue(struct net_device *);
+
+static struct platform_device *msp85x0_ge_device[NO_PORTS];
+static struct net_device *msp85x0_eth[NO_PORTS];
+static unsigned int msp85x0_ge_sram;
+static unsigned int port_number;
+
+/*
+ * The MSP85x0 GE has two alignment requirements:
+ * -> skb->data to be cacheline aligned (32 byte)
+ * -> IP header alignment to 16 bytes
+ *
+ * The latter is not implemented. So, that results in an extra copy on
+ * the Rx. This is a big performance hog. For the former case, the
+ * dev_alloc_skb() has been replaced with msp85x0_ge_alloc_skb(). The size
+ * requested is calculated:
+ *
+ * Ethernet Frame Size : 1518
+ * Ethernet Header     : 14
+ * Future MSP85x0 change for IP header alignment : 2
+ *
+ * Hence, we allocate (1518 + 14 + 2+ 64) = 1580 bytes.  For IP header
+ * alignment, we use skb_reserve().
+ */
+#define ALIGNED_RX_SKB_ADDR(addr) \
+	((((unsigned long)(addr) + (32UL - 1UL)) \
+	& ~(32UL - 1UL)) - (unsigned long)(addr))
+#define msp85x0_ge_alloc_skb(__length, __gfp_flags) \
+({      struct sk_buff *__skb; \
+	__skb = alloc_skb((__length),(__gfp_flags)); \
+	if(__skb){ \
+		int __offset = (int) ALIGNED_RX_SKB_ADDR(__skb->data); \
+		if(__offset) \
+			skb_reserve(__skb, __offset); \
+	} \
+	__skb; \
+})
+
+int increment_tx_pkt_count(unsigned int port)
+{
+	unsigned int flags;
+	spin_lock_irqsave(&msp85x0_lock,flags);
+	if(port==0){
+		port0_pkt_count++;
+	}
+	else{
+		port1_pkt_count++;	
+	}
+	spin_unlock_irqrestore(&msp85x0_lock,flags);
+	return 0;
+}
+
+unsigned int get_tx_pkt_count(unsigned int port)
+{
+	unsigned int flags,pktCount,tx_pending_pkt;
+	spin_lock_irqsave(&msp85x0_lock,flags);
+	tx_pending_pkt=MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_TX_DMA_STS + (port << XDMA_PORT_OFFSET));
+	if(port==0){
+		pktCount=port0_pkt_count - tx_pending_pkt;
+	}
+	else{
+		pktCount=port1_pkt_count - tx_pending_pkt;	
+	}
+	spin_unlock_irqrestore(&msp85x0_lock,flags);
+	return pktCount;	
+}
+
+unsigned int decrement_tx_pkt_count(unsigned int port)
+{
+	unsigned int flags;
+	spin_lock_irqsave(&msp85x0_lock,flags);
+	if(port==0){
+		port0_pkt_count--;
+	}
+	else{
+		port1_pkt_count--;	
+	}
+	spin_unlock_irqrestore(&msp85x0_lock,flags);
+	return 0;	
+}
+void msp85x0_bringup_sequence(int port)
+{
+   	unsigned int reg_data;
+
+	/* SDQPF */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8),reg_data);
+	/* TRTG  */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_TRTG_CONFIG + (port << TRTG2_PORT_OFFSET));
+	reg_data |=(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_TRTG_CONFIG + (port << TRTG2_PORT_OFFSET),reg_data);
+	/* GMII TX/RX DISABLE PORT 0  */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_GMII_CONFIG_GENERAL + (port << MAC_PORT_OFFSET));
+	reg_data |=(0x3);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_GMII_CONFIG_GENERAL + (port << MAC_PORT_OFFSET),reg_data);
+	/* TMAC */    
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 + (port << MAC_PORT_OFFSET));
+	reg_data |=(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_TMAC_CONFIG_1 + (port << MAC_PORT_OFFSET),reg_data);
+	/* L1TPP */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_L1TPP_CONFIG + (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_L1TPP_CONFIG + (port << MAC_PORT_OFFSET),reg_data);
+	/* L1RPP */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_L1RPP_CONFIG_STS+ (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_L1RPP_CONFIG_STS + (port << MAC_PORT_OFFSET),reg_data);
+	/* RTIF  */ 
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_RTIF_CONFIG + (port << MAC_PORT_OFFSET));
+	reg_data |=(0x4000);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_RTIF_CONFIG + (port << MAC_PORT_OFFSET),reg_data);
+	/* RMAC  */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1+ (port << MAC_PORT_OFFSET));
+	reg_data |=(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_RMAC_CONFIG_1+ (port << MAC_PORT_OFFSET),reg_data);
+}
+
+void msp85x0_reset_sequence(int port)
+{
+   	unsigned int reg_data;
+	/* RMAC */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1+ (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_RMAC_CONFIG_1+ (port << MAC_PORT_OFFSET),reg_data);
+	/* RTIF */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_RTIF_CONFIG + (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x4000);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_RTIF_CONFIG + (port << MAC_PORT_OFFSET),reg_data);
+	/* L1RPP */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_L1RPP_CONFIG_STS+ (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_L1RPP_CONFIG_STS + (port << MAC_PORT_OFFSET),reg_data);
+	/* L1TPP */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_L1TPP_CONFIG + (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_L1TPP_CONFIG + (port << MAC_PORT_OFFSET),reg_data);
+	/* TMAC  */    
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 + (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_TMAC_CONFIG_1 + (port << MAC_PORT_OFFSET),reg_data);
+	/* GMII TX/RX DISABLE PORT 0  */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_GMII_CONFIG_GENERAL + (port << MAC_PORT_OFFSET));
+	reg_data &=~(0x3);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_GMII_CONFIG_GENERAL + (port << MAC_PORT_OFFSET),reg_data);
+	/* TRTG  */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_TRTG_CONFIG + (port << TRTG2_PORT_OFFSET));
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_TRTG_CONFIG + (port << TRTG2_PORT_OFFSET),reg_data);
+	/* SDQPF */
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8));
+	reg_data |=0x1;	
+	MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8),reg_data);
+	reg_data &=~(0x1);	
+	MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8),reg_data);
+}
+
+static int msp85x0_ge_xdma_reset()
+{
+	unsigned int reg_data;
+
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_RESET);
+	reg_data |= 1 << (8);
+	MSP85x0_GE_WRITE(MSP85x0_GE_RESET,reg_data);
+	mdelay(50);
+	reg_data &= ~(1 << 8);
+	MSP85x0_GE_WRITE(MSP85x0_GE_RESET,reg_data);
+	return 0;
+}
+
+/*
+ * Configure the GMII block of the MSP85x0 based on what the PHY tells us
+ */
+static void msp85x0_ge_gmii_config(int port_num)
+{
+	unsigned int reg_data = 0, phy_reg;
+	int err;
+
+	err = titan_ge_mdio_read(port_num, TITAN_GE_MDIO_PHY_STATUS, &phy_reg);
+
+	if (err == TITAN_GE_MDIO_ERROR) {
+		printk(KERN_ERR
+		       "Could not read PHY control register 0x11 \n");
+		
+		printk(KERN_ERR
+			"Setting speed to 1000 Mbps and Duplex to Full \n");
+
+		return;
+	}
+
+	err = titan_ge_mdio_write(port_num, TITAN_GE_MDIO_PHY_IE, 0);
+
+	if (phy_reg & 0x8000) {
+		if (phy_reg & 0x2000) {
+			/* Full Duplex and 1000 Mbps */
+			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
+					(port_num << MII_PORT_OFFSET)), 0x201);
+		}  else {
+			/* Half Duplex and 1000 Mbps */
+			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
+					(port_num << MII_PORT_OFFSET)), 0x2201);
+			}
+	}
+	if (phy_reg & 0x4000) {
+		if (phy_reg & 0x2000) {
+			/* Full Duplex and 100 Mbps */
+			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
+					(port_num << MII_PORT_OFFSET)), 0x100);
+		} else {
+			/* Half Duplex and 100 Mbps */
+			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
+					(port_num << MII_PORT_OFFSET)), 0x2100);
+		}
+	}
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_GMII_CONFIG_GENERAL +
+				(port_num << MII_PORT_OFFSET));
+	reg_data |= 0x3;
+	MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_GENERAL +
+			(port_num << MII_PORT_OFFSET)), reg_data);
+}
+
+/*
+ * Enable the TMAC if it is not
+ */
+static void msp85x0_ge_enable_tx(unsigned int port_num)
+{
+	unsigned long reg_data;
+
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET));
+	if (!(reg_data & 0x8000)) {
+		printk("TMAC disabled for port %d!! \n", port_num);
+
+		reg_data |= 0x0001;	/* Enable TMAC */
+		reg_data |= 0x4000;	/* CRC Check Enable */
+		reg_data |= 0x2000;	/* Padding enable */
+		reg_data |= 0x0800;	/* CRC Add enable */
+		//reg_data |= 0x0080;	/* PAUSE frame */
+
+		MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_CONFIG_1 +
+				(port_num << MAC_PORT_OFFSET)), reg_data);
+	}
+}
+
+/*
+ * Tx Timeout function
+ */
+static void msp85x0_ge_tx_timeout(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+
+	printk(KERN_INFO "%s: TX timeout  ", netdev->name);
+	printk(KERN_INFO "Resetting card \n");
+
+	/* Do the reset outside of interrupt context */
+	schedule_work(&msp85x0_ge_eth->tx_timeout_task);
+}
+
+/*
+ * Update the AFX tables for UC and MC for slice 0 only
+ */
+static void msp85x0_ge_update_afx(msp85x0_ge_port_info * msp85x0_ge_eth)
+{
+	int port = msp85x0_ge_eth->port_num;
+	unsigned int i;
+	volatile unsigned long reg_data = 0;
+	u8 p_addr[6];
+
+	memcpy(p_addr, msp85x0_ge_eth->port_mac_addr, 6);
+
+	/* Set the MAC address here for TMAC and RMAC */
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_HI + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[5] << 8) | p_addr[4]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_MID + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[3] << 8) | p_addr[2]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_LOW + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[1] << 8) | p_addr[0]));
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_HI + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[5] << 8) | p_addr[4]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_MID + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[3] << 8) | p_addr[2]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_LOW + (port << MAC_PORT_OFFSET)),
+		       ((p_addr[1] << 8) | p_addr[0]));
+
+	/* Configure the eight address filters */
+
+	/* Select first filter to match our address */
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_2 +
+				(port << MAC_PORT_OFFSET)), 0);
+	wmb();
+	/* Configure the match */
+	reg_data = 0x9;	/* Forward Enable Bit */
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_0 +
+				(port << MAC_PORT_OFFSET)), reg_data);
+
+	/* Finally, AFX Exact Match Address Registers */
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_EXACT_MATCH_LOW + (port << MAC_PORT_OFFSET)),
+			       ((p_addr[1] << 8) | p_addr[0]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_EXACT_MATCH_MID + (port << MAC_PORT_OFFSET)),
+			       ((p_addr[3] << 8) | p_addr[2]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_EXACT_MATCH_HIGH + (port << MAC_PORT_OFFSET)),
+			       ((p_addr[5] << 8) | p_addr[4]));
+
+	/* VLAN id set to 0 */
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_EXACT_MATCH_VID +
+				(port << MAC_PORT_OFFSET)), 0);
+	wmb();
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_3 | (port << MAC_PORT_OFFSET)), 0x1);
+
+	for (i = 1; i < NO_ADDRESS_FILTERS; i++) {
+		/* Select each of the eight filters */
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_2 +
+				(port << MAC_PORT_OFFSET)), i);
+
+		/* Configure the match */
+		reg_data = 0x0;	/* Disable filter */
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_0 +
+				(port << MAC_PORT_OFFSET)), reg_data);
+
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_3 | (port << MAC_PORT_OFFSET)), 0);
+
+	}
+}
+
+/*
+ * Actual Routine to reset the adapter when the timeout occurred
+ */
+
+static void msp85x0_ge_tx_timeout_task(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	int port = msp85x0_ge_eth->port_num;
+
+	printk("MSP85x0 GE: Transmit timed out. Resetting ... \n");
+
+	/* Dump debug info */
+	printk(KERN_ERR "TRTG cause : %x \n",
+			MSP85x0_GE_READ(MSP85x0_GE_TRTG2_INTERRUPT_IND + (port << TRTG2_PORT_OFFSET)));
+
+	/* Fix this for the other ports */
+	printk(KERN_ERR "FIFO cause : %x \n", MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_INTR));
+	printk(KERN_ERR "IE cause : %x \n", MSP85x0_GE_READ(MSP85x0_GE_INTR_GRP0_STATUS));
+	printk(KERN_ERR "XDMA GDI ERROR : %x \n",
+			MSP85x0_GE_READ(MSP85x0_GE_GXDMA_INT_STS + (port << XDMA_PORT_OFFSET)));
+	printk(KERN_ERR "CHANNEL ERROR: %x \n",MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_INTERRUPT
+						+ (port << XDMA_PORT_OFFSET)));
+
+	netif_device_detach(netdev);
+	msp85x0_ge_port_reset(msp85x0_ge_eth->port_num);
+	msp85x0_ge_port_start(netdev);
+	netif_device_attach(netdev);
+}
+
+/*
+ * Change the MTU of the Ethernet Device
+ */
+static int msp85x0_ge_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned long flags;
+#ifdef MSP85x0_GE_JUMBO_FRAMES
+	if ((new_mtu > 9500) || (new_mtu < 64))
+		return -EINVAL;
+#else
+	if ((new_mtu > 1518) || (new_mtu < 64))
+		return -EINVAL;
+#endif
+	spin_lock_irqsave(&msp85x0_ge_eth->lock, flags);
+
+	netdev->mtu = new_mtu;
+	/* Now we have to reopen the interface so that SKBs with the new
+	 * size will be allocated */
+	if (netif_running(netdev)) {
+		msp85x0_ge_eth_stop(netdev);
+            	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_MAX_FRAME_LEN + (msp85x0_ge_eth->port_num << MAC_PORT_OFFSET)), new_mtu + 2); // for the padded bytes
+
+		if (msp85x0_ge_eth_reopen(netdev) != 0) {
+			printk(KERN_ERR
+			       "%s: Fatal error on opening device\n",
+			       netdev->name);
+			spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+			return -1;
+		}
+	}
+	spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+	return 0;
+}
+
+static int handle_phy_interrupt(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int err,reg_data;
+	  
+        err =titan_ge_mdio_read(port_num,TITAN_GE_MDIO_PHY_IS, &reg_data);
+        if (reg_data & 0x0400) {
+               /* Link status change */
+               titan_ge_mdio_read(port_num,TITAN_GE_MDIO_PHY_STATUS, &reg_data);
+               if (!(reg_data & 0x0400)) {
+                    /* Link is down */
+                    netif_carrier_off(netdev);
+                    netif_stop_queue(netdev);
+               } else {
+                    /* Link is up */
+                    netif_carrier_on(netdev);
+                    netif_wake_queue(netdev);
+                    /* Enable the queue */
+                    msp85x0_ge_enable_tx(port_num);
+               }
+        }
+	return 0;
+}
+
+static int handle_error_interrupts(unsigned int cause,unsigned char shift,unsigned int port_num)
+{ 
+       /* Handle error interrupts */
+        if (cause && (cause != 0x2)) {
+                printk(KERN_ERR"XDMA Channel Error : %x  on port %d\n",
+					cause, port_num);
+                printk(KERN_ERR"XDMA GDI Hardware error : %x  on port %d\n",
+                        MSP85x0_GE_READ(MSP85x0_GE_GXDMA_INT_STS + (port_num << shift)), port_num);
+                printk(KERN_ERR"XDMA currently has %d Rx descriptors \n",
+                        MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_RX_DMA_STS + (port_num << shift)));
+                printk(KERN_ERR
+                        "XDMA currently has prefetcted %d Rx descriptors \n",
+                        MSP85x0_GE_READ(MSP85x0_GE_GXDMA0_DESC_PREFETCH_CNT + (port_num << shift)));
+                MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_INTERRUPT +
+                               (port_num << shift)), cause);
+        }
+	return 0;
+}
+
+
+/*
+ * Enable the Tx & Rx side interrupts
+ */
+static void msp85x0_ge_enable_rx_int(unsigned int port)
+{
+	unsigned long reg_data = MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_IE);
+        reg_data |=(RX_INT << (XDMA_CHANNEL_OFFSET * port));
+	MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_IE, reg_data);
+}
+/*
+ * Disable the Tx & Rx side interrupts
+ */
+static void msp85x0_ge_disable_rx_int(unsigned int port)
+{
+	unsigned long reg_data = MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_IE);
+        reg_data &=~(RX_INT << (XDMA_CHANNEL_OFFSET * port));
+	MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_IE, reg_data);
+}
+
+static void clear_xdma_interrupts(unsigned int port,unsigned int tx_rx)
+{
+     MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_CORE_A,tx_rx << (XDMA_CHANNEL_OFFSET * port));
+}
+/*
+ * MSP85x0 Gbe Interrupt Handler. All the three ports send interrupt to one line
+ * only. Once an interrupt is triggered, figure out the port and then check
+ * the Interrupt channel.
+ */
+static irqreturn_t msp85x0_ge_sequoia_int_handler(int irq, void *dev_id,
+	struct pt_regs *regs)
+{
+	struct net_device *netdev = (struct net_device *) dev_id;
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int eth_int_cause_error = 0, is;
+	unsigned long eth_int_cause1,eth_rx_ood_error;
+	unsigned long flags;
+
+	spin_lock_irqsave(&msp85x0_ge_eth->lock, flags);
+        /* Ack the CPU interrupt */
+	is=*(volatile unsigned int *)(RM9150_DMA_DCR + 0x8000 + RM9150_GCIC_INT3_STATUS);
+	*(volatile unsigned int *)(RM9150_DMA_DCR + 0x8000 + RM9150_GCIC_INT3_CLEAR)=is;
+
+        eth_int_cause1 = MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_CORE_A);	
+        if (eth_int_cause1 == 0) {
+                eth_int_cause_error = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_INTERRUPT
+                                                + (port_num << 9));
+                if (eth_int_cause_error == 0)
+		{
+			spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+                        return IRQ_NONE;
+		}
+
+        }
+        /* Handle the Rx next */
+        if (eth_int_cause1 & (RX_INT << (port_num * 16))) {
+	      clear_xdma_interrupts(port_num,RX_INT);
+              if (netif_rx_schedule_prep(netdev)) {
+		   msp85x0_ge_disable_rx_int(port_num);	
+                   __netif_rx_schedule(netdev);			       		
+
+              }
+        }
+	/* Handle error interrupts */
+	handle_error_interrupts(eth_int_cause_error,9,port_num);
+
+	/* Handle Rx OOD */ 
+        eth_rx_ood_error = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_INTERRUPT + (port_num << 9));
+	if(eth_rx_ood_error & 0x2)
+	{
+              if (netif_rx_schedule_prep(netdev)){
+		   msp85x0_ge_disable_rx_int(port_num);	
+                   __netif_rx_schedule(netdev);
+	      }
+	}	
+
+        /*
+         * PHY interrupt to inform abt the changes. Reading the
+         * PHY Status register will clear the interrupt
+         */
+        if ((!(eth_int_cause1 & (0x3 << (port_num * 16)))) &&
+                (eth_int_cause_error == 0)) {
+			handle_phy_interrupt(netdev);
+        }
+	spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+	return IRQ_HANDLED;
+}
+/*
+ * Multicast and Promiscuous mode set. The
+ * set_multi entry point is called whenever the
+ * multicast address list or the network interface
+ * flags are updated.
+ */
+static void msp85x0_ge_set_multi(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned long reg_data;
+
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_1 +
+				(port_num << MAC_PORT_OFFSET));
+
+	if (netdev->flags & IFF_PROMISC) {
+		reg_data |= 0x2;
+	}
+	else if (netdev->flags & IFF_ALLMULTI) {
+		reg_data |= 0x01;
+		reg_data |= 0x400; /* Use the 64-bit Multicast Hash bin */
+	}
+	else {
+		reg_data = 0x2;
+	}
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_1 +
+			(port_num << MAC_PORT_OFFSET)), reg_data);
+	if (reg_data & 0x01) {
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_MULTICAST_HASH_LOW +
+				(port_num << MAC_PORT_OFFSET)), 0xffff);
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_MULTICAST_HASH_MIDLOW +
+				(port_num << MAC_PORT_OFFSET)), 0xffff);
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_MULTICAST_HASH_MIDHI +
+				(port_num << MAC_PORT_OFFSET)), 0xffff);
+		MSP85x0_GE_WRITE((MSP85x0_GE_AFX_MULTICAST_HASH_HI +
+				(port_num << MAC_PORT_OFFSET)), 0xffff);
+	}
+}
+
+/*
+ * Open the network device
+ */
+static int msp85x0_ge_open(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int irq;
+	int retval;       
+
+	spin_lock_irq(&(msp85x0_ge_eth->lock));
+
+	if (msp85x0_ge_eth_open(netdev) != MSP85x0_OK) {
+		spin_unlock_irq(&(msp85x0_ge_eth->lock));
+		printk("%s: Error opening interface \n", netdev->name);
+		free_irq(netdev->irq, netdev);
+		return -EBUSY;
+	}
+
+	spin_unlock_irq(&(msp85x0_ge_eth->lock));
+
+        irq = MSP85x0_ETH_PORT_IRQ;
+
+	retval = request_irq(irq, INTERRUPT_HANDLER,
+		     SA_SAMPLE_RANDOM | SA_SHIRQ, netdev->name, netdev);
+
+	if (retval != 0) {
+		printk(KERN_ERR "Cannot assign IRQ number to MSP85x0 GE \n");
+		return -1;
+	}
+
+	netdev->irq = irq;
+	printk(KERN_INFO "Assigned IRQ %d to port %d\n", irq, port_num);
+
+	return 0;
+}
+
+/*
+ * Allocate the SKBs for the Rx ring. Also used
+ * for refilling the queue
+ */
+
+static int msp85x0_ge_rx_task(struct net_device *netdev,
+				msp85x0_ge_port_info *msp85x0_ge_eth)
+{
+	struct device *device = &msp85x0_ge_device[msp85x0_ge_eth->port_num]->dev;
+	volatile msp85x0_ge_rx_desc *rx_desc;
+	struct sk_buff *skb;
+	int rx_used_desc;
+	int count = 0;
+	oom_flag=0;
+	while (msp85x0_ge_eth->rx_ring_skbs < msp85x0_ge_eth->rx_ring_size) {
+		/* First try to get the skb from the recycler */
+		skb = msp85x0_ge_alloc_skb(MSP85x0_GE_RX_BUFSIZE, GFP_ATOMIC);
+		if (unlikely(!skb)) {
+			/* OOM, set the flag */
+			oom_flag = 1;
+			break;
+		}
+		count++;
+		skb->dev = netdev;
+		msp85x0_ge_eth->rx_ring_skbs++;
+		rx_used_desc = msp85x0_ge_eth->rx_used_desc_q;
+		rx_desc = &(msp85x0_ge_eth->rx_desc_area[rx_used_desc]);
+		rx_desc->buffer_addr = dma_map_single(device, skb->data,
+				MSP85x0_GE_RX_BUFSIZE - 2, DMA_FROM_DEVICE);
+		msp85x0_ge_eth->rx_skb[rx_used_desc] = skb;
+		rx_desc->cmd_sts = MSP85x0_GE_RX_BUFFER_OWNED;
+   		DMA_CACHE_WBACK_INV((unsigned long)rx_desc,sizeof(msp85x0_ge_rx_desc));
+		if((rx_used_desc + 1) == MSP85x0_GE_RX_QUEUE)
+			msp85x0_ge_eth->rx_used_desc_q =0;
+		else
+			msp85x0_ge_eth->rx_used_desc_q = (rx_used_desc + 1);	
+	}
+	return count;
+}
+
+/*
+ * Actual init of the Tital GE port. There is one register for
+ * the channel configuration
+ */
+static void msp85x0_port_init(struct net_device *netdev,
+			    msp85x0_ge_port_info * msp85x0_ge_eth)
+{
+	unsigned long reg_data;
+	unsigned int port_num;	
+
+	port_num = msp85x0_ge_eth->port_num;
+	for (port_num = 0; port_num < NO_PORTS; port_num++)
+	{
+		msp85x0_ge_port_reset(port_num);
+
+		/* First reset the TMAC */
+		reg_data = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET));
+		reg_data |= XDMA_TMAC_RESET;
+		MSP85x0_GE_WRITE(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET), reg_data);
+		/* RMAC */
+		reg_data = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET));
+		reg_data |= XDMA_RMAC_RESET;
+		MSP85x0_GE_WRITE(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET), reg_data);
+	}
+}
+
+static int start_tx_and_rx_activity(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int reg_data;
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_CONFIG_2 + (port_num << MAC_PORT_OFFSET)), 0xe1b7);
+#ifdef MSP85x0_GE_JUMBO_FRAMES
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_MAX_FRAME_LEN + (port_num << MAC_PORT_OFFSET)), 0x4000);
+#endif
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET));
+	reg_data |= (0x0001 << 14);	/* CRC Check Enable */		
+	reg_data |= (0x0002 << 12);	/* Padding enable */	
+	reg_data |= (0x0001 << 11);	/* CRC Add enable */		
+	reg_data |= (0x0001 << 10);	/* Min. frame length check */	
+	reg_data |= (0x0001 <<  6);	/* Pause, if FIFO full */	
+	reg_data &=~(0x0001 <<  6);	/* Disable pause frame */
+	reg_data |= (0x0001 <<  5);	/* Send XON */			
+	reg_data |= (0x0001 <<  4);	/* Stop on XOFF */
+	reg_data |= (0x0001 <<  0);	/* Enable TMAC */
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET)), reg_data);
+	udelay(30);
+
+	/* Destination Address drop bit */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_2 + (port_num << MAC_PORT_OFFSET));
+        reg_data |= 0x109;        /* DA_DROP bit and pause */
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_CONFIG_2 + (port_num << MAC_PORT_OFFSET)), reg_data);
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_LINK_CONFIG + (port_num << MAC_PORT_OFFSET)), 0x3);
+#ifdef MSP85x0_GE_JUMBO_FRAMES
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_MAX_FRAME_LEN + (port_num << MAC_PORT_OFFSET)), 0x4000);
+#endif
+	/* Start the Rx activity */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET));
+	reg_data |= (0x0001 << 14);	/* Preamble check enable */	
+	reg_data |= (0x0001 << 13);	/* VLAN tag aware */		
+	reg_data |= (0x0003 << 10);	/* in-range length checking */	
+	reg_data |= (0x0001 <<  8);	/* Max frame discard */		
+	reg_data |= (0x0001 <<  7);	/* Max frame check enable */	
+	reg_data |= (0x0001 <<  6);	/* Min frame discard */		
+	reg_data |= (0x0001 <<  5);	/* Min frame check enable */	
+	reg_data |= (0x0001 <<  4);	/* CRC discard */		
+	reg_data |= (0x0001 <<  3);	/* CRC check enable */		
+	reg_data |= (0x0001 <<  1);	/* reserved */
+	reg_data |= (0x0001 <<  0);	/* RMAC Enable */
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET)), reg_data);
+	udelay(30);
+	return 0;
+}
+
+static int trtg_block_enable(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int reg_data;
+
+	/*
+	 * Step 3:  TRTG block enable
+	 */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TRTG_CONFIG + (port_num << TRTG2_PORT_OFFSET));
+	reg_data &= ~1;
+        MSP85x0_GE_WRITE((MSP85x0_GE_TRTG_CONFIG + (port_num << TRTG2_PORT_OFFSET)), reg_data);
+
+        reg_data = PKT_PAD_BYTES(2);
+        MSP85x0_GE_WRITE((MSP85x0_GE_TRTG_BYTE_OFFSET_0 + (port_num << TRTG2_PORT_OFFSET)), reg_data);
+        MSP85x0_GE_WRITE((MSP85x0_GE_TRTG_BYTE_OFFSET_1 + (port_num << TRTG2_PORT_OFFSET)), reg_data);   
+	mdelay(5);
+
+	/* Priority */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TRTG_PRIORITY_CHKSUM + (port_num << TRTG2_PORT_OFFSET));
+	reg_data &= ~(0x00f00000);
+	reg_data |= (14 << 8);
+	MSP85x0_GE_WRITE((MSP85x0_GE_TRTG_PRIORITY_CHKSUM + (port_num << TRTG2_PORT_OFFSET)), reg_data);
+
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TRTG_CONFIG + (port_num << TRTG2_PORT_OFFSET));
+	reg_data |= 0x0001;
+	MSP85x0_GE_WRITE((MSP85x0_GE_TRTG_CONFIG + (port_num << TRTG2_PORT_OFFSET)), reg_data);
+	return 0;
+}
+
+
+static int enable_tx_and_rx_interrupts(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned int reg_data;
+
+	if (config_done == 0) {
+		/* XD_OOD_INTSMSG = 0x61, XD_INTSMSG    = 0x62
+		   XD_RX_INTSMSG  = 0x60, XD_TX_INTSMSG = 0x60  */
+                MSP85x0_GE_WRITE(MSP85x0_GE_CPIF2_INT_MSG_ADDR0,(RM9150_GCIC_BASE + RM9150_GCIC_INTMSG) >> 4);
+                reg_data = 0x61626060;
+                MSP85x0_GE_WRITE(MSP85x0_GE_CPIF2_SET_VECTOR_MSG0, reg_data);
+                reg_data = MSP85x0_GE_READ(MSP85x0_GE_CPIF2_INT_VECOTR_MODE0);
+                reg_data |= 0x1;
+                MSP85x0_GE_WRITE(MSP85x0_GE_CPIF2_INT_VECOTR_MODE0, reg_data);
+	}
+
+	/*
+	 * Enable the Interrupts for Rx 
+	 */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_IE);
+	reg_data |= (RX_INT << (port_num * XDMA_CHANNEL_OFFSET));
+	MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_IE, reg_data);
+
+	return 0;
+}
+
+
+static int get_ring_count(unsigned int count)
+{
+	unsigned int ring_size;
+	switch(count)
+	{
+		case 1:
+			ring_size=0;break;
+		case 2:
+			ring_size=1;break;
+		case 4:
+			ring_size=2;break;
+		case 8:
+			ring_size=3;break;
+		case 16:
+			ring_size=4;break;
+		default:
+			ring_size=0;break;
+	}
+	return ring_size;
+}
+
+static int get_rx_buff_size(unsigned int size)
+{
+	unsigned int buff_size;
+	switch(size)
+	{
+		case 1:
+			buff_size=0;break;
+		case 2:
+			buff_size=1;break;
+		case 4:
+			buff_size=2;break;
+		case 8:
+			buff_size=3;break;
+		case 16:
+			buff_size=4;break;
+		case 32:
+			buff_size=5;break;
+		default:
+			buff_size=0;break;
+	}
+	return buff_size;
+}
+
+static int xdma_config(struct net_device *netdev)
+{
+	volatile unsigned long reg_data;
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	int port_num = msp85x0_ge_eth->port_num;
+	unsigned int count = 0,rx_ring,tx_ring;
+
+	if (config_done == 0) {
+		reg_data = MSP85x0_GE_READ(MSP85x0_GE_XDMA_CONFIG);
+		reg_data &= ~(0x80000000);      /* clear reset */
+		reg_data |= (0x1 << 29);	/* sparse tx descriptor spacing */
+		reg_data |= (0x1 << 28);	/* sparse rx descriptor spacing */
+                /* No support for coherency.  Has to be cleared */
+		reg_data &= ~(0x8000); /* Disable the write back */ 
+                reg_data &=~(0x1E00000);
+		MSP85x0_GE_WRITE(MSP85x0_GE_XDMA_CONFIG, reg_data);
+	}
+
+	msp85x0_ge_eth->tx_threshold = 0;
+	msp85x0_ge_eth->rx_threshold = 0;
+
+        /* We need to write the descriptors for Tx and Rx */
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_TX_DESC + (port_num << XDMA_PORT_OFFSET)),
+                       (unsigned long) msp85x0_ge_eth->tx_dma);
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_RX_DESC + (port_num << XDMA_PORT_OFFSET)),
+                       (unsigned long) msp85x0_ge_eth->rx_dma);
+
+        /* IR register for the XDMA */
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_GDI_INTERRUPT_ENABLE + (port_num << XDMA_PORT_OFFSET));
+        reg_data |= 0xF006C000; /* No Rx_OOD */
+        MSP85x0_GE_WRITE((MSP85x0_GE_GDI_INTERRUPT_ENABLE + (port_num << XDMA_PORT_OFFSET)), reg_data);
+
+	tx_ring = get_ring_count(MSP85x0_GE_TX_QUEUE/64);
+	tx_ring = tx_ring << 27;
+	rx_ring = get_ring_count(MSP85x0_GE_RX_QUEUE/64);
+	rx_ring = rx_ring << 16;
+
+	// Should be written while XDMA in the reset
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET));
+	reg_data &=~(7 << 27); 	// Clear Tx descriptor ring size
+	reg_data &=~(7 << 16); 	// Clear Rx descriptor ring size
+	reg_data |=(tx_ring | rx_ring);
+	reg_data |= 0x400;  	// Rx TCP Checksum
+        if(MSP85x0_GE_RX_BUFSIZE % 512)
+        {
+                printk(KERN_ERR"\n\r ERROR!! Invalid Rx buffer size.   ");
+                printk(KERN_ERR"\n\r         should be mulitple of 512.");
+                printk(KERN_ERR"\n\r Current size=0x%x",MSP85x0_GE_RX_BUFSIZE) ;
+        }
+	reg_data |= (get_rx_buff_size(MSP85x0_GE_RX_BUFSIZE/512) << 5);
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET)), reg_data);
+	// Rx desc iTH thershold for packet drop
+	reg_data=2;  // 0 ->4 , 1 -> 8, 2 -> 16, 3 -> 32 
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_RX_DESC_PKT_DRP_THR + (port_num << XDMA_PORT_OFFSET)), reg_data);
+        MSP85x0_GE_WRITE((MSP85x0_GE_GDI_PASSPW_CONFIG + (port_num << XDMA_PORT_OFFSET)),0x101);
+
+	/* Start the Tx and Rx XDMA controller */
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET));
+        reg_data &= ~(1 << 31);     /* Clear tx reset */
+        reg_data &= ~(1 << 20);     /* Clear rx reset */
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_CONFIG + (port_num << XDMA_PORT_OFFSET)), reg_data);
+
+        /* Rx desc count */
+        count=msp85x0_ge_rx_task(netdev, msp85x0_ge_eth);
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_RX_DMA_STS + (msp85x0_ge_eth->port_num << 9)),count);
+	msp85x0_ge_eth->rx_local_desc_count=count;	
+	udelay(30);
+	return 0;
+}
+
+
+/*
+ * Start the port. All the hardware specific configuration
+ * for the XDMA, Tx FIFO, Rx FIFO, TMAC, RMAC, TRTG and AFX
+ * go here
+ */
+static int msp85x0_ge_port_start(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	int port_num = msp85x0_ge_eth->port_num;
+
+	xdma_config(netdev);
+   	msp85x0_eth_setup_tx_rx_fifo(netdev);
+	trtg_block_enable(netdev);
+	start_tx_and_rx_activity(netdev);
+
+	msp85x0_ge_gmii_config(port_num);
+	enable_tx_and_rx_interrupts(netdev);
+
+	if (config_done == 0) {
+		config_done = 1;
+	}
+
+	return MSP85x0_OK;
+}
+/*
+ * Function to queue the packet for the Ethernet device
+ */
+static void msp85x0_ge_tx_queue(msp85x0_ge_port_info * msp85x0_ge_eth,
+				struct sk_buff * skb)
+{
+	struct device *device = &msp85x0_ge_device[msp85x0_ge_eth->port_num]->dev;
+	unsigned int curr_desc = msp85x0_ge_eth->tx_curr_desc_q;
+	volatile msp85x0_ge_tx_desc *tx_curr;
+	int port_num = msp85x0_ge_eth->port_num;
+	unsigned int pkts;
+
+	tx_curr = &(msp85x0_ge_eth->tx_desc_area[curr_desc]);
+
+	pkts=MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_TX_DMA_STS+ (port_num << XDMA_PORT_OFFSET)) & 0x3FF;
+	if(pkts < 1023)	
+	{
+		tx_curr->buffer_addr =dma_map_single(device, skb->data, skb_headlen(skb),
+			       DMA_TO_DEVICE);
+
+		msp85x0_ge_eth->tx_skb[curr_desc] = (struct sk_buff *) skb;
+		tx_curr->buffer_len = skb_headlen(skb);
+
+		/* Last descriptor enables interrupt and changes ownership */
+		tx_curr->cmd_sts = 0x1 | (1 << 15) | (1 << 5);
+		
+   		DMA_CACHE_WBACK_INV((unsigned long)tx_curr,sizeof(msp85x0_ge_tx_desc));
+			
+        	/* Kick the XDMA to start the transfer from memory to the FIFO */
+        	MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_TX_DMA_STS + (port_num << XDMA_PORT_OFFSET)), 0x1);
+		/* Have the packet count updated */
+		increment_tx_pkt_count(port_num);
+		/* Current descriptor updated */
+		msp85x0_ge_eth->tx_curr_desc_q = (curr_desc + 1) % MSP85x0_GE_TX_QUEUE;
+
+		/* Prefetch the next descriptor */
+		prefetch((const void *)&msp85x0_ge_eth->tx_desc_area[msp85x0_ge_eth->tx_curr_desc_q]);
+	}
+
+}
+
+static int msp85x0_eth_set_mac_addr(struct net_device *dev)
+{
+   msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(dev);
+   unsigned int port = msp85x0_ge_eth->port_num;
+   unsigned char addr[6];
+   unsigned int i,retries=1000;
+  	
+   
+   memcpy(addr, dev->dev_addr, 6);
+   
+   /* TMAC address */
+   MSP85x0_GE_WRITE(MSP85x0_GE_TMAC_STATION_HI + (port<<12),
+                  (addr[5] << 8) | addr[4]);
+   MSP85x0_GE_WRITE(MSP85x0_GE_TMAC_STATION_MID + (port<<12),
+                  (addr[3] << 8) | addr[2]);
+   MSP85x0_GE_WRITE(MSP85x0_GE_TMAC_STATION_LOW + (port<<12),
+                  (addr[1] << 8) | addr[0]);
+
+   /* RMAC address */
+   MSP85x0_GE_WRITE(MSP85x0_GE_RMAC_STATION_HI + (port<<12),
+                  (addr[5] << 8) | addr[4]);
+   MSP85x0_GE_WRITE(MSP85x0_GE_RMAC_STATION_MID + (port<<12),
+                  (addr[3] << 8) | addr[2]);
+   MSP85x0_GE_WRITE(MSP85x0_GE_RMAC_STATION_LOW + (port<<12),
+                  (addr[1] << 8) | addr[0]);
+
+   for (i=0; i<8; i++)
+   {
+      /* select address filter */
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_2 + (port<<12), i);
+      
+      /* accept on match */
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_0 + (port<<12), 0x9);
+      
+      /* exact match */
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_EXACT_MATCH_LOW + (port<<12),
+                     (addr[1] << 8) | addr[0]);
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_EXACT_MATCH_MID + (port<<12),
+                     (addr[3] << 8) | addr[2]);
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_EXACT_MATCH_HIGH + (port<<12),
+                     (addr[5] << 8) | addr[4]);
+
+      /* set VLAN id to 0 */
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_EXACT_MATCH_VID + (port<<12), 0);
+      
+      /* update address filter */
+      MSP85x0_GE_WRITE(MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_3 + (port<<12), 1);
+      while (retries)
+      {
+	if(!(MSP85x0_GE_READ(MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_3 + (port<<12)) & 1))
+	{
+		break;
+	}
+	mdelay(1);
+	retries--;
+      }
+      if(!retries)
+      {
+      	 printk("\n\r Unable to update the filters ");
+      	 return MSP85x0_ERROR;
+      }
+    }	
+ 	return MSP85x0_OK; 
+}
+static int msp85x0_eth_setup_tx_ring(struct net_device *dev)
+{
+   msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(dev);
+   unsigned int port_num = msp85x0_ge_eth->port_num,retval;
+
+   /* Allocate the Tx ring now */
+   msp85x0_ge_eth->tx_ring_skbs = 0;
+   msp85x0_ge_eth->tx_ring_size = MSP85x0_GE_TX_QUEUE;
+
+   /* Allocate space in the SRAM for the descriptors */
+
+   msp85x0_ge_eth->tx_desc_area = (msp85x0_ge_tx_desc *)
+  		(msp85x0_ge_sram + MSP85x0_TX_RING_BYTES * port_num);
+   msp85x0_ge_eth->tx_desc_area_size =
+	     msp85x0_ge_eth->tx_ring_size * sizeof(msp85x0_ge_tx_desc);
+
+   msp85x0_ge_eth->tx_dma = MSP85x0_SRAM_BASE + MSP85x0_TX_RING_BYTES * port_num;
+   GE_DBG("tx_dma=0x%x\n",(unsigned int)msp85x0_ge_eth->tx_dma);
+   GE_DBG("tx_desc_area=0x%x\n",(unsigned int )msp85x0_ge_eth->tx_desc_area);
+
+   if (!msp85x0_ge_eth->tx_desc_area) 
+   {
+   	printk(KERN_ERR"%s: Cannot allocate Tx Ring (size %d bytes) for port %d \n",dev->name, MSP85x0_TX_RING_BYTES, port_num);
+	return MSP85x0_ERROR;
+   }
+
+   memset((void *)msp85x0_ge_eth->tx_desc_area, 0, msp85x0_ge_eth->tx_desc_area_size);
+	
+   /* Now initialize the Tx descriptor ring */
+   retval=msp85x0_ge_init_tx_desc_ring(msp85x0_ge_eth,msp85x0_ge_eth->tx_ring_size,
+	   (unsigned long) msp85x0_ge_eth->tx_desc_area,
+	   (unsigned long) msp85x0_ge_eth->tx_dma);
+ 
+   DMA_CACHE_WBACK_INV((unsigned long)msp85x0_ge_eth->tx_desc_area,msp85x0_ge_eth->tx_desc_area_size);
+
+   if(retval!=MSP85x0_OK)
+   {
+	printk("\n\r Error initializing descriptor ...");
+	return MSP85x0_ERROR;		
+   }
+   return retval;
+}
+
+static int msp85x0_eth_setup_rx_ring(struct net_device *dev)
+{
+   msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(dev);
+   unsigned int port_num = msp85x0_ge_eth->port_num;
+
+
+   /* Allocate the Rx ring now */
+   msp85x0_ge_eth->rx_ring_size = MSP85x0_GE_RX_QUEUE;
+   msp85x0_ge_eth->rx_ring_skbs = 0;
+  
+   msp85x0_ge_eth->rx_desc_area =
+                (msp85x0_ge_rx_desc *)(msp85x0_ge_sram + 0x4000 + MSP85x0_RX_RING_BYTES * port_num);
+   msp85x0_ge_eth->rx_dma = MSP85x0_SRAM_BASE + 0x4000 + MSP85x0_RX_RING_BYTES * port_num;
+
+   msp85x0_ge_eth->rx_desc_area_size =
+	     msp85x0_ge_eth->rx_ring_size * sizeof(msp85x0_ge_rx_desc);
+
+   GE_DBG("rx_dma=0x%p\n", (void *)msp85x0_ge_eth->rx_dma);
+   GE_DBG("rx_desc_area=0x%p\n",(void *)msp85x0_ge_eth->rx_desc_area);
+
+   if (!msp85x0_ge_eth->rx_desc_area) {
+	printk(KERN_ERR "%s: Cannot allocate Rx Ring (size %d bytes)\n",
+	       dev->name, MSP85x0_RX_RING_BYTES);
+	printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
+	       dev->name);
+	return MSP85x0_ERROR;
+   }
+   memset((void *)msp85x0_ge_eth->rx_desc_area, 0, msp85x0_ge_eth->rx_desc_area_size);
+
+   /* Now initialize the Rx ring */
+   if ((msp85x0_ge_init_rx_desc_ring
+       (msp85x0_ge_eth, msp85x0_ge_eth->rx_ring_size, MSP85x0_GE_RX_BUFSIZE,
+      (unsigned long) msp85x0_ge_eth->rx_desc_area, 0,
+      (unsigned long) msp85x0_ge_eth->rx_dma)) == 0)
+   {	
+       panic("%s: Error initializing RX Ring\n", dev->name);
+	return MSP85x0_ERROR;
+   }
+  DMA_CACHE_WBACK_INV((unsigned long)msp85x0_ge_eth->rx_desc_area,msp85x0_ge_eth->rx_desc_area_size);
+
+   return MSP85x0_OK;
+}
+
+static int msp85x0_eth_setup_tx_rx_fifo(struct net_device *dev)
+{
+   	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(dev);
+   	unsigned int port = msp85x0_ge_eth->port_num;
+
+	unsigned int reg_data,reg_data1;
+
+        /* Enable RX FIFO 0 and 8 */
+	// RX FIFO
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_0 + (port * SQDPF_RX_PORT_OFFSET));
+        reg_data |= 0x100000;
+	MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RXFIFO_0 + (port * SQDPF_RX_PORT_OFFSET), reg_data);
+        /*
+         * BAV2,BAV and DAV settings for the Rx FIFO
+	 *
+   	 * The recommendation for RxFIFO is to minimize DAV_TH, minimize BAV_TH, and set BAV2_TH to its min.
+         * DAV_TH min = 2.
+         * BAV_TH min = 2.
+         * BAV2_TH min = BAV_TH min + 3 = 2+3 = 5.
+	 */
+        reg_data = 0x00500802;
+        MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RX_THRLD_0 + (port * SQDPF_RX_PORT_OFFSET), reg_data);
+
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_0 + (port * SQDPF_RX_PORT_OFFSET));
+	reg_data = 0x00260000;
+        reg_data |=(port << 7);
+        reg_data |=(port << 8);
+        MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_RXFIFO_0 + (port * SQDPF_RX_PORT_OFFSET), reg_data);
+
+	// TX FIFO
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_SDQPF_TXFIFO_0 + (port * SQDPF_TX_PORT_OFFSET));
+        reg_data |= 0x100000;
+        MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_TXFIFO_0 + (port * SQDPF_TX_PORT_OFFSET), reg_data);
+        /*
+         *  BAV2, BAV and DAV settings for the Tx FIFO
+         *
+         *  The recommendation for TxFIFO is to maximize DAV_TH, minimize BAV_TH, 
+         *  and set BAV2_TH to its min.
+         *  DAV_TH max = SIZE-3.  So for 4KB physical buffer this is (128 - 3) = 125.
+         *  BAV_TH min = 2.
+         *  BAV2_TH min = BAV_TH min + 3 = 2+3 = 5.
+	 */
+
+        reg_data1 = 0x0050087D;
+        MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_TX_THRLD_0 + (port * SQDPF_TX_PORT_OFFSET), reg_data1);
+
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_SDQPF_TXFIFO_0 + (port * SQDPF_TX_PORT_OFFSET));
+	reg_data = 0x220000;
+	reg_data |=(port << 7);
+        MSP85x0_GE_WRITE(MSP85x0_GE_SDQPF_TXFIFO_0 + (port * SQDPF_TX_PORT_OFFSET), reg_data);
+	return MSP85x0_OK;
+}
+
+
+static int msp85x0_ge_eth_open(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	unsigned long reg_data;
+	unsigned int phy_reg;
+	int err = 0;
+
+	int tbi_mode;
+	if(config_done == 0){
+		reg_data = MSP85x0_GE_READ(MSP85x0_GE_TSB_CTRL_0);
+		tbi_mode =(reg_data & 0x700) >> 8;
+	
+		if(!tbi_mode)
+		{	
+			reg_data &=~(0x700);
+			MSP85x0_GE_WRITE(MSP85x0_GE_TSB_CTRL_0,reg_data);
+		}
+	}
+
+	/* Stop the Rx activity */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET));
+	reg_data &= ~(0x00000001);
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_CONFIG_1 + (port_num << MAC_PORT_OFFSET)), reg_data);
+
+        /* Clear the port interrupts */
+        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_INTERRUPT +
+                        (port_num << 9)), 0xf006c002);
+	MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_INTERRUPT +
+                        (port_num << 9)), 0);
+	if (config_done == 0) {
+	        MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_CORE_A, 0xffffffff);
+	}
+	/* Set MAC address */
+   	if(msp85x0_eth_set_mac_addr(netdev)==MSP85x0_ERROR)
+	{
+		printk(KERN_ERR"\n\r Unable to update the AFX filters");
+		return MSP85x0_ERROR;
+	}
+	/* Setup Tx Ring */
+   	if(msp85x0_eth_setup_tx_ring(netdev)==MSP85x0_ERROR)
+   	{
+		printk(KERN_ERR"\n\r Unable to setup tx ring "); 
+		return MSP85x0_ERROR;
+   	}
+	/* Setup Rx Ring */	
+   	if(msp85x0_eth_setup_rx_ring(netdev)==MSP85x0_ERROR)
+   	{
+		printk(KERN_ERR"\n\r Unable to setup rx ring "); 
+		return MSP85x0_ERROR; 	
+   	}
+	/* Port Init - (Stop Tx and Rx XDMA Channels for the port)*/
+	if (config_done == 0)
+		msp85x0_port_init(netdev, msp85x0_ge_eth);
+
+	/* Fill the Rx ring with the SKBs */
+	msp85x0_ge_port_start(netdev);
+
+	/*
+	 * Check if Interrupt Coalescing needs to be turned on. The
+	 * values specified in the register is multiplied by
+	 * (8 x 64 nanoseconds) to determine when an interrupt should
+	 * be sent to the CPU.
+	 */
+	if (MSP85x0_GE_TX_COAL) {
+		msp85x0_ge_eth->tx_int_coal =
+		    msp85x0_ge_tx_coal(port_num);
+	}
+
+	err = titan_ge_mdio_read(port_num,TITAN_GE_MDIO_PHY_STATUS, &phy_reg);
+	if (err == TITAN_GE_MDIO_ERROR) {
+		printk(KERN_ERR
+		       "Could not read PHY control register 0x11 \n");
+		return MSP85x0_ERROR;
+	}
+	if (!(phy_reg & 0x0400)) {
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+		return MSP85x0_ERROR;
+	} else {
+		netif_carrier_on(netdev);
+		netif_start_queue(netdev);
+	}
+
+	return MSP85x0_OK;
+}
+
+
+/*
+ * Queue the packet for Tx. Currently no support for zero copy,
+ * checksum offload and Scatter Gather. The chip does support
+ * Scatter Gather only. But, that wont help here since zero copy
+ * requires support for Tx checksumming also.
+ */
+int msp85x0_ge_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned long flags;
+	struct net_device_stats *stats;
+
+	stats = &msp85x0_ge_eth->stats;
+	spin_lock_irqsave(&msp85x0_ge_eth->lock, flags);
+
+	if (msp85x0_ge_eth->tx_threshold > TX_THRESHOLD) {
+		msp85x0_ge_eth->tx_threshold = 0;
+		msp85x0_ge_free_tx_queue(netdev);
+	}
+	else
+		msp85x0_ge_eth->tx_threshold++;
+
+
+	if ((MSP85x0_GE_TX_QUEUE - msp85x0_ge_eth->tx_ring_skbs) <=
+	    (skb_shinfo(skb)->nr_frags + 1)) {
+	printk("\n\r tx fragments = %d",skb_shinfo(skb)->nr_frags); 
+		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+		printk(KERN_ERR "Tx OOD \n");
+		return 1;
+	}
+
+	msp85x0_ge_tx_queue(msp85x0_ge_eth, skb);
+	msp85x0_ge_eth->tx_ring_skbs++;
+
+	stats->tx_bytes += skb->len;
+	stats->tx_packets++;
+
+	spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
+	netdev->trans_start = jiffies;
+	return 0;
+}
+
+/*
+ * Actually does the Rx. Rx side checksumming supported.
+ */
+static int msp85x0_ge_rx(struct net_device *netdev, int port_num,
+			msp85x0_ge_port_info * msp85x0_ge_eth,
+		       msp85x0_ge_packet * packet)
+{
+	int rx_curr_desc, rx_used_desc;
+	volatile msp85x0_ge_rx_desc *rx_desc;
+
+	rx_curr_desc = msp85x0_ge_eth->rx_curr_desc_q;
+	rx_used_desc = msp85x0_ge_eth->rx_used_desc_q;
+	port_num     = msp85x0_ge_eth->port_num;
+
+	rx_desc = &(msp85x0_ge_eth->rx_desc_area[rx_curr_desc]);
+
+	packet->skb = msp85x0_ge_eth->rx_skb[rx_curr_desc];
+	packet->len = (rx_desc->cmd_sts & 0x7fff);
+
+	/*
+	 * At this point, we dont know if the checksumming
+	 * actually helps relieve CPU. So, keep it for
+	 * port 0 only
+	 */
+	packet->checksum = ntohs((rx_desc->buffer & 0xffff0000) >> 16);
+	packet->cmd_sts = rx_desc->cmd_sts;
+
+	if((rx_curr_desc + 1) == MSP85x0_GE_RX_QUEUE)
+		msp85x0_ge_eth->rx_curr_desc_q =0;
+	else
+		msp85x0_ge_eth->rx_curr_desc_q = (rx_curr_desc + 1);
+	msp85x0_ge_eth->rx_ring_skbs--;
+	msp85x0_ge_eth->rx_local_desc_count--;
+
+	/* Prefetch the next descriptor */
+	prefetch((const void *)
+	       &msp85x0_ge_eth->rx_desc_area[msp85x0_ge_eth->rx_curr_desc_q]);
+
+	return MSP85x0_OK;
+}
+
+/*
+ * Free the Tx queue of the used SKBs
+ */
+static int msp85x0_ge_free_tx_queue(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	int pkts,port_num = msp85x0_ge_eth->port_num;
+	int tx_desc_used;
+	struct sk_buff *skb;
+
+	/* Take the lock */
+	pkts=get_tx_pkt_count(port_num);
+	while(pkts)
+	{
+		pkts--;
+		tx_desc_used = msp85x0_ge_eth->tx_used_desc_q;
+
+		/* return right away */
+		if (tx_desc_used == msp85x0_ge_eth->tx_curr_desc_q)
+			break;
+	
+		skb = msp85x0_ge_eth->tx_skb[tx_desc_used];
+		dev_kfree_skb_irq(skb);
+		msp85x0_ge_eth->tx_skb[tx_desc_used] = NULL;
+
+		if((tx_desc_used + 1) == MSP85x0_GE_TX_QUEUE)
+			msp85x0_ge_eth->tx_used_desc_q=0;
+		else
+			msp85x0_ge_eth->tx_used_desc_q=tx_desc_used + 1;
+
+		if (msp85x0_ge_eth->tx_ring_skbs > 0)
+		{
+			msp85x0_ge_eth->tx_ring_skbs--;
+			decrement_tx_pkt_count(port_num);
+		}
+	}
+	return MSP85x0_OK;
+}
+
+/*
+ * Threshold beyond which we do the cleaning of
+ * Tx queue and new allocation for the Rx
+ * queue
+ */
+/*
+ * Receive the packets and send it to the kernel.
+ */
+
+
+static int msp85x0_ge_receive_queue(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	msp85x0_ge_packet packet;
+	struct net_device_stats *stats;
+	struct sk_buff *skb;
+	unsigned long received_packets = 0;
+	unsigned int ack;
+	int max=-1;
+
+	unsigned int rx_dma_desc_count;
+	unsigned int total_desc_recvd;
+
+	rx_dma_desc_count=MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_RX_DMA_STS + (port_num << 9));		
+	if(msp85x0_ge_eth->rx_local_desc_count == rx_dma_desc_count)
+	{
+		return MSP85x0_ERROR;
+	}
+	if(rx_dma_desc_count > msp85x0_ge_eth->rx_local_desc_count)
+	{
+		printk(KERN_ERR"\n\r The DMA and S/W counter are not in SYNC !!");
+		return MSP85x0_ERROR;
+	}
+	total_desc_recvd=msp85x0_ge_eth->rx_local_desc_count - rx_dma_desc_count;
+	max=total_desc_recvd;
+
+	oom_flag=0;
+	stats = &msp85x0_ge_eth->stats;
+	while ((max--) && 
+	       (msp85x0_ge_rx(netdev, port_num, msp85x0_ge_eth, &packet) == MSP85x0_OK))
+ 	{	
+		skb = (struct sk_buff *) packet.skb;
+		if(!skb)
+		{
+			printk(KERN_ERR"\n\r Null SKB !!! ");
+			break;
+		}
+
+		msp85x0_ge_eth->rx_work_limit--;
+
+		received_packets++;
+
+		if (msp85x0_ge_eth->rx_threshold > RX_THRESHOLD) {
+			ack=msp85x0_ge_rx_task(netdev, msp85x0_ge_eth);
+		        MSP85x0_GE_WRITE((MSP85x0_GE_CHANNEL0_RX_DMA_STS + (msp85x0_ge_eth->port_num << 9)),ack);
+			msp85x0_ge_eth->rx_local_desc_count +=ack;	
+			if(!oom_flag){
+				msp85x0_ge_eth->rx_threshold = 0;
+			}
+		} else
+			msp85x0_ge_eth->rx_threshold++;
+
+		if (packet.cmd_sts & (MSP85x0_GE_RX_PERR | MSP85x0_GE_RX_OVERFLOW_ERROR | MSP85x0_GE_RX_TRUNC | MSP85x0_GE_RX_CRC_ERROR))
+		{
+			if(packet.cmd_sts & MSP85x0_GE_RX_OVERFLOW_ERROR)
+				stats->rx_over_errors++; 
+			else if(packet.cmd_sts & MSP85x0_GE_RX_TRUNC)
+				stats->rx_frame_errors++;
+			else
+				stats->rx_errors++;
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+                if(!(packet.cmd_sts & MSP85x0_GE_RX_STP))
+                {
+                        stats->rx_dropped++;
+                        dev_kfree_skb_any(skb);
+                        continue;
+                }
+ 
+
+		/*
+		 * Increment data pointer by two since thats where
+		 * the MAC starts
+		 */
+		skb_reserve(skb, 2);
+		/*
+		 * Either support fast path or slow path. Decision
+		 * making can really slow down the performance. The
+		 * idea is to cut down the number of checks and improve
+		 * the fastpath.
+		 */
+		skb_put(skb, packet.len - 2);
+
+		skb->protocol = eth_type_trans(skb, netdev);
+
+		if(netif_receive_skb(skb)==NET_RX_DROP)
+		{
+			stats->rx_dropped++;
+		}
+		else
+		{
+			stats->rx_packets++;
+			stats->rx_bytes += packet.len;
+		}
+		if (!msp85x0_ge_eth->rx_work_limit || (oom_flag==1))
+		{
+			break;
+		}
+	}
+	return received_packets;
+}
+
+/*
+ * Main function to handle the polling for Rx side NAPI.
+ * Receive interrupts have been disabled at this point.
+ * The poll schedules the transmit followed by receive.
+ */
+static int msp85x0_ge_poll(struct net_device *netdev, int *budget)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	int port_num = msp85x0_ge_eth->port_num;
+	int work_done = 0;
+	unsigned long flags, status;	
+
+	msp85x0_ge_eth->rx_work_limit = *budget;
+	if ((int)msp85x0_ge_eth->rx_work_limit > netdev->quota)
+		msp85x0_ge_eth->rx_work_limit = netdev->quota;
+
+	do {
+		/* Ack the Rx interrupts */
+		clear_xdma_interrupts(port_num,RX_INT);
+		work_done += msp85x0_ge_receive_queue(netdev);
+		/* Out of quota and there is work to be done */
+		if((oom_flag == 1) || (msp85x0_ge_eth->rx_work_limit <= 0))
+		{
+			*budget -= work_done;
+			netdev->quota -= work_done;
+			return 1;
+		}
+		status = MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_CORE_A);
+	}
+	while (status & (RX_INT << (XDMA_CHANNEL_OFFSET * port_num)));	
+
+	/* If we are here, then no more interrupts to process */
+	/*
+	 * No more packets on the poll list. Turn the interrupts
+	 * back on and we should be able to catch the new
+	 * packets in the interrupt handler
+	 */
+	spin_lock_irqsave(&msp85x0_ge_eth->lock,flags);
+	if (!work_done)
+		work_done = 1;
+
+	*budget -= work_done;
+	netdev->quota -= work_done;
+
+	/* Remove us from the poll list */
+	netif_rx_complete(netdev);
+
+	/* Re-enable interrupts */
+	msp85x0_ge_enable_rx_int(port_num);
+	spin_unlock_irqrestore(&msp85x0_ge_eth->lock,flags);
+	return 0;
+}
+
+/*
+ * Close the network device
+ */
+int msp85x0_ge_stop(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+
+	spin_lock_irq(&(msp85x0_ge_eth->lock));
+	msp85x0_ge_eth_stop(netdev);
+	free_irq(netdev->irq, netdev);
+	spin_unlock_irq(&msp85x0_ge_eth->lock);
+	return MSP85x0_OK;
+}
+
+/* Don't Re-Initialize the port, Just start from where it stops */ 
+static int msp85x0_ge_eth_reopen(struct net_device *netdev)	
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int reg_data,irq;
+	int retval;
+
+        irq = MSP85x0_ETH_PORT_IRQ;
+
+	retval = request_irq(irq, INTERRUPT_HANDLER,
+		     SA_INTERRUPT | SA_SAMPLE_RANDOM | SA_SHIRQ, netdev->name, netdev);
+
+	if (retval != 0) {
+		printk(KERN_ERR "Cannot assign IRQ number to MSP85x0 GE \n");
+		return -1;
+	}
+
+	netdev->irq = irq;
+	printk(KERN_INFO "Assigned IRQ %d to port %d\n", irq, msp85x0_ge_eth->port_num);
+
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_IE);
+	reg_data |=(RX_INT << (msp85x0_ge_eth->port_num * 16));
+	MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_IE,reg_data);
+
+	netif_start_queue(netdev);	
+	msp85x0_bringup_sequence(msp85x0_ge_eth->port_num);
+	return 0;
+}
+
+/*
+ * Actually does the stop of the Ethernet device
+ */
+static void msp85x0_ge_eth_stop(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int reg_data;
+
+	/* Tell Kernel to release this interface */
+	netif_stop_queue(netdev);
+	/* Disable the Tx and Rx Interrupts for the port*/
+	reg_data=MSP85x0_GE_READ(MSP85x0_GE_INTR_XDMA_IE);
+	reg_data &=~(0x3 << (msp85x0_ge_eth->port_num * 16));
+	MSP85x0_GE_WRITE(MSP85x0_GE_INTR_XDMA_IE,reg_data);
+	/* set the open function to re-open */
+	/* This to work around to solve the msp85x0 shutdown and bringup sequence */
+	netdev->open=msp85x0_ge_eth_reopen;
+	msp85x0_reset_sequence(msp85x0_ge_eth->port_num);
+}
+
+/*
+ * Update the MAC address. Note that we have to write the
+ * address in three station registers, 16 bits each. And this
+ * has to be done for TMAC and RMAC
+ */
+static void msp85x0_ge_update_mac_address(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+	unsigned int port_num = msp85x0_ge_eth->port_num;
+	u8 p_addr[6];
+
+	memcpy(msp85x0_ge_eth->port_mac_addr, netdev->dev_addr, 6);
+	memcpy(p_addr, netdev->dev_addr, 6);
+
+	/* Update the Address Filtering Match tables */
+	msp85x0_ge_update_afx(msp85x0_ge_eth);
+
+	printk("Station MAC : %d %d %d %d %d %d  \n",
+		p_addr[5], p_addr[4], p_addr[3],
+		p_addr[2], p_addr[1], p_addr[0]);
+
+	/* Set the MAC address here for TMAC and RMAC */
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_HI + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[5] << 8) | p_addr[4]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_MID + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[3] << 8) | p_addr[2]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_STATION_LOW + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[1] << 8) | p_addr[0]));
+
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_HI + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[5] << 8) | p_addr[4]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_MID + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[3] << 8) | p_addr[2]));
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_STATION_LOW + (port_num << MAC_PORT_OFFSET)),
+		       ((p_addr[1] << 8) | p_addr[0]));
+}
+
+/*
+ * Set the MAC address of the Ethernet device
+ */
+static int msp85x0_ge_set_mac_address(struct net_device *dev, void *addr)
+{
+	msp85x0_ge_port_info *tp = netdev_priv(dev);
+	struct sockaddr *sa = addr;
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+
+	spin_lock_irq(&tp->lock);
+	msp85x0_ge_update_mac_address(dev);
+	spin_unlock_irq(&tp->lock);
+
+	return 0;
+}
+
+/*
+ * Get the Ethernet device stats
+ */
+static struct net_device_stats *msp85x0_ge_get_stats(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
+
+	return &msp85x0_ge_eth->stats;
+}
+
+/*
+ * Initialize the Rx descriptor ring for the MSP85x0 Ge
+ */
+static int msp85x0_ge_init_rx_desc_ring(msp85x0_ge_port_info * msp85x0_eth_port,
+				      int rx_desc_num,
+				      int rx_buff_size,
+				      unsigned long rx_desc_base_addr,
+				      unsigned long rx_buff_base_addr,
+				      unsigned long rx_dma)
+{
+	volatile msp85x0_ge_rx_desc *rx_desc;
+	unsigned long buffer_addr;
+	int index;
+	unsigned long msp85x0_ge_rx_desc_bus = rx_dma;
+
+	buffer_addr = rx_buff_base_addr;
+	rx_desc = (msp85x0_ge_rx_desc *) rx_desc_base_addr;
+
+	/* Check alignment */
+	if (rx_buff_base_addr & 0xF)
+		return 0;
+
+	/* Check Rx buffer size */
+	if ((rx_buff_size < 8) || (rx_buff_size > MSP85x0_GE_MAX_RX_BUFFER))
+		return 0;
+
+	/* Initialize the Rx desc ring */
+	for (index = 0; index < rx_desc_num; index++) {
+		msp85x0_ge_rx_desc_bus += sizeof(msp85x0_ge_rx_desc);
+		rx_desc[index].cmd_sts = 0;
+		rx_desc[index].buffer_addr = 0;
+		msp85x0_eth_port->rx_skb[index] = NULL;
+		buffer_addr += rx_buff_size;
+	}
+
+	msp85x0_eth_port->rx_curr_desc_q = 0;
+	msp85x0_eth_port->rx_used_desc_q = 0;
+
+	msp85x0_eth_port->rx_desc_area = (msp85x0_ge_rx_desc *) rx_desc_base_addr;
+	msp85x0_eth_port->rx_desc_area_size =
+	    rx_desc_num * sizeof(msp85x0_ge_rx_desc);
+
+	msp85x0_eth_port->rx_dma = rx_dma;
+
+	return MSP85x0_OK;
+}
+
+/*
+ * Initialize the Tx descriptor ring. Descriptors in the SRAM
+ */
+static int msp85x0_ge_init_tx_desc_ring(msp85x0_ge_port_info * msp85x0_ge_eth,
+				      int tx_desc_num,
+				      unsigned long tx_desc_base_addr,
+				      unsigned long tx_dma)
+{
+	msp85x0_ge_tx_desc *tx_desc;
+	int index;
+	unsigned long msp85x0_ge_tx_desc_bus = tx_dma;
+
+	if (tx_desc_base_addr & 0xF)
+	{
+		printk(KERN_ERR"\n\r Descriptor Base is not 16 byte aligned !!=0x%lx",tx_desc_base_addr);
+		return 0;
+	}
+
+	tx_desc = (msp85x0_ge_tx_desc *) tx_desc_base_addr;
+
+	for (index = 0; index < tx_desc_num; index++) {
+		msp85x0_ge_eth->tx_dma_array[index] =
+		    (dma_addr_t) msp85x0_ge_tx_desc_bus;
+		msp85x0_ge_tx_desc_bus += sizeof(msp85x0_ge_tx_desc);
+		tx_desc[index].cmd_sts = 0x0000;
+		tx_desc[index].buffer_len = 0;
+		tx_desc[index].buffer_addr = 0x00000000;
+		msp85x0_ge_eth->tx_skb[index] = NULL;
+	}
+
+	msp85x0_ge_eth->tx_curr_desc_q = 0;
+	msp85x0_ge_eth->tx_used_desc_q = 0;
+
+	msp85x0_ge_eth->tx_desc_area = (msp85x0_ge_tx_desc *) tx_desc_base_addr;
+	msp85x0_ge_eth->tx_desc_area_size =
+	    tx_desc_num * sizeof(msp85x0_ge_tx_desc);
+
+	msp85x0_ge_eth->tx_dma = tx_dma;
+	return MSP85x0_OK;
+}
+
+/*
+ * Initialize the device as an Ethernet device
+ */
+static void __init msp85x0_ge_probe(struct net_device *netdev)
+{
+	msp85x0_ge_port_info *msp85x0_ge_eth;
+	unsigned int port = port_number;
+
+	ether_setup(netdev);
+
+	netdev->open = msp85x0_ge_open;
+	netdev->stop = msp85x0_ge_stop;
+	netdev->hard_start_xmit = msp85x0_ge_start_xmit;
+	netdev->get_stats = msp85x0_ge_get_stats;
+	netdev->set_multicast_list = msp85x0_ge_set_multi;
+	netdev->set_mac_address = msp85x0_ge_set_mac_address;
+
+	/* Tx timeout */
+	netdev->tx_timeout = msp85x0_ge_tx_timeout;
+	netdev->watchdog_timeo = 2 * HZ;
+
+	/* Set these to very high values */
+	netdev->poll = msp85x0_ge_poll;
+	netdev->weight = 64;
+
+	netdev->tx_queue_len = MSP85x0_GE_TX_QUEUE;
+	netdev->base_addr = 0;
+
+	netdev->change_mtu = msp85x0_ge_change_mtu;
+
+	msp85x0_ge_eth = netdev_priv(netdev);
+	/* Allocation of memory for the driver structures */
+
+	msp85x0_ge_eth->port_num = port;
+
+	/* Configure the Tx timeout handler */
+	INIT_WORK(&msp85x0_ge_eth->tx_timeout_task,
+		  (void (*)(void *)) msp85x0_ge_tx_timeout_task, netdev);
+	/* we're going to reset, so assume we have no link for now */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+	spin_lock_init(&msp85x0_ge_eth->lock);
+
+	/*
+	 * Set MAC addresses: we assume that PMON correctly sets
+	 * up MAC addresses
+	 */
+	netdev->dev_addr[0] = 
+	  	MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_LOW + 
+			       (port << MAC_PORT_OFFSET))) & 0xff;
+	netdev->dev_addr[1] = 
+		MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_LOW + 
+			       (port << MAC_PORT_OFFSET))) >> 8;
+	netdev->dev_addr[2] = 
+		MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_MID + 
+			       (port << MAC_PORT_OFFSET))) & 0xff;
+	netdev->dev_addr[3] = 
+		MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_MID + 
+			       (port << MAC_PORT_OFFSET))) >> 8;
+	netdev->dev_addr[4] = 
+		MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_HI + 
+			       (port << MAC_PORT_OFFSET))) & 0xff;
+	netdev->dev_addr[5] = 
+		MSP85x0_GE_READ((MSP85x0_GE_TMAC_STATION_HI + 
+			       (port << MAC_PORT_OFFSET))) >> 8;
+
+	printk(KERN_NOTICE
+	       "%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+	       netdev->name, port, netdev->dev_addr[0],
+	       netdev->dev_addr[1], netdev->dev_addr[2],
+	       netdev->dev_addr[3], netdev->dev_addr[4],
+	       netdev->dev_addr[5]);
+
+	printk(KERN_NOTICE "Rx NAPI supported, Tx Coalescing ON \n");
+
+	return;
+}
+
+/*
+ * Reset the Ethernet port
+ */
+static void msp85x0_ge_port_reset(unsigned int port_num)
+{
+	unsigned int reg_data;
+	unsigned int retries=1000;
+	/* Stop the Tx port activity */
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 +
+				(port_num << MAC_PORT_OFFSET));
+	reg_data &= ~(0x0001);
+	MSP85x0_GE_WRITE((MSP85x0_GE_TMAC_CONFIG_1 +
+			(port_num << MAC_PORT_OFFSET)), reg_data);
+
+	/* Wait till TMAC is brought down. */
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 + 
+                                (port_num << MAC_PORT_OFFSET));
+        while((reg_data & 0x8000) && retries){
+		retries--;
+		udelay(30);
+                reg_data = MSP85x0_GE_READ(MSP85x0_GE_TMAC_CONFIG_1 +
+				(port_num << MAC_PORT_OFFSET));
+        }
+	if(!retries)
+	{
+		printk(KERN_ERR "Unable to stop the Tx MAC for Port %d",port_num);
+	}
+	/* Stop the Rx port activity */
+	retries=1000;
+	reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1 +
+				(port_num << MAC_PORT_OFFSET));
+	reg_data &= ~(0x0001);
+	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_CONFIG_1 +
+			(port_num << MAC_PORT_OFFSET)), reg_data);
+
+	/* Wait till all packets received and RMAC brought down. */
+        reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1 +
+                                (port_num << MAC_PORT_OFFSET));
+        while((reg_data & 0x8000) && retries){
+		retries--;
+		udelay(30);
+                reg_data = MSP85x0_GE_READ(MSP85x0_GE_RMAC_CONFIG_1 +
+                                (port_num << MAC_PORT_OFFSET));
+        }
+	if(!retries)
+	{
+		printk(KERN_ERR "Unable to stop the Rx MAC for Port %d",port_num);
+	}
+	return;
+}
+
+/*
+ * Coalescing for the Tx path
+ */
+static unsigned int msp85x0_ge_tx_coal(int port)
+{
+	unsigned int delay;
+	delay = (MSP85x0_GE_TX_COAL << 16) | MSP85x0_GE_RX_COAL;
+
+	MSP85x0_GE_WRITE(MSP85x0_GE_INT_COALESCING + (port * 4), delay);
+        MSP85x0_GE_WRITE(MSP85x0_GE_INT_COALESCING + (port * 4), delay);
+	return delay;
+}
+
+/*
+ * Register the MSP85x0 GE with the kernel
+ */
+static int __init msp85x0_ge_init_module(void)
+{
+	unsigned int version, device,regval;
+	int i,rc;
+
+	printk(KERN_NOTICE"PMC-Sierra MSP85x0 10/100/1000 Ethernet Driver \n");
+
+	msp85x0_ge_sram=(unsigned int)IOMAP(MSP85x0_SRAM_BASE,MSP85x0_SRAM_SIZE);
+	if (!msp85x0_ge_sram) {
+		printk(KERN_ERR"Mapping MSP85x0 SRAM failed\n");
+		return -ENOMEM;
+	}
+	
+	regval = MSP85x0_GE_READ(MSP85x0_GE_DEVICE_ID);
+	version= GET_GE_VERSION(regval);
+	device = GET_GE_ID(regval);
+
+	printk(KERN_NOTICE "Device Id : %x,  Version : %x \n", device, version);
+
+	for (port_number = 0; port_number < NO_PORTS; port_number++) {
+		i=port_number;
+		msp85x0_eth[i] = alloc_netdev(sizeof(struct _eth_port_ctrl),"eth%d",msp85x0_ge_probe);
+		if(!msp85x0_eth[i])
+			return -ENOMEM;
+
+		if((rc = register_netdev(msp85x0_eth[i])))
+		{
+      			printk(KERN_ERR "msp85x0_eth: error %i registering device \"%s\"\n",
+				rc, msp85x0_eth[i]->name);
+         		free_netdev(msp85x0_eth[i]);
+         		return -ENODEV;
+		
+		}
+
+	}
+	msp85x0_reset_sequence(0);
+	msp85x0_reset_sequence(1);
+	msp85x0_ge_xdma_reset();			
+   	spin_lock_init(&msp85x0_lock);
+	return 0;
+}
+
+/*
+ * Unregister the MSP85x0 GE from the kernel
+ */
+static void __exit msp85x0_ge_cleanup_module(void)
+{
+	int i;
+
+	for (i = 0; i < NO_PORTS; i++) 
+	{
+		if (msp85x0_eth[i]) 
+		{
+			unregister_netdev(msp85x0_eth[i]);
+			free_netdev(msp85x0_eth[i]);
+		}
+	}
+
+	iounmap((void *)msp85x0_ge_sram);
+}
+
+MODULE_AUTHOR("PMC Sierra Inc <thotakir@pmc-sierra.com>");
+MODULE_DESCRIPTION("MSP85x0 GE Ethernet driver");
+MODULE_LICENSE("GPL");
+
+module_init(msp85x0_ge_init_module);
+module_exit(msp85x0_ge_cleanup_module);
+
diff -Naur a/drivers/net/msp85x0_ge.h b/drivers/net/msp85x0_ge.h
--- a/drivers/net/msp85x0_ge.h	1969-12-31 16:00:00.000000000 -0800
+++ b/drivers/net/msp85x0_ge.h	2006-06-23 15:26:10.000000000 -0700
@@ -0,0 +1,452 @@
+#ifndef _MSP85x0_GE_H_
+#define _MSP85x0_GE_H_
+
+#include <linux/config.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/config.h>
+#include <linux/spinlock.h>
+#include <asm/byteorder.h>
+
+#include <asm/pmc_sequoia.h>
+
+/*
+ * These functions should be later moved to a more generic location since there
+ * will be others accessing it also
+ */
+
+// MSP85x0_GE_BASE and MSP85x0_GE_SIZE are defined in asm/pmc_sequoia.h
+
+#ifndef msec_delay
+#define msec_delay(x)   do { if(in_interrupt()) { \
+				/* Don't mdelay in interrupt context! */ \
+				BUG(); \
+			} else { \
+				set_current_state(TASK_UNINTERRUPTIBLE); \
+				schedule_timeout((x * HZ)/1000); \
+			} } while(0)
+#endif
+#define MSP85x0_GE_PORT_0
+
+#define MSP85x0_SRAM_BASE         RM9150_SRAM_BASE
+#define MSP85x0_SRAM_SIZE         RM9150_SRAM_SIZE
+
+extern unsigned long titan_ge_sram;
+
+/*
+ * We may need these constants
+ */
+#define MSP85x0_BIT0    0x00000001
+#define MSP85x0_BIT1    0x00000002
+#define MSP85x0_BIT2    0x00000004
+#define MSP85x0_BIT3    0x00000008
+#define MSP85x0_BIT4    0x00000010
+#define MSP85x0_BIT5    0x00000020
+#define MSP85x0_BIT6    0x00000040
+#define MSP85x0_BIT7    0x00000080
+#define MSP85x0_BIT8    0x00000100
+#define MSP85x0_BIT9    0x00000200
+#define MSP85x0_BIT10   0x00000400
+#define MSP85x0_BIT11   0x00000800
+#define MSP85x0_BIT12   0x00001000
+#define MSP85x0_BIT13   0x00002000
+#define MSP85x0_BIT14   0x00004000
+#define MSP85x0_BIT15   0x00008000
+#define MSP85x0_BIT16   0x00010000
+#define MSP85x0_BIT17   0x00020000
+#define MSP85x0_BIT18   0x00040000
+#define MSP85x0_BIT19   0x00080000
+#define MSP85x0_BIT20   0x00100000
+#define MSP85x0_BIT21   0x00200000
+#define MSP85x0_BIT22   0x00400000
+#define MSP85x0_BIT23   0x00800000
+#define MSP85x0_BIT24   0x01000000
+#define MSP85x0_BIT25   0x02000000
+#define MSP85x0_BIT26   0x04000000
+#define MSP85x0_BIT27   0x08000000
+#define MSP85x0_BIT28   0x10000000
+#define MSP85x0_BIT29   0x20000000
+#define MSP85x0_BIT30   0x40000000
+#define MSP85x0_BIT31   0x80000000
+
+/* Flow Control */
+#define	MSP85x0_GE_FC_NONE	0x0
+#define	MSP85x0_GE_FC_FULL	0x1
+#define	MSP85x0_GE_FC_TX_PAUSE	0x2
+#define	MSP85x0_GE_FC_RX_PAUSE	0x3
+
+/* Duplex Settings */
+#define	MSP85x0_GE_FULL_DUPLEX	0x1
+#define	MSP85x0_GE_HALF_DUPLEX	0x2
+
+/* Speed settings */
+#define	MSP85x0_GE_SPEED_1000	0x1
+#define	MSP85x0_GE_SPEED_100	0x2
+#define	MSP85x0_GE_SPEED_10	0x3
+
+/* Debugging info only */
+#undef MSP85x0_DEBUG
+
+/* Keep the rings in the Titan's SSRAM */
+#define MSP85x0_RX_RING_IN_SRAM
+
+#ifdef CONFIG_MIPS64
+#define	MSP85x0_GE_IE_MASK	0xfffffffffb001b64
+#define	MSP85x0_GE_IE_STATUS	0xfffffffffb001b60
+#else
+#define	MSP85x0_GE_IE_MASK	0xfb001b64
+#define	MSP85x0_GE_IE_STATUS	0xfb001b60
+#endif
+
+/* Support for Jumbo Frames */
+#undef MSP85x0_GE_JUMBO_FRAMES
+//#define MSP85x0_GE_JUMBO_FRAMES
+
+/* Rx buffer size */
+#ifdef MSP85x0_GE_JUMBO_FRAMES
+#define	MSP85x0_GE_RX_BUFSIZE	(16 * 1024) 
+#else
+#define	MSP85x0_GE_RX_BUFSIZE	2048  
+#endif
+
+/*
+ * Tx and Rx Interrupt Coalescing parameter. These values are
+ * for 1 Ghz processor. Rx coalescing can be taken care of
+ * by NAPI. NAPI is adaptive and hence useful. Tx coalescing
+ * is not adaptive. Hence, these values need to be adjusted
+ * based on load, CPU speed etc.
+ */
+#define	MSP85x0_GE_RX_COAL	10
+#define	MSP85x0_GE_TX_COAL	200
+
+#if defined(__BIG_ENDIAN)
+
+/* Define the Rx descriptor */
+
+typedef struct eth_rx_desc {
+	u32     reserved;	/* Unused 		*/
+	u32     buffer_addr;	/* CPU buffer address 	*/
+	u32	cmd_sts;	/* Command and Status	*/
+	u32	buffer;		/* XDMA buffer address	*/
+} msp85x0_ge_rx_desc;
+
+/* Define the Tx descriptor */
+typedef struct eth_tx_desc {
+	u16     cmd_sts;	/* Command, Status and Buffer count */
+	u16	buffer_len;	/* Length of the buffer	*/
+	u32     buffer_addr;	/* Physical address of the buffer */
+} msp85x0_ge_tx_desc;
+
+#elif defined(__LITTLE_ENDIAN)
+
+/* Define the Rx descriptor */
+typedef struct eth_rx_desc {
+        u32     buffer_addr;    /* CPU buffer address   */
+        u32     reserved;       /* Unused               */
+        u32     buffer;         /* XDMA buffer address  */
+        u32     cmd_sts;        /* Command and Status   */	
+} msp85x0_ge_rx_desc;
+
+/* Define the Tx descriptor */
+typedef struct eth_tx_desc {
+	u32     buffer_addr;	/* Physical address of the buffer */
+	u16     buffer_len;     /* Length of the buffer */
+	u16     cmd_sts;        /* Command, Status and Buffer count */
+} msp85x0_ge_tx_desc;
+#endif
+
+/* Default Tx Queue Size */
+#define MSP85x0_GE_TX_QUEUE     256
+#define MSP85x0_TX_RING_BYTES	(MSP85x0_GE_TX_QUEUE * sizeof(struct eth_tx_desc))
+
+/* Default Rx Queue Size */
+#define	MSP85x0_GE_RX_QUEUE	256
+#define MSP85x0_RX_RING_BYTES	(MSP85x0_GE_RX_QUEUE * sizeof(struct eth_rx_desc))
+
+/* Packet Structure */
+typedef struct _pkt_info {
+	unsigned int           len;
+	unsigned int            cmd_sts;
+	unsigned int            buffer;
+	struct sk_buff          *skb;
+	unsigned int		checksum;
+} msp85x0_ge_packet;
+
+
+#define	PHYS_CNT	3
+
+/* Titan Port specific data structure */
+typedef struct _eth_port_ctrl {
+	unsigned int		port_num;
+	u8			port_mac_addr[6];
+
+	/* Rx descriptor pointers */
+	int 			rx_curr_desc_q, rx_used_desc_q;
+
+	/* Tx descriptor pointers */
+	int 			tx_curr_desc_q, tx_used_desc_q;
+
+	/* Rx descriptor area */
+	volatile msp85x0_ge_rx_desc	*rx_desc_area;
+	unsigned int			rx_desc_area_size;
+	struct sk_buff*			rx_skb[MSP85x0_GE_RX_QUEUE];
+
+	/* Tx Descriptor area */
+	volatile msp85x0_ge_tx_desc	*tx_desc_area;
+	unsigned int                    tx_desc_area_size;
+	struct sk_buff*                 tx_skb[MSP85x0_GE_TX_QUEUE];
+
+	/* Timeout task */
+	struct work_struct		tx_timeout_task;
+
+	/* DMA structures and handles */
+	dma_addr_t			tx_dma;
+	dma_addr_t			rx_dma;
+	dma_addr_t			tx_dma_array[MSP85x0_GE_TX_QUEUE];
+
+	/* Device lock */
+	spinlock_t			lock;
+
+	unsigned int			tx_ring_skbs;
+	unsigned int			rx_ring_size;
+	unsigned int			tx_ring_size;
+	unsigned int			rx_ring_skbs;
+
+	struct net_device_stats		stats;
+
+	/* Tx and Rx coalescing */
+	unsigned long			rx_int_coal;
+	unsigned long			tx_int_coal;
+
+	/* Threshold for replenishing the Rx and Tx rings */
+	unsigned int			tx_threshold;
+	unsigned int			rx_threshold;
+
+	/* NAPI work limit */
+	int				rx_work_limit;
+	unsigned int 			rx_local_desc_count;
+
+} msp85x0_ge_port_info;
+
+/* Titan specific constants */
+#define	MSP85x0_ETH_PORT_IRQ		5
+
+/* Max Rx buffer */
+#define	MSP85x0_GE_MAX_RX_BUFFER		65536
+
+/* Tx and Rx Error */
+#define	MSP85x0_GE_ERROR
+
+/* Rx Descriptor Command and Status */
+
+#define	MSP85x0_GE_RX_CRC_ERROR		MSP85x0_BIT27	/* crc error */
+#define	MSP85x0_GE_RX_OVERFLOW_ERROR	MSP85x0_BIT15	/* overflow */
+#define MSP85x0_GE_RX_BUFFER_OWNED	MSP85x0_BIT21	/* buffer ownership */
+#define	MSP85x0_GE_RX_STP			MSP85x0_BIT31	/* start of packet */
+#define	MSP85x0_GE_RX_BAM			MSP85x0_BIT30	/* broadcast address match */
+#define MSP85x0_GE_RX_PAM			MSP85x0_BIT28	/* physical address match */
+#define MSP85x0_GE_RX_LAFM		MSP85x0_BIT29	/* logical address filter match */
+#define MSP85x0_GE_RX_VLAN		MSP85x0_BIT26	/* virtual lans */
+#define MSP85x0_GE_RX_PERR		MSP85x0_BIT19	/* packet error */
+#define MSP85x0_GE_RX_TRUNC		MSP85x0_BIT20	/* packet size greater than 32 buffers */
+
+/* Tx Descriptor Command */
+#define	MSP85x0_GE_TX_BUFFER_OWNED	MSP85x0_BIT5	/* buffer ownership */
+#define	MSP85x0_GE_TX_ENABLE_INTERRUPT	MSP85x0_BIT15	/* Interrupt Enable */
+
+/* Return Status */
+#define	MSP85x0_OK	0x1	/* Good Status */
+#define	MSP85x0_ERROR	0x2	/* Error Status */
+
+/* MIB specific register offset */
+#define MSP85x0_GE_MSTATX_STATS_BASE_LOW       0x0800  /* MSTATX COUNTL[15:0] */
+#define MSP85x0_GE_MSTATX_STATS_BASE_MID       0x0804  /* MSTATX COUNTM[15:0] */
+#define MSP85x0_GE_MSTATX_STATS_BASE_HI        0x0808  /* MSTATX COUNTH[7:0] */
+#define MSP85x0_GE_MSTATX_CONTROL              0x0828  /* MSTATX Control */
+#define MSP85x0_GE_MSTATX_VARIABLE_SELECT      0x082C  /* MSTATX Variable Select */
+
+/* MIB counter offsets, add to the MSP85x0_GE_MSTATX_STATS_BASE_XXX */
+#define MSP85x0_GE_MSTATX_RXFRAMESOK                   0x0040
+#define MSP85x0_GE_MSTATX_RXOCTETSOK                   0x0050
+#define MSP85x0_GE_MSTATX_RXFRAMES                     0x0060
+#define MSP85x0_GE_MSTATX_RXOCTETS                     0x0070
+#define MSP85x0_GE_MSTATX_RXUNICASTFRAMESOK            0x0080
+#define MSP85x0_GE_MSTATX_RXBROADCASTFRAMESOK          0x0090
+#define MSP85x0_GE_MSTATX_RXMULTICASTFRAMESOK          0x00A0
+#define MSP85x0_GE_MSTATX_RXTAGGEDFRAMESOK             0x00B0
+#define MSP85x0_GE_MSTATX_RXMACPAUSECONTROLFRAMESOK    0x00C0
+#define MSP85x0_GE_MSTATX_RXMACCONTROLFRAMESOK         0x00D0
+#define MSP85x0_GE_MSTATX_RXFCSERROR                   0x00E0
+#define MSP85x0_GE_MSTATX_RXALIGNMENTERROR             0x00F0
+#define MSP85x0_GE_MSTATX_RXSYMBOLERROR                0x0100
+#define MSP85x0_GE_MSTATX_RXLAYER1ERROR                0x0110
+#define MSP85x0_GE_MSTATX_RXINRANGELENGTHERROR         0x0120
+#define MSP85x0_GE_MSTATX_RXLONGLENGTHERROR            0x0130
+#define MSP85x0_GE_MSTATX_RXLONGLENGTHCRCERROR         0x0140
+#define MSP85x0_GE_MSTATX_RXSHORTLENGTHERROR           0x0150
+#define MSP85x0_GE_MSTATX_RXSHORTLLENGTHCRCERROR       0x0160
+#define MSP85x0_GE_MSTATX_RXFRAMES64OCTETS             0x0170
+#define MSP85x0_GE_MSTATX_RXFRAMES65TO127OCTETS        0x0180
+#define MSP85x0_GE_MSTATX_RXFRAMES128TO255OCTETS       0x0190
+#define MSP85x0_GE_MSTATX_RXFRAMES256TO511OCTETS       0x01A0
+#define MSP85x0_GE_MSTATX_RXFRAMES512TO1023OCTETS      0x01B0
+#define MSP85x0_GE_MSTATX_RXFRAMES1024TO1518OCTETS     0x01C0
+#define MSP85x0_GE_MSTATX_RXFRAMES1519TOMAXSIZE        0x01D0
+#define MSP85x0_GE_MSTATX_RXSTATIONADDRESSFILTERED     0x01E0
+#define MSP85x0_GE_MSTATX_RXVARIABLE                   0x01F0
+#define MSP85x0_GE_MSTATX_GENERICADDRESSFILTERED       0x0200
+#define MSP85x0_GE_MSTATX_UNICASTFILTERED              0x0210
+#define MSP85x0_GE_MSTATX_MULTICASTFILTERED            0x0220
+#define MSP85x0_GE_MSTATX_BROADCASTFILTERED            0x0230
+#define MSP85x0_GE_MSTATX_HASHFILTERED                 0x0240
+#define MSP85x0_GE_MSTATX_TXFRAMESOK                   0x0250
+#define MSP85x0_GE_MSTATX_TXOCTETSOK                   0x0260
+#define MSP85x0_GE_MSTATX_TXOCTETS                     0x0270
+#define MSP85x0_GE_MSTATX_TXTAGGEDFRAMESOK             0x0280
+#define MSP85x0_GE_MSTATX_TXMACPAUSECONTROLFRAMESOK    0x0290
+#define MSP85x0_GE_MSTATX_TXFCSERROR                   0x02A0
+#define MSP85x0_GE_MSTATX_TXSHORTLENGTHERROR           0x02B0
+#define MSP85x0_GE_MSTATX_TXLONGLENGTHERROR            0x02C0
+#define MSP85x0_GE_MSTATX_TXSYSTEMERROR                0x02D0
+#define MSP85x0_GE_MSTATX_TXMACERROR                   0x02E0
+#define MSP85x0_GE_MSTATX_TXCARRIERSENSEERROR          0x02F0
+#define MSP85x0_GE_MSTATX_TXSQETESTERROR               0x0300
+#define MSP85x0_GE_MSTATX_TXUNICASTFRAMESOK            0x0310
+#define MSP85x0_GE_MSTATX_TXBROADCASTFRAMESOK          0x0320
+#define MSP85x0_GE_MSTATX_TXMULTICASTFRAMESOK          0x0330
+#define MSP85x0_GE_MSTATX_TXUNICASTFRAMESATTEMPTED     0x0340
+#define MSP85x0_GE_MSTATX_TXBROADCASTFRAMESATTEMPTED   0x0350
+#define MSP85x0_GE_MSTATX_TXMULTICASTFRAMESATTEMPTED   0x0360
+#define MSP85x0_GE_MSTATX_TXFRAMES64OCTETS             0x0370
+#define MSP85x0_GE_MSTATX_TXFRAMES65TO127OCTETS        0x0380
+#define MSP85x0_GE_MSTATX_TXFRAMES128TO255OCTETS       0x0390
+#define MSP85x0_GE_MSTATX_TXFRAMES256TO511OCTETS       0x03A0
+#define MSP85x0_GE_MSTATX_TXFRAMES512TO1023OCTETS      0x03B0
+#define MSP85x0_GE_MSTATX_TXFRAMES1024TO1518OCTETS     0x03C0
+#define MSP85x0_GE_MSTATX_TXFRAMES1519TOMAXSIZE        0x03D0
+#define MSP85x0_GE_MSTATX_TXVARIABLE                   0x03E0
+#define MSP85x0_GE_MSTATX_RXSYSTEMERROR                0x03F0
+#define MSP85x0_GE_MSTATX_SINGLECOLLISION              0x0400
+#define MSP85x0_GE_MSTATX_MULTIPLECOLLISION            0x0410
+#define MSP85x0_GE_MSTATX_DEFERREDXMISSIONS            0x0420
+#define MSP85x0_GE_MSTATX_LATECOLLISIONS               0x0430
+#define MSP85x0_GE_MSTATX_ABORTEDDUETOXSCOLLS          0x0440
+
+
+/* Interrupt specific defines */
+#define MSP85x0_GE_DEVICE_ID         0x0000  /* Device ID */
+#define MSP85x0_GE_RESET             0x0008  /* Reset reg */
+#define MSP85x0_GE_TSB_CTRL_0        0x0010  /* TSB Control reg 0 */
+#define MSP85x0_GE_CPIF2_GU0         0x0014  /* CPIF2 General Use 0 */
+#define MSP85x0_GE_CPIF2_GENERAL_USE3	0x0020
+#define MSP85x0_GE_INTR_GRP0_STATUS  0x0024  /* General Interrupt Group 0 Status */
+#define MSP85x0_GE_INTR_XDMA_CORE_A  0x002C  /* XDMA Channel Interrupt Status, Core A*/
+#define MSP85x0_GE_CPIF2_SET_VECTOR_MSG0	0x0044
+#define MSP85x0_GE_CPIF2_INT_MSG_ADDR0	0x0060
+#define MSP85x0_GE_CPIF2_INT_VECOTR_MODE0	0x0080
+#define MSP85x0_GE_INTR_XDMA_IE      0x0084  /* XDMA Channel Interrupt Enable */
+#define MSP85x0_GE_SDQPF_ECC_INTR    0x280C  /* SDQPF ECC Interrupt Status */
+
+#define MSP85x0_GE_SDQPF_RXFIFO_CTL  0x2828  /* SDQPF RxFifo Control and Interrupt Enb*/
+#define MSP85x0_GE_SDQPF_RXFIFO_INTR 0x282C  /* SDQPF RxFifo Interrupt Status */
+#define MSP85x0_GE_SDQPF_RXFIFO_0    0x2840  /* SDQPF RxFIFO Config */
+#define MSP85x0_GE_SDQPF_RX_THRLD_0  0x2844
+#define MSP85x0_GE_SDQPF_RXFIFO_8    0x28A0  /* SDQPF RxFIFO Config */
+#define MSP85x0_GE_SDQPF_RX_THRLD_8  0x28A4
+
+#define MSP85x0_GE_SDQPF_TXFIFO_CTL  0x2928  /* SDQPF TxFifo Control and Interrupt Enb*/
+#define MSP85x0_GE_SDQPF_TXFIFO_INTR 0x292C  /* SDQPF TxFifo Interrupt Status */
+#define MSP85x0_GE_SDQPF_TXFIFO_0    0x2940  /* SDQPF TxFIFO Enable */
+#define MSP85x0_GE_SDQPF_TX_THRLD_0  0x2944  /* SDQPF TxFIFO Enable */
+#define MSP85x0_GE_SDQPF_TXFIFO_1    0x294C  /* SDQPF TxFIFO Enable */
+#define MSP85x0_GE_SDQPF_TX_THRLD_1  0x2950  /* SDQPF TxFIFO Enable */
+
+#define MSP85x0_GE_XDMA_CONFIG       0x3000  /* XDMA Global Configuration */
+#define MSP85x0_GE_XDMA_INTR_SUMMARY 0x3010  /* XDMA Interrupt Summary */
+#define MSP85x0_GE_XDMA_BUFADDRPRE   0x3018  /* XDMA Buffer Address Prefix */
+#define MSP85x0_GE_XDMA_DESCADDRPRE  0x301C  /* XDMA Descriptor Address Prefix */
+#define MSP85x0_GE_XDMA_PORTWEIGHT   0x302C  /* XDMA Port Weight Configuration */
+
+#define MSP85x0_GE_CPIF2_CPXCISR     0x002C
+#define MSP85x0_GE_CPIF2_CPGIG0SR    0x0024
+#define MSP85x0_GE_INTR_GRP0_STATUS  0x0024	
+
+/* Rx MAC defines */
+#define MSP85x0_GE_RMAC_CONFIG_1               0x1200  /* RMAC Configuration 1 */
+#define MSP85x0_GE_RMAC_CONFIG_2               0x1204  /* RMAC Configuration 2 */
+#define MSP85x0_GE_RMAC_MAX_FRAME_LEN          0x1208  /* RMAC Max Frame Length */
+#define MSP85x0_GE_RMAC_STATION_HI             0x120C  /* Rx Station Address High */
+#define MSP85x0_GE_RMAC_STATION_MID            0x1210  /* Rx Station Address Middle */
+#define MSP85x0_GE_RMAC_STATION_LOW            0x1214  /* Rx Station Address Low */
+#define MSP85x0_GE_RMAC_LINK_CONFIG            0x1218  /* RMAC Link Configuration */
+
+/* Tx MAC defines */
+#define MSP85x0_GE_TMAC_CONFIG_1               0x1240  /* TMAC Configuration 1 */
+#define MSP85x0_GE_TMAC_CONFIG_2               0x1244  /* TMAC Configuration 2 */
+#define MSP85x0_GE_TMAC_IPG                    0x1248  /* TMAC Inter-Packet Gap */
+#define MSP85x0_GE_TMAC_STATION_HI             0x124C  /* Tx Station Address High */
+#define MSP85x0_GE_TMAC_STATION_MID            0x1250  /* Tx Station Address Middle */
+#define MSP85x0_GE_TMAC_STATION_LOW            0x1254  /* Tx Station Address Low */
+#define MSP85x0_GE_TMAC_MAX_FRAME_LEN          0x1258  /* TMAC Max Frame Length */
+#define MSP85x0_GE_TMAC_MIN_FRAME_LEN          0x125C  /* TMAC Min Frame Length */
+#define MSP85x0_GE_TMAC_PAUSE_FRAME_TIME       0x1260  /* TMAC Pause Frame Time */
+#define MSP85x0_GE_TMAC_PAUSE_FRAME_INTERVAL   0x1264  /* TMAC Pause Frame Interval */
+
+#define MSP85x0_GE_L1RPP_CONFIG_STS	     0x128C	
+#define MSP85x0_GE_RTIF_CONFIG		     0x12CC
+
+#define MSP85x0_GE_L1TPP_CONFIG 		     0x1300
+/* GMII register */
+#define MSP85x0_GE_GMII_INTERRUPT_STATUS       0x1348  /* GMII Interrupt Status */
+#define MSP85x0_GE_GMII_CONFIG_GENERAL         0x134C  /* GMII Configuration General */
+#define MSP85x0_GE_GMII_CONFIG_MODE            0x1350  /* GMII Configuration Mode */
+
+/* Tx and Rx XDMA defines */
+
+#define MSP85x0_GE_GXDMA_INT_STS		     0x3008
+#define MSP85x0_GE_GXDMA0_DESC_PREFETCH_CNT    0x305C
+
+#define MSP85x0_GE_INT_COALESCING              0x3030 /* Interrupt Coalescing */
+#define MSP85x0_GE_GDI_PASSPW_CONFIG           0x303C /* Channel 0 XDMA config */
+#define MSP85x0_GE_CHANNEL0_CONFIG             0x3040 /* Channel 0 XDMA config */
+#define MSP85x0_GE_CHANNEL0_TX_DMA_STS	     0x3044 /* Channel 0 Tx DMA Status */	
+#define MSP85x0_GE_CHANNEL0_RX_DMA_STS	     0x3048 /* Channel 0 Rx DMA Status */
+#define MSP85x0_GE_CHANNEL0_INTERRUPT          0x304c /* Channel 0 Interrupt Status */
+#define MSP85x0_GE_GDI_INTERRUPT_ENABLE        0x3050 /* IE for the GDI Errors */
+#define MSP85x0_GE_CHANNEL0_PACKET             0x3060 /* Channel 0 Packet count */
+#define MSP85x0_GE_CHANNEL0_BYTE               0x3064 /* Channel 0 Byte count */
+#define MSP85x0_GE_CHANNEL0_TX_DESC            0x3054 /* Channel 0 Tx first desc */
+#define MSP85x0_GE_CHANNEL0_RX_DESC            0x3058 /* Channel 0 Rx first desc */
+#define MSP85x0_GE_CHANNEL0_RX_DESC_PKT_DRP_THR	0x3074
+
+#define MSP85x0_GE_TRTG2_INTERRUPT_IND	     0x100C
+#define MSP85x0_GE_TRTG_PRIORITY_CHKSUM	     0x1038
+#define MSP85x0_GE_TRTG_BYTE_OFFSET_0	     0x103C
+#define MSP85x0_GE_TRTG_BYTE_OFFSET_1	     0x1040
+
+/* AFX (Address Filter Exact) register offsets for Slice 0 */
+#define MSP85x0_GE_AFX_EXACT_MATCH_LOW         0x1100  /* AFX Exact Match Address Low*/
+#define MSP85x0_GE_AFX_EXACT_MATCH_MID         0x1104  /* AFX Exact Match Address Mid*/
+#define MSP85x0_GE_AFX_EXACT_MATCH_HIGH        0x1108  /* AFX Exact Match Address Hi */
+#define MSP85x0_GE_AFX_EXACT_MATCH_VID         0x110C  /* AFX Exact Match VID */
+
+#define MSP85x0_GE_AFX_MULTICAST_HASH_LOW      0x1118  /* AFX Multicast HASH Low */
+#define MSP85x0_GE_AFX_MULTICAST_HASH_MIDLOW   0x111c  /* AFX Multicast HASH MidLow */
+#define MSP85x0_GE_AFX_MULTICAST_HASH_MIDHI    0x1120  /* AFX Multicast HASH MidHi*/
+#define MSP85x0_GE_AFX_MULTICAST_HASH_HI       0x1124  /* AFX Multicast HASH Hi */
+#define MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_0     0x1158  /* AFX Address Filter Ctrl 0 */
+#define MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_1     0x115C  /* AFX Address Filter Ctrl 1 */
+#define MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_2     0x1160  /* AFX Address Filter Ctrl 2 */
+#define MSP85x0_GE_AFX_ADDRS_FILTER_CTRL_3     0x1164  /* AFX Address Filter Ctrl 2 */
+/* Traffic Groomer block */
+#define        MSP85x0_GE_TRTG_CONFIG	     0x1000  /* TRTG Config */
+
+
+#define XDMA_TMAC_RESET  0x80000000
+#define XDMA_TMAC_ENABLE (~(0xC0000000))
+
+#define XDMA_RMAC_RESET  0x00100000
+#define XDMA_RMAC_ENABLE (~(0x00180000))
+#endif 				/* _MSP85x0_GE_H_ */
+
diff -Naur a/drivers/net/titan_mdio.c b/drivers/net/titan_mdio.c
--- a/drivers/net/titan_mdio.c	2005-07-11 11:28:10.000000000 -0700
+++ b/drivers/net/titan_mdio.c	2006-06-22 11:48:21.000000000 -0700
@@ -41,6 +41,17 @@
 /*
  * Titan MDIO and SCMB registers
  */
+#ifdef CONFIG_PMC_SEQUOIA
+
+#define TITAN_GE_SCMB_CONTROL                0x0400  /* SCMB Control */
+#define TITAN_GE_SCMB_CLKA                   0x0404  /* SCMB Clock A */
+#define TITAN_GE_MDIO_COMMAND                0x0410  /* MDIO Command */
+#define TITAN_GE_MDIO_DEVICE_PORT_ADDRESS    0x0414  /* MDIO Device and Port addrs */
+#define TITAN_GE_MDIO_DATA                   0x0418  /* MDIO Data */
+#define TITAN_GE_MDIO_INTERRUPTS             0x041C  /* MDIO Interrupts */
+
+#else // CONFIG_PMC_SEQUOIA
+
 #define TITAN_GE_SCMB_CONTROL                0x01c0  /* SCMB Control */
 #define TITAN_GE_SCMB_CLKA	             0x01c4  /* SCMB Clock A */
 #define TITAN_GE_MDIO_COMMAND                0x01d0  /* MDIO Command */
@@ -48,6 +59,8 @@
 #define TITAN_GE_MDIO_DATA                   0x01d8  /* MDIO Data */
 #define TITAN_GE_MDIO_INTERRUPTS             0x01dC  /* MDIO Interrupts */
 
+#endif //CONFIG_PMC_SEQUOIA
+
 /*
  * Function to poll the MDIO
  */
@@ -132,6 +145,10 @@
 	volatile unsigned long	val;
 	int retries = 0;
 
+#ifdef CONFIG_PMC_SEQUOIA
+        dev_addr++;
+#endif
+
 	/* Setup the PHY device */
 
 again:
@@ -181,6 +198,10 @@
 {
 	volatile unsigned long	val;
 
+#ifdef CONFIG_PMC_SEQUOIA
+        dev_addr++;
+#endif
+
 	if (titan_ge_mdio_poll() != TITAN_GE_MDIO_GOOD)
 		return TITAN_GE_MDIO_ERROR;
 
diff -Naur a/drivers/net/titan_mdio.h b/drivers/net/titan_mdio.h
--- a/drivers/net/titan_mdio.h	2005-07-11 11:28:10.000000000 -0700
+++ b/drivers/net/titan_mdio.h	2006-06-22 11:48:21.000000000 -0700
@@ -7,8 +7,13 @@
 #include <linux/netdevice.h>
 #include <linux/workqueue.h>
 #include <linux/delay.h>
+#ifdef CONFIG_PMC_YOSEMITE
 #include "titan_ge.h"
+#else
+#include "msp85x0_ge.h"
+#endif
 
+extern unsigned long titan_ge_base;
 
 #define	TITAN_GE_MDIO_ERROR	(-9000)
 #define	TITAN_GE_MDIO_GOOD	0

