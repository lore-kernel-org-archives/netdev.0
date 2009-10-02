From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] netlink: add socket destruction notification
Date: Fri, 02 Oct 2009 10:44:08 +0200
Message-ID: <1254473048.3959.76.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>, Thomas Graf <tgraf@suug.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:51607 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbZJBIoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 04:44:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we want to keep track of resources associated with applications, we
need to know when an app is going away. Add a notification function to
netlink that tells us that, and also hook it up to generic netlink so
generic netlink can notify the families. Due to the way generic netlink
works though, we need to notify all families and they have to sort out
whatever resources some commands associated with the socket themselves.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/connector/connector.c       |    2 +-
 drivers/scsi/scsi_netlink.c         |    2 +-
 drivers/scsi/scsi_transport_iscsi.c |    2 +-
 include/linux/netlink.h             |    1 +
 include/net/genetlink.h             |    3 +++
 kernel/audit.c                      |    3 ++-
 lib/kobject_uevent.c                |    2 +-
 net/bridge/netfilter/ebt_ulog.c     |    2 +-
 net/core/rtnetlink.c                |    3 ++-
 net/decnet/netfilter/dn_rtmsg.c     |    2 +-
 net/ipv4/fib_frontend.c             |    2 +-
 net/ipv4/inet_diag.c                |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    6 +++---
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/netfilter/nfnetlink.c           |    2 +-
 net/netlink/af_netlink.c            |    6 ++++++
 net/netlink/genetlink.c             |   18 ++++++++++++++++--
 net/xfrm/xfrm_user.c                |    2 +-
 security/selinux/netlink.c          |    3 ++-
 20 files changed, 47 insertions(+), 20 deletions(-)

--- wireless-testing.orig/net/xfrm/xfrm_user.c	2009-09-23 10:10:41.000000000 +0200
+++ wireless-testing/net/xfrm/xfrm_user.c	2009-09-29 14:45:33.000000000 +0200
@@ -2605,7 +2605,7 @@ static int __net_init xfrm_user_net_init
 	struct sock *nlsk;
 
 	nlsk = netlink_kernel_create(net, NETLINK_XFRM, XFRMNLGRP_MAX,
-				     xfrm_netlink_rcv, NULL, THIS_MODULE);
+				     xfrm_netlink_rcv, NULL, NULL, THIS_MODULE);
 	if (nlsk == NULL)
 		return -ENOMEM;
 	rcu_assign_pointer(net->xfrm.nlsk, nlsk);
--- wireless-testing.orig/drivers/connector/connector.c	2009-09-29 12:26:17.000000000 +0200
+++ wireless-testing/drivers/connector/connector.c	2009-09-29 14:45:33.000000000 +0200
@@ -451,7 +451,7 @@ static int __devinit cn_init(void)
 
 	dev->nls = netlink_kernel_create(&init_net, NETLINK_CONNECTOR,
 					 CN_NETLINK_USERS + 0xf,
-					 dev->input, NULL, THIS_MODULE);
+					 dev->input, NULL, NULL, THIS_MODULE);
 	if (!dev->nls)
 		return -EIO;
 
--- wireless-testing.orig/drivers/scsi/scsi_netlink.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/drivers/scsi/scsi_netlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -496,7 +496,7 @@ scsi_netlink_init(void)
 
 	scsi_nl_sock = netlink_kernel_create(&init_net, NETLINK_SCSITRANSPORT,
 				SCSI_NL_GRP_CNT, scsi_nl_rcv_msg, NULL,
-				THIS_MODULE);
+				NULL, THIS_MODULE);
 	if (!scsi_nl_sock) {
 		printk(KERN_ERR "%s: register of recieve handler failed\n",
 				__func__);
--- wireless-testing.orig/drivers/scsi/scsi_transport_iscsi.c	2009-09-29 12:26:46.000000000 +0200
+++ wireless-testing/drivers/scsi/scsi_transport_iscsi.c	2009-09-29 14:45:33.000000000 +0200
@@ -2082,7 +2082,7 @@ static __init int iscsi_transport_init(v
 		goto unregister_conn_class;
 
 	nls = netlink_kernel_create(&init_net, NETLINK_ISCSI, 1, iscsi_if_rx,
-				    NULL, THIS_MODULE);
+				    NULL, NULL, THIS_MODULE);
 	if (!nls) {
 		err = -ENOBUFS;
 		goto unregister_session_class;
--- wireless-testing.orig/kernel/audit.c	2009-09-29 12:27:01.000000000 +0200
+++ wireless-testing/kernel/audit.c	2009-09-29 14:45:33.000000000 +0200
@@ -970,7 +970,8 @@ static int __init audit_init(void)
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
 	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, 0,
-					   audit_receive, NULL, THIS_MODULE);
+					   audit_receive, NULL, NULL,
+					   THIS_MODULE);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 	else
--- wireless-testing.orig/lib/kobject_uevent.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/lib/kobject_uevent.c	2009-09-29 14:45:33.000000000 +0200
@@ -322,7 +322,7 @@ EXPORT_SYMBOL_GPL(add_uevent_var);
 static int __init kobject_uevent_init(void)
 {
 	uevent_sock = netlink_kernel_create(&init_net, NETLINK_KOBJECT_UEVENT,
-					    1, NULL, NULL, THIS_MODULE);
+					    1, NULL, NULL, NULL, THIS_MODULE);
 	if (!uevent_sock) {
 		printk(KERN_ERR
 		       "kobject_uevent: unable to create netlink socket!\n");
--- wireless-testing.orig/net/bridge/netfilter/ebt_ulog.c	2009-09-29 12:27:03.000000000 +0200
+++ wireless-testing/net/bridge/netfilter/ebt_ulog.c	2009-09-29 14:45:33.000000000 +0200
@@ -304,7 +304,7 @@ static int __init ebt_ulog_init(void)
 
 	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
 					  EBT_ULOG_MAXNLGROUPS, NULL, NULL,
-					  THIS_MODULE);
+					  NULL, THIS_MODULE);
 	if (!ebtulognl) {
 		printk(KERN_WARNING KBUILD_MODNAME ": out of memory trying to "
 		       "call netlink_kernel_create\n");
--- wireless-testing.orig/net/core/rtnetlink.c	2009-09-29 12:27:04.000000000 +0200
+++ wireless-testing/net/core/rtnetlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -1360,7 +1360,8 @@ static int rtnetlink_net_init(struct net
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
-				   rtnetlink_rcv, &rtnl_mutex, THIS_MODULE);
+				   rtnetlink_rcv, NULL,
+				   &rtnl_mutex, THIS_MODULE);
 	if (!sk)
 		return -ENOMEM;
 	net->rtnl = sk;
--- wireless-testing.orig/net/decnet/netfilter/dn_rtmsg.c	2009-09-23 10:10:41.000000000 +0200
+++ wireless-testing/net/decnet/netfilter/dn_rtmsg.c	2009-09-29 14:45:33.000000000 +0200
@@ -128,7 +128,7 @@ static int __init dn_rtmsg_init(void)
 
 	dnrmg = netlink_kernel_create(&init_net,
 				      NETLINK_DNRTMSG, DNRNG_NLGRP_MAX,
-				      dnrmg_receive_user_skb,
+				      dnrmg_receive_user_skb, NULL,
 				      NULL, THIS_MODULE);
 	if (dnrmg == NULL) {
 		printk(KERN_ERR "dn_rtmsg: Cannot create netlink socket");
--- wireless-testing.orig/net/ipv4/fib_frontend.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/net/ipv4/fib_frontend.c	2009-09-29 14:45:33.000000000 +0200
@@ -879,7 +879,7 @@ static int nl_fib_lookup_init(struct net
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, 0,
-				   nl_fib_input, NULL, THIS_MODULE);
+				   nl_fib_input, NULL, NULL, THIS_MODULE);
 	if (sk == NULL)
 		return -EAFNOSUPPORT;
 	net->ipv4.fibnl = sk;
--- wireless-testing.orig/net/ipv4/inet_diag.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/net/ipv4/inet_diag.c	2009-09-29 14:45:33.000000000 +0200
@@ -924,7 +924,7 @@ static int __init inet_diag_init(void)
 		goto out;
 
 	idiagnl = netlink_kernel_create(&init_net, NETLINK_INET_DIAG, 0,
-					inet_diag_rcv, NULL, THIS_MODULE);
+					inet_diag_rcv, NULL, NULL, THIS_MODULE);
 	if (idiagnl == NULL)
 		goto out_free_table;
 	err = 0;
--- wireless-testing.orig/net/ipv4/netfilter/ip_queue.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/net/ipv4/netfilter/ip_queue.c	2009-09-29 14:45:33.000000000 +0200
@@ -578,7 +578,7 @@ static int __init ip_queue_init(void)
 
 	netlink_register_notifier(&ipq_nl_notifier);
 	ipqnl = netlink_kernel_create(&init_net, NETLINK_FIREWALL, 0,
-				      ipq_rcv_skb, NULL, THIS_MODULE);
+				      ipq_rcv_skb, NULL, NULL, THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip_queue: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
--- wireless-testing.orig/net/ipv4/netfilter/ipt_ULOG.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/net/ipv4/netfilter/ipt_ULOG.c	2009-09-29 14:45:33.000000000 +0200
@@ -400,9 +400,9 @@ static int __init ulog_tg_init(void)
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++)
 		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
 
-	nflognl = netlink_kernel_create(&init_net,
-					NETLINK_NFLOG, ULOG_MAXNLGROUPS, NULL,
-					NULL, THIS_MODULE);
+	nflognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
+					ULOG_MAXNLGROUPS, NULL,
+					NULL, NULL, THIS_MODULE);
 	if (!nflognl)
 		return -ENOMEM;
 
--- wireless-testing.orig/net/ipv6/netfilter/ip6_queue.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/net/ipv6/netfilter/ip6_queue.c	2009-09-29 14:45:33.000000000 +0200
@@ -580,7 +580,7 @@ static int __init ip6_queue_init(void)
 
 	netlink_register_notifier(&ipq_nl_notifier);
 	ipqnl = netlink_kernel_create(&init_net, NETLINK_IP6_FW, 0,
-			              ipq_rcv_skb, NULL, THIS_MODULE);
+				      ipq_rcv_skb, NULL, NULL, THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip6_queue: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
--- wireless-testing.orig/net/netfilter/nfnetlink.c	2009-09-29 12:27:12.000000000 +0200
+++ wireless-testing/net/netfilter/nfnetlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -196,7 +196,7 @@ static int __init nfnetlink_init(void)
 	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
 
 	nfnl = netlink_kernel_create(&init_net, NETLINK_NETFILTER, NFNLGRP_MAX,
-				     nfnetlink_rcv, NULL, THIS_MODULE);
+				     nfnetlink_rcv, NULL, NULL, THIS_MODULE);
 	if (!nfnl) {
 		printk(KERN_ERR "cannot initialize nfnetlink!\n");
 		return -ENOMEM;
--- wireless-testing.orig/net/netlink/genetlink.c	2009-09-29 12:27:12.000000000 +0200
+++ wireless-testing/net/netlink/genetlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -561,6 +561,20 @@ static void genl_rcv(struct sk_buff *skb
 	genl_unlock();
 }
 
+static void genl_destruct(struct sock *sk)
+{
+	struct genl_family *f;
+	int idx;
+
+	genl_lock();
+
+	for (idx = 0; idx < GENL_FAM_TAB_SIZE; idx++)
+		list_for_each_entry(f, &family_ht[idx], family_list)
+			if (f->destruct_sk)
+				f->destruct_sk(sk);
+	genl_unlock();
+}
+
 /**************************************************************************
  * Controller
  **************************************************************************/
@@ -852,8 +866,8 @@ static int __net_init genl_pernet_init(s
 {
 	/* we'll bump the group number right afterwards */
 	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC, 0,
-					       genl_rcv, &genl_mutex,
-					       THIS_MODULE);
+					       genl_rcv, genl_destruct,
+					       &genl_mutex, THIS_MODULE);
 
 	if (!net->genl_sock && net_eq(net, &init_net))
 		panic("GENL: Cannot initialize generic netlink\n");
--- wireless-testing.orig/security/selinux/netlink.c	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/security/selinux/netlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -106,7 +106,8 @@ void selnl_notify_policyload(u32 seqno)
 static int __init selnl_init(void)
 {
 	selnl = netlink_kernel_create(&init_net, NETLINK_SELINUX,
-				      SELNLGRP_MAX, NULL, NULL, THIS_MODULE);
+				      SELNLGRP_MAX, NULL, NULL, NULL,
+				      THIS_MODULE);
 	if (selnl == NULL)
 		panic("SELinux:  Cannot create netlink socket.");
 	netlink_set_nonroot(NETLINK_SELINUX, NL_NONROOT_RECV);
--- wireless-testing.orig/include/linux/netlink.h	2009-09-29 12:26:58.000000000 +0200
+++ wireless-testing/include/linux/netlink.h	2009-09-29 14:45:33.000000000 +0200
@@ -182,6 +182,7 @@ extern void netlink_table_ungrab(void);
 extern struct sock *netlink_kernel_create(struct net *net,
 					  int unit,unsigned int groups,
 					  void (*input)(struct sk_buff *skb),
+					  void (*destruct)(struct sock *sk),
 					  struct mutex *cb_mutex,
 					  struct module *module);
 extern void netlink_kernel_release(struct sock *sk);
--- wireless-testing.orig/include/net/genetlink.h	2009-09-23 10:10:42.000000000 +0200
+++ wireless-testing/include/net/genetlink.h	2009-09-29 14:45:33.000000000 +0200
@@ -30,6 +30,8 @@ struct genl_multicast_group
  * @maxattr: maximum number of attributes supported
  * @netnsok: set to true if the family can handle network
  *	namespaces and should be presented in all of them
+ * @destruct_sk: called when any generic netlink socket
+ *	is destroyed (e.g. by the application closing it)
  * @attrbuf: buffer to store parsed attributes
  * @ops_list: list of all assigned operations
  * @family_list: family list
@@ -43,6 +45,7 @@ struct genl_family
 	unsigned int		version;
 	unsigned int		maxattr;
 	bool			netnsok;
+	void			(*destruct_sk)(struct sock *sk);
 	struct nlattr **	attrbuf;	/* private */
 	struct list_head	ops_list;	/* private */
 	struct list_head	family_list;	/* private */
--- wireless-testing.orig/net/netlink/af_netlink.c	2009-09-29 12:27:12.000000000 +0200
+++ wireless-testing/net/netlink/af_netlink.c	2009-09-29 14:45:33.000000000 +0200
@@ -80,6 +80,7 @@ struct netlink_sock {
 	struct mutex		*cb_mutex;
 	struct mutex		cb_def_mutex;
 	void			(*netlink_rcv)(struct sk_buff *skb);
+	void			(*destruct)(struct sock *sk);
 	struct module		*module;
 };
 
@@ -166,6 +167,9 @@ static void netlink_sock_destruct(struct
 		return;
 	}
 
+	if (nlk->destruct)
+		nlk->destruct(sk);
+
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
 	WARN_ON(nlk_sk(sk)->groups);
@@ -1464,6 +1468,7 @@ static void netlink_data_ready(struct so
 struct sock *
 netlink_kernel_create(struct net *net, int unit, unsigned int groups,
 		      void (*input)(struct sk_buff *skb),
+		      void (*destruct)(struct sock *sk),
 		      struct mutex *cb_mutex, struct module *module)
 {
 	struct socket *sock;
@@ -1502,6 +1507,7 @@ netlink_kernel_create(struct net *net, i
 	sk->sk_data_ready = netlink_data_ready;
 	if (input)
 		nlk_sk(sk)->netlink_rcv = input;
+	nlk_sk(sk)->destruct = destruct;
 
 	if (netlink_insert(sk, net, 0))
 		goto out_sock_release;


