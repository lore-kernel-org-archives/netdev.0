From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH,RFC] set_security implementation inside softmac
Date: Mon, 08 May 2006 15:57:14 +0100
Message-ID: <445F5C4A.90502@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020406070102080104000002"
Cc: ipw2100-admin@linux.intel.com, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:34979 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932216AbWEHOkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 10:40:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020406070102080104000002
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This patch moves the boring set_security logic (which is currently 
duplicated line-for-line in zd1211 and bcm43xx) into softmac, and adds a 
hook so that drivers can still be notified about sec changes (so that 
they can upload keys to the device, etc).

I also attached a patch for bcm43xx to illustrate this.

However, the set_security stuff in ieee80211 feels kind of sub-standard 
(or have I just misunderstood it?), how each driver is expected to 
populate ieee->sec from that callback, and how the driver doesn't get an 
opportunity to say "actually, I can't work with that configuration".

Is it worth fixing the whole thing, or is this kind of patch acceptable?

Thanks,
Daniel

--------------020406070102080104000002
Content-Type: text/x-patch;
 name="softmac-set-security.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="softmac-set-security.patch"

Index: linux/include/net/ieee80211softmac.h
===================================================================
--- linux.orig/include/net/ieee80211softmac.h
+++ linux/include/net/ieee80211softmac.h
@@ -172,6 +172,10 @@ struct ieee80211softmac_device {
 	void (*set_bssid_filter)(struct net_device *dev, const u8 *bssid);
 	void (*set_channel)(struct net_device *dev, u8 channel);
 
+	/* implement this if you need to configure hardware encryption
+	 * when the user changes security settings */
+	void (*set_security)(struct net_device *dev);
+
 	/* assign if you need it, informational only */
 	void (*link_change)(struct net_device *dev);
 
Index: linux/net/ieee80211/softmac/ieee80211softmac_module.c
===================================================================
--- linux.orig/net/ieee80211/softmac/ieee80211softmac_module.c
+++ linux/net/ieee80211/softmac/ieee80211softmac_module.c
@@ -27,6 +27,51 @@
 #include "ieee80211softmac_priv.h"
 #include <linux/sort.h>
 #include <linux/etherdevice.h>
+#include <net/ieee80211.h>
+
+static void set_security(struct net_device *dev,
+	struct ieee80211_security *sec)
+{
+	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
+	struct ieee80211_device *ieee = mac->ieee;
+	struct ieee80211_security *secinfo = &ieee->sec;
+	int keyidx;
+
+	dprintk(KERN_NOTICE PFX "set_security:\n");
+	secinfo->flags = sec->flags;
+
+	for (keyidx = 0; keyidx < WEP_KEYS; keyidx++)
+		if (sec->flags & (1 << keyidx)) {
+			secinfo->encode_alg[keyidx] = sec->encode_alg[keyidx];
+			secinfo->key_sizes[keyidx] = sec->key_sizes[keyidx];
+			memcpy(secinfo->keys[keyidx], sec->keys[keyidx],
+			       SCM_KEY_LEN);
+		}
+
+	if (sec->flags & SEC_ACTIVE_KEY) {
+		secinfo->active_key = sec->active_key;
+		dprintk("   .active_key = %d\n", sec->active_key);
+	}
+	if (sec->flags & SEC_UNICAST_GROUP) {
+		secinfo->unicast_uses_group = sec->unicast_uses_group;
+		dprintk("   .unicast_uses_group = %d\n", sec->unicast_uses_group);
+	}
+	if (sec->flags & SEC_LEVEL) {
+		secinfo->level = sec->level;
+		dprintk("   .level = %d\n", sec->level);
+	}
+	if (sec->flags & SEC_ENABLED) {
+		secinfo->enabled = sec->enabled;
+		dprintk("   .enabled = %d\n", sec->enabled);
+	}
+	if (sec->flags & SEC_ENCRYPT) {
+		secinfo->encrypt = sec->encrypt;
+		dprintk("   .encrypt = %d\n", sec->encrypt);
+	}
+
+	if (mac->set_security)
+		mac->set_security(dev);
+}
 
 struct net_device *alloc_ieee80211softmac(int sizeof_priv)
 {
@@ -44,6 +89,7 @@ struct net_device *alloc_ieee80211softma
 	softmac->ieee->handle_assoc_response = ieee80211softmac_handle_assoc_response;
 	softmac->ieee->handle_reassoc_request = ieee80211softmac_handle_reassoc_req;
 	softmac->ieee->handle_disassoc = ieee80211softmac_handle_disassoc;
+	softmac->ieee->set_security = set_security;
 	softmac->scaninfo = NULL;
 
 	softmac->associnfo.scan_retry = IEEE80211SOFTMAC_ASSOC_SCAN_RETRY_LIMIT;

--------------020406070102080104000002
Content-Type: text/x-patch;
 name="bcm43xx-set-security.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm43xx-set-security.patch"

Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3548,8 +3548,7 @@ static void bcm43xx_ieee80211_set_chan(s
 }
 
 /* set_security() callback in struct ieee80211_device */
-static void bcm43xx_ieee80211_set_security(struct net_device *net_dev,
-					   struct ieee80211_security *sec)
+static void bcm43xx_ieee80211_set_security(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct ieee80211_security *secinfo = &bcm->ieee->sec;
@@ -3560,42 +3559,15 @@ static void bcm43xx_ieee80211_set_securi
 
 	bcm43xx_lock_mmio(bcm, flags);
 
-	for (keyidx = 0; keyidx<WEP_KEYS; keyidx++)
-		if (sec->flags & (1<<keyidx)) {
-			secinfo->encode_alg[keyidx] = sec->encode_alg[keyidx];
-			secinfo->key_sizes[keyidx] = sec->key_sizes[keyidx];
-			memcpy(secinfo->keys[keyidx], sec->keys[keyidx], SCM_KEY_LEN);
-		}
-	
-	if (sec->flags & SEC_ACTIVE_KEY) {
-		secinfo->active_key = sec->active_key;
-		dprintk(KERN_INFO PFX "   .active_key = %d\n", sec->active_key);
-	}
-	if (sec->flags & SEC_UNICAST_GROUP) {
-		secinfo->unicast_uses_group = sec->unicast_uses_group;
-		dprintk(KERN_INFO PFX "   .unicast_uses_group = %d\n", sec->unicast_uses_group);
-	}
-	if (sec->flags & SEC_LEVEL) {
-		secinfo->level = sec->level;
-		dprintk(KERN_INFO PFX "   .level = %d\n", sec->level);
-	}
-	if (sec->flags & SEC_ENABLED) {
-		secinfo->enabled = sec->enabled;
-		dprintk(KERN_INFO PFX "   .enabled = %d\n", sec->enabled);
-	}
-	if (sec->flags & SEC_ENCRYPT) {
-		secinfo->encrypt = sec->encrypt;
-		dprintk(KERN_INFO PFX "   .encrypt = %d\n", sec->encrypt);
-	}
 	if (bcm->initialized && !bcm->ieee->host_encrypt) {
 		if (secinfo->enabled) {
 			/* upload WEP keys to hardware */
 			char null_address[6] = { 0 };
 			u8 algorithm = 0;
 			for (keyidx = 0; keyidx<WEP_KEYS; keyidx++) {
-				if (!(sec->flags & (1<<keyidx)))
+				if (!(secinfo->flags & (1<<keyidx)))
 					continue;
-				switch (sec->encode_alg[keyidx]) {
+				switch (secinfo->encode_alg[keyidx]) {
 					case SEC_ALG_NONE: algorithm = BCM43xx_SEC_ALGO_NONE; break;
 					case SEC_ALG_WEP:
 						algorithm = BCM43xx_SEC_ALGO_WEP;
@@ -3614,7 +3586,7 @@ static void bcm43xx_ieee80211_set_securi
 						assert(0);
 						break;
 				}
-				bcm43xx_key_write(bcm, keyidx, algorithm, sec->keys[keyidx], secinfo->key_sizes[keyidx], &null_address[0]);
+				bcm43xx_key_write(bcm, keyidx, algorithm, secinfo->keys[keyidx], secinfo->key_sizes[keyidx], &null_address[0]);
 				bcm->key[keyidx].enabled = 1;
 				bcm->key[keyidx].algorithm = algorithm;
 			}
@@ -3695,6 +3667,7 @@ static int bcm43xx_init_private(struct b
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
+	bcm->softmac->set_security = bcm43xx_ieee80211_set_security;
 
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
 	bcm->pci_dev = pci_dev;
@@ -3730,7 +3703,6 @@ static int bcm43xx_init_private(struct b
 	
 	bcm->ieee->iw_mode = BCM43xx_INITIAL_IWMODE;
 	bcm->ieee->tx_headroom = sizeof(struct bcm43xx_txhdr);
-	bcm->ieee->set_security = bcm43xx_ieee80211_set_security;
 	bcm->ieee->hard_start_xmit = bcm43xx_ieee80211_hard_start_xmit;
 
 	return 0;

--------------020406070102080104000002--
