From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sa1100ir - fix for 2.6
Date: Fri, 5 Dec 2003 15:06:01 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205150601.68c52de3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, irda-users@sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk@arm.linux.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Alexander Viro <aviro@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update the ARM SA1100 irda driver to current 2.6 network device model
  * allocate network device with alloc_irdadev - get rid of dev_alloc
  * change to current system device class model - looks like it was using early
    old version of interface from 2.5
  * better error unwind

This has been cross compiled successfully against net-drivers-2.5-exp

diff -Nru a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
--- a/drivers/net/irda/sa1100_ir.c	Fri Dec  5 14:48:38 2003
+++ b/drivers/net/irda/sa1100_ir.c	Fri Dec  5 14:48:38 2003
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/device.h>
 #include <linux/dma-mapping.h>
+#include <linux/sysdev.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/wrapper.h>
@@ -56,6 +57,11 @@
 static int tx_lpm;
 static int max_rate = 4000000;
 
+/*
+ * Our netdevice.  There is only ever one of these.
+ */
+static struct net_device *netdev;
+
 struct sa1100_irda {
 	unsigned char		hscr0;
 	unsigned char		utcr4;
@@ -947,56 +953,77 @@
 	return io->head ? 0 : -ENOMEM;
 }
 
-static struct device_driver sa1100ir_driver = {
-	.name		= "sa1100ir",
-	.bus		= &system_bus_type,
+static struct sysdev_class sa1100ir_sysdev_class = {
+	set_kset_name("sa1100ir"),
 	.suspend	= sa1100_irda_suspend,
 	.resume		= sa1100_irda_resume,
 };
 
 static struct sys_device sa1100ir_device = {
-	.name		= "sa1100ir",
 	.id		= 0,
-	.root		= NULL,
-	.dev		= {
-		.name	= "Intel Corporation SA11x0 [IrDA]",
-		.bus_id	= "0",
-		.driver	= &sa1100ir_driver,
-	},
+	.cls		= &sa1100ir_sysdev_class,
 };
 
-static int sa1100_irda_net_init(struct net_device *dev)
+static int __init sa1100_irda_init(void)
 {
-	struct sa1100_irda *si = dev->priv;
+	struct net_device *dev;
+	struct sa1100_irda *si;
 	unsigned int baudrate_mask;
-	int err = -ENOMEM;
-
-	si = kmalloc(sizeof(struct sa1100_irda), GFP_KERNEL);
-	if (!si)
-		goto out;
-
-	memset(si, 0, sizeof(*si));
+	int err;
 
-	si->dev = &sa1100ir_device.dev;
+	/* Register as a system device with sysfs */
+	err = sysdev_class_register(&sa1100ir_sysdev_class);
+	if (err)
+		goto err_sys_1;
+	
+	err = sys_device_register(&sa1100ir_device);
+	if (err)
+		goto err_sys_2;
 
 	/*
-	 * Initialise the HP-SIR buffers
+	 * Limit power level a sensible range.
 	 */
-	err = sa1100_irda_init_iobuf(&si->rx_buff, 14384);
+	if (power_level < 1)
+		power_level = 1;
+	if (power_level > 3)
+		power_level = 3;
+
+	err = request_mem_region(__PREG(Ser2UTCR0), 0x24, "IrDA") ? 0 : -EBUSY;
 	if (err)
-		goto out;
-	err = sa1100_irda_init_iobuf(&si->tx_buff, 4000);
+		goto err_mem_1;
+	err = request_mem_region(__PREG(Ser2HSCR0), 0x1c, "IrDA") ? 0 : -EBUSY;
+	if (err)
+		goto err_mem_2;
+	err = request_mem_region(__PREG(Ser2HSCR2), 0x04, "IrDA") ? 0 : -EBUSY;
 	if (err)
-		goto out_free_rx;
+		goto err_mem_3;
+
+	err = -ENOMEM;
+	dev = alloc_irdadev(sizeof(struct sa1100_irda));
+	if (!dev) 
+		goto err_mem_4;
+
+	si = dev->priv;
+	dev->irq = IRQ_Ser2ICP;
 
-	dev->priv = si;
 	dev->hard_start_xmit	= sa1100_irda_hard_xmit;
 	dev->open		= sa1100_irda_start;
 	dev->stop		= sa1100_irda_stop;
 	dev->do_ioctl		= sa1100_irda_ioctl;
 	dev->get_stats		= sa1100_irda_stats;
 
-	irda_device_setup(dev);
+	SET_MODULE_OWNER(dev);
+
+	/*
+	 * Initialise the HP-SIR buffers
+	 */
+	err = sa1100_irda_init_iobuf(&si->rx_buff, 14384);
+	if (err)
+		goto err_buf_1;
+	err = sa1100_irda_init_iobuf(&si->tx_buff, 4000);
+	if (err)
+		goto err_buf_2;
+
 	irda_init_max_qos_capabilies(&si->qos);
 
 	/*
@@ -1030,110 +1057,55 @@
 	Ser2UTCR4 = si->utcr4;
 	Ser2HSCR0 = HSCR0_UART;
 
+	err = register_netdev(dev);
+	if (err)
+		goto err_registration;
+
+	netdev = dev;
+	
 	return 0;
 
+err_registration:
 	kfree(si->tx_buff.head);
-out_free_rx:
+err_buf_2:
 	kfree(si->rx_buff.head);
-out:
-	kfree(si);
-
-	return err;
-}
+err_buf_1:
+	free_netdev(dev);
+err_mem_4:
 
-/*
- * Remove all traces of this driver module from the kernel, so we can't be
- * called.  Note that the device has already been stopped, so we don't have
- * to worry about interrupts or dma.
- */
-static void sa1100_irda_net_uninit(struct net_device *dev)
-{
-	struct sa1100_irda *si = dev->priv;
-
-	dev->hard_start_xmit	= NULL;
-	dev->open		= NULL;
-	dev->stop		= NULL;
-	dev->do_ioctl		= NULL;
-	dev->get_stats		= NULL;
-	dev->priv		= NULL;
-
-	kfree(si->tx_buff.head);
-	kfree(si->rx_buff.head);
-	kfree(si);
-}
-
-static int __init sa1100_irda_init(void)
-{
-	struct net_device *dev;
-	int err;
-
-	/*
-	 * Limit power level a sensible range.
-	 */
-	if (power_level < 1)
-		power_level = 1;
-	if (power_level > 3)
-		power_level = 3;
-
-	err = request_mem_region(__PREG(Ser2UTCR0), 0x24, "IrDA") ? 0 : -EBUSY;
-	if (err)
-		goto err_mem_1;
-	err = request_mem_region(__PREG(Ser2HSCR0), 0x1c, "IrDA") ? 0 : -EBUSY;
-	if (err)
-		goto err_mem_2;
-	err = request_mem_region(__PREG(Ser2HSCR2), 0x04, "IrDA") ? 0 : -EBUSY;
-	if (err)
-		goto err_mem_3;
-
-	driver_register(&sa1100ir_driver);
-	sys_device_register(&sa1100ir_device);
-
-	rtnl_lock();
-	dev = dev_alloc("irda%d", &err);
-	if (dev) {
-		dev->irq    = IRQ_Ser2ICP;
-		dev->init   = sa1100_irda_net_init;
-		dev->uninit = sa1100_irda_net_uninit;
-
-		err = register_netdevice(dev);
-
-		if (err)
-			kfree(dev);
-		else
-			dev_set_drvdata(&sa1100ir_device.dev, dev);
-	}
-	rtnl_unlock();
-
-	if (err) {
-		sys_device_unregister(&sa1100ir_device);
-		driver_unregister(&sa1100ir_driver);
-
-		release_mem_region(__PREG(Ser2HSCR2), 0x04);
+	release_mem_region(__PREG(Ser2HSCR2), 0x04);
 err_mem_3:
-		release_mem_region(__PREG(Ser2HSCR0), 0x1c);
+	release_mem_region(__PREG(Ser2HSCR0), 0x1c);
 err_mem_2:
-		release_mem_region(__PREG(Ser2UTCR0), 0x24);
-	}
+	release_mem_region(__PREG(Ser2UTCR0), 0x24);
 err_mem_1:
+	sys_device_unregister(&sa1100ir_device);
+err_sys_2:
+	sysdev_class_unregister(&sa1100ir_sysdev_class);
+err_sys_1:
 	return err;
 }
 
 static void __exit sa1100_irda_exit(void)
 {
-	struct net_device *dev = dev_get_drvdata(&sa1100ir_device.dev);
+	struct net_device *dev = netdev;
 
-	if (dev)
+	if (dev) {
+		struct sa1100_irda *si = dev->priv;
 		unregister_netdev(dev);
 
-	sys_device_unregister(&sa1100ir_device);
-	driver_unregister(&sa1100ir_driver);
+		kfree(si->tx_buff.head);
+		kfree(si->rx_buff.head);
+		release_mem_region(__PREG(Ser2HSCR2), 0x04);
+		release_mem_region(__PREG(Ser2HSCR0), 0x1c);
+		release_mem_region(__PREG(Ser2UTCR0), 0x24);
+		free_netdev(dev);
 
-	release_mem_region(__PREG(Ser2HSCR2), 0x04);
-	release_mem_region(__PREG(Ser2HSCR0), 0x1c);
-	release_mem_region(__PREG(Ser2UTCR0), 0x24);
+		sys_device_unregister(&sa1100ir_device);
+		sysdev_class_unregister(&sa1100ir_sysdev_class);
 
-	if(dev)
-		free_netdev(dev);
+		netdev = NULL;
+	}
 }
 
 static int __init sa1100ir_setup(char *line)
