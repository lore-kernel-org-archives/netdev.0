From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 2/3] ethtool: Add support for DMA buffer
 settings
Date: Sat, 2 Aug 2014 07:26:07 -0700
Message-ID: <20140802072607.6eec3334@haswell.linuxnetplumber.net>
References: <1406634039-15030-1-git-send-email-_govind@gmx.com>
	<1406634039-15030-3-git-send-email-_govind@gmx.com>
	<20140730.175306.483788306179792581.davem@davemloft.net>
	<1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, _govind@gmx.com,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52577 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbaHBO0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 10:26:12 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so7128438pde.4
        for <netdev@vger.kernel.org>; Sat, 02 Aug 2014 07:26:11 -0700 (PDT)
In-Reply-To: <1406987782.30258.43.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 02 Aug 2014 14:56:22 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Wed, 2014-07-30 at 17:53 -0700, David Miller wrote:
> > From: Govindarajulu Varadarajan <_govind@gmx.com>
> > Date: Tue, 29 Jul 2014 17:10:38 +0530
> > 
> > > @@ -440,6 +440,20 @@ struct ethtool_ringparam {
> > >  };
> > >  
> > >  /**
> > > + * struct ethtool_buffparam - DMA buffer parameters
> > > + * @rx_copybreak_cur: current receive DMA buff rx_copybreak.
> > > + * @rx_copybreak_min: min rx_copybreak set by driver.
> > > + * @rx_copybreak_max: Max rx_copybreak set by driver.
> > > + * @reserved: reserve room for future use.
> > > + */
> > > +struct ethtool_buffparam {
> > > +	__u32	cmd;
> > > +	__u32	rx_copybreak_cur;
> > > +	__u32	rx_copybreak_max;
> > > +	__u8	reserved[84];
> > > +};
> > 
> > I don't understand the reasoning behind this reserved field.
> > 
> > You can't use it to add more fields later, because right now
> > we'll let the user put any garbage there and thus if you add
> > more fields that garbage from older apps would be interpreted
> > as one of the new values.
> 
> That's OK, we can test that they're all zero.  Or add flags.
> 
> > Largely we have not been adding reserved fields to new ethtool
> > structures, and this is the primary reason I guess.
> 
> Yes we have, but not consistently.
> 
> > It's a shame that when we want to add a new 32-bit knob we have
> > to add an entire new struct.
> > 
> > We have ethtool_value, but that's only good for one knob at a time and
> > we have to allocate an entire new ethtool command value for each such
> > knob.
> 
> Two commands and two function pointers!
> 
> > I really don't know what the recommend here.
> > 
> > However I wonder what value that "max" thing has, I think setting the
> > value to infinity is just fine, it just means every packet will be
> > copied.
> > 
> > So if we remove the 'max', we just have the copybreak itself, and you
> > can therefore use ethtool_value and allocate the ethtool command
> > numbers.
> > 
> > What do you think?
> 
> How about adding a generic operation for independent tunables:
> 
> struct ethtool_get_tunable {
> 	u32	cmd;
> 	u32	id;
> 	u64	value, min, max;
> };
> 
> struct ethtool_set_tunable {
> 	u32	cmd;
> 	u32	id;
> 	u64	value;
> };
> 
> 	int (*get_tunable)(struct net_device *, struct ethtool_get_tunable *);
> 	int (*set_tunable)(struct net_device *, const struct ethtool_set_tunable *);
> 
> The id to name mapping could be provided either through a stringset or
> macros in <uapi/linux/ethtool.h>.  And perhaps we could split the id
> space to allow for driver-specific tunables (while strongly discouraging
> those for in-tree drivers).
> 
> Ben.
> 

Looks like you just reinvented netlink :-)

I wish ethtool would die.
It has fixed size static structures and has no notification mechanism.

If we could just get all the ethtool features into netlink, under IF_LINK
then most of this could go away.
