From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/14] rocker: implement set settings mode command
Date: Sun,  4 Oct 2015 23:25:40 +0200
Message-ID: <1443993949-3915-6-git-send-email-jiri@resnulli.us>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37678 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbJDVZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:25:59 -0400
Received: by wicfx3 with SMTP id fx3so90190262wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 14:25:58 -0700 (PDT)
In-Reply-To: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce a helper to ask HW for change of the port mode (world).

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 32 +++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index c698653..54d2f46 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1641,6 +1641,30 @@ rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 	return 0;
 }
 
+static int
+rocker_cmd_set_port_settings_mode_prep(const struct rocker_port *rocker_port,
+				       struct rocker_desc_info *desc_info,
+				       void *priv)
+{
+	int mode = *(int *)priv;
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,
+			       rocker_port->pport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_MODE,
+			       mode))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
@@ -1691,6 +1715,14 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port,
 			       NULL, NULL, NULL);
 }
 
+static int rocker_cmd_set_port_settings_mode(struct rocker_port *rocker_port,
+					     u8 mode)
+{
+	return rocker_cmd_exec(rocker_port, NULL, 0,
+			       rocker_cmd_set_port_settings_mode_prep,
+			       &mode, NULL, NULL);
+}
+
 static int
 rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 				const struct rocker_flow_tbl_entry *entry)
-- 
1.9.3
