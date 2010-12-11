From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Sat, 11 Dec 2010 14:04:47 +0900
Message-ID: <20101211050447.GC32453@verge.net.au>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
 <1292042278.3136.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45283 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab0LKFEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Dec 2010 00:04:52 -0500
Content-Disposition: inline
In-Reply-To: <1292042278.3136.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 11, 2010 at 04:37:58AM +0000, Ben Hutchings wrote:
> On Sat, 2010-12-11 at 13:13 +0900, Simon Horman wrote:
> > Early orphaning is an optimisation which avoids unnecessary cache misses by
> > orphaning an skb just before it is handed to a device for transmit thus
> > avoiding the case where the orphaning occurs on a different CPU.
> > 
> > In the case of bonded devices this has the unfortunate side-effect of
> > breaking down flow control allowing a socket to send UDP packets as fast as
> > the CPU will allow. This is particularly undesirable in virtualised
> > network environments.
> > 
> > This patch introduces ethtool control of early orphaning.
> > It remains on by default by it now may be disabled on a per-interface basis.
> > 
> > I have implemented this as a generic flag.
> > As it seems to be the first generic flag that requires
> > no driver awareness I also supplied a default flag handler.
> > I am unsure if any aspect of this approach is acceptable.
> 
> I'm not convinced that this belongs in the ethtool API.  It doesn't seem
> to have anything to do with hardware or driver behaviour.  The flag
> belongs in priv_flags, not features.

Ok, I have no objection to it going in priv_flags so long
as it can be exposed to user-space in some sensible fashion.
Do you have any thoughts on how best to achieve that?

> But if it is to be a feature flag...
> 
> [...]
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 1774178..f63bdce 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> [...]
> > @@ -157,6 +158,13 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
> >  }
> >  EXPORT_SYMBOL(ethtool_op_set_flags);
> >  
> > +static int ethtool_op_set_flags_early_orphan(struct net_device *dev, u32 data)
> > +{
> > +       dev->features = ((dev->features & ~NETIF_F_EARLY_ORPHAN) |
> > +                        (data & NETIF_F_EARLY_ORPHAN));
> > +       return 0;
> 
> this needs to check that no unsupported flags are set, i.e.
> 
> 	return ethtool_op_set_flags(dev, data, NETIF_F_EARLY_ORPHAN);

I thought that I could ensure that by using NETIF_F_EARLY_ORPHAN
as the mask as I have above.

I think that in order for your suggestion to work we
need to mask out the non-flags_dup_features in the supported
check in ethtool_op_set_flags() or use:

	return ethtool_op_set_flags(dev, data, dev->features & NETIF_F_EARLY_ORPHAN);

Although NETIF_F_EARLY_ORPHAN isn't needed there due to the
exception I added for it to the supported check in ethtool_op_set_flags().

> 
> > +}
> > +
> >  void ethtool_ntuple_flush(struct net_device *dev)
> >  {
> >         struct ethtool_rx_ntuple_flow_spec_container *fsc, *f;
> > @@ -1644,7 +1652,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
> >  		break;
> >  	case ETHTOOL_SFLAGS:
> >  		rc = ethtool_set_value(dev, useraddr,
> > -				       dev->ethtool_ops->set_flags);
> > +				       dev->ethtool_ops->set_flags ?
> > +				       dev->ethtool_ops->set_flags :
> > +				       ethtool_op_set_flags_early_orphan);
> [...]
> 
> and this fallback needs to be done further up along with ETHTOOL_DRVINFO
> so that it doesn't depend on the driver setting dev->ethtool_ops at all.

Thanks, got it.
