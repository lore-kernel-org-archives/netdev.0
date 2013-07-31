From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netem: Introduce skb_orphan_partial() helper
Date: Tue, 30 Jul 2013 17:55:08 -0700
Message-ID: <1375232108.10515.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:60808 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3GaAzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:55:11 -0400
Received: by mail-pb0-f42.google.com with SMTP id un1so100332pbc.1
        for <netdev@vger.kernel.org>; Tue, 30 Jul 2013 17:55:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 547669d483e578 ("tcp: xps: fix reordering issues") added
unexpected reorders in case netem is used in a MQ setup for high
performance test bed.

ETH=eth0
tc qd del dev $ETH root 2>/dev/null
tc qd add dev $ETH root handle 1: mq
for i in `seq 1 32`
do
 tc qd add dev $ETH parent 1:$i netem delay 100ms
done

As all tcp packets are orphaned by netem, TCP stack believes it can
set skb->ooo_okay on all packets.

In order to allow producers to send more packets, we want to 
keep sk_wmem_alloc from reaching sk_sndbuf limit.

We can do that by accounting one byte per skb in netem queues,
so that TCP stack is not fooled too much.

Tested:

With above MQ/netem setup, scaling number of concurrent flows gives
linear results and no reorders/retransmits

lpq83:~# for n in 1 10 20 30 40 50 60 70 80 90 100
 do echo -n "n:$n " ; ./super_netperf $n -H 10.7.7.84; done
n:1 198.46
n:10 2002.69
n:20 4000.98
n:30 6006.35
n:40 8020.93
n:50 10032.3
n:60 12081.9
n:70 13971.3
n:80 16009.7
n:90 17117.3
n:100 17425.5

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |    1 +
 net/core/sock.c       |   19 +++++++++++++++++++
 net/sched/sch_netem.c |    5 +----
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b9f2b09..53d4714 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1520,6 +1520,7 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
 					      unsigned long size, int force,
 					      gfp_t priority);
 extern void			sock_wfree(struct sk_buff *skb);
+extern void			skb_orphan_partial(struct sk_buff *skb);
 extern void			sock_rfree(struct sk_buff *skb);
 extern void			sock_edemux(struct sk_buff *skb);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 85e8de1..a753d97 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1576,6 +1576,25 @@ void sock_wfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_wfree);
 
+void skb_orphan_partial(struct sk_buff *skb)
+{
+	/* TCP stack sets skb->ooo_okay based on sk_wmem_alloc,
+	 * so we do not completely orphan skb, but transfert all
+	 * accounted bytes but one, to avoid unexpected reorders.
+	 */
+	if (skb->destructor == sock_wfree
+#ifdef CONFIG_INET
+	    || skb->destructor == tcp_wfree
+#endif
+		) {
+		atomic_sub(skb->truesize - 1, &skb->sk->sk_wmem_alloc);
+		skb->truesize = 1;
+	} else {
+		skb_orphan(skb);
+	}
+}
+EXPORT_SYMBOL(skb_orphan_partial);
+
 /*
  * Read buffer destructor automatically called from kfree_skb.
  */
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 82f6016..a6d788d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -412,12 +412,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 
 	/* If a delay is expected, orphan the skb. (orphaning usually takes
 	 * place at TX completion time, so _before_ the link transit delay)
-	 * Ideally, this orphaning should be done after the rate limiting
-	 * module, because this breaks TCP Small Queue, and other mechanisms
-	 * based on socket sk_wmem_alloc.
 	 */
 	if (q->latency || q->jitter)
-		skb_orphan(skb);
+		skb_orphan_partial(skb);
 
 	/*
 	 * If we need to duplicate packet, then re-insert at top of the
