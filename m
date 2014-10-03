From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net-next 3/3] bridge: Add filtering support for default_pvid
Date: Fri,  3 Oct 2014 11:29:18 -0400
Message-ID: <1412350158-19061-4-git-send-email-vyasevic@redhat.com>
References: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	toshiaki.makita1@gmail.com, cwang@twopensource.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:34779 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417AbaJCP3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:29:35 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so1148198qcw.17
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:29:32 -0700 (PDT)
In-Reply-To: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when vlan filtering is turned on on the bridge, the bridge
will drop all traffic untill the user configures the filter.  This
isn't very nice for ports that don't care about vlans and just
want untagged traffic.

A concept of a default_pvid was recently introduced.  This patch
adds filtering support for default_pvid.   Now, ports that don't
care about vlans and don't define there own filter will belong
to the VLAN of the default_pvid and continue to receive untagged
traffic.

This filtering can be disabled by setting default_pvid to 0.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |   8 +++-
 net/bridge/br_if.c      |   3 ++
 net/bridge/br_private.h |  14 +++++-
 net/bridge/br_vlan.c    | 118 ++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 136 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 659cac1..ffd379d 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -88,12 +88,17 @@ out:
 static int br_dev_init(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int err;
 
 	br->stats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!br->stats)
 		return -ENOMEM;
 
-	return 0;
+	err = br_vlan_init(br);
+	if (err)
+		free_percpu(br->stats);
+
+	return err;
 }
 
 static int br_dev_open(struct net_device *dev)
@@ -389,5 +394,4 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
-	br_vlan_init(br);
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 7b7289c..ed307db 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -500,6 +500,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
+	if (nbp_vlan_init(p))
+		netdev_err(dev, "failed to initialize vlan filtering on this port\n");
+
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f671561..d8cbaa6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -605,12 +605,13 @@ bool br_vlan_find(struct net_bridge *br, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
-void br_vlan_init(struct net_bridge *br);
+int br_vlan_init(struct net_bridge *br);
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
 bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
+int nbp_vlan_init(struct net_bridge_port *port);
 
 static inline struct net_port_vlans *br_get_vlan_info(
 						const struct net_bridge *br)
@@ -643,6 +644,9 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 
 static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
+	if (!v)
+		return 0;
+
 	smp_rmb();
 	return v->pvid;
 }
@@ -703,8 +707,9 @@ static inline void br_recalculate_fwd_mask(struct net_bridge *br)
 {
 }
 
-static inline void br_vlan_init(struct net_bridge *br)
+static inline int br_vlan_init(struct net_bridge *br)
 {
+	return 0;
 }
 
 static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
@@ -737,6 +742,11 @@ static inline bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
 	return false;
 }
 
+static inline int nbp_vlan_init(struct net_bridge_port *port)
+{
+	return 0;
+}
+
 static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 {
 	return 0;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e11c993..150048f 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -499,12 +499,110 @@ err_filt:
 	goto unlock;
 }
 
+static bool vlan_default_pvid(struct net_port_vlans *pv, u16 vid)
+{
+	return pv && vid == pv->pvid && test_bit(vid, pv->untagged_bitmap);
+}
+
+static void br_vlan_disable_default_pvid(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	u16 pvid = br->default_pvid;
+
+	/* Disable default_pvid on all ports where it is still
+	 * configured.
+	 */
+	if (vlan_default_pvid(br_get_vlan_info(br), pvid))
+		br_vlan_delete(br, pvid);
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (vlan_default_pvid(nbp_get_vlan_info(p), pvid))
+			nbp_vlan_delete(p, pvid);
+	}
+
+	br->default_pvid = 0;
+}
+
+static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
+{
+	struct net_bridge_port *p;
+	u16 old_pvid;
+	int err = 0;
+	unsigned long *changed;
+
+	changed = kcalloc(BITS_TO_LONGS(BR_MAX_PORTS), sizeof(unsigned long),
+			  GFP_KERNEL);
+	if (!changed)
+		return -ENOMEM;
+
+	old_pvid = br->default_pvid;
+
+	/* Update default_pvid config only if we do not conflict with
+	 * user configuration.
+	 */
+	if ((!old_pvid || vlan_default_pvid(br_get_vlan_info(br), old_pvid)) &&
+	    !br_vlan_find(br, pvid)) {
+		err = br_vlan_add(br, pvid,
+				  BRIDGE_VLAN_INFO_PVID |
+				  BRIDGE_VLAN_INFO_UNTAGGED);
+		if (err)
+			goto out;
+		br_vlan_delete(br, old_pvid);
+		set_bit(0, changed);
+	}
+
+	list_for_each_entry(p, &br->port_list, list) {
+		/* Update default_pvid config only if we do not conflict with
+		 * user configuration.
+		 */
+		if ((old_pvid &&
+		     !vlan_default_pvid(nbp_get_vlan_info(p), old_pvid)) ||
+		    nbp_vlan_find(p, pvid))
+			continue;
+
+		err = nbp_vlan_add(p, pvid,
+				   BRIDGE_VLAN_INFO_PVID |
+				   BRIDGE_VLAN_INFO_UNTAGGED);
+		if (err)
+			goto err_port;
+		nbp_vlan_delete(p, old_pvid);
+		set_bit(p->port_no, changed);
+	}
+
+	br->default_pvid = pvid;
+
+out:
+	kfree(changed);
+	return err;
+
+err_port:
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		if (!test_bit(p->port_no, changed))
+			continue;
+
+		if (old_pvid)
+			nbp_vlan_add(p, old_pvid,
+				     BRIDGE_VLAN_INFO_PVID |
+				     BRIDGE_VLAN_INFO_UNTAGGED);
+		nbp_vlan_delete(p, pvid);
+	}
+
+	if (test_bit(0, changed)) {
+		if (old_pvid)
+			br_vlan_add(br, old_pvid,
+				    BRIDGE_VLAN_INFO_PVID |
+				    BRIDGE_VLAN_INFO_UNTAGGED);
+		br_vlan_delete(br, pvid);
+	}
+	goto out;
+}
+
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 {
 	u16 pvid = val;
 	int err = 0;
 
-	if (!val || val >= VLAN_VID_MASK)
+	if (val >= VLAN_VID_MASK)
 		return -EINVAL;
 
 	if (!rtnl_trylock())
@@ -520,17 +618,22 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 		goto unlock;
 	}
 
-	br->default_pvid = pvid;
+	if (!pvid)
+		br_vlan_disable_default_pvid(br);
+	else
+		err = __br_vlan_set_default_pvid(br, pvid);
 
 unlock:
 	rtnl_unlock();
 	return err;
 }
 
-void br_vlan_init(struct net_bridge *br)
+int br_vlan_init(struct net_bridge *br)
 {
 	br->vlan_proto = htons(ETH_P_8021Q);
 	br->default_pvid = 1;
+	return br_vlan_add(br, 1,
+			   BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);
 }
 
 /* Must be protected by RTNL.
@@ -622,3 +725,12 @@ out:
 	rcu_read_unlock();
 	return found;
 }
+
+int nbp_vlan_init(struct net_bridge_port *p)
+{
+	return p->br->default_pvid ?
+			nbp_vlan_add(p, p->br->default_pvid,
+				     BRIDGE_VLAN_INFO_PVID |
+				     BRIDGE_VLAN_INFO_UNTAGGED) :
+			0;
+}
-- 
1.9.3
