From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC V2 PATCH] rtnetlink: Add method to calculate dump info data size
Date: Mon, 09 May 2011 15:26:29 -0700
Message-ID: <20110509222629.8689.77365.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47317 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab1EIW0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 18:26:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The message size allocated for rtnl info dumps was limited to a single
page.  This is not enough for additional interface info available with
devices that support SR-IOV.  Calculate the amount of data required so
the dump can allocate enough data to satisfy the request.

V2 of this patch adds a new argument to the rtnl_register service that
allows for a new method to calculate the amount of data required to
complete the info dump request.  So far the method is only implemented
for the RTM_GETLINK slot.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 include/linux/netlink.h              |    6 ++-
 include/net/rtnetlink.h              |    5 +-
 net/bridge/br_netlink.c              |   15 ++++---
 net/core/fib_rules.c                 |    6 +--
 net/core/neighbour.c                 |   10 ++--
 net/core/rtnetlink.c                 |   76 ++++++++++++++++++++++++++++++----
 net/dcb/dcbnl.c                      |    4 +-
 net/decnet/dn_dev.c                  |    6 +--
 net/decnet/dn_fib.c                  |    4 +-
 net/decnet/dn_route.c                |    5 +-
 net/ipv4/devinet.c                   |    6 +--
 net/ipv4/fib_frontend.c              |    6 +--
 net/ipv4/inet_diag.c                 |    2 -
 net/ipv4/ipmr.c                      |    3 +
 net/ipv4/route.c                     |    2 -
 net/ipv6/addrconf.c                  |   12 +++--
 net/ipv6/addrlabel.c                 |    6 +--
 net/ipv6/ip6_fib.c                   |    2 -
 net/ipv6/ip6mr.c                     |    2 -
 net/ipv6/route.c                     |    6 +--
 net/netfilter/ipset/ip_set_core.c    |    2 -
 net/netfilter/nf_conntrack_netlink.c |    4 +-
 net/netlink/af_netlink.c             |   17 +++++---
 net/netlink/genetlink.c              |    2 -
 net/phonet/pn_netlink.c              |   12 +++--
 net/sched/act_api.c                  |    6 +--
 net/sched/cls_api.c                  |    6 +--
 net/sched/sch_api.c                  |   12 +++--
 net/xfrm/xfrm_user.c                 |    2 -
 29 files changed, 159 insertions(+), 88 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 4c4ac3f..8b8dfb8 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -220,7 +220,8 @@ struct netlink_callback {
 	int			(*dump)(struct sk_buff * skb,
 					struct netlink_callback *cb);
 	int			(*done)(struct netlink_callback *cb);
-	int			family;
+	u16			family;
+	u16			min_dump_alloc;
 	long			args[6];
 };
 
@@ -258,7 +259,8 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 extern int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 			      const struct nlmsghdr *nlh,
 			      int (*dump)(struct sk_buff *skb, struct netlink_callback*),
-			      int (*done)(struct netlink_callback*));
+			      int (*done)(struct netlink_callback*),
+			      u16 min_dump_alloc);
 
 
 #define NL_NONROOT_RECV 0x1
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 4093ca7..d1ac642 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -6,11 +6,12 @@
 
 typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *, void *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
+typedef u16 (*rtnl_calcit_func)(struct sk_buff *);
 
 extern int	__rtnl_register(int protocol, int msgtype,
-				rtnl_doit_func, rtnl_dumpit_func);
+				rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
 extern void	rtnl_register(int protocol, int msgtype,
-			      rtnl_doit_func, rtnl_dumpit_func);
+			      rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
 extern int	rtnl_unregister(int protocol, int msgtype);
 extern void	rtnl_unregister_all(int protocol);
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index ffb0dc4..6814083 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -218,19 +218,24 @@ int __init br_netlink_init(void)
 	if (err < 0)
 		goto err1;
 
-	err = __rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, br_dump_ifinfo);
+	err = __rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL,
+			      br_dump_ifinfo, NULL);
 	if (err)
 		goto err2;
-	err = __rtnl_register(PF_BRIDGE, RTM_SETLINK, br_rtm_setlink, NULL);
+	err = __rtnl_register(PF_BRIDGE, RTM_SETLINK,
+			      br_rtm_setlink, NULL, NULL);
 	if (err)
 		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, br_fdb_add, NULL);
+	err = __rtnl_register(PF_BRIDGE, RTM_NEWNEIGH,
+			      br_fdb_add, NULL, NULL);
 	if (err)
 		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_DELNEIGH, br_fdb_delete, NULL);
+	err = __rtnl_register(PF_BRIDGE, RTM_DELNEIGH,
+			      br_fdb_delete, NULL, NULL);
 	if (err)
 		goto err3;
-	err = __rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, br_fdb_dump);
+	err = __rtnl_register(PF_BRIDGE, RTM_GETNEIGH,
+			      NULL, br_fdb_dump, NULL);
 	if (err)
 		goto err3;
 
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 3911586..56e6fc8 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -739,9 +739,9 @@ static struct pernet_operations fib_rules_net_ops = {
 static int __init fib_rules_init(void)
 {
 	int err;
-	rtnl_register(PF_UNSPEC, RTM_NEWRULE, fib_nl_newrule, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule);
+	rtnl_register(PF_UNSPEC, RTM_NEWRULE, fib_nl_newrule, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule, NULL);
 
 	err = register_pernet_subsys(&fib_rules_net_ops);
 	if (err < 0)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 799f06e..a880b83 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2909,12 +2909,12 @@ EXPORT_SYMBOL(neigh_sysctl_unregister);
 
 static int __init neigh_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWNEIGH, neigh_add, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELNEIGH, neigh_delete, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETNEIGH, NULL, neigh_dump_info);
+	rtnl_register(PF_UNSPEC, RTM_NEWNEIGH, neigh_add, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELNEIGH, neigh_delete, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNEIGH, NULL, neigh_dump_info, NULL);
 
-	rtnl_register(PF_UNSPEC, RTM_GETNEIGHTBL, NULL, neightbl_dump_info);
-	rtnl_register(PF_UNSPEC, RTM_SETNEIGHTBL, neightbl_set, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETNEIGHTBL, NULL, neightbl_dump_info, NULL);
+	rtnl_register(PF_UNSPEC, RTM_SETNEIGHTBL, neightbl_set, NULL, NULL);
 
 	return 0;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2963312..77b7f4a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -56,6 +56,7 @@
 struct rtnl_link {
 	rtnl_doit_func		doit;
 	rtnl_dumpit_func	dumpit;
+	rtnl_calcit_func calcit;
 };
 
 static DEFINE_MUTEX(rtnl_mutex);
@@ -144,12 +145,28 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
 	return tab ? tab[msgindex].dumpit : NULL;
 }
 
+static rtnl_calcit_func rtnl_get_calcit(int protocol, int msgindex)
+{
+	struct rtnl_link *tab;
+
+	if (protocol <= RTNL_FAMILY_MAX)
+		tab = rtnl_msg_handlers[protocol];
+	else
+		tab = NULL;
+
+	if (tab == NULL || tab[msgindex].calcit == NULL)
+		tab = rtnl_msg_handlers[PF_UNSPEC];
+
+	return tab ? tab[msgindex].calcit : NULL;
+}
+
 /**
  * __rtnl_register - Register a rtnetlink message type
  * @protocol: Protocol family or PF_UNSPEC
  * @msgtype: rtnetlink message type
  * @doit: Function pointer called for each request message
  * @dumpit: Function pointer called for each dump request (NLM_F_DUMP) message
+ * @calcit: Function pointer to calc size of dump message
  *
  * Registers the specified function pointers (at least one of them has
  * to be non-NULL) to be called whenever a request message for the
@@ -162,7 +179,8 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
  * Returns 0 on success or a negative error code.
  */
 int __rtnl_register(int protocol, int msgtype,
-		    rtnl_doit_func doit, rtnl_dumpit_func dumpit)
+		    rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+		    rtnl_calcit_func calcit)
 {
 	struct rtnl_link *tab;
 	int msgindex;
@@ -185,6 +203,9 @@ int __rtnl_register(int protocol, int msgtype,
 	if (dumpit)
 		tab[msgindex].dumpit = dumpit;
 
+	if (calcit)
+		tab[msgindex].calcit = calcit;
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__rtnl_register);
@@ -199,9 +220,10 @@ EXPORT_SYMBOL_GPL(__rtnl_register);
  * of memory implies no sense in continuing.
  */
 void rtnl_register(int protocol, int msgtype,
-		   rtnl_doit_func doit, rtnl_dumpit_func dumpit)
+		   rtnl_doit_func doit, rtnl_dumpit_func dumpit,
+		   rtnl_calcit_func calcit)
 {
-	if (__rtnl_register(protocol, msgtype, doit, dumpit) < 0)
+	if (__rtnl_register(protocol, msgtype, doit, dumpit, calcit) < 0)
 		panic("Unable to register rtnetlink message handler, "
 		      "protocol = %d, message type = %d\n",
 		      protocol, msgtype);
@@ -1819,6 +1841,32 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	return err;
 }
 
+static u16 rtnl_calcit(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	int h;
+	int idx = 0, s_idx;
+	struct net_device *dev;
+	struct hlist_head *head;
+	struct hlist_node *node;
+	u16 alloc_size = 0;
+
+	for (h = 0; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, node, head, index_hlist) {
+			if (idx < s_idx) {
+				idx++;
+				continue;
+			}
+			alloc_size = (u16)if_nlmsg_size(dev);
+			break;
+		}
+	}
+
+	return alloc_size;
+}
+
 static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
@@ -1902,13 +1950,21 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		struct sock *rtnl;
 		rtnl_dumpit_func dumpit;
+		rtnl_calcit_func calcit;
+		u16 min_dump_alloc = 0;
 
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
+		calcit = rtnl_get_calcit(family, type);
+		if (calcit) {
+			min_dump_alloc = calcit(skb);
+			printk("Minimum Dump Alloc Size = %d\n", min_dump_alloc);
+		}
 
 		rtnl = net->rtnl;
-		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		return netlink_dump_start(rtnl, skb, nlh, dumpit,
+					  NULL, min_dump_alloc);
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
@@ -2014,12 +2070,12 @@ void __init rtnetlink_init(void)
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 
-	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo);
-	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL);
-	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink, rtnl_dump_ifinfo, rtnl_calcit);
+	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL);
 
-	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all);
-	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all);
+	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
 }
 
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 3609eac..ed1bb8c 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1819,8 +1819,8 @@ static int __init dcbnl_init(void)
 {
 	INIT_LIST_HEAD(&dcb_app_list);
 
-	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL);
-	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL, NULL);
 
 	return 0;
 }
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 404fa15..0011eba 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1419,9 +1419,9 @@ void __init dn_dev_init(void)
 
 	dn_dev_devices_on();
 
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
 
 	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 1c74ed3..104324d 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -763,8 +763,8 @@ void __init dn_fib_init(void)
 
 	register_dnaddr_notifier(&dn_fib_dnaddr_notifier);
 
-	rtnl_register(PF_DECnet, RTM_NEWROUTE, dn_fib_rtm_newroute, NULL);
-	rtnl_register(PF_DECnet, RTM_DELROUTE, dn_fib_rtm_delroute, NULL);
+	rtnl_register(PF_DECnet, RTM_NEWROUTE, dn_fib_rtm_newroute, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_DELROUTE, dn_fib_rtm_delroute, NULL, NULL);
 }
 
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 74544bc..2949ca4 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1841,10 +1841,11 @@ void __init dn_route_init(void)
 	proc_net_fops_create(&init_net, "decnet_cache", S_IRUGO, &dn_rt_cache_seq_fops);
 
 #ifdef CONFIG_DECNET_ROUTER
-	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute, dn_fib_dump);
+	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
+		      dn_fib_dump, NULL);
 #else
 	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
-		      dn_cache_dump);
+		      dn_cache_dump, NULL);
 #endif
 }
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5345b0b..fee7550 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1833,8 +1833,8 @@ void __init devinet_init(void)
 
 	rtnl_af_register(&inet_af_ops);
 
-	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL);
-	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL);
-	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr);
+	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL, NULL);
+	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL, NULL);
+	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, NULL);
 }
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2252471..92fc5f6 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1124,9 +1124,9 @@ static struct pernet_operations fib_net_ops = {
 
 void __init ip_fib_init(void)
 {
-	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL);
-	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL);
-	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib);
+	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
+	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
+	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
 
 	register_pernet_subsys(&fib_net_ops);
 	register_netdevice_notifier(&fib_netdev_notifier);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 6ffe94c..5ff4765 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -871,7 +871,7 @@ static int inet_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 
 		return netlink_dump_start(idiagnl, skb, nlh,
-					  inet_diag_dump, NULL);
+					  inet_diag_dump, NULL, 0);
 	}
 
 	return inet_diag_get_exact(skb, nlh);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 30a7763..aae2bd8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2544,7 +2544,8 @@ int __init ip_mr_init(void)
 		goto add_proto_fail;
 	}
 #endif
-	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETROUTE, NULL, ipmr_rtm_dumproute);
+	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETROUTE,
+		      NULL, ipmr_rtm_dumproute, NULL);
 	return 0;
 
 #ifdef CONFIG_IP_PIMSM_V2
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6a83840..eec0caa 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3312,7 +3312,7 @@ int __init ip_rt_init(void)
 	xfrm_init();
 	xfrm4_init(ip_rt_max_size);
 #endif
-	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL);
+	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, NULL);
 
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&sysctl_route_ops);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c663a3b..3629ae7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4704,16 +4704,16 @@ int __init addrconf_init(void)
 	if (err < 0)
 		goto errout_af;
 
-	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo);
+	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo, NULL);
 	if (err < 0)
 		goto errout;
 
 	/* Only the first call to __rtnl_register can fail */
-	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL);
-	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL);
-	__rtnl_register(PF_INET6, RTM_GETADDR, inet6_rtm_getaddr, inet6_dump_ifaddr);
-	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL, inet6_dump_ifmcaddr);
-	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL, inet6_dump_ifacaddr);
+	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL, NULL);
+	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL, NULL);
+	__rtnl_register(PF_INET6, RTM_GETADDR, inet6_rtm_getaddr, inet6_dump_ifaddr, NULL);
+	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL, inet6_dump_ifmcaddr, NULL);
+	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL, inet6_dump_ifacaddr, NULL);
 
 	ipv6_addr_label_rtnl_register();
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index c8993e5..f3aa749 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -592,8 +592,8 @@ out:
 
 void __init ipv6_addr_label_rtnl_register(void)
 {
-	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel, NULL);
-	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel, NULL);
-	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get, ip6addrlbl_dump);
+	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel, NULL, NULL);
+	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel, NULL, NULL);
+	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get, ip6addrlbl_dump, NULL);
 }
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 4076a0b..9b257da 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1586,7 +1586,7 @@ int __init fib6_init(void)
 	if (ret)
 		goto out_kmem_cache_create;
 
-	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
+	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib, NULL);
 	if (ret)
 		goto out_unregister_subsys;
 out:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 82a8099..1edfcc9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1354,7 +1354,7 @@ int __init ip6_mr_init(void)
 		goto add_proto_fail;
 	}
 #endif
-	rtnl_register(RTNL_FAMILY_IP6MR, RTM_GETROUTE, NULL, ip6mr_rtm_dumproute);
+	rtnl_register(RTNL_FAMILY_IP6MR, RTM_GETROUTE, NULL, ip6mr_rtm_dumproute, NULL);
 	return 0;
 #ifdef CONFIG_IPV6_PIMSM_V2
 add_proto_fail:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f1be5c5..1c49165 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2924,9 +2924,9 @@ int __init ip6_route_init(void)
 		goto xfrm6_init;
 
 	ret = -ENOBUFS;
-	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL) ||
-	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL) ||
-	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL))
+	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, NULL) ||
+	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, NULL) ||
+	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, NULL))
 		goto fib6_rules_init;
 
 	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 72d1ac6..dc1528c 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1120,7 +1120,7 @@ ip_set_dump(struct sock *ctnl, struct sk_buff *skb,
 
 	return netlink_dump_start(ctnl, skb, nlh,
 				  ip_set_dump_start,
-				  ip_set_dump_done);
+				  ip_set_dump_done, 0);
 }
 
 /* Add, del and test */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 30bf8a1..e3e8d4c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -970,7 +970,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP)
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
-					  ctnetlink_done);
+					  ctnetlink_done, 0);
 
 	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
 	if (err < 0)
@@ -1836,7 +1836,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		return netlink_dump_start(ctnl, skb, nlh,
 					  ctnetlink_exp_dump_table,
-					  ctnetlink_exp_done);
+					  ctnetlink_exp_done, 0);
 	}
 
 	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c8f35b5..063bee9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1665,13 +1665,10 @@ static int netlink_dump(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	struct netlink_callback *cb;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct nlmsghdr *nlh;
 	int len, err = -ENOBUFS;
-
-	skb = sock_rmalloc(sk, NLMSG_GOODSIZE, 0, GFP_KERNEL);
-	if (!skb)
-		goto errout;
+	int alloc_size;
 
 	mutex_lock(nlk->cb_mutex);
 
@@ -1681,6 +1678,12 @@ static int netlink_dump(struct sock *sk)
 		goto errout_skb;
 	}
 
+	alloc_size = max_t(int, cb->min_dump_alloc, NLMSG_GOODSIZE);
+
+	skb = sock_rmalloc(sk, alloc_size, 0, GFP_KERNEL);
+	if (!skb)
+		goto errout;
+
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
@@ -1727,7 +1730,8 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 		       const struct nlmsghdr *nlh,
 		       int (*dump)(struct sk_buff *skb,
 				   struct netlink_callback *),
-		       int (*done)(struct netlink_callback *))
+		       int (*done)(struct netlink_callback *),
+		       u16 min_dump_alloc)
 {
 	struct netlink_callback *cb;
 	struct sock *sk;
@@ -1741,6 +1745,7 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	cb->dump = dump;
 	cb->done = done;
 	cb->nlh = nlh;
+	cb->min_dump_alloc = min_dump_alloc;
 	atomic_inc(&skb->users);
 	cb->skb = skb;
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 1781d99..482fa57 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -525,7 +525,7 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 		genl_unlock();
 		err = netlink_dump_start(net->genl_sock, skb, nlh,
-					 ops->dumpit, ops->done);
+					 ops->dumpit, ops->done, 0);
 		genl_lock();
 		return err;
 	}
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 438accb..4ad4bb9 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -289,15 +289,15 @@ out:
 
 int __init phonet_netlink_register(void)
 {
-	int err = __rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL);
+	int err = __rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit, NULL, NULL);
 	if (err)
 		return err;
 
 	/* Further __rtnl_register() cannot fail */
-	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL);
-	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit);
-	__rtnl_register(PF_PHONET, RTM_NEWROUTE, route_doit, NULL);
-	__rtnl_register(PF_PHONET, RTM_DELROUTE, route_doit, NULL);
-	__rtnl_register(PF_PHONET, RTM_GETROUTE, NULL, route_dumpit);
+	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL, NULL);
+	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit, NULL);
+	__rtnl_register(PF_PHONET, RTM_NEWROUTE, route_doit, NULL, NULL);
+	__rtnl_register(PF_PHONET, RTM_DELROUTE, route_doit, NULL, NULL);
+	__rtnl_register(PF_PHONET, RTM_GETROUTE, NULL, route_dumpit, NULL);
 	return 0;
 }
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 14b42f4..c857763 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1120,9 +1120,9 @@ nlmsg_failure:
 
 static int __init tc_action_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETACTION, tc_ctl_action, tc_dump_action);
+	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETACTION, tc_ctl_action, tc_dump_action, NULL);
 
 	return 0;
 }
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index bb2c523..9563887 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -610,10 +610,10 @@ EXPORT_SYMBOL(tcf_exts_dump_stats);
 
 static int __init tc_filter_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
-						 tc_dump_tfilter);
+		      tc_dump_tfilter, NULL);
 
 	return 0;
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7490f3f..7870a92 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1794,12 +1794,12 @@ static int __init pktsched_init(void)
 	register_qdisc(&pfifo_head_drop_qdisc_ops);
 	register_qdisc(&mq_qdisc_ops);
 
-	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc);
-	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass);
+	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass, NULL);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 5d1d60d..d31e914 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2296,7 +2296,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (link->dump == NULL)
 			return -EINVAL;
 
-		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done);
+		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done, 0);
 	}
 
 	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,

