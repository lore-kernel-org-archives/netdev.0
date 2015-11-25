From: Ameen <ameenali023@gmail.com>
Subject: [PATCH 2/2] Minor improvement for smsc95xx netusb driver performance.
Date: Wed, 25 Nov 2015 23:55:26 +0200
Message-ID: <1448488526-8040-1-git-send-email-AmeenAli023@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Ameen <AmeenAli023@gmail.com>
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33043 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbKYVzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 16:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce number of memcpy's by 1-2 improve transmit performance by 2-4%.
or reduce CPU usage on a comparable value.

Signed-off-by: Ameen Ali <AmeenAli023@gmail.com>
---
 drivers/net/usb/smsc95xx.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 66b3ab9..fff07cc 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1830,7 +1830,9 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 {
 	bool csum = skb->ip_summed == CHECKSUM_PARTIAL;
 	int overhead = csum ? SMSC95XX_TX_OVERHEAD_CSUM : SMSC95XX_TX_OVERHEAD;
-	u32 tx_cmd_a, tx_cmd_b;
+	struct tx_commands_t {
+		u32 cmd_a, cmd_b, csum_preamble;
+	} tx_cmds;
 
 	/* We do not advertise SG, so skbs should be already linearized */
 	BUG_ON(skb_shinfo(skb)->nr_frags);
@@ -1855,26 +1857,24 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 				+ skb->csum_offset)) = csum_fold(calc);
 
 			csum = false;
+			overhead = SMSC95XX_TX_OVERHEAD;
 		} else {
-			u32 csum_preamble = smsc95xx_calc_csum_preamble(skb);
+			tx_cmds.csum_preamble = smsc95xx_calc_csum_preamble(skb);
 			skb_push(skb, 4);
-			cpu_to_le32s(&csum_preamble);
-			memcpy(skb->data, &csum_preamble, 4);
+			cpu_to_le32s(&tx_cmds.csum_preamble);
 		}
 	}
 
-	skb_push(skb, 4);
-	tx_cmd_b = (u32)(skb->len - 4);
+	tx_cmds.cmd_a = (u32)skb->len | TX_CMD_A_FIRST_SEG_ |
+		TX_CMD_A_LAST_SEG_;
+	cpu_to_le32s(&tx_cmds.cmd_a);
+	tx_cmds.cmd_b = (u32)skb->len;
 	if (csum)
-		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
-	cpu_to_le32s(&tx_cmd_b);
-	memcpy(skb->data, &tx_cmd_b, 4);
+	  tx_cmds.cmd_b |= TX_CMD_B_CSUM_ENABLE;
 
-	skb_push(skb, 4);
-	tx_cmd_a = (u32)(skb->len - 8) | TX_CMD_A_FIRST_SEG_ |
-		TX_CMD_A_LAST_SEG_;
-	cpu_to_le32s(&tx_cmd_a);
-	memcpy(skb->data, &tx_cmd_a, 4);
+	cpu_to_le32s(&tx_cmds.cmd_b);
+	skb_push(skb, 8);
+	memcpy(skb->data, &tx_cmds, overhead);
 
 	return skb;
 }
-- 
2.5.0
