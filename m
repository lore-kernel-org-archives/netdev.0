From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] dst: rcu check refinement
Date: Thu, 22 Apr 2010 23:30:18 +0200
Message-ID: <1271971818.7895.6547.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:46380 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754Ab0DVVa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 17:30:29 -0400
Received: by bwz25 with SMTP id 25so10216227bwz.28
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 14:30:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__sk_dst_get() might be called from softirq, with socket lock held.

[  159.026180] include/net/sock.h:1200 invoked rcu_dereference_check()
without protection!
[  159.026261] 
[  159.026261] other info that might help us debug this:
[  159.026263] 
[  159.026425] 
[  159.026426] rcu_scheduler_active = 1, debug_locks = 0
[  159.026552] 2 locks held by swapper/0:
[  159.026609]  #0:  (&icsk->icsk_retransmit_timer){+.-...}, at:
[<ffffffff8104fc15>] run_timer_softirq+0x105/0x350
[  159.026839]  #1:  (slock-AF_INET){+.-...}, at: [<ffffffff81392b8f>]
tcp_write_timer+0x2f/0x1e0
[  159.027063] 
[  159.027064] stack backtrace:
[  159.027172] Pid: 0, comm: swapper Not tainted
2.6.34-rc5-03707-gde498c8-dirty #36
[  159.027252] Call Trace:
[  159.027306]  <IRQ>  [<ffffffff810718ef>] lockdep_rcu_dereference
+0xaf/0xc0
[  159.027411]  [<ffffffff8138e4f7>] tcp_current_mss+0xa7/0xb0
[  159.027537]  [<ffffffff8138fa49>] tcp_write_wakeup+0x89/0x190
[  159.027600]  [<ffffffff81391936>] tcp_send_probe0+0x16/0x100
[  159.027726]  [<ffffffff81392cd9>] tcp_write_timer+0x179/0x1e0
[  159.027790]  [<ffffffff8104fca1>] run_timer_softirq+0x191/0x350
[  159.027980]  [<ffffffff810477ed>] __do_softirq+0xcd/0x200


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/include/net/sock.h b/include/net/sock.h
index 8ab0514..86a8ca1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1197,7 +1197,8 @@ static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
 {
 	return rcu_dereference_check(sk->sk_dst_cache, rcu_read_lock_held() ||
-						       sock_owned_by_user(sk));
+						       sock_owned_by_user(sk) ||
+						       lockdep_is_held(&sk->sk_lock.slock));
 }
 
 static inline struct dst_entry *


