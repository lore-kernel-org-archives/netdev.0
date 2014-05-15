From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next] macvlan: simplify the structure port
Date: Thu, 15 May 2014 19:11:36 +0800
Message-ID: <5374A0E8.7070404@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:18356 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbaEOLML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 07:12:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The port->count was used to count the number of macvlan devs
in the same port, but the list vlans could play the same role
to do that, so free the port if the list vlans is empty and
no need to use the parameter count.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/macvlan.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e03707d..f4701da 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -44,9 +44,10 @@ struct macvlan_port {
 	struct sk_buff_head	bc_queue;
 	struct work_struct	bc_work;
 	bool 			passthru;
-	int			count;
 };
 
+#define MACVLAN_PORT_IS_EMPTY(port)    list_empty(&port->vlans)
+
 struct macvlan_skb_cb {
 	const struct macvlan_dev *src;
 };
@@ -628,8 +629,7 @@ static void macvlan_uninit(struct net_device *dev)
 
 	free_percpu(vlan->pcpu_stats);
 
-	port->count -= 1;
-	if (!port->count)
+	if (MACVLAN_PORT_IS_EMPTY(port))
 		macvlan_port_destroy(port->dev);
 }
 
@@ -931,13 +931,12 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		vlan->flags = nla_get_u16(data[IFLA_MACVLAN_FLAGS]);
 
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
-		if (port->count)
+		if (!MACVLAN_PORT_IS_EMPTY(port))
 			return -EINVAL;
 		port->passthru = true;
 		eth_hw_addr_inherit(dev, lowerdev);
 	}
 
-	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto destroy_port;
@@ -955,8 +954,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 unregister_netdev:
 	unregister_netdevice(dev);
 destroy_port:
-	port->count -= 1;
-	if (!port->count)
+	if (MACVLAN_PORT_IS_EMPTY(port))
 		macvlan_port_destroy(lowerdev);
 
 	return err;
-- 
1.8.0
