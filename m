From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 07/12] rocker: switchdev Add Open vSwitch (-like) flow support to OF-DPA world
Date: Wed, 28 Sep 2016 14:42:57 +0200
Message-ID: <1475066582-1971-8-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37633 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932335AbcI1MnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:19 -0400
Received: by mail-wm0-f53.google.com with SMTP id b130so69645084wmc.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:18 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prototype programming of Open vSwitch (-like) flows into hardware
by implementing SWITCHDEV_OBJ_OVS_FLOW type objects in the
rocker_port_obj_{add,del} SDO, a new object type that
was added by an earlier patch in that forms part of this prototype.

A very limited subset of flows are accepted by this implementation,
however, it is sufficient for a working ping test: the ICMP packets are
programmed into hardware although the ARP packets are not.

Follow-up patches in this prototype will modify the Open vSwitch kernel
datapath to call the new SDOs and thus make use of the changes in this
patch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 261 +++++++++++++++++++++++++++++
 1 file changed, 261 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index fcad907baecf..6669f2ba2f97 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -19,6 +19,7 @@
 #include <linux/inetdevice.h>
 #include <linux/if_vlan.h>
 #include <linux/if_bridge.h>
+#include <linux/sw_flow.h>
 #include <net/neighbour.h>
 #include <net/switchdev.h>
 #include <net/ip_fib.h>
@@ -2795,6 +2796,264 @@ static int ofdpa_port_obj_fdb_dump(const struct rocker_port *rocker_port,
 	return err;
 }
 
+#if IS_ENABLED(CONFIG_OPENVSWITCH)
+
+static int
+ofdpa_port_sw_flow_actions(struct ofdpa_port *ofdpa_port,
+			   const struct switchdev_obj_sw_flow *flow,
+			   struct ofdpa_flow_tbl_key *out_key)
+{
+	int rem, err, out_ifindex = -1, len = flow->actions.len;
+	const struct nlattr *a, *attr = flow->actions.actions;
+	struct net_device *out_dev, *dev = ofdpa_port->dev;
+	struct rocker_port *out_rocker_port;
+	struct ofdpa_port *out_ofdpa_port;
+	__be16 vlan_id;
+	u32 out_pport;
+
+	for (a = attr, rem = len; rem > 0; a = nla_next(a, &rem)) {
+		int type = nla_type(a);
+
+		switch (type) {
+		case OVS_ACTION_ATTR_OUTPUT:
+			/* Only unicast is supported at this time */
+			if (out_ifindex >= 0)
+				return -ENOTSUPP;
+			out_ifindex = nla_get_u32(a);
+			break;
+
+		case OVS_ACTION_ATTR_POP_VLAN:
+		case OVS_ACTION_ATTR_PUSH_VLAN:
+		case OVS_ACTION_ATTR_SET:
+		case OVS_ACTION_ATTR_USERSPACE:
+		case OVS_ACTION_ATTR_HASH:
+		case OVS_ACTION_ATTR_RECIRC:
+		case OVS_ACTION_ATTR_PUSH_MPLS:
+		case OVS_ACTION_ATTR_POP_MPLS:
+		case OVS_ACTION_ATTR_SET_MASKED:
+		case OVS_ACTION_ATTR_SAMPLE:
+			return -ENOTSUPP;
+
+		case OVS_ACTION_ATTR_UNSPEC:
+		default:
+			return -EINVAL;
+		}
+	}
+
+	/* No output */
+	if (out_ifindex == -1)
+		return -ENOTSUPP;
+
+	out_dev = dev_get_by_index(dev_net(dev), out_ifindex);
+	if (!out_dev)
+		return -EINVAL;
+
+	/* It is invalid to output to the input port */
+	if (dev == out_dev) {
+		err = -EINVAL;
+		goto err;
+	}
+
+	/* Only support flows whose input and output port are on
+	 * the same rocker switch.
+	 */
+	if (!rocker_port_dev_cmp_rocker(dev, out_dev)) {
+		err = -ENOTSUPP;
+		goto err;
+	}
+
+	out_rocker_port = netdev_priv(out_dev);
+	out_ofdpa_port = out_rocker_port->wpriv;
+	out_pport = out_ofdpa_port->pport;
+	vlan_id = out_ofdpa_port->internal_vlan_id;
+	out_key->acl.group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+
+	err = 0;
+err:
+	dev_put(out_dev);
+	return err;
+}
+
+static int ofdpa_port_sw_flow_match(struct ofdpa_port *ofdpa_port,
+				    const struct switchdev_obj_sw_flow *flow,
+				    struct ofdpa_flow_tbl_key *out_key)
+{
+	const struct sw_flow_key *mask = flow->mask;
+	const struct sw_flow_key *key = flow->key;
+	const u8 *eth_dst = NULL, *eth_dst_mask = NULL;
+	u64 key_allowed, key_required;
+
+	key_required =
+		BIT_ULL(OVS_KEY_ATTR_IN_PORT) |
+		BIT_ULL(OVS_KEY_ATTR_ETHERNET) |
+		BIT_ULL(OVS_KEY_ATTR_ETHERTYPE);
+
+	/* TODO: Support more key fields as per those
+	 * permitted in the OF-DPA ACL Flow Table.
+	 */
+	key_allowed = key_required |
+		BIT_ULL(OVS_KEY_ATTR_PRIORITY) |	/* Only zero */
+		BIT_ULL(OVS_KEY_ATTR_IPV4) |
+		BIT_ULL(OVS_KEY_ATTR_ICMP) |
+		BIT_ULL(OVS_KEY_ATTR_SKB_MARK) |	/* Only zero */
+		BIT_ULL(OVS_KEY_ATTR_TUNNEL) |		/* Only zero */
+		BIT_ULL(OVS_KEY_ATTR_DP_HASH) |		/* Only zero */
+		BIT_ULL(OVS_KEY_ATTR_RECIRC_ID);	/* Only zero */
+
+	if ((flow->attrs & key_required) != key_required ||
+	    (flow->attrs & key_allowed) != flow->attrs)
+		return -ENOTSUPP;
+
+	/* Only support zero/no skb priority */
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_PRIORITY) &&
+	    key->phy.priority)
+		return -ENOTSUPP;
+
+	/* Only support zero/no tunnel id */
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_TUNNEL) &&
+	    key->tun_key.tun_id != cpu_to_be64(0))
+		return -ENOTSUPP;
+
+	/* Only support zero/no skb mark */
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_SKB_MARK) && key->phy.skb_mark)
+		return -ENOTSUPP;
+
+	/* Only support zero/no dp hash */
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_DP_HASH) && key->ovs_flow_hash)
+		return -ENOTSUPP;
+
+	/* Only support zero/no recirculation id */
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_RECIRC_ID) && key->recirc_id)
+		return -ENOTSUPP;
+
+	/* The OF-DPA ACL table requires an unmasked match on ethernet type */
+	if (mask->eth.type != cpu_to_be16(0xffff))
+		return -ENOTSUPP;
+
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_IPV4)) {
+		if (mask->ip.frag)
+			/* There is no IP frag match in OF-DPA */
+			return -ENOTSUPP;
+		if (mask->ipv4.addr.src != cpu_to_be32(0) ||
+		    mask->ipv4.addr.dst != cpu_to_be32(0))
+			/* Rocker doesn't implement these matches */
+			return -ENOTSUPP;
+		out_key->acl.ip_proto = key->ip.proto;
+		out_key->acl.ip_proto_mask = mask->ip.proto;
+		out_key->acl.ip_tos = key->ip.tos;
+		out_key->acl.ip_tos_mask = mask->ip.tos;
+	}
+
+	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_ICMP) &&
+	   (mask->tp.src != cpu_to_be16(0) || mask->tp.dst != cpu_to_be16(0)))
+		/* Rocker doesn't implement these matches */
+		return -ENOTSUPP;
+
+	out_key->acl.in_pport = ofdpa_port->pport;
+	out_key->acl.in_pport_mask = mask->phy.in_port;
+	ether_addr_copy(out_key->acl.eth_src, key->eth.src);
+	ether_addr_copy(out_key->acl.eth_src_mask, mask->eth.src);
+	ether_addr_copy(out_key->acl.eth_dst, key->eth.dst);
+	ether_addr_copy(out_key->acl.eth_dst_mask, mask->eth.dst);
+	out_key->acl.eth_type = key->eth.type;
+
+	if (!ether_addr_equal(out_key->acl.eth_dst, zero_mac)) {
+		eth_dst = key->eth.dst;
+		eth_dst_mask = mask->eth.dst;
+	}
+
+	out_key->acl.vlan_id = ofdpa_port->internal_vlan_id;
+	out_key->acl.vlan_id_mask = htons(0xffff);
+	out_key->priority = OFDPA_PRIORITY_ACL_CTRL;
+
+	return 0;
+}
+
+static struct ofdpa_flow_tbl_entry *
+ofdpa_port_sw_flow_entry(struct ofdpa_port *ofdpa_port,
+			 struct switchdev_trans *trans,
+			 const struct switchdev_obj_sw_flow *flow)
+{
+	struct ofdpa_flow_tbl_entry *entry;
+	int flags = 0;
+	int err;
+
+	entry = ofdpa_kzalloc(trans, flags, sizeof(*entry));
+	if (!entry)
+		return ERR_PTR(-ENOMEM);
+
+	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	entry->key_len = offsetof(struct ofdpa_flow_tbl_key, acl.group_id);
+
+	err = ofdpa_port_sw_flow_match(ofdpa_port, flow, &entry->key);
+	if (err)
+		goto err;
+
+	return entry;
+
+err:
+	ofdpa_kfree(trans, entry);
+	return ERR_PTR(err);
+}
+
+static int ofdpa_port_obj_sw_flow_add(struct rocker_port *rocker_port,
+				      const struct switchdev_obj_sw_flow *flow,
+				      struct switchdev_trans *trans)
+{
+	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
+	struct ofdpa_flow_tbl_entry *entry;
+	int err, flags = 0;
+
+	if (!ofdpa_port_is_ovsed(ofdpa_port))
+		return -EINVAL;
+
+	entry = ofdpa_port_sw_flow_entry(ofdpa_port, trans, flow);
+	if (IS_ERR(entry))
+		return PTR_ERR(entry);
+
+	err = ofdpa_port_sw_flow_actions(ofdpa_port, flow, &entry->key);
+	if (err) {
+		ofdpa_kfree(trans, entry);
+		return err;
+	}
+
+	return ofdpa_flow_tbl_add(ofdpa_port, trans, flags, entry);
+}
+
+static int ofdpa_port_obj_sw_flow_del(struct rocker_port *rocker_port,
+				       const struct switchdev_obj_sw_flow *flow)
+{
+	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
+	struct switchdev_trans *trans = NULL;
+	struct ofdpa_flow_tbl_entry *entry;
+	int flags = 0;
+
+	if (!ofdpa_port_is_ovsed(ofdpa_port))
+		return -EINVAL;
+
+	entry = ofdpa_port_sw_flow_entry(ofdpa_port, trans, flow);
+	if (IS_ERR(entry))
+		return PTR_ERR(entry);
+
+	return ofdpa_flow_tbl_del(ofdpa_port, trans, flags, entry);
+}
+
+#else
+
+static int ofdpa_port_obj_sw_flow_add(struct rocker_port *rocker_port,
+				       const struct switchdev_obj_sw_flow *flow,
+				       struct switchdev_trans *trans) {
+	return -ENOTSUPP;
+}
+
+static int ofdpa_port_obj_sw_flow_del(struct rocker_port *rocker_port,
+				       const struct switchdev_obj_sw_flow *flow)
+{
+	return -ENOTSUPP;
+}
+
+#endif
+
 static int ofdpa_port_bridge_join(struct ofdpa_port *ofdpa_port,
 				  struct net_device *bridge)
 {
@@ -2946,6 +3205,8 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_obj_fdb_add = ofdpa_port_obj_fdb_add,
 	.port_obj_fdb_del = ofdpa_port_obj_fdb_del,
 	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
+	.port_obj_sw_flow_add = ofdpa_port_obj_sw_flow_add,
+	.port_obj_sw_flow_del = ofdpa_port_obj_sw_flow_del,
 	.port_master_linked = ofdpa_port_master_linked,
 	.port_master_unlinked = ofdpa_port_master_unlinked,
 	.port_neigh_update = ofdpa_port_neigh_update,
-- 
2.7.0.rc3.207.g0ac5344
