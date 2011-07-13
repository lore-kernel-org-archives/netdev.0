From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] be2net: account for skb allocation failures
Date: Wed, 13 Jul 2011 03:31:43 +0200
Message-ID: <1310520703.2634.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46253 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467Ab1GMBbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 21:31:47 -0400
Received: by wwe5 with SMTP id 5so5485955wwe.1
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 18:31:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we cannot allocate new skbs in RX completion handler, we should
increase netdevice rx_dropped counter, not spam console messages.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Ajit Khaparde <ajit.khaparde@emulex.com>
---
Note: This driver uses u64 fields without proper synch on 32bit arches.

 drivers/net/benet/be.h         |    1 +
 drivers/net/benet/be_ethtool.c |    1 +
 drivers/net/benet/be_main.c    |    4 ++--
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 9aa1534..72ec00f 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -199,6 +199,7 @@ struct be_rx_stats {
 	u32 rx_polls;	/* number of times NAPI called poll function */
 	u32 rx_events;	/* number of ucast rx completion events  */
 	u32 rx_compl;	/* number of rx completion entries processed */
+	ulong rx_dropped; /* number of skb allocation errors */
 	ulong rx_jiffies;
 	u64 rx_bytes;
 	u64 rx_bytes_prev;
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 30c1386..7fd8130 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -102,6 +102,7 @@ static const struct be_ethtool_stat et_rx_stats[] = {
 	{DRVSTAT_RX_INFO(rx_compl)},
 	{DRVSTAT_RX_INFO(rx_mcast_pkts)},
 	{DRVSTAT_RX_INFO(rx_post_fail)},
+	{DRVSTAT_RX_INFO(rx_dropped)},
 	{ERXSTAT_INFO(rx_drops_no_fragments)}
 };
 #define ETHTOOL_RXSTATS_NUM (ARRAY_SIZE(et_rx_stats))
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 4ebd700..f7d6d9d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -431,6 +431,7 @@ void netdev_stats_update(struct be_adapter *adapter)
 		pkts += rx_stats(rxo)->rx_pkts;
 		bytes += rx_stats(rxo)->rx_bytes;
 		mcast += rx_stats(rxo)->rx_mcast_pkts;
+		drops += rx_stats(rxo)->rx_dropped;
 		/*  no space in linux buffers: best possible approximation */
 		if (adapter->generation == BE_GEN3) {
 			if (!(lancer_chip(adapter))) {
@@ -1181,8 +1182,7 @@ static void be_rx_compl_process(struct be_adapter *adapter,
 
 	skb = netdev_alloc_skb_ip_align(netdev, BE_HDR_LEN);
 	if (unlikely(!skb)) {
-		if (net_ratelimit())
-			dev_warn(&adapter->pdev->dev, "skb alloc failed\n");
+		rxo->stats.rx_dropped++;
 		be_rx_compl_discard(adapter, rxo, rxcp);
 		return;
 	}


