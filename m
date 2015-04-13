From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 1/4] rocker: add helper for setting untagged VLAN
Date: Mon, 13 Apr 2015 15:47:54 +0900
Message-ID: <1428907677-27204-2-git-send-email-simon.horman@netronome.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35198 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbbDMGsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:48:22 -0400
Received: by pddn5 with SMTP id n5so97246116pdd.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:48:21 -0700 (PDT)
In-Reply-To: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper for setting setting untagged VLAN and use it twice.

Also add a helper for returning the uppermost device of a port:
its bridge device if present otherwise the port's device. This seems
to be clean enough in the context of this patch. I also plan
to re-use it in a subsequent patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 41 ++++++++++++++++++++----------------
 1 file changed, 23 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a87b177bd723..955cf0ae33a7 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -325,6 +325,12 @@ static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
 	return !!rocker_port->bridge_dev;
 }
 
+static struct net_device *rocker_port_uppermost_dev(struct rocker_port *rocker_port)
+{
+	return rocker_port_is_bridged(rocker_port) ?
+		rocker_port->bridge_dev : rocker_port->dev;
+}
+
 struct rocker_wait {
 	wait_queue_head_t wait;
 	bool done;
@@ -3758,6 +3764,21 @@ not_found:
 	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, lock_flags);
 }
 
+static int rocker_port_set_untagged_vlan(struct rocker_port *rocker_port)
+{
+	int err;
+	int ifindex;
+
+	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
+	if (err)
+		return err;
+
+	ifindex = rocker_port_uppermost_dev(rocker_port)->ifindex;
+	rocker_port->internal_vlan_id =
+		rocker_port_internal_vlan_id_get(rocker_port, ifindex);
+	return rocker_port_vlan(rocker_port, 0, 0);
+}
+
 static int rocker_port_fib_ipv4(struct rocker_port *rocker_port, __be32 dst,
 				int dst_len, struct fib_info *fi, u32 tb_id,
 				int flags)
@@ -4888,21 +4909,12 @@ static bool rocker_port_dev_check(struct net_device *dev)
 static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 				   struct net_device *bridge)
 {
-	int err;
-
 	rocker_port_internal_vlan_id_put(rocker_port,
 					 rocker_port->dev->ifindex);
 
 	rocker_port->bridge_dev = bridge;
 
-	/* Use bridge internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
-	if (err)
-		return err;
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 bridge->ifindex);
-	return rocker_port_vlan(rocker_port, 0, 0);
+	return rocker_port_set_untagged_vlan(rocker_port);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
@@ -4914,14 +4926,7 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 
 	rocker_port->bridge_dev = NULL;
 
-	/* Use port internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
-	if (err)
-		return err;
-	rocker_port->internal_vlan_id =
-		rocker_port_internal_vlan_id_get(rocker_port,
-						 rocker_port->dev->ifindex);
-	err = rocker_port_vlan(rocker_port, 0, 0);
+	err = rocker_port_set_untagged_vlan(rocker_port);
 	if (err)
 		return err;
 
-- 
2.1.4
