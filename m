From: greearb@candelatech.com
Subject: [PATCH 3/4] mac80211-hwsim: Pass rate-ctrl flags and tx-power to user-space
Date: Fri,  3 Apr 2015 14:12:02 -0700
Message-ID: <1428095523-374-3-git-send-email-greearb@candelatech.com>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Cc: johannes@sipsolutions.net, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34592 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbDCVMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 17:12:08 -0400
In-Reply-To: <1428095523-374-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

The flags field allows user-space to properly decode what the
rate->idx really means.  The tx-power field is useful as well,
in case user-space is interested in doing something clever with
path-loss calculations.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 21 ++++++++++++++++++++-
 drivers/net/wireless/mac80211_hwsim.h |  8 ++++++++
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 5089169..afb2139 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -521,6 +521,9 @@ static const struct nla_policy hwsim_genl_policy[HWSIM_ATTR_MAX + 1] = {
 	[HWSIM_ATTR_RADIO_NAME] = { .type = NLA_STRING },
 	[HWSIM_ATTR_NO_VIF] = { .type = NLA_FLAG },
 	[HWSIM_ATTR_FREQ] = { .type = NLA_U32 },
+	[HWSIM_ATTR_TX_INFO2] = { .type = NLA_UNSPEC,
+				  .len = IEEE80211_TX_MAX_RATES *
+				         sizeof(struct hwsim_tx_rate2)},
 };
 
 static void mac80211_hwsim_tx_frame(struct ieee80211_hw *hw,
@@ -929,6 +932,7 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 	unsigned int hwsim_flags = 0;
 	int i;
 	struct hwsim_tx_rate tx_attempts[IEEE80211_TX_MAX_RATES];
+	struct hwsim_tx_rate2 tx_attempts2[IEEE80211_TX_MAX_RATES];
 
 	if (data->ps != PS_DISABLED)
 		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PM);
@@ -980,6 +984,8 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 	for (i = 0; i < IEEE80211_TX_MAX_RATES; i++) {
 		tx_attempts[i].idx = info->status.rates[i].idx;
 		tx_attempts[i].count = info->status.rates[i].count;
+		tx_attempts2[i].rc_flags = info->status.rates[i].flags;
+		tx_attempts2[i].power_level = data->power_level;
 	}
 
 	if (nla_put(skb, HWSIM_ATTR_TX_INFO,
@@ -987,6 +993,11 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		    tx_attempts))
 		goto nla_put_failure;
 
+	if (nla_put(skb, HWSIM_ATTR_TX_INFO2,
+		    sizeof(struct hwsim_tx_rate2)*IEEE80211_TX_MAX_RATES,
+		    tx_attempts2))
+		goto nla_put_failure;
+
 	/* We create a cookie to identify this skb */
 	if (nla_put_u64(skb, HWSIM_ATTR_COOKIE, (unsigned long) my_skb))
 		goto nla_put_failure;
@@ -2680,6 +2691,7 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	struct mac80211_hwsim_data *data2;
 	struct ieee80211_tx_info *txi;
 	struct hwsim_tx_rate *tx_attempts;
+	struct hwsim_tx_rate2 *tx_attempts2;
 	unsigned long ret_skb_ptr;
 	struct sk_buff *skb, *tmp;
 	const u8 *src;
@@ -2723,6 +2735,12 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	tx_attempts = (struct hwsim_tx_rate *)nla_data(
 		       info->attrs[HWSIM_ATTR_TX_INFO]);
 
+	if (info->attrs[HWSIM_ATTR_TX_INFO2])
+		tx_attempts2 = (struct hwsim_tx_rate2 *)nla_data(
+		       info->attrs[HWSIM_ATTR_TX_INFO2]);
+	else
+		tx_attempts2 = NULL;
+
 	/* now send back TX status */
 	txi = IEEE80211_SKB_CB(skb);
 
@@ -2731,7 +2749,8 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 	for (i = 0; i < IEEE80211_TX_MAX_RATES; i++) {
 		txi->status.rates[i].idx = tx_attempts[i].idx;
 		txi->status.rates[i].count = tx_attempts[i].count;
-		/*txi->status.rates[i].flags = 0;*/
+		if (tx_attempts2)
+			txi->status.rates[i].flags = tx_attempts2[i].rc_flags;
 	}
 
 	txi->status.ack_signal = nla_get_u32(info->attrs[HWSIM_ATTR_SIGNAL]);
diff --git a/drivers/net/wireless/mac80211_hwsim.h b/drivers/net/wireless/mac80211_hwsim.h
index f0fc495c..a2e2e11 100644
--- a/drivers/net/wireless/mac80211_hwsim.h
+++ b/drivers/net/wireless/mac80211_hwsim.h
@@ -129,6 +129,7 @@ enum {
  * @HWSIM_ATTR_RADIO_NAME: Name of radio, e.g. phy666
  * @HWSIM_ATTR_NO_VIF:  Do not create vif (wlanX) when creating radio.
  * @HWSIM_ATTR_FREQ: Frequency at which packet is transmitted or received.
+ * @HWSIM_ATTR_TX_INFO2: hwsim_tx_rate2 array
  * @__HWSIM_ATTR_MAX: enum limit
  */
 
@@ -154,6 +155,7 @@ enum {
 	HWSIM_ATTR_RADIO_NAME,
 	HWSIM_ATTR_NO_VIF,
 	HWSIM_ATTR_FREQ,
+	HWSIM_ATTR_TX_INFO2,
 	__HWSIM_ATTR_MAX,
 };
 #define HWSIM_ATTR_MAX (__HWSIM_ATTR_MAX - 1)
@@ -176,4 +178,10 @@ struct hwsim_tx_rate {
 	u8 count;
 } __packed;
 
+/* Auxilary info to allow user-space to better understand the rate */
+struct hwsim_tx_rate2 {
+	u16 rc_flags; /* rate-ctrl flags (see mac80211_rate_control_flags) */
+	s16 power_level;
+} __packed;
+
 #endif /* __MAC80211_HWSIM_H */
-- 
1.7.11.7
