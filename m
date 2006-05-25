From: Bill Fink <billfink@mindspring.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 12:12:09 -0400
Message-ID: <20060525121209.26235736.billfink@mindspring.com>
References: <20060523.182217.59656237.davem@davemloft.net>
	<4474BD52.6020604@garzik.org>
	<20060525032357.4990425f.billfink@mindspring.com>
	<200605250805.38241.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, phil@ipom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth04.mail.atl.earthlink.net ([209.86.89.64]:62946 "EHLO
	smtpauth04.mail.atl.earthlink.net") by vger.kernel.org with ESMTP
	id S1030240AbWEYQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 12:12:18 -0400
To: Brent Cook <bcook@bpointsys.com>
In-Reply-To: <200605250805.38241.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 May 2006, Brent Cook wrote:

> On Thursday 25 May 2006 02:23, Bill Fink wrote:
> > On Wed, 24 May 2006, Jeff Garzik wrote:
> > > Brent Cook wrote:
> > > > Note that this is just clearing the hardware statistics on the
> > > > interface, and would not require any kind of atomic_increment addition
> > > > for interfaces that support that. It would be kind-of awkward to
> > > > implement this on drivers that increment stats in hardware though (lo,
> > > > vlan, br, etc.) This also brings up the question of resetting the stats
> > > > for 'netstat -s'
> > >
> > > If you don't atomically clear the statistics, then you are leaving open
> > > a window where the stats could easily be corrupted, if the network
> > > interface is under load.
> > >
> > > This 'clearing' operation has implications on the rest of the statistics
> > > usage.
> > >
> > > More complexity, and breaking of apps, when we could just use the
> > > existing, working system?  I'll take the "do nothing, break nothing,
> > > everything still works" route any day.
> >
> > I'll admit to not knowing all the intricacies of the kernel coding
> > involved, but I don't offhand see how zeroing the stats would be
> > significantly more complex than updating the stats during normal usage. 
> > But I'll have to leave that argument to the experts.
> 
> What it boils down to is that currently, a single CPU or thread ever touches 
> the stats concurrently, so it doesn't have to lock them or do anything 
> special to ensure that the continue incrementing. If you want to make sure 
> that the statistics actually reset when you want them to, you have to account 
> for this case:
> 
>   CPU0 reads current value from memory (increment)
>   CPU1 writes 0 to current value in memory (reset)
>   CPU0 writes incremented value to memory (increment complete)
> 
> Check out do_add_counters() in net/ipv4/netfilter/ip_tables.c
> to see what's required to do this reliably in the kernel.

Thanks for the info.  I have a possibly naive question.  Would it
increase the reliability of clearing the stats using "lazy" zeroing
(no locking), if the zeroing app (ethtool) bound itself to the same
CPU that was handling interrupts for the device (assuming no sharing
of interrupts across CPUs)?

> The current patch is fine if your hardware implements the required atomicity 
> itself. Otherwise, you need a locking infrastructure to extend it to all 
> network devices if you want zeroing to always work. What I'm seeing here in 
> response to this is that it doesn't matter if zeroing just _mostly_ works, 
> which is what you would get if you didn't lock. Eh, I'm OK with that too, but 
> I think people are worried about the bugs that would get filed by admins when 
> just zeroing the stats on cheap NIC x only works 90% of the time, less under 
> load. Or not at all (not implemented in driver.) Then you're back to the 
> userspace solution or actually implement stat locking / atomic ops.

I would be fine with the "lazy" clearing of the stats (with a note
describing the limitations in the ethtool man page).  Being somewhat
anal, I would always check that the stats had in fact been zeroed
successfully before proceeding.  BTW I am in 100% agreement not to
do anything that would affect performance of the fast path, as I
understand proper locking would necessitate.

I will also look into the beforeafter utility that has been suggested,
to see how easy it is to use and how much extra work would be required
over just a direct visual examination of the interface statistics.

						-Bill
