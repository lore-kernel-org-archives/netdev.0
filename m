From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] sit: fix panic with route cache in ip tunnels
Date: Wed, 19 Feb 2014 17:15:32 +0100
Message-ID: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <therbert@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:37348 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbaBSQPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 11:15:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels").

Because sit code does not call ip_tunnel_init(), the dst_cache was not
initialized.

CC: Tom Herbert <therbert@google.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 3dfbcf1dcb1c..5ff33d9bd5de 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1326,6 +1326,9 @@ static const struct net_device_ops ipip6_netdev_ops = {
 
 static void ipip6_dev_free(struct net_device *dev)
 {
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	free_percpu(tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1375,6 +1378,12 @@ static int ipip6_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ipip6_tunnel_stats->syncp);
 	}
 
+	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst);
+	if (!tunnel->dst_cache) {
+		free_percpu(dev->tstats);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 
-- 
1.8.5.4
