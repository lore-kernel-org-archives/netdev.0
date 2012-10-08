From: Cong Wang <amwang@redhat.com>
Subject: BUG: unable to handle kernel NULL pointer dereference in
 qfq_dequeue()
Date: Mon, 08 Oct 2012 17:15:56 +0800
Message-ID: <1349687756.2707.21.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@redhat.com>
To: stephen hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733Ab2JHJQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 05:16:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all,

We got the following kernel crash on RHEL6 and I confirmed upstream has
the same problem (I didn't save this kernel log though):

BUG: unable to handle kernel NULL pointer dereference at
0000000000000010
IP: [<ffffffffa02c3dca>] qfq_dequeue+0x30a/0x490 [sch_qfq]
PGD 1fbed067 PUD 1b103067 PMD 0 
Oops: 0000 [#1] SMP 
last sysfs
file: /sys/devices/pci0000:00/0000:00:08.0/virtio4/net/eth2/address
CPU 0 
Modules linked in: cls_u32 sch_qfq sch_cbq ip6t_REJECT nf_conntrack_ipv6
nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables ipv6
virtio_balloon snd_intel8x0 snd_ac97_codec ac97_bus snd_seq
snd_seq_device
snd_pcm snd_timer snd soundcore snd_page_alloc virtio_net i2c_piix4
i2c_core
ext4 mbcache jbd2 virtio_blk virtio_pci virtio_ring virtio pata_acpi
ata_generic ata_piix dm_mirror dm_region_hash dm_log dm_mod [last
unloaded:
scsi_wait_scan]

Pid: 0, comm: swapper Not tainted 2.6.32-259.el6.x86_64 #1 Red Hat KVM
RIP: 0010:[<ffffffffa02c3dca>]  [<ffffffffa02c3dca>] qfq_dequeue
+0x30a/0x490
[sch_qfq]
RSP: 0018:ffff880002203da0  EFLAGS: 00010287
RAX: ffffffffffffffb0 RBX: ffff88001f45e0c0 RCX: 0000000000000029
RDX: fffffe0000000000 RSI: 0000000000000001 RDI: ffff88001f45f718
RBP: ffff880002203de0 R08: 0000000000000007 R09: 0000000225c602e3
R10: 00000000ffffffff R11: dead000000200200 R12: 0000000000000013
R13: ffff88001f124ea8 R14: ffff88001f45f6b8 R15: 0028940000000000
FS:  0000000000000000(0000) GS:ffff880002200000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000010 CR3: 000000001b277000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff81a00000, task
ffffffff81a8d020)
Stack:
 ffff88001f45e000 0028900000000000 ffff880002203de0 ffff88001f4fcc00
<d> ffff88001f4fcc00 0000000000000000 0000000000000001 ffff88001ad640c0
<d> ffff880002203e60 ffffffffa02b9c85 ffff88001f4fcc00 ffff88001f4fcc00
Call Trace:
 <IRQ> 
 [<ffffffffa02b9c85>] cbq_dequeue+0x365/0x730 [sch_cbq]
 [<ffffffff81456c3f>] __qdisc_run+0x3f/0xe0
 [<ffffffff81436c00>] net_tx_action+0x130/0x1c0
 [<ffffffff8102b46d>] ? lapic_next_event+0x1d/0x30
 [<ffffffff81073d81>] __do_softirq+0xc1/0x1e0
 [<ffffffff81096b10>] ? hrtimer_interrupt+0x140/0x250
 [<ffffffff8100c24c>] call_softirq+0x1c/0x30
 [<ffffffff8100de85>] do_softirq+0x65/0xa0
 [<ffffffff81073b65>] irq_exit+0x85/0x90
 [<ffffffff81502bc0>] smp_apic_timer_interrupt+0x70/0x9b
 [<ffffffff8100bc13>] apic_timer_interrupt+0x13/0x20
 <EOI> 
 [<ffffffff810387cb>] ? native_safe_halt+0xb/0x10
 [<ffffffff810149cd>] default_idle+0x4d/0xb0
 [<ffffffff81009e06>] cpu_idle+0xb6/0x110
 [<ffffffff814e137a>] rest_init+0x7a/0x80
 [<ffffffff81c21f7b>] start_kernel+0x424/0x430
 [<ffffffff81c2133a>] x86_64_start_reservations+0x125/0x129
 [<ffffffff81c21438>] x86_64_start_kernel+0xfa/0x109
Code: 7c 03 50 4d 8b 7e 58 e8 b5 f6 ff ff 48 85 c0 0f 84 3c 01 00 00 41
8b 4e
60 be 01 00 00 00 49 8d 7e 60 48 89 f2 48 d3 e2 48 f7 da <48> 23 50 60
49 39 56
50 0f 84 d6 00 00 00 b8 02 00 00 00 49 89 
RIP  [<ffffffffa02c3dca>] qfq_dequeue+0x30a/0x490 [sch_qfq]
 RSP <ffff880002203da0>
CR2: 0000000000000010


This crash can be easily reproduced in KVM guests by the following
steps:

1. on virt-guest1 setup qdisc with qfq with this script:
http://pastebin.com/BRaSXLzq
2. on virt-guest2 start listening on ports 1234, 1235
# nc -l 1234 > /dev/null 2>&1
# nc -l 1235 > /dev/null 2>&1
3. on virt-guest1 send traffic to virt-guest2
# yes | nc $virt-guest2_ip_addr 1234
# yes | nc $virt-guest2_ip_addr 1235

I am not familiar with qfq qdisc. Any ideas?

Thanks!
