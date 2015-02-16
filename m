From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH] multicast: Extend ip address command to enable multicast group join/leave on IP level.
Date: Mon, 16 Feb 2015 14:20:38 -0800
Message-ID: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:46142 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbbBPWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 17:36:11 -0500
Received: by pdjy10 with SMTP id y10so39145732pdj.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 14:36:10 -0800 (PST)
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

Signed-off-by: Madhu Challa <challa@noironetworks.com>
---
 include/net/ip.h             |  1 +
 include/net/ipv6.h           |  2 ++
 include/net/multicast.h      | 16 +++++++++++++
 include/net/netns/ipv4.h     |  1 +
 include/net/netns/ipv6.h     |  1 +
 include/uapi/linux/if_addr.h |  1 +
 net/ipv4/devinet.c           | 11 +++++++++
 net/ipv4/igmp.c              | 57 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c          | 11 ++++++++-
 net/ipv6/mcast.c             | 39 ++++++++++++++++++++++++++++++
 10 files changed, 139 insertions(+), 1 deletion(-)
 create mode 100644 include/net/multicast.h

diff --git a/include/net/ip.h b/include/net/ip.h
index 025c61c..e759bf4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -571,4 +571,5 @@ extern int sysctl_icmp_msgs_burst;
 int ip_misc_proc_init(void);
 #endif
 
+void ip_mc_config_async(struct sock *sk, bool join, __be32 saddr, int ifindex);
 #endif	/* _IP_H */
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4c9fe22..9da5537 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -940,4 +940,6 @@ int ipv6_sysctl_register(void);
 void ipv6_sysctl_unregister(void);
 #endif
 
+void ipv6_mc_config_async(struct sock *sk, bool join,
+			  const struct in6_addr *addr, int ifindex);
 #endif /* _NET_IPV6_H */
diff --git a/include/net/multicast.h b/include/net/multicast.h
new file mode 100644
index 0000000..eb0a70c
--- /dev/null
+++ b/include/net/multicast.h
@@ -0,0 +1,16 @@
+#ifndef _MULTICAST_H
+#define _MULTICAST_H
+
+struct mc_autojoin_request {
+	union {
+		struct sockaddr_in sin;
+		struct sockaddr_in6 sin6;
+	} addr;
+	int ifindex;
+	struct sock *sk;
+	struct work_struct ipv4_work;
+	struct work_struct ipv6_work;
+	bool join;
+};
+
+#endif
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
index f0b4a31..86888b0 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -584,6 +584,11 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		    !inet_ifa_match(nla_get_be32(tb[IFA_ADDRESS]), ifa)))
 			continue;
 
+		if (ipv4_is_multicast(ifa->ifa_address)) {
+			ip_mc_config_async(net->ipv4.mc_autojoin_sock,
+					   false, ifa->ifa_address,
+					   ifa->ifa_dev->dev->ifindex);
+		}
 		__inet_del_ifa(in_dev, ifap, 1, nlh, NETLINK_CB(skb).portid);
 		return 0;
 	}
@@ -838,6 +843,12 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		 * userspace already relies on not having to provide this.
 		 */
 		set_ifa_lifetime(ifa, valid_lft, prefered_lft);
+		if (ifa->ifa_flags & IFA_F_MCAUTOJOIN) {
+			WARN_ON(!ipv4_is_multicast(ifa->ifa_address));
+			ip_mc_config_async(net->ipv4.mc_autojoin_sock,
+					   true, ifa->ifa_address,
+					   ifa->ifa_dev->dev->ifindex);
+		}
 		return __inet_insert_ifa(ifa, nlh, NETLINK_CB(skb).portid);
 	} else {
 		inet_free_ifa(ifa);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 666cf36..0b3a000 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -105,6 +105,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #endif
+#include <net/multicast.h>
 
 #define IP_MAX_MEMBERSHIPS	20
 #define IP_MAX_MSF		10
@@ -1976,6 +1977,45 @@ out:
 }
 EXPORT_SYMBOL(ip_mc_leave_group);
 
+static void ip_mc_auto_join(struct work_struct *work)
+{
+	struct mc_autojoin_request *req =
+		container_of(work, struct mc_autojoin_request, ipv4_work);
+	struct ip_mreqn mreq = {
+		.imr_multiaddr.s_addr = req->addr.sin.sin_addr.s_addr,
+		.imr_ifindex = req->ifindex,
+	};
+
+	lock_sock(req->sk);
+	if (req->join)
+		ip_mc_join_group(req->sk, &mreq);
+	else
+		ip_mc_leave_group(req->sk, &mreq);
+	release_sock(req->sk);
+	sock_put(req->sk);
+	kfree(req);
+}
+
+void ip_mc_config_async(struct sock *sk, bool join, __be32 saddr,
+			int ifindex)
+{
+	struct mc_autojoin_request *req;
+	ASSERT_RTNL();
+
+	req = kzalloc(sizeof(*req), GFP_KERNEL);
+	if (!req)
+		return;
+
+	sock_hold(sk);
+	req->sk = sk;
+	req->addr.sin.sin_addr.s_addr = saddr;
+	req->ifindex = ifindex;
+	req->join = join;
+	INIT_WORK(&req->ipv4_work, ip_mc_auto_join);
+	schedule_work(&req->ipv4_work);
+}
+EXPORT_SYMBOL(ip_mc_config_async);
+
 int ip_mc_source(int add, int omode, struct sock *sk, struct
 	ip_mreq_source *mreqs, int ifindex)
 {
@@ -2724,6 +2764,8 @@ static const struct file_operations igmp_mcf_seq_fops = {
 static int __net_init igmp_net_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
+	int err;
+	struct socket *sock = NULL;
 
 	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
 	if (!pde)
@@ -2732,8 +2774,16 @@ static int __net_init igmp_net_init(struct net *net)
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
@@ -2742,8 +2792,15 @@ out_igmp:
 
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
index 98e4a63..572598b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2540,6 +2540,11 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			manage_tempaddrs(idev, ifp, valid_lft, prefered_lft,
 					 true, jiffies);
 		in6_ifa_put(ifp);
+		if (ifa_flags & IFA_F_MCAUTOJOIN) {
+			WARN_ON(!ipv6_addr_is_multicast(pfx));
+			ipv6_mc_config_async(net->ipv6.mc_autojoin_sock,
+					     true, pfx, ifindex);
+		}
 		addrconf_verify_rtnl();
 		return 0;
 	}
@@ -2578,6 +2583,10 @@ static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
 						 jiffies);
 			ipv6_del_addr(ifp);
 			addrconf_verify_rtnl();
+			if (ipv6_addr_is_multicast(pfx)) {
+				ipv6_mc_config_async(net->ipv6.mc_autojoin_sock,
+						     false, pfx, dev->ifindex);
+			}
 			return 0;
 		}
 	}
@@ -3945,7 +3954,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 	/* We ignore other flags so far. */
 	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
-		     IFA_F_NOPREFIXROUTE;
+		     IFA_F_NOPREFIXROUTE | IFA_F_MCAUTOJOIN;
 
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5ce107c..00fca26 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -63,6 +63,7 @@
 #include <net/inet_common.h>
 
 #include <net/ip6_checksum.h>
+#include <net/multicast.h>
 
 /* Ensure that we have struct in6_addr aligned on 32bit word. */
 static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
@@ -247,6 +248,44 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	return -EADDRNOTAVAIL;
 }
 
+static void ipv6_mc_auto_join(struct work_struct *work)
+{
+	struct mc_autojoin_request *req =
+		container_of(work, struct mc_autojoin_request, ipv6_work);
+
+	lock_sock(req->sk);
+	if (req->join)
+		ipv6_sock_mc_join(req->sk, req->ifindex,
+				  &req->addr.sin6.sin6_addr);
+	else
+		ipv6_sock_mc_drop(req->sk, req->ifindex,
+				  &req->addr.sin6.sin6_addr);
+	release_sock(req->sk);
+	sock_put(req->sk);
+	kfree(req);
+}
+
+
+void ipv6_mc_config_async(struct sock *sk, bool join,
+			  const struct in6_addr *addr, int ifindex)
+{
+	struct mc_autojoin_request *req;
+	ASSERT_RTNL();
+
+	req = kzalloc(sizeof(*req), GFP_KERNEL);
+	if (!req)
+		return;
+
+	sock_hold(sk);
+	req->sk = sk;
+	memcpy(&req->addr.sin6.sin6_addr, addr, sizeof(*addr));
+	req->ifindex = ifindex;
+	req->join = join;
+	INIT_WORK(&req->ipv6_work, ipv6_mc_auto_join);
+	schedule_work(&req->ipv6_work);
+}
+EXPORT_SYMBOL(ipv6_mc_config_async);
+
 /* called with rcu_read_lock() */
 static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
 					     const struct in6_addr *group,
-- 
1.9.1
