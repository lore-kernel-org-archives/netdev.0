From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v7 2/6] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Fri, 16 Nov 2012 23:04:12 +0000
Message-ID: <1353107052.2743.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
	 <1352905010-24172-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61893 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab2KPXEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 18:04:16 -0500
In-Reply-To: <1352905010-24172-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-14 at 15:56 +0100, Thomas Petazzoni wrote:
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/marvell/mvneta.c
[...]
> +/* Set interrupt coalescing for ethtools */
> +static int mvneta_ethtool_set_coalesce(struct net_device *dev,
> +				       struct ethtool_coalesce *c)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +	int queue;
> +
> +	for (queue = 0; queue < rxq_number; queue++) {
> +		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
> +		rxq->time_coal = c->rx_coalesce_usecs;
> +		rxq->pkts_coal = c->rx_max_coalesced_frames;
> +		mvneta_rx_pkts_coal_set(pp, rxq, rxq->pkts_coal);
> +		mvneta_rx_time_coal_set(pp, rxq, rxq->time_coal);
> +	}

Please check that c->rx_coalesce_usecs || c->rx_max_coalesced_frames
(see the comments in <linux/ethtool.h>).  Also please check that the
other fields, up to and including use_adaptive_tx_coalesce, are all set
to 0.

> +	for (queue = 0; queue < txq_number; queue++) {
> +		struct mvneta_tx_queue *txq = &pp->txqs[queue];
> +		txq->done_pkts_coal = c->tx_max_coalesced_frames;
> +		mvneta_tx_done_pkts_coal_set(pp, txq, txq->done_pkts_coal);
> +	}
> +
> +	return 0;
> +}
[...]
> +static int mvneta_ethtool_set_ringparam(struct net_device *dev,
> +					struct ethtool_ringparam *ring)
> +{
> +	struct mvneta_port *pp = netdev_priv(dev);
> +
> +	if ((ring->rx_pending == 0) || (ring->tx_pending == 0))
> +		return -EINVAL;

Please check that the other fields are all set to 0.

> +	pp->rx_ring_size = ring->rx_pending < MVNETA_MAX_RXD ?
> +		ring->rx_pending : MVNETA_MAX_RXD;
> +	pp->tx_ring_size = ring->tx_pending < MVNETA_MAX_TXD ?
> +		ring->tx_pending : MVNETA_MAX_TXD;
> +
> +	if (netif_running(dev)) {
> +		mvneta_stop(dev);
> +		if (mvneta_open(dev)) {
> +			netdev_err(dev,
> +				   "error on opening device after ring param change\n");
> +			return -ENOMEM;
> +		}

This is nasty because the stack will still considers the interface to be
up.  Ideally you would hold onto the old rings and revert to using them
in case of failure.  If that's not possible then use dev_close() and
dev_open() so that the stack knows the interface didn't come up again.

Ben.

> +	}
> +
> +	return 0;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
