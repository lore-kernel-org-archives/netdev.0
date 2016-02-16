From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/13] rocker: pass "learning" value as a parameter to rocker_port_set_learning
Date: Tue, 16 Feb 2016 13:55:33 +0100
Message-ID: <1455627338-9872-9-git-send-email-jiri@resnulli.us>
References: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37351 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110AbcBPMzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:55:52 -0500
Received: by mail-wm0-f43.google.com with SMTP id g62so151411568wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:55:51 -0800 (PST)
In-Reply-To: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be consistent with the rest of the setting functions, and pass
"learning" as a bool function parameter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 871ccbe..0015dcb 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1583,6 +1583,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
+	bool learning = *(bool *)priv;
 	struct rocker_tlv *cmd_info;
 
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
@@ -1595,7 +1596,7 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,
-			      !!(rocker_port->brport_flags & BR_LEARNING)))
+			      learning))
 		return -EMSGSIZE;
 	rocker_tlv_nest_end(desc_info, cmd_info);
 	return 0;
@@ -1652,11 +1653,12 @@ static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
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
 
 /**********************
@@ -4447,7 +4449,8 @@ static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 	orig_flags = rocker_port->brport_flags;
 	rocker_port->brport_flags = brport_flags;
 	if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
-		err = rocker_port_set_learning(rocker_port, trans);
+		err = rocker_port_set_learning(rocker_port, trans,
+					       !!(rocker_port->brport_flags & BR_LEARNING));
 
 	if (switchdev_trans_ph_prepare(trans))
 		rocker_port->brport_flags = orig_flags;
@@ -5182,7 +5185,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
-	rocker_port_set_learning(rocker_port, NULL);
+	rocker_port_set_learning(rocker_port, NULL,
+				 !!(rocker_port->brport_flags & BR_LEARNING));
 
 	err = rocker_port_ig_tbl(rocker_port, NULL, 0);
 	if (err) {
-- 
1.9.3
