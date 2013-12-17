From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: autocork should not hold first packet in write queue
Date: Tue, 17 Dec 2013 09:58:30 -0800
Message-ID: <1387303110.19078.279.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f41.google.com ([209.85.213.41]:38540 "EHLO
	mail-yh0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab3LQR6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 12:58:33 -0500
Received: by mail-yh0-f41.google.com with SMTP id f11so4897736yha.28
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 09:58:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Willem noticed a TCP_RR regression caused by TCP autocorking
on a Mellanox test bed. MLX4_EN_TX_COAL_TIME is 16 us, which can be
right above RTT between hosts.

We can receive a ACK for a packet still in NIC TX ring buffer or in a
softnet completion queue.

Fix this by always pushing the skb if it is at the head of write queue.

Also, as TX completion is lockless, it's safer to perform sk_wmem_alloc
test after setting TSQ_THROTTLED.

erd:~# MIB="MIN_LATENCY,MEAN_LATENCY,MAX_LATENCY,P99_LATENCY,STDDEV_LATENCY"
erd:~#  ./netperf -H remote -t TCP_RR -- -o $MIB | tail -n 1
(repeat 3 times)

Before patch :

18,1049.87,41004,39631,6295.47
17,239.52,40804,48,2912.79
18,348.40,40877,54,3573.39

After patch :

18,22.84,4606,38,16.39
17,21.56,2871,36,13.51
17,22.46,2705,37,11.83


Reported-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: f54b311142a9 ("tcp: auto corking")
---
 net/ipv4/tcp.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0ca8754..d099f9a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -622,19 +622,21 @@ static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
 }
 
 /* If a not yet filled skb is pushed, do not send it if
- * we have packets in Qdisc or NIC queues :
+ * we have data packets in Qdisc or NIC queues :
  * Because TX completion will happen shortly, it gives a chance
  * to coalesce future sendmsg() payload into this skb, without
  * need for a timer, and with no latency trade off.
  * As packets containing data payload have a bigger truesize
- * than pure acks (dataless) packets, the last check prevents
- * autocorking if we only have an ACK in Qdisc/NIC queues.
+ * than pure acks (dataless) packets, the last checks prevent
+ * autocorking if we only have an ACK in Qdisc/NIC queues,
+ * or if TX completion was delayed after we processed ACK packet.
  */
 static bool tcp_should_autocork(struct sock *sk, struct sk_buff *skb,
 				int size_goal)
 {
 	return skb->len < size_goal &&
 	       sysctl_tcp_autocorking &&
+	       skb != tcp_write_queue_head(sk) &&
 	       atomic_read(&sk->sk_wmem_alloc) > skb->truesize;
 }
 
@@ -660,7 +662,11 @@ static void tcp_push(struct sock *sk, int flags, int mss_now,
 			NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPAUTOCORKING);
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
 		}
-		return;
+		/* It is possible TX completion already happened
+		 * before we set TSQ_THROTTLED.
+		 */
+		if (atomic_read(&sk->sk_wmem_alloc) > skb->truesize)
+			return;
 	}
 
 	if (flags & MSG_MORE)
