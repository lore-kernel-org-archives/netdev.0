From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net] team: Replace rcu_read_lock with a mutex in team_vlan_rx_kill_vid
Date: Mon, 18 Jan 2016 17:30:22 +0200
Message-ID: <1453131022-23818-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>,
	<ogerlitz@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0055.outbound.protection.outlook.com ([157.55.234.55]:61792
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755626AbcARQFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2016 11:05:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't be within an RCU read-side critical section when deleting
VLANs, as underlying drivers might sleep during the hardware operation.
Therefore, replace the RCU critical section with a mutex. This is
consistent with team_vlan_rx_add_vid.

Fixes: 3d249d4ca7d0 ("net: introduce ethernet teaming device")
Acked-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/team/team.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2528331..718ceea 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1872,10 +1872,10 @@ static int team_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(port, &team->port_list, list)
+	mutex_lock(&team->lock);
+	list_for_each_entry(port, &team->port_list, list)
 		vlan_vid_del(port->dev, proto, vid);
-	rcu_read_unlock();
+	mutex_unlock(&team->lock);
 
 	return 0;
 }
-- 
2.4.10
