From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (06/12) Probe2 -- sk16
Date: Tue, 14 Oct 2003 15:34:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310142234.h9EMYAo30162@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

from viro NE17-sk16
	* switched sk_g16 to dynamic allocation
	* sk_g16: embedded ->priv
	* sk_g16: fixed buggy check for signature (|| instead of &&, somebody
	  forgot to replace it when inverting the test).
	* sk_g16: fixed use after kfree()
	* sk_g16: fixed init_etherdev() race
Additional:
	* add free_netdev
	

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Sep 29 09:44:51 2003
+++ b/drivers/net/Space.c	Mon Sep 29 09:44:51 2003
@@ -72,7 +72,7 @@
 extern struct net_device *ni52_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern int sonic_probe(struct net_device *);
-extern int SK_init(struct net_device *);
+extern struct net_device *SK_init(int unit);
 extern int seeq8005_probe(struct net_device *);
 extern int smc_init( struct net_device * );
 extern int atarilance_probe(struct net_device *);
@@ -277,13 +277,13 @@
 #ifdef CONFIG_ELPLUS		/* 3c505 */
 	{elplus_probe, 0},
 #endif
-#ifdef CONFIG_SK_G16
-	{SK_init, 0},
-#endif
 	{NULL, 0},
 };
 
 static struct devprobe2 isa_probes2[] __initdata = {
+#ifdef CONFIG_SK_G16
+	{SK_init, 0},
+#endif
 #ifdef CONFIG_NI5010
 	{ni5010_probe, 0},
 #endif
diff -Nru a/drivers/net/sk_g16.c b/drivers/net/sk_g16.c
--- a/drivers/net/sk_g16.c	Mon Sep 29 09:44:51 2003
+++ b/drivers/net/sk_g16.c	Mon Sep 29 09:44:51 2003
@@ -457,8 +457,6 @@
 /* static variables */
 
 static SK_RAM *board;  /* pointer to our memory mapped board components */
-static struct net_device *SK_dev;
-unsigned long SK_ioaddr;
 static spinlock_t SK_lock = SPIN_LOCK_UNLOCKED;
 
 /* Macros */
@@ -472,7 +470,6 @@
  * See for short explanation of each function its definitions header.
  */
 
-int          SK_init(struct net_device *dev);
 static int   SK_probe(struct net_device *dev, short ioaddr);
 
 static void  SK_timeout(struct net_device *dev);
@@ -530,84 +527,71 @@
  *     YY/MM/DD  uid  Description
 -*/
 
+static int io;	/* 0 == probe */
+
 /* 
  * Check for a network adaptor of this type, and return '0' if one exists.
  * If dev->base_addr == 0, probe all likely locations.
  * If dev->base_addr == 1, always return failure.
  */
 
-int __init SK_init(struct net_device *dev)
+struct net_device * __init SK_init(int unit)
 {
-	int ioaddr;			   /* I/O port address used for POS regs */
 	int *port, ports[] = SK_IO_PORTS;  /* SK_G16 supported ports */
 	static unsigned version_printed;
+	struct net_device *dev = alloc_etherdev(sizeof(struct priv));
+	int err = -ENODEV;
+
+	if (!dev)
+		return ERR_PTR(-ENOMEM);
 
-	/* get preconfigured base_addr from dev which is done in Space.c */
-	int base_addr = dev->base_addr; 
+	if (unit >= 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+		io = dev->base_addr;
+	}
 
 	if (version_printed++ == 0)
 	        PRINTK(("%s: %s", SK_NAME, rcsid));
 
-	if (base_addr > 0x0ff)        /* Check a single specified address */
-	{
-	    int rc = -ENODEV;
-
-	    ioaddr = base_addr;
+	if (io > 0xff) {        /* Check a single specified address */
+		err = -EBUSY;
+		/* Check if on specified address is a SK_G16 */
+		if (request_region(io, ETHERCARD_TOTAL_SIZE, "sk_g16")) {
+			err = SK_probe(dev, io);
+			if (!err)
+				goto got_it;
+			release_region(io, ETHERCARD_TOTAL_SIZE);
+		}
+	} else if (io > 0) {       /* Don't probe at all */
+		err = -ENXIO;
+	} else {
+		/* Autoprobe base_addr */
+		for (port = &ports[0]; *port; port++) {
+			io = *port;
+
+			/* Check if I/O Port region is used by another board */
+			if (!request_region(io, ETHERCARD_TOTAL_SIZE, "sk_g16"))
+				continue;       /* Try next Port address */
+
+			/* Check if at ioaddr is a SK_G16 */
+			if (SK_probe(dev, io) == 0)
+				goto got_it;
 
-	    /* Check if on specified address is a SK_G16 */
-	    if (!request_region(ioaddr, ETHERCARD_TOTAL_SIZE, "sk_g16"))
-	    	return -EBUSY;
-
-	    if ( (inb(SK_POS0) == SK_IDLOW) ||
-		 (inb(SK_POS1) == SK_IDHIGH) )  
-	    {
-		rc = SK_probe(dev, ioaddr);
-	    }
-
-	    if (rc)
-	        release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-	    return rc;
+			release_region(io, ETHERCARD_TOTAL_SIZE);
+		}
 	}
-	else if (base_addr > 0)       /* Don't probe at all */
-	{
-		return -ENXIO;
+err_out:
+	free_netdev(dev);
+	return ERR_PTR(err);
+
+got_it:
+	err = register_netdev(dev);
+	if (err) {
+		release_region(dev->base_addr, ETHERCARD_TOTAL_SIZE);
+		goto err_out;
 	}
-
-	/* Autoprobe base_addr */
-
-	for (port = &ports[0]; *port; port++) 
-	{
-	    ioaddr = *port;           /* we need ioaddr for accessing POS regs */
-
-	    /* Check if I/O Port region is used by another board */
-
-	    if (!request_region(ioaddr, ETHERCARD_TOTAL_SIZE, "sk_g16"))
-	    {
-		continue;             /* Try next Port address */
-	    }
-
-	    /* Check if at ioaddr is a SK_G16 */
-
-	    if ( !(inb(SK_POS0) == SK_IDLOW) ||
-		 !(inb(SK_POS1) == SK_IDHIGH) )
-	    {
-	        release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-		continue;             /* Try next Port address */
-	    }
-
-	    dev->base_addr = ioaddr;  /* Set I/O Port Address */
-
-	    if (SK_probe(dev, ioaddr) == 0)  
-	    {
-		return 0; /* Card found and initialized */
-	    }
-
-	    release_region(ioaddr, ETHERCARD_TOTAL_SIZE);
-	}
-
-	dev->base_addr = base_addr;   /* Write back original base_addr */
-
-	return -ENODEV;                /* Failed to find or init driver */
+	return dev;
 
 } /* End of SK_init */
 
@@ -620,54 +604,22 @@
 
 
 #ifdef MODULE
-static int io;	/* 0 == probe */
-
 static int __init SK_init_module (void)
 {
-	int rc;
-	
-	SK_dev = init_etherdev (NULL, 0);
-	if (!SK_dev)
-		return -ENOMEM;
-	
-	SK_dev->base_addr = io;
-
-	rc = SK_init (SK_dev);
-	if (rc) {
-		unregister_netdev (SK_dev);
-		kfree (SK_dev);
-		SK_dev = NULL;
-	}
-	
-	return rc;
+ 	SK_dev = SK_init(-1);
+ 	return IS_ERR(SK_dev) ? PTR_ERR(SK_dev) : 0;
 }
-#endif /* MODULE */
-
 
 static void __exit SK_cleanup_module (void)
 {
-	if (SK_dev) {
-		if (SK_dev->priv) {
-			kfree(SK_dev->priv);
-			SK_dev->priv = NULL;
-		}
-		unregister_netdev(SK_dev);
-		free_netdev(SK_dev);
-		SK_dev = NULL;
-	}
-	if (SK_ioaddr) {
-		release_region(SK_ioaddr, ETHERCARD_TOTAL_SIZE);
-		SK_ioaddr = 0;
-	}
-		
+ 	unregister_netdev(SK_dev);
+ 	release_region(SK_dev->base_addr, ETHERCARD_TOTAL_SIZE);
+ 	free_netdev(SK_dev);
 }
 
-
-#ifdef MODULE
 module_init(SK_init_module);
-#endif
 module_exit(SK_cleanup_module);
-
+#endif
 
 
 /*-
@@ -695,7 +647,11 @@
     int sk_addr_flag = 0;   /* SK ADDR correct? 1 - no, 0 - yes */
     unsigned int rom_addr;  /* used to store RAM address used for POS_ADDR */
 
-    struct priv *p;         /* SK_G16 private structure */
+    struct priv *p = dev->priv;         /* SK_G16 private structure */
+
+    if (inb(SK_POS0) != SK_IDLOW || inb(SK_POS1) != SK_IDHIGH)
+	return -ENODEV;
+    dev->base_addr = ioaddr;
 
     if (SK_ADDR & 0x3fff || SK_ADDR < 0xa0000)
     {
@@ -837,12 +793,6 @@
 	    dev->dev_addr[4],
 	    dev->dev_addr[5]);
 
-    /* Allocate memory for private structure */
-    p = dev->priv = (void *) kmalloc(sizeof(struct priv), GFP_KERNEL);
-    if (p == NULL) {
-	   printk("%s: ERROR - no memory for driver data!\n", dev->name);
-	   return -ENOMEM;
-    }
     memset((char *) dev->priv, 0, sizeof(struct priv)); /* clear memory */
 
     /* Assign our Device Driver functions */
@@ -856,10 +806,6 @@
     dev->watchdog_timeo		= HZ/7;
 
 
-    /* Set the generic fields of the device structure */
-
-    ether_setup(dev);
-    
     dev->flags &= ~IFF_MULTICAST;
 
     /* Initialize private structure */
@@ -884,12 +830,7 @@
     SK_print_pos(dev, "End of SK_probe");
     SK_print_ram(dev);
 #endif 
-
-    SK_dev = dev;
-    SK_ioaddr = ioaddr;
-
     return 0;                            /* Initialization done */
-
 } /* End of SK_probe() */
 
 
@@ -1280,7 +1221,7 @@
 
 	memcpy_toio((tmdp->u.buffer & 0x00ffffff), skb->data, skb->len);
 	if (len != skb->len)
-		memcpy_toio((tmdp->u.buffer & 0x00ffffff) + sb->len, pad, len-skb->len);
+		memcpy_toio((tmdp->u.buffer & 0x00ffffff) + skb->len, pad, len-skb->len);
 
 	writew(-len, &tmdp->blen);            /* set length to transmit */
 
