From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 4/5] netvsc: enable GRO
Date: Mon, 27 Feb 2017 10:26:50 -0800
Message-ID: <20170227182651.3956-5-sthemmin@microsoft.com>
References: <20170227182651.3956-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34380 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdB0S56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:57:58 -0500
Received: by mail-pf0-f172.google.com with SMTP id p185so10118063pfb.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:56:49 -0800 (PST)
In-Reply-To: <20170227182651.3956-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use GRO when receiving packets.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 54b6cab5af23..6dcd1f08b834 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -642,11 +642,11 @@ int netvsc_recv_callback(struct net_device *net,
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct netvsc_device *net_device = net_device_ctx->nvdev;
+	u16 q_idx = channel->offermsg.offer.sub_channel_index;
+	struct netvsc_channel *nvchan = &net_device->chan_table[q_idx];
 	struct net_device *vf_netdev;
 	struct sk_buff *skb;
 	struct netvsc_stats *rx_stats;
-	u16 q_idx = channel->offermsg.offer.sub_channel_index;
-
 
 	if (net->reg_state != NETREG_REGISTERED)
 		return NVSP_STAT_FAIL;
@@ -679,7 +679,7 @@ int netvsc_recv_callback(struct net_device *net,
 	 * on the synthetic device because modifying the VF device
 	 * statistics will not work correctly.
 	 */
-	rx_stats = &net_device->chan_table[q_idx].rx_stats;
+	rx_stats = &nvchan->rx_stats;
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->packets++;
 	rx_stats->bytes += len;
@@ -690,7 +690,7 @@ int netvsc_recv_callback(struct net_device *net,
 		++rx_stats->multicast;
 	u64_stats_update_end(&rx_stats->syncp);
 
-	netif_receive_skb(skb);
+	napi_gro_receive(&nvchan->napi, skb);
 	rcu_read_unlock();
 
 	return 0;
-- 
2.11.0
