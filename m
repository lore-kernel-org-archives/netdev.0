From: Philipp Reisner <philipp.reisner@linbit.com>
Subject: Issue with connector/netlink
Date: Thu, 29 Mar 2007 20:47:18 +0200
Message-ID: <200703292047.19208.philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aug.linbit.com ([212.69.162.22]:38720 "EHLO mail.linbit.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934328AbXC2TTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 15:19:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Evgenjy,

Again we run into an issue in the connector/netlink code
path. This time we were not able to create a fix. But 
please allow me to describe everything:

Kernel: 2.6.20.3 

The OOPS:

general protection fault: 0000 [1] SMP
CPU 0
Modules linked in: tun nfs lockd nfs_acl sunrpc ipv6 bridge kvm_intel kvm drbd cn tsde
v i2c_i801 psmouse i2c_core floppy pcspkr serio_raw parport_pc parport evdev shpchp pc
i_hotplug ext3 jbd mbcache dm_mirror dm_snapshot dm_mod raid1 raid0 md_mod ide_generic
 sd_mod ata_piix libata scsi_mod generic ide_core ehci_hcd uhci_hcd e1000 thermal proc
essor fan
Pid: 1948, comm: cqueue/0 Not tainted 2.6.20.3 #2
RIP: 0010:[<ffffffff8024f904>]  [<ffffffff8024f904>] netlink_broadcast+0x123/0x2de
RSP: 0018:ffff8100379bddc0  EFLAGS: 00010297
RAX: 656b736968772d31 RBX: ffff810079d7f800 RCX: 0000000000000004
RDX: ffff81007e113000 RSI: ffff810079d68280 RDI: ffffffff804c6a80
RBP: ffff810079d68280 R08: 00000000000000d0 R09: ffff810079d68280
R10: 0000000000000002 R11: ffff81007fd6fac0 R12: 0000000000000020
R13: 0000000000000000 R14: ffff810079d7f818 R15: 0000000000000003
FS:  0000000000000000(0000) GS:ffffffff804d6000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00002b2acc1ecb40 CR3: 0000000079ac1000 CR4: 00000000000026e0
Process cqueue/0 (pid: 1948, threadinfo ffff8100379bc000, task ffff810037fd8040)
Stack:  ffff810079d7f400 00000000000000d0 ffff81007e113000 000000007e069a24
 0000000000000000 0000000000000100 ffff810079d7f400 ffff81007e069a10
 ffff81007e069a24 ffffffff881e9d00 ffff81007cf07800 ffffffff881d5c23
Call Trace:
 [<ffffffff881d5c23>] :drbd:drbd_connector_callback+0x14f/0x19c
 [<ffffffff881b70c3>] :cn:cn_queue_wrapper+0x0/0x33
 [<ffffffff881b70d8>] :cn:cn_queue_wrapper+0x15/0x33
 [<ffffffff881b70c3>] :cn:cn_queue_wrapper+0x0/0x33
 [<ffffffff80247176>] run_workqueue+0x8f/0x137
 [<ffffffff80243ddc>] worker_thread+0x0/0x14a
 [<ffffffff8028e63b>] keventd_create_kthread+0x0/0x65
 [<ffffffff80243ef0>] worker_thread+0x114/0x14a
 [<ffffffff8027c586>] default_wake_function+0x0/0xe
 [<ffffffff8022ef0a>] kthread+0xd1/0x100
 [<ffffffff80256ec8>] child_rip+0xa/0x12
 [<ffffffff8028e63b>] keventd_create_kthread+0x0/0x65
 [<ffffffff8022ee39>] kthread+0x0/0x100
 [<ffffffff80256ebe>] child_rip+0x0/0x12

Code: 44 0f a3 38 19 c0 85 c0 0f 84 17 01 00 00 83 7c 24 24 00 74

Decoded:

>>RIP; ffffffff8024f904 <netlink_broadcast+123/2de>   <=====

>>RAX; 656b736968772d31 <phys_startup_64+656b736968572c31/ffffffff7fffff00>
>>RBX; ffff810079d7f800 <phys_startup_64+ffff810079b7f700/ffffffff7fffff00>
>>RDX; ffff81007e113000 <phys_startup_64+ffff81007df12f00/ffffffff7fffff00>
>>RSI; ffff810079d68280 <phys_startup_64+ffff810079b68180/ffffffff7fffff00>
>>RDI; ffffffff804c6a80 <nl_table_lock+0/10>
>>RBP; ffff810079d68280 <phys_startup_64+ffff810079b68180/ffffffff7fffff00>
>>R09; ffff810079d68280 <phys_startup_64+ffff810079b68180/ffffffff7fffff00>
>>R11; ffff81007fd6fac0 <phys_startup_64+ffff81007fb6f9c0/ffffffff7fffff00>
>>R14; ffff810079d7f818 <phys_startup_64+ffff810079b7f718/ffffffff7fffff00>

Trace; ffffffff881d5c23 <_end+7c0ffb3/7f03a390>
Trace; ffffffff881b70c3 <_end+7bf1453/7f03a390>
Trace; ffffffff881b70d8 <_end+7bf1468/7f03a390>
Trace; ffffffff881b70c3 <_end+7bf1453/7f03a390>
Trace; ffffffff80247176 <run_workqueue+8f/137>
Trace; ffffffff80243ddc <worker_thread+0/14a>
Trace; ffffffff8028e63b <keventd_create_kthread+0/65>
Trace; ffffffff80243ef0 <worker_thread+114/14a>
Trace; ffffffff8027c586 <default_wake_function+0/e>
Trace; ffffffff8022ef0a <kthread+d1/100>
Trace; ffffffff80256ec8 <child_rip+a/12>
Trace; ffffffff8028e63b <keventd_create_kthread+0/65>
Trace; ffffffff8022ee39 <kthread+0/100>
Trace; ffffffff80256ebe <child_rip+0/12>

Code;  ffffffff8024f904 <netlink_broadcast+123/2de>
0000000000000000 <_RIP>:
Code;  ffffffff8024f904 <netlink_broadcast+123/2de>   <=====
   0:   44 0f a3 38               bt     %r15d,(%rax)   <=====
Code;  ffffffff8024f908 <netlink_broadcast+127/2de>
   4:   19 c0                     sbb    %eax,%eax
Code;  ffffffff8024f90a <netlink_broadcast+129/2de>
   6:   85 c0                     test   %eax,%eax
Code;  ffffffff8024f90c <netlink_broadcast+12b/2de>
   8:   0f 84 17 01 00 00         je     125 <_RIP+0x125>
Code;  ffffffff8024f912 <netlink_broadcast+131/2de>
   e:   83 7c 24 24 00            cmpl   $0x0,0x24(%rsp)
Code;  ffffffff8024f917 <netlink_broadcast+136/2de>
  13:   74 00                     je     15 <_RIP+0x15>

It happens in netlink_broadcast() which seems to get called
from drbd_connector_callback(). Drbd_connector_callback() 
calls cn_netlink_send(), which in turn calls netlink_broadcast().
   I guess this little detail is missing from the trace since
   the call to netlink_broadcast() happens with the return
   statement in cn_netlink_send().

netlink_broadcast() in turn calls the inlined function
do_one_broadcast(), in which the OOPS happens. It is the test_bit()
call!

static inline int do_one_broadcast(struct sock *sk,
                                   struct netlink_broadcast_data *p)
{
        struct netlink_sock *nlk = nlk_sk(sk);
        int val;

        if (p->exclude_sk == sk)
                goto out;

        if (nlk->pid == p->pid || p->group - 1 >= nlk->ngroups ||
            !test_bit(p->group - 1, nlk->groups)) <=<<==<<<===<<<<====<<<<<======
                goto out;

        if (p->failure) {
                netlink_overrun(sk);
                goto out;
        }

        sock_hold(sk);
        if (p->skb2 == NULL) {
                if (skb_shared(p->skb)) {
                        p->skb2 = skb_clone(p->skb, p->allocation);
                } else {
                        p->skb2 = skb_get(p->skb);
                        /*
                         * skb ownership may have been set when
                         * delivered to a previous socket.
                         */
                        skb_orphan(p->skb2);
                }
        }
        if (p->skb2 == NULL) {
                netlink_overrun(sk);
                /* Clone failed. Notify ALL listeners. */
                p->failure = 1;
        } else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
                netlink_overrun(sk);
        } else {
                p->congested |= val;
                p->delivered = 1;
                p->skb2 = NULL;
        }
        sock_put(sk);

out:
        return 0;
}

Here is a bit more of the context in assembler source:

.LBE884:
.LBE883:
        .stabn  68,0,937,.LM391-netlink_broadcast
.LM391:
        movzbl  57(%rdx), %eax
        imulq   $80, %rax, %rax
        addq    nl_table(%rip), %rax
        movq    40(%rax), %r14
.LBB885:
.LBB886:
        .stabn  68,0,875,.LM392-netlink_broadcast
.LM392:
        movl    $0, 28(%rsp)
        movl    $0, 32(%rsp)
        movl    $0, 36(%rsp)
        jmp     .L239
.L276:
        movl    12(%rsp), %eax
        cmpl    %eax, 544(%rbx)
        je      .L241
        cmpl    564(%rbx), %r15d
        jae     .L241
        movq    568(%rbx), %rax
.LBB887:
.LBB888:
        .stabs  "include/asm/bitops.h",132,0,0,.Ltext105
.Ltext105:
        .stabn  68,0,243,.LM393-netlink_broadcast
.LM393:
#APP
        btl %r15d,(%rax) <=<<==<<<===<<<<====<<<<<=====<<<<<<======
        sbbl %eax,%eax
#NO_APP
.LBE888:
.LBE887:
        .stabs  "net/netlink/af_netlink.c",132,0,0,.Ltext106
.Ltext106:
        .stabn  68,0,875,.LM394-netlink_broadcast
.LM394:
        testl   %eax, %eax
        je      .L241
        .stabn  68,0,879,.LM395-netlink_broadcast
.LM395:
        cmpl    $0, 36(%rsp)
        je      .L245
        .stabn  68,0,880,.LM396-netlink_broadcast
.LM396:
        movq    %rbx, %rdi
        call    netlink_overrun
        jmp     .L241

I hope that all this helps you to understand the issue... Thats too much
of networking internals for me...

-Phil
