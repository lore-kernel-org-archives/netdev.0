From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] switch iph5526_probe to initcalls
Date: Sun, 15 Jun 2003 20:00:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615180011.GA4922@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's a pci driver so it has no business in Space.c

p.s. it doesn't compile with or without the patch due to scsi issues..

--- 1.21/drivers/net/Space.c	Mon Jun  9 18:52:43 2003
+++ edited/drivers/net/Space.c	Sat Jun 14 21:32:48 2003
@@ -398,24 +398,6 @@
 	return -ENODEV;
 }
 
-#ifdef CONFIG_NET_FC
-static int fcif_probe(struct net_device *dev)
-{
-	if (dev->base_addr == -1)
-		return 1;
-
-	if (1
-#ifdef CONFIG_IPHASE5526
-	    && iph5526_probe(dev)
-#endif
-	    && 1 ) {
-		return 1; /* -ENODEV or -EAGAIN would be more accurate. */
-	}
-	return 0;
-}
-#endif  /* CONFIG_NET_FC */
-
-
 #ifdef CONFIG_ETHERTAP
 static struct net_device tap0_dev = {
 	.name		= "tap0",
@@ -588,22 +570,6 @@
 #define      NEXT_DEV        (&tr0_dev)
 
 #endif 
-
-#ifdef CONFIG_NET_FC
-static struct net_device fc1_dev = {
-	.name		= "fc1",
-	.next		= NEXT_DEV,
-	.init		= fcif_probe
-};
-static struct net_device fc0_dev = {
-	.name		= "fc0",
-	.next		=  &fc1_dev,
-	.init		= fcif_probe
-};
-#undef       NEXT_DEV
-#define      NEXT_DEV        (&fc0_dev)
-#endif
-
 
 #ifdef CONFIG_SBNI
 static struct net_device sbni7_dev = {
--- 1.25/drivers/net/fc/iph5526.c	Tue Jun 10 00:49:03 2003
+++ edited/drivers/net/fc/iph5526.c	Sat Jun 14 21:32:48 2003
@@ -239,19 +239,7 @@
 
 static int __init iph5526_probe_pci(struct net_device *dev)
 {
-#ifdef MODULE
 	struct fc_info *fi = (struct fc_info *)dev->priv;
-#else
-	struct fc_info *fi = fc[count];
-	static int count;
-	int err;
- 
-	if (!fi)
-		return -ENODEV;
-
-	fc_setup(dev);
-	count++;
-#endif
 	fi->dev = dev;
 	dev->base_addr = fi->base_addr;
 	dev->irq = fi->irq;
@@ -4479,8 +4467,6 @@
 	return buf;
 }
 
-#ifdef MODULE
-
 #define NAMELEN		8	/* # of chars for storing dev->name */
 
 static struct net_device *dev_fc[MAX_FC_CARDS];
@@ -4491,7 +4477,7 @@
 static int scsi_registered;
 
 
-int init_module(void)
+static int __init iph5526_init(void)
 {
 	int i = 0;
 
@@ -4530,7 +4516,7 @@
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit iph5526_exit(void)
 {
 	int i = 0;
 	while(fc[i] != NULL) {
@@ -4549,7 +4535,9 @@
 	if (scsi_registered == TRUE)
 		scsi_unregister_host(&driver_template); 
 }
-#endif /* MODULE */
+
+module_init(iph5526_init);
+module_exit(iph5526_exit);
 
 void clean_up_memory(struct fc_info *fi)
 {
