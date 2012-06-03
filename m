From: Raffaele Recalcati <lamiaposta71@gmail.com>
Subject: [PATCH] net/ethernet: ks8851_mll mac address configuration support added
Date: Sun,  3 Jun 2012 22:43:43 +0200
Message-ID: <1338756223-7207-1-git-send-email-lamiaposta71@gmail.com>
Cc: Raffaele Recalcati <raffaele.recalcati@bticino.it>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54091 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab2FCUoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2012 16:44:46 -0400
Received: by wibhj8 with SMTP id hj8so2238377wib.1
        for <netdev@vger.kernel.org>; Sun, 03 Jun 2012 13:44:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raffaele Recalcati <raffaele.recalcati@bticino.it>

Signed-off-by: Raffaele Recalcati <raffaele.recalcati@bticino.it>
---
 drivers/net/ethernet/micrel/ks8851_mll.c |   25 +++++++++++++++-------
 include/linux/ks8851_mll.h               |   33 ++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/ks8851_mll.h

diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 2784bc7..b9893b5 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -35,7 +35,7 @@
 #include <linux/platform_device.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
-#include <asm/io.h>
+#include <linux/ks8851_mll.h>
 
 #define	DRV_NAME	"ks8851_mll"
 
@@ -1516,6 +1516,7 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 	struct net_device *netdev;
 	struct ks_net *ks;
 	u16 id, data;
+	struct ks8851_mll_platform_data *pdata;
 
 	io_d = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	io_c = platform_get_resource(pdev, IORESOURCE_MEM, 1);
@@ -1597,17 +1598,27 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 	ks_disable_qmu(ks);
 	ks_setup(ks);
 	ks_setup_int(ks);
-	memcpy(netdev->dev_addr, ks->mac_addr, 6);
 
 	data = ks_rdreg16(ks, KS_OBCR);
 	ks_wrreg16(ks, KS_OBCR, data | OBCR_ODS_16MA);
 
-	/**
-	 * If you want to use the default MAC addr,
-	 * comment out the 2 functions below.
-	 */
+	/* overwriting the default MAC address */
+	pdata = pdev->dev.platform_data;
+	if (!pdata) {
+		netdev_err(netdev, "No platform data\n");
+		err = -ENODEV;
+		goto err_register;
+	}
+	memcpy(ks->mac_addr, pdata->mac_addr, 6);
+	if (!is_valid_ether_addr(ks->mac_addr)) {
+		/* Use random MAC address if none passed */
+		random_ether_addr(ks->mac_addr);
+		netdev_info(netdev, "Using random mac address\n");
+	}
+	netdev_info(netdev, "Mac address is: %pM\n", ks->mac_addr);
+
+	memcpy(netdev->dev_addr, ks->mac_addr, 6);
 
-	random_ether_addr(netdev->dev_addr);
 	ks_set_mac(ks, netdev->dev_addr);
 
 	id = ks_rdreg16(ks, KS_CIDER);
diff --git a/include/linux/ks8851_mll.h b/include/linux/ks8851_mll.h
new file mode 100644
index 0000000..e9ccfb5
--- /dev/null
+++ b/include/linux/ks8851_mll.h
@@ -0,0 +1,33 @@
+/*
+ * ks8861_mll platform data struct definition
+ * Copyright (c) 2012 BTicino S.p.A.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _LINUX_KS8851_MLL_H
+#define _LINUX_KS8851_MLL_H
+
+#include <linux/if_ether.h>
+
+/**
+ * struct ks8851_mll_platform_data - Platform data of the KS8851_MLL network driver
+ * @macaddr:	The MAC address of the device, set to all 0:s to use the on in
+ *		the chip.
+ */
+struct ks8851_mll_platform_data {
+	u8 mac_addr[ETH_ALEN];
+};
+
+#endif
-- 
1.7.9.5
