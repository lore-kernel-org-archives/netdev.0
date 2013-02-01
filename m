From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] team: move netlink event notifiers after team_port_leave()
Date: Fri,  1 Feb 2013 15:28:01 +0100
Message-ID: <1359728882-15333-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:34944 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473Ab3BAO2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 09:28:09 -0500
Received: by mail-ee0-f43.google.com with SMTP id c50so2154954eek.2
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 06:28:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In team_port_del(), there is need to be do all the cleanup related
things first and netlink event notifiers should be called after that.
This fixes two problems:
team carrier is now correctly set (port is removed from list first)
mode can set option as changed in .port_leave op

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 70d5d6b..1567cc8 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1131,10 +1131,6 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 		return -ENOENT;
 	}
 
-	__team_option_inst_mark_removed_port(team, port);
-	__team_options_change_check(team);
-	__team_option_inst_del_port(team, port);
-	__team_port_change_port_removed(port);
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
@@ -1143,6 +1139,12 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_close(port_dev);
 	team_port_leave(team, port);
+
+	__team_option_inst_mark_removed_port(team, port);
+	__team_options_change_check(team);
+	__team_option_inst_del_port(team, port);
+	__team_port_change_port_removed(port);
+
 	team_port_set_orig_dev_addr(port);
 	dev_set_mtu(port_dev, port->orig.mtu);
 	synchronize_rcu();
-- 
1.8.1
