From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [regression, 2.6.37-rc1] 'ip link tap0 up' stuck in do_exit()
Date: Wed, 8 Dec 2010 14:41:16 +0100
Message-ID: <20101208134116.GA16923@redhat.com>
References: <20101103062609.GB31163@dastard> <1288768402.2467.665.camel@edumazet-laptop> <20101103103448.GA9169@dastard> <20101103112936.GB9169@dastard> <20101104002140.GA13830@dastard> <20101104054718.GC5210@cr0.nay.redhat.com> <20101208100245.01cf23c5@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Dave Chinner <david@fromorbit.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Mickler <florian@mickler.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101208100245.01cf23c5@schatten.dmk.lab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08, Florian Mickler wrote:
>
> [ ccing Ingo and Oleg ] as suggested

Well. Of course I can't explain this bug. But, looking at this email
I do not see amything strange in exit/schedule/etc.

> > >> > > > This is resulting in the command 'ip link set tap0 up' hanging as a zombie:
> > >> > > >
> > >> > > > root      3005     1  0 16:53 pts/3    00:00:00 /bin/sh /vm-images/qemu-ifup tap0
> > >> > > > root      3011  3005  0 16:53 pts/3    00:00:00 /usr/bin/sudo /sbin/ip link set tap0 up
> > >> > > > root      3012  3011  0 16:53 pts/3    00:00:00 [ip] <defunct>

That is. ip is a zombie.

> > >> > > > In do_exit() with this trace:
> > >> > > >
> > >> > > > [ 1630.782255] ip            x ffff88063fcb3600     0  3012   3011 0x00000000
> > >> > > > [ 1630.789121]  ffff880631328000 0000000000000046 0000000000000000 ffff880633104380
> > >> > > > [ 1630.796524]  0000000000013600 ffff88062f031fd8 0000000000013600 0000000000013600
> > >> > > > [ 1630.803925]  ffff8806313282d8 ffff8806313282e0 ffff880631328000 0000000000013600
> > >> > > > [ 1630.811324] Call Trace:
> > >> > > > [ 1630.813760]  [<ffffffff8104a90d>] ? do_exit+0x716/0x724
> > >> > > > [ 1630.818964]  [<ffffffff8104a995>] ? do_group_exit+0x7a/0xa4
> > >> > > > [ 1630.824512]  [<ffffffff8104a9d1>] ? sys_exit_group+0x12/0x16
> > >> > > > [ 1630.830149]  [<ffffffff81009a82>] ? system_call_fastpath+0x16/0x1b
> > >> > > >
> > >> > > > The address comes down to the schedule() call:
> > >> > > >
> > >> > > > (gdb) l *(do_exit+0x716)
> > >> > > > 0xffffffff8104a90d is in do_exit (kernel/exit.c:1034).
> > >> > > > 1029            preempt_disable();
> > >> > > > 1030            exit_rcu();
> > >> > > > 1031            /* causes final put_task_struct in finish_task_switch(). */
> > >> > > > 1032            tsk->state = TASK_DEAD;
> > >> > > > 1033            schedule();
> > >> > > > 1034            BUG();
> > >> > > > 1035            /* Avoid "noreturn function does return".  */
> > >> > > > 1036            for (;;)
> > >> > > > 1037                    cpu_relax();    /* For when BUG is null */
> > >> > > > 1038    }

Everything is correct. The task is dead, but it wasn't released by its
parent, task_struct (and thus the stack) is still visible.

> > Interesting, the scheduler failed to put the dead task out of
> > run queue, so to me this is likely to be a scheduler bug.
> > I have no idea how sudo can change the behaviour here.
> >
> > Another guess is we need a smp_wmb() before schedule() above.

No, everything looks fine.

For example,

	$ perl -le 'print fork || exit; <>'
	17436

	$ ps 17436
	  PID TTY      STAT   TIME COMMAND
	17436 pts/22   Z+     0:00 [perl] <defunct>

	$ cat /proc/17436/stack
	[<ffffffff8104d3a0>] do_exit+0x6c4/0x6d2
	[<ffffffff8104d429>] do_group_exit+0x7b/0xa4
	[<ffffffff8104d469>] sys_exit_group+0x17/0x1b
	[<ffffffff8100bdb2>] system_call_fastpath+0x16/0x1b
	[<ffffffffffffffff>] 0xffffffffffffffff

Oleg.
