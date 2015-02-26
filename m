From: sfeldma@gmail.com
Subject: [PATCH net-next 3/3] rocker: put port in FORWADING state after leaving bridge
Date: Wed, 25 Feb 2015 20:15:38 -0800
Message-ID: <1424924138-15928-4-git-send-email-sfeldma@gmail.com>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41637 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbbBZEPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:15:15 -0500
Received: by pdno5 with SMTP id o5so9958488pdn.8
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:15:15 -0800 (PST)
In-Reply-To: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Cleanup the port forwarding state transitions for the cases when the port
joins or leaves a bridge, or is brought admin UP or DOWN.  When port is
bridged, we can rely on bridge driver putting port in correct state using
STP callback into port driver, regardless if bridge is enabled for STP or not.
When port is not bridged, we can reuse some of the STP code to enabled or
disable forwarding depending on UP or DOWN.

Tested by trying all the transitions from bridge/not bridge, and UP/DOWN, and
verifying port is in the correct forwarding state after each transition.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   39 ++++++++++++++++++++++++++--------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index db3e364..e5a15a4 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3324,6 +3324,26 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 	return rocker_port_fwding(rocker_port);
 }
 
+static int rocker_port_fwd_enable(struct rocker_port *rocker_port)
+{
+	if (rocker_port_is_bridged(rocker_port))
+		/* bridge STP will enable port */
+		return 0;
+
+	/* port is not bridged, so simulate going to FORWARDING state */
+	return rocker_port_stp_update(rocker_port, BR_STATE_FORWARDING);
+}
+
+static int rocker_port_fwd_disable(struct rocker_port *rocker_port)
+{
+	if (rocker_port_is_bridged(rocker_port))
+		/* bridge STP will disable port */
+		return 0;
+
+	/* port is not bridged, so simulate going to DISABLED state */
+	return rocker_port_stp_update(rocker_port, BR_STATE_DISABLED);
+}
+
 static struct rocker_internal_vlan_tbl_entry *
 rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
 {
@@ -3416,8 +3436,6 @@ not_found:
 static int rocker_port_open(struct net_device *dev)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	u8 stp_state = rocker_port_is_bridged(rocker_port) ?
-		BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	err = rocker_port_dma_rings_init(rocker_port);
@@ -3440,9 +3458,9 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
-	err = rocker_port_stp_update(rocker_port, stp_state);
+	err = rocker_port_fwd_enable(rocker_port);
 	if (err)
-		goto err_stp_update;
+		goto err_fwd_enable;
 
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
@@ -3450,7 +3468,7 @@ static int rocker_port_open(struct net_device *dev)
 	netif_start_queue(dev);
 	return 0;
 
-err_stp_update:
+err_fwd_enable:
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
@@ -3467,7 +3485,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
-	rocker_port_stp_update(rocker_port, BR_STATE_DISABLED);
+	rocker_port_fwd_disable(rocker_port);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
@@ -4456,9 +4474,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
 						 bridge->ifindex);
-	err = rocker_port_vlan(rocker_port, 0, 0);
-
-	return err;
+	return rocker_port_vlan(rocker_port, 0, 0);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
@@ -4478,6 +4494,11 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 		rocker_port_internal_vlan_id_get(rocker_port,
 						 rocker_port->dev->ifindex);
 	err = rocker_port_vlan(rocker_port, 0, 0);
+	if (err)
+		return err;
+
+	if (rocker_port->dev->flags & IFF_UP)
+		err = rocker_port_fwd_enable(rocker_port);
 
 	return err;
 }
-- 
1.7.10.4
