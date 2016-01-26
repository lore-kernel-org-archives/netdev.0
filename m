From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mac80211: avoid excessive stack usage in sta_info
Date: Tue, 26 Jan 2016 23:05:31 +0100
Message-ID: <1453845942-3402704-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_OPTIMIZE_INLINING is set, the sta_info_insert_finish
function consumes more stack than normally, exceeding the
1024 byte limit on ARM:

net/mac80211/sta_info.c: In function 'sta_info_insert_finish':
net/mac80211/sta_info.c:561:1: error: the frame size of 1080 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

It turns out that there are two functions that put a 'struct station_info'
on the stack: __sta_info_destroy_part2 and sta_info_insert_finish, and
this structure alone requires up to 792 bytes.

Hoping that both are called rarely enough, this replaces the
on-stack structure with a dynamic allocation, which unfortunately
requires some suboptimal error handling for out-of-memory.

The __sta_info_destroy_part2 function is actually affected by the
stack usage twice because it calls cfg80211_del_sta_sinfo(), which
has another instance of struct station_info on its stack.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 98b6218388e3 ("mac80211/cfg80211: add station events")
Fixes: 6f7a8d26e266 ("mac80211: send statistics with delete station event")
---
 net/mac80211/sta_info.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 4402ad5b27d1..a29199ec4c3c 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -498,11 +498,17 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
 {
 	struct ieee80211_local *local = sta->local;
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
-	struct station_info sinfo;
+	struct station_info *sinfo;
 	int err = 0;
 
 	lockdep_assert_held(&local->sta_mtx);
 
+	sinfo = kzalloc(sizeof(struct station_info), GFP_KERNEL);
+	if (!sinfo) {
+		err = -ENOMEM;
+		goto out_err;
+	}
+
 	/* check if STA exists already */
 	if (sta_info_get_bss(sdata, sta->sta.addr)) {
 		err = -EEXIST;
@@ -534,10 +540,9 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
 	ieee80211_sta_debugfs_add(sta);
 	rate_control_add_sta_debugfs(sta);
 
-	memset(&sinfo, 0, sizeof(sinfo));
-	sinfo.filled = 0;
-	sinfo.generation = local->sta_generation;
-	cfg80211_new_sta(sdata->dev, sta->sta.addr, &sinfo, GFP_KERNEL);
+	sinfo->generation = local->sta_generation;
+	cfg80211_new_sta(sdata->dev, sta->sta.addr, sinfo, GFP_KERNEL);
+	kfree(sinfo);
 
 	sta_dbg(sdata, "Inserted STA %pM\n", sta->sta.addr);
 
@@ -898,7 +903,7 @@ static void __sta_info_destroy_part2(struct sta_info *sta)
 {
 	struct ieee80211_local *local = sta->local;
 	struct ieee80211_sub_if_data *sdata = sta->sdata;
-	struct station_info sinfo = {};
+	struct station_info *sinfo;
 	int ret;
 
 	/*
@@ -936,8 +941,11 @@ static void __sta_info_destroy_part2(struct sta_info *sta)
 
 	sta_dbg(sdata, "Removed STA %pM\n", sta->sta.addr);
 
-	sta_set_sinfo(sta, &sinfo);
-	cfg80211_del_sta_sinfo(sdata->dev, sta->sta.addr, &sinfo, GFP_KERNEL);
+	sinfo = kzalloc(sizeof(*sinfo), GFP_KERNEL);
+	if (sinfo)
+		sta_set_sinfo(sta, sinfo);
+	cfg80211_del_sta_sinfo(sdata->dev, sta->sta.addr, sinfo, GFP_KERNEL);
+	kfree(sinfo);
 
 	rate_control_remove_sta_debugfs(sta);
 	ieee80211_sta_debugfs_remove(sta);
-- 
2.7.0
