From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 12/13] rocker: call rocker_cmd_exec function with "nowait" boolean instead of flags
Date: Mon,  5 Oct 2015 19:44:05 +0200
Message-ID: <1444067046-27825-13-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38668 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbJERoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:25 -0400
Received: by wiclk2 with SMTP id lk2so125619734wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:24 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

No need to push down rocker flags just to check if this is nowait or
not. Let the caller handle that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 38 +++++++++++++++++++------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index d2151a9..69fec19 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -338,6 +338,11 @@ static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
 #define ROCKER_OP_FLAG_LEARNED		BIT(2)
 #define ROCKER_OP_FLAG_REFRESH		BIT(3)
 
+static bool rocker_flags_nowait(int flags)
+{
+	return flags & ROCKER_OP_FLAG_NOWAIT;
+}
+
 static void *__rocker_mem_alloc(struct switchdev_trans *trans, int flags,
 				size_t size)
 {
@@ -1412,14 +1417,13 @@ typedef int (*rocker_cmd_proc_cb_t)(const struct rocker_port *rocker_port,
 				    const struct rocker_desc_info *desc_info,
 				    void *priv);
 
-static int rocker_cmd_exec(struct rocker_port *rocker_port, int flags,
+static int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
 			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
 			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
-	bool nowait = !!(flags & ROCKER_OP_FLAG_NOWAIT);
 	unsigned long lock_flags;
 	int err;
 
@@ -1722,7 +1726,7 @@ rocker_cmd_set_port_settings_mode_prep(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_ethtool_proc,
 			       ecmd);
@@ -1731,7 +1735,7 @@ static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_get_port_settings_prep, NULL,
 			       rocker_cmd_get_port_settings_macaddr_proc,
 			       macaddr);
@@ -1740,7 +1744,7 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_settings_ethtool_prep,
 			       ecmd, NULL, NULL);
 }
@@ -1748,7 +1752,7 @@ static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 						unsigned char *macaddr)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_settings_macaddr_prep,
 			       macaddr, NULL, NULL);
 }
@@ -1756,7 +1760,7 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 					    int mtu)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_settings_mtu_prep,
 			       &mtu, NULL, NULL);
 }
@@ -1764,7 +1768,7 @@ static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
 				    bool learning)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_learning_prep,
 			       &learning, NULL, NULL);
 }
@@ -1772,7 +1776,7 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port,
 static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
 					     u8 mode)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_set_port_settings_mode_prep,
 			       &mode, NULL, NULL);
 }
@@ -2689,7 +2693,8 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
 	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port, flags,
+		return rocker_cmd_exec(rocker_port,
+				       rocker_flags_nowait(flags),
 				       rocker_cmd_flow_tbl_add,
 				       found, NULL, NULL);
 	return 0;
@@ -2723,7 +2728,8 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 
 	if (found) {
 		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port, flags,
+			err = rocker_cmd_exec(rocker_port,
+					      rocker_flags_nowait(flags),
 					      rocker_cmd_flow_tbl_del,
 					      found, NULL, NULL);
 		rocker_kfree(trans, found);
@@ -3014,7 +3020,8 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
 	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port, flags,
+		return rocker_cmd_exec(rocker_port,
+				       rocker_flags_nowait(flags),
 				       rocker_cmd_group_tbl_add,
 				       found, NULL, NULL);
 	return 0;
@@ -3045,7 +3052,8 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 
 	if (found) {
 		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port, flags,
+			err = rocker_cmd_exec(rocker_port,
+					      rocker_flags_nowait(flags),
 					      rocker_cmd_group_tbl_del,
 					      found, NULL, NULL);
 		rocker_group_tbl_entry_free(trans, found);
@@ -4526,7 +4534,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, 0,
+	err = rocker_cmd_exec(rocker_port, false,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -5058,7 +5066,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
 static int rocker_cmd_get_port_stats_ethtool(struct rocker_port *rocker_port,
 					     void *priv)
 {
-	return rocker_cmd_exec(rocker_port, 0,
+	return rocker_cmd_exec(rocker_port, false,
 			       rocker_cmd_get_port_stats_prep, NULL,
 			       rocker_cmd_get_port_stats_ethtool_proc,
 			       priv);
-- 
1.9.3
