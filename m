From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 05/14] drivers: wireless: ar5523: use container_of
Date: Mon,  2 Mar 2015 18:40:19 +0100
Message-ID: <1425318028-26531-6-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, linux-wireless@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54110 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754540AbbCBRko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:44 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile tested only due to lack of hw.

If we want to shrink skb->cb then we'd have to see about
reducing struct ieee80211_tx_info, which gets embedded inside
skb->cb[].

It provides a scratch space to be used by wireless drivers.
ar5523 uses the maximum space available today (40 bytes), but it seems
we don't need this -- data->skb pointer seems to always point back to the
skb whose cb buffer the data structure resides, iow, given a pointer to the
embedded control buffer we can infer the skb address.

Cc: linux-wireless@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/wireless/ath/ar5523/ar5523.c | 8 ++++----
 drivers/net/wireless/ath/ar5523/ar5523.h | 1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
index f920506..7410ac0 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -779,8 +779,6 @@ static void ar5523_tx(struct ieee80211_hw *hw,
 		ieee80211_stop_queues(hw);
 	}
 
-	data->skb = skb;
-
 	spin_lock_irqsave(&ar->tx_data_list_lock, flags);
 	list_add_tail(&data->list, &ar->tx_queue_pending);
 	spin_unlock_irqrestore(&ar->tx_data_list_lock, flags);
@@ -817,10 +815,12 @@ static void ar5523_tx_work_locked(struct ar5523 *ar)
 		if (!data)
 			break;
 
-		skb = data->skb;
+		txi = container_of((void *)data, struct ieee80211_tx_info, driver_data);
 		txqid = 0;
-		txi = IEEE80211_SKB_CB(skb);
+
+		skb = container_of((void *) txi, struct sk_buff, cb);
 		paylen = skb->len;
+
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
 			ar5523_err(ar, "Failed to allocate TX urb\n");
diff --git a/drivers/net/wireless/ath/ar5523/ar5523.h b/drivers/net/wireless/ath/ar5523/ar5523.h
index 00c6fd3..9a322a6 100644
--- a/drivers/net/wireless/ath/ar5523/ar5523.h
+++ b/drivers/net/wireless/ath/ar5523/ar5523.h
@@ -74,7 +74,6 @@ struct ar5523_tx_cmd {
 struct ar5523_tx_data {
 	struct list_head	list;
 	struct ar5523		*ar;
-	struct sk_buff		*skb;
 	struct urb		*urb;
 };
 
-- 
2.0.5
