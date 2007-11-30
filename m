From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Thu, 29 Nov 2007 22:31:58 -0500
Message-ID: <20071130033158.GB29165@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2831 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933071AbXK3DcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 22:32:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave/Herbert,

Here is another clutch of patches intended for 2.6.24.

Let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.git fixes-davem

---

The following changes since commit d9f8bcbf67a0ee67c8cb0734f003dfe916bb5248:
  Linus Torvalds (1):
        Linux 2.6.24-rc3

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Adel Gadllah (1):
      mac80211: rate limit wep decrypt failed messages

Daniel Drake (1):
      ieee80211: fix unaligned access in ieee80211_copy_snap

Johannes Berg (1):
      mac80211: drop unencrypted frames if encryption is expected

Michael Buesch (1):
      rfkill: fix double-mutex-locking

Michael Wu (1):
      mac80211: Fix behavior of ieee80211_open and ieee80211_close

Zhu Yi (1):
      mac80211: free ifsta->extra_ie and clear IEEE80211_STA_PRIVACY_INVOKED

 net/ieee80211/ieee80211_tx.c |    3 ++-
 net/mac80211/ieee80211.c     |   10 +++++++---
 net/mac80211/rx.c            |    2 +-
 net/mac80211/wep.c           |    3 ++-
 net/rfkill/rfkill.c          |   14 +++++---------
 5 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index a4c3c51..6d06f13 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -144,7 +144,8 @@ static int ieee80211_copy_snap(u8 * data, u16 h_proto)
 	snap->oui[1] = oui[1];
 	snap->oui[2] = oui[2];
 
-	*(u16 *) (data + SNAP_SIZE) = htons(h_proto);
+	h_proto = htons(h_proto);
+	memcpy(data + SNAP_SIZE, &h_proto, sizeof(u16));
 
 	return SNAP_SIZE + sizeof(u16);
 }
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index e0ee65a..0dc114c 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -216,6 +216,7 @@ static int ieee80211_open(struct net_device *dev)
 			res = local->ops->start(local_to_hw(local));
 		if (res)
 			return res;
+		ieee80211_hw_config(local);
 	}
 
 	switch (sdata->type) {
@@ -232,7 +233,6 @@ static int ieee80211_open(struct net_device *dev)
 			netif_tx_unlock_bh(local->mdev);
 
 			local->hw.conf.flags |= IEEE80211_CONF_RADIOTAP;
-			ieee80211_hw_config(local);
 		}
 		break;
 	case IEEE80211_IF_TYPE_STA:
@@ -311,8 +311,7 @@ static int ieee80211_stop(struct net_device *dev)
 			ieee80211_configure_filter(local);
 			netif_tx_unlock_bh(local->mdev);
 
-			local->hw.conf.flags |= IEEE80211_CONF_RADIOTAP;
-			ieee80211_hw_config(local);
+			local->hw.conf.flags &= ~IEEE80211_CONF_RADIOTAP;
 		}
 		break;
 	case IEEE80211_IF_TYPE_STA:
@@ -334,6 +333,11 @@ static int ieee80211_stop(struct net_device *dev)
 			cancel_delayed_work(&local->scan_work);
 		}
 		flush_workqueue(local->hw.workqueue);
+
+		sdata->u.sta.flags &= ~IEEE80211_STA_PRIVACY_INVOKED;
+		kfree(sdata->u.sta.extra_ie);
+		sdata->u.sta.extra_ie = NULL;
+		sdata->u.sta.extra_ie_len = 0;
 		/* fall through */
 	default:
 		conf.if_id = dev->ifindex;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 428a9fc..00f908d 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -997,7 +997,7 @@ ieee80211_rx_h_drop_unencrypted(struct ieee80211_txrx_data *rx)
 	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
 		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
-		     rx->sdata->drop_unencrypted &&
+		     (rx->key || rx->sdata->drop_unencrypted) &&
 		     (rx->sdata->eapol == 0 || !ieee80211_is_eapol(rx->skb)))) {
 		if (net_ratelimit())
 			printk(KERN_DEBUG "%s: RX non-WEP frame, but expected "
diff --git a/net/mac80211/wep.c b/net/mac80211/wep.c
index 9bf0e1c..b5f3413 100644
--- a/net/mac80211/wep.c
+++ b/net/mac80211/wep.c
@@ -265,7 +265,8 @@ int ieee80211_wep_decrypt(struct ieee80211_local *local, struct sk_buff *skb,
 	if (ieee80211_wep_decrypt_data(local->wep_rx_tfm, rc4key, klen,
 				       skb->data + hdrlen + WEP_IV_LEN,
 				       len)) {
-		printk(KERN_DEBUG "WEP decrypt failed (ICV)\n");
+		if (net_ratelimit())
+			printk(KERN_DEBUG "WEP decrypt failed (ICV)\n");
 		ret = -1;
 	}
 
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index 73d60a3..4469a7b 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -60,11 +60,7 @@ static void rfkill_led_trigger(struct rfkill *rfkill,
 static int rfkill_toggle_radio(struct rfkill *rfkill,
 				enum rfkill_state state)
 {
-	int retval;
-
-	retval = mutex_lock_interruptible(&rfkill->mutex);
-	if (retval)
-		return retval;
+	int retval = 0;
 
 	if (state != rfkill->state) {
 		retval = rfkill->toggle_radio(rfkill->data, state);
@@ -74,7 +70,6 @@ static int rfkill_toggle_radio(struct rfkill *rfkill,
 		}
 	}
 
-	mutex_unlock(&rfkill->mutex);
 	return retval;
 }
 
@@ -158,12 +153,13 @@ static ssize_t rfkill_state_store(struct device *dev,
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
+	if (mutex_lock_interruptible(&rfkill->mutex))
+		return -ERESTARTSYS;
 	error = rfkill_toggle_radio(rfkill,
 			state ? RFKILL_STATE_ON : RFKILL_STATE_OFF);
-	if (error)
-		return error;
+	mutex_unlock(&rfkill->mutex);
 
-	return count;
+	return error ? error : count;
 }
 
 static ssize_t rfkill_claim_show(struct device *dev,
-- 
John W. Linville
linville@tuxdriver.com
