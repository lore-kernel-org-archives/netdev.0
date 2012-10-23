From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 5/6] sunhme: remove mac address handling as a module parameter
Date: Tue, 23 Oct 2012 19:15:32 +0200
Message-ID: <1351012533-3524-6-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:61441 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:17:07 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so3294189wgb.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:17:05 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 drivers/net/ethernet/sun/sunhme.c |   69 +++++++++----------------------------
 1 file changed, 16 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index cf14ab9..b5e70d5 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -9,8 +9,6 @@
  * 2000/11/11 Willy Tarreau <willy AT meta-x.org>
  *   - port to non-sparc architectures. Tested only on x86 and
  *     only currently works with QFE PCI cards.
- *   - ability to specify the MAC address at module load time by passing this
- *     argument : macaddr=0x00,0x10,0x20,0x30,0x40,0x50
  */
 
 #include <linux/module.h>
@@ -74,12 +72,6 @@ MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION("Sun HappyMealEthernet(HME) 10/100baseT ethernet driver");
 MODULE_LICENSE("GPL");
 
-static int macaddr[6];
-
-/* accept MAC address of the form macaddr=0x08,0x00,0x20,0x30,0x40,0x50 */
-module_param_array(macaddr, int, NULL, 0);
-MODULE_PARM_DESC(macaddr, "Happy Meal MAC address to set");
-
 #ifdef CONFIG_SBUS
 static struct quattro *qfe_sbus_list;
 #endif
@@ -2631,8 +2623,9 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	struct quattro *qp = NULL;
 	struct happy_meal *hp;
 	struct net_device *dev;
-	int i, qfe_slot = -1;
+	int i, len, qfe_slot = -1;
 	int err = -ENODEV;
+	const unsigned char *addr;
 
 	sbus_dp = op->dev.parent->of_node;
 
@@ -2660,28 +2653,12 @@ static int __devinit happy_meal_sbus_probe_one(struct platform_device *op, int i
 	if (hme_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
 
-	/* If user did not specify a MAC address specifically, use
-	 * the Quattro local-mac-address property...
-	 */
-	for (i = 0; i < 6; i++) {
-		if (macaddr[i] != 0)
-			break;
-	}
-	if (i < 6) { /* a mac address was given */
-		for (i = 0; i < 6; i++)
-			dev->dev_addr[i] = macaddr[i];
-		macaddr[5]++;
-	} else {
-		const unsigned char *addr;
-		int len;
-
-		addr = of_get_property(dp, "local-mac-address", &len);
 
-		if (qfe_slot != -1 && addr && len == 6)
-			memcpy(dev->dev_addr, addr, 6);
-		else
-			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
-	}
+	addr = of_get_property(dp, "local-mac-address", &len);
+	if (qfe_slot != -1 && addr && len == 6)
+		memcpy(dev->dev_addr, addr, 6);
+	else
+		memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
 
 	hp = netdev_priv(dev);
 
@@ -2945,9 +2922,10 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	struct net_device *dev;
 	void __iomem *hpreg_base;
 	unsigned long hpreg_res;
-	int i, qfe_slot = -1;
+	int i, len, qfe_slot = -1;
 	char prom_name[64];
 	int err;
+	const unsigned char *addr;
 
 	/* Now make sure pci_dev cookie is there. */
 #ifdef CONFIG_SPARC
@@ -3018,31 +2996,16 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 		goto err_out_free_res;
 	}
 
-	for (i = 0; i < 6; i++) {
-		if (macaddr[i] != 0)
-			break;
-	}
-	if (i < 6) { /* a mac address was given */
-		for (i = 0; i < 6; i++)
-			dev->dev_addr[i] = macaddr[i];
-		macaddr[5]++;
-	} else {
 #ifdef CONFIG_SPARC
-		const unsigned char *addr;
-		int len;
-
-		if (qfe_slot != -1 &&
-		    (addr = of_get_property(dp, "local-mac-address", &len))
-			!= NULL &&
-		    len == 6) {
-			memcpy(dev->dev_addr, addr, 6);
-		} else {
-			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
-		}
+	if (qfe_slot != -1 &&
+	    (addr = of_get_property(dp, "local-mac-address", &len)) != NULL &&
+	    len == 6)
+		memcpy(dev->dev_addr, addr, 6);
+	else
+		memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
 #else
-		get_hme_mac_nonsparc(pdev, &dev->dev_addr[0]);
+	get_hme_mac_nonsparc(pdev, &dev->dev_addr[0]);
 #endif
-	}
 
 	/* Layout registers. */
 	hp->gregs      = (hpreg_base + 0x0000UL);
-- 
1.7.9.5
