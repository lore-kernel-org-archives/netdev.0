From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Benchmark results: "Enhanced NUMA scheduling with adaptive affinity"
Date: Thu, 15 Nov 2012 08:29:12 -0800
Message-ID: <CA+55aFzo8iZQUdp3bYvb6M_qwLc-yyG0oRYHEGU-8hzbNsbEOQ@mail.gmail.com>
References: <20121112160451.189715188@chello.nl> <20121112184833.GA17503@gmail.com>
 <20121115100805.GS8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Mel Gorman <mgorman@suse.de>, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:33389 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768378Ab2KOQ3f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 11:29:35 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so1801022oag.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 08:29:34 -0800 (PST)
In-Reply-To: <20121115100805.GS8218@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Davem, Eric -

 this oops may be related to the numa patches, but quite frankly, I
don't see why/how it should be. And there's been some GRO work since
3.6, and we had an earlier oops case, so I thought I'd forward this.

The code decodes to

  14: 39 d0                 cmp    %edx,%eax
  16: 89 53 68             mov    %edx,0x68(%rbx)
  19: 0f 87 c7 04 00 00     ja     0x4e6
  1f: 4c 01 ab e0 00 00 00 add    %r13,0xe0(%rbx)
  26: 49 8b 44 24 08       mov    0x8(%r12),%rax
  2b:* 48 89 18             mov    %rbx,(%rax)     <-- trapping instruction
  2e: 49 89 5c 24 08       mov    %rbx,0x8(%r12)
  33: 0f b6 43 7c           movzbl 0x7c(%rbx),%eax
  37: a8 10                 test   $0x10,%al

and if I read the disassembly right (which is not guaranteed), it's the line

        p->prev->next = skb;

in the "merge:" case in skb_gro_receive() (just after the __skb_pull()
- the "ja" and "add" above the trapping instruction is the BUG_ON()
plus the "skb->data += len" part of the inlined __skb_pull()).

             Linus

On Thu, Nov 15, 2012 at 2:08 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> The machine was meant to test all this overnight but unfortunately when
> running a kernel build benchmark on the schednuma patches the machine
> hung while downloading the tarball with this
>
> [   73.863226] BUG: unable to handle kernel NULL pointer dereference at           (null)
> [   73.871062] IP: [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   73.876983] PGD 0
> [   73.878998] Oops: 0002 [#1] PREEMPT SMP
> [   73.882938] Modules linked in: af_packet mperf kvm_intel coretemp kvm crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd sr_mod lrw cdrom aes_x86_64 ses pcspkr xts i7core_edac ata_piix enclosure lpc_ich dcdbas sg gf128mul mfd_core bnx2 edac_core wmi acpi_power_meter button serio_raw joydev microcode autofs4 processor thermal_sys scsi_dh_rdac scsi_dh_hp_sw scsi_dh_alua scsi_dh_emc scsi_dh ata_generic megaraid_sas pata_atiixp [last unloaded: oprofile]
> [   73.924659] CPU 0
> [   73.926493] Pid: 0, comm: swapper/0 Not tainted 3.7.0-rc4-schednuma-v2r3 #1 Dell Inc. PowerEdge R810/0TT6JF
> [   73.936380] RIP: 0010:[<ffffffff8146feaa>]  [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   73.944714] RSP: 0018:ffff88047f803b50  EFLAGS: 00010282
> [   73.950004] RAX: 0000000000000000 RBX: ffff88046c2bdbc0 RCX: 0000000000000900
> [   73.957113] RDX: 00000000000005a8 RSI: ffff88046c2bdbc0 RDI: ffff88046eadb800
> [   73.964221] RBP: ffff88047f803bb0 R08: 00000000000005dc R09: ffff88046ddeccc0
> [   73.971328] R10: ffff88086d795d78 R11: 0000000000000001 R12: ffff880462b282c0
> [   73.978436] R13: 0000000000000034 R14: 00000000000005a8 R15: ffff88046eadbec0
> [   73.985543] FS:  0000000000000000(0000) GS:ffff88047f800000(0000) knlGS:0000000000000000
> [   73.993602] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   73.999326] CR2: 0000000000000000 CR3: 0000000001a0c000 CR4: 00000000000007f0
> [   74.006435] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   74.013543] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   74.020651] Process swapper/0 (pid: 0, threadinfo ffffffff81a00000, task ffffffff81a14420)
> [   74.028883] Stack:
> [   74.030885]  0000000000000060 ffff880462b282c0 ffff88086d795d78 ffffffff000005dc
> [   74.038300]  ffff88046e5f46c0 000000606a275ec0 0000000000000000 ffff88046c2bdbc0
> [   74.045715]  00000000000005a8 ffff88086d795d78 00000000000005a8 000000006c001080
> [   74.053131] Call Trace:
> [   74.055567]  <IRQ>
> [   74.057486]  [<ffffffff814b9573>] tcp_gro_receive+0x213/0x2b0
> [   74.063419]  [<ffffffff814cff49>] tcp4_gro_receive+0x99/0x110
> [   74.069150]  [<ffffffff814e096d>] inet_gro_receive+0x1cd/0x200
> [   74.074965]  [<ffffffff8147b30a>] dev_gro_receive+0x1ba/0x2b0
> [   74.080691]  [<ffffffff8147b6e3>] napi_gro_receive+0xe3/0x130
> [   74.086426]  [<ffffffffa009fda8>] bnx2_rx_int+0x3e8/0xf10 [bnx2]
> [   74.092416]  [<ffffffffa00a0cbd>] bnx2_poll_work+0x3ed/0x450 [bnx2]
> [   74.098666]  [<ffffffffa00a0d5e>] bnx2_poll_msix+0x3e/0xc0 [bnx2]
> [   74.104739]  [<ffffffff8147b969>] net_rx_action+0x159/0x290
> [   74.110298]  [<ffffffff8104d148>] __do_softirq+0xc8/0x250
> [   74.115682]  [<ffffffff8107bf9e>] ? sched_clock_idle_wakeup_event+0x1e/0x20
> [   74.122625]  [<ffffffff81577c9c>] call_softirq+0x1c/0x30
> [   74.127922]  [<ffffffff8100470d>] do_softirq+0x6d/0xa0
> [   74.133041]  [<ffffffff8104d44d>] irq_exit+0xad/0xc0
> [   74.137996]  [<ffffffff8107779d>] scheduler_ipi+0x5d/0x110
> [   74.143469]  [<ffffffff8102b7a4>] ? native_apic_msr_eoi_write+0x14/0x20
> [   74.150060]  [<ffffffff810257d5>] smp_reschedule_interrupt+0x25/0x30
> [   74.156394]  [<ffffffff8157785d>] reschedule_interrupt+0x6d/0x80
> [   74.162376]  <EOI>
> [   74.164295]  [<ffffffff81316798>] ? intel_idle+0xe8/0x150
> [   74.169875]  [<ffffffff81316779>] ? intel_idle+0xc9/0x150
> [   74.175259]  [<ffffffff8143de99>] cpuidle_enter+0x19/0x20
> [   74.180642]  [<ffffffff8143e522>] cpuidle_idle_call+0xa2/0x340
> [   74.186458]  [<ffffffff8100baca>] cpu_idle+0x7a/0xf0
> [   74.191410]  [<ffffffff8154b44b>] rest_init+0x7b/0x80
> [   74.196447]  [<ffffffff81ac3be2>] start_kernel+0x38f/0x39c
> [   74.201913]  [<ffffffff81ac3652>] ? repair_env_string+0x5e/0x5e
> [   74.207815]  [<ffffffff81ac3335>] x86_64_start_reservations+0x131/0x135
> [   74.214407]  [<ffffffff81ac3439>] x86_64_start_kernel+0x100/0x10f
> [   74.220475] Code: 8b e8 00 00 00 0f 87 86 00 00 00 8b 53 68 8b 43 6c 44 29 ea 39 d0 89 53 68 0f 87 c7 04 00 00 4c 01 ab e0 00 00 00 49 8b 44 24 08 <48> 89 18 49 89 5c 24 08 0f b6 43 7c a8 10 0f 85 ac 04 00 00 83
> [   74.240051] RIP  [<ffffffff8146feaa>] skb_gro_receive+0xaa/0x590
> [   74.246046]  RSP <ffff88047f803b50>
> [   74.249518] CR2: 0000000000000000
> [   74.252821] ---[ end trace 97cb529523f52c9b ]---
> [   74.258895] Kernel panic - not syncing: Fatal exception in interrupt
> -- 0:console -- time-stamp -- Nov/15/12  3:09:06 --
>
> I've no idea if it is directly related to your patches and I didn't try
> to reproduce it yet.
