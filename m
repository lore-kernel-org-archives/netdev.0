From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 11/13] rocker: remove trans parameter to rocker_cmd_exec function
Date: Mon,  5 Oct 2015 19:44:04 +0200
Message-ID: <1444067046-27825-12-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:36554 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbJERoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:23 -0400
Received: by wicgb1 with SMTP id gb1so130430296wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:22 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The only purpose of passing this parameter is to check for
prepare phase. The only reason for a failure in that state is if
TLVs don't fit into descriptor. That is highly unlikely and if that
happens, it is a driver bug. So remove this parameter from
rocker_cmd_exec, and check for prepare phase in caller.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 65 +++++++++++++++++--------------
 1 file changed, 35 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 9a38b83..d2151a9 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1412,8 +1412,7 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    const struct rocker_desc_info *desc_info,
 				    void *priv);
 
-static int rocker_cmd_exec(struct rocker_port *rocker_port,
-			   struct switchdev_trans *trans, int flags,
+static int rocker_cmd_exec(struct rocker_port *rocker_port, int flags,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
@@ -1442,17 +1441,15 @@ static int rocker_cmd_exec(struct rocker_port *rocker_port,
 		return err;
 	}
 
-	if (!switchdev_trans_ph_prepare(trans))
-		rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
+	rocker_desc_head_set(rocker, &rocker->cmd_ring, desc_info);
 
 	spin_unlock_irqrestore(&rocker->cmd_ring_lock, lock_flags);
 
 	if (nowait)
 		return 0;
 
-	if (!switchdev_trans_ph_prepare(trans))
-		if (!rocker_wait_event_timeout(wait, HZ / 10))
-			return -EIO;
+	if (!rocker_wait_event_timeout(wait, HZ / 10))
+		return -EIO;
 
 	err = rocker_desc_err(desc_info);
 	if (err)
@@ -1725,7 +1722,7 @@ rocker_cmd_set_port_settings_mode_prep(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1734,7 +1731,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1743,7 +1740,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1751,7 +1748,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1759,16 +1756,15 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 					    int mtu)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_set_port_settings_mtu_prep,
 			       &mtu, NULL, NULL);
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    struct switchdev_trans *trans,
 				    bool learning)
 {
-	return rocker_cmd_exec(rocker_port, trans, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_set_port_learning_prep,
 			       &learning, NULL, NULL);
 }
@@ -1776,7 +1772,7 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
 					     u8 mode)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_set_port_settings_mode_prep,
 			       &mode, NULL, NULL);
 }
@@ -2692,8 +2688,11 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, flags,
-			       rocker_cmd_flow_tbl_add, found, NULL, NULL);
+	if (!switchdev_trans_ph_prepare(trans))
+		return rocker_cmd_exec(rocker_port, flags,
+				       rocker_cmd_flow_tbl_add,
+				       found, NULL, NULL);
+	return 0;
 }
 
 static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
@@ -2723,9 +2722,10 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 	rocker_kfree(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans, flags,
-				      rocker_cmd_flow_tbl_del,
-				      found, NULL, NULL);
+		if (!switchdev_trans_ph_prepare(trans))
+			err = rocker_cmd_exec(rocker_port, flags,
+					      rocker_cmd_flow_tbl_del,
+					      found, NULL, NULL);
 		rocker_kfree(trans, found);
 	}
 
@@ -3013,8 +3013,11 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
-	return rocker_cmd_exec(rocker_port, trans, flags,
-			       rocker_cmd_group_tbl_add, found, NULL, NULL);
+	if (!switchdev_trans_ph_prepare(trans))
+		return rocker_cmd_exec(rocker_port, flags,
+				       rocker_cmd_group_tbl_add,
+				       found, NULL, NULL);
+	return 0;
 }
 
 static int rocker_group_tbl_del(struct rocker_port *rocker_port,
@@ -3041,9 +3044,10 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 	rocker_group_tbl_entry_free(trans, match);
 
 	if (found) {
-		err = rocker_cmd_exec(rocker_port, trans, flags,
-				      rocker_cmd_group_tbl_del,
-				      found, NULL, NULL);
+		if (!switchdev_trans_ph_prepare(trans))
+			err = rocker_cmd_exec(rocker_port, flags,
+					      rocker_cmd_group_tbl_del,
+					      found, NULL, NULL);
 		rocker_group_tbl_entry_free(trans, found);
 	}
 
@@ -4522,7 +4526,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, NULL, 0,
+	err = rocker_cmd_exec(rocker_port, 0,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -4610,8 +4614,9 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
-	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans,
+	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING &&
+	    !switchdev_trans_ph_prepare(trans))
+		err = rocker_port_set_learning(rocker_port,
 					       !!(rocker_port->brport_flags & BR_LEARNING));
 
 	if (switchdev_trans_ph_prepare(trans))
@@ -5053,7 +5058,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port, NULL, 0,
+	return rocker_cmd_exec(rocker_port, 0,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
@@ -5313,7 +5318,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
-	rocker_port_set_learning(rocker_port, NULL,
+	rocker_port_set_learning(rocker_port,
 				 !!(rocker_port->brport_flags & BR_LEARNING));
 
 	err = rocker_port_ig_tbl(rocker_port, NULL, 0);
-- 
1.9.3
