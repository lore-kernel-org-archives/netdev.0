From: akpm@osdl.org
Subject: [patch 07/13] M68k HP Lance Ethernet: Fix leaks on probe/removal
Date: Sun, 21 Nov 2004 22:43:54 -0800
Message-ID: <200411220644.iAM6i6900649@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, geert@linux-m68k.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Geert Uytterhoeven <geert@linux-m68k.org>

HP Lance Ethernet: There's tons of leaks in the hplcance probing code, and it
doesn't release the memory region on removal either (from Christoph Hellwig)

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/hplance.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff -puN drivers/net/hplance.c~m68k-hp-lance-ethernet-fix-leaks-on-probe-removal drivers/net/hplance.c
--- 25/drivers/net/hplance.c~m68k-hp-lance-ethernet-fix-leaks-on-probe-removal	2004-11-21 22:42:53.205593760 -0800
+++ 25-akpm/drivers/net/hplance.c	2004-11-21 22:42:53.208593304 -0800
@@ -76,25 +76,31 @@ static int __devinit hplance_init_one(st
 				const struct dio_device_id *ent)
 {
 	struct net_device *dev;
-	int err;
+	int err = -ENOMEM;
 
 	dev = alloc_etherdev(sizeof(struct hplance_private));
 	if (!dev)
-		return -ENOMEM;
+		goto out;
 
-	if (!request_mem_region(d->resource.start, d->resource.end-d->resource.start, d->name))
-		return -EBUSY;
+	err = -EBUSY;
+	if (!request_mem_region(dio_resource_start(d),
+				dio_resource_len(d), d->name))
+		goto out_free_netdev;
 
-	SET_MODULE_OWNER(dev);
-        
 	hplance_init(dev, d);
 	err = register_netdev(dev);
-	if (err) {
-		free_netdev(dev);
-		return err;
-	}
+	if (err)
+		goto out_release_mem_region;
+
 	dio_set_drvdata(d, dev);
 	return 0;
+
+ out_release_mem_region:
+	release_mem_region(dio_resource_start(d), dio_resource_len(d));
+ out_free_netdev:
+	free_netdev(dev);
+ out:
+	return err;
 }
 
 static void __devexit hplance_remove_one(struct dio_dev *d)
@@ -102,6 +108,7 @@ static void __devexit hplance_remove_one
 	struct net_device *dev = dio_get_drvdata(d);
 
 	unregister_netdev(dev);
+	release_mem_region(dio_resource_start(d), dio_resource_len(d));
 	free_netdev(dev);
 }
 
_
