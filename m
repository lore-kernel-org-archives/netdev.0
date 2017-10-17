From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 3/3] bonding: remove rtmsg_ifinfo called after bond_lower_state_changed
Date: Tue, 17 Oct 2017 17:39:41 +0800
Message-ID: <171b4df490deff34566d747eb2daf9c103ab1b11.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
 <54188a4761376d409cde7bf746edc877b4c3f0ae.1508233044.git.lucien.xin@gmail.com>
 <954c1166464c4f08118d80063395a905d9b20912.1508233044.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:47142 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934809AbdJQJkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:40:14 -0400
Received: by mail-pg0-f65.google.com with SMTP id r25so984706pgn.4
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 02:40:14 -0700 (PDT)
In-Reply-To: <954c1166464c4f08118d80063395a905d9b20912.1508233044.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch 'rtnetlink: bring NETDEV_CHANGELOWERSTATE event
process back to rtnetlink_event', bond_lower_state_changed would
generate NETDEV_CHANGEUPPER event which would send a notification
to userspace in rtnetlink_event.

There's no need to call rtmsg_ifinfo to send the notification
any more. So this patch is to remove it from these places after
bond_lower_state_changed.

Besides, after this, rtmsg_ifinfo is not needed to be exported.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/bonding.h | 4 ----
 net/core/rtnetlink.c  | 1 -
 2 files changed, 5 deletions(-)

diff --git a/include/net/bonding.h b/include/net/bonding.h
index b2e6865..1b7631c 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -330,7 +330,6 @@ static inline void bond_set_active_slave(struct slave *slave)
 		slave->backup = 0;
 		bond_queue_slave_event(slave);
 		bond_lower_state_changed(slave);
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
 
@@ -340,7 +339,6 @@ static inline void bond_set_backup_slave(struct slave *slave)
 		slave->backup = 1;
 		bond_queue_slave_event(slave);
 		bond_lower_state_changed(slave);
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
 
@@ -353,7 +351,6 @@ static inline void bond_set_slave_state(struct slave *slave,
 	slave->backup = slave_state;
 	if (notify) {
 		bond_lower_state_changed(slave);
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 		bond_queue_slave_event(slave);
 		slave->should_notify = 0;
 	} else {
@@ -385,7 +382,6 @@ static inline void bond_slave_state_notify(struct bonding *bond)
 	bond_for_each_slave(bond, tmp, iter) {
 		if (tmp->should_notify) {
 			bond_lower_state_changed(tmp);
-			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
 			tmp->should_notify = 0;
 		}
 	}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 24cb403..1574ab5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2910,7 +2910,6 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 {
 	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags);
 }
-EXPORT_SYMBOL(rtmsg_ifinfo);
 
 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 				   struct net_device *dev,
-- 
2.1.0
