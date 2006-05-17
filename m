From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 17 May 2006 15:38:01 -0400
Message-ID: <20060517193801.GC17895@tuxdriver.com>
References: <20060517193405.GB17895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arjan@linux.intel.com, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:36367 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751037AbWEQTie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 15:38:34 -0400
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20060517193405.GB17895@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 59d4b684fbe74b25ac8593f39d2aaa86aa485b1f:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Arjan van de Ven:
      unused exports in wireless drivers

Daniel Drake:
      set_security implementation inside softmac

 drivers/net/wireless/bcm43xx/bcm43xx_main.c     |   38 +++----------------
 drivers/net/wireless/hostap/hostap_80211_tx.c   |    1 -
 drivers/net/wireless/hostap/hostap_ap.c         |   11 ------
 drivers/net/wireless/hostap/hostap_main.c       |    2 -
 include/net/ieee80211softmac.h                  |    4 ++
 net/ieee80211/softmac/ieee80211softmac_module.c |   46 +++++++++++++++++++++++
 6 files changed, 55 insertions(+), 47 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index c050290..17b59ef 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3547,8 +3547,7 @@ static void bcm43xx_ieee80211_set_chan(s
 }
 
 /* set_security() callback in struct ieee80211_device */
-static void bcm43xx_ieee80211_set_security(struct net_device *net_dev,
-					   struct ieee80211_security *sec)
+static void bcm43xx_ieee80211_set_security(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
 	struct ieee80211_security *secinfo = &bcm->ieee->sec;
@@ -3559,42 +3558,15 @@ static void bcm43xx_ieee80211_set_securi
 
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
@@ -3613,7 +3585,7 @@ static void bcm43xx_ieee80211_set_securi
 						assert(0);
 						break;
 				}
-				bcm43xx_key_write(bcm, keyidx, algorithm, sec->keys[keyidx], secinfo->key_sizes[keyidx], &null_address[0]);
+				bcm43xx_key_write(bcm, keyidx, algorithm, secinfo->keys[keyidx], secinfo->key_sizes[keyidx], &null_address[0]);
 				bcm->key[keyidx].enabled = 1;
 				bcm->key[keyidx].algorithm = algorithm;
 			}
@@ -3694,6 +3666,7 @@ static int bcm43xx_init_private(struct b
 	bcm->ieee = netdev_priv(net_dev);
 	bcm->softmac = ieee80211_priv(net_dev);
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
+	bcm->softmac->set_security = bcm43xx_ieee80211_set_security;
 
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
 	bcm->pci_dev = pci_dev;
@@ -3729,7 +3702,6 @@ #endif /* CONFIG_BCM43XX_PIO */
 	
 	bcm->ieee->iw_mode = BCM43xx_INITIAL_IWMODE;
 	bcm->ieee->tx_headroom = sizeof(struct bcm43xx_txhdr);
-	bcm->ieee->set_security = bcm43xx_ieee80211_set_security;
 	bcm->ieee->hard_start_xmit = bcm43xx_ieee80211_hard_start_xmit;
 
 	return 0;
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 06a5214..4a5be70 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -534,5 +534,4 @@ int hostap_master_start_xmit(struct sk_b
 }
 
 
-EXPORT_SYMBOL(hostap_dump_tx_80211);
 EXPORT_SYMBOL(hostap_master_start_xmit);
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 06c3fa3..ba13125 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -3276,17 +3276,6 @@ EXPORT_SYMBOL(hostap_init_data);
 EXPORT_SYMBOL(hostap_init_ap_proc);
 EXPORT_SYMBOL(hostap_free_data);
 EXPORT_SYMBOL(hostap_check_sta_fw_version);
-EXPORT_SYMBOL(hostap_handle_sta_tx);
-EXPORT_SYMBOL(hostap_handle_sta_release);
 EXPORT_SYMBOL(hostap_handle_sta_tx_exc);
-EXPORT_SYMBOL(hostap_update_sta_ps);
-EXPORT_SYMBOL(hostap_handle_sta_rx);
-EXPORT_SYMBOL(hostap_is_sta_assoc);
-EXPORT_SYMBOL(hostap_is_sta_authorized);
-EXPORT_SYMBOL(hostap_add_sta);
-EXPORT_SYMBOL(hostap_update_rates);
-EXPORT_SYMBOL(hostap_add_wds_links);
-EXPORT_SYMBOL(hostap_wds_link_oper);
 #ifndef PRISM2_NO_KERNEL_IEEE80211_MGMT
-EXPORT_SYMBOL(hostap_deauth_all_stas);
 #endif /* PRISM2_NO_KERNEL_IEEE80211_MGMT */
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 8dd4c44..93786f4 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -1125,11 +1125,9 @@ EXPORT_SYMBOL(hostap_set_auth_algs);
 EXPORT_SYMBOL(hostap_dump_rx_header);
 EXPORT_SYMBOL(hostap_dump_tx_header);
 EXPORT_SYMBOL(hostap_80211_header_parse);
-EXPORT_SYMBOL(hostap_80211_prism_header_parse);
 EXPORT_SYMBOL(hostap_80211_get_hdrlen);
 EXPORT_SYMBOL(hostap_get_stats);
 EXPORT_SYMBOL(hostap_setup_dev);
-EXPORT_SYMBOL(hostap_proc);
 EXPORT_SYMBOL(hostap_set_multicast_list_queue);
 EXPORT_SYMBOL(hostap_set_hostapd);
 EXPORT_SYMBOL(hostap_set_hostapd_sta);
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 703463a..1729842 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -172,6 +172,10 @@ struct ieee80211softmac_device {
 	void (*set_bssid_filter)(struct net_device *dev, const u8 *bssid);
 	void (*set_channel)(struct net_device *dev, u8 channel);
 
+	/* implement this if you need to configure hardware encryption
+	 * when the user changes security settings */
+	void (*set_security)(struct net_device *dev);
+
 	/* assign if you need it, informational only */
 	void (*link_change)(struct net_device *dev);
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_module.c b/net/ieee80211/softmac/ieee80211softmac_module.c
index 4b2e57d..03cd26c 100644
--- a/net/ieee80211/softmac/ieee80211softmac_module.c
+++ b/net/ieee80211/softmac/ieee80211softmac_module.c
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
-- 
John W. Linville
linville@tuxdriver.com
