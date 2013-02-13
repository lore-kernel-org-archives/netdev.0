From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v11 net-next 10/12] bridge: Add vlan support to static neighbors
Date: Wed, 13 Feb 2013 17:00:18 -0500
Message-ID: <1360792820-14116-11-git-send-email-vyasevic@redhat.com>
References: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12646 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965026Ab3BMWA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2013 17:00:58 -0500
In-Reply-To: <1360792820-14116-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user adds bridge neighbors, allow him to specify VLAN id.
If the VLAN id is not specified, the neighbor will be added
for VLANs currently in the ports filter list.  If no VLANs are
configured on the port, we use vlan 0 and only add 1 entry.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 +-
 drivers/net/macvlan.c                            |    2 +-
 drivers/net/vxlan.c                              |    3 +-
 include/linux/netdevice.h                        |    4 +-
 include/uapi/linux/neighbour.h                   |    1 +
 net/bridge/br_fdb.c                              |  148 +++++++++++++++++++---
 net/bridge/br_private.h                          |    6 +-
 net/core/rtnetlink.c                             |   26 +++--
 10 files changed, 162 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4e2aa47..1c0efcb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7002,7 +7002,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
+static int ixgbe_ndo_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
 			     const unsigned char *addr)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 937bcc3..5088dc5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1959,6 +1959,7 @@ static int mlx4_en_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 }
 
 static int mlx4_en_fdb_del(struct ndmsg *ndm,
+			   struct nlattr *tb[],
 			   struct net_device *dev,
 			   const unsigned char *addr)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b745194..b953168 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -247,8 +247,8 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-static int qlcnic_fdb_del(struct ndmsg *ndm, struct net_device *netdev,
-			const unsigned char *addr)
+static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
+			struct net_device *netdev, const unsigned char *addr)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err = -EOPNOTSUPP;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index e4b8078..defcd8a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -599,7 +599,7 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-static int macvlan_fdb_del(struct ndmsg *ndm,
+static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev,
 			   const unsigned char *addr)
 {
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 72485b9..9d70421 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -393,7 +393,8 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 }
 
 /* Delete entry (via netlink) */
-static int vxlan_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
+static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
+			    struct net_device *dev,
 			    const unsigned char *addr)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1964ca6..9deb672 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -884,7 +884,8 @@ struct netdev_fcoe_hbainfo {
  *		      struct net_device *dev,
  *		      const unsigned char *addr, u16 flags)
  *	Adds an FDB entry to dev for addr.
- * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
+ * int (*ndo_fdb_del)(struct ndmsg *ndm, struct nlattr *tb[],
+ *		      struct net_device *dev,
  *		      const unsigned char *addr)
  *	Deletes the FDB entry from dev coresponding to addr.
  * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
@@ -1008,6 +1009,7 @@ struct net_device_ops {
 					       const unsigned char *addr,
 					       u16 flags);
 	int			(*ndo_fdb_del)(struct ndmsg *ndm,
+					       struct nlattr *tb[],
 					       struct net_device *dev,
 					       const unsigned char *addr);
 	int			(*ndo_fdb_dump)(struct sk_buff *skb,
diff --git a/include/uapi/linux/neighbour.h b/include/uapi/linux/neighbour.h
index 275e5d6..adb068c 100644
--- a/include/uapi/linux/neighbour.h
+++ b/include/uapi/linux/neighbour.h
@@ -20,6 +20,7 @@ enum {
 	NDA_LLADDR,
 	NDA_CACHEINFO,
 	NDA_PROBES,
+	NDA_VLAN,
 	__NDA_MAX
 };
 
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 276a522..4b75ad4 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -505,6 +505,10 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ci.ndm_refcnt	 = 0;
 	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
+
+	if (nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -516,6 +520,7 @@ static inline size_t fdb_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
+		+ nla_total_size(sizeof(u16)) /* NDA_VLAN */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
@@ -617,6 +622,25 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	return 0;
 }
 
+static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
+	       const unsigned char *addr, u16 nlh_flags, u16 vid)
+{
+	int err = 0;
+
+	if (ndm->ndm_flags & NTF_USE) {
+		rcu_read_lock();
+		br_fdb_update(p->br, p, addr, vid);
+		rcu_read_unlock();
+	} else {
+		spin_lock_bh(&p->br->hash_lock);
+		err = fdb_add_entry(p, addr, ndm->ndm_state,
+				    nlh_flags, vid);
+		spin_unlock_bh(&p->br->hash_lock);
+	}
+
+	return err;
+}
+
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
 int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	       struct net_device *dev,
@@ -624,12 +648,29 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct net_bridge_port *p;
 	int err = 0;
+	struct net_port_vlans *pv;
+	unsigned short vid = VLAN_N_VID;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
 		return -EINVAL;
 	}
 
+	if (tb[NDA_VLAN]) {
+		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
+			return -EINVAL;
+		}
+
+		vid = nla_get_u16(tb[NDA_VLAN]);
+
+		if (vid >= VLAN_N_VID) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
+				vid);
+			return -EINVAL;
+		}
+	}
+
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
@@ -637,41 +678,90 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	if (ndm->ndm_flags & NTF_USE) {
-		rcu_read_lock();
-		br_fdb_update(p->br, p, addr, 0);
-		rcu_read_unlock();
+	pv = nbp_get_vlan_info(p);
+	if (vid != VLAN_N_VID) {
+		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
+			pr_info("bridge: RTM_NEWNEIGH with unconfigured "
+				"vlan %d on port %s\n", vid, dev->name);
+			return -EINVAL;
+		}
+
+		/* VID was specified, so use it. */
+		err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 	} else {
-		spin_lock_bh(&p->br->hash_lock);
-		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags,
-				0);
-		spin_unlock_bh(&p->br->hash_lock);
+		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN)) {
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
+			goto out;
+		}
+
+		/* We have vlans configured on this port and user didn't
+		 * specify a VLAN.  To be nice, add/update entry for every
+		 * vlan on this port.
+		 */
+		vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
+		while (vid < BR_VLAN_BITMAP_LEN) {
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
+			if (err)
+				goto out;
+			vid = find_next_bit(pv->vlan_bitmap,
+					    BR_VLAN_BITMAP_LEN, vid+1);
+		}
 	}
 
+out:
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
+static int fdb_delete_by_addr(struct net_bridge *br, const u8 *addr,
+			      u16 vlan)
 {
-	struct net_bridge *br = p->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr, 0);
+	fdb = fdb_find(head, addr, vlan);
 	if (!fdb)
 		return -ENOENT;
 
-	fdb_delete(p->br, fdb);
+	fdb_delete(br, fdb);
 	return 0;
 }
 
+static int __br_fdb_delete(struct net_bridge_port *p,
+			   const unsigned char *addr, u16 vid)
+{
+	int err;
+
+	spin_lock_bh(&p->br->hash_lock);
+	err = fdb_delete_by_addr(p->br, addr, vid);
+	spin_unlock_bh(&p->br->hash_lock);
+
+	return err;
+}
+
 /* Remove neighbor entry with RTM_DELNEIGH */
-int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
+int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
+		  struct net_device *dev,
 		  const unsigned char *addr)
 {
 	struct net_bridge_port *p;
 	int err;
+	struct net_port_vlans *pv;
+	unsigned short vid = VLAN_N_VID;
 
+	if (tb[NDA_VLAN]) {
+		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
+			return -EINVAL;
+		}
+
+		vid = nla_get_u16(tb[NDA_VLAN]);
+
+		if (vid >= VLAN_N_VID) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
+				vid);
+			return -EINVAL;
+		}
+	}
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
@@ -679,9 +769,33 @@ int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr(p, addr);
-	spin_unlock_bh(&p->br->hash_lock);
+	pv = nbp_get_vlan_info(p);
+	if (vid != VLAN_N_VID) {
+		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
+			pr_info("bridge: RTM_DELNEIGH with unconfigured "
+				"vlan %d on port %s\n", vid, dev->name);
+			return -EINVAL;
+		}
 
+		err = __br_fdb_delete(p, addr, vid);
+	} else {
+		if (!pv || bitmap_empty(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN)) {
+			err = __br_fdb_delete(p, addr, 0);
+			goto out;
+		}
+
+		/* We have vlans configured on this port and user didn't
+		 * specify a VLAN.  To be nice, add/update entry for every
+		 * vlan on this port.
+		 */
+		err = -ENOENT;
+		vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
+		while (vid < BR_VLAN_BITMAP_LEN) {
+			err &= __br_fdb_delete(p, addr, vid);
+			vid = find_next_bit(pv->vlan_bitmap,
+					    BR_VLAN_BITMAP_LEN, vid+1);
+		}
+	}
+out:
 	return err;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a2a64f7..91e505c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -388,7 +388,7 @@ extern void br_fdb_update(struct net_bridge *br,
 			  const unsigned char *addr,
 			  u16 vid);
 
-extern int br_fdb_delete(struct ndmsg *ndm,
+extern int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			 struct net_device *dev,
 			 const unsigned char *addr);
 extern int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[],
@@ -577,13 +577,13 @@ extern void nbp_vlan_flush(struct net_bridge_port *port);
 static inline struct net_port_vlans *br_get_vlan_info(
 						const struct net_bridge *br)
 {
-	return rcu_dereference(br->vlan_info);
+	return rcu_dereference_rtnl(br->vlan_info);
 }
 
 static inline struct net_port_vlans *nbp_get_vlan_info(
 						const struct net_bridge_port *p)
 {
-	return rcu_dereference(p->vlan_info);
+	return rcu_dereference_rtnl(p->vlan_info);
 }
 
 /* Since bridge now depends on 8021Q module, but the time bridge sees the
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index f3a112e..d8aa20f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2119,13 +2119,17 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
-	struct nlattr *llattr;
+	struct nlattr *tb[NDA_MAX+1];
 	struct net_device *dev;
 	int err = -EINVAL;
 	__u8 *addr;
 
-	if (nlmsg_len(nlh) < sizeof(*ndm))
-		return -EINVAL;
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
@@ -2139,13 +2143,17 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		return -ENODEV;
 	}
 
-	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
-	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
-		pr_info("PF_BRIGDE: RTM_DELNEIGH with invalid address\n");
+	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
+		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(tb[NDA_LLADDR]);
+	if (!is_valid_ether_addr(addr)) {
+		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether address\n");
 		return -EINVAL;
 	}
 
-	addr = nla_data(llattr);
 	err = -EOPNOTSUPP;
 
 	/* Support fdb on master device the net/bridge default case */
@@ -2155,7 +2163,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		const struct net_device_ops *ops = br_dev->netdev_ops;
 
 		if (ops->ndo_fdb_del)
-			err = ops->ndo_fdb_del(ndm, dev, addr);
+			err = ops->ndo_fdb_del(ndm, tb, dev, addr);
 
 		if (err)
 			goto out;
@@ -2165,7 +2173,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	/* Embedded bridge, macvlan, and any other device support */
 	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_del) {
-		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+		err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
-- 
1.7.7.6
