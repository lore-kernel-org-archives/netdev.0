From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: replace fixed stack allocation with dynamic allocation
Date: Sun, 15 Mar 2015 23:04:46 -0700
Message-ID: <1426485886-61607-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36075 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPGDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 02:03:46 -0400
Received: by pdbcz9 with SMTP id cz9so48683234pdb.3
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 23:03:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

In hast to fix some sparse warning, I hard-coded a fix-sized array on the stack
which is probably too big for kernel standards.  Fix this by converting array
to dynamic allocation.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index bc5f27a..2511ae2 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2955,11 +2955,16 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 	struct rocker_port *p;
 	struct rocker *rocker = rocker_port->rocker;
 	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
-	u32 group_ids[ROCKER_FP_PORTS_MAX];
+	u32 *group_ids;
 	u8 group_count = 0;
-	int err;
+	int err = 0;
 	int i;
 
+	group_ids = kcalloc(rocker->port_count, sizeof(u32),
+			    rocker_op_flags_gfp(flags));
+	if (!group_ids)
+		return -ENOMEM;
+
 	/* Adjust the flood group for this VLAN.  The flood group
 	 * references an L2 interface group for each port in this
 	 * VLAN.
@@ -2977,7 +2982,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 
 	/* If there are no bridged ports in this VLAN, we're done */
 	if (group_count == 0)
-		return 0;
+		goto no_ports_in_vlan;
 
 	err = rocker_group_l2_flood(rocker_port, flags, vlan_id,
 				    group_count, group_ids,
@@ -2986,6 +2991,8 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
 
+no_ports_in_vlan:
+	kfree(group_ids);
 	return err;
 }
 
-- 
1.7.10.4
