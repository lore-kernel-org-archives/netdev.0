From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/7) de620 -- dynamic allocation (resend)
Date: Wed, 24 Sep 2003 10:03:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030924100326.48f0f76a.shemminger@osdl.org>
References: <20030923144721.6001c598.shemminger@osdl.org>
	<3F70E809.6010509@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart_Wed__24_Sep_2003_10:03:26_-0700_08746280"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F70E809.6010509@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart_Wed__24_Sep_2003_10:03:26_-0700_08746280
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Convert de620 (original from Al Viro)
	* switched de620 to dynamic allocation
	* de620: embedded ->priv
	* de620: fixed IO before request_region()
	+ fetch and don't clobber command line baseaddr

This applies against 2.6.0-test5 bk latest with the probe2 (0/7) applied.
Revision history of Space.c were:  

======== Space.c 1.1..1.40 ========
D 1.40 03/09/23 05:56:25-07:00 shemminger@osdl.org[shemminger] 42 41 34/1/481
P drivers/net/Space.c
C Import patch 0-probe2
------------------------------------------------
D 1.39 03/09/23 12:09:54-07:00 shemminger@osdl.org 41 40 8/6/474
P drivers/net/Space.c
C [NET]: Fix boot param string setup in Space.c
------------------------------------------------
D 1.38 03/09/23 12:08:59-07:00 shemminger@osdl.org 40 39 3/6/477
P drivers/net/Space.c
C [NET]: Fix inaccurate comments in Space.c
------------------------------------------------
D 1.37 03/09/23 12:08:25-07:00 shemminger@osdl.org 39 38 3/11/480
P drivers/net/Space.c
C [NET]: No need for alloc_divert_blk in Space.c
------------------------------------------------
D 1.36 03/09/12 13:40:26-04:00 mzyngier@freesurf.fr[jgarzik] 38 37 0/4/491
P drivers/net/Space.c
C depca update
------------------------------------------------
D 1.35 03/09/08 10:01:25-04:00 shemminger@osdl.org[jgarzik] 37 36 0/5/495
P drivers/net/Space.c
C (1/4) sdla - move out of Space.c


--Multipart_Wed__24_Sep_2003_10:03:26_-0700_08746280
Content-Type: text/x-diff;
 name="1-de620.patch"
Content-Disposition: attachment;
 filename="1-de620.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Wed Sep 24 09:54:28 2003
+++ b/drivers/net/Space.c	Wed Sep 24 09:54:28 2003
@@ -97,7 +97,7 @@
 extern struct net_device *ltpc_probe(void);
  =20
 /* Detachable devices ("pocket adaptors") */
-extern int de620_probe(struct net_device *);
+extern struct net_device *de620_probe(int unit);
=20
 /* Fibre Channel adapters */
 extern int iph5526_probe(struct net_device *dev);
@@ -296,7 +296,7 @@
 	{NULL, 0},
 };
=20
-static struct devprobe parport_probes[] __initdata =3D {
+static struct devprobe2 parport_probes[] __initdata =3D {
 #ifdef CONFIG_DE620		/* D-Link DE-620 adapter */
 	{de620_probe, 0},
 #endif
@@ -387,8 +387,7 @@
 	    probe_list(dev, mips_probes) =3D=3D 0 ||
 	    probe_list(dev, eisa_probes) =3D=3D 0 ||
 	    probe_list(dev, mca_probes) =3D=3D 0 ||
-	    probe_list(dev, isa_probes) =3D=3D 0 ||
-	    probe_list(dev, parport_probes) =3D=3D 0)=20
+	    probe_list(dev, isa_probes) =3D=3D 0)
 		err =3D register_netdev(dev);
=20
 	if (err)
@@ -404,7 +403,7 @@
 	if (base_addr =3D=3D 1)
 		return;
=20
-	return;	/* nothing yet */
+	probe_list2(unit, parport_probes, base_addr =3D=3D 0);
 }
=20
 #ifdef CONFIG_TR
diff -Nru a/drivers/net/de620.c b/drivers/net/de620.c
--- a/drivers/net/de620.c	Wed Sep 24 09:54:28 2003
+++ b/drivers/net/de620.c	Wed Sep 24 09:54:28 2003
@@ -226,7 +226,6 @@
=20
 /* Initialization */
 static int	adapter_init(struct net_device *);
-int		de620_probe(struct net_device *);
 static int	read_eeprom(struct net_device *);
=20
=20
@@ -814,11 +813,16 @@
  *
  * Check if there is a DE-620 connected
  */
-int __init de620_probe(struct net_device *dev)
+struct net_device * __init de620_probe(int unit)
 {
-	static struct net_device_stats de620_netstats;
-	int i;
 	byte checkbyte =3D 0xa5;
+	struct net_device *dev;
+	int err =3D -ENOMEM;
+	int i;
+
+	dev =3D alloc_etherdev(sizeof(struct net_device_stats));
+	if (!dev)
+		goto out;
=20
 	SET_MODULE_OWNER(dev);
=20
@@ -831,11 +835,23 @@
 	dev->base_addr =3D io;
 	dev->irq       =3D irq;
=20
+	/* allow overriding parameters on command line */
+	if (unit >=3D 0) {
+		sprintf(dev->name, "eth%d", unit);
+		netdev_boot_setup_check(dev);
+	}
+=09
 	if (de620_debug)
 		printk(version);
=20
 	printk(KERN_INFO "D-Link DE-620 pocket adapter");
=20
+	if (!request_region(dev->base_addr, 3, "de620")) {
+		printk(" io 0x%3lX, which is busy.\n", dev->base_addr);
+		err =3D -EBUSY;
+		goto out1;
+	}
+
 	/* Initially, configure basic nibble mode, so we can read the EEPROM */
 	NIC_Cmd =3D DEF_NIC_CMD;
 	de620_set_register(dev, W_EIP, EIPRegister);
@@ -846,12 +862,8 @@
=20
 	if ((checkbyte !=3D 0xa5) || (read_eeprom(dev) !=3D 0)) {
 		printk(" not identified in the printer port\n");
-		return -ENODEV;
-	}
-
-	if (!request_region(dev->base_addr, 3, "de620")) {
-		printk(KERN_ERR "io 0x%3lX, which is busy.\n", dev->base_addr);
-		return -EBUSY;
+		err =3D -ENODEV;
+		goto out2;
 	}
=20
 	/* else, got it! */
@@ -870,10 +882,6 @@
 	else
 		printk(" UTP)\n");
=20
-	/* Initialize the device structure. */
-	dev->priv =3D &de620_netstats;
-
-	memset(dev->priv, 0, sizeof(struct net_device_stats));
 	dev->get_stats 		=3D get_stats;
 	dev->open 		=3D de620_open;
 	dev->stop 		=3D de620_close;
@@ -884,8 +892,6 @@
 =09
 	/* base_addr and irq are already set, see above! */
=20
-	ether_setup(dev);
-
 	/* dump eeprom */
 	if (de620_debug) {
 		printk("\nEEPROM contents:\n");
@@ -899,7 +905,17 @@
 		printk("SCR =3D 0x%02x\n", nic_data.SCR);
 	}
=20
-	return 0;
+	err =3D register_netdev(dev);
+	if (err)
+		goto out2;
+	return dev;
+
+out2:
+	release_region(dev->base_addr, 3);
+out1:
+	free_netdev(dev);
+out:
+	return ERR_PTR(err);
 }
 =0C
 /**********************************
@@ -994,20 +1010,21 @@
  *
  */
 #ifdef MODULE
-static struct net_device de620_dev;
+static struct net_device *de620_dev;
=20
 int init_module(void)
 {
-	de620_dev.init =3D de620_probe;
-	if (register_netdev(&de620_dev) !=3D 0)
-		return -EIO;
+	de620_dev =3D de620_probe(-1);
+	if (IS_ERR(de620_dev))
+		return PTR_ERR(de620_dev);
 	return 0;
 }
=20
 void cleanup_module(void)
 {
-	unregister_netdev(&de620_dev);
-	release_region(de620_dev.base_addr, 3);
+	unregister_netdev(de620_dev);
+	release_region(de620_dev->base_addr, 3);
+	free_netdev(de620_dev);
 }
 #endif /* MODULE */
 MODULE_LICENSE("GPL");

--Multipart_Wed__24_Sep_2003_10:03:26_-0700_08746280--
