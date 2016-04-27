From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: give prequeue mode some care
Date: Wed, 27 Apr 2016 10:12:25 -0700
Message-ID: <1461777145.5535.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32820 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbcD0RM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 13:12:28 -0400
Received: by mail-pf0-f175.google.com with SMTP id 206so22713213pfu.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 10:12:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP prequeue goal is to defer processing of incoming packets
to user space thread currently blocked in a recvmsg() system call.

Intent is to spend less time processing these packets on behalf
of softirq handler, as softirq handler is unfair to normal process
scheduler decisions, as it might interrupt threads that do not
even use networking.

Current prequeue implementation has following issues :

1) It only checks size of the prequeue against sk_rcvbuf

   It was fine 15 years ago when sk_rcvbuf was in the 64KB vicinity.
   But we now have ~8MB values to cope with modern networking needs.
   We have to add sk_rmem_alloc in the equation, since out of order
   packets can definitely use up to sk_rcvbuf memory themselves.

2) Even with a fixed memory truesize check, prequeue can be filled
   by thousands of packets. When prequeue needs to be flushed, either
   from sofirq context (in tcp_prequeue() or timer code), or process
   context (in tcp_prequeue_process()), this adds a latency spike
   which is often not desirable.
   I added a fixed limit of 32 packets, as this translated to a max
   flush time of 60 us on my test hosts.

   Also note that all packets in prequeue are not accounted for tcp_mem,
   since they are not charged against sk_forward_alloc at this point.
   This is probably not a big deal.

Note that this might increase LINUX_MIB_TCPPREQUEUEDROPPED counts,
which is misnamed, as packets are not dropped at all, but rather pushed
to the stack (where they can be either consumed or dropped)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d2a5763e5abc..58bcf5e001e7 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1506,16 +1506,16 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
-	if (tp->ucopy.memory > sk->sk_rcvbuf) {
+	if (skb_queue_len(&tp->ucopy.prequeue) >= 32 ||
+	    tp->ucopy.memory + atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf) {
 		struct sk_buff *skb1;
 
 		BUG_ON(sock_owned_by_user(sk));
+		NET_ADD_STATS_BH(sock_net(sk), LINUX_MIB_TCPPREQUEUEDROPPED,
+				 skb_queue_len(&tp->ucopy.prequeue));
 
-		while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL) {
+		while ((skb1 = __skb_dequeue(&tp->ucopy.prequeue)) != NULL)
 			sk_backlog_rcv(sk, skb1);
-			NET_INC_STATS_BH(sock_net(sk),
-					 LINUX_MIB_TCPPREQUEUEDROPPED);
-		}
 
 		tp->ucopy.memory = 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
