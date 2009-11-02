From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-11-02
Date: Mon, 2 Nov 2009 16:40:22 -0500
Message-ID: <20091102214022.GM14046@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756890AbZKBVpL@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Another collection of fixes intended for 2.6.32...several
(almost-)one-liners, a b43 bounce-buffer fix,  and a couple of USB IDs.
There are several from Johannes -- I'm sure there was sake involved...  :-)

Please let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 63ca2d74ea4f9c7a7ac082c915609a7b224908e7:
  Ken Kawasaki (1):
        pcnet_cs: add cis of PreMax PE-200 ethernet pcmcia card

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

David Woodhouse (1):
      libertas if_usb: Fix crash on 64-bit machines

Johannes Berg (5):
      mac80211: fix BSS leak
      mac80211: fix addba timer
      mac80211: fix reason code output endianness
      cfg80211: fix NULL ptr deref
      mac80211: check interface is down before type change

Luis R. Rodriguez (1):
      ath9k: fix misplaced semicolon on rate control

Michael Buesch (1):
      b43: Fix DMA TX bounce buffer copying

Xose Vazquez Perez (1):
      rt73usb.c : more ids

Zhu Yi (1):
      ipw2200: fix oops on missing firmware

 drivers/net/wireless/ath/ath9k/rc.c          |    2 +-
 drivers/net/wireless/b43/dma.c               |   15 +++++++++++++--
 drivers/net/wireless/ipw2x00/ipw2100.c       |    5 ++++-
 drivers/net/wireless/ipw2x00/ipw2200.c       |    2 ++
 drivers/net/wireless/ipw2x00/libipw.h        |    1 +
 drivers/net/wireless/ipw2x00/libipw_module.c |   14 +++++++++-----
 drivers/net/wireless/libertas/if_usb.c       |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c        |    5 +++++
 net/mac80211/agg-tx.c                        |   19 ++++++++++++-------
 net/mac80211/cfg.c                           |    6 +++---
 net/mac80211/ht.c                            |    2 +-
 net/mac80211/ibss.c                          |    6 ++++--
 net/wireless/sme.c                           |    7 +++++--
 13 files changed, 61 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath/ath9k/rc.c
index 16a2717..1895d63 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -679,7 +679,7 @@ static u8 ath_rc_get_highest_rix(struct ath_softc *sc,
 		return rate;
 
 	if (rate_table->info[rate].valid_single_stream &&
-	    !(ath_rc_priv->ht_cap & WLAN_RC_DS_FLAG));
+	    !(ath_rc_priv->ht_cap & WLAN_RC_DS_FLAG))
 		return rate;
 
 	/* This should not happen */
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 8701034..de4e804 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1157,8 +1157,9 @@ struct b43_dmaring *parse_cookie(struct b43_wldev *dev, u16 cookie, int *slot)
 }
 
 static int dma_tx_fragment(struct b43_dmaring *ring,
-			   struct sk_buff *skb)
+			   struct sk_buff **in_skb)
 {
+	struct sk_buff *skb = *in_skb;
 	const struct b43_dma_ops *ops = ring->ops;
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	u8 *header;
@@ -1224,8 +1225,14 @@ static int dma_tx_fragment(struct b43_dmaring *ring,
 		}
 
 		memcpy(skb_put(bounce_skb, skb->len), skb->data, skb->len);
+		memcpy(bounce_skb->cb, skb->cb, sizeof(skb->cb));
+		bounce_skb->dev = skb->dev;
+		skb_set_queue_mapping(bounce_skb, skb_get_queue_mapping(skb));
+		info = IEEE80211_SKB_CB(bounce_skb);
+
 		dev_kfree_skb_any(skb);
 		skb = bounce_skb;
+		*in_skb = bounce_skb;
 		meta->skb = skb;
 		meta->dmaaddr = map_descbuffer(ring, skb->data, skb->len, 1);
 		if (b43_dma_mapping_error(ring, meta->dmaaddr, skb->len, 1)) {
@@ -1355,7 +1362,11 @@ int b43_dma_tx(struct b43_wldev *dev, struct sk_buff *skb)
 	 * static, so we don't need to store it per frame. */
 	ring->queue_prio = skb_get_queue_mapping(skb);
 
-	err = dma_tx_fragment(ring, skb);
+	/* dma_tx_fragment might reallocate the skb, so invalidate pointers pointing
+	 * into the skb data or cb now. */
+	hdr = NULL;
+	info = NULL;
+	err = dma_tx_fragment(ring, &skb);
 	if (unlikely(err == -ENOKEY)) {
 		/* Drop this packet, as we don't have the encryption key
 		 * anymore and must not transmit it unencrypted. */
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 240cff1..a741d37 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6325,8 +6325,10 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 
       fail:
 	if (dev) {
-		if (registered)
+		if (registered) {
+			unregister_ieee80211(priv->ieee);
 			unregister_netdev(dev);
+		}
 
 		ipw2100_hw_stop_adapter(priv);
 
@@ -6383,6 +6385,7 @@ static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 		/* Unregister the device first - this results in close()
 		 * being called if the device is open.  If we free storage
 		 * first, then close() will crash. */
+		unregister_ieee80211(priv->ieee);
 		unregister_netdev(dev);
 
 		/* ipw2100_down will ensure that there is no more pending work
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 8d58e6e..04341a2 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11821,6 +11821,7 @@ static int __devinit ipw_pci_probe(struct pci_dev *pdev,
 		if (err) {
 			IPW_ERROR("Failed to register promiscuous network "
 				  "device (error %d).\n", err);
+			unregister_ieee80211(priv->ieee);
 			unregister_netdev(priv->net_dev);
 			goto out_remove_sysfs;
 		}
@@ -11871,6 +11872,7 @@ static void __devexit ipw_pci_remove(struct pci_dev *pdev)
 
 	mutex_unlock(&priv->mutex);
 
+	unregister_ieee80211(priv->ieee);
 	unregister_netdev(priv->net_dev);
 
 	if (priv->rxq) {
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index bf45391..f42ade6 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -1020,6 +1020,7 @@ static inline int libipw_is_cck_rate(u8 rate)
 /* ieee80211.c */
 extern void free_ieee80211(struct net_device *dev, int monitor);
 extern struct net_device *alloc_ieee80211(int sizeof_priv, int monitor);
+extern void unregister_ieee80211(struct libipw_device *ieee);
 extern int libipw_change_mtu(struct net_device *dev, int new_mtu);
 
 extern void libipw_networks_age(struct libipw_device *ieee,
diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index a0e9f6a..be5b809 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -235,16 +235,19 @@ void free_ieee80211(struct net_device *dev, int monitor)
 	libipw_networks_free(ieee);
 
 	/* free cfg80211 resources */
-	if (!monitor) {
-		wiphy_unregister(ieee->wdev.wiphy);
-		kfree(ieee->a_band.channels);
-		kfree(ieee->bg_band.channels);
+	if (!monitor)
 		wiphy_free(ieee->wdev.wiphy);
-	}
 
 	free_netdev(dev);
 }
 
+void unregister_ieee80211(struct libipw_device *ieee)
+{
+	wiphy_unregister(ieee->wdev.wiphy);
+	kfree(ieee->a_band.channels);
+	kfree(ieee->bg_band.channels);
+}
+
 #ifdef CONFIG_LIBIPW_DEBUG
 
 static int debug = 0;
@@ -330,3 +333,4 @@ module_init(libipw_init);
 
 EXPORT_SYMBOL(alloc_ieee80211);
 EXPORT_SYMBOL(free_ieee80211);
+EXPORT_SYMBOL(unregister_ieee80211);
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 92bc8c5..3fac4ef 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -508,7 +508,7 @@ static int __if_usb_submit_rx_urb(struct if_usb_card *cardp,
 	/* Fill the receive configuration URB and initialise the Rx call back */
 	usb_fill_bulk_urb(cardp->rx_urb, cardp->udev,
 			  usb_rcvbulkpipe(cardp->udev, cardp->ep_in),
-			  (void *) (skb->tail + (size_t) IPFIELD_ALIGN_OFFSET),
+			  skb->data + IPFIELD_ALIGN_OFFSET,
 			  MRVDRV_ETH_RX_PACKET_BUFFER_SIZE, callbackfn,
 			  cardp);
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index b8f5ee3..14e7bb2 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2389,10 +2389,13 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x13b1, 0x0023), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x13b1, 0x0028), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* MSI */
+	{ USB_DEVICE(0x0db0, 0x4600), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0x6877), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0x6874), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0xa861), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x0db0, 0xa874), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* Ovislink */
+	{ USB_DEVICE(0x1b75, 0x7318), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Ralink */
 	{ USB_DEVICE(0x04bb, 0x093d), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x148f, 0x2573), USB_DEVICE_DATA(&rt73usb_ops) },
@@ -2420,6 +2423,8 @@ static struct usb_device_id rt73usb_device_table[] = {
 	/* Planex */
 	{ USB_DEVICE(0x2019, 0xab01), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x2019, 0xab50), USB_DEVICE_DATA(&rt73usb_ops) },
+	/* WideTell */
+	{ USB_DEVICE(0x7167, 0x3840), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Zcom */
 	{ USB_DEVICE(0x0cde, 0x001c), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* ZyXEL */
diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index bd765f3..b09948c 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -666,26 +666,25 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 
 	state = &sta->ampdu_mlme.tid_state_tx[tid];
 
+	del_timer_sync(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
+
 	spin_lock_bh(&sta->lock);
 
-	if (!(*state & HT_ADDBA_REQUESTED_MSK)) {
-		spin_unlock_bh(&sta->lock);
-		return;
-	}
+	if (!(*state & HT_ADDBA_REQUESTED_MSK))
+		goto timer_still_needed;
 
 	if (mgmt->u.action.u.addba_resp.dialog_token !=
 		sta->ampdu_mlme.tid_tx[tid]->dialog_token) {
-		spin_unlock_bh(&sta->lock);
 #ifdef CONFIG_MAC80211_HT_DEBUG
 		printk(KERN_DEBUG "wrong addBA response token, tid %d\n", tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
-		return;
+		goto timer_still_needed;
 	}
 
-	del_timer_sync(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
 #ifdef CONFIG_MAC80211_HT_DEBUG
 	printk(KERN_DEBUG "switched off addBA timer for tid %d \n", tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
+
 	if (le16_to_cpu(mgmt->u.action.u.addba_resp.status)
 			== WLAN_STATUS_SUCCESS) {
 		u8 curstate = *state;
@@ -699,5 +698,11 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 	} else {
 		___ieee80211_stop_tx_ba_session(sta, tid, WLAN_BACK_INITIATOR);
 	}
+
+	goto out;
+
+ timer_still_needed:
+	add_timer(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
+ out:
 	spin_unlock_bh(&sta->lock);
 }
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index 5608f6c..7b5131b 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -72,6 +72,9 @@ static int ieee80211_change_iface(struct wiphy *wiphy,
 	struct ieee80211_sub_if_data *sdata;
 	int ret;
 
+	if (netif_running(dev))
+		return -EBUSY;
+
 	if (!nl80211_type_check(type))
 		return -EINVAL;
 
@@ -81,9 +84,6 @@ static int ieee80211_change_iface(struct wiphy *wiphy,
 	if (ret)
 		return ret;
 
-	if (netif_running(sdata->dev))
-		return -EBUSY;
-
 	if (ieee80211_vif_is_mesh(&sdata->vif) && params->mesh_id_len)
 		ieee80211_sdata_set_mesh_id(sdata,
 					    params->mesh_id_len,
diff --git a/net/mac80211/ht.c b/net/mac80211/ht.c
index 0891bfb..48ef1a2 100644
--- a/net/mac80211/ht.c
+++ b/net/mac80211/ht.c
@@ -153,7 +153,7 @@ void ieee80211_process_delba(struct ieee80211_sub_if_data *sdata,
 	if (net_ratelimit())
 		printk(KERN_DEBUG "delba from %pM (%s) tid %d reason code %d\n",
 			mgmt->sa, initiator ? "initiator" : "recipient", tid,
-			mgmt->u.action.u.delba.reason_code);
+			le16_to_cpu(mgmt->u.action.u.delba.reason_code));
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (initiator == WLAN_BACK_INITIATOR)
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index ca8ecce..f1362f3 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -73,6 +73,7 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_mgmt *mgmt;
 	u8 *pos;
 	struct ieee80211_supported_band *sband;
+	struct cfg80211_bss *bss;
 	u32 bss_change;
 	u8 supp_rates[IEEE80211_MAX_SUPP_RATES];
 
@@ -177,8 +178,9 @@ static void __ieee80211_sta_join_ibss(struct ieee80211_sub_if_data *sdata,
 	mod_timer(&ifibss->timer,
 		  round_jiffies(jiffies + IEEE80211_IBSS_MERGE_INTERVAL));
 
-	cfg80211_inform_bss_frame(local->hw.wiphy, local->hw.conf.channel,
-				  mgmt, skb->len, 0, GFP_KERNEL);
+	bss = cfg80211_inform_bss_frame(local->hw.wiphy, local->hw.conf.channel,
+					mgmt, skb->len, 0, GFP_KERNEL);
+	cfg80211_put_bss(bss);
 	cfg80211_ibss_joined(sdata->dev, ifibss->bssid, GFP_KERNEL);
 }
 
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index ece378d..9f0b280 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -165,7 +165,7 @@ void cfg80211_conn_work(struct work_struct *work)
 	struct cfg80211_registered_device *rdev =
 		container_of(work, struct cfg80211_registered_device, conn_work);
 	struct wireless_dev *wdev;
-	u8 bssid[ETH_ALEN];
+	u8 bssid_buf[ETH_ALEN], *bssid = NULL;
 
 	rtnl_lock();
 	cfg80211_lock_rdev(rdev);
@@ -181,7 +181,10 @@ void cfg80211_conn_work(struct work_struct *work)
 			wdev_unlock(wdev);
 			continue;
 		}
-		memcpy(bssid, wdev->conn->params.bssid, ETH_ALEN);
+		if (wdev->conn->params.bssid) {
+			memcpy(bssid_buf, wdev->conn->params.bssid, ETH_ALEN);
+			bssid = bssid_buf;
+		}
 		if (cfg80211_conn_do_work(wdev))
 			__cfg80211_connect_result(
 					wdev->netdev, bssid,
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
