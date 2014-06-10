From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 4/4] bridge: Support 802.1ad vlan filtering
Date: Tue, 10 Jun 2014 20:59:25 +0900
Message-ID: <1402401565-15423-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:41697 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaFJMAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 08:00:19 -0400
In-Reply-To: <1402401565-15423-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables us to change the vlan protocol for vlan filtering.
We come to be able to filter frames on the basis of 802.1ad vlan tags
through a bridge.

This also changes br->group_addr if it has not been set by user.
This is needed for an 802.1ad bridge.
(See IEEE 802.1Q-2011 8.13.5.)

Furthermore, this sets br->group_fwd_mask_required so that an 802.1ad
bridge can forward the Nearest Customer Bridge group addresses except
for br->group_addr, which should be passed to higher layer.

To change the vlan protocol, write a protocol in sysfs:
# echo 0x88a8 > /sys/class/net/br0/bridge/vlan_protocol

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_private.h  |  7 ++++
 net/bridge/br_sysfs_br.c | 26 +++++++++++++
 net/bridge/br_vlan.c     | 97 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 130 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index ba59880..bd95695 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -249,6 +249,7 @@ struct net_bridge
 	unsigned long			bridge_forward_delay;
 
 	u8				group_addr[ETH_ALEN];
+	bool				group_addr_set;
 	u16				root_port;
 
 	enum {
@@ -601,7 +602,9 @@ int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
+void br_recalculate_fwd_mask(struct net_bridge *br);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 void br_vlan_init(struct net_bridge *br);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
@@ -698,6 +701,10 @@ static inline bool br_vlan_find(struct net_bridge *br, u16 vid)
 	return false;
 }
 
+static inline void br_recalculate_fwd_mask(struct net_bridge *br)
+{
+}
+
 static inline void br_vlan_init(struct net_bridge *br)
 {
 }
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 8dac6555..c9e2572 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -312,10 +312,19 @@ static ssize_t group_addr_store(struct device *d,
 	    new_addr[5] == 3)		/* 802.1X PAE address */
 		return -EINVAL;
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	spin_lock_bh(&br->lock);
 	for (i = 0; i < 6; i++)
 		br->group_addr[i] = new_addr[i];
 	spin_unlock_bh(&br->lock);
+
+	br->group_addr_set = true;
+	br_recalculate_fwd_mask(br);
+
+	rtnl_unlock();
+
 	return len;
 }
 
@@ -700,6 +709,22 @@ static ssize_t vlan_filtering_store(struct device *d,
 	return store_bridge_parm(d, buf, len, br_vlan_filter_toggle);
 }
 static DEVICE_ATTR_RW(vlan_filtering);
+
+static ssize_t vlan_protocol_show(struct device *d,
+				  struct device_attribute *attr,
+				  char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%#06x\n", ntohs(br->vlan_proto));
+}
+
+static ssize_t vlan_protocol_store(struct device *d,
+				   struct device_attribute *attr,
+				   const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_vlan_set_proto);
+}
+static DEVICE_ATTR_RW(vlan_protocol);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -745,6 +770,7 @@ static struct attribute *bridge_attrs[] = {
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	&dev_attr_vlan_filtering.attr,
+	&dev_attr_vlan_protocol.attr,
 #endif
 	NULL
 };
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 63bd981..2b2774f 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -378,6 +378,33 @@ out:
 	return found;
 }
 
+/* Must be protected by RTNL. */
+static void recalculate_group_addr(struct net_bridge *br)
+{
+	if (br->group_addr_set)
+		return;
+
+	spin_lock_bh(&br->lock);
+	if (!br->vlan_enabled || br->vlan_proto == htons(ETH_P_8021Q)) {
+		/* Bridge Group Address */
+		br->group_addr[5] = 0x00;
+	} else { /* vlan_enabled && ETH_P_8021AD */
+		/* Provider Bridge Group Address */
+		br->group_addr[5] = 0x08;
+	}
+	spin_unlock_bh(&br->lock);
+}
+
+/* Must be protected by RTNL. */
+void br_recalculate_fwd_mask(struct net_bridge *br)
+{
+	if (!br->vlan_enabled || br->vlan_proto == htons(ETH_P_8021Q))
+		br->group_fwd_mask_required = BR_GROUPFWD_DEFAULT;
+	else /* vlan_enabled && ETH_P_8021AD */
+		br->group_fwd_mask_required = BR_GROUPFWD_8021AD &
+					      ~(1u << br->group_addr[5]);
+}
+
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 {
 	if (!rtnl_trylock())
@@ -388,12 +415,82 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
 
 	br->vlan_enabled = val;
 	br_manage_promisc(br);
+	recalculate_group_addr(br);
+	br_recalculate_fwd_mask(br);
 
 unlock:
 	rtnl_unlock();
 	return 0;
 }
 
+int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
+{
+	int err = 0;
+	struct net_bridge_port *p;
+	struct net_port_vlans *pv;
+	__be16 proto, oldproto;
+	u16 vid, errvid;
+
+	if (val != ETH_P_8021Q && val != ETH_P_8021AD)
+		return -EPROTONOSUPPORT;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	proto = htons(val);
+	if (br->vlan_proto == proto)
+		goto unlock;
+
+	/* Add VLANs for the new proto to the device filter. */
+	list_for_each_entry(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+			err = vlan_vid_add(p->dev, proto, vid);
+			if (err)
+				goto err_filt;
+		}
+	}
+
+	oldproto = br->vlan_proto;
+	br->vlan_proto = proto;
+
+	recalculate_group_addr(br);
+	br_recalculate_fwd_mask(br);
+
+	/* Delete VLANs for the old proto from the device filter. */
+	list_for_each_entry(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+			vlan_vid_del(p->dev, oldproto, vid);
+	}
+
+unlock:
+	rtnl_unlock();
+	return err;
+
+err_filt:
+	errvid = vid;
+	for_each_set_bit(vid, pv->vlan_bitmap, errvid)
+		vlan_vid_del(p->dev, proto, vid);
+
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		pv = rtnl_dereference(p->vlan_info);
+		if (!pv)
+			continue;
+
+		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+			vlan_vid_del(p->dev, proto, vid);
+	}
+
+	goto unlock;
+}
+
 void br_vlan_init(struct net_bridge *br)
 {
 	br->vlan_proto = htons(ETH_P_8021Q);
-- 
1.8.1.2
