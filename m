From: Jon Masters <jonathan@jonmasters.org>
Subject: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6 kernels
Date: Thu, 28 Jan 2010 00:45:59 -0500
Message-ID: <1264657559.2793.103.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754456Ab0A1GZY@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

A number of people seem to have reported this crash in various forms,
but I have yet to see a solution, and can reproduce on 2.6.33-rc5 this
evening so I know it's still present in the latest upstream kernels too.
Userspace is Fedora 12, and this happens on both all recent F12 kernels
(sporadic in 2.6.31 until recently, solidly reproducible on 2.6.32) and
upstream 2.6.32, and 2.6.33-rc5 also - hard to find a "known good".

The problem happens when using netfilter with KVM (problem does not
occur without the firewall loaded, for example) and will occur within a
few minutes of attempting to start or stop a guest that is connecting to
the network - the easiest way to reproduce so far is simply to start up
a bunch of Fedora guests and have them do a "yum update" cycle.

All of the crashes appear similar to the following (2.6.33-rc5):

general protection fault: 0000 [#1] SMP 
last sysfs file: /sys/kernel/mm/ksm/run
CPU 6 
Pid: 2982, comm: qemu-kvm Not tainted 2.6.33-rc5 #2 0F9382/Precision
WorkStation 490    
RIP: 0010:[<ffffffff813b4115>]  [<ffffffff813b4115>] destroy_conntrack
+0x82/0x114
RSP: 0018:ffff880028383c48  EFLAGS: 00010202
RAX: 0000000080000001 RBX: ffffffff81af33a0 RCX: 0000000000007530
RDX: dead000000200200 RSI: 0000000000000011 RDI: ffffffff81af33a0
RBP: ffff880028383c58 R08: ffff8802171b14d0 R09: 000000000000000a
R10: 00000040283957c0 R11: ffff8800283838a8 R12: ffffffff81ddbce0
R13: ffffffffa0281389 R14: 0000000000000000 R15: ffff88021140f430
FS:  00007fc17b7d2780(0000) GS:ffff880028380000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fc12c038000 CR3: 00000001db1bb000 CR4: 00000000000026e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process qemu-kvm (pid: 2982, threadinfo ffff8801dab40000, task
ffff8801dab38000)
Stack:
 ffff88021140f400 ffff88021360e410 ffff880028383c68 ffffffff813b2016
<0> ffff880028383c88 ffffffff8138dbc3 ffff880028383c88 ffff88021140f400
<0> ffff880028383ca8 ffffffff8138d925 0000000300000000 ffff88021140f400
Call Trace:
 <IRQ> 
 [<ffffffff813b2016>] nf_conntrack_destroy+0x1b/0x1d
 [<ffffffff8138dbc3>] skb_release_head_state+0x77/0xb9
 [<ffffffff8138d925>] __kfree_skb+0x16/0x82
 [<ffffffff8138da2a>] kfree_skb+0x6a/0x73
 [<ffffffffa0281389>] ip6_mc_input+0x214/0x221 [ipv6]
 [<ffffffffa02813bd>] ip6_rcv_finish+0x27/0x2b [ipv6]
 [<ffffffffa02816c7>] ipv6_rcv+0x306/0x33f [ipv6]
 [<ffffffff813b2193>] ? nf_hook_slow+0x6a/0xcb
 [<ffffffff81395593>] ? netif_receive_skb+0x0/0x3c6
 [<ffffffff81395934>] netif_receive_skb+0x3a1/0x3c6
 [<ffffffffa02ebae6>] br_handle_frame_finish+0x104/0x13c [bridge]
 [<ffffffffa02ebcaf>] br_handle_frame+0x191/0x1aa [bridge]
 [<ffffffff813958a0>] netif_receive_skb+0x30d/0x3c6
 [<ffffffff813959e3>] process_backlog+0x8a/0xc3
 [<ffffffff81395fd8>] net_rx_action+0x78/0x17e
 [<ffffffff81052fda>] __do_softirq+0xe5/0x1a6
 [<ffffffff8100ab1c>] call_softirq+0x1c/0x30
 <EOI> 
 [<ffffffff8100c2b6>] ? do_softirq+0x46/0x83
 [<ffffffff81396104>] netif_rx_ni+0x26/0x2b
 [<ffffffffa0436d6e>] tun_chr_aio_write+0x3ce/0x429 [tun]
 [<ffffffffa04369a0>] ? tun_chr_aio_write+0x0/0x429 [tun]
 [<ffffffff81104b89>] do_sync_readv_writev+0xc1/0x100
 [<ffffffff811d0c2f>] ? selinux_file_permission+0xa7/0xb3
 [<ffffffff811048ed>] ? copy_from_user+0x2f/0x31
 [<ffffffff811c7149>] ? security_file_permission+0x16/0x18
 [<ffffffff811058d3>] do_readv_writev+0xa7/0x127
 [<ffffffff81066761>] ? unlock_timer+0x12/0x14
 [<ffffffff81066d18>] ? sys_timer_settime+0x258/0x2aa
 [<ffffffff81105996>] vfs_writev+0x43/0x4e
 [<ffffffff81105a86>] sys_writev+0x4a/0x93
 [<ffffffff81009c32>] system_call_fastpath+0x16/0x1b
Code: c7 00 cd dd 81 e8 67 f6 ff ff 48 89 df e8 90 28 00 00 f6 43 78 08
75 2a 48 8b 53 10 48 85 d2 75 04 0f 0b eb fe 48 8b 43 08 a8 01 <48> 89
02 75 04 48 89 50 08 48 b8 00 02 20 00 00 00 ad de 48 89 
RIP  [<ffffffff813b4115>] destroy_conntrack+0x82/0x114
 RSP <ffff880028383c48>
---[ end trace ee1619cd5f767f78 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 2982, comm: qemu-kvm Tainted: G      D    2.6.33-rc5 #2
Call Trace:
 <IRQ>  [<ffffffff81421fb5>] panic+0x7a/0x13d
 [<ffffffff81425569>] oops_end+0xb7/0xc7
 [<ffffffff8100d35d>] die+0x5a/0x63

Several people have suggested various sysctls. I note that my F12 box
has the following set by default now:

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

This does not fix the problem, although I am indeed using bridged
networking for the guest instances.

At this point, I've disabled loading the firewall modules on this box
since it's behind a firewall anyway and I need it to keep running more
than ten minutes at a time :) but I am obviously interested in helping
to track this down and fix it. I don't know the code in question and I
won't have time to poke much further until the weekend.

Jon.
