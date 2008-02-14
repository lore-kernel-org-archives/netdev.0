From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [PATCH][RFC] race in generic address resolution
Date: Thu, 14 Feb 2008 17:56:53 +0100
Message-ID: <939d53060802140856v5168a4a2md8c8ed3fad6798e4@mail.gmail.com>
References: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com>
	 <20080205.205154.153345843.davem@davemloft.net>
	 <47B00EE0.4040109@linux.vnet.ibm.com>
	 <20080211.214711.134366517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.185]:43873 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105AbYBNQ4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 11:56:54 -0500
Received: by rv-out-0910.google.com with SMTP id k20so266879rvb.1
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2008 08:56:53 -0800 (PST)
In-Reply-To: <20080211.214711.134366517.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It seems this patch hangs my  machine very quickly when there are some
ICMPv6 traffic.

I'm using net-2.6, pulled today (14th Feb).

I had some unexpected hangs on my SMP test machines and I bisected the
problem to  69cc64d8d92bf852f933e90c888dfff083bd4fc9
"[NDISC]: Fix race in generic address resolution".

Looks like a deadlock:
"BUG: soft lockup - CPU#1 stuck for 61s! [swapper:0]"

Here are some traces printed on the console:

Pid: 0, comm: swapper Not tainted (2.6.25-rc1-netns-00113-g69cc64d-dirty #34)
EIP: 0060:[<c02eb5f6>] EFLAGS: 00000287 CPU: 0
EIP is at __write_lock_failed+0xa/0x20
EAX: c7b3fab4 EBX: c7b3fab4 ECX: 00000000 EDX: c0377986
ESI: c7b3fa90 EDI: c7b6f290 EBP: c03cbd24 ESP: c03cbd24
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7f9b404 CR3: 07ac8000 CR4: 00000690
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: 00000000 DR7: 00000000
 [<c020e43f>] _raw_write_lock+0x57/0x6c
 [<c02eba95>] _write_lock_bh+0x25/0x2d
 [<c026b107>] ? neigh_resolve_output+0x93/0x238
 [<c026b107>] neigh_resolve_output+0x93/0x238
 [<c02a5635>] ip6_output2+0x241/0x289
 [<c02a61cd>] ip6_output+0xa92/0xaad
 [<c025ff11>] ? __alloc_skb+0x4f/0xfb
 [<c02b2596>] ? __ndisc_send+0x1fb/0x3f5
 [<c02b26a0>] __ndisc_send+0x305/0x3f5
 [<c02b2fb5>] ndisc_send_ns+0x63/0x6e
 [<c02b3f3e>] ndisc_solicit+0x183/0x18d
 [<c0121071>] ? __mod_timer+0x96/0xa1
 [<c026b81e>] neigh_timer_handler+0x214/0x252
 [<c0120c90>] run_timer_softirq+0xfe/0x159
 [<c026b60a>] ? neigh_timer_handler+0x0/0x252
 [<c011dbfa>] __do_softirq+0x6f/0xe9
 [<c011dcae>] do_softirq+0x3a/0x52
 [<c011dfc3>] irq_exit+0x44/0x46
 [<c0105273>] do_IRQ+0x5a/0x73
 [<c0103666>] common_interrupt+0x2e/0x34
 [<c0101954>] ? default_idle+0x4a/0x77
 [<c010190a>] ? default_idle+0x0/0x77
 [<c0101855>] cpu_idle+0x89/0x9d
 [<c02e6135>] rest_init+0x49/0x4b
 =======================
BUG: soft lockup - CPU#1 stuck for 61s! [swapper:0]

Pid: 0, comm: swapper Not tainted (2.6.25-rc1-netns-00113-g69cc64d-dirty #34)
EIP: 0060:[<c02eb5f6>] EFLAGS: 00000287 CPU: 1
EIP is at __write_lock_failed+0xa/0x20
EAX: c7b3fab4 EBX: c7b3fab4 ECX: 00000000 EDX: 00000000
ESI: c03bb9c0 EDI: c7b3fab4 EBP: c7841eb0 ESP: c7841eb0
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: 08560008 CR3: 07b04000 CR4: 00000690
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: 00000000 DR7: 00000000
 [<c020e43f>] _raw_write_lock+0x57/0x6c
 [<c02eba68>] _write_lock+0x20/0x28
 [<c026982c>] ? neigh_periodic_timer+0x99/0x142
 [<c026982c>] neigh_periodic_timer+0x99/0x142
 [<c0120c90>] run_timer_softirq+0xfe/0x159
 [<c0269793>] ? neigh_periodic_timer+0x0/0x142
 [<c011dbfa>] __do_softirq+0x6f/0xe9
 [<c011dcae>] do_softirq+0x3a/0x52
 [<c011dfc3>] irq_exit+0x44/0x46
 [<c010d680>] smp_apic_timer_interrupt+0x71/0x81
 [<c0103747>] apic_timer_interrupt+0x33/0x38
 [<c0101954>] ? default_idle+0x4a/0x77
 [<c010190a>] ? default_idle+0x0/0x77
 [<c0101855>] cpu_idle+0x89/0x9d
 =======================
BUG: soft lockup - CPU#0 stuck for 61s! [swapper:0]

Pid: 0, comm: swapper Not tainted (2.6.25-rc1-netns-00113-g69cc64d-dirty #34)
EIP: 0060:[<c02eb5f6>] EFLAGS: 00000287 CPU: 0
EIP is at __write_lock_failed+0xa/0x20
EAX: c7b3fab4 EBX: c7b3fab4 ECX: 00000000 EDX: c0377986
ESI: c7b3fa90 EDI: c7b6f290 EBP: c03cbd24 ESP: c03cbd24
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: b7f9b404 CR3: 07ac8000 CR4: 00000690
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: 00000000 DR7: 00000000
 [<c020e43f>] _raw_write_lock+0x57/0x6c
 [<c02eba95>] _write_lock_bh+0x25/0x2d
 [<c026b107>] ? neigh_resolve_output+0x93/0x238
 [<c026b107>] neigh_resolve_output+0x93/0x238
 [<c02a5635>] ip6_output2+0x241/0x289
 [<c02a61cd>] ip6_output+0xa92/0xaad
 [<c025ff11>] ? __alloc_skb+0x4f/0xfb
 [<c02b2596>] ? __ndisc_send+0x1fb/0x3f5
 [<c02b26a0>] __ndisc_send+0x305/0x3f5
 [<c02b2fb5>] ndisc_send_ns+0x63/0x6e
 [<c02b3f3e>] ndisc_solicit+0x183/0x18d
 [<c0121071>] ? __mod_timer+0x96/0xa1
 [<c026b81e>] neigh_timer_handler+0x214/0x252
 [<c0120c90>] run_timer_softirq+0xfe/0x159
 [<c026b60a>] ? neigh_timer_handler+0x0/0x252
 [<c011dbfa>] __do_softirq+0x6f/0xe9
 [<c011dcae>] do_softirq+0x3a/0x52
 [<c011dfc3>] irq_exit+0x44/0x46
 [<c0105273>] do_IRQ+0x5a/0x73
 [<c0103666>] common_interrupt+0x2e/0x34
 [<c0101954>] ? default_idle+0x4a/0x77
 [<c010190a>] ? default_idle+0x0/0x77
 [<c0101855>] cpu_idle+0x89/0x9d
 [<c02e6135>] rest_init+0x49/0x4b
 =======================
BUG: soft lockup - CPU#1 stuck for 61s! [swapper:0]
 ...


Benjamin

On Tue, Feb 12, 2008 at 6:47 AM, David Miller <davem@davemloft.net> wrote:
> From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
>  Date: Mon, 11 Feb 2008 10:01:20 +0100
>
>
>  > we run your patch during the weekend on single CPU and SMP
>  > machines. We do not see any problems. Thanks for providing the fix.
>
>  Thanks for testing Frank, I can now push this fix upstream.
>
>
> --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
