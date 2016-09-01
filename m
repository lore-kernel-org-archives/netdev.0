From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/4] dql: Add counters for number of queuing and completion operations
Date: Wed, 31 Aug 2016 17:10:03 -0700
Message-ID: <1472688605-2613704-3-git-send-email-tom@herbertland.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50997 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754224AbcIAAKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 20:10:24 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8108lNG032700
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2564kytrb2-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:23 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 79b890306fd811e695200002c99331b0-4bde0a50 for <netdev@vger.kernel.org>;        Wed,
 31 Aug 2016 17:10:22 -0700
In-Reply-To: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two new counters to struct dql that are num_enqueue_ops and
num_completed_ops. num_enqueue_ops is incremented by one in each call to
dql_queued. num_enqueue_ops is incremented in dql_completed which takes
an argument indicating number of operations completed. These counters
are only intended for statistics and do not impact the BQL algorithm.

We add a new sysfs entry in byte_queue_limits named inflight_pkts.
This provides the number of packets in flight for the queue by
dql->num_enqueue_ops - dql->num_completed_ops.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/dynamic_queue_limits.h |  7 ++++++-
 include/linux/netdevice.h            |  2 +-
 lib/dynamic_queue_limits.c           |  3 ++-
 net/core/net-sysfs.c                 | 14 ++++++++++++++
 4 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
index a4be703..b6a4804 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -43,6 +43,8 @@ struct dql {
 	unsigned int	adj_limit;		/* limit + num_completed */
 	unsigned int	last_obj_cnt;		/* Count at last queuing */
 
+	unsigned int	num_enqueue_ops;	/* Number of queue operations */
+
 	/* Fields accessed only by completion path (dql_completed) */
 
 	unsigned int	limit ____cacheline_aligned_in_smp; /* Current limit */
@@ -55,6 +57,8 @@ struct dql {
 	unsigned int	lowest_slack;		/* Lowest slack found */
 	unsigned long	slack_start_time;	/* Time slacks seen */
 
+	unsigned int	num_completed_ops;	/* Number of complete ops */
+
 	/* Configuration */
 	unsigned int	max_limit;		/* Max limit */
 	unsigned int	min_limit;		/* Minimum limit */
@@ -83,6 +87,7 @@ static inline void dql_queued(struct dql *dql, unsigned int count)
 	barrier();
 
 	dql->num_queued += count;
+	dql->num_enqueue_ops++;
 }
 
 /* Returns how many objects can be queued, < 0 indicates over limit. */
@@ -92,7 +97,7 @@ static inline int dql_avail(const struct dql *dql)
 }
 
 /* Record number of completed objects and recalculate the limit. */
-void dql_completed(struct dql *dql, unsigned int count);
+void dql_completed(struct dql *dql, unsigned int count, unsigned int ops);
 
 /* Reset dql state */
 void dql_reset(struct dql *dql);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d122be9..0d1d748 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2999,7 +2999,7 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 	if (unlikely(!bytes))
 		return;
 
-	dql_completed(&dev_queue->dql, bytes);
+	dql_completed(&dev_queue->dql, bytes, pkts);
 
 	/*
 	 * Without the memory barrier there is a small possiblity that
diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index f346715..d5e7a27 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -14,7 +14,7 @@
 #define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
 
 /* Records completed count and recalculates the queue limit */
-void dql_completed(struct dql *dql, unsigned int count)
+void dql_completed(struct dql *dql, unsigned int count, unsigned int ops)
 {
 	unsigned int inprogress, prev_inprogress, limit;
 	unsigned int ovlimit, completed, num_queued;
@@ -108,6 +108,7 @@ void dql_completed(struct dql *dql, unsigned int count)
 	dql->prev_ovlimit = ovlimit;
 	dql->prev_last_obj_cnt = dql->last_obj_cnt;
 	dql->num_completed = completed;
+	dql->num_completed_ops += ops;
 	dql->prev_num_queued = num_queued;
 }
 EXPORT_SYMBOL(dql_completed);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6e4f347..ab7b0b6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1147,6 +1147,19 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 static struct netdev_queue_attribute bql_inflight_attribute =
 	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
 
+static ssize_t bql_show_inflight_pkts(struct netdev_queue *queue,
+				      struct netdev_queue_attribute *attr,
+				      char *buf)
+{
+	struct dql *dql = &queue->dql;
+
+	return sprintf(buf, "%u\n",
+		       dql->num_enqueue_ops - dql->num_completed_ops);
+}
+
+static struct netdev_queue_attribute bql_inflight_pkts_attribute =
+	__ATTR(inflight_pkts, S_IRUGO, bql_show_inflight_pkts, NULL);
+
 #define BQL_ATTR(NAME, FIELD)						\
 static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
 				 struct netdev_queue_attribute *attr,	\
@@ -1176,6 +1189,7 @@ static struct attribute *dql_attrs[] = {
 	&bql_limit_min_attribute.attr,
 	&bql_hold_time_attribute.attr,
 	&bql_inflight_attribute.attr,
+	&bql_inflight_pkts_attribute.attr,
 	NULL
 };
 
-- 
2.8.0.rc2
