From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 09:38:52 +0200
Message-ID: <42CA390C.9000801@cosmosbay.com>
References: <20050704.154712.63128211.davem@davemloft.net>	<42C9BE69.2070008@cosmosbay.com>	<42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090908060004010709010307"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050704.160140.21591849.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090908060004010709010307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[NET] : unroll a small loop in pfifo_fast_dequeue(). Compiler generates better code.
	(Using skb_queue_empty() to test the queue is faster than trying to __skb_dequeue())
	oprofile says this function uses now 0.29% instead of 1.22 %, on a x86_64 target.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------090908060004010709010307
Content-Type: text/plain;
 name="patch.sch_generic"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.sch_generic"

--- linux-2.6.12/net/sched/sch_generic.c  2005-06-17 21:48:29.000000000 +0200
+++ linux-2.6.12-ed/net/sched/sch_generic.c       2005-07-05 09:11:30.000000000 +0200
@@ -333,18 +333,23 @@
 static struct sk_buff *
 pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
-       int prio;
        struct sk_buff_head *list = qdisc_priv(qdisc);
        struct sk_buff *skb;

-       for (prio = 0; prio < 3; prio++, list++) {
-               skb = __skb_dequeue(list);
-               if (skb) {
-                       qdisc->q.qlen--;
-                       return skb;
-               }
+       for (;;) {
+               if (!skb_queue_empty(list))
+                       break;
+               list++;
+               if (!skb_queue_empty(list))
+                       break;
+               list++;
+               if (!skb_queue_empty(list))
+                       break;
+               return NULL;
        }
-       return NULL;
+       skb = __skb_dequeue(list);
+       qdisc->q.qlen--;
+       return skb;
 }

 static int

--------------090908060004010709010307--
