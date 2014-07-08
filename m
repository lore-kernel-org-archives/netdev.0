From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Mon, 7 Jul 2014 18:41:27 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407071834230.586@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>    <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.02.1406101726390.11647@dtop>    <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>   <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.02.1406281724370.18954@dtop>  <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1406300112340.31629@dtop> <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li263-96.members.linode.com ([173.255.253.96]:46763 "EHLO
	mail.rydia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbaGHBla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2014 21:41:30 -0400
In-Reply-To: <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jun 2014, Eric Dumazet wrote:

> On Mon, 2014-06-30 at 01:15 -0700, dormando wrote:
>
> > Heh. You folks have quite insane amounts of output.
> >
> > I'm now testing a kernel which has the one upstreamed patch + the two not
> > yet in -stable, under 3.10.45. A kernel with ~60% of those patches has
> > been running for 17.5 days so far. Much longer than it normally runs.
> >
> > So, looking pretty decent, still. Thanks for your patience for all of my
> > dumb questions. I'll probably only pipe up again on this issue if I see
> > another crash.
>
> Thanks _you_ for your patience, reports, and tests !
>

Mostly there, but I think we hit what might be a new bug.. The machines
which crashed every few days previously have been stable for weeks.

however I had one machine running the new kernel in a larger cluster
elsewhere; we had a network event and the one machine on the new kernel
panic'ed in ipv4_dst_destroy, but what looks like a new path. Sadly I've
had to halt the rollout :( All of the older unfixed kernels survived this
particular network event.

Unfortunately this is still on 3.10, due to a bad softirq regression in
3.14 I've not had time to track down. I applied all of your patches for
what wasn't already in 3.10. The only other change I made was to un-revert
62713c4b6bc10c2d082ee1540e11b01a2b2162ab - which I'd been keeping reverted
as it was making crashes much more frequent.

We tried for hours to get it to crash again and could not: full prod
traffic, udpkill running across four interfaces, and flapping the BGP
sessions around causing mass route flushing. No crash. There was something
specific about the upstream network event but we have not figured out what
yet. There were some InHdrErrors recorded and maybe some small amount of
forwarded traffic (we have some forwarding rules that are only used during
traffic bleeds). Nothing else stood out.

<4>[410769.205739] general protection fault: 0000 [#1] SMP
<4>[410769.205758] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel igb i2c_algo_bit gpio_ich isci ipmi_watchdog ixgbe ipmi_devintf microcode sb_edac libsas edac_core lpc_ich ptp mfd_core pps_core tpm_tis mdio tpm tpm_bios ipmi_si ipmi_msghandler
<4>[410769.205860] CPU: 2 PID: 251071 Comm: cache-main Tainted: G        W    3.10.45 #1
<4>[410769.205874] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[410769.205892] task: ffff88b882bddc00 ti: ffff88be06058000 task.ti: ffff88be06058000
<4>[410769.205906] RIP: 0010:[<ffffffff815fa8ef>]  [<ffffffff815fa8ef>] ipv4_dst_destroy+0x4f/0x80
<4>[410769.205926] RSP: 0000:ffff885effc43e00  EFLAGS: 00010286
<4>[410769.205936] RAX: dead000000200200 RBX: ffff88be3a5a1380 RCX: 0000000000000040
<4>[410769.205950] RDX: dead000000100100 RSI: dead000000100100 RDI: dead000000200200
<4>[410769.205964] RBP: ffff885effc43e10 R08: ffffffff81cb0b00 R09: ffffea01791b9480
<4>[410769.205978] R10: ffffffff815b98f5 R11: 000000000003d4bf R12: 0000000000000000
<4>[410769.206009] R13: ffffffff81c8c300 R14: ffff885effc4d748 R15: ffff88b882bddc00
<4>[410769.206052] FS:  00007faa7b33c880(0000) GS:ffff885effc40000(0000) knlGS:0000000000000000
<4>[410769.206096] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[410769.206123] CR2: 00007f09c903c420 CR3: 000000bb6d074000 CR4: 00000000000407e0
<4>[410769.206166] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[410769.206208] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[410769.206251] Stack:
<4>[410769.206271]  ffff88be3a5a1380 ffff88be3a5a1380 ffff885effc43e40 ffffffff815b98d2
<4>[410769.206321]  ffff885effc43e40 ffff885effc4d720 ffffffff81c39d80 ffff88be06059fd8
<4>[410769.206370]  ffff885effc43e50 ffffffff815b9c6e ffff885effc43ec0 ffffffff810c91e2
<4>[410769.206420] Call Trace:
<4>[410769.206440]  <IRQ>
<4>[410769.206445]  [<ffffffff815b98d2>] dst_destroy+0x32/0xe0
<4>[410769.206491]  [<ffffffff815b9c6e>] dst_destroy_rcu+0xe/0x20
<4>[410769.206520]  [<ffffffff810c91e2>] rcu_process_callbacks+0x202/0x560
<4>[410769.206550]  [<ffffffff8108e9f4>] ? ktime_get+0x54/0xe0
<4>[410769.206578]  [<ffffffff81051a00>] __do_softirq+0xd0/0x270
<4>[410769.206607]  [<ffffffff810969b4>] ? tick_program_event+0x24/0x30
<4>[410769.206637]  [<ffffffff81071bb0>] ? hrtimer_interrupt+0x140/0x240
<4>[410769.206667]  [<ffffffff816d12fc>] call_softirq+0x1c/0x30
<4>[410769.206696]  [<ffffffff81004215>] do_softirq+0x55/0x90
<4>[410769.206722]  [<ffffffff81051cb5>] irq_exit+0x55/0x60
<4>[410769.206748]  [<ffffffff816d1a6e>] smp_apic_timer_interrupt+0x6e/0x99
<4>[410769.206776]  [<ffffffff816d0c8a>] apic_timer_interrupt+0x6a/0x70
<4>[410769.206803]  <EOI>
<4>[410769.206807]  [<ffffffff816d00c2>] ? system_call_fastpath+0x16/0x1b
<4>[410769.206854] Code: 4a 8f e9 81 e8 33 d2 0c 00 48 8b 93 b0 00 00 00 48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00 ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 8f e9 81
<1>[410769.207051] RIP  [<ffffffff815fa8ef>] ipv4_dst_destroy+0x4f/0x80
<4>[410769.207080]  RSP <ffff885effc43e00>
<4>[410769.207358] ---[ end trace 81d52c76acd843b0 ]---
<0>[410769.276065] Kernel panic - not syncing: Fatal exception in interrupt

Thanks,
-Dormando
