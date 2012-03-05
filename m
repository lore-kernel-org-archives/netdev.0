From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next v2] net: export netdev_stats_to_stats64
Date: Mon, 05 Mar 2012 06:50:09 -0800
Message-ID: <1330959009.2474.21.camel@edumazet-laptop>
References: <20120305113353.GA12969@Spy32>
	 <1330954326.2474.9.camel@edumazet-laptop>
	 <1330955921.2474.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Junchang Wang <junchangwang@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38834 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932379Ab2CEOuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 09:50:12 -0500
Received: by pbcun15 with SMTP id un15so2854538pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 06:50:11 -0800 (PST)
In-Reply-To: <1330955921.2474.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers use internal netdev stats member to store part of their
stats, yet advertize ndo_get_stats64() to implement some 64bit fields.

Allow them to use netdev_stats_to_stats64() helper to make the copy of
netdev stats before they compute their 64bit counters.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: added the include bit as well, sorry guys.

 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |    9 +++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f1b7d03..4d279c5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2557,6 +2557,8 @@ extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
 extern struct rtnl_link_stats64 *dev_get_stats(struct net_device *dev,
 					       struct rtnl_link_stats64 *storage);
+extern void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
+				    const struct net_device_stats *netdev_stats);
 
 extern int		netdev_max_backlog;
 extern int		netdev_tstamp_prequeue;
diff --git a/net/core/dev.c b/net/core/dev.c
index 763a0ed..5ef3b65 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5834,12 +5834,12 @@ void netdev_run_todo(void)
 /* Convert net_device_stats to rtnl_link_stats64.  They have the same
  * fields in the same order, with only the type differing.
  */
-static void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
-				    const struct net_device_stats *netdev_stats)
+void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
+			     const struct net_device_stats *netdev_stats)
 {
 #if BITS_PER_LONG == 64
-        BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
-        memcpy(stats64, netdev_stats, sizeof(*stats64));
+	BUILD_BUG_ON(sizeof(*stats64) != sizeof(*netdev_stats));
+	memcpy(stats64, netdev_stats, sizeof(*stats64));
 #else
 	size_t i, n = sizeof(*stats64) / sizeof(u64);
 	const unsigned long *src = (const unsigned long *)netdev_stats;
@@ -5851,6 +5851,7 @@ static void netdev_stats_to_stats64(struct rtnl_link_stats64 *stats64,
 		dst[i] = src[i];
 #endif
 }
+EXPORT_SYMBOL(netdev_stats_to_stats64);
 
 /**
  *	dev_get_stats	- get network device statistics
