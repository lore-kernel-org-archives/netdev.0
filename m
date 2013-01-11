From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH v3] net, wireless: overwrite default_ethtool_ops
Date: Fri, 11 Jan 2013 10:19:10 +0100
Message-ID: <20130111091909.GA2347@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-wireless@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab3AKJTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 04:19:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since:

commit 2c60db037034d27f8c636403355d52872da92f81
Author: Eric Dumazet <edumazet@google.com>
Date:   Sun Sep 16 09:17:26 2012 +0000

    net: provide a default dev->ethtool_ops

wireless core does not correctly assign ethtool_ops.

After alloc_netdev*() call, some cfg80211 drivers provide they own
ethtool_ops, but some do not. For them, wireless core provide generic
cfg80211_ethtool_ops, which is assigned in NETDEV_REGISTER notify call:

        if (!dev->ethtool_ops)
                dev->ethtool_ops = &cfg80211_ethtool_ops;

But after Eric's commit, dev->ethtool_ops is no longer NULL (on cfg80211
drivers without custom ethtool_ops), but points to &default_ethtool_ops.

In order to fix the problem, provide function which will overwrite
default_ethtool_ops and use it by wireless core.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
v1 -> v2: change order of default_ethtool_ops initialization to avoid
the problem. Change the subject accordingly.

v2 -> v3: provide function to overwrite default_ethtool_ops, describe
problem a bit more detailed in the changelog

 include/linux/netdevice.h |    3 +++
 net/core/dev.c            |    8 ++++++++
 net/wireless/core.c       |    3 +--
 3 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c599e47..9ef07d0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,6 +60,9 @@ struct wireless_dev;
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
 
+extern void netdev_set_default_ethtool_ops(struct net_device *dev,
+					   const struct ethtool_ops *ops);
+
 /* hardware address assignment types */
 #define NET_ADDR_PERM		0	/* address is permanent (default) */
 #define NET_ADDR_RANDOM		1	/* address is generated randomly */
diff --git a/net/core/dev.c b/net/core/dev.c
index 515473e..f64e439 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6121,6 +6121,14 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 
 static const struct ethtool_ops default_ethtool_ops;
 
+void netdev_set_default_ethtool_ops(struct net_device *dev,
+				    const struct ethtool_ops *ops)
+{
+	if (dev->ethtool_ops == &default_ethtool_ops)
+		dev->ethtool_ops = ops;
+}
+EXPORT_SYMBOL_GPL(netdev_set_default_ethtool_ops);
+
 /**
  *	alloc_netdev_mqs - allocate network device
  *	@sizeof_priv:	size of private data to allocate space for
diff --git a/net/wireless/core.c b/net/wireless/core.c
index 747dd93..7cbd3bf 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -858,8 +858,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
 		/* allow mac80211 to determine the timeout */
 		wdev->ps_timeout = -1;
 
-		if (!dev->ethtool_ops)
-			dev->ethtool_ops = &cfg80211_ethtool_ops;
+		netdev_set_default_ethtool_ops(dev, &cfg80211_ethtool_ops);
 
 		if ((wdev->iftype == NL80211_IFTYPE_STATION ||
 		     wdev->iftype == NL80211_IFTYPE_P2P_CLIENT ||
-- 
1.7.1
