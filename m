From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 4/4] bridge: Support 802.1ad vlan filtering
Date: Mon,  9 Jun 2014 20:34:47 +0900
Message-ID: <1402313687-28067-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:60941 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbaFILfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 07:35:10 -0400
In-Reply-To: <1402313687-28067-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables us to change the vlan protocol for vlan filtering.
We come to be able to filter frames on the basis of 802.1ad vlan tags
through a bridge.

This also changes br->group_addr if it has not been set by user.
This is needed for an 802.1ad bridge.
(See IEEE 802.1Q-2011 8.13.5.)

To change the vlan protocol, write a protocol in sysfs:
# echo 0x88a8 > /sys/class/net/br0/bridge/vlan_protocol

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_private.h  |  2 ++
 net/bridge/br_sysfs_br.c | 18 +++++++++++
 net/bridge/br_vlan.c     | 81 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 101 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 65204c2..3c5b23b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -246,6 +246,7 @@ struct net_bridge
 	unsigned long			bridge_forward_delay;
 
 	u8				group_addr[ETH_ALEN];
+	unsigned char			group_addr_set;
 	u16				root_port;
 
 	enum {
@@ -599,6 +600,7 @@ int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
 bool br_vlan_find(struct net_bridge *br, u16 vid);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
+int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 void br_vlan_init(struct net_bridge *br);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 8dac6555..1831018 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -315,6 +315,7 @@ static ssize_t group_addr_store(struct device *d,
 	spin_lock_bh(&br->lock);
 	for (i = 0; i < 6; i++)
 		br->group_addr[i] = new_addr[i];
+	br->group_addr_set = 1;
 	spin_unlock_bh(&br->lock);
 	return len;
 }
@@ -700,6 +701,22 @@ static ssize_t vlan_filtering_store(struct device *d,
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
@@ -745,6 +762,7 @@ static struct attribute *bridge_attrs[] = {
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	&dev_attr_vlan_filtering.attr,
+	&dev_attr_vlan_protocol.attr,
 #endif
 	NULL
 };
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 63bd981..c86a7a6 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -394,6 +394,87 @@ unlock:
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
+	spin_lock_bh(&br->lock);
+	if (!br->group_addr_set) {
+		switch (val) {
+		case ETH_P_8021Q:
+			/* Bridge Group Address */
+			br->group_addr[5] = 0x00;
+			break;
+
+		case ETH_P_8021AD:
+			/* Provider Bridge Group Address */
+			br->group_addr[5] = 0x08;
+			break;
+		}
+	}
+	spin_unlock_bh(&br->lock);
+
+	oldproto = br->vlan_proto;
+	br->vlan_proto = proto;
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
