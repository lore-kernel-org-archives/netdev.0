From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Sun, 01 Jul 2012 09:38:05 -0700
Message-ID: <1341160685.2032.15.camel@joe2Laptop>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	 <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	 <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52757 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752498Ab2GAQiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 12:38:07 -0400
In-Reply-To: <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 17:00 +0100, Ben Hutchings wrote:
> On Sun, 2012-07-01 at 12:43 +0300, Or Gerlitz wrote:
> > From: Hadar Hen Zion <hadarh@mellanox.co.il>
[]
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
[]
> > @@ -599,16 +603,360 @@ static int mlx4_en_set_rxfh_indir(struct net_device *dev,
> >  	return err;
> >  }
> >  
> > +#define not_all_zeros_or_all_ones(field, type) \
> > +	(field && (type)~field)

I think this macro is suboptimal because
negated names are easy to misuse.

I think type is also unnecessary and too
easy to mismatch or keep up to date with
field type changes.

Perhaps it's better as:

#define all_zeros_or_all_ones(field)		\
({						\
	field && (typeof(field))~field;		\
})

> > +
> > +static int mlx4_en_validate_flow(struct net_device *dev,
> > +				 struct ethtool_rxnfc *cmd)
> > +{
[]
> > +		/* don't allow mask which isn't all 0 or 1 */
> > +		if (not_all_zeros_or_all_ones(l4_mask->ip4src, __be32) ||
> > +		    not_all_zeros_or_all_ones(l4_mask->ip4dst, __be32) ||
> > +		    not_all_zeros_or_all_ones(l4_mask->psrc, __be16) ||
> > +		    not_all_zeros_or_all_ones(l4_mask->pdst, __be16))
> > +			return -EOPNOTSUPP;

		if (!all_zeros_or_all_ones(l4_mask->ip4src) ||
		    !all_zeros_or_all_ones(l4_mask->ip4dst) ||
		    !all_zeros_or_all_ones(l4_mask->psrc) ||
		    !all_zeros_or_all_ones(l4_mask->pdst))
