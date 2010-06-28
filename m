From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/4] net: add driver hooks for time stamping.
Date: Mon, 28 Jun 2010 17:34:00 +0200
Message-ID: <60156fd38851b015312293c1873458bfbbfc73c5.1277737223.git.richard.cochran@omicron.at>
References: <cover.1277737222.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:20070 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774Ab0F1Pd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 11:33:57 -0400
Received: by fg-out-1718.google.com with SMTP id e21so497563fga.1
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 08:33:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1277737222.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds hooks for transmit and receive time stamps and a new
networking option to allow a software fallback for transmit time stamps,
for MACs lacking time stamping hardware. The receive hook does not yet
have any effect, but it prepares the way for hardware time stamping
in PHY devices.

Using the hooks will still require adding two inline function calls to
each MAC driver. The CONFIG option makes these calls safe to add, since
the calls become NOOPs when the option is disabled.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/skbuff.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/Kconfig            |   11 +++++++++++
 2 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac74ee0..fe70e66 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/phy.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1947,6 +1948,47 @@ static inline ktime_t net_invalid_timestamp(void)
 extern void skb_tstamp_tx(struct sk_buff *orig_skb,
 			struct skb_shared_hwtstamps *hwtstamps);
 
+#ifdef CONFIG_NETWORK_TXTS_FALLBACK
+static inline void sw_tx_timestamp(struct sk_buff *skb)
+{
+	union skb_shared_tx *shtx = skb_tx(skb);
+	if (shtx->software && !shtx->in_progress)
+		skb_tstamp_tx(skb, NULL);
+}
+#else
+static inline void sw_tx_timestamp(struct sk_buff *skb)
+{
+}
+#endif
+
+/**
+ * skb_tx_timestamp() - Driver hook for software timestamping
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
 
diff --git a/net/Kconfig b/net/Kconfig
index 0d68b40..73e8d97 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -86,6 +86,17 @@ config NETWORK_SECMARK
 	  to nfmark, but designated for security purposes.
 	  If you are unsure how to answer this question, answer N.
 
+config NETWORK_TXTS_FALLBACK
+	bool "Transmit Timestamping in Software"
+	depends on EXPERIMENTAL
+	help
+	  This option allows timestamping of transmitted packets for
+	  MACs which lack hardware timestamping capabilities. This
+	  option adds some overhead in the transmit path. Note that
+	  this option also requires support in the MAC driver.
+
+	  If you are unsure how to answer this question, answer N.
+
 menuconfig NETFILTER
 	bool "Network packet filtering framework (Netfilter)"
 	---help---
-- 
1.7.0.4

