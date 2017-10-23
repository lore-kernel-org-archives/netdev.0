From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/3] bonding: remove rtmsg_ifinfo called after bond_lower_state_changed
Date: Mon, 23 Oct 2017 18:44:52 +0800
Message-ID: <21fdc6d360481b9fffdde8686b9c632b3e207b13.1508755319.git.lucien.xin@gmail.com>
References: <cover.1508755319.git.lucien.xin@gmail.com>
 <15984f2370698158ef2af599b8619a2b7f64852d.1508755319.git.lucien.xin@gmail.com>
 <8ca1a0080c9ef1dd81750f69967cec324f1e8a84.1508755319.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:53467 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdJWKpZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 06:45:25 -0400
Received: by mail-pg0-f67.google.com with SMTP id s2so11449449pge.10
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 03:45:25 -0700 (PDT)
In-Reply-To: <8ca1a0080c9ef1dd81750f69967cec324f1e8a84.1508755319.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508755319.git.lucien.xin@gmail.com>
References: <cover.1508755319.git.lucien.xin@gmail.com>
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
index 2860cc6..f801fc9 100644
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
index 854a848..de24d39 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2989,7 +2989,6 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 {
 	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags, NULL);
 }
-EXPORT_SYMBOL(rtmsg_ifinfo);
 
 void rtmsg_ifinfo_newnet(int type, struct net_device *dev, unsigned int change,
 			 gfp_t flags, int *new_nsid)
-- 
2.1.0
