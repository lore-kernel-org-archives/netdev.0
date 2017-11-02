From: Allen Pais <allen.pais@oracle.com>
Subject: [PATCH 2/2] net: bridge: Convert timers to use timer_setup()
Date: Thu,  2 Nov 2017 10:58:51 +0530
Message-ID: <1509600531-16086-2-git-send-email-allen.pais@oracle.com>
References: <1509600531-16086-1-git-send-email-allen.pais@oracle.com>
Cc: davem@davemloft.net, keescook@chromium.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        Allen Pais <allen.pais@oracle.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18214 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdKBF3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 01:29:16 -0400
In-Reply-To: <1509600531-16086-1-git-send-email-allen.pais@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

switch to using the new timer_setup() and from_timer() api's.

Signed-off-by: Allen Pais <allen.pais@oracle.com>
---
 net/bridge/br_stp_timer.c | 48 +++++++++++++++++++----------------------------
 1 file changed, 19 insertions(+), 29 deletions(-)

diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 60b6fe2..0e68790 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -31,9 +31,9 @@ static int br_is_designated_for_some_port(const struct net_bridge *br)
 	return 0;
 }
 
-static void br_hello_timer_expired(unsigned long arg)
+static void br_hello_timer_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (struct net_bridge *)arg;
+	struct net_bridge *br = from_timer(br, t, hello_timer);
 
 	br_debug(br, "hello timer expired\n");
 	spin_lock(&br->lock);
@@ -47,9 +47,9 @@ static void br_hello_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_message_age_timer_expired(unsigned long arg)
+static void br_message_age_timer_expired(struct timer_list *t)
 {
-	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge_port *p = from_timer(p, t, message_age_timer);
 	struct net_bridge *br = p->br;
 	const bridge_id *id = &p->designated_bridge;
 	int was_root;
@@ -80,9 +80,9 @@ static void br_message_age_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_forward_delay_timer_expired(unsigned long arg)
+static void br_forward_delay_timer_expired(struct timer_list *t)
 {
-	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge_port *p = from_timer(p, t, forward_delay_timer);
 	struct net_bridge *br = p->br;
 
 	br_debug(br, "port %u(%s) forward delay timer\n",
@@ -104,9 +104,9 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_tcn_timer_expired(unsigned long arg)
+static void br_tcn_timer_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (struct net_bridge *) arg;
+	struct net_bridge *br = from_timer(br, t, tcn_timer);
 
 	br_debug(br, "tcn timer expired\n");
 	spin_lock(&br->lock);
@@ -118,9 +118,9 @@ static void br_tcn_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_topology_change_timer_expired(unsigned long arg)
+static void br_topology_change_timer_expired(struct timer_list *t)
 {
-	struct net_bridge *br = (struct net_bridge *) arg;
+	struct net_bridge *br = from_timer(br, t, topology_change_timer);
 
 	br_debug(br, "topo change timer expired\n");
 	spin_lock(&br->lock);
@@ -129,9 +129,9 @@ static void br_topology_change_timer_expired(unsigned long arg)
 	spin_unlock(&br->lock);
 }
 
-static void br_hold_timer_expired(unsigned long arg)
+static void br_hold_timer_expired(struct timer_list *t)
 {
-	struct net_bridge_port *p = (struct net_bridge_port *) arg;
+	struct net_bridge_port *p = from_timer(p, t, hold_timer);
 
 	br_debug(p->br, "port %u(%s) hold timer expired\n",
 		 (unsigned int) p->port_no, p->dev->name);
@@ -144,27 +144,17 @@ static void br_hold_timer_expired(unsigned long arg)
 
 void br_stp_timer_init(struct net_bridge *br)
 {
-	setup_timer(&br->hello_timer, br_hello_timer_expired,
-		      (unsigned long) br);
-
-	setup_timer(&br->tcn_timer, br_tcn_timer_expired,
-		      (unsigned long) br);
-
-	setup_timer(&br->topology_change_timer,
-		      br_topology_change_timer_expired,
-		      (unsigned long) br);
+	timer_setup(&br->hello_timer, br_hello_timer_expired, 0);
+	timer_setup(&br->tcn_timer, br_tcn_timer_expired, 0);
+	timer_setup(&br->topology_change_timer,
+		    br_topology_change_timer_expired, 0);
 }
 
 void br_stp_port_timer_init(struct net_bridge_port *p)
 {
-	setup_timer(&p->message_age_timer, br_message_age_timer_expired,
-		      (unsigned long) p);
-
-	setup_timer(&p->forward_delay_timer, br_forward_delay_timer_expired,
-		      (unsigned long) p);
-
-	setup_timer(&p->hold_timer, br_hold_timer_expired,
-		      (unsigned long) p);
+	timer_setup(&p->message_age_timer, br_message_age_timer_expired, 0);
+	timer_setup(&p->forward_delay_timer, br_forward_delay_timer_expired, 0);
+	timer_setup(&p->hold_timer, br_hold_timer_expired, 0);
 }
 
 /* Report ticks left (in USER_HZ) used for API */
-- 
1.9.1
