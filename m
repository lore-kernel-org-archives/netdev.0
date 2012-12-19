From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V4 09/13] bridge: Add vlan support to static neighbors
Date: Wed, 19 Dec 2012 12:48:20 -0500
Message-ID: <1355939304-21804-10-git-send-email-vyasevic@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49350 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755751Ab2LSRsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 12:48:43 -0500
In-Reply-To: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a user adds bridge neighbors, allow him to specify VLAN id.
If the VLAN id is not specified, the neighbor will be added
for VLANs currently in the ports filter list.  If the list is
empty, we use vlan 0 and only add 1 entry.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/macvlan.c                         |    2 +-
 drivers/net/vxlan.c                           |    3 +-
 include/linux/netdevice.h                     |    1 +
 include/uapi/linux/neighbour.h                |    1 +
 net/bridge/br_fdb.c                           |  139 ++++++++++++++++++++++---
 net/bridge/br_private.h                       |    2 +-
 net/core/rtnetlink.c                          |   24 +++--
 8 files changed, 146 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 20a5af6..ec97efe 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6985,7 +6985,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-static int ixgbe_ndo_fdb_del(struct ndmsg *ndm,
+static int ixgbe_ndo_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
 			     const unsigned char *addr)
 {
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 68a43fe..480189c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -565,7 +565,7 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-static int macvlan_fdb_del(struct ndmsg *ndm,
+static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev,
 			   const unsigned char *addr)
 {
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b3fdf6..09340c9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -392,7 +392,8 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 }
 
 /* Delete entry (via netlink) */
-static int vxlan_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
+static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
+			    struct net_device *dev,
 			    const unsigned char *addr)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c6a14d4..3ee7a80 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -996,6 +996,7 @@ struct net_device_ops {
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
index a244efc..f1199e4 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -506,6 +506,10 @@ static int fdb_fill_info(struct sk_buff *skb, const struct net_bridge *br,
 	ci.ndm_refcnt	 = 0;
 	if (nla_put(skb, NDA_CACHEINFO, sizeof(ci), &ci))
 		goto nla_put_failure;
+
+	if (nla_put(skb, NDA_VLAN, sizeof(u16), &fdb->vlan_id))
+		goto nla_put_failure;
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -517,6 +521,7 @@ static inline size_t fdb_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
 		+ nla_total_size(ETH_ALEN) /* NDA_LLADDR */
+		+ nla_total_size(sizeof(u16)) /* NDA_VLAN */
 		+ nla_total_size(sizeof(struct nda_cacheinfo));
 }
 
@@ -618,19 +623,55 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
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
 	       const unsigned char *addr, u16 nlh_flags)
 {
 	struct net_bridge_port *p;
+	struct net_port_vlan *pve;
 	int err = 0;
+	unsigned short vid = BR_INVALID_VID;
 
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
+		if (vid > VLAN_N_VID) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
+				vid);
+			return -EINVAL;
+		}
+	}
+
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_NEWNEIGH %s not a bridge port\n",
@@ -638,27 +679,45 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		return -EINVAL;
 	}
 
-	if (ndm->ndm_flags & NTF_USE) {
-		rcu_read_lock();
-		br_fdb_update(p->br, p, addr, 0);
-		rcu_read_unlock();
+	if (vid != BR_INVALID_VID) {
+		pve = nbp_vlan_find(p, vid);
+		if (!pve) {
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
+		if (list_empty(&p->vlan_list)) {
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, 0);
+			goto out;
+		}
+
+		/* We have vlans configured on this port and user didn't
+		 * specify a VLAN.  To be nice, add/update entry for every
+		 * vlan on this port.
+		 */
+		list_for_each_entry_rcu(pve, &p->vlan_list, list) {
+			err = __br_fdb_add(ndm, p, addr, nlh_flags, pve->vid);
+			if (err)
+				goto out;
+		}
 	}
 
+out:
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
+static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr,
+			      u16 vlan)
 {
 	struct net_bridge *br = p->br;
-	struct hlist_head *head = &br->hash[br_mac_hash(addr, 0)];
+	struct hlist_head *head = &br->hash[br_mac_hash(addr, vlan)];
 	struct net_bridge_fdb_entry *fdb;
 
-	fdb = fdb_find(head, addr, 0);
+	fdb = fdb_find(head, addr, vlan);
 	if (!fdb)
 		return -ENOENT;
 
@@ -666,13 +725,42 @@ static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
 	return 0;
 }
 
+static int __br_fdb_delete(struct net_bridge_port *p,
+			    const unsigned char *addr, u16 vid)
+{
+	int err;
+
+	spin_lock_bh(&p->br->hash_lock);
+	err = fdb_delete_by_addr(p, addr, vid);
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
+	struct net_port_vlan *pve;
 	int err;
+	unsigned short vid = BR_INVALID_VID;
 
+	if (tb[NDA_VLAN]) {
+		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
+			return -EINVAL;
+		}
+
+		vid = nla_get_u16(tb[NDA_VLAN]);
+
+		if (vid > VLAN_N_VID) {
+			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
+				vid);
+			return -EINVAL;
+		}
+	}
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
@@ -680,9 +768,30 @@ int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	spin_lock_bh(&p->br->hash_lock);
-	err = fdb_delete_by_addr(p, addr);
-	spin_unlock_bh(&p->br->hash_lock);
+	if (vid != BR_INVALID_VID) {
+		pve = nbp_vlan_find(p, vid);
+		if (!pve) {
+			pr_info("bridge: RTM_DELNEIGH with unconfigured "
+				"vlan %d on port %s\n", vid, dev->name);
+			return -EINVAL;
+		}
 
+		err = __br_fdb_delete(p, addr, vid);
+	} else {
+		if (list_empty(&p->vlan_list)) {
+			err = __br_fdb_delete(p, addr, 0);
+			goto out;
+		}
+
+		/* We have vlans configured on this port and user didn't
+		 * specify a VLAN.  To be nice, add/update entry for every
+		 * vlan on this port.
+		 */
+		err = -ENOENT;
+		list_for_each_entry_rcu(pve, &p->vlan_list, list) {
+			err &= __br_fdb_delete(p, addr, pve->vid);
+		}
+	}
+out:
 	return err;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2569afb..cc75212 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -407,7 +407,7 @@ extern void br_fdb_update(struct net_bridge *br,
 			  const unsigned char *addr,
 			  u16 vid);
 
-extern int br_fdb_delete(struct ndmsg *ndm,
+extern int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			 struct net_device *dev,
 			 const unsigned char *addr);
 extern int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[],
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1868625..8352302 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2125,7 +2125,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
-	struct nlattr *llattr;
+	struct nlattr *tb[NDA_MAX+1];
 	struct net_device *dev;
 	int err = -EINVAL;
 	__u8 *addr;
@@ -2133,8 +2133,9 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (nlmsg_len(nlh) < sizeof(*ndm))
-		return -EINVAL;
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
 
 	ndm = nlmsg_data(nlh);
 	if (ndm->ndm_ifindex == 0) {
@@ -2148,13 +2149,17 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
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
@@ -2163,7 +2168,8 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		struct net_device *master = dev->master;
 
 		if (master->netdev_ops->ndo_fdb_del)
-			err = master->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+			err = master->netdev_ops->ndo_fdb_del(ndm, tb,
+							      dev, addr);
 
 		if (err)
 			goto out;
@@ -2173,7 +2179,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	/* Embedded bridge, macvlan, and any other device support */
 	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_del) {
-		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+		err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
-- 
1.7.7.6
