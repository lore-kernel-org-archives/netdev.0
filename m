From: David Ahern <dsahern@gmail.com>
Subject: [PATCH 2/3] rocker: add support for phys_port_name
Date: Mon, 16 Mar 2015 09:46:57 -0600
Message-ID: <1426520818-11198-2-git-send-email-dsahern@gmail.com>
References: <1426520818-11198-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:32902 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934892AbbCPPrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 11:47:19 -0400
Received: by ignm3 with SMTP id m3so35179434ign.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 08:47:18 -0700 (PDT)
In-Reply-To: <1426520818-11198-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the phys_port_name operation. Port names are pulled from the
rocker hardware model in qemu and default to the qemu name + port id.
e.g.,

sw1p1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
        ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

where 'sw1' comes from the qemu command line -device rocker,name=sw1, and
'p1' is port 1.

Patch is adapted from Scott's phys_port_id patch.

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Scott Feldman <sfeldma@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 58 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h |  1 +
 2 files changed, 59 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index bc5f27aa3131..8de390499952 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -30,6 +30,7 @@
 #include <linux/if_vlan.h>
 #include <linux/if_bridge.h>
 #include <linux/bitops.h>
+#include <linux/ctype.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
 #include <net/ip_fib.h>
@@ -1631,6 +1632,48 @@ rocker_cmd_get_port_settings_macaddr_proc(struct rocker *rocker,
 }
 
 static int
+rocker_cmd_get_port_settings_phys_name_proc(struct rocker *rocker,
+					    struct rocker_port *rocker_port,
+					    struct rocker_desc_info *desc_info,
+					    void *priv)
+{
+	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	struct netdev_phys_item_name *name = priv;
+	struct rocker_tlv *attr;
+	int i, j = 0, len;
+	char *str;
+
+	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
+	if (!attrs[ROCKER_TLV_CMD_INFO])
+		return -EIO;
+
+	rocker_tlv_parse_nested(info_attrs, ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
+				attrs[ROCKER_TLV_CMD_INFO]);
+	attr = info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_PHYS_NAME];
+	if (!attr)
+		return -EIO;
+
+	len = min_t(int, rocker_tlv_len(attr), sizeof(name->str) - 1);
+	str = rocker_tlv_data(attr);
+
+	/* make sure name only contains alphanumeric characters */
+	for (i = 0; i < len; ++i) {
+		if (isalnum(str[i])) {
+			name->str[j] = str[i];
+			j++;
+		}
+	}
+
+	if (j == 0)
+		return -EIO;
+
+	name->str[j] = '\0';
+
+	return 0;
+}
+
+static int
 rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
 					  struct rocker_port *rocker_port,
 					  struct rocker_desc_info *desc_info,
@@ -4131,6 +4174,20 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       rocker_port->brport_flags, mask);
 }
 
+static int rocker_port_get_phys_port_name(struct net_device *dev,
+					  struct netdev_phys_item_name *name)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	err = rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			      rocker_cmd_get_port_settings_prep, NULL,
+			      rocker_cmd_get_port_settings_phys_name_proc,
+			      name, false);
+
+	return err ? -EOPNOTSUPP : 0;
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -4143,6 +4200,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
+	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
 
 /********************
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 51e430d25138..a4e9591d7457 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -158,6 +158,7 @@ enum {
 	ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,		/* binary */
 	ROCKER_TLV_CMD_PORT_SETTINGS_MODE,		/* u8 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,		/* u8 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_PHYS_NAME,		/* binary */
 
 	__ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
 	ROCKER_TLV_CMD_PORT_SETTINGS_MAX =
-- 
2.2.1
