From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] netem - distribution table fixes.
Date: Mon, 30 Aug 2004 13:57:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830135717.1f4a3af0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix some issues with netem. 
 * fix memory link in q_destroy where distribution table not freed
 * fix math error in tabledist that made it work for only small values
 * change API for distribution table so scaling factor is constant and
   table size is determined by looking at the rtnetlink payload size.
   this is faster and simpler. Since haven't actually released the tools to load
   the table yet, this is the chance to get it right ;-)

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	2004-08-30 13:55:55 -07:00
+++ b/include/linux/pkt_sched.h	2004-08-30 13:55:55 -07:00
@@ -429,11 +429,6 @@
 	__u32	dup_corr;	/* duplicate correlation  */
 };
 
-struct tc_netem_dist
-{
-	__u32	size;		/* table size */
-	__u32	factor;		/* table scaling factor */
-	__s16	data[0];	/* distribution table values */
-};
+#define NETEM_DIST_SCALE	8192
 
 #endif
diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-30 13:55:55 -07:00
+++ b/net/sched/sch_netem.c	2004-08-30 13:55:55 -07:00
@@ -71,7 +71,6 @@
 
 	struct disttable {
 		u32  size;
-		u32  factor;
 		s16 table[0];
 	} *delay_dist;
 };
@@ -113,11 +112,10 @@
  * std deviation sigma.  Uses table lookup to approximate the desired
  * distribution, and a uniformly-distributed pseudo-random source.
  */
-static unsigned long tabledist(int mu, int sigma, 
-			       struct crndstate *state,
-			       const struct disttable *dist)
+static long tabledist(unsigned long mu, long sigma, 
+		      struct crndstate *state, const struct disttable *dist)
 {
-	int t, x, factor;
+	long t, x;
 	unsigned long rnd;
 
 	if (sigma == 0)
@@ -129,16 +127,14 @@
 	if (dist == NULL) 
 		return (rnd % (2*sigma)) - sigma + mu;
 
-	factor = dist->factor;
 	t = dist->table[rnd % dist->size];
-
-	x = (sigma % factor) * t;
+	x = (sigma % NETEM_DIST_SCALE) * t;
 	if (x >= 0)
-		x += factor/2;
+		x += NETEM_DIST_SCALE/2;
 	else
-		x -= factor/2;
+		x -= NETEM_DIST_SCALE/2;
 
-	return (x + (sigma / factor) * t) / factor + mu;
+	return  x / NETEM_DIST_SCALE + (sigma / NETEM_DIST_SCALE) * t + mu;
 }
 
 /* Put skb in the private delayed queue. */
@@ -305,25 +301,28 @@
 	return ret;
 }
 
+/*
+ * Distribution data is a variable size payload containing
+ * signed 16 bit values.
+ */
 static int get_dist_table(struct Qdisc *sch, const struct rtattr *attr)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-	const struct tc_netem_dist *dist = RTA_DATA(attr);
+	unsigned long n = RTA_PAYLOAD(attr)/sizeof(__s16);
+	const __s16 *data = RTA_DATA(attr);
 	struct disttable *d;
 	int i;
 
-	if (RTA_PAYLOAD(attr) < sizeof(*dist) ||
-	    dist->factor < 2 || dist->factor > 1<<16 || dist->size > 65536)
+	if (n > 65536)
 		return -EINVAL;
 
-	d = kmalloc(sizeof(*d) + dist->size*sizeof(d->table[0]), GFP_KERNEL);
+	d = kmalloc(sizeof(*d) + n*sizeof(d->table[0]), GFP_KERNEL);
 	if (!d)
 		return -ENOMEM;
 
-	d->size = dist->size;
-	d->factor = dist->factor;
-	for (i = 0; i < dist->size; i++)
-		d->table[i] = dist->data[i];
+	d->size = n;
+	for (i = 0; i < n; i++)
+		d->table[i] = data[i];
 	
 	spin_lock_bh(&sch->dev->queue_lock);
 	d = xchg(&q->delay_dist, d);
@@ -431,6 +430,7 @@
 
 	del_timer_sync(&q->timer);
 	qdisc_destroy(q->qdisc);
+	kfree(q->delay_dist);
 }
 
 static int netem_dump(struct Qdisc *sch, struct sk_buff *skb)
