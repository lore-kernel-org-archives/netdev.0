From: Roland Dreier <rdreier@cisco.com>
Subject: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 15:44:57 -0700
Message-ID: <adaeisq23rq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:3294 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758661AbZGHWpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 18:45:12 -0400
Received: from sj-core-4.cisco.com (sj-core-4.cisco.com [171.68.223.138])
	by sj-dkim-1.cisco.com (8.12.11/8.12.11) with ESMTP id n68MjCJo030462
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 15:45:12 -0700
Received: from xbh-sjc-231.amer.cisco.com (xbh-sjc-231.cisco.com [128.107.191.100])
	by sj-core-4.cisco.com (8.13.8/8.14.3) with ESMTP id n68MjA2K026284
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 22:45:12 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got the following BUG() from 2.6.31-rc2+git (up to commit e3288775)
while transferring a huge file via rsync.  The networking setup on this
system is rather complicated: I have two two-port NICs installed, one
driven by cxgb3 (eth2/eth3) and one by iw_nes (eth4/eth5), and I have
one port of each NIC (eth3 and eth5) as well as the on-board forcedeth
LAN (eth0) attached to a bridge.

I then have the forcedeth LAN port eth0 cabled to a real 1 Gb switch
port, and I have a cable from the non-bridge eth4 port of the iw_nes NIC
to the bridge port eth3 of the cxgb3 NIC, and I have the system's real
IP address configured on that eth4 non-bridge interface of the iw_nes
NIC.

(The reason for this crazy setup is that it lets me do tcpdump on the
bridge to grab all traffic from the iw_nes NIC as it appears on the
wire; this avoids any possibility of munging of packets seen by doing
tcpdump on the eth4 interface before they are actually put on the wire)

The BUG is at:

static inline struct kmem_cache *page_get_cache(struct page *page)
{
	page = compound_head(page);
512 =>	BUG_ON(!PageSlab(page));
	return (struct kmem_cache *)page->lru.next;
}

so I guess cxgb3 is passing garbage to free_skb() somehow.

I'm continuing to debug and see when this appeared and possibly bisect
where it was introduced, although it is slow going because it takes a
while before the bug actually triggers (I've seen 100s of MB transferred
before hitting the crash).

anyway any ideas are welcome.


------------[ cut here ]------------
kernel BUG at /scratch/Ksrc/linux-git/mm/slab.c:521!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/module/nfsd/initstate
CPU 7
Modules linked in: kvm_amd kvm nfsd exportfs nfs lockd nfs_acl auth_rpcgss bridge stp llc sg sr_mod iw_cxgb3 svcrdma rdma_cm ib_cm iw_cm ib_sa ib_mad ib_addr ipv6 sunrpc loop ide_cd_mod cdrom ide_pci_generic usbhid hid usb_storage iw_nes cxgb3 amd74xx ide_core evdev ehci_hcd amd64_edac_mod edac_core ib_core mlx4_core mdio forcedeth ata_generic floppy thermal button processor
Pid: 0, comm: swapper Not tainted 2.6.31-rc2 #3 H8DMU
RIP: 0010:[<ffffffff810d7097>]  [<ffffffff810d7097>] kfree+0x8e/0x271
RSP: 0018:ffffc90000e03930  EFLAGS: 00010046
RAX: ffffea00077fc8f8 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffffea0000000000 RSI: ffff8802248bb000 RDI: ffff880224829000
RBP: ffffc90000e03980 R08: ffff88012692eb70 R09: ffff880227b41ad8
R10: 0000000000000002 R11: ffffffffa00efcd0 R12: ffffffff812eea6d
R13: ffffffffa00e781e R14: ffff88012692eb70 R15: ffff880224829000
FS:  00007f2e4291f710(0000) GS:ffffc90000e00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f2e3fabb000 CR3: 000000021f88e000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff880227b96000, task ffff880127b177b0)
Stack:
 ffff880127c1d2c0 0000000000000286 ffffc90000e039a0 0000000000000286
<0> ffff8801420b4000 0000000000000000 ffff880223dcd7c0 ffffffffa00e781e
<0> ffff88012692eb70 0000000000000003 ffffc90000e039a0 ffffffff812eea6d
Call Trace:
 <IRQ>
 [<ffffffffa00e781e>] ? free_tx_desc+0x215/0x255 [cxgb3]
 [<ffffffff812eea6d>] skb_release_data+0xcb/0xd0
 [<ffffffff812ee73d>] __kfree_skb+0x1e/0x8b
 [<ffffffff812ee846>] kfree_skb+0x6a/0x72
 [<ffffffffa00e781e>] free_tx_desc+0x215/0x255 [cxgb3]
 [<ffffffffa00eb947>] t3_eth_xmit+0xb2/0x7c8 [cxgb3]
 [<ffffffff8103a956>] ? try_to_wake_up+0x205/0x217
 [<ffffffff8103a968>] ? default_wake_function+0x0/0x14
 [<ffffffff81031bc8>] ? __wake_up_sync_key+0x53/0x60
 [<ffffffff812ea71d>] ? sock_def_readable+0x44/0x71
 [<ffffffff813247b9>] ? tcp_rcv_established+0x627/0x943
 [<ffffffff812f6b4c>] dev_hard_start_xmit+0x21b/0x2c7
 [<ffffffff81307f62>] __qdisc_run+0xef/0x1fb
 [<ffffffff812f6f39>] dev_queue_xmit+0x22a/0x32a
 [<ffffffffa026fe67>] br_dev_queue_push_xmit+0x64/0x6a [bridge]
 [<ffffffffa026fedd>] __br_forward+0x60/0x64 [bridge]
 [<ffffffffa026feff>] br_forward+0x1e/0x2a [bridge]
 [<ffffffffa02709c8>] br_handle_frame_finish+0xf4/0x116 [bridge]
 [<ffffffffa0270b59>] br_handle_frame+0x16f/0x18a [bridge]
 [<ffffffff812f5b28>] netif_receive_skb+0x291/0x364
 [<ffffffff812f5c8b>] process_backlog+0x90/0xc7
 [<ffffffffa003fdaf>] ? nv_alloc_rx_optimized+0x119/0x21f [forcedeth]
 [<ffffffff812f6302>] net_rx_action+0xbc/0x1dd
 [<ffffffffa004267e>] ? nv_nic_irq_optimized+0xf4/0x279 [forcedeth]
 [<ffffffff810453f2>] __do_softirq+0xe0/0x1b8
 [<ffffffff8100cd8c>] call_softirq+0x1c/0x28
 [<ffffffff8100e862>] do_softirq+0x3e/0x8f
 [<ffffffff81044e23>] irq_exit+0x53/0x8d
 [<ffffffff81369720>] do_IRQ+0xa8/0xbf
 [<ffffffff8100c5d3>] ret_from_intr+0x0/0xf
 <EOI>
 [<ffffffff810130f9>] ? default_idle+0x6e/0xb7
 [<ffffffff810130f7>] ? default_idle+0x6c/0xb7
 [<ffffffff810133b1>] ? c1e_idle+0xfa/0x101
 [<ffffffff8100ae04>] ? cpu_idle+0x61/0xaa
 [<ffffffff813631a0>] ? start_secondary+0x1a4/0x1a8
Code: 0c 48 ba 00 00 00 00 00 ea ff ff 48 6b c0 38 48 01 d0 66 83 38 00 79 04 48 8b 40 10 66 83 38 00 79 04 48 8b 40 10 80 38 00 78 04 <0f> 0b eb fe 4c 8b 70 28 65 8b 04 25 d0 dd 00 00 83 3d da fa 44
RIP  [<ffffffff810d7097>] kfree+0x8e/0x271
 RSP <ffffc90000e03930>
---[ end trace bde922e5a179ae1a ]---
