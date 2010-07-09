From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH] depca: fix leaks
Date: Fri,  9 Jul 2010 16:36:25 +0400
Message-ID: <1278678986-7725-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:39380 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755966Ab0GIMgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 08:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since some of xxx_register_driver() can return error we must continue
with already registered drivers. If any of xxx_register_driver()
succeeded or depca_platform_probe() found any device then
depca_module_init() returns ok. In depca_module_exit() we must
unregister only registered drivers.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/depca.c |   93 ++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 70 insertions(+), 23 deletions(-)

diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index bf66e9b..4f43e12 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -551,6 +551,15 @@ static int io;
 static char *adapter_name;
 static int mem;			/* For loadable module assignment
 				   use insmod mem=0x????? .... */
+
+#ifdef CONFIG_MCA
+static int is_mca_registered;
+#endif
+#ifdef CONFIG_EISA
+static int is_eisa_registered;
+#endif
+static int is_platform_registered;
+
 module_param (irq, int, 0);
 module_param (io, int, 0);
 module_param (adapter_name, charp, 0);
@@ -1457,9 +1466,9 @@ static int __init depca_mca_probe(struct device *device)
 ** ISA bus I/O device probe
 */
 
-static void __init depca_platform_probe (void)
+static int __init depca_platform_probe(void)
 {
-	int i;
+	int i, n = 0;
 	struct platform_device *pldev;
 
 	for (i = 0; depca_io_ports[i].iobase; i++) {
@@ -1493,8 +1502,10 @@ static void __init depca_platform_probe (void)
 			depca_io_ports[i].device = NULL;
 			pldev->dev.platform_data = NULL;
 			platform_device_unregister (pldev);
-		}
+		} else
+			n++;
 	}
+	return n;
 }
 
 static enum depca_type __init depca_shmem_probe (ulong *mem_start)
@@ -2059,32 +2070,19 @@ static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return status;
 }
 
-static int __init depca_module_init (void)
-{
-        int err = 0;
-
-#ifdef CONFIG_MCA
-        err = mca_register_driver (&depca_mca_driver);
-#endif
-#ifdef CONFIG_EISA
-        err |= eisa_driver_register (&depca_eisa_driver);
-#endif
-	err |= platform_driver_register (&depca_isa_driver);
-	depca_platform_probe ();
-
-        return err;
-}
-
-static void __exit depca_module_exit (void)
+static void depca_unregister(void)
 {
 	int i;
 #ifdef CONFIG_MCA
-        mca_unregister_driver (&depca_mca_driver);
+	if (is_mca_registered)
+		mca_unregister_driver(&depca_mca_driver);
 #endif
 #ifdef CONFIG_EISA
-        eisa_driver_unregister (&depca_eisa_driver);
+	if (is_eisa_registered)
+		eisa_driver_unregister(&depca_eisa_driver);
 #endif
-	platform_driver_unregister (&depca_isa_driver);
+	if (is_platform_registered)
+		platform_driver_unregister(&depca_isa_driver);
 
 	for (i = 0; depca_io_ports[i].iobase; i++) {
 		if (depca_io_ports[i].device) {
@@ -2095,5 +2093,54 @@ static void __exit depca_module_exit (void)
 	}
 }
 
+static int __init depca_module_init(void)
+{
+	int any = 0;
+	int platform_err = 0, err = 0;
+
+#ifdef CONFIG_MCA
+	{
+		int mca_err = 0;
+		mca_err = mca_register_driver(&depca_mca_driver);
+		if (!mca_err) {
+			any = 1;
+			is_mca_registered = 1;
+		} else
+			err = mca_err;
+	}
+#endif
+#ifdef CONFIG_EISA
+	{
+		int eisa_err = 0;
+		eisa_err = eisa_driver_register(&depca_eisa_driver);
+		if (!eisa_err) {
+			any = 1;
+			is_eisa_registered = 1;
+		} else
+			err = eisa_err;
+	}
+#endif
+	platform_err = platform_driver_register(&depca_isa_driver);
+	if (!platform_err) {
+		any = 1;
+		is_platform_registered = 1;
+	} else
+		err = platform_err;
+
+	if (depca_platform_probe())
+		any = 1;
+
+	if (any)
+		err = 0;
+	else if (err)
+		depca_unregister();
+	return err;
+}
+
+static void __exit depca_module_exit(void)
+{
+	depca_unregister();
+}
+
 module_init (depca_module_init);
 module_exit (depca_module_exit);
-- 
1.7.0.4

