From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-10-07
Date: Thu, 7 Oct 2010 14:58:59 -0400
Message-ID: <20101007185859.GD20950@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58320 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753050Ab0JGTAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 15:00:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a few more more-or-less-one-liner fixes intended for 2.6.36.
The one from Felix fixes a regression introduced in the 2.6.36 cycle.
The one from Johannes fixes a crash reported by Ben Greear (as
documented in the changelog).  The one from me reverts and earlier patch
from me that can result in stuff in dmesg from not calling
netif_receive_skb in the proper context.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit fb3dbece264a50ab4373f3af0bbbd9175d3ad4d7:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-2.6 (2010-10-07 00:59:39 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Felix Fietkau (1):
      ath9k_hw: fix regression in ANI listen time calculation

Johannes Berg (1):
      mac80211: delete AddBA response timer

John W. Linville (1):
      Revert "mac80211: use netif_receive_skb in ieee80211_tx_status callpath"

 drivers/net/wireless/ath/ath9k/ani.c |    2 +-
 net/mac80211/agg-tx.c                |    2 ++
 net/mac80211/status.c                |    4 ++--
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index cc648b6..a3d95cc 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -543,7 +543,7 @@ static u8 ath9k_hw_chan_2_clockrate_mhz(struct ath_hw *ah)
 	if (conf_is_ht40(conf))
 		return clockrate * 2;
 
-	return clockrate * 2;
+	return clockrate;
 }
 
 static int32_t ath9k_hw_ani_get_listen_time(struct ath_hw *ah)
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index c893f23..8f23401 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -175,6 +175,8 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 
 	set_bit(HT_AGG_STATE_STOPPING, &tid_tx->state);
 
+	del_timer_sync(&tid_tx->addba_resp_timer);
+
 	/*
 	 * After this packets are no longer handed right through
 	 * to the driver but are put onto tid_tx->pending instead,
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 10caec5..34da679 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -377,7 +377,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 				skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (skb2) {
 					skb2->dev = prev_dev;
-					netif_receive_skb(skb2);
+					netif_rx(skb2);
 				}
 			}
 
@@ -386,7 +386,7 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb)
 	}
 	if (prev_dev) {
 		skb->dev = prev_dev;
-		netif_receive_skb(skb);
+		netif_rx(skb);
 		skb = NULL;
 	}
 	rcu_read_unlock();
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
