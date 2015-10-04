From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/14] rocker: call rocker_cmd_exec function with "nowait" boolean instead of flags
Date: Sun,  4 Oct 2015 23:25:48 +0200
Message-ID: <1443993949-3915-14-git-send-email-jiri@resnulli.us>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38592 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbJDV0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:26:08 -0400
Received: by wiclk2 with SMTP id lk2so90441623wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 14:26:07 -0700 (PDT)
In-Reply-To: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
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
index af950ad..3311f5b 100644
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
@@ -2733,7 +2737,8 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->flow_tbl_lock, lock_flags);
 
 	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port, flags,
+		return rocker_cmd_exec(rocker_port,
+				       rocker_flags_nowait(flags),
 				       rocker_cmd_flow_tbl_add,
 				       found, NULL, NULL);
 	return 0;
@@ -2767,7 +2772,8 @@ static int rocker_flow_tbl_del(struct rocker_port *rocker_port,
 
 	if (found) {
 		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port, flags,
+			err = rocker_cmd_exec(rocker_port,
+					      rocker_flags_nowait(flags),
 					      rocker_cmd_flow_tbl_del,
 					      found, NULL, NULL);
 		rocker_kfree(trans, found);
@@ -3058,7 +3064,8 @@ static int rocker_group_tbl_add(struct rocker_port *rocker_port,
 	spin_unlock_irqrestore(&rocker->group_tbl_lock, lock_flags);
 
 	if (!switchdev_trans_ph_prepare(trans))
-		return rocker_cmd_exec(rocker_port, flags,
+		return rocker_cmd_exec(rocker_port,
+				       rocker_flags_nowait(flags),
 				       rocker_cmd_group_tbl_add,
 				       found, NULL, NULL);
 	return 0;
@@ -3089,7 +3096,8 @@ static int rocker_group_tbl_del(struct rocker_port *rocker_port,
 
 	if (found) {
 		if (!switchdev_trans_ph_prepare(trans))
-			err = rocker_cmd_exec(rocker_port, flags,
+			err = rocker_cmd_exec(rocker_port,
+					      rocker_flags_nowait(flags),
 					      rocker_cmd_group_tbl_del,
 					      found, NULL, NULL);
 		rocker_group_tbl_entry_free(trans, found);
@@ -4570,7 +4578,7 @@ static int rocker_port_get_phys_port_name(struct net_device *dev,
 	struct port_name name = { .buf = buf, .len = len };
 	int err;
 
-	err = rocker_cmd_exec(rocker_port, 0,
+	err = rocker_cmd_exec(rocker_port, false,
 			      rocker_cmd_get_port_settings_prep, NULL,
 			      rocker_cmd_get_port_settings_phys_name_proc,
 			      &name);
@@ -5102,7 +5110,7 @@ rocker_cmd_get_port_stats_ethtool_proc(const struct rocker_port *rocker_port,
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
