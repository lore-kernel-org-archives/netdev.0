From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: MV643xx Ethernet 2.6 driver update
Date: Mon, 17 Jan 2005 11:40:19 -0700
Message-ID: <20050117184019.GA24655@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

While porting the mv643xx ethernet driver to 2.6 and for use on PPC, I
modified it to use the device driver model, fixed the hardware checksum
support, and did some miscellaneous bug fixes and cleanups.

The following changes are included:
	
 A. Remove redundant or unneeded code.
 B. Replace fixed count spins with udelay/msleep waits on hardware status bits
 C. Fix code to enable hardware checksum generation for TX packets
 D. Convert from pci_map_* to dma_map_* interface
 E. Add device driver model support.
 F. Add support for several configurable parameters via platform_device
 G. Make use of MV64340_RX_QUEUE_FILL_ON_TASK macro consistent.
 H. Simplify mv64340_eth_set_rx_mode()
 I. Clean up receive buffer sizing
 J. Call netif_carrier_off/netif_carrier_on on a link down/up condition
 K. Add support for PHYs/boards that don't support autonegotiation.

Change E is the only one that modifies the driver interface.

Change G was sent to me by Steven J Hill <sjhill1@rockwellcollins.com>.
Change K was sent to me by Brian Waite <brian@waitefamily.us>.

The first 6 changes were submitted to LKLM on Dec. 13 2004.  Comments
were received only from Christoph Hellwig <hch@infradead.org> and have
been addressed.  Changes G-K have been added since then.

I have some additional (mostly cosmetic, but still significant) cleanups,
but I'd like to get these in the queue first.

Thanks,
Dale Farnsworth

Please do a

	bk pull bk://dfarnsworth.bkbits.net/netdev-2.6-mv643xx-enet

This will update the following files:

 drivers/net/mv643xx_eth.c | 1146 ++++++++++++++++++++++++----------------------
 drivers/net/mv643xx_eth.h |  235 ---------
 include/linux/mv643xx.h   |  206 ++++++++
 3 files changed, 833 insertions(+), 754 deletions(-)

through these ChangeSets:

<dale@farnsworth.org> (05/01/14 1.2329.1.11)
   Add support for PHYs/boards that don't support autonegotiation.
   
   Signed-off-by: Brian Waite <brian@waitefamily.us>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.10)
   With this patch, the driver now calls netif_carrier_off/netif_carrier_on
   on a link down/up condition.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.9)
   This patch cleans up the handling of receive buffer sizing.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.8)
   This patch simplifies the mv64340_eth_set_rx_mode function without
   changing its behavior.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.7)
   This patch makes the use of the MV64340_RX_QUEUE_FILL_ON_TASK config macro
   more consistent, though the macro remains undefined, since the feature still
   does not work properly.
           
   Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.6)
   This patch adds support for passing additional parameters via the
   platform_device interface.  These additional parameters are:
           size of RX and TX descriptor rings
           port_config value 
           port_config_extend value
           port_sdma_config value
           port_serial_control value
           PHY address                                                                                                                                             Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.5)
   This patch adds device driver model support to the mv643xx_eth driver.
   
   This is a change to the driver's programming interface.  Platform
   code must now pass in the address of the MV643xx ethernet registers
   and IRQ.  If firmware doesn't set the MAC address, platform code
   must also pass in the MAC address.
   
   Also, note that local MV_READ/MV_WRITE macros are used rather than              using global macros.  Keeping the macro names minimizes the patch size.         The names will be changed to mv_read/mv_write in a later cosmetic               cleanup patch.                                                                                                                                                  Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.4)
   This patch replaces the use of the pci_map_* functions with the
   corresponding dma_map_* functions.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.3)
   This patch fixes the code that enables hardware checksum generation.
   The previous code has so many problems that it appears to never have 
   worked 2.6.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.2)
   This patch removes spin delays (count to 1000000, ugh) and instead waits
   with udelay or msleep for hardware flags to change.
   
   It also adds a spinlock to protect access to the MV64340_ETH_SMI_REG,
   which is shared across ports.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.2329.1.1)
   This patch removes code that is redundant or useless.
   The biggest area is in pre-initializing the RX and TX descriptor
   rings, which only obfuscates the driver since the ring data is
   overwritten without being used.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>


Cumulative patch resulting from the changesets above:

diff -Nru a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c	2005-01-17 11:22:12 -07:00
+++ b/drivers/net/mv643xx_eth.c	2005-01-17 11:22:12 -07:00
@@ -10,6 +10,12 @@
  *
  * Copyright (C) 2003 Ralf Baechle <ralf@linux-mips.org>
  *
+ * Copyright (C) 2004-2005 MontaVista Software, Inc.
+ *                    Dale Farnsworth <dale@farnsworth.org>
+ *
+ * Copyright (C) 2004 Steven J. Hill <sjhill1@rockwellcollins.com>
+ *                                   <sjhill@realitydiluted.com>
+ *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
  * as published by the Free Software Foundation; either version 2
@@ -24,58 +30,49 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
-#include <linux/config.h>
-#include <linux/version.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/config.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/fcntl.h>
-#include <linux/ioport.h>
-#include <linux/interrupt.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/ip.h>
 #include <linux/init.h>
-#include <linux/in.h>
-#include <linux/pci.h>
-#include <linux/workqueue.h>
-#include <asm/smp.h>
-#include <linux/skbuff.h>
+#include <linux/dma-mapping.h>
 #include <linux/tcp.h>
-#include <linux/netdevice.h>
+#include <linux/udp.h>
 #include <linux/etherdevice.h>
-#include <net/ip.h>
 
 #include <linux/bitops.h>
+#include <linux/delay.h>
 #include <asm/io.h>
 #include <asm/types.h>
 #include <asm/pgtable.h>
 #include <asm/system.h>
+#include <asm/delay.h>
 #include "mv643xx_eth.h"
 
 /*
  * The first part is the high level driver of the gigE ethernet ports. 
  */
 
-/* Definition for configuring driver */
-#undef MV64340_RX_QUEUE_FILL_ON_TASK
-
 /* Constants */
 #define EXTRA_BYTES 32
 #define WRAP       ETH_HLEN + 2 + 4 + 16
 #define BUFFER_MTU dev->mtu + WRAP
 #define INT_CAUSE_UNMASK_ALL		0x0007ffff
 #define INT_CAUSE_UNMASK_ALL_EXT	0x0011ffff
-#ifdef MV64340_RX_FILL_ON_TASK
+#ifdef MV64340_RX_QUEUE_FILL_ON_TASK
 #define INT_CAUSE_MASK_ALL		0x00000000
 #define INT_CAUSE_CHECK_BITS		INT_CAUSE_UNMASK_ALL
 #define INT_CAUSE_CHECK_BITS_EXT	INT_CAUSE_UNMASK_ALL_EXT
 #endif
+#ifdef MV64340_CHECKSUM_OFFLOAD_TX
+#define MAX_DESCS_PER_SKB	(MAX_SKB_FRAGS + 1)
+#else
+#define MAX_DESCS_PER_SKB	1
+#endif
+
+#define PHY_WAIT_ITERATIONS	1000	/* 1000 iterations * 10uS = 10mS max */
+#define PHY_WAIT_MICRO_SECONDS	10
 
 /* Static function declarations */
+static int eth_port_link_is_up(unsigned int eth_port_num);
+static void eth_port_uc_addr_get(struct net_device *dev,
+		                                 unsigned char *MacAddr);
 static int mv64340_eth_real_open(struct net_device *);
 static int mv64340_eth_real_stop(struct net_device *);
 static int mv64340_eth_change_mtu(struct net_device *, int);
@@ -84,9 +81,21 @@
 #ifdef MV64340_NAPI
 static int mv64340_poll(struct net_device *dev, int *budget);
 #endif
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
+
+static void __iomem *mv64x60_eth_shared_base;
+
+/* used to protect MV64340_ETH_SMI_REG, which is shared across ports */
+static spinlock_t mv64340_eth_phy_lock = SPIN_LOCK_UNLOCKED;
 
-unsigned char prom_mac_addr_base[6];
-unsigned long mv64340_sram_base;
+#undef MV_READ
+#define MV_READ(offset)	\
+	readl(mv64x60_eth_shared_base - MV64340_ETH_SHARED_REGS + offset)
+
+#undef MV_WRITE
+#define MV_WRITE(offset, data)	\
+	writel((u32)data,	\
+		mv64x60_eth_shared_base - MV64340_ETH_SHARED_REGS + offset)
 
 /*
  * Changes MTU (maximum transfer unit) of the gigabit ethenret port
@@ -148,24 +157,15 @@
 		panic("%s: Error in test_set_bit / clear_bit", dev->name);
 
 	while (mp->rx_ring_skbs < (mp->rx_ring_size - 5)) {
-		/* The +8 for buffer allignment and another 32 byte extra */
-
-		skb = dev_alloc_skb(BUFFER_MTU + 8 + EXTRA_BYTES);
+		/* Ensure skb->len is a multiple of 8 */
+		skb = dev_alloc_skb((BUFFER_MTU + EXTRA_BYTES + 7) & ~0x7);
 		if (!skb)
-			/* Better luck next time */
 			break;
 		mp->rx_ring_skbs++;
 		pkt_info.cmd_sts = ETH_RX_ENABLE_INTERRUPT;
-		pkt_info.byte_cnt = dev->mtu + ETH_HLEN + 4 + 2 + EXTRA_BYTES;
-		/* Allign buffer to 8 bytes */
-		if (pkt_info.byte_cnt & ~0x7) {
-			pkt_info.byte_cnt &= ~0x7;
-			pkt_info.byte_cnt += 8;
-		}
+		pkt_info.byte_cnt = skb->len;
 		pkt_info.buf_ptr =
-		    pci_map_single(0, skb->data,
-				   dev->mtu + ETH_HLEN + 4 + 2 + EXTRA_BYTES,
-				   PCI_DMA_FROMDEVICE);
+		    dma_map_single(NULL, skb->data, skb->len, DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
 		if (eth_rx_return_buff(mp, &pkt_info) != ETH_OK) {
 			printk(KERN_ERR
@@ -186,7 +186,7 @@
 		add_timer(&mp->timeout);
 		mp->rx_timer_flag = 1;
 	}
-#if MV64340_RX_QUEUE_FILL_ON_TASK
+#ifdef MV64340_RX_QUEUE_FILL_ON_TASK
 	else {
 		/* Return interrupts */
 		MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(mp->port_num),
@@ -244,18 +244,14 @@
 static void mv64340_eth_set_rx_mode(struct net_device *dev)
 {
 	struct mv64340_private *mp = netdev_priv(dev);
+	u32 config_reg;
 
-	if (dev->flags & IFF_PROMISC) {
-		ethernet_set_config_reg
-		    (mp->port_num,
-		     ethernet_get_config_reg(mp->port_num) |
-		     ETH_UNICAST_PROMISCUOUS_MODE);
-	} else {
-		ethernet_set_config_reg
-		    (mp->port_num,
-		     ethernet_get_config_reg(mp->port_num) &
-		     ~(unsigned int) ETH_UNICAST_PROMISCUOUS_MODE);
-	}
+	config_reg = ethernet_get_config_reg(mp->port_num);
+	if (dev->flags & IFF_PROMISC)
+		config_reg |= (u32)MV64340_ETH_UNICAST_PROMISCUOUS_MODE;
+	else
+		config_reg &= ~(u32)MV64340_ETH_UNICAST_PROMISCUOUS_MODE;
+	ethernet_set_config_reg(mp->port_num, config_reg);
 }
 
 
@@ -348,26 +344,27 @@
 		 * last skb releases the whole chain.
 		 */
 		if (pkt_info.return_info) {
-			dev_kfree_skb_irq((struct sk_buff *)
-					  pkt_info.return_info);
-			released = 0;
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
-				pci_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, PCI_DMA_TODEVICE);
-
-			if (mp->tx_ring_skbs != 1)
-				mp->tx_ring_skbs--;
-		} else 
-			pci_unmap_page(NULL, pkt_info.buf_ptr,
-					pkt_info.byte_cnt, PCI_DMA_TODEVICE);
+				dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
+			else
+				dma_unmap_single(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 
-		/* 
-		 * Decrement the number of outstanding skbs counter on
-		 * the TX queue.
-		 */
-		if (mp->tx_ring_skbs == 0)
-			panic("ERROR - TX outstanding SKBs counter is corrupted");
+			dev_kfree_skb_irq(pkt_info.return_info);
+			released = 0;
 
+			/* 
+			 * Decrement the number of outstanding skbs counter on
+			 * the TX queue.
+			 */
+			if (mp->tx_ring_skbs == 0)
+				panic("ERROR - TX outstanding SKBs"
+						" counter is corrupted");
+			mp->tx_ring_skbs--;
+		} else 
+			dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	spin_unlock(&mp->lock);
@@ -387,10 +384,9 @@
  * Output : number of served packets
  */
 #ifdef MV64340_NAPI
-static int mv64340_eth_receive_queue(struct net_device *dev, unsigned int max,
-								int budget)
+static int mv64340_eth_receive_queue(struct net_device *dev, int budget)
 #else
-static int mv64340_eth_receive_queue(struct net_device *dev, unsigned int max)
+static int mv64340_eth_receive_queue(struct net_device *dev)
 #endif
 {
 	struct mv64340_private *mp = netdev_priv(dev);
@@ -402,7 +398,7 @@
 #ifdef MV64340_NAPI
 	while (eth_port_receive(mp, &pkt_info) == ETH_OK && budget > 0) {
 #else
-	while ((--max) && eth_port_receive(mp, &pkt_info) == ETH_OK) {
+	while (eth_port_receive(mp, &pkt_info) == ETH_OK) {
 #endif
 		mp->rx_ring_skbs--;
 		received_packets++;
@@ -412,7 +408,7 @@
 		/* Update statistics. Note byte count includes 4 byte CRC count */
 		stats->rx_packets++;
 		stats->rx_bytes += pkt_info.byte_cnt;
-		skb = (struct sk_buff *) pkt_info.return_info;
+		skb = pkt_info.return_info;
 		/*
 		 * In case received a packet without first / last bits on OR
 		 * the error summary bit is on, the packets needs to be dropeed.
@@ -505,7 +501,7 @@
 		/* UDP change : We may need this */
 		if ((eth_int_cause_ext & 0x0000ffff) &&
 		    (mv64340_eth_free_tx_queue(dev, eth_int_cause_ext) == 0) &&
-		    (MV64340_TX_QUEUE_SIZE > mp->tx_ring_skbs + 1))
+		    (mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB))
                                          netif_wake_queue(dev);
 #ifdef MV64340_NAPI
 	} else {
@@ -525,7 +521,7 @@
 		 * in an interrupts enabled context that refills the RX ring
 		 * with skb's.
 		 */
-#if MV64340_RX_QUEUE_FILL_ON_TASK
+#ifdef MV64340_RX_QUEUE_FILL_ON_TASK
 		/* Unmask all interrupts on ethernet port */
 		MV_WRITE(MV64340_ETH_INTERRUPT_MASK_REG(port_num),
 		         INT_CAUSE_MASK_ALL);
@@ -538,25 +534,14 @@
 	}
 	/* PHY status changed */
 	if (eth_int_cause_ext & (BIT16 | BIT20)) {
-		unsigned int phy_reg_data;
-
-		/* Check Link status on ethernet port */
-		eth_port_read_smi_reg(port_num, 1, &phy_reg_data);
-		if (!(phy_reg_data & 0x20)) {
-			netif_stop_queue(dev);
-		} else {
+		if (eth_port_link_is_up(port_num)) {
+			netif_carrier_on(dev);
 			netif_wake_queue(dev);
-
-			/*
-			 * Start all TX queues on ethernet port. This is good in
-			 * case of previous packets where not transmitted, due
-			 * to link down and this command re-enables all TX
-			 * queues.
-			 * Note that it is possible to get a TX resource error
-			 * interrupt after issuing this, since not all TX queues
-			 * are enabled, or has anything to send.
-			 */
+			/* Start TX queue */
 			MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
+		} else {
+			netif_carrier_off(dev);
+			netif_stop_queue(dev);
 		}
 	}
 
@@ -661,7 +646,7 @@
 {
 	struct mv64340_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
-	int err = err;
+	int err;
 
 	spin_lock_irq(&mp->lock);
 
@@ -708,56 +693,25 @@
  *
  * INPUT:
  *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *      int 			rx_desc_num       Number of Rx descriptors
- *      int 			rx_buff_size      Size of Rx buffer
- *      unsigned int    rx_desc_base_addr  Rx descriptors memory area base addr.
- *      unsigned int    rx_buff_base_addr  Rx buffer memory area base addr.
  *
  * OUTPUT:
  *      The routine updates the Ethernet port control struct with information 
  *      regarding the Rx descriptors and buffers.
  *
  * RETURN:
- *      false if the given descriptors memory area is not aligned according to
- *      Ethernet SDMA specifications.
- *      true otherwise.
+ *      None.
  */
-static int ether_init_rx_desc_ring(struct mv64340_private * mp,
-	unsigned long rx_buff_base_addr)
+static void ether_init_rx_desc_ring(struct mv64340_private * mp)
 {
-	unsigned long buffer_addr = rx_buff_base_addr;
 	volatile struct eth_rx_desc *p_rx_desc;
 	int rx_desc_num = mp->rx_ring_size;
-	unsigned long rx_desc_base_addr = (unsigned long) mp->p_rx_desc_area;
-	int rx_buff_size = 1536;	/* Dummy, will be replaced later */
 	int i;
 
-	p_rx_desc = (struct eth_rx_desc *) rx_desc_base_addr;
-
-	/* Rx desc Must be 4LW aligned (i.e. Descriptor_Address[3:0]=0000). */
-	if (rx_buff_base_addr & 0xf)
-		return 0;
-
-	/* Rx buffers are limited to 64K bytes and Minimum size is 8 bytes  */
-	if ((rx_buff_size < 8) || (rx_buff_size > RX_BUFFER_MAX_SIZE))
-		return 0;
-
-	/* Rx buffers must be 64-bit aligned.       */
-	if ((rx_buff_base_addr + rx_buff_size) & 0x7)
-		return 0;
-
-	/* initialize the Rx descriptors ring */
+	/* initialize the next_desc_ptr links in the Rx descriptors ring */
+	p_rx_desc = (struct eth_rx_desc *) mp->p_rx_desc_area;
 	for (i = 0; i < rx_desc_num; i++) {
-		p_rx_desc[i].buf_size = rx_buff_size;
-		p_rx_desc[i].byte_cnt = 0x0000;
-		p_rx_desc[i].cmd_sts =
-			ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
 		p_rx_desc[i].next_desc_ptr = mp->rx_desc_dma +
 			((i + 1) % rx_desc_num) * sizeof(struct eth_rx_desc);
-		p_rx_desc[i].buf_ptr = buffer_addr;
-
-		mp->rx_skb[i] = NULL;
-		buffer_addr += rx_buff_size;
 	}
 
 	/* Save Rx desc pointer to driver struct. */
@@ -766,9 +720,8 @@
 
 	mp->rx_desc_area_size = rx_desc_num * sizeof(struct eth_rx_desc);
 
+	/* Add the queue to the list of RX queues of this port */
 	mp->port_rx_queue_command |= 1;
-
-	return 1;
 }
 
 /*
@@ -785,57 +738,37 @@
  *
  * INPUT:
  *	struct mv64340_private   *mp   Ethernet Port Control srtuct. 
- *      int 		tx_desc_num        Number of Tx descriptors
- *      int 		tx_buff_size	   Size of Tx buffer
- *      unsigned int    tx_desc_base_addr  Tx descriptors memory area base addr.
  *
  * OUTPUT:
  *      The routine updates the Ethernet port control struct with information 
  *      regarding the Tx descriptors and buffers.
  *
  * RETURN:
- *      false if the given descriptors memory area is not aligned according to
- *      Ethernet SDMA specifications.
- *      true otherwise.
+ *      None.
  */
-static int ether_init_tx_desc_ring(struct mv64340_private *mp)
+static void ether_init_tx_desc_ring(struct mv64340_private *mp)
 {
-	unsigned long tx_desc_base_addr = (unsigned long) mp->p_tx_desc_area;
 	int tx_desc_num = mp->tx_ring_size;
 	struct eth_tx_desc *p_tx_desc;
 	int i;
 
-	/* Tx desc Must be 4LW aligned (i.e. Descriptor_Address[3:0]=0000). */
-	if (tx_desc_base_addr & 0xf)
-		return 0;
-
-	/* save the first desc pointer to link with the last descriptor */
-	p_tx_desc = (struct eth_tx_desc *) tx_desc_base_addr;
-
-	/* Initialize the Tx descriptors ring */
+	/* Initialize the next_desc_ptr links in the Tx descriptors ring */
+	p_tx_desc = (struct eth_tx_desc *) mp->p_tx_desc_area;
 	for (i = 0; i < tx_desc_num; i++) {
-		p_tx_desc[i].byte_cnt	= 0x0000;
-		p_tx_desc[i].l4i_chk	= 0x0000;
-		p_tx_desc[i].cmd_sts	= 0x00000000;
 		p_tx_desc[i].next_desc_ptr = mp->tx_desc_dma +
 			((i + 1) % tx_desc_num) * sizeof(struct eth_tx_desc);
-		p_tx_desc[i].buf_ptr	= 0x00000000;
-		mp->tx_skb[i]		= NULL;
 	}
 
-	/* Set Tx desc pointer in driver struct. */
 	mp->tx_curr_desc_q = 0;
 	mp->tx_used_desc_q = 0;
 #ifdef MV64340_CHECKSUM_OFFLOAD_TX
         mp->tx_first_desc_q = 0;
 #endif
-	/* Init Tx ring base and size parameters */
+
 	mp->tx_desc_area_size	= tx_desc_num * sizeof(struct eth_tx_desc);
 
 	/* Add the queue to the list of Tx queues of this port */
 	mp->port_tx_queue_command |= 1;
-
-	return 1;
 }
 
 /* Helper function for mv64340_eth_open */
@@ -843,8 +776,9 @@
 {
 	struct mv64340_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
-	u32 phy_reg_data;
 	unsigned int size;
+	int i;
+	u32 port_serial_control_reg;
 
 	/* Stop RX Queues */
 	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
@@ -876,49 +810,74 @@
 	mp->rx_task_busy = 0;
 	mp->rx_timer_flag = 0;
 
+	/* Allocate RX and TX skb rings */
+	mp->rx_skb = kmalloc(sizeof(*mp->rx_skb)*mp->rx_ring_size, GFP_KERNEL);
+	if (!mp->rx_skb) {
+		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
+		return -ENOMEM;
+	}
+	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb)*mp->tx_ring_size, GFP_KERNEL);
+	if (!mp->tx_skb) {
+		printk(KERN_ERR "%s: Cannot allocate Tx skb ring\n", dev->name);
+		kfree(mp->rx_skb);
+		return -ENOMEM;
+	}
+
 	/* Allocate TX ring */
 	mp->tx_ring_skbs = 0;
-	mp->tx_ring_size = MV64340_TX_QUEUE_SIZE;
 	size = mp->tx_ring_size * sizeof(struct eth_tx_desc);
 	mp->tx_desc_area_size = size;
 
-	/* Assumes allocated ring is 16 bytes alligned */
-	mp->p_tx_desc_area = pci_alloc_consistent(NULL, size, &mp->tx_desc_dma);
+	if (mp->tx_sram_size) {
+		mp->p_tx_desc_area = ioremap(mp->tx_sram_addr,
+							mp->tx_sram_size);
+		mp->tx_desc_dma = mp->tx_sram_addr;
+	} else
+		mp->p_tx_desc_area = dma_alloc_coherent(NULL, size,
+						&mp->tx_desc_dma, GFP_KERNEL);
+
 	if (!mp->p_tx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Tx Ring (size %d bytes)\n",
 		       dev->name, size);
+		kfree(mp->rx_skb);
+		kfree(mp->tx_skb);
 		return -ENOMEM;
 	}
+	BUG_ON((u32)mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
 	memset((void *) mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
 
-	/* Dummy will be replaced upon real tx */
 	ether_init_tx_desc_ring(mp);
 
 	/* Allocate RX ring */
-	/* Meantime RX Ring are fixed - but must be configurable by user */
-	mp->rx_ring_size = MV64340_RX_QUEUE_SIZE;
 	mp->rx_ring_skbs = 0;
 	size = mp->rx_ring_size * sizeof(struct eth_rx_desc);
 	mp->rx_desc_area_size = size;
 
-	/* Assumes allocated ring is 16 bytes aligned */
-
-	mp->p_rx_desc_area = pci_alloc_consistent(NULL, size, &mp->rx_desc_dma);
+	if (mp->rx_sram_size) {
+		mp->p_rx_desc_area = ioremap(mp->rx_sram_addr,
+							mp->rx_sram_size);
+		mp->rx_desc_dma = mp->rx_sram_addr;
+	} else
+		mp->p_rx_desc_area = dma_alloc_coherent(NULL, size,
+						&mp->rx_desc_dma, GFP_KERNEL);
 
 	if (!mp->p_rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
 		       dev->name, size);
 		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
 		       dev->name);
-		pci_free_consistent(0, mp->tx_desc_area_size,
-				    (void *) mp->p_tx_desc_area,
-				    mp->tx_desc_dma);
+		if (mp->rx_sram_size)
+			iounmap(mp->p_rx_desc_area);
+		else
+			dma_free_coherent(NULL, mp->tx_desc_area_size,
+				    mp->p_tx_desc_area, mp->tx_desc_dma);
+		kfree(mp->rx_skb);
+		kfree(mp->tx_skb);
 		return -ENOMEM;
 	}
-	memset(mp->p_rx_desc_area, 0, size);
+	memset((void *)mp->p_rx_desc_area, 0, size);
 
-	if (!(ether_init_rx_desc_ring(mp, 0)))
-		panic("%s: Error initializing RX Ring", dev->name);
+	ether_init_rx_desc_ring(mp);
 
 	mv64340_eth_rx_task(dev);	/* Fill RX ring with skb's */
 
@@ -934,18 +893,18 @@
 	mp->tx_int_coal =
 		eth_port_set_tx_coal (port_num, 133000000, MV64340_TX_COAL);  
 
-	/* Increase the Rx side buffer size */
+	/* Increase the Rx side buffer size if supporting GigE */
+	port_serial_control_reg =
+			MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	if (port_serial_control_reg & MV64340_ETH_SET_GMII_SPEED_TO_1000)
+		MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+			(port_serial_control_reg & 0xfff1ffff) | (0x5 << 17));
+
+	/* wait up to 1 second for link to come up */
+	for (i = 0; i < 10 && !eth_port_link_is_up(port_num); i++)
+		msleep(100);				/* sleep 1/10 second */
 
-	MV_WRITE (MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num), (0x5 << 17) |
-			(MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num))
-					& 0xfff1ffff));
-
-	/* Check Link status on phy */
-	eth_port_read_smi_reg(port_num, 1, &phy_reg_data);
-	if (!(phy_reg_data & 0x20))
-		netif_stop_queue(dev);
-	else
-		netif_start_queue(dev);
+	netif_start_queue(dev);
 
 	return 0;
 }
@@ -960,22 +919,25 @@
 	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
 		 0x0000ff00);
 
-	/* Free TX rings */
+
 	/* Free outstanding skb's on TX rings */
-	for (curr = 0;
-	     (mp->tx_ring_skbs) && (curr < MV64340_TX_QUEUE_SIZE);
-	     curr++) {
+	for (curr = 0; mp->tx_ring_skbs && curr < mp->tx_ring_size; curr++) {
 		if (mp->tx_skb[curr]) {
 			dev_kfree_skb(mp->tx_skb[curr]);
 			mp->tx_ring_skbs--;
 		}
 	}
-	if (mp->tx_ring_skbs != 0)
+	if (mp->tx_ring_skbs)
 		printk("%s: Error on Tx descriptor free - could not free %d"
 		     " descriptors\n", dev->name,
 		     mp->tx_ring_skbs);
-	pci_free_consistent(0, mp->tx_desc_area_size,
-			    (void *) mp->p_tx_desc_area, mp->tx_desc_dma);
+
+	/* Free TX ring */
+	if (mp->tx_sram_size)
+		iounmap(mp->p_tx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->tx_desc_area_size,
+			    mp->p_tx_desc_area, mp->tx_desc_dma);
 }
 
 static void mv64340_eth_free_rx_rings(struct net_device *dev)
@@ -988,25 +950,25 @@
 	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
 		 0x0000ff00);
 
-	/* Free RX rings */
 	/* Free preallocated skb's on RX rings */
-	for (curr = 0;
-		mp->rx_ring_skbs && (curr < MV64340_RX_QUEUE_SIZE);
-		curr++) {
+	for (curr = 0; mp->rx_ring_skbs && curr < mp->rx_ring_size; curr++) {
 		if (mp->rx_skb[curr]) {
 			dev_kfree_skb(mp->rx_skb[curr]);
 			mp->rx_ring_skbs--;
 		}
 	}
 
-	if (mp->rx_ring_skbs != 0)
+	if (mp->rx_ring_skbs)
 		printk(KERN_ERR
 		       "%s: Error in freeing Rx Ring. %d skb's still"
 		       " stuck in RX Ring - ignoring them\n", dev->name,
 		       mp->rx_ring_skbs);
-	pci_free_consistent(0, mp->rx_desc_area_size,
-			    (void *) mp->p_rx_desc_area,
-			    mp->rx_desc_dma);
+	/* Free RX ring */
+	if (mp->rx_sram_size)
+		iounmap(mp->p_rx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->rx_desc_area_size,
+			    mp->p_rx_desc_area, mp->rx_desc_dma);
 }
 
 /*
@@ -1068,23 +1030,25 @@
 
 	while (eth_tx_return_desc(mp, &pkt_info) == ETH_OK) {
 		if (pkt_info.return_info) {
-			dev_kfree_skb_irq((struct sk_buff *)
-                                                  pkt_info.return_info);
 			if (skb_shinfo(pkt_info.return_info)->nr_frags) 
-                                 pci_unmap_page(NULL, pkt_info.buf_ptr,
-                                             pkt_info.byte_cnt,
-                                             PCI_DMA_TODEVICE);
+				dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
+			else
+				dma_unmap_single(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 
-                         if (mp->tx_ring_skbs != 1)
-                                  mp->tx_ring_skbs--;
+			dev_kfree_skb_irq(pkt_info.return_info);
+
+			if (mp->tx_ring_skbs)
+				mp->tx_ring_skbs--;
                 } else 
-                       pci_unmap_page(NULL, pkt_info.buf_ptr, pkt_info.byte_cnt,
-                                      PCI_DMA_TODEVICE);
+			dma_unmap_page(NULL, pkt_info.buf_ptr,
+					pkt_info.byte_cnt, DMA_TO_DEVICE);
 	}
 
 	if (netif_queue_stopped(dev) &&
-            MV64340_TX_QUEUE_SIZE > mp->tx_ring_skbs + 1)
-                       netif_wake_queue(dev);
+			mp->tx_ring_size > mp->tx_ring_skbs + MAX_DESCS_PER_SKB)
+		netif_wake_queue(dev);
 }
 
 /*
@@ -1112,7 +1076,7 @@
 		orig_budget = *budget;
 		if (orig_budget > dev->quota)
 			orig_budget = dev->quota;
-		work_done = mv64340_eth_receive_queue(dev, 0, orig_budget);
+		work_done = mv64340_eth_receive_queue(dev, orig_budget);
 		mp->rx_task.func(dev);
 		*budget -= work_done;
 		dev->quota -= work_done;
@@ -1163,8 +1127,8 @@
 	}
 
 	/* This is a hard error, log it. */
-	if ((MV64340_TX_QUEUE_SIZE - mp->tx_ring_skbs) <=
-	    (skb_shinfo(skb)->nr_frags + 1)) {
+	if ((mp->tx_ring_size - mp->tx_ring_skbs) <=
+					(skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
 		printk(KERN_ERR
 		       "%s: Bug in mv64340_eth - Trying to transmit when"
@@ -1175,6 +1139,7 @@
 	/* Paranoid check - this shouldn't happen */
 	if (skb == NULL) {
 		stats->tx_dropped++;
+		printk(KERN_ERR "mv64320_eth paranoid check failed\n");
 		return 1;
 	}
 
@@ -1182,39 +1147,85 @@
 
 	/* Update packet info data structure -- DMA owned, first last */
 #ifdef MV64340_CHECKSUM_OFFLOAD_TX
-	if (!skb_shinfo(skb)->nr_frags || (skb_shinfo(skb)->nr_frags > 3)) {
-#endif
-		pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
-	    	                   ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
+	if (!skb_shinfo(skb)->nr_frags) {
+linear:
+		if (skb->ip_summed != CHECKSUM_HW)
+			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
+							   ETH_TX_FIRST_DESC |
+							   ETH_TX_LAST_DESC;
+		else {
+			u32		ipheader = skb->nh.iph->ihl << 11;
 
+			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
+					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC |
+					ETH_GEN_TCP_UDP_CHECKSUM |
+					ETH_GEN_IP_V_4_CHECKSUM |
+					ipheader;
+			/* CPU already calculated pseudo header checksum. */
+			if (skb->nh.iph->protocol == IPPROTO_UDP) {
+				pkt_info.cmd_sts |= ETH_UDP_FRAME;
+				pkt_info.l4i_chk = skb->h.uh->check;
+			}
+			else if (skb->nh.iph->protocol == IPPROTO_TCP)
+				pkt_info.l4i_chk = skb->h.th->check;
+			else {
+				printk(KERN_ERR
+				       "%s: chksum proto != TCP or UDP\n",
+				       dev->name);
+				spin_unlock_irqrestore(&mp->lock, flags);
+				return 1;
+			}
+		}
 		pkt_info.byte_cnt = skb->len;
-		pkt_info.buf_ptr = pci_map_single(0, skb->data, skb->len,
-		                                  PCI_DMA_TODEVICE);
-
-
+		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
+							  DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
 		status = eth_port_send(mp, &pkt_info);
 		if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
 			printk(KERN_ERR "%s: Error on transmitting packet\n",
 				       dev->name);
 		mp->tx_ring_skbs++;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
 	} else {
 		unsigned int    frag;
 		u32		ipheader;
+		skb_frag_t	*last_frag;
+
+		frag = skb_shinfo(skb)->nr_frags - 1;
+		last_frag = &skb_shinfo(skb)->frags[frag];
+		if (last_frag->size <= 8 && last_frag->page_offset & 0x7) {
+			skb_linearize(skb, GFP_ATOMIC);
+			goto linear;
+		}
 
                 /* first frag which is skb header */
                 pkt_info.byte_cnt = skb_headlen(skb);
-                pkt_info.buf_ptr = pci_map_single(0, skb->data,
-                                        skb_headlen(skb), PCI_DMA_TODEVICE);
+                pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
+                                        skb_headlen(skb), DMA_TO_DEVICE);
                 pkt_info.return_info = 0;
-                ipheader = skb->nh.iph->ihl << 11;
-                pkt_info.cmd_sts = ETH_TX_FIRST_DESC | 
-					ETH_GEN_TCP_UDP_CHECKSUM |
+                pkt_info.cmd_sts = ETH_TX_FIRST_DESC;
+
+		if (skb->ip_summed == CHECKSUM_HW) {
+			/* CPU already calculated pseudo header checksum. */
+			ipheader = skb->nh.iph->ihl << 11;
+			pkt_info.cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 					ETH_GEN_IP_V_4_CHECKSUM |
-                                        ipheader;
-		/* CPU already calculated pseudo header checksum. So, use it */
-                pkt_info.l4i_chk = skb->h.th->check;
+					ipheader;
+			/* CPU already calculated pseudo header checksum. */
+			if (skb->nh.iph->protocol == IPPROTO_UDP) {
+				pkt_info.cmd_sts |= ETH_UDP_FRAME;
+				pkt_info.l4i_chk = skb->h.uh->check;
+			}
+			else if (skb->nh.iph->protocol == IPPROTO_TCP)
+				pkt_info.l4i_chk = skb->h.th->check;
+			else {
+				printk(KERN_ERR
+				       "%s: chksum proto != TCP or UDP\n",
+				       dev->name);
+				spin_unlock_irqrestore(&mp->lock, flags);
+				return 1;
+			}
+		}
+
                 status = eth_port_send(mp, &pkt_info);
 		if (status != ETH_OK) {
 	                if ((status == ETH_ERROR))
@@ -1242,12 +1253,10 @@
                                 pkt_info.return_info = 0;
                         }
                         pkt_info.byte_cnt = this_frag->size;
-                        if (this_frag->size < 8)
-                                printk("%d : \n", skb_shinfo(skb)->nr_frags);
 
-                        pkt_info.buf_ptr = pci_map_page(NULL, this_frag->page,
+                        pkt_info.buf_ptr = dma_map_page(NULL, this_frag->page,
                                         this_frag->page_offset,
-                                        this_frag->size, PCI_DMA_TODEVICE);
+                                        this_frag->size, DMA_TO_DEVICE);
 
                         status = eth_port_send(mp, &pkt_info);
 
@@ -1263,12 +1272,24 @@
 			}
                 }
         }
+#else
+	pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT | ETH_TX_FIRST_DESC |
+							ETH_TX_LAST_DESC;
+	pkt_info.byte_cnt = skb->len;
+	pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
+								DMA_TO_DEVICE);
+	pkt_info.return_info = skb;
+	status = eth_port_send(mp, &pkt_info);
+	if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
+		printk(KERN_ERR "%s: Error on transmitting packet\n",
+			       dev->name);
+	mp->tx_ring_skbs++;
 #endif
 
 	/* Check if TX queue can handle another skb. If not, then
 	 * signal higher layers to stop requesting TX
 	 */
-	if (MV64340_TX_QUEUE_SIZE <= (mp->tx_ring_skbs + 1))
+	if (mp->tx_ring_size <= (mp->tx_ring_skbs + MAX_DESCS_PER_SKB))
 		/* 
 		 * Stop getting skb's from upper layers.
 		 * Getting skb's from upper layers will be enabled again after
@@ -1304,29 +1325,40 @@
 }
 
 /*/
- * mv64340_eth_init
+ * mv64340_eth_probe
  *								       
  * First function called after registering the network device. 
  * It's purpose is to initialize the device as an ethernet device, 
- * fill the structure that was given in registration with pointers
- * to functions, and setting the MAC address of the interface
+ * fill the ethernet device structure with pointers * to functions,
+ * and set the MAC address of the interface
  *
- * Input : number of port to initialize
- * Output : -ENONMEM if failed , 0 if success
+ * Input : struct device *
+ * Output : -ENOMEM if failed , 0 if success
  */
-static struct net_device *mv64340_eth_init(int port_num)
+static int mv64340_eth_probe(struct device *ddev)
 {
+	struct platform_device *pdev = to_platform_device(ddev);
+	struct mv64xxx_eth_platform_data *pd;
+	int port_num = pdev->id;
 	struct mv64340_private *mp;
 	struct net_device *dev;
+	u8 *p;
+	struct resource *res;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct mv64340_private));
 	if (!dev)
-		return NULL;
+		return -ENOMEM;
+
+ 	dev_set_drvdata(ddev, dev);
 
 	mp = netdev_priv(dev);
 
-	dev->irq = ETH_PORT0_IRQ_NUM + port_num;
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	BUG_ON(!res);
+	dev->irq = res->start;
+
+	mp->port_num = port_num;
 
 	dev->open = mv64340_eth_open;
 	dev->stop = mv64340_eth_stop;
@@ -1343,7 +1375,7 @@
 #endif
 
 	dev->watchdog_timeo = 2 * HZ;
-	dev->tx_queue_len = MV64340_TX_QUEUE_SIZE;
+	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv64340_eth_change_mtu;
 
@@ -1359,60 +1391,149 @@
 #endif
 #endif
 
-	mp->port_num = port_num;
 
 	/* Configure the timeout task */
         INIT_WORK(&mp->tx_timeout_task,
                   (void (*)(void *))mv64340_eth_tx_timeout_task, dev);
 
 	spin_lock_init(&mp->lock);
+	
+	/* set default config values */
+	eth_port_uc_addr_get(dev, dev->dev_addr);
+	mp->port_config = MV64340_ETH_PORT_CONFIG_DEFAULT_VALUE;
+	mp->port_config_extend = MV64340_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE;
+	mp->port_sdma_config = MV64340_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE;
+	mp->port_serial_control = MV64340_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE;
+	mp->rx_ring_size = MV64340_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
+	mp->tx_ring_size = MV64340_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
+
+	pd = pdev->dev.platform_data;
+	if (pd) {
+		if (pd->mac_addr != NULL)
+			memcpy(dev->dev_addr, pd->mac_addr, 6);
+
+		if (pd->phy_addr || pd->force_phy_addr)
+			ethernet_phy_set(port_num, pd->phy_addr);
+
+		if (pd->port_config || pd->force_port_config)
+			mp->port_config = pd->port_config;
+
+		if (pd->port_config_extend || pd->force_port_config_extend)
+			mp->port_config_extend = pd->port_config_extend;
+
+		if (pd->port_sdma_config || pd->force_port_sdma_config)
+			mp->port_sdma_config = pd->port_sdma_config;
+
+		if (pd->port_serial_control || pd->force_port_serial_control)
+			mp->port_serial_control = pd->port_serial_control;
+
+		if (pd->rx_queue_size)
+			mp->rx_ring_size = pd->rx_queue_size;
+
+		if (pd->tx_queue_size)
+			mp->tx_ring_size = pd->tx_queue_size;
+
+		if (pd->tx_sram_size) {
+			mp->tx_sram_size = pd->tx_sram_size;
+			mp->tx_sram_addr = pd->tx_sram_addr;
+		}
 
-	/* set MAC addresses */
-	memcpy(dev->dev_addr, prom_mac_addr_base, 6);
-	dev->dev_addr[5] += port_num;
+		if (pd->rx_sram_size) {
+			mp->rx_sram_size = pd->rx_sram_size;
+			mp->rx_sram_addr = pd->rx_sram_addr;
+		}
+	}
 
 	err = register_netdev(dev);
 	if (err)
-		goto out_free_dev;
+		goto out;
 
-	printk(KERN_NOTICE "%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		dev->name, port_num,
-		dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
-		dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+	p = dev->dev_addr;
+	printk(KERN_NOTICE
+		"%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
+		dev->name, port_num, p[0], p[1], p[2], p[3], p[4], p[5]);
 
 	if (dev->features & NETIF_F_SG)
-		printk("Scatter Gather Enabled  ");
+		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
 
 	if (dev->features & NETIF_F_IP_CSUM)
-		printk("TX TCP/IP Checksumming Supported  \n");
+		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
+								dev->name);
+
+#ifdef MV64340_CHECKSUM_OFFLOAD_TX
+	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
+#endif
 
-	printk("RX TCP/UDP Checksum Offload ON, \n");
-	printk("TX and RX Interrupt Coalescing ON \n");
+#ifdef MV64340_COAL
+	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
+								dev->name);
+#endif
 
 #ifdef MV64340_NAPI
-	printk("RX NAPI Enabled \n");
+	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
 #endif
 
-	return dev;
+	return 0;
 
-out_free_dev:
+out:
 	free_netdev(dev);
 
-	return NULL;
+	return err;
 }
 
-static void mv64340_eth_remove(struct net_device *dev)
+static int mv64340_eth_remove(struct device *ddev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
+	struct net_device *dev = dev_get_drvdata(ddev);
 
 	unregister_netdev(dev);
 	flush_scheduled_work();
+
 	free_netdev(dev);
+	dev_set_drvdata(ddev, NULL);
+	return 0;
+}
+
+static int mv64340_eth_shared_probe(struct device *ddev)
+{
+	struct platform_device *pdev = to_platform_device(ddev);
+	struct resource *res;
+
+	printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (res == NULL)
+		return -ENODEV;
+
+	mv64x60_eth_shared_base = ioremap(res->start,
+						MV64340_ETH_SHARED_REGS_SIZE);
+	if (mv64x60_eth_shared_base == NULL)
+		return -ENOMEM;
+
+	return 0;
+
 }
 
-static struct net_device *mv64340_dev0;
-static struct net_device *mv64340_dev1;
-static struct net_device *mv64340_dev2;
+static int mv64340_eth_shared_remove(struct device *ddev)
+{
+	iounmap(mv64x60_eth_shared_base);
+	mv64x60_eth_shared_base = NULL;
+
+	return 0;
+}
+
+static struct device_driver mv643xx_eth_driver = {
+	.name	= MV64XXX_ETH_NAME,
+	.bus	= &platform_bus_type,
+	.probe	= mv64340_eth_probe,
+	.remove	= mv64340_eth_remove,
+};
+
+static struct device_driver mv643xx_eth_shared_driver = {
+	.name	= MV64XXX_ETH_SHARED_NAME,
+	.bus	= &platform_bus_type,
+	.probe	= mv64340_eth_shared_probe,
+	.remove	= mv64340_eth_shared_remove,
+};
 
 /*
  * mv64340_init_module
@@ -1425,30 +1546,15 @@
  */
 static int __init mv64340_init_module(void)
 {
-	printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+	int rc;
 
-#ifdef CONFIG_MV643XX_ETH_0
-	mv64340_dev0 = mv64340_eth_init(0);
-	if (!mv64340_dev0) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 0\n");
+	rc = driver_register(&mv643xx_eth_shared_driver);
+	if (!rc) {
+		rc = driver_register(&mv643xx_eth_driver);
+		if (rc)
+			driver_unregister(&mv643xx_eth_shared_driver);
 	}
-#endif
-#ifdef CONFIG_MV643XX_ETH_1
-	mv64340_dev1 = mv64340_eth_init(1);
-	if (!mv64340_dev1) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 1\n");
-	}
-#endif
-#ifdef CONFIG_MV643XX_ETH_2
-	mv64340_dev2 = mv64340_eth_init(2);
-	if (!mv64340_dev2) {
-		printk(KERN_ERR
-		       "Error registering MV-64360 ethernet port 2\n");
-	}
-#endif
-	return 0;
+	return rc;
 }
 
 /*
@@ -1462,19 +1568,16 @@
  */
 static void __exit mv64340_cleanup_module(void)
 {
-	if (mv64340_dev2)
-		mv64340_eth_remove(mv64340_dev2);
-	if (mv64340_dev1)
-		mv64340_eth_remove(mv64340_dev1);
-	if (mv64340_dev0)
-		mv64340_eth_remove(mv64340_dev0);
+	driver_unregister(&mv643xx_eth_driver);
+	driver_unregister(&mv643xx_eth_shared_driver);
 }
 
 module_init(mv64340_init_module);
 module_exit(mv64340_cleanup_module);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm and Manish Lachwani");
+MODULE_AUTHOR("Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
+		" and Dale Farnsworth");
 MODULE_DESCRIPTION("Ethernet driver for Marvell MV64340");
 
 /*
@@ -1605,12 +1708,6 @@
  *       port_sdma_config      User port SDMA config value.
  *       port_serial_control   User port serial control value.
  *
- *       This driver introduce a set of default values:
- *       PORT_CONFIG_VALUE           Default port configuration value
- *       PORT_CONFIG_EXTEND_VALUE    Default port extend configuration value
- *       PORT_SDMA_CONFIG_VALUE      Default sdma control value
- *       PORT_SERIAL_CONTROL_VALUE   Default port serial control value
- *
  *		This driver data flow is done using the struct pkt_info which
  *              is a unified struct for Rx and Tx operations:
  *
@@ -1627,25 +1724,11 @@
 #define ETH_ENABLE_TX_QUEUE(eth_port) \
 	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port), 1)
 
-#define ETH_DISABLE_TX_QUEUE(eth_port) \
-	MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << 8))
-
-#define ETH_ENABLE_RX_QUEUE(rx_queue, eth_port) \
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << rx_queue))
-
-#define ETH_DISABLE_RX_QUEUE(rx_queue, eth_port) \
-	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port),	\
-	         (1 << (8 + rx_queue)))
-
-#define LINK_UP_TIMEOUT		100000
-#define PHY_BUSY_TIMEOUT	10000000
-
 /* locals */
 
 /* PHY routines */
 static int ethernet_phy_get(unsigned int eth_port_num);
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
 
 /* Ethernet Port routines */
 static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
@@ -1677,18 +1760,6 @@
  */
 static void eth_port_init(struct mv64340_private * mp)
 {
-	mp->port_config = PORT_CONFIG_VALUE;
-	mp->port_config_extend = PORT_CONFIG_EXTEND_VALUE;
-#if defined(__BIG_ENDIAN)
-	mp->port_sdma_config = PORT_SDMA_CONFIG_VALUE;
-#elif defined(__LITTLE_ENDIAN)
-	mp->port_sdma_config = PORT_SDMA_CONFIG_VALUE |
-		ETH_BLM_RX_NO_SWAP | ETH_BLM_TX_NO_SWAP;
-#else
-#error One of __LITTLE_ENDIAN or __BIG_ENDIAN must be defined!
-#endif
-	mp->port_serial_control = PORT_SERIAL_CONTROL_VALUE;
-
 	mp->port_rx_queue_command = 0;
 	mp->port_tx_queue_command = 0;
 
@@ -1727,14 +1798,12 @@
  *       Ethernet port is ready to receive and transmit.
  *
  * RETURN:
- *       false if the port PHY is not up.
- *       true otherwise.
+ *       None.
  */
-static int eth_port_start(struct mv64340_private *mp)
+static void eth_port_start(struct mv64340_private *mp)
 {
 	unsigned int eth_port_num = mp->port_num;
 	int tx_curr_desc, rx_curr_desc;
-	unsigned int phy_reg_data;
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
@@ -1759,8 +1828,9 @@
 	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num),
 		 mp->port_serial_control);
 
-	MV_SET_REG_BITS(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num),
-			ETH_SERIAL_PORT_ENABLE);
+	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num),
+		MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num)) |
+						MV64340_ETH_SERIAL_PORT_ENABLE);
 
 	/* Assign port SDMA configuration */
 	MV_WRITE(MV64340_ETH_SDMA_CONFIG_REG(eth_port_num),
@@ -1769,14 +1839,6 @@
 	/* Enable port Rx. */
 	MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(eth_port_num),
 		 mp->port_rx_queue_command);
-
-	/* Check if link is up */
-	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data);
-
-	if (!(phy_reg_data & 0x20))
-		return 0;
-
-	return 1;
 }
 
 /*
@@ -1817,6 +1879,41 @@
 }
 
 /*
+ * eth_port_uc_addr_get - This function retrieves the port Unicast address
+ * (MAC address) from the ethernet hw registers.
+ *
+ * DESCRIPTION:
+ *		This function retrieves the port Ethernet MAC address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Port number.
+ *	char		*MacAddr	pointer where the MAC address is stored
+ *
+ * OUTPUT:
+ *	Copy the MAC address to the location pointed to by MacAddr
+ *
+ * RETURN:
+ *	N/A.
+ *
+ */
+static void eth_port_uc_addr_get(struct net_device *dev, unsigned char *p_addr)
+{
+	struct mv64340_private *mp = netdev_priv(dev);
+	unsigned int mac_h;
+	unsigned int mac_l;
+
+	mac_h = MV_READ(MV64340_ETH_MAC_ADDR_HIGH(mp->port_num));
+	mac_l = MV_READ(MV64340_ETH_MAC_ADDR_LOW(mp->port_num));
+
+	p_addr[0] = (mac_h >> 24) & 0xff;
+	p_addr[1] = (mac_h >> 16) & 0xff;
+	p_addr[2] = (mac_h >> 8) & 0xff;
+	p_addr[3] = mac_h & 0xff;
+	p_addr[4] = (mac_l >> 8) & 0xff;
+	p_addr[5] = mac_l & 0xff;
+}
+
+/*
  * eth_port_uc_addr - This function Set the port unicast address table
  *
  * DESCRIPTION:
@@ -1975,41 +2072,57 @@
 }
 
 /*
+ * ethernet_phy_set - Set the ethernet port PHY address.
+ *
+ * DESCRIPTION:
+ *       This routine sets the given ethernet port PHY address.
+ *
+ * INPUT:
+ *	unsigned int	eth_port_num	Ethernet Port number.
+ *	int		phy_addr	PHY address.
+ *
+ * OUTPUT:
+ *       None.
+ *
+ * RETURN:
+ *       None.
+ *
+ */
+static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr)
+{
+	u32 reg_data;
+	int addr_shift = 5 * eth_port_num;
+
+	reg_data = MV_READ(MV64340_ETH_PHY_ADDR_REG);
+	reg_data &= ~(0x1f << addr_shift);
+	reg_data |= (phy_addr & 0x1f) << addr_shift;
+	MV_WRITE(MV64340_ETH_PHY_ADDR_REG, reg_data);
+}
+
+/*
  * ethernet_phy_reset - Reset Ethernet port PHY.
  *
  * DESCRIPTION:
- *       This routine utilize the SMI interface to reset the ethernet port PHY.
- *       The routine waits until the link is up again or link up is timeout.
+ *       This routine utilizes the SMI interface to reset the ethernet port PHY.
  *
  * INPUT:
  *	unsigned int   eth_port_num   Ethernet Port number.
  *
  * OUTPUT:
- *       The ethernet port PHY renew its link.
+ *       The PHY is reset.
  *
  * RETURN:
  *       None.
  *
  */
-static int ethernet_phy_reset(unsigned int eth_port_num)
+static void ethernet_phy_reset(unsigned int eth_port_num)
 {
-	unsigned int time_out = 50;
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
 	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
 	eth_port_write_smi_reg(eth_port_num, 0, phy_reg_data);
-
-	/* Poll on the PHY LINK */
-	do {
-		eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data);
-
-		if (time_out-- == 0)
-			return 0;
-	} while (!(phy_reg_data & 0x20));
-
-	return 1;
 }
 
 /*
@@ -2030,62 +2143,48 @@
  *       None.
  *
  */
-static void eth_port_reset(unsigned int eth_port_num)
+static void eth_port_reset(unsigned int port_num)
 {
 	unsigned int reg_data;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	reg_data =
-	    MV_READ(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port_num));
+	reg_data = MV_READ(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG
-			 (eth_port_num), (reg_data << 8));
+		MV_WRITE(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
+							(reg_data << 8));
 
 		/* Wait for all Tx activity to terminate. */
-		do {
-			/* Check port cause register that all Tx queues are stopped */
-			reg_data =
-			    MV_READ
-			    (MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG
-			     (eth_port_num));
-		}
-		while (reg_data & 0xFF);
+		/* Check port cause register that all Tx queues are stopped */
+		while (MV_READ(MV64340_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
+									& 0xFF)
+			udelay(10);
 	}
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	reg_data =
-	    MV_READ(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			 (eth_port_num));
+	reg_data = MV_READ(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			 (eth_port_num), (reg_data << 8));
+		MV_WRITE(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+							(reg_data << 8));
 
 		/* Wait for all Rx activity to terminate. */
-		do {
-			/* Check port cause register that all Rx queues are stopped */
-			reg_data =
-			    MV_READ
-			    (MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG
-			     (eth_port_num));
-		}
-		while (reg_data & 0xFF);
+		/* Check port cause register that all Rx queues are stopped */
+		while (MV_READ(MV64340_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
+									& 0xFF)
+			udelay(10);
 	}
 
 
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(eth_port_num);
+	eth_clear_mib_counters(port_num);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data =
-	    MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG (eth_port_num));
-	reg_data &= ~ETH_SERIAL_PORT_ENABLE;
-	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(eth_port_num), reg_data);
-
-	return;
+	reg_data = MV_READ(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data &= ~MV64340_ETH_SERIAL_PORT_ENABLE;
+	MV_WRITE(MV64340_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 /*
@@ -2119,6 +2218,23 @@
 		 eth_config_reg);
 }
 
+static int eth_port_link_is_up(unsigned int eth_port_num)
+{
+	unsigned int phy_reg_data0;
+	unsigned int phy_reg_data1;
+
+	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data1);
+
+	if (phy_reg_data0 & 0x1000) {		/* auto-neg supported? */
+		if (phy_reg_data1 & 0x20)	/* auto-neg complete */
+			return 1;
+	} else
+		if (phy_reg_data1 & 0x4)	/* link up */
+			return 1;
+	return 0;
+}
+
 /*
  * ethernet_get_config_reg - Get the port configuration register
  *
@@ -2144,7 +2260,6 @@
 	return eth_config_reg;
 }
 
-
 /*
  * eth_port_read_smi_reg - Read PHY registers
  *
@@ -2153,7 +2268,7 @@
  *       order to perform PHY register read.
  *
  * INPUT:
- *	unsigned int   eth_port_num   Ethernet Port number.
+ *       unsigned int   port_num  Ethernet Port number.
  *       unsigned int   phy_reg   PHY register address offset.
  *       unsigned int   *value   Register value buffer.
  *
@@ -2165,41 +2280,41 @@
  *       true otherwise.
  *
  */
-static int eth_port_read_smi_reg(unsigned int eth_port_num,
+static void eth_port_read_smi_reg(unsigned int port_num,
 	unsigned int phy_reg, unsigned int *value)
 {
-	int phy_addr = ethernet_phy_get(eth_port_num);
-	unsigned int time_out = PHY_BUSY_TIMEOUT;
-	unsigned int reg_value;
-
-	/* first check that it is not busy */
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_BUSY);
+	int phy_addr = ethernet_phy_get(port_num);
+	unsigned long flags;
+	int i;
+
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mv64340_eth_phy_lock, flags);
 
-	/* not busy */
+	/* wait for the SMI register to become available */
+	for (i = 0; MV_READ(MV64340_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv64340 PHY busy timeout, port %d\n", port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
 
 	MV_WRITE(MV64340_ETH_SMI_REG,
 		 (phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
-	time_out = PHY_BUSY_TIMEOUT;	/* initialize the time out var again */
-
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_READ_VALID);
-
-	/* Wait for the data to update in the SMI register */
-	for (time_out = 0; time_out < PHY_BUSY_TIMEOUT; time_out++);
-
-	reg_value = MV_READ(MV64340_ETH_SMI_REG);
-
-	*value = reg_value & 0xffff;
+	/* now wait for the data to be valid */
+	for (i = 0; !(MV_READ(MV64340_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv64340 PHY read timeout, port %d\n", port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
+	 
+	*value = MV_READ(MV64340_ETH_SMI_REG) & 0xffff;
 
-	return 1;
+out:
+	spin_unlock_irqrestore(&mv64340_eth_phy_lock, flags);
 }
 
 /*
@@ -2222,27 +2337,32 @@
  *      true otherwise.
  *
  */
-static int eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(unsigned int eth_port_num,
 	unsigned int phy_reg, unsigned int value)
 {
-	unsigned int time_out = PHY_BUSY_TIMEOUT;
-	unsigned int reg_value;
 	int phy_addr;
+	int i;
+	unsigned long flags;
 
 	phy_addr = ethernet_phy_get(eth_port_num);
 
-	/* first check that it is not busy */
-	do {
-		reg_value = MV_READ(MV64340_ETH_SMI_REG);
-		if (time_out-- == 0)
-			return 0;
-	} while (reg_value & ETH_SMI_BUSY);
+	/* the SMI register is a shared resource */
+	spin_lock_irqsave(&mv64340_eth_phy_lock, flags);
+
+	/* wait for the SMI register to become available */
+	for (i = 0; MV_READ(MV64340_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+		if (i == PHY_WAIT_ITERATIONS) {
+			printk("mv64340 PHY busy timeout, port %d\n",
+								eth_port_num);
+			goto out;
+		}
+		udelay(PHY_WAIT_MICRO_SECONDS);
+	}
 
-	/* not busy */
 	MV_WRITE(MV64340_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 		 ETH_SMI_OPCODE_WRITE | (value & 0xffff));
-
-	return 1;
+out:
+	spin_unlock_irqrestore(&mv64340_eth_phy_lock, flags);
 }
 
 /*
@@ -2280,84 +2400,60 @@
                                          struct pkt_info * p_pkt_info)
 {
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
-	volatile struct eth_tx_desc *current_descriptor;
-	volatile struct eth_tx_desc *first_descriptor;
-	u32 command_status, first_chip_ptr;
+	struct eth_tx_desc *current_descriptor;
+	struct eth_tx_desc *first_descriptor;
+	u32 command;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
 	if (mp->tx_resource_err)
 		return ETH_QUEUE_FULL;
 
+	/*
+	 * The hardware requires that each buffer that is <= 8 bytes
+	 * in length must be aligned on an 8 byte boundary.
+	 */
+        if (p_pkt_info->byte_cnt <= 8 && p_pkt_info->buf_ptr & 0x7) {
+                printk(KERN_ERR
+			"mv64340_eth port %d: packet size <= 8 problem\n",
+			mp->port_num);
+                return ETH_ERROR;
+        }
+
 	/* Get the Tx Desc ring indexes */
 	tx_desc_curr = mp->tx_curr_desc_q;
 	tx_desc_used = mp->tx_used_desc_q;
 
 	current_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
-	if (current_descriptor == NULL)
-		return ETH_ERROR;
 
-	tx_next_desc = (tx_desc_curr + 1) % MV64340_TX_QUEUE_SIZE;
-	command_status = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC;
+	tx_next_desc = (tx_desc_curr + 1) % mp->tx_ring_size;
 
-	if (command_status & ETH_TX_FIRST_DESC) {
+        current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
+        current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
+        current_descriptor->l4i_chk = p_pkt_info->l4i_chk;
+        mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
+
+	command = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC |
+							ETH_BUFFER_OWNED_BY_DMA;
+	if (command & ETH_TX_LAST_DESC)
+		command |= ETH_TX_ENABLE_INTERRUPT;
+
+	if (command & ETH_TX_FIRST_DESC) {
 		tx_first_desc = tx_desc_curr;
 		mp->tx_first_desc_q = tx_first_desc;
-
-                /* fill first descriptor */
-                first_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
-                first_descriptor->l4i_chk = p_pkt_info->l4i_chk;
-                first_descriptor->cmd_sts = command_status;
-                first_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-                first_descriptor->buf_ptr = p_pkt_info->buf_ptr;
-                first_descriptor->next_desc_ptr = mp->tx_desc_dma +
-			tx_next_desc * sizeof(struct eth_tx_desc);
-		wmb();
+                first_descriptor = current_descriptor;
+		mp->tx_first_command = command;
         } else {
                 tx_first_desc = mp->tx_first_desc_q;
                 first_descriptor = &mp->p_tx_desc_area[tx_first_desc];
-                if (first_descriptor == NULL) {
-                        printk("First desc is NULL !!\n");
-                        return ETH_ERROR;
-                }
-                if (command_status & ETH_TX_LAST_DESC)
-                        current_descriptor->next_desc_ptr = 0x00000000;
-                else {
-                        command_status |= ETH_BUFFER_OWNED_BY_DMA;
-                        current_descriptor->next_desc_ptr = mp->tx_desc_dma +
-				tx_next_desc * sizeof(struct eth_tx_desc);
-                }
-        }
-
-        if (p_pkt_info->byte_cnt < 8) {
-                printk(" < 8 problem \n");
-                return ETH_ERROR;
+		BUG_ON(first_descriptor == NULL);
+		current_descriptor->cmd_sts = command;
         }
 
-        current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
-        current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-        current_descriptor->l4i_chk = p_pkt_info->l4i_chk;
-        current_descriptor->cmd_sts = command_status;
-
-        mp->tx_skb[tx_desc_curr] = (struct sk_buff*) p_pkt_info->return_info;
-
-        wmb();
-
-        /* Set last desc with DMA ownership and interrupt enable. */
-        if (command_status & ETH_TX_LAST_DESC) {
-                current_descriptor->cmd_sts = command_status |
-                                        ETH_TX_ENABLE_INTERRUPT |
-                                        ETH_BUFFER_OWNED_BY_DMA;
-
-		if (!(command_status & ETH_TX_FIRST_DESC))
-			first_descriptor->cmd_sts |= ETH_BUFFER_OWNED_BY_DMA;
+        if (command & ETH_TX_LAST_DESC) {
+		wmb();
+		first_descriptor->cmd_sts = mp->tx_first_command;
+ 
 		wmb();
-
-		first_chip_ptr = MV_READ(MV64340_ETH_CURRENT_SERVED_TX_DESC_PTR(mp->port_num));
-
-		/* Apply send command */
-		if (first_chip_ptr == 0x00000000)
-			MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(mp->port_num), (struct eth_tx_desc *) mp->tx_desc_dma + tx_first_desc);
-
                 ETH_ENABLE_TX_QUEUE(mp->port_num);
 
 		/*
@@ -2365,11 +2461,6 @@
 		 * error */
                 tx_first_desc = tx_next_desc;
                 mp->tx_first_desc_q = tx_first_desc;
-	} else {
-		if (! (command_status & ETH_TX_FIRST_DESC) ) {
-			current_descriptor->cmd_sts = command_status;
-			wmb();
-		}
 	}
 
         /* Check for ring index overlap in the Tx desc ring */
@@ -2381,7 +2472,6 @@
 	}
 
         mp->tx_curr_desc_q = tx_next_desc;
-        wmb();
 
         return ETH_OK;
 }
@@ -2391,7 +2481,7 @@
 {
 	int tx_desc_curr;
 	int tx_desc_used;
-	volatile struct eth_tx_desc* current_descriptor;
+	struct eth_tx_desc *current_descriptor;
 	unsigned int command_status;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
@@ -2403,36 +2493,21 @@
 	tx_desc_used = mp->tx_used_desc_q;
 	current_descriptor = &mp->p_tx_desc_area[tx_desc_curr];
 
-	if (current_descriptor == NULL)
-		return ETH_ERROR;
-
 	command_status = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC;
-
-/* XXX Is this for real ?!?!? */
-	/* Buffers with a payload smaller than 8 bytes must be aligned to a
-	 * 64-bit boundary. We use the memory allocated for Tx descriptor.
-	 * This memory is located in TX_BUF_OFFSET_IN_DESC offset within the
-	 * Tx descriptor. */
-	if (p_pkt_info->byte_cnt <= 8) {
-		printk(KERN_ERR
-		       "You have failed in the < 8 bytes errata - fixme\n");
-		return ETH_ERROR;
-	}
 	current_descriptor->buf_ptr = p_pkt_info->buf_ptr;
 	current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
-	mp->tx_skb[tx_desc_curr] = (struct sk_buff *) p_pkt_info->return_info;
-
-	mb();
+	mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
 
 	/* Set last desc with DMA ownership and interrupt enable. */
+	wmb();
 	current_descriptor->cmd_sts = command_status |
 			ETH_BUFFER_OWNED_BY_DMA | ETH_TX_ENABLE_INTERRUPT;
 
-	/* Apply send command */
+	wmb();
 	ETH_ENABLE_TX_QUEUE(mp->port_num);
 
 	/* Finish Tx packet. Update first desc in case of Tx resource error */
-	tx_desc_curr = (tx_desc_curr + 1) % MV64340_TX_QUEUE_SIZE;
+	tx_desc_curr = (tx_desc_curr + 1) % mp->tx_ring_size;
 
 	/* Update the current descriptor */
  	mp->tx_curr_desc_q = tx_desc_curr;
@@ -2474,40 +2549,33 @@
 static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv64340_private * mp,
 					      struct pkt_info * p_pkt_info)
 {
-	int tx_desc_used, tx_desc_curr;
+	int tx_desc_used;
 #ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        int tx_first_desc;
+        int tx_busy_desc = mp->tx_first_desc_q;
+#else
+	int tx_busy_desc = mp->tx_curr_desc_q;
 #endif
-	volatile struct eth_tx_desc *p_tx_desc_used;
+	struct eth_tx_desc *p_tx_desc_used;
 	unsigned int command_status;
 
 	/* Get the Tx Desc ring indexes */
-	tx_desc_curr = mp->tx_curr_desc_q;
 	tx_desc_used = mp->tx_used_desc_q;
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-        tx_first_desc = mp->tx_first_desc_q;
-#endif
+
 	p_tx_desc_used = &mp->p_tx_desc_area[tx_desc_used];
 
-	/* XXX Sanity check */
+	/* Sanity check */
 	if (p_tx_desc_used == NULL)
 		return ETH_ERROR;
 
+	/* Stop release. About to overlap the current available Tx descriptor */
+	if (tx_desc_used == tx_busy_desc && !mp->tx_resource_err)
+		return ETH_END_OF_JOB;
+
 	command_status = p_tx_desc_used->cmd_sts;
 
 	/* Still transmitting... */
-#ifndef MV64340_CHECKSUM_OFFLOAD_TX
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
 		return ETH_RETRY;
-#endif
-	/* Stop release. About to overlap the current available Tx descriptor */
-#ifdef MV64340_CHECKSUM_OFFLOAD_TX
-	if (tx_desc_used == tx_first_desc && !mp->tx_resource_err)
-		return ETH_END_OF_JOB;
-#else
-	if (tx_desc_used == tx_desc_curr && !mp->tx_resource_err)
-		return ETH_END_OF_JOB;
-#endif
 
 	/* Pass the packet information to the caller */
 	p_pkt_info->cmd_sts = command_status;
@@ -2515,7 +2583,7 @@
 	mp->tx_skb[tx_desc_used] = NULL;
 
 	/* Update the next descriptor to release. */
-	mp->tx_used_desc_q = (tx_desc_used + 1) % MV64340_TX_QUEUE_SIZE;
+	mp->tx_used_desc_q = (tx_desc_used + 1) % mp->tx_ring_size;
 
 	/* Any Tx return cancels the Tx resource error status */
 	mp->tx_resource_err = 0;
@@ -2565,6 +2633,7 @@
 
 	/* The following parameters are used to save readings from memory */
 	command_status = p_rx_desc->cmd_sts;
+	rmb();
 
 	/* Nothing to receive... */
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
@@ -2581,14 +2650,13 @@
 	mp->rx_skb[rx_curr_desc] = NULL;
 
 	/* Update current index in data structure */
-	rx_next_curr_desc = (rx_curr_desc + 1) % MV64340_RX_QUEUE_SIZE;
+	rx_next_curr_desc = (rx_curr_desc + 1) % mp->rx_ring_size;
 	mp->rx_curr_desc_q = rx_next_curr_desc;
 
 	/* Rx descriptors exhausted. Set the Rx ring resource error flag */
 	if (rx_next_curr_desc == rx_used_desc)
 		mp->rx_resource_err = 1;
 
-	mb();
 	return ETH_OK;
 }
 
@@ -2627,17 +2695,15 @@
 	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
 
 	/* Flush the write pipe */
-	mb();
 
 	/* Return the descriptor to DMA ownership */
+	wmb();
 	p_used_rx_desc->cmd_sts =
 		ETH_BUFFER_OWNED_BY_DMA | ETH_RX_ENABLE_INTERRUPT;
-
-	/* Flush descriptor and CPU pipe */
-	mb();
+	wmb();
 
 	/* Move the used descriptor pointer to the next descriptor */
-	mp->rx_used_desc_q = (used_rx_desc + 1) % MV64340_RX_QUEUE_SIZE;
+	mp->rx_used_desc_q = (used_rx_desc + 1) % mp->rx_ring_size;
 
 	/* Any Rx return cancels the Rx resource error status */
 	mp->rx_resource_err = 0;
diff -Nru a/drivers/net/mv643xx_eth.h b/drivers/net/mv643xx_eth.h
--- a/drivers/net/mv643xx_eth.h	2005-01-17 11:22:12 -07:00
+++ b/drivers/net/mv643xx_eth.h	2005-01-17 11:22:12 -07:00
@@ -46,15 +46,12 @@
  *  The first part is the high level driver of the gigE ethernet ports.
  */
 
-#define ETH_PORT0_IRQ_NUM 48			/* main high register, bit0 */
-#define ETH_PORT1_IRQ_NUM ETH_PORT0_IRQ_NUM+1	/* main high register, bit1 */
-#define ETH_PORT2_IRQ_NUM ETH_PORT0_IRQ_NUM+2	/* main high register, bit1 */
-
 /* Checksum offload for Tx works */
-#define  MV64340_CHECKSUM_OFFLOAD_TX
-#define	 MV64340_NAPI
-#define	 MV64340_TX_FAST_REFILL
-#undef	 MV64340_COAL
+#define	MV64340_CHECKSUM_OFFLOAD_TX
+#define	MV64340_NAPI
+#define	MV64340_TX_FAST_REFILL
+#undef	MV64340_RX_QUEUE_FILL_ON_TASK		/* Does not work, yet */
+#undef	MV64340_COAL
 
 /* 
  * Number of RX / TX descriptors on RX / TX rings.
@@ -65,10 +62,10 @@
  */
 
 /* Default TX ring size is 1000 descriptors */
-#define MV64340_TX_QUEUE_SIZE 1000
+#define MV64340_DEFAULT_TX_QUEUE_SIZE 1000
 
 /* Default RX ring size is 400 descriptors */
-#define MV64340_RX_QUEUE_SIZE 400
+#define MV64340_DEFAULT_RX_QUEUE_SIZE 400
 
 #define MV64340_TX_COAL 100
 #ifdef MV64340_COAL
@@ -93,58 +90,6 @@
  *
  */
 
-/* Default port configuration value */
-#define PORT_CONFIG_VALUE                       \
-             ETH_UNICAST_NORMAL_MODE		|   \
-             ETH_DEFAULT_RX_QUEUE_0		|   \
-             ETH_DEFAULT_RX_ARP_QUEUE_0		|   \
-             ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|   \
-             ETH_RECEIVE_BC_IF_IP		|   \
-             ETH_RECEIVE_BC_IF_ARP 		|   \
-             ETH_CAPTURE_TCP_FRAMES_DIS		|   \
-             ETH_CAPTURE_UDP_FRAMES_DIS		|   \
-             ETH_DEFAULT_RX_TCP_QUEUE_0		|   \
-             ETH_DEFAULT_RX_UDP_QUEUE_0		|   \
-             ETH_DEFAULT_RX_BPDU_QUEUE_0
-
-/* Default port extend configuration value */
-#define PORT_CONFIG_EXTEND_VALUE		\
-             ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|   \
-             ETH_PARTITION_DISABLE
-
-
-/* Default sdma control value */
-#define PORT_SDMA_CONFIG_VALUE			\
-			 ETH_RX_BURST_SIZE_16_64BIT 	|	\
-			 GT_ETH_IPG_INT_RX(0) 		|	\
-			 ETH_TX_BURST_SIZE_16_64BIT;
-
-#define GT_ETH_IPG_INT_RX(value)                \
-            ((value & 0x3fff) << 8)
-
-/* Default port serial control value */
-#define PORT_SERIAL_CONTROL_VALUE		\
-			ETH_FORCE_LINK_PASS 			|	\
-			ETH_ENABLE_AUTO_NEG_FOR_DUPLX		|	\
-			ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL 	|	\
-			ETH_ADV_SYMMETRIC_FLOW_CTRL 		|	\
-			ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX 	|	\
-			ETH_FORCE_BP_MODE_NO_JAM 		|	\
-			BIT9 					|	\
-			ETH_DO_NOT_FORCE_LINK_FAIL 		|	\
-			ETH_RETRANSMIT_16_ATTEMPTS 		|	\
-			ETH_ENABLE_AUTO_NEG_SPEED_GMII	 	|	\
-			ETH_DTE_ADV_0 				|	\
-			ETH_DISABLE_AUTO_NEG_BYPASS		|	\
-			ETH_AUTO_NEG_NO_CHANGE 			|	\
-			ETH_MAX_RX_PACKET_9700BYTE 		|	\
-			ETH_CLR_EXT_LOOPBACK 			|	\
-			ETH_SET_FULL_DUPLEX_MODE 		|	\
-			ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-#define RX_BUFFER_MAX_SIZE  0x4000000
-#define TX_BUFFER_MAX_SIZE  0x4000000
-
 /* MAC accepet/reject macros */
 #define ACCEPT_MAC_ADDR	    0
 #define REJECT_MAC_ADDR	    1
@@ -211,156 +156,12 @@
 #define ETH_PORT_TX_FIFO_EMPTY                          BIT10
 
 
-/* These macros describes the Port configuration reg (Px_cR) bits */
-#define ETH_UNICAST_NORMAL_MODE                         0
-#define ETH_UNICAST_PROMISCUOUS_MODE                    BIT0
-#define ETH_DEFAULT_RX_QUEUE_0                          0
-#define ETH_DEFAULT_RX_QUEUE_1                          BIT1
-#define ETH_DEFAULT_RX_QUEUE_2                          BIT2
-#define ETH_DEFAULT_RX_QUEUE_3                          (BIT2 | BIT1)
-#define ETH_DEFAULT_RX_QUEUE_4                          BIT3
-#define ETH_DEFAULT_RX_QUEUE_5                          (BIT3 | BIT1)
-#define ETH_DEFAULT_RX_QUEUE_6                          (BIT3 | BIT2)
-#define ETH_DEFAULT_RX_QUEUE_7                          (BIT3 | BIT2 | BIT1)
-#define ETH_DEFAULT_RX_ARP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_ARP_QUEUE_1                      BIT4
-#define ETH_DEFAULT_RX_ARP_QUEUE_2                      BIT5
-#define ETH_DEFAULT_RX_ARP_QUEUE_3                      (BIT5 | BIT4)
-#define ETH_DEFAULT_RX_ARP_QUEUE_4                      BIT6
-#define ETH_DEFAULT_RX_ARP_QUEUE_5                      (BIT6 | BIT4)
-#define ETH_DEFAULT_RX_ARP_QUEUE_6                      (BIT6 | BIT5)
-#define ETH_DEFAULT_RX_ARP_QUEUE_7                      (BIT6 | BIT5 | BIT4)
-#define ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP                 0
-#define ETH_REJECT_BC_IF_NOT_IP_OR_ARP                  BIT7
-#define ETH_RECEIVE_BC_IF_IP                            0
-#define ETH_REJECT_BC_IF_IP                             BIT8
-#define ETH_RECEIVE_BC_IF_ARP                           0
-#define ETH_REJECT_BC_IF_ARP                            BIT9
-#define ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY               BIT12
-#define ETH_CAPTURE_TCP_FRAMES_DIS                      0
-#define ETH_CAPTURE_TCP_FRAMES_EN                       BIT14
-#define ETH_CAPTURE_UDP_FRAMES_DIS                      0
-#define ETH_CAPTURE_UDP_FRAMES_EN                       BIT15
-#define ETH_DEFAULT_RX_TCP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_TCP_QUEUE_1                      BIT16
-#define ETH_DEFAULT_RX_TCP_QUEUE_2                      BIT17
-#define ETH_DEFAULT_RX_TCP_QUEUE_3                      (BIT17 | BIT16)
-#define ETH_DEFAULT_RX_TCP_QUEUE_4                      BIT18
-#define ETH_DEFAULT_RX_TCP_QUEUE_5                      (BIT18 | BIT16)
-#define ETH_DEFAULT_RX_TCP_QUEUE_6                      (BIT18 | BIT17)
-#define ETH_DEFAULT_RX_TCP_QUEUE_7                      (BIT18 | BIT17 | BIT16)
-#define ETH_DEFAULT_RX_UDP_QUEUE_0                      0
-#define ETH_DEFAULT_RX_UDP_QUEUE_1                      BIT19
-#define ETH_DEFAULT_RX_UDP_QUEUE_2                      BIT20
-#define ETH_DEFAULT_RX_UDP_QUEUE_3                      (BIT20 | BIT19)
-#define ETH_DEFAULT_RX_UDP_QUEUE_4                      (BIT21
-#define ETH_DEFAULT_RX_UDP_QUEUE_5                      (BIT21 | BIT19)
-#define ETH_DEFAULT_RX_UDP_QUEUE_6                      (BIT21 | BIT20)
-#define ETH_DEFAULT_RX_UDP_QUEUE_7                      (BIT21 | BIT20 | BIT19)
-#define ETH_DEFAULT_RX_BPDU_QUEUE_0                      0
-#define ETH_DEFAULT_RX_BPDU_QUEUE_1                     BIT22
-#define ETH_DEFAULT_RX_BPDU_QUEUE_2                     BIT23
 #define ETH_DEFAULT_RX_BPDU_QUEUE_3                     (BIT23 | BIT22)
 #define ETH_DEFAULT_RX_BPDU_QUEUE_4                     BIT24
 #define ETH_DEFAULT_RX_BPDU_QUEUE_5                     (BIT24 | BIT22)
 #define ETH_DEFAULT_RX_BPDU_QUEUE_6                     (BIT24 | BIT23)
 #define ETH_DEFAULT_RX_BPDU_QUEUE_7                     (BIT24 | BIT23 | BIT22)
 
-
-/* These macros describes the Port configuration extend reg (Px_cXR) bits*/
-#define ETH_CLASSIFY_EN                                 BIT0
-#define ETH_SPAN_BPDU_PACKETS_AS_NORMAL                 0
-#define ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7             BIT1
-#define ETH_PARTITION_DISABLE                           0
-#define ETH_PARTITION_ENABLE                            BIT2
-
-
-/* Tx/Rx queue command reg (RQCR/TQCR)*/
-#define ETH_QUEUE_0_ENABLE                              BIT0
-#define ETH_QUEUE_1_ENABLE                              BIT1
-#define ETH_QUEUE_2_ENABLE                              BIT2
-#define ETH_QUEUE_3_ENABLE                              BIT3
-#define ETH_QUEUE_4_ENABLE                              BIT4
-#define ETH_QUEUE_5_ENABLE                              BIT5
-#define ETH_QUEUE_6_ENABLE                              BIT6
-#define ETH_QUEUE_7_ENABLE                              BIT7
-#define ETH_QUEUE_0_DISABLE                             BIT8
-#define ETH_QUEUE_1_DISABLE                             BIT9
-#define ETH_QUEUE_2_DISABLE                             BIT10
-#define ETH_QUEUE_3_DISABLE                             BIT11
-#define ETH_QUEUE_4_DISABLE                             BIT12
-#define ETH_QUEUE_5_DISABLE                             BIT13
-#define ETH_QUEUE_6_DISABLE                             BIT14
-#define ETH_QUEUE_7_DISABLE                             BIT15
-
-
-/* These macros describes the Port Sdma configuration reg (SDCR) bits */
-#define ETH_RIFB                                        BIT0
-#define ETH_RX_BURST_SIZE_1_64BIT                       0
-#define ETH_RX_BURST_SIZE_2_64BIT                       BIT1
-#define ETH_RX_BURST_SIZE_4_64BIT                       BIT2
-#define ETH_RX_BURST_SIZE_8_64BIT                       (BIT2 | BIT1)
-#define ETH_RX_BURST_SIZE_16_64BIT                      BIT3
-#define ETH_BLM_RX_NO_SWAP                              BIT4
-#define ETH_BLM_RX_BYTE_SWAP                            0
-#define ETH_BLM_TX_NO_SWAP                              BIT5
-#define ETH_BLM_TX_BYTE_SWAP                            0
-#define ETH_DESCRIPTORS_BYTE_SWAP                       BIT6
-#define ETH_DESCRIPTORS_NO_SWAP                         0
-#define ETH_TX_BURST_SIZE_1_64BIT                       0
-#define ETH_TX_BURST_SIZE_2_64BIT                       BIT22
-#define ETH_TX_BURST_SIZE_4_64BIT                       BIT23
-#define ETH_TX_BURST_SIZE_8_64BIT                       (BIT23 | BIT22)
-#define ETH_TX_BURST_SIZE_16_64BIT                      BIT24
-
-
-
-/* These macros describes the Port serial control reg (PSCR) bits */
-#define ETH_SERIAL_PORT_DISABLE                         0
-#define ETH_SERIAL_PORT_ENABLE                          BIT0
-#define ETH_FORCE_LINK_PASS                             BIT1
-#define ETH_DO_NOT_FORCE_LINK_PASS                      0
-#define ETH_ENABLE_AUTO_NEG_FOR_DUPLX                   0
-#define ETH_DISABLE_AUTO_NEG_FOR_DUPLX                  BIT2
-#define ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL               0
-#define ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL              BIT3
-#define ETH_ADV_NO_FLOW_CTRL                            0
-#define ETH_ADV_SYMMETRIC_FLOW_CTRL                     BIT4
-#define ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX               0
-#define ETH_FORCE_FC_MODE_TX_PAUSE_DIS                  BIT5
-#define ETH_FORCE_BP_MODE_NO_JAM                        0
-#define ETH_FORCE_BP_MODE_JAM_TX                        BIT7
-#define ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR              BIT8
-#define ETH_FORCE_LINK_FAIL                             0
-#define ETH_DO_NOT_FORCE_LINK_FAIL                      BIT10
-#define ETH_RETRANSMIT_16_ATTEMPTS                      0
-#define ETH_RETRANSMIT_FOREVER                          BIT11
-#define ETH_DISABLE_AUTO_NEG_SPEED_GMII                 BIT13
-#define ETH_ENABLE_AUTO_NEG_SPEED_GMII                  0
-#define ETH_DTE_ADV_0                                   0
-#define ETH_DTE_ADV_1                                   BIT14
-#define ETH_DISABLE_AUTO_NEG_BYPASS                     0
-#define ETH_ENABLE_AUTO_NEG_BYPASS                      BIT15
-#define ETH_AUTO_NEG_NO_CHANGE                          0
-#define ETH_RESTART_AUTO_NEG                            BIT16
-#define ETH_MAX_RX_PACKET_1518BYTE                      0
-#define ETH_MAX_RX_PACKET_1522BYTE                      BIT17
-#define ETH_MAX_RX_PACKET_1552BYTE                      BIT18
-#define ETH_MAX_RX_PACKET_9022BYTE                      (BIT18 | BIT17)
-#define ETH_MAX_RX_PACKET_9192BYTE                      BIT19
-#define ETH_MAX_RX_PACKET_9700BYTE                      (BIT19 | BIT17)
-#define ETH_SET_EXT_LOOPBACK                            BIT20
-#define ETH_CLR_EXT_LOOPBACK                            0
-#define ETH_SET_FULL_DUPLEX_MODE                        BIT21
-#define ETH_SET_HALF_DUPLEX_MODE                        0
-#define ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX       BIT22
-#define ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX      0
-#define ETH_SET_GMII_SPEED_TO_10_100                    0
-#define ETH_SET_GMII_SPEED_TO_1000                      BIT23
-#define ETH_SET_MII_SPEED_TO_10                         0
-#define ETH_SET_MII_SPEED_TO_100                        BIT24
-
-
 /* SMI reg */
 #define ETH_SMI_BUSY        	BIT28	/* 0 - Write, 1 - Read          */
 #define ETH_SMI_READ_VALID  	BIT27	/* 0 - Write, 1 - Read          */
@@ -499,6 +300,11 @@
 	u32	port_tx_queue_command;	/* Port active Tx queues summary */
 	u32	port_rx_queue_command;	/* Port active Rx queues summary */
 
+	u32	rx_sram_addr;		/* Base address of rx sram area	*/
+	u32	rx_sram_size;		/* Size of rx sram area		*/
+	u32	tx_sram_addr;		/* Base address of tx sram area	*/
+	u32	tx_sram_size;		/* Size of tx sram area		*/
+
 	int	rx_resource_err;	/* Rx ring resource error flag */
 	int	tx_resource_err;	/* Tx ring resource error flag */
 
@@ -511,21 +317,22 @@
 	int tx_curr_desc_q, tx_used_desc_q;
 #ifdef MV64340_CHECKSUM_OFFLOAD_TX
         int tx_first_desc_q;
+	u32 tx_first_command;
 #endif
 
 #ifdef MV64340_TX_FAST_REFILL
 	u32	tx_clean_threshold;
 #endif
 
-	volatile struct eth_rx_desc	* p_rx_desc_area;
+	struct eth_rx_desc		* p_rx_desc_area;
 	dma_addr_t			rx_desc_dma;
 	unsigned int			rx_desc_area_size;
-	struct sk_buff			* rx_skb[MV64340_RX_QUEUE_SIZE];
+	struct sk_buff			** rx_skb;
 
-	volatile struct eth_tx_desc	* p_tx_desc_area;
+	struct eth_tx_desc		* p_tx_desc_area;
 	dma_addr_t			tx_desc_dma;
 	unsigned int			tx_desc_area_size;
-	struct sk_buff			* tx_skb[MV64340_TX_QUEUE_SIZE];
+	struct sk_buff			** tx_skb;
 
 	struct work_struct		tx_timeout_task;
 
@@ -565,7 +372,7 @@
 /* Port operation control routines */
 static void eth_port_init(struct mv64340_private *mp);
 static void eth_port_reset(unsigned int eth_port_num);
-static int eth_port_start(struct mv64340_private *mp);
+static void eth_port_start(struct mv64340_private *mp);
 
 static void ethernet_set_config_reg(unsigned int eth_port_num,
 				    unsigned int value);
@@ -576,13 +383,13 @@
 				 unsigned char *p_addr);
 
 /* PHY and MIB routines */
-static int ethernet_phy_reset(unsigned int eth_port_num);
+static void ethernet_phy_reset(unsigned int eth_port_num);
 
-static int eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(unsigned int eth_port_num,
 				   unsigned int phy_reg,
 				   unsigned int value);
 
-static int eth_port_read_smi_reg(unsigned int eth_port_num,
+static void eth_port_read_smi_reg(unsigned int eth_port_num,
 				  unsigned int phy_reg,
 				  unsigned int *value);
 
diff -Nru a/include/linux/mv643xx.h b/include/linux/mv643xx.h
--- a/include/linux/mv643xx.h	2005-01-17 11:22:12 -07:00
+++ b/include/linux/mv643xx.h	2005-01-17 11:22:12 -07:00
@@ -662,6 +662,9 @@
 /*        Ethernet Unit Registers  		*/
 /****************************************/
 
+#define MV64340_ETH_SHARED_REGS                                     0x2000
+#define MV64340_ETH_SHARED_REGS_SIZE                                0x2000
+
 #define MV64340_ETH_PHY_ADDR_REG                                    0x2000
 #define MV64340_ETH_SMI_REG                                         0x2004
 #define MV64340_ETH_UNIT_DEFAULT_ADDR_REG                           0x2008
@@ -1083,6 +1086,209 @@
 	u8	brg_can_tune;
 	u8	brg_clk_src;
 	u32	brg_clk_freq;
+};
+
+/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
+#define MV64340_ETH_UNICAST_NORMAL_MODE		0
+#define MV64340_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
+#define MV64340_ETH_DEFAULT_RX_QUEUE_0		0
+#define MV64340_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
+#define MV64340_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
+#define MV64340_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
+#define MV64340_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
+#define MV64340_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
+#define MV64340_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
+#define MV64340_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_0	0
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
+#define MV64340_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
+#define MV64340_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
+#define MV64340_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
+#define MV64340_ETH_RECEIVE_BC_IF_IP		0
+#define MV64340_ETH_REJECT_BC_IF_IP		(1<<8)
+#define MV64340_ETH_RECEIVE_BC_IF_ARP		0
+#define MV64340_ETH_REJECT_BC_IF_ARP		(1<<9)
+#define MV64340_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
+#define MV64340_ETH_CAPTURE_TCP_FRAMES_DIS	0
+#define MV64340_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
+#define MV64340_ETH_CAPTURE_UDP_FRAMES_DIS	0
+#define MV64340_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_0	0
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
+#define MV64340_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_0	0
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21)
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
+#define MV64340_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
+#define MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+
+#define	MV64340_ETH_PORT_CONFIG_DEFAULT_VALUE			\
+		MV64340_ETH_UNICAST_NORMAL_MODE		|	\
+		MV64340_ETH_DEFAULT_RX_QUEUE_0		|	\
+		MV64340_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
+		MV64340_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		MV64340_ETH_RECEIVE_BC_IF_IP		|	\
+		MV64340_ETH_RECEIVE_BC_IF_ARP		|	\
+		MV64340_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
+		MV64340_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
+		MV64340_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
+		MV64340_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
+		MV64340_ETH_DEFAULT_RX_BPDU_QUEUE_0
+
+/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
+#define MV64340_ETH_CLASSIFY_EN				(1<<0)
+#define MV64340_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
+#define MV64340_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
+#define MV64340_ETH_PARTITION_DISABLE			0
+#define MV64340_ETH_PARTITION_ENABLE			(1<<2)
+
+#define	MV64340_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		MV64340_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		MV64340_ETH_PARTITION_DISABLE
+
+/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
+#define MV64340_ETH_RIFB			(1<<0)
+#define MV64340_ETH_RX_BURST_SIZE_1_64BIT		0
+#define MV64340_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
+#define MV64340_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
+#define MV64340_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
+#define MV64340_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
+#define MV64340_ETH_BLM_RX_NO_SWAP			(1<<4)
+#define MV64340_ETH_BLM_RX_BYTE_SWAP			0
+#define MV64340_ETH_BLM_TX_NO_SWAP			(1<<5)
+#define MV64340_ETH_BLM_TX_BYTE_SWAP			0
+#define MV64340_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
+#define MV64340_ETH_DESCRIPTORS_NO_SWAP			0
+#define MV64340_ETH_TX_BURST_SIZE_1_64BIT		0
+#define MV64340_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
+#define MV64340_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
+#define MV64340_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
+#define MV64340_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
+
+#define	MV64340_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
+
+#define	MV64340_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		MV64340_ETH_RX_BURST_SIZE_4_64BIT	|	\
+		MV64340_ETH_IPG_INT_RX(0)		|	\
+		MV64340_ETH_TX_BURST_SIZE_4_64BIT
+
+/* These macros describe Ethernet Port serial control reg (PSCR) bits */
+#define MV64340_ETH_SERIAL_PORT_DISABLE			0
+#define MV64340_ETH_SERIAL_PORT_ENABLE			(1<<0)
+#define MV64340_ETH_FORCE_LINK_PASS			(1<<1)
+#define MV64340_ETH_DO_NOT_FORCE_LINK_PASS		0
+#define MV64340_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
+#define MV64340_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
+#define MV64340_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define MV64340_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
+#define MV64340_ETH_ADV_NO_FLOW_CTRL			0
+#define MV64340_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
+#define MV64340_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
+#define MV64340_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
+#define MV64340_ETH_FORCE_BP_MODE_NO_JAM		0
+#define MV64340_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
+#define MV64340_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
+#define MV64340_ETH_FORCE_LINK_FAIL			0
+#define MV64340_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
+#define MV64340_ETH_RETRANSMIT_16_ATTEMPTS		0
+#define MV64340_ETH_RETRANSMIT_FOREVER			(1<<11)
+#define MV64340_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
+#define MV64340_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
+#define MV64340_ETH_DTE_ADV_0				0
+#define MV64340_ETH_DTE_ADV_1				(1<<14)
+#define MV64340_ETH_DISABLE_AUTO_NEG_BYPASS		0
+#define MV64340_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
+#define MV64340_ETH_AUTO_NEG_NO_CHANGE			0
+#define MV64340_ETH_RESTART_AUTO_NEG			(1<<16)
+#define MV64340_ETH_MAX_RX_PACKET_1518BYTE		0
+#define MV64340_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
+#define MV64340_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
+#define MV64340_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
+#define MV64340_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
+#define MV64340_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
+#define MV64340_ETH_SET_EXT_LOOPBACK			(1<<20)
+#define MV64340_ETH_CLR_EXT_LOOPBACK			0
+#define MV64340_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
+#define MV64340_ETH_SET_HALF_DUPLEX_MODE		0
+#define MV64340_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
+#define MV64340_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
+#define MV64340_ETH_SET_GMII_SPEED_TO_10_100		0
+#define MV64340_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
+#define MV64340_ETH_SET_MII_SPEED_TO_10			0
+#define MV64340_ETH_SET_MII_SPEED_TO_100		(1<<24)
+
+#define	MV64340_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
+		MV64340_ETH_DO_NOT_FORCE_LINK_PASS	|	\
+		MV64340_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
+		MV64340_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
+		MV64340_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
+		MV64340_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
+		MV64340_ETH_FORCE_BP_MODE_NO_JAM	|	\
+		(1<<9)	/* reserved */			|	\
+		MV64340_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
+		MV64340_ETH_RETRANSMIT_16_ATTEMPTS	|	\
+		MV64340_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
+		MV64340_ETH_DTE_ADV_0			|	\
+		MV64340_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
+		MV64340_ETH_AUTO_NEG_NO_CHANGE		|	\
+		MV64340_ETH_MAX_RX_PACKET_9700BYTE	|	\
+		MV64340_ETH_CLR_EXT_LOOPBACK		|	\
+		MV64340_ETH_SET_FULL_DUPLEX_MODE	|	\
+		MV64340_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
+
+#define	MV64340_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
+#define	MV64340_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
+
+#define MV64340_ETH_DESC_SIZE				64
+
+#define MV64XXX_ETH_SHARED_NAME	"mv64xxx_eth_shared"
+#define MV64XXX_ETH_NAME	"mv64xxx_eth"
+
+struct mv64xxx_eth_platform_data {
+	/* 
+	 * Non-values for mac_addr, phy_addr, port_config, etc.
+	 * override the default value.  Setting the corresponding
+	 * force_* field, causes the default value to be overridden
+	 * even when zero.
+	 */
+	unsigned int	force_phy_addr:1;
+	unsigned int	force_port_config:1;
+	unsigned int	force_port_config_extend:1;
+	unsigned int	force_port_sdma_config:1;
+	unsigned int	force_port_serial_control:1;
+	int		phy_addr;
+	char		*mac_addr;	/* pointer to mac address */
+	u32		port_config;
+	u32		port_config_extend;
+	u32		port_sdma_config;
+	u32		port_serial_control;
+	u32		tx_queue_size;
+	u32		rx_queue_size;
+	u32		tx_sram_addr;
+	u32		tx_sram_size;
+	u32		rx_sram_addr;
+	u32		rx_sram_size;
 };
 
 #endif /* __ASM_MV64340_H */
