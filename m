From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/3] team: move add to port list before port enablement
Date: Sat,  8 Jun 2013 15:00:54 +0200
Message-ID: <1370696455-12221-3-git-send-email-jiri@resnulli.us>
References: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:54444 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab3FHNBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 09:01:05 -0400
Received: by mail-ee0-f41.google.com with SMTP id d17so735293eek.28
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:01:04 -0700 (PDT)
In-Reply-To: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

team_port_enable() adds port to port_hashlist. Reader sees port
in team_get_port_by_index_rcu() and returns it, but
team_get_first_port_txable_rcu() tries to go through port_list, where the
port is not inserted yet -> NULL pointer dereference.
Fix this by reordering port_list and port_hashlist insertion.
Panic is easily triggeable when txing packets and adding/removing port
in a loop.

Introduced by commit 3d249d4c "net: introduce ethernet teaming device"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index d016a76..b305105 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1092,8 +1092,8 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	}
 
 	port->index = -1;
-	team_port_enable(team, port);
 	list_add_tail_rcu(&port->list, &team->port_list);
+	team_port_enable(team, port);
 	__team_compute_features(team);
 	__team_port_change_port_added(port, !!netif_carrier_ok(port_dev));
 	__team_options_change_check(team);
-- 
1.7.11.7
