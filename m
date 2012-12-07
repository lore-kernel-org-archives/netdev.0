From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC] wireless: check against default_ethtool_ops
Date: Fri, 7 Dec 2012 13:16:19 +0100
Message-ID: <20121207121617.GA4356@redhat.com>
References: <1354729192-22945-1-git-send-email-greearb@candelatech.com>
 <87a9ts4c1q.fsf@nemi.mork.no>
 <50BF8C18.9060504@candelatech.com>
 <20121206122528.GG2502@redhat.com>
 <50C0FCE0.2090507@candelatech.com>
 <20121207095012.GB11933@redhat.com>
 <87zk1q3xrv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	linux-wireless@vger.kernel.org,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933768Ab2LGMQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 07:16:27 -0500
Content-Disposition: inline
In-Reply-To: <87zk1q3xrv.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since:

commit 2c60db037034d27f8c636403355d52872da92f81
Author: Eric Dumazet <edumazet@google.com>
Date:   Sun Sep 16 09:17:26 2012 +0000

    net: provide a default dev->ethtool_ops

wireless core does not correctly assign ethtool_ops. In order to fix
the problem, and avoid assigning ethtool_ops on each individual cfg80211
driver, we check against default_ethool_ops pointer instead of NULL in
wireless core.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |    3 ++-
 net/wireless/core.c       |    2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8eda02..c98e1c3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,6 +60,8 @@ struct wireless_dev;
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
 
+extern const struct ethtool_ops default_ethtool_ops;
+
 /* hardware address assignment types */
 #define NET_ADDR_PERM		0	/* address is permanent (default) */
 #define NET_ADDR_RANDOM		1	/* address is generated randomly */
diff --git a/net/core/dev.c b/net/core/dev.c
index c0946cb..4cd2168 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6008,7 +6008,8 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 	return queue;
 }
 
-static const struct ethtool_ops default_ethtool_ops;
+const struct ethtool_ops default_ethtool_ops;
+EXPORT_SYMBOL_GPL(default_ethtool_ops);
 
 /**
  *	alloc_netdev_mqs - allocate network device
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 14d9904..90915d4 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -866,7 +866,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		/* allow mac80211 to determine the timeout */
 		wdev->ps_timeout = -1;
 
-		if (!dev->ethtool_ops)
+		if (dev->ethtool_ops == &default_ethtool_ops)
 			dev->ethtool_ops = &cfg80211_ethtool_ops;
 
 		if ((wdev->iftype == NL80211_IFTYPE_STATION ||
-- 
1.7.1
