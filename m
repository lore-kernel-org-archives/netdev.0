From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/13] rocker: pass "learning" value as a parameter to rocker_port_set_learning
Date: Mon,  5 Oct 2015 19:44:02 +0200
Message-ID: <1444067046-27825-10-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37767 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbJERoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:21 -0400
Received: by wicfx3 with SMTP id fx3so125388516wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:20 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be consistent with the rest of the setting functions, and pass
"learning" as a bool function parameter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - fixed learning variable casting as pointed out by David Laight
---
 drivers/net/ethernet/rocker/rocker_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index e0694ac..af70a48 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1634,6 +1634,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
+	bool learning = *(bool *)priv;
 	struct rocker_tlv *cmd_info;
 
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
@@ -1646,7 +1647,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,
-			      !!(rocker_port->brport_flags & BR_LEARNING)))
+			      learning))
 		return -EMSGSIZE;
 	rocker_tlv_nest_end(desc_info, cmd_info);
 	return 0;
@@ -1719,11 +1720,12 @@ static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
-				    struct switchdev_trans *trans)
+				    struct switchdev_trans *trans,
+				    bool learning)
 {
 	return rocker_cmd_exec(rocker_port, trans, 0,
 			       rocker_cmd_set_port_learning_prep,
-			       NULL, NULL, NULL);
+			       &learning, NULL, NULL);
 }
 
 static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
@@ -4564,7 +4566,8 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
 	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans);
+		err = rocker_port_set_learning(rocker_port, trans,
+					       !!(rocker_port->brport_flags & BR_LEARNING));
 
 	if (switchdev_trans_ph_prepare(trans))
 		rocker_port->brport_flags = orig_flags;
@@ -5265,7 +5268,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
-	rocker_port_set_learning(rocker_port, NULL);
+	rocker_port_set_learning(rocker_port, NULL,
+				 !!(rocker_port->brport_flags & BR_LEARNING));
 
 	err = rocker_port_ig_tbl(rocker_port, NULL, 0);
 	if (err) {
-- 
1.9.3
