From: sfeldma@gmail.com
Subject: [PATCH net-next 5/5] rocker: remove support for legacy VLAN ndo ops
Date: Mon,  1 Jun 2015 11:39:06 -0700
Message-ID: <1433183947-13095-6-git-send-email-sfeldma@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35286 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbbFAShb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:31 -0400
Received: by padjw17 with SMTP id jw17so42802993pad.2
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:30 -0700 (PDT)
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Remove support for legacy ndo ops
.ndo_vlan_rx_add_vid/.ndo_vlan_rx_kill_vid.  Rocker will use
bridge_setlink/dellink exclusively for VLAN add/del operations.

The legacy ops are needed if using 8021q driver module to setup VLANs on
the port.  But an alternative exists in using bridge_setlink/delink to
setup VLANs, which doesn't depend on 8021q module.  So rocker will switch
to the newer setlink/dellink ops.  VLANs can added/delete from the port,
regardless if port is bridged or not, using the bridge commands:

	bridge vlan [add|del] vid VID dev DEV self

(Yes, I agree it's confusing to use the "bridge" command to set a VLAN on a
non-bridged port).

Using setlink/dellink over legacy ops let's us handle the stacked driver
case automatically.  It's built-in.  setlink also pass additional flags
(PVID, egress untagged) that aren't available with the legacy ops.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   34 +---------------------------------
 1 file changed, 1 insertion(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 3eb3eba..e3fb97a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4185,35 +4185,6 @@ static int rocker_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
-static int rocker_port_vlan_rx_add_vid(struct net_device *dev,
-				       __be16 proto, u16 vid)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int err;
-
-	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, vid);
-	if (err)
-		return err;
-
-	return rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
-				      0, htons(vid));
-}
-
-static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
-					__be16 proto, u16 vid)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int err;
-
-	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
-				     ROCKER_OP_FLAG_REMOVE, htons(vid));
-	if (err)
-		return err;
-
-	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
-				ROCKER_OP_FLAG_REMOVE, vid);
-}
-
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4235,8 +4206,6 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_stop			= rocker_port_stop,
 	.ndo_start_xmit			= rocker_port_xmit,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
-	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
 	.ndo_bridge_getlink		= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
@@ -4908,8 +4877,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 		       NAPI_POLL_WEIGHT);
 	rocker_carrier_init(rocker_port);
 
-	dev->features |= NETIF_F_NETNS_LOCAL |
-			 NETIF_F_HW_VLAN_CTAG_FILTER;
+	dev->features |= NETIF_F_NETNS_LOCAL;
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.7.10.4
