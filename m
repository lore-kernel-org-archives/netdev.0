From: Roberto Medina <robertoxmed@gmail.com>
Subject: [PATCH] net: eth: realtek: atp: checkpatch errors and warnings corrected
Date: Mon,  3 Nov 2014 19:24:33 +0100
Message-ID: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	Roberto Medina <robertoxmed@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roberto Medina <robertoxmed@gmail.com>

Several warnings and errors corrected using checkpatch.
Some warnings like "line over 80" are still present.

Before the patch:
	total: 16 errors, 155 warnings, 38 checks, 883 lines checked

With the patch:
	total: 0 errors, 64 warnings, 24 checks, 905 lines checked
	
Compile tested.

Signed-off-by: Roberto Medina <robertoxmed@gmail.com>
---
 drivers/net/ethernet/realtek/atp.c | 470 +++++++++++++++++++------------------
 1 file changed, 246 insertions(+), 224 deletions(-)

diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index d77d60e..8291260 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -1,43 +1,42 @@
 /* atp.c: Attached (pocket) ethernet adapter driver for linux. */
-/*
-	This is a driver for commonly OEM pocket (parallel port)
-	ethernet adapters based on the Realtek RTL8002 and RTL8012 chips.
-
-	Written 1993-2000 by Donald Becker.
-
-	This software may be used and distributed according to the terms of
-	the GNU General Public License (GPL), incorporated herein by reference.
-	Drivers based on or derived from this code fall under the GPL and must
-	retain the authorship, copyright and license notice.  This file is not
-	a complete program and may only be used when the entire operating
-	system is licensed under the GPL.
-
-	Copyright 1993 United States Government as represented by the Director,
-	National Security Agency.  Copyright 1994-2000 retained by the original
-	author, Donald Becker. The timer-based reset code was supplied in 1995
-	by Bill Carlson, wwc@super.org.
-
-	The author may be reached as becker@scyld.com, or C/O
-	Scyld Computing Corporation
-	410 Severn Ave., Suite 210
-	Annapolis MD 21403
-
-	Support information and updates available at
-	http://www.scyld.com/network/atp.html
-
-
-	Modular support/softnet added by Alan Cox.
-	_bit abuse fixed up by Alan Cox
-
-*/
+/*	This is a driver for commonly OEM pocket (parallel port)
+ *	ethernet adapters based on the Realtek RTL8002 and RTL8012 chips.
+ *
+ *	Written 1993-2000 by Donald Becker.
+ *
+ *	This software may be used and distributed according to the terms of
+ *	the GNU General Public License (GPL), incorporated herein by reference.
+ *	Drivers based on or derived from this code fall under the GPL and must
+ *	retain the authorship, copyright and license notice.  This file is not
+ *	a complete program and may only be used when the entire operating
+ *	system is licensed under the GPL.
+ *
+ *	Copyright 1993 United States Government as represented by the Director,
+ *	National Security Agency.  Copyright 1994-2000 retained by the original
+ *	author, Donald Becker. The timer-based reset code was supplied in 1995
+ *	by Bill Carlson, wwc@super.org.
+ *
+ *	The author may be reached as becker@scyld.com, or C/O
+ *	Scyld Computing Corporation
+ *	410 Severn Ave., Suite 210
+ *	Annapolis MD 21403
+ *
+ *	Support information and updates available at
+ *	http://www.scyld.com/network/atp.html
+ *
+ *	Modular support/softnet added by Alan Cox.
+ *	_bit abuse fixed up by Alan Cox
+ *
+ */
 
 static const char version[] =
 "atp.c:v1.09=ac 2002/10/01 Donald Becker <becker@scyld.com>\n";
 
 /* The user-configurable values.
-   These may be modified when a driver module is loaded.*/
+ * These may be modified when a driver module is loaded.
+ */
 
-static int debug = 1; 			/* 1 normal messages, 0 quiet .. 7 verbose. */
+static int debug = 1;	/* 1 normal messages, 0 quiet .. 7 verbose. */
 #define net_debug debug
 
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
@@ -47,80 +46,79 @@ static int max_interrupt_work = 15;
 /* The standard set of ISA module parameters. */
 static int io[NUM_UNITS];
 static int irq[NUM_UNITS];
-static int xcvr[NUM_UNITS]; 			/* The data transfer mode. */
+static int xcvr[NUM_UNITS];		/* The data transfer mode. */
 
 /* Operational parameters that are set at compile time. */
 
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (400*HZ/1000)
 
-/*
-	This file is a device driver for the RealTek (aka AT-Lan-Tec) pocket
-	ethernet adapter.  This is a common low-cost OEM pocket ethernet
-	adapter, sold under many names.
-
-  Sources:
-	This driver was written from the packet driver assembly code provided by
-	Vincent Bono of AT-Lan-Tec.	 Ever try to figure out how a complicated
-	device works just from the assembly code?  It ain't pretty.  The following
-	description is written based on guesses and writing lots of special-purpose
-	code to test my theorized operation.
-
-	In 1997 Realtek made available the documentation for the second generation
-	RTL8012 chip, which has lead to several driver improvements.
-	  http://www.realtek.com.tw/
-
-					Theory of Operation
-
-	The RTL8002 adapter seems to be built around a custom spin of the SEEQ
-	controller core.  It probably has a 16K or 64K internal packet buffer, of
-	which the first 4K is devoted to transmit and the rest to receive.
-	The controller maintains the queue of received packet and the packet buffer
-	access pointer internally, with only 'reset to beginning' and 'skip to next
-	packet' commands visible.  The transmit packet queue holds two (or more?)
-	packets: both 'retransmit this packet' (due to collision) and 'transmit next
-	packet' commands must be started by hand.
-
-	The station address is stored in a standard bit-serial EEPROM which must be
-	read (ughh) by the device driver.  (Provisions have been made for
-	substituting a 74S288 PROM, but I haven't gotten reports of any models
-	using it.)  Unlike built-in devices, a pocket adapter can temporarily lose
-	power without indication to the device driver.  The major effect is that
-	the station address, receive filter (promiscuous, etc.) and transceiver
-	must be reset.
-
-	The controller itself has 16 registers, some of which use only the lower
-	bits.  The registers are read and written 4 bits at a time.  The four bit
-	register address is presented on the data lines along with a few additional
-	timing and control bits.  The data is then read from status port or written
-	to the data port.
-
-	Correction: the controller has two banks of 16 registers.  The second
-	bank contains only the multicast filter table (now used) and the EEPROM
-	access registers.
-
-	Since the bulk data transfer of the actual packets through the slow
-	parallel port dominates the driver's running time, four distinct data
-	(non-register) transfer modes are provided by the adapter, two in each
-	direction.  In the first mode timing for the nibble transfers is
-	provided through the data port.  In the second mode the same timing is
-	provided through the control port.  In either case the data is read from
-	the status port and written to the data port, just as it is accessing
-	registers.
-
-	In addition to the basic data transfer methods, several more are modes are
-	created by adding some delay by doing multiple reads of the data to allow
-	it to stabilize.  This delay seems to be needed on most machines.
-
-	The data transfer mode is stored in the 'dev->if_port' field.  Its default
-	value is '4'.  It may be overridden at boot-time using the third parameter
-	to the "ether=..." initialization.
-
-	The header file <atp.h> provides inline functions that encapsulate the
-	register and data access methods.  These functions are hand-tuned to
-	generate reasonable object code.  This header file also documents my
-	interpretations of the device registers.
-*/
+/*	This file is a device driver for the RealTek (aka AT-Lan-Tec) pocket
+ *	ethernet adapter.  This is a common low-cost OEM pocket ethernet
+ *	adapter, sold under many names.
+ *
+ * Sources:
+ *	This driver was written from the packet driver assembly code provided by
+ *	Vincent Bono of AT-Lan-Tec.	 Ever try to figure out how a complicated
+ *	device works just from the assembly code?  It ain't pretty.  The following
+ *	description is written based on guesses and writing lots of special-purpose
+ *	code to test my theorized operation.
+ *
+ *	In 1997 Realtek made available the documentation for the second generation
+ *	RTL8012 chip, which has lead to several driver improvements.
+ *	  http://www.realtek.com.tw/
+ *
+ *				Theory of Operation
+ *
+ *	The RTL8002 adapter seems to be built around a custom spin of the SEEQ
+ *	controller core.  It probably has a 16K or 64K internal packet buffer, of
+ *	which the first 4K is devoted to transmit and the rest to receive.
+ *	The controller maintains the queue of received packet and the packet buffer
+ *	access pointer internally, with only 'reset to beginning' and 'skip to next
+ *	packet' commands visible.  The transmit packet queue holds two (or more?)
+ *	packets: both 'retransmit this packet' (due to collision) and 'transmit next
+ *	packet' commands must be started by hand.
+ *
+ *	The station address is stored in a standard bit-serial EEPROM which must be
+ *	read (ughh) by the device driver.  (Provisions have been made for
+ *	substituting a 74S288 PROM, but I haven't gotten reports of any models
+ *	using it.)  Unlike built-in devices, a pocket adapter can temporarily lose
+ *	power without indication to the device driver.  The major effect is that
+ *	the station address, receive filter (promiscuous, etc.) and transceiver
+ *	must be reset.
+ *
+ *	The controller itself has 16 registers, some of which use only the lower
+ *	bits.  The registers are read and written 4 bits at a time.  The four bit
+ *	register address is presented on the data lines along with a few additional
+ *	timing and control bits.  The data is then read from status port or written
+ *	to the data port.
+ *
+ *	Correction: the controller has two banks of 16 registers.  The second
+ *	bank contains only the multicast filter table (now used) and the EEPROM
+ *	access registers.
+ *
+ *	Since the bulk data transfer of the actual packets through the slow
+ *	parallel port dominates the driver's running time, four distinct data
+ *	(non-register) transfer modes are provided by the adapter, two in each
+ *	direction.  In the first mode timing for the nibble transfers is
+ *	provided through the data port.  In the second mode the same timing is
+ *	provided through the control port.  In either case the data is read from
+ *	the status port and written to the data port, just as it is accessing
+ *	registers.
+ *
+ *	In addition to the basic data transfer methods, several more are modes are
+ *	created by adding some delay by doing multiple reads of the data to allow
+ *	it to stabilize.  This delay seems to be needed on most machines.
+ *
+ *	The data transfer mode is stored in the 'dev->if_port' field.  Its default
+ *	value is '4'.  It may be overridden at boot-time using the third parameter
+ *	to the "ether=..." initialization.
+ *
+ *	The header file <atp.h> provides inline functions that encapsulate the
+ *	register and data access methods.  These functions are hand-tuned to
+ *	generate reasonable object code.  This header file also documents my
+ *	interpretations of the device registers.
+ */
 
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -140,7 +138,7 @@ static int xcvr[NUM_UNITS]; 			/* The data transfer mode. */
 #include <linux/delay.h>
 #include <linux/bitops.h>
 
-#include <asm/io.h>
+#include <linux/io.h>
 #include <asm/dma.h>
 
 #include "atp.h"
@@ -167,20 +165,21 @@ MODULE_PARM_DESC(xcvr, "ATP transceiver(s) (0=internal, 1=external)");
 static char mux_8012[] = { 0xff, 0xf7, 0xff, 0xfb, 0xf3, 0xfb, 0xff, 0xf7,};
 
 struct net_local {
-    spinlock_t lock;
-    struct net_device *next_module;
-    struct timer_list timer;	/* Media selection timer. */
-    long last_rx_time;		/* Last Rx, in jiffies, to handle Rx hang. */
-    int saved_tx_size;
-    unsigned int tx_unit_busy:1;
-    unsigned char re_tx,	/* Number of packet retransmissions. */
-		addr_mode,		/* Current Rx filter e.g. promiscuous, etc. */
+	spinlock_t lock;
+	struct net_device *next_module;
+	struct timer_list timer;	/* Media selection timer. */
+	long last_rx_time;	/* Last Rx, in jiffies, to handle Rx hang. */
+	int saved_tx_size;
+	unsigned int tx_unit_busy:1;
+	unsigned char re_tx,	/* Number of packet retransmissions. */
+		addr_mode,	/* Current Rx filter e.g. promiscuous, etc. */
 		pac_cnt_in_tx_buf;
 };
 
 /* This code, written by wwc@super.org, resets the adapter every
-   TIMED_CHECKER ticks.  This recovers from an unknown error which
-   hangs the device. */
+ * TIMED_CHECKER ticks.  This recovers from an unknown error which
+ * hangs the device.
+ */
 #define TIMED_CHECKER (HZ/4)
 #ifdef TIMED_CHECKER
 #include <linux/timer.h>
@@ -194,41 +193,43 @@ static void get_node_ID(struct net_device *dev);
 static unsigned short eeprom_op(long ioaddr, unsigned int cmd);
 static int net_open(struct net_device *dev);
 static void hardware_init(struct net_device *dev);
-static void write_packet(long ioaddr, int length, unsigned char *packet, int pad, int mode);
+static void write_packet(long ioaddr, int length, unsigned char *packet,
+			 int pad, int mode);
 static void trigger_send(long ioaddr, int length);
 static netdev_tx_t atp_send_packet(struct sk_buff *skb,
 				   struct net_device *dev);
 static irqreturn_t atp_interrupt(int irq, void *dev_id);
 static void net_rx(struct net_device *dev);
-static void read_block(long ioaddr, int length, unsigned char *buffer, int data_mode);
+static void read_block(long ioaddr, int length, unsigned char *buffer,
+		       int data_mode);
 static int net_close(struct net_device *dev);
 static void set_rx_mode(struct net_device *dev);
 static void tx_timeout(struct net_device *dev);
 
-
 /* A list of all installed ATP devices, for removing the driver module. */
 static struct net_device *root_atp_dev;
 
 /* Check for a network adapter of this type, and return '0' iff one exists.
-   If dev->base_addr == 0, probe all likely locations.
-   If dev->base_addr == 1, always return failure.
-   If dev->base_addr == 2, allocate space for the device and return success
-   (detachable devices only).
-
-   FIXME: we should use the parport layer for this
-   */
+ * If dev->base_addr == 0, probe all likely locations.
+ * If dev->base_addr == 1, always return failure.
+ * If dev->base_addr == 2, allocate space for the device and return success
+ * (detachable devices only).
+ *
+ *  FIXME: we should use the parport layer for this
+ */
 static int __init atp_init(void)
 {
 	int *port, ports[] = {0x378, 0x278, 0x3bc, 0};
 	int base_addr = io[0];
 
-	if (base_addr > 0x1ff)		/* Check a single specified location. */
+	if (base_addr > 0x1ff)	/* Check a single specified location. */
 		return atp_probe1(base_addr);
 	else if (base_addr == 1)	/* Don't probe at all. */
 		return -ENXIO;
 
 	for (port = ports; *port; port++) {
 		long ioaddr = *port;
+
 		outb(0x57, ioaddr + PAR_DATA);
 		if (inb(ioaddr + PAR_DATA) != 0x57)
 			continue;
@@ -246,7 +247,7 @@ static const struct net_device_ops atp_netdev_ops = {
 	.ndo_set_rx_mode	= set_rx_mode,
 	.ndo_tx_timeout		= tx_timeout,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -259,7 +260,8 @@ static int __init atp_probe1(long ioaddr)
 
 	outb(0xff, ioaddr + PAR_DATA);
 	/* Save the original value of the Control register, in case we guessed
-	   wrong. */
+	 *  wrong.
+	 */
 	saved_ctrl_reg = inb(ioaddr + PAR_CONTROL);
 	if (net_debug > 3)
 		printk("atp: Control register was %#2.2x.\n", saved_ctrl_reg);
@@ -330,8 +332,7 @@ static int __init atp_probe1(long ioaddr)
 		printk(KERN_INFO "%s", version);
 #endif
 
-	printk(KERN_NOTICE "%s: Pocket adapter found at %#3lx, IRQ %d, "
-	       "SAPROM %pM.\n",
+	printk(KERN_NOTICE "%s: Pocket adapter found at %#3lx, IRQ %d, SAPROM %pM.\n",
 	       dev->name, dev->base_addr, dev->irq, dev->dev_addr);
 
 	/* Reset the ethernet hardware and activate the printer pass-through. */
@@ -349,7 +350,7 @@ static int __init atp_probe1(long ioaddr)
 	if (dev->mem_end & 0xf)
 		net_debug = dev->mem_end & 7;
 
-	dev->netdev_ops 	= &atp_netdev_ops;
+	dev->netdev_ops		= &atp_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 
 	res = register_netdev(dev);
@@ -374,7 +375,8 @@ static void __init get_node_ID(struct net_device *dev)
 	write_reg(ioaddr, CMR2, CMR2_EEPROM);	  /* Point to the EEPROM control registers. */
 
 	/* Some adapters have the station address at offset 15 instead of offset
-	   zero.  Check for it, and fix it if needed. */
+	 * zero.  Check for it, and fix it if needed.
+	 */
 	if (eeprom_op(ioaddr, EE_READ(0)) == 0xffff)
 		sa_offset = 15;
 
@@ -385,9 +387,8 @@ static void __init get_node_ID(struct net_device *dev)
 	write_reg(ioaddr, CMR2, CMR2_NULL);
 }
 
-/*
-  An EEPROM read command starts by shifting out 0x60+address, and then
-  shifting in the serial data. See the NatSemi databook for details.
+/* An EEPROM read command starts by shifting out 0x60+address, and then
+ * shifting in the serial data. See the NatSemi databook for details.
  *		   ________________
  * CS : __|
  *			   ___	   ___
@@ -404,6 +405,7 @@ static unsigned short __init eeprom_op(long ioaddr, u32 cmd)
 
 	while (--num_bits >= 0) {
 		char outval = (cmd & (1<<num_bits)) ? EE_DATA_WRITE : 0;
+
 		write_reg_high(ioaddr, PROM_CMD, outval | EE_CLK_LOW);
 		write_reg_high(ioaddr, PROM_CMD, outval | EE_CLK_HIGH);
 		eedata_out <<= 1;
@@ -414,25 +416,25 @@ static unsigned short __init eeprom_op(long ioaddr, u32 cmd)
 	return eedata_out;
 }
 
-
 /* Open/initialize the board.  This is called (in the current kernel)
-   sometime after booting when the 'ifconfig' program is run.
-
-   This routine sets everything up anew at each open, even
-   registers that "should" only need to be set once at boot, so that
-   there is non-reboot way to recover if something goes wrong.
-
-   This is an attachable device: if there is no private entry then it wasn't
-   probed for at boot-time, and we need to probe for it again.
-   */
+ * sometime after booting when the 'ifconfig' program is run.
+ *
+ * This routine sets everything up anew at each open, even
+ * registers that "should" only need to be set once at boot, so that
+ * there is non-reboot way to recover if something goes wrong.
+ *
+ * This is an attachable device: if there is no private entry then it wasn't
+ * probed for at boot-time, and we need to probe for it again.
+ */
 static int net_open(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	int ret;
 
 	/* The interrupt line is turned off (tri-stated) when the device isn't in
-	   use.  That's especially important for "attached" interfaces where the
-	   port or interrupt may be shared. */
+	 * use.  That's especially important for "attached" interfaces where the
+	 *  port or interrupt may be shared.
+	 */
 	ret = request_irq(dev->irq, atp_interrupt, 0, dev->name, dev);
 	if (ret)
 		return ret;
@@ -450,40 +452,41 @@ static int net_open(struct net_device *dev)
 }
 
 /* This routine resets the hardware.  We initialize everything, assuming that
-   the hardware may have been temporarily detached. */
+ *   the hardware may have been temporarily detached.
+ */
 static void hardware_init(struct net_device *dev)
 {
 	struct net_local *lp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
-    int i;
+	int i;
 
 	/* Turn off the printer multiplexer on the 8012. */
 	for (i = 0; i < 8; i++)
 		outb(mux_8012[i], ioaddr + PAR_DATA);
 	write_reg_high(ioaddr, CMR1, CMR1h_RESET);
 
-    for (i = 0; i < 6; i++)
+	for (i = 0; i < 6; i++)
 		write_reg_byte(ioaddr, PAR0 + i, dev->dev_addr[i]);
 
 	write_reg_high(ioaddr, CMR2, lp->addr_mode);
 
 	if (net_debug > 2) {
 		printk(KERN_DEBUG "%s: Reset: current Rx mode %d.\n", dev->name,
-			   (read_nibble(ioaddr, CMR2_h) >> 3) & 0x0f);
+		       (read_nibble(ioaddr, CMR2_h) >> 3) & 0x0f);
 	}
 
-    write_reg(ioaddr, CMR2, CMR2_IRQOUT);
-    write_reg_high(ioaddr, CMR1, CMR1h_RxENABLE | CMR1h_TxENABLE);
+	write_reg(ioaddr, CMR2, CMR2_IRQOUT);
+	write_reg_high(ioaddr, CMR1, CMR1h_RxENABLE | CMR1h_TxENABLE);
 
 	/* Enable the interrupt line from the serial port. */
 	outb(Ctrl_SelData + Ctrl_IRQEN, ioaddr + PAR_CONTROL);
 
 	/* Unmask the interesting interrupts. */
-    write_reg(ioaddr, IMR, ISR_RxOK | ISR_TxErr | ISR_TxOK);
-    write_reg_high(ioaddr, IMR, ISRh_RxErr);
+	write_reg(ioaddr, IMR, ISR_RxOK | ISR_TxErr | ISR_TxOK);
+	write_reg_high(ioaddr, IMR, ISRh_RxErr);
 
 	lp->tx_unit_busy = 0;
-    lp->pac_cnt_in_tx_buf = 0;
+	lp->pac_cnt_in_tx_buf = 0;
 	lp->saved_tx_size = 0;
 }
 
@@ -496,23 +499,22 @@ static void trigger_send(long ioaddr, int length)
 
 static void write_packet(long ioaddr, int length, unsigned char *packet, int pad_len, int data_mode)
 {
-    if (length & 1)
-    {
-    	length++;
-    	pad_len++;
-    }
-
-    outb(EOC+MAR, ioaddr + PAR_DATA);
-    if ((data_mode & 1) == 0) {
+	if (length & 1) {
+		length++;
+		pad_len++;
+	}
+
+	outb(EOC+MAR, ioaddr + PAR_DATA);
+	if ((data_mode & 1) == 0) {
 		/* Write the packet out, starting with the write addr. */
 		outb(WrAddr+MAR, ioaddr + PAR_DATA);
 		do {
 			write_byte_mode0(ioaddr, *packet++);
-		} while (--length > pad_len) ;
+		} while (--length > pad_len);
 		do {
 			write_byte_mode0(ioaddr, 0);
-		} while (--length > 0) ;
-    } else {
+		} while (--length > 0);
+	} else {
 		/* Write the packet out in slow mode. */
 		unsigned char outbyte = *packet++;
 
@@ -528,10 +530,10 @@ static void write_packet(long ioaddr, int length, unsigned char *packet, int pad
 			write_byte_mode1(ioaddr, *packet++);
 		while (--length > 0)
 			write_byte_mode1(ioaddr, 0);
-    }
-    /* Terminate the Tx frame.  End of write: ECB. */
-    outb(0xff, ioaddr + PAR_DATA);
-    outb(Ctrl_HNibWrite | Ctrl_SelData | Ctrl_IRQEN, ioaddr + PAR_CONTROL);
+	}
+	/* Terminate the Tx frame.  End of write: ECB. */
+	outb(0xff, ioaddr + PAR_DATA);
+	outb(Ctrl_HNibWrite | Ctrl_SelData | Ctrl_IRQEN, ioaddr + PAR_CONTROL);
 }
 
 static void tx_timeout(struct net_device *dev)
@@ -539,8 +541,8 @@ static void tx_timeout(struct net_device *dev)
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING "%s: Transmit timed out, %s?\n", dev->name,
-		   inb(ioaddr + PAR_CONTROL) & 0x10 ? "network cable problem"
-		   :  "IRQ conflict");
+	       inb(ioaddr + PAR_CONTROL) & 0x10 ? "network cable problem"
+	       :  "IRQ conflict");
 	dev->stats.tx_errors++;
 	/* Try to restart the adapter. */
 	hardware_init(dev);
@@ -562,7 +564,8 @@ static netdev_tx_t atp_send_packet(struct sk_buff *skb,
 	netif_stop_queue(dev);
 
 	/* Disable interrupts by writing 0x00 to the Interrupt Mask Register.
-	   This sequence must not be interrupted by an incoming packet. */
+	 * This sequence must not be interrupted by an incoming packet.
+	 */
 
 	spin_lock_irqsave(&lp->lock, flags);
 	write_reg(ioaddr, IMR, 0);
@@ -574,22 +577,23 @@ static netdev_tx_t atp_send_packet(struct sk_buff *skb,
 	lp->pac_cnt_in_tx_buf++;
 	if (lp->tx_unit_busy == 0) {
 		trigger_send(ioaddr, length);
-		lp->saved_tx_size = 0; 				/* Redundant */
+		lp->saved_tx_size = 0;		/* Redundant */
 		lp->re_tx = 0;
 		lp->tx_unit_busy = 1;
-	} else
+	} else {
 		lp->saved_tx_size = length;
+	}
 	/* Re-enable the LPT interrupts. */
 	write_reg(ioaddr, IMR, ISR_RxOK | ISR_TxErr | ISR_TxOK);
 	write_reg_high(ioaddr, IMR, ISRh_RxErr);
 
-	dev_kfree_skb (skb);
+	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
 
-
 /* The typical workload of the driver:
-   Handle the network interface interrupts. */
+ * Handle the network interface interrupts.
+ */
 static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
@@ -611,20 +615,25 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 	write_reg(ioaddr, CMR2, CMR2_NULL);
 	write_reg(ioaddr, IMR, 0);
 
-	if (net_debug > 5) printk(KERN_DEBUG "%s: In interrupt ", dev->name);
-    while (--boguscount > 0) {
+	if (net_debug > 5)
+		printk(KERN_DEBUG "%s: In interrupt ", dev->name);
+	while (--boguscount > 0) {
 		int status = read_nibble(ioaddr, ISR);
-		if (net_debug > 5) printk("loop status %02x..", status);
+
+		if (net_debug > 5)
+			printk("loop status %02x..", status);
 
 		if (status & (ISR_RxOK<<3)) {
 			handled = 1;
 			write_reg(ioaddr, ISR, ISR_RxOK); /* Clear the Rx interrupt. */
 			do {
 				int read_status = read_nibble(ioaddr, CMR1);
+
 				if (net_debug > 6)
 					printk("handling Rx packet %02x..", read_status);
 				/* We acknowledged the normal Rx interrupt, so if the interrupt
-				   is still outstanding we must have a Rx error. */
+				 * is still outstanding we must have a Rx error.
+				 */
 				if (read_status & (CMR1_IRQ << 3)) { /* Overrun. */
 					dev->stats.rx_over_errors++;
 					/* Set to no-accept mode long enough to remove a packet. */
@@ -636,14 +645,17 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 				} else if ((read_status & (CMR1_BufEnb << 3)) == 0) {
 					net_rx(dev);
 					num_tx_since_rx = 0;
-				} else
+				} else {
 					break;
+				}
 			} while (--boguscount > 0);
 		} else if (status & ((ISR_TxErr + ISR_TxOK)<<3)) {
 			handled = 1;
-			if (net_debug > 6)  printk("handling Tx done..");
-			/* Clear the Tx interrupt.  We should check for too many failures
-			   and reinitialize the adapter. */
+			if (net_debug > 6)
+				printk("handling Tx done..");
+			/* Clear the Tx interrupt.  We should check for too many
+			 * failures and reinitialize the adapter.
+			 */
 			write_reg(ioaddr, ISR, ISR_TxErr + ISR_TxOK);
 			if (status & (ISR_TxErr<<3)) {
 				dev->stats.collisions++;
@@ -653,38 +665,41 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 					break;
 				}
 				/* Attempt to retransmit. */
-				if (net_debug > 6)  printk("attempting to ReTx");
+				if (net_debug > 6)
+					printk("attempting to ReTx");
 				write_reg(ioaddr, CMR1, CMR1_ReXmit + CMR1_Xmit);
 			} else {
 				/* Finish up the transmit. */
 				dev->stats.tx_packets++;
 				lp->pac_cnt_in_tx_buf--;
-				if ( lp->saved_tx_size) {
+				if (lp->saved_tx_size) {
 					trigger_send(ioaddr, lp->saved_tx_size);
 					lp->saved_tx_size = 0;
 					lp->re_tx = 0;
-				} else
+				} else {
 					lp->tx_unit_busy = 0;
+				}
 				netif_wake_queue(dev);	/* Inform upper layers. */
 			}
 			num_tx_since_rx++;
 		} else if (num_tx_since_rx > 8 &&
 			   time_after(jiffies, dev->last_rx + HZ)) {
 			if (net_debug > 2)
-				printk(KERN_DEBUG "%s: Missed packet? No Rx after %d Tx and "
-					   "%ld jiffies status %02x  CMR1 %02x.\n", dev->name,
-					   num_tx_since_rx, jiffies - dev->last_rx, status,
-					   (read_nibble(ioaddr, CMR1) >> 3) & 15);
+				printk(KERN_DEBUG "%s: Missed packet? No Rx after %d Tx and %ld jiffies status %02x  CMR1 %02x.\n",
+				       dev->name, num_tx_since_rx, jiffies - dev->last_rx, status,
+				       (read_nibble(ioaddr, CMR1) >> 3) & 15);
 			dev->stats.rx_missed_errors++;
 			hardware_init(dev);
 			num_tx_since_rx = 0;
 			break;
-		} else
+		} else {
 			break;
-    }
+		}
+	}
 
 	/* This following code fixes a rare (and very difficult to track down)
-	   problem where the adapter forgets its ethernet address. */
+	 *  problem where the adapter forgets its ethernet address.
+	 */
 	{
 		int i;
 		for (i = 0; i < 6; i++)
@@ -695,22 +710,24 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 	}
 
 	/* Tell the adapter that it can go back to using the output line as IRQ. */
-    write_reg(ioaddr, CMR2, CMR2_IRQOUT);
+	write_reg(ioaddr, CMR2, CMR2_IRQOUT);
 	/* Enable the physical interrupt line, which is sure to be low until.. */
 	outb(Ctrl_SelData + Ctrl_IRQEN, ioaddr + PAR_CONTROL);
 	/* .. we enable the interrupt sources. */
 	write_reg(ioaddr, IMR, ISR_RxOK | ISR_TxErr | ISR_TxOK);
-	write_reg_high(ioaddr, IMR, ISRh_RxErr); 			/* Hmmm, really needed? */
+	write_reg_high(ioaddr, IMR, ISRh_RxErr); /* Hmmm, really needed? */
 
 	spin_unlock(&lp->lock);
 
-	if (net_debug > 5) printk("exiting interrupt.\n");
+	if (net_debug > 5)
+		printk("exiting interrupt.\n");
 	return IRQ_RETVAL(handled);
 }
 
 #ifdef TIMED_CHECKER
 /* This following code fixes a rare (and very difficult to track down)
-   problem where the adapter forgets its ethernet address. */
+ * problem where the adapter forgets its ethernet address.
+ */
 static void atp_timed_checker(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
@@ -727,19 +744,19 @@ static void atp_timed_checker(unsigned long data)
 		lp->last_rx_time = jiffies;
 #else
 		for (i = 0; i < 6; i++)
-			if (read_cmd_byte(ioaddr, PAR0 + i) != atp_timed_dev->dev_addr[i])
-				{
-			struct net_local *lp = netdev_priv(atp_timed_dev);
-			write_reg_byte(ioaddr, PAR0 + i, atp_timed_dev->dev_addr[i]);
-			if (i == 2)
-			  dev->stats.tx_errors++;
-			else if (i == 3)
-			  dev->stats.tx_dropped++;
-			else if (i == 4)
-			  dev->stats.collisions++;
-			else
-			  dev->stats.rx_errors++;
-		  }
+			if (read_cmd_byte(ioaddr, PAR0 + i) != atp_timed_dev->dev_addr[i]) {
+				struct net_local *lp = netdev_priv(atp_timed_dev);
+
+				write_reg_byte(ioaddr, PAR0 + i, atp_timed_dev->dev_addr[i]);
+				if (i == 2)
+					dev->stats.tx_errors++;
+				else if (i == 3)
+					dev->stats.tx_dropped++;
+				else if (i == 4)
+					dev->stats.collisions++;
+				else
+					dev->stats.rx_errors++;
+			}
 #endif
 	}
 	spin_unlock(&lp->lock);
@@ -757,23 +774,26 @@ static void net_rx(struct net_device *dev)
 
 	/* Process the received packet. */
 	outb(EOC+MAR, ioaddr + PAR_DATA);
-	read_block(ioaddr, 8, (unsigned char*)&rx_head, dev->if_port);
+	read_block(ioaddr, 8, (unsigned char *)&rx_head, dev->if_port);
 	if (net_debug > 5)
 		printk(KERN_DEBUG " rx_count %04x %04x %04x %04x..", rx_head.pad,
-			   rx_head.rx_count, rx_head.rx_status, rx_head.cur_addr);
+		       rx_head.rx_count, rx_head.rx_status, rx_head.cur_addr);
 	if ((rx_head.rx_status & 0x77) != 0x01) {
 		dev->stats.rx_errors++;
-		if (rx_head.rx_status & 0x0004) dev->stats.rx_frame_errors++;
-		else if (rx_head.rx_status & 0x0002) dev->stats.rx_crc_errors++;
+		if (rx_head.rx_status & 0x0004)
+			dev->stats.rx_frame_errors++;
+		else if (rx_head.rx_status & 0x0002)
+			dev->stats.rx_crc_errors++;
 		if (net_debug > 3)
 			printk(KERN_DEBUG "%s: Unknown ATP Rx error %04x.\n",
-				   dev->name, rx_head.rx_status);
+			       dev->name, rx_head.rx_status);
 		if  (rx_head.rx_status & 0x0020) {
 			dev->stats.rx_fifo_errors++;
 			write_reg_high(ioaddr, CMR1, CMR1h_TxENABLE);
 			write_reg_high(ioaddr, CMR1, CMR1h_RxENABLE | CMR1h_TxENABLE);
-		} else if (rx_head.rx_status & 0x0050)
+		} else if (rx_head.rx_status & 0x0050) {
 			hardware_init(dev);
+		}
 		return;
 	} else {
 		/* Malloc up new buffer. The "-4" omits the FCS (CRC). */
@@ -787,7 +807,7 @@ static void net_rx(struct net_device *dev)
 		}
 
 		skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
-		read_block(ioaddr, pkt_len, skb_put(skb,pkt_len), dev->if_port);
+		read_block(ioaddr, pkt_len, skb_put(skb, pkt_len), dev->if_port);
 		skb->protocol = eth_type_trans(skb, dev);
 		netif_rx(skb);
 		dev->last_rx = jiffies;
@@ -804,7 +824,7 @@ static void read_block(long ioaddr, int length, unsigned char *p, int data_mode)
 	if (data_mode <= 3) { /* Mode 0 or 1 */
 		outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
 		outb(length == 8  ?  RdAddr | HNib | MAR  :  RdAddr | MAR,
-			 ioaddr + PAR_DATA);
+		     ioaddr + PAR_DATA);
 		if (data_mode <= 1) { /* Mode 0 or 1 */
 			do { *p++ = read_byte_mode0(ioaddr); } while (--length > 0);
 		} else { /* Mode 2 or 3 */
@@ -844,8 +864,7 @@ net_close(struct net_device *dev)
 	return 0;
 }
 
-/*
- *	Set or clear the multicast filter for this adapter.
+/* Set or clear the multicast filter for this adapter.
  */
 
 static void set_rx_mode(struct net_device *dev)
@@ -860,17 +879,20 @@ static void set_rx_mode(struct net_device *dev)
 	write_reg_high(ioaddr, CMR2, lp->addr_mode);
 }
 
-static int __init atp_init_module(void) {
-	if (debug)					/* Emit version even if no cards detected. */
+static int __init atp_init_module(void)
+{
+	if (debug)	/* Emit version even if no cards detected. */
 		printk(KERN_INFO "%s", version);
 	return atp_init();
 }
 
-static void __exit atp_cleanup_module(void) {
+static void __exit atp_cleanup_module(void)
+{
 	struct net_device *next_dev;
 
 	while (root_atp_dev) {
 		struct net_local *atp_local = netdev_priv(root_atp_dev);
+
 		next_dev = atp_local->next_module;
 		unregister_netdev(root_atp_dev);
 		/* No need to release_region(), since we never snarf it. */
-- 
2.1.3
