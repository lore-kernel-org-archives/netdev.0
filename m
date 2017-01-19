From: Dave Jones <davej@codemonkey.org.uk>
Subject: prb_retire_rx_blk_timer_expired use-after-free
Date: Wed, 18 Jan 2017 19:22:47 -0500
Message-ID: <20170119002247.ixkpbbm3gannw7qv@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:49192 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751585AbdASBBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 20:01:01 -0500
Received: from [2601:196:4600:77b0:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.84_2)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1cU0V5-00020P-V8
        for netdev@vger.kernel.org; Wed, 18 Jan 2017 19:22:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSI looks kinda like slab poison here, so re-using a free'd ptr ?

general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.10.0-rc4-think+ #2 
task: ffffffff81e16500 task.stack: ffffffff81e00000
RIP: 0010:prb_retire_rx_blk_timer_expired+0x42/0x130
RSP: 0018:ffff880507803e30 EFLAGS: 00010246
RAX: ffffffff81e16500 RBX: ffff8804bc751158 RCX: 0000000000000000
RDX: ffff8804fb6e8008 RSI: a56b6b6b6b6b6b6b RDI: 0000000000000001
RBP: ffff880507803e48 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000061f74469 R11: 0000000000000054 R12: ffff8804bc751338
R13: ffff8804bc7516d8 R14: ffffffff818ab6a0 R15: ffff8804bc751158
FS:  0000000000000000(0000) GS:ffff880507800000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00005578f64a0130 CR3: 0000000003e11000 CR4: 00000000001406f0
DR0: 00007f539ba38000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 <IRQ>
 call_timer_fn+0xd2/0x340
 ? call_timer_fn+0x5/0x340
 ? prb_retire_current_block+0x100/0x100
 run_timer_softirq+0x284/0x650
 ? 0xffffffffa035c077
 ? run_timer_softirq+0x5/0x650
 ? lapic_next_deadline+0x5/0x40
 __do_softirq+0x143/0x431
 irq_exit+0xa5/0xb0
 smp_apic_timer_interrupt+0x3d/0x50
 apic_timer_interrupt+0x8d/0xa0
RIP: 0010:cpuidle_enter_state+0x129/0x360
RSP: 0018:ffffffff81e03db8 EFLAGS: 00000246
  ORIG_RAX: ffffffffffffff10
RAX: 0000000000000000 RBX: ffffe8ffff603cc8 RCX: 000000000000001f
RDX: 20c49ba5e353f7cf RSI: ffffffff81c5e743 RDI: ffffffff81c48102
RBP: ffffffff81e03df8 R08: cccccccccccccccd R09: 0000000000000018
R10: 000000000000022e R11: 0000000000000a2c R12: 0000000000000005
R13: ffffffff81eaf918 R14: 0000000000000005 R15: ffffffff81eaf900
 </IRQ>
 ? cpuidle_enter_state+0x113/0x360
 cpuidle_enter+0x17/0x20
 call_cpuidle+0x23/0x40
 do_idle+0xf6/0x1f0
 cpu_startup_entry+0x71/0x80
 rest_init+0xb8/0xc0
 start_kernel+0x432/0x453
 x86_64_start_reservations+0x2a/0x2c
 x86_64_start_kernel+0x178/0x18b
 start_cpu+0x14/0x14
 ? start_cpu+0x14/0x14
Code: fb 4c 89 e7 e8 b0 f1 01 00 0f b7 8b 2a 05 00 00 48 8b 93 18 05 00 00 80 bb 29 05 00 00 00 0f b6 bb 28 05 00 00 48 8b 34 ca 75 58 <8b> 56 0c 48 89 c8 85 d2 74 1d 8b 93 70 05 00 00 85 d2 74 13 f3 

All code
========
   0:	fb                   	sti    
   1:	4c 89 e7             	mov    %r12,%rdi
   4:	e8 b0 f1 01 00       	callq  0x1f1b9
   9:	0f b7 8b 2a 05 00 00 	movzwl 0x52a(%rbx),%ecx
  10:	48 8b 93 18 05 00 00 	mov    0x518(%rbx),%rdx
  17:	80 bb 29 05 00 00 00 	cmpb   $0x0,0x529(%rbx)
  1e:	0f b6 bb 28 05 00 00 	movzbl 0x528(%rbx),%edi
  25:	48 8b 34 ca          	mov    (%rdx,%rcx,8),%rsi
  29:	75 58                	jne    0x83
  2b:*	8b 56 0c             	mov    0xc(%rsi),%edx     <-- trapping instruction
  2e:	48 89 c8             	mov    %rcx,%rax
  31:	85 d2                	test   %edx,%edx
  33:	74 1d                	je     0x52
  35:	8b 93 70 05 00 00    	mov    0x570(%rbx),%edx
  3b:	85 d2                	test   %edx,%edx
  3d:	74 13                	je     0x52
  3f:	f3                   	repz

Code starting with the faulting instruction
===========================================
   0:	8b 56 0c             	mov    0xc(%rsi),%edx
   3:	48 89 c8             	mov    %rcx,%rax
   6:	85 d2                	test   %edx,%edx
   8:	74 1d                	je     0x27
   a:	8b 93 70 05 00 00    	mov    0x570(%rbx),%edx
  10:	85 d2                	test   %edx,%edx
  12:	74 13                	je     0x27
  14:	f3                   	repz

That code is the BLOCK_NUM_PKTS line here..

 677         spin_lock(&po->sk.sk_receive_queue.lock);
 678 
 679         frozen = prb_queue_frozen(pkc);
 680         pbd = GET_CURR_PBLOCK_DESC_FROM_CORE(pkc);
 681 
 682         if (unlikely(pkc->delete_blk_timer))
 683                 goto out;
 684 
 685         /* We only need to plug the race when the block is partially filled.
 686          * tpacket_rcv:
 687          *              lock(); increment BLOCK_NUM_PKTS; unlock()
 688          *              copy_bits() is in progress ...
 689          *              timer fires on other cpu:
 690          *              we can't retire the current block because copy_bits
 691          *              is in progress.
 692          *
 693          */
 694         if (BLOCK_NUM_PKTS(pbd)) {
