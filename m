From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 0/8] Add busy poll support for epoll
Date: Thu, 23 Mar 2017 15:38:18 -0700
Message-ID: <CAKgT0Uctdf4N-w72EY8T5Zfw=QCSCgAesXdgOh-HUYdD=Aq9AA@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain> <20170323220721.GA62356@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Samudrala, Sridhar" <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323220721.GA62356-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 23, 2017 at 3:07 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, Mar 23, 2017 at 02:36:29PM -0700, Alexander Duyck wrote:
>> This is my second pass at trying to add support for busy polling when using
>> epoll. It is pretty much a full rewrite as I have made serious changes to
>> most of the patches.
>>
>> In the v1 series I had submitted we only allowed epoll to make use of busy
>> poll when all NAPI IDs were the same. I gave this some more thought and
>> after making several other changes based on feedback from Eric Dumazet I
>> decided to try changing the main concept a bit and instead we will now
>> attempt to busy poll on the NAPI ID of the last socket added to the ready
>> list. By doing it this way we are able to take advantage of the changes
>> Eric has already made so that we get woken up by the softirq, we then pull
>> packets via busy poll, and will return to the softirq until we are woken up
>> and a new socket has been added to the ready list.
>>
>> Most of the changes in this set authored by me are meant to be cleanup or
>> fixes for various things. For example, I am trying to make it so that we
>> don't perform hash look-ups for the NAPI instance when we are only working
>> with sender_cpu and the like.
>>
>> The most complicated change of the set is probably the clean-ups for the
>> timeout. I realized that the timeout could potentially get into a state
>> where it would never timeout if the local_clock() was approaching a
>> rollover and the added busy poll usecs interval would be enough to roll it
>> over.  Because we were shifting the value you would never be able to get
>> time_after to actually trigger.
>>
>> At the heart of this set is the last 3 patches which enable epoll support
>> and add support for obtaining the NAPI ID of a given socket.  With these
>> It becomes possible for an application to make use of epoll and get optimal
>> busy poll utilization by stacking multiple sockets with the same NAPI ID on
>> the same epoll context.
>
> it all sounds awesome, but i cannot quite visualize the impact.
> Can you post some sample code/minibenchmark and numbers before/after?
>
> Thanks!
>

Anything specific you are looking for?  I can probably work with our
team internally to setup the benchmark in the next day or so.

I've been doing most of my benchmarking at my desk with sockperf with
just one thread and multiple sockets and seeing some modest savings
with my round trip times dropping from something like 18 microseconds
on average to 8 microseconds for ping-pong tests.

Thanks.

- Alex
