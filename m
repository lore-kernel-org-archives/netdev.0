From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] More dgrs cleanup
Date: Mon, 26 Jan 2004 10:10:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126101040.6db9d97e.shemminger@osdl.org>
References: <20040123222459.58b4413a.akpm@osdl.org>
	<20040124070450.GN21151@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: viro@parcelfarce.linux.theplanet.co.uk
In-Reply-To: <20040124070450.GN21151@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 24 Jan 2004 07:04:50 +0000
viro@parcelfarce.linux.theplanet.co.uk wrote:

> On Fri, Jan 23, 2004 at 10:24:59PM -0800, Andrew Morton wrote:
> > static int __init dgrs_eisa_probe (struct device *gendev)
> > {
> > 	struct net_device *dev;
> > 	struct eisa_device *edev = to_eisa_device(gendev);
> > 	uint	io = edev->base_addr;
> > 	uint	mem;
> > 	uint	irq;
> > 	int 	rc = -ENODEV; /* Not EISA configured */
> > 
> > 	if (!request_region(io, 256, "RightSwitch")) {
> > 		printk(KERN_ERR "%s: io 0x%3lX, which is busy.\n", dev->name,
> > 				dev->base_addr);
> > 		return -EBUSY;
> > 	}
> > 
> > `dev' is uninitialised when we do that printk.
> 
> IIRC, dgrs patch was from Stephen.  AFAICS, we want edev->base_addr instead
> of dev->base_addr.  

Yes, that is what the eisa probe code passes in for the base address.
dev->base_addr is then set in dgrs_found_device.

>Fsck knows what should replace dev->name - for pci
> I'd say pci_name(edev), dunno about eisa...

I just kept what the original code was doing... the name doesn't matter that much.
Many drivers have a problem now when they do setup before register-netdev and print
error messages.

For now how about this which just uses "dgrs" which is what everything else does.
Al can clean it out in the next purge...
---------------------------------------
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1594  -> 1.1595 
#	  drivers/net/dgrs.c	1.23    -> 1.24   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/26	shemminger@osdl.org	1.1595
# More cleanup.
#  * get rid of typedef for private data struct
#  * tag most of the printk's with priority
#  * don't print "eth%d" when name not set
#  * reserve resources as "dgrs" not "RightSwitch"
#  * avoid race in irq detect logic
# --------------------------------------------
#
diff -Nru a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c	Mon Jan 26 10:08:44 2004
+++ b/drivers/net/dgrs.c	Mon Jan 26 10:08:44 2004
@@ -192,7 +192,7 @@
 /*
  *	Private per-board data structure (dev->priv)
  */
-typedef struct
+struct dgrs_priv
 {
 	/*
 	 *	Stuff for generic ethercard I/F
@@ -242,9 +242,7 @@
 	int		nports;		/* Number of physical ports (4 or 6) */
 	int		chan;		/* Channel # (1-6) for this device */
 	struct net_device	*devtbl[6];	/* Ptrs to N device structs */
-
-} DGRS_PRIV;
-
+};
 
 /*
  *	reset or un-reset the IDT processor
@@ -252,7 +250,7 @@
 static void
 proc_reset(struct net_device *dev0, int reset)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	struct dgrs_priv *priv0 = dev0->priv;
 
 	if (priv0->plxreg)
 	{
@@ -276,7 +274,7 @@
 static int
 check_board_dma(struct net_device *dev0)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	struct dgrs_priv *priv0 = dev0->priv;
 	ulong	x;
 
 	/*
@@ -357,7 +355,7 @@
 {
         int     	i;
         ulong   	csr = 0;
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	struct dgrs_priv *priv = dev->priv;
 
 	if (pciaddr)
 	{
@@ -455,7 +453,7 @@
 void
 dgrs_rcv_frame(
 	struct net_device	*dev0,
-	DGRS_PRIV	*priv0,
+	struct dgrs_priv *priv0,
 	I596_CB		*cbp
 )
 {
@@ -465,7 +463,7 @@
 	uchar		*putp;
 	uchar		*p;
 	struct net_device	*devN;
-	DGRS_PRIV	*privN;
+	struct dgrs_priv *privN;
 
 	/*
 	 *	Determine Nth priv and dev structure pointers
@@ -481,7 +479,7 @@
 		 */
 		if (devN == NULL)
 			goto out;
-		privN = (DGRS_PRIV *) devN->priv;
+		privN = devN->priv;
 	}
 	else
 	{	/* Switch mode */
@@ -489,8 +487,6 @@
 		privN = priv0;
 	}
 
-	if (0) printk("%s: rcv len=%ld\n", devN->name, cbp->xmit.count);
-
 	/*
 	 *	Allocate a message block big enough to hold the whole frame
 	 */
@@ -694,9 +690,9 @@
 
 static int dgrs_start_xmit(struct sk_buff *skb, struct net_device *devN)
 {
-	DGRS_PRIV	*privN = (DGRS_PRIV *) devN->priv;
+	struct dgrs_priv *privN = devN->priv;
 	struct net_device	*dev0;
-	DGRS_PRIV	*priv0;
+	struct dgrs_priv *priv0;
 	I596_RBD	*rbdp;
 	int		count;
 	int		i, len, amt;
@@ -707,7 +703,7 @@
 	if (dgrs_nicmode)
 	{
 		dev0 = privN->devtbl[0];
-		priv0 = (DGRS_PRIV *) dev0->priv;
+		priv0 = dev0->priv;
 	}
 	else
 	{
@@ -810,7 +806,7 @@
  */
 static struct net_device_stats *dgrs_get_stats( struct net_device *dev )
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	struct dgrs_priv *priv = dev->priv;
 
 	return (&priv->stats);
 }
@@ -821,7 +817,7 @@
 
 static void dgrs_set_multicast_list( struct net_device *dev)
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	struct dgrs_priv *priv = dev->priv;
 
 	priv->port->is_promisc = (dev->flags & IFF_PROMISC) ? 1 : 0;
 }
@@ -831,7 +827,7 @@
  */
 static int dgrs_ioctl(struct net_device *devN, struct ifreq *ifr, int cmd)
 {
-	DGRS_PRIV	*privN = (DGRS_PRIV *) devN->priv;
+	struct dgrs_priv *privN = devN->priv;
 	DGRS_IOCTL	ioc;
 	int		i;
 
@@ -897,7 +893,7 @@
 static irqreturn_t dgrs_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device	*dev0 = (struct net_device *) dev_id;
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	struct dgrs_priv *priv0 = dev0->priv;
 	I596_CB		*cbp;
 	int		cmd;
 	int		i;
@@ -987,7 +983,7 @@
 static int __init 
 dgrs_download(struct net_device *dev0)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	struct dgrs_priv *priv0 = dev0->priv;
 	int		is;
 	unsigned long	i;
 
@@ -1147,12 +1143,12 @@
 int __init 
 dgrs_probe1(struct net_device *dev)
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	struct dgrs_priv *priv = dev->priv;
 	unsigned long	i;
 	int		rc;
 
-	printk("%s: Digi RightSwitch io=%lx mem=%lx irq=%d plx=%lx dma=%lx\n",
-		dev->name, dev->base_addr, dev->mem_start, dev->irq,
+	printk(KERN_INFO "dgrs: Digi RightSwitch io=%lx mem=%lx irq=%d plx=%lx dma=%lx\n",
+		dev->base_addr, dev->mem_start, dev->irq,
 		priv->plxreg, priv->plxdma);
 
 	/*
@@ -1165,19 +1161,24 @@
 	/*
 	 * Get ether address of board
 	 */
-	printk("%s: Ethernet address", dev->name);
 	memcpy(dev->dev_addr, priv->port->ethaddr, 6);
-	for (i = 0; i < 6; ++i)
-		printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
-	printk("\n");
 
-	if (dev->dev_addr[0] & 1)
-	{
-		printk("%s: Illegal Ethernet Address\n", dev->name);
+	if (dev->dev_addr[0] & 1) {
+		printk(KERN_ERR "dgrs: Illegal Ethernet Address");
+		for (i = 0; i < 6; ++i)
+			printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
+		printk("\n");
+
 		rc = -ENXIO;
 		goto err_out;
 	}
 
+	rc = request_irq(dev->irq, &dgrs_intr, SA_SHIRQ, "dgrs", dev);
+	if (rc)
+		goto err_out;
+
+	priv->intrcnt = 0;
+
 	/*
 	 *	ACK outstanding interrupts, hook the interrupt,
 	 *	and verify that we are getting interrupts from the board.
@@ -1185,21 +1186,17 @@
 	if (priv->plxreg)
 		OUTL(dev->base_addr + PLX_LCL2PCI_DOORBELL, 1);
 	
-	rc = request_irq(dev->irq, &dgrs_intr, SA_SHIRQ, "RightSwitch", dev);
-	if (rc)
-		goto err_out;
-
-	priv->intrcnt = 0;
 	for (i = jiffies + 2*HZ + HZ/2; time_after(i, jiffies); )
 	{
 		cpu_relax();
 		if (priv->intrcnt >= 2)
 			break;
 	}
+
 	if (priv->intrcnt < 2)
 	{
-		printk(KERN_ERR "%s: Not interrupting on IRQ %d (%d)\n",
-				dev->name, dev->irq, priv->intrcnt);
+		printk(KERN_ERR "dgrs%x: Not interrupting on IRQ %d (%d)\n",
+				dev->base_addr, dev->irq, priv->intrcnt);
 		rc = -ENXIO;
 		goto err_free_irq;
 	}
@@ -1222,21 +1219,6 @@
        	return rc;
 }
 
-int __init 
-dgrs_initclone(struct net_device *dev)
-{
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
-	int		i;
-
-	printk("%s: Digi RightSwitch port %d ",
-		dev->name, priv->chan);
-	for (i = 0; i < 6; ++i)
-		printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
-	printk("\n");
-
-	return (0);
-}
-
 static struct net_device * __init 
 dgrs_found_device(
 	int		io,
@@ -1247,15 +1229,15 @@
 	struct device   *pdev
 )
 {
-	DGRS_PRIV *priv;
+	struct dgrs_priv *priv;
 	struct net_device *dev;
 	int i, ret = -ENOMEM;
 
-	dev = alloc_etherdev(sizeof(DGRS_PRIV));
+	dev = alloc_etherdev(sizeof(struct dgrs_priv));
 	if (!dev)
 		goto err0;
 
-	priv = (DGRS_PRIV *)dev->priv;
+	priv = (struct dgrs_priv *)dev->priv;
 
 	dev->base_addr = io;
 	dev->mem_start = mem;
@@ -1291,9 +1273,9 @@
 	for (i = 1; i < priv->nports; ++i)
 	{
 		struct net_device	*devN;
-		DGRS_PRIV	*privN;
+		struct dgrs_priv *privN;
 			/* Allocate new dev and priv structures */
-		devN = alloc_etherdev(sizeof(DGRS_PRIV));
+		devN = alloc_etherdev(sizeof(struct dgrs_priv));
 		ret = -ENOMEM;
 		if (!devN) 
 			goto fail;
@@ -1301,7 +1283,7 @@
 		/* Don't copy the network device structure! */
 
 		/* copy the priv structure of dev[0] */
-		privN = (DGRS_PRIV *)devN->priv;
+		privN = (struct dgrs_priv *)devN->priv;
 		*privN = *priv;
 
 			/* ... and zero out VM areas */
@@ -1312,9 +1294,11 @@
 			/* ... and base MAC address off address of 1st port */
 		devN->dev_addr[5] += i;
 
-		ret = dgrs_initclone(devN);
-		if (ret)
-			goto fail;
+		printk(KERN_INFO "%s: Digi RightSwitch port %d ",
+		       dev->name, priv->chan);
+		for (i = 0; i < 6; ++i)
+			printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
+		printk("\n");
 
 		SET_MODULE_OWNER(devN);
 		SET_NETDEV_DEV(dev, pdev);
@@ -1346,7 +1330,7 @@
 
 static void __devexit dgrs_remove(struct net_device *dev)
 {
-	DGRS_PRIV *priv = dev->priv;
+	struct dgrs_priv *priv = dev->priv;
 	int i;
 
 	unregister_netdev(dev);
@@ -1397,7 +1381,8 @@
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
-	err = pci_request_regions(pdev, "RightSwitch");
+
+	err = pci_request_regions(pdev, "dgrs");
 	if (err)
 		return err;
 
@@ -1467,8 +1452,8 @@
 	uint	irq;
 	int 	rc = -ENODEV; /* Not EISA configured */
 
-	if (!request_region(io, 256, "RightSwitch")) {
-		printk(KERN_ERR "%s: io 0x%3lX, which is busy.\n", dev->name,
+	if (!request_region(io, 256, "dgrs")) {
+		printk(KERN_ERR "dgrs: io 0x%3lX, which is busy.\n", 
 				dev->base_addr);
 		return -EBUSY;
 	}
