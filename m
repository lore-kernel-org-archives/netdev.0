From: Jakub Kicinski <moorray3@wp.pl>
Subject: Re: [PATCH 1/4] ethtool: correctly ensure {GS}CHANNELS doesn't
 conflict with GS{RXFH}
Date: Mon, 8 Feb 2016 20:47:43 +0000
Message-ID: <20160208204743.1ac70f4b@jkicinski-Precision-T1700>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
	<1454961965-15116-2-git-send-email-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:18256 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971AbcBHUrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 15:47:47 -0500
In-Reply-To: <1454961965-15116-2-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Build bot seems upset so let me throw few stones as well.

On Mon,  8 Feb 2016 12:06:02 -0800, Jacob Keller wrote:
>
> +static inline int ethool_get_max_rxfh_channel(struct net_device *dev, u32 *max)

static inline in C sources is frowned upon.

> +	u32 dev_size, current_max = 0;
> +	u32 *indir;
> +	int ret, i;
> +
> +	if (!dev->ethtool_ops->get_rxfh_indir_size ||
> +	    !dev->ethtool_ops->get_rxfh)
> +		return -EOPNOTSUPP;
> +	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
> +	if (dev_size == 0)
> +		return -EOPNOTSUPP;
> +
> +	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
> +	if (!indir)
> +		return -ENOMEM;
> +
> +	ret = dev->ethtool_ops->get_rxfh(dev, indir, NULL, NULL);
> +	if (ret)
> +		goto out;
> +
> +	for (i = dev_size; i--;) {
> +		if (indir[i] > current_max)
> +			current_max = indir[i];
> +	}

Could be

while (dev_size--)
	current_max = max(current_max, indir[dev_size]);

> +	/* ensure the new Rx count fits within the configured Rx flow
> +	 * indirection table settings */
> +	if (netif_is_rxfh_configured(dev) &&
> +	    ethtool_get_max_rxfh_channel(dev, &max_rx) &&
> +	    ((channels.rx_count > max_rx) ||
> +	     (channels.combined_count > max_rx))
> +	    return -EINVAL;
> +
>  	return dev->ethtool_ops->set_channels(dev, &channels);
>  }

The situation with rx_count vs combined count is unclear.  My current
understanding is that

channels.combined_count + channels.rx_count > max_rx

would be the safest way to go.
