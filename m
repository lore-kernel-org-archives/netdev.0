From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] rfc: ethtool: early-orphan control
Date: Tue, 14 Dec 2010 19:30:31 +0000
Message-ID: <1292355031.20458.18.camel@bwh-desktop>
References: <1292040815-10439-1-git-send-email-horms@verge.net.au>
	 <1292042278.3136.14.camel@localhost>  <20101211050447.GC32453@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18674 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab0LNTae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 14:30:34 -0500
In-Reply-To: <20101211050447.GC32453@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-11 at 14:04 +0900, Simon Horman wrote:
> On Sat, Dec 11, 2010 at 04:37:58AM +0000, Ben Hutchings wrote:
> > On Sat, 2010-12-11 at 13:13 +0900, Simon Horman wrote:
> > > Early orphaning is an optimisation which avoids unnecessary cache misses by
> > > orphaning an skb just before it is handed to a device for transmit thus
> > > avoiding the case where the orphaning occurs on a different CPU.
> > > 
> > > In the case of bonded devices this has the unfortunate side-effect of
> > > breaking down flow control allowing a socket to send UDP packets as fast as
> > > the CPU will allow. This is particularly undesirable in virtualised
> > > network environments.
> > > 
> > > This patch introduces ethtool control of early orphaning.
> > > It remains on by default by it now may be disabled on a per-interface basis.
> > > 
> > > I have implemented this as a generic flag.
> > > As it seems to be the first generic flag that requires
> > > no driver awareness I also supplied a default flag handler.
> > > I am unsure if any aspect of this approach is acceptable.
> > 
> > I'm not convinced that this belongs in the ethtool API.  It doesn't seem
> > to have anything to do with hardware or driver behaviour.  The flag
> > belongs in priv_flags, not features.
> 
> Ok, I have no objection to it going in priv_flags so long
> as it can be exposed to user-space in some sensible fashion.
> Do you have any thoughts on how best to achieve that?

I suppose this should actually be in plain 'flags', which is exposed and
changeable through rtnetlink (ifinfomsg::ifi_{flags,change}) or ioctl
(SIOCSIFFLAGS).

> > But if it is to be a feature flag...
> > 
> > [...]
> > > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > > index 1774178..f63bdce 100644
> > > --- a/net/core/ethtool.c
> > > +++ b/net/core/ethtool.c
> > [...]
> > > @@ -157,6 +158,13 @@ int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
> > >  }
> > >  EXPORT_SYMBOL(ethtool_op_set_flags);
> > >  
> > > +static int ethtool_op_set_flags_early_orphan(struct net_device *dev, u32 data)
> > > +{
> > > +       dev->features = ((dev->features & ~NETIF_F_EARLY_ORPHAN) |
> > > +                        (data & NETIF_F_EARLY_ORPHAN));
> > > +       return 0;
> > 
> > this needs to check that no unsupported flags are set, i.e.
> > 
> > 	return ethtool_op_set_flags(dev, data, NETIF_F_EARLY_ORPHAN);
> 
> I thought that I could ensure that by using NETIF_F_EARLY_ORPHAN
> as the mask as I have above.

No, this *ignores* the unsupported flags.  Unsupported flags should be
reported as an error (EINVAL) which is what ethtool_op_set_flags() now
does.

> I think that in order for your suggestion to work we
> need to mask out the non-flags_dup_features in the supported
> check in ethtool_op_set_flags() or use:
> 
> 	return ethtool_op_set_flags(dev, data, dev->features & NETIF_F_EARLY_ORPHAN);
> 
> Although NETIF_F_EARLY_ORPHAN isn't needed there due to the
> exception I added for it to the supported check in ethtool_op_set_flags().
[...]

I don't follow.  In what circumstances would my suggested implementation
do the wrong thing?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

