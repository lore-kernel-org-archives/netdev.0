From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] rocker: use new helper to figure out master kind
Date: Wed, 26 Aug 2015 18:36:37 +0200
Message-ID: <1440606998-11072-6-git-send-email-jiri@resnulli.us>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38525 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbbHZQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 12:36:46 -0400
Received: by wicja10 with SMTP id ja10so20600668wic.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 09:36:45 -0700 (PDT)
In-Reply-To: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Looking at rtnl kind string is kind of ugly. So use new helpers to do
this in nicer way.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a7cb74a..62f383c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -322,21 +322,16 @@ static u16 rocker_port_vlan_to_vid(const struct rocker_port *rocker_port,
 	return ntohs(vlan_id);
 }
 
-static bool rocker_port_is_slave(const struct rocker_port *rocker_port,
-				   const char *kind)
-{
-	return rocker_port->bridge_dev &&
-		!strcmp(rocker_port->bridge_dev->rtnl_link_ops->kind, kind);
-}
-
 static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
 {
-	return rocker_port_is_slave(rocker_port, "bridge");
+	return rocker_port->bridge_dev &&
+	       netif_is_bridge_master(rocker_port->bridge_dev);
 }
 
 static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 {
-	return rocker_port_is_slave(rocker_port, "openvswitch");
+	return rocker_port->bridge_dev &&
+	       netif_is_ovs_master(rocker_port->bridge_dev);
 }
 
 #define ROCKER_OP_FLAG_REMOVE		BIT(0)
@@ -5338,10 +5333,10 @@ static int rocker_port_master_changed(struct net_device *dev)
 	int err = 0;
 
 	/* N.B: Do nothing if the type of master is not supported */
-	if (master && master->rtnl_link_ops) {
-		if (!strcmp(master->rtnl_link_ops->kind, "bridge"))
+	if (master) {
+		if (netif_is_bridge_master(master))
 			err = rocker_port_bridge_join(rocker_port, master);
-		else if (!strcmp(master->rtnl_link_ops->kind, "openvswitch"))
+		else if (netif_is_ovs_master(master))
 			err = rocker_port_ovs_changed(rocker_port, master);
 	} else if (rocker_port_is_bridged(rocker_port)) {
 		err = rocker_port_bridge_leave(rocker_port);
-- 
1.9.3
