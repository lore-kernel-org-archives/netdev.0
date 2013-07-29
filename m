From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 2/6] tg3: Allow NVRAM programming when
 interface is down
Date: Mon, 29 Jul 2013 13:58:36 -0700
Message-ID: <1375131520-1746-3-git-send-email-nsujir@broadcom.com>
References: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2532 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab3G2U6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:52 -0400
In-Reply-To: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, when the interface was brought down, the driver would set
the power state to D3hot. In D3hot, we don't have access to the NVRAM.
This patch removes the call to set the power state to PCI_D3hot in
close. A following patch will implement the shutdown handler to properly
set the D3hot state when the system is going down.

Doing the above means that the TG3_PHYFLG_IS_LOW_POWER should not be
checked to validate access to the NVRAM.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 2e4bf5f..ec244c9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11502,7 +11502,7 @@ static int tg3_close(struct net_device *dev)
 	memset(&tp->net_stats_prev, 0, sizeof(tp->net_stats_prev));
 	memset(&tp->estats_prev, 0, sizeof(tp->estats_prev));
 
-	tg3_power_down(tp);
+	tg3_power_down_prepare(tp);
 
 	tg3_carrier_off(tp);
 
@@ -11724,9 +11724,6 @@ static int tg3_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	if (tg3_flag(tp, NO_NVRAM))
 		return -EINVAL;
 
-	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		return -EAGAIN;
-
 	offset = eeprom->offset;
 	len = eeprom->len;
 	eeprom->len = 0;
@@ -11784,9 +11781,6 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	u8 *buf;
 	__be32 start, end;
 
-	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		return -EAGAIN;
-
 	if (tg3_flag(tp, NO_NVRAM) ||
 	    eeprom->magic != TG3_EEPROM_MAGIC)
 		return -EINVAL;
@@ -13515,7 +13509,7 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 			tg3_phy_start(tp);
 	}
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
-		tg3_power_down(tp);
+		tg3_power_down_prepare(tp);
 
 }
 
-- 
1.8.1.4
