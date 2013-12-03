From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: fix a BUG_ON on triggered by setting max_autoclose
 to
Date: Tue, 3 Dec 2013 10:43:43 -0500
Message-ID: <20131203154343.GA3251@neilslaptop.think-freely.org>
References: <529DADE5.4040701@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44656 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754608Ab3LCPoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 10:44:13 -0500
Content-Disposition: inline
In-Reply-To: <529DADE5.4040701@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 03, 2013 at 06:09:41PM +0800, Wang Weidong wrote:
> since 2692ba61, add the max_autoclose to sysctl. when I setted the
> max_autoclose to 0. Just do the test_autoclose, it will trigger that:
> 
> [  608.056238] ------------[ cut here ]------------
> [  608.056244] kernel BUG at /home/wwd/work/linux/net/sctp/sm_sideeffect.c:1488!
> [  608.056250] invalid opcode: 0000 [#1] SMP
> [  608.056254] Modules linked in: md5 sctp(O) crc32c libcrc32c edd fuse loop dm_mod ipv6 8139too sg 8139cp mii i2c_piix4 i2c_core virtio_balloon intel_agp virtio_pci virtio_ring sr_mod cdrom rtc_cmos joydev hid_generic intel_gtt virtio floppy pcspkr button ext3 jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore sd_mod usb_common crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_emc scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh ata_generic ata_piix libata scsi_mod [last unloaded: sctp]
> [  608.056310] CPU: 5 PID: 4517 Comm: test_autoclose Tainted: G  R        O 3.13.0-rc1-0.27-default+ #2
> [  608.056315] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  608.056319] task: ffff8800372f5590 ti: ffff8800db882000 task.ti: ffff8800db882000
> [  608.056323] RIP: 0010:[<ffffffffa033e350>]  [<ffffffffa033e350>] sctp_cmd_interpreter+0x1010/0x1070 [sctp]
> [  608.056339] RSP: 0018:ffff880116f43928  EFLAGS: 00010246
> [  608.056343] RAX: 0000000000000009 RBX: ffff880116f43ab8 RCX: 0000000000000009
> [  608.056349] RDX: 0000000000000003 RSI: 0000000000000000 RDI: ffff880116f43a88
> [  608.056353] RBP: ffff880116f439d8 R08: 0000000000002029 R09: 0000000000000001
> [  608.056357] R10: 0000000000000000 R11: 0000000000000005 R12: ffff8800db7c9150
> [  608.056361] R13: 0000000000000000 R14: ffff8800db7c9000 R15: 0000000000000001
> [  608.056365] FS:  00007f942d71c700(0000) GS:ffff880116f40000(0000) knlGS:0000000000000000
> [  608.056370] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  608.056373] CR2: 00007f942d324d90 CR3: 00000000db094000 CR4: 00000000000006e0
> [  608.056382] Stack:
> [  608.056384]  0000000000000018 ffff880116f43988 ffff8800da569600 000000010000000a
> [  608.056391]  ffff880037265e40 0000000016f43988 ffff880116f439e8 0000000000000000
> [  608.056397]  ffffffffa0365101 0000000000000000 ffff880116f43a28 ffffffff812b7739
> [  608.056403] Call Trace:
> [  608.056406]  <IRQ>
> [  608.056409]
> [  608.056421]  [<ffffffff812b7739>] ? __dynamic_pr_debug+0x69/0x80
> [  608.056432]  [<ffffffff81097c6d>] ? trace_hardirqs_off+0xd/0x10
> [  608.056442]  [<ffffffff814e7258>] ? _raw_spin_unlock_irqrestore+0x58/0x60
> [  608.056451]  [<ffffffffa033e3e6>] sctp_side_effects+0x36/0x130 [sctp]
> [  608.056459]  [<ffffffffa033e5c7>] sctp_do_sm+0xe7/0x210 [sctp]
> [  608.056470]  [<ffffffffa0359860>] ? sctp_rcv+0x780/0x780 [sctp]
> [  608.056479]  [<ffffffffa0340a5f>] sctp_endpoint_bh_rcv+0x10f/0x220 [sctp]
> [  608.056489]  [<ffffffffa0349991>] sctp_inq_push+0x41/0x60 [sctp]
> [  608.056498]  [<ffffffffa03597b5>] sctp_rcv+0x6d5/0x780 [sctp]
> [  608.056508]  [<ffffffffa0358e00>] ? sctp_csum_combine+0x10/0x10 [sctp]
> [  608.056518]  [<ffffffffa0358df0>] ? sctp_v4_err+0x240/0x240 [sctp]
> [  608.056528]  [<ffffffff8145b8a4>] ip_local_deliver_finish+0xf4/0x270
> [  608.056533]  [<ffffffff8145b7f0>] ? ip_local_deliver_finish+0x40/0x270
> [  608.056538]  [<ffffffff8145b690>] ip_local_deliver+0x80/0x90
> [  608.056543]  [<ffffffff8145bbd3>] ip_rcv_finish+0x1b3/0x600
> [  608.056547]  [<ffffffff8145ba20>] ? ip_local_deliver_finish+0x270/0x270
> [  608.056552]  [<ffffffff8145b04f>] NF_HOOK+0x2f/0x70
> [  608.056565]  [<ffffffff81425853>] ? __netif_receive_skb_core+0x113/0x7a0
> [  608.056570]  [<ffffffff8145b365>] ip_rcv+0x2d5/0x3b0
> [  608.056575]  [<ffffffff81425e3f>] __netif_receive_skb_core+0x6ff/0x7a0
> [  608.056580]  [<ffffffff81425853>] ? __netif_receive_skb_core+0x113/0x7a0
> [  608.056585]  [<ffffffff81426108>] ? process_backlog+0x1a8/0x1c0
> [  608.056590]  [<ffffffff81425f0b>] __netif_receive_skb+0x2b/0x80
> [  608.056595]  [<ffffffff81426018>] process_backlog+0xb8/0x1c0
> [  608.056600]  [<ffffffff8142695c>] net_rx_action+0x11c/0x240
> [  608.056607]  [<ffffffff81050e18>] __do_softirq+0x118/0x290
> [  608.056615]  [<ffffffff814f0e0c>] do_softirq_own_stack+0x1c/0x30
> [  608.056618]  <EOI>
> [  608.056620]
> [  608.056623]  [<ffffffff81050bd5>] do_softirq+0x65/0x70
> [  608.056629]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
> [  608.056635]  [<ffffffff810518c3>] local_bh_enable_ip+0xb3/0xc0
> [  608.056640]  [<ffffffff814e71af>] _raw_spin_unlock_bh+0x2f/0x40
> [  608.056645]  [<ffffffff8140fddc>] release_sock+0x8c/0xa0
> [  608.056654]  [<ffffffffa0354c08>] sctp_sendmsg+0x3a8/0xcc0 [sctp]
> [  608.056661]  [<ffffffff8129924a>] ? number+0x33a/0x360
> [  608.056667]  [<ffffffff81497c3c>] inet_sendmsg+0x9c/0x100
> [  608.056672]  [<ffffffff81497ba0>] ? inet_recvmsg+0x110/0x110
> [  608.056679]  [<ffffffff8140a387>] sock_sendmsg+0x97/0xc0
> [  608.056690]  [<ffffffff8114caae>] ? might_fault+0x3e/0x90
> [  608.056695]  [<ffffffff8114caae>] ? might_fault+0x3e/0x90
> [  608.056700]  [<ffffffff81417a73>] ? verify_iovec+0x53/0x100
> [  608.056705]  [<ffffffff8140abb6>] ___sys_sendmsg+0x416/0x420
> [  608.056710]  [<ffffffff81151af6>] ? __do_fault+0x216/0x510
> [  608.056715]  [<ffffffff814eaf74>] ? __do_page_fault+0x2b4/0x4a0
> [  608.056720]  [<ffffffff81095c9e>] ? up_read+0x1e/0x40
> [  608.056724]  [<ffffffff814eaf74>] ? __do_page_fault+0x2b4/0x4a0
> [  608.056729]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
> [  608.056733]  [<ffffffff8140fddc>] ? release_sock+0x8c/0xa0
> [  608.056741]  [<ffffffff8109bb5d>] ? trace_hardirqs_on+0xd/0x10
> [  608.056746]  [<ffffffff81051875>] ? local_bh_enable_ip+0x65/0xc0
> [  608.056751]  [<ffffffff8140ad94>] __sys_sendmsg+0x44/0x80
> [  608.056756]  [<ffffffff8140ade4>] SyS_sendmsg+0x14/0x20
> [  608.056761]  [<ffffffff814ef5a2>] system_call_fastpath+0x16/0x1b
> -------------------------------------
> 
> The reason is: In test_autoclose set the autoclose to 5 not 0(default). So when
> we init the association, the (sctp_sock) sp->autoclose is not 0 while asoc's 
> timeouts[SCTP_EVENT_TIMEOUT_AUTOCLOSE] is 0. 
> So when we process the COOKIE_ACK, the sctp_sf_do_5_1E_ca will be called, that
> will do that:
> 	if (asoc->autoclose) //asoc->autoclose is equal sp->autoclose
> 		sctp_add_cmd_sf(commands, SCTP_CMD_TIMER_START,
> 				SCTP_TO(SCTP_EVENT_TIMEOUT_AUTOCLOSE));
> then the sctp_do_sm will goto the SCTP_CMD_TIMER_START where place a BUG_ON.
> So When we do test_autoclose will trigger the BUG_ON.
> And when the sp->autoclose is 0, it will not happen.
> 
> the timeout is zero only when the sp->autoclose is 0. While the sp->autoclose should
> consistent between setsockopt() and getsockopt() calls.
> so I make the max_autoclose min value to 1.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
