From: Bruce Curtis <brutus@google.com>
Subject: Re: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback connections
Date: Thu, 18 Oct 2012 16:23:20 +0400
Message-ID: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
References: <507FD7A5.9080503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:51054 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710Ab2JRMXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 08:23:22 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so5298256vcb.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 05:23:21 -0700 (PDT)
In-Reply-To: <507FD7A5.9080503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Weiping,

Also wasn't able to repro on a real machine, will try a VM, but has to
do with the "making friends" code-paths which have been refactored
since last patch (due to Eric's comments above about an unreferenced
skb->friend sock pointer), I'll be sending out a new patch soon.

Thanks,
Bruce

On Thu, Oct 18, 2012 at 2:19 PM, Weiping Pan <panweiping3@gmail.com> wrote:
> Sorry, forget to cc the list.
>
>
> 2012/9/18 Bruce "Brutus" Curtis<brutus@google.com>:
>>
>>  From: "Bruce \"Brutus\" Curtis"<brutus@google.com>
>>
>>  TCP/IP loopback socket pair stack bypass, based on an idea by, and
>>  rough upstream patch from, David Miller<davem@davemloft.net>  called
>>  "friends", the data structure modifcations and connection scheme are
>>  reused with extensive data-path changes.
>
>
> Hi, Bruce,
>
> I found that there is a bug in the tcp friends patch,
> when I kill netperf randomly, panic occurs in tcp_close().
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000d
> IP: [<c0835a9b>] tcp_close+0x7b/0x3a0
> *pde = 00000000
> Oops: 0000 [#1] SMP
> Modules linked in: fuse 8021q garp stp llc ip6t_REJECT
> nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4
> ip6table_filter xt_state nf_conntrack ip6_tables ppdev parport_pc
> pcspkr i2c_piix4 i2c_core parport microcode e1000 uinput
> Pid: 16627, comm: netperf Not tainted 3.6.0+ #25 innotek GmbH VirtualBox
> EIP: 0060:[<c0835a9b>] EFLAGS: 00010202 CPU: 1
> EIP is at tcp_close+0x7b/0x3a0
> EAX: f6f41240 EBX: c2a46f40 ECX: 00000000 EDX: 00000001
> ESI: 00000000 EDI: c2a46f88 EBP: c2a1fd8c ESP: c2a1fd78
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> CR0: 8005003b CR2: 0000000d CR3: 00c07000 CR4: 000006d0
> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> DR6: ffff0ff0 DR7: 00000400
> Process netperf (pid: 16627, ti=c2a1e000 task=f44cd780 task.ti=c2a1e000)
> Stack:
>  c0b4d880 00000000 c2a46f40 ed821080 f4de7f00 c2a1fd9c c0857cff ed821080
>  00000000 c2a1fdb0 c07e3db0 00000000 f6f07540 00000008 c2a1fdbc c07e4127
>  f4de7f00 c2a1fdec c05378e8 00000001 00000000 00000000 f54bf010 ed82109c
> Call Trace:
>  [<c0857cff>] inet_release+0x5f/0x70
>  [<c07e3db0>] sock_release+0x20/0x80
>  [<c07e4127>] sock_close+0x17/0x30
>  [<c05378e8>] __fput+0x98/0x1f0
>  [<c0537a4d>] ____fput+0xd/0x10
>  [<c04580f1>] task_work_run+0x91/0xb0
>  [<c0441157>] do_exit+0x177/0x7f0
>  [<c0422c97>] ? smp_reschedule_interrupt+0x27/0x30
>  [<c0441a67>] do_group_exit+0x37/0xa0
>  [<c044e989>] get_signal_to_deliver+0x1c9/0x5b0
>  [<c0471393>] ? update_curr+0x213/0x380
>  [<c0402bca>] do_signal+0x2a/0x980
>  [<c04026c7>] ? __switch_to+0xc7/0x340
>  [<c08ea8c9>] ? __schedule+0x379/0x780
>  [<c08ec3f8>] ? apic_timer_interrupt+0x34/0x3c
>  [<c04ad0ae>] ? __audit_syscall_exit+0x36e/0x3a0
>  [<c04ad0ae>] ? __audit_syscall_exit+0x36e/0x3a0
>  [<c04036e5>] do_notify_resume+0x75/0xa0
>  [<c08ec1c1>] work_notifysig+0x30/0x37
> Code: 85 c0 74 3e 83 6b 50 01 8b 08 8b 50 04 c7 00 00 00 00 00 c7 40
> 04 00 00 00 00 89 51 04 89 0a 8b 88 9c 00 00 00 8b 50 34 2b 50 30<0f>
> b6 49 0d 83 e1 01 29 ca 01 d6 e8 c5 64 fb ff 8b 43 48 39 f8
> EIP: [<c0835a9b>] tcp_close+0x7b/0x3a0 SS:ESP 0068:c2a1fd78
> CR2: 000000000000000d
> ---[ end trace 9f6d5c8fc973265c ]---
>
>
> How to reproduce it ?
> 1 run netserver in a loop
> 2 run netperf with different modes in a loop
> 3 kill netperf randomly
>
> And I found it is easy to see the panic on VirtualBox, but I did not
> see it on the real machine.
>
> Any hints ?
>
> thanks
> Weiping Pan
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
