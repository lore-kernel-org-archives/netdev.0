From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: latest -git: kernel hangs when pulling the plug on 8139too
Date: Tue, 12 Aug 2008 21:02:20 +0200
Message-ID: <19f34abd0808121202p6a59917ey561ac48012fb92ca@mail.gmail.com>
References: <19f34abd0808110949n5d7d363es66325b87a8fb0fd1@mail.gmail.com>
	 <20080811192739.GB5791@martell.zuzino.mipt.ru>
	 <19f34abd0808121020l4a0552a0v3d48b181d980d600@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:37431 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbYHLTCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 15:02:21 -0400
Received: by gxk9 with SMTP id 9so188760gxk.13
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 12:02:20 -0700 (PDT)
In-Reply-To: <19f34abd0808121020l4a0552a0v3d48b181d980d600@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 7:20 PM, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> ...but after pulling the cable and seeing the keyboard blink for five
> seconds, the CPU resets without running the new kernel (i.e. it
> reboots and I see the BIOS messages, etc.).
>
> Maybe I did something wrong? (Though I don't think so.)
>
> I will try to replace some printk()s to early_printk() (allows me to
> maybe capture some messages on ttyS0 without trying to send anything
> over netconsole).

It turns out that we're not getting as far as the "panic:" line in panic().

So I tried something new: Running a bash busy loop while unplugging the cable:

    $ while true; do echo p > /proc/sysrq-trigger; done

And to my great surprise, the kernel doesn't reboot. But I can't use
it either. It's simply printing the same message to ttyS0 over and
over:

    SysRq : Show Regs

It is also occasionally garbled, like this:

    SysRq : ow Regs
    ...
    Sys : Show Regs
    ...
    SysRq : Shw Regs

(Can this be an artefact of high-speed serial console?)

I also tried to press SysRq-p from the keyboard a couple of times, but
it didn't seem to have much effect. At one point, these is this:

    SysRq : Show Regs
    vt: argh, driver_data is NULL !
    vt: argh, driver_data is NULL !
    SysRq : Show Regs

Also encountered this in the middle of everything:

    SysRq : Show Regs
    Clocksource tsc unstable (delta = 299973911855 ns)
    SysRq : Show Regs
    SysRq : Show Regs
    SysRq : Show Regs
    SysRq : Show Regs
    Clockevents: could not switch to one-shot mode: lapic is not functional.
    Could not switch to high resolution mode on CPU 0
    SysRq : Show Regs
    ...
    SysRq : Show Regs
    SysRq : <6>Clockevents: could not switch to one-shot mode: lapic
is not function
    al.
    Could not switch to high resolution mode on CPU 1
    Show Regs
    SysRq : Show Regs

Although these are all curious cases, the one piece of possibly
valuable information I might have gotten out of it is this:

    Pid: 10, comm: events/0 Not tainted (2.6.27-rc2-00325-g796aade-dirty #7)
    EIP: 0060:[<c0593a7d>] EFLAGS: 00000292 CPU: 0
    EIP is at _spin_unlock_irqrestore+0x5d/0x70
    EAX: 00000292 EBX: f6c80970 ECX: 00000003 EDX: f789a4d4
    ESI: 00000292 EDI: f6d3c430 EBP: f78a3f34 ESP: f78a3f2c
     DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
    CR0: 8005003b CR2: 00bf0f80 CR3: 35278000 CR4: 000006d0
    DR0: c0b901bc DR1: 00000000 DR2: 00000000 DR3: 00000000
    DR6: ffff0ff0 DR7: 00000400
     [<c02df3cf>] flush_to_ldisc+0x11f/0x1a0
     [<c014677a>] run_workqueue+0x15a/0x1f0
     [<c0146727>] ? run_workqueue+0x107/0x1f0
     [<c02df2b0>] ? flush_to_ldisc+0x0/0x1a0
     [<c01472ad>] worker_thread+0x7d/0xe0
     [<c0149e10>] ? autoremove_wake_function+0x0/0x50
     [<c0147230>] ? worker_thread+0x0/0xe0
     [<c0149b22>] kthread+0x42/0x70
     [<c0149ae0>] ? kthread+0x0/0x70
     [<c0105ce3>] kernel_thread_helper+0x7/0x14
     =======================
    eth0: link down
    SysR
    SysRhow Regs
    Pid: 10, comm: events/0 Not tainted (2.6.27-rc2-00325-g796aade-dirty #7)
    EIP: 0060:[<c0593abb>] EFLAGS: 00000202 CPU: 0
    EIP is at _spin_unlock_irq+0x2b/0x60
    EAX: 000bc04d EBX: c5f5ee00 ECX: f7899fe0 EDX: 00000000
    ESI: 00000000 EDI: f5111fe0 EBP: f78a3f14 ESP: f78a3f10
     DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
    CR0: 8005003b CR2: b7f3a000 CR3: 353a2000 CR4: 000006d0
    DR0: c0b901bc DR1: 00000000 DR2: 00000000 DR3: 00000000
    DR6: ffff0ff0 DR7: 00000400
     [<c013079b>] finish_task_switch+0x5b/0xc0
     [<c0130740>] ? finish_task_switch+0x0/0xc0
     [<c0590a40>] schedule+0x3a0/0x890
     [<c0159a5b>] ? trace_hardirqs_on+0xb/0x10
     [<c0149fd1>] ? prepare_to_wait+0x41/0x60
     [<c01472e5>] worker_thread+0xb5/0xe0
     [<c0149e10>] ? autoremove_wake_function+0x0/0x50
     [<c0147230>] ? worker_thread+0x0/0xe0
     [<c0149b22>] kthread+0x42/0x70
     [<c0149ae0>] ? kthread+0x0/0x70
     [<c0105ce3>] kernel_thread_helper+0x7/0x14
     =======================
    SysRhow Regs
    SysRhow Regs
    SysRhow Regs

(The stack traces are from sysrq-p, so I am not sure how to interpret it.)

Also, the netconsole is printing about the same thing (lots of Show
Regs lines), some of those also garbled, but always like this:

    ysRq : Show Regs

I'm wondering if it just got stuck sending the same packet(s) over and
over. The corruption seems to happen very regularly, anyway:

    debian@debian01:~$ nc -l -p 6666 -u | grep -b '^ysRq'
    4086:ysRq : Show Regs
    26678:ysRq : Show Regs
    49270:ysRq : Show Regs
    71844:ysRq : Show Regs
    94454:ysRq : Show Regs
    117064:ysRq : Show Regs
    139656:ysRq : Show Regs
    161104:ysRq : Show Regs
    206252:ysRq : Show Regs

(Deltas seem to be mostly 22574 and 22592.)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
