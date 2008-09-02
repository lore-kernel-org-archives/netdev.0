From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-09-02
Date: Tue, 2 Sep 2008 18:15:11 -0400
Message-ID: <20080902221511.GH3050@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40700 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbYIBWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 18:30:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is this week's round of fixes.  Admittedly not all of them are
regressions with entries at bugzilla.kernel.org -- hopefully that is not
a hard and fast requirement. :-)

I think everything here is suitable for 2.6.27.  Please let me know if
there are problems.

Thanks!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7c19a3d280297d43ef5ff7c6b205dc208a16d3d1:
  David S. Miller (1):
        net: Unbreak userspace usage of linux/mroute.h

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Adrian Bunk (1):
      wireless/libertas/if_cs.c: fix memory leaks

Boaz Harrosh (1):
      rt2x00: Compiler warning unmasked by fix of BUILD_BUG_ON

David Kilroy (1):
      orinoco: Multicast to the specified addresses

Florian Mickler (1):
      net/wireless/Kconfig: clarify the description for CONFIG_WIRELESS_EXT_SYSFS

John W. Linville (1):
      iwlwifi: do not use GFP_DMA in iwl_tx_queue_init

Jouni Malinen (1):
      mac80211: Fix debugfs union misuse and pointer corruption

Mohamed Abbas (1):
      iwlwifi: fix apm_stop (wrong bit polarity for FLAG_INIT_DONE)

Senthil Balasubramanian (2):
      ath9k: Incorrect key used when group and pairwise ciphers are different.
      ath9: Fix ath_rx_flush_tid() for IRQs disabled kernel warning message.

Tomas Winkler (2):
      iwlwifi: workaround interrupt handling no some platforms
      iwlwifi: fix 64bit platform firmware loading

 drivers/net/wireless/ath9k/hw.c         |    8 ++++----
 drivers/net/wireless/ath9k/main.c       |    6 ++++--
 drivers/net/wireless/ath9k/recv.c       |    5 +++--
 drivers/net/wireless/iwlwifi/iwl-4965.c |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-5000.c |   14 ++++++--------
 drivers/net/wireless/iwlwifi/iwl-agn.c  |    8 ++++++++
 drivers/net/wireless/iwlwifi/iwl-fh.h   |    1 +
 drivers/net/wireless/iwlwifi/iwl-tx.c   |    2 +-
 drivers/net/wireless/libertas/if_cs.c   |   13 +++----------
 drivers/net/wireless/orinoco.c          |   10 +++++++---
 drivers/net/wireless/rt2x00/rt2x00reg.h |    5 ++---
 net/mac80211/debugfs_key.c              |    6 +++---
 net/mac80211/ieee80211_i.h              |    4 +++-
 net/wireless/Kconfig                    |    3 ++-
 14 files changed, 49 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/ath9k/hw.c b/drivers/net/wireless/ath9k/hw.c
index a17eb13..6dbfed0 100644
--- a/drivers/net/wireless/ath9k/hw.c
+++ b/drivers/net/wireless/ath9k/hw.c
@@ -7285,15 +7285,15 @@ ath9k_hw_set_keycache_entry(struct ath_hal *ah, u16 entry,
 		}
 		break;
 	case ATH9K_CIPHER_WEP:
-		if (k->kv_len < 40 / NBBY) {
+		if (k->kv_len < LEN_WEP40) {
 			DPRINTF(ah->ah_sc, ATH_DBG_KEYCACHE,
 				 "%s: WEP key length %u too small\n",
 				 __func__, k->kv_len);
 			return false;
 		}
-		if (k->kv_len <= 40 / NBBY)
+		if (k->kv_len <= LEN_WEP40)
 			keyType = AR_KEYTABLE_TYPE_40;
-		else if (k->kv_len <= 104 / NBBY)
+		else if (k->kv_len <= LEN_WEP104)
 			keyType = AR_KEYTABLE_TYPE_104;
 		else
 			keyType = AR_KEYTABLE_TYPE_128;
@@ -7313,7 +7313,7 @@ ath9k_hw_set_keycache_entry(struct ath_hal *ah, u16 entry,
 	key2 = get_unaligned_le32(k->kv_val + 6) ^ xorMask;
 	key3 = (get_unaligned_le16(k->kv_val + 10) ^ xorMask) & 0xffff;
 	key4 = get_unaligned_le32(k->kv_val + 12) ^ xorMask;
-	if (k->kv_len <= 104 / NBBY)
+	if (k->kv_len <= LEN_WEP104)
 		key4 &= 0xff;
 
 	if (keyType == AR_KEYTABLE_TYPE_TKIP && ATH9K_IS_MIC_ENABLED(ah)) {
diff --git a/drivers/net/wireless/ath9k/main.c b/drivers/net/wireless/ath9k/main.c
index 2888778..95b3371 100644
--- a/drivers/net/wireless/ath9k/main.c
+++ b/drivers/net/wireless/ath9k/main.c
@@ -206,7 +206,8 @@ static int ath_key_config(struct ath_softc *sc,
 	if (!ret)
 		return -EIO;
 
-	sc->sc_keytype = hk.kv_type;
+	if (mac)
+		sc->sc_keytype = hk.kv_type;
 	return 0;
 }
 
@@ -756,7 +757,8 @@ static int ath9k_set_key(struct ieee80211_hw *hw,
 			key->hw_key_idx = key->keyidx;
 			/* push IV and Michael MIC generation to stack */
 			key->flags |= IEEE80211_KEY_FLAG_GENERATE_IV;
-			key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
+			if (key->alg == ALG_TKIP)
+				key->flags |= IEEE80211_KEY_FLAG_GENERATE_MMIC;
 		}
 		break;
 	case DISABLE_KEY:
diff --git a/drivers/net/wireless/ath9k/recv.c b/drivers/net/wireless/ath9k/recv.c
index 2fe8061..20ddb7a 100644
--- a/drivers/net/wireless/ath9k/recv.c
+++ b/drivers/net/wireless/ath9k/recv.c
@@ -360,8 +360,9 @@ static void ath_rx_flush_tid(struct ath_softc *sc,
 	struct ath_arx_tid *rxtid, int drop)
 {
 	struct ath_rxbuf *rxbuf;
+	unsigned long flag;
 
-	spin_lock_bh(&rxtid->tidlock);
+	spin_lock_irqsave(&rxtid->tidlock, flag);
 	while (rxtid->baw_head != rxtid->baw_tail) {
 		rxbuf = rxtid->rxbuf + rxtid->baw_head;
 		if (!rxbuf->rx_wbuf) {
@@ -382,7 +383,7 @@ static void ath_rx_flush_tid(struct ath_softc *sc,
 		INCR(rxtid->baw_head, ATH_TID_MAX_BUFS);
 		INCR(rxtid->seq_next, IEEE80211_SEQ_MAX);
 	}
-	spin_unlock_bh(&rxtid->tidlock);
+	spin_unlock_irqrestore(&rxtid->tidlock, flag);
 }
 
 static struct sk_buff *ath_rxbuf_alloc(struct ath_softc *sc,
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index e258122..23fed32 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -474,8 +474,8 @@ static void iwl4965_apm_stop(struct iwl_priv *priv)
 	iwl_set_bit(priv, CSR_RESET, CSR_RESET_REG_FLAG_SW_RESET);
 
 	udelay(10);
-
-	iwl_set_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
+	/* clear "init complete"  move adapter D0A* --> D0U state */
+	iwl_clear_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index cbc01a0..b08036a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -145,7 +145,8 @@ static void iwl5000_apm_stop(struct iwl_priv *priv)
 
 	udelay(10);
 
-	iwl_set_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
+	/* clear "init complete"  move adapter D0A* --> D0U state */
+	iwl_clear_bit(priv, CSR_GP_CNTRL, CSR_GP_CNTRL_REG_FLAG_INIT_DONE);
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
@@ -577,14 +578,11 @@ static int iwl5000_load_section(struct iwl_priv *priv,
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
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 061ffba..c0b73c4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
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
diff --git a/drivers/net/wireless/iwlwifi/iwl-fh.h b/drivers/net/wireless/iwlwifi/iwl-fh.h
index 9446424..cd11c0c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fh.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fh.h
@@ -287,6 +287,7 @@
 
 #define FH_RSSR_CHNL0_RX_STATUS_CHNL_IDLE	(0x01000000)
 
+#define FH_MEM_TFDIB_REG1_ADDR_BITSHIFT	28
 
 /**
  * Transmit DMA Channel Control/Status Registers (TCSR)
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index d82823b..ff879d4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -426,7 +426,7 @@ static int iwl_tx_queue_init(struct iwl_priv *priv,
 				continue;
 		}
 
-		txq->cmd[i] = kmalloc(len, GFP_KERNEL | GFP_DMA);
+		txq->cmd[i] = kmalloc(len, GFP_KERNEL);
 		if (!txq->cmd[i])
 			return -ENOMEM;
 	}
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 04d7a25..8941919 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -595,7 +595,7 @@ static int if_cs_prog_helper(struct if_cs_card *card)
 		if (ret < 0) {
 			lbs_pr_err("can't download helper at 0x%x, ret %d\n",
 				sent, ret);
-			goto done;
+			goto err_release;
 		}
 
 		if (count == 0)
@@ -604,9 +604,8 @@ static int if_cs_prog_helper(struct if_cs_card *card)
 		sent += count;
 	}
 
+err_release:
 	release_firmware(fw);
-	ret = 0;
-
 done:
 	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
 	return ret;
@@ -676,14 +675,8 @@ static int if_cs_prog_real(struct if_cs_card *card)
 	}
 
 	ret = if_cs_poll_while_fw_download(card, IF_CS_SCRATCH, 0x5a);
-	if (ret < 0) {
+	if (ret < 0)
 		lbs_pr_err("firmware download failed\n");
-		goto err_release;
-	}
-
-	ret = 0;
-	goto done;
-
 
 err_release:
 	release_firmware(fw);
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 1ebcafe..36c004e 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1970,6 +1970,9 @@ __orinoco_set_multicast_list(struct net_device *dev)
 			priv->promiscuous = promisc;
 	}
 
+	/* If we're not in promiscuous mode, then we need to set the
+	 * group address if either we want to multicast, or if we were
+	 * multicasting and want to stop */
 	if (! promisc && (mc_count || priv->mc_count) ) {
 		struct dev_mc_list *p = dev->mc_list;
 		struct hermes_multicast mclist;
@@ -1989,9 +1992,10 @@ __orinoco_set_multicast_list(struct net_device *dev)
 			printk(KERN_WARNING "%s: Multicast list is "
 			       "longer than mc_count\n", dev->name);
 
-		err = hermes_write_ltv(hw, USER_BAP, HERMES_RID_CNFGROUPADDRESSES,
-				       HERMES_BYTES_TO_RECLEN(priv->mc_count * ETH_ALEN),
-				       &mclist);
+		err = hermes_write_ltv(hw, USER_BAP,
+				   HERMES_RID_CNFGROUPADDRESSES,
+				   HERMES_BYTES_TO_RECLEN(mc_count * ETH_ALEN),
+				   &mclist);
 		if (err)
 			printk(KERN_ERR "%s: Error %d setting multicast list.\n",
 			       dev->name, err);
diff --git a/drivers/net/wireless/rt2x00/rt2x00reg.h b/drivers/net/wireless/rt2x00/rt2x00reg.h
index 7e88ce5..2ea7866 100644
--- a/drivers/net/wireless/rt2x00/rt2x00reg.h
+++ b/drivers/net/wireless/rt2x00/rt2x00reg.h
@@ -136,7 +136,7 @@ struct rt2x00_field32 {
  */
 #define is_power_of_two(x)	( !((x) & ((x)-1)) )
 #define low_bit_mask(x)		( ((x)-1) & ~(x) )
-#define is_valid_mask(x)	is_power_of_two(1 + (x) + low_bit_mask(x))
+#define is_valid_mask(x)	is_power_of_two(1LU + (x) + low_bit_mask(x))
 
 /*
  * Macro's to find first set bit in a variable.
@@ -173,8 +173,7 @@ struct rt2x00_field32 {
  * does not exceed the given typelimit.
  */
 #define FIELD_CHECK(__mask, __type)			\
-	BUILD_BUG_ON(!__builtin_constant_p(__mask) ||	\
-		     !(__mask) ||			\
+	BUILD_BUG_ON(!(__mask) ||			\
 		     !is_valid_mask(__mask) ||		\
 		     (__mask) != (__type)(__mask))	\
 
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 7439b63..cf82ace 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -265,7 +265,7 @@ void ieee80211_debugfs_key_add_default(struct ieee80211_sub_if_data *sdata)
 	key = sdata->default_key;
 	if (key) {
 		sprintf(buf, "../keys/%d", key->debugfs.cnt);
-		sdata->debugfs.default_key =
+		sdata->common_debugfs.default_key =
 			debugfs_create_symlink("default_key",
 					       sdata->debugfsdir, buf);
 	} else
@@ -277,8 +277,8 @@ void ieee80211_debugfs_key_remove_default(struct ieee80211_sub_if_data *sdata)
 	if (!sdata)
 		return;
 
-	debugfs_remove(sdata->debugfs.default_key);
-	sdata->debugfs.default_key = NULL;
+	debugfs_remove(sdata->common_debugfs.default_key);
+	sdata->common_debugfs.default_key = NULL;
 }
 
 void ieee80211_debugfs_key_sta_del(struct ieee80211_key *key,
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 586a9b4..4498d87 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -496,8 +496,10 @@ struct ieee80211_sub_if_data {
 		struct {
 			struct dentry *mode;
 		} monitor;
-		struct dentry *default_key;
 	} debugfs;
+	struct {
+		struct dentry *default_key;
+	} common_debugfs;
 
 #ifdef CONFIG_MAC80211_MESH
 	struct dentry *mesh_stats_dir;
diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index ab015c6..833b024 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -39,4 +39,5 @@ config WIRELESS_EXT_SYSFS
 	  files in /sys/class/net/*/wireless/. The same information
 	  is available via the ioctls as well.
 
-	  Say Y if you have programs using it (we don't know of any).
+	  Say Y if you have programs using it, like old versions of
+	  hal.

-- 
John W. Linville
linville@tuxdriver.com
