From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 2/3] ipv4,ipv6: kill ip_mc_{join,leave}_group and ipv6_sock_mc_{join,drop}
Date: Wed, 18 Mar 2015 14:50:43 -0300
Message-ID: <4e10da321f4acaf728469dbebfe21416f7273356.1426700794.git.marcelo.leitner@gmail.com>
References: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Cc: hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169AbbCRRvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 13:51:25 -0400
In-Reply-To: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in favor of their inner __ ones, which doesn't grab rtnl.

As these functions need to operate on a locked socket, we can't be
grabbing rtnl by then. It's too late and doing so causes reversed
locking.

So this patch:
- move rtnl handling to callers instead while already fixing some
  reversed locking situations, like on vxlan and ipvs code.
- renames __ ones to not have the __ mark:
  __ip_mc_{join,leave}_group -> ip_mc_{join,leave}_group
  __ipv6_sock_mc_{join,drop} -> ipv6_sock_mc_{join,drop}

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/vxlan.c             |  5 ++++-
 include/linux/igmp.h            |  2 --
 include/net/ipv6.h              |  4 ----
 net/ipv4/devinet.c              |  4 ++--
 net/ipv4/igmp.c                 | 41 ++++++++---------------------------------
 net/ipv4/ip_sockglue.c          | 21 +++++++++++++++------
 net/ipv6/addrconf.c             |  4 ++--
 net/ipv6/ipv6_sockglue.c        | 21 +++++++++++++--------
 net/ipv6/mcast.c                | 30 +++---------------------------
 net/netfilter/ipvs/ip_vs_sync.c |  2 ++
 net/tipc/udp_media.c            |  4 ++--
 11 files changed, 51 insertions(+), 87 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e0a775ea882995d88127e4d3c2a8f3f0afb8d60..5ba58dda0e6240fbd108d268725a2185dd0bbadf 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1097,7 +1097,6 @@ EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
 /* Callback to update multicast group membership when first VNI on
  * multicast asddress is brought up
- * Done as workqueue because ip_mc_join_group acquires RTNL.
  */
 static void vxlan_igmp_join(struct work_struct *work)
 {
@@ -1107,6 +1106,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
+	rtnl_lock();
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
@@ -1122,6 +1122,7 @@ static void vxlan_igmp_join(struct work_struct *work)
 #endif
 	}
 	release_sock(sk);
+	rtnl_unlock();
 
 	vxlan_sock_release(vs);
 	dev_put(vxlan->dev);
@@ -1136,6 +1137,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	union vxlan_addr *ip = &vxlan->default_dst.remote_ip;
 	int ifindex = vxlan->default_dst.remote_ifindex;
 
+	rtnl_lock();
 	lock_sock(sk);
 	if (ip->sa.sa_family == AF_INET) {
 		struct ip_mreqn mreq = {
@@ -1152,6 +1154,7 @@ static void vxlan_igmp_leave(struct work_struct *work)
 	}
 
 	release_sock(sk);
+	rtnl_unlock();
 
 	vxlan_sock_release(vs);
 	dev_put(vxlan->dev);
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index b5a6470e686c436f619ee086cbdfc3ece389db35..2c677afeea4782c96b79d0d8ede4846d87783b99 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -111,9 +111,7 @@ struct ip_mc_list {
 
 extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
-extern int __ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
-extern int __ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern void ip_mc_drop_socket(struct sock *sk);
 extern int ip_mc_source(int add, int omode, struct sock *sk,
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index b7673065c074f10c20ec647d2cc895bffafa961a..e7ba9758a34564fd7ce75e5c7fe2e1816c9243df 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -942,10 +942,6 @@ void ipv6_sysctl_unregister(void);
 
 int ipv6_sock_mc_join(struct sock *sk, int ifindex,
 		      const struct in6_addr *addr);
-int __ipv6_sock_mc_join(struct sock *sk, int ifindex,
-			const struct in6_addr *addr);
 int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
 		      const struct in6_addr *addr);
-int __ipv6_sock_mc_drop(struct sock *sk, int ifindex,
-			const struct in6_addr *addr);
 #endif /* _NET_IPV6_H */
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5105759e4e00a5d4b7812bd6d7e098c7fb298506..bfae49bbe82824fe933d9f8549a59cc1aef74527 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -560,9 +560,9 @@ static int ip_mc_config(struct sock *sk, bool join, const struct in_ifaddr *ifa)
 
 	lock_sock(sk);
 	if (join)
-		ret = __ip_mc_join_group(sk, &mreq);
+		ret = ip_mc_join_group(sk, &mreq);
 	else
-		ret = __ip_mc_leave_group(sk, &mreq);
+		ret = ip_mc_leave_group(sk, &mreq);
 	release_sock(sk);
 
 	return ret;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 5cb1ef4ce292ed1abd5a591d8b6c08bfb1688c5f..ad3f866085def009d62a32d058bdd711ad1fcb0c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1850,7 +1850,10 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc)
 	pmc->sfcount[MCAST_EXCLUDE] = 1;
 }
 
-int __ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
+/* Join a multicast group
+ */
+
+int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	__be32 addr = imr->imr_multiaddr.s_addr;
 	struct ip_mc_socklist *iml, *i;
@@ -1898,20 +1901,6 @@ int __ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 done:
 	return err;
 }
-EXPORT_SYMBOL(__ip_mc_join_group);
-
-/* Join a multicast group
- */
-int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
-{
-	int ret;
-
-	rtnl_lock();
-	ret = __ip_mc_join_group(sk, imr);
-	rtnl_unlock();
-
-	return ret;
-}
 EXPORT_SYMBOL(ip_mc_join_group);
 
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
@@ -1934,7 +1923,7 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 	return err;
 }
 
-int __ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
@@ -1979,18 +1968,6 @@ int __ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 out:
 	return ret;
 }
-EXPORT_SYMBOL(__ip_mc_leave_group);
-
-int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
-{
-	int ret;
-
-	rtnl_lock();
-	ret = __ip_mc_leave_group(sk, imr);
-	rtnl_unlock();
-
-	return ret;
-}
 EXPORT_SYMBOL(ip_mc_leave_group);
 
 int ip_mc_source(int add, int omode, struct sock *sk, struct
@@ -2010,7 +1987,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
+	ASSERT_RTNL();
 
 	imr.imr_multiaddr.s_addr = mreqs->imr_multiaddr;
 	imr.imr_address.s_addr = mreqs->imr_interface;
@@ -2124,9 +2101,8 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
 		&mreqs->imr_sourceaddr, 1);
 done:
-	rtnl_unlock();
 	if (leavegroup)
-		return ip_mc_leave_group(sk, &imr);
+		err = ip_mc_leave_group(sk, &imr);
 	return err;
 }
 
@@ -2148,7 +2124,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	rtnl_lock();
+	ASSERT_RTNL();
 
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
@@ -2210,7 +2186,6 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	pmc->sfmode = msf->imsf_fmode;
 	err = 0;
 done:
-	rtnl_unlock();
 	if (leavegroup)
 		err = ip_mc_leave_group(sk, &imr);
 	return err;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5171709199f48588b7ba0f733b72ba2234d4c100..f6a0d54b308ac8a758724fab9bb92afddcfcb333 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -541,9 +541,18 @@ static bool setsockopt_needs_rtnl(int optname)
 	switch (optname) {
 	case IP_ADD_MEMBERSHIP:
 	case IP_ADD_SOURCE_MEMBERSHIP:
+	case IP_BLOCK_SOURCE:
 	case IP_DROP_MEMBERSHIP:
+	case IP_DROP_SOURCE_MEMBERSHIP:
+	case IP_MSFILTER:
+	case IP_UNBLOCK_SOURCE:
+	case MCAST_BLOCK_SOURCE:
+	case MCAST_MSFILTER:
 	case MCAST_JOIN_GROUP:
+	case MCAST_JOIN_SOURCE_GROUP:
 	case MCAST_LEAVE_GROUP:
+	case MCAST_LEAVE_SOURCE_GROUP:
+	case MCAST_UNBLOCK_SOURCE:
 		return true;
 	}
 	return false;
@@ -861,9 +870,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 
 		if (optname == IP_ADD_MEMBERSHIP)
-			err = __ip_mc_join_group(sk, &mreq);
+			err = ip_mc_join_group(sk, &mreq);
 		else
-			err = __ip_mc_leave_group(sk, &mreq);
+			err = ip_mc_leave_group(sk, &mreq);
 		break;
 	}
 	case IP_MSFILTER:
@@ -928,7 +937,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			mreq.imr_multiaddr.s_addr = mreqs.imr_multiaddr;
 			mreq.imr_address.s_addr = mreqs.imr_interface;
 			mreq.imr_ifindex = 0;
-			err = __ip_mc_join_group(sk, &mreq);
+			err = ip_mc_join_group(sk, &mreq);
 			if (err && err != -EADDRINUSE)
 				break;
 			omode = MCAST_INCLUDE;
@@ -960,9 +969,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		mreq.imr_ifindex = greq.gr_interface;
 
 		if (optname == MCAST_JOIN_GROUP)
-			err = __ip_mc_join_group(sk, &mreq);
+			err = ip_mc_join_group(sk, &mreq);
 		else
-			err = __ip_mc_leave_group(sk, &mreq);
+			err = ip_mc_leave_group(sk, &mreq);
 		break;
 	}
 	case MCAST_JOIN_SOURCE_GROUP:
@@ -1005,7 +1014,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			mreq.imr_multiaddr = psin->sin_addr;
 			mreq.imr_address.s_addr = 0;
 			mreq.imr_ifindex = greqs.gsr_interface;
-			err = __ip_mc_join_group(sk, &mreq);
+			err = ip_mc_join_group(sk, &mreq);
 			if (err && err != -EADDRINUSE)
 				break;
 			greqs.gsr_interface = mreq.imr_ifindex;
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 88d2cf0cae52fd9798ed709ff64dc9462252ecdc..158378e73f0ab26fe06c1d7b9834ee04c29e070e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2473,9 +2473,9 @@ static int ipv6_mc_config(struct sock *sk, bool join,
 
 	lock_sock(sk);
 	if (join)
-		ret = __ipv6_sock_mc_join(sk, ifindex, addr);
+		ret = ipv6_sock_mc_join(sk, ifindex, addr);
 	else
-		ret = __ipv6_sock_mc_drop(sk, ifindex, addr);
+		ret = ipv6_sock_mc_drop(sk, ifindex, addr);
 	release_sock(sk);
 
 	return ret;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index f2b731df8d7735a129a8619a4753dd0ab2c76d0d..cc5883791bac1b32e4bbf9c36ee30f4d078b7dde 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -124,6 +124,11 @@ static bool setsockopt_needs_rtnl(int optname)
 	case IPV6_DROP_MEMBERSHIP:
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
+	case MCAST_JOIN_SOURCE_GROUP:
+	case MCAST_LEAVE_SOURCE_GROUP:
+	case MCAST_BLOCK_SOURCE:
+	case MCAST_UNBLOCK_SOURCE:
+	case MCAST_MSFILTER:
 		return true;
 	}
 	return false;
@@ -597,9 +602,9 @@ done:
 			break;
 
 		if (optname == IPV6_ADD_MEMBERSHIP)
-			retv = __ipv6_sock_mc_join(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
+			retv = ipv6_sock_mc_join(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
 		else
-			retv = __ipv6_sock_mc_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
+			retv = ipv6_sock_mc_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
 		break;
 	}
 	case IPV6_JOIN_ANYCAST:
@@ -638,11 +643,11 @@ done:
 		}
 		psin6 = (struct sockaddr_in6 *)&greq.gr_group;
 		if (optname == MCAST_JOIN_GROUP)
-			retv = __ipv6_sock_mc_join(sk, greq.gr_interface,
-						   &psin6->sin6_addr);
+			retv = ipv6_sock_mc_join(sk, greq.gr_interface,
+						 &psin6->sin6_addr);
 		else
-			retv = __ipv6_sock_mc_drop(sk, greq.gr_interface,
-						   &psin6->sin6_addr);
+			retv = ipv6_sock_mc_drop(sk, greq.gr_interface,
+						 &psin6->sin6_addr);
 		break;
 	}
 	case MCAST_JOIN_SOURCE_GROUP:
@@ -674,8 +679,8 @@ done:
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&greqs.gsr_group;
-			retv = __ipv6_sock_mc_join(sk, greqs.gsr_interface,
-						   &psin6->sin6_addr);
+			retv = ipv6_sock_mc_join(sk, greqs.gsr_interface,
+						 &psin6->sin6_addr);
 			/* prior join w/ different source is ok */
 			if (retv && retv != -EADDRINUSE)
 				break;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 1dd1fedff9f44fa9fe9eb590abd0bc873864c138..cbb66fd3da6d697520f48b143adad4838af3ed6a 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -132,7 +132,7 @@ static int unsolicited_report_interval(struct inet6_dev *idev)
 	return iv > 0 ? iv : 1;
 }
 
-int __ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
+int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct net_device *dev = NULL;
 	struct ipv6_mc_socklist *mc_lst;
@@ -199,24 +199,12 @@ int __ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *add
 
 	return 0;
 }
-EXPORT_SYMBOL(__ipv6_sock_mc_join);
-
-int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
-{
-	int ret;
-
-	rtnl_lock();
-	ret = __ipv6_sock_mc_join(sk, ifindex, addr);
-	rtnl_unlock();
-
-	return ret;
-}
 EXPORT_SYMBOL(ipv6_sock_mc_join);
 
 /*
  *	socket leave on multicast group
  */
-int __ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
+int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst;
@@ -255,18 +243,6 @@ int __ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *add
 
 	return -EADDRNOTAVAIL;
 }
-EXPORT_SYMBOL(__ipv6_sock_mc_drop);
-
-int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
-{
-	int ret;
-
-	rtnl_lock();
-	ret = __ipv6_sock_mc_drop(sk, ifindex, addr);
-	rtnl_unlock();
-
-	return ret;
-}
 EXPORT_SYMBOL(ipv6_sock_mc_drop);
 
 /* called with rcu_read_lock() */
@@ -460,7 +436,7 @@ done:
 	read_unlock_bh(&idev->lock);
 	rcu_read_unlock();
 	if (leavegroup)
-		return ipv6_sock_mc_drop(sk, pgsr->gsr_interface, group);
+		err = ipv6_sock_mc_drop(sk, pgsr->gsr_interface, group);
 	return err;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 08d95559b6f78e21fbacd3d400801f89a5335b4b..19b9cce6c210c425f3e577a22e0ac8c2e1c71804 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1405,9 +1405,11 @@ join_mcast_group(struct sock *sk, struct in_addr *addr, char *ifname)
 
 	mreq.imr_ifindex = dev->ifindex;
 
+	rtnl_lock();
 	lock_sock(sk);
 	ret = ip_mc_join_group(sk, &mreq);
 	release_sock(sk);
+	rtnl_unlock();
 
 	return ret;
 }
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index fc2fb11a354d063ac030cf0af0363866051a923a..04836dd70c2bb79906307ec40e0cbd7b2589978e 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -246,11 +246,11 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)
 			return 0;
 		mreqn.imr_multiaddr = remote->ipv4;
 		mreqn.imr_ifindex = ub->ifindex;
-		err = __ip_mc_join_group(sk, &mreqn);
+		err = ip_mc_join_group(sk, &mreqn);
 	} else {
 		if (!ipv6_addr_is_multicast(&remote->ipv6))
 			return 0;
-		err = __ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
+		err = ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
 	}
 	return err;
 }
-- 
1.9.3
