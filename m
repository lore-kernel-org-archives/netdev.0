From: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v2 5/8] net: Track start of busy loop instead of
 when it should end
Date: Fri, 24 Mar 2017 08:48:13 -0700
Message-ID: <CAKgT0UeWdiOwKz2rqK64xPvHM-W5eZdEfHW4SvN0QMHWD79_-w@mail.gmail.com>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
 <20170323213742.12615.85793.stgit@localhost.localdomain> <1490318682.9687.22.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Ue+UFOAhwxN-EOjWYZa9YZc2QaT5gvoLap70COs0rF7NA@mail.gmail.com>
 <1490329655.9687.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UfQPLqHtZ_SjanbLoG6t5f36C4nsORuw6yjLT0xZrEoEQ@mail.gmail.com> <1490354210.9687.44.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Samudrala, Sridhar" <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490354210.9687.44.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 24, 2017 at 4:16 AM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Thu, 2017-03-23 at 22:55 -0700, Alexander Duyck wrote:
>
>> Right, but time_after assumes roll over.  When you are using a time
>> value based off of local_clock() >> 10, you don't ever roll over when
>> you do addition.  Just the clock rolls over.  At least on 64 bit
>> systems.
>>
>> So if local time approaches something like all 1's, and we have
>> shifted it by 10 it is then the max it can ever reach is
>> 0x003FFFFFFFFFFFFF.  I can add our loop time to that and it won't roll
>> over.  In the mean time the busy_loop_us_ can never exceed whatever I
>> added to that so we are now locked into a loop.  I realize I am
>> probably being pedantic, and it will have an exceedingly small rate of
>> occurrence, but it is still an issue.
>
> Do you realize that a 64bit clock wont rollover before the host has
> reached 584 years of uptime ?

Yeah, that is what I meant by "probably being pedantic".  I was being
a too much of a perfectionist.

So I can work with the ">> 10" approach.  The only thing I think I may
still want to change is that on 32b systems I will still use the
do_procintvec_minmax for busy_poll and busy_read to prevent us from
inputting values less than 0. For 64b systems we can do_procuintvec.
It isn't so much that I don't trust root, it is just that we didn't
really document the ranges anywhere for this so I figure if we at
least lock that down to the usable ranges since root may not be aware
of the implementation details.
