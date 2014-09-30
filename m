From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 05:51:25 -0700
Message-ID: <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140930085114.24043.81310.stgit@dragon>
	 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64307 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaI3Mv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:51:29 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so7391802pdj.13
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 05:51:28 -0700 (PDT)
In-Reply-To: <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Add a new dql attribute, to control how much packets we are allowed to
burst from qdisc to device.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Jesper, please consider using this instead of 7 or 8 values you hard coded.

 include/linux/dynamic_queue_limits.h |    1 
 lib/dynamic_queue_limits.c           |    1 
 net/core/net-sysfs.c                 |   31 +++++++++++++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/include/linux/dynamic_queue_limits.h b/include/linux/dynamic_queue_limits.h
index a4be70398ce1..8509053eb330 100644
--- a/include/linux/dynamic_queue_limits.h
+++ b/include/linux/dynamic_queue_limits.h
@@ -42,6 +42,7 @@ struct dql {
 	unsigned int	num_queued;		/* Total ever queued */
 	unsigned int	adj_limit;		/* limit + num_completed */
 	unsigned int	last_obj_cnt;		/* Count at last queuing */
+	unsigned int	burst;
 
 	/* Fields accessed only by completion path (dql_completed) */
 
diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
index 0777c5a45fa0..acc0d6105191 100644
--- a/lib/dynamic_queue_limits.c
+++ b/lib/dynamic_queue_limits.c
@@ -132,6 +132,7 @@ int dql_init(struct dql *dql, unsigned hold_time)
 	dql->max_limit = DQL_MAX_LIMIT;
 	dql->min_limit = 0;
 	dql->slack_hold_time = hold_time;
+	dql->burst = 7;
 	dql_reset(dql);
 	return 0;
 }
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 9dd06699b09c..80cf6f166706 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -978,6 +978,36 @@ static struct netdev_queue_attribute bql_hold_time_attribute =
 	__ATTR(hold_time, S_IRUGO | S_IWUSR, bql_show_hold_time,
 	    bql_set_hold_time);
 
+static ssize_t bql_show_burst(struct netdev_queue *queue,
+			      struct netdev_queue_attribute *attr,
+			      char *buf)
+{
+	const struct dql *dql = &queue->dql;
+
+	return sprintf(buf, "%u\n", dql->burst);
+}
+
+static ssize_t bql_set_burst(struct netdev_queue *queue,
+			     struct netdev_queue_attribute *attribute,
+			     const char *buf, size_t len)
+{
+	struct dql *dql = &queue->dql;
+	unsigned int value;
+	int err;
+
+	err = kstrtouint(buf, 10, &value);
+	if (err < 0)
+		return err;
+
+	dql->burst = value;
+
+	return len;
+}
+
+static struct netdev_queue_attribute bql_burst_attribute =
+	__ATTR(burst, S_IRUGO | S_IWUSR, bql_show_burst,
+	    bql_set_burst);
+
 static ssize_t bql_show_inflight(struct netdev_queue *queue,
 				 struct netdev_queue_attribute *attr,
 				 char *buf)
@@ -1019,6 +1049,7 @@ static struct attribute *dql_attrs[] = {
 	&bql_limit_min_attribute.attr,
 	&bql_hold_time_attribute.attr,
 	&bql_inflight_attribute.attr,
+	&bql_burst_attribute.attr,
 	NULL
 };
 
