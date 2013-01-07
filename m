From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH repost] net,wireless: check against default_ethtool_ops
Date: Mon, 7 Jan 2013 11:23:07 +0100
Message-ID: <20130107102307.GA1587@minipsycho.orion>
References: <20130107095548.GA6931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130107095548.GA6931-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mon, Jan 07, 2013 at 10:55:49AM CET, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>Since:
>
>commit 2c60db037034d27f8c636403355d52872da92f81
>Author: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>Date:   Sun Sep 16 09:17:26 2012 +0000
>
>    net: provide a default dev->ethtool_ops
>
>wireless core does not correctly assign ethtool_ops. In order to fix
>the problem, and avoid assigning ethtool_ops on each individual cfg80211
>drivers, we check against default_ethool_ops pointer instead of NULL in
>wireless core.
>
>Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>Acked-by: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
>Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org # 3.7+
>---
>This should go directly through net tree since patch include core
>net specific changes.
>
> include/linux/netdevice.h |    2 ++
> net/core/dev.c            |    3 ++-
> net/wireless/core.c       |    2 +-
> 3 files changed, 5 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index f8eda02..c98e1c3 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -60,6 +60,8 @@ struct wireless_dev;
> #define SET_ETHTOOL_OPS(netdev,ops) \
> 	( (netdev)->ethtool_ops = (ops) )
> 
>+extern const struct ethtool_ops default_ethtool_ops;
>+
> /* hardware address assignment types */
> #define NET_ADDR_PERM		0	/* address is permanent (default) */
> #define NET_ADDR_RANDOM		1	/* address is generated randomly */
>diff --git a/net/core/dev.c b/net/core/dev.c
>index c0946cb..4cd2168 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -6008,7 +6008,8 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
> 	return queue;
> }
> 
>-static const struct ethtool_ops default_ethtool_ops;
>+const struct ethtool_ops default_ethtool_ops;
>+EXPORT_SYMBOL_GPL(default_ethtool_ops);

I think that default_ethtool_ops should stay static. Wouldn't it be
nicer to introduce a helper like:

bool dev_has_default_ethtool_ops(struct net_device *dev)
{
	return dev->ethtool_ops == &default_ethtool_ops;
}

> 
> /**
>  *	alloc_netdev_mqs - allocate network device
>diff --git a/net/wireless/core.c b/net/wireless/core.c
>index 14d9904..90915d4 100644
>--- a/net/wireless/core.c
>+++ b/net/wireless/core.c
>@@ -866,7 +866,7 @@ static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
> 		/* allow mac80211 to determine the timeout */
> 		wdev->ps_timeout = -1;
> 
>-		if (!dev->ethtool_ops)
>+		if (dev->ethtool_ops == &default_ethtool_ops)
> 			dev->ethtool_ops = &cfg80211_ethtool_ops;
> 
> 		if ((wdev->iftype == NL80211_IFTYPE_STATION ||
>-- 
>1.7.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
