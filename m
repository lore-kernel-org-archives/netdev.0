From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 3/4] rocker: forward packets to CPU when a port not bridged
Date: Mon, 13 Apr 2015 15:47:56 +0900
Message-ID: <1428907677-27204-4-git-send-email-simon.horman@netronome.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36093 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbbDMGs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:48:27 -0400
Received: by pdea3 with SMTP id a3so97210221pde.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:48:27 -0700 (PDT)
In-Reply-To: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is intended to be sufficient for the kernel to act as
a fall-back for any packets that are received when a rocker port
is not bridged.

A subsequent patch will build on this one to make use of the port's
unicast routing entries.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 56 ++++++++++++++++++++++++++++++++----
 1 file changed, 51 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index b88097b26587..d74d53cb59ab 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -199,6 +199,8 @@ struct rocker;
 enum {
 	ROCKER_CTRL_LINK_LOCAL_MCAST,
 	ROCKER_CTRL_LOCAL_ARP,
+	ROCKER_CTRL_LOCAL_UNICAST,
+	ROCKER_CTRL_PROMISC,
 	ROCKER_CTRL_IPV4_MCAST,
 	ROCKER_CTRL_IPV6_MCAST,
 	ROCKER_CTRL_DFLT_BRIDGING,
@@ -3129,6 +3131,17 @@ static struct rocker_ctrl {
 		.eth_type = htons(ETH_P_ARP),
 		.acl = true,
 	},
+	[ROCKER_CTRL_LOCAL_UNICAST] = {
+		/* pass local unicast pkts up to CPU */
+		.eth_dst_mask = ff_mac,
+		.acl = true,
+	},
+	[ROCKER_CTRL_PROMISC] = {
+		/* pass all pkts up to CPU */
+		.eth_dst = zero_mac,
+		.eth_dst_mask = zero_mac,
+		.acl = true,
+	},
 	[ROCKER_CTRL_IPV4_MCAST] = {
 		/* pass IPv4 mcast pkts up to CPU, RFC 1112 */
 		.eth_dst = ipv4_mcast,
@@ -3161,6 +3174,8 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 out_pport = 0;
 	u8 *eth_src = NULL;
 	u8 *eth_src_mask = NULL;
+	const u8 *eth_dst = ctrl->eth_dst ? :
+		rocker_port_uppermost_dev(rocker_port)->dev_addr;
 	__be16 vlan_id_mask = htons(0xffff);
 	u8 ip_proto = 0;
 	u8 ip_proto_mask = 0;
@@ -3172,7 +3187,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	err = rocker_flow_tbl_acl(rocker_port, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
-				  ctrl->eth_dst, ctrl->eth_dst_mask,
+				  eth_dst, ctrl->eth_dst_mask,
 				  ctrl->eth_type,
 				  vlan_id, vlan_id_mask,
 				  ip_proto, ip_proto_mask,
@@ -3630,13 +3645,20 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 		break;
 	case BR_STATE_LEARNING:
 	case BR_STATE_FORWARDING:
-		want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
+		if (!(rocker_port->dev->flags & IFF_PROMISC))
+			want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
 		want[ROCKER_CTRL_IPV4_MCAST] = true;
 		want[ROCKER_CTRL_IPV6_MCAST] = true;
-		if (rocker_port_is_bridged(rocker_port))
+		if (rocker_port_is_bridged(rocker_port)) {
 			want[ROCKER_CTRL_DFLT_BRIDGING] = true;
-		else
-			want[ROCKER_CTRL_LOCAL_ARP] = true;
+		} else {
+			if (rocker_port->dev->flags & IFF_PROMISC) {
+				want[ROCKER_CTRL_PROMISC] = true;
+			} else {
+				want[ROCKER_CTRL_LOCAL_UNICAST] = true;
+				want[ROCKER_CTRL_LOCAL_ARP] = true;
+			}
+		}
 		break;
 	}
 
@@ -4027,10 +4049,33 @@ static int rocker_port_set_mac_address(struct net_device *dev, void *p)
 	err = rocker_cmd_set_port_settings_macaddr(rocker_port, addr->sa_data);
 	if (err)
 		return err;
+
+	if (rocker_port->dev->flags & IFF_UP) {
+		err = rocker_port_fwd_disable(rocker_port);
+		if (err)
+			return err;
+	}
+
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	if (rocker_port->dev->flags & IFF_UP) {
+		err = rocker_port_fwd_enable(rocker_port);
+		if (err)
+			return err;
+	}
+
 	return 0;
 }
 
+static void rocker_port_change_rx_flags(struct net_device *dev, int change)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	if (change & IFF_PROMISC && rocker_port->dev->flags & IFF_UP)
+		if (!rocker_port_fwd_disable(rocker_port))
+			rocker_port_fwd_enable(rocker_port);
+}
+
 static int rocker_port_vlan_rx_add_vid(struct net_device *dev,
 				       __be16 proto, u16 vid)
 {
@@ -4230,6 +4275,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
 	.ndo_start_xmit			= rocker_port_xmit,
+	.ndo_change_rx_flags		= rocker_port_change_rx_flags,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
 	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
-- 
2.1.4
