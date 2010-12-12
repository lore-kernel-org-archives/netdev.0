From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 9/9] hostap: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:53:05 +0100
Message-ID: <1292169185-10579-10-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Jes Sorensen <jes@trained-monkey.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

flush_scheduled_work() is on its way out.  Drop flush_scheduled_work()
from prism2_free_local_data() and replace it with explicit flushing of
work items on the respective free functions.  Work items in ap_data
are flushed from hostap_free_data() and the ones in local_info from
prism2_free_local_data().

Flush is used instead of cancel as some process and free items from
queue.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jes Sorensen <jes@trained-monkey.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/wireless/hostap/hostap_ap.c |    3 +++
 drivers/net/wireless/hostap/hostap_hw.c |    8 +++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index dbb9869..18d63f5 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -858,7 +858,10 @@ void hostap_free_data(struct ap_data *ap)
 		return;
 	}
 
+	flush_work_sync(&ap->add_sta_proc_queue);
+
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
+	flush_work_sync(&ap->wds_oper_queue);
 	if (ap->crypt)
 		ap->crypt->deinit(ap->crypt_priv);
 	ap->crypt = ap->crypt_priv = NULL;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index b7cb165..a8bddd8 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -3317,7 +3317,13 @@ static void prism2_free_local_data(struct net_device *dev)
 
 	unregister_netdev(local->dev);
 
-	flush_scheduled_work();
+	flush_work_sync(&local->reset_queue);
+	flush_work_sync(&local->set_multicast_list_queue);
+	flush_work_sync(&local->set_tim_queue);
+#ifndef PRISM2_NO_STATION_MODES
+	flush_work_sync(&local->info_queue);
+#endif
+	flush_work_sync(&local->comms_qual_update);
 
 	lib80211_crypt_info_free(&local->crypt_info);
 
-- 
1.7.1
