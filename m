From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Wed, 31 Mar 2004 23:28:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331212817.GQ2143@dualathlon.random>
References: <20040329222926.GF3808@dualathlon.random> <200403302005.AAA00466@yakov.inr.ac.ru> <20040330211450.GI3808@dualathlon.random> <20040330133000.098761e2.davem@redhat.com> <20040330213742.GL3808@dualathlon.random> <20040331171023.GA4543@in.ibm.com> <16491.4593.718724.277551@robur.slu.se> <20040331203750.GB4543@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dipankar Sarma <dipankar@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040331203750.GB4543@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 01, 2004 at 02:07:50AM +0530, Dipankar Sarma wrote:
> On Wed, Mar 31, 2004 at 08:46:09PM +0200, Robert Olsson wrote:
> Content-Description: message body text
> > Before run
> > 
> > total    droppped tsquz    throttl  bh_enbl  ksoftird irqexit  other   
> > 00000000 00000000 00000000 00000000 000000e8 0000017e 00030411 00000000
> > 00000000 00000000 00000000 00000000 000000ae 00000277 00030349 00000000
> > 
> > After DoS (See description from previous mail)
> > 
> > total    droppped tsquz    throttl  bh_enbl  ksoftird irqexit  other    
> > 00164c55 00000000 000021de 00000000 000000fc 0000229f 0003443c 00000000
> > 001695e7 00000000 0000224d 00000000 00000162 0000236f 000342f7 00000000
> > 
> > So the major part of softirq's are run from irqexit and therefor out of 
> > scheduler control. This even with RX polling (eth0, eth2) We still have 
> > some TX interrupts plus timer interrupts now at 1000Hz. Which probably 
> > reduces the number of softirq's that ksoftirqd runs.
> 
> So, NAPI or not we get userland stalls due to packetflooding.

indeed, the most of the softirq load happens within irqs even with NAPI
as we were talking about, so Alexey and DaveM were wrong about the
hardirq load being non significant.

Maybe the problem is simply that NAPI should be tuned more aggressively,
it may have to poll for a longer time before giving up.

> Looking at some of the old patches we discussed privately, it seems
> this is what was done earlier -
> 
> 1. Use rcu-softirq.patch which provides call_rcu_bh() for softirqs
>    only.

this is the one I prefer if it performs.

> 2. Limit non-ksoftirqd softirqs - get a measure of userland stall (using
>    an api rcu_grace_period(cpu)) and if it is too long, expire
>    the timeslice of the current process  and start sending everything to 
>    ksoftirqd.

yep, this may be desiderable eventually just to be fair with tasks, but
I believe it's partly an orthogonal with the rcu grace period length.

> By reducing the softirq time at the back of a hardirq or local_bh_enable(),
> we should be able to bring a bit more fairness. I am working on the
> patches, will test and publish later. 

I consider this as the approch number 2 too.
