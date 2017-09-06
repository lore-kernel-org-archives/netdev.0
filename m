From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: hung task in mac80211
Date: Wed, 6 Sep 2017 14:40:19 +0200
Message-ID: <20170906144019.1c98a636@elisabeth>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Johannes Berg <johannes.berg@intel.com>
To: Matteo Croce <mcroce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Sep 2017 13:57:47 +0200
Matteo Croce <mcroce@redhat.com> wrote:

> Hi,
> 
> I have an hung task on vanilla 4.13 kernel which I haven't on 4.12.
> The problem is present both on my AP and on my notebook,
> so it seems it affects AP and STA mode as well.
> The generated messages are:
> 
> INFO: task kworker/u16:6:120 blocked for more than 120 seconds.
>       Not tainted 4.13.0 #57
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> kworker/u16:6   D    0   120      2 0x00000000
> Workqueue: phy0 ieee80211_ba_session_work [mac80211]
> Call Trace:
>  ? __schedule+0x174/0x5b0
>  ? schedule+0x31/0x80
>  ? schedule_preempt_disabled+0x9/0x10
>  ? __mutex_lock.isra.2+0x163/0x480
>  ? select_task_rq_fair+0xb9f/0xc60
>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
>  ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]

This is ugly and maybe wrong, but you could check perhaps...:

diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index c92df492e898..bd7512a656f2 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -320,28 +320,40 @@ void ieee80211_ba_session_work(struct work_struct *work)
 
 	mutex_lock(&sta->ampdu_mlme.mtx);
 	for (tid = 0; tid < IEEE80211_NUM_TIDS; tid++) {
-		if (test_and_clear_bit(tid, sta->ampdu_mlme.tid_rx_timer_expired))
+		if (test_and_clear_bit(tid, sta->ampdu_mlme.tid_rx_timer_expired)) {
+			mutex_unlock(&sta->ampdu_mlme.mtx);
 			___ieee80211_stop_rx_ba_session(
 				sta, tid, WLAN_BACK_RECIPIENT,
 				WLAN_REASON_QSTA_TIMEOUT, true);
+			mutex_lock(&sta->ampdu_mlme.mtx);
+		}
 
 		if (test_and_clear_bit(tid,
-				       sta->ampdu_mlme.tid_rx_stop_requested))
+				       sta->ampdu_mlme.tid_rx_stop_requested)) {
+			mutex_unlock(&sta->ampdu_mlme.mtx);
 			___ieee80211_stop_rx_ba_session(
 				sta, tid, WLAN_BACK_RECIPIENT,
 				WLAN_REASON_UNSPECIFIED, true);
+			mutex_lock(&sta->ampdu_mlme.mtx);
+		}
 
 		if (test_and_clear_bit(tid,
-				       sta->ampdu_mlme.tid_rx_manage_offl))
+				       sta->ampdu_mlme.tid_rx_manage_offl)) {
+			mutex_unlock(&sta->ampdu_mlme.mtx);
 			__ieee80211_start_rx_ba_session(sta, 0, 0, 0, 1, tid,
 							IEEE80211_MAX_AMPDU_BUF,
 							false, true);
+			mutex_lock(&sta->ampdu_mlme.mtx);
+		}
 
 		if (test_and_clear_bit(tid + IEEE80211_NUM_TIDS,
-				       sta->ampdu_mlme.tid_rx_manage_offl))
+				       sta->ampdu_mlme.tid_rx_manage_offl)) {
+			mutex_unlock(&sta->ampdu_mlme.mtx);
 			___ieee80211_stop_rx_ba_session(
 				sta, tid, WLAN_BACK_RECIPIENT,
 				0, false);
+			mutex_lock(&sta->ampdu_mlme.mtx);
+		}
 
 		spin_lock_bh(&sta->lock);
 
-- 
Stefano
