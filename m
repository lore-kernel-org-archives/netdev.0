From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Fri, 20 Mar 2015 23:37:35 -0700
Message-ID: <20150321063735.GB29867@roeck-us.net>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
 <20150320131622.GC9179@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonas Johansson <jonasj76@gmail.com>, netdev@vger.kernel.org,
	stephen@networkplumber.org, f.fainelli@gmail.com, jiri@resnulli.us,
	sfeldma@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:47682 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbbCUGhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 02:37:50 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZD2c-002fhV-1K
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 06:37:50 +0000
Content-Disposition: inline
In-Reply-To: <20150320131622.GC9179@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 02:16:22PM +0100, Andrew Lunn wrote:
> On Fri, Mar 20, 2015 at 01:22:46PM +0100, Jonas Johansson wrote:
> > The bridge code will sometimes hold a spinlock and the code
> > following must therefore be atomic. If using a MDIO call which uses
> > a wait/sleep in this contex, the kernel will not be very happy.
> > 
> > I'm using a switch device and wants to flush its FDB when the linux
> > bridge FDB is flushed. I've implemented some hooks for this task.
> > In short:
> >      bridge    - br_fdb_flush() & br_fdb_delete_by_port
> >   -> switchdev - switch_flush()
> >   -> dsa       - slave_flush()
> >   -> mv88e6xxx - mv88_flush()
> 
> Hi Jonas
> 
> Have you seen the patches from Guenter Roeck implementing hardware
> bridging? There should be a new version coming out soon.
> 
> > So, when a bridge port is flushed via e.g. sysfs, the mv88_flush()
> > function will at the end be called. The mv88_flush() will use MDIO
> > calls to set the proper registers and flush the device. But, due to
> > that the MDIO on my platform uses wait_for_completion() and a
> > spinlock is held (in this case in brport_store()) the process will
> > not go very well.
> 
> Ah, not good. We have a number of mutex in the mv88x6xxx code, one of
> which is used with fdb operations..
>  
The mutexes in the mv88x6xxx don't matter, really. There is also the
mdio bus mutex which would kill us anyway.

Handling port state changes is already implemented with a workqueue
in my code because of the spinlock problem. I use that same workqueue
in my (not submitted) patch to flush the fdb.

Guenter

> > The only possible solutions that came into my mind is:
> >  1) Let mv88_flush() schedule a work queue to take care of the flush
> >     later on.
> >  2) Change the MDIO implementation to use polling.
> 
> I don't think these is feasible. The MDIO bus could be a gpio
> bit-banging interface. It is hard to guarantee that the GPIO code will
> not sleep.
> 
> >  3) Dont use spinlock in bridge code.
> 
> This would be my preference, but i've no idea how much work it is.  We
> should audit the bridge code and document in what context operations
> on the switch are called.
>
