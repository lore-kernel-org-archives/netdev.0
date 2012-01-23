From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH] mv643xx_eth: Add Rx Discard and Rx Overrun statistics
Date: Mon, 23 Jan 2012 13:16:35 +0200
Message-ID: <20120123111635.15315.64174.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: buytenh@wantstofly.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43836 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998Ab2AWLQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 06:16:39 -0500
Received: by eekc14 with SMTP id c14so1512468eek.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 03:16:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These statistics helped me a lot while searching who is losing
packets in my setup.
I added these stats to MIB group since they are very similar,
but just in other registers.
I have tested this patch on 88F6281 SoC.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 drivers/net/ethernet/marvell/mv643xx_eth.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c049d2..9edecfa 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -136,6 +136,8 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define INT_MASK			0x0068
 #define INT_MASK_EXT			0x006c
 #define TX_FIFO_URGENT_THRESHOLD	0x0074
+#define RX_DISCARD_FRAME_CNT		0x0084
+#define RX_OVERRUN_FRAME_CNT		0x0088
 #define TXQ_FIX_PRIO_CONF_MOVED		0x00dc
 #define TX_BW_RATE_MOVED		0x00e0
 #define TX_BW_MTU_MOVED			0x00e8
@@ -334,6 +336,9 @@ struct mib_counters {
 	u32 bad_crc_event;
 	u32 collision;
 	u32 late_collision;
+	/* Non MIB hardware counters */
+	u32 rx_discard;
+	u32 rx_overrun;
 };
 
 struct lro_counters {
@@ -1225,6 +1230,10 @@ static void mib_counters_clear(struct mv643xx_eth_private *mp)
 
 	for (i = 0; i < 0x80; i += 4)
 		mib_read(mp, i);
+
+	/* Clear non MIB hw counters also */
+	rdlp(mp, RX_DISCARD_FRAME_CNT);
+	rdlp(mp, RX_OVERRUN_FRAME_CNT);
 }
 
 static void mib_counters_update(struct mv643xx_eth_private *mp)
@@ -1262,6 +1271,9 @@ static void mib_counters_update(struct mv643xx_eth_private *mp)
 	p->bad_crc_event += mib_read(mp, 0x74);
 	p->collision += mib_read(mp, 0x78);
 	p->late_collision += mib_read(mp, 0x7c);
+	/* Non MIB hardware counters */
+	p->rx_discard += rdlp(mp, RX_DISCARD_FRAME_CNT);
+	p->rx_overrun += rdlp(mp, RX_OVERRUN_FRAME_CNT);
 	spin_unlock_bh(&mp->mib_counters_lock);
 
 	mod_timer(&mp->mib_counters_timer, jiffies + 30 * HZ);
@@ -1413,6 +1425,8 @@ static const struct mv643xx_eth_stats mv643xx_eth_stats[] = {
 	MIBSTAT(bad_crc_event),
 	MIBSTAT(collision),
 	MIBSTAT(late_collision),
+	MIBSTAT(rx_discard),
+	MIBSTAT(rx_overrun),
 	LROSTAT(lro_aggregated),
 	LROSTAT(lro_flushed),
 	LROSTAT(lro_no_desc),
