From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 01/10] net: introduce time stamping wrapper for netif_rx.
Date: Fri, 10 Jun 2011 17:06:59 +0200
Message-ID: <34a4527448b3a36c88d0c1c3cb9ad8661e693d7a.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57323 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757319Ab1FJPHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:07:17 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2260711bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:07:17 -0700 (PDT)
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds a variation on netif_rx() designed to allow non-NAPI
Ethernet MAC drivers to support hardware time stamping in PHY devices.
Adapting a given driver requires two small changes, namely replacing
netif_rx() with netif_rx_defer() and adding a call to skb_tx_timestamp()
in the transmission path.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/netdevice.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..9a56505 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2066,6 +2066,27 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
 #define HAVE_NETIF_RX 1
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
+
+/**
+ * netif_rx_defer() - post buffer to the network code
+ * @skb: buffer to post
+ *
+ * This function receives a packet from a device driver and queues it
+ * for the upper (protocol) levels to process.  All non-NAPI Ethernet
+ * MAC drivers should use this instead of netif_rx() since this method
+ * allows hardware timestamping to occur within the PHY.
+ *
+ * return values:
+ * NET_RX_SUCCESS  (no congestion)
+ * NET_RX_DROP     (packet was dropped)
+ */
+static inline int netif_rx_defer(struct sk_buff *skb)
+{
+	if (skb_defer_rx_timestamp(skb))
+		return NET_RX_SUCCESS;
+	return netif_rx(skb);
+}
+
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
-- 
1.7.0.4

