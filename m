From: Brent Cook <bcook@bpointsys.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 08:05:37 -0500
Message-ID: <200605250805.38241.bcook@bpointsys.com>
References: <20060523.182217.59656237.davem@davemloft.net> <4474BD52.6020604@garzik.org> <20060525032357.4990425f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, phil@ipom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.sbc.mail.mud.yahoo.com ([68.142.198.206]:63378 "HELO
	smtp107.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S965165AbWEYNHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 09:07:36 -0400
To: Bill Fink <billfink@mindspring.com>
In-Reply-To: <20060525032357.4990425f.billfink@mindspring.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 25 May 2006 02:23, Bill Fink wrote:
> On Wed, 24 May 2006, Jeff Garzik wrote:
> > Brent Cook wrote:
> > > Note that this is just clearing the hardware statistics on the
> > > interface, and would not require any kind of atomic_increment addition
> > > for interfaces that support that. It would be kind-of awkward to
> > > implement this on drivers that increment stats in hardware though (lo,
> > > vlan, br, etc.) This also brings up the question of resetting the stats
> > > for 'netstat -s'
> >
> > If you don't atomically clear the statistics, then you are leaving open
> > a window where the stats could easily be corrupted, if the network
> > interface is under load.
> >
> > This 'clearing' operation has implications on the rest of the statistics
> > usage.
> >
> > More complexity, and breaking of apps, when we could just use the
> > existing, working system?  I'll take the "do nothing, break nothing,
> > everything still works" route any day.
>
> I'll admit to not knowing all the intricacies of the kernel coding
> involved, but I don't offhand see how zeroing the stats would be
> significantly more complex than updating the stats during normal usage. 
> But I'll have to leave that argument to the experts.
>

What it boils down to is that currently, a single CPU or thread ever touches 
the stats concurrently, so it doesn't have to lock them or do anything 
special to ensure that the continue incrementing. If you want to make sure 
that the statistics actually reset when you want them to, you have to account 
for this case:

  CPU0 reads current value from memory (increment)
  CPU1 writes 0 to current value in memory (reset)
  CPU0 writes incremented value to memory (increment complete)

Check out do_add_counters() in net/ipv4/netfilter/ip_tables.c
to see what's required to do this reliably in the kernel.

The current patch is fine if your hardware implements the required atomicity 
itself. Otherwise, you need a locking infrastructure to extend it to all 
network devices if you want zeroing to always work. What I'm seeing here in 
response to this is that it doesn't matter if zeroing just _mostly_ works, 
which is what you would get if you didn't lock. Eh, I'm OK with that too, but 
I think people are worried about the bugs that would get filed by admins when 
just zeroing the stats on cheap NIC x only works 90% of the time, less under 
load. Or not at all (not implemented in driver.) Then you're back to the 
userspace solution or actually implement stat locking / atomic ops.

 - Brent
