From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2009-11-30 (security fixes too)
Date: Mon, 30 Nov 2009 19:23:25 -0500
Message-ID: <20091201002325.GI21401@tuxdriver.com>
References: <20091130194706.GE21401@tuxdriver.com> <alpine.LFD.2.00.0911301406230.2872@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0911301406230.2872-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 30, 2009 at 02:08:21PM -0800, Linus Torvalds wrote:
> 
> 
> On Mon, 30 Nov 2009, John W. Linville wrote:
> > 
> > If a) you have already taken Dave's latest pull request; and, b) you
> > don't want to wait for his next one to get the mac80211 security fixes
> > from Johannes, then you can at your discretion pull from here:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git security
> 
> Hmm. If I pull the 'security' branch, I get
> 
>  drivers/net/wireless/iwlwifi/iwl-tx.c |   10 +++++++++-
>  include/net/mac80211.h                |    6 ++++++
>  net/mac80211/agg-rx.c                 |    4 ----
>  net/mac80211/agg-tx.c                 |   17 ++++++++---------
>  net/mac80211/ht.c                     |    8 +++-----
>  net/mac80211/ieee80211_i.h            |    2 ++
>  6 files changed, 28 insertions(+), 19 deletions(-)
> 
> which does not match what you then descibe in the rest of the email 
> (changelog and diffstat).
> 
> What you describe seems to be the master branch. 
> 
> So I'm not going to pull either, and will wait for confirmation of exactly 
> what you wanted me to pull.

Ha!  I confused you... :-)

Yes, the diffstat above is correct for the security branch.
The diffstat lower in the email is for the master branch (which is
a superset).

So just for clarity, a pull request tailored for Linus:

The following changes since commit 3e9848403ad59c53b31facb30b43ca80135ae0b9:
  Eric Dumazet (1):
        pktgen: Fix netdevice unregister

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git security

Johannes Berg (2):
      mac80211: fix two remote exploits
      mac80211: fix spurious delBA handling

 drivers/net/wireless/iwlwifi/iwl-tx.c |   10 +++++++++-
 include/net/mac80211.h                |    6 ++++++
 net/mac80211/agg-rx.c                 |    4 ----
 net/mac80211/agg-tx.c                 |   17 ++++++++---------
 net/mac80211/ht.c                     |    8 +++-----
 net/mac80211/ieee80211_i.h            |    2 ++
 6 files changed, 28 insertions(+), 19 deletions(-)

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

Sorry for the confusion!  That's what I get for trying to be clever... :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
