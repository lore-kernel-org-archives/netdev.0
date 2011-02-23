From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/6] netem: use vmalloc for distribution table
Date: Wed, 23 Feb 2011 15:04:18 -0800
Message-ID: <20110223230534.173432150@vyatta.com>
References: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47471 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754673Ab1BWXHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:49 -0500
Content-Disposition: inline; filename=netem-vmalloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netem probability table can be large (up to 64K bytes)
which may be too large to allocate in one contiguous chunk.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_netem.c	2011-02-23 14:43:27.000000000 -0800
+++ b/net/sched/sch_netem.c	2011-02-23 14:49:07.228646202 -0800
@@ -308,6 +308,16 @@ static void netem_reset(struct Qdisc *sc
 	qdisc_watchdog_cancel(&q->watchdog);
 }
 
+static void dist_free(struct disttable *d)
+{
+	if (d) {
+		if (is_vmalloc_addr(d))
+			vfree(d);
+		else
+			kfree(d);
+	}
+}
+
 /*
  * Distribution data is a variable size payload containing
  * signed 16 bit values.
@@ -315,16 +325,20 @@ static void netem_reset(struct Qdisc *sc
 static int get_dist_table(struct Qdisc *sch, const struct nlattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	unsigned long n = nla_len(attr)/sizeof(__s16);
+	size_t n = nla_len(attr)/sizeof(__s16);
 	const __s16 *data = nla_data(attr);
 	spinlock_t *root_lock;
 	struct disttable *d;
 	int i;
+	size_t s;
 
 	if (n > 65536)
 		return -EINVAL;
 
-	d = kmalloc(sizeof(*d) + n*sizeof(d->table[0]), GFP_KERNEL);
+	s = sizeof(struct disttable) + n * sizeof(s16);
+	d = kmalloc(s, GFP_KERNEL);
+	if (!d)
+		d = vmalloc(s);
 	if (!d)
 		return -ENOMEM;
 
@@ -335,7 +349,7 @@ static int get_dist_table(struct Qdisc *
 	root_lock = qdisc_root_sleeping_lock(sch);
 
 	spin_lock_bh(root_lock);
-	kfree(q->delay_dist);
+	dist_free(q->delay_dist);
 	q->delay_dist = d;
 	spin_unlock_bh(root_lock);
 	return 0;
@@ -556,7 +570,7 @@ static void netem_destroy(struct Qdisc *
 
 	qdisc_watchdog_cancel(&q->watchdog);
 	qdisc_destroy(q->qdisc);
-	kfree(q->delay_dist);
+	dist_free(q->delay_dist);
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)


