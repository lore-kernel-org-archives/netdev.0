From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH v2 net-next 6/8] net/ncsi: Rework the channel monitoring
Date: Tue,  4 Oct 2016 11:25:52 +1100
Message-ID: <1475540754-31169-7-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: davem@davemloft.net, joel@jms.id.au, yuvali@mellanox.com,
        benh@kernel.crashing.org, Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39759 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751399AbcJDAZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 20:25:28 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u940MruP026200
        for <netdev@vger.kernel.org>; Mon, 3 Oct 2016 20:25:28 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25uy9hw1es-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2016 20:25:27 -0400
Received: from localhost
        by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Tue, 4 Oct 2016 10:25:25 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
        by d23dlp01.au.ibm.com (Postfix) with ESMTP id DCB122CE805A
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 11:25:22 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u940PMiI197050
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u940PMTf003720
        for <netdev@vger.kernel.org>; Tue, 4 Oct 2016 11:25:22 +1100
In-Reply-To: <1475540754-31169-1-git-send-email-gwshan@linux.vnet.ibm.com>
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
 net/ncsi/ncsi-manage.c | 44 +++++++++++++++++++++++++-------------------
 net/ncsi/ncsi-rsp.c    |  2 +-
 3 files changed, 35 insertions(+), 23 deletions(-)

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
index adf5401..4742c7c 100644
--- a/net/ncsi/ncsi-manage.c
+++ b/net/ncsi/ncsi-manage.c
@@ -172,15 +172,15 @@ static void ncsi_channel_monitor(unsigned long data)
 	struct ncsi_dev_priv *ndp = np->ndp;
 	struct ncsi_cmd_arg nca;
 	bool enabled, chained;
-	unsigned int timeout;
+	unsigned int monitor_state;
 	unsigned long flags;
 	int state, ret;
 
 	spin_lock_irqsave(&nc->lock, flags);
 	state = nc->state;
 	chained = !list_empty(&nc->link);
-	timeout = nc->timeout;
-	enabled = nc->enabled;
+	enabled = nc->monitor.enabled;
+	monitor_state = nc->monitor.state;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
 	if (!enabled || chained)
@@ -189,7 +189,9 @@ static void ncsi_channel_monitor(unsigned long data)
 	    state != NCSI_CHANNEL_ACTIVE)
 		return;
 
-	if (!(timeout % 2)) {
+	switch (monitor_state) {
+	case NCSI_CHANNEL_MONITOR_START:
+	case NCSI_CHANNEL_MONITOR_RETRY:
 		nca.ndp = ndp;
 		nca.package = np->id;
 		nca.channel = nc->id;
@@ -201,12 +203,16 @@ static void ncsi_channel_monitor(unsigned long data)
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
-		    state == NCSI_CHANNEL_ACTIVE)
+		    state == NCSI_CHANNEL_ACTIVE) {
 			ncsi_report_link(ndp, true);
+			ndp->flags |= NCSI_DEV_RESHUFFLE;
+		}
 
 		spin_lock_irqsave(&nc->lock, flags);
 		nc->state = NCSI_CHANNEL_INVISIBLE;
@@ -221,10 +227,9 @@ static void ncsi_channel_monitor(unsigned long data)
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
@@ -232,12 +237,12 @@ void ncsi_start_channel_monitor(struct ncsi_channel *nc)
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
@@ -245,14 +250,14 @@ void ncsi_stop_channel_monitor(struct ncsi_channel *nc)
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
@@ -281,8 +286,9 @@ struct ncsi_channel *ncsi_add_channel(struct ncsi_package *np, unsigned char id)
 	nc->id = id;
 	nc->package = np;
 	nc->state = NCSI_CHANNEL_INACTIVE;
-	nc->enabled = false;
-	setup_timer(&nc->timer, ncsi_channel_monitor, (unsigned long)nc);
+	nc->monitor.enabled = false;
+	setup_timer(&nc->monitor.timer,
+		    ncsi_channel_monitor, (unsigned long)nc);
 	spin_lock_init(&nc->lock);
 	INIT_LIST_HEAD(&nc->link);
 	for (index = 0; index < NCSI_CAP_MAX; index++)
diff --git a/net/ncsi/ncsi-rsp.c b/net/ncsi/ncsi-rsp.c
index 86cdaeb..087db77 100644
--- a/net/ncsi/ncsi-rsp.c
+++ b/net/ncsi/ncsi-rsp.c
@@ -322,7 +322,7 @@ static int ncsi_rsp_handler_gls(struct ncsi_request *nr)
 
 	/* Reset the channel monitor if it has been enabled */
 	spin_lock_irqsave(&nc->lock, flags);
-	nc->timeout = 0;
+	nc->monitor.state = NCSI_CHANNEL_MONITOR_START;
 	spin_unlock_irqrestore(&nc->lock, flags);
 
 	return 0;
-- 
2.1.0
