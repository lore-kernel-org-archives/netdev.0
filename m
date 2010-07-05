From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/4] net: add driver hooks for time stamping.
Date: Mon, 5 Jul 2010 07:31:07 +0200
Message-ID: <a9c79dd7d996a352b37ea4e650b235d0c8b996d1.1278307573.git.richard.cochran@omicron.at>
References: <cover.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44353 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0GEFbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 01:31:11 -0400
Received: by mail-bw0-f46.google.com with SMTP id 1so2488155bwz.19
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 22:31:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds hooks for transmit and receive time stamps. The
transmit hook allows a software fallback for transmit time stamps,
for MACs lacking time stamping hardware. The receive hook does not yet
have any effect, but it prepares the way for hardware time stamping
in PHY devices. Using the hooks will still require adding two inline
function calls to each MAC driver.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/skbuff.h |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac74ee0..75323fe 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/phy.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1947,6 +1948,41 @@ static inline ktime_t net_invalid_timestamp(void)
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
+ * @phy: The port's phy_device. Pass NULL if this is not available.
+ * @skb: A socket buffer.
+ */
+static inline void skb_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+	sw_tx_timestamp(skb);
+}
+
+/**
+ * skb_rx_timestamp() - Driver hook for receive timestamping
+ *
+ * Ethernet MAC Drivers should call this function in their NAPI poll()
+ * function immediately before calling eth_type_trans().
+ *
+ * @phy: The port's phy_device. Pass NULL if this is not available.
+ * @skb: A socket buffer.
+ */
+static inline void skb_rx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+}
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
-- 
1.7.0.4

