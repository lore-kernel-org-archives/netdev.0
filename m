From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH 4/5] Tsi108_eth: fix link recovery after disconnect
Date: Fri, 8 Feb 2008 14:17:41 -0500
Message-ID: <1B5F013528140F45B5C671039279CA5702A960A4@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linuxppc-dev@ozlabs.org>,
	"Josh Boyer" <jwboyer@linux.vnet.ibm.com>,
	"Zang Roy-r61911" <tie-fei.zang@freescale.com>
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tundra.com ([142.46.200.162]:48723 "EHLO mx2.tundra.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763211AbYBHT3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 14:29:48 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix for tsi108_eth network driver.
This patch fixes a problem with link recovery after connection was lost.
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-02-06
16:16:00.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
16:57:41.000000000 -0500
@@ -338,22 +338,21 @@ static void tsi108_check_phy(struct net_
 
 			TSI_WRITE(TSI108_MAC_CFG2, mac_cfg2_reg);
 			TSI_WRITE(TSI108_EC_PORTCTRL, portctrl_reg);
+		}
 
-			if (data->link_up == 0) {
-				/* The manual says it can take 3-4 usecs
for the speed change
-				 * to take effect.
-				 */
-				udelay(5);
-
-				spin_lock(&data->txlock);
-				if (is_valid_ether_addr(dev->dev_addr)
&& data->txfree)
-					netif_wake_queue(dev);
+		if (data->link_up == 0) {
+			/* The manual says it can take 3-4 usecs for the
speed change
+			 * to take effect.
+			 */
+			udelay(5);
 
-				data->link_up = 1;
-				spin_unlock(&data->txlock);
-			}
-		}
+			spin_lock(&data->txlock);
+			if (is_valid_ether_addr(dev->dev_addr) &&
data->txfree)
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



---



Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 


