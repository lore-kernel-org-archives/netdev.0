From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [PATCH 5/6] d80211: add IEEE 802.11e Direct Link Setup (DLS) support
Date: Thu, 14 Dec 2006 21:48:38 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B8@dhost002-46.dex002.intermedia.net>
References: <20061214040249.GA10680@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:21603 "EHLO
	dhost002-46.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750753AbWLOFs5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 00:48:57 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061214040249.GA10680@mail.intel.com>
To: <yi.zhu@intel.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Again - this DLS management frame processing code should not be in the
kernel - it should be in wpa_supplicant.

Only the frame processing code should be in the kernel.

Simon
 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Zhu Yi
Sent: Wednesday, December 13, 2006 8:03 PM
To: netdev@vger.kernel.org
Subject: [PATCH 5/6] d80211: add IEEE 802.11e Direct Link Setup (DLS)
support

Struct dls_info is declared to store the peer's MAC address, timeout
value, supported rates, etc information for the DLS link. The stack also
maintains a hash table to store the dls_info for all the DLS peers for
local interface. The peer's MAC address is used as the hash table key.
The DLS MLMEs handling functions for DLS Setup Request, DLS Response and
DLS teardown are added.

During packet TX, the stack compares the destination MAC address against
the dls_info hash table and see whether a Direct Link should be used for
the packet transmission. If so, it modifiess the IEEE 802.11 MAC header
DA, SA and BSS fields to reflect the direct link setup.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/d80211/ieee80211.c     |   19 +-
 net/d80211/ieee80211_i.h   |   17 ++
 net/d80211/ieee80211_sta.c |  450
++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 481 insertions(+), 5 deletions(-)

077c391798f72f356c0a5cb50f307b50143a5dcc
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c index
4eba18f..b25d00e 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -1472,11 +1472,18 @@ static int ieee80211_subif_start_xmit(st
                 memcpy(hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 30;
         } else if (sdata->type == IEEE80211_IF_TYPE_STA) {
-		fc |= IEEE80211_FCTL_TODS;
-		/* BSSID SA DA */
-		memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
-		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
-		memcpy(hdr.addr3, skb->data, ETH_ALEN);
+		if (dls_link_status(local, hdr.addr1) == DLS_STATUS_OK)
{
+			/* DA SA BSSID */
+			memcpy(hdr.addr1, skb->data, ETH_ALEN);
+			memcpy(hdr.addr2, skb->data + ETH_ALEN,
ETH_ALEN);
+			memcpy(hdr.addr3, sdata->u.sta.bssid, ETH_ALEN);
+		} else {
+			fc |= IEEE80211_FCTL_TODS;
+			/* BSSID SA DA */
+			memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
+			memcpy(hdr.addr2, skb->data + ETH_ALEN,
ETH_ALEN);
+			memcpy(hdr.addr3, skb->data, ETH_ALEN);
+		}
 		hdrlen = 24;
 	} else if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		/* DA SA BSSID */
@@ -4602,6 +4609,7 @@ int ieee80211_register_hw(struct ieee802
 	/* Initialize QoS Params */
 	local->dot11EDCAAveragingPeriod = 5;
 	local->MPDUExchangeTime = 0;
+	spin_lock_init(&local->dls_lock);
 
 	/* TODO: add rtnl locking around device creation and qdisc
install */
 	ieee80211_install_qdisc(local->mdev);
@@ -4702,6 +4710,7 @@ void ieee80211_unregister_hw(struct ieee
 
 	ieee80211_rx_bss_list_deinit(local->mdev);
 	ieee80211_clear_tx_pending(local);
+	dls_info_stop(local);
 	sta_info_stop(local);
 	rate_control_deinitialize(local);
 	ieee80211_dev_sysfs_del(local);
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h index
e8929d3..d09f65e 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -346,6 +346,18 @@ struct sta_ts_data {
 	u32 used_time_usec;
 };
 
+#define DLS_STATUS_OK		0
+#define DLS_STATUS_NOLINK	1
+#define DLS_STATUS_SETUP	2
+struct dls_info {
+	atomic_t refcnt;
+	int status;
+	u8 addr[ETH_ALEN];
+	struct dls_info *hnext; /* next entry in hash table list */
+	u32 timeout;
+	u32 supp_rates;
+};
+
 struct ieee80211_local {
 	/* embed the driver visible part.
 	 * don't cast (use the static inlines below), but we keep @@
-558,6 +570,9 @@ struct ieee80211_local {
 #define STA_TSDIR_NUM	2
 	/* HCCA: 0~7, EDCA: 8~15 */
 	struct sta_ts_data ts_data[STA_TSID_NUM][STA_TSDIR_NUM];
+
+	struct dls_info *dls_hash[STA_HASH_SIZE];
+	spinlock_t dls_lock;
 };
 
 enum sta_link_direction {
@@ -687,6 +702,8 @@ struct sta_info * ieee80211_ibss_add_sta
 					 u8 *addr);
 int ieee80211_sta_deauthenticate(struct net_device *dev, u16 reason);
int ieee80211_sta_disassociate(struct net_device *dev, u16 reason);
+void dls_info_stop(struct ieee80211_local *local); int 
+dls_link_status(struct ieee80211_local *local, u8 *addr);
 
 /* ieee80211_dev.c */
 int ieee80211_dev_alloc_index(struct ieee80211_local *local); diff
--git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c index
81b2ded..393a294 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -893,6 +893,174 @@ void wmm_send_delts(struct net_device *d  }
 
 
+void ieee80211_send_dls_req(struct net_device *dev, struct dls_info 
+*dls) {
+	struct ieee80211_sub_if_data *sdata =
IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u8 *pos, *supp_rates, *esupp_rates = NULL;
+	int i;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + 200 /* rates + ext_rates
Size */);
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for DLS
REQ "
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
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.dls_req));
+	mgmt->u.action.category = WLAN_CATEGORY_DLS;
+	mgmt->u.action.u.dls_req.action_code = WLAN_ACTION_DLS_REQ;
+	memcpy(mgmt->u.action.u.dls_req.dest, dls->addr, ETH_ALEN);
+	memcpy(mgmt->u.action.u.dls_req.src, dev->dev_addr, ETH_ALEN);
+	mgmt->u.action.u.dls_req.capab_info =
cpu_to_le16(ifsta->ap_capab);
+	mgmt->u.action.u.dls_req.timeout = dls->timeout;
+
+	/* Add supported rates and extended supported rates */
+	supp_rates = skb_put(skb, 2);
+	supp_rates[0] = WLAN_EID_SUPP_RATES;
+	supp_rates[1] = 0;
+	for (i = 0; i < local->num_curr_rates; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+		if (!(rate->flags & IEEE80211_RATE_SUPPORTED))
+			continue;
+		if (esupp_rates) {
+			pos = skb_put(skb, 1);
+			esupp_rates[1]++;
+		} else if (supp_rates[1] == 8) {
+			esupp_rates = skb_put(skb, 3);
+			esupp_rates[0] = WLAN_EID_EXT_SUPP_RATES;
+			esupp_rates[1] = 1;
+			pos = &esupp_rates[2];
+		} else {
+			pos = skb_put(skb, 1);
+			supp_rates[1]++;
+		}
+		if (local->hw.conf.phymode == MODE_ATHEROS_TURBO)
+			*pos = rate->rate / 10;
+		else
+			*pos = rate->rate / 5;
+	}
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
+static void ieee80211_send_dls_resp(struct net_device *dev, u8
*mac_addr,
+				    u16 status)
+{
+	struct ieee80211_sub_if_data *sdata =
IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct sk_buff *skb;
+	struct ieee80211_mgmt *mgmt;
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u8 *pos, *supp_rates, *esupp_rates = NULL;
+	int i;
+
+	skb = dev_alloc_skb(sizeof(*mgmt) + 200 /* rates + ext_rates
Size */);
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for
addts "
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
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.dls_resp));
+	mgmt->u.action.category = WLAN_CATEGORY_DLS;
+	mgmt->u.action.u.dls_resp.action_code = WLAN_ACTION_DLS_RESP;
+	memcpy(mgmt->u.action.u.dls_resp.dest, dev->dev_addr, ETH_ALEN);
+	memcpy(mgmt->u.action.u.dls_resp.src, mac_addr, ETH_ALEN);
+	mgmt->u.action.u.dls_resp.status_code = cpu_to_le16(status);
+
+	if (!mgmt->u.action.u.dls_resp.status_code) {
+		ieee80211_sta_tx(dev, skb, 0, 0);
+		return;
+	}
+
+	/* Add capability information */
+	pos = skb_put(skb, 2);
+	*(__le16 *)pos = cpu_to_le16(ifsta->ap_capab);
+
+	/* Add supported rates and extended supported rates */
+	supp_rates = skb_put(skb, 2);
+	supp_rates[0] = WLAN_EID_SUPP_RATES;
+	supp_rates[1] = 0;
+	for (i = 0; i < local->num_curr_rates; i++) {
+		struct ieee80211_rate *rate = &local->curr_rates[i];
+		if (!(rate->flags & IEEE80211_RATE_SUPPORTED))
+			continue;
+		if (esupp_rates) {
+			pos = skb_put(skb, 1);
+			esupp_rates[1]++;
+		} else if (supp_rates[1] == 8) {
+			esupp_rates = skb_put(skb, 3);
+			esupp_rates[0] = WLAN_EID_EXT_SUPP_RATES;
+			esupp_rates[1] = 1;
+			pos = &esupp_rates[2];
+		} else {
+			pos = skb_put(skb, 1);
+			supp_rates[1]++;
+		}
+		if (local->hw.conf.phymode == MODE_ATHEROS_TURBO)
+			*pos = rate->rate / 10;
+		else
+			*pos = rate->rate / 5;
+	}
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
+void ieee80211_send_dls_teardown(struct net_device *dev, u8 *mac_addr,
+				 u16 reason)
+{
+	struct ieee80211_sub_if_data *sdata =
IEEE80211_DEV_TO_SUB_IF(dev);
+	struct ieee80211_if_sta *ifsta = &sdata->u.sta;
+	struct ieee80211_mgmt *mgmt;
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(sizeof(*mgmt));
+	if (!skb) {
+		printk(KERN_DEBUG "%s: failed to allocate buffer for DLS
"
+		       "Teardown frame\n", dev->name);
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
+	skb_put(skb, 1 + sizeof(mgmt->u.action.u.dls_teardown));
+	mgmt->u.action.category = WLAN_CATEGORY_DLS;
+	mgmt->u.action.u.dls_teardown.action_code =
WLAN_ACTION_DLS_TEARDOWN;
+	memcpy(mgmt->u.action.u.dls_teardown.dest, mac_addr, ETH_ALEN);
+	memcpy(mgmt->u.action.u.dls_teardown.src, dev->dev_addr,
ETH_ALEN);
+	mgmt->u.action.u.dls_teardown.reason_code = cpu_to_le16(reason);
+
+	ieee80211_sta_tx(dev, skb, 0, 0);
+}
+
+
 static int ieee80211_privacy_mismatch(struct net_device *dev,
 				      struct ieee80211_if_sta *ifsta)  {
@@ -1532,6 +1700,266 @@ static void sta_parse_tspec(struct net_d  }
 
 
+/* must be called with local->dls_lock held */ static struct dls_info *

+__dls_info_get(struct ieee80211_local *local, u8 *addr) {
+	struct dls_info *dls;
+
+	dls = local->dls_hash[STA_HASH(addr)];
+	while (dls) {
+		if (memcmp(dls->addr, addr, ETH_ALEN) == 0) {
+			atomic_inc(&dls->refcnt);
+			break;
+		}
+		dls = dls->hnext;
+	}
+
+	return dls;
+}
+
+struct dls_info * dls_info_get(struct ieee80211_local *local, u8 *addr)

+{
+	struct dls_info *dls;
+
+	spin_lock_bh(&local->dls_lock);
+	dls = __dls_info_get(local, addr);
+	spin_unlock_bh(&local->dls_lock);
+
+	return dls;
+}
+
+static void dls_info_put(struct dls_info *dls) {
+	if ((atomic_read(&dls->refcnt) == 1) ||
+	    (atomic_dec_and_test(&dls->refcnt)))
+		kfree(dls);
+}
+
+/* must be called with local->dls_lock held */ static void 
+__dls_info_hash_del(struct ieee80211_local *local,
+				struct dls_info *dls)
+{
+	struct dls_info *d;
+
+	d = local->dls_hash[STA_HASH(dls->addr)];
+	if (!d)
+		return;
+	if (memcmp(d->addr, dls->addr, ETH_ALEN) == 0) {
+		local->dls_hash[STA_HASH(dls->addr)] = d->hnext;
+		return;
+	}
+	while (d->hnext && memcmp(d->hnext->addr, dls->addr, ETH_ALEN)
!= 0)
+		d = d->hnext;
+	if (d->hnext)
+		d->hnext = d->hnext->hnext;
+
+}
+
+static void dls_info_del(struct ieee80211_local *local, u8 *addr) {
+	struct dls_info *dls;
+
+	spin_lock_bh(&local->dls_lock);
+	dls = __dls_info_get(local, addr);
+	if (!dls)
+		goto unlock;
+
+	__dls_info_hash_del(local, dls);
+	atomic_dec(&dls->refcnt);
+	dls_info_put(dls);
+unlock:
+	spin_unlock_bh(&local->dls_lock);
+}
+
+void dls_info_add(struct ieee80211_local *local, struct dls_info *dls) 
+{
+	struct dls_info *d;
+
+	spin_lock_bh(&local->dls_lock);
+	if ((d = __dls_info_get(local, dls->addr)) != NULL) {
+		__dls_info_hash_del(local, d);
+		atomic_dec(&dls->refcnt);
+		dls_info_put(dls);
+	}
+	dls->hnext = local->dls_hash[STA_HASH(dls->addr)];
+	local->dls_hash[STA_HASH(dls->addr)] = dls;
+	spin_unlock_bh(&local->dls_lock);
+}
+
+int dls_link_status(struct ieee80211_local *local, u8 *addr) {
+	struct dls_info *d;
+	int ret = DLS_STATUS_NOLINK;
+
+	spin_lock_bh(&local->dls_lock);
+	if ((d = __dls_info_get(local, addr)) != NULL) {
+		ret = d->status;
+		dls_info_put(d);
+	}
+	spin_unlock_bh(&local->dls_lock);
+	return ret;
+}
+
+void dls_info_stop(struct ieee80211_local *local) {
+	struct dls_info *n, *d = local->dls_hash[0];
+	int i;
+
+	spin_lock_bh(&local->dls_lock);
+	for (i = 0; i < STA_HASH_SIZE; d = local->dls_hash[++i]) {
+		while (d) {
+			n = d->hnext;
+			dls_info_put(d);
+			d = n;
+		}
+	}
+	spin_unlock_bh(&local->dls_lock);
+			
+}
+
+static void sta_process_dls_req(struct net_device *dev,
+				struct ieee80211_if_sta *ifsta,
+				struct ieee80211_mgmt *mgmt, size_t len)
{
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct dls_info *dls;
+	u8 *src = mgmt->u.action.u.dls_req.src;
+	struct ieee802_11_elems elems;
+	struct ieee80211_rate *rates = local->curr_rates;
+	size_t baselen, num_rates = local->num_curr_rates;
+	int i, j, oper_mode;
+	u32 supp_rates = 0;
+
+	printk(KERN_DEBUG "Receive DLS request from "
+	       "%02X:%02X:%02X:%02X:%02X:%02X\n",
+	       src[0], src[1], src[2], src[3], src[4], src[5]);
+
+	baselen = (u8 *)mgmt->u.action.u.dls_req.variable - (u8 *)mgmt;
+	if (baselen > len)
+		return;
+
+	if (ieee802_11_parse_elems(mgmt->u.action.u.dls_req.variable,
+				   len - baselen, &elems) ==
ParseFailed) {
+		printk(KERN_ERR "DLS Parse support rates failed.\n");
+		return;
+	}
+	oper_mode = local->sta_scanning ? local->scan_oper_phymode :
+					  local->hw.conf.phymode;
+	for (i = 0; i < elems.supp_rates_len + elems.ext_supp_rates_len;
i++) {
+		u8 rate = 0;
+		if (i < elems.supp_rates_len)
+			rate = elems.supp_rates[i];
+		else if (elems.ext_supp_rates)
+			rate = elems.ext_supp_rates[i -
elems.supp_rates_len];
+		rate = 5 * (rate & 0x7f);
+		if (oper_mode == MODE_ATHEROS_TURBO)
+			rate *= 2;
+		for (j = 0; j < num_rates; j++)
+			if (rates[j].rate == rate)
+				supp_rates |= BIT(j);
+	}
+	if (supp_rates == 0) {
+		/* Send DLS failed Response to the peer because
+		 * the supported rates are mismatch */
+		ieee80211_send_dls_resp(dev, src,
WLAN_REASON_QSTA_NOT_USE);
+		return;
+	}
+
+	dls = kzalloc(sizeof(struct dls_info), GFP_ATOMIC);
+	if (!dls) {
+		printk(KERN_ERR "No memory for dls_info allocation.\n");
+		return;
+	}
+	atomic_set(&dls->refcnt, 1);
+	dls->status = DLS_STATUS_OK;
+	dls->timeout = le16_to_cpu(mgmt->u.action.u.dls_req.timeout);
+	memcpy(dls->addr, src, ETH_ALEN);
+	dls->supp_rates = supp_rates;
+	dls_info_add(local, dls);
+
+	/* Send DLS successful Response to the peer */
+	ieee80211_send_dls_resp(dev, src, 0);
+}
+
+
+static void sta_process_dls_resp(struct net_device *dev,
+				 struct ieee80211_if_sta *ifsta,
+				 struct ieee80211_mgmt *mgmt, size_t
len) {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	struct dls_info *dls;
+	u8 *src = mgmt->u.action.u.dls_resp.src;
+	struct ieee802_11_elems elems;
+	struct ieee80211_rate *rates = local->curr_rates;
+	size_t baselen, num_rates = local->num_curr_rates;
+	int i, j, oper_mode;
+	u32 supp_rates = 0;
+
+	printk(KERN_DEBUG "Receive DLS response from "
+	       "%02X:%02X:%02X:%02X:%02X:%02X\n",
+	       src[0], src[1], src[2], src[3], src[4], src[5]);
+
+	dls = dls_info_get(local, src);
+	if (!dls) {
+		printk(KERN_ERR "Cannot find dls_info for address
%02X:%02X:"
+		       "%02X:%02X:%02X:%02X. Invalid DLS response
received.\n",
+		       src[0], src[1], src[2], src[3], src[4], src[5]);
+		return;
+	}
+	if (mgmt->u.action.u.dls_resp.status_code) {
+		printk(KERN_ERR "DLS setup refused by peer. Reason
%d\n",
+		       mgmt->u.action.u.dls_resp.status_code);
+		dls_info_del(local, src);
+		return;
+	}
+
+	baselen = (u8 *)mgmt->u.action.u.dls_resp.variable - (u8 *)mgmt;
+	if (baselen > len)
+		return;
+
+	if (ieee802_11_parse_elems(mgmt->u.action.u.dls_resp.variable,
+				   len - baselen, &elems) ==
ParseFailed) {
+		printk(KERN_ERR "DLS Parse support rates failed.\n");
+		return;
+	}
+	oper_mode = local->sta_scanning ? local->scan_oper_phymode :
+					  local->hw.conf.phymode;
+	for (i = 0; i < elems.supp_rates_len + elems.ext_supp_rates_len;
i++) {
+		u8 rate = 0;
+		if (i < elems.supp_rates_len)
+			rate = elems.supp_rates[i];
+		else if (elems.ext_supp_rates)
+			rate = elems.ext_supp_rates[i -
elems.supp_rates_len];
+		rate = 5 * (rate & 0x7f);
+		if (oper_mode == MODE_ATHEROS_TURBO)
+			rate *= 2;
+		for (j = 0; j < num_rates; j++)
+			if (rates[j].rate == rate)
+				supp_rates |= BIT(j);
+	}
+	dls->supp_rates = supp_rates;
+	dls->status = DLS_STATUS_OK;
+	dls_info_put(dls);
+}
+
+
+static void sta_process_dls_teardown(struct net_device *dev,
+				     struct ieee80211_if_sta *ifsta,
+				     struct ieee80211_mgmt *mgmt, size_t
len) {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
+	u8 *src = mgmt->u.action.u.dls_teardown.src;
+
+	printk(KERN_DEBUG "DLS Teardown received from "
+	       "%02X:%02X:%02X:%02X:%02X:%02X. Reason %d\n",
+	       src[0], src[1], src[2], src[3], src[4], src[5],
+	       mgmt->u.action.u.dls_teardown.reason_code);
+
+	dls_info_del(local, src);
+	return;
+}
+
+
 static void ieee80211_rx_mgmt_action(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta,
 				     struct ieee80211_mgmt *mgmt,
@@ -1592,6 +2020,28 @@ static void ieee80211_rx_mgmt_action(str
 		}
 		break;
 	case WLAN_CATEGORY_DLS:
+		if (len < 24 + 16) {
+			printk(KERN_DEBUG "%s: too short (%zd) DLS
category "
+			       "frame received from " MAC_FMT " -
ignored\n",
+			       dev->name, len, MAC_ARG(mgmt->sa));
+			return;
+		}
+		switch (mgmt->u.action.u.dls_req.action_code) {
+		case WLAN_ACTION_DLS_REQ:
+			sta_process_dls_req(dev, ifsta, mgmt, len);
+			break;
+		case WLAN_ACTION_DLS_RESP:
+			sta_process_dls_resp(dev, ifsta, mgmt, len);
+			break;
+		case WLAN_ACTION_DLS_TEARDOWN:
+			sta_process_dls_teardown(dev, ifsta, mgmt, len);
+			break;
+		default:
+			printk(KERN_ERR "%s: unsupported DLS action code
%d\n",
+			       dev->name,
mgmt->u.action.u.dls_req.action_code);
+			break;
+		}
+		break;
 	case WLAN_CATEGORY_BACK:
 	default:
 		printk(KERN_ERR "%s: unsupported action category %d\n",
--
1.2.6
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
