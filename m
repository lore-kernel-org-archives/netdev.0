From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 3/4] rt2x00: use DECLARE_EWMA
Date: Wed, 19 Aug 2015 09:46:21 +0200
Message-ID: <1439970382-6170-4-git-send-email-johannes@sipsolutions.net>
References: <1439970382-6170-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1439970382-6170-1-git-send-email-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Instead of using the out-of-line EWMA calculation, use DECLARE_EWMA()
to create static inlines. On x86/64 this results in code that's one
byte larger (for me), but reduces struct link_ant and struct link
size by the two unsigned long values that store the parameters each.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rt2x00/Kconfig      |  1 -
 drivers/net/wireless/rt2x00/rt2x00.h     |  6 ++++--
 drivers/net/wireless/rt2x00/rt2x00link.c | 18 ++++++------------
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2x00/Kconfig
index 2b4ef256c6b9..de62f5dcb62f 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -240,7 +240,6 @@ config RT2X00_LIB_USB
 
 config RT2X00_LIB
 	tristate
-	select AVERAGE
 
 config RT2X00_LIB_FIRMWARE
 	bool
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 9bb398bed9bb..3282ddb766f4 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -254,6 +254,8 @@ struct link_qual {
 	int tx_failed;
 };
 
+DECLARE_EWMA(rssi, 1024, 8)
+
 /*
  * Antenna settings about the currently active link.
  */
@@ -285,7 +287,7 @@ struct link_ant {
 	 * Similar to the avg_rssi in the link_qual structure
 	 * this value is updated by using the walking average.
 	 */
-	struct ewma rssi_ant;
+	struct ewma_rssi rssi_ant;
 };
 
 /*
@@ -314,7 +316,7 @@ struct link {
 	/*
 	 * Currently active average RSSI value
 	 */
-	struct ewma avg_rssi;
+	struct ewma_rssi avg_rssi;
 
 	/*
 	 * Work structure for scheduling periodic link tuning.
diff --git a/drivers/net/wireless/rt2x00/rt2x00link.c b/drivers/net/wireless/rt2x00/rt2x00link.c
index 9b941c0c1264..017188e5a736 100644
--- a/drivers/net/wireless/rt2x00/rt2x00link.c
+++ b/drivers/net/wireless/rt2x00/rt2x00link.c
@@ -33,15 +33,11 @@
  */
 #define DEFAULT_RSSI		-128
 
-/* Constants for EWMA calculations. */
-#define RT2X00_EWMA_FACTOR	1024
-#define RT2X00_EWMA_WEIGHT	8
-
-static inline int rt2x00link_get_avg_rssi(struct ewma *ewma)
+static inline int rt2x00link_get_avg_rssi(struct ewma_rssi *ewma)
 {
 	unsigned long avg;
 
-	avg = ewma_read(ewma);
+	avg = ewma_rssi_read(ewma);
 	if (avg)
 		return -avg;
 
@@ -76,8 +72,7 @@ static void rt2x00link_antenna_update_rssi_history(struct rt2x00_dev *rt2x00dev,
 
 static void rt2x00link_antenna_reset(struct rt2x00_dev *rt2x00dev)
 {
-	ewma_init(&rt2x00dev->link.ant.rssi_ant, RT2X00_EWMA_FACTOR,
-		  RT2X00_EWMA_WEIGHT);
+	ewma_rssi_init(&rt2x00dev->link.ant.rssi_ant);
 }
 
 static void rt2x00lib_antenna_diversity_sample(struct rt2x00_dev *rt2x00dev)
@@ -225,12 +220,12 @@ void rt2x00link_update_stats(struct rt2x00_dev *rt2x00dev,
 	/*
 	 * Update global RSSI
 	 */
-	ewma_add(&link->avg_rssi, -rxdesc->rssi);
+	ewma_rssi_add(&link->avg_rssi, -rxdesc->rssi);
 
 	/*
 	 * Update antenna RSSI
 	 */
-	ewma_add(&ant->rssi_ant, -rxdesc->rssi);
+	ewma_rssi_add(&ant->rssi_ant, -rxdesc->rssi);
 }
 
 void rt2x00link_start_tuner(struct rt2x00_dev *rt2x00dev)
@@ -285,8 +280,7 @@ void rt2x00link_reset_tuner(struct rt2x00_dev *rt2x00dev, bool antenna)
 	 */
 	rt2x00dev->link.count = 0;
 	memset(qual, 0, sizeof(*qual));
-	ewma_init(&rt2x00dev->link.avg_rssi, RT2X00_EWMA_FACTOR,
-		  RT2X00_EWMA_WEIGHT);
+	ewma_rssi_init(&rt2x00dev->link.avg_rssi);
 
 	/*
 	 * Restore the VGC level as stored in the registers,
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
