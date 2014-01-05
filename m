From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/12] ipvs: Remove unused variable ret from sync_thread_master()
Date: Mon,  6 Jan 2014 00:12:59 +0100
Message-ID: <1388963586-5049-6-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>

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
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index f63c238..db80126 100644
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
1.7.10.4

