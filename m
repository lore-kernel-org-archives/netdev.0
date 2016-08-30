From: Nikolay Borisov <kernel@kyup.com>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Tue, 30 Aug 2016 12:31:04 +0300
Message-ID: <57C55258.8070509@kyup.com>
References: <57BDAE06.1040400@kyup.com>
 <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAOssrKddiaWQX+v7FZTJg9mwyhxHJCDQQMUJVwP17-z1ATrKWA@mail.gmail.com>
 <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
 <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Miklos Szeredi <mszeredi@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/30/2016 12:18 PM, Miklos Szeredi wrote:
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

I have no way of being 100% sure but looking through nginx's source code
it seems they do utilize MSG_PEEK on several occasions. This issue has
been apparently very hard to reproduce since I have 100s of servers
running a lot of  NGINX processes and this has been triggered only once.

On a different note - if I inspect a live node without this patch should
the discrepancy between the gc_inflight_list and the unix_tot_inflight
be present VS with this patch applied?

> 
> Thanks,
> Miklos
> 
