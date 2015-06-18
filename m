From: Christoph Paasch <cpaasch@apple.com>
Subject: [PATCH net] Revert
 "tcp: switch tcp_fastopen key generation to net_get_random_once"
Date: Wed, 17 Jun 2015 17:28:19 -0700
Message-ID: <1434587299-60271-1-git-send-email-cpaasch@apple.com>
Cc: David Miller <davem@davemloft.net>,
	Christoph Paasch <cpaasch@apple.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out7.apple.com ([17.151.62.29]:59965 "EHLO
	mail-in7.apple.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750856AbbFRArG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 20:47:06 -0400
Received: from localhost ([17.149.226.91])
 by chicory.apple.com (Oracle Communications Messaging Server 7.0.5.30.0 64bit
 (built Oct 22 2013)) with ESMTPSA id <0NQ400HYL6THTJ10@chicory.apple.com> for
 netdev@vger.kernel.org; Wed, 17 Jun 2015 17:32:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 222e83d2e0aecb6a5e8d42b1a8d51332a1eba960.

tcp_fastopen_reset_cipher really cannot be called from interrupt
context. It allocates the tcp_fastopen_context with GFP_KERNEL and
calls crypto_alloc_cipher, which allocates all kind of stuff with
GFP_KERNEL.

Thus, we might sleep when the key-generation is triggered by an
incoming TFO cookie-request which would then happen in interrupt-
context, as shown by enabling CONFIG_DEBUG_ATOMIC_SLEEP:

[   36.001813] BUG: sleeping function called from invalid context at mm/slub.c:1266
[   36.003624] in_atomic(): 1, irqs_disabled(): 0, pid: 1016, name: packetdrill
[   36.004859] CPU: 1 PID: 1016 Comm: packetdrill Not tainted 4.1.0-rc7 #14
[   36.006085] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
[   36.008250]  00000000000004f2 ffff88007f8838a8 ffffffff8171d53a ffff880075a084a8
[   36.009630]  ffff880075a08000 ffff88007f8838c8 ffffffff810967d3 ffff88007f883928
[   36.011076]  0000000000000000 ffff88007f8838f8 ffffffff81096892 ffff88007f89be00
[   36.012494] Call Trace:
[   36.012953]  <IRQ>  [<ffffffff8171d53a>] dump_stack+0x4f/0x6d
[   36.014085]  [<ffffffff810967d3>] ___might_sleep+0x103/0x170
[   36.015117]  [<ffffffff81096892>] __might_sleep+0x52/0x90
[   36.016117]  [<ffffffff8118e887>] kmem_cache_alloc_trace+0x47/0x190
[   36.017266]  [<ffffffff81680d82>] ? tcp_fastopen_reset_cipher+0x42/0x130
[   36.018485]  [<ffffffff81680d82>] tcp_fastopen_reset_cipher+0x42/0x130
[   36.019679]  [<ffffffff81680f01>] tcp_fastopen_init_key_once+0x61/0x70
[   36.020884]  [<ffffffff81680f2c>] __tcp_fastopen_cookie_gen+0x1c/0x60
[   36.022058]  [<ffffffff816814ff>] tcp_try_fastopen+0x58f/0x730
[   36.023118]  [<ffffffff81671788>] tcp_conn_request+0x3e8/0x7b0
[   36.024185]  [<ffffffff810e3872>] ? __module_text_address+0x12/0x60
[   36.025327]  [<ffffffff8167b2e1>] tcp_v4_conn_request+0x51/0x60
[   36.026410]  [<ffffffff816727e0>] tcp_rcv_state_process+0x190/0xda0
[   36.027556]  [<ffffffff81661f97>] ? __inet_lookup_established+0x47/0x170
[   36.028784]  [<ffffffff8167c2ad>] tcp_v4_do_rcv+0x16d/0x3d0
[   36.029832]  [<ffffffff812e6806>] ? security_sock_rcv_skb+0x16/0x20
[   36.030936]  [<ffffffff8167cc8a>] tcp_v4_rcv+0x77a/0x7b0
[   36.031875]  [<ffffffff816af8c3>] ? iptable_filter_hook+0x33/0x70
[   36.032953]  [<ffffffff81657d22>] ip_local_deliver_finish+0x92/0x1f0
[   36.034065]  [<ffffffff81657f1a>] ip_local_deliver+0x9a/0xb0
[   36.035069]  [<ffffffff81657c90>] ? ip_rcv+0x3d0/0x3d0
[   36.035963]  [<ffffffff81657569>] ip_rcv_finish+0x119/0x330
[   36.036950]  [<ffffffff81657ba7>] ip_rcv+0x2e7/0x3d0
[   36.037847]  [<ffffffff81610652>] __netif_receive_skb_core+0x552/0x930
[   36.038994]  [<ffffffff81610a57>] __netif_receive_skb+0x27/0x70
[   36.040033]  [<ffffffff81610b72>] process_backlog+0xd2/0x1f0
[   36.041025]  [<ffffffff81611482>] net_rx_action+0x122/0x310
[   36.042007]  [<ffffffff81076743>] __do_softirq+0x103/0x2f0
[   36.042978]  [<ffffffff81723e3c>] do_softirq_own_stack+0x1c/0x30

There does not seem to be a better way to handle this. We could try
to make the call to kmalloc and crypto_alloc_cipher during bootup, and
then generate the random value only on-the-fly (when the first TFO-SYN
comes in) with net_get_random_once in order to have the better entropy
that comes with doing the late initialisation of the random value. But
that's probably net-next material.

Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Fixes: 222e83d2e0ae ("tcp: switch tcp_fastopen key generation to net_get_random_once")
Signed-off-by: Christoph Paasch <cpaasch@apple.com>
---
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c |  5 -----
 net/ipv4/tcp_fastopen.c    | 27 +++++++++++----------------
 3 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6d204f3f9df8..f27a4e6bae11 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1359,7 +1359,6 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 		      struct request_sock *req,
 		      struct tcp_fastopen_cookie *foc,
 		      struct dst_entry *dst);
-void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
 /* Fastopen key context */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index c3852a7ff3c7..46d6b3817b41 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -231,11 +231,6 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
-		/* Generate a dummy secret but don't publish it. This
-		 * is needed so we don't regenerate a new key on the
-		 * first invocation of tcp_fastopen_cookie_gen
-		 */
-		tcp_fastopen_init_key_once(false);
 		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 46b087a27503..67377acff6a5 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -14,20 +14,6 @@ struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
 
-void tcp_fastopen_init_key_once(bool publish)
-{
-	static u8 key[TCP_FASTOPEN_KEY_LENGTH];
-
-	/* tcp_fastopen_reset_cipher publishes the new context
-	 * atomically, so we allow this race happening here.
-	 *
-	 * All call sites of tcp_fastopen_cookie_gen also check
-	 * for a valid cookie, so this is an acceptable risk.
-	 */
-	if (net_get_random_once(key, sizeof(key)) && publish)
-		tcp_fastopen_reset_cipher(key, sizeof(key));
-}
-
 static void tcp_fastopen_ctx_free(struct rcu_head *head)
 {
 	struct tcp_fastopen_context *ctx =
@@ -78,8 +64,6 @@ static bool __tcp_fastopen_cookie_gen(const void *path,
 	struct tcp_fastopen_context *ctx;
 	bool ok = false;
 
-	tcp_fastopen_init_key_once(true);
-
 	rcu_read_lock();
 	ctx = rcu_dereference(tcp_fastopen_ctx);
 	if (ctx) {
@@ -313,3 +297,14 @@ fastopen:
 	return false;
 }
 EXPORT_SYMBOL(tcp_try_fastopen);
+
+static int __init tcp_fastopen_init(void)
+{
+	__u8 key[TCP_FASTOPEN_KEY_LENGTH];
+
+	get_random_bytes(key, sizeof(key));
+	tcp_fastopen_reset_cipher(key, sizeof(key));
+	return 0;
+}
+
+late_initcall(tcp_fastopen_init);
-- 
2.1.2
