From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] NET: Generic network statistics API
Date: Sun, 3 Oct 2004 23:34:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003213442.GH14344@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041003213124.GG14344@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Generic network statistics API for netlink users.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.9-rc3.orig/include/net/gen_stats.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-rc3/include/net/gen_stats.h	2004-10-03 22:18:55.000000000 +0200
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
--- linux-2.6.9-rc3.orig/include/linux/gen_stats.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-rc3/include/linux/gen_stats.h	2004-10-03 22:58:21.000000000 +0200
@@ -0,0 +1,50 @@
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
+#endif /* __LINUX_GEN_STATS_H */
--- linux-2.6.9-rc3.orig/net/core/gen_stats.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.9-rc3/net/core/gen_stats.c	2004-10-03 22:22:43.000000000 +0200
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
