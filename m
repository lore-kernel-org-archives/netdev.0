From: Noel Burton-Krahn <noel@burton-krahn.com>
Subject: [PATCH] mrp: add periodictimer to retry lost packets
Date: Wed, 18 Sep 2013 10:09:25 -0700
Message-ID: <CAB5uXS7b2CGjF=1OTzCmEeduGHSO_SOmMDv6=-bZU2VzaEQNfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:37474 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741Ab3IRRJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 13:09:26 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so4785520qcz.0
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 10:09:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MRP doesn't implement the periodictimer in 802.1Q, so it never retries
if packets get lost.  I ran into this problem when MRP sent a MVRP
JoinIn before the interface was fully up.  The JoinIn was lost, MRP
didn't retry, and MVRP registration failed.

(Sorry for the repost, my earlier message wasn't formatted correctly)

Cheers,
--
Noel

diff --git a/include/net/mrp.h b/include/net/mrp.h
index 4fbf02a..0f7558b 100644
--- a/include/net/mrp.h
+++ b/include/net/mrp.h
@@ -112,6 +112,7 @@ struct mrp_applicant {
     struct mrp_application    *app;
     struct net_device    *dev;
     struct timer_list    join_timer;
+    struct timer_list    periodic_timer;

     spinlock_t        lock;
     struct sk_buff_head    queue;
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 1eb05d8..edcd458 100644
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
@@ -595,6 +600,26 @@ static void mrp_join_timer(unsigned long data)
     mrp_join_timer_arm(app);
 }

+static void mrp_periodic_timer_arm(struct mrp_applicant *app)
+{
+    unsigned long delay;
+
+    delay = (u64)msecs_to_jiffies(mrp_periodic_time);
+    mod_timer(&app->periodic_timer, jiffies + delay);
+}
+
+static void mrp_periodic_timer(unsigned long data)
+{
+    struct mrp_applicant *app = (struct mrp_applicant *)data;
+
+    spin_lock(&app->lock);
+    mrp_mad_event(app, MRP_EVENT_PERIODIC);
+    mrp_pdu_queue(app);
+    spin_unlock(&app->lock);
+
+    mrp_periodic_timer_arm(app);
+}
+
 static int mrp_pdu_parse_end_mark(struct sk_buff *skb, int *offset)
 {
     __be16 endmark;
@@ -845,6 +870,9 @@ int mrp_init_applicant(struct net_device *dev,
struct mrp_application *appl)
     rcu_assign_pointer(dev->mrp_port->applicants[appl->type], app);
     setup_timer(&app->join_timer, mrp_join_timer, (unsigned long)app);
     mrp_join_timer_arm(app);
+    setup_timer(&app->periodic_timer, mrp_periodic_timer,
+            (unsigned long)app);
+    mrp_periodic_timer_arm(app);
     return 0;

 err3:
@@ -870,6 +898,7 @@ void mrp_uninit_applicant(struct net_device *dev,
struct mrp_application *appl)
      * all pending messages before the applicant is gone.
      */
     del_timer_sync(&app->join_timer);
+    del_timer_sync(&app->periodic_timer);

     spin_lock_bh(&app->lock);
     mrp_mad_event(app, MRP_EVENT_TX);
