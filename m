From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Break out RSS indir table init and
 assignment
Date: Wed, 14 Dec 2011 13:10:01 -0800
Message-ID: <1323897002-17295-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2488 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758171Ab1LNVJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 16:09:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch creates a new device member to hold the RSS indirection table
and separates out the code that initializes the table from the code that
programs the table into device registers.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   57 +++++++++++++++++++++--------------
 drivers/net/ethernet/broadcom/tg3.h |    3 ++
 2 files changed, 37 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0766d03..8bf11ca 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -135,7 +135,6 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 	(tg3_flag(tp, LRG_PROD_RING_CAP) ? \
 	 TG3_RX_JMB_MAX_SIZE_5717 : TG3_RX_JMB_MAX_SIZE_5700)
 #define TG3_DEF_RX_JUMBO_RING_PENDING	100
-#define TG3_RSS_INDIR_TBL_SIZE		128
 
 /* Do not place this n-ring entries value into the tp struct itself,
  * we really want to expose these constants to GCC so that modulo et
@@ -8221,6 +8220,37 @@ static void tg3_setup_rxbd_thresholds(struct tg3 *tp)
 		tw32(JMB_REPLENISH_LWM, bdcache_maxcnt);
 }
 
+void tg3_rss_init_indir_tbl(struct tg3 *tp)
+{
+	int i;
+
+	if (!tg3_flag(tp, SUPPORT_MSIX))
+		return;
+
+	if (tp->irq_cnt <= 2)
+		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
+	else
+		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
+			tp->rss_ind_tbl[i] = i % (tp->irq_cnt - 1);
+}
+
+void tg3_rss_write_indir_tbl(struct tg3 *tp)
+{
+	int i = 0;
+	u32 reg = MAC_RSS_INDIR_TBL_0;
+
+	while (i < TG3_RSS_INDIR_TBL_SIZE) {
+		u32 val = tp->rss_ind_tbl[i];
+		i++;
+		for (; i % 8; i++) {
+			val <<= 4;
+			val |= tp->rss_ind_tbl[i];
+		}
+		tw32(reg, val);
+		reg += 4;
+	}
+}
+
 /* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 {
@@ -8914,28 +8944,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(100);
 
 	if (tg3_flag(tp, ENABLE_RSS)) {
-		int i = 0;
-		u32 reg = MAC_RSS_INDIR_TBL_0;
-
-		if (tp->irq_cnt == 2) {
-			for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i += 8) {
-				tw32(reg, 0x0);
-				reg += 4;
-			}
-		} else {
-			u32 val;
-
-			while (i < TG3_RSS_INDIR_TBL_SIZE) {
-				val = i % (tp->irq_cnt - 1);
-				i++;
-				for (; i % 8; i++) {
-					val <<= 4;
-					val |= (i % (tp->irq_cnt - 1));
-				}
-				tw32(reg, val);
-				reg += 4;
-			}
-		}
+		tg3_rss_write_indir_tbl(tp);
 
 		/* Setup the "secret" hash key. */
 		tw32(MAC_RSS_HASH_KEY_0, 0x5f865437);
@@ -9659,6 +9668,8 @@ static int tg3_open(struct net_device *dev)
 	 */
 	tg3_ints_init(tp);
 
+	tg3_rss_init_indir_tbl(tp);
+
 	/* The placement of this call is tied
 	 * to the setup and use of Host TX descriptors.
 	 */
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index a4b1419..aea8f72 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -31,6 +31,8 @@
 #define TG3_RX_RET_MAX_SIZE_5705	512
 #define TG3_RX_RET_MAX_SIZE_5717	4096
 
+#define TG3_RSS_INDIR_TBL_SIZE		128
+
 /* First 256 bytes are a mirror of PCI config space. */
 #define TG3PCI_VENDOR			0x00000000
 #define  TG3PCI_VENDOR_BROADCOM		 0x14e4
@@ -3152,6 +3154,7 @@ struct tg3 {
 	u32				led_ctrl;
 	u32				phy_otp;
 	u32				setlpicnt;
+	u8				rss_ind_tbl[TG3_RSS_INDIR_TBL_SIZE];
 
 #define TG3_BPN_SIZE			24
 	char				board_part_number[TG3_BPN_SIZE];
-- 
1.7.3.4
