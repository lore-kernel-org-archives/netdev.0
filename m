From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 5/9] net/eipoib: Add ethtool file support
Date: Wed, 18 Jul 2012 19:37:01 +0100
Message-ID: <1342636621.2617.63.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
	 <1342609202-32427-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37340 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755454Ab2GRShF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:37:05 -0400
In-Reply-To: <1342609202-32427-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 13:59 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> Via ethtool the driver describes its version, ABI version, on what PIF
> interface it runs and various statistics.
[...]
> +static const char parent_strings[][ETH_GSTRING_LEN] = {
> +	/* private statistics */
> +	"tx_parent_dropped",
> +	"tx_vif_miss",
> +	"tx_neigh_miss",
> +	"tx_vlan",
> +	"tx_shared",
> +	"tx_proto_errors",
> +	"tx_skb_errors",
> +	"tx_slave_err",
> +
> +	"rx_parent_dropped",
> +	"rx_vif_miss",
> +	"rx_neigh_miss",
> +	"rx_vlan",
> +	"rx_shared",
> +	"rx_proto_errors",
> +	"rx_skb_errors",
> +	"rx_slave_err",
> +#define PORT_STATS_LEN	(8 * 2)
> +};
> +
> +#define PARENT_STATS_LEN (sizeof(parent_strings) / ETH_GSTRING_LEN)
> +
> +static void parent_get_strings(struct net_device *parent_dev,
> +			       uint32_t stringset, uint8_t *data)
> +{
> +	int index = 0, stats_off = 0, i;
> +
> +	if (stringset != ETH_SS_STATS)
> +		return;
> +
> +	for (i = 0; i < PORT_STATS_LEN; i++)
> +		strcpy(data + (index++) * ETH_GSTRING_LEN,
> +		       parent_strings[i + stats_off]);
> +
> +	stats_off += PORT_STATS_LEN;

This is a very longwinded way to write:
	memcpy(data, parent_strings, sizeof(parent_strings));

> +
> +}
> +
> +static void parent_get_ethtool_stats(struct net_device *parent_dev,
> +				     struct ethtool_stats *stats,
> +				     uint64_t *data)
> +{
> +	struct parent *parent = netdev_priv(parent_dev);
> +	int index = 0, i;
> +
> +	read_lock_bh(&parent->lock);
> +
> +	for (i = 0; i < PORT_STATS_LEN; i++)
> +		data[index++] = ((unsigned long *) &parent->port_stats)[i];
> +
> +	read_unlock_bh(&parent->lock);
> +}
> +
> +static int parent_get_sset_count(struct net_device *parent_dev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return PARENT_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
[...]

I get the feeling you've removed some code with unifdef; the result
looks really weird, with PORT_STATS_LEN and PARENT_STATS_LEN used
inconsistently.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
