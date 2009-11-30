From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2009-11-30 (security fixes too)
Date: Mon, 30 Nov 2009 14:47:06 -0500
Message-ID: <20091130194706.GE21401@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Linus,

If a) you have already taken Dave's latest pull request; and, b) you
don't want to wait for his next one to get the mac80211 security fixes
from Johannes, then you can at your discretion pull from here:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git security

That branch is in the same line as the master branch I'm asking Dave to
pull, so I think that git will work all that out without messing the
history.

Dave,

Below are a couple of mac80211 security fixes from Johannes as well as a
number of not-quite-one-liners, all intended for 2.6.32.  Please let me
know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 3e9848403ad59c53b31facb30b43ca80135ae0b9:
  Eric Dumazet (1):
        pktgen: Fix netdevice unregister

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git

Gertjan van Wingerde (1):
      rt2x00: Fix padding bug on L2PAD devices.

Jean Tourrilhes (1):
      WE: Fix set events not propagated

Johannes Berg (2):
      mac80211: fix two remote exploits
      mac80211: fix spurious delBA handling

Larry Finger (2):
      b43: avoid PPC fault during resume
      b43legacy: avoid PPC fault during resume

Michael Buesch (1):
      airo: Fix integer overflow warning

 drivers/net/wireless/airo.c               |    2 +-
 drivers/net/wireless/b43/rfkill.c         |   10 ++++++++--
 drivers/net/wireless/b43legacy/rfkill.c   |    7 +++++++
 drivers/net/wireless/iwlwifi/iwl-tx.c     |   10 +++++++++-
 drivers/net/wireless/rt2x00/rt2x00queue.c |    2 +-
 include/net/mac80211.h                    |    6 ++++++
 net/mac80211/agg-rx.c                     |    4 ----
 net/mac80211/agg-tx.c                     |   17 ++++++++---------
 net/mac80211/ht.c                         |    8 +++-----
 net/mac80211/ieee80211_i.h                |    2 ++
 net/wireless/wext.c                       |    3 ++-
 11 files changed, 47 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index abf896a..02f70de 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -4806,7 +4806,7 @@ static int airo_config_commit(struct net_device *dev,
 
 static inline int sniffing_mode(struct airo_info *ai)
 {
-	return le16_to_cpu(ai->config.rmode & RXMODE_MASK) >=
+	return (le16_to_cpu(ai->config.rmode) & le16_to_cpu(RXMODE_MASK)) >=
 		le16_to_cpu(RXMODE_RFMON);
 }
 
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index ffdce6f..78016ae 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -33,8 +33,14 @@ bool b43_is_hw_radio_enabled(struct b43_wldev *dev)
 		      & B43_MMIO_RADIO_HWENABLED_HI_MASK))
 			return 1;
 	} else {
-		if (b43_status(dev) >= B43_STAT_STARTED &&
-		    b43_read16(dev, B43_MMIO_RADIO_HWENABLED_LO)
+		/* To prevent CPU fault on PPC, do not read a register
+		 * unless the interface is started; however, on resume
+		 * for hibernation, this routine is entered early. When
+		 * that happens, unconditionally return TRUE.
+		 */
+		if (b43_status(dev) < B43_STAT_STARTED)
+			return 1;
+		if (b43_read16(dev, B43_MMIO_RADIO_HWENABLED_LO)
 		    & B43_MMIO_RADIO_HWENABLED_LO_MASK)
 			return 1;
 	}
diff --git a/drivers/net/wireless/b43legacy/rfkill.c b/drivers/net/wireless/b43legacy/rfkill.c
index 8783022..d579df7 100644
--- a/drivers/net/wireless/b43legacy/rfkill.c
+++ b/drivers/net/wireless/b43legacy/rfkill.c
@@ -34,6 +34,13 @@ bool b43legacy_is_hw_radio_enabled(struct b43legacy_wldev *dev)
 		      & B43legacy_MMIO_RADIO_HWENABLED_HI_MASK))
 			return 1;
 	} else {
+		/* To prevent CPU fault on PPC, do not read a register
+		 * unless the interface is started; however, on resume
+		 * for hibernation, this routine is entered early. When
+		 * that happens, unconditionally return TRUE.
+		 */
+		if (b43legacy_status(dev) < B43legacy_STAT_STARTED)
+			return 1;
 		if (b43legacy_read16(dev, B43legacy_MMIO_RADIO_HWENABLED_LO)
 		    & B43legacy_MMIO_RADIO_HWENABLED_LO_MASK)
 			return 1;
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index fb9bcfa..b7e196e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -1277,8 +1277,16 @@ int iwl_tx_agg_stop(struct iwl_priv *priv , const u8 *ra, u16 tid)
 		return -ENXIO;
 	}
 
+	if (priv->stations[sta_id].tid[tid].agg.state ==
+				IWL_EMPTYING_HW_QUEUE_ADDBA) {
+		IWL_DEBUG_HT(priv, "AGG stop before setup done\n");
+		ieee80211_stop_tx_ba_cb_irqsafe(priv->hw, ra, tid);
+		priv->stations[sta_id].tid[tid].agg.state = IWL_AGG_OFF;
+		return 0;
+	}
+
 	if (priv->stations[sta_id].tid[tid].agg.state != IWL_AGG_ON)
-		IWL_WARN(priv, "Stopping AGG while state not IWL_AGG_ON\n");
+		IWL_WARN(priv, "Stopping AGG while state not ON or starting\n");
 
 	tid_data = &priv->stations[sta_id].tid[tid];
 	ssn = (tid_data->seq_number & IEEE80211_SCTL_SEQ) >> 4;
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 577029e..d7a7ede 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -213,7 +213,7 @@ void rt2x00queue_insert_l2pad(struct sk_buff *skb, unsigned int header_length)
 		skb_push(skb, header_align);
 		memmove(skb->data, skb->data + header_align, header_length);
 		memmove(skb->data + header_length + l2pad,
-			skb->data + header_length + l2pad + header_align,
+			skb->data + header_length + l2pad + payload_align,
 			frame_length - header_length);
 		skbdesc->flags |= SKBDESC_L2_PADDED;
 	}
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index c75b960..998c30f 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1283,6 +1283,12 @@ enum ieee80211_filter_flags {
  *
  * These flags are used with the ampdu_action() callback in
  * &struct ieee80211_ops to indicate which action is needed.
+ *
+ * Note that drivers MUST be able to deal with a TX aggregation
+ * session being stopped even before they OK'ed starting it by
+ * calling ieee80211_start_tx_ba_cb(_irqsafe), because the peer
+ * might receive the addBA frame and send a delBA right away!
+ *
  * @IEEE80211_AMPDU_RX_START: start Rx aggregation
  * @IEEE80211_AMPDU_RX_STOP: stop Rx aggregation
  * @IEEE80211_AMPDU_TX_START: start Tx aggregation
diff --git a/net/mac80211/agg-rx.c b/net/mac80211/agg-rx.c
index bc064d7..ce8e0e7 100644
--- a/net/mac80211/agg-rx.c
+++ b/net/mac80211/agg-rx.c
@@ -85,10 +85,6 @@ void ieee80211_sta_stop_rx_ba_session(struct ieee80211_sub_if_data *sdata, u8 *r
 	struct ieee80211_local *local = sdata->local;
 	struct sta_info *sta;
 
-	/* stop HW Rx aggregation. ampdu_action existence
-	 * already verified in session init so we add the BUG_ON */
-	BUG_ON(!local->ops->ampdu_action);
-
 	rcu_read_lock();
 
 	sta = sta_info_get(local, ra);
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 206fd82..89e238b 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -123,13 +123,18 @@ void ieee80211_send_bar(struct ieee80211_sub_if_data *sdata, u8 *ra, u16 tid, u1
 	ieee80211_tx_skb(sdata, skb, 0);
 }
 
-static int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
-					   enum ieee80211_back_parties initiator)
+int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
+				    enum ieee80211_back_parties initiator)
 {
 	struct ieee80211_local *local = sta->local;
 	int ret;
 	u8 *state;
 
+#ifdef CONFIG_MAC80211_HT_DEBUG
+	printk(KERN_DEBUG "Tx BA session stop requested for %pM tid %u\n",
+	       sta->sta.addr, tid);
+#endif /* CONFIG_MAC80211_HT_DEBUG */
+
 	state = &sta->ampdu_mlme.tid_state_tx[tid];
 
 	if (*state == HT_AGG_STATE_OPERATIONAL)
@@ -143,7 +148,6 @@ static int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 
 	/* HW shall not deny going back to legacy */
 	if (WARN_ON(ret)) {
-		*state = HT_AGG_STATE_OPERATIONAL;
 		/*
 		 * We may have pending packets get stuck in this case...
 		 * Not bothering with a workaround for now.
@@ -525,11 +529,6 @@ int __ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 		goto unlock;
 	}
 
-#ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Tx BA session stop requested for %pM tid %u\n",
-	       sta->sta.addr, tid);
-#endif /* CONFIG_MAC80211_HT_DEBUG */
-
 	ret = ___ieee80211_stop_tx_ba_session(sta, tid, initiator);
 
  unlock:
@@ -545,7 +544,7 @@ int ieee80211_stop_tx_ba_session(struct ieee80211_hw *hw,
 	struct sta_info *sta;
 	int ret = 0;
 
-	if (WARN_ON(!local->ops->ampdu_action))
+	if (!local->ops->ampdu_action)
 		return -EINVAL;
 
 	if (tid >= STA_TID_NUM)
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 48ef1a2..cdc58e6 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -141,7 +141,6 @@ void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,
 			     struct sta_info *sta,
 			     struct ieee80211_mgmt *mgmt, size_t len)
 {
-	struct ieee80211_local *local = sdata->local;
 	u16 tid, params;
 	u16 initiator;
 
@@ -161,10 +160,9 @@ void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,
 						 WLAN_BACK_INITIATOR, 0);
 	else { /* WLAN_BACK_RECIPIENT */
 		spin_lock_bh(&sta->lock);
-		sta->ampdu_mlme.tid_state_tx[tid] =
-				HT_AGG_STATE_OPERATIONAL;
+		if (sta->ampdu_mlme.tid_state_tx[tid] & HT_ADDBA_REQUESTED_MSK)
+			___ieee80211_stop_tx_ba_session(sta, tid,
+							WLAN_BACK_RECIPIENT);
 		spin_unlock_bh(&sta->lock);
-		ieee80211_stop_tx_ba_session(&local->hw, sta->sta.addr, tid,
-					     WLAN_BACK_RECIPIENT);
 	}
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index a910bf1..10d316e 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -1091,6 +1091,8 @@ void ieee80211_process_addba_request(struct ieee80211_local *local,
 
 int __ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 				   enum ieee80211_back_parties initiator);
+int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
+				    enum ieee80211_back_parties initiator);
 
 /* Spectrum management */
 void ieee80211_process_measurement_req(struct ieee80211_sub_if_data *sdata,
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index 60fe577..eb32ff0 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -875,7 +875,8 @@ static int ioctl_standard_iw_point(struct iw_point *iwp, unsigned int cmd,
 	}
 
 	/* Generate an event to notify listeners of the change */
-	if ((descr->flags & IW_DESCR_FLAG_EVENT) && err == -EIWCOMMIT) {
+	if ((descr->flags & IW_DESCR_FLAG_EVENT) &&
+	    ((err == 0) || (err == -EIWCOMMIT))) {
 		union iwreq_data *data = (union iwreq_data *) iwp;
 
 		if (descr->flags & IW_DESCR_FLAG_RESTRICT)
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
