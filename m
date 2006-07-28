From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: SMSC LAN911x and LAN921x vendor driver
Date: Fri, 28 Jul 2006 12:48:53 +0100
Message-ID: <11540873333102-git-send-email-steve.glendinning@smsc.com>
References: <20060714115035.502d8edf@dxpl.pdx.osdl.net>
Reply-To: Steve Glendinning <steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <Bahadir.Balban@arm.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.8.5] ([86.54.8.5]:4273 "EHLO drevil.shawell.net")
	by vger.kernel.org with ESMTP id S1161123AbWG1Ltf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 07:49:35 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060714115035.502d8edf@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Attached is a driver patch for SMSC911x family of ethernet chips,
> generated against 2.6.18-rc1 sources. There's a similar driver in the
> tree; this one has been tested by SMSC on all flavors of the chip and
> claimed to be efficient.

Updated after feedback from Stephen Hemminger.

Driver updated to also support LAN921x family.  Workarounds added for
known hardware issues.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/Kconfig    |    7 
 drivers/net/Makefile   |    1 
 drivers/net/smsc911x.c | 2289 ++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/smsc911x.h |  504 +++++++++++
 4 files changed, 2801 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3918990..7e1fff2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -865,6 +865,13 @@ config NET_NETX
 	  <file:Documentation/networking/net-modules.txt>. The module
 	  will be called netx-eth.
 
+config SMSC911X
+		 tristate "SMSC 911x family of embedded ethernet support"
+		 depends on NET_ETHERNET
+		 ---help---
+		   Say Y here if you want support for SMSC LAN911x family
+		   of ethernet chips.
+
 config DM9000
 	tristate "DM9000 support"
 	depends on (ARM || MIPS) && NET_ETHERNET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c91e951..51f680b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -196,6 +196,7 @@ obj-$(CONFIG_S2IO) += s2io.o
 obj-$(CONFIG_MYRI10GE) += myri10ge/
 obj-$(CONFIG_SMC91X) += smc91x.o
 obj-$(CONFIG_SMC911X) += smc911x.o
+obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_FEC_8XX) += fec_8xx/
 
diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
new file mode 100644
index 0000000..12bbe67
--- /dev/null
+++ b/drivers/net/smsc911x.c
@@ -0,0 +1,2289 @@
+/***************************************************************************
+ *
+ * Copyright (C) 2004-2005  SMSC
+ * Copyright (C) 2005 ARM
+ *
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
+ *
+ ***************************************************************************
+ * Rewritten, heavily based on smsc911x simple driver by SMSC.
+ * Partly uses io macros from smc91x.c by Nicolas Pitre
+ *
+ * History:
+ *   05/05/2005 bahadir.balban@arm.com
+ *     - Transition to linux coding style
+ *     - Platform driver and module interface
+ *
+ *   17/07/2006  steve.glendinning@smsc.com
+ *     - Added support for LAN921x family
+ *     - Added workaround for multicast filters
+ */
+
+#include <linux/config.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/init.h>
+#include <linux/ioport.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/timer.h>
+#include <linux/version.h>
+#include <asm/bug.h>
+#include <asm/bitops.h>
+#include <asm/dma.h>
+#include <asm/irq.h>
+#include <asm/io.h>
+#include "smsc911x.h"
+
+#define SMSC_CHIPNAME		 "smsc911x"
+
+/* Tasklet declarations */
+static unsigned long rx_tasklet_parameter;
+static void smsc911x_rx_tasklet(unsigned long data);
+
+DECLARE_TASKLET(rx_tasklet, smsc911x_rx_tasklet, 0);
+MODULE_LICENSE("GPL");
+
+/* MAC */
+static int smsc911x_mac_notbusy(struct smsc911x_data *pdata);
+
+static unsigned int smsc911x_mac_read(struct smsc911x_data *pdata,
+				      unsigned int offset);
+
+static void smsc911x_mac_write(struct smsc911x_data *pdata,
+			       unsigned int offset, unsigned int value);
+
+/* PHY layer */
+static int smsc911x_phy_reset(struct smsc911x_data *pdata);
+static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata);
+static int smsc911x_phy_initialise(struct smsc911x_data *pdata);
+static void smsc911x_phy_setlink(struct smsc911x_data *pdata);
+static unsigned int smsc911x_phy_read(struct smsc911x_data *pdata,
+				      unsigned int offset);
+
+static void smsc911x_phy_write(struct smsc911x_data *pdata,
+			       unsigned int offset, unsigned int value);
+
+static void smsc911x_phy_upd_lmode_fd(struct smsc911x_data *pdata,
+				      unsigned int, unsigned int);
+
+static void smsc911x_phy_update_linkmode(struct smsc911x_data *pdata);
+static void smsc911x_phy_getlinkmode(struct smsc911x_data *pdata);
+static void smsc911x_phy_checklink(unsigned long);
+static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata);
+static int smsc911x_phy_loopbacktest(struct smsc911x_data *pdata);
+
+/* Transmit */
+static void smsc911x_tx_initialise(struct smsc911x_data *pdata);
+static void smsc911x_tx_writefifo(struct smsc911x_data *pdata,
+				  unsigned int *bufp, unsigned int size);
+
+static inline unsigned int smsc911x_tx_get_txstatcount(struct smsc911x_data
+						       *pdata);
+static unsigned int smsc911x_tx_completetx(struct smsc911x_data *pdata);
+
+static inline int smsc911x_tx_handleirq(struct smsc911x_data *pdata,
+					unsigned int irqstatus);
+
+static void smsc911x_tx_update_txcounters(struct smsc911x_data *pdata);
+
+/* Receive */
+static void smsc911x_rx_initialise(struct smsc911x_data *pdata);
+static void smsc911x_rx_readfifo(struct smsc911x_data *pdata,
+				 unsigned int *bufp, unsigned int size);
+
+static void smsc911x_rx_handoffskb(struct smsc911x_data *pdata,
+				   struct sk_buff *skb);
+
+static unsigned int smsc911x_rx_pop_rxstatus(struct smsc911x_data *pdata);
+static void smsc911x_rx_counterrors(struct smsc911x_data *pdata,
+				    unsigned int rxstatus);
+
+static void smsc911x_rx_fastforward(struct smsc911x_data *pdata,
+				    unsigned int size);
+
+static void smsc911x_rx_processpackets(struct smsc911x_data *pdata);
+static int smsc911x_rx_handleirq(struct smsc911x_data *pdata,
+				 unsigned int intstat);
+
+static unsigned int smsc911x_hash(char addr[]);
+static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata);
+
+/* LAN initialisation */
+static int smsc911x_lan_initialise(struct smsc911x_data *pdata,
+				   unsigned int intcfg);
+
+/* Linux network device interface */
+static int smsc911x_init(struct net_device *dev);
+static int smsc911x_open(struct net_device *dev);
+static int smsc911x_stop(struct net_device *dev);
+static int smsc911x_hard_start_xmit(struct sk_buff *skb,
+				    struct net_device *dev);
+
+static struct net_device_stats *smsc911x_get_stats(struct net_device *dev);
+static void smsc911x_set_multicast_list(struct net_device *dev);
+static irqreturn_t smsc911x_irqhandler(int irq, void *dev_id,
+				       struct pt_regs *regs);
+
+/* Module interface */
+static int smsc911x_init_module(void);
+static void smsc911x_cleanup_module(void);
+
+/* Driver interface */
+static int smsc911x_drv_probe(struct platform_device *pdev);
+static int smsc911x_drv_remove(struct platform_device *pdev);
+
+/* Entry point for starting/opening the interface */
+static int smsc911x_open(struct net_device *dev)
+{
+	struct smsc911x_data *pdata;
+	unsigned int mac_high16;
+	unsigned int mac_low32;
+	unsigned int timeout;
+	unsigned int intcfg;
+	int result;
+
+	/* Set interrupt deassertion to 220uS */
+	intcfg = 22 << 24;
+	timeout = 1000;
+	result = -ENODEV;
+
+	pdata = netdev_priv(dev);
+
+	/* Initialise smsc911x */
+
+	/*
+	 * dwIntCfg|=INT_CFG_IRQ_POL_;  use this to set IRQ_POL bit
+	 * dwIntCfg|=INT_CFG_IRQ_TYPE_;  use this to set IRQ_TYPE bit
+	 */
+	if (!smsc911x_lan_initialise(pdata, intcfg))
+		goto done;
+
+	SMSC_TRACE("Testing irq handler using IRQ %d", dev->irq);
+	pdata->request_irq_disable = 0;
+	pdata->software_irq_signal = 0;
+	smsc911x_reg_write((smsc911x_reg_read(pdata, INT_EN) |
+			    INT_EN_SW_INT_EN_), pdata, INT_EN);
+	do {
+		udelay(10);
+		timeout--;
+	} while (timeout && (!pdata->software_irq_signal));
+
+	if (!pdata->software_irq_signal) {
+		printk("<1>ISR failed signaling test.");
+		result = -ENODEV;
+		goto done;
+	}
+	SMSC_TRACE("IRQ handler passed test using IRQ %d", dev->irq);
+
+	printk("%s: SMSC911x/921x identified at %#08x, IRQ: %d\n", dev->name,
+	       pdata->base, dev->irq);
+
+	/* Read mac address from EEPROM */
+	mac_high16 = smsc911x_mac_read(pdata, ADDRH);
+	mac_low32 = smsc911x_mac_read(pdata, ADDRL);
+
+	/* Generate random MAC address if eeprom values are invalid */
+	if ((mac_high16 == 0x0000FFFF) && (mac_low32 == 0xFFFFFFFF)) {
+		u8 random_mac[6];
+		random_ether_addr(random_mac);
+		mac_high16 = (random_mac[5] << 8) | random_mac[4];
+		mac_low32 = (random_mac[3] << 24) | (random_mac[2] << 16) |
+		    (random_mac[1] << 8) | random_mac[0];
+
+		smsc911x_mac_write(pdata, ADDRH, mac_high16);
+		smsc911x_mac_write(pdata, ADDRL, mac_low32);
+		SMSC_TRACE("MAC Address is set to random_ether_addr");
+	} else {
+		SMSC_TRACE("Mac Address is read from LAN911x EEPROM");
+	}
+
+	dev->dev_addr[0] = (u8)(mac_low32);
+	dev->dev_addr[1] = (u8)(mac_low32 >> 8);
+	dev->dev_addr[2] = (u8)(mac_low32 >> 16);
+	dev->dev_addr[3] = (u8)(mac_low32 >> 24);
+	dev->dev_addr[4] = (u8)(mac_high16);
+	dev->dev_addr[5] = (u8)(mac_high16 >> 8);
+	printk("%s: SMSC911x MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+	       dev->name, dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
+	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
+
+	netif_carrier_off(dev);
+	if (!smsc911x_phy_initialise(pdata)) {
+		SMSC_WARNING("Failed to initialize PHY");
+		result = -ENODEV;
+		goto done;
+	}
+
+	smsc911x_tx_initialise(pdata);
+	smsc911x_rx_initialise(pdata);
+	netif_start_queue(dev);
+
+	result = 0;
+
+done:
+	SMSC_TRACE("result: %d", result);
+	return result;
+}
+
+/* Entry point for stopping the interface */
+static int smsc911x_stop(struct net_device *dev)
+{
+	unsigned long flags;
+	unsigned long base;
+	unsigned long idrev;
+	struct smsc911x_data *pdata;
+	struct net_device *pnetdev;
+
+	pdata = netdev_priv(dev);
+
+	pdata->stop_link_poll = 1;
+	del_timer_sync(&pdata->link_poll_timer);
+
+	spin_lock_irqsave(&dev->_xmit_lock, flags);
+	smsc911x_reg_write((smsc911x_reg_read(pdata, INT_CFG) &
+			    (~INT_CFG_IRQ_EN_)), pdata, INT_CFG);
+	netif_stop_queue(pdata->dev);
+	spin_unlock_irqrestore(&dev->_xmit_lock, flags);
+
+	/* At this point all Rx and Tx activity is stopped */
+	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	smsc911x_tx_update_txcounters(pdata);
+
+	/* Preserve important fields */
+	base = pdata->base;
+	idrev = pdata->idrev;
+	pnetdev = pdata->dev;
+
+	/* Clear all structure */
+	memset((void *)pdata, 0, sizeof(struct smsc911x_data));
+
+	/* Reassign important fields */
+	pdata->base = base;
+	pdata->idrev = idrev;
+	pdata->dev = pnetdev;
+
+	SMSC_TRACE("<--Simp911x_stop");
+	return 0;
+}
+
+/* Entry point for transmitting a packet */
+static int smsc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct smsc911x_data *pdata;
+	unsigned int freespace;
+	unsigned int tx_cmd_a;
+	unsigned int tx_cmd_b;
+	unsigned int temp;
+	u32 wrsz;
+	u32 bufp;
+
+	pdata = netdev_priv(dev);
+
+	freespace = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TDFREE_;
+
+	if (unlikely(freespace < TX_FIFO_LOW_THRESHOLD))
+		SMSC_WARNING("Tx data fifo low, space available: %d",
+			     freespace);
+
+	/* Word alignment adjustment */
+	tx_cmd_a = ((((unsigned int)(skb->data)) & 0x03) << 16);
+	tx_cmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
+	tx_cmd_a |= (unsigned int)skb->len;
+
+	tx_cmd_b = ((unsigned int)skb->len) << 16;
+	tx_cmd_b |= (unsigned int)skb->len;
+
+	smsc911x_reg_write(tx_cmd_a, pdata, TX_DATA_FIFO);
+	smsc911x_reg_write(tx_cmd_b, pdata, TX_DATA_FIFO);
+
+	bufp = ((u32)skb->data) & 0xFFFFFFFC;
+	wrsz = (u32)skb->len + 3;
+	wrsz += ((u32)skb->data) & 0x3;
+	wrsz >>= 2;
+
+	smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+
+	freespace -= (skb->len + 32);
+	dev_kfree_skb(skb);
+
+	if (unlikely(smsc911x_tx_get_txstatcount(pdata) >= 30))
+		smsc911x_tx_update_txcounters(pdata);
+
+	if (freespace < TX_FIFO_LOW_THRESHOLD) {
+		netif_stop_queue(pdata->dev);
+		temp = smsc911x_reg_read(pdata, FIFO_INT);
+		temp &= 0x00FFFFFF;
+		temp |= 0x32000000;
+		smsc911x_reg_write(temp, pdata, FIFO_INT);
+	}
+
+	return 0;
+}
+
+/* Entry point for getting status counters */
+static struct net_device_stats *smsc911x_get_stats(struct net_device *dev)
+{
+	struct smsc911x_data *pdata;
+	pdata = netdev_priv(dev);
+	return &pdata->stats;
+}
+
+/* Entry point for setting addressing modes */
+static void smsc911x_set_multicast_list(struct net_device *dev)
+{
+	struct smsc911x_data *pdata;
+	unsigned long flags;
+
+	pdata = netdev_priv(dev);
+
+	spin_lock_irqsave(&pdata->phy_lock, flags);
+
+	if (dev->flags & IFF_PROMISC) {
+		/* Enabling promiscuous mode */
+		pdata->set_bits_mask = MAC_CR_PRMS_;
+		pdata->clear_bits_mask = (MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0;
+		pdata->hashlo = 0;
+		goto prepare;
+	}
+
+	if (dev->flags & IFF_ALLMULTI) {
+		/* Enabling all multicast mode */
+		pdata->set_bits_mask = MAC_CR_MCPAS_;
+		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0;
+		pdata->hashlo = 0;
+		goto prepare;
+	}
+	if (dev->mc_count > 0) {
+		/* Enabling specific multicast addresses */
+		unsigned int hash_high = 0;
+		unsigned int hash_low = 0;
+		unsigned int count = 0;
+		struct dev_mc_list *mc_list = dev->mc_list;
+
+		pdata->set_bits_mask = MAC_CR_HPFILT_;
+		pdata->clear_bits_mask = (MAC_CR_PRMS_ | MAC_CR_MCPAS_);
+
+		while (mc_list) {
+			count++;
+			if ((mc_list->dmi_addrlen) == 6) {
+				unsigned int mask = 0x01;
+				unsigned int bitnum;
+				bitnum = smsc911x_hash(mc_list->dmi_addr);
+				mask <<= (bitnum & 0x1F);
+				if (bitnum & 0x20) {
+					hash_high |= mask;
+				} else {
+					hash_low |= mask;
+				}
+			} else {
+				SMSC_WARNING("dmi_addrlen != 6");
+			}
+			mc_list = mc_list->next;
+		}
+		if (count != (unsigned int)dev->mc_count)
+			SMSC_WARNING("mc_count != dev->mc_count");
+
+		pdata->hashhi = hash_high;
+		pdata->hashlo = hash_low;
+	} else {
+		/* Enabling local MAC address only */
+		pdata->set_bits_mask = 0L;
+		pdata->clear_bits_mask =
+		    (MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+		pdata->hashhi = 0UL;
+		pdata->hashlo = 0UL;
+	}
+
+      prepare:
+
+	if (pdata->generation <= 1) {
+		if (pdata->multicast_update_pending == 0) {
+			pdata->multicast_update_pending = 1;
+
+			/* signal software interrupt */
+			pdata->request_irq_disable = 0;
+			pdata->software_irq_signal = 0;
+			smsc911x_reg_write((smsc911x_reg_read(pdata, INT_EN) |
+					    INT_EN_SW_INT_EN_), pdata, INT_EN);
+		} else {
+			/* Rx_CompleteMulticastUpdate has not yet been called
+			 * therefore these latest settings will be used instead */
+		}
+	} else {
+		/* Newer revision - can write immediately */
+		unsigned int mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+		mac_cr |= pdata->set_bits_mask;
+		mac_cr &= ~(pdata->clear_bits_mask);
+		smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+		smsc911x_mac_write(pdata, HASHH, pdata->hashhi);
+		smsc911x_mac_write(pdata, HASHL, pdata->hashlo);
+	}
+
+	spin_unlock_irqrestore(&pdata->phy_lock, flags);
+	return;
+}
+
+static irqreturn_t
+smsc911x_irqhandler(int irq, void *dev_id, struct pt_regs *regs)
+{
+	unsigned int intcfg;
+	unsigned int intsts;
+	int serviced;
+	unsigned int reserved_bits;
+	struct smsc911x_data *pdata;
+
+	intcfg = 0;
+	intsts = 0;
+	serviced = IRQ_NONE;
+	reserved_bits = 0x00FFCEEE;
+
+	pdata = (struct smsc911x_data *)dev_id;
+	BUG_ON(!pdata);
+
+	intcfg = smsc911x_reg_read(pdata, INT_CFG);
+
+	if (unlikely((intcfg & 0x00001100) != 0x00001100)) {
+		SMSC_TRACE("Spurious interrupt, intcfg: 0x%08X", intcfg);
+		goto done;
+	}
+
+	/* this could mean surprise removal */
+	if (unlikely(intcfg & reserved_bits)) {
+		SMSC_WARNING("SMSC911x irq handler, reserved bits are high.");
+		goto done;
+	}
+
+	intsts = smsc911x_reg_read(pdata, INT_STS);
+	if (unlikely(intsts & INT_STS_SW_INT_)) {
+		smsc911x_reg_write((smsc911x_reg_read(pdata, INT_EN)
+				    & (~INT_EN_SW_INT_EN_)), pdata, INT_EN);
+		smsc911x_reg_write(INT_STS_SW_INT_, pdata, INT_STS);
+		pdata->software_irq_signal = 1;
+		serviced = IRQ_HANDLED;
+		if (pdata->request_irq_disable) {
+			smsc911x_reg_write((smsc911x_reg_read(pdata, INT_CFG)
+					    & (~INT_CFG_IRQ_EN_)), pdata,
+					   INT_CFG);
+			/* Prevent irqs from being handled */
+			intsts = 0;
+		}
+		if (pdata->multicast_update_pending) {
+			smsc911x_rx_multicast_update(pdata);
+		}
+	}
+
+	if (smsc911x_tx_handleirq(pdata, intsts))
+		serviced = IRQ_HANDLED;
+
+	if (likely(smsc911x_rx_handleirq(pdata, intsts)))
+		serviced = IRQ_HANDLED;
+
+	if (unlikely(!serviced))
+		SMSC_WARNING("Unserviced irq. intcfg: 0x%08X, intsts: "
+			     "0x%08X, int_en: 0x%08X", intcfg, intsts,
+			     smsc911x_reg_read(pdata, INT_EN));
+      done:
+	return serviced;
+}
+
+/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 flavors.
+ * If something goes wrong, returns -ENODEV to revert back to internal phy. */
+static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)
+{
+	unsigned int address;
+	unsigned int hwcfg;
+	unsigned int phyid1;
+	unsigned int phyid2;
+
+	hwcfg = smsc911x_reg_read(pdata, HW_CFG);
+
+	/* External phy is requested, supported, and detected */
+	if (hwcfg & HW_CFG_EXT_PHY_DET_) {
+
+		/* Attempt to switch to external phy for auto-detecting
+		 * its address. Assuming tx and rx are stopped because
+		 * smsc911x_phy_initialise is called before
+		 * smsc911x_rx_initialise and tx_initialise.
+		 */
+
+		/* Disable phy clocks to the MAC */
+		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+		hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
+		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+		udelay(10);	/* Enough time for clocks to stop */
+
+		/* Switch to external phy */
+		hwcfg |= HW_CFG_EXT_PHY_EN_;
+		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+
+		/* Enable phy clocks to the MAC */
+		hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+		hwcfg |= HW_CFG_PHY_CLK_SEL_EXT_PHY_;
+		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+		udelay(10);	/* Enough time for clocks to restart */
+
+		hwcfg |= HW_CFG_SMI_SEL_;
+		smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+
+		/* As far as a single threaded initialisation of this driver
+		 * is concerned, there is no need to acquire phy_lock.
+		 */
+
+		/* Auto-detect PHY */
+		for (address = 0; address <= 31; address++) {
+			pdata->phy_address = address;
+			phyid1 = smsc911x_phy_read(pdata, PHY_ID_1);
+			phyid2 = smsc911x_phy_read(pdata, PHY_ID_2);
+			if ((phyid1 != 0xFFFFU) || (phyid2 != 0xFFFFU)) {
+				SMSC_TRACE("Detected PHY at address = "
+					   "0x%02X = %d", address, address);
+				break;
+			}
+		}
+
+		if ((phyid1 == 0xFFFFU) && (phyid2 == 0xFFFFU)) {
+			SMSC_WARNING("External PHY is not accessable, "
+				     "using internal PHY instead");
+			/* Revert back to interal phy settings. */
+
+			/* Disable phy clocks to the MAC */
+			hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+			hwcfg |= HW_CFG_PHY_CLK_SEL_CLK_DIS_;
+			smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+			udelay(10);	/* Enough time for clocks to stop */
+
+			/* Switch to internal phy */
+			hwcfg &= (~HW_CFG_EXT_PHY_EN_);
+			smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+
+			/* Enable phy clocks to the MAC */
+			hwcfg &= (~HW_CFG_PHY_CLK_SEL_);
+			hwcfg |= HW_CFG_PHY_CLK_SEL_INT_PHY_;
+			smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+			udelay(10);	/* Enough time for clocks to restart */
+
+			hwcfg &= (~HW_CFG_SMI_SEL_);
+			smsc911x_reg_write(hwcfg, pdata, HW_CFG);
+			/* Use internal phy */
+			return -ENODEV;
+		} else {
+			SMSC_TRACE("Successfully switched to external PHY");
+#ifdef USE_LED1_WORK_AROUND
+			pdata->not_using_extphy = 0;
+#endif
+		}
+	} else {
+		SMSC_WARNING("No external PHY detected.");
+		SMSC_WARNING("Using internal PHY instead.");
+		/* Use internal phy */
+		return -ENODEV;
+	}
+	return 0;
+}
+
+/* Initialises the PHY layer */
+static int smsc911x_phy_initialise(struct smsc911x_data *pdata)
+{
+	int result = 0;
+	unsigned int phyid1 = 0;
+	unsigned int phyid2 = 0;
+
+#ifndef USE_PHY_WORK_AROUND
+	unsigned int temp = 0;
+	unsigned int loopcount = 0;
+#endif
+
+	switch (pdata->idrev & 0xFFFF0000) {
+	case 0x01170000:
+	case 0x01150000:
+		if (smsc911x_phy_initialise_external(pdata) < 0)
+			goto use_internal_phy;
+		break;
+	default:
+		SMSC_TRACE("External PHY is not supported");
+		SMSC_TRACE("Using internal PHY instead");
+		goto use_internal_phy;
+	}
+      use_internal_phy:
+	pdata->phy_address = 1;
+#ifdef USE_LED1_WORK_AROUND
+	pdata->not_using_extphy = 1;
+#endif
+
+	/* Single threaded initialisation so no need to grab phy_lock. */
+	phyid1 = smsc911x_phy_read(pdata, PHY_ID_1);
+	phyid2 = smsc911x_phy_read(pdata, PHY_ID_2);
+
+	if ((phyid1 == 0xFFFF) && (phyid2 == 0xFFFF)) {
+		SMSC_WARNING("Internal PHY not detected!");
+		goto done;
+	}
+
+	pdata->link_speed = LINK_OFF;
+	pdata->link_settings = LINK_OFF;
+
+	/* Reset the phy */
+#ifdef USE_PHY_WORK_AROUND
+	smsc911x_phy_reset(pdata);
+	if (!smsc911x_phy_loopbacktest(pdata)) {
+		SMSC_WARNING("Failed Loop Back Test");
+		goto done;
+	} else {
+		SMSC_TRACE("Passed Loop Back Test");
+	}
+#else
+	smsc911x_phy_write(pdata, PHY_BCR, PHY_BCR_RESET_);
+	loopcount = 100000;
+	do {
+		udelay(10);
+		temp = smsc911x_phy_read(pdata, PHY_BCR);
+		loopcount--;
+	} while ((loopcount > 0) && (temp & PHY_BCR_RESET_));
+	if (temp & PHY_BCR_RESET_) {
+		SMSC_WARNING("PHY reset failed to complete.");
+		goto done;
+	}
+#endif				/* not USE_PHY_WORK_AROUND */
+
+	smsc911x_phy_setlink(pdata);
+	init_timer(&pdata->link_poll_timer);
+	pdata->link_poll_timer.function = smsc911x_phy_checklink;
+	pdata->link_poll_timer.data = (unsigned long)pdata;
+	pdata->link_poll_timer.expires = jiffies + HZ;
+	add_timer(&pdata->link_poll_timer);
+	result = 1;
+      done:
+	SMSC_TRACE("smsc911x_phy_initialise, result: %s", result ?
+		   "SUCCESS" : "FAILURE");
+	return result;
+}
+
+#ifdef USE_PHY_WORK_AROUND
+static int smsc911x_phy_reset(struct smsc911x_data *pdata)
+{
+	int result = 0;
+	unsigned int temp = 0;
+	unsigned int lcount = 100000;
+
+	SMSC_TRACE("Performing PHY BCR Reset");
+	smsc911x_phy_write(pdata, PHY_BCR, PHY_BCR_RESET_);
+	do {
+		udelay(10);
+		temp = smsc911x_phy_read(pdata, PHY_BCR);
+		lcount--;
+	} while ((lcount > 0) && (temp & PHY_BCR_RESET_));
+
+	if (temp & PHY_BCR_RESET_) {
+		SMSC_WARNING("PHY reset failed to complete.");
+		goto done;
+	}
+	/* Extra delay required because the phy may not be completed with
+	 * its reset when PHY_BCR_RESET_ is cleared. Specs say 256 uS is
+	 * enough delay but using 500 here to be safe
+	 */
+	udelay(500);
+	result = 1;
+      done:
+	return result;
+}
+
+static unsigned int smsc911x_phy_lbt_gettxstatus(struct smsc911x_data *pdata)
+{
+	unsigned int result =
+	    (smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TSUSED_);
+
+	if (result != 0) {
+		/* Tx status is available, read it */
+		result = smsc911x_reg_read(pdata, TX_STATUS_FIFO);
+	}
+
+	return result;
+}
+
+static unsigned int smsc911x_phy_lbt_getrxstatus(struct smsc911x_data *pdata)
+{
+	unsigned int result =
+	    (smsc911x_reg_read(pdata, RX_FIFO_INF) & RX_FIFO_INF_RXSUSED_);
+
+	if (result != 0) {
+		/* Rx status is available, read it */
+		result = smsc911x_reg_read(pdata, RX_STATUS_FIFO);
+	}
+
+	return result;
+}
+
+static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
+{
+	int result = 0;
+	unsigned int tries = 0;
+	unsigned int lcount = 0;
+	u32 wrsz;
+	u32 rdsz;
+	u32 bufp;
+
+	for (tries = 0; tries < 10; tries++) {
+		unsigned int txcmd_a = 0;
+		unsigned int txcmd_b = 0;
+		unsigned int status = 0;
+		unsigned int pktlength = 0;
+
+		/* Zero-out rx packet memory */
+		memset(pdata->loopback_rx_pkt, 0, MIN_PACKET_SIZE);
+
+		/* Write tx packet to 118 */
+		txcmd_a = (((unsigned int)pdata->loopback_tx_pkt)
+			   & 0x03) << 16;
+		txcmd_a |= TX_CMD_A_FIRST_SEG_ | TX_CMD_A_LAST_SEG_;
+		txcmd_a |= MIN_PACKET_SIZE;
+
+		txcmd_b = MIN_PACKET_SIZE << 16 | MIN_PACKET_SIZE;
+
+		smsc911x_reg_write(txcmd_a, pdata, TX_DATA_FIFO);
+		smsc911x_reg_write(txcmd_b, pdata, TX_DATA_FIFO);
+
+		bufp = ((u32) pdata->loopback_tx_pkt) & 0xFFFFFFFC;
+		wrsz = MIN_PACKET_SIZE + 3;
+		wrsz += (((u32) pdata->loopback_tx_pkt) & 0x3);
+		wrsz >>= 2;
+
+		smsc911x_tx_writefifo(pdata, (unsigned int *)bufp, wrsz);
+
+		/* Wait till transmit is done */
+		lcount = 60;
+		do {
+			udelay(5);
+			lcount--;
+			status = smsc911x_phy_lbt_gettxstatus(pdata);
+		} while ((lcount > 0) && (status == 0));
+
+		if (status == 0) {
+			SMSC_WARNING("Failed to transmit during "
+				     "loopback test");
+			continue;
+		}
+		if (status & 0x00008000) {
+			SMSC_WARNING("Transmit encountered errors "
+				     "during loopback test");
+			continue;
+		}
+
+		/* Wait till receive is done */
+		lcount = 60;
+		do {
+			udelay(5);
+			lcount--;
+			status = smsc911x_phy_lbt_getrxstatus(pdata);
+		} while ((lcount > 0) && (status == 0));
+
+		if (status == 0) {
+			SMSC_WARNING("Failed to receive during "
+				     "loopback test");
+			continue;
+		}
+		if (status & RX_STS_ES_) {
+			SMSC_WARNING("Receive encountered errors "
+				     "during loopback test");
+			continue;
+		}
+
+		pktlength = ((status & 0x3FFF0000UL) >> 16);
+
+		bufp = (u32)pdata->loopback_rx_pkt;
+		rdsz = pktlength + 3;
+		rdsz += ((u32)pdata->loopback_rx_pkt) & 0x3;
+		rdsz >>= 2;
+
+		smsc911x_rx_readfifo(pdata, (unsigned int *)bufp, rdsz);
+
+		if (pktlength != (MIN_PACKET_SIZE + 4)) {
+			SMSC_WARNING("Unexpected packet size during "
+				     "loop back test, size=%d, "
+				     "will retry", pktlength);
+		} else {
+			unsigned int index = 0;
+			int mismatch = 0;
+			for (index = 0; index < MIN_PACKET_SIZE; index++) {
+				if (pdata->loopback_tx_pkt[index]
+				    != pdata->loopback_rx_pkt[index]) {
+					mismatch = 1;
+					break;
+				}
+			}
+			if (!mismatch) {
+				SMSC_TRACE("Successfully verified "
+					   "loopback packet");
+				result = 1;
+				goto done;
+			} else {
+				SMSC_WARNING("Data miss match during "
+					     "loop back test, will retry.");
+			}
+		}
+	}
+      done:
+	return result;
+}
+
+static int smsc911x_phy_loopbacktest(struct smsc911x_data *pdata)
+{
+	int result = 0;
+	unsigned int index = 0;
+	unsigned int tries = 0;
+	unsigned int val;
+
+	/* Initialise tx packet */
+	for (index = 0; index < 6; index++) {
+		/* Use broadcast destination address */
+		pdata->loopback_tx_pkt[index] = (char)0xFF;
+	}
+
+	for (index = 6; index < 12; index++) {
+		/* Use incrementing source address */
+		pdata->loopback_tx_pkt[index] = (char)index;
+	}
+
+	/* Set length type field */
+	pdata->loopback_tx_pkt[12] = 0x00;
+	pdata->loopback_tx_pkt[13] = 0x00;
+	for (index = 14; index < MIN_PACKET_SIZE; index++) {
+		pdata->loopback_tx_pkt[index] = (char)index;
+	}
+
+	val = smsc911x_reg_read(pdata, HW_CFG);
+	val &= HW_CFG_TX_FIF_SZ_;
+	val |= HW_CFG_SF_;
+	smsc911x_reg_write(val, pdata, HW_CFG);
+
+	smsc911x_reg_write(TX_CFG_TX_ON_, pdata, TX_CFG);
+	smsc911x_reg_write((((unsigned int)pdata->loopback_rx_pkt)
+			    & 0x03) << 8, pdata, RX_CFG);
+
+	/* Set PHY to 10/FD, no ANEG, */
+	smsc911x_phy_write(pdata, PHY_BCR, 0x0100);
+
+	/* Enable MAC tx/rx, FD */
+	smsc911x_mac_write(pdata, MAC_CR, MAC_CR_FDPX_
+			   | MAC_CR_TXEN_ | MAC_CR_RXEN_);
+
+	/* Set PHY to loopback mode */
+	smsc911x_phy_write(pdata, PHY_BCR, 0x4100);
+
+	for (tries = 0; tries < 10; tries++) {
+		if (smsc911x_phy_check_loopbackpkt(pdata)) {
+			result = 1;
+			goto done;
+		}
+		pdata->resetcount++;
+		/* Disable MAC rx */
+		smsc911x_mac_write(pdata, MAC_CR, 0);
+		smsc911x_phy_reset(pdata);
+
+		/* Set PHY to 10/FD, no ANEG, and loopback mode */
+		smsc911x_phy_write(pdata, PHY_BCR, 0x4100);
+
+		/* Enable MAC tx/rx, FD */
+		smsc911x_mac_write(pdata, MAC_CR, MAC_CR_FDPX_
+				   | MAC_CR_TXEN_ | MAC_CR_RXEN_);
+	}
+      done:
+	/* Disable MAC */
+	smsc911x_mac_write(pdata, MAC_CR, 0);
+
+	/* Cancel PHY loopback mode */
+	smsc911x_phy_write(pdata, PHY_BCR, 0);
+
+	smsc911x_reg_write(0, pdata, TX_CFG);
+	smsc911x_reg_write(0, pdata, RX_CFG);
+
+	return result;
+}
+#endif				/* USE_PHY_WORK_AROUND */
+
+/* Sets the link mode */
+static void smsc911x_phy_setlink(struct smsc911x_data *pdata)
+{
+	unsigned int temp;
+
+	/* Because this is part of the single threaded initialization
+	 * path there is no need to acquire the phy_lock
+	 */
+	temp = smsc911x_phy_read(pdata, PHY_ANEG_ADV);
+
+	/* Advertise all speeds and pause capabilities */
+	temp |= (PHY_ANEG_ADV_PAUSE_ | PHY_ANEG_ADV_SPEED_);
+	smsc911x_phy_write(pdata, PHY_ANEG_ADV, temp);
+
+	/* begin to establish link */
+	smsc911x_phy_write(pdata, PHY_BCR, PHY_BCR_AUTO_NEG_ENABLE_ |
+			   PHY_BCR_RESTART_AUTO_NEG_);
+	return;
+}
+
+/* NOTE: Assuming phy_lock has already been acquired.
+ * Gets the current link mode
+ */
+static void smsc911x_phy_getlinkmode(struct smsc911x_data *pdata)
+{
+	unsigned int result = LINK_OFF;
+	unsigned int phy_reg = 0;
+	unsigned int phy_bsr = 0;
+
+	phy_bsr = smsc911x_phy_read(pdata, PHY_BSR);
+
+	pdata->link_settings = LINK_OFF;
+	if (phy_bsr & PHY_BSR_LINK_STATUS_) {
+		phy_reg = smsc911x_phy_read(pdata, PHY_BCR);
+		if (phy_reg & PHY_BCR_AUTO_NEG_ENABLE_) {
+			unsigned int linksettings = LINK_AUTO_NEGOTIATE;
+			unsigned int phy_adv =
+			    smsc911x_phy_read(pdata, PHY_ANEG_ADV);
+			unsigned int phy_lpa =
+			    smsc911x_phy_read(pdata, PHY_ANEG_LPA);
+			if (phy_adv & PHY_ANEG_ADV_ASYMP_)
+				linksettings |= LINK_ASYMMETRIC_PAUSE;
+			if (phy_adv & PHY_ANEG_ADV_SYMP_)
+				linksettings |= LINK_SYMMETRIC_PAUSE;
+			if (phy_adv & PHY_ANEG_LPA_100FDX_)
+				linksettings |= LINK_SPEED_100FD;
+			if (phy_adv & PHY_ANEG_LPA_100HDX_)
+				linksettings |= LINK_SPEED_100HD;
+			if (phy_adv & PHY_ANEG_LPA_10FDX_)
+				linksettings |= LINK_SPEED_10FD;
+			if (phy_adv & PHY_ANEG_LPA_10HDX_)
+				linksettings |= LINK_SPEED_10HD;
+
+			pdata->link_settings = linksettings;
+			phy_lpa &= phy_adv;
+
+			if (phy_lpa & PHY_ANEG_LPA_100FDX_)
+				result = LINK_SPEED_100FD;
+			else if (phy_lpa & PHY_ANEG_LPA_100HDX_)
+				result = LINK_SPEED_100HD;
+			else if (phy_lpa & PHY_ANEG_LPA_10FDX_)
+				result = LINK_SPEED_10FD;
+			else if (phy_lpa & PHY_ANEG_LPA_10HDX_)
+				result = LINK_SPEED_10HD;
+		} else {
+			if (phy_reg & PHY_BCR_SPEED_SELECT_) {
+				if (phy_reg & PHY_BCR_DUPLEX_MODE_) {
+					result = LINK_SPEED_100FD;
+					pdata->link_settings = result;
+				} else {
+					result = LINK_SPEED_100HD;
+					pdata->link_settings = result;
+				}
+			} else {
+				if (phy_reg & PHY_BCR_DUPLEX_MODE_) {
+					result = LINK_SPEED_10FD;
+					pdata->link_settings = result;
+				} else {
+					result = LINK_SPEED_10HD;
+					pdata->link_settings = result;
+				}
+			}
+		}
+	}
+	pdata->link_speed = result;
+	return;
+}
+
+/* Updates link mode full-duplex */
+static void
+smsc911x_phy_upd_lmode_fd(struct smsc911x_data *pdata,
+			  unsigned int locallink, unsigned int linkpartner)
+{
+	unsigned int temp;
+
+	if (((locallink & linkpartner) & 0x0400) != 0) {
+		/* Enable PAUSE receive and transmit */
+		smsc911x_mac_write(pdata, FLOW, 0xFFFF0002);
+		temp = smsc911x_reg_read(pdata, AFC_CFG);
+		temp |= 0xF;
+		smsc911x_reg_write(temp, pdata, AFC_CFG);
+
+	} else if (((locallink & 0x0C00) == 0x0C00) &&
+		   ((linkpartner & 0x0C00) == 0x0800)) {
+		/* Enable PAUSE receive, disable PAUSE transmit */
+		smsc911x_mac_write(pdata, FLOW, 0xFFFF0002);
+		temp = smsc911x_reg_read(pdata, AFC_CFG);
+		temp &= ~0xF;
+		smsc911x_reg_write(temp, pdata, AFC_CFG);
+
+	} else {
+		/* Disable PAUSE receive and transmit */
+		smsc911x_mac_write(pdata, FLOW, 0);
+		temp = smsc911x_reg_read(pdata, AFC_CFG);
+		temp &= ~0xF;
+		smsc911x_reg_write(temp, pdata, AFC_CFG);
+	}
+	return;
+}
+
+static void smsc911x_phy_print_linkmode(unsigned int locallink,
+					unsigned int linkpartner)
+{
+	SMSC_TRACE("LAN911x: %s,%s,%s,%s,%s,%s",
+		   (locallink & PHY_ANEG_ADV_ASYMP_) ? "ASYMP" : "     ",
+		   (locallink & PHY_ANEG_ADV_SYMP_) ? "SYMP " : "     ",
+		   (locallink & PHY_ANEG_ADV_100F_) ? "100FD" : "     ",
+		   (locallink & PHY_ANEG_ADV_100H_) ? "100HD" : "     ",
+		   (locallink & PHY_ANEG_ADV_10F_) ? "10FD " : "     ",
+		   (locallink & PHY_ANEG_ADV_10H_) ? "10HD " : "     ");
+
+	SMSC_TRACE("Partner: %s,%s,%s,%s,%s,%s",
+		   (linkpartner & PHY_ANEG_LPA_ASYMP_) ? "ASYMP" : "     ",
+		   (linkpartner & PHY_ANEG_LPA_SYMP_) ? "SYMP " : "     ",
+		   (linkpartner & PHY_ANEG_LPA_100FDX_) ? "100FD" : "     ",
+		   (linkpartner & PHY_ANEG_LPA_100HDX_) ? "100HD" : "     ",
+		   (linkpartner & PHY_ANEG_LPA_10FDX_) ? "10FD " : "     ",
+		   (linkpartner & PHY_ANEG_LPA_10HDX_) ? "10HD " : "     ");
+	return;
+}
+
+/* Update link mode if any thing has changed */
+static void smsc911x_phy_update_linkmode(struct smsc911x_data *pdata)
+{
+	unsigned int old_link_speed = pdata->link_speed;
+	unsigned int temp;
+
+	spin_lock(&pdata->phy_lock);
+	smsc911x_phy_getlinkmode(pdata);
+
+	if (old_link_speed != pdata->link_speed) {
+		if (pdata->link_speed != LINK_OFF) {
+			unsigned int phy_reg = 0;
+			switch (pdata->link_speed) {
+			case LINK_SPEED_10HD:
+				SMSC_TRACE("Link is now UP at 10Mbps HD");
+				break;
+			case LINK_SPEED_10FD:
+				SMSC_TRACE("Link is now UP at 10Mbps FD");
+				break;
+			case LINK_SPEED_100HD:
+				SMSC_TRACE("Link is now UP at 100Mbps HD");
+				break;
+			case LINK_SPEED_100FD:
+				SMSC_TRACE("Link is now UP at 100Mbps FD");
+				break;
+			default:
+				SMSC_WARNING("Link is now UP at unknown link "
+					     "speed: 0x%08X",
+					     pdata->link_speed);
+				break;
+			}
+			phy_reg = smsc911x_mac_read(pdata, MAC_CR);
+			phy_reg &= ~(MAC_CR_FDPX_ | MAC_CR_RCVOWN_);
+
+			switch (pdata->link_speed) {
+			case LINK_SPEED_10HD:
+			case LINK_SPEED_100HD:
+				phy_reg |= MAC_CR_RCVOWN_;
+				break;
+
+			case LINK_SPEED_10FD:
+			case LINK_SPEED_100FD:
+				phy_reg |= MAC_CR_FDPX_;
+				break;
+
+			default:
+				SMSC_WARNING("Unknown link speed: 0x%08X",
+					     pdata->link_speed);
+				break;
+			}
+
+			smsc911x_mac_write(pdata, MAC_CR, phy_reg);
+
+			if (pdata->link_settings & LINK_AUTO_NEGOTIATE) {
+				unsigned int linkpartner = 0;
+				unsigned int locallink = 0;
+				locallink = smsc911x_phy_read(pdata, 4);
+				linkpartner = smsc911x_phy_read(pdata, 5);
+				switch (pdata->link_speed) {
+				case LINK_SPEED_10FD:
+				case LINK_SPEED_100FD:
+					smsc911x_phy_upd_lmode_fd(pdata,
+								  locallink,
+								  linkpartner);
+					break;
+
+				case LINK_SPEED_10HD:
+				case LINK_SPEED_100HD:
+					smsc911x_mac_write(pdata, FLOW, 0);
+					temp =
+					    smsc911x_reg_read(pdata, AFC_CFG);
+					temp |= 0xF;
+					smsc911x_reg_write(temp, pdata,
+							   AFC_CFG);
+					break;
+
+				default:
+					SMSC_WARNING("Unknown link speed: "
+						     "0x%08X\n",
+						     pdata->link_speed);
+					break;
+				}
+				smsc911x_phy_print_linkmode(locallink,
+							    linkpartner);
+			} else {
+				switch (pdata->link_speed) {
+				case LINK_SPEED_10HD:
+				case LINK_SPEED_100HD:
+					smsc911x_mac_write(pdata, FLOW, 0);
+					smsc911x_reg_write(0x0000000F,
+							   pdata, AFC_CFG);
+					break;
+				default:
+					smsc911x_mac_write(pdata, FLOW, 0);
+					temp =
+					    smsc911x_reg_read(pdata, AFC_CFG);
+					temp &= ~0xF;
+					smsc911x_reg_write(temp, pdata,
+							   AFC_CFG);
+					break;
+				}
+			}
+			netif_carrier_on(pdata->dev);
+#ifdef USE_LED1_WORK_AROUND
+			if ((pdata->gpio_orig_setting & GPIO_CFG_LED1_EN_) &&
+			    pdata->not_using_extphy) {
+				/* Restore orginal GPIO configuration */
+				pdata->gpio_setting = pdata->gpio_orig_setting;
+				smsc911x_reg_write(pdata->gpio_setting, pdata,
+						   GPIO_CFG);
+			}
+#endif				/* USE_LED1_WORK_AROUND */
+		} else {
+			SMSC_TRACE("Link is now down");
+			netif_carrier_off(pdata->dev);
+			smsc911x_mac_write(pdata, FLOW, 0);
+
+			temp = smsc911x_reg_read(pdata, AFC_CFG);
+			temp &= ~0xF;
+			smsc911x_reg_write(temp, pdata, AFC_CFG);
+
+#ifdef USE_LED1_WORK_AROUND
+			/* Check global setting that LED1
+			 * usage is 10/100 indicator */
+			pdata->gpio_setting =
+			    smsc911x_reg_read(pdata, GPIO_CFG);
+			if ((pdata->gpio_setting & GPIO_CFG_LED1_EN_)
+			    && pdata->not_using_extphy) {
+				/* Force 10/100 LED off, after saving
+				 * orginal GPIO configuration */
+				pdata->gpio_orig_setting = pdata->gpio_setting;
+
+				pdata->gpio_setting &= ~GPIO_CFG_LED1_EN_;
+				pdata->gpio_setting |= (GPIO_CFG_GPIOBUF0_
+							| GPIO_CFG_GPIODIR0_
+							| GPIO_CFG_GPIOD0_);
+				smsc911x_reg_write(pdata->gpio_setting, pdata,
+						   GPIO_CFG);
+			}
+#endif				/* USE_LED1_WORK_AROUND */
+		}
+	}
+	spin_unlock(&pdata->phy_lock);
+	return;
+}
+
+/* Gets a phy register */
+static unsigned int
+smsc911x_phy_read(struct smsc911x_data *pdata, unsigned int index)
+{
+	unsigned int addr = 0;
+	unsigned int result = 0xFFFF;
+	int i;
+
+	/* Confirm MII not busy */
+	if (unlikely
+	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {
+		SMSC_WARNING("MII is busy in smsc911x_phy_read???");
+		result = 0;
+		goto done;
+	}
+
+	/* Set the address, index & direction (read from PHY) */
+	addr = (((pdata->phy_address) & 0x1F) << 11)
+	    | ((index & 0x1F) << 6);
+	smsc911x_mac_write(pdata, MII_ACC, addr);
+
+	/* Wait for read to complete w/ timeout */
+	for (i = 0; i < 100; i++) {
+		/* See if MII is finished yet */
+		if ((smsc911x_mac_read(pdata, MII_ACC)
+		     & MII_ACC_MII_BUSY_) == 0) {
+			result = (unsigned int)smsc911x_mac_read(pdata,
+								 MII_DATA);
+			goto done;
+		}
+	}
+	SMSC_WARNING("Timed out waiting for MII write to finish");
+
+      done:
+	return result;
+}
+
+/* Sets a phy register */
+static void smsc911x_phy_write(struct smsc911x_data *pdata,
+			       unsigned int index, unsigned int val)
+{
+	unsigned int addr = 0;
+	int i = 0;
+
+	/* Confirm MII not busy */
+	if (unlikely
+	    ((smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_) != 0)) {
+		SMSC_WARNING("MII is busy in smsc911x_write_phy???");
+		goto done;
+	}
+
+	/* Put the data to write in the MAC */
+	smsc911x_mac_write(pdata, MII_DATA, val);
+
+	/* Set the address, index & direction (write to PHY) */
+	addr = (((pdata->phy_address) & 0x1F) << 11) |
+		((index & 0x1F) << 6) | MII_ACC_MII_WRITE_;
+	smsc911x_mac_write(pdata, MII_ACC, addr);
+
+	/* Wait for write to complete w/ timeout */
+	for (i = 0; i < 100; i++) {
+		/* See if MII is finished yet */
+		if ((smsc911x_mac_read(pdata, MII_ACC)
+		     & MII_ACC_MII_BUSY_) == 0)
+			goto done;
+	}
+	SMSC_WARNING("Timed out waiting for MII write to finish");
+      done:
+	return;
+}
+
+/* Entry point for the link poller */
+static void smsc911x_phy_checklink(unsigned long ptr)
+{
+	struct smsc911x_data *pdata;
+	pdata = (struct smsc911x_data *)ptr;
+
+	/* Must call this twice */
+	smsc911x_phy_update_linkmode(pdata);
+	smsc911x_phy_update_linkmode(pdata);
+
+	if (!(pdata->stop_link_poll)) {
+		pdata->link_poll_timer.expires = jiffies + HZ;
+		add_timer(&(pdata->link_poll_timer));
+	}
+	return;
+}
+
+/* Polls for not busy for a limited time */
+static int smsc911x_mac_notbusy(struct smsc911x_data *pdata)
+{
+	int i = 0;
+	/* Assuming MacPhyAccessLock has already been acquired */
+
+	/* wait for MAC not busy, w/ timeout */
+	for (i = 0; i < 40; i++) {
+		if ((smsc911x_reg_read(pdata, MAC_CSR_CMD)
+		     & MAC_CSR_CMD_CSR_BUSY_) == 0) {
+			return 1;
+		}
+	}
+	SMSC_WARNING("Timed out waiting for MAC not BUSY. "
+		     "MAC_CSR_CMD: 0x%08X", smsc911x_reg_read(pdata,
+							      MAC_CSR_CMD));
+	return 0;
+}
+
+/* Fetches a MAC register value. Assumes phy_lock is acquired */
+static unsigned int
+smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
+{
+	unsigned int result = 0xFFFFFFFF;
+	volatile unsigned int temp = 0;
+
+	/* Wait until not busy */
+	if (unlikely
+	    (smsc911x_reg_read(pdata, MAC_CSR_CMD) & MAC_CSR_CMD_CSR_BUSY_)) {
+		SMSC_WARNING("smsc911x_mac_read failed, "
+			     "MAC already busy at entry");
+		goto done;
+	}
+
+	/* Send the MAC cmd */
+	smsc911x_reg_write(((offset & 0x000000FF) | MAC_CSR_CMD_CSR_BUSY_
+			    | MAC_CSR_CMD_R_NOT_W_), pdata, MAC_CSR_CMD);
+
+	temp = smsc911x_reg_read(pdata, BYTE_TEST);	/* To flush previous write */
+
+	/* Wait for the read to happen */
+	if (unlikely(!smsc911x_mac_notbusy(pdata))) {
+		SMSC_WARNING("smsc911x_mac_read failed, "
+			     "waiting for MAC not busy after read");
+		goto done;
+	} else {
+		/* Read the data */
+		result = smsc911x_reg_read(pdata, MAC_CSR_DATA);
+	}
+      done:
+	return result;
+}
+
+/* Set a mac register, phy_lock must be acquired before calling. */
+static void smsc911x_mac_write(struct smsc911x_data *pdata,
+			       unsigned int offset, unsigned int val)
+{
+	volatile unsigned int temp = 0;
+
+	if (unlikely
+	    (smsc911x_reg_read(pdata, MAC_CSR_CMD) & MAC_CSR_CMD_CSR_BUSY_)) {
+		SMSC_WARNING("smsc911x_mac_write failed, "
+			     "MAC already busy at entry");
+		goto done;
+	}
+
+	/* Send data to write */
+	smsc911x_reg_write(val, pdata, MAC_CSR_DATA);
+
+	/* Write the actual data */
+	smsc911x_reg_write(((offset & 0x000000FF) | MAC_CSR_CMD_CSR_BUSY_),
+			   pdata, MAC_CSR_CMD);
+	/* Force flush of previous write */
+	temp = smsc911x_reg_read(pdata, BYTE_TEST);
+
+	/* Wait for the write to complete */
+	if (unlikely(!smsc911x_mac_notbusy(pdata))) {
+		SMSC_WARNING("smsc911x_mac_write failed, "
+			     "waiting for MAC not busy after write");
+	}
+
+      done:
+	return;
+}
+
+/* Initialise the transmitter, it is called during driver
+ * initialisation, thus no need to acquire phy_lock */
+static void smsc911x_tx_initialise(struct smsc911x_data *pdata)
+{
+	unsigned int mac_cr;
+	unsigned int hw_cfg = 0;
+
+	hw_cfg = smsc911x_reg_read(pdata, HW_CFG);
+	hw_cfg &= HW_CFG_TX_FIF_SZ_;
+	hw_cfg |= HW_CFG_SF_;
+	smsc911x_reg_write(hw_cfg, pdata, HW_CFG);
+
+	smsc911x_reg_write(smsc911x_reg_read(pdata, FIFO_INT) | 0xFF000000,
+			   pdata, FIFO_INT);
+	smsc911x_reg_write(smsc911x_reg_read(pdata, INT_EN) | INT_EN_TDFA_EN_,
+			   pdata, INT_EN);
+
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= (MAC_CR_TXEN_ | MAC_CR_HBDIS_);
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+	smsc911x_reg_write(TX_CFG_TX_ON_, pdata, TX_CFG);
+	return;
+}
+
+/* Reenables the transmitter */
+static inline int
+smsc911x_tx_handleirq(struct smsc911x_data *pdata, unsigned int intsts)
+{
+	if (intsts & INT_STS_TDFA_) {
+		smsc911x_reg_write(smsc911x_reg_read(pdata, FIFO_INT) |
+				   0xFF000000, pdata, FIFO_INT);
+		smsc911x_reg_write(INT_STS_TDFA_, pdata, INT_STS);
+		netif_wake_queue(pdata->dev);
+		return 1;
+	}
+	return 0;
+}
+
+/* Writes a packet to the TX_DATA_FIFO */
+static void
+smsc911x_tx_writefifo(struct smsc911x_data *pdata, unsigned int *buf,
+		      unsigned int wordcount)
+{
+	while (wordcount) {
+		smsc911x_reg_write(*buf++, pdata, TX_DATA_FIFO);
+		wordcount--;
+	}
+}
+
+/* Gets the number of tx statuses in the fifo */
+static inline unsigned int smsc911x_tx_get_txstatcount(struct smsc911x_data
+						       *pdata)
+{
+	unsigned int result;
+	result = (smsc911x_reg_read(pdata, TX_FIFO_INF)
+		  & TX_FIFO_INF_TSUSED_) >> 16;
+	return result;
+}
+
+/* Fetches a tx status out of the status fifo */
+static unsigned int smsc911x_tx_completetx(struct smsc911x_data *pdata)
+{
+	unsigned int result;
+
+	result = smsc911x_reg_read(pdata, TX_FIFO_INF) & TX_FIFO_INF_TSUSED_;
+
+	if (result != 0)
+		result = smsc911x_reg_read(pdata, TX_STATUS_FIFO);
+
+	return result;
+}
+
+/* Reads tx statuses and increments counters where necessary */
+static void smsc911x_tx_update_txcounters(struct smsc911x_data *pdata)
+{
+	unsigned int tx_stat;
+
+	while ((tx_stat = smsc911x_tx_completetx(pdata)) != 0) {
+		if (unlikely(tx_stat & 0x80000000)) {
+			/* In this driver the packet tag is used as the packet length.
+			 * Since a packet length can never reach the size of 0x8000,
+			 * this bit is reserved so that if packet tracking tags were
+			 * ever used, then those tracking tags would set the reserved bit.
+			 * Accordingly, this control path would be used to look up the
+			 * packet and perhaps free it. It is worth noting that the
+			 * "reserved bit" in the warning above does not reference a
+			 * hardware defined reserved bit but rather a driver defined one.
+			 */
+			SMSC_WARNING("Packet tag reserved bit is high");
+		} else {
+			if (unlikely(tx_stat & 0x00008000)) {
+				pdata->stats.tx_errors++;
+			} else {
+				pdata->stats.tx_packets++;
+				pdata->stats.tx_bytes += (tx_stat >> 16);
+			}
+			if (unlikely(tx_stat & 0x00000100)) {
+				pdata->stats.collisions += 16;
+				pdata->stats.tx_aborted_errors += 1;
+			} else {
+				pdata->stats.collisions +=
+				    ((tx_stat >> 3) & 0xF);
+			}
+			if (unlikely(tx_stat & 0x00000800)) {
+				pdata->stats.tx_carrier_errors += 1;
+			}
+			if (unlikely(tx_stat & 0x00000200)) {
+				pdata->stats.collisions++;
+				pdata->stats.tx_aborted_errors++;
+			}
+		}
+	}
+	return;
+}
+
+/* Initializes the receiver, called single-threadedly during
+ * driver initialisation, it doesn't need phy_lock */
+static void smsc911x_rx_initialise(struct smsc911x_data *pdata)
+{
+	unsigned int mac_cr;
+
+	smsc911x_reg_write(0x00000200, pdata, RX_CFG);
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= MAC_CR_RXEN_;
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+
+	smsc911x_reg_write(smsc911x_reg_read(pdata, FIFO_INT) & ~(0xFF), pdata,
+			   FIFO_INT);
+	smsc911x_reg_write(smsc911x_reg_read(pdata, INT_EN) | INT_EN_RSFL_EN_,
+			   pdata, INT_EN);
+	return;
+}
+
+/* Reads a packet out of the RX_DATA_FIFO */
+static void
+smsc911x_rx_readfifo(struct smsc911x_data *pdata, unsigned int *buf,
+		     unsigned int count)
+{
+	while (count) {
+		*buf++ = smsc911x_reg_read(pdata, RX_DATA_FIFO);
+		count--;
+	}
+	return;
+}
+
+/* Passes a packet to linux */
+static void smsc911x_rx_handoffskb(struct smsc911x_data *pdata,
+				   struct sk_buff *skb)
+{
+	int result;
+
+	skb->dev = pdata->dev;
+	skb->protocol = eth_type_trans(skb, pdata->dev);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	result = netif_rx(skb);
+
+	switch (result) {
+	case NET_RX_SUCCESS:
+		break;
+	case NET_RX_CN_LOW:
+	case NET_RX_CN_MOD:
+	case NET_RX_CN_HIGH:
+	case NET_RX_DROP:
+		pdata->rx_congested = 1;
+		break;
+	default:
+		pdata->rx_congested = 1;
+		SMSC_WARNING("Unknown return value from "
+			     "netif_rx, result: %d", result);
+		break;
+	}
+	return;
+}
+
+/* Fetches the next rx status */
+static unsigned int smsc911x_rx_pop_rxstatus(struct smsc911x_data *pdata)
+{
+	unsigned int result;
+
+	result = smsc911x_reg_read(pdata, RX_FIFO_INF);
+	if ((pdata->rx_congested == 0) ||
+	    ((pdata->rx_congested == 1) && ((result & 0x00FF0000) == 0))) {
+		/* Rx status is available, read it */
+		if (result & 0x00FF0000)
+			result = smsc911x_reg_read(pdata, RX_STATUS_FIFO);
+		else
+			result = 0;
+	} else {
+		/*  Initiate the interrupt deassertion interval */
+		smsc911x_reg_write(smsc911x_reg_read(pdata, INT_CFG)
+				   | INT_CFG_INT_DEAS_CLR_, pdata, INT_CFG);
+		result = 0;
+	}
+	return result;
+}
+
+/* Increments the Rx error counters */
+static void
+smsc911x_rx_counterrors(struct smsc911x_data *pdata, unsigned int rxstat)
+{
+	int crc_err;
+
+	crc_err = 0;
+	if (unlikely(rxstat & 0x00008000)) {
+		pdata->stats.rx_errors++;
+		if (unlikely(rxstat & 0x00000002)) {
+			pdata->stats.rx_crc_errors++;
+			crc_err = 1;
+		}
+	}
+	if (likely(!crc_err)) {
+		if (unlikely((rxstat & 0x00001020) == 0x00001020)) {
+			/* Frame type indicates length,
+			 * and length error is set */
+			pdata->stats.rx_length_errors++;
+		}
+		if (rxstat & RX_STS_MCAST_)
+			pdata->stats.multicast++;
+	}
+	return;
+}
+
+/* Quickly dumps bad packets */
+static void
+smsc911x_rx_fastforward(struct smsc911x_data *pdata, unsigned int count)
+{
+	if (likely(count >= 4)) {
+		unsigned int timeout = 500;
+		smsc911x_reg_write(RX_DP_CTRL_RX_FFWD_, pdata, RX_DP_CTRL);
+		while (timeout && (smsc911x_reg_read(pdata, RX_DP_CTRL)
+				   & RX_DP_CTRL_RX_FFWD_)) {
+			udelay(1);
+			timeout--;
+		}
+		if (unlikely(timeout == 0)) {
+			SMSC_WARNING("Timed out waiting for RX FFWD "
+				     "to finish, RX_DP_CTRL: 0x%08X",
+				     smsc911x_reg_read(pdata, RX_DP_CTRL));
+		}
+	} else {
+		while (count) {
+			volatile unsigned int temp;
+			temp = smsc911x_reg_read(pdata, RX_DATA_FIFO);
+			count--;
+		}
+	}
+	return;
+}
+
+/* Main function for reading packets out of the LAN911x */
+static void smsc911x_rx_processpackets(struct smsc911x_data *pdata)
+{
+	unsigned int rxstat;
+	unsigned int *bufptr;
+
+	pdata->rx_congested = 0;
+	while ((rxstat = smsc911x_rx_pop_rxstatus(pdata)) != 0) {
+		unsigned int pktlength = ((rxstat & 0x3FFF0000) >> 16);
+		smsc911x_rx_counterrors(pdata, rxstat);
+
+		if (likely((rxstat & RX_STS_ES_) == 0)) {
+			struct sk_buff *skb = NULL;
+			skb = dev_alloc_skb(pktlength + 2);
+			if (likely(skb)) {
+				skb->data = skb->head;
+				skb->tail = skb->head;
+				/* Align IP on 16B boundary */
+				skb_reserve(skb, 2);
+				skb_put(skb, pktlength - 4);
+
+				/* Update counters */
+				pdata->stats.rx_packets++;
+				pdata->stats.rx_bytes += (pktlength - 4);
+				bufptr = (unsigned int *)skb->head;
+				smsc911x_rx_readfifo(pdata, bufptr,
+						     (pktlength + 2 + 3) >> 2);
+
+				smsc911x_rx_handoffskb(pdata, skb);
+				continue;
+			} else {
+				SMSC_WARNING("Unable to allocate sk_buff "
+					     "for rx packet, in PIO path");
+				pdata->stats.rx_dropped++;
+			}
+		}
+		/* At this point, the packet is to be read out
+		 * of the fifo and discarded */
+		pktlength += 2 + 3;
+		pktlength >>= 2;
+		smsc911x_rx_fastforward(pdata, pktlength);
+	}
+	pdata->stats.rx_dropped += smsc911x_reg_read(pdata, RX_DROP);
+	smsc911x_reg_write(INT_STS_RSFL_, pdata, INT_STS);
+	return;
+}
+
+/* Receive tasklet */
+static void smsc911x_rx_tasklet(unsigned long data)
+{
+	struct net_device *netdev;
+	struct smsc911x_data *pdata;
+
+	netdev = (struct net_device *)rx_tasklet_parameter;
+	pdata = netdev_priv(netdev);
+
+	smsc911x_rx_processpackets(pdata);
+	smsc911x_reg_write(smsc911x_reg_read(pdata, INT_CFG) | INT_CFG_IRQ_EN_,
+			   pdata, INT_CFG);
+	return;
+}
+
+/* Receiver irq handler */
+static int smsc911x_rx_handleirq(struct smsc911x_data *pdata,
+				 unsigned int intsts)
+{
+	int result = 0;
+
+	if (unlikely(intsts & INT_STS_RXE_)) {
+		smsc911x_reg_write(INT_STS_RXE_, pdata, INT_STS);
+		result = 1;
+	}
+	if (!(intsts & INT_STS_RSFL_)) {
+		return result;
+	}
+
+	result = 1;
+	smsc911x_reg_write(smsc911x_reg_read(pdata, INT_CFG) &
+			   (~INT_CFG_IRQ_EN_), pdata, INT_CFG);
+	tasklet_schedule(&rx_tasklet);
+	return result;
+}
+
+/* Returns hash bit number for given MAC address
+ * Example:
+ * 01 00 5E 00 00 01 -> returns bit number 31 */
+static unsigned int smsc911x_hash(char addr[6])
+{
+	int i;
+	int bit;
+	unsigned int crc;
+	unsigned int poly;
+	unsigned int result;
+	unsigned int data;
+
+	crc = 0xFFFFFFFF;
+	poly = 0xEDB88320;
+	result = 0;
+
+	for (i = 0; i < 6; i++) {
+		data = (unsigned int)addr[i];
+		for (bit = 0; bit < 8; bit++) {
+			unsigned int p = (crc ^ ((unsigned int)data)) & 1;
+			crc >>= 1;
+			if (p != 0)
+				crc ^= poly;
+			data >>= 1;
+		}
+	}
+	result = ((crc & 0x01) << 5) | ((crc & 0x02) << 3) |
+	    ((crc & 0x04) << 1) | ((crc & 0x08) >> 1) |
+	    ((crc & 0x10) >> 3) | ((crc & 0x20) >> 5);
+	return result;
+}
+
+static void smsc911x_rx_multicast_update(struct smsc911x_data *pdata)
+{
+	unsigned long flags;
+	unsigned int timeout;
+	unsigned int mac_cr;
+
+	/* This function is only called for older LAN911x devices 
+	 * (revA or revB), where MAC_CR, HASHH and HASHL should not
+	 * be modified during Rx - newer devices immediately update the
+	 * registers */
+
+	local_irq_save(flags);
+
+	/* Stop Rx */
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr &= ~(MAC_CR_RXEN_);
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+
+	/* Poll until Rx has stopped.  If a frame is being recieved, this will
+	 * block until the end of this frame.  (this may take a long time at
+	 * 10Mbps) */
+	timeout = 2000;
+	while ((timeout--)
+	       && (!(smsc911x_reg_read(pdata, INT_STS) & INT_STS_RXSTOP_INT_))) {
+		udelay(1);
+	}
+
+	if (unlikely(timeout == 0)) {
+		/* We have delayed for 2000us, so Rx should have stopped.  At
+		 * 10Mbps-HD, Rx stop is only 99.6% reliable. */
+		SMSC_WARNING("Rx stop timed out\n");
+	}
+
+	/* Acknowledge the interrupt */
+	smsc911x_reg_write(INT_STS_RXSTOP_INT_, pdata, INT_STS);
+
+	/* Perform the update - safe to do now Rx has stopped */
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= pdata->set_bits_mask;
+	mac_cr &= ~(pdata->clear_bits_mask);
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+	smsc911x_mac_write(pdata, HASHH, pdata->hashhi);
+	smsc911x_mac_write(pdata, HASHL, pdata->hashlo);
+	SMSC_TRACE("maccr 0x%08X, HASHH 0x%08X, HASHL 0x%08X", mac_cr,
+		   pdata->HashHi, pdata->HashLo);
+
+	/* Re-enable Rx */
+	mac_cr = smsc911x_mac_read(pdata, MAC_CR);
+	mac_cr |= MAC_CR_RXEN_;
+	smsc911x_mac_write(pdata, MAC_CR, mac_cr);
+
+	pdata->multicast_update_pending = 0;
+
+	local_irq_restore(flags);
+}
+
+static int
+smsc911x_lan_initialise(struct smsc911x_data *pdata, unsigned int intcfg)
+{
+	int result;
+	unsigned int timeout;
+	unsigned int temp;
+
+	result = 0;
+	timeout = 0;
+	temp = 0;
+	SMSC_TRACE("LAN Initialise, int_cfg: 0x%08X", intcfg);
+	BUG_ON(!pdata);
+	spin_lock_init(&pdata->phy_lock);
+
+	/* Reset the LAN911x */
+	smsc911x_reg_write(HW_CFG_SRST_, pdata, HW_CFG);
+	timeout = 10;
+
+	do {
+		udelay(10);
+		temp = smsc911x_reg_read(pdata, HW_CFG);
+		timeout--;
+	} while ((timeout > 0) && (temp & HW_CFG_SRST_));
+
+	if (unlikely(temp & HW_CFG_SRST_)) {
+		SMSC_WARNING("Failed to complete reset");
+		goto done;
+	}
+
+	smsc911x_reg_write(0x00050000, pdata, HW_CFG);
+	smsc911x_reg_write(0x006E3740, pdata, AFC_CFG);
+
+	/* Make sure EEPROM has finished loading before setting GPIO_CFG */
+	timeout = 50;
+	while ((timeout > 0) &&
+	       (smsc911x_reg_read(pdata, E2P_CMD) & E2P_CMD_EPC_BUSY_)) {
+		udelay(10);
+		timeout--;
+	}
+
+	if (unlikely(timeout == 0)) {
+		SMSC_WARNING("Timed out waiting for EEPROM "
+			     "busy bit to clear\n");
+	}
+#if USE_DEBUG >= 1
+	smsc911x_reg_write(0x00670700, pdata, GPIO_CFG);
+#else
+	smsc911x_reg_write(0x70070000, pdata, GPIO_CFG);
+#endif
+
+	/* Initialise irqs */
+	smsc911x_reg_write(0, pdata, INT_EN);
+	smsc911x_reg_write(0xFFFFFFFF, pdata, INT_STS);
+	intcfg |= INT_CFG_IRQ_EN_;
+	smsc911x_reg_write(intcfg, pdata, INT_CFG);
+	result = 1;
+      done:
+	return result;
+}
+
+/* Initializing private device structures */
+static int smsc911x_init(struct net_device *netdev)
+{
+	int result;
+	unsigned long idrev;
+	unsigned int mac_high16;
+	unsigned int mac_low32;
+	struct smsc911x_data *pdata;
+
+	idrev = 0;
+	pdata = 0;
+	result = -ENODEV;
+
+	BUG_ON(!netdev);
+
+	SMSC_TRACE("Driver Parameters:");
+	SMSC_TRACE("LAN base: 0x%08lX", netdev->base_addr);
+	SMSC_TRACE("IRQ: %d", netdev->irq);
+	SMSC_TRACE("PHY will be autodetected.");
+	BUG_ON(!netdev_priv(netdev));
+
+	memset(netdev_priv(netdev), 0, sizeof(struct smsc911x_data));
+	pdata = netdev_priv(netdev);
+
+	if (netdev->base_addr == 0) {
+		SMSC_WARNING("netdev->base_addr: 0x00000000");
+		result = -ENODEV;
+		goto done;
+	}
+	/* Initialise internal base field */
+	pdata->base = netdev->base_addr;
+
+	/* Read mac address assigned as from EEPROM */
+	mac_high16 = smsc911x_mac_read(pdata, ADDRH);
+	mac_low32 = smsc911x_mac_read(pdata, ADDRL);
+
+	if ((mac_high16 == 0x0000FFFF)
+	    && (mac_low32 == 0xFFFFFFFF)) {
+
+		/* Use default MAC addresses if eeprom values are invalid */
+		mac_high16 = 0x00000070;
+		mac_low32 = 0x110F8000;
+		smsc911x_mac_write(pdata, ADDRH, mac_high16);
+		smsc911x_mac_write(pdata, ADDRL, mac_low32);
+		SMSC_TRACE("MAC Address is set by default to 0x%04X%08X",
+			   mac_high16, mac_low32);
+	} else {
+		SMSC_TRACE("MAC Address is read from LAN911x as 0x%04X%08X",
+			   mac_high16, mac_low32);
+	}
+
+	/* Default generation to zero (all workarounds apply) */
+	pdata->generation = 0;
+
+	idrev = smsc911x_reg_read(pdata, ID_REV);
+	if (((idrev >> 16) & 0xFFFF) == (idrev & 0xFFFF)) {
+		/* this may mean the chip is set for 32 bit
+		 * while the bus is reading as 16 bit
+		 */
+	      unknown_chip:
+		SMSC_WARNING("LAN911x not identified, idrev: 0x%08lX", idrev);
+		result = -ENODEV;
+		goto done;
+	}
+	switch (idrev & 0xFFFF0000) {
+	case 0x01180000:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE("LAN9118 Beacon identified, idrev: 0x%08lX",
+				   idrev);
+			pdata->generation = 0;
+			break;
+		case 1UL:
+			SMSC_TRACE
+			    ("LAN9118 Concord A0 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 1;
+			break;
+		case 2UL:
+			SMSC_TRACE
+			    ("LAN9118 Concord A1 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9118 Concord A1 identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		}
+		break;
+
+	case 0x01170000:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE("LAN9117 Beacon identified, idrev: 0x%08lX",
+				   idrev);
+			pdata->generation = 0;
+			break;
+		case 1UL:
+			SMSC_TRACE
+			    ("LAN9117 Concord A0 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 1;
+			break;
+		case 2UL:
+			SMSC_TRACE
+			    ("LAN9117 Concord A1 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9117 Concord A1 identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		}
+		break;
+
+	case 0x01160000:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			goto unknown_chip;
+		case 1UL:
+			SMSC_TRACE
+			    ("LAN9116 Concord A0 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 1;
+			break;
+		case 2UL:
+			SMSC_TRACE
+			    ("LAN9116 Concord A1 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9116 Concord A1 identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		}
+		break;
+
+	case 0x01150000:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			goto unknown_chip;
+		case 1UL:
+			SMSC_TRACE
+			    ("LAN9115 Concord A0 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 1;
+			break;
+		case 2UL:
+			SMSC_TRACE
+			    ("LAN9115 Concord A1 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9115 Concord A1 identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		}
+		break;
+
+	case 0x01120000:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			goto unknown_chip;
+		case 1UL:
+			SMSC_TRACE
+			    ("LAN9112 Concord A0 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 1;
+			break;
+		case 2UL:
+			SMSC_TRACE
+			    ("LAN9112 Concord A1 identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9112 Concord A1 identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 2;
+			break;
+		}
+		break;
+
+	case 0x118A0000UL:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE
+			    ("LAN9218 Boylston identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9218 Boylston identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		}
+		break;
+
+	case 0x117A0000UL:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE
+			    ("LAN9217 Boylston identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9217 Boylston identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		}
+		break;
+
+	case 0x116A0000UL:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE
+			    ("LAN9216 Boylston identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9216 Boylston identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		}
+		break;
+
+	case 0x115A0000UL:
+		switch (idrev & 0x0000FFFFUL) {
+		case 0UL:
+			SMSC_TRACE
+			    ("LAN9215 Boylston identified, idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		default:
+			SMSC_TRACE
+			    ("LAN9215 Boylston identified (NEW), idrev: 0x%08lX",
+			     idrev);
+			pdata->generation = 3;
+			break;
+		}
+		break;
+
+	default:
+		goto unknown_chip;
+	}
+	pdata->idrev = idrev;
+
+	if (pdata->generation == 0)
+		SMSC_WARNING("This driver is not intended "
+			     "for this chip revision");
+
+	ether_setup(netdev);
+	netdev->open = smsc911x_open;
+	netdev->stop = smsc911x_stop;
+	netdev->hard_start_xmit = smsc911x_hard_start_xmit;
+	netdev->get_stats = smsc911x_get_stats;
+	netdev->set_multicast_list = smsc911x_set_multicast_list;
+	netdev->flags |= IFF_MULTICAST;
+	pdata->dev = netdev;
+
+	result = 0;
+
+      done:
+	return result;
+}
+
+static int smsc911x_drv_remove(struct platform_device *pdev)
+{
+	struct net_device *netdev;
+	struct smsc911x_data *pdata;
+	struct resource *res;
+	unsigned int base;
+
+	netdev = platform_get_drvdata(pdev);
+	BUG_ON(!netdev);
+	pdata = netdev_priv(netdev);
+	BUG_ON(!pdata);
+	base = pdata->base;
+	BUG_ON(!base);
+
+	SMSC_TRACE("Stopping driver.");
+	platform_set_drvdata(pdev, NULL);
+	unregister_netdev(netdev);
+	free_irq(netdev->irq, netdev);
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+					   "smsc911x-memory");
+	if (!res)
+		platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
+	release_mem_region(res->start, res->end - res->start);
+	/* Clear global ptr to netdev for tasklets */
+	rx_tasklet_parameter = 0;
+	free_netdev(netdev);
+	iounmap((void *)base);
+	return 0;
+}
+
+static int smsc911x_drv_probe(struct platform_device *pdev)
+{
+	struct net_device *netdev;
+	struct resource *res;
+	unsigned int base;
+	int res_size;
+	int retval;
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+					   "smsc911x-memory");
+	if (!res)
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		retval = -ENODEV;
+		goto out;
+	}
+	res_size = res->end - res->start;
+
+	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
+		retval = -EBUSY;
+		goto out;
+	}
+
+	netdev = alloc_etherdev(sizeof(struct smsc911x_data));
+	if (!netdev) {
+		printk("%s: Could not allocate device.\n", SMSC_CHIPNAME);
+		retval = -ENOMEM;
+		goto out_release_io;
+	}
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	/* Global pointer to netdev, used by tasklets */
+	rx_tasklet_parameter = (unsigned long)netdev;
+	netdev->irq = platform_get_irq(pdev, 0);
+	netdev->base_addr = (unsigned int)ioremap_nocache(res->start, res_size);
+	base = netdev->base_addr;
+	if (netdev->base_addr == 0) {
+		SMSC_WARNING("Error smsc911x base address invalid");
+		retval = -ENOMEM;
+		goto out_free_netdev;
+	}
+
+	if ((retval = smsc911x_init(netdev)) < 0)
+		goto out_unmap_io;
+
+	if (request_irq(netdev->irq, smsc911x_irqhandler,
+			SA_INTERRUPT, SMSC_CHIPNAME,
+			netdev_priv(netdev)) != 0) {
+		SMSC_WARNING("Unable to claim requested irq: %d", netdev->irq);
+		retval = -ENODEV;
+		goto out_unmap_io;
+	}
+
+	platform_set_drvdata(pdev, netdev);
+	retval = register_netdev(netdev);
+
+	if (retval) {
+		SMSC_WARNING("Error %i registering device", retval);
+		retval = -ENODEV;
+		goto out_unset_drvdata;
+	} else {
+		SMSC_TRACE("Network interface: \"%s\"", netdev->name);
+	}
+
+	return 0;
+
+out_unset_drvdata:
+	platform_set_drvdata(pdev, NULL);
+out_unmap_io:
+	iounmap((void *)base);
+out_free_netdev:
+	rx_tasklet_parameter = 0;
+	free_netdev(netdev);
+out_release_io:
+	release_mem_region(res->start, res->end - res->start);
+out:
+	return retval;
+}
+
+static struct platform_driver smsc911x_driver = {
+	.probe = smsc911x_drv_probe,
+	.remove = smsc911x_drv_remove,
+	.suspend = 0,		/* TODO: Add suspend routine */
+	.resume = 0,		/* TODO: Add resume routeine */
+	.driver = {
+		   .name = SMSC_CHIPNAME,
+		   },
+};
+
+/* Entry point for loading the module ==> All below must go
+ * into drv_probe */
+static int __init smsc911x_init_module(void)
+{
+	platform_driver_register(&smsc911x_driver);
+	return 0;
+}
+
+/* entry point for unloading the module */
+static void __exit smsc911x_cleanup_module(void)
+{
+	platform_driver_unregister(&smsc911x_driver);
+}
+
+module_init(smsc911x_init_module);
+module_exit(smsc911x_cleanup_module);
diff --git a/drivers/net/smsc911x.h b/drivers/net/smsc911x.h
new file mode 100644
index 0000000..175f6cb
--- /dev/null
+++ b/drivers/net/smsc911x.h
@@ -0,0 +1,504 @@
+#ifndef __SMSC911X_H__
+#define __SMSC911X_H__
+
+#define USE_PHY_WORK_AROUND
+#define USE_LED1_WORK_AROUND	/* 10/100 LED link-state inversion */
+
+/* Debugging */
+#define USE_DEBUG	0
+#if USE_DEBUG >= 1
+#define SMSC_WARNING(fmt, args...) \
+		printk(KERN_EMERG "SMSC_WARNING: %s: " fmt "\n", \
+			__FUNCTION__ , ## args)
+#else
+#define SMSC_WARNING(msg, args...)
+#endif				/* USE_DEBUG >= 1 */
+
+#if USE_DEBUG >= 2
+#define SMSC_TRACE(fmt,args...) \
+		printk(KERN_EMERG "SMSC_TRACE: %s: " fmt "\n", \
+			__FUNCTION__ , ## args)
+#else
+#define SMSC_TRACE(msg,args...)
+#endif				/* USE_DEBUG >= 2 */
+
+/* NOTE: If you add any more fields, make sure to decide on whether
+ * to clear the fields or retain their values in smsc911x_stop() */
+struct smsc911x_data {
+	unsigned int base;
+	unsigned int idrev;
+
+	/* used to decide which workarounds apply */
+	unsigned int generation;
+
+	struct net_device *dev;
+
+	/* This needs to be acquired before calling any of below:
+	 * smsc911x_mac_read(), smsc911x_mac_write()
+	 * smsc911x_phy_read(), smsc911x_phy_write()
+	 */
+	spinlock_t phy_lock;
+
+	int rx_congested;
+	struct net_device_stats stats;
+
+	unsigned int phy_address;
+#ifdef USE_LED1_WORK_AROUND
+	unsigned int gpio_setting;
+	unsigned int gpio_orig_setting;
+	unsigned int not_using_extphy;
+#endif
+	unsigned int link_speed;
+	unsigned int link_settings;
+	struct timer_list link_poll_timer;
+	int stop_link_poll;
+
+	int request_irq_disable;
+	int software_irq_signal;
+
+#ifdef USE_PHY_WORK_AROUND
+#define MIN_PACKET_SIZE (64)
+	char loopback_tx_pkt[MIN_PACKET_SIZE];
+	char loopback_rx_pkt[MIN_PACKET_SIZE];
+	unsigned int resetcount;
+#endif
+
+	/* Members for Multicast filter workaround */
+	unsigned int multicast_update_pending;
+	unsigned int set_bits_mask;
+	unsigned int clear_bits_mask;
+	unsigned int hashhi;
+	unsigned int hashlo;
+};
+
+#define TX_FIFO_LOW_THRESHOLD            (1600)
+
+/* IO macros for portability */
+
+#define SMSC_CAN_USE_16BIT	0
+#define SMSC_CAN_USE_32BIT	1
+
+#if SMSC_CAN_USE_16BIT
+
+static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+{
+	u32 reg_val;
+	unsigned long flags;
+
+	/* these two 16-bit reads must be performed consecutively, so must
+	 * not be interrupted by our own ISR (which would start another
+	 * read operation) */
+	local_irq_save(flags);
+	reg_val = ((readw((u16 *)(pdata->base + reg)) & 0xFFFF) |
+		   ((readw((u16 *)(pdata->base + reg + 2)) & 0xFFFF) << 16));
+	local_irq_restore(flags);
+
+	return reg_val;
+}
+
+static inline void smsc911x_reg_write(u32 val, struct smsc911x_data *pdata,
+				      u32 reg)
+{
+	unsigned long flags;
+
+	/* these two 16-bit writes must be performed consecutively, so must
+	 * not be interrupted by our own ISR (which would start another
+	 * read operation) */
+	local_irq_save(flags);
+	writew(val & 0xFFFF, (u16 *)(pdata->base + reg));
+	writew(((val >> 16) & 0xFFFF), (u16 *)(pdata->base + reg + 2));
+	local_irq_restore(flags);
+}
+
+#elif SMSC_CAN_USE_32BIT
+
+static inline u32 smsc911x_reg_read(struct smsc911x_data *pdata, u32 reg)
+{
+	return readl((u32 *)(pdata->base + reg));
+}
+
+static inline void smsc911x_reg_write(u32 val, struct smsc911x_data *pdata,
+				      u32 reg)
+{
+	writel(val, (u32 *)(pdata->base + reg));
+}
+
+#endif				/* SMSC_CAN_USE_32BIT */
+
+/* SMSC911x registers and bitfields */
+#define RX_DATA_FIFO					0x00
+
+#define TX_DATA_FIFO					0x20
+#define TX_CMD_A_ON_COMP_				0x80000000
+#define TX_CMD_A_BUF_END_ALGN_				0x03000000
+#define TX_CMD_A_4_BYTE_ALGN_				0x00000000
+#define TX_CMD_A_16_BYTE_ALGN_				0x01000000
+#define TX_CMD_A_32_BYTE_ALGN_				0x02000000
+#define TX_CMD_A_DATA_OFFSET_				0x001F0000
+#define TX_CMD_A_FIRST_SEG_				0x00002000
+#define TX_CMD_A_LAST_SEG_				0x00001000
+#define TX_CMD_A_BUF_SIZE_				0x000007FF
+#define TX_CMD_B_PKT_TAG_				0xFFFF0000
+#define TX_CMD_B_ADD_CRC_DISABLE_			0x00002000
+#define TX_CMD_B_DISABLE_PADDING_			0x00001000
+#define TX_CMD_B_PKT_BYTE_LENGTH_			0x000007FF
+
+#define RX_STATUS_FIFO					0x40
+#define RX_STS_ES_					0x00008000
+#define RX_STS_MCAST_					0x00000400
+#define RX_STATUS_FIFO_PEEK				0x44
+#define TX_STATUS_FIFO					0x48
+#define TX_STATUS_FIFO_PEEK				0x4C
+#define ID_REV						0x50
+#define ID_REV_CHIP_ID_					0xFFFF0000 /* RO */
+#define ID_REV_REV_ID_					0x0000FFFF /* RO */
+
+#define INT_CFG						0x54
+#define INT_CFG_INT_DEAS_				0xFF000000 /* R/W */
+#define INT_CFG_INT_DEAS_CLR_				0x00004000 /* SC */
+#define INT_CFG_INT_DEAS_STS_				0x00002000 /* SC */
+#define INT_CFG_IRQ_INT_				0x00001000 /* RO */
+#define INT_CFG_IRQ_EN_					0x00000100 /* R/W */
+#define INT_CFG_IRQ_POL_				0x00000010 /* R/W Not Affected by SW Reset */
+#define INT_CFG_IRQ_TYPE_				0x00000001 /* R/W Not Affected by SW Reset */
+
+#define INT_STS						0x58
+#define INT_STS_SW_INT_					0x80000000 /* R/WC */
+#define INT_STS_TXSTOP_INT_				0x02000000 /* R/WC */
+#define INT_STS_RXSTOP_INT_				0x01000000 /* R/WC */
+#define INT_STS_RXDFH_INT_				0x00800000 /* R/WC */
+#define INT_STS_RXDF_INT_				0x00400000 /* R/WC */
+#define INT_STS_TX_IOC_					0x00200000 /* R/WC */
+#define INT_STS_RXD_INT_				0x00100000 /* R/WC */
+#define INT_STS_GPT_INT_				0x00080000 /* R/WC */
+#define INT_STS_PHY_INT_				0x00040000 /* RO */
+#define INT_STS_PME_INT_				0x00020000 /* R/WC */
+#define INT_STS_TXSO_					0x00010000 /* R/WC */
+#define INT_STS_RWT_					0x00008000 /* R/WC */
+#define INT_STS_RXE_					0x00004000 /* R/WC */
+#define INT_STS_TXE_					0x00002000 /* R/WC */
+#define INT_STS_TDFU_					0x00000800 /* R/WC */
+#define INT_STS_TDFO_					0x00000400 /* R/WC */
+#define INT_STS_TDFA_					0x00000200 /* R/WC */
+#define INT_STS_TSFF_					0x00000100 /* R/WC */
+#define INT_STS_TSFL_					0x00000080 /* R/WC */
+#define INT_STS_RXDF_					0x00000040 /* R/WC */
+#define INT_STS_RDFL_					0x00000020 /* R/WC */
+#define INT_STS_RSFF_					0x00000010 /* R/WC */
+#define INT_STS_RSFL_					0x00000008 /* R/WC */
+#define INT_STS_GPIO2_INT_				0x00000004 /* R/WC */
+#define INT_STS_GPIO1_INT_				0x00000002 /* R/WC */
+#define INT_STS_GPIO0_INT_				0x00000001 /* R/WC */
+#define INT_EN						0x5C
+#define INT_EN_SW_INT_EN_				0x80000000 /* R/W */
+#define INT_EN_TXSTOP_INT_EN_				0x02000000 /* R/W */
+#define INT_EN_RXSTOP_INT_EN_				0x01000000 /* R/W */
+#define INT_EN_RXDFH_INT_EN_				0x00800000 /* R/W */
+#define INT_EN_TIOC_INT_EN_				0x00200000 /* R/W */
+#define INT_EN_RXD_INT_EN_				0x00100000 /* R/W */
+#define INT_EN_GPT_INT_EN_				0x00080000 /* R/W */
+#define INT_EN_PHY_INT_EN_				0x00040000 /* R/W */
+#define INT_EN_PME_INT_EN_				0x00020000 /* R/W */
+#define INT_EN_TXSO_EN_					0x00010000 /* R/W */
+#define INT_EN_RWT_EN_					0x00008000 /* R/W */
+#define INT_EN_RXE_EN_					0x00004000 /* R/W */
+#define INT_EN_TXE_EN_					0x00002000 /* R/W */
+#define INT_EN_TDFU_EN_					0x00000800 /* R/W */
+#define INT_EN_TDFO_EN_					0x00000400 /* R/W */
+#define INT_EN_TDFA_EN_					0x00000200 /* R/W */
+#define INT_EN_TSFF_EN_					0x00000100 /* R/W */
+#define INT_EN_TSFL_EN_					0x00000080 /* R/W */
+#define INT_EN_RXDF_EN_					0x00000040 /* R/W */
+#define INT_EN_RDFL_EN_					0x00000020 /* R/W */
+#define INT_EN_RSFF_EN_					0x00000010 /* R/W */
+#define INT_EN_RSFL_EN_					0x00000008 /* R/W */
+#define INT_EN_GPIO2_INT_				0x00000004 /* R/W */
+#define INT_EN_GPIO1_INT_				0x00000002 /* R/W */
+#define INT_EN_GPIO0_INT_				0x00000001 /* R/W */
+
+#define BYTE_TEST					0x64
+#define FIFO_INT					0x68
+#define FIFO_INT_TX_AVAIL_LEVEL_			0xFF000000/* R/W */
+#define FIFO_INT_TX_STS_LEVEL_				0x00FF0000/* R/W */
+#define FIFO_INT_RX_AVAIL_LEVEL_			0x0000FF00/* R/W */
+#define FIFO_INT_RX_STS_LEVEL_				0x000000FF/* R/W */
+
+#define RX_CFG						0x6C
+#define RX_CFG_RX_END_ALGN_				0xC0000000 /* R/W */
+#define RX_CFG_RX_END_ALGN4_				0x00000000 /* R/W */
+#define RX_CFG_RX_END_ALGN16_				0x40000000 /* R/W */
+#define RX_CFG_RX_END_ALGN32_				0x80000000 /* R/W */
+#define RX_CFG_RX_DMA_CNT_				0x0FFF0000 /* R/W */
+#define RX_CFG_RX_DUMP_					0x00008000 /* R/W */
+#define RX_CFG_RXDOFF_					0x00001F00 /* R/W */
+
+#define TX_CFG						0x70
+#define TX_CFG_TXS_DUMP_				0x00008000 /* Self Clearing */
+#define TX_CFG_TXD_DUMP_				0x00004000 /* Self Clearing */
+#define TX_CFG_TXSAO_					0x00000004 /* R/W */
+#define TX_CFG_TX_ON_					0x00000002 /* R/W */
+#define TX_CFG_STOP_TX_					0x00000001 /* Self Clearing */
+
+#define HW_CFG						0x74
+#define HW_CFG_TTM_					0x00200000 /* R/W */
+#define HW_CFG_SF_					0x00100000 /* R/W */
+#define HW_CFG_TX_FIF_SZ_				0x000F0000 /* R/W */
+#define HW_CFG_TR_					0x00003000 /* R/W */
+
+/* R/W only available on 115/117 */
+#define HW_CFG_PHY_CLK_SEL_				0x00000060
+
+/* R/W only available on 115/117 */
+#define HW_CFG_PHY_CLK_SEL_INT_PHY_			0x00000000
+
+/* R/W only available on 115/117 */
+#define HW_CFG_PHY_CLK_SEL_EXT_PHY_			0x00000020
+
+/* R/W only available on 115/117 */
+#define HW_CFG_PHY_CLK_SEL_CLK_DIS_			0x00000040
+
+/* R/W only available on 115/117 */
+#define HW_CFG_SMI_SEL_		 			0x00000010
+
+/* RO only available  on 115/117 */
+#define HW_CFG_EXT_PHY_DET_				0x00000008
+
+/* R/W only available on 115/117 */
+#define HW_CFG_EXT_PHY_EN_				0x00000004
+
+/* RO only available  on 116/118 */
+#define HW_CFG_32_16_BIT_MODE_				0x00000004
+
+/* RO only available  on 115/117 */
+#define HW_CFG_SRST_TO_					0x00000002
+#define HW_CFG_SRST_					0x00000001 /* Self Clearing */
+
+#define RX_DP_CTRL					0x78
+#define RX_DP_CTRL_RX_FFWD_				0x80000000 /* RO */
+
+#define RX_FIFO_INF					0x7C
+#define RX_FIFO_INF_RXSUSED_				0x00FF0000 /* RO */
+#define RX_FIFO_INF_RXDUSED_				0x0000FFFF /* RO */
+
+#define TX_FIFO_INF					0x80
+#define TX_FIFO_INF_TSUSED_				0x00FF0000 /* RO */
+#define TX_FIFO_INF_TDFREE_				0x0000FFFF /* RO */
+
+#define PMT_CTRL					0x84
+#define PMT_CTRL_PM_MODE_				0x00003000 /* Self Clearing */
+#define PMT_CTRL_PM_MODE_D0_				0x00000000 /* Self Clearing */
+#define PMT_CTRL_PM_MODE_D1_				0x00001000 /* Self Clearing */
+#define PMT_CTRL_PM_MODE_D2_				0x00002000 /* Self Clearing */
+#define PMT_CTRL_PM_MODE_D3_				0x00003000 /* Self Clearing */
+#define PMT_CTRL_PHY_RST_				0x00000400 /* Self Clearing */
+#define PMT_CTRL_WOL_EN_				0x00000200 /* R/W */
+#define PMT_CTRL_ED_EN_					0x00000100 /* R/W */
+#define PMT_CTRL_PME_TYPE_				0x00000040 /* R/W
+								    * Not Affected by
+								    * SW Reset */
+#define PMT_CTRL_WUPS_					0x00000030 /* R/WC */
+#define PMT_CTRL_WUPS_NOWAKE_				0x00000000 /* R/WC */
+#define PMT_CTRL_WUPS_ED_				0x00000010 /* R/WC */
+#define PMT_CTRL_WUPS_WOL_				0x00000020 /* R/WC */
+#define PMT_CTRL_WUPS_MULTI_				0x00000030 /* R/WC */
+#define PMT_CTRL_PME_IND_				0x00000008 /* R/W */
+#define PMT_CTRL_PME_POL_				0x00000004 /* R/W */
+#define PMT_CTRL_PME_EN_				0x00000002 /* R/W
+								    * Not Affected by
+								    * SW Reset */
+#define PMT_CTRL_READY_					0x00000001 /* RO */
+
+#define GPIO_CFG					0x88
+#define GPIO_CFG_LED3_EN_				0x40000000 /* R/W */
+#define GPIO_CFG_LED2_EN_				0x20000000 /* R/W */
+#define GPIO_CFG_LED1_EN_				0x10000000 /* R/W */
+#define GPIO_CFG_GPIO2_INT_POL_				0x04000000 /* R/W */
+#define GPIO_CFG_GPIO1_INT_POL_				0x02000000 /* R/W */
+#define GPIO_CFG_GPIO0_INT_POL_				0x01000000 /* R/W */
+#define GPIO_CFG_EEPR_EN_				0x00700000 /* R/W */
+#define GPIO_CFG_GPIOBUF2_				0x00040000 /* R/W */
+#define GPIO_CFG_GPIOBUF1_				0x00020000 /* R/W */
+#define GPIO_CFG_GPIOBUF0_				0x00010000 /* R/W */
+#define GPIO_CFG_GPIODIR2_				0x00000400 /* R/W */
+#define GPIO_CFG_GPIODIR1_				0x00000200 /* R/W */
+#define GPIO_CFG_GPIODIR0_				0x00000100 /* R/W */
+#define GPIO_CFG_GPIOD4_				0x00000020 /* R/W */
+#define GPIO_CFG_GPIOD3_				0x00000010 /* R/W */
+#define GPIO_CFG_GPIOD2_				0x00000004 /* R/W */
+#define GPIO_CFG_GPIOD1_				0x00000002 /* R/W */
+#define GPIO_CFG_GPIOD0_				0x00000001 /* R/W */
+
+#define GPT_CFG						0x8C
+#define GPT_CFG_TIMER_EN_				0x20000000 /* R/W */
+#define GPT_CFG_GPT_LOAD_				0x0000FFFF /* R/W */
+
+#define GPT_CNT						0x90
+#define GPT_CNT_GPT_CNT_				0x0000FFFF /* RO */
+
+#define ENDIAN						0x98
+#define FREE_RUN					0x9C
+#define RX_DROP						0xA0
+#define MAC_CSR_CMD					0xA4
+#define MAC_CSR_CMD_CSR_BUSY_				0x80000000 /* Self Clearing */
+#define MAC_CSR_CMD_R_NOT_W_				0x40000000 /* R/W */
+#define MAC_CSR_CMD_CSR_ADDR_				0x000000FF /* R/W */
+
+#define MAC_CSR_DATA					0xA8
+#define AFC_CFG						0xAC
+#define AFC_CFG_AFC_HI_					0x00FF0000 /* R/W */
+#define AFC_CFG_AFC_LO_					0x0000FF00 /* R/W */
+#define AFC_CFG_BACK_DUR_				0x000000F0 /* R/W */
+#define AFC_CFG_FCMULT_					0x00000008 /* R/W */
+#define AFC_CFG_FCBRD_					0x00000004 /* R/W */
+#define AFC_CFG_FCADD_					0x00000002 /* R/W */
+#define AFC_CFG_FCANY_					0x00000001 /* R/W */
+
+#define E2P_CMD						0xB0
+#define E2P_CMD_EPC_BUSY_				0x80000000 /* Self Clearing */
+#define E2P_CMD_EPC_CMD_				0x70000000 /* R/W */
+#define E2P_CMD_EPC_CMD_READ_				0x00000000 /* R/W */
+#define E2P_CMD_EPC_CMD_EWDS_				0x10000000 /* R/W */
+#define E2P_CMD_EPC_CMD_EWEN_				0x20000000 /* R/W */
+#define E2P_CMD_EPC_CMD_WRITE_				0x30000000 /* R/W */
+#define E2P_CMD_EPC_CMD_WRAL_				0x40000000 /* R/W */
+#define E2P_CMD_EPC_CMD_ERASE_				0x50000000 /* R/W */
+#define E2P_CMD_EPC_CMD_ERAL_				0x60000000 /* R/W */
+#define E2P_CMD_EPC_CMD_RELOAD_				0x70000000 /* R/W */
+#define E2P_CMD_EPC_TIMEOUT_				0x00000200 /* R */
+#define E2P_CMD_MAC_ADDR_LOADED_			0x00000100 /* RO */
+#define E2P_CMD_EPC_ADDR_				0x000000FF /* R/W */
+
+#define E2P_DATA					0xB4
+#define E2P_DATA_EEPROM_DATA_				0x000000FF /* R/W */
+#define LAN_REGISTER_EXTENT				0x00000100
+
+#define LINK_OFF					0x00
+#define LINK_SPEED_10HD					0x01
+#define LINK_SPEED_10FD					0x02
+#define LINK_SPEED_100HD				0x04
+#define LINK_SPEED_100FD				0x08
+#define LINK_SYMMETRIC_PAUSE				0x10
+#define LINK_ASYMMETRIC_PAUSE				0x20
+#define LINK_AUTO_NEGOTIATE				0x40
+
+/*
+ *		 MAC Control and Status Register (Indirect Address)
+ *		 Offset (through the MAC_CSR CMD and DATA port)
+ */
+#define MAC_CR						0x01	/* R/W */
+
+/* MAC_CR - MAC Control Register */
+#define MAC_CR_RXALL_					0x80000000
+#define MAC_CR_HBDIS_					0x10000000
+#define MAC_CR_RCVOWN_					0x00800000
+#define MAC_CR_LOOPBK_					0x00200000
+#define MAC_CR_FDPX_					0x00100000
+#define MAC_CR_MCPAS_					0x00080000
+#define MAC_CR_PRMS_					0x00040000
+#define MAC_CR_INVFILT_					0x00020000
+#define MAC_CR_PASSBAD_					0x00010000
+#define MAC_CR_HFILT_					0x00008000
+#define MAC_CR_HPFILT_					0x00002000
+#define MAC_CR_LCOLL_					0x00001000
+#define MAC_CR_BCAST_					0x00000800
+#define MAC_CR_DISRTY_					0x00000400
+#define MAC_CR_PADSTR_					0x00000100
+#define MAC_CR_BOLMT_MASK_				0x000000C0
+#define MAC_CR_DFCHK_					0x00000020
+#define MAC_CR_TXEN_					0x00000008
+#define MAC_CR_RXEN_					0x00000004
+
+#define ADDRH						0x02 /* R/W mask 0x0000FFFFUL */
+#define ADDRL						0x03 /* R/W mask 0xFFFFFFFFUL */
+#define HASHH						0x04 /* R/W */
+#define HASHL						0x05 /* R/W */
+
+#define MII_ACC						0x06 /* R/W */
+#define MII_ACC_PHY_ADDR_				0x0000F800
+#define MII_ACC_MIIRINDA_				0x000007C0
+#define MII_ACC_MII_WRITE_				0x00000002
+#define MII_ACC_MII_BUSY_				0x00000001
+
+#define MII_DATA					0x07	/* R/W mask 0x0000FFFFUL */
+
+#define FLOW						0x08	/* R/W */
+#define FLOW_FCPT_					0xFFFF0000
+#define FLOW_FCPASS_					0x00000004
+#define FLOW_FCEN_					0x00000002
+#define FLOW_FCBSY_					0x00000001
+
+#define VLAN1						0x09	/* R/W mask 0x0000FFFFUL */
+#define VLAN2						0x0A	/* R/W mask 0x0000FFFFUL */
+
+#define WUFF						0x0B	/* WO */
+
+#define WUCSR						0x0C	/* R/W */
+#define WUCSR_GUE_					0x00000200
+#define WUCSR_WUFR_					0x00000040
+#define WUCSR_MPR_					0x00000020
+#define WUCSR_WAKE_EN_					0x00000004
+#define WUCSR_MPEN_					0x00000002
+
+/*
+ * Phy register offsets and bit definitions
+ */
+#define LAN9118_PHY_ID					0x00C0001C
+
+#define PHY_BCR						0
+#define PHY_BCR_RESET_					0x8000
+#define PHY_BCR_SPEED_SELECT_				0x2000
+#define PHY_BCR_AUTO_NEG_ENABLE_			0x1000
+#define PHY_BCR_RESTART_AUTO_NEG_			0x0200
+#define PHY_BCR_DUPLEX_MODE_				0x0100
+
+#define PHY_BSR						1
+#define PHY_BSR_LINK_STATUS_				0x0004
+#define PHY_BSR_REMOTE_FAULT_				0x0010
+#define PHY_BSR_AUTO_NEG_COMP_				0x0020
+
+#define PHY_ID_1					2
+#define PHY_ID_2					3
+
+#define PHY_ANEG_ADV					4
+#define PHY_ANEG_ADV_PAUSE_				0x0C00
+#define PHY_ANEG_ADV_ASYMP_				0x0800
+#define PHY_ANEG_ADV_SYMP_				0x0400
+#define PHY_ANEG_ADV_10H_				0x020
+#define PHY_ANEG_ADV_10F_				0x040
+#define PHY_ANEG_ADV_100H_				0x080
+#define PHY_ANEG_ADV_100F_				0x100
+#define PHY_ANEG_ADV_SPEED_				0x1E0
+
+#define PHY_ANEG_LPA					5
+#define PHY_ANEG_LPA_ASYMP_				0x0800
+#define PHY_ANEG_LPA_SYMP_				0x0400
+#define PHY_ANEG_LPA_100FDX_				0x0100
+#define PHY_ANEG_LPA_100HDX_				0x0080
+#define PHY_ANEG_LPA_10FDX_				0x0040
+#define PHY_ANEG_LPA_10HDX_				0x0020
+
+/* Mode Control/Status Register */
+#define PHY_MODE_CTRL_STS				17
+#define MODE_CTRL_STS_EDPWRDOWN_			0x2000
+#define MODE_CTRL_STS_ENERGYON_				0x0002
+
+#define PHY_INT_SRC					29
+#define PHY_INT_SRC_ENERGY_ON_				0x0080
+#define PHY_INT_SRC_ANEG_COMP_				0x0040
+#define PHY_INT_SRC_REMOTE_FAULT_			0x0020
+#define PHY_INT_SRC_LINK_DOWN_				0x0010
+
+#define PHY_INT_MASK					30
+#define PHY_INT_MASK_ENERGY_ON_				0x0080
+#define PHY_INT_MASK_ANEG_COMP_				0x0040
+#define PHY_INT_MASK_REMOTE_FAULT_			0x0020
+#define PHY_INT_MASK_LINK_DOWN_				0x0010
+
+#define PHY_SPECIAL					31
+#define PHY_SPECIAL_SPD_				0x001C
+#define PHY_SPECIAL_SPD_10HALF_				0x0004
+#define PHY_SPECIAL_SPD_10FULL_				0x0014
+#define PHY_SPECIAL_SPD_100HALF_			0x0008
+#define PHY_SPECIAL_SPD_100FULL_			0x0018
+
+#endif				/* __SMSC911X_H__ */
-- 
1.4.0

