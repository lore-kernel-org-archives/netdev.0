From: Karl Beldan <karl.beldan@gmail.com>
Subject: [PATCH] mac80211: minstrels: spare numerous useless calls to get_random_bytes
Date: Wed, 13 Nov 2013 10:54:19 +0100
Message-ID: <1384336459-5322-1-git-send-email-karl.beldan@gmail.com>
Cc: Felix Fietkau <nbd@openwrt.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Karl Beldan <karl.beldan@rivierawaves.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:43965 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759211Ab3KMJyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 04:54:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Beldan <karl.beldan@rivierawaves.com>

ATM, only the first array value returned by get_random_bytes is used.
This change moves the call to get_random_bytes from the nested loop it
is in to its parent.
While at it, replace get_random_bytes with prandom_bytes since PRNs are
way enough for the selection process.
After this, minstrel_ht reclaims 80 PR-bytes instead of 640 R-bytes.

minstrels use sample tables to probe different rates in a randomized
manner.
minstrel_ht inits one single sample table upon registration (during
subsys_initcalls) and minstrel uses one per STA addition in minstrel.

Signed-off-by: Karl Beldan <karl.beldan@rivierawaves.com>
---
 net/mac80211/rc80211_minstrel.c    | 3 +--
 net/mac80211/rc80211_minstrel_ht.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 7fa1b36..d2f19f7 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -422,10 +422,9 @@ init_sample_table(struct minstrel_sta_info *mi)
 	memset(mi->sample_table, 0xff, SAMPLE_COLUMNS * mi->n_rates);
 
 	for (col = 0; col < SAMPLE_COLUMNS; col++) {
+		prandom_bytes(rnd, sizeof(rnd));
 		for (i = 0; i < mi->n_rates; i++) {
-			get_random_bytes(rnd, sizeof(rnd));
 			new_idx = (i + rnd[i & 7]) % mi->n_rates;
-
 			while (SAMPLE_TBL(mi, new_idx, col) != 0xff)
 				new_idx = (new_idx + 1) % mi->n_rates;
 
diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index 5d60779..91912f8 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -1052,10 +1052,9 @@ init_sample_table(void)
 
 	memset(sample_table, 0xff, sizeof(sample_table));
 	for (col = 0; col < SAMPLE_COLUMNS; col++) {
+		prandom_bytes(rnd, sizeof(rnd));
 		for (i = 0; i < MCS_GROUP_RATES; i++) {
-			get_random_bytes(rnd, sizeof(rnd));
 			new_idx = (i + rnd[i]) % MCS_GROUP_RATES;
-
 			while (sample_table[col][new_idx] != 0xff)
 				new_idx = (new_idx + 1) % MCS_GROUP_RATES;
 
-- 
1.8.2
