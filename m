From: Crutcher Dunnavant <crutcher@eng.ua.edu>
Subject: Re: init_foodev cleanup questions
Date: Tue, 2 Jul 2002 09:48:55 -0500
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020702094855.A7978@monket.dyndns.org>
References: <20020701235418.B4148@monket.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020701235418.B4148@monket.dyndns.org>; from crutcher@eng.ua.edu on Mon, Jul 01, 2002 at 11:54:18PM -0500
List-Id: netdev.vger.kernel.org

++ 01/07/02 23:54 -0500 - Crutcher Dunnavant:
> Hello all.
> 
> I've got some time on my hands, so I am walking through
> all the network drivers, and cleaning up use of init_foodev.
> This means zapping foo_setup, and kmallocing or memseting
> dev->priv;
> 
> I'm doing this at the prompting of an entry on the
> kernel-janitors TODO list.
> 
> Very much of this code is utter crap, and the fixes are
> obvious.
> 
> However, I have some questions regarding the legacy probe
> code from drivers/net/Space.c
> 
> can I safely remove bar_probe() from Space.c, if I also
> cleanup bar.c so as to make it a module_init/module_exit
> based module?

below is an (untested) example of what I'm talking about. Is this kosher?

--- linux-2.5.24/drivers/net/3c509.c.init_netdev	Mon Jul  1 23:22:12 2002
+++ linux-2.5.24/drivers/net/3c509.c	Mon Jul  1 23:36:31 2002
@@ -233,8 +233,9 @@
 #endif /* __ISAPNP__ */
 static int nopnp;
 
-int __init el3_probe(struct net_device *dev, int card_idx)
+int __init el3_init_one(int card_idx)
 {
+	struct net_device *dev;
 	struct el3_private *lp;
 	short lrs_state = 0xff, i;
 	int ioaddr, irq, if_port;
@@ -1242,7 +1243,6 @@
 
 #endif /* CONFIG_PM */
 
-#ifdef MODULE
 /* Parameters that may be passed into the module. */
 static int debug = -1;
 static int irq[] = {-1, -1, -1, -1, -1, -1, -1, -1};
@@ -1264,8 +1264,8 @@
 MODULE_DEVICE_TABLE(isapnp, el3_isapnp_adapters);
 MODULE_LICENSE("GPL");
 
-int
-init_module(void)
+static __init int
+el3_init(void)
 {
 	int el3_cards = 0;
 
@@ -1273,7 +1273,7 @@
 		el3_debug = debug;
 
 	el3_root_dev = NULL;
-	while (el3_probe(0, el3_cards) == 0) {
+	while (el3_init_one(el3_cards) == 0) {
 		if (irq[el3_cards] > 1)
 			el3_root_dev->irq = irq[el3_cards];
 		if (xcvr[el3_cards] >= 0)
@@ -1284,8 +1284,8 @@
 	return el3_cards ? 0 : -ENODEV;
 }
 
-void
-cleanup_module(void)
+static __exit void
+el3_exit(void)
 {
 	struct net_device *next_dev;
 
@@ -1308,7 +1308,9 @@
 		el3_root_dev = next_dev;
 	}
 }
-#endif /* MODULE */
+
+MODULE_INIT(el3_init);
+MODULE_EXIT(el3_exit);
 
 /*
  * Local variables:
--- linux-2.5.24/drivers/net/Space.c.init_netdev	Mon Jul  1 23:33:59 2002
+++ linux-2.5.24/drivers/net/Space.c	Tue Jul  2 00:32:30 2002
@@ -57,7 +57,6 @@
 extern int znet_probe(struct net_device *);
 extern int express_probe(struct net_device *);
 extern int eepro_probe(struct net_device *);
-extern int el3_probe(struct net_device *);
 extern int at1500_probe(struct net_device *);
 extern int at1700_probe(struct net_device *);
 extern int fmv18x_probe(struct net_device *);
@@ -216,9 +215,6 @@
  * look for EISA/PCI/MCA cards in addition to ISA cards).
  */
 static struct devprobe isa_probes[] __initdata = {
-#ifdef CONFIG_EL3		/* ISA, EISA, MCA 3c5x9 */
-	{el3_probe, 0},
-#endif
 #ifdef CONFIG_HP100 		/* ISA, EISA & PCI */
 	{hp100_probe, 0},
 #endif


-- 
Crutcher Dunnavant <crutcher+spam@eng.ua.edu>
ECSS System Hacker / UA COE CS Senior
