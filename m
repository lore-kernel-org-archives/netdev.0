From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Using a waiting MDIO does not go well with a spinlocked bridge
Date: Fri, 20 Mar 2015 23:32:05 -0700
Message-ID: <20150321063205.GA29867@roeck-us.net>
References: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	f.fainelli@gmail.com, jiri@resnulli.us, sfeldma@gmail.com
To: Jonas Johansson <jonasj76@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:46764 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbbCUGcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 02:32:10 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YZCx7-002d5z-58
	for netdev@vger.kernel.org; Sat, 21 Mar 2015 06:32:09 +0000
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.03.1503201321050.27020@hellgate.skynet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 01:22:46PM +0100, Jonas Johansson wrote:
> The bridge code will sometimes hold a spinlock and the code following must
> therefore be atomic. If using a MDIO call which uses a wait/sleep in this
> contex, the kernel will not be very happy.
> 
> I'm using a switch device and wants to flush its FDB when the linux bridge
> FDB is flushed. I've implemented some hooks for this task.
> In short:
>      bridge    - br_fdb_flush() & br_fdb_delete_by_port
>   -> switchdev - switch_flush()
>   -> dsa       - slave_flush()
>   -> mv88e6xxx - mv88_flush()
> 
> So, when a bridge port is flushed via e.g. sysfs, the mv88_flush() function
> will at the end be called. The mv88_flush() will use MDIO calls to set the
> proper registers and flush the device. But, due to that the MDIO on my
> platform uses wait_for_completion() and a spinlock is held (in this case in
> brport_store()) the process will not go very well.
> 
I happen to have similar code, though not (yet) submitted upstream.

> The only possible solutions that came into my mind is:
>  1) Let mv88_flush() schedule a work queue to take care of the flush
>     later on.

That is my implementation.

>  2) Change the MDIO implementation to use polling.
>  3) Dont use spinlock in bridge code.
> 
> 1) Using this approach the the atomic part is missed, i.e. the switch device
> isn't guaranteed to be flushed after the command has been issued. And, if a
> FDB entry is added (atomic) to the switch device immediately after the flush
> command, there will not be defined if the entry will be added before or
> after the flush occurs. To solve this, all (FDB) operations must be added to
> a work queue to assure that they are executed in the right order.
> 

In my code I did not bother about this. Which may be why I didn't submit it
upstream ;-). One possible simplification might be to reject fdb operations
while a flush operation is pending (EAGAIN or EBUSY ?), though I don't know
if that is feasible.

> 2) This will result in unsued CPU cycles.
> 
> 3) Havent looked into this, but probably a lot of work.
> 
I don't think 2) or 3) are good solutions. Both want to change other
subsystems due to problems in the dsa code. If we start doing that we
would mess up the kernel all over the place. I think the solution has
to come from within DSA.

Thanks,
Guenter
