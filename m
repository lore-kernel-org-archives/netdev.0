From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 1/5] tg3: Refactor __tg3_set_mac_addr()
Date: Fri, 3 Jan 2014 10:09:11 -0800
Message-ID: <1388772555-916-2-git-send-email-nsujir@broadcom.com>
References: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:9445 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbaACSJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 13:09:28 -0500
In-Reply-To: <1388772555-916-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>

so that individual MAC address filter entries can be set.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a8def93..80d55bf 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3948,32 +3948,41 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 	return 0;
 }
 
+/* tp->lock is held. */
+static void __tg3_set_one_mac_addr(struct tg3 *tp, u8 *mac_addr, int index)
+{
+	u32 addr_high, addr_low;
+
+	addr_high = ((mac_addr[0] << 8) | mac_addr[1]);
+	addr_low = ((mac_addr[2] << 24) | (mac_addr[3] << 16) |
+		    (mac_addr[4] <<  8) | mac_addr[5]);
+
+	if (index < 4) {
+		tw32(MAC_ADDR_0_HIGH + (index * 8), addr_high);
+		tw32(MAC_ADDR_0_LOW + (index * 8), addr_low);
+	} else {
+		index -= 4;
+		tw32(MAC_EXTADDR_0_HIGH + (index * 8), addr_high);
+		tw32(MAC_EXTADDR_0_LOW + (index * 8), addr_low);
+	}
+}
 
 /* tp->lock is held. */
 static void __tg3_set_mac_addr(struct tg3 *tp, bool skip_mac_1)
 {
-	u32 addr_high, addr_low;
+	u32 addr_high;
 	int i;
 
-	addr_high = ((tp->dev->dev_addr[0] << 8) |
-		     tp->dev->dev_addr[1]);
-	addr_low = ((tp->dev->dev_addr[2] << 24) |
-		    (tp->dev->dev_addr[3] << 16) |
-		    (tp->dev->dev_addr[4] <<  8) |
-		    (tp->dev->dev_addr[5] <<  0));
 	for (i = 0; i < 4; i++) {
 		if (i == 1 && skip_mac_1)
 			continue;
-		tw32(MAC_ADDR_0_HIGH + (i * 8), addr_high);
-		tw32(MAC_ADDR_0_LOW + (i * 8), addr_low);
+		__tg3_set_one_mac_addr(tp, tp->dev->dev_addr, i);
 	}
 
 	if (tg3_asic_rev(tp) == ASIC_REV_5703 ||
 	    tg3_asic_rev(tp) == ASIC_REV_5704) {
-		for (i = 0; i < 12; i++) {
-			tw32(MAC_EXTADDR_0_HIGH + (i * 8), addr_high);
-			tw32(MAC_EXTADDR_0_LOW + (i * 8), addr_low);
-		}
+		for (i = 4; i < 16; i++)
+			__tg3_set_one_mac_addr(tp, tp->dev->dev_addr, i);
 	}
 
 	addr_high = (tp->dev->dev_addr[0] +
-- 
1.8.1.4
