From: Adrien Schildknecht <adrien+dev@schischi.me>
Subject: [PATCH] mac80211: fix invalid read in minstrel_sort_best_tp_rates()
Date: Tue, 28 Jul 2015 10:30:16 +0200
Message-ID: <1438072216-19228-1-git-send-email-adrien+dev@schischi.me>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: johannes@sipsolutions.net, davem@davemloft.net,
	thomas@net.t-labs.tu-berlin.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the last iteration of the loop, j may equal zero and thus
tp_list[j - 1] causes an invalid read.
Changed the logic of the loop so that j - 1 is always >= 0.

Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
---
 net/mac80211/rc80211_minstrel.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 247552a..3ece7d1 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -92,14 +92,15 @@ int minstrel_get_tp_avg(struct minstrel_rate *mr, int prob_ewma)
 static inline void
 minstrel_sort_best_tp_rates(struct minstrel_sta_info *mi, int i, u8 *tp_list)
 {
-	int j = MAX_THR_RATES;
-	struct minstrel_rate_stats *tmp_mrs = &mi->r[j - 1].stats;
+	int j;
+	struct minstrel_rate_stats *tmp_mrs;
 	struct minstrel_rate_stats *cur_mrs = &mi->r[i].stats;
 
-	while (j > 0 && (minstrel_get_tp_avg(&mi->r[i], cur_mrs->prob_ewma) >
-	       minstrel_get_tp_avg(&mi->r[tp_list[j - 1]], tmp_mrs->prob_ewma))) {
-		j--;
+	for (j = MAX_THR_RATES; j > 0; --j) {
 		tmp_mrs = &mi->r[tp_list[j - 1]].stats;
+		if (minstrel_get_tp_avg(&mi->r[i], cur_mrs->prob_ewma) <=
+		    minstrel_get_tp_avg(&mi->r[tp_list[j - 1]], tmp_mrs->prob_ewma))
+			break;
 	}
 
 	if (j < MAX_THR_RATES - 1)
-- 
2.4.6
