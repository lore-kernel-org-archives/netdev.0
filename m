From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH net-next 6/8] net/ncsi: Rework the channel monitoring
Date: Thu, 29 Sep 2016 15:03:13 +1000
Message-ID: <1475125395-8459-7-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:55352 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753297AbcI2FDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 01:03:20 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8T53IkO139120
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:19 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25rrts1dhn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:03:18 -0400
Received: from localhost
        by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 29 Sep 2016 15:03:10 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
        by d23dlp02.au.ibm.com (Postfix) with ESMTP id A13EA2BB0059
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8T537vF65011788
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
        by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8T536Ha021759
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 15:03:07 +1000
In-Reply-To: <1475125395-8459-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original NCSI channel monitoring was implemented based on a
backoff algorithm: the GLS response should be received in the
specified interval. Otherwise, the channel is regarded as dead
and failover should be taken if current channel is an active one.
There are several problems in the implementation: (A) On BCM5718,
we found when the IID (Instance ID) in the GLS command packet
changes from 255 to 1, the response corresponding to IID#1 never
comes in. It means we cannot make the unfair judgement that the
channel is dead when one response is missed. (B) The code's
readability should be improved. (C) We should do failover when
current channel is active one and the channel monitoring should
be marked as disabled before doing failover.

This reworks the channel monitoring to address all above issues.
The fields for channel monitoring is put into separate struct
and the state of channel monitoring is predefined. The channel
is regarded alive if the network controller responses to one of
two GLS commands or both of them in 5 seconds.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
Reviewed-by: Joel Stanley <joel@jms.id.au>
---
 net/ncsi/internal.h    | 12 +++++++++---
 net/ncsi/ncsi-manage.c | 46 ++++++++++++++++++++++++++--------------------
 net/ncsi/ncsi-rsp.c    |  2 +-
 3 files changed, 36 insertions(+), 24 deletions(-)

diff --git a/net/ncsi/internal.h b/net/ncsi/internal.h
index 26e9295..13290a7 100644
--- a/net/ncsi/internal.h
+++ b/net/ncsi/internal.h
@@ -187,9 +187,15 @@ struct ncsi_channel {
 	struct ncsi_channel_mode    modes[NCSI_MODE_MAX];
 	struct ncsi_channel_filter  *filters[NCSI_FILTER_MAX];
 	struct ncsi_channel_stats   stats;
-	struct timer_list           timer;	/* Link monitor timer  */
-	bool                        enabled;	/* Timer is enabled    */
-	unsigned int                timeout;	/* Times of timeout    */
+	struct {
+		struct timer_list   timer;
+		bool                enabled;
+		unsigned int        state;
+#define NCSI_CHANNEL_MONITOR_START	0
+#define NCSI_CHANNEL_MONITOR_RETRY	1
+#define NCSI_CHANNEL_MONITOR_WAIT	2
+#define NCSI_CHANNEL_MONITOR_WAIT_MAX	5
+	} monitor;
 	struct list_head            node;
 	struct list_head            link;
 };
diff --git a/net/ncsi/ncsi-manage.c b/net/ncsi/ncsi-manage.c
index 41d6af9..1b797c9 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -164,13 +164,13 @@ static void ncsi_channel_monitor(unsigned long data)
 	struct ncsi_dev_priv *ndp = np->ndp;
 	struct ncsi_cmd_arg nca;
 	bool enabled;
-	unsigned int timeout;
+	unsigned int monitor_state;
 	unsigned long flags;
 	int old_state, ret;
 
 	spin_lock_irqsave(&nc->lock, flags);
-	timeout = nc->timeout;
-	enabled = nc->enabled;
+	enabled = nc->monitor.enabled;
+	monitor_state = nc->monitor.state;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
 	if (!enabled || !list_empty(&nc->link))
@@ -181,7 +181,9 @@ static void ncsi_channel_monitor(unsigned long data)
 	    old_state != NCSI_CHANNEL_ACTIVE)
 		return;
 
-	if (!(timeout % 2)) {
+	switch (monitor_state) {
+	case NCSI_CHANNEL_MONITOR_START:
+	case NCSI_CHANNEL_MONITOR_RETRY:
 		nca.ndp = ndp;
 		nca.package = np->id;
 		nca.channel = nc->id;
@@ -193,14 +195,18 @@ static void ncsi_channel_monitor(unsigned long data)
 				   ret);
 			return;
 		}
-	}
 
-	if (timeout + 1 >= 3) {
+		break;
+	case NCSI_CHANNEL_MONITOR_WAIT ... NCSI_CHANNEL_MONITOR_WAIT_MAX:
+		break;
+	default:
 		if (!(ndp->flags & NCSI_DEV_HWA) &&
-		    old_state == NCSI_CHANNEL_ACTIVE)
+		    old_state == NCSI_CHANNEL_ACTIVE) {
 			ncsi_report_link(ndp, true);
+			ndp->flags |= NCSI_DEV_RESHUFFLE;
+		}
 
-		WRITE_ONCE(nc->state, NCSI_CHANNEL_INACTIVE);
+		WRITE_ONCE(nc->state, NCSI_CHANNEL_ACTIVE);
 		spin_lock_irqsave(&ndp->lock, flags);
 		list_add_tail_rcu(&nc->link, &ndp->channel_queue);
 		spin_unlock_irqrestore(&ndp->lock, flags);
@@ -209,10 +215,9 @@ static void ncsi_channel_monitor(unsigned long data)
 	}
 
 	spin_lock_irqsave(&nc->lock, flags);
-	nc->timeout = timeout + 1;
-	nc->enabled = true;
+	nc->monitor.state++;
 	spin_unlock_irqrestore(&nc->lock, flags);
-	mod_timer(&nc->timer, jiffies + HZ * (1 << (nc->timeout / 2)));
+	mod_timer(&nc->monitor.timer, jiffies + HZ);
 }
 
 void ncsi_start_channel_monitor(struct ncsi_channel *nc)
@@ -220,12 +225,12 @@ void ncsi_start_channel_monitor(struct ncsi_channel *nc)
 	unsigned long flags;
 
 	spin_lock_irqsave(&nc->lock, flags);
-	WARN_ON_ONCE(nc->enabled);
-	nc->timeout = 0;
-	nc->enabled = true;
+	WARN_ON_ONCE(nc->monitor.enabled);
+	nc->monitor.enabled = true;
+	nc->monitor.state = NCSI_CHANNEL_MONITOR_START;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
-	mod_timer(&nc->timer, jiffies + HZ * (1 << (nc->timeout / 2)));
+	mod_timer(&nc->monitor.timer, jiffies + HZ);
 }
 
 void ncsi_stop_channel_monitor(struct ncsi_channel *nc)
@@ -233,14 +238,14 @@ void ncsi_stop_channel_monitor(struct ncsi_channel *nc)
 	unsigned long flags;
 
 	spin_lock_irqsave(&nc->lock, flags);
-	if (!nc->enabled) {
+	if (!nc->monitor.enabled) {
 		spin_unlock_irqrestore(&nc->lock, flags);
 		return;
 	}
-	nc->enabled = false;
+	nc->monitor.enabled = false;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
-	del_timer_sync(&nc->timer);
+	del_timer_sync(&nc->monitor.timer);
 }
 
 struct ncsi_channel *ncsi_find_channel(struct ncsi_package *np,
@@ -269,8 +274,9 @@ struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
 	nc->id = id;
 	nc->package = np;
 	WRITE_ONCE(nc->state, NCSI_CHANNEL_INACTIVE);
-	nc->enabled = false;
-	setup_timer(&nc->timer, ncsi_channel_monitor, (unsigned long)nc);
+	nc->monitor.enabled = false;
+	setup_timer(&nc->monitor.timer,
+		    ncsi_channel_monitor, (unsigned long)nc);
 	spin_lock_init(&nc->lock);
 	INIT_LIST_HEAD(&nc->link);
 	for (index = 0; index < NCSI_CAP_MAX; index++)
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 5143490..1618eda 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -315,7 +315,7 @@ static int ncsi_rsp_handler_gls(struct ncsi_request *nr)
 
 	/* Reset the channel monitor if it has been enabled */
 	spin_lock_irqsave(&nc->lock, flags);
-	nc->timeout = 0;
+	nc->monitor.state = NCSI_CHANNEL_MONITOR_START;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
 	return 0;
-- 
2.1.0
