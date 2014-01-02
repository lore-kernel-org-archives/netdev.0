From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 4/5] alx: add alx_get_stats operation
Date: Thu, 2 Jan 2014 17:05:31 +0100
Message-ID: <20140102160531.GA25216@kria>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
 <1388619628-3373-5-git-send-email-sd@queasysnail.net>
 <20140101.222702.1562824655053158808.davem@davemloft.net>
 <1388663813.22017.12.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:41784 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbaABQFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 11:05:45 -0500
Content-Disposition: inline
In-Reply-To: <1388663813.22017.12.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2014-01-02, 11:56:53] Ben Hutchings wrote:
> On Wed, 2014-01-01 at 22:27 -0500, David Miller wrote:
> > From: Sabrina Dubroca <sd@queasysnail.net>
> > Date: Thu,  2 Jan 2014 00:40:27 +0100
> > 
> > > +	spin_lock(&alx->stats_lock);
> > > +
> > > +	__alx_update_hw_stats(&alx->hw);
> > 
> > Please use something like the linux/u64_stats_sync.h stuff rather
> > than spin locking.
> 
> I don't think that'sa useful, as we can have multiple writers
> (concurrent calls to get_stats).  And there is really no harm in using a
> spinlock to serialise get_stats calls.  The u64_stats API is good for
> statistics updated from the data path.

I've read the comments in linux/u64_stats_sync.h, which mentions the
need for exclusive access to the data. I've looked at other drivers
(broadcom/b44.c, nvidia/forcedeth.c) that use the u64_stats functions
to get stats from hardware, and they use a spin_lock around the update
code. The other drivers that I've looked at and that use u64_stats
have software stats that they update on rx/tx, so I think the
situation is a bit different.


For now I've added u64_stats and modified the functions this way:

static struct net_device_stats *alx_get_stats(struct net_device *netdev)
{
	struct alx_priv *alx = netdev_priv(netdev);
	struct net_device_stats *net_stats = &netdev->stats;
	struct alx_hw_stats *hw_stats = &alx->hw.stats;

	unsigned int start;

	spin_lock(&alx->stats_lock);

	__alx_update_hw_stats(&alx->hw);

	spin_unlock(&alx->stats_lock);

	do {
		start = u64_stats_fetch_begin(&hw_stats->syncp);
		/* fill net_stat... */
	} while (u64_stats_fetch_retry(&hw_stats->syncp, start));

	return net_stats;
}


void __alx_update_hw_stats(struct alx_hw *hw)
{
	u64_stats_update_begin(&hw->stats.syncp);

	/* fill hw->stats */

	u64_stats_update_end(&hw->stats.syncp);
}


static void alx_get_ethtool_stats(struct net_device *netdev,
				  struct ethtool_stats *estats, u64 *data)
{
	struct alx_priv *alx = netdev_priv(netdev);
	struct alx_hw *hw = &alx->hw;

	unsigned int start;

	spin_lock(&alx->stats_lock);
	__alx_update_hw_stats(hw);
	spin_unlock(&alx->stats_lock);

	do {
		start = u64_stats_fetch_begin(&hw->stats.syncp);
		memcpy(data, &hw->stats, sizeof(hw->stats));
	} while (u64_stats_fetch_retry(&hw->stats.syncp, start));
}

Thanks,

-- 
Sabrina Dubroca
