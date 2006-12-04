From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: Re: [RFC patch] driver for the Opencores Ethernet Controller
Date: Mon, 04 Dec 2006 15:46:19 -0800
Message-ID: <200612042346.kB4NkJJP026630@oogie-boogie.ics.uci.edu>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
	<20061204110429.79b70d2e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oogie-boogie.ics.uci.edu ([128.195.1.41]:54569 "EHLO
	oogie-boogie.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967827AbWLDXsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 18:48:45 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

  > On Mon, 04 Dec 2006 10:01:01 -0800
  > Dan Nicolaescu <dann@ics.uci.edu> wrote:
  > 
  > > 
  > > Hi,
  > > 
  > > Here is a driver for the Opencores Ethernet Controller. I started from
  > > a 2.4 uClinux driver, ported it to 2.6, made it work, cleaned it up
  > > and added the MII interface. 
  > > 
  > > The Opencores Ethernet Controller is Verilog code that can be used to
  > > implement an Ethernet device in hardware. It needs to be coupled with
  > > a PHY and some buffer memory. Because of that devices that implement
  > > this controller can be very different. The code here tries to support
  > > that by having some parameters that need to be defined at compile
  > > time.
  > > 
  > > This is my first Ethernet driver, so comments/advice would be
  > > appreciated.
  > > 
  > > Thanks
  > >         --dan
  > > 
  > >  Kconfig    |    5 
  > >  open_eth.c | 1022 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  > >  open_eth.h |  132 +++++++
  > >  3 files changed, 1159 insertions(+)
  > 
  > Please run through scripts/Lindent or cleanup style.
  > Also has trailing whitespace.

Thanks for the review! I managed to send in the diff of my working
file instead of the one that I just cleaned up. Sorry about that. 

  > Gack, just put in correct define's avoid adding conditional
  > compilation stuff.

Gone, that was for debugging. 

  > > +
  > > +#if CONFIG_MII	
  > > +	struct mii_if_info mii_if;	/* MII lib hooks/info */
  > > +#endif	
  > 
  > Use select in Kconfig, to force MII

That was intentional, I don't want to add extra code to the kernel in
case MII is not otherwise enabled (for code size for embedded processors).

  > > +		else if (!(i % 8))
  > > +			printk(" ");
  > > +		printk(" %.2x", *(((unsigned char *)add) + i));
  > > +	}
  > > +	printk("\n");
  > > +}
  > > +#endif
  > > +
  > > +int dann_int_count = 0;
  > > +int dann_rx_count = 0;
  > > +int dann_tx_count = 0;
  > > +
  > > +static int oeth_open(struct net_device *dev)
  > > +{
  > > +	int ret;
  > > +	struct oeth_private *cep = netdev_priv(dev);
  > > +	struct oeth_regs *regs = cep->regs;
  > > +
  > > +	/*FIXME: just for debugging....*/
  > > +	memset((void*)OETH_SRAM_BUFF_BASE, 0, 0x4000);
  > > +	
  > > +	/* Install our interrupt handler. */
  > > +	ret = request_irq(OETH_IRQ, oeth_interrupt, 0, "eth", (void *)dev);
  > > +	if (ret)
  > > +	{
  > 
  > Why not use dev->name rather than "eth"?

Fixed.

  > Indentation. See Documentation style.
  > What about IRQF_SHARED?

Not sure, maybe I should make this another driver parameter. On my
platform is not shared...


  > > +		printk("request_irq failed for the Opencore ethernet device\n");
  > > +		return ret;
  > > +	}
  > > +	/* Enable the receiver and transmiter. */
  > > +	regs->moder |= OETH_MODER_RXEN | OETH_MODER_TXEN;
  > > +
  > > +	/* Start the queue, we are ready to process packets now. */
  > > +	netif_start_queue (dev);
  > > +	return 0;
  > > +}
  > > +
  > > +static int oeth_close(struct net_device *dev)
  > > +{
  > > +	struct oeth_private *cep = netdev_priv(dev);
  > > +	struct oeth_regs *regs = cep->regs;
  > > +	volatile struct oeth_bd *bdp;
  > > +	int i;
  > > +
  > > +	spin_lock_irq(&cep->lock);
  > > +	/* Disable the receiver and transmiter. */
  > > +	regs->moder &= ~(OETH_MODER_RXEN | OETH_MODER_TXEN);
  > > +
  > > +	bdp = cep->rx_bd_base;
  > > +	for (i = 0; i < OETH_RXBD_NUM; i++) {
  > > +		bdp->len_status &= ~(OETH_TX_BD_STATS | OETH_TX_BD_READY);
  > > +		bdp++;
  > > +	}
  > > +
  > > +	bdp = cep->tx_bd_base;
  > > +	for (i = 0; i < OETH_TXBD_NUM; i++) {
  > > +		bdp->len_status &= ~(OETH_RX_BD_STATS | OETH_RX_BD_EMPTY);
  > > +		bdp++;
  > > +	}
  > > +
  > > +	spin_unlock_irq(&cep->lock);
  > > +
  > > +	return 0;
  > > +}
  > > +
  > > +#if 1
  > > +static void* memcpy_hton (void *dest, void *data,  size_t n)
  > 
  > const ?

Nuked, not needed, it was just working around HW bugs. 

  > > +static int oeth_start_xmit(struct sk_buff *skb, struct net_device *dev)
  > > +{
  > > +	struct oeth_private *cep = netdev_priv(dev);
  > > +	volatile struct oeth_bd *bdp;
  > > +	unsigned long flags;
  > > +	u32 len_status;
  > > +
  > > +	spin_lock_irqsave(&cep->lock, flags);
  > > +
  > > +	if (cep->tx_full) {
  > > +		/* All transmit buffers are full.  Bail out. */
  > > +		printk("%s: tx queue full!.\n", dev->name);
  > > +		print_queue(cep->tx_bd_base, cep->tx_next, OETH_TXBD_NUM);
  > > +		spin_unlock_irqrestore(&cep->lock, flags);
  > > +		return 1;
  > return NETDEV_TX_BUSY.
  >
  > you forgot to call stop_queue

Fixed.

What should I return in the case below: 

if (skb->len > OETH_TX_BUFF_SIZE) {
        printk("%s: tx frame too long!.\n", dev->name);
        spin_unlock_irqrestore(&cep->lock, flags);
        return 1;
}
Even better, is there a way to make sure the network stack knows that
it should not try to send packets bigger than OETH_TX_BUFF_SIZE? 

  > > +
  > > +	/* Copy data to TX buffer. */
  > > +	memcpy_hton ((unsigned char *)bdp->addr, skb->data,  skb->len);
  > 
  > Use skb_copy_and_csum_dev and you get checksum offload for free.

Wouldn't that just add (a bit of) overhead? It performs the memcpy, but it also
checks if the HW is capable of doing the checksum (which it is)... 
Incidentally the memcpy_hton is just memcpy now.

  > > +
  > > +/* The interrupt handler. */
  > > +static irqreturn_t oeth_interrupt(int irq, void *dev_id, struct pt_regs *ptregs)
  > > +{
  > > +	struct	net_device *dev = dev_id;
  > > +	struct oeth_private *cep = netdev_priv(dev);
  > > +	volatile struct oeth_regs *regs = cep->regs;
  > > +	u32	int_events;
  > > +
  > > +	dann_int_count++;
  > > +
  > > +	spin_lock_irq(&cep->lock);
  > > +	
  > 
  > You are in interrupt handler, calling spin_lock_irq is unnecessary
  > and wrong.

Fixed.

  > > +		/* Process the incoming frame. */
  > > +		pkt_len = len_status >> 16;
  > > +
  > > +		skb = dev_alloc_skb(pkt_len);
  > 
  > netdev_alloc_skb now please

OK.


  > > +
  > > +		if (skb == NULL) {
  > > +			printk("%s: Memory squeeze, dropping packet.\n", dev->name);
  > 
  > add KERN_WARNING, and use net_ratelimit
  > 
  > > +			cep->stats.rx_dropped++;
  > > +		}
  > > +		else {
  > > +			skb->dev = dev;
  > > +			OEDRX((printk("RX in ETH buf\n")));
  > > +			OEDRX((oeth_print_packet((u32*)bdp->addr, pkt_len)));
  > > +
  > > +			memcpy_ntoh(skb_put(skb, pkt_len), (unsigned char *)bdp->addr, pkt_len);
  > 
  > 
  > Copying packet in IRQ routine causes long latencies.

Any suggestions on how else to do this?


  > > +
  > > +static int oeth_calc_crc(char *mac_addr)
  > > +{
  > > +	int result = 0;
  > > +	return (result & 0x3f);
  > > +}
  > Ah... that's not what you want, I'm sure. Did you read your
  > own code?

I had that from the original driver. I didn't check it. I deleted this
function and its only user as multicasting was obviously never
tested. 

  > > +/*
  > > + * Probe for an Opencores ethernet controller.
  > > + */
  > > +static struct net_device* __devinit oeth_probe(int unit)
  > > +{
  > > +	struct net_device *dev = alloc_etherdev(sizeof(struct oeth_private));
  > > +	if (!dev)
  > > +		return ERR_PTR(-ENOMEM);
  > > +	sprintf(dev->name, "eth%d", unit);
  > 
  > Unnecessary, already done by alloc_etherdev
  > 
  > > +
  > > +	if (!check_mem_region(OETH_BASE_ADDR, OETH_REGS_SIZE)) {
  > > +		SET_MODULE_OWNER(dev);
  > > +		if (oeth_init(dev, OETH_BASE_ADDR, OETH_IRQ) == 0){
  > > +			if (register_netdev(dev))
  > > +				printk(KERN_WARNING "Openethernet: No card found\n");
  > > +			else
  > > +				return dev;
  > > +		}
  > > +
  > > +	}
  > > +	return NULL;
  > > +}
  > > +
  > > +
  > > +#if CONFIG_MII
  > > +static int check_if_running(struct net_device *dev)
  > > +{
  > > +	if (!netif_running(dev))
  > > +		return -EINVAL;
  > > +	return 0;
  > > +}
  > 
  > Bogus wrapper.

OK. BTW this is present in 3 more files: hamachi.c, starfire.c and
sundance.c 


  > > +
  > > +/* Initialize the Open Ethernet MAC. */
  > > +static int oeth_init(struct net_device *dev, unsigned int base_addr,
  > > +			      unsigned int irq)
  > > +{
  > > +	struct oeth_private *cep = netdev_priv(dev);
  > > +	volatile struct oeth_regs *regs;
  > > +	volatile struct oeth_bd *tx_bd, *rx_bd;
  > > +	int i;
  > > +	unsigned long mem_addr = OETH_SRAM_BUFF_BASE;
  > > +
  > > +	/* Reset the private structure. */
  > > +	memset(cep, 0, sizeof (struct oeth_private));
  > 
  > Unnecessary already zeroed by alloc_etherdev

OK

  > 
  > Bogus indentation, bogus while loop??

That should not have been there. Fixed.


  > > +
  > > +	/* Fill in the fields of the device structure with ethernet values. */
  > > +	ether_setup(dev);
  > 
  > Already done by alloc_etherdev

OK


Here's an updated version.

 Kconfig    |    5 
 open_eth.c |  727 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 open_eth.h |  132 +++++++++++
 3 files changed, 864 insertions(+)

--- /dev/null	2006-09-20 11:38:04.545479250 -0700
+++ drivers/net/open_eth.c	2006-12-04 15:37:33.933175000 -0800
@@ -0,0 +1,727 @@
+/*
+ * Ethernet driver for Open Ethernet Controller (www.opencores.org).
+ *      Copyright (c) 2002 Simon Srot (simons@opencores.org)
+ *      Copyright (c) 2006 Tensilica Inc.
+ * 
+ * Based on:
+ *
+ * Ethernet driver for Motorola MPC8xx.
+ *      Copyright (c) 1997 Dan Malek (dmalek@jlc.net)
+ *
+ * mcen302.c: A Linux network driver for Mototrola 68EN302 MCU
+ *
+ *      Copyright (C) 1999 Aplio S.A. Written by Vadim Lebedev
+ *
+ * 
+ *  The Open Ethernet Controller is just a MAC, it needs to be
+ *  combined with a PHY and buffer memory in order to create an
+ *  ethernet device. Thus some of the hardware parameters are device
+ *  specific. They need to be defined in asm/hardware.h. Example:
+ * 
+ * The IRQ for the device:
+ * #define OETH_IRQ                1
+ * 
+ * The address where the MAC registers are mapped:
+ * #define OETH_BASE_ADDR          0xFD030000
+ *
+ * The address where the MAC RX/TX buffers are mapped:
+ * #define OETH_SRAM_BUFF_BASE     0xFD800000
+ * 
+ * Sizes for a RX or TX buffer:
+ * #define OETH_RX_BUFF_SIZE       2048
+ * #define OETH_TX_BUFF_SIZE       2048
+ * The number of RX and TX buffers:
+ * #define OETH_RXBD_NUM           16
+ * #define OETH_TXBD_NUM           16
+ * The PHY ID (needed if MII is enabled):
+ * #define OETH_PHY_ID             0
+ * 
+ * Code to perform the device specific initialization (REGS is a
+ *  struct oeth_regs*):
+ * #define OETH_PLATFORM_SPECIFIC_INIT(REGS)
+ * it should at least initialize the device MAC address in
+ *  REGS->mac_addr1 and REGS->mac_addr2.
+ * 
+ */
+
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/ioport.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/delay.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/module.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+
+#include <asm/hardware.h>
+
+#include "open_eth.h"
+
+#define DRV_NAME "OpencoresEthernet"
+
+/* The Opencores Ethernet driver needs some parameters from the
+ * hardware implementation. They should be defined in the
+ asm/hardware.h file. */
+
+/* Debug helpers. */
+/* #define OETH_DEBUG_TRANSMIT  */
+#ifdef OETH_DEBUG_TRANSMIT
+#define OEDTX(x) x
+#else
+#define OEDTX(x)
+#endif
+
+/* #define OETH_DEBUG_RECEIVE */
+#ifdef OETH_DEBUG_RECEIVE
+#define OEDRX(x) x
+#else
+#define OEDRX(x)
+#endif
+
+#define OETH_REGS_SIZE  0x1000	/* MAC registers + RX and TX descriptors */
+#define OETH_BD_BASE    (OETH_BASE_ADDR + 0x400)
+#define OETH_TOTAL_BD   128
+
+/* The transmitter timeout FIXME: dann this needs to be handled */
+#define OETH_TX_TIMEOUT	       (2*HZ)
+
+/* The buffer descriptors track the ring buffers. */
+struct oeth_private {
+	struct oeth_regs *regs;	/* Address of controller registers. */
+	struct oeth_bd *rx_bd_base;	/* Address of Rx BDs. */
+	struct oeth_bd *tx_bd_base;	/* Address of Tx BDs. */
+	u8 tx_next;		/* Next buffer to be sent */
+	u8 tx_last;		/* Next buffer to be checked if packet sent */
+	u8 tx_full;		/* Buffer ring full indicator */
+	u8 rx_cur;		/* Next buffer to be checked if packet received */
+
+#if CONFIG_MII
+	struct mii_if_info mii_if;	/* MII lib hooks/info */
+#endif
+	spinlock_t lock;
+	struct net_device_stats stats;
+};
+
+static int oeth_open(struct net_device *dev);
+static int oeth_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static void oeth_rx(struct net_device *dev);
+static void oeth_tx(struct net_device *dev);
+static irqreturn_t oeth_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+static int oeth_close(struct net_device *dev);
+static struct net_device_stats *oeth_get_stats(struct net_device *dev);
+static int oeth_set_mac_address(struct net_device *dev, void *addr);
+
+#if defined(OETH_DEBUG_RECEIVE) || defined(OETH_DEBUG_TRANSMIT)
+static void oeth_print_packet(u32 * add, int len)
+{
+	int i;
+
+	printk("ipacket: add = %p len = %d\n", add, len);
+	for (i = 0; i < len; i++) {
+		if (!(i % 16))
+			printk("\n");
+		else if (!(i % 8))
+			printk(" ");
+		printk(" %.2x", *(((unsigned char *)add) + i));
+	}
+	printk("\n");
+}
+#endif
+
+static int oeth_open(struct net_device *dev)
+{
+	int ret;
+	struct oeth_private *cep = netdev_priv(dev);
+	struct oeth_regs *regs = cep->regs;
+
+	/* Install our interrupt handler. */
+	ret = request_irq(OETH_IRQ, oeth_interrupt, 0, dev->name, (void *)dev);
+	if (ret) {
+		printk("request_irq failed for the Opencore ethernet device\n");
+		return ret;
+	}
+	/* Enable the receiver and transmiter. */
+	regs->moder |= OETH_MODER_RXEN | OETH_MODER_TXEN;
+
+	/* Start the queue, we are ready to process packets now. */
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int oeth_close(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	struct oeth_regs *regs = cep->regs;
+	volatile struct oeth_bd *bdp;
+	int i;
+
+	spin_lock_irq(&cep->lock);
+	/* Disable the receiver and transmiter. */
+	regs->moder &= ~(OETH_MODER_RXEN | OETH_MODER_TXEN);
+
+	bdp = cep->rx_bd_base;
+	for (i = 0; i < OETH_RXBD_NUM; i++) {
+		bdp->len_status &= ~(OETH_TX_BD_STATS | OETH_TX_BD_READY);
+		bdp++;
+	}
+
+	bdp = cep->tx_bd_base;
+	for (i = 0; i < OETH_TXBD_NUM; i++) {
+		bdp->len_status &= ~(OETH_RX_BD_STATS | OETH_RX_BD_EMPTY);
+		bdp++;
+	}
+
+	spin_unlock_irq(&cep->lock);
+
+	return 0;
+}
+
+static int oeth_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_bd *bdp;
+	unsigned long flags;
+	u32 len_status;
+
+	spin_lock_irqsave(&cep->lock, flags);
+
+	if (cep->tx_full) {
+		/* All transmit buffers are full.  Bail out. */
+		printk("%s: tx queue full!.\n", dev->name);
+		netif_stop_queue(dev);
+		spin_unlock_irqrestore(&cep->lock, flags);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Fill in a Tx ring entry. */
+	bdp = cep->tx_bd_base + cep->tx_next;
+
+	len_status = bdp->len_status;
+
+	/* Clear all of the status flags. */
+	len_status &= ~OETH_TX_BD_STATS;
+
+	/* If the frame is short, tell MAC to pad it. */
+	if (skb->len <= ETH_ZLEN)
+		len_status |= OETH_TX_BD_PAD;
+	else
+		len_status &= ~OETH_TX_BD_PAD;
+
+	OEDTX((printk("TX skb\n")));
+	OEDTX((oeth_print_packet((u32 *) skb->data, skb->len)));
+	OEDTX((printk("end TX skb print\n")));
+
+	if (skb->len > OETH_TX_BUFF_SIZE) {
+		printk("%s: tx frame too long!.\n", dev->name);
+		spin_unlock_irqrestore(&cep->lock, flags);
+		return 1;
+	}
+
+	/* Copy data to TX buffer. */
+	memcpy((unsigned char *)bdp->addr, skb->data, skb->len);
+
+	len_status = (len_status & 0x0000ffff) | (skb->len << 16);
+
+	if ((bdp->addr + (len_status >> 16))
+	    >= (OETH_SRAM_BUFF_BASE + OETH_TXBD_NUM * OETH_TX_BUFF_SIZE
+		+ OETH_RXBD_NUM * OETH_RX_BUFF_SIZE))
+		panic("MEMORY OVERWRITE at address: %x !!!\n",
+		      (bdp->addr + (len_status >> 16)));
+
+	OEDTX((printk("TX controller buff\n")));
+	OEDTX((oeth_print_packet((u32 *) bdp->addr, bdp->len_status >> 16)));
+	OEDTX(printk("end TX controller buff print\n"));
+
+	dev_kfree_skb(skb);
+
+	cep->tx_next =
+	    (cep->tx_next + 1 == OETH_TXBD_NUM) ? 0 : (cep->tx_next + 1);
+
+	if (cep->tx_next == cep->tx_last) {
+		cep->tx_full = 1;
+		/* Do not transmit anymore if the TX queue is full. */
+		netif_stop_queue(dev);
+	}
+
+	/* Send it on its way.  Tell controller its ready, interrupt when done,
+	 * and to put the CRC on the end. */
+	len_status |= (OETH_TX_BD_READY | OETH_TX_BD_IRQ | OETH_TX_BD_CRC);
+	bdp->len_status = len_status;
+
+	spin_unlock_irqrestore(&cep->lock, flags);
+
+	dev->trans_start = jiffies;
+	return 0;
+}
+
+/* The interrupt handler. */
+static irqreturn_t oeth_interrupt(int irq, void *dev_id, struct pt_regs *ptregs)
+{
+	struct net_device *dev = dev_id;
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_regs *regs = cep->regs;
+	u32 int_events;
+
+	spin_lock(&cep->lock);
+
+	/* Get the interrupt events that caused us to be here. */
+	int_events = regs->int_src;
+	/* Acknowledge interrupt. */
+	regs->int_src = int_events;
+
+	/* Handle receive event in its own function. */
+	if (int_events & (OETH_INT_RXF | OETH_INT_RXE))
+		oeth_rx(dev);
+
+	/* Handle transmit event in its own function. */
+	if (int_events & (OETH_INT_TXB | OETH_INT_TXE)) {
+		oeth_tx(dev);
+	}
+
+	/* Check for receive busy, i.e. packets coming but no place to
+	 * put them. */
+	if (int_events & OETH_INT_BUSY) {
+		if (!(int_events & (OETH_INT_RXF | OETH_INT_RXE)))
+			oeth_rx(dev);
+	}
+
+	spin_unlock(&cep->lock);
+
+	return IRQ_HANDLED;
+}
+
+static void oeth_tx(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_bd *bdp;
+
+	for (;;
+	     cep->tx_last =
+	     (cep->tx_last + 1 == OETH_TXBD_NUM) ? 0 : (cep->tx_last + 1)) {
+		u32 len_status;
+
+		bdp = cep->tx_bd_base + cep->tx_last;
+		len_status = bdp->len_status;
+
+		/* If the OETH_TX_BD_READY is set the transmission has
+		 * not been done yet! */
+		if ((len_status & OETH_TX_BD_READY)
+		    || ((cep->tx_last == cep->tx_next) && !cep->tx_full))
+			break;
+
+		/* Check status for errors. */
+		if (len_status & OETH_TX_BD_LATECOL)
+			cep->stats.tx_window_errors++;
+		if (len_status & OETH_TX_BD_RETLIM)
+			cep->stats.tx_aborted_errors++;
+		if (len_status & OETH_TX_BD_UNDERRUN)
+			cep->stats.tx_fifo_errors++;
+		if (len_status & OETH_TX_BD_CARRIER) {
+			cep->stats.tx_carrier_errors++;
+		}
+		if (len_status &
+		    (OETH_TX_BD_LATECOL | OETH_TX_BD_RETLIM |
+		     OETH_TX_BD_UNDERRUN))
+			cep->stats.tx_errors++;
+
+		cep->stats.tx_packets++;
+		cep->stats.tx_bytes += len_status >> 16;
+		cep->stats.collisions += (len_status & OETH_TX_BD_RETRY) >> 4;
+
+		if (cep->tx_full) {
+			cep->tx_full = 0;
+			/* We have freed an entry in the TX queue, we can
+			 * start transmitting again. */
+			if (netif_queue_stopped(dev))
+				netif_wake_queue(dev);
+		}
+	}
+}
+
+static void oeth_rx(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_bd *bdp;
+	struct sk_buff *skb;
+	int pkt_len;
+	int bad = 0;
+	int current_buff = cep->rx_cur;
+	static int last_current_buff = 0;
+
+	for (;;
+	     cep->rx_cur =
+	     (cep->rx_cur + 1 == OETH_RXBD_NUM) ? 0 : (cep->rx_cur + 1)) {
+		u32 len_status;
+		bdp = cep->rx_bd_base + cep->rx_cur;
+
+		/* First, grab all of the stats for the incoming
+		 * packet.  These get messed up if we get called due
+		 * to a busy condition. */
+		len_status = bdp->len_status;
+
+		if (len_status & OETH_RX_BD_EMPTY)
+			break;
+
+		/* Check status for errors. */
+		if (len_status & (OETH_RX_BD_TOOLONG | OETH_RX_BD_SHORT)) {
+			cep->stats.rx_length_errors++;
+			bad = 1;
+		}
+		if (len_status & OETH_RX_BD_DRIBBLE) {
+			cep->stats.rx_frame_errors++;
+			bad = 1;
+		}
+		if (len_status & OETH_RX_BD_CRCERR) {
+			cep->stats.rx_crc_errors++;
+			bad = 1;
+		}
+		if (len_status & OETH_RX_BD_OVERRUN) {
+			cep->stats.rx_crc_errors++;
+			bad = 1;
+		}
+		if (len_status & OETH_RX_BD_TOOLONG) {
+			cep->stats.rx_crc_errors++;
+			bad = 1;
+		}
+		if (len_status & OETH_RX_BD_MISS) {
+
+		}
+		if (len_status & OETH_RX_BD_LATECOL) {
+			cep->stats.rx_frame_errors++;
+			bad = 1;
+		}
+
+		if (bad) {
+			bdp->len_status = (len_status & ~OETH_RX_BD_STATS)
+			    | OETH_RX_BD_EMPTY;
+			continue;
+		}
+
+		/* Process the incoming frame. */
+		pkt_len = len_status >> 16;
+
+		skb = netdev_alloc_skb(pkt_len);
+
+		if (skb == NULL) {
+			printk("%s: Memory squeeze, dropping packet.\n",
+			       dev->name);
+			cep->stats.rx_dropped++;
+		} else {
+			skb->dev = dev;
+			OEDRX((printk("RX in ETH buf\n")));
+			OEDRX((oeth_print_packet((u32 *) bdp->addr, pkt_len)));
+
+			memcpy(skb_put(skb, pkt_len),
+			       (unsigned char *)bdp->addr, pkt_len);
+			OEDRX((printk("RX in memory\n")));
+			OEDRX((oeth_print_packet((u32 *) skb->data, pkt_len)));
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
+			cep->stats.rx_packets++;
+			cep->stats.rx_bytes += pkt_len;
+
+		}
+
+		bdp->len_status = (len_status & ~OETH_RX_BD_STATS)
+		    | OETH_RX_BD_EMPTY;
+	}
+}
+
+static struct net_device_stats *oeth_get_stats(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	return &cep->stats;
+}
+
+static int oeth_set_mac_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_regs *regs = cep->regs;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	regs->mac_addr1 = addr->sa_data[0] << 8 | addr->sa_data[1];
+	regs->mac_addr0 = addr->sa_data[2] << 24
+	    | addr->sa_data[3] << 16 | addr->sa_data[4] << 8 | addr->sa_data[5];
+	return 0;
+}
+
+static int __init oeth_init(struct net_device *dev, unsigned int base_addr,
+			    unsigned int irq);
+
+/*
+ * Probe for an Opencores ethernet controller.
+ */
+static struct net_device *__devinit oeth_probe(int unit)
+{
+	struct net_device *dev = alloc_etherdev(sizeof(struct oeth_private));
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (!check_mem_region(OETH_BASE_ADDR, OETH_REGS_SIZE)) {
+		SET_MODULE_OWNER(dev);
+		if (oeth_init(dev, OETH_BASE_ADDR, OETH_IRQ) == 0) {
+			if (register_netdev(dev))
+				printk(KERN_WARNING
+				       "Openethernet: No card found\n");
+			else
+				return dev;
+		}
+
+	}
+	return NULL;
+}
+
+#if CONFIG_MII
+static void oeth_get_drvinfo(struct net_device *dev,
+			     struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, "0.0");
+	strcpy(info->bus_info, "none");
+}
+
+static int oeth_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	spin_lock_irq(&cep->lock);
+	mii_ethtool_gset(&cep->mii_if, ecmd);
+	spin_unlock_irq(&cep->lock);
+	return 0;
+}
+
+static int oeth_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	int res;
+	spin_lock_irq(&cep->lock);
+	res = mii_ethtool_sset(&cep->mii_if, ecmd);
+	spin_unlock_irq(&cep->lock);
+	return res;
+}
+
+static int oeth_nway_reset(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	return mii_nway_restart(&cep->mii_if);
+}
+
+static u32 oeth_get_link(struct net_device *dev)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	return mii_link_ok(&cep->mii_if);
+}
+
+static struct ethtool_ops ethtool_ops = {
+	.get_drvinfo = oeth_get_drvinfo,
+	.get_link = oeth_get_link,
+	.get_settings = oeth_get_settings,
+	.set_settings = oeth_set_settings,
+	.nway_reset = oeth_nway_reset,
+};
+#endif
+
+/* MII Data accesses. */
+static int mdio_read(struct net_device *dev, int phy_id, int location)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	struct oeth_regs *regs = cep->regs;
+	int read_value, i;
+	volatile int v;
+
+	regs->miiaddress = (phy_id & OETH_MIIADDRESS_FIAD)
+	    | ((location << 8) & OETH_MIIADDRESS_RGAD);
+	regs->miicommand = OETH_MIICOMMAND_RSTAT;
+
+	/* Check if the MII is done. */
+	for (i = 10000; i >= 0; i--) {
+		v = regs->miistatus;
+		if (!(v & OETH_MIISTATUS_BUSY)) {
+			read_value = regs->miirx_data;
+			/* Don't leave miicommand in read status, it
+			 * seems to not be reset to 0 after completion. */
+			regs->miicommand = 0;
+			return read_value;
+		}
+	}
+	printk(KERN_ERR "mdio_read timeout %s\n", dev->name);
+	return -1;
+}
+
+static void mdio_write(struct net_device *dev, int phy_id, int location,
+		       int value)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	struct oeth_regs *regs = cep->regs;
+	int i;
+	volatile int v;
+	regs->miiaddress = (phy_id & OETH_MIIADDRESS_FIAD)
+	    | ((location << 8) & OETH_MIIADDRESS_RGAD);
+	regs->miitx_data = value;
+	regs->miicommand = OETH_MIICOMMAND_WCTRLDATA;
+	/* Check if the MII is done. */
+	for (i = 10000; i >= 0; i--) {
+		v = regs->miistatus;
+		if (!(v & OETH_MIISTATUS_BUSY))
+			return;
+	}
+	printk(KERN_ERR "mdio_write timeout %s\n", dev->name);
+}
+
+/* Initialize the Open Ethernet MAC. */
+static int oeth_init(struct net_device *dev, unsigned int base_addr,
+		     unsigned int irq)
+{
+	struct oeth_private *cep = netdev_priv(dev);
+	volatile struct oeth_regs *regs;
+	volatile struct oeth_bd *tx_bd, *rx_bd;
+	int i;
+	unsigned long mem_addr = OETH_SRAM_BUFF_BASE;
+
+	/* Initialize the lock. */
+	spin_lock_init(&cep->lock);
+
+	/* Memory regions for the controller registers and buffer space. */
+	request_region(base_addr, OETH_REGS_SIZE, DRV_NAME);
+	dev->base_addr = base_addr;
+	request_region(OETH_SRAM_BUFF_BASE,
+		       OETH_TXBD_NUM * OETH_TX_BUFF_SIZE
+		       + OETH_RXBD_NUM * OETH_RX_BUFF_SIZE, DRV_NAME);
+	/* Get pointer ethernet controller configuration registers. */
+	regs = cep->regs = (struct oeth_regs *)(base_addr);
+
+	/* Reset the controller. */
+	regs->moder = OETH_MODER_RST;	/* Reset ON */
+	regs->moder &= ~OETH_MODER_RST;	/* Reset OFF */
+
+	/* Setting TXBD base to OETH_TXBD_NUM. */
+	regs->tx_bd_num = OETH_TXBD_NUM;
+
+	/* Initialize TXBD pointer. */
+	cep->tx_bd_base = (struct oeth_bd *)OETH_BD_BASE;
+	tx_bd = cep->tx_bd_base;
+
+	/* Initialize RXBD pointer. */
+	cep->rx_bd_base = cep->tx_bd_base + OETH_TXBD_NUM;
+	rx_bd = cep->rx_bd_base;
+
+	/* Initialize receive/transmit pointers. */
+	cep->rx_cur = 0;
+	cep->tx_next = 0;
+	cep->tx_last = 0;
+	cep->tx_full = 0;
+
+	/* Set min (64) and max (1536) packet length. */
+	regs->packet_len = (64 << 16) | 1536;
+
+	/* Set IPGT, IPGR1, IPGR2 and COLLCONF registers to the
+	 * recommended values. */
+	regs->ipgt = 0x00000015;
+	regs->ipgr1 = 0x0000000c;
+	regs->ipgr2 = 0x00000012;
+	regs->collconf = 0x000f003f;
+
+	/* Set control module mode. Do not deal with PAUSE frames for now. */
+	regs->ctrlmoder = 0;
+
+#if CONFIG_MII
+	/* Initialize MII. */
+	cep->mii_if.dev = dev;
+	cep->mii_if.mdio_read = mdio_read;
+	cep->mii_if.mdio_write = mdio_write;
+	cep->mii_if.phy_id = OETH_PHY_ID;
+	cep->mii_if.phy_id_mask = OETH_MIIADDRESS_FIAD;
+	cep->mii_if.reg_num_mask = 0x1f;
+	SET_ETHTOOL_OPS(dev, &ethtool_ops);
+#endif
+
+	/* Platform specific initialization. This function should set
+	   at least the MAC address for the device. */
+	OETH_PLATFORM_SPECIFIC_INIT(regs);
+
+	/* Initialize TXBDs. */
+	for (i = 0; i < OETH_TXBD_NUM; i++) {
+		tx_bd[i].len_status =
+		    OETH_TX_BD_PAD | OETH_TX_BD_CRC | OETH_TX_BD_IRQ;
+		tx_bd[i].addr = mem_addr;
+		mem_addr += OETH_TX_BUFF_SIZE;
+	}
+	tx_bd[OETH_TXBD_NUM - 1].len_status |= OETH_TX_BD_WRAP;
+
+	/* Initialize RXBDs. */
+	for (i = 0; i < OETH_RXBD_NUM; i++) {
+		rx_bd[i].len_status = OETH_RX_BD_EMPTY | OETH_RX_BD_IRQ;
+		rx_bd[i].addr = mem_addr;
+		mem_addr += OETH_RX_BUFF_SIZE;
+	}
+	rx_bd[OETH_RXBD_NUM - 1].len_status |= OETH_RX_BD_WRAP;
+
+	/* Set default ethernet MAC address. */
+	dev->dev_addr[0] = (regs->mac_addr1 >> 8) & 0xff;
+	dev->dev_addr[1] = regs->mac_addr1 & 0xff;
+	dev->dev_addr[2] = (regs->mac_addr0 >> 24) & 0xff;
+	dev->dev_addr[3] = (regs->mac_addr0 >> 16) & 0xff;
+	dev->dev_addr[4] = (regs->mac_addr0 >> 8) & 0xff;
+	dev->dev_addr[5] = regs->mac_addr0 & 0xff;
+
+	/* Clear all pending interrupts. */
+	regs->int_src = 0xffffffff;
+
+	/* Promisc, IFG, CRCEn  */
+	regs->moder |= OETH_MODER_PAD | OETH_MODER_IFG | OETH_MODER_CRCEN;
+
+	/* Enable interrupt sources. */
+	regs->int_mask = OETH_INT_MASK_TXB | OETH_INT_MASK_TXE
+	    | OETH_INT_MASK_RXF | OETH_INT_MASK_RXE
+	    | OETH_INT_MASK_TXC | OETH_INT_MASK_RXC | OETH_INT_MASK_BUSY;
+
+	/* The Open Ethernet specific entries in the device structure. */
+	dev->open = oeth_open;
+	dev->hard_start_xmit = oeth_start_xmit;
+	dev->stop = oeth_close;
+	dev->get_stats = oeth_get_stats;
+	dev->set_mac_address = oeth_set_mac_address;
+	dev->irq = irq;
+	/* FIXME: Something needs to be done with dev->tx_timeout and
+	   dev->watchdog timeout here. */
+
+	printk("Open Ethernet Core Version 1.0\n");
+
+	return 0;
+}
+
+static struct net_device *oeth_dev;
+
+static int __init oeth_init_module(void)
+{
+	oeth_dev = oeth_probe(0);
+	if (!oeth_dev)
+		return PTR_ERR(oeth_dev);
+	return 0;
+}
+
+static void __exit oeth_cleanup_module(void)
+{
+	unregister_netdev(oeth_dev);
+	release_region(oeth_dev->base_addr, OETH_REGS_SIZE);
+	release_region(OETH_SRAM_BUFF_BASE,
+		       OETH_TXBD_NUM * OETH_TX_BUFF_SIZE
+		       + OETH_RXBD_NUM * OETH_RX_BUFF_SIZE);
+	free_netdev(oeth_dev);
+}
+
+module_init(oeth_init_module);
+module_exit(oeth_cleanup_module);
+
+MODULE_DESCRIPTION("Opencores ethernet driver.");
+MODULE_LICENSE("GPL");
--- /dev/null	2006-09-20 11:38:04.545479250 -0700
+++ drivers/net/open_eth.h	2006-12-04 15:00:55.000000000 -0800
@@ -0,0 +1,132 @@
+/* Ethernet configuration registers */
+struct oeth_regs {
+	u32 moder;		/* Mode Register */
+	u32 int_src;		/* Interrupt Source Register */
+	u32 int_mask;		/* Interrupt Mask Register */
+	u32 ipgt;		/* Back to Bak Inter Packet Gap Register */
+	u32 ipgr1;		/* Non Back to Back Inter Packet Gap Register 1 */
+	u32 ipgr2;		/* Non Back to Back Inter Packet Gap Register 2 */
+	u32 packet_len;		/* Packet Length Register (min. and max.) */
+	u32 collconf;		/* Collision and Retry Configuration Register */
+	u32 tx_bd_num;		/* Transmit Buffer Descriptor Number Register */
+	u32 ctrlmoder;		/* Control Module Mode Register */
+	u32 miimoder;		/* MII Mode Register */
+	u32 miicommand;		/* MII Command Register */
+	u32 miiaddress;		/* MII Address Register */
+	u32 miitx_data;		/* MII Transmit Data Register */
+	u32 miirx_data;		/* MII Receive Data Register */
+	u32 miistatus;		/* MII Status Register */
+	u32 mac_addr0;		/* MAC Individual Address Register 0 */
+	u32 mac_addr1;		/* MAC Individual Address Register 1 */
+	u32 hash_addr0;		/* Hash Register 0 */
+	u32 hash_addr1;		/* Hash Register 1 */
+};
+
+/* Ethernet buffer descriptor */
+struct oeth_bd {
+	u32 len_status;
+	u32 addr;		/* Buffer address */
+};
+
+/* Tx BD */
+#define OETH_TX_BD_READY        0x8000	/* Tx BD Ready */
+#define OETH_TX_BD_IRQ          0x4000	/* Tx BD IRQ Enable */
+#define OETH_TX_BD_WRAP         0x2000	/* Tx BD Wrap (last BD) */
+#define OETH_TX_BD_PAD          0x1000	/* Tx BD Pad Enable */
+#define OETH_TX_BD_CRC          0x0800	/* Tx BD CRC Enable */
+
+#define OETH_TX_BD_UNDERRUN     0x0100	/* Tx BD Underrun Status */
+#define OETH_TX_BD_RETRY        0x00F0	/* Tx BD Retry Status */
+#define OETH_TX_BD_RETLIM       0x0008	/* Tx BD Retransmission Limit Status */
+#define OETH_TX_BD_LATECOL      0x0004	/* Tx BD Late Collision Status */
+#define OETH_TX_BD_DEFER        0x0002	/* Tx BD Defer Status */
+#define OETH_TX_BD_CARRIER      0x0001	/* Tx BD Carrier Sense Lost Status */
+#define OETH_TX_BD_STATS        (OETH_TX_BD_UNDERRUN            | \
+                                OETH_TX_BD_RETRY                | \
+                                OETH_TX_BD_RETLIM               | \
+                                OETH_TX_BD_LATECOL              | \
+                                OETH_TX_BD_DEFER                | \
+                                OETH_TX_BD_CARRIER)
+
+/* Rx BD */
+#define OETH_RX_BD_EMPTY        0x8000	/* Rx BD Empty */
+#define OETH_RX_BD_IRQ          0x4000	/* Rx BD IRQ Enable */
+#define OETH_RX_BD_WRAP         0x2000	/* Rx BD Wrap (last BD) */
+
+#define OETH_RX_BD_MISS         0x0080	/* Rx BD Miss Status */
+#define OETH_RX_BD_OVERRUN      0x0040	/* Rx BD Overrun Status */
+#define OETH_RX_BD_INVSIMB      0x0020	/* Rx BD Invalid Symbol Status */
+#define OETH_RX_BD_DRIBBLE      0x0010	/* Rx BD Dribble Nibble Status */
+#define OETH_RX_BD_TOOLONG      0x0008	/* Rx BD Too Long Status */
+#define OETH_RX_BD_SHORT        0x0004	/* Rx BD Too Short Frame Status */
+#define OETH_RX_BD_CRCERR       0x0002	/* Rx BD CRC Error Status */
+#define OETH_RX_BD_LATECOL      0x0001	/* Rx BD Late Collision Status */
+#define OETH_RX_BD_STATS        (OETH_RX_BD_MISS                | \
+                                OETH_RX_BD_OVERRUN              | \
+                                OETH_RX_BD_INVSIMB              | \
+                                OETH_RX_BD_DRIBBLE              | \
+                                OETH_RX_BD_TOOLONG              | \
+                                OETH_RX_BD_SHORT                | \
+                                OETH_RX_BD_CRCERR               | \
+                                OETH_RX_BD_LATECOL)
+
+/* MODER Register */
+#define OETH_MODER_RXEN         0x00000001	/* Receive Enable  */
+#define OETH_MODER_TXEN         0x00000002	/* Transmit Enable */
+#define OETH_MODER_NOPRE        0x00000004	/* No Preamble  */
+#define OETH_MODER_BRO          0x00000008	/* Reject Broadcast */
+#define OETH_MODER_IAM          0x00000010	/* Use Individual Hash */
+#define OETH_MODER_PRO          0x00000020	/* Promiscuous (receive all) */
+#define OETH_MODER_IFG          0x00000040	/* Min. IFG not required */
+#define OETH_MODER_LOOPBCK      0x00000080	/* Loop Back */
+#define OETH_MODER_NOBCKOF      0x00000100	/* No Backoff */
+#define OETH_MODER_EXDFREN      0x00000200	/* Excess Defer */
+#define OETH_MODER_FULLD        0x00000400	/* Full Duplex */
+#define OETH_MODER_RST          0x00000800	/* Reset MAC */
+#define OETH_MODER_DLYCRCEN     0x00001000	/* Delayed CRC Enable */
+#define OETH_MODER_CRCEN        0x00002000	/* CRC Enable */
+#define OETH_MODER_HUGEN        0x00004000	/* Huge Enable */
+#define OETH_MODER_PAD          0x00008000	/* Pad Enable */
+#define OETH_MODER_RECSMALL     0x00010000	/* Receive Small */
+
+/* Interrupt Source Register */
+#define OETH_INT_TXB            0x00000001	/* Transmit Buffer IRQ */
+#define OETH_INT_TXE            0x00000002	/* Transmit Error IRQ */
+#define OETH_INT_RXF            0x00000004	/* Receive Frame IRQ */
+#define OETH_INT_RXE            0x00000008	/* Receive Error IRQ */
+#define OETH_INT_BUSY           0x00000010	/* Busy IRQ */
+#define OETH_INT_TXC            0x00000020	/* Transmit Control Frame IRQ */
+#define OETH_INT_RXC            0x00000040	/* Received Control Frame IRQ */
+
+/* Interrupt Mask Register */
+#define OETH_INT_MASK_TXB       0x00000001	/* Transmit Buffer IRQ Mask */
+#define OETH_INT_MASK_TXE       0x00000002	/* Transmit Error IRQ Mask */
+#define OETH_INT_MASK_RXF       0x00000004	/* Receive Frame IRQ Mask */
+#define OETH_INT_MASK_RXE       0x00000008	/* Receive Error IRQ Mask */
+#define OETH_INT_MASK_BUSY      0x00000010	/* Busy IRQ Mask */
+#define OETH_INT_MASK_TXC       0x00000020	/* Transmit Control Frame IRQ Mask */
+#define OETH_INT_MASK_RXC       0x00000040	/* Received Control Frame IRQ Mask */
+
+/* Control Module Mode Register */
+#define OETH_CTRLMODER_PASSALL  0x00000001	/* Pass Control Frames */
+#define OETH_CTRLMODER_RXFLOW   0x00000002	/* Receive Control Flow Enable */
+#define OETH_CTRLMODER_TXFLOW   0x00000004	/* Transmit Control Flow Enable */
+
+/* MII Mode Register */
+#define OETH_MIIMODER_CLKDIV    0x000000FF	/* Clock Divider */
+#define OETH_MIIMODER_NOPRE     0x00000100	/* No Preamble */
+#define OETH_MIIMODER_RST       0x00000200	/* MIIM Reset */
+
+/* MII Command Register */
+#define OETH_MIICOMMAND_SCANSTAT  0x00000001	/* Scan Status */
+#define OETH_MIICOMMAND_RSTAT     0x00000002	/* Read Status */
+#define OETH_MIICOMMAND_WCTRLDATA 0x00000004	/* Write Control Data */
+
+/* MII Address Register */
+#define OETH_MIIADDRESS_FIAD    0x0000001F	/* PHY Address */
+#define OETH_MIIADDRESS_RGAD    0x00001F00	/* RGAD Address */
+
+/* MII Status Register */
+#define OETH_MIISTATUS_LINKFAIL 0x00000001	/* Link Fail */
+#define OETH_MIISTATUS_BUSY     0x00000002	/* MII Busy */
+#define OETH_MIISTATUS_NVALID   0x00000004	/* Data in MII Status Register is invalid */
--- drivers/net/Kconfig~	2006-09-05 12:30:28.000000000 -0700
+++ drivers/net/Kconfig	2006-12-01 11:29:25.000000000 -0800
@@ -550,6 +550,11 @@
         help
           If you have an XT2000 board, you probably want to enable this driver.
 
+config OPENCORES_ETHERNET
+       tristate "Opencores.org Ethernet MAC driver"
+       depends on NET_ETHERNET
+       help
+	  
 config SUNBMAC
 	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
 	depends on NET_ETHERNET && SBUS && EXPERIMENTAL
