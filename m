From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: probably serious conntrack/netfilter panic, 4.8.14, timers and
 intel turbo
Date: Wed, 11 Jan 2017 18:22:43 +0100
Message-ID: <20170111172243.5yqliuverfhchlju@alphalink.fr>
References: <9be92e4dc7d83096cbcdaae1a3f77bd3@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9be92e4dc7d83096cbcdaae1a3f77bd3@nuclearcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: netfilter-devel@vger.kernel.org, I'm afraid I'll need some help
for this case.

On Sat, Dec 17, 2016 at 09:48:13PM +0200, Denys Fedoryshchenko wrote:
> Hi,
> 
> I posted recently several netfilter related crashes, didn't got any answers,
> one of them started to happen quite often on loaded NAT (17Gbps),
> so after trying endless ways to make it stable, i found out that in
> backtrace i can often see timers, and this bug probably appearing on older
> releases,
> i've seen such backtrace with timer fired for conntrack on them.
> I disabled Intel turbo for cpus on this loaded NAT, and voila, panic
> disappeared for 2nd day!
> * by wrmsr -a 0x1a0 0x4000850089
> I am not sure timers is the reason, but probably turbo creating some
> condition for bug.
> 

Re-formatting the stack-trace for easier reference:

[28904.162607] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[28904.163210] IP: [<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.163745] PGD 0
[28904.164058] Oops: 0002 [#1] SMP
[28904.164323] Modules linked in: nf_nat_pptp nf_nat_proto_gre xt_TCPMSS xt_connmark ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_nat xt_rateest xt_RATEEST nf_conntrack_pptp nf_conntrack_proto_gre xt_CT xt_set xt_hl xt_tcpudp ip_set_hash_net ip_set nfnetlink iptable_raw iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables netconsole configfs 8021q garp mrp stp llc bonding ixgbe dca
[28904.168132] CPU: 27 PID: 0 Comm: swapper/27 Not tainted 4.8.14-build-0124 #2
[28904.168398] Hardware name: Intel Corporation S2600WTT/S2600WTT, BIOS SE5C610.86B.01.01.1008.031920151331 03/19/2015
[28904.168853] task: ffff885fa42e8c40 task.stack: ffff885fa42f0000
[28904.169114] RIP: 0010:[<ffffffffa00ab07d>] [<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.169643] RSP: 0018:ffff885fbccc3dd8 EFLAGS: 00010246
[28904.169901] RAX: 0000000000000000 RBX: ffff885fbccc0000 RCX: ffff885fbccc0010
[28904.170169] RDX: ffff885f87a1c150 RSI: 0000000000000142 RDI: ffff885fbccc0000
[28904.170437] RBP: ffff885fbccc3de8 R08: 00000000cbdee177 R09: 0000000000000100
[28904.170704] R10: ffff885fbccc3dd0 R11: ffffffff820050c0 R12: ffff885f87a1c140
[28904.170971] R13: 000000000005d948 R14: 00000000000ea942 R15: ffff885f87a1c160
[28904.171237] FS: 0000000000000000(0000) GS:ffff885fbccc0000(0000) knlGS:0000000000000000
[28904.171688] CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[28904.171964] CR2: 0000000000000008 CR3: 000000607f006000 CR4: 00000000001406e0
[28904.172231] Stack:
[28904.172482] ffff885f87a1c140 ffffffff820a1405 ffff885fbccc3e28 ffffffffa00abb30
[28904.173182] 00000002820a1405 ffff885f87a1c140 ffff885f99a28201 0000000000000000
[28904.173884] 0000000000000000 ffffffff820050c8 ffff885fbccc3e58 ffffffffa00abc62
[28904.174585] Call Trace:
[28904.174835] <IRQ>
[28904.174912] [<ffffffffa00abb30>] nf_ct_delete_from_lists+0xc9/0xf2 [nf_conntrack]
[28904.175613] [<ffffffffa00abc62>] nf_ct_delete+0x109/0x12c [nf_conntrack]
[28904.175894] [<ffffffffa00abc85>] ? nf_ct_delete+0x12c/0x12c [nf_conntrack]
[28904.176169] [<ffffffffa00abc92>] death_by_timeout+0xd/0xf [nf_conntrack]
[28904.176443] [<ffffffff81109922>] call_timer_fn.isra.5+0x17/0x6b
[28904.176714] [<ffffffff811099e5>] expire_timers+0x6f/0x7e
[28904.176975] [<ffffffff81109add>] run_timer_softirq+0x69/0x8b
[28904.177238] [<ffffffff811141bb>] ? clockevents_program_event+0xd0/0xe8
[28904.177504] [<ffffffff810d000c>] __do_softirq+0xbd/0x1aa
[28904.177765] [<ffffffff810d0240>] irq_exit+0x37/0x7c
[28904.178026] [<ffffffff8102c519>] smp_trace_apic_timer_interrupt+0x7b/0x88
[28904.178300] [<ffffffff8102c52f>] smp_apic_timer_interrupt+0x9/0xb
[28904.178565] [<ffffffff818f4f1c>] apic_timer_interrupt+0x7c/0x90
[28904.178835] <EOI>
[28904.178907] [<ffffffff8101b929>] ? mwait_idle+0x64/0x7a
[28904.179436] [<ffffffff810e3d8f>] ? atomic_notifier_call_chain+0x13/0x15
[28904.179712] [<ffffffff8101bd04>] arch_cpu_idle+0xa/0xc
[28904.179976] [<ffffffff810f7c3d>] default_idle_call+0x27/0x29
[28904.180244] [<ffffffff810f7d5c>] cpu_startup_entry+0x11d/0x1c7
[28904.180508] [<ffffffff8102af13>] start_secondary+0xe8/0xeb
[28904.180767] Code: 80 2f 0b 82 48 89 df e8 da 90 84 e1 48 8b 43 10 49 8d 54 24 10 48 8d 4b 10 49 89 4c 24 18 a8 01 49 89 44 24 10 48 89 53 10 75 04 <89> 50 08 c6 03 00 5b 41 5c 5d c3 48 8b 05 10 be 00 00 89 f6
[28904.185546] RIP [<ffffffffa00ab07d>] nf_ct_add_to_dying_list+0x55/0x61 [nf_conntrack]
[28904.186065] RSP <ffff885fbccc3dd8>
[28904.186319] CR2: 0000000000000008
[28904.186593] ---[ end trace 35cbc6c885a5c2d8 ]---
[28904.186860] Kernel panic - not syncing: Fatal exception in interrupt
[28904.187155] Kernel Offset: disabled
[28904.187419] Rebooting in 5 seconds..
[28909.193662] ACPI MEMORY or I/O RESET_REG.

And here's decodecode's output:

All code
========
   0:   80 2f 0b                subb   $0xb,(%rdi)
   3:   82                      (bad)
   4:   48 89 df                mov    %rbx,%rdi
   7:   e8 da 90 84 e1          callq  0xffffffffe18490e6
   c:   48 8b 43 10             mov    0x10(%rbx),%rax
  10:   49 8d 54 24 10          lea    0x10(%r12),%rdx
  15:   48 8d 4b 10             lea    0x10(%rbx),%rcx
  19:   49 89 4c 24 18          mov    %rcx,0x18(%r12)
  1e:   a8 01                   test   $0x1,%al
  20:   49 89 44 24 10          mov    %rax,0x10(%r12)
  25:   48 89 53 10             mov    %rdx,0x10(%rbx)
  29:   75 04                   jne    0x2f
  2b:*  89 50 08                mov    %edx,0x8(%rax)           <-- trapping instruction
  2e:   c6 03 00                movb   $0x0,(%rbx)
  31:   5b                      pop    %rbx
  32:   41 5c                   pop    %r12
  34:   5d                      pop    %rbp
  35:   c3                      retq
  36:   48 8b 05 10 be 00 00    mov    0xbe10(%rip),%rax        # 0xbe4d
  3d:   89 f6                   mov    %esi,%esi


Fortunately, nf_ct_add_to_dying_list() is small:

static void nf_ct_add_to_dying_list(struct nf_conn *ct)
{
	struct ct_pcpu *pcpu;

	/* add this conntrack to the (per cpu) dying list */
	ct->cpu = smp_processor_id();
	pcpu = per_cpu_ptr(nf_ct_net(ct)->ct.pcpu_lists, ct->cpu);

	spin_lock(&pcpu->lock);
	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
			     &pcpu->dying);
	spin_unlock(&pcpu->lock);
}


So "callq  0xffffffffe18490e6" probably refers to the
"spin_lock(&pcpu->lock)" call, which means RBX == pcpu.
Considering the offsets used, we certainly have R12 == ct.

>From there, we can interpret the assembly code as follow:
  Original register values:
    rbx:        pcpu
    0x10(%rbx): &pcpu->dying.first

    r12:        ct
    0x10(%r12): &ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
    0x18(%r12): &ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev

  Code:
    mov    %rbx,%rdi          ; RBX == pcpu
    callq  0xffffffffe18490e6 ; spin_lock(&pcpu->lock)

    mov    0x10(%rbx),%rax    ; rax = pcpu->dying.first
    lea    0x10(%r12),%rdx    ; rdx = &ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
    lea    0x10(%rbx),%rcx    ; rcx = &pcpu->dying.first

    mov    %rcx,0x18(%r12)    ; ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = &pcpu->dying.first

    test   $0x1,%al           ; test: is_a_nulls(pcpu->dying.first)

    mov    %rax,0x10(%r12)    ; &ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next = pcpu->dying.first
    mov    %rdx,0x10(%rbx)    ; pcpu->dying.first = &ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode

    jne    0x2f               ; jump if is_a_nulls(pcpu->dying.first)

    mov    %edx,0x8(%rax)     <-- trapping instruction, RAX == 0


So RAX, which has been set to pcpu->dying.first, is NULL. The
pcpu->dying list is thus corrupted.

I'm not familiar with nf_conntrack_core.c and I still can't figure out
how we could end up with pcpu->dying.first being a NULL pointer.

Probably there's a race somewhere and activating turbo mode makes it
more likely to happen. But still, I'd expect a locking or RCU issue to
give us garbage here, not a plain NULL pointer.

Does anyone have a clue?
