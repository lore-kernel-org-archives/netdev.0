From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Remove CONFIG_KMOD from net/ (towards removing CONFIG_KMOD entirely)
Date: Fri, 17 Oct 2008 02:37:10 +1100
Message-ID: <200810170237.10755.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49894 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbYJPPha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 11:37:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Date: Wed, 09 Jul 2008 10:28:42 +0200
From: Johannes Berg <johannes@sipsolutions.net>

Some code here depends on CONFIG_KMOD to not try to load
protocol modules or similar, replace by CONFIG_MODULES
where more than just request_module depends on CONFIG_KMOD
and and also use try_then_request_module in ebtables.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
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
 18 files changed, 18 insertions(+), 43 deletions(-)

diff -r a0f7d5208026 net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/bluetooth/af_bluetooth.c	Mon Aug 25 14:28:47 2008 +1000
@@ -37,10 +37,7 @@
 #include <linux/poll.h>
 #include <net/sock.h>
 #include <asm/ioctls.h>
-
-#if defined(CONFIG_KMOD)
 #include <linux/kmod.h>
-#endif
 
 #include <net/bluetooth/bluetooth.h>
 
@@ -145,11 +142,8 @@ static int bt_sock_create(struct net *ne
 	if (proto < 0 || proto >= BT_MAX_PROTO)
 		return -EINVAL;
 
-#if defined(CONFIG_KMOD)
-	if (!bt_proto[proto]) {
+	if (!bt_proto[proto])
 		request_module("bt-proto-%d", proto);
-	}
-#endif
 
 	err = -EPROTONOSUPPORT;
 
diff -r a0f7d5208026 net/bridge/netfilter/ebtables.c
--- a/net/bridge/netfilter/ebtables.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/bridge/netfilter/ebtables.c	Mon Aug 25 14:28:47 2008 +1000
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
diff -r a0f7d5208026 net/can/af_can.c
--- a/net/can/af_can.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/can/af_can.c	Mon Aug 25 14:28:47 2008 +1000
@@ -128,8 +128,8 @@ static int can_create(struct net *net, s
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
 
-#ifdef CONFIG_KMOD
-	/* try to load protocol module, when CONFIG_KMOD is defined */
+#ifdef CONFIG_MODULES
+	/* try to load protocol module kernel is modular */
 	if (!proto_tab[protocol]) {
 		err = request_module("can-proto-%d", protocol);
 
diff -r a0f7d5208026 net/core/dev.c
--- a/net/core/dev.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/core/dev.c	Mon Aug 25 14:28:47 2008 +1000
@@ -4882,8 +4882,6 @@ EXPORT_SYMBOL(br_fdb_put_hook);
 EXPORT_SYMBOL(br_fdb_put_hook);
 #endif
 
-#ifdef CONFIG_KMOD
 EXPORT_SYMBOL(dev_load);
-#endif
 
 EXPORT_PER_CPU_SYMBOL(softnet_data);
diff -r a0f7d5208026 net/core/rtnetlink.c
--- a/net/core/rtnetlink.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/core/rtnetlink.c	Mon Aug 25 14:28:47 2008 +1000
@@ -1027,7 +1027,7 @@ static int rtnl_newlink(struct sk_buff *
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	int err;
 
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 replay:
 #endif
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
@@ -1116,7 +1116,7 @@ replay:
 			return -EOPNOTSUPP;
 
 		if (!ops) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			if (kind[0]) {
 				__rtnl_unlock();
 				request_module("rtnl-link-%s", kind);
diff -r a0f7d5208026 net/dccp/ccid.c
--- a/net/dccp/ccid.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/dccp/ccid.c	Mon Aug 25 14:28:47 2008 +1000
@@ -154,7 +154,7 @@ struct ccid *ccid_new(unsigned char id, 
 	struct ccid *ccid = NULL;
 
 	ccids_read_lock();
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (ccids[id] == NULL) {
 		/* We only try to load if in process context */
 		ccids_read_unlock();
diff -r a0f7d5208026 net/decnet/dn_dev.c
--- a/net/decnet/dn_dev.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/decnet/dn_dev.c	Mon Aug 25 14:28:47 2008 +1000
@@ -490,9 +490,7 @@ int dn_dev_ioctl(unsigned int cmd, void 
 		return -EFAULT;
 	ifr->ifr_name[IFNAMSIZ-1] = 0;
 
-#ifdef CONFIG_KMOD
 	dev_load(&init_net, ifr->ifr_name);
-#endif
 
 	switch(cmd) {
 		case SIOCGIFADDR:
diff -r a0f7d5208026 net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/ipv4/devinet.c	Mon Aug 25 14:28:47 2008 +1000
@@ -613,9 +613,7 @@ int devinet_ioctl(struct net *net, unsig
 	if (colon)
 		*colon = 0;
 
-#ifdef CONFIG_KMOD
 	dev_load(net, ifr.ifr_name);
-#endif
 
 	switch (cmd) {
 	case SIOCGIFADDR:	/* Get interface address */
diff -r a0f7d5208026 net/ipv4/inet_diag.c
--- a/net/ipv4/inet_diag.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/ipv4/inet_diag.c	Mon Aug 25 14:28:47 2008 +1000
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
diff -r a0f7d5208026 net/ipv4/tcp_cong.c
--- a/net/ipv4/tcp_cong.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/ipv4/tcp_cong.c	Mon Aug 25 14:28:47 2008 +1000
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
diff -r a0f7d5208026 net/netfilter/nfnetlink.c
--- a/net/netfilter/nfnetlink.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/netfilter/nfnetlink.c	Mon Aug 25 14:28:47 2008 +1000
@@ -134,7 +134,7 @@ static int nfnetlink_rcv_msg(struct sk_b
 	type = nlh->nlmsg_type;
 	ss = nfnetlink_get_subsys(type);
 	if (!ss) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 		nfnl_unlock();
 		request_module("nfnetlink-subsys-%d", NFNL_SUBSYS_ID(type));
 		nfnl_lock();
diff -r a0f7d5208026 net/netlink/af_netlink.c
--- a/net/netlink/af_netlink.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/netlink/af_netlink.c	Mon Aug 25 14:28:47 2008 +1000
@@ -435,7 +435,7 @@ static int netlink_create(struct net *ne
 		return -EPROTONOSUPPORT;
 
 	netlink_lock_table();
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (!nl_table[protocol].registered) {
 		netlink_unlock_table();
 		request_module("net-pf-%d-proto-%d", PF_NETLINK, protocol);
diff -r a0f7d5208026 net/sched/act_api.c
--- a/net/sched/act_api.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/sched/act_api.c	Mon Aug 25 14:28:47 2008 +1000
@@ -494,7 +494,7 @@ struct tc_action *tcf_action_init_1(stru
 
 	a_o = tc_lookup_action_n(act_name);
 	if (a_o == NULL) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 		rtnl_unlock();
 		request_module("act_%s", act_name);
 		rtnl_lock();
diff -r a0f7d5208026 net/sched/cls_api.c
--- a/net/sched/cls_api.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/sched/cls_api.c	Mon Aug 25 14:28:47 2008 +1000
@@ -227,7 +227,7 @@ replay:
 		err = -ENOENT;
 		tp_ops = tcf_proto_lookup_ops(tca[TCA_KIND]);
 		if (tp_ops == NULL) {
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			struct nlattr *kind = tca[TCA_KIND];
 			char name[IFNAMSIZ];
 
diff -r a0f7d5208026 net/sched/ematch.c
--- a/net/sched/ematch.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/sched/ematch.c	Mon Aug 25 14:28:47 2008 +1000
@@ -224,7 +224,7 @@ static int tcf_em_validate(struct tcf_pr
 
 		if (em->ops == NULL) {
 			err = -ENOENT;
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 			__rtnl_unlock();
 			request_module("ematch-kind-%u", em_hdr->kind);
 			rtnl_lock();
diff -r a0f7d5208026 net/sched/sch_api.c
--- a/net/sched/sch_api.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/sched/sch_api.c	Mon Aug 25 14:28:47 2008 +1000
@@ -764,7 +764,7 @@ qdisc_create(struct net_device *dev, str
 	struct qdisc_size_table *stab;
 
 	ops = qdisc_lookup_ops(kind);
-#ifdef CONFIG_KMOD
+#ifdef CONFIG_MODULES
 	if (ops == NULL && kind != NULL) {
 		char name[IFNAMSIZ];
 		if (nla_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
diff -r a0f7d5208026 net/socket.c
--- a/net/socket.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/socket.c	Mon Aug 25 14:28:47 2008 +1000
@@ -1142,7 +1142,7 @@ static int __sock_create(struct net *net
 
 	sock->type = type;
 
-#if defined(CONFIG_KMOD)
+#ifdef CONFIG_MODULES
 	/* Attempt to load a protocol module if the find failed.
 	 *
 	 * 12/09/1996 Marcin: But! this makes REALLY only sense, if the user
diff -r a0f7d5208026 net/sunrpc/auth.c
--- a/net/sunrpc/auth.c	Mon Aug 25 14:27:58 2008 +1000
+++ b/net/sunrpc/auth.c	Mon Aug 25 14:28:47 2008 +1000
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
