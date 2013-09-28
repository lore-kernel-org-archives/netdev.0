From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 3/3] tg3: use phylib when robo switch is in use
Date: Sat, 28 Sep 2013 23:15:28 +0200
Message-ID: <1380402928-11480-3-git-send-email-hauke@hauke-m.de>
References: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Cc: nsujir@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:45260 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755175Ab3I1VPp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 17:15:45 -0400
In-Reply-To: <1380402928-11480-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a switch is connected as a PHY to the MAC driven by tg3, use
phylib and provide the phy address to tg3 from the sprom.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/tg3.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 853a05e..a17a3c9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1513,6 +1513,13 @@ static int tg3_mdio_init(struct tg3 *tp)
 				    TG3_CPMU_PHY_STRAP_IS_SERDES;
 		if (is_serdes)
 			tp->phy_addr += 7;
+	} else if (tg3_flag(tp, IS_SSB_CORE) && tg3_flag(tp, ROBOSWITCH)) {
+		int addr;
+
+		addr = ssb_gige_get_phyaddr(tp->pdev);
+		if (addr < 0)
+			return addr;
+		tp->phy_addr = addr;
 	} else
 		tp->phy_addr = TG3_PHY_MII_ADDR;
 
@@ -17366,8 +17373,10 @@ static int tg3_init_one(struct pci_dev *pdev,
 			tg3_flag_set(tp, FLUSH_POSTED_WRITES);
 		if (ssb_gige_one_dma_at_once(pdev))
 			tg3_flag_set(tp, ONE_DMA_AT_ONCE);
-		if (ssb_gige_have_roboswitch(pdev))
+		if (ssb_gige_have_roboswitch(pdev)) {
+			tg3_flag_set(tp, USE_PHYLIB);
 			tg3_flag_set(tp, ROBOSWITCH);
+		}
 		if (ssb_gige_is_rgmii(pdev))
 			tg3_flag_set(tp, RGMII_MODE);
 	}
-- 
1.7.10.4
