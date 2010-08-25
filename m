From: Michael Tokarev <mjt@tls.msk.ru>
Subject: [stable 2.6.32] instant crash (jump to NULL) with virtio-net, tap,
 bridge and veth
Date: Wed, 25 Aug 2010 19:50:24 +0400
Message-ID: <4C753BC0.6010803@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, kvm-devel <kvm@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:55377 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821Ab0HYPu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 11:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I'm seeing instant host kernel crash triggered by _any_
network activity to/from a kvm guest that's using virtio-net.

My setup is maybe a bit unusual, but here we go.

I've a host machine that has one bridge configured,
and is running a few kvm virtual machines and a few
linux containers (LXC).  All the guests/containers
are "connected" to that single bridge - guests using
tap devices, lxc containers using veth devices. Host
eth0 is connected to the same bridge as well.

The problem happens with virtio-net drivers used in
guest (this is windowsXP virtual machine with latest
netkvm driver from alt.fedoraproject.org), when I
connect to that guest from an LXC container.  I.e,
when packet goes lxc => veth => bridge => tun =>
kvm => virtio in guest (or back).

When I connect to the same guest from _host_, it all
works as expected.  When I change (virtual) NIC in
guest to e1000 or older (from 2009) virtio-net driver,
it works.  When I connect from lxc container to a
linux guest with latest virtio-net drivers, it all
works as expected too.  So only one combination so
far that triggers the issue.

This is all with 2.6.32 kernel.  Initially it was
2.6.32.15, but 2.6.32.20 behaves the same way too.
All 64bit.

Also it does NOT happen with 2.6.35.3, the current
latest released kernel.

Here's one of captured OOPSes (i did it several
times, but they were incomplete):

console [netcon0] enabled
netconsole: network logging started
BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
PGD 177bf2067 PUD 177ae5067 PMD 0
Oops: 0010 [#1] SMP
last sysfs file: /sys/devices/virtual/block/md8/md/mismatch_cnt
CPU 0
Modules linked in: netconsole configfs squashfs kvm_amd kvm veth autofs4 bridge quota_v2 quota_tree ext4 jbd2 crc16 raid0 raid456 async_pq async_xor xor async_memcpy async_raid6_recov raid6_pq async_tx loop sr_mod cdrom tun powernow_k8 processor thermal_sys 8021q garp stp llc asus_atk0110 hwmon atl1 mii ext3 jbd mbcache raid1 md_mod pata_atiixp ehci_hcd ohci_hcd usbcore nls_base ahci libata sd_mod scsi_mod
Pid: 2345, comm: kvm Not tainted 2.6.32-amd64 #2.6.32.20 System Product Name
RIP: 0010:[<0000000000000000>]  [<(null)>] (null)
RSP: 0018:ffff880028203e70  EFLAGS: 00010293
RAX: ffff880179480ec0 RBX: ffff8801a07770c0 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffff8801a07770c0 RDI: ffff8801a07770c0
RBP: ffff880124b89030 R08: ffffffff8125fab0 R09: ffff880028203e40
R10: 0000000000000000 R11: 0000000000000000 R12: ffff880028210888
R13: ffff880028210880 R14: 000000010000e60f R15: 0000000000000040
FS:  00007fe2da5e5700(0000) GS:ffff880028200000(0000) knlGS:00000000f74a59d0
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000177a8a000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kvm64 (pid: 2345, threadinfo ffff880177be2000, task ffff880177a7c0c0)
Stack:
 ffffffff8125fbd5 0000000000000040 ffffffff8126013c 0000000080000000
<0> ffff8800282108b8 0000000000000002 ffff880028210888 ffff880028210880
<0> ffffffff81236276 ffff880028203f48 ffff8800282108b8 0000000000000000
Call Trace:
 <IRQ>
 [<ffffffff8125fbd5>] ? ip_rcv_finish+0x125/0x430
 [<ffffffff8126013c>] ? ip_rcv+0x25c/0x350
 [<ffffffff81236276>] ? process_backlog+0x76/0xd0
 [<ffffffff81236a18>] ? net_rx_action+0xf8/0x1f0
 [<ffffffff81059120>] ? __do_softirq+0xb0/0x1d0
 [<ffffffff8100c56c>] ? call_softirq+0x1c/0x30
 <EOI>
 [<ffffffff8100e595>] ? do_softirq+0x65/0xa0
 [<ffffffff81236b2e>] ? netif_rx_ni+0x1e/0x30
 [<ffffffffa014e97a>] ? tun_chr_aio_write+0x35a/0x510 [tun]
 [<ffffffffa014e620>] ? tun_chr_aio_write+0x0/0x510 [tun]
 [<ffffffff810ffea4>] ? do_sync_readv_writev+0xd4/0x110
 [<ffffffff8106e890>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff81071709>] ? enqueue_hrtimer+0x79/0xc0
 [<ffffffff810ffd08>] ? rw_copy_check_uvector+0x88/0x110
 [<ffffffff811005bc>] ? do_readv_writev+0xdc/0x220
 [<ffffffff8106dafc>] ? sys_timer_settime+0x13c/0x2e0
 [<ffffffff8110084e>] ? sys_writev+0x4e/0x90
 [<ffffffff8100b482>] ? system_call_fastpath+0x16/0x1b
Code:  Bad RIP value.
RIP  [<(null)>] (null)
 RSP <ffff880028203e70>
CR2: 0000000000000000
---[ end trace 1dcd3c52bde0fa25 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 2345, comm: kvm Tainted: G      D    2.6.32-amd64 #2.6.32.20
Call Trace:
 <IRQ>  [<ffffffff812c22de>] ? panic+0x7a/0x134
 [<ffffffff812c23d8>] ? printk+0x40/0x48
 [<ffffffff8100faa3>] ? oops_end+0xa3/0xb0
 [<ffffffff8103138a>] ? no_context+0xfa/0x260
 [<ffffffff812c52a5>] ? page_fault+0x25/0x30
 [<ffffffff8125fab0>] ? ip_rcv_finish+0x0/0x430
 [<ffffffff8125fbd5>] ? ip_rcv_finish+0x125/0x430
 [<ffffffff8126013c>] ? ip_rcv+0x25c/0x350
 [<ffffffff81236276>] ? process_backlog+0x76/0xd0
 [<ffffffff81236a18>] ? net_rx_action+0xf8/0x1f0
 [<ffffffff81059120>] ? __do_softirq+0xb0/0x1d0
 [<ffffffff8100c56c>] ? call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8100e595>] ? do_softirq+0x65/0xa0
 [<ffffffff81236b2e>] ? netif_rx_ni+0x1e/0x30
 [<ffffffffa014e97a>] ? tun_chr_aio_write+0x35a/0x510 [tun]
 [<ffffffffa014e620>] ? tun_chr_aio_write+0x0/0x510 [tun]
 [<ffffffff810ffea4>] ? do_sync_readv_writev+0xd4/0x110
 [<ffffffff8106e890>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff81071709>] ? enqueue_hrtimer+0x79/0xc0
 [<ffffffff810ffd08>] ? rw_copy_check_uvector+0x88/0x110
 [<ffffffff811005bc>] ? do_readv_writev+0xdc/0x220
 [<ffffffff8106dafc>] ? sys_timer_settime+0x13c/0x2e0
 [<ffffffff8110084e>] ? sys_writev+0x4e/0x90
 [<ffffffff8100b482>] ? system_call_fastpath+0x16/0x1b
Rebooting in 60 seconds..


Another:

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
PGD 10c804067 PUD 212d0e067 PMD 0
Oops: 0010 [#1] SMP
last sysfs file: /sys/devices/virtual/vc/vcsa2/dev
CPU 0
Modules linked in: netconsole configfs squashfs kvm_amd kvm veth autofs4 bridge quota_v2 quota_tree ext4 jbd2 crc16 raid0 raid456 async_pq async_xor xor async_memcpy async_raid6_recov raid6_pq async_tx loop sr_mod cdrom tun powernow_k8 processor thermal_sys 8021q garp stp llc asus_atk0110 hwmon atl1 mii ext3 jbd mbcache raid1 md_mod pata_atiixp ehci_hcd ohci_hcd usbcore nls_base [<ffffffff8100bff3>] ? apic_timer_interrupt+0x13/0x20
 [<ffffffff8100fced>] ? oops_end+0x9d/0xb0
 [<ffffffff810320b7>] ? no_context+0xf7/0x260
 [<ffffffff81032375>] ? __bad_area_nosemaphore+0x155/0x230
 [<ffffffffa0273ea0>] ? br_nf_pre_routing_finish+0x0/0x350 [bridge]
 [<ffffffffa0274759>] ? br_nf_pre_routing+0x569/0x880 [bridge]
 [<ffffffff812cc945>] ? page_fault+0x25/0x30
 [<ffffffff812650a0>] ? ip_rcv+0x0/0x350
 [<ffffffff81264c60>] ? ip_rcv_finish+0x0/0x440
 [<ffffffff81264e19>] ? ip_rcv_finish+0x1b9/0x440
 [<ffffffff81265354>] ? ip_rcv+0x2b4/0x350
 [<ffffffff8123ba85>] ? process_backlog+0x75/0xc0
 [<ffffffff8123c246>] ? net_rx_action+0x106/0x220
 [<ffffffff8105abcb>] ? __do_softirq+0xfb/0x1d0
 [<ffffffff8100c62c>] ? call_softirq+0x1c/0x30
 <EOI>  [<ffffffff8100e765>] ? do_softirq+0x65/0xa0
 [<ffffffff8123c379>] ? netif_rx_ni+0x19/0x20
 [<ffffffffa0151b0b>] ? tun_chr_aio_write+0x3fb/0x550 [tun]
 [<ffffffffa0151710>] ? tun_chr_aio_write+0x0/0x550 [tun]
 [<ffffffff811031fb>] ? do_sync_readv_writev+0xcb/0x110
 [<ffffffff81065941>] ? __dequeue_signal+0xe1/0x210
 [<ffffffff810706b0>] ? autoremove_wake_function+0x0/0x30
 [<ffffffff81012bc2>] ? read_tsc+0x12/0x40
 [<ffffffff81024608>] ? lapic_next_event+0x18/0x20
 [<ffffffff8107d156>] ? tick_dev_program_event+0x36/0xb0
 [<ffffffff81103036>] ? rw_copy_check_uvector+0x86/0x130
 [<ffffffff81103912>] ? do_readv_writev+0xe2/0x230
 [<ffffffff8106f883>] ? sys_timer_settime+0x153/0x350
 [<ffffffff81103bb3>] ? sys_writev+0x53/0xa0
 [<ffffffff8100b542>] ? system_call_fastpath+0x16/0x1b
Rebooting in 60 seconds..

I looked at the changes in tun, virtio-net, bridge code and
veth between 2.6.32 and 2.6.35, but I see nothing relevant
in there (but I'm not an expert in that area anyway). The
changes mentions a few crashes, but all were related to
device registration/deregistration or module unload, not
to normal send/receive path.

It will be really nice to fix this for long-stable 2.6.32
series... ;)

Thanks!

/mjt
