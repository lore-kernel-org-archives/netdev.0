From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/6) smctr -- probe2
Date: Wed, 15 Oct 2003 13:48:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152048.h9FKm0911880@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert the SMC tokenring driver to new probing.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Oct 15 13:33:05 2003
+++ b/drivers/net/Space.c	Wed Oct 15 13:33:05 2003
@@ -412,9 +412,12 @@
 extern int ibmtr_probe(struct net_device *);
 extern int sk_isa_probe(struct net_device *);
 extern int proteon_probe(struct net_device *);
-extern int smctr_probe(struct net_device *);
+extern struct net_device *smctr_probe(int unit);
 
 static struct devprobe2 tr_probes2[] __initdata = {
+#ifdef CONFIG_SMCTR
+	{smctr_probe, 0},
+#endif
 	{NULL, 0},
 };
 
@@ -438,9 +441,6 @@
 #endif
 #ifdef CONFIG_PROTEON
 	    proteon_probe(dev) == 0 ||
-#endif
-#ifdef CONFIG_SMCTR
-	    smctr_probe(dev) == 0 ||
 #endif
 	    0 ) 
 		err = register_netdev(dev);
diff -Nru a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
--- a/drivers/net/tokenring/smctr.c	Wed Oct 15 13:33:05 2003
+++ b/drivers/net/tokenring/smctr.c	Wed Oct 15 13:33:05 2003
@@ -69,13 +69,6 @@
 
 #define SMCTR_IO_EXTENT   20
 
-/* A zero-terminated list of I/O addresses to be probed. */
-static unsigned int smctr_portlist[] __initdata = {
-        0x200, 0x220, 0x240, 0x260, 0x280, 0x2A0, 0x2C0, 0x2E0, 0x300,
-        0x320, 0x340, 0x360, 0x380,
-        0
-};
-
 #ifdef CONFIG_MCA
 static unsigned int smctr_posid = 0x6ec6;
 #endif
@@ -219,7 +212,7 @@
 static int smctr_open_tr(struct net_device *dev);
 
 /* P */
-int __init smctr_probe (struct net_device *dev);
+struct net_device *smctr_probe(int unit);
 static int __init smctr_probe1(struct net_device *dev, int ioaddr);
 static int smctr_process_rx_packet(MAC_HEADER *rmf, __u16 size,
         struct net_device *dev, __u16 rx_status);
@@ -3583,71 +3576,72 @@
         return (err);
 }
 
-/* Check for a network adapter of this type, and return '0 if one exists.
- * If dev->base_addr == 0, probe all likely locations.
- * If dev->base_addr == 1, always return failure.
+/* Check for a network adapter of this type, 
+ * and return device structure if one exists.
  */
-int __init smctr_probe (struct net_device *dev)
+struct net_device __init *smctr_probe(int unit)
 {
-        int i;
-        int base_addr;
+	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
+	static const unsigned ports[] = {
+		0x200, 0x220, 0x240, 0x260, 0x280, 0x2A0, 0x2C0, 0x2E0, 0x300,
+		0x320, 0x340, 0x360, 0x380, 0
+	};
+	const unsigned *port;
+        int err = 0;
 
-#ifndef MODULE
-	netdev_boot_setup_check(dev);
-	tr_setup(dev);
-#endif
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-        base_addr = dev->base_addr;
-        if(base_addr > 0x1ff)    /* Check a single specified location. */
-                return (smctr_probe1(dev, base_addr));
-        else if(base_addr != 0)  /* Don't probe at all. */
-                return (-ENXIO);
+	SET_MODULE_OWNER(dev);
 
-        for(i = 0; smctr_portlist[i]; i++)
-        {
-                int ioaddr = smctr_portlist[i];
-                if (!smctr_probe1(dev, ioaddr))
-                        return (0);
-        }
-
-        return (-ENODEV);
-}
+	if (unit >= 0) {
+		sprintf(dev->name, "tr%d", unit);
+		netdev_boot_setup_check(dev);
+	}
 
-static void cleanup_card(struct net_device *dev)
-{
+        if (dev->base_addr > 0x1ff)    /* Check a single specified location. */
+		err = smctr_probe1(dev, dev->base_addr);
+        else if(dev->base_addr != 0)  /* Don't probe at all. */
+                err =-ENXIO;
+	else {
+		for (port = ports; *port; port++) {
+			err = smctr_probe1(dev, *port);
+			if (!err)
+				break;
+		}
+	}
+	if (err)
+		goto out;
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+out1:
 #ifdef CONFIG_MCA
-	struct net_local *tp = (struct net_local *)dev->priv;
-	if (tp->slot_num)
+	{ struct net_local *tp = (struct net_local *)dev->priv;
+	  if (tp->slot_num)
 		mca_mark_as_unused(tp->slot_num);
+	}
 #endif
 	release_region(dev->base_addr, SMCTR_IO_EXTENT);
-	if (dev->irq)
-		free_irq(dev->irq, dev);
-	if (dev->priv)
-		kfree(dev->priv);
+	free_irq(dev->irq, dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
 }
 
+
 static int __init smctr_probe1(struct net_device *dev, int ioaddr)
 {
         static unsigned version_printed;
-        struct net_local *tp;
+        struct net_local *tp = dev->priv;
         int err;
         __u32 *ram;
 
         if(smctr_debug && version_printed++ == 0)
                 printk(version);
 
-        /* Setup this devices private information structure */
-        tp = (struct net_local *)kmalloc(sizeof(struct net_local),
-                GFP_KERNEL);
-        if(tp == NULL) {
-		err = -ENOMEM;
-		goto out;
-	}
-        memset(tp, 0, sizeof(struct net_local));
         spin_lock_init(&tp->lock);
-        
-        dev->priv = tp;
         dev->base_addr = ioaddr;
 
 	/* Actually detect an adapter now. */
@@ -3656,7 +3650,7 @@
         {
 		if ((err = smctr_chk_mca(dev)) < 0) {
 			err = -ENODEV;
-			goto out_tp;
+			goto out;
 		}
         }
 
@@ -3671,7 +3665,6 @@
         if(err != UCODE_PRESENT && err != SUCCESS)
         {
                 printk(KERN_ERR "%s: Firmware load failed (%d)\n", dev->name, err);
-		cleanup_card(dev);
 		err = -EIO;
 		goto out;
         }
@@ -3696,8 +3689,6 @@
         dev->set_multicast_list = &smctr_set_multicast_list;
         return (0);
 
-out_tp:
-	kfree(tp);
 out:
 	return err;
 }
@@ -5669,47 +5660,59 @@
 static struct net_device* dev_smctr[SMCTR_MAX_ADAPTERS];
 static int io[SMCTR_MAX_ADAPTERS];
 static int irq[SMCTR_MAX_ADAPTERS];
-static int mem[SMCTR_MAX_ADAPTERS];
 
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(io,  "1-" __MODULE_STRING(SMCTR_MAX_ADAPTERS) "i");
+MODULE_PARM(io, "1-" __MODULE_STRING(SMCTR_MAX_ADAPTERS) "i");
 MODULE_PARM(irq, "1-" __MODULE_STRING(SMCTR_MAX_ADAPTERS) "i");
-MODULE_PARM(mem, "1-" __MODULE_STRING(SMCTR_MAX_ADAPTERS) "i");
-MODULE_PARM(ringspeed, "1-" __MODULE_STRING(SMCTR_MAX_ADAPTERS) "i");
+MODULE_PARM(ringspeed, "i");
+
+static struct net_device *setup_card(int n)
+{
+	struct net_device *dev = alloc_trdev(sizeof(struct net_local));
+	int err;
+	
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
+
+	dev->irq = irq[n];
+	err = smctr_probe1(dev, io[n]);
+	if (err) 
+		goto out;
+		
+	err = register_netdev(dev);
+	if (err)
+		goto out1;
+	return dev;
+ out1:
+#ifdef CONFIG_MCA
+	{ struct net_local *tp = (struct net_local *)dev->priv;
+	  if (tp->slot_num)
+		mca_mark_as_unused(tp->slot_num);
+	}
+#endif
+	release_region(dev->base_addr, SMCTR_IO_EXTENT);
+	free_irq(dev->irq, dev);
+out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+}
+			
 
 int init_module(void)
 {
-        int i;
+        int i, found = 0;
+	struct net_device *dev;
 
         for(i = 0; i < SMCTR_MAX_ADAPTERS; i++) {
-		struct net_device *dev = alloc_trdev(0);
-                irq[i] = 0;
-                mem[i] = 0;
-		if (!dev)
-			return -ENOMEM;
-                dev->base_addr = io[i];
-                dev->irq       = irq[i];
-                dev->mem_start = mem[i];
-
-		if (smctr_probe(dev) != 0) {
-                        kfree(dev);
-                        if (i == 0) {
-                                printk(KERN_ERR "%s: smctr_probe failed.\n",
-                                        cardname);
-                                return -EIO;
-                        }
-			return 0;
-                }
-		if (register_netdev(dev) != 0) {
-                        cleanup_card(dev);
-			kfree(dev);
-			continue;
-                }
-                dev_smctr[i] = dev;
+		dev = io[0]? setup_card(i) : smctr_probe(-1);
+		if (!IS_ERR(dev)) {
+			++found;
+			dev_smctr[i] = dev;
+		}
         }
 
-        return (0);
+        return found ? 0 : -ENODEV;
 }
 
 void cleanup_module(void)
@@ -5718,9 +5721,20 @@
 
         for(i = 0; i < SMCTR_MAX_ADAPTERS; i++) {
 		struct net_device *dev = dev_smctr[i];
+
 		if (dev) {
+
 			unregister_netdev(dev);
-			cleanup_card(dev);
+#ifdef CONFIG_MCA
+			{ struct net_local *tp = dev->priv;
+			if (tp->slot_num)
+				mca_mark_as_unused(tp->slot_num);
+			}
+#endif
+			release_region(dev->base_addr, SMCTR_IO_EXTENT);
+			if (dev->irq)
+				free_irq(dev->irq, dev);
+
 			free_netdev(dev);
 		}
         }
