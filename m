From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 05/14] net: network drivers no longer need to implement ndo_busy_poll()
Date: Wed, 18 Nov 2015 06:30:54 -0800
Message-ID: <1447857063-618-6-git-send-email-edumazet@google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eli Cohen <eli@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34793 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbKROb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:31:26 -0500
Received: by padhx2 with SMTP id hx2so46597811pad.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:31:26 -0800 (PST)
In-Reply-To: <1447857063-618-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having to implement complex ndo_busy_poll() method,
drivers can simply rely on NAPI poll logic.

Busy polling gains are mainly coming from polling itself,
not on exact details on how we poll the device.

ndo_busy_poll() if implemented can avoid touching
napi state, but it adds extra synchronization between
normal napi->poll() and busy poll handler, slowing down
the common path (non busy polling) with extra atomic operations.
In practice few drivers ever got busy poll because of the complexity.

We could go one step further, and make busy polling
available for all NAPI drivers, but this would require
that all netif_napi_del() calls are done in process context
so that we can call synchronize_rcu().
Full audit would be required.

Before this is done, a driver still needs to call :

- skb_mark_napi_id() for each skb provided to the stack.
- napi_hash_add() and napi_hash_del() to allocate a napi_id per napi struct.
- Make sure RCU grace period is respected after napi_hash_del() before
  memory containing napi structure is freed.

Followup patch implements busy poll for mlx5 driver as an example.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2002eec2617d..93009610aee8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4677,10 +4677,11 @@ static struct napi_struct *napi_by_id(unsigned int napi_id)
 }
 
 #if defined(CONFIG_NET_RX_BUSY_POLL)
+#define BUSY_POLL_BUDGET 8
 bool sk_busy_loop(struct sock *sk, int nonblock)
 {
 	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
-	const struct net_device_ops *ops;
+	int (*busy_poll)(struct napi_struct *dev);
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -4690,13 +4691,27 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	if (!napi)
 		goto out;
 
-	ops = napi->dev->netdev_ops;
-	if (!ops->ndo_busy_poll)
-		goto out;
+	/* Note: ndo_busy_poll method is optional in linux-4.5 */
+	busy_poll = napi->dev->netdev_ops->ndo_busy_poll;
 
 	do {
+		rc = 0;
 		local_bh_disable();
-		rc = ops->ndo_busy_poll(napi);
+		if (busy_poll) {
+			rc = busy_poll(napi);
+		} else if (napi_schedule_prep(napi)) {
+			void *have = netpoll_poll_lock(napi);
+
+			if (test_bit(NAPI_STATE_SCHED, &napi->state)) {
+				rc = napi->poll(napi, BUSY_POLL_BUDGET);
+				trace_napi_poll(napi);
+				if (rc == BUSY_POLL_BUDGET) {
+					napi_complete_done(napi, rc);
+					napi_schedule(napi);
+				}
+			}
+			netpoll_poll_unlock(have);
+		}
 		if (rc > 0)
 			NET_ADD_STATS_BH(sock_net(sk),
 					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
-- 
2.6.0.rc2.230.g3dd15c0
