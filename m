From: Jiri Benc <jbenc@suse.cz>
Subject: [5/9] ipw: fix after "ieee80211_device alignment fix"
Date: Fri, 3 Jun 2005 18:32:54 +0200
Message-ID: <20050603183254.03afaa81@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2100 and ipw2200 after the API change (alignment,
struct iee80211_device).

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/drivers/net/wireless/ipw2100.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2100.c	2005-06-01 11:03:37.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2100.c	2005-06-03 11:57:33.000000000 +0200
@@ -1772,7 +1772,7 @@
 /* Called by register_netdev() */
 static int ipw2100_net_init(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	return ipw2100_up(priv, 1);
 }
 
@@ -3248,9 +3248,9 @@
 	return IRQ_NONE;
 }
 
-static int ipw2100_tx(struct ieee80211_txb *txb, struct net_device *dev)
+static int ipw2100_tx(struct ieee80211_txb *txb, struct ieee80211_device *ieee)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
 	unsigned long flags;
@@ -3260,7 +3260,7 @@
 	if (!(priv->status & STATUS_ASSOCIATED)) {
 		IPW_DEBUG_INFO("Can not transmit when not connected.\n");
 		priv->ieee->stats.tx_carrier_errors++;
-		netif_stop_queue(dev);
+		netif_stop_queue(ieee80211_dev(ieee));
 		goto fail_unlock;
 	}
 
@@ -3291,7 +3291,7 @@
 	return 0;
 
  fail_unlock:
-	netif_stop_queue(dev);
+	netif_stop_queue(ieee80211_dev(ieee));
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 	return 1;
 }
@@ -5418,10 +5418,10 @@
 		ipw2100_configure_security(priv, 0);
 }
 
-static void shim__set_security(struct net_device *dev,
+static void shim__set_security(struct ieee80211_device *ieee,
 			       struct ieee80211_security *sec)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	int i, force_update = 0;
 
 	down(&priv->action_sem);
@@ -5609,7 +5609,7 @@
  * method as well) to talk to the firmware */
 static int ipw2100_set_address(struct net_device *dev, void *p)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	struct sockaddr *addr = p;
 	int err = 0;
 
@@ -5637,7 +5637,7 @@
 
 static int ipw2100_open(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	unsigned long flags;
 	IPW_DEBUG_INFO("dev->open\n");
 
@@ -5651,7 +5651,7 @@
 
 static int ipw2100_close(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	unsigned long flags;
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
@@ -5692,7 +5692,7 @@
  */
 static void ipw2100_tx_timeout(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	priv->ieee->stats.tx_errors++;
 
@@ -5715,7 +5715,7 @@
  */
 static struct net_device_stats *ipw2100_stats(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	return &priv->ieee->stats;
 }
@@ -5802,7 +5802,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5829,7 +5829,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5839,7 +5839,7 @@
 
 static int ipw2100_wpa_set_param(struct net_device *dev, u8 name, u32 value){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int ret=0;
 
 	switch(name){
@@ -5878,7 +5878,7 @@
 
 static int ipw2100_wpa_mlme(struct net_device *dev, int command, int reason){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int ret=0;
 
 	switch(command){
@@ -5920,8 +5920,8 @@
 static int ipw2100_wpa_set_wpa_ie(struct net_device *dev,
 				struct ipw2100_param *param, int plen){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	u8 *buf;
 
 	if (! ieee->wpa_enabled)
@@ -5960,8 +5960,8 @@
 				struct ipw2100_param *param, int param_len){
 
 	int ret = 0;
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	struct ieee80211_crypto_ops *ops;
 	struct ieee80211_crypt_data **crypt;
 
@@ -6081,7 +6081,7 @@
 	}
  done:
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 
 	/* Do not reset port if card is in Managed mode since resetting will
 	 * generate new IEEE 802.11 authentication which may end up in looping
@@ -6178,7 +6178,7 @@
 static void ipw_ethtool_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *info)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	char fw_ver[64], ucode_ver[64];
 
 	strcpy(info->driver, DRV_NAME);
@@ -6195,7 +6195,7 @@
 
 static u32 ipw2100_ethtool_get_link(struct net_device *dev)
 {
-    struct ipw2100_priv *priv = ieee80211_priv(dev);
+    struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
     return (priv->status & STATUS_ASSOCIATED) ? 1 : 0;
 }
 
@@ -6288,12 +6288,14 @@
 {
 	struct ipw2100_priv *priv;
 	struct net_device *dev;
+	struct ieee80211_device *ieee;
 
-	dev = alloc_ieee80211(sizeof(struct ipw2100_priv));
-	if (!dev)
+	ieee = alloc_ieee80211(sizeof(struct ipw2100_priv));
+	if (!ieee)
 		return NULL;
-	priv = ieee80211_priv(dev);
-	priv->ieee = netdev_priv(dev);
+	dev = ieee80211_dev(ieee);
+	priv = ieee80211_priv(ieee);
+	priv->ieee = ieee;
 	priv->pci_dev = pci_dev;
 	priv->net_dev = dev;
 
@@ -6477,7 +6479,7 @@
 		return err;
 	}
 
-	priv = ieee80211_priv(dev);
+	priv = ieee80211_dev_to_priv(dev);
 
 	pci_set_master(pci_dev);
 	pci_set_drvdata(pci_dev, priv);
@@ -6618,7 +6620,7 @@
 		ipw2100_queues_free(priv);
 		sysfs_remove_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
 
-		free_ieee80211(dev);
+		free_ieee80211(netdev_priv(dev));
 		pci_set_drvdata(pci_dev, NULL);
 	}
 
@@ -6675,7 +6677,7 @@
 		if (dev->base_addr)
 			iounmap((unsigned char *)dev->base_addr);
 
-		free_ieee80211(dev);
+		free_ieee80211(netdev_priv(dev));
 	}
 
 	pci_release_regions(pci_dev);
@@ -6918,7 +6920,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	if (!(priv->status & STATUS_ASSOCIATED))
 		strcpy(wrqu->name, "unassociated");
 	else
@@ -6933,7 +6935,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_freq *fwrq = &wrqu->freq;
 	int err = 0;
 
@@ -6984,7 +6986,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->freq.e = 0;
 
@@ -7005,7 +7007,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	IPW_DEBUG_WX("SET Mode -> %d \n", wrqu->mode);
@@ -7048,7 +7050,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->mode = priv->ieee->iw_mode;
 	IPW_DEBUG_WX("GET Mode -> %d\n", wrqu->mode);
@@ -7084,7 +7086,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	u16 val;
 	int i, level;
@@ -7196,7 +7198,7 @@
 			      struct iw_request_info *info,
 			      union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	static const unsigned char any[] = {
@@ -7251,7 +7253,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
@@ -7271,7 +7273,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	char *essid = ""; /* ANY */
 	int length = 0;
 	int err = 0;
@@ -7325,7 +7327,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured ESSID then return that; otherwise return ANY */
@@ -7353,7 +7355,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (wrqu->data.length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
@@ -7375,7 +7377,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->data.length = strlen(priv->nick) + 1;
 	memcpy(extra, priv->nick, wrqu->data.length);
@@ -7390,7 +7392,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	u32 target_rate = wrqu->bitrate.value;
 	u32 rate;
 	int err = 0;
@@ -7431,7 +7433,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int val;
 	int len = sizeof(val);
 	int err = 0;
@@ -7483,7 +7485,7 @@
 			      struct iw_request_info *info,
 			      union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int value, err;
 
 	/* Auto RTS not yet supported */
@@ -7523,7 +7525,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->rts.value = priv->rts_threshold & ~RTS_DISABLED;
 	wrqu->rts.fixed = 1; /* no auto select */
@@ -7540,7 +7542,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0, value;
 
 	if (priv->ieee->iw_mode != IW_MODE_ADHOC)
@@ -7580,7 +7582,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (priv->ieee->iw_mode != IW_MODE_ADHOC) {
 		wrqu->power.disabled = 1;
@@ -7616,7 +7618,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (!wrqu->frag.fixed)
 		return -EINVAL;
@@ -7646,7 +7648,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	wrqu->frag.value = priv->frag_threshold & ~FRAG_DISABLED;
 	wrqu->frag.fixed = 0;	/* no auto select */
 	wrqu->frag.disabled = (priv->frag_threshold & FRAG_DISABLED) ? 1 : 0;
@@ -7660,7 +7662,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	if (wrqu->retry.flags & IW_RETRY_LIFETIME ||
@@ -7709,7 +7711,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->retry.disabled = 0; /* can't be disabled */
 
@@ -7738,7 +7740,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	down(&priv->action_sem);
@@ -7769,7 +7771,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_get_scan(priv->ieee, info, wrqu, extra);
 }
 
@@ -7785,7 +7787,7 @@
 	 * No check of STATUS_INITIALIZED required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_set_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7797,7 +7799,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_get_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7805,7 +7807,7 @@
 			        struct iw_request_info *info,
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	down(&priv->action_sem);
@@ -7855,7 +7857,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (!(priv->power_mode & IPW_POWER_ENABLED)) {
 		wrqu->power.disabled = 1;
@@ -7880,7 +7882,7 @@
 				  struct iw_request_info *info,
 				  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int *parms = (int *)extra;
 	int enable = (parms[0] > 0);
 	int err = 0;
@@ -7911,7 +7913,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	if (priv->status & STATUS_INITIALIZED)
 		schedule_reset(priv);
 	return 0;
@@ -7923,7 +7925,7 @@
 				    struct iw_request_info *info,
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0, mode = *(int *)extra;
 
 	down(&priv->action_sem);
@@ -7951,7 +7953,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int level = IPW_POWER_LEVEL(priv->power_mode);
 	s32 timeout, period;
 
@@ -7988,7 +7990,7 @@
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	int err, mode = *(int *)extra;
 
 	down(&priv->action_sem);
@@ -8021,7 +8023,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (priv->config & CFG_LONG_PREAMBLE)
 		snprintf(wrqu->name, IFNAMSIZ, "long (1)");
@@ -8163,7 +8165,7 @@
 	int tx_qual;
 	int beacon_qual;
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_statistics *wstats;
 	u32 rssi, quality, tx_retries, missed_beacons, tx_failures;
 	u32 ord_len = sizeof(u32);
Index: netdev/drivers/net/wireless/ipw2200.c
===================================================================
--- netdev.orig/drivers/net/wireless/ipw2200.c	2005-06-01 11:03:37.000000000 +0200
+++ netdev/drivers/net/wireless/ipw2200.c	2005-06-03 11:57:33.000000000 +0200
@@ -5157,7 +5157,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	if (!(priv->status & STATUS_ASSOCIATED))
 		strcpy(wrqu->name, "unassociated");
 	else 
@@ -5210,7 +5210,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra) 
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_freq *fwrq = &wrqu->freq;
 	
 	/* if setting by freq convert to channel */
@@ -5244,7 +5244,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->freq.e = 0;
 
@@ -5264,7 +5264,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int err = 0;
 
 	IPW_DEBUG_WX("Set MODE: %d\n", wrqu->mode);
@@ -5317,7 +5317,7 @@
 			       struct iw_request_info *info, 
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->mode = priv->ieee->iw_mode;
 	IPW_DEBUG_WX("Get MODE -> %d\n", wrqu->mode);
@@ -5354,7 +5354,7 @@
 			    struct iw_request_info *info, 
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_range *range = (struct iw_range *)extra;
 	u16 val;
 	int i;
@@ -5418,7 +5418,7 @@
 			  struct iw_request_info *info, 
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	static const unsigned char any[] = {
 		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
@@ -5472,7 +5472,7 @@
 			  struct iw_request_info *info, 
 			  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
 	if (priv->config & CFG_STATIC_BSSID || 
@@ -5491,7 +5491,7 @@
 			    struct iw_request_info *info, 
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	char *essid = ""; /* ANY */
 	int length = 0;
   
@@ -5543,7 +5543,7 @@
 			    struct iw_request_info *info, 
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured ESSID then return that; otherwise return ANY */
@@ -5567,7 +5567,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	IPW_DEBUG_WX("Setting nick to '%s'\n", extra);
 	if (wrqu->data.length > IW_ESSID_MAX_SIZE)
@@ -5586,7 +5586,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	IPW_DEBUG_WX("Getting nick\n");
 	wrqu->data.length = strlen(priv->nick) + 1;
 	memcpy(extra, priv->nick, wrqu->data.length);
@@ -5607,7 +5607,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv * priv = ieee80211_priv(dev);
+	struct ipw_priv * priv = ieee80211_dev_to_priv(dev);
 	wrqu->bitrate.value = priv->last_rate;
 
 	IPW_DEBUG_WX("GET Rate -> %d \n", wrqu->bitrate.value);
@@ -5619,7 +5619,7 @@
 			  struct iw_request_info *info, 
 			  union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (wrqu->rts.disabled)
 		priv->rts_threshold = DEFAULT_RTS_THRESHOLD;
@@ -5640,7 +5640,7 @@
 			  struct iw_request_info *info, 
 			  union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	wrqu->rts.value = priv->rts_threshold;
 	wrqu->rts.fixed = 0;	/* no auto select */
 	wrqu->rts.disabled = 
@@ -5655,7 +5655,7 @@
 			    struct iw_request_info *info, 
 			    union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	struct ipw_tx_power tx_power;
 	int i;
 
@@ -5699,7 +5699,7 @@
 			    struct iw_request_info *info, 
 			    union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	wrqu->power.value = priv->tx_power;
 	wrqu->power.fixed = 1;
@@ -5717,7 +5717,7 @@
 			       struct iw_request_info *info, 
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (wrqu->frag.disabled)
 		priv->ieee->fts = DEFAULT_FTS;
@@ -5738,7 +5738,7 @@
 			       struct iw_request_info *info, 
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	wrqu->frag.value = priv->ieee->fts;
 	wrqu->frag.fixed = 0;	/* no auto select */
 	wrqu->frag.disabled = 
@@ -5771,7 +5771,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	IPW_DEBUG_WX("Start scan\n");
 	if (ipw_request_scan(priv))
 		return -EIO;
@@ -5782,7 +5782,7 @@
 			   struct iw_request_info *info, 
 			   union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_get_scan(priv->ieee, info, wrqu, extra);
 }
 
@@ -5790,7 +5790,7 @@
 				 struct iw_request_info *info, 
 				 union iwreq_data *wrqu, char *key)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_set_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -5798,7 +5798,7 @@
 				 struct iw_request_info *info, 
 				 union iwreq_data *wrqu, char *key)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	return ieee80211_wx_get_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -5806,7 +5806,7 @@
 			        struct iw_request_info *info, 
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int err;
 
 	if (wrqu->power.disabled) {
@@ -5855,7 +5855,7 @@
 			        struct iw_request_info *info, 
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (!(priv->power_mode & IPW_POWER_ENABLED)) {
 		wrqu->power.disabled = 1;
@@ -5872,7 +5872,7 @@
 				    struct iw_request_info *info, 
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int mode = *(int *)extra;
 	int err;
 	
@@ -5900,7 +5900,7 @@
 				    struct iw_request_info *info, 
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int level = IPW_POWER_LEVEL(priv->power_mode);
 	char *p = extra;
 
@@ -5932,7 +5932,7 @@
                                     struct iw_request_info *info,
                                     union iwreq_data *wrqu, char *extra)
 {
-        struct ipw_priv *priv = ieee80211_priv(dev);
+        struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int mode = *(int *)extra;
 	u8 band = 0, modulation = 0;
 
@@ -5998,7 +5998,7 @@
                                     struct iw_request_info *info,
                                     union iwreq_data *wrqu, char *extra)
 {
-        struct ipw_priv *priv = ieee80211_priv(dev);
+        struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	switch (priv->ieee->freq_band) {
 	case IEEE80211_24GHZ_BAND:
@@ -6046,7 +6046,7 @@
 			      struct iw_request_info *info, 
 			      union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	int *parms = (int *)extra;
 	int enable = (parms[0] > 0);
 
@@ -6072,7 +6072,7 @@
 			struct iw_request_info *info, 
 			union iwreq_data *wrqu, char *extra)
 { 
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	IPW_DEBUG_WX("RESET\n");
 	ipw_adapter_restart(priv);
 	return 0;
@@ -6185,7 +6185,7 @@
  */
 static struct iw_statistics *ipw_get_wireless_stats(struct net_device * dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	struct iw_statistics *wstats;
 	
 	wstats = &priv->wstats;
@@ -6248,7 +6248,7 @@
 
 static int ipw_net_open(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	IPW_DEBUG_INFO("dev->open\n");
 	/* we should be verifying the device is ready to be opened */
 	if (!(priv->status & STATUS_RF_KILL_MASK) && 
@@ -6394,9 +6394,9 @@
 }
 
 static int ipw_net_hard_start_xmit(struct ieee80211_txb *txb,
-				   struct net_device *dev)
+				   struct ieee80211_device *ieee)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(ieee);
 	unsigned long flags;
 
 	IPW_DEBUG_TX("dev->xmit(%d bytes)\n", txb->payload_size);
@@ -6406,7 +6406,7 @@
 	if (!(priv->status & STATUS_ASSOCIATED)) {
 		IPW_DEBUG_INFO("Tx attempt while not associated.\n");
 		priv->ieee->stats.tx_carrier_errors++;
-		netif_stop_queue(dev);
+		netif_stop_queue(ieee80211_dev(ieee));
 		goto fail_unlock;
 	}
 
@@ -6422,7 +6422,7 @@
 
 static struct net_device_stats *ipw_net_get_stats(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	
 	priv->ieee->stats.tx_packets = priv->tx_packets;
 	priv->ieee->stats.rx_packets = priv->rx_packets;
@@ -6436,7 +6436,7 @@
 
 static int ipw_net_set_mac_address(struct net_device *dev, void *p)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	struct sockaddr *addr = p;
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
@@ -6451,7 +6451,7 @@
 static void ipw_ethtool_get_drvinfo(struct net_device *dev, 
 				    struct ethtool_drvinfo *info)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_dev_to_priv(dev);
 	char vers[64];
 	char date[32];
 	u32 len;
@@ -6472,7 +6472,7 @@
 
 static u32 ipw_ethtool_get_link(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 	return (priv->status & STATUS_ASSOCIATED) != 0;
 }
 
@@ -6484,7 +6484,7 @@
 static int ipw_ethtool_get_eeprom(struct net_device *dev,
 				  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_dev_to_priv(dev);
 
 	if (eeprom->offset + eeprom->len > CX2_EEPROM_IMAGE_SIZE)
 		return -EINVAL;
@@ -6496,7 +6496,7 @@
 static int ipw_ethtool_set_eeprom(struct net_device *dev,
 				  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
-	struct ipw_priv *p = ieee80211_priv(dev);
+	struct ipw_priv *p = ieee80211_dev_to_priv(dev);
 	int i;
 
 	if (eeprom->offset + eeprom->len > CX2_EEPROM_IMAGE_SIZE)
@@ -6633,10 +6633,10 @@
 }
 
 
-static void shim__set_security(struct net_device *dev,
+static void shim__set_security(struct ieee80211_device *ieee,
 			       struct ieee80211_security *sec)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_priv(ieee);
 	int i;
 
 	for (i = 0; i < 4; i++) { 
@@ -6874,7 +6874,7 @@
 /* Called by register_netdev() */
 static int ipw_net_init(struct net_device *dev)
 {
-	struct ipw_priv *priv = ieee80211_priv(dev);
+	struct ipw_priv *priv = ieee80211_dev_to_priv(dev);
 
 	if (priv->status & STATUS_RF_KILL_SW) {
 		IPW_WARNING("Radio disabled by module parameter.\n");
@@ -6952,19 +6952,21 @@
 {
 	int err = 0;
 	struct net_device *net_dev;
+	struct ieee80211_device *ieee;
 	void __iomem *base;
 	u32 length, val;
 	struct ipw_priv *priv;
 	int band, modulation;
 
-	net_dev = alloc_ieee80211(sizeof(struct ipw_priv));
-	if (net_dev == NULL) {
+	ieee = alloc_ieee80211(sizeof(struct ipw_priv));
+	if (ieee == NULL) {
 		err = -ENOMEM;
 		goto out;
 	}
+	net_dev = ieee80211_dev(ieee);
 
-	priv = ieee80211_priv(net_dev);
-	priv->ieee = netdev_priv(net_dev);
+	priv = ieee80211_priv(ieee);
+	priv->ieee = ieee;
 	priv->net_dev = net_dev;
 	priv->pci_dev = pdev;
 #ifdef CONFIG_IPW_DEBUG
@@ -7160,7 +7162,7 @@
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
  out_free_ieee80211:
-	free_ieee80211(priv->net_dev);
+	free_ieee80211(priv->ieee);
  out:
 	return err;
 }
@@ -7202,7 +7204,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	free_ieee80211(priv->net_dev);
+	free_ieee80211(priv->ieee);
 
 #ifdef CONFIG_PM
 	if (fw_loaded) {


-- 
Jiri Benc
SUSE Labs
