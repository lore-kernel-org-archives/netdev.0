From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 'fixes' 2008-02-01
Date: Fri, 1 Feb 2008 17:41:00 -0500
Message-ID: <20080201224100.GD3050@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some more fixes suitable for 2.6.25.  Also there is a patch
that includes the mac80211 alignment warning as a configurable option,
which should stop it from annoying normal users.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes

---

The following changes since commit 24e1c13c93cbdd05e4b7ea921c0050b036555adc:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes

Johannes Berg (3):
      mac80211: make alignment warning optional
      mac80211 rate control: fix section mismatch
      mac80211: fix initialisation error path

John W. Linville (1):
      ath5k: fix section mismatch warning

Reinette Chatre (1):
      iwlwifi: fix merge sequence: exit on error before state change

Ron Rindjunsky (1):
      iwlwifi: fix sparse warning in iwl 3945

Tomas Winkler (2):
      iwlwifi: Fix MIMO PS mode
      iwlwifi: remove ieee80211 types from iwl-helpers.h

 drivers/net/wireless/ath5k/base.c           |    6 +++---
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    7 ++++---
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   23 ++++++++++++++++++-----
 drivers/net/wireless/iwlwifi/iwl-helpers.h  |    3 ---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   10 +++++-----
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   10 +++++-----
 include/linux/ieee80211.h                   |    6 ++++++
 net/mac80211/Kconfig                        |   12 ++++++++++++
 net/mac80211/ieee80211.c                    |   14 +++++++-------
 net/mac80211/rc80211_pid_algo.c             |    2 +-
 net/mac80211/rc80211_simple.c               |    2 +-
 net/mac80211/rx.c                           |    7 +++++++
 12 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index d6599d2..ddc8714 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -153,7 +153,7 @@ static int		ath5k_pci_resume(struct pci_dev *pdev);
 #define ath5k_pci_resume NULL
 #endif /* CONFIG_PM */
 
-static struct pci_driver ath5k_pci_drv_id = {
+static struct pci_driver ath5k_pci_driver = {
 	.name		= "ath5k_pci",
 	.id_table	= ath5k_pci_id_table,
 	.probe		= ath5k_pci_probe,
@@ -329,7 +329,7 @@ init_ath5k_pci(void)
 
 	ath5k_debug_init();
 
-	ret = pci_register_driver(&ath5k_pci_drv_id);
+	ret = pci_register_driver(&ath5k_pci_driver);
 	if (ret) {
 		printk(KERN_ERR "ath5k_pci: can't register pci driver\n");
 		return ret;
@@ -341,7 +341,7 @@ init_ath5k_pci(void)
 static void __exit
 exit_ath5k_pci(void)
 {
-	pci_unregister_driver(&ath5k_pci_drv_id);
+	pci_unregister_driver(&ath5k_pci_driver);
 
 	ath5k_debug_finish();
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 4fdeb53..8d4d91d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -238,9 +238,10 @@ void iwl3945_hw_rx_statistics(struct iwl3945_priv *priv, struct iwl3945_rx_mem_b
 	priv->last_statistics_time = jiffies;
 }
 
-void iwl3945_add_radiotap(struct iwl3945_priv *priv, struct sk_buff *skb,
-			  struct iwl3945_rx_frame_hdr *rx_hdr,
-			  struct ieee80211_rx_status *stats)
+static void iwl3945_add_radiotap(struct iwl3945_priv *priv,
+				 struct sk_buff *skb,
+				 struct iwl3945_rx_frame_hdr *rx_hdr,
+				 struct ieee80211_rx_status *stats)
 {
 	/* First cache any information we need before we overwrite
 	 * the information provided in the skb from the hardware */
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 569347f..d727de8 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -4658,17 +4658,30 @@ void iwl4965_set_ht_add_station(struct iwl4965_priv *priv, u8 index,
 				struct ieee80211_ht_info *sta_ht_inf)
 {
 	__le32 sta_flags;
+	u8 mimo_ps_mode;
 
 	if (!sta_ht_inf || !sta_ht_inf->ht_supported)
 		goto done;
 
+	mimo_ps_mode = (sta_ht_inf->cap & IEEE80211_HT_CAP_MIMO_PS) >> 2;
+
 	sta_flags = priv->stations[index].sta.station_flags;
 
-	if (((sta_ht_inf->cap & IEEE80211_HT_CAP_MIMO_PS >> 2))
-						== IWL_MIMO_PS_DYNAMIC)
+	sta_flags &= ~(STA_FLG_RTS_MIMO_PROT_MSK | STA_FLG_MIMO_DIS_MSK);
+
+	switch (mimo_ps_mode) {
+	case WLAN_HT_CAP_MIMO_PS_STATIC:
+		sta_flags |= STA_FLG_MIMO_DIS_MSK;
+		break;
+	case WLAN_HT_CAP_MIMO_PS_DYNAMIC:
 		sta_flags |= STA_FLG_RTS_MIMO_PROT_MSK;
-	else
-		sta_flags &= ~STA_FLG_RTS_MIMO_PROT_MSK;
+		break;
+	case WLAN_HT_CAP_MIMO_PS_DISABLED:
+		break;
+	default:
+		IWL_WARNING("Invalid MIMO PS mode %d", mimo_ps_mode);
+		break;
+	}
 
 	sta_flags |= cpu_to_le32(
 	      (u32)sta_ht_inf->ampdu_factor << STA_FLG_MAX_AGG_SIZE_POS);
@@ -4679,7 +4692,7 @@ void iwl4965_set_ht_add_station(struct iwl4965_priv *priv, u8 index,
 	if (iwl4965_is_fat_tx_allowed(priv, sta_ht_inf))
 		sta_flags |= STA_FLG_FAT_EN_MSK;
 	else
-		sta_flags &= (~STA_FLG_FAT_EN_MSK);
+		sta_flags &= ~STA_FLG_FAT_EN_MSK;
 
 	priv->stations[index].sta.station_flags = sta_flags;
  done:
diff --git a/drivers/net/wireless/iwlwifi/iwl-helpers.h b/drivers/net/wireless/iwlwifi/iwl-helpers.h
index cb009f4..8993cca 100644
--- a/drivers/net/wireless/iwlwifi/iwl-helpers.h
+++ b/drivers/net/wireless/iwlwifi/iwl-helpers.h
@@ -147,9 +147,6 @@ static inline struct ieee80211_conf *ieee80211_get_hw_conf(
 
 #define QOS_CONTROL_LEN 2
 
-#define IEEE80211_STYPE_BACK_REQ	0x0080
-#define IEEE80211_STYPE_BACK		0x0090
-
 
 static inline int ieee80211_is_management(u16 fc)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 33239f1..f55c757 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6330,6 +6330,11 @@ static int __iwl3945_up(struct iwl3945_priv *priv)
 		return -ENODEV;
 	}
 
+	if (!priv->ucode_data_backup.v_addr || !priv->ucode_data.v_addr) {
+		IWL_ERROR("ucode not available for device bringup\n");
+		return -EIO;
+	}
+
 	/* If platform's RF_KILL switch is NOT set to KILL */
 	if (iwl3945_read32(priv, CSR_GP_CNTRL) &
 				CSR_GP_CNTRL_REG_FLAG_HW_RF_KILL_SW)
@@ -6342,11 +6347,6 @@ static int __iwl3945_up(struct iwl3945_priv *priv)
 		}
 	}
 
-	if (!priv->ucode_data_backup.v_addr || !priv->ucode_data.v_addr) {
-		IWL_ERROR("ucode not available for device bringup\n");
-		return -EIO;
-	}
-
 	iwl3945_write32(priv, CSR_INT, 0xFFFFFFFF);
 
 	rc = iwl3945_hw_nic_init(priv);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index bf3a60c..f423241 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6755,6 +6755,11 @@ static int __iwl4965_up(struct iwl4965_priv *priv)
 		return -ENODEV;
 	}
 
+	if (!priv->ucode_data_backup.v_addr || !priv->ucode_data.v_addr) {
+		IWL_ERROR("ucode not available for device bringup\n");
+		return -EIO;
+	}
+
 	/* If platform's RF_KILL switch is NOT set to KILL */
 	if (iwl4965_read32(priv, CSR_GP_CNTRL) &
 				CSR_GP_CNTRL_REG_FLAG_HW_RF_KILL_SW)
@@ -6767,11 +6772,6 @@ static int __iwl4965_up(struct iwl4965_priv *priv)
 		}
 	}
 
-	if (!priv->ucode_data_backup.v_addr || !priv->ucode_data.v_addr) {
-		IWL_ERROR("ucode not available for device bringup\n");
-		return -EIO;
-	}
-
 	iwl4965_write32(priv, CSR_INT, 0xFFFFFFFF);
 
 	rc = iwl4965_hw_nic_init(priv);
diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 5de6d91..f577c8f 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -287,6 +287,12 @@ struct ieee80211_ht_addt_info {
 #define IEEE80211_HT_IE_NON_GF_STA_PRSNT	0x0004
 #define IEEE80211_HT_IE_NON_HT_STA_PRSNT	0x0010
 
+/* MIMO Power Save Modes */
+#define WLAN_HT_CAP_MIMO_PS_STATIC         0
+#define WLAN_HT_CAP_MIMO_PS_DYNAMIC        1
+#define WLAN_HT_CAP_MIMO_PS_INVALID        2
+#define WLAN_HT_CAP_MIMO_PS_DISABLED       3
+
 /* Authentication algorithms */
 #define WLAN_AUTH_OPEN 0
 #define WLAN_AUTH_SHARED_KEY 1
diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index 09c2550..e77592d 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -98,6 +98,18 @@ config MAC80211_DEBUGFS
 
 	  Say N unless you know you need this.
 
+config MAC80211_DEBUG_PACKET_ALIGNMENT
+	bool "Enable packet alignment debugging"
+	depends on MAC80211
+	help
+	  This option is recommended for driver authors and strongly
+	  discouraged for everybody else, it will trigger a warning
+	  when a driver hands mac80211 a buffer that is aligned in
+	  a way that will cause problems with the IP stack on some
+	  architectures.
+
+	  Say N unless you're writing a mac80211 based driver.
+
 config MAC80211_DEBUG
 	bool "Enable debugging output"
 	depends on MAC80211
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 5dcc2d6..67b7c75 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -1344,17 +1344,17 @@ static int __init ieee80211_init(void)
 
 	ret = rc80211_simple_init();
 	if (ret)
-		goto fail;
+		goto out;
 
 	ret = rc80211_pid_init();
 	if (ret)
-		goto fail_simple;
+		goto out_cleanup_simple;
 
 	ret = ieee80211_wme_register();
 	if (ret) {
 		printk(KERN_DEBUG "ieee80211_init: failed to "
 		       "initialize WME (err=%d)\n", ret);
-		goto fail_pid;
+		goto out_cleanup_pid;
 	}
 
 	ieee80211_debugfs_netdev_init();
@@ -1362,11 +1362,11 @@ static int __init ieee80211_init(void)
 
 	return 0;
 
- fail_pid:
-	rc80211_simple_exit();
- fail_simple:
+ out_cleanup_pid:
 	rc80211_pid_exit();
- fail:
+ out_cleanup_simple:
+	rc80211_simple_exit();
+ out:
 	return ret;
 }
 
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index 554c4ba..c339571 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -538,7 +538,7 @@ int __init rc80211_pid_init(void)
 	return ieee80211_rate_control_register(&mac80211_rcpid);
 }
 
-void __exit rc80211_pid_exit(void)
+void rc80211_pid_exit(void)
 {
 	ieee80211_rate_control_unregister(&mac80211_rcpid);
 }
diff --git a/net/mac80211/rc80211_simple.c b/net/mac80211/rc80211_simple.c
index 934676d..9a78b11 100644
--- a/net/mac80211/rc80211_simple.c
+++ b/net/mac80211/rc80211_simple.c
@@ -389,7 +389,7 @@ int __init rc80211_simple_init(void)
 	return ieee80211_rate_control_register(&mac80211_rcsimple);
 }
 
-void __exit rc80211_simple_exit(void)
+void rc80211_simple_exit(void)
 {
 	ieee80211_rate_control_unregister(&mac80211_rcsimple);
 }
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index d44c872..535407d 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -340,11 +340,15 @@ static u32 ieee80211_rx_load_stats(struct ieee80211_local *local,
 	return load;
 }
 
+#ifdef CONFIG_MAC80211_DEBUG_PACKET_ALIGNMENT
 static ieee80211_txrx_result
 ieee80211_rx_h_verify_ip_alignment(struct ieee80211_txrx_data *rx)
 {
 	int hdrlen;
 
+	if (!WLAN_FC_DATA_PRESENT(rx->fc))
+		return TXRX_CONTINUE;
+
 	/*
 	 * Drivers are required to align the payload data in a way that
 	 * guarantees that the contained IP header is aligned to a four-
@@ -371,11 +375,14 @@ ieee80211_rx_h_verify_ip_alignment(struct ieee80211_txrx_data *rx)
 
 	return TXRX_CONTINUE;
 }
+#endif
 
 ieee80211_rx_handler ieee80211_rx_pre_handlers[] =
 {
 	ieee80211_rx_h_parse_qos,
+#ifdef CONFIG_MAC80211_DEBUG_PACKET_ALIGNMENT
 	ieee80211_rx_h_verify_ip_alignment,
+#endif
 	NULL
 };
 
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
