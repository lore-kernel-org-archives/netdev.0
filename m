From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ibmtr -- convert to new probeing
Date: Mon, 17 Nov 2003 16:47:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117164757.7a6ec07e.shemminger@osdl.org>
References: <OF2336FD68.EC98F250-ON05256DDF.001F93EA-05256DDF.00205884@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
In-Reply-To: <OF2336FD68.EC98F250-ON05256DDF.001F93EA-05256DDF.00205884@urscorp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The way ibmtr_cs.c #include's ibmtr.c is gross, but adding a few more #ifdef's
should fix it again.  

This applies on top of earlier patch.  It also cleans up some more things
that should be defined as static.

diff -Nru a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
--- a/drivers/net/pcmcia/ibmtr_cs.c	Mon Nov 17 14:02:43 2003
+++ b/drivers/net/pcmcia/ibmtr_cs.c	Mon Nov 17 14:02:43 2003
@@ -125,10 +125,6 @@
 
 static dev_link_t *dev_list;
 
-extern int ibmtr_probe(struct net_device *dev);
-extern int trdev_init(struct net_device *dev);
-extern irqreturn_t tok_interrupt (int irq, void *dev_id, struct pt_regs *regs);
-
 /*====================================================================*/
 
 typedef struct ibmtr_dev_t {
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	Mon Nov 17 14:02:43 2003
+++ b/drivers/net/tokenring/ibmtr.c	Mon Nov 17 14:02:43 2003
@@ -152,7 +152,7 @@
 
 /* this allows displaying full adapter information */
 
-char *channel_def[] __devinitdata = { "ISA", "MCA", "ISA P&P" };
+static const char *channel_def[] __devinitdata = { "ISA", "MCA", "ISA P&P" };
 
 static char pcchannelid[] __devinitdata = {
 	0x05, 0x00, 0x04, 0x09,
@@ -172,7 +172,7 @@
 	0x03, 0x08, 0x02, 0x00
 };
 
-char __devinit *adapter_def(char type)
+static const char __devinit *adapter_def(char type)
 {
 	switch (type) {
 	case 0xF: return "PC Adapter | PC Adapter II | Adapter/A";
@@ -187,7 +187,6 @@
 #define TRC_INITV 0x02		/*  verbose init trace points     */
 unsigned char ibmtr_debug_trace = 0;
 
-int 		ibmtr_probe(struct net_device *dev);
 static int	ibmtr_probe1(struct net_device *dev, int ioaddr);
 static unsigned char get_sram_size(struct tok_info *adapt_info);
 static int 	trdev_init(struct net_device *dev);
@@ -198,7 +197,7 @@
 static void 	tok_set_multicast_list(struct net_device *dev);
 static int 	tok_send_packet(struct sk_buff *skb, struct net_device *dev);
 static int 	tok_close(struct net_device *dev);
-irqreturn_t tok_interrupt(int irq, void *dev_id, struct pt_regs *regs);
+static irqreturn_t tok_interrupt(int irq, void *dev_id, struct pt_regs *regs);
 static void 	initial_tok_int(struct net_device *dev);
 static void 	tr_tx(struct net_device *dev);
 static void 	tr_rx(struct net_device *dev);
@@ -207,6 +206,7 @@
 static void 	ibmtr_readlog(struct net_device *dev);
 static struct 	net_device_stats *tok_get_stats(struct net_device *dev);
 static int 	ibmtr_change_mtu(struct net_device *dev, int mtu);
+#ifndef PCMCIA
 static void	find_turbo_adapters(int *iolist);
 
 static int ibmtr_portlist[IBMTR_MAX_ADAPTERS+1] __devinitdata = {
@@ -216,7 +216,6 @@
 static int __devinitdata turbo_irq[IBMTR_MAX_ADAPTERS] = {0};
 static int __devinitdata turbo_searched = 0;
 
-#ifndef PCMCIA
 static __u32 ibmtr_mem_base __initdata = 0xd0000;
 #endif
 
@@ -240,6 +239,7 @@
  * going away. 
  */
 
+#ifndef PCMCIA
 static void __devinit find_turbo_adapters(int *iolist) {
 	int ram_addr;
 	int index=0;
@@ -312,6 +312,7 @@
 		}
 	}
 }
+#endif
 
 /****************************************************************************
  *	ibmtr_probe():  Routine specified in the network device structure
@@ -325,24 +326,28 @@
  *	which references it.
  ****************************************************************************/
 
-int __devinit ibmtr_probe(struct net_device *dev)
+static int __devinit ibmtr_probe(struct net_device *dev)
 {
-	int i;
 	int base_addr = dev->base_addr;
+#ifndef PCMCIA
+	int i;
+#endif
 
 	if (base_addr && base_addr <= 0x1ff) /* Don't probe at all. */
 		return -ENXIO;
 	if (base_addr > 0x1ff) /* Check a single specified location.  */
 		return ibmtr_probe1(dev, base_addr);
+#ifndef PCMCIA
 	find_turbo_adapters(ibmtr_portlist);
 	for (i = 0; ibmtr_portlist[i]; i++) {
 		if (!ibmtr_probe1(dev, ibmtr_portlist[i]))
 			return 0;
 	}
+#endif
 	return -ENODEV;
 }
 
-#ifndef MODULE
+#if !defined(MODULE) && !defined(PCMCIA)
 /*
  * Called from Space.c to probe for token ring devices at boot
  * time.
@@ -388,13 +393,14 @@
 #endif
 	int err = -ENODEV;
 
-	/*?? Now, allocate some of the PIO PORTs for this driver.. */
+#ifndef PCMCIA
 	/* record PIOaddr range as busy */
 	if (!request_region(PIOaddr, IBMTR_IO_EXTENT, "ibmtr")) {
 		DPRINTK("Could not grab PIO range. Halting driver.\n");
 		err = -EBUSY;
 		goto out1;
 	}
+#endif
 
 	/*    Query the adapter PIO base port which will return
 	 *    indication of where MMIO was placed. We also have a
@@ -787,8 +793,10 @@
 	iounmap(t_mmio);
 #endif
  out2:
+#ifndef PCMCIA
 	release_region(PIOaddr, IBMTR_IO_EXTENT);
  out1:
+#endif
 	return err;
 }				/*ibmtr_probe1() */
 
@@ -1164,7 +1172,7 @@
 
 /******************************************************************************/
 
-irqreturn_t tok_interrupt(int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t tok_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	unsigned char status;
 	/*  unsigned char status_even ; */
