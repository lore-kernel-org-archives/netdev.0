From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull upstream-fixes branch of wireless-2.6
Date: Fri, 5 May 2006 21:06:18 -0400
Message-ID: <20060506010613.GA26189@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:5902 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751184AbWEFBHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 21:07:04 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are fixes intended for 2.6.17...thanks!

---

The following changes since commit d98550e334715b2d9e45f8f0f4e1608720108640:
  Linus Torvalds:
        Merge branch 'merge' of git://git.kernel.org/.../paulus/powerpc

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-fixes

Daniel Drake:
      softmac: don't reassociate if user asked for deauthentication
      softmac: make non-operational after being stopped

David Woodhouse:
      bcm43xx: Fix access to non-existent PHY registers

Jean Delvare:
      ieee80211: Fix A band channel count (resent)

Michael Buesch:
      bcm43xx: fix iwmode crash when down
      bcm43xx: Fix array overrun in bcm43xx_geo_init

Stefano Brivio:
      bcm43xx: check for valid MAC address in SPROM

 drivers/net/wireless/bcm43xx/bcm43xx_main.c     |   45 ++++++++++++++---------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h     |    6 ++-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c      |    2 +
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c       |    7 +++-
 include/net/ieee80211.h                         |    6 ++-
 include/net/ieee80211softmac.h                  |    3 +-
 net/ieee80211/softmac/ieee80211softmac_assoc.c  |   17 ++++++++-
 net/ieee80211/softmac/ieee80211softmac_auth.c   |   16 +++++++-
 net/ieee80211/softmac/ieee80211softmac_module.c |    4 ++
 net/ieee80211/softmac/ieee80211softmac_scan.c   |    8 ++++
 10 files changed, 84 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 9a06e61..e2982a8 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -939,9 +939,9 @@ #endif
 	return 0;
 }
 
-static void bcm43xx_geo_init(struct bcm43xx_private *bcm)
+static int bcm43xx_geo_init(struct bcm43xx_private *bcm)
 {
-	struct ieee80211_geo geo;
+	struct ieee80211_geo *geo;
 	struct ieee80211_channel *chan;
 	int have_a = 0, have_bg = 0;
 	int i;
@@ -949,7 +949,10 @@ static void bcm43xx_geo_init(struct bcm4
 	struct bcm43xx_phyinfo *phy;
 	const char *iso_country;
 
-	memset(&geo, 0, sizeof(geo));
+	geo = kzalloc(sizeof(*geo), GFP_KERNEL);
+	if (!geo)
+		return -ENOMEM;
+
 	for (i = 0; i < bcm->nr_80211_available; i++) {
 		phy = &(bcm->core_80211_ext[i].phy);
 		switch (phy->type) {
@@ -967,31 +970,36 @@ static void bcm43xx_geo_init(struct bcm4
 	iso_country = bcm43xx_locale_iso(bcm->sprom.locale);
 
  	if (have_a) {
-		for (i = 0, channel = 0; channel < 201; channel++) {
-			chan = &geo.a[i++];
+		for (i = 0, channel = IEEE80211_52GHZ_MIN_CHANNEL;
+		      channel <= IEEE80211_52GHZ_MAX_CHANNEL; channel++) {
+			chan = &geo->a[i++];
 			chan->freq = bcm43xx_channel_to_freq_a(channel);
 			chan->channel = channel;
 		}
-		geo.a_channels = i;
+		geo->a_channels = i;
 	}
 	if (have_bg) {
-		for (i = 0, channel = 1; channel < 15; channel++) {
-			chan = &geo.bg[i++];
+		for (i = 0, channel = IEEE80211_24GHZ_MIN_CHANNEL;
+		      channel <= IEEE80211_24GHZ_MAX_CHANNEL; channel++) {
+			chan = &geo->bg[i++];
 			chan->freq = bcm43xx_channel_to_freq_bg(channel);
 			chan->channel = channel;
 		}
-		geo.bg_channels = i;
+		geo->bg_channels = i;
 	}
-	memcpy(geo.name, iso_country, 2);
+	memcpy(geo->name, iso_country, 2);
 	if (0 /*TODO: Outdoor use only */)
-		geo.name[2] = 'O';
+		geo->name[2] = 'O';
 	else if (0 /*TODO: Indoor use only */)
-		geo.name[2] = 'I';
+		geo->name[2] = 'I';
 	else
-		geo.name[2] = ' ';
-	geo.name[3] = '\0';
+		geo->name[2] = ' ';
+	geo->name[3] = '\0';
+
+	ieee80211_set_geo(bcm->ieee, geo);
+	kfree(geo);
 
-	ieee80211_set_geo(bcm->ieee, &geo);
+	return 0;
 }
 
 /* DummyTransmission function, as documented on 
@@ -3479,16 +3487,17 @@ static int bcm43xx_attach_board(struct b
 			goto err_80211_unwind;
 		bcm43xx_wireless_core_disable(bcm);
 	}
+	err = bcm43xx_geo_init(bcm);
+	if (err)
+		goto err_80211_unwind;
 	bcm43xx_pctl_set_crystal(bcm, 0);
 
 	/* Set the MAC address in the networking subsystem */
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
+	if (is_valid_ether_addr(bcm->sprom.et1macaddr))
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.et1macaddr, 6);
 	else
 		memcpy(bcm->net_dev->dev_addr, bcm->sprom.il0macaddr, 6);
 
-	bcm43xx_geo_init(bcm);
-
 	snprintf(bcm->nick, IW_ESSID_MAX_SIZE,
 		 "Broadcom %04X", bcm->chip_id);
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index eca79a3..30a202b 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -118,12 +118,14 @@ int bcm43xx_channel_to_freq(struct bcm43
 static inline
 int bcm43xx_is_valid_channel_a(u8 channel)
 {
-	return (channel <= 200);
+	return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
+	       && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
 }
 static inline
 int bcm43xx_is_valid_channel_bg(u8 channel)
 {
-	return (channel >= 1 && channel <= 14);
+	return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
+	       && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
 }
 static inline
 int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index 3313716..b0abac5 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -1287,7 +1287,7 @@ static void bcm43xx_phy_initg(struct bcm
 	if (radio->revision == 8)
 		bcm43xx_phy_write(bcm, 0x0805, 0x3230);
 	bcm43xx_phy_init_pctl(bcm);
-	if (bcm->chip_id == 0x4306 && bcm->chip_package != 2) {
+	if (bcm->chip_id == 0x4306 && bcm->chip_package == 2) {
 		bcm43xx_phy_write(bcm, 0x0429,
 				  bcm43xx_phy_read(bcm, 0x0429) & 0xBFFF);
 		bcm43xx_phy_write(bcm, 0x04C3,
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 3edbb48..b450639 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -182,8 +182,11 @@ static int bcm43xx_wx_set_mode(struct ne
 		mode = BCM43xx_INITIAL_IWMODE;
 
 	bcm43xx_lock_mmio(bcm, flags);
-	if (bcm->ieee->iw_mode != mode)
-		bcm43xx_set_iwmode(bcm, mode);
+	if (bcm->initialized) {
+		if (bcm->ieee->iw_mode != mode)
+			bcm43xx_set_iwmode(bcm, mode);
+	} else
+		bcm->ieee->iw_mode = mode;
 	bcm43xx_unlock_mmio(bcm, flags);
 
 	return 0;
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 4725ff8..d5926bf 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -955,11 +955,13 @@ #define CFG_IEEE80211_RTS (1<<2)
 
 #define IEEE80211_24GHZ_MIN_CHANNEL 1
 #define IEEE80211_24GHZ_MAX_CHANNEL 14
-#define IEEE80211_24GHZ_CHANNELS    14
+#define IEEE80211_24GHZ_CHANNELS (IEEE80211_24GHZ_MAX_CHANNEL - \
+				  IEEE80211_24GHZ_MIN_CHANNEL + 1)
 
 #define IEEE80211_52GHZ_MIN_CHANNEL 34
 #define IEEE80211_52GHZ_MAX_CHANNEL 165
-#define IEEE80211_52GHZ_CHANNELS    131
+#define IEEE80211_52GHZ_CHANNELS (IEEE80211_52GHZ_MAX_CHANNEL - \
+				  IEEE80211_52GHZ_MIN_CHANNEL + 1)
 
 enum {
 	IEEE80211_CH_PASSIVE_ONLY = (1 << 0),
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index b1ebfba..052ed59 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -204,7 +204,8 @@ struct ieee80211softmac_device {
 	
 	/* couple of flags */
 	u8 scanning:1, /* protects scanning from being done multiple times at once */
-	   associated:1;
+	   associated:1,
+	   running:1;
 	
 	struct ieee80211softmac_scaninfo *scaninfo;
 	struct ieee80211softmac_assoc_info associnfo;
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index fb79ce7..57ea9f6 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -51,11 +51,12 @@ ieee80211softmac_assoc(struct ieee80211s
 	spin_lock_irqsave(&mac->lock, flags);
 	mac->associnfo.associating = 1;
 	mac->associated = 0; /* just to make sure */
-	spin_unlock_irqrestore(&mac->lock, flags);
 
 	/* Set a timer for timeout */
 	/* FIXME: make timeout configurable */
-	schedule_delayed_work(&mac->associnfo.timeout, 5 * HZ);
+	if (likely(mac->running))
+		schedule_delayed_work(&mac->associnfo.timeout, 5 * HZ);
+	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
 void
@@ -319,6 +320,9 @@ ieee80211softmac_handle_assoc_response(s
 	u16 status = le16_to_cpup(&resp->status);
 	struct ieee80211softmac_network *network = NULL;
 	unsigned long flags;
+
+	if (unlikely(!mac->running))
+		return -ENODEV;
 	
 	spin_lock_irqsave(&mac->lock, flags);
 
@@ -377,10 +381,16 @@ ieee80211softmac_handle_disassoc(struct 
 {
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	unsigned long flags;
+
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	if (memcmp(disassoc->header.addr2, mac->associnfo.bssid, ETH_ALEN))
 		return 0;
+
 	if (memcmp(disassoc->header.addr1, mac->dev->dev_addr, ETH_ALEN))
 		return 0;
+
 	dprintk(KERN_INFO PFX "got disassoc frame\n");
 	netif_carrier_off(dev);
 	spin_lock_irqsave(&mac->lock, flags);
@@ -400,6 +410,9 @@ ieee80211softmac_handle_reassoc_req(stru
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	struct ieee80211softmac_network *network;
 
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	network = ieee80211softmac_get_network_by_bssid(mac, resp->header.addr3);
 	if (!network) {
 		dprintkl(KERN_INFO PFX "reassoc request from unknown network\n");
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 9a0eac6..06e3326 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -86,6 +86,11 @@ ieee80211softmac_auth_queue(void *data)
 		
 		/* Lock and set flags */
 		spin_lock_irqsave(&mac->lock, flags);
+		if (unlikely(!mac->running)) {
+			/* Prevent reschedule on workqueue flush */
+			spin_unlock_irqrestore(&mac->lock, flags);
+			return;
+		}
 		net->authenticated = 0;
 		net->authenticating = 1;
 		/* add a timeout call so we eventually give up waiting for an auth reply */
@@ -124,6 +129,9 @@ ieee80211softmac_auth_resp(struct net_de
 	unsigned long flags;
 	u8 * data;
 	
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	/* Find correct auth queue item */
 	spin_lock_irqsave(&mac->lock, flags);
 	list_for_each(list_ptr, &mac->auth_queue) {
@@ -298,8 +306,6 @@ ieee80211softmac_deauth_from_net(struct 
 	
 	/* can't transmit data right now... */
 	netif_carrier_off(mac->dev);
-	/* let's try to re-associate */
-	schedule_work(&mac->associnfo.work);
 	spin_unlock_irqrestore(&mac->lock, flags);
 }
 
@@ -338,6 +344,9 @@ ieee80211softmac_deauth_resp(struct net_
 	struct ieee80211softmac_network *net = NULL;
 	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
 	
+	if (unlikely(!mac->running))
+		return -ENODEV;
+
 	if (!deauth) {
 		dprintk("deauth without deauth packet. eek!\n");
 		return 0;
@@ -360,5 +369,8 @@ ieee80211softmac_deauth_resp(struct net_
 	}
 
 	ieee80211softmac_deauth_from_net(mac, net);
+
+	/* let's try to re-associate */
+	schedule_work(&mac->associnfo.work);
 	return 0;
 }
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index be83bdc..6252be2 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -89,6 +89,8 @@ ieee80211softmac_clear_pending_work(stru
 	ieee80211softmac_wait_for_scan(sm);
 	
 	spin_lock_irqsave(&sm->lock, flags);
+	sm->running = 0;
+
 	/* Free all pending assoc work items */
 	cancel_delayed_work(&sm->associnfo.work);
 	
@@ -204,6 +206,8 @@ void ieee80211softmac_start(struct net_d
 		assert(0);
 	if (mac->txrates_change)
 		mac->txrates_change(dev, change, &oldrates);
+
+	mac->running = 1;
 }
 EXPORT_SYMBOL_GPL(ieee80211softmac_start);
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_scan.c b/net/ieee80211/softmac/ieee80211softmac_scan.c
index 2b9e7ed..d31cf77 100644
--- a/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ b/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -115,7 +115,15 @@ void ieee80211softmac_scan(void *d)
 			// TODO: is this if correct, or should we do this only if scanning from assoc request?
 			if (sm->associnfo.req_essid.len)
 				ieee80211softmac_send_mgt_frame(sm, &sm->associnfo.req_essid, IEEE80211_STYPE_PROBE_REQ, 0);
+
+			spin_lock_irqsave(&sm->lock, flags);
+			if (unlikely(!sm->running)) {
+				/* Prevent reschedule on workqueue flush */
+				spin_unlock_irqrestore(&sm->lock, flags);
+				break;
+			}
 			schedule_delayed_work(&si->softmac_scan, IEEE80211SOFTMAC_PROBE_DELAY);
+			spin_unlock_irqrestore(&sm->lock, flags);
 			return;
 		} else {
 			dprintk(PFX "Not probing Channel %d (not allowed here)\n", si->channels[current_channel_idx].channel);
-- 
John W. Linville
linville@tuxdriver.com
