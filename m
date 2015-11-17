From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/9] net: network drivers no longer need to implement ndo_busy_poll()
Date: Tue, 17 Nov 2015 05:57:00 -0800
Message-ID: <1447768624-14962-6-git-send-email-edumazet@google.com>
References: <1447768624-14962-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Willem de Bruijn <willemb@google.com>,
	Rida Assaf <rida@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35018 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbbKQN5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:57:43 -0500
Received: by pacej9 with SMTP id ej9so9935485pac.2
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:57:43 -0800 (PST)
In-Reply-To: <1447768624-14962-1-git-send-email-edumazet@google.com>
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

- skb_mark_napi_id() for each skb provided to the stack, although we can
  easily do this directly in core networking stack in a future patch.

- napi_hash_add() and napi_hash_del() to allocate/free a napi_id per napi.

- Make sure RCU grace period is respected after napi_hash_del() before
  memory containing napi structure is freed.

Followup patch implements busy poll for mlx5 driver as an example.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c | 25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4d0fbf5987ff..21a7d4093fde 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4673,10 +4673,11 @@ static struct napi_struct *napi_by_id(unsigned int napi_id)
 	return NULL;
 }
 
+#define BUSY_POLL_BUDGET 8
 bool sk_busy_loop(struct sock *sk, int nonblock)
 {
 	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
-	const struct net_device_ops *ops;
+	int (*busy_poll)(struct napi_struct *dev);
 	struct napi_struct *napi;
 	int rc = false;
 
@@ -4686,13 +4687,27 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
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
