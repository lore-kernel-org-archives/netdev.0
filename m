From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] drivers: wireless: carl9170: shrink carl9170_tx_info
Date: Fri, 13 Mar 2015 16:37:25 +0100
Message-ID: <1426261045-22373-1-git-send-email-fw@strlen.de>
Cc: chunkeey@googlemail.com, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57155 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755087AbbCMPhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 11:37:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

its embededded inside rate_driver_data of the ieee80211_tx_info struct,
which in turn is stored in skb->cb[].

In order to shrink cb, we need to shrink ieee80211_tx_info which means
to downsize all users first.

Alternatively, one might be able to remove kref but
its less intrusive/simpler to use u32 for timeout handling.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/wireless/ath/carl9170/carl9170.h |  4 ++--
 drivers/net/wireless/ath/carl9170/debug.c    |  2 +-
 drivers/net/wireless/ath/carl9170/tx.c       | 24 +++++++++++++++++++-----
 3 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/carl9170.h b/drivers/net/wireless/ath/carl9170/carl9170.h
index 237d0cd..a785300 100644
--- a/drivers/net/wireless/ath/carl9170/carl9170.h
+++ b/drivers/net/wireless/ath/carl9170/carl9170.h
@@ -491,9 +491,9 @@ struct carl9170_sta_info {
 };
 
 struct carl9170_tx_info {
-	unsigned long timeout;
-	struct ar9170 *ar;
+	u32 timeout32;
 	struct kref ref;
+	struct ar9170 *ar;
 };
 
 #define CHK_DEV_STATE(a, s)	(((struct ar9170 *)a)->state >= (s))
diff --git a/drivers/net/wireless/ath/carl9170/debug.c b/drivers/net/wireless/ath/carl9170/debug.c
index 6808db4..d00ab9d 100644
--- a/drivers/net/wireless/ath/carl9170/debug.c
+++ b/drivers/net/wireless/ath/carl9170/debug.c
@@ -291,7 +291,7 @@ static void carl9170_debugfs_format_frame(struct ar9170 *ar,
 	    "pc:%.8x, to:%d ms\n", prefix, skb, txc->s.cookie,
 	    ieee80211_get_DA(hdr), get_seq_h(hdr),
 	    le16_to_cpu(txc->f.mac_control), le32_to_cpu(txc->f.phy_control),
-	    jiffies_to_msecs(jiffies - arinfo->timeout));
+	    jiffies_to_msecs(((u32)jiffies) - arinfo->timeout32));
 }
 
 
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/ath/carl9170/tx.c
index ae86a600..d576747 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -555,6 +555,20 @@ static void carl9170_tx_fill_rateinfo(struct ar9170 *ar, unsigned int rix,
 	}
 }
 
+static inline bool carl9170_time_is_before_jiffies(u32 timeout)
+{
+	u32 now = (u32)jiffies;
+
+	return (s32)(now - timeout) >= 0;
+}
+
+static inline bool carl9170_time_is_after_jiffies(u32 timeout)
+{
+	u32 now = (u32)jiffies;
+
+	return (s32)(now - timeout) < 0;
+}
+
 static void carl9170_check_queue_stop_timeout(struct ar9170 *ar)
 {
 	int i;
@@ -574,8 +588,8 @@ static void carl9170_check_queue_stop_timeout(struct ar9170 *ar)
 		txinfo = IEEE80211_SKB_CB(skb);
 		arinfo = (void *) txinfo->rate_driver_data;
 
-		if (time_is_before_jiffies(arinfo->timeout +
-		    msecs_to_jiffies(CARL9170_QUEUE_STUCK_TIMEOUT)) == true)
+		if (carl9170_time_is_before_jiffies(arinfo->timeout32 +
+		    (u32)msecs_to_jiffies(CARL9170_QUEUE_STUCK_TIMEOUT)))
 			restart = true;
 
 next:
@@ -620,7 +634,7 @@ static void carl9170_tx_ampdu_timeout(struct ar9170 *ar)
 
 		txinfo = IEEE80211_SKB_CB(skb);
 		arinfo = (void *)txinfo->rate_driver_data;
-		if (time_is_after_jiffies(arinfo->timeout +
+		if (carl9170_time_is_after_jiffies(arinfo->timeout32 +
 		    msecs_to_jiffies(CARL9170_QUEUE_TIMEOUT)))
 			goto unlock;
 
@@ -1066,7 +1080,7 @@ static int carl9170_tx_prepare(struct ar9170 *ar,
 	txc->f.mac_control = mac_tmp;
 
 	arinfo = (void *)info->rate_driver_data;
-	arinfo->timeout = jiffies;
+	arinfo->timeout32 = (u32)jiffies;
 	arinfo->ar = ar;
 	kref_init(&arinfo->ref);
 	return 0;
@@ -1259,7 +1273,7 @@ static struct sk_buff *carl9170_tx_pick_skb(struct ar9170 *ar,
 	info = IEEE80211_SKB_CB(skb);
 	arinfo = (void *) info->rate_driver_data;
 
-	arinfo->timeout = jiffies;
+	arinfo->timeout32 = (u32)jiffies;
 	return skb;
 
 err_unlock:
-- 
2.0.5
