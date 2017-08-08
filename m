From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/7] rtnetlink: make rtnl_register accept a flags parameter
Date: Tue,  8 Aug 2017 18:02:31 +0200
Message-ID: <20170808160236.28562-3-fw@strlen.de>
References: <20170808160236.28562-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35528 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752728AbdHHQCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:02:25 -0400
In-Reply-To: <20170808160236.28562-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows us to later indicate to rtnetlink core that certain
doit functions should be called without acquiring rtnl_mutex.

This change should have no effect, we simply replace the last (now
unused) calcit argument with the new flag.

Signed-off-by: Florian Westphal <fw@strlen.de>
Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/rtnetlink.h  |  5 ++---
 net/bridge/br_mdb.c      |  6 +++---
 net/can/gw.c             |  6 +++---
 net/core/fib_rules.c     |  6 +++---
 net/core/neighbour.c     | 10 +++++-----
 net/core/net_namespace.c |  4 ++--
 net/core/rtnetlink.c     | 36 ++++++++++++++++++------------------
 net/dcb/dcbnl.c          |  4 ++--
 net/decnet/dn_dev.c      |  6 +++---
 net/decnet/dn_fib.c      |  4 ++--
 net/decnet/dn_route.c    |  4 ++--
 net/ipv4/devinet.c       |  8 ++++----
 net/ipv4/fib_frontend.c  |  6 +++---
 net/ipv4/ipmr.c          |  8 ++++----
 net/ipv4/route.c         |  2 +-
 net/ipv6/addrconf.c      | 14 +++++++-------
 net/ipv6/addrlabel.c     |  6 +++---
 net/ipv6/ip6_fib.c       |  2 +-
 net/ipv6/ip6mr.c         |  2 +-
 net/ipv6/route.c         |  6 +++---
 net/mpls/af_mpls.c       |  8 ++++----
 net/phonet/pn_netlink.c  | 12 ++++++------
 net/qrtr/qrtr.c          |  2 +-
 net/sched/act_api.c      |  6 +++---
 net/sched/cls_api.c      |  6 +++---
 net/sched/sch_api.c      | 12 ++++++------
 26 files changed, 95 insertions(+), 96 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index abe6b733d473..ac32460a0adb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -7,12 +7,11 @@
 typedef int (*rtnl_doit_func)(struct sk_buff *, struct nlmsghdr *,
 			      struct netlink_ext_ack *);
 typedef int (*rtnl_dumpit_func)(struct sk_buff *, struct netlink_callback *);
-typedef u16 (*rtnl_calcit_func)(struct sk_buff *, struct nlmsghdr *);
 
 int __rtnl_register(int protocol, int msgtype,
-		    rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
+		    rtnl_doit_func, rtnl_dumpit_func, unsigned int flags);
 void rtnl_register(int protocol, int msgtype,
-		   rtnl_doit_func, rtnl_dumpit_func, rtnl_calcit_func);
+		   rtnl_doit_func, rtnl_dumpit_func, unsigned int flags);
 int rtnl_unregister(int protocol, int msgtype);
 void rtnl_unregister_all(int protocol);
 
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index a0b11e7d67d9..ca01def49af0 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -713,9 +713,9 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 void br_mdb_init(void)
 {
-	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, NULL);
-	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_add, NULL, NULL);
-	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_del, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_GETMDB, NULL, br_mdb_dump, 0);
+	rtnl_register(PF_BRIDGE, RTM_NEWMDB, br_mdb_add, NULL, 0);
+	rtnl_register(PF_BRIDGE, RTM_DELMDB, br_mdb_del, NULL, 0);
 }
 
 void br_mdb_uninit(void)
diff --git a/net/can/gw.c b/net/can/gw.c
index 29748d844c3f..73a02af4b5d7 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -1031,15 +1031,15 @@ static __init int cgw_module_init(void)
 	notifier.notifier_call = cgw_notifier;
 	register_netdevice_notifier(&notifier);
 
-	if (__rtnl_register(PF_CAN, RTM_GETROUTE, NULL, cgw_dump_jobs, NULL)) {
+	if (__rtnl_register(PF_CAN, RTM_GETROUTE, NULL, cgw_dump_jobs, 0)) {
 		unregister_netdevice_notifier(&notifier);
 		kmem_cache_destroy(cgw_cache);
 		return -ENOBUFS;
 	}
 
 	/* Only the first call to __rtnl_register can fail */
-	__rtnl_register(PF_CAN, RTM_NEWROUTE, cgw_create_job, NULL, NULL);
-	__rtnl_register(PF_CAN, RTM_DELROUTE, cgw_remove_job, NULL, NULL);
+	__rtnl_register(PF_CAN, RTM_NEWROUTE, cgw_create_job, NULL, 0);
+	__rtnl_register(PF_CAN, RTM_DELROUTE, cgw_remove_job, NULL, 0);
 
 	return 0;
 }
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index fc0b65093417..9a6d97c1d810 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -1026,9 +1026,9 @@ static struct pernet_operations fib_rules_net_ops = {
 static int __init fib_rules_init(void)
 {
 	int err;
-	rtnl_register(PF_UNSPEC, RTM_NEWRULE, fib_nl_newrule, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWRULE, fib_nl_newrule, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELRULE, fib_nl_delrule, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_GETRULE, NULL, fib_nl_dumprule, 0);
 
 	err = register_pernet_subsys(&fib_rules_net_ops);
 	if (err < 0)
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d0713627deb6..16a1a4c4eb57 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -3261,13 +3261,13 @@ EXPORT_SYMBOL(neigh_sysctl_unregister);
 
 static int __init neigh_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWNEIGH, neigh_add, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELNEIGH, neigh_delete, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETNEIGH, NULL, neigh_dump_info, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWNEIGH, neigh_add, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELNEIGH, neigh_delete, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_GETNEIGH, NULL, neigh_dump_info, 0);
 
 	rtnl_register(PF_UNSPEC, RTM_GETNEIGHTBL, NULL, neightbl_dump_info,
-		      NULL);
-	rtnl_register(PF_UNSPEC, RTM_SETNEIGHTBL, neightbl_set, NULL, NULL);
+		      0);
+	rtnl_register(PF_UNSPEC, RTM_SETNEIGHTBL, neightbl_set, NULL, 0);
 
 	return 0;
 }
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 8726d051f31d..a7f06d706aa0 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -855,9 +855,9 @@ static int __init net_ns_init(void)
 
 	register_pernet_subsys(&net_ns_ops);
 
-	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
-		      NULL);
+		      0);
 
 	return 0;
 }
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8c9d34deea7d..67607c540c03 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -178,7 +178,7 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
  * @msgtype: rtnetlink message type
  * @doit: Function pointer called for each request message
  * @dumpit: Function pointer called for each dump request (NLM_F_DUMP) message
- * @calcit: Function pointer to calc size of dump message
+ * @flags: rtnl_link_flags to modifiy behaviour of doit/dumpit functions
  *
  * Registers the specified function pointers (at least one of them has
  * to be non-NULL) to be called whenever a request message for the
@@ -192,7 +192,7 @@ static rtnl_dumpit_func rtnl_get_dumpit(int protocol, int msgindex)
  */
 int __rtnl_register(int protocol, int msgtype,
 		    rtnl_doit_func doit, rtnl_dumpit_func dumpit,
-		    rtnl_calcit_func calcit)
+		    unsigned int flags)
 {
 	struct rtnl_link *tab;
 	int msgindex;
@@ -230,9 +230,9 @@ EXPORT_SYMBOL_GPL(__rtnl_register);
  */
 void rtnl_register(int protocol, int msgtype,
 		   rtnl_doit_func doit, rtnl_dumpit_func dumpit,
-		   rtnl_calcit_func calcit)
+		   unsigned int flags)
 {
-	if (__rtnl_register(protocol, msgtype, doit, dumpit, calcit) < 0)
+	if (__rtnl_register(protocol, msgtype, doit, dumpit, flags) < 0)
 		panic("Unable to register rtnetlink message handler, "
 		      "protocol = %d, message type = %d\n",
 		      protocol, msgtype);
@@ -4279,23 +4279,23 @@ void __init rtnetlink_init(void)
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink,
-		      rtnl_dump_ifinfo, NULL);
-	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL);
+		      rtnl_dump_ifinfo, 0);
+	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, 0);
 
-	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
-	rtnl_register(PF_UNSPEC, RTM_GETNETCONF, NULL, rtnl_dump_all, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, 0);
+	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, 0);
+	rtnl_register(PF_UNSPEC, RTM_GETNETCONF, NULL, rtnl_dump_all, 0);
 
-	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
-	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
-	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, NULL);
+	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, 0);
+	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, 0);
+	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, 0);
 
-	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
-	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
-	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
+	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, 0);
+	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, 0);
+	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, 0);
 
 	rtnl_register(PF_UNSPEC, RTM_GETSTATS, rtnl_stats_get, rtnl_stats_dump,
-		      NULL);
+		      0);
 }
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 733f523707ac..bae7d78aa068 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1938,8 +1938,8 @@ static int __init dcbnl_init(void)
 {
 	INIT_LIST_HEAD(&dcb_app_list);
 
-	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETDCB, dcb_doit, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_SETDCB, dcb_doit, NULL, 0);
 
 	return 0;
 }
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index fa0110b57ca1..4d339de56862 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1419,9 +1419,9 @@ void __init dn_dev_init(void)
 
 	dn_dev_devices_on();
 
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, 0);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, 0);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, 0);
 
 	proc_create("decnet_dev", S_IRUGO, init_net.proc_net, &dn_dev_seq_fops);
 
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index f9f6fb3f3c5b..3d37464c8b4a 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -791,8 +791,8 @@ void __init dn_fib_init(void)
 
 	register_dnaddr_notifier(&dn_fib_dnaddr_notifier);
 
-	rtnl_register(PF_DECnet, RTM_NEWROUTE, dn_fib_rtm_newroute, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_DELROUTE, dn_fib_rtm_delroute, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_NEWROUTE, dn_fib_rtm_newroute, NULL, 0);
+	rtnl_register(PF_DECnet, RTM_DELROUTE, dn_fib_rtm_delroute, NULL, 0);
 }
 
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index bcbe548f8854..0bd3afd01dd2 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1922,10 +1922,10 @@ void __init dn_route_init(void)
 
 #ifdef CONFIG_DECNET_ROUTER
 	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
-		      dn_fib_dump, NULL);
+		      dn_fib_dump, 0);
 #else
 	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
-		      dn_cache_dump, NULL);
+		      dn_cache_dump, 0);
 #endif
 }
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 38d9af9b917c..d7adc0616599 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2491,9 +2491,9 @@ void __init devinet_init(void)
 
 	rtnl_af_register(&inet_af_ops);
 
-	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL, NULL);
-	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL, NULL);
-	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, NULL);
+	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL, 0);
+	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL, 0);
+	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr, 0);
 	rtnl_register(PF_INET, RTM_GETNETCONF, inet_netconf_get_devconf,
-		      inet_netconf_dump_devconf, NULL);
+		      inet_netconf_dump_devconf, 0);
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 2cba559f14df..37819ab4cc74 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1348,7 +1348,7 @@ void __init ip_fib_init(void)
 	register_netdevice_notifier(&fib_netdev_notifier);
 	register_inetaddr_notifier(&fib_inetaddr_notifier);
 
-	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, NULL);
-	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, NULL);
-	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, NULL);
+	rtnl_register(PF_INET, RTM_NEWROUTE, inet_rtm_newroute, NULL, 0);
+	rtnl_register(PF_INET, RTM_DELROUTE, inet_rtm_delroute, NULL, 0);
+	rtnl_register(PF_INET, RTM_GETROUTE, NULL, inet_dump_fib, 0);
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 06863ea3fc5b..c9b3e6e069ae 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -3114,14 +3114,14 @@ int __init ip_mr_init(void)
 	}
 #endif
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETROUTE,
-		      ipmr_rtm_getroute, ipmr_rtm_dumproute, NULL);
+		      ipmr_rtm_getroute, ipmr_rtm_dumproute, 0);
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_NEWROUTE,
-		      ipmr_rtm_route, NULL, NULL);
+		      ipmr_rtm_route, NULL, 0);
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_DELROUTE,
-		      ipmr_rtm_route, NULL, NULL);
+		      ipmr_rtm_route, NULL, 0);
 
 	rtnl_register(RTNL_FAMILY_IPMR, RTM_GETLINK,
-		      NULL, ipmr_rtm_dumplink, NULL);
+		      NULL, ipmr_rtm_dumplink, 0);
 	return 0;
 
 #ifdef CONFIG_IP_PIMSM_V2
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0383e66f59bc..2ef46294475f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3067,7 +3067,7 @@ int __init ip_rt_init(void)
 	xfrm_init();
 	xfrm4_init();
 #endif
-	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, NULL);
+	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, 0);
 
 #ifdef CONFIG_SYSCTL
 	register_pernet_subsys(&sysctl_route_ops);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 30ee23eef268..640792e1ecb7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -6605,21 +6605,21 @@ int __init addrconf_init(void)
 	rtnl_af_register(&inet6_ops);
 
 	err = __rtnl_register(PF_INET6, RTM_GETLINK, NULL, inet6_dump_ifinfo,
-			      NULL);
+			      0);
 	if (err < 0)
 		goto errout;
 
 	/* Only the first call to __rtnl_register can fail */
-	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL, NULL);
-	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL, NULL);
+	__rtnl_register(PF_INET6, RTM_NEWADDR, inet6_rtm_newaddr, NULL, 0);
+	__rtnl_register(PF_INET6, RTM_DELADDR, inet6_rtm_deladdr, NULL, 0);
 	__rtnl_register(PF_INET6, RTM_GETADDR, inet6_rtm_getaddr,
-			inet6_dump_ifaddr, NULL);
+			inet6_dump_ifaddr, 0);
 	__rtnl_register(PF_INET6, RTM_GETMULTICAST, NULL,
-			inet6_dump_ifmcaddr, NULL);
+			inet6_dump_ifmcaddr, 0);
 	__rtnl_register(PF_INET6, RTM_GETANYCAST, NULL,
-			inet6_dump_ifacaddr, NULL);
+			inet6_dump_ifacaddr, 0);
 	__rtnl_register(PF_INET6, RTM_GETNETCONF, inet6_netconf_get_devconf,
-			inet6_netconf_dump_devconf, NULL);
+			inet6_netconf_dump_devconf, 0);
 
 	ipv6_addr_label_rtnl_register();
 
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 7a428f65c7ec..cea5eb488013 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -593,10 +593,10 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 void __init ipv6_addr_label_rtnl_register(void)
 {
 	__rtnl_register(PF_INET6, RTM_NEWADDRLABEL, ip6addrlbl_newdel,
-			NULL, NULL);
+			NULL, 0);
 	__rtnl_register(PF_INET6, RTM_DELADDRLABEL, ip6addrlbl_newdel,
-			NULL, NULL);
+			NULL, 0);
 	__rtnl_register(PF_INET6, RTM_GETADDRLABEL, ip6addrlbl_get,
-			ip6addrlbl_dump, NULL);
+			ip6addrlbl_dump, 0);
 }
 
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 69ed0043d117..8c58c7558de0 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -2038,7 +2038,7 @@ int __init fib6_init(void)
 		goto out_kmem_cache_create;
 
 	ret = __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib,
-			      NULL);
+			      0);
 	if (ret)
 		goto out_unregister_subsys;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7454850f2098..f5500f5444e9 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1427,7 +1427,7 @@ int __init ip6_mr_init(void)
 	}
 #endif
 	rtnl_register(RTNL_FAMILY_IP6MR, RTM_GETROUTE, NULL,
-		      ip6mr_rtm_dumproute, NULL);
+		      ip6mr_rtm_dumproute, 0);
 	return 0;
 #ifdef CONFIG_IPV6_PIMSM_V2
 add_proto_fail:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index aba07fce67fb..317872aefce8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -4109,9 +4109,9 @@ int __init ip6_route_init(void)
 		goto fib6_rules_init;
 
 	ret = -ENOBUFS;
-	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, NULL) ||
-	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, NULL) ||
-	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, NULL))
+	if (__rtnl_register(PF_INET6, RTM_NEWROUTE, inet6_rtm_newroute, NULL, 0) ||
+	    __rtnl_register(PF_INET6, RTM_DELROUTE, inet6_rtm_delroute, NULL, 0) ||
+	    __rtnl_register(PF_INET6, RTM_GETROUTE, inet6_rtm_getroute, NULL, 0))
 		goto out_register_late_subsys;
 
 	ret = register_netdevice_notifier(&ip6_route_dev_notifier);
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index ea4f481839dd..c5b9ce41d66f 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -2479,12 +2479,12 @@ static int __init mpls_init(void)
 
 	rtnl_af_register(&mpls_af_ops);
 
-	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
-	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
+	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, 0);
+	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, 0);
 	rtnl_register(PF_MPLS, RTM_GETROUTE, mpls_getroute, mpls_dump_routes,
-		      NULL);
+		      0);
 	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
-		      mpls_netconf_dump_devconf, NULL);
+		      mpls_netconf_dump_devconf, 0);
 	err = 0;
 out:
 	return err;
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 45b3af3080d8..da754fc926e7 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -300,15 +300,15 @@ static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 int __init phonet_netlink_register(void)
 {
 	int err = __rtnl_register(PF_PHONET, RTM_NEWADDR, addr_doit,
-				  NULL, NULL);
+				  NULL, 0);
 	if (err)
 		return err;
 
 	/* Further __rtnl_register() cannot fail */
-	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL, NULL);
-	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit, NULL);
-	__rtnl_register(PF_PHONET, RTM_NEWROUTE, route_doit, NULL, NULL);
-	__rtnl_register(PF_PHONET, RTM_DELROUTE, route_doit, NULL, NULL);
-	__rtnl_register(PF_PHONET, RTM_GETROUTE, NULL, route_dumpit, NULL);
+	__rtnl_register(PF_PHONET, RTM_DELADDR, addr_doit, NULL, 0);
+	__rtnl_register(PF_PHONET, RTM_GETADDR, NULL, getaddr_dumpit, 0);
+	__rtnl_register(PF_PHONET, RTM_NEWROUTE, route_doit, NULL, 0);
+	__rtnl_register(PF_PHONET, RTM_DELROUTE, route_doit, NULL, 0);
+	__rtnl_register(PF_PHONET, RTM_GETROUTE, NULL, route_dumpit, 0);
 	return 0;
 }
diff --git a/net/qrtr/qrtr.c b/net/qrtr/qrtr.c
index 5586609afa27..c2f5c13550c0 100644
--- a/net/qrtr/qrtr.c
+++ b/net/qrtr/qrtr.c
@@ -1081,7 +1081,7 @@ static int __init qrtr_proto_init(void)
 		return rc;
 	}
 
-	rtnl_register(PF_QIPCRTR, RTM_NEWADDR, qrtr_addr_doit, NULL, NULL);
+	rtnl_register(PF_QIPCRTR, RTM_NEWADDR, qrtr_addr_doit, NULL, 0);
 
 	return 0;
 }
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index a2915d958279..02fcb0c78a28 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -1255,10 +1255,10 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 
 static int __init tc_action_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETACTION, tc_ctl_action, tc_dump_action,
-		      NULL);
+		      0);
 
 	return 0;
 }
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 668afb6e9885..f5a118dca264 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1018,10 +1018,10 @@ EXPORT_SYMBOL(tcf_exts_get_dev);
 
 static int __init tc_filter_init(void)
 {
-	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, tc_ctl_tfilter, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, tc_ctl_tfilter,
-		      tc_dump_tfilter, NULL);
+		      tc_dump_tfilter, 0);
 
 	return 0;
 }
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index bd24a550e0f9..816c8092e601 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1952,14 +1952,14 @@ static int __init pktsched_init(void)
 	register_qdisc(&mq_qdisc_ops);
 	register_qdisc(&noqueue_qdisc_ops);
 
-	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, NULL);
+	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc,
-		      NULL);
-	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL, NULL);
+		      0);
+	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL, 0);
+	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass,
-		      NULL);
+		      0);
 
 	return 0;
 }
-- 
2.13.0
