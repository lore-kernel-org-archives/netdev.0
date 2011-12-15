From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-next 6/6] tg3: Make the RSS indir tbl admin
 configurable
Date: Thu, 15 Dec 2011 13:03:08 -0800
Message-ID: <20111215210308.GA7025@mcarlson.broadcom.com>
References: <1323897002-17295-7-git-send-email-mcarlson@broadcom.com>
 <1323899459.2753.19.camel@bwh-desktop>
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
Received: from mms2.broadcom.com ([216.31.210.18]:4784 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759225Ab1LOVC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Dec 2011 16:02:59 -0500
In-Reply-To: <1323899459.2753.19.camel@bwh-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2011 at 01:50:59PM -0800, Ben Hutchings wrote:
> On Wed, 2011-12-14 at 13:10 -0800, Matt Carlson wrote:
> > This patch adds the ethtool callbacks necessary to change the rss
> > indirection table from userspace.  When setting the indirection table
> > through set_rxfh_indir, an indirection table size of zero is
> > interpreted to mean that the admin wants to relinquish control of the
> > table to the driver.
> 
> I'm not convinced that this is a particularly useful option, but I won't
> object.  But please document this as an optional driver behaviour in
> <linux/ethtool.h>, and add support for this in the ethtool command (e.g.
> a 'reset' or 'default' keyword).

Will do.

> > Should the number of interrupts change (e.g.
> > across a close / open call, or through a reset), any indirection table
> > values that exceed the number of RSS queues or interrupt vectors will
> > be automatically scaled back to values within range.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Reviewed-by: Benjamin Li <benli@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/tg3.c |  128 ++++++++++++++++++++++++++++++++++-
> >  drivers/net/ethernet/broadcom/tg3.h |    1 +
> >  2 files changed, 128 insertions(+), 1 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> > index 8bf11ca..f684be9 100644
> > --- a/drivers/net/ethernet/broadcom/tg3.c
> > +++ b/drivers/net/ethernet/broadcom/tg3.c
> > @@ -8229,9 +8229,18 @@ void tg3_rss_init_indir_tbl(struct tg3 *tp)
> >  
> >  	if (tp->irq_cnt <= 2)
> >  		memset(&tp->rss_ind_tbl[0], 0, sizeof(tp->rss_ind_tbl));
> > -	else
> > +	else if (tg3_flag(tp, USER_INDIR_TBL)) {
> > +		/* Validate table against current IRQ count */
> > +		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++) {
> > +			if (tp->rss_ind_tbl[i] >= tp->irq_cnt - 1) {
> > +				/* Cap the vector index */
> > +				tp->rss_ind_tbl[i] = tp->irq_cnt - 2;
> 
> A modulo operation might make more sense.  But I don't suppose this
> failure is going to happen often enough for it to be important.

I suppose that makes more sense.  TG3 only has at-most 4 RSS queues, so
there really isn't much difference.  Your idea places more of the
traffic in the first RSS queue, which has a slight performance
advantage.  Thanks for making me rethink this. :)

> > +			}
> > +		}
> > +	} else {
> >  		for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
> >  			tp->rss_ind_tbl[i] = i % (tp->irq_cnt - 1);
> > +	}
> >  }
> >  
> >  void tg3_rss_write_indir_tbl(struct tg3 *tp)
> > @@ -10719,6 +10728,120 @@ static int tg3_get_sset_count(struct net_device *dev, int sset)
> >  	}
> >  }
> >  
> > +static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
> > +			 u32 *rules __always_unused)
> > +{
> > +	struct tg3 *tp = netdev_priv(dev);
> > +
> > +	if (!tg3_flag(tp, SUPPORT_MSIX))
> > +		return -EINVAL;
> 
> Should be -EOPNOTSUPP.

Will do.

> > +	if (!netif_running(tp->dev))
> > +		return -EAGAIN;
> 
> Why?  You do handle !netif_running() below...

Right.  This isn't needed.

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
> > +		return -EINVAL;
> 
> -EOPNOTSUPP

Will do.

> > +	if (!indir->size) {
> > +		indir->size = TG3_RSS_INDIR_TBL_SIZE;
> > +		return 0;
> > +	}
> > +
> > +	if (indir->size != TG3_RSS_INDIR_TBL_SIZE)
> > +		return -EINVAL;
> 
> This is enough to make the ethtool command work, but you're really
> supposed to copy min(indir->size, TG3_RSS_INDIR_TBL_SIZE) entries.

Could you elaborate on this?  I'm confused because I can't figure out
how returning half of an indirection table could be useful.
