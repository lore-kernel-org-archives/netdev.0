From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 2/4] bql: Add tracking of inflight packets
Date: Tue, 30 Aug 2016 17:00:32 -0700
Message-ID: <1472601634-531498-3-git-send-email-tom@herbertland.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45666 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752233AbcHaABI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:01:08 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7UNt3RP014465
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 255juj0se6-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:44 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 f61e4f006f0d11e68b750002c9dfb610-d23f8aa0 for <netdev@vger.kernel.org>;        Tue,
 30 Aug 2016 17:00:43 -0700
In-Reply-To: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two fields to netdev_queue as head_cnt and tail_cnt. head_cnt is
incremented for every sent packet in netdev_tx_sent_queue and tail_cnt
is incremented by the number of packets in netdev_tx_completed_queue.
So then the number of inflight packets for a queue is simply
queue->head_cnt - queue->tail_cnt.

Add inflight_pkts to be reported in sys-fs.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h |  4 ++++
 net/core/net-sysfs.c      | 11 +++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d122be9..487d1df 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -592,6 +592,8 @@ struct netdev_queue {
 
 #ifdef CONFIG_BQL
 	struct dql		dql;
+	unsigned int		head_cnt;
+	unsigned int		tail_cnt;
 #endif
 } ____cacheline_aligned_in_smp;
 
@@ -2958,6 +2960,7 @@ static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
 					unsigned int bytes)
 {
 #ifdef CONFIG_BQL
+	dev_queue->head_cnt++;
 	dql_queued(&dev_queue->dql, bytes);
 
 	if (likely(dql_avail(&dev_queue->dql) >= 0))
@@ -2999,6 +3002,7 @@ static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
 	if (unlikely(!bytes))
 		return;
 
+	dev_queue->tail_cnt += pkts;
 	dql_completed(&dev_queue->dql, bytes);
 
 	/*
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6e4f347..5a33f6a 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1147,6 +1147,16 @@ static ssize_t bql_show_inflight(struct netdev_queue *queue,
 static struct netdev_queue_attribute bql_inflight_attribute =
 	__ATTR(inflight, S_IRUGO, bql_show_inflight, NULL);
 
+static ssize_t bql_show_inflight_pkts(struct netdev_queue *queue,
+				      struct netdev_queue_attribute *attr,
+				      char *buf)
+{
+	return sprintf(buf, "%u\n", queue->head_cnt - queue->tail_cnt);
+}
+
+static struct netdev_queue_attribute bql_inflight_pkts_attribute =
+	__ATTR(inflight_pkts, S_IRUGO, bql_show_inflight_pkts, NULL);
+
 #define BQL_ATTR(NAME, FIELD)						\
 static ssize_t bql_show_ ## NAME(struct netdev_queue *queue,		\
 				 struct netdev_queue_attribute *attr,	\
@@ -1176,6 +1186,7 @@ static struct attribute *dql_attrs[] = {
 	&bql_limit_min_attribute.attr,
 	&bql_hold_time_attribute.attr,
 	&bql_inflight_attribute.attr,
+	&bql_inflight_pkts_attribute.attr,
 	NULL
 };
 
-- 
2.8.0.rc2
