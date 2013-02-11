From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [flow_cache_new_hashrnd] WARNING: at kernel/smp.c:328
 smp_call_function_single()
Date: Mon, 11 Feb 2013 10:03:09 +0100
Message-ID: <20130211090309.GA23932@gmail.com>
References: <20130211085600.GB10857@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuansheng Liu <chuansheng.liu@intel.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130211085600.GB10857@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Fengguang Wu <fengguang.wu@intel.com> wrote:

> Greetings,
> 
> I got the below oops and the first bad commit is

It's a one-time warning, not an actual crash, right?

> commit b29f39c7c3e75a741a7da88244ec707f293ec04c
> Author: Chuansheng Liu <chuansheng.liu@intel.com>
> Date:   Wed Feb 6 23:18:21 2013 +0800
> 
>     smp: Give WARN()ing if in_interrupt() when calling smp_call_function_many()/single()

So this commit was supposed to warn about instances where an IPI 
is generated from hardirq context in essence.

But this:

> [  229.341176]  [<ffffffff810353b4>] warn_slowpath_common+0x83/0x9c
> [  229.343091]  [<ffffffff817089d6>] ? flow_cache_new_hashrnd+0x98/0x98
> [  229.345105]  [<ffffffff810353e7>] warn_slowpath_null+0x1a/0x1c
> [  229.346978]  [<ffffffff81090793>] smp_call_function_single+0xbd/0x1c7
> [  229.349017]  [<ffffffff81090afe>] smp_call_function_many+0x121/0x23e
> [  229.350996]  [<ffffffff817089d6>] ? flow_cache_new_hashrnd+0x98/0x98
> [  229.353005]  [<ffffffff81090e09>] smp_call_function+0x37/0x40
> [  229.354860]  [<ffffffff8170907e>] flow_cache_flush+0x72/0xa0
> [  229.356735]  [<ffffffff81759e33>] xfrm_dev_event+0x14/0x20
> [  229.358545]  [<ffffffff817ff8b0>] notifier_call_chain+0x65/0x95
> [  229.360469]  [<ffffffff8105ce16>] __raw_notifier_call_chain+0xe/0x10
> [  229.362453]  [<ffffffff8105ce2c>] raw_notifier_call_chain+0x14/0x16
> [  229.364453]  [<ffffffff816f63d6>] call_netdevice_notifiers+0x4a/0x4f
> [  229.366434]  [<ffffffff816fa2ab>] __dev_notify_flags+0x37/0x5b
> [  229.368342]  [<ffffffff816fa318>] dev_change_flags+0x49/0x54
> [  229.370184]  [<ffffffff8174574a>] devinet_ioctl+0x24f/0x542
> [  229.372036]  [<ffffffff81746975>] inet_ioctl+0x97/0xb1
> [  229.373774]  [<ffffffff816e5042>] sock_do_ioctl.constprop.42+0x18/0x37
> [  229.375791]  [<ffffffff816e5480>] sock_ioctl+0x1fd/0x20a
> [  229.377648]  [<ffffffff810bb9cd>] ? trace_buffer_lock_reserve+0x41/0x56
> [  229.379701]  [<ffffffff8112b7c6>] vfs_ioctl+0x26/0x39
> [  229.381459]  [<ffffffff8112c0d2>] do_vfs_ioctl+0x41b/0x45e
> [  229.383269]  [<ffffffff8100bc3a>] ? ftrace_raw_event_sys_enter+0x10b/0x11a
> [  229.385404]  [<ffffffff817fc118>] ? retint_swapgs+0x13/0x1b
> [  229.387227]  [<ffffffff8112c15a>] sys_ioctl+0x45/0x73
> [  229.388975]  [<ffffffff818034be>] tracesys+0xd0/0xd5
> [  229.390665] ---[ end trace c47a5dd12e99cb04 ]---

... is syscall/ioctl context, so the warning is bogus - possibly 
the notifier there runs with bhs disabled and thus 
in_interrupt() triggers?

It should probably use in_irq() - while double checking whether 
that works on non-genirq platforms.

Anyway, the commit needs more work so I've zapped the commit for 
now.

Thanks,

	Ingo
