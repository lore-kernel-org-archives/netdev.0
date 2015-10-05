From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/13] rocker: implement set settings mode command
Date: Mon,  5 Oct 2015 19:43:58 +0200
Message-ID: <1444067046-27825-6-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33527 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377AbbJERoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:16 -0400
Received: by wiclk2 with SMTP id lk2so132053466wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:15 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
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
