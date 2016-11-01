From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] inet: fix sleeping inside inet_wait_for_connect()
Date: Tue,  1 Nov 2016 16:04:36 -0700
Message-ID: <1478041476-5568-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36267 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753037AbcKAXEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 19:04:47 -0400
Received: by mail-pf0-f196.google.com with SMTP id n85so12790525pfi.3
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 16:04:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported this kernel warning:

  WARNING: CPU: 0 PID: 4608 at kernel/sched/core.c:7724
  __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
  do not call blocking ops when !TASK_RUNNING; state=1 set at
  [<ffffffff811f5a5c>] prepare_to_wait+0xbc/0x210
  kernel/sched/wait.c:178
  Modules linked in:
  CPU: 0 PID: 4608 Comm: syz-executor Not tainted 4.9.0-rc2+ #320
  Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
   ffff88006625f7a0 ffffffff81b46914 ffff88006625f818 0000000000000000
   ffffffff84052960 0000000000000000 ffff88006625f7e8 ffffffff81111237
   ffff88006aceac00 ffffffff00001e2c ffffed000cc4beff ffffffff84052960
  Call Trace:
   [<     inline     >] __dump_stack lib/dump_stack.c:15
   [<ffffffff81b46914>] dump_stack+0xb3/0x10f lib/dump_stack.c:51
   [<ffffffff81111237>] __warn+0x1a7/0x1f0 kernel/panic.c:550
   [<ffffffff8111132c>] warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:565
   [<ffffffff811922fc>] __might_sleep+0x14c/0x1a0 kernel/sched/core.c:7719
   [<     inline     >] slab_pre_alloc_hook mm/slab.h:393
   [<     inline     >] slab_alloc_node mm/slub.c:2634
   [<     inline     >] slab_alloc mm/slub.c:2716
   [<ffffffff81508da0>] __kmalloc_track_caller+0x150/0x2a0 mm/slub.c:4240
   [<ffffffff8146be14>] kmemdup+0x24/0x50 mm/util.c:113
   [<ffffffff8388b2cf>] dccp_feat_clone_sp_val.part.5+0x4f/0xe0 net/dccp/feat.c:374
   [<     inline     >] dccp_feat_clone_sp_val net/dccp/feat.c:1141
   [<     inline     >] dccp_feat_change_recv net/dccp/feat.c:1141
   [<ffffffff8388d491>] dccp_feat_parse_options+0xaa1/0x13d0 net/dccp/feat.c:1411
   [<ffffffff83894f01>] dccp_parse_options+0x721/0x1010 net/dccp/options.c:128
   [<ffffffff83891280>] dccp_rcv_state_process+0x200/0x15b0 net/dccp/input.c:644
   [<ffffffff838b8a94>] dccp_v4_do_rcv+0xf4/0x1a0 net/dccp/ipv4.c:681
   [<     inline     >] sk_backlog_rcv ./include/net/sock.h:872
   [<ffffffff82b7ceb6>] __release_sock+0x126/0x3a0 net/core/sock.c:2044
   [<ffffffff82b7d189>] release_sock+0x59/0x1c0 net/core/sock.c:2502
   [<     inline     >] inet_wait_for_connect net/ipv4/af_inet.c:547
   [<ffffffff8316b2a2>] __inet_stream_connect+0x5d2/0xbb0 net/ipv4/af_inet.c:617
   [<ffffffff8316b8d5>] inet_stream_connect+0x55/0xa0 net/ipv4/af_inet.c:656
   [<ffffffff82b705e4>] SYSC_connect+0x244/0x2f0 net/socket.c:1533
   [<ffffffff82b72dd4>] SyS_connect+0x24/0x30 net/socket.c:1514
   [<ffffffff83fbf701>] entry_SYSCALL_64_fastpath+0x1f/0xc2
  arch/x86/entry/entry_64.S:209

Unlike commit 26cabd31259ba43f68026ce3f62b78094124333f
("sched, net: Clean up sk_wait_event() vs. might_sleep()"), the
sleeping function is called before schedule_timeout(), this is indeed
a bug. Fix this by moving the wait logic to the new API, it is similar
to commit ff960a731788a7408b6f66ec4fd772ff18833211
("netdev, sched/wait: Fix sleeping inside wait event").

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/af_inet.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9648c97..5ddf5cd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -533,9 +533,9 @@ EXPORT_SYMBOL(inet_dgram_connect);
 
 static long inet_wait_for_connect(struct sock *sk, long timeo, int writebias)
 {
-	DEFINE_WAIT(wait);
+	DEFINE_WAIT_FUNC(wait, woken_wake_function);
 
-	prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
+	add_wait_queue(sk_sleep(sk), &wait);
 	sk->sk_write_pending += writebias;
 
 	/* Basic assumption: if someone sets sk->sk_err, he _must_
@@ -545,13 +545,12 @@ static long inet_wait_for_connect(struct sock *sk, long timeo, int writebias)
 	 */
 	while ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		release_sock(sk);
-		timeo = schedule_timeout(timeo);
+		timeo = wait_woken(&wait, TASK_INTERRUPTIBLE, timeo);
 		lock_sock(sk);
 		if (signal_pending(current) || !timeo)
 			break;
-		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 	}
-	finish_wait(sk_sleep(sk), &wait);
+	remove_wait_queue(sk_sleep(sk), &wait);
 	sk->sk_write_pending -= writebias;
 	return timeo;
 }
-- 
2.1.0
