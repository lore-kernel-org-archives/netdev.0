From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-12-08
Date: Tue, 8 Dec 2009 15:02:24 -0500
Message-ID: <20091208200224.GB16303@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here are a couple of dozen more fixes intended for 2.6.33.  They are
mostly small (or at least self-contained), and FWIW about half of
them are specifically for the mwl8k driver.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/

---

The following changes since commit 28b4d5cc17c20786848cdc07b7ea237a309776bb:
  David S. Miller (1):
        Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master

Andrew Morton (1):
      net/rfkill/core.c: work around gcc-4.0.2 silliness

David Kilroy (1):
      orinoco: remove spare KERN_DEBUG

Felix Fietkau (1):
      ath9k: fix tx status reporting

Johannes Berg (1):
      mac80211: recalculate idle later in MLME

John W. Linville (1):
      iwlwifi: fix warning from ieee80211_stop_tx_ba_cb_irqsafe argument change

Kalle Valo (3):
      wl1251: remove false warning messages
      wl1251: fix bssid handling
      wl1251: don't build null data template in wl1251_op_config()

Larry Finger (1):
      rtl8187: Fix wrong rfkill switch mask for some models

Lennert Buytenhek (12):
      mwl8k: fix MCS bitmap size in SET_RATE command
      mwl8k: fix UPDATE_STADB command struct legacy_rates array length
      mwl8k: prevent corruption of QoS field on receive
      mwl8k: fix addr4 zeroing and payload overwrite on DMA header creation
      mwl8k: properly report rate on received 40MHz packets
      mwl8k: allow more time for firmware commands to complete
      mwl8k: allow more time for transmit rings to drain
      mwl8k: increase firmware loading timeouts
      mwl8k: don't forget to call pci_disable_device()
      mwl8k: struct ieee80211_rx_status::qual is deprecated
      mwl8k: don't overwrite mwl8k_vif::bssid until after disassociation
      mwl8k: don't complain about oversized beacons in FINALIZE_JOIN

Shahar Or (1):
      ath5k: add support for Dell Vostro A860 LED

Vasanthakumar Thiagarajan (1):
      mac80211: Fix bug in computing crc over dynamic IEs in beacon

Vivek Natarajan (1):
      mac80211: Fix dynamic power save for scanning.

 drivers/net/wireless/ath/ath5k/led.c          |    2 +
 drivers/net/wireless/ath/ath9k/xmit.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |    2 +-
 drivers/net/wireless/mwl8k.c                  |  327 ++++++++++++-------------
 drivers/net/wireless/orinoco/hermes_dld.c     |    2 +-
 drivers/net/wireless/rtl818x/rtl8187.h        |    5 +
 drivers/net/wireless/rtl818x/rtl8187_dev.c    |   12 +-
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c |    4 +-
 drivers/net/wireless/wl12xx/wl1251_main.c     |   36 ++--
 net/mac80211/ieee80211_i.h                    |    1 +
 net/mac80211/mlme.c                           |   10 +-
 net/mac80211/scan.c                           |   20 ++-
 net/mac80211/util.c                           |    2 +-
 net/rfkill/core.c                             |    4 +-
 14 files changed, 228 insertions(+), 201 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index d495890..60f5475 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -79,6 +79,8 @@ static const struct pci_device_id ath5k_led_devices[] = {
 	{ ATH_SDEVICE(PCI_VENDOR_ID_HP, 0x0137b), ATH_LED(3, 1) },
 	/* IBM-specific AR5212 (all others) */
 	{ PCI_VDEVICE(ATHEROS, PCI_DEVICE_ID_ATHEROS_AR5212_IBM), ATH_LED(0, 0) },
+	/* Dell Vostro A860 (shahar-ThuA2tnqEQ612v9G2T7xgg@public.gmane.org) */
+	{ ATH_SDEVICE(PCI_VENDOR_ID_QMI, 0x0112), ATH_LED(3, 0) },
 	{ }
 };
 
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/ath/ath9k/xmit.c
index 564c6cb..2a11cc5 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2078,7 +2078,7 @@ static void ath_tx_processq(struct ath_softc *sc, struct ath_txq *txq)
 				&txq->axq_q, lastbf->list.prev);
 
 		txq->axq_depth--;
-		txok = (ds->ds_txstat.ts_status == 0);
+		txok = !(ds->ds_txstat.ts_status & ATH9K_TXERR_FILT);
 		txq->axq_tx_inprogress = false;
 		spin_unlock_bh(&txq->axq_lock);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 58b132f..00da5e1 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -1353,7 +1353,7 @@ int iwl_tx_agg_stop(struct iwl_priv *priv , const u8 *ra, u16 tid)
 	if (priv->stations[sta_id].tid[tid].agg.state ==
 				IWL_EMPTYING_HW_QUEUE_ADDBA) {
 		IWL_DEBUG_HT(priv, "AGG stop before setup done\n");
-		ieee80211_stop_tx_ba_cb_irqsafe(priv->hw, ra, tid);
+		ieee80211_stop_tx_ba_cb_irqsafe(priv->vif, ra, tid);
 		priv->stations[sta_id].tid[tid].agg.state = IWL_AGG_OFF;
 		return 0;
 	}
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 0cb5ecc..59d4915 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -84,7 +84,8 @@ struct rxd_ops {
 	int rxd_size;
 	void (*rxd_init)(void *rxd, dma_addr_t next_dma_addr);
 	void (*rxd_refill)(void *rxd, dma_addr_t addr, int len);
-	int (*rxd_process)(void *rxd, struct ieee80211_rx_status *status);
+	int (*rxd_process)(void *rxd, struct ieee80211_rx_status *status,
+			   __le16 *qos);
 };
 
 struct mwl8k_device_info {
@@ -184,7 +185,7 @@ struct mwl8k_priv {
 	/* PHY parameters */
 	struct ieee80211_supported_band band;
 	struct ieee80211_channel channels[14];
-	struct ieee80211_rate rates[13];
+	struct ieee80211_rate rates[14];
 
 	bool radio_on;
 	bool radio_short_preamble;
@@ -220,15 +221,6 @@ struct mwl8k_vif {
 	u8	bssid[ETH_ALEN];
 	u8	mac_addr[ETH_ALEN];
 
-	/*
-	 * Subset of supported legacy rates.
-	 * Intersection of AP and STA supported rates.
-	 */
-	struct ieee80211_rate legacy_rates[13];
-
-	/* number of supported legacy rates */
-	u8	legacy_nrates;
-
 	 /* Index into station database.Returned by update_sta_db call */
 	u8	peer_id;
 
@@ -266,6 +258,11 @@ static const struct ieee80211_rate mwl8k_rates[] = {
 	{ .bitrate = 360, .hw_value = 72, },
 	{ .bitrate = 480, .hw_value = 96, },
 	{ .bitrate = 540, .hw_value = 108, },
+	{ .bitrate = 720, .hw_value = 144, },
+};
+
+static const u8 mwl8k_rateids[12] = {
+	2, 4, 11, 22, 12, 18, 24, 36, 48, 72, 96, 108,
 };
 
 /* Set or get info from Firmware */
@@ -574,7 +571,7 @@ static int mwl8k_load_firmware(struct ieee80211_hw *hw)
 			       "helper image\n", pci_name(priv->pdev));
 			return rc;
 		}
-		msleep(1);
+		msleep(5);
 
 		rc = mwl8k_feed_fw_image(priv, fw->data, fw->size);
 	} else {
@@ -591,9 +588,8 @@ static int mwl8k_load_firmware(struct ieee80211_hw *hw)
 		iowrite32(MWL8K_MODE_AP, priv->regs + MWL8K_HIU_GEN_PTR);
 	else
 		iowrite32(MWL8K_MODE_STA, priv->regs + MWL8K_HIU_GEN_PTR);
-	msleep(1);
 
-	loops = 200000;
+	loops = 500000;
 	do {
 		u32 ready_code;
 
@@ -633,9 +629,6 @@ struct ewc_ht_info {
 /* Peer Entry flags - used to define the type of the peer node */
 #define MWL8K_PEER_TYPE_ACCESSPOINT	2
 
-#define MWL8K_IEEE_LEGACY_DATA_RATES	13
-#define MWL8K_MCS_BITMAP_SIZE		16
-
 struct peer_capability_info {
 	/* Peer type - AP vs. STA.  */
 	__u8	peer_type;
@@ -652,10 +645,10 @@ struct peer_capability_info {
 	struct ewc_ht_info	ewc_info;
 
 	/* Legacy rate table. Intersection of our rates and peer rates.  */
-	__u8	legacy_rates[MWL8K_IEEE_LEGACY_DATA_RATES];
+	__u8	legacy_rates[12];
 
 	/* HT rate table. Intersection of our rates and peer rates.  */
-	__u8	ht_rates[MWL8K_MCS_BITMAP_SIZE];
+	__u8	ht_rates[16];
 	__u8	pad[16];
 
 	/* If set, interoperability mode, no proprietary extensions.  */
@@ -706,55 +699,64 @@ static inline u16 mwl8k_qos_setbit_qlen(u16 qos, u8 len)
 struct mwl8k_dma_data {
 	__le16 fwlen;
 	struct ieee80211_hdr wh;
+	char data[0];
 } __attribute__((packed));
 
 /* Routines to add/remove DMA header from skb.  */
-static inline void mwl8k_remove_dma_header(struct sk_buff *skb)
+static inline void mwl8k_remove_dma_header(struct sk_buff *skb, __le16 qos)
 {
-	struct mwl8k_dma_data *tr = (struct mwl8k_dma_data *)skb->data;
-	void *dst, *src = &tr->wh;
-	int hdrlen = ieee80211_hdrlen(tr->wh.frame_control);
-	u16 space = sizeof(struct mwl8k_dma_data) - hdrlen;
+	struct mwl8k_dma_data *tr;
+	int hdrlen;
 
-	dst = (void *)tr + space;
-	if (dst != src) {
-		memmove(dst, src, hdrlen);
-		skb_pull(skb, space);
+	tr = (struct mwl8k_dma_data *)skb->data;
+	hdrlen = ieee80211_hdrlen(tr->wh.frame_control);
+
+	if (hdrlen != sizeof(tr->wh)) {
+		if (ieee80211_is_data_qos(tr->wh.frame_control)) {
+			memmove(tr->data - hdrlen, &tr->wh, hdrlen - 2);
+			*((__le16 *)(tr->data - 2)) = qos;
+		} else {
+			memmove(tr->data - hdrlen, &tr->wh, hdrlen);
+		}
 	}
+
+	if (hdrlen != sizeof(*tr))
+		skb_pull(skb, sizeof(*tr) - hdrlen);
 }
 
 static inline void mwl8k_add_dma_header(struct sk_buff *skb)
 {
 	struct ieee80211_hdr *wh;
-	u32 hdrlen, pktlen;
+	int hdrlen;
 	struct mwl8k_dma_data *tr;
 
+	/*
+	 * Add a firmware DMA header; the firmware requires that we
+	 * present a 2-byte payload length followed by a 4-address
+	 * header (without QoS field), followed (optionally) by any
+	 * WEP/ExtIV header (but only filled in for CCMP).
+	 */
 	wh = (struct ieee80211_hdr *)skb->data;
+
 	hdrlen = ieee80211_hdrlen(wh->frame_control);
-	pktlen = skb->len;
+	if (hdrlen != sizeof(*tr))
+		skb_push(skb, sizeof(*tr) - hdrlen);
 
-	/*
-	 * Copy up/down the 802.11 header; the firmware requires
-	 * we present a 2-byte payload length followed by a
-	 * 4-address header (w/o QoS), followed (optionally) by
-	 * any WEP/ExtIV header (but only filled in for CCMP).
-	 */
-	if (hdrlen != sizeof(struct mwl8k_dma_data))
-		skb_push(skb, sizeof(struct mwl8k_dma_data) - hdrlen);
+	if (ieee80211_is_data_qos(wh->frame_control))
+		hdrlen -= 2;
 
 	tr = (struct mwl8k_dma_data *)skb->data;
 	if (wh != &tr->wh)
 		memmove(&tr->wh, wh, hdrlen);
-
-	/* Clear addr4 */
-	memset(tr->wh.addr4, 0, ETH_ALEN);
+	if (hdrlen != sizeof(tr->wh))
+		memset(((void *)&tr->wh) + hdrlen, 0, sizeof(tr->wh) - hdrlen);
 
 	/*
 	 * Firmware length is the length of the fully formed "802.11
 	 * payload".  That is, everything except for the 802.11 header.
 	 * This includes all crypto material including the MIC.
 	 */
-	tr->fwlen = cpu_to_le16(pktlen - hdrlen);
+	tr->fwlen = cpu_to_le16(skb->len - sizeof(*tr));
 }
 
 
@@ -779,6 +781,10 @@ struct mwl8k_rxd_8366 {
 	__u8 rx_ctrl;
 } __attribute__((packed));
 
+#define MWL8K_8366_RATE_INFO_MCS_FORMAT		0x80
+#define MWL8K_8366_RATE_INFO_40MHZ		0x40
+#define MWL8K_8366_RATE_INFO_RATEID(x)		((x) & 0x3f)
+
 #define MWL8K_8366_RX_CTRL_OWNED_BY_HOST	0x80
 
 static void mwl8k_rxd_8366_init(void *_rxd, dma_addr_t next_dma_addr)
@@ -800,7 +806,8 @@ static void mwl8k_rxd_8366_refill(void *_rxd, dma_addr_t addr, int len)
 }
 
 static int
-mwl8k_rxd_8366_process(void *_rxd, struct ieee80211_rx_status *status)
+mwl8k_rxd_8366_process(void *_rxd, struct ieee80211_rx_status *status,
+		       __le16 *qos)
 {
 	struct mwl8k_rxd_8366 *rxd = _rxd;
 
@@ -813,9 +820,11 @@ mwl8k_rxd_8366_process(void *_rxd, struct ieee80211_rx_status *status)
 	status->signal = -rxd->rssi;
 	status->noise = -rxd->noise_floor;
 
-	if (rxd->rate & 0x80) {
+	if (rxd->rate & MWL8K_8366_RATE_INFO_MCS_FORMAT) {
 		status->flag |= RX_FLAG_HT;
-		status->rate_idx = rxd->rate & 0x7f;
+		if (rxd->rate & MWL8K_8366_RATE_INFO_40MHZ)
+			status->flag |= RX_FLAG_40MHZ;
+		status->rate_idx = MWL8K_8366_RATE_INFO_RATEID(rxd->rate);
 	} else {
 		int i;
 
@@ -830,6 +839,8 @@ mwl8k_rxd_8366_process(void *_rxd, struct ieee80211_rx_status *status)
 	status->band = IEEE80211_BAND_2GHZ;
 	status->freq = ieee80211_channel_to_frequency(rxd->channel);
 
+	*qos = rxd->qos_control;
+
 	return le16_to_cpu(rxd->pkt_len);
 }
 
@@ -888,7 +899,8 @@ static void mwl8k_rxd_8687_refill(void *_rxd, dma_addr_t addr, int len)
 }
 
 static int
-mwl8k_rxd_8687_process(void *_rxd, struct ieee80211_rx_status *status)
+mwl8k_rxd_8687_process(void *_rxd, struct ieee80211_rx_status *status,
+		       __le16 *qos)
 {
 	struct mwl8k_rxd_8687 *rxd = _rxd;
 	u16 rate_info;
@@ -903,7 +915,6 @@ mwl8k_rxd_8687_process(void *_rxd, struct ieee80211_rx_status *status)
 
 	status->signal = -rxd->rssi;
 	status->noise = -rxd->noise_level;
-	status->qual = rxd->link_quality;
 	status->antenna = MWL8K_8687_RATE_INFO_ANTSELECT(rate_info);
 	status->rate_idx = MWL8K_8687_RATE_INFO_RATEID(rate_info);
 
@@ -919,6 +930,8 @@ mwl8k_rxd_8687_process(void *_rxd, struct ieee80211_rx_status *status)
 	status->band = IEEE80211_BAND_2GHZ;
 	status->freq = ieee80211_channel_to_frequency(rxd->channel);
 
+	*qos = rxd->qos_control;
+
 	return le16_to_cpu(rxd->pkt_len);
 }
 
@@ -1090,6 +1103,7 @@ static int rxq_process(struct ieee80211_hw *hw, int index, int limit)
 		void *rxd;
 		int pkt_len;
 		struct ieee80211_rx_status status;
+		__le16 qos;
 
 		skb = rxq->buf[rxq->head].skb;
 		if (skb == NULL)
@@ -1097,7 +1111,7 @@ static int rxq_process(struct ieee80211_hw *hw, int index, int limit)
 
 		rxd = rxq->rxd + (rxq->head * priv->rxd_ops->rxd_size);
 
-		pkt_len = priv->rxd_ops->rxd_process(rxd, &status);
+		pkt_len = priv->rxd_ops->rxd_process(rxd, &status, &qos);
 		if (pkt_len < 0)
 			break;
 
@@ -1115,7 +1129,7 @@ static int rxq_process(struct ieee80211_hw *hw, int index, int limit)
 		rxq->rxd_count--;
 
 		skb_put(skb, pkt_len);
-		mwl8k_remove_dma_header(skb);
+		mwl8k_remove_dma_header(skb, qos);
 
 		/*
 		 * Check for a pending join operation.  Save a
@@ -1221,99 +1235,106 @@ static inline void mwl8k_tx_start(struct mwl8k_priv *priv)
 	ioread32(priv->regs + MWL8K_HIU_INT_CODE);
 }
 
-struct mwl8k_txq_info {
-	u32 fw_owned;
-	u32 drv_owned;
-	u32 unused;
-	u32 len;
-	u32 head;
-	u32 tail;
-};
-
-static int mwl8k_scan_tx_ring(struct mwl8k_priv *priv,
-				struct mwl8k_txq_info *txinfo)
+static void mwl8k_dump_tx_rings(struct ieee80211_hw *hw)
 {
-	int count, desc, status;
-	struct mwl8k_tx_queue *txq;
-	struct mwl8k_tx_desc *tx_desc;
-	int ndescs = 0;
+	struct mwl8k_priv *priv = hw->priv;
+	int i;
 
-	memset(txinfo, 0, MWL8K_TX_QUEUES * sizeof(struct mwl8k_txq_info));
+	for (i = 0; i < MWL8K_TX_QUEUES; i++) {
+		struct mwl8k_tx_queue *txq = priv->txq + i;
+		int fw_owned = 0;
+		int drv_owned = 0;
+		int unused = 0;
+		int desc;
 
-	for (count = 0; count < MWL8K_TX_QUEUES; count++) {
-		txq = priv->txq + count;
-		txinfo[count].len = txq->stats.len;
-		txinfo[count].head = txq->head;
-		txinfo[count].tail = txq->tail;
 		for (desc = 0; desc < MWL8K_TX_DESCS; desc++) {
-			tx_desc = txq->txd + desc;
-			status = le32_to_cpu(tx_desc->status);
+			struct mwl8k_tx_desc *tx_desc = txq->txd + desc;
+			u32 status;
 
+			status = le32_to_cpu(tx_desc->status);
 			if (status & MWL8K_TXD_STATUS_FW_OWNED)
-				txinfo[count].fw_owned++;
+				fw_owned++;
 			else
-				txinfo[count].drv_owned++;
+				drv_owned++;
 
 			if (tx_desc->pkt_len == 0)
-				txinfo[count].unused++;
+				unused++;
 		}
-	}
 
-	return ndescs;
+		printk(KERN_ERR "%s: txq[%d] len=%d head=%d tail=%d "
+		       "fw_owned=%d drv_owned=%d unused=%d\n",
+		       wiphy_name(hw->wiphy), i,
+		       txq->stats.len, txq->head, txq->tail,
+		       fw_owned, drv_owned, unused);
+	}
 }
 
 /*
  * Must be called with priv->fw_mutex held and tx queues stopped.
  */
+#define MWL8K_TX_WAIT_TIMEOUT_MS	1000
+
 static int mwl8k_tx_wait_empty(struct ieee80211_hw *hw)
 {
 	struct mwl8k_priv *priv = hw->priv;
 	DECLARE_COMPLETION_ONSTACK(tx_wait);
-	u32 count;
-	unsigned long timeout;
+	int retry;
+	int rc;
 
 	might_sleep();
 
+	/*
+	 * The TX queues are stopped at this point, so this test
+	 * doesn't need to take ->tx_lock.
+	 */
+	if (!priv->pending_tx_pkts)
+		return 0;
+
+	retry = 0;
+	rc = 0;
+
 	spin_lock_bh(&priv->tx_lock);
-	count = priv->pending_tx_pkts;
-	if (count)
-		priv->tx_wait = &tx_wait;
-	spin_unlock_bh(&priv->tx_lock);
+	priv->tx_wait = &tx_wait;
+	while (!rc) {
+		int oldcount;
+		unsigned long timeout;
 
-	if (count) {
-		struct mwl8k_txq_info txinfo[MWL8K_TX_QUEUES];
-		int index;
-		int newcount;
+		oldcount = priv->pending_tx_pkts;
 
+		spin_unlock_bh(&priv->tx_lock);
 		timeout = wait_for_completion_timeout(&tx_wait,
-					msecs_to_jiffies(5000));
-		if (timeout)
-			return 0;
-
+			    msecs_to_jiffies(MWL8K_TX_WAIT_TIMEOUT_MS));
 		spin_lock_bh(&priv->tx_lock);
-		priv->tx_wait = NULL;
-		newcount = priv->pending_tx_pkts;
-		mwl8k_scan_tx_ring(priv, txinfo);
-		spin_unlock_bh(&priv->tx_lock);
 
-		printk(KERN_ERR "%s(%u) TIMEDOUT:5000ms Pend:%u-->%u\n",
-		       __func__, __LINE__, count, newcount);
+		if (timeout) {
+			WARN_ON(priv->pending_tx_pkts);
+			if (retry) {
+				printk(KERN_NOTICE "%s: tx rings drained\n",
+				       wiphy_name(hw->wiphy));
+			}
+			break;
+		}
 
-		for (index = 0; index < MWL8K_TX_QUEUES; index++)
-			printk(KERN_ERR "TXQ:%u L:%u H:%u T:%u FW:%u "
-			       "DRV:%u U:%u\n",
-					index,
-					txinfo[index].len,
-					txinfo[index].head,
-					txinfo[index].tail,
-					txinfo[index].fw_owned,
-					txinfo[index].drv_owned,
-					txinfo[index].unused);
+		if (priv->pending_tx_pkts < oldcount) {
+			printk(KERN_NOTICE "%s: timeout waiting for tx "
+			       "rings to drain (%d -> %d pkts), retrying\n",
+			       wiphy_name(hw->wiphy), oldcount,
+			       priv->pending_tx_pkts);
+			retry = 1;
+			continue;
+		}
 
-		return -ETIMEDOUT;
+		priv->tx_wait = NULL;
+
+		printk(KERN_ERR "%s: tx rings stuck for %d ms\n",
+		       wiphy_name(hw->wiphy), MWL8K_TX_WAIT_TIMEOUT_MS);
+		mwl8k_dump_tx_rings(hw);
+
+		rc = -ETIMEDOUT;
 	}
+	spin_unlock_bh(&priv->tx_lock);
 
-	return 0;
+	return rc;
 }
 
 #define MWL8K_TXD_SUCCESS(status)				\
@@ -1361,7 +1382,7 @@ static void mwl8k_txq_reclaim(struct ieee80211_hw *hw, int index, int force)
 		BUG_ON(skb == NULL);
 		pci_unmap_single(priv->pdev, addr, size, PCI_DMA_TODEVICE);
 
-		mwl8k_remove_dma_header(skb);
+		mwl8k_remove_dma_header(skb, tx_desc->qos_control);
 
 		/* Mark descriptor as unused */
 		tx_desc->pkt_phys_addr = 0;
@@ -1563,8 +1584,8 @@ static void mwl8k_fw_unlock(struct ieee80211_hw *hw)
  * Command processing.
  */
 
-/* Timeout firmware commands after 2000ms */
-#define MWL8K_CMD_TIMEOUT_MS	2000
+/* Timeout firmware commands after 10s */
+#define MWL8K_CMD_TIMEOUT_MS	10000
 
 static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 {
@@ -1615,12 +1636,21 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 		       MWL8K_CMD_TIMEOUT_MS);
 		rc = -ETIMEDOUT;
 	} else {
+		int ms;
+
+		ms = MWL8K_CMD_TIMEOUT_MS - jiffies_to_msecs(timeout);
+
 		rc = cmd->result ? -EINVAL : 0;
 		if (rc)
 			printk(KERN_ERR "%s: Command %s error 0x%x\n",
 			       wiphy_name(hw->wiphy),
 			       mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
 			       le16_to_cpu(cmd->result));
+		else if (ms > 2000)
+			printk(KERN_NOTICE "%s: Command %s took %d ms\n",
+			       wiphy_name(hw->wiphy),
+			       mwl8k_cmd_name(cmd->code, buf, sizeof(buf)),
+			       ms);
 	}
 
 	return rc;
@@ -2439,8 +2469,6 @@ mwl8k_set_edca_params(struct ieee80211_hw *hw, __u8 qnum,
 /*
  * CMD_FINALIZE_JOIN.
  */
-
-/* FJ beacon buffer size is compiled into the firmware.  */
 #define MWL8K_FJ_BEACON_MAXLEN	128
 
 struct mwl8k_cmd_finalize_join {
@@ -2450,17 +2478,13 @@ struct mwl8k_cmd_finalize_join {
 } __attribute__((packed));
 
 static int mwl8k_finalize_join(struct ieee80211_hw *hw, void *frame,
-				__u16 framelen, __u16 dtim)
+			       int framelen, int dtim)
 {
 	struct mwl8k_cmd_finalize_join *cmd;
 	struct ieee80211_mgmt *payload = frame;
-	u16 hdrlen;
-	u32 payload_len;
+	int payload_len;
 	int rc;
 
-	if (frame == NULL)
-		return -EINVAL;
-
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (cmd == NULL)
 		return -ENOMEM;
@@ -2469,24 +2493,17 @@ static int mwl8k_finalize_join(struct ieee80211_hw *hw, void *frame,
 	cmd->header.length = cpu_to_le16(sizeof(*cmd));
 	cmd->sleep_interval = cpu_to_le32(dtim ? dtim : 1);
 
-	hdrlen = ieee80211_hdrlen(payload->frame_control);
-
-	payload_len = framelen > hdrlen ? framelen - hdrlen : 0;
-
-	/* XXX TBD Might just have to abort and return an error */
-	if (payload_len > MWL8K_FJ_BEACON_MAXLEN)
-		printk(KERN_ERR "%s(): WARNING: Incomplete beacon "
-		       "sent to firmware. Sz=%u MAX=%u\n", __func__,
-		       payload_len, MWL8K_FJ_BEACON_MAXLEN);
-
-	if (payload_len > MWL8K_FJ_BEACON_MAXLEN)
+	payload_len = framelen - ieee80211_hdrlen(payload->frame_control);
+	if (payload_len < 0)
+		payload_len = 0;
+	else if (payload_len > MWL8K_FJ_BEACON_MAXLEN)
 		payload_len = MWL8K_FJ_BEACON_MAXLEN;
 
-	if (payload && payload_len)
-		memcpy(cmd->beacon_data, &payload->u.beacon, payload_len);
+	memcpy(cmd->beacon_data, &payload->u.beacon, payload_len);
 
 	rc = mwl8k_post_cmd(hw, &cmd->header);
 	kfree(cmd);
+
 	return rc;
 }
 
@@ -2515,9 +2532,7 @@ static int mwl8k_cmd_update_sta_db(struct ieee80211_hw *hw,
 	struct ieee80211_bss_conf *info = &mv_vif->bss_info;
 	struct mwl8k_cmd_update_sta_db *cmd;
 	struct peer_capability_info *peer_info;
-	struct ieee80211_rate *bitrates = mv_vif->legacy_rates;
 	int rc;
-	__u8 count, *rates;
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (cmd == NULL)
@@ -2536,13 +2551,11 @@ static int mwl8k_cmd_update_sta_db(struct ieee80211_hw *hw,
 		/* Build peer_info block */
 		peer_info->peer_type = MWL8K_PEER_TYPE_ACCESSPOINT;
 		peer_info->basic_caps = cpu_to_le16(info->assoc_capability);
+		memcpy(peer_info->legacy_rates, mwl8k_rateids,
+		       sizeof(mwl8k_rateids));
 		peer_info->interop = 1;
 		peer_info->amsdu_enabled = 0;
 
-		rates = peer_info->legacy_rates;
-		for (count = 0; count < mv_vif->legacy_nrates; count++)
-			rates[count] = bitrates[count].hw_value;
-
 		rc = mwl8k_post_cmd(hw, &cmd->header);
 		if (rc == 0)
 			mv_vif->peer_id = peer_info->station_id;
@@ -2565,8 +2578,6 @@ static int mwl8k_cmd_update_sta_db(struct ieee80211_hw *hw,
 /*
  * CMD_SET_AID.
  */
-#define MWL8K_RATE_INDEX_MAX_ARRAY			14
-
 #define MWL8K_FRAME_PROT_DISABLED			0x00
 #define MWL8K_FRAME_PROT_11G				0x07
 #define MWL8K_FRAME_PROT_11N_HT_40MHZ_ONLY		0x02
@@ -2579,7 +2590,7 @@ struct mwl8k_cmd_update_set_aid {
 	 /* AP's MAC address (BSSID) */
 	__u8	bssid[ETH_ALEN];
 	__le16	protection_mode;
-	__u8	supp_rates[MWL8K_RATE_INDEX_MAX_ARRAY];
+	__u8	supp_rates[14];
 } __attribute__((packed));
 
 static int mwl8k_cmd_set_aid(struct ieee80211_hw *hw,
@@ -2588,8 +2599,6 @@ static int mwl8k_cmd_set_aid(struct ieee80211_hw *hw,
 	struct mwl8k_vif *mv_vif = MWL8K_VIF(vif);
 	struct ieee80211_bss_conf *info = &mv_vif->bss_info;
 	struct mwl8k_cmd_update_set_aid *cmd;
-	struct ieee80211_rate *bitrates = mv_vif->legacy_rates;
-	int count;
 	u16 prot_mode;
 	int rc;
 
@@ -2621,8 +2630,7 @@ static int mwl8k_cmd_set_aid(struct ieee80211_hw *hw,
 	}
 	cmd->protection_mode = cpu_to_le16(prot_mode);
 
-	for (count = 0; count < mv_vif->legacy_nrates; count++)
-		cmd->supp_rates[count] = bitrates[count].hw_value;
+	memcpy(cmd->supp_rates, mwl8k_rateids, sizeof(mwl8k_rateids));
 
 	rc = mwl8k_post_cmd(hw, &cmd->header);
 	kfree(cmd);
@@ -2635,20 +2643,17 @@ static int mwl8k_cmd_set_aid(struct ieee80211_hw *hw,
  */
 struct mwl8k_cmd_update_rateset {
 	struct	mwl8k_cmd_pkt header;
-	__u8	legacy_rates[MWL8K_RATE_INDEX_MAX_ARRAY];
+	__u8	legacy_rates[14];
 
 	/* Bitmap for supported MCS codes.  */
-	__u8	mcs_set[MWL8K_IEEE_LEGACY_DATA_RATES];
-	__u8	reserved[MWL8K_IEEE_LEGACY_DATA_RATES];
+	__u8	mcs_set[16];
+	__u8	reserved[16];
 } __attribute__((packed));
 
 static int mwl8k_update_rateset(struct ieee80211_hw *hw,
 		struct ieee80211_vif *vif)
 {
-	struct mwl8k_vif *mv_vif = MWL8K_VIF(vif);
 	struct mwl8k_cmd_update_rateset *cmd;
-	struct ieee80211_rate *bitrates = mv_vif->legacy_rates;
-	int count;
 	int rc;
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
@@ -2657,9 +2662,7 @@ static int mwl8k_update_rateset(struct ieee80211_hw *hw,
 
 	cmd->header.code = cpu_to_le16(MWL8K_CMD_SET_RATE);
 	cmd->header.length = cpu_to_le16(sizeof(*cmd));
-
-	for (count = 0; count < mv_vif->legacy_nrates; count++)
-		cmd->legacy_rates[count] = bitrates[count].hw_value;
+	memcpy(cmd->legacy_rates, mwl8k_rateids, sizeof(mwl8k_rateids));
 
 	rc = mwl8k_post_cmd(hw, &cmd->header);
 	kfree(cmd);
@@ -2932,11 +2935,6 @@ static int mwl8k_add_interface(struct ieee80211_hw *hw,
 	/* Back pointer to parent config block */
 	mwl8k_vif->priv = priv;
 
-	/* Setup initial PHY parameters */
-	memcpy(mwl8k_vif->legacy_rates,
-		priv->rates, sizeof(mwl8k_vif->legacy_rates));
-	mwl8k_vif->legacy_nrates = ARRAY_SIZE(priv->rates);
-
 	/* Set Initial sequence number to zero */
 	mwl8k_vif->seqno = 0;
 
@@ -3014,9 +3012,6 @@ static void mwl8k_bss_info_changed(struct ieee80211_hw *hw,
 	struct mwl8k_vif *mwl8k_vif = MWL8K_VIF(vif);
 	int rc;
 
-	if (changed & BSS_CHANGED_BSSID)
-		memcpy(mwl8k_vif->bssid, info->bssid, ETH_ALEN);
-
 	if ((changed & BSS_CHANGED_ASSOC) == 0)
 		return;
 
@@ -3030,6 +3025,8 @@ static void mwl8k_bss_info_changed(struct ieee80211_hw *hw,
 		memcpy(&mwl8k_vif->bss_info, info,
 			sizeof(struct ieee80211_bss_conf));
 
+		memcpy(mwl8k_vif->bssid, info->bssid, ETH_ALEN);
+
 		/* Install rates */
 		rc = mwl8k_update_rateset(hw, vif);
 		if (rc)
@@ -3366,7 +3363,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	if (rc) {
 		printk(KERN_ERR "%s: Cannot obtain PCI resources\n",
 		       MWL8K_NAME);
-		return rc;
+		goto err_disable_device;
 	}
 
 	pci_set_master(pdev);
@@ -3597,6 +3594,8 @@ err_iounmap:
 
 err_free_reg:
 	pci_release_regions(pdev);
+
+err_disable_device:
 	pci_disable_device(pdev);
 
 	return rc;
diff --git a/drivers/net/wireless/orinoco/hermes_dld.c b/drivers/net/wireless/orinoco/hermes_dld.c
index a3eefe1..6d5660d 100644
--- a/drivers/net/wireless/orinoco/hermes_dld.c
+++ b/drivers/net/wireless/orinoco/hermes_dld.c
@@ -427,7 +427,7 @@ int hermesi_program_init(hermes_t *hw, u32 offset)
 	if (err)
 		return err;
 
-	pr_debug(KERN_DEBUG PFX "Enabling volatile, EP 0x%08x\n", offset);
+	pr_debug(PFX "Enabling volatile, EP 0x%08x\n", offset);
 	err = hermes_doicmd_wait(hw,
 				 HERMES_PROGRAM_ENABLE_VOLATILE,
 				 offset & 0xFFFFu,
diff --git a/drivers/net/wireless/rtl818x/rtl8187.h b/drivers/net/wireless/rtl818x/rtl8187.h
index abb4907..b1a24de 100644
--- a/drivers/net/wireless/rtl818x/rtl8187.h
+++ b/drivers/net/wireless/rtl818x/rtl8187.h
@@ -23,6 +23,7 @@
 #define RTL8187_EEPROM_TXPWR_CHAN_1	0x16	/* 3 channels */
 #define RTL8187_EEPROM_TXPWR_CHAN_6	0x1B	/* 2 channels */
 #define RTL8187_EEPROM_TXPWR_CHAN_4	0x3D	/* 2 channels */
+#define RTL8187_EEPROM_SELECT_GPIO	0x3B
 
 #define RTL8187_REQT_READ	0xC0
 #define RTL8187_REQT_WRITE	0x40
@@ -31,6 +32,9 @@
 
 #define RTL8187_MAX_RX		0x9C4
 
+#define RFKILL_MASK_8187_89_97	0x2
+#define RFKILL_MASK_8198	0x4
+
 struct rtl8187_rx_info {
 	struct urb *urb;
 	struct ieee80211_hw *dev;
@@ -122,6 +126,7 @@ struct rtl8187_priv {
 	u8 noise;
 	u8 slot_time;
 	u8 aifsn[4];
+	u8 rfkill_mask;
 	struct {
 		__le64 buf;
 		struct sk_buff_head queue;
diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
index 76973b8..bc5726d 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
@@ -1322,6 +1322,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	struct ieee80211_channel *channel;
 	const char *chip_name;
 	u16 txpwr, reg;
+	u16 product_id = le16_to_cpu(udev->descriptor.idProduct);
 	int err, i;
 
 	dev = ieee80211_alloc_hw(sizeof(*priv), &rtl8187_ops);
@@ -1481,6 +1482,13 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 		(*channel++).hw_value = txpwr & 0xFF;
 		(*channel++).hw_value = txpwr >> 8;
 	}
+	/* Handle the differing rfkill GPIO bit in different models */
+	priv->rfkill_mask = RFKILL_MASK_8187_89_97;
+	if (product_id == 0x8197 || product_id == 0x8198) {
+		eeprom_93cx6_read(&eeprom, RTL8187_EEPROM_SELECT_GPIO, &reg);
+		if (reg & 0xFF00)
+			priv->rfkill_mask = RFKILL_MASK_8198;
+	}
 
 	/*
 	 * XXX: Once this driver supports anything that requires
@@ -1509,9 +1517,9 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	mutex_init(&priv->conf_mutex);
 	skb_queue_head_init(&priv->b_tx_status.queue);
 
-	printk(KERN_INFO "%s: hwaddr %pM, %s V%d + %s\n",
+	printk(KERN_INFO "%s: hwaddr %pM, %s V%d + %s, rfkill mask %d\n",
 	       wiphy_name(dev->wiphy), dev->wiphy->perm_addr,
-	       chip_name, priv->asic_rev, priv->rf->name);
+	       chip_name, priv->asic_rev, priv->rf->name, priv->rfkill_mask);
 
 #ifdef CONFIG_RTL8187_LEDS
 	eeprom_93cx6_read(&eeprom, 0x3F, &reg);
diff --git a/drivers/net/wireless/rtl818x/rtl8187_rfkill.c b/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
index cad8037..03555e1 100644
--- a/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
+++ b/drivers/net/wireless/rtl818x/rtl8187_rfkill.c
@@ -25,10 +25,10 @@ static bool rtl8187_is_radio_enabled(struct rtl8187_priv *priv)
 	u8 gpio;
 
 	gpio = rtl818x_ioread8(priv, &priv->map->GPIO0);
-	rtl818x_iowrite8(priv, &priv->map->GPIO0, gpio & ~0x02);
+	rtl818x_iowrite8(priv, &priv->map->GPIO0, gpio & ~priv->rfkill_mask);
 	gpio = rtl818x_ioread8(priv, &priv->map->GPIO1);
 
-	return gpio & 0x02;
+	return gpio & priv->rfkill_mask;
 }
 
 void rtl8187_rfkill_init(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/wl12xx/wl1251_main.c b/drivers/net/wireless/wl12xx/wl1251_main.c
index ff4be7b..2f50a25 100644
--- a/drivers/net/wireless/wl12xx/wl1251_main.c
+++ b/drivers/net/wireless/wl12xx/wl1251_main.c
@@ -629,10 +629,6 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 			goto out_sleep;
 	}
 
-	ret = wl1251_build_null_data(wl);
-	if (ret < 0)
-		goto out_sleep;
-
 	if (conf->flags & IEEE80211_CONF_PS && !wl->psm_requested) {
 		wl1251_debug(DEBUG_PSM, "psm enabled");
 
@@ -1110,6 +1106,21 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 	if (ret < 0)
 		goto out;
 
+	if (changed & BSS_CHANGED_BSSID) {
+		memcpy(wl->bssid, bss_conf->bssid, ETH_ALEN);
+
+		ret = wl1251_build_null_data(wl);
+		if (ret < 0)
+			goto out;
+
+		if (wl->bss_type != BSS_TYPE_IBSS) {
+			ret = wl1251_join(wl, wl->bss_type, wl->channel,
+					  wl->beacon_int, wl->dtim_period);
+			if (ret < 0)
+				goto out_sleep;
+		}
+	}
+
 	if (changed & BSS_CHANGED_ASSOC) {
 		if (bss_conf->assoc) {
 			wl->beacon_int = bss_conf->beacon_int;
@@ -1169,23 +1180,6 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 	}
 
-	if (changed & BSS_CHANGED_BSSID) {
-		memcpy(wl->bssid, bss_conf->bssid, ETH_ALEN);
-
-		ret = wl1251_build_null_data(wl);
-		if (ret < 0)
-			goto out;
-
-		if (wl->bss_type != BSS_TYPE_IBSS) {
-			ret = wl1251_join(wl, wl->bss_type, wl->channel,
-					  wl->beacon_int, wl->dtim_period);
-			if (ret < 0)
-				goto out_sleep;
-			wl1251_warning("Set ctsprotect failed %d", ret);
-			goto out_sleep;
-		}
-	}
-
 	if (changed & BSS_CHANGED_BEACON) {
 		beacon = ieee80211_beacon_get(hw, vif);
 		ret = wl1251_cmd_template_set(wl, CMD_BEACON, beacon->data,
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 419f186..91dc863 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -746,6 +746,7 @@ struct ieee80211_local {
 	unsigned int wmm_acm; /* bit field of ACM bits (BIT(802.1D tag)) */
 
 	bool pspolling;
+	bool scan_ps_enabled;
 	/*
 	 * PS can only be enabled when we have exactly one managed
 	 * interface (and monitors) in PS, this then points there.
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 6dc7b5a..d8d50fb 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1083,8 +1083,6 @@ static void ieee80211_set_disassoc(struct ieee80211_sub_if_data *sdata,
 
 	ieee80211_set_wmm_default(sdata);
 
-	ieee80211_recalc_idle(local);
-
 	/* channel(_type) changes are handled by ieee80211_hw_config */
 	local->oper_channel_type = NL80211_CHAN_NO_HT;
 
@@ -1370,6 +1368,7 @@ ieee80211_rx_mgmt_deauth(struct ieee80211_sub_if_data *sdata,
 
 	if (!wk) {
 		ieee80211_set_disassoc(sdata, true);
+		ieee80211_recalc_idle(sdata->local);
 	} else {
 		list_del(&wk->list);
 		kfree(wk);
@@ -1403,6 +1402,7 @@ ieee80211_rx_mgmt_disassoc(struct ieee80211_sub_if_data *sdata,
 			sdata->dev->name, mgmt->sa, reason_code);
 
 	ieee80211_set_disassoc(sdata, false);
+	ieee80211_recalc_idle(sdata->local);
 	return RX_MGMT_CFG80211_DISASSOC;
 }
 
@@ -2117,6 +2117,7 @@ static void ieee80211_sta_work(struct work_struct *work)
 				" after %dms, disconnecting.\n",
 				bssid, (1000 * IEEE80211_PROBE_WAIT)/HZ);
 			ieee80211_set_disassoc(sdata, true);
+			ieee80211_recalc_idle(local);
 			mutex_unlock(&ifmgd->mtx);
 			/*
 			 * must be outside lock due to cfg80211,
@@ -2560,6 +2561,8 @@ int ieee80211_mgd_deauth(struct ieee80211_sub_if_data *sdata,
 			IEEE80211_STYPE_DEAUTH, req->reason_code,
 			cookie);
 
+	ieee80211_recalc_idle(sdata->local);
+
 	return 0;
 }
 
@@ -2592,5 +2595,8 @@ int ieee80211_mgd_disassoc(struct ieee80211_sub_if_data *sdata,
 	ieee80211_send_deauth_disassoc(sdata, req->bss->bssid,
 			IEEE80211_STYPE_DISASSOC, req->reason_code,
 			cookie);
+
+	ieee80211_recalc_idle(sdata->local);
+
 	return 0;
 }
diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 4cf387c..f1a4c71 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -227,7 +227,8 @@ static bool ieee80211_prep_hw_scan(struct ieee80211_local *local)
 static void ieee80211_scan_ps_enable(struct ieee80211_sub_if_data *sdata)
 {
 	struct ieee80211_local *local = sdata->local;
-	bool ps = false;
+
+	local->scan_ps_enabled = false;
 
 	/* FIXME: what to do when local->pspolling is true? */
 
@@ -235,12 +236,13 @@ static void ieee80211_scan_ps_enable(struct ieee80211_sub_if_data *sdata)
 	cancel_work_sync(&local->dynamic_ps_enable_work);
 
 	if (local->hw.conf.flags & IEEE80211_CONF_PS) {
-		ps = true;
+		local->scan_ps_enabled = true;
 		local->hw.conf.flags &= ~IEEE80211_CONF_PS;
 		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_PS);
 	}
 
-	if (!ps || !(local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK))
+	if (!(local->scan_ps_enabled) ||
+	    !(local->hw.flags & IEEE80211_HW_PS_NULLFUNC_STACK))
 		/*
 		 * If power save was enabled, no need to send a nullfunc
 		 * frame because AP knows that we are sleeping. But if the
@@ -261,7 +263,7 @@ static void ieee80211_scan_ps_disable(struct ieee80211_sub_if_data *sdata)
 
 	if (!local->ps_sdata)
 		ieee80211_send_nullfunc(local, sdata, 0);
-	else {
+	else if (local->scan_ps_enabled) {
 		/*
 		 * In !IEEE80211_HW_PS_NULLFUNC_STACK case the hardware
 		 * will send a nullfunc frame with the powersave bit set
@@ -277,6 +279,16 @@ static void ieee80211_scan_ps_disable(struct ieee80211_sub_if_data *sdata)
 		 */
 		local->hw.conf.flags |= IEEE80211_CONF_PS;
 		ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_PS);
+	} else if (local->hw.conf.dynamic_ps_timeout > 0) {
+		/*
+		 * If IEEE80211_CONF_PS was not set and the dynamic_ps_timer
+		 * had been running before leaving the operating channel,
+		 * restart the timer now and send a nullfunc frame to inform
+		 * the AP that we are awake.
+		 */
+		ieee80211_send_nullfunc(local, sdata, 0);
+		mod_timer(&local->dynamic_ps_timer, jiffies +
+			  msecs_to_jiffies(local->hw.conf.dynamic_ps_timeout));
 	}
 }
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index d09f78b..78a6e92 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -579,7 +579,7 @@ u32 ieee802_11_parse_elems_crc(u8 *start, size_t len,
 		if (elen > left)
 			break;
 
-		if (calc_crc && id < 64 && (filter & BIT(id)))
+		if (calc_crc && id < 64 && (filter & (1ULL << id)))
 			crc = crc32_be(crc, pos - 2, elen + 2);
 
 		switch (id) {
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 448e5a0..c218e07 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -579,6 +579,8 @@ static ssize_t rfkill_name_show(struct device *dev,
 
 static const char *rfkill_get_type_str(enum rfkill_type type)
 {
+	BUILD_BUG_ON(NUM_RFKILL_TYPES != RFKILL_TYPE_FM + 1);
+
 	switch (type) {
 	case RFKILL_TYPE_WLAN:
 		return "wlan";
@@ -597,8 +599,6 @@ static const char *rfkill_get_type_str(enum rfkill_type type)
 	default:
 		BUG();
 	}
