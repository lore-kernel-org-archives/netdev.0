From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 2/4] phylib: add a way to make PHY time stamps possible.
Date: Mon, 5 Jul 2010 07:32:52 +0200
Message-ID: <f5d438863bb1132293cb6eab89fe199a739e4957.1278307573.git.richard.cochran@omicron.at>
References: <cover.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:52146 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0GEFc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 01:32:56 -0400
Received: by bwz1 with SMTP id 1so2488615bwz.19
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 22:32:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new networking option to allow hardware time stamps
from PHY devices. Using PHY time stamps will still require adding two
inline function calls to each MAC driver. The CONFIG option makes
these calls safe to add, since the calls become NOOPs when the option
is disabled.

The patch also adds phylib driver methods for the SIOCSHWTSTAMP ioctl
and callbacks for transmit and receive time stamping. Drivers may
optionally implement these functions.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/phy.h    |    7 +++++++
 include/linux/skbuff.h |   29 +++++++++++++++++++++++++++++
 net/Kconfig            |   11 +++++++++++
 3 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 987e111..3566bde 100644
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
@@ -402,6 +404,11 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
+	int (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
+	int (*rxtstamp)(struct phy_device *phydev, struct sk_buff *skb);
+	int (*txtstamp)(struct phy_device *phydev, struct sk_buff *skb);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 75323fe..8905508 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1955,6 +1955,33 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
 		skb_tstamp_tx(skb, NULL);
 }
 
+#ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
+
+static inline void phy_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+	union skb_shared_tx *shtx = skb_tx(skb);
+	if (shtx->hardware && phy && phy->drv->txtstamp)
+		phy->drv->txtstamp(phy, skb);
+}
+
+static inline void phy_rx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+	if (phy && phy->drv->rxtstamp)
+		phy->drv->rxtstamp(phy, skb);
+}
+
+#else /* CONFIG_NETWORK_PHY_TIMESTAMPING */
+
+static inline void phy_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+}
+
+static inline void phy_rx_timestamp(struct phy_device *phy, struct sk_buff *skb)
+{
+}
+
+#endif /* !CONFIG_NETWORK_PHY_TIMESTAMPING */
+
 /**
  * skb_tx_timestamp() - Driver hook for transmit timestamping
  *
@@ -1967,6 +1994,7 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
  */
 static inline void skb_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
 {
+	phy_tx_timestamp(phy, skb);
 	sw_tx_timestamp(skb);
 }
 
@@ -1981,6 +2009,7 @@ static inline void skb_tx_timestamp(struct phy_device *phy, struct sk_buff *skb)
  */
 static inline void skb_rx_timestamp(struct phy_device *phy, struct sk_buff *skb)
 {
+	phy_rx_timestamp(phy, skb);
 }
 
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
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
1.7.0.4

