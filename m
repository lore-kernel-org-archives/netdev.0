From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/9] net: allow BH servicing in sk_busy_loop()
Date: Tue, 17 Nov 2015 05:56:59 -0800
Message-ID: <1447768624-14962-5-git-send-email-edumazet@google.com>
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
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34125 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975AbbKQN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:57:40 -0500
Received: by padhx2 with SMTP id hx2so10024443pad.1
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 05:57:40 -0800 (PST)
In-Reply-To: <1447768624-14962-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of blocking BH in whole sk_busy_loop(), block them
only around ->ndo_busy_poll() calls.

This has many benefits.

1) allow tunneled traffic to use busy poll as well as native traffic.
   Tunnels handlers usually call netif_rx() and depend on net_rx_action()
   being run (from sofirq handler)

2) allow RFS/RPS being used (sending IPI to other cpus if needed)

3) use the 'lets burn cpu cycles' budget to do useful work
   (like TX completions, timers, RCU callbacks...)

4) reduce BH latencies, making busy poll a better citizen.

Tested:

Tested with SIT tunnel

lpaa5:~# echo 0 >/proc/sys/net/core/busy_read
lpaa5:~# ./netperf -H 2002:af6:786::1 -t TCP_RR
MIGRATED TCP REQUEST/RESPONSE TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:786::1 () port 0 AF_INET6 : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    37373.93
16384  87380

Now enable busy poll on both hosts

lpaa5:~# echo 70 >/proc/sys/net/core/busy_read
lpaa6:~# echo 70 >/proc/sys/net/core/busy_read

lpaa5:~# ./netperf -H 2002:af6:786::1 -t TCP_RR
MIGRATED TCP REQUEST/RESPONSE TEST from ::0 (::) port 0 AF_INET6 to 2002:af6:786::1 () port 0 AF_INET6 : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       10.00    58314.77
16384  87380

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c | 18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8902b01a827b..4d0fbf5987ff 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4680,11 +4680,7 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	struct napi_struct *napi;
 	int rc = false;
 
-	/*
-	 * rcu read lock for napi hash
-	 * bh so we don't race with net_rx_action
-	 */
-	rcu_read_lock_bh();
+	rcu_read_lock();
 
 	napi = napi_by_id(sk->sk_napi_id);
 	if (!napi)
@@ -4695,23 +4691,23 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 		goto out;
 
 	do {
+		local_bh_disable();
 		rc = ops->ndo_busy_poll(napi);
+		if (rc > 0)
+			NET_ADD_STATS_BH(sock_net(sk),
+					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
+		local_bh_enable();
 
 		if (rc == LL_FLUSH_FAILED)
 			break; /* permanent failure */
 
-		if (rc > 0)
-			/* local bh are disabled so it is ok to use _BH */
-			NET_ADD_STATS_BH(sock_net(sk),
-					 LINUX_MIB_BUSYPOLLRXPACKETS, rc);
 		cpu_relax();
-
 	} while (!nonblock && skb_queue_empty(&sk->sk_receive_queue) &&
 		 !need_resched() && !busy_loop_timeout(end_time));
 
 	rc = !skb_queue_empty(&sk->sk_receive_queue);
 out:
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 	return rc;
 }
 EXPORT_SYMBOL(sk_busy_loop);
-- 
2.6.0.rc2.230.g3dd15c0
