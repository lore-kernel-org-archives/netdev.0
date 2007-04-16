From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK 01/04]: Switch cb_lock spinlock to mutex and allow to override it
Date: Mon, 16 Apr 2007 09:51:53 +0200 (MEST)
Message-ID: <20070416074950.19262.97555.sendpatchset@localhost.localdomain>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34162 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932431AbXDPHvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:51:54 -0400
In-Reply-To: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETLINK]: Switch cb_lock spinlock to mutex and allow to override it

Switch cb_lock to mutex and allow netlink kernel users to override it
with a subsystem specific mutex for consistent locking in dump callbacks.
All netlink_dump_start users have been audited not to rely on any
side-effects of the previously used spinlock.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8373a426e9d692f74d10867c2dc3ea332e09154c
tree b0c1c2cc07d75444d8e5cb3da0b521f863324d93
parent 7d91d7463ee62d4c45d3fdd78ba92dee2920b342
author Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:17 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:17 +0200

 drivers/connector/connector.c       |    2 +-
 drivers/scsi/scsi_netlink.c         |    3 ++-
 drivers/scsi/scsi_transport_iscsi.c |    2 +-
 fs/ecryptfs/netlink.c               |    2 +-
 include/linux/netlink.h             |    5 ++++-
 kernel/audit.c                      |    2 +-
 lib/kobject_uevent.c                |    2 +-
 net/bridge/netfilter/ebt_ulog.c     |    2 +-
 net/core/rtnetlink.c                |    2 +-
 net/decnet/netfilter/dn_rtmsg.c     |    2 +-
 net/ipv4/fib_frontend.c             |    3 ++-
 net/ipv4/inet_diag.c                |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    2 +-
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/netfilter/nfnetlink.c           |    2 +-
 net/netlink/af_netlink.c            |   38 +++++++++++++++++++++--------------
 net/netlink/genetlink.c             |    2 +-
 net/xfrm/xfrm_user.c                |    2 +-
 security/selinux/netlink.c          |    2 +-
 20 files changed, 47 insertions(+), 34 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 7f9c4fb..a7b9e9b 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -448,7 +448,7 @@ static int __devinit cn_init(void)
 
 	dev->nls = netlink_kernel_create(NETLINK_CONNECTOR,
 					 CN_NETLINK_USERS + 0xf,
-					 dev->input, THIS_MODULE);
+					 dev->input, NULL, THIS_MODULE);
 	if (!dev->nls)
 		return -EIO;
 
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 45646a2..4bf9aa5 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -168,7 +168,8 @@ scsi_netlink_init(void)
 	}
 
 	scsi_nl_sock = netlink_kernel_create(NETLINK_SCSITRANSPORT,
-				SCSI_NL_GRP_CNT, scsi_nl_rcv, THIS_MODULE);
+				SCSI_NL_GRP_CNT, scsi_nl_rcv, NULL,
+				THIS_MODULE);
 	if (!scsi_nl_sock) {
 		printk(KERN_ERR "%s: register of recieve handler failed\n",
 				__FUNCTION__);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 10590cd..aabaa05 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1435,7 +1435,7 @@ static __init int iscsi_transport_init(void)
 	if (err)
 		goto unregister_conn_class;
 
-	nls = netlink_kernel_create(NETLINK_ISCSI, 1, iscsi_if_rx,
+	nls = netlink_kernel_create(NETLINK_ISCSI, 1, iscsi_if_rx, NULL,
 			THIS_MODULE);
 	if (!nls) {
 		err = -ENOBUFS;
diff --git a/fs/ecryptfs/netlink.c b/fs/ecryptfs/netlink.c
index 8405d21..fe91863 100644
--- a/fs/ecryptfs/netlink.c
+++ b/fs/ecryptfs/netlink.c
@@ -229,7 +229,7 @@ int ecryptfs_init_netlink(void)
 
 	ecryptfs_nl_sock = netlink_kernel_create(NETLINK_ECRYPTFS, 0,
 						 ecryptfs_receive_nl_message,
-						 THIS_MODULE);
+						 NULL, THIS_MODULE);
 	if (!ecryptfs_nl_sock) {
 		rc = -EIO;
 		ecryptfs_printk(KERN_ERR, "Failed to create netlink socket\n");
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 0d11f6a..f41688f 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -157,7 +157,10 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
-extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
+extern struct sock *netlink_kernel_create(int unit, unsigned int groups,
+					  void (*input)(struct sock *sk, int len),
+					  struct mutex *cb_mutex,
+					  struct module *module);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
diff --git a/kernel/audit.c b/kernel/audit.c
index 80a7457..4e9d208 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -795,7 +795,7 @@ static int __init audit_init(void)
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
 	audit_sock = netlink_kernel_create(NETLINK_AUDIT, 0, audit_receive,
-					   THIS_MODULE);
+					   NULL, THIS_MODULE);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 	else
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 84272ed..82fc179 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -293,7 +293,7 @@ EXPORT_SYMBOL_GPL(add_uevent_var);
 static int __init kobject_uevent_init(void)
 {
 	uevent_sock = netlink_kernel_create(NETLINK_KOBJECT_UEVENT, 1, NULL,
-					    THIS_MODULE);
+					    NULL, THIS_MODULE);
 
 	if (!uevent_sock) {
 		printk(KERN_ERR
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 8b84cd4..9411db6 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -302,7 +302,7 @@ static int __init ebt_ulog_init(void)
 	}
 
 	ebtulognl = netlink_kernel_create(NETLINK_NFLOG, EBT_ULOG_MAXNLGROUPS,
-					  NULL, THIS_MODULE);
+					  NULL, NULL, THIS_MODULE);
 	if (!ebtulognl)
 		ret = -ENOMEM;
 	else if ((ret = ebt_register_watcher(&ulog)))
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5266df3..648a7b6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -972,7 +972,7 @@ void __init rtnetlink_init(void)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, RTNLGRP_MAX, rtnetlink_rcv,
-				     THIS_MODULE);
+				     NULL, THIS_MODULE);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 2ee47ba..6962346 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -138,7 +138,7 @@ static int __init dn_rtmsg_init(void)
 	int rv = 0;
 
 	dnrmg = netlink_kernel_create(NETLINK_DNRTMSG, DNRNG_NLGRP_MAX,
-				      dnrmg_receive_user_sk, THIS_MODULE);
+				      dnrmg_receive_user_sk, NULL, THIS_MODULE);
 	if (dnrmg == NULL) {
 		printk(KERN_ERR "dn_rtmsg: Cannot create netlink socket");
 		return -ENOMEM;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 60f119d..4764310 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -821,7 +821,8 @@ static void nl_fib_input(struct sock *sk, int len)
 
 static void nl_fib_lookup_init(void)
 {
-      netlink_kernel_create(NETLINK_FIB_LOOKUP, 0, nl_fib_input, THIS_MODULE);
+      netlink_kernel_create(NETLINK_FIB_LOOKUP, 0, nl_fib_input, NULL,
+      			    THIS_MODULE);
 }
 
 static void fib_disable_ip(struct net_device *dev, int force)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 0148f0e..dbeacd8 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -893,7 +893,7 @@ static int __init inet_diag_init(void)
 		goto out;
 
 	idiagnl = netlink_kernel_create(NETLINK_INET_DIAG, 0, inet_diag_rcv,
-					THIS_MODULE);
+					NULL, THIS_MODULE);
 	if (idiagnl == NULL)
 		goto out_free_table;
 	err = 0;
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 0d72693..702d94d 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -668,7 +668,7 @@ static int __init ip_queue_init(void)
 
 	netlink_register_notifier(&ipq_nl_notifier);
 	ipqnl = netlink_kernel_create(NETLINK_FIREWALL, 0, ipq_rcv_sk,
-				      THIS_MODULE);
+				      NULL, THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip_queue: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 60dcf86..ebca0d0 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -419,7 +419,7 @@ static int __init ipt_ulog_init(void)
 		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
 
 	nflognl = netlink_kernel_create(NETLINK_NFLOG, ULOG_MAXNLGROUPS, NULL,
-					THIS_MODULE);
+					NULL, THIS_MODULE);
 	if (!nflognl)
 		return -ENOMEM;
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index bfae9fd..0004db3 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -657,7 +657,7 @@ static int __init ip6_queue_init(void)
 	struct proc_dir_entry *proc;
 
 	netlink_register_notifier(&ipq_nl_notifier);
-	ipqnl = netlink_kernel_create(NETLINK_IP6_FW, 0, ipq_rcv_sk,
+	ipqnl = netlink_kernel_create(NETLINK_IP6_FW, 0, ipq_rcv_sk, NULL,
 				      THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip6_queue: failed to create netlink socket\n");
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b0da853..8797e69 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -265,7 +265,7 @@ static int __init nfnetlink_init(void)
 	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
 
 	nfnl = netlink_kernel_create(NETLINK_NETFILTER, NFNLGRP_MAX,
-				     nfnetlink_rcv, THIS_MODULE);
+				     nfnetlink_rcv, NULL, THIS_MODULE);
 	if (!nfnl) {
 		printk(KERN_ERR "cannot initialize nfnetlink!\n");
 		return -1;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6701fbd..0be19b7 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -56,6 +56,7 @@
 #include <linux/types.h>
 #include <linux/audit.h>
 #include <linux/selinux.h>
+#include <linux/mutex.h>
 
 #include <net/sock.h>
 #include <net/scm.h>
@@ -76,7 +77,8 @@ struct netlink_sock {
 	unsigned long		state;
 	wait_queue_head_t	wait;
 	struct netlink_callback	*cb;
-	spinlock_t		cb_lock;
+	struct mutex		*cb_mutex;
+	struct mutex		cb_def_mutex;
 	void			(*data_ready)(struct sock *sk, int bytes);
 	struct module		*module;
 };
@@ -108,6 +110,7 @@ struct netlink_table {
 	unsigned long *listeners;
 	unsigned int nl_nonroot;
 	unsigned int groups;
+	struct mutex *cb_mutex;
 	struct module *module;
 	int registered;
 };
@@ -370,7 +373,8 @@ static struct proto netlink_proto = {
 	.obj_size = sizeof(struct netlink_sock),
 };
 
-static int __netlink_create(struct socket *sock, int protocol)
+static int __netlink_create(struct socket *sock, struct mutex *cb_mutex,
+			    int protocol)
 {
 	struct sock *sk;
 	struct netlink_sock *nlk;
@@ -384,7 +388,8 @@ static int __netlink_create(struct socket *sock, int protocol)
 	sock_init_data(sock, sk);
 
 	nlk = nlk_sk(sk);
-	spin_lock_init(&nlk->cb_lock);
+	nlk->cb_mutex = cb_mutex ? : &nlk->cb_def_mutex;
+	mutex_init(nlk->cb_mutex);
 	init_waitqueue_head(&nlk->wait);
 
 	sk->sk_destruct = netlink_sock_destruct;
@@ -395,6 +400,7 @@ static int __netlink_create(struct socket *sock, int protocol)
 static int netlink_create(struct socket *sock, int protocol)
 {
 	struct module *module = NULL;
+	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
 	int err = 0;
 
@@ -417,9 +423,10 @@ static int netlink_create(struct socket *sock, int protocol)
 	if (nl_table[protocol].registered &&
 	    try_module_get(nl_table[protocol].module))
 		module = nl_table[protocol].module;
+	cb_mutex = nl_table[protocol].cb_mutex;
 	netlink_unlock_table();
 
-	if ((err = __netlink_create(sock, protocol)) < 0)
+	if ((err = __netlink_create(sock, cb_mutex, protocol)) < 0)
 		goto out_module;
 
 	nlk = nlk_sk(sock->sk);
@@ -443,14 +450,14 @@ static int netlink_release(struct socket *sock)
 	netlink_remove(sk);
 	nlk = nlk_sk(sk);
 
-	spin_lock(&nlk->cb_lock);
+	mutex_lock(nlk->cb_mutex);
 	if (nlk->cb) {
 		if (nlk->cb->done)
 			nlk->cb->done(nlk->cb);
 		netlink_destroy_callback(nlk->cb);
 		nlk->cb = NULL;
 	}
-	spin_unlock(&nlk->cb_lock);
+	mutex_unlock(nlk->cb_mutex);
 
 	/* OK. Socket is unlinked, and, therefore,
 	   no new packets will arrive */
@@ -1266,7 +1273,7 @@ static void netlink_data_ready(struct sock *sk, int len)
 struct sock *
 netlink_kernel_create(int unit, unsigned int groups,
 		      void (*input)(struct sock *sk, int len),
-		      struct module *module)
+		      struct mutex *cb_mutex, struct module *module)
 {
 	struct socket *sock;
 	struct sock *sk;
@@ -1281,7 +1288,7 @@ netlink_kernel_create(int unit, unsigned int groups,
 	if (sock_create_lite(PF_NETLINK, SOCK_DGRAM, unit, &sock))
 		return NULL;
 
-	if (__netlink_create(sock, unit) < 0)
+	if (__netlink_create(sock, cb_mutex, unit) < 0)
 		goto out_sock_release;
 
 	if (groups < 32)
@@ -1305,6 +1312,7 @@ netlink_kernel_create(int unit, unsigned int groups,
 	netlink_table_grab();
 	nl_table[unit].groups = groups;
 	nl_table[unit].listeners = listeners;
+	nl_table[unit].cb_mutex = cb_mutex;
 	nl_table[unit].module = module;
 	nl_table[unit].registered = 1;
 	netlink_table_ungrab();
@@ -1347,7 +1355,7 @@ static int netlink_dump(struct sock *sk)
 	if (!skb)
 		goto errout;
 
-	spin_lock(&nlk->cb_lock);
+	mutex_lock(nlk->cb_mutex);
 
 	cb = nlk->cb;
 	if (cb == NULL) {
@@ -1358,7 +1366,7 @@ static int netlink_dump(struct sock *sk)
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
-		spin_unlock(&nlk->cb_lock);
+		mutex_unlock(nlk->cb_mutex);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, len);
 		return 0;
@@ -1376,13 +1384,13 @@ static int netlink_dump(struct sock *sk)
 	if (cb->done)
 		cb->done(cb);
 	nlk->cb = NULL;
-	spin_unlock(&nlk->cb_lock);
+	mutex_unlock(nlk->cb_mutex);
 
 	netlink_destroy_callback(cb);
 	return 0;
 
 errout_skb:
-	spin_unlock(&nlk->cb_lock);
+	mutex_unlock(nlk->cb_mutex);
 	kfree_skb(skb);
 errout:
 	return err;
@@ -1414,15 +1422,15 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	}
 	nlk = nlk_sk(sk);
 	/* A dump is in progress... */
-	spin_lock(&nlk->cb_lock);
+	mutex_lock(nlk->cb_mutex);
 	if (nlk->cb) {
-		spin_unlock(&nlk->cb_lock);
+		mutex_unlock(nlk->cb_mutex);
 		netlink_destroy_callback(cb);
 		sock_put(sk);
 		return -EBUSY;
 	}
 	nlk->cb = cb;
-	spin_unlock(&nlk->cb_lock);
+	mutex_unlock(nlk->cb_mutex);
 
 	netlink_dump(sk);
 	sock_put(sk);
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index fac2e7a..6e31234 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -558,7 +558,7 @@ static int __init genl_init(void)
 
 	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
 	genl_sock = netlink_kernel_create(NETLINK_GENERIC, GENL_MAX_ID,
-					  genl_rcv, THIS_MODULE);
+					  genl_rcv, NULL, THIS_MODULE);
 	if (genl_sock == NULL)
 		panic("GENL: Cannot initialize generic netlink\n");
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2f6671f..a5a5a1a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2445,7 +2445,7 @@ static int __init xfrm_user_init(void)
 	printk(KERN_INFO "Initializing XFRM netlink socket\n");
 
 	nlsk = netlink_kernel_create(NETLINK_XFRM, XFRMNLGRP_MAX,
-				     xfrm_netlink_rcv, THIS_MODULE);
+				     xfrm_netlink_rcv, NULL, THIS_MODULE);
 	if (nlsk == NULL)
 		return -ENOMEM;
 	rcu_assign_pointer(xfrm_nl, nlsk);
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 33f2e06..f49046d 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -104,7 +104,7 @@ void selnl_notify_policyload(u32 seqno)
 
 static int __init selnl_init(void)
 {
-	selnl = netlink_kernel_create(NETLINK_SELINUX, SELNLGRP_MAX, NULL,
+	selnl = netlink_kernel_create(NETLINK_SELINUX, SELNLGRP_MAX, NULL, NULL,
 	                              THIS_MODULE);
 	if (selnl == NULL)
 		panic("SELinux:  Cannot create netlink socket.");
