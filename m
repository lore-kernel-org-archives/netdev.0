From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: fix possible null pointer dereference in team_handle_frame
Date: Mon, 23 Feb 2015 14:02:54 +0100
Message-ID: <1424696574-6590-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:38222 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbBWNC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 08:02:58 -0500
Received: by wesw55 with SMTP id w55so17878715wes.5
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 05:02:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently following race is possible in team:

CPU0                                        CPU1
                                            team_port_del
                                              team_upper_dev_unlink
                                                priv_flags &= ~IFF_TEAM_PORT
team_handle_frame
  team_port_get_rcu
    team_port_exists
      priv_flags & IFF_TEAM_PORT == 0
    return NULL (instead of port got
                 from rx_handler_data)
                                              netdev_rx_handler_unregister

The thing is that the flag is removed before rx_handler is unregistered.
If team_handle_frame is called in between, team_port_exists returns 0
and team_port_get_rcu will return NULL.
So do not check the flag here. It is guaranteed by netdev_rx_handler_unregister
that team_handle_frame will always see valid rx_handler_data pointer.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Fixes: 3d249d4ca7d0 ("net: introduce ethernet teaming device")
---
 drivers/net/team/team.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 0e62274..f1ee71e 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -43,9 +43,7 @@
 
 static struct team_port *team_port_get_rcu(const struct net_device *dev)
 {
-	struct team_port *port = rcu_dereference(dev->rx_handler_data);
-
-	return team_port_exists(dev) ? port : NULL;
+	return rcu_dereference(dev->rx_handler_data);
 }
 
 static struct team_port *team_port_get_rtnl(const struct net_device *dev)
-- 
1.9.3
