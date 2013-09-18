From: Noel Burton-Krahn <noel@burton-krahn.com>
Subject: [PATCH 1/1] mrp: add periodictimer to allow retries when packets get lost
Date: Wed, 18 Sep 2013 12:24:40 -0700
Message-ID: <1379532280-11047-1-git-send-email-noel@burton-krahn.com>
References: <1379528419.1787.50.camel@joe-AO722>
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Noel Burton-Krahn <noel@burton-krahn.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43641 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562Ab3IRTZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 15:25:24 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so7423905pdj.25
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 12:25:23 -0700 (PDT)
In-Reply-To: <1379528419.1787.50.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MRP doesn't implement the periodictimer in 802.1Q, so it never retries
if packets get lost.  I ran into this problem when MRP sent a MVRP
JoinIn before the interface was fully up.  The JoinIn was lost, MRP
didn't retry, and MVRP registration failed.

Tested against Juniper QFabric switches

Signed-off-by: Noel Burton-Krahn <noel@burton-krahn.com>
---
 include/net/mrp.h |    1 +
 net/802/mrp.c     |   27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/net/mrp.h b/include/net/mrp.h
index 4fbf02a..0f7558b 100644
--- a/include/net/mrp.h
+++ b/include/net/mrp.h
@@ -112,6 +112,7 @@ struct mrp_applicant {
 	struct mrp_application	*app;
 	struct net_device	*dev;
 	struct timer_list	join_timer;
+	struct timer_list	periodic_timer;
 
 	spinlock_t		lock;
 	struct sk_buff_head	queue;
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 1eb05d8..3ed6162 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -24,6 +24,11 @@
 static unsigned int mrp_join_time __read_mostly = 200;
 module_param(mrp_join_time, uint, 0644);
 MODULE_PARM_DESC(mrp_join_time, "Join time in ms (default 200ms)");
+
+static unsigned int mrp_periodic_time __read_mostly = 1000;
+module_param(mrp_periodic_time, uint, 0644);
+MODULE_PARM_DESC(mrp_periodic_time, "Periodic time in ms (default 1s)");
+
 MODULE_LICENSE("GPL");
 
 static const u8
@@ -595,6 +600,24 @@ static void mrp_join_timer(unsigned long data)
 	mrp_join_timer_arm(app);
 }
 
+static void mrp_periodic_timer_arm(struct mrp_applicant *app)
+{
+	mod_timer(&app->periodic_timer,
+		  jiffies + msecs_to_jiffies(mrp_periodic_time));
+}
+
+static void mrp_periodic_timer(unsigned long data)
+{
+	struct mrp_applicant *app = (struct mrp_applicant *)data;
+
+	spin_lock(&app->lock);
+	mrp_mad_event(app, MRP_EVENT_PERIODIC);
+	mrp_pdu_queue(app);
+	spin_unlock(&app->lock);
+
+	mrp_periodic_timer_arm(app);
+}
+
 static int mrp_pdu_parse_end_mark(struct sk_buff *skb, int *offset)
 {
 	__be16 endmark;
@@ -845,6 +868,9 @@ int mrp_init_applicant(struct net_device *dev, struct mrp_application *appl)
 	rcu_assign_pointer(dev->mrp_port->applicants[appl->type], app);
 	setup_timer(&app->join_timer, mrp_join_timer, (unsigned long)app);
 	mrp_join_timer_arm(app);
+	setup_timer(&app->periodic_timer, mrp_periodic_timer,
+		    (unsigned long)app);
+	mrp_periodic_timer_arm(app);
 	return 0;
 
 err3:
@@ -870,6 +896,7 @@ void mrp_uninit_applicant(struct net_device *dev, struct mrp_application *appl)
 	 * all pending messages before the applicant is gone.
 	 */
 	del_timer_sync(&app->join_timer);
+	del_timer_sync(&app->periodic_timer);
 
 	spin_lock_bh(&app->lock);
 	mrp_mad_event(app, MRP_EVENT_TX);
-- 
1.7.9.5
