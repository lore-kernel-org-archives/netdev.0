From: george anzinger <george@mvista.com>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 00:25:46 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <accsv8$fka$2@main.gmane.org>
References: <Pine.LNX.4.33.0205201836160.9301-100000@w-nivedita2.des.beaverton.ibm.com>
		<3CE9E466.AC2358EE@mvista.com> <20020520.230021.29510217.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: george anzinger <george@mvista.com>
>    Date: Mon, 20 May 2002 23:08:38 -0700
> 
>    Nivedita Singhvi wrote:
>    >
>    > On Mon, 20 May 2002, David S. Miller wrote:
>    >
>    > > Such rule does not even make this piece of code legal.  Consider:
>    > >
>    > > task1:cpu0:   x = counters[smp_processor_id()];
>    > >       cpu0:   PREEMPT
>    > > task2:cpu0:   x = counters[smp_processor_id()];
>    > > task2:cpu0:   counters[smp_processor_id()] = x + 1;
>    > >       cpu0:   PREEMPT
>    > > task1:cpu0:   counters[smp_processor_id()] = x + 1;
>    > >               full garbage
> 
>    May be someone could tell me if these matter.  If you are
>    bumping a counter and you switch cpus in the middle, a.)
>    does it matter? and b.) if so which cpu should get the
>    count?  I sort of thought that, if this were going on, it
>    did not really matter as long as some counter was bumped.
> 
> That's not the problem.  We use per-cpu values for each counter (and
> when the user asks for the value, we add together the values from
> each processor).
> 
> Please review the example I quote above, you aren't reading it
> carefully enough.
> 
> Let us imagine that we are dealing with counter "X", and
> that the values at the beginning of the example are:
> 
>         X[0] = 5
>         X[1] = 7
>         X[2] = ...
> 
> Actually, no values matter for the purposes of this example
> except the one for cpu 0.  Here is what happens, watch carefully:
> 
>    > > task1:cpu0:   x = counters[smp_processor_id()];
>    > >       cpu0:   PREEMPT
> 
> task1 sees 'x' as '5'
> 
>    > > task2:cpu0:   x = counters[smp_processor_id()];
>    > > task2:cpu0:   counters[smp_processor_id()] = x + 1;
>    > >       cpu0:   PREEMPT
> 
> task2 bumps the counter to '6'
> 
>    > > task1:cpu0:   counters[smp_processor_id()] = x + 1;
>    > >               full garbage
> 
> task1 also bumps the counter to '6'
> 
> This is the problem.  We make these counters non-atomic on purpose
> for performance reasons, so do not mention that as a possible fix.

I understand the issue.  The question is what is the
result.  Bogus numbers do.. what?  Does the kernel crash or
does the user think strange things while every thing just
keeps on working?

As for the fix, I would think that would be more up to the
network folks than me.  Atomic is one option, but you can
also disable preemption.  It is really light weight, and may
already be disabled in some of these cases.

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
