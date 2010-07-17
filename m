From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 4/4] net: support time stamping in phy devices.
Date: Sat, 17 Jul 2010 20:49:36 +0200
Message-ID: <3141801bf678cc6b67a57de8a041bf1c284d5efb.1279391885.git.richard.cochran@omicron.at>
References: <cover.1279391885.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65139 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756536Ab0GQStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jul 2010 14:49:47 -0400
Received: by mail-bw0-f46.google.com with SMTP id 1so1698395bwz.19
        for <netdev@vger.kernel.org>; Sat, 17 Jul 2010 11:49:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1279391885.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new networking option to allow hardware time stamps
from PHY devices. When enabled, likely candidates among incoming and
outgoing network packets are offered to the PHY driver for possible
time stamping. When accepted by the PHY driver, incoming packets are
deferred for later delivery by the driver.

The patch also adds phylib driver methods for the SIOCSHWTSTAMP ioctl
and callbacks for transmit and receive time stamping. Drivers may
optionally implement these functions.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/phy/phy.c        |    5 ++
 drivers/net/phy/phy_device.c |    2 +
 include/linux/netdevice.h    |    4 +
 include/linux/phy.h          |   22 +++++++
 include/linux/skbuff.h       |   31 ++++++++++
 net/Kconfig                  |   10 +++
 net/core/Makefile            |    2 +-
 net/core/dev.c               |    3 +
 net/core/timestamping.c      |  126 ++++++++++++++++++++++++++++++++++++++++++
 net/socket.c                 |    4 +
 10 files changed, 208 insertions(+), 1 deletions(-)
 create mode 100644 net/core/timestamping.c

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index bd88d81..5130db8 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -361,6 +361,11 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		}
 		break;
 
+	case SIOCSHWTSTAMP:
+		if (phydev->drv->hwtstamp)
+			return phydev->drv->hwtstamp(phydev, ifr);
+		/* fall through */
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 1a99bb2..c076119 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -460,6 +460,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	}
 
 	phydev->attached_dev = dev;
+	dev->phydev = phydev;
 
 	phydev->dev_flags = flags;
 
@@ -513,6 +514,7 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
+	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 
 	/* If the device had no specific driver before (i.e. - it
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8fa5e5a..131e9c8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -54,6 +54,7 @@
 
 struct vlan_group;
 struct netpoll_info;
+struct phy_device;
 /* 802.11 specific */
 struct wireless_dev;
 					/* source back-compat hooks */
@@ -1077,6 +1078,9 @@ struct net_device {
 #endif
 	/* n-tuple filter list attached to this device */
 	struct ethtool_rx_ntuple_list ethtool_ntuple_list;
+
+	/* phy device may attach itself for hardware timestamping */
+	struct phy_device *phydev;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d63736a..6b0a782 100644
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
@@ -402,6 +404,26 @@ struct phy_driver {
 	/* Clears up any memory if needed */
 	void (*remove)(struct phy_device *phydev);
 
+	/* Handles SIOCSHWTSTAMP ioctl for hardware time stamping. */
+	int  (*hwtstamp)(struct phy_device *phydev, struct ifreq *ifr);
+
+	/*
+	 * Requests a Rx timestamp for 'skb'. If the skb is accepted,
+	 * the phy driver promises to deliver it using netif_rx() as
+	 * soon as a timestamp becomes available. One of the
+	 * PTP_CLASS_ values is passed in 'type'. The function must
+	 * return true if the skb is accepted for delivery.
+	 */
+	bool (*rxtstamp)(struct phy_device *dev, struct sk_buff *skb, int type);
+
+	/*
+	 * Requests a Tx timestamp for 'skb'. The phy driver promises
+	 * to deliver it to the socket's error queue as soon as a
+	 * timestamp becomes available. One of the PTP_CLASS_ values
+	 * is passed in 'type'.
+	 */
+	void (*txtstamp)(struct phy_device *dev, struct sk_buff *skb, int type);
+
 	struct device_driver driver;
 };
 #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a1b0400..f5aa87e 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1933,6 +1933,36 @@ static inline ktime_t net_invalid_timestamp(void)
 	return ktime_set(0, 0);
 }
 
+extern void skb_timestamping_init(void);
+
+#ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
+
+extern void skb_clone_tx_timestamp(struct sk_buff *skb);
+extern bool skb_defer_rx_timestamp(struct sk_buff *skb);
+
+#else /* CONFIG_NETWORK_PHY_TIMESTAMPING */
+
+static inline void skb_clone_tx_timestamp(struct sk_buff *skb)
+{
+}
+
+static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
+{
+	return false;
+}
+
+#endif /* !CONFIG_NETWORK_PHY_TIMESTAMPING */
+
+/**
+ * skb_complete_tx_timestamp() - deliver cloned skb with tx timestamps
+ *
+ * @skb: clone of the the original outgoing packet
+ * @hwtstamps: hardware time stamps
+ *
+ */
+void skb_complete_tx_timestamp(struct sk_buff *skb,
+			       struct skb_shared_hwtstamps *hwtstamps);
+
 /**
  * skb_tstamp_tx - queue clone of skb with send time stamps
  * @orig_skb:	the original outgoing packet
@@ -1965,6 +1995,7 @@ static inline void sw_tx_timestamp(struct sk_buff *skb)
  */
 static inline void skb_tx_timestamp(struct sk_buff *skb)
 {
+	skb_clone_tx_timestamp(skb);
 	sw_tx_timestamp(skb);
 }
 
diff --git a/net/Kconfig b/net/Kconfig
index 0d68b40..b325094 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -86,6 +86,16 @@ config NETWORK_SECMARK
 	  to nfmark, but designated for security purposes.
 	  If you are unsure how to answer this question, answer N.
 
+config NETWORK_PHY_TIMESTAMPING
+	bool "Timestamping in PHY devices"
+	depends on EXPERIMENTAL
+	help
+	  This allows timestamping of network packets by PHYs with
+	  hardware timestamping capabilities. This option adds some
+	  overhead in the transmit and receive paths.
+
+	  If you are unsure how to answer this question, answer N.
+
 menuconfig NETFILTER
 	bool "Network packet filtering framework (Netfilter)"
 	---help---
diff --git a/net/core/Makefile b/net/core/Makefile
index 51c3eec..8a04dd2 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -18,4 +18,4 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
-
+obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
diff --git a/net/core/dev.c b/net/core/dev.c
index e85cc5f..0804c79 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2939,6 +2939,9 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (netdev_tstamp_prequeue)
 		net_timestamp_check(skb);
 
+	if (skb_defer_rx_timestamp(skb))
+		return NET_RX_SUCCESS;
+
 #ifdef CONFIG_RPS
 	{
 		struct rps_dev_flow voidflow, *rflow = &voidflow;
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
new file mode 100644
index 0000000..0ae6c22
--- /dev/null
+++ b/net/core/timestamping.c
@@ -0,0 +1,126 @@
+/*
+ * PTP 1588 clock support - support for timestamping in PHY devices
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <linux/errqueue.h>
+#include <linux/phy.h>
+#include <linux/ptp_classify.h>
+#include <linux/skbuff.h>
+
+static struct sock_filter ptp_filter[] = {
+	PTP_FILTER
+};
+
+static unsigned int classify(struct sk_buff *skb)
+{
+	if (likely(skb->dev &&
+		   skb->dev->phydev &&
+		   skb->dev->phydev->drv))
+		return sk_run_filter(skb, ptp_filter, ARRAY_SIZE(ptp_filter));
+	else
+		return PTP_CLASS_NONE;
+}
+
+void skb_clone_tx_timestamp(struct sk_buff *skb)
+{
+	struct phy_device *phydev;
+	struct sk_buff *clone;
+	struct sock *sk = skb->sk;
+	unsigned int type;
+
+	if (!sk)
+		return;
+
+	type = classify(skb);
+
+	switch (type) {
+	case PTP_CLASS_V1_IPV4:
+	case PTP_CLASS_V1_IPV6:
+	case PTP_CLASS_V2_IPV4:
+	case PTP_CLASS_V2_IPV6:
+	case PTP_CLASS_V2_L2:
+	case PTP_CLASS_V2_VLAN:
+		phydev = skb->dev->phydev;
+		if (likely(phydev->drv->txtstamp)) {
+			clone = skb_clone(skb, GFP_ATOMIC);
+			if (!clone)
+				return;
+			clone->sk = sk;
+			phydev->drv->txtstamp(phydev, clone, type);
+		}
+		break;
+	default:
+		break;
+	}
+}
+
+void skb_complete_tx_timestamp(struct sk_buff *skb,
+			       struct skb_shared_hwtstamps *hwtstamps)
+{
+	struct sock *sk = skb->sk;
+	struct sock_exterr_skb *serr;
+	int err;
+
+	if (!hwtstamps)
+		return;
+
+	*skb_hwtstamps(skb) = *hwtstamps;
+	serr = SKB_EXT_ERR(skb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = ENOMSG;
+	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
+	skb->sk = NULL;
+	err = sock_queue_err_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_complete_tx_timestamp);
+
+bool skb_defer_rx_timestamp(struct sk_buff *skb)
+{
+	struct phy_device *phydev;
+	unsigned int type;
+
+	skb_push(skb, ETH_HLEN);
+
+	type = classify(skb);
+
+	skb_pull(skb, ETH_HLEN);
+
+	switch (type) {
+	case PTP_CLASS_V1_IPV4:
+	case PTP_CLASS_V1_IPV6:
+	case PTP_CLASS_V2_IPV4:
+	case PTP_CLASS_V2_IPV6:
+	case PTP_CLASS_V2_L2:
+	case PTP_CLASS_V2_VLAN:
+		phydev = skb->dev->phydev;
+		if (likely(phydev->drv->rxtstamp))
+			return phydev->drv->rxtstamp(phydev, skb, type);
+		break;
+	default:
+		break;
+	}
+
+	return false;
+}
+
+void __init skb_timestamping_init(void)
+{
+	BUG_ON(sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter)));
+}
diff --git a/net/socket.c b/net/socket.c
index acfa173..b8a03b8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2403,6 +2403,10 @@ static int __init sock_init(void)
 	netfilter_init();
 #endif
 
+#ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
+	skb_timestamping_init();
+#endif
+
 	return 0;
 }
 
-- 
1.7.0.4

