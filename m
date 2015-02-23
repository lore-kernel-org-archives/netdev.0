From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH net-next v3 2/2] multicast: Extend ip address command to enable multicast group join/leave on IP level.
Date: Sun, 22 Feb 2015 22:26:54 -0800
Message-ID: <1424672814-2998-3-git-send-email-challa@noironetworks.com>
References: <1424672814-2998-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: eric.dumazet@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44435 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbbBWGnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 01:43:13 -0500
Received: by pdbnh10 with SMTP id nh10so23185746pdb.11
        for <netdev@vger.kernel.org>; Sun, 22 Feb 2015 22:43:13 -0800 (PST)
In-Reply-To: <1424672814-2998-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joining multicast group on ethernet level via "ip maddr" command would
not work if we have an Ethernet switch that does igmp snooping since
the switch would not replicate multicast packets on ports that did not
have IGMP reports for the multicast addresses.

Linux vxlan interfaces created via "ip link add vxlan" have the group option
that enables then to do the required join.

By extending ip address command with option "autojoin" we can get similar
functionality for openvswitch vxlan interfaces as well as other tunneling
mechanisms that need to receive multicast traffic. The kernel code is
structured similar to how the vxlan driver does a group join / leave.

example:
ip address add 224.1.1.10/24 dev eth5 autojoin
ip address del 224.1.1.10/24 dev eth5

This patch applies on top of
[PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
igmp v6: add __ipv6_sock_mc_join and __ipv6_sock_mc_drop

Signed-off-by: Madhu Challa <challa@noironetworks.com>
---
 include/net/netns/ipv4.h     |  1 +
 include/net/netns/ipv6.h     |  1 +
 include/uapi/linux/if_addr.h |  1 +
 net/ipv4/devinet.c           | 36 ++++++++++++++++++++++++++++++++++++
 net/ipv4/igmp.c              | 17 +++++++++++++++++
 net/ipv6/addrconf.c          | 39 ++++++++++++++++++++++++++++++++++++---
 net/ipv6/mcast.c             | 20 ++++++++++++++++----
 7 files changed, 108 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index dbe2254..9c1f01e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -47,6 +47,7 @@ struct netns_ipv4 {
 #endif
 	struct hlist_head	*fib_table_hash;
 	struct sock		*fibnl;
+	struct sock		*mc_autojoin_sock;
 
 	struct sock  * __percpu	*icmp_sk;
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 69ae41f..fd2cef8 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -67,6 +67,7 @@ struct netns_ipv6 {
 	struct sock             *ndisc_sk;
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
+	struct sock		*mc_autojoin_sock;
 #ifdef CONFIG_IPV6_MROUTE
 #ifndef CONFIG_IPV6_MROUTE_MULTIPLE_TABLES
 	struct mr6_table	*mrt6;
diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index dea10a8..40fdfea 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -50,6 +50,7 @@ enum {
 #define IFA_F_PERMANENT		0x80
 #define IFA_F_MANAGETEMPADDR	0x100
 #define IFA_F_NOPREFIXROUTE	0x200
+#define IFA_F_MCAUTOJOIN	0x400
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 3a8985c..ee56730 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -548,6 +548,26 @@ struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 	return NULL;
 }
 
+static int ip_mc_config(struct sock *sk, bool join, __be32 saddr, int ifindex)
+{
+	struct ip_mreqn mreq = {
+		.imr_multiaddr.s_addr = saddr,
+		.imr_ifindex = ifindex,
+	};
+	int ret;
+
+	ASSERT_RTNL();
+
+	lock_sock(sk);
+	if (join)
+		ret = __ip_mc_join_group(sk, &mreq);
+	else
+		ret = __ip_mc_leave_group(sk, &mreq);
+	release_sock(sk);
+
+	return ret;
+}
+
 static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -584,6 +604,11 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		    !inet_ifa_match(nla_get_be32(tb[IFA_ADDRESS]), ifa)))
 			continue;
 
+		if (ipv4_is_multicast(ifa->ifa_address)) {
+			ip_mc_config(net->ipv4.mc_autojoin_sock,
+				     false, ifa->ifa_address,
+				     ifa->ifa_dev->dev->ifindex);
+		}
 		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).portid);
 		return 0;
 	}
@@ -825,6 +850,7 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct in_ifaddr *ifa_existing;
 	__u32 valid_lft = INFINITY_LIFE_TIME;
 	__u32 prefered_lft = INFINITY_LIFE_TIME;
+	int ret;
 
 	ASSERT_RTNL();
 
@@ -838,6 +864,16 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		 * userspace already relies on not having to provide this.
 		 */
 		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
+		if (ifa->ifa_flags & IFA_F_MCAUTOJOIN) {
+			WARN_ON(!ipv4_is_multicast(ifa->ifa_address));
+			ret = ip_mc_config(net->ipv4.mc_autojoin_sock,
+					   true, ifa->ifa_address,
+					   ifa->ifa_dev->dev->ifindex);
+			if (ret < 0) {
+				inet_free_ifa(ifa);
+				return ret;
+			}
+		}
 		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
 	} else {
 		inet_free_ifa(ifa);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 4b1172d..15bb88d 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2740,6 +2740,8 @@ static const struct file_operations igmp_mcf_seq_fops = {
 static int __net_init igmp_net_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
+	struct socket *sock = NULL;
+	int err;
 
 	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
 	if (!pde)
@@ -2748,8 +2750,16 @@ static int __net_init igmp_net_init(struct net *net)
 			  &igmp_mcf_seq_fops);
 	if (!pde)
 		goto out_mcfilter;
+	err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
+	if (err < 0)
+		goto out_sock;
+	sk_change_net(sock->sk, net);
+	net->ipv4.mc_autojoin_sock = sock->sk;
+
 	return 0;
 
+out_sock:
+	remove_proc_entry("mcfilter", net->proc_net);
 out_mcfilter:
 	remove_proc_entry("igmp", net->proc_net);
 out_igmp:
@@ -2758,8 +2768,15 @@ out_igmp:
 
 static void __net_exit igmp_net_exit(struct net *net)
 {
+	struct sock *sk = net->ipv4.mc_autojoin_sock;
+
 	remove_proc_entry("mcfilter", net->proc_net);
 	remove_proc_entry("igmp", net->proc_net);
+	if (sk) {
+		kernel_sock_shutdown(sk->sk_socket, SHUT_RDWR);
+		sk_release_kernel(sk);
+		net->ipv4.mc_autojoin_sock = NULL;
+	}
 }
 
 static struct pernet_operations igmp_net_ops = {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 98e4a63..b9b6d52 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2464,6 +2464,23 @@ err_exit:
 	return err;
 }
 
+static int ipv6_mc_config(struct sock *sk, bool join,
+			  const struct in6_addr *addr, int ifindex)
+{
+	int ret;
+
+	ASSERT_RTNL();
+
+	lock_sock(sk);
+	if (join)
+		ret = __ipv6_sock_mc_join(sk, ifindex, addr);
+	else
+		ret = __ipv6_sock_mc_drop(sk, ifindex, addr);
+	release_sock(sk);
+
+	return ret;
+}
+
 /*
  *	Manual configuration of address on an interface
  */
@@ -2476,10 +2493,11 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
+	unsigned long timeout;
+	clock_t expires;
 	int scope;
 	u32 flags;
-	clock_t expires;
-	unsigned long timeout;
+	int ret;
 
 	ASSERT_RTNL();
 
@@ -2501,6 +2519,14 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	if (IS_ERR(idev))
 		return PTR_ERR(idev);
 
+	if (ifa_flags & IFA_F_MCAUTOJOIN) {
+		WARN_ON(!ipv6_addr_is_multicast(pfx));
+		ret = ipv6_mc_config(net->ipv6.mc_autojoin_sock,
+				     true, pfx, ifindex);
+		if (ret < 0)
+			return ret;
+	}
+
 	scope = ipv6_addr_scope(pfx);
 
 	timeout = addrconf_timeout_fixup(valid_lft, HZ);
@@ -2542,6 +2568,9 @@ static int inet6_addr_add(struct net *net, int ifindex,
 		in6_ifa_put(ifp);
 		addrconf_verify_rtnl();
 		return 0;
+	} else if (ifa_flags & IFA_F_MCAUTOJOIN) {
+		ipv6_mc_config(net->ipv6.mc_autojoin_sock,
+			       false, pfx, ifindex);
 	}
 
 	return PTR_ERR(ifp);
@@ -2578,6 +2607,10 @@ static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
 						 jiffies);
 			ipv6_del_addr(ifp);
 			addrconf_verify_rtnl();
+			if (ipv6_addr_is_multicast(pfx)) {
+				ipv6_mc_config(net->ipv6.mc_autojoin_sock,
+					       false, pfx, dev->ifindex);
+			}
 			return 0;
 		}
 	}
@@ -3945,7 +3978,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	/* We ignore other flags so far. */
 	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
-		     IFA_F_NOPREFIXROUTE;
+		     IFA_F_NOPREFIXROUTE | IFA_F_MCAUTOJOIN;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index f4a76b1..5b1261f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2930,20 +2930,32 @@ static int __net_init igmp6_net_init(struct net *net)
 
 	inet6_sk(net->ipv6.igmp_sk)->hop_limit = 1;
 
+	err = inet_ctl_sock_create(&net->ipv6.mc_autojoin_sock, PF_INET6,
+				   SOCK_RAW, IPPROTO_ICMPV6, net);
+	if (err < 0) {
+		pr_err("Failed to initialize the IGMP6 autojoin socket (err %d)\n",
+		       err);
+		goto out_sock_create;
+	}
+
 	err = igmp6_proc_init(net);
 	if (err)
-		goto out_sock_create;
-out:
-	return err;
+		goto out_sock_create_autojoin;
+
+	return 0;
 
+out_sock_create_autojoin:
+	inet_ctl_sock_destroy(net->ipv6.mc_autojoin_sock);
 out_sock_create:
 	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
-	goto out;
+out:
+	return err;
 }
 
 static void __net_exit igmp6_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
+	inet_ctl_sock_destroy(net->ipv6.mc_autojoin_sock);
 	igmp6_proc_exit(net);
 }
 
-- 
1.9.1
