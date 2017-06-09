From: Dominik Heidler <dheidler@suse.de>
Subject: [PATCH] l2tp: cast l2tp traffic counter to unsigned
Date: Fri,  9 Jun 2017 16:29:47 +0200
Message-ID: <20170609142947.16969-1-dheidler@suse.de>
Cc: Dominik Heidler <dheidler@suse.de>,
        Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46430 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751534AbdFIObq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:31:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a counter problem on 32bit systems:
When the rx_bytes counter reached 2 GiB, it jumpd to (2^64 Bytes - 2GiB) Bytes.

rtnl_link_stats64 has __u64 type and atomic_long_read returns
atomic_long_t which is signed. Due to the conversation
we get an incorrect value on 32bit systems if the MSB of
the atomic_long_t value is set.

CC: Tom Parkin <tparkin@katalix.com>
Fixes: 7b7c0719cd7a ("l2tp: avoid deadlock in l2tp stats update")
Signed-off-by: Dominik Heidler <dheidler@suse.de>
---
 net/l2tp/l2tp_eth.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 8b21af7321b9..668a75e002e9 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -114,12 +114,13 @@ static void l2tp_eth_get_stats64(struct net_device *dev,
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
 
-	stats->tx_bytes   = atomic_long_read(&priv->tx_bytes);
-	stats->tx_packets = atomic_long_read(&priv->tx_packets);
-	stats->tx_dropped = atomic_long_read(&priv->tx_dropped);
-	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
-	stats->rx_packets = atomic_long_read(&priv->rx_packets);
-	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
+	stats->tx_bytes   = (unsigned long) atomic_long_read(&priv->tx_bytes);
+	stats->tx_packets = (unsigned long) atomic_long_read(&priv->tx_packets);
+	stats->tx_dropped = (unsigned long) atomic_long_read(&priv->tx_dropped);
+	stats->rx_bytes   = (unsigned long) atomic_long_read(&priv->rx_bytes);
+	stats->rx_packets = (unsigned long) atomic_long_read(&priv->rx_packets);
+	stats->rx_errors  = (unsigned long) atomic_long_read(&priv->rx_errors);
+
 }
 
 static const struct net_device_ops l2tp_eth_netdev_ops = {
-- 
2.13.0
