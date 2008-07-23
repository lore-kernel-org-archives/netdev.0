From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCHes] pull request: WAN
Date: Wed, 23 Jul 2008 23:38:25 +0200
Message-ID: <m3d4l4s2lq.fsf@maximus.localdomain>
References: <m3ljzyc9e7.fsf@maximus.localdomain> <488653A9.50001@garzik.org>
	<m3hcags2xq.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:43977 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754557AbYGWVi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 17:38:59 -0400
In-Reply-To: <m3hcags2xq.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Wed\, 23 Jul 2008 23\:31\:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-jeff
vs your "upstream" branch:

 Documentation/DocBook/z8530book.tmpl |   38 +--
 drivers/char/pcmcia/synclink_cs.c    |    4 -
 drivers/char/synclink.c              |    4 -
 drivers/char/synclink_gt.c           |    5 -
 drivers/char/synclinkmp.c            |    4 -
 drivers/net/wan/Kconfig              |   13 +-
 drivers/net/wan/Makefile             |   11 +-
 drivers/net/wan/cosa.c               |  293 +++++++---------
 drivers/net/wan/dscc4.c              |    1 -
 drivers/net/wan/farsync.c            |    5 +-
 drivers/net/wan/farsync.h            |    6 -
 drivers/net/wan/hdlc.c               |   25 +-
 drivers/net/wan/hdlc_cisco.c         |   29 +-
 drivers/net/wan/hdlc_fr.c            |   19 +-
 drivers/net/wan/hdlc_ppp.c           |   15 +-
 drivers/net/wan/hdlc_raw.c           |   15 +-
 drivers/net/wan/hdlc_raw_eth.c       |   17 +-
 drivers/net/wan/hdlc_x25.c           |   17 +-
 drivers/net/wan/hostess_sv11.c       |  382 ++++++++------------
 drivers/net/wan/lmc/lmc.h            |   11 +-
 drivers/net/wan/lmc/lmc_debug.c      |    7 +-
 drivers/net/wan/lmc/lmc_debug.h      |    6 +-
 drivers/net/wan/lmc/lmc_ioctl.h      |    2 +-
 drivers/net/wan/lmc/lmc_main.c       |  672 +++++++++++++++-------------------
 drivers/net/wan/lmc/lmc_media.c      |   66 ++--
 drivers/net/wan/lmc/lmc_proto.c      |  146 ++------
 drivers/net/wan/lmc/lmc_proto.h      |   14 +-
 drivers/net/wan/lmc/lmc_var.h        |  360 +++++++------------
 drivers/net/wan/pc300.h              |  228 +++++-------
 drivers/net/wan/pc300_drv.c          |  146 ++++----
 drivers/net/wan/sealevel.c           |  361 +++++++-----------
 drivers/net/wan/syncppp.c            |    9 -
 drivers/net/wan/z85230.c             |  193 ++++------
 drivers/net/wan/z85230.h             |   10 +-
 include/net/syncppp.h                |    2 -
 net/wanrouter/wanmain.c              |   27 --
 36 files changed, 1245 insertions(+), 1918 deletions(-)

diff --git a/Documentation/DocBook/z8530book.tmpl b/Documentation/DocBook/z8530book.tmpl
index 42c75ba..a42a8a4 100644
--- a/Documentation/DocBook/z8530book.tmpl
+++ b/Documentation/DocBook/z8530book.tmpl
@@ -69,12 +69,6 @@
 	device to be used as both a tty interface and as a synchronous 
 	controller is a project for Linux post the 2.4 release
   </para>
-  <para>
-	The support code handles most common card configurations and
-	supports running both Cisco HDLC and Synchronous PPP. With extra
-	glue the frame relay and X.25 protocols can also be used with this
-	driver.
-  </para>
   </chapter>
   
   <chapter id="Driver_Modes">
@@ -179,35 +173,27 @@
   <para>
 	If you wish to use the network interface facilities of the driver,
 	then you need to attach a network device to each channel that is
-	present and in use. In addition to use the SyncPPP and Cisco HDLC
+	present and in use. In addition to use the generic HDLC
 	you need to follow some additional plumbing rules. They may seem 
 	complex but a look at the example hostess_sv11 driver should
 	reassure you.
   </para>
   <para>
 	The network device used for each channel should be pointed to by
-	the netdevice field of each channel. The dev-&gt; priv field of the
+	the netdevice field of each channel. The hdlc-&gt; priv field of the
 	network device points to your private data - you will need to be
-	able to find your ppp device from this. In addition to use the
-	sync ppp layer the private data must start with a void * pointer
-	to the syncppp structures.
+	able to find your private data from this.
   </para>
   <para>
 	The way most drivers approach this particular problem is to
 	create a structure holding the Z8530 device definition and
-	put that and the syncppp pointer into the private field of
-	the network device. The network device fields of the channels
-	then point back to the network devices. The ppp_device can also
-	be put in the private structure conveniently.
+	put that into the private field of the network device. The
+	network device fields of the channels then point back to the
+	network devices.
   </para>
   <para>
-	If you wish to use the synchronous ppp then you need to attach
-	the syncppp layer to the network device. You should do this before
-	you register the network device. The
-	<function>sppp_attach</function> requires that the first void *
-	pointer in your private data is pointing to an empty struct
-	ppp_device. The function fills in the initial data for the
-	ppp/hdlc layer.
+	If you wish to use the generic HDLC then you need to register
+	the HDLC device.
   </para>
   <para>
 	Before you register your network device you will also need to
@@ -314,10 +300,10 @@
 	buffer in sk_buff format and queues it for transmission. The
 	caller must provide the entire packet with the exception of the
 	bitstuffing and CRC. This is normally done by the caller via
-	the syncppp interface layer. It returns 0 if the buffer has been 
-        queued and non zero values  for queue full. If the function accepts 
-	the buffer it becomes property of the Z8530 layer and the caller 
-	should not free it. 
+	the generic HDLC interface layer. It returns 0 if the buffer has been
+	queued and non zero values for queue full. If the function accepts
+	the buffer it becomes property of the Z8530 layer and the caller
+	should not free it.
   </para>
   <para>
 	The function <function>z8530_get_stats</function> returns a pointer
diff --git a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
index b694d43..36a0afa 100644
--- a/drivers/char/pcmcia/synclink_cs.c
+++ b/drivers/char/pcmcia/synclink_cs.c
@@ -232,7 +232,6 @@ typedef struct _mgslpc_info {
 
 	/* SPPP/Cisco HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -459,13 +458,11 @@ static int ttymajor=0;
 
 static int debug_level = 0;
 static int maxframe[MAX_DEVICE_COUNT] = {0,};
-static int dosyncppp[MAX_DEVICE_COUNT] = {1,1,1,1};
 
 module_param(break_on_load, bool, 0);
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 MODULE_LICENSE("GPL");
 
@@ -2914,7 +2911,6 @@ static void mgslpc_add_device(MGSLPC_INFO *info)
 	if (info->line < MAX_DEVICE_COUNT) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	mgslpc_device_count++;
diff --git a/drivers/char/synclink.c b/drivers/char/synclink.c
index 527d220..2b9e930 100644
--- a/drivers/char/synclink.c
+++ b/drivers/char/synclink.c
@@ -304,7 +304,6 @@ struct mgsl_struct {
 
 	/* generic HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -868,7 +867,6 @@ static int irq[MAX_ISA_DEVICES];
 static int dma[MAX_ISA_DEVICES];
 static int debug_level;
 static int maxframe[MAX_TOTAL_DEVICES];
-static int dosyncppp[MAX_TOTAL_DEVICES];
 static int txdmabufs[MAX_TOTAL_DEVICES];
 static int txholdbufs[MAX_TOTAL_DEVICES];
 	
@@ -879,7 +877,6 @@ module_param_array(irq, int, NULL, 0);
 module_param_array(dma, int, NULL, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 module_param_array(txdmabufs, int, NULL, 0);
 module_param_array(txholdbufs, int, NULL, 0);
 
@@ -4257,7 +4254,6 @@ static void mgsl_add_device( struct mgsl_struct *info )
 	if (info->line < MAX_TOTAL_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 
 		if (txdmabufs[info->line]) {
 			info->num_tx_dma_buffers = txdmabufs[info->line];
diff --git a/drivers/char/synclink_gt.c b/drivers/char/synclink_gt.c
index 2c3e43b..88083b0 100644
--- a/drivers/char/synclink_gt.c
+++ b/drivers/char/synclink_gt.c
@@ -128,17 +128,14 @@ static int slgt_device_count;
 static int ttymajor;
 static int debug_level;
 static int maxframe[MAX_DEVICES];
-static int dosyncppp[MAX_DEVICES];
 
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 MODULE_PARM_DESC(ttymajor, "TTY major device number override: 0=auto assigned");
 MODULE_PARM_DESC(debug_level, "Debug syslog output: 0=disabled, 1 to 5=increasing detail");
 MODULE_PARM_DESC(maxframe, "Maximum frame size used by device (4096 to 65535)");
-MODULE_PARM_DESC(dosyncppp, "Enable synchronous net device, 0=disable 1=enable");
 
 /*
  * tty support and callbacks
@@ -348,7 +345,6 @@ struct slgt_info {
 	/* SPPP/Cisco HDLC device parts */
 
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 #if SYNCLINK_GENERIC_HDLC
 	struct net_device *netdev;
@@ -3385,7 +3381,6 @@ static void add_device(struct slgt_info *info)
 	if (info->line < MAX_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	slgt_device_count++;
diff --git a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
index 5768c41..f2edfad 100644
--- a/drivers/char/synclinkmp.c
+++ b/drivers/char/synclinkmp.c
@@ -270,7 +270,6 @@ typedef struct _synclinkmp_info {
 
 	/* SPPP/Cisco HDLC device parts */
 	int netcount;
-	int dosyncppp;
 	spinlock_t netlock;
 
 #if SYNCLINK_GENERIC_HDLC
@@ -469,13 +468,11 @@ static int ttymajor = 0;
  */
 static int debug_level = 0;
 static int maxframe[MAX_DEVICES] = {0,};
-static int dosyncppp[MAX_DEVICES] = {0,};
 
 module_param(break_on_load, bool, 0);
 module_param(ttymajor, int, 0);
 module_param(debug_level, int, 0);
 module_param_array(maxframe, int, NULL, 0);
-module_param_array(dosyncppp, int, NULL, 0);
 
 static char *driver_name = "SyncLink MultiPort driver";
 static char *driver_version = "$Revision: 4.38 $";
@@ -3751,7 +3748,6 @@ static void add_device(SLMP_INFO *info)
 	if (info->line < MAX_DEVICES) {
 		if (maxframe[info->line])
 			info->max_frame_size = maxframe[info->line];
-		info->dosyncppp = dosyncppp[info->line];
 	}
 
 	synclinkmp_device_count++;
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 846be60..766b8bf 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -25,7 +25,7 @@ if WAN
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET && HDLC
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -37,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on ISA && m && ISA_DMA_API
+	depends on ISA && m && ISA_DMA_API && HDLC
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
@@ -61,7 +61,7 @@ config COSA
 #
 config LANMEDIA
 	tristate "LanMedia Corp. SSI/V.35, T1/E1, HSSI, T3 boards"
-	depends on PCI && VIRT_TO_BUS
+	depends on PCI && VIRT_TO_BUS && HDLC
 	---help---
 	  Driver for the following Lan Media family of serial boards:
 
@@ -78,9 +78,8 @@ config LANMEDIA
 	  - LMC 5245 board connects directly to a T3 circuit saving the
 	  additional external hardware.
 
-	  To change setting such as syncPPP vs Cisco HDLC or clock source you
-	  will need lmcctl.  It is available at <ftp://ftp.lanmedia.com/>
-	  (broken link).
+	  To change setting such as clock source you will need lmcctl.
+	  It is available at <ftp://ftp.lanmedia.com/> (broken link).
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called lmc.
@@ -88,7 +87,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on ISA && m && ISA_DMA_API && INET
+	depends on ISA && m && ISA_DMA_API && INET && HDLC
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
diff --git a/drivers/net/wan/Makefile b/drivers/net/wan/Makefile
index d61fef3..1025496 100644
--- a/drivers/net/wan/Makefile
+++ b/drivers/net/wan/Makefile
@@ -21,12 +21,11 @@ pc300-y				:= pc300_drv.o
 pc300-$(CONFIG_PC300_MLPPP)	+= pc300_tty.o
 pc300-objs			:= $(pc300-y)
 
-obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	syncppp.o	hostess_sv11.o
-obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	syncppp.o	sealevel.o
-obj-$(CONFIG_COSA)		+=		syncppp.o	cosa.o
-obj-$(CONFIG_FARSYNC)		+=		syncppp.o	farsync.o
-obj-$(CONFIG_DSCC4)             +=				dscc4.o
-obj-$(CONFIG_LANMEDIA)		+=		syncppp.o
+obj-$(CONFIG_HOSTESS_SV11)	+= z85230.o	hostess_sv11.o
+obj-$(CONFIG_SEALEVEL_4021)	+= z85230.o	sealevel.o
+obj-$(CONFIG_COSA)		+= cosa.o
+obj-$(CONFIG_FARSYNC)		+= farsync.o
+obj-$(CONFIG_DSCC4)             += dscc4.o
 obj-$(CONFIG_X25_ASY)		+= x25_asy.o
 
 obj-$(CONFIG_LANMEDIA)		+= lmc/
diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 5827324..e38b7ac 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -2,6 +2,7 @@
 
 /*
  *  Copyright (C) 1995-1997  Jan "Yenya" Kasprzak <kas@fi.muni.cz>
+ *  Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -54,7 +55,7 @@
  *
  * The Linux driver (unlike the present *BSD drivers :-) can work even
  * for the COSA and SRP in one computer and allows each channel to work
- * in one of the three modes (character device, Cisco HDLC, Sync PPP).
+ * in one of the two modes (character or network device).
  *
  * AUTHOR
  *
@@ -72,12 +73,6 @@
  * The Comtrol Hostess SV11 driver by Alan Cox
  * The Sync PPP/Cisco HDLC layer (syncppp.c) ported to Linux by Alan Cox
  */
-/*
- *     5/25/1999 : Marcelo Tosatti <marcelo@conectiva.com.br>
- *             fixed a deadlock in cosa_sppp_open
- */
-
-/* ---------- Headers, macros, data structures ---------- */
 
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -86,6 +81,7 @@
 #include <linux/fs.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
@@ -93,14 +89,12 @@
 #include <linux/mutex.h>
 #include <linux/device.h>
 #include <linux/smp_lock.h>
-
-#undef COSA_SLOW_IO	/* for testing purposes only */
-
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
 
-#include <net/syncppp.h>
+#undef COSA_SLOW_IO	/* for testing purposes only */
+
 #include "cosa.h"
 
 /* Maximum length of the identification string. */
@@ -112,7 +106,6 @@
 /* Per-channel data structure */
 
 struct channel_data {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	int usage;	/* Usage count; >0 for chrdev, -1 for netdev */
 	int num;	/* Number of the channel */
 	struct cosa_data *cosa;	/* Pointer to the per-card structure */
@@ -136,10 +129,9 @@ struct channel_data {
 	wait_queue_head_t txwaitq, rxwaitq;
 	int tx_status, rx_status;
 
-	/* SPPP/HDLC device parts */
-	struct ppp_device pppdev;
+	/* generic HDLC device parts */
+	struct net_device *netdev;
 	struct sk_buff *rx_skb, *tx_skb;
-	struct net_device_stats stats;
 };
 
 /* cosa->firmware_status bits */
@@ -281,21 +273,19 @@ static int cosa_start_tx(struct channel_data *channel, char *buf, int size);
 static void cosa_kick(struct cosa_data *cosa);
 static int cosa_dma_able(struct channel_data *chan, char *buf, int data);
 
-/* SPPP/HDLC stuff */
-static void sppp_channel_init(struct channel_data *chan);
-static void sppp_channel_delete(struct channel_data *chan);
-static int cosa_sppp_open(struct net_device *d);
-static int cosa_sppp_close(struct net_device *d);
-static void cosa_sppp_timeout(struct net_device *d);
-static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *d);
-static char *sppp_setup_rx(struct channel_data *channel, int size);
-static int sppp_rx_done(struct channel_data *channel);
-static int sppp_tx_done(struct channel_data *channel, int size);
-static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
-static struct net_device_stats *cosa_net_stats(struct net_device *dev);
+/* Network device stuff */
+static int cosa_net_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity);
+static int cosa_net_open(struct net_device *d);
+static int cosa_net_close(struct net_device *d);
+static void cosa_net_timeout(struct net_device *d);
+static int cosa_net_tx(struct sk_buff *skb, struct net_device *d);
+static char *cosa_net_setup_rx(struct channel_data *channel, int size);
+static int cosa_net_rx_done(struct channel_data *channel);
+static int cosa_net_tx_done(struct channel_data *channel, int size);
+static int cosa_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 /* Character device */
-static void chardev_channel_init(struct channel_data *chan);
 static char *chrdev_setup_rx(struct channel_data *channel, int size);
 static int chrdev_rx_done(struct channel_data *channel);
 static int chrdev_tx_done(struct channel_data *channel, int size);
@@ -357,17 +347,17 @@ static void debug_status_in(struct cosa_data *cosa, int status);
 static void debug_status_out(struct cosa_data *cosa, int status);
 #endif
 
-
+static inline struct channel_data* dev_to_chan(struct net_device *dev)
+{
+	return (struct channel_data *)dev_to_hdlc(dev)->priv;
+}
+
 /* ---------- Initialization stuff ---------- */
 
 static int __init cosa_init(void)
 {
 	int i, err = 0;
 
-	printk(KERN_INFO "cosa v1.08 (c) 1997-2000 Jan Kasprzak <kas@fi.muni.cz>\n");
-#ifdef CONFIG_SMP
-	printk(KERN_INFO "cosa: SMP found. Please mail any success/failure reports to the author.\n");
-#endif
 	if (cosa_major > 0) {
 		if (register_chrdev(cosa_major, "cosa", &cosa_fops)) {
 			printk(KERN_WARNING "cosa: unable to get major %d\n",
@@ -402,7 +392,7 @@ static int __init cosa_init(void)
 	}
 	err = 0;
 	goto out;
-	
+
 out_chrdev:
 	unregister_chrdev(cosa_major, "cosa");
 out:
@@ -414,43 +404,29 @@ static void __exit cosa_exit(void)
 {
 	struct cosa_data *cosa;
 	int i;
-	printk(KERN_INFO "Unloading the cosa module\n");
 
-	for (i=0; i<nr_cards; i++)
+	for (i = 0; i < nr_cards; i++)
 		device_destroy(cosa_class, MKDEV(cosa_major, i));
 	class_destroy(cosa_class);
-	for (cosa=cosa_cards; nr_cards--; cosa++) {
+
+	for (cosa = cosa_cards; nr_cards--; cosa++) {
 		/* Clean up the per-channel data */
-		for (i=0; i<cosa->nchannels; i++) {
+		for (i = 0; i < cosa->nchannels; i++) {
 			/* Chardev driver has no alloc'd per-channel data */
-			sppp_channel_delete(cosa->chan+i);
+			unregister_hdlc_device(cosa->chan[i].netdev);
+			free_netdev(cosa->chan[i].netdev);
 		}
 		/* Clean up the per-card data */
 		kfree(cosa->chan);
 		kfree(cosa->bouncebuf);
 		free_irq(cosa->irq, cosa);
 		free_dma(cosa->dma);
-		release_region(cosa->datareg,is_8bit(cosa)?2:4);
+		release_region(cosa->datareg, is_8bit(cosa) ? 2 : 4);
 	}
 	unregister_chrdev(cosa_major, "cosa");
 }
 module_exit(cosa_exit);
 
-/*
- * This function should register all the net devices needed for the
- * single channel.
- */
-static __inline__ void channel_init(struct channel_data *chan)
-{
-	sprintf(chan->name, "cosa%dc%d", chan->cosa->num, chan->num);
-
-	/* Initialize the chardev data structures */
-	chardev_channel_init(chan);
-
-	/* Register the sppp interface */
-	sppp_channel_init(chan);
-}
-	
 static int cosa_probe(int base, int irq, int dma)
 {
 	struct cosa_data *cosa = cosa_cards+nr_cards;
@@ -576,13 +552,43 @@ static int cosa_probe(int base, int irq, int dma)
 	/* Initialize the per-channel data */
 	cosa->chan = kcalloc(cosa->nchannels, sizeof(struct channel_data), GFP_KERNEL);
 	if (!cosa->chan) {
-	        err = -ENOMEM;
+		err = -ENOMEM;
 		goto err_out3;
 	}
-	for (i=0; i<cosa->nchannels; i++) {
-		cosa->chan[i].cosa = cosa;
-		cosa->chan[i].num = i;
-		channel_init(cosa->chan+i);
+
+	for (i = 0; i < cosa->nchannels; i++) {
+		struct channel_data *chan = &cosa->chan[i];
+
+		chan->cosa = cosa;
+		chan->num = i;
+		sprintf(chan->name, "cosa%dc%d", chan->cosa->num, i);
+
+		/* Initialize the chardev data structures */
+		mutex_init(&chan->rlock);
+		init_MUTEX(&chan->wsem);
+
+		/* Register the network interface */
+		if (!(chan->netdev = alloc_hdlcdev(chan))) {
+			printk(KERN_WARNING "%s: alloc_hdlcdev failed.\n",
+			       chan->name);
+			goto err_hdlcdev;
+		}
+		dev_to_hdlc(chan->netdev)->attach = cosa_net_attach;
+		dev_to_hdlc(chan->netdev)->xmit = cosa_net_tx;
+		chan->netdev->open = cosa_net_open;
+		chan->netdev->stop = cosa_net_close;
+		chan->netdev->do_ioctl = cosa_net_ioctl;
+		chan->netdev->tx_timeout = cosa_net_timeout;
+		chan->netdev->watchdog_timeo = TX_TIMEOUT;
+		chan->netdev->base_addr = chan->cosa->datareg;
+		chan->netdev->irq = chan->cosa->irq;
+		chan->netdev->dma = chan->cosa->dma;
+		if (register_hdlc_device(chan->netdev)) {
+			printk(KERN_WARNING "%s: register_hdlc_device()"
+			       " failed.\n", chan->netdev->name);
+			free_netdev(chan->netdev);
+			goto err_hdlcdev;
+		}
 	}
 
 	printk (KERN_INFO "cosa%d: %s (%s at 0x%x irq %d dma %d), %d channels\n",
@@ -590,13 +596,20 @@ static int cosa_probe(int base, int irq, int dma)
 		cosa->datareg, cosa->irq, cosa->dma, cosa->nchannels);
 
 	return nr_cards++;
+
+err_hdlcdev:
+	while (i-- > 0) {
+		unregister_hdlc_device(cosa->chan[i].netdev);
+		free_netdev(cosa->chan[i].netdev);
+	}
+	kfree(cosa->chan);
 err_out3:
 	kfree(cosa->bouncebuf);
 err_out2:
 	free_dma(cosa->dma);
 err_out1:
 	free_irq(cosa->irq, cosa);
-err_out:	
+err_out:
 	release_region(cosa->datareg,is_8bit(cosa)?2:4);
 	printk(KERN_NOTICE "cosa%d: allocating resources failed\n",
 	       cosa->num);
@@ -604,54 +617,19 @@ err_out:
 }
 
 
-/*---------- SPPP/HDLC netdevice ---------- */
+/*---------- network device ---------- */
 
-static void cosa_setup(struct net_device *d)
+static int cosa_net_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity)
 {
-	d->open = cosa_sppp_open;
-	d->stop = cosa_sppp_close;
-	d->hard_start_xmit = cosa_sppp_tx;
-	d->do_ioctl = cosa_sppp_ioctl;
-	d->get_stats = cosa_net_stats;
-	d->tx_timeout = cosa_sppp_timeout;
-	d->watchdog_timeo = TX_TIMEOUT;
-}
-
-static void sppp_channel_init(struct channel_data *chan)
-{
-	struct net_device *d;
-	chan->if_ptr = &chan->pppdev;
-	d = alloc_netdev(0, chan->name, cosa_setup);
-	if (!d) {
-		printk(KERN_WARNING "%s: alloc_netdev failed.\n", chan->name);
-		return;
-	}
-	chan->pppdev.dev = d;
-	d->base_addr = chan->cosa->datareg;
-	d->irq = chan->cosa->irq;
-	d->dma = chan->cosa->dma;
-	d->ml_priv = chan;
-	sppp_attach(&chan->pppdev);
-	if (register_netdev(d)) {
-		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
-		sppp_detach(d);
-		free_netdev(d);
-		chan->pppdev.dev = NULL;
-		return;
-	}
-}
-
-static void sppp_channel_delete(struct channel_data *chan)
-{
-	unregister_netdev(chan->pppdev.dev);
-	sppp_detach(chan->pppdev.dev);
-	free_netdev(chan->pppdev.dev);
-	chan->pppdev.dev = NULL;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-static int cosa_sppp_open(struct net_device *d)
+static int cosa_net_open(struct net_device *dev)
 {
-	struct channel_data *chan = d->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 	int err;
 	unsigned long flags;
 
@@ -662,36 +640,35 @@ static int cosa_sppp_open(struct net_device *d)
 	}
 	spin_lock_irqsave(&chan->cosa->lock, flags);
 	if (chan->usage != 0) {
-		printk(KERN_WARNING "%s: sppp_open called with usage count %d\n",
-			chan->name, chan->usage);
+		printk(KERN_WARNING "%s: cosa_net_open called with usage count"
+		       " %d\n", chan->name, chan->usage);
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return -EBUSY;
 	}
-	chan->setup_rx = sppp_setup_rx;
-	chan->tx_done = sppp_tx_done;
-	chan->rx_done = sppp_rx_done;
-	chan->usage=-1;
+	chan->setup_rx = cosa_net_setup_rx;
+	chan->tx_done = cosa_net_tx_done;
+	chan->rx_done = cosa_net_rx_done;
+	chan->usage = -1;
 	chan->cosa->usage++;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 
-	err = sppp_open(d);
+	err = hdlc_open(dev);
 	if (err) {
 		spin_lock_irqsave(&chan->cosa->lock, flags);
-		chan->usage=0;
+		chan->usage = 0;
 		chan->cosa->usage--;
-		
 		spin_unlock_irqrestore(&chan->cosa->lock, flags);
 		return err;
 	}
 
-	netif_start_queue(d);
+	netif_start_queue(dev);
 	cosa_enable_rx(chan);
 	return 0;
 }
 
-static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
+static int cosa_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct channel_data *chan = dev->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 
 	netif_stop_queue(dev);
 
@@ -700,16 +677,16 @@ static int cosa_sppp_tx(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static void cosa_sppp_timeout(struct net_device *dev)
+static void cosa_net_timeout(struct net_device *dev)
 {
-	struct channel_data *chan = dev->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 
 	if (test_bit(RXBIT, &chan->cosa->rxtx)) {
-		chan->stats.rx_errors++;
-		chan->stats.rx_missed_errors++;
+		chan->netdev->stats.rx_errors++;
+		chan->netdev->stats.rx_missed_errors++;
 	} else {
-		chan->stats.tx_errors++;
-		chan->stats.tx_aborted_errors++;
+		chan->netdev->stats.tx_errors++;
+		chan->netdev->stats.tx_aborted_errors++;
 	}
 	cosa_kick(chan->cosa);
 	if (chan->tx_skb) {
@@ -719,13 +696,13 @@ static void cosa_sppp_timeout(struct net_device *dev)
 	netif_wake_queue(dev);
 }
 
-static int cosa_sppp_close(struct net_device *d)
+static int cosa_net_close(struct net_device *dev)
 {
-	struct channel_data *chan = d->ml_priv;
+	struct channel_data *chan = dev_to_chan(dev);
 	unsigned long flags;
 
-	netif_stop_queue(d);
-	sppp_close(d);
+	netif_stop_queue(dev);
+	hdlc_close(dev);
 	cosa_disable_rx(chan);
 	spin_lock_irqsave(&chan->cosa->lock, flags);
 	if (chan->rx_skb) {
@@ -736,13 +713,13 @@ static int cosa_sppp_close(struct net_device *d)
 		kfree_skb(chan->tx_skb);
 		chan->tx_skb = NULL;
 	}
-	chan->usage=0;
+	chan->usage = 0;
 	chan->cosa->usage--;
 	spin_unlock_irqrestore(&chan->cosa->lock, flags);
 	return 0;
 }
 
-static char *sppp_setup_rx(struct channel_data *chan, int size)
+static char *cosa_net_setup_rx(struct channel_data *chan, int size)
 {
 	/*
 	 * We can safely fall back to non-dma-able memory, because we have
@@ -754,66 +731,53 @@ static char *sppp_setup_rx(struct channel_data *chan, int size)
 	if (chan->rx_skb == NULL) {
 		printk(KERN_NOTICE "%s: Memory squeeze, dropping packet\n",
 			chan->name);
-		chan->stats.rx_dropped++;
+		chan->netdev->stats.rx_dropped++;
 		return NULL;
 	}
-	chan->pppdev.dev->trans_start = jiffies;
+	chan->netdev->trans_start = jiffies;
 	return skb_put(chan->rx_skb, size);
 }
 
-static int sppp_rx_done(struct channel_data *chan)
+static int cosa_net_rx_done(struct channel_data *chan)
 {
 	if (!chan->rx_skb) {
 		printk(KERN_WARNING "%s: rx_done with empty skb!\n",
 			chan->name);
-		chan->stats.rx_errors++;
-		chan->stats.rx_frame_errors++;
+		chan->netdev->stats.rx_errors++;
+		chan->netdev->stats.rx_frame_errors++;
 		return 0;
 	}
-	chan->rx_skb->protocol = htons(ETH_P_WAN_PPP);
-	chan->rx_skb->dev = chan->pppdev.dev;
+	chan->rx_skb->protocol = hdlc_type_trans(chan->rx_skb, chan->netdev);
+	chan->rx_skb->dev = chan->netdev;
 	skb_reset_mac_header(chan->rx_skb);
-	chan->stats.rx_packets++;
-	chan->stats.rx_bytes += chan->cosa->rxsize;
+	chan->netdev->stats.rx_packets++;
+	chan->netdev->stats.rx_bytes += chan->cosa->rxsize;
 	netif_rx(chan->rx_skb);
 	chan->rx_skb = NULL;
-	chan->pppdev.dev->last_rx = jiffies;
+	chan->netdev->last_rx = jiffies;
 	return 0;
 }
 
 /* ARGSUSED */
-static int sppp_tx_done(struct channel_data *chan, int size)
+static int cosa_net_tx_done(struct channel_data *chan, int size)
 {
 	if (!chan->tx_skb) {
 		printk(KERN_WARNING "%s: tx_done with empty skb!\n",
 			chan->name);
-		chan->stats.tx_errors++;
-		chan->stats.tx_aborted_errors++;
+		chan->netdev->stats.tx_errors++;
+		chan->netdev->stats.tx_aborted_errors++;
 		return 1;
 	}
 	dev_kfree_skb_irq(chan->tx_skb);
 	chan->tx_skb = NULL;
-	chan->stats.tx_packets++;
-	chan->stats.tx_bytes += size;
-	netif_wake_queue(chan->pppdev.dev);
+	chan->netdev->stats.tx_packets++;
+	chan->netdev->stats.tx_bytes += size;
+	netif_wake_queue(chan->netdev);
 	return 1;
 }
 
-static struct net_device_stats *cosa_net_stats(struct net_device *dev)
-{
-	struct channel_data *chan = dev->ml_priv;
-	return &chan->stats;
-}
-
-
 /*---------- Character device ---------- */
 
-static void chardev_channel_init(struct channel_data *chan)
-{
-	mutex_init(&chan->rlock);
-	init_MUTEX(&chan->wsem);
-}
-
 static ssize_t cosa_read(struct file *file,
 	char __user *buf, size_t count, loff_t *ppos)
 {
@@ -1223,16 +1187,15 @@ static int cosa_ioctl_common(struct cosa_data *cosa,
 	return -ENOIOCTLCMD;
 }
 
-static int cosa_sppp_ioctl(struct net_device *dev, struct ifreq *ifr,
-	int cmd)
+static int cosa_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int rv;
-	struct channel_data *chan = dev->ml_priv;
-	rv = cosa_ioctl_common(chan->cosa, chan, cmd, (unsigned long)ifr->ifr_data);
-	if (rv == -ENOIOCTLCMD) {
-		return sppp_do_ioctl(dev, ifr, cmd);
-	}
-	return rv;
+	struct channel_data *chan = dev_to_chan(dev);
+	rv = cosa_ioctl_common(chan->cosa, chan, cmd,
+			       (unsigned long)ifr->ifr_data);
+	if (rv != -ENOIOCTLCMD)
+		return rv;
+	return hdlc_ioctl(dev, ifr, cmd);
 }
 
 static int cosa_chardev_ioctl(struct inode *inode, struct file *file,
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 50ef5b4..f5d55ad 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -103,7 +103,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
-#include <net/syncppp.h>
 #include <linux/hdlc.h>
 #include <linux/mutex.h>
 
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 754f008..9557ad0 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -47,10 +47,7 @@ MODULE_LICENSE("GPL");
 /*      Default parameters for the link
  */
 #define FST_TX_QUEUE_LEN        100	/* At 8Mbps a longer queue length is
-					 * useful, the syncppp module forces
-					 * this down assuming a slower line I
-					 * guess.
-					 */
+					 * useful */
 #define FST_TXQ_DEPTH           16	/* This one is for the buffering
 					 * of frames on the way down to the card
 					 * so that we can keep the card busy
diff --git a/drivers/net/wan/farsync.h b/drivers/net/wan/farsync.h
index d871daf..6b27e7c 100644
--- a/drivers/net/wan/farsync.h
+++ b/drivers/net/wan/farsync.h
@@ -54,9 +54,6 @@
 
 
 /*      Ioctl call command values
- *
- *      The first three private ioctls are used by the sync-PPP module,
- *      allowing a little room for expansion we start our numbering at 10.
  */
 #define FSTWRITE        (SIOCDEVPRIVATE+10)
 #define FSTCPURESET     (SIOCDEVPRIVATE+11)
@@ -202,9 +199,6 @@ struct fstioc_info {
 #define J1              7
 
 /* "proto" */
-#define FST_HDLC        1               /* Cisco compatible HDLC */
-#define FST_PPP         2               /* Sync PPP */
-#define FST_MONITOR     3               /* Monitor only (raw packet reception) */
 #define FST_RAW         4               /* Two way raw packets */
 #define FST_GEN_HDLC    5               /* Using "Generic HDLC" module */
 
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index e3a5364..1f2a140 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -22,20 +22,19 @@
  * - proto->start() and stop() are called with spin_lock_irq held.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/notifier.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/notifier.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 #include <net/net_namespace.h>
 
 
@@ -109,7 +108,7 @@ static int hdlc_device_event(struct notifier_block *this, unsigned long event,
 
 	if (dev->get_stats != hdlc_get_stats)
 		return NOTIFY_DONE; /* not an HDLC device */
- 
+
 	if (event != NETDEV_CHANGE)
 		return NOTIFY_DONE; /* Only interrested in carrier changes */
 
@@ -357,7 +356,7 @@ static struct packet_type hdlc_packet_type = {
 
 
 static struct notifier_block hdlc_notifier = {
-        .notifier_call = hdlc_device_event,
+	.notifier_call = hdlc_device_event,
 };
 
 
@@ -367,8 +366,8 @@ static int __init hdlc_module_init(void)
 
 	printk(KERN_INFO "%s\n", version);
 	if ((result = register_netdevice_notifier(&hdlc_notifier)) != 0)
-                return result;
-        dev_add_pack(&hdlc_packet_type);
+		return result;
+	dev_add_pack(&hdlc_packet_type);
 	return 0;
 }
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 849819c..44e64b1 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -9,19 +9,18 @@
  * as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 
 #undef DEBUG_HARD_HEADER
 
@@ -68,9 +67,9 @@ struct cisco_state {
 static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr);
 
 
-static inline struct cisco_state * state(hdlc_device *hdlc)
+static inline struct cisco_state* state(hdlc_device *hdlc)
 {
-	return(struct cisco_state *)(hdlc->state);
+	return (struct cisco_state *)hdlc->state;
 }
 
 
@@ -172,7 +171,7 @@ static int cisco_rx(struct sk_buff *skb)
 	    data->address != CISCO_UNICAST)
 		goto rx_error;
 
-	switch(ntohs(data->protocol)) {
+	switch (ntohs(data->protocol)) {
 	case CISCO_SYS_INFO:
 		/* Packet is not needed, drop it. */
 		dev_kfree_skb_any(skb);
@@ -336,7 +335,7 @@ static struct hdlc_proto proto = {
 static const struct header_ops cisco_header_ops = {
 	.create = cisco_hard_header,
 };
- 
+
 static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 {
 	cisco_proto __user *cisco_s = ifr->ifr_settings.ifs_ifsu.cisco;
@@ -359,10 +358,10 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		return 0;
 
 	case IF_PROTO_CISCO:
-		if(!capable(CAP_NET_ADMIN))
+		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if(dev->flags & IFF_UP)
+		if (dev->flags & IFF_UP)
 			return -EBUSY;
 
 		if (copy_from_user(&new_settings, cisco_s, size))
@@ -372,7 +371,7 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		    new_settings.timeout < 2)
 			return -EINVAL;
 
-		result=hdlc->attach(dev, ENCODING_NRZ,PARITY_CRC16_PR1_CCITT);
+		result = hdlc->attach(dev, ENCODING_NRZ,PARITY_CRC16_PR1_CCITT);
 		if (result)
 			return result;
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 62e93da..d3d5055 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -33,20 +33,19 @@
 
 */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/etherdevice.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 
 #undef DEBUG_PKT
 #undef DEBUG_ECN
@@ -96,7 +95,7 @@ typedef struct {
 	unsigned ea1:	1;
 	unsigned cr:	1;
 	unsigned dlcih:	6;
-  
+
 	unsigned ea2:	1;
 	unsigned de:	1;
 	unsigned becn:	1;
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 0030833..4efe9e6 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -9,19 +9,18 @@
  * as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 #include <net/syncppp.h>
 
 struct ppp_state {
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index bbbb819..8612311 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -9,19 +9,18 @@
  * as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 
 
 static int raw_ioctl(struct net_device *dev, struct ifreq *ifr);
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 26dee60..a13fc32 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -9,20 +9,19 @@
  * as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
+#include <linux/inetdevice.h>
 #include <linux/init.h>
-#include <linux/skbuff.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/pkt_sched.h>
-#include <linux/inetdevice.h>
-#include <linux/lapb.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/etherdevice.h>
-#include <linux/hdlc.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 
 static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr);
 
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index e808720..8b7e5d2 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -9,20 +9,19 @@
  * as published by the Free Software Foundation.
  */
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
-#include <linux/poll.h>
 #include <linux/errno.h>
+#include <linux/hdlc.h>
 #include <linux/if_arp.h>
-#include <linux/init.h>
-#include <linux/skbuff.h>
-#include <linux/pkt_sched.h>
 #include <linux/inetdevice.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
 #include <linux/lapb.h>
+#include <linux/module.h>
+#include <linux/pkt_sched.h>
+#include <linux/poll.h>
 #include <linux/rtnetlink.h>
-#include <linux/hdlc.h>
-
+#include <linux/skbuff.h>
+#include <linux/slab.h>
 #include <net/x25device.h>
 
 static int x25_ioctl(struct net_device *dev, struct ifreq *ifr);
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index f3065d3..e299313 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -16,6 +16,8 @@
  *	touching control registers.
  *
  *	Port B isnt wired (why - beats me)
+ *
+ *	Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  */
 
 #include <linux/module.h>
@@ -26,6 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <net/arp.h>
 
@@ -33,34 +36,31 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
-#include <net/syncppp.h>
 #include "z85230.h"
 
 static int dma;
 
-struct sv11_device
-{
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
-	struct z8530_dev sync;
-	struct ppp_device netdev;
-};
-
 /*
  *	Network driver support routines
  */
 
+static inline struct z8530_dev* dev_to_sv(struct net_device *dev)
+{
+	return (struct z8530_dev *)dev_to_hdlc(dev)->priv;
+}
+
 /*
- *	Frame receive. Simple for our card as we do sync ppp and there
+ *	Frame receive. Simple for our card as we do HDLC and there
  *	is no funny garbage involved
  */
- 
+
 static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 {
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
-	skb_trim(skb, skb->len-2);
-	skb->protocol=__constant_htons(ETH_P_WAN_PPP);
+	skb_trim(skb, skb->len - 2);
+	skb->protocol = hdlc_type_trans(skb, c->netdevice);
 	skb_reset_mac_header(skb);
-	skb->dev=c->netdevice;
+	skb->dev = c->netdevice;
 	/*
 	 *	Send it to the PPP layer. We don't have time to process
 	 *	it right now.
@@ -68,56 +68,51 @@ static void hostess_input(struct z8530_channel *c, struct sk_buff *skb)
 	netif_rx(skb);
 	c->netdevice->last_rx = jiffies;
 }
- 
+
 /*
  *	We've been placed in the UP state
- */ 
- 
+ */
+
 static int hostess_open(struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
+	struct z8530_dev *sv11 = dev_to_sv(d);
 	int err = -1;
-	
+
 	/*
 	 *	Link layer up
 	 */
-	switch(dma)
-	{
+	switch (dma) {
 		case 0:
-			err=z8530_sync_open(d, &sv11->sync.chanA);
+			err = z8530_sync_open(d, &sv11->chanA);
 			break;
 		case 1:
-			err=z8530_sync_dma_open(d, &sv11->sync.chanA);
+			err = z8530_sync_dma_open(d, &sv11->chanA);
 			break;
 		case 2:
-			err=z8530_sync_txdma_open(d, &sv11->sync.chanA);
+			err = z8530_sync_txdma_open(d, &sv11->chanA);
 			break;
 	}
-	
-	if(err)
+
+	if (err)
 		return err;
-	/*
-	 *	Begin PPP
-	 */
-	err=sppp_open(d);
-	if(err)
-	{
-		switch(dma)
-		{
+
+	err = hdlc_open(d);
+	if (err) {
+		switch (dma) {
 			case 0:
-				z8530_sync_close(d, &sv11->sync.chanA);
+				z8530_sync_close(d, &sv11->chanA);
 				break;
 			case 1:
-				z8530_sync_dma_close(d, &sv11->sync.chanA);
+				z8530_sync_dma_close(d, &sv11->chanA);
 				break;
 			case 2:
-				z8530_sync_txdma_close(d, &sv11->sync.chanA);
+				z8530_sync_txdma_close(d, &sv11->chanA);
 				break;
-		}				
+		}
 		return err;
 	}
-	sv11->sync.chanA.rx_function=hostess_input;
-	
+	sv11->chanA.rx_function = hostess_input;
+
 	/*
 	 *	Go go go
 	 */
@@ -128,30 +123,24 @@ static int hostess_open(struct net_device *d)
 
 static int hostess_close(struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
+	struct z8530_dev *sv11 = dev_to_sv(d);
 	/*
 	 *	Discard new frames
 	 */
-	sv11->sync.chanA.rx_function=z8530_null_rx;
-	/*
-	 *	PPP off
-	 */
-	sppp_close(d);
-	/*
-	 *	Link layer down
-	 */
+	sv11->chanA.rx_function = z8530_null_rx;
+
+	hdlc_close(d);
 	netif_stop_queue(d);
-		
-	switch(dma)
-	{
+
+	switch (dma) {
 		case 0:
-			z8530_sync_close(d, &sv11->sync.chanA);
+			z8530_sync_close(d, &sv11->chanA);
 			break;
 		case 1:
-			z8530_sync_dma_close(d, &sv11->sync.chanA);
+			z8530_sync_dma_close(d, &sv11->chanA);
 			break;
 		case 2:
-			z8530_sync_txdma_close(d, &sv11->sync.chanA);
+			z8530_sync_txdma_close(d, &sv11->chanA);
 			break;
 	}
 	return 0;
@@ -159,232 +148,174 @@ static int hostess_close(struct net_device *d)
 
 static int hostess_ioctl(struct net_device *d, struct ifreq *ifr, int cmd)
 {
-	/* struct sv11_device *sv11=d->ml_priv;
-	   z8530_ioctl(d,&sv11->sync.chanA,ifr,cmd) */
-	return sppp_do_ioctl(d, ifr,cmd);
-}
-
-static struct net_device_stats *hostess_get_stats(struct net_device *d)
-{
-	struct sv11_device *sv11=d->ml_priv;
-	if(sv11)
-		return z8530_get_stats(&sv11->sync.chanA);
-	else
-		return NULL;
+	/* struct z8530_dev *sv11=dev_to_sv(d);
+	   z8530_ioctl(d,&sv11->chanA,ifr,cmd) */
+	return hdlc_ioctl(d, ifr, cmd);
 }
 
 /*
- *	Passed PPP frames, fire them downwind.
+ *	Passed network frames, fire them downwind.
  */
- 
+
 static int hostess_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct sv11_device *sv11=d->ml_priv;
-	return z8530_queue_xmit(&sv11->sync.chanA, skb);
+	return z8530_queue_xmit(&dev_to_sv(d)->chanA, skb);
 }
 
-static int hostess_neigh_setup(struct neighbour *n)
+static int hostess_attach(struct net_device *dev, unsigned short encoding,
+			  unsigned short parity)
 {
-	if (n->nud_state == NUD_NONE) {
-		n->ops = &arp_broken_ops;
-		n->output = n->ops->output;
-	}
-	return 0;
-}
-
-static int hostess_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
-{
-	if (p->tbl->family == AF_INET) {
-		p->neigh_setup = hostess_neigh_setup;
-		p->ucast_probes = 0;
-		p->mcast_probes = 0;
-	}
-	return 0;
-}
-
-static void sv11_setup(struct net_device *dev)
-{	
-	dev->open = hostess_open;
-	dev->stop = hostess_close;
-	dev->hard_start_xmit = hostess_queue_xmit;
-	dev->get_stats = hostess_get_stats;
-	dev->do_ioctl = hostess_ioctl;
-	dev->neigh_setup = hostess_neigh_setup_dev;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
 /*
  *	Description block for a Comtrol Hostess SV11 card
  */
- 
-static struct sv11_device *sv11_init(int iobase, int irq)
+
+static struct z8530_dev *sv11_init(int iobase, int irq)
 {
-	struct z8530_dev *dev;
-	struct sv11_device *sv;
-	
+	struct z8530_dev *sv;
+	struct net_device *netdev;
 	/*
 	 *	Get the needed I/O space
 	 */
-	 
-	if(!request_region(iobase, 8, "Comtrol SV11"))
-	{	
-		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n", iobase);
+
+	if (!request_region(iobase, 8, "Comtrol SV11")) {
+		printk(KERN_WARNING "hostess: I/O 0x%X already in use.\n",
+		       iobase);
 		return NULL;
 	}
-	
-	sv = kzalloc(sizeof(struct sv11_device), GFP_KERNEL);
-	if(!sv)
-		goto fail3;
-			
-	sv->if_ptr=&sv->netdev;
-	
-	sv->netdev.dev = alloc_netdev(0, "hdlc%d", sv11_setup);
-	if(!sv->netdev.dev)
-		goto fail2;
-
-	dev=&sv->sync;
-	
+
+	sv = kzalloc(sizeof(struct z8530_dev), GFP_KERNEL);
+	if (!sv)
+		goto err_kzalloc;
+
 	/*
 	 *	Stuff in the I/O addressing
 	 */
-	 
-	dev->active = 0;
-	
-	dev->chanA.ctrlio=iobase+1;
-	dev->chanA.dataio=iobase+3;
-	dev->chanB.ctrlio=-1;
-	dev->chanB.dataio=-1;
-	dev->chanA.irqs=&z8530_nop;
-	dev->chanB.irqs=&z8530_nop;
-	
-	outb(0, iobase+4);		/* DMA off */
-	
+
+	sv->active = 0;
+
+	sv->chanA.ctrlio = iobase + 1;
+	sv->chanA.dataio = iobase + 3;
+	sv->chanB.ctrlio = -1;
+	sv->chanB.dataio = -1;
+	sv->chanA.irqs = &z8530_nop;
+	sv->chanB.irqs = &z8530_nop;
+
+	outb(0, iobase + 4);		/* DMA off */
+
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
-	   
-	if(request_irq(irq, &z8530_interrupt, IRQF_DISABLED, "Hostess SV11", dev)<0)
-	{
+
+	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+			"Hostess SV11", sv) < 0) {
 		printk(KERN_WARNING "hostess: IRQ %d already in use.\n", irq);
-		goto fail1;
+		goto err_irq;
 	}
-	
-	dev->irq=irq;
-	dev->chanA.private=sv;
-	dev->chanA.netdevice=sv->netdev.dev;
-	dev->chanA.dev=dev;
-	dev->chanB.dev=dev;
-	
-	if(dma)
-	{
+
+	sv->irq = irq;
+	sv->chanA.private = sv;
+	sv->chanA.dev = sv;
+	sv->chanB.dev = sv;
+
+	if (dma) {
 		/*
 		 *	You can have DMA off or 1 and 3 thats the lot
 		 *	on the Comtrol.
 		 */
-		dev->chanA.txdma=3;
-		dev->chanA.rxdma=1;
-		outb(0x03|0x08, iobase+4);		/* DMA on */
-		if(request_dma(dev->chanA.txdma, "Hostess SV/11 (TX)")!=0)
-			goto fail;
-			
-		if(dma==1)
-		{
-			if(request_dma(dev->chanA.rxdma, "Hostess SV/11 (RX)")!=0)
-				goto dmafail;
-		}
+		sv->chanA.txdma = 3;
+		sv->chanA.rxdma = 1;
+		outb(0x03 | 0x08, iobase + 4);		/* DMA on */
+		if (request_dma(sv->chanA.txdma, "Hostess SV/11 (TX)"))
+			goto err_txdma;
+
+		if (dma == 1)
+			if (request_dma(sv->chanA.rxdma, "Hostess SV/11 (RX)"))
+				goto err_rxdma;
 	}
 
 	/* Kill our private IRQ line the hostess can end up chattering
 	   until the configuration is set */
 	disable_irq(irq);
-		
+
 	/*
 	 *	Begin normal initialise
 	 */
-	 
-	if(z8530_init(dev)!=0)
-	{
+
+	if (z8530_init(sv)) {
 		printk(KERN_ERR "Z8530 series device not found.\n");
 		enable_irq(irq);
-		goto dmafail2;
+		goto free_dma;
 	}
-	z8530_channel_load(&dev->chanB, z8530_dead_port);
-	if(dev->type==Z85C30)
-		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream);
+	z8530_channel_load(&sv->chanB, z8530_dead_port);
+	if (sv->type == Z85C30)
+		z8530_channel_load(&sv->chanA, z8530_hdlc_kilostream);
 	else
-		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream_85230);
-	
+		z8530_channel_load(&sv->chanA, z8530_hdlc_kilostream_85230);
+
 	enable_irq(irq);
-	
 
 	/*
 	 *	Now we can take the IRQ
 	 */
-	if(dev_alloc_name(dev->chanA.netdevice,"hdlc%d")>=0)
-	{
-		struct net_device *d=dev->chanA.netdevice;
 
-		/* 
-		 *	Initialise the PPP components
-		 */
-		d->ml_priv = sv;
-		sppp_attach(&sv->netdev);
-		
-		/*
-		 *	Local fields
-		 */	
-		
-		d->base_addr = iobase;
-		d->irq = irq;
-		
-		if(register_netdev(d))
-		{
-			printk(KERN_ERR "%s: unable to register device.\n",
-				d->name);
-			sppp_detach(d);
-			goto dmafail2;
-		}
+	sv->chanA.netdevice = netdev = alloc_hdlcdev(sv);
+	if (!netdev)
+		goto free_dma;
 
-		z8530_describe(dev, "I/O", iobase);
-		dev->active=1;
-		return sv;	
+	dev_to_hdlc(netdev)->attach = hostess_attach;
+	dev_to_hdlc(netdev)->xmit = hostess_queue_xmit;
+	netdev->open = hostess_open;
+	netdev->stop = hostess_close;
+	netdev->do_ioctl = hostess_ioctl;
+	netdev->base_addr = iobase;
+	netdev->irq = irq;
+
+	if (register_hdlc_device(netdev)) {
+		printk(KERN_ERR "hostess: unable to register HDLC device.\n");
+		free_netdev(netdev);
+		goto free_dma;
 	}
-dmafail2:
-	if(dma==1)
-		free_dma(dev->chanA.rxdma);
-dmafail:
-	if(dma)
-		free_dma(dev->chanA.txdma);
-fail:
-	free_irq(irq, dev);
-fail1:
-	free_netdev(sv->netdev.dev);
-fail2:
+
+	z8530_describe(sv, "I/O", iobase);
+	sv->active = 1;
+	return sv;
+
+free_dma:
+	if (dma == 1)
+		free_dma(sv->chanA.rxdma);
+err_rxdma:
+	if (dma)
+		free_dma(sv->chanA.txdma);
+err_txdma:
+	free_irq(irq, sv);
+err_irq:
 	kfree(sv);
-fail3:
-	release_region(iobase,8);
+err_kzalloc:
+	release_region(iobase, 8);
 	return NULL;
 }
 
-static void sv11_shutdown(struct sv11_device *dev)
+static void sv11_shutdown(struct z8530_dev *dev)
 {
-	sppp_detach(dev->netdev.dev);
-	unregister_netdev(dev->netdev.dev);
-	z8530_shutdown(&dev->sync);
-	free_irq(dev->sync.irq, dev);
-	if(dma)
-	{
-		if(dma==1)
-			free_dma(dev->sync.chanA.rxdma);
-		free_dma(dev->sync.chanA.txdma);
+	unregister_hdlc_device(dev->chanA.netdevice);
+	z8530_shutdown(dev);
+	free_irq(dev->irq, dev);
+	if (dma) {
+		if (dma == 1)
+			free_dma(dev->chanA.rxdma);
+		free_dma(dev->chanA.txdma);
 	}
-	release_region(dev->sync.chanA.ctrlio-1, 8);
-	free_netdev(dev->netdev.dev);
+	release_region(dev->chanA.ctrlio - 1, 8);
+	free_netdev(dev->chanA.netdevice);
 	kfree(dev);
 }
 
-#ifdef MODULE
-
-static int io=0x200;
-static int irq=9;
+static int io = 0x200;
+static int irq = 9;
 
 module_param(io, int, 0);
 MODULE_PARM_DESC(io, "The I/O base of the Comtrol Hostess SV11 card");
@@ -397,22 +328,17 @@ MODULE_AUTHOR("Alan Cox");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Modular driver for the Comtrol Hostess SV11");
 
-static struct sv11_device *sv11_unit;
+static struct z8530_dev *sv11_unit;
 
 int init_module(void)
 {
-	printk(KERN_INFO "SV-11 Z85230 Synchronous Driver v 0.03.\n");
-	printk(KERN_INFO "(c) Copyright 2001, Red Hat Inc.\n");	
-	if((sv11_unit=sv11_init(io,irq))==NULL)
+	if ((sv11_unit = sv11_init(io, irq)) == NULL)
 		return -ENODEV;
 	return 0;
 }
 
 void cleanup_module(void)
 {
-	if(sv11_unit)
+	if (sv11_unit)
 		sv11_shutdown(sv11_unit);
 }
-
-#endif
-
diff --git a/drivers/net/wan/lmc/lmc.h b/drivers/net/wan/lmc/lmc.h
index 882e58c..4ced7ac 100644
--- a/drivers/net/wan/lmc/lmc.h
+++ b/drivers/net/wan/lmc/lmc.h
@@ -11,12 +11,12 @@ unsigned lmc_mii_readreg(lmc_softc_t * const sc, unsigned
       			  devaddr, unsigned regno);
 void lmc_mii_writereg(lmc_softc_t * const sc, unsigned devaddr,
 			       unsigned regno, unsigned data);
-void lmc_led_on(lmc_softc_t * const, u_int32_t);
-void lmc_led_off(lmc_softc_t * const, u_int32_t);
+void lmc_led_on(lmc_softc_t * const, u32);
+void lmc_led_off(lmc_softc_t * const, u32);
 unsigned lmc_mii_readreg(lmc_softc_t * const, unsigned, unsigned);
 void lmc_mii_writereg(lmc_softc_t * const, unsigned, unsigned, unsigned);
-void lmc_gpio_mkinput(lmc_softc_t * const sc, u_int32_t bits);
-void lmc_gpio_mkoutput(lmc_softc_t * const sc, u_int32_t bits);
+void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits);
+void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits);
 
 int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 
@@ -26,8 +26,7 @@ extern lmc_media_t lmc_t1_media;
 extern lmc_media_t lmc_hssi_media;
 
 #ifdef _DBG_EVENTLOG
-static void lmcEventLog( u_int32_t EventNum, u_int32_t arg2, u_int32_t arg3 );
+static void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
 #endif
 
 #endif
-
diff --git a/drivers/net/wan/lmc/lmc_debug.c b/drivers/net/wan/lmc/lmc_debug.c
index 3b94352..15049d7 100644
--- a/drivers/net/wan/lmc/lmc_debug.c
+++ b/drivers/net/wan/lmc/lmc_debug.c
@@ -1,4 +1,3 @@
-
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
@@ -48,10 +47,10 @@ void lmcConsoleLog(char *type, unsigned char *ucData, int iLen)
 #endif
 
 #ifdef DEBUG
-u_int32_t lmcEventLogIndex = 0;
-u_int32_t lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
+u32 lmcEventLogIndex;
+u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
 
-void lmcEventLog (u_int32_t EventNum, u_int32_t arg2, u_int32_t arg3)
+void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3)
 {
   lmcEventLogBuf[lmcEventLogIndex++] = EventNum;
   lmcEventLogBuf[lmcEventLogIndex++] = arg2;
diff --git a/drivers/net/wan/lmc/lmc_debug.h b/drivers/net/wan/lmc/lmc_debug.h
index cf35638..2d46f12 100644
--- a/drivers/net/wan/lmc/lmc_debug.h
+++ b/drivers/net/wan/lmc/lmc_debug.h
@@ -38,15 +38,15 @@
 
 
 #ifdef DEBUG
-extern u_int32_t lmcEventLogIndex;
-extern u_int32_t lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
+extern u32 lmcEventLogIndex;
+extern u32 lmcEventLogBuf[LMC_EVENTLOGSIZE * LMC_EVENTLOGARGS];
 #define LMC_EVENT_LOG(x, y, z) lmcEventLog((x), (y), (z))
 #else
 #define LMC_EVENT_LOG(x,y,z)
 #endif /* end ifdef _DBG_EVENTLOG */
 
 void lmcConsoleLog(char *type, unsigned char *ucData, int iLen);
-void lmcEventLog (u_int32_t EventNum, u_int32_t arg2, u_int32_t arg3);
+void lmcEventLog(u32 EventNum, u32 arg2, u32 arg3);
 void lmc_trace(struct net_device *dev, char *msg);
 
 #endif
diff --git a/drivers/net/wan/lmc/lmc_ioctl.h b/drivers/net/wan/lmc/lmc_ioctl.h
index 57dd861..72fb113 100644
--- a/drivers/net/wan/lmc/lmc_ioctl.h
+++ b/drivers/net/wan/lmc/lmc_ioctl.h
@@ -61,7 +61,7 @@
 /*
  * IFTYPE defines
  */
-#define LMC_PPP         1               /* use sppp interface */
+#define LMC_PPP         1               /* use generic HDLC interface */
 #define LMC_NET         2               /* use direct net interface */
 #define LMC_RAW         3               /* use direct net interface */
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 62133ce..f80640f 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1,6 +1,7 @@
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
+  * Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
   *
   * This code is written by:
   * Andrew Stanley-Jones (asj@cban.com)
@@ -36,8 +37,6 @@
   *
   */
 
-/* $Id: lmc_main.c,v 1.36 2000/04/11 05:25:25 asj Exp $ */
-
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/string.h>
@@ -49,6 +48,7 @@
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/init.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
@@ -57,9 +57,6 @@
 #include <linux/skbuff.h>
 #include <linux/inet.h>
 #include <linux/bitops.h>
-
-#include <net/syncppp.h>
-
 #include <asm/processor.h>             /* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -78,8 +75,6 @@
 #include "lmc_debug.h"
 #include "lmc_proto.h"
 
-static int lmc_first_load = 0;
-
 static int LMC_PKT_BUF_SZ = 1542;
 
 static struct pci_device_id lmc_pci_tbl[] = {
@@ -91,11 +86,10 @@ static struct pci_device_id lmc_pci_tbl[] = {
 };
 
 MODULE_DEVICE_TABLE(pci, lmc_pci_tbl);
-MODULE_LICENSE("GPL");
+MODULE_LICENSE("GPL v2");
 
 
 static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static int lmc_rx (struct net_device *dev);
 static int lmc_open(struct net_device *dev);
 static int lmc_close(struct net_device *dev);
@@ -114,20 +108,14 @@ static void lmc_driver_timeout(struct net_device *dev);
  * linux reserves 16 device specific IOCTLs.  We call them
  * LMCIOC* to control various bits of our world.
  */
-int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
+int lmc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     lmc_ctl_t ctl;
-    int ret;
-    u_int16_t regVal;
+    int ret = -EOPNOTSUPP;
+    u16 regVal;
     unsigned long flags;
 
-    struct sppp *sp;
-
-    ret = -EOPNOTSUPP;
-
-    sc = dev->priv;
-
     lmc_trace(dev, "lmc_ioctl in");
 
     /*
@@ -149,7 +137,6 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
         break;
 
     case LMCIOCSINFO: /*fold01*/
-        sp = &((struct ppp_device *) dev)->sppp;
         if (!capable(CAP_NET_ADMIN)) {
             ret = -EPERM;
             break;
@@ -175,25 +162,20 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		sc->TxDescriptControlInit &= ~LMC_TDES_ADD_CRC_DISABLE;
         }
 
-        if (ctl.keepalive_onoff == LMC_CTL_OFF)
-            sp->pp_flags &= ~PP_KEEPALIVE;	/* Turn off */
-        else
-            sp->pp_flags |= PP_KEEPALIVE;	/* Turn on */
-
         ret = 0;
         break;
 
     case LMCIOCIFTYPE: /*fold01*/
         {
-            u_int16_t	old_type = sc->if_type;
-            u_int16_t	new_type;
+	    u16 old_type = sc->if_type;
+	    u16	new_type;
 
 	    if (!capable(CAP_NET_ADMIN)) {
 		ret = -EPERM;
 		break;
 	    }
 
-	    if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u_int16_t))) {
+	    if (copy_from_user(&new_type, ifr->ifr_data, sizeof(u16))) {
 		ret = -EFAULT;
 		break;
 	    }
@@ -206,15 +188,11 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
             }
             
             lmc_proto_close(sc);
-            lmc_proto_detach(sc);
 
             sc->if_type = new_type;
-//            lmc_proto_init(sc);
             lmc_proto_attach(sc);
-            lmc_proto_open(sc);
-
-	    ret = 0 ;
-	    break ;
+	    ret = lmc_proto_open(sc);
+	    break;
 	}
 
     case LMCIOCGETXINFO: /*fold01*/
@@ -241,51 +219,53 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 
         break;
 
-    case LMCIOCGETLMCSTATS: /*fold01*/
-        if (sc->lmc_cardtype == LMC_CARDTYPE_T1){
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_FERR_LSB);
-            sc->stats.framingBitErrorCount +=
-                lmc_mii_readreg (sc, 0, 18) & 0xff;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_FERR_MSB);
-            sc->stats.framingBitErrorCount +=
-                (lmc_mii_readreg (sc, 0, 18) & 0xff) << 8;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_LCV_LSB);
-            sc->stats.lineCodeViolationCount +=
-                lmc_mii_readreg (sc, 0, 18) & 0xff;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_LCV_MSB);
-            sc->stats.lineCodeViolationCount +=
-                (lmc_mii_readreg (sc, 0, 18) & 0xff) << 8;
-            lmc_mii_writereg (sc, 0, 17, T1FRAMER_AERR);
-            regVal = lmc_mii_readreg (sc, 0, 18) & 0xff;
-
-            sc->stats.lossOfFrameCount +=
-                (regVal & T1FRAMER_LOF_MASK) >> 4;
-            sc->stats.changeOfFrameAlignmentCount +=
-                (regVal & T1FRAMER_COFA_MASK) >> 2;
-            sc->stats.severelyErroredFrameCount +=
-                regVal & T1FRAMER_SEF_MASK;
-        }
-
-        if (copy_to_user(ifr->ifr_data, &sc->stats,
-                         sizeof (struct lmc_statistics)))
-		ret = -EFAULT;
-	else
-		ret = 0;
-        break;
+    case LMCIOCGETLMCSTATS:
+	    if (sc->lmc_cardtype == LMC_CARDTYPE_T1) {
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
+		    sc->extra_stats.framingBitErrorCount +=
+			    lmc_mii_readreg(sc, 0, 18) & 0xff;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_MSB);
+		    sc->extra_stats.framingBitErrorCount +=
+			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_LSB);
+		    sc->extra_stats.lineCodeViolationCount +=
+			    lmc_mii_readreg(sc, 0, 18) & 0xff;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_LCV_MSB);
+		    sc->extra_stats.lineCodeViolationCount +=
+			    (lmc_mii_readreg(sc, 0, 18) & 0xff) << 8;
+		    lmc_mii_writereg(sc, 0, 17, T1FRAMER_AERR);
+		    regVal = lmc_mii_readreg(sc, 0, 18) & 0xff;
+
+		    sc->extra_stats.lossOfFrameCount +=
+			    (regVal & T1FRAMER_LOF_MASK) >> 4;
+		    sc->extra_stats.changeOfFrameAlignmentCount +=
+			    (regVal & T1FRAMER_COFA_MASK) >> 2;
+		    sc->extra_stats.severelyErroredFrameCount +=
+			    regVal & T1FRAMER_SEF_MASK;
+	    }
+	    if (copy_to_user(ifr->ifr_data, &sc->lmc_device->stats,
+			     sizeof(sc->lmc_device->stats)) ||
+		copy_to_user(ifr->ifr_data + sizeof(sc->lmc_device->stats),
+			     &sc->extra_stats, sizeof(sc->extra_stats)))
+		    ret = -EFAULT;
+	    else
+		    ret = 0;
+	    break;
 
-    case LMCIOCCLEARLMCSTATS: /*fold01*/
-        if (!capable(CAP_NET_ADMIN)){
-            ret = -EPERM;
-            break;
-        }
+    case LMCIOCCLEARLMCSTATS:
+	    if (!capable(CAP_NET_ADMIN)) {
+		    ret = -EPERM;
+		    break;
+	    }
 
-        memset (&sc->stats, 0, sizeof (struct lmc_statistics));
-        sc->stats.check = STATCHECK;
-        sc->stats.version_size = (DRIVER_VERSION << 16) +
-            sizeof (struct lmc_statistics);
-        sc->stats.lmc_cardtype = sc->lmc_cardtype;
-        ret = 0;
-        break;
+	    memset(&sc->lmc_device->stats, 0, sizeof(sc->lmc_device->stats));
+	    memset(&sc->extra_stats, 0, sizeof(sc->extra_stats));
+	    sc->extra_stats.check = STATCHECK;
+	    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
+		    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+	    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
+	    ret = 0;
+	    break;
 
     case LMCIOCSETCIRCUIT: /*fold01*/
         if (!capable(CAP_NET_ADMIN)){
@@ -330,7 +310,8 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 		ret = -EFAULT;
 		break;
 	}
-        if (copy_to_user(ifr->ifr_data + sizeof (u32), lmcEventLogBuf, sizeof (lmcEventLogBuf)))
+	if (copy_to_user(ifr->ifr_data + sizeof(u32), lmcEventLogBuf,
+			 sizeof(lmcEventLogBuf)))
 		ret = -EFAULT;
 	else
 		ret = 0;
@@ -641,14 +622,12 @@ int lmc_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd) /*fold00*/
 /* the watchdog process that cruises around */
 static void lmc_watchdog (unsigned long data) /*fold00*/
 {
-    struct net_device *dev = (struct net_device *) data;
-    lmc_softc_t *sc;
+    struct net_device *dev = (struct net_device *)data;
+    lmc_softc_t *sc = dev_to_sc(dev);
     int link_status;
-    u_int32_t ticks;
+    u32 ticks;
     unsigned long flags;
 
-    sc = dev->priv;
-
     lmc_trace(dev, "lmc_watchdog in");
 
     spin_lock_irqsave(&sc->lmc_lock, flags);
@@ -677,22 +656,22 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
      * check for a transmit interrupt timeout
      * Has the packet xmt vs xmt serviced threshold been exceeded */
     if (sc->lmc_taint_tx == sc->lastlmc_taint_tx &&
-        sc->stats.tx_packets > sc->lasttx_packets &&
-        sc->tx_TimeoutInd == 0)
+	sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	sc->tx_TimeoutInd == 0)
     {
 
         /* wait for the watchdog to come around again */
         sc->tx_TimeoutInd = 1;
     }
     else if (sc->lmc_taint_tx == sc->lastlmc_taint_tx &&
-             sc->stats.tx_packets > sc->lasttx_packets &&
-             sc->tx_TimeoutInd)
+	     sc->lmc_device->stats.tx_packets > sc->lasttx_packets &&
+	     sc->tx_TimeoutInd)
     {
 
         LMC_EVENT_LOG(LMC_EVENT_XMTINTTMO, LMC_CSR_READ (sc, csr_status), 0);
 
         sc->tx_TimeoutDisplay = 1;
-        sc->stats.tx_TimeoutCnt++;
+	sc->extra_stats.tx_TimeoutCnt++;
 
         /* DEC chip is stuck, hit it with a RESET!!!! */
         lmc_running_reset (dev);
@@ -712,13 +691,11 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
         /* reset the transmit timeout detection flag */
         sc->tx_TimeoutInd = 0;
         sc->lastlmc_taint_tx = sc->lmc_taint_tx;
-        sc->lasttx_packets = sc->stats.tx_packets;
-    }
-    else
-    {
+	sc->lasttx_packets = sc->lmc_device->stats.tx_packets;
+    } else {
         sc->tx_TimeoutInd = 0;
         sc->lastlmc_taint_tx = sc->lmc_taint_tx;
-        sc->lasttx_packets = sc->stats.tx_packets;
+	sc->lasttx_packets = sc->lmc_device->stats.tx_packets;
     }
 
     /* --- end time out check ----------------------------------- */
@@ -748,19 +725,7 @@ static void lmc_watchdog (unsigned long data) /*fold00*/
          sc->last_link_status = 1;
          /* lmc_reset (sc); Again why reset??? */
 
-         /* Inform the world that link protocol is back up. */
 	 netif_carrier_on(dev);
-
-         /* Now we have to tell the syncppp that we had an outage
-          * and that it should deal.  Calling sppp_reopen here
-          * should do the trick, but we may have to call sppp_close
-          * when the link goes down, and call sppp_open here.
-          * Subject to more testing.
-          * --bbraun
-          */
-
-         lmc_proto_reopen(sc);
-
      }
 
     /* Call media specific watchdog functions */
@@ -816,114 +781,93 @@ kick_timer:
 
 }
 
-static void lmc_setup(struct net_device * const dev) /*fold00*/
+static int lmc_attach(struct net_device *dev, unsigned short encoding,
+		      unsigned short parity)
 {
-    lmc_trace(dev, "lmc_setup in");
-
-    dev->type = ARPHRD_HDLC;
-    dev->hard_start_xmit = lmc_start_xmit;
-    dev->open = lmc_open;
-    dev->stop = lmc_close;
-    dev->get_stats = lmc_get_stats;
-    dev->do_ioctl = lmc_ioctl;
-    dev->tx_timeout = lmc_driver_timeout;
-    dev->watchdog_timeo = (HZ); /* 1 second */
-    
-    lmc_trace(dev, "lmc_setup out");
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-
 static int __devinit lmc_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
-    struct net_device *dev;
-    lmc_softc_t *sc;
-    u16 subdevice;
-    u_int16_t AdapModelNum;
-    int err = -ENOMEM;
-    static int cards_found;
-#ifndef GCOM
-    /* We name by type not by vendor */
-    static const char lmcname[] = "hdlc%d";
-#else
-    /* 
-     * GCOM uses LMC vendor name so that clients can know which card
-     * to attach to.
-     */
-    static const char lmcname[] = "lmc%d";
-#endif
-
-
-    /*
-     * Allocate our own device structure
-     */
-    dev = alloc_netdev(sizeof(lmc_softc_t), lmcname, lmc_setup);
-    if (!dev) {
-        printk (KERN_ERR "lmc:alloc_netdev for device failed\n");
-	goto out1;
-    }
- 
-    lmc_trace(dev, "lmc_init_one in");
-
-    err = pci_enable_device(pdev);
-    if (err) {
-	    printk(KERN_ERR "lmc: pci enable failed:%d\n", err);
-	    goto out2;
-    }
-    
-    if (pci_request_regions(pdev, "lmc")) {
-	    printk(KERN_ERR "lmc: pci_request_region failed\n");
-	    err = -EIO;
-	    goto out3;
-    }
-
-    pci_set_drvdata(pdev, dev);
-
-    if(lmc_first_load == 0){
-        printk(KERN_INFO "Lan Media Corporation WAN Driver Version %d.%d.%d\n",
-	       DRIVER_MAJOR_VERSION, DRIVER_MINOR_VERSION,DRIVER_SUB_VERSION);
-        lmc_first_load = 1;
-    }
-    
-    sc = dev->priv;
-    sc->lmc_device = dev;
-    sc->name = dev->name;
-
-    /* Initialize the sppp layer */
-    /* An ioctl can cause a subsequent detach for raw frame interface */
-    dev->ml_priv = sc;
-    sc->if_type = LMC_PPP;
-    sc->check = 0xBEAFCAFE;
-    dev->base_addr = pci_resource_start(pdev, 0);
-    dev->irq = pdev->irq;
-
-    SET_NETDEV_DEV(dev, &pdev->dev);
-
-    /*
-     * This will get the protocol layer ready and do any 1 time init's
-     * Must have a valid sc and dev structure
-     */
-    lmc_proto_init(sc);
-
-    lmc_proto_attach(sc);
+	lmc_softc_t *sc;
+	struct net_device *dev;
+	u16 subdevice;
+	u16 AdapModelNum;
+	int err;
+	static int cards_found;
+
+	/* lmc_trace(dev, "lmc_init_one in"); */
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		printk(KERN_ERR "lmc: pci enable failed: %d\n", err);
+		return err;
+	}
 
-    /*
-     * Why were we changing this???
-     dev->tx_queue_len = 100;
-     */
+	err = pci_request_regions(pdev, "lmc");
+	if (err) {
+		printk(KERN_ERR "lmc: pci_request_region failed\n");
+		goto err_req_io;
+	}
 
-    /* Init the spin lock so can call it latter */
+	/*
+	 * Allocate our own device structure
+	 */
+	sc = kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
+	if (!sc) {
+		err = -ENOMEM;
+		goto err_kzalloc;
+	}
 
-    spin_lock_init(&sc->lmc_lock);
-    pci_set_master(pdev);
+	dev = alloc_hdlcdev(sc);
+	if (!dev) {
+		printk(KERN_ERR "lmc:alloc_netdev for device failed\n");
+		goto err_hdlcdev;
+	}
 
-    printk ("%s: detected at %lx, irq %d\n", dev->name,
-	    dev->base_addr, dev->irq);
 
-    if (register_netdev (dev) != 0) {
-        printk (KERN_ERR "%s: register_netdev failed.\n", dev->name);
-	goto out4;
-    }
+	dev->type = ARPHRD_HDLC;
+	dev_to_hdlc(dev)->xmit = lmc_start_xmit;
+	dev_to_hdlc(dev)->attach = lmc_attach;
+	dev->open = lmc_open;
+	dev->stop = lmc_close;
+	dev->get_stats = lmc_get_stats;
+	dev->do_ioctl = lmc_ioctl;
+	dev->tx_timeout = lmc_driver_timeout;
+	dev->watchdog_timeo = HZ; /* 1 second */
+	dev->tx_queue_len = 100;
+	sc->lmc_device = dev;
+	sc->name = dev->name;
+	sc->if_type = LMC_PPP;
+	sc->check = 0xBEAFCAFE;
+	dev->base_addr = pci_resource_start(pdev, 0);
+	dev->irq = pdev->irq;
+	pci_set_drvdata(pdev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	/*
+	 * This will get the protocol layer ready and do any 1 time init's
+	 * Must have a valid sc and dev structure
+	 */
+	lmc_proto_attach(sc);
+
+	/* Init the spin lock so can call it latter */
+
+	spin_lock_init(&sc->lmc_lock);
+	pci_set_master(pdev);
+
+	printk(KERN_INFO "%s: detected at %lx, irq %d\n", dev->name,
+	       dev->base_addr, dev->irq);
+
+	err = register_hdlc_device(dev);
+	if (err) {
+		printk(KERN_ERR "%s: register_netdev failed.\n", dev->name);
+		free_netdev(dev);
+		goto err_hdlcdev;
+	}
 
     sc->lmc_cardtype = LMC_CARDTYPE_UNKNOWN;
     sc->lmc_timing = LMC_CTL_CLOCK_SOURCE_EXT;
@@ -939,27 +883,27 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
 
     switch (subdevice) {
     case PCI_DEVICE_ID_LMC_HSSI:
-        printk ("%s: LMC HSSI\n", dev->name);
+	printk(KERN_INFO "%s: LMC HSSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_HSSI;
         sc->lmc_media = &lmc_hssi_media;
         break;
     case PCI_DEVICE_ID_LMC_DS3:
-        printk ("%s: LMC DS3\n", dev->name);
+	printk(KERN_INFO "%s: LMC DS3\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_DS3;
         sc->lmc_media = &lmc_ds3_media;
         break;
     case PCI_DEVICE_ID_LMC_SSI:
-        printk ("%s: LMC SSI\n", dev->name);
+	printk(KERN_INFO "%s: LMC SSI\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_SSI;
         sc->lmc_media = &lmc_ssi_media;
         break;
     case PCI_DEVICE_ID_LMC_T1:
-        printk ("%s: LMC T1\n", dev->name);
+	printk(KERN_INFO "%s: LMC T1\n", dev->name);
         sc->lmc_cardtype = LMC_CARDTYPE_T1;
         sc->lmc_media = &lmc_t1_media;
         break;
     default:
-        printk (KERN_WARNING "%s: LMC UNKOWN CARD!\n", dev->name);
+	printk(KERN_WARNING "%s: LMC UNKOWN CARD!\n", dev->name);
         break;
     }
 
@@ -977,32 +921,28 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
      */
     AdapModelNum = (lmc_mii_readreg (sc, 0, 3) & 0x3f0) >> 4;
 
-    if ((AdapModelNum == LMC_ADAP_T1
-         && subdevice == PCI_DEVICE_ID_LMC_T1) ||	/* detect LMC1200 */
-        (AdapModelNum == LMC_ADAP_SSI
-         && subdevice == PCI_DEVICE_ID_LMC_SSI) ||	/* detect LMC1000 */
-        (AdapModelNum == LMC_ADAP_DS3
-         && subdevice == PCI_DEVICE_ID_LMC_DS3) ||	/* detect LMC5245 */
-        (AdapModelNum == LMC_ADAP_HSSI
-         && subdevice == PCI_DEVICE_ID_LMC_HSSI))
-    {				/* detect LMC5200 */
+    if ((AdapModelNum != LMC_ADAP_T1 || /* detect LMC1200 */
+	 subdevice != PCI_DEVICE_ID_LMC_T1) &&
+	(AdapModelNum != LMC_ADAP_SSI || /* detect LMC1000 */
+	 subdevice != PCI_DEVICE_ID_LMC_SSI) &&
+	(AdapModelNum != LMC_ADAP_DS3 || /* detect LMC5245 */
+	 subdevice != PCI_DEVICE_ID_LMC_DS3) &&
+	(AdapModelNum != LMC_ADAP_HSSI || /* detect LMC5200 */
+	 subdevice != PCI_DEVICE_ID_LMC_HSSI))
+	    printk(KERN_WARNING "%s: Model number (%d) miscompare for PCI"
+		   " Subsystem ID = 0x%04x\n",
+		   dev->name, AdapModelNum, subdevice);
 
-    }
-    else {
-        printk ("%s: Model number (%d) miscompare for PCI Subsystem ID = 0x%04x\n",
-                dev->name, AdapModelNum, subdevice);
-//        return (NULL);
-    }
     /*
      * reset clock
      */
     LMC_CSR_WRITE (sc, csr_gp_timer, 0xFFFFFFFFUL);
 
     sc->board_idx = cards_found++;
-    sc->stats.check = STATCHECK;
-    sc->stats.version_size = (DRIVER_VERSION << 16) +
-        sizeof (struct lmc_statistics);
-    sc->stats.lmc_cardtype = sc->lmc_cardtype;
+    sc->extra_stats.check = STATCHECK;
+    sc->extra_stats.version_size = (DRIVER_VERSION << 16) +
+	    sizeof(sc->lmc_device->stats) + sizeof(sc->extra_stats);
+    sc->extra_stats.lmc_cardtype = sc->lmc_cardtype;
 
     sc->lmc_ok = 0;
     sc->last_link_status = 0;
@@ -1010,58 +950,51 @@ static int __devinit lmc_init_one(struct pci_dev *pdev,
     lmc_trace(dev, "lmc_init_one out");
     return 0;
 
- out4:
-    lmc_proto_detach(sc);
- out3:
-    if (pdev) {
-	    pci_release_regions(pdev);
-	    pci_set_drvdata(pdev, NULL);
-    }
- out2:
-    free_netdev(dev);
- out1:
-    return err;
+err_hdlcdev:
+	pci_set_drvdata(pdev, NULL);
+	kfree(sc);
+err_kzalloc:
+	pci_release_regions(pdev);
+err_req_io:
+	pci_disable_device(pdev);
+	return err;
 }
 
 /*
  * Called from pci when removing module.
  */
-static void __devexit lmc_remove_one (struct pci_dev *pdev)
+static void __devexit lmc_remove_one(struct pci_dev *pdev)
 {
-    struct net_device *dev = pci_get_drvdata(pdev);
-    
-    if (dev) {
-	    lmc_softc_t *sc = dev->priv;
-	    
-	    printk("%s: removing...\n", dev->name);
-	    lmc_proto_detach(sc);
-	    unregister_netdev(dev);
-	    free_netdev(dev);
-	    pci_release_regions(pdev);
-	    pci_disable_device(pdev);
-	    pci_set_drvdata(pdev, NULL);
-    }
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (dev) {
+		printk(KERN_DEBUG "%s: removing...\n", dev->name);
+		unregister_hdlc_device(dev);
+		free_netdev(dev);
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
+		pci_set_drvdata(pdev, NULL);
+	}
 }
 
 /* After this is called, packets can be sent.
  * Does not initialize the addresses
  */
-static int lmc_open (struct net_device *dev) /*fold00*/
+static int lmc_open(struct net_device *dev)
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
+    int err;
 
     lmc_trace(dev, "lmc_open in");
 
     lmc_led_on(sc, LMC_DS3_LED0);
 
-    lmc_dec_reset (sc);
-    lmc_reset (sc);
-
-    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ (sc, csr_status), 0);
-    LMC_EVENT_LOG(LMC_EVENT_RESET2,
-                  lmc_mii_readreg (sc, 0, 16),
-                  lmc_mii_readreg (sc, 0, 17));
+    lmc_dec_reset(sc);
+    lmc_reset(sc);
 
+    LMC_EVENT_LOG(LMC_EVENT_RESET1, LMC_CSR_READ(sc, csr_status), 0);
+    LMC_EVENT_LOG(LMC_EVENT_RESET2, lmc_mii_readreg(sc, 0, 16),
+		  lmc_mii_readreg(sc, 0, 17));
 
     if (sc->lmc_ok){
         lmc_trace(dev, "lmc_open lmc_ok out");
@@ -1106,14 +1039,14 @@ static int lmc_open (struct net_device *dev) /*fold00*/
 
     /* dev->flags |= IFF_UP; */
 
-    lmc_proto_open(sc);
+    if ((err = lmc_proto_open(sc)) != 0)
+	    return err;
 
     dev->do_ioctl = lmc_ioctl;
 
 
     netif_start_queue(dev);
-    
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     /*
      * select what interrupts we want to get
@@ -1165,8 +1098,7 @@ static int lmc_open (struct net_device *dev) /*fold00*/
 
 static void lmc_running_reset (struct net_device *dev) /*fold00*/
 {
-
-    lmc_softc_t *sc = (lmc_softc_t *) dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
 
     lmc_trace(dev, "lmc_runnig_reset in");
 
@@ -1184,7 +1116,7 @@ static void lmc_running_reset (struct net_device *dev) /*fold00*/
     netif_wake_queue(dev);
 
     sc->lmc_txfull = 0;
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     sc->lmc_intrmask = TULIP_DEFAULT_INTR_MASK;
     LMC_CSR_WRITE (sc, csr_intr, sc->lmc_intrmask);
@@ -1200,14 +1132,13 @@ static void lmc_running_reset (struct net_device *dev) /*fold00*/
  * This disables the timer for the watchdog and keepalives,
  * and disables the irq for dev.
  */
-static int lmc_close (struct net_device *dev) /*fold00*/
+static int lmc_close(struct net_device *dev)
 {
     /* not calling release_region() as we should */
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
 
     lmc_trace(dev, "lmc_close in");
-    
-    sc = dev->priv;
+
     sc->lmc_ok = 0;
     sc->lmc_media->set_link_status (sc, 0);
     del_timer (&sc->timer);
@@ -1215,7 +1146,7 @@ static int lmc_close (struct net_device *dev) /*fold00*/
     lmc_ifdown (dev);
 
     lmc_trace(dev, "lmc_close out");
-    
+
     return 0;
 }
 
@@ -1223,16 +1154,16 @@ static int lmc_close (struct net_device *dev) /*fold00*/
 /* When the interface goes down, this is called */
 static int lmc_ifdown (struct net_device *dev) /*fold00*/
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr6;
     int i;
 
     lmc_trace(dev, "lmc_ifdown in");
-    
+
     /* Don't let anything else go on right now */
     //    dev->start = 0;
     netif_stop_queue(dev);
-    sc->stats.tx_tbusy1++ ;
+    sc->extra_stats.tx_tbusy1++;
 
     /* stop interrupts */
     /* Clear the interrupt mask */
@@ -1244,8 +1175,8 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
     csr6 &= ~LMC_DEC_SR;		/* Turn off the Receive bit */
     LMC_CSR_WRITE (sc, csr_command, csr6);
 
-    sc->stats.rx_missed_errors +=
-        LMC_CSR_READ (sc, csr_missed_frames) & 0xffff;
+    sc->lmc_device->stats.rx_missed_errors +=
+	    LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
 
     /* release the interrupt */
     if(sc->got_irq == 1){
@@ -1276,7 +1207,7 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
     lmc_led_off (sc, LMC_MII16_LED_ALL);
 
     netif_wake_queue(dev);
-    sc->stats.tx_tbusy0++ ;
+    sc->extra_stats.tx_tbusy0++;
 
     lmc_trace(dev, "lmc_ifdown out");
 
@@ -1289,7 +1220,7 @@ static int lmc_ifdown (struct net_device *dev) /*fold00*/
 static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 {
     struct net_device *dev = (struct net_device *) dev_instance;
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr;
     int i;
     s32 stat;
@@ -1300,8 +1231,6 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 
     lmc_trace(dev, "lmc_interrupt in");
 
-    sc = dev->priv;
-    
     spin_lock(&sc->lmc_lock);
 
     /*
@@ -1354,7 +1283,7 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
 
 	    int		n_compl = 0 ;
             /* reset the transmit timeout detection flag -baz */
-            sc->stats.tx_NoCompleteCnt = 0;
+	    sc->extra_stats.tx_NoCompleteCnt = 0;
 
             badtx = sc->lmc_taint_tx;
             i = badtx % LMC_TXDESCS;
@@ -1378,27 +1307,25 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
                 if (sc->lmc_txq[i] == NULL)
                     continue;
 
-                /*
-                 * Check the total error summary to look for any errors
-                 */
-                if (stat & 0x8000) {
-                    sc->stats.tx_errors++;
-                    if (stat & 0x4104)
-                        sc->stats.tx_aborted_errors++;
-                    if (stat & 0x0C00)
-                        sc->stats.tx_carrier_errors++;
-                    if (stat & 0x0200)
-                        sc->stats.tx_window_errors++;
-                    if (stat & 0x0002)
-                        sc->stats.tx_fifo_errors++;
-                }
-                else {
-                    
-                    sc->stats.tx_bytes += sc->lmc_txring[i].length & 0x7ff;
-                    
-                    sc->stats.tx_packets++;
+		/*
+		 * Check the total error summary to look for any errors
+		 */
+		if (stat & 0x8000) {
+			sc->lmc_device->stats.tx_errors++;
+			if (stat & 0x4104)
+				sc->lmc_device->stats.tx_aborted_errors++;
+			if (stat & 0x0C00)
+				sc->lmc_device->stats.tx_carrier_errors++;
+			if (stat & 0x0200)
+				sc->lmc_device->stats.tx_window_errors++;
+			if (stat & 0x0002)
+				sc->lmc_device->stats.tx_fifo_errors++;
+		} else {
+			sc->lmc_device->stats.tx_bytes += sc->lmc_txring[i].length & 0x7ff;
+
+			sc->lmc_device->stats.tx_packets++;
                 }
-                
+
                 //                dev_kfree_skb(sc->lmc_txq[i]);
                 dev_kfree_skb_irq(sc->lmc_txq[i]);
                 sc->lmc_txq[i] = NULL;
@@ -1415,13 +1342,13 @@ static irqreturn_t lmc_interrupt (int irq, void *dev_instance) /*fold00*/
             LMC_EVENT_LOG(LMC_EVENT_TBUSY0, n_compl, 0);
             sc->lmc_txfull = 0;
             netif_wake_queue(dev);
-            sc->stats.tx_tbusy0++ ;
+	    sc->extra_stats.tx_tbusy0++;
 
 
 #ifdef DEBUG
-            sc->stats.dirtyTx = badtx;
-            sc->stats.lmc_next_tx = sc->lmc_next_tx;
-            sc->stats.lmc_txfull = sc->lmc_txfull;
+	    sc->extra_stats.dirtyTx = badtx;
+	    sc->extra_stats.lmc_next_tx = sc->lmc_next_tx;
+	    sc->extra_stats.lmc_txfull = sc->lmc_txfull;
 #endif
             sc->lmc_taint_tx = badtx;
 
@@ -1476,9 +1403,9 @@ lmc_int_fail_out:
     return IRQ_RETVAL(handled);
 }
 
-static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00*/
+static int lmc_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 flag;
     int entry;
     int ret = 0;
@@ -1486,8 +1413,6 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
 
     lmc_trace(dev, "lmc_start_xmit in");
 
-    sc = dev->priv;
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
     /* normal path, tbusy known to be zero */
@@ -1532,8 +1457,8 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
     if (sc->lmc_next_tx - sc->lmc_taint_tx >= LMC_TXDESCS - 1)
     {				/* ring full, go busy */
         sc->lmc_txfull = 1;
-        netif_stop_queue(dev);
-        sc->stats.tx_tbusy1++ ;
+	netif_stop_queue(dev);
+	sc->extra_stats.tx_tbusy1++;
         LMC_EVENT_LOG(LMC_EVENT_TBUSY1, entry, 0);
     }
 #endif
@@ -1550,7 +1475,7 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
      * the watchdog timer handler. -baz
      */
 
-    sc->stats.tx_NoCompleteCnt++;
+    sc->extra_stats.tx_NoCompleteCnt++;
     sc->lmc_next_tx++;
 
     /* give ownership to the chip */
@@ -1569,9 +1494,9 @@ static int lmc_start_xmit (struct sk_buff *skb, struct net_device *dev) /*fold00
 }
 
 
-static int lmc_rx (struct net_device *dev) /*fold00*/
+static int lmc_rx(struct net_device *dev)
 {
-    lmc_softc_t *sc;
+    lmc_softc_t *sc = dev_to_sc(dev);
     int i;
     int rx_work_limit = LMC_RXDESCS;
     unsigned int next_rx;
@@ -1583,8 +1508,6 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
 
     lmc_trace(dev, "lmc_rx in");
 
-    sc = dev->priv;
-
     lmc_led_on(sc, LMC_DS3_LED3);
 
     rxIntLoopCnt = 0;		/* debug -baz */
@@ -1597,39 +1520,38 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
         rxIntLoopCnt++;		/* debug -baz */
         len = ((stat & LMC_RDES_FRAME_LENGTH) >> RDES_FRAME_LENGTH_BIT_NUMBER);
         if ((stat & 0x0300) != 0x0300) {  /* Check first segment and last segment */
-            if ((stat & 0x0000ffff) != 0x7fff) {
-                /* Oversized frame */
-                sc->stats.rx_length_errors++;
-                goto skip_packet;
-            }
-        }
-
-        if(stat & 0x00000008){ /* Catch a dribbling bit error */
-            sc->stats.rx_errors++;
-            sc->stats.rx_frame_errors++;
-            goto skip_packet;
-        }
+		if ((stat & 0x0000ffff) != 0x7fff) {
+			/* Oversized frame */
+			sc->lmc_device->stats.rx_length_errors++;
+			goto skip_packet;
+		}
+	}
 
+	if (stat & 0x00000008) { /* Catch a dribbling bit error */
+		sc->lmc_device->stats.rx_errors++;
+		sc->lmc_device->stats.rx_frame_errors++;
+		goto skip_packet;
+	}
 
-        if(stat & 0x00000004){ /* Catch a CRC error by the Xilinx */
-            sc->stats.rx_errors++;
-            sc->stats.rx_crc_errors++;
-            goto skip_packet;
-        }
 
+	if (stat & 0x00000004) { /* Catch a CRC error by the Xilinx */
+		sc->lmc_device->stats.rx_errors++;
+		sc->lmc_device->stats.rx_crc_errors++;
+		goto skip_packet;
+	}
 
-        if (len > LMC_PKT_BUF_SZ){
-            sc->stats.rx_length_errors++;
-            localLengthErrCnt++;
-            goto skip_packet;
-        }
+	if (len > LMC_PKT_BUF_SZ) {
+		sc->lmc_device->stats.rx_length_errors++;
+		localLengthErrCnt++;
+		goto skip_packet;
+	}
 
-        if (len < sc->lmc_crcSize + 2) {
-            sc->stats.rx_length_errors++;
-            sc->stats.rx_SmallPktCnt++;
-            localLengthErrCnt++;
-            goto skip_packet;
-        }
+	if (len < sc->lmc_crcSize + 2) {
+		sc->lmc_device->stats.rx_length_errors++;
+		sc->extra_stats.rx_SmallPktCnt++;
+		localLengthErrCnt++;
+		goto skip_packet;
+	}
 
         if(stat & 0x00004000){
             printk(KERN_WARNING "%s: Receiver descriptor error, receiver out of sync?\n", dev->name);
@@ -1656,8 +1578,8 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
         }
         
         dev->last_rx = jiffies;
-        sc->stats.rx_packets++;
-        sc->stats.rx_bytes += len;
+	sc->lmc_device->stats.rx_packets++;
+	sc->lmc_device->stats.rx_bytes += len;
 
         LMC_CONSOLE_LOG("recv", skb->data, len);
 
@@ -1679,7 +1601,6 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
 
             skb_put (skb, len);
             skb->protocol = lmc_proto_type(sc, skb);
-            skb->protocol = htons(ETH_P_WAN_PPP);
             skb_reset_mac_header(skb);
             /* skb_reset_network_header(skb); */
             skb->dev = dev;
@@ -1704,7 +1625,7 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
                  * in which care we'll try to allocate the buffer
                  * again.  (once a second)
                  */
-                sc->stats.rx_BuffAllocErr++;
+		sc->extra_stats.rx_BuffAllocErr++;
                 LMC_EVENT_LOG(LMC_EVENT_RCVINT, stat, len);
                 sc->failed_recv_alloc = 1;
                 goto skip_out_of_mem;
@@ -1739,16 +1660,14 @@ static int lmc_rx (struct net_device *dev) /*fold00*/
      * descriptors with bogus packets
      *
     if (localLengthErrCnt > LMC_RXDESCS - 3) {
-        sc->stats.rx_BadPktSurgeCnt++;
-        LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE,
-                      localLengthErrCnt,
-                      sc->stats.rx_BadPktSurgeCnt);
+	sc->extra_stats.rx_BadPktSurgeCnt++;
+	LMC_EVENT_LOG(LMC_EVENT_BADPKTSURGE, localLengthErrCnt,
+		      sc->extra_stats.rx_BadPktSurgeCnt);
     } */
 
     /* save max count of receive descriptors serviced */
-    if (rxIntLoopCnt > sc->stats.rxIntLoopCnt) {
-        sc->stats.rxIntLoopCnt = rxIntLoopCnt;	/* debug -baz */
-    }
+    if (rxIntLoopCnt > sc->extra_stats.rxIntLoopCnt)
+	    sc->extra_stats.rxIntLoopCnt = rxIntLoopCnt; /* debug -baz */
 
 #ifdef DEBUG
     if (rxIntLoopCnt == 0)
@@ -1775,23 +1694,22 @@ skip_out_of_mem:
     return 0;
 }
 
-static struct net_device_stats *lmc_get_stats (struct net_device *dev) /*fold00*/
+static struct net_device_stats *lmc_get_stats(struct net_device *dev)
 {
-    lmc_softc_t *sc = dev->priv;
+    lmc_softc_t *sc = dev_to_sc(dev);
     unsigned long flags;
 
     lmc_trace(dev, "lmc_get_stats in");
 
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
-    sc->stats.rx_missed_errors += LMC_CSR_READ (sc, csr_missed_frames) & 0xffff;
+    sc->lmc_device->stats.rx_missed_errors += LMC_CSR_READ(sc, csr_missed_frames) & 0xffff;
 
     spin_unlock_irqrestore(&sc->lmc_lock, flags);
 
     lmc_trace(dev, "lmc_get_stats out");
 
-    return (struct net_device_stats *) &sc->stats;
+    return &sc->lmc_device->stats;
 }
 
 static struct pci_driver lmc_driver = {
@@ -1970,7 +1888,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
     {
         if (sc->lmc_txq[i] != NULL){		/* have buffer */
             dev_kfree_skb(sc->lmc_txq[i]);	/* free it */
-            sc->stats.tx_dropped++;      /* We just dropped a packet */
+	    sc->lmc_device->stats.tx_dropped++;	/* We just dropped a packet */
         }
         sc->lmc_txq[i] = NULL;
         sc->lmc_txring[i].status = 0x00000000;
@@ -1982,7 +1900,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
     lmc_trace(sc->lmc_device, "lmc_softreset out");
 }
 
-void lmc_gpio_mkinput(lmc_softc_t * const sc, u_int32_t bits) /*fold00*/
+void lmc_gpio_mkinput(lmc_softc_t * const sc, u32 bits) /*fold00*/
 {
     lmc_trace(sc->lmc_device, "lmc_gpio_mkinput in");
     sc->lmc_gpio_io &= ~bits;
@@ -1990,7 +1908,7 @@ void lmc_gpio_mkinput(lmc_softc_t * const sc, u_int32_t bits) /*fold00*/
     lmc_trace(sc->lmc_device, "lmc_gpio_mkinput out");
 }
 
-void lmc_gpio_mkoutput(lmc_softc_t * const sc, u_int32_t bits) /*fold00*/
+void lmc_gpio_mkoutput(lmc_softc_t * const sc, u32 bits) /*fold00*/
 {
     lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput in");
     sc->lmc_gpio_io |= bits;
@@ -1998,7 +1916,7 @@ void lmc_gpio_mkoutput(lmc_softc_t * const sc, u_int32_t bits) /*fold00*/
     lmc_trace(sc->lmc_device, "lmc_gpio_mkoutput out");
 }
 
-void lmc_led_on(lmc_softc_t * const sc, u_int32_t led) /*fold00*/
+void lmc_led_on(lmc_softc_t * const sc, u32 led) /*fold00*/
 {
     lmc_trace(sc->lmc_device, "lmc_led_on in");
     if((~sc->lmc_miireg16) & led){ /* Already on! */
@@ -2011,7 +1929,7 @@ void lmc_led_on(lmc_softc_t * const sc, u_int32_t led) /*fold00*/
     lmc_trace(sc->lmc_device, "lmc_led_on out");
 }
 
-void lmc_led_off(lmc_softc_t * const sc, u_int32_t led) /*fold00*/
+void lmc_led_off(lmc_softc_t * const sc, u32 led) /*fold00*/
 {
     lmc_trace(sc->lmc_device, "lmc_led_off in");
     if(sc->lmc_miireg16 & led){ /* Already set don't do anything */
@@ -2061,13 +1979,13 @@ static void lmc_reset(lmc_softc_t * const sc) /*fold00*/
      */
     sc->lmc_media->init(sc);
 
-    sc->stats.resetCount++;
+    sc->extra_stats.resetCount++;
     lmc_trace(sc->lmc_device, "lmc_reset out");
 }
 
 static void lmc_dec_reset(lmc_softc_t * const sc) /*fold00*/
 {
-    u_int32_t val;
+    u32 val;
     lmc_trace(sc->lmc_device, "lmc_dec_reset in");
 
     /*
@@ -2151,23 +2069,21 @@ static void lmc_initcsrs(lmc_softc_t * const sc, lmc_csrptr_t csr_base, /*fold00
     lmc_trace(sc->lmc_device, "lmc_initcsrs out");
 }
 
-static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
-    lmc_softc_t *sc;
+static void lmc_driver_timeout(struct net_device *dev)
+{
+    lmc_softc_t *sc = dev_to_sc(dev);
     u32 csr6;
     unsigned long flags;
 
     lmc_trace(dev, "lmc_driver_timeout in");
 
-    sc = dev->priv;
-
     spin_lock_irqsave(&sc->lmc_lock, flags);
 
     printk("%s: Xmitter busy|\n", dev->name);
 
-    sc->stats.tx_tbusy_calls++ ;
-    if (jiffies - dev->trans_start < TX_TIMEOUT) {
-        goto bug_out;
-    }
+    sc->extra_stats.tx_tbusy_calls++;
+    if (jiffies - dev->trans_start < TX_TIMEOUT)
+	    goto bug_out;
 
     /*
      * Chip seems to have locked up
@@ -2178,7 +2094,7 @@ static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
 
     LMC_EVENT_LOG(LMC_EVENT_XMTPRCTMO,
                   LMC_CSR_READ (sc, csr_status),
-                  sc->stats.tx_ProcTimeout);
+		  sc->extra_stats.tx_ProcTimeout);
 
     lmc_running_reset (dev);
 
@@ -2195,8 +2111,8 @@ static void lmc_driver_timeout(struct net_device *dev) { /*fold00*/
     /* immediate transmit */
     LMC_CSR_WRITE (sc, csr_txpoll, 0);
 
-    sc->stats.tx_errors++;
-    sc->stats.tx_ProcTimeout++;	/* -baz */
+    sc->lmc_device->stats.tx_errors++;
+    sc->extra_stats.tx_ProcTimeout++; /* -baz */
 
     dev->trans_start = jiffies;
 
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_media.c
index 8aa461c..f327674 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -16,8 +16,6 @@
 #include <linux/inet.h>
 #include <linux/bitops.h>
 
-#include <net/syncppp.h>
-
 #include <asm/processor.h>             /* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -95,8 +93,7 @@ static void lmc_dummy_set_1 (lmc_softc_t * const, int);
 static void lmc_dummy_set2_1 (lmc_softc_t * const, lmc_ctl_t *);
 
 static inline void write_av9110_bit (lmc_softc_t *, int);
-static void write_av9110 (lmc_softc_t *, u_int32_t, u_int32_t, u_int32_t,
-			  u_int32_t, u_int32_t);
+static void write_av9110(lmc_softc_t *, u32, u32, u32, u32, u32);
 
 lmc_media_t lmc_ds3_media = {
   lmc_ds3_init,			/* special media init stuff */
@@ -427,7 +424,7 @@ lmc_ds3_set_scram (lmc_softc_t * const sc, int ie)
 static int
 lmc_ds3_get_link_status (lmc_softc_t * const sc)
 {
-    u_int16_t link_status, link_status_11;
+    u16 link_status, link_status_11;
     int ret = 1;
 
     lmc_mii_writereg (sc, 0, 17, 7);
@@ -449,7 +446,7 @@ lmc_ds3_get_link_status (lmc_softc_t * const sc)
         (link_status & LMC_FRAMER_REG0_OOFS)){
         ret = 0;
         if(sc->last_led_err[3] != 1){
-            u16 r1;
+	    u16 r1;
             lmc_mii_writereg (sc, 0, 17, 01); /* Turn on Xbit error as our cisco does */
             r1 = lmc_mii_readreg (sc, 0, 18);
             r1 &= 0xfe;
@@ -462,7 +459,7 @@ lmc_ds3_get_link_status (lmc_softc_t * const sc)
     else {
         lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
         if(sc->last_led_err[3] == 1){
-            u16 r1;
+	    u16 r1;
             lmc_mii_writereg (sc, 0, 17, 01); /* Turn off Xbit error */
             r1 = lmc_mii_readreg (sc, 0, 18);
             r1 |= 0x01;
@@ -540,20 +537,19 @@ lmc_ds3_watchdog (lmc_softc_t * const sc)
  *  SSI methods
  */
 
-static void
-lmc_ssi_init (lmc_softc_t * const sc)
+static void lmc_ssi_init(lmc_softc_t * const sc)
 {
-  u_int16_t mii17;
-  int cable;
+	u16 mii17;
+	int cable;
 
-  sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1000;
+	sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1000;
 
-  mii17 = lmc_mii_readreg (sc, 0, 17);
+	mii17 = lmc_mii_readreg(sc, 0, 17);
 
-  cable = (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_SHIFT;
-  sc->ictl.cable_type = cable;
+	cable = (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_SHIFT;
+	sc->ictl.cable_type = cable;
 
-  lmc_gpio_mkoutput (sc, LMC_GEP_SSI_TXCLOCK);
+	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
 }
 
 static void
@@ -681,11 +677,11 @@ lmc_ssi_set_speed (lmc_softc_t * const sc, lmc_ctl_t * ctl)
 static int
 lmc_ssi_get_link_status (lmc_softc_t * const sc)
 {
-  u_int16_t link_status;
-  u_int32_t ticks;
+  u16 link_status;
+  u32 ticks;
   int ret = 1;
   int hw_hdsk = 1;
-  
+
   /*
    * missing CTS?  Hmm.  If we require CTS on, we may never get the
    * link to come up, so omit it in this test.
@@ -720,9 +716,9 @@ lmc_ssi_get_link_status (lmc_softc_t * const sc)
   }
   else if (ticks == 0 ) {				/* no clock found ? */
       ret = 0;
-      if(sc->last_led_err[3] != 1){
-          sc->stats.tx_lossOfClockCnt++;
-          printk(KERN_WARNING "%s: Lost Clock, Link Down\n", sc->name);
+      if (sc->last_led_err[3] != 1) {
+	      sc->extra_stats.tx_lossOfClockCnt++;
+	      printk(KERN_WARNING "%s: Lost Clock, Link Down\n", sc->name);
       }
       sc->last_led_err[3] = 1;
       lmc_led_on (sc, LMC_MII16_LED3);	/* turn ON red LED */
@@ -838,9 +834,7 @@ write_av9110_bit (lmc_softc_t * sc, int c)
   LMC_CSR_WRITE (sc, csr_gp, sc->lmc_gpio);
 }
 
-static void
-write_av9110 (lmc_softc_t * sc, u_int32_t n, u_int32_t m, u_int32_t v,
-	      u_int32_t x, u_int32_t r)
+static void write_av9110(lmc_softc_t *sc, u32 n, u32 m, u32 v, u32 x, u32 r)
 {
   int i;
 
@@ -887,19 +881,13 @@ write_av9110 (lmc_softc_t * sc, u_int32_t n, u_int32_t m, u_int32_t v,
 		     | LMC_GEP_SSI_GENERATOR));
 }
 
-static void
-lmc_ssi_watchdog (lmc_softc_t * const sc)
+static void lmc_ssi_watchdog(lmc_softc_t * const sc)
 {
-  u_int16_t mii17 = lmc_mii_readreg (sc, 0, 17);
-  if (((mii17 >> 3) & 7) == 7)
-    {
-      lmc_led_off (sc, LMC_MII16_LED2);
-    }
-  else
-    {
-      lmc_led_on (sc, LMC_MII16_LED2);
-    }
-
+	u16 mii17 = lmc_mii_readreg(sc, 0, 17);
+	if (((mii17 >> 3) & 7) == 7)
+		lmc_led_off(sc, LMC_MII16_LED2);
+	else
+		lmc_led_on(sc, LMC_MII16_LED2);
 }
 
 /*
@@ -929,7 +917,7 @@ lmc_t1_read (lmc_softc_t * const sc, int a)
 static void
 lmc_t1_init (lmc_softc_t * const sc)
 {
-  u_int16_t mii16;
+  u16 mii16;
   int i;
 
   sc->ictl.cardtype = LMC_CTL_CARDTYPE_LMC1200;
@@ -1028,7 +1016,7 @@ lmc_t1_set_status (lmc_softc_t * const sc, lmc_ctl_t * ctl)
  */ static int
 lmc_t1_get_link_status (lmc_softc_t * const sc)
 {
-    u_int16_t link_status;
+    u16 link_status;
     int ret = 1;
 
   /* LMC5245 (DS3) & LMC1200 (DS1) LED definitions
diff --git a/drivers/net/wan/lmc/lmc_proto.c b/drivers/net/wan/lmc/lmc_proto.c
index 8531575..be9877f 100644
--- a/drivers/net/wan/lmc/lmc_proto.c
+++ b/drivers/net/wan/lmc/lmc_proto.c
@@ -36,9 +36,6 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
-
-#include <net/syncppp.h>
-
 #include <asm/processor.h>             /* Processor type for cache alignment. */
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -50,48 +47,6 @@
 #include "lmc_ioctl.h"
 #include "lmc_proto.h"
 
-/*
- * The compile-time variable SPPPSTUP causes the module to be
- * compiled without referencing any of the sync ppp routines.
- */
-#ifdef SPPPSTUB
-#define SPPP_detach(d)	(void)0
-#define SPPP_open(d)	0
-#define SPPP_reopen(d)	(void)0
-#define SPPP_close(d)	(void)0
-#define SPPP_attach(d)	(void)0
-#define SPPP_do_ioctl(d,i,c)	-EOPNOTSUPP
-#else
-#define SPPP_attach(x)	sppp_attach((x)->pd)
-#define SPPP_detach(x)	sppp_detach((x)->pd->dev)
-#define SPPP_open(x)	sppp_open((x)->pd->dev)
-#define SPPP_reopen(x)	sppp_reopen((x)->pd->dev)
-#define SPPP_close(x)	sppp_close((x)->pd->dev)
-#define SPPP_do_ioctl(x, y, z)	sppp_do_ioctl((x)->pd->dev, (y), (z))
-#endif
-
-// init
-void lmc_proto_init(lmc_softc_t *sc) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_init in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        sc->pd = kmalloc(sizeof(struct ppp_device), GFP_KERNEL);
-	if (!sc->pd) {
-		printk("lmc_proto_init(): kmalloc failure!\n");
-		return;
-	}
-        sc->pd->dev = sc->lmc_device;
-        sc->if_ptr = sc->pd;
-        break;
-    case LMC_RAW:
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_init out");
-}
-
 // attach
 void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
 {
@@ -100,7 +55,6 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
     case LMC_PPP:
         {
             struct net_device *dev = sc->lmc_device;
-            SPPP_attach(sc);
             dev->do_ioctl = lmc_ioctl;
         }
         break;
@@ -108,7 +62,7 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
         {
             struct net_device *dev = sc->lmc_device;
             /*
-             * They set a few basics because they don't use sync_ppp
+	     * They set a few basics because they don't use HDLC
              */
             dev->flags |= IFF_POINTOPOINT;
 
@@ -124,88 +78,39 @@ void lmc_proto_attach(lmc_softc_t *sc) /*FOLD00*/
     lmc_trace(sc->lmc_device, "lmc_proto_attach out");
 }
 
-// detach
-void lmc_proto_detach(lmc_softc_t *sc) /*FOLD00*/
+int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd)
 {
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_detach(sc);
-        break;
-    case LMC_RAW: /* Tell someone we're detaching? */
-        break;
-    default:
-        break;
-    }
-
+	lmc_trace(sc->lmc_device, "lmc_proto_ioctl");
+	if (sc->if_type == LMC_PPP)
+		return hdlc_ioctl(sc->lmc_device, ifr, cmd);
+	return -EOPNOTSUPP;
 }
 
-// reopen
-void lmc_proto_reopen(lmc_softc_t *sc) /*FOLD00*/
+int lmc_proto_open(lmc_softc_t *sc)
 {
-    lmc_trace(sc->lmc_device, "lmc_proto_reopen in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_reopen(sc);
-        break;
-    case LMC_RAW: /* Reset the interface after being down, prerape to receive packets again */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_reopen out");
-}
+	int ret = 0;
 
+	lmc_trace(sc->lmc_device, "lmc_proto_open in");
 
-// ioctl
-int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_ioctl out");
-    switch(sc->if_type){
-    case LMC_PPP:
-        return SPPP_do_ioctl (sc, ifr, cmd);
-        break;
-    default:
-        return -EOPNOTSUPP;
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_ioctl out");
+	if (sc->if_type == LMC_PPP) {
+		ret = hdlc_open(sc->lmc_device);
+		if (ret < 0)
+			printk(KERN_WARNING "%s: HDLC open failed: %d\n",
+			       sc->name, ret);
+	}
+
+	lmc_trace(sc->lmc_device, "lmc_proto_open out");
+	return ret;
 }
 
-// open
-void lmc_proto_open(lmc_softc_t *sc) /*FOLD00*/
+void lmc_proto_close(lmc_softc_t *sc)
 {
-    int ret;
+	lmc_trace(sc->lmc_device, "lmc_proto_close in");
 
-    lmc_trace(sc->lmc_device, "lmc_proto_open in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        ret = SPPP_open(sc);
-        if(ret < 0)
-            printk("%s: syncPPP open failed: %d\n", sc->name, ret);
-        break;
-    case LMC_RAW: /* We're about to start getting packets! */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_open out");
-}
-
-// close
+	if (sc->if_type == LMC_PPP)
+		hdlc_close(sc->lmc_device);
 
-void lmc_proto_close(lmc_softc_t *sc) /*FOLD00*/
-{
-    lmc_trace(sc->lmc_device, "lmc_proto_close in");
-    switch(sc->if_type){
-    case LMC_PPP:
-        SPPP_close(sc);
-        break;
-    case LMC_RAW: /* Interface going down */
-        break;
-    default:
-        break;
-    }
-    lmc_trace(sc->lmc_device, "lmc_proto_close out");
+	lmc_trace(sc->lmc_device, "lmc_proto_close out");
 }
 
 __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
@@ -213,8 +118,8 @@ __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
     lmc_trace(sc->lmc_device, "lmc_proto_type in");
     switch(sc->if_type){
     case LMC_PPP:
-        return htons(ETH_P_WAN_PPP);
-        break;
+	    return hdlc_type_trans(skb, sc->lmc_device);
+	    break;
     case LMC_NET:
         return htons(ETH_P_802_2);
         break;
@@ -245,4 +150,3 @@ void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb) /*FOLD00*/
     }
     lmc_trace(sc->lmc_device, "lmc_proto_netif out");
 }
-
diff --git a/drivers/net/wan/lmc/lmc_proto.h b/drivers/net/wan/lmc/lmc_proto.h
index ccaa69e..662148c 100644
--- a/drivers/net/wan/lmc/lmc_proto.h
+++ b/drivers/net/wan/lmc/lmc_proto.h
@@ -1,16 +1,18 @@
 #ifndef _LMC_PROTO_H_
 #define _LMC_PROTO_H_
 
-void lmc_proto_init(lmc_softc_t *sc);
+#include <linux/hdlc.h>
+
 void lmc_proto_attach(lmc_softc_t *sc);
-void lmc_proto_detach(lmc_softc_t *sc);
-void lmc_proto_reopen(lmc_softc_t *sc);
 int lmc_proto_ioctl(lmc_softc_t *sc, struct ifreq *ifr, int cmd);
-void lmc_proto_open(lmc_softc_t *sc);
+int lmc_proto_open(lmc_softc_t *sc);
 void lmc_proto_close(lmc_softc_t *sc);
 __be16 lmc_proto_type(lmc_softc_t *sc, struct sk_buff *skb);
 void lmc_proto_netif(lmc_softc_t *sc, struct sk_buff *skb);
-int lmc_skb_rawpackets(char *buf, char **start, off_t offset, int len, int unused);
 
-#endif
+static inline lmc_softc_t* dev_to_sc(struct net_device *dev)
+{
+	return (lmc_softc_t *)dev_to_hdlc(dev)->priv;
+}
 
+#endif
diff --git a/drivers/net/wan/lmc/lmc_var.h b/drivers/net/wan/lmc/lmc_var.h
index 6d003a3..65d0197 100644
--- a/drivers/net/wan/lmc/lmc_var.h
+++ b/drivers/net/wan/lmc/lmc_var.h
@@ -1,8 +1,6 @@
 #ifndef _LMC_VAR_H_
 #define _LMC_VAR_H_
 
-/* $Id: lmc_var.h,v 1.17 2000/04/06 12:16:47 asj Exp $ */
-
  /*
   * Copyright (c) 1997-2000 LAN Media Corporation (LMC)
   * All rights reserved.  www.lanmedia.com
@@ -19,23 +17,6 @@
 
 #include <linux/timer.h>
 
-#ifndef __KERNEL__
-typedef signed char s8;
-typedef unsigned char u8;
-
-typedef signed short s16;
-typedef unsigned short u16;
-
-typedef signed int s32;
-typedef unsigned int u32;
-
-typedef signed long long s64;
-typedef unsigned long long u64;
-
-#define BITS_PER_LONG 32 
-
-#endif
-
 /*
  * basic definitions used in lmc include files
  */
@@ -45,9 +26,6 @@ typedef struct lmc___media lmc_media_t;
 typedef struct lmc___ctl lmc_ctl_t;
 
 #define lmc_csrptr_t    unsigned long
-#define u_int16_t	u16
-#define u_int8_t	u8
-#define tulip_uint32_t	u32
 
 #define LMC_REG_RANGE 0x80
 
@@ -122,45 +100,45 @@ struct lmc_regfile_t {
  *  used to define bits in the second tulip_desc_t field (length)
  *  for the transmit descriptor -baz */
 
-#define LMC_TDES_FIRST_BUFFER_SIZE       ((u_int32_t)(0x000007FF))
-#define LMC_TDES_SECOND_BUFFER_SIZE      ((u_int32_t)(0x003FF800))
-#define LMC_TDES_HASH_FILTERING          ((u_int32_t)(0x00400000))
-#define LMC_TDES_DISABLE_PADDING         ((u_int32_t)(0x00800000))
-#define LMC_TDES_SECOND_ADDR_CHAINED     ((u_int32_t)(0x01000000))
-#define LMC_TDES_END_OF_RING             ((u_int32_t)(0x02000000))
-#define LMC_TDES_ADD_CRC_DISABLE         ((u_int32_t)(0x04000000))
-#define LMC_TDES_SETUP_PACKET            ((u_int32_t)(0x08000000))
-#define LMC_TDES_INVERSE_FILTERING       ((u_int32_t)(0x10000000))
-#define LMC_TDES_FIRST_SEGMENT           ((u_int32_t)(0x20000000))
-#define LMC_TDES_LAST_SEGMENT            ((u_int32_t)(0x40000000))
-#define LMC_TDES_INTERRUPT_ON_COMPLETION ((u_int32_t)(0x80000000))
+#define LMC_TDES_FIRST_BUFFER_SIZE       ((u32)(0x000007FF))
+#define LMC_TDES_SECOND_BUFFER_SIZE      ((u32)(0x003FF800))
+#define LMC_TDES_HASH_FILTERING          ((u32)(0x00400000))
+#define LMC_TDES_DISABLE_PADDING         ((u32)(0x00800000))
+#define LMC_TDES_SECOND_ADDR_CHAINED     ((u32)(0x01000000))
+#define LMC_TDES_END_OF_RING             ((u32)(0x02000000))
+#define LMC_TDES_ADD_CRC_DISABLE         ((u32)(0x04000000))
+#define LMC_TDES_SETUP_PACKET            ((u32)(0x08000000))
+#define LMC_TDES_INVERSE_FILTERING       ((u32)(0x10000000))
+#define LMC_TDES_FIRST_SEGMENT           ((u32)(0x20000000))
+#define LMC_TDES_LAST_SEGMENT            ((u32)(0x40000000))
+#define LMC_TDES_INTERRUPT_ON_COMPLETION ((u32)(0x80000000))
 
 #define TDES_SECOND_BUFFER_SIZE_BIT_NUMBER  11
 #define TDES_COLLISION_COUNT_BIT_NUMBER     3
 
 /* Constants for the RCV descriptor RDES */
 
-#define LMC_RDES_OVERFLOW             ((u_int32_t)(0x00000001))
-#define LMC_RDES_CRC_ERROR            ((u_int32_t)(0x00000002))
-#define LMC_RDES_DRIBBLING_BIT            ((u_int32_t)(0x00000004))
-#define LMC_RDES_REPORT_ON_MII_ERR    ((u_int32_t)(0x00000008))
-#define LMC_RDES_RCV_WATCHDOG_TIMEOUT ((u_int32_t)(0x00000010))
-#define LMC_RDES_FRAME_TYPE           ((u_int32_t)(0x00000020))
-#define LMC_RDES_COLLISION_SEEN       ((u_int32_t)(0x00000040))
-#define LMC_RDES_FRAME_TOO_LONG       ((u_int32_t)(0x00000080))
-#define LMC_RDES_LAST_DESCRIPTOR      ((u_int32_t)(0x00000100))
-#define LMC_RDES_FIRST_DESCRIPTOR     ((u_int32_t)(0x00000200))
-#define LMC_RDES_MULTICAST_FRAME      ((u_int32_t)(0x00000400))
-#define LMC_RDES_RUNT_FRAME           ((u_int32_t)(0x00000800))
-#define LMC_RDES_DATA_TYPE            ((u_int32_t)(0x00003000))
-#define LMC_RDES_LENGTH_ERROR         ((u_int32_t)(0x00004000))
-#define LMC_RDES_ERROR_SUMMARY        ((u_int32_t)(0x00008000))
-#define LMC_RDES_FRAME_LENGTH         ((u_int32_t)(0x3FFF0000))
-#define LMC_RDES_OWN_BIT              ((u_int32_t)(0x80000000))
+#define LMC_RDES_OVERFLOW             ((u32)(0x00000001))
+#define LMC_RDES_CRC_ERROR            ((u32)(0x00000002))
+#define LMC_RDES_DRIBBLING_BIT        ((u32)(0x00000004))
+#define LMC_RDES_REPORT_ON_MII_ERR    ((u32)(0x00000008))
+#define LMC_RDES_RCV_WATCHDOG_TIMEOUT ((u32)(0x00000010))
+#define LMC_RDES_FRAME_TYPE           ((u32)(0x00000020))
+#define LMC_RDES_COLLISION_SEEN       ((u32)(0x00000040))
+#define LMC_RDES_FRAME_TOO_LONG       ((u32)(0x00000080))
+#define LMC_RDES_LAST_DESCRIPTOR      ((u32)(0x00000100))
+#define LMC_RDES_FIRST_DESCRIPTOR     ((u32)(0x00000200))
+#define LMC_RDES_MULTICAST_FRAME      ((u32)(0x00000400))
+#define LMC_RDES_RUNT_FRAME           ((u32)(0x00000800))
+#define LMC_RDES_DATA_TYPE            ((u32)(0x00003000))
+#define LMC_RDES_LENGTH_ERROR         ((u32)(0x00004000))
+#define LMC_RDES_ERROR_SUMMARY        ((u32)(0x00008000))
+#define LMC_RDES_FRAME_LENGTH         ((u32)(0x3FFF0000))
+#define LMC_RDES_OWN_BIT              ((u32)(0x80000000))
 
 #define RDES_FRAME_LENGTH_BIT_NUMBER       16
 
-#define LMC_RDES_ERROR_MASK ( (u_int32_t)( \
+#define LMC_RDES_ERROR_MASK ( (u32)( \
 	  LMC_RDES_OVERFLOW \
 	| LMC_RDES_DRIBBLING_BIT \
 	| LMC_RDES_REPORT_ON_MII_ERR \
@@ -172,32 +150,32 @@ struct lmc_regfile_t {
  */
 
 typedef struct {
-	u_int32_t	n;
-	u_int32_t	m;
-	u_int32_t	v;
-	u_int32_t	x;
-	u_int32_t	r;
-	u_int32_t	f;
-	u_int32_t	exact;
+	u32	n;
+	u32	m;
+	u32	v;
+	u32	x;
+	u32	r;
+	u32	f;
+	u32	exact;
 } lmc_av9110_t;
 
 /*
  * Common structure passed to the ioctl code.
  */
 struct lmc___ctl {
-	u_int32_t	cardtype;
-	u_int32_t	clock_source;		/* HSSI, T1 */
-	u_int32_t	clock_rate;		/* T1 */
-	u_int32_t	crc_length;
-	u_int32_t	cable_length;		/* DS3 */
-	u_int32_t	scrambler_onoff;	/* DS3 */
-	u_int32_t	cable_type;		/* T1 */
-	u_int32_t	keepalive_onoff;	/* protocol */
-	u_int32_t	ticks;			/* ticks/sec */
+	u32	cardtype;
+	u32	clock_source;		/* HSSI, T1 */
+	u32	clock_rate;		/* T1 */
+	u32	crc_length;
+	u32	cable_length;		/* DS3 */
+	u32	scrambler_onoff;	/* DS3 */
+	u32	cable_type;		/* T1 */
+	u32	keepalive_onoff;	/* protocol */
+	u32	ticks;			/* ticks/sec */
 	union {
 		lmc_av9110_t	ssi;
 	} cardspec;
-	u_int32_t       circuit_type;   /* T1 or E1 */
+	u32       circuit_type;   /* T1 or E1 */
 };
 
 
@@ -244,108 +222,69 @@ struct lmc___media {
 
 #define STATCHECK     0xBEEFCAFE
 
-/*  Included in this structure are first
- *   - standard net_device_stats
- *   - some other counters used for debug and driver performance
- *  evaluation -baz
- */
-struct lmc_statistics
+struct lmc_extra_statistics
 {
-        unsigned long     rx_packets;             /* total packets received       */
-        unsigned long     tx_packets;             /* total packets transmitted    */
-	unsigned long     rx_bytes;
-        unsigned long     tx_bytes;
-        
-        unsigned long     rx_errors;              /* bad packets received         */
-        unsigned long     tx_errors;              /* packet transmit problems     */
-        unsigned long     rx_dropped;             /* no space in linux buffers    */
-        unsigned long     tx_dropped;             /* no space available in linux  */
-        unsigned long     multicast;              /* multicast packets received   */
-        unsigned long     collisions;
-
-        /* detailed rx_errors: */
-        unsigned long     rx_length_errors;
-        unsigned long     rx_over_errors;         /* receiver ring buff overflow  */
-        unsigned long     rx_crc_errors;          /* recved pkt with crc error    */
-        unsigned long     rx_frame_errors;        /* recv'd frame alignment error */
-        unsigned long     rx_fifo_errors;         /* recv'r fifo overrun          */
-        unsigned long     rx_missed_errors;       /* receiver missed packet       */
-
-        /* detailed tx_errors */
-        unsigned long     tx_aborted_errors;
-        unsigned long     tx_carrier_errors;
-        unsigned long     tx_fifo_errors;
-        unsigned long     tx_heartbeat_errors;
-        unsigned long     tx_window_errors;
-
-        /* for cslip etc */
-        unsigned long rx_compressed;
-        unsigned long tx_compressed;
-
-        /* -------------------------------------
-         * Custom stats & counters follow -baz */
-        u_int32_t       version_size;
-        u_int32_t       lmc_cardtype;
-
-        u_int32_t       tx_ProcTimeout;
-        u_int32_t       tx_IntTimeout;
-        u_int32_t       tx_NoCompleteCnt;
-        u_int32_t       tx_MaxXmtsB4Int;
-        u_int32_t       tx_TimeoutCnt;
-        u_int32_t       tx_OutOfSyncPtr;
-        u_int32_t       tx_tbusy0;
-        u_int32_t       tx_tbusy1;
-        u_int32_t       tx_tbusy_calls;
-        u_int32_t       resetCount;
-        u_int32_t       lmc_txfull;
-        u_int32_t       tbusy;
-        u_int32_t       dirtyTx;
-        u_int32_t       lmc_next_tx;
-        u_int32_t       otherTypeCnt;
-        u_int32_t       lastType;
-        u_int32_t       lastTypeOK;
-        u_int32_t       txLoopCnt;
-        u_int32_t       usedXmtDescripCnt;
-        u_int32_t       txIndexCnt;
-        u_int32_t       rxIntLoopCnt;
-
-        u_int32_t       rx_SmallPktCnt;
-        u_int32_t       rx_BadPktSurgeCnt;
-        u_int32_t       rx_BuffAllocErr;
-        u_int32_t       tx_lossOfClockCnt;
-
-        /* T1 error counters */
-        u_int32_t       framingBitErrorCount;
-        u_int32_t       lineCodeViolationCount;
-
-        u_int32_t       lossOfFrameCount;
-        u_int32_t       changeOfFrameAlignmentCount;
-        u_int32_t       severelyErroredFrameCount;
-
-        u_int32_t       check;
+	u32       version_size;
+	u32       lmc_cardtype;
+
+	u32       tx_ProcTimeout;
+	u32       tx_IntTimeout;
+	u32       tx_NoCompleteCnt;
+	u32       tx_MaxXmtsB4Int;
+	u32       tx_TimeoutCnt;
+	u32       tx_OutOfSyncPtr;
+	u32       tx_tbusy0;
+	u32       tx_tbusy1;
+	u32       tx_tbusy_calls;
+	u32       resetCount;
+	u32       lmc_txfull;
+	u32       tbusy;
+	u32       dirtyTx;
+	u32       lmc_next_tx;
+	u32       otherTypeCnt;
+	u32       lastType;
+	u32       lastTypeOK;
+	u32       txLoopCnt;
+	u32       usedXmtDescripCnt;
+	u32       txIndexCnt;
+	u32       rxIntLoopCnt;
+
+	u32       rx_SmallPktCnt;
+	u32       rx_BadPktSurgeCnt;
+	u32       rx_BuffAllocErr;
+	u32       tx_lossOfClockCnt;
+
+	/* T1 error counters */
+	u32       framingBitErrorCount;
+	u32       lineCodeViolationCount;
+
+	u32       lossOfFrameCount;
+	u32       changeOfFrameAlignmentCount;
+	u32       severelyErroredFrameCount;
+
+	u32       check;
 };
 
-
 typedef struct lmc_xinfo {
-        u_int32_t       Magic0;                         /* BEEFCAFE */
+	u32       Magic0;                         /* BEEFCAFE */
 
-        u_int32_t       PciCardType;
-        u_int32_t       PciSlotNumber;          /* PCI slot number       */
+	u32       PciCardType;
+	u32       PciSlotNumber;          /* PCI slot number       */
 
-        u_int16_t       DriverMajorVersion;
-        u_int16_t       DriverMinorVersion;
-        u_int16_t       DriverSubVersion;
+	u16	       DriverMajorVersion;
+	u16	       DriverMinorVersion;
+	u16	       DriverSubVersion;
 
-        u_int16_t       XilinxRevisionNumber;
-        u_int16_t       MaxFrameSize;
+	u16	       XilinxRevisionNumber;
+	u16	       MaxFrameSize;
 
-        u_int16_t       t1_alarm1_status;
-        u_int16_t       t1_alarm2_status;
+	u16     	  t1_alarm1_status;
+	u16       	t1_alarm2_status;
 
-        int                     link_status;
-        u_int32_t       mii_reg16;
+	int             link_status;
+	u32       mii_reg16;
 
-        u_int32_t       Magic1;                         /* DEADBEEF */
+	u32       Magic1;                         /* DEADBEEF */
 } LMC_XINFO;
 
 
@@ -353,23 +292,22 @@ typedef struct lmc_xinfo {
  * forward decl
  */
 struct lmc___softc {
-        void *if_ptr;   /* General purpose pointer (used by SPPP) */
 	char                   *name;
 	u8			board_idx;
-	struct lmc_statistics   stats;
-	struct net_device          *lmc_device;
+	struct lmc_extra_statistics extra_stats;
+	struct net_device      *lmc_device;
 
 	int                     hang, rxdesc, bad_packet, some_counter;
-	u_int32_t               txgo;
+	u32  	         	txgo;
 	struct lmc_regfile_t	lmc_csrs;
-	volatile u_int32_t	lmc_txtick;
-	volatile u_int32_t	lmc_rxtick;
-	u_int32_t		lmc_flags;
-	u_int32_t		lmc_intrmask;	/* our copy of csr_intr */
-	u_int32_t		lmc_cmdmode;	/* our copy of csr_cmdmode */
-	u_int32_t		lmc_busmode;	/* our copy of csr_busmode */
-	u_int32_t		lmc_gpio_io;	/* state of in/out settings */
-	u_int32_t		lmc_gpio;	/* state of outputs */
+	volatile u32		lmc_txtick;
+	volatile u32		lmc_rxtick;
+	u32			lmc_flags;
+	u32			lmc_intrmask;	/* our copy of csr_intr */
+	u32			lmc_cmdmode;	/* our copy of csr_cmdmode */
+	u32			lmc_busmode;	/* our copy of csr_busmode */
+	u32			lmc_gpio_io;	/* state of in/out settings */
+	u32			lmc_gpio;	/* state of outputs */
 	struct sk_buff*		lmc_txq[LMC_TXDESCS];
 	struct sk_buff*		lmc_rxq[LMC_RXDESCS];
 	volatile
@@ -381,42 +319,41 @@ struct lmc___softc {
 	unsigned int		lmc_taint_tx, lmc_taint_rx;
 	int			lmc_tx_start, lmc_txfull;
 	int			lmc_txbusy;
-	u_int16_t		lmc_miireg16;
+	u16			lmc_miireg16;
 	int			lmc_ok;
 	int			last_link_status;
 	int			lmc_cardtype;
-	u_int32_t               last_frameerr;
+	u32               	last_frameerr;
 	lmc_media_t	       *lmc_media;
 	struct timer_list	timer;
 	lmc_ctl_t		ictl;
-	u_int32_t		TxDescriptControlInit;  
+	u32			TxDescriptControlInit;
 
 	int                     tx_TimeoutInd; /* additional driver state */
 	int                     tx_TimeoutDisplay;
 	unsigned int		lastlmc_taint_tx;
 	int                     lasttx_packets;
-	u_int32_t		tx_clockState;
-	u_int32_t		lmc_crcSize;
-	LMC_XINFO		lmc_xinfo; 
+	u32			tx_clockState;
+	u32			lmc_crcSize;
+	LMC_XINFO		lmc_xinfo;
 	char                    lmc_yel, lmc_blue, lmc_red; /* for T1 and DS3 */
-        char                    lmc_timing; /* for HSSI and SSI */
-        int                     got_irq;
+	char                    lmc_timing; /* for HSSI and SSI */
+	int                     got_irq;
 
-        char                    last_led_err[4];
+	char                    last_led_err[4];
 
-        u32                     last_int;
-        u32                     num_int;
+	u32                     last_int;
+	u32                     num_int;
 
 	spinlock_t              lmc_lock;
-        u_int16_t               if_type;       /* PPP or NET */
-        struct ppp_device       *pd;
+	u16			if_type;       /* HDLC/PPP or NET */
 
-        /* Failure cases */
-        u8                       failed_ring;
-        u8                       failed_recv_alloc;
+	/* Failure cases */
+	u8			failed_ring;
+	u8			failed_recv_alloc;
 
-        /* Structure check */
-        u32                     check;
+	/* Structure check */
+	u32                     check;
 };
 
 #define LMC_PCI_TIME 1
@@ -512,8 +449,8 @@ struct lmc___softc {
   | TULIP_STS_TXUNDERFLOW\
   | TULIP_STS_RXSTOPPED )
 
-#define DESC_OWNED_BY_SYSTEM   ((u_int32_t)(0x00000000))
-#define DESC_OWNED_BY_DC21X4   ((u_int32_t)(0x80000000))
+#define DESC_OWNED_BY_SYSTEM   ((u32)(0x00000000))
+#define DESC_OWNED_BY_DC21X4   ((u32)(0x80000000))
 
 #ifndef TULIP_CMD_RECEIVEALL
 #define TULIP_CMD_RECEIVEALL 0x40000000L
@@ -525,46 +462,9 @@ struct lmc___softc {
 #define LMC_ADAP_SSI            4
 #define LMC_ADAP_T1             5
 
-#define HDLC_HDR_LEN  4
-#define HDLC_ADDR_LEN 1
-#define HDLC_SLARP    0x8035
 #define LMC_MTU 1500
-#define SLARP_LINECHECK 2
 
 #define LMC_CRC_LEN_16 2  /* 16-bit CRC */
 #define LMC_CRC_LEN_32 4
 
-#ifdef LMC_HDLC
-/* definition of an hdlc header. */
-struct hdlc_hdr
-{
-	u8  address;
-	u8  control;
-	u16 type;
-};
-
-/* definition of a slarp header. */
-struct slarp
-{
-	long code;
-	union sl
-	{
-		struct
-		{
-			ulong address;
-			ulong mask;
-			ushort unused;
-		} add;
-		struct
-		{
-			ulong mysequence;
-			ulong yoursequence;
-			ushort reliability;
-			ulong time;
-		} chk;
-	} t;
-};
-#endif /* LMC_HDLC */
-
-
 #endif /* _LMC_VAR_H_ */
diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index 63e9fcf..2e4f84f 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -100,31 +100,14 @@
 #define	_PC300_H
 
 #include <linux/hdlc.h>
-#include <net/syncppp.h>
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
-#ifndef CY_TYPES
-#define CY_TYPES
-typedef	__u64	ucdouble;	/* 64 bits, unsigned */
-typedef	__u32	uclong;		/* 32 bits, unsigned */
-typedef	__u16	ucshort;	/* 16 bits, unsigned */
-typedef	__u8	ucchar;		/* 8 bits, unsigned */
-#endif /* CY_TYPES */
+#define PC300_PROTO_MLPPP 1
 
-#define PC300_PROTO_MLPPP 1		
-
-#define PC300_KERNEL	"2.4.x"	/* Kernel supported by this driver */
-
-#define	PC300_DEVNAME	"hdlc"	/* Dev. name base (for hdlc0, hdlc1, etc.) */
-#define PC300_MAXINDEX	100	/* Max dev. name index (the '0' in hdlc0) */
-
-#define	PC300_MAXCARDS	4	/* Max number of cards per system */
 #define	PC300_MAXCHAN	2	/* Number of channels per card */
 
-#define	PC300_PLX_WIN	0x80    /* PLX control window size (128b) */
 #define	PC300_RAMSIZE	0x40000 /* RAM window size (256Kb) */
-#define	PC300_SCASIZE	0x400   /* SCA window size (1Kb) */
 #define	PC300_FALCSIZE	0x400	/* FALC window size (1Kb) */
 
 #define PC300_OSC_CLOCK	24576000
@@ -160,26 +143,14 @@ typedef	__u8	ucchar;		/* 8 bits, unsigned */
  * Memory access functions/macros      *
  * (required to support Alpha systems) *
  ***************************************/
-#ifdef __KERNEL__
-#define cpc_writeb(port,val)	{writeb((ucchar)(val),(port)); mb();}
+#define cpc_writeb(port,val)	{writeb((u8)(val),(port)); mb();}
 #define cpc_writew(port,val)	{writew((ushort)(val),(port)); mb();}
-#define cpc_writel(port,val)	{writel((uclong)(val),(port)); mb();}
+#define cpc_writel(port,val)	{writel((u32)(val),(port)); mb();}
 
 #define cpc_readb(port)		readb(port)
 #define cpc_readw(port)		readw(port)
 #define cpc_readl(port)		readl(port)
 
-#else /* __KERNEL__ */
-#define cpc_writeb(port,val)	(*(volatile ucchar *)(port) = (ucchar)(val))
-#define cpc_writew(port,val)	(*(volatile ucshort *)(port) = (ucshort)(val))
-#define cpc_writel(port,val)	(*(volatile uclong *)(port) = (uclong)(val))
-
-#define cpc_readb(port)		(*(volatile ucchar *)(port))
-#define cpc_readw(port)		(*(volatile ucshort *)(port))
-#define cpc_readl(port)		(*(volatile uclong *)(port))
-
-#endif /* __KERNEL__ */
-
 /****** Data Structures *****************************************************/
 
 /*
@@ -188,15 +159,15 @@ typedef	__u8	ucchar;		/* 8 bits, unsigned */
  *      (memory mapped).
  */
 struct RUNTIME_9050 {
-	uclong	loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
-	uclong	loc_rom_range;		/* 10h : Local ROM Range */
-	uclong	loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
-	uclong	loc_rom_base;		/* 24h : Local ROM Base */
-	uclong	loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
-	uclong	rom_bus_descr;		/* 38h : ROM Bus Descriptor */
-	uclong	cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
-	uclong	intr_ctrl_stat;		/* 4Ch : Interrupt Control/Status */
-	uclong	init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
+	u32 loc_addr_range[4];	/* 00-0Ch : Local Address Ranges */
+	u32 loc_rom_range;	/* 10h : Local ROM Range */
+	u32 loc_addr_base[4];	/* 14-20h : Local Address Base Addrs */
+	u32 loc_rom_base;	/* 24h : Local ROM Base */
+	u32 loc_bus_descr[4];	/* 28-34h : Local Bus Descriptors */
+	u32 rom_bus_descr;	/* 38h : ROM Bus Descriptor */
+	u32 cs_base[4];		/* 3C-48h : Chip Select Base Addrs */
+	u32 intr_ctrl_stat;	/* 4Ch : Interrupt Control/Status */
+	u32 init_ctrl;		/* 50h : EEPROM ctrl, Init Ctrl, etc */
 };
 
 #define PLX_9050_LINT1_ENABLE	0x01
@@ -240,66 +211,66 @@ struct RUNTIME_9050 {
 #define PC300_FALC_MAXLOOP	0x0000ffff	/* for falc_issue_cmd() */
 
 typedef struct falc {
-	ucchar sync;		/* If true FALC is synchronized */
-	ucchar active;		/* if TRUE then already active */
-	ucchar loop_active;	/* if TRUE a line loopback UP was received */
-	ucchar loop_gen;	/* if TRUE a line loopback UP was issued */
+	u8 sync;	/* If true FALC is synchronized */
+	u8 active;	/* if TRUE then already active */
+	u8 loop_active;	/* if TRUE a line loopback UP was received */
+	u8 loop_gen;	/* if TRUE a line loopback UP was issued */
 
-	ucchar num_channels;
-	ucchar offset;		/* 1 for T1, 0 for E1 */
-	ucchar full_bandwidth;
+	u8 num_channels;
+	u8 offset;	/* 1 for T1, 0 for E1 */
+	u8 full_bandwidth;
 
-	ucchar xmb_cause;
-	ucchar multiframe_mode;
+	u8 xmb_cause;
+	u8 multiframe_mode;
 
 	/* Statistics */
-	ucshort pden;	/* Pulse Density violation count */
-	ucshort los;	/* Loss of Signal count */
-	ucshort losr;	/* Loss of Signal recovery count */
-	ucshort lfa;	/* Loss of frame alignment count */
-	ucshort farec;	/* Frame Alignment Recovery count */
-	ucshort lmfa;	/* Loss of multiframe alignment count */
-	ucshort ais;	/* Remote Alarm indication Signal count */
-	ucshort sec;	/* One-second timer */
-	ucshort es;	/* Errored second */
-	ucshort rai;	/* remote alarm received */
-	ucshort bec;
-	ucshort fec;
-	ucshort cvc;
-	ucshort cec;
-	ucshort ebc;
+	u16 pden;	/* Pulse Density violation count */
+	u16 los;	/* Loss of Signal count */
+	u16 losr;	/* Loss of Signal recovery count */
+	u16 lfa;	/* Loss of frame alignment count */
+	u16 farec;	/* Frame Alignment Recovery count */
+	u16 lmfa;	/* Loss of multiframe alignment count */
+	u16 ais;	/* Remote Alarm indication Signal count */
+	u16 sec;	/* One-second timer */
+	u16 es;		/* Errored second */
+	u16 rai;	/* remote alarm received */
+	u16 bec;
+	u16 fec;
+	u16 cvc;
+	u16 cec;
+	u16 ebc;
 
 	/* Status */
-	ucchar red_alarm;
-	ucchar blue_alarm;
-	ucchar loss_fa;
-	ucchar yellow_alarm;
-	ucchar loss_mfa;
-	ucchar prbs;
+	u8 red_alarm;
+	u8 blue_alarm;
+	u8 loss_fa;
+	u8 yellow_alarm;
+	u8 loss_mfa;
+	u8 prbs;
 } falc_t;
 
 typedef struct falc_status {
-	ucchar sync;  /* If true FALC is synchronized */
-	ucchar red_alarm;
-	ucchar blue_alarm;
-	ucchar loss_fa;
-	ucchar yellow_alarm;
-	ucchar loss_mfa;
-	ucchar prbs;
+	u8 sync;	/* If true FALC is synchronized */
+	u8 red_alarm;
+	u8 blue_alarm;
+	u8 loss_fa;
+	u8 yellow_alarm;
+	u8 loss_mfa;
+	u8 prbs;
 } falc_status_t;
 
 typedef struct rsv_x21_status {
-	ucchar dcd;
-	ucchar dsr;
-	ucchar cts;
-	ucchar rts;
-	ucchar dtr;
+	u8 dcd;
+	u8 dsr;
+	u8 cts;
+	u8 rts;
+	u8 dtr;
 } rsv_x21_status_t;
 
 typedef struct pc300stats {
 	int hw_type;
-	uclong line_on;
-	uclong line_off;
+	u32 line_on;
+	u32 line_off;
 	struct net_device_stats gen_stats;
 	falc_t te_stats;
 } pc300stats_t;
@@ -317,28 +288,19 @@ typedef struct pc300loopback {
 
 typedef struct pc300patterntst {
 	char patrntst_on;       /* 0 - off; 1 - on; 2 - read num_errors */
-	ucshort num_errors;
+	u16 num_errors;
 } pc300patterntst_t;
 
 typedef struct pc300dev {
-	void *if_ptr;		/* General purpose pointer */
 	struct pc300ch *chan;
-	ucchar trace_on;
-	uclong line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
-	uclong line_off;
-#ifdef __KERNEL__
+	u8 trace_on;
+	u32 line_on;		/* DCD(X.21, RSV) / sync(TE) change counters */
+	u32 line_off;
 	char name[16];
 	struct net_device *dev;
-
-	void *private;
-	struct sk_buff *tx_skb;
-	union {	/* This union has all the protocol-specific structures */
-		struct ppp_device pppdev;
-	}ifu;
 #ifdef CONFIG_PC300_MLPPP
 	void *cpc_tty;	/* information to PC300 TTY driver */
 #endif
-#endif /* __KERNEL__ */
 }pc300dev_t;
 
 typedef struct pc300hw {
@@ -346,43 +308,42 @@ typedef struct pc300hw {
 	int bus;		/* Bus (PCI, PMC, etc.) */
 	int nchan;		/* number of channels */
 	int irq;		/* interrupt request level */
-	uclong clock;		/* Board clock */
-	ucchar cpld_id;		/* CPLD ID (TE only) */
-	ucshort cpld_reg1;	/* CPLD reg 1 (TE only) */
-	ucshort cpld_reg2;	/* CPLD reg 2 (TE only) */
-	ucshort gpioc_reg;	/* PLX GPIOC reg */
-	ucshort intctl_reg;	/* PLX Int Ctrl/Status reg */
-	uclong iophys;		/* PLX registers I/O base */
-	uclong iosize;		/* PLX registers I/O size */
-	uclong plxphys;		/* PLX registers MMIO base (physical) */
+	u32 clock;		/* Board clock */
+	u8 cpld_id;		/* CPLD ID (TE only) */
+	u16 cpld_reg1;		/* CPLD reg 1 (TE only) */
+	u16 cpld_reg2;		/* CPLD reg 2 (TE only) */
+	u16 gpioc_reg;		/* PLX GPIOC reg */
+	u16 intctl_reg;		/* PLX Int Ctrl/Status reg */
+	u32 iophys;		/* PLX registers I/O base */
+	u32 iosize;		/* PLX registers I/O size */
+	u32 plxphys;		/* PLX registers MMIO base (physical) */
 	void __iomem * plxbase;	/* PLX registers MMIO base (virtual) */
-	uclong plxsize;		/* PLX registers MMIO size */
-	uclong scaphys;		/* SCA registers MMIO base (physical) */
+	u32 plxsize;		/* PLX registers MMIO size */
+	u32 scaphys;		/* SCA registers MMIO base (physical) */
 	void __iomem * scabase;	/* SCA registers MMIO base (virtual) */
-	uclong scasize;		/* SCA registers MMIO size */
-	uclong ramphys;		/* On-board RAM MMIO base (physical) */
+	u32 scasize;		/* SCA registers MMIO size */
+	u32 ramphys;		/* On-board RAM MMIO base (physical) */
 	void __iomem * rambase;	/* On-board RAM MMIO base (virtual) */
-	uclong alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
-	uclong ramsize;		/* On-board RAM MMIO size */
-	uclong falcphys;	/* FALC registers MMIO base (physical) */
+	u32 alloc_ramsize;	/* RAM MMIO size allocated by the PCI bridge */
+	u32 ramsize;		/* On-board RAM MMIO size */
+	u32 falcphys;		/* FALC registers MMIO base (physical) */
 	void __iomem * falcbase;/* FALC registers MMIO base (virtual) */
-	uclong falcsize;	/* FALC registers MMIO size */
+	u32 falcsize;		/* FALC registers MMIO size */
 } pc300hw_t;
 
 typedef struct pc300chconf {
-	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps), 
+	sync_serial_settings	phys_settings;	/* Clock type/rate (in bps),
 						   loopback mode */
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
-	uclong media;		/* HW media (RS232, V.35, etc.) */
-	uclong proto;		/* Protocol (PPP, X.25, etc.) */
-	ucchar monitor;		/* Monitor mode (0 = off, !0 = on) */
+	u32 media;		/* HW media (RS232, V.35, etc.) */
+	u32 proto;		/* Protocol (PPP, X.25, etc.) */
 
 	/* TE-specific parameters */
-	ucchar lcode;		/* Line Code (AMI, B8ZS, etc.) */
-	ucchar fr_mode;		/* Frame Mode (ESF, D4, etc.) */
-	ucchar lbo;		/* Line Build Out */
-	ucchar rx_sens;		/* Rx Sensitivity (long- or short-haul) */
-	uclong tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
+	u8 lcode;		/* Line Code (AMI, B8ZS, etc.) */
+	u8 fr_mode;		/* Frame Mode (ESF, D4, etc.) */
+	u8 lbo;			/* Line Build Out */
+	u8 rx_sens;		/* Rx Sensitivity (long- or short-haul) */
+	u32 tslot_bitmap;	/* bit[i]=1  =>  timeslot _i_ is active */
 } pc300chconf_t;
 
 typedef struct pc300ch {
@@ -390,20 +351,18 @@ typedef struct pc300ch {
 	int channel;
 	pc300dev_t d;
 	pc300chconf_t conf;
-	ucchar tx_first_bd;	/* First TX DMA block descr. w/ data */
-	ucchar tx_next_bd;	/* Next free TX DMA block descriptor */
-	ucchar rx_first_bd;	/* First free RX DMA block descriptor */
-	ucchar rx_last_bd;	/* Last free RX DMA block descriptor */
-	ucchar nfree_tx_bd;	/* Number of free TX DMA block descriptors */
-	falc_t falc;		/* FALC structure (TE only) */
+	u8 tx_first_bd;	/* First TX DMA block descr. w/ data */
+	u8 tx_next_bd;	/* Next free TX DMA block descriptor */
+	u8 rx_first_bd;	/* First free RX DMA block descriptor */
+	u8 rx_last_bd;	/* Last free RX DMA block descriptor */
+	u8 nfree_tx_bd;	/* Number of free TX DMA block descriptors */
+	falc_t falc;	/* FALC structure (TE only) */
 } pc300ch_t;
 
 typedef struct pc300 {
 	pc300hw_t hw;			/* hardware config. */
 	pc300ch_t chan[PC300_MAXCHAN];
-#ifdef __KERNEL__
 	spinlock_t card_lock;
-#endif /* __KERNEL__ */
 } pc300_t;
 
 typedef struct pc300conf {
@@ -471,12 +430,7 @@ enum pc300_loopback_cmds {
 #define PC300_TX_QUEUE_LEN	100
 #define	PC300_DEF_MTU		1600
 
-#ifdef __KERNEL__
 /* Function Prototypes */
-void tx_dma_start(pc300_t *, int);
 int cpc_open(struct net_device *dev);
-int cpc_set_media(hdlc_device *, int);
-#endif /* __KERNEL__ */
 
 #endif	/* _PC300_H */
-
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 3341705..d0a8d1e 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -227,8 +227,6 @@ static char rcsid[] =
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/if.h>
-
-#include <net/syncppp.h>
 #include <net/arp.h>
 
 #include <asm/io.h>
@@ -285,8 +283,8 @@ static void rx_dma_buf_init(pc300_t *, int);
 static void tx_dma_buf_check(pc300_t *, int);
 static void rx_dma_buf_check(pc300_t *, int);
 static irqreturn_t cpc_intr(int, void *);
-static int clock_rate_calc(uclong, uclong, int *);
-static uclong detect_ram(pc300_t *);
+static int clock_rate_calc(u32, u32, int *);
+static u32 detect_ram(pc300_t *);
 static void plx_init(pc300_t *);
 static void cpc_trace(struct net_device *, struct sk_buff *, char);
 static int cpc_attach(struct net_device *, unsigned short, unsigned short);
@@ -311,10 +309,10 @@ static void tx_dma_buf_pt_init(pc300_t * card, int ch)
 			               + DMA_TX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_TX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (uclong) (DMA_TX_BD_BASE +
+		cpc_writel(&ptdescr->next, (u32)(DMA_TX_BD_BASE +
 			(ch_factor + ((i + 1) & (N_DMA_TX_BUF - 1))) * sizeof(pcsca_bd_t)));
-		cpc_writel(&ptdescr->ptbuf, 
-						(uclong) (DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
+		cpc_writel(&ptdescr->ptbuf,
+			   (u32)(DMA_TX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -341,10 +339,10 @@ static void rx_dma_buf_pt_init(pc300_t * card, int ch)
 				       + DMA_RX_BD_BASE + ch_factor * sizeof(pcsca_bd_t));
 
 	for (i = 0; i < N_DMA_RX_BUF; i++, ptdescr++) {
-		cpc_writel(&ptdescr->next, (uclong) (DMA_RX_BD_BASE +
-	     	(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
+		cpc_writel(&ptdescr->next, (u32)(DMA_RX_BD_BASE +
+			(ch_factor + ((i + 1) & (N_DMA_RX_BUF - 1))) * sizeof(pcsca_bd_t)));
 		cpc_writel(&ptdescr->ptbuf,
-			   (uclong) (DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
+			   (u32)(DMA_RX_BASE + (ch_factor + i) * BD_DEF_LEN));
 	}
 }
 
@@ -367,8 +365,8 @@ static void tx_dma_buf_check(pc300_t * card, int ch)
 {
 	volatile pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].tx_first_bd;
-	ucshort next_bd = card->chan[ch].tx_next_bd;
+	u16 first_bd = card->chan[ch].tx_first_bd;
+	u16 next_bd = card->chan[ch].tx_next_bd;
 
 	printk("#CH%d: f_bd = %d(0x%08zx), n_bd = %d(0x%08zx)\n", ch,
 	       first_bd, TX_BD_ADDR(ch, first_bd),
@@ -392,9 +390,9 @@ static void tx1_dma_buf_check(pc300_t * card, int ch)
 {
 	volatile pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].tx_first_bd;
-	ucshort next_bd = card->chan[ch].tx_next_bd;
-	uclong scabase = card->hw.scabase;
+	u16 first_bd = card->chan[ch].tx_first_bd;
+	u16 next_bd = card->chan[ch].tx_next_bd;
+	u32 scabase = card->hw.scabase;
 
 	printk ("\nnfree_tx_bd = %d \n", card->chan[ch].nfree_tx_bd);
 	printk("#CH%d: f_bd = %d(0x%08x), n_bd = %d(0x%08x)\n", ch,
@@ -413,13 +411,13 @@ static void tx1_dma_buf_check(pc300_t * card, int ch)
 	printk("\n");
 }
 #endif
-			 
+
 static void rx_dma_buf_check(pc300_t * card, int ch)
 {
 	volatile pcsca_bd_t __iomem *ptdescr;
 	int i;
-	ucshort first_bd = card->chan[ch].rx_first_bd;
-	ucshort last_bd = card->chan[ch].rx_last_bd;
+	u16 first_bd = card->chan[ch].rx_first_bd;
+	u16 last_bd = card->chan[ch].rx_last_bd;
 	int ch_factor;
 
 	ch_factor = ch * N_DMA_RX_BUF;
@@ -440,9 +438,9 @@ static void rx_dma_buf_check(pc300_t * card, int ch)
 static int dma_get_rx_frame_size(pc300_t * card, int ch)
 {
 	volatile pcsca_bd_t __iomem *ptdescr;
-	ucshort first_bd = card->chan[ch].rx_first_bd;
+	u16 first_bd = card->chan[ch].rx_first_bd;
 	int rcvd = 0;
-	volatile ucchar status;
+	volatile u8 status;
 
 	ptdescr = (card->hw.rambase + RX_BD_ADDR(ch, first_bd));
 	while ((status = cpc_readb(&ptdescr->status)) & DST_OSB) {
@@ -462,12 +460,12 @@ static int dma_get_rx_frame_size(pc300_t * card, int ch)
  * dma_buf_write: writes a frame to the Tx DMA buffers
  * NOTE: this function writes one frame at a time.
  */
-static int dma_buf_write(pc300_t * card, int ch, ucchar * ptdata, int len)
+static int dma_buf_write(pc300_t *card, int ch, u8 *ptdata, int len)
 {
 	int i, nchar;
 	volatile pcsca_bd_t __iomem *ptdescr;
 	int tosend = len;
-	ucchar nbuf = ((len - 1) / BD_DEF_LEN) + 1;
+	u8 nbuf = ((len - 1) / BD_DEF_LEN) + 1;
 
 	if (nbuf >= card->chan[ch].nfree_tx_bd) {
 		return -ENOMEM;
@@ -509,7 +507,7 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	volatile pcsca_bd_t __iomem *ptdescr;
 	int rcvd = 0;
-	volatile ucchar status;
+	volatile u8 status;
 
 	ptdescr = (card->hw.rambase +
 				  RX_BD_ADDR(ch, chan->rx_first_bd));
@@ -563,8 +561,8 @@ static int dma_buf_read(pc300_t * card, int ch, struct sk_buff *skb)
 static void tx_dma_stop(pc300_t * card, int ch)
 {
 	void __iomem *scabase = card->hw.scabase;
-	ucchar drr_ena_bit = 1 << (5 + 2 * ch);
-	ucchar drr_rst_bit = 1 << (1 + 2 * ch);
+	u8 drr_ena_bit = 1 << (5 + 2 * ch);
+	u8 drr_rst_bit = 1 << (1 + 2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
@@ -574,8 +572,8 @@ static void tx_dma_stop(pc300_t * card, int ch)
 static void rx_dma_stop(pc300_t * card, int ch)
 {
 	void __iomem *scabase = card->hw.scabase;
-	ucchar drr_ena_bit = 1 << (4 + 2 * ch);
-	ucchar drr_rst_bit = 1 << (2 * ch);
+	u8 drr_ena_bit = 1 << (4 + 2 * ch);
+	u8 drr_rst_bit = 1 << (2 * ch);
 
 	/* Disable DMA */
 	cpc_writeb(scabase + DRR, drr_ena_bit);
@@ -607,7 +605,7 @@ static void rx_dma_start(pc300_t * card, int ch)
 /*************************/
 /***   FALC Routines   ***/
 /*************************/
-static void falc_issue_cmd(pc300_t * card, int ch, ucchar cmd)
+static void falc_issue_cmd(pc300_t *card, int ch, u8 cmd)
 {
 	void __iomem *falcbase = card->hw.falcbase;
 	unsigned long i = 0;
@@ -675,7 +673,7 @@ static void falc_intr_enable(pc300_t * card, int ch)
 static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 {
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar tshf = card->chan[ch].falc.offset;
+	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) & 
@@ -691,7 +689,7 @@ static void falc_open_timeslot(pc300_t * card, int ch, int timeslot)
 static void falc_close_timeslot(pc300_t * card, int ch, int timeslot)
 {
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar tshf = card->chan[ch].falc.offset;
+	u8 tshf = card->chan[ch].falc.offset;
 
 	cpc_writeb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch),
 		   cpc_readb(falcbase + F_REG((ICB1 + (timeslot - tshf) / 8), ch)) | 
@@ -812,7 +810,7 @@ static void falc_init_t1(pc300_t * card, int ch)
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to T1 mode (PCM 24) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch), FMR1_PMOD);
@@ -981,7 +979,7 @@ static void falc_init_e1(pc300_t * card, int ch)
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
+	u8 dja = (ch ? (LIM2_DJA2 | LIM2_DJA1) : 0);
 
 	/* Switch to E1 mode (PCM 30) */
 	cpc_writeb(falcbase + F_REG(FMR1, ch),
@@ -1187,7 +1185,7 @@ static void te_config(pc300_t * card, int ch)
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar dummy;
+	u8 dummy;
 	unsigned long flags;
 
 	memset(pfalc, 0, sizeof(falc_t));
@@ -1403,7 +1401,7 @@ static void falc_update_stats(pc300_t * card, int ch)
 	pc300chconf_t *conf = (pc300chconf_t *) & chan->conf;
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucshort counter;
+	u16 counter;
 
 	counter = cpc_readb(falcbase + F_REG(FECL, ch));
 	counter |= cpc_readb(falcbase + F_REG(FECH, ch)) << 8;
@@ -1729,7 +1727,7 @@ static void falc_pattern_test(pc300_t * card, int ch, unsigned int activate)
  * Description:	This routine returns the bit error counter value
  *----------------------------------------------------------------------------
  */
-static ucshort falc_pattern_test_error(pc300_t * card, int ch)
+static u16 falc_pattern_test_error(pc300_t * card, int ch)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -1776,7 +1774,7 @@ static void cpc_tx_timeout(struct net_device *dev)
 	pc300_t *card = (pc300_t *) chan->card;
 	int ch = chan->channel;
 	unsigned long flags;
-	ucchar ilar;
+	u8 ilar;
 
 	dev->stats.tx_errors++;
 	dev->stats.tx_aborted_errors++;
@@ -1807,11 +1805,7 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i;
 #endif
 
-	if (chan->conf.monitor) {
-		/* In monitor mode no Tx is done: ignore packet */
-		dev_kfree_skb(skb);
-		return 0;
-	} else if (!netif_carrier_ok(dev)) {
+	if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
 		dev->stats.tx_errors++;
@@ -1836,7 +1830,7 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Write buffer to DMA buffers */
-	if (dma_buf_write(card, ch, (ucchar *) skb->data, skb->len) != 0) {
+	if (dma_buf_write(card, ch, (u8 *)skb->data, skb->len) != 0) {
 //		printk("%s: write error. Dropping TX packet.\n", dev->name);
 		netif_stop_queue(dev);
 		dev_kfree_skb(skb);
@@ -2001,7 +1995,7 @@ static void sca_tx_intr(pc300dev_t *dev)
 static void sca_intr(pc300_t * card)
 {
 	void __iomem *scabase = card->hw.scabase;
-	volatile uclong status;
+	volatile u32 status;
 	int ch;
 	int intr_count = 0;
 	unsigned char dsr_rx;
@@ -2016,7 +2010,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Reception ****/
 			if (status & IR0_DRX((IR0_DMIA | IR0_DMIB), ch)) {
-				ucchar drx_stat = cpc_readb(scabase + DSR_RX(ch));
+				u8 drx_stat = cpc_readb(scabase + DSR_RX(ch));
 
 				/* Clear RX interrupts */
 				cpc_writeb(scabase + DSR_RX(ch), drx_stat | DSR_DWE);
@@ -2090,7 +2084,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** Transmission ****/
 			if (status & IR0_DTX((IR0_EFT | IR0_DMIA | IR0_DMIB), ch)) {
-				ucchar dtx_stat = cpc_readb(scabase + DSR_TX(ch));
+				u8 dtx_stat = cpc_readb(scabase + DSR_TX(ch));
 
 				/* Clear TX interrupts */
 				cpc_writeb(scabase + DSR_TX(ch), dtx_stat | DSR_DWE);
@@ -2134,7 +2128,7 @@ static void sca_intr(pc300_t * card)
 
 	    /**** MSCI ****/
 			if (status & IR0_M(IR0_RXINTA, ch)) {
-				ucchar st1 = cpc_readb(scabase + M_REG(ST1, ch));
+				u8 st1 = cpc_readb(scabase + M_REG(ST1, ch));
 
 				/* Clear MSCI interrupts */
 				cpc_writeb(scabase + M_REG(ST1, ch), st1);
@@ -2176,7 +2170,7 @@ static void sca_intr(pc300_t * card)
 	}
 }
 
-static void falc_t1_loop_detection(pc300_t * card, int ch, ucchar frs1)
+static void falc_t1_loop_detection(pc300_t *card, int ch, u8 frs1)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -2201,7 +2195,7 @@ static void falc_t1_loop_detection(pc300_t * card, int ch, ucchar frs1)
 	}
 }
 
-static void falc_e1_loop_detection(pc300_t * card, int ch, ucchar rsp)
+static void falc_e1_loop_detection(pc300_t *card, int ch, u8 rsp)
 {
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
@@ -2231,8 +2225,8 @@ static void falc_t1_intr(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar isr0, isr3, gis;
-	ucchar dummy;
+	u8 isr0, isr3, gis;
+	u8 dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		if (gis & GIS_ISR0) {
@@ -2278,8 +2272,8 @@ static void falc_e1_intr(pc300_t * card, int ch)
 	pc300ch_t *chan = (pc300ch_t *) & card->chan[ch];
 	falc_t *pfalc = (falc_t *) & chan->falc;
 	void __iomem *falcbase = card->hw.falcbase;
-	ucchar isr1, isr2, isr3, gis, rsp;
-	ucchar dummy;
+	u8 isr1, isr2, isr3, gis, rsp;
+	u8 dummy;
 
 	while ((gis = cpc_readb(falcbase + F_REG(GIS, ch))) != 0) {
 		rsp = cpc_readb(falcbase + F_REG(RSP, ch));
@@ -2361,7 +2355,7 @@ static void falc_intr(pc300_t * card)
 static irqreturn_t cpc_intr(int irq, void *dev_id)
 {
 	pc300_t *card = dev_id;
-	volatile ucchar plx_status;
+	volatile u8 plx_status;
 
 	if (!card) {
 #ifdef PC300_DEBUG_INTR
@@ -2400,7 +2394,7 @@ static irqreturn_t cpc_intr(int irq, void *dev_id)
 
 static void cpc_sca_status(pc300_t * card, int ch)
 {
-	ucchar ilar;
+	u8 ilar;
 	void __iomem *scabase = card->hw.scabase;
 	unsigned long flags;
 
@@ -2818,7 +2812,7 @@ static int cpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	}
 }
 
-static int clock_rate_calc(uclong rate, uclong clock, int *br_io)
+static int clock_rate_calc(u32 rate, u32 clock, int *br_io)
 {
 	int br, tc;
 	int br_pwr, error;
@@ -2855,12 +2849,12 @@ static int ch_config(pc300dev_t * d)
 	void __iomem *scabase = card->hw.scabase;
 	void __iomem *plxbase = card->hw.plxbase;
 	int ch = chan->channel;
-	uclong clkrate = chan->conf.phys_settings.clock_rate;
-	uclong clktype = chan->conf.phys_settings.clock_type;
-	ucshort encoding = chan->conf.proto_settings.encoding;
-	ucshort parity = chan->conf.proto_settings.parity;   
-	ucchar md0, md2;
-    
+	u32 clkrate = chan->conf.phys_settings.clock_rate;
+	u32 clktype = chan->conf.phys_settings.clock_type;
+	u16 encoding = chan->conf.proto_settings.encoding;
+	u16 parity = chan->conf.proto_settings.parity;
+	u8 md0, md2;
+
 	/* Reset the channel */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_CH_RST);
 
@@ -3152,19 +3146,10 @@ int cpc_open(struct net_device *dev)
 	printk("pc300: cpc_open");
 #endif
 
-#ifdef FIXME
-	if (hdlc->proto.id == IF_PROTO_PPP) {
-		d->if_ptr = &hdlc->state.ppp.pppdev;
-	}
-#endif
-
 	result = hdlc_open(dev);
-	if (/* FIXME hdlc->proto.id == IF_PROTO_PPP*/ 0) {
-		dev->priv = d;
-	}
-	if (result) {
+
+	if (result)
 		return result;
-	}
 
 	sprintf(ifr.ifr_name, "%s", dev->name);
 	result = cpc_opench(d);
@@ -3197,9 +3182,7 @@ static int cpc_close(struct net_device *dev)
 	CPC_UNLOCK(card, flags);
 
 	hdlc_close(dev);
-	if (/* FIXME hdlc->proto.id == IF_PROTO_PPP*/ 0) {
-		d->if_ptr = NULL;
-	}
+
 #ifdef CONFIG_PC300_MLPPP
 	if (chan->conf.proto == PC300_PROTO_MLPPP) {
 		cpc_tty_unregister_service(d);
@@ -3210,16 +3193,16 @@ static int cpc_close(struct net_device *dev)
 	return 0;
 }
 
-static uclong detect_ram(pc300_t * card)
+static u32 detect_ram(pc300_t * card)
 {
-	uclong i;
-	ucchar data;
+	u32 i;
+	u8 data;
 	void __iomem *rambase = card->hw.rambase;
 
 	card->hw.ramsize = PC300_RAMSIZE;
 	/* Let's find out how much RAM is present on this board */
 	for (i = 0; i < card->hw.ramsize; i++) {
-		data = (ucchar) (i & 0xff);
+		data = (u8)(i & 0xff);
 		cpc_writeb(rambase + i, data);
 		if (cpc_readb(rambase + i) != data) {
 			break;
@@ -3296,7 +3279,7 @@ static void cpc_init_card(pc300_t * card)
 	cpc_writeb(card->hw.scabase + DMER, 0x80);
 
 	if (card->hw.type == PC300_TE) {
-		ucchar reg1;
+		u8 reg1;
 
 		/* Check CPLD version */
 		reg1 = cpc_readb(card->hw.falcbase + CPLD_REG1);
@@ -3360,7 +3343,6 @@ static void cpc_init_card(pc300_t * card)
 		chan->nfree_tx_bd = N_DMA_TX_BUF;
 
 		d->chan = chan;
-		d->tx_skb = NULL;
 		d->trace_on = 0;
 		d->line_on = 0;
 		d->line_off = 0;
@@ -3431,7 +3413,7 @@ cpc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	static int first_time = 1;
 	int err, eeprom_outdated = 0;
-	ucshort device_id;
+	u16 device_id;
 	pc300_t *card;
 
 	if (first_time) {
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 44a89df..c023584 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -8,6 +8,7 @@
  *
  *	(c) Copyright 1999, 2001 Alan Cox
  *	(c) Copyright 2001 Red Hat Inc.
+ *	Generic HDLC port Copyright (C) 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  */
 
@@ -19,6 +20,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <net/arp.h>
@@ -27,22 +29,19 @@
 #include <asm/io.h>
 #include <asm/dma.h>
 #include <asm/byteorder.h>
-#include <net/syncppp.h>
 #include "z85230.h"
 
 
 struct slvl_device
 {
-	void *if_ptr;	/* General purpose pointer (used by SPPP) */
 	struct z8530_channel *chan;
-	struct ppp_device pppdev;
 	int channel;
 };
 
 
 struct slvl_board
 {
-	struct slvl_device *dev[2];
+	struct slvl_device dev[2];
 	struct z8530_dev board;
 	int iobase;
 };
@@ -51,72 +50,69 @@ struct slvl_board
  *	Network driver support routines
  */
 
+static inline struct slvl_device* dev_to_chan(struct net_device *dev)
+{
+	return (struct slvl_device *)dev_to_hdlc(dev)->priv;
+}
+
 /*
- *	Frame receive. Simple for our card as we do sync ppp and there
+ *	Frame receive. Simple for our card as we do HDLC and there
  *	is no funny garbage involved
  */
- 
+
 static void sealevel_input(struct z8530_channel *c, struct sk_buff *skb)
 {
 	/* Drop the CRC - it's not a good idea to try and negotiate it ;) */
-	skb_trim(skb, skb->len-2);
-	skb->protocol=htons(ETH_P_WAN_PPP);
+	skb_trim(skb, skb->len - 2);
+	skb->protocol = hdlc_type_trans(skb, c->netdevice);
 	skb_reset_mac_header(skb);
-	skb->dev=c->netdevice;
-	/*
-	 *	Send it to the PPP layer. We don't have time to process
-	 *	it right now.
-	 */
+	skb->dev = c->netdevice;
 	netif_rx(skb);
 	c->netdevice->last_rx = jiffies;
 }
- 
+
 /*
  *	We've been placed in the UP state
- */ 
- 
+ */
+
 static int sealevel_open(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl = dev_to_chan(d);
 	int err = -1;
 	int unit = slvl->channel;
-	
+
 	/*
-	 *	Link layer up. 
+	 *	Link layer up.
 	 */
 
-	switch(unit)
+	switch (unit)
 	{
 		case 0:
-			err=z8530_sync_dma_open(d, slvl->chan);
+			err = z8530_sync_dma_open(d, slvl->chan);
 			break;
 		case 1:
-			err=z8530_sync_open(d, slvl->chan);
+			err = z8530_sync_open(d, slvl->chan);
 			break;
 	}
-	
-	if(err)
+
+	if (err)
 		return err;
-	/*
-	 *	Begin PPP
-	 */
-	err=sppp_open(d);
-	if(err)
-	{
-		switch(unit)
-		{
+
+	err = hdlc_open(d);
+	if (err) {
+		switch (unit) {
 			case 0:
 				z8530_sync_dma_close(d, slvl->chan);
 				break;
 			case 1:
 				z8530_sync_close(d, slvl->chan);
 				break;
-		}				
+		}
 		return err;
 	}
-	
-	slvl->chan->rx_function=sealevel_input;
-	
+
+	slvl->chan->rx_function = sealevel_input;
+
 	/*
 	 *	Go go go
 	 */
@@ -126,26 +122,19 @@ static int sealevel_open(struct net_device *d)
 
 static int sealevel_close(struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
+	struct slvl_device *slvl = dev_to_chan(d);
 	int unit = slvl->channel;
-	
+
 	/*
 	 *	Discard new frames
 	 */
-	
-	slvl->chan->rx_function=z8530_null_rx;
-		
-	/*
-	 *	PPP off
-	 */
-	sppp_close(d);
-	/*
-	 *	Link layer down
-	 */
 
+	slvl->chan->rx_function = z8530_null_rx;
+
+	hdlc_close(d);
 	netif_stop_queue(d);
-		
-	switch(unit)
+
+	switch (unit)
 	{
 		case 0:
 			z8530_sync_dma_close(d, slvl->chan);
@@ -159,210 +148,153 @@ static int sealevel_close(struct net_device *d)
 
 static int sealevel_ioctl(struct net_device *d, struct ifreq *ifr, int cmd)
 {
-	/* struct slvl_device *slvl=d->priv;
+	/* struct slvl_device *slvl=dev_to_chan(d);
 	   z8530_ioctl(d,&slvl->sync.chanA,ifr,cmd) */
-	return sppp_do_ioctl(d, ifr,cmd);
-}
-
-static struct net_device_stats *sealevel_get_stats(struct net_device *d)
-{
-	struct slvl_device *slvl=d->priv;
-	if(slvl)
-		return z8530_get_stats(slvl->chan);
-	else
-		return NULL;
+	return hdlc_ioctl(d, ifr, cmd);
 }
 
 /*
- *	Passed PPP frames, fire them downwind.
+ *	Passed network frames, fire them downwind.
  */
- 
+
 static int sealevel_queue_xmit(struct sk_buff *skb, struct net_device *d)
 {
-	struct slvl_device *slvl=d->priv;
-	return z8530_queue_xmit(slvl->chan, skb);
+	return z8530_queue_xmit(dev_to_chan(d)->chan, skb);
 }
 
-static int sealevel_neigh_setup(struct neighbour *n)
+static int sealevel_attach(struct net_device *dev, unsigned short encoding,
+			   unsigned short parity)
 {
-	if (n->nud_state == NUD_NONE) {
-		n->ops = &arp_broken_ops;
-		n->output = n->ops->output;
-	}
-	return 0;
+	if (encoding == ENCODING_NRZ && parity == PARITY_CRC16_PR1_CCITT)
+		return 0;
+	return -EINVAL;
 }
 
-static int sealevel_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
+static int slvl_setup(struct slvl_device *sv, int iobase, int irq)
 {
-	if (p->tbl->family == AF_INET) {
-		p->neigh_setup = sealevel_neigh_setup;
-		p->ucast_probes = 0;
-		p->mcast_probes = 0;
+	struct net_device *dev = alloc_hdlcdev(sv);
+	if (!dev)
+		return -1;
+
+	dev_to_hdlc(dev)->attach = sealevel_attach;
+	dev_to_hdlc(dev)->xmit = sealevel_queue_xmit;
+	dev->open = sealevel_open;
+	dev->stop = sealevel_close;
+	dev->do_ioctl = sealevel_ioctl;
+	dev->base_addr = iobase;
+	dev->irq = irq;
+
+	if (register_hdlc_device(dev)) {
+		printk(KERN_ERR "sealevel: unable to register HDLC device\n");
+		free_netdev(dev);
+		return -1;
 	}
-	return 0;
-}
 
-static int sealevel_attach(struct net_device *dev)
-{
-	struct slvl_device *sv = dev->priv;
-	sppp_attach(&sv->pppdev);
+	sv->chan->netdevice = dev;
 	return 0;
 }
 
-static void sealevel_detach(struct net_device *dev)
-{
-	sppp_detach(dev);
-}
-		
-static void slvl_setup(struct net_device *d)
-{
-	d->open = sealevel_open;
-	d->stop = sealevel_close;
-	d->init = sealevel_attach;
-	d->uninit = sealevel_detach;
-	d->hard_start_xmit = sealevel_queue_xmit;
-	d->get_stats = sealevel_get_stats;
-	d->set_multicast_list = NULL;
-	d->do_ioctl = sealevel_ioctl;
-	d->neigh_setup = sealevel_neigh_setup_dev;
-	d->set_mac_address = NULL;
-
-}
-
-static inline struct slvl_device *slvl_alloc(int iobase, int irq)
-{
-	struct net_device *d;
-	struct slvl_device *sv;
-
-	d = alloc_netdev(sizeof(struct slvl_device), "hdlc%d",
-			 slvl_setup);
-
-	if (!d) 
-		return NULL;
-
-	sv = d->priv;
-	d->ml_priv = sv;
-	sv->if_ptr = &sv->pppdev;
-	sv->pppdev.dev = d;
-	d->base_addr = iobase;
-	d->irq = irq;
-		
-	return sv;
-}
-
 
 /*
  *	Allocate and setup Sealevel board.
  */
- 
-static __init struct slvl_board *slvl_init(int iobase, int irq, 
+
+static __init struct slvl_board *slvl_init(int iobase, int irq,
 					   int txdma, int rxdma, int slow)
 {
 	struct z8530_dev *dev;
 	struct slvl_board *b;
-	
+
 	/*
 	 *	Get the needed I/O space
 	 */
 
-	if(!request_region(iobase, 8, "Sealevel 4021")) 
-	{	
-		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n", iobase);
+	if (!request_region(iobase, 8, "Sealevel 4021")) {
+		printk(KERN_WARNING "sealevel: I/O 0x%X already in use.\n",
+		       iobase);
 		return NULL;
 	}
-	
-	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
-	if(!b)
-		goto fail3;
 
-	if (!(b->dev[0]= slvl_alloc(iobase, irq)))
-		goto fail2;
+	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
+	if (!b)
+		goto err_kzalloc;
 
-	b->dev[0]->chan = &b->board.chanA;	
-	b->dev[0]->channel = 0;
-	
-	if (!(b->dev[1] = slvl_alloc(iobase, irq)))
-		goto fail1_0;
+	b->dev[0].chan = &b->board.chanA;
+	b->dev[0].channel = 0;
 
-	b->dev[1]->chan = &b->board.chanB;
-	b->dev[1]->channel = 1;
+	b->dev[1].chan = &b->board.chanB;
+	b->dev[1].channel = 1;
 
 	dev = &b->board;
-	
+
 	/*
 	 *	Stuff in the I/O addressing
 	 */
-	 
+
 	dev->active = 0;
 
 	b->iobase = iobase;
-	
+
 	/*
 	 *	Select 8530 delays for the old board
 	 */
-	 
-	if(slow)
+
+	if (slow)
 		iobase |= Z8530_PORT_SLEEP;
-		
-	dev->chanA.ctrlio=iobase+1;
-	dev->chanA.dataio=iobase;
-	dev->chanB.ctrlio=iobase+3;
-	dev->chanB.dataio=iobase+2;
-	
-	dev->chanA.irqs=&z8530_nop;
-	dev->chanB.irqs=&z8530_nop;
-	
+
+	dev->chanA.ctrlio = iobase + 1;
+	dev->chanA.dataio = iobase;
+	dev->chanB.ctrlio = iobase + 3;
+	dev->chanB.dataio = iobase + 2;
+
+	dev->chanA.irqs = &z8530_nop;
+	dev->chanB.irqs = &z8530_nop;
+
 	/*
 	 *	Assert DTR enable DMA
 	 */
-	 
-	outb(3|(1<<7), b->iobase+4);	
-	
+
+	outb(3 | (1 << 7), b->iobase + 4);
+
 
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
-   
-	if(request_irq(irq, &z8530_interrupt, IRQF_DISABLED, "SeaLevel", dev)<0)
-	{
+
+	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+			"SeaLevel", dev) < 0) {
 		printk(KERN_WARNING "sealevel: IRQ %d already in use.\n", irq);
-		goto fail1_1;
+		goto err_request_irq;
 	}
-	
-	dev->irq=irq;
-	dev->chanA.private=&b->dev[0];
-	dev->chanB.private=&b->dev[1];
-	dev->chanA.netdevice=b->dev[0]->pppdev.dev;
-	dev->chanB.netdevice=b->dev[1]->pppdev.dev;
-	dev->chanA.dev=dev;
-	dev->chanB.dev=dev;
-
-	dev->chanA.txdma=3;
-	dev->chanA.rxdma=1;
-	if(request_dma(dev->chanA.txdma, "SeaLevel (TX)")!=0)
-		goto fail;
-		
-	if(request_dma(dev->chanA.rxdma, "SeaLevel (RX)")!=0)
-		goto dmafail;
-	
+
+	dev->irq = irq;
+	dev->chanA.private = &b->dev[0];
+	dev->chanB.private = &b->dev[1];
+	dev->chanA.dev = dev;
+	dev->chanB.dev = dev;
+
+	dev->chanA.txdma = 3;
+	dev->chanA.rxdma = 1;
+	if (request_dma(dev->chanA.txdma, "SeaLevel (TX)"))
+		goto err_dma_tx;
+
+	if (request_dma(dev->chanA.rxdma, "SeaLevel (RX)"))
+		goto err_dma_rx;
+
 	disable_irq(irq);
-		
+
 	/*
 	 *	Begin normal initialise
 	 */
-	 
-	if(z8530_init(dev)!=0)
-	{
+
+	if (z8530_init(dev) != 0) {
 		printk(KERN_ERR "Z8530 series device not found.\n");
 		enable_irq(irq);
-		goto dmafail2;
+		goto free_hw;
 	}
-	if(dev->type==Z85C30)
-	{
+	if (dev->type == Z85C30) {
 		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream);
 		z8530_channel_load(&dev->chanB, z8530_hdlc_kilostream);
-	}
-	else
-	{
+	} else {
 		z8530_channel_load(&dev->chanA, z8530_hdlc_kilostream_85230);
 		z8530_channel_load(&dev->chanB, z8530_hdlc_kilostream_85230);
 	}
@@ -370,36 +302,31 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/*
 	 *	Now we can take the IRQ
 	 */
-	
+
 	enable_irq(irq);
 
-	if (register_netdev(b->dev[0]->pppdev.dev)) 
-		goto dmafail2;
-		
-	if (register_netdev(b->dev[1]->pppdev.dev)) 
-		goto fail_unit;
+	if (slvl_setup(&b->dev[0], iobase, irq))
+		goto free_hw;
+	if (slvl_setup(&b->dev[1], iobase, irq))
+		goto free_netdev0;
 
 	z8530_describe(dev, "I/O", iobase);
-	dev->active=1;
+	dev->active = 1;
 	return b;
 
-fail_unit:
-	unregister_netdev(b->dev[0]->pppdev.dev);
-	
-dmafail2:
+free_netdev0:
+	unregister_hdlc_device(b->dev[0].chan->netdevice);
+	free_netdev(b->dev[0].chan->netdevice);
+free_hw:
 	free_dma(dev->chanA.rxdma);
-dmafail:
+err_dma_rx:
 	free_dma(dev->chanA.txdma);
-fail:
+err_dma_tx:
 	free_irq(irq, dev);
-fail1_1:
-	free_netdev(b->dev[1]->pppdev.dev);
-fail1_0:
-	free_netdev(b->dev[0]->pppdev.dev);
-fail2:
+err_request_irq:
 	kfree(b);
-fail3:
-	release_region(iobase,8);
+err_kzalloc:
+	release_region(iobase, 8);
 	return NULL;
 }
 
@@ -408,14 +335,14 @@ static void __exit slvl_shutdown(struct slvl_board *b)
 	int u;
 
 	z8530_shutdown(&b->board);
-	
-	for(u=0; u<2; u++)
+
+	for (u = 0; u < 2; u++)
 	{
-		struct net_device *d = b->dev[u]->pppdev.dev;
-		unregister_netdev(d);
+		struct net_device *d = b->dev[u].chan->netdevice;
+		unregister_hdlc_device(d);
 		free_netdev(d);
 	}
-	
+
 	free_irq(b->board.irq, &b->board);
 	free_dma(b->board.chanA.rxdma);
 	free_dma(b->board.chanA.txdma);
@@ -451,10 +378,6 @@ static struct slvl_board *slvl_unit;
 
 static int __init slvl_init_module(void)
 {
-#ifdef MODULE
-	printk(KERN_INFO "SeaLevel Z85230 Synchronous Driver v 0.02.\n");
-	printk(KERN_INFO "(c) Copyright 1998, Building Number Three Ltd.\n");
-#endif
 	slvl_unit = slvl_init(io, irq, txdma, rxdma, slow);
 
 	return slvl_unit ? 0 : -ENODEV;
diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 29b4b94..327d585 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -230,13 +230,6 @@ static void sppp_input (struct net_device *dev, struct sk_buff *skb)
 	skb->dev=dev;
 	skb_reset_mac_header(skb);
 
-	if (dev->flags & IFF_RUNNING)
-	{
-		/* Count received bytes, add FCS and one flag */
-		sp->ibytes+= skb->len + 3;
-		sp->ipkts++;
-	}
-
 	if (!pskb_may_pull(skb, PPP_HEADER_LEN)) {
 		/* Too small packet, drop it. */
 		if (sp->pp_flags & PP_DEBUG)
@@ -832,7 +825,6 @@ static void sppp_cp_send (struct sppp *sp, u16 proto, u8 type,
 			sppp_print_bytes ((u8*) (lh+1), len);
 		printk (">\n");
 	}
-	sp->obytes += skb->len;
 	/* Control is high priority so it doesn't get queued behind data */
 	skb->priority=TC_PRIO_CONTROL;
 	skb->dev = dev;
@@ -875,7 +867,6 @@ static void sppp_cisco_send (struct sppp *sp, int type, u32 par1, u32 par2)
 		printk (KERN_WARNING "%s: cisco output: <%xh %xh %xh %xh %xh-%xh>\n",
 			dev->name,  ntohl (ch->type), ch->par1,
 			ch->par2, ch->rel, ch->time0, ch->time1);
-	sp->obytes += skb->len;
 	skb->priority=TC_PRIO_CONTROL;
 	skb->dev = dev;
 	skb_queue_tail(&tx_queue, skb);
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 98ef400..243bd8d 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -43,6 +43,7 @@
 #include <linux/netdevice.h>
 #include <linux/if_arp.h>
 #include <linux/delay.h>
+#include <linux/hdlc.h>
 #include <linux/ioport.h>
 #include <linux/init.h>
 #include <asm/dma.h>
@@ -51,7 +52,6 @@
 #define RT_UNLOCK
 #include <linux/spinlock.h>
 
-#include <net/syncppp.h>
 #include "z85230.h"
 
 
@@ -440,51 +440,46 @@ static void z8530_tx(struct z8530_channel *c)
  *	A status event occurred in PIO synchronous mode. There are several
  *	reasons the chip will bother us here. A transmit underrun means we
  *	failed to feed the chip fast enough and just broke a packet. A DCD
- *	change is a line up or down. We communicate that back to the protocol
- *	layer for synchronous PPP to renegotiate.
+ *	change is a line up or down.
  */
 
 static void z8530_status(struct z8530_channel *chan)
 {
 	u8 status, altered;
 
-	status=read_zsreg(chan, R0);
-	altered=chan->status^status;
-	
-	chan->status=status;
-	
-	if(status&TxEOM)
-	{
+	status = read_zsreg(chan, R0);
+	altered = chan->status ^ status;
+
+	chan->status = status;
+
+	if (status & TxEOM) {
 /*		printk("%s: Tx underrun.\n", chan->dev->name); */
-		chan->stats.tx_fifo_errors++;
+		chan->netdevice->stats.tx_fifo_errors++;
 		write_zsctrl(chan, ERR_RES);
 		z8530_tx_done(chan);
 	}
-		
-	if(altered&chan->dcdcheck)
+
+	if (altered & chan->dcdcheck)
 	{
-		if(status&chan->dcdcheck)
-		{
+		if (status & chan->dcdcheck) {
 			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]|RxENABLE);
-			if(chan->netdevice &&
-			    ((chan->netdevice->type == ARPHRD_HDLC) ||
-			    (chan->netdevice->type == ARPHRD_PPP)))
-				sppp_reopen(chan->netdevice);
-		}
-		else
-		{
+			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
+			if (chan->netdevice)
+				netif_carrier_on(chan->netdevice);
+		} else {
 			printk(KERN_INFO "%s: DCD lost\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]&~RxENABLE);
+			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
+			if (chan->netdevice)
+				netif_carrier_off(chan->netdevice);
 		}
-		
-	}	
+
+	}
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
 }
 
-struct z8530_irqhandler z8530_sync=
+struct z8530_irqhandler z8530_sync =
 {
 	z8530_rx,
 	z8530_tx,
@@ -556,8 +551,7 @@ static void z8530_dma_tx(struct z8530_channel *chan)
  *	
  *	A status event occurred on the Z8530. We receive these for two reasons
  *	when in DMA mode. Firstly if we finished a packet transfer we get one
- *	and kick the next packet out. Secondly we may see a DCD change and
- *	have to poke the protocol layer.
+ *	and kick the next packet out. Secondly we may see a DCD change.
  *
  */
  
@@ -586,24 +580,21 @@ static void z8530_dma_status(struct z8530_channel *chan)
 		}
 	}
 
-	if(altered&chan->dcdcheck)
+	if (altered & chan->dcdcheck)
 	{
-		if(status&chan->dcdcheck)
-		{
+		if (status & chan->dcdcheck) {
 			printk(KERN_INFO "%s: DCD raised\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]|RxENABLE);
-			if(chan->netdevice &&
-			    ((chan->netdevice->type == ARPHRD_HDLC) ||
-			    (chan->netdevice->type == ARPHRD_PPP)))
-				sppp_reopen(chan->netdevice);
-		}
-		else
-		{
+			write_zsreg(chan, R3, chan->regs[3] | RxENABLE);
+			if (chan->netdevice)
+				netif_carrier_on(chan->netdevice);
+		} else {
 			printk(KERN_INFO "%s:DCD lost\n", chan->dev->name);
-			write_zsreg(chan, R3, chan->regs[3]&~RxENABLE);
+			write_zsreg(chan, R3, chan->regs[3] & ~RxENABLE);
 			z8530_flush_fifo(chan);
+			if (chan->netdevice)
+				netif_carrier_off(chan->netdevice);
 		}
-	}	
+	}
 
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
@@ -1459,10 +1450,10 @@ static void z8530_tx_begin(struct z8530_channel *c)
 			/*
 			 *	Check if we crapped out.
 			 */
-			if(get_dma_residue(c->txdma))
+			if (get_dma_residue(c->txdma))
 			{
-				c->stats.tx_dropped++;
-				c->stats.tx_fifo_errors++;
+				c->netdevice->stats.tx_dropped++;
+				c->netdevice->stats.tx_fifo_errors++;
 			}
 			release_dma_lock(flags);
 		}
@@ -1534,21 +1525,21 @@ static void z8530_tx_begin(struct z8530_channel *c)
  *	packet. This code is fairly timing sensitive.
  *
  *	Called with the register lock held.
- */ 
- 
+ */
+
 static void z8530_tx_done(struct z8530_channel *c)
 {
 	struct sk_buff *skb;
 
 	/* Actually this can happen.*/
-	if(c->tx_skb==NULL)
+	if (c->tx_skb == NULL)
 		return;
 
-	skb=c->tx_skb;
-	c->tx_skb=NULL;
+	skb = c->tx_skb;
+	c->tx_skb = NULL;
 	z8530_tx_begin(c);
-	c->stats.tx_packets++;
-	c->stats.tx_bytes+=skb->len;
+	c->netdevice->stats.tx_packets++;
+	c->netdevice->stats.tx_bytes += skb->len;
 	dev_kfree_skb_irq(skb);
 }
 
@@ -1558,7 +1549,7 @@ static void z8530_tx_done(struct z8530_channel *c)
  *	@skb: The buffer
  *
  *	We point the receive handler at this function when idle. Instead
- *	of syncppp processing the frames we get to throw them away.
+ *	of processing the frames we get to throw them away.
  */
  
 void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb)
@@ -1635,10 +1626,11 @@ static void z8530_rx_done(struct z8530_channel *c)
 		else
 			/* Can't occur as we dont reenable the DMA irq until
 			   after the flip is done */
-			printk(KERN_WARNING "%s: DMA flip overrun!\n", c->netdevice->name);
-			
+			printk(KERN_WARNING "%s: DMA flip overrun!\n",
+			       c->netdevice->name);
+
 		release_dma_lock(flags);
-		
+
 		/*
 		 *	Shove the old buffer into an sk_buff. We can't DMA
 		 *	directly into one on a PC - it might be above the 16Mb
@@ -1646,27 +1638,23 @@ static void z8530_rx_done(struct z8530_channel *c)
 		 *	can avoid the copy. Optimisation 2 - make the memcpy
 		 *	a copychecksum.
 		 */
-		 
-		skb=dev_alloc_skb(ct);
-		if(skb==NULL)
-		{
-			c->stats.rx_dropped++;
-			printk(KERN_WARNING "%s: Memory squeeze.\n", c->netdevice->name);
-		}
-		else
-		{
+
+		skb = dev_alloc_skb(ct);
+		if (skb == NULL) {
+			c->netdevice->stats.rx_dropped++;
+			printk(KERN_WARNING "%s: Memory squeeze.\n",
+			       c->netdevice->name);
+		} else {
 			skb_put(skb, ct);
 			skb_copy_to_linear_data(skb, rxb, ct);
-			c->stats.rx_packets++;
-			c->stats.rx_bytes+=ct;
+			c->netdevice->stats.rx_packets++;
+			c->netdevice->stats.rx_bytes += ct;
 		}
-		c->dma_ready=1;
-	}
-	else
-	{
-		RT_LOCK;	
-		skb=c->skb;
-		
+		c->dma_ready = 1;
+	} else {
+		RT_LOCK;
+		skb = c->skb;
+
 		/*
 		 *	The game we play for non DMA is similar. We want to
 		 *	get the controller set up for the next packet as fast
@@ -1677,48 +1665,39 @@ static void z8530_rx_done(struct z8530_channel *c)
 		 *	if you build a system where the sync irq isnt blocked
 		 *	by the kernel IRQ disable then you need only block the
 		 *	sync IRQ for the RT_LOCK area.
-		 *	
+		 *
 		 */
 		ct=c->count;
-		
+
 		c->skb = c->skb2;
 		c->count = 0;
 		c->max = c->mtu;
-		if(c->skb)
-		{
+		if (c->skb) {
 			c->dptr = c->skb->data;
 			c->max = c->mtu;
-		}
-		else
-		{
-			c->count= 0;
+		} else {
+			c->count = 0;
 			c->max = 0;
 		}
 		RT_UNLOCK;
 
 		c->skb2 = dev_alloc_skb(c->mtu);
-		if(c->skb2==NULL)
+		if (c->skb2 == NULL)
 			printk(KERN_WARNING "%s: memory squeeze.\n",
-				c->netdevice->name);
+			       c->netdevice->name);
 		else
-		{
-			skb_put(c->skb2,c->mtu);
-		}
-		c->stats.rx_packets++;
-		c->stats.rx_bytes+=ct;
-		
+			skb_put(c->skb2, c->mtu);
+		c->netdevice->stats.rx_packets++;
+		c->netdevice->stats.rx_bytes += ct;
 	}
 	/*
 	 *	If we received a frame we must now process it.
 	 */
-	if(skb)
-	{
+	if (skb) {
 		skb_trim(skb, ct);
-		c->rx_function(c,skb);
-	}
-	else
-	{
-		c->stats.rx_dropped++;
+		c->rx_function(c, skb);
+	} else {
+		c->netdevice->stats.rx_dropped++;
 		printk(KERN_ERR "%s: Lost a frame\n", c->netdevice->name);
 	}
 }
@@ -1730,7 +1709,7 @@ static void z8530_rx_done(struct z8530_channel *c)
  *	Returns true if the buffer cross a DMA boundary on a PC. The poor
  *	thing can only DMA within a 64K block not across the edges of it.
  */
- 
+
 static inline int spans_boundary(struct sk_buff *skb)
 {
 	unsigned long a=(unsigned long)skb->data;
@@ -1799,24 +1778,6 @@ int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb)
 
 EXPORT_SYMBOL(z8530_queue_xmit);
 
-/**
- *	z8530_get_stats - Get network statistics
- *	@c: The channel to use
- *
- *	Get the statistics block. We keep the statistics in software as
- *	the chip doesn't do it for us.
- *
- *	Locking is ignored here - we could lock for a copy but its
- *	not likely to be that big an issue
- */
- 
-struct net_device_stats *z8530_get_stats(struct z8530_channel *c)
-{
-	return &c->stats;
-}
-
-EXPORT_SYMBOL(z8530_get_stats);
-
 /*
  *	Module support
  */
diff --git a/drivers/net/wan/z85230.h b/drivers/net/wan/z85230.h
index 158aea7..4f37239 100644
--- a/drivers/net/wan/z85230.h
+++ b/drivers/net/wan/z85230.h
@@ -325,7 +325,6 @@ struct z8530_channel
 
 	void		*private;	/* For our owner */
 	struct net_device	*netdevice;	/* Network layer device */
-	struct net_device_stats stats;	/* Network layer statistics */
 
 	/*
 	 *	Async features
@@ -366,13 +365,13 @@ struct z8530_channel
 	unsigned char		tx_active; /* character is being xmitted */
 	unsigned char		tx_stopped; /* output is suspended */
 
-	spinlock_t		*lock;	  /* Devicr lock */
-};	
+	spinlock_t		*lock;	  /* Device lock */
+};
 
 /*
  *	Each Z853x0 device.
- */	
- 
+ */
+
 struct z8530_dev
 {
 	char *name;	/* Device instance name */
@@ -408,7 +407,6 @@ extern int z8530_sync_txdma_open(struct net_device *, struct z8530_channel *);
 extern int z8530_sync_txdma_close(struct net_device *, struct z8530_channel *);
 extern int z8530_channel_load(struct z8530_channel *, u8 *);
 extern int z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb);
-extern struct net_device_stats *z8530_get_stats(struct z8530_channel *c);
 extern void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb);
 
 
diff --git a/include/net/syncppp.h b/include/net/syncppp.h
index e43f407..9e306f7 100644
--- a/include/net/syncppp.h
+++ b/include/net/syncppp.h
@@ -43,8 +43,6 @@ struct sppp
 	u32		pp_rseq;	/* remote sequence number */
 	struct slcp	lcp;		/* LCP params */
 	struct sipcp	ipcp;		/* IPCP params */
-	u32		ibytes,obytes;	/* Bytes in/out */
-	u32		ipkts,opkts;	/* Packets in/out */
 	struct timer_list	pp_timer;
 	struct net_device	*pp_if;
 	char		pp_link_state;	/* Link status */
diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index b210a88..7f07152 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -57,7 +57,6 @@
 #include <linux/vmalloc.h>	/* vmalloc, vfree */
 #include <asm/uaccess.h>        /* copy_to/from_user */
 #include <linux/init.h>         /* __initfunc et al. */
-#include <net/syncppp.h>
 
 #define KMEM_SAFETYZONE 8
 
@@ -567,9 +566,6 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 {
 	wanif_conf_t *cnf;
 	struct net_device *dev = NULL;
-#ifdef CONFIG_WANPIPE_MULTPPP
-	struct ppp_device *pppdev=NULL;
-#endif
 	int err;
 
 	if ((wandev->state == WAN_UNCONFIGURED) || (wandev->new_if == NULL))
@@ -588,25 +584,10 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 		goto out;
 
 	if (cnf->config_id == WANCONFIG_MPPP) {
-#ifdef CONFIG_WANPIPE_MULTPPP
-		pppdev = kzalloc(sizeof(struct ppp_device), GFP_KERNEL);
-		err = -ENOBUFS;
-		if (pppdev == NULL)
-			goto out;
-		pppdev->dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (pppdev->dev == NULL) {
-			kfree(pppdev);
-			err = -ENOBUFS;
-			goto out;
-		}
-		err = wandev->new_if(wandev, (struct net_device *)pppdev, cnf);
-		dev = pppdev->dev;
-#else
 		printk(KERN_INFO "%s: Wanpipe Mulit-Port PPP support has not been compiled in!\n",
 				wandev->name);
 		err = -EPROTONOSUPPORT;
 		goto out;
-#endif
 	} else {
 		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
 		err = -ENOBUFS;
@@ -661,17 +642,9 @@ static int wanrouter_device_new_if(struct wan_device *wandev,
 	kfree(dev->priv);
 	dev->priv = NULL;
 
-#ifdef CONFIG_WANPIPE_MULTPPP
-	if (cnf->config_id == WANCONFIG_MPPP)
-		kfree(pppdev);
-	else
-		kfree(dev);
-#else
 	/* Sync PPP is disabled */
 	if (cnf->config_id != WANCONFIG_MPPP)
 		kfree(dev);
-#endif
-
 out:
 	kfree(cnf);
 	return err;

-- 
Krzysztof Halasa
