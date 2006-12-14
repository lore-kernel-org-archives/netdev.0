From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 4/6] d80211: add IEEE802.11e/WMM Traffic Stream (TS) Management support
Date: Thu, 14 Dec 2006 12:02:37 +0800
Message-ID: <20061214040237.GA10670@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10343 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbWLNEOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:14:32 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The d80211 now maintains a sta_ts_data structure for every TSID and
direction combination of all the Taffic Streams. For those admission
control enabled Acesss Categories (AC), STA can initiatively request
a traffic stream. The stack also maintains two variables to record the
admitted time and used time for each TS. In every dot11EDCAAveragingPeriod,
a timer is used to track how much time (in usec) has been used (vs the
admitted time). If it finds the used time is less than the admitted time
in current dot11EDCAAveragingPeriod period, the STA will continue to
fulfil the admitted time in the next period. Otherwise the stack will
reduce the admitted time until the TS has been throttled. Finally both
the AP and STA are able to delete the TS by sending a DELTS MLME.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/d80211/ieee80211.c       |    4 
 net/d80211/ieee80211_i.h     |   49 ++++-
 net/d80211/ieee80211_iface.c |    5 +
 net/d80211/ieee80211_sta.c   |  403 ++++++++++++++++++++++++++++++++++++++++++
 net/d80211/wme.c             |   34 +++-
 5 files changed, 480 insertions(+), 15 deletions(-)

d4a326b8493fb465480a68696315c05558c03b2c
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..4eba18f 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4599,6 +4599,10 @@ int ieee80211_register_hw(struct ieee802
 		goto fail_wep;
 	}
 
+	/* Initialize QoS Params */
+	local->dot11EDCAAveragingPeriod = 5;
+	local->MPDUExchangeTime = 0;
+
 	/* TODO: add rtnl locking around device creation and qdisc install */
 	ieee80211_install_qdisc(local->mdev);
 
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..e8929d3 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -56,6 +56,10 @@ struct ieee80211_local;
  * increased memory use (about 2 kB of RAM per entry). */
 #define IEEE80211_FRAGMENT_MAX 4
 
+/* Minimum and Maximum TSID used by EDCA. HCCA uses 0~7; EDCA uses 8~15 */
+#define EDCA_TSID_MIN 8
+#define EDCA_TSID_MAX 15
+
 struct ieee80211_fragment_entry {
 	unsigned long first_frag_time;
 	unsigned int seq;
@@ -241,6 +245,7 @@ struct ieee80211_if_sta {
 		IEEE80211_IBSS_SEARCH, IEEE80211_IBSS_JOINED
 	} state;
 	struct work_struct work;
+	struct timer_list admit_timer; /* Recompute EDCA admitted time */
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
@@ -328,6 +333,19 @@ struct ieee80211_sub_if_data {
 
 #define IEEE80211_DEV_TO_SUB_IF(dev) netdev_priv(dev)
 
+struct sta_ts_data {
+	enum {
+		TS_STATUS_UNUSED	= 0,
+		TS_STATUS_ACTIVE	= 1,
+		TS_STATUS_INACTIVE	= 2,
+		TS_STATUS_THROTTLING	= 3,
+	} status;
+	u8 dialog_token;
+	u8 up;
+	u32 admitted_time_usec;
+	u32 used_time_usec;
+};
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep
@@ -449,18 +467,19 @@ struct ieee80211_local {
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	u32 wpa_trigger;
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
-        /* SNMP counters */
-        /* dot11CountersTable */
-        u32 dot11TransmittedFragmentCount;
-        u32 dot11MulticastTransmittedFrameCount;
-        u32 dot11FailedCount;
+	/* SNMP counters */
+	/* dot11CountersTable */
+	u32 dot11TransmittedFragmentCount;
+	u32 dot11MulticastTransmittedFrameCount;
+	u32 dot11FailedCount;
 	u32 dot11RetryCount;
 	u32 dot11MultipleRetryCount;
 	u32 dot11FrameDuplicateCount;
-        u32 dot11ReceivedFragmentCount;
-        u32 dot11MulticastReceivedFrameCount;
-        u32 dot11TransmittedFrameCount;
-        u32 dot11WEPUndecryptableCount;
+	u32 dot11ReceivedFragmentCount;
+	u32 dot11MulticastReceivedFrameCount;
+	u32 dot11TransmittedFrameCount;
+	u32 dot11WEPUndecryptableCount;
+	u32 dot11EDCAAveragingPeriod;
 
 #ifdef CONFIG_D80211_LEDS
 	int tx_led_counter, rx_led_counter;
@@ -533,6 +552,17 @@ struct ieee80211_local {
 				* (1 << MODE_*) */
 
 	int user_space_mlme;
+
+	u32 MPDUExchangeTime;
+#define STA_TSID_NUM	16
+#define STA_TSDIR_NUM	2
+	/* HCCA: 0~7, EDCA: 8~15 */
+	struct sta_ts_data ts_data[STA_TSID_NUM][STA_TSDIR_NUM];
+};
+
+enum sta_link_direction {
+	STA_TS_UPLINK = 0,
+	STA_TS_DOWNLINK = 1,
 };
 
 static inline struct ieee80211_local *hw_to_local(
@@ -639,6 +669,7 @@ int ieee80211_set_compression(struct iee
 int ieee80211_init_client(struct net_device *dev);
 /* ieee80211_sta.c */
 void ieee80211_sta_work(void *ptr);
+void ieee80211_admit_refresh(unsigned long ptr);
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status);
 int ieee80211_sta_set_ssid(struct net_device *dev, char *ssid, size_t len);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..e48c57d 100644
--- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -187,6 +187,10 @@ void ieee80211_if_set_type(struct net_de
 		ifsta = &sdata->u.sta;
 		INIT_WORK(&ifsta->work, ieee80211_sta_work, dev);
 
+		init_timer(&ifsta->admit_timer);
+		ifsta->admit_timer.data = (unsigned long) dev;
+		ifsta->admit_timer.function = ieee80211_admit_refresh;
+
 		ifsta->capab = WLAN_CAPABILITY_ESS;
 		ifsta->auth_algs = IEEE80211_AUTH_ALG_OPEN |
 			IEEE80211_AUTH_ALG_SHARED_KEY;
@@ -278,6 +282,7 @@ void ieee80211_if_reinit(struct net_devi
 		break;
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
+		del_timer_sync(&sdata->u.sta.admit_timer);
 		kfree(sdata->u.sta.extra_ie);
 		sdata->u.sta.extra_ie = NULL;
 		kfree(sdata->u.sta.assocreq_ies);
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index cf11e88..81b2ded 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -667,6 +667,232 @@ static void ieee80211_send_disassoc(stru
 }
 
 
+int ieee80211_ts_index(u8 direction)
+{
+	if (direction == WLAN_TSINFO_DOWNLINK ||
+	    direction == WLAN_TSINFO_DIRECTLINK)
+		return STA_TS_DOWNLINK;
+	return STA_TS_UPLINK; /* UP and Bidirectional LINK */
+}
+
+
+void ieee80211_send_addts(struct net_device *dev,
+			  struct ieee802_11_elem_tspec *tspec)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	static u8 token;
+	struct ieee802_11_elem_tspec *ptspec;
+	u8 *pos;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + sizeof(*tspec));
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for addts "
+		       "frame\n", dev->name);
+		return;
+	}
+
+	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	memset(mgmt, 0, 24);
+	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
+	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
+	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_ACTION);
+
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.addts_req));
+	mgmt->u.action.category = WLAN_CATEGORY_QOS;
+	mgmt->u.action.u.addts_req.action_code = WLAN_ACTION_QOS_ADDTS_REQ;
+	mgmt->u.action.u.addts_req.dialog_token = ++token % 127;
+
+	skb_put(skb, 2 + sizeof(*tspec));
+	pos = mgmt->u.action.u.addts_req.variable;
+	pos[0] = WLAN_EID_TSPEC;
+	pos[1] = sizeof(*tspec);
+	pos += 2;
+	ptspec = (struct ieee802_11_elem_tspec *)pos;
+	memcpy(ptspec, tspec, sizeof(*tspec));
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
+void wmm_send_addts(struct net_device *dev, struct ieee802_11_elem_tspec *tspec)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	static u8 token;
+	struct ieee802_11_elem_tspec *ptspec;
+	u8 *pos;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + 2 + 6 + sizeof(*tspec));
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for addts "
+		       "frame\n", dev->name);
+		return;
+	}
+
+	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	memset(mgmt, 0, 24);
+	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
+	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
+	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_ACTION);
+
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.wme_action));
+	mgmt->u.action.category = WLAN_CATEGORY_WMM;
+	mgmt->u.action.u.wme_action.action_code = WLAN_ACTION_QOS_ADDTS_REQ;
+	mgmt->u.action.u.wme_action.dialog_token = ++token % 127;
+	mgmt->u.action.u.wme_action.status_code = 0;
+
+	skb_put(skb, 2 + 6 + sizeof(*tspec));
+	pos = mgmt->u.action.u.wme_action.variable;
+	pos[0] = WLAN_EID_GENERIC;
+	pos[1] = 61;
+	pos += 2;
+	pos[0] = 0x00; pos[1] = 0x50; pos[2] = 0xf2; /* Wi-Fi OUI (00:50:F2)*/
+	pos += 3;
+	pos[0] = WIFI_OUI_TYPE_WMM;
+	pos[1] = WIFI_OUI_STYPE_WMM_TSPEC;
+	pos[2] = 1; /* Version */
+	pos += 3;
+	ptspec = (struct ieee802_11_elem_tspec *)pos;
+	memcpy(ptspec, tspec, sizeof(*tspec));
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
+void ieee80211_send_delts(struct net_device *dev, u8 tsid, u8 direction,
+			  u32 medium_time)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	struct ieee802_11_ts_info *ts_info;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u8 index = ieee80211_ts_index(direction);
+
+	if (local->ts_data[tsid][index].status == TS_STATUS_UNUSED) {
+		printk(KERN_DEBUG "%s: Tring to delete an ACM disabled TS "
+		       "(%u:%u)\n", dev->name, tsid, direction);
+		return;
+	}
+	skb = dev_alloc_skb(sizeof(*mgmt));
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for delts "
+		       "frame\n", dev->name);
+		return;
+	}
+
+	/* recompute admitted time */
+	local->ts_data[tsid][index].admitted_time_usec -=
+		local->dot11EDCAAveragingPeriod * medium_time * 32;
+	if ((s32)(local->ts_data[tsid][index].admitted_time_usec) < 0)
+		local->ts_data[tsid][index].admitted_time_usec = 0;
+
+	local->ts_data[tsid][index].status = TS_STATUS_INACTIVE;
+
+	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	memset(mgmt, 0, 24);
+	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
+	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
+	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_ACTION);
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.delts));
+	mgmt->u.action.category = WLAN_CATEGORY_QOS;
+	mgmt->u.action.u.delts.action_code = WLAN_ACTION_QOS_DELTS;
+	mgmt->u.action.u.delts.reason_code = 0;
+	ts_info = &mgmt->u.action.u.delts.ts_info;
+	memset(ts_info, 0, sizeof(*ts_info));
+
+	ts_info->tsid = tsid;
+	ts_info->direction = direction;
+	ts_info->access_policy = WLAN_TSINFO_EDCA;
+	ts_info->apsd = WLAN_TSINFO_PSB_LEGACY;
+	ts_info->up = local->ts_data[tsid][index].up;
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
+void wmm_send_delts(struct net_device *dev, u8 tsid, u8 direction,
+		    u32 medium_time)
+{
+	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	struct ieee802_11_elem_tspec *tspec;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u8 index = ieee80211_ts_index(direction);
+	u8 *pos;
+
+	if (local->ts_data[tsid][index].status == TS_STATUS_UNUSED) {
+		printk(KERN_DEBUG "%s: Tring to delete a non-Actived TS "
+		       "(%u %u)\n", dev->name, tsid, direction);
+		return;
+	}
+	skb = dev_alloc_skb(sizeof(*mgmt) + 2 + 6 + sizeof(*tspec));
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for delts "
+		       "frame\n", dev->name);
+		return;
+	}
+
+	/* recompute admitted time */
+	local->ts_data[tsid][index].admitted_time_usec -=
+		local->dot11EDCAAveragingPeriod * medium_time * 32;
+	if ((s32)(local->ts_data[tsid][index].admitted_time_usec < 0))
+		local->ts_data[tsid][index].admitted_time_usec = 0;
+
+	local->ts_data[tsid][index].status = TS_STATUS_INACTIVE;
+
+	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
+	memset(mgmt, 0, 24);
+	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
+	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
+	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_ACTION);
+
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.wme_action));
+	mgmt->u.action.category = WLAN_CATEGORY_WMM;
+	mgmt->u.action.u.wme_action.action_code = WLAN_ACTION_QOS_DELTS;
+	mgmt->u.action.u.wme_action.dialog_token = 0;
+	mgmt->u.action.u.wme_action.status_code = 0;
+
+	skb_put(skb, 2 + 6 + sizeof(*tspec));
+	pos = mgmt->u.action.u.wme_action.variable;
+	pos[0] = WLAN_EID_GENERIC;
+	pos[1] = 61;
+	pos += 2;
+	pos[0] = 0x00; pos[1] = 0x50; pos[2] = 0xf2; /* Wi-Fi OUI (00:50:F2)*/
+	pos += 3;
+	pos[0] = WIFI_OUI_TYPE_WMM;
+	pos[1] = WIFI_OUI_STYPE_WMM_TSPEC;
+	pos[2] = 1; /* Version */
+	pos += 3;
+	tspec = (struct ieee802_11_elem_tspec *)pos;
+	memset(tspec, 0, sizeof(*tspec));
+
+	tspec->ts_info.tsid = tsid;
+	tspec->ts_info.direction = direction;
+	tspec->ts_info.access_policy = WLAN_TSINFO_EDCA;
+	tspec->ts_info.apsd = WLAN_TSINFO_PSB_LEGACY;
+	tspec->ts_info.up = local->ts_data[tsid][index].up;
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
 static int ieee80211_privacy_mismatch(struct net_device *dev,
 				      struct ieee80211_if_sta *ifsta)
 {
@@ -1239,6 +1465,141 @@ static void ieee80211_rx_mgmt_assoc_resp
 	ieee80211_associated(dev, ifsta);
 }
 
+static u32 calculate_mpdu_exchange_time(struct ieee802_11_elem_tspec *tspec)
+{
+	/*
+	 * MPDUExchangeTime = duration(Nominal MSDU Size, Min PHY Rate) +
+	 *		      SIFS + ACK duration
+	 */
+	return 5000;
+}
+
+static void sta_update_tspec(struct ieee80211_local *local, int action,
+			     struct ieee802_11_elem_tspec *tspec)
+{
+	u8 tsid = tspec->ts_info.tsid;
+	u8 index = ieee80211_ts_index(tspec->ts_info.direction);
+	
+	switch (action) {
+	case WLAN_ACTION_QOS_ADDTS_RESP:
+		local->ts_data[tsid][index].status = TS_STATUS_ACTIVE;
+		local->ts_data[tsid][index].up = tspec->ts_info.up;
+		local->ts_data[tsid][index].used_time_usec = 0;
+		local->ts_data[tsid][index].admitted_time_usec +=
+		    local->dot11EDCAAveragingPeriod * tspec->medium_time * 32;
+		local->MPDUExchangeTime = calculate_mpdu_exchange_time(tspec);
+		break;
+	case WLAN_ACTION_QOS_DELTS:
+		local->ts_data[tsid][index].status = TS_STATUS_INACTIVE;
+		local->ts_data[tsid][index].used_time_usec = 0;
+		local->ts_data[tsid][index].admitted_time_usec -=
+		    local->dot11EDCAAveragingPeriod * tspec->medium_time * 32;
+		if (local->ts_data[tsid][index].admitted_time_usec < 0)
+			local->ts_data[tsid][index].admitted_time_usec = 0;
+		local->MPDUExchangeTime = 0;
+		break;
+	default:
+		printk(KERN_ERR "%s: invalid action type %d\n", __FUNCTION__,
+		       action);
+		break;
+	}
+}
+
+static void sta_parse_tspec(struct net_device *dev,
+			    struct ieee80211_if_sta *ifsta,
+			    struct ieee80211_mgmt *mgmt, size_t len, u8 prefix,
+			    struct ieee802_11_elem_tspec *tspec)
+{
+	struct ieee802_11_elems elems;
+	u8 *pos;
+
+	printk(KERN_DEBUG "Dialog_token: %d, TID: %u, Direction: %u, PSB: %d, "
+	       "UP: %d\n", mgmt->u.action.u.wme_action.dialog_token,
+	       tspec->ts_info.tsid, tspec->ts_info.direction,
+	       tspec->ts_info.apsd, tspec->ts_info.up);
+
+	if (mgmt->u.action.category == WLAN_CATEGORY_QOS)
+		pos = mgmt->u.action.u.addts_resp.variable + prefix;
+	else
+		pos = mgmt->u.action.u.wme_action.variable + prefix;
+
+	if (ieee802_11_parse_elems(pos, len - (pos - (u8 *) mgmt), &elems)
+	    == ParseFailed) {
+		printk(KERN_DEBUG "%s: failed to parse TSPEC\n", dev->name);
+		return;
+	}
+	memcpy(tspec, elems.tspec, sizeof(*tspec));
+}
+
+
+static void ieee80211_rx_mgmt_action(struct net_device *dev,
+				     struct ieee80211_if_sta *ifsta,
+				     struct ieee80211_mgmt *mgmt,
+				     size_t len,
+				     struct ieee80211_rx_status *rx_status)
+{
+	u8 prefix = 0;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct ieee802_11_elem_tspec tspec;
+
+	if (len < 24 + 1) {
+		printk(KERN_DEBUG "%s: too short (%zd) action frame "
+		       "received from " MAC_FMT " - ignored\n",
+		       dev->name, len, MAC_ARG(mgmt->sa));
+		return;
+	}
+
+	switch (mgmt->u.action.category) {
+	case WLAN_CATEGORY_QOS:
+	case WLAN_CATEGORY_WMM:
+		if (len < 24 + 4) {
+			printk(KERN_DEBUG "%s: too short (%zd) QoS category "
+			       "frame received from " MAC_FMT " - ignored\n",
+			       dev->name, len, MAC_ARG(mgmt->sa));
+			return;
+		}
+		switch (mgmt->u.action.u.wme_action.action_code) {
+		case WLAN_ACTION_QOS_ADDTS_REQ:
+			printk(KERN_DEBUG "%s: WLAN_ACTION_QOS_ADDTS_REQ "
+			       "received in Non-AP STA mode!\n", dev->name);
+			return;
+		case WLAN_ACTION_QOS_ADDTS_RESP:
+			if (mgmt->u.action.u.wme_action.status_code == 47) {
+				/* TODO: handle TS Delay */
+				prefix = 6;
+			}
+			/* TODO: handle TCLAS, TCLAS Porcessing here */
+
+			if (mgmt->u.action.u.wme_action.status_code == 0) {
+				/* TODO: handle Schedule */
+				sta_parse_tspec(dev, ifsta, mgmt, len,
+						prefix, &tspec);
+				sta_update_tspec(local,
+					WLAN_ACTION_QOS_ADDTS_RESP, &tspec);
+				mod_timer(&ifsta->admit_timer, jiffies +
+					  local->dot11EDCAAveragingPeriod * HZ);
+			}
+			break;
+		case WLAN_ACTION_QOS_DELTS:
+			sta_parse_tspec(dev, ifsta, mgmt, len, prefix, &tspec);
+			sta_update_tspec(local, WLAN_ACTION_QOS_DELTS, &tspec);
+			break;
+		default:
+			printk(KERN_ERR "%s: unsupported QoS action code %d\n",
+			       dev->name,
+			       mgmt->u.action.u.wme_action.action_code);
+			break;
+		}
+		break;
+	case WLAN_CATEGORY_DLS:
+	case WLAN_CATEGORY_BACK:
+	default:
+		printk(KERN_ERR "%s: unsupported action category %d\n",
+		       dev->name, mgmt->u.action.category);
+		break;
+	}
+}
+
 
 /* Caller must hold local->sta_bss_lock */
 static void __ieee80211_rx_bss_hash_add(struct net_device *dev,
@@ -1778,6 +2139,9 @@ void ieee80211_sta_rx_mgmt(struct net_de
 		ieee80211_rx_mgmt_disassoc(dev, ifsta, mgmt, skb->len,
 					   rx_status);
 		break;
+	case IEEE80211_STYPE_ACTION:
+		ieee80211_rx_mgmt_action(dev, ifsta, mgmt, skb->len, rx_status);
+		break;
 	default:
 		printk(KERN_DEBUG "%s: received unknown management frame - "
 		       "stype=%d\n", dev->name,
@@ -1923,6 +2287,45 @@ void ieee80211_sta_work(void *ptr)
 }
 
 
+void ieee80211_admit_refresh(unsigned long ptr)
+{
+	struct net_device *dev;
+	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_local *local;
+	struct ieee80211_if_sta *ifsta;
+	int i, j, find = 0;
+
+	dev = (struct net_device *) ptr;
+	local = dev->ieee80211_ptr;
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	ifsta = &sdata->u.sta;
+
+	for (i = 0; i < STA_TSID_NUM; i++) {
+		for (j = 0; j < STA_TSDIR_NUM; j++) {
+			if ((local->ts_data[i][j].status != TS_STATUS_ACTIVE) &&
+			    (local->ts_data[i][j].status != TS_STATUS_THROTTLING))
+				continue;
+			find = 1;
+
+			local->ts_data[i][j].used_time_usec -=
+				local->ts_data[i][j].admitted_time_usec;
+			if ((s32)(local->ts_data[i][j].used_time_usec) < 0)
+				local->ts_data[i][j].used_time_usec = 0;
+
+			local->ts_data[i][j].status =
+				(local->ts_data[i][j].used_time_usec >=
+			         local->ts_data[i][j].admitted_time_usec) ?
+				TS_STATUS_THROTTLING :
+				TS_STATUS_ACTIVE;
+		}
+	}
+
+	if (find)
+		mod_timer(&ifsta->admit_timer, jiffies +
+			  local->dot11EDCAAveragingPeriod * HZ);
+}
+
+
 static void ieee80211_sta_new_auth(struct net_device *dev,
 				   struct ieee80211_if_sta *ifsta)
 {
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index f26fe6c..f04d571 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -180,7 +180,7 @@ static inline int classify80211(struct s
 		(struct ieee80211_tx_packet_data *) skb->cb;
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 	unsigned short fc = le16_to_cpu(hdr->frame_control);
-	int qos;
+	int qos, tsid, dir;
 	const int ieee802_1d_to_ac[8] = { 2, 3, 3, 2, 1, 1, 0, 0 };
 
 	/* see if frame is data or non data frame */
@@ -207,14 +207,36 @@ static inline int classify80211(struct s
 	}
 
 	/* use the data classifier to determine what 802.1d tag the
-	* data frame has */
+	 * data frame has */
 	skb->priority = classify_1d(skb, qd);
+	tsid = 8 + skb->priority;
 
-	/* incase we are a client verify acm is not set for this ac */
-	while (unlikely(local->wmm_acm & BIT(skb->priority))) {
+	/* FIXME: only uplink needs to be checked for Tx */
+	dir = STA_TS_UPLINK;
+
+	if (local->wmm_acm & BIT(skb->priority)) {
+		switch (local->ts_data[tsid][dir].status) {
+		case TS_STATUS_ACTIVE:
+			/* if TS Management is enabled, update used_time */
+			local->ts_data[tsid][dir].used_time_usec +=
+				local->MPDUExchangeTime;
+			break;
+		case TS_STATUS_THROTTLING:
+			/* if admitted time is used up, refuse to send more */
+			if (net_ratelimit())
+				printk(KERN_DEBUG "QoS packet throttling\n");
+			break;
+		default:
+			break;
+		}
+	}
+
+	/* in case we are a client verify acm is not set for this ac */
+	while ((local->wmm_acm & BIT(skb->priority)) &&
+	       (local->ts_data[skb->priority + EDCA_TSID_MIN][dir].status
+			!= TS_STATUS_ACTIVE)) {
 		if (wme_downgrade_ac(skb)) {
-			/* No AC with lower priority has acm=0,
-			* drop packet. */
+			/* No AC with lower priority has acm=0, drop packet. */
 			return -1;
 		}
 	}
-- 
1.2.6
