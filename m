From: Sean Wang <sean.wang@mediatek.com>
Subject: [PATCH net v3 2/3] net: ethernet: mediatek: fix flow control settings on GMAC0 is not being enabled properly
Date: Tue, 16 Aug 2016 13:55:14 +0800
Message-ID: <1471326915-15162-3-git-send-email-sean.wang@mediatek.com>
References: <1471326915-15162-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
	Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:52818 "EHLO
	mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751006AbcHPFzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 01:55:25 -0400
In-Reply-To: <1471326915-15162-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 08ef55c6f257acf3bdc6940813f80e8f0f5d90ec
("net-next: mediatek: fix gigabit and flow control advertisement")
had supported proper flow control settings for GMAC1. But for GMAC0,

1.GMAC0 shares the common logic with GMAC1 inside mtk_phy_link_adjust()
to adapt various settings for the target phy.

2.GMAC0 uses fixed-phy to connect to a builtin gigabit switch with
fixed link speed as commit 0c72c50f6f93b0c3daa9ea35d89ab3a933c7b5a0
("net-next: mediatek: add fixed-phy support") describes.

3.However, fixed-phy doesn't enable SUPPORTED_Pause & SUPPORTED_Asym_Pause
supported flag on default that would cause mtk_phy_link_adjust() not to
enable flow control setting on GMAC0 properly and cause packet dropped
when high traffic.

Due to these reasons, the patch adds SUPPORTED_Pause & SUPPORTED_Asym_Pause
supported flags on fixed-phy used by the driver to have proper handling on
the both GMAC with the shared common logic.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index f19b8b9..eb59a73 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -267,6 +267,11 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	mac->phy_dev->autoneg = AUTONEG_ENABLE;
 	mac->phy_dev->speed = 0;
 	mac->phy_dev->duplex = 0;
+
+	if (of_phy_is_fixed_link(mac->of_node))
+		mac->phy_dev->supported |=
+		SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
 	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
 				   SUPPORTED_Asym_Pause;
 	mac->phy_dev->advertising = mac->phy_dev->supported |
-- 
1.7.9.5
