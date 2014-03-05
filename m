From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 2/2] 6lowpan: reassembly: fix kernel oops while unloading
Date: Wed,  5 Mar 2014 21:43:31 +0100
Message-ID: <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:63557 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757021AbaCEUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 15:44:37 -0500
Received: by mail-ea0-f169.google.com with SMTP id h14so1303885eaj.0
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 12:44:36 -0800 (PST)
In-Reply-To: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While fragmentation and unloading of 6lowpan module I got this kernel Oops
after few seconds:

BUG: unable to handle kernel paging request at f88bbc30
IP: [<f88bbc30>] 0xf88bbc30
*pde = 371ee067 *pte = 00000000
Oops: 0000 [#1] SMP
Modules linked in: ipv6 [last unloaded: 6lowpan]
CPU: 0 PID: 0 Comm: swapper/0 Not tainted
3.14.0-rc3-00831-g1f8ca2c-dirty #114
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
task: c0540870 ti: f700c000 task.ti: c0536000
EIP: 0060:[<f88bbc30>] EFLAGS: 00210286 CPU: 0
EIP is at 0xf88bbc30
EAX: f7096080 EBX: 00000100 ECX: 00000000 EDX: 00000000
ESI: f88bbc30 EDI: f700df8c EBP: f700df98 ESP: f700df60
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
CR0: 8005003b CR2: f88bbc30 CR3: 372cf000 CR4: 00000690
Stack:
 c012af4c 00000000 00000002 00000000 c012aef8 f7096080 f88bbc30 c0ac181c
 c0828200 00000000 c050ca53 c05d6340 f70960a0 f7096080 f700dfc4 c012b66b
 c05d6d70 c05d6b70 f700dfb0 f88bbc30 f71dadf8 f71dadf8 00000002 c053a204
Call Trace:
 [<c012af4c>] ? call_timer_fn+0x54/0xb3
 [<c012aef8>] ? process_timeout+0xa/0xa
 [<c012b66b>] run_timer_softirq+0x140/0x15f
 [<c0126ec1>] __do_softirq+0xd5/0x1bc
 [<c0126dec>] ? tasklet_hi_action+0xa8/0xa8
 <IRQ>
 [<c012714a>] ? irq_exit+0x39/0x82
 [<c0119ef1>] ? smp_apic_timer_interrupt+0x25/0x2f
 [<c03e7e1f>] ? apic_timer_interrupt+0x2f/0x40
 [<c014007b>] ? wake_up_new_task+0x5a/0x85
 [<c010743c>] ? default_idle+0xa/0xc
 [<c01078d8>] ? arch_cpu_idle+0x12/0x1c
 [<c0152afc>] ? cpu_startup_entry+0xb2/0x114
 [<c03ddd74>] ? rest_init+0x92/0x97
 [<c05728d5>] ? start_kernel+0x2b7/0x2bc
 [<c05722af>] ? i386_start_kernel+0x79/0x7d

It seems that the inet_frag_queue is deleted but the timer is running. This
patch adds a for loop to iterate over all frag_queue entries in the
frag_bucket and calling del_timer for each frag_queue entry while
unloading the 6lowpan module.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reported-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
I am not sure about that I can do that in this simply way without hold
any lock of the inet_frag_queue or inet_frag_bucket. Please help there.
The kernel oops never occurs afterwards, but this isn't simple to test.
I can't test all cases.

 net/ieee802154/reassembly.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index 59db7b5..833b6ad 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -560,6 +560,18 @@ out:
 
 void lowpan_net_frag_exit(void)
 {
+	int i;
+
+	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
+		struct inet_frag_bucket *hb;
+		struct inet_frag_queue *q;
+		struct hlist_node *n;
+
+		hb = &lowpan_frags.hash[i];
+		hlist_for_each_entry_safe(q, n, &hb->chain, list)
+			del_timer(&q->timer);
+	}
+
 	inet_frags_fini(&lowpan_frags);
 	lowpan_frags_sysctl_unregister();
 	unregister_pernet_subsys(&lowpan_frags_ops);
-- 
1.9.0
