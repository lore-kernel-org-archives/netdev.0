From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 11:35:02 +0100
Message-ID: <20120214103502.GH32155@v3-1054>
References: <201202132253.16496.jdelvare@suse.de>
 <22039.1329171191@death.nxdomain>
 <201202141122.10705.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slnx.de ([79.140.41.54]:60196 "EHLO v3-1054.slnx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666Ab2BNKkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 05:40:41 -0500
Content-Disposition: inline
In-Reply-To: <201202141122.10705.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 11:22:10AM +0100, Jean Delvare wrote:
> Hi Jay,
> 
> Thanks for the fast answer.
> 
> On Monday 13 February 2012 11:13:11 pm Jay Vosburgh wrote:
> > Jean Delvare <jdelvare@suse.de> wrote:
> > >I am trying to do network bonding on top of 3com 3C905C ethernet
> > >adapters. I am facing the problem that network cable removal isn't
> > >detected. It is detected when using Realtek hardware with driver
> > > 8139too or VIA hardware with driver via-rhine, but no luck with
> > > driver 3c59x. I'm using bonding option miimon=100 for link
> > > detection.
> > >
> > >Does anyone know if this is a hardware limitation, or a missing
> > > feature of the 3c59x driver, or a bug in that driver?
> > 
> > 	It just so happens that I was looking at 3c59x earlier today for
> > something else.  It appears to run its internal link state detection
> >  on a 5 second timer, after which (in theory) bonding's miimon would
> >  notice (provided that the driver notices and calls
> >  netif_carrier_off).
> 
> Thanks for the pointer. There is indeed a 5 second timer to detect 
> transitions from link down to link up. However the timer period to 
> detect transitions from link up to link down is 1 minute. Knowing that, 
> I tested again and indeed the bonding module end up detecting the link 
> going down, after up to 1 minute. That's not exactly convenient for 
> bonding.
> 
> I admit I don't quite get the rationale for having different timer 
> periods for detecting the link going up or down. Steffen, this was done 
> by you in:
> 
> commit b4ff6450f5336c492d1e2f184d3b8186e0716b7a
> Author: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> Date:   Sun Mar 26 01:37:40 2006 -0800
> 
>     [PATCH] 3c59x: decrease polling interval
> 
> No rationale explained in the commit message. Can you explain? I find 
> the asymmetry confusing, I'd rather use 5 seconds (if not less) for both 
> cases.


This patch is based on a discussion with Andrew Morton some years ago.
The 3c59x does polling for external environment changes which is quite
expensive. Firing a timer that disables the interrupts on a running
interface every 5 seconds is just not reasonable for checking for external
environment changes. So we decided to let it depend on the link status,
5 seconds if the link is down and 60 seconds if the link is up.
