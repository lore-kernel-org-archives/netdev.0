From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [RFC PATCH 0/5] netlink: mmap kernel panic and some issues
Date: Wed, 22 Jul 2015 22:17:30 +0900
Message-ID: <20150722131730.GA18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32856 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932905AbbGVNRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:17:36 -0400
Received: by padck2 with SMTP id ck2so138006327pad.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:17:35 -0700 (PDT)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id ml10sm3406383pab.47.2015.07.22.06.17.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:17:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello,

I got a kernel panic below when I dumped using mmaped netlink socket
while monitoring it by nlmon tap device. I realized it is because
mmaped netlink skb does not have skb_shared_info but don't know how
to fix it in sane. This patch series seems to work fine for me but
I'm not sure it's right or not.

Patch 1/5 added helper functions for mmaped netlink skb and applied
these at 2/5. I'm not sure I embed helper functions like this or add
skb functions and wrap it like alloc_skb_head() in
netlink_alloc_skb(). Patch 3/5 fixes nm_state for skb which is
allocated but not sent.

I noticed I can not send netlink message by using mmaped netlink
socket since:

    commit: a8866ff6a5bce7d0ec465a63bc482a85c09b0d39
    netlink: make the check for "send from tx_ring" deterministic

I found a msg->msg_iter.type was set to 1 (WRITE). It seems that we
need to accept it but reject KERNEL_DS. Patch 4/5 may fix it.

Talking about Patch 5/5, I receive many notifications which frame
status is NL_MMAP_STATUS_RESERVED from mmaped nflog poll() when I
specified QTHRESH or TIMEOUT nflog config option. This behavior
seems to be different from normal socket. And I don't need to be
notified that there is a frame I'm processing - SKIP in the ring
too.

It would be appreciate if someone consolidate patches or tell me how
to fix it.

Thanks,

[  196.691844] Netfilter messages via NETLINK v0.30.
[  196.742847] nf_conntrack version 0.5.0 (2943 buckets, 11772 max)
[  196.787119] ctnetlink v0.93: registering with nfnetlink.
[  211.177865] device eth1 entered promiscuous mode
[  211.314466] bridge: automatic filtering via arp/ip/ip6tables has been deprecated. Update your scripts to load br_netfilter if you need this.
[  211.319998] br0: port 1(eth1) entered forwarding state
[  211.320419] br0: port 1(eth1) entered forwarding state
[  211.466591] Ebtables v2.0 registered
[  226.336171] br0: port 1(eth1) entered forwarding state
[  300.957103] BUG: unable to handle kernel NULL pointer dereference at 0000000000000002
[  300.958740] IP: [<ffffffff81482b48>] kfree_skb_list+0x18/0x30
[  300.959814] PGD 177ae067 PUD 177c6067 PMD 0 
[  300.960958] Oops: 0000 [#1] SMP 
[  300.960958] Modules linked in: nlmon nf_conntrack_ipv4 nf_defrag_ipv4 ebt_redirect ebtable_broute ebtables x_tables bridge stp llc dummy nf_conntrack_netlink nf_conntrack nfnetlink netconsole binfmt_misc ttm drm_kms_helper drm ppdev snd_pcm snd_timer parport_pc snd parport soundcore acpi_cpufreq psmouse pcspkr i2c_piix4 evdev i2c_core processor button thermal_sys serio_raw configfs loop autofs4 ext4 crc16 mbcache jbd2 sg sr_mod cdrom ata_generic virtio_blk virtio_net ata_piix virtio_pci virtio_ring virtio libata scsi_mod floppy [last unloaded: netconsole]
[  300.960958] CPU: 0 PID: 890 Comm: ulogd Not tainted 4.1.1 #3
[  300.960958] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[  300.960958] task: ffff8800129963d0 ti: ffff880017254000 task.ti: ffff880017254000
[  300.960958] RIP: 0010:[<ffffffff81482b48>]  [<ffffffff81482b48>] kfree_skb_list+0x18/0x30
[  300.960958] RSP: 0018:ffff8800172577e8  EFLAGS: 00010202
[  300.960958] RAX: 0000000000000000 RBX: ffff88001513c000 RCX: 000000005fb50000
[  300.960958] RDX: 00000000ffffffff RSI: ffff88000012e000 RDI: 0000000000000002
[  300.960958] RBP: ffff8800172577f8 R08: 0000000000000020 R09: 0000000000000578
[  300.960958] R10: ffffffff818c4cc0 R11: 0000000000000000 R12: ffff88001747d800
[  300.960958] R13: 0000000000000000 R14: 0000000000001000 R15: ffff8800157ed400
[  300.960958] FS:  00007f92e6dc1700(0000) GS:ffff880017c00000(0000) knlGS:0000000000000000
[  300.960958] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  300.960958] CR2: 0000000000000002 CR3: 0000000015100000 CR4: 00000000000006f0
[  300.960958] Stack:
[  300.960958]  ffff880017666600 ffff88001513c000 ffff880017257828 ffffffff81482be5
[  300.960958]  ffff880017257828 ffff88001747d800 0000000000000000 ffff88000012e000
[  300.960958]  ffff880017257848 ffffffff81482cc6 ffff88001747d800 ffff88001747d800
[  300.960958] Call Trace:
[  300.960958]  [<ffffffff81482be5>] ? skb_release_data+0x85/0xd0
[  300.960958]  [<ffffffff81482cc6>] ? __kfree_skb+0x16/0x90
[  300.960958]  [<ffffffffa033b16c>] ? nlmon_xmit+0x2c/0x30 [nlmon]
[  300.960958]  [<ffffffff81494043>] ? dev_hard_start_xmit+0x233/0x3e0
[  300.960958]  [<ffffffff8149442e>] ? netif_skb_features+0xfe/0x200
[  300.960958]  [<ffffffff81494770>] ? validate_xmit_skb+0x40/0x330
[  300.960958]  [<ffffffff81494f59>] ? __dev_queue_xmit+0x489/0x590
[  300.960958]  [<ffffffff814c2e26>] ? netlink_deliver_tap+0xe6/0x170
[  300.960958]  [<ffffffff814c2eeb>] ? __netlink_sendskb+0x3b/0x240
[  300.960958]  [<ffffffff814c57c6>] ? netlink_dump+0x1c6/0x2d0
[  300.960958]  [<ffffffff814c769a>] ? __netlink_dump_start+0x19a/0x1d0
[  300.960958]  [<ffffffffa02f4d20>] ? ctnetlink_get_conntrack+0xc0/0x25c [nf_conntrack_netlink]
[  300.960958]  [<ffffffffa02f2b20>] ? ctnetlink_dump_dying+0x20/0x20 [nf_conntrack_netlink]
[  300.960958]  [<ffffffffa02f0a40>] ? ctnetlink_nfqueue_attach_expect+0x170/0x170 [nf_conntrack_netlink]
[  300.960958]  [<ffffffff8131a15e>] ? __nla_reserve+0x4e/0x70
[  300.960958]  [<ffffffff8131a15e>] ? __nla_reserve+0x4e/0x70
[  300.960958]  [<ffffffffa02f4c60>] ? ctnetlink_nfqueue_parse+0x2e0/0x2e0 [nf_conntrack_netlink]
[  300.960958]  [<ffffffffa0056b7b>] ? nfnetlink_rcv_msg+0x28b/0x2a0 [nfnetlink]
[  300.960958]  [<ffffffff81494770>] ? validate_xmit_skb+0x40/0x330
[  300.960958]  [<ffffffffa00568f0>] ? nfnetlink_rcv+0xe0/0xe0 [nfnetlink]
[  300.960958]  [<ffffffff814c65d9>] ? netlink_rcv_skb+0xa9/0xd0
[  300.960958]  [<ffffffff814c6266>] ? netlink_unicast+0x126/0x1c0
[  300.960958]  [<ffffffff814c6ea6>] ? netlink_sendmsg+0x556/0x660
[  300.960958]  [<ffffffff8147770d>] ? sock_sendmsg+0x4d/0x60
[  300.960958]  [<ffffffff814791b4>] ? SYSC_sendto+0x104/0x180
[  300.960958]  [<ffffffff811d7eb9>] ? vfs_read+0xa9/0xe0
[  300.960958]  [<ffffffff811d87fc>] ? SyS_read+0x9c/0xd0
[  300.960958]  [<ffffffff81596bae>] ? system_call_fastpath+0x12/0x71
[  300.960958] Code: 48 83 c4 08 5b c9 c3 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53 48 83 ec 08 0f 1f 44 00 00 48 85 ff 74 15 0f 1f 44 00 00 <48> 8b 1f e8 f0 fc ff ff 48 85 db 48 89 df 75 f0 48 83 c4 08 5b 
[  300.960958] RIP  [<ffffffff81482b48>] kfree_skb_list+0x18/0x30
[  300.960958]  RSP <ffff8800172577e8>
[  300.960958] CR2: 0000000000000002
[  300.960958] ---[ end trace fa655a8b26512358 ]---
[  300.960958] Kernel panic - not syncing: Fatal exception in interrupt
[  300.960958] Kernel Offset: disabled
[  300.960958] ---[ end Kernel panic - not syncing: Fatal exception in interrupt

----- End forwarded message -----
