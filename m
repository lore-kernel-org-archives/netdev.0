From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 01/10] dql: Dynamic queue limits
Date: Tue, 22 Nov 2011 21:52:21 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1111222138280.13686@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:54794 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952Ab1KWFwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:52:24 -0500
Received: by fabs1 with SMTP id s1so38323fab.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:52:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implementation of dynamic queue limits (dql).  This is a libary which
allows a queue limit to be dynamically managed.  The goal of dql is
to set the queue limit, number of objects to the queue, to be minimized
without allowing the queue to be starved.

dql would be used with a queue which has these properties:

1) Objects are queued up to some limit which can be expressed as a
   count of objects.
2) Periodically a completion process executes which retires consumed
   objects.
3) Starvation occurs when limit has been reached, all queued data has
   actually been consumed but completion processing has not yet run,
   so queuing new data is blocked.
4) Minimizing the amount of queued data is desirable.

A canonical example of such a queue would be a NIC HW transmit queue.

The queue limit is dynamic, it will increase or decrease over time
depending on the workload.  The queue limit is recalculated each time
completion processing is done.  Increases occur when the queue is
starved and can exponentially increase over successive intervals.
Decreases occur when more data is being maintained in the queue than
needed to prevent starvation.  The number of extra objects, or "slack",
is measured over successive intervals, and to avoid hysteresis the
limit is only reduced by the miminum slack seen over a configurable
time period.

dql API provides routines to manage the queue:
- dql_init is called to intialize the dql structure
- dql_reset is called to reset dynamic values
- dql_queued called when objects are being enqueued
- dql_avail returns availability in the queue
- dql_completed is called when objects have be consumed in the queue

Configuration consists of:
- max_limit, maximum limit
- min_limit, minimum limit
- slack_hold_time, time to measure instances of slack before reducing
  queue limit

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/dynamic_queue_limits.h |   81 +++++++++++++++++++++
 lib/Kconfig                          |    3 +
 lib/Makefile                         |    2 +
 lib/dynamic_queue_limits.c           |  132 ++++++++++++++++++++++++++++++++++
 4 files changed, 218 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/dynamic_queue_limits.h
 create mode 100644 lib/dynamic_queue_limits.c

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
new file mode 100644
index 0000000..8953187
--- /dev/null
+++ b/include/linux/dynamic_queue_limits.h
@@ -0,0 +1,81 @@
+/*
+ * Dynamic queue limits (dql) - Definitions
+ *
+ * Copyright (c) 2011, Tom Herbert <therbert@google.com>
+ *
+ * This header file contains the definitions for dynamic queue limits (dql).
+ * dql would be used in conjunction with a producer/consumer type queue
+ * (possibly a HW queue).  Such a queue would have these general properties:
+ *
+ *   1) Objects are queued up to some limit specified as number of objects.
+ *   2) Periodically a completion process executes which retires consumed
+ *      objects.
+ *   3) Starvation occurs when limit has been reached, all queued data has
+ *      actually been consumed, but completion processing has not yet run
+ *      so queuing new data is blocked.
+ *   4) Minimizing the amount of queued data is desirable.
+ *
+ * The goal of dql is to calculate the limit as the minimum number of objects
+ * needed to prevent starvation.
+ *
+ * The dql implementation does not implement any locking for the dql data
+ * structures, the higher layer should provide this.
+ */
+
+#ifndef _LINUX_DQL_H
+#define _LINUX_DQL_H
+
+#ifdef __KERNEL__
+
+struct dql {
+	unsigned long	num_queued;		/* Total ever queued */
+	unsigned long	last_obj_cnt;		/* Count at last queuing */
+
+	unsigned long	limit ____cacheline_aligned_in_smp; /* Current limit */
+	unsigned long	prev_ovlimit;		/* Previous over limit */
+
+	unsigned long	prev_num_queued;	/* Previous queue total */
+	unsigned long	num_completed;		/* Total ever completed */
+
+	unsigned long	prev_last_obj_cnt;	/* Previous queuing cnt */
+
+	unsigned long	lowest_slack;		/* Lowest slack found */
+	unsigned long	slack_start_time;	/* Time slacks seen */
+
+	unsigned long	max_limit ____cacheline_aligned_in_smp; /* Max limit */
+	unsigned long	min_limit;		/* Minimum limit */
+	unsigned	slack_hold_time;	/* Time to measure slack */
+};
+
+/* Set some static maximums */
+#define	DQL_MAX_OBJECT (-1UL / 16)
+#define	DQL_MAX_LIMIT ((-1UL / 2) - DQL_MAX_OBJECT)
+
+/* Record number of objects queued. */
+static inline void dql_queued(struct dql *dql, unsigned long count)
+{
+	BUG_ON(count > DQL_MAX_OBJECT);
+	BUG_ON(dql->num_queued - dql->num_completed > DQL_MAX_LIMIT);
+
+	dql->num_queued += count;
+	dql->last_obj_cnt = count;
+}
+
+/* Returns how many objects can be queued, < 0 indicates over limit. */
+static inline long dql_avail(struct dql *dql)
+{
+	return dql->limit - (dql->num_queued - dql->num_completed);
+}
+
+/* Record number of completed objects and recalculate the limit. */
+extern void dql_completed(struct dql *dql, unsigned long count);
+
+/* Reset dql state */
+extern void dql_reset(struct dql *dql);
+
+/* Initialize dql state */
+extern int dql_init(struct dql *dql, unsigned hold_time);
+
+#endif /* _KERNEL_ */
+
+#endif /* _LINUX_DQL_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 32f3e5a..63b5782 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -244,6 +244,9 @@ config CPU_RMAP
 	bool
 	depends on SMP
 
+config DQL
+	bool
+
 #
 # Netlink attribute parsing support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index a4da283..ff00d4d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -115,6 +115,8 @@ obj-$(CONFIG_CPU_RMAP) += cpu_rmap.o
 
 obj-$(CONFIG_CORDIC) += cordic.o
 
+obj-$(CONFIG_DQL) += dynamic_queue_limits.o
+
 hostprogs-y	:= gen_crc32table
 clean-files	:= crc32table.h
 
diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
new file mode 100644
index 0000000..9b9edb0
--- /dev/null
+++ b/lib/dynamic_queue_limits.c
@@ -0,0 +1,132 @@
+/*
+ * Dynamic byte queue limits.  See include/linux/dynamic_queue_limits.h
+ *
+ * Copyright (c) 2011, Tom Herbert <therbert@google.com>
+ */
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/ctype.h>
+#include <linux/kernel.h>
+#include <linux/dynamic_queue_limits.h>
+
+#define POSDIFF(A, B) ((A) > (B) ? (A) - (B) : 0)
+
+/* Records completed count and recalculates the queue limit */
+void dql_completed(struct dql *dql, unsigned long count)
+{
+	unsigned long inprogress, prev_inprogress, limit;
+	unsigned long ovlimit, all_prev_completed, completed;
+
+	/* Can't complete more than what's in queue */
+	BUG_ON(count > dql->num_queued - dql->num_completed);
+
+	completed = dql->num_completed + count;
+	limit = dql->limit;
+	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
+	inprogress = dql->num_queued - completed;
+	prev_inprogress = dql->prev_num_queued - dql->num_completed;
+	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
+
+	if ((ovlimit && !inprogress) ||
+	    (dql->prev_ovlimit && all_prev_completed)) {
+		/*
+		 * Queue considered starved if:
+		 *   - The queue was over-limit in the last interval,
+		 *     and there is no more data in the queue.
+		 *  OR
+		 *   - The queue was over-limit in the previous interval and
+		 *     when enqueuing it was possible that all queued data
+		 *     had been consumed.  This covers the case when queue
+		 *     may have becomes starved between completion processing
+		 *     running and next time enqueue was scheduled.
+		 *
+		 *     When queue is starved increase the limit by the amount
+		 *     of bytes both sent and completed in the last interval,
+		 *     plus any previous over-limit.
+		 */
+		limit += POSDIFF(completed, dql->prev_num_queued) +
+		     dql->prev_ovlimit;
+		dql->slack_start_time = jiffies;
+		dql->lowest_slack = -1UL;
+	} else if (inprogress && prev_inprogress && !all_prev_completed) {
+		/*
+		 * Queue was not starved, check if the limit can be decreased.
+		 * A decrease is only considered if the queue has been busy in
+		 * the whole interval (the check above).
+		 *
+		 * If there is slack, the amount of execess data queued above
+		 * the the amount needed to prevent starvation, the queue limit
+		 * can be decreased.  To avoid hysteresis we consider the
+		 * minimum amount of slack found over several iterations of the
+		 * completion routine.
+		 */
+		unsigned long slack, slack_last_objs;
+
+		/*
+		 * Slack is the maximum of
+		 *   - The queue limit plus previous over-limit minus twice
+		 *     the number of objects completed.  Note that two times
+		 *     number of completed bytes is a basis for an upper bound
+		 *     of the limit.
+		 *   - Portion of objects in the last queuing operation that
+		 *     was not part of non-zero previous over-limit.  That is
+		 *     "round down" by non-overlimit portion of the last
+		 *     queueing operation.
+		 */
+		slack = POSDIFF(limit + dql->prev_ovlimit,
+		    2 * (completed - dql->num_completed));
+		slack_last_objs = dql->prev_ovlimit ?
+		    POSDIFF(dql->prev_last_obj_cnt, dql->prev_ovlimit) : 0;
+
+		slack = max(slack, slack_last_objs);
+
+		if (slack < dql->lowest_slack)
+			dql->lowest_slack = slack;
+
+		if (time_after(jiffies,
+			       dql->slack_start_time + dql->slack_hold_time)) {
+			limit = POSDIFF(limit, dql->lowest_slack);
+			dql->slack_start_time = jiffies;
+			dql->lowest_slack = -1UL;
+		}
+	}
+
+	/* Enforce bounds on limit */
+	limit = clamp(limit, dql->min_limit, dql->max_limit);
+
+	if (limit != dql->limit) {
+		dql->limit = limit;
+		ovlimit = 0;
+	}
+
+	dql->prev_ovlimit = ovlimit;
+	dql->prev_last_obj_cnt = dql->last_obj_cnt;
+	dql->num_completed = completed;
+	dql->prev_num_queued = dql->num_queued;
+}
+EXPORT_SYMBOL(dql_completed);
+
+void dql_reset(struct dql *dql)
+{
+	/* Reset all dynamic values */
+	dql->limit = 0;
+	dql->num_queued = 0;
+	dql->num_completed = 0;
+	dql->last_obj_cnt = 0;
+	dql->prev_num_queued = 0;
+	dql->prev_last_obj_cnt = 0;
+	dql->prev_ovlimit = 0;
+	dql->lowest_slack = -1UL;
+	dql->slack_start_time = jiffies;
+}
+EXPORT_SYMBOL(dql_reset);
+
+int dql_init(struct dql *dql, unsigned hold_time)
+{
+	dql->max_limit = DQL_MAX_LIMIT;
+	dql->min_limit = 0;
+	dql->slack_hold_time = hold_time;
+	dql_reset(dql);
+	return 0;
+}
+EXPORT_SYMBOL(dql_init);
-- 
1.7.3.1
