From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH -next 08/11] remove CONFIG_KMOD from net
Date: Wed, 09 Jul 2008 10:28:42 +0200
Message-ID: <20080709082903.988242000@sipsolutions.net>
References: <20080709082834.942992000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:40953 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbYGIMrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:47:17 -0400
Content-Disposition: inline; filename=010-config-kmod-remove-net.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some code here depends on CONFIG_KMOD to not try to load
protocol modules or similar, replace by CONFIG_MODULES
where more than just request_module depends on CONFIG_KMOD
and and also use try_then_request_module in ebtables.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org
---
v2: remove #ifdef around EXPORT_SYMBOL pointed out by
    Adrian Bunk

 include/linux/netdevice.h       |    5 ++++-
 net/bluetooth/af_bluetooth.c    |    8 +-------
 net/bridge/netfilter/ebtables.c |   15 +++------------
 net/can/af_can.c                |    4 ++--
 net/core/dev.c                  |    2 --
 net/core/rtnetlink.c            |    4 ++--
 net/dccp/ccid.c                 |    2 +-
 net/decnet/dn_dev.c             |    2 --
 net/ipv4/devinet.c              |    2 --
 net/ipv4/inet_diag.c            |    2 --
 net/ipv4/tcp_cong.c             |    4 ++--
 net/netfilter/nfnetlink.c       |    2 +-
 net/netlink/af_netlink.c        |    2 +-
 net/sched/act_api.c             |    2 +-
 net/sched/cls_api.c             |    2 +-
 net/sched/ematch.c              |    2 +-
 net/sched/sch_api.c             |    2 +-
 net/socket.c                    |    2 +-
 net/sunrpc/auth.c               |    2 --
 19 files changed, 22 insertions(+), 44 deletions(-)

--- linux-next.orig/net/bluetooth/af_bluetooth.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/bluetooth/af_bluetooth.c	2008-07-08 23:55:31.000000000 +0200
@@ -36,10 +36,7 @@
 #include <linux/init.h>
 #include <linux/poll.h>
 #include <net/sock.h>
-
-#if defined(CONFIG_KMOD)
 #include <linux/kmod.h>
-#endif
 
 #include <net/bluetooth/bluetooth.h>
 
@@ -144,11 +141,8 @@ static int bt_sock_create(struct net *ne
 	if (proto < 0 || proto >= BT_MAX_PROTO)
 		return -EINVAL;
 
-#if defined(CONFIG_KMOD)
-	if (!bt_proto[proto]) {
+	if (!bt_proto[proto])
 		request_module("bt-proto-%d", proto);
-	}
-#endif
 
 	err = -EPROTONOSUPPORT;
 
--- linux-next.orig/net/bridge/netfilter/ebtables.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/bridge/netfilter/ebtables.c	2008-07-08 23:55:31.000000000 +0200
@@ -288,23 +288,14 @@ find_inlist_lock_noload(struct list_head
 	return NULL;
 }
 
-#ifndef CONFIG_KMOD
-#define find_inlist_lock(h,n,p,e,m) find_inlist_lock_noload((h),(n),(e),(m))
-#else
 static void *
 find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
    int *error, struct mutex *mutex)
 {
-	void *ret;
-
-	ret = find_inlist_lock_noload(head, name, error, mutex);
-	if (!ret) {
-		request_module("%s%s", prefix, name);
-		ret = find_inlist_lock_noload(head, name, error, mutex);
-	}
-	return ret;
+	return try_then_request_module(
+			find_inlist_lock_noload(head, name, error, mutex),
+			"%s%s", prefix, name);
 }
-#endif
 
 static inline struct ebt_table *
 find_table_lock(const char *name, int *error, struct mutex *mutex)
--- linux-next.orig/net/can/af_can.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/can/af_can.c	2008-07-08 23:55:31.000000000 +0200
@@ -128,8 +128,8 @@ static int can_create(struct net *net, s
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
 
-#ifdef CONFIG_KMOD
-	/* try to load protocol module, when CONFIG_KMOD is defined */
+#ifdef CONFIG_MODULES
+	/* try to load protocol module kernel is modular */
 	if (!proto_tab[protocol]) {
 		err = request_module("can-proto-%d", protocol);
 
--- linux-next.orig/net/core/dev.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/core/dev.c	2008-07-08 23:55:31.000000000 +0200
@@ -4704,8 +4704,6 @@ EXPORT_SYMBOL(br_fdb_get_hook);
 EXPORT_SYMBOL(br_fdb_put_hook);
 #endif
 
-#ifdef CONFIG_KMOD
 EXPORT_SYMBOL(dev_load);
-#endif
 
 EXPORT_PER_CPU_SYMBOL(softnet_data);
--- linux-next.orig/net/core/rtnetlink.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/core/rtnetlink.c	2008-07-08 23:55:31.000000000 +0200
@@ -1025,7 +1025,7 @@ static int rtnl_newlink(struct sk_buff *
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 replay:
 #endif
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
@@ -1114,7 +1114,7 @@ replay:
 			return -EOPNOTSUPP;
 
 		if (!ops) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			if (kind[0]) {
 				__rtnl_unlock();
 				request_module("rtnl-link-%s", kind);
--- linux-next.orig/net/dccp/ccid.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/dccp/ccid.c	2008-07-08 23:55:31.000000000 +0200
@@ -154,7 +154,7 @@ struct ccid *ccid_new(unsigned char id, 
 	struct ccid *ccid = NULL;
 
 	ccids_read_lock();
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (ccids[id] == NULL) {
 		/* We only try to load if in process context */
 		ccids_read_unlock();
--- linux-next.orig/net/decnet/dn_dev.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/decnet/dn_dev.c	2008-07-08 23:55:31.000000000 +0200
@@ -490,9 +490,7 @@ int dn_dev_ioctl(unsigned int cmd, void 
 		return -EFAULT;
 	ifr->ifr_name[IFNAMSIZ-1] = 0;
 
-#ifdef CONFIG_KMOD
 	dev_load(&init_net, ifr->ifr_name);
-#endif
 
 	switch(cmd) {
 		case SIOCGIFADDR:
--- linux-next.orig/net/ipv4/devinet.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/ipv4/devinet.c	2008-07-08 23:55:31.000000000 +0200
@@ -613,9 +613,7 @@ int devinet_ioctl(struct net *net, unsig
 	if (colon)
 		*colon = 0;
 
-#ifdef CONFIG_KMOD
 	dev_load(net, ifr.ifr_name);
-#endif
 
 	switch (cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
--- linux-next.orig/net/ipv4/inet_diag.c	2008-07-08 23:47:41.000000000 +0200
+++ linux-next/net/ipv4/inet_diag.c	2008-07-08 23:55:31.000000000 +0200
@@ -53,11 +53,9 @@ static DEFINE_MUTEX(inet_diag_table_mute
 
 static const struct inet_diag_handler *inet_diag_lock_handler(int type)
 {
-#ifdef CONFIG_KMOD
 	if (!inet_diag_table[type])
 		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
 			       NETLINK_INET_DIAG, type);
-#endif
 
 	mutex_lock(&inet_diag_table_mutex);
 	if (!inet_diag_table[type])
--- linux-next.orig/net/ipv4/tcp_cong.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/ipv4/tcp_cong.c	2008-07-08 23:55:31.000000000 +0200
@@ -115,7 +115,7 @@ int tcp_set_default_congestion_control(c
 
 	spin_lock(&tcp_cong_list_lock);
 	ca = tcp_ca_find(name);
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (!ca && capable(CAP_SYS_MODULE)) {
 		spin_unlock(&tcp_cong_list_lock);
 
@@ -244,7 +244,7 @@ int tcp_set_congestion_control(struct so
 	if (ca == icsk->icsk_ca_ops)
 		goto out;
 
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	/* not found attempt to autoload module */
 	if (!ca && capable(CAP_SYS_MODULE)) {
 		rcu_read_unlock();
--- linux-next.orig/net/netfilter/nfnetlink.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/netfilter/nfnetlink.c	2008-07-08 23:55:31.000000000 +0200
@@ -134,7 +134,7 @@ static int nfnetlink_rcv_msg(struct sk_b
 	type = nlh->nlmsg_type;
 	ss = nfnetlink_get_subsys(type);
 	if (!ss) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 		nfnl_unlock();
 		request_module("nfnetlink-subsys-%d", NFNL_SUBSYS_ID(type));
 		nfnl_lock();
--- linux-next.orig/net/netlink/af_netlink.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/netlink/af_netlink.c	2008-07-08 23:55:31.000000000 +0200
@@ -434,7 +434,7 @@ static int netlink_create(struct net *ne
 		return -EPROTONOSUPPORT;
 
 	netlink_lock_table();
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (!nl_table[protocol].registered) {
 		netlink_unlock_table();
 		request_module("net-pf-%d-proto-%d", PF_NETLINK, protocol);
--- linux-next.orig/net/sched/act_api.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/sched/act_api.c	2008-07-08 23:55:31.000000000 +0200
@@ -495,7 +495,7 @@ struct tc_action *tcf_action_init_1(stru
 
 	a_o = tc_lookup_action_n(act_name);
 	if (a_o == NULL) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 		rtnl_unlock();
 		request_module("act_%s", act_name);
 		rtnl_lock();
--- linux-next.orig/net/sched/cls_api.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/sched/cls_api.c	2008-07-08 23:55:31.000000000 +0200
@@ -223,7 +223,7 @@ replay:
 		err = -ENOENT;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			struct nlattr *kind = tca[TCA_KIND];
 			char name[IFNAMSIZ];
 
--- linux-next.orig/net/sched/ematch.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/sched/ematch.c	2008-07-08 23:55:31.000000000 +0200
@@ -224,7 +224,7 @@ static int tcf_em_validate(struct tcf_pr
 
 		if (em->ops == NULL) {
 			err = -ENOENT;
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			__rtnl_unlock();
 			request_module("ematch-kind-%u", em_hdr->kind);
 			rtnl_lock();
--- linux-next.orig/net/sched/sch_api.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/sched/sch_api.c	2008-07-08 23:55:31.000000000 +0200
@@ -561,7 +561,7 @@ qdisc_create(struct net_device *dev, u32
 	struct Qdisc_ops *ops;
 
 	ops = qdisc_lookup_ops(kind);
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (ops == NULL && kind != NULL) {
 		char name[IFNAMSIZ];
 		if (nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
--- linux-next.orig/net/socket.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/socket.c	2008-07-08 23:55:31.000000000 +0200
@@ -1140,7 +1140,7 @@ static int __sock_create(struct net *net
 
 	sock->type = type;
 
-#if defined(CONFIG_KMOD)
+#ifdef CONFIG_MODULES
 	/* Attempt to load a protocol module if the find failed.
 	 *
 	 * 12/09/1996 Marcin: But! this makes REALLY only sense, if the user
--- linux-next.orig/net/sunrpc/auth.c	2008-07-08 23:47:42.000000000 +0200
+++ linux-next/net/sunrpc/auth.c	2008-07-08 23:55:31.000000000 +0200
@@ -83,10 +83,8 @@ rpcauth_create(rpc_authflavor_t pseudofl
 	if (flavor >= RPC_AUTH_MAXFLAVOR)
 		goto out;
 
-#ifdef CONFIG_KMOD
 	if ((ops = auth_flavors[flavor]) == NULL)
 		request_module("rpc-auth-%u", flavor);
-#endif
 	spin_lock(&rpc_authflavor_lock);
 	ops = auth_flavors[flavor];
 	if (ops == NULL || !try_module_get(ops->owner)) {
--- linux-next.orig/include/linux/netdevice.h	2008-07-08 23:47:39.000000000 +0200
+++ linux-next/include/linux/netdevice.h	2008-07-08 23:55:31.000000000 +0200
@@ -1488,8 +1488,11 @@ extern int		dev_set_allmulti(struct net_
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
-/* Load a device via the kmod */
+#ifdef CONFIG_MODULES
 extern void		dev_load(struct net *net, const char *name);
+#else
+static inline void	dev_load(struct net *net, const char *name) {};
+#endif
 extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;

-- 
