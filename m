From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [RFC PATCH] bridge: vlan: add per-vlan contexts and move to rhashtables
Date: Mon, 21 Sep 2015 18:45:06 +0200
Message-ID: <1442853906-25157-1-git-send-email-razor@blackwall.org>
Cc: vyasevich@gmail.com, roopa@cumulusnetworks.com,
	davem@davemloft.net, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38368 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbbIUQpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 12:45:12 -0400
Received: by wiclk2 with SMTP id lk2so120583131wic.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 09:45:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Hi all,
Please keep in mind this is still an RFC, but soon I'll have v1 ready for
posting. The motivation behind this work is that we'd like to extend the
vlan functionality, after talking to Vlad it became clear we need both
global and per-port vlan contexts, here's a list of some of the new
features we'd like to introduce:
- per-vlan counters
- vlan ingress/egress mapping
- per-vlan igmp configuration
- vlan priorities
- avoid fdb entries replication (e.g. local fdb scaling issues with many vlans)

The intention of this new structure is to be easily extensible. I made
the refcnt atomic from the beginning because later we'll need it to be,
if I'm wrong we can always switch it back to a normal integer. The
structure is kept single to avoid code duplication where possible and
also because we'll soon introduce "port0 / aka bridge as port" which
should simplify things further (thanks to Vlad for the suggestion!).
Unfortunately this initial switch needs to be done in a single larger
patch because the moment net_port_vlans is touched, the whole API needs
to be changed.

Here are the main points:
- per-vlan global struct
- per-vlan per-port struct, having a pointer and a ref to the global one
- rhashtables used for both
- sorted list kept for both to enable compressed user requests, stable
  walks, error paths etc
- global struct always created, even if the vlan is added per-port only
- user-space should see everything as before, completely compatible
- untagged vlans now are represented by a flag

Things tested so far (more tests queued):
- basic vlan ingress/egress
- pvids
- untagged vlans
- undef CONFIG_BRIDGE_VLAN_FILTERING
- adding/deleting vlans in different scenarios (with/without global ctx,
  while transmitting traffic etc)
- loading/removing the module while having/adding/deleting vlans
- extracting bridge vlan information (user ABI), compressed requests
- kmemleak ON during the whole time

Things to do for v1:
- Add more comments / documentation
- Remove (br|nbp)_vlan_list, and use vlan group directly
- Simplify some functions (e.g. __vlan_add)
- Cleanup leftover bugs
- Rename BRIDGE_VLAN_INFO_MASTERVL
- Sync on the user-visible error returns from before

Things that will _NOT_ be done in v1:
- Single fast-path lookup, I'm deferring optimizations until after (or
  if) some version of this patch gets accepted.
- Any new features also deferred

Again any feedback would be appreciated.

Thanks,
 Nik
---
 include/uapi/linux/if_bridge.h |   1 +
 net/bridge/br_device.c         |   2 +-
 net/bridge/br_fdb.c            |  74 ++---
 net/bridge/br_forward.c        |  15 +-
 net/bridge/br_input.c          |  10 +-
 net/bridge/br_mdb.c            |  24 +-
 net/bridge/br_netlink.c        | 176 ++++++-----
 net/bridge/br_private.h        | 157 +++++++---
 net/bridge/br_vlan.c           | 669 ++++++++++++++++++++++++-----------------
 9 files changed, 667 insertions(+), 461 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 3635b7797508..7d8548021abb 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -127,6 +127,7 @@ enum {
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
 #define BRIDGE_VLAN_INFO_RANGE_BEGIN	(1<<3) /* VLAN is start of vlan range */
 #define BRIDGE_VLAN_INFO_RANGE_END	(1<<4) /* VLAN is end of vlan range */
+#define BRIDGE_VLAN_INFO_MASTERVL	(1<<5) /* Bridge VLAN */
 
 struct bridge_vlan_info {
 	__u16 flags;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 6ed2feb51e3c..c21a0b8080a9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -56,7 +56,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
-	if (!br_allowed_ingress(br, br_get_vlan_info(br), skb, &vid))
+	if (!br_allowed_ingress(br, skb, &vid))
 		goto out;
 
 	if (is_broadcast_ether_addr(dest))
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875da0a4f..110293324720 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -163,22 +163,25 @@ static void fdb_delete_local(struct net_bridge *br,
 			     struct net_bridge_fdb_entry *f)
 {
 	const unsigned char *addr = f->addr.addr;
-	u16 vid = f->vlan_id;
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *op;
+	u16 vid = f->vlan_id;
 
 	/* Maybe another port has same hw addr? */
 	list_for_each_entry(op, &br->port_list, list) {
+		vg = nbp_vlan_group(op);
 		if (op != p && ether_addr_equal(op->dev->dev_addr, addr) &&
-		    (!vid || nbp_vlan_find(op, vid))) {
+		    (!vid || br_vlan_find(vg, vid))) {
 			f->dst = op;
 			f->added_by_user = 0;
 			return;
 		}
 	}
 
+	vg = br_vlan_group(br);
 	/* Maybe bridge device has same hw addr? */
 	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
-	    (!vid || br_vlan_find(br, vid))) {
+	    (!vid || br_vlan_find(vg, vid))) {
 		f->dst = NULL;
 		f->added_by_user = 0;
 		return;
@@ -203,14 +206,14 @@ void br_fdb_find_delete_local(struct net_bridge *br,
 
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge *br = p->br;
-	struct net_port_vlans *pv = nbp_get_vlan_info(p);
-	bool no_vlan = !pv;
+	struct net_bridge_vlan *v;
 	int i;
-	u16 vid;
 
 	spin_lock_bh(&br->hash_lock);
 
+	vg = nbp_vlan_group(p);
 	/* Search all chains since old address/hash is unknown */
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct hlist_node *h;
@@ -226,7 +229,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 				 * configured, we can safely be done at
 				 * this point.
 				 */
-				if (no_vlan)
+				if (!vg || list_empty(&vg->vlan_list))
 					goto insert;
 			}
 		}
@@ -236,15 +239,15 @@ insert:
 	/* insert new address,  may fail if invalid address or dup. */
 	fdb_insert(br, p, newaddr, 0);
 
-	if (no_vlan)
+	if (!vg || list_empty(&vg->vlan_list))
 		goto done;
 
 	/* Now add entries for every VLAN configured on the port.
 	 * This function runs under RTNL so the bitmap will not change
 	 * from under us.
 	 */
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-		fdb_insert(br, p, newaddr, vid);
+	list_for_each_entry(v, &vg->vlan_list, vlist)
+		fdb_insert(br, p, newaddr, v->vid);
 
 done:
 	spin_unlock_bh(&br->hash_lock);
@@ -252,9 +255,9 @@ done:
 
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_fdb_entry *f;
-	struct net_port_vlans *pv;
-	u16 vid = 0;
+	struct net_bridge_vlan *v;
 
 	spin_lock_bh(&br->hash_lock);
 
@@ -264,20 +267,18 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 		fdb_delete_local(br, NULL, f);
 
 	fdb_insert(br, NULL, newaddr, 0);
-
+	vg = br_vlan_group(br);
+	if (!vg)
+		goto out;
 	/* Now remove and add entries for every VLAN configured on the
 	 * bridge.  This function runs under RTNL so the bitmap will not
 	 * change from under us.
 	 */
-	pv = br_get_vlan_info(br);
-	if (!pv)
-		goto out;
-
-	for_each_set_bit_from(vid, pv->vlan_bitmap, VLAN_N_VID) {
-		f = __br_fdb_get(br, br->dev->dev_addr, vid);
+	list_for_each_entry(v, &vg->vlan_list, vlist) {
+		f = __br_fdb_get(br, br->dev->dev_addr, v->vid);
 		if (f && f->is_local && !f->dst)
 			fdb_delete_local(br, NULL, f);
-		fdb_insert(br, NULL, newaddr, vid);
+		fdb_insert(br, NULL, newaddr, v->vid);
 	}
 out:
 	spin_unlock_bh(&br->hash_lock);
@@ -842,9 +843,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	       struct net_device *dev,
 	       const unsigned char *addr, u16 vid, u16 nlh_flags)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p;
+	struct net_bridge_vlan *v;
 	int err = 0;
-	struct net_port_vlans *pv;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
@@ -863,9 +865,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	pv = nbp_get_vlan_info(p);
+	vg = nbp_vlan_group(p);
 	if (vid) {
-		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
+		v = br_vlan_find(vg, vid);
+		if (!v) {
 			pr_info("bridge: RTM_NEWNEIGH with unconfigured "
 				"vlan %d on port %s\n", vid, dev->name);
 			return -EINVAL;
@@ -875,15 +878,15 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
-		if (err || !pv)
+		if (err || !vg || list_empty(&vg->vlan_list))
 			goto out;
 
 		/* We have vlans configured on this port and user didn't
 		 * specify a VLAN.  To be nice, add/update entry for every
 		 * vlan on this port.
 		 */
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
+		list_for_each_entry(v, &vg->vlan_list, vlist) {
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, v->vid);
 			if (err)
 				goto out;
 		}
@@ -925,9 +928,10 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  struct net_device *dev,
 		  const unsigned char *addr, u16 vid)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_port *p;
+	struct net_bridge_vlan *v;
 	int err;
-	struct net_port_vlans *pv;
 
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
@@ -936,9 +940,10 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	pv = nbp_get_vlan_info(p);
+	vg = nbp_vlan_group(p);
 	if (vid) {
-		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
+		v = br_vlan_find(vg, vid);
+		if (!v) {
 			pr_info("bridge: RTM_DELNEIGH with unconfigured "
 				"vlan %d on port %s\n", vid, dev->name);
 			return -EINVAL;
@@ -948,16 +953,11 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	} else {
 		err = -ENOENT;
 		err &= __br_fdb_delete(p, addr, 0);
-		if (!pv)
+		if (!vg || list_empty(&vg->vlan_list))
 			goto out;
 
-		/* We have vlans configured on this port and user didn't
-		 * specify a VLAN.  To be nice, add/update entry for every
-		 * vlan on this port.
-		 */
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			err &= __br_fdb_delete(p, addr, vid);
-		}
+		list_for_each_entry(v, &vg->vlan_list, vlist)
+			err &= __br_fdb_delete(p, addr, v->vid);
 	}
 out:
 	return err;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index fa7bfced888e..dc064e2375c6 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -30,9 +30,11 @@ static int deliver_clone(const struct net_bridge_port *prev,
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
+	struct net_bridge_vlan_group *vg;
+
+	vg = nbp_vlan_group(p);
 	return ((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
-		br_allowed_egress(p->br, nbp_get_vlan_info(p), skb) &&
-		p->state == BR_STATE_FORWARDING;
+		br_allowed_egress(vg, skb) && p->state == BR_STATE_FORWARDING;
 }
 
 int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
@@ -76,7 +78,10 @@ EXPORT_SYMBOL_GPL(br_forward_finish);
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
-	skb = br_handle_vlan(to->br, nbp_get_vlan_info(to), skb);
+	struct net_bridge_vlan_group *vg;
+
+	vg = nbp_vlan_group(to);
+	skb = br_handle_vlan(to->br, vg, skb);
 	if (!skb)
 		return;
 
@@ -99,6 +104,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_device *indev;
 
 	if (skb_warn_if_lro(skb)) {
@@ -106,7 +112,8 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	skb = br_handle_vlan(to->br, nbp_get_vlan_info(to), skb);
+	vg = nbp_vlan_group(to);
+	skb = br_handle_vlan(to->br, vg, skb);
 	if (!skb)
 		return;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5dce22d..250311ef224f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -30,28 +30,28 @@ static int br_pass_frame_up(struct sk_buff *skb)
 {
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(brdev);
+	struct net_bridge_vlan_group *vg;
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
-	struct net_port_vlans *pv;
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
 	brstats->rx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	vg = br_vlan_group(br);
 	/* Bridge is just like any other port.  Make sure the
 	 * packet is allowed except in promisc modue when someone
 	 * may be running packet capture.
 	 */
-	pv = br_get_vlan_info(br);
 	if (!(brdev->flags & IFF_PROMISC) &&
-	    !br_allowed_egress(br, pv, skb)) {
+	    !br_allowed_egress(vg, skb)) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
 
 	indev = skb->dev;
 	skb->dev = brdev;
-	skb = br_handle_vlan(br, pv, skb);
+	skb = br_handle_vlan(br, vg, skb);
 	if (!skb)
 		return NET_RX_DROP;
 
@@ -134,7 +134,7 @@ int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb)
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
+	if (!nbp_allowed_ingress(p, skb, &vid))
 		goto out;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index d747275fad18..92c59cbd5c31 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -464,11 +464,11 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	unsigned short vid = VLAN_N_VID;
+	const struct list_head *vlan_list;
 	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
 	struct net_bridge_port *p;
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan *v;
 	struct net_bridge *br;
 	int err;
 
@@ -489,10 +489,10 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
-	pv = nbp_get_vlan_info(p);
-	if (br_vlan_enabled(br) && pv && entry->vid == 0) {
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			entry->vid = vid;
+	vlan_list = nbp_vlan_list(p);
+	if (br_vlan_enabled(br) && vlan_list && entry->vid == 0) {
+		list_for_each_entry(v, vlan_list, vlist) {
+			entry->vid = v->vid;
 			err = __br_mdb_add(net, br, entry);
 			if (err)
 				break;
@@ -566,11 +566,11 @@ unlock:
 static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	unsigned short vid = VLAN_N_VID;
+	const struct list_head *vlan_list;
 	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
 	struct net_bridge_port *p;
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan *v;
 	struct net_bridge *br;
 	int err;
 
@@ -591,10 +591,10 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!p || p->br != br || p->state == BR_STATE_DISABLED)
 		return -EINVAL;
 
-	pv = nbp_get_vlan_info(p);
-	if (br_vlan_enabled(br) && pv && entry->vid == 0) {
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			entry->vid = vid;
+	vlan_list = nbp_vlan_list(p);
+	if (br_vlan_enabled(br) && vlan_list && entry->vid == 0) {
+		list_for_each_entry(v, vlan_list, vlist) {
+			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
 			if (!err)
 				__br_mdb_notify(dev, entry, RTM_DELMDB);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ea748c93a07f..80687028280c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -21,36 +21,35 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-static int br_get_num_vlan_infos(const struct net_port_vlans *pv,
-				 u32 filter_mask)
+static int __get_num_vlan_infos(struct list_head *vlan_list, u32 filter_mask,
+				u16 pvid)
 {
-	u16 vid_range_start = 0, vid_range_end = 0;
-	u16 vid_range_flags = 0;
-	u16 pvid, vid, flags;
+	struct net_bridge_vlan *v;
+	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
+	u16 flags;
 	int num_vlans = 0;
 
-	if (filter_mask & RTEXT_FILTER_BRVLAN)
-		return pv->num_vlans;
-
 	if (!(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
 		return 0;
 
-	/* Count number of vlan info's
-	 */
-	pvid = br_get_pvid(pv);
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+	/* Count number of vlan infos */
+	list_for_each_entry(v, vlan_list, vlist) {
 		flags = 0;
-		if (vid == pvid)
+		/* only a context, bridge vlan not activated */
+		if (v->flags & BRIDGE_VLAN_INFO_MASTER &&
+		    !(v->flags & BRIDGE_VLAN_INFO_MASTERVL))
+			continue;
+		if (v->vid == pvid)
 			flags |= BRIDGE_VLAN_INFO_PVID;
 
-		if (test_bit(vid, pv->untagged_bitmap))
+		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 			flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (vid_range_start == 0) {
 			goto initvars;
-		} else if ((vid - vid_range_end) == 1 &&
+		} else if ((v->vid - vid_range_end) == 1 &&
 			flags == vid_range_flags) {
-			vid_range_end = vid;
+			vid_range_end = v->vid;
 			continue;
 		} else {
 			if ((vid_range_end - vid_range_start) > 0)
@@ -59,8 +58,8 @@ static int br_get_num_vlan_infos(const struct net_port_vlans *pv,
 				num_vlans += 1;
 		}
 initvars:
-		vid_range_start = vid;
-		vid_range_end = vid;
+		vid_range_start = v->vid;
+		vid_range_end = v->vid;
 		vid_range_flags = flags;
 	}
 
@@ -74,28 +73,40 @@ initvars:
 	return num_vlans;
 }
 
+static int br_get_num_vlan_infos(struct net_bridge_vlan_group *vg,
+				 u32 filter_mask, u16 pvid)
+{
+	if (!vg)
+		return 0;
+
+	if (filter_mask & RTEXT_FILTER_BRVLAN)
+		return vg->num_vlans;
+
+	return __get_num_vlan_infos(&vg->vlan_list, filter_mask, pvid);
+}
+
 static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 					   u32 filter_mask)
 {
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan_group *vg = NULL;
+	struct net_bridge_port *p;
+	struct net_bridge *br;
 	int num_vlan_infos;
+	u16 pvid = 0;
 
 	rcu_read_lock();
-	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rcu(dev));
-	else if (dev->priv_flags & IFF_EBRIDGE)
-		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
-	else
-		pv = NULL;
-	if (pv)
-		num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
-	else
-		num_vlan_infos = 0;
+	if (br_port_exists(dev)) {
+		p = br_port_get_rcu(dev);
+		vg = nbp_vlan_group(p);
+		pvid = nbp_get_pvid(p);
+	} else if (dev->priv_flags & IFF_EBRIDGE) {
+		br = netdev_priv(dev);
+		vg = br_vlan_group(br);
+		pvid = br_get_pvid(br);
+	}
+	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask, pvid);
 	rcu_read_unlock();
 
-	if (!num_vlan_infos)
-		return 0;
-
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
 	return num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info));
 }
@@ -185,31 +196,34 @@ nla_put_failure:
 }
 
 static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
-					 const struct net_port_vlans *pv)
+					 const struct list_head *vlan_list,
+					 u16 pvid)
 {
-	u16 vid_range_start = 0, vid_range_end = 0;
-	u16 vid_range_flags = 0;
-	u16 pvid, vid, flags;
+	struct net_bridge_vlan *v;
+	u16 vid_range_start = 0, vid_range_end = 0, vid_range_flags = 0;
+	u16 flags;
 	int err = 0;
 
 	/* Pack IFLA_BRIDGE_VLAN_INFO's for every vlan
 	 * and mark vlan info with begin and end flags
 	 * if vlaninfo represents a range
 	 */
-	pvid = br_get_pvid(pv);
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+	list_for_each_entry(v, vlan_list, vlist) {
 		flags = 0;
-		if (vid == pvid)
+		if (v->flags & BRIDGE_VLAN_INFO_MASTER &&
+		    !(v->flags & BRIDGE_VLAN_INFO_MASTERVL))
+			continue;
+		if (v->vid == pvid)
 			flags |= BRIDGE_VLAN_INFO_PVID;
 
-		if (test_bit(vid, pv->untagged_bitmap))
+		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 			flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (vid_range_start == 0) {
 			goto initvars;
-		} else if ((vid - vid_range_end) == 1 &&
+		} else if ((v->vid - vid_range_end) == 1 &&
 			flags == vid_range_flags) {
-			vid_range_end = vid;
+			vid_range_end = v->vid;
 			continue;
 		} else {
 			err = br_fill_ifvlaninfo_range(skb, vid_range_start,
@@ -220,8 +234,8 @@ static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
 		}
 
 initvars:
-		vid_range_start = vid;
-		vid_range_end = vid;
+		vid_range_start = v->vid;
+		vid_range_end = v->vid;
 		vid_range_flags = flags;
 	}
 
@@ -238,19 +252,23 @@ initvars:
 }
 
 static int br_fill_ifvlaninfo(struct sk_buff *skb,
-			      const struct net_port_vlans *pv)
+			      const struct list_head *vlan_list,
+			      u16 pvid)
 {
 	struct bridge_vlan_info vinfo;
-	u16 pvid, vid;
+	struct net_bridge_vlan *v;
 
-	pvid = br_get_pvid(pv);
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-		vinfo.vid = vid;
+	list_for_each_entry(v, vlan_list, vlist) {
+		if (v->flags & BRIDGE_VLAN_INFO_MASTER &&
+		    !(v->flags & BRIDGE_VLAN_INFO_MASTERVL))
+			continue;
+
+		vinfo.vid = v->vid;
 		vinfo.flags = 0;
-		if (vid == pvid)
+		if (v->vid == pvid)
 			vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
 
-		if (test_bit(vid, pv->untagged_bitmap))
+		if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 			vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 
 		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
@@ -269,11 +287,11 @@ nla_put_failure:
  * Contains port and master info as well as carrier and bridge state.
  */
 static int br_fill_ifinfo(struct sk_buff *skb,
-			  const struct net_bridge_port *port,
+			  struct net_bridge_port *port,
 			  u32 pid, u32 seq, int event, unsigned int flags,
 			  u32 filter_mask, const struct net_device *dev)
 {
-	const struct net_bridge *br;
+	struct net_bridge *br;
 	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
@@ -320,16 +338,20 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	/* Check if  the VID information is requested */
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		const struct net_port_vlans *pv;
+		const struct list_head *vlan_list;
 		struct nlattr *af;
+		u16 pvid;
 		int err;
 
-		if (port)
-			pv = nbp_get_vlan_info(port);
-		else
-			pv = br_get_vlan_info(br);
+		if (port) {
+			vlan_list = nbp_vlan_list(port);
+			pvid = nbp_get_pvid(port);
+		} else {
+			vlan_list = br_vlan_list(br);
+			pvid = br_get_pvid(br);
+		}
 
-		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
+		if (!vlan_list || list_empty(vlan_list))
 			goto done;
 
 		af = nla_nest_start(skb, IFLA_AF_SPEC);
@@ -337,9 +359,10 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			goto nla_put_failure;
 
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
-			err = br_fill_ifvlaninfo_compressed(skb, pv);
+			err = br_fill_ifvlaninfo_compressed(skb, vlan_list,
+							    pvid);
 		else
-			err = br_fill_ifvlaninfo(skb, pv);
+			err = br_fill_ifvlaninfo(skb, vlan_list, pvid);
 		if (err)
 			goto nla_put_failure;
 		nla_nest_end(skb, af);
@@ -416,12 +439,9 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 			if (err)
 				break;
-
-			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-				err = br_vlan_add(p->br, vinfo->vid,
-						  vinfo->flags);
 		} else {
-			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
+			err = br_vlan_add(br, vinfo->vid, vinfo->flags |
+							  BRIDGE_VLAN_INFO_MASTERVL);
 		}
 		break;
 
@@ -857,20 +877,22 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 
 static size_t br_get_link_af_size(const struct net_device *dev)
 {
-	struct net_port_vlans *pv;
-
-	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
-	else if (dev->priv_flags & IFF_EBRIDGE)
-		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
-	else
-		return 0;
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+	int num_vlans = 0;
 
-	if (!pv)
-		return 0;
+	if (br_port_exists(dev)) {
+		p = br_port_get_rtnl(dev);
+		num_vlans = br_get_num_vlan_infos(nbp_vlan_group(p),
+						  RTEXT_FILTER_BRVLAN, 0);
+	} else if (dev->priv_flags & IFF_EBRIDGE) {
+		br = netdev_priv(dev);
+		num_vlans = br_get_num_vlan_infos(br_vlan_group(br),
+						  RTEXT_FILTER_BRVLAN, 0);
+	}
 
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
 }
 
 static struct rtnl_af_ops br_af_ops __read_mostly = {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 213baf7aaa93..1bd24378473e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -20,6 +20,7 @@
 #include <net/route.h>
 #include <net/ip6_fib.h>
 #include <linux/if_vlan.h>
+#include <linux/rhashtable.h>
 
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -28,7 +29,6 @@
 
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
-#define BR_VLAN_BITMAP_LEN	BITS_TO_LONGS(VLAN_N_VID)
 
 #define BR_VERSION	"2.3"
 
@@ -77,16 +77,26 @@ struct bridge_mcast_querier {
 };
 #endif
 
-struct net_port_vlans {
-	u16				port_idx;
-	u16				pvid;
+struct net_bridge_vlan {
+	struct rhash_head		vnode;
+	u16				vid;
+	u16				flags;
+	union {
+		struct net_bridge	*br;
+		struct net_bridge_port	*port;
+	};
 	union {
-		struct net_bridge_port		*port;
-		struct net_bridge		*br;
-	}				parent;
+		atomic_t		refcnt;
+		struct net_bridge_vlan	*brvlan;
+	};
+	struct list_head		vlist;
+
 	struct rcu_head			rcu;
-	unsigned long			vlan_bitmap[BR_VLAN_BITMAP_LEN];
-	unsigned long			untagged_bitmap[BR_VLAN_BITMAP_LEN];
+};
+
+struct net_bridge_vlan_group {
+	struct rhashtable		vlan_hash;
+	struct list_head		vlan_list;
 	u16				num_vlans;
 };
 
@@ -185,7 +195,8 @@ struct net_bridge_port
 	struct netpoll			*np;
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_port_vlans __rcu	*vlan_info;
+	struct net_bridge_vlan_group	*vlgrp;
+	u16				pvid;
 #endif
 };
 
@@ -293,10 +304,11 @@ struct net_bridge
 	struct kobject			*ifobj;
 	u32				auto_cnt;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	struct net_bridge_vlan_group	*vlgrp;
 	u8				vlan_enabled;
 	__be16				vlan_proto;
 	u16				default_pvid;
-	struct net_port_vlans __rcu	*vlan_info;
+	u16				pvid;
 #endif
 };
 
@@ -601,18 +613,19 @@ static inline void br_mdb_uninit(void)
 
 /* br_vlan.c */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			struct sk_buff *skb, u16 *vid);
-bool br_allowed_egress(struct net_bridge *br, const struct net_port_vlans *v,
+bool br_allowed_ingress(struct net_bridge *br, struct sk_buff *skb, u16 *vid);
+bool nbp_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
+			 u16 *vid);
+bool br_allowed_egress(struct net_bridge_vlan_group *br,
 		       const struct sk_buff *skb);
 bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid);
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
-			       const struct net_port_vlans *v,
+			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb);
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags);
 int br_vlan_delete(struct net_bridge *br, u16 vid);
 void br_vlan_flush(struct net_bridge *br);
-bool br_vlan_find(struct net_bridge *br, u16 vid);
+struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid);
 void br_recalculate_fwd_mask(struct net_bridge *br);
 int __br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
@@ -623,19 +636,18 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
-bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
 int nbp_vlan_init(struct net_bridge_port *port);
+int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
 
-static inline struct net_port_vlans *br_get_vlan_info(
-						const struct net_bridge *br)
+static inline struct net_bridge_vlan_group *br_vlan_group(struct net_bridge *br)
 {
-	return rcu_dereference_rtnl(br->vlan_info);
+	return br->vlgrp;
 }
 
-static inline struct net_port_vlans *nbp_get_vlan_info(
-						const struct net_bridge_port *p)
+static inline struct net_bridge_vlan_group *nbp_vlan_group(
+					const struct net_bridge_port *p)
 {
-	return rcu_dereference_rtnl(p->vlan_info);
+	return p->vlgrp;
 }
 
 /* Since bridge now depends on 8021Q module, but the time bridge sees the
@@ -645,9 +657,9 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 {
 	int err = 0;
 
-	if (skb_vlan_tag_present(skb))
+	if (skb_vlan_tag_present(skb)) {
 		*vid = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
-	else {
+	} else {
 		*vid = 0;
 		err = -EINVAL;
 	}
@@ -655,30 +667,59 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 	return err;
 }
 
-static inline u16 br_get_pvid(const struct net_port_vlans *v)
+static inline u16 br_get_pvid(const struct net_bridge *br)
+{
+	if (!br)
+		return 0;
+
+	smp_rmb();
+	return br->pvid;
+}
+
+static inline u16 nbp_get_pvid(const struct net_bridge_port *p)
 {
-	if (!v)
+	if (!p)
 		return 0;
 
 	smp_rmb();
-	return v->pvid;
+	return p->pvid;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return br->vlan_enabled;
 }
+
+static inline bool br_vlan_is_master(struct net_bridge_vlan *v)
+{
+	return v->flags & BRIDGE_VLAN_INFO_MASTER;
+}
+
+static inline struct list_head *br_vlan_list(struct net_bridge *br)
+{
+	return &br->vlgrp->vlan_list;
+}
+
+static inline struct list_head *nbp_vlan_list(struct net_bridge_port *p)
+{
+	return &p->vlgrp->vlan_list;
+}
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
-				      struct net_port_vlans *v,
 				      struct sk_buff *skb,
 				      u16 *vid)
 {
 	return true;
 }
 
-static inline bool br_allowed_egress(struct net_bridge *br,
-				     const struct net_port_vlans *v,
+static inline bool nbp_allowed_ingress(struct net_bridge_port *p,
+				       struct sk_buff *skb,
+				       u16 *vid)
+{
+	return true;
+}
+
+static inline bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 				     const struct sk_buff *skb)
 {
 	return true;
@@ -691,7 +732,7 @@ static inline bool br_should_learn(struct net_bridge_port *p,
 }
 
 static inline struct sk_buff *br_handle_vlan(struct net_bridge *br,
-					     const struct net_port_vlans *v,
+					     struct net_bridge_vlan_group *vg,
 					     struct sk_buff *skb)
 {
 	return skb;
@@ -711,11 +752,6 @@ static inline void br_vlan_flush(struct net_bridge *br)
 {
 }
 
-static inline bool br_vlan_find(struct net_bridge *br, u16 vid)
-{
-	return false;
-}
-
 static inline void br_recalculate_fwd_mask(struct net_bridge *br)
 {
 }
@@ -739,32 +775,28 @@ static inline void nbp_vlan_flush(struct net_bridge_port *port)
 {
 }
 
-static inline struct net_port_vlans *br_get_vlan_info(
-						const struct net_bridge *br)
-{
-	return NULL;
-}
-static inline struct net_port_vlans *nbp_get_vlan_info(
-						const struct net_bridge_port *p)
+static inline struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg,
+						   u16 vid)
 {
 	return NULL;
 }
 
-static inline bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
+static inline int nbp_vlan_init(struct net_bridge_port *port)
 {
-	return false;
+	return 0;
 }
 
-static inline int nbp_vlan_init(struct net_bridge_port *port)
+static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
 {
 	return 0;
 }
 
-static inline u16 br_vlan_get_tag(const struct sk_buff *skb, u16 *tag)
+static inline u16 br_get_pvid(const struct net_bridge *br)
 {
 	return 0;
 }
-static inline u16 br_get_pvid(const struct net_port_vlans *v)
+
+static inline u16 nbp_get_pvid(const struct net_bridge_port *p)
 {
 	return 0;
 }
@@ -779,6 +811,33 @@ static inline int __br_vlan_filter_toggle(struct net_bridge *br,
 {
 	return -EOPNOTSUPP;
 }
+
+static inline int nbp_get_num_vlan_infos(struct net_bridge_port *p,
+					 u32 filter_mask)
+{
+	return 0;
+}
+
+static inline struct list_head *br_vlan_list(struct net_bridge *br)
+{
+	return NULL;
+}
+
+static inline struct list_head *nbp_vlan_list(struct net_bridge_port *p)
+{
+	return NULL;
+}
+
+static inline struct net_bridge_vlan_group *br_vlan_group(struct net_bridge *br)
+{
+	return NULL;
+}
+
+static inline struct net_bridge_vlan_group *nbp_vlan_group(
+					const struct net_bridge_port *p)
+{
+	return NULL;
+}
 #endif
 
 struct nf_br_ops {
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 5f5a02b49a99..b865dea3c8f8 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -6,35 +6,65 @@
 
 #include "br_private.h"
 
-static void __vlan_add_pvid(struct net_port_vlans *v, u16 vid)
+static inline int br_vlan_cmp(struct rhashtable_compare_arg *arg,
+			      const void *ptr)
 {
-	if (v->pvid == vid)
+	const struct net_bridge_vlan *vle = ptr;
+	u16 vid = *(u16 *)arg->key;
+
+	return vle->vid != vid;
+}
+
+static const struct rhashtable_params br_vlan_rht_params = {
+	.head_offset = offsetof(struct net_bridge_vlan, vnode),
+	.key_offset = offsetof(struct net_bridge_vlan, vid),
+	.key_len = sizeof(u16),
+	.max_size = VLAN_N_VID,
+	.obj_cmpfn = br_vlan_cmp,
+	.automatic_shrinking = true,
+};
+
+static struct net_bridge_vlan *br_vlan_lookup(struct rhashtable *tbl, u16 vid)
+{
+	return rhashtable_lookup_fast(tbl, &vid, br_vlan_rht_params);
+}
+
+static void __vlan_add_pvid(u16 *pvid, u16 vid)
+{
+	if (*pvid == vid)
 		return;
 
 	smp_wmb();
-	v->pvid = vid;
+	*pvid = vid;
 }
 
-static void __vlan_delete_pvid(struct net_port_vlans *v, u16 vid)
+static void __vlan_delete_pvid(u16 *pvid, u16 vid)
 {
-	if (v->pvid != vid)
+	if (*pvid != vid)
 		return;
 
 	smp_wmb();
-	v->pvid = 0;
+	*pvid = 0;
 }
 
-static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
+static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 {
-	if (flags & BRIDGE_VLAN_INFO_PVID)
-		__vlan_add_pvid(v, vid);
-	else
-		__vlan_delete_pvid(v, vid);
+	if (flags & BRIDGE_VLAN_INFO_PVID) {
+		if (br_vlan_is_master(v))
+			__vlan_add_pvid(&v->br->pvid, v->vid);
+		else
+			__vlan_add_pvid(&v->port->pvid, v->vid);
+	} else {
+		if (br_vlan_is_master(v))
+			__vlan_delete_pvid(&v->br->pvid, v->vid);
+		else
+			__vlan_delete_pvid(&v->port->pvid, v->vid);
+	}
 
 	if (flags & BRIDGE_VLAN_INFO_UNTAGGED)
-		set_bit(vid, v->untagged_bitmap);
+		v->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 	else
-		clear_bit(vid, v->untagged_bitmap);
+		v->flags &= ~BRIDGE_VLAN_INFO_UNTAGGED;
 }
 
 static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
@@ -67,54 +97,26 @@ static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 	return err;
 }
 
-static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
+static void __vlan_add_list(struct net_bridge_vlan *v)
 {
-	struct net_bridge_port *p = NULL;
-	struct net_bridge *br;
-	struct net_device *dev;
-	int err;
-
-	if (test_bit(vid, v->vlan_bitmap)) {
-		__vlan_add_flags(v, vid, flags);
-		return 0;
-	}
-
-	if (v->port_idx) {
-		p = v->parent.port;
-		br = p->br;
-		dev = p->dev;
-	} else {
-		br = v->parent.br;
-		dev = br->dev;
-	}
-
-	if (p) {
-		/* Add VLAN to the device filter if it is supported.
-		 * This ensures tagged traffic enters the bridge when
-		 * promiscuous mode is disabled by br_manage_promisc().
-		 */
-		err = __vlan_vid_add(dev, br, vid, flags);
-		if (err)
-			return err;
-	}
+	struct list_head *headp, *hpos;
+	struct net_bridge_vlan *prev;
 
-	err = br_fdb_insert(br, p, dev->dev_addr, vid);
-	if (err) {
-		br_err(br, "failed insert local address into bridge "
-		       "forwarding table\n");
-		goto out_filt;
+	headp = br_vlan_is_master(v) ? &v->br->vlgrp->vlan_list :
+				       &v->port->vlgrp->vlan_list;
+	list_for_each_prev(hpos, headp) {
+		prev = list_entry(hpos, struct net_bridge_vlan, vlist);
+		if (v->vid < prev->vid)
+			continue;
+		else
+			break;
 	}
+	list_add(&v->vlist, hpos);
+}
 
-	set_bit(vid, v->vlan_bitmap);
-	v->num_vlans++;
-	__vlan_add_flags(v, vid, flags);
-
-	return 0;
-
-out_filt:
-	if (p)
-		vlan_vid_del(dev, br->vlan_proto, vid);
-	return err;
+static void __vlan_del_list(struct net_bridge_vlan *v)
+{
+	list_del(&v->vlist);
 }
 
 static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
@@ -146,63 +148,177 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	return err;
 }
 
-static int __vlan_del(struct net_port_vlans *v, u16 vid)
+
+static int __vlan_add(struct net_bridge_vlan *v, u16 flags)
 {
-	if (!test_bit(vid, v->vlan_bitmap))
-		return -EINVAL;
+	struct net_bridge_vlan *masterv = NULL;
+	struct net_bridge_port *p = NULL;
+	struct rhashtable *tbl;
+	struct net_device *dev;
+	struct net_bridge *br;
+	int err;
+
+	if (br_vlan_is_master(v)) {
+		br = v->br;
+		dev = br->dev;
+		tbl = &br->vlgrp->vlan_hash;
+	} else {
+		p = v->port;
+		br = p->br;
+		dev = p->dev;
+		tbl = &p->vlgrp->vlan_hash;
+	}
+
+	if (p) {
+		u16 master_flags = flags;
+
+		/* Add VLAN to the device filter if it is supported.
+		 * This ensures tagged traffic enters the bridge when
+		 * promiscuous mode is disabled by br_manage_promisc().
+		 */
+		err = __vlan_vid_add(dev, br, v->vid, flags);
+		if (err)
+			goto out;
+
+		/* need to work on the master vlan too */
+		if (flags & BRIDGE_VLAN_INFO_MASTER) {
+			master_flags |= BRIDGE_VLAN_INFO_MASTERVL;
+			err = br_vlan_add(br, v->vid, master_flags);
+			if (err)
+				goto out_filt;
+		}
+
+		masterv = br_vlan_find(br->vlgrp, v->vid);
+		if (!masterv) {
+			/* missing global ctx, create it now */
+			err = br_vlan_add(br, v->vid, master_flags);
+			if (err)
+				goto out_filt;
+			masterv = br_vlan_find(br->vlgrp, v->vid);
+			WARN_ON(!masterv);
+		}
+		atomic_inc(&masterv->refcnt);
+		v->brvlan = masterv;
+	}
+
+	err = br_fdb_insert(br, p, dev->dev_addr, v->vid);
+	if (err) {
+		br_err(br, "failed insert local address into bridge forwarding table\n");
+		goto out_filt;
+	}
+
+	err = rhashtable_lookup_insert_fast(tbl, &v->vnode, br_vlan_rht_params);
+	if (err)
+		goto out_fdb_insert;
+
+	__vlan_add_list(v);
+	__vlan_add_flags(v, flags);
+	if (br_vlan_is_master(v))
+		br->vlgrp->num_vlans++;
+	else
+		p->vlgrp->num_vlans++;
+
+out:
+	return err;
+
+out_fdb_insert:
+	br_fdb_find_delete_local(br, p, br->dev->dev_addr, v->vid);
+
+out_filt:
+	if (p) {
+		__vlan_vid_del(dev, br, v->vid);
+		if (masterv) {
+			atomic_dec(&masterv->refcnt);
+			v->brvlan = NULL;
+		}
+	}
+
+	goto out;
+}
 
-	__vlan_delete_pvid(v, vid);
-	clear_bit(vid, v->untagged_bitmap);
+static int __vlan_del(struct net_bridge_vlan *v)
+{
+	struct net_bridge_vlan *masterv = v;
+	struct net_bridge_port *p = NULL;
+	struct net_bridge *br;
+	int err = 0;
+	struct rhashtable *tbl;
+	u16 *pvid;
 
-	if (v->port_idx) {
-		struct net_bridge_port *p = v->parent.port;
-		int err;
+	if (br_vlan_is_master(v)) {
+		br = v->br;
+		tbl = &v->br->vlgrp->vlan_hash;
+		pvid = &v->br->pvid;
+	} else {
+		p = v->port;
+		br = p->br;
+		tbl = &p->vlgrp->vlan_hash;
+		masterv = v->brvlan;
+		pvid = &p->pvid;
+	}
 
-		err = __vlan_vid_del(p->dev, p->br, vid);
+	__vlan_delete_pvid(pvid, v->vid);
+	if (p) {
+		err = __vlan_vid_del(p->dev, p->br, v->vid);
 		if (err)
-			return err;
+			goto out;
 	}
 
-	clear_bit(vid, v->vlan_bitmap);
-	v->num_vlans--;
-	if (bitmap_empty(v->vlan_bitmap, VLAN_N_VID)) {
-		if (v->port_idx)
-			RCU_INIT_POINTER(v->parent.port->vlan_info, NULL);
-		else
-			RCU_INIT_POINTER(v->parent.br->vlan_info, NULL);
+	if (br_vlan_is_master(v))
+		br->vlgrp->num_vlans--;
+	else
+		p->vlgrp->num_vlans--;
+
+	if (masterv != v) {
+		rhashtable_remove_fast(tbl, &v->vnode, br_vlan_rht_params);
+		__vlan_del_list(v);
 		kfree_rcu(v, rcu);
 	}
-	return 0;
+
+	if (atomic_dec_and_test(&masterv->refcnt)) {
+		rhashtable_remove_fast(&masterv->br->vlgrp->vlan_hash,
+				       &masterv->vnode, br_vlan_rht_params);
+		__vlan_del_list(masterv);
+		kfree_rcu(masterv, rcu);
+	}
+out:
+	return err;
 }
 
-static void __vlan_flush(struct net_port_vlans *v)
+static void __vlan_flush(struct net_bridge_vlan_group *vlgrp, u16 *pvid)
 {
-	smp_wmb();
-	v->pvid = 0;
-	bitmap_zero(v->vlan_bitmap, VLAN_N_VID);
-	if (v->port_idx)
-		RCU_INIT_POINTER(v->parent.port->vlan_info, NULL);
-	else
-		RCU_INIT_POINTER(v->parent.br->vlan_info, NULL);
-	kfree_rcu(v, rcu);
+	struct net_bridge_vlan *vlan, *tmp;
+
+	__vlan_delete_pvid(pvid, *pvid);
+	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
+		__vlan_del(vlan);
+	rhashtable_destroy(&vlgrp->vlan_hash);
+	kfree(vlgrp);
 }
 
 struct sk_buff *br_handle_vlan(struct net_bridge *br,
-			       const struct net_port_vlans *pv,
+			       struct net_bridge_vlan_group *vg,
 			       struct sk_buff *skb)
 {
+	struct net_bridge_vlan *v;
 	u16 vid;
 
 	/* If this packet was not filtered at input, let it pass */
 	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		goto out;
 
-	/* Vlan filter table must be configured at this point.  The
+	/* At this point, we know that the frame was filtered and contains
+	 * a valid vlan id.  If the vlan id has untagged flag set,
+	 * send untagged; otherwise, send tagged.
+	 */
+	br_vlan_get_tag(skb, &vid);
+	v = br_vlan_find(vg, vid);
+	/* Vlan table must be configured at this point.  The
 	 * only exception is the bridge is set in promisc mode and the
 	 * packet is destined for the bridge device.  In this case
 	 * pass the packet as is.
 	 */
-	if (!pv) {
+	if (!v) {
 		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev) {
 			goto out;
 		} else {
@@ -210,13 +326,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 			return NULL;
 		}
 	}
-
-	/* At this point, we know that the frame was filtered and contains
-	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
-	 * send untagged; otherwise, send tagged.
-	 */
-	br_vlan_get_tag(skb, &vid);
-	if (test_bit(vid, pv->untagged_bitmap))
+	if (v->flags & BRIDGE_VLAN_INFO_UNTAGGED)
 		skb->vlan_tci = 0;
 
 out:
@@ -224,29 +334,12 @@ out:
 }
 
 /* Called under RCU */
-bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			struct sk_buff *skb, u16 *vid)
+static bool __allowed_ingress(struct rhashtable *tbl, u16 pvid, __be16 proto,
+			      struct sk_buff *skb, u16 *vid)
 {
 	bool tagged;
-	__be16 proto;
-
-	/* If VLAN filtering is disabled on the bridge, all packets are
-	 * permitted.
-	 */
-	if (!br->vlan_enabled) {
-		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
-		return true;
-	}
-
-	/* If there are no vlan in the permitted list, all packets are
-	 * rejected.
-	 */
-	if (!v)
-		goto drop;
 
 	BR_INPUT_SKB_CB(skb)->vlan_filtered = true;
-	proto = br->vlan_proto;
-
 	/* If vlan tx offload is disabled on bridge device and frame was
 	 * sent from vlan device on the bridge device, it does not have
 	 * HW accelerated vlan tag.
@@ -281,8 +374,6 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	}
 
 	if (!*vid) {
-		u16 pvid = br_get_pvid(v);
-
 		/* Frame had a tag with VID 0 or did not have a tag.
 		 * See if pvid is set on this port.  That tells us which
 		 * vlan untagged or priority-tagged traffic belongs to.
@@ -309,16 +400,46 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	}
 
 	/* Frame had a valid vlan tag.  See if vlan is allowed */
-	if (test_bit(*vid, v->vlan_bitmap))
+	if (br_vlan_lookup(tbl, *vid))
 		return true;
 drop:
 	kfree_skb(skb);
 	return false;
 }
 
+bool br_allowed_ingress(struct net_bridge *br, struct sk_buff *skb, u16 *vid)
+{
+	/* If VLAN filtering is disabled on the bridge, all packets are
+	 * permitted.
+	 */
+	if (!br->vlan_enabled) {
+		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
+		return true;
+	}
+
+	return __allowed_ingress(&br->vlgrp->vlan_hash, br->pvid,
+				 br->vlan_proto, skb, vid);
+}
+
+bool nbp_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb,
+			 u16 *vid)
+{
+	struct net_bridge *br = p->br;
+
+	/* If VLAN filtering is disabled on the bridge, all packets are
+	 * permitted.
+	 */
+	if (!br->vlan_enabled) {
+		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
+		return true;
+	}
+
+	return __allowed_ingress(&p->vlgrp->vlan_hash, p->pvid, br->vlan_proto,
+				 skb, vid);
+}
+
 /* Called under RCU. */
-bool br_allowed_egress(struct net_bridge *br,
-		       const struct net_port_vlans *v,
+bool br_allowed_egress(struct net_bridge_vlan_group *vg,
 		       const struct sk_buff *skb)
 {
 	u16 vid;
@@ -327,11 +448,8 @@ bool br_allowed_egress(struct net_bridge *br,
 	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		return true;
 
-	if (!v)
-		return false;
-
 	br_vlan_get_tag(skb, &vid);
-	if (test_bit(vid, v->vlan_bitmap))
+	if (br_vlan_find(vg, vid))
 		return true;
 
 	return false;
@@ -341,28 +459,26 @@ bool br_allowed_egress(struct net_bridge *br,
 bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 {
 	struct net_bridge *br = p->br;
-	struct net_port_vlans *v;
 
 	/* If filtering was disabled at input, let it pass. */
 	if (!br->vlan_enabled)
 		return true;
 
-	v = rcu_dereference(p->vlan_info);
-	if (!v)
+	if (!p->vlgrp->num_vlans)
 		return false;
 
 	if (!br_vlan_get_tag(skb, vid) && skb->vlan_proto != br->vlan_proto)
 		*vid = 0;
 
 	if (!*vid) {
-		*vid = br_get_pvid(v);
+		*vid = nbp_get_pvid(p);
 		if (!*vid)
 			return false;
 
 		return true;
 	}
 
-	if (test_bit(*vid, v->vlan_bitmap))
+	if (br_vlan_find(p->vlgrp, *vid))
 		return true;
 
 	return false;
@@ -373,31 +489,41 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
  */
 int br_vlan_add(struct net_bridge *br, u16 vid, u16 flags)
 {
-	struct net_port_vlans *pv = NULL;
-	int err;
+	struct net_bridge_vlan *vlan;
+	int ret;
 
 	ASSERT_RTNL();
 
-	pv = rtnl_dereference(br->vlan_info);
-	if (pv)
-		return __vlan_add(pv, vid, flags);
+	vlan = br_vlan_find(br->vlgrp, vid);
+	if (vlan) {
+		if (flags & BRIDGE_VLAN_INFO_MASTERVL) {
+			/* It was only kept for port vlans, now make it real */
+			if (!(vlan->flags & BRIDGE_VLAN_INFO_MASTERVL))
+				atomic_inc(&vlan->refcnt);
+			vlan->flags |= BRIDGE_VLAN_INFO_MASTERVL;
+		} else if (!(vlan->flags & BRIDGE_VLAN_INFO_MASTERVL)) {
+			/* Trying to change flags of non-existant bridge vlan */
+			return -EINVAL;
+		}
+		__vlan_add_flags(vlan, flags);
+		return 0;
+	}
 
-	/* Create port vlan infomration
-	 */
-	pv = kzalloc(sizeof(*pv), GFP_KERNEL);
-	if (!pv)
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan)
 		return -ENOMEM;
 
-	pv->parent.br = br;
-	err = __vlan_add(pv, vid, flags);
-	if (err)
-		goto out;
+	vlan->vid = vid;
+	vlan->flags = flags | BRIDGE_VLAN_INFO_MASTER;
+	vlan->flags &= ~BRIDGE_VLAN_INFO_PVID;
+	vlan->br = br;
+	if (flags & BRIDGE_VLAN_INFO_MASTERVL)
+		atomic_set(&vlan->refcnt, 1);
+	ret = __vlan_add(vlan, flags);
+	if (ret)
+		kfree(vlan);
 
-	rcu_assign_pointer(br->vlan_info, pv);
-	return 0;
-out:
-	kfree(pv);
-	return err;
+	return ret;
 }
 
 /* Must be protected by RTNL.
@@ -405,49 +531,33 @@ out:
  */
 int br_vlan_delete(struct net_bridge *br, u16 vid)
 {
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan *v;
 
 	ASSERT_RTNL();
 
-	pv = rtnl_dereference(br->vlan_info);
-	if (!pv)
-		return -EINVAL;
+	v = br_vlan_find(br->vlgrp, vid);
+	if (!v || !(v->flags & BRIDGE_VLAN_INFO_MASTERVL))
+		return -ENOENT;
 
 	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
+	v->flags &= ~BRIDGE_VLAN_INFO_MASTERVL;
 
-	__vlan_del(pv, vid);
-	return 0;
+	return __vlan_del(v);
 }
 
 void br_vlan_flush(struct net_bridge *br)
 {
-	struct net_port_vlans *pv;
-
 	ASSERT_RTNL();
-	pv = rtnl_dereference(br->vlan_info);
-	if (!pv)
-		return;
 
-	__vlan_flush(pv);
+	__vlan_flush(br_vlan_group(br), &br->pvid);
 }
 
-bool br_vlan_find(struct net_bridge *br, u16 vid)
+struct net_bridge_vlan *br_vlan_find(struct net_bridge_vlan_group *vg, u16 vid)
 {
-	struct net_port_vlans *pv;
-	bool found = false;
-
-	rcu_read_lock();
-	pv = rcu_dereference(br->vlan_info);
+	if (!vg)
+		return NULL;
 
-	if (!pv)
-		goto out;
-
-	if (test_bit(vid, pv->vlan_bitmap))
-		found = true;
-
-out:
-	rcu_read_unlock();
-	return found;
+	return br_vlan_lookup(&vg->vlan_hash, vid);
 }
 
 /* Must be protected by RTNL. */
@@ -505,21 +615,16 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 {
 	int err = 0;
 	struct net_bridge_port *p;
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan *vlan;
 	__be16 oldproto;
-	u16 vid, errvid;
 
 	if (br->vlan_proto == proto)
 		return 0;
 
 	/* Add VLANs for the new proto to the device filter. */
 	list_for_each_entry(p, &br->port_list, list) {
-		pv = rtnl_dereference(p->vlan_info);
-		if (!pv)
-			continue;
-
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			err = vlan_vid_add(p->dev, proto, vid);
+		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist) {
+			err = vlan_vid_add(p->dev, proto, vlan->vid);
 			if (err)
 				goto err_filt;
 		}
@@ -532,30 +637,19 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
 	br_recalculate_fwd_mask(br);
 
 	/* Delete VLANs for the old proto from the device filter. */
-	list_for_each_entry(p, &br->port_list, list) {
-		pv = rtnl_dereference(p->vlan_info);
-		if (!pv)
-			continue;
-
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-			vlan_vid_del(p->dev, oldproto, vid);
-	}
+	list_for_each_entry(p, &br->port_list, list)
+		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist)
+			vlan_vid_del(p->dev, oldproto, vlan->vid);
 
 	return 0;
 
 err_filt:
-	errvid = vid;
-	for_each_set_bit(vid, pv->vlan_bitmap, errvid)
-		vlan_vid_del(p->dev, proto, vid);
-
-	list_for_each_entry_continue_reverse(p, &br->port_list, list) {
-		pv = rtnl_dereference(p->vlan_info);
-		if (!pv)
-			continue;
+	list_for_each_entry_continue_reverse(vlan, &p->vlgrp->vlan_list, vlist)
+		vlan_vid_del(p->dev, proto, vlan->vid);
 
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-			vlan_vid_del(p->dev, proto, vid);
-	}
+	list_for_each_entry_continue_reverse(p, &br->port_list, list)
+		list_for_each_entry(vlan, &p->vlgrp->vlan_list, vlist)
+			vlan_vid_del(p->dev, proto, vlan->vid);
 
 	return err;
 }
@@ -576,9 +670,19 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
 	return err;
 }
 
-static bool vlan_default_pvid(struct net_port_vlans *pv, u16 vid)
+static bool vlan_default_pvid(struct net_bridge_vlan_group *vg, u16 pvid,
+			      u16 vid)
 {
-	return pv && vid == pv->pvid && test_bit(vid, pv->untagged_bitmap);
+	struct net_bridge_vlan *v;
+
+	if (vid != pvid)
+		return false;
+
+	v = br_vlan_lookup(&vg->vlan_hash, vid);
+	if (v && (v->flags & BRIDGE_VLAN_INFO_UNTAGGED))
+		return true;
+
+	return false;
 }
 
 static void br_vlan_disable_default_pvid(struct net_bridge *br)
@@ -589,11 +693,11 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 	/* Disable default_pvid on all ports where it is still
 	 * configured.
 	 */
-	if (vlan_default_pvid(br_get_vlan_info(br), pvid))
+	if (vlan_default_pvid(br->vlgrp, br->pvid, pvid))
 		br_vlan_delete(br, pvid);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (vlan_default_pvid(nbp_get_vlan_info(p), pvid))
+		if (vlan_default_pvid(p->vlgrp, p->pvid, pvid))
 			nbp_vlan_delete(p, pvid);
 	}
 
@@ -617,11 +721,12 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	/* Update default_pvid config only if we do not conflict with
 	 * user configuration.
 	 */
-	if ((!old_pvid || vlan_default_pvid(br_get_vlan_info(br), old_pvid)) &&
-	    !br_vlan_find(br, pvid)) {
+	if ((!old_pvid || vlan_default_pvid(br->vlgrp, br->pvid, old_pvid)) &&
+	    !br_vlan_find(br->vlgrp, pvid)) {
 		err = br_vlan_add(br, pvid,
 				  BRIDGE_VLAN_INFO_PVID |
-				  BRIDGE_VLAN_INFO_UNTAGGED);
+				  BRIDGE_VLAN_INFO_UNTAGGED |
+				  BRIDGE_VLAN_INFO_MASTERVL);
 		if (err)
 			goto out;
 		br_vlan_delete(br, old_pvid);
@@ -633,8 +738,8 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		 * user configuration.
 		 */
 		if ((old_pvid &&
-		     !vlan_default_pvid(nbp_get_vlan_info(p), old_pvid)) ||
-		    nbp_vlan_find(p, pvid))
+		     !vlan_default_pvid(p->vlgrp, p->pvid, old_pvid)) ||
+		    br_vlan_find(p->vlgrp, pvid))
 			continue;
 
 		err = nbp_vlan_add(p, pvid,
@@ -668,7 +773,8 @@ err_port:
 		if (old_pvid)
 			br_vlan_add(br, old_pvid,
 				    BRIDGE_VLAN_INFO_PVID |
-				    BRIDGE_VLAN_INFO_UNTAGGED);
+				    BRIDGE_VLAN_INFO_UNTAGGED |
+				    BRIDGE_VLAN_INFO_MASTERVL);
 		br_vlan_delete(br, pvid);
 	}
 	goto out;
@@ -707,10 +813,62 @@ unlock:
 
 int br_vlan_init(struct net_bridge *br)
 {
+	int ret = -ENOMEM;
+
+	br->vlgrp = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
+	if (!br->vlgrp)
+		goto out;
+	ret = rhashtable_init(&br->vlgrp->vlan_hash, &br_vlan_rht_params);
+	if (ret)
+		goto err_rhtbl;
+	INIT_LIST_HEAD(&br->vlgrp->vlan_list);
 	br->vlan_proto = htons(ETH_P_8021Q);
 	br->default_pvid = 1;
-	return br_vlan_add(br, 1,
-			   BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED);
+	ret = br_vlan_add(br, 1,
+			  BRIDGE_VLAN_INFO_PVID | BRIDGE_VLAN_INFO_UNTAGGED |
+			  BRIDGE_VLAN_INFO_MASTERVL);
+	if (ret)
+		goto err_vlan_add;
+
+out:
+	return ret;
+
+err_vlan_add:
+	rhashtable_destroy(&br->vlgrp->vlan_hash);
+err_rhtbl:
+	kfree(br->vlgrp);
+
+	goto out;
+}
+
+int nbp_vlan_init(struct net_bridge_port *p)
+{
+	int ret = -ENOMEM;
+
+	p->vlgrp = kzalloc(sizeof(struct net_bridge_vlan_group), GFP_KERNEL);
+	if (!p->vlgrp)
+		goto out;
+
+	ret = rhashtable_init(&p->vlgrp->vlan_hash, &br_vlan_rht_params);
+	if (ret)
+		goto err_rhtbl;
+	INIT_LIST_HEAD(&p->vlgrp->vlan_list);
+	if (p->br->default_pvid) {
+		ret = nbp_vlan_add(p, p->br->default_pvid,
+				   BRIDGE_VLAN_INFO_PVID |
+				   BRIDGE_VLAN_INFO_UNTAGGED);
+		if (ret)
+			goto err_vlan_add;
+	}
+out:
+	return ret;
+
+err_vlan_add:
+	rhashtable_destroy(&p->vlgrp->vlan_hash);
+err_rhtbl:
+	kfree(p->vlgrp);
+
+	goto out;
 }
 
 /* Must be protected by RTNL.
@@ -718,35 +876,28 @@ int br_vlan_init(struct net_bridge *br)
  */
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags)
 {
-	struct net_port_vlans *pv = NULL;
-	int err;
+	struct net_bridge_vlan *vlan;
+	int ret;
 
 	ASSERT_RTNL();
 
-	pv = rtnl_dereference(port->vlan_info);
-	if (pv)
-		return __vlan_add(pv, vid, flags);
-
-	/* Create port vlan infomration
-	 */
-	pv = kzalloc(sizeof(*pv), GFP_KERNEL);
-	if (!pv) {
-		err = -ENOMEM;
-		goto clean_up;
+	vlan = br_vlan_find(port->vlgrp, vid);
+	if (vlan) {
+		__vlan_add_flags(vlan, flags);
+		return 0;
 	}
 
-	pv->port_idx = port->port_no;
-	pv->parent.port = port;
-	err = __vlan_add(pv, vid, flags);
-	if (err)
-		goto clean_up;
+	vlan = kzalloc(sizeof(*vlan), GFP_KERNEL);
+	if (!vlan)
+		return -ENOMEM;
 
-	rcu_assign_pointer(port->vlan_info, pv);
-	return 0;
+	vlan->vid = vid;
+	vlan->port = port;
+	ret = __vlan_add(vlan, flags);
+	if (ret)
+		kfree(vlan);
 
-clean_up:
-	kfree(pv);
-	return err;
+	return ret;
 }
 
 /* Must be protected by RTNL.
@@ -754,61 +905,27 @@ clean_up:
  */
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 {
-	struct net_port_vlans *pv;
+	struct net_bridge_vlan *v;
 
 	ASSERT_RTNL();
 
-	pv = rtnl_dereference(port->vlan_info);
-	if (!pv)
-		return -EINVAL;
-
+	v = br_vlan_find(port->vlgrp, vid);
+	if (!v)
+		return -ENOENT;
 	br_fdb_find_delete_local(port->br, port, port->dev->dev_addr, vid);
 	br_fdb_delete_by_port(port->br, port, vid, 0);
 
-	return __vlan_del(pv, vid);
+	return __vlan_del(v);
 }
 
 void nbp_vlan_flush(struct net_bridge_port *port)
 {
-	struct net_port_vlans *pv;
-	u16 vid;
+	struct net_bridge_vlan *vlan;
 
 	ASSERT_RTNL();
 
-	pv = rtnl_dereference(port->vlan_info);
-	if (!pv)
-		return;
+	list_for_each_entry(vlan, &port->vlgrp->vlan_list, vlist)
+		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
 
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
-		vlan_vid_del(port->dev, port->br->vlan_proto, vid);
-
-	__vlan_flush(pv);
-}
-
-bool nbp_vlan_find(struct net_bridge_port *port, u16 vid)
-{
-	struct net_port_vlans *pv;
-	bool found = false;
-
-	rcu_read_lock();
-	pv = rcu_dereference(port->vlan_info);
-
-	if (!pv)
-		goto out;
-
-	if (test_bit(vid, pv->vlan_bitmap))
-		found = true;
-
-out:
-	rcu_read_unlock();
-	return found;
-}
-
-int nbp_vlan_init(struct net_bridge_port *p)
-{
-	return p->br->default_pvid ?
-			nbp_vlan_add(p, p->br->default_pvid,
-				     BRIDGE_VLAN_INFO_PVID |
-				     BRIDGE_VLAN_INFO_UNTAGGED) :
-			0;
+	__vlan_flush(nbp_vlan_group(port), &port->pvid);
 }
-- 
2.4.3
