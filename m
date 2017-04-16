From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: rtnetlink: plumb extended ack to doit function
Date: Sun, 16 Apr 2017 09:48:24 -0700
Message-ID: <1492361304-6116-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jhs@mojatatu.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33297 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932131AbdDPQsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 12:48:30 -0400
Received: by mail-pf0-f172.google.com with SMTP id s16so56982683pfs.0
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 09:48:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink_ext_ack arg to rtnl_doit_func. Pass extack arg to nlmsg_parse
for doit functions that call it directly.

This is the first step to using extended error reporting in rtnetlink.
>From here individual subsystems can be updated to set netlink_ext_ack as
needed.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c        |  4 ++--
 include/net/fib_rules.h  |  6 ++++--
 include/net/rtnetlink.h  |  3 ++-
 net/bridge/br_mdb.c      |  6 ++++--
 net/can/gw.c             |  6 ++++--
 net/core/fib_rules.c     | 10 ++++++----
 net/core/neighbour.c     | 15 +++++++++------
 net/core/net_namespace.c | 10 ++++++----
 net/core/rtnetlink.c     | 42 ++++++++++++++++++++++++++----------------
 net/dcb/dcbnl.c          |  5 +++--
 net/decnet/dn_dev.c      | 12 ++++++++----
 net/decnet/dn_fib.c      | 10 ++++++----
 net/decnet/dn_route.c    |  6 ++++--
 net/ipv4/devinet.c       | 13 ++++++++-----
 net/ipv4/fib_frontend.c  |  6 ++++--
 net/ipv4/ipmr.c          | 10 ++++++----
 net/ipv4/route.c         |  5 +++--
 net/ipv6/addrconf.c      | 20 ++++++++++++--------
 net/ipv6/addrlabel.c     | 12 ++++++++----
 net/ipv6/route.c         | 11 +++++++----
 net/mpls/af_mpls.c       |  9 ++++++---
 net/phonet/pn_netlink.c  | 10 ++++++----
 net/qrtr/qrtr.c          |  5 +++--
 net/sched/act_api.c      |  5 +++--
 net/sched/cls_api.c      |  5 +++--
 net/sched/sch_api.c      | 15 +++++++++------
 26 files changed, 162 insertions(+), 99 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index eb5493e83556..a84dcad2ee91 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1282,11 +1282,11 @@ static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
 	/* fib_nl_{new,del}rule handling looks for net from skb->sk */
 	skb->sk = dev_net(dev)->rtnl;
 	if (add_it) {
-		err = fib_nl_newrule(skb, nlh);
+		err = fib_nl_newrule(skb, nlh, NULL);
 		if (err == -EEXIST)
 			err = 0;
 	} else {
-		err = fib_nl_delrule(skb, nlh);
+		err = fib_nl_delrule(skb, nlh, NULL);
 		if (err == -ENOENT)
 			err = 0;
 	}
diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 1243b9c7694e..76c7300626d6 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -143,6 +143,8 @@ int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
 			 u32 flags);
 bool fib_rule_matchall(const struct fib_rule *rule);
 
-int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh);
-int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh);
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
+		   struct netlink_ext_ack *extack);
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
+		   struct netlink_ext_ack *extack);
 #endif
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index c07b941fce89..78fa5fe32947 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -4,7 +4,8 @@
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
 
-typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
+typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *,
+			      struct netlink_ext_ack *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 993626a7fc3b..b0845480a3ae 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -569,7 +569,8 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	return ret;
 }
 
-static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
+		      struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_bridge_vlan_group *vg;
@@ -663,7 +664,8 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 	return err;
 }
 
-static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
+		      struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_bridge_vlan_group *vg;
diff --git a/net/can/gw.c b/net/can/gw.c
index 3b84fb7d98aa..ad5bf5d508d3 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -809,7 +809,8 @@ static int cgw_parse_attr(struct nlmsghdr *nlh, struct cf_mod *mod,
 	return 0;
 }
 
-static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh)
+static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct rtcanmsg *r;
 	struct cgw_job *gwj;
@@ -921,7 +922,8 @@ static void cgw_remove_all_jobs(void)
 	}
 }
 
-static int cgw_remove_job(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int cgw_remove_job(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct cgw_job *gwj = NULL;
 	struct hlist_node *nx;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index df03110ca3c8..c58c1df6f92b 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -368,7 +368,8 @@ static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
 	return 0;
 }
 
-int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
+int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh,
+		   struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -386,7 +387,7 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, extack);
 	if (err < 0)
 		goto errout;
 
@@ -561,7 +562,8 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 }
 EXPORT_SYMBOL_GPL(fib_nl_newrule);
 
-int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
+int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
+		   struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -580,7 +582,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*frh), tb, FRA_MAX, ops->policy, extack);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 31f37b264710..58b0bcc125b5 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1590,7 +1590,8 @@ static struct neigh_table *neigh_find_table(int family)
 	return tbl;
 }
 
-static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -1648,7 +1649,8 @@ static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh,
+		     struct netlink_ext_ack *extack)
 {
 	int flags = NEIGH_UPDATE_F_ADMIN | NEIGH_UPDATE_F_OVERRIDE;
 	struct net *net = sock_net(skb->sk);
@@ -1661,7 +1663,7 @@ static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err;
 
 	ASSERT_RTNL();
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, extack);
 	if (err < 0)
 		goto out;
 
@@ -1936,7 +1938,8 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 	[NDTPA_LOCKTIME]		= { .type = NLA_U64 },
 };
 
-static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct neigh_table *tbl;
@@ -1946,7 +1949,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err, tidx;
 
 	err = nlmsg_parse(nlh, sizeof(*ndtmsg), tb, NDTA_MAX,
-			  nl_neightbl_policy, NULL);
+			  nl_neightbl_policy, extack);
 	if (err < 0)
 		goto errout;
 
@@ -1984,7 +1987,7 @@ static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 		int i, ifindex = 0;
 
 		err = nla_parse_nested(tbp, NDTPA_MAX, tb[NDTA_PARMS],
-				       nl_ntbl_parm_policy, NULL);
+				       nl_ntbl_parm_policy, extack);
 		if (err < 0)
 			goto errout_tbl_lock;
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index ec18cbc756d2..c1d8aed8e5a8 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -571,7 +571,8 @@ static const struct nla_policy rtnl_net_policy[NETNSA_MAX + 1] = {
 	[NETNSA_FD]		= { .type = NLA_U32 },
 };
 
-static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
@@ -579,7 +580,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int nsid, err;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
-			  rtnl_net_policy, NULL);
+			  rtnl_net_policy, extack);
 	if (err < 0)
 		return err;
 	if (!tb[NETNSA_NSID])
@@ -644,7 +645,8 @@ static int rtnl_net_fill(struct sk_buff *skb, u32 portid, u32 seq, int flags,
 	return -EMSGSIZE;
 }
 
-static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
@@ -653,7 +655,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err, id;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
-			  rtnl_net_policy, NULL);
+			  rtnl_net_policy, extack);
 	if (err < 0)
 		return err;
 	if (tb[NETNSA_PID])
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0ee5479528b5..088f9c8b4196 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2213,7 +2213,8 @@ static int do_setlink(const struct sk_buff *skb,
 	return err;
 }
 
-static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -2222,7 +2223,8 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	char ifname[IFNAMSIZ];
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy,
+			  extack);
 	if (err < 0)
 		goto errout;
 
@@ -2306,7 +2308,8 @@ int rtnl_delete_link(struct net_device *dev)
 }
 EXPORT_SYMBOL_GPL(rtnl_delete_link);
 
-static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
@@ -2315,7 +2318,7 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, extack);
 	if (err < 0)
 		return err;
 
@@ -2426,7 +2429,8 @@ static int rtnl_group_changelink(const struct sk_buff *skb,
 	return 0;
 }
 
-static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
@@ -2444,7 +2448,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 #ifdef CONFIG_MODULES
 replay:
 #endif
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, extack);
 	if (err < 0)
 		return err;
 
@@ -2678,7 +2682,8 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 }
 
-static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
+static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -2689,7 +2694,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
 	int err;
 	u32 ext_filter_mask = 0;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy, extack);
 	if (err < 0)
 		return err;
 
@@ -2960,7 +2965,8 @@ static int fdb_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)
 	return 0;
 }
 
-static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -2970,7 +2976,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u16 vid;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
@@ -3060,7 +3066,8 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_del);
 
-static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -3073,7 +3080,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!netlink_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
@@ -3503,7 +3510,8 @@ static int rtnl_bridge_notify(struct net_device *dev)
 	return err;
 }
 
-static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -3577,7 +3585,8 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -3945,7 +3954,8 @@ static size_t if_nlmsg_stats_size(const struct net_device *dev,
 	return size;
 }
 
-static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int rtnl_stats_get(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *dev = NULL;
@@ -4107,7 +4117,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (doit == NULL)
 		return -EOPNOTSUPP;
 
-	return doit(skb, nlh);
+	return doit(skb, nlh, extack);
 }
 
 static void rtnetlink_rcv(struct sk_buff *skb)
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3f5a5f710576..93106120f987 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1696,7 +1696,8 @@ static const struct reply_func reply_funcs[DCB_CMD_MAX+1] = {
 	[DCB_CMD_CEE_GET]	= { RTM_GETDCB, dcbnl_cee_get },
 };
 
-static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+		    struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *netdev;
@@ -1712,7 +1713,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	ret = nlmsg_parse(nlh, sizeof(*dcb), tb, DCB_ATTR_MAX,
-			  dcbnl_rtnl_policy, NULL);
+			  dcbnl_rtnl_policy, extack);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index e65f1be44e8e..9017a9a73ab5 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -565,7 +565,8 @@ static const struct nla_policy dn_ifa_policy[IFA_MAX+1] = {
 	[IFA_FLAGS]		= { .type = NLA_U32 },
 };
 
-static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh,
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -581,7 +582,8 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		goto errout;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy,
+			  extack);
 	if (err < 0)
 		goto errout;
 
@@ -609,7 +611,8 @@ static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -625,7 +628,8 @@ static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, dn_ifa_policy,
+			  extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 34663bf8aa6d..f9058ebeb635 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -501,7 +501,8 @@ static inline u32 rtm_get_table(struct nlattr *attrs[], u8 table)
 	return table;
 }
 
-static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
@@ -516,7 +517,7 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
@@ -527,7 +528,8 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return tb->delete(tb, r, attrs, nlh, &NETLINK_CB(skb));
 }
 
-static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
@@ -542,7 +544,7 @@ static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	err = nlmsg_parse(nlh, sizeof(*r), attrs, RTA_MAX, rtm_dn_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2d7097bbc666..4b9518a0d248 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1640,7 +1640,8 @@ const struct nla_policy rtm_dn_policy[RTA_MAX + 1] = {
 /*
  * This is called by both endnodes and routers now.
  */
-static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm = nlmsg_data(nlh);
@@ -1654,7 +1655,8 @@ static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (!net_eq(net, &init_net))
 		return -EINVAL;
 
-	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_dn_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_dn_policy,
+			  extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f33f53791f50..df14815a3b8c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -571,7 +571,8 @@ static int ip_mc_config(struct sock *sk, bool join, const struct in_ifaddr *ifa)
 	return ret;
 }
 
-static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh,
+			    struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -583,7 +584,7 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ASSERT_RTNL();
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		goto errout;
 
@@ -845,7 +846,8 @@ static struct in_ifaddr *find_matching_ifa(struct in_ifaddr *ifa)
 	return NULL;
 }
 
-static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
+			    struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct in_ifaddr *ifa;
@@ -1871,7 +1873,8 @@ static const struct nla_policy devconf_ipv4_policy[NETCONFA_MAX+1] = {
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
-				    struct nlmsghdr *nlh)
+				    struct nlmsghdr *nlh,
+				    struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX+1];
@@ -1884,7 +1887,7 @@ static int inet_netconf_get_devconf(struct sk_buff *in_skb,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
-			  devconf_ipv4_policy, NULL);
+			  devconf_ipv4_policy, extack);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 434dd2538716..5a0e456b5d58 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -710,7 +710,8 @@ static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 	return err;
 }
 
-static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
@@ -732,7 +733,8 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 	return err;
 }
 
-static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index d7be21f2174a..95ea3585a223 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2430,7 +2430,8 @@ static int ipmr_nla_get_ttls(const struct nlattr *nla, struct mfcctl *mfcc)
 /* returns < 0 on error, 0 for ADD_MFC and 1 for ADD_MFC_PROXY */
 static int rtm_to_ipmr_mfcc(struct net *net, struct nlmsghdr *nlh,
 			    struct mfcctl *mfcc, int *mrtsock,
-			    struct mr_table **mrtret)
+			    struct mr_table **mrtret,
+			    struct netlink_ext_ack *extack)
 {
 	struct net_device *dev = NULL;
 	u32 tblid = RT_TABLE_DEFAULT;
@@ -2440,7 +2441,7 @@ static int rtm_to_ipmr_mfcc(struct net *net, struct nlmsghdr *nlh,
 	int ret, rem;
 
 	ret = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipmr_policy,
-			     NULL);
+			     extack);
 	if (ret < 0)
 		goto out;
 	rtm = nlmsg_data(nlh);
@@ -2499,7 +2500,8 @@ static int rtm_to_ipmr_mfcc(struct net *net, struct nlmsghdr *nlh,
 }
 
 /* takes care of both newroute and delroute */
-static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	int ret, mrtsock, parent;
@@ -2508,7 +2510,7 @@ static int ipmr_rtm_route(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	mrtsock = 0;
 	tbl = NULL;
-	ret = rtm_to_ipmr_mfcc(net, nlh, &mfcc, &mrtsock, &tbl);
+	ret = rtm_to_ipmr_mfcc(net, nlh, &mfcc, &mrtsock, &tbl, extack);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7a4f2c38c3c4..a4443748cc1e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2629,7 +2629,8 @@ static int rt_fill_info(struct net *net,  __be32 dst, __be32 src, u32 table_id,
 	return -EMSGSIZE;
 }
 
-static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
@@ -2646,7 +2647,7 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	kuid_t uid;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv4_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d6da0fe5acca..1b34d66b9bf5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -611,7 +611,8 @@ static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
 };
 
 static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
-				     struct nlmsghdr *nlh)
+				     struct nlmsghdr *nlh,
+				     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX+1];
@@ -624,7 +625,7 @@ static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
-			  devconf_ipv6_policy, NULL);
+			  devconf_ipv6_policy, extack);
 	if (err < 0)
 		goto errout;
 
@@ -4402,7 +4403,8 @@ static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 };
 
 static int
-inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
+inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh,
+		  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
@@ -4412,7 +4414,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
@@ -4512,7 +4514,8 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
 }
 
 static int
-inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
+inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh,
+		  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
@@ -4525,7 +4528,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
@@ -4875,7 +4878,8 @@ static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	return inet6_dump_addr(skb, cb, type);
 }
 
-static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrmsg *ifm;
@@ -4887,7 +4891,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6cb4ed91722a..07cd7d248bb6 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -404,7 +404,8 @@ static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
 	[IFAL_LABEL]		= { .len = sizeof(u32), },
 };
 
-static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrlblmsg *ifal;
@@ -413,7 +414,8 @@ static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 label;
 	int err = 0;
 
-	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy,
+			  extack);
 	if (err < 0)
 		return err;
 
@@ -521,7 +523,8 @@ static inline int ip6addrlbl_msgsize(void)
 		+ nla_total_size(4);	/* IFAL_LABEL */
 }
 
-static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrlblmsg *ifal;
@@ -532,7 +535,8 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct ip6addrlbl_entry *p;
 	struct sk_buff *skb;
 
-	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy, NULL);
+	err = nlmsg_parse(nlh, sizeof(*ifal), tb, IFAL_MAX, ifal_policy,
+			  extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ccde23eba702..4ba7c49872ff 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3260,7 +3260,8 @@ static int ip6_route_multipath_del(struct fib6_config *cfg)
 	return last_err;
 }
 
-static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack)
 {
 	struct fib6_config cfg;
 	int err;
@@ -3277,7 +3278,8 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 }
 
-static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack)
 {
 	struct fib6_config cfg;
 	int err;
@@ -3565,7 +3567,8 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		     NLM_F_MULTI);
 }
 
-static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
+static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
+			      struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
@@ -3576,7 +3579,7 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	int err, iif = 0, oif = 0;
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_ipv6_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		goto errout;
 
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 07181d2273e1..088e2b459d0f 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1110,7 +1110,8 @@ static const struct nla_policy devconf_mpls_policy[NETCONFA_MAX + 1] = {
 };
 
 static int mpls_netconf_get_devconf(struct sk_buff *in_skb,
-				    struct nlmsghdr *nlh)
+				    struct nlmsghdr *nlh,
+				    struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX + 1];
@@ -1746,7 +1747,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 	return err;
 }
 
-static int mpls_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int mpls_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct mpls_route_config *cfg;
 	int err;
@@ -1767,7 +1769,8 @@ static int mpls_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 }
 
 
-static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int mpls_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
+			     struct netlink_ext_ack *extack)
 {
 	struct mpls_route_config *cfg;
 	int err;
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 363799bf97f6..45b3af3080d8 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -61,7 +61,8 @@ static const struct nla_policy ifa_phonet_policy[IFA_MAX+1] = {
 	[IFA_LOCAL] = { .type = NLA_U8 },
 };
 
-static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+		     struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -79,7 +80,7 @@ static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ASSERT_RTNL();
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_phonet_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
@@ -227,7 +228,8 @@ static const struct nla_policy rtm_phonet_policy[RTA_MAX+1] = {
 	[RTA_OIF] = { .type = NLA_U32 },
 };
 
-static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+		      struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
@@ -245,7 +247,7 @@ static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ASSERT_RTNL();
 
 	err = nlmsg_parse(nlh, sizeof(*rtm), tb, RTA_MAX, rtm_phonet_policy,
-			  NULL);
+			  extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 7fdbb34002f5..c36b0ec364a4 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -943,7 +943,8 @@ static const struct nla_policy qrtr_policy[IFA_MAX + 1] = {
 	[IFA_LOCAL] = { .type = NLA_U32 },
 };
 
-static int qrtr_addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
+static int qrtr_addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh,
+			  struct netlink_ext_ack *extack)
 {
 	struct nlattr *tb[IFA_MAX + 1];
 	struct ifaddrmsg *ifm;
@@ -957,7 +958,7 @@ static int qrtr_addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	ASSERT_RTNL();
 
-	rc = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, qrtr_policy, NULL);
+	rc = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, qrtr_policy, extack);
 	if (rc < 0)
 		return rc;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 79d875c6e8a0..82b1d48d91cc 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -993,7 +993,8 @@ static int tcf_action_add(struct net *net, struct nlattr *nla,
 	return tcf_add_notify(net, n, &actions, portid);
 }
 
-static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n,
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_ACT_MAX + 1];
@@ -1005,7 +1006,7 @@ static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
 		return -EPERM;
 
 	ret = nlmsg_parse(n, sizeof(struct tcamsg), tca, TCA_ACT_MAX, NULL,
-			  NULL);
+			  extack);
 	if (ret < 0)
 		return ret;
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index e2c68c30f97d..a8da383b681a 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -201,7 +201,8 @@ EXPORT_SYMBOL(tcf_destroy_chain);
 
 /* Add/change/delete/get a filter node */
 
-static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
+			  struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
@@ -229,7 +230,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 replay:
 	tp_created = 0;
 
-	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL, NULL);
+	err = nlmsg_parse(n, sizeof(*t), tca, TCA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fcb5ae581c04..2fa163a095cf 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1116,7 +1116,8 @@ check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w)
  * Delete/get qdisc.
  */
 
-static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n,
+			struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = nlmsg_data(n);
@@ -1131,7 +1132,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
@@ -1185,7 +1186,8 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
  * Create/change qdisc.
  */
 
-static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n,
+			   struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm;
@@ -1200,7 +1202,7 @@ static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 
 replay:
 	/* Reinit, just in case something touches this. */
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
@@ -1558,7 +1560,8 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 
 
 
-static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
+static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n,
+			 struct netlink_ext_ack *extack)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = nlmsg_data(n);
@@ -1577,7 +1580,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 	    !netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
-	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
+	err = nlmsg_parse(n, sizeof(*tcm), tca, TCA_MAX, NULL, extack);
 	if (err < 0)
 		return err;
 
-- 
2.1.4
