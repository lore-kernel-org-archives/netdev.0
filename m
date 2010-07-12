From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-07-12
Date: Mon, 12 Jul 2010 16:16:38 -0400
Message-ID: <20100712201637.GD2442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a couple of small fixes for resource leaks in 2.6.35.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 17c99297212a2d1b1779a08caf4b0d83a85545df:

  r8169: incorrect identifier for a 8168dp (2010-07-11 17:10:09 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Rajkumar Manoharan (1):
      ath9k_htc: fix memory leak in ath9k_hif_usb_alloc_urbs

Reinette Chatre (1):
      iwlwifi: remove key information during device restart

 drivers/net/wireless/ath/ath9k/hif_usb.c |    8 ++++++--
 drivers/net/wireless/iwlwifi/iwl-sta.h   |   11 +++++++++++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 77b3591..23c15aa 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -730,13 +730,17 @@ static int ath9k_hif_usb_alloc_urbs(struct hif_device_usb *hif_dev)
 
 	/* RX */
 	if (ath9k_hif_usb_alloc_rx_urbs(hif_dev) < 0)
-		goto err;
+		goto err_rx;
 
 	/* Register Read */
 	if (ath9k_hif_usb_alloc_reg_in_urb(hif_dev) < 0)
-		goto err;
+		goto err_reg;
 
 	return 0;
+err_reg:
+	ath9k_hif_usb_dealloc_rx_urbs(hif_dev);
+err_rx:
+	ath9k_hif_usb_dealloc_tx_urbs(hif_dev);
 err:
 	return -ENOMEM;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.h b/drivers/net/wireless/iwlwifi/iwl-sta.h
index c2a453a..dc43ebd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.h
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.h
@@ -97,6 +97,17 @@ static inline void iwl_clear_driver_stations(struct iwl_priv *priv)
 	spin_lock_irqsave(&priv->sta_lock, flags);
 	memset(priv->stations, 0, sizeof(priv->stations));
 	priv->num_stations = 0;
+
+	/*
+	 * Remove all key information that is not stored as part of station
+	 * information since mac80211 may not have had a
+	 * chance to remove all the keys. When device is reconfigured by
+	 * mac80211 after an error all keys will be reconfigured.
+	 */
+	priv->ucode_key_table = 0;
+	priv->key_mapping_key = 0;
+	memset(priv->wep_keys, 0, sizeof(priv->wep_keys));
+
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
 }
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
