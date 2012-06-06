From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sky2: fix checksum bit management on some chips
Date: Wed, 6 Jun 2012 13:01:30 -0700
Message-ID: <20120606130130.5a86f94a@nehalam.linuxnetplumber.net>
References: <20120606172036.GA11911@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <mlindner@marvell.com>, netdev@vger.kernel.org
To: Kirill Smelkov <kirr@mns.spb.ru>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33457 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753228Ab2FFUBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 16:01:38 -0400
In-Reply-To: <20120606172036.GA11911@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newer flavors of Yukon II use a different method for receive
checksum offload. This is indicated in the driver by the SKY2_HW_NEW_LE
flag. On these newer chips, the BMU_ENA_RX_CHKSUM should not be set.

The driver would get incorrectly toggle the bit, enabling the old
checksum logic on these chips and cause a BUG_ON() assertion. If
receive checksum was toggled via ethtool.

Reported-by: Kirill Smelkov <kirr@mns.spb.ru>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next, please apply to net and stable kernels.

--- a/drivers/net/ethernet/marvell/sky2.c	2012-06-06 11:09:38.288440819 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-06-06 11:25:01.275782462 -0700
@@ -4381,10 +4381,12 @@ static int sky2_set_features(struct net_
 	struct sky2_port *sky2 = netdev_priv(dev);
 	netdev_features_t changed = dev->features ^ features;
 
-	if (changed & NETIF_F_RXCSUM) {
-		bool on = features & NETIF_F_RXCSUM;
-		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
-			     on ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
+	if ((changed & NETIF_F_RXCSUM) &&
+	    !(sky2->hw->flags & SKY2_HW_NEW_LE)) {
+		sky2_write32(sky2->hw,
+			     Q_ADDR(rxqaddr[sky2->port], Q_CSR),
+			     (features & NETIF_F_RXCSUM)
+			     ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 	}
 
 	if (changed & NETIF_F_RXHASH)
