From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8736] New: New TC deadlock scenario
Date: Wed, 11 Jul 2007 11:18:03 -0700
Message-ID: <20070711111803.f8f97d98.akpm@linux-foundation.org>
References: <bug-8736-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52166 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765413AbXGKSSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:18:23 -0400
In-Reply-To: <bug-8736-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Jul 2007 08:45:12 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8736
> 
>            Summary: New TC deadlock scenario
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ranko@spidernet.net
> 
> 
> Most recent kernel where this bug did not occur: 
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Here is another scenario I bumped onto - qdisc_watchdog_cancel() and
> qdisc_restart() deadlock.
> 
> CPU#0
> qdisc_watchdog() fires and gets dev->queue_lock
> qdisc_run()...qdisc_restart()... 
> -> releases dev->queue_lock and enters dev_hard_start_xmit()
> 
> CPU#1
> tc del qdisc dev ...
> qdisc_graft()...dev_graft_qdisc()...dev_deactivate()...
> -> grabs dev->queue_lock ... 
> qdisc_reset()...{cbq,hfsc,htb,netem,tbf}_reset()...qdisc_watchdog_cancel()...
> -> hrtimer_cancel() - waiting for the qdisc_watchdog() to exit, while still
> holding dev->queue_lock
> 
> CPU#0
> dev_hard_start_xmit() returns ... 
> -> wants to get dev->queue_lock(!)
> 
> DEADLOCK!
> 
> I did not manage to get a backtrace on qdisc_watchdog stack to show them both
> but nevertheless - the above looks like the only way qdisc_watchdog_cancel
> could be sitting there.
> 
> Regards,
> 
> Ranko
> 
> ---cut---
> SysRq : Show Regs
> 
> Pid: 12790, comm:                   tc
> EIP: 0060:[<c02f13f9>] CPU: 1
> EIP is at _spin_unlock_irqrestore+0x36/0x39
>  EFLAGS: 00000282    Not tainted  (2.6.22.SNET.Thors.htbpatch.6.lockdebug #1)
> EAX: 00000000 EBX: c1d119c0 ECX: 00000000 EDX: 00000000
> ESI: 00000282 EDI: c1d11a18 EBP: 00000000 DS: 007b ES: 007b FS: 00d8
> CR0: 80050033 CR2: 008ba828 CR3: 20dc2000 CR4: 000006d0
>  [<c0132ff4>] hrtimer_try_to_cancel+0x33/0x66
>  [<c013007b>] kthread+0xf/0x57
>  [<c0133035>] hrtimer_cancel+0xe/0x14
>  [<c029daaf>] qdisc_watchdog_cancel+0x8/0x11
>  [<f8b8541d>] htb_reset+0x9c/0x14b [sch_htb]
>  [<c029c2ad>] qdisc_reset+0x10/0x11
>  [<c029c3e7>] dev_deactivate+0x27/0xa5
>  [<c029d7a6>] dev_graft_qdisc+0x81/0xa5
>  [<c029d7f2>] qdisc_graft+0x28/0x88
>  [<c029df93>] tc_get_qdisc+0x15d/0x1e9
>  [<c029de36>] tc_get_qdisc+0x0/0x1e9
>  [<c0297038>] rtnetlink_rcv_msg+0x1c2/0x1f5
>  [<c02a1834>] netlink_run_queue+0x96/0xfd
>  [<c0296e76>] rtnetlink_rcv_msg+0x0/0x1f5
>  [<c0296e28>] rtnetlink_rcv+0x26/0x42
>  [<c02a1d5c>] netlink_data_ready+0x12/0x54
>  [<c02a0abe>] netlink_sendskb+0x1c/0x33
>  [<c02a1c6b>] netlink_sendmsg+0x1f3/0x2d2
>  [<c0284d06>] sock_sendmsg+0xe2/0xfd
>  [<c013030d>] autoremove_wake_function+0x0/0x37
>  [<c013030d>] autoremove_wake_function+0x0/0x37
>  [<c01d79c3>] copy_from_user+0x2d/0x59
>  [<c0284e4e>] sys_sendmsg+0x12d/0x243
>  [<c02f12fd>] _read_unlock_irq+0x20/0x23
>  [<c013a49e>] trace_hardirqs_on+0xac/0x149
>  [<c0148c78>] find_get_page+0x11/0x49
>  [<c015585e>] __handle_mm_fault+0x19d/0x947
>  [<c02f0f87>] _spin_unlock+0x14/0x1c
>  [<c01558e5>] __handle_mm_fault+0x224/0x947
>  [<c028608a>] sys_socketcall+0x24f/0x271
>  [<c0103370>] restore_nocheck+0x12/0x15
>  [<c010329e>] sysenter_past_esp+0x5f/0x99
>  =======================
> 

