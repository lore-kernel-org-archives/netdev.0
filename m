From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [Powerpc / eHEA] Circular dependency with 2.6.29-rc6
Date: Wed, 25 Feb 2009 19:24:09 +0100
Message-ID: <1235586249.4645.3765.camel@laptop>
References: <49A26290.60607@in.ibm.com>  <49A55E54.4080304@de.ibm.com>
	 <1235577013.4645.3548.camel@laptop>  <49A57AB9.3000502@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: TKLEIN@de.ibm.com, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Mel Gorman <mel@csn.ul.ie>, netdev <netdev@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Ingo Molnar <mingo@elte.hu>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53162 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290AbZBYSYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 13:24:34 -0500
In-Reply-To: <49A57AB9.3000502@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-25 at 18:07 +0100, Jan-Bernd Themann wrote:
> Hi,
> 
> yes, sorry for the funny wrapping... and thanks for your quick answer!
> 
> Peter Zijlstra wrote:
> > On Wed, 2009-02-25 at 16:05 +0100, Jan-Bernd Themann wrote:
> >
> >   
> >> - When "open" is called for a registered network device, port->port_lock
> >> is taken first,
> >>   then ehea_fw_handles.lock
> >> - When "open" is left these locks are released in a proper way (inverse
> >> order)
> >>     
> >
> > So this has:
> >
> >   port->port_lock
> >     ehea_fw_handles.lock
> >
> > This would be the case that is generating the warning.
> >
> >   
> >> - In addition: ehea_fw_handles.lock is held by the function
> >> "driver_probe_device"
> >>   that registers all available network devices (register_netdev)
> >> - When multiple network devices are registered, it is possible that
> >> "open" is
> >>   called on an already registered network device while further
> >> netdevices are still registered
> >>   in "driver_probe_device". ---> "open" will take port->port_lock, but
> >> won't get ehea_fw_handles.lock
> >>     
> >
> > Right, so here you have 
> >
> >   ehea_fw_handles.lock
> >     port->port_lock
> >
> > Overlay these two cases and you have AB-BA deadlocks.
> >
> >   
> The thing here is that I did not see that "open" is called from this
> "probe" function,
> this happens probably indirectly as each new device causes a notifier chain
> to be called --> If I got it right then a userspace tool triggers the
> "open".
> In that case the open would run in an other task/thread and thus when
> the kernel
> preemts the task/thread the probe function would continue and free the lock.
> 
> Lets assume that it is actually possible that "open" is called in the
> same context as
> "probe", wound't that mean that we actually need to hit a deadlock?
> (probe helds
> the lock all the time). We have never observed a deadlock so far.

That's the brilliant bit about lockdep, it can observe potential
deadlocks without ever hitting them :-)

> Is there a way to find out if all these locks are actually taken in the
> same context
> (kthread, tasklet...)?

They don't need to happen in the same context, suppose a kthread (1)
does the probe and some user task (2) does the open:

    1 - probe                    2 - open

lock(ehea_fw_handles.lock)

			lock(port->port_lock)

lock(port->port_lock) <-- waiting for 2

			lock(ehea_fw_handles.lock) <-- waiting for 1


Which is the classic AB-BA deadlock scenario.

Hitting it will be very unlikely, as this probe thing is a very rare
event, but that doesn't mean it cannot happen.

Now, if you can guarantee that the probe and open port object are
_never_ the same one, then we can say this is a false positive and work
on teaching lockdep about that.

> >> - However, ehea_fw_handles.lock is freed once all netdevices are registered.
> >> - When the second netdevice is registered in "driver_probe_device", it
> >> will also try to get
> >>   the port->port_lock (which in fact is a different one, as there is one
> >> per netdevice).
> >> - Does the mutex debug mechanism distinguish between the different
> >> port->port_lock instances?
> >>     
> >
> > Not unless you tell it to.
> >   
> > Are you really sure the port->port_lock in this AB-BA scenario are never
> > the same? The above explanation didn't convince me (also very hard to
> > read due to funny wrapping).
> >   
> I'm not sure, especially as I just ran the same test with just one port
> and we still
> get the warning. But having two instances of port accessing the locks
> does not
> look like a problem to me as they allocate and free the locks properly
> (right order).

The initial probe will establish the A->B order, the subsequent open
will attempt B->A at which point lockdep will warn.



