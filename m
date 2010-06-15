From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 04/12] phylib: add a way to make PHY time stamps possible.
Date: Tue, 15 Jun 2010 18:08:20 +0200
Message-ID: <27c0ad283f025c2bb71e7ceb71be07f969939429.1276615626.git.richard.cochran@omicron.at>
References: <cover.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43726 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab0FOQHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 12:07:35 -0400
Received: by mail-fx0-f46.google.com with SMTP id 10so266600fxm.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 09:07:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1276615626.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new networking option to allow hardware time stamps
from PHY devices. Using PHY time stamps will still require adding two
inline function calls to each MAC driver. The CONFIG option makes these
calls safe to add, since the calls become NOOPs when the option is
disabled.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/phy.h    |    4 ++++
 include/linux/skbuff.h |   32 ++++++++++++++++++++++++++++++++
 net/Kconfig            |   11 +++++++++++
 3 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index a5e9df1..7a8caac 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -234,6 +234,8 @@ enum phy_state {
 	PHY_RESUMING
 };
 
+struct sk_buff;
+
 /* phy_device: An instance of a PHY
  *
  * drv: Pointer to the driver for this PHY instance
@@ -404,6 +406,8 @@ struct phy_driver {
 
 	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
 	int (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
+	int (*rxtstamp)(struct phy_device *phydev, struct sk_buff *skb);
+	int (*txtstamp)(struct phy_device *phydev, struct sk_buff *skb);
 
 	struct device_driver driver;
 };
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 645e78d..7b650d4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/phy.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1942,6 +1943,37 @@ static inline ktime_t net_invalid_timestamp(void)
 extern void skb_tstamp_tx(struct sk_buff *orig_skb,
 			struct skb_shared_hwtstamps *hwtstamps);
 
+#ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
+
+static inline void skb_tx_timetamp(struct phy_device *phy, struct sk_buff *skb)
+{
+	union skb_shared_tx *shtx = skb_tx(skb);
+
+	if (shtx->hardware && phy && phy->drv->txtstamp)
+		phy->drv->txtstamp(phy, skb);
+
+	if (shtx->software && !shtx->in_progress)
+		skb_tstamp_tx(skb, NULL);
+}
+
+static inline void skb_rx_timetamp(struct phy_device *phy, struct sk_buff *skb)
+{
+	if (phy && phy->drv->rxtstamp)
+		phy->drv->rxtstamp(phy, skb);
+}
+
+#else /* CONFIG_NETWORK_PHY_TIMESTAMPING */
+
+static inline void skb_tx_timetamp(struct phy_device *phy, struct sk_buff *skb)
+{
+}
+
+static inline void skb_rx_timetamp(struct phy_device *phy, struct sk_buff *skb)
+{
+}
+
+#endif /* !CONFIG_NETWORK_PHY_TIMESTAMPING */
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
diff --git a/net/Kconfig b/net/Kconfig
index 0d68b40..3fa7ae3 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -86,6 +86,17 @@ config NETWORK_SECMARK
 	  to nfmark, but designated for security purposes.
 	  If you are unsure how to answer this question, answer N.
 
+config NETWORK_PHY_TIMESTAMPING
+	bool "Timestamping in PHY devices"
+	depends on EXPERIMENTAL
+	help
+	  This allows timestamping of network packets by PHYs with
+	  hardware timestamping capabilities. This option adds some
+	  overhead in the transmit and receive paths. Note that this
+	  option also requires support in the MAC driver.
+
+	  If you are unsure how to answer this question, answer N.
+
 menuconfig NETFILTER
 	bool "Network packet filtering framework (Netfilter)"
 	---help---
-- 
1.6.3.3

