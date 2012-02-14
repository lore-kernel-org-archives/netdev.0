From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 05/10] tg3: Reduce UMP event collision window
Date: Mon, 13 Feb 2012 17:20:12 -0800
Message-ID: <1329182417-28223-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1648 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758658Ab2BNBVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tg3 driver needs to submit a few phy register values to the UMP
firmware each time the link state changes.  Up until now, the driver
would wait for the previous event to complete, then proceed to gather
data through a series of phy accesses.  Since phy accesses are
relatively slow, it is possible for another thread to attempt to submit
its own event while the UMP code is still construction its message.

This patch seeks to minimize the collision window as much as possible by
preloading the phy data.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   42 +++++++++++++++++++++-------------
 1 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 67b6d61..31a8e8a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1453,33 +1453,23 @@ static void tg3_wait_for_event_ack(struct tg3 *tp)
 }
 
 /* tp->lock is held. */
-static void tg3_ump_link_report(struct tg3 *tp)
+static void tg3_phy_gather_ump_data(struct tg3 *tp, u32 *data)
 {
-	u32 reg;
-	u32 val;
-
-	if (!tg3_flag(tp, 5780_CLASS) || !tg3_flag(tp, ENABLE_ASF))
-		return;
-
-	tg3_wait_for_event_ack(tp);
-
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_LINK_UPDATE);
-
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_LEN_MBOX, 14);
+	u32 reg, val;
 
 	val = 0;
 	if (!tg3_readphy(tp, MII_BMCR, &reg))
 		val = reg << 16;
 	if (!tg3_readphy(tp, MII_BMSR, &reg))
 		val |= (reg & 0xffff);
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX, val);
+	*data++ = val;
 
 	val = 0;
 	if (!tg3_readphy(tp, MII_ADVERTISE, &reg))
 		val = reg << 16;
 	if (!tg3_readphy(tp, MII_LPA, &reg))
 		val |= (reg & 0xffff);
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 4, val);
+	*data++ = val;
 
 	val = 0;
 	if (!(tp->phy_flags & TG3_PHYFLG_MII_SERDES)) {
@@ -1488,13 +1478,33 @@ static void tg3_ump_link_report(struct tg3 *tp)
 		if (!tg3_readphy(tp, MII_STAT1000, &reg))
 			val |= (reg & 0xffff);
 	}
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 8, val);
+	*data++ = val;
 
 	if (!tg3_readphy(tp, MII_PHYADDR, &reg))
 		val = reg << 16;
 	else
 		val = 0;
-	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 12, val);
+	*data++ = val;
+}
+
+/* tp->lock is held. */
+static void tg3_ump_link_report(struct tg3 *tp)
+{
+	u32 data[4];
+
+	if (!tg3_flag(tp, 5780_CLASS) || !tg3_flag(tp, ENABLE_ASF))
+		return;
+
+	tg3_phy_gather_ump_data(tp, data);
+
+	tg3_wait_for_event_ack(tp);
+
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX, FWCMD_NICDRV_LINK_UPDATE);
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_LEN_MBOX, 14);
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 0x0, data[0]);
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 0x4, data[1]);
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 0x8, data[2]);
+	tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX + 0xc, data[3]);
 
 	tg3_generate_fw_event(tp);
 }
-- 
1.7.3.4
