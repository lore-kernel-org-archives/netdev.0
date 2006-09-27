From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] softmac: Fix WX and association related races
Date: Wed, 27 Sep 2006 17:26:33 +0200
Message-ID: <200609271726.34305.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Christian <email@christianhoffmann.info>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49852
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S964933AbWI0Pa6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 11:30:58 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes some race conditions in the WirelessExtension
handling and association handling code.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

Hi John,

Please apply this fo wireless-2.6 and push it with your
next push of bugfixes.
There are other theoretical raceconditions possible in softmac
related to scanning and assoc code. But I don't really want to fix
these, as I think they:
1) are not triggerable in real world conditions.
2) are not exploitable to do some bad attacks, etc...
3) require _huge_ changes to softmac, and I don't really
   want to spend more effort into softmac any longer.
This patch fixes some real-world exploitable bugs, so better
fix them to have working wireless until d80211 is ready for
prime-time.

btw: d80211 might have similiar race conditions like this.

Larry, once this patch settled a little bit and enough people
tested it, you might want to try pushing it into -stable (although
it's big...)


Index: wireless-2.6/include/net/ieee80211softmac.h
===================================================================
--- wireless-2.6.orig/include/net/ieee80211softmac.h	2006-09-25 17:02:08.000000000 +0200
+++ wireless-2.6/include/net/ieee80211softmac.h	2006-09-27 16:39:17.000000000 +0200
@@ -63,13 +63,11 @@ struct ieee80211softmac_wpa {
 
 /*
  * Information about association
- *
- * Do we need a lock for this?
- * We only ever use this structure inlined
- * into our global struct. I've used its lock,
- * but maybe we need a local one here?
  */
 struct ieee80211softmac_assoc_info {
+
+	struct mutex mutex;
+
 	/*
 	 * This is the requested ESSID. It is written
 	 * only by the WX handlers.
@@ -99,12 +97,13 @@ struct ieee80211softmac_assoc_info {
 	 *
 	 * bssfixed is used for SIOCSIWAP.
 	 */
-	u8 static_essid:1,
-	   short_preamble_available:1,
-	   associating:1,
-	   assoc_wait:1,
-	   bssvalid:1,
-	   bssfixed:1;
+	u8 static_essid;
+	u8 short_preamble_available;
+	u8 associating;
+	u8 associated;
+	u8 assoc_wait;
+	u8 bssvalid;
+	u8 bssfixed;
 
 	/* Scan retries remaining */
 	int scan_retry;
@@ -229,12 +228,10 @@ struct ieee80211softmac_device {
 	/* private stuff follows */
 	/* this lock protects this structure */
 	spinlock_t lock;
-	
-	/* couple of flags */
-	u8 scanning:1, /* protects scanning from being done multiple times at once */
-	   associated:1,
-	   running:1;
-	
+
+	u8 running; /* SoftMAC started? */
+	u8 scanning;
+
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
 	struct ieee80211softmac_bss_info bssinfo;
@@ -250,7 +247,7 @@ struct ieee80211softmac_device {
 
 	/* we need to keep a list of network structs we copied */
 	struct list_head network_list;
-	
+
 	/* This must be the last item so that it points to the data
 	 * allocated beyond this structure by alloc_ieee80211 */
 	u8 priv[0];
@@ -295,7 +292,7 @@ static inline u8 ieee80211softmac_sugges
 {
 	struct ieee80211softmac_txrates *txrates = &mac->txrates;
 
-	if (!mac->associated)
+	if (!mac->associnfo.associated)
 		return txrates->mgt_mcast_rate;
 
 	/* We are associated, sending unicast frame */
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-09-17 15:21:53.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-09-27 17:10:08.000000000 +0200
@@ -48,7 +48,7 @@ ieee80211softmac_assoc(struct ieee80211s
 	dprintk(KERN_INFO PFX "sent association request!\n");
 
 	spin_lock_irqsave(&mac->lock, flags);
-	mac->associated = 0; /* just to make sure */
+	mac->associnfo.associated = 0; /* just to make sure */
 
 	/* Set a timer for timeout */
 	/* FIXME: make timeout configurable */
@@ -62,24 +62,22 @@ ieee80211softmac_assoc_timeout(void *d)
 {
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
 	struct ieee80211softmac_network *n;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	/* we might race against ieee80211softmac_handle_assoc_response,
 	 * so make sure only one of us does something */
-	if (!mac->associnfo.associating) {
-		spin_unlock_irqrestore(&mac->lock, flags);
-		return;
-	}
+	if (!mac->associnfo.associating)
+		goto out;
 	mac->associnfo.associating = 0;
 	mac->associnfo.bssvalid = 0;
-	mac->associated = 0;
+	mac->associnfo.associated = 0;
 
 	n = ieee80211softmac_get_network_by_bssid_locked(mac, mac->associnfo.bssid);
-	spin_unlock_irqrestore(&mac->lock, flags);
 
 	dprintk(KERN_INFO PFX "assoc request timed out!\n");
 	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, n);
+out:
+	mutex_unlock(&mac->associnfo.mutex);
 }
 
 void
@@ -93,7 +91,7 @@ ieee80211softmac_disassoc(struct ieee802
 
 	netif_carrier_off(mac->dev);
 
-	mac->associated = 0;
+	mac->associnfo.associated = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associnfo.associating = 0;
 	ieee80211softmac_init_bss(mac);
@@ -107,7 +105,7 @@ ieee80211softmac_send_disassoc_req(struc
 {
 	struct ieee80211softmac_network *found;
 
-	if (mac->associnfo.bssvalid && mac->associated) {
+	if (mac->associnfo.bssvalid && mac->associnfo.associated) {
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);
 		if (found)
 			ieee80211softmac_send_mgt_frame(mac, found, IEEE80211_STYPE_DISASSOC, reason);
@@ -196,17 +194,18 @@ ieee80211softmac_assoc_work(void *d)
 	int bssvalid;
 	unsigned long flags;
 
+	mutex_lock(&mac->associnfo.mutex);
+
+	if (!mac->associnfo.associating)
+		goto out;
+
 	/* ieee80211_disassoc might clear this */
 	bssvalid = mac->associnfo.bssvalid;
 
 	/* meh */
-	if (mac->associated)
+	if (mac->associnfo.associated)
 		ieee80211softmac_send_disassoc_req(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
-	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.associating = 1;
-	spin_unlock_irqrestore(&mac->lock, flags);
-
 	/* try to find the requested network in our list, if we found one already */
 	if (bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
@@ -260,10 +259,8 @@ ieee80211softmac_assoc_work(void *d)
 
 	if (!found) {
 		if (mac->associnfo.scan_retry > 0) {
-			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.scan_retry--;
-			spin_unlock_irqrestore(&mac->lock, flags);
-		
+
 			/* We know of no such network. Let's scan. 
 			 * NB: this also happens if we had no memory to copy the network info...
 			 * Maybe we can hope to have more memory after scanning finishes ;)
@@ -272,19 +269,17 @@ ieee80211softmac_assoc_work(void *d)
 			ieee80211softmac_notify(mac->dev, IEEE80211SOFTMAC_EVENT_SCAN_FINISHED, ieee80211softmac_assoc_notify_scan, NULL);
 			if (ieee80211softmac_start_scan(mac))
 				dprintk(KERN_INFO PFX "Associate: failed to initiate scan. Is device up?\n");
-			return;
+			goto out;
 		} else {
-			spin_lock_irqsave(&mac->lock, flags);
 			mac->associnfo.associating = 0;
-			mac->associated = 0;
-			spin_unlock_irqrestore(&mac->lock, flags);
+			mac->associnfo.associated = 0;
 
 			dprintk(KERN_INFO PFX "Unable to find matching network after scan!\n");
 			/* reset the retry counter for the next user request since we
 			 * break out and don't reschedule ourselves after this point. */
 			mac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_NET_NOT_FOUND, NULL);
-			return;
+			goto out;
 		}
 	}
 
@@ -297,7 +292,7 @@ ieee80211softmac_assoc_work(void *d)
 	/* copy the ESSID for displaying it */
 	mac->associnfo.associate_essid.len = found->essid.len;
 	memcpy(mac->associnfo.associate_essid.data, found->essid.data, IW_ESSID_MAX_SIZE + 1);
-	
+
 	/* we found a network! authenticate (if necessary) and associate to it. */
 	if (found->authenticating) {
 		dprintk(KERN_INFO PFX "Already requested authentication, waiting...\n");
@@ -305,7 +300,7 @@ ieee80211softmac_assoc_work(void *d)
 			mac->associnfo.assoc_wait = 1;
 			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
 		}
-		return;
+		goto out;
 	}
 	if (!found->authenticated && !found->authenticating) {
 		/* This relies on the fact that _auth_req only queues the work,
@@ -321,11 +316,14 @@ ieee80211softmac_assoc_work(void *d)
 			mac->associnfo.assoc_wait = 0;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, found);
 		}
-		return;
+		goto out;
 	}
 	/* finally! now we can start associating */
 	mac->associnfo.assoc_wait = 0;
 	ieee80211softmac_assoc(mac, found);
+
+out:
+	mutex_unlock(&mac->associnfo.mutex);
 }
 
 /* call this to do whatever is necessary when we're associated */
@@ -341,7 +339,7 @@ ieee80211softmac_associated(struct ieee8
 	mac->bssinfo.supported_rates = net->supported_rates;
 	ieee80211softmac_recalc_txrates(mac);
 
-	mac->associated = 1;
+	mac->associnfo.associated = 1;
 
 	mac->associnfo.short_preamble_available =
 		(cap & WLAN_CAPABILITY_SHORT_PREAMBLE) != 0;
@@ -421,7 +419,7 @@ ieee80211softmac_handle_assoc_response(s
 			dprintk(KERN_INFO PFX "associating failed (reason: 0x%x)!\n", status);
 			mac->associnfo.associating = 0;
 			mac->associnfo.bssvalid = 0;
-			mac->associated = 0;
+			mac->associnfo.associated = 0;
 			ieee80211softmac_call_events_locked(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, network);
 	}
 	
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_module.c	2006-09-17 15:21:52.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_module.c	2006-09-27 16:30:07.000000000 +0200
@@ -57,6 +57,7 @@ struct net_device *alloc_ieee80211softma
 	INIT_LIST_HEAD(&softmac->network_list);
 	INIT_LIST_HEAD(&softmac->events);
 
+	mutex_init(&softmac->associnfo.mutex);
 	INIT_WORK(&softmac->associnfo.work, ieee80211softmac_assoc_work, softmac);
 	INIT_WORK(&softmac->associnfo.timeout, ieee80211softmac_assoc_timeout, softmac);
 	softmac->start_scan = ieee80211softmac_start_scan_implementation;
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-09-17 15:21:53.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_wx.c	2006-09-27 16:49:25.000000000 +0200
@@ -73,13 +73,14 @@ ieee80211softmac_wx_set_essid(struct net
 	struct ieee80211softmac_network *n;
 	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
-	unsigned long flags;
+
+	mutex_lock(&sm->associnfo.mutex);
 
 	/* Check if we're already associating to this or another network
 	 * If it's another network, cancel and start over with our new network
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
-	if((sm->associnfo.associating || sm->associated) &&
+	if((sm->associnfo.associating || sm->associnfo.associated) &&
 	   (data->essid.flags && data->essid.length && extra)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
@@ -87,10 +88,9 @@ ieee80211softmac_wx_set_essid(struct net
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
-			return 0;
+			goto out;
 		} else {
 			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
-			spin_lock_irqsave(&sm->lock,flags);
 			/* Cancel assoc work */
 			cancel_delayed_work(&sm->associnfo.work);
 			/* We don't have to do this, but it's a little cleaner */
@@ -98,14 +98,13 @@ ieee80211softmac_wx_set_essid(struct net
 				cancel_delayed_work(&authptr->work);
 			sm->associnfo.bssvalid = 0;
 			sm->associnfo.bssfixed = 0;
-			spin_unlock_irqrestore(&sm->lock,flags);
 			flush_scheduled_work();
+			sm->associnfo.associating = 0;
+			sm->associnfo.associated = 0;
 		}
 	}
 
 
-	spin_lock_irqsave(&sm->lock, flags);
-
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
@@ -121,10 +120,12 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If applicable, we have already copied the data in */
 	sm->associnfo.req_essid.len = length;
 
+	sm->associnfo.associating = 1;
 	/* queue lower level code to do work (if necessary) */
 	schedule_work(&sm->associnfo.work);
+out:
+	mutex_unlock(&sm->associnfo.mutex);
 
-	spin_unlock_irqrestore(&sm->lock, flags);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_essid);
@@ -136,10 +137,8 @@ ieee80211softmac_wx_get_essid(struct net
 			      char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
-	unsigned long flags;
 
-	/* avoid getting inconsistent information */
-	spin_lock_irqsave(&sm->lock, flags);
+	mutex_lock(&sm->associnfo.mutex);
 	/* If all fails, return ANY (empty) */
 	data->essid.length = 0;
 	data->essid.flags = 0;  /* active */
@@ -152,12 +151,13 @@ ieee80211softmac_wx_get_essid(struct net
 	}
 	
 	/* If we're associating/associated, return that */
-	if (sm->associated || sm->associnfo.associating) {
+	if (sm->associnfo.associated || sm->associnfo.associating) {
 		data->essid.length = sm->associnfo.associate_essid.len;
 		data->essid.flags = 1;  /* active */
 		memcpy(extra, sm->associnfo.associate_essid.data, sm->associnfo.associate_essid.len);
 	}
-	spin_unlock_irqrestore(&sm->lock, flags);
+	mutex_unlock(&sm->associnfo.mutex);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_essid);
@@ -322,15 +322,15 @@ ieee80211softmac_wx_get_wap(struct net_d
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
 	int err = 0;
-	unsigned long flags;
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	if (mac->associnfo.bssvalid)
 		memcpy(data->ap_addr.sa_data, mac->associnfo.bssid, ETH_ALEN);
 	else
 		memset(data->ap_addr.sa_data, 0xff, ETH_ALEN);
 	data->ap_addr.sa_family = ARPHRD_ETHER;
-	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_wap);
@@ -342,28 +342,27 @@ ieee80211softmac_wx_set_wap(struct net_d
 			    char *extra)
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(net_dev);
-	unsigned long flags;
 
 	/* sanity check */
 	if (data->ap_addr.sa_family != ARPHRD_ETHER) {
 		return -EINVAL;
 	}
 
-	spin_lock_irqsave(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
 	if (is_broadcast_ether_addr(data->ap_addr.sa_data)) {
 		/* the bssid we have is not to be fixed any longer,
 		 * and we should reassociate to the best AP. */
 		mac->associnfo.bssfixed = 0;
 		/* force reassociation */
 		mac->associnfo.bssvalid = 0;
-		if (mac->associated)
+		if (mac->associnfo.associated)
 			schedule_work(&mac->associnfo.work);
 	} else if (is_zero_ether_addr(data->ap_addr.sa_data)) {
 		/* the bssid we have is no longer fixed */
 		mac->associnfo.bssfixed = 0;
         } else {
 		if (!memcmp(mac->associnfo.bssid, data->ap_addr.sa_data, ETH_ALEN)) {
-			if (mac->associnfo.associating || mac->associated) {
+			if (mac->associnfo.associating || mac->associnfo.associated) {
 			/* bssid unchanged and associated or associating - just return */
 				goto out;
 			}
@@ -378,7 +377,8 @@ ieee80211softmac_wx_set_wap(struct net_d
         }
 
  out:
-	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_wap);
@@ -394,7 +394,8 @@ ieee80211softmac_wx_set_genie(struct net
 	int err = 0;
 	char *buf;
 	int i;
-	
+
+	mutex_lock(&mac->associnfo.mutex);
 	spin_lock_irqsave(&mac->lock, flags);
 	/* bleh. shouldn't be locked for that kmalloc... */
 
@@ -432,6 +433,8 @@ ieee80211softmac_wx_set_genie(struct net
 
  out:	
 	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_unlock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_genie);
@@ -446,7 +449,8 @@ ieee80211softmac_wx_get_genie(struct net
 	unsigned long flags;
 	int err = 0;
 	int space = wrqu->data.length;
-	
+
+	mutex_lock(&mac->associnfo.mutex);
 	spin_lock_irqsave(&mac->lock, flags);
 	
 	wrqu->data.length = 0;
@@ -459,6 +463,8 @@ ieee80211softmac_wx_get_genie(struct net
 			err = -E2BIG;
 	}
 	spin_unlock_irqrestore(&mac->lock, flags);
+	mutex_lock(&mac->associnfo.mutex);
+
 	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_get_genie);
@@ -473,10 +479,13 @@ ieee80211softmac_wx_set_mlme(struct net_
 	struct iw_mlme *mlme = (struct iw_mlme *)extra;
 	u16 reason = cpu_to_le16(mlme->reason_code);
 	struct ieee80211softmac_network *net;
+	int err = -EINVAL;
+
+	mutex_lock(&mac->associnfo.mutex);
 
 	if (memcmp(mac->associnfo.bssid, mlme->addr.sa_data, ETH_ALEN)) {
 		printk(KERN_DEBUG PFX "wx_set_mlme: requested operation on net we don't use\n");
-		return -EINVAL;
+		goto out;
 	}
 
 	switch (mlme->cmd) {
@@ -484,14 +493,22 @@ ieee80211softmac_wx_set_mlme(struct net_
 		net = ieee80211softmac_get_network_by_bssid_locked(mac, mlme->addr.sa_data);
 		if (!net) {
 			printk(KERN_DEBUG PFX "wx_set_mlme: we should know the net here...\n");
-			return -EINVAL;
+			goto out;
 		}
 		return ieee80211softmac_deauth_req(mac, net, reason);
 	case IW_MLME_DISASSOC:
 		ieee80211softmac_send_disassoc_req(mac, reason);
-		return 0;
+		mac->associnfo.associated = 0;
+		mac->associnfo.associating = 0;
+		err = 0;
+		goto out;
 	default:
-		return -EOPNOTSUPP;
+		err = -EOPNOTSUPP;
 	}
+
+out:
+	mutex_unlock(&mac->associnfo.mutex);
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_wx_set_mlme);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-09-17 15:24:29.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c	2006-09-27 15:29:01.000000000 +0200
@@ -242,7 +242,7 @@ void bcm43xx_leds_update(struct bcm43xx_
 			//TODO
 			break;
 		case BCM43xx_LED_ASSOC:
-			if (bcm->softmac->associated)
+			if (bcm->softmac->associnfo.associated)
 				turn_on = 1;
 			break;
 #ifdef CONFIG_BCM43XX_DEBUG
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-09-24 18:34:58.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c	2006-09-27 15:28:36.000000000 +0200
@@ -847,7 +847,7 @@ static struct iw_statistics *bcm43xx_get
 	unsigned long flags;
 
 	wstats = &bcm->stats.wstats;
-	if (!mac->associated) {
+	if (!mac->associnfo.associated) {
 		wstats->miss.beacon = 0;
 //		bcm->ieee->ieee_stats.tx_retry_limit_exceeded = 0; // FIXME: should this be cleared here?
 		wstats->discard.retries = 0;
Index: wireless-2.6/net/ieee80211/softmac/ieee80211softmac_io.c
===================================================================
--- wireless-2.6.orig/net/ieee80211/softmac/ieee80211softmac_io.c	2006-09-17 15:21:53.000000000 +0200
+++ wireless-2.6/net/ieee80211/softmac/ieee80211softmac_io.c	2006-09-27 16:33:18.000000000 +0200
@@ -475,8 +475,13 @@ int ieee80211softmac_handle_beacon(struc
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 
-	if (mac->associated && memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
-		ieee80211softmac_process_erp(mac, network->erp_value);
+	/* This might race, but we don't really care and it's not worth
+	 * adding heavyweight locking in this fastpath.
+	 */
+	if (mac->associnfo.associated) {
+		if (memcmp(network->bssid, mac->associnfo.bssid, ETH_ALEN) == 0)
+			ieee80211softmac_process_erp(mac, network->erp_value);
+	}
 
 	return 0;
 }


-- 
Greetings Michael.
