From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH v2 5/8] net: Track start of busy loop instead of
 when it should end
Date: Thu, 23 Mar 2017 20:42:27 -0700
Message-ID: <CAKgT0Ue+UFOAhwxN-EOjWYZa9YZc2QaT5gvoLap70COs0rF7NA@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
 <20170323213742.12615.85793.stgit@localhost.localdomain> <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Linux API <linux-api@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 6:24 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-23 at 14:37 -0700, Alexander Duyck wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>
>> The last bit I changed is to move from using a shift by 10 to just using
>> NSEC_PER_USEC and using multiplication for any run time calculations and
>> division for a few compile time ones.  This should be more accurate and
>> perform about the same on most architectures since modern CPUs typically
>> handle multiplication without too much overhead.
>
>
> busy polling thread can be preempted for more than 2 seconds.

If it is preempted is the timing value even valid anymore?  I was
wondering about that.  Also when preemption is enabled is there
anything to prevent us from being migrated to a CPU?  If so what do we
do about architectures that allow drift between the clocks?

> Using usec instead of nanoseconds gave us 3 orders of magnitude cushion.

Yes, but the problem is we also opened up an issue where if the clock
was approaching a roll-over we could add a value to it that would put
us in a state where we would never time out.

> We do not need nsec accuracy for busy polling users, if this restricts
> range and usability under stress.

Yes and no.  So the standard use cases suggest using values of 50 to
100 microseconds.  I suspect that for most people that is probably
what they are using.  The addition of preemption kind of threw a
wrench in the works because now instead of spending that time busy
polling you can get preempted and then are off doing something else
for the entire period of time.

What would you think of changing this so that instead of tracking the
total time this function is active, instead we tracked the total time
we spent with preemption disabled?  What I would do is move the
start_time configuration to just after the preempt_disable() call.
Then if we end up yielding to another thread we would just reset the
start_time when we restarted instead of trying to deal with all the
extra clock nonsense that we would have to deal with otherwise since I
don't know if we actually want to count time where we aren't actually
doing anything.  In addition this would bring us closer to how NAPI
already works since it essentially will either find an event, or if we
time out we hand it off to the softirq which in turn can handle it or
hand it off to softirqd.  The only item that might be a bit more
difficult to deal with then would be the way the times are used in
fs/select.c but I don't know if that is really the right way to go
anyway. With the preemption changes and such it might just make sense
to drop those bits and rely on just the socket polling alone.

The other option is to switch over everything from using unsigned long
to using uint64_t and time_after64.  Then we can guarantee the range
needed and then some, but then we are playing with a u64 time value on
32b architectures which might be a bit more expensive.  Even with that
though I still need to clean up the sysctl since it doesn't make sense
to allow negative values for the busy_poll usec to be used which is
currently the case.

Anyway let me know what you think and I can probably spin out a new
set tomorrow.

- Alex
