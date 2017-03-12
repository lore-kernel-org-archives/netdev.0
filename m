From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Subject: [PATCH v3] Enable tx timestamping on loopback and dummy
Date: Sun, 12 Mar 2017 21:52:32 +0000
Message-ID: <20170312215231.GA10928@u480fcf44e5b8574c5490.ant.amazon.com>
References: <20170311144224.GA21305@u480fcf44e5b8574c5490.ant.amazon.com>
 <13e4b635-089d-fb4b-4d73-62b807bb86e8@hartkopp.net>
 <20170312163000.GA1649@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:14459 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935498AbdCLVwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 17:52:33 -0400
Content-Disposition: inline
In-Reply-To: <20170312163000.GA1649@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From f3483202625648be728df39622360508f2fb03e1 Mon Sep 17 00:00:00 2001
From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Date: Sat, 11 Mar 2017 20:06:54 +0000
Subject: [PATCH v3] Enable tx timestamping on loopback and dummy

This enables testing of SO_TIMESTAMPING options by targetting localhost
addresses.

Tested on qemu using txtimestamping.c from the kernel selftests, and
ethtool -T.
---
Changes:
 * Added ethtool flags to both drivers to report they support timestamping.

 drivers/net/dummy.c    | 15 +++++++++++++++
 drivers/net/loopback.c | 15 +++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 2c80611..149244a 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/moduleparam.h>
 #include <linux/rtnetlink.h>
+#include <linux/net_tstamp.h>
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
 
@@ -125,6 +126,7 @@ static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	dstats->tx_bytes += skb->len;
 	u64_stats_update_end(&dstats->syncp);
 
+	skb_tx_timestamp(skb);
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
 }
@@ -304,8 +306,21 @@ static void dummy_get_drvinfo(struct net_device *dev,
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 }
 
+static int dummy_get_ts_info(struct net_device *dev,
+			      struct ethtool_ts_info *ts_info)
+{
+	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				   SOF_TIMESTAMPING_RX_SOFTWARE |
+				   SOF_TIMESTAMPING_SOFTWARE;
+
+	ts_info->phc_index = -1;
+
+	return 0;
+};
+
 static const struct ethtool_ops dummy_ethtool_ops = {
 	.get_drvinfo            = dummy_get_drvinfo,
+	.get_ts_info		= dummy_get_ts_info,
 };
 
 static void dummy_free_netdev(struct net_device *dev)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 122cc2d..3a60d27 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -55,6 +55,7 @@
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/percpu.h>
+#include <linux/net_tstamp.h>
 #include <net/net_namespace.h>
 #include <linux/u64_stats_sync.h>
 
@@ -74,6 +75,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	struct pcpu_lstats *lb_stats;
 	int len;
 
+	skb_tx_timestamp(skb);
 	skb_orphan(skb);
 
 	/* Before queueing this packet to netif_rx(),
@@ -129,8 +131,21 @@ static u32 always_on(struct net_device *dev)
 	return 1;
 }
 
+static int loopback_get_ts_info(struct net_device *netdev,
+				struct ethtool_ts_info *ts_info)
+{
+	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				   SOF_TIMESTAMPING_RX_SOFTWARE |
+				   SOF_TIMESTAMPING_SOFTWARE;
+
+	ts_info->phc_index = -1;
+
+	return 0;
+};
+
 static const struct ethtool_ops loopback_ethtool_ops = {
 	.get_link		= always_on,
+	.get_ts_info		= loopback_get_ts_info,
 };
 
 static int loopback_dev_init(struct net_device *dev)
-- 
1.9.1

Amazon Data Services Ireland Limited registered office: One Burlington Plaza, Burlington Road, Dublin 4, Ireland. Registered in Ireland. Registration number 390566.
