From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (22/42) 3c527
Date: Wed, 12 Nov 2003 16:43:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311130043.hAD0hwl30832@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

NE46-3c527
	* switched 3c527 to dynamic allocation
	* 3c527: switched to embedded ->priv
	* 3c527: fixed resource leaks on failure exits

diff -Nru a/drivers/net/3c527.c b/drivers/net/3c527.c
--- a/drivers/net/3c527.c	Tue Nov 11 13:50:29 2003
+++ b/drivers/net/3c527.c	Tue Nov 11 13:50:29 2003
@@ -210,8 +210,6 @@
 
 
 /* Index to functions, as function prototypes. */
-extern int mc32_probe(struct net_device *dev);
-
 static int	mc32_probe1(struct net_device *dev, int ioaddr);
 static int      mc32_command(struct net_device *dev, u16 cmd, void *data, int len);
 static int	mc32_open(struct net_device *dev);
@@ -224,9 +222,19 @@
 static void	mc32_reset_multicast_list(struct net_device *dev);
 static struct ethtool_ops netdev_ethtool_ops;
 
+static void cleanup_card(struct net_device *dev)
+{
+	struct mc32_local *lp=dev->priv;
+	unsigned slot = lp->slot;
+	mca_mark_as_unused(slot);
+	mca_set_adapter_name(slot, NULL);
+	free_irq(dev->irq, dev);
+	release_region(dev->base_addr, MC32_IO_EXTENT);
+}
+
 /**
  * mc32_probe 	-	Search for supported boards
- * @dev: device to probe
+ * @unit: interface number to use
  *
  * Because MCA bus is a real bus and we can scan for cards we could do a
  * single scan for all boards here. Right now we use the passed in device
@@ -234,10 +242,18 @@
  * in particular.
  */
 
-int __init mc32_probe(struct net_device *dev)
+struct net_device *__init mc32_probe(int unit)
 {
+	struct net_device *dev = alloc_etherdev(sizeof(struct mc32_local));
 	static int current_mca_slot = -1;
 	int i;
+	int err;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	if (unit >= 0)
+		sprintf(dev->name, "eth%d", unit);
 
 	SET_MODULE_OWNER(dev);
 
@@ -258,12 +274,18 @@
 				mca_set_adapter_name(current_mca_slot, 
 						mc32_adapters[i].name);
 				mca_mark_as_used(current_mca_slot);
-				return 0;
+				err = register_netdev(dev);
+				if (err) {
+					cleanup_card(dev);
+					free_netdev(dev);
+					dev = ERR_PTR(err);
+				}
+				return dev;
 			}
 			
 		}
 	}
-	return -ENODEV;
+	return ERR_PTR(-ENODEV);
 }
 
 /**
@@ -283,7 +305,7 @@
 	int i, err;
 	u8 POS;
 	u32 base;
-	struct mc32_local *lp;
+	struct mc32_local *lp = dev->priv;
 	static u16 mca_io_bases[]={
 		0x7280,0x7290,
 		0x7680,0x7690,
@@ -410,24 +432,14 @@
 	 *	Grab the IRQ
 	 */
 
-	i = request_irq(dev->irq, &mc32_interrupt, SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
-	if (i) {
+	err = request_irq(dev->irq, &mc32_interrupt, SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
+	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return i;
-	}
-
-
-	/* Initialize the device structure. */
-	dev->priv = kmalloc(sizeof(struct mc32_local), GFP_KERNEL);
-	if (dev->priv == NULL)
-	{
-		err = -ENOMEM;
-		goto err_exit_irq; 
+		goto err_exit_ports; 
 	}
 
-	memset(dev->priv, 0, sizeof(struct mc32_local));
-	lp = dev->priv;
+	memset(lp, 0, sizeof(struct mc32_local));
 	lp->slot = slot;
 
 	i=0;
@@ -441,7 +453,7 @@
 		{
 			printk(KERN_ERR "%s: failed to boot adapter.\n", dev->name);
 			err = -ENODEV; 
-			goto err_exit_free;
+			goto err_exit_irq;
 		}
 		udelay(1000);
 		if(inb(dev->base_addr+2)&(1<<5))
@@ -456,7 +468,7 @@
 		else
 			printk(KERN_ERR "%s: unknown failure %d.\n", dev->name, base);
 		err = -ENODEV; 
-		goto err_exit_free;
+		goto err_exit_irq;
 	}
 	
 	base=0;
@@ -472,7 +484,7 @@
 			{
 				printk(KERN_ERR "%s: mailbox read fail (%d).\n", dev->name, i);
 				err = -ENODEV;
-				goto err_exit_free;
+				goto err_exit_irq;
 			}
 		}
 
@@ -515,15 +527,11 @@
 	dev->watchdog_timeo	= HZ*5;	/* Board does all the work */
 	dev->ethtool_ops	= &netdev_ethtool_ops;
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(dev);
-	
 	return 0;
 
-err_exit_free:
-	kfree(dev->priv);
 err_exit_irq:
 	free_irq(dev->irq, dev);
+err_exit_ports:
 	release_region(dev->base_addr, MC32_IO_EXTENT);
 	return err;
 }
@@ -1628,7 +1636,7 @@
 
 #ifdef MODULE
 
-static struct net_device this_device;
+static struct net_device *this_device;
 
 /**
  *	init_module		-	entry point
@@ -1640,12 +1648,9 @@
 
 int init_module(void)
 {
-	int result;
-	
-	this_device.init = mc32_probe;
-	if ((result = register_netdev(&this_device)) != 0)
-		return result;
-
+	this_device = mc32_probe(-1);
+	if (IS_ERR(this_device))
+		return PTR_ERR(this_device);
 	return 0;
 }
 
@@ -1662,24 +1667,9 @@
 
 void cleanup_module(void)
 {
-	int slot;
-	
-	unregister_netdev(&this_device);
-
-	/*
-	 * If we don't do this, we can't re-insmod it later.
-	 */
-	 
-	if (this_device.priv)
-	{
-		struct mc32_local *lp=this_device.priv;
-		slot = lp->slot;
-		mca_mark_as_unused(slot);
-		mca_set_adapter_name(slot, NULL);
-		kfree(this_device.priv);
-	}
-	free_irq(this_device.irq, &this_device);
-	release_region(this_device.base_addr, MC32_IO_EXTENT);
+	unregister_netdev(this_device);
+	cleanup_card(this_device);
+	free_netdev(this_device);
 }
 
 #endif /* MODULE */
diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Tue Nov 11 13:50:29 2003
+++ b/drivers/net/Space.c	Tue Nov 11 13:50:29 2003
@@ -90,7 +90,7 @@
 extern int macsonic_probe(struct net_device *dev);
 extern int mac8390_probe(struct net_device *dev);
 extern int mac89x0_probe(struct net_device *dev);
-extern int mc32_probe(struct net_device *dev);
+extern struct net_device *mc32_probe(int unit);
 extern struct net_device *cops_probe(int unit);
 extern struct net_device *ltpc_probe(void);
   
@@ -184,13 +184,13 @@
 #ifdef CONFIG_ELMC		/* 3c523 */
 	{elmc_probe, 0},
 #endif
-#ifdef CONFIG_ELMC_II		/* 3c527 */
-	{mc32_probe, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 mca_probes2[] __initdata = {
+#ifdef CONFIG_ELMC_II		/* 3c527 */
+	{mc32_probe, 0},
+#endif
 #ifdef CONFIG_SKMC              /* SKnet Microchannel */
         {skmca_probe, 0},
 #endif
