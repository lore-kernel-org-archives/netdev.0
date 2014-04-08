From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2/2] FDDI: DEC FDDIcontroller 700 TURBOchannel card support
Date: Tue, 8 Apr 2014 13:20:26 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1404080028140.26128@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1404080022120.26128@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:49249 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756227AbaDHMU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 08:20:27 -0400
Received: from localhost.localdomain ([127.0.0.1]:39863 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6822541AbaDHMU0Z5bGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 14:20:26 +0200
In-Reply-To: <alpine.LFD.2.11.1404080022120.26128@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the DEC FDDIcontroller 700 (DEFZA), DEC's 
first-generation FDDI network interface adapter, made for TURBOchannel and 
based on a discrete version of what eventually became Motorola's widely 
used CAMEL chipset.  The CAMEL chipset is present for example in the DEC 
FDDIcontroller TURBOchannel, EISA and PCI adapters (DEFTA/DEFEA/DEFPA) 
that we support with the defxx driver, however the host bus interface 
logic and the firmware API are different in the DEFZA and hence a separate 
driver is required.

There isn't much to say about the driver except that it works, but there 
is one peculiarity to mention.  The adapter implements two Tx/Rx queue 
pairs.  Of these one pair is used by hardware to exchange frames with the 
ring.  The other pair is used for SMT frames only, any SMT frame received 
by hardware on the Rx queue must be queued back by the driver to the SMT 
Rx queue for the firmware to process.  Likewise the SMT Tx queue presents 
the driver with SMT frames produced by the firmware that must be queued 
back to the Tx queue for hardware to put on the ring.  This solution was 
chosen because the designers ran out of PCB space and could not squeeze in 
more logic to handle this SMT frame traffic without the need to involve 
the driver as with the later DEFTA/DEFEA/DEFPA adapters.

For this reason the driver has frames in the transmit path that it wants 
to present to network taps (e.g. `tcpdump') but not the normal receive 
queue.  This in turn requires that ptype_all and dev_queue_xmit_nit 
symbols are exported.

Finally the driver does some Frame Control byte decoding so to avoid magic 
numbers some macros are added to <linux/if_fddi.h>.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
Dave,

 Please apply.  I hope the way I hooked to ptype_all and 
dev_queue_xmit_nit is fine; let me know if you prefer to use 
EXPORT_SYMBOL_GPL instead.

 This driver could benefit from some improvement, in particular the 
interrupt handler should be split and use a thread rather than doing all 
the stuff in the hardirq, but let's not make better the enemy of good.  
I've been sitting on this driver for too long already.

 There are some warnings with this driver and checkpatch.pl; I consider 
them all noise and deliberately ignored, but please let me know if you'd 
rather see any of them silenced.

 Thanks,

  Maciej

linux-defza-1.1.3.patch
Index: net-20140407-4maxp64/Documentation/networking/00-INDEX
===================================================================
--- net-20140407-4maxp64.orig/Documentation/networking/00-INDEX
+++ net-20140407-4maxp64/Documentation/networking/00-INDEX
@@ -58,6 +58,8 @@ de4x5.txt
 	- the Digital EtherWORKS DE4?? and DE5?? PCI Ethernet driver
 decnet.txt
 	- info on using the DECnet networking layer in Linux.
+defza.txt
+	- the DEC FDDIcontroller 700 (DEFZA-xx) TURBOchannel FDDI driver
 dl2k.txt
 	- README for D-Link DL2000-based Gigabit Ethernet Adapters (dl2k.ko).
 dm9000.txt
Index: net-20140407-4maxp64/Documentation/networking/defza.txt
===================================================================
--- /dev/null
+++ net-20140407-4maxp64/Documentation/networking/defza.txt
@@ -0,0 +1,53 @@
+Notes on the DEC FDDIcontroller 700 (DEFZA-xx) driver v.1.1.3.
+
+
+ DEC FDDIcontroller 700 is the DEC's first-generation
+TURBOchannel FDDI network card, designed in 1990 specifically
+for the DECstation 5000 model 200 workstation.  The board is a
+single attachment station and it was manufactured in two
+variations, the SAS/MMF DEFZA-AA -- the original design, with
+ST connectors -- and the SAS/STP DEFZA-CA -- denoted 700C, with
+a DE9 and a BNC connector (a part of a DEC proprietary PMD that
+can interface to a DECconcentrator 500).  The driver supports
+both kinds of cards, but it was tested with DEFZA-AA boards
+only.
+
+ The driver handles any number of cards installed in a single
+system.  They get fddi0, fddi1, etc. interface names assigned
+in the order of increasing TURBOchannel slot numbers.
+
+ The board only supports DMA on the receive side.  Transmits
+must use PIO.  As a result the impact of transmits on system
+performance is significant.
+
+ The board supports a 64-entry CAM for matching destination
+addresses.  Two entries are preoccupied by the Directed Beacon
+and Ring Purger multicast addresses and the rest is used as a
+multicast filter.  An all-multi mode is also supported for LLC
+frames and it is used if requested explicitly or if the CAM
+overflows.  The promiscuous mode supports separate enables for
+LLC and SMT frames, but the driver doesn't support changing
+them individually.
+
+
+Known problems:
+
+ None.
+
+
+To do:
+
+ 5. MAC address change.  The card does not support changing the
+Media Access Controller's address registers but a similar effect
+can be achieved by adding an alias to the CAM.  There is no way
+to disable matching against the original address.
+
+ 7. Queueing incoming/outgoing SMT frames in the driver if the
+SMT receive/RMC transmit ring is full. (?)
+
+ 8. Retrieving/reporting FDDI/SNMP stats.
+
+ Both success and failure reports are welcome.  In particular I
+would be pleased to hear from a DEFZA-CA user.
+
+  Maciej W. Rozycki  <macro@linux-mips.org>
Index: net-20140407-4maxp64/MAINTAINERS
===================================================================
--- net-20140407-4maxp64.orig/MAINTAINERS
+++ net-20140407-4maxp64/MAINTAINERS
@@ -2663,6 +2663,11 @@ M:	"Maciej W. Rozycki" <macro@linux-mips
 S:	Maintained
 F:	drivers/net/fddi/defxx.*
 
+DEFZA FDDI NETWORK DRIVER
+M:	"Maciej W. Rozycki" <macro@linux-mips.org>
+S:	Maintained
+F:	drivers/net/fddi/defza.*
+
 DELL LAPTOP DRIVER
 M:	Matthew Garrett <mjg59@srcf.ucam.org>
 L:	platform-driver-x86@vger.kernel.org
Index: net-20140407-4maxp64/drivers/net/fddi/Kconfig
===================================================================
--- net-20140407-4maxp64.orig/drivers/net/fddi/Kconfig
+++ net-20140407-4maxp64/drivers/net/fddi/Kconfig
@@ -15,6 +15,17 @@ config FDDI
 
 if FDDI
 
+config DEFZA
+	tristate "DEC FDDIcontroller 700/700C (DEFZA-xx) support"
+	depends on FDDI && TC
+	---help---
+	  This is support for the DEC FDDIcontroller 700 (DEFZA-AA, fiber)
+	  and 700C (DEFZA-CA, copper) TURBOchannel network cards which can
+	  connect you to a local FDDI network.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called defza.  If unsure, say N.
+
 config DEFXX
 	tristate "Digital DEFTA/DEFEA/DEFPA adapter support"
 	depends on FDDI && (PCI || EISA || TC)
Index: net-20140407-4maxp64/drivers/net/fddi/Makefile
===================================================================
--- net-20140407-4maxp64.orig/drivers/net/fddi/Makefile
+++ net-20140407-4maxp64/drivers/net/fddi/Makefile
@@ -3,4 +3,5 @@
 #
 
 obj-$(CONFIG_DEFXX) += defxx.o
+obj-$(CONFIG_DEFZA) += defza.o
 obj-$(CONFIG_SKFP) += skfp/
Index: net-20140407-4maxp64/drivers/net/fddi/defza.c
===================================================================
--- /dev/null
+++ net-20140407-4maxp64/drivers/net/fddi/defza.c
@@ -0,0 +1,1639 @@
+/*	FDDI network adapter driver for DEC FDDIcontroller 700/700C devices.
+ *
+ *	Copyright (c) 2014  Maciej W. Rozycki
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	References:
+ *
+ *	Dave Sawyer & Phil Weeks & Frank Itkowsky,
+ *	"DEC FDDIcontroller 700 Port Specification",
+ *	Revision 1.1, Digital Equipment Corporation
+ */
+
+
+/* ------------------------------------------------------------------------- */
+/* FZA configurable parameters.                                              */
+
+/* The number of transmit ring descriptors; either 0 for 512 or 1 for 1024.  */
+#define FZA_RING_TX_MODE 0
+
+/* The number of receive ring descriptors; from 2 up to 256.  */
+#define FZA_RING_RX_SIZE 256
+
+/* Define it for debugging messages.  */
+#undef DEBUG
+
+/* End of FZA configurable parameters.  No need to change anything below.    */
+/* ------------------------------------------------------------------------- */
+
+
+#include <linux/delay.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/fddidevice.h>
+#include <linux/sched.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/stat.h>
+#include <linux/tc.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+#include <linux/wait.h>
+
+#include "defza.h"
+
+#ifdef DEBUG
+# define mb_debug() mb()
+#else
+# define mb_debug()
+#endif
+
+#define DRV_NAME "defza"
+#define DRV_VERSION "v.1.1.3"
+#define DRV_RELDATE "Apr  5 2014"
+
+static char version[] =
+	DRV_NAME ": " DRV_VERSION "  " DRV_RELDATE "  Maciej W. Rozycki\n";
+
+MODULE_AUTHOR("Maciej W. Rozycki <macro@linux-mips.org>");
+MODULE_DESCRIPTION("DEC FDDIcontroller 700 (DEFZA-xx) driver");
+MODULE_LICENSE("GPL");
+
+static int loopback;
+module_param(loopback, int, S_IRUGO | S_IWUSR);
+
+/* Ring Purger Multicast */
+static u8 hw_addr_purger[8] = { 0x09, 0x00, 0x2b, 0x02, 0x01, 0x05 };
+/* Directed Beacon Multicast */
+static u8 hw_addr_beacon[8] = { 0x01, 0x80, 0xc2, 0x00, 0x01, 0x00 };
+
+
+static inline struct sk_buff *fza_alloc_skb_irq(struct net_device *dev,
+						unsigned int length)
+{
+	return __netdev_alloc_skb(dev, length, GFP_ATOMIC);
+}
+
+static inline struct sk_buff *fza_alloc_skb(struct net_device *dev,
+					    unsigned int length)
+{
+	return __netdev_alloc_skb(dev, length, GFP_KERNEL);
+}
+
+static inline void fza_skb_align(struct sk_buff *skb, unsigned int v)
+{
+	unsigned long int x, y;
+
+	x = (unsigned long int)skb->data;
+	y = ALIGN(x, v);
+
+	skb_reserve(skb, y - x);
+}
+
+static inline void fza_reads(const void __iomem *from, void *to,
+			     unsigned long size)
+{
+	if (sizeof(unsigned long) == 8) {
+		const u64 __iomem *src = from;
+		const u32 __iomem *src_trail;
+		u64 *dst = to;
+		u32 *dst_trail;
+
+		for (size = (size + 3) / 4; size > 1; size -= 2)
+			*dst++ = readq(src++);
+		if (size) {
+			src_trail = (u32 __iomem *)src;
+			dst_trail = (u32 *)dst;
+			*dst_trail = readl(src_trail);
+		}
+	} else {
+		const u32 __iomem *src = from;
+		u32 *dst = to;
+
+		for (size = (size + 3) / 4; size; size--)
+			*dst++ = readl(src++);
+	}
+}
+
+static inline void fza_writes(const void *from, void __iomem *to,
+			      unsigned long size)
+{
+	if (sizeof(unsigned long) == 8) {
+		const u64 *src = from;
+		const u32 *src_trail;
+		u64 __iomem *dst = to;
+		u32 __iomem *dst_trail;
+
+		for (size = (size + 3) / 4; size > 1; size -= 2)
+			writeq(*src++, dst++);
+		if (size) {
+			src_trail = (u32 *)src;
+			dst_trail = (u32 __iomem *)dst;
+			writel(*src_trail, dst_trail);
+		}
+	} else {
+		const u32 *src = from;
+		u32 __iomem *dst = to;
+
+		for (size = (size + 3) / 4; size; size--)
+			writel(*src++, dst++);
+	}
+}
+
+static inline void fza_moves(const void __iomem *from, void __iomem *to,
+			     unsigned long size)
+{
+	if (sizeof(unsigned long) == 8) {
+		const u64 __iomem *src = from;
+		const u32 __iomem *src_trail;
+		u64 __iomem *dst = to;
+		u32 __iomem *dst_trail;
+
+		for (size = (size + 3) / 4; size > 1; size -= 2)
+			writeq(readq(src++), dst++);
+		if (size) {
+			src_trail = (u32 __iomem *)src;
+			dst_trail = (u32 __iomem *)dst;
+			writel(readl(src_trail), dst_trail);
+		}
+	} else {
+		const u32 __iomem *src = from;
+		u32 __iomem *dst = to;
+
+		for (size = (size + 3) / 4; size; size--)
+			writel(readl(src++), dst++);
+	}
+}
+
+static inline void fza_zeros(void __iomem *to, unsigned long size)
+{
+	if (sizeof(unsigned long) == 8) {
+		u64 __iomem *dst = to;
+		u32 __iomem *dst_trail;
+
+		for (size = (size + 3) / 4; size > 1; size -= 2)
+			writeq(0, dst++);
+		if (size) {
+			dst_trail = (u32 __iomem *)dst;
+			writel(0, dst_trail);
+		}
+	} else {
+		u32 __iomem *dst = to;
+
+		for (size = (size + 3) / 4; size; size--)
+			writel(0, dst++);
+	}
+}
+
+
+static inline void fza_regs_dump(struct fza_private *fp)
+{
+	mb_debug();
+	pr_debug("%s: iomem registers:\n", fp->name);
+	pr_debug(" reset:           0x%04x\n", readw(&fp->regs->reset));
+	pr_debug(" interrupt event: 0x%04x\n", readw(&fp->regs->int_event));
+	pr_debug(" status:          0x%04x\n", readw(&fp->regs->status));
+	pr_debug(" interrupt mask:  0x%04x\n", readw(&fp->regs->int_mask));
+	pr_debug(" control A:       0x%04x\n", readw(&fp->regs->control_a));
+	pr_debug(" control B:       0x%04x\n", readw(&fp->regs->control_b));
+}
+
+
+static inline void fza_do_reset(struct fza_private *fp)
+{
+	/* Reset the board. */
+	wmb();
+	writew(FZA_RESET_INIT, &fp->regs->reset);
+	iob();
+	readw(&fp->regs->reset);	/* Read it back for a small delay. */
+	iob();
+	writew(FZA_RESET_CLR, &fp->regs->reset);
+
+	/* Enable all interrupt events we handle. */
+	wmb();
+	writew(fp->int_mask, &fp->regs->int_mask);
+	iob();
+}
+
+static inline void fza_do_shutdown(struct fza_private *fp)
+{
+	/* Disable the driver mode. */
+	wmb();
+	writew(FZA_CONTROL_B_IDLE, &fp->regs->control_b);
+
+	/* And reset the board. */
+	wmb();
+	writew(FZA_RESET_INIT, &fp->regs->reset);
+	iob();
+	writew(FZA_RESET_CLR, &fp->regs->reset);
+	iob();
+}
+
+static int fza_reset(struct fza_private *fp)
+{
+	uint status, state;
+
+	unsigned long int flags;
+	long int t;
+
+
+	pr_info("%s: resetting the board...\n", fp->name);
+
+	spin_lock_irqsave(&fp->lock, flags);
+	fp->state_chg_flag = 0;
+	fza_do_reset(fp);
+	spin_unlock_irqrestore(&fp->lock, flags);
+
+	/* DEC says RESET needs up to 30 seconds to complete.  My DEFZA-AA
+	 * rev. C03 happily finishes in 9.7 seconds. :-)  But we need to
+	 * be on the safe side...
+	 */
+	t = wait_event_timeout(fp->state_chg_wait, fp->state_chg_flag,
+			       45 * HZ);
+	status = readw(&fp->regs->status);
+	state = FZA_STATUS_GET_STATE(status);
+	if (fp->state_chg_flag == 0) {
+		pr_err("%s: RESET timed out!, state %x\n", fp->name, state);
+		return -EIO;
+	}
+	if (state != FZA_STATE_UNINITIALIZED) {
+		pr_err("%s: RESET failed!, state %x, failure ID %x\n",
+		       fp->name, state, FZA_STATUS_GET_TEST(status));
+		return -EIO;
+	}
+	pr_info("%s: OK\n", fp->name);
+	pr_debug("%s: RESET: %lums elapsed\n", fp->name,
+		 (45 * HZ - t) * 1000 / HZ);
+
+	return 0;
+}
+
+
+static struct fza_ring_cmd __iomem *fza_cmd_send(struct net_device *dev,
+						 int command)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	unsigned int old_mask, new_mask;
+	struct fza_ring_cmd __iomem *ring = fp->ring_cmd + fp->ring_cmd_index;
+	union fza_cmd_buf __iomem *buf;
+
+	struct netdev_hw_addr *ha;
+	int i;
+
+
+	old_mask = fp->int_mask;
+	new_mask = old_mask & ~FZA_MASK_STATE_CHG;
+	writew(new_mask, &fp->regs->int_mask);
+	iob();
+	fp->int_mask = new_mask;
+
+	buf = fp->mmio + readl(&ring->buffer);
+
+	if ((readl(&ring->cmd_own) & FZA_RING_OWN_MASK) != FZA_RING_OWN_HOST) {
+		pr_warn("%s: command buffer full, command: %u!\n", fp->name,
+			command);
+		return NULL;
+	}
+
+	switch (command) {
+
+	case FZA_RING_CMD_INIT:
+		writel(FZA_RING_TX_MODE, &buf->init.tx_mode);
+		writel(FZA_RING_RX_SIZE, &buf->init.hst_rx_size);
+		fza_zeros(&buf->init.counters, sizeof(buf->init.counters));
+		break;
+
+	case FZA_RING_CMD_MODCAM:
+		i = 0;
+		fza_writes(&hw_addr_purger, &buf->cam.hw_addr[i++],
+			   sizeof(*buf->cam.hw_addr));
+		fza_writes(&hw_addr_beacon, &buf->cam.hw_addr[i++],
+			   sizeof(*buf->cam.hw_addr));
+		netdev_for_each_mc_addr(ha, dev) {
+			if (i >= FZA_CMD_CAM_SIZE)
+				break;
+			fza_writes(ha->addr, &buf->cam.hw_addr[i++],
+				   sizeof(*buf->cam.hw_addr));
+		}
+		while (i < FZA_CMD_CAM_SIZE)
+			fza_zeros(&buf->cam.hw_addr[i++],
+				  sizeof(*buf->cam.hw_addr));
+		break;
+
+	case FZA_RING_CMD_PARAM:
+		writel(loopback, &buf->param.loop_mode);
+		writel(fp->t_max, &buf->param.t_max);
+		writel(fp->t_req, &buf->param.t_req);
+		writel(fp->tvx, &buf->param.tvx);
+		writel(fp->lem_threshold, &buf->param.lem_threshold);
+		fza_writes(&fp->station_id, &buf->param.station_id,
+			   sizeof(buf->param.station_id));
+		/* Convert to milliseconds due to buggy firmware. */
+		writel(fp->rtoken_timeout / 12500, &buf->param.rtoken_timeout);
+		writel(fp->ring_purger, &buf->param.ring_purger);
+		break;
+
+	case FZA_RING_CMD_MODPROM:
+		if (dev->flags & IFF_PROMISC) {
+			writel(1, &buf->modprom.llc_prom);
+			writel(1, &buf->modprom.smt_prom);
+		} else {
+			writel(0, &buf->modprom.llc_prom);
+			writel(0, &buf->modprom.smt_prom);
+		}
+		if (dev->flags & IFF_ALLMULTI ||
+		    netdev_mc_count(dev) > FZA_CMD_CAM_SIZE - 2)
+			writel(1, &buf->modprom.llc_multi);
+		else
+			writel(0, &buf->modprom.llc_multi);
+		writel(1, &buf->modprom.llc_bcast);
+		break;
+
+	}
+
+	/* Trigger the command. */
+	writel(FZA_RING_OWN_FZA | command, &ring->cmd_own);
+	wmb();
+	writew(FZA_CONTROL_A_CMD_POLL, &fp->regs->control_a);
+
+	fp->ring_cmd_index = (fp->ring_cmd_index + 1) % FZA_RING_CMD_SIZE;
+
+	fp->int_mask = old_mask;
+	writew(fp->int_mask, &fp->regs->int_mask);
+
+	return ring;
+}
+
+
+static int fza_init_send(struct net_device *dev,
+			 struct fza_cmd_init *__iomem *init)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	struct fza_ring_cmd __iomem *ring;
+
+	unsigned long int flags;
+	long int t;
+	u32 stat;
+
+
+	spin_lock_irqsave(&fp->lock, flags);
+	fp->cmd_done_flag = 0;
+	ring = fza_cmd_send(dev, FZA_RING_CMD_INIT);
+	spin_unlock_irqrestore(&fp->lock, flags);
+	if (ring == NULL)
+		/* This should never happen in the uninitialized state,
+		 * so do not try to recover and just consider it fatal.
+		 */
+		return -ENOBUFS;
+
+	/* INIT may take quite a long time (160ms for my C03). */
+	t = wait_event_timeout(fp->cmd_done_wait, fp->cmd_done_flag, 3 * HZ);
+	if (fp->cmd_done_flag == 0) {
+		pr_err("%s: INIT command timed out!, state %x\n", fp->name,
+		       FZA_STATUS_GET_STATE(readw(&fp->regs->status)));
+		return -EIO;
+	}
+	stat = readl(&ring->stat);
+	if (stat != FZA_RING_STAT_SUCCESS) {
+		pr_err("%s: INIT command failed!, status %02x, state %x\n",
+		       fp->name, stat,
+		       FZA_STATUS_GET_STATE(readw(&fp->regs->status)));
+		return -EIO;
+	}
+	pr_debug("%s: INIT: %lums elapsed\n", fp->name,
+		 (3 * HZ - t) * 1000 / HZ);
+
+	if (init)
+		*init = fp->mmio + readl(&ring->buffer);
+	return 0;
+}
+
+
+static void fza_rx_init(struct fza_private *fp)
+{
+	int i;
+
+	/* Fill the host receive descriptor ring. */
+	for (i = 0; i < FZA_RING_RX_SIZE; i++) {
+		wmb();
+		writel(0, &fp->ring_hst_rx[i].rmc);
+		wmb();
+		writel((fp->rx_dma[i] + 0x1000) >> 9,
+		       &fp->ring_hst_rx[i].buffer1);
+		wmb();
+		writel(fp->rx_dma[i] >> 9 | FZA_RING_OWN_FZA,
+		       &fp->ring_hst_rx[i].buf0_own);
+	}
+}
+
+
+static void fza_set_rx_mode(struct net_device *dev)
+{
+	fza_cmd_send(dev, FZA_RING_CMD_MODCAM);
+	fza_cmd_send(dev, FZA_RING_CMD_MODPROM);
+}
+
+
+union fza_buffer_txp {
+	struct fza_buffer_tx *data_ptr;
+	struct fza_buffer_tx __iomem *mmio_ptr;
+};
+
+static int fza_do_xmit(union fza_buffer_txp ub, int len,
+		       struct net_device *dev, int smt)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	int i, first, frag_len, left_len;
+	u32 own, rmc;
+	struct fza_buffer_tx __iomem *rmc_tx_ptr;
+
+
+	if ((((fp->ring_rmc_txd_index - 1 + fp->ring_rmc_tx_size) -
+	      fp->ring_rmc_tx_index) % fp->ring_rmc_tx_size) *
+	    FZA_TX_BUFFER_SIZE < len)
+		return 1;
+
+	first = fp->ring_rmc_tx_index;
+
+	left_len = len;
+	frag_len = FZA_TX_BUFFER_SIZE;
+	/* First descriptor is relinquished last. */
+	own = FZA_RING_TX_OWN_HOST;
+	/* First descriptor carries frame length; we don't use cut-through. */
+	rmc = FZA_RING_TX_SOP | FZA_RING_TX_VBC | len;
+	do {
+		i = fp->ring_rmc_tx_index;
+		rmc_tx_ptr = &fp->buffer_tx[i];
+
+		if (left_len < FZA_TX_BUFFER_SIZE)
+			frag_len = left_len;
+		left_len -= frag_len;
+
+		/* Length must be a multiple of 4 as only word writes are
+		 * permitted!
+		 */
+		frag_len = (frag_len + 3) & ~3;
+		if (smt)
+			fza_moves(ub.mmio_ptr, rmc_tx_ptr, frag_len);
+		else
+			fza_writes(ub.data_ptr, rmc_tx_ptr, frag_len);
+
+		if (left_len == 0)
+			rmc |= FZA_RING_TX_EOP;		/* mark last frag */
+
+		wmb();
+		writel(rmc, &fp->ring_rmc_tx[i].rmc);
+		wmb();
+		writel(own, &fp->ring_rmc_tx[i].own);
+
+		ub.data_ptr++;
+		fp->ring_rmc_tx_index = (fp->ring_rmc_tx_index + 1) %
+					fp->ring_rmc_tx_size;
+
+		/* Settings for intermediate frags. */
+		own = FZA_RING_TX_OWN_RMC;
+		rmc = 0;
+	} while (left_len > 0);
+
+	if ((((fp->ring_rmc_txd_index - 1 + fp->ring_rmc_tx_size) -
+	      fp->ring_rmc_tx_index) % fp->ring_rmc_tx_size) *
+	    FZA_TX_BUFFER_SIZE < dev->mtu + dev->hard_header_len) {
+		netif_stop_queue(dev);
+		pr_debug("%s: queue stopped\n", fp->name);
+	}
+
+	wmb();
+	writel(FZA_RING_TX_OWN_RMC, &fp->ring_rmc_tx[first].own);
+
+	wmb();
+	writew(FZA_CONTROL_A_TX_POLL, &fp->regs->control_a); /* go, go, go! */
+
+	return 0;
+}
+
+
+static int fza_do_recv_smt(struct fza_buffer_tx *data_ptr, int len,
+			   u32 rmc, struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	struct fza_buffer_tx __iomem *smt_rx_ptr;
+	u32 own;
+	int i;
+
+	i = fp->ring_smt_rx_index;
+	mb();
+	own = readl(&fp->ring_smt_rx[i].own);
+	if ((own & FZA_RING_OWN_MASK) == FZA_RING_OWN_FZA)
+		return 1;
+
+	smt_rx_ptr = fp->mmio + readl(&fp->ring_smt_rx[i].buffer);
+
+	/* Length must be a multiple of 4 as only word writes are permitted! */
+	fza_writes(data_ptr, smt_rx_ptr, (len + 3) & ~3);
+
+	wmb();
+	writel(rmc, &fp->ring_smt_rx[i].rmc);
+	wmb();
+	writel(FZA_RING_OWN_FZA, &fp->ring_smt_rx[i].own);
+
+	fp->ring_smt_rx_index =
+		(fp->ring_smt_rx_index + 1) % fp->ring_smt_rx_size;
+
+	wmb();
+	writew(FZA_CONTROL_A_SMT_RX_POLL, &fp->regs->control_a); /* grab it! */
+
+	return 0;
+}
+
+
+static void fza_tx(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	u32 own, rmc;
+	int i;
+
+	while (1) {
+		i = fp->ring_rmc_txd_index;
+		mb();
+		if (i == fp->ring_rmc_tx_index)
+			break;
+		own = readl(&fp->ring_rmc_tx[i].own);
+		if ((own & FZA_RING_OWN_MASK) == FZA_RING_TX_OWN_RMC)
+			break;
+
+		rmc = readl(&fp->ring_rmc_tx[i].rmc);
+		/* Only process the first descriptor. */
+		if ((rmc & FZA_RING_TX_SOP) != 0) {
+			if ((rmc & FZA_RING_TX_DCC_MASK) ==
+			    FZA_RING_TX_DCC_SUCCESS) {
+				int pkt_len = (rmc & FZA_RING_PBC_MASK) - 3;
+								/* Omit PRH. */
+
+				fp->stats.tx_packets++;
+				fp->stats.tx_bytes += pkt_len;
+			} else {
+				fp->stats.tx_errors++;
+				switch (rmc & FZA_RING_TX_DCC_MASK) {
+				case FZA_RING_TX_DCC_DTP_SOP:
+				case FZA_RING_TX_DCC_DTP:
+				case FZA_RING_TX_DCC_ABORT:
+					fp->stats.tx_aborted_errors++;
+					break;
+				case FZA_RING_TX_DCC_UNDRRUN:
+					fp->stats.tx_fifo_errors++;
+					break;
+				case FZA_RING_TX_DCC_PARITY:
+				default:
+					break;
+				}
+			}
+		}
+
+		fp->ring_rmc_txd_index = (fp->ring_rmc_txd_index + 1) %
+					 fp->ring_rmc_tx_size;
+	}
+
+	if ((((fp->ring_rmc_txd_index - 1 + fp->ring_rmc_tx_size) -
+	      fp->ring_rmc_tx_index) % fp->ring_rmc_tx_size) *
+	    FZA_TX_BUFFER_SIZE >= dev->mtu + dev->hard_header_len) {
+		if (fp->queue_active) {
+			netif_wake_queue(dev);
+			pr_debug("%s: queue waked\n", fp->name);
+		}
+	}
+}
+
+static inline int fza_rx_err(struct fza_private *fp,
+			     const u32 rmc, const u8 fc)
+{
+	int len, min_len, max_len;
+
+	len = rmc & FZA_RING_PBC_MASK;
+
+	if (unlikely((rmc & FZA_RING_RX_BAD) != 0)) {
+		fp->stats.rx_errors++;
+
+		/* Check special status codes. */
+		if ((rmc & (FZA_RING_RX_CRC | FZA_RING_RX_RRR_MASK |
+			    FZA_RING_RX_DA_MASK | FZA_RING_RX_SA_MASK)) ==
+		     (FZA_RING_RX_CRC | FZA_RING_RX_RRR_DADDR |
+		      FZA_RING_RX_DA_CAM | FZA_RING_RX_SA_ALIAS)) {
+			if (len >= 8190)
+				fp->stats.rx_length_errors++;
+			return 1;
+		}
+		if ((rmc & (FZA_RING_RX_CRC | FZA_RING_RX_RRR_MASK |
+			    FZA_RING_RX_DA_MASK | FZA_RING_RX_SA_MASK)) ==
+		     (FZA_RING_RX_CRC | FZA_RING_RX_RRR_DADDR |
+		      FZA_RING_RX_DA_CAM | FZA_RING_RX_SA_CAM)) {
+			/* Halt the interface to trigger a reset. */
+			mb();
+			writew(FZA_CONTROL_A_HALT, &fp->regs->control_a);
+			iob();
+			return 1;
+		}
+
+		/* Check the MAC status. */
+		switch (rmc & FZA_RING_RX_RRR_MASK) {
+		case FZA_RING_RX_RRR_OK:
+			if ((rmc & FZA_RING_RX_CRC) != 0)
+				fp->stats.rx_crc_errors++;
+			else if ((rmc & FZA_RING_RX_FSC_MASK) == 0 ||
+				 (rmc & FZA_RING_RX_FSB_ERR) != 0)
+				fp->stats.rx_frame_errors++;
+			return 1;
+		case FZA_RING_RX_RRR_SADDR:
+		case FZA_RING_RX_RRR_DADDR:
+		case FZA_RING_RX_RRR_ABORT:
+			/* Halt the interface to trigger a reset. */
+			mb();
+			writew(FZA_CONTROL_A_HALT, &fp->regs->control_a);
+			iob();
+			return 1;
+		case FZA_RING_RX_RRR_LENGTH:
+			fp->stats.rx_frame_errors++;
+			return 1;
+		default:
+			return 1;
+		}
+	}
+
+	/* Packet received successfully; validate the length. */
+	switch (fc & FDDI_FC_K_FORMAT_MASK) {
+	case FDDI_FC_K_FORMAT_MANAGEMENT:
+		if ((fc & FDDI_FC_K_CLASS_MASK) == FDDI_FC_K_CLASS_ASYNC)
+			min_len = 37;
+		else
+			min_len = 17;
+		break;
+	case FDDI_FC_K_FORMAT_LLC:
+		min_len = 20;
+		break;
+	default:
+		min_len = 17;
+		break;
+	}
+	max_len = 4495;
+	if (len < min_len || len > max_len) {
+		fp->stats.rx_errors++;
+		fp->stats.rx_length_errors++;
+		return 1;
+	}
+
+	return 0;
+}
+
+static void fza_rx(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	struct fza_fddihdr *frame;
+	int i, len;
+	u8 fc;
+
+	struct sk_buff *skb, *newskb;
+	dma_addr_t dma, newdma;
+	u32 own, rmc, buf;
+
+	while (1) {
+		i = fp->ring_hst_rx_index;
+		mb();
+		own = readl(&fp->ring_hst_rx[i].buf0_own);
+		if ((own & FZA_RING_OWN_MASK) == FZA_RING_OWN_FZA)
+			break;
+
+		rmc = readl(&fp->ring_hst_rx[i].rmc);
+		skb = fp->rx_skbuff[i];
+		dma = fp->rx_dma[i];
+
+		/* The RMC doesn't count the preamble and the starting
+		 * delimiter.  We fix it up here for a total of 3 octets.
+		 */
+		mb();
+		len = (rmc & FZA_RING_PBC_MASK) + 3;
+		frame = (struct fza_fddihdr *)skb->data;
+
+		/* We need to get at real FC. */
+		dma_sync_single_for_cpu(fp->bdev,
+					dma +
+					((u8 *)&frame->hdr.fc - (u8 *)frame),
+					sizeof(frame->hdr.fc),
+					DMA_FROM_DEVICE);
+		fc = frame->hdr.fc;
+
+		if (fza_rx_err(fp, rmc, fc))
+			goto err_rx;
+
+		/* We have to 512-byte-align RX buffers... */
+		newskb = fza_alloc_skb_irq(dev, FZA_RX_BUFFER_SIZE + 511);
+		if (newskb != NULL) {
+			fza_skb_align(newskb, 512);
+			newdma = dma_map_single(fp->bdev, newskb->data,
+						FZA_RX_BUFFER_SIZE,
+						DMA_FROM_DEVICE);
+			if (dma_mapping_error(fp->bdev, newdma)) {
+				dev_kfree_skb_irq(newskb);
+				newskb = NULL;
+			}
+		}
+		if (newskb != NULL) {
+			int pkt_len = len - 7;	/* omit P, SD and FCS */
+			int is_multi;
+			int rx_stat;
+
+			dma_unmap_single(fp->bdev, dma, FZA_RX_BUFFER_SIZE,
+					 DMA_FROM_DEVICE);
+
+			/* Queue SMT frames to the SMT receive ring. */
+			if ((fc & (FDDI_FC_K_CLASS_MASK |
+				   FDDI_FC_K_FORMAT_MASK)) ==
+			     (FDDI_FC_K_CLASS_ASYNC |
+			      FDDI_FC_K_FORMAT_MANAGEMENT) &&
+			    (rmc & FZA_RING_RX_DA_MASK) !=
+			     FZA_RING_RX_DA_PROM) {
+				if (fza_do_recv_smt((struct fza_buffer_tx *)
+						    skb->data, len, rmc,
+						    dev)) {
+					wmb();
+					writel(FZA_CONTROL_A_SMT_RX_OVFL,
+					       &fp->regs->control_a);
+				}
+			}
+
+			is_multi = ((frame->hdr.daddr[0] & 0x01) != 0);
+
+			skb_reserve(skb, 3);	/* skip over P and SD */
+			skb_put(skb, pkt_len);	/* and cut off FCS */
+			skb->protocol = fddi_type_trans(skb, dev);
+
+			rx_stat = netif_rx(skb);
+			if (rx_stat != NET_RX_DROP) {
+				fp->stats.rx_packets++;
+				fp->stats.rx_bytes += pkt_len;
+				if (is_multi)
+					fp->stats.multicast++;
+			} else
+				fp->stats.rx_dropped++;
+
+			skb = newskb;
+			dma = newdma;
+			fp->rx_skbuff[i] = skb;
+			fp->rx_dma[i] = dma;
+		} else {
+			fp->stats.rx_dropped++;
+			pr_notice("%s: memory squeeze, dropping packet\n",
+				  fp->name);
+		}
+
+err_rx:
+		wmb();
+		writel(0, &fp->ring_hst_rx[i].rmc);
+		wmb();
+		buf = (dma + 0x1000) >> 9;
+		writel(buf, &fp->ring_hst_rx[i].buffer1);
+		wmb();
+		buf = dma >> 9 | FZA_RING_OWN_FZA;
+		writel(buf, &fp->ring_hst_rx[i].buf0_own);
+		fp->ring_hst_rx_index =
+			(fp->ring_hst_rx_index + 1) % fp->ring_hst_rx_size;
+	}
+}
+
+
+static void fza_tx_smt(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	struct fza_buffer_tx __iomem *smt_tx_ptr, *skb_data_ptr;
+	int i, len;
+	u32 own;
+
+
+	while (1) {
+		i = fp->ring_smt_tx_index;
+		mb();
+		own = readl(&fp->ring_smt_tx[i].own);
+		if ((own & FZA_RING_OWN_MASK) == FZA_RING_OWN_FZA)
+			break;
+
+		smt_tx_ptr = fp->mmio + readl(&fp->ring_smt_tx[i].buffer);
+		len = readl(&fp->ring_smt_tx[i].rmc) & FZA_RING_PBC_MASK;
+
+		if (!netif_queue_stopped(dev)) {
+			if (!list_empty(&ptype_all)) {
+				struct sk_buff *skb;
+
+				/* Length must be a multiple of 4 as only word
+				 * reads are permitted!
+				 */
+				skb = fza_alloc_skb_irq(dev, (len + 3) & ~3);
+				if (skb == NULL)
+					goto err_no_skb;	/* drop */
+
+				skb_data_ptr = (struct fza_buffer_tx *)
+					       skb->data;
+
+				fza_reads(smt_tx_ptr, skb_data_ptr,
+					  (len + 3) & ~3);
+				skb->dev = dev;
+				skb_reserve(skb, 3);	/* skip over PRH */
+				skb_put(skb, len - 3);
+				skb_reset_network_header(skb);
+
+				dev_queue_xmit_nit(skb, dev);
+
+				dev_kfree_skb_irq(skb);
+
+err_no_skb:
+				;
+			}
+
+			/* Queue the frame to the RMC transmit ring. */
+			fza_do_xmit((union fza_buffer_txp)
+				    { .mmio_ptr = smt_tx_ptr },
+				    len, dev, 1);
+		}
+
+		mb();
+		writel(FZA_RING_OWN_FZA, &fp->ring_smt_tx[i].own);
+		fp->ring_smt_tx_index =
+			(fp->ring_smt_tx_index + 1) % fp->ring_smt_tx_size;
+	}
+}
+
+
+static void fza_uns(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	u32 own;
+	int i;
+
+
+	while (1) {
+		i = fp->ring_uns_index;
+		mb();
+		own = readl(&fp->ring_uns[i].own);
+		if ((own & FZA_RING_OWN_MASK) == FZA_RING_OWN_FZA)
+			break;
+
+		if (readl(&fp->ring_uns[i].id) == FZA_RING_UNS_RX_OVER) {
+			fp->stats.rx_errors++;
+			fp->stats.rx_over_errors++;
+		}
+
+		mb();
+		writel(FZA_RING_OWN_FZA, &fp->ring_uns[i].own);
+		fp->ring_uns_index =
+			(fp->ring_uns_index + 1) % FZA_RING_UNS_SIZE;
+	}
+}
+
+
+static void fza_tx_flush(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	u32 own;
+	int i;
+
+
+	/* Clean up the SMT TX ring. */
+	i = fp->ring_smt_tx_index;
+	do {
+		mb();
+		writel(FZA_RING_OWN_FZA, &fp->ring_smt_tx[i].own);
+		fp->ring_smt_tx_index =
+			(fp->ring_smt_tx_index + 1) % fp->ring_smt_tx_size;
+
+	} while (i != fp->ring_smt_tx_index);
+
+	/* Clean up the RMC TX ring. */
+	i = fp->ring_rmc_tx_index;
+	do {
+		mb();
+		own = readl(&fp->ring_rmc_tx[i].own);
+		if ((own & FZA_RING_OWN_MASK) == FZA_RING_TX_OWN_RMC) {
+			u32 rmc = readl(&fp->ring_rmc_tx[i].rmc);
+			writel(rmc | FZA_RING_TX_DTP, &fp->ring_rmc_tx[i].rmc);
+		}
+		fp->ring_rmc_tx_index =
+			(fp->ring_rmc_tx_index + 1) % fp->ring_rmc_tx_size;
+
+	} while (i != fp->ring_rmc_tx_index);
+
+	/* Done. */
+	wmb();
+	writew(FZA_CONTROL_A_FLUSH_DONE, &fp->regs->control_a);
+}
+
+
+static irqreturn_t fza_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct fza_private *fp = netdev_priv(dev);
+
+	uint int_event;
+
+
+	/* Get interrupt events. */
+	mb();
+	int_event = readw(&fp->regs->int_event) & fp->int_mask;
+	if (int_event == 0)
+		return IRQ_NONE;
+
+	/* Clear the events. */
+	writew(int_event, &fp->regs->int_event);
+
+	/* Now handle the events.  The order matters. */
+
+	/* Command finished interrupt. */
+	if ((int_event & FZA_EVENT_CMD_DONE) != 0) {
+		fp->irq_count_cmd_done++;
+
+		spin_lock(&fp->lock);
+		fp->cmd_done_flag = 1;
+		wake_up(&fp->cmd_done_wait);
+		spin_unlock(&fp->lock);
+	}
+
+	/* Transmit finished interrupt. */
+	if ((int_event & FZA_EVENT_TX_DONE) != 0) {
+		fp->irq_count_tx_done++;
+		fza_tx(dev);
+	}
+
+	/* Host receive interrupt. */
+	if ((int_event & FZA_EVENT_RX_POLL) != 0) {
+		fp->irq_count_rx_poll++;
+		fza_rx(dev);
+	}
+
+	/* SMT transmit interrupt. */
+	if ((int_event & FZA_EVENT_SMT_TX_POLL) != 0) {
+		fp->irq_count_smt_tx_poll++;
+		fza_tx_smt(dev);
+	}
+
+	/* Transmit ring flush request. */
+	if ((int_event & FZA_EVENT_FLUSH_TX) != 0) {
+		fp->irq_count_flush_tx++;
+		fza_tx_flush(dev);
+	}
+
+	/* Link status change interrupt. */
+	if ((int_event & FZA_EVENT_LINK_ST_CHG) != 0) {
+		uint status;
+
+		fp->irq_count_link_st_chg++;
+		status = readw(&fp->regs->status);
+		if (FZA_STATUS_GET_LINK(status) == FZA_LINK_ON) {
+			netif_carrier_on(dev);
+			pr_info("%s: link available\n", fp->name);
+		} else {
+			netif_carrier_off(dev);
+			pr_info("%s: link unavailable\n", fp->name);
+		}
+	}
+
+	/* Unsolicited event interrupt. */
+	if ((int_event & FZA_EVENT_UNS_POLL) != 0) {
+		fp->irq_count_uns_poll++;
+		fza_uns(dev);
+	}
+
+	/* State change interrupt. */
+	if ((int_event & FZA_EVENT_STATE_CHG) != 0) {
+		uint status, state;
+
+		fp->irq_count_state_chg++;
+
+		status = readw(&fp->regs->status);
+		state = FZA_STATUS_GET_STATE(status);
+		pr_debug("%s: state change: %x\n", fp->name, state);
+		switch (state) {
+
+		case FZA_STATE_RESET:
+			break;
+
+		case FZA_STATE_UNINITIALIZED:
+			netif_carrier_off(dev);
+			del_timer_sync(&fp->reset_timer);
+			fp->ring_cmd_index = 0;
+			fp->ring_uns_index = 0;
+			fp->ring_rmc_tx_index = 0;
+			fp->ring_rmc_txd_index = 0;
+			fp->ring_hst_rx_index = 0;
+			fp->ring_smt_tx_index = 0;
+			fp->ring_smt_rx_index = 0;
+			if (fp->state > state) {
+				pr_info("%s: OK\n", fp->name);
+				fza_cmd_send(dev, FZA_RING_CMD_INIT);
+			}
+			break;
+
+		case FZA_STATE_INITIALIZED:
+			if (fp->state > state) {
+				fza_set_rx_mode(dev);
+				fza_cmd_send(dev, FZA_RING_CMD_PARAM);
+			}
+			break;
+
+		case FZA_STATE_RUNNING:
+		case FZA_STATE_MAINTENANCE:
+			fp->state = state;
+			fza_rx_init(fp);
+			fp->queue_active = 1;
+			netif_wake_queue(dev);
+			pr_debug("%s: queue waked\n", fp->name);
+			break;
+
+		case FZA_STATE_HALTED:
+			fp->queue_active = 0;
+			netif_stop_queue(dev);
+			pr_debug("%s: queue stopped\n", fp->name);
+			del_timer_sync(&fp->reset_timer);
+			pr_warn("%s: halted, reason: %x\n", fp->name,
+				FZA_STATUS_GET_HALT(status));
+			fza_regs_dump(fp);
+			pr_info("%s: resetting the board...\n", fp->name);
+			fza_do_reset(fp);
+			fp->timer_state = 0;
+			fp->reset_timer.expires = jiffies + 45 * HZ;
+			add_timer(&fp->reset_timer);
+			break;
+
+		default:
+			pr_warn("%s: undefined state: %x\n", fp->name, state);
+			break;
+
+		}
+
+		spin_lock(&fp->lock);
+		fp->state_chg_flag = 1;
+		wake_up(&fp->state_chg_wait);
+		spin_unlock(&fp->lock);
+	}
+
+	return IRQ_HANDLED;
+}
+
+
+static void fza_reset_timer(unsigned long int handle)
+{
+	struct fza_private *fp = (struct fza_private *)handle;
+
+
+	if (!fp->timer_state) {
+		pr_err("%s: RESET timed out!\n", fp->name);
+		pr_info("%s: trying harder...\n", fp->name);
+
+		/* Assert the board reset. */
+		wmb();
+		writew(FZA_RESET_INIT, &fp->regs->reset);
+		iob();
+
+		fp->timer_state = 1;
+		fp->reset_timer.expires = jiffies + HZ;
+	} else {
+		/* Clear the board reset. */
+		writew(FZA_RESET_CLR, &fp->regs->reset);
+
+		/* Enable all interrupt events we handle. */
+		wmb();
+		writew(fp->int_mask, &fp->regs->int_mask);
+		iob();
+
+		fp->timer_state = 0;
+		fp->reset_timer.expires = jiffies + 45 * HZ;
+	}
+	add_timer(&fp->reset_timer);
+}
+
+
+static int fza_set_mac_address(struct net_device *dev, void *addr)
+{
+	return -EOPNOTSUPP;
+}
+
+static int fza_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	u8 fc;
+	unsigned int old_mask, new_mask;
+	int ret;
+
+	skb_push(skb, 3);			/* make room for PRH */
+
+	/* Decode FC to set PRH. */
+	fc = skb->data[3];
+	skb->data[0] = 0;
+	skb->data[1] = 0;
+	skb->data[2] = FZA_PRH2_NORMAL;
+	if ((fc & FDDI_FC_K_CLASS_MASK) == FDDI_FC_K_CLASS_SYNC)
+		skb->data[0] |= FZA_PRH0_FRAME_SYNC;
+	switch (fc & FDDI_FC_K_FORMAT_MASK) {
+	case FDDI_FC_K_FORMAT_MANAGEMENT:
+		if ((fc & FDDI_FC_K_CONTROL_MASK) == 0) {
+			/* token */
+			skb->data[0] |= FZA_PRH0_TKN_TYPE_IMM;
+			skb->data[1] |= FZA_PRH1_TKN_SEND_NONE;
+		} else {
+			/* SMT or MAC */
+			skb->data[0] |= FZA_PRH0_TKN_TYPE_UNR;
+			skb->data[1] |= FZA_PRH1_TKN_SEND_UNR;
+		}
+		skb->data[1] |= FZA_PRH1_CRC_NORMAL;
+		break;
+	case FDDI_FC_K_FORMAT_LLC:
+	case FDDI_FC_K_FORMAT_FUTURE:
+		skb->data[0] |= FZA_PRH0_TKN_TYPE_UNR;
+		skb->data[1] |= FZA_PRH1_CRC_NORMAL | FZA_PRH1_TKN_SEND_UNR;
+		break;
+	case FDDI_FC_K_FORMAT_IMPLEMENTOR:
+		skb->data[0] |= FZA_PRH0_TKN_TYPE_UNR;
+		skb->data[1] |= FZA_PRH1_TKN_SEND_ORIG;
+		break;
+	}
+
+	/* SMT transmit interrupts may sneak frames into the RMC
+	 * transmit ring.  We disable them while queueing a frame
+	 * to maintain consistency.
+	 */
+	old_mask = fp->int_mask;
+	new_mask = old_mask & ~FZA_MASK_SMT_TX_POLL;
+	writew(new_mask, &fp->regs->int_mask);
+	iob();
+	fp->int_mask = new_mask;
+	ret = fza_do_xmit((union fza_buffer_txp)
+			  { .data_ptr = (struct fza_buffer_tx *)skb->data },
+			  skb->len, dev, 0);
+	fp->int_mask = old_mask;
+	writew(fp->int_mask, &fp->regs->int_mask);
+
+	if (ret) {
+		/* Probably an SMT packet filled the remaining space,
+		 * so just stop the queue, but don't report it as an error.
+		 */
+		netif_stop_queue(dev);
+		pr_debug("%s: queue stopped\n", fp->name);
+		fp->stats.tx_dropped++;
+	}
+
+	dev_kfree_skb(skb);
+
+	return ret;
+}
+
+static int fza_open(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	struct fza_ring_cmd __iomem *ring;
+
+	unsigned long int flags;
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	long int t;
+	int ret, i;
+	u32 stat;
+
+
+	for (i = 0; i < FZA_RING_RX_SIZE; i++) {
+		/* We have to 512-byte-align RX buffers... */
+		skb = fza_alloc_skb(dev, FZA_RX_BUFFER_SIZE + 511);
+		if (skb != NULL) {
+			fza_skb_align(skb, 512);
+			dma = dma_map_single(fp->bdev, skb->data,
+					     FZA_RX_BUFFER_SIZE,
+					     DMA_FROM_DEVICE);
+			if (dma_mapping_error(fp->bdev, dma)) {
+				dev_kfree_skb(skb);
+				skb = NULL;
+			}
+		}
+		if (skb == NULL) {
+			for (--i; i >= 0; i--) {
+				dma_unmap_single(fp->bdev, fp->rx_dma[i],
+						 FZA_RX_BUFFER_SIZE,
+						 DMA_FROM_DEVICE);
+				dev_kfree_skb(fp->rx_skbuff[i]);
+				fp->rx_dma[i] = 0;
+				fp->rx_skbuff[i] = NULL;
+			}
+			return -ENOMEM;
+		}
+		fp->rx_skbuff[i] = skb;
+		fp->rx_dma[i] = dma;
+	}
+
+
+	ret = fza_init_send(dev, NULL);
+	if (ret != 0)
+		return ret;
+
+
+	/* Purger and Beacon multicasts need to be supplied before PARAM. */
+	fza_set_rx_mode(dev);
+
+
+	spin_lock_irqsave(&fp->lock, flags);
+	fp->cmd_done_flag = 0;
+	ring = fza_cmd_send(dev, FZA_RING_CMD_PARAM);
+	spin_unlock_irqrestore(&fp->lock, flags);
+	if (ring == NULL)
+		return -ENOBUFS;
+
+	t = wait_event_timeout(fp->cmd_done_wait, fp->cmd_done_flag, 3 * HZ);
+	if (fp->cmd_done_flag == 0) {
+		pr_err("%s: PARAM command timed out!, state %x\n", fp->name,
+		       FZA_STATUS_GET_STATE(readw(&fp->regs->status)));
+		return -EIO;
+	}
+	stat = readl(&ring->stat);
+	if (stat != FZA_RING_STAT_SUCCESS) {
+		pr_err("%s: PARAM command failed!, status %02x, state %x\n",
+		       fp->name, stat,
+		       FZA_STATUS_GET_STATE(readw(&fp->regs->status)));
+		return -EIO;
+	}
+	pr_debug("%s: PARAM: %lums elapsed\n", fp->name,
+		 (3 * HZ - t) * 1000 / HZ);
+
+	return 0;
+}
+
+static int fza_close(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+	uint state;
+
+	unsigned long int flags;
+	long int t;
+	int i;
+
+
+	netif_stop_queue(dev);
+	pr_debug("%s: queue stopped\n", fp->name);
+
+	del_timer_sync(&fp->reset_timer);
+	spin_lock_irqsave(&fp->lock, flags);
+	fp->state = FZA_STATE_UNINITIALIZED;
+	fp->state_chg_flag = 0;
+	/* Shut the interface down. */
+	wmb();
+	writew(FZA_CONTROL_A_SHUT, &fp->regs->control_a);
+	iob();
+	spin_unlock_irqrestore(&fp->lock, flags);
+
+	/* DEC says SHUT needs up to 10 seconds to complete. */
+	t = wait_event_timeout(fp->state_chg_wait, fp->state_chg_flag,
+			       15 * HZ);
+	state = FZA_STATUS_GET_STATE(readw(&fp->regs->status));
+	if (fp->state_chg_flag == 0) {
+		pr_err("%s: SHUT timed out!, state %x\n", fp->name, state);
+		return -EIO;
+	}
+	if (state != FZA_STATE_UNINITIALIZED) {
+		pr_err("%s: SHUT failed!, state %x\n", fp->name, state);
+		return -EIO;
+	}
+	pr_debug("%s: SHUT: %lums elapsed\n", fp->name,
+		 (15 * HZ - t) * 1000 / HZ);
+
+	for (i = 0; i < FZA_RING_RX_SIZE; i++)
+		if (fp->rx_skbuff[i] != NULL) {
+			dma_unmap_single(fp->bdev, fp->rx_dma[i],
+					 FZA_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
+			dev_kfree_skb(fp->rx_skbuff[i]);
+			fp->rx_dma[i] = 0;
+			fp->rx_skbuff[i] = NULL;
+		}
+
+	return 0;
+}
+
+static struct net_device_stats *fza_get_stats(struct net_device *dev)
+{
+	struct fza_private *fp = netdev_priv(dev);
+
+	return &fp->stats;
+}
+
+
+static int fza_probe(struct device *bdev)
+{
+	static const struct net_device_ops netdev_ops = {
+		.ndo_open = fza_open,
+		.ndo_stop = fza_close,
+		.ndo_start_xmit = fza_start_xmit,
+		.ndo_set_rx_mode = fza_set_rx_mode,
+		.ndo_set_mac_address = fza_set_mac_address,
+		.ndo_get_stats = fza_get_stats,
+	};
+
+	struct tc_dev *tdev = to_tc_dev(bdev);
+	resource_size_t start, len;
+	struct net_device *dev;
+	struct fza_private *fp;
+	void __iomem *mmio;
+
+	struct fza_cmd_init __iomem *init;
+	uint hw_addr[2];
+	char rom_rev[4], fw_rev[4], rmc_rev[4];
+	uint pmd_type_alt, smt_ver, pmd_type;
+
+	static int version_printed;
+
+	int ret, i;
+
+
+	if (!version_printed) {
+		pr_info("%s", version);
+		version_printed = 1;
+	}
+
+	dev = alloc_fddidev(sizeof(*fp));
+	if (!dev)
+		return -ENOMEM;
+	SET_NETDEV_DEV(dev, bdev);
+
+	fp = netdev_priv(dev);
+	dev_set_drvdata(bdev, dev);
+
+	fp->bdev = bdev;
+	fp->name = dev_name(bdev);
+
+	/* Request the I/O MEM resource. */
+	start = tdev->resource.start;
+	len = tdev->resource.end - start + 1;
+	if (!request_mem_region(start, len, dev_name(bdev))) {
+		pr_err("%s: cannot reserve MMIO region\n", fp->name);
+		ret = -EBUSY;
+		goto err_out_kfree;
+	}
+
+	/* MMIO mapping setup. */
+	mmio = ioremap_nocache(start, len);
+	if (!mmio) {
+		pr_err("%s: cannot map MMIO\n", fp->name);
+		ret = -ENOMEM;
+		goto err_out_resource;
+	}
+
+	/* Initialize the new device structure. */
+	switch (loopback) {
+	case FZA_LOOP_NORMAL:
+	case FZA_LOOP_INTERN:
+	case FZA_LOOP_EXTERN:
+		break;
+	default:
+		loopback = FZA_LOOP_NORMAL;
+	}
+
+	fp->mmio = mmio;
+	dev->irq = tdev->interrupt;
+
+	pr_info("%s: DEC FDDIcontroller 700 (DEFZA-xx) at 0x%08llx, irq %d\n",
+		fp->name, (long long)tdev->resource.start, dev->irq);
+	pr_debug("%s: mapped at: 0x%p\n", fp->name, mmio);
+
+
+	fp->regs = mmio + FZA_REG_BASE;
+	fp->ring_cmd = mmio + FZA_RING_CMD;
+	fp->ring_uns = mmio + FZA_RING_UNS;
+
+	init_waitqueue_head(&fp->state_chg_wait);
+	init_waitqueue_head(&fp->cmd_done_wait);
+	spin_lock_init(&fp->lock);
+	fp->int_mask = FZA_MASK_NORMAL;
+
+	init_timer(&fp->reset_timer);
+	fp->reset_timer.data = (unsigned long int)fp;
+	fp->reset_timer.function = fza_reset_timer;
+
+
+	/* Sanitize the board. */
+	fza_regs_dump(fp);
+	fza_do_shutdown(fp);
+
+	ret = request_irq(dev->irq, fza_interrupt, IRQF_SHARED, fp->name, dev);
+	if (ret != 0) {
+		pr_err("%s: unable to get IRQ %d!\n", fp->name, dev->irq);
+		goto err_out_map;
+	}
+
+	/* Enable the driver mode. */
+	wmb();
+	writew(FZA_CONTROL_B_DRIVER, &fp->regs->control_b);
+
+	/* For some reason transmit done interrupts can trigger during
+	 * reset.  This avoids a division error in the handler.
+	 */
+	fp->ring_rmc_tx_size = FZA_RING_TX_SIZE;
+
+	ret = fza_reset(fp);
+	if (ret != 0)
+		goto err_out_irq;
+
+	ret = fza_init_send(dev, &init);
+	if (ret != 0)
+		goto err_out_irq;
+
+	fza_reads(&init->hw_addr, &hw_addr, sizeof(hw_addr));
+	memcpy(dev->dev_addr, &hw_addr, FDDI_K_ALEN);
+
+	fza_reads(&init->rom_rev, &rom_rev, sizeof(rom_rev));
+	fza_reads(&init->fw_rev, &fw_rev, sizeof(fw_rev));
+	fza_reads(&init->rmc_rev, &rmc_rev, sizeof(rmc_rev));
+	for (i = 3; i >= 0 && rom_rev[i] == ' '; i--)
+		rom_rev[i] = 0;
+	for (i = 3; i >= 0 && fw_rev[i] == ' '; i--)
+		fw_rev[i] = 0;
+	for (i = 3; i >= 0 && rmc_rev[i] == ' '; i--)
+		rmc_rev[i] = 0;
+
+	fp->ring_rmc_tx = mmio + readl(&init->rmc_tx);
+	fp->ring_rmc_tx_size = readl(&init->rmc_tx_size);
+	fp->ring_hst_rx = mmio + readl(&init->hst_rx);
+	fp->ring_hst_rx_size = readl(&init->hst_rx_size);
+	fp->ring_smt_tx = mmio + readl(&init->smt_tx);
+	fp->ring_smt_tx_size = readl(&init->smt_tx_size);
+	fp->ring_smt_rx = mmio + readl(&init->smt_rx);
+	fp->ring_smt_rx_size = readl(&init->smt_rx_size);
+
+	fp->buffer_tx = mmio + FZA_TX_BUFFER_ADDR(readl(&init->rmc_tx));
+
+	fp->t_max = readl(&init->def_t_max);
+	fp->t_req = readl(&init->def_t_req);
+	fp->tvx = readl(&init->def_tvx);
+	fp->lem_threshold = readl(&init->lem_threshold);
+	fza_reads(&init->def_station_id, &fp->station_id,
+		   sizeof(fp->station_id));
+	fp->rtoken_timeout = readl(&init->rtoken_timeout);
+	fp->ring_purger = readl(&init->ring_purger);
+
+	pmd_type_alt = readl(&init->pmd_type_alt);
+	smt_ver = readl(&init->smt_ver);
+	pmd_type = readl(&init->pmd_type);
+
+	pr_debug("%s: INIT parameters:\n", fp->name);
+	pr_debug("        tx_mode: %u\n", readl(&init->tx_mode));
+	pr_debug("    hst_rx_size: %u\n", readl(&init->hst_rx_size));
+	pr_debug("        rmc_rev: %.4s\n", rmc_rev);
+	pr_debug("        rom_rev: %.4s\n", rom_rev);
+	pr_debug("         fw_rev: %.4s\n", fw_rev);
+	pr_debug("       mop_type: %u\n", readl(&init->mop_type));
+	pr_debug("         hst_rx: 0x%08x\n", readl(&init->hst_rx));
+	pr_debug("         rmc_tx: 0x%08x\n", readl(&init->rmc_tx));
+	pr_debug("    rmc_tx_size: %u\n", readl(&init->rmc_tx_size));
+	pr_debug("         smt_tx: 0x%08x\n", readl(&init->smt_tx));
+	pr_debug("    smt_tx_size: %u\n", readl(&init->smt_tx_size));
+	pr_debug("         smt_rx: 0x%08x\n", readl(&init->smt_rx));
+	pr_debug("    smt_rx_size: %u\n", readl(&init->smt_rx_size));
+	/* TC systems are always LE, so don't bother swapping. */
+	pr_debug("        hw_addr: 0x%02x%02x%02x%02x%02x%02x%02x%02x\n",
+		 (readl(&init->hw_addr[0]) >> 0) & 0xff,
+		 (readl(&init->hw_addr[0]) >> 8) & 0xff,
+		 (readl(&init->hw_addr[0]) >> 16) & 0xff,
+		 (readl(&init->hw_addr[0]) >> 24) & 0xff,
+		 (readl(&init->hw_addr[1]) >> 0) & 0xff,
+		 (readl(&init->hw_addr[1]) >> 8) & 0xff,
+		 (readl(&init->hw_addr[1]) >> 16) & 0xff,
+		 (readl(&init->hw_addr[1]) >> 24) & 0xff);
+	pr_debug("      def_t_req: %u\n", readl(&init->def_t_req));
+	pr_debug("        def_tvx: %u\n", readl(&init->def_tvx));
+	pr_debug("      def_t_max: %u\n", readl(&init->def_t_max));
+	pr_debug("  lem_threshold: %u\n", readl(&init->lem_threshold));
+	/* Don't bother swapping, see above. */
+	pr_debug(" def_station_id: 0x%02x%02x%02x%02x%02x%02x%02x%02x\n",
+		 (readl(&init->def_station_id[0]) >> 0) & 0xff,
+		 (readl(&init->def_station_id[0]) >> 8) & 0xff,
+		 (readl(&init->def_station_id[0]) >> 16) & 0xff,
+		 (readl(&init->def_station_id[0]) >> 24) & 0xff,
+		 (readl(&init->def_station_id[1]) >> 0) & 0xff,
+		 (readl(&init->def_station_id[1]) >> 8) & 0xff,
+		 (readl(&init->def_station_id[1]) >> 16) & 0xff,
+		 (readl(&init->def_station_id[1]) >> 24) & 0xff);
+	pr_debug("   pmd_type_alt: %u\n", readl(&init->pmd_type_alt));
+	pr_debug("        smt_ver: %u\n", readl(&init->smt_ver));
+	pr_debug(" rtoken_timeout: %u\n", readl(&init->rtoken_timeout));
+	pr_debug("    ring_purger: %u\n", readl(&init->ring_purger));
+	pr_debug("    smt_ver_max: %u\n", readl(&init->smt_ver_max));
+	pr_debug("    smt_ver_min: %u\n", readl(&init->smt_ver_min));
+	pr_debug("       pmd_type: %u\n", readl(&init->pmd_type));
+
+	pr_info("%s: model DEFZA-%cA, address %pMF\n",
+		fp->name, pmd_type == 0 ? 'A' : 'C', dev->dev_addr);
+	pr_info("%s: ROM rev. %.4s, firmware rev. %.4s, RMC rev. %.4s, "
+		"SMT ver. %u\n", fp->name, rom_rev, fw_rev, rmc_rev, smt_ver);
+	if (pmd_type_alt != 1 || pmd_type != 0) {
+		pr_warn("%s: WARNING: unrecognized PMD type (%u, %u), "
+			"please report\n", fp->name, pmd_type_alt, pmd_type);
+		pr_warn("%s:          to <macro@linux-mips.org>\n", fp->name);
+	}
+
+
+	/* Now that we fetched initial parameters just shut the interface
+	 * until opened.
+	 */
+	ret = fza_close(dev);
+	if (ret != 0)
+		goto err_out_irq;
+
+	/* The FZA-specific entries in the device structure. */
+	dev->netdev_ops = &netdev_ops;
+
+	ret = register_netdev(dev);
+	if (ret != 0)
+		goto err_out_irq;
+
+	pr_info("%s: registered as %s\n", fp->name, dev->name);
+	fp->name = (const char *)dev->name;
+
+	get_device(bdev);
+	return 0;
+
+
+err_out_irq:
+	del_timer_sync(&fp->reset_timer);
+	fza_do_shutdown(fp);
+	free_irq(dev->irq, dev);
+
+err_out_map:
+	iounmap(mmio);
+
+err_out_resource:
+	release_mem_region(start, len);
+
+err_out_kfree:
+	free_netdev(dev);
+
+	pr_err("%s: initialization failure, aborting!\n", fp->name);
+	return ret;
+}
+
+
+static int fza_remove(struct device *bdev)
+{
+	struct net_device *dev = dev_get_drvdata(bdev);
+	struct fza_private *fp = netdev_priv(dev);
+	struct tc_dev *tdev = to_tc_dev(bdev);
+	resource_size_t start, len;
+
+	put_device(bdev);
+
+	unregister_netdev(dev);
+
+	del_timer_sync(&fp->reset_timer);
+	fza_do_shutdown(fp);
+	free_irq(dev->irq, dev);
+
+	iounmap(fp->mmio);
+
+	start = tdev->resource.start;
+	len = tdev->resource.end - start + 1;
+	release_mem_region(start, len);
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+
+static struct tc_device_id const fza_tc_table[] = {
+	{ "DEC     ", "PMAF-AA " },
+	{ }
+};
+MODULE_DEVICE_TABLE(tc, fza_tc_table);
+
+static struct tc_driver fza_driver = {
+	.id_table	= fza_tc_table,
+	.driver		= {
+		.name	= "defza",
+		.bus	= &tc_bus_type,
+		.probe	= fza_probe,
+		.remove	= fza_remove,
+	},
+};
+
+static int fza_init(void)
+{
+	return tc_register_driver(&fza_driver);
+}
+
+static void fza_exit(void)
+{
+	tc_unregister_driver(&fza_driver);
+}
+
+
+module_init(fza_init);
+module_exit(fza_exit);
Index: net-20140407-4maxp64/drivers/net/fddi/defza.h
===================================================================
--- /dev/null
+++ net-20140407-4maxp64/drivers/net/fddi/defza.h
@@ -0,0 +1,764 @@
+/*	FDDI network adapter driver for DEC FDDIcontroller 700/700C devices.
+ *
+ *	Copyright (c) 2014  Maciej W. Rozycki
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ *	References:
+ *
+ *	Dave Sawyer & Phil Weeks & Frank Itkowsky,
+ *	"DEC FDDIcontroller 700 Port Specification",
+ *	Revision 1.1, Digital Equipment Corporation
+ */
+
+#include <linux/compiler.h>
+#include <linux/if_fddi.h>
+#include <linux/spinlock.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+
+/* IOmem register offsets. */
+#define FZA_REG_BASE		0x100000	/* register base address */
+#define FZA_REG_RESET		0x100200	/* reset register */
+#define FZA_REG_INT_EVENT	0x100400	/* interrupt event register */
+#define FZA_REG_STATUS		0x100402	/* status register */
+#define FZA_REG_INT_MASK	0x100404	/* interrupt mask register */
+#define FZA_REG_CONTROL_A	0x100500	/* control A register */
+#define FZA_REG_CONTROL_B	0x100502	/* control B register */
+
+
+/* Reset register constants.  Bits 1:0 are r/w, others are fixed at 0. */
+#define FZA_RESET_DLU	0x0002	/* OR with INIT to blast flash memory */
+#define FZA_RESET_INIT	0x0001	/* switch into the reset state */
+#define FZA_RESET_CLR	0x0000	/* run self-test and return to work */
+
+
+/* Interrupt event register constants.  All bits are r/w1c. */
+#define FZA_EVENT_DLU_DONE	0x0800	/* flash memory write complete */
+#define FZA_EVENT_FLUSH_TX	0x0400	/* transmit ring flush request */
+#define FZA_EVENT_PM_PARITY_ERR	0x0200	/* onboard packet memory parity err */
+#define FZA_EVENT_HB_PARITY_ERR	0x0100	/* host bus parity error */
+#define FZA_EVENT_NXM_ERR	0x0080	/* non-existent memory access error;
+					   also raised for unaligned and
+					   unsupported partial-word accesses */
+#define FZA_EVENT_LINK_ST_CHG	0x0040	/* link status change */
+#define FZA_EVENT_STATE_CHG	0x0020	/* adapter state change */
+#define FZA_EVENT_UNS_POLL	0x0010	/* unsolicited event service request */
+#define FZA_EVENT_CMD_DONE	0x0008	/* command done ack */
+#define FZA_EVENT_SMT_TX_POLL	0x0004	/* SMT frame transmit request */
+#define FZA_EVENT_RX_POLL	0x0002	/* receive request (packet avail.) */
+#define FZA_EVENT_TX_DONE	0x0001	/* RMC transmit done ack */
+
+
+/* Status register constants.  All bits are r/o. */
+#define FZA_STATUS_DLU_SHIFT	0xc	/* down line upgrade status bits */
+#define FZA_STATUS_DLU_MASK	0x03
+#define FZA_STATUS_LINK_SHIFT	0xb	/* link status bits */
+#define FZA_STATUS_LINK_MASK	0x01
+#define FZA_STATUS_STATE_SHIFT	0x8	/* adapter state bits */
+#define FZA_STATUS_STATE_MASK	0x07
+#define FZA_STATUS_HALT_SHIFT	0x0	/* halt reason bits */
+#define FZA_STATUS_HALT_MASK	0xff
+#define FZA_STATUS_TEST_SHIFT	0x0	/* test failure bits */
+#define FZA_STATUS_TEST_MASK	0xff
+
+#define FZA_STATUS_GET_DLU(x)	(((x) >> FZA_STATUS_DLU_SHIFT) &	\
+				 FZA_STATUS_DLU_MASK)
+#define FZA_STATUS_GET_LINK(x)	(((x) >> FZA_STATUS_LINK_SHIFT) &	\
+				 FZA_STATUS_LINK_MASK)
+#define FZA_STATUS_GET_STATE(x)	(((x) >> FZA_STATUS_STATE_SHIFT) &	\
+				 FZA_STATUS_STATE_MASK)
+#define FZA_STATUS_GET_HALT(x)	(((x) >> FZA_STATUS_HALT_SHIFT) &	\
+				 FZA_STATUS_HALT_MASK)
+#define FZA_STATUS_GET_TEST(x)	(((x) >> FZA_STATUS_TEST_SHIFT) &	\
+				 FZA_STATUS_TEST_MASK)
+
+#define FZA_DLU_FAILURE		0x0	/* DLU catastrophic error; brain dead */
+#define FZA_DLU_ERROR		0x1	/* DLU error; old firmware intact */
+#define FZA_DLU_SUCCESS		0x2	/* DLU OK; new firmware loaded */
+
+#define FZA_LINK_OFF		0x0	/* link unavailable */
+#define FZA_LINK_ON		0x1	/* link available */
+
+#define FZA_STATE_RESET		0x0	/* resetting */
+#define FZA_STATE_UNINITIALIZED	0x1	/* after a reset */
+#define FZA_STATE_INITIALIZED	0x2	/* initialized */
+#define FZA_STATE_RUNNING	0x3	/* running (link active) */
+#define FZA_STATE_MAINTENANCE	0x4	/* running (link looped back) */
+#define FZA_STATE_HALTED	0x5	/* halted (error condition) */
+
+#define FZA_HALT_UNKNOWN	0x00	/* unknown reason */
+#define FZA_HALT_HOST		0x01	/* host-directed HALT */
+#define FZA_HALT_HB_PARITY	0x02	/* host bus parity error */
+#define FZA_HALT_NXM		0x03	/* adapter non-existent memory ref. */
+#define FZA_HALT_SW		0x04	/* adapter software fault */
+#define FZA_HALT_HW		0x05	/* adapter hardware fault */
+#define FZA_HALT_PC_TRACE	0x06	/* PC Trace path test */
+#define FZA_HALT_DLSW		0x07	/* data link software fault */
+#define FZA_HALT_DLHW		0x08	/* data link hardware fault */
+
+#define FZA_TEST_FATAL		0x00	/* self-test catastrophic failure */
+#define FZA_TEST_68K		0x01	/* 68000 CPU */
+#define FZA_TEST_SRAM_BWADDR	0x02	/* SRAM byte/word address */
+#define FZA_TEST_SRAM_DBUS	0x03	/* SRAM data bus */
+#define FZA_TEST_SRAM_STUCK1	0x04	/* SRAM stuck-at range 1 */
+#define FZA_TEST_SRAM_STUCK2	0x05	/* SRAM stuck-at range 2 */
+#define FZA_TEST_SRAM_COUPL1	0x06	/* SRAM coupling range 1 */
+#define FZA_TEST_SRAM_COUPL2	0x07	/* SRAM coupling */
+#define FZA_TEST_FLASH_CRC	0x08	/* Flash CRC */
+#define FZA_TEST_ROM		0x09	/* option ROM */
+#define FZA_TEST_PHY_CSR	0x0a	/* PHY CSR */
+#define FZA_TEST_MAC_BIST	0x0b	/* MAC BiST */
+#define FZA_TEST_MAC_CSR	0x0c	/* MAC CSR */
+#define FZA_TEST_MAC_ADDR_UNIQ	0x0d	/* MAC unique address */
+#define FZA_TEST_ELM_BIST	0x0e	/* ELM BiST */
+#define FZA_TEST_ELM_CSR	0x0f	/* ELM CSR */
+#define FZA_TEST_ELM_ADDR_UNIQ	0x10	/* ELM unique address */
+#define FZA_TEST_CAM		0x11	/* CAM */
+#define FZA_TEST_NIROM		0x12	/* NI ROM checksum */
+#define FZA_TEST_SC_LOOP	0x13	/* SC loopback packet */
+#define FZA_TEST_LM_LOOP	0x14	/* LM loopback packet */
+#define FZA_TEST_EB_LOOP	0x15	/* EB loopback packet */
+#define FZA_TEST_SC_LOOP_BYPS	0x16	/* SC bypass loopback packet */
+#define FZA_TEST_LM_LOOP_LOCAL	0x17	/* LM local loopback packet */
+#define FZA_TEST_EB_LOOP_LOCAL	0x18	/* EB local loopback packet */
+#define FZA_TEST_CDC_LOOP	0x19	/* CDC loopback packet */
+#define FZA_TEST_FIBER_LOOP	0x1A	/* FIBER loopback packet */
+#define FZA_TEST_CAM_MATCH_LOOP	0x1B	/* CAM match packet loopback */
+#define FZA_TEST_68K_IRQ_STUCK	0x1C	/* 68000 interrupt line stuck-at */
+#define FZA_TEST_IRQ_PRESENT	0x1D	/* interrupt present register */
+#define FZA_TEST_RMC_BIST	0x1E	/* RMC BiST */
+#define FZA_TEST_RMC_CSR	0x1F	/* RMC CSR */
+#define FZA_TEST_RMC_ADDR_UNIQ	0x20	/* RMC unique address */
+#define FZA_TEST_PM_DPATH	0x21	/* packet memory data path */
+#define FZA_TEST_PM_ADDR	0x22	/* packet memory address */
+#define FZA_TEST_RES_23		0x23	/* reserved */
+#define FZA_TEST_PM_DESC	0x24	/* packet memory descriptor */
+#define FZA_TEST_PM_OWN		0x25	/* packet memory own bit */
+#define FZA_TEST_PM_PARITY	0x26	/* packet memory parity */
+#define FZA_TEST_PM_BSWAP	0x27	/* packet memory byte swap */
+#define FZA_TEST_PM_WSWAP	0x28	/* packet memory word swap */
+#define FZA_TEST_PM_REF		0x29	/* packet memory refresh */
+#define FZA_TEST_PM_CSR		0x2A	/* PM CSR */
+#define FZA_TEST_PORT_STATUS	0x2B	/* port status register */
+#define FZA_TEST_HOST_IRQMASK	0x2C	/* host interrupt mask */
+#define FZA_TEST_TIMER_IRQ1	0x2D	/* RTOS timer */
+#define FZA_TEST_FORCE_IRQ1	0x2E	/* force RTOS IRQ1 */
+#define FZA_TEST_TIMER_IRQ5	0x2F	/* IRQ5 backoff timer */
+#define FZA_TEST_FORCE_IRQ5	0x30	/* force IRQ5 */
+#define FZA_TEST_RES_31		0x31	/* reserved */
+#define FZA_TEST_IC_PRIO	0x32	/* interrupt controller priority */
+#define FZA_TEST_PM_FULL	0x33	/* full packet memory */
+#define FZA_TEST_PMI_DMA	0x34	/* PMI DMA */
+
+
+/* Interrupt mask register constants.  All bits are r/w. */
+#define FZA_MASK_RESERVED	0xf000	/* unused */
+#define FZA_MASK_DLU_DONE	0x0800	/* flash memory write complete */
+#define FZA_MASK_FLUSH_TX	0x0400	/* transmit ring flush request */
+#define FZA_MASK_PM_PARITY_ERR	0x0200	/* onboard packet memory parity
+					   error */
+#define FZA_MASK_HB_PARITY_ERR	0x0100	/* host bus parity error */
+#define FZA_MASK_NXM_ERR	0x0080	/* adapter non-existent memory
+					   reference */
+#define FZA_MASK_LINK_ST_CHG	0x0040	/* link status change */
+#define FZA_MASK_STATE_CHG	0x0020	/* adapter state change */
+#define FZA_MASK_UNS_POLL	0x0010	/* unsolicited event service request */
+#define FZA_MASK_CMD_DONE	0x0008	/* command ring entry processed */
+#define FZA_MASK_SMT_TX_POLL	0x0004	/* SMT frame transmit request */
+#define FZA_MASK_RCV_POLL	0x0002	/* receive request (packet
+					   available) */
+#define FZA_MASK_TX_DONE	0x0001	/* RMC transmit done acknowledge */
+
+/* Which interrupts to receive: 0/1 is mask/unmask. */
+#define FZA_MASK_NONE		0x0000
+#define FZA_MASK_NORMAL							\
+		((~(FZA_MASK_RESERVED | FZA_MASK_DLU_DONE |		\
+		    FZA_MASK_PM_PARITY_ERR | FZA_MASK_HB_PARITY_ERR |	\
+		    FZA_MASK_NXM_ERR)) & 0xffff)
+
+
+/* Control A register constants. */
+#define FZA_CONTROL_A_HB_PARITY_ERR	0x8000	/* host bus parity error */
+#define FZA_CONTROL_A_NXM_ERR		0x4000	/* adapter non-existent memory
+						   reference */
+#define FZA_CONTROL_A_SMT_RX_OVFL	0x0040	/* SMT receive overflow */
+#define FZA_CONTROL_A_FLUSH_DONE	0x0020	/* flush tx request complete */
+#define FZA_CONTROL_A_SHUT		0x0010	/* turn the interface off */
+#define FZA_CONTROL_A_HALT		0x0008	/* halt the controller */
+#define FZA_CONTROL_A_CMD_POLL		0x0004	/* command ring poll */
+#define FZA_CONTROL_A_SMT_RX_POLL	0x0002	/* SMT receive ring poll */
+#define FZA_CONTROL_A_TX_POLL		0x0001	/* transmit poll */
+
+
+/* Control B register constants.  All bits are r/w.
+ *
+ * Possible values:
+ *	0x0000 after booting into REX,
+ *	0x0003 after issuing `boot #/mop'.
+ */
+#define FZA_CONTROL_B_CONSOLE	0x0002	/* OR with DRIVER for console
+					   (TC firmware) mode */
+#define FZA_CONTROL_B_DRIVER	0x0001	/* driver mode */
+#define FZA_CONTROL_B_IDLE	0x0000	/* no driver installed */
+
+
+#define FZA_RESET_PAD							\
+		(FZA_REG_RESET - FZA_REG_BASE)
+#define FZA_INT_EVENT_PAD						\
+		(FZA_REG_INT_EVENT - FZA_REG_RESET - sizeof(u16))
+#define FZA_CONTROL_A_PAD						\
+		(FZA_REG_CONTROL_A - FZA_REG_INT_MASK - sizeof(u16))
+
+/* Layout of registers. */
+struct fza_regs {
+	u8  pad0[FZA_RESET_PAD];
+	u16 reset;				/* reset register */
+	u8  pad1[FZA_INT_EVENT_PAD];
+	u16 int_event;				/* interrupt event register */
+	u16 status;				/* status register */
+	u16 int_mask;				/* interrupt mask register */
+	u8  pad2[FZA_CONTROL_A_PAD];
+	u16 control_a;				/* control A register */
+	u16 control_b;				/* control B register */
+};
+
+
+/* Command descriptor ring entry. */
+struct fza_ring_cmd {
+	u32 cmd_own;		/* bit 31: ownership, bits [30:0]: command */
+	u32 stat;		/* command status */
+	u32 buffer;		/* address of the buffer in the FZA space */
+	u32 pad0;
+};
+
+#define FZA_RING_CMD		0x200400	/* command ring address */
+#define FZA_RING_CMD_SIZE	0x40		/* command descriptor ring
+						   size */
+/* Command constants. */
+#define FZA_RING_CMD_MASK	0x7fffffff
+#define FZA_RING_CMD_NOP	0x00000000	/* nop */
+#define FZA_RING_CMD_INIT	0x00000001	/* initialize */
+#define FZA_RING_CMD_MODCAM	0x00000002	/* modify CAM */
+#define FZA_RING_CMD_PARAM	0x00000003	/* set system parameters */
+#define FZA_RING_CMD_MODPROM	0x00000004	/* modify promiscuous mode */
+#define FZA_RING_CMD_SETCHAR	0x00000005	/* set link characteristics */
+#define FZA_RING_CMD_RDCNTR	0x00000006	/* read counters */
+#define FZA_RING_CMD_STATUS	0x00000007	/* get link status */
+#define FZA_RING_CMD_RDCAM	0x00000008	/* read CAM */
+
+/* Command status constants. */
+#define FZA_RING_STAT_SUCCESS	0x00000000
+
+
+/* Unsolicited event descriptor ring entry. */
+struct fza_ring_uns {
+	u32 own;		/* bit 31: ownership, bits [30:0]: reserved */
+	u32 id;			/* event ID */
+	u32 buffer;		/* address of the buffer in the FZA space */
+	u32 pad0;		/* reserved */
+};
+
+#define FZA_RING_UNS		0x200800	/* unsolicited ring address */
+#define FZA_RING_UNS_SIZE	0x40		/* unsolicited descriptor ring
+						   size */
+/* Unsolicited event constants. */
+#define FZA_RING_UNS_UND	0x00000000	/* undefined event ID */
+#define FZA_RING_UNS_INIT_IN	0x00000001	/* ring init initiated */
+#define FZA_RING_UNS_INIT_RX	0x00000002	/* ring init received */
+#define FZA_RING_UNS_BEAC_IN	0x00000003	/* ring beaconing initiated */
+#define FZA_RING_UNS_DUP_ADDR	0x00000004	/* duplicate address detected */
+#define FZA_RING_UNS_DUP_TOK	0x00000005	/* duplicate token detected */
+#define FZA_RING_UNS_PURG_ERR	0x00000006	/* ring purger error */
+#define FZA_RING_UNS_STRIP_ERR	0x00000007	/* bridge strip error */
+#define FZA_RING_UNS_OP_OSC	0x00000008	/* ring op oscillation */
+#define FZA_RING_UNS_BEAC_RX	0x00000009	/* directed beacon received */
+#define FZA_RING_UNS_PCT_IN	0x0000000a	/* PC trace initiated */
+#define FZA_RING_UNS_PCT_RX	0x0000000b	/* PC trace received */
+#define FZA_RING_UNS_TX_UNDER	0x0000000c	/* transmit underrun */
+#define FZA_RING_UNS_TX_FAIL	0x0000000d	/* transmit failure */
+#define FZA_RING_UNS_RX_OVER	0x0000000e	/* receive overrun */
+
+
+/* RMC (Ring Memory Control) transmit descriptor ring entry. */
+struct fza_ring_rmc_tx {
+	u32 rmc;		/* RMC information */
+	u32 avl;		/* available for host (unused by RMC) */
+	u32 own;		/* bit 31: ownership, bits [30:0]: reserved */
+	u32 pad0;		/* reserved */
+};
+
+#define FZA_TX_BUFFER_ADDR(x)	(0x200000 | ((x & 0xffff) << 5))
+#define FZA_TX_BUFFER_SIZE	512
+struct fza_buffer_tx {
+	u32 data[FZA_TX_BUFFER_SIZE / sizeof(u32)];
+};
+
+/* Transmit ring RMC constants. */
+#define FZA_RING_TX_SOP		0x80000000	/* start of packet */
+#define FZA_RING_TX_EOP		0x40000000	/* end of packet */
+#define FZA_RING_TX_DTP		0x20000000	/* discard this packet */
+#define FZA_RING_TX_VBC		0x10000000	/* valid buffer byte count */
+#define FZA_RING_TX_DCC_MASK	0x0f000000	/* DMA completion code */
+#define FZA_RING_TX_DCC_SUCCESS	0x01000000	/* transmit succeeded */
+#define FZA_RING_TX_DCC_DTP_SOP	0x02000000	/* DTP set at SOP */
+#define FZA_RING_TX_DCC_DTP	0x04000000	/* DTP set within packet */
+#define FZA_RING_TX_DCC_ABORT	0x05000000	/* MAC-requested abort */
+#define FZA_RING_TX_DCC_PARITY	0x06000000	/* xmit data parity error */
+#define FZA_RING_TX_DCC_UNDRRUN	0x07000000	/* transmit underrun */
+#define FZA_RING_TX_XPO_MASK	0x003fe000	/* transmit packet offset */
+
+
+/* Host receive descriptor ring entry. */
+struct fza_ring_hst_rx {
+	u32 buf0_own;		/* bit 31: ownership, bits [30:23]: unused,
+				   bits [22:0]: right-shifted address of the
+				   buffer in system memory (low buffer) */
+	u32 buffer1;		/* bits [31:23]: unused,
+				   bits [22:0]: right-shifted address of the
+				   buffer in system memory (high buffer) */
+	u32 rmc;		/* RMC information */
+	u32 pad0;
+};
+
+#define FZA_RX_BUFFER_SIZE	(4096 + 512)	/* buffer length */
+
+/* Receive ring RMC constants. */
+#define FZA_RING_RX_SOP		0x80000000	/* start of packet */
+#define FZA_RING_RX_EOP		0x40000000	/* end of packet */
+#define FZA_RING_RX_FSC_MASK	0x38000000	/* # of frame status bits */
+#define FZA_RING_RX_FSB_MASK	0x07c00000	/* frame status bits */
+#define FZA_RING_RX_FSB_ERR	0x04000000	/* error detected */
+#define FZA_RING_RX_FSB_ADDR	0x02000000	/* address recognized */
+#define FZA_RING_RX_FSB_COP	0x01000000	/* frame copied */
+#define FZA_RING_RX_FSB_F0	0x00800000	/* first additional flag */
+#define FZA_RING_RX_FSB_F1	0x00400000	/* second additional flag */
+#define FZA_RING_RX_BAD		0x00200000	/* bad packet */
+#define FZA_RING_RX_CRC		0x00100000	/* CRC error */
+#define FZA_RING_RX_RRR_MASK	0x000e0000	/* MAC receive status bits */
+#define FZA_RING_RX_RRR_OK	0x00000000	/* receive OK */
+#define FZA_RING_RX_RRR_SADDR	0x00020000	/* source address matched */
+#define FZA_RING_RX_RRR_DADDR	0x00040000	/* dest address not matched */
+#define FZA_RING_RX_RRR_ABORT	0x00060000	/* RMC abort */
+#define FZA_RING_RX_RRR_LENGTH	0x00080000	/* invalid length */
+#define FZA_RING_RX_RRR_FRAG	0x000a0000	/* fragment */
+#define FZA_RING_RX_RRR_FORMAT	0x000c0000	/* format error */
+#define FZA_RING_RX_RRR_RESET	0x000e0000	/* MAC reset */
+#define FZA_RING_RX_DA_MASK	0x00018000	/* daddr match status bits */
+#define FZA_RING_RX_DA_NONE	0x00000000	/* no match */
+#define FZA_RING_RX_DA_PROM	0x00008000	/* promiscuous match */
+#define FZA_RING_RX_DA_CAM	0x00010000	/* CAM entry match */
+#define FZA_RING_RX_DA_LOCAL	0x00018000	/* link addr or LLC bcast */
+#define FZA_RING_RX_SA_MASK	0x00006000	/* saddr match status bits */
+#define FZA_RING_RX_SA_NONE	0x00000000	/* no match */
+#define FZA_RING_RX_SA_ALIAS	0x00002000	/* alias address match */
+#define FZA_RING_RX_SA_CAM	0x00004000	/* CAM entry match */
+#define FZA_RING_RX_SA_LOCAL	0x00006000	/* link address match */
+
+
+/* SMT (Station Management) transmit/receive descriptor ring entry. */
+struct fza_ring_smt {
+	u32 own;		/* bit 31: ownership, bits [30:0]: unused */
+	u32 rmc;		/* RMC information */
+	u32 buffer;		/* address of the buffer */
+	u32 pad0;		/* reserved */
+};
+
+/* Ownership constants.
+ *
+ * Only an owner is permitted to process a given ring entry.
+ * RMC transmit ring meanings are reversed.
+ */
+#define FZA_RING_OWN_MASK	0x80000000
+#define FZA_RING_OWN_FZA	0x00000000	/* permit FZA, forbid host */
+#define FZA_RING_OWN_HOST	0x80000000	/* permit host, forbid FZA */
+#define FZA_RING_TX_OWN_RMC	0x80000000	/* permit RMC, forbid host */
+#define FZA_RING_TX_OWN_HOST	0x00000000	/* permit host, forbid RMC */
+
+/* RMC constants. */
+#define FZA_RING_PBC_MASK	0x00001fff	/* frame length */
+
+
+/* Layout of counter buffers. */
+
+struct fza_counter {
+	u32 msw;
+	u32 lsw;
+};
+
+struct fza_counters {
+	struct fza_counter sys_buf;	/* system buffer unavailable */
+	struct fza_counter tx_under;	/* transmit underruns */
+	struct fza_counter tx_fail;	/* transmit failures */
+	struct fza_counter rx_over;	/* receive data overruns */
+	struct fza_counter frame_cnt;	/* frame count */
+	struct fza_counter error_cnt;	/* error count */
+	struct fza_counter lost_cnt;	/* lost count */
+	struct fza_counter rinit_in;	/* ring initialization initiated */
+	struct fza_counter rinit_rx;	/* ring initialization received */
+	struct fza_counter beac_in;	/* ring beacon initiated */
+	struct fza_counter dup_addr;	/* duplicate address test failures */
+	struct fza_counter dup_tok;	/* duplicate token detected */
+	struct fza_counter purg_err;	/* ring purge errors */
+	struct fza_counter strip_err;	/* bridge strip errors */
+	struct fza_counter pct_in;	/* traces initiated */
+	struct fza_counter pct_rx;	/* traces received */
+	struct fza_counter lem_rej;	/* LEM rejects */
+	struct fza_counter tne_rej;	/* TNE expiry rejects */
+	struct fza_counter lem_event;	/* LEM events */
+	struct fza_counter lct_rej;	/* LCT rejects */
+	struct fza_counter conn_cmpl;	/* connections completed */
+	struct fza_counter el_buf;	/* elasticity buffer errors */
+};
+
+
+/* Layout of command buffers. */
+
+/* INIT command buffer.
+ *
+ * Values of default link parameters given are as obtained from a
+ * DEFZA-AA rev. C03 board.  The board counts time in units of 80ns.
+ */
+struct fza_cmd_init {
+	u32 tx_mode;			/* transmit mode */
+	u32 hst_rx_size;		/* host receive ring entries */
+
+	struct fza_counters counters;	/* counters */
+
+	u8 rmc_rev[4];			/* RMC revision */
+	u8 rom_rev[4];			/* ROM revision */
+	u8 fw_rev[4];			/* firmware revision */
+
+	u32 mop_type;			/* MOP device type */
+
+	u32 hst_rx;			/* base of host rx descriptor ring */
+	u32 rmc_tx;			/* base of RMC tx descriptor ring */
+	u32 rmc_tx_size;		/* size of RMC tx descriptor ring */
+	u32 smt_tx;			/* base of SMT tx descriptor ring */
+	u32 smt_tx_size;		/* size of SMT tx descriptor ring */
+	u32 smt_rx;			/* base of SMT rx descriptor ring */
+	u32 smt_rx_size;		/* size of SMT rx descriptor ring */
+
+	u32 hw_addr[2];			/* link address */
+
+	u32 def_t_req;			/* default Requested TTRT (T_REQ) --
+					   C03: 100000 [80ns] */
+	u32 def_tvx;			/* default Valid Transmission Time
+					   (TVX) -- C03: 32768 [80ns] */
+	u32 def_t_max;			/* default Maximum TTRT (T_MAX) --
+					   C03: 2162688 [80ns] */
+	u32 lem_threshold;		/* default LEM threshold -- C03: 8 */
+	u32 def_station_id[2];		/* default station ID */
+
+	u32 pmd_type_alt;		/* alternative PMD type code */
+
+	u32 smt_ver;			/* SMT version */
+
+	u32 rtoken_timeout;		/* default restricted token timeout
+					   -- C03: 12500000 [80ns] */
+	u32 ring_purger;		/* default ring purger enable --
+					   C03: 1 */
+
+	u32 smt_ver_max;		/* max SMT version ID */
+	u32 smt_ver_min;		/* min SMT version ID */
+	u32 pmd_type;			/* PMD type code */
+};
+
+
+/* MODCAM/RDCAM command buffer. */
+#define FZA_CMD_CAM_SIZE	64		/* CAM address entry count */
+struct fza_cmd_cam {
+	u32 hw_addr[FZA_CMD_CAM_SIZE][2];	/* CAM address entries */
+};
+
+
+/* PARAM command buffer.
+ *
+ * Permitted ranges given are as defined by the spec and obtained from a
+ * DEFZA-AA rev. C03 board, respectively.  The rtoken_timeout field is
+ * erroneously interpreted in units of ms.
+ */
+struct fza_cmd_param {
+	u32 loop_mode;			/* loopback mode */
+	u32 t_max;			/* Maximum TTRT (T_MAX)
+					   def: ??? [80ns]
+					   C03: [t_req+1,4294967295] [80ns] */
+	u32 t_req;			/* Requested TTRT (T_REQ)
+					   def: [50000,2097151] [80ns]
+					   C03: [50001,t_max-1] [80ns] */
+	u32 tvx;			/* Valid Transmission Time (TVX)
+					   def: [29375,65280] [80ns]
+					   C03: [29376,65279] [80ns] */
+	u32 lem_threshold;		/* LEM threshold */
+	u32 station_id[2];		/* station ID */
+	u32 rtoken_timeout;		/* restricted token timeout
+					   def: [0,125000000] [80ns]
+					   C03: [0,9999] [ms] */
+	u32 ring_purger;		/* ring purger enable: 0|1 */
+};
+
+/* Loopback modes for the PARAM command. */
+#define FZA_LOOP_NORMAL		0
+#define FZA_LOOP_INTERN		1
+#define FZA_LOOP_EXTERN		2
+
+
+/* MODPROM command buffer. */
+struct fza_cmd_modprom {
+	u32 llc_prom;			/* LLC promiscuous enable */
+	u32 smt_prom;			/* SMT promiscuous enable */
+	u32 llc_multi;			/* LLC multicast promiscuous enable */
+	u32 llc_bcast;			/* LLC broadcast promiscuous enable */
+};
+
+
+/* SETCHAR command buffer.
+ *
+ * Permitted ranges are as for the PARAM command.
+ */
+struct fza_cmd_setchar {
+	u32 t_max;			/* Maximum TTRT (T_MAX) */
+	u32 t_req;			/* Requested TTRT (T_REQ) */
+	u32 tvx;			/* Valid Transmission Time (TVX) */
+	u32 lem_threshold;		/* LEM threshold */
+	u32 rtoken_timeout;		/* restricted token timeout */
+	u32 ring_purger;		/* ring purger enable */
+};
+
+
+/* RDCNTR command buffer. */
+struct fza_cmd_rdcntr {
+	struct fza_counters counters;	/* counters */
+};
+
+
+/* STATUS command buffer. */
+struct fza_cmd_status {
+	u32 led_state;			/* LED state */
+	u32 rmt_state;			/* ring management state */
+	u32 link_state;			/* link state */
+	u32 dup_addr;			/* duplicate address flag */
+	u32 ring_purger;		/* ring purger state */
+	u32 t_neg;			/* negotiated TTRT [80ns] */
+	u32 una[2];			/* upstream neighbour address */
+	u32 una_timeout;		/* UNA timed out */
+	u32 strip_mode;			/* frame strip mode */
+	u32 yield_mode;			/* claim token yield mode */
+	u32 phy_state;			/* PHY state */
+	u32 neigh_phy;			/* neighbour PHY type */
+	u32 reject;			/* reject reason */
+	u32 phy_lee;			/* PHY link error estimate [-log10] */
+	u32 una_old[2];			/* old upstream neighbour address */
+	u32 rmt_mac;			/* remote MAC indicated */
+	u32 ring_err;			/* ring error reason */
+	u32 beac_rx[2];			/* sender of last directed beacon */
+	u32 un_dup_addr;		/* upstream neighbr dup address flag */
+	u32 dna[2];			/* downstream neighbour address */
+	u32 dna_old[2];			/* old downstream neighbour address */
+};
+
+
+/* Common command buffer. */
+union fza_cmd_buf {
+	struct fza_cmd_init init;
+	struct fza_cmd_cam cam;
+	struct fza_cmd_param param;
+	struct fza_cmd_modprom modprom;
+	struct fza_cmd_setchar setchar;
+	struct fza_cmd_rdcntr rdcntr;
+	struct fza_cmd_status status;
+};
+
+
+/* MAC (Media Access Controller) chip packet request header constants. */
+
+/* Packet request header byte #0. */
+#define FZA_PRH0_FMT_TYPE_MASK	0xc0	/* type of packet, always zero */
+#define FZA_PRH0_TOK_TYPE_MASK	0x30	/* type of token required
+					   to send this frame */
+#define FZA_PRH0_TKN_TYPE_ANY	0x30	/* use either token type */
+#define FZA_PRH0_TKN_TYPE_UNR	0x20	/* use an unrestricted token */
+#define FZA_PRH0_TKN_TYPE_RST	0x10	/* use a restricted token */
+#define FZA_PRH0_TKN_TYPE_IMM	0x00	/* send immediately,
+					   no token required */
+#define FZA_PRH0_FRAME_MASK	0x08	/* type of frame to send */
+#define FZA_PRH0_FRAME_SYNC	0x08	/* send a synchronous frame */
+#define FZA_PRH0_FRAME_ASYNC	0x00	/* send an asynchronous frame */
+#define FZA_PRH0_MODE_MASK	0x04	/* send mode */
+#define FZA_PRH0_MODE_IMMED	0x04	/* an immediate mode, send regardless
+					   of the ring operational state */
+#define FZA_PRH0_MODE_NORMAL	0x00	/* a normal mode, send only if ring
+					   operational */
+#define FZA_PRH0_SF_MASK	0x02	/* send frame first */
+#define FZA_PRH0_SF_FIRST	0x02	/* send this frame first
+					   with this token capture */
+#define FZA_PRH0_SF_NORMAL	0x00	/* treat this frame normally */
+#define FZA_PRH0_BCN_MASK	0x01	/* beacon frame */
+#define FZA_PRH0_BCN_BEACON	0x01	/* send the frame only
+					   if in the beacon state */
+#define FZA_PRH0_BCN_DATA	0x01	/* send the frame only
+					   if in the data state */
+/* Packet request header byte #1. */
+					/* bit 7 always zero */
+#define FZA_PRH1_SL_MASK	0x40	/* send frame last */
+#define FZA_PRH1_SL_LAST	0x40	/* send this frame last, releasing
+					   the token afterwards */
+#define FZA_PRH1_SL_NORMAL	0x00	/* treat this frame normally */
+#define FZA_PRH1_CRC_MASK	0x20	/* CRC append */
+#define FZA_PRH1_CRC_NORMAL	0x20	/* calculate the CRC and append it
+					   as the FCS field to the frame */
+#define FZA_PRH1_CRC_SKIP	0x00	/* leave the frame as is */
+#define FZA_PRH1_TKN_SEND_MASK	0x18	/* type of token to send after the
+					   frame if this is the last frame */
+#define FZA_PRH1_TKN_SEND_ORIG	0x18	/* send a token of the same type as the
+					   originally captured one */
+#define FZA_PRH1_TKN_SEND_RST	0x10	/* send a restricted token */
+#define FZA_PRH1_TKN_SEND_UNR	0x08	/* send an unrestricted token */
+#define FZA_PRH1_TKN_SEND_NONE	0x00	/* send no token */
+#define FZA_PRH1_EXTRA_FS_MASK	0x07	/* send extra frame status
+					   indicators */
+#define FZA_PRH1_EXTRA_FS_ST	0x07	/* TR RR ST II */
+#define FZA_PRH1_EXTRA_FS_SS	0x06	/* TR RR SS II */
+#define FZA_PRH1_EXTRA_FS_SR	0x05	/* TR RR SR II */
+#define FZA_PRH1_EXTRA_FS_NONE1	0x04	/* TR RR II II */
+#define FZA_PRH1_EXTRA_FS_RT	0x03	/* TR RR RT II */
+#define FZA_PRH1_EXTRA_FS_RS	0x02	/* TR RR RS II */
+#define FZA_PRH1_EXTRA_FS_RR	0x01	/* TR RR RR II */
+#define FZA_PRH1_EXTRA_FS_NONE	0x00	/* TR RR II II */
+/* Packet request header byte #2. */
+#define FZA_PRH2_NORMAL		0x00	/* always zero */
+
+/* PRH used for LLC frames. */
+#define FZA_PRH0_LLC		(FZA_PRH0_TKN_TYPE_UNR)
+#define FZA_PRH1_LLC		(FZA_PRH1_CRC_NORMAL | FZA_PRH1_TKN_SEND_UNR)
+#define FZA_PRH2_LLC		(FZA_PRH2_NORMAL)
+
+/* PRH used for SMT frames. */
+#define FZA_PRH0_SMT		(FZA_PRH0_TKN_TYPE_UNR)
+#define FZA_PRH1_SMT		(FZA_PRH1_CRC_NORMAL | FZA_PRH1_TKN_SEND_UNR)
+#define FZA_PRH2_SMT		(FZA_PRH2_NORMAL)
+
+
+#if ((FZA_RING_RX_SIZE) < 2) || ((FZA_RING_RX_SIZE) > 256)
+# error FZA_RING_RX_SIZE has to be from 2 up to 256
+#endif
+#if ((FZA_RING_TX_MODE) != 0) && ((FZA_RING_TX_MODE) != 1)
+# error FZA_RING_TX_MODE has to be either 0 or 1
+#endif
+
+#define FZA_RING_TX_SIZE (512 << (FZA_RING_TX_MODE))
+
+struct fza_private {
+	struct device *bdev;		/* pointer to the bus device */
+	const char *name;		/* printable device name */
+	void __iomem *mmio;		/* MMIO ioremap cookie */
+	struct fza_regs __iomem *regs;	/* pointer to FZA registers */
+
+	struct sk_buff *rx_skbuff[FZA_RING_RX_SIZE];
+					/* all skbs assigned to the host
+					   receive descriptors */
+	dma_addr_t rx_dma[FZA_RING_RX_SIZE];
+					/* their corresponding DMA addresses */
+
+	struct fza_ring_cmd __iomem *ring_cmd;
+					/* pointer to the command descriptor
+					   ring */
+	int ring_cmd_index;		/* index to the command descriptor ring
+					   for the next command */
+	struct fza_ring_uns __iomem *ring_uns;
+					/* pointer to the unsolicited
+					   descriptor ring */
+	int ring_uns_index;		/* index to the unsolicited descriptor
+					   ring for the next event */
+
+	struct fza_ring_rmc_tx __iomem *ring_rmc_tx;
+					/* pointer to the RMC transmit
+					   descriptor ring (obtained from the
+					   INIT command) */
+	int ring_rmc_tx_size;		/* number of entries in the RMC
+					   transmit descriptor ring (obtained
+					   from the INIT command) */
+	int ring_rmc_tx_index;		/* index to the RMC transmit descriptor
+					   ring for the next transmission */
+	int ring_rmc_txd_index;		/* index to the RMC transmit descriptor
+					   ring for the next transmit done
+					   acknowledge */
+
+	struct fza_ring_hst_rx __iomem *ring_hst_rx;
+					/* pointer to the host receive
+					   descriptor ring (obtained from the
+					   INIT command) */
+	int ring_hst_rx_size;		/* number of entries in the host
+					   receive descriptor ring (set by the
+					   INIT command) */
+	int ring_hst_rx_index;		/* index to the host receive descriptor
+					   ring for the next transmission */
+
+	struct fza_ring_smt __iomem *ring_smt_tx;
+					/* pointer to the SMT transmit
+					   descriptor ring (obtained from the
+					   INIT command) */
+	int ring_smt_tx_size;		/* number of entries in the SMT
+					   transmit descriptor ring (obtained
+					   from the INIT command) */
+	int ring_smt_tx_index;		/* index to the SMT transmit descriptor
+					   ring for the next transmission */
+
+	struct fza_ring_smt __iomem *ring_smt_rx;
+					/* pointer to the SMT transmit
+					   descriptor ring (obtained from the
+					   INIT command) */
+	int ring_smt_rx_size;		/* number of entries in the SMT
+					   receive descriptor ring (obtained
+					   from the INIT command) */
+	int ring_smt_rx_index;		/* index to the SMT receive descriptor
+					   ring for the next transmission */
+
+	struct fza_buffer_tx __iomem *buffer_tx;
+					/* pointer to the RMC transmit
+					   buffers */
+
+	uint state;			/* adapter expected state */
+
+	spinlock_t lock;		/* for device & private data access */
+	uint int_mask;			/* interrupt source selector */
+
+	int cmd_done_flag;		/* command completion trigger */
+	wait_queue_head_t cmd_done_wait;
+
+	int state_chg_flag;		/* state change trigger */
+	wait_queue_head_t state_chg_wait;
+
+	struct timer_list reset_timer;	/* RESET time-out trigger */
+	int timer_state;		/* RESET trigger state */
+
+	int queue_active;		/* whether to enable queueing */
+
+	struct net_device_stats stats;
+
+	uint irq_count_flush_tx;	/* transmit flush irqs */
+	uint irq_count_uns_poll;	/* unsolicited event irqs */
+	uint irq_count_smt_tx_poll;	/* SMT transmit irqs */
+	uint irq_count_rx_poll;		/* host receive irqs */
+	uint irq_count_tx_done;		/* transmit done irqs */
+	uint irq_count_cmd_done;	/* command done irqs */
+	uint irq_count_state_chg;	/* state change irqs */
+	uint irq_count_link_st_chg;	/* link status change irqs */
+
+	uint t_max;			/* T_MAX */
+	uint t_req;			/* T_REQ */
+	uint tvx;			/* TVX */
+	uint lem_threshold;		/* LEM threshold */
+	uint station_id[2];		/* station ID */
+	uint rtoken_timeout;		/* restricted token timeout */
+	uint ring_purger;		/* ring purger enable flag */
+};
+
+struct fza_fddihdr {
+	u8 pa[2];			/* preamble */
+	u8 sd;				/* starting delimiter */
+	struct fddihdr hdr;
+} __packed;
Index: net-20140407-4maxp64/include/linux/netdevice.h
===================================================================
--- net-20140407-4maxp64.orig/include/linux/netdevice.h
+++ net-20140407-4maxp64/include/linux/netdevice.h
@@ -1887,6 +1887,7 @@ netdev_notifier_info_to_dev(const struct
 int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 
+extern struct list_head			ptype_all;		/* Taps */
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 #define for_each_netdev(net, d)		\
@@ -2631,6 +2632,7 @@ int dev_set_mac_address(struct net_devic
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_port_id *ppid);
+void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev);
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			struct netdev_queue *txq);
 int dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
Index: net-20140407-4maxp64/include/uapi/linux/if_fddi.h
===================================================================
--- net-20140407-4maxp64.orig/include/uapi/linux/if_fddi.h
+++ net-20140407-4maxp64/include/uapi/linux/if_fddi.h
@@ -5,9 +5,10 @@
  *
  *		Global definitions for the ANSI FDDI interface.
  *
- * Version:	@(#)if_fddi.h	1.0.2	Sep 29 2004
+ * Version:	@(#)if_fddi.h	1.0.3	Apr  5 2014
  *
- * Author:	Lawrence V. Stefani, <stefani@lkg.dec.com>
+ * Author:	Lawrence V. Stefani, <stefani@yahoo.com>
+ * Maintainer:	Maciej W. Rozycki, <macro@linux-mips.org>
  *
  *		if_fddi.h is based on previous if_ether.h and if_tr.h work by
  *			Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
@@ -44,7 +45,21 @@
 #define FDDI_K_OUI_LEN		3	/* Octets in OUI in 802.2 SNAP
 					   header */
 
-/* Define FDDI Frame Control (FC) Byte values */
+/* Define FDDI Frame Control (FC) Byte masks */
+#define FDDI_FC_K_CLASS_MASK		0x80	/* class bit */
+#define FDDI_FC_K_CLASS_SYNC		0x80
+#define FDDI_FC_K_CLASS_ASYNC		0x00
+#define FDDI_FC_K_ALEN_MASK		0x40	/* address length bit */
+#define FDDI_FC_K_ALEN_48		0x40
+#define FDDI_FC_K_ALEN_16		0x00
+#define FDDI_FC_K_FORMAT_MASK		0x30	/* format bits */
+#define FDDI_FC_K_FORMAT_FUTURE		0x30
+#define FDDI_FC_K_FORMAT_IMPLEMENTOR	0x20
+#define FDDI_FC_K_FORMAT_LLC		0x10
+#define FDDI_FC_K_FORMAT_MANAGEMENT	0x00
+#define FDDI_FC_K_CONTROL_MASK		0x0f	/* control bits */
+
+/* Define FDDI Frame Control (FC) Byte specific values */
 #define FDDI_FC_K_VOID			0x00
 #define FDDI_FC_K_NON_RESTRICTED_TOKEN	0x80
 #define FDDI_FC_K_RESTRICTED_TOKEN	0xC0
Index: net-20140407-4maxp64/net/core/dev.c
===================================================================
--- net-20140407-4maxp64.orig/net/core/dev.c
+++ net-20140407-4maxp64/net/core/dev.c
@@ -144,7 +144,8 @@
 static DEFINE_SPINLOCK(ptype_lock);
 static DEFINE_SPINLOCK(offload_lock);
 struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
-struct list_head ptype_all __read_mostly;	/* Taps */
+struct list_head ptype_all __read_mostly;		/* Taps */
+EXPORT_SYMBOL(ptype_all);
 static struct list_head offload_base __read_mostly;
 
 static int netif_rx_internal(struct sk_buff *skb);
@@ -1730,7 +1731,7 @@ static inline bool skb_loop_sk(struct pa
  *	taps currently in use.
  */
 
-static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
+void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct packet_type *ptype;
 	struct sk_buff *skb2 = NULL;
@@ -1778,6 +1779,7 @@ static void dev_queue_xmit_nit(struct sk
 		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL(dev_queue_xmit_nit);
 
 /**
  * netif_setup_tc - Handle tc mappings on real_num_tx_queues change
