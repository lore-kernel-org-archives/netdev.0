From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/6) tokenring probing change
Date: Wed, 15 Oct 2003 13:47:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310152047.h9FKltw11805@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ISA token ring drivers to the new probe2 infrastructure
that allows driver to allocate network device in the same way
for both modular and non-modular cases.

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Mon Oct 13 13:08:06 2003
+++ b/drivers/net/Space.c	Mon Oct 13 13:08:06 2003
@@ -430,26 +430,6 @@
 	{NULL, 0},
 };
 
-static __init int trif_probe(int unit)
-{
-	struct net_device *dev;
-	int err = -ENODEV;
-	
-	dev = alloc_trdev(0);
-	if (!dev)
-		return -ENOMEM;
-
-	sprintf(dev->name, "tr%d", unit);
-	netdev_boot_setup_check(dev);
-	if (
-	    0 ) 
-		err = register_netdev(dev);
-		
-	if (err)
-		free_netdev(dev);
-	return err;
-
-}
 
 static void __init trif_probe2(int unit)
 {
@@ -484,8 +464,7 @@
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		if (!trif_probe(num))
-			trif_probe2(num);
+		trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
 		if (!ethif_probe(num))
This applies against net-2.5-exp

diff -Nru a/drivers/net/Space.c b/drivers/net/Space.c
--- a/drivers/net/Space.c	Fri Oct 10 11:27:32 2003
+++ b/drivers/net/Space.c	Fri Oct 10 11:27:32 2003
@@ -414,6 +414,10 @@
 extern int proteon_probe(struct net_device *);
 extern int smctr_probe(struct net_device *);
 
+static struct devprobe2 tr_probes2[] __initdata = {
+	{NULL, 0},
+};
+
 static __init int trif_probe(int unit)
 {
 	struct net_device *dev;
@@ -446,6 +450,15 @@
 	return err;
 
 }
+
+static void __init trif_probe2(int unit)
+{
+	unsigned long base_addr = netdev_boot_base("tr", unit);
+
+	if (base_addr == 1)
+		return;
+	probe_list2(unit, tr_probes2, base_addr == 0);
+}
 #endif
 
 	
@@ -471,7 +484,8 @@
 #endif
 #ifdef CONFIG_TR
 	for (num = 0; num < 8; ++num)
-		trif_probe(num);
+		if (!trif_probe(num))
+			trif_probe2(num);
 #endif
 	for (num = 0; num < 8; ++num)
 		if (!ethif_probe(num))
