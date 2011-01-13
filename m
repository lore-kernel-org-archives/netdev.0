From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 03/10] GRETH: added no_gbit option
Date: Thu, 13 Jan 2011 09:25:28 +0100
Message-ID: <1294907135-24884-3-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932796Ab1AMJAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:12 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For debug only. The driver does not report that it is GBit capable, instead
it will report 10/100 mode to the generic PHY layer.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |   15 +++++++++++++--
 drivers/net/greth.h |    1 +
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 1b10186..ef8da22 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -66,6 +66,10 @@ static int greth_edcl = 1;
 module_param(greth_edcl, int, 0);
 MODULE_PARM_DESC(greth_edcl, "GRETH EDCL usage indicator. Set to 1 if EDCL is used.");
 
+static int no_gbit = 0;
+module_param(no_gbit, int, S_IRUGO);
+MODULE_PARM_DESC(no_gbit, "GRETH reports only 10/100 support to PHY layer if set to 1. Only affects GRETH GBit MAC, default 0 (off).");
+
 static int greth_open(struct net_device *dev);
 static netdev_tx_t greth_start_xmit(struct sk_buff *skb,
 	   struct net_device *dev);
@@ -1284,7 +1288,7 @@ static int greth_mdio_probe(struct net_device *dev)
 	}
 
 	ret = phy_connect_direct(dev, phy, &greth_link_change,
-			0, greth->gbit_mac ?
+			0, greth->gbit_phy_support ?
 			PHY_INTERFACE_MODE_GMII :
 			PHY_INTERFACE_MODE_MII);
 	if (ret) {
@@ -1293,7 +1297,7 @@ static int greth_mdio_probe(struct net_device *dev)
 		return ret;
 	}
 
-	if (greth->gbit_mac)
+	if (greth->gbit_phy_support)
 		phy->supported &= PHY_GBIT_FEATURES;
 	else
 		phy->supported &= PHY_BASIC_FEATURES;
@@ -1447,6 +1451,13 @@ static int __devinit greth_of_probe(struct platform_device *ofdev, const struct
 	tmp = GRETH_REGLOAD(regs->control);
 	greth->gbit_mac = (tmp >> 27) & 1;
 
+	/* Let user skip GBit link mode by telling MDIO layer that MAC does
+	 * not support GBIT (for debug) */
+	if (greth->gbit_mac && !no_gbit)
+		greth->gbit_phy_support = 1;
+	else
+		greth->gbit_phy_support = 0;
+
 	/* Check for multicast capability */
 	greth->multicast = (tmp >> 25) & 1;
 
diff --git a/drivers/net/greth.h b/drivers/net/greth.h
index 03ad903..9414169 100644
--- a/drivers/net/greth.h
+++ b/drivers/net/greth.h
@@ -138,6 +138,7 @@ struct greth_private {
 	u8 gbit_mac;
 	u8 mdio_int_en;
 	u8 edcl;
+	u8 gbit_phy_support;
 };
 
 #endif
-- 
1.5.4

