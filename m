From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH v2 1/5] net: ethernet: mediatek: add REVMII and fix RMII mode supported by GMAC
Date: Tue, 16 Aug 2016 01:51:22 +0800
Message-ID: <1471283487-24113-2-git-send-email-sean.wang@mediatek.com>
References: <1471283487-24113-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:60284 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753106AbcHORvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 13:51:37 -0400
In-Reply-To: <1471283487-24113-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds the supplement for the setup of reverse MII (REVMII)
on GMAC, fixes up the incorrect setup of reduced MII (RMII) on GMAC
and rearranges the error handling for invalid phy argument.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 88b04dd..f19b8b9 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -245,12 +245,16 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	case PHY_INTERFACE_MODE_MII:
 		ge_mode = 1;
 		break;
-	case PHY_INTERFACE_MODE_RMII:
+	case PHY_INTERFACE_MODE_REVMII:
 		ge_mode = 2;
 		break;
+	case PHY_INTERFACE_MODE_RMII:
+		if (!mac->id)
+			goto err_phy;
+		ge_mode = 3;
+		break;
 	default:
-		dev_err(eth->dev, "invalid phy_mode\n");
-		return -1;
+		goto err_phy;
 	}
 
 	/* put the gmac into the right mode */
@@ -272,6 +276,11 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	of_node_put(np);
 
 	return 0;
+
+err_phy:
+	of_node_put(np);
+	dev_err(eth->dev, "invalid phy_mode\n");
+	return -EINVAL;
 }
 
 static int mtk_mdio_init(struct mtk_eth *eth)
-- 
1.7.9.5
