From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 6/6] tg3: Make the RSS indir tbl admin
 configurable
Date: Wed, 14 Dec 2011 21:50:59 +0000
Message-ID: <1323899459.2753.19.camel@bwh-desktop>
References: <1323897002-17295-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:58177 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757464Ab1LNVvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 16:51:04 -0500
In-Reply-To: <1323897002-17295-7-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-14 at 13:10 -0800, Matt Carlson wrote:
> This patch adds the ethtool callbacks necessary to change the rss
> indirection table from userspace.  When setting the indirection table
> through set_rxfh_indir, an indirection table size of zero is
> interpreted to mean that the admin wants to relinquish control of the
> table to the driver.

I'm not convinced that this is a particularly useful option, but I won't
object.  But please document this as an optional driver behaviour in
<linux/ethtool.h>, and add support for this in the ethtool command (e.g.
a 'reset' or 'default' keyword).

> Should the number of interrupts change (e.g.
> across a close / open call, or through a reset), any indirection table
> values that exceed the number of RSS queues or interrupt vectors will
> be automatically scaled back to values within range.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |  128 ++++++++++++++++++++++++++++++++++-
>  drivers/net/ethernet/broadcom/tg3.h |    1 +
>  2 files changed, 128 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index 8bf11ca..f684be9 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -8229,9 +8229,18 @@ void tg3_rss_init_indir_tbl(struct tg3 *tp)
>  
>  	if (tp->irq_cnt <= 2)
>  		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
> -	else
> +	else if (tg3_flag(tp, USER_INDIR_TBL)) {
> +		/* Validate table against current IRQ count */
> +		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
> +			if (tp->rss_ind_tbl[i] >= tp->irq_cnt - 1) {
> +				/* Cap the vector index */
> +				tp->rss_ind_tbl[i] = tp->irq_cnt - 2;

A modulo operation might make more sense.  But I don't suppose this
failure is going to happen often enough for it to be important.

> +			}
> +		}
> +	} else {
>  		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
>  			tp->rss_ind_tbl[i] = i % (tp->irq_cnt - 1);
> +	}
>  }
>  
>  void tg3_rss_write_indir_tbl(struct tg3 *tp)
> @@ -10719,6 +10728,120 @@ static int tg3_get_sset_count(struct net_device *dev, int sset)
>  	}
>  }
>  
> +static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
> +			 u32 *rules __always_unused)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +
> +	if (!tg3_flag(tp, SUPPORT_MSIX))
> +		return -EINVAL;

Should be -EOPNOTSUPP.

> +	if (!netif_running(tp->dev))
> +		return -EAGAIN;

Why?  You do handle !netif_running() below...

> +	switch (info->cmd) {
> +	case ETHTOOL_GRXRINGS:
> +		if (netif_running(tp->dev))
> +			info->data = tp->irq_cnt;
> +		else {
> +			info->data = num_online_cpus();
> +			if (info->data > TG3_IRQ_MAX_VECS_RSS)
> +				info->data = TG3_IRQ_MAX_VECS_RSS;
> +		}
> +
> +		/* The first interrupt vector only
> +		 * handles link interrupts.
> +		 */
> +		info->data -= 1;
> +		return 0;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static int tg3_get_rxfh_indir(struct net_device *dev,
> +			      struct ethtool_rxfh_indir *indir)
> +{
> +	struct tg3 *tp = netdev_priv(dev);
> +	int i;
> +
> +	if (!tg3_flag(tp, SUPPORT_MSIX))
> +		return -EINVAL;

-EOPNOTSUPP

> +	if (!indir->size) {
> +		indir->size = TG3_RSS_INDIR_TBL_SIZE;
> +		return 0;
> +	}
> +
> +	if (indir->size != TG3_RSS_INDIR_TBL_SIZE)
> +		return -EINVAL;

This is enough to make the ethtool command work, but you're really
supposed to copy min(indir->size, TG3_RSS_INDIR_TBL_SIZE) entries.

> +	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> +		indir->ring_index[i] = tp->rss_ind_tbl[i];
> +
> +	return 0;
> +}
> +
> +static int tg3_set_rxfh_indir(struct net_device *dev,
> +			      const struct ethtool_rxfh_indir *indir)
> +{
[...]

This function looks fine.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
