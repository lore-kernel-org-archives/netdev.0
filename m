From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-06-30
Date: Thu, 30 Jun 2011 13:32:25 -0400
Message-ID: <20110630173223.GA12963@tuxdriver.com>
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

Here is a batch of fixes intended for 3.0.  Arik gives us a fix for a
potential NULL dereference in mac80211.  Emmanuel gives us a fix for a
regression introduced by "iwlagn: support multiple TBs per command" that
can corrupt memory.  Eugene (and Bob) gives a memory leak fix for ath5k.
Evgeni gives us a preprocessor-related fix that makes modinfo output
make more sense for iwlagn.  Johannes gives us a trio of fixes, all
isolated to the bowels of iwlagn.  I overlayed a fixup on top of one of
Johannes's patches, since there was some confusion between DMA and PCI
API usage.  Finally, Rajkumar gives us an ath9k fix to ensure the chip
is properly awakened even if there is no active interface when the
resume occurs.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 16adf5d07987d93675945f3cecf0e33706566005:

  usbnet: Remove over-broad module alias from zaurus. (2011-06-29 06:09:17 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git for-davem

Arik Nemtsov (1):
      mac80211: fix rx->key NULL dereference during mic failure

Emmanuel Grumbach (1):
      iwlagn: Fix a bug introduced by the HUGE command removal

Eugene A. Shatokhin (1):
      ath5k: fix memory leak when fewer than N_PD_CURVES are in use

Evgeni Golov (1):
      iwlagn: fix *_UCODE_API_MAX output in the firmware field

Johannes Berg (3):
      iwlagn: fix change_interface for P2P types
      iwlagn: fix cmd queue unmap
      iwlagn: map command buffers BIDI

John W. Linville (3):
      Merge branch 'wireless-2.6' of git://git.kernel.org/.../iwlwifi/iwlwifi-2.6
      iwlagn: use PCI_DMA_* for pci_* operations
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6 into for-davem

Rajkumar Manoharan (1):
      ath9k: Fix suspend/resume when no interface is UP

 drivers/net/wireless/ath/ath5k/eeprom.c |    8 +++-----
 drivers/net/wireless/ath/ath9k/pci.c    |    6 ++++++
 drivers/net/wireless/iwlwifi/iwl-1000.c |    5 +++--
 drivers/net/wireless/iwlwifi/iwl-2000.c |    7 ++++---
 drivers/net/wireless/iwlwifi/iwl-5000.c |    5 +++--
 drivers/net/wireless/iwlwifi/iwl-6000.c |    9 +++++----
 drivers/net/wireless/iwlwifi/iwl-core.c |    3 ++-
 drivers/net/wireless/iwlwifi/iwl-tx.c   |   25 ++++++++++---------------
 include/net/cfg80211.h                  |    2 +-
 net/mac80211/wpa.c                      |    8 +++++++-
 net/wireless/nl80211.c                  |    3 ++-
 11 files changed, 46 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/eeprom.c b/drivers/net/wireless/ath/ath5k/eeprom.c
index 1fef84f..392771f 100644
--- a/drivers/net/wireless/ath/ath5k/eeprom.c
+++ b/drivers/net/wireless/ath/ath5k/eeprom.c
@@ -691,14 +691,12 @@ ath5k_eeprom_free_pcal_info(struct ath5k_hw *ah, int mode)
 		if (!chinfo[pier].pd_curves)
 			continue;
 
-		for (pdg = 0; pdg < ee->ee_pd_gains[mode]; pdg++) {
+		for (pdg = 0; pdg < AR5K_EEPROM_N_PD_CURVES; pdg++) {
 			struct ath5k_pdgain_info *pd =
 					&chinfo[pier].pd_curves[pdg];
 
-			if (pd != NULL) {
-				kfree(pd->pd_step);
-				kfree(pd->pd_pwr);
-			}
+			kfree(pd->pd_step);
+			kfree(pd->pd_pwr);
 		}
 
 		kfree(chinfo[pier].pd_curves);
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index b8cbfc7..3bad0b2 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -278,6 +278,12 @@ static int ath_pci_suspend(struct device *device)
 
 	ath9k_hw_set_gpio(sc->sc_ah, sc->sc_ah->led_pin, 1);
 
+	/* The device has to be moved to FULLSLEEP forcibly.
+	 * Otherwise the chip never moved to full sleep,
+	 * when no interface is up.
+	 */
+	ath9k_hw_setpower(sc->sc_ah, ATH9K_PM_FULL_SLEEP);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-1000.c b/drivers/net/wireless/iwlwifi/iwl-1000.c
index 61d4a11..2a88e73 100644
--- a/drivers/net/wireless/iwlwifi/iwl-1000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-1000.c
@@ -36,6 +36,7 @@
 #include <net/mac80211.h>
 #include <linux/etherdevice.h>
 #include <asm/unaligned.h>
+#include <linux/stringify.h>
 
 #include "iwl-eeprom.h"
 #include "iwl-dev.h"
@@ -55,10 +56,10 @@
 #define IWL100_UCODE_API_MIN 5
 
 #define IWL1000_FW_PRE "iwlwifi-1000-"
-#define IWL1000_MODULE_FIRMWARE(api) IWL1000_FW_PRE #api ".ucode"
+#define IWL1000_MODULE_FIRMWARE(api) IWL1000_FW_PRE __stringify(api) ".ucode"
 
 #define IWL100_FW_PRE "iwlwifi-100-"
-#define IWL100_MODULE_FIRMWARE(api) IWL100_FW_PRE #api ".ucode"
+#define IWL100_MODULE_FIRMWARE(api) IWL100_FW_PRE __stringify(api) ".ucode"
 
 
 /*
diff --git a/drivers/net/wireless/iwlwifi/iwl-2000.c b/drivers/net/wireless/iwlwifi/iwl-2000.c
index 2282279..3df76f5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-2000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-2000.c
@@ -36,6 +36,7 @@
 #include <net/mac80211.h>
 #include <linux/etherdevice.h>
 #include <asm/unaligned.h>
+#include <linux/stringify.h>
 
 #include "iwl-eeprom.h"
 #include "iwl-dev.h"
@@ -58,13 +59,13 @@
 #define IWL105_UCODE_API_MIN 5
 
 #define IWL2030_FW_PRE "iwlwifi-2030-"
-#define IWL2030_MODULE_FIRMWARE(api) IWL2030_FW_PRE #api ".ucode"
+#define IWL2030_MODULE_FIRMWARE(api) IWL2030_FW_PRE __stringify(api) ".ucode"
 
 #define IWL2000_FW_PRE "iwlwifi-2000-"
-#define IWL2000_MODULE_FIRMWARE(api) IWL2000_FW_PRE #api ".ucode"
+#define IWL2000_MODULE_FIRMWARE(api) IWL2000_FW_PRE __stringify(api) ".ucode"
 
 #define IWL105_FW_PRE "iwlwifi-105-"
-#define IWL105_MODULE_FIRMWARE(api) IWL105_FW_PRE #api ".ucode"
+#define IWL105_MODULE_FIRMWARE(api) IWL105_FW_PRE __stringify(api) ".ucode"
 
 static void iwl2000_set_ct_threshold(struct iwl_priv *priv)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wireless/iwlwifi/iwl-5000.c
index f99f9c1..e816c27 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -37,6 +37,7 @@
 #include <net/mac80211.h>
 #include <linux/etherdevice.h>
 #include <asm/unaligned.h>
+#include <linux/stringify.h>
 
 #include "iwl-eeprom.h"
 #include "iwl-dev.h"
@@ -57,10 +58,10 @@
 #define IWL5150_UCODE_API_MIN 1
 
 #define IWL5000_FW_PRE "iwlwifi-5000-"
-#define IWL5000_MODULE_FIRMWARE(api) IWL5000_FW_PRE #api ".ucode"
+#define IWL5000_MODULE_FIRMWARE(api) IWL5000_FW_PRE __stringify(api) ".ucode"
 
 #define IWL5150_FW_PRE "iwlwifi-5150-"
-#define IWL5150_MODULE_FIRMWARE(api) IWL5150_FW_PRE #api ".ucode"
+#define IWL5150_MODULE_FIRMWARE(api) IWL5150_FW_PRE __stringify(api) ".ucode"
 
 /* NIC configuration for 5000 series */
 static void iwl5000_nic_config(struct iwl_priv *priv)
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless/iwlwifi/iwl-6000.c
index fbe565c..5b150bc 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -36,6 +36,7 @@
 #include <net/mac80211.h>
 #include <linux/etherdevice.h>
 #include <asm/unaligned.h>
+#include <linux/stringify.h>
 
 #include "iwl-eeprom.h"
 #include "iwl-dev.h"
@@ -58,16 +59,16 @@
 #define IWL6000G2_UCODE_API_MIN 4
 
 #define IWL6000_FW_PRE "iwlwifi-6000-"
-#define IWL6000_MODULE_FIRMWARE(api) IWL6000_FW_PRE #api ".ucode"
+#define IWL6000_MODULE_FIRMWARE(api) IWL6000_FW_PRE __stringify(api) ".ucode"
 
 #define IWL6050_FW_PRE "iwlwifi-6050-"
-#define IWL6050_MODULE_FIRMWARE(api) IWL6050_FW_PRE #api ".ucode"
+#define IWL6050_MODULE_FIRMWARE(api) IWL6050_FW_PRE __stringify(api) ".ucode"
 
 #define IWL6005_FW_PRE "iwlwifi-6000g2a-"
-#define IWL6005_MODULE_FIRMWARE(api) IWL6005_FW_PRE #api ".ucode"
+#define IWL6005_MODULE_FIRMWARE(api) IWL6005_FW_PRE __stringify(api) ".ucode"
 
 #define IWL6030_FW_PRE "iwlwifi-6000g2b-"
-#define IWL6030_MODULE_FIRMWARE(api) IWL6030_FW_PRE #api ".ucode"
+#define IWL6030_MODULE_FIRMWARE(api) IWL6030_FW_PRE __stringify(api) ".ucode"
 
 static void iwl6000_set_ct_threshold(struct iwl_priv *priv)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 213c80c..45cc51c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -1763,6 +1763,7 @@ int iwl_mac_change_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	struct iwl_rxon_context *ctx = iwl_rxon_ctx_from_vif(vif);
 	struct iwl_rxon_context *bss_ctx = &priv->contexts[IWL_RXON_CTX_BSS];
 	struct iwl_rxon_context *tmp;
+	enum nl80211_iftype newviftype = newtype;
 	u32 interface_modes;
 	int err;
 
@@ -1818,7 +1819,7 @@ int iwl_mac_change_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 
 	/* success */
 	iwl_teardown_interface(priv, vif, true);
-	vif->type = newtype;
+	vif->type = newviftype;
 	vif->p2p = newp2p;
 	err = iwl_setup_interface(priv, ctx);
 	WARN_ON(err);
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 686e176..137dba9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -126,7 +126,7 @@ static inline u8 iwl_tfd_get_num_tbs(struct iwl_tfd *tfd)
 }
 
 static void iwlagn_unmap_tfd(struct iwl_priv *priv, struct iwl_cmd_meta *meta,
-			     struct iwl_tfd *tfd)
+			     struct iwl_tfd *tfd, int dma_dir)
 {
 	struct pci_dev *dev = priv->pci_dev;
 	int i;
@@ -151,7 +151,7 @@ static void iwlagn_unmap_tfd(struct iwl_priv *priv, struct iwl_cmd_meta *meta,
 	/* Unmap chunks, if any. */
 	for (i = 1; i < num_tbs; i++)
 		pci_unmap_single(dev, iwl_tfd_tb_get_addr(tfd, i),
-				iwl_tfd_tb_get_len(tfd, i), PCI_DMA_TODEVICE);
+				iwl_tfd_tb_get_len(tfd, i), dma_dir);
 }
 
 /**
@@ -167,7 +167,8 @@ void iwlagn_txq_free_tfd(struct iwl_priv *priv, struct iwl_tx_queue *txq)
 	struct iwl_tfd *tfd_tmp = txq->tfds;
 	int index = txq->q.read_ptr;
 
-	iwlagn_unmap_tfd(priv, &txq->meta[index], &tfd_tmp[index]);
+	iwlagn_unmap_tfd(priv, &txq->meta[index], &tfd_tmp[index],
+			 PCI_DMA_TODEVICE);
 
 	/* free SKB */
 	if (txq->txb) {
@@ -310,9 +311,7 @@ void iwl_cmd_queue_unmap(struct iwl_priv *priv)
 		i = get_cmd_index(q, q->read_ptr);
 
 		if (txq->meta[i].flags & CMD_MAPPED) {
-			pci_unmap_single(priv->pci_dev,
-					 dma_unmap_addr(&txq->meta[i], mapping),
-					 dma_unmap_len(&txq->meta[i], len),
+			iwlagn_unmap_tfd(priv, &txq->meta[i], &txq->tfds[i],
 					 PCI_DMA_BIDIRECTIONAL);
 			txq->meta[i].flags = 0;
 		}
@@ -535,12 +534,7 @@ out_free_arrays:
 void iwl_tx_queue_reset(struct iwl_priv *priv, struct iwl_tx_queue *txq,
 			int slots_num, u32 txq_id)
 {
-	int actual_slots = slots_num;
-
-	if (txq_id == priv->cmd_queue)
-		actual_slots++;
-
-	memset(txq->meta, 0, sizeof(struct iwl_cmd_meta) * actual_slots);
+	memset(txq->meta, 0, sizeof(struct iwl_cmd_meta) * slots_num);
 
 	txq->need_update = 0;
 
@@ -700,10 +694,11 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 		if (!(cmd->dataflags[i] & IWL_HCMD_DFL_NOCOPY))
 			continue;
 		phys_addr = pci_map_single(priv->pci_dev, (void *)cmd->data[i],
-					   cmd->len[i], PCI_DMA_TODEVICE);
+					   cmd->len[i], PCI_DMA_BIDIRECTIONAL);
 		if (pci_dma_mapping_error(priv->pci_dev, phys_addr)) {
 			iwlagn_unmap_tfd(priv, out_meta,
-					 &txq->tfds[q->write_ptr]);
+					 &txq->tfds[q->write_ptr],
+					 PCI_DMA_BIDIRECTIONAL);
 			idx = -ENOMEM;
 			goto out;
 		}
@@ -807,7 +802,7 @@ void iwl_tx_cmd_complete(struct iwl_priv *priv, struct iwl_rx_mem_buffer *rxb)
 	cmd = txq->cmd[cmd_index];
 	meta = &txq->meta[cmd_index];
 
-	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index]);
+	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index], PCI_DMA_BIDIRECTIONAL);
 
 	/* Input error checking is done when commands are added to queue. */
 	if (meta->flags & CMD_WANT_SKB) {
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 0589f55..396e8fc 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2688,7 +2688,7 @@ void cfg80211_send_unprot_disassoc(struct net_device *dev, const u8 *buf,
  * @dev: network device
  * @addr: The source MAC address of the frame
  * @key_type: The key type that the received frame used
- * @key_id: Key identifier (0..3)
+ * @key_id: Key identifier (0..3). Can be -1 if missing.
  * @tsc: The TSC value of the frame that generated the MIC failure (6 octets)
  * @gfp: allocation flags
  *
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 9dc3b5f..d91c1a2 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -154,7 +154,13 @@ update_iv:
 	return RX_CONTINUE;
 
 mic_fail:
-	mac80211_ev_michael_mic_failure(rx->sdata, rx->key->conf.keyidx,
+	/*
+	 * In some cases the key can be unset - e.g. a multicast packet, in
+	 * a driver that supports HW encryption. Send up the key idx only if
+	 * the key is set.
+	 */
+	mac80211_ev_michael_mic_failure(rx->sdata,
+					rx->key ? rx->key->conf.keyidx : -1,
 					(void *) skb->data, NULL, GFP_ATOMIC);
 	return RX_DROP_UNUSABLE;
 }
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 98fa8eb..f07602d 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -6463,7 +6463,8 @@ void nl80211_michael_mic_failure(struct cfg80211_registered_device *rdev,
 	if (addr)
 		NLA_PUT(msg, NL80211_ATTR_MAC, ETH_ALEN, addr);
 	NLA_PUT_U32(msg, NL80211_ATTR_KEY_TYPE, key_type);
-	NLA_PUT_U8(msg, NL80211_ATTR_KEY_IDX, key_id);
+	if (key_id != -1)
+		NLA_PUT_U8(msg, NL80211_ATTR_KEY_IDX, key_id);
 	if (tsc)
 		NLA_PUT(msg, NL80211_ATTR_KEY_SEQ, 6, tsc);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
