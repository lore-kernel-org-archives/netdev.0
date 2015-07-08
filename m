From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: add change MTU support
Date: Wed,  8 Jul 2015 16:06:47 -0700
Message-ID: <1436396807-62275-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36411 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbGHXFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:05:04 -0400
Received: by pacgz10 with SMTP id gz10so65600424pac.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:05:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Implement ndo_change_mtu: on MTU change, reallocate Rx ring bufs and signal
HW of new port MTU value.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   61 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h |    1 +
 2 files changed, 62 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2d8578cade..c005167 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -1818,6 +1818,30 @@ rocker_cmd_set_port_settings_macaddr_prep(const struct rocker_port *rocker_port,
 }
 
 static int
+rocker_cmd_set_port_settings_mtu_prep(const struct rocker_port *rocker_port,
+				      struct rocker_desc_info *desc_info,
+				      void *priv)
+{
+	int mtu = *(int *)priv;
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
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_MTU,
+			       mtu))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
+static int
 rocker_cmd_set_port_learning_prep(const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
@@ -1874,6 +1898,14 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 			       macaddr, NULL, NULL);
 }
 
+static int rocker_cmd_set_port_settings_mtu(struct rocker_port *rocker_port,
+					    int mtu)
+{
+	return rocker_cmd_exec(rocker_port, SWITCHDEV_TRANS_NONE, 0,
+			       rocker_cmd_set_port_settings_mtu_prep,
+			       &mtu, NULL, NULL);
+}
+
 static int rocker_port_set_learning(struct rocker_port *rocker_port,
 				    enum switchdev_trans trans)
 {
@@ -4152,6 +4184,34 @@ static int rocker_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
+static int rocker_port_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int running = netif_running(dev);
+	int err;
+
+#define ROCKER_PORT_MIN_MTU	68
+#define ROCKER_PORT_MAX_MTU	9000
+
+	if (new_mtu < ROCKER_PORT_MIN_MTU || new_mtu > ROCKER_PORT_MAX_MTU)
+		return -EINVAL;
+
+	if (running)
+		rocker_port_stop(dev);
+
+	netdev_info(dev, "MTU change from %d to %d\n", dev->mtu, new_mtu);
+	dev->mtu = new_mtu;
+
+	err = rocker_cmd_set_port_settings_mtu(rocker_port, new_mtu);
+	if (err)
+		return err;
+
+	if (running)
+		err = rocker_port_open(dev);
+
+	return err;
+}
+
 static int rocker_port_get_phys_port_name(struct net_device *dev,
 					  char *buf, size_t len)
 {
@@ -4172,6 +4232,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_stop			= rocker_port_stop,
 	.ndo_start_xmit			= rocker_port_xmit,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
+	.ndo_change_mtu			= rocker_port_change_mtu,
 	.ndo_bridge_getlink		= switchdev_port_bridge_getlink,
 	.ndo_bridge_setlink		= switchdev_port_bridge_setlink,
 	.ndo_bridge_dellink		= switchdev_port_bridge_dellink,
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index c61fbf9..08b2c3d 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -159,6 +159,7 @@ enum {
 	ROCKER_TLV_CMD_PORT_SETTINGS_MODE,		/* u8 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,		/* u8 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_PHYS_NAME,		/* binary */
+	ROCKER_TLV_CMD_PORT_SETTINGS_MTU,		/* u16 */
 
 	__ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
 	ROCKER_TLV_CMD_PORT_SETTINGS_MAX =
-- 
1.7.10.4
