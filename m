From: Eric Dumazet <edumazet@google.com>
Subject: Re: struct pid memory leak
Date: Sat, 23 Jan 2016 11:50:14 -0800
Message-ID: <CANn89iLTOMxh2JZqPZ=tDUeJcfR9i1V95B5C3RTEsx7sqrBQ+Q@mail.gmail.com>
References: <CACT4Y+bZTpitMQOCyPcf4kKaXwghhEe3hmT=FtkrD3toZgoxxQ@mail.gmail.com>
	<1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160123180010.GB1609@1wt.eu>
	<CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com>
	<20160123184007.GE1609@1wt.eu>
	<CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Hocko <mhocko@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 23, 2016 at 10:46 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sat, Jan 23, 2016 at 7:40 PM, Willy Tarreau <w@1wt.eu> wrote:
>> On Sat, Jan 23, 2016 at 07:14:33PM +0100, Dmitry Vyukov wrote:
>>> I've attached my .config.
>>> Also run this program in a parallel loop. I think it's leaking not
>>> every time, probably some race is involved.
>>
>> Thank you. Just in order to confirm, am I supposed to see the
>> messages you quoted in dmesg ?
>
>
> I think the simplest way to confirm that you can reproduce it locally
> is to check /proc/slabinfo. When I run this program in a parallel
> loop, number of objects in pid cache was constantly growing:
>
> # cat /proc/slabinfo | grep pid
> pid                  297    532    576   28    4 : tunables    0    0
>   0 : slabdata     19     19      0
> ...
> pid                  412    532    576   28    4 : tunables    0    0
>   0 : slabdata     19     19      0
> ...
> pid                 1107   1176    576   28    4 : tunables    0    0
>   0 : slabdata     42     42      0
> ...
> pid                 1545   1652    576   28    4 : tunables    0    0
>   0 : slabdata     59     59      0
>
>
> If you want to use kmemleak, then you need to run this program in a
> parallel loop for some time, then stop it and then:
>
> $ echo scan > /sys/kernel/debug/kmemleak
> $ cat /sys/kernel/debug/kmemleak
>
> If kmemleak has detected any leaks, cat will show them. I noticed that
> kmemleak can delay leaks with significant delay, so usually I do scan
> at least 5 times.

Note that kmemleak is not needed.

Just run a normal kernel (eventually using slab_nomerge=1 boot cmd to
make sure 'pid' slab is not shared)

It seems that bug is rather old, as linux-4.0 has it.
