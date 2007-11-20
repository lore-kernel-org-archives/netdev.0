From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-davem' branch of wireless-2.6
Date: Tue, 20 Nov 2007 17:11:35 -0500
Message-ID: <20071120221135.GI16090@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3009 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbXKTWMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:12:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some more updates for net-2.6.25 -- nothing too major.

Let me know if there are problems!

Thanks,

John

---

Individual patches available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-davem

---

The following changes since commit 11fc81a8722144256613e04846f35fa474ff0f3b:
  Pavel Emelyanov (1):
        [NET]: Compact sk_stream_mem_schedule() code

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-davem

Helmut Schaa (1):
      mac80211: Remove local->scan_flags

Johannes Berg (2):
      mac80211: provide interface iterator for drivers
      mac80211: remove more forgotten code

Ron Rindjunsky (1):
      mac80211: adding 802.11n definitions in ieee80211.h

 include/linux/ieee80211.h      |  134 ++++++++++++++++++++++++++++++++++++++++
 include/net/mac80211.h         |   16 +++++
 net/mac80211/ieee80211_i.h     |    4 -
 net/mac80211/ieee80211_ioctl.c |   19 +-----
 net/mac80211/ieee80211_sta.c   |   12 ----
 net/mac80211/tx.c              |   58 -----------------
 net/mac80211/util.c            |   33 ++++++++++
 7 files changed, 186 insertions(+), 90 deletions(-)

diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
index 214821a..3e64159 100644
--- a/include/linux/ieee80211.h
+++ b/include/linux/ieee80211.h
@@ -54,6 +54,8 @@
 #define IEEE80211_STYPE_ACTION		0x00D0
 
 /* control */
+#define IEEE80211_STYPE_BACK_REQ	0x0080
+#define IEEE80211_STYPE_BACK		0x0090
 #define IEEE80211_STYPE_PSPOLL		0x00A0
 #define IEEE80211_STYPE_RTS		0x00B0
 #define IEEE80211_STYPE_CTS		0x00C0
@@ -185,6 +187,25 @@ struct ieee80211_mgmt {
 					u8 new_chan;
 					u8 switch_count;
 				} __attribute__((packed)) chan_switch;
+				struct{
+					u8 action_code;
+					u8 dialog_token;
+					__le16 capab;
+					__le16 timeout;
+					__le16 start_seq_num;
+				} __attribute__((packed)) addba_req;
+				struct{
+					u8 action_code;
+					u8 dialog_token;
+					__le16 status;
+					__le16 capab;
+					__le16 timeout;
+				} __attribute__((packed)) addba_resp;
+				struct{
+					u8 action_code;
+					__le16 params;
+					__le16 reason_code;
+				} __attribute__((packed)) delba;
 			} u;
 		} __attribute__ ((packed)) action;
 	} u;
@@ -205,6 +226,66 @@ struct ieee80211_cts {
 	u8 ra[6];
 } __attribute__ ((packed));
 
+/**
+ * struct ieee80211_bar - HT Block Ack Request
+ *
+ * This structure refers to "HT BlockAckReq" as
+ * described in 802.11n draft section 7.2.1.7.1
+ */
+struct ieee80211_bar {
+	__le16 frame_control;
+	__le16 duration;
+	__u8 ra[6];
+	__u8 ta[6];
+	__u16 control;
+	__u16 start_seq_num;
+} __attribute__((packed));
+
+/**
+ * struct ieee80211_ht_cap - HT capabilities
+ *
+ * This structure refers to "HT capabilities element" as
+ * described in 802.11n draft section 7.3.2.52
+ */
+struct ieee80211_ht_cap {
+	__le16 cap_info;
+	u8 ampdu_params_info;
+	u8 supp_mcs_set[16];
+	__le16 extended_ht_cap_info;
+	__le32 tx_BF_cap_info;
+	u8 antenna_selection_info;
+} __attribute__ ((packed));
+
+/**
+ * struct ieee80211_ht_cap - HT additional information
+ *
+ * This structure refers to "HT information element" as
+ * described in 802.11n draft section 7.3.2.53
+ */
+struct ieee80211_ht_addt_info {
+	u8 control_chan;
+	u8 ht_param;
+	__le16 operation_mode;
+	__le16 stbc_param;
+	u8 basic_set[16];
+} __attribute__ ((packed));
+
+/* 802.11n HT capabilities masks */
+#define IEEE80211_HT_CAP_SUP_WIDTH		0x0002
+#define IEEE80211_HT_CAP_MIMO_PS		0x000C
+#define IEEE80211_HT_CAP_GRN_FLD		0x0010
+#define IEEE80211_HT_CAP_SGI_20			0x0020
+#define IEEE80211_HT_CAP_SGI_40			0x0040
+#define IEEE80211_HT_CAP_DELAY_BA		0x0400
+#define IEEE80211_HT_CAP_MAX_AMSDU		0x0800
+#define IEEE80211_HT_CAP_AMPDU_FACTOR		0x03
+#define IEEE80211_HT_CAP_AMPDU_DENSITY		0x1C
+/* 802.11n HT IE masks */
+#define IEEE80211_HT_IE_CHA_SEC_OFFSET		0x03
+#define IEEE80211_HT_IE_CHA_WIDTH		0x04
+#define IEEE80211_HT_IE_HT_PROTECTION		0x0003
+#define IEEE80211_HT_IE_NON_GF_STA_PRSNT	0x0004
+#define IEEE80211_HT_IE_NON_HT_STA_PRSNT	0x0010
 
 /* Authentication algorithms */
 #define WLAN_AUTH_OPEN 0
@@ -271,6 +352,18 @@ enum ieee80211_statuscode {
 	WLAN_STATUS_UNSUPP_RSN_VERSION = 44,
 	WLAN_STATUS_INVALID_RSN_IE_CAP = 45,
 	WLAN_STATUS_CIPHER_SUITE_REJECTED = 46,
+	/* 802.11e */
+	WLAN_STATUS_UNSPECIFIED_QOS = 32,
+	WLAN_STATUS_ASSOC_DENIED_NOBANDWIDTH = 33,
+	WLAN_STATUS_ASSOC_DENIED_LOWACK = 34,
+	WLAN_STATUS_ASSOC_DENIED_UNSUPP_QOS = 35,
+	WLAN_STATUS_REQUEST_DECLINED = 37,
+	WLAN_STATUS_INVALID_QOS_PARAM = 38,
+	WLAN_STATUS_CHANGE_TSPEC = 39,
+	WLAN_STATUS_WAIT_TS_DELAY = 47,
+	WLAN_STATUS_NO_DIRECT_LINK = 48,
+	WLAN_STATUS_STA_NOT_PRESENT = 49,
+	WLAN_STATUS_STA_NOT_QSTA = 50,
 };
 
 
@@ -301,6 +394,16 @@ enum ieee80211_reasoncode {
 	WLAN_REASON_INVALID_RSN_IE_CAP = 22,
 	WLAN_REASON_IEEE8021X_FAILED = 23,
 	WLAN_REASON_CIPHER_SUITE_REJECTED = 24,
+	/* 802.11e */
+	WLAN_REASON_DISASSOC_UNSPECIFIED_QOS = 32,
+	WLAN_REASON_DISASSOC_QAP_NO_BANDWIDTH = 33,
+	WLAN_REASON_DISASSOC_LOW_ACK = 34,
+	WLAN_REASON_DISASSOC_QAP_EXCEED_TXOP = 35,
+	WLAN_REASON_QSTA_LEAVE_QBSS = 36,
+	WLAN_REASON_QSTA_NOT_USE = 37,
+	WLAN_REASON_QSTA_REQUIRE_SETUP = 38,
+	WLAN_REASON_QSTA_TIMEOUT = 39,
+	WLAN_REASON_QSTA_CIPHER_NOT_SUPP = 45,
 };
 
 
@@ -319,6 +422,15 @@ enum ieee80211_eid {
 	WLAN_EID_HP_PARAMS = 8,
 	WLAN_EID_HP_TABLE = 9,
 	WLAN_EID_REQUEST = 10,
+	/* 802.11e */
+	WLAN_EID_QBSS_LOAD = 11,
+	WLAN_EID_EDCA_PARAM_SET = 12,
+	WLAN_EID_TSPEC = 13,
+	WLAN_EID_TCLAS = 14,
+	WLAN_EID_SCHEDULE = 15,
+	WLAN_EID_TS_DELAY = 43,
+	WLAN_EID_TCLAS_PROCESSING = 44,
+	WLAN_EID_QOS_CAPA = 46,
 	/* 802.11h */
 	WLAN_EID_PWR_CONSTRAINT = 32,
 	WLAN_EID_PWR_CAPABILITY = 33,
@@ -333,6 +445,9 @@ enum ieee80211_eid {
 	/* 802.11g */
 	WLAN_EID_ERP_INFO = 42,
 	WLAN_EID_EXT_SUPP_RATES = 50,
+	/* 802.11n */
+	WLAN_EID_HT_CAPABILITY = 45,
+	WLAN_EID_HT_EXTRA_INFO = 61,
 	/* 802.11i */
 	WLAN_EID_RSN = 48,
 	WLAN_EID_WPA = 221,
@@ -341,6 +456,25 @@ enum ieee80211_eid {
 	WLAN_EID_QOS_PARAMETER = 222
 };
 
+/* Action category code */
+enum ieee80211_category {
+	WLAN_CATEGORY_SPECTRUM_MGMT = 0,
+	WLAN_CATEGORY_QOS = 1,
+	WLAN_CATEGORY_DLS = 2,
+	WLAN_CATEGORY_BACK = 3,
+	WLAN_CATEGORY_WMM = 17,
+};
+
+/* BACK action code */
+enum ieee80211_back_actioncode {
+	WLAN_ACTION_ADDBA_REQ = 0,
+	WLAN_ACTION_ADDBA_RESP = 1,
+	WLAN_ACTION_DELBA = 2,
+};
+
+/* A-MSDU 802.11n */
+#define IEEE80211_QOS_CONTROL_A_MSDU_PRESENT 0x0080
+
 /* cipher suite selectors */
 #define WLAN_CIPHER_SUITE_USE_GROUP	0x000FAC00
 #define WLAN_CIPHER_SUITE_WEP40		0x000FAC01
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 17b6039..1470e1b 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1406,4 +1406,20 @@ void ieee80211_wake_queues(struct ieee80211_hw *hw);
  */
 void ieee80211_scan_completed(struct ieee80211_hw *hw);
 
+/**
+ * ieee80211_iterate_active_interfaces - iterate active interfaces
+ *
+ * This function iterates over the interfaces associated with a given
+ * hardware that are currently active and calls the callback for them.
+ * Must be called under RTNL.
+ *
+ * @hw: the hardware struct of which the interfaces should be iterated over
+ * @iterator: the iterator function to call
+ * @data: first argument of the iterator function
+ */
+void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
+					 void (*iterator)(void *data, u8 *mac,
+							  int if_id),
+					 void *data);
+
 #endif /* MAC80211_H */
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 72e1c93..2be7fce 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -483,10 +483,6 @@ struct ieee80211_local {
 	struct list_head sta_bss_list;
 	struct ieee80211_sta_bss *sta_bss_hash[STA_HASH_SIZE];
 	spinlock_t sta_bss_lock;
-#define IEEE80211_SCAN_MATCH_SSID BIT(0)
-#define IEEE80211_SCAN_WPA_ONLY BIT(1)
-#define IEEE80211_SCAN_EXTRA_INFO BIT(2)
-	int scan_flags;
 
 	/* SNMP counters */
 	/* dot11CountersTable */
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 942b9cc..503b64a 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -513,7 +513,6 @@ static int ieee80211_ioctl_siwscan(struct net_device *dev,
 				   struct iw_request_info *info,
 				   union iwreq_data *wrqu, char *extra)
 {
-	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	struct iw_scan_req *req = NULL;
 	u8 *ssid = NULL;
@@ -522,21 +521,9 @@ static int ieee80211_ioctl_siwscan(struct net_device *dev,
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
-		}
-		break;
-	default:
+	if (sdata->type != IEEE80211_IF_TYPE_STA &&
+	    sdata->type != IEEE80211_IF_TYPE_IBSS &&
+	    sdata->type != IEEE80211_IF_TYPE_AP) {
 		return -EOPNOTSUPP;
 	}
 
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 015b3f8..2a321f0 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2898,15 +2898,6 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	if (!(local->enabled_modes & (1 << bss->hw_mode)))
 		return current_ev;
 
-	if (local->scan_flags & IEEE80211_SCAN_WPA_ONLY &&
-	    !bss->wpa_ie && !bss->rsn_ie)
-		return current_ev;
-
-	if (local->scan_flags & IEEE80211_SCAN_MATCH_SSID &&
-	    (local->scan_ssid_len != bss->ssid_len ||
-	     memcmp(local->scan_ssid, bss->ssid, bss->ssid_len) != 0))
-		return current_ev;
-
 	memset(&iwe, 0, sizeof(iwe));
 	iwe.cmd = SIOCGIWAP;
 	iwe.u.ap_addr.sa_family = ARPHRD_ETHER;
@@ -3013,9 +3004,6 @@ ieee80211_sta_scan_result(struct net_device *dev,
 	do {
 		char *buf;
 
-		if (!(local->scan_flags & IEEE80211_SCAN_EXTRA_INFO))
-			break;
-
 		buf = kmalloc(100, GFP_ATOMIC);
 		if (!buf)
 			break;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 1a53154..9ccf4b5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1527,64 +1527,6 @@ int ieee80211_subif_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
-/*
- * This is the transmit routine for the 802.11 type interfaces
- * called by upper layers of the linux networking
- * stack when it has a frame to transmit
- */
-int ieee80211_mgmt_start_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	struct ieee80211_sub_if_data *sdata;
-	struct ieee80211_tx_packet_data *pkt_data;
-	struct ieee80211_hdr *hdr;
-	u16 fc;
-
-	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
-
-	if (skb->len < 10) {
-		dev_kfree_skb(skb);
-		return 0;
-	}
-
-	if (skb_headroom(skb) < sdata->local->tx_headroom) {
-		if (pskb_expand_head(skb, sdata->local->tx_headroom,
-				     0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			return 0;
-		}
-	}
-
-	hdr = (struct ieee80211_hdr *) skb->data;
-	fc = le16_to_cpu(hdr->frame_control);
-
-	pkt_data = (struct ieee80211_tx_packet_data *) skb->cb;
-	memset(pkt_data, 0, sizeof(struct ieee80211_tx_packet_data));
-	pkt_data->ifindex = sdata->dev->ifindex;
-
-	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
-	skb->dev = sdata->local->mdev;
-
-	/*
-	 * We're using the protocol field of the the frame control header
-	 * to request TX callback for hostapd. BIT(1) is checked.
-	 */
-	if ((fc & BIT(1)) == BIT(1)) {
-		pkt_data->flags |= IEEE80211_TXPD_REQ_TX_STATUS;
-		fc &= ~BIT(1);
-		hdr->frame_control = cpu_to_le16(fc);
-	}
-
-	if (!(fc & IEEE80211_FCTL_PROTECTED))
-		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
-
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
-	dev_queue_xmit(skb);
-
-	return 0;
-}
-
 /* helper functions for pending packets for when queues are stopped */
 
 void ieee80211_clear_tx_pending(struct ieee80211_local *local)
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 5a0564e..88f262b 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -22,6 +22,7 @@
 #include <linux/bitmap.h>
 #include <net/net_namespace.h>
 #include <net/cfg80211.h>
+#include <net/rtnetlink.h>
 
 #include "ieee80211_i.h"
 #include "ieee80211_rate.h"
@@ -484,3 +485,35 @@ void ieee80211_wake_queues(struct ieee80211_hw *hw)
 		ieee80211_wake_queue(hw, i);
 }
 EXPORT_SYMBOL(ieee80211_wake_queues);
+
+void ieee80211_iterate_active_interfaces(struct ieee80211_hw *hw,
+					 void (*iterator)(void *data, u8 *mac,
+							  int if_id),
+					 void *data)
+{
+	struct ieee80211_local *local = hw_to_local(hw);
+	struct ieee80211_sub_if_data *sdata;
+
+	ASSERT_RTNL();
+
+	/* we hold the RTNL here so can safely walk the list */
+	list_for_each_entry(sdata, &local->interfaces, list) {
+		switch (sdata->type) {
+		case IEEE80211_IF_TYPE_INVALID:
+		case IEEE80211_IF_TYPE_MNTR:
+		case IEEE80211_IF_TYPE_VLAN:
+			continue;
+		case IEEE80211_IF_TYPE_AP:
+		case IEEE80211_IF_TYPE_STA:
+		case IEEE80211_IF_TYPE_IBSS:
+		case IEEE80211_IF_TYPE_WDS:
+			break;
+		}
+		if (sdata->dev == local->mdev)
+			continue;
+		if (netif_running(sdata->dev))
+			iterator(data, sdata->dev->dev_addr,
+				 sdata->dev->ifindex);
+	}
+}
+EXPORT_SYMBOL_GPL(ieee80211_iterate_active_interfaces);
-- 
John W. Linville
linville@tuxdriver.com
