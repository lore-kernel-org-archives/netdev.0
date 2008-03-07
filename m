From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 6/6][NETNS][IPV6] mcast - handle several network namespace
Date: Fri, 07 Mar 2008 16:26:44 +0100
Message-ID: <20080307152943.781632944@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:40216 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764189AbYCGPaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:15 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m27FUEik187268
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:14 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FUEj62044070
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:14 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FUDKm018881
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:13 +0100
Content-Disposition: inline; filename=ipv6-mcast-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch make use of the network namespace information at the right 
places to handle the multicast for several network namespaces.
It makes the socket control to be per namespace too.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 
 net/ipv6/mcast.c         |  116 +++++++++++++++++++++++++++++++----------------
 net/ipv6/udp.c           |    3 +
 3 files changed, 82 insertions(+), 38 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -53,5 +53,6 @@ struct netns_ipv6 {
 	struct sock		**icmp_sk;
 	struct sock             *ndisc_sk;
 	struct sock             *tcp_sk;
+	struct sock             *igmp_sk;
 };
 #endif
Index: net-2.6.26/net/ipv6/mcast.c
===================================================================
--- net-2.6.26.orig/net/ipv6/mcast.c
+++ net-2.6.26/net/ipv6/mcast.c
@@ -126,8 +126,6 @@ static struct in6_addr mld2_all_mcr = ML
 /* Big mc list lock for all the sockets */
 static DEFINE_RWLOCK(ipv6_sk_mc_lock);
 
-static struct socket *igmp6_socket;
-
 int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
 
 static void igmp6_join_group(struct ifmcaddr6 *ma);
@@ -183,6 +181,7 @@ int ipv6_sock_mc_join(struct sock *sk, i
 	struct net_device *dev = NULL;
 	struct ipv6_mc_socklist *mc_lst;
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sk->sk_net;
 	int err;
 
 	if (!ipv6_addr_is_multicast(addr))
@@ -208,14 +207,14 @@ int ipv6_sock_mc_join(struct sock *sk, i
 
 	if (ifindex == 0) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
+		rt = rt6_lookup(net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
 			dst_release(&rt->u.dst);
 		}
 	} else
-		dev = dev_get_by_index(&init_net, ifindex);
+		dev = dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
@@ -256,6 +255,7 @@ int ipv6_sock_mc_drop(struct sock *sk, i
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst, **lnk;
+	struct net *net = sk->sk_net;
 
 	write_lock_bh(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list; (mc_lst = *lnk) !=NULL ; lnk = &mc_lst->next) {
@@ -266,7 +266,8 @@ int ipv6_sock_mc_drop(struct sock *sk, i
 			*lnk = mc_lst->next;
 			write_unlock_bh(&ipv6_sk_mc_lock);
 
-			if ((dev = dev_get_by_index(&init_net, mc_lst->ifindex)) != NULL) {
+			dev = dev_get_by_index(net, mc_lst->ifindex);
+			if (dev != NULL) {
 				struct inet6_dev *idev = in6_dev_get(dev);
 
 				(void) ip6_mc_leave_src(sk, mc_lst, idev);
@@ -286,7 +287,9 @@ int ipv6_sock_mc_drop(struct sock *sk, i
 	return -EADDRNOTAVAIL;
 }
 
-static struct inet6_dev *ip6_mc_find_dev(struct in6_addr *group, int ifindex)
+static struct inet6_dev *ip6_mc_find_dev(struct net *net,
+					 struct in6_addr *group,
+					 int ifindex)
 {
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
@@ -294,14 +297,14 @@ static struct inet6_dev *ip6_mc_find_dev
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(&init_net, group, NULL, 0, 0);
+		rt = rt6_lookup(net, group, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
 			dst_release(&rt->u.dst);
 		}
 	} else
-		dev = dev_get_by_index(&init_net, ifindex);
+		dev = dev_get_by_index(net, ifindex);
 
 	if (!dev)
 		return NULL;
@@ -324,6 +327,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst;
+	struct net *net = sk->sk_net;
 
 	write_lock_bh(&ipv6_sk_mc_lock);
 	while ((mc_lst = np->ipv6_mc_list) != NULL) {
@@ -332,7 +336,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 		np->ipv6_mc_list = mc_lst->next;
 		write_unlock_bh(&ipv6_sk_mc_lock);
 
-		dev = dev_get_by_index(&init_net, mc_lst->ifindex);
+		dev = dev_get_by_index(net, mc_lst->ifindex);
 		if (dev) {
 			struct inet6_dev *idev = in6_dev_get(dev);
 
@@ -361,6 +365,7 @@ int ip6_mc_source(int add, int omode, st
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
+	struct net *net = sk->sk_net;
 	int i, j, rv;
 	int leavegroup = 0;
 	int pmclocked = 0;
@@ -376,7 +381,7 @@ int ip6_mc_source(int add, int omode, st
 	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(group, pgsr->gsr_interface);
+	idev = ip6_mc_find_dev(net, group, pgsr->gsr_interface);
 	if (!idev)
 		return -ENODEV;
 	dev = idev->dev;
@@ -500,6 +505,7 @@ int ip6_mc_msfilter(struct sock *sk, str
 	struct inet6_dev *idev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *newpsl, *psl;
+	struct net *net = sk->sk_net;
 	int leavegroup = 0;
 	int i, err;
 
@@ -511,7 +517,7 @@ int ip6_mc_msfilter(struct sock *sk, str
 	    gsf->gf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(group, gsf->gf_interface);
+	idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
 
 	if (!idev)
 		return -ENODEV;
@@ -592,13 +598,14 @@ int ip6_mc_msfget(struct sock *sk, struc
 	struct net_device *dev;
 	struct ipv6_pinfo *inet6 = inet6_sk(sk);
 	struct ip6_sf_socklist *psl;
+	struct net *net = sk->sk_net;
 
 	group = &((struct sockaddr_in6 *)&gsf->gf_group)->sin6_addr;
 
 	if (!ipv6_addr_is_multicast(group))
 		return -EINVAL;
 
-	idev = ip6_mc_find_dev(group, gsf->gf_interface);
+	idev = ip6_mc_find_dev(net, group, gsf->gf_interface);
 
 	if (!idev)
 		return -ENODEV;
@@ -1393,7 +1400,8 @@ mld_scount(struct ifmcaddr6 *pmc, int ty
 
 static struct sk_buff *mld_newpack(struct net_device *dev, int size)
 {
-	struct sock *sk = igmp6_socket->sk;
+	struct net *net = dev->nd_net;
+	struct sock *sk = net->ipv6.igmp_sk;
 	struct sk_buff *skb;
 	struct mld2_report *pmr;
 	struct in6_addr addr_buf;
@@ -1440,6 +1448,7 @@ static void mld_sendpack(struct sk_buff 
 			      (struct mld2_report *)skb_transport_header(skb);
 	int payload_len, mldlen;
 	struct inet6_dev *idev = in6_dev_get(skb->dev);
+	struct net *net = skb->dev->nd_net;
 	int err;
 	struct flowi fl;
 
@@ -1459,7 +1468,7 @@ static void mld_sendpack(struct sk_buff 
 		goto err_out;
 	}
 
-	icmpv6_flow_init(igmp6_socket->sk, &fl, ICMPV6_MLD2_REPORT,
+	icmpv6_flow_init(net->ipv6.igmp_sk, &fl, ICMPV6_MLD2_REPORT,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
@@ -1753,7 +1762,8 @@ static void mld_send_cr(struct inet6_dev
 
 static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 {
-	struct sock *sk = igmp6_socket->sk;
+	struct net *net = dev->nd_net;
+	struct sock *sk = net->ipv6.igmp_sk;
 	struct inet6_dev *idev;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
@@ -1824,7 +1834,7 @@ static void igmp6_send(struct in6_addr *
 		goto err_out;
 	}
 
-	icmpv6_flow_init(igmp6_socket->sk, &fl, type,
+	icmpv6_flow_init(sk, &fl, type,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
 
@@ -2334,6 +2344,7 @@ void ipv6_mc_destroy_dev(struct inet6_de
 
 #ifdef CONFIG_PROC_FS
 struct igmp6_mc_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct inet6_dev *idev;
 };
@@ -2344,9 +2355,10 @@ static inline struct ifmcaddr6 *igmp6_mc
 {
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mc_iter_state *state = igmp6_mc_seq_private(seq);
+	struct net *net = state->p.net;
 
 	state->idev = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (!idev)
@@ -2448,8 +2460,8 @@ static const struct seq_operations igmp6
 
 static int igmp6_mc_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp6_mc_seq_ops,
-			sizeof(struct igmp6_mc_iter_state));
+	return seq_open_net(inode, file, &igmp6_mc_seq_ops,
+			    sizeof(struct igmp6_mc_iter_state));
 }
 
 static const struct file_operations igmp6_mc_seq_fops = {
@@ -2457,10 +2469,11 @@ static const struct file_operations igmp
 	.open		=	igmp6_mc_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 
 struct igmp6_mcf_iter_state {
+	struct seq_net_private p;
 	struct net_device *dev;
 	struct inet6_dev *idev;
 	struct ifmcaddr6 *im;
@@ -2473,10 +2486,11 @@ static inline struct ip6_sf_list *igmp6_
 	struct ip6_sf_list *psf = NULL;
 	struct ifmcaddr6 *im = NULL;
 	struct igmp6_mcf_iter_state *state = igmp6_mcf_seq_private(seq);
+	struct net *net = state->p.net;
 
 	state->idev = NULL;
 	state->im = NULL;
-	for_each_netdev(&init_net, state->dev) {
+	for_each_netdev(net, state->dev) {
 		struct inet6_dev *idev;
 		idev = in6_dev_get(state->dev);
 		if (unlikely(idev == NULL))
@@ -2608,8 +2622,8 @@ static const struct seq_operations igmp6
 
 static int igmp6_mcf_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &igmp6_mcf_seq_ops,
-			sizeof(struct igmp6_mcf_iter_state));
+	return seq_open_net(inode, file, &igmp6_mcf_seq_ops,
+			    sizeof(struct igmp6_mcf_iter_state));
 }
 
 static const struct file_operations igmp6_mcf_seq_fops = {
@@ -2617,26 +2631,27 @@ static const struct file_operations igmp
 	.open		=	igmp6_mcf_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release_private,
+	.release	=	seq_release_net,
 };
 #endif
 
-int __init igmp6_init(void)
+static int igmp6_net_init(struct net *net)
 {
 	struct ipv6_pinfo *np;
+	struct socket *sock;
 	struct sock *sk;
 	int err;
 
-	err = sock_create_kern(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &igmp6_socket);
+	err = sock_create_kern(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &sock);
 	if (err < 0) {
 		printk(KERN_ERR
 		       "Failed to initialize the IGMP6 control socket (err %d).\n",
 		       err);
-		igmp6_socket = NULL; /* For safety. */
-		return err;
+		goto out;
 	}
 
-	sk = igmp6_socket->sk;
+	net->ipv6.igmp_sk = sk = sock->sk;
+	sk_change_net(sk, net);
 	sk->sk_allocation = GFP_ATOMIC;
 	sk->sk_prot->unhash(sk);
 
@@ -2644,20 +2659,45 @@ int __init igmp6_init(void)
 	np->hop_limit = 1;
 
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops);
-	proc_net_fops_create(&init_net, "mcfilter6", S_IRUGO, &igmp6_mcf_seq_fops);
+	err = -ENOMEM;
+	if (!proc_net_fops_create(net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops))
+		goto out_sock_create;
+	if (!proc_net_fops_create(net, "mcfilter6", S_IRUGO,
+				  &igmp6_mcf_seq_fops)) {
+		proc_net_remove(net, "igmp6");
+		goto out_sock_create;
+	}
 #endif
 
-	return 0;
+	err = 0;
+out:
+	return err;
+
+out_sock_create:
+	sk_release_kernel(net->ipv6.igmp_sk);
+	goto out;
 }
 
-void igmp6_cleanup(void)
+static void igmp6_net_exit(struct net *net)
 {
-	sock_release(igmp6_socket);
-	igmp6_socket = NULL; /* for safety */
-
+	sk_release_kernel(net->ipv6.igmp_sk);
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "mcfilter6");
-	proc_net_remove(&init_net, "igmp6");
+	proc_net_remove(net, "mcfilter6");
+	proc_net_remove(net, "igmp6");
 #endif
 }
+
+static struct pernet_operations igmp6_net_ops = {
+	.init = igmp6_net_init,
+	.exit = igmp6_net_exit,
+};
+
+int __init igmp6_init(void)
+{
+	return register_pernet_subsys(&igmp6_net_ops);
+}
+
+void igmp6_cleanup(void)
+{
+	unregister_pernet_subsys(&igmp6_net_ops);
+}
Index: net-2.6.26/net/ipv6/udp.c
===================================================================
--- net-2.6.26.orig/net/ipv6/udp.c
+++ net-2.6.26/net/ipv6/udp.c
@@ -323,6 +323,9 @@ static struct sock *udp_v6_mcast_next(st
 	sk_for_each_from(s, node) {
 		struct inet_sock *inet = inet_sk(s);
 
+		if (s->sk_net != sk->sk_net)
+			continue;
+
 		if (s->sk_hash == num && s->sk_family == PF_INET6) {
 			struct ipv6_pinfo *np = inet6_sk(s);
 			if (inet->dport) {

-- 
