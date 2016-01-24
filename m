From: Willy Tarreau <w@1wt.eu>
Subject: Re: struct pid memory leak
Date: Sun, 24 Jan 2016 03:11:45 +0100
Message-ID: <20160124021145.GA12367@1wt.eu>
References: <CACT4Y+bZTpitMQOCyPcf4kKaXwghhEe3hmT=FtkrD3toZgoxxQ@mail.gmail.com> <1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com> <20160123180010.GB1609@1wt.eu> <CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com> <20160123184007.GE1609@1wt.eu> <CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Hocko <mhocko@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Eric Dumazet <edumazet@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:28455 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbcAXCMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jan 2016 21:12:01 -0500
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 07:46:45PM +0100, Dmitry Vyukov wrote:
> On Sat, Jan 23, 2016 at 7:40 PM, Willy Tarreau <w@1wt.eu> wrote:
> > On Sat, Jan 23, 2016 at 07:14:33PM +0100, Dmitry Vyukov wrote:
> >> I've attached my .config.
> >> Also run this program in a parallel loop. I think it's leaking not
> >> every time, probably some race is involved.
> >
> > Thank you. Just in order to confirm, am I supposed to see the
> > messages you quoted in dmesg ?
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

OK got it and indeed I can see it grow. In fact, the active column grows and
once it reaches the num objects, this one grows in turn, which makes sense.

All I can say now is that it doesn't need to run over multiple processes
to leak, though that makes it easier. SMP is not needed either.

> If you want to use kmemleak, then you need to run this program in a
> parallel loop for some time, then stop it and then:
> 
> $ echo scan > /sys/kernel/debug/kmemleak
> $ cat /sys/kernel/debug/kmemleak
> 
> If kmemleak has detected any leaks, cat will show them. I noticed that
> kmemleak can delay leaks with significant delay, so usually I do scan
> at least 5 times.

Thank you for these information.

I've tested on an older (3.14) kernel and I can see the effect there as well.
I don't have "pid" in slabinfo, but launching 1000 processes at a time uses
a few tens to hundreds kB of RAM on each round. 3.10 doesn't seem affected,
I'm seeing the memory grow to a fixed point if I increase the number of
parallel processes but then even after a few tens of thousands of processes,
the reported used memory doesn't seem to increase (remember no "pid" entry
here).

kmemleak indeed reports me something on 3.14 which seems to match your
trace as I'm seeing bash as the process (instead of syz-executor in your
case) and alloc_pid() calls kmem_cache_alloc() :

Unreferenced object 0xffff88003facd000 (size 128):
  comm "bash", pid 1822, jiffies 4294951223 (age 15.280s)
  hex dump (first 32 bytes):
    01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff810dfc22>] kmem_cache_alloc+0x92/0xe0
    [<ffffffff81065d74>] alloc_pid+0x24/0x4a0
    [<ffffffff81180a93>] cpumask_any_but+0x23/0x40
    [<ffffffff8104b258>] copy_process.part.66+0x1068/0x16e0
    [<ffffffff812038db>] n_tty_write+0x37b/0x4f0
    [<ffffffff812003d1>] tty_write+0x1c1/0x2a0
    [<ffffffff8104ba90>] do_fork+0xe0/0x340
    [<ffffffff81058b30>] __set_task_blocked+0x30/0x80
    [<ffffffff8105af38>] __set_current_blocked+0x38/0x60
    [<ffffffff813b6e39>] stub_clone+0x69/0x90
    [<ffffffff813b6b59>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff

It doesn't report this on 3.10.

Unfortunately I feel totally incompetent on the subject :-/

Willy
