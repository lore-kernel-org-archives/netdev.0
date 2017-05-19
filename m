From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH net-next v2] bridge: fix hello and hold timers starting/stopping
Date: Fri, 19 May 2017 19:30:43 +0200
Message-ID: <20170519173043.10201-1-cera@cera.cz>
Cc: davem@davemloft.net, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        lucien.xin@gmail.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33773 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750748AbdESRax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 13:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current bridge code incorrectly handles starting/stopping of hello and
hold timers during STP enable/disable.

1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
   transition. The timers are already stopped in NO_STP state so
   this is confusing no-op.

2. During USER_STP->NO_STP transition the timers are started. This
   does not make sense and is confusion because the timer should not be
   active in NO_STP state.

Cc: davem@davemloft.net
Cc: sashok@cumulusnetworks.com
Cc: stephen@networkplumber.org
Cc: bridge@lists.linux-foundation.org
Cc: lucien.xin@gmail.com
Cc: nikolay@cumulusnetworks.com
Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 net/bridge/br_stp_if.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 08341d2aa9c9..a05027027513 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -150,7 +150,6 @@ static int br_stp_call_user(struct net_bridge *br, char *arg)
 
 static void br_stp_start(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
 	int err = -ENOENT;
 
 	if (net_eq(dev_net(br->dev), &init_net))
@@ -169,11 +168,6 @@ static void br_stp_start(struct net_bridge *br)
 	if (!err) {
 		br->stp_enabled = BR_USER_STP;
 		br_debug(br, "userspace STP started\n");
-
-		/* Stop hello and hold timers */
-		del_timer(&br->hello_timer);
-		list_for_each_entry(p, &br->port_list, list)
-			del_timer(&p->hold_timer);
 	} else {
 		br->stp_enabled = BR_KERNEL_STP;
 		br_debug(br, "using kernel STP\n");
@@ -187,7 +181,6 @@ static void br_stp_start(struct net_bridge *br)
 
 static void br_stp_stop(struct net_bridge *br)
 {
-	struct net_bridge_port *p;
 	int err;
 
 	if (br->stp_enabled == BR_USER_STP) {
@@ -196,10 +189,6 @@ static void br_stp_stop(struct net_bridge *br)
 			br_err(br, "failed to stop userspace STP (%d)\n", err);
 
 		/* To start timers on any ports left in blocking */
-		mod_timer(&br->hello_timer, jiffies + br->hello_time);
-		list_for_each_entry(p, &br->port_list, list)
-			mod_timer(&p->hold_timer,
-				  round_jiffies(jiffies + BR_HOLD_TIME));
 		spin_lock_bh(&br->lock);
 		br_port_state_selection(br);
 		spin_unlock_bh(&br->lock);
-- 
2.13.0
