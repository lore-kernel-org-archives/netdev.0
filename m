From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: fix mtu setting
Date: Thu, 29 May 2014 20:46:17 +0200
Message-ID: <1401389177-10463-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:61456 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbaE2SqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 14:46:23 -0400
Received: by mail-pa0-f47.google.com with SMTP id ld10so777454pab.34
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 11:46:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now it is not possible to set mtu to team device which has a port
enslaved to it. The reason is that when team_change_mtu() calls
dev_set_mtu() for port device, notificator for NETDEV_PRECHANGEMTU
event is called and team_device_event() returns NOTIFY_BAD forbidding
the change. So fix this by returning NOTIFY_DONE here in case team is
changing mtu in team_change_mtu().

Introduced-by: 3d249d4c "net: introduce ethernet teaming device"
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 7 ++++++-
 include/linux/if_team.h | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9a9ce8d..b4958c7 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1724,6 +1724,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 	 * to traverse list in reverse under rcu_read_lock
 	 */
 	mutex_lock(&team->lock);
+	team->port_mtu_change_allowed = true;
 	list_for_each_entry(port, &team->port_list, list) {
 		err = dev_set_mtu(port->dev, new_mtu);
 		if (err) {
@@ -1732,6 +1733,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 			goto unwind;
 		}
 	}
+	team->port_mtu_change_allowed = false;
 	mutex_unlock(&team->lock);
 
 	dev->mtu = new_mtu;
@@ -1741,6 +1743,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 unwind:
 	list_for_each_entry_continue_reverse(port, &team->port_list, list)
 		dev_set_mtu(port->dev, dev->mtu);
+	team->port_mtu_change_allowed = false;
 	mutex_unlock(&team->lock);
 
 	return err;
@@ -2851,7 +2854,9 @@ static int team_device_event(struct notifier_block *unused,
 		break;
 	case NETDEV_PRECHANGEMTU:
 		/* Forbid to change mtu of underlaying device */
-		return NOTIFY_BAD;
+		if (!port->team->port_mtu_change_allowed)
+			return NOTIFY_BAD;
+		break;
 	case NETDEV_PRE_TYPE_CHANGE:
 		/* Forbid to change type of underlaying device */
 		return NOTIFY_BAD;
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index a899dc2..a6aa970 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -194,6 +194,7 @@ struct team {
 	bool user_carrier_enabled;
 	bool queue_override_enabled;
 	struct list_head *qom_lists; /* array of queue override mapping lists */
+	bool port_mtu_change_allowed;
 	struct {
 		unsigned int count;
 		unsigned int interval; /* in ms */
-- 
1.9.0
