From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Fri, 20 Mar 2015 14:16:22 +0100
Message-ID: <20150320131622.GC9179@lunn.ch>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	f.fainelli@gmail.com, jiri@resnulli.us, sfeldma@gmail.com
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53454 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbbCTNT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 09:19:57 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 01:22:46PM +0100, Jonas Johansson wrote:
> The bridge code will sometimes hold a spinlock and the code
> following must therefore be atomic. If using a MDIO call which uses
> a wait/sleep in this contex, the kernel will not be very happy.
> 
> I'm using a switch device and wants to flush its FDB when the linux
> bridge FDB is flushed. I've implemented some hooks for this task.
> In short:
>      bridge    - br_fdb_flush() & br_fdb_delete_by_port
>   -> switchdev - switch_flush()
>   -> dsa       - slave_flush()
>   -> mv88e6xxx - mv88_flush()

Hi Jonas

Have you seen the patches from Guenter Roeck implementing hardware
bridging? There should be a new version coming out soon.

> So, when a bridge port is flushed via e.g. sysfs, the mv88_flush()
> function will at the end be called. The mv88_flush() will use MDIO
> calls to set the proper registers and flush the device. But, due to
> that the MDIO on my platform uses wait_for_completion() and a
> spinlock is held (in this case in brport_store()) the process will
> not go very well.

Ah, not good. We have a number of mutex in the mv88x6xxx code, one of
which is used with fdb operations..
 
> The only possible solutions that came into my mind is:
>  1) Let mv88_flush() schedule a work queue to take care of the flush
>     later on.
>  2) Change the MDIO implementation to use polling.

I don't think these is feasible. The MDIO bus could be a gpio
bit-banging interface. It is hard to guarantee that the GPIO code will
not sleep.

>  3) Dont use spinlock in bridge code.

This would be my preference, but i've no idea how much work it is.  We
should audit the bridge code and document in what context operations
on the switch are called.

   Andrew
