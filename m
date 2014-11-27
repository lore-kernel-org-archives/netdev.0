From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 19/21] rocker: add ndo_bridge_setlink/getlink support for learning policy
Date: Thu, 27 Nov 2014 11:40:24 +0100
Message-ID: <1417084826-9875-20-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:48353 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488AbaK0Kkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:53 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so7857008wiw.10
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:52 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Rocker ports will use new "swdev" hwmode for bridge port offload policy.
Current supported policy settings are BR_LEARNING and BR_LEARNING_SYNC.
User can turn on/off device port FDB learning and syncing to bridge.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v3->v4:
-no change
new in v3
---
 drivers/net/ethernet/rocker/rocker.c | 99 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker.h |  1 +
 2 files changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fea49e8..61cfdbf 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -203,6 +203,7 @@ struct rocker_port {
 	u32 lport;
 	__be16 internal_vlan_id;
 	int stp_state;
+	u32 brport_flags;
 	bool ctrls[ROCKER_CTRL_MAX];
 	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
 	struct napi_struct napi_tx;
@@ -1629,6 +1630,30 @@ rocker_cmd_set_port_settings_macaddr_prep(struct rocker *rocker,
 	return 0;
 }
 
+static int
+rocker_cmd_set_port_learning_prep(struct rocker *rocker,
+				  struct rocker_port *rocker_port,
+				  struct rocker_desc_info *desc_info,
+				  void *priv)
+{
+	struct rocker_tlv *cmd_info;
+
+	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
+			       ROCKER_TLV_CMD_TYPE_SET_PORT_SETTINGS))
+		return -EMSGSIZE;
+	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
+	if (!cmd_info)
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
+			       rocker_port->lport))
+		return -EMSGSIZE;
+	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,
+			      !!(rocker_port->brport_flags & BR_LEARNING)))
+		return -EMSGSIZE;
+	rocker_tlv_nest_end(desc_info, cmd_info);
+	return 0;
+}
+
 static int rocker_cmd_get_port_settings_ethtool(struct rocker_port *rocker_port,
 						struct ethtool_cmd *ecmd)
 {
@@ -1663,6 +1688,13 @@ static int rocker_cmd_set_port_settings_macaddr(struct rocker_port *rocker_port,
 			       macaddr, NULL, NULL, false);
 }
 
+static int rocker_port_set_learning(struct rocker_port *rocker_port)
+{
+	return rocker_cmd_exec(rocker_port->rocker, rocker_port,
+			       rocker_cmd_set_port_learning_prep,
+			       NULL, NULL, NULL, false);
+}
+
 static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 					   struct rocker_flow_tbl_entry *entry)
 {
@@ -2995,6 +3027,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	u32 out_lport = rocker_port->lport;
 	u32 tunnel_id = 0;
 	u32 group_id = ROCKER_GROUP_NONE;
+	bool syncing = !!(rocker_port->brport_flags & BR_LEARNING_SYNC);
 	bool copy_to_cpu = false;
 	int err;
 
@@ -3009,6 +3042,9 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 			return err;
 	}
 
+	if (!syncing)
+		return 0;
+
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
@@ -3659,6 +3695,64 @@ skip:
 	return idx;
 }
 
+static int rocker_port_bridge_setlink(struct net_device *dev,
+				      struct nlmsghdr *nlh)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct nlattr *protinfo;
+	struct nlattr *afspec;
+	struct nlattr *attr;
+	u16 mode;
+	int err;
+
+	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
+				   IFLA_PROTINFO);
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+
+	if (afspec) {
+		attr = nla_find_nested(afspec, IFLA_BRIDGE_MODE);
+		if (attr) {
+			mode = nla_get_u16(attr);
+			if (mode != BRIDGE_MODE_SWDEV)
+				return -EINVAL;
+		}
+	}
+
+	if (protinfo) {
+		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
+		if (attr) {
+			if (nla_get_u8(attr))
+				rocker_port->brport_flags |= BR_LEARNING;
+			else
+				rocker_port->brport_flags &= ~BR_LEARNING;
+			err = rocker_port_set_learning(rocker_port);
+			if (err)
+				return err;
+		}
+		attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING_SYNC);
+		if (attr) {
+			if (nla_get_u8(attr))
+				rocker_port->brport_flags |= BR_LEARNING_SYNC;
+			else
+				rocker_port->brport_flags &= ~BR_LEARNING_SYNC;
+		}
+	}
+
+	return 0;
+}
+
+static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+				      struct net_device *dev,
+				      u32 filter_mask)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	u16 mode = BRIDGE_MODE_SWDEV;
+	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
+
+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
+				       rocker_port->brport_flags, mask);
+}
+
 static int rocker_port_switch_parent_id_get(struct net_device *dev,
 					    struct netdev_phys_item_id *psid)
 {
@@ -3687,6 +3781,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_add			= rocker_port_fdb_add,
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
+	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
+	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
 };
@@ -3887,6 +3983,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->rocker = rocker;
 	rocker_port->port_number = port_number;
 	rocker_port->lport = port_number + 1;
+	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
 
 	rocker_port_dev_addr_init(rocker, rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
@@ -3906,6 +4003,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
+	rocker_port_set_learning(rocker_port);
+
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port, dev->ifindex);
 	err = rocker_port_ig_tbl(rocker_port, 0);
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 5251cf8..8d2865b 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -139,6 +139,7 @@ enum {
 	ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG,		/* u8 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,		/* binary */
 	ROCKER_TLV_CMD_PORT_SETTINGS_MODE,		/* u8 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,		/* u8 */
 
 	__ROCKER_TLV_CMD_PORT_SETTINGS_MAX,
 	ROCKER_TLV_CMD_PORT_SETTINGS_MAX =
-- 
1.9.3
