From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] netem: distribution table changes
Date: Fri, 06 Aug 2010 12:35:54 -0700
Message-ID: <20100806193559.022225705@vyatta.com>
References: <20100806193548.007978639@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35715 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761959Ab0HFTiE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 15:38:04 -0400
Content-Disposition: inline; filename=netem-dist-vmalloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some issues with distribution table in netem:
  * Make maximum size visible to user space
  * Use vmalloc to avoid allocating large physical contiguous memory.
    (maybe this should use flex array?)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/include/linux/pkt_sched.h	2010-08-02 16:22:42.197329627 -0700
+++ b/include/linux/pkt_sched.h	2010-08-03 08:29:43.926514463 -0700
@@ -466,6 +466,7 @@ struct tc_netem_corrupt {
 };
 
 #define NETEM_DIST_SCALE	8192
+#define NETEM_DIST_MAX		16384
 
 /* DRR */
 
--- a/net/sched/sch_netem.c	2010-08-03 08:29:39.546593787 -0700
+++ b/net/sched/sch_netem.c	2010-08-03 08:29:43.926514463 -0700
@@ -321,10 +321,10 @@ static int get_dist_table(struct Qdisc *
 	struct disttable *d;
 	int i;
 
-	if (n > 65536)
+	if (n > NETEM_DIST_MAX)
 		return -EINVAL;
 
-	d = kmalloc(sizeof(*d) + n*sizeof(d->table[0]), GFP_KERNEL);
+	d = vmalloc(sizeof(*d) + n*sizeof(d->table[0]));
 	if (!d)
 		return -ENOMEM;
 
@@ -332,7 +332,7 @@ static int get_dist_table(struct Qdisc *
 	for (i = 0; i < n; i++)
 		d->table[i] = data[i];
 
-	kfree(q->delay_dist);
+	vfree(q->delay_dist);
 	q->delay_dist = d;
 
 	return 0;
@@ -559,7 +559,7 @@ static void netem_destroy(struct Qdisc *
 
 	qdisc_watchdog_cancel(&q->watchdog);
 	qdisc_destroy(q->qdisc);
-	kfree(q->delay_dist);
+	vfree(q->delay_dist);
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)


