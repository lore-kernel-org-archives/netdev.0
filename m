From: jamal <hadi@cyberus.ca>
Subject: RFC/PATCH capture qdisc requeue event in stats
Date: 29 Aug 2004 13:13:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093799632.1073.410.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-+0TpqyglMNHxo02qQwAl"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-+0TpqyglMNHxo02qQwAl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



The requeue event is useful in finding out when a device is overloaded
on the egress (bus or bandwidth).
Atached patch introduces this. I would have used the overlimit bits
but at the moment thats being used for different semantical reasons.
I have not done extensive testing on it. 

Opinions welcome - If all is good, Dave please apply.

cheers,
jamal

--=-+0TpqyglMNHxo02qQwAl
Content-Disposition: attachment; filename=reqs-patch
Content-Type: text/plain; name=reqs-patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/sched/sch_atm.c	2004/08/29 16:43:53	1.1
+++ b/net/sched/sch_atm.c	2004/08/29 16:58:26
@@ -545,8 +545,10 @@
 
 	D2PRINTK("atm_tc_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
 	ret = p->link.q->ops->requeue(skb,p->link.q);
-	if (!ret) sch->q.qlen++;
-	else {
+	if (!ret) {
+	       	sch->q.qlen++;
+	       	sch->stats.reqs++;
+	} else {
 		sch->stats.drops++;
 		p->link.stats.drops++;
 	}
--- a/net/sched/sch_cbq.c	2004/08/29 16:40:52	1.1
+++ b/net/sched/sch_cbq.c	2004/08/29 16:56:58
@@ -485,6 +485,7 @@
 #endif
 	if ((ret = cl->q->ops->requeue(skb, cl->q)) == 0) {
 		sch->q.qlen++;
+		sch->stats.reqs++;
 		if (!cl->next_alive)
 			cbq_activate_class(cl);
 		return 0;
--- a/net/sched/sch_dsmark.c	2004/08/29 16:41:51	1.1
+++ b/net/sched/sch_dsmark.c	2004/08/29 17:01:27
@@ -297,6 +297,7 @@
 	D2PRINTK("dsmark_requeue(skb %p,sch %p,[qdisc %p])\n",skb,sch,p);
         if ((ret = p->q->ops->requeue(skb, p->q)) == 0) {
 		sch->q.qlen++;
+		sch->stats.reqs++;
 		return 0;
 	}
 	sch->stats.drops++;
--- a/net/sched/sch_fifo.c	2004/08/29 16:42:52	1.1
+++ b/net/sched/sch_fifo.c	2004/08/29 16:52:47
@@ -67,6 +67,7 @@
 {
 	__skb_queue_head(&sch->q, skb);
 	sch->stats.backlog += skb->len;
+	sch->stats.reqs++;
 	return 0;
 }
 
@@ -126,6 +127,7 @@
 pfifo_requeue(struct sk_buff *skb, struct Qdisc* sch)
 {
 	__skb_queue_head(&sch->q, skb);
+	sch->stats.reqs++;
 	return 0;
 }
 
--- a/net/sched/sch_generic.c	2004/08/29 16:39:47	1.1
+++ b/net/sched/sch_generic.c	2004/08/29 16:56:44
@@ -327,6 +327,7 @@
 
 	__skb_queue_head(list, skb);
 	qdisc->q.qlen++;
+	qdisc->stats.reqs++;
 	return 0;
 }
 
--- a/net/sched/sch_gred.c	2004/08/29 16:44:44	1.1
+++ b/net/sched/sch_gred.c	2004/08/29 16:50:07
@@ -222,6 +222,7 @@
 
 	__skb_queue_head(&sch->q, skb);
 	sch->stats.backlog += skb->len;
+	sch->stats.reqs++;
 	q->backlog += skb->len;
 	return 0;
 }
--- a/net/sched/sch_hfsc.c	2004/08/29 16:41:19	1.1
+++ b/net/sched/sch_hfsc.c	2004/08/29 16:57:11
@@ -1803,6 +1803,7 @@
 
 	__skb_queue_head(&q->requeue, skb);
 	sch->q.qlen++;
+	sch->stats.reqs++;
 	return NET_XMIT_SUCCESS;
 }
 
--- a/net/sched/sch_htb.c	2004/08/29 16:44:17	1.1
+++ b/net/sched/sch_htb.c	2004/08/29 17:00:24
@@ -794,6 +794,7 @@
 	    htb_activate (q,cl);
 
     sch->q.qlen++;
+    sch->stats.reqs++;
     HTB_DBG(1,1,"htb_req_ok cl=%X skb=%p\n",(cl && cl != HTB_DIRECT)?cl->classid:0,skb);
     return NET_XMIT_SUCCESS;
 }
--- a/net/sched/sch_netem.c	2004/08/29 16:46:10	1.1
+++ b/net/sched/sch_netem.c	2004/08/29 16:48:44
@@ -662,8 +662,10 @@
 	struct netem_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
+	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->q.reqs++;
+	}
 
 	return ret;
 }
--- a/net/sched/sch_prio.c	2004/08/29 16:43:21	1.1
+++ b/net/sched/sch_prio.c	2004/08/29 16:57:52
@@ -139,6 +139,7 @@
 
 	if ((ret = qdisc->ops->requeue(skb, qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->stats.reqs++;
 		return 0;
 	}
 dropped:
--- a/net/sched/sch_red.c	2004/08/29 16:46:46	1.1
+++ b/net/sched/sch_red.c	2004/08/29 16:49:34
@@ -309,6 +309,8 @@
 
 	__skb_queue_head(&sch->q, skb);
 	sch->stats.backlog += skb->len;
+	sch->stats.reqs++;
+
 	return 0;
 }
 
--- a/net/sched/sch_tbf.c	2004/08/29 16:40:15	1.1
+++ b/net/sched/sch_tbf.c	2004/08/29 16:56:24
@@ -166,8 +166,10 @@
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0)
+	if ((ret = q->qdisc->ops->requeue(skb, q->qdisc)) == 0) {
 		sch->q.qlen++;
+		sch->stats.reqs++;
+	}
 
 	return ret;
 }
--- a/net/sched/sch_teql.c	2004/08/29 16:42:23	1.1
+++ b/net/sched/sch_teql.c	2004/08/29 16:53:13
@@ -112,6 +112,7 @@
 	struct teql_sched_data *q = qdisc_priv(sch);
 
 	__skb_queue_head(&q->q, skb);
+	sch->stats.reqs++;
 	return 0;
 }
 
--- a/include/linux/pkt_sched.h	2004-08-29 13:07:26.000000000 -0400
+++ b/include/linux/pkt_sched.h	2004-08-29 12:36:29.000000000 -0400
@@ -38,6 +38,7 @@
 	__u32	pps;			/* Current flow packet rate */
 	__u32	qlen;
 	__u32	backlog;
+	__u32	reqs;			/* requeues */
 };
 
 struct tc_estimator

--=-+0TpqyglMNHxo02qQwAl--
