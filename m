From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v0 1/5] net: add generic PF_BRIDGE:RTM_ FDB hooks
Date: Mon, 19 Mar 2012 00:19:19 -0700
Message-ID: <4F66DDF7.602@intel.com>
References: <20120319065543.11166.76186.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kvm@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4549 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab2CSHTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 03:19:20 -0400
In-Reply-To: <20120319065543.11166.76186.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forgot to change the title resending with a title that won't
be dropped by netdev and kvm mailing lists. And updated my
local repo so it won't happen again.

---

This adds two new flags NTF_MASTER and NTF_LOWERDEV that can
now be used to specify where PF_BRIDGE netlink commands should
be sent. NTF_MASTER sends the commands to the 'dev->master'
device for parsing. Typically this will be the linux net/bridge,
macvlan, or open-vswitch devices. Also without any flags set
the command will be handled by the master device as well so
that current user space tools continue to work as expected.

The NTF_LOWERDEV flag will push the PF_BRIDGE commands to the
device. In the basic example below the commands are then parsed
and programmed in the embedded bridge.

Note if both NTF_LOWERDEV and NTF_MASTER bits are set then the
command will be sent both to 'dev->master' and 'dev' this allows
user space to easily keep the embedded bridge and software bridge
in sync.

To support this new net device ops were added to call into
the device and the existing bridging code was refactored
to use these. There should be no change from user space.

A basic setup with a SR-IOV enabled NIC looks like this,

          veth0  veth2
            |      |
          ------------
          |  bridge0 |   <---- software bridging
          ------------
               /
               /
  ethx.y      ethx
    VF         PF
     \         \          <---- propagate FDB entries to HW
     \         \
  --------------------
  |  Embedded Bridge |    <---- hardware offloaded switching
  --------------------

In this case the embedded bridge must be managed to allow 'veth0'
to communicate with 'ethx.y' correctly. At present drivers managing
the embedded bridge either send frames onto the network which
then get dropped by the switch OR the embedded bridge will flood
these frames. With this patch we have a mechanism to manage the
embedded bridge correctly from user space. This example is specific
to SR-IOV but replacing the VF with another PF or dropping this
into the DSA framework generates similar management issues.

Examples session using the 'br'[1] tool to add, dump and then
delete a mac address with a new "embedded" option and enabled
ixgbe driver:

# br fdb add 22:35:19:ac:60:59 dev eth3
# br fdb
port    mac addr                flags
veth0   22:35:19:ac:60:58       static
veth0   9a:5f:81:f7:f6:ec       local
eth3    00:1b:21:55:23:59       local
eth3    22:35:19:ac:60:59       static
veth0   22:35:19:ac:60:57       static
#br fdb add 22:35:19:ac:60:59 embedded dev eth3
#br fdb
port    mac addr                flags
veth0   22:35:19:ac:60:58       static
veth0   9a:5f:81:f7:f6:ec       local
eth3    00:1b:21:55:23:59       local
eth3    22:35:19:ac:60:59       static
veth0   22:35:19:ac:60:57       static
eth3    22:35:19:ac:60:59       local embedded
#br fdb del 22:35:19:ac:60:59 embedded dev eth3

I added a couple lines to 'br' to set the flags correctly is all. It
is my opinion that the merit of this patch is now embedded and SW
bridges can both be modeled correctly in user space using very nearly
the same message passing.

[1] 'br' tool was published as an RFC here and will be renamed 'bridge'
    http://patchwork.ozlabs.org/patch/117664/

Thanks to Jamal Hadi Salim, Stephen Hemminger and Ben Hutchings for
valuable feedback, suggestions, and review.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/neighbour.h |    3 +
 include/linux/netdevice.h |   26 ++++++++
 include/linux/rtnetlink.h |    4 +
 net/bridge/br_device.c    |    3 +
 net/bridge/br_fdb.c       |  128 ++++++++++--------------------------------
 net/bridge/br_netlink.c   |   12 ----
 net/bridge/br_private.h   |   15 ++++-
 net/core/rtnetlink.c      |  138 +++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 217 insertions(+), 112 deletions(-)

diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index b188f68..3a94409 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -33,6 +33,9 @@ enum {
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_ROUTER	0x80
 
+#define NTF_LOWERDEV	0x02
+#define NTF_MASTER	0x04
+
 /*
  *	Neighbor Cache Entry States.
  */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4535a4e..4208901 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -54,6 +54,7 @@
 #include <net/netprio_cgroup.h>
 
 #include <linux/netdev_features.h>
+#include <linux/neighbour.h>
 
 struct netpoll_info;
 struct phy_device;
@@ -904,6 +905,19 @@ struct netdev_fcoe_hbainfo {
  *	feature set might be less than what was returned by ndo_fix_features()).
  *	Must return >0 or -errno if it changed dev->features itself.
  *
+ * int (*ndo_fdb_add)(struct ndmsg *ndm, struct net_device *dev,
+ *		      unsigned char *addr, u16 flags)
+ *	Adds an FDB entry to dev for addr. The ndmsg contains flags to indicate
+ *	if the dev->master FDB should be updated or the devices internal FDB.
+ * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
+ *		      unsigned char *addr)
+ *	Deletes the FDB entry from dev coresponding to addr. The ndmsg
+ *	contains flags to indicate if the dev->master FDB should be
+ *	updated or the devices internal FDB.
+ * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
+ *		       struct net_device *dev, int idx)
+ *	Used to add FDB entries to dump requests. Implementers should add
+ *	entries to skb and update idx with the number of entries.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1001,6 +1015,18 @@ struct net_device_ops {
 						    netdev_features_t features);
 	int			(*ndo_neigh_construct)(struct neighbour *n);
 	void			(*ndo_neigh_destroy)(struct neighbour *n);
+
+	int			(*ndo_fdb_add)(struct ndmsg *ndm,
+					       struct net_device *dev,
+					       unsigned char *addr,
+					       u16 flags);
+	int			(*ndo_fdb_del)(struct ndmsg *ndm,
+					       struct net_device *dev,
+					       unsigned char *addr);
+	int			(*ndo_fdb_dump)(struct sk_buff *skb,
+						struct netlink_callback *cb,
+						struct net_device *dev,
+						int idx);
 };
 
 /*
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 577592e..2c1de89 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -801,6 +801,10 @@ rtattr_failure:
 	return table;
 }
 
+extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
+			     struct netlink_callback *cb,
+			     struct net_device *dev,
+			     int idx);
 #endif /* __KERNEL__ */
 
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ba829de..d6e5929 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -317,6 +317,9 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_add_slave		 = br_add_slave,
 	.ndo_del_slave		 = br_del_slave,
 	.ndo_fix_features        = br_fix_features,
+	.ndo_fdb_add		 = br_fdb_add,
+	.ndo_fdb_del		 = br_fdb_delete,
+	.ndo_fdb_dump		 = br_fdb_dump,
 };
 
 static void br_dev_free(struct net_device *dev)
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5ba0c84..2f9dc98 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -535,44 +535,38 @@ errout:
 }
 
 /* Dump information about entries, in response to GETNEIGH */
-int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+int br_fdb_dump(struct sk_buff *skb,
+		struct netlink_callback *cb,
+		struct net_device *dev,
+		int idx)
 {
-	struct net *net = sock_net(skb->sk);
-	struct net_device *dev;
-	int idx = 0;
-
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		struct net_bridge *br = netdev_priv(dev);
-		int i;
-
-		if (!(dev->priv_flags & IFF_EBRIDGE))
-			continue;
+	struct net_bridge *br = netdev_priv(dev);
+	int i;
 
-		for (i = 0; i < BR_HASH_SIZE; i++) {
-			struct hlist_node *h;
-			struct net_bridge_fdb_entry *f;
+	if (!(dev->priv_flags & IFF_EBRIDGE))
+		goto out;
 
-			hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
-				if (idx < cb->args[0])
-					goto skip;
+	for (i = 0; i < BR_HASH_SIZE; i++) {
+		struct hlist_node *h;
+		struct net_bridge_fdb_entry *f;
 
-				if (fdb_fill_info(skb, br, f,
-						  NETLINK_CB(cb->skb).pid,
-						  cb->nlh->nlmsg_seq,
-						  RTM_NEWNEIGH,
-						  NLM_F_MULTI) < 0)
-					break;
+		hlist_for_each_entry_rcu(f, h, &br->hash[i], hlist) {
+			if (idx < cb->args[0])
+				goto skip;
+
+			if (fdb_fill_info(skb, br, f,
+					  NETLINK_CB(cb->skb).pid,
+					  cb->nlh->nlmsg_seq,
+					  RTM_NEWNEIGH,
+					  NLM_F_MULTI) < 0)
+				break;
 skip:
-				++idx;
-			}
+			++idx;
 		}
 	}
-	rcu_read_unlock();
-
-	cb->args[0] = idx;
 
-	return skb->len;
+out:
+	return idx;
 }
 
 /* Update (create or replace) forwarding database entry */
@@ -614,43 +608,11 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 }
 
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
-int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
+	       unsigned char *addr, u16 nlh_flags)
 {
-	struct net *net = sock_net(skb->sk);
-	struct ndmsg *ndm;
-	struct nlattr *tb[NDA_MAX+1];
-	struct net_device *dev;
 	struct net_bridge_port *p;
-	const __u8 *addr;
-	int err;
-
-	ASSERT_RTNL();
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
-	if (err < 0)
-		return err;
-
-	ndm = nlmsg_data(nlh);
-	if (ndm->ndm_ifindex == 0) {
-		pr_info("bridge: RTM_NEWNEIGH with invalid ifindex\n");
-		return -EINVAL;
-	}
-
-	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
-	if (dev == NULL) {
-		pr_info("bridge: RTM_NEWNEIGH with unknown ifindex\n");
-		return -ENODEV;
-	}
-
-	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
-		pr_info("bridge: RTM_NEWNEIGH with invalid address\n");
-		return -EINVAL;
-	}
-
-	addr = nla_data(tb[NDA_LLADDR]);
-	if (!is_valid_ether_addr(addr)) {
-		pr_info("bridge: RTM_NEWNEIGH with invalid ether address\n");
-		return -EINVAL;
-	}
+	int err = 0;
 
 	if (!(ndm->ndm_state & (NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE))) {
 		pr_info("bridge: RTM_NEWNEIGH with invalid state %#x\n", ndm->ndm_state);
@@ -670,14 +632,14 @@ int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		rcu_read_unlock();
 	} else {
 		spin_lock_bh(&p->br->hash_lock);
-		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh->nlmsg_flags);
+		err = fdb_add_entry(p, addr, ndm->ndm_state, nlh_flags);
 		spin_unlock_bh(&p->br->hash_lock);
 	}
 
 	return err;
 }
 
-static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
+static int fdb_delete_by_addr(struct net_bridge_port *p, u8 *addr)
 {
 	struct net_bridge *br = p->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
@@ -692,40 +654,12 @@ static int fdb_delete_by_addr(struct net_bridge_port *p, const u8 *addr)
 }
 
 /* Remove neighbor entry with RTM_DELNEIGH */
-int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+int br_fdb_delete(struct ndmsg *ndm, struct net_device *dev,
+		  unsigned char *addr)
 {
-	struct net *net = sock_net(skb->sk);
-	struct ndmsg *ndm;
 	struct net_bridge_port *p;
-	struct nlattr *llattr;
-	const __u8 *addr;
-	struct net_device *dev;
 	int err;
 
-	ASSERT_RTNL();
-	if (nlmsg_len(nlh) < sizeof(*ndm))
-		return -EINVAL;
-
-	ndm = nlmsg_data(nlh);
-	if (ndm->ndm_ifindex == 0) {
-		pr_info("bridge: RTM_DELNEIGH with invalid ifindex\n");
-		return -EINVAL;
-	}
-
-	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
-	if (dev == NULL) {
-		pr_info("bridge: RTM_DELNEIGH with unknown ifindex\n");
-		return -ENODEV;
-	}
-
-	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
-	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
-		pr_info("bridge: RTM_DELNEIGH with invalid address\n");
-		return -EINVAL;
-	}
-
-	addr = nla_data(llattr);
-
 	p = br_port_get_rtnl(dev);
 	if (p == NULL) {
 		pr_info("bridge: RTM_DELNEIGH %s not a bridge port\n",
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index a1daf82..15f74fc 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -235,18 +235,6 @@ int __init br_netlink_init(void)
 			      br_rtm_setlink, NULL, NULL);
 	if (err)
 		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH,
-			      br_fdb_add, NULL, NULL);
-	if (err)
-		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_DELNEIGH,
-			      br_fdb_delete, NULL, NULL);
-	if (err)
-		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_GETNEIGH,
-			      NULL, br_fdb_dump, NULL);
-	if (err)
-		goto err3;
 
 	return 0;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0b67a63..929b9f6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -363,9 +363,18 @@ extern int br_fdb_insert(struct net_bridge *br,
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
-extern int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb);
-extern int br_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
-extern int br_fdb_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
+
+extern int br_fdb_delete(struct ndmsg *ndm,
+			 struct net_device *dev,
+			 unsigned char *addr);
+extern int br_fdb_add(struct ndmsg *nlh,
+		      struct net_device *dev,
+		      unsigned char *addr,
+		      u16 nlh_flags);
+extern int br_fdb_dump(struct sk_buff *skb,
+		       struct netlink_callback *cb,
+		       struct net_device *dev,
+		       int idx);
 
 /* br_forward.c */
 extern void br_deliver(const struct net_bridge_port *to,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1a63c6e..8c3278a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -35,7 +35,9 @@
 #include <linux/security.h>
 #include <linux/mutex.h>
 #include <linux/if_addr.h>
+#include <linux/if_bridge.h>
 #include <linux/pci.h>
+#include <linux/etherdevice.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -1973,6 +1975,138 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
 }
 
+static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct nlattr *tb[NDA_MAX+1];
+	struct net_device *dev;
+	u8 *addr;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
+	if (err < 0)
+		return err;
+
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex == 0) {
+		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ifindex\n");
+		return -EINVAL;
+	}
+
+	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+	if (dev == NULL) {
+		pr_info("PF_BRIDGE: RTM_NEWNEIGH with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	if (!tb[NDA_LLADDR] || nla_len(tb[NDA_LLADDR]) != ETH_ALEN) {
+		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(tb[NDA_LLADDR]);
+	if (!is_valid_ether_addr(addr)) {
+		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ether address\n");
+		return -EINVAL;
+	}
+
+	err = -EOPNOTSUPP;
+
+	/* Support software bridge default usage */
+	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
+	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
+		struct net_device *master = dev->master;
+
+		if (master->netdev_ops->ndo_fdb_add)
+			err = master->netdev_ops->ndo_fdb_add(ndm, dev, addr,
+							      nlh->nlmsg_flags);
+	}
+
+	/* Embedded bridge, macvlan, and any other device support */
+	if ((ndm->ndm_flags & NTF_LOWERDEV) &&
+	    dev->netdev_ops->ndo_fdb_add)
+		err = dev->netdev_ops->ndo_fdb_add(ndm, dev, addr,
+						   nlh->nlmsg_flags);
+
+	return err;
+}
+
+static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ndmsg *ndm;
+	struct nlattr *llattr;
+	struct net_device *dev;
+	int err = -EINVAL;
+	__u8 *addr;
+
+	if (nlmsg_len(nlh) < sizeof(*ndm))
+		return -EINVAL;
+
+	ndm = nlmsg_data(nlh);
+	if (ndm->ndm_ifindex == 0) {
+		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ifindex\n");
+		return -EINVAL;
+	}
+
+	dev = __dev_get_by_index(net, ndm->ndm_ifindex);
+	if (dev == NULL) {
+		pr_info("PF_BRIDGE: RTM_DELNEIGH with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	llattr = nlmsg_find_attr(nlh, sizeof(*ndm), NDA_LLADDR);
+	if (llattr == NULL || nla_len(llattr) != ETH_ALEN) {
+		pr_info("PF_BRIGDE: RTM_DELNEIGH with invalid address\n");
+		return -EINVAL;
+	}
+
+	addr = nla_data(llattr);
+	err = -EOPNOTSUPP;
+
+	/* Support software bridge default usage */
+	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
+	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
+		struct net_device *master = dev->master;
+
+		if (master->netdev_ops->ndo_fdb_del)
+			err = master->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+	}
+
+	/* Embedded bridge, macvlan, and any other device support */
+	if ((ndm->ndm_flags & NTF_LOWERDEV) &&
+	    dev->netdev_ops->ndo_fdb_del)
+		err = dev->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+
+	return err;
+}
+
+static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx = 0;
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		if (dev->priv_flags & IFF_BRIDGE_PORT) {
+			struct net_device *master = dev->master;
+			const struct net_device_ops *ops = master->netdev_ops;
+
+			if (ops->ndo_fdb_dump)
+				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
+		}
+
+		if (dev->netdev_ops->ndo_fdb_dump)
+			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
+	}
+	rcu_read_unlock();
+
+	cb->args[0] = idx;
+	return skb->len;
+}
+
 /* Protected by RTNL sempahore.  */
 static struct rtattr **rta_buf;
 static int rtattr_max;
@@ -2145,5 +2279,9 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
+
+	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, NULL);
 }
 
