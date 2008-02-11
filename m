From: "Alex Bounine" <alex.bou9@gmail.com>
Subject: [PATCH 4/5 v3] Tsi108_eth: fix link recovery after disconnect
Date: Mon, 11 Feb 2008 14:36:12 -0500
Message-ID: <d5f62df20802111136p3ba13f8cudae073a178b77aa9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, tie-fei.zang@freescale.com,
	jwboyer@linux.vnet.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:44806 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756740AbYBKTgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:36:14 -0500
Received: by rv-out-0910.google.com with SMTP id k20so3459745rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:36:12 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix for tsi108_eth network driver.
This patch fixes a problem with link recovery after connection was lost.

Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06 16:16:00.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
16:57:41.000000000 -0500
@@ -338,22 +338,21 @@ static void tsi108_check_phy(struct net_

 			TSI_WRITE(TSI108_MAC_CFG2, mac_cfg2_reg);
 			TSI_WRITE(TSI108_EC_PORTCTRL, portctrl_reg);
+		}

-			if (data->link_up == 0) {
-				/* The manual says it can take 3-4 usecs for the speed change
-				 * to take effect.
-				 */
-				udelay(5);
-
-				spin_lock(&data->txlock);
-				if (is_valid_ether_addr(dev->dev_addr) && data->txfree)
-					netif_wake_queue(dev);
+		if (data->link_up == 0) {
+			/* The manual says it can take 3-4 usecs for the speed change
+			 * to take effect.
+			 */
+			udelay(5);

-				data->link_up = 1;
-				spin_unlock(&data->txlock);
-			}
-		}
+			spin_lock(&data->txlock);
+			if (is_valid_ether_addr(dev->dev_addr) && data->txfree)
+				netif_wake_queue(dev);

+			data->link_up = 1;
+			spin_unlock(&data->txlock);
+		}
 	} else {
 		if (data->link_up == 1) {
 			netif_stop_queue(dev);
@@ -1267,12 +1266,11 @@ static void tsi108_init_phy(struct net_d
 	 * PHY_STAT register before the link up status bit is set.
 	 */

-	data->link_up = 1;
+	data->link_up = 0;

 	while (!((phyval = tsi108_read_mii(data, MII_BMSR)) &
 		 BMSR_LSTATUS)) {
 		if (i++ > (MII_READ_DELAY / 10)) {
-			data->link_up = 0;
 			break;
 		}
 		spin_unlock_irqrestore(&phy_lock, flags);
