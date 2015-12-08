From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue,  8 Dec 2015 12:48:05 -0800
Message-ID: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35489 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbLHUsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 15:48:13 -0500
Received: by pfu207 with SMTP id 207so17616571pfu.2
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 12:48:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VRFs require ip rules for route lookups to work properly. Currently
creating a VRF means instantiating a device and then adding the 4 ip
and ip6 rules:

    ip link add vrf-${VRF} type vrf table ${TBID}
    ip ru add oif vrf-${VRF} table ${TBID}
    ip ru add iif vrf-${VRF} table ${TBID}
    ip -6 ru add oif vrf-${VRF} table $TBID
    ip -6 ru add iif vrf-${VRF} table $TBID

Since the table is required when the vrf device is created the rules can
be inserted automatically lightening the overhead and improving the
user experience (only the ip link add is needed).

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- addressed comments from Nik

 drivers/net/vrf.c       | 122 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/fib_rules.h |   3 ++
 net/core/fib_rules.c    |   6 ++-
 3 files changed, 128 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 56abdf224d35..a1f9abb1183d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -36,6 +36,7 @@
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
+#include <net/fib_rules.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -50,6 +51,7 @@ struct net_vrf {
 	struct rtable           *rth;
 	struct rt6_info		*rt6;
 	u32                     tb_id;
+	u32                     pref;
 };
 
 struct pcpu_dstats {
@@ -809,6 +811,114 @@ static const struct ethtool_ops vrf_ethtool_ops = {
 	.get_drvinfo	= vrf_get_drvinfo,
 };
 
+static inline size_t vrf_fib_rule_nl_size(bool have_pref)
+{
+	size_t sz;
+
+	sz = NLMSG_ALIGN(sizeof(struct fib_rule_hdr))
+			 + nla_total_size(IFNAMSIZ)     /* FRA_{I,O}IFNAME */
+			 + nla_total_size(sizeof(u32)); /* FRA_TABLE */
+
+	if (have_pref)
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
+	skb = nlmsg_new(vrf_fib_rule_nl_size(!!vrf->pref), GFP_KERNEL);
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
+	if (vrf->pref) {
+		if (nla_put_u32(skb, FRA_PRIORITY, vrf->pref))
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
@@ -842,6 +952,7 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static void vrf_dellink(struct net_device *dev, struct list_head *head)
 {
+	vrf_del_fib_rules(dev);
 	unregister_netdevice_queue(dev, head);
 }
 
@@ -849,6 +960,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
+	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
@@ -857,7 +969,15 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	return register_netdevice(dev);
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	err = vrf_add_fib_rules(dev);
+	if (err)
+		unregister_netdevice(dev);
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
