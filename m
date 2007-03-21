From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Wed, 21 Mar 2007 15:06:02 +0100
Message-ID: <46013BCA.3060300@trash.net>
References: <1174471116.16343.10.camel@localhost> <4601047A.6050108@trash.net> <46010641.3000009@trash.net> <4601268D.7090003@trash.net> <46013B73.2060804@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040508070309000609050506"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43598 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867AbXCUOGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 10:06:10 -0400
In-Reply-To: <46013B73.2060804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040508070309000609050506
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Patrick McHardy wrote:
> 
>>>Alexey just explained to me why we do need qdisc_tree_lock in private
>>>mail. While dumping only the first skb is filled under the RTNL,
>>>while filling further skbs we don't hold the RTNL anymore. So I will
>>>probably have to drop that patch.
>>
>>
>>
>>What we could do is replace the netlink cb_lock spinlock by a
>>user-supplied mutex (supplied to netlink_kernel_create, rtnl_mutex
>>in this case). That would put the entire dump under the rtnl and
>>allow us to get rid of qdisc_tree_lock and avoid the need to take
>>dev_base_lock during qdisc dumping. Same in other spots like
>>rtnl_dump_ifinfo, inet_dump_ifaddr, ...
> 
> 
> 
> These (compile tested) patches demonstrate the idea. The first one
> lets netlink_kernel_create users specify a mutex that should be
> held during dump callbacks, the second one uses this for rtnetlink
> and changes inet_dump_ifaddr for demonstration.
> 
> A complete patch would allow us to simplify locking in lots of
> spots, all rtnetlink users currently need to implement extra
> locking just for the dump functions, and a number of them
> already get it wrong and seem to rely on the rtnl.
> 
> If there are no objections to this change I'm going to update
> the second patch to include all rtnetlink users


D'oh .. wrong patches.




--------------040508070309000609050506
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[NETLINK]: Put dump callback under mutex, optionally user supplied

Replace the callback spinlock by a mutex and allow users to supply
their own mutex to allow getting rid of seperate locking in dump
callbacks. For users that don't supply their own mutex nothing changes.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c3400c45267a1fd291da75b0fe4b7970c846ff50
tree 96a4dc6050d74e72b4fffe9c047a0e695085e6db
parent 2c31e4429748f2629c59379b1113931a13a0cca9
author Patrick McHardy <kaber@trash.net> Wed, 21 Mar 2007 14:43:02 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 21 Mar 2007 14:43:02 +0100

 drivers/connector/connector.c       |    2 +-
 drivers/scsi/scsi_netlink.c         |    3 ++-
 drivers/scsi/scsi_transport_iscsi.c |    2 +-
 fs/ecryptfs/netlink.c               |    2 +-
 include/linux/netlink.h             |    5 ++++-
 lib/kobject_uevent.c                |    2 +-
 net/bridge/netfilter/ebt_ulog.c     |    2 +-
 net/core/rtnetlink.c                |    2 +-
 net/decnet/netfilter/dn_rtmsg.c     |    2 +-
 net/ipv4/fib_frontend.c             |    2 +-
 net/ipv4/inet_diag.c                |    2 +-
 net/ipv4/netfilter/ip_queue.c       |    2 +-
 net/ipv4/netfilter/ipt_ULOG.c       |    2 +-
 net/ipv6/netfilter/ip6_queue.c      |    2 +-
 net/netfilter/nfnetlink.c           |    2 +-
 net/netlink/af_netlink.c            |   30 +++++++++++++++++++-----------
 net/netlink/genetlink.c             |    2 +-
 net/xfrm/xfrm_user.c                |    2 +-
 security/selinux/netlink.c          |    2 +-
 19 files changed, 41 insertions(+), 29 deletions(-)

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
index 259f5c3..445d2fd 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -304,7 +304,7 @@ static int __init ebt_ulog_init(void)
 	}
 
 	ebtulognl = netlink_kernel_create(NETLINK_NFLOG, EBT_ULOG_MAXNLGROUPS,
-					  NULL, THIS_MODULE);
+					  NULL, NULL, THIS_MODULE);
 	if (!ebtulognl)
 		ret = -ENOMEM;
 	else if ((ret = ebt_register_watcher(&ulog)))
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6055074..777c4c0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -873,7 +873,7 @@ void __init rtnetlink_init(void)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, RTNLGRP_MAX, rtnetlink_rcv,
-				     THIS_MODULE);
+				     NULL, THIS_MODULE);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index 9e8256a..7799f36 100644
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
index 35515fb..2d79413 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -816,7 +816,7 @@ static void nl_fib_input(struct sock *sk, int len)
 
 static void nl_fib_lookup_init(void)
 {
-      netlink_kernel_create(NETLINK_FIB_LOOKUP, 0, nl_fib_input, THIS_MODULE);
+      netlink_kernel_create(NETLINK_FIB_LOOKUP, 0, nl_fib_input, NULL, THIS_MODULE);
 }
 
 static void fib_disable_ip(struct net_device *dev, int force)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 62c2e9f..abb012a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -918,7 +918,7 @@ static int __init inet_diag_init(void)
 		goto out;
 
 	idiagnl = netlink_kernel_create(NETLINK_INET_DIAG, 0, inet_diag_rcv,
-					THIS_MODULE);
+					NULL, THIS_MODULE);
 	if (idiagnl == NULL)
 		goto out_free_table;
 	err = 0;
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 17f7c98..c81fd41 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -680,7 +680,7 @@ static int __init ip_queue_init(void)
 
 	netlink_register_notifier(&ipq_nl_notifier);
 	ipqnl = netlink_kernel_create(NETLINK_FIREWALL, 0, ipq_rcv_sk,
-				      THIS_MODULE);
+				      NULL, THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip_queue: failed to create netlink socket\n");
 		goto cleanup_netlink_notifier;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index 3e5566b..17094c1 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -398,7 +398,7 @@ static int __init ipt_ulog_init(void)
 	}
 
 	nflognl = netlink_kernel_create(NETLINK_NFLOG, ULOG_MAXNLGROUPS, NULL,
-					THIS_MODULE);
+					NULL, THIS_MODULE);
 	if (!nflognl)
 		return -ENOMEM;
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 275e625..9caa7f7 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -669,7 +669,7 @@ static int __init ip6_queue_init(void)
 	struct proc_dir_entry *proc;
 
 	netlink_register_notifier(&ipq_nl_notifier);
-	ipqnl = netlink_kernel_create(NETLINK_IP6_FW, 0, ipq_rcv_sk,
+	ipqnl = netlink_kernel_create(NETLINK_IP6_FW, 0, ipq_rcv_sk, NULL,
 				      THIS_MODULE);
 	if (ipqnl == NULL) {
 		printk(KERN_ERR "ip6_queue: failed to create netlink socket\n");
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index dec36ab..51acce6 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -279,7 +279,7 @@ static int __init nfnetlink_init(void)
 	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
 
 	nfnl = netlink_kernel_create(NETLINK_NETFILTER, NFNLGRP_MAX,
-				     nfnetlink_rcv, THIS_MODULE);
+				     nfnetlink_rcv, NULL, THIS_MODULE);
 	if (!nfnl) {
 		printk(KERN_ERR "cannot initialize nfnetlink!\n");
 		return -1;
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5a7e6c8..7f6c666 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -76,7 +76,8 @@ struct netlink_sock {
 	unsigned long		state;
 	wait_queue_head_t	wait;
 	struct netlink_callback	*cb;
-	spinlock_t		cb_lock;
+	struct mutex		*cb_mutex;
+	struct mutex		cb_def_mutex;
 	void			(*data_ready)(struct sock *sk, int bytes);
 	struct module		*module;
 };
@@ -108,6 +109,7 @@ struct netlink_table {
 	unsigned long *listeners;
 	unsigned int nl_nonroot;
 	unsigned int groups;
+	struct mutex *cb_mutex;
 	struct module *module;
 	int registered;
 };
@@ -384,7 +386,7 @@ static int __netlink_create(struct socket *sock, int protocol)
 	sock_init_data(sock, sk);
 
 	nlk = nlk_sk(sk);
-	spin_lock_init(&nlk->cb_lock);
+	mutex_init(nlk->cb_mutex);
 	init_waitqueue_head(&nlk->wait);
 
 	sk->sk_destruct = netlink_sock_destruct;
@@ -395,6 +397,7 @@ static int __netlink_create(struct socket *sock, int protocol)
 static int netlink_create(struct socket *sock, int protocol)
 {
 	struct module *module = NULL;
+	struct mutex *cb_mutex;
 	struct netlink_sock *nlk;
 	unsigned int groups;
 	int err = 0;
@@ -419,6 +422,7 @@ static int netlink_create(struct socket *sock, int protocol)
 	    try_module_get(nl_table[protocol].module))
 		module = nl_table[protocol].module;
 	groups = nl_table[protocol].groups;
+	cb_mutex = nl_table[protocol].cb_mutex;
 	netlink_unlock_table();
 
 	if ((err = __netlink_create(sock, protocol)) < 0)
@@ -426,6 +430,7 @@ static int netlink_create(struct socket *sock, int protocol)
 
 	nlk = nlk_sk(sock->sk);
 	nlk->module = module;
+	nlk->cb_mutex = cb_mutex ? cb_mutex : &nlk->cb_def_mutex;
 out:
 	return err;
 
@@ -445,14 +450,14 @@ static int netlink_release(struct socket *sock)
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
@@ -1268,6 +1273,7 @@ static void netlink_data_ready(struct sock *sk, int len)
 struct sock *
 netlink_kernel_create(int unit, unsigned int groups,
 		      void (*input)(struct sock *sk, int len),
+		      struct mutex *cb_mutex,
 		      struct module *module)
 {
 	struct socket *sock;
@@ -1303,11 +1309,13 @@ netlink_kernel_create(int unit, unsigned int groups,
 
 	nlk = nlk_sk(sk);
 	nlk->flags |= NETLINK_KERNEL_SOCKET;
+	nlk->cb_mutex = &nlk->cb_def_mutex;
 
 	netlink_table_grab();
 	nl_table[unit].groups = groups;
 	nl_table[unit].listeners = listeners;
 	nl_table[unit].module = module;
+	nl_table[unit].cb_mutex = cb_mutex;
 	nl_table[unit].registered = 1;
 	netlink_table_ungrab();
 
@@ -1349,7 +1357,7 @@ static int netlink_dump(struct sock *sk)
 	if (!skb)
 		goto errout;
 
-	spin_lock(&nlk->cb_lock);
+	mutex_lock(nlk->cb_mutex);
 
 	cb = nlk->cb;
 	if (cb == NULL) {
@@ -1360,7 +1368,7 @@ static int netlink_dump(struct sock *sk)
 	len = cb->dump(skb, cb);
 
 	if (len > 0) {
-		spin_unlock(&nlk->cb_lock);
+		mutex_unlock(nlk->cb_mutex);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, len);
 		return 0;
@@ -1378,13 +1386,13 @@ static int netlink_dump(struct sock *sk)
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
@@ -1416,15 +1424,15 @@ int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
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
index c299679..dd45b7b 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -586,7 +586,7 @@ static int __init genl_init(void)
 
 	netlink_set_nonroot(NETLINK_GENERIC, NL_NONROOT_RECV);
 	genl_sock = netlink_kernel_create(NETLINK_GENERIC, GENL_MAX_ID,
-					  genl_rcv, THIS_MODULE);
+					  genl_rcv, NULL, THIS_MODULE);
 	if (genl_sock == NULL)
 		panic("GENL: Cannot initialize generic netlink\n");
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 699a7e0..8d0654e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2467,7 +2467,7 @@ static int __init xfrm_user_init(void)
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

--------------040508070309000609050506
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 777c4c0..3f5d198 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -873,7 +873,7 @@ void __init rtnetlink_init(void)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, RTNLGRP_MAX, rtnetlink_rcv,
-				     NULL, THIS_MODULE);
+				     &rtnl_mutex, THIS_MODULE);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 043857b..c4b82e3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1183,17 +1183,13 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	int s_ip_idx, s_idx = cb->args[0];
 
 	s_ip_idx = ip_idx = cb->args[1];
-	read_lock(&dev_base_lock);
 	for (dev = dev_base, idx = 0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
 		if (idx > s_idx)
 			s_ip_idx = 0;
-		rcu_read_lock();
-		if ((in_dev = __in_dev_get_rcu(dev)) == NULL) {
-			rcu_read_unlock();
+		if ((in_dev = __in_dev_get_rtnl(dev)) == NULL)
 			continue;
-		}
 
 		for (ifa = in_dev->ifa_list, ip_idx = 0; ifa;
 		     ifa = ifa->ifa_next, ip_idx++) {
@@ -1201,16 +1197,12 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 				continue;
 			if (inet_fill_ifaddr(skb, ifa, NETLINK_CB(cb->skb).pid,
 					     cb->nlh->nlmsg_seq,
-					     RTM_NEWADDR, NLM_F_MULTI) <= 0) {
-				rcu_read_unlock();
+					     RTM_NEWADDR, NLM_F_MULTI) <= 0)
 				goto done;
-			}
 		}
-		rcu_read_unlock();
 	}
 
 done:
-	read_unlock(&dev_base_lock);
 	cb->args[0] = idx;
 	cb->args[1] = ip_idx;
 

--------------040508070309000609050506--
