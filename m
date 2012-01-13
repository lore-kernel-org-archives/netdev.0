From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] netem:  de-GSO packets before enqueing
Date: Thu, 12 Jan 2012 16:57:20 -0800
Message-ID: <20120112165720.4545c670@nehalam.linuxnetplumber.net>
References: <1326400930.2740.10.camel@bwh-desktop>
	<20120112220328.GA10813@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120112220328.GA10813@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Probably something like this is needed (untested).

This issue was discovered when looking at the skb_checksum path for the
netem corruption operation, but it is a general problem.
Network emulation operations like corruption and drop want to operate
on a per-packet (not per-segment) basis. This patch does GSO in software
if necessary to break up packets.  Code is similar to logic in xfrm_output.

Although it appears that the operation is not work conserving, it is okay
because the higher level qdisc operations account for packets by incrementing
by gso_size.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_netem.c	2012-01-12 14:57:59.218796226 -0800
+++ b/net/sched/sch_netem.c	2012-01-12 15:21:07.614162912 -0800
@@ -128,6 +128,8 @@ struct netem_skb_cb {
 	psched_time_t	time_to_send;
 };
 
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch);
+
 static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 {
 	BUILD_BUG_ON(sizeof(skb->cb) <
@@ -355,6 +357,41 @@ static int tfifo_enqueue(struct sk_buff
 	return qdisc_reshape_fail(nskb, sch);
 }
 
+static int netem_enqueue_gso(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct sk_buff *segs;
+	int rc;
+
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+
+	if (IS_ERR(segs)) {
+		sch->qstats.drops++;
+		return NET_XMIT_DROP;
+	}
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int ret;
+
+		segs->next = NULL;
+		ret = netem_enqueue(segs, sch);
+		if (ret == NET_XMIT_DROP) {
+			while ((segs = nskb)) {
+				nskb = segs->next;
+				segs->next = NULL;
+				kfree_skb(segs);
+			}
+			return ret;
+		}
+
+		segs = nskb;
+	} while (segs);
+
+	return NET_XMIT_SUCCESS;
+}
+
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -370,6 +407,10 @@ static int netem_enqueue(struct sk_buff
 	int ret;
 	int count = 1;
 
+	/* Want to operate on per-packet basis */
+	if (skb_is_gso(skb))
+		return netem_enqueue_gso(skb, sch);
+
 	/* Random duplication */
 	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
 		++count;
