From: greearb@candelatech.com
Subject: [PATCH 4/4] mac80211-hwsim: enable better rx-status when using netlink.
Date: Fri,  3 Apr 2015 14:12:03 -0700
Message-ID: <1428095523-374-4-git-send-email-greearb@candelatech.com>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Cc: johannes@sipsolutions.net, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34594 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbbDCVMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:12:08 -0400
In-Reply-To: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows proper rx-status reporting for packets received
from the netlink api.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 10 ++++++++++
 drivers/net/wireless/mac80211_hwsim.h | 18 ++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index afb2139..67c604b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2824,6 +2824,16 @@ static int hwsim_cloned_frame_received_nl(struct sk_buff *skb_2,
 	rx_status.rate_idx = nla_get_u32(info->attrs[HWSIM_ATTR_RX_RATE]);
 	rx_status.signal = nla_get_u32(info->attrs[HWSIM_ATTR_SIGNAL]);
 
+	if (info->attrs[HWSIM_ATTR_RX_INFO]) {
+		struct hwsim_rx_info *r;
+		r = (struct hwsim_rx_info *)nla_data(
+			info->attrs[HWSIM_ATTR_RX_INFO]);
+		rx_status.flag = r->rx_flags;
+		rx_status.vht_flag = r->vht_flags;
+		rx_status.vht_nss = r->vht_nss;
+		rx_status.ampdu_reference = r->ampdu_reference;
+	}
+
 	memcpy(IEEE80211_SKB_RXCB(skb), &rx_status, sizeof(rx_status));
 	data2->rx_pkts++;
 	data2->rx_bytes += skb->len;
diff --git a/drivers/net/wireless/mac80211_hwsim.h b/drivers/net/wireless/mac80211_hwsim.h
index a2e2e11..0e26c9f 100644
--- a/drivers/net/wireless/mac80211_hwsim.h
+++ b/drivers/net/wireless/mac80211_hwsim.h
@@ -130,6 +130,7 @@ enum {
  * @HWSIM_ATTR_NO_VIF:  Do not create vif (wlanX) when creating radio.
  * @HWSIM_ATTR_FREQ: Frequency at which packet is transmitted or received.
  * @HWSIM_ATTR_TX_INFO2: hwsim_tx_rate2 array
+ * @HWSIM_ATTR_RX_INFO: hwsim_rx_info
  * @__HWSIM_ATTR_MAX: enum limit
  */
 
@@ -156,6 +157,7 @@ enum {
 	HWSIM_ATTR_NO_VIF,
 	HWSIM_ATTR_FREQ,
 	HWSIM_ATTR_TX_INFO2,
+	HWSIM_ATTR_RX_INFO,
 	__HWSIM_ATTR_MAX,
 };
 #define HWSIM_ATTR_MAX (__HWSIM_ATTR_MAX - 1)
@@ -184,4 +186,20 @@ struct hwsim_tx_rate2 {
 	s16 power_level;
 } __packed;
 
+/**
+ * This relates to the ieee80211_rx_status struct in mac80211.h
+ * @rx_flags: %RX_FLAG_* (see  mac80211_rx_flags)
+ * @vht_flags: %RX_VHT_FLAG_*
+ * @vht_nss: number of streams (VHT only)
+ * @ampdu_reference: A-MPDU reference number, must be a different value for
+ *	each A-MPDU but the same for each subframe within one A-MPDU
+ */
+struct hwsim_rx_info {
+	u32 rx_flags;
+	u8 vht_flags;
+	u8 vht_nss;
+	u16 unused_pad; /* pad to 32-bits, and space for growth */
+	u32 ampdu_reference;
+} __packed;
+
 #endif /* __MAC80211_HWSIM_H */
-- 
1.7.11.7
