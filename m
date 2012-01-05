From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: [PATCH v2 1/6] ath6kl: rename vif init and cleanup functions
Date: Thu, 05 Jan 2012 15:26:27 +0200
Message-ID: <20120105132627.22281.77816.stgit@x201>
References: <20120105132523.22281.95999.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, ath6kl-devel@qualcomm.com,
	davem@davemloft.net
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105132523.22281.95999.stgit@x201>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ath6kl_cfg80211_vif_init/cleanup() follow more closely the style used
elsewhere in ath6kl.

Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c |    9 ++++-----
 drivers/net/wireless/ath/ath6kl/cfg80211.h |    2 ++
 drivers/net/wireless/ath/ath6kl/core.h     |    1 -
 drivers/net/wireless/ath/ath6kl/init.c     |    5 +++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 6c59a21..cd67cb6 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -1403,7 +1403,7 @@ static int ath6kl_cfg80211_del_iface(struct wiphy *wiphy,
 
 	ath6kl_cleanup_vif(vif, test_bit(WMI_READY, &ar->flag));
 
-	ath6kl_deinit_if_data(vif);
+	ath6kl_cfg80211_vif_cleanup(vif);
 
 	return 0;
 }
@@ -2742,7 +2742,7 @@ int ath6kl_register_ieee80211_hw(struct ath6kl *ar)
 	return 0;
 }
 
-static int ath6kl_init_if_data(struct ath6kl_vif *vif)
+static int ath6kl_cfg80211_vif_init(struct ath6kl_vif *vif)
 {
 	vif->aggr_cntxt = aggr_init(vif->ndev);
 	if (!vif->aggr_cntxt) {
@@ -2761,7 +2761,7 @@ static int ath6kl_init_if_data(struct ath6kl_vif *vif)
 	return 0;
 }
 
-void ath6kl_deinit_if_data(struct ath6kl_vif *vif)
+void ath6kl_cfg80211_vif_cleanup(struct ath6kl_vif *vif)
 {
 	struct ath6kl *ar = vif->ar;
 
@@ -2808,8 +2808,7 @@ struct net_device *ath6kl_interface_add(struct ath6kl *ar, char *name,
 
 	ath6kl_init_control_info(vif);
 
-	/* TODO: Pass interface specific pointer instead of ar */
-	if (ath6kl_init_if_data(vif))
+	if (ath6kl_cfg80211_vif_init(vif))
 		goto err;
 
 	if (register_netdevice(ndev))
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.h b/drivers/net/wireless/ath/ath6kl/cfg80211.h
index 81f20a5..aa96169 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.h
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.h
@@ -53,6 +53,8 @@ int ath6kl_cfg80211_suspend(struct ath6kl *ar,
 
 int ath6kl_cfg80211_resume(struct ath6kl *ar);
 
+void ath6kl_cfg80211_vif_cleanup(struct ath6kl_vif *vif);
+
 void ath6kl_cfg80211_stop(struct ath6kl_vif *vif);
 void ath6kl_cfg80211_stop_all(struct ath6kl *ar);
 
diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index c863a28..93d05c0 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -723,7 +723,6 @@ void ath6kl_wakeup_event(void *dev);
 void ath6kl_reset_device(struct ath6kl *ar, u32 target_type,
 			 bool wait_fot_compltn, bool cold_reset);
 void ath6kl_init_control_info(struct ath6kl_vif *vif);
-void ath6kl_deinit_if_data(struct ath6kl_vif *vif);
 void ath6kl_core_free(struct ath6kl *ar);
 struct ath6kl_vif *ath6kl_vif_first(struct ath6kl *ar);
 void ath6kl_cleanup_vif(struct ath6kl_vif *vif, bool wmi_ready);
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 368ecbd..ffe6254 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -1695,7 +1695,7 @@ err_rxbuf_cleanup:
 	ath6kl_htc_flush_rx_buf(ar->htc_target);
 	ath6kl_cleanup_amsdu_rxbufs(ar);
 	rtnl_lock();
-	ath6kl_deinit_if_data(netdev_priv(ndev));
+	ath6kl_cfg80211_vif_cleanup(netdev_priv(ndev));
 	rtnl_unlock();
 	wiphy_unregister(ar->wiphy);
 err_debug_init:
@@ -1716,6 +1716,7 @@ err_wq:
 	return ret;
 }
 
+/* FIXME: move this to cfg80211.c and rename to ath6kl_cfg80211_vif_stop() */
 void ath6kl_cleanup_vif(struct ath6kl_vif *vif, bool wmi_ready)
 {
 	static u8 bcast_mac[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
@@ -1761,7 +1762,7 @@ void ath6kl_stop_txrx(struct ath6kl *ar)
 		spin_unlock_bh(&ar->list_lock);
 		ath6kl_cleanup_vif(vif, test_bit(WMI_READY, &ar->flag));
 		rtnl_lock();
-		ath6kl_deinit_if_data(vif);
+		ath6kl_cfg80211_vif_cleanup(vif);
 		rtnl_unlock();
 		spin_lock_bh(&ar->list_lock);
 	}
