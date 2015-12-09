From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3] net: Add fib rules at vrf device create
Date: Wed,  9 Dec 2015 09:43:32 -0800
Message-ID: <1449683012-14145-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34730 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbbLIRnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 12:43:40 -0500
Received: by pacwq6 with SMTP id wq6so32902811pac.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:43:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRFs require ip rules for route lookups to work properly. Currently
creating a VRF means instantiating a device and then adding the 4 ip
and ip6 rules:

    ip link add vrf-${VRF} type vrf table ${TBID}
    ip link set vrf-${VRF} up
    ip ru add oif vrf-${VRF} table ${TBID}
    ip ru add iif vrf-${VRF} table ${TBID}
    ip -6 ru add oif vrf-${VRF} table $TBID
    ip -6 ru add iif vrf-${VRF} table $TBID

Similarly, cleanup requires deleting the link and removing the FIB rules.
Since the table is required when the vrf device is created the rules can
be inserted and deleted automatically lightening the overhead and improving
the user experience (only the ip link commands are needed).

The VRF driver will only automatically add and remove FIB rules if
directed by the user per a new IFLA attribute. This new attribute,
suggested by Roopa, helps maintain backward compatibility with existing
users that already manage the fib rules directly.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- add IFLA attribute to control whether the driver automatically
  creates the FIB rules (thanks, Roopa!)

v2
- addressed comments from Nik

 drivers/net/vrf.c            | 147 ++++++++++++++++++++++++++++++++++++++++++-
 include/net/fib_rules.h      |   3 +
 include/uapi/linux/if_link.h |   4 +-
 net/core/fib_rules.c         |   6 +-
 4 files changed, 156 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 56abdf224d35..b9918e8415ea 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -36,6 +36,7 @@
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
+#include <net/fib_rules.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -50,6 +51,9 @@ struct net_vrf {
 	struct rtable           *rth;
 	struct rt6_info		*rt6;
 	u32                     tb_id;
+	u32                     rule_pref;
+	u32			rule_pref_set : 1,
+				rules_auto_created : 1;
 };
 
 struct pcpu_dstats {
@@ -809,6 +813,114 @@ static const struct ethtool_ops vrf_ethtool_ops = {
 	.get_drvinfo	= vrf_get_drvinfo,
 };
 
+static inline size_t vrf_fib_rule_nl_size(bool have_rule_pref)
+{
+	size_t sz;
+
+	sz = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
+			 + nla_total_size(IFNAMSIZ)     /* FRA_{I,O}IFNAME */
+			 + nla_total_size(sizeof(u32)); /* FRA_TABLE */
+
+	if (have_rule_pref)
+		sz += nla_total_size(sizeof(u32));      /* FRA_PRIORITY */
+
+	return sz;
+}
+
+static int vrf_fib_rule(const struct net_device *dev, __u8 family,
+			int if_type, bool add_it)
+{
+	const struct net_vrf *vrf = netdev_priv(dev);
+	struct fib_rule_hdr *frh;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	int err;
+
+	skb = nlmsg_new(vrf_fib_rule_nl_size(vrf->rule_pref_set), GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(skb, 0, 0, 0, sizeof(*frh), 0);
+	if (!nlh)
+		goto nla_put_failure;
+
+	frh = nlmsg_data(nlh);
+	memset(frh, 0, sizeof(*frh));
+	frh->family = family;
+	frh->action = FR_ACT_TO_TBL;
+
+	if (nla_put_u32(skb, FRA_TABLE, vrf->tb_id))
+		goto nla_put_failure;
+
+	if (nla_put_string(skb, if_type, dev->name))
+		goto nla_put_failure;
+
+	if (vrf->rule_pref_set) {
+		if (nla_put_u32(skb, FRA_PRIORITY, vrf->rule_pref))
+			goto nla_put_failure;
+	}
+
+	nlmsg_end(skb, nlh);
+
+	/* fib_nl_{new,del}rule handling looks for net from skb->sk */
+	skb->sk = dev_net(dev)->rtnl;
+	if (add_it) {
+		err = fib_nl_newrule(skb, nlh);
+	} else {
+		err = fib_nl_delrule(skb, nlh);
+		if (err == -ENOENT)
+			err = 0;
+	}
+
+	nlmsg_free(skb);
+
+	return err;
+
+nla_put_failure:
+	nlmsg_free(skb);
+
+	return -EMSGSIZE;
+}
+
+static void vrf_del_fib_rules(const struct net_device *dev)
+{
+	if (vrf_fib_rule(dev, AF_INET,  FRA_IIFNAME, 0) ||
+	    vrf_fib_rule(dev, AF_INET,  FRA_OIFNAME, 0) ||
+	    vrf_fib_rule(dev, AF_INET6, FRA_IIFNAME, 0) ||
+	    vrf_fib_rule(dev, AF_INET6, FRA_OIFNAME, 0)) {
+		netdev_err(dev, "Failed to delete FIB rules.\n");
+	}
+}
+
+static int vrf_add_fib_rules(const struct net_device *dev)
+{
+	int err;
+
+	err = vrf_fib_rule(dev, AF_INET,  FRA_IIFNAME, 1);
+	if (err < 0)
+		goto out_err;
+
+	err = vrf_fib_rule(dev, AF_INET,  FRA_OIFNAME, 1);
+	if (err < 0)
+		goto out_err;
+
+	err = vrf_fib_rule(dev, AF_INET6, FRA_IIFNAME, 1);
+	if (err < 0)
+		goto out_err;
+
+	err = vrf_fib_rule(dev, AF_INET6, FRA_OIFNAME, 1);
+	if (err < 0)
+		goto out_err;
+
+	return 0;
+
+out_err:
+	netdev_err(dev, "Failed to add FIB rules.\n");
+	vrf_del_fib_rules(dev);
+
+	return err;
+}
+
 static void vrf_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -842,6 +954,11 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static void vrf_dellink(struct net_device *dev, struct list_head *head)
 {
+	struct net_vrf *vrf = netdev_priv(dev);
+
+	if (vrf->rules_auto_created)
+		vrf_del_fib_rules(dev);
+
 	unregister_netdevice_queue(dev, head);
 }
 
@@ -849,15 +966,43 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
+	u8 create_fib_rules = 0;
+	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
 
 	vrf->tb_id = nla_get_u32(data[IFLA_VRF_TABLE]);
 
+	if (data[IFLA_VRF_AUTOCREATE_RULES])
+		create_fib_rules = nla_get_u8(data[IFLA_VRF_AUTOCREATE_RULES]);
+
+	if (data[IFLA_VRF_RULES_PRIORITY]) {
+		/* specifying IFLA_VRF_RULES_PRIORITY is only valid if the
+		 * FIB rules are to be added when the device is created
+		 */
+		if (!create_fib_rules)
+			return -EINVAL;
+
+		vrf->rule_pref = nla_get_u32(data[IFLA_VRF_RULES_PRIORITY]);
+		vrf->rule_pref_set = 1;
+	}
+
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	return register_netdevice(dev);
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	if (create_fib_rules) {
+		err = vrf_add_fib_rules(dev);
+		if (err)
+			unregister_netdevice(dev);
+
+		vrf->rules_auto_created = 1;
+	}
+out:
+	return err;
 }
 
 static size_t vrf_nl_getsize(const struct net_device *dev)
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 59160de702b6..0b76f81345c9 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -117,4 +117,7 @@ int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
 		     struct fib_lookup_arg *);
 int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
 			 u32 flags);
+
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh);
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh);
 #endif
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5ad57375a99f..2b998c255e70 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -394,7 +394,9 @@ enum macvlan_macaddr_mode {
 /* VRF section */
 enum {
 	IFLA_VRF_UNSPEC,
-	IFLA_VRF_TABLE,
+	IFLA_VRF_TABLE,			/* u32 */
+	IFLA_VRF_RULES_PRIORITY,	/* u32 */
+	IFLA_VRF_AUTOCREATE_RULES,	/* u8  */
 	__IFLA_VRF_MAX
 };
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 365de66436ac..a5068c558bfb 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -265,7 +265,7 @@ static int validate_rulemsg(struct fib_rule_hdr *frh, struct nlattr **tb,
 	return err;
 }
 
-static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -424,8 +424,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rules_ops_put(ops);
 	return err;
 }
+EXPORT_SYMBOL_GPL(fib_nl_newrule);
 
-static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -536,6 +537,7 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	rules_ops_put(ops);
 	return err;
 }
+EXPORT_SYMBOL_GPL(fib_nl_delrule);
 
 static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 					 struct fib_rule *rule)
-- 
1.9.1
