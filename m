From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Tue, 5 Oct 2004 14:03:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005140304.6d0d5f02.davem@davemloft.net>
References: <20041003213124.GG14344@postel.suug.ch>
	<20041003213954.GI14344@postel.suug.ch>
	<20041003161436.50293f9a.davem@davemloft.net>
	<20041003235737.GO14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041003235737.GO14344@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Oct 2004 01:57:37 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * David S. Miller <20041003161436.50293f9a.davem@davemloft.net> 2004-10-03 16:14
> > First, how does this new thing ever get built into the tree?
> 
> I misunderstood you before and didn't realize I missed to diff the
> Makefile part. Sorry about that.

Ok, so I combined all of the work into one big patch
and checked it into my tree as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/05 13:38:47-07:00 davem@nuts.davemloft.net 
#   [NET]: Generic network statistics/estimator
#   
#   Work done by Thomas Graf <tgraf@suug.ch> and
#   Jamal Hadi Salim <hadi@cyberus.ca>
#   
#   The following patchset introduces generic network statistics for
#   netlink users. It uses nested TLV which prevents further compatibility
#   problems when introducing new statistics. Backward compatibility to
#   existing TLV types TCA_STATS and TCA_XSTATS is ensured but can be
#   easly removed once it is no longer needed. Therefore prior users of
#   struct tc_stats can be converted to this API and existing userspace
#   applications will not notice a difference while converted applications
#   can use the new extendable statistic interface.
#   
#   Changes:
#   - Add generic network statistics API for netlink users.
#   - Introduces a generic rate estimator based on timers. Patch is based
#     on Jamals patch and adapted to the new generic network statistics
#     API.
#   - Add documentation of generic network statistics and estimator API.
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
#   Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/core/Makefile
#   2004/10/05 13:36:58-07:00 davem@nuts.davemloft.net +1 -1
#   [NET]: Generic network statistics/estimator
# 
# net/core/gen_stats.c
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +132 -0
#   [NET]: Generic network statistics/estimator
# 
# net/core/gen_estimator.c
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +204 -0
#   [NET]: Generic network statistics/estimator
# 
# include/net/gen_stats.h
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +45 -0
#   [NET]: Generic network statistics/estimator
# 
# Documentation/networking/gen_stats.txt
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +117 -0
#   [NET]: Generic network statistics/estimator
# 
# net/core/gen_stats.c
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +0 -0
#   BitKeeper file /disk1/BK/net-2.6/net/core/gen_stats.c
# 
# net/core/gen_estimator.c
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +0 -0
#   BitKeeper file /disk1/BK/net-2.6/net/core/gen_estimator.c
# 
# include/net/gen_stats.h
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +0 -0
#   BitKeeper file /disk1/BK/net-2.6/include/net/gen_stats.h
# 
# include/linux/gen_stats.h
#   2004/10/05 13:36:51-07:00 davem@nuts.davemloft.net +62 -0
#   [NET]: Generic network statistics/estimator
# 
# Documentation/networking/gen_stats.txt
#   2004/10/05 13:36:52-07:00 davem@nuts.davemloft.net +0 -0
#   BitKeeper file /disk1/BK/net-2.6/Documentation/networking/gen_stats.txt
# 
# include/linux/gen_stats.h
#   2004/10/05 13:36:51-07:00 davem@nuts.davemloft.net +0 -0
#   BitKeeper file /disk1/BK/net-2.6/include/linux/gen_stats.h
# 
diff -Nru a/Documentation/networking/gen_stats.txt b/Documentation/networking/gen_stats.txt
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/Documentation/networking/gen_stats.txt	2004-10-05 13:41:59 -07:00
@@ -0,0 +1,117 @@
+Generic networking statistics for netlink users
+======================================================================
+
+Statistic counters are grouped into structs:
+
+Struct               TLV type              Description
+----------------------------------------------------------------------
+gnet_stats_basic     TCA_STATS_BASIC       Basic statistics
+gnet_stats_rate_est  TCA_STATS_RATE_EST    Rate estimator
+gnet_stats_queue     TCA_STATS_QUEUE       Queue statistics
+none                 TCA_STATS_APP         Application specific
+
+
+Collecting:
+-----------
+
+Declare the statistic structs you need:
+struct mystruct {
+	struct gnet_stats_basic	bstats;
+	struct gnet_stats_queue	qstats;
+	...
+};
+
+Update statistics:
+mystruct->tstats.packet++;
+mystruct->qstats.backlog += skb->pkt_len;
+
+
+Export to userspace (Dump):
+---------------------------
+
+my_dumping_routine(struct sk_buff *skb, ...)
+{
+	struct gnet_dump dump;
+
+	if (gnet_stats_start_copy(skb, TCA_STATS2, &mystruct->lock, &dump) < 0)
+		goto rtattr_failure;
+
+	if (gnet_stats_copy_basic(&dump, &mystruct->bstats) < 0 ||
+	    gnet_stats_copy_queue(&dump, &mystruct->qstats) < 0 ||
+		gnet_stats_copy_app(&dump, &xstats, sizeof(xstats)) < 0)
+		goto rtattr_failure;
+
+	if (gnet_stats_finish_copy(&dump) < 0)
+		goto rtattr_failure;
+	...
+}
+
+TCA_STATS/TCA_XSTATS backward compatibility:
+--------------------------------------------
+
+Prior users of struct tc_stats and xstats can maintain backward
+compatibility by calling the compat wrappers to keep providing the
+existing TLV types.
+
+my_dumping_routine(struct sk_buff *skb, ...)
+{
+    if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
+		TCA_XSTATS, &mystruct->lock, &dump) < 0)
+		goto rtattr_failure;
+	...
+}
+
+A struct tc_stats will be filled out during gnet_stats_copy_* calls
+and appended to the skb. TCA_XSTATS is provided if gnet_stats_copy_app
+was called.
+
+
+Locking:
+--------
+
+Locks are taken before writing and released once all statistics have
+been written. Locks are always released in case of an error. You
+are responsible for making sure that the lock is initialized.
+
+
+Rate Estimator:
+--------------
+
+0) Prepare an estimator attribute. Most likely this would be in user
+   space. The value of this TLV should contain a tc_estimator structure.
+   As usual, such a TLV nees to be 32 bit aligned and therefore the
+   length needs to be appropriately set etc. The estimator interval
+   and ewma log need to be converted to the appropriate values.
+   tc_estimator.c::tc_setup_estimator() is advisable to be used as the
+   conversion routine. It does a few clever things. It takes a time
+   interval in microsecs, a time constant also in microsecs and a struct
+   tc_estimator to  be populated. The returned tc_estimator can be
+   transported to the kernel.  Transfer such a structure in a TLV of type
+   TCA_RATE to your code in the kernel.
+
+In the kernel when setting up:
+1) make sure you have basic stats and rate stats setup first.
+2) make sure you have initialized stats lock that is used to setup such
+   stats.
+3) Now initialize a new estimator:
+
+   int ret = gen_new_estimator(my_basicstats,my_rate_est_stats,
+       mystats_lock, attr_with_tcestimator_struct);
+
+   if ret == 0
+       success
+   else
+       failed
+
+From now on, everytime you dump my_rate_est_stats it will contain
+uptodate info.
+
+Once you are done, call gen_kill_estimator(my_basicstats,
+my_rate_est_stats) Make sure that my_basicstats and my_rate_est_stats
+are still valid (i.e still exist) at the time of making this call.
+
+
+Authors:
+--------
+Thomas Graf <tgraf@suug.ch>
+Jamal Hadi Salim <hadi@cyberus.ca>
diff -Nru a/include/linux/gen_stats.h b/include/linux/gen_stats.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/linux/gen_stats.h	2004-10-05 13:41:59 -07:00
@@ -0,0 +1,62 @@
+#ifndef __LINUX_GEN_STATS_H
+#define __LINUX_GEN_STATS_H
+
+#include <linux/types.h>
+
+enum {
+	TCA_STATS_UNSPEC,
+	TCA_STATS_BASIC,
+	TCA_STATS_RATE_EST,
+	TCA_STATS_QUEUE,
+	TCA_STATS_APP,
+	__TCA_STATS_MAX,
+};
+#define TCA_STATS_MAX (__TCA_STATS_MAX - 1)
+
+/**
+ * @bytes: number of seen bytes
+ * @packets: number of seen packets
+ */
+struct gnet_stats_basic
+{
+	__u64	bytes;
+	__u32	packets;
+};
+
+/**
+ * @bps: current byte rate
+ * @pps: current packet rate
+ */
+struct gnet_stats_rate_est
+{
+	__u32	bps;
+	__u32	pps;
+};
+
+/**
+ * @qlen: queue length
+ * @backlog: backlog size of queue
+ * @drops: number of dropped packets
+ * @requeues: number of requeues
+ */
+struct gnet_stats_queue
+{
+	__u32	qlen;
+	__u32	backlog;
+	__u32	drops;
+	__u32	requeues;
+	__u32	overlimits;
+};
+
+/**
+ * @interval: sampling period
+ * @ewma_log: the log of measurement window weight
+ */
+struct gnet_estimator
+{
+	signed char	interval;
+	unsigned char	ewma_log;
+};
+
+
+#endif /* __LINUX_GEN_STATS_H */
diff -Nru a/include/net/gen_stats.h b/include/net/gen_stats.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/net/gen_stats.h	2004-10-05 13:41:59 -07:00
@@ -0,0 +1,45 @@
+#ifndef __NET_GEN_STATS_H
+#define __NET_GEN_STATS_H
+
+#include <linux/gen_stats.h>
+#include <linux/socket.h>
+#include <linux/rtnetlink.h>
+#include <linux/pkt_sched.h>
+
+struct gnet_dump
+{
+	spinlock_t *      lock;
+	struct sk_buff *  skb;
+	struct rtattr *   tail;
+
+	/* Backward compatability */
+	int               compat_tc_stats;
+	int               compat_xstats;
+	struct rtattr *   xstats;
+	struct tc_stats   tc_stats;
+};
+
+extern int gnet_stats_start_copy(struct sk_buff *skb, int type,
+				 spinlock_t *lock, struct gnet_dump *d);
+
+extern int gnet_stats_start_copy_compat(struct sk_buff *skb, int type,
+					int tc_stats_type,int xstats_type,
+					spinlock_t *lock, struct gnet_dump *d);
+
+extern int gnet_stats_copy_basic(struct gnet_dump *d,
+				 struct gnet_stats_basic *b);
+extern int gnet_stats_copy_rate_est(struct gnet_dump *d,
+				    struct gnet_stats_rate_est *r);
+extern int gnet_stats_copy_queue(struct gnet_dump *d,
+				 struct gnet_stats_queue *q);
+extern int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
+
+extern int gnet_stats_finish_copy(struct gnet_dump *d);
+
+extern int gen_new_estimator(struct gnet_stats_basic *bstats,
+			     struct gnet_stats_rate_est *rate_est,
+			     spinlock_t *stats_lock, struct rtattr *opt);
+extern void gen_kill_estimator(struct gnet_stats_basic *bstats,
+			       struct gnet_stats_rate_est *rate_est);
+
+#endif
diff -Nru a/net/core/Makefile b/net/core/Makefile
--- a/net/core/Makefile	2004-10-05 13:41:59 -07:00
+++ b/net/core/Makefile	2004-10-05 13:41:59 -07:00
@@ -2,7 +2,7 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o
+obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o gen_stats.o gen_estimator.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
diff -Nru a/net/core/gen_estimator.c b/net/core/gen_estimator.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/core/gen_estimator.c	2004-10-05 13:41:59 -07:00
@@ -0,0 +1,204 @@
+/*
+ * net/sched/gen_estimator.c	Simple rate estimator.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ * Changes:
+ *              Jamal Hadi Salim - moved it to net/core and reshulfed
+ *              names to make it usable in general net subsystem.
+ */
+
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/jiffies.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/init.h>
+#include <net/sock.h>
+#include <net/gen_stats.h>
+
+/*
+   This code is NOT intended to be used for statistics collection,
+   its purpose is to provide a base for statistical multiplexing
+   for controlled load service.
+   If you need only statistics, run a user level daemon which
+   periodically reads byte counters.
+
+   Unfortunately, rate estimation is not a very easy task.
+   F.e. I did not find a simple way to estimate the current peak rate
+   and even failed to formulate the problem 8)8)
+
+   So I preferred not to built an estimator into the scheduler,
+   but run this task separately.
+   Ideally, it should be kernel thread(s), but for now it runs
+   from timers, which puts apparent top bounds on the number of rated
+   flows, has minimal overhead on small, but is enough
+   to handle controlled load service, sets of aggregates.
+
+   We measure rate over A=(1<<interval) seconds and evaluate EWMA:
+
+   avrate = avrate*(1-W) + rate*W
+
+   where W is chosen as negative power of 2: W = 2^(-ewma_log)
+
+   The resulting time constant is:
+
+   T = A/(-ln(1-W))
+
+
+   NOTES.
+
+   * The stored value for avbps is scaled by 2^5, so that maximal
+     rate is ~1Gbit, avpps is scaled by 2^10.
+
+   * Minimal interval is HZ/4=250msec (it is the greatest common divisor
+     for HZ=100 and HZ=1024 8)), maximal interval
+     is (HZ*2^EST_MAX_INTERVAL)/4 = 8sec. Shorter intervals
+     are too expensive, longer ones can be implemented
+     at user level painlessly.
+ */
+
+#define EST_MAX_INTERVAL	5
+
+struct gen_estimator
+{
+	struct gen_estimator	*next;
+	struct gnet_stats_basic	*bstats;
+	struct gnet_stats_rate_est	*rate_est;
+	spinlock_t		*stats_lock;
+	unsigned		interval;
+	int			ewma_log;
+	u64			last_bytes;
+	u32			last_packets;
+	u32			avpps;
+	u32			avbps;
+};
+
+struct gen_estimator_head
+{
+	struct timer_list	timer;
+	struct gen_estimator	*list;
+};
+
+static struct gen_estimator_head elist[EST_MAX_INTERVAL+1];
+
+/* Estimator array lock */
+static rwlock_t est_lock = RW_LOCK_UNLOCKED;
+
+static void est_timer(unsigned long arg)
+{
+	int idx = (int)arg;
+	struct gen_estimator *e;
+
+	read_lock(&est_lock);
+	for (e = elist[idx].list; e; e = e->next) {
+		u64 nbytes;
+		u32 npackets;
+		u32 rate;
+
+		spin_lock(e->stats_lock);
+		nbytes = e->bstats->bytes;
+		npackets = e->bstats->packets;
+		rate = (nbytes - e->last_bytes)<<(7 - idx);
+		e->last_bytes = nbytes;
+		e->avbps += ((long)rate - (long)e->avbps) >> e->ewma_log;
+		e->rate_est->bps = (e->avbps+0xF)>>5;
+
+		rate = (npackets - e->last_packets)<<(12 - idx);
+		e->last_packets = npackets;
+		e->avpps += ((long)rate - (long)e->avpps) >> e->ewma_log;
+		e->rate_est->pps = (e->avpps+0x1FF)>>10;
+		spin_unlock(e->stats_lock);
+	}
+
+	mod_timer(&elist[idx].timer, jiffies + ((HZ<<idx)/4));
+	read_unlock(&est_lock);
+}
+
+int gen_new_estimator(struct gnet_stats_basic *bstats,
+	struct gnet_stats_rate_est *rate_est, spinlock_t *stats_lock, struct rtattr *opt)
+{
+	struct gen_estimator *est;
+	struct gnet_estimator *parm = RTA_DATA(opt);
+
+	if (RTA_PAYLOAD(opt) < sizeof(*parm))
+		return -EINVAL;
+
+	if (parm->interval < -2 || parm->interval > 3)
+		return -EINVAL;
+
+	est = kmalloc(sizeof(*est), GFP_KERNEL);
+	if (est == NULL)
+		return -ENOBUFS;
+
+	memset(est, 0, sizeof(*est));
+	est->interval = parm->interval + 2;
+	est->bstats = bstats;
+	est->rate_est = rate_est;
+	est->stats_lock = stats_lock;
+	est->ewma_log = parm->ewma_log;
+	est->last_bytes = bstats->bytes;
+	est->avbps = rate_est->bps<<5;
+	est->last_packets = bstats->packets;
+	est->avpps = rate_est->pps<<10;
+
+	est->next = elist[est->interval].list;
+	if (est->next == NULL) {
+		init_timer(&elist[est->interval].timer);
+		elist[est->interval].timer.data = est->interval;
+		elist[est->interval].timer.expires = jiffies + ((HZ<<est->interval)/4);
+		elist[est->interval].timer.function = est_timer;
+		add_timer(&elist[est->interval].timer);
+	}
+	write_lock_bh(&est_lock);
+	elist[est->interval].list = est;
+	write_unlock_bh(&est_lock);
+	return 0;
+}
+
+void gen_kill_estimator(struct gnet_stats_basic *bstats,
+	struct gnet_stats_rate_est *rate_est)
+{
+	int idx;
+	struct gen_estimator *est, **pest;
+
+	for (idx=0; idx <= EST_MAX_INTERVAL; idx++) {
+		int killed = 0;
+		pest = &elist[idx].list;
+		while ((est=*pest) != NULL) {
+			if (est->rate_est != rate_est || est->bstats != bstats) {
+				pest = &est->next;
+				continue;
+			}
+
+			write_lock_bh(&est_lock);
+			*pest = est->next;
+			write_unlock_bh(&est_lock);
+
+			kfree(est);
+			killed++;
+		}
+		if (killed && elist[idx].list == NULL)
+			del_timer(&elist[idx].timer);
+	}
+}
+
+EXPORT_SYMBOL(gen_kill_estimator);
+EXPORT_SYMBOL(gen_new_estimator);
diff -Nru a/net/core/gen_stats.c b/net/core/gen_stats.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/core/gen_stats.c	2004-10-05 13:41:59 -07:00
@@ -0,0 +1,132 @@
+/*
+ * net/core/gen_stats.c
+ *
+ *             This program is free software; you can redistribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; either version
+ *             2 of the License, or (at your option) any later version.
+ *
+ * Authors:  Thomas Graf <tgraf@suug.ch>
+ *           Jamal Hadi Salim
+ *           Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
+ *
+ * See Documentation/networking/gen_stats.txt
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/socket.h>
+#include <linux/rtnetlink.h>
+#include <linux/gen_stats.h>
+#include <net/gen_stats.h>
+
+
+static inline int
+gnet_stats_copy(struct gnet_dump *d, int type, void *buf, int size)
+{
+	RTA_PUT(d->skb, type, size, buf);
+	return 0;
+
+rtattr_failure:
+	spin_unlock_bh(d->lock);
+	return -1;
+}
+
+int
+gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
+	int xstats_type, spinlock_t *lock, struct gnet_dump *d)
+{
+	spin_lock_bh(lock);
+	d->lock = lock;
+	d->tail = (struct rtattr *) skb->tail;
+	d->skb = skb;
+	d->compat_tc_stats = tc_stats_type;
+	d->compat_xstats = xstats_type;
+	d->xstats = NULL;
+
+	if (d->compat_tc_stats)
+		memset(&d->tc_stats, 0, sizeof(d->tc_stats));
+
+	return gnet_stats_copy(d, type, NULL, 0);
+}
+
+int
+gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
+	struct gnet_dump *d)
+{
+	return gnet_stats_start_copy_compat(skb, type, 0, 0, lock, d);
+}
+
+
+int
+gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic *b)
+{
+	if (d->compat_tc_stats) {
+		d->tc_stats.bytes = b->bytes;
+		d->tc_stats.packets = b->packets;
+	}
+	
+	return gnet_stats_copy(d, TCA_STATS_BASIC, b, sizeof(*b));
+}
+
+int
+gnet_stats_copy_rate_est(struct gnet_dump *d, struct gnet_stats_rate_est *r)
+{
+	if (d->compat_tc_stats) {
+		d->tc_stats.bps = r->bps;
+		d->tc_stats.pps = r->pps;
+	}
+
+	return gnet_stats_copy(d, TCA_STATS_RATE_EST, r, sizeof(*r));
+}
+
+int
+gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q)
+{
+	if (d->compat_tc_stats) {
+		d->tc_stats.drops = q->drops;
+		d->tc_stats.qlen = q->qlen;
+		d->tc_stats.backlog = q->backlog;
+		d->tc_stats.overlimits = q->overlimits;
+	}
+		
+	return gnet_stats_copy(d, TCA_STATS_QUEUE, q, sizeof(*q));
+}
+
+int
+gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
+{
+	if (d->compat_xstats)
+		d->xstats = (struct rtattr *) d->skb->tail;
+	return gnet_stats_copy(d, TCA_STATS_APP, st, len);
+}
+
+int
+gnet_stats_finish_copy(struct gnet_dump *d)
+{
+	d->tail->rta_len = d->skb->tail - (u8 *) d->tail;
+
+	if (d->compat_tc_stats)
+		if (gnet_stats_copy(d, d->compat_tc_stats, &d->tc_stats,
+			sizeof(d->tc_stats)) < 0)
+			return -1;
+
+	if (d->compat_xstats && d->xstats) {
+		if (gnet_stats_copy(d, d->compat_xstats, RTA_DATA(d->xstats),
+			RTA_PAYLOAD(d->xstats)) < 0)
+			return -1;
+	}
+
+	spin_unlock_bh(d->lock);
+	return 0;
+}
+
+
+EXPORT_SYMBOL(gnet_stats_start_copy);
+EXPORT_SYMBOL(gnet_stats_copy_basic);
+EXPORT_SYMBOL(gnet_stats_copy_rate_est);
+EXPORT_SYMBOL(gnet_stats_copy_queue);
+EXPORT_SYMBOL(gnet_stats_copy_app);
+EXPORT_SYMBOL(gnet_stats_finish_copy);
