From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Wed, 25 Feb 2015 09:41:25 -0800
Message-ID: <20150225174125.GB2400@roeck-us.net>
References: <54EAAEBC.6080609@roeck-us.net>
 <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com>
 <20150223133454.GB23581@lunn.ch>
 <54EB37C7.3090209@roeck-us.net>
 <20150223160109.GB27057@lunn.ch>
 <54EB6BF5.2020600@gmail.com>
 <20150223183537.GA23456@roeck-us.net>
 <54EDD172.4010606@nexvision.fr>
 <54EDDB72.1090706@roeck-us.net>
 <54EDF2B8.8020200@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Andrey Volkov <andrey.volkov@nexvision.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:48437 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbBYRlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:41:39 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YQfxq-001WG4-4J
	for netdev@vger.kernel.org; Wed, 25 Feb 2015 17:41:38 +0000
Content-Disposition: inline
In-Reply-To: <54EDF2B8.8020200@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey,

On Wed, Feb 25, 2015 at 05:05:12PM +0100, Andrey Volkov wrote:
> > 
> > Does removing a port from a fid clean up the entries associated with it
> > in the database ?
> > 
> It doesn't, sorry that I didn't described it clearly: I've tried to point to that fact that 
> changing FID will cause 2 things:
>  - learn/discard/... process for all following packets will begin from scratch (as it should be)
>  - we could start (potentially) slow database cleanup process in dedicated thread/work, and we may not
>    care about appearing of new ATU rules for the removed port, since packets now will be rejected 
>    by port's logic.
> 
Any idea what happens if a packet is received which has an fdb entry
pointing to port X, which was just removed from the bridge group ?

> >> seen any mutichip bridges/hardwared "trunks" support (in the Marvell's sense), did anyone, except me, use it?
> >>
> > Not me. That would be difficult to test without real hardware.
> Not a problem for me :), I've already monster switch containing three different types of Marvell's chips 
> just before me on my table.
> 

Lucky (or unlucky ;-) you.

> > 
> > The above suggests that you have a HW bridge implementation for Marvell chips as well.
> > Would it make sense to merge our implementations, or just use yours if it is better ?
> I've implemented same thing almost by same way, so for me it will be easer to rebase on top of your jobs,
> especially due to the fact that I've enforced to use very old kernel: proprietary binary blobs...
> 

Can you by any chance share your code, and or do you plan
to submit it ?

I'll have to look into multi-bridge implementations at some point
in the future, so that would help a lot.

> > 
> >> Btw your current FID implementation contain funny security problem: same ports in the different chips,
> >> interconnected by DSA, will have same FID and as result they will treated as bridged together by
> >> internal switch logic...
> >>
> > You mean if multiple switch chips are used ? Those ports are configured to only send
> > data to the CPU port. Doesn't that take care of the problem ? Granted, I have not
> > looked into multi-chip applications, so there may well be some problems.
> 
> My current project is to implement support of something like:
> 
>        .----------.    .--------.
>        |  CPU1    |    |  CPU2  |
>  .DSA--o (master) |    |        |
>  |     '----------'    'o-------'
>  |                  .---'
>  | .-----.       .--o--.       .-----.
>  '-o SW1 o--DSA--o SW2 o==DSA==o SW3 |
>    '-----'       '-----'       '-----'
>      |             |              |
>    ports         ports          ports
> 
> Where SW2 and SW3 are interconnected by "trunk", everything managed by CPU1,
> some ports of SW1-SW3 are bridged with CPU2, some with CPU1, and some bridged 
> independently of CPUs. Also, as I told before, all SWs are from 
> different chips families, so I'm using all, except 88e6060 and 6171, Marvell's drivers.
> 
Sounds like a lot of fun, especially if/when both CPUs start messing
with switch configuration.

> > Maybe
> > it is possible to merge a chip ID into the fid to solve it.
> Will not work IMHO, since to support interswitch bridges, some ports must have common id's,
> so we should have some enumeration management at level of the DSA tree.
> I've already implemented it as a free running counter, but implementation is wrong, terrible
> and must be redesigned by hlists or alike.
> 
Maybe use ida to get a well defined id for each bridge group touched
by dsa ? This id could then be used by the driver to identify a bridge.

Guenter
