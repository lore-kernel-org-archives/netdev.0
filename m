From: Dave Jones <davej@redhat.com>
Subject: 3.6rc6 use-after-free in destroy_conntrack()
Date: Fri, 21 Sep 2012 11:31:58 -0400
Message-ID: <20120921153158.GA25012@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefw@redhat.com,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753684Ab2IUPcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 11:32:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We just had a report of this happening during shutdown..

There's a blurry photograph of the full trace here.. https://bugzilla.redhat.com/attachment.cgi?id=615311

Rough transcription:

general protection fault
RIP: destroy_conntrack+0x88

RAX: 6b6b6b6b6b6b6b6b6b6b

trace:
 ? destroy_conntrack
 ? __nf_conntrack_find
 nf_conntrack_destroy
 ? nf_regsiter_afinfo
 skb_release_head_state
 __kfree
 kfree
 arp_error_report
 ? neigh_parms_alloc
 neigh_invalidate
 ? neigh_parms_alloc
 neigh_timer_handler
 run_timer_softirq
 ? run_timer_softirq
 __do_softirq
 call_softirq
 do_softirq
 irq_exit
 smp_apic_timer_interrupt
 apic_timer_interrupt
 <EOI>
 ? mwait_idle
 ? mwait_idle
 cpu_idle
 start_secondary

Disassembly of the code line shows that the dereference is happening here
in destroy_conntrack ..


        l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
    1403:       0f b6 b3 86 00 00 00    movzbl 0x86(%rbx),%esi
    140a:       0f b7 7b 72             movzwl 0x72(%rbx),%edi
    140e:       e8 00 00 00 00          callq  1413 <destroy_conntrack+0x83>
->       if (l4proto && l4proto->destroy)
    1413:       48 85 c0                test   %rax,%rax
    1416:       74 0e                   je     1426 <destroy_conntrack+0x96>
    1418:       48 8b 40 28             mov    0x28(%rax),%rax

'l4proto' seems to have been freed already, judging by the value in rax.

	Dave
