From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -v2] ipvs: Remove unused variable ret from sync_thread_master()
Date: Tue, 12 Nov 2013 15:34:24 +0100
Message-ID: <1384266864-564-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:45136 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817Ab3KLOeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 09:34:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]

Commit 35a2af94c7ce7130ca292c68b1d27fcfdb648f6b ("sched/wait: Make the
__wait_event*() interface more friendly") changed how the interruption
state is returned. However, sync_thread_master() ignores this state,
now causing a compile warning.

According to Julian Anastasov <ja@ssi.bg>, this behavior is OK:

    "Yes, your patch looks ok to me. In the past we used ssleep() but IPVS
     users were confused why IPVS threads increase the load average. So, we
     switched to _interruptible calls and later the socket polling was
     added."

Document this, as requested by Peter Zijlstra, to avoid precious developers
disappearing in this pitfall in the future.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
v2: Document that sync_thread_master() ignores the interruption state,

 net/netfilter/ipvs/ip_vs_sync.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f63c2388f38d..db801263ee9f 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1637,7 +1637,10 @@ static int sync_thread_master(void *data)
 			continue;
 		}
 		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
-			int ret = __wait_event_interruptible(*sk_sleep(sk),
+			/* (Ab)use interruptible sleep to avoid increasing
+			 * the load avg.
+			 */
+			__wait_event_interruptible(*sk_sleep(sk),
 						   sock_writeable(sk) ||
 						   kthread_should_stop());
 			if (unlikely(kthread_should_stop()))
-- 
1.7.9.5
