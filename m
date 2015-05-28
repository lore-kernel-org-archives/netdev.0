From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99091] New: Kernel panic while sending network packets
 over TAP interface
Date: Thu, 28 May 2015 07:35:56 -0700
Message-ID: <20150528073556.335fd7a3@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36492 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbbE1Of6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:35:58 -0400
Received: by pdfh10 with SMTP id h10so43103892pdf.3
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:35:57 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id yn5sm2624877pac.48.2015.05.28.07.35.56
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 07:35:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 28 May 2015 11:44:58 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99091] New: Kernel panic while sending network packets over TAP interface


https://bugzilla.kernel.org/show_bug.cgi?id=99091

            Bug ID: 99091
           Summary: Kernel panic while sending network packets over TAP
                    interface
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11 and higher
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: ras@open.ch
        Regression: No

We are experiencing kernel panics on a rather specific setup after upgrading to
kernel versions 3.12.40, 3.14.9, 3.16.7, 3.17.7 and 3.18.14. The same
configuration with kernel 3.10.79 runs stable.  Kernel 3.8 proved to be stable
as well.
Unfortunately we are unable to reproduce the bug in a lab environment, but on
one of our production hosts the kernel reliably panics within 24 hours.

In our setup, network traffic takes the following path:
(1) network interface => (2) bridge => (3) VLAN => (4) bridge => (5) TAP
interface => (6) Virtual Machine => (7) bridge => (8) VLAN => (9) bridge =>
(10) GRE interface
The bridges (4) and (7) reply to any ARP request with their MAC address to suck
all traffic into the virtual machine and forward everything coming out of the
virtual machine.

Bisecting points us to commit eda29772 "tun: Support software transmit time
stamping.", but sometimes we did not get a crash dump, so further manual
verification was needed. We managed to prevent 3.18.8 from crashing by removing
commit eda29772 and a few successive fixes (7bf66305, f96eb74c, 4bfb0513). The
crash dump indicates that skb_tstamp_tx() is called from tun_net_xmit(), which
can only happen since the first chunk of eda29772. Several fixes for eda29772
appeared on the stable branches, none of which helps in our case.
We assume the packet in transit during the crash must have been locally
created, as sk_buff->sk must be set to match the call sequence.
We further assume that the crash happens during transmit on a TAP interface
(5), as we see no crashes with traffic over GRE interfaces with TAP interfaces
disabled.
Our setup is designed specifically to cause the calling path "bridge transmit"
- "VLAN transmit" - "bridge transmit" - "GRE or TAP transmit" as reflected by
the crash dump. It appears that this sequence hits a race condition or a
corrupted/uninitialized error queue in skb_queue_tail().

Here is a stack trace from a crashed Linux kernel based on commit 82a54d0e
(linux 3.11-rc1):

general protection fault: 0000 [#1] SMP 
Modules linked in: adm1021 vhost_net vhost macvtap xt_TEE xt_condition(O)
xt_set ip6t_ipv6header ip6t_rt ip6t_eui64 ip6t_frag ip6t_mh ip6t_hbh ip6t_ah
ip6t_REJECT ip6table_mangle ip6table_raw ip6table_filter nf_conntrack_ipv6
nf_defrag_ipv6 ip6_tables ebt_ip6 ip_set_hash_ip ip_set pl2303 e1000e ptp
pps_core i2c_i801 coretemp
CPU: 5 PID: 0 Comm: swapper/5 Tainted: G           O 3.11.0-rc1_1-osix- #1
Hardware name: To be filled by O.E.M. To be filled by O.E.M./To be filled by
O.E.M., BIOS 4.6.4 12/28/2012
task: ffff88042b99cfe0 ti: ffff88042b9a2000 task.ti: ffff88042b9a2000
RIP: 0010:[<ffffffff8148615d>]  [<ffffffff8148615d>] skb_queue_tail+0x2e/0x44
RSP: 0018:ffff880440343828  EFLAGS: 00010046
RAX: 0000000000000246 RBX: ffff880411aaa950 RCX: 0000000000000000
RDX: 35322e3535322e35 RSI: 0000000000000246 RDI: ffff880411aaa964
RBP: ffff880440343840 R08: ffff8804284879e8 R09: 00000000100a0081
R10: 000000000000ffff R11: ffff8804129d8000 R12: ffff8804284879c0
R13: ffff880411aaa964 R14: 00000008000000c1 R15: 000000000000100a
FS:  0000000000000000(0000) GS:ffff880440340000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f7900bb1218 CR3: 0000000424c99000 CR4: 00000000000427e0
Stack:
 0000000000000000 ffff880411aaa800 0000000000000042 ffff880440343870
 ffffffff81486210 ffff880411aaa800 ffff8804284879c0 ffff880411aaa800
 ffff880428919800 ffff880440343898 ffffffff81487d79 ffff880425480180
Call Trace:
 <IRQ> 
 [<ffffffff81486210>] sock_queue_err_skb+0x9d/0xc8
 [<ffffffff81487d79>] skb_tstamp_tx+0x80/0x93
 [<ffffffff813c67d7>] tun_net_xmit+0x15a/0x284
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814a8cca>] sch_direct_xmit+0x70/0x185
 [<ffffffff81492f75>] dev_queue_xmit+0x234/0x429
 [<ffffffff815879ad>] br_dev_queue_push_xmit+0xa1/0xa6
 [<ffffffff815879d4>] br_forward_finish+0x22/0x4f
 [<ffffffff81587a45>] __br_deliver+0x44/0x72
 [<ffffffff81587d9e>] br_deliver+0x56/0x5b
 [<ffffffff81586164>] br_dev_xmit+0x15d/0x17d
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff81599b7b>] vlan_dev_hard_start_xmit+0x82/0xac
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff815879ad>] br_dev_queue_push_xmit+0xa1/0xa6
 [<ffffffff815879d4>] br_forward_finish+0x22/0x4f
 [<ffffffff81587a45>] __br_deliver+0x44/0x72
 [<ffffffff81587d9e>] br_deliver+0x56/0x5b
 [<ffffffff81586164>] br_dev_xmit+0x15d/0x17d
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff815329e0>] ? nf_nat_ipv4_out+0x42/0xbf
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff814ecdd5>] ip_finish_output+0x2be/0x31c
 [<ffffffff814edf79>] ip_output+0x48/0x82
 [<ffffffff814eaee0>] ip_forward_finish+0x62/0x65
 [<ffffffff814eb16c>] ip_forward+0x289/0x301
 [<ffffffff814e9978>] ip_rcv_finish+0x26b/0x2ad
 [<ffffffff814e9d77>] ip_rcv+0x257/0x2c4
 [<ffffffff8149089a>] __netif_receive_skb_core+0x55d/0x5a6
 [<ffffffff81490c72>] __netif_receive_skb+0x18/0x5a
 [<ffffffff81490cf7>] netif_receive_skb+0x43/0x78
 [<ffffffff813c33eb>] ri_tasklet+0x1ad/0x28b
 [<ffffffff8109732e>] tasklet_action+0x77/0xbe
 [<ffffffff8109791d>] __do_softirq+0xca/0x18c
 [<ffffffff81097ade>] irq_exit+0x53/0xb0
 [<ffffffff810b3d05>] scheduler_ipi+0xee/0x118
 [<ffffffff8105bcd3>] smp_reschedule_interrupt+0x25/0x27
 [<ffffffff815ae81d>] reschedule_interrupt+0x6d/0x80
 <EOI> 
 [<ffffffff8106478a>] ? native_safe_halt+0x6/0x8
 [<ffffffff8104268f>] default_idle+0x9/0xd
 [<ffffffff81042ca6>] arch_cpu_idle+0x13/0x1e
 [<ffffffff810c0b9e>] cpu_startup_entry+0x10d/0x169
 [<ffffffff8105c3f2>] start_secondary+0x1f5/0x1f9
Code: e5 41 55 4c 8d 6f 14 41 54 49 89 f4 53 48 89 fb 4c 89 ef e8 d5 6a 12 00
48 8b 53 08 49 89 1c 24 4c 89 ef 48 89 c6 49 89 54 24 08 <4c> 89 22 ff 43 10 4c
89 63 08 e8 ed 6a 12 00 5b 41 5c 41 5d 5d 
RIP  [<ffffffff8148615d>] skb_queue_tail+0x2e/0x44
 RSP <ffff880440343828>
---[ end trace 726ceceef820f680 ]---
Kernel panic - not syncing: Fatal exception in interrupt
------------[ cut here ]------------
WARNING: CPU: 5 PID: 0 at arch/x86/kernel/smp.c:124
native_smp_send_reschedule+0x25/0x57()
Modules linked in: adm1021 vhost_net vhost macvtap xt_TEE xt_condition(O)
xt_set ip6t_ipv6header ip6t_rt ip6t_eui64 ip6t_frag ip6t_mh ip6t_hbh ip6t_ah
ip6t_REJECT ip6table_mangle ip6table_raw ip6table_filter nf_conntrack_ipv6
nf_defrag_ipv6 ip6_tables ebt_ip6 ip_set_hash_ip ip_set pl2303 e1000e ptp
pps_core i2c_i801 coretemp
CPU: 5 PID: 0 Comm: swapper/5 Tainted: G      D    O 3.11.0-rc1_1-osix- #1
Hardware name: To be filled by O.E.M. To be filled by O.E.M./To be filled by
O.E.M., BIOS 4.6.4 12/28/2012
 ffffffff816502f0 ffff8804403433f8 ffffffff815a7140 0000000000000000
 ffff880440343430 ffffffff81091368 ffffffff8105bafe 0000000000000001
 00000000000129c0 0000000000000005 0000000000000005 ffff880440343440
Call Trace:
 <IRQ>  [<ffffffff815a7140>] dump_stack+0x45/0x56
 [<ffffffff81091368>] warn_slowpath_common+0x75/0x8e
 [<ffffffff8105bafe>] ? native_smp_send_reschedule+0x25/0x57
 [<ffffffff81091420>] warn_slowpath_null+0x15/0x17
 [<ffffffff8105bafe>] native_smp_send_reschedule+0x25/0x57
 [<ffffffff810bd220>] trigger_load_balance+0x1e0/0x1eb
 [<ffffffff810b3e35>] scheduler_tick+0x82/0x94
 [<ffffffff8109cbb3>] update_process_times+0x57/0x66
 [<ffffffff810c825f>] tick_sched_handle+0x32/0x34
 [<ffffffff810c8aa1>] tick_sched_timer+0x35/0x53
 [<ffffffff810c8a6c>] ? tick_sched_do_timer+0x41/0x41
 [<ffffffff810ada0f>] __run_hrtimer.isra.27+0x59/0xb2
 [<ffffffff810adee1>] hrtimer_interrupt+0xde/0x1c5
 [<ffffffff8105d6e1>] local_apic_timer_interrupt+0x4f/0x52
 [<ffffffff8105da87>] smp_apic_timer_interrupt+0x3a/0x4b
 [<ffffffff815ae49d>] apic_timer_interrupt+0x6d/0x80
 [<ffffffff815a5459>] ? panic+0x18c/0x1ca
 [<ffffffff815a53c8>] ? panic+0xfb/0x1ca
 [<ffffffff8103e407>] oops_end+0xb7/0xc6
 [<ffffffff8103e53d>] die+0x55/0x5e
 [<ffffffff8103c06e>] do_general_protection+0xa5/0x158
 [<ffffffff815ad328>] general_protection+0x28/0x30
 [<ffffffff8148615d>] ? skb_queue_tail+0x2e/0x44
 [<ffffffff8148614a>] ? skb_queue_tail+0x1b/0x44
 [<ffffffff81486210>] sock_queue_err_skb+0x9d/0xc8
 [<ffffffff81487d79>] skb_tstamp_tx+0x80/0x93
 [<ffffffff813c67d7>] tun_net_xmit+0x15a/0x284
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814a8cca>] sch_direct_xmit+0x70/0x185
 [<ffffffff81492f75>] dev_queue_xmit+0x234/0x429
 [<ffffffff815879ad>] br_dev_queue_push_xmit+0xa1/0xa6
 [<ffffffff815879d4>] br_forward_finish+0x22/0x4f
 [<ffffffff81587a45>] __br_deliver+0x44/0x72
 [<ffffffff81587d9e>] br_deliver+0x56/0x5b
 [<ffffffff81586164>] br_dev_xmit+0x15d/0x17d
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff81599b7b>] vlan_dev_hard_start_xmit+0x82/0xac
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff815879ad>] br_dev_queue_push_xmit+0xa1/0xa6
 [<ffffffff815879d4>] br_forward_finish+0x22/0x4f
 [<ffffffff81587a45>] __br_deliver+0x44/0x72
 [<ffffffff81587d9e>] br_deliver+0x56/0x5b
 [<ffffffff81586164>] br_dev_xmit+0x15d/0x17d
 [<ffffffff81492c17>] dev_hard_start_xmit+0x29e/0x3c8
 [<ffffffff815329e0>] ? nf_nat_ipv4_out+0x42/0xbf
 [<ffffffff814930b6>] dev_queue_xmit+0x375/0x429
 [<ffffffff814ecdd5>] ip_finish_output+0x2be/0x31c
 [<ffffffff814edf79>] ip_output+0x48/0x82
 [<ffffffff814eaee0>] ip_forward_finish+0x62/0x65
 [<ffffffff814eb16c>] ip_forward+0x289/0x301
 [<ffffffff814e9978>] ip_rcv_finish+0x26b/0x2ad
 [<ffffffff814e9d77>] ip_rcv+0x257/0x2c4
 [<ffffffff8149089a>] __netif_receive_skb_core+0x55d/0x5a6
 [<ffffffff81490c72>] __netif_receive_skb+0x18/0x5a
 [<ffffffff81490cf7>] netif_receive_skb+0x43/0x78
 [<ffffffff813c33eb>] ri_tasklet+0x1ad/0x28b
 [<ffffffff8109732e>] tasklet_action+0x77/0xbe
 [<ffffffff8109791d>] __do_softirq+0xca/0x18c
 [<ffffffff81097ade>] irq_exit+0x53/0xb0
 [<ffffffff810b3d05>] scheduler_ipi+0xee/0x118
 [<ffffffff8105bcd3>] smp_reschedule_interrupt+0x25/0x27
 [<ffffffff815ae81d>] reschedule_interrupt+0x6d/0x80
 <EOI>  [<ffffffff8106478a>] ? native_safe_halt+0x6/0x8
 [<ffffffff8104268f>] default_idle+0x9/0xd
 [<ffffffff81042ca6>] arch_cpu_idle+0x13/0x1e
 [<ffffffff810c0b9e>] cpu_startup_entry+0x10d/0x169
 [<ffffffff8105c3f2>] start_secondary+0x1f5/0x1f9
---[ end trace 726ceceef820f681 ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
