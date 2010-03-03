From: "John W. Linville" <linville@tuxdriver.com>
Subject: pullreq: wireless-next-2.6 2010-03-03
Date: Wed, 3 Mar 2010 16:26:39 -0500
Message-ID: <20100303212638.GI23920@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40616 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266Ab0CCVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 16:30:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is another quick batch intended for 2.6.34.  Included are a
USB ID, some small fixes, and a few (for async firmware loading and
KEY_RFKILL) that depended on patches that weren't in the net-next-2.6
tree until after the merge window opened.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3a5b27bf6f29574d667230c7e76e4b83fe3014e0:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://gitorious.org/linux-omap-dss2/linux

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Bryan Polk (1):
      rt2x00: Add USB ID for CEIVA adapter to rt73usb

Dan Carpenter (1):
      zd1211rw: fix potential array underflow

Helmut Schaa (2):
      rt2x00: fix rt2800pci compilation with SoC
      rt2x00: Export rt2x00soc_probe from rt2x00soc

Johannes Berg (2):
      ar9170: load firmware asynchronously
      iwlwifi: load firmware asynchronously before mac80211 registration

Jouni Malinen (1):
      mac80211: Fix reassociation processing (within ESS roaming)

Matthew Garrett (1):
      rfkill: Add support for KEY_RFKILL

Ming Lei (1):
      ath9k: fix lockdep warning when unloading module

Stanislaw Gruszka (1):
      airo: return from set_wep_key() when key length is zero

Sujith (1):
      mac80211: Fix HT rate control configuration

 drivers/net/wireless/airo.c              |    3 +-
 drivers/net/wireless/ath/ar9170/ar9170.h |    1 +
 drivers/net/wireless/ath/ar9170/main.c   |   10 ++-
 drivers/net/wireless/ath/ar9170/usb.c    |  170 ++++++++++++++++++------------
 drivers/net/wireless/ath/ath9k/rc.c      |    6 +-
 drivers/net/wireless/ath/ath9k/xmit.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c   |  157 ++++++++++++++--------------
 drivers/net/wireless/iwlwifi/iwl-dev.h   |    2 +
 drivers/net/wireless/rt2x00/rt2800pci.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00soc.c  |    1 +
 drivers/net/wireless/rt2x00/rt73usb.c    |    2 +
 drivers/net/wireless/zd1211rw/zd_mac.c   |   10 +-
 include/linux/rfkill.h                   |    2 +-
 include/net/mac80211.h                   |    3 +-
 net/mac80211/mlme.c                      |   19 +++-
 net/mac80211/rate.h                      |    5 +-
 net/rfkill/input.c                       |    8 ++
 17 files changed, 237 insertions(+), 168 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 698d567..dc5018a 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5255,7 +5255,8 @@ static int set_wep_key(struct airo_info *ai, u16 index, const char *key,
 	WepKeyRid wkr;
 	int rc;
 
-	WARN_ON(keylen == 0);
+	if (WARN_ON(keylen == 0))
+		return -1;
 
 	memset(&wkr, 0, sizeof(wkr));
 	wkr.len = cpu_to_le16(sizeof(wkr));
diff --git a/drivers/net/wireless/ath/ar9170/ar9170.h b/drivers/net/wireless/ath/ar9170/ar9170.h
index 8c8ce67..dc662b7 100644
--- a/drivers/net/wireless/ath/ar9170/ar9170.h
+++ b/drivers/net/wireless/ath/ar9170/ar9170.h
@@ -166,6 +166,7 @@ struct ar9170 {
 	struct ath_common common;
 	struct mutex mutex;
 	enum ar9170_device_state state;
+	bool registered;
 	unsigned long bad_hw_nagger;
 
 	int (*open)(struct ar9170 *);
diff --git a/drivers/net/wireless/ath/ar9170/main.c b/drivers/net/wireless/ath/ar9170/main.c
index 8a964f1..f4650fc 100644
--- a/drivers/net/wireless/ath/ar9170/main.c
+++ b/drivers/net/wireless/ath/ar9170/main.c
@@ -2701,7 +2701,8 @@ int ar9170_register(struct ar9170 *ar, struct device *pdev)
 	dev_info(pdev, "Atheros AR9170 is registered as '%s'\n",
 		 wiphy_name(ar->hw->wiphy));
 
-	return err;
+	ar->registered = true;
+	return 0;
 
 err_unreg:
 	ieee80211_unregister_hw(ar->hw);
@@ -2712,11 +2713,14 @@ err_out:
 
 void ar9170_unregister(struct ar9170 *ar)
 {
+	if (ar->registered) {
 #ifdef CONFIG_AR9170_LEDS
-	ar9170_unregister_leds(ar);
+		ar9170_unregister_leds(ar);
 #endif /* CONFIG_AR9170_LEDS */
 
-	kfree_skb(ar->rx_failover);
 	ieee80211_unregister_hw(ar->hw);
+	}
+
+	kfree_skb(ar->rx_failover);
 	mutex_destroy(&ar->mutex);
 }
diff --git a/drivers/net/wireless/ath/ar9170/usb.c b/drivers/net/wireless/ath/ar9170/usb.c
index 0f36118..4e30197 100644
--- a/drivers/net/wireless/ath/ar9170/usb.c
+++ b/drivers/net/wireless/ath/ar9170/usb.c
@@ -582,43 +582,6 @@ static int ar9170_usb_upload(struct ar9170_usb *aru, const void *data,
 	return 0;
 }
 
-static int ar9170_usb_request_firmware(struct ar9170_usb *aru)
-{
-	int err = 0;
-
-	err = request_firmware(&aru->firmware, "ar9170.fw",
-			       &aru->udev->dev);
-	if (!err) {
-		aru->init_values = NULL;
-		return 0;
-	}
-
-	if (aru->req_one_stage_fw) {
-		dev_err(&aru->udev->dev, "ar9170.fw firmware file "
-			"not found and is required for this device\n");
-		return -EINVAL;
-	}
-
-	dev_err(&aru->udev->dev, "ar9170.fw firmware file "
-		"not found, trying old firmware...\n");
-
-	err = request_firmware(&aru->init_values, "ar9170-1.fw",
-			       &aru->udev->dev);
-	if (err) {
-		dev_err(&aru->udev->dev, "file with init values not found.\n");
-		return err;
-	}
-
-	err = request_firmware(&aru->firmware, "ar9170-2.fw", &aru->udev->dev);
-	if (err) {
-		release_firmware(aru->init_values);
-		dev_err(&aru->udev->dev, "firmware file not found.\n");
-		return err;
-	}
-
-	return err;
-}
-
 static int ar9170_usb_reset(struct ar9170_usb *aru)
 {
 	int ret, lock = (aru->intf->condition != USB_INTERFACE_BINDING);
@@ -757,6 +720,103 @@ err_out:
 	return err;
 }
 
+static void ar9170_usb_firmware_failed(struct ar9170_usb *aru)
+{
+	struct device *parent = aru->udev->dev.parent;
+
+	/* unbind anything failed */
+	if (parent)
+		down(&parent->sem);
+	device_release_driver(&aru->udev->dev);
+	if (parent)
+		up(&parent->sem);
+}
+
+static void ar9170_usb_firmware_finish(const struct firmware *fw, void *context)
+{
+	struct ar9170_usb *aru = context;
+	int err;
+
+	aru->firmware = fw;
+
+	if (!fw) {
+		dev_err(&aru->udev->dev, "firmware file not found.\n");
+		goto err_freefw;
+	}
+
+	err = ar9170_usb_init_device(aru);
+	if (err)
+		goto err_freefw;
+
+	err = ar9170_usb_open(&aru->common);
+	if (err)
+		goto err_unrx;
+
+	err = ar9170_register(&aru->common, &aru->udev->dev);
+
+	ar9170_usb_stop(&aru->common);
+	if (err)
+		goto err_unrx;
+
+	return;
+
+ err_unrx:
+	ar9170_usb_cancel_urbs(aru);
+
+ err_freefw:
+	ar9170_usb_firmware_failed(aru);
+}
+
+static void ar9170_usb_firmware_inits(const struct firmware *fw,
+				      void *context)
+{
+	struct ar9170_usb *aru = context;
+	int err;
+
+	if (!fw) {
+		dev_err(&aru->udev->dev, "file with init values not found.\n");
+		ar9170_usb_firmware_failed(aru);
+		return;
+	}
+
+	aru->init_values = fw;
+
+	/* ok so we have the init values -- get code for two-stage */
+
+	err = request_firmware_nowait(THIS_MODULE, 1, "ar9170-2.fw",
+				      &aru->udev->dev, GFP_KERNEL, aru,
+				      ar9170_usb_firmware_finish);
+	if (err)
+		ar9170_usb_firmware_failed(aru);
+}
+
+static void ar9170_usb_firmware_step2(const struct firmware *fw, void *context)
+{
+	struct ar9170_usb *aru = context;
+	int err;
+
+	if (fw) {
+		ar9170_usb_firmware_finish(fw, context);
+		return;
+	}
+
+	if (aru->req_one_stage_fw) {
+		dev_err(&aru->udev->dev, "ar9170.fw firmware file "
+			"not found and is required for this device\n");
+		ar9170_usb_firmware_failed(aru);
+		return;
+	}
+
+	dev_err(&aru->udev->dev, "ar9170.fw firmware file "
+		"not found, trying old firmware...\n");
+
+	err = request_firmware_nowait(THIS_MODULE, 1, "ar9170-1.fw",
+				      &aru->udev->dev, GFP_KERNEL, aru,
+				      ar9170_usb_firmware_inits);
+	if (err)
+		ar9170_usb_firmware_failed(aru);
+}
+
 static bool ar9170_requires_one_stage(const struct usb_device_id *id)
 {
 	if (!id->driver_info)
@@ -814,33 +874,9 @@ static int ar9170_usb_probe(struct usb_interface *intf,
 	if (err)
 		goto err_freehw;
 
-	err = ar9170_usb_request_firmware(aru);
-	if (err)
-		goto err_freehw;
-
-	err = ar9170_usb_init_device(aru);
-	if (err)
-		goto err_freefw;
-
-	err = ar9170_usb_open(ar);
-	if (err)
-		goto err_unrx;
-
-	err = ar9170_register(ar, &udev->dev);
-
-	ar9170_usb_stop(ar);
-	if (err)
-		goto err_unrx;
-
-	return 0;
-
-err_unrx:
-	ar9170_usb_cancel_urbs(aru);
-
-err_freefw:
-	release_firmware(aru->init_values);
-	release_firmware(aru->firmware);
-
+	return request_firmware_nowait(THIS_MODULE, 1, "ar9170.fw",
+				       &aru->udev->dev, GFP_KERNEL, aru,
+				       ar9170_usb_firmware_step2);
 err_freehw:
 	usb_set_intfdata(intf, NULL);
 	usb_put_dev(udev);
@@ -860,12 +896,12 @@ static void ar9170_usb_disconnect(struct usb_interface *intf)
 	ar9170_unregister(&aru->common);
 	ar9170_usb_cancel_urbs(aru);
 
-	release_firmware(aru->init_values);
-	release_firmware(aru->firmware);
-
 	usb_put_dev(aru->udev);
 	usb_set_intfdata(intf, NULL);
 	ieee80211_free_hw(aru->common.hw);
+
+	release_firmware(aru->init_values);
+	release_firmware(aru->firmware);
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index ac34a05..0e79e58 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -1323,7 +1323,7 @@ static void ath_rate_init(void *priv, struct ieee80211_supported_band *sband,
 
 static void ath_rate_update(void *priv, struct ieee80211_supported_band *sband,
 			    struct ieee80211_sta *sta, void *priv_sta,
-			    u32 changed)
+			    u32 changed, enum nl80211_channel_type oper_chan_type)
 {
 	struct ath_softc *sc = priv;
 	struct ath_rate_priv *ath_rc_priv = priv_sta;
@@ -1340,8 +1340,8 @@ static void ath_rate_update(void *priv, struct ieee80211_supported_band *sband,
 		if (sc->sc_ah->opmode != NL80211_IFTYPE_STATION)
 			return;
 
-		if (sc->hw->conf.channel_type == NL80211_CHAN_HT40MINUS ||
-		    sc->hw->conf.channel_type == NL80211_CHAN_HT40PLUS)
+		if (oper_chan_type == NL80211_CHAN_HT40MINUS ||
+		    oper_chan_type == NL80211_CHAN_HT40PLUS)
 			oper_cw40 = true;
 
 		oper_sgi40 = (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 47294f9..b2c8207 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2258,7 +2258,7 @@ void ath_tx_node_cleanup(struct ath_softc *sc, struct ath_node *an)
 		if (ATH_TXQ_SETUP(sc, i)) {
 			txq = &sc->tx.txq[i];
 
-			spin_lock(&txq->axq_lock);
+			spin_lock_bh(&txq->axq_lock);
 
 			list_for_each_entry_safe(ac,
 					ac_tmp, &txq->axq_acq, list) {
@@ -2279,7 +2279,7 @@ void ath_tx_node_cleanup(struct ath_softc *sc, struct ath_node *an)
 				}
 			}
 
-			spin_unlock(&txq->axq_lock);
+			spin_unlock_bh(&txq->axq_lock);
 		}
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 6aeb82b..47b0214 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1463,59 +1463,66 @@ static void iwl_nic_start(struct iwl_priv *priv)
 }
 
 
+static void iwl_ucode_callback(const struct firmware *ucode_raw, void *context);
+static int iwl_mac_setup_register(struct iwl_priv *priv);
+
+static int __must_check iwl_request_firmware(struct iwl_priv *priv, bool first)
+{
+	const char *name_pre = priv->cfg->fw_name_pre;
+
+	if (first)
+		priv->fw_index = priv->cfg->ucode_api_max;
+	else
+		priv->fw_index--;
+
+	if (priv->fw_index < priv->cfg->ucode_api_min) {
+		IWL_ERR(priv, "no suitable firmware found!\n");
+		return -ENOENT;
+	}
+
+	sprintf(priv->firmware_name, "%s%d%s",
+		name_pre, priv->fw_index, ".ucode");
+
+	IWL_DEBUG_INFO(priv, "attempting to load firmware '%s'\n",
+		       priv->firmware_name);
+
+	return request_firmware_nowait(THIS_MODULE, 1, priv->firmware_name,
+				       &priv->pci_dev->dev, GFP_KERNEL, priv,
+				       iwl_ucode_callback);
+}
+
 /**
- * iwl_read_ucode - Read uCode images from disk file.
+ * iwl_ucode_callback - callback when firmware was loaded
  *
- * Copy into buffers for card to fetch via bus-mastering
+ * If loaded successfully, copies the firmware into buffers
+ * for the card to fetch (via DMA).
  */
-static int iwl_read_ucode(struct iwl_priv *priv)
+static void iwl_ucode_callback(const struct firmware *ucode_raw, void *context)
 {
+	struct iwl_priv *priv = context;
 	struct iwl_ucode_header *ucode;
-	int ret = -EINVAL, index;
-	const struct firmware *ucode_raw;
-	const char *name_pre = priv->cfg->fw_name_pre;
 	const unsigned int api_max = priv->cfg->ucode_api_max;
 	const unsigned int api_min = priv->cfg->ucode_api_min;
-	char buf[25];
 	u8 *src;
 	size_t len;
 	u32 api_ver, build;
 	u32 inst_size, data_size, init_size, init_data_size, boot_size;
+	int err;
 	u16 eeprom_ver;
 
-	/* Ask kernel firmware_class module to get the boot firmware off disk.
-	 * request_firmware() is synchronous, file is in memory on return. */
-	for (index = api_max; index >= api_min; index--) {
-		sprintf(buf, "%s%d%s", name_pre, index, ".ucode");
-		ret = request_firmware(&ucode_raw, buf, &priv->pci_dev->dev);
-		if (ret < 0) {
-			IWL_ERR(priv, "%s firmware file req failed: %d\n",
-				  buf, ret);
-			if (ret == -ENOENT)
-				continue;
-			else
-				goto error;
-		} else {
-			if (index < api_max)
-				IWL_ERR(priv, "Loaded firmware %s, "
-					"which is deprecated. "
-					"Please use API v%u instead.\n",
-					  buf, api_max);
-
-			IWL_DEBUG_INFO(priv, "Got firmware '%s' file (%zd bytes) from disk\n",
-				       buf, ucode_raw->size);
-			break;
-		}
+	if (!ucode_raw) {
+		IWL_ERR(priv, "request for firmware file '%s' failed.\n",
+			priv->firmware_name);
+		goto try_again;
 	}
 
-	if (ret < 0)
-		goto error;
+	IWL_DEBUG_INFO(priv, "Loaded firmware file '%s' (%zd bytes).\n",
+		       priv->firmware_name, ucode_raw->size);
 
 	/* Make sure that we got at least the v1 header! */
 	if (ucode_raw->size < priv->cfg->ops->ucode->get_header_size(1)) {
 		IWL_ERR(priv, "File size way too small!\n");
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 
 	/* Data from ucode file:  header followed by uCode images */
@@ -1540,10 +1547,9 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 		IWL_ERR(priv, "Driver unable to support your firmware API. "
 			  "Driver supports v%u, firmware is v%u.\n",
 			  api_max, api_ver);
-		priv->ucode_ver = 0;
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
+
 	if (api_ver != api_max)
 		IWL_ERR(priv, "Firmware has old API version. Expected v%u, "
 			  "got v%u. New firmware can be obtained "
@@ -1585,6 +1591,12 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 	IWL_DEBUG_INFO(priv, "f/w package hdr boot inst size = %u\n",
 		       boot_size);
 
+	/*
+	 * For any of the failures below (before allocating pci memory)
+	 * we will try to load a version with a smaller API -- maybe the
+	 * user just got a corrupted version of the latest API.
+	 */
+
 	/* Verify size of file vs. image size info in file's header */
 	if (ucode_raw->size !=
 		priv->cfg->ops->ucode->get_header_size(api_ver) +
@@ -1594,41 +1606,35 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 		IWL_DEBUG_INFO(priv,
 			"uCode file size %d does not match expected size\n",
 			(int)ucode_raw->size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 
 	/* Verify that uCode images will fit in card's SRAM */
 	if (inst_size > priv->hw_params.max_inst_size) {
 		IWL_DEBUG_INFO(priv, "uCode instr len %d too large to fit in\n",
 			       inst_size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 
 	if (data_size > priv->hw_params.max_data_size) {
 		IWL_DEBUG_INFO(priv, "uCode data len %d too large to fit in\n",
 				data_size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 	if (init_size > priv->hw_params.max_inst_size) {
 		IWL_INFO(priv, "uCode init instr len %d too large to fit in\n",
 			init_size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 	if (init_data_size > priv->hw_params.max_data_size) {
 		IWL_INFO(priv, "uCode init data len %d too large to fit in\n",
 		      init_data_size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 	if (boot_size > priv->hw_params.max_bsm_size) {
 		IWL_INFO(priv, "uCode boot instr len %d too large to fit in\n",
 			boot_size);
-		ret = -EINVAL;
-		goto err_release;
+		goto try_again;
 	}
 
 	/* Allocate ucode buffers for card's bus-master loading ... */
@@ -1712,20 +1718,36 @@ static int iwl_read_ucode(struct iwl_priv *priv)
 	IWL_DEBUG_INFO(priv, "Copying (but not loading) boot instr len %Zd\n", len);
 	memcpy(priv->ucode_boot.v_addr, src, len);
 
+	/**************************************************
+	 * This is still part of probe() in a sense...
+	 *
+	 * 9. Setup and register with mac80211 and debugfs
+	 **************************************************/
+	err = iwl_mac_setup_register(priv);
+	if (err)
+		goto out_unbind;
+
+	err = iwl_dbgfs_register(priv, DRV_NAME);
+	if (err)
+		IWL_ERR(priv, "failed to create debugfs files. Ignoring error: %d\n", err);
+
 	/* We have our copies now, allow OS release its copies */
 	release_firmware(ucode_raw);
-	return 0;
+	return;
+
+ try_again:
+	/* try next, if any */
+	if (iwl_request_firmware(priv, false))
+		goto out_unbind;
+	release_firmware(ucode_raw);
+	return;
 
  err_pci_alloc:
 	IWL_ERR(priv, "failed to allocate pci memory\n");
-	ret = -ENOMEM;
 	iwl_dealloc_ucode_pci(priv);
-
- err_release:
+ out_unbind:
+	device_release_driver(&priv->pci_dev->dev);
 	release_firmware(ucode_raw);
-
- error:
-	return ret;
 }
 
 static const char *desc_lookup_text[] = {
@@ -2667,21 +2689,7 @@ static int iwl_mac_start(struct ieee80211_hw *hw)
 
 	/* we should be verifying the device is ready to be opened */
 	mutex_lock(&priv->mutex);
-
-	/* fetch ucode file from disk, alloc and copy to bus-master buffers ...
-	 * ucode filename and max sizes are card-specific. */
-
-	if (!priv->ucode_code.len) {
-		ret = iwl_read_ucode(priv);
-		if (ret) {
-			IWL_ERR(priv, "Could not read microcode: %d\n", ret);
-			mutex_unlock(&priv->mutex);
-			return ret;
-		}
-	}
-
 	ret = __iwl_up(priv);
-
 	mutex_unlock(&priv->mutex);
 
 	if (ret)
@@ -3654,17 +3662,10 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	iwl_power_initialize(priv);
 	iwl_tt_initialize(priv);
 
-	/**************************************************
-	 * 9. Setup and register with mac80211 and debugfs
-	 **************************************************/
-	err = iwl_mac_setup_register(priv);
+	err = iwl_request_firmware(priv, true);
 	if (err)
 		goto out_remove_sysfs;
 
-	err = iwl_dbgfs_register(priv, DRV_NAME);
-	if (err)
-		IWL_ERR(priv, "failed to create debugfs files. Ignoring error: %d\n", err);
-
 	return 0;
 
  out_remove_sysfs:
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index ab891b9..6054c5f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -1132,6 +1132,7 @@ struct iwl_priv {
 	u8   rev_id;
 
 	/* uCode images, save to reload in case of failure */
+	int fw_index;			/* firmware we're trying to load */
 	u32 ucode_ver;			/* version of ucode, copy of
 					   iwl_ucode.ver */
 	struct fw_desc ucode_code;	/* runtime inst */
@@ -1142,6 +1143,7 @@ struct iwl_priv {
 	struct fw_desc ucode_boot;	/* bootstrap inst */
 	enum ucode_type ucode_type;
 	u8 ucode_write_complete;	/* the image write is complete */
+	char firmware_name[25];
 
 
 	struct iwl_rxon_time_cmd rxon_timing;
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index aca8c12..91cce2d 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -1225,7 +1225,7 @@ MODULE_LICENSE("GPL");
 #ifdef CONFIG_RT2800PCI_SOC
 static int rt2800soc_probe(struct platform_device *pdev)
 {
-	return rt2x00soc_probe(pdev, rt2800pci_ops);
+	return rt2x00soc_probe(pdev, &rt2800pci_ops);
 }
 
 static struct platform_driver rt2800soc_driver = {
diff --git a/drivers/net/wireless/rt2x00/rt2x00soc.c b/drivers/net/wireless/rt2x00/rt2x00soc.c
index 4efdc96..111c0ff 100644
--- a/drivers/net/wireless/rt2x00/rt2x00soc.c
+++ b/drivers/net/wireless/rt2x00/rt2x00soc.c
@@ -112,6 +112,7 @@ exit_free_device:
 
 	return retval;
 }
+EXPORT_SYMBOL_GPL(rt2x00soc_probe);
 
 int rt2x00soc_remove(struct platform_device *pdev)
 {
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index f39a8ed..47f3e4a 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2352,6 +2352,8 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x0411, 0x00f4), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0411, 0x0116), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0411, 0x0119), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* CEIVA */
+	{ USB_DEVICE(0x178d, 0x02be), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* CNet */
 	{ USB_DEVICE(0x1371, 0x9022), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x1371, 0x9032), USB_DEVICE_DATA(&rt73usb_ops) },
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 2d555cc..e240996 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -350,7 +350,7 @@ static void zd_mac_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 	first_idx = info->status.rates[0].idx;
 	ZD_ASSERT(0<=first_idx && first_idx<ARRAY_SIZE(zd_retry_rates));
 	retries = &zd_retry_rates[first_idx];
-	ZD_ASSERT(0<=retry && retry<=retries->count);
+	ZD_ASSERT(1 <= retry && retry <= retries->count);
 
 	info->status.rates[0].idx = retries->rate[0];
 	info->status.rates[0].count = 1; // (retry > 1 ? 2 : 1);
@@ -360,7 +360,7 @@ static void zd_mac_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
 		info->status.rates[i].count = 1; // ((i==retry-1) && success ? 1:2);
 	}
 	for (; i<IEEE80211_TX_MAX_RATES && i<retry; i++) {
-		info->status.rates[i].idx = retries->rate[retry-1];
+		info->status.rates[i].idx = retries->rate[retry - 1];
 		info->status.rates[i].count = 1; // (success ? 1:2);
 	}
 	if (i<IEEE80211_TX_MAX_RATES)
@@ -424,12 +424,10 @@ void zd_mac_tx_failed(struct urb *urb)
 		first_idx = info->status.rates[0].idx;
 		ZD_ASSERT(0<=first_idx && first_idx<ARRAY_SIZE(zd_retry_rates));
 		retries = &zd_retry_rates[first_idx];
-		if (retry < 0 || retry > retries->count) {
+		if (retry <= 0 || retry > retries->count)
 			continue;
-		}
 
-		ZD_ASSERT(0<=retry && retry<=retries->count);
-		final_idx = retries->rate[retry-1];
+		final_idx = retries->rate[retry - 1];
 		final_rate = zd_rates[final_idx].hw_value;
 
 		if (final_rate != tx_status->rate) {
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index 97059d0..4f82326 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -29,7 +29,7 @@
 /**
  * enum rfkill_type - type of rfkill switch.
  *
- * @RFKILL_TYPE_ALL: toggles all switches (userspace only)
+ * @RFKILL_TYPE_ALL: toggles all switches (requests only - not a switch type)
  * @RFKILL_TYPE_WLAN: switch is on a 802.11 wireless network device.
  * @RFKILL_TYPE_BLUETOOTH: switch is on a bluetooth device.
  * @RFKILL_TYPE_UWB: switch is on a ultra wideband device.
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 80eb7cc..45d7d44 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -2426,7 +2426,8 @@ struct rate_control_ops {
 			  struct ieee80211_sta *sta, void *priv_sta);
 	void (*rate_update)(void *priv, struct ieee80211_supported_band *sband,
 			    struct ieee80211_sta *sta,
-			    void *priv_sta, u32 changed);
+			    void *priv_sta, u32 changed,
+			    enum nl80211_channel_type oper_chan_type);
 	void (*free_sta)(void *priv, struct ieee80211_sta *sta,
 			 void *priv_sta);
 
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 41812a1..0ab284c 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -177,7 +177,8 @@ static u32 ieee80211_enable_ht(struct ieee80211_sub_if_data *sdata,
 		sta = sta_info_get(sdata, bssid);
 		if (sta)
 			rate_control_rate_update(local, sband, sta,
-						 IEEE80211_RC_HT_CHANGED);
+						 IEEE80211_RC_HT_CHANGED,
+						 local->oper_channel_type);
 		rcu_read_unlock();
         }
 
@@ -1893,8 +1894,20 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data *sdata,
 
 	mutex_lock(&ifmgd->mtx);
 	if (ifmgd->associated) {
-		mutex_unlock(&ifmgd->mtx);
-		return -EALREADY;
+		if (!req->prev_bssid ||
+		    memcmp(req->prev_bssid, ifmgd->associated->bssid,
+			   ETH_ALEN)) {
+			/*
+			 * We are already associated and the request was not a
+			 * reassociation request from the current BSS, so
+			 * reject it.
+			 */
+			mutex_unlock(&ifmgd->mtx);
+			return -EALREADY;
+		}
+
+		/* Trying to reassociate - clear previous association state */
+		ieee80211_set_disassoc(sdata);
 	}
 	mutex_unlock(&ifmgd->mtx);
 
diff --git a/net/mac80211/rate.h b/net/mac80211/rate.h
index b6108bc..065a961 100644
--- a/net/mac80211/rate.h
+++ b/net/mac80211/rate.h
@@ -66,7 +66,8 @@ static inline void rate_control_rate_init(struct sta_info *sta)
 
 static inline void rate_control_rate_update(struct ieee80211_local *local,
 				    struct ieee80211_supported_band *sband,
-				    struct sta_info *sta, u32 changed)
+				    struct sta_info *sta, u32 changed,
+				    enum nl80211_channel_type oper_chan_type)
 {
 	struct rate_control_ref *ref = local->rate_ctrl;
 	struct ieee80211_sta *ista = &sta->sta;
@@ -74,7 +75,7 @@ static inline void rate_control_rate_update(struct ieee80211_local *local,
 
 	if (ref && ref->ops->rate_update)
 		ref->ops->rate_update(ref->priv, sband, ista,
-				      priv_sta, changed);
+				      priv_sta, changed, oper_chan_type);
 }
 
 static inline void *rate_control_alloc_sta(struct rate_control_ref *ref,
diff --git a/net/rfkill/input.c b/net/rfkill/input.c
index a7295ad..3713d7e 100644
--- a/net/rfkill/input.c
+++ b/net/rfkill/input.c
@@ -212,6 +212,9 @@ static void rfkill_event(struct input_handle *handle, unsigned int type,
 		case KEY_WIMAX:
 			rfkill_schedule_toggle(RFKILL_TYPE_WIMAX);
 			break;
+		case KEY_RFKILL:
+			rfkill_schedule_toggle(RFKILL_TYPE_ALL);
+			break;
 		}
 	} else if (type == EV_SW && code == SW_RFKILL_ALL)
 		rfkill_schedule_evsw_rfkillall(data);
@@ -295,6 +298,11 @@ static const struct input_device_id rfkill_ids[] = {
 		.keybit = { [BIT_WORD(KEY_WIMAX)] = BIT_MASK(KEY_WIMAX) },
 	},
 	{
+		.flags = INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_KEYBIT,
+		.evbit = { BIT_MASK(EV_KEY) },
+		.keybit = { [BIT_WORD(KEY_RFKILL)] = BIT_MASK(KEY_RFKILL) },
+	},
+	{
 		.flags = INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_SWBIT,
 		.evbit = { BIT(EV_SW) },
 		.swbit = { [BIT_WORD(SW_RFKILL_ALL)] = BIT_MASK(SW_RFKILL_ALL) },
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
