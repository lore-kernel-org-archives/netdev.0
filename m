From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3C501] Do not use dev->name before register_netdev
Date: Sat, 13 Mar 2004 13:59:40 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313025940.GA8218@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040313025859.GA8186@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Mar 13, 2004 at 01:58:59PM +1100, herbert wrote:
> 
> This patch replaces/removes all uses of dev->name in 8390 drivers.
> As it is, these drivers will do printks or allocate resources with
> the name eth%d.

Here is the same fix for 3c501.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="devname.1"

Index: kernel-2.5/drivers/net/3c501.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/3c501.c,v
retrieving revision 1.1.1.9
diff -u -r1.1.1.9 3c501.c
--- kernel-2.5/drivers/net/3c501.c	19 Feb 2004 08:54:53 -0000	1.1.1.9
+++ kernel-2.5/drivers/net/3c501.c	12 Mar 2004 22:49:08 -0000
@@ -182,20 +182,12 @@
 	} else if (io != 0) {
 		err = -ENXIO;		/* Don't probe at all. */
 	} else {
-		for (port = ports; *port && el1_probe1(dev, *port); port++)
-			;
-		if (!*port)
-			err = -ENODEV;
+		for (port = ports; *port; port++)
+			if (!(err = el1_probe1(dev, *port)))
+				break;
 	}
-	if (err)
-		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
-	return dev;
-out1:
-	release_region(dev->base_addr, EL1_IO_EXTENT);
-out:
+	if (err == 0)
+		return dev;
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
@@ -220,12 +212,13 @@
 	unsigned char station_addr[6];
 	int autoirq = 0;
 	int i;
+	int err;
 
 	/*
 	 *	Reserve I/O resource for exclusive use by this driver
 	 */
 
-	if (!request_region(ioaddr, EL1_IO_EXTENT, dev->name))
+	if (!request_region(ioaddr, EL1_IO_EXTENT, "3c501"))
 		return -ENODEV;
 
 	/*
@@ -295,16 +288,6 @@
 	if (autoirq)
 		dev->irq = autoirq;
 
-	printk(KERN_INFO "%s: %s EtherLink at %#lx, using %sIRQ %d.\n", dev->name, mname, dev->base_addr,
-			autoirq ? "auto":"assigned ", dev->irq);
-
-#ifdef CONFIG_IP_MULTICAST
-	printk(KERN_WARNING "WARNING: Use of the 3c501 in a multicast kernel is NOT recommended.\n");
-#endif
-
-	if (el_debug)
-		printk(KERN_DEBUG "%s", version);
-
 	memset(dev->priv, 0, sizeof(struct net_local));
 	lp=dev->priv;
 	spin_lock_init(&lp->lock);
@@ -321,6 +304,23 @@
 	dev->get_stats = &el1_get_stats;
 	dev->set_multicast_list = &set_multicast_list;
 	dev->ethtool_ops = &netdev_ethtool_ops;
+
+	err = register_netdev(dev);
+	if (err) {
+		release_region(ioaddr, EL1_IO_EXTENT);
+		return err;
+	}
+
+	printk(KERN_INFO "%s: %s EtherLink at %#lx, using %sIRQ %d.\n", dev->name, mname, dev->base_addr,
+			autoirq ? "auto":"assigned ", dev->irq);
+
+#ifdef CONFIG_IP_MULTICAST
+	printk(KERN_WARNING "WARNING: Use of the 3c501 in a multicast kernel is NOT recommended.\n");
+#endif
+
+	if (el_debug)
+		printk(KERN_DEBUG "%s", version);
+
 	return 0;
 }
 

--W/nzBZO5zC0uMSeA--
