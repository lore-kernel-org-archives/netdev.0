From: pablo@netfilter.org
Subject: [PATCH 1/2] netlink: add netlink_kernel_cfg parameter to netlink_kernel_create
Date: Fri, 29 Jun 2012 18:15:21 +0200
Message-ID: <1340986522-3442-2-git-send-email-pablo@netfilter.org>
References: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340986522-3442-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the following structure:

struct netlink_kernel_cfg {
        unsigned int    groups;
        void            (*input)(struct sk_buff *skb);
        struct mutex    *cb_mutex;
};

That can be passed to netlink_kernel_create to set optional configurations
for netlink kernel sockets.

I've populated this structure by looking for NULL and zero parameters at the
existing code. The remaining parameters that always need to be set are still
left in the original interface.

That includes optional parameters for the netlink socket creation. This allows
easy extensibility of this interface in the future.

This patch also adapts all callers to use this new interface.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 crypto/crypto_user.c                |    7 +++++--
 drivers/connector/connector.c       |   13 +++++++++----
 drivers/infiniband/core/netlink.c   |    7 +++++--
 drivers/scsi/scsi_netlink.c         |    7 +++++--
 drivers/scsi/scsi_transport_iscsi.c |    9 ++++++---
 drivers/staging/gdm72xx/netlink_k.c |    6 ++++--
 include/linux/netlink.h             |   15 ++++++++++-----
 kernel/audit.c                      |    7 +++++--
 lib/kobject_uevent.c                |    5 ++++-
 net/bridge/netfilter/ebt_ulog.c     |    6 ++++--
 net/core/rtnetlink.c                |    9 +++++++--
 net/core/sock_diag.c                |    8 ++++++--
 net/decnet/netfilter/dn_rtmsg.c     |    8 +++++---
 net/ipv4/fib_frontend.c             |    7 +++++--
 net/ipv4/netfilter/ipt_ULOG.c       |    8 +++++---
 net/netfilter/nfnetlink.c           |    7 +++++--
 net/netlink/af_netlink.c            |   16 ++++++++++------
 net/netlink/genetlink.c             |   10 +++++++---
 net/xfrm/xfrm_user.c                |    7 +++++--
 security/selinux/netlink.c          |    6 +++++-
 20 files changed, 117 insertions(+), 51 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index 5a37ead..ba2c611 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -496,9 +496,12 @@ static void crypto_netlink_rcv(struct sk_buff *skb)
 
 static int __init crypto_user_init(void)
 {
+	struct netlink_kernel_cfg cfg = {
+		.input	= crypto_netlink_rcv,
+	};
+
 	crypto_nlsk = netlink_kernel_create(&init_net, NETLINK_CRYPTO,
-					    0, crypto_netlink_rcv,
-					    NULL, THIS_MODULE);
+					    THIS_MODULE, &cfg);
 	if (!crypto_nlsk)
 		return -ENOMEM;
 
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 34e0e9e..116cf8d 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -251,15 +251,20 @@ static const struct file_operations cn_file_ops = {
 	.release = single_release
 };
 
+static struct cn_dev cdev = {
+	.input   = cn_rx_skb,
+};
+
 static int __devinit cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
-
-	dev->input = cn_rx_skb;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= CN_NETLINK_USERS + 0xf,
+		.input	= dev->input,
+	};
 
 	dev->nls = netlink_kernel_create(&init_net, NETLINK_CONNECTOR,
-					 CN_NETLINK_USERS + 0xf,
-					 dev->input, NULL, THIS_MODULE);
+					 THIS_MODULE, &cfg);
 	if (!dev->nls)
 		return -EIO;
 
diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index 1e691dc..3ae2bfd 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -173,8 +173,11 @@ static void ibnl_rcv(struct sk_buff *skb)
 
 int __init ibnl_init(void)
 {
-	nls = netlink_kernel_create(&init_net, NETLINK_RDMA, 0, ibnl_rcv,
-				    NULL, THIS_MODULE);
+	struct netlink_kernel_cfg cfg = {
+		.input	= ibnl_rcv,
+	};
+
+	nls = netlink_kernel_create(&init_net, NETLINK_RDMA, THIS_MODULE, &cfg);
 	if (!nls) {
 		pr_warn("Failed to create netlink socket\n");
 		return -ENOMEM;
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index c77628a..8818dd6 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -486,6 +486,10 @@ void
 scsi_netlink_init(void)
 {
 	int error;
+	struct netlink_kernel_cfg cfg = {
+		.input	= scsi_nl_rcv_msg,
+		.groups	= SCSI_NL_GRP_CNT,
+	};
 
 	INIT_LIST_HEAD(&scsi_nl_drivers);
 
@@ -497,8 +501,7 @@ scsi_netlink_init(void)
 	}
 
 	scsi_nl_sock = netlink_kernel_create(&init_net, NETLINK_SCSITRANSPORT,
-				SCSI_NL_GRP_CNT, scsi_nl_rcv_msg, NULL,
-				THIS_MODULE);
+					     THIS_MODULE, &cfg);
 	if (!scsi_nl_sock) {
 		printk(KERN_ERR "%s: register of receive handler failed\n",
 				__func__);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 1cf640e..6042954 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -2936,7 +2936,10 @@ EXPORT_SYMBOL_GPL(iscsi_unregister_transport);
 static __init int iscsi_transport_init(void)
 {
 	int err;
-
+	struct netlink_kernel_cfg cfg = {
+		.groups	= 1,
+		.input	= iscsi_if_rx,
+	};
 	printk(KERN_INFO "Loading iSCSI transport class v%s.\n",
 		ISCSI_TRANSPORT_VERSION);
 
@@ -2966,8 +2969,8 @@ static __init int iscsi_transport_init(void)
 	if (err)
 		goto unregister_conn_class;
 
-	nls = netlink_kernel_create(&init_net, NETLINK_ISCSI, 1, iscsi_if_rx,
-				    NULL, THIS_MODULE);
+	nls = netlink_kernel_create(&init_net, NETLINK_ISCSI,
+				    THIS_MODULE, &cfg);
 	if (!nls) {
 		err = -ENOBUFS;
 		goto unregister_session_class;
diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index d0cb48a..d1eed1e 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -88,13 +88,15 @@ struct sock *netlink_init(int unit, void (*cb)(struct net_device *dev, u16 type,
 						void *msg, int len))
 {
 	struct sock *sock;
+	struct netlink_kernel_cfg cfg = {
+		.input  = netlink_rcv,
+	};
 
 #if !defined(DEFINE_MUTEX)
 	init_MUTEX(&netlink_mutex);
 #endif
 
-	sock = netlink_kernel_create(&init_net, unit, 0, netlink_rcv, NULL,
-					THIS_MODULE);
+	sock = netlink_kernel_create(&init_net, unit, 0, THIS_MODULE, &cfg);
 
 	if (sock)
 		rcv_cb = cb;
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index ed33f09..6085e49 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -174,11 +174,16 @@ struct netlink_skb_parms {
 extern void netlink_table_grab(void);
 extern void netlink_table_ungrab(void);
 
-extern struct sock *netlink_kernel_create(struct net *net,
-					  int unit,unsigned int groups,
-					  void (*input)(struct sk_buff *skb),
-					  struct mutex *cb_mutex,
-					  struct module *module);
+/* optional Netlink kernel configuration parameters */
+struct netlink_kernel_cfg {
+	unsigned int	groups;
+	void		(*input)(struct sk_buff *skb);
+	struct mutex	*cb_mutex;
+};
+
+extern struct sock *netlink_kernel_create(struct net *net, int unit,
+					  struct module *module,
+					  struct netlink_kernel_cfg *cfg);
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
diff --git a/kernel/audit.c b/kernel/audit.c
index 30b252a..4a3f28d 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -962,14 +962,17 @@ static void audit_receive(struct sk_buff  *skb)
 static int __init audit_init(void)
 {
 	int i;
+	struct netlink_kernel_cfg cfg = {
+		.input	= audit_receive,
+	};
 
 	if (audit_initialized == AUDIT_DISABLED)
 		return 0;
 
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, 0,
-					   audit_receive, NULL, THIS_MODULE);
+	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT,
+					   THIS_MODULE, &cfg);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 	else
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 1a91efa..0401d29 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -373,13 +373,16 @@ EXPORT_SYMBOL_GPL(add_uevent_var);
 static int uevent_net_init(struct net *net)
 {
 	struct uevent_sock *ue_sk;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= 1,
+	};
 
 	ue_sk = kzalloc(sizeof(*ue_sk), GFP_KERNEL);
 	if (!ue_sk)
 		return -ENOMEM;
 
 	ue_sk->sk = netlink_kernel_create(net, NETLINK_KOBJECT_UEVENT,
-					  1, NULL, NULL, THIS_MODULE);
+					  THIS_MODULE, &cfg);
 	if (!ue_sk->sk) {
 		printk(KERN_ERR
 		       "kobject_uevent: unable to create netlink socket!\n");
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 1bd1732..374bdcd 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -282,6 +282,9 @@ static int __init ebt_ulog_init(void)
 {
 	int ret;
 	int i;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= EBT_ULOG_MAXNLGROUPS,
+	};
 
 	if (nlbufsiz >= 128*1024) {
 		pr_warning("Netlink buffer has to be <= 128kB,"
@@ -296,8 +299,7 @@ static int __init ebt_ulog_init(void)
 	}
 
 	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
-					  EBT_ULOG_MAXNLGROUPS, NULL, NULL,
-					  THIS_MODULE);
+					  THIS_MODULE, &cfg);
 	if (!ebtulognl)
 		ret = -ENOMEM;
 	else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 21318d1..2db8557 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2366,8 +2366,13 @@ static struct notifier_block rtnetlink_dev_notifier = {
 static int __net_init rtnetlink_net_init(struct net *net)
 {
 	struct sock *sk;
-	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
-				   rtnetlink_rcv, &rtnl_mutex, THIS_MODULE);
+	struct netlink_kernel_cfg cfg = {
+		.groups		= RTNLGRP_MAX,
+		.input		= rtnetlink_rcv,
+		.cb_mutex	= &rtnl_mutex,
+	};
+
+	sk = netlink_kernel_create(net, NETLINK_ROUTE, THIS_MODULE, &cfg);
 	if (!sk)
 		return -ENOMEM;
 	net->rtnl = sk;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 0d934ce..0929821 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -177,8 +177,12 @@ EXPORT_SYMBOL_GPL(sock_diag_nlsk);
 
 static int __init sock_diag_init(void)
 {
-	sock_diag_nlsk = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG, 0,
-					sock_diag_rcv, NULL, THIS_MODULE);
+	struct netlink_kernel_cfg cfg = {
+		.input	= sock_diag_rcv,
+	};
+
+	sock_diag_nlsk = netlink_kernel_create(&init_net, NETLINK_SOCK_DIAG,
+					       THIS_MODULE, &cfg);
 	return sock_diag_nlsk == NULL ? -ENOMEM : 0;
 }
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index b8f7f5b..11db0ec 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -125,11 +125,13 @@ static struct nf_hook_ops dnrmg_ops __read_mostly = {
 static int __init dn_rtmsg_init(void)
 {
 	int rv = 0;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= DNRNG_NLGRP_MAX,
+		.input	= dnrmg_receive_user_skb,
+	};
 
 	dnrmg = netlink_kernel_create(&init_net,
-				      NETLINK_DNRTMSG, DNRNG_NLGRP_MAX,
-				      dnrmg_receive_user_skb,
-				      NULL, THIS_MODULE);
+				      NETLINK_DNRTMSG, THIS_MODULE, &cfg);
 	if (dnrmg == NULL) {
 		printk(KERN_ERR "dn_rtmsg: Cannot create netlink socket");
 		return -ENOMEM;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3854411..0cd820e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -935,8 +935,11 @@ static void nl_fib_input(struct sk_buff *skb)
 static int __net_init nl_fib_lookup_init(struct net *net)
 {
 	struct sock *sk;
-	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, 0,
-				   nl_fib_input, NULL, THIS_MODULE);
+	struct netlink_kernel_cfg cfg = {
+		.input	= nl_fib_input,
+	};
+
+	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, THIS_MODULE, &cfg);
 	if (sk == NULL)
 		return -EAFNOSUPPORT;
 	net->ipv4.fibnl = sk;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 99b3f53..1109f7f 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -381,6 +381,9 @@ static struct nf_logger ipt_ulog_logger __read_mostly = {
 static int __init ulog_tg_init(void)
 {
 	int ret, i;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= ULOG_MAXNLGROUPS,
+	};
 
 	pr_debug("init module\n");
 
@@ -393,9 +396,8 @@ static int __init ulog_tg_init(void)
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++)
 		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
 
-	nflognl = netlink_kernel_create(&init_net,
-					NETLINK_NFLOG, ULOG_MAXNLGROUPS, NULL,
-					NULL, THIS_MODULE);
+	nflognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
+					THIS_MODULE, &cfg);
 	if (!nflognl)
 		return -ENOMEM;
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 3e797d1..700e461 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -203,9 +203,12 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 static int __net_init nfnetlink_net_init(struct net *net)
 {
 	struct sock *nfnl;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= NFNLGRP_MAX,
+		.input	= nfnetlink_rcv,
+	};
 
-	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, NFNLGRP_MAX,
-				     nfnetlink_rcv, NULL, THIS_MODULE);
+	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, THIS_MODULE, &cfg);
 	if (!nfnl)
 		return -ENOMEM;
 	net->nfnl_stash = nfnl;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index b3025a6..43a124f 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1503,14 +1503,16 @@ static void netlink_data_ready(struct sock *sk, int len)
  */
 
 struct sock *
-netlink_kernel_create(struct net *net, int unit, unsigned int groups,
-		      void (*input)(struct sk_buff *skb),
-		      struct mutex *cb_mutex, struct module *module)
+netlink_kernel_create(struct net *net, int unit,
+		      struct module *module,
+		      struct netlink_kernel_cfg *cfg)
 {
 	struct socket *sock;
 	struct sock *sk;
 	struct netlink_sock *nlk;
 	struct listeners *listeners = NULL;
+	struct mutex *cb_mutex = cfg ? cfg->cb_mutex : NULL;
+	unsigned int groups;
 
 	BUG_ON(!nl_table);
 
@@ -1532,16 +1534,18 @@ netlink_kernel_create(struct net *net, int unit, unsigned int groups,
 	sk = sock->sk;
 	sk_change_net(sk, net);
 
-	if (groups < 32)
+	if (!cfg || cfg->groups < 32)
 		groups = 32;
+	else
+		groups = cfg->groups;
 
 	listeners = kzalloc(sizeof(*listeners) + NLGRPSZ(groups), GFP_KERNEL);
 	if (!listeners)
 		goto out_sock_release;
 
 	sk->sk_data_ready = netlink_data_ready;
-	if (input)
-		nlk_sk(sk)->netlink_rcv = input;
+	if (cfg && cfg->input)
+		nlk_sk(sk)->netlink_rcv = cfg->input;
 
 	if (netlink_insert(sk, net, 0))
 		goto out_sock_release;
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2cc7c1e..32761b5 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -915,10 +915,14 @@ static struct genl_multicast_group notify_grp = {
 
 static int __net_init genl_pernet_init(struct net *net)
 {
+	struct netlink_kernel_cfg cfg = {
+		.input		= genl_rcv,
+		.cb_mutex	= &genl_mutex,
+	};
+
 	/* we'll bump the group number right afterwards */
-	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC, 0,
-					       genl_rcv, &genl_mutex,
-					       THIS_MODULE);
+	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC,
+					       THIS_MODULE, &cfg);
 
 	if (!net->genl_sock && net_eq(net, &init_net))
 		panic("GENL: Cannot initialize generic netlink\n");
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 44293b3..622d049 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2945,9 +2945,12 @@ static struct xfrm_mgr netlink_mgr = {
 static int __net_init xfrm_user_net_init(struct net *net)
 {
 	struct sock *nlsk;
+	struct netlink_kernel_cfg cfg = {
+		.groups	= XFRMNLGRP_MAX,
+		.input	= xfrm_netlink_rcv,
+	};
 
-	nlsk = netlink_kernel_create(net, NETLINK_XFRM, XFRMNLGRP_MAX,
-				     xfrm_netlink_rcv, NULL, THIS_MODULE);
+	nlsk = netlink_kernel_create(net, NETLINK_XFRM, THIS_MODULE, &cfg);
 	if (nlsk == NULL)
 		return -ENOMEM;
 	net->xfrm.nlsk_stash = nlsk; /* Don't set to NULL */
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 8a23a35..8a77725 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -111,8 +111,12 @@ void selnl_notify_policyload(u32 seqno)
 
 static int __init selnl_init(void)
 {
+	struct netlink_kernel_cfg cfg = {
+		.groups	= SELNLGRP_MAX,
+	};
+
 	selnl = netlink_kernel_create(&init_net, NETLINK_SELINUX,
-				      SELNLGRP_MAX, NULL, NULL, THIS_MODULE);
+				      THIS_MODULE, &cfg);
 	if (selnl == NULL)
 		panic("SELinux:  Cannot create netlink socket.");
 	netlink_set_nonroot(NETLINK_SELINUX, NL_NONROOT_RECV);
-- 
1.7.10

