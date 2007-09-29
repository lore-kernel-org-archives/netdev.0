From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Sat, 29 Sep 2007 02:08:23 -0400
Message-ID: <20070929060823.GA18873@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:36404 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752729AbXI2GIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 02:08:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from the 'upstream' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream

to receive the following changes:

Adrian Bunk (1):
      drivers/net/cxgb3/xgmac.c: remove dead code

Chris Snook (1):
      atl1: explain 32-bit DMA restriction

Ed Swierk (1):
      forcedeth: "no link" is informational

Jeff Garzik (1):
      [netdrvr] sundance: fix phy scanning on IP100A

Jesper Juhl (1):
      Avoid possible NULL pointer deref in 3c359 driver

Krishna Kumar (1):
      e1000e: Do not allow requeue of freed skb

Maciej W. Rozycki (5):
      sb1250-mac.c: De-typedef, de-volatile, de-etc...
      sb1250-mac: Driver model & phylib update
      PHYLIB: Spinlock fixes for softirqs
      PHYLIB: IRQ event workqueue handling fixes
      PHYLIB: fix an interrupt loop potential when halting

Magnus Damm (1):
      ax88796: add 93cx6 eeprom support

Mariusz Kozlowski (1):
      skge: remove broken and unused PHY_M_PC_MDI_XMODE macro

Micah Gruber (1):
      Fix a potential NULL pointer dereference in uli526x_interrupt() in drivers/net/tulip/uli526x.c

Nathanael Nerode (1):
      dgrs: remove from build, config, and maintainer list

Olof Johansson (4):
      pasemi_mac: set interface speed correctly on XAUI ports
      pasemi_mac: flags as passed to spin_*_irqsave() should be unsigned long
      pasemi_mac: don't enable rx before there are buffers on the ring
      pasemi_mac: pass in count of buffers to replenish rx ring with

Peter Oruba (1):
      PCI-X/PCI-Express read control interfaces: use them in e1000

Roy Zang (1):
      Clean up redundant PHY write line for ULi526x Ethernet driver

Stephen Hemminger (2):
      via-velocity: use standard VLAN interface (resend)
      via-velocity: more cleanup

Vitaly Bordug (1):
      PHY fixed driver: rework release path and update phy_id notation

 Documentation/networking/dgrs.txt |   52 
 MAINTAINERS                       |    6 
 drivers/net/Kconfig               |   23 
 drivers/net/Makefile              |    1 
 drivers/net/atl1/atl1_main.c      |   10 
 drivers/net/ax88796.c             |   49 
 drivers/net/cxgb3/xgmac.c         |    5 
 drivers/net/dgrs.c                | 1593 ------
 drivers/net/dgrs.h                |   38 
 drivers/net/dgrs_asstruct.h       |   37 
 drivers/net/dgrs_bcomm.h          |  148 
 drivers/net/dgrs_es4h.h           |  183 
 drivers/net/dgrs_ether.h          |  135 
 drivers/net/dgrs_firmware.c       | 9966 --------------------------------------
 drivers/net/dgrs_i82596.h         |  473 -
 drivers/net/dgrs_plx9060.h        |  175 
 drivers/net/e1000/e1000_hw.c      |   25 
 drivers/net/e1000/e1000_hw.h      |    2 
 drivers/net/e1000/e1000_main.c    |   14 
 drivers/net/e1000e/netdev.c       |    2 
 drivers/net/forcedeth.c           |    2 
 drivers/net/pasemi_mac.c          |   43 
 drivers/net/phy/Kconfig           |   14 
 drivers/net/phy/fixed.c           |  310 -
 drivers/net/phy/phy.c             |   52 
 drivers/net/phy/phy_device.c      |    4 
 drivers/net/sb1250-mac.c          | 1367 ++---
 drivers/net/skge.h                |    2 
 drivers/net/sundance.c            |   14 
 drivers/net/tokenring/3c359.c     |    5 
 drivers/net/tulip/uli526x.c       |    6 
 drivers/net/via-velocity.c        |  247 
 drivers/net/via-velocity.h        |  207 
 include/linux/eeprom_93cx6.h      |    3 
 include/linux/phy.h               |    3 
 include/linux/phy_fixed.h         |   38 
 include/net/ax88796.h             |    1 
 37 files changed, 1233 insertions(+), 14022 deletions(-)

diff --git a/Documentation/networking/dgrs.txt b/Documentation/networking/dgrs.txt
deleted file mode 100644
index 1aa1bb3..0000000
--- a/Documentation/networking/dgrs.txt
+++ /dev/null
@@ -1,52 +0,0 @@
-    The Digi International RightSwitch SE-X (dgrs) Device Driver
-
-This is a Linux driver for the Digi International RightSwitch SE-X
-EISA and PCI boards.  These are 4 (EISA) or 6 (PCI) port Ethernet
-switches and a NIC combined into a single board.  This driver can
-be compiled into the kernel statically or as a loadable module.
-
-There is also a companion management tool, called "xrightswitch".
-The management tool lets you watch the performance graphically,
-as well as set the SNMP agent IP and IPX addresses, IEEE Spanning
-Tree, and Aging time.  These can also be set from the command line
-when the driver is loaded.  The driver command line options are:
-
-	debug=NNN		Debug printing level
-	dma=0/1			Disable/Enable DMA on PCI card
-	spantree=0/1		Disable/Enable IEEE spanning tree
-	hashexpire=NNN		Change address aging time (default 300 seconds)
-	ipaddr=A,B,C,D		Set SNMP agent IP address i.e. 199,86,8,221
-	iptrap=A,B,C,D		Set SNMP agent IP trap address i.e. 199,86,8,221
-	ipxnet=NNN		Set SNMP agent IPX network number
-	nicmode=0/1		Disable/Enable multiple NIC mode
-
-There is also a tool for setting up input and output packet filters
-on each port, called "dgrsfilt".
-
-Both the management tool and the filtering tool are available
-separately from the following FTP site:
-
-	ftp://ftp.dgii.com/drivers/rightswitch/linux/
-
-When nicmode=1, the board and driver operate as 4 or 6 individual
-NIC ports (eth0...eth5) instead of as a switch.  All switching
-functions are disabled.  In the future, the board firmware may include
-a routing cache when in this mode.
-
-Copyright 1995-1996 Digi International Inc.
-
-This software may be used and distributed according to the terms
-of the GNU General Public License, incorporated herein by reference.
-
-For information on purchasing a RightSwitch SE-4 or SE-6
-board, please contact Digi's sales department at 1-612-912-3444
-or 1-800-DIGIBRD.  Outside the U.S., please check our Web page at:
-
-	http://www.dgii.com
-
-for sales offices worldwide.  Tech support is also available through
-the channels listed on the Web site, although as long as I am
-employed on networking products at Digi I will be happy to provide
-any bug fixes that may be needed.
-
--Rick Richardson, rick@dgii.com
diff --git a/MAINTAINERS b/MAINTAINERS
index 27e1110..1664680 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1274,12 +1274,6 @@ L:	Eng.Linux@digi.com
 W:	http://www.digi.com
 S:	Orphaned
 
-DIGI RIGHTSWITCH NETWORK DRIVER
-P:	Rick Richardson
-L:	netdev@vger.kernel.org
-W:	http://www.digi.com
-S:	Orphaned
-
 DIRECTORY NOTIFICATION
 P:	Stephen Rothwell
 M:	sfr@canb.auug.org.au
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 467532c..45f6cf5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -240,6 +240,13 @@ config AX88796
 	  AX88796 driver, using platform bus to provide
 	  chip detection and resources
 
+config AX88796_93CX6
+	bool "ASIX AX88796 external 93CX6 eeprom support"
+	depends on AX88796
+	select EEPROM_93CX6
+	help
+	  Select this if your platform comes with an external 93CX6 eeprom.
+
 config MACE
 	tristate "MACE (Power Mac ethernet) support"
 	depends on PPC_PMAC && PPC32
@@ -1459,21 +1466,6 @@ config TC35815
 	depends on NET_PCI && PCI && MIPS
 	select MII
 
-config DGRS
-	tristate "Digi Intl. RightSwitch SE-X support"
-	depends on NET_PCI && (PCI || EISA)
-	---help---
-	  This is support for the Digi International RightSwitch series of
-	  PCI/EISA Ethernet switch cards. These include the SE-4 and the SE-6
-	  models.  If you have a network card of this type, say Y and read the
-	  Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  More specific
-	  information is contained in <file:Documentation/networking/dgrs.txt>.
-
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module
-	  will be called dgrs.
-
 config EEPRO100
 	tristate "EtherExpressPro/100 support (eepro100, original Becker driver)"
 	depends on NET_PCI && PCI
@@ -2126,6 +2118,7 @@ config R8169_VLAN
 config SB1250_MAC
 	tristate "SB1250 Gigabit Ethernet support"
 	depends on SIBYTE_SB1xxx_SOC
+	select PHYLIB
 	---help---
 	  This driver supports Gigabit Ethernet interfaces based on the
 	  Broadcom SiByte family of System-On-a-Chip parts.  They include
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 6220c50..eb5c655 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -44,7 +44,6 @@ obj-$(CONFIG_SUNVNET) += sunvnet.o
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
 
-obj-$(CONFIG_DGRS) += dgrs.o
 obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index e1a9223..4c728f1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2209,8 +2209,14 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		return err;
 
 	/*
-	 * 64-bit DMA currently has data corruption problems, so let's just
-	 * use 32-bit DMA for now.  This is a big hack that is probably wrong.
+	 * The atl1 chip can DMA to 64-bit addresses, but it uses a single
+	 * shared register for the high 32 bits, so only a single, aligned,
+	 * 4 GB physical address range can be used at a time.
+	 *
+	 * Supporting 64-bit DMA on this hardware is more trouble than it's
+	 * worth.  It is far easier to limit to 32-bit DMA than update
+	 * various kernel subsystems to support the mechanics required by a
+	 * fixed-high-32-bit system.
 	 */
 	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err) {
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 90e0734..9fe0517 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -24,6 +24,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/eeprom_93cx6.h>
 
 #include <net/ax88796.h>
 
@@ -582,6 +583,37 @@ static const struct ethtool_ops ax_ethtool_ops = {
 	.get_link		= ax_get_link,
 };
 
+#ifdef CONFIG_AX88796_93CX6
+static void ax_eeprom_register_read(struct eeprom_93cx6 *eeprom)
+{
+	struct ei_device *ei_local = eeprom->data;
+	u8 reg = ei_inb(ei_local->mem + AX_MEMR);
+
+	eeprom->reg_data_in = reg & AX_MEMR_EEI;
+	eeprom->reg_data_out = reg & AX_MEMR_EEO; /* Input pin */
+	eeprom->reg_data_clock = reg & AX_MEMR_EECLK;
+	eeprom->reg_chip_select = reg & AX_MEMR_EECS;
+}
+
+static void ax_eeprom_register_write(struct eeprom_93cx6 *eeprom)
+{
+	struct ei_device *ei_local = eeprom->data;
+	u8 reg = ei_inb(ei_local->mem + AX_MEMR);
+
+	reg &= ~(AX_MEMR_EEI | AX_MEMR_EECLK | AX_MEMR_EECS);
+
+	if (eeprom->reg_data_in)
+		reg |= AX_MEMR_EEI;
+	if (eeprom->reg_data_clock)
+		reg |= AX_MEMR_EECLK;
+	if (eeprom->reg_chip_select)
+		reg |= AX_MEMR_EECS;
+
+	ei_outb(reg, ei_local->mem + AX_MEMR);
+	udelay(10);
+}
+#endif
+
 /* setup code */
 
 static void ax_initial_setup(struct net_device *dev, struct ei_device *ei_local)
@@ -640,6 +672,23 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 		memcpy(dev->dev_addr,  SA_prom, 6);
 	}
 
+#ifdef CONFIG_AX88796_93CX6
+	if (first_init && ax->plat->flags & AXFLG_HAS_93CX6) {
+		unsigned char mac_addr[6];
+		struct eeprom_93cx6 eeprom;
+
+		eeprom.data = ei_local;
+		eeprom.register_read = ax_eeprom_register_read;
+		eeprom.register_write = ax_eeprom_register_write;
+		eeprom.width = PCI_EEPROM_WIDTH_93C56;
+
+		eeprom_93cx6_multiread(&eeprom, 0,
+				       (__le16 __force *)mac_addr,
+				       sizeof(mac_addr) >> 1);
+
+		memcpy(dev->dev_addr,  mac_addr, 6);
+	}
+#endif
 	if (ax->plat->wordlength == 2) {
 		/* We must set the 8390 for word mode. */
 		ei_outb(ax->plat->dcr_val, ei_local->mem + EN0_DCFG);
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index ff9e9dc..bcb5bc4 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -522,10 +522,7 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 		goto rxcheck;
 	}
 
-	if (((tx_tcnt != mac->tx_tcnt) &&
-	     (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
-	    ((mac->tx_mcnt == tx_mcnt) &&
-	     (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
+	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
 		if (mac->toggle_cnt > 4) {
 			status = 2;
 			goto out;
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
deleted file mode 100644
index 054f2ba..0000000
--- a/drivers/net/dgrs.c
+++ /dev/null

[SNIPPED AS OBVIOUS, for file size reasons]

diff --git a/drivers/net/dgrs.h b/drivers/net/dgrs.h
deleted file mode 100644
index 6058d53..0000000
--- a/drivers/net/dgrs.h
+++ /dev/null
@@ -1,38 +0,0 @@
-/*
- *	ioctl's for the Digi Intl. RightSwitch
- *
- *	These network driver ioctl's are a bit obtuse compared to the usual
- *	ioctl's for a "normal" device driver.  Hey, I didn't invent it.
- *
- *	Typical use:
- *
- *	struct ifreq	ifr;
- *	DGRS_IOCTL	ioc;
- *	int		x;
- *
- *	strcpy(ifr.ifr_name, "eth1");
- *	ifr.ifr_data = (caddr_t) &ioc;
- *	ioc.cmd = DGRS_GETMEM;
- *	ioc.len = sizeof(x);
- *	ioc.data = (caddr_t) &x;
- *	rc = ioctl(fd, DGRSIOCTL, &ifr);
- *	printf("rc=%d mem=%x\n", rc, x);
- *
- */
-#include <linux/sockios.h>
-
-#define DGRSIOCTL      SIOCDEVPRIVATE
-
-typedef struct dgrs_ioctl {
-	unsigned short cmd;	/* Command to run */
-	unsigned short len;	/* Length of the data buffer */
-	unsigned char  __user *data;	/* Pointer to the data buffer */
-	unsigned short	port;	/* port number for command, if needed */
-	unsigned short	filter;	/* filter number for command, if needed */
-} DGRS_IOCTL;
-
-/*
- *	Commands for the driver
- */
-#define	DGRS_GETMEM		0x01	/* Get the dual port memory address */
-#define	DGRS_SETFILTER		0x02	/* Set a filter */
diff --git a/drivers/net/dgrs_asstruct.h b/drivers/net/dgrs_asstruct.h
deleted file mode 100644
index f0e2121..0000000
--- a/drivers/net/dgrs_asstruct.h
+++ /dev/null
@@ -1,37 +0,0 @@
-/*
- *	For declaring structures shared with assembly routines
- *
- *	$Id: asstruct.h,v 1.1.1.1 1994/10/23 05:08:32 rick Exp $
- */
-
-#ifdef ASSEMBLER
-
-#	define MO(t,a)		(a)
-#	define VMO(t,a)		(a)
-
-#	define	BEGIN_STRUCT(x)	_Off=0
-#	define	S1A(t,x,n)	_Off=(_Off+0)&~0; x=_Off; _Off=_Off+(1*n)
-#	define	S2A(t,x,n)	_Off=(_Off+1)&~1; x=_Off; _Off=_Off+(2*n)
-#	define	S4A(t,x,n)	_Off=(_Off+3)&~3; x=_Off; _Off=_Off+(4*n)
-#	define	WORD(x)		_Off=(_Off+3)&~3; x=_Off; _Off=_Off+4
-#	define	WORDA(x,n)	_Off=(_Off+3)&~3; x=_Off; _Off=_Off+(4*n)
-#	define	VWORD(x)	_Off=(_Off+3)&~3; x=_Off; _Off=_Off+4
-#	define	S1(t,x)		_Off=(_Off+0)&~0; x=_Off; _Off=_Off+1
-#	define	S2(t,x)		_Off=(_Off+1)&~1; x=_Off; _Off=_Off+2
-#	define	S4(t,x)		_Off=(_Off+3)&~3; x=_Off; _Off=_Off+4
-#	define	END_STRUCT(x)	_Off=(_Off+3)&~3; x=_Off
-
-#else	/* C */
-
-#define VMO(t,a)        (*(volatile t *)(a))
-
-#	define BEGIN_STRUCT(x) struct x {
-#	define S1(t,x)         t x ;
-#	define S1A(t,x,n)      t x[n] ;
-#	define S2(t,x)         t x ;
-#	define S2A(t,x,n)      t x[n] ;
-#	define S4(t,x)         t x ;
-#	define S4A(t,x,n)      t x[n] ;
-#	define END_STRUCT(x)   } ;
-
-#endif
diff --git a/drivers/net/dgrs_bcomm.h b/drivers/net/dgrs_bcomm.h
deleted file mode 100644
index 5e9c252..0000000
--- a/drivers/net/dgrs_bcomm.h
+++ /dev/null
@@ -1,148 +0,0 @@
-/*
- * The bios low-memory structure
- *
- * Some of the variables in here can be used to set parameters that
- * are stored in NVRAM and will retain their old values the next time
- * the card is brought up.  To use the values stored in NVRAM, the
- * parameter should be set to "all ones".  This tells the firmware to
- * use the NVRAM value or a suitable default.  The value that is used
- * will be stored back into this structure by the firmware.  If the
- * value of the variable is not "all ones", then that value will be
- * used and will be stored into NVRAM if it isn't already there.
- * The variables this applies to are the following:
- *	Variable	Set to:		Gets default of:
- *	bc_hashexpire	-1		300	(5 minutes)
- *	bc_spantree	-1		1	(spanning tree on)
- *	bc_ipaddr	FF:FF:FF:FF	0	(no SNMP IP address)
- *	bc_ipxnet	FF:FF:FF:FF	0	(no SNMP IPX net)
- *	bc_iptrap	FF:FF:FF:FF	0	(no SNMP IP trap address)
- *
- * Some variables MUST have their value set after the firmware
- * is loaded onto the board, but before the processor is released.
- * These are:
- *	bc_host		0 means no host "port", run as standalone switch.
- *			1 means run as a switch, with a host port. (normal)
- *			2 means run as multiple NICs, not as a switch.
- *			-1 means run in diagnostics mode.
- *	bc_nowait
- *	bc_hostarea_len
- *	bc_filter_len
- *
- */
-BEGIN_STRUCT(bios_comm)
-	S4(ulong, bc_intflag)	/* Count of all interrupts */
-	S4(ulong, bc_lbolt)	/* Count of timer interrupts */
-	S4(ulong, bc_maincnt)	/* Count of main loops */
-	S4(ulong, bc_hashcnt)	/* Count of entries in hash table */
-	S4A(ulong, bc_cnt, 8)	/* Misc counters, for debugging */
-	S4A(ulong, bc_flag, 8)	/* Misc flags, for debugging */
-	S4(ulong, bc_memsize)	/* Size of memory */
-	S4(ulong, bc_dcache)	/* Size of working dcache */
-	S4(ulong, bc_icache)	/* Size of working icache */
-	S4(long, bc_status)	/* Firmware status */
-	S1A(char, bc_file, 8)	/* File name of assertion failure */
-	S4(ulong, bc_line)	/* Line # of assertion failure */
-	S4(uchar *, bc_ramstart)
-	S4(uchar *, bc_ramend)
-	S4(uchar *, bc_heapstart) /* Start of heap (end of loaded memory) */
-	S4(uchar *, bc_heapend)	/* End of heap */
-
-	/* Configurable Parameters */
-	S4(long, bc_host)	/* 1=Host Port, 0=No Host Port, -1=Test Mode */
-	S4(long, bc_nowait)	/* Don't wait for 2host circ buffer to empty*/
-	S4(long, bc_150ohm)	/* 0 == 100 ohm UTP, 1 == 150 ohm STP */
-	S4(long, bc_squelch)	/* 0 == normal squelch, 1 == reduced squelch */
-	S4(ulong, bc_hashexpire) /* Expiry time in seconds for hash table */
-	S4(long, bc_spantree)	/* 1 == enable IEEE spanning tree */
-
-	S2A(ushort, bc_eaddr, 3) /* New ether address */
-	S2(ushort, bc_dummy1)	/* padding for DOS compilers */
-
-	/* Various debugging aids */
-	S4(long, bc_debug)	/* Debugging is turned on */
-	S4(long, bc_spew)	/* Spew data on port 4 for bs_spew seconds */
-	S4(long, bc_spewlen)	/* Length of spewed data packets */
-	S4(long, bc_maxrfd)	/* If != 0, max number of RFD's to allocate */
-	S4(long, bc_maxrbd)	/* If != 0, max number of RBD's to allocate */
-
-	/* Circular buffers for messages to/from host */
-	S4(ulong, bc_2host_head)
-	S4(ulong, bc_2host_tail)
-	S4(ulong, bc_2host_mask)
-	S1A(char, bc_2host, 0x200)	/* Circ buff to host */
-
-	S4(ulong, bc_2idt_head)
-	S4(ulong, bc_2idt_tail)
-	S4(ulong, bc_2idt_mask)
-	S1A(char, bc_2idt, 0x200)	/* Circ buff to idt */
-
-	/* Pointers to structures for driver access */
-	S4(uchar *, bc_port)	/* pointer to Port[] structures */
-	S4(long, bc_nports)	/* Number of ports */
-	S4(long, bc_portlen)	/* sizeof(PORT) */
-	S4(uchar *, bc_hash)	/* Pointer to hash table */
-	S4(long, bc_hashlen)	/* sizeof(Table) */
-
-	/* SNMP agent addresses */
-	S1A(uchar, bc_ipaddr, 4) /* IP address for SNMP */
-	S1A(uchar, bc_ipxnet, 4) /* IPX net address for SNMP */
-
-	S4(long, bc_nohostintr) /* Do not cause periodic host interrupts */
-
-	S4(uchar *, bc_dmaaddr) /* Physical addr of host DMA buf for diags */
-	S4(ulong, bc_dmalen)	/* Length of DMA buffer 0..2048 */
-
-	/*
-	 *	Board memory allocated on startup for use by host, usually
-	 *	for the purposes of creating DMA chain descriptors.  The
-	 *	"len" must be set before the processor is released.  The
-	 *	address of the area is returned in bc_hostarea.  The area
-	 *	is guaranteed to be aligned on a 16 byte boundary.
-	 */
-	S4(ulong, bc_hostarea_len)	/* RW: Number of bytes to allocate */
-	S4(uchar *, bc_hostarea)	/* RO: Address of allocated memory */
-
-	/*
-	 *	Variables for communicating filters into the board
-	 */
-	S4(ulong *, bc_filter_area)	/* RO: Space to put filter into */
-	S4(ulong, bc_filter_area_len)	/* RO: Length of area, in bytes */
-	S4(long, bc_filter_cmd)		/* RW: Filter command, see below */
-	S4(ulong, bc_filter_len)	/* RW: Actual length of filter */
-	S4(ulong, bc_filter_port)	/* RW: Port # for filter 0..6 */
-	S4(ulong, bc_filter_num)	/* RW: Filter #, 0=input, 1=output */
-
-	/* more SNMP agent addresses */
-	S1A(uchar, bc_iptrap, 4) /* IP address for SNMP */
-
-	S4A(long, bc_spare, 2)	/* spares */
-END_STRUCT(bios_comm)
-
-#define	bc	VMO(struct bios_comm, 0xa3000100)
-
-/*
- *	bc_status values
- */
-#define	BC_INIT	0
-#define	BC_RUN	100
-
-/*
- *	bc_host values
- */
-#define	BC_DIAGS	-1
-#define BC_SASWITCH	0
-#define	BC_SWITCH	1
-#define	BC_MULTINIC	2
-
-/*
- *	Values for spew (debugging)
- */
-#define	BC_SPEW_ENABLE	0x80000000
-
-/*
- *	filter commands
- */
-#define	BC_FILTER_ERR	-1
-#define	BC_FILTER_OK	0
-#define	BC_FILTER_SET	1
-#define	BC_FILTER_CLR	2
diff --git a/drivers/net/dgrs_es4h.h b/drivers/net/dgrs_es4h.h
deleted file mode 100644
index 5518fba..0000000
--- a/drivers/net/dgrs_es4h.h
+++ /dev/null
@@ -1,183 +0,0 @@
-/************************************************************************/
-/*									*/
-/*	es4h.h:	Hardware definition of the ES/4h Ethernet Switch, from	*/
-/*		both the host and the 3051's point of view.		*/
-/*		NOTE: this name is a misnomer now that there is a PCI	*/
-/*		board.  Everything that says "es4h" should really be	*/
-/*		"se4".  But we'll keep the old name for now.		*/
-/*									*/
-/*	$Id: es4h.h,v 1.10 1996/08/22 17:16:53 rick Exp $		*/
-/*									*/
-/************************************************************************/
-
-/************************************************************************/
-/*									*/
-/*	EISA I/O Registers.  These are located at 0x1000 * slot-number	*/
-/*	plus the indicated address.  I.E. 0x4000-0x4009 for slot 4.	*/
-/*									*/
-/************************************************************************/
-
-#define	ES4H_MANUFmsb	0x00		/* Read-only */
-#define	ES4H_MANUFlsb	0x01		/* Read-only */
-#	define ES4H_MANUF_CODE		0x1049	/* = "DBI" */
-
-#define	ES4H_PRODUCT	0x02		/* Read-only */
-#	define ES4H_PRODUCT_CODE	0x0A
-#	define EPC_PRODUCT_CODE		0x03
-
-#define	ES4H_REVISION	0x03		/* Read-only */
-#	define ES4H_REVISION_CODE	0x01
-
-#define	ES4H_EC		0x04		/* EISA Control */
-#	define ES4H_EC_RESET		0x04	/* WO, EISA reset */
-#	define ES4H_EC_ENABLE		0x01	/* RW, EISA enable - set to */
-						/* 1 before memory enable */
-#define	ES4H_PC		0x05		/* Processor Control */
-#	define ES4H_PC_RESET		0x04	/* RW, 3051 reset */
-#	define ES4H_PC_INT		0x08	/* WO, assert 3051 intr. 3 */
-
-#define	ES4H_MW		0x06		/* Memory Window select and enable */
-#	define ES4H_MW_ENABLE		0x80	/* WO, enable memory */
-#	define ES4H_MW_SELECT_MASK	0x1f	/* WO, 32k window selected */
-
-#define	ES4H_IS		0x07		/* Interrupt, addr select */
-#	define ES4H_IS_INTMASK		0x07	/* WO, interrupt select */
-#	define ES4H_IS_INTOFF		0x00		/* No IRQ */
-#	define ES4H_IS_INT3		0x03		/* IRQ 3 */
-#	define ES4H_IS_INT5		0x02		/* IRQ 5 */
-#	define ES4H_IS_INT7		0x01		/* IRQ 7 */
-#	define ES4H_IS_INT10		0x04		/* IRQ 10 */
-#	define ES4H_IS_INT11		0x05		/* IRQ 11 */
-#	define ES4H_IS_INT12		0x06		/* IRQ 12 */
-#	define ES4H_IS_INT15		0x07		/* IRQ 15 */
-#	define ES4H_IS_INTACK		0x10	/* WO, interrupt ack */
-#	define ES4H_IS_INTPEND		0x10	/* RO, interrupt pending */
-#	define ES4H_IS_LINEAR		0x40	/* WO, no memory windowing */
-#	define ES4H_IS_AS15		0x80	/* RW, address select bit 15 */
-
-#define	ES4H_AS_23_16	0x08		/* Address select bits 23-16 */
-#define	ES4H_AS_31_24	0x09		/* Address select bits 31-24 */
-
-#define ES4H_IO_MAX		0x09		/* Size of I/O space */
-
-/*
- * PCI
- */
-#define SE6_RESET		PLX_USEROUT
-
-/************************************************************************/
-/*									*/
-/*	3051 Memory Map							*/
-/*									*/
-/*	Note: 3051 has 4K I-cache, 2K D-cache.  1 cycle is 50 nsec.	*/
-/*									*/
-/************************************************************************/
-#define	SE4_NPORTS		4		/* # of ethernet ports */
-#define	SE6_NPORTS		6		/* # of ethernet ports */
-#define	SE_NPORTS		6		/* Max # of ethernet ports */
-
-#define	ES4H_RAM_BASE		0x83000000	/* Base address of RAM */
-#define	ES4H_RAM_SIZE		0x00200000	/* Size of RAM (2MB) */
-#define	ES4H_RAM_INTBASE	0x83800000	/* Base of int-on-write RAM */
-						/* a.k.a. PKT RAM */
-
-						/* Ethernet controllers */
-						/* See: i82596.h */
-#define	ES4H_ETHER0_PORT	0xA2000000
-#define	ES4H_ETHER0_CMD		0xA2000100
-#define	ES4H_ETHER1_PORT	0xA2000200
-#define	ES4H_ETHER1_CMD		0xA2000300
-#define	ES4H_ETHER2_PORT	0xA2000400
-#define	ES4H_ETHER2_CMD		0xA2000500
-#define	ES4H_ETHER3_PORT	0xA2000600
-#define	ES4H_ETHER3_CMD		0xA2000700
-#define	ES4H_ETHER4_PORT	0xA2000800	/* RS SE-6 only */
-#define	ES4H_ETHER4_CMD		0xA2000900	/* RS SE-6 only */
-#define	ES4H_ETHER5_PORT	0xA2000A00	/* RS SE-6 only */
-#define	ES4H_ETHER5_CMD		0xA2000B00	/* RS SE-6 only */
-
-#define	ES4H_I8254		0xA2040000	/* 82C54 timers */
-						/* See: i8254.h */
-
-#define	SE4_I8254_HZ		(23000000/4)	/* EISA clock input freq. */
-#define	SE4_IDT_HZ		(46000000)	/* EISA CPU freq. */
-#define	SE6_I8254_HZ		(20000000/4)	/* PCI clock input freq. */
-#define	SE6_IDT_HZ		(50000000)	/* PCI CPU freq. */
-#define	ES4H_I8254_HZ		(23000000/4)	/* EISA clock input freq. */
-
-#define	ES4H_GPP		0xA2050000	/* General purpose port */
-	/*
-	 * SE-4 (EISA) GPP bits
-	 */
-#	define ES4H_GPP_C0_100		0x0001	/* WO, Chan 0: 100 ohm TP */
-#	define ES4H_GPP_C0_SQE		0x0002	/* WO, Chan 0: normal squelch */
-#	define ES4H_GPP_C1_100		0x0004	/* WO, Chan 1: 100 ohm TP */
-#	define ES4H_GPP_C1_SQE		0x0008	/* WO, Chan 1: normal squelch */
-#	define ES4H_GPP_C2_100		0x0010	/* WO, Chan 2: 100 ohm TP */
-#	define ES4H_GPP_C2_SQE		0x0020	/* WO, Chan 2: normal squelch */
-#	define ES4H_GPP_C3_100		0x0040	/* WO, Chan 3: 100 ohm TP */
-#	define ES4H_GPP_C3_SQE		0x0080	/* WO, Chan 3: normal squelch */
-#	define ES4H_GPP_SQE		0x00AA	/* WO, All: normal squelch */
-#	define ES4H_GPP_100		0x0055	/* WO, All: 100 ohm TP */
-#	define ES4H_GPP_HOSTINT		0x0100	/* RO, cause intr. to host */
-						/* Hold high > 250 nsec */
-#	define SE4_GPP_EED		0x0200	/* RW, EEPROM data bit */
-#	define SE4_GPP_EECS		0x0400	/* RW, EEPROM chip select */
-#	define SE4_GPP_EECK		0x0800	/* RW, EEPROM clock */
-
-	/*
-	 * SE-6 (PCI) GPP bits
-	 */
-#	define SE6_GPP_EED		0x0001	/* RW, EEPROM data bit */
-#	define SE6_GPP_EECS		0x0002	/* RW, EEPROM chip select */
-#	define SE6_GPP_EECK		0x0004	/* RW, EEPROM clock */
-#	define SE6_GPP_LINK		0x00fc	/* R, Link status LEDs */
-
-#define	ES4H_INTVEC		0xA2060000	/* RO: Interrupt Vector */
-#	define ES4H_IV_DMA0		0x01	/* Chan 0 DMA interrupt */
-#	define ES4H_IV_PKT0		0x02	/* Chan 0 PKT interrupt */
-#	define ES4H_IV_DMA1		0x04	/* Chan 1 DMA interrupt */
-#	define ES4H_IV_PKT1		0x08	/* Chan 1 PKT interrupt */
-#	define ES4H_IV_DMA2		0x10	/* Chan 2 DMA interrupt */
-#	define ES4H_IV_PKT2		0x20	/* Chan 2 PKT interrupt */
-#	define ES4H_IV_DMA3		0x40	/* Chan 3 DMA interrupt */
-#	define ES4H_IV_PKT3		0x80	/* Chan 3 PKT interrupt */
-
-#define	ES4H_INTACK		0xA2060000	/* WO: Interrupt Ack */
-#	define ES4H_INTACK_8254		0x01	/* Real Time Clock (int 0) */
-#	define ES4H_INTACK_HOST		0x02	/* Host (int 1) */
-#	define ES4H_INTACK_PKT0		0x04	/* Chan 0 Pkt (int 2) */
-#	define ES4H_INTACK_PKT1		0x08	/* Chan 1 Pkt (int 3) */
-#	define ES4H_INTACK_PKT2		0x10	/* Chan 2 Pkt (int 4) */
-#	define ES4H_INTACK_PKT3		0x20	/* Chan 3 Pkt (int 5) */
-
-#define	SE6_PLX			0xA2070000	/* PLX 9060, SE-6 (PCI) only */
-						/* see plx9060.h */
-
-#define	SE6_PCI_VENDOR_ID	0x114F		/* Digi PCI vendor ID */
-#define	SE6_PCI_DEVICE_ID	0x0003		/* RS SE-6 device ID */
-#define	SE6_PCI_ID		((SE6_PCI_DEVICE_ID<<16) | SE6_PCI_VENDOR_ID)
-
-/*
- *	IDT Interrupts
- */
-#define	ES4H_INT_8254		IDT_INT0
-#define	ES4H_INT_HOST		IDT_INT1
-#define	ES4H_INT_ETHER0		IDT_INT2
-#define	ES4H_INT_ETHER1		IDT_INT3
-#define	ES4H_INT_ETHER2		IDT_INT4
-#define	ES4H_INT_ETHER3		IDT_INT5
-
-/*
- *	Because there are differences between the SE-4 and the SE-6,
- *	we assume that the following globals will be set up at init
- *	time in main.c to containt the appropriate constants from above
- */
-extern ushort	Gpp;		/* Softcopy of GPP register */
-extern ushort	EEck;		/* Clock bit */
-extern ushort	EEcs;		/* CS bit */
-extern ushort	EEd;		/* Data bit */
-extern ulong	I8254_Hz;	/* i8254 input frequency */
-extern ulong	IDT_Hz;		/* IDT CPU frequency */
-extern int	Nports;		/* Number of ethernet controllers */
-extern int	Nchan;		/* Nports+1 */
diff --git a/drivers/net/dgrs_ether.h b/drivers/net/dgrs_ether.h
deleted file mode 100644
index 7539b59..0000000
--- a/drivers/net/dgrs_ether.h
+++ /dev/null
@@ -1,135 +0,0 @@
-/*
- *	A filtering function.  There are two filters/port.  Filter "0"
- *	is the input filter, and filter "1" is the output filter.
- */
-typedef int (FILTER_FUNC)(uchar *pktp, int pktlen, ulong *scratch, int port);
-#define	NFILTERS	2
-
-/*
- *	The per port structure
- */
-typedef struct
-{
-	int		chan;		/* Channel number (0-3) */
-	ulong		portaddr;	/* address of 596 port register */
-	volatile ulong	*ca;		/* address of 596 chan attention */
-	ulong		intmask;	/* Interrupt mask for this port */
-	ulong		intack;		/* Ack bit for this port */
-
-	uchar		ethaddr[6];	/* Ethernet address of this port */
-	int		is_promisc;	/* Port is promiscuous */
-
-	int		debug;		/* Debugging turned on */
-
-	I596_ISCP	*iscpp;		/* Uncached ISCP pointer */
-	I596_SCP	*scpp;		/* Uncached SCP pointer */
-	I596_SCB	*scbp;		/* Uncached SCB pointer */
-
-	I596_ISCP	iscp;
-	I596_SCB	scb;
-
-	/* Command Queue */
-	I596_CB		*cb0;
-	I596_CB		*cbN;
-	I596_CB		*cb_head;
-	I596_CB		*cb_tail;
-
-	/* Receive Queue */
-	I596_RFD	*rfd0;
-	I596_RFD	*rfdN;
-	I596_RFD	*rfd_head;
-	I596_RFD	*rfd_tail;
-
-	/* Receive Buffers */
-	I596_RBD	*rbd0;
-	I596_RBD	*rbdN;
-	I596_RBD	*rbd_head;
-	I596_RBD	*rbd_tail;
-	int		buf_size;	/* Size of an RBD buffer */
-	int		buf_cnt;	/* Total RBD's allocated */
-
-	/* Rx Statistics */
-	ulong		cnt_rx_cnt;	/* Total packets rcvd, good and bad */
-	ulong		cnt_rx_good;	/* Total good packets rcvd */
-	ulong		cnt_rx_bad;	/* Total of all bad packets rcvd */
-					/* Subtotals can be gotten from SCB */
-	ulong		cnt_rx_nores;	/* No resources */
-	ulong		cnt_rx_bytes;	/* Total bytes rcvd */
-
-	/* Tx Statistics */
-	ulong		cnt_tx_queued;
-	ulong		cnt_tx_done;
-	ulong		cnt_tx_freed;
-	ulong		cnt_tx_nores;	/* No resources */
-
-	ulong		cnt_tx_bad;
-	ulong		cnt_tx_err_late;
-	ulong		cnt_tx_err_nocrs;
-	ulong		cnt_tx_err_nocts;
-	ulong		cnt_tx_err_under;
-	ulong		cnt_tx_err_maxcol;
-	ulong		cnt_tx_collisions;
-
-	/* Special stuff for host */
-#	define		rfd_freed	cnt_rx_cnt
-	ulong		rbd_freed;
-	int		host_timer;
-
-	/* Added after first beta */
-	ulong		cnt_tx_races;	/* Counts race conditions */
-	int		spanstate;
-	ulong		cnt_st_tx;	/* send span tree pkts */
-	ulong		cnt_st_fail_tx;	/* Failures to send span tree pkts */
-	ulong		cnt_st_fail_rbd;/* Failures to send span tree pkts */
-	ulong		cnt_st_rx;	/* rcv span tree pkts */
-	ulong		cnt_st_rx_bad;	/* bogus st packets rcvd */
-	ulong		cnt_rx_fwd;	/* Rcvd packets that were forwarded */
-
-	ulong		cnt_rx_mcast;	/* Multicast pkts received */
-	ulong		cnt_tx_mcast;	/* Multicast pkts transmitted */
-	ulong		cnt_tx_bytes;	/* Bytes transmitted */
-
-	/*
-	 *	Packet filtering
-	 *	Filter 0: input filter
-	 *	Filter 1: output filter
-	 */
-
-	ulong		*filter_space[NFILTERS];
-	FILTER_FUNC	*filter_func[NFILTERS];
-	ulong		filter_cnt[NFILTERS];
-	ulong		filter_len[NFILTERS];
-
-	ulong		pad[ (512-300) / 4];
-} PORT;
-
-/*
- *	Port[0]			is host interface
- *	Port[1..SE_NPORTS]	are external 10 Base T ports.  Fewer may be in
- *				use, depending on whether this is an SE-4 or
- *				an SE-6.
- *	Port[SE_NPORTS]		Pseudo-port for Spanning tree and SNMP
- */
-extern PORT	Port[1+SE_NPORTS+1];
-
-extern int	Nports;		/* Number of genuine ethernet controllers */
-extern int	Nchan;		/* ... plus one for host interface */
-
-extern int	FirstChan;	/* 0 or 1, depedning on whether host is used */
-extern int	NumChan;	/* 4 or 5 */
-
-/*
- *	A few globals
- */
-extern int	IsPromisc;
-extern int	MultiNicMode;
-
-/*
- *	Functions
- */
-extern void	eth_xmit_spew_on(PORT *p, int cnt);
-extern void	eth_xmit_spew_off(PORT *p);
-
-extern I596_RBD	*alloc_rbds(PORT *p, int num);
-
-extern I596_CB * eth_cb_alloc(PORT *p);
diff --git a/drivers/net/dgrs_firmware.c b/drivers/net/dgrs_firmware.c
deleted file mode 100644
index 8c20d4c..0000000
--- a/drivers/net/dgrs_firmware.c
+++ /dev/null

[SNIPPED AS OBVIOUS, for file size reasons]

diff --git a/drivers/net/dgrs_i82596.h b/drivers/net/dgrs_i82596.h
deleted file mode 100644
index ac9217a..0000000
--- a/drivers/net/dgrs_i82596.h
+++ /dev/null

[SNIPPED AS OBVIOUS, for file size reasons]

diff --git a/drivers/net/dgrs_plx9060.h b/drivers/net/dgrs_plx9060.h
deleted file mode 100644
index 6888ae0..0000000
--- a/drivers/net/dgrs_plx9060.h
+++ /dev/null

[SNIPPED AS OBVIOUS, for file size reasons]

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index ba120f7..6c3b85a 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -870,10 +870,6 @@ e1000_init_hw(struct e1000_hw *hw)
     uint32_t ctrl;
     uint32_t i;
     int32_t ret_val;
-    uint16_t pcix_cmd_word;
-    uint16_t pcix_stat_hi_word;
-    uint16_t cmd_mmrbc;
-    uint16_t stat_mmrbc;
     uint32_t mta_size;
     uint32_t reg_data;
     uint32_t ctrl_ext;
@@ -963,24 +959,9 @@ e1000_init_hw(struct e1000_hw *hw)
         break;
     default:
         /* Workaround for PCI-X problem when BIOS sets MMRBC incorrectly. */
-        if (hw->bus_type == e1000_bus_type_pcix) {
-            e1000_read_pci_cfg(hw, PCIX_COMMAND_REGISTER, &pcix_cmd_word);
-            e1000_read_pci_cfg(hw, PCIX_STATUS_REGISTER_HI,
-                &pcix_stat_hi_word);
-            cmd_mmrbc = (pcix_cmd_word & PCIX_COMMAND_MMRBC_MASK) >>
-                PCIX_COMMAND_MMRBC_SHIFT;
-            stat_mmrbc = (pcix_stat_hi_word & PCIX_STATUS_HI_MMRBC_MASK) >>
-                PCIX_STATUS_HI_MMRBC_SHIFT;
-            if (stat_mmrbc == PCIX_STATUS_HI_MMRBC_4K)
-                stat_mmrbc = PCIX_STATUS_HI_MMRBC_2K;
-            if (cmd_mmrbc > stat_mmrbc) {
-                pcix_cmd_word &= ~PCIX_COMMAND_MMRBC_MASK;
-                pcix_cmd_word |= stat_mmrbc << PCIX_COMMAND_MMRBC_SHIFT;
-                e1000_write_pci_cfg(hw, PCIX_COMMAND_REGISTER,
-                    &pcix_cmd_word);
-            }
-        }
-        break;
+	if (hw->bus_type == e1000_bus_type_pcix && e1000_pcix_get_mmrbc(hw) > 2048)
+		e1000_pcix_set_mmrbc(hw, 2048);
+	break;
     }
 
     /* More time needed for PHY to initialize */
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index fe87146..1084c17 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -424,6 +424,8 @@ void e1000_pci_clear_mwi(struct e1000_hw *hw);
 void e1000_read_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 void e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t * value);
 int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
+void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
+int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index cbd64ce..ce24b48 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4901,6 +4901,20 @@ e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 	pci_write_config_word(adapter->pdev, reg, *value);
 }
 
+int
+e1000_pcix_get_mmrbc(struct e1000_hw *hw)
+{
+	struct e1000_adapter *adapter = hw->back;
+	return pcix_get_mmrbc(adapter->pdev);
+}
+
+void
+e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
+{
+	struct e1000_adapter *adapter = hw->back;
+	pcix_set_mmrbc(adapter->pdev, mmrbc);
+}
+
 int32_t
 e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 885d946..4a21d7d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3531,7 +3531,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* handle pci_map_single() error in e1000_tx_map */
 		dev_kfree_skb_any(skb);
 		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
-		return NETDEV_TX_BUSY;
+		return NETDEV_TX_OK;
 	}
 
 	e1000_tx_queue(adapter, tx_flags, count);
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 666de42..dae30b7 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4917,7 +4917,7 @@ static int nv_open(struct net_device *dev)
 	if (ret) {
 		netif_carrier_on(dev);
 	} else {
-		printk("%s: no link during initialization.\n", dev->name);
+		printk(KERN_INFO "%s: no link during initialization.\n", dev->name);
 		netif_carrier_off(dev);
 	}
 	if (oom)
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 912bc5d..c2d34a8 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -370,23 +370,18 @@ static void pasemi_mac_free_rx_resources(struct net_device *dev)
 	mac->rx = NULL;
 }
 
-static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
+static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int i;
 	int start = mac->rx->next_to_fill;
-	unsigned int limit, count;
-
-	limit = RING_AVAIL(mac->rx);
-	/* Check to see if we're doing first-time setup */
-	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 0))
-		limit = RX_RING_SIZE;
+	int count;
 
 	if (limit <= 0)
 		return;
 
 	i = start;
-	for (count = limit; count; count--) {
+	for (count = 0; count < limit; count++) {
 		struct pasemi_mac_buffer *info = &RX_DESC_INFO(mac, i);
 		u64 *buff = &RX_BUFF(mac, i);
 		struct sk_buff *skb;
@@ -417,10 +412,10 @@ static void pasemi_mac_replenish_rx_ring(struct net_device *dev)
 
 	wmb();
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), limit - count);
-	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), limit - count);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count);
+	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
-	mac->rx->next_to_fill += limit - count;
+	mac->rx->next_to_fill += count;
 }
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
@@ -538,7 +533,7 @@ static int pasemi_mac_clean_rx(struct pasemi_mac *mac, int limit)
 	}
 
 	mac->rx->next_to_clean += limit - count;
-	pasemi_mac_replenish_rx_ring(mac->netdev);
+	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
 
 	spin_unlock(&mac->rx->lock);
 
@@ -552,7 +547,7 @@ static int pasemi_mac_clean_tx(struct pasemi_mac *mac)
 	struct pas_dma_xct_descr *dp;
 	unsigned int start, count, limit;
 	unsigned int total_count;
-	int flags;
+	unsigned long flags;
 	struct sk_buff *skbs[32];
 	dma_addr_t dmas[32];
 
@@ -786,11 +781,6 @@ static int pasemi_mac_open(struct net_device *dev)
 
 	write_mac_reg(mac, PAS_MAC_CFG_TXP, flags);
 
-	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
-		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
-
-	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
-
 	write_iob_reg(mac, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
 			   PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
 
@@ -805,8 +795,6 @@ static int pasemi_mac_open(struct net_device *dev)
 	write_iob_reg(mac, PAS_IOB_DMA_COM_TIMEOUTCFG,
 			   PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
-	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
-
 	ret = pasemi_mac_setup_rx_resources(dev);
 	if (ret)
 		goto out_rx_resources;
@@ -832,7 +820,18 @@ static int pasemi_mac_open(struct net_device *dev)
 	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
 			   PAS_DMA_TXCHAN_TCMDSTA_EN);
 
-	pasemi_mac_replenish_rx_ring(dev);
+	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
+
+	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
+		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
+
+	if (mac->type == MAC_TYPE_GMAC)
+		flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
+	else
+		flags |= PAS_MAC_CFG_PCFG_TSR_10G | PAS_MAC_CFG_PCFG_SPD_10G;
+
+	/* Enable interface in MAC */
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
 
 	ret = pasemi_mac_phy_init(dev);
 	/* Some configs don't have PHYs (XAUI etc), so don't complain about
@@ -970,7 +969,7 @@ static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device *dev)
 	struct pas_dma_xct_descr *dp;
 	u64 dflags, mactx, ptr;
 	dma_addr_t map;
-	int flags;
+	unsigned long flags;
 
 	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
 
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index dd09011..432c210 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -76,4 +76,18 @@ config FIXED_MII_100_FDX
 	bool "Emulation for 100M Fdx fixed PHY behavior"
 	depends on FIXED_PHY
 
+config FIXED_MII_1000_FDX
+	bool "Emulation for 1000M Fdx fixed PHY behavior"
+	depends on FIXED_PHY
+
+config FIXED_MII_AMNT
+        int "Number of emulated PHYs to allocate "
+        depends on FIXED_PHY
+        default "1"
+        ---help---
+        Sometimes it is required to have several independent emulated
+        PHYs on the bus (in case of multi-eth but phy-less HW for instance).
+        This control will have specified number allocated for each fixed
+        PHY type enabled.
+
 endif # PHYLIB
diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index bb96691..5619182 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -30,53 +30,31 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
-#define MII_REGS_NUM	7
-
-/*
-    The idea is to emulate normal phy behavior by responding with
-    pre-defined values to mii BMCR read, so that read_status hook could
-    take all the needed info.
-*/
-
-struct fixed_phy_status {
-	u8 	link;
-	u16	speed;
-	u8 	duplex;
-};
-
-/*-----------------------------------------------------------------------------
- *  Private information hoder for mii_bus
- *-----------------------------------------------------------------------------*/
-struct fixed_info {
-	u16 *regs;
-	u8 regs_num;
-	struct fixed_phy_status phy_status;
-	struct phy_device *phydev; /* pointer to the container */
-	/* link & speed cb */
-	int(*link_update)(struct net_device*, struct fixed_phy_status*);
-
-};
+/* we need to track the allocated pointers in order to free them on exit */
+static struct fixed_info *fixed_phy_ptrs[CONFIG_FIXED_MII_AMNT*MAX_PHY_AMNT];
 
 /*-----------------------------------------------------------------------------
  *  If something weird is required to be done with link/speed,
  * network driver is able to assign a function to implement this.
  * May be useful for PHY's that need to be software-driven.
  *-----------------------------------------------------------------------------*/
-int fixed_mdio_set_link_update(struct phy_device* phydev,
-		int(*link_update)(struct net_device*, struct fixed_phy_status*))
+int fixed_mdio_set_link_update(struct phy_device *phydev,
+			       int (*link_update) (struct net_device *,
+						   struct fixed_phy_status *))
 {
 	struct fixed_info *fixed;
 
-	if(link_update == NULL)
+	if (link_update == NULL)
 		return -EINVAL;
 
-	if(phydev) {
-		if(phydev->bus)	{
+	if (phydev) {
+		if (phydev->bus) {
 			fixed = phydev->bus->priv;
 			fixed->link_update = link_update;
 			return 0;
@@ -84,54 +62,64 @@ int fixed_mdio_set_link_update(struct phy_device* phydev,
 	}
 	return -EINVAL;
 }
+
 EXPORT_SYMBOL(fixed_mdio_set_link_update);
 
+struct fixed_info *fixed_mdio_get_phydev (int phydev_ind)
+{
+	if (phydev_ind >= MAX_PHY_AMNT)
+		return NULL;
+	return fixed_phy_ptrs[phydev_ind];
+}
+
+EXPORT_SYMBOL(fixed_mdio_get_phydev);
+
 /*-----------------------------------------------------------------------------
  *  This is used for updating internal mii regs from the status
  *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
 static int fixed_mdio_update_regs(struct fixed_info *fixed)
 {
 	u16 *regs = fixed->regs;
 	u16 bmsr = 0;
 	u16 bmcr = 0;
 
-	if(!regs) {
+	if (!regs) {
 		printk(KERN_ERR "%s: regs not set up", __FUNCTION__);
 		return -EINVAL;
 	}
 
-	if(fixed->phy_status.link)
+	if (fixed->phy_status.link)
 		bmsr |= BMSR_LSTATUS;
 
-	if(fixed->phy_status.duplex) {
+	if (fixed->phy_status.duplex) {
 		bmcr |= BMCR_FULLDPLX;
 
-		switch ( fixed->phy_status.speed ) {
+		switch (fixed->phy_status.speed) {
 		case 100:
 			bmsr |= BMSR_100FULL;
 			bmcr |= BMCR_SPEED100;
-		break;
+			break;
 
 		case 10:
 			bmsr |= BMSR_10FULL;
-		break;
+			break;
 		}
 	} else {
-		switch ( fixed->phy_status.speed ) {
+		switch (fixed->phy_status.speed) {
 		case 100:
 			bmsr |= BMSR_100HALF;
 			bmcr |= BMCR_SPEED100;
-		break;
+			break;
 
 		case 10:
 			bmsr |= BMSR_100HALF;
-		break;
+			break;
 		}
 	}
 
-	regs[MII_BMCR] =  bmcr;
-	regs[MII_BMSR] =  bmsr | 0x800; /*we are always capable of 10 hdx*/
+	regs[MII_BMCR] = bmcr;
+	regs[MII_BMSR] = bmsr | 0x800;	/*we are always capable of 10 hdx */
 
 	return 0;
 }
@@ -141,29 +129,30 @@ static int fixed_mii_read(struct mii_bus *bus, int phy_id, int location)
 	struct fixed_info *fixed = bus->priv;
 
 	/* if user has registered link update callback, use it */
-	if(fixed->phydev)
-		if(fixed->phydev->attached_dev) {
-			if(fixed->link_update) {
+	if (fixed->phydev)
+		if (fixed->phydev->attached_dev) {
+			if (fixed->link_update) {
 				fixed->link_update(fixed->phydev->attached_dev,
-						&fixed->phy_status);
+						   &fixed->phy_status);
 				fixed_mdio_update_regs(fixed);
 			}
-	}
+		}
 
 	if ((unsigned int)location >= fixed->regs_num)
 		return -1;
 	return fixed->regs[location];
 }
 
-static int fixed_mii_write(struct mii_bus *bus, int phy_id, int location, u16 val)
+static int fixed_mii_write(struct mii_bus *bus, int phy_id, int location,
+			   u16 val)
 {
-	/* do nothing for now*/
+	/* do nothing for now */
 	return 0;
 }
 
 static int fixed_mii_reset(struct mii_bus *bus)
 {
-	/*nothing here - no way/need to reset it*/
+	/*nothing here - no way/need to reset it */
 	return 0;
 }
 #endif
@@ -171,8 +160,8 @@ static int fixed_mii_reset(struct mii_bus *bus)
 static int fixed_config_aneg(struct phy_device *phydev)
 {
 	/* :TODO:03/13/2006 09:45:37 PM::
-	 The full autoneg funcionality can be emulated,
-	 but no need to have anything here for now
+	   The full autoneg funcionality can be emulated,
+	   but no need to have anything here for now
 	 */
 	return 0;
 }
@@ -182,59 +171,79 @@ static int fixed_config_aneg(struct phy_device *phydev)
  * match will never return true...
  *-----------------------------------------------------------------------------*/
 static struct phy_driver fixed_mdio_driver = {
-	.name		= "Fixed PHY",
-	.features	= PHY_BASIC_FEATURES,
-	.config_aneg	= fixed_config_aneg,
-	.read_status	= genphy_read_status,
-	.driver 	= { .owner = THIS_MODULE,},
+	.name = "Fixed PHY",
+#ifdef CONFIG_FIXED_MII_1000_FDX
+	.features = PHY_GBIT_FEATURES,
+#else
+	.features = PHY_BASIC_FEATURES,
+#endif
+	.config_aneg = fixed_config_aneg,
+	.read_status = genphy_read_status,
+	.driver = { .owner = THIS_MODULE, },
 };
 
+static void fixed_mdio_release(struct device *dev)
+{
+	struct phy_device *phydev = container_of(dev, struct phy_device, dev);
+	struct mii_bus *bus = phydev->bus;
+	struct fixed_info *fixed = bus->priv;
+
+	kfree(phydev);
+	kfree(bus->dev);
+	kfree(bus);
+	kfree(fixed->regs);
+	kfree(fixed);
+}
+
 /*-----------------------------------------------------------------------------
  *  This func is used to create all the necessary stuff, bind
  * the fixed phy driver and register all it on the mdio_bus_type.
- * speed is either 10 or 100, duplex is boolean.
+ * speed is either 10 or 100 or 1000, duplex is boolean.
  * number is used to create multiple fixed PHYs, so that several devices can
  * utilize them simultaneously.
+ *
+ * The device on mdio bus will look like [bus_id]:[phy_id],
+ * bus_id = number
+ * phy_id = speed+duplex.
  *-----------------------------------------------------------------------------*/
-#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX)
-static int fixed_mdio_register_device(int number, int speed, int duplex)
+#if defined(CONFIG_FIXED_MII_100_FDX) || defined(CONFIG_FIXED_MII_10_FDX) || defined(CONFIG_FIXED_MII_1000_FDX)
+struct fixed_info *fixed_mdio_register_device(
+	int bus_id, int speed, int duplex, u8 phy_id)
 {
 	struct mii_bus *new_bus;
 	struct fixed_info *fixed;
 	struct phy_device *phydev;
-	int err = 0;
+	int err;
 
-	struct device* dev = kzalloc(sizeof(struct device), GFP_KERNEL);
+	struct device *dev = kzalloc(sizeof(struct device), GFP_KERNEL);
 
-	if (NULL == dev)
-		return -ENOMEM;
+	if (dev == NULL)
+		goto err_dev_alloc;
 
 	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
 
-	if (NULL == new_bus) {
-		kfree(dev);
-		return -ENOMEM;
-	}
+	if (new_bus == NULL)
+		goto err_bus_alloc;
+
 	fixed = kzalloc(sizeof(struct fixed_info), GFP_KERNEL);
 
-	if (NULL == fixed) {
-		kfree(dev);
-		kfree(new_bus);
-		return -ENOMEM;
-	}
+	if (fixed == NULL)
+		goto err_fixed_alloc;
+
+	fixed->regs = kzalloc(MII_REGS_NUM * sizeof(int), GFP_KERNEL);
+	if (NULL == fixed->regs)
+		goto err_fixed_regs_alloc;
 
-	fixed->regs = kzalloc(MII_REGS_NUM*sizeof(int), GFP_KERNEL);
 	fixed->regs_num = MII_REGS_NUM;
 	fixed->phy_status.speed = speed;
 	fixed->phy_status.duplex = duplex;
 	fixed->phy_status.link = 1;
 
-	new_bus->name = "Fixed MII Bus",
-	new_bus->read = &fixed_mii_read,
-	new_bus->write = &fixed_mii_write,
-	new_bus->reset = &fixed_mii_reset,
-
-	/*set up workspace*/
+	new_bus->name = "Fixed MII Bus";
+	new_bus->read = &fixed_mii_read;
+	new_bus->write = &fixed_mii_write;
+	new_bus->reset = &fixed_mii_reset;
+	/*set up workspace */
 	fixed_mdio_update_regs(fixed);
 	new_bus->priv = fixed;
 
@@ -243,119 +252,110 @@ static int fixed_mdio_register_device(int number, int speed, int duplex)
 
 	/* create phy_device and register it on the mdio bus */
 	phydev = phy_device_create(new_bus, 0, 0);
+	if (phydev == NULL)
+		goto err_phy_dev_create;
 
 	/*
-	 Put the phydev pointer into the fixed pack so that bus read/write code could
-	 be able to access for instance attached netdev. Well it doesn't have to do
-	 so, only in case of utilizing user-specified link-update...
+	 * Put the phydev pointer into the fixed pack so that bus read/write
+	 * code could be able to access for instance attached netdev. Well it
+	 * doesn't have to do so, only in case of utilizing user-specified
+	 * link-update...
 	 */
-	fixed->phydev = phydev;
 
-	if(NULL == phydev) {
-		err = -ENOMEM;
-		goto device_create_fail;
-	}
+	fixed->phydev = phydev;
+	phydev->speed = speed;
+	phydev->duplex = duplex;
 
 	phydev->irq = PHY_IGNORE_INTERRUPT;
 	phydev->dev.bus = &mdio_bus_type;
 
-	if(number)
-		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
-				"fixed_%d@%d:%d", number, speed, duplex);
-	else
-		snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
-				"fixed@%d:%d", speed, duplex);
-	phydev->bus = new_bus;
+	snprintf(phydev->dev.bus_id, BUS_ID_SIZE,
+		 PHY_ID_FMT, bus_id, phy_id);
 
-	err = device_register(&phydev->dev);
-	if(err) {
-		printk(KERN_ERR "Phy %s failed to register\n",
-				phydev->dev.bus_id);
-		goto bus_register_fail;
-	}
+	phydev->bus = new_bus;
 
-	/*
-	   the mdio bus has phy_id match... In order not to do it
-	   artificially, we are binding the driver here by hand;
-	   it will be the same for all the fixed phys anyway.
-	 */
 	phydev->dev.driver = &fixed_mdio_driver.driver;
-
+	phydev->dev.release = fixed_mdio_release;
 	err = phydev->dev.driver->probe(&phydev->dev);
-	if(err < 0) {
-		printk(KERN_ERR "Phy %s: problems with fixed driver\n",phydev->dev.bus_id);
-		goto probe_fail;
+	if (err < 0) {
+		printk(KERN_ERR "Phy %s: problems with fixed driver\n",
+		       phydev->dev.bus_id);
+		goto err_out;
 	}
+	err = device_register(&phydev->dev);
+	if (err) {
+		printk(KERN_ERR "Phy %s failed to register\n",
+		       phydev->dev.bus_id);
+		goto err_out;
+	}
+	//phydev->state = PHY_RUNNING; /* make phy go up quick, but in 10Mbit/HDX
+	return fixed;
 
-	err = device_bind_driver(&phydev->dev);
-	if (err)
-		goto probe_fail;
-
-	return 0;
-
-probe_fail:
-	device_unregister(&phydev->dev);
-bus_register_fail:
+err_out:
 	kfree(phydev);
-device_create_fail:
-	kfree(dev);
-	kfree(new_bus);
+err_phy_dev_create:
+	kfree(fixed->regs);
+err_fixed_regs_alloc:
 	kfree(fixed);
+err_fixed_alloc:
+	kfree(new_bus);
+err_bus_alloc:
+	kfree(dev);
+err_dev_alloc:
+
+	return NULL;
 
-	return err;
 }
 #endif
 
-
 MODULE_DESCRIPTION("Fixed PHY device & driver for PAL");
 MODULE_AUTHOR("Vitaly Bordug");
 MODULE_LICENSE("GPL");
 
 static int __init fixed_init(void)
 {
-#if 0
-	int ret;
-	int duplex = 0;
-#endif
-
-	/* register on the bus... Not expected to be matched with anything there... */
+	int cnt = 0;
+	int i;
+/* register on the bus... Not expected to be matched
+ * with anything there...
+ *
+ */
 	phy_driver_register(&fixed_mdio_driver);
 
-	/* So let the fun begin...
-	   We will create several mdio devices here, and will bound the upper
-	   driver to them.
-
-	   Then the external software can lookup the phy bus by searching
-	   fixed@speed:duplex, e.g. fixed@100:1, to be connected to the
-	   virtual 100M Fdx phy.
-
-	   In case several virtual PHYs required, the bus_id will be in form
-	   fixed_<num>@<speed>:<duplex>, which make it able even to define
-	   driver-specific link control callback, if for instance PHY is completely
-	   SW-driven.
-
-	*/
-
-#ifdef CONFIG_FIXED_MII_DUPLEX
-#if 0
-	duplex = 1;
-#endif
+/* We will create several mdio devices here, and will bound the upper
+ * driver to them.
+ *
+ * Then the external software can lookup the phy bus by searching
+ * for 0:101, to be connected to the virtual 100M Fdx phy.
+ *
+ * In case several virtual PHYs required, the bus_id will be in form
+ * [num]:[duplex]+[speed], which make it able even to define
+ * driver-specific link control callback, if for instance PHY is
+ * completely SW-driven.
+ */
+	for (i=1; i <= CONFIG_FIXED_MII_AMNT; i++) {
+#ifdef CONFIG_FIXED_MII_1000_FDX
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(0, 1000, 1, i);
 #endif
-
 #ifdef CONFIG_FIXED_MII_100_FDX
-	fixed_mdio_register_device(0, 100, 1);
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(1, 100, 1, i);
 #endif
-
 #ifdef CONFIG_FIXED_MII_10_FDX
-	fixed_mdio_register_device(0, 10, 1);
+		fixed_phy_ptrs[cnt++] = fixed_mdio_register_device(2, 10, 1, i);
 #endif
+	}
+
 	return 0;
 }
 
 static void __exit fixed_exit(void)
 {
+	int i;
+
 	phy_driver_unregister(&fixed_mdio_driver);
-	/* :WARNING:02/18/2006 04:32:40 AM:: Cleanup all the created stuff */
+	for (i=0; i < MAX_PHY_AMNT; i++)
+		if ( fixed_phy_ptrs[i] )
+			device_unregister(&fixed_phy_ptrs[i]->phydev->dev);
 }
 
 module_init(fixed_init);
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 17c1e15..9bc1177 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -7,7 +7,7 @@
  * Author: Andy Fleming
  *
  * Copyright (c) 2004 Freescale Semiconductor, Inc.
- * Copyright (c) 2006  Maciej W. Rozycki
+ * Copyright (c) 2006, 2007  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
@@ -35,6 +35,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
+#include <asm/atomic.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
@@ -424,7 +425,7 @@ int phy_start_aneg(struct phy_device *phydev)
 {
 	int err;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (AUTONEG_DISABLE == phydev->autoneg)
 		phy_sanitize_settings(phydev);
@@ -445,7 +446,7 @@ int phy_start_aneg(struct phy_device *phydev)
 	}
 
 out_unlock:
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 	return err;
 }
 EXPORT_SYMBOL(phy_start_aneg);
@@ -490,10 +491,10 @@ void phy_stop_machine(struct phy_device *phydev)
 {
 	del_timer_sync(&phydev->phy_timer);
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	if (phydev->state > PHY_UP)
 		phydev->state = PHY_UP;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	phydev->adjust_state = NULL;
 }
@@ -537,9 +538,9 @@ static void phy_force_reduction(struct phy_device *phydev)
  */
 void phy_error(struct phy_device *phydev)
 {
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	phydev->state = PHY_HALTED;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 }
 
 /**
@@ -562,6 +563,7 @@ static irqreturn_t phy_interrupt(int irq, void *phy_dat)
 	 * queue will write the PHY to disable and clear the
 	 * interrupt, and then reenable the irq line. */
 	disable_irq_nosync(irq);
+	atomic_inc(&phydev->irq_disable);
 
 	schedule_work(&phydev->phy_queue);
 
@@ -632,6 +634,7 @@ int phy_start_interrupts(struct phy_device *phydev)
 
 	INIT_WORK(&phydev->phy_queue, phy_change);
 
+	atomic_set(&phydev->irq_disable, 0);
 	if (request_irq(phydev->irq, phy_interrupt,
 				IRQF_SHARED,
 				"phy_interrupt",
@@ -662,13 +665,22 @@ int phy_stop_interrupts(struct phy_device *phydev)
 	if (err)
 		phy_error(phydev);
 
+	free_irq(phydev->irq, phydev);
+
 	/*
-	 * Finish any pending work; we might have been scheduled to be called
-	 * from keventd ourselves, but cancel_work_sync() handles that.
+	 * Cannot call flush_scheduled_work() here as desired because
+	 * of rtnl_lock(), but we do not really care about what would
+	 * be done, except from enable_irq(), so cancel any work
+	 * possibly pending and take care of the matter below.
 	 */
 	cancel_work_sync(&phydev->phy_queue);
-
-	free_irq(phydev->irq, phydev);
+	/*
+	 * If work indeed has been cancelled, disable_irq() will have
+	 * been left unbalanced from phy_interrupt() and enable_irq()
+	 * has to be called so that other devices on the line work.
+	 */
+	while (atomic_dec_return(&phydev->irq_disable) >= 0)
+		enable_irq(phydev->irq);
 
 	return err;
 }
@@ -690,11 +702,12 @@ static void phy_change(struct work_struct *work)
 	if (err)
 		goto phy_err;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
 		phydev->state = PHY_CHANGELINK;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
+	atomic_dec(&phydev->irq_disable);
 	enable_irq(phydev->irq);
 
 	/* Reenable interrupts */
@@ -708,6 +721,7 @@ static void phy_change(struct work_struct *work)
 
 irq_enable_err:
 	disable_irq(phydev->irq);
+	atomic_inc(&phydev->irq_disable);
 phy_err:
 	phy_error(phydev);
 }
@@ -718,13 +732,11 @@ phy_err:
  */
 void phy_stop(struct phy_device *phydev)
 {
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
 
-	phydev->state = PHY_HALTED;
-
 	if (phydev->irq != PHY_POLL) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
@@ -733,8 +745,10 @@ void phy_stop(struct phy_device *phydev)
 		phy_clear_interrupt(phydev);
 	}
 
+	phydev->state = PHY_HALTED;
+
 out_unlock:
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	/*
 	 * Cannot call flush_scheduled_work() here as desired because
@@ -782,7 +796,7 @@ static void phy_timer(unsigned long data)
 	int needs_aneg = 0;
 	int err = 0;
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 
 	if (phydev->adjust_state)
 		phydev->adjust_state(phydev->attached_dev);
@@ -948,7 +962,7 @@ static void phy_timer(unsigned long data)
 			break;
 	}
 
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	if (needs_aneg)
 		err = phy_start_aneg(phydev);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 49328e0..c046121 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -670,9 +670,9 @@ static int phy_remove(struct device *dev)
 
 	phydev = to_phy_device(dev);
 
-	spin_lock(&phydev->lock);
+	spin_lock_bh(&phydev->lock);
 	phydev->state = PHY_DOWN;
-	spin_unlock(&phydev->lock);
+	spin_unlock_bh(&phydev->lock);
 
 	if (phydev->drv->remove)
 		phydev->drv->remove(phydev);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 6001ab4..7b53d65 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -1,5 +1,6 @@
 /*
  * Copyright (C) 2001,2002,2003,2004 Broadcom Corporation
+ * Copyright (c) 2006, 2007  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -18,7 +19,12 @@
  *
  * This driver is designed for the Broadcom SiByte SOC built-in
  * Ethernet controllers. Written by Mitch Lichtenberg at Broadcom Corp.
+ *
+ * Updated to the driver model and the PHY abstraction layer
+ * by Maciej W. Rozycki.
  */
+
+#include <linux/bug.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -32,9 +38,15 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
-#include <asm/processor.h>		/* Processor type for cache alignment. */
-#include <asm/io.h>
+#include <linux/err.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+
 #include <asm/cache.h>
+#include <asm/io.h>
+#include <asm/processor.h>	/* Processor type for cache alignment. */
 
 /* This is only here until the firmware is ready.  In that case,
    the firmware leaves the ethernet address in the register for us. */
@@ -48,7 +60,7 @@
 
 /* These identify the driver base version and may not be removed. */
 #if 0
-static char version1[] __devinitdata =
+static char version1[] __initdata =
 "sb1250-mac.c:1.00 1/11/2001 Written by Mitch Lichtenberg\n";
 #endif
 
@@ -57,8 +69,6 @@ static char version1[] __devinitdata =
 
 #define CONFIG_SBMAC_COALESCE
 
-#define MAX_UNITS 4		/* More are supported, limit only on options */
-
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (2*HZ)
 
@@ -74,26 +84,6 @@ static int debug = 1;
 module_param(debug, int, S_IRUGO);
 MODULE_PARM_DESC(debug, "Debug messages");
 
-/* mii status msgs */
-static int noisy_mii = 1;
-module_param(noisy_mii, int, S_IRUGO);
-MODULE_PARM_DESC(noisy_mii, "MII status messages");
-
-/* Used to pass the media type, etc.
-   Both 'options[]' and 'full_duplex[]' should exist for driver
-   interoperability.
-   The media type is usually passed in 'options[]'.
-*/
-#ifdef MODULE
-static int options[MAX_UNITS] = {-1, -1, -1, -1};
-module_param_array(options, int, NULL, S_IRUGO);
-MODULE_PARM_DESC(options, "1-" __MODULE_STRING(MAX_UNITS));
-
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1};
-module_param_array(full_duplex, int, NULL, S_IRUGO);
-MODULE_PARM_DESC(full_duplex, "1-" __MODULE_STRING(MAX_UNITS));
-#endif
-
 #ifdef CONFIG_SBMAC_COALESCE
 static int int_pktcnt_tx = 255;
 module_param(int_pktcnt_tx, int, S_IRUGO);
@@ -112,6 +102,7 @@ module_param(int_timeout_rx, int, S_IRUGO);
 MODULE_PARM_DESC(int_timeout_rx, "RX timeout value");
 #endif
 
+#include <asm/sibyte/board.h>
 #include <asm/sibyte/sb1250.h>
 #if defined(CONFIG_SIBYTE_BCM1x55) || defined(CONFIG_SIBYTE_BCM1x80)
 #include <asm/sibyte/bcm1480_regs.h>
@@ -135,22 +126,43 @@ MODULE_PARM_DESC(int_timeout_rx, "RX timeout value");
 #error invalid SiByte MAC configuation
 #endif
 
+#ifdef K_INT_PHY
+#define SBMAC_PHY_INT			K_INT_PHY
+#else
+#define SBMAC_PHY_INT			PHY_POLL
+#endif
+
 /**********************************************************************
  *  Simple types
  ********************************************************************* */
 
+enum sbmac_speed {
+	sbmac_speed_none = 0,
+	sbmac_speed_10 = SPEED_10,
+	sbmac_speed_100 = SPEED_100,
+	sbmac_speed_1000 = SPEED_1000,
+};
 
-typedef enum { sbmac_speed_auto, sbmac_speed_10,
-	       sbmac_speed_100, sbmac_speed_1000 } sbmac_speed_t;
-
-typedef enum { sbmac_duplex_auto, sbmac_duplex_half,
-	       sbmac_duplex_full } sbmac_duplex_t;
+enum sbmac_duplex {
+	sbmac_duplex_none = -1,
+	sbmac_duplex_half = DUPLEX_HALF,
+	sbmac_duplex_full = DUPLEX_FULL,
+};
 
-typedef enum { sbmac_fc_auto, sbmac_fc_disabled, sbmac_fc_frame,
-	       sbmac_fc_collision, sbmac_fc_carrier } sbmac_fc_t;
+enum sbmac_fc {
+	sbmac_fc_none,
+	sbmac_fc_disabled,
+	sbmac_fc_frame,
+	sbmac_fc_collision,
+	sbmac_fc_carrier,
+};
 
-typedef enum { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
-	       sbmac_state_broken } sbmac_state_t;
+enum sbmac_state {
+	sbmac_state_uninit,
+	sbmac_state_off,
+	sbmac_state_on,
+	sbmac_state_broken,
+};
 
 
 /**********************************************************************
@@ -176,55 +188,61 @@ typedef enum { sbmac_state_uninit, sbmac_state_off, sbmac_state_on,
  *  DMA Descriptor structure
  ********************************************************************* */
 
-typedef struct sbdmadscr_s {
+struct sbdmadscr {
 	uint64_t  dscr_a;
 	uint64_t  dscr_b;
-} sbdmadscr_t;
-
-typedef unsigned long paddr_t;
+};
 
 /**********************************************************************
  *  DMA Controller structure
  ********************************************************************* */
 
-typedef struct sbmacdma_s {
+struct sbmacdma {
 
 	/*
 	 * This stuff is used to identify the channel and the registers
 	 * associated with it.
 	 */
-
-	struct sbmac_softc *sbdma_eth;	    /* back pointer to associated MAC */
-	int              sbdma_channel;	    /* channel number */
-	int		 sbdma_txdir;       /* direction (1=transmit) */
-	int		 sbdma_maxdescr;    /* total # of descriptors in ring */
+	struct sbmac_softc	*sbdma_eth;	/* back pointer to associated
+						   MAC */
+	int			sbdma_channel;	/* channel number */
+	int			sbdma_txdir;	/* direction (1=transmit) */
+	int			sbdma_maxdescr;	/* total # of descriptors
+						   in ring */
 #ifdef CONFIG_SBMAC_COALESCE
-	int		 sbdma_int_pktcnt;  /* # descriptors rx/tx before interrupt*/
-	int		 sbdma_int_timeout; /* # usec rx/tx interrupt */
+	int			sbdma_int_pktcnt;
+						/* # descriptors rx/tx
+						   before interrupt */
+	int			sbdma_int_timeout;
+						/* # usec rx/tx interrupt */
 #endif
-
-	volatile void __iomem *sbdma_config0;	/* DMA config register 0 */
-	volatile void __iomem *sbdma_config1;	/* DMA config register 1 */
-	volatile void __iomem *sbdma_dscrbase;	/* Descriptor base address */
-	volatile void __iomem *sbdma_dscrcnt;   /* Descriptor count register */
-	volatile void __iomem *sbdma_curdscr;	/* current descriptor address */
-	volatile void __iomem *sbdma_oodpktlost;/* pkt drop (rx only) */
-
+	void __iomem		*sbdma_config0;	/* DMA config register 0 */
+	void __iomem		*sbdma_config1;	/* DMA config register 1 */
+	void __iomem		*sbdma_dscrbase;
+						/* descriptor base address */
+	void __iomem		*sbdma_dscrcnt;	/* descriptor count register */
+	void __iomem		*sbdma_curdscr;	/* current descriptor
+						   address */
+	void __iomem		*sbdma_oodpktlost;
+						/* pkt drop (rx only) */
 
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
-
-	sbdmadscr_t     *sbdma_dscrtable_unaligned;
-	sbdmadscr_t     *sbdma_dscrtable;	/* base of descriptor table */
-	sbdmadscr_t     *sbdma_dscrtable_end; /* end of descriptor table */
-
-	struct sk_buff **sbdma_ctxtable;    /* context table, one per descr */
-
-	paddr_t          sbdma_dscrtable_phys; /* and also the phys addr */
-	sbdmadscr_t     *sbdma_addptr;	/* next dscr for sw to add */
-	sbdmadscr_t     *sbdma_remptr;	/* next dscr for sw to remove */
-} sbmacdma_t;
+	void			*sbdma_dscrtable_unaligned;
+	struct sbdmadscr	*sbdma_dscrtable;
+						/* base of descriptor table */
+	struct sbdmadscr	*sbdma_dscrtable_end;
+						/* end of descriptor table */
+	struct sk_buff		**sbdma_ctxtable;
+						/* context table, one
+						   per descr */
+	dma_addr_t		sbdma_dscrtable_phys;
+						/* and also the phys addr */
+	struct sbdmadscr	*sbdma_addptr;	/* next dscr for sw to add */
+	struct sbdmadscr	*sbdma_remptr;	/* next dscr for sw
+						   to remove */
+};
 
 
 /**********************************************************************
@@ -236,47 +254,43 @@ struct sbmac_softc {
 	/*
 	 * Linux-specific things
 	 */
+	struct net_device	*sbm_dev;	/* pointer to linux device */
+	struct napi_struct	napi;
+	struct phy_device	*phy_dev;	/* the associated PHY device */
+	struct mii_bus		mii_bus;	/* the MII bus */
+	int			phy_irq[PHY_MAX_ADDR];
+	spinlock_t		sbm_lock;	/* spin lock */
+	int			sbm_devflags;	/* current device flags */
 
-	struct net_device *sbm_dev;		/* pointer to linux device */
-	struct napi_struct napi;
-	spinlock_t sbm_lock;		/* spin lock */
-	struct timer_list sbm_timer;     	/* for monitoring MII */
-	int sbm_devflags;			/* current device flags */
-
-	int	     sbm_phy_oldbmsr;
-	int	     sbm_phy_oldanlpar;
-	int	     sbm_phy_oldk1stsr;
-	int	     sbm_phy_oldlinkstat;
-	int sbm_buffersize;
-
-	unsigned char sbm_phys[2];
+	int			sbm_buffersize;
 
 	/*
 	 * Controller-specific things
 	 */
-
-	void __iomem		*sbm_base;          /* MAC's base address */
-	sbmac_state_t    sbm_state;         /* current state */
-
-	volatile void __iomem	*sbm_macenable;	/* MAC Enable Register */
-	volatile void __iomem	*sbm_maccfg;	/* MAC Configuration Register */
-	volatile void __iomem	*sbm_fifocfg;	/* FIFO configuration register */
-	volatile void __iomem	*sbm_framecfg;	/* Frame configuration register */
-	volatile void __iomem	*sbm_rxfilter;	/* receive filter register */
-	volatile void __iomem	*sbm_isr;	/* Interrupt status register */
-	volatile void __iomem	*sbm_imr;	/* Interrupt mask register */
-	volatile void __iomem	*sbm_mdio;	/* MDIO register */
-
-	sbmac_speed_t    sbm_speed;		/* current speed */
-	sbmac_duplex_t   sbm_duplex;	/* current duplex */
-	sbmac_fc_t       sbm_fc;		/* current flow control setting */
-
-	unsigned char    sbm_hwaddr[ETHER_ADDR_LEN];
-
-	sbmacdma_t       sbm_txdma;		/* for now, only use channel 0 */
-	sbmacdma_t       sbm_rxdma;
-	int              rx_hw_checksum;
-	int 		 sbe_idx;
+	void __iomem		*sbm_base;	/* MAC's base address */
+	enum sbmac_state	sbm_state;	/* current state */
+
+	void __iomem		*sbm_macenable;	/* MAC Enable Register */
+	void __iomem		*sbm_maccfg;	/* MAC Config Register */
+	void __iomem		*sbm_fifocfg;	/* FIFO Config Register */
+	void __iomem		*sbm_framecfg;	/* Frame Config Register */
+	void __iomem		*sbm_rxfilter;	/* Receive Filter Register */
+	void __iomem		*sbm_isr;	/* Interrupt Status Register */
+	void __iomem		*sbm_imr;	/* Interrupt Mask Register */
+	void __iomem		*sbm_mdio;	/* MDIO Register */
+
+	enum sbmac_speed	sbm_speed;	/* current speed */
+	enum sbmac_duplex	sbm_duplex;	/* current duplex */
+	enum sbmac_fc		sbm_fc;		/* cur. flow control setting */
+	int			sbm_pause;	/* current pause setting */
+	int			sbm_link;	/* current link state */
+
+	unsigned char		sbm_hwaddr[ETHER_ADDR_LEN];
+
+	struct sbmacdma		sbm_txdma;	/* only channel 0 for now */
+	struct sbmacdma		sbm_rxdma;
+	int			rx_hw_checksum;
+	int			sbe_idx;
 };
 
 
@@ -288,54 +302,58 @@ struct sbmac_softc {
  *  Prototypes
  ********************************************************************* */
 
-static void sbdma_initctx(sbmacdma_t *d,
-			  struct sbmac_softc *s,
-			  int chan,
-			  int txrx,
-			  int maxdescr);
-static void sbdma_channel_start(sbmacdma_t *d, int rxtx);
-static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *m);
-static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *m);
-static void sbdma_emptyring(sbmacdma_t *d);
-static void sbdma_fillring(sbmacdma_t *d);
-static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d, int work_to_do, int poll);
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll);
+static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
+			  int txrx, int maxdescr);
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
+static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
+static void sbdma_emptyring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmacdma *d);
+static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			    int work_to_do, int poll);
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			     int poll);
 static int sbmac_initctx(struct sbmac_softc *s);
 static void sbmac_channel_start(struct sbmac_softc *s);
 static void sbmac_channel_stop(struct sbmac_softc *s);
-static sbmac_state_t sbmac_set_channel_state(struct sbmac_softc *,sbmac_state_t);
-static void sbmac_promiscuous_mode(struct sbmac_softc *sc,int onoff);
+static enum sbmac_state sbmac_set_channel_state(struct sbmac_softc *,
+						enum sbmac_state);
+static void sbmac_promiscuous_mode(struct sbmac_softc *sc, int onoff);
 static uint64_t sbmac_addr2reg(unsigned char *ptr);
-static irqreturn_t sbmac_intr(int irq,void *dev_instance);
+static irqreturn_t sbmac_intr(int irq, void *dev_instance);
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev);
 static void sbmac_setmulti(struct sbmac_softc *sc);
-static int sbmac_init(struct net_device *dev, int idx);
-static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed);
-static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc);
+static int sbmac_init(struct platform_device *pldev, long long base);
+static int sbmac_set_speed(struct sbmac_softc *s, enum sbmac_speed speed);
+static int sbmac_set_duplex(struct sbmac_softc *s, enum sbmac_duplex duplex,
+			    enum sbmac_fc fc);
 
 static int sbmac_open(struct net_device *dev);
-static void sbmac_timer(unsigned long data);
 static void sbmac_tx_timeout (struct net_device *dev);
 static void sbmac_set_rx_mode(struct net_device *dev);
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static int sbmac_close(struct net_device *dev);
 static int sbmac_poll(struct napi_struct *napi, int budget);
 
-static int sbmac_mii_poll(struct sbmac_softc *s,int noisy);
+static void sbmac_mii_poll(struct net_device *dev);
 static int sbmac_mii_probe(struct net_device *dev);
 
-static void sbmac_mii_sync(struct sbmac_softc *s);
-static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitcnt);
-static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx);
-static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
-			    unsigned int regval);
+static void sbmac_mii_sync(void __iomem *sbm_mdio);
+static void sbmac_mii_senddata(void __iomem *sbm_mdio, unsigned int data,
+			       int bitcnt);
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx);
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 val);
 
 
 /**********************************************************************
  *  Globals
  ********************************************************************* */
 
-static uint64_t sbmac_orig_hwaddr[MAX_UNITS];
+static char sbmac_string[] = "sb1250-mac";
+static char sbmac_pretty[] = "SB1250 MAC";
+
+static char sbmac_mdio_string[] = "sb1250-mac-mdio";
 
 
 /**********************************************************************
@@ -347,185 +365,66 @@ static uint64_t sbmac_orig_hwaddr[MAX_UNITS];
 #define	MII_COMMAND_WRITE	0x01
 #define	MII_COMMAND_ACK		0x02
 
-#define BMCR_RESET     0x8000
-#define BMCR_LOOPBACK  0x4000
-#define BMCR_SPEED0    0x2000
-#define BMCR_ANENABLE  0x1000
-#define BMCR_POWERDOWN 0x0800
-#define BMCR_ISOLATE   0x0400
-#define BMCR_RESTARTAN 0x0200
-#define BMCR_DUPLEX    0x0100
-#define BMCR_COLTEST   0x0080
-#define BMCR_SPEED1    0x0040
-#define BMCR_SPEED1000	BMCR_SPEED1
-#define BMCR_SPEED100	BMCR_SPEED0
-#define BMCR_SPEED10 	0
-
-#define BMSR_100BT4	0x8000
-#define BMSR_100BT_FDX	0x4000
-#define BMSR_100BT_HDX  0x2000
-#define BMSR_10BT_FDX   0x1000
-#define BMSR_10BT_HDX   0x0800
-#define BMSR_100BT2_FDX 0x0400
-#define BMSR_100BT2_HDX 0x0200
-#define BMSR_1000BT_XSR	0x0100
-#define BMSR_PRESUP	0x0040
-#define BMSR_ANCOMPLT	0x0020
-#define BMSR_REMFAULT	0x0010
-#define BMSR_AUTONEG	0x0008
-#define BMSR_LINKSTAT	0x0004
-#define BMSR_JABDETECT	0x0002
-#define BMSR_EXTCAPAB	0x0001
-
-#define PHYIDR1 	0x2000
-#define PHYIDR2		0x5C60
-
-#define ANAR_NP		0x8000
-#define ANAR_RF		0x2000
-#define ANAR_ASYPAUSE	0x0800
-#define ANAR_PAUSE	0x0400
-#define ANAR_T4		0x0200
-#define ANAR_TXFD	0x0100
-#define ANAR_TXHD	0x0080
-#define ANAR_10FD	0x0040
-#define ANAR_10HD	0x0020
-#define ANAR_PSB	0x0001
-
-#define ANLPAR_NP	0x8000
-#define ANLPAR_ACK	0x4000
-#define ANLPAR_RF	0x2000
-#define ANLPAR_ASYPAUSE	0x0800
-#define ANLPAR_PAUSE	0x0400
-#define ANLPAR_T4	0x0200
-#define ANLPAR_TXFD	0x0100
-#define ANLPAR_TXHD	0x0080
-#define ANLPAR_10FD	0x0040
-#define ANLPAR_10HD	0x0020
-#define ANLPAR_PSB	0x0001	/* 802.3 */
-
-#define ANER_PDF	0x0010
-#define ANER_LPNPABLE	0x0008
-#define ANER_NPABLE	0x0004
-#define ANER_PAGERX	0x0002
-#define ANER_LPANABLE	0x0001
-
-#define ANNPTR_NP	0x8000
-#define ANNPTR_MP	0x2000
-#define ANNPTR_ACK2	0x1000
-#define ANNPTR_TOGTX	0x0800
-#define ANNPTR_CODE	0x0008
-
-#define ANNPRR_NP	0x8000
-#define ANNPRR_MP	0x2000
-#define ANNPRR_ACK3	0x1000
-#define ANNPRR_TOGTX	0x0800
-#define ANNPRR_CODE	0x0008
-
-#define K1TCR_TESTMODE	0x0000
-#define K1TCR_MSMCE	0x1000
-#define K1TCR_MSCV	0x0800
-#define K1TCR_RPTR	0x0400
-#define K1TCR_1000BT_FDX 0x200
-#define K1TCR_1000BT_HDX 0x100
-
-#define K1STSR_MSMCFLT	0x8000
-#define K1STSR_MSCFGRES	0x4000
-#define K1STSR_LRSTAT	0x2000
-#define K1STSR_RRSTAT	0x1000
-#define K1STSR_LP1KFD	0x0800
-#define K1STSR_LP1KHD   0x0400
-#define K1STSR_LPASMDIR	0x0200
-
-#define K1SCR_1KX_FDX	0x8000
-#define K1SCR_1KX_HDX	0x4000
-#define K1SCR_1KT_FDX	0x2000
-#define K1SCR_1KT_HDX	0x1000
-
-#define STRAP_PHY1	0x0800
-#define STRAP_NCMODE	0x0400
-#define STRAP_MANMSCFG	0x0200
-#define STRAP_ANENABLE	0x0100
-#define STRAP_MSVAL	0x0080
-#define STRAP_1KHDXADV	0x0010
-#define STRAP_1KFDXADV	0x0008
-#define STRAP_100ADV	0x0004
-#define STRAP_SPEEDSEL	0x0000
-#define STRAP_SPEED100	0x0001
-
-#define PHYSUP_SPEED1000 0x10
-#define PHYSUP_SPEED100  0x08
-#define PHYSUP_SPEED10   0x00
-#define PHYSUP_LINKUP	 0x04
-#define PHYSUP_FDX       0x02
-
-#define	MII_BMCR	0x00 	/* Basic mode control register (rw) */
-#define	MII_BMSR	0x01	/* Basic mode status register (ro) */
-#define	MII_PHYIDR1	0x02
-#define	MII_PHYIDR2	0x03
-
-#define MII_K1STSR	0x0A	/* 1K Status Register (ro) */
-#define	MII_ANLPAR	0x05	/* Autonegotiation lnk partner abilities (rw) */
-
-
 #define M_MAC_MDIO_DIR_OUTPUT	0		/* for clarity */
 
 #define ENABLE 		1
 #define DISABLE		0
 
 /**********************************************************************
- *  SBMAC_MII_SYNC(s)
+ *  SBMAC_MII_SYNC(sbm_mdio)
  *
  *  Synchronize with the MII - send a pattern of bits to the MII
  *  that will guarantee that it is ready to accept a command.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   sbm_mdio - address of the MAC's MDIO register
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbmac_mii_sync(struct sbmac_softc *s)
+static void sbmac_mii_sync(void __iomem *sbm_mdio)
 {
 	int cnt;
 	uint64_t bits;
 	int mac_mdio_genc;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	bits = M_MAC_MDIO_DIR_OUTPUT | M_MAC_MDIO_OUT;
 
-	__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 
 	for (cnt = 0; cnt < 32; cnt++) {
-		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 	}
 }
 
 /**********************************************************************
- *  SBMAC_MII_SENDDATA(s,data,bitcnt)
+ *  SBMAC_MII_SENDDATA(sbm_mdio, data, bitcnt)
  *
  *  Send some bits to the MII.  The bits to be sent are right-
  *  justified in the 'data' parameter.
  *
  *  Input parameters:
- *  	   s - sbmac structure
- *  	   data - data to send
- *  	   bitcnt - number of bits to send
+ *  	   sbm_mdio - address of the MAC's MDIO register
+ *  	   data     - data to send
+ *  	   bitcnt   - number of bits to send
  ********************************************************************* */
 
-static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitcnt)
+static void sbmac_mii_senddata(void __iomem *sbm_mdio, unsigned int data,
+			       int bitcnt)
 {
 	int i;
 	uint64_t bits;
 	unsigned int curmask;
 	int mac_mdio_genc;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	bits = M_MAC_MDIO_DIR_OUTPUT;
-	__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 
 	curmask = 1 << (bitcnt - 1);
 
@@ -533,9 +432,9 @@ static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitc
 		if (data & curmask)
 			bits |= M_MAC_MDIO_OUT;
 		else bits &= ~M_MAC_MDIO_OUT;
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(bits | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | M_MAC_MDC | mac_mdio_genc, sbm_mdio);
+		__raw_writeq(bits | mac_mdio_genc, sbm_mdio);
 		curmask >>= 1;
 	}
 }
@@ -543,21 +442,22 @@ static void sbmac_mii_senddata(struct sbmac_softc *s,unsigned int data, int bitc
 
 
 /**********************************************************************
- *  SBMAC_MII_READ(s,phyaddr,regidx)
- *
+ *  SBMAC_MII_READ(bus, phyaddr, regidx)
  *  Read a PHY register.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   bus     - MDIO bus handle
  *  	   phyaddr - PHY's address
- *  	   regidx = index of register to read
+ *  	   regnum  - index of register to read
  *
  *  Return value:
- *  	   value read, or 0 if an error occurred.
+ *  	   value read, or 0xffff if an error occurred.
  ********************************************************************* */
 
-static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx)
+static int sbmac_mii_read(struct mii_bus *bus, int phyaddr, int regidx)
 {
+	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
+	void __iomem *sbm_mdio = sc->sbm_mdio;
 	int idx;
 	int error;
 	int regval;
@@ -567,8 +467,7 @@ static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx)
 	 * Synchronize ourselves so that the PHY knows the next
 	 * thing coming down is a command
 	 */
-
-	sbmac_mii_sync(s);
+	sbmac_mii_sync(sbm_mdio);
 
 	/*
 	 * Send the data to the PHY.  The sequence is
@@ -577,37 +476,37 @@ static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx)
 	 * the PHY addr (5 bits)
 	 * the register index (5 bits)
 	 */
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_START, 2);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_READ, 2);
+	sbmac_mii_senddata(sbm_mdio, phyaddr, 5);
+	sbmac_mii_senddata(sbm_mdio, regidx, 5);
 
-	sbmac_mii_senddata(s,MII_COMMAND_START, 2);
-	sbmac_mii_senddata(s,MII_COMMAND_READ, 2);
-	sbmac_mii_senddata(s,phyaddr, 5);
-	sbmac_mii_senddata(s,regidx, 5);
-
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
 	/*
 	 * Switch the port around without a clock transition.
 	 */
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	/*
 	 * Send out a clock pulse to signal we want the status
 	 */
-
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+		     sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	/*
 	 * If an error occurred, the PHY will signal '1' back
 	 */
-	error = __raw_readq(s->sbm_mdio) & M_MAC_MDIO_IN;
+	error = __raw_readq(sbm_mdio) & M_MAC_MDIO_IN;
 
 	/*
 	 * Issue an 'idle' clock pulse, but keep the direction
 	 * the same.
 	 */
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+		     sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 
 	regval = 0;
 
@@ -615,55 +514,60 @@ static unsigned int sbmac_mii_read(struct sbmac_softc *s,int phyaddr,int regidx)
 		regval <<= 1;
 
 		if (error == 0) {
-			if (__raw_readq(s->sbm_mdio) & M_MAC_MDIO_IN)
+			if (__raw_readq(sbm_mdio) & M_MAC_MDIO_IN)
 				regval |= 1;
 		}
 
-		__raw_writeq(M_MAC_MDIO_DIR_INPUT|M_MAC_MDC | mac_mdio_genc, s->sbm_mdio);
-		__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, s->sbm_mdio);
+		__raw_writeq(M_MAC_MDIO_DIR_INPUT | M_MAC_MDC | mac_mdio_genc,
+			     sbm_mdio);
+		__raw_writeq(M_MAC_MDIO_DIR_INPUT | mac_mdio_genc, sbm_mdio);
 	}
 
 	/* Switch back to output */
-	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, s->sbm_mdio);
+	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, sbm_mdio);
 
 	if (error == 0)
 		return regval;
-	return 0;
+	return 0xffff;
 }
 
 
 /**********************************************************************
- *  SBMAC_MII_WRITE(s,phyaddr,regidx,regval)
+ *  SBMAC_MII_WRITE(bus, phyaddr, regidx, regval)
  *
  *  Write a value to a PHY register.
  *
  *  Input parameters:
- *  	   s - sbmac structure
+ *  	   bus     - MDIO bus handle
  *  	   phyaddr - PHY to use
- *  	   regidx - register within the PHY
- *  	   regval - data to write to register
+ *  	   regidx  - register within the PHY
+ *  	   regval  - data to write to register
  *
  *  Return value:
- *  	   nothing
+ *  	   0 for success
  ********************************************************************* */
 
-static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
-			    unsigned int regval)
+static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
+			   u16 regval)
 {
+	struct sbmac_softc *sc = (struct sbmac_softc *)bus->priv;
+	void __iomem *sbm_mdio = sc->sbm_mdio;
 	int mac_mdio_genc;
 
-	sbmac_mii_sync(s);
+	sbmac_mii_sync(sbm_mdio);
+
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_START, 2);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_WRITE, 2);
+	sbmac_mii_senddata(sbm_mdio, phyaddr, 5);
+	sbmac_mii_senddata(sbm_mdio, regidx, 5);
+	sbmac_mii_senddata(sbm_mdio, MII_COMMAND_ACK, 2);
+	sbmac_mii_senddata(sbm_mdio, regval, 16);
 
-	sbmac_mii_senddata(s,MII_COMMAND_START,2);
-	sbmac_mii_senddata(s,MII_COMMAND_WRITE,2);
-	sbmac_mii_senddata(s,phyaddr, 5);
-	sbmac_mii_senddata(s,regidx, 5);
-	sbmac_mii_senddata(s,MII_COMMAND_ACK,2);
-	sbmac_mii_senddata(s,regval,16);
+	mac_mdio_genc = __raw_readq(sbm_mdio) & M_MAC_GENC;
 
-	mac_mdio_genc = __raw_readq(s->sbm_mdio) & M_MAC_GENC;
+	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, sbm_mdio);
 
-	__raw_writeq(M_MAC_MDIO_DIR_OUTPUT | mac_mdio_genc, s->sbm_mdio);
+	return 0;
 }
 
 
@@ -676,8 +580,8 @@ static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
  *  way.
  *
  *  Input parameters:
- *  	   d - sbmacdma_t structure (DMA channel context)
- *  	   s - sbmac_softc structure (pointer to a MAC)
+ *  	   d - struct sbmacdma (DMA channel context)
+ *  	   s - struct sbmac_softc (pointer to a MAC)
  *  	   chan - channel number (0..1 right now)
  *  	   txrx - Identifies DMA_TX or DMA_RX for channel direction
  *      maxdescr - number of descriptors
@@ -686,11 +590,8 @@ static void sbmac_mii_write(struct sbmac_softc *s,int phyaddr,int regidx,
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_initctx(sbmacdma_t *d,
-			  struct sbmac_softc *s,
-			  int chan,
-			  int txrx,
-			  int maxdescr)
+static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
+			  int txrx, int maxdescr)
 {
 #ifdef CONFIG_SBMAC_COALESCE
 	int int_pktcnt, int_timeout;
@@ -709,27 +610,27 @@ static void sbdma_initctx(sbmacdma_t *d,
 	s->sbe_idx =(s->sbm_base - A_MAC_BASE_0)/MAC_SPACING;
 #endif
 
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_BYTES)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_COLLISIONS)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_LATE_COL)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_EX_COL)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_FCS_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_ABORT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_BAD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_GOOD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_RUNT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_TX_OVERSIZE)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BYTES)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_MCAST)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BCAST)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_BAD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_GOOD)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_RUNT)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_OVERSIZE)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_FCS_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_LENGTH_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_CODE_ERROR)));
-	__raw_writeq(0, IOADDR(A_MAC_REGISTER(s->sbe_idx, R_MAC_RMON_RX_ALIGN_ERROR)));
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_BYTES);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_COLLISIONS);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_LATE_COL);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_EX_COL);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_FCS_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_ABORT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_BAD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_GOOD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_RUNT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_TX_OVERSIZE);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BYTES);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_MCAST);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BCAST);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_BAD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_GOOD);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_RUNT);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_OVERSIZE);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_FCS_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_LENGTH_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_CODE_ERROR);
+	__raw_writeq(0, s->sbm_base + R_MAC_RMON_RX_ALIGN_ERROR);
 
 	/*
 	 * initialize register pointers
@@ -757,18 +658,17 @@ static void sbdma_initctx(sbmacdma_t *d,
 
 	d->sbdma_maxdescr = maxdescr;
 
-	d->sbdma_dscrtable_unaligned =
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		kmalloc((d->sbdma_maxdescr+1)*sizeof(sbdmadscr_t), GFP_KERNEL);
+	d->sbdma_dscrtable_unaligned = kcalloc(d->sbdma_maxdescr + 1,
+					       sizeof(*d->sbdma_dscrtable),
+					       GFP_KERNEL);
 
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
 	 * MAC will corrupt it.
 	 */
-	d->sbdma_dscrtable = (sbdmadscr_t *)
-		ALIGN((unsigned long)d->sbdma_dscrtable, sizeof(sbdmadscr_t));
-
-	memset(d->sbdma_dscrtable,0,d->sbdma_maxdescr*sizeof(sbdmadscr_t));
+	d->sbdma_dscrtable = (struct sbdmadscr *)
+			     ALIGN((unsigned long)d->sbdma_dscrtable_unaligned,
+				   sizeof(*d->sbdma_dscrtable));
 
 	d->sbdma_dscrtable_end = d->sbdma_dscrtable + d->sbdma_maxdescr;
 
@@ -779,7 +679,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 */
 
 	d->sbdma_ctxtable = kcalloc(d->sbdma_maxdescr,
-				    sizeof(struct sk_buff *), GFP_KERNEL);
+				    sizeof(*d->sbdma_ctxtable), GFP_KERNEL);
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*
@@ -816,7 +716,7 @@ static void sbdma_initctx(sbmacdma_t *d,
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_start(sbmacdma_t *d, int rxtx )
+static void sbdma_channel_start(struct sbmacdma *d, int rxtx)
 {
 	/*
 	 * Turn on the DMA channel
@@ -857,7 +757,7 @@ static void sbdma_channel_start(sbmacdma_t *d, int rxtx )
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_channel_stop(sbmacdma_t *d)
+static void sbdma_channel_stop(struct sbmacdma *d)
 {
 	/*
 	 * Turn off the DMA channel
@@ -906,10 +806,10 @@ static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
  ********************************************************************* */
 
 
-static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *sb)
+static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
 {
-	sbdmadscr_t *dsc;
-	sbdmadscr_t *nextdsc;
+	struct sbdmadscr *dsc;
+	struct sbdmadscr *nextdsc;
 	struct sk_buff *sb_new = NULL;
 	int pktsize = ENET_PACKET_SIZE;
 
@@ -950,7 +850,7 @@ static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *sb)
 	if (sb == NULL) {
 		sb_new = dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN);
 		if (sb_new == NULL) {
-			printk(KERN_INFO "%s: sk_buff allocation failed\n",
+			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
@@ -1021,10 +921,10 @@ static int sbdma_add_rcvbuffer(sbmacdma_t *d,struct sk_buff *sb)
  ********************************************************************* */
 
 
-static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *sb)
+static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *sb)
 {
-	sbdmadscr_t *dsc;
-	sbdmadscr_t *nextdsc;
+	struct sbdmadscr *dsc;
+	struct sbdmadscr *nextdsc;
 	uint64_t phys;
 	uint64_t ncb;
 	int length;
@@ -1110,7 +1010,7 @@ static int sbdma_add_txbuffer(sbmacdma_t *d,struct sk_buff *sb)
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_emptyring(sbmacdma_t *d)
+static void sbdma_emptyring(struct sbmacdma *d)
 {
 	int idx;
 	struct sk_buff *sb;
@@ -1138,7 +1038,7 @@ static void sbdma_emptyring(sbmacdma_t *d)
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_fillring(sbmacdma_t *d)
+static void sbdma_fillring(struct sbmacdma *d)
 {
 	int idx;
 
@@ -1185,13 +1085,13 @@ static void sbmac_netpoll(struct net_device *netdev)
  *  	   nothing
  ********************************************************************* */
 
-static int sbdma_rx_process(struct sbmac_softc *sc,sbmacdma_t *d,
-                             int work_to_do, int poll)
+static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			    int work_to_do, int poll)
 {
 	struct net_device *dev = sc->sbm_dev;
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	int len;
 	int work_done = 0;
@@ -1223,8 +1123,9 @@ again:
 		prefetch(dsc);
 		prefetch(&d->sbdma_ctxtable[curidx]);
 
-		hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-				d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+		hwidx = ((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
+			 d->sbdma_dscrtable_phys) /
+			sizeof(*d->sbdma_dscrtable);
 
 		/*
 		 * If they're the same, that means we've processed all
@@ -1348,12 +1249,13 @@ done:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll)
+static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
+			     int poll)
 {
 	struct net_device *dev = sc->sbm_dev;
 	int curidx;
 	int hwidx;
-	sbdmadscr_t *dsc;
+	struct sbdmadscr *dsc;
 	struct sk_buff *sb;
 	unsigned long flags;
 	int packets_handled = 0;
@@ -1363,8 +1265,8 @@ static void sbdma_tx_process(struct sbmac_softc *sc,sbmacdma_t *d, int poll)
 	if (d->sbdma_remptr == d->sbdma_addptr)
 	  goto end_unlock;
 
-	hwidx = (int) (((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
-			d->sbdma_dscrtable_phys) / sizeof(sbdmadscr_t));
+	hwidx = ((__raw_readq(d->sbdma_curdscr) & M_DMA_CURDSCR_ADDR) -
+		 d->sbdma_dscrtable_phys) / sizeof(*d->sbdma_dscrtable);
 
 	for (;;) {
 		/*
@@ -1467,14 +1369,6 @@ static int sbmac_initctx(struct sbmac_softc *s)
 	s->sbm_imr       = s->sbm_base + R_MAC_INT_MASK;
 	s->sbm_mdio      = s->sbm_base + R_MAC_MDIO;
 
-	s->sbm_phys[0]   = 1;
-	s->sbm_phys[1]   = 0;
-
-	s->sbm_phy_oldbmsr = 0;
-	s->sbm_phy_oldanlpar = 0;
-	s->sbm_phy_oldk1stsr = 0;
-	s->sbm_phy_oldlinkstat = 0;
-
 	/*
 	 * Initialize the DMA channels.  Right now, only one per MAC is used
 	 * Note: Only do this _once_, as it allocates memory from the kernel!
@@ -1489,19 +1383,11 @@ static int sbmac_initctx(struct sbmac_softc *s)
 
 	s->sbm_state = sbmac_state_off;
 
-	/*
-	 * Initial speed is (XXX TEMP) 10MBit/s HDX no FC
-	 */
-
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-
 	return 0;
 }
 
 
-static void sbdma_uninitctx(struct sbmacdma_s *d)
+static void sbdma_uninitctx(struct sbmacdma *d)
 {
 	if (d->sbdma_dscrtable_unaligned) {
 		kfree(d->sbdma_dscrtable_unaligned);
@@ -1537,7 +1423,7 @@ static void sbmac_uninitctx(struct sbmac_softc *sc)
 static void sbmac_channel_start(struct sbmac_softc *s)
 {
 	uint64_t reg;
-	volatile void __iomem *port;
+	void __iomem *port;
 	uint64_t cfg,fifo,framecfg;
 	int idx, th_value;
 
@@ -1800,10 +1686,10 @@ static void sbmac_channel_stop(struct sbmac_softc *s)
  *  Return value:
  *  	   old state
  ********************************************************************* */
-static sbmac_state_t sbmac_set_channel_state(struct sbmac_softc *sc,
-					     sbmac_state_t state)
+static enum sbmac_state sbmac_set_channel_state(struct sbmac_softc *sc,
+						enum sbmac_state state)
 {
-	sbmac_state_t oldstate = sc->sbm_state;
+	enum sbmac_state oldstate = sc->sbm_state;
 
 	/*
 	 * If same as previous state, return
@@ -1938,14 +1824,14 @@ static uint64_t sbmac_addr2reg(unsigned char *ptr)
  *
  *  Input parameters:
  *  	   s - sbmac structure
- *  	   speed - speed to set MAC to (see sbmac_speed_t enum)
+ *  	   speed - speed to set MAC to (see enum sbmac_speed)
  *
  *  Return value:
  *  	   1 if successful
  *      0 indicates invalid parameters
  ********************************************************************* */
 
-static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed)
+static int sbmac_set_speed(struct sbmac_softc *s, enum sbmac_speed speed)
 {
 	uint64_t cfg;
 	uint64_t framecfg;
@@ -2003,8 +1889,6 @@ static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed)
 		cfg |= V_MAC_SPEED_SEL_1000MBPS | M_MAC_BURST_EN;
 		break;
 
-	case sbmac_speed_auto:		/* XXX not implemented */
-		/* fall through */
 	default:
 		return 0;
 	}
@@ -2027,15 +1911,16 @@ static int sbmac_set_speed(struct sbmac_softc *s,sbmac_speed_t speed)
  *
  *  Input parameters:
  *  	   s - sbmac structure
- *  	   duplex - duplex setting (see sbmac_duplex_t)
- *  	   fc - flow control setting (see sbmac_fc_t)
+ *  	   duplex - duplex setting (see enum sbmac_duplex)
+ *  	   fc - flow control setting (see enum sbmac_fc)
  *
  *  Return value:
  *  	   1 if ok
  *  	   0 if an invalid parameter combination was specified
  ********************************************************************* */
 
-static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc_t fc)
+static int sbmac_set_duplex(struct sbmac_softc *s, enum sbmac_duplex duplex,
+			    enum sbmac_fc fc)
 {
 	uint64_t cfg;
 
@@ -2077,8 +1962,6 @@ static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc
 			cfg |= M_MAC_HDX_EN | V_MAC_FC_CMD_ENAB_FALSECARR;
 			break;
 
-		case sbmac_fc_auto:		/* XXX not implemented */
-			/* fall through */
 		case sbmac_fc_frame:		/* not valid in half duplex */
 		default:			/* invalid selection */
 			return 0;
@@ -2097,15 +1980,12 @@ static int sbmac_set_duplex(struct sbmac_softc *s,sbmac_duplex_t duplex,sbmac_fc
 
 		case sbmac_fc_collision:	/* not valid in full duplex */
 		case sbmac_fc_carrier:		/* not valid in full duplex */
-		case sbmac_fc_auto:		/* XXX not implemented */
-			/* fall through */
 		default:
 			return 0;
 		}
 		break;
-	case sbmac_duplex_auto:
-		/* XXX not implemented */
-		break;
+	default:
+		return 0;
 	}
 
 	/*
@@ -2228,7 +2108,7 @@ static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 static void sbmac_setmulti(struct sbmac_softc *sc)
 {
 	uint64_t reg;
-	volatile void __iomem *port;
+	void __iomem *port;
 	int idx;
 	struct dev_mc_list *mclist;
 	struct net_device *dev = sc->sbm_dev;
@@ -2384,7 +2264,7 @@ static int sb1250_change_mtu(struct net_device *_dev, int new_mtu)
 	if (new_mtu >  ENET_PACKET_SIZE)
 		return -EINVAL;
 	_dev->mtu = new_mtu;
-	printk(KERN_INFO "changing the mtu to %d\n", new_mtu);
+	pr_info("changing the mtu to %d\n", new_mtu);
 	return 0;
 }
 
@@ -2400,20 +2280,17 @@ static int sb1250_change_mtu(struct net_device *_dev, int new_mtu)
  *  	   status
  ********************************************************************* */
 
-static int sbmac_init(struct net_device *dev, int idx)
+static int sbmac_init(struct platform_device *pldev, long long base)
 {
-	struct sbmac_softc *sc;
+	struct net_device *dev = pldev->dev.driver_data;
+	int idx = pldev->id;
+	struct sbmac_softc *sc = netdev_priv(dev);
 	unsigned char *eaddr;
 	uint64_t ea_reg;
 	int i;
 	int err;
 	DECLARE_MAC_BUF(mac);
 
-	sc = netdev_priv(dev);
-
-	/* Determine controller base address */
-
-	sc->sbm_base = IOADDR(dev->base_addr);
 	sc->sbm_dev = dev;
 	sc->sbe_idx = idx;
 
@@ -2470,43 +2347,55 @@ static int sbmac_init(struct net_device *dev, int idx)
 	dev->poll_controller = sbmac_netpoll;
 #endif
 
+	dev->irq		= UNIT_INT(idx);
+
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);
 
 	err = register_netdev(dev);
-	if (err)
-		goto out_uninit;
-
-	if (sc->rx_hw_checksum == ENABLE) {
-		printk(KERN_INFO "%s: enabling TCP rcv checksum\n",
-			sc->sbm_dev->name);
+	if (err) {
+		printk(KERN_ERR "%s.%d: unable to register netdev\n",
+		       sbmac_string, idx);
+		sbmac_uninitctx(sc);
+		return err;
 	}
 
+	pr_info("%s.%d: registered as %s\n", sbmac_string, idx, dev->name);
+
+	if (sc->rx_hw_checksum == ENABLE)
+		pr_info("%s: enabling TCP rcv checksum\n", dev->name);
+
 	/*
 	 * Display Ethernet address (this is called during the config
 	 * process so we need to finish off the config message that
 	 * was being displayed)
 	 */
-	printk(KERN_INFO
-	       "%s: SiByte Ethernet at 0x%08lX, address: %s\n",
-	       dev->name, dev->base_addr, print_mac(mac, eaddr));
+	pr_info("%s: SiByte Ethernet at 0x%08Lx, address: %s\n",
+	       dev->name, base, print_mac(mac, eaddr));
 
-	return 0;
+	sc->mii_bus.name = sbmac_mdio_string;
+	sc->mii_bus.id = idx;
+	sc->mii_bus.priv = sc;
+	sc->mii_bus.read = sbmac_mii_read;
+	sc->mii_bus.write = sbmac_mii_write;
+	sc->mii_bus.irq = sc->phy_irq;
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		sc->mii_bus.irq[i] = SBMAC_PHY_INT;
 
-out_uninit:
-	sbmac_uninitctx(sc);
+	sc->mii_bus.dev = &pldev->dev;
+	dev_set_drvdata(&pldev->dev, &sc->mii_bus);
 
-	return err;
+	return 0;
 }
 
 
 static int sbmac_open(struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
+	int err;
 
-	if (debug > 1) {
-		printk(KERN_DEBUG "%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
-	}
+	if (debug > 1)
+		pr_debug("%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
 
 	/*
 	 * map/route interrupt (clear status first, in case something
@@ -2515,25 +2404,35 @@ static int sbmac_open(struct net_device *dev)
 	 */
 
 	__raw_readq(sc->sbm_isr);
-	if (request_irq(dev->irq, &sbmac_intr, IRQF_SHARED, dev->name, dev))
-		return -EBUSY;
+	err = request_irq(dev->irq, &sbmac_intr, IRQF_SHARED, dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "%s: unable to get IRQ %d\n", dev->name,
+		       dev->irq);
+		goto out_err;
+	}
 
 	/*
-	 * Probe phy address
+	 * Probe PHY address
 	 */
-
-	if(sbmac_mii_probe(dev) == -1) {
-		printk("%s: failed to probe PHY.\n", dev->name);
-		return -EINVAL;
+	err = mdiobus_register(&sc->mii_bus);
+	if (err) {
+		printk(KERN_ERR "%s: unable to register MDIO bus\n",
+		       dev->name);
+		goto out_unirq;
 	}
 
-	napi_enable(&sc->napi);
+	sc->sbm_speed = sbmac_speed_none;
+	sc->sbm_duplex = sbmac_duplex_none;
+	sc->sbm_fc = sbmac_fc_none;
+	sc->sbm_pause = -1;
+	sc->sbm_link = 0;
 
 	/*
-	 * Configure default speed
+	 * Attach to the PHY
 	 */
-
-	sbmac_mii_poll(sc,noisy_mii);
+	err = sbmac_mii_probe(dev);
+	if (err)
+		goto out_unregister;
 
 	/*
 	 * Turn on the channel
@@ -2541,200 +2440,133 @@ static int sbmac_open(struct net_device *dev)
 
 	sbmac_set_channel_state(sc,sbmac_state_on);
 
-	/*
-	 * XXX Station address is in dev->dev_addr
-	 */
-
-	if (dev->if_port == 0)
-		dev->if_port = 0;
-
 	netif_start_queue(dev);
 
 	sbmac_set_rx_mode(dev);
 
-	/* Set the timer to check for link beat. */
-	init_timer(&sc->sbm_timer);
-	sc->sbm_timer.expires = jiffies + 2 * HZ/100;
-	sc->sbm_timer.data = (unsigned long)dev;
-	sc->sbm_timer.function = &sbmac_timer;
-	add_timer(&sc->sbm_timer);
+	phy_start(sc->phy_dev);
+
+	napi_enable(&sc->napi);
 
 	return 0;
+
+out_unregister:
+	mdiobus_unregister(&sc->mii_bus);
+
+out_unirq:
+	free_irq(dev->irq, dev);
+
+out_err:
+	return err;
 }
 
 static int sbmac_mii_probe(struct net_device *dev)
 {
+	struct sbmac_softc *sc = netdev_priv(dev);
+	struct phy_device *phy_dev;
 	int i;
-	struct sbmac_softc *s = netdev_priv(dev);
-	u16 bmsr, id1, id2;
-	u32 vendor, device;
-
-	for (i=1; i<31; i++) {
-	bmsr = sbmac_mii_read(s, i, MII_BMSR);
-		if (bmsr != 0) {
-			s->sbm_phys[0] = i;
-			id1 = sbmac_mii_read(s, i, MII_PHYIDR1);
-			id2 = sbmac_mii_read(s, i, MII_PHYIDR2);
-			vendor = ((u32)id1 << 6) | ((id2 >> 10) & 0x3f);
-			device = (id2 >> 4) & 0x3f;
-
-			printk(KERN_INFO "%s: found phy %d, vendor %06x part %02x\n",
-				dev->name, i, vendor, device);
-			return i;
-		}
-	}
-	return -1;
-}
 
-
-static int sbmac_mii_poll(struct sbmac_softc *s,int noisy)
-{
-    int bmsr,bmcr,k1stsr,anlpar;
-    int chg;
-    char buffer[100];
-    char *p = buffer;
-
-    /* Read the mode status and mode control registers. */
-    bmsr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMSR);
-    bmcr = sbmac_mii_read(s,s->sbm_phys[0],MII_BMCR);
-
-    /* get the link partner status */
-    anlpar = sbmac_mii_read(s,s->sbm_phys[0],MII_ANLPAR);
-
-    /* if supported, read the 1000baseT register */
-    if (bmsr & BMSR_1000BT_XSR) {
-	k1stsr = sbmac_mii_read(s,s->sbm_phys[0],MII_K1STSR);
-	}
-    else {
-	k1stsr = 0;
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		phy_dev = sc->mii_bus.phy_map[i];
+		if (phy_dev)
+			break;
 	}
-
-    chg = 0;
-
-    if ((bmsr & BMSR_LINKSTAT) == 0) {
-	/*
-	 * If link status is down, clear out old info so that when
-	 * it comes back up it will force us to reconfigure speed
-	 */
-	s->sbm_phy_oldbmsr = 0;
-	s->sbm_phy_oldanlpar = 0;
-	s->sbm_phy_oldk1stsr = 0;
-	return 0;
+	if (!phy_dev) {
+		printk(KERN_ERR "%s: no PHY found\n", dev->name);
+		return -ENXIO;
 	}
 
-    if ((s->sbm_phy_oldbmsr != bmsr) ||
-	(s->sbm_phy_oldanlpar != anlpar) ||
-	(s->sbm_phy_oldk1stsr != k1stsr)) {
-	if (debug > 1) {
-	    printk(KERN_DEBUG "%s: bmsr:%x/%x anlpar:%x/%x  k1stsr:%x/%x\n",
-	       s->sbm_dev->name,
-	       s->sbm_phy_oldbmsr,bmsr,
-	       s->sbm_phy_oldanlpar,anlpar,
-	       s->sbm_phy_oldk1stsr,k1stsr);
-	    }
-	s->sbm_phy_oldbmsr = bmsr;
-	s->sbm_phy_oldanlpar = anlpar;
-	s->sbm_phy_oldk1stsr = k1stsr;
-	chg = 1;
+	phy_dev = phy_connect(dev, phy_dev->dev.bus_id, &sbmac_mii_poll, 0,
+			      PHY_INTERFACE_MODE_GMII);
+	if (IS_ERR(phy_dev)) {
+		printk(KERN_ERR "%s: could not attach to PHY\n", dev->name);
+		return PTR_ERR(phy_dev);
 	}
 
-    if (chg == 0)
-	    return 0;
+	/* Remove any features not supported by the controller */
+	phy_dev->supported &= SUPPORTED_10baseT_Half |
+			      SUPPORTED_10baseT_Full |
+			      SUPPORTED_100baseT_Half |
+			      SUPPORTED_100baseT_Full |
+			      SUPPORTED_1000baseT_Half |
+			      SUPPORTED_1000baseT_Full |
+			      SUPPORTED_Autoneg |
+			      SUPPORTED_MII |
+			      SUPPORTED_Pause |
+			      SUPPORTED_Asym_Pause;
+	phy_dev->advertising = phy_dev->supported;
+
+	pr_info("%s: attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
+		dev->name, phy_dev->drv->name,
+		phy_dev->dev.bus_id, phy_dev->irq);
+
+	sc->phy_dev = phy_dev;
 
-    p += sprintf(p,"Link speed: ");
-
-    if (k1stsr & K1STSR_LP1KFD) {
-	s->sbm_speed = sbmac_speed_1000;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = sbmac_fc_frame;
-	p += sprintf(p,"1000BaseT FDX");
-	}
-    else if (k1stsr & K1STSR_LP1KHD) {
-	s->sbm_speed = sbmac_speed_1000;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-	p += sprintf(p,"1000BaseT HDX");
-	}
-    else if (anlpar & ANLPAR_TXFD) {
-	s->sbm_speed = sbmac_speed_100;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = (anlpar & ANLPAR_PAUSE) ? sbmac_fc_frame : sbmac_fc_disabled;
-	p += sprintf(p,"100BaseT FDX");
-	}
-    else if (anlpar & ANLPAR_TXHD) {
-	s->sbm_speed = sbmac_speed_100;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_disabled;
-	p += sprintf(p,"100BaseT HDX");
-	}
-    else if (anlpar & ANLPAR_10FD) {
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_full;
-	s->sbm_fc = sbmac_fc_frame;
-	p += sprintf(p,"10BaseT FDX");
-	}
-    else if (anlpar & ANLPAR_10HD) {
-	s->sbm_speed = sbmac_speed_10;
-	s->sbm_duplex = sbmac_duplex_half;
-	s->sbm_fc = sbmac_fc_collision;
-	p += sprintf(p,"10BaseT HDX");
-	}
-    else {
-	p += sprintf(p,"Unknown");
-	}
-
-    if (noisy) {
-	    printk(KERN_INFO "%s: %s\n",s->sbm_dev->name,buffer);
-	    }
-
-    return 1;
+	return 0;
 }
 
 
-static void sbmac_timer(unsigned long data)
+static void sbmac_mii_poll(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *)data;
 	struct sbmac_softc *sc = netdev_priv(dev);
-	int next_tick = HZ;
-	int mii_status;
+	struct phy_device *phy_dev = sc->phy_dev;
+	unsigned long flags;
+	enum sbmac_fc fc;
+	int link_chg, speed_chg, duplex_chg, pause_chg, fc_chg;
+
+	link_chg = (sc->sbm_link != phy_dev->link);
+	speed_chg = (sc->sbm_speed != phy_dev->speed);
+	duplex_chg = (sc->sbm_duplex != phy_dev->duplex);
+	pause_chg = (sc->sbm_pause != phy_dev->pause);
+
+	if (!link_chg && !speed_chg && !duplex_chg && !pause_chg)
+		return;					/* Hmmm... */
+
+	if (!phy_dev->link) {
+		if (link_chg) {
+			sc->sbm_link = phy_dev->link;
+			sc->sbm_speed = sbmac_speed_none;
+			sc->sbm_duplex = sbmac_duplex_none;
+			sc->sbm_fc = sbmac_fc_disabled;
+			sc->sbm_pause = -1;
+			pr_info("%s: link unavailable\n", dev->name);
+		}
+		return;
+	}
 
-	spin_lock_irq (&sc->sbm_lock);
+	if (phy_dev->duplex == DUPLEX_FULL) {
+		if (phy_dev->pause)
+			fc = sbmac_fc_frame;
+		else
+			fc = sbmac_fc_disabled;
+	} else
+		fc = sbmac_fc_collision;
+	fc_chg = (sc->sbm_fc != fc);
 
-	/* make IFF_RUNNING follow the MII status bit "Link established" */
-	mii_status = sbmac_mii_read(sc, sc->sbm_phys[0], MII_BMSR);
+	pr_info("%s: link available: %dbase-%cD\n", dev->name, phy_dev->speed,
+		phy_dev->duplex == DUPLEX_FULL ? 'F' : 'H');
 
-	if ( (mii_status & BMSR_LINKSTAT) != (sc->sbm_phy_oldlinkstat) ) {
-    	        sc->sbm_phy_oldlinkstat = mii_status & BMSR_LINKSTAT;
-		if (mii_status & BMSR_LINKSTAT) {
-			netif_carrier_on(dev);
-		}
-		else {
-			netif_carrier_off(dev);
-		}
-	}
+	spin_lock_irqsave(&sc->sbm_lock, flags);
 
-	/*
-	 * Poll the PHY to see what speed we should be running at
-	 */
+	sc->sbm_speed = phy_dev->speed;
+	sc->sbm_duplex = phy_dev->duplex;
+	sc->sbm_fc = fc;
+	sc->sbm_pause = phy_dev->pause;
+	sc->sbm_link = phy_dev->link;
 
-	if (sbmac_mii_poll(sc,noisy_mii)) {
-		if (sc->sbm_state != sbmac_state_off) {
-			/*
-			 * something changed, restart the channel
-			 */
-			if (debug > 1) {
-				printk("%s: restarting channel because speed changed\n",
-				       sc->sbm_dev->name);
-			}
-			sbmac_channel_stop(sc);
-			sbmac_channel_start(sc);
-		}
+	if ((speed_chg || duplex_chg || fc_chg) &&
+	    sc->sbm_state != sbmac_state_off) {
+		/*
+		 * something changed, restart the channel
+		 */
+		if (debug > 1)
+			pr_debug("%s: restarting channel "
+				 "because PHY state changed\n", dev->name);
+		sbmac_channel_stop(sc);
+		sbmac_channel_start(sc);
 	}
 
-	spin_unlock_irq (&sc->sbm_lock);
-
-	sc->sbm_timer.expires = jiffies + next_tick;
-	add_timer(&sc->sbm_timer);
+	spin_unlock_irqrestore(&sc->sbm_lock, flags);
 }
 
 
@@ -2787,64 +2619,34 @@ static void sbmac_set_rx_mode(struct net_device *dev)
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
-	u16 *data = (u16 *)&rq->ifr_ifru;
-	unsigned long flags;
-	int retval;
 
-	spin_lock_irqsave(&sc->sbm_lock, flags);
-	retval = 0;
-
-	switch(cmd) {
-	case SIOCDEVPRIVATE:		/* Get the address of the PHY in use. */
-		data[0] = sc->sbm_phys[0] & 0x1f;
-		/* Fall Through */
-	case SIOCDEVPRIVATE+1:		/* Read the specified MII register. */
-		data[3] = sbmac_mii_read(sc, data[0] & 0x1f, data[1] & 0x1f);
-		break;
-	case SIOCDEVPRIVATE+2:		/* Write the specified MII register */
-		if (!capable(CAP_NET_ADMIN)) {
-			retval = -EPERM;
-			break;
-		}
-		if (debug > 1) {
-		    printk(KERN_DEBUG "%s: sbmac_mii_ioctl: write %02X %02X %02X\n",dev->name,
-		       data[0],data[1],data[2]);
-		    }
-		sbmac_mii_write(sc, data[0] & 0x1f, data[1] & 0x1f, data[2]);
-		break;
-	default:
-		retval = -EOPNOTSUPP;
-	}
+	if (!netif_running(dev) || !sc->phy_dev)
+		return -EINVAL;
 
-	spin_unlock_irqrestore(&sc->sbm_lock, flags);
-	return retval;
+	return phy_mii_ioctl(sc->phy_dev, if_mii(rq), cmd);
 }
 
 static int sbmac_close(struct net_device *dev)
 {
 	struct sbmac_softc *sc = netdev_priv(dev);
-	unsigned long flags;
-	int irq;
 
 	napi_disable(&sc->napi);
 
-	sbmac_set_channel_state(sc,sbmac_state_off);
+	phy_stop(sc->phy_dev);
 
-	del_timer_sync(&sc->sbm_timer);
-
-	spin_lock_irqsave(&sc->sbm_lock, flags);
+	sbmac_set_channel_state(sc, sbmac_state_off);
 
 	netif_stop_queue(dev);
 
-	if (debug > 1) {
-		printk(KERN_DEBUG "%s: Shutting down ethercard\n",dev->name);
-	}
+	if (debug > 1)
+		pr_debug("%s: Shutting down ethercard\n", dev->name);
 
-	spin_unlock_irqrestore(&sc->sbm_lock, flags);
+	phy_disconnect(sc->phy_dev);
+	sc->phy_dev = NULL;
 
-	irq = dev->irq;
-	synchronize_irq(irq);
-	free_irq(irq, dev);
+	mdiobus_unregister(&sc->mii_bus);
+
+	free_irq(dev->irq, dev);
 
 	sbdma_emptyring(&(sc->sbm_txdma));
 	sbdma_emptyring(&(sc->sbm_rxdma));
@@ -2877,54 +2679,195 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
+
+static int __init sbmac_probe(struct platform_device *pldev)
+{
+	struct net_device *dev;
+	struct sbmac_softc *sc;
+	void __iomem *sbm_base;
+	struct resource *res;
+	u64 sbmac_orig_hwaddr;
+	int err;
+
+	res = platform_get_resource(pldev, IORESOURCE_MEM, 0);
+	BUG_ON(!res);
+	sbm_base = ioremap_nocache(res->start, res->end - res->start + 1);
+	if (!sbm_base) {
+		printk(KERN_ERR "%s: unable to map device registers\n",
+		       pldev->dev.bus_id);
+		err = -ENOMEM;
+		goto out_out;
+	}
+
+	/*
+	 * The R_MAC_ETHERNET_ADDR register will be set to some nonzero
+	 * value for us by the firmware if we're going to use this MAC.
+	 * If we find a zero, skip this MAC.
+	 */
+	sbmac_orig_hwaddr = __raw_readq(sbm_base + R_MAC_ETHERNET_ADDR);
+	pr_debug("%s: %sconfiguring MAC at 0x%08Lx\n", pldev->dev.bus_id,
+		 sbmac_orig_hwaddr ? "" : "not ", (long long)res->start);
+	if (sbmac_orig_hwaddr == 0) {
+		err = 0;
+		goto out_unmap;
+	}
+
+	/*
+	 * Okay, cool.  Initialize this MAC.
+	 */
+	dev = alloc_etherdev(sizeof(struct sbmac_softc));
+	if (!dev) {
+		printk(KERN_ERR "%s: unable to allocate etherdev\n",
+		       pldev->dev.bus_id);
+		err = -ENOMEM;
+		goto out_unmap;
+	}
+
+	pldev->dev.driver_data = dev;
+	SET_NETDEV_DEV(dev, &pldev->dev);
+
+	sc = netdev_priv(dev);
+	sc->sbm_base = sbm_base;
+
+	err = sbmac_init(pldev, res->start);
+	if (err)
+		goto out_kfree;
+
+	return 0;
+
+out_kfree:
+	free_netdev(dev);
+	__raw_writeq(sbmac_orig_hwaddr, sbm_base + R_MAC_ETHERNET_ADDR);
+
+out_unmap:
+	iounmap(sbm_base);
+
+out_out:
+	return err;
+}
+
+static int __exit sbmac_remove(struct platform_device *pldev)
+{
+	struct net_device *dev = pldev->dev.driver_data;
+	struct sbmac_softc *sc = netdev_priv(dev);
+
+	unregister_netdev(dev);
+	sbmac_uninitctx(sc);
+	iounmap(sc->sbm_base);
+	free_netdev(dev);
+
+	return 0;
+}
+
+
+static struct platform_device **sbmac_pldev;
+static int sbmac_max_units;
+
 #if defined(SBMAC_ETH0_HWADDR) || defined(SBMAC_ETH1_HWADDR) || defined(SBMAC_ETH2_HWADDR) || defined(SBMAC_ETH3_HWADDR)
-static void
-sbmac_setup_hwaddr(int chan,char *addr)
+static void __init sbmac_setup_hwaddr(int idx, char *addr)
 {
+	void __iomem *sbm_base;
+	unsigned long start, end;
 	uint8_t eaddr[6];
 	uint64_t val;
-	unsigned long port;
 
-	port = A_MAC_CHANNEL_BASE(chan);
-	sbmac_parse_hwaddr(addr,eaddr);
+	if (idx >= sbmac_max_units)
+		return;
+
+	start = A_MAC_CHANNEL_BASE(idx);
+	end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
+
+	sbm_base = ioremap_nocache(start, end - start + 1);
+	if (!sbm_base) {
+		printk(KERN_ERR "%s: unable to map device registers\n",
+		       sbmac_string);
+		return;
+	}
+
+	sbmac_parse_hwaddr(addr, eaddr);
 	val = sbmac_addr2reg(eaddr);
-	__raw_writeq(val, IOADDR(port+R_MAC_ETHERNET_ADDR));
-	val = __raw_readq(IOADDR(port+R_MAC_ETHERNET_ADDR));
+	__raw_writeq(val, sbm_base + R_MAC_ETHERNET_ADDR);
+	val = __raw_readq(sbm_base + R_MAC_ETHERNET_ADDR);
+
+	iounmap(sbm_base);
 }
 #endif
 
-static struct net_device *dev_sbmac[MAX_UNITS];
+static int __init sbmac_platform_probe_one(int idx)
+{
+	struct platform_device *pldev;
+	struct {
+		struct resource r;
+		char name[strlen(sbmac_pretty) + 4];
+	} *res;
+	int err;
+
+	res = kzalloc(sizeof(*res), GFP_KERNEL);
+	if (!res) {
+		printk(KERN_ERR "%s.%d: unable to allocate memory\n",
+		       sbmac_string, idx);
+		err = -ENOMEM;
+		goto out_err;
+	}
+
+	/*
+	 * This is the base address of the MAC.
+	 */
+	snprintf(res->name, sizeof(res->name), "%s %d", sbmac_pretty, idx);
+	res->r.name = res->name;
+	res->r.flags = IORESOURCE_MEM;
+	res->r.start = A_MAC_CHANNEL_BASE(idx);
+	res->r.end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
+
+	pldev = platform_device_register_simple(sbmac_string, idx, &res->r, 1);
+	if (IS_ERR(pldev)) {
+		printk(KERN_ERR "%s.%d: unable to register platform device\n",
+		       sbmac_string, idx);
+		err = PTR_ERR(pldev);
+		goto out_kfree;
+	}
+
+	if (!pldev->dev.driver) {
+		err = 0;		/* No hardware at this address. */
+		goto out_unregister;
+	}
+
+	sbmac_pldev[idx] = pldev;
+	return 0;
 
-static int __init
-sbmac_init_module(void)
+out_unregister:
+	platform_device_unregister(pldev);
+
+out_kfree:
+	kfree(res);
+
+out_err:
+	return err;
+}
+
+static void __init sbmac_platform_probe(void)
 {
-	int idx;
-	struct net_device *dev;
-	unsigned long port;
-	int chip_max_units;
+	int i;
 
 	/* Set the number of available units based on the SOC type.  */
 	switch (soc_type) {
 	case K_SYS_SOC_TYPE_BCM1250:
 	case K_SYS_SOC_TYPE_BCM1250_ALT:
-		chip_max_units = 3;
+		sbmac_max_units = 3;
 		break;
 	case K_SYS_SOC_TYPE_BCM1120:
 	case K_SYS_SOC_TYPE_BCM1125:
 	case K_SYS_SOC_TYPE_BCM1125H:
-	case K_SYS_SOC_TYPE_BCM1250_ALT2: /* Hybrid */
-		chip_max_units = 2;
+	case K_SYS_SOC_TYPE_BCM1250_ALT2:	/* Hybrid */
+		sbmac_max_units = 2;
 		break;
 	case K_SYS_SOC_TYPE_BCM1x55:
 	case K_SYS_SOC_TYPE_BCM1x80:
-		chip_max_units = 4;
+		sbmac_max_units = 4;
 		break;
 	default:
-		chip_max_units = 0;
-		break;
+		return;				/* none */
 	}
-	if (chip_max_units > MAX_UNITS)
-		chip_max_units = MAX_UNITS;
 
 	/*
 	 * For bringup when not using the firmware, we can pre-fill
@@ -2932,89 +2875,71 @@ sbmac_init_module(void)
 	 * specified in this file (or maybe from the config file?)
 	 */
 #ifdef SBMAC_ETH0_HWADDR
-	if (chip_max_units > 0)
-	  sbmac_setup_hwaddr(0,SBMAC_ETH0_HWADDR);
+	sbmac_setup_hwaddr(0, SBMAC_ETH0_HWADDR);
 #endif
 #ifdef SBMAC_ETH1_HWADDR
-	if (chip_max_units > 1)
-	  sbmac_setup_hwaddr(1,SBMAC_ETH1_HWADDR);
+	sbmac_setup_hwaddr(1, SBMAC_ETH1_HWADDR);
 #endif
 #ifdef SBMAC_ETH2_HWADDR
-	if (chip_max_units > 2)
-	  sbmac_setup_hwaddr(2,SBMAC_ETH2_HWADDR);
+	sbmac_setup_hwaddr(2, SBMAC_ETH2_HWADDR);
 #endif
 #ifdef SBMAC_ETH3_HWADDR
-	if (chip_max_units > 3)
-	  sbmac_setup_hwaddr(3,SBMAC_ETH3_HWADDR);
+	sbmac_setup_hwaddr(3, SBMAC_ETH3_HWADDR);
 #endif
 
+	sbmac_pldev = kcalloc(sbmac_max_units, sizeof(*sbmac_pldev),
+			      GFP_KERNEL);
+	if (!sbmac_pldev) {
+		printk(KERN_ERR "%s: unable to allocate memory\n",
+		       sbmac_string);
+		return;
+	}
+
 	/*
 	 * Walk through the Ethernet controllers and find
 	 * those who have their MAC addresses set.
 	 */
-	for (idx = 0; idx < chip_max_units; idx++) {
+	for (i = 0; i < sbmac_max_units; i++)
+		if (sbmac_platform_probe_one(i))
+			break;
+}
 
-	        /*
-	         * This is the base address of the MAC.
-		 */
 
-	        port = A_MAC_CHANNEL_BASE(idx);
+static void __exit sbmac_platform_cleanup(void)
+{
+	int i;
 
-		/*
-		 * The R_MAC_ETHERNET_ADDR register will be set to some nonzero
-		 * value for us by the firmware if we are going to use this MAC.
-		 * If we find a zero, skip this MAC.
-		 */
+	for (i = 0; i < sbmac_max_units; i++)
+		platform_device_unregister(sbmac_pldev[i]);
+	kfree(sbmac_pldev);
+}
 
-		sbmac_orig_hwaddr[idx] = __raw_readq(IOADDR(port+R_MAC_ETHERNET_ADDR));
-		if (sbmac_orig_hwaddr[idx] == 0) {
-			printk(KERN_DEBUG "sbmac: not configuring MAC at "
-			       "%lx\n", port);
-		    continue;
-		}
 
-		/*
-		 * Okay, cool.  Initialize this MAC.
-		 */
+static struct platform_driver sbmac_driver = {
+	.probe = sbmac_probe,
+	.remove = __exit_p(sbmac_remove),
+	.driver = {
+		.name = sbmac_string,
+	},
+};
 
-		dev = alloc_etherdev(sizeof(struct sbmac_softc));
-		if (!dev)
-			return -ENOMEM;
+static int __init sbmac_init_module(void)
+{
+	int err;
 
-		printk(KERN_DEBUG "sbmac: configuring MAC at %lx\n", port);
+	err = platform_driver_register(&sbmac_driver);
+	if (err)
+		return err;
 
-		dev->irq = UNIT_INT(idx);
-		dev->base_addr = port;
-		dev->mem_end = 0;
-		if (sbmac_init(dev, idx)) {
-			port = A_MAC_CHANNEL_BASE(idx);
-			__raw_writeq(sbmac_orig_hwaddr[idx], IOADDR(port+R_MAC_ETHERNET_ADDR));
-			free_netdev(dev);
-			continue;
-		}
-		dev_sbmac[idx] = dev;
-	}
-	return 0;
-}
+	sbmac_platform_probe();
 
+	return err;
+}
 
-static void __exit
-sbmac_cleanup_module(void)
+static void __exit sbmac_cleanup_module(void)
 {
-	struct net_device *dev;
-	int idx;
-
-	for (idx = 0; idx < MAX_UNITS; idx++) {
-		struct sbmac_softc *sc;
-		dev = dev_sbmac[idx];
-		if (!dev)
-			continue;
-
-		sc = netdev_priv(dev);
-		unregister_netdev(dev);
-		sbmac_uninitctx(sc);
-		free_netdev(dev);
-	}
+	sbmac_platform_cleanup();
+	platform_driver_unregister(&sbmac_driver);
 }
 
 module_init(sbmac_init_module);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index dd0fd45..1a57bdd 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -1351,8 +1351,6 @@ enum {
 	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
 };
 
-#define PHY_M_PC_MDI_XMODE(x)	((((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
-
 enum {
 	PHY_M_PC_MAN_MDI	= 0, /* 00 = Manual MDI configuration */
 	PHY_M_PC_MAN_MDIX	= 1, /* 01 = Manual MDIX configuration */
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index a37637e..ff98f5d 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -466,7 +466,7 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 #else
 	int bar = 1;
 #endif
-	int phy, phy_idx = 0;
+	int phy, phy_end, phy_idx = 0;
 	DECLARE_MAC_BUF(mac);
 
 /* when built into the kernel, we only print version if device is found */
@@ -552,11 +552,19 @@ static int __devinit sundance_probe1 (struct pci_dev *pdev,
 
 	np->phys[0] = 1;		/* Default setting */
 	np->mii_preamble_required++;
+
 	/*
 	 * It seems some phys doesn't deal well with address 0 being accessed
-	 * first, so leave address zero to the end of the loop (32 & 31).
+	 * first
 	 */
-	for (phy = 1; phy <= 32 && phy_idx < MII_CNT; phy++) {
+	if (sundance_pci_tbl[np->chip_id].device == 0x0200) {
+		phy = 0;
+		phy_end = 31;
+	} else {
+		phy = 1;
+		phy_end = 32;	/* wraps to zero, due to 'phy & 0x1f' */
+	}
+	for (; phy <= phy_end && phy_idx < MII_CNT; phy++) {
 		int phyx = phy & 0x1f;
 		int mii_status = mdio_read(dev, phyx, MII_BMSR);
 		if (mii_status != 0xffff  &&  mii_status != 0x0000) {
diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 88d03c0..7224d36 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1045,11 +1045,6 @@ static irqreturn_t xl_interrupt(int irq, void *dev_id)
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u16 intstatus, macstatus  ;
 
-	if (!dev) { 
-		printk(KERN_WARNING "Device structure dead, aaahhhh !\n") ;
-		return IRQ_NONE; 
-	}
-
 	intstatus = readw(xl_mmio + MMIO_INTSTATUS) ;  
 
 	if (!(intstatus & 1)) /* We didn't generate the interrupt */
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 53c7523..76e5561 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -664,11 +664,6 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 	unsigned long ioaddr = dev->base_addr;
 	unsigned long flags;
 
-	if (!dev) {
-		ULI526X_DBUG(1, "uli526x_interrupt() without DEVICE arg", 0);
-		return IRQ_NONE;
-	}
-
 	spin_lock_irqsave(&db->lock, flags);
 	outl(0, ioaddr + DCR7);
 
@@ -1604,7 +1599,6 @@ static void uli526x_process_mode(struct uli526x_board_info *db)
 			case ULI526X_100MFD: phy_reg = 0x2100; break;
 			}
 			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
-       			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
 		}
 	}
 }
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 511a74c..4ae0579 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -72,6 +72,7 @@
 #include <linux/mii.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -84,6 +85,163 @@
 static int velocity_nics = 0;
 static int msglevel = MSG_LEVEL_INFO;
 
+/**
+ *	mac_get_cam_mask	-	Read a CAM mask
+ *	@regs: register block for this velocity
+ *	@mask: buffer to store mask
+ *
+ *	Fetch the mask bits of the selected CAM and store them into the
+ *	provided mask buffer.
+ */
+
+static void mac_get_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* read mask */
+	for (i = 0; i < 8; i++)
+		*mask++ = readb(&(regs->MARCAM[i]));
+
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+}
+
+
+/**
+ *	mac_set_cam_mask	-	Set a CAM mask
+ *	@regs: register block for this velocity
+ *	@mask: CAM mask to load
+ *
+ *	Store a new mask into a CAM
+ */
+
+static void mac_set_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(CAMADDR_CAMEN, &regs->CAMADDR);
+
+	for (i = 0; i < 8; i++) {
+		writeb(*mask++, &(regs->MARCAM[i]));
+	}
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+static void mac_set_vlan_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL, &regs->CAMADDR);
+
+	for (i = 0; i < 8; i++) {
+		writeb(*mask++, &(regs->MARCAM[i]));
+	}
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+/**
+ *	mac_set_cam	-	set CAM data
+ *	@regs: register block of this velocity
+ *	@idx: Cam index
+ *	@addr: 2 or 6 bytes of CAM data
+ *
+ *	Load an address or vlan tag into a CAM
+ */
+
+static void mac_set_cam(struct mac_regs __iomem * regs, int idx, const u8 *addr)
+{
+	int i;
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	idx &= (64 - 1);
+
+	writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
+
+	for (i = 0; i < 6; i++) {
+		writeb(*addr++, &(regs->MARCAM[i]));
+	}
+	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
+
+	udelay(10);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+static void mac_set_vlan_cam(struct mac_regs __iomem * regs, int idx,
+			     const u8 *addr)
+{
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	idx &= (64 - 1);
+
+	writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
+	writew(*((u16 *) addr), &regs->MARCAM[0]);
+
+	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
+
+	udelay(10);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+
+/**
+ *	mac_wol_reset	-	reset WOL after exiting low power
+ *	@regs: register block of this velocity
+ *
+ *	Called after we drop out of wake on lan mode in order to
+ *	reset the Wake on lan features. This function doesn't restore
+ *	the rest of the logic from the result of sleep/wakeup
+ */
+
+static void mac_wol_reset(struct mac_regs __iomem * regs)
+{
+
+	/* Turn off SWPTAG right after leaving power mode */
+	BYTE_REG_BITS_OFF(STICKHW_SWPTAG, &regs->STICKHW);
+	/* clear sticky bits */
+	BYTE_REG_BITS_OFF((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
+
+	BYTE_REG_BITS_OFF(CHIPGCR_FCGMII, &regs->CHIPGCR);
+	BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
+	/* disable force PME-enable */
+	writeb(WOLCFG_PMEOVR, &regs->WOLCFGClr);
+	/* disable power-event config bit */
+	writew(0xFFFF, &regs->WOLCRClr);
+	/* clear power status */
+	writew(0xFFFF, &regs->WOLSRClr);
+}
 
 static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static const struct ethtool_ops velocity_ethtool_ops;
@@ -111,15 +269,6 @@ VELOCITY_PARAM(RxDescriptors, "Number of receive descriptors");
 #define TX_DESC_DEF     64
 VELOCITY_PARAM(TxDescriptors, "Number of transmit descriptors");
 
-#define VLAN_ID_MIN     0
-#define VLAN_ID_MAX     4095
-#define VLAN_ID_DEF     0
-/* VID_setting[] is used for setting the VID of NIC.
-   0: default VID.
-   1-4094: other VIDs.
-*/
-VELOCITY_PARAM(VID_setting, "802.1Q VLAN ID");
-
 #define RX_THRESH_MIN   0
 #define RX_THRESH_MAX   3
 #define RX_THRESH_DEF   0
@@ -147,13 +296,6 @@ VELOCITY_PARAM(rx_thresh, "Receive fifo threshold");
 */
 VELOCITY_PARAM(DMA_length, "DMA length");
 
-#define TAGGING_DEF     0
-/* enable_tagging[] is used for enabling 802.1Q VID tagging.
-   0: disable VID seeting(default).
-   1: enable VID setting.
-*/
-VELOCITY_PARAM(enable_tagging, "Enable 802.1Q tagging");
-
 #define IP_ALIG_DEF     0
 /* IP_byte_align[] is used for IP header DWORD byte aligned
    0: indicate the IP header won't be DWORD byte aligned.(Default) .
@@ -324,7 +466,7 @@ MODULE_DEVICE_TABLE(pci, velocity_id_table);
  *	a pointer a static string valid while the driver is loaded.
  */
 
-static char __devinit *get_chip_name(enum chip_type chip_id)
+static const char __devinit *get_chip_name(enum chip_type chip_id)
 {
 	int i;
 	for (i = 0; chip_info_table[i].name != NULL; i++)
@@ -442,8 +584,7 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_int_opt(&opts->DMA_length, DMA_length[index], DMA_LENGTH_MIN, DMA_LENGTH_MAX, DMA_LENGTH_DEF, "DMA_length", devname);
 	velocity_set_int_opt(&opts->numrx, RxDescriptors[index], RX_DESC_MIN, RX_DESC_MAX, RX_DESC_DEF, "RxDescriptors", devname);
 	velocity_set_int_opt(&opts->numtx, TxDescriptors[index], TX_DESC_MIN, TX_DESC_MAX, TX_DESC_DEF, "TxDescriptors", devname);
-	velocity_set_int_opt(&opts->vid, VID_setting[index], VLAN_ID_MIN, VLAN_ID_MAX, VLAN_ID_DEF, "VID_setting", devname);
-	velocity_set_bool_opt(&opts->flags, enable_tagging[index], TAGGING_DEF, VELOCITY_FLAGS_TAGGING, "enable_tagging", devname);
+
 	velocity_set_bool_opt(&opts->flags, txcsum_offload[index], TX_CSUM_DEF, VELOCITY_FLAGS_TX_CSUM, "txcsum_offload", devname);
 	velocity_set_int_opt(&opts->flow_cntl, flow_control[index], FLOW_CNTL_MIN, FLOW_CNTL_MAX, FLOW_CNTL_DEF, "flow_control", devname);
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
@@ -465,6 +606,7 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem * regs = vptr->mac_regs;
+	unsigned short vid;
 
 	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
@@ -473,27 +615,52 @@ static void velocity_init_cam_filter(struct velocity_info *vptr)
 	/* Disable all CAMs */
 	memset(vptr->vCAMmask, 0, sizeof(u8) * 8);
 	memset(vptr->mCAMmask, 0, sizeof(u8) * 8);
-	mac_set_cam_mask(regs, vptr->vCAMmask, VELOCITY_VLAN_ID_CAM);
-	mac_set_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
+	mac_set_cam_mask(regs, vptr->mCAMmask);
 
 	/* Enable first VCAM */
-	if (vptr->flags & VELOCITY_FLAGS_TAGGING) {
-		/* If Tagging option is enabled and VLAN ID is not zero, then
-		   turn on MCFG_RTGOPT also */
-		if (vptr->options.vid != 0)
-			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
-
-		mac_set_cam(regs, 0, (u8 *) & (vptr->options.vid), VELOCITY_VLAN_ID_CAM);
+	if (vptr->vlgrp) {
+		for (vid = 0; vid < VLAN_VID_MASK; vid++) {
+			if (vlan_group_get_device(vptr->vlgrp, vid)) {
+				/* If Tagging option is enabled and
+				   VLAN ID is not zero, then
+				   turn on MCFG_RTGOPT also */
+				if (vid != 0)
+					WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
+
+				mac_set_vlan_cam(regs, 0, (u8 *) &vid);
+			}
+		}
 		vptr->vCAMmask[0] |= 1;
-		mac_set_cam_mask(regs, vptr->vCAMmask, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 	} else {
 		u16 temp = 0;
-		mac_set_cam(regs, 0, (u8 *) &temp, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam(regs, 0, (u8 *) &temp);
 		temp = 1;
-		mac_set_cam_mask(regs, (u8 *) &temp, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam_mask(regs, (u8 *) &temp);
 	}
 }
 
+static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+        spin_lock_irq(&vptr->lock);
+	velocity_init_cam_filter(vptr);
+        spin_unlock_irq(&vptr->lock);
+}
+
+static void velocity_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+        spin_lock_irq(&vptr->lock);
+	vlan_group_set_device(vptr->vlgrp, vid, NULL);
+	velocity_init_cam_filter(vptr);
+        spin_unlock_irq(&vptr->lock);
+}
+
+
 /**
  *	velocity_rx_reset	-	handle a receive reset
  *	@vptr: velocity we are resetting
@@ -790,13 +957,17 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	dev->do_ioctl = velocity_ioctl;
 	dev->ethtool_ops = &velocity_ethtool_ops;
 	dev->change_mtu = velocity_change_mtu;
+
+	dev->vlan_rx_add_vid = velocity_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid = velocity_vlan_rx_kill_vid;
+
 #ifdef  VELOCITY_ZERO_COPY_SUPPORT
 	dev->features |= NETIF_F_SG;
 #endif
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER;
 
-	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM) {
+	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM)
 		dev->features |= NETIF_F_IP_CSUM;
-	}
 
 	ret = register_netdev(dev);
 	if (ret < 0)
@@ -1989,8 +2160,8 @@ static int velocity_xmit(struct sk_buff *skb, struct net_device *dev)
 		td_ptr->tdesc1.CMDZ = 2;
 	}
 
-	if (vptr->flags & VELOCITY_FLAGS_TAGGING) {
-		td_ptr->tdesc1.pqinf.VID = (vptr->options.vid & 0xfff);
+	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
+		td_ptr->tdesc1.pqinf.VID = vlan_tx_tag_get(skb);
 		td_ptr->tdesc1.pqinf.priority = 0;
 		td_ptr->tdesc1.pqinf.CFI = 0;
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
@@ -2116,14 +2287,14 @@ static void velocity_set_multi(struct net_device *dev)
 		rx_mode = (RCR_AM | RCR_AB);
 	} else {
 		int offset = MCAM_SIZE - vptr->multicast_limit;
-		mac_get_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+		mac_get_cam_mask(regs, vptr->mCAMmask);
 
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
-			mac_set_cam(regs, i + offset, mclist->dmi_addr, VELOCITY_MULTICAST_CAM);
+			mac_set_cam(regs, i + offset, mclist->dmi_addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
 		}
 
-		mac_set_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+		mac_set_cam_mask(regs, vptr->mCAMmask);
 		rx_mode = (RCR_AM | RCR_AB);
 	}
 	if (dev->mtu > 1500)
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index b9e114d..aa91796 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1173,7 +1173,7 @@ enum chip_type {
 
 struct velocity_info_tbl {
 	enum chip_type chip_id;
-	char *name;
+	const char *name;
 	int txqueue;
 	u32 flags;
 };
@@ -1194,14 +1194,6 @@ struct velocity_info_tbl {
 #define mac_disable_int(regs)       	writel(CR0_GINTMSK1,&((regs)->CR0Clr))
 #define mac_enable_int(regs)    	writel(CR0_GINTMSK1,&((regs)->CR0Set))
 
-#define mac_hw_mibs_read(regs, MIBs) {\
-	int i;\
-	BYTE_REG_BITS_ON(MIBCR_MPTRINI,&((regs)->MIBCR));\
-	for (i=0;i<HW_MIB_SIZE;i++) {\
-		(MIBs)[i]=readl(&((regs)->MIBData));\
-	}\
-}
-
 #define mac_set_dma_length(regs, n) {\
 	BYTE_REG_BITS_SET((n),0x07,&((regs)->DCFG));\
 }
@@ -1226,195 +1218,17 @@ struct velocity_info_tbl {
 	writew(TRDCSR_WAK<<(n*4),&((regs)->TDCSRSet));\
 }
 
-#define mac_eeprom_reload(regs) {\
-	int i=0;\
-	BYTE_REG_BITS_ON(EECSR_RELOAD,&((regs)->EECSR));\
-	do {\
-		udelay(10);\
-		if (i++>0x1000) {\
-			break;\
-		}\
-	}while (BYTE_REG_BITS_IS_ON(EECSR_RELOAD,&((regs)->EECSR)));\
-}
-
-enum velocity_cam_type {
-	VELOCITY_VLAN_ID_CAM = 0,
-	VELOCITY_MULTICAST_CAM
-};
-
-/**
- *	mac_get_cam_mask	-	Read a CAM mask
- *	@regs: register block for this velocity
- *	@mask: buffer to store mask
- *	@cam_type: CAM to fetch
- *
- *	Fetch the mask bits of the selected CAM and store them into the
- *	provided mask buffer.
- */
-
-static inline void mac_get_cam_mask(struct mac_regs __iomem * regs, u8 * mask, enum velocity_cam_type cam_type)
-{
-	int i;
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_VCAMSL, &regs->CAMADDR);
-	else
-		writeb(0, &regs->CAMADDR);
-
-	/* read mask */
-	for (i = 0; i < 8; i++)
-		*mask++ = readb(&(regs->MARCAM[i]));
-
-	/* disable CAMEN */
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+static inline void mac_eeprom_reload(struct mac_regs __iomem * regs) {
+	int i=0;
 
+	BYTE_REG_BITS_ON(EECSR_RELOAD,&(regs->EECSR));
+	do {
+		udelay(10);
+		if (i++>0x1000)
+			break;
+	} while (BYTE_REG_BITS_IS_ON(EECSR_RELOAD,&(regs->EECSR)));
 }
 
-/**
- *	mac_set_cam_mask	-	Set a CAM mask
- *	@regs: register block for this velocity
- *	@mask: CAM mask to load
- *	@cam_type: CAM to store
- *
- *	Store a new mask into a CAM
- */
-
-static inline void mac_set_cam_mask(struct mac_regs __iomem * regs, u8 * mask, enum velocity_cam_type cam_type)
-{
-	int i;
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN, &regs->CAMADDR);
-
-	for (i = 0; i < 8; i++) {
-		writeb(*mask++, &(regs->MARCAM[i]));
-	}
-	/* disable CAMEN */
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-}
-
-/**
- *	mac_set_cam	-	set CAM data
- *	@regs: register block of this velocity
- *	@idx: Cam index
- *	@addr: 2 or 6 bytes of CAM data
- *	@cam_type: CAM to load
- *
- *	Load an address or vlan tag into a CAM
- */
-
-static inline void mac_set_cam(struct mac_regs __iomem * regs, int idx, u8 *addr, enum velocity_cam_type cam_type)
-{
-	int i;
-
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	idx &= (64 - 1);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writew(*((u16 *) addr), &regs->MARCAM[0]);
-	else {
-		for (i = 0; i < 6; i++) {
-			writeb(*addr++, &(regs->MARCAM[i]));
-		}
-	}
-	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
-
-	udelay(10);
-
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-}
-
-/**
- *	mac_get_cam	-	fetch CAM data
- *	@regs: register block of this velocity
- *	@idx: Cam index
- *	@addr: buffer to hold up to 6 bytes of CAM data
- *	@cam_type: CAM to load
- *
- *	Load an address or vlan tag from a CAM into the buffer provided by
- *	the caller. VLAN tags are 2 bytes the address cam entries are 6.
- */
-
-static inline void mac_get_cam(struct mac_regs __iomem * regs, int idx, u8 *addr, enum velocity_cam_type cam_type)
-{
-	int i;
-
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	idx &= (64 - 1);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
-
-	BYTE_REG_BITS_ON(CAMCR_CAMRD, &regs->CAMCR);
-
-	udelay(10);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		*((u16 *) addr) = readw(&(regs->MARCAM[0]));
-	else
-		for (i = 0; i < 6; i++, addr++)
-			*((u8 *) addr) = readb(&(regs->MARCAM[i]));
-
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-}
-
-/**
- *	mac_wol_reset	-	reset WOL after exiting low power
- *	@regs: register block of this velocity
- *
- *	Called after we drop out of wake on lan mode in order to
- *	reset the Wake on lan features. This function doesn't restore
- *	the rest of the logic from the result of sleep/wakeup
- */
-
-static inline void mac_wol_reset(struct mac_regs __iomem * regs)
-{
-
-	/* Turn off SWPTAG right after leaving power mode */
-	BYTE_REG_BITS_OFF(STICKHW_SWPTAG, &regs->STICKHW);
-	/* clear sticky bits */
-	BYTE_REG_BITS_OFF((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
-
-	BYTE_REG_BITS_OFF(CHIPGCR_FCGMII, &regs->CHIPGCR);
-	BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
-	/* disable force PME-enable */
-	writeb(WOLCFG_PMEOVR, &regs->WOLCFGClr);
-	/* disable power-event config bit */
-	writew(0xFFFF, &regs->WOLCRClr);
-	/* clear power status */
-	writew(0xFFFF, &regs->WOLSRClr);
-}
-
-
 /*
  * Header for WOL definitions. Used to compute hashes
  */
@@ -1701,7 +1515,7 @@ struct velocity_opt {
 	int numrx;			/* Number of RX descriptors */
 	int numtx;			/* Number of TX descriptors */
 	enum speed_opt spd_dpx;		/* Media link mode */
-	int vid;			/* vlan id */
+
 	int DMA_length;			/* DMA length */
 	int rx_thresh;			/* RX_THRESH */
 	int flow_cntl;
@@ -1727,6 +1541,7 @@ struct velocity_info {
 	dma_addr_t tx_bufs_dma;
 	u8 *tx_bufs;
 
+	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
 	enum chip_type chip_id;
 
diff --git a/include/linux/eeprom_93cx6.h b/include/linux/eeprom_93cx6.h
index d774b77..a55c873 100644
--- a/include/linux/eeprom_93cx6.h
+++ b/include/linux/eeprom_93cx6.h
@@ -21,13 +21,14 @@
 /*
 	Module: eeprom_93cx6
 	Abstract: EEPROM reader datastructures for 93cx6 chipsets.
-	Supported chipsets: 93c46 & 93c66.
+	Supported chipsets: 93c46, 93c56 and 93c66.
  */
 
 /*
  * EEPROM operation defines.
  */
 #define PCI_EEPROM_WIDTH_93C46	6
+#define PCI_EEPROM_WIDTH_93C56	8
 #define PCI_EEPROM_WIDTH_93C66	8
 #define PCI_EEPROM_WIDTH_OPCODE	3
 #define PCI_EEPROM_WRITE_OPCODE	0x05
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2a65978..f0742b6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,6 +25,8 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 
+#include <asm/atomic.h>
+
 #define PHY_BASIC_FEATURES	(SUPPORTED_10baseT_Half | \
 				 SUPPORTED_10baseT_Full | \
 				 SUPPORTED_100baseT_Half | \
@@ -281,6 +283,7 @@ struct phy_device {
 	/* Interrupt and Polling infrastructure */
 	struct work_struct phy_queue;
 	struct timer_list phy_timer;
+	atomic_t irq_disable;
 
 	spinlock_t lock;
 
diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
new file mode 100644
index 0000000..04ba70d
--- /dev/null
+++ b/include/linux/phy_fixed.h
@@ -0,0 +1,38 @@
+#ifndef __PHY_FIXED_H
+#define __PHY_FIXED_H
+
+#define MII_REGS_NUM	29
+
+/* max number of virtual phy stuff */
+#define MAX_PHY_AMNT	10
+/*
+    The idea is to emulate normal phy behavior by responding with
+    pre-defined values to mii BMCR read, so that read_status hook could
+    take all the needed info.
+*/
+
+struct fixed_phy_status {
+	u8 link;
+	u16 speed;
+	u8 duplex;
+};
+
+/*-----------------------------------------------------------------------------
+ *  Private information hoder for mii_bus
+ *-----------------------------------------------------------------------------*/
+struct fixed_info {
+	u16 *regs;
+	u8 regs_num;
+	struct fixed_phy_status phy_status;
+	struct phy_device *phydev;	/* pointer to the container */
+	/* link & speed cb */
+	int (*link_update) (struct net_device *, struct fixed_phy_status *);
+
+};
+
+
+int fixed_mdio_set_link_update(struct phy_device *,
+       int (*link_update) (struct net_device *, struct fixed_phy_status *));
+struct fixed_info *fixed_mdio_get_phydev (int phydev_ind);
+
+#endif /* __PHY_FIXED_H */
diff --git a/include/net/ax88796.h b/include/net/ax88796.h
index ee786a0..51329da 100644
--- a/include/net/ax88796.h
+++ b/include/net/ax88796.h
@@ -14,6 +14,7 @@
 
 #define AXFLG_HAS_EEPROM		(1<<0)
 #define AXFLG_MAC_FROMDEV		(1<<1)	/* device already has MAC */
+#define AXFLG_HAS_93CX6			(1<<2)	/* use eeprom_93cx6 driver */
 
 struct ax_plat_data {
 	unsigned int	 flags;
