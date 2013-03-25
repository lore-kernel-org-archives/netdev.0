From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] dsa: factor freeing of dsa_platform_data
Date: Mon, 25 Mar 2013 16:03:39 +0100
Message-ID: <1364223820-26051-3-git-send-email-florian@openwrt.org>
References: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43629 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab3CYPD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 11:03:56 -0400
In-Reply-To: <1364223820-26051-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch factors the freeing of the struct dsa_platform_data
manipulated by the driver identically in two places to a single
function.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 net/dsa/dsa.c |   38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 908bc11..aa2ff58 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -343,6 +343,21 @@ out:
 	return ret;
 }
 
+static void dsa_of_free_platform_data(struct dsa_platform_data *pd)
+{
+	int i;
+	int port_index;
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		port_index = 0;
+		while (pd->chip[i].port_names &&
+			pd->chip[i].port_names[++port_index])
+			kfree(pd->chip[i].port_names[port_index]);
+		kfree(pd->chip[i].rtable);
+	}
+	kfree(pd->chip);
+}
+
 static int dsa_of_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -354,7 +369,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 	const char *port_name;
 	int chip_index, port_index;
 	const unsigned int *sw_addr, *port_reg;
-	int ret, i;
+	int ret;
 
 	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
 	if (!mdio)
@@ -439,14 +454,7 @@ static int dsa_of_probe(struct platform_device *pdev)
 	return 0;
 
 out_free_chip:
-	for (i = 0; i < pd->nr_chips; i++) {
-		port_index = 0;
-		while (pd->chip[i].port_names &&
-			pd->chip[i].port_names[++port_index])
-			kfree(pd->chip[i].port_names[port_index]);
-		kfree(pd->chip[i].rtable);
-	}
-	kfree(pd->chip);
+	dsa_of_free_platform_data(pd);
 out_free:
 	kfree(pd);
 	pdev->dev.platform_data = NULL;
@@ -456,21 +464,11 @@ out_free:
 static void dsa_of_remove(struct platform_device *pdev)
 {
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
-	int i;
-	int port_index;
 
 	if (!pdev->dev.of_node)
 		return;
 
-	for (i = 0; i < pd->nr_chips; i++) {
-		port_index = 0;
-		while (pd->chip[i].port_names &&
-			pd->chip[i].port_names[++port_index])
-			kfree(pd->chip[i].port_names[port_index]);
-		kfree(pd->chip[i].rtable);
-	}
-
-	kfree(pd->chip);
+	dsa_of_free_platform_data(pd);
 	kfree(pd);
 }
 #else
-- 
1.7.10.4
