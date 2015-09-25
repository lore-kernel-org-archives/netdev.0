From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: vlan: add per-vlan struct and
	move to rhashtables
Date: Fri, 25 Sep 2015 19:00:11 +0200
Message-ID: <1443200411-7399-1-git-send-email-razor@blackwall.org>
Cc: bridge@lists.linux-foundation.org, vyasevich@gmail.com,
	shm@cumulusnetworks.com, davem@davemloft.net, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch changes the bridge vlan implementation to use rhashtables
instead of bitmaps. The main motivation behind this change is that we
need extensible per-vlan structures (both per-port and global) so more
advanced features can be introduced and the vlan support can be
extended. I've tried to break this up but the moment net_port_vlans is
changed and the whole API goes away, thus this is a larger patch.
A few short goals of this patch are:
- Extensible per-vlan structs stored in rhashtables and a sorted list
- Keep user-visible behaviour (compressed vlans etc)
- Keep fastpath ingress/egress logic the same (optimizations to come
  later)

Here's a brief list of some of the new features we'd like to introduce:
- per-vlan counters
- vlan ingress/egress mapping
- per-vlan igmp configuration
- vlan priorities
- avoid fdb entries replication (e.g. local fdb scaling issues)

The structure is kept single for both global and per-port entries so to
avoid code duplication where possible and also because we'll soon introduce
"port0 / aka bridge as port" which should simplify things further
(thanks to Vlad for the suggestion!).

Now we have per-vlan global rhashtable (bridge-wide) and per-vlan port
rhashtable, if an entry is added to a port it'll get a pointer to its
global context so it can be quickly accessed later. There's also a
sorted vlan list which is used for stable walks and some user-visible
behaviour such as the vlan ranges, also for error paths.
VLANs are stored in a "vlan group" which currently contains the
rhashtable, sorted vlan list and the number of "real" vlan entries.
A good side-effect of this change is that it resembles how hw keeps
per-vlan data.
One important note after this change is that if a VLAN is being looked up
in the bridge's rhashtable for filtering purposes (or to check if it's an
existing usable entry, not just a global context) then the new helper
br_vlan_should_use() needs to be used if the vlan is found. In case the
lookup is done only with a port's vlan group, then this check can be
skipped.

Things tested so far:
- basic vlan ingress/egress
- pvids
- untagged vlans
- undef CONFIG_BRIDGE_VLAN_FILTERING
- adding/deleting vlans in different scenarios (with/without global ctx,
  while transmitting traffic, in ranges etc)
- loading/removing the module while having/adding/deleting vlans
- extracting bridge vlan information (user ABI), compressed requests
- adding/deleting fdbs on vlans
- bridge mac change, promisc mode
- default pvid change
- kmemleak ON during the whole time

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Things that will be done as follow-ups include fastpath optimization and
moving the pvid member into the vlan group which would allow to converge a
few functions.

 include/uapi/linux/if_bridge.h |   1 +
 net/bridge/br_device.c         |   2 +-
 net/bridge/br_fdb.c            |  76 ++---
 net/bridge/br_forward.c        |  15 +-
 net/bridge/br_input.c          |  10 +-
 net/bridge/br_mdb.c            |  24 +-
 net/bridge/br_netlink.c        | 174 +++++-----
 net/bridge/br_private.h        | 191 ++++++++---
 net/bridge/br_vlan.c           | 699 +++++++++++++++++++++++++----------------
 9 files changed, 732 insertions(+), 460 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 3635b7797508..18db14477bdd 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -127,6 +127,7 @@ enum {
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
 #define BRIDGE_VLAN_INFO_RANGE_BEGIN	(1<<3) /* VLAN is start of vlan range */
 #define BRIDGE_VLAN_INFO_RANGE_END	(1<<4) /* VLAN is end of vlan range */
+#define BRIDGE_VLAN_INFO_BRENTRY	(1<<5) /* Global bridge VLAN entry */
 
 struct bridge_vlan_info {
 	__u16 flags;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 2f81624a8257..c915c5b408ea 100644
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
index 6663cc0789a6..41de11e2eb11 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -163,22 +163,27 @@ static void fdb_delete_local(struct net_bridge *br,
 			     struct net_bridge_fdb_entry *f)
 {
 	const unsigned char *addr = f->addr.addr;
-	u16 vid = f->vlan_id;
+	struct net_bridge_vlan_group *vg;
+	const struct net_bridge_vlan *v;
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
+	v = br_vlan_find(vg, vid);
 	/* Maybe bridge device has same hw addr? */
 	if (p && ether_addr_equal(br->dev->dev_addr, addr) &&
-	    (!vid || br_vlan_find(br, vid))) {
+	    (!vid || (v && br_vlan_should_use(v)))) {
 		f->dst = NULL;
 		f->added_by_user = 0;
 		return;
@@ -203,14 +208,14 @@ void br_fdb_find_delete_local(struct net_bridge *br,
 
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
@@ -226,7 +231,7 @@ void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
 				 * configured, we can safely be done at
 				 * this point.
 				 */
-				if (no_vlan)
+				if (!vg || !vg->num_vlans)
 					goto insert;
 			}
 		}
@@ -236,15 +241,15 @@ insert:
 	/* insert new address,  may fail if invalid address or dup. */
 	fdb_insert(br, p, newaddr, 0);
 
-	if (no_vlan)
+	if (!vg || !vg->num_vlans)
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
@@ -252,9 +257,9 @@ done:
 
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 {
+	struct net_bridge_vlan_group *vg;
 	struct net_bridge_fdb_entry *f;
-	struct net_port_vlans *pv;
-	u16 vid = 0;
+	struct net_bridge_vlan *v;
 
 	spin_lock_bh(&br->hash_lock);
 
@@ -264,20 +269,18 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 		fdb_delete_local(br, NULL, f);
 
 	fdb_insert(br, NULL, newaddr, 0);
-
+	vg = br_vlan_group(br);
+	if (!vg || !vg->num_vlans)
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
@@ -844,9 +847,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
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
@@ -865,9 +869,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
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
@@ -877,15 +882,15 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
 		err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
-		if (err || !pv)
+		if (err || !vg || !vg->num_vlans)
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
@@ -927,9 +932,10 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
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
@@ -938,9 +944,10 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
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
@@ -950,16 +957,11 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	} else {
 		err = -ENOENT;
 		err &= __br_fdb_delete(p, addr, 0);
-		if (!pv)
+		if (!vg || !vg->num_vlans)
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
index 48afca729ed7..6d5ed795c3e2 100644
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
 
 int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
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
index 223f4040d9df..e27d0dfd2ee9 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -36,28 +36,28 @@ static int br_pass_frame_up(struct sk_buff *skb)
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
 
@@ -140,7 +140,7 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
-	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
+	if (!nbp_allowed_ingress(p, skb, &vid))
 		goto out;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index d747275fad18..cd8deea2d074 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -464,11 +464,11 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	unsigned short vid = VLAN_N_VID;
+	struct net_bridge_vlan_group *vg;
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
+	vg = nbp_vlan_group(p);
+	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
+		list_for_each_entry(v, &vg->vlan_list, vlist) {
+			entry->vid = v->vid;
 			err = __br_mdb_add(net, br, entry);
 			if (err)
 				break;
@@ -566,11 +566,11 @@ unlock:
 static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	unsigned short vid = VLAN_N_VID;
+	struct net_bridge_vlan_group *vg;
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
+	vg = nbp_vlan_group(p);
+	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
+		list_for_each_entry(v, &vg->vlan_list, vlist) {
+			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
 			if (!err)
 				__br_mdb_notify(dev, entry, RTM_DELMDB);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ea748c93a07f..bb8bb7b36f04 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -21,36 +21,35 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-static int br_get_num_vlan_infos(const struct net_port_vlans *pv,
-				 u32 filter_mask)
+static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
+				u32 filter_mask,
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
+	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		flags = 0;
-		if (vid == pvid)
+		/* only a context, bridge vlan not activated */
+		if (!br_vlan_should_use(v))
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
+	return __get_num_vlan_infos(vg, filter_mask, pvid);
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
@@ -185,31 +196,33 @@ nla_put_failure:
 }
 
 static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
-					 const struct net_port_vlans *pv)
+					 struct net_bridge_vlan_group *vg,
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
+	list_for_each_entry(v, &vg->vlan_list, vlist) {
 		flags = 0;
-		if (vid == pvid)
+		if (!br_vlan_should_use(v))
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
@@ -220,8 +233,8 @@ static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
 		}
 
 initvars:
-		vid_range_start = vid;
-		vid_range_end = vid;
+		vid_range_start = v->vid;
+		vid_range_end = v->vid;
 		vid_range_flags = flags;
 	}
 
@@ -238,19 +251,22 @@ initvars:
 }
 
 static int br_fill_ifvlaninfo(struct sk_buff *skb,
-			      const struct net_port_vlans *pv)
+			      struct net_bridge_vlan_group *vg,
+			      u16 pvid)
 {
 	struct bridge_vlan_info vinfo;
-	u16 pvid, vid;
+	struct net_bridge_vlan *v;
 
-	pvid = br_get_pvid(pv);
-	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-		vinfo.vid = vid;
+	list_for_each_entry(v, &vg->vlan_list, vlist) {
+		if (!br_vlan_should_use(v))
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
@@ -269,11 +285,11 @@ nla_put_failure:
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
@@ -320,16 +336,20 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	/* Check if  the VID information is requested */
 	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
 	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
-		const struct net_port_vlans *pv;
+		struct net_bridge_vlan_group *vg;
 		struct nlattr *af;
+		u16 pvid;
 		int err;
 
-		if (port)
-			pv = nbp_get_vlan_info(port);
-		else
-			pv = br_get_vlan_info(br);
+		if (port) {
+			vg = nbp_vlan_group(port);
+			pvid = nbp_get_pvid(port);
+		} else {
+			vg = br_vlan_group(br);
+			pvid = br_get_pvid(br);
+		}
 
-		if (!pv || bitmap_empty(pv->vlan_bitmap, VLAN_N_VID))
+		if (!vg || !vg->num_vlans)
 			goto done;
 
 		af = nla_nest_start(skb, IFLA_AF_SPEC);
@@ -337,9 +357,9 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			goto nla_put_failure;
 
 		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
-			err = br_fill_ifvlaninfo_compressed(skb, pv);
+			err = br_fill_ifvlaninfo_compressed(skb, vg, pvid);
 		else
-			err = br_fill_ifvlaninfo(skb, pv);
+			err = br_fill_ifvlaninfo(skb, vg, pvid);
 		if (err)
 			goto nla_put_failure;
 		nla_nest_end(skb, af);
@@ -413,14 +433,14 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 	switch (cmd) {
 	case RTM_SETLINK:
 		if (p) {
+			/* if the MASTER flag is set this will act on the global
+			 * per-VLAN entry as well
+			 */
 			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
 			if (err)
 				break;
-
-			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-				err = br_vlan_add(p->br, vinfo->vid,
-						  vinfo->flags);
 		} else {
+			vinfo->flags |= BRIDGE_VLAN_INFO_BRENTRY;
 			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
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
index 74e99c75c8e4..cfe945f5ab8b 100644
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
 
@@ -77,16 +77,58 @@ struct bridge_mcast_querier {
 };
 #endif
 
-struct net_port_vlans {
-	u16				port_idx;
-	u16				pvid;
+/**
+ * struct net_bridge_vlan - per-vlan entry
+ *
+ * @vnode: rhashtable member
+ * @vid: VLAN id
+ * @flags: bridge vlan flags
+ * @br: if MASTER flag set, this points to a bridge struct
+ * @port: if MASTER flag unset, this points to a port struct
+ * @refcnt: if MASTER flag set, this is bumped for each port referencing it
+ * @brvlan: if MASTER flag unset, this points to the global per-VLAN context
+ *          for this VLAN entry
+ * @vlist: sorted list of VLAN entries
+ * @rcu: used for entry destruction
+ *
+ * This structure is shared between the global per-VLAN entries contained in
+ * the bridge rhashtable and the local per-port per-VLAN entries contained in
+ * the port's rhashtable. The union entries should be interpreted depending on
+ * the entry flags that are set.
+ */
+struct net_bridge_vlan {
+	struct rhash_head		vnode;
+	u16				vid;
+	u16				flags;
 	union {
-		struct net_bridge_port		*port;
-		struct net_bridge		*br;
-	}				parent;
+		struct net_bridge	*br;
+		struct net_bridge_port	*port;
+	};
+	union {
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
+/**
+ * struct net_bridge_vlan_group
+ *
+ * @vlan_hash: VLAN entry rhashtable
+ * @vlan_list: sorted VLAN entry list
+ * @num_vlans: number of total VLAN entries
+ *
+ * IMPORTANT: Be careful when checking if there're VLAN entries using list
+ *            primitives because the bridge can have entries in its list which
+ *            are just for global context but not for filtering, i.e. they have
+ *            the master flag set but not the brentry flag. If you have to check
+ *            if there're "real" entries in the bridge please test @num_vlans
+ */
+struct net_bridge_vlan_group {
+	struct rhashtable		vlan_hash;
+	struct list_head		vlan_list;
 	u16				num_vlans;
 };
 
@@ -185,7 +227,8 @@ struct net_bridge_port
 	struct netpoll			*np;
 #endif
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	struct net_port_vlans __rcu	*vlan_info;
+	struct net_bridge_vlan_group	*vlgrp;
+	u16				pvid;
 #endif
 };
 
@@ -293,10 +336,11 @@ struct net_bridge
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
 
@@ -344,6 +388,31 @@ static inline int br_is_root_bridge(const struct net_bridge *br)
 	return !memcmp(&br->bridge_id, &br->designated_root, 8);
 }
 
+/* check if a VLAN entry is global */
+static inline bool br_vlan_is_master(const struct net_bridge_vlan *v)
+{
+	return v->flags & BRIDGE_VLAN_INFO_MASTER;
+}
+
+/* check if a VLAN entry is used by the bridge */
+static inline bool br_vlan_is_brentry(const struct net_bridge_vlan *v)
+{
+	return v->flags & BRIDGE_VLAN_INFO_BRENTRY;
+}
+
+/* check if we should use the vlan entry is usable */
+static inline bool br_vlan_should_use(const struct net_bridge_vlan *v)
+{
+	if (br_vlan_is_master(v)) {
+		if (br_vlan_is_brentry(v))
+			return true;
+		else
+			return false;
+	}
+
+	return true;
+}
+
 /* br_device.c */
 void br_dev_setup(struct net_device *dev);
 void br_dev_delete(struct net_device *dev, struct list_head *list);
@@ -601,18 +670,19 @@ static inline void br_mdb_uninit(void)
 
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
@@ -623,19 +693,19 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
-bool nbp_vlan_find(struct net_bridge_port *port, u16 vid);
 int nbp_vlan_init(struct net_bridge_port *port);
+int nbp_get_num_vlan_infos(struct net_bridge_port *p, u32 filter_mask);
 
-static inline struct net_port_vlans *br_get_vlan_info(
-						const struct net_bridge *br)
+static inline struct net_bridge_vlan_group *br_vlan_group(
+					const struct net_bridge *br)
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
@@ -645,9 +715,9 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
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
@@ -655,13 +725,22 @@ static inline int br_vlan_get_tag(const struct sk_buff *skb, u16 *vid)
 	return err;
 }
 
-static inline u16 br_get_pvid(const struct net_port_vlans *v)
+static inline u16 br_get_pvid(const struct net_bridge *br)
 {
-	if (!v)
+	if (!br)
 		return 0;
 
 	smp_rmb();
-	return v->pvid;
+	return br->pvid;
+}
+
+static inline u16 nbp_get_pvid(const struct net_bridge_port *p)
+{
+	if (!p)
+		return 0;
+
+	smp_rmb();
+	return p->pvid;
 }
 
 static inline int br_vlan_enabled(struct net_bridge *br)
@@ -670,15 +749,20 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 }
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
@@ -691,7 +775,7 @@ static inline bool br_should_learn(struct net_bridge_port *p,
 }
 
 static inline struct sk_buff *br_handle_vlan(struct net_bridge *br,
-					     const struct net_port_vlans *v,
+					     struct net_bridge_vlan_group *vg,
 					     struct sk_buff *skb)
 {
 	return skb;
@@ -711,11 +795,6 @@ static inline void br_vlan_flush(struct net_bridge *br)
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
@@ -739,32 +818,28 @@ static inline void nbp_vlan_flush(struct net_bridge_port *port)
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
@@ -779,6 +854,24 @@ static inline int __br_vlan_filter_toggle(struct net_bridge *br,
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
+static inline struct net_bridge_vlan_group *br_vlan_group(
+					const struct net_bridge *br)
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
index 5f5a02b49a99..8b392070051c 100644
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
+	struct net_bridge_vlan *vent;
 
-	err = br_fdb_insert(br, p, dev->dev_addr, vid);
-	if (err) {
-		br_err(br, "failed insert local address into bridge "
-		       "forwarding table\n");
-		goto out_filt;
+	headp = br_vlan_is_master(v) ? &v->br->vlgrp->vlan_list :
+				       &v->port->vlgrp->vlan_list;
+	list_for_each_prev(hpos, headp) {
+		vent = list_entry(hpos, struct net_bridge_vlan, vlist);
+		if (v->vid < vent->vid)
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
@@ -146,63 +148,195 @@ static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 	return err;
 }
 
-static int __vlan_del(struct net_port_vlans *v, u16 vid)
+/* This is the shared VLAN add function which works for both ports and bridge
+ * devices. There are four possible calls to this function in terms of the
+ * vlan entry type:
+ * 1. vlan is being added on a port (no master flags, global entry exists)
+ * 2. vlan is being added on a bridge (both master and brvlan flags)
+ * 3. vlan is being added on a port, but a global entry didn't exist which
+ *    is being created right now (master flag set, brvlan flag unset), the
+ *    global entry is used for global per-vlan features, but not for filtering
+ * 4. same as 3 but with both master and brvlan flags set so the entry
+ *    will be used for filtering in both the port and the bridge
+ */
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
+			master_flags |= BRIDGE_VLAN_INFO_BRENTRY;
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
+	/* Add the dev mac only if it's a usable vlan */
+	if (br_vlan_should_use(v)) {
+		err = br_fdb_insert(br, p, dev->dev_addr, v->vid);
+		if (err) {
+			br_err(br, "failed insert local address into bridge forwarding table\n");
+			goto out_filt;
+		}
+	}
+
+	err = rhashtable_lookup_insert_fast(tbl, &v->vnode, br_vlan_rht_params);
+	if (err)
+		goto out_fdb_insert;
 
-	__vlan_delete_pvid(v, vid);
-	clear_bit(vid, v->untagged_bitmap);
+	__vlan_add_list(v);
+	__vlan_add_flags(v, flags);
+	if (br_vlan_is_master(v)) {
+		if (br_vlan_is_brentry(v))
+			br->vlgrp->num_vlans++;
+	} else {
+		p->vlgrp->num_vlans++;
+	}
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
+
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
+	if (br_vlan_is_master(v)) {
+		if (br_vlan_is_brentry(v)) {
+			v->flags &= ~BRIDGE_VLAN_INFO_BRENTRY;
+			br->vlgrp->num_vlans--;
+		}
+	} else {
+		p->vlgrp->num_vlans--;
+	}
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
+	/* Vlan entry must be configured at this point.  The
 	 * only exception is the bridge is set in promisc mode and the
 	 * packet is destined for the bridge device.  In this case
 	 * pass the packet as is.
 	 */
-	if (!pv) {
+	if (!v || !br_vlan_should_use(v)) {
 		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev) {
 			goto out;
 		} else {
@@ -210,13 +344,7 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
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
@@ -224,29 +352,13 @@ out:
 }
 
 /* Called under RCU */
-bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
-			struct sk_buff *skb, u16 *vid)
+static bool __allowed_ingress(struct rhashtable *tbl, u16 pvid, __be16 proto,
+			      struct sk_buff *skb, u16 *vid)
 {
+	const struct net_bridge_vlan *v;
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
@@ -281,8 +393,6 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	}
 
 	if (!*vid) {
-		u16 pvid = br_get_pvid(v);
-
 		/* Frame had a tag with VID 0 or did not have a tag.
 		 * See if pvid is set on this port.  That tells us which
 		 * vlan untagged or priority-tagged traffic belongs to.
@@ -309,29 +419,59 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	}
 
 	/* Frame had a valid vlan tag.  See if vlan is allowed */
-	if (test_bit(*vid, v->vlan_bitmap))
+	v = br_vlan_lookup(tbl, *vid);
+	if (v && br_vlan_should_use(v))
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
+	const struct net_bridge_vlan *v;
 	u16 vid;
 
 	/* If this packet was not filtered at input, let it pass */
 	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		return true;
 
-	if (!v)
-		return false;
-
 	br_vlan_get_tag(skb, &vid);
-	if (test_bit(vid, v->vlan_bitmap))
+	v = br_vlan_find(vg, vid);
+	if (v && br_vlan_should_use(v))
 		return true;
 
 	return false;
@@ -341,28 +481,26 @@ bool br_allowed_egress(struct net_bridge *br,
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
@@ -373,31 +511,47 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
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
+		if (!br_vlan_is_brentry(vlan)) {
+			/* Trying to change flags of non-existent bridge vlan */
+			if (!(flags & BRIDGE_VLAN_INFO_BRENTRY))
+				return -EINVAL;
+			/* It was only kept for port vlans, now make it real */
+			ret = br_fdb_insert(br, NULL, br->dev->dev_addr,
+					    vlan->vid);
+			if (ret) {
+				br_err(br, "failed insert local address into bridge forwarding table\n");
+				return ret;
+			}
+			atomic_inc(&vlan->refcnt);
+			vlan->flags |= BRIDGE_VLAN_INFO_BRENTRY;
+			br->vlgrp->num_vlans++;
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
+	if (flags & BRIDGE_VLAN_INFO_BRENTRY)
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
@@ -405,49 +559,32 @@ out:
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
+	if (!v || !br_vlan_is_brentry(v))
+		return -ENOENT;
 
 	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
 
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
+	if (!vg)
+		return NULL;
 
-	rcu_read_lock();
-	pv = rcu_dereference(br->vlan_info);
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
+	return br_vlan_lookup(&vg->vlan_hash, vid);
 }
 
 /* Must be protected by RTNL. */
@@ -505,21 +642,16 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
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
@@ -532,30 +664,19 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto)
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
@@ -576,9 +697,20 @@ int br_vlan_set_proto(struct net_bridge *br, unsigned long val)
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
+	if (v && br_vlan_should_use(v) &&
+	    (v->flags & BRIDGE_VLAN_INFO_UNTAGGED))
+		return true;
+
+	return false;
 }
 
 static void br_vlan_disable_default_pvid(struct net_bridge *br)
@@ -589,11 +721,11 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
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
 
@@ -602,6 +734,7 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 
 static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 {
+	const struct net_bridge_vlan *pvent;
 	struct net_bridge_port *p;
 	u16 old_pvid;
 	int err = 0;
@@ -617,11 +750,13 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	/* Update default_pvid config only if we do not conflict with
 	 * user configuration.
 	 */
-	if ((!old_pvid || vlan_default_pvid(br_get_vlan_info(br), old_pvid)) &&
-	    !br_vlan_find(br, pvid)) {
+	pvent = br_vlan_find(br->vlgrp, pvid);
+	if ((!old_pvid || vlan_default_pvid(br->vlgrp, br->pvid, old_pvid)) &&
+	    (!pvent || !br_vlan_should_use(pvent))) {
 		err = br_vlan_add(br, pvid,
 				  BRIDGE_VLAN_INFO_PVID |
-				  BRIDGE_VLAN_INFO_UNTAGGED);
+				  BRIDGE_VLAN_INFO_UNTAGGED |
+				  BRIDGE_VLAN_INFO_BRENTRY);
 		if (err)
 			goto out;
 		br_vlan_delete(br, old_pvid);
@@ -633,8 +768,8 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 		 * user configuration.
 		 */
 		if ((old_pvid &&
-		     !vlan_default_pvid(nbp_get_vlan_info(p), old_pvid)) ||
-		    nbp_vlan_find(p, pvid))
+		     !vlan_default_pvid(p->vlgrp, p->pvid, old_pvid)) ||
+		    br_vlan_find(p->vlgrp, pvid))
 			continue;
 
 		err = nbp_vlan_add(p, pvid,
@@ -668,7 +803,8 @@ err_port:
 		if (old_pvid)
 			br_vlan_add(br, old_pvid,
 				    BRIDGE_VLAN_INFO_PVID |
-				    BRIDGE_VLAN_INFO_UNTAGGED);
+				    BRIDGE_VLAN_INFO_UNTAGGED |
+				    BRIDGE_VLAN_INFO_BRENTRY);
 		br_vlan_delete(br, pvid);
 	}
 	goto out;
@@ -707,10 +843,62 @@ unlock:
 
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
+			  BRIDGE_VLAN_INFO_BRENTRY);
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
@@ -718,35 +906,28 @@ int br_vlan_init(struct net_bridge *br)
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
@@ -754,61 +935,27 @@ clean_up:
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
-
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
+	list_for_each_entry(vlan, &port->vlgrp->vlan_list, vlist)
+		vlan_vid_del(port->dev, port->br->vlan_proto, vlan->vid);
 
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
