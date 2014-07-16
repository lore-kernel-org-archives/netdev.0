From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 16 Jul 2014 14:03:40 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407161400290.7329@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>     <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>     <alpine.DEB.2.02.1406101726390.11647@dtop>     <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>    <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.02.1406281724370.18954@dtop>   <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>  
 <alpine.DEB.2.02.1406300112340.31629@dtop>  <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1407071834230.586@dtop> <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from li263-96.members.linode.com ([173.255.253.96]:49579 "EHLO
	mail.rydia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbaGPVDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 17:03:44 -0400
In-Reply-To: <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jul 2014, Eric Dumazet wrote:

> On Mon, 2014-07-07 at 18:41 -0700, dormando wrote:
>
> > Mostly there, but I think we hit what might be a new bug.. The machines
> > which crashed every few days previously have been stable for weeks.
> >
> > however I had one machine running the new kernel in a larger cluster
> > elsewhere; we had a network event and the one machine on the new kernel
> > panic'ed in ipv4_dst_destroy, but what looks like a new path. Sadly I've
> > had to halt the rollout :( All of the older unfixed kernels survived this
> > particular network event.
> >
> > Unfortunately this is still on 3.10, due to a bad softirq regression in
> > 3.14 I've not had time to track down. I applied all of your patches for
> > what wasn't already in 3.10. The only other change I made was to un-revert
> > 62713c4b6bc10c2d082ee1540e11b01a2b2162ab - which I'd been keeping reverted
> > as it was making crashes much more frequent.
>
> Hmm, always give patch title or a valid sha1 commit, this one is not in
> David trees, so its hard to tell.
>

Happened again, about two minutes after causing a large route churn.
Doing the same action again after it's been rebooted isn't causing it to
crash... it last went down a week ago. Either we're still not reproducing
it correctly, or it requires some amount of uptime inbetween crashes.

Trace is slightly different this time, but same function.

Any thoughts on how to instrument? :( kernels without your latest patches
aren't crashing during these changes. We've fixed the UDP issue but traded
it for something else.

<4>[774493.032809] general protection fault: 0000 [#1] SMP
<4>[774493.032830] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler isci igb libsas i2c_algo_bit ixgbe ptp pps_core mdio
<4>[774493.032948] CPU: 10 PID: 49 Comm: ksoftirqd/10 Tainted: G        W    3.10.45 #1
<4>[774493.032964] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[774493.032983] task: ffff88be6f3e0000 ti: ffff88be6f3de000 task.ti: ffff88be6f3de000
<4>[774493.032997] RIP: 0010:[<ffffffff815fa8ef>]  [<ffffffff815fa8ef>] ipv4_dst_destroy+0x4f/0x80
<4>[774493.033022] RSP: 0018:ffff88be6f3dfd18  EFLAGS: 00010296
<4>[774493.033033] RAX: dead000000200200 RBX: ffff88b94f5d1380 RCX: 0000000000000040
<4>[774493.033046] RDX: dead000000100100 RSI: dead000000100100 RDI: dead000000200200
<4>[774493.033060] RBP: ffff88be6f3dfd28 R08: ffffffff81cb0b00 R09: ffffea02f9458400
<4>[774493.033090] R10: ffffffff815b98f5 R11: 0000000000000031 R12: 0000000000000000
<4>[774493.033133] R13: ffffffff81c8c300 R14: ffff88c07fc4d748 R15: ffff88be6f3e0000
<4>[774493.033177] FS:  0000000000000000(0000) GS:ffff88c07fc40000(0000) knlGS:0000000000000000
<4>[774493.033221] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[774493.033248] CR2: 00007f805c06f000 CR3: 0000005769ed2000 CR4: 00000000000407e0
<4>[774493.033291] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
<4>[774493.033334] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
<4>[774493.033377] Stack:
<4>[774493.033397]  ffff88b94f5d1380 ffff88b94f5d1380 ffff88be6f3dfd58 ffffffff815b98d2
<4>[774493.033448]  ffff88be6f3dfd58 ffff88c07fc4d720 ffffffff81c39d80 ffff88be6f3dffd8
<4>[774493.033499]  ffff88be6f3dfd68 ffffffff815b9c6e ffff88be6f3dfdd8 ffffffff810c91e2
<4>[774493.033551] Call Trace:
<4>[774493.033579]  [<ffffffff815b98d2>] dst_destroy+0x32/0xe0
<4>[774493.033607]  [<ffffffff815b9c6e>] dst_destroy_rcu+0xe/0x20
<4>[774493.033638]  [<ffffffff810c91e2>] rcu_process_callbacks+0x202/0x560
<4>[774493.033671]  [<ffffffff81051a00>] __do_softirq+0xd0/0x270
<4>[774493.033699]  [<ffffffff81051bc8>] run_ksoftirqd+0x28/0x40
<4>[774493.033730]  [<ffffffff8107576d>] smpboot_thread_fn+0xfd/0x180
<4>[774493.033758]  [<ffffffff81075670>] ? lg_global_lock+0x80/0x80
<4>[774493.033788]  [<ffffffff8106e040>] kthread+0xc0/0xd0
<4>[774493.033814]  [<ffffffff8106df80>] ? flush_kthread_worker+0xb0/0xb0
<4>[774493.033845]  [<ffffffff816d001c>] ret_from_fork+0x7c/0xb0
<4>[774493.033872]  [<ffffffff8106df80>] ? flush_kthread_worker+0xb0/0xb0
<4>[774493.033900] Code: 4a 8f e9 81 e8 33 d2 0c 00 48 8b 93 b0 00 00 00 48 bf 00 02 20 00 00 00 ad de 48 8b 83 b8 00 00 00 48 be 00 01 10 00 00 00 ad de <48> 89 42 08 48 89 10 48 89 bb b8 00 00 00 48 c7 c7 4a 8f e9 81
<1>[774493.034115] RIP  [<ffffffff815fa8ef>] ipv4_dst_destroy+0x4f/0x80
<4>[774493.034145]  RSP <ffff88be6f3dfd18>
<4>[774493.034439] ---[ end trace 10b9e107c9a58917 ]---
<0>[774493.096332] Kernel panic - not syncing: Fatal exception in interrupt
