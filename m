From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/4] net: add driver hook for tx time stamping.
Date: Sat, 17 Jul 2010 20:48:28 +0200
Message-ID: <4398135dc3c471239cc8f349c2c3a85cd87ac017.1279391885.git.richard.cochran@omicron.at>
References: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756493Ab0GQSs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 14:48:28 -0400
Received: by mail-bw0-f46.google.com with SMTP id 1so1698395bwz.19
        for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 11:48:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1279391885.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a hook for transmit time stamps. The transmit hook
allows a software fallback for transmit time stamps, for MACs
lacking time stamping hardware. Using the hook will still require
adding an inline function call to each MAC driver.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/skbuff.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac74ee0..a1b0400 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1947,6 +1947,27 @@ static inline ktime_t net_invalid_timestamp(void)
 extern void skb_tstamp_tx(struct sk_buff *orig_skb,
 			struct skb_shared_hwtstamps *hwtstamps);
 
+static inline void sw_tx_timestamp(struct sk_buff *skb)
+{
+	union skb_shared_tx *shtx = skb_tx(skb);
+	if (shtx->software && !shtx->in_progress)
+		skb_tstamp_tx(skb, NULL);
+}
+
+/**
+ * skb_tx_timestamp() - Driver hook for transmit timestamping
+ *
+ * Ethernet MAC Drivers should call this function in their hard_xmit()
+ * function as soon as possible after giving the sk_buff to the MAC
+ * hardware, but before freeing the sk_buff.
+ *
+ * @skb: A socket buffer.
+ */
+static inline void skb_tx_timestamp(struct sk_buff *skb)
+{
+	sw_tx_timestamp(skb);
+}
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
-- 
1.7.0.4

