From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Thu, 25 Oct 2007 03:49:50 -0400
Message-ID: <20071025074950.GA8909@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:41535 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397AbXJYHtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 03:49:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/networking/00-INDEX        |    2 -
 Documentation/networking/net-modules.txt |  315 ------------------------------
 drivers/net/bonding/bond_main.c          |    5 +-
 drivers/net/bonding/bonding.h            |    1 -
 drivers/net/cpmac.c                      |  145 ++++++++------
 drivers/net/ehea/ehea.h                  |    2 +-
 drivers/net/ehea/ehea_main.c             |    7 +-
 drivers/net/forcedeth.c                  |   16 ++
 drivers/net/ipg.c                        |   22 ++-
 drivers/net/ipg.h                        |   20 --
 drivers/net/natsemi.c                    |    1 +
 drivers/net/usb/rndis_host.c             |   18 ++-
 include/linux/pci_ids.h                  |    4 +
 13 files changed, 149 insertions(+), 409 deletions(-)
 delete mode 100644 Documentation/networking/net-modules.txt

Adrian Bunk (4):
      remove Documentation/networking/net-modules.txt
      drivers/net/ipg.c: cleanups
      make bonding/bond_main.c:bond_deinit() static
      bonding/bond_main.c: fix cut'n'paste error

Ayaz Abdulla (1):
      [netdrvr] forcedeth: add MCP77 device IDs

Eugene Konev (3):
      cpmac: use print_mac() instead of MAC_FMT
      cpmac: convert to napi_struct interface
      cpmac: update to new fixed phy driver interface

Ingo Molnar (1):
      natsemi: fix oops, link back netdevice from private-struct

Jan-Bernd Themann (1):
      ehea: fix port_napi_disable/enable

Thomas Sailer (1):
      rndis_host: reduce MTU instead of refusing to talk to devices with low max packet size

diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 153d84d..f5a5e6d 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -80,8 +80,6 @@ multicast.txt
 	- Behaviour of cards under Multicast
 ncsa-telnet
 	- notes on how NCSA telnet (DOS) breaks with MTU discovery enabled.
-net-modules.txt
-	- info and "insmod" parameters for all network driver modules.
 netdevices.txt
 	- info on network device driver functions exported to the kernel.
 olympic.txt
diff --git a/Documentation/networking/net-modules.txt b/Documentation/networking/net-modules.txt
deleted file mode 100644
index 98c4392..0000000
--- a/Documentation/networking/net-modules.txt
+++ /dev/null
@@ -1,315 +0,0 @@
-Wed 2-Aug-95  <matti.aarnio@utu.fi>
-
-		Linux network driver modules
-
-	Do not mistake this for "README.modules" at the top-level
-	directory!  That document tells about modules in general, while
-	this one tells only about network device driver modules.
-
-	This is a potpourri of INSMOD-time(*) configuration options
-	(if such exists) and their default values of various modules
-	in the Linux network drivers collection.
-
-	Some modules have also hidden (= non-documented) tunable values.
-	The choice of not documenting them is based on general belief, that
-	the less the user needs to know, the better.  (There are things that
-	driver developers can use, others should not confuse themselves.)
-
-	In many cases it is highly preferred that insmod:ing is done
-	ONLY with defining an explicit address for the card, AND BY
-	NOT USING AUTO-PROBING!
-
-	Now most cards have some explicitly defined base address that they
-	are compiled with (to avoid auto-probing, among other things).
-	If that compiled value does not match your actual configuration,
-	do use the "io=0xXXX" -parameter for the insmod, and give there
-	a value matching your environment.
-
-	If you are adventurous, you can ask the driver to autoprobe
-	by using the "io=0" parameter, however it is a potentially dangerous
-	thing to do in a live system.  (If you don't know where the
-	card is located, you can try autoprobing, and after possible
-	crash recovery, insmod with proper IO-address..)
-
-	--------------------------
-	(*)	"INSMOD-time" means when you load module with
-		/sbin/insmod  you can feed it optional parameters.
-		See "man insmod".
-	--------------------------
-
-
-	8390 based Network Modules		(Paul Gortmaker, Nov 12, 1995)
-	--------------------------
-
-(Includes: smc-ultra, ne, wd, 3c503, hp, hp-plus, e2100 and ac3200)
-
-The 8390 series of network drivers now support multiple card systems without 
-reloading the same module multiple times (memory efficient!) This is done by 
-specifying multiple comma separated values, such as:
-
-	insmod 3c503.o io=0x280,0x300,0x330,0x350  xcvr=0,1,0,1
-
-The above would have the one module controlling four 3c503 cards, with card 2
-and 4 using external transceivers. The "insmod" manual describes the usage
-of comma separated value lists.
-
-It is *STRONGLY RECOMMENDED* that you supply "io=" instead of autoprobing.
-If an "io=" argument is not supplied, then the ISA drivers will complain
-about autoprobing being not recommended, and begrudgingly autoprobe for
-a *SINGLE CARD ONLY* -- if you want to use multiple cards you *have* to 
-supply an "io=0xNNN,0xQQQ,..." argument.
-
-The ne module is an exception to the above. A NE2000 is essentially an
-8390 chip, some bus glue and some RAM. Because of this, the ne probe is
-more invasive than the rest, and so at boot we make sure the ne probe is 
-done last of all the 8390 cards (so that it won't trip over other 8390 based
-cards) With modules we can't ensure that all other non-ne 8390 cards have
-already been found. Because of this, the ne module REQUIRES an "io=0xNNN" 
-argument passed in via insmod. It will refuse to autoprobe.
-
-It is also worth noting that auto-IRQ probably isn't as reliable during 
-the flurry of interrupt activity on a running machine. Cards such as the 
-ne2000 that can't get the IRQ setting from an EEPROM or configuration
-register are probably best supplied with an "irq=M" argument as well.
-
-
-----------------------------------------------------------------------
-Card/Module List - Configurable Parameters and Default Values
-----------------------------------------------------------------------
-
-3c501.c:
-	io  = 0x280	IO base address
-	irq = 5		IRQ
-	(Probes ports:	0x280, 0x300)
-
-3c503.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ software selected by driver using autoIRQ)
-	xcvr = 0	(Use xcvr=1 to select external transceiver.)
-	(Probes ports: 0x300, 0x310, 0x330, 0x350, 0x250, 0x280, 0x2A0, 0x2E0)
-
-3c505.c:
-	io = 0
-	irq = 0
-	dma = 6         (not autoprobed)
-	(Probes ports: 0x300, 0x280, 0x310)
-
-3c507.c:
-	io = 0x300
-	irq = 0
-	(Probes ports: 0x300, 0x320, 0x340, 0x280)
-
-3c509.c:
-	io = 0
-	irq = 0
-	( Module load-time probing Works reliably only on EISA, ISA ID-PROBE
-	  IS NOT RELIABLE!  Compile this driver statically into kernel for
-	  now, if you need it auto-probing on an ISA-bus machine. )
-
-8390.c:
-	(No public options, several other modules need this one)
-
-a2065.c:
-	Since this is a Zorro board, it supports full autoprobing, even for
-	multiple boards. (m68k/Amiga)
-
-ac3200.c:
-	io = 0		(Checks 0x1000 to 0x8fff in 0x1000 intervals)
-	irq = 0		(Read from config register)
-	(EISA probing..)
-
-apricot.c:
-	io = 0x300  (Can't be altered!)
-	irq = 10
-
-arcnet.c:
-	io = 0
-	irqnum = 0
-	shmem = 0
-	num = 0
-	DO SET THESE MANUALLY AT INSMOD!
-	(When probing, looks at the following possible addresses:
-	 Suggested ones:
-		0x300, 0x2E0, 0x2F0, 0x2D0
-	 Other ones:
-		0x200, 0x210, 0x220, 0x230, 0x240, 0x250, 0x260, 0x270,
-		0x280, 0x290, 0x2A0, 0x2B0, 0x2C0,
-		       0x310, 0x320, 0x330, 0x340, 0x350, 0x360, 0x370,
-		0x380, 0x390, 0x3A0,			  0x3E0, 0x3F0  )
-
-ariadne.c:
-	Since this is a Zorro board, it supports full autoprobing, even for
-	multiple boards. (m68k/Amiga)
-
-at1700.c:
-	io = 0x260
-	irq = 0
-	(Probes ports: 0x260, 0x280, 0x2A0, 0x240, 0x340, 0x320, 0x380, 0x300)
-
-atarilance.c:
-	Supports full autoprobing. (m68k/Atari)
-
-atp.c: *Not modularized*
-	(Probes ports: 0x378, 0x278, 0x3BC;
-	 fixed IRQs: 5 and 7			)
-
-cops.c:
-	io = 0x240
-	irq = 5
-	nodeid = 0	(AutoSelect = 0, NodeID 1-254 is hand selected.)
-	(Probes ports: 0x240, 0x340, 0x200, 0x210, 0x220, 0x230, 0x260,
-		       0x2A0, 0x300, 0x310, 0x320, 0x330, 0x350, 0x360)	
-
-de4x5.c:
-	io = 0x000b
-	irq = 10
-	is_not_dec = 0  -- For non-DEC card using DEC 21040/21041/21140 chip, set this to 1
-	(EISA, and PCI probing)
-
-de600.c:
-	de600_debug = 0
-	(On port 0x378, irq 7 -- lpt1;  compile time configurable)
-
-de620.c:
-	bnc = 0, utp = 0  <-- Force media by setting either.
-	io = 0x378	(also compile-time configurable)
-	irq = 7
-
-depca.c:
-	io = 0x200
-	irq = 7
-	(Probes ports:	ISA:  0x300, 0x200;
-			EISA: 0x0c00		)
-
-dummy.c:
-	No options
-
-e2100.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ software selected by driver)
-	mem = 0		(Override default shared memory start of 0xd0000)
-	xcvr = 0	(Use xcvr=1 to select external transceiver.)
-	(Probes ports: 0x300, 0x280, 0x380, 0x220)
-
-eepro.c:
-	io = 0x200
-	irq = 0
-	(Probes ports: 0x200, 0x240, 0x280, 0x2C0, 0x300, 0x320, 0x340, 0x360)
-
-eexpress.c:
-	io = 0x300
-	irq = 0		(IRQ value read from EEPROM)
-	(Probes ports: 0x300, 0x270, 0x320, 0x340)
-
-eql.c:
-	(No parameters)
-
-ewrk3.c:
-	io = 0x300
-	irq = 5
-	(With module no autoprobing!
-	 On EISA-bus does EISA probing.
-	 Static linkage probes ports on ISA bus:
-		0x100, 0x120, 0x140, 0x160, 0x180, 0x1A0, 0x1C0,
-		0x200, 0x220, 0x240, 0x260, 0x280, 0x2A0, 0x2C0, 0x2E0,
-		0x300,        0x340, 0x360, 0x380, 0x3A0, 0x3C0)
-
-hp-plus.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ read from configuration register)
-	(Probes ports: 0x200, 0x240, 0x280, 0x2C0, 0x300, 0x320, 0x340)
-
-hp.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ software selected by driver using autoIRQ)
-	(Probes ports: 0x300, 0x320, 0x340, 0x280, 0x2C0, 0x200, 0x240)
-
-hp100.c:
-	hp100_port = 0 (IO-base address)
-	(Does EISA-probing, if on EISA-slot;
-	 On ISA-bus probes all ports from 0x100 thru to 0x3E0
-	 in increments of 0x020)
-
-hydra.c:
-	Since this is a Zorro board, it supports full autoprobing, even for
-	multiple boards. (m68k/Amiga)
-
-ibmtr.c:
-	io = 0xa20, 0xa24 (autoprobed by default)
-	irq = 0 (driver cannot select irq - read from hardware)
-	mem = 0 (shared memory base set at 0xd0000 and not yet 
-	         able to override thru mem= parameter.)
-
-lance.c: *Not modularized*
-	(PCI, and ISA probing; "CONFIG_PCI" needed for PCI support)
-	(Probes ISA ports: 0x300, 0x320, 0x340, 0x360)
-
-loopback.c: *Static kernel component*
-
-ne.c:
-	io = 0		(Explicitly *requires* an "io=0xNNN" value)
-	irq = 0		(Tries to determine configured IRQ via autoIRQ)
-	(Probes ports: 0x300, 0x280, 0x320, 0x340, 0x360)
-
-net_init.c: *Static kernel component*
-
-ni52.c: *Not modularized*
-	(Probes ports:	0x300, 0x280, 0x360, 0x320, 0x340
-		mems:	0xD0000, 0xD2000, 0xC8000, 0xCA000,
-			0xD4000, 0xD6000, 0xD8000 )
-
-ni65.c: *Not modularized*  **16MB MEMORY BARRIER BUG**
-	(Probes ports:	0x300, 0x320, 0x340, 0x360)
-
-pi2.c:	*Not modularized* (well, NON-STANDARD modularization!)
-	Only one card supported at this time.
-	(Probes ports: 0x380, 0x300, 0x320, 0x340, 0x360, 0x3A0)
-
-plip.c:
-	io = 0
-	irq = 0		(by default, uses IRQ 5 for port at 0x3bc, IRQ 7
-			for port at 0x378, and IRQ 2 for port at 0x278)
-	(Probes ports: 0x278, 0x378, 0x3bc)
-
-ppp.c:
-	No options (ppp-2.2+ has some, this is based on non-dynamic
-	version from ppp-2.1.2d)
-
-seeq8005.c: *Not modularized*
-	(Probes ports: 0x300, 0x320, 0x340, 0x360)
-
-skeleton.c: *Skeleton*
-
-slhc.c:
-	No configuration parameters
-
-slip.c:
-	slip_maxdev = 256 (default value from SL_NRUNIT on slip.h)
-
-
-smc-ultra.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ val. read from EEPROM)
-	(Probes ports:	0x200, 0x220, 0x240, 0x280, 0x300, 0x340, 0x380)
-
-tulip.c: *Partial modularization*
-	(init-time memory allocation makes problems..)
-
-tunnel.c:
-	No insmod parameters
-
-wavelan.c:
-	io = 0x390	(Settable, but change not recommended)
-	irq = 0		(Not honoured, if changed..)
-
-wd.c:
-	io = 0		(It will complain if you don't supply an "io=0xNNN")
-	irq = 0		(IRQ val. read from EEPROM, ancient cards use autoIRQ)
-	mem = 0		(Force shared-memory on address 0xC8000, or whatever..)
-	mem_end = 0	(Force non-std. mem. size via supplying mem_end val.)
-			(eg. for 32k WD8003EBT, use mem=0xd0000 mem_end=0xd8000)
-	(Probes ports:	0x300, 0x280, 0x380, 0x240)
-
-znet.c: *Not modularized*
-	(Only one device on  Zenith Z-Note (notebook?) systems,
-	 configuration information from (EE)PROM)
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6909bec..6937ef0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -188,6 +188,7 @@ struct bond_parm_tbl arp_validate_tbl[] = {
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
+static void bond_deinit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -3681,7 +3682,7 @@ static int bond_open(struct net_device *bond_dev)
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
-		INIT_DELAYED_WORK(&bond->ad_work, bond_alb_monitor);
+		INIT_DELAYED_WORK(&bond->ad_work, bond_3ad_state_machine_handler);
 		queue_delayed_work(bond->wq, &bond->ad_work, 0);
 		/* register to receive LACPDUs */
 		bond_register_lacpdu(bond);
@@ -4449,7 +4450,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 /* De-initialize device specific data.
  * Caller must hold rtnl_lock.
  */
-void bond_deinit(struct net_device *bond_dev)
+static void bond_deinit(struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index d1ed14b..61c1b45 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -302,7 +302,6 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_de
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
-void bond_deinit(struct net_device *bond_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
 void bond_destroy_sysfs_entry(struct bonding *bond);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 57541d2..6fd95a2 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -34,6 +34,7 @@
 #include <linux/skbuff.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <asm/gpio.h>
@@ -53,12 +54,6 @@ MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 
 #define CPMAC_VERSION "0.5.0"
-/* stolen from net/ieee80211.h */
-#ifndef MAC_FMT
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
-		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
-#endif
 /* frame size + 802.1q tag */
 #define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + 4)
 #define CPMAC_QUEUES	8
@@ -211,6 +206,7 @@ struct cpmac_priv {
 	struct net_device *dev;
 	struct work_struct reset_work;
 	struct platform_device *pdev;
+	struct napi_struct napi;
 };
 
 static irqreturn_t cpmac_irq(int, void *);
@@ -362,47 +358,48 @@ static void cpmac_set_multicast_list(struct net_device *dev)
 	}
 }
 
-static struct sk_buff *cpmac_rx_one(struct net_device *dev,
-				    struct cpmac_priv *priv,
+static struct sk_buff *cpmac_rx_one(struct cpmac_priv *priv,
 				    struct cpmac_desc *desc)
 {
 	struct sk_buff *skb, *result = NULL;
 
 	if (unlikely(netif_msg_hw(priv)))
-		cpmac_dump_desc(dev, desc);
+		cpmac_dump_desc(priv->dev, desc);
 	cpmac_write(priv->regs, CPMAC_RX_ACK(0), (u32)desc->mapping);
 	if (unlikely(!desc->datalen)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING "%s: rx: spurious interrupt\n",
-			       dev->name);
+			       priv->dev->name);
 		return NULL;
 	}
 
-	skb = netdev_alloc_skb(dev, CPMAC_SKB_SIZE);
+	skb = netdev_alloc_skb(priv->dev, CPMAC_SKB_SIZE);
 	if (likely(skb)) {
 		skb_reserve(skb, 2);
 		skb_put(desc->skb, desc->datalen);
-		desc->skb->protocol = eth_type_trans(desc->skb, dev);
+		desc->skb->protocol = eth_type_trans(desc->skb, priv->dev);
 		desc->skb->ip_summed = CHECKSUM_NONE;
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += desc->datalen;
+		priv->dev->stats.rx_packets++;
+		priv->dev->stats.rx_bytes += desc->datalen;
 		result = desc->skb;
-		dma_unmap_single(&dev->dev, desc->data_mapping, CPMAC_SKB_SIZE,
-				 DMA_FROM_DEVICE);
+		dma_unmap_single(&priv->dev->dev, desc->data_mapping,
+				 CPMAC_SKB_SIZE, DMA_FROM_DEVICE);
 		desc->skb = skb;
-		desc->data_mapping = dma_map_single(&dev->dev, skb->data,
+		desc->data_mapping = dma_map_single(&priv->dev->dev, skb->data,
 						    CPMAC_SKB_SIZE,
 						    DMA_FROM_DEVICE);
 		desc->hw_data = (u32)desc->data_mapping;
 		if (unlikely(netif_msg_pktdata(priv))) {
-			printk(KERN_DEBUG "%s: received packet:\n", dev->name);
-			cpmac_dump_skb(dev, result);
+			printk(KERN_DEBUG "%s: received packet:\n",
+			       priv->dev->name);
+			cpmac_dump_skb(priv->dev, result);
 		}
 	} else {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING
-			       "%s: low on skbs, dropping packet\n", dev->name);
-		dev->stats.rx_dropped++;
+			       "%s: low on skbs, dropping packet\n",
+			       priv->dev->name);
+		priv->dev->stats.rx_dropped++;
 	}
 
 	desc->buflen = CPMAC_SKB_SIZE;
@@ -411,25 +408,25 @@ static struct sk_buff *cpmac_rx_one(struct net_device *dev,
 	return result;
 }
 
-static int cpmac_poll(struct net_device *dev, int *budget)
+static int cpmac_poll(struct napi_struct *napi, int budget)
 {
 	struct sk_buff *skb;
 	struct cpmac_desc *desc;
-	int received = 0, quota = min(dev->quota, *budget);
-	struct cpmac_priv *priv = netdev_priv(dev);
+	int received = 0;
+	struct cpmac_priv *priv = container_of(napi, struct cpmac_priv, napi);
 
 	spin_lock(&priv->rx_lock);
 	if (unlikely(!priv->rx_head)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
-			       dev->name);
-		netif_rx_complete(dev);
+			       priv->dev->name);
+		netif_rx_complete(priv->dev, napi);
 		return 0;
 	}
 
 	desc = priv->rx_head;
-	while ((received < quota) && ((desc->dataflags & CPMAC_OWN) == 0)) {
-		skb = cpmac_rx_one(dev, priv, desc);
+	while (((desc->dataflags & CPMAC_OWN) == 0) && (received < budget)) {
+		skb = cpmac_rx_one(priv, desc);
 		if (likely(skb)) {
 			netif_receive_skb(skb);
 			received++;
@@ -439,13 +436,11 @@ static int cpmac_poll(struct net_device *dev, int *budget)
 
 	priv->rx_head = desc;
 	spin_unlock(&priv->rx_lock);
-	*budget -= received;
-	dev->quota -= received;
 	if (unlikely(netif_msg_rx_status(priv)))
-		printk(KERN_DEBUG "%s: poll processed %d packets\n", dev->name,
-		       received);
+		printk(KERN_DEBUG "%s: poll processed %d packets\n",
+		       priv->dev->name, received);
 	if (desc->dataflags & CPMAC_OWN) {
-		netif_rx_complete(dev);
+		netif_rx_complete(priv->dev, napi);
 		cpmac_write(priv->regs, CPMAC_RX_PTR(0), (u32)desc->mapping);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
@@ -655,6 +650,7 @@ static void cpmac_hw_error(struct work_struct *work)
 	spin_unlock(&priv->rx_lock);
 	cpmac_clear_tx(priv->dev);
 	cpmac_hw_start(priv->dev);
+	napi_enable(&priv->napi);
 	netif_start_queue(priv->dev);
 }
 
@@ -681,8 +677,10 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 
 	if (status & MAC_INT_RX) {
 		queue = (status >> 8) & 7;
-		netif_rx_schedule(dev);
-		cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
+		if (netif_rx_schedule_prep(dev, &priv->napi)) {
+			cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
+			__netif_rx_schedule(dev, &priv->napi);
+		}
 	}
 
 	cpmac_write(priv->regs, CPMAC_MAC_EOI_VECTOR, 0);
@@ -692,6 +690,7 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 			printk(KERN_ERR "%s: hw error, resetting...\n",
 			       dev->name);
 		netif_stop_queue(dev);
+		napi_disable(&priv->napi);
 		cpmac_hw_stop(dev);
 		schedule_work(&priv->reset_work);
 		if (unlikely(netif_msg_hw(priv)))
@@ -849,6 +848,15 @@ static void cpmac_adjust_link(struct net_device *dev)
 	spin_unlock(&priv->lock);
 }
 
+static int cpmac_link_update(struct net_device *dev,
+			     struct fixed_phy_status *status)
+{
+	status->link = 1;
+	status->speed = 100;
+	status->duplex = 1;
+	return 0;
+}
+
 static int cpmac_open(struct net_device *dev)
 {
 	int i, size, res;
@@ -857,15 +865,6 @@ static int cpmac_open(struct net_device *dev)
 	struct cpmac_desc *desc;
 	struct sk_buff *skb;
 
-	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link,
-				0, PHY_INTERFACE_MODE_MII);
-	if (IS_ERR(priv->phy)) {
-		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: Could not attach to PHY\n",
-			       dev->name);
-		return PTR_ERR(priv->phy);
-	}
-
 	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
 	if (!request_mem_region(mem->start, mem->end - mem->start, dev->name)) {
 		if (netif_msg_drv(priv))
@@ -927,6 +926,7 @@ static int cpmac_open(struct net_device *dev)
 	INIT_WORK(&priv->reset_work, cpmac_hw_error);
 	cpmac_hw_start(dev);
 
+	napi_enable(&priv->napi);
 	priv->phy->state = PHY_CHANGELINK;
 	phy_start(priv->phy);
 
@@ -951,8 +951,6 @@ fail_remap:
 	release_mem_region(mem->start, mem->end - mem->start);
 
 fail_reserve:
-	phy_disconnect(priv->phy);
-
 	return res;
 }
 
@@ -965,9 +963,8 @@ static int cpmac_stop(struct net_device *dev)
 	netif_stop_queue(dev);
 
 	cancel_work_sync(&priv->reset_work);
+	napi_disable(&priv->napi);
 	phy_stop(priv->phy);
-	phy_disconnect(priv->phy);
-	priv->phy = NULL;
 
 	cpmac_hw_stop(dev);
 
@@ -1001,11 +998,13 @@ static int external_switch;
 
 static int __devinit cpmac_probe(struct platform_device *pdev)
 {
-	int rc, phy_id;
+	int rc, phy_id, i;
 	struct resource *mem;
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
+	struct fixed_info *fixed_phy;
+	DECLARE_MAC_BUF(mac);
 
 	pdata = pdev->dev.platform_data;
 
@@ -1053,21 +1052,51 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	dev->set_multicast_list = cpmac_set_multicast_list;
 	dev->tx_timeout         = cpmac_tx_timeout;
 	dev->ethtool_ops        = &cpmac_ethtool_ops;
-	dev->poll = cpmac_poll;
-	dev->weight = 64;
 	dev->features |= NETIF_F_MULTI_QUEUE;
 
+	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
+
 	spin_lock_init(&priv->lock);
 	spin_lock_init(&priv->rx_lock);
 	priv->dev = dev;
 	priv->ring_size = 64;
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
 	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
+
 	if (phy_id == 31) {
-		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT,
-			 cpmac_mii.id, phy_id);
-	} else
-		snprintf(priv->phy_name, BUS_ID_SIZE, "fixed@%d:%d", 100, 1);
+		snprintf(priv->phy_name, BUS_ID_SIZE, PHY_ID_FMT, cpmac_mii.id,
+			 phy_id);
+	} else {
+		/* Let's try to get a free fixed phy... */
+		for (i = 0; i < MAX_PHY_AMNT; i++) {
+			fixed_phy = fixed_mdio_get_phydev(i);
+			if (!fixed_phy)
+				continue;
+			if (!fixed_phy->phydev->attached_dev) {
+				strncpy(priv->phy_name,
+					fixed_phy->phydev->dev.bus_id,
+					BUS_ID_SIZE);
+				fixed_mdio_set_link_update(fixed_phy->phydev,
+							   &cpmac_link_update);
+				goto phy_found;
+			}
+		}
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: Could not find fixed PHY\n",
+			       dev->name);
+		rc = -ENODEV;
+		goto fail;
+	}
+
+phy_found:
+	priv->phy = phy_connect(dev, priv->phy_name, &cpmac_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(priv->phy)) {
+		if (netif_msg_drv(priv))
+			printk(KERN_ERR "%s: Could not attach to PHY\n",
+			       dev->name);
+		return PTR_ERR(priv->phy);
+	}
 
 	if ((rc = register_netdev(dev))) {
 		printk(KERN_ERR "cpmac: error %i registering device %s\n", rc,
@@ -1077,9 +1106,9 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	if (netif_msg_probe(priv)) {
 		printk(KERN_INFO
-		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, mac: "
-		       MAC_FMT ")\n", dev->name, (void *)mem->start, dev->irq,
-		       priv->phy_name, MAC_ARG(dev->dev_addr));
+		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, "
+		       "mac: %s)\n", dev->name, (void *)mem->start, dev->irq,
+		       priv->phy_name, print_mac(mac, dev->dev_addr));
 	}
 	return 0;
 
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index b557bb4..4b4b74e 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0078"
+#define DRV_VERSION	"EHEA_0079"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 2809c99..0a7e789 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -2329,7 +2329,7 @@ static void port_napi_disable(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps; i++)
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
 		napi_disable(&port->port_res[i].napi);
 }
 
@@ -2337,7 +2337,7 @@ static void port_napi_enable(struct ehea_port *port)
 {
 	int i;
 
-	for (i = 0; i < port->num_def_qps; i++)
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++)
 		napi_enable(&port->port_res[i].napi);
 }
 
@@ -2373,8 +2373,6 @@ static int ehea_down(struct net_device *dev)
 	ehea_drop_multicast_list(dev);
 	ehea_free_interrupts(dev);
 
-	port_napi_disable(port);
-
 	port->state = EHEA_PORT_DOWN;
 
 	ret = ehea_clean_all_portres(port);
@@ -2396,6 +2394,7 @@ static int ehea_stop(struct net_device *dev)
 	flush_scheduled_work();
 	down(&port->port_lock);
 	netif_stop_queue(dev);
+	port_napi_disable(port);
 	ret = ehea_down(dev);
 	up(&port->port_lock);
 	return ret;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 70ddf1a..92ce2e3 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5597,6 +5597,22 @@ static struct pci_device_id pci_tbl[] = {
 		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_31),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_HIGH_DMA|DEV_HAS_POWER_CNTRL|DEV_HAS_MSI|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT|DEV_HAS_CORRECT_MACADDR,
 	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_32),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_33),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_34),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
+	{	/* MCP77 Ethernet Controller */
+		PCI_DEVICE(PCI_VENDOR_ID_NVIDIA, PCI_DEVICE_ID_NVIDIA_NVENET_35),
+		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER|DEV_HAS_CHECKSUM|DEV_HAS_HIGH_DMA|DEV_HAS_MSI|DEV_HAS_POWER_CNTRL|DEV_HAS_PAUSEFRAME_TX|DEV_HAS_STATISTICS_V2|DEV_HAS_TEST_EXTENDED|DEV_HAS_MGMT_UNIT,
+	},
 	{0,},
 };
 
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 6888723..dbd23bb 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -55,6 +55,26 @@ MODULE_DESCRIPTION("IC Plus IP1000 Gigabit Ethernet Adapter Linux Driver "
 		   DrvVer);
 MODULE_LICENSE("GPL");
 
+//variable record -- index by leading revision/length
+//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
+static unsigned short DefaultPhyParam[] = {
+	// 11/12/03 IP1000A v1-3 rev=0x40
+	/*--------------------------------------------------------------------------
+	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
+				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
+				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
+	  --------------------------------------------------------------------------*/
+	// 12/17/03 IP1000A v1-4 rev=0x40
+	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	// 01/09/04 IP1000A v1-5 rev=0x41
+	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
+	    0x0000,
+	30, 0x005e, 9, 0x0700,
+	0x0000
+};
+
 static const char *ipg_brand_name[] = {
 	"IC PLUS IP1000 1000/100/10 based NIC",
 	"Sundance Technology ST2021 based NIC",
@@ -990,7 +1010,7 @@ static void ipg_nic_txcleanup(struct net_device *dev)
 }
 
 /* Provides statistical information about the IPG NIC. */
-struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
+static struct net_device_stats *ipg_nic_get_stats(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
 	void __iomem *ioaddr = sp->ioaddr;
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index e418b90..d5d092c 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -833,24 +833,4 @@ struct ipg_nic_private {
 	struct delayed_work task;
 };
 
-//variable record -- index by leading revision/length
-//Revision/Length(=N*4), Address1, Data1, Address2, Data2,...,AddressN,DataN
-unsigned short DefaultPhyParam[] = {
-	// 11/12/03 IP1000A v1-3 rev=0x40
-	/*--------------------------------------------------------------------------
-	(0x4000|(15*4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 22, 0x85bd, 24, 0xfff2,
-				 27, 0x0c10, 28, 0x0c10, 29, 0x2c10, 31, 0x0003, 23, 0x92f6,
-				 31, 0x0000, 23, 0x003d, 30, 0x00de, 20, 0x20e7,  9, 0x0700,
-	  --------------------------------------------------------------------------*/
-	// 12/17/03 IP1000A v1-4 rev=0x40
-	(0x4000 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
-	    0x0000,
-	30, 0x005e, 9, 0x0700,
-	// 01/09/04 IP1000A v1-5 rev=0x41
-	(0x4100 | (07 * 4)), 31, 0x0001, 27, 0x01e0, 31, 0x0002, 27, 0xeb8e, 31,
-	    0x0000,
-	30, 0x005e, 9, 0x0700,
-	0x0000
-};
-
 #endif				/* __LINUX_IPG_H */
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 9531171..87cde06 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -864,6 +864,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 
 	np = netdev_priv(dev);
 	netif_napi_add(dev, &np->napi, natsemi_poll, 64);
+	np->dev = dev;
 
 	np->pci_dev = pdev;
 	pci_set_drvdata(pdev, dev);
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index cd991a0..1ebe325 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -512,11 +512,19 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 	}
 	tmp = le32_to_cpu(u.init_c->max_transfer_size);
 	if (tmp < dev->hard_mtu) {
-		dev_err(&intf->dev,
-			"dev can't take %u byte packets (max %u)\n",
-			dev->hard_mtu, tmp);
-		retval = -EINVAL;
-		goto fail_and_release;
+		if (tmp <= net->hard_header_len) {
+			dev_err(&intf->dev,
+				"dev can't take %u byte packets (max %u)\n",
+				dev->hard_mtu, tmp);
+			retval = -EINVAL;
+			goto fail_and_release;
+		}
+		dev->hard_mtu = tmp;
+		net->mtu = dev->hard_mtu - net->hard_header_len;
+		dev_warn(&intf->dev,
+			 "dev can't take %u byte packets (max %u), "
+			 "adjusting MTU to %u\n",
+			 dev->hard_mtu, tmp, net->mtu);
 	}
 
 	/* REVISIT:  peripheral "alignment" request is ignored ... */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 4e10a07..e44aac8 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1236,6 +1236,10 @@
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP67_IDE       0x0560
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP73_IDE       0x056C
 #define PCI_DEVICE_ID_NVIDIA_NFORCE_MCP77_IDE       0x0759
+#define PCI_DEVICE_ID_NVIDIA_NVENET_32              0x0760
+#define PCI_DEVICE_ID_NVIDIA_NVENET_33              0x0761
+#define PCI_DEVICE_ID_NVIDIA_NVENET_34              0x0762
+#define PCI_DEVICE_ID_NVIDIA_NVENET_35              0x0763
 
 #define PCI_VENDOR_ID_IMS		0x10e0
 #define PCI_DEVICE_ID_IMS_TT128		0x9128
