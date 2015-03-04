From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: don't traverse port list using rcu in team_set_mac_address
Date: Wed,  4 Mar 2015 08:36:31 +0100
Message-ID: <1425454591-7686-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:46616 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933361AbbCDHgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 02:36:35 -0500
Received: by wggy19 with SMTP id y19so44625997wgg.13
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 23:36:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the list is traversed using rcu variant. That is not correct
since dev_set_mac_address can be called which eventually calls
rtmsg_ifinfo_build_skb and there, skb allocation can sleep. So fix this
by remove the rcu usage here.

Fixes: 3d249d4ca7 "net: introduce ethernet teaming device"
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a7d163b..88e72c2 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1732,11 +1732,11 @@ static int team_set_mac_address(struct net_device *dev, void *p)
 	if (dev->type == ARPHRD_ETHER && !is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	rcu_read_lock();
-	list_for_each_entry_rcu(port, &team->port_list, list)
+	mutex_lock(&team->lock);
+	list_for_each_entry(port, &team->port_list, list)
 		if (team->ops.port_change_dev_addr)
 			team->ops.port_change_dev_addr(team, port);
-	rcu_read_unlock();
+	mutex_unlock(&team->lock);
 	return 0;
 }
 
-- 
1.9.3
