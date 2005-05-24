From: Jiri Benc <jbenc@suse.cz>
Subject: [4/6] ipw2100: fix after "ieee80211_device alignment fix"
Date: Tue, 24 May 2005 15:18:02 +0200
Message-ID: <20050524151802.59124dde@griffin.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes ipw2100 after ieee80211_device alignment fix
(patch [2/5] ieee80211: ieee80211_device alignment fix and cleanup)


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

--- linux-2.6.12-rc2-mm3.01/drivers/net/wireless/ipw2100.c	2005-05-19 16:23:00.000000000 +0200
+++ linux-2.6.12-rc2-mm3.04/drivers/net/wireless/ipw2100.c	2005-05-19 17:35:48.000000000 +0200
@@ -1717,7 +1717,7 @@
 /* Called by register_netdev() */
 static int ipw2100_net_init(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ipw2100_up(priv, 1);
 }
 
@@ -3142,9 +3142,9 @@
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
@@ -3154,7 +3154,7 @@
 	if (!(priv->status & STATUS_ASSOCIATED)) {
 		IPW_DEBUG_INFO("Can not transmit when not connected.\n");
 		priv->ieee->stats.tx_carrier_errors++;
-		netif_stop_queue(dev);
+		netif_stop_queue(ieee80211_dev(ieee));
 		goto fail_unlock;
 	}
 
@@ -3185,7 +3185,7 @@
 	return 0;
 
  fail_unlock:
-	netif_stop_queue(dev);
+	netif_stop_queue(ieee80211_dev(ieee));
 	spin_unlock_irqrestore(&priv->low_lock, flags);
 	return 1;
 }
@@ -5087,10 +5087,10 @@
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
@@ -5270,7 +5270,7 @@
  * method as well) to talk to the firmware */
 static int ipw2100_set_address(struct net_device *dev, void *p)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct sockaddr *addr = p;
 	int err = 0;
 
@@ -5298,7 +5298,7 @@
 
 static int ipw2100_open(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	unsigned long flags;
 	IPW_DEBUG_INFO("dev->open\n");
 
@@ -5312,7 +5312,7 @@
 
 static int ipw2100_close(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	unsigned long flags;
 	struct list_head *element;
 	struct ipw2100_tx_packet *packet;
@@ -5348,7 +5348,7 @@
  */
 static void ipw2100_tx_timeout(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	priv->ieee->stats.tx_errors++;
 
@@ -5371,7 +5371,7 @@
  */
 static struct net_device_stats *ipw2100_stats(struct net_device *dev)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	return &priv->ieee->stats;
 }
@@ -5458,7 +5458,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5485,7 +5485,7 @@
 	}
 
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 	else
 		ret = -EOPNOTSUPP;
 
@@ -5495,7 +5495,7 @@
 
 static int ipw2100_wpa_set_param(struct net_device *dev, u8 name, u32 value){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int ret=0;
 
 	switch(name){
@@ -5534,7 +5534,7 @@
 
 static int ipw2100_wpa_mlme(struct net_device *dev, int command, int reason){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int ret=0;
 
 	switch(command){
@@ -5576,8 +5576,8 @@
 static int ipw2100_wpa_set_wpa_ie(struct net_device *dev,
 				struct ipw2100_param *param, int plen){
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	u8 *buf;
 
 	if (! ieee->wpa_enabled)
@@ -5616,8 +5616,8 @@
 				struct ipw2100_param *param, int param_len){
 
 	int ret = 0;
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(ieee);
 	struct ieee80211_crypto_ops *ops;
 	struct ieee80211_crypt_data **crypt;
 
@@ -5737,7 +5737,7 @@
 	}
  done:
 	if (ieee->set_security)
-		ieee->set_security(ieee->dev, &sec);
+		ieee->set_security(ieee, &sec);
 
 	/* Do not reset port if card is in Managed mode since resetting will
 	 * generate new IEEE 802.11 authentication which may end up in looping
@@ -5834,7 +5834,7 @@
 static void ipw_ethtool_get_drvinfo(struct net_device *dev,
 				    struct ethtool_drvinfo *info)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	char fw_ver[64], ucode_ver[64];
 
 	strcpy(info->driver, DRV_NAME);
@@ -5851,7 +5851,7 @@
 
 static u32 ipw2100_ethtool_get_link(struct net_device *dev)
 {
-    struct ipw2100_priv *priv = ieee80211_priv(dev);
+    struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
     return (priv->status & STATUS_ASSOCIATED) ? 1 : 0;
 }
 
@@ -5944,12 +5944,14 @@
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
 
@@ -6131,7 +6133,7 @@
 		return err;
 	}
 
-	priv = ieee80211_priv(dev);
+	priv = ieee80211_priv(netdev_priv(dev));
 
 	pci_set_master(pci_dev);
 	pci_set_drvdata(pci_dev, priv);
@@ -6270,7 +6272,7 @@
 		ipw2100_queues_free(priv);
 		sysfs_remove_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
 
-		free_ieee80211(dev);
+		free_ieee80211(netdev_priv(dev));
 		pci_set_drvdata(pci_dev, NULL);
 	}
 
@@ -6326,7 +6328,7 @@
 		if (dev->base_addr)
 			iounmap((unsigned char *)dev->base_addr);
 
-		free_ieee80211(dev);
+		free_ieee80211(netdev_priv(dev));
 	}
 
 	pci_release_regions(pci_dev);
@@ -6547,7 +6549,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	if (!(priv->status & STATUS_ASSOCIATED))
 		strcpy(wrqu->name, "unassociated");
 	else
@@ -6562,7 +6564,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_freq *fwrq = &wrqu->freq;
 	int err = 0;
 
@@ -6613,7 +6615,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->freq.e = 0;
 
@@ -6634,7 +6636,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	IPW_DEBUG_WX("SET Mode -> %d \n", wrqu->mode);
@@ -6677,7 +6679,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->mode = priv->ieee->iw_mode;
 	IPW_DEBUG_WX("GET Mode -> %d\n", wrqu->mode);
@@ -6713,7 +6715,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_range *range = (struct iw_range *)extra;
 	u16 val;
 	int i, level;
@@ -6825,7 +6827,7 @@
 			      struct iw_request_info *info,
 			      union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	static const unsigned char any[] = {
@@ -6880,7 +6882,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured BSSID then return that; otherwise return ANY */
@@ -6900,7 +6902,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	char *essid = ""; /* ANY */
 	int length = 0;
 	int err = 0;
@@ -6954,7 +6956,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	/* If we are associated, trying to associate, or have a statically
 	 * configured ESSID then return that; otherwise return ANY */
@@ -6982,7 +6984,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	if (wrqu->data.length > IW_ESSID_MAX_SIZE)
 		return -E2BIG;
@@ -7004,7 +7006,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->data.length = strlen(priv->nick) + 1;
 	memcpy(extra, priv->nick, wrqu->data.length);
@@ -7019,7 +7021,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	u32 target_rate = wrqu->bitrate.value;
 	u32 rate;
 	int err = 0;
@@ -7060,7 +7062,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int val;
 	int len = sizeof(val);
 	int err = 0;
@@ -7112,7 +7114,7 @@
 			      struct iw_request_info *info,
 			      union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int value, err;
 
 	/* Auto RTS not yet supported */
@@ -7152,7 +7154,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->rts.value = priv->rts_threshold & ~RTS_DISABLED;
 	wrqu->rts.fixed = 1; /* no auto select */
@@ -7169,7 +7171,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0, value;
 
 	if (priv->ieee->iw_mode != IW_MODE_ADHOC)
@@ -7209,7 +7211,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	if (priv->ieee->iw_mode != IW_MODE_ADHOC) {
 		wrqu->power.disabled = 1;
@@ -7245,7 +7247,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	if (!wrqu->frag.fixed)
 		return -EINVAL;
@@ -7275,7 +7277,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	wrqu->frag.value = priv->frag_threshold & ~FRAG_DISABLED;
 	wrqu->frag.fixed = 0;	/* no auto select */
 	wrqu->frag.disabled = (priv->frag_threshold & FRAG_DISABLED) ? 1 : 0;
@@ -7289,7 +7291,7 @@
 				struct iw_request_info *info,
 				union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	if (wrqu->retry.flags & IW_RETRY_LIFETIME ||
@@ -7338,7 +7340,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	wrqu->retry.disabled = 0; /* can't be disabled */
 
@@ -7367,7 +7369,7 @@
 			       struct iw_request_info *info,
 			       union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	down(&priv->action_sem);
@@ -7398,7 +7400,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_get_scan(priv->ieee, info, wrqu, extra);
 }
 
@@ -7414,7 +7416,7 @@
 	 * No check of STATUS_INITIALIZED required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_set_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7426,7 +7428,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	return ieee80211_wx_get_encode(priv->ieee, info, wrqu, key);
 }
 
@@ -7434,7 +7436,7 @@
 			        struct iw_request_info *info,
 			        union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0;
 
 	down(&priv->action_sem);
@@ -7484,7 +7486,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	if (!(priv->power_mode & IPW_POWER_ENABLED)) {
 		wrqu->power.disabled = 1;
@@ -7509,7 +7511,7 @@
 				  struct iw_request_info *info,
 				  union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int *parms = (int *)extra;
 	int enable = (parms[0] > 0);
 	int err = 0;
@@ -7540,7 +7542,7 @@
 			    struct iw_request_info *info,
 			    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	if (priv->status & STATUS_INITIALIZED)
 		schedule_reset(priv);
 	return 0;
@@ -7552,7 +7554,7 @@
 				    struct iw_request_info *info,
 				    union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err = 0, mode = *(int *)extra;
 
 	down(&priv->action_sem);
@@ -7580,7 +7582,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int level = IPW_POWER_LEVEL(priv->power_mode);
 	s32 timeout, period;
 
@@ -7617,7 +7619,7 @@
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	int err, mode = *(int *)extra;
 
 	down(&priv->action_sem);
@@ -7650,7 +7652,7 @@
 	 * This can be called at any time.  No action lock required
 	 */
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 
 	if (priv->config & CFG_LONG_PREAMBLE)
 		snprintf(wrqu->name, IFNAMSIZ, "long (1)");
@@ -7792,7 +7794,7 @@
 	int tx_qual;
 	int beacon_qual;
 
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ipw2100_priv *priv = ieee80211_priv(netdev_priv(dev));
 	struct iw_statistics *wstats;
 	u32 rssi, quality, tx_retries, missed_beacons, tx_failures;
 	u32 ord_len = sizeof(u32);


--
Jiri Benc
SUSE Labs
