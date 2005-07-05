From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 01:41:04 +0200
Message-ID: <20050705234104.GR16076@postel.suug.ch>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CB14B2.5090601@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CB14B2.5090601@cosmosbay.com> 2005-07-06 01:16
> Oh well, I was unaware of last changes in 2.6.13-rc1 :(

Ok, this clarifies a lot for me, I was under the impression
you knew about these changes.

> Given the fact that the PFIFO_FAST_BANDS macro was introduced, I wonder if 
> the patch should be this one or not...
> Should we assume PFIFO_FAST_BANDS will stay at 3 or what ?

It is very unlikely to change within mainline but the idea behind
it is to allow it be changed at compile time.

I still think we can fix this performance issue without manually
unrolling the loop or we should at least try to. In the end gcc
should notice the constant part of the loop and move it out so
basically the only difference should the additional prio++ and
possibly a failing branch prediction.

What about this? I'm still not sure where exactly all the time
is lost so this is a shot in the dark.

Index: net-2.6/net/sched/sch_generic.c
===================================================================
--- net-2.6.orig/net/sched/sch_generic.c
+++ net-2.6/net/sched/sch_generic.c
@@ -330,10 +330,11 @@ static struct sk_buff *pfifo_fast_dequeu
 {
 	int prio;
 	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct sk_buff *skb;
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++, list++) {
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
-		if (skb) {
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		if (!skb_queue_empty(list + prio)) {
+			skb = __qdisc_dequeue_head(qdisc, list);
 			qdisc->q.qlen--;
 			return skb;
 		}
