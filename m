From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-09-29
Date: Wed, 29 Sep 2010 16:33:53 -0400
Message-ID: <20100929203352.GC2516@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36944 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742Ab0I3M7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 08:59:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are two more fixes intended for 2.6.36.  One fixes a user after
free error, the other fixes a reported regression (bug 17722).  Both are
reasonably small and well documented in the commit logs.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 01db403cf99f739f86903314a489fb420e0e254f:

  tcp: Fix >4GB writes on 64-bit. (2010-09-27 20:24:54 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Florian Mickler (1):
      iwl3945: queue the right work if the scan needs to be aborted

Johannes Berg (1):
      mac80211: fix use-after-free

 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    2 +-
 net/mac80211/rx.c                           |    4 ----
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 9dd9e64..8fd00a6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1411,7 +1411,7 @@ void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	clear_bit(STATUS_SCAN_HW, &priv->status);
 	clear_bit(STATUS_SCANNING, &priv->status);
 	/* inform mac80211 scan aborted */
-	queue_work(priv->workqueue, &priv->scan_completed);
+	queue_work(priv->workqueue, &priv->abort_scan);
 }
 
 int iwlagn_manage_ibss_station(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 59a308b..d31661c 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -3018,7 +3018,7 @@ void iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	clear_bit(STATUS_SCANNING, &priv->status);
 
 	/* inform mac80211 scan aborted */
-	queue_work(priv->workqueue, &priv->scan_completed);
+	queue_work(priv->workqueue, &priv->abort_scan);
 }
 
 static void iwl3945_bg_restart(struct work_struct *data)
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index fa0f37e..2862428 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2199,9 +2199,6 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx,
 	struct net_device *prev_dev = NULL;
 	struct ieee80211_rx_status *status = IEEE80211_SKB_RXCB(skb);
 
-	if (status->flag & RX_FLAG_INTERNAL_CMTR)
-		goto out_free_skb;
-
 	if (skb_headroom(skb) < sizeof(*rthdr) &&
 	    pskb_expand_head(skb, sizeof(*rthdr), 0, GFP_ATOMIC))
 		goto out_free_skb;
@@ -2260,7 +2257,6 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx,
 	} else
 		goto out_free_skb;
 
-	status->flag |= RX_FLAG_INTERNAL_CMTR;
 	return;
 
  out_free_skb:
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
