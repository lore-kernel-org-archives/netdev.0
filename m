From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 05/13] rocker: implement get settings mode command
Date: Tue, 16 Feb 2016 15:14:43 +0100
Message-ID: <1455632091-10716-6-git-send-email-jiri@resnulli.us>
References: <1455632091-10716-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33883 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932867AbcBPOPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 09:15:00 -0500
Received: by mail-wm0-f50.google.com with SMTP id b205so111965105wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 06:14:59 -0800 (PST)
In-Reply-To: <1455632091-10716-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce a helper to ask HW for the port mode (world).

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 32 +++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index eecbbd5..1a99b35 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1495,6 +1495,30 @@ rocker_cmd_get_port_settings_macaddr_proc(const struct rocker_port *rocker_port,
 	return 0;
 }
 
+static int
+rocker_cmd_get_port_settings_mode_proc(const struct rocker_port *rocker_port,
+				       const struct rocker_desc_info *desc_info,
+				       void *priv)
+{
+	u8 *p_mode = priv;
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	const struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	const struct rocker_tlv *attr;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+	attr = info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MODE];
+	if (!attr)
+		return -EIO;
+
+	*p_mode = rocker_tlv_get_u8(info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MODE]);
+	return 0;
+}
+
 struct port_name {
 	char *buf;
 	size_t len;
@@ -1660,6 +1684,14 @@ static int rocker_cmd_get_port_settings_macaddr(struct rocker_port *rocker_port,
 			       macaddr);
 }
 
+static int rocker_cmd_get_port_settings_mode(struct rocker_port *rocker_port,
+					     u8 *p_mode)
+{
+	return rocker_cmd_exec(rocker_port, NULL, 0,
+			       rocker_cmd_get_port_settings_prep, NULL,
+			       rocker_cmd_get_port_settings_mode_proc, p_mode);
+}
+
 static int rocker_cmd_set_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
-- 
1.9.3
