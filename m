From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] net/sb1250: setup the pdevice within the soc code
Date: Mon, 26 Apr 2010 23:07:44 +0200
Message-ID: <20100426210744.GA23721@Chamillionaire.breakpoint.cc>
References: <20100426195229.GB22245@Chamillionaire.breakpoint.cc>
 <20100426202459.GD27656@linux-mips.org>
 <20100426204122.GA23697@Chamillionaire.breakpoint.cc>
 <20100426210022.GE27656@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Ralf Baechle <ralf@linux-mips.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42955 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410Ab0DZVHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:07:46 -0400
Content-Disposition: inline
In-Reply-To: <20100426210022.GE27656@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

doing it within the driver does not look good.
And surely isn't how platform devices were meat to be used.

Acked-by: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
---
 arch/mips/sibyte/swarm/platform.c |   54 +++++++++++++++++
 drivers/net/sb1250-mac.c          |  120 +------------------------------------
 2 files changed, 55 insertions(+), 119 deletions(-)

diff --git a/arch/mips/sibyte/swarm/platform.c b/arch/mips/sibyte/swarm/platform.c
index 54847fe..0973352 100644
--- a/arch/mips/sibyte/swarm/platform.c
+++ b/arch/mips/sibyte/swarm/platform.c
@@ -83,3 +83,57 @@ static int __init swarm_pata_init(void)
 device_initcall(swarm_pata_init);
 
 #endif /* defined(CONFIG_SIBYTE_SWARM) || defined(CONFIG_SIBYTE_LITTLESUR) */
+
+#define sb1250_dev_struct(num) \
+	static struct resource sb1250_res##num = {		\
+		.name = "SB1250 MAC " __stringify(num),		\
+		.flags = IORESOURCE_MEM,		\
+		.start = A_MAC_CHANNEL_BASE(num),	\
+		.end = A_MAC_CHANNEL_BASE(num + 1) -1,	\
+	};\
+	static struct platform_device sb1250_dev##num = {	\
+		.name = "sb1250-mac",			\
+	.id = num,					\
+	.resource = &sb1250_res##num,			\
+	.num_resources = 1,				\
+	}
+
+sb1250_dev_struct(0);
+sb1250_dev_struct(1);
+sb1250_dev_struct(2);
+sb1250_dev_struct(3);
+
+static struct platform_device *sb1250_devs[] __initdata = {
+	&sb1250_dev0,
+	&sb1250_dev1,
+	&sb1250_dev2,
+	&sb1250_dev3,
+};
+
+static int __init sb1250_device_init(void)
+{
+	int ret;
+
+	/* Set the number of available units based on the SOC type.  */
+	switch (soc_type) {
+	case K_SYS_SOC_TYPE_BCM1250:
+	case K_SYS_SOC_TYPE_BCM1250_ALT:
+		ret = platform_add_devices(sb1250_devs, 3);
+		break;
+	case K_SYS_SOC_TYPE_BCM1120:
+	case K_SYS_SOC_TYPE_BCM1125:
+	case K_SYS_SOC_TYPE_BCM1125H:
+	case K_SYS_SOC_TYPE_BCM1250_ALT2:       /* Hybrid */
+		ret = platform_add_devices(sb1250_devs, 2);
+		break;
+	case K_SYS_SOC_TYPE_BCM1x55:
+	case K_SYS_SOC_TYPE_BCM1x80:
+		ret = platform_add_devices(sb1250_devs, 4);
+		break;
+	default:
+		ret = -ENODEV;
+		break;
+	}
+	return ret;
+}
+device_initcall(sb1250_device_init);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index fc503a1..459bc59 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -332,7 +332,6 @@ static int sbmac_mii_write(struct mii_bus *bus, int phyaddr, int regidx,
  ********************************************************************* */
 
 static char sbmac_string[] = "sb1250-mac";
-static char sbmac_pretty[] = "SB1250 MAC";
 
 static char sbmac_mdio_string[] = "sb1250-mac-mdio";
 
@@ -2668,114 +2667,6 @@ static int __exit sbmac_remove(struct platform_device *pldev)
 	return 0;
 }
 
-
-static struct platform_device **sbmac_pldev;
-static int sbmac_max_units;
-
-static int __init sbmac_platform_probe_one(int idx)
-{
-	struct platform_device *pldev;
-	struct {
-		struct resource r;
-		char name[strlen(sbmac_pretty) + 4];
-	} *res;
-	int err;
-
-	res = kzalloc(sizeof(*res), GFP_KERNEL);
-	if (!res) {
-		printk(KERN_ERR "%s.%d: unable to allocate memory\n",
-		       sbmac_string, idx);
-		err = -ENOMEM;
-		goto out_err;
-	}
-
-	/*
-	 * This is the base address of the MAC.
-	 */
-	snprintf(res->name, sizeof(res->name), "%s %d", sbmac_pretty, idx);
-	res->r.name = res->name;
-	res->r.flags = IORESOURCE_MEM;
-	res->r.start = A_MAC_CHANNEL_BASE(idx);
-	res->r.end = A_MAC_CHANNEL_BASE(idx + 1) - 1;
-
-	pldev = platform_device_register_simple(sbmac_string, idx, &res->r, 1);
-	if (IS_ERR(pldev)) {
-		printk(KERN_ERR "%s.%d: unable to register platform device\n",
-		       sbmac_string, idx);
-		err = PTR_ERR(pldev);
-		goto out_kfree;
-	}
-
-	if (!pldev->dev.driver) {
-		err = 0;		/* No hardware at this address. */
-		goto out_unregister;
-	}
-
-	sbmac_pldev[idx] = pldev;
-	return 0;
-
-out_unregister:
-	platform_device_unregister(pldev);
-
-out_kfree:
-	kfree(res);
-
-out_err:
-	return err;
-}
-
-static void __init sbmac_platform_probe(void)
-{
-	int i;
-
-	/* Set the number of available units based on the SOC type.  */
-	switch (soc_type) {
-	case K_SYS_SOC_TYPE_BCM1250:
-	case K_SYS_SOC_TYPE_BCM1250_ALT:
-		sbmac_max_units = 3;
-		break;
-	case K_SYS_SOC_TYPE_BCM1120:
-	case K_SYS_SOC_TYPE_BCM1125:
-	case K_SYS_SOC_TYPE_BCM1125H:
-	case K_SYS_SOC_TYPE_BCM1250_ALT2:	/* Hybrid */
-		sbmac_max_units = 2;
-		break;
-	case K_SYS_SOC_TYPE_BCM1x55:
-	case K_SYS_SOC_TYPE_BCM1x80:
-		sbmac_max_units = 4;
-		break;
-	default:
-		return;				/* none */
-	}
-
-	sbmac_pldev = kcalloc(sbmac_max_units, sizeof(*sbmac_pldev),
-			      GFP_KERNEL);
-	if (!sbmac_pldev) {
-		printk(KERN_ERR "%s: unable to allocate memory\n",
-		       sbmac_string);
-		return;
-	}
-
-	/*
-	 * Walk through the Ethernet controllers and find
-	 * those who have their MAC addresses set.
-	 */
-	for (i = 0; i < sbmac_max_units; i++)
-		if (sbmac_platform_probe_one(i))
-			break;
-}
-
-
-static void __exit sbmac_platform_cleanup(void)
-{
-	int i;
-
-	for (i = 0; i < sbmac_max_units; i++)
-		platform_device_unregister(sbmac_pldev[i]);
-	kfree(sbmac_pldev);
-}
-
-
 static struct platform_driver sbmac_driver = {
 	.probe = sbmac_probe,
 	.remove = __exit_p(sbmac_remove),
@@ -2786,20 +2677,11 @@ static struct platform_driver sbmac_driver = {
 
 static int __init sbmac_init_module(void)
 {
-	int err;
-
-	err = platform_driver_register(&sbmac_driver);
-	if (err)
-		return err;
-
-	sbmac_platform_probe();
-
-	return err;
+	return platform_driver_register(&sbmac_driver);
 }
 
 static void __exit sbmac_cleanup_module(void)
 {
-	sbmac_platform_cleanup();
 	platform_driver_unregister(&sbmac_driver);
 }
 
-- 
1.6.6.1
