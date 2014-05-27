From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 4/9] tlan: Fix MAC address byte order on OC-2325/OC-2326
Date: Tue, 27 May 2014 23:38:42 +0200
Message-ID: <1401226727-5508-5-git-send-email-linux@rainbow-software.org>
References: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401226727-5508-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olicom OC-2325 and OC-2326 cards have the MAC address byte-swapped in EEPROM.
Byte-swap the MAC address if it's located at offset 0xF8.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index ae9fece..31d4a96 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -864,7 +864,7 @@ static int tlan_init(struct net_device *dev)
 		priv->rx_list_dma + sizeof(struct tlan_list)*TLAN_NUM_RX_LISTS;
 
 	err = 0;
-	for (i = 0;  i < 6 ; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		err |= tlan_ee_read_byte(dev,
 					 (u8) priv->adapter->addr_ofs + i,
 					 (u8 *) &dev->dev_addr[i]);
@@ -872,7 +872,14 @@ static int tlan_init(struct net_device *dev)
 		pr_err("%s: Error reading MAC from eeprom: %d\n",
 		       dev->name, err);
 	}
-	dev->addr_len = 6;
+	/* Olicom OC-2325/OC-2326 have the address byte-swapped */
+	if (priv->adapter->addr_ofs == 0xf8) {
+		for (i = 0; i < ETH_ALEN; i += 2) {
+			char tmp = dev->dev_addr[i];
+			dev->dev_addr[i] = dev->dev_addr[i + 1];
+			dev->dev_addr[i + 1] = tmp;
+		}
+	}
 
 	netif_carrier_off(dev);
 
-- 
Ondrej Zary
