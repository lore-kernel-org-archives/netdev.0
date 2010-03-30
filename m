From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/pcmcia 3com: replacements of printk() with
 dev_info() and friends (fwd)
Date: Tue, 30 Mar 2010 13:15:35 -0700
Message-ID: <1269980135.1507.28.camel@Joe-Laptop.home>
References: <alpine.DEB.1.10.1003302019200.11637@blala.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Kurz <akurz@blala.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1268 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab0C3UPh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 16:15:37 -0400
In-Reply-To: <alpine.DEB.1.10.1003302019200.11637@blala.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-30 at 21:01 +0400, Alexander Kurz wrote:
>   It is my first patch, so I highly welcome comments and hints,

If you wanted to clean this up, you might
end up with something like what is below.

If you really wanted to clean this up, you'd
reorder the functions so you wouldn't need the
	/* index of functions */
block so that all the static functions are
instantiated in order of use.

Basically:
	Columnarize enums, typedefs, structs, etc
	Convert printks to appropriate types
	Coalesce long formats
	Indent multiline arguments to function open paren
	Trim trailing whitespace
	Convert leading spaces to tab
	Vertical whitespace between function variables and code
	Appropriate checkpatch cleanups

I use a script for most of this,
http://lkml.org/lkml/2010/3/24/447
some coccinelle conversions I haven't posted,
checkpatch and a little I hope tasteful typing.

cheers, Joe
---
 drivers/net/pcmcia/3c574_cs.c |  462 +++++++++++++++++++++++------------------
 1 files changed, 255 insertions(+), 207 deletions(-)

diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 3d1d3a7..9c96742 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -12,7 +12,7 @@
 	following copyright:
 	Copyright 1993 United States Government as represented by the
 	Director, National Security Agency.
-	
+
 
 */
 
@@ -86,6 +86,8 @@ earlier 3Com products.
 #include <linux/ethtool.h>
 #include <linux/bitops.h>
 #include <linux/mii.h>
+#include <linux/uaccess.h>
+#include <linux/io.h>
 
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
@@ -95,8 +97,6 @@ earlier 3Com products.
 #include <pcmcia/ds.h>
 #include <pcmcia/mem_op.h>
 
-#include <asm/uaccess.h>
-#include <asm/io.h>
 #include <asm/system.h>
 
 /*====================================================================*/
@@ -122,7 +122,7 @@ INT_MODULE_PARM(auto_polarity, 1);
 /*====================================================================*/
 
 /* Time in jiffies before concluding the transmitter is hung. */
-#define TX_TIMEOUT  ((800*HZ)/1000)
+#define TX_TIMEOUT  ((800 * HZ) / 1000)
 
 /* To minimize the size of the driver source and make the driver more
    readable not all constants are symbolically defined.
@@ -137,85 +137,125 @@ INT_MODULE_PARM(auto_polarity, 1);
 /* The top five bits written to EL3_CMD are a command, the lower
    11 bits are the parameter, if applicable. */
 enum el3_cmds {
-	TotalReset = 0<<11, SelectWindow = 1<<11, StartCoax = 2<<11,
-	RxDisable = 3<<11, RxEnable = 4<<11, RxReset = 5<<11, RxDiscard = 8<<11,
-	TxEnable = 9<<11, TxDisable = 10<<11, TxReset = 11<<11,
-	FakeIntr = 12<<11, AckIntr = 13<<11, SetIntrEnb = 14<<11,
-	SetStatusEnb = 15<<11, SetRxFilter = 16<<11, SetRxThreshold = 17<<11,
-	SetTxThreshold = 18<<11, SetTxStart = 19<<11, StatsEnable = 21<<11,
-	StatsDisable = 22<<11, StopCoax = 23<<11,
+	TotalReset	= 0 << 11,
+	SelectWindow	= 1 << 11,
+	StartCoax	= 2 << 11,
+	RxDisable	= 3 << 11,
+	RxEnable	= 4 << 11,
+	RxReset		= 5 << 11,
+	RxDiscard	= 8 << 11,
+	TxEnable	= 9 << 11,
+	TxDisable	= 10 << 11,
+	TxReset		= 11 << 11,
+	FakeIntr	= 12 << 11,
+	AckIntr		= 13 << 11,
+	SetIntrEnb	= 14 << 11,
+	SetStatusEnb	= 15 << 11,
+	SetRxFilter	= 16 << 11,
+	SetRxThreshold	= 17 << 11,
+	SetTxThreshold	= 18 << 11,
+	SetTxStart	= 19 << 11,
+	StatsEnable	= 21 << 11,
+	StatsDisable	= 22 << 11,
+	StopCoax	= 23 << 11,
 };
 
 enum elxl_status {
-	IntLatch = 0x0001, AdapterFailure = 0x0002, TxComplete = 0x0004,
-	TxAvailable = 0x0008, RxComplete = 0x0010, RxEarly = 0x0020,
-	IntReq = 0x0040, StatsFull = 0x0080, CmdBusy = 0x1000 };
+	IntLatch	= 0x0001,
+	AdapterFailure	= 0x0002,
+	TxComplete	= 0x0004,
+	TxAvailable	= 0x0008,
+	RxComplete	= 0x0010,
+	RxEarly		= 0x0020,
+	IntReq		= 0x0040,
+	StatsFull	= 0x0080,
+	CmdBusy		= 0x1000
+};
 
 /* The SetRxFilter command accepts the following classes: */
 enum RxFilter {
-	RxStation = 1, RxMulticast = 2, RxBroadcast = 4, RxProm = 8
+	RxStation	= 1,
+	RxMulticast	= 2,
+	RxBroadcast	= 4,
+	RxProm		= 8
 };
 
 enum Window0 {
-	Wn0EepromCmd = 10, Wn0EepromData = 12, /* EEPROM command/address, data. */
-	IntrStatus=0x0E,		/* Valid in all windows. */
+	Wn0EepromCmd	= 10,
+	Wn0EepromData	= 12,	/* EEPROM command/address, data. */
+	IntrStatus	= 0x0E,	/* Valid in all windows. */
 };
 /* These assumes the larger EEPROM. */
 enum Win0_EEPROM_cmds {
-	EEPROM_Read = 0x200, EEPROM_WRITE = 0x100, EEPROM_ERASE = 0x300,
-	EEPROM_EWENB = 0x30,		/* Enable erasing/writing for 10 msec. */
-	EEPROM_EWDIS = 0x00,		/* Disable EWENB before 10 msec timeout. */
+	EEPROM_Read	= 0x200,
+	EEPROM_WRITE	= 0x100,
+	EEPROM_ERASE	= 0x300,
+	EEPROM_EWENB	= 0x30,	/* Enable erasing/writing for 10 msec. */
+	EEPROM_EWDIS	= 0x00,	/* Disable EWENB before 10 msec timeout. */
 };
 
 /* Register window 1 offsets, the window used in normal operation.
    On the "Odie" this window is always mapped at offsets 0x10-0x1f.
    Except for TxFree, which is overlapped by RunnerWrCtrl. */
 enum Window1 {
-	TX_FIFO = 0x10,  RX_FIFO = 0x10,  RxErrors = 0x14,
-	RxStatus = 0x18,  Timer=0x1A, TxStatus = 0x1B,
-	TxFree = 0x0C, /* Remaining free bytes in Tx buffer. */
-	RunnerRdCtrl = 0x16, RunnerWrCtrl = 0x1c,
+	TX_FIFO		= 0x10,
+	RX_FIFO		= 0x10,
+	RxErrors	= 0x14,
+	RxStatus	= 0x18,
+	Timer		= 0x1A,
+	TxStatus	= 0x1B,
+	TxFree		= 0x0C,	/* Remaining free bytes in Tx buffer. */
+	RunnerRdCtrl	= 0x16,
+	RunnerWrCtrl	= 0x1c,
 };
 
 enum Window3 {			/* Window 3: MAC/config bits. */
-	Wn3_Config=0, Wn3_MAC_Ctrl=6, Wn3_Options=8,
+	Wn3_Config	= 0,
+	Wn3_MAC_Ctrl	= 6,
+	Wn3_Options	= 8,
 };
 enum wn3_config {
-	Ram_size = 7,
-	Ram_width = 8,
-	Ram_speed = 0x30,
-	Rom_size = 0xc0,
-	Ram_split_shift = 16,
-	Ram_split = 3 << Ram_split_shift,
-	Xcvr_shift = 20,
-	Xcvr = 7 << Xcvr_shift,
-	Autoselect = 0x1000000,
+	Ram_size	= 7,
+	Ram_width	= 8,
+	Ram_speed	= 0x30,
+	Rom_size	= 0xc0,
+	Ram_split_shift	= 16,
+	Ram_split	= 3 << Ram_split_shift,
+	Xcvr_shift	= 20,
+	Xcvr		= 7 << Xcvr_shift,
+	Autoselect	= 0x1000000,
 };
 
 enum Window4 {		/* Window 4: Xcvr/media bits. */
-	Wn4_FIFODiag = 4, Wn4_NetDiag = 6, Wn4_PhysicalMgmt=8, Wn4_Media = 10,
+	Wn4_FIFODiag	= 4,
+	Wn4_NetDiag	= 6,
+	Wn4_PhysicalMgmt = 8,
+	Wn4_Media	= 10,
 };
 
 #define MEDIA_TP	0x00C0	/* Enable link beat and jabber for 10baseT. */
 
 struct el3_private {
 	struct pcmcia_device	*p_dev;
-	dev_node_t node;
-	u16 advertising, partner;		/* NWay media advertisement */
-	unsigned char phys;			/* MII device address */
-	unsigned int autoselect:1, default_media:3;	/* Read from the EEPROM/Wn3_Config. */
-	/* for transceiver monitoring */
+	dev_node_t	node;
+	u16		advertising;
+	u16		partner;		/* NWay media advertisement */
+	unsigned char	phys;			/* MII device address */
+	unsigned int	autoselect:1;
+	unsigned int	default_media:3;	/* Read from the
+						 * EEPROM/Wn3_Config.
+						 * for transceiver monitoring */
 	struct timer_list media;
-	unsigned short media_status;
-	unsigned short fast_poll;
-	unsigned long last_irq;
-	spinlock_t window_lock;			/* Guards the Window selection */
+	unsigned short	media_status;
+	unsigned short	fast_poll;
+	unsigned long	last_irq;
+	spinlock_t	window_lock;		/* Guards Window selection */
 };
 
 /* Set iff a MII transceiver on any interface requires mdio preamble.
    This only set with the original DP83840 on older 3c905 boards, so the extra
    code size of a per-interface flag is not worthwhile. */
-static char mii_preamble_required = 0;
+static char mii_preamble_required;
 
 /* Index of functions. */
 
@@ -245,23 +285,21 @@ static const struct ethtool_ops netdev_ethtool_ops;
 static void set_rx_mode(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 
-static void tc574_detach(struct pcmcia_device *p_dev);
-
 /*
 	tc574_attach() creates an "instance" of the driver, allocating
 	local data structures for one device.  The device is registered
 	with Card Services.
 */
 static const struct net_device_ops el3_netdev_ops = {
-	.ndo_open 		= el3_open,
-	.ndo_stop 		= el3_close,
+	.ndo_open		= el3_open,
+	.ndo_stop		= el3_close,
 	.ndo_start_xmit		= el3_start_xmit,
-	.ndo_tx_timeout 	= el3_tx_timeout,
+	.ndo_tx_timeout		= el3_tx_timeout,
 	.ndo_get_stats		= el3_get_stats,
 	.ndo_do_ioctl		= el3_ioctl,
 	.ndo_set_multicast_list = set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -294,7 +332,7 @@ static int tc574_probe(struct pcmcia_device *link)
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return tc574_config(link);
-} /* tc574_attach */
+}
 
 /*
 
@@ -317,7 +355,7 @@ static void tc574_detach(struct pcmcia_device *link)
 	tc574_release(link);
 
 	free_netdev(dev);
-} /* tc574_detach */
+}
 
 /*
 	tc574_config() is scheduled to run after a CARD_INSERTION event
@@ -381,8 +419,8 @@ static int tc574_config(struct pcmcia_device *link)
 		for (i = 0; i < 3; i++)
 			phys_addr[i] = htons(read_eeprom(ioaddr, i + 10));
 		if (phys_addr[0] == htons(0x6060)) {
-			printk(KERN_NOTICE "3c574_cs: IO port conflict at 0x%03lx"
-				   "-0x%03lx\n", dev->base_addr, dev->base_addr+15);
+			netdev_notice(dev, "IO port conflict at 0x%03lx-0x%03lx\n",
+				      dev->base_addr, dev->base_addr+15);
 			goto failed;
 		}
 	}
@@ -393,10 +431,10 @@ static int tc574_config(struct pcmcia_device *link)
 
 	{
 		u_char mcr;
-		outw(2<<11, ioaddr + RunnerRdCtrl);
+		outw(2 << 11, ioaddr + RunnerRdCtrl);
 		mcr = inb(ioaddr + 2);
-		outw(0<<11, ioaddr + RunnerRdCtrl);
-		printk(KERN_INFO "  ASIC rev %d,", mcr>>3);
+		outw(0 << 11, ioaddr + RunnerRdCtrl);
+		netdev_info(dev, "ASIC rev %d\n", mcr >> 3);
 		EL3WINDOW(3);
 		config = inl(ioaddr + Wn3_Config);
 		lp->default_media = (config & Xcvr) >> Xcvr_shift;
@@ -407,7 +445,7 @@ static int tc574_config(struct pcmcia_device *link)
 
 	{
 		int phy;
-		
+
 		/* Roadrunner only: Turn on the MII transceiver */
 		outw(0x8040, ioaddr + Wn3_Options);
 		mdelay(1);
@@ -416,7 +454,7 @@ static int tc574_config(struct pcmcia_device *link)
 		tc574_wait_for_completion(dev, RxReset);
 		mdelay(1);
 		outw(0x8040, ioaddr + Wn3_Options);
-		
+
 		EL3WINDOW(4);
 		for (phy = 1; phy <= 32; phy++) {
 			int mii_status;
@@ -424,16 +462,15 @@ static int tc574_config(struct pcmcia_device *link)
 			mii_status = mdio_read(ioaddr, phy & 0x1f, 1);
 			if (mii_status != 0xffff) {
 				lp->phys = phy & 0x1f;
-				dev_dbg(&link->dev, "  MII transceiver at "
-					"index %d, status %x.\n",
-					  phy, mii_status);
+				dev_dbg(&link->dev, "MII transceiver at index %d, status %x\n",
+					phy, mii_status);
 				if ((mii_status & 0x0040) == 0)
 					mii_preamble_required = 1;
 				break;
 			}
 		}
 		if (phy > 32) {
-			printk(KERN_NOTICE "  No MII transceivers found!\n");
+			netdev_notice(dev, "No MII transceivers found!\n");
 			goto failed;
 		}
 		i = mdio_read(ioaddr, lp->phys, 16) | 0x40;
@@ -450,21 +487,19 @@ static int tc574_config(struct pcmcia_device *link)
 	SET_NETDEV_DEV(dev, &link->dev);
 
 	if (register_netdev(dev) != 0) {
-		printk(KERN_NOTICE "3c574_cs: register_netdev() failed\n");
+		netdev_notice(dev, "register_netdev() failed\n");
 		link->dev_node = NULL;
 		goto failed;
 	}
 
 	strcpy(lp->node.dev_name, dev->name);
 
-	printk(KERN_INFO "%s: %s at io %#3lx, irq %d, "
-	       "hw_addr %pM.\n",
-	       dev->name, cardname, dev->base_addr, dev->irq,
-	       dev->dev_addr);
-	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
-		   8 << config & Ram_size,
-		   ram_split[(config & Ram_split) >> Ram_split_shift],
-		   config & Autoselect ? "autoselect " : "");
+	netdev_info(dev, "%s at io %#3lx, irq %d, hw_addr %pM\n",
+		    cardname, dev->base_addr, dev->irq, dev->dev_addr);
+	netdev_info(dev, "%dK FIFO split %s Rx:Tx, %sMII interface\n",
+		    8 << config & Ram_size,
+		    ram_split[(config & Ram_split) >> Ram_split_shift],
+		    config & Autoselect ? "autoselect " : "");
 
 	return 0;
 
@@ -510,15 +545,15 @@ static int tc574_resume(struct pcmcia_device *link)
 static void dump_status(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
+
 	EL3WINDOW(1);
-	printk(KERN_INFO "  irq status %04x, rx status %04x, tx status "
-		   "%02x, tx free %04x\n", inw(ioaddr+EL3_STATUS),
-		   inw(ioaddr+RxStatus), inb(ioaddr+TxStatus),
-		   inw(ioaddr+TxFree));
+	netdev_info(dev, "irq status %04x, rx status %04x, tx status %02x, tx free %04x\n",
+		    inw(ioaddr+EL3_STATUS), inw(ioaddr+RxStatus),
+		    inb(ioaddr+TxStatus), inw(ioaddr+TxFree));
 	EL3WINDOW(4);
-	printk(KERN_INFO "  diagnostics: fifo %04x net %04x ethernet %04x"
-		   " media %04x\n", inw(ioaddr+0x04), inw(ioaddr+0x06),
-		   inw(ioaddr+0x08), inw(ioaddr+0x0a));
+	netdev_info(dev, "diagnostics: fifo %04x net %04x ethernet %04x media %04x\n",
+		    inw(ioaddr+0x04), inw(ioaddr+0x06),
+		    inw(ioaddr+0x08), inw(ioaddr+0x0a));
 	EL3WINDOW(1);
 }
 
@@ -528,11 +563,13 @@ static void dump_status(struct net_device *dev)
 static void tc574_wait_for_completion(struct net_device *dev, int cmd)
 {
 	int i = 1500;
+
 	outw(cmd, dev->base_addr + EL3_CMD);
 	while (--i > 0)
-		if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000)) break;
+		if (!(inw(dev->base_addr + EL3_STATUS) & 0x1000))
+			break;
 	if (i == 0)
-		printk(KERN_NOTICE "%s: command 0x%04x did not complete!\n", dev->name, cmd);
+		netdev_notice(dev, "command 0x%04x did not complete!\n", cmd);
 }
 
 /* Read a word from the EEPROM using the regular EEPROM access register.
@@ -541,6 +578,7 @@ static void tc574_wait_for_completion(struct net_device *dev, int cmd)
 static unsigned short read_eeprom(unsigned int ioaddr, int index)
 {
 	int timer;
+
 	outw(EEPROM_Read + index, ioaddr + Wn0EepromCmd);
 	/* Pause for at least 162 usec for the read to take place. */
 	for (timer = 1620; timer >= 0; timer--) {
@@ -589,17 +627,19 @@ static int mdio_read(unsigned int ioaddr, int phy_id, int location)
 
 	/* Shift the read command bits out. */
 	for (i = 14; i >= 0; i--) {
-		int dataval = (read_cmd&(1<<i)) ? MDIO_DATA_WRITE1 : MDIO_DATA_WRITE0;
+		int dataval = (read_cmd & (1 << i))
+			? MDIO_DATA_WRITE1 : MDIO_DATA_WRITE0;
 		outw(dataval, mdio_addr);
 		outw(dataval | MDIO_SHIFT_CLK, mdio_addr);
 	}
 	/* Read the two transition, 16 data, and wire-idle bits. */
 	for (i = 19; i > 0; i--) {
 		outw(MDIO_ENB_IN, mdio_addr);
-		retval = (retval << 1) | ((inw(mdio_addr) & MDIO_DATA_READ) ? 1 : 0);
+		retval = (retval << 1) |
+			((inw(mdio_addr) & MDIO_DATA_READ) ? 1 : 0);
 		outw(MDIO_ENB_IN | MDIO_SHIFT_CLK, mdio_addr);
 	}
-	return (retval>>1) & 0xffff;
+	return (retval >> 1) & 0xffff;
 }
 
 static void mdio_write(unsigned int ioaddr, int phy_id, int location, int value)
@@ -613,7 +653,8 @@ static void mdio_write(unsigned int ioaddr, int phy_id, int location, int value)
 
 	/* Shift the command bits out. */
 	for (i = 31; i >= 0; i--) {
-		int dataval = (write_cmd&(1<<i)) ? MDIO_DATA_WRITE1 : MDIO_DATA_WRITE0;
+		int dataval = (write_cmd&(1 << i))
+			? MDIO_DATA_WRITE1 : MDIO_DATA_WRITE0;
 		outw(dataval, mdio_addr);
 		outw(dataval | MDIO_SHIFT_CLK, mdio_addr);
 	}
@@ -645,7 +686,7 @@ static void tc574_reset(struct net_device *dev)
 	EL3WINDOW(2);
 	for (i = 0; i < 6; i++)
 		outb(dev->dev_addr[i], ioaddr + i);
-	for (; i < 12; i+=2)
+	for (; i < 12; i += 2)
 		outw(0, ioaddr + i);
 
 	/* Reset config options */
@@ -659,7 +700,7 @@ static void tc574_reset(struct net_device *dev)
 	outw(0xc040, ioaddr + Wn3_Options);
 	EL3WINDOW(1);
 	spin_unlock_irqrestore(&lp->window_lock, flags);
-	
+
 	tc574_wait_for_completion(dev, TxReset);
 	tc574_wait_for_completion(dev, RxReset);
 	mdelay(1);
@@ -680,10 +721,10 @@ static void tc574_reset(struct net_device *dev)
 
 	/* .. enable any extra statistics bits.. */
 	outw(0x0040, ioaddr + Wn4_NetDiag);
-	
+
 	EL3WINDOW(1);
 	spin_unlock_irqrestore(&lp->window_lock, flags);
-	
+
 	/* .. re-sync MII and re-fill what NWay is advertising. */
 	mdio_sync(ioaddr, 32);
 	mdio_write(ioaddr, lp->phys, 4, lp->advertising);
@@ -704,9 +745,10 @@ static void tc574_reset(struct net_device *dev)
 	outw(SetStatusEnb | 0xff, ioaddr + EL3_CMD);
 	/* Ack all pending events, and set active indicator mask. */
 	outw(AckIntr | IntLatch | TxAvailable | RxEarly | IntReq,
-		 ioaddr + EL3_CMD);
-	outw(SetIntrEnb | IntLatch | TxAvailable | RxComplete | StatsFull
-		 | AdapterFailure | RxEarly, ioaddr + EL3_CMD);
+	     ioaddr + EL3_CMD);
+	outw(SetIntrEnb | IntLatch | TxAvailable | RxComplete | StatsFull |
+	     AdapterFailure | RxEarly,
+	     ioaddr + EL3_CMD);
 }
 
 static int el3_open(struct net_device *dev)
@@ -716,27 +758,27 @@ static int el3_open(struct net_device *dev)
 
 	if (!pcmcia_dev_present(link))
 		return -ENODEV;
-	
+
 	link->open++;
 	netif_start_queue(dev);
-	
+
 	tc574_reset(dev);
 	lp->media.function = &media_check;
 	lp->media.data = (unsigned long) dev;
 	lp->media.expires = jiffies + HZ;
 	add_timer(&lp->media);
-	
-	dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
-		  dev->name, inw(dev->base_addr + EL3_STATUS));
-	
+
+	dev_dbg(&link->dev, "%s: opened, status %0x\n",
+		dev->name, inw(dev->base_addr + EL3_STATUS));
+
 	return 0;
 }
 
 static void el3_tx_timeout(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
-	
-	printk(KERN_NOTICE "%s: Transmit timed out!\n", dev->name);
+
+	netdev_notice(dev, "Transmit timed out!\n");
 	dump_status(dev);
 	dev->stats.tx_errors++;
 	dev->trans_start = jiffies;
@@ -750,7 +792,7 @@ static void pop_tx_status(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	int i;
-    
+
 	/* Clear the Tx status stack. */
 	for (i = 32; i > 0; i--) {
 		u_char tx_status = inb(ioaddr + TxStatus);
@@ -760,8 +802,8 @@ static void pop_tx_status(struct net_device *dev)
 		if (tx_status & 0x30)
 			tc574_wait_for_completion(dev, TxReset);
 		if (tx_status & 0x38) {
-			pr_debug("%s: transmit error: status 0x%02x\n",
-				  dev->name, tx_status);
+			netdev_dbg(dev, "transmit error: status 0x%02x\n",
+				   tx_status);
 			outw(TxEnable, ioaddr + EL3_CMD);
 			dev->stats.tx_aborted_errors++;
 		}
@@ -769,30 +811,28 @@ static void pop_tx_status(struct net_device *dev)
 	}
 }
 
-static netdev_tx_t el3_start_xmit(struct sk_buff *skb,
-					struct net_device *dev)
+static netdev_tx_t el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
 	struct el3_private *lp = netdev_priv(dev);
 	unsigned long flags;
 
-	pr_debug("%s: el3_start_xmit(length = %ld) called, "
-		  "status %4.4x.\n", dev->name, (long)skb->len,
-		  inw(ioaddr + EL3_STATUS));
+	netdev_dbg(dev, "el3_start_xmit(length = %ld) called, status %04x\n",
+		   (long)skb->len, inw(ioaddr + EL3_STATUS));
 
 	spin_lock_irqsave(&lp->window_lock, flags);
 	outw(skb->len, ioaddr + TX_FIFO);
 	outw(0, ioaddr + TX_FIFO);
-	outsl(ioaddr + TX_FIFO, skb->data, (skb->len+3)>>2);
+	outsl(ioaddr + TX_FIFO, skb->data, (skb->len+3) >> 2);
 
 	dev->trans_start = jiffies;
 
 	/* TxFree appears only in Window 1, not offset 0x1c. */
 	if (inw(ioaddr + TxFree) <= 1536) {
 		netif_stop_queue(dev);
-		/* Interrupt us when the FIFO has room for max-sized packet. 
+		/* Interrupt us when the FIFO has room for max-sized packet.
 		   The threshold is in units of dwords. */
-		outw(SetTxThreshold + (1536>>2), ioaddr + EL3_CMD);
+		outw(SetTxThreshold + (1536 >> 2), ioaddr + EL3_CMD);
 	}
 
 	pop_tx_status(dev);
@@ -815,16 +855,15 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		return IRQ_NONE;
 	ioaddr = dev->base_addr;
 
-	pr_debug("%s: interrupt, status %4.4x.\n",
-		  dev->name, inw(ioaddr + EL3_STATUS));
+	netdev_dbg(dev, "interrupt, status %04x\n", inw(ioaddr + EL3_STATUS));
 
 	spin_lock(&lp->window_lock);
-	
+
 	while ((status = inw(ioaddr + EL3_STATUS)) &
 		   (IntLatch | RxComplete | RxEarly | StatsFull)) {
 		if (!netif_device_present(dev) ||
-			((status & 0xe000) != 0x2000)) {
-			pr_debug("%s: Interrupt from dead card\n", dev->name);
+		    ((status & 0xe000) != 0x2000)) {
+			netdev_dbg(dev, "Interrupt from dead card\n");
 			break;
 		}
 
@@ -834,7 +873,7 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 			work_budget = el3_rx(dev, work_budget);
 
 		if (status & TxAvailable) {
-			pr_debug("  TX room bit was handled.\n");
+			netdev_dbg(dev, "TX room bit was handled\n");
 			/* There's room in the FIFO for a full-sized packet. */
 			outw(AckIntr | TxAvailable, ioaddr + EL3_CMD);
 			netif_wake_queue(dev);
@@ -856,8 +895,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 				EL3WINDOW(4);
 				fifo_diag = inw(ioaddr + Wn4_FIFODiag);
 				EL3WINDOW(1);
-				printk(KERN_NOTICE "%s: adapter failure, FIFO diagnostic"
-					   " register %04x.\n", dev->name, fifo_diag);
+				netdev_notice(dev, "adapter failure, FIFO diagnostic register %04x\n",
+					      fifo_diag);
 				if (fifo_diag & 0x0400) {
 					/* Tx overrun */
 					tc574_wait_for_completion(dev, TxReset);
@@ -874,8 +913,8 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		}
 
 		if (--work_budget < 0) {
-			pr_debug("%s: Too much work in interrupt, "
-				  "status %4.4x.\n", dev->name, status);
+			netdev_dbg(dev, "Too much work in interrupt, status %04x\n",
+				   status);
 			/* Clear all interrupts */
 			outw(AckIntr | 0xFF, ioaddr + EL3_CMD);
 			break;
@@ -884,9 +923,9 @@ static irqreturn_t el3_interrupt(int irq, void *dev_id)
 		outw(AckIntr | IntReq | IntLatch, ioaddr + EL3_CMD);
 	}
 
-	pr_debug("%s: exiting interrupt, status %4.4x.\n",
-		  dev->name, inw(ioaddr + EL3_STATUS));
-		  
+	netdev_dbg(dev, "exiting interrupt, status %04x\n",
+		   inw(ioaddr + EL3_STATUS));
+
 	spin_unlock(&lp->window_lock);
 	return IRQ_RETVAL(handled);
 }
@@ -906,12 +945,13 @@ static void media_check(unsigned long arg)
 
 	if (!netif_device_present(dev))
 		goto reschedule;
-	
+
 	/* Check for pending interrupt with expired latency timer: with
 	   this, we can limp along even if the interrupt is blocked */
-	if ((inw(ioaddr + EL3_STATUS) & IntLatch) && (inb(ioaddr + Timer) == 0xff)) {
+	if ((inw(ioaddr + EL3_STATUS) & IntLatch) &&
+	    (inb(ioaddr + Timer) == 0xff)) {
 		if (!lp->fast_poll)
-			printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+			netdev_info(dev, "interrupt(s) dropped!\n");
 
 		local_irq_save(flags);
 		el3_interrupt(dev->irq, dev);
@@ -931,39 +971,38 @@ static void media_check(unsigned long arg)
 	media = mdio_read(ioaddr, lp->phys, 1);
 	partner = mdio_read(ioaddr, lp->phys, 5);
 	EL3WINDOW(1);
-	
+
 	if (media != lp->media_status) {
 		if ((media ^ lp->media_status) & 0x0004)
-			printk(KERN_INFO "%s: %s link beat\n", dev->name,
-				   (lp->media_status & 0x0004) ? "lost" : "found");
+			netdev_info(dev, "%s link beat\n",
+				    (lp->media_status & 0x0004)
+				    ? "lost" : "found");
 		if ((media ^ lp->media_status) & 0x0020) {
 			lp->partner = 0;
 			if (lp->media_status & 0x0020) {
-				printk(KERN_INFO "%s: autonegotiation restarted\n",
-					   dev->name);
+				netdev_info(dev, "autonegotiation restarted\n");
 			} else if (partner) {
 				partner &= lp->advertising;
 				lp->partner = partner;
-				printk(KERN_INFO "%s: autonegotiation complete: "
-					   "%sbaseT-%cD selected\n", dev->name,
-					   ((partner & 0x0180) ? "100" : "10"),
-					   ((partner & 0x0140) ? 'F' : 'H'));
+				netdev_info(dev, "autonegotiation complete: %sbaseT-%cD selected\n",
+
+					    ((partner & 0x0180) ? "100" : "10"),
+					    ((partner & 0x0140) ? 'F' : 'H'));
 			} else {
-				printk(KERN_INFO "%s: link partner did not autonegotiate\n",
-					   dev->name);
+				netdev_info(dev, "link partner did not autonegotiate\n");
 			}
 
 			EL3WINDOW(3);
 			outb((partner & 0x0140 ? 0x20 : 0) |
-				 (dev->mtu > 1500 ? 0x40 : 0), ioaddr + Wn3_MAC_Ctrl);
+			     (dev->mtu > 1500 ? 0x40 : 0),
+			     ioaddr + Wn3_MAC_Ctrl);
 			EL3WINDOW(1);
 
 		}
 		if (media & 0x0010)
-			printk(KERN_INFO "%s: remote fault detected\n",
-				   dev->name);
+			netdev_info(dev, "remote fault detected\n");
 		if (media & 0x0002)
-			printk(KERN_INFO "%s: jabber detected\n", dev->name);
+			netdev_info(dev, "jabber detected\n");
 		lp->media_status = media;
 	}
 	spin_unlock_irqrestore(&lp->window_lock, flags);
@@ -995,33 +1034,33 @@ static void update_stats(struct net_device *dev)
 	unsigned int ioaddr = dev->base_addr;
 	u8 rx, tx, up;
 
-	pr_debug("%s: updating the statistics.\n", dev->name);
+	netdev_dbg(dev, "updating the statistics\n");
 
 	if (inw(ioaddr+EL3_STATUS) == 0xffff) /* No card. */
 		return;
-		
+
 	/* Unlike the 3c509 we need not turn off stats updates while reading. */
 	/* Switch to the stats window, and read everything. */
 	EL3WINDOW(6);
-	dev->stats.tx_carrier_errors 		+= inb(ioaddr + 0);
+	dev->stats.tx_carrier_errors		+= inb(ioaddr + 0);
 	dev->stats.tx_heartbeat_errors		+= inb(ioaddr + 1);
-	/* Multiple collisions. */	   	inb(ioaddr + 2);
+	/* Multiple collisions. */		   inb(ioaddr + 2);
 	dev->stats.collisions			+= inb(ioaddr + 3);
 	dev->stats.tx_window_errors		+= inb(ioaddr + 4);
 	dev->stats.rx_fifo_errors		+= inb(ioaddr + 5);
 	dev->stats.tx_packets			+= inb(ioaddr + 6);
-	up		 			 = inb(ioaddr + 9);
+	up					 = inb(ioaddr + 9);
 	dev->stats.tx_packets			+= (up&0x30) << 4;
 	/* Rx packets   */			   inb(ioaddr + 7);
 	/* Tx deferrals */			   inb(ioaddr + 8);
-	rx		 			 = inw(ioaddr + 10);
+	rx					 = inw(ioaddr + 10);
 	tx					 = inw(ioaddr + 12);
 
 	EL3WINDOW(4);
 	/* BadSSD */				   inb(ioaddr + 12);
 	up					 = inb(ioaddr + 13);
 
-	dev->stats.tx_bytes 			+= tx + ((up & 0xf0) << 12);
+	dev->stats.tx_bytes			+= tx + ((up & 0xf0) << 12);
 
 	EL3WINDOW(1);
 }
@@ -1030,22 +1069,34 @@ static int el3_rx(struct net_device *dev, int worklimit)
 {
 	unsigned int ioaddr = dev->base_addr;
 	short rx_status;
-	
-	pr_debug("%s: in rx_packet(), status %4.4x, rx_status %4.4x.\n",
-		  dev->name, inw(ioaddr+EL3_STATUS), inw(ioaddr+RxStatus));
+
+	netdev_dbg(dev, "in rx_packet(), status %04x, rx_status %04x\n",
+		   inw(ioaddr+EL3_STATUS), inw(ioaddr+RxStatus));
 	while (!((rx_status = inw(ioaddr + RxStatus)) & 0x8000) &&
-			worklimit > 0) {
+	       worklimit > 0) {
 		worklimit--;
 		if (rx_status & 0x4000) { /* Error, update stats. */
 			short error = rx_status & 0x3800;
 			dev->stats.rx_errors++;
 			switch (error) {
-			case 0x0000:	dev->stats.rx_over_errors++; break;
-			case 0x0800:	dev->stats.rx_length_errors++; break;
-			case 0x1000:	dev->stats.rx_frame_errors++; break;
-			case 0x1800:	dev->stats.rx_length_errors++; break;
-			case 0x2000:	dev->stats.rx_frame_errors++; break;
-			case 0x2800:	dev->stats.rx_crc_errors++; break;
+			case 0x0000:
+				dev->stats.rx_over_errors++;
+				break;
+			case 0x0800:
+				dev->stats.rx_length_errors++;
+				break;
+			case 0x1000:
+				dev->stats.rx_frame_errors++;
+				break;
+			case 0x1800:
+				dev->stats.rx_length_errors++;
+				break;
+			case 0x2000:
+				dev->stats.rx_frame_errors++;
+				break;
+			case 0x2800:
+				dev->stats.rx_crc_errors++;
+				break;
 			}
 		} else {
 			short pkt_len = rx_status & 0x7ff;
@@ -1053,19 +1104,19 @@ static int el3_rx(struct net_device *dev, int worklimit)
 
 			skb = dev_alloc_skb(pkt_len+5);
 
-			pr_debug("  Receiving packet size %d status %4.4x.\n",
-				  pkt_len, rx_status);
+			netdev_dbg(dev, "Receiving packet size %d status %04x\n",
+				   pkt_len, rx_status);
 			if (skb != NULL) {
 				skb_reserve(skb, 2);
-				insl(ioaddr+RX_FIFO, skb_put(skb, pkt_len),
-						((pkt_len+3)>>2));
+				insl(ioaddr + RX_FIFO, skb_put(skb, pkt_len),
+				     ((pkt_len+3) >> 2));
 				skb->protocol = eth_type_trans(skb, dev);
 				netif_rx(skb);
 				dev->stats.rx_packets++;
 				dev->stats.rx_bytes += pkt_len;
 			} else {
-				pr_debug("%s: couldn't allocate a sk_buff of"
-					  " size %d.\n", dev->name, pkt_len);
+				netdev_dbg(dev, "couldn't allocate a sk_buff of size %d\n",
+					   pkt_len);
 				dev->stats.rx_dropped++;
 			}
 		}
@@ -1093,41 +1144,39 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	struct mii_ioctl_data *data = if_mii(rq);
 	int phy = lp->phys & 0x1f;
 
-	pr_debug("%s: In ioct(%-.6s, %#4.4x) %4.4x %4.4x %4.4x %4.4x.\n",
-		  dev->name, rq->ifr_ifrn.ifrn_name, cmd,
-		  data->phy_id, data->reg_num, data->val_in, data->val_out);
+	netdev_dbg(dev, "In ioct(%-.6s, %#04x) %04x %04x %04x %04x\n",
+		   rq->ifr_ifrn.ifrn_name, cmd,
+		   data->phy_id, data->reg_num, data->val_in, data->val_out);
 
-	switch(cmd) {
+	switch (cmd) {
 	case SIOCGMIIPHY:		/* Get the address of the PHY in use. */
 		data->phy_id = phy;
-	case SIOCGMIIREG:		/* Read the specified MII register. */
-		{
-			int saved_window;
-			unsigned long flags;
-
-			spin_lock_irqsave(&lp->window_lock, flags);
-			saved_window = inw(ioaddr + EL3_CMD) >> 13;
-			EL3WINDOW(4);
-			data->val_out = mdio_read(ioaddr, data->phy_id & 0x1f,
-						  data->reg_num & 0x1f);
-			EL3WINDOW(saved_window);
-			spin_unlock_irqrestore(&lp->window_lock, flags);
-			return 0;
-		}
-	case SIOCSMIIREG:		/* Write the specified MII register */
-		{
-			int saved_window;
-                       unsigned long flags;
-
-			spin_lock_irqsave(&lp->window_lock, flags);
-			saved_window = inw(ioaddr + EL3_CMD) >> 13;
-			EL3WINDOW(4);
-			mdio_write(ioaddr, data->phy_id & 0x1f,
-				   data->reg_num & 0x1f, data->val_in);
-			EL3WINDOW(saved_window);
-			spin_unlock_irqrestore(&lp->window_lock, flags);
-			return 0;
-		}
+	case SIOCGMIIREG: {		/* Read the specified MII register. */
+		int saved_window;
+		unsigned long flags;
+
+		spin_lock_irqsave(&lp->window_lock, flags);
+		saved_window = inw(ioaddr + EL3_CMD) >> 13;
+		EL3WINDOW(4);
+		data->val_out = mdio_read(ioaddr, data->phy_id & 0x1f,
+					  data->reg_num & 0x1f);
+		EL3WINDOW(saved_window);
+		spin_unlock_irqrestore(&lp->window_lock, flags);
+		return 0;
+	}
+	case SIOCSMIIREG: {		/* Write the specified MII register */
+		int saved_window;
+		unsigned long flags;
+
+		spin_lock_irqsave(&lp->window_lock, flags);
+		saved_window = inw(ioaddr + EL3_CMD) >> 13;
+		EL3WINDOW(4);
+		mdio_write(ioaddr, data->phy_id & 0x1f,
+			   data->reg_num & 0x1f, data->val_in);
+		EL3WINDOW(saved_window);
+		spin_unlock_irqrestore(&lp->window_lock, flags);
+		return 0;
+	}
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1144,14 +1193,13 @@ static int el3_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 static void set_rx_mode(struct net_device *dev)
 {
 	unsigned int ioaddr = dev->base_addr;
+	enum el3_cmds filters = SetRxFilter | RxStation | RxBroadcast;
 
 	if (dev->flags & IFF_PROMISC)
-		outw(SetRxFilter | RxStation | RxMulticast | RxBroadcast | RxProm,
-			 ioaddr + EL3_CMD);
+		filters |= RxMulticast | RxProm;
 	else if (!netdev_mc_empty(dev) || (dev->flags & IFF_ALLMULTI))
-		outw(SetRxFilter|RxStation|RxMulticast|RxBroadcast, ioaddr + EL3_CMD);
-	else
-		outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
+		filters |= RxMulticast;
+	outw(filters, ioaddr + EL3_CMD);
 }
 
 static void set_multicast_list(struct net_device *dev)
@@ -1170,18 +1218,18 @@ static int el3_close(struct net_device *dev)
 	struct el3_private *lp = netdev_priv(dev);
 	struct pcmcia_device *link = lp->p_dev;
 
-	dev_dbg(&link->dev, "%s: shutting down ethercard.\n", dev->name);
-	
+	netdev_dbg(dev, "shutting down ethercard\n");
+
 	if (pcmcia_dev_present(link)) {
 		unsigned long flags;
 
 		/* Turn off statistics ASAP.  We update lp->stats below. */
 		outw(StatsDisable, ioaddr + EL3_CMD);
-		
+
 		/* Disable the receiver and transmitter. */
 		outw(RxDisable, ioaddr + EL3_CMD);
 		outw(TxDisable, ioaddr + EL3_CMD);
-		
+
 		/* Note: Switching to window 0 may disable the IRQ. */
 		EL3WINDOW(0);
 		spin_lock_irqsave(&lp->window_lock, flags);


