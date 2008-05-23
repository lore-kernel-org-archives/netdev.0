From: "Kevin D. Kissell" <kevink@mips.com>
Subject: Re: Patch to add M3Pnet Driver
Date: Fri, 23 May 2008 18:42:52 +0200
Message-ID: <4836F40C.804@mips.com>
References: <4835F799.6070302@mips.com> <20080523023623.GA17651@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050700070400040604080502"
Cc: Ralf Baechle <ralf@linux-mips.org>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mips.com ([63.167.95.198]:33130 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913AbYEWRP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 13:15:58 -0400
In-Reply-To: <20080523023623.GA17651@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050700070400040604080502
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Guysm

Yet another network driver is probably not what the world needs most,
but I had to write one for MIPS Linux this month that was a little
different from any of the others.  It's a driver that impersonates
an ethernet interface whilst actually passing packets in memory between
different processors running different OS images in a shared memory
environment, something that actually happens in embedded systems.
I call it M3P (pronounced "mep"), for MIPS Memory Message Passing,
but if I didn't think it could be adapted to non-MIPS based and indeed
heterogeneous systems, I wouldn't trouble you with it.  I note that
the "mipsnet" driver, which is limited in its function to running
on a MIPS simulator, made it in, so I figured I'd at least ask if
it's something that could be absorbed into the network driver mass,
the better for other folks to improve on it - there are a lot of
enhancements I'd like to make, some of which are described in the
comments, but it's not clear that I'll have time to make them any
time soon.  A familiar refrain, I suppose.  Anyway, the patch is
attached.  See also Ralf's ack below.

			Regards,

			Kevin K.

Ralf Baechle wrote:
> On Fri, May 23, 2008 at 12:45:45AM +0200, Kevin D. Kissell wrote:
>> From: "Kevin D. Kissell" <kevink@mips.com>
>> Date: Fri, 23 May 2008 00:45:45 +0200
>> To: Linux MIPS Org <linux-mips@linux-mips.org>
>> Subject: Patch to add M3Pnet Driver
>> Content-Type: multipart/mixed;
>> 	boundary="------------050707080700070300010401"
>>
>> As per previous messages, here's 2 of 2
> 
> This is largely a network driver patch with minor arch bits thrown in so
> this one will have to go via jeff@garzik.org and netdev@vger.kernel.org.
> The MIPS bits are looking good though so feel free to add my
> 
> Acked-by: Ralf Baechle <ralf@linux-mips.org>
> 
> line for them.
> 
>   Ralf


--------------050700070400040604080502
Content-Type: text/x-patch;
 name="0002-Add-support-for-M3P-MIPS-Memory-Message-Passing-ps.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0002-Add-support-for-M3P-MIPS-Memory-Message-Passing-ps.patc";
 filename*1="h"

>From f98ebc82b0273d30e0a29943a1553a60c7684200 Mon Sep 17 00:00:00 2001
From: Kevin D. Kissell <kevink@mips.com>
Date: Thu, 22 May 2008 16:34:42 +0200
Subject: [PATCH] Add support for M3P (MIPS Memory Message Passing) pseudo-ethernet
 device for communication between e.g. AP and RP in APRP Linux.
 Signed-off-by: Kevin D. Kissell <kevink@mips.com>

---
 arch/mips/mips-boards/generic/Makefile   |    3 +-
 arch/mips/mips-boards/generic/platform.c |   34 +++
 drivers/net/Kconfig                      |    8 +
 drivers/net/Makefile                     |    1 +
 drivers/net/m3pnet.c                     |  431 ++++++++++++++++++++++++++++++
 drivers/net/m3pnet.h                     |   47 ++++
 6 files changed, 523 insertions(+), 1 deletions(-)
 create mode 100644 arch/mips/mips-boards/generic/platform.c
 create mode 100644 drivers/net/m3pnet.c
 create mode 100644 drivers/net/m3pnet.h

diff --git a/arch/mips/mips-boards/generic/Makefile b/arch/mips/mips-boards/generic/Makefile
index b31d8df..6f0d02b 100644
--- a/arch/mips/mips-boards/generic/Makefile
+++ b/arch/mips/mips-boards/generic/Makefile
@@ -19,10 +19,11 @@
 #
 
 obj-y				:= reset.o display.o init.o memory.o \
-				   cmdline.o time.o
+				   cmdline.o time.o platform.o
 
 obj-$(CONFIG_EARLY_PRINTK)	+= console.o
 obj-$(CONFIG_PCI)		+= pci.o
 obj-$(CONFIG_KGDB)		+= gdb_hook.o
+obj-$(CONFIG_MIPS_M3P_NET)	+= platform.o
 
 EXTRA_CFLAGS += -Werror
diff --git a/arch/mips/mips-boards/generic/platform.c b/arch/mips/mips-boards/generic/platform.c
new file mode 100644
index 0000000..1d56094
--- /dev/null
+++ b/arch/mips/mips-boards/generic/platform.c
@@ -0,0 +1,34 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2008 by Kevin D. Kissell, MIPS Technologies Inc.
+ */
+#include <linux/init.h>
+#include <linux/if_ether.h>
+#include <linux/kernel.h>
+#include <linux/platform_device.h>
+
+static char m3pnet_string[] = "m3pnet";
+
+static struct platform_device eth3_device = {
+	.name		= m3pnet_string,
+	.id		= 0,
+};
+
+/*
+ * Create a platform device for the M3P driver
+ */
+static int __init m3pnet_devinit(void)
+{
+	int err;
+
+	err = platform_device_register(&eth3_device);
+	if (err)
+		printk(KERN_ERR "%s: registration failed\n", m3pnet_string);
+
+	return err;
+}
+
+device_initcall(m3pnet_devinit);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 28d284a..b38e2c5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -496,6 +496,14 @@ config MIPS_SIM_NET
 	  emulated by the MIPS Simulator.
 	  If you are not using a MIPSsim or are unsure, say N.
 
+config MIPS_M3P_NET
+	tristate "MIPS Memory Message Passing device"
+	depends on MIPS
+	help
+	  The M3PNET device is a pseudo-network device intended
+	  for communication between real or virtual processors
+	  running distinct OS images.
+	  If you are unsure, say N.
 config SGI_O2MACE_ETH
 	tristate "SGI O2 MACE Fast Ethernet support"
 	depends on SGI_IP32=y
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 931264b..140be5b 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -192,6 +192,7 @@ obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
+obj-$(CONFIG_MIPS_M3P_NET) += m3pnet.o
 obj-$(CONFIG_SGI_IOC3_ETH) += ioc3-eth.o
 obj-$(CONFIG_DECLANCE) += declance.o
 obj-$(CONFIG_ATARILANCE) += atarilance.o
diff --git a/drivers/net/m3pnet.c b/drivers/net/m3pnet.c
new file mode 100644
index 0000000..ab01d42
--- /dev/null
+++ b/drivers/net/m3pnet.c
@@ -0,0 +1,431 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ */
+
+/*
+ * Memory based message passing network "device". Written for
+ * MIPS systems, but probably more broadly usable. Initial prototype
+ * supports only a single point-to-point instance, with arbitrary
+ * "ethernet addresses" at either end.  It would probably be good
+ * to evolve M3PNet to support multipoint, with data structure
+ * indices trivially computed based on bits of the "NIC address".
+ */
+
+#include <linux/init.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <asm/spinlock.h>
+
+#include "m3pnet.h"
+
+#define M3PNET_VERSION "2008-05-22"
+
+static char m3pnet_string[] = "m3pnet";
+
+#define N_XBUF 8
+#define N_RBUF 8
+#define M3P_MTU 1500
+
+#define M3PSIZE (((N_XBUF+N_RBUF) * M3P_MTU)\
+	+ ((N_XBUF+N_RBUF)*sizeof(struct m3p_buffer))\
+	+ sizeof(struct m3p_channel))
+
+#define M3P_SEND 1
+#define M3P_RECV 2
+
+/* Arbitrary unique type for VPE shared area */
+
+#define M3P_AREA_TYPE 0xEC0BA8EA
+
+struct m3p_private {
+	int xblocked;
+	int rblocked;
+};
+
+
+#ifdef M3P_DEBUG
+void pktdump(unsigned char *pkt, int len)
+{
+	printk("m3p pkt: ");
+	while (len-- > 1)
+		printk("%02x", *pkt++);
+	printk("%02x\n", *pkt);
+}
+#endif /* M3P_DEBUG */
+
+static unsigned char *m3pnet_ringinit(struct m3p_buffer *pbuf,
+				unsigned char *pool, int nbufs)
+{
+	int i;
+
+	for (i = 0; i < nbufs; i++) {
+		if (i == 0)
+			pbuf[i].prev = &pbuf[nbufs - 1];
+		else
+			pbuf[i].prev = &pbuf[i - 1];
+		if (i == (nbufs - 1))
+			pbuf[i].next = &pbuf[0];
+		else
+			pbuf[i].next = &pbuf[i+1];
+		pbuf[i].size = M3P_MTU;
+		pbuf[i].length = 0;
+		pbuf[i].content = pool;
+		pool += M3P_MTU;
+	}
+	return(pool);
+}
+
+static void m3pnet_bufsetup(struct net_device *netdev)
+{
+	struct m3p_channel *pchan = (struct m3p_channel *)netdev->base_addr;
+	struct m3p_buffer *pbuf = (struct m3p_buffer *)(netdev->base_addr
+		+ sizeof(struct m3p_channel));
+	unsigned char *pcontent = (unsigned char *)(netdev->base_addr
+		+ sizeof(struct m3p_channel)
+		+ ((N_XBUF + N_RBUF) * sizeof(struct m3p_buffer)));
+
+	spin_lock_init(&pchan->lock);
+	pchan->send_head = pchan->send_tail = &pbuf[0];
+	pcontent = m3pnet_ringinit(pbuf, pcontent, N_XBUF);
+	/* Advance pointer to base of receive buffer array */
+	pbuf = &pbuf[N_XBUF];
+	pchan->recv_head = pchan->recv_tail = &pbuf[0];
+	pcontent = m3pnet_ringinit(pbuf, pcontent, N_RBUF);
+}
+
+
+#define DEFAULT_VPE 1
+
+static void m3p_ipi(struct net_device *dev, int type)
+{
+	/*
+	 * This needs to be abstracted through platform code
+	 * to use whatever hardware IPI mechanism is available.
+	 * Here we're assuming a MIPS APRP environment with
+	 * cross-VPE interrupt support.
+	 */
+	int vpe_send_interrupt(int v, int t);
+
+	/*
+	 * Only a single M3P device is supported in this version
+	 * of the driver.  With multiple devices, we would
+	 * store a VPE ID as part of the per-net_device
+	 * private data and use it here.
+	 */
+
+	(void)vpe_send_interrupt(DEFAULT_VPE, type);
+}
+
+static inline ssize_t m3pnet_send(struct net_device *dev,
+	struct sk_buff *skb)
+{
+	struct m3p_channel *pchan = (struct m3p_channel *)dev->base_addr;
+	unsigned int flags;
+	int kickstart = 0;
+
+	memcpy(pchan->send_tail->content, skb->data, skb->len);
+#ifdef M3P_DEBUG
+	printk("m3pnet_send (%d)", skb->len);
+	pktdump(pchan->send_tail->content, skb->len);
+#endif /* M3P_DEBUG */
+	spin_lock_irqsave(&pchan->lock, flags);
+	pchan->send_tail->length = skb->len;
+	if (pchan->send_tail->next->length == 0) {
+		/*
+		 * If the next buffer is free, advance in ring
+		 * and interrupt the other guy if necessary.
+		 */
+		if (pchan->send_head == pchan->send_tail)
+			kickstart = 1;
+		pchan->send_tail = pchan->send_tail->next;
+	}
+	spin_unlock_irqrestore(&pchan->lock, flags);
+	if (kickstart)
+		m3p_ipi(dev, M3P_SEND);
+
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+	dev_kfree_skb(skb);
+
+	return 0;
+}
+
+static int m3pnet_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct m3p_channel *pchan = (struct m3p_channel *)dev->base_addr;
+	struct m3p_private *private = (struct m3p_private *)dev->priv;
+
+	if (!m3p_can_send(pchan)) {
+		printk(KERN_ERR "M3P send channel blockage, skb discarded\n");
+		dev_kfree_skb(skb);
+		return 1;
+	}
+
+	m3pnet_send(dev, skb);
+
+	if (!m3p_can_send(pchan)) {
+		netif_stop_queue(dev);
+		private->xblocked = 1;
+	}
+
+	return 0;
+}
+
+static inline ssize_t m3pnet_receive(struct net_device *dev)
+{
+	struct sk_buff *skb;
+	struct m3p_channel *pchan = (struct m3p_channel *)dev->base_addr;
+	size_t len = pchan->recv_head->length;
+	unsigned char *cp;
+	unsigned int flags;
+	int kickstart = 0;
+
+	skb = dev_alloc_skb(len + NET_IP_ALIGN);
+	if (!skb) {
+		dev->stats.rx_dropped++;
+		return -ENOMEM;
+	}
+
+	skb_reserve(skb, NET_IP_ALIGN);
+	cp = skb_put(skb, len);
+	memcpy(cp, pchan->recv_head->content, len);
+#ifdef M3P_DEBUG
+	printk("m3pnet_recieve (%d)", len);
+	pktdump(cp, len);
+#endif /* M3P_DEBUG */
+	spin_lock_irqsave(&pchan->lock, flags);
+	/* It may be worth considering a "low water mark" for this */
+	if (pchan->recv_head->prev == pchan->recv_tail
+	&& pchan->recv_tail->length != 0)
+		kickstart = 1;
+	pchan->recv_head = pchan->recv_head->next;
+	pchan->recv_head->prev->length = 0;
+	spin_unlock_irqrestore(&pchan->lock, flags);
+	if (kickstart)
+		m3p_ipi(dev, M3P_RECV);
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	netif_rx(skb);
+
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
+
+	return len;
+}
+
+static irqreturn_t m3pnet_interrupt(int irq, void *dev_id)
+{
+	struct net_device *dev = dev_id;
+	struct m3p_channel *pchan = (struct m3p_channel *)dev->base_addr;
+	struct m3p_private *private = (struct m3p_private *)dev->priv;
+
+	irqreturn_t retval = IRQ_NONE;
+
+	if (irq == dev->irq) {
+
+		if (m3p_can_send(pchan) && private->xblocked) {
+			private->xblocked = 0;
+			netif_wake_queue(dev);
+			retval = IRQ_HANDLED;
+		}
+
+		while (m3p_can_receive(pchan)) {
+			m3pnet_receive(dev);
+			retval = IRQ_HANDLED;
+		}
+
+	} else {
+		printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
+		       dev->name, __FUNCTION__, irq);
+	}
+	return retval;
+}
+
+static int m3pnet_open(struct net_device *dev)
+{
+	int err;
+	struct m3p_channel *pchan = (struct m3p_channel *)dev->base_addr;
+	struct m3p_private *private = (struct m3p_private *)dev->priv;
+
+	err = request_irq(dev->irq, &m3pnet_interrupt,
+			  IRQF_SHARED, dev->name, (void *) dev);
+
+	if (err) {
+		kfree((char *)dev->base_addr);
+		return err;
+	}
+
+	/*
+	 * Initial design did buffer initialization
+	 * exclusively in probe routine, after memory
+	 * allocation.  In practice, if an APRP application
+	 * fails or terminates with the buffers in an
+	 * invalid state, we want have easy assurance
+	 * that the next run will see a sensible array.
+	 */
+
+	m3pnet_bufsetup(dev);
+
+	if (m3p_can_send(pchan))
+		netif_start_queue(dev);
+	else
+		private->xblocked = 1;
+
+	return 0;
+}
+
+static int m3pnet_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	free_irq(dev->irq, dev);
+	return 0;
+}
+
+static void m3pnet_set_mclist(struct net_device *dev)
+{
+}
+
+static int __init m3pnet_probe(struct platform_device *dev)
+{
+	struct net_device *netdev;
+	struct m3p_private *private;
+	int err;
+	int irq;
+	int arch_get_xcpu_irq(void);
+
+	netdev = alloc_etherdev(sizeof(struct m3p_private));
+	if (!netdev) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	SET_NETDEV_DEV(netdev, &dev->dev);
+
+	netdev->open			= m3pnet_open;
+	netdev->stop			= m3pnet_close;
+	netdev->hard_start_xmit		= m3pnet_xmit;
+	netdev->set_multicast_list	= m3pnet_set_mclist;
+
+	private = netdev->priv;
+	private->xblocked = 0;
+	private->rblocked = 0;
+
+	/*
+	 * Allocate and format send and receive buffer rings on channel
+	 */
+	netdev->base_addr = (unsigned long)kmalloc(M3PSIZE, GFP_KERNEL);
+	if (netdev->base_addr == 0) {
+		err = -ENOMEM;
+		goto  out_free_netdev;
+	}
+
+	m3pnet_bufsetup(netdev);
+
+	/*
+	 * Initial prototype is cross-VPE on pre-GIC Malta FPGA,
+	 * but future versions should support CMP. Push responsibility
+	 * for identifying IRQs to the generic architecture support code,
+	 * which will eventually get it from platform code.
+	 */
+
+	irq = arch_get_xcpu_irq();
+	if (irq >= 0)
+		netdev->irq = irq;
+	else  {
+		err = irq;
+		goto out_free_buffers;
+	}
+
+	/*
+	 * Lacking any better mechanism to allocate a MAC address we use a
+	 * random one ...
+	 */
+	random_ether_addr(netdev->dev_addr);
+
+	err = register_netdev(netdev);
+	if (err) {
+		printk(KERN_ERR "M3PNet: failed to register netdev.\n");
+		goto out_free_buffers;
+	}
+	/*
+	 * Not clear how this driver would ever be used in a non-APRP
+	 * configuration, but let's be sparing in our assumptions.
+	 */
+#ifdef CONFIG_MIPS_VPE_LOADER
+	else {
+		void mips_publish_vpe_area(int type, void *ptr);
+
+		mips_publish_vpe_area(M3P_AREA_TYPE, (void *)netdev->base_addr);
+	}
+#endif /* CONFIG_MIPS_VPE_LOADER */
+
+#ifdef M3P_DEBUG
+	printk(KERN_INFO "M3PNet driver probe returning 0 (success)\n");
+#endif /* M3P_DEBUG */
+	return 0;
+
+out_free_buffers:
+	kfree((char *)netdev->base_addr);
+
+out_free_netdev:
+	free_netdev(netdev);
+
+out:
+#ifdef M3P_DEBUG
+	printk(KERN_INFO "M3PNet driver probe returning %d\n", err);
+#endif /* M3P_DEBUG */
+	return err;
+}
+
+static int __exit m3pnet_device_remove(struct platform_device *device)
+{
+	struct net_device *dev = platform_get_drvdata(device);
+
+	unregister_netdev(dev);
+	kfree((char *)dev->base_addr);
+	free_netdev(dev);
+	platform_set_drvdata(device, NULL);
+
+	return 0;
+}
+
+static struct platform_driver m3pnet_driver = {
+	.probe	= m3pnet_probe,
+	.remove	= __devexit_p(m3pnet_device_remove),
+	.driver = {
+		.name	= m3pnet_string,
+		.owner	= THIS_MODULE,
+	}
+};
+
+static int __init m3pnet_init_module(void)
+{
+	int err;
+
+	printk(KERN_INFO "M3PNet Network driver. Version: %s. "
+	       "(c)2008 MIPS Technologies, Inc.\n", M3PNET_VERSION);
+
+	err = platform_driver_register(&m3pnet_driver);
+	if (err)
+		printk(KERN_ERR "Driver registration failed\n");
+
+	return err;
+}
+
+static void __exit m3pnet_exit_module(void)
+{
+	platform_driver_unregister(&m3pnet_driver);
+}
+
+module_init(m3pnet_init_module);
+module_exit(m3pnet_exit_module);
+MODULE_AUTHOR("Kevin D. Kissell");
+MODULE_DESCRIPTION("M3P Memory Message Pasing Driver");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/m3pnet.h b/drivers/net/m3pnet.h
new file mode 100644
index 0000000..de2e861
--- /dev/null
+++ b/drivers/net/m3pnet.h
@@ -0,0 +1,47 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ */
+#ifndef __M3PNET_H
+#define __M3PNET_H
+
+/*
+ * M3PNET passes messages in shared non-necessarily-hardware-coherent
+ * memory between real or virtual processors. Messages are copied from
+ * Linux (or other OS) network buffers into low-level M3P buffers,
+ * which are managed as a ring.
+ */
+
+struct m3p_buffer {
+	struct m3p_buffer *prev;
+	struct m3p_buffer *next;
+	int size;
+	void *content;
+	int length;
+};
+
+/*
+ * Channel structure here is implicitly point-to-point.
+ * The "RP"side of the prototype simply reverses the
+ * senses of "send" and "recv".  A more general and
+ * extensible scheme would be preferable, with bits
+ * of the "NIC" address used to select the queues.
+ */
+
+struct m3p_channel {
+	unsigned int status;
+	spinlock_t lock;
+	struct m3p_buffer *send_head;
+	struct m3p_buffer *send_tail;
+	struct m3p_buffer *recv_head;
+	struct m3p_buffer *recv_tail;
+};
+
+#define m3p_can_receive(c) \
+	(c->recv_head->length != 0)
+
+#define m3p_can_send(c) \
+	(c->send_tail->length == 0)
+
+#endif /* __MIPSNET_H */
-- 
1.5.3.3


--------------050700070400040604080502--
