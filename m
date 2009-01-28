From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-next] pkt_sched: sch_htb: Warn on too many events.
Date: Wed, 28 Jan 2009 12:52:30 +0000
Message-ID: <20090128125230.GA6282@ff.dom.local>
References: <496B19F7.4060909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:54954 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbZA1Mwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 07:52:38 -0500
Received: by fg-out-1718.google.com with SMTP id 13so546837fge.17
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2009 04:52:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496B19F7.4060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-01-2009 11:22, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
>> BTW, I wonder if adding the old "too many
>> events" warning back wouldn't be more useful here.
> 
> It would be good to notify the user and also have some indication
> for this case when looking into bug reports. A counter or a (single)
> printk would both be fine.

Here is my proposal. (I assume single "work conserving" warn should be
enough too - if somebody doesn't fix it for one class, they probably
know what they are doing, and don't need more.)

Jarek P.
-------------->
pkt_sched: sch_htb: Warn on too many events.

Let's get some info on possible config problems. This patch brings
back an old warning, but it's printed only once now. BTW a "class
isn't work conserving" warning is also limited to once per qdisc
instead of per class.

With feedback from Patrick McHardy <kaber@trash.net>

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_htb.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 2f0f0b0..6fbb3e3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -114,8 +114,6 @@ struct htb_class {
 	struct tcf_proto *filter_list;
 	int filter_cnt;
 
-	int warned;		/* only one warning about non work conserving .. */
-
 	/* token bucket parameters */
 	struct qdisc_rate_table *rate;	/* rate table of the class itself */
 	struct qdisc_rate_table *ceil;	/* ceiling rate (limits borrows too) */
@@ -155,6 +153,10 @@ struct htb_sched {
 	int direct_qlen;	/* max qlen of above */
 
 	long direct_pkts;
+
+#define HTB_WARN_NONCONSERVING	0x1
+#define HTB_WARN_TOOMANYEVENTS	0x2
+	int warned;	/* only one warning about non work conserving etc. */
 };
 
 /* find class in global hash table using given handle */
@@ -687,6 +689,10 @@ static psched_time_t htb_do_events(struct htb_sched *q, int level,
 			htb_add_to_wait_tree(q, cl, diff);
 	}
 	/* too much load - let's continue on next jiffie (including above) */
+	if (!(q->warned & HTB_WARN_TOOMANYEVENTS)) {
+		printk(KERN_WARNING "htb: too many events!\n");
+		q->warned |= HTB_WARN_TOOMANYEVENTS;
+	}
 	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;
 }
 
@@ -809,11 +815,11 @@ next:
 		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
 		if (likely(skb != NULL))
 			break;
-		if (!cl->warned) {
+		if (!(q->warned & HTB_WARN_NONCONSERVING)) {
 			printk(KERN_WARNING
 			       "htb: class %X isn't work conserving ?!\n",
 			       cl->common.classid);
-			cl->warned = 1;
+			q->warned |= HTB_WARN_NONCONSERVING;
 		}
 
 		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
