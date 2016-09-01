From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Thu, 1 Sep 2016 11:13:00 +0200
Message-ID: <87640044-f4a6-d919-46b9-01c4f4f11260@stressinduktion.org>
References: <57BDAE06.1040400@kyup.com>
 <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAOssrKddiaWQX+v7FZTJg9mwyhxHJCDQQMUJVwP17-z1ATrKWA@mail.gmail.com>
 <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
 <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Nikolay Borisov <kernel@kyup.com>,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Miklos Szeredi <mszeredi@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.08.2016 11:18, Miklos Szeredi wrote:
> On Tue, Aug 30, 2016 at 12:37 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:
>> On Sat, Aug 27, 2016 at 11:55 AM, Miklos Szeredi <mszeredi@redhat.com> wrote:
> 
>> crash> list -H gc_inflight_list unix_sock.link -s unix_sock.inflight |
>> grep counter | cut -d= -f2 | awk '{s+=$1} END {print s}'
>> 130
>> crash> p unix_tot_inflight
>> unix_tot_inflight = $2 = 135
>>
>> We've lost track of a total of five inflight sockets, so it's not a
>> one-off thing.  Really weird...  Now off to sleep, maybe I'll dream of
>> the solution.
> 
> Okay, found one bug: gc assumes that in-flight sockets that don't have
> an external ref can't gain one while unix_gc_lock is held.  That is
> true because unix_notinflight() will be called before detaching fds,
> which takes unix_gc_lock.  Only MSG_PEEK was somehow overlooked.  That
> one also clones the fds, also keeping them in the skb.  But through
> MSG_PEEK an external reference can definitely be gained without ever
> touching unix_gc_lock.
> 
> Not sure whether the reported bug can be explained by this.  Can you
> confirm the MSG_PEEK was used in the setup?
> 
> Does someone want to write a stress test for SCM_RIGHTS + MSG_PEEK?
> 
> Anyway, attaching a fix that works by acquiring unix_gc_lock in case
> of MSG_PEEK also.  It is trivially correct, but I haven't tested it.

You can use spin_unlock_wait in unix_gc_barrier to make it a bit more
lightweight.

Anyway, all of the scans on the socket receive queues are actually
protected by the appropriate locks again, I didn't see a way were we
could result in such a crash because of concurrent modification of the
receive queue. Do you have any hints or looked into this more closely?

Thanks,
Hannes
