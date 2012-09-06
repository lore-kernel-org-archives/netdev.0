From: pablo@netfilter.org
Subject: [PATCH 2/2] netlink: remove module parameter from netlink_kernel_create
Date: Thu,  6 Sep 2012 14:31:52 +0200
Message-ID: <1346934712-3056-2-git-send-email-pablo@netfilter.org>
References: <1346934712-3056-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42489 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab2IFMdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 08:33:07 -0400
In-Reply-To: <1346934712-3056-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch defines netlink_kernel_create as a wrapper function of
__netlink_kernel_create to hide the struct module *me parameter
(which seems to be THIS_MODULE in all existing netlink subsystems).

Suggested by David S. Miller.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 crypto/crypto_user.c                |    3 +--
 drivers/connector/connector.c       |    3 +--
 drivers/scsi/scsi_netlink.c         |    2 +-
 drivers/scsi/scsi_transport_iscsi.c |    3 +--
 drivers/staging/gdm72xx/netlink_k.c |    2 +-
 include/linux/netlink.h             |   13 ++++++++++---
 kernel/audit.c                      |    3 +--
 lib/kobject_uevent.c                |    3 +--
 net/bridge/netfilter/ebt_ulog.c     |    3 +--
 net/core/rtnetlink.c                |    2 +-
 net/core/sock_diag.c                |    3 +--
 net/decnet/netfilter/dn_rtmsg.c     |    3 +--
 net/ipv4/fib_frontend.c             |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    3 +--
 net/netfilter/nfnetlink.c           |    2 +-
 net/netlink/af_netlink.c            |    8 +++-----
 net/netlink/genetlink.c             |    3 +--
 net/xfrm/xfrm_user.c                |    2 +-
 security/selinux/netlink.c          |    3 +--
 19 files changed, 30 insertions(+), 36 deletions(-)

diff --git a/crypto/crypto_user.c b/crypto/crypto_user.c
index ba2c611..165914e 100644
--- a/crypto/crypto_user.c
+++ b/crypto/crypto_user.c
@@ -500,8 +500,7 @@ static int __init crypto_user_init(void)
 		.input	= crypto_netlink_rcv,
 	};
 
-	crypto_nlsk = netlink_kernel_create(&init_net, NETLINK_CRYPTO,
-					    THIS_MODULE, &cfg);
+	crypto_nlsk = netlink_kernel_create(&init_net, NETLINK_CRYPTO, &cfg);
 	if (!crypto_nlsk)
 		return -ENOMEM;
 
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 82fa4f0..965b781 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -264,8 +264,7 @@ static int __devinit cn_init(void)
 		.input	= dev->input,
 	};
 
-	dev->nls = netlink_kernel_create(&init_net, NETLINK_CONNECTOR,
-					 THIS_MODULE, &cfg);
+	dev->nls = netlink_kernel_create(&init_net, NETLINK_CONNECTOR, &cfg);
 	if (!dev->nls)
 		return -EIO;
 
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index 8818dd6..3252bc9 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -501,7 +501,7 @@ scsi_netlink_init(void)
 	}
 
 	scsi_nl_sock = netlink_kernel_create(&init_net, NETLINK_SCSITRANSPORT,
-					     THIS_MODULE, &cfg);
+					     &cfg);
 	if (!scsi_nl_sock) {
 		printk(KERN_ERR "%s: register of receive handler failed\n",
 				__func__);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index fa1dfaa..519bd53 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -2969,8 +2969,7 @@ static __init int iscsi_transport_init(void)
 	if (err)
 		goto unregister_conn_class;
 
-	nls = netlink_kernel_create(&init_net, NETLINK_ISCSI,
-				    THIS_MODULE, &cfg);
+	nls = netlink_kernel_create(&init_net, NETLINK_ISCSI, &cfg);
 	if (!nls) {
 		err = -ENOBUFS;
 		goto unregister_session_class;
diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index 3abb31d..2109cab 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -95,7 +95,7 @@ struct sock *netlink_init(int unit, void (*cb)(struct net_device *dev, u16 type,
 	init_MUTEX(&netlink_mutex);
 #endif
 
-	sock = netlink_kernel_create(&init_net, unit, THIS_MODULE, &cfg);
+	sock = netlink_kernel_create(&init_net, unit, &cfg);
 
 	if (sock)
 		rcv_cb = cb;
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index d30ee743..628e799 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -153,6 +153,7 @@ struct nlattr {
 
 #include <linux/capability.h>
 #include <linux/skbuff.h>
+#include <linux/module.h>
 
 struct net;
 
@@ -187,9 +188,15 @@ struct netlink_kernel_cfg {
 	unsigned int	flags;
 };
 
-extern struct sock *netlink_kernel_create(struct net *net, int unit,
-					  struct module *module,
-					  struct netlink_kernel_cfg *cfg);
+extern struct sock *__netlink_kernel_create(struct net *net, int unit,
+					    struct module *module,
+					    struct netlink_kernel_cfg *cfg);
+static inline struct sock *
+netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
+{
+	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
+}
+
 extern void netlink_kernel_release(struct sock *sk);
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
diff --git a/kernel/audit.c b/kernel/audit.c
index ea3b7b6..a24aafa 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -971,8 +971,7 @@ static int __init audit_init(void)
 
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT,
-					   THIS_MODULE, &cfg);
+	audit_sock = netlink_kernel_create(&init_net, NETLINK_AUDIT, &cfg);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 	else
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index c2e9778..52e5abb 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -382,8 +382,7 @@ static int uevent_net_init(struct net *net)
 	if (!ue_sk)
 		return -ENOMEM;
 
-	ue_sk->sk = netlink_kernel_create(net, NETLINK_KOBJECT_UEVENT,
-					  THIS_MODULE, &cfg);
+	ue_sk->sk = netlink_kernel_create(net, NETLINK_KOBJECT_UEVENT, &cfg);
 	if (!ue_sk->sk) {
 		printk(KERN_ERR
 		       "kobject_uevent: unable to create netlink socket!\n");
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 1906347..3476ec4 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -298,8 +298,7 @@ static int __init ebt_ulog_init(void)
 		spin_lock_init(&ulog_buffers[i].lock);
 	}
 
-	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
-					  THIS_MODULE, &cfg);
+	ebtulognl = netlink_kernel_create(&init_net, NETLINK_NFLOG, &cfg);
 	if (!ebtulognl)
 		ret = -ENOMEM;
 	else if ((ret = xt_register_target(&ebt_ulog_tg_reg)) != 0)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a71806e..508c5df 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2384,7 +2384,7 @@ static int __net_init rtnetlink_net_init(struct net *net)
 		.flags		= NL_CFG_F_NONROOT_RECV,
 	};
 
-	sk = netlink_kernel_create(net, NETLINK_ROUTE, THIS_MODULE, &cfg);
+	sk = netlink_kernel_create(net, NETLINK_ROUTE, &cfg);
 	if (!sk)
 		return -ENOMEM;
 	net->rtnl = sk;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 9d8755e..602cd63 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -172,8 +172,7 @@ static int __net_init diag_net_init(struct net *net)
 		.input	= sock_diag_rcv,
 	};
 
-	net->diag_nlsk = netlink_kernel_create(net, NETLINK_SOCK_DIAG,
-					       THIS_MODULE, &cfg);
+	net->diag_nlsk = netlink_kernel_create(net, NETLINK_SOCK_DIAG, &cfg);
 	return net->diag_nlsk == NULL ? -ENOMEM : 0;
 }
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 11db0ec..dfe4201 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -130,8 +130,7 @@ static int __init dn_rtmsg_init(void)
 		.input	= dnrmg_receive_user_skb,
 	};
 
-	dnrmg = netlink_kernel_create(&init_net,
-				      NETLINK_DNRTMSG, THIS_MODULE, &cfg);
+	dnrmg = netlink_kernel_create(&init_net, NETLINK_DNRTMSG, &cfg);
 	if (dnrmg == NULL) {
 		printk(KERN_ERR "dn_rtmsg: Cannot create netlink socket");
 		return -ENOMEM;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index acdee32..21bf521 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -986,7 +986,7 @@ static int __net_init nl_fib_lookup_init(struct net *net)
 		.input	= nl_fib_input,
 	};
 
-	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, THIS_MODULE, &cfg);
+	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, &cfg);
 	if (sk == NULL)
 		return -EAFNOSUPPORT;
 	net->ipv4.fibnl = sk;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 1109f7f..b5ef3cb 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -396,8 +396,7 @@ static int __init ulog_tg_init(void)
 	for (i = 0; i < ULOG_MAXNLGROUPS; i++)
 		setup_timer(&ulog_buffers[i].timer, ulog_timer, i);
 
-	nflognl = netlink_kernel_create(&init_net, NETLINK_NFLOG,
-					THIS_MODULE, &cfg);
+	nflognl = netlink_kernel_create(&init_net, NETLINK_NFLOG, &cfg);
 	if (!nflognl)
 		return -ENOMEM;
 
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index a265033..ffb92c0 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -241,7 +241,7 @@ static int __net_init nfnetlink_net_init(struct net *net)
 #endif
 	};
 
-	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, THIS_MODULE, &cfg);
+	nfnl = netlink_kernel_create(net, NETLINK_NETFILTER, &cfg);
 	if (!nfnl)
 		return -ENOMEM;
 	net->nfnl_stash = nfnl;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 1543a66..93768db 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1526,9 +1526,8 @@ static void netlink_data_ready(struct sock *sk, int len)
  */
 
 struct sock *
-netlink_kernel_create(struct net *net, int unit,
-		      struct module *module,
-		      struct netlink_kernel_cfg *cfg)
+__netlink_kernel_create(struct net *net, int unit, struct module *module,
+			struct netlink_kernel_cfg *cfg)
 {
 	struct socket *sock;
 	struct sock *sk;
@@ -1603,8 +1602,7 @@ out_sock_release_nosk:
 	sock_release(sock);
 	return NULL;
 }
-EXPORT_SYMBOL(netlink_kernel_create);
-
+EXPORT_SYMBOL(__netlink_kernel_create);
 
 void
 netlink_kernel_release(struct sock *sk)
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index c1b71ae..19288b7 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -922,8 +922,7 @@ static int __net_init genl_pernet_init(struct net *net)
 	};
 
 	/* we'll bump the group number right afterwards */
-	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC,
-					       THIS_MODULE, &cfg);
+	net->genl_sock = netlink_kernel_create(net, NETLINK_GENERIC, &cfg);
 
 	if (!net->genl_sock && net_eq(net, &init_net))
 		panic("GENL: Cannot initialize generic netlink\n");
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ab58034..354070a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2963,7 +2963,7 @@ static int __net_init xfrm_user_net_init(struct net *net)
 		.input	= xfrm_netlink_rcv,
 	};
 
-	nlsk = netlink_kernel_create(net, NETLINK_XFRM, THIS_MODULE, &cfg);
+	nlsk = netlink_kernel_create(net, NETLINK_XFRM, &cfg);
 	if (nlsk == NULL)
 		return -ENOMEM;
 	net->xfrm.nlsk_stash = nlsk; /* Don't set to NULL */
diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 0d2cd11..14d810e 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -116,8 +116,7 @@ static int __init selnl_init(void)
 		.flags	= NL_CFG_F_NONROOT_RECV,
 	};
 
-	selnl = netlink_kernel_create(&init_net, NETLINK_SELINUX,
-				      THIS_MODULE, &cfg);
+	selnl = netlink_kernel_create(&init_net, NETLINK_SELINUX, &cfg);
 	if (selnl == NULL)
 		panic("SELinux:  Cannot create netlink socket.");
 	return 0;
-- 
1.7.10.4
