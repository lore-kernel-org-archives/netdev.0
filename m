From: Dmitry Vyukov <dvyukov@google.com>
Subject: [RFC] net: fix data race on sk_buff after re-cloning
Date: Thu, 17 Sep 2015 20:44:16 +0200
Message-ID: <1442515456-12390-1-git-send-email-dvyukov@google.com>
Cc: andreyknvl@google.com, kcc@google.com, glider@google.com,
	paulmck@linux.vnet.ibm.com, hboehm@google.com,
	Dmitry Vyukov <dvyukov@google.com>
To: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@redhat.com, jiri@resnulli.us,
	hannes@stressinduktion.org, linus.luessing@c0d3.blue,
	willemb@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36381 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629AbbIQSoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 14:44:22 -0400
Received: by wicgb1 with SMTP id gb1so3000643wic.1
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 11:44:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

KernelThreadSanitizer (KTSAN) reported the following race (on 4.2 rc2):

ThreadSanitizer: data-race in __copy_skb_header

Write at 0xffff8800bb158f48 of size 8 by thread 3146 on CPU 5:
 [<ffffffff81b699fe>] __copy_skb_header+0xee/0x1d0 net/core/skbuff.c:765
 [<ffffffff81b69b3c>] __skb_clone+0x5c/0x320 net/core/skbuff.c:820
 [<ffffffff81b6c750>] skb_clone+0xd0/0x130 net/core/skbuff.c:962
 [<ffffffff81c4a295>] tcp_transmit_skb+0xb5/0x1750 net/ipv4/tcp_output.c:932
 [<ffffffff81c4f564>] __tcp_retransmit_skb+0x244/0xb10 net/ipv4/tcp_output.c:2638
 [<ffffffff81c501fb>] tcp_retransmit_skb+0x2b/0x240 net/ipv4/tcp_output.c:2655
 [<ffffffff81c53229>] tcp_retransmit_timer+0x579/0xb70 net/ipv4/tcp_timer.c:433
 [<ffffffff81c53929>] tcp_write_timer_handler+0x109/0x320 net/ipv4/tcp_timer.c:514
 [<ffffffff81c53c00>] tcp_write_timer+0xc0/0xe0 net/ipv4/tcp_timer.c:532
 [<ffffffff8110e74c>] call_timer_fn+0x4c/0x1b0 kernel/time/timer.c:1155
 [<     inline     >] __run_timers kernel/time/timer.c:1231
 [<ffffffff8110f433>] run_timer_softirq+0x313/0x500 kernel/time/timer.c:1414
 [<ffffffff81091c1e>] __do_softirq+0xbe/0x2f0 kernel/softirq.c:273
 [<ffffffff81ee4cca>] apic_timer_interrupt+0x8a/0xa0 arch/x86/entry/entry_64.S:790

Previous read at 0xffff8800bb158f48 of size 8 by thread 3168 on CPU 0:
 [<ffffffff81b693ab>] skb_release_head_state+0x4b/0x120 net/core/skbuff.c:640
 [<ffffffff81b6ac6d>] skb_release_all+0x1d/0x50 net/core/skbuff.c:657
 [<     inline     >] __kfree_skb net/core/skbuff.c:673
 [<ffffffff81b6af20>] consume_skb+0x60/0x100 net/core/skbuff.c:746
 [<ffffffff81b8a69d>] __dev_kfree_skb_any+0x4d/0x60 net/core/dev.c:2312
 [<     inline     >] dev_kfree_skb_any include/linux/netdevice.h:2933
 [<ffffffff8194a703>] e1000_unmap_and_free_tx_resource.isra.42+0xd3/0x120 drivers/net/ethernet/intel/e1000/e1000_main.c:1973
 [<     inline     >] e1000_clean_tx_irq drivers/net/ethernet/intel/e1000/e1000_main.c:3881
 [<ffffffff8194a99d>] e1000_clean+0x24d/0x11e0 drivers/net/ethernet/intel/e1000/e1000_main.c:3818
 [<     inline     >] napi_poll net/core/dev.c:4744
 [<ffffffff81b8df79>] net_rx_action+0x489/0x690 net/core/dev.c:4809
 [<ffffffff81091c1e>] __do_softirq+0xbe/0x2f0 kernel/softirq.c:273
 [<ffffffff81ee4cca>] apic_timer_interrupt+0x8a/0xa0 arch/x86/entry/entry_64.S:790

Mutexes locked by thread 3146:
Mutex 436586 is locked here:
 [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:158
 [<ffffffff81ee37c0>] _raw_spin_lock+0x50/0x70 kernel/locking/spinlock.c:151
 [<     inline     >] spin_lock include/linux/spinlock.h:312
 [<ffffffff81c53b65>] tcp_write_timer+0x25/0xe0 net/ipv4/tcp_timer.c:530
 [<ffffffff8110e74c>] call_timer_fn+0x4c/0x1b0 kernel/time/timer.c:1155
 [<     inline     >] __run_timers kernel/time/timer.c:1231
 [<ffffffff8110f433>] run_timer_softirq+0x313/0x500 kernel/time/timer.c:1414
 [<ffffffff81091c1e>] __do_softirq+0xbe/0x2f0 kernel/softirq.c:273
 [<ffffffff81ee4cca>] apic_timer_interrupt+0x8a/0xa0 arch/x86/entry/entry_64.S:790

The only way I can see it happens is as follows:
 - sk_buff_fclones is allocated
 - then it is cloned which returns fclones->skb2
 - then fclones->skb2 is freed, which drops fclones->fclone_ref to 1
 - then the original skb is cloned again
 - at this point skb_clone sees that fclones->fclone_ref = 1
   and returns fclones->skb2 again
Now initialization of fclones->skb2 races with the previous use,
because refcounting lacks proper memory barriers.

I am looking at skb code for the first time, so I can't conclude
whether such scenario is possible or not. But refcount at least in
kfree_skbmem() looks broken. For example, kfree_skb() properly
inserts rmb after the fast-path check:

	if (likely(atomic_read(&skb->users) == 1))
		smp_rmb();

The patch contains a proposed fix.
If it looks good to you and the scenario looks sane,
then I will update the description and resend it.
---
 net/core/skbuff.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index dad4dd3..4c89bac 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -618,8 +618,9 @@ static void kfree_skbmem(struct sk_buff *skb)
 		/* We usually free the clone (TX completion) before original skb
 		 * This test would have no chance to be true for the clone,
 		 * while here, branch prediction will be good.
+		 * Paired with atomic_dec_and_test() below.
 		 */
-		if (atomic_read(&fclones->fclone_ref) == 1)
+		if (atomic_read_acquire(&fclones->fclone_ref) == 1)
 			goto fastpath;
 		break;
 
@@ -944,7 +945,8 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 		return NULL;
 
 	if (skb->fclone == SKB_FCLONE_ORIG &&
-	    atomic_read(&fclones->fclone_ref) == 1) {
+	    /* Paired with atomic_dec_and_test() in kfree_skbmem(). */
+	    atomic_read_acquire(&fclones->fclone_ref) == 1) {
 		n = &fclones->skb2;
 		atomic_set(&fclones->fclone_ref, 2);
 	} else {
-- 
2.6.0.rc0.131.gf624c3d
