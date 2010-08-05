From: Franchoze Eric <franchoze@yandex.ru>
Subject: null pointer at cls_api.c
Date: Thu, 05 Aug 2010 23:24:15 +0400
Message-ID: <282881281036255@web101.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward9.mail.yandex.net ([77.88.61.48]:45089 "EHLO
	forward9.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab0HETYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 15:24:17 -0400
Received: from web101.yandex.ru (web101.yandex.ru [77.88.61.2])
	by forward9.mail.yandex.net (Yandex) with ESMTP id DC41014D838C
	for <netdev@vger.kernel.org>; Thu,  5 Aug 2010 23:24:15 +0400 (MSD)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by web101.yandex.ru (Yandex) with ESMTP id D8FA1250023
	for <netdev@vger.kernel.org>; Thu,  5 Aug 2010 23:24:15 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, can somebody follow up with approriate fix for that bug? It's reproducible on the latest 2.6.32.17 kernel with Centos5 user land.
Script to reproduce is bellow.  I did quick fix for that to show where is the issue.

Thanks.

--- net/sched/cls_api.c_orig	2010-08-05 10:46:01.000000000 -0700
+++ net/sched/cls_api.c	2010-08-05 12:03:01.000000000 -0700
@@ -255,6 +255,11 @@ replay:
 			kfree(tp);
 			goto errout;
 		}
+
+		if (!tp || !tp->ops) {
+			err = -ENOENT;
+			goto errout;
+		}
 		tp->ops = tp_ops;
 		tp->protocol = protocol;
 		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));


#!/bin/bash
DEV=tun1
SPEED="100kbit"
ISPEED="10Mbit"
tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 1: htb default 1
tc class add dev $DEV parent 1: classid 1:1 htb rate ${ISPEED}
tc class add dev $DEV parent 1:1 classid 1:2 htb rate ${SPEED} ceil ${SPEED} prio 0
tc qdisc add dev $DEV parent 1:2 handle 2: sfq perturb 10
tc filter add dev $DEV parent 2: protocol ip u32 match ip dport 80 0xffff flowid 2:1

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
PGD 81ca27067 PUD 825b8e067 PMD 0 
Oops: 0010 [#1] PREEMPT SMP 
last sysfs file: /sys/class/misc/watchdog/dev
CPU 7 
Modules linked in: wdt_pci sc520_wdt pcwd_pci i6300esb hpwdt cls_u32 sch_sfq sch_htb lockd sunrpc xt_connlimit xt_MARK iptable_mangle ipt_REDIRECT iptable_nat nf_nat tun ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables dm_mirror dm_multipath scsi_dh sbs sbshc power_meter hwmon battery ac tpm_tis serio_raw rtc_cmos rtc_core rtc_lib tpm tpm_bios button tg3 firmware_class libphy amd64_edac_mod edac_core i2c_piix4 i2c_core dm_region_hash dm_log dm_mod sata_svw libata cciss sd_mod scsi_mod ext3 jbd
Pid: 4807, comm: tc Not tainted 2.6.32.17-af #1 ProLiant DL165 G6
RIP: 0010:[<0000000000000000>]  [<(null)>] (null)
RSP: 0018:ffff880823547880  EFLAGS: 00010286
RAX: ffffffffa0292b80 RBX: ffff88082484f700 RCX: ffff880823547898
RDX: 0000000000020001 RSI: 0000000000000000 RDI: ffff88082568e000
RBP: ffff8808235478d8 R08: ffff880427c00040 R09: 0000000000000000
R10: 0000000000000000 R11: ffff88082484f7c0 R12: ffff88082546603c
R13: ffff88081ca8f440 R14: ffff88082484f7c0 R15: ffff880823547908
FS:  00007fb0ca8186e0(0000) GS:ffff880436440000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000008259ec000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process tc (pid: 4807, threadinfo ffff880823546000, task ffff880824b68800)
Stack:
 ffffffffa0299836 ffff8808235478c8 0000000000000000 0000000000000000
<0> ffff88081ca8f440 ffff88082546603c ffff88081ca8f440 ffff88082546603c
<0> 0000000080000800 ffff88082484f700 0000000000000000 ffff880823547998
Call Trace:
 [<ffffffffa0299836>] ? u32_set_parms+0xca/0x14f [cls_u32]
 [<ffffffffa0299e49>] u32_change+0x316/0x3bd [cls_u32]
 [<ffffffffa0299696>] ? kzalloc+0xf/0x11 [cls_u32]
 [<ffffffff8126f9e1>] tc_ctl_tfilter+0x505/0x5f6
 [<ffffffff810d4fbd>] ? ____cache_alloc+0x1d/0x223
 [<ffffffff81262377>] rtnetlink_rcv_msg+0x1c3/0x1e2
 [<ffffffff812621b4>] ? rtnetlink_rcv_msg+0x0/0x1e2
 [<ffffffff81273273>] netlink_rcv_skb+0x3e/0x8d
 [<ffffffff812620aa>] rtnetlink_rcv+0x20/0x29
 [<ffffffff812730e8>] netlink_unicast+0xed/0x154
 [<ffffffff8127464b>] netlink_sendmsg+0x245/0x258
 [<ffffffff812730f8>] ? netlink_unicast+0xfd/0x154
 [<ffffffff81248ffc>] __sock_sendmsg+0x59/0x62
 [<ffffffff8124988e>] sock_sendmsg+0xc7/0xe0
 [<ffffffff810604bb>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff810604bb>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff8124a345>] ? move_addr_to_kernel+0x40/0x49
 [<ffffffff8125254b>] ? verify_iovec+0x4f/0x94
 [<ffffffff81249a85>] sys_sendmsg+0x1de/0x24d
 [<ffffffff810ae914>] ? lru_cache_add_lru+0x38/0x3d
 [<ffffffff810c6468>] ? page_add_new_anon_rmap+0x3a/0x49
 [<ffffffff810bee8f>] ? handle_mm_fault+0x5e8/0x602
 [<ffffffff8100bb6b>] system_call_fastpath+0x16/0x1b
Code:  Bad RIP value.
RIP  [<(null)>] (null)
 RSP <ffff880823547880>
CR2: 0000000000000000
---[ end trace 62c007c0b888891e ]---
