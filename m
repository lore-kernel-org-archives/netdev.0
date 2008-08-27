From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-08-26
Date: Tue, 26 Aug 2008 21:30:10 -0400
Message-ID: <20080827013009.GA15781@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46499 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbYH0Chp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 22:37:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is the latest round of fixes intended for 2.6.27.  I think
the non-iwlwifi ones are pretty solid.  As for the iwlwifi ones,
the Intel guys assure me that these are important changes.

You will notice that (despite my exhortations) no less than two of
the iwlwifi patches declare themselves as cleanups.  I have included
them anyway because the later fixes depend on them and they seemed
harmless enough.  Plus, they were posted (or at least written) before
the recent fireworks about what we should be merging after -rc1...

I have reiterated the "fixes only" rule to Zhu Yi and asked him to
pass that to the rest of his team.  I'm quite confident that he will
comply and in any event I intend this to be the last post -rc1 pull
request with cleanups from Intel (or anyone else) in it.

I would appreciate it if we could merge this request as-is.  If you
are not comfortable with that, then I would ask you to pull from the
'no-iwlwifi' branch instead.  In that case, at least we can get the
less questionable patches pushed upstream ASAP.

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit c2d42545774c4bba7232521d836d0793330e3a4e:
  Eilon Greenstein (1):
        bnx2x: Version update

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Assaf Krauss (1):
      iwlwifi: W/A for the TSF correction in IBSS

Dan Williams (2):
      atmel: return ENOENT on request_firmware failure
      atmel: try open system authentication too

Felipe Balbi (1):
      net: rfkill: add missing line break

Gregory Greenman (1):
      iwlwifi: call apm stop on exit

Jan-Espen Pettersen (1):
      mac80211: don't send empty extended rates IE

Jiri Slaby (2):
      Ath5k: lock beacons
      Ath5k: fix bintval setup

John W. Linville (1):
      mac80211: quiet chatty IBSS merge message

Jouni Malinen (2):
      mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM
      mac80211: Fix debugfs file add/del for netdev

Julia Lawall (1):
      net/mac80211/mesh.c: correct the argument to __mesh_table_free

Mohamed Abbas (2):
      iwlwifi: void full rxon on rx chain changes
      iwlwifi: fix apm_stop function

Ron Rindjunsky (3):
      iwlwifi: allow consecutive scans in unassociated state
      iwlwifi: fix hidden ssid discovery in passive channels
      iwlwifi: use station's mimo power save values

Tomas Winkler (6):
      iwlwifi: clean up hw scan handler
      iwlwifi: align set channel with mac80211
      iwlwifi: cleanup PCI register handling
      iwlwifi: generic init calibrations framework
      iwlwifi: fix rx_chain computation
      iwlwifi: fix 64bit platform firmware loading

 drivers/net/wireless/ath5k/base.c           |   23 ++++--
 drivers/net/wireless/ath5k/base.h           |    1 +
 drivers/net/wireless/atmel.c                |   51 ++++++++-----
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |   13 ++--
 drivers/net/wireless/iwlwifi/iwl-4965.c     |   10 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h  |    7 ++
 drivers/net/wireless/iwlwifi/iwl-5000.c     |   83 +++++----------------
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c   |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   83 ++++++++++++---------
 drivers/net/wireless/iwlwifi/iwl-calib.c    |   60 +++++++++++++++
 drivers/net/wireless/iwlwifi/iwl-commands.h |    4 +-
 drivers/net/wireless/iwlwifi/iwl-core.c     |  107 +++++++++++++--------------
 drivers/net/wireless/iwlwifi/iwl-core.h     |   12 ++-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |   15 ++--
 drivers/net/wireless/iwlwifi/iwl-fh.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-power.c    |   27 +++----
 drivers/net/wireless/iwlwifi/iwl-rx.c       |    5 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    2 +-
 net/mac80211/debugfs_netdev.c               |   24 +++---
 net/mac80211/ieee80211_i.h                  |    6 ++
 net/mac80211/mesh.c                         |    2 +-
 net/mac80211/mlme.c                         |   52 +++----------
 net/rfkill/rfkill.c                         |    2 +-
 23 files changed, 311 insertions(+), 282 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index b20a45a..0676c6d 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -251,7 +251,7 @@ static inline void ath5k_txbuf_free(struct ath5k_softc *sc,
 		return;
 	pci_unmap_single(sc->pdev, bf->skbaddr, bf->skb->len,
 			PCI_DMA_TODEVICE);
-	dev_kfree_skb(bf->skb);
+	dev_kfree_skb_any(bf->skb);
 	bf->skb = NULL;
 }
 
@@ -466,6 +466,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	mutex_init(&sc->lock);
 	spin_lock_init(&sc->rxbuflock);
 	spin_lock_init(&sc->txbuflock);
+	spin_lock_init(&sc->block);
 
 	/* Set private data */
 	pci_set_drvdata(pdev, hw);
@@ -2179,8 +2180,11 @@ ath5k_beacon_config(struct ath5k_softc *sc)
 
 		sc->imask |= AR5K_INT_SWBA;
 
-		if (ath5k_hw_hasveol(ah))
+		if (ath5k_hw_hasveol(ah)) {
+			spin_lock(&sc->block);
 			ath5k_beacon_send(sc);
+			spin_unlock(&sc->block);
+		}
 	}
 	/* TODO else AP */
 
@@ -2403,7 +2407,9 @@ ath5k_intr(int irq, void *dev_id)
 						  TSF_TO_TU(tsf),
 						  (unsigned long long) tsf);
 				} else {
+					spin_lock(&sc->block);
 					ath5k_beacon_send(sc);
+					spin_unlock(&sc->block);
 				}
 			}
 			if (status & AR5K_INT_RXEOL) {
@@ -2745,6 +2751,11 @@ static int ath5k_add_interface(struct ieee80211_hw *hw,
 		ret = -EOPNOTSUPP;
 		goto end;
 	}
+
+	/* Set to a reasonable value. Note that this will
+	 * be set to mac80211's value at ath5k_config(). */
+	sc->bintval = 1000;
+
 	ret = 0;
 end:
 	mutex_unlock(&sc->lock);
@@ -2789,9 +2800,6 @@ ath5k_config_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	struct ath5k_hw *ah = sc->ah;
 	int ret;
 
-	/* Set to a reasonable value. Note that this will
-	 * be set to mac80211's value at ath5k_config(). */
-	sc->bintval = 1000;
 	mutex_lock(&sc->lock);
 	if (sc->vif != vif) {
 		ret = -EIO;
@@ -3050,6 +3058,7 @@ static int
 ath5k_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb)
 {
 	struct ath5k_softc *sc = hw->priv;
+	unsigned long flags;
 	int ret;
 
 	ath5k_debug_dump_skb(sc, skb, "BC  ", 1);
@@ -3059,12 +3068,14 @@ ath5k_beacon_update(struct ieee80211_hw *hw, struct sk_buff *skb)
 		goto end;
 	}
 
+	spin_lock_irqsave(&sc->block, flags);
 	ath5k_txbuf_free(sc, sc->bbuf);
 	sc->bbuf->skb = skb;
 	ret = ath5k_beacon_setup(sc, sc->bbuf);
 	if (ret)
 		sc->bbuf->skb = NULL;
-	else {
+	spin_unlock_irqrestore(&sc->block, flags);
+	if (!ret) {
 		ath5k_beacon_config(sc);
 		mmiowb();
 	}
diff --git a/drivers/net/wireless/ath5k/base.h b/drivers/net/wireless/ath5k/base.h
index d7e03e6..7ec2f37 100644
--- a/drivers/net/wireless/ath5k/base.h
+++ b/drivers/net/wireless/ath5k/base.h
@@ -172,6 +172,7 @@ struct ath5k_softc {
 	struct tasklet_struct	txtq;		/* tx intr tasklet */
 	struct ath5k_led	tx_led;		/* tx led */
 
+	spinlock_t		block;		/* protects beacon */
 	struct ath5k_buf	*bbuf;		/* beacon buffer */
 	unsigned int		bhalq,		/* SW q for outgoing beacons */
 				bmisscount,	/* missed beacon transmits */
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index bd35bb0..bd65c48 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1304,7 +1304,7 @@ EXPORT_SYMBOL(atmel_open);
 int atmel_open(struct net_device *dev)
 {
 	struct atmel_private *priv = netdev_priv(dev);
-	int i, channel;
+	int i, channel, err;
 
 	/* any scheduled timer is no longer needed and might screw things up.. */
 	del_timer_sync(&priv->management_timer);
@@ -1328,8 +1328,9 @@ int atmel_open(struct net_device *dev)
 	priv->site_survey_state = SITE_SURVEY_IDLE;
 	priv->station_is_associated = 0;
 
-	if (!reset_atmel_card(dev))
-		return -EAGAIN;
+	err = reset_atmel_card(dev);
+	if (err)
+		return err;
 
 	if (priv->config_reg_domain) {
 		priv->reg_domain = priv->config_reg_domain;
@@ -3061,12 +3062,20 @@ static void authenticate(struct atmel_private *priv, u16 frame_len)
 	}
 
 	if (status == WLAN_STATUS_NOT_SUPPORTED_AUTH_ALG) {
-		/* Do opensystem first, then try sharedkey */
+		/* Flip back and forth between WEP auth modes until the max
+		 * authentication tries has been exceeded.
+		 */
 		if (system == WLAN_AUTH_OPEN) {
 			priv->CurrentAuthentTransactionSeqNum = 0x001;
 			priv->exclude_unencrypted = 1;
 			send_authentication_request(priv, WLAN_AUTH_SHARED_KEY, NULL, 0);
 			return;
+		} else if (   system == WLAN_AUTH_SHARED_KEY
+		           && priv->wep_is_on) {
+			priv->CurrentAuthentTransactionSeqNum = 0x001;
+			priv->exclude_unencrypted = 0;
+			send_authentication_request(priv, WLAN_AUTH_OPEN, NULL, 0);
+			return;
 		} else if (priv->connect_to_any_BSS) {
 			int bss_index;
 
@@ -3580,12 +3589,12 @@ static int atmel_wakeup_firmware(struct atmel_private *priv)
 
 	if (i == 0) {
 		printk(KERN_ALERT "%s: MAC failed to boot.\n", priv->dev->name);
-		return 0;
+		return -EIO;
 	}
 
 	if ((priv->host_info_base = atmel_read16(priv->dev, MR2)) == 0xffff) {
 		printk(KERN_ALERT "%s: card missing.\n", priv->dev->name);
-		return 0;
+		return -ENODEV;
 	}
 
 	/* now check for completion of MAC initialization through
@@ -3609,19 +3618,19 @@ static int atmel_wakeup_firmware(struct atmel_private *priv)
 	if (i == 0) {
 		printk(KERN_ALERT "%s: MAC failed to initialise.\n",
 				priv->dev->name);
-		return 0;
+		return -EIO;
 	}
 
 	/* Check for MAC_INIT_OK only on the register that the MAC_INIT_OK was set */
 	if ((mr3 & MAC_INIT_COMPLETE) &&
 	    !(atmel_read16(priv->dev, MR3) & MAC_INIT_OK)) {
 		printk(KERN_ALERT "%s: MAC failed MR3 self-test.\n", priv->dev->name);
-		return 0;
+		return -EIO;
 	}
 	if ((mr1 & MAC_INIT_COMPLETE) &&
 	    !(atmel_read16(priv->dev, MR1) & MAC_INIT_OK)) {
 		printk(KERN_ALERT "%s: MAC failed MR1 self-test.\n", priv->dev->name);
-		return 0;
+		return -EIO;
 	}
 
 	atmel_copy_to_host(priv->dev, (unsigned char *)iface,
@@ -3642,7 +3651,7 @@ static int atmel_wakeup_firmware(struct atmel_private *priv)
 	iface->func_ctrl = le16_to_cpu(iface->func_ctrl);
 	iface->mac_status = le16_to_cpu(iface->mac_status);
 
-	return 1;
+	return 0;
 }
 
 /* determine type of memory and MAC address */
@@ -3693,7 +3702,7 @@ static int probe_atmel_card(struct net_device *dev)
 		/* Standard firmware in flash, boot it up and ask
 		   for the Mac Address */
 		priv->card_type = CARD_TYPE_SPI_FLASH;
-		if (atmel_wakeup_firmware(priv)) {
+		if (atmel_wakeup_firmware(priv) == 0) {
 			atmel_get_mib(priv, Mac_Address_Mib_Type, 0, dev->dev_addr, 6);
 
 			/* got address, now squash it again until the network
@@ -3835,6 +3844,7 @@ static int reset_atmel_card(struct net_device *dev)
 	struct atmel_private *priv = netdev_priv(dev);
 	u8 configuration;
 	int old_state = priv->station_state;
+	int err = 0;
 
 	/* data to add to the firmware names, in priority order
 	   this implemenents firmware versioning */
@@ -3868,11 +3878,12 @@ static int reset_atmel_card(struct net_device *dev)
 					       dev->name);
 					strcpy(priv->firmware_id, "atmel_at76c502.bin");
 				}
-				if (request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev) != 0) {
+				err = request_firmware(&fw_entry, priv->firmware_id, priv->sys_dev);
+				if (err != 0) {
 					printk(KERN_ALERT
 					       "%s: firmware %s is missing, cannot continue.\n",
 					       dev->name, priv->firmware_id);
-					return 0;
+					return err;
 				}
 			} else {
 				int fw_index = 0;
@@ -3901,7 +3912,7 @@ static int reset_atmel_card(struct net_device *dev)
 					       "%s: firmware %s is missing, cannot start.\n",
 					       dev->name, priv->firmware_id);
 					priv->firmware_id[0] = '\0';
-					return 0;
+					return -ENOENT;
 				}
 			}
 
@@ -3926,8 +3937,9 @@ static int reset_atmel_card(struct net_device *dev)
 			release_firmware(fw_entry);
 	}
 
-	if (!atmel_wakeup_firmware(priv))
-		return 0;
+	err = atmel_wakeup_firmware(priv);
+	if (err != 0)
+		return err;
 
 	/* Check the version and set the correct flag for wpa stuff,
 	   old and new firmware is incompatible.
@@ -3968,10 +3980,9 @@ static int reset_atmel_card(struct net_device *dev)
 	if (!priv->radio_on_broken) {
 		if (atmel_send_command_wait(priv, CMD_EnableRadio, NULL, 0) ==
 		    CMD_STATUS_REJECTED_RADIO_OFF) {
-			printk(KERN_INFO
-			       "%s: cannot turn the radio on. (Hey radio, you're beautiful!)\n",
+			printk(KERN_INFO "%s: cannot turn the radio on.\n",
 			       dev->name);
-                        return 0;
+                        return -EIO;
 		}
 	}
 
@@ -4006,7 +4017,7 @@ static int reset_atmel_card(struct net_device *dev)
 		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
 	}
 
-	return 1;
+	return 0;
 }
 
 static void atmel_send_command(struct atmel_private *priv, int command,
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h b/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
index fce950f..f4793a6 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
@@ -98,16 +98,17 @@
 #define IWL_RSSI_OFFSET	44
 
 
-#include "iwl-commands.h"
 
 /* PCI registers */
-#define PCI_LINK_CTRL      0x0F0	/* 1 byte */
-#define PCI_POWER_SOURCE   0x0C8
-#define PCI_REG_WUM8       0x0E8
+#define PCI_CFG_RETRY_TIMEOUT	0x041
+#define PCI_CFG_POWER_SOURCE	0x0C8
+#define PCI_REG_WUM8		0x0E8
+#define PCI_CFG_LINK_CTRL	0x0F0
 
 /* PCI register values */
-#define PCI_LINK_VAL_L0S_EN	0x01
-#define PCI_LINK_VAL_L1_EN	0x02
+#define PCI_CFG_LINK_CTRL_VAL_L0S_EN	0x01
+#define PCI_CFG_LINK_CTRL_VAL_L1_EN	0x02
+#define PCI_CFG_CMD_REG_INT_DIS_MSK	0x04
 #define PCI_CFG_PMC_PME_FROM_D3COLD_SUPPORT         (0x80000000)
 
 #define TFD_QUEUE_SIZE_MAX      (256)
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index e258122..d9c4fdb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -399,7 +399,7 @@ static void iwl4965_nic_config(struct iwl_priv *priv)
 	unsigned long flags;
 	u32 val;
 	u16 radio_cfg;
-	u8 val_link;
+	u16 link;
 
 	spin_lock_irqsave(&priv->lock, flags);
 
@@ -410,10 +410,10 @@ static void iwl4965_nic_config(struct iwl_priv *priv)
 				       val & ~(1 << 11));
 	}
 
-	pci_read_config_byte(priv->pci_dev, PCI_LINK_CTRL, &val_link);
+	pci_read_config_word(priv->pci_dev, PCI_CFG_LINK_CTRL, &link);
 
 	/* L1 is enabled by BIOS */
-	if ((val_link & PCI_LINK_VAL_L1_EN) == PCI_LINK_VAL_L1_EN)
+	if ((link & PCI_CFG_LINK_CTRL_VAL_L1_EN) == PCI_CFG_LINK_CTRL_VAL_L1_EN)
 		/* diable L0S disabled L1A enabled */
 		iwl_set_bit(priv, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
 	else
@@ -474,8 +474,8 @@ static void iwl4965_apm_stop(struct iwl_priv *priv)
 	iwl_set_bit(priv, CSR_RESET, CSR_RESET_REG_FLAG_SW_RESET);
 
 	udelay(10);
-
-	iwl_set_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
+	/* clear "init complete"  move adapter D0A* --> D0U state */
+	iwl_clear_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000-hw.h b/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
index 17d4f31..c479ee2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-5000-hw.h
@@ -129,6 +129,13 @@ struct iwl5000_shared {
 	__le32 padding2;
 } __attribute__ ((packed));
 
+/* calibrations defined for 5000 */
+/* defines the order in which results should be sent to the runtime uCode */
+enum iwl5000_calib {
+	IWL5000_CALIB_LO,
+	IWL5000_CALIB_TX_IQ,
+	IWL5000_CALIB_TX_IQ_PERD,
+};
 
 #endif /* __iwl_5000_hw_h__ */
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index cbc01a0..cccd84c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -145,7 +145,8 @@ static void iwl5000_apm_stop(struct iwl_priv *priv)
 
 	udelay(10);
 
-	iwl_set_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
+	/* clear "init complete"  move adapter D0A* --> D0U state */
+	iwl_clear_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
@@ -208,14 +209,14 @@ static void iwl5000_nic_config(struct iwl_priv *priv)
 {
 	unsigned long flags;
 	u16 radio_cfg;
-	u8 val_link;
+	u16 link;
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	pci_read_config_byte(priv->pci_dev, PCI_LINK_CTRL, &val_link);
+	pci_read_config_word(priv->pci_dev, PCI_CFG_LINK_CTRL, &link);
 
 	/* L1 is enabled by BIOS */
-	if ((val_link & PCI_LINK_VAL_L1_EN) == PCI_LINK_VAL_L1_EN)
+	if ((link & PCI_CFG_LINK_CTRL_VAL_L1_EN) == PCI_CFG_LINK_CTRL_VAL_L1_EN)
 		/* diable L0S disabled L1A enabled */
 		iwl_set_bit(priv, CSR_GIO_REG, CSR_GIO_REG_VAL_L0S_ENABLED);
 	else
@@ -444,48 +445,6 @@ static int iwl5000_send_Xtal_calib(struct iwl_priv *priv)
 				sizeof(cal_cmd), &cal_cmd);
 }
 
-static int iwl5000_send_calib_results(struct iwl_priv *priv)
-{
-	int ret = 0;
-
-	struct iwl_host_cmd hcmd = {
-		.id = REPLY_PHY_CALIBRATION_CMD,
-		.meta.flags = CMD_SIZE_HUGE,
-	};
-
-	if (priv->calib_results.lo_res) {
-		hcmd.len = priv->calib_results.lo_res_len;
-		hcmd.data = priv->calib_results.lo_res;
-		ret = iwl_send_cmd_sync(priv, &hcmd);
-
-		if (ret)
-			goto err;
-	}
-
-	if (priv->calib_results.tx_iq_res) {
-		hcmd.len = priv->calib_results.tx_iq_res_len;
-		hcmd.data = priv->calib_results.tx_iq_res;
-		ret = iwl_send_cmd_sync(priv, &hcmd);
-
-		if (ret)
-			goto err;
-	}
-
-	if (priv->calib_results.tx_iq_perd_res) {
-		hcmd.len = priv->calib_results.tx_iq_perd_res_len;
-		hcmd.data = priv->calib_results.tx_iq_perd_res;
-		ret = iwl_send_cmd_sync(priv, &hcmd);
-
-		if (ret)
-			goto err;
-	}
-
-	return 0;
-err:
-	IWL_ERROR("Error %d\n", ret);
-	return ret;
-}
-
 static int iwl5000_send_calib_cfg(struct iwl_priv *priv)
 {
 	struct iwl5000_calib_cfg_cmd calib_cfg_cmd;
@@ -510,33 +469,30 @@ static void iwl5000_rx_calib_result(struct iwl_priv *priv,
 	struct iwl_rx_packet *pkt = (void *)rxb->skb->data;
 	struct iwl5000_calib_hdr *hdr = (struct iwl5000_calib_hdr *)pkt->u.raw;
 	int len = le32_to_cpu(pkt->len) & FH_RSCSR_FRAME_SIZE_MSK;
-
-	iwl_free_calib_results(priv);
+	int index;
 
 	/* reduce the size of the length field itself */
 	len -= 4;
 
+	/* Define the order in which the results will be sent to the runtime
+	 * uCode. iwl_send_calib_results sends them in a row according to their
+	 * index. We sort them here */
 	switch (hdr->op_code) {
 	case IWL5000_PHY_CALIBRATE_LO_CMD:
-		priv->calib_results.lo_res = kzalloc(len, GFP_ATOMIC);
-		priv->calib_results.lo_res_len = len;
-		memcpy(priv->calib_results.lo_res, pkt->u.raw, len);
+		index = IWL5000_CALIB_LO;
 		break;
 	case IWL5000_PHY_CALIBRATE_TX_IQ_CMD:
-		priv->calib_results.tx_iq_res = kzalloc(len, GFP_ATOMIC);
-		priv->calib_results.tx_iq_res_len = len;
-		memcpy(priv->calib_results.tx_iq_res, pkt->u.raw, len);
+		index = IWL5000_CALIB_TX_IQ;
 		break;
 	case IWL5000_PHY_CALIBRATE_TX_IQ_PERD_CMD:
-		priv->calib_results.tx_iq_perd_res = kzalloc(len, GFP_ATOMIC);
-		priv->calib_results.tx_iq_perd_res_len = len;
-		memcpy(priv->calib_results.tx_iq_perd_res, pkt->u.raw, len);
+		index = IWL5000_CALIB_TX_IQ_PERD;
 		break;
 	default:
 		IWL_ERROR("Unknown calibration notification %d\n",
 			  hdr->op_code);
 		return;
 	}
+	iwl_calib_set(&priv->calib_results[index], pkt->u.raw, len);
 }
 
 static void iwl5000_rx_calib_complete(struct iwl_priv *priv,
@@ -577,14 +533,11 @@ static int iwl5000_load_section(struct iwl_priv *priv,
 		FH_TFDIB_CTRL0_REG(FH_SRVC_CHNL),
 		phy_addr & FH_MEM_TFDIB_DRAM_ADDR_LSB_MSK);
 
-	/* FIME: write the MSB of the phy_addr in CTRL1
-	 * iwl_write_direct32(priv,
-		IWL_FH_TFDIB_CTRL1_REG(IWL_FH_SRVC_CHNL),
-		((phy_addr & MSB_MSK)
-			<< FH_MEM_TFDIB_REG1_ADDR_BITSHIFT) | byte_count);
-	 */
 	iwl_write_direct32(priv,
-		FH_TFDIB_CTRL1_REG(FH_SRVC_CHNL), byte_cnt);
+		FH_TFDIB_CTRL1_REG(FH_SRVC_CHNL),
+		(iwl_get_dma_hi_address(phy_addr)
+			<< FH_MEM_TFDIB_REG1_ADDR_BITSHIFT) | byte_cnt);
+
 	iwl_write_direct32(priv,
 		FH_TCSR_CHNL_TX_BUF_STS_REG(FH_SRVC_CHNL),
 		1 << FH_TCSR_CHNL_TX_BUF_STS_REG_POS_TB_NUM |
@@ -834,7 +787,7 @@ static int iwl5000_alive_notify(struct iwl_priv *priv)
 	iwl5000_send_Xtal_calib(priv);
 
 	if (priv->ucode_type == UCODE_RT)
-		iwl5000_send_calib_results(priv);
+		iwl_send_calib_results(priv);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 754fef5..90a2b6d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -1153,7 +1153,8 @@ static int rs_switch_to_mimo2(struct iwl_priv *priv,
 	    !sta->ht_info.ht_supported)
 		return -1;
 
-	if (priv->current_ht_config.tx_mimo_ps_mode == IWL_MIMO_PS_STATIC)
+	if (((sta->ht_info.cap & IEEE80211_HT_CAP_MIMO_PS) >> 2)
+						== IWL_MIMO_PS_STATIC)
 		return -1;
 
 	/* Need both Tx chains/antennas to support MIMO */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 061ffba..be5637c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -181,14 +181,14 @@ static int iwl4965_check_rxon_cmd(struct iwl_rxon_cmd *rxon)
 }
 
 /**
- * iwl4965_full_rxon_required - check if full RXON (vs RXON_ASSOC) cmd is needed
+ * iwl_full_rxon_required - check if full RXON (vs RXON_ASSOC) cmd is needed
  * @priv: staging_rxon is compared to active_rxon
  *
  * If the RXON structure is changing enough to require a new tune,
  * or is clearing the RXON_FILTER_ASSOC_MSK, then return 1 to indicate that
  * a new tune (full RXON command, rather than RXON_ASSOC cmd) is required.
  */
-static int iwl4965_full_rxon_required(struct iwl_priv *priv)
+static int iwl_full_rxon_required(struct iwl_priv *priv)
 {
 
 	/* These items are only settable from the full RXON command */
@@ -207,7 +207,6 @@ static int iwl4965_full_rxon_required(struct iwl_priv *priv)
 	     priv->active_rxon.ofdm_ht_single_stream_basic_rates) ||
 	    (priv->staging_rxon.ofdm_ht_dual_stream_basic_rates !=
 	     priv->active_rxon.ofdm_ht_dual_stream_basic_rates) ||
-	    (priv->staging_rxon.rx_chain != priv->active_rxon.rx_chain) ||
 	    (priv->staging_rxon.assoc_id != priv->active_rxon.assoc_id))
 		return 1;
 
@@ -263,7 +262,7 @@ static int iwl4965_commit_rxon(struct iwl_priv *priv)
 	/* If we don't need to send a full RXON, we can use
 	 * iwl4965_rxon_assoc_cmd which is used to reconfigure filter
 	 * and other flags for the current radio configuration. */
-	if (!iwl4965_full_rxon_required(priv)) {
+	if (!iwl_full_rxon_required(priv)) {
 		ret = iwl_send_rxon_assoc(priv);
 		if (ret) {
 			IWL_ERROR("Error setting RXON_ASSOC (%d)\n", ret);
@@ -587,8 +586,6 @@ static void iwl4965_ht_conf(struct iwl_priv *priv,
 		iwl_conf->supported_chan_width = 0;
 	}
 
-	iwl_conf->tx_mimo_ps_mode =
-		(u8)((ht_conf->cap & IEEE80211_HT_CAP_MIMO_PS) >> 2);
 	memcpy(iwl_conf->supp_mcs_set, ht_conf->supp_mcs_set, 16);
 
 	iwl_conf->control_channel = ht_bss_conf->primary_channel;
@@ -1273,7 +1270,7 @@ int iwl4965_set_pwr_src(struct iwl_priv *priv, enum iwl_pwr_src src)
 
 	if (src == IWL_PWR_SRC_VAUX) {
 		u32 val;
-		ret = pci_read_config_dword(priv->pci_dev, PCI_POWER_SOURCE,
+		ret = pci_read_config_dword(priv->pci_dev, PCI_CFG_POWER_SOURCE,
 					    &val);
 
 		if (val & PCI_CFG_PMC_PME_FROM_D3COLD_SUPPORT)
@@ -2190,7 +2187,10 @@ static void __iwl4965_down(struct iwl_priv *priv)
 	udelay(5);
 
 	/* FIXME: apm_ops.suspend(priv) */
-	priv->cfg->ops->lib->apm_ops.reset(priv);
+	if (exit_pending || test_bit(STATUS_IN_SUSPEND, &priv->status))
+		priv->cfg->ops->lib->apm_ops.stop(priv);
+	else
+		priv->cfg->ops->lib->apm_ops.reset(priv);
 	priv->cfg->ops->lib->free_shared_mem(priv);
 
  exit:
@@ -2602,6 +2602,7 @@ static int iwl4965_mac_start(struct ieee80211_hw *hw)
 {
 	struct iwl_priv *priv = hw->priv;
 	int ret;
+	u16 pci_cmd;
 
 	IWL_DEBUG_MAC80211("enter\n");
 
@@ -2612,6 +2613,13 @@ static int iwl4965_mac_start(struct ieee80211_hw *hw)
 	pci_restore_state(priv->pci_dev);
 	pci_enable_msi(priv->pci_dev);
 
+	/* enable interrupts if needed: hw bug w/a */
+	pci_read_config_word(priv->pci_dev, PCI_COMMAND, &pci_cmd);
+	if (pci_cmd & PCI_COMMAND_INTX_DISABLE) {
+		pci_cmd &= ~PCI_COMMAND_INTX_DISABLE;
+		pci_write_config_word(priv->pci_dev, PCI_COMMAND, pci_cmd);
+	}
+
 	ret = request_irq(priv->pci_dev->irq, iwl4965_isr, IRQF_SHARED,
 			  DRV_NAME, priv);
 	if (ret) {
@@ -2843,7 +2851,7 @@ static int iwl4965_mac_config(struct ieee80211_hw *hw, struct ieee80211_conf *co
 	)
 		priv->staging_rxon.flags = 0;
 
-	iwl_set_rxon_channel(priv, conf->channel->band, channel);
+	iwl_set_rxon_channel(priv, conf->channel);
 
 	iwl_set_flags_for_band(priv, conf->channel->band);
 
@@ -3181,9 +3189,9 @@ static void iwl4965_bss_info_changed(struct ieee80211_hw *hw,
 
 }
 
-static int iwl4965_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
+static int iwl_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t ssid_len)
 {
-	int rc = 0;
+	int ret;
 	unsigned long flags;
 	struct iwl_priv *priv = hw->priv;
 
@@ -3193,41 +3201,40 @@ static int iwl4965_mac_hw_scan(struct ieee80211_hw *hw, u8 *ssid, size_t len)
 	spin_lock_irqsave(&priv->lock, flags);
 
 	if (!iwl_is_ready_rf(priv)) {
-		rc = -EIO;
+		ret = -EIO;
 		IWL_DEBUG_MAC80211("leave - not ready or exit pending\n");
 		goto out_unlock;
 	}
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_AP) {	/* APs don't scan */
-		rc = -EIO;
+		ret = -EIO;
 		IWL_ERROR("ERROR: APs don't scan\n");
 		goto out_unlock;
 	}
 
 	/* we don't schedule scan within next_scan_jiffies period */
 	if (priv->next_scan_jiffies &&
-			time_after(priv->next_scan_jiffies, jiffies)) {
-		rc = -EAGAIN;
+	    time_after(priv->next_scan_jiffies, jiffies)) {
+		IWL_DEBUG_SCAN("scan rejected: within next scan period\n");
+		ret = -EAGAIN;
 		goto out_unlock;
 	}
 	/* if we just finished scan ask for delay */
-	if (priv->last_scan_jiffies && time_after(priv->last_scan_jiffies +
-				IWL_DELAY_NEXT_SCAN, jiffies)) {
-		rc = -EAGAIN;
+	if (iwl_is_associated(priv) && priv->last_scan_jiffies &&
+	    time_after(priv->last_scan_jiffies + IWL_DELAY_NEXT_SCAN, jiffies)) {
+		IWL_DEBUG_SCAN("scan rejected: within previous scan period\n");
+		ret = -EAGAIN;
 		goto out_unlock;
 	}
-	if (len) {
-		IWL_DEBUG_SCAN("direct scan for %s [%d]\n ",
-			       iwl_escape_essid(ssid, len), (int)len);
-
+	if (ssid_len) {
 		priv->one_direct_scan = 1;
-		priv->direct_ssid_len = (u8)
-		    min((u8) len, (u8) IW_ESSID_MAX_SIZE);
+		priv->direct_ssid_len =  min_t(u8, ssid_len, IW_ESSID_MAX_SIZE);
 		memcpy(priv->direct_ssid, ssid, priv->direct_ssid_len);
-	} else
+	} else {
 		priv->one_direct_scan = 0;
+	}
 
-	rc = iwl_scan_initiate(priv);
+	ret = iwl_scan_initiate(priv);
 
 	IWL_DEBUG_MAC80211("leave\n");
 
@@ -3235,7 +3242,7 @@ out_unlock:
 	spin_unlock_irqrestore(&priv->lock, flags);
 	mutex_unlock(&priv->mutex);
 
-	return rc;
+	return ret;
 }
 
 static void iwl4965_mac_update_tkip_key(struct ieee80211_hw *hw,
@@ -3580,7 +3587,7 @@ static int iwl4965_mac_beacon_update(struct ieee80211_hw *hw, struct sk_buff *sk
 
 	priv->assoc_id = 0;
 	timestamp = ((struct ieee80211_mgmt *)skb->data)->u.beacon.timestamp;
-	priv->timestamp = le64_to_cpu(timestamp) +  (priv->beacon_int * 1000);
+	priv->timestamp = le64_to_cpu(timestamp);
 
 	IWL_DEBUG_MAC80211("leave\n");
 	spin_unlock_irqrestore(&priv->lock, flags);
@@ -4142,7 +4149,7 @@ static struct ieee80211_ops iwl4965_hw_ops = {
 	.reset_tsf = iwl4965_mac_reset_tsf,
 	.bss_info_changed = iwl4965_bss_info_changed,
 	.ampdu_action = iwl4965_mac_ampdu_action,
-	.hw_scan = iwl4965_mac_hw_scan
+	.hw_scan = iwl_mac_hw_scan
 };
 
 static int iwl4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -4217,9 +4224,6 @@ static int iwl4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 
 	pci_set_drvdata(pdev, priv);
 
-	/* We disable the RETRY_TIMEOUT register (0x41) to keep
-	 * PCI Tx retries from interfering with C3 CPU state */
-	pci_write_config_byte(pdev, 0x41, 0x00);
 
 	/***********************
 	 * 3. Read REV register
@@ -4239,6 +4243,10 @@ static int iwl4965_pci_probe(struct pci_dev *pdev, const struct pci_device_id *e
 		": Detected Intel Wireless WiFi Link %s REV=0x%X\n",
 		priv->cfg->name, priv->hw_rev);
 
+	/* We disable the RETRY_TIMEOUT register (0x41) to keep
+	 * PCI Tx retries from interfering with C3 CPU state */
+	pci_write_config_byte(pdev, PCI_CFG_RETRY_TIMEOUT, 0x00);
+
 	/* amp init */
 	err = priv->cfg->ops->lib->apm_ops.init(priv);
 	if (err < 0) {
@@ -4364,15 +4372,18 @@ static void __devexit iwl4965_pci_remove(struct pci_dev *pdev)
 	iwl_dbgfs_unregister(priv);
 	sysfs_remove_group(&pdev->dev.kobj, &iwl4965_attribute_group);
 
+	/* ieee80211_unregister_hw call wil cause iwl4965_mac_stop to
+	 * to be called and iwl4965_down since we are removing the device
+	 * we need to set STATUS_EXIT_PENDING bit.
+	 */
+	set_bit(STATUS_EXIT_PENDING, &priv->status);
 	if (priv->mac80211_registered) {
 		ieee80211_unregister_hw(priv->hw);
 		priv->mac80211_registered = 0;
+	} else {
+		iwl4965_down(priv);
 	}
 
-	set_bit(STATUS_EXIT_PENDING, &priv->status);
-
-	iwl4965_down(priv);
-
 	/* make sure we flush any pending irq or
 	 * tasklet for the driver
 	 */
diff --git a/drivers/net/wireless/iwlwifi/iwl-calib.c b/drivers/net/wireless/iwlwifi/iwl-calib.c
index ef49440..35fb4a4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-calib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-calib.c
@@ -66,6 +66,66 @@
 #include "iwl-core.h"
 #include "iwl-calib.h"
 
+/*****************************************************************************
+ * INIT calibrations framework
+ *****************************************************************************/
+
+ int iwl_send_calib_results(struct iwl_priv *priv)
+{
+	int ret = 0;
+	int i = 0;
+
+	struct iwl_host_cmd hcmd = {
+		.id = REPLY_PHY_CALIBRATION_CMD,
+		.meta.flags = CMD_SIZE_HUGE,
+	};
+
+	for (i = 0; i < IWL_CALIB_MAX; i++)
+		if (priv->calib_results[i].buf) {
+			hcmd.len = priv->calib_results[i].buf_len;
+			hcmd.data = priv->calib_results[i].buf;
+			ret = iwl_send_cmd_sync(priv, &hcmd);
+			if (ret)
+				goto err;
+		}
+
+	return 0;
+err:
+	IWL_ERROR("Error %d iteration %d\n", ret, i);
+	return ret;
+}
+EXPORT_SYMBOL(iwl_send_calib_results);
+
+int iwl_calib_set(struct iwl_calib_result *res, const u8 *buf, int len)
+{
+	if (res->buf_len != len) {
+		kfree(res->buf);
+		res->buf = kzalloc(len, GFP_ATOMIC);
+	}
+	if (unlikely(res->buf == NULL))
+		return -ENOMEM;
+
+	res->buf_len = len;
+	memcpy(res->buf, buf, len);
+	return 0;
+}
+EXPORT_SYMBOL(iwl_calib_set);
+
+void iwl_calib_free_results(struct iwl_priv *priv)
+{
+	int i;
+
+	for (i = 0; i < IWL_CALIB_MAX; i++) {
+		kfree(priv->calib_results[i].buf);
+		priv->calib_results[i].buf = NULL;
+		priv->calib_results[i].buf_len = 0;
+	}
+}
+
+/*****************************************************************************
+ * RUNTIME calibrations framework
+ *****************************************************************************/
+
 /* "false alarms" are signals that our DSP tries to lock onto,
  *   but then determines that they are either noise, or transmissions
  *   from a distant wireless network (also "noise", really) that get
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index 28b5b09..fbd8cc1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -2026,8 +2026,8 @@ struct iwl4965_spectrum_notification {
  *   bit 2 - '0' PM have to walk up every DTIM
  *           '1' PM could sleep over DTIM till listen Interval.
  * PCI power managed
- *   bit 3 - '0' (PCI_LINK_CTRL & 0x1)
- *           '1' !(PCI_LINK_CTRL & 0x1)
+ *   bit 3 - '0' (PCI_CFG_LINK_CTRL & 0x1)
+ *           '1' !(PCI_CFG_LINK_CTRL & 0x1)
  * Force sleep Modes
  *   bit 31/30- '00' use both mac/xtal sleeps
  *              '01' force Mac sleep
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index c72f725..a3b496e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -592,12 +592,11 @@ static void iwlcore_free_geos(struct iwl_priv *priv)
 	clear_bit(STATUS_GEO_CONFIGURED, &priv->status);
 }
 
-static u8 is_single_rx_stream(struct iwl_priv *priv)
+static bool is_single_rx_stream(struct iwl_priv *priv)
 {
 	return !priv->current_ht_config.is_ht ||
 	       ((priv->current_ht_config.supp_mcs_set[1] == 0) &&
-		(priv->current_ht_config.supp_mcs_set[2] == 0)) ||
-	       priv->ps_mode == IWL_MIMO_PS_STATIC;
+		(priv->current_ht_config.supp_mcs_set[2] == 0));
 }
 
 static u8 iwl_is_channel_extension(struct iwl_priv *priv,
@@ -704,33 +703,39 @@ EXPORT_SYMBOL(iwl_set_rxon_ht);
  * MIMO (dual stream) requires at least 2, but works better with 3.
  * This does not determine *which* chains to use, just how many.
  */
-static int iwlcore_get_rx_chain_counter(struct iwl_priv *priv,
-					u8 *idle_state, u8 *rx_state)
+static int iwl_get_active_rx_chain_count(struct iwl_priv *priv)
 {
-	u8 is_single = is_single_rx_stream(priv);
-	u8 is_cam = test_bit(STATUS_POWER_PMI, &priv->status) ? 0 : 1;
+	bool is_single = is_single_rx_stream(priv);
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
 
 	/* # of Rx chains to use when expecting MIMO. */
 	if (is_single || (!is_cam && (priv->ps_mode == IWL_MIMO_PS_STATIC)))
-		*rx_state = 2;
+		return 2;
 	else
-		*rx_state = 3;
+		return 3;
+}
 
+static int iwl_get_idle_rx_chain_count(struct iwl_priv *priv, int active_cnt)
+{
+	int idle_cnt;
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
 	/* # Rx chains when idling and maybe trying to save power */
 	switch (priv->ps_mode) {
 	case IWL_MIMO_PS_STATIC:
 	case IWL_MIMO_PS_DYNAMIC:
-		*idle_state = (is_cam) ? 2 : 1;
+		idle_cnt = (is_cam) ? 2 : 1;
 		break;
 	case IWL_MIMO_PS_NONE:
-		*idle_state = (is_cam) ? *rx_state : 1;
+		idle_cnt = (is_cam) ? active_cnt : 1;
 		break;
+	case IWL_MIMO_PS_INVALID:
 	default:
-		*idle_state = 1;
+		IWL_ERROR("invalide mimo ps mode %d\n", priv->ps_mode);
+		WARN_ON(1);
+		idle_cnt = -1;
 		break;
 	}
-
-	return 0;
+	return idle_cnt;
 }
 
 /**
@@ -741,39 +746,49 @@ static int iwlcore_get_rx_chain_counter(struct iwl_priv *priv,
  */
 void iwl_set_rxon_chain(struct iwl_priv *priv)
 {
-	u8 is_single = is_single_rx_stream(priv);
-	u8 idle_state, rx_state;
-
-	priv->staging_rxon.rx_chain = 0;
-	rx_state = idle_state = 3;
+	bool is_single = is_single_rx_stream(priv);
+	bool is_cam = !test_bit(STATUS_POWER_PMI, &priv->status);
+	u8 idle_rx_cnt, active_rx_cnt;
+	u16 rx_chain;
 
 	/* Tell uCode which antennas are actually connected.
 	 * Before first association, we assume all antennas are connected.
 	 * Just after first association, iwl_chain_noise_calibration()
 	 *    checks which antennas actually *are* connected. */
-	priv->staging_rxon.rx_chain |=
-		    cpu_to_le16(priv->hw_params.valid_rx_ant <<
-						 RXON_RX_CHAIN_VALID_POS);
+	rx_chain = priv->hw_params.valid_rx_ant << RXON_RX_CHAIN_VALID_POS;
 
 	/* How many receivers should we use? */
-	iwlcore_get_rx_chain_counter(priv, &idle_state, &rx_state);
-	priv->staging_rxon.rx_chain |=
-		cpu_to_le16(rx_state << RXON_RX_CHAIN_MIMO_CNT_POS);
-	priv->staging_rxon.rx_chain |=
-		cpu_to_le16(idle_state << RXON_RX_CHAIN_CNT_POS);
-
-	if (!is_single && (rx_state >= 2) &&
-	    !test_bit(STATUS_POWER_PMI, &priv->status))
+	active_rx_cnt = iwl_get_active_rx_chain_count(priv);
+	idle_rx_cnt = iwl_get_idle_rx_chain_count(priv, active_rx_cnt);
+
+	/* correct rx chain count accoridng hw settings */
+	if (priv->hw_params.rx_chains_num < active_rx_cnt)
+		active_rx_cnt = priv->hw_params.rx_chains_num;
+
+	if (priv->hw_params.rx_chains_num < idle_rx_cnt)
+		idle_rx_cnt = priv->hw_params.rx_chains_num;
+
+	rx_chain |= active_rx_cnt << RXON_RX_CHAIN_MIMO_CNT_POS;
+	rx_chain |= idle_rx_cnt  << RXON_RX_CHAIN_CNT_POS;
+
+	priv->staging_rxon.rx_chain = cpu_to_le16(rx_chain);
+
+	if (!is_single && (active_rx_cnt >= 2) && is_cam)
 		priv->staging_rxon.rx_chain |= RXON_RX_CHAIN_MIMO_FORCE_MSK;
 	else
 		priv->staging_rxon.rx_chain &= ~RXON_RX_CHAIN_MIMO_FORCE_MSK;
 
-	IWL_DEBUG_ASSOC("rx chain %X\n", priv->staging_rxon.rx_chain);
+	IWL_DEBUG_ASSOC("rx_chain=0x%Xi active=%d idle=%d\n",
+			priv->staging_rxon.rx_chain,
+			active_rx_cnt, idle_rx_cnt);
+
+	WARN_ON(active_rx_cnt == 0 || idle_rx_cnt == 0 ||
+		active_rx_cnt < idle_rx_cnt);
 }
 EXPORT_SYMBOL(iwl_set_rxon_chain);
 
 /**
- * iwlcore_set_rxon_channel - Set the phymode and channel values in staging RXON
+ * iwl_set_rxon_channel - Set the phymode and channel values in staging RXON
  * @phymode: MODE_IEEE80211A sets to 5.2GHz; all else set to 2.4GHz
  * @channel: Any channel valid for the requested phymode
 
@@ -782,10 +797,11 @@ EXPORT_SYMBOL(iwl_set_rxon_chain);
  * NOTE:  Does not commit to the hardware; it sets appropriate bit fields
  * in the staging RXON flag structure based on the phymode
  */
-int iwl_set_rxon_channel(struct iwl_priv *priv,
-				enum ieee80211_band band,
-				u16 channel)
+int iwl_set_rxon_channel(struct iwl_priv *priv, struct ieee80211_channel *ch)
 {
+	enum ieee80211_band band = ch->band;
+	u16 channel = ieee80211_frequency_to_channel(ch->center_freq);
+
 	if (!iwl_get_channel_info(priv, band, channel)) {
 		IWL_DEBUG_INFO("Could not set channel to %d [%d]\n",
 			       channel, band);
@@ -907,8 +923,6 @@ int iwl_init_drv(struct iwl_priv *priv)
 	priv->qos_data.qos_active = 0;
 	priv->qos_data.qos_cap.val = 0;
 
-	iwl_set_rxon_channel(priv, IEEE80211_BAND_2GHZ, 6);
-
 	priv->rates_mask = IWL_RATES_MASK;
 	/* If power management is turned on, default to AC mode */
 	priv->power_mode = IWL_POWER_AC;
@@ -935,22 +949,6 @@ err:
 }
 EXPORT_SYMBOL(iwl_init_drv);
 
-void iwl_free_calib_results(struct iwl_priv *priv)
-{
-	kfree(priv->calib_results.lo_res);
-	priv->calib_results.lo_res = NULL;
-	priv->calib_results.lo_res_len = 0;
-
-	kfree(priv->calib_results.tx_iq_res);
-	priv->calib_results.tx_iq_res = NULL;
-	priv->calib_results.tx_iq_res_len = 0;
-
-	kfree(priv->calib_results.tx_iq_perd_res);
-	priv->calib_results.tx_iq_perd_res = NULL;
-	priv->calib_results.tx_iq_perd_res_len = 0;
-}
-EXPORT_SYMBOL(iwl_free_calib_results);
-
 int iwl_set_tx_power(struct iwl_priv *priv, s8 tx_power, bool force)
 {
 	int ret = 0;
@@ -978,10 +976,9 @@ int iwl_set_tx_power(struct iwl_priv *priv, s8 tx_power, bool force)
 }
 EXPORT_SYMBOL(iwl_set_tx_power);
 
-
 void iwl_uninit_drv(struct iwl_priv *priv)
 {
-	iwl_free_calib_results(priv);
+	iwl_calib_free_results(priv);
 	iwlcore_free_geos(priv);
 	iwl_free_channel_map(priv);
 	kfree(priv->scan);
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 64f139e..b5db050 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -186,12 +186,9 @@ struct ieee80211_hw *iwl_alloc_all(struct iwl_cfg *cfg,
 void iwl_hw_detect(struct iwl_priv *priv);
 
 void iwl_clear_stations_table(struct iwl_priv *priv);
-void iwl_free_calib_results(struct iwl_priv *priv);
 void iwl_reset_qos(struct iwl_priv *priv);
 void iwl_set_rxon_chain(struct iwl_priv *priv);
-int iwl_set_rxon_channel(struct iwl_priv *priv,
-				enum ieee80211_band band,
-				u16 channel);
+int iwl_set_rxon_channel(struct iwl_priv *priv, struct ieee80211_channel *ch);
 void iwl_set_rxon_ht(struct iwl_priv *priv, struct iwl_ht_info *ht_info);
 u8 iwl_is_fat_tx_allowed(struct iwl_priv *priv,
 			 struct ieee80211_ht_info *sta_ht_inf);
@@ -291,6 +288,13 @@ int iwl_scan_initiate(struct iwl_priv *priv);
 void iwl_setup_rx_scan_handlers(struct iwl_priv *priv);
 void iwl_setup_scan_deferred_work(struct iwl_priv *priv);
 
+/*******************************************************************************
+ * Calibrations - implemented in iwl-calib.c
+ ******************************************************************************/
+int iwl_send_calib_results(struct iwl_priv *priv);
+int iwl_calib_set(struct iwl_calib_result *res, const u8 *buf, int len);
+void iwl_calib_free_results(struct iwl_priv *priv);
+
 /*****************************************************
  *   S e n d i n g     H o s t     C o m m a n d s   *
  *****************************************************/
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index c19db43..deec634 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -412,7 +412,6 @@ struct iwl_ht_info {
 	/* self configuration data */
 	u8 is_ht;
 	u8 supported_chan_width;
-	u16 tx_mimo_ps_mode;
 	u8 is_green_field;
 	u8 sgf;			/* HT_SHORT_GI_* short guard interval */
 	u8 max_amsdu_size;
@@ -746,13 +745,10 @@ struct statistics_general_data {
 	u32 beacon_energy_c;
 };
 
-struct iwl_calib_results {
-	void *tx_iq_res;
-	void *tx_iq_perd_res;
-	void *lo_res;
-	u32 tx_iq_res_len;
-	u32 tx_iq_perd_res_len;
-	u32 lo_res_len;
+/* Opaque calibration results */
+struct iwl_calib_result {
+	void *buf;
+	size_t buf_len;
 };
 
 enum ucode_type {
@@ -814,6 +810,7 @@ enum {
 
 
 #define IWL_MAX_NUM_QUEUES	20 /* FIXME: do dynamic allocation */
+#define IWL_CALIB_MAX  3
 
 struct iwl_priv {
 
@@ -858,7 +855,7 @@ struct iwl_priv {
 	s32 last_temperature;
 
 	/* init calibration results */
-	struct iwl_calib_results calib_results;
+	struct iwl_calib_result calib_results[IWL_CALIB_MAX];
 
 	/* Scan related variables */
 	unsigned long last_scan_jiffies;
diff --git a/drivers/net/wireless/iwlwifi/iwl-fh.h b/drivers/net/wireless/iwlwifi/iwl-fh.h
index 9446424..cd11c0c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fh.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fh.h
@@ -287,6 +287,7 @@
 
 #define FH_RSSR_CHNL0_RX_STATUS_CHNL_IDLE	(0x01000000)
 
+#define FH_MEM_TFDIB_REG1_ADDR_BITSHIFT	28
 
 /**
  * Transmit DMA Channel Control/Status Registers (TCSR)
diff --git a/drivers/net/wireless/iwlwifi/iwl-power.c b/drivers/net/wireless/iwlwifi/iwl-power.c
index a099c9e..eb6312d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-power.c
+++ b/drivers/net/wireless/iwlwifi/iwl-power.c
@@ -152,9 +152,10 @@ static u16 iwl_get_auto_power_mode(struct iwl_priv *priv)
 /* initialize to default */
 static int iwl_power_init_handle(struct iwl_priv *priv)
 {
-	int ret = 0, i;
 	struct iwl_power_mgr *pow_data;
 	int size = sizeof(struct iwl_power_vec_entry) * IWL_POWER_MAX;
+	struct iwl_powertable_cmd *cmd;
+	int i;
 	u16 pci_pm;
 
 	IWL_DEBUG_POWER("Initialize power \n");
@@ -167,25 +168,19 @@ static int iwl_power_init_handle(struct iwl_priv *priv)
 	memcpy(&pow_data->pwr_range_1[0], &range_1[0], size);
 	memcpy(&pow_data->pwr_range_2[0], &range_2[0], size);
 
-	ret = pci_read_config_word(priv->pci_dev,
-				  PCI_LINK_CTRL, &pci_pm);
-	if (ret != 0)
-		return 0;
-	else {
-		struct iwl_powertable_cmd *cmd;
+	pci_read_config_word(priv->pci_dev, PCI_CFG_LINK_CTRL, &pci_pm);
 
-		IWL_DEBUG_POWER("adjust power command flags\n");
+	IWL_DEBUG_POWER("adjust power command flags\n");
 
-		for (i = 0; i < IWL_POWER_MAX; i++) {
-			cmd = &pow_data->pwr_range_0[i].cmd;
+	for (i = 0; i < IWL_POWER_MAX; i++) {
+		cmd = &pow_data->pwr_range_0[i].cmd;
 
-			if (pci_pm & 0x1)
-				cmd->flags &= ~IWL_POWER_PCI_PM_MSK;
-			else
-				cmd->flags |= IWL_POWER_PCI_PM_MSK;
-		}
+		if (pci_pm & PCI_CFG_LINK_CTRL_VAL_L0S_EN)
+			cmd->flags &= ~IWL_POWER_PCI_PM_MSK;
+		else
+			cmd->flags |= IWL_POWER_PCI_PM_MSK;
 	}
-	return ret;
+	return 0;
 }
 
 /* adjust power command according to dtim period and power level*/
diff --git a/drivers/net/wireless/iwlwifi/iwl-rx.c b/drivers/net/wireless/iwlwifi/iwl-rx.c
index f3f6ea4..e81bfc4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rx.c
@@ -1173,7 +1173,10 @@ void iwl_rx_reply_rx(struct iwl_priv *priv,
 
 	rx_status.antenna = 0;
 	rx_status.flag = 0;
-	rx_status.flag |= RX_FLAG_TSFT;
+
+	/* TSF isn't reliable. In order to allow smooth user experience,
+	 * this W/A doesn't propagate it to the mac80211 */
+	/*rx_status.flag |= RX_FLAG_TSFT;*/
 
 	if ((unlikely(rx_start->cfg_phy_cnt > 20))) {
 		IWL_DEBUG_DROP("dsp size out of range [0,20]: %d/n",
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 9bb6adb..6c8ac3a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -421,7 +421,7 @@ static int iwl_get_channels_for_scan(struct iwl_priv *priv,
 		else
 			scan_ch->type = SCAN_CHANNEL_TYPE_ACTIVE;
 
-		if ((scan_ch->type & SCAN_CHANNEL_TYPE_ACTIVE) && n_probes)
+		if (n_probes)
 			scan_ch->type |= IWL_SCAN_PROBE_MASK(n_probes);
 
 		scan_ch->active_dwell = cpu_to_le16(active_dwell);
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 475f89a..8165df5 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -248,8 +248,8 @@ IEEE80211_IF_WFILE(min_discovery_timeout,
 static void add_sta_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(drop_unencrypted, sta);
-	DEBUGFS_ADD(force_unicast_rateidx, ap);
-	DEBUGFS_ADD(max_ratectrl_rateidx, ap);
+	DEBUGFS_ADD(force_unicast_rateidx, sta);
+	DEBUGFS_ADD(max_ratectrl_rateidx, sta);
 
 	DEBUGFS_ADD(state, sta);
 	DEBUGFS_ADD(bssid, sta);
@@ -283,8 +283,8 @@ static void add_ap_files(struct ieee80211_sub_if_data *sdata)
 static void add_wds_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(drop_unencrypted, wds);
-	DEBUGFS_ADD(force_unicast_rateidx, ap);
-	DEBUGFS_ADD(max_ratectrl_rateidx, ap);
+	DEBUGFS_ADD(force_unicast_rateidx, wds);
+	DEBUGFS_ADD(max_ratectrl_rateidx, wds);
 
 	DEBUGFS_ADD(peer, wds);
 }
@@ -292,8 +292,8 @@ static void add_wds_files(struct ieee80211_sub_if_data *sdata)
 static void add_vlan_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_ADD(drop_unencrypted, vlan);
-	DEBUGFS_ADD(force_unicast_rateidx, ap);
-	DEBUGFS_ADD(max_ratectrl_rateidx, ap);
+	DEBUGFS_ADD(force_unicast_rateidx, vlan);
+	DEBUGFS_ADD(max_ratectrl_rateidx, vlan);
 }
 
 static void add_monitor_files(struct ieee80211_sub_if_data *sdata)
@@ -381,8 +381,8 @@ static void add_files(struct ieee80211_sub_if_data *sdata)
 static void del_sta_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(drop_unencrypted, sta);
-	DEBUGFS_DEL(force_unicast_rateidx, ap);
-	DEBUGFS_DEL(max_ratectrl_rateidx, ap);
+	DEBUGFS_DEL(force_unicast_rateidx, sta);
+	DEBUGFS_DEL(max_ratectrl_rateidx, sta);
 
 	DEBUGFS_DEL(state, sta);
 	DEBUGFS_DEL(bssid, sta);
@@ -416,8 +416,8 @@ static void del_ap_files(struct ieee80211_sub_if_data *sdata)
 static void del_wds_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(drop_unencrypted, wds);
-	DEBUGFS_DEL(force_unicast_rateidx, ap);
-	DEBUGFS_DEL(max_ratectrl_rateidx, ap);
+	DEBUGFS_DEL(force_unicast_rateidx, wds);
+	DEBUGFS_DEL(max_ratectrl_rateidx, wds);
 
 	DEBUGFS_DEL(peer, wds);
 }
@@ -425,8 +425,8 @@ static void del_wds_files(struct ieee80211_sub_if_data *sdata)
 static void del_vlan_files(struct ieee80211_sub_if_data *sdata)
 {
 	DEBUGFS_DEL(drop_unencrypted, vlan);
-	DEBUGFS_DEL(force_unicast_rateidx, ap);
-	DEBUGFS_DEL(max_ratectrl_rateidx, ap);
+	DEBUGFS_DEL(force_unicast_rateidx, vlan);
+	DEBUGFS_DEL(max_ratectrl_rateidx, vlan);
 }
 
 static void del_monitor_files(struct ieee80211_sub_if_data *sdata)
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index ec59345..586a9b4 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -470,6 +470,8 @@ struct ieee80211_sub_if_data {
 			struct dentry *auth_transaction;
 			struct dentry *flags;
 			struct dentry *num_beacons_sta;
+			struct dentry *force_unicast_rateidx;
+			struct dentry *max_ratectrl_rateidx;
 		} sta;
 		struct {
 			struct dentry *drop_unencrypted;
@@ -483,9 +485,13 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *drop_unencrypted;
 			struct dentry *peer;
+			struct dentry *force_unicast_rateidx;
+			struct dentry *max_ratectrl_rateidx;
 		} wds;
 		struct {
 			struct dentry *drop_unencrypted;
+			struct dentry *force_unicast_rateidx;
+			struct dentry *max_ratectrl_rateidx;
 		} vlan;
 		struct {
 			struct dentry *mode;
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index b5933b2..35f2f95 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -383,7 +383,7 @@ errcopy:
 		hlist_for_each_safe(p, q, &newtbl->hash_buckets[i])
 			tbl->free_node(p, 0);
 	}
-	__mesh_table_free(tbl);
+	__mesh_table_free(newtbl);
 endgrow:
 	return NULL;
 }
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 1e97fb9..9bb68c6 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -478,51 +478,21 @@ int ieee80211_ht_addt_info_ie_to_ht_bss_info(
 static void ieee80211_sta_send_associnfo(struct net_device *dev,
 					 struct ieee80211_if_sta *ifsta)
 {
-	char *buf;
-	size_t len;
-	int i;
 	union iwreq_data wrqu;
 
-	if (!ifsta->assocreq_ies && !ifsta->assocresp_ies)
-		return;
-
-	buf = kmalloc(50 + 2 * (ifsta->assocreq_ies_len +
-				ifsta->assocresp_ies_len), GFP_KERNEL);
-	if (!buf)
-		return;
-
-	len = sprintf(buf, "ASSOCINFO(");
 	if (ifsta->assocreq_ies) {
-		len += sprintf(buf + len, "ReqIEs=");
-		for (i = 0; i < ifsta->assocreq_ies_len; i++) {
-			len += sprintf(buf + len, "%02x",
-				       ifsta->assocreq_ies[i]);
-		}
+		memset(&wrqu, 0, sizeof(wrqu));
+		wrqu.data.length = ifsta->assocreq_ies_len;
+		wireless_send_event(dev, IWEVASSOCREQIE, &wrqu,
+				    ifsta->assocreq_ies);
 	}
-	if (ifsta->assocresp_ies) {
-		if (ifsta->assocreq_ies)
-			len += sprintf(buf + len, " ");
-		len += sprintf(buf + len, "RespIEs=");
-		for (i = 0; i < ifsta->assocresp_ies_len; i++) {
-			len += sprintf(buf + len, "%02x",
-				       ifsta->assocresp_ies[i]);
-		}
-	}
-	len += sprintf(buf + len, ")");
 
-	if (len > IW_CUSTOM_MAX) {
-		len = sprintf(buf, "ASSOCRESPIE=");
-		for (i = 0; i < ifsta->assocresp_ies_len; i++) {
-			len += sprintf(buf + len, "%02x",
-				       ifsta->assocresp_ies[i]);
-		}
+	if (ifsta->assocresp_ies) {
+		memset(&wrqu, 0, sizeof(wrqu));
+		wrqu.data.length = ifsta->assocresp_ies_len;
+		wireless_send_event(dev, IWEVASSOCRESPIE, &wrqu,
+				    ifsta->assocresp_ies);
 	}
-
-	memset(&wrqu, 0, sizeof(wrqu));
-	wrqu.data.length = len;
-	wireless_send_event(dev, IWEVCUSTOM, &wrqu, buf);
-
-	kfree(buf);
 }
 
 
@@ -813,7 +783,7 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		}
 	}
 
-	if (count == 8) {
+	if (rates_len > count) {
 		pos = skb_put(skb, rates_len - count + 2);
 		*pos++ = WLAN_EID_EXT_SUPP_RATES;
 		*pos++ = rates_len - count;
@@ -2868,7 +2838,7 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 		       jiffies);
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 		if (beacon_timestamp > rx_timestamp) {
-#ifndef CONFIG_MAC80211_IBSS_DEBUG
+#ifdef CONFIG_MAC80211_IBSS_DEBUG
 			printk(KERN_DEBUG "%s: beacon TSF higher than "
 			       "local TSF - IBSS merge with BSSID %s\n",
 			       dev->name, print_mac(mac, mgmt->bssid));
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 35a9994..74aecc0 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -377,7 +377,7 @@ static ssize_t rfkill_claim_show(struct device *dev,
 {
 	struct rfkill *rfkill = to_rfkill(dev);
 
-	return sprintf(buf, "%d", rfkill->user_claim);
+	return sprintf(buf, "%d\n", rfkill->user_claim);
 }
 
 static ssize_t rfkill_claim_store(struct device *dev,
-- 
John W. Linville
linville@tuxdriver.com
