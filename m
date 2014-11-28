From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 17/21] rocker: implement L2 bridge offloading
Date: Fri, 28 Nov 2014 14:34:28 +0100
Message-ID: <1417181672-11531-18-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wi0-f180.google.com ([209.85.212.180]:64878 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbaK1Nez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:55 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so11259811wiv.1
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:54 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add L2 bridge offloading support to rocker driver.  Here, the Linux bridge
driver is used to collect swdev ports into a tagged (or untagged) VLAN
bridge.  The switchdev will offload from the bridge driver the following L2
bridging functions:

 - Learning of neighbor MAC addresses on VLAN X  Learned mac/vlan is
installed in bridge FDB.  (And removed when device unlearns mac/vlan).
Learning must be turned off on each bridge port to disable the feature in
the bridge driver.

- Flooding of multicast/broadcast and unknown unicast pkts to (STP)
active ports in bridge.  The bridge driver is unaware of the flooding happening
at the device level.  Flooding must be turned off on each bridge port to
disable the feature on the bridge driver.

- STP port state is pushed down to driver/device.  The bridge still processes
STP BDPUs and maintains port STP state (for all VLANs in bridge), but
the driver/device must be notified of port STP state change to program
the device.

Multiple (VLAN) bridges are supported.  The device (implemented per
the OF-DPA spec) must use a portion of the VLAN namespace for
internal VLANs.  Right now, the upper 255 VLANs (0xf00 to 0xffe) are
used as internal VLAN IDs for untagged traffic and are not available
as port VLANs.

The driver uses the following interfaces:

1. To track VLAN add/del on ports in bridge:

.ndo_vlan_rx_add_vid
.ndo_vlan_rx_kill_vid

2. To track port add/del membership in bridge:

NETDEV_CHANGEUPPER netdevice notifier

3. To catch static FDB entries installed on bridge/vlan by user using netlink:

.ndo_fdb_add
.ndo_fdb_del

4. To be notified on port STP state change:

.ndo_switch_port_stp_update

5. To notify bridge driver on learned/forgotten mac/vlans on bridge port:

br_fdb_external_learn_add
br_fdb_external_learn_del

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v3->v4->v5:
-no change
v2->v3:
-use renamed br_fdb learn functions
-use ndo_fdb_add/del ops instead on new ones
-pass rocker_port struct to rocker_port_stp_update instead of net_device
-allow device to refresh existing learned FDB entries to keep aging
 timers active
v1->v2:
-no change
---
 drivers/net/ethernet/rocker/rocker.c | 670 ++++++++++++++++++++++++++++++++++-
 1 file changed, 669 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 6345f60..6c15aa1 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -28,6 +28,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
 #include <linux/bitops.h>
 #include <net/switchdev.h>
 #include <net/rtnetlink.h>
@@ -196,10 +197,12 @@ enum {
 
 struct rocker_port {
 	struct net_device *dev;
+	struct net_device *bridge_dev;
 	struct rocker *rocker;
 	unsigned int port_number;
 	u32 lport;
 	__be16 internal_vlan_id;
+	int stp_state;
 	bool ctrls[ROCKER_CTRL_MAX];
 	unsigned long vlan_bitmap[ROCKER_VLAN_BITMAP_LEN];
 	struct napi_struct napi_tx;
@@ -290,6 +293,20 @@ static __be16 rocker_port_vid_to_vlan(struct rocker_port *rocker_port,
 	return vlan_id;
 }
 
+static u16 rocker_port_vlan_to_vid(struct rocker_port *rocker_port,
+				   __be16 vlan_id)
+{
+	if (rocker_vlan_id_is_internal(vlan_id))
+		return 0;
+
+	return ntohs(vlan_id);
+}
+
+static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
+{
+	return !!rocker_port->bridge_dev;
+}
+
 struct rocker_wait {
 	wait_queue_head_t wait;
 	bool done;
@@ -1301,6 +1318,43 @@ static int rocker_event_link_change(struct rocker *rocker,
 #define ROCKER_OP_FLAG_REMOVE		BIT(0)
 #define ROCKER_OP_FLAG_NOWAIT		BIT(1)
 #define ROCKER_OP_FLAG_LEARNED		BIT(2)
+#define ROCKER_OP_FLAG_REFRESH		BIT(3)
+
+static int rocker_port_fdb(struct rocker_port *rocker_port,
+			   const unsigned char *addr,
+			   __be16 vlan_id, int flags);
+
+static int rocker_event_mac_vlan_seen(struct rocker *rocker,
+				      const struct rocker_tlv *info)
+{
+	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAX + 1];
+	unsigned int port_number;
+	struct rocker_port *rocker_port;
+	unsigned char *addr;
+	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
+	__be16 vlan_id;
+
+	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
+	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_LPORT] ||
+	    !attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAC] ||
+	    !attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID])
+		return -EIO;
+	port_number =
+		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_MAC_VLAN_LPORT]) - 1;
+	addr = rocker_tlv_data(attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAC]);
+	vlan_id = rocker_tlv_get_u16(attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID]);
+
+	if (port_number >= rocker->port_count)
+		return -EINVAL;
+
+	rocker_port = rocker->ports[port_number];
+
+	if (rocker_port->stp_state != BR_STATE_LEARNING &&
+	    rocker_port->stp_state != BR_STATE_FORWARDING)
+		return 0;
+
+	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+}
 
 static int rocker_event_process(struct rocker *rocker,
 				struct rocker_desc_info *desc_info)
@@ -1320,6 +1374,8 @@ static int rocker_event_process(struct rocker *rocker,
 	switch (type) {
 	case ROCKER_TLV_EVENT_TYPE_LINK_CHANGED:
 		return rocker_event_link_change(rocker, info);
+	case ROCKER_TLV_EVENT_TYPE_MAC_VLAN_SEEN:
+		return rocker_event_mac_vlan_seen(rocker, info);
 	}
 
 	return -EOPNOTSUPP;
@@ -2547,6 +2603,104 @@ static int rocker_group_l2_flood(struct rocker_port *rocker_port,
 				       group_id);
 }
 
+static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
+					int flags, __be16 vlan_id)
+{
+	struct rocker_port *p;
+	struct rocker *rocker = rocker_port->rocker;
+	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
+	u32 group_ids[rocker->port_count];
+	u8 group_count = 0;
+	int err;
+	int i;
+
+	/* Adjust the flood group for this VLAN.  The flood group
+	 * references an L2 interface group for each port in this
+	 * VLAN.
+	 */
+
+	for (i = 0; i < rocker->port_count; i++) {
+		p = rocker->ports[i];
+		if (!rocker_port_is_bridged(p))
+			continue;
+		if (test_bit(ntohs(vlan_id), p->vlan_bitmap)) {
+			group_ids[group_count++] =
+				ROCKER_GROUP_L2_INTERFACE(vlan_id,
+							  p->lport);
+		}
+	}
+
+	/* If there are no bridged ports in this VLAN, we're done */
+	if (group_count == 0)
+		return 0;
+
+	err = rocker_group_l2_flood(rocker_port, flags, vlan_id,
+				    group_count, group_ids,
+				    group_id);
+	if (err)
+		netdev_err(rocker_port->dev,
+			   "Error (%d) port VLAN l2 flood group\n", err);
+
+	return err;
+}
+
+static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
+				      int flags, __be16 vlan_id,
+				      bool pop_vlan)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_port *p;
+	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
+	u32 out_lport;
+	int ref = 0;
+	int err;
+	int i;
+
+	/* An L2 interface group for this port in this VLAN, but
+	 * only when port STP state is LEARNING|FORWARDING.
+	 */
+
+	if (rocker_port->stp_state == BR_STATE_LEARNING ||
+	    rocker_port->stp_state == BR_STATE_FORWARDING) {
+		out_lport = rocker_port->lport;
+		err = rocker_group_l2_interface(rocker_port, flags,
+						vlan_id, out_lport,
+						pop_vlan);
+		if (err) {
+			netdev_err(rocker_port->dev,
+				   "Error (%d) port VLAN l2 group for lport %d\n",
+				   err, out_lport);
+			return err;
+		}
+	}
+
+	/* An L2 interface group for this VLAN to CPU port.
+	 * Add when first port joins this VLAN and destroy when
+	 * last port leaves this VLAN.
+	 */
+
+	for (i = 0; i < rocker->port_count; i++) {
+		p = rocker->ports[i];
+		if (test_bit(ntohs(vlan_id), p->vlan_bitmap))
+			ref++;
+	}
+
+	if ((!adding || ref != 1) && (adding || ref != 0))
+		return 0;
+
+	out_lport = 0;
+	err = rocker_group_l2_interface(rocker_port, flags,
+					vlan_id, out_lport,
+					pop_vlan);
+	if (err) {
+		netdev_err(rocker_port->dev,
+			   "Error (%d) port VLAN l2 group for CPU port\n", err);
+		return err;
+	}
+
+	return 0;
+}
+
 static struct rocker_ctrl {
 	const u8 *eth_dst;
 	const u8 *eth_dst_mask;
@@ -2625,6 +2779,30 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
+					int flags, struct rocker_ctrl *ctrl,
+					__be16 vlan_id)
+{
+	enum rocker_of_dpa_table_id goto_tbl =
+		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
+	u32 tunnel_id = 0;
+	int err;
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return 0;
+
+	err = rocker_flow_tbl_bridge(rocker_port, flags,
+				     ctrl->eth_dst, ctrl->eth_dst_mask,
+				     vlan_id, tunnel_id,
+				     goto_tbl, group_id, ctrl->copy_to_cpu);
+
+	if (err)
+		netdev_err(rocker_port->dev, "Error (%d) ctrl FLOOD\n", err);
+
+	return err;
+}
+
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 				      int flags, struct rocker_ctrl *ctrl,
 				      __be16 vlan_id)
@@ -2655,6 +2833,9 @@ static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port, int flags,
 	if (ctrl->acl)
 		return rocker_port_ctrl_vlan_acl(rocker_port, flags,
 						 ctrl, vlan_id);
+	if (ctrl->bridge)
+		return rocker_port_ctrl_vlan_bridge(rocker_port, flags,
+						    ctrl, vlan_id);
 
 	if (ctrl->term)
 		return rocker_port_ctrl_vlan_term(rocker_port, flags,
@@ -2699,6 +2880,64 @@ static int rocker_port_ctrl(struct rocker_port *rocker_port, int flags,
 	return err;
 }
 
+static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
+			    u16 vid)
+{
+	enum rocker_of_dpa_table_id goto_tbl =
+		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+	u32 in_lport = rocker_port->lport;
+	__be16 vlan_id = htons(vid);
+	__be16 vlan_id_mask = htons(0xffff);
+	__be16 internal_vlan_id;
+	bool untagged;
+	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
+	int err;
+
+	internal_vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, &untagged);
+
+	if (adding && test_and_set_bit(ntohs(internal_vlan_id),
+				       rocker_port->vlan_bitmap))
+			return 0; /* already added */
+	else if (!adding && !test_and_clear_bit(ntohs(internal_vlan_id),
+						rocker_port->vlan_bitmap))
+			return 0; /* already removed */
+
+	if (adding) {
+		err = rocker_port_ctrl_vlan_add(rocker_port, flags,
+						internal_vlan_id);
+		if (err) {
+			netdev_err(rocker_port->dev,
+				   "Error (%d) port ctrl vlan add\n", err);
+			return err;
+		}
+	}
+
+	err = rocker_port_vlan_l2_groups(rocker_port, flags,
+					 internal_vlan_id, untagged);
+	if (err) {
+		netdev_err(rocker_port->dev,
+			   "Error (%d) port VLAN l2 groups\n", err);
+		return err;
+	}
+
+	err = rocker_port_vlan_flood_group(rocker_port, flags,
+					   internal_vlan_id);
+	if (err) {
+		netdev_err(rocker_port->dev,
+			   "Error (%d) port VLAN l2 flood group\n", err);
+		return err;
+	}
+
+	err = rocker_flow_tbl_vlan(rocker_port, flags,
+				   in_lport, vlan_id, vlan_id_mask,
+				   goto_tbl, untagged, internal_vlan_id);
+	if (err)
+		netdev_err(rocker_port->dev,
+			   "Error (%d) port VLAN table\n", err);
+
+	return err;
+}
+
 static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
@@ -2724,6 +2963,163 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 	return err;
 }
 
+struct rocker_fdb_learn_work {
+	struct work_struct work;
+	struct net_device *dev;
+	int flags;
+	u8 addr[ETH_ALEN];
+	u16 vid;
+};
+
+static void rocker_port_fdb_learn_work(struct work_struct *work)
+{
+	struct rocker_fdb_learn_work *lw =
+		container_of(work, struct rocker_fdb_learn_work, work);
+	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
+	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
+
+	if (learned & removing)
+		br_fdb_external_learn_del(lw->dev, lw->addr, lw->vid);
+	else if (learned & !removing)
+		br_fdb_external_learn_add(lw->dev, lw->addr, lw->vid);
+
+	kfree(work);
+}
+
+static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
+				 int flags, const u8 *addr, __be16 vlan_id)
+{
+	struct rocker_fdb_learn_work *lw;
+	enum rocker_of_dpa_table_id goto_tbl =
+		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	u32 out_lport = rocker_port->lport;
+	u32 tunnel_id = 0;
+	u32 group_id = ROCKER_GROUP_NONE;
+	bool copy_to_cpu = false;
+	int err;
+
+	if (rocker_port_is_bridged(rocker_port))
+		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+
+	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
+		err = rocker_flow_tbl_bridge(rocker_port, flags, addr, NULL,
+					     vlan_id, tunnel_id, goto_tbl,
+					     group_id, copy_to_cpu);
+		if (err)
+			return err;
+	}
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return 0;
+
+	lw = kmalloc(sizeof(*lw), rocker_op_flags_gfp(flags));
+	if (!lw)
+		return -ENOMEM;
+
+	INIT_WORK(&lw->work, rocker_port_fdb_learn_work);
+
+	lw->dev = rocker_port->dev;
+	lw->flags = flags;
+	ether_addr_copy(lw->addr, addr);
+	lw->vid = rocker_port_vlan_to_vid(rocker_port, vlan_id);
+
+	schedule_work(&lw->work);
+
+	return 0;
+}
+
+static struct rocker_fdb_tbl_entry *
+rocker_fdb_tbl_find(struct rocker *rocker, struct rocker_fdb_tbl_entry *match)
+{
+	struct rocker_fdb_tbl_entry *found;
+
+	hash_for_each_possible(rocker->fdb_tbl, found, entry, match->key_crc32)
+		if (memcmp(&found->key, &match->key, sizeof(found->key)) == 0)
+			return found;
+
+	return NULL;
+}
+
+static int rocker_port_fdb(struct rocker_port *rocker_port,
+			   const unsigned char *addr,
+			   __be16 vlan_id, int flags)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_fdb_tbl_entry *fdb;
+	struct rocker_fdb_tbl_entry *found;
+	bool removing = (flags & ROCKER_OP_FLAG_REMOVE);
+	unsigned long lock_flags;
+
+	fdb = kzalloc(sizeof(*fdb), rocker_op_flags_gfp(flags));
+	if (!fdb)
+		return -ENOMEM;
+
+	fdb->learned = (flags & ROCKER_OP_FLAG_LEARNED);
+	fdb->key.lport = rocker_port->lport;
+	ether_addr_copy(fdb->key.addr, addr);
+	fdb->key.vlan_id = vlan_id;
+	fdb->key_crc32 = crc32(~0, &fdb->key, sizeof(fdb->key));
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+
+	found = rocker_fdb_tbl_find(rocker, fdb);
+
+	if (removing && found) {
+		kfree(fdb);
+		hash_del(&found->entry);
+	} else if (!removing && !found) {
+		hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
+	}
+
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
+
+	/* Check if adding and already exists, or removing and can't find */
+	if (!found != !removing) {
+		kfree(fdb);
+		if (!found && removing)
+			return 0;
+		/* Refreshing existing to update aging timers */
+		flags |= ROCKER_OP_FLAG_REFRESH;
+	}
+
+	return rocker_port_fdb_learn(rocker_port, flags, addr, vlan_id);
+}
+
+static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_fdb_tbl_entry *found;
+	unsigned long lock_flags;
+	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_REMOVE;
+	struct hlist_node *tmp;
+	int bkt;
+	int err = 0;
+
+	if (rocker_port->stp_state == BR_STATE_LEARNING ||
+	    rocker_port->stp_state == BR_STATE_FORWARDING)
+		return 0;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
+
+	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
+		if (found->key.lport != rocker_port->lport)
+			continue;
+		if (!found->learned)
+			continue;
+		err = rocker_port_fdb_learn(rocker_port, flags,
+					    found->key.addr,
+					    found->key.vlan_id);
+		if (err)
+			goto err_out;
+		hash_del(&found->entry);
+	}
+
+err_out:
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
+
+	return err;
+}
+
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
 				  int flags, __be16 vlan_id)
 {
@@ -2756,6 +3152,97 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 	return err;
 }
 
+static int rocker_port_fwding(struct rocker_port *rocker_port)
+{
+	bool pop_vlan;
+	u32 out_lport;
+	__be16 vlan_id;
+	u16 vid;
+	int flags = ROCKER_OP_FLAG_NOWAIT;
+	int err;
+
+	/* Port will be forwarding-enabled if its STP state is LEARNING
+	 * or FORWARDING.  Traffic from CPU can still egress, regardless of
+	 * port STP state.  Use L2 interface group on port VLANs as a way
+	 * to toggle port forwarding: if forwarding is disabled, L2
+	 * interface group will not exist.
+	 */
+
+	if (rocker_port->stp_state != BR_STATE_LEARNING &&
+	    rocker_port->stp_state != BR_STATE_FORWARDING)
+		flags |= ROCKER_OP_FLAG_REMOVE;
+
+	out_lport = rocker_port->lport;
+	for (vid = 1; vid < VLAN_N_VID; vid++) {
+		if (!test_bit(vid, rocker_port->vlan_bitmap))
+			continue;
+		vlan_id = htons(vid);
+		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
+		err = rocker_group_l2_interface(rocker_port, flags,
+						vlan_id, out_lport,
+						pop_vlan);
+		if (err) {
+			netdev_err(rocker_port->dev,
+				   "Error (%d) port VLAN l2 group for lport %d\n",
+				   err, out_lport);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
+{
+	bool want[ROCKER_CTRL_MAX] = { 0, };
+	int flags;
+	int err;
+	int i;
+
+	if (rocker_port->stp_state == state)
+		return 0;
+
+	rocker_port->stp_state = state;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		/* port is completely disabled */
+		break;
+	case BR_STATE_LISTENING:
+	case BR_STATE_BLOCKING:
+		want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
+		break;
+	case BR_STATE_LEARNING:
+	case BR_STATE_FORWARDING:
+		want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
+		want[ROCKER_CTRL_IPV4_MCAST] = true;
+		want[ROCKER_CTRL_IPV6_MCAST] = true;
+		if (rocker_port_is_bridged(rocker_port))
+			want[ROCKER_CTRL_DFLT_BRIDGING] = true;
+		else
+			want[ROCKER_CTRL_LOCAL_ARP] = true;
+		break;
+	}
+
+	for (i = 0; i < ROCKER_CTRL_MAX; i++) {
+		if (want[i] != rocker_port->ctrls[i]) {
+			flags = ROCKER_OP_FLAG_NOWAIT |
+				(want[i] ? 0 : ROCKER_OP_FLAG_REMOVE);
+			err = rocker_port_ctrl(rocker_port, flags,
+					       &rocker_ctrls[i]);
+			if (err)
+				return err;
+			rocker_port->ctrls[i] = want[i];
+		}
+	}
+
+	err = rocker_port_fdb_flush(rocker_port);
+	if (err)
+		return err;
+
+	return rocker_port_fwding(rocker_port);
+}
+
 static struct rocker_internal_vlan_tbl_entry *
 rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
 {
@@ -2848,6 +3335,8 @@ not_found:
 static int rocker_port_open(struct net_device *dev)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	u8 stp_state = rocker_port_is_bridged(rocker_port) ?
+		BR_STATE_BLOCKING : BR_STATE_FORWARDING;
 	int err;
 
 	err = rocker_port_dma_rings_init(rocker_port);
@@ -2870,12 +3359,18 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
+	err = rocker_port_stp_update(rocker_port, stp_state);
+	if (err)
+		goto err_stp_update;
+
 	napi_enable(&rocker_port->napi_tx);
 	napi_enable(&rocker_port->napi_rx);
 	rocker_port_set_enable(rocker_port, true);
 	netif_start_queue(dev);
 	return 0;
 
+err_stp_update:
+	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 err_request_tx_irq:
@@ -2891,6 +3386,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
+	rocker_port_stp_update(rocker_port, BR_STATE_DISABLED);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
 	rocker_port_dma_rings_fini(rocker_port);
@@ -3035,6 +3531,62 @@ static int rocker_port_set_mac_address(struct net_device *dev, void *p)
 	return 0;
 }
 
+static int rocker_port_vlan_rx_add_vid(struct net_device *dev,
+				       __be16 proto, u16 vid)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	err = rocker_port_vlan(rocker_port, 0, vid);
+	if (err)
+		return err;
+
+	return rocker_port_router_mac(rocker_port, 0, htons(vid));
+}
+
+static int rocker_port_vlan_rx_kill_vid(struct net_device *dev,
+					__be16 proto, u16 vid)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	err = rocker_port_router_mac(rocker_port, ROCKER_OP_FLAG_REMOVE,
+				     htons(vid));
+	if (err)
+		return err;
+
+	return rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, vid);
+}
+
+static int rocker_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			       struct net_device *dev,
+			       const unsigned char *addr, u16 vid,
+			       u16 nlm_flags)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
+	int flags = 0;
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return -EINVAL;
+
+	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+}
+
+static int rocker_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			       struct net_device *dev,
+			       const unsigned char *addr, u16 vid)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, NULL);
+	int flags = ROCKER_OP_FLAG_REMOVE;
+
+	if (!rocker_port_is_bridged(rocker_port))
+		return -EINVAL;
+
+	return rocker_port_fdb(rocker_port, addr, vlan_id, flags);
+}
+
 static int rocker_port_switch_parent_id_get(struct net_device *dev,
 					    struct netdev_phys_item_id *psid)
 {
@@ -3046,12 +3598,24 @@ static int rocker_port_switch_parent_id_get(struct net_device *dev,
 	return 0;
 }
 
+static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+
+	return rocker_port_stp_update(rocker_port, state);
+}
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
 	.ndo_start_xmit			= rocker_port_xmit,
 	.ndo_set_mac_address		= rocker_port_set_mac_address,
+	.ndo_vlan_rx_add_vid		= rocker_port_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid		= rocker_port_vlan_rx_kill_vid,
+	.ndo_fdb_add			= rocker_port_fdb_add,
+	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
+	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
 };
 
 /********************
@@ -3501,17 +4065,121 @@ static struct pci_driver rocker_pci_driver = {
 	.remove		= rocker_remove,
 };
 
+/************************************
+ * Net device notifier event handler
+ ************************************/
+
+static bool rocker_port_dev_check(struct net_device *dev)
+{
+	return dev->netdev_ops == &rocker_port_netdev_ops;
+}
+
+static int rocker_port_bridge_join(struct rocker_port *rocker_port,
+				   struct net_device *bridge)
+{
+	int err;
+
+	rocker_port_internal_vlan_id_put(rocker_port,
+					 rocker_port->dev->ifindex);
+
+	rocker_port->bridge_dev = bridge;
+
+	/* Use bridge internal VLAN ID for untagged pkts */
+	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
+	if (err)
+		return err;
+	rocker_port->internal_vlan_id =
+		rocker_port_internal_vlan_id_get(rocker_port,
+						 bridge->ifindex);
+	err = rocker_port_vlan(rocker_port, 0, 0);
+
+	return err;
+}
+
+static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
+{
+	int err;
+
+	rocker_port_internal_vlan_id_put(rocker_port,
+					 rocker_port->bridge_dev->ifindex);
+
+	rocker_port->bridge_dev = NULL;
+
+	/* Use port internal VLAN ID for untagged pkts */
+	err = rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, 0);
+	if (err)
+		return err;
+	rocker_port->internal_vlan_id =
+		rocker_port_internal_vlan_id_get(rocker_port,
+						 rocker_port->dev->ifindex);
+	err = rocker_port_vlan(rocker_port, 0, 0);
+
+	return err;
+}
+
+static int rocker_port_master_changed(struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct net_device *master = netdev_master_upper_dev_get(dev);
+	int err = 0;
+
+	if (master && master->rtnl_link_ops &&
+	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
+		err = rocker_port_bridge_join(rocker_port, master);
+	else
+		err = rocker_port_bridge_leave(rocker_port);
+
+	return err;
+}
+
+static int rocker_netdevice_event(struct notifier_block *unused,
+				  unsigned long event, void *ptr)
+{
+	struct net_device *dev;
+	int err;
+
+	switch (event) {
+	case NETDEV_CHANGEUPPER:
+		dev = netdev_notifier_info_to_dev(ptr);
+		if (!rocker_port_dev_check(dev))
+			return NOTIFY_DONE;
+		err = rocker_port_master_changed(dev);
+		if (err)
+			netdev_warn(dev,
+				    "failed to reflect master change (err %d)\n",
+				    err);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rocker_netdevice_nb __read_mostly = {
+	.notifier_call = rocker_netdevice_event,
+};
+
 /***********************
  * Module init and exit
  ***********************/
 
 static int __init rocker_module_init(void)
 {
-	return pci_register_driver(&rocker_pci_driver);
+	int err;
+
+	register_netdevice_notifier(&rocker_netdevice_nb);
+	err = pci_register_driver(&rocker_pci_driver);
+	if (err)
+		goto err_pci_register_driver;
+	return 0;
+
+err_pci_register_driver:
+	unregister_netdevice_notifier(&rocker_netdevice_nb);
+	return err;
 }
 
 static void __exit rocker_module_exit(void)
 {
+	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	pci_unregister_driver(&rocker_pci_driver);
 }
 
-- 
1.9.3
