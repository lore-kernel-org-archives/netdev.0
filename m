From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-davem' branch of wireless-2.6
Date: Tue, 16 Oct 2007 22:31:46 -0400
Message-ID: <20071017023145.GA2848@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4870 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760820AbXJQDIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 23:08:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

A few fixes for 2.6.24.  I've included some SSB ones since I wasn't
sure who else should get them.

Thanks,

John

---

As usual, individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-davem

---

The following changes since commit 65a6ec0d72a07f16719e9b7a96e1c4bae044b591:
  Linus Torvalds (1):
        Merge branch 'devel' of master.kernel.org:/home/rmk/linux-2.6-arm

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-davem

Bill Moss (1):
      mac80211: honor IW_SCAN_THIS_ESSID in siwscan ioctl

Felix Fietkau (1):
      ssb: Fix a null pointer check in mipscore init

Ingo Molnar (1):
      ssb: fix build failure

Johannes Berg (3):
      ieee80211: fix TKIP QoS bug
      mac80211: fix set_channel regression
      mac80211: reorder association debug output

John W. Linville (2):
      mac80211: store channel info in sta_bss_list
      mac80211: store SSID in sta_bss_list

 drivers/ssb/Kconfig                  |    4 +-
 drivers/ssb/driver_mipscore.c        |    3 +-
 net/ieee80211/ieee80211_crypt_tkip.c |    2 +-
 net/mac80211/ieee80211_ioctl.c       |   45 +++++++++++++--------
 net/mac80211/ieee80211_sta.c         |   71 +++++++++++++++++++++-------------
 5 files changed, 77 insertions(+), 48 deletions(-)

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index b4a5e5e..d976660 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -22,7 +22,7 @@ config SSB
 
 config SSB_PCIHOST_POSSIBLE
 	bool
-	depends on SSB && PCI
+	depends on SSB && (PCI = y || PCI = SSB)
 	default y
 
 config SSB_PCIHOST
@@ -37,7 +37,7 @@ config SSB_PCIHOST
 
 config SSB_PCMCIAHOST_POSSIBLE
 	bool
-	depends on SSB && PCMCIA && EXPERIMENTAL
+	depends on SSB && (PCMCIA = y || PCMCIA = SSB) && EXPERIMENTAL
 	default y
 
 config SSB_PCMCIAHOST
diff --git a/drivers/ssb/driver_mipscore.c b/drivers/ssb/driver_mipscore.c
index ab8691a..3d3dd32 100644
--- a/drivers/ssb/driver_mipscore.c
+++ b/drivers/ssb/driver_mipscore.c
@@ -173,7 +173,7 @@ u32 ssb_cpu_clock(struct ssb_mipscore *mcore)
 
 void ssb_mipscore_init(struct ssb_mipscore *mcore)
 {
-	struct ssb_bus *bus = mcore->dev->bus;
+	struct ssb_bus *bus;
 	struct ssb_device *dev;
 	unsigned long hz, ns;
 	unsigned int irq, i;
@@ -183,6 +183,7 @@ void ssb_mipscore_init(struct ssb_mipscore *mcore)
 
 	ssb_dprintk(KERN_INFO PFX "Initializing MIPS core...\n");
 
+	bus = mcore->dev->bus;
 	hz = ssb_clockspeed(bus);
 	if (!hz)
 		hz = 100000000;
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 6cc54ee..72e6ab6 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -586,7 +586,7 @@ static void michael_mic_hdr(struct sk_buff *skb, u8 * hdr)
 	if (stype & IEEE80211_STYPE_QOS_DATA) {
 		const struct ieee80211_hdr_3addrqos *qoshdr =
 			(struct ieee80211_hdr_3addrqos *)skb->data;
-		hdr[12] = qoshdr->qos_ctl & cpu_to_le16(IEEE80211_QCTL_TID);
+		hdr[12] = le16_to_cpu(qoshdr->qos_ctl) & IEEE80211_QCTL_TID;
 	} else
 		hdr[12] = 0;		/* priority */
 
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index f0224c2..a57fed7 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -306,9 +306,12 @@ int ieee80211_set_channel(struct ieee80211_local *local, int channel, int freq)
 			    ((chan->chan == channel) || (chan->freq == freq))) {
 				local->oper_channel = chan;
 				local->oper_hw_mode = mode;
-				set++;
+				set = 1;
+				break;
 			}
 		}
+		if (set)
+			break;
 	}
 
 	if (set) {
@@ -508,32 +511,40 @@ static int ieee80211_ioctl_giwap(struct net_device *dev,
 
 static int ieee80211_ioctl_siwscan(struct net_device *dev,
 				   struct iw_request_info *info,
-				   struct iw_point *data, char *extra)
+				   union iwreq_data *wrqu, char *extra)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct iw_scan_req *req = NULL;
 	u8 *ssid = NULL;
 	size_t ssid_len = 0;
 
 	if (!netif_running(dev))
 		return -ENETDOWN;
 
-	switch (sdata->type) {
-	case IEEE80211_IF_TYPE_STA:
-	case IEEE80211_IF_TYPE_IBSS:
-		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-			ssid = sdata->u.sta.ssid;
-			ssid_len = sdata->u.sta.ssid_len;
-		}
-		break;
-	case IEEE80211_IF_TYPE_AP:
-		if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
-			ssid = sdata->u.ap.ssid;
-			ssid_len = sdata->u.ap.ssid_len;
+	if (wrqu->data.length == sizeof(struct iw_scan_req) &&
+	    wrqu->data.flags & IW_SCAN_THIS_ESSID) {
+		req = (struct iw_scan_req *)extra;
+		ssid = req->essid;
+		ssid_len = req->essid_len;
+	} else {
+		switch (sdata->type) {
+		case IEEE80211_IF_TYPE_STA:
+		case IEEE80211_IF_TYPE_IBSS:
+			if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
+				ssid = sdata->u.sta.ssid;
+				ssid_len = sdata->u.sta.ssid_len;
+			}
+			break;
+		case IEEE80211_IF_TYPE_AP:
+			if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID) {
+				ssid = sdata->u.ap.ssid;
+				ssid_len = sdata->u.ap.ssid_len;
+			}
+			break;
+		default:
+			return -EOPNOTSUPP;
 		}
-		break;
-	default:
-		return -EOPNOTSUPP;
 	}
 
 	return ieee80211_sta_req_scan(dev, ssid, ssid_len);
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 1641e8f..db81aef 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -12,7 +12,6 @@
  */
 
 /* TODO:
- * BSS table: use <BSSID,SSID> as the key to support multi-SSID APs
  * order BSS list by RSSI(?) ("quality of AP")
  * scan result table filtering (by capability (privacy, IBSS/BSS, WPA/RSN IE,
  *    SSID)
@@ -61,7 +60,8 @@
 static void ieee80211_send_probe_req(struct net_device *dev, u8 *dst,
 				     u8 *ssid, size_t ssid_len);
 static struct ieee80211_sta_bss *
-ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid);
+ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid, int channel,
+		     u8 *ssid, u8 ssid_len);
 static void ieee80211_rx_bss_put(struct net_device *dev,
 				 struct ieee80211_sta_bss *bss);
 static int ieee80211_sta_find_ibss(struct net_device *dev,
@@ -427,7 +427,9 @@ static void ieee80211_set_associated(struct net_device *dev,
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return;
 
-		bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
+		bss = ieee80211_rx_bss_get(dev, ifsta->bssid,
+					   local->hw.conf.channel,
+					   ifsta->ssid, ifsta->ssid_len);
 		if (bss) {
 			if (bss->has_erp_value)
 				ieee80211_handle_erp_ie(dev, bss->erp_value);
@@ -574,7 +576,8 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		capab |= WLAN_CAPABILITY_SHORT_SLOT_TIME |
 			WLAN_CAPABILITY_SHORT_PREAMBLE;
 	}
-	bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
+	bss = ieee80211_rx_bss_get(dev, ifsta->bssid, local->hw.conf.channel,
+				   ifsta->ssid, ifsta->ssid_len);
 	if (bss) {
 		if (bss->capability & WLAN_CAPABILITY_PRIVACY)
 			capab |= WLAN_CAPABILITY_PRIVACY;
@@ -722,6 +725,7 @@ static void ieee80211_send_disassoc(struct net_device *dev,
 static int ieee80211_privacy_mismatch(struct net_device *dev,
 				      struct ieee80211_if_sta *ifsta)
 {
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
 	int res = 0;
 
@@ -729,7 +733,8 @@ static int ieee80211_privacy_mismatch(struct net_device *dev,
 	    ifsta->key_management_enabled)
 		return 0;
 
-	bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
+	bss = ieee80211_rx_bss_get(dev, ifsta->bssid, local->hw.conf.channel,
+				   ifsta->ssid, ifsta->ssid_len);
 	if (!bss)
 		return 0;
 
@@ -1203,15 +1208,11 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	capab_info = le16_to_cpu(mgmt->u.assoc_resp.capab_info);
 	status_code = le16_to_cpu(mgmt->u.assoc_resp.status_code);
 	aid = le16_to_cpu(mgmt->u.assoc_resp.aid);
-	if ((aid & (BIT(15) | BIT(14))) != (BIT(15) | BIT(14)))
-		printk(KERN_DEBUG "%s: invalid aid value %d; bits 15:14 not "
-		       "set\n", dev->name, aid);
-	aid &= ~(BIT(15) | BIT(14));
 
 	printk(KERN_DEBUG "%s: RX %sssocResp from %s (capab=0x%x "
 	       "status=%d aid=%d)\n",
 	       dev->name, reassoc ? "Rea" : "A", print_mac(mac, mgmt->sa),
-	       capab_info, status_code, aid);
+	       capab_info, status_code, aid & ~(BIT(15) | BIT(14)));
 
 	if (status_code != WLAN_STATUS_SUCCESS) {
 		printk(KERN_DEBUG "%s: AP denied association (code=%d)\n",
@@ -1223,6 +1224,11 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 		return;
 	}
 
+	if ((aid & (BIT(15) | BIT(14))) != (BIT(15) | BIT(14)))
+		printk(KERN_DEBUG "%s: invalid aid value %d; bits 15:14 not "
+		       "set\n", dev->name, aid);
+	aid &= ~(BIT(15) | BIT(14));
+
 	pos = mgmt->u.assoc_resp.variable;
 	if (ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems)
 	    == ParseFailed) {
@@ -1241,7 +1247,9 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	 * update our stored copy */
 	if (elems.erp_info && elems.erp_info_len >= 1) {
 		struct ieee80211_sta_bss *bss
-			= ieee80211_rx_bss_get(dev, ifsta->bssid);
+			= ieee80211_rx_bss_get(dev, ifsta->bssid,
+					       local->hw.conf.channel,
+					       ifsta->ssid, ifsta->ssid_len);
 		if (bss) {
 			bss->erp_value = elems.erp_info[0];
 			bss->has_erp_value = 1;
@@ -1271,7 +1279,9 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 			       " AP\n", dev->name);
 			return;
 		}
-		bss = ieee80211_rx_bss_get(dev, ifsta->bssid);
+		bss = ieee80211_rx_bss_get(dev, ifsta->bssid,
+					   local->hw.conf.channel,
+					   ifsta->ssid, ifsta->ssid_len);
 		if (bss) {
 			sta->last_rssi = bss->rssi;
 			sta->last_signal = bss->signal;
@@ -1347,7 +1357,8 @@ static void __ieee80211_rx_bss_hash_del(struct net_device *dev,
 
 
 static struct ieee80211_sta_bss *
-ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid)
+ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid, int channel,
+		     u8 *ssid, u8 ssid_len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
@@ -1358,6 +1369,11 @@ ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid)
 	atomic_inc(&bss->users);
 	atomic_inc(&bss->users);
 	memcpy(bss->bssid, bssid, ETH_ALEN);
+	bss->channel = channel;
+	if (ssid && ssid_len <= IEEE80211_MAX_SSID_LEN) {
+		memcpy(bss->ssid, ssid, ssid_len);
+		bss->ssid_len = ssid_len;
+	}
 
 	spin_lock_bh(&local->sta_bss_lock);
 	/* TODO: order by RSSI? */
@@ -1369,7 +1385,8 @@ ieee80211_rx_bss_add(struct net_device *dev, u8 *bssid)
 
 
 static struct ieee80211_sta_bss *
-ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid)
+ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid, int channel,
+		     u8 *ssid, u8 ssid_len)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
@@ -1377,7 +1394,10 @@ ieee80211_rx_bss_get(struct net_device *dev, u8 *bssid)
 	spin_lock_bh(&local->sta_bss_lock);
 	bss = local->sta_bss_hash[STA_HASH(bssid)];
 	while (bss) {
-		if (memcmp(bss->bssid, bssid, ETH_ALEN) == 0) {
+		if (!memcmp(bss->bssid, bssid, ETH_ALEN) &&
+		    bss->channel == channel &&
+		    bss->ssid_len == ssid_len &&
+		    (ssid_len == 0 || !memcmp(bss->ssid, ssid, ssid_len))) {
 			atomic_inc(&bss->users);
 			break;
 		}
@@ -1545,9 +1565,11 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 	else
 		channel = rx_status->channel;
 
-	bss = ieee80211_rx_bss_get(dev, mgmt->bssid);
+	bss = ieee80211_rx_bss_get(dev, mgmt->bssid, channel,
+				   elems.ssid, elems.ssid_len);
 	if (!bss) {
-		bss = ieee80211_rx_bss_add(dev, mgmt->bssid);
+		bss = ieee80211_rx_bss_add(dev, mgmt->bssid, channel,
+					   elems.ssid, elems.ssid_len);
 		if (!bss)
 			return;
 	} else {
@@ -1573,10 +1595,6 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 
 	bss->beacon_int = le16_to_cpu(mgmt->u.beacon.beacon_int);
 	bss->capability = le16_to_cpu(mgmt->u.beacon.capab_info);
-	if (elems.ssid && elems.ssid_len <= IEEE80211_MAX_SSID_LEN) {
-		memcpy(bss->ssid, elems.ssid, elems.ssid_len);
-		bss->ssid_len = elems.ssid_len;
-	}
 
 	bss->supp_rates_len = 0;
 	if (elems.supp_rates) {
@@ -1647,7 +1665,6 @@ static void ieee80211_rx_bss_info(struct net_device *dev,
 
 
 	bss->hw_mode = rx_status->phymode;
-	bss->channel = channel;
 	bss->freq = rx_status->freq;
 	if (channel != rx_status->channel &&
 	    (bss->hw_mode == MODE_IEEE80211G ||
@@ -2375,7 +2392,7 @@ static int ieee80211_sta_create_ibss(struct net_device *dev,
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sta_bss *bss;
-	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct ieee80211_hw_mode *mode;
 	u8 bssid[ETH_ALEN], *pos;
 	int i;
@@ -2398,18 +2415,17 @@ static int ieee80211_sta_create_ibss(struct net_device *dev,
 	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID %s\n",
 	       dev->name, print_mac(mac, bssid));
 
-	bss = ieee80211_rx_bss_add(dev, bssid);
+	bss = ieee80211_rx_bss_add(dev, bssid, local->hw.conf.channel,
+				   sdata->u.sta.ssid, sdata->u.sta.ssid_len);
 	if (!bss)
 		return -ENOMEM;
 
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	mode = local->oper_hw_mode;
 
 	if (local->hw.conf.beacon_int == 0)
 		local->hw.conf.beacon_int = 100;
 	bss->beacon_int = local->hw.conf.beacon_int;
 	bss->hw_mode = local->hw.conf.phymode;
-	bss->channel = local->hw.conf.channel;
 	bss->freq = local->hw.conf.freq;
 	bss->last_update = jiffies;
 	bss->capability = WLAN_CAPABILITY_IBSS;
@@ -2469,7 +2485,8 @@ static int ieee80211_sta_find_ibss(struct net_device *dev,
 	       "%s\n", print_mac(mac, bssid), print_mac(mac2, ifsta->bssid));
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0 &&
-	    (bss = ieee80211_rx_bss_get(dev, bssid))) {
+	    (bss = ieee80211_rx_bss_get(dev, bssid, local->hw.conf.channel,
+					ifsta->ssid, ifsta->ssid_len))) {
 		printk(KERN_DEBUG "%s: Selected IBSS BSSID %s"
 		       " based on configured SSID\n",
 		       dev->name, print_mac(mac, bssid));
-- 
John W. Linville
linville@tuxdriver.com
