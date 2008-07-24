From: Dieter Ries <clip2@gmx.de>
Subject: Re: Current Git: BUG: unable to handle kernel paging
	request at 0000000001a40ca0
Date: Thu, 24 Jul 2008 08:51:51 +0200
Message-ID: <48882687.7020508@gmx.de>
References: <488750AA.20707@gmx.de>	
	<19f34abd0807231046o4b194409w7d0e28a7cd745afa@mail.gmail.com>	
	<48877200.9040608@gmx.de> <4887A860.6070607@gmx.de>
	<19f34abd0807231500m3d780d90i39626023e0685369@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	jeffrey.t.kirsher@intel.com, jgarzik@pobox.com
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <19f34abd0807231500m3d780d90i39626023e0685369@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Vegard Nossum schrieb:
> On Wed, Jul 23, 2008 at 11:53 PM, Dieter Ries <clip3@gmx.de> wrote:
>>>> Dieter: If this is reproducible, it would probably help quite a bit to
>>>> configure the kernel with CONFIG_SLUB_DEBUG and boot with
>>>> slub_debug=FZPUT (unless you already have CONFIG_SLUB_DEBUG_ON set, in
>>>> which case you are already running with the SLUB debugging at boot).
>>>> It might catch the corruption before it becomes fatal, or give us some
>>>> more clues anyway.
>> I tried to bisect the bug, which failed because there were too many kernels
>> not booting with other problems, I guess bisecting just fails in the merge
>> window.
>>
>> With CONFIG_SLUB_DEBUG_ON the output looks different, unfortunately
>> netconsole stops before those are transmitted.

I think I managed to catch one of those:


general protection fault: 0000 [1] SMP
CPU 0
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.26-06373-gcaf076e #49
RIP: 0010:[<ffffffff805e08f9>]  [<ffffffff805e08f9>] 
nf_nat_move_storage+0x21/0x7a
RSP: 0018:ffffffff8091ab80  EFLAGS: 00010206
RAX: ffffffff805e08d8 RBX: ffff88007d1fb948 RCX: 000000000000006b
RDX: ffff88007d175e10 RSI: ffff88007d175e7b RDI: ffff88007d1fb948
RBP: ffffffff8091aba0 R08: 0000000000000000 R09: ffff88007d175e90
R10: ffffe20000000008 R11: ffff88007d175e10 R12: 59d2c3ffff88007d
R13: ffff88007d175e7b R14: 00000000000000a0 R15: 0000000000000001
FS:  0000000000000000(0000) GS:ffffffff8089ee80(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff808b0000, task ffffffff80842340)
Stack:  0000000000000002 ffff88007d3d2000 ffff88007d1fb948 0000000000000070
  ffffffff8091abf0 ffffffff8059d3c4 ffffffff8091ac40 0000000100000001
  ffffffff809e3658 ffff88007d3d2000 0000000000000002 ffff88007f9f6500
Call Trace:
  <IRQ>  [<ffffffff8059d3c4>] __nf_ct_ext_add+0x15f/0x1f7
  [<ffffffff805e762c>] nf_nat_fn+0x84/0x152
  [<ffffffff805e77d8>] nf_nat_in+0x2f/0x71
  [<ffffffff805953d8>] nf_iterate+0x48/0x85
  [<ffffffff805b19c0>] ? ip_rcv_finish+0x0/0x35d
  [<ffffffff80595478>] nf_hook_slow+0x63/0xcb
  [<ffffffff805b19c0>] ? ip_rcv_finish+0x0/0x35d
  [<ffffffff8028fe7c>] ? __slab_alloc+0x413/0x4bd
  [<ffffffff805b21b8>] ip_rcv+0x257/0x297
  [<ffffffff80581461>] netif_receive_skb+0x1f1/0x263
  [<ffffffff80495b34>] e1000_receive_skb+0x46/0x5d
  [<ffffffff8049830b>] e1000_clean_rx_irq+0x20e/0x2a6
  [<ffffffff8024cce8>] ? getnstimeofday+0x3f/0xa0
  [<ffffffff804952ce>] e1000_clean+0x6d/0x218
  [<ffffffff8024ad39>] ? hrtimer_get_next_event+0xa8/0xb8
  [<ffffffff80583569>] net_rx_action+0xa9/0x17c
  [<ffffffff80239b51>] __do_softirq+0x65/0xd5
  [<ffffffff8020c5dc>] call_softirq+0x1c/0x28
  [<ffffffff8020dd0a>] do_softirq+0x39/0x77
  [<ffffffff80239aab>] irq_exit+0x44/0x85
  [<ffffffff8020dff5>] do_IRQ+0x147/0x16a
  [<ffffffff8020b8a1>] ret_from_intr+0x0/0xa
  <EOI>  [<ffffffff80446d94>] ? acpi_idle_enter_bm+0x2a7/0x317
  [<ffffffff80446d8a>] ? acpi_idle_enter_bm+0x29d/0x317
  [<ffffffff805672cd>] ? menu_select+0x75/0x9e
  [<ffffffff8056660e>] ? cpuidle_idle_call+0x75/0xa7
  [<ffffffff80209fd6>] ? cpu_idle+0x69/0x8c
  [<ffffffff8064d9ed>] ? rest_init+0x61/0x63
  [<ffffffff808bcd9c>] ? start_kernel+0x2ad/0x2b9
  [<ffffffff808bc275>] ? x86_64_start_reservations+0x84/0x88
  [<ffffffff808bc385>] ? x86_64_start_kernel+0xe4/0xeb


Code: ff 5b 41 5c 41 5d 41 5e c9 c3 55 48 89 e5 41 55 41 54 53 48 83 ec 
08 e8 c6 a8 c2 ff 4c 8b 66 20 48 89 fb 49 89 f5 4d 85 e4 74 51 <49> f7 
44 24 78 80 01 00 00 74 46 48 c7 c7 78 6a 9e 80 e8 8f 2e
RIP  [<ffffffff805e08f9>] nf_nat_move_storage+0x21/0x7a
  RSP <ffffffff8091ab80>
---[ end trace 6f6148e13aab302e ]---
Kernel panic - not syncing: Aiee, killing interrupt handler!

>>
>> As there are always some lines about e1000 in the backtraces, I tried to
>> boot without LAN cable connected, and it worked, and crashed afterwards when
>> I plugged the cable in, with a bug in net/core/dev.c.
>>
>> Should I copy the messages with CONFIG_SLUB_DEBUG_ON by hand, or are just
>> some parts important?
> 
> There were some e1000 patches in flight on LKML recently; you might be
> able to find them and see if it helps you. It also seems that some
> changes were just committed to -git, so I guess you should try the
> very latest from there.

I reverted some of the last patches concerning e1000 one by one, but the 
last ~12 which I did revert yet didnt solve the problem.

> 
> You also Cced netdev from the start, so somebody from there should be
> able to help you more from here than I. :-)
> 
> 
> Vegard
> 
cu
Dieter

-- 
3rd Law of Computing:
         Anything that can go wr
fortune: Segmentation violation -- Core dumped

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
