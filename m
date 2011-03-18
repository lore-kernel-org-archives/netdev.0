From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 14/36] macvlan,rcu: convert call_rcu(macvlan_port_rcu_free)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 12:00:07 +0800
Message-ID: <4D82D8C7.3040608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:49202 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932155Ab1CRD6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:58:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback macvlan_port_rcu_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(macvlan_port_rcu_free).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 drivers/net/macvlan.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 6ed577b..6205e45 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -591,21 +591,13 @@ static int macvlan_port_create(struct net_device *dev)
 	return err;
 }
 
-static void macvlan_port_rcu_free(struct rcu_head *head)
-{
-	struct macvlan_port *port;
-
-	port = container_of(head, struct macvlan_port, rcu);
-	kfree(port);
-}
-
 static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = macvlan_port_get(dev);
 
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
-	call_rcu(&port->rcu, macvlan_port_rcu_free);
+	kfree_rcu(port, rcu);
 }
 
 static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
1.7.4
