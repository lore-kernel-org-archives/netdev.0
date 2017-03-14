From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Subject: [PATCH v5] Enable tx timestamping on loopback and dummy
Date: Tue, 14 Mar 2017 10:59:42 +0000
Message-ID: <20170314105941.GA9827@u480fcf44e5b8574c5490.ant.amazon.com>
References: <20170312215231.GA10928@u480fcf44e5b8574c5490.ant.amazon.com>
 <20170313104006.GC1875@localhost.localdomain>
 <20170313111608.GA21070@u480fcf44e5b8574c5490.ant.amazon.com>
 <20170313.121504.1530815997705662155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6001.amazon.com ([52.95.48.154]:29525 "EHLO
        smtp-fw-6001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750744AbdCNK7r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:59:47 -0400
Content-Disposition: inline
In-Reply-To: <20170313.121504.1530815997705662155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From aafd3312170ed658571ef443675036f96114c2d7 Mon Sep 17 00:00:00 2001
From: Ezequiel Lara Gomez <ezegomez@amazon.com>
Date: Sat, 11 Mar 2017 20:06:54 +0000
Subject: [PATCH v5] Enable tx timestamping on loopback and dummy

This enables developing code that uses SOF_TIMESTAMPING_TX_SOFTWARE
by using localhost addresses (without needing to send packets outside),
as well as enabling unit and functional testing of TX timestamping code
without needing hardware support or network access.

It also fulfills the expectation of software network devices supporting
software-based timestamping.

Tested on qemu using txtimestamping.c from the kernel selftests, and
ethtool -T.

Signed-off-by: Ezequiel Lara Gomez <ezegomez@amazon.com>
---
Changes:
* v2: split styling changes suggested by checkpatch.pl to a separate patch
* v3: added ethtool reporting of tx timestamping support
* v4: clarified on the commit message the reason to introduce this.
* v5: proper signoff of the change. Apologies!

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
