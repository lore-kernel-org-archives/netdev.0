From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 07:24:08 +0200
Message-ID: <1340947448.29822.41.camel@edumazet-glaptop>
References: <1340903237.13187.151.camel@edumazet-glaptop>
	<1340945592.29822.8.camel@edumazet-glaptop>
	<20120628.221252.2220466000873887315.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ycheng@google.com, ncardwell@google.com, mattmathis@google.com
To: David Miller <davem@davemloft.net>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <20120628.221252.2220466000873887315.davem@davemloft.net>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-28 at 22:12 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jun 2012 06:53:12 +0200
> 
> > Please dont apply this patch, I'll submit an updated version later.
> 
> Ok.

By the way, I am not sure NET_XMIT_CN is correctly used in RED.

Or maybe my understanding of NET_XMIT_CN is wrong.

If a the packet is dropped in enqueue(), why use NET_XMIT_CN instead of 
NET_XMIT_DROP ?

This seems to mean : I dropped _this_ packet, but dont worry too much, I
might accept other packets, so please go on...

diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 633e32d..0fc5b6c 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -77,7 +77,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->qstats.overlimits++;
 		if (!red_use_ecn(q) || !INET_ECN_set_ce(skb)) {
 			q->stats.prob_drop++;
-			goto congestion_drop;
+			goto drop;
 		}
 
 		q->stats.prob_mark++;
@@ -88,7 +88,7 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		if (red_use_harddrop(q) || !red_use_ecn(q) ||
 		    !INET_ECN_set_ce(skb)) {
 			q->stats.forced_drop++;
-			goto congestion_drop;
+			goto drop;
 		}
 
 		q->stats.forced_mark++;
@@ -104,9 +104,8 @@ static int red_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	}
 	return ret;
 
-congestion_drop:
-	qdisc_drop(skb, sch);
-	return NET_XMIT_CN;
+drop:
+	return qdisc_drop(skb, sch);
 }
 
 static struct sk_buff *red_dequeue(struct Qdisc *sch)
