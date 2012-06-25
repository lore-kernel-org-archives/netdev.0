From: <Menny_Hamburger@Dell.com>
Subject: [PATCH] net-next: ipv6: ndisc: allocate a ndisc socket per inet6_dev
Date: Mon, 25 Jun 2012 11:26:41 +0100
Message-ID: <D8C50530D6022F40A817A35C40CC06A70B34E34D44@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:21147 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab2FYK2v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 06:28:51 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: mennyh <Menny_Hamburger@Dell.com>

 When an IPV6 network discovery packet does not get sent by the NIC, 
 either because there is some S/W issue or a H/W problem with the NIC, NDP will stop
 working and will not be able to send ndisc packets via other NICs on the machine.
 The reason for this that there is only one global socket assigned per network for network discovery
 (net->ipv6.ndisc_sk), and  when this socket is busy, NDP cannot be serviced by 
 other NICS. 
 
 This patch adds a kernel configuration option IPV6_NDISC_SOCKET_PER_INTERFACE, 
 which when enabled the kernel will allocate a network discovery socket per inet6_dev on creation,
 instead of a single socket per network.

Signed-off-by: mennyh <Menny_Hamburger@Dell.com>
---
 include/net/if_inet6.h   |    3 +++
 include/net/ndisc.h      |    3 +++
 include/net/netns/ipv6.h |    2 ++
 net/ipv6/Kconfig         |    8 ++++++++
 net/ipv6/addrconf.c      |   22 +++++++++++++++++++++
 net/ipv6/ndisc.c         |   48 +++++++++++++++++++++++++++++++++++++++++++++-
 6 files changed, 85 insertions(+), 1 deletion(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 9356322..7134632 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -191,6 +191,9 @@ struct inet6_dev {
 	struct inet6_dev	*next;
 	struct ipv6_devconf	cnf;
 	struct ipv6_devstat	stats;
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	struct sock             *ndisc_sk;
+#endif
 	unsigned long		tstamp; /* ipv6InterfaceTable update timestamp */
 	struct rcu_head		rcu;
 };
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index c02b6ad..9039d6c 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -153,6 +153,9 @@ extern void			ndisc_send_skb(struct sk_buff *skb,
 					       const struct in6_addr *saddr,
 					       struct icmp6hdr *icmp6h);
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+extern int ndisc_socket_init(struct sock **ndisc_sk, struct net *net);
+#endif
 
 
 /*
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index df0a545..5d65d60 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -58,7 +58,9 @@ struct netns_ipv6 {
 	struct fib_rules_ops    *fib6_rules_ops;
 #endif
 	struct sock		**icmp_sk;
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	struct sock             *ndisc_sk;
+#endif
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
 #ifdef CONFIG_IPV6_MROUTE
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 5728695..77a09ff 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -250,4 +250,12 @@ config IPV6_PIMSM_V2
 	  Support for IPv6 PIM multicast routing protocol PIM-SMv2.
 	  If unsure, say N.
 
+config IPV6_NDISC_SOCKET_PER_INTERFACE
+	bool "IPv6: define socket for network discovery per interface (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  Normally only one socket per network is allocated to service the IPV6 network discovery protocol;
+	  This may cause NDP to stop working when ndisc packet is starved by a NIC due to S/W or H/W problems.
+	  If you say Y here, a separate socket will be allocated for each IPV6 enabled interface.
+
+	  If unsure, say N.
+
 endif # IPV6
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f6411c..8cbcb66 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -78,6 +78,9 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+#include <net/inet_common.h>
+#endif
 #include <linux/if_tunnel.h>
 #include <linux/rtnetlink.h>
 
@@ -336,6 +339,13 @@ void in6_dev_finish_destroy(struct inet6_dev *idev)
 		pr_warn("Freeing alive inet6 device %p\n", idev);
 		return;
 	}
+
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	if (idev->ndisc_sk) {
+		inet_ctl_sock_destroy(idev->ndisc_sk);
+		idev->ndisc_sk = NULL;
+	}
+#endif
 	snmp6_free_dev(idev);
 	kfree_rcu(idev, rcu);
 }
@@ -392,6 +402,18 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 		return NULL;
 	}
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	if (ndisc_socket_init(&ndev->ndisc_sk, dev_net(dev)) < 0) {
+		ADBG((KERN_WARNING
+			"%s(): cannot allocate network discovery socket\n"));
+		ndev->ndisc_sk = NULL;
+		neigh_parms_release(&nd_tbl, ndev->nd_parms);
+		ndev->dead = 1;
+		in6_dev_finish_destroy(ndev);
+		return NULL;
+	}
+#endif
+
 	/* One reference from device.  We must do this before
 	 * we invoke __ipv6_regen_rndid().
 	 */
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 69a6330..08f991b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -422,8 +422,12 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				const struct in6_addr *target,
 				int llinfo)
 {
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
+#else
+	struct sock *sk;
+#endif
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
 	int hlen = LL_RESERVED_SPACE(dev);
@@ -432,6 +436,10 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	int err;
 	u8 *opt;
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+        sk = in6_dev_get(dev)->ndisc_sk;
+#endif
+
 	if (!dev->addr_len)
 		llinfo = 0;
 
@@ -488,11 +496,19 @@ void ndisc_send_skb(struct sk_buff *skb,
 	struct flowi6 fl6;
 	struct dst_entry *dst;
 	struct net *net = dev_net(dev);
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	struct sock *sk = net->ipv6.ndisc_sk;
+#else
+	struct sock *sk;
+#endif
 	struct inet6_dev *idev;
 	int err;
 	u8 type;
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+        sk = in6_dev_get(dev)->ndisc_sk;
+#endif
+
 	type = icmp6h->icmp6_type;
 
 	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
@@ -550,6 +566,11 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	struct icmp6hdr icmp6h = {
 		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
 	};
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
+#else
+	struct sock *sk = in6_dev_get(dev)->ndisc_sk;
+#endif
 
 	/* for anycast or proxy, solicited_addr != src_addr */
 	ifp = ipv6_get_ifaddr(dev_net(dev), solicited_addr, dev, 1);
@@ -561,7 +582,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
-				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
+				       inet6_sk(sk)->srcprefs,
 				       &tmpaddr))
 			return;
 		src_addr = &tmpaddr;
@@ -1470,7 +1491,11 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 {
 	struct net_device *dev = skb->dev;
 	struct net *net = dev_net(dev);
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	struct sock *sk = net->ipv6.ndisc_sk;
+#else
+	struct sock *sk;
+#endif
 	int len = sizeof(struct icmp6hdr) + 2 * sizeof(struct in6_addr);
 	struct inet_peer *peer;
 	struct sk_buff *buff;
@@ -1487,6 +1512,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	sk = in6_dev_get(dev)->ndisc_sk;
+#endif
+
 	if (ipv6_get_lladdr(dev, &saddr_buf, IFA_F_TENTATIVE)) {
 		ND_PRINTK(2, warn, "Redirect: no link-local address on %s\n",
 			  dev->name);
@@ -1761,7 +1790,11 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 
 #endif
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+int ndisc_socket_init(struct sock **ndisc_sk, struct net *net)
+#else
 static int __net_init ndisc_net_init(struct net *net)
+#endif
 {
 	struct ipv6_pinfo *np;
 	struct sock *sk;
@@ -1776,7 +1809,11 @@ static int __net_init ndisc_net_init(struct net *net)
 		return err;
 	}
 
+#ifdef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
+	*ndisc_sk = sk;
+#else
 	net->ipv6.ndisc_sk = sk;
+#endif
 
 	np = inet6_sk(sk);
 	np->hop_limit = 255;
@@ -1786,6 +1823,7 @@ static int __net_init ndisc_net_init(struct net *net)
 	return 0;
 }
 :q!
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 static void __net_exit ndisc_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.ndisc_sk);
@@ -1795,14 +1833,18 @@ static struct pernet_operations ndisc_net_ops = {
 	.init = ndisc_net_init,
 	.exit = ndisc_net_exit,
 };
+#endif
 
 int __init ndisc_init(void)
 {
 	int err;
 
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	err = register_pernet_subsys(&ndisc_net_ops);
 	if (err)
 		return err;
+#endif
+
 	/*
 	 * Initialize the neighbour table
 	 */
@@ -1825,7 +1867,9 @@ out_unregister_sysctl:
 	neigh_sysctl_unregister(&nd_tbl.parms);
 out_unregister_pernet:
 #endif
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	unregister_pernet_subsys(&ndisc_net_ops);
+#endif
 	goto out;
 }
 
@@ -1836,5 +1880,7 @@ void ndisc_cleanup(void)
 	neigh_sysctl_unregister(&nd_tbl.parms);
 #endif
 	neigh_table_clear(&nd_tbl);
+#ifndef CONFIG_IPV6_NDISC_SOCKET_PER_INTERFACE
 	unregister_pernet_subsys(&ndisc_net_ops);
+#endif
 }
-- 
1.7.10.1
