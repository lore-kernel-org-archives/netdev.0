From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 3/6][NETNS][IPV6] ndisc - make socket control per namespace
Date: Fri, 07 Mar 2008 16:26:41 +0100
Message-ID: <20080307152940.291004856@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:40214 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762622AbYCGPaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:11 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m27FUA4l091590
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:10 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FUAKW1822762
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:10 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FU9eF032462
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:09 +0100
Content-Disposition: inline; filename=ndisc-make-ndisc-socket-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ndisc socket control per namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 
 net/ipv6/ndisc.c         |   77 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 54 insertions(+), 24 deletions(-)

Index: net-2.6.26/include/net/netns/ipv6.h
===================================================================
--- net-2.6.26.orig/include/net/netns/ipv6.h
+++ net-2.6.26/include/net/netns/ipv6.h
@@ -51,5 +51,6 @@ struct netns_ipv6 {
 	struct fib_rules_ops    *fib6_rules_ops;
 #endif
 	struct sock		**icmp_sk;
+	struct sock             *ndisc_sk;
 };
 #endif
Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -89,8 +89,6 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
-static struct socket *ndisc_socket;
-
 static u32 ndisc_hash(const void *pkey, const struct net_device *dev);
 static int ndisc_constructor(struct neighbour *neigh);
 static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb);
@@ -449,7 +447,8 @@ static void __ndisc_send(struct net_devi
 {
 	struct flowi fl;
 	struct dst_entry *dst;
-	struct sock *sk = ndisc_socket->sk;
+	struct net *net = dev->nd_net;
+	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
 	struct inet6_dev *idev;
@@ -459,8 +458,7 @@ static void __ndisc_send(struct net_devi
 
 	type = icmp6h->icmp6_type;
 
-	icmpv6_flow_init(ndisc_socket->sk, &fl, type,
-			 saddr, daddr, dev->ifindex);
+	icmpv6_flow_init(sk, &fl, type, saddr, daddr, dev->ifindex);
 
 	dst = icmp6_dst_alloc(dev, neigh, daddr);
 	if (!dst)
@@ -1394,13 +1392,14 @@ static void ndisc_redirect_rcv(struct sk
 void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 			 struct in6_addr *target)
 {
-	struct sock *sk = ndisc_socket->sk;
+	struct net_device *dev = skb->dev;
+	struct net *net = dev->nd_net;
+	struct sock *sk = net->ipv6.ndisc_sk;
 	int len = sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 	struct sk_buff *buff;
 	struct icmp6hdr *icmph;
 	struct in6_addr saddr_buf;
 	struct in6_addr *addrp;
-	struct net_device *dev;
 	struct rt6_info *rt;
 	struct dst_entry *dst;
 	struct inet6_dev *idev;
@@ -1411,8 +1410,6 @@ void ndisc_send_redirect(struct sk_buff 
 	int hlen;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 
-	dev = skb->dev;
-
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: no link-local address on %s\n",
@@ -1427,10 +1424,10 @@ void ndisc_send_redirect(struct sk_buff 
 		return;
 	}
 
-	icmpv6_flow_init(ndisc_socket->sk, &fl, NDISC_REDIRECT,
+	icmpv6_flow_init(sk, &fl, NDISC_REDIRECT,
 			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
 
-	dst = ip6_route_output(&init_net, NULL, &fl);
+	dst = ip6_route_output(net, NULL, &fl);
 	if (dst == NULL)
 		return;
 
@@ -1719,22 +1716,24 @@ static int ndisc_ifinfo_sysctl_strategy(
 
 #endif
 
-int __init ndisc_init(void)
+static int ndisc_net_init(struct net *net)
 {
+	struct socket *sock;
 	struct ipv6_pinfo *np;
 	struct sock *sk;
 	int err;
 
-	err = sock_create_kern(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &ndisc_socket);
+	err = sock_create_kern(PF_INET6, SOCK_RAW, IPPROTO_ICMPV6, &sock);
 	if (err < 0) {
 		ND_PRINTK0(KERN_ERR
 			   "ICMPv6 NDISC: Failed to initialize the control socket (err %d).\n",
 			   err);
-		ndisc_socket = NULL; /* For safety. */
 		return err;
 	}
 
-	sk = ndisc_socket->sk;
+	net->ipv6.ndisc_sk = sk = sock->sk;
+	sk_change_net(sk, net);
+
 	np = inet6_sk(sk);
 	sk->sk_allocation = GFP_ATOMIC;
 	np->hop_limit = 255;
@@ -1742,21 +1741,52 @@ int __init ndisc_init(void)
 	np->mc_loop = 0;
 	sk->sk_prot->unhash(sk);
 
+	return 0;
+}
+
+static void ndisc_net_exit(struct net *net)
+{
+	sk_release_kernel(net->ipv6.ndisc_sk);
+}
+
+static struct pernet_operations ndisc_net_ops = {
+	.init = ndisc_net_init,
+	.exit = ndisc_net_exit,
+};
+
+int __init ndisc_init(void)
+{
+	int err;
+
+	err = register_pernet_subsys(&ndisc_net_ops);
+	if (err)
+		return err;
 	/*
 	 * Initialize the neighbour table
 	 */
-
 	neigh_table_init(&nd_tbl);
 
 #ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH,
-			      "ipv6",
-			      &ndisc_ifinfo_sysctl_change,
-			      &ndisc_ifinfo_sysctl_strategy);
+	err = neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6,
+				    NET_IPV6_NEIGH, "ipv6",
+				    &ndisc_ifinfo_sysctl_change,
+				    &ndisc_ifinfo_sysctl_strategy);
+	if (err)
+		goto out_unregister_pernet;
 #endif
+	err = register_netdevice_notifier(&ndisc_netdev_notifier);
+	if (err)
+		goto out_unregister_sysctl;
+out:
+	return err;
 
-	register_netdevice_notifier(&ndisc_netdev_notifier);
-	return 0;
+out_unregister_sysctl:
+#ifdef CONFIG_SYSCTL
+	neigh_sysctl_unregister(&nd_tbl.parms);
+out_unregister_pernet:
+#endif
+	unregister_pernet_subsys(&ndisc_net_ops);
+	goto out;
 }
 
 void ndisc_cleanup(void)
@@ -1766,6 +1796,5 @@ void ndisc_cleanup(void)
 	neigh_sysctl_unregister(&nd_tbl.parms);
 #endif
 	neigh_table_clear(&nd_tbl);
-	sock_release(ndisc_socket);
-	ndisc_socket = NULL; /* For safety. */
+	unregister_pernet_subsys(&ndisc_net_ops);
 }

-- 
