From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: [PATCH] Bridge: Removed unwanted check and improper usage of bridge locks
Date: Tue, 29 Mar 2011 23:54:32 +0530
Message-ID: <1301423072-28093-1-git-send-email-sasikanth.v19@gmail.com>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Sasikanth V <sasikanth.v19@gmail.com>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41393 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab1C2SZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 14:25:07 -0400
Received: by ywj3 with SMTP id 3so191923ywj.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 11:25:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 net/bridge/br_device.c    |    5 ++++-
 net/bridge/br_stp_if.c    |    2 --
 net/bridge/br_stp_timer.c |    3 ---
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 21e5901..6cc612b 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -80,10 +80,13 @@ static int br_dev_open(struct net_device *dev)
 
 	netif_carrier_off(dev);
 
-	br_features_recompute(br);
 	netif_start_queue(dev);
+
+	spin_lock_bh(&br->lock);
+	br_features_recompute(br);
 	br_stp_enable_bridge(br);
 	br_multicast_open(br);
+	spin_unlock_bh(&br->lock);
 
 	return 0;
 }
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5593f5a..472d8b2 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -44,7 +44,6 @@ void br_stp_enable_bridge(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
-	spin_lock_bh(&br->lock);
 	mod_timer(&br->hello_timer, jiffies + br->hello_time);
 	mod_timer(&br->gc_timer, jiffies + HZ/10);
 
@@ -55,7 +54,6 @@ void br_stp_enable_bridge(struct net_bridge *br)
 			br_stp_enable_port(p);
 
 	}
-	spin_unlock_bh(&br->lock);
 }
 
 /* NO locks held */
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 3e96514..18244b2 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -65,8 +65,6 @@ static void br_message_age_timer_expired(unsigned long arg)
 	 * check is redundant. I'm leaving it in for now, though.
 	 */
 	spin_lock(&br->lock);
-	if (p->state == BR_STATE_DISABLED)
-		goto unlock;
 	was_root = br_is_root_bridge(br);
 
 	br_become_designated_port(p);
@@ -74,7 +72,6 @@ static void br_message_age_timer_expired(unsigned long arg)
 	br_port_state_selection(br);
 	if (br_is_root_bridge(br) && !was_root)
 		br_become_root_bridge(br);
- unlock:
 	spin_unlock(&br->lock);
 }
 
-- 
1.7.3.4

