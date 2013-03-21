From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/2] rtnetlink: Remove passing of attributes into rtnl_doit functions
Date: Thu, 21 Mar 2013 18:45:29 +0100
Message-ID: <6ca95420a71ea6973c4d42cdbf54f5802d0846e5.1363885020.git.tgraf@suug.ch>
References: <cover.1363885020.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39005
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751287Ab3CURpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:45:39 -0400
In-Reply-To: <cover.1363885020.git.tgraf@suug.ch>
In-Reply-To: <cover.1363885020.git.tgraf@suug.ch>
References: <cover.1363885020.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With decnet converted, we can finally get rid of rta_buf and its
computations around it. It also gets rid of the minimal header
length verification since all message handlers do that explicitly
anyway.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/rtnetlink.h |  2 +-
 net/bridge/br_mdb.c     |  4 +--
 net/can/gw.c            |  5 ++-
 net/core/fib_rules.c    |  4 +--
 net/core/neighbour.c    |  6 ++--
 net/core/rtnetlink.c    | 82 ++++++-------------------------------------------
 net/dcb/dcbnl.c         |  2 +-
 net/decnet/dn_dev.c     |  4 +--
 net/decnet/dn_fib.c     |  4 +--
 net/decnet/dn_route.c   |  2 +-
 net/ipv4/devinet.c      |  7 ++---
 net/ipv4/fib_frontend.c |  4 +--
 net/ipv4/route.c        |  2 +-
 net/ipv6/addrconf.c     | 10 +++---
 net/ipv6/addrlabel.c    |  6 ++--
 net/ipv6/route.c        |  6 ++--
 net/phonet/pn_netlink.c |  4 +--
 net/sched/act_api.c     |  2 +-
 net/sched/cls_api.c     |  2 +-
 net/sched/sch_api.c     |  6 ++--
 20 files changed, 47 insertions(+), 117 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 5a15fab..7026648 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -4,7 +4,7 @@
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
 
-typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *, void *);
+typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
 typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index ee79f3f..19942e3 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -382,7 +382,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	return ret;
 }
 
-static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct br_mdb_entry *entry;
@@ -458,7 +458,7 @@ unlock:
 	return err;
 }
 
-static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net_device *dev;
 	struct br_mdb_entry *entry;
diff --git a/net/can/gw.c b/net/can/gw.c
index 2d117dc..2dc619d 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -778,8 +778,7 @@ static int cgw_parse_attr(struct nlmsghdr *nlh, struct cf_mod *mod,
 	return 0;
 }
 
-static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh,
-			  void *arg)
+static int cgw_create_job(struct sk_buff *skb,  struct nlmsghdr *nlh)
 {
 	struct rtcanmsg *r;
 	struct cgw_job *gwj;
@@ -868,7 +867,7 @@ static void cgw_remove_all_jobs(void)
 	}
 }
 
-static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
+static int cgw_remove_job(struct sk_buff *skb,  struct nlmsghdr *nlh)
 {
 	struct cgw_job *gwj = NULL;
 	struct hlist_node *nx;
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 58a4ba2..d5a9f8e 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -266,7 +266,7 @@ errout:
 	return err;
 }
 
-static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
@@ -415,7 +415,7 @@ errout:
 	return err;
 }
 
-static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 3863b8f..c72a646 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1613,7 +1613,7 @@ int neigh_table_clear(struct neigh_table *tbl)
 }
 EXPORT_SYMBOL(neigh_table_clear);
 
-static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -1677,7 +1677,7 @@ out:
 	return err;
 }
 
-static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -1955,7 +1955,7 @@ static const struct nla_policy nl_ntbl_parm_policy[NDTPA_MAX+1] = {
 	[NDTPA_LOCKTIME]		= { .type = NLA_U64 },
 };
 
-static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int neightbl_set(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct neigh_table *tbl;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9a9b99e..751f124 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -515,32 +515,6 @@ out:
 	return err;
 }
 
-static const int rtm_min[RTM_NR_FAMILIES] =
-{
-	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
-	[RTM_FAM(RTM_NEWADDR)]      = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
-	[RTM_FAM(RTM_NEWROUTE)]     = NLMSG_LENGTH(sizeof(struct rtmsg)),
-	[RTM_FAM(RTM_NEWRULE)]      = NLMSG_LENGTH(sizeof(struct fib_rule_hdr)),
-	[RTM_FAM(RTM_NEWQDISC)]     = NLMSG_LENGTH(sizeof(struct tcmsg)),
-	[RTM_FAM(RTM_NEWTCLASS)]    = NLMSG_LENGTH(sizeof(struct tcmsg)),
-	[RTM_FAM(RTM_NEWTFILTER)]   = NLMSG_LENGTH(sizeof(struct tcmsg)),
-	[RTM_FAM(RTM_NEWACTION)]    = NLMSG_LENGTH(sizeof(struct tcamsg)),
-	[RTM_FAM(RTM_GETMULTICAST)] = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
-	[RTM_FAM(RTM_GETANYCAST)]   = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
-};
-
-static const int rta_max[RTM_NR_FAMILIES] =
-{
-	[RTM_FAM(RTM_NEWLINK)]      = IFLA_MAX,
-	[RTM_FAM(RTM_NEWADDR)]      = IFA_MAX,
-	[RTM_FAM(RTM_NEWROUTE)]     = RTA_MAX,
-	[RTM_FAM(RTM_NEWRULE)]      = FRA_MAX,
-	[RTM_FAM(RTM_NEWQDISC)]     = TCA_MAX,
-	[RTM_FAM(RTM_NEWTCLASS)]    = TCA_MAX,
-	[RTM_FAM(RTM_NEWTFILTER)]   = TCA_MAX,
-	[RTM_FAM(RTM_NEWACTION)]    = TCAA_MAX,
-};
-
 int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group, int echo)
 {
 	struct sock *rtnl = net->rtnl;
@@ -1537,7 +1511,7 @@ errout:
 	return err;
 }
 
-static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -1578,7 +1552,7 @@ errout:
 	return err;
 }
 
-static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
@@ -1709,7 +1683,7 @@ static int rtnl_group_changelink(struct net *net, int group,
 	return 0;
 }
 
-static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	const struct rtnl_link_ops *ops;
@@ -1864,7 +1838,7 @@ out:
 	}
 }
 
-static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -2081,7 +2055,7 @@ int ndo_dflt_fdb_add(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_add);
 
-static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -2179,7 +2153,7 @@ int ndo_dflt_fdb_del(struct ndmsg *ndm,
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_del);
 
-static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ndmsg *ndm;
@@ -2478,8 +2452,7 @@ errout:
 	return err;
 }
 
-static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
-			       void *arg)
+static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -2549,8 +2522,7 @@ out:
 	return err;
 }
 
-static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh,
-			       void *arg)
+static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
@@ -2620,10 +2592,6 @@ out:
 	return err;
 }
 
-/* Protected by RTNL sempahore.  */
-static struct rtattr **rta_buf;
-static int rtattr_max;
-
 /* Process one rtnetlink message. */
 
 static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -2631,7 +2599,6 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net *net = sock_net(skb->sk);
 	rtnl_doit_func doit;
 	int sz_idx, kind;
-	int min_len;
 	int family;
 	int type;
 	int err;
@@ -2679,32 +2646,11 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 	}
 
-	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
-
-	min_len = rtm_min[sz_idx];
-	if (nlh->nlmsg_len < min_len)
-		return -EINVAL;
-
-	if (nlh->nlmsg_len > min_len) {
-		int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
-		struct rtattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
-
-		while (RTA_OK(attr, attrlen)) {
-			unsigned int flavor = attr->rta_type & NLA_TYPE_MASK;
-			if (flavor) {
-				if (flavor > rta_max[sz_idx])
-					return -EINVAL;
-				rta_buf[flavor-1] = attr;
-			}
-			attr = RTA_NEXT(attr, attrlen);
-		}
-	}
-
 	doit = rtnl_get_doit(family, type);
 	if (doit == NULL)
 		return -EOPNOTSUPP;
 
-	return doit(skb, nlh, (void *)&rta_buf[0]);
+	return doit(skb, nlh);
 }
 
 static void rtnetlink_rcv(struct sk_buff *skb)
@@ -2774,16 +2720,6 @@ static struct pernet_operations rtnetlink_net_ops = {
 
 void __init rtnetlink_init(void)
 {
-	int i;
-
-	rtattr_max = 0;
-	for (i = 0; i < ARRAY_SIZE(rta_max); i++)
-		if (rta_max[i] > rtattr_max)
-			rtattr_max = rta_max[i];
-	rta_buf = kmalloc(rtattr_max * sizeof(struct rtattr *), GFP_KERNEL);
-	if (!rta_buf)
-		panic("rtnetlink_init: cannot allocate rta_buf\n");
-
 	if (register_pernet_subsys(&rtnetlink_net_ops))
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 21291f1..40d5829 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1658,7 +1658,7 @@ static const struct reply_func reply_funcs[DCB_CMD_MAX+1] = {
 	[DCB_CMD_CEE_GET]	= { RTM_GETDCB, dcbnl_cee_get },
 };
 
-static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *netdev;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index c8da116..7d91970 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -563,7 +563,7 @@ static const struct nla_policy dn_ifa_policy[IFA_MAX+1] = {
 				    .len = IFNAMSIZ - 1 },
 };
 
-static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_nl_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -607,7 +607,7 @@ errout:
 	return err;
 }
 
-static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_nl_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 42a8048..f093059 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -511,7 +511,7 @@ static inline u32 rtm_get_table(struct nlattr *attrs[], u8 table)
 	return table;
 }
 
-static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
@@ -536,7 +536,7 @@ static int dn_fib_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *
 	return tb->delete(tb, r, attrs, nlh, &NETLINK_CB(skb));
 }
 
-static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int dn_fib_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct dn_fib_table *tb;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index b4b3508..5904429 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1616,7 +1616,7 @@ errout:
 /*
  * This is called by both endnodes and routers now.
  */
-static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
+static int dn_cache_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm = nlmsg_data(nlh);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index af57bba..20a9f92 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -536,7 +536,7 @@ struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 	return NULL;
 }
 
-static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -775,7 +775,7 @@ static struct in_ifaddr *find_matching_ifa(struct in_ifaddr *ifa)
 	return NULL;
 }
 
-static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct in_ifaddr *ifa;
@@ -1730,8 +1730,7 @@ static const struct nla_policy devconf_ipv4_policy[NETCONFA_MAX+1] = {
 };
 
 static int inet_netconf_get_devconf(struct sk_buff *in_skb,
-				    struct nlmsghdr *nlh,
-				    void *arg)
+				    struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX+1];
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index eb4bb12..0e74398 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -604,7 +604,7 @@ errout:
 	return err;
 }
 
-static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
@@ -626,7 +626,7 @@ errout:
 	return err;
 }
 
-static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct fib_config cfg;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6e28514..550781a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2311,7 +2311,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh, void *arg)
+static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct rtmsg *rtm;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fa36a67..15794fd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -544,8 +544,7 @@ static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
 };
 
 static int inet6_netconf_get_devconf(struct sk_buff *in_skb,
-				     struct nlmsghdr *nlh,
-				     void *arg)
+				     struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[NETCONFA_MAX+1];
@@ -3578,7 +3577,7 @@ static const struct nla_policy ifa_ipv6_policy[IFA_MAX+1] = {
 };
 
 static int
-inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
@@ -3644,7 +3643,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 }
 
 static int
-inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
@@ -3983,8 +3982,7 @@ static int inet6_dump_ifacaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	return inet6_dump_addr(skb, cb, type);
 }
 
-static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh,
-			     void *arg)
+static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrmsg *ifm;
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 6f226c8..f083a58 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -414,8 +414,7 @@ static const struct nla_policy ifal_policy[IFAL_MAX+1] = {
 	[IFAL_LABEL]		= { .len = sizeof(u32), },
 };
 
-static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh,
-			     void *arg)
+static int ip6addrlbl_newdel(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrlblmsg *ifal;
@@ -530,8 +529,7 @@ static inline int ip6addrlbl_msgsize(void)
 		+ nla_total_size(4);	/* IFAL_LABEL */
 }
 
-static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh,
-			  void *arg)
+static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr* nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrlblmsg *ifal;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e5fe004..ad0aa6b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2355,7 +2355,7 @@ beginning:
 	return last_err;
 }
 
-static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2370,7 +2370,7 @@ static int inet6_rtm_delroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *a
 		return ip6_route_del(&cfg);
 }
 
-static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_newroute(struct sk_buff *skb, struct nlmsghdr* nlh)
 {
 	struct fib6_config cfg;
 	int err;
@@ -2562,7 +2562,7 @@ int rt6_dump_route(struct rt6_info *rt, void *p_arg)
 		     prefix, 0, NLM_F_MULTI);
 }
 
-static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh, void *arg)
+static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr* nlh)
 {
 	struct net *net = sock_net(in_skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 0193630..dc15f43 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -61,7 +61,7 @@ static const struct nla_policy ifa_phonet_policy[IFA_MAX+1] = {
 	[IFA_LOCAL] = { .type = NLA_U8 },
 };
 
-static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
+static int addr_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[IFA_MAX+1];
@@ -224,7 +224,7 @@ static const struct nla_policy rtm_phonet_policy[RTA_MAX+1] = {
 	[RTA_OIF] = { .type = NLA_U32 },
 };
 
-static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *attr)
+static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[RTA_MAX+1];
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8579c4b..fd70728 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -982,7 +982,7 @@ done:
 	return ret;
 }
 
-static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int tc_ctl_action(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_ACT_MAX + 1];
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 964f5e4..9a04b98 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -118,7 +118,7 @@ static inline u32 tcf_auto_prio(struct tcf_proto *tp)
 
 /* Add/change/delete/get a filter node */
 
-static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tca[TCA_MAX + 1];
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c297e2a..0bbce22 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -971,7 +971,7 @@ check_loop_fn(struct Qdisc *q, unsigned long cl, struct qdisc_walker *w)
  * Delete/get qdisc.
  */
 
-static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = nlmsg_data(n);
@@ -1038,7 +1038,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
  * Create/change qdisc.
  */
 
-static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm;
@@ -1372,7 +1372,7 @@ done:
 
 
 
-static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n)
 {
 	struct net *net = sock_net(skb->sk);
 	struct tcmsg *tcm = nlmsg_data(n);
-- 
1.7.11.7
