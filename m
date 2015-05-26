From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next] rocker: by default accept untagged packets
Date: Tue, 26 May 2015 09:55:03 +0900
Message-ID: <1432601703-26774-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35799 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbbEZAzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 20:55:14 -0400
Received: by pacwv17 with SMTP id wv17so79841024pac.2
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 17:55:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will occur anyway if the 8021q module is loaded as it will
call rocker_port_vlan_rx_add_vid for vlan 0. This code is here
to handle the case where the 8021q module is not loaded.

This patch also handles the case where the 8021q is unloaded
removing all VLANs from all ports.

This change should not affect bridging, although the rules are
harmlessly installed anyway. This is in keeping with the behaviour
for VLANs when the 8021q modules is loaded.

To aid implementation of the above provide a helper
and use it to replace some existing code.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 51 +++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 36f7edfc3c7a..bc00e0abd8b6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3720,6 +3720,19 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_vlan_rx_vid(struct rocker_port *rocker_port,
+				   enum switchdev_trans trans, int flag,
+				   u16 vid)
+{
+	int err;
+
+	err = rocker_port_vlan(rocker_port, trans, flag, vid);
+	if (err)
+		return err;
+
+	return rocker_port_router_mac(rocker_port, trans, flag, htons(vid));
+}
+
 static int rocker_port_fwding(struct rocker_port *rocker_port,
 			      enum switchdev_trans trans)
 {
@@ -4009,6 +4022,16 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
+	/* By default accept untagged vlan packets.
+	 *
+	 * This will occur anyway if the 8021q module is loaded as it will
+	 * call rocker_port_vlan_rx_add_vid for vlan 0. This code is here
+	 * to handle the case where the 8021q module is not loaded.
+	 */
+	err = rocker_port_vlan_rx_vid(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
+	if (err)
+		goto err_fwd_enable;
+
 	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE);
 	if (err)
 		goto err_fwd_enable;
@@ -4187,29 +4210,33 @@ static int rocker_port_vlan_rx_add_vid(struct net_device *dev,
 				       __be16 proto, u16 vid)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	int err;
-
-	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, vid);
-	if (err)
-		return err;
 
-	return rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
-				      0, htons(vid));
+	return rocker_port_vlan_rx_vid(rocker_port, SWITCHDEV_TRANS_NONE,
+				       0, vid);
 }
 
 static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
 					__be16 proto, u16 vid)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	int err;
+	int err, i;
 
-	err = rocker_port_router_mac(rocker_port, SWITCHDEV_TRANS_NONE,
-				     ROCKER_OP_FLAG_REMOVE, htons(vid));
+	err = rocker_port_vlan_rx_vid(rocker_port, SWITCHDEV_TRANS_NONE,
+				      ROCKER_OP_FLAG_REMOVE, vid);
 	if (err)
 		return err;
 
-	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
-				ROCKER_OP_FLAG_REMOVE, vid);
+	/* If no vlans are set then the last one has been removed;
+	 * restore the default behaviour of accepting untagged packets.
+	 *
+	 * This may occur if the 8021q module is unloaded.
+	 */
+	for (i = 0; i < ROCKER_VLAN_BITMAP_LEN; i++)
+		if (rocker_port->vlan_bitmap[i])
+			return 0;
+	return rocker_port_vlan_rx_vid(rocker_port, SWITCHDEV_TRANS_NONE,
+				       0, 0);
+
 }
 
 static int rocker_port_get_phys_port_name(struct net_device *dev,
-- 
2.1.4
