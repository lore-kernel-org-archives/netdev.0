From: Chris Caputo <ccaputo@alt.net>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 02:43:13 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net>
References: <20081010090426.GA6054@ff.dom.local>
	<20081010095129.GB6054@ff.dom.local>
	<48F6FB3E.7060903@bigtelecom.ru> <20081016084027.GA17632@ff.dom.local>
	<48FEC302.5090707@bigtelecom.ru> <20081022070200.GB4178@ff.dom.local>
	<493FDCD4.5020108@bigtelecom.ru> <20081
	<20081218081737.GA8416@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:35274 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749AbZANCtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 21:49:55 -0500
In-Reply-To: <20081218081737.GA8416@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2008, Jarek Poplawski wrote:
> On Thu, Dec 18, 2008 at 09:43:51AM +0300, Badalian Vyacheslav wrote:
> > Hello
> > result: Patch 2+3 = uptime 7 days without crashes.
> > May i revert patches and try single new patch?
> 
> Here is my current opinion on this bug:
> 
> 1) I'm almost sure it's not a htb, but hrtimers bug (some race),
> 
> 2) the htb patches you've tested are not "the proper" way of fixing
>    it; I see substantial changes in hrtimers code in the "-tip" tree
>    (probably for 2.6.29), which, probably, you'll be advised by
>    hrtimers maintainers to try, and I guess, it's not easy on a
>    production system,
> 
> So, it's up to you:
> 
> 1) since these patches work for you, you can stop with testing and
>    wait with these patched kernels until 2.6.29 (I can propose this
>    #2 patch as a temporary fix then),
> 
> 2) for curiosity you could try this patch #4 alone on one box first
>    (after reverting at least patch #2), but again: if it works, it
>    could be only treated as a temporary hack, and alternative of #2.

I think I am hitting the same issue discussed in this thread and:

 http://bugzilla.kernel.org/show_bug.cgi?id=11718

and wanted to share my data.

My system:

 2x Xeon @ 3.06ghz
 CONFIG_HZ=250
 CONFIG_HIGH_RES_TIMERS=y
 CONFIG_NO_HZ=y
 (please let me know if more details are useful)

With 2.6.27.10 after around 30 minutes or an hour, server tends to hang 
with:

 Pid: 0, comm: swapper Not tainted (2.6.27.10 #1)
 EIP: 0060:[<c023199f>] EFLAGS: 00000286 CPU: 0
 EIP is at run_hrtimer_pending+0x31/0xb8
 EAX: f6c1d468 EBX: c039b2ae ECX: 00000002 EDX: 00000001
 ESI: f6c1d468 EDI: c1807e20 EBP: c0587f28 ESP: c0587f18
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 CR0: 8005003b CR2: 09a36358 CR3: 36d64000 CR4: 000006d0
 DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
 DR6: ffff0ff0 DR7: 00000400
  [<c0231a3c>] run_hrtimer_softirq+0x16/0x18
  [<c0223e6d>] __do_softirq+0x64/0xcd
  [<c0223f0b>] do_softirq+0x35/0x3a
  [<c0224199>] irq_exit+0x38/0x6d
  [<c020eefb>] smp_apic_timer_interrupt+0x71/0x82
  [<c0203640>] apic_timer_interrupt+0x28/0x30
  [<c0207f9d>] ? default_idle+0x2d/0x42
  [<c0201946>] cpu_idle+0xca/0xea
  [<c045194e>] rest_init+0x4e/0x50

One time with 2.6.27.10:

 BUG: unable to handle kernel NULL pointer dereference at 000000
  [<c0239b6b>] smp_call_function+0x12/0x14
  [<c020df20>] native_smp_send_stop+0x1b/0x28
  [<c0220304>] panic+0x47/0xdf
  [<c0203ac2>] oops_end+0x5d/0x71
  [<c0203f9f>] die+0x57/0x5f
  [<c02129a7>] do_page_fault+0x474/0x529
  [<c0212533>] ? do_page_fault+0x0/0x529
  [<c045eb3a>] error_code+0x72/0x78
  [<c024007b>] ? cgroup_get_sb+0x20/0x2b4
  [<c02f223c>] ? rb_erase+0x118/0x241
  [<c023177d>] __remove_hrtimer+0x5f/0x67
  [<c039b2ae>] ? qdisc_watchdog+0x0/0x1c
  [<c023199a>] run_hrtimer_pending+0x2c/0xb8
  [<c0231a3c>] run_hrtimer_softirq+0x16/0x18
  [<c0223e6d>] __do_softirq+0x64/0xcd
  [<c0223f0b>] do_softirq+0x35/0x3a
  [<c0224199>] irq_exit+0x38/0x6d
  [<c020eefb>] smp_apic_timer_interrupt+0x71/0x82
  [<c0203640>] apic_timer_interrupt+0x28/0x30
  [<c0207f9d>] ? default_idle+0x2d/0x42
  [<c0201946>] cpu_idle+0xca/0xea
  [<c045194e>] rest_init+0x4e/0x50
  =======================
 ---[ end trace 818de8d3237477a5 ]---
 Rebooting in 10 seconds..

With 2.6.27.10 plus what is being called patches #2 and #3 in this thread, 
the server ran for a day or so before hanging again:

 Pid: 0, comm: swapper Not tainted (2.6.27.10 #3)
 EIP: 0060:[<c023199f>] EFLAGS: 00000206 CPU: 0
 EIP is at run_hrtimer_pending+0x31/0xb8
 EAX: f73f8470 EBX: c039b312 ECX: 00000002 EDX: 00000001
 ESI: f73f8470 EDI: c1807e20 EBP: c0589f20 ESP: c0589f10
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 CR0: 8005003b CR2: 08ca3358 CR3: 005ca000 CR4: 000006d0
 DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
 DR6: ffff0ff0 DR7: 00000400
  [<c0231a3c>] run_hrtimer_softirq+0x16/0x18
  [<c0223e6d>] __do_softirq+0x64/0xcd
  [<c0223f0b>] do_softirq+0x35/0x3a
  [<c0224199>] irq_exit+0x38/0x6d
  [<c02052b3>] do_IRQ+0x5c/0x75
  [<c0203553>] common_interrupt+0x23/0x28
  [<c0207f9d>] ? default_idle+0x2d/0x42
  [<c0201946>] cpu_idle+0xca/0xea
  [<c045225e>] rest_init+0x4e/0x50

With 2.6.28 (without the patches from this thread) after about an hour the 
system hung again.  "Show Regs" indicated:

 Pid: 0, comm: swapper Not tainted (2.6.28 #1)
 EIP: 0060:[<c03977bd>] EFLAGS: 00000247 CPU: 0
 EIP is at __netif_schedule+0xc/0x39
 EAX: f6934600 EBX: 00000000 ECX: f6934600 EDX: f6864000
 ESI: f6864488 EDI: c1807480 EBP: c05c1f08 ESP: c05c1f04
  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 CR0: 8005003b CR2: 09968358 CR3: 365cd000 CR4: 000006d0
 DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
 DR6: ffff0ff0 DR7: 00000400
 Call Trace:
  [<c03a669d>] qdisc_watchdog+0x18/0x1c
  [<c02335c3>] run_hrtimer_pending+0x56/0xda
  [<c03a6685>] ? qdisc_watchdog+0x0/0x1c
  [<c023365d>] run_hrtimer_softirq+0x16/0x18
  [<c0225b1a>] __do_softirq+0x7a/0x11c
  [<c0225bf1>] do_softirq+0x35/0x3a
  [<c0225eb5>] irq_exit+0x38/0x6d
  [<c020f719>] smp_apic_timer_interrupt+0x71/0x7f
  [<c0203858>] apic_timer_interrupt+0x28/0x30
  [<c0208360>] ? default_idle+0x2d/0x42
  [<c0201938>] cpu_idle+0x6b/0x84
  [<c046b292>] rest_init+0x4e/0x50

Per Jarek's suggestion in bugzilla, I ran 2.6.28 plus Peter Zijlstra's 
"hrtimer: removing all ur callback modes" patches dated 2008-11-25, 
2008-12-04 and 2008-12-08.  Uptime was 2 days 22 hours before I hit what 
appears to be an unrelated bug related to the IPv6 FIB.  (Separately 
reported with subject 'panic with 2.6.28 while doing "ip -6 route"'.)

Chris
