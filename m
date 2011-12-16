From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: Make the RSS indir tbl admin configurable
Date: Fri, 16 Dec 2011 11:19:27 -0800
Message-ID: <20111216191927.GA9054@mcarlson.broadcom.com>
References: <1323996466-8139-1-git-send-email-mcarlson@broadcom.com>
 <1324004674.2825.226.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2111 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202Ab1LPTTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 14:19:13 -0500
In-Reply-To: <1324004674.2825.226.camel@deadeye>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2011 at 07:04:34PM -0800, Ben Hutchings wrote:
> On Thu, 2011-12-15 at 16:47 -0800, Matt Carlson wrote:
> > This patch adds the ethtool callbacks necessary to change the rss
> > indirection table from userspace.  When setting the indirection table
> > through set_rxfh_indir, an indirection table size of zero is
> > interpreted to mean that the admin wants to relinquish control of the
> > table to the driver.  Should the number of interrupts change (e.g.
> > across a close / open call, or through a reset), any indirection table
> > values that exceed the number of RSS queues or interrupt vectors will
> > be automatically scaled back to values within range.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> No I didn't!
> 
> Ben.

Sorry.  This part of procedure I'm unsure about.  I didn't want to lose
the ack of your contributions to this patch.  The SOB does imply that
you are O.K. with it as-is though, which you may or may not be aligned
with.  I apologize if I was putting words in your mouth.

What should I have done instead?  Would Dave put the SOB on your behalf
as he accepts it?

> > Reviewed-by: Benjamin Li <benli@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c |  126 ++++++++++++++++++++++++++++++++++-
> >  drivers/net/ethernet/broadcom/tg3.h |    1 +
> >  2 files changed, 126 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index 8bf11ca..87f70f6 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -8229,9 +8229,19 @@ void tg3_rss_init_indir_tbl(struct tg3 *tp)
> >  
> >  	if (tp->irq_cnt <= 2)
> >  		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
> > -	else
> > +	else if (tg3_flag(tp, USER_INDIR_TBL)) {
> > +		/* Validate table against current IRQ count */
> > +		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
> > +			if (tp->rss_ind_tbl[i] >= tp->irq_cnt - 1) {
> > +				/* Bring the index within range */
> > +				tp->rss_ind_tbl[i] = tp->rss_ind_tbl[i] %
> > +						     (tp->irq_cnt - 1);
> > +			}
> > +		}
> > +	} else {
> >  		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> >  			tp->rss_ind_tbl[i] = i % (tp->irq_cnt - 1);
> > +	}
> >  }
> >  
> >  void tg3_rss_write_indir_tbl(struct tg3 *tp)
> > @@ -10719,6 +10729,117 @@ static int tg3_get_sset_count(struct net_device *dev, int sset)
> >  	}
> >  }
> >  
> > +static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
> > +			 u32 *rules __always_unused)
> > +{
> > +	struct tg3 *tp = netdev_priv(dev);
> > +
> > +	if (!tg3_flag(tp, SUPPORT_MSIX))
> > +		return -EOPNOTSUPP;
> > +
> > +	switch (info->cmd) {
> > +	case ETHTOOL_GRXRINGS:
> > +		if (netif_running(tp->dev))
> > +			info->data = tp->irq_cnt;
> > +		else {
> > +			info->data = num_online_cpus();
> > +			if (info->data > TG3_IRQ_MAX_VECS_RSS)
> > +				info->data = TG3_IRQ_MAX_VECS_RSS;
> > +		}
> > +
> > +		/* The first interrupt vector only
> > +		 * handles link interrupts.
> > +		 */
> > +		info->data -= 1;
> > +		return 0;
> > +
> > +	default:
> > +		return -EOPNOTSUPP;
> > +	}
> > +}
> > +
> > +static int tg3_get_rxfh_indir(struct net_device *dev,
> > +			      struct ethtool_rxfh_indir *indir)
> > +{
> > +	struct tg3 *tp = netdev_priv(dev);
> > +	int i;
> > +
> > +	if (!tg3_flag(tp, SUPPORT_MSIX))
> > +		return -EOPNOTSUPP;
> > +
> > +	if (!indir->size) {
> > +		indir->size = TG3_RSS_INDIR_TBL_SIZE;
> > +		return 0;
> > +	}
> > +
> > +	if (indir->size != TG3_RSS_INDIR_TBL_SIZE)
> > +		return -EINVAL;
> > +
> > +	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> > +		indir->ring_index[i] = tp->rss_ind_tbl[i];
> > +
> > +	return 0;
> > +}
> > +
> > +static int tg3_set_rxfh_indir(struct net_device *dev,
> > +			      const struct ethtool_rxfh_indir *indir)
> > +{
> > +	struct tg3 *tp = netdev_priv(dev);
> > +	size_t i;
> > +
> > +	if (!tg3_flag(tp, SUPPORT_MSIX))
> > +		return -EOPNOTSUPP;
> > +
> > +	if (!indir->size) {
> > +		tg3_flag_clear(tp, USER_INDIR_TBL);
> > +		tg3_rss_init_indir_tbl(tp);
> > +	} else {
> > +		int limit;
> > +
> > +		/* Validate size and indices */
> > +		if (indir->size != TG3_RSS_INDIR_TBL_SIZE)
> > +			return -EINVAL;
> > +
> > +		if (netif_running(dev))
> > +			limit = tp->irq_cnt;
> > +		else {
> > +			limit = num_online_cpus();
> > +			if (limit > TG3_IRQ_MAX_VECS_RSS)
> > +				limit = TG3_IRQ_MAX_VECS_RSS;
> > +		}
> > +
> > +		/* The first interrupt vector only
> > +		 * handles link interrupts.
> > +		 */
> > +		limit -= 1;
> > +
> > +		/* Check the indices in the table.
> > +		 * Leave the existing table unmodified
> > +		 * if an error is detected.
> > +		 */
> > +		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> > +			if (indir->ring_index[i] >= limit)
> > +				return -EINVAL;
> > +
> > +		tg3_flag_set(tp, USER_INDIR_TBL);
> > +
> > +		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> > +			tp->rss_ind_tbl[i] = indir->ring_index[i];
> > +	}
> > +
> > +	if (!netif_running(dev) || !tg3_flag(tp, ENABLE_RSS))
> > +		return 0;
> > +
> > +	/* It is legal to write the indirection
> > +	 * table while the device is running.
> > +	 */
> > +	tg3_full_lock(tp, 0);
> > +	tg3_rss_write_indir_tbl(tp);
> > +	tg3_full_unlock(tp);
> > +
> > +	return 0;
> > +}
> > +
> >  static void tg3_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
> >  {
> >  	switch (stringset) {
> > @@ -11949,6 +12070,9 @@ static const struct ethtool_ops tg3_ethtool_ops = {
> >  	.get_coalesce		= tg3_get_coalesce,
> >  	.set_coalesce		= tg3_set_coalesce,
> >  	.get_sset_count		= tg3_get_sset_count,
> > +	.get_rxnfc		= tg3_get_rxnfc,
> > +	.get_rxfh_indir		= tg3_get_rxfh_indir,
> > +	.set_rxfh_indir		= tg3_set_rxfh_indir,
> >  };
> >  
> >  static void __devinit tg3_get_eeprom_size(struct tg3 *tp)
> > diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
> > index aea8f72..4800595 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.h
> > +++ b/drivers/net/ethernet/broadcom/tg3.h
> > @@ -2932,6 +2932,7 @@ enum TG3_FLAGS {
> >  	TG3_FLAG_APE_HAS_NCSI,
> >  	TG3_FLAG_4K_FIFO_LIMIT,
> >  	TG3_FLAG_RESET_TASK_PENDING,
> > +	TG3_FLAG_USER_INDIR_TBL,
> >  	TG3_FLAG_5705_PLUS,
> >  	TG3_FLAG_IS_5788,
> >  	TG3_FLAG_5750_PLUS,
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
