From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH 5/5] alx: add stats to ethtool
Date: Thu, 2 Jan 2014 19:19:15 +0100
Message-ID: <20140102181915.GB25216@kria>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
 <1388619628-3373-6-git-send-email-sd@queasysnail.net>
 <1388668154.4326.1.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:39325 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750993AbaABST0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 13:19:26 -0500
Content-Disposition: inline
In-Reply-To: <1388668154.4326.1.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2014-01-02, 14:09:14] Johannes Berg wrote:
> On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:
> 
> > +static const char alx_gstrings_stats[][ETH_GSTRING_LEN] = {
> 
> You should probably have a comment here and on the stats struct
> declaration that they must absolutely match in order/size/etc.


With these comments, and something similar before
__alx_update_hw_stats, should I use the code for __alx_update_hw_stats
mentionned in mail 0?


/* Statistics counters collected by the MAC
 *
 * The order of the fields must match the strings in alx_gstrings_stats
 * See ethtool.c
 */
struct alx_hw_stats {
	/* ... */
}

/* The order of these strings must match the order of the fields in
 * struct alx_hw_stats
 * See hw.h
 */
static const char alx_gstrings_stats[][ETH_GSTRING_LEN] = {
	/* ... */
}



> Maybe try to put in some BUILD_BUG_ON() as well, at least checking the
> sizeof() vs. ARRAY_SIZE*sizeof(u64) - that might already have caught the
> bug that Ben pointed out.


static void alx_get_ethtool_stats(struct net_device *netdev,
				  struct ethtool_stats *estats, u64 *data)
{
	struct alx_priv *alx = netdev_priv(netdev);
	struct alx_hw *hw = &alx->hw;

	spin_lock(&alx->stats_lock);

	__alx_update_hw_stats(hw);
	BUILD_BUG_ON(sizeof(hw->stats) - offsetof(struct alx_hw_stats, rx_ok) <
		     ALX_NUM_STATS * sizeof(u64));
	memcpy(data, &hw->stats.rx_ok, ALX_NUM_STATS * sizeof(u64));

	spin_unlock(&alx->stats_lock);
}

This way, rx_ok doesn't need to come first in struct alx_hw_stats, and
the size of the structure is checked as you said.



> > +	"rx_packets",
> 
> Is it useful to provide stats that are already elsewhere? Then again, it
> doesn't really hurt and simplifies the code ...

You're right, rx_packets is the sum of all the rx_SIZE_RANGE_packets
and is redundant information. The values split by size range are only
for ethtool. ndo_get_stats(64) uses only the sum. I think this
information is more relevant to the user, and anyway, it's available,
so we might as well provide it.


Thanks,

-- 
Sabrina Dubroca
