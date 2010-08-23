From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 16617] New: inconsistent lock state at boot
Date: Mon, 23 Aug 2010 12:18:37 -0700
Message-ID: <20100823121837.e246fb69.akpm@linux-foundation.org>
References: <bug-16617-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>, casteyde.christian@free.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60037 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753158Ab0HWTTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 15:19:24 -0400
In-Reply-To: <bug-16617-27@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 17 Aug 2010 20:05:55 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=16617
> 
>            Summary: inconsistent lock state at boot
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.36-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: casteyde.christian@free.fr
>         Regression: Yes
> 
> 
> Kernel 2.6.36-rc1
> Athlon64 X2 4200 in 64bit mode
> Slackware64 13.1
> 1 GB RAM
> 
> Since 2.6.36-rc1 with debug options activated (lock validation, kmemcheck,
> etc.), I get the following error at boot:
> 
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> uli526x: eth0 NIC Link is Up 100 Mbps Full duplex
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> 
> =================================
> [ INFO: inconsistent lock state ]
> 2.6.36-rc1 #2
> ---------------------------------
> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> iptables/1915 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (&(&lock->lock)->rlock){+.?...}, at: [<ffffffff814d7c01>]
> get_counters+0x111/0x1c0
> {IN-SOFTIRQ-W} state was registered at:
>   [<ffffffff81074e66>] __lock_acquire+0xb96/0x1c10
>   [<ffffffff81075f3a>] lock_acquire+0x5a/0x70
>   [<ffffffff81595996>] _raw_spin_lock+0x36/0x50
>   [<ffffffff8152bfc8>] ip6t_do_table+0x88/0x4e0
>   [<ffffffff8152e437>] ip6table_filter_hook+0x17/0x20
>   [<ffffffff8147ef54>] nf_iterate+0x64/0xa0
>   [<ffffffff8147f034>] nf_hook_slow+0xa4/0x150
>   [<ffffffff815196ab>] mld_sendpack+0x28b/0x4d0
>   [<ffffffff8151a10b>] mld_ifc_timer_expire+0x27b/0x310
>   [<ffffffff8104fade>] run_timer_softirq+0x1ae/0x2e0
>   [<ffffffff810499a0>] __do_softirq+0xc0/0x160
>   [<ffffffff8100324c>] call_softirq+0x1c/0x30
>   [<ffffffff81005585>] do_softirq+0x75/0xb0
>   [<ffffffff810494d5>] irq_exit+0x95/0xa0
>   [<ffffffff8101f5fa>] smp_apic_timer_interrupt+0x6a/0xa0
>   [<ffffffff81002d13>] apic_timer_interrupt+0x13/0x20
>   [<ffffffff81165c1d>] ext4_lookup+0x9d/0x110
>   [<ffffffff810d8f1b>] do_lookup+0x1db/0x270
>   [<ffffffff810db135>] link_path_walk+0x445/0xbe0
>   [<ffffffff810dba40>] path_walk+0x60/0xe0
>   [<ffffffff810dbbc3>] do_path_lookup+0x53/0x60
>   [<ffffffff810dc803>] user_path_at+0x53/0xa0
>   [<ffffffff810d2ed7>] vfs_fstatat+0x37/0x70
>   [<ffffffff810d2f46>] vfs_stat+0x16/0x20
>   [<ffffffff810d311f>] sys_newstat+0x1f/0x50
>   [<ffffffff810023ab>] system_call_fastpath+0x16/0x1b
> irq event stamp: 73961
> hardirqs last  enabled at (73961): [<ffffffff810497ae>]
> local_bh_enable+0x7e/0x100
> hardirqs last disabled at (73959): [<ffffffff81049761>]
> local_bh_enable+0x31/0x100
> softirqs last  enabled at (73960): [<ffffffff814d7b6b>] get_counters+0x7b/0x1c0
> softirqs last disabled at (73914): [<ffffffff814d7b1e>] get_counters+0x2e/0x1c0
> 
> other info that might help us debug this:
> 2 locks held by iptables/1915:
>  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff8149c35a>]
> ip_getsockopt+0x6a/0xb0
>  #1:  (&xt[i].mutex){+.+.+.}, at: [<ffffffff8148ac4e>]
> xt_find_table_lock+0x3e/0x120
> 
> stack backtrace:
> Pid: 1915, comm: iptables Not tainted 2.6.36-rc1 #2
> Call Trace:
>  [<ffffffff81072371>] print_usage_bug+0x181/0x1d0
>  [<ffffffff810727d9>] mark_lock+0x419/0x630
>  [<ffffffff81074edc>] __lock_acquire+0xc0c/0x1c10
>  [<ffffffff815957b8>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff815957b8>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff815957b8>] ? trace_hardirqs_off_thunk+0x3a/0x3c
>  [<ffffffff81075f3a>] lock_acquire+0x5a/0x70
>  [<ffffffff814d7c01>] ? get_counters+0x111/0x1c0
>  [<ffffffff81072d2d>] ? trace_hardirqs_on_caller+0x13d/0x180
>  [<ffffffff81595996>] _raw_spin_lock+0x36/0x50
>  [<ffffffff814d7c01>] ? get_counters+0x111/0x1c0
>  [<ffffffff810497ae>] ? local_bh_enable+0x7e/0x100
>  [<ffffffff814d7c01>] get_counters+0x111/0x1c0
>  [<ffffffff814d7cde>] alloc_counters+0x2e/0x50
>  [<ffffffff814d94cd>] ? do_ipt_get_ctl+0xfd/0x3a0
>  [<ffffffff814d95b1>] do_ipt_get_ctl+0x1e1/0x3a0
>  [<ffffffff81072d7d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff814808b0>] nf_sockopt+0x90/0xa0
>  [<ffffffff814808d3>] nf_getsockopt+0x13/0x20
>  [<ffffffff8149c370>] ip_getsockopt+0x80/0xb0
>  [<ffffffff814ba391>] raw_getsockopt+0x11/0x30
>  [<ffffffff8145242f>] sock_common_getsockopt+0xf/0x20
>  [<ffffffff8144f3d0>] sys_getsockopt+0x60/0xc0
>  [<ffffffff810023ab>] system_call_fastpath+0x16/0x1b
> 
> I haven't managed to find the faulty module.
> 

