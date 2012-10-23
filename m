From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 4/6] greth: remove mac address handling as a module parameter
Date: Tue, 23 Oct 2012 19:15:31 +0200
Message-ID: <1351012533-3524-5-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:41114 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:16:49 -0400
Received: by mail-wi0-f170.google.com with SMTP id hm2so3465776wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:16:48 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 drivers/net/ethernet/aeroflex/greth.c |   36 +++++++++++----------------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 442fefa..c6c85d6 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -59,11 +59,6 @@ static int greth_debug = -1;	/* -1 == use GRETH_DEF_MSG_ENABLE as value */
 module_param(greth_debug, int, 0);
 MODULE_PARM_DESC(greth_debug, "GRETH bitmapped debugging message enable value");
 
-/* Accept MAC address of the form macaddr=0x08,0x00,0x20,0x30,0x40,0x50 */
-static int macaddr[6];
-module_param_array(macaddr, int, NULL, 0);
-MODULE_PARM_DESC(macaddr, "GRETH Ethernet MAC address");
-
 static int greth_edcl = 1;
 module_param(greth_edcl, int, 0);
 MODULE_PARM_DESC(greth_edcl, "GRETH EDCL usage indicator. Set to 1 if EDCL is used.");
@@ -1385,8 +1380,11 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 
 	int i;
 	int err;
+	int len;
 	int tmp;
 	unsigned long timeout;
+	const unsigned char *addr;
+	int macaddr[6]; /* XXX an initial mac? e.g. 00:11:22:33:44:55? */
 
 	dev = alloc_etherdev(sizeof(struct greth_private));
 
@@ -1495,32 +1493,22 @@ static int __devinit greth_of_probe(struct platform_device *ofdev)
 
 	memset(greth->rx_bd_base, 0, 1024);
 
-	/* Get MAC address from: module param, OF property or ID prom */
-	for (i = 0; i < 6; i++) {
-		if (macaddr[i] != 0)
-			break;
-	}
-	if (i == 6) {
-		const unsigned char *addr;
-		int len;
-		addr = of_get_property(ofdev->dev.of_node, "local-mac-address",
-					&len);
-		if (addr != NULL && len == 6) {
-			for (i = 0; i < 6; i++)
-				macaddr[i] = (unsigned int) addr[i];
-		} else {
+	/* Get MAC address from: OF property or ID prom */
+	addr = of_get_property(ofdev->dev.of_node, "local-mac-address",
+				&len);
+	if (addr != NULL && len == 6) {
+		for (i = 0; i < 6; i++)
+			macaddr[i] = (unsigned int) addr[i];
+	} else {
 #ifdef CONFIG_SPARC
-			for (i = 0; i < 6; i++)
-				macaddr[i] = (unsigned int) idprom->id_ethaddr[i];
+		for (i = 0; i < 6; i++)
+			macaddr[i] = (unsigned int) idprom->id_ethaddr[i];
 #endif
-		}
 	}
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = macaddr[i];
 
-	macaddr[5]++;
-
 	if (!is_valid_ether_addr(&dev->dev_addr[0])) {
 		if (netif_msg_probe(greth))
 			dev_err(greth->dev, "no valid ethernet address, aborting.\n");
-- 
1.7.9.5
