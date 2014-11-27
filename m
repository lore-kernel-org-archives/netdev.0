From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 04/21] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Thu, 27 Nov 2014 11:40:09 +0100
Message-ID: <1417084826-9875-5-git-send-email-jiri@resnulli.us>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wg0-f42.google.com ([74.125.82.42]:45315 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754244AbaK0Kkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 05:40:35 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so6129063wgg.29
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 02:40:33 -0800 (PST)
In-Reply-To: <1417084826-9875-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
u16 vid to drivers from there.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Acked-by: John Fastabend <john.r.fastabend@intel.com>
---
v3->v4:
-fixed spelling of "fdb" pointed out by Andy
new in v3
---
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  9 +++--
 drivers/net/macvlan.c                            |  4 +-
 drivers/net/vxlan.c                              |  4 +-
 include/linux/netdevice.h                        |  8 ++--
 include/linux/rtnetlink.h                        |  6 ++-
 net/bridge/br_fdb.c                              | 39 ++----------------
 net/bridge/br_private.h                          |  4 +-
 net/core/rtnetlink.c                             | 50 ++++++++++++++++++++----
 10 files changed, 70 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7262077..5ed5e40 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7536,7 +7536,7 @@ static int i40e_get_phys_port_id(struct net_device *netdev,
  */
 static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			    struct net_device *dev,
-			    const unsigned char *addr,
+			    const unsigned char *addr, u16 vid,
 			    u16 flags)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 932f779..1bad9f4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7708,7 +7708,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 
 static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
-			     const unsigned char *addr,
+			     const unsigned char *addr, u16 vid,
 			     u16 flags)
 {
 	/* guarantee we can provide a unique filter for the unicast address */
@@ -7717,7 +7717,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			return -ENOMEM;
 	}
 
-	return ndo_dflt_fdb_add(ndm, tb, dev, addr, flags);
+	return ndo_dflt_fdb_add(ndm, tb, dev, addr, vid, flags);
 }
 
 static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a913b3a..3227c80 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -376,13 +376,14 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 }
 
 static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
-			struct net_device *netdev, const unsigned char *addr)
+			struct net_device *netdev,
+			const unsigned char *addr, u16 vid)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err = -EOPNOTSUPP;
 
 	if (!adapter->fdb_mac_learn)
-		return ndo_dflt_fdb_del(ndm, tb, netdev, addr);
+		return ndo_dflt_fdb_del(ndm, tb, netdev, addr, vid);
 
 	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
 	    qlcnic_sriov_check(adapter)) {
@@ -401,13 +402,13 @@ static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 
 static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			struct net_device *netdev,
-			const unsigned char *addr, u16 flags)
+			const unsigned char *addr, u16 vid, u16 flags)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
 
 	if (!adapter->fdb_mac_learn)
-		return ndo_dflt_fdb_add(ndm, tb, netdev, addr, flags);
+		return ndo_dflt_fdb_add(ndm, tb, netdev, addr, vid, flags);
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) &&
 	    !qlcnic_sriov_check(adapter)) {
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index bfb0b6e..a1a3e3e 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -872,7 +872,7 @@ static int macvlan_vlan_rx_kill_vid(struct net_device *dev,
 
 static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev,
-			   const unsigned char *addr,
+			   const unsigned char *addr, u16 vid,
 			   u16 flags)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -897,7 +897,7 @@ static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 static int macvlan_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev,
-			   const unsigned char *addr)
+			   const unsigned char *addr, u16 vid)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	int err = -EINVAL;
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e9f81d4..7d8013d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -849,7 +849,7 @@ static int vxlan_fdb_parse(struct nlattr *tb[], struct vxlan_dev *vxlan,
 /* Add static entry (via netlink) */
 static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			 struct net_device *dev,
-			 const unsigned char *addr, u16 flags)
+			 const unsigned char *addr, u16 vid, u16 flags)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	/* struct net *net = dev_net(vxlan->dev); */
@@ -885,7 +885,7 @@ static int vxlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 /* Delete entry (via netlink) */
 static int vxlan_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 			    struct net_device *dev,
-			    const unsigned char *addr)
+			    const unsigned char *addr, u16 vid)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2cb7724..589929c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -951,11 +951,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *
  * int (*ndo_fdb_add)(struct ndmsg *ndm, struct nlattr *tb[],
  *		      struct net_device *dev,
- *		      const unsigned char *addr, u16 flags)
+ *		      const unsigned char *addr, u16 vid, u16 flags)
  *	Adds an FDB entry to dev for addr.
  * int (*ndo_fdb_del)(struct ndmsg *ndm, struct nlattr *tb[],
  *		      struct net_device *dev,
- *		      const unsigned char *addr)
+ *		      const unsigned char *addr, u16 vid)
  *	Deletes the FDB entry from dev coresponding to addr.
  * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
  *		       struct net_device *dev, struct net_device *filter_dev,
@@ -1128,11 +1128,13 @@ struct net_device_ops {
 					       struct nlattr *tb[],
 					       struct net_device *dev,
 					       const unsigned char *addr,
+					       u16 vid,
 					       u16 flags);
 	int			(*ndo_fdb_del)(struct ndmsg *ndm,
 					       struct nlattr *tb[],
 					       struct net_device *dev,
-					       const unsigned char *addr);
+					       const unsigned char *addr,
+					       u16 vid);
 	int			(*ndo_fdb_dump)(struct sk_buff *skb,
 						struct netlink_callback *cb,
 						struct net_device *dev,
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6cacbce..063f0f5 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -94,11 +94,13 @@ extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
 			    struct nlattr *tb[],
 			    struct net_device *dev,
 			    const unsigned char *addr,
-			     u16 flags);
+			    u16 vid,
+			    u16 flags);
 extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
 			    struct nlattr *tb[],
 			    struct net_device *dev,
-			    const unsigned char *addr);
+			    const unsigned char *addr,
+			    u16 vid);
 
 extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev, u16 mode);
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 08ef4e7..b1be971 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -805,33 +805,17 @@ static int __br_fdb_add(struct ndmsg *ndm, struct net_bridge_port *p,
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
 int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	       struct net_device *dev,
-	       const unsigned char *addr, u16 nlh_flags)
+	       const unsigned char *addr, u16 vid, u16 nlh_flags)
 {
 	struct net_bridge_port *p;
 	int err = 0;
 	struct net_port_vlans *pv;
-	unsigned short vid = VLAN_N_VID;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
 		return -EINVAL;
 	}
 
-	if (tb[NDA_VLAN]) {
-		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
-			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
-			return -EINVAL;
-		}
-
-		vid = nla_get_u16(tb[NDA_VLAN]);
-
-		if (!vid || vid >= VLAN_VID_MASK) {
-			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
-				vid);
-			return -EINVAL;
-		}
-	}
-
 	if (is_zero_ether_addr(addr)) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid ether address\n");
 		return -EINVAL;
@@ -845,7 +829,7 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	}
 
 	pv = nbp_get_vlan_info(p);
-	if (vid != VLAN_N_VID) {
+	if (vid) {
 		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
 			pr_info("bridge: RTM_NEWNEIGH with unconfigured "
 				"vlan %d on port %s\n", vid, dev->name);
@@ -903,27 +887,12 @@ static int __br_fdb_delete(struct net_bridge_port *p,
 /* Remove neighbor entry with RTM_DELNEIGH */
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		  struct net_device *dev,
-		  const unsigned char *addr)
+		  const unsigned char *addr, u16 vid)
 {
 	struct net_bridge_port *p;
 	int err;
 	struct net_port_vlans *pv;
-	unsigned short vid = VLAN_N_VID;
-
-	if (tb[NDA_VLAN]) {
-		if (nla_len(tb[NDA_VLAN]) != sizeof(unsigned short)) {
-			pr_info("bridge: RTM_NEWNEIGH with invalid vlan\n");
-			return -EINVAL;
-		}
 
-		vid = nla_get_u16(tb[NDA_VLAN]);
-
-		if (!vid || vid >= VLAN_VID_MASK) {
-			pr_info("bridge: RTM_NEWNEIGH with invalid vlan id %d\n",
-				vid);
-			return -EINVAL;
-		}
-	}
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
@@ -932,7 +901,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 	}
 
 	pv = nbp_get_vlan_info(p);
-	if (vid != VLAN_N_VID) {
+	if (vid) {
 		if (!pv || !test_bit(vid, pv->vlan_bitmap)) {
 			pr_info("bridge: RTM_DELNEIGH with unconfigured "
 				"vlan %d on port %s\n", vid, dev->name);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5b37077..1b529da 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -404,9 +404,9 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		   const unsigned char *addr, u16 vid, bool added_by_user);
 
 int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
-		  struct net_device *dev, const unsigned char *addr);
+		  struct net_device *dev, const unsigned char *addr, u16 vid);
 int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
-	       const unsigned char *addr, u16 nlh_flags);
+	       const unsigned char *addr, u16 vid, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct net_device *dev, struct net_device *fdev, int idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a688268..85d1d76 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -36,6 +36,7 @@
 #include <linux/mutex.h>
 #include <linux/if_addr.h>
 #include <linux/if_bridge.h>
+#include <linux/if_vlan.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
 
@@ -2312,7 +2313,7 @@ errout:
 int ndo_dflt_fdb_add(struct ndmsg *ndm,
 		     struct nlattr *tb[],
 		     struct net_device *dev,
-		     const unsigned char *addr,
+		     const unsigned char *addr, u16 vid,
 		     u16 flags)
 {
 	int err = -EINVAL;
@@ -2338,6 +2339,28 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_add);
 
+static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
+{
+	u16 vid = 0;
+
+	if (vlan_attr) {
+		if (nla_len(vlan_attr) != sizeof(u16)) {
+			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan\n");
+			return -EINVAL;
+		}
+
+		vid = nla_get_u16(vlan_attr);
+
+		if (!vid || vid >= VLAN_VID_MASK) {
+			pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid vlan id %d\n",
+				vid);
+			return -EINVAL;
+		}
+	}
+	*p_vid = vid;
+	return 0;
+}
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2345,6 +2368,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[NDA_MAX+1];
 	struct net_device *dev;
 	u8 *addr;
+	u16 vid;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
@@ -2370,6 +2394,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	if (err)
+		return err;
+
 	err = -EOPNOTSUPP;
 
 	/* Support fdb on master device the net/bridge default case */
@@ -2378,7 +2406,8 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 		const struct net_device_ops *ops = br_dev->netdev_ops;
 
-		err = ops->ndo_fdb_add(ndm, tb, dev, addr, nlh->nlmsg_flags);
+		err = ops->ndo_fdb_add(ndm, tb, dev, addr, vid,
+				       nlh->nlmsg_flags);
 		if (err)
 			goto out;
 		else
@@ -2389,9 +2418,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if ((ndm->ndm_flags & NTF_SELF)) {
 		if (dev->netdev_ops->ndo_fdb_add)
 			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
+							   vid,
 							   nlh->nlmsg_flags);
 		else
-			err = ndo_dflt_fdb_add(ndm, tb, dev, addr,
+			err = ndo_dflt_fdb_add(ndm, tb, dev, addr, vid,
 					       nlh->nlmsg_flags);
 
 		if (!err) {
@@ -2409,7 +2439,7 @@ out:
 int ndo_dflt_fdb_del(struct ndmsg *ndm,
 		     struct nlattr *tb[],
 		     struct net_device *dev,
-		     const unsigned char *addr)
+		     const unsigned char *addr, u16 vid)
 {
 	int err = -EINVAL;
 
@@ -2438,6 +2468,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net_device *dev;
 	int err = -EINVAL;
 	__u8 *addr;
+	u16 vid;
 
 	if (!netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
@@ -2465,6 +2496,10 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	addr = nla_data(tb[NDA_LLADDR]);
 
+	err = fdb_vid_parse(tb[NDA_VLAN], &vid);
+	if (err)
+		return err;
+
 	err = -EOPNOTSUPP;
 
 	/* Support fdb on master device the net/bridge default case */
@@ -2474,7 +2509,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 		const struct net_device_ops *ops = br_dev->netdev_ops;
 
 		if (ops->ndo_fdb_del)
-			err = ops->ndo_fdb_del(ndm, tb, dev, addr);
+			err = ops->ndo_fdb_del(ndm, tb, dev, addr, vid);
 
 		if (err)
 			goto out;
@@ -2485,9 +2520,10 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	/* Embedded bridge, macvlan, and any other device support */
 	if (ndm->ndm_flags & NTF_SELF) {
 		if (dev->netdev_ops->ndo_fdb_del)
-			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
+			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr,
+							   vid);
 		else
-			err = ndo_dflt_fdb_del(ndm, tb, dev, addr);
+			err = ndo_dflt_fdb_del(ndm, tb, dev, addr, vid);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
-- 
1.9.3
