From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 1/6] ieee80211: Fix TKIP MIC calculation for QoS frames
Date: Thu, 13 Apr 2006 17:17:06 +0800
Message-ID: <20060413091706.GA28641@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:37296 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751227AbWDMJYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:10 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix TKIP MIC verification failure when receiving QoS frames from AP.

Signed-off-by: Hong Liu <hong.liu@intel.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/ieee80211.h              |    3 +++
 net/ieee80211/ieee80211_crypt_tkip.c |   11 ++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

2a0ee963da3c8a125e2af4dec07aca8bf4357d03
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 4725ff8..66dc136 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -104,6 +104,9 @@
 #define IEEE80211_SCTL_FRAG		0x000F
 #define IEEE80211_SCTL_SEQ		0xFFF0
 
+/* QOS control */
+#define IEEE80211_QCTL_TID		0x000F
+
 /* debug macros */
 
 #ifdef CONFIG_IEEE80211_DEBUG
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 93def94..3fa5df2 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -501,8 +501,11 @@ static int michael_mic(struct ieee80211_
 static void michael_mic_hdr(struct sk_buff *skb, u8 * hdr)
 {
 	struct ieee80211_hdr_4addr *hdr11;
+	u16 stype;
 
 	hdr11 = (struct ieee80211_hdr_4addr *)skb->data;
+	stype  = WLAN_FC_GET_STYPE(le16_to_cpu(hdr11->frame_ctl));
+
 	switch (le16_to_cpu(hdr11->frame_ctl) &
 		(IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
 	case IEEE80211_FCTL_TODS:
@@ -523,7 +526,13 @@ static void michael_mic_hdr(struct sk_bu
 		break;
 	}
 
-	hdr[12] = 0;		/* priority */
+	if (stype & IEEE80211_STYPE_QOS_DATA) {
+		const struct ieee80211_hdr_3addrqos *qoshdr =
+			(struct ieee80211_hdr_3addrqos *)skb->data;
+		hdr[12] = le16_to_cpu(qoshdr->qos_ctl) & IEEE80211_QCTL_TID;
+	} else
+		hdr[12] = 0;		/* priority */
+
 	hdr[13] = hdr[14] = hdr[15] = 0;	/* reserved */
 }
 
-- 
1.2.6

