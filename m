From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 1/2] pkt_sched: Fix sch_sfq vs tc_modify_qdisc oops
Date: Wed, 11 Aug 2010 08:31:02 +0000
Message-ID: <20100811083101.GA10126@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Franchoze Eric <franchoze@yandex.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49993 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab0HKIbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 04:31:10 -0400
Received: by bwz3 with SMTP id 3so2464316bwz.19
        for <netdev@vger.kernel.org>; Wed, 11 Aug 2010 01:31:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
After more investigation I've found sch_sfq is still vulnerable
because off its missing class handlers. Here is an oops as
proof of the concept, and a patch below. This patch should be
considered for stable (without following 2/2 patch).

Jarek P.

This oops can happen while doing tc qdisc replace on sfq
leaf qdiscs under some traffic.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<(null)>] (null)
*pde = 00000000 
Oops: 0000 [#1] SMP 
last sysfs file: /sys/module/sch_htb/refcnt
Modules linked in: sch_htb sch_sfq sch_prio snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss ipv6 ext3 jbd mbcache lp fuse ppdev snd_intel8x0 snd_ac97_codec ac97_bus rtc_cmos parport_pc uhci_hcd intel_agp snd_pcm e100 psmouse rtc_core mii i2c_i801 parport agpgart processor snd_timer thermal dcdbas serio_raw ehci_hcd rtc_lib shpchp thermal_sys button i2c_core evdev hwmon snd soundcore snd_page_alloc reiserfs [last unloaded: sch_htb]

Pid: 2925, comm: tc Not tainted (2.6.32-smp #1) OptiPlex 170L                
EIP: 0060:[<00000000>] EFLAGS: 00010286 CPU: 0
EIP is at 0x0
EAX: cdb52000 EBX: c44dbc98 ECX: d041fe20 EDX: 00000028
ESI: c44dbc98 EDI: cdb52080 EBP: cdb52000 ESP: c44dbc14
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process tc (pid: 2925, ti=c44da000 task=ce819500 task.ti=c44da000)
Stack:
 c12dfbe6 00000000 c44dbc98 00000028 cdb52080 cdb52000 c1353949 c44dbc98
<0> 00000028 d041f37a d041fdbd cdb52000 cf151410 cd8b7000 cf065800 c12e1dc1
<0> 00000000 00000000 cd9fd700 cf045000 cf151424 cf151400 cd9fd700 00010002
Call Trace:
 [<c12dfbe6>] ? check_loop_fn+0x16/0xa0
 [<c1353949>] ? printk+0x17/0x1e
 [<d041f37a>] ? sfq_walk+0x8a/0xb0 [sch_sfq]
 [<c12e1dc1>] ? tc_modify_qdisc+0x451/0x4f0
 [<c12dfbd0>] ? check_loop_fn+0x0/0xa0
 [<c12e1970>] ? tc_modify_qdisc+0x0/0x4f0
 [<c12d635d>] ? rtnetlink_rcv_msg+0x16d/0x210
 [<c12bf2d5>] ? sock_rmalloc+0x35/0x90
 [<c12d61f0>] ? rtnetlink_rcv_msg+0x0/0x210
 [<c12e7d26>] ? netlink_rcv_skb+0x66/0x90
 [<c12d61e9>] ? rtnetlink_rcv+0x19/0x20
 [<c12e79fe>] ? netlink_unicast+0x26e/0x280
 [<c12e81d5>] ? netlink_sendmsg+0x1d5/0x2f0
 [<c12bc401>] ? sock_sendmsg+0x111/0x130
 [<c104b560>] ? autoremove_wake_function+0x0/0x50
 [<c104b560>] ? autoremove_wake_function+0x0/0x50
 [<c12bc594>] ? sys_sendmsg+0x174/0x280
 [<c12bd4a6>] ? sys_recvmsg+0x1a6/0x240
 [<c10804f4>] ? find_get_page+0x24/0xb0
 [<c1080e34>] ? filemap_fault+0x74/0x3a0
 [<c1097371>] ? __do_fault+0x361/0x450
 [<c12bed30>] ? lock_sock_nested+0x90/0xb0
 [<c1098f94>] ? handle_mm_fault+0x144/0x800
 [<c12bdc0d>] ? sys_socketcall+0xbd/0x290
 [<c101d22a>] ? do_page_fault+0x13a/0x2a0
 [<c101d0f0>] ? do_page_fault+0x0/0x2a0
 [<c1002eb5>] ? syscall_call+0x7/0xb
Code:  Bad EIP value.
EIP: [<00000000>] 0x0 SS:ESP 0068:c44dbc14
CR2: 0000000000000000

------------>

sch_sfq as a classful qdisc needs the .leaf handler. Otherwise, there
is an oops possible in tc_modify_qdisc()/check_loop().

Fixes commit 7d2681a6ff4f9ab5e48d02550b4c6338f1638998

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index b8bcb20..201cbac 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -508,6 +508,11 @@ nla_put_failure:
 	return -1;
 }
 
+static struct Qdisc *sfq_leaf(struct Qdisc *sch, unsigned long arg)
+{
+	return NULL;
+}
+
 static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
 {
 	return 0;
@@ -575,6 +580,7 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 }
 
 static const struct Qdisc_class_ops sfq_class_ops = {
+	.leaf		=	sfq_leaf,
 	.get		=	sfq_get,
 	.put		=	sfq_put,
 	.tcf_chain	=	sfq_find_tcf,
