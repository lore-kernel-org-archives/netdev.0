From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-04-22
Date: Fri, 22 Apr 2011 16:11:43 -0400
Message-ID: <20110422201142.GA27119@tuxdriver.com>
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

Here are some fixes intended for 2.6.39...

This includes a Bluetooth pull, described thusly by Gustavo:

	Four small fixes for 2.6.39. An incorrect refcnt balance for
	hci connection by Ville Tervo, a warning fix in the command
	timer by Vinicius Gomes, an ERTM fix by Ruiyi Zhang, and SCO
	synchronization fix by Luiz Augusto von Dentz.

On top of those, there are some use-after-free fixes from Stansilaw for
iwlegacy and iwlwifi, a mac80211 debugfs locking fix from Johannes, and
a small logic fix for the return code of ath9k's ah_stoprecv from Felix,
and an iwlwifi fix for frame injection from Daniel Halperin.

Please let me know if there are problems!

John

---

The following changes since commit f01cb5fbea1c1613621f9f32f385e12c1a29dde0:

  Revert "bridge: Forward reserved group addresses if !STP" (2011-04-21 21:17:25 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Daniel Halperin (1):
      iwlwifi: fix frame injection for HT channels

Felix Fietkau (1):
      ath9k: fix the return value of ath_stoprecv

Johannes Berg (1):
      mac80211: fix SMPS debugfs locking

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6

Luiz Augusto von Dentz (1):
      Bluetooth: fix shutdown on SCO sockets

Ruiyi Zhang (1):
      Bluetooth: Only keeping SAR bits when retransmitting one frame.

Stanislaw Gruszka (2):
      iwlwifi: fix skb usage after free
      iwl4965: fix skb usage after free

Ville Tervo (1):
      Bluetooth: Fix refcount balance for hci connection

Vinicius Costa Gomes (1):
      Bluetooth: Fix keeping the command timer running

 drivers/net/wireless/ath/ath9k/recv.c       |    2 +-
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c |   10 +++++++---
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |    7 +------
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |   10 +++++++---
 net/bluetooth/hci_core.c                    |    5 ++---
 net/bluetooth/hci_event.c                   |    2 --
 net/bluetooth/l2cap_core.c                  |    1 +
 net/bluetooth/sco.c                         |    9 +++++++++
 net/mac80211/cfg.c                          |    2 ++
 net/mac80211/debugfs_netdev.c               |    4 ++--
 10 files changed, 32 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index dcd19bc..b29c80d 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -506,7 +506,7 @@ bool ath_stoprecv(struct ath_softc *sc)
 			"confusing the DMA engine when we start RX up\n");
 		ATH_DBG_WARN_ON_ONCE(!stopped);
 	}
-	return stopped || reset;
+	return stopped && !reset;
 }
 
 void ath_flushrecv(struct ath_softc *sc)
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-tx.c b/drivers/net/wireless/iwlegacy/iwl-4965-tx.c
index 5c40502..fbec88d 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-tx.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-tx.c
@@ -1127,12 +1127,16 @@ int iwl4965_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 	     q->read_ptr = iwl_legacy_queue_inc_wrap(q->read_ptr, q->n_bd)) {
 
 		tx_info = &txq->txb[txq->q.read_ptr];
-		iwl4965_tx_status(priv, tx_info,
-				 txq_id >= IWL4965_FIRST_AMPDU_QUEUE);
+
+		if (WARN_ON_ONCE(tx_info->skb == NULL))
+			continue;
 
 		hdr = (struct ieee80211_hdr *)tx_info->skb->data;
-		if (hdr && ieee80211_is_data_qos(hdr->frame_control))
+		if (ieee80211_is_data_qos(hdr->frame_control))
 			nfreed++;
+
+		iwl4965_tx_status(priv, tx_info,
+				 txq_id >= IWL4965_FIRST_AMPDU_QUEUE);
 		tx_info->skb = NULL;
 
 		priv->cfg->ops->lib->txq_free_tfd(priv, txq);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
index dfdbea6..fbbde07 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rxon.c
@@ -335,7 +335,6 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 	struct ieee80211_channel *channel = conf->channel;
 	const struct iwl_channel_info *ch_info;
 	int ret = 0;
-	bool ht_changed[NUM_IWL_RXON_CTX] = {};
 
 	IWL_DEBUG_MAC80211(priv, "changed %#x", changed);
 
@@ -383,10 +382,8 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 
 		for_each_context(priv, ctx) {
 			/* Configure HT40 channels */
-			if (ctx->ht.enabled != conf_is_ht(conf)) {
+			if (ctx->ht.enabled != conf_is_ht(conf))
 				ctx->ht.enabled = conf_is_ht(conf);
-				ht_changed[ctx->ctxid] = true;
-			}
 
 			if (ctx->ht.enabled) {
 				if (conf_is_ht40_minus(conf)) {
@@ -455,8 +452,6 @@ int iwlagn_mac_config(struct ieee80211_hw *hw, u32 changed)
 		if (!memcmp(&ctx->staging, &ctx->active, sizeof(ctx->staging)))
 			continue;
 		iwlagn_commit_rxon(priv, ctx);
-		if (ht_changed[ctx->ctxid])
-			iwlagn_update_qos(priv, ctx);
 	}
  out:
 	mutex_unlock(&priv->mutex);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
index a709d05..2dd7d54 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -1224,12 +1224,16 @@ int iwlagn_tx_queue_reclaim(struct iwl_priv *priv, int txq_id, int index)
 	     q->read_ptr = iwl_queue_inc_wrap(q->read_ptr, q->n_bd)) {
 
 		tx_info = &txq->txb[txq->q.read_ptr];
-		iwlagn_tx_status(priv, tx_info,
-				 txq_id >= IWLAGN_FIRST_AMPDU_QUEUE);
+
+		if (WARN_ON_ONCE(tx_info->skb == NULL))
+			continue;
 
 		hdr = (struct ieee80211_hdr *)tx_info->skb->data;
-		if (hdr && ieee80211_is_data_qos(hdr->frame_control))
+		if (ieee80211_is_data_qos(hdr->frame_control))
 			nfreed++;
+
+		iwlagn_tx_status(priv, tx_info,
+				 txq_id >= IWLAGN_FIRST_AMPDU_QUEUE);
 		tx_info->skb = NULL;
 
 		if (priv->cfg->ops->lib->txq_inval_byte_cnt_tbl)
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 2216620..e7dced9 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -587,10 +587,8 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	hci_req_cancel(hdev, ENODEV);
 	hci_req_lock(hdev);
 
-	/* Stop timer, it might be running */
-	del_timer_sync(&hdev->cmd_timer);
-
 	if (!test_and_clear_bit(HCI_UP, &hdev->flags)) {
+		del_timer_sync(&hdev->cmd_timer);
 		hci_req_unlock(hdev);
 		return 0;
 	}
@@ -629,6 +627,7 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 
 	/* Drop last sent command */
 	if (hdev->sent_cmd) {
+		del_timer_sync(&hdev->cmd_timer);
 		kfree_skb(hdev->sent_cmd);
 		hdev->sent_cmd = NULL;
 	}
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index cebe7588..b257015 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -2387,8 +2387,6 @@ static inline void hci_io_capa_reply_evt(struct hci_dev *hdev, struct sk_buff *s
 	if (!conn)
 		goto unlock;
 
-	hci_conn_hold(conn);
-
 	conn->remote_cap = ev->capability;
 	conn->remote_oob = ev->oob_data;
 	conn->remote_auth = ev->authentication;
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index ca27f3a..2c8dd44 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1051,6 +1051,7 @@ static void l2cap_retransmit_one_frame(struct sock *sk, u8 tx_seq)
 	tx_skb = skb_clone(skb, GFP_ATOMIC);
 	bt_cb(skb)->retries++;
 	control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
+	control &= L2CAP_CTRL_SAR;
 
 	if (pi->conn_state & L2CAP_CONN_SEND_FBIT) {
 		control |= L2CAP_CTRL_FINAL;
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 42fdffd..94954c7 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -369,6 +369,15 @@ static void __sco_sock_close(struct sock *sk)
 
 	case BT_CONNECTED:
 	case BT_CONFIG:
+		if (sco_pi(sk)->conn) {
+			sk->sk_state = BT_DISCONN;
+			sco_sock_set_timer(sk, SCO_DISCONN_TIMEOUT);
+			hci_conn_put(sco_pi(sk)->conn->hcon);
+			sco_pi(sk)->conn = NULL;
+		} else
+			sco_chan_del(sk, ECONNRESET);
+		break;
+
 	case BT_CONNECT:
 	case BT_DISCONN:
 		sco_chan_del(sk, ECONNRESET);
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 3342135..4404973 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -1504,6 +1504,8 @@ int __ieee80211_request_smps(struct ieee80211_sub_if_data *sdata,
 	enum ieee80211_smps_mode old_req;
 	int err;
 
+	lockdep_assert_held(&sdata->u.mgd.mtx);
+
 	old_req = sdata->u.mgd.req_smps;
 	sdata->u.mgd.req_smps = smps_mode;
 
diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index dacace6..9ea7c0d 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -177,9 +177,9 @@ static int ieee80211_set_smps(struct ieee80211_sub_if_data *sdata,
 	if (sdata->vif.type != NL80211_IFTYPE_STATION)
 		return -EOPNOTSUPP;
 
-	mutex_lock(&local->iflist_mtx);
+	mutex_lock(&sdata->u.mgd.mtx);
 	err = __ieee80211_request_smps(sdata, smps_mode);
-	mutex_unlock(&local->iflist_mtx);
+	mutex_unlock(&sdata->u.mgd.mtx);
 
 	return err;
 }
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
