From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH] net: sched: tbf: fix an oops when a GSO packet cannot be enqueued
Date: Fri, 22 Nov 2013 17:27:26 +0800
Message-ID: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <ben@decadent.org.uk>,
	<jpirko@redhat.com>, <jhs@mojatatu.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:45805 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab3KVJ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 04:27:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems commit e43ac79a4b("sch_tbf: segment too big GSO packets")
introduce this oops.

When GSO mode is on, use the following command:
tc qdisc add dev eth0 root handle 1: tbf latency 50ms burst 1KB rate 50mbit mtu 1KB
iperf -c host -t 30

Oops happened:

[16884.119862] BUG: unable to handle kernel NULL pointer dereference at 00000000000000c8
[16884.212742] IP: [<ffffffff813dd3e1>] tcp_gso_segment+0x251/0x3a0
[16884.283951] PGD 1f14258067 PUD 1f34e7e067 PMD 0
[16884.338656] Oops: 0000 [#1] SMP
[16884.376851] Modules linked in: sch_tbf(O) tun ip6table_filter ip6_tables iptable_filter ip_tables x_tables edd af_packet bridge stp llc microcode fuse loop dm_mod igb dca i2c_algo_bit ptp ipv6 kvm_intel kvm i2c_i801 sg i2c_core pps_core ehci_pci mptctl pcspkr button iTCO_wdt iTCO_vendor_support lpc_ich mfd_core hid_generic serio_raw ext3 jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore usb_common sd_mod crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh_rdac scsi_dh ata_generic ata_piix libata mptsas mptscsih mptbase scsi_transport_sas scsi_mod [last unloaded: sch_tbf]
[16885.029346] CPU: 15 PID: 546 Comm: iperf Tainted: G           O 3.12.0-rc6-0.7-default+ #7
[16885.127372] Hardware name: Huawei Technologies Co., Ltd. Tecal XH620           /BC21THSA              , BIOS TTSAV020 12/02/2011
[16885.264597] task: ffff881fa8940240 ti: ffff881fbd64e000 task.ti: ffff881fbd64e000
[16885.353331] RIP: 0010:[<ffffffff813dd3e1>]  [<ffffffff813dd3e1>] tcp_gso_segment+0x251/0x3a0
[16885.453424] RSP: 0018:ffff881fbd64f738  EFLAGS: 00010286
[16885.516364] RAX: 000000000ea96820 RBX: 0000000000000000 RCX: 0000000020368706
[16885.600973] RDX: 000000001b1b0000 RSI: 00000000000002c0 RDI: ffff881fa8bfbb70
[16885.685584] RBP: ffff881fbd64f778 R08: 000000000000e93f R09: ffff881fbcaac400
[16885.770191] R10: 0000000000000004 R11: ffff881fbc93e840 R12: ffff881fbcaac510
[16885.854799] R13: ffff881fa8bfbb70 R14: 00000000000005a8 R15: ffff881fa8bfbd70
[16885.939409] FS:  00007f255987e700(0000) GS:ffff88203f3e0000(0000) knlGS:0000000000000000
[16886.035364] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[16886.103466] CR2: 00000000000000c8 CR3: 0000001f13c07000 CR4: 00000000000027e0
[16886.188075] Stack:
[16886.211809]  ffff881fbd64f788 00000020813dd2d5 2068a90e0164230a 0000000000000006
[16886.299540]  ffff881fa8bfbb70 ffff881fa8bfbb98 0000000000000014 0000000390004bb3
[16886.387268]  ffff881fbd64f7d8 ffffffff813ed38d 06ff881fbd64f7e8 0000000000000046
[16886.475000] Call Trace:
[16886.503900]  [<ffffffff813ed38d>] inet_gso_segment+0x14d/0x310
[16886.573036]  [<ffffffff8107093b>] ? try_to_wake_up+0x1eb/0x290
[16886.642187]  [<ffffffff81382c4d>] skb_mac_gso_segment+0xad/0x170
[16886.713392]  [<ffffffff81382d79>] __skb_gso_segment+0x69/0xe0
[16886.781499]  [<ffffffffa0038763>] tbf_enqueue+0x63/0x1e0 [sch_tbf]
[16886.854765]  [<ffffffff81383466>] dev_queue_xmit+0x186/0x440
[16886.921844]  [<ffffffffa08a13d0>] ? br_forward+0x60/0x60 [bridge]
[16886.994078]  [<ffffffffa08a145b>] br_dev_queue_push_xmit+0x8b/0xd0 [bridge]
[16887.076622]  [<ffffffffa08a14f8>] br_forward_finish+0x58/0x60 [bridge]
[16887.154010]  [<ffffffffa08a1578>] __br_deliver+0x78/0x100 [bridge]
[16887.227275]  [<ffffffffa08a163d>] br_deliver+0x3d/0x50 [bridge]
[16887.297439]  [<ffffffffa089f8ae>] br_dev_xmit+0xce/0x230 [bridge]
[16887.369668]  [<ffffffff813830bf>] dev_hard_start_xmit+0x2cf/0x4f0
[16887.441901]  [<ffffffff81383697>] dev_queue_xmit+0x3b7/0x440
[16887.508970]  [<ffffffff8138c4e1>] neigh_resolve_output+0x131/0x200
[16887.582230]  [<ffffffff813bb31d>] ip_finish_output+0x23d/0x440
[16887.651368]  [<ffffffff813bb5a8>] ip_output+0x88/0x90
[16887.711219]  [<ffffffff813b9f34>] ip_local_out+0x24/0x30
[16887.774168]  [<ffffffff813ba3dd>] ip_queue_xmit+0x14d/0x3e0
[16887.840208]  [<ffffffff813d1661>] tcp_transmit_skb+0x501/0x840
[16887.909346]  [<ffffffff813d29b3>] tcp_write_xmit+0x1e3/0xb20
[16887.976415]  [<ffffffff813d335d>] __tcp_push_pending_frames+0x2d/0x70
[16888.052770]  [<ffffffff813c6034>] tcp_sendmsg+0xc74/0xc90
[16888.116751]  [<ffffffff813ec3f1>] inet_sendmsg+0x61/0xc0
[16888.179702]  [<ffffffff81368981>] sock_aio_write+0x101/0x120
[16888.246776]  [<ffffffff8121d530>] ? timerqueue_add+0x60/0xb0
[16888.313851]  [<ffffffff81134720>] do_sync_write+0x60/0x90
[16888.377827]  [<ffffffff81134904>] ? rw_verify_area+0x54/0xf0
[16888.444897]  [<ffffffff81134b26>] vfs_write+0x186/0x190
[16888.506808]  [<ffffffff811353bd>] SyS_write+0x5d/0xa0
[16888.566657]  [<ffffffff8143e0e2>] system_call_fastpath+0x16/0x1b
[16888.637857] Code: 8b 85 80 00 00 00 48 89 83 80 00 00 00 49 8b 45 18 44 89 b3 e8 00 00 00 48 89 43 18 45 29 b5 e8 00 00 00 48 8b 1b 8b 45 d4 0f c8 <44> 0f b7 a3 c8 00 00 00 4c 03 a3 d8 00 00 00 41 89 44 24 04 41
[16888.862165] RIP  [<ffffffff813dd3e1>] tcp_gso_segment+0x251/0x3a0
-----------------------cut here--------------------------------------------

If max_size is too small, a GSO segment cannot be enqueued,
we need to free the segment.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_tbf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 68f9859..f246589 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -140,7 +140,7 @@ static int tbf_segment(struct sk_buff *skb, struct Qdisc *sch)
 			qdisc_skb_cb(segs)->pkt_len = segs->len;
 			ret = qdisc_enqueue(segs, q->qdisc);
 		} else {
-			ret = qdisc_reshape_fail(skb, sch);
+			ret = qdisc_reshape_fail(segs, q->qdisc);
 		}
 		if (ret != NET_XMIT_SUCCESS) {
 			if (net_xmit_drop_count(ret))
-- 
1.7.12
