From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net-next 2/4] net: dsa: mv88e6xxx: Monitor and
 Management tables
Date: Fri, 2 Dec 2016 21:56:56 +0100
Message-ID: <20161202205656.GD30716@lunn.ch>
References: <1480701779-30633-1-git-send-email-andrew@lunn.ch>
 <1480701779-30633-3-git-send-email-andrew@lunn.ch>
 <87mvgecejs.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38256 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750738AbcLBVkP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 16:40:15 -0500
Content-Disposition: inline
In-Reply-To: <87mvgecejs.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 02:32:39PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > @@ -3184,6 +3186,8 @@ static const struct mv88e6xxx_ops mv88e6085_ops = {
> >  	.stats_get_sset_count = mv88e6095_stats_get_sset_count,
> >  	.stats_get_strings = mv88e6095_stats_get_strings,
> >  	.stats_get_stats = mv88e6095_stats_get_stats,
> > +	.g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
> > +	.g1_set_egress_port = mv88e6095_g1_set_egress_port,
> >  };
> 
> I like the implementation in this version better. But please explain me
> why you are prefixing these operations with g1_?

The prefix gives some basic grouping. port_ indicates it operates on a
port, and is likely to be found in port.c. stats_ indicates it
operates on statistics, ppu that is operates on the phy polling unit.

We are going to have some things which don't fall into a simple
category, like these two. But it would however be nice to group them,
so i picked which register bank they are in. These operations are
always in g1. It is a useful hint as to where to find the different
variants.

> But let's imagine we can set the CPU port in some Global 2 registers.
> You are going to wrap this in chip.c with something like:
> 
>     int mv88e6xxx_set_cpu_port(struct mv88e6xxx_chip *chip, int port)
>     {
>         if (chip->info->ops->g2_set_cpu_port)
>             return chip->info->ops->g2_set_cpu_port(chip, port);
>         else if (chip->info->ops->g1_set_cpu_port)
>             return chip->info->ops->g1_set_cpu_port(chip, port);
>         else
>             return -EOPNOTSUPP;
>     }

I answered in one of my other emails. Frames with reserved MAC
addresses can be forwarded to the CPU. For most devices, this is a g2
operation. However, for 6390, it is a g1. In that case, my code does
not use a prefix. Not having a prefix, when all the others do, also
gives you information. It means the ops are spread around and you need
to make a bigger effort to go find them.

   Andrew
