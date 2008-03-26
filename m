From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 1/3][NETNS][IPV6] anycast - handle several network namespace
Date: Wed, 26 Mar 2008 13:28:33 +0100
Message-ID: <20080326123131.486264273@mai.toulouse-stg.fr.ibm.com>
References: <20080326122832.564021438@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:50601 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbYCZMca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:32:30 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m2QCWTck037684
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 12:32:29 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QCWTa22150400
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:32:29 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QCWSPr003139
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:32:29 +0100
Content-Disposition: inline; filename=ipv6-acast-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the network namespace information to have this protocol to
handle several network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/addrconf.h |    3 ++-
 include/net/ipv6.h     |   17 ++++++-----------
 net/ipv6/af_inet6.c    |   12 ++++++------
 net/ipv6/anycast.c     |   38 ++++++++++++++++++++++----------------
 net/ipv6/ndisc.c       |    2 +-
 5 files changed, 37 insertions(+), 35 deletions(-)

Index: net-2.6.26/net/ipv6/anycast.c
===================================================================
--- net-2.6.26.orig/net/ipv6/anycast.c
+++ net-2.6.26/net/ipv6/anycast.c
@@ -82,6 +82,7 @@ int ipv6_sock_ac_join(struct sock *sk, i
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev;
 	struct ipv6_ac_socklist *pac;
+	struct net *net = sock_net(sk);
 	int	ishost = !ipv6_devconf.forwarding;
 	int	err = 0;
 
@@ -89,7 +90,7 @@ int ipv6_sock_ac_join(struct sock *sk, i
 		return -EPERM;
 	if (ipv6_addr_is_multicast(addr))
 		return -EINVAL;
-	if (ipv6_chk_addr(&init_net, addr, NULL, 0))
+	if (ipv6_chk_addr(net, addr, NULL, 0))
 		return -EINVAL;
 
 	pac = sock_kmalloc(sk, sizeof(struct ipv6_ac_socklist), GFP_KERNEL);
@@ -101,7 +102,7 @@ int ipv6_sock_ac_join(struct sock *sk, i
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
+		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
@@ -112,10 +113,10 @@ int ipv6_sock_ac_join(struct sock *sk, i
 		} else {
 			/* router, no matching interface: just pick one */
 
-			dev = dev_get_by_flags(&init_net, IFF_UP, IFF_UP|IFF_LOOPBACK);
+			dev = dev_get_by_flags(net, IFF_UP, IFF_UP|IFF_LOOPBACK);
 		}
 	} else
-		dev = dev_get_by_index(&init_net, ifindex);
+		dev = dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
 		err = -ENODEV;
@@ -176,6 +177,7 @@ int ipv6_sock_ac_drop(struct sock *sk, i
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct net_device *dev;
 	struct ipv6_ac_socklist *pac, *prev_pac;
+	struct net *net = sock_net(sk);
 
 	write_lock_bh(&ipv6_sk_ac_lock);
 	prev_pac = NULL;
@@ -196,7 +198,7 @@ int ipv6_sock_ac_drop(struct sock *sk, i
 
 	write_unlock_bh(&ipv6_sk_ac_lock);
 
-	dev = dev_get_by_index(&init_net, pac->acl_ifindex);
+	dev = dev_get_by_index(net, pac->acl_ifindex);
 	if (dev) {
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
 		dev_put(dev);
@@ -210,6 +212,7 @@ void ipv6_sock_ac_close(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct net_device *dev = NULL;
 	struct ipv6_ac_socklist *pac;
+	struct net *net = sock_net(sk);
 	int	prev_index;
 
 	write_lock_bh(&ipv6_sk_ac_lock);
@@ -224,7 +227,7 @@ void ipv6_sock_ac_close(struct sock *sk)
 		if (pac->acl_ifindex != prev_index) {
 			if (dev)
 				dev_put(dev);
-			dev = dev_get_by_index(&init_net, pac->acl_ifindex);
+			dev = dev_get_by_index(net, pac->acl_ifindex);
 			prev_index = pac->acl_ifindex;
 		}
 		if (dev)
@@ -422,14 +425,15 @@ static int ipv6_chk_acast_dev(struct net
 /*
  *	check if given interface (or any, if dev==0) has this anycast address
  */
-int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr)
+int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+			struct in6_addr *addr)
 {
 	int found = 0;
 
 	if (dev)
 		return ipv6_chk_acast_dev(dev, addr);
 	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev)
+	for_each_netdev(net, dev)
 		if (ipv6_chk_acast_dev(dev, addr)) {
 			found = 1;
 			break;
@@ -441,6 +445,7 @@ int ipv6_chk_acast_addr(struct net_devic
 
 #ifdef CONFIG_PROC_FS
 struct ac6_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct inet6_dev *idev;
 };
@@ -451,9 +456,10 @@ static inline struct ifacaddr6 *ac6_get_
 {
 	struct ifacaddr6 *im = NULL;
 	struct ac6_iter_state *state = ac6_seq_private(seq);
+	struct net *net = seq_file_net(seq);
 
 	state->idev = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (!idev)
@@ -551,8 +557,8 @@ static const struct seq_operations ac6_s
 
 static int ac6_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ac6_seq_ops,
-			sizeof(struct ac6_iter_state));
+	return seq_open_net(inode, file, &ac6_seq_ops,
+			    sizeof(struct ac6_iter_state));
 }
 
 static const struct file_operations ac6_seq_fops = {
@@ -560,20 +566,20 @@ static const struct file_operations ac6_
 	.open		=	ac6_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 
-int __init ac6_proc_init(void)
+int ac6_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(&init_net, "anycast6", S_IRUGO, &ac6_seq_fops))
+	if (!proc_net_fops_create(net, "anycast6", S_IRUGO, &ac6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
 }
 
-void ac6_proc_exit(void)
+void ac6_proc_exit(struct net *net)
 {
-	proc_net_remove(&init_net, "anycast6");
+	proc_net_remove(net, "anycast6");
 }
 #endif
 
Index: net-2.6.26/include/net/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/ipv6.h
+++ net-2.6.26/include/net/ipv6.h
@@ -591,8 +591,8 @@ extern int ip6_mc_msfget(struct sock *sk
 			 int __user *optlen);
 
 #ifdef CONFIG_PROC_FS
-extern int  ac6_proc_init(void);
-extern void ac6_proc_exit(void);
+extern int  ac6_proc_init(struct net *net);
+extern void ac6_proc_exit(struct net *net);
 extern int  raw6_proc_init(void);
 extern void raw6_proc_exit(void);
 extern int  tcp6_proc_init(struct net *net);
@@ -607,15 +607,10 @@ extern int snmp6_register_dev(struct ine
 extern int snmp6_unregister_dev(struct inet6_dev *idev);
 
 #else
-static inline int snmp6_register_dev(struct inet6_dev *idev)
-{
-	return 0;
-}
-
-static inline int snmp6_unregister_dev(struct inet6_dev *idev)
-{
-	return 0;
-}
+static inline int ac6_proc_init(struct net *net) { return 0; }
+static inline void ac6_proc_exit(struct net *net) { }
+static inline int snmp6_register_dev(struct inet6_dev *idev) { return 0; }
+static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
 #endif
 
 #ifdef CONFIG_SYSCTL
Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -862,11 +862,16 @@ static int inet6_net_init(struct net *ne
 	err = tcp6_proc_init(net);
 	if (err)
 		goto proc_tcp6_fail;
+	err = ac6_proc_init(net);
+	if (err)
+		goto proc_ac6_fail;
 out:
 #endif
 	return err;
 
 #ifdef CONFIG_PROC_FS
+proc_ac6_fail:
+	tcp6_proc_exit(net);
 proc_tcp6_fail:
 	udp6_proc_exit(net);
 	goto out;
@@ -878,6 +883,7 @@ static void inet6_net_exit(struct net *n
 #ifdef CONFIG_PROC_FS
 	udp6_proc_exit(net);
 	tcp6_proc_exit(net);
+	ac6_proc_exit(net);
 #endif
 }
 
@@ -965,9 +971,6 @@ static int __init inet6_init(void)
 		goto proc_udplite6_fail;
 	if (ipv6_misc_proc_init())
 		goto proc_misc6_fail;
-
-	if (ac6_proc_init())
-		goto proc_anycast6_fail;
 	if (if6_proc_init())
 		goto proc_if6_fail;
 #endif
@@ -1039,8 +1042,6 @@ ip6_route_fail:
 #ifdef CONFIG_PROC_FS
 	if6_proc_exit();
 proc_if6_fail:
-	ac6_proc_exit();
-proc_anycast6_fail:
 	ipv6_misc_proc_exit();
 proc_misc6_fail:
 	udplite6_proc_exit();
@@ -1101,7 +1102,6 @@ static void __exit inet6_exit(void)
 
 	/* Cleanup code parts. */
 	if6_proc_exit();
-	ac6_proc_exit();
 	ipv6_misc_proc_exit();
 	udplite6_proc_exit();
 	raw6_proc_exit();
Index: net-2.6.26/include/net/addrconf.h
===================================================================
--- net-2.6.26.orig/include/net/addrconf.h
+++ net-2.6.26/include/net/addrconf.h
@@ -134,7 +134,8 @@ extern int inet6_ac_check(struct sock *s
 
 extern int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr);
 extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr);
-extern int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr);
+extern int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
+			       struct in6_addr *addr);
 
 
 /* Device notifier */
Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -773,7 +773,7 @@ static void ndisc_recv_ns(struct sk_buff
 			return;
 		}
 
-		if (ipv6_chk_acast_addr(dev, &msg->target) ||
+		if (ipv6_chk_acast_addr(dev_net(dev), dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
 		     (pneigh = pneigh_lookup(&nd_tbl, dev_net(dev),

-- 
