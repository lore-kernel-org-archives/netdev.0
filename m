From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 2/3] bridge: Add filtering support for default_pvid
Date: Fri, 12 Sep 2014 16:44:50 -0400
Message-ID: <1410554691-18467-3-git-send-email-vyasevic@redhat.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:62358 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbaILUpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:45:05 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so1307505qgd.21
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:45:02 -0700 (PDT)
In-Reply-To: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
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

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |  8 +++--
 net/bridge/br_if.c      |  2 ++
 net/bridge/br_private.h | 13 ++++++--
 net/bridge/br_vlan.c    | 87 +++++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 104 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 568cccd..af8f706 100644
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
index a9f54a9..cb2b20f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -500,6 +500,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
+	nbp_vlan_init(p);
+
 	spin_lock_bh(&br->lock);
 	changed_addr = br_stp_recalculate_bridge_id(br);
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 84c9a5d..bb4abdf 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -602,12 +602,13 @@ bool br_vlan_find(struct net_bridge *br, u16 vid);
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
@@ -640,6 +641,8 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 
 static inline u16 br_get_pvid(const struct net_port_vlans *v)
 {
+	if (!v)
+		return VLAN_N_VID;
 	/* Return just the VID if it is set, or VLAN_N_VID (invalid vid) if
 	 * vid wasn't set
 	 */
@@ -703,8 +706,9 @@ static inline void br_recalculate_fwd_mask(struct net_bridge *br)
 {
 }
 
-static inline void br_vlan_init(struct net_bridge *br)
+static inline int br_vlan_init(struct net_bridge *br)
 {
+	return 0;
 }
 
 static inline int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
@@ -737,6 +741,11 @@ static inline bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
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
index 43a297b..4b807ef 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -489,6 +489,80 @@ err_filt:
 	goto unlock;
 }
 
+static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
+{
+	struct net_bridge_port *p;
+	u16 old_pvid;
+	int err;
+	DECLARE_BITMAP(changed, BR_MAX_PORTS);
+
+	bitmap_zero(changed, BR_MAX_PORTS);
+
+	/* This function runs with filtering turned off so we can
+	 * remove the old pvid configuration and add the new one after
+	 * without impacting traffic.
+	 */
+
+	old_pvid = br->default_pvid;
+
+	/* If the user has set a different PVID or if the new default pvid
+	 * conflicts with user configuration, do not modify the configuration.
+	 */
+	if (old_pvid != br_get_pvid(br_get_vlan_info(br)) ||
+	    br_vlan_find(br, pvid))
+		goto do_ports;
+
+	set_bit(0, changed);
+	br_vlan_delete(br, old_pvid);
+	err = br_vlan_add(br, pvid,
+			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);
+	if (err)
+		goto err_br;
+
+do_ports:
+	list_for_each_entry(p, &br->port_list, list) {
+		/* If the user has set a different PVID or if the new default
+		 * pvid conflicts with user configuration, do not modify the
+		 * configuration.
+		 */
+		if (old_pvid != br_get_pvid(nbp_get_vlan_info(p)) ||
+		    nbp_vlan_find(p, pvid))
+			continue;
+
+		set_bit(p->port_no, changed);
+		err = nbp_vlan_add(p, pvid,
+				   BRIDGE_VLAN_INFO_PVID |
+				   BRIDGE_VLAN_INFO_UNTAGGED);
+		if (err)
+			goto err_port;
+		nbp_vlan_delete(p, old_pvid);
+	}
+
+	br->default_pvid = pvid;
+
+	return 0;
+
+err_port:
+	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
+		if (!test_bit(p->port_no, changed))
+			continue;
+
+		nbp_vlan_delete(p, pvid);
+		nbp_vlan_add(p, old_pvid,
+			     BRIDGE_VLAN_INFO_PVID |
+			     BRIDGE_VLAN_INFO_UNTAGGED);
+	}
+
+err_br:
+	if (test_bit(0, changed)) {
+		br_vlan_delete(br, pvid);
+		br_vlan_add(br, old_pvid,
+			    BRIDGE_VLAN_INFO_PVID |
+			    BRIDGE_VLAN_INFO_UNTAGGED);
+	}
+	return err;
+}
+
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 {
 	u16 pvid = val;
@@ -509,17 +583,19 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 		goto unlock;
 	}
 
-	br->default_pvid = vid;
+	err = __br_vlan_set_default_pvid(br, pvid);
 
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
@@ -611,3 +687,10 @@ out:
 	rcu_read_unlock();
 	return found;
 }
+
+int nbp_vlan_init(struct net_bridge_port *p)
+{
+	return nbp_vlan_add(p, p->br->default_pvid,
+			    BRIDGE_VLAN_INFO_PVID |
+			    BRIDGE_VLAN_INFO_UNTAGGED);
+}
-- 
1.9.3
