From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] ipv6: add support of peer address
Date: Tue, 30 Apr 2013 11:17:44 +0200
Message-ID: <1367313464-4338-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1367268252-4810-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:33944 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759627Ab3D3JRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 05:17:45 -0400
In-Reply-To: <1367268252-4810-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the support of peer address for IPv6. For example, it is
possible to specify the remote end of a 6inY tunnel.
This was already possible in IPv4:
 ip addr add ip1 peer ip2 dev dev1

The peer address is specified with IFA_ADDRESS and the local address with
IFA_LOCAL (like explained in include/uapi/linux/if_addr.h).
Note that the API is not changed, because before this patch, it was not
possible to specify two different addresses in IFA_LOCAL and IFA_REMOTE.
There is a small change for the dump: if the peer is different from ::,
IFA_ADDRESS will contain the peer address instead of the local address.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that iproute2 is already able to add addr like this (but needs a small
fix for the display, I will send it when the patch is merged):
$ ip tunnel add mode sit remote 192.168.123.2 local 192.168.123.1
$ ip -6 addr add 2003::1 peer 2003::2 dev sit1
$ ip addr list dev sit1
6: sit1: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN
    link/sit 192.168.123.1 peer 192.168.123.2
    inet6 2003::1 peer 2003::2/128 scope global
       valid_lft forever preferred_lft forever

v2: fix skb size calculation in inet6_ifaddr_msgsize()

 include/net/if_inet6.h |  1 +
 net/ipv6/addrconf.c    | 64 ++++++++++++++++++++++++++++++++++++--------------
 2 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 100fb8c..0727d0e 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -74,6 +74,7 @@ struct inet6_ifaddr {
 	bool			tokenized;
 
 	struct rcu_head		rcu;
+	struct in6_addr		peer_addr;
 };
 
 struct ip6_sf_socklist {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d1ab6ab..d684d23 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2402,6 +2402,7 @@ err_exit:
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *pfx,
+			  const struct in6_addr *peer_pfx,
 			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
 			  __u32 valid_lft)
 {
@@ -2457,6 +2458,8 @@ static int inet6_addr_add(struct net *net, int ifindex, const struct in6_addr *p
 		ifp->valid_lft = valid_lft;
 		ifp->prefered_lft = prefered_lft;
 		ifp->tstamp = jiffies;
+		if (peer_pfx)
+			ifp->peer_addr = *peer_pfx;
 		spin_unlock_bh(&ifp->lock);
 
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
@@ -2526,7 +2529,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 		return -EFAULT;
 
 	rtnl_lock();
-	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
+	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr, NULL,
 			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
 			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	rtnl_unlock();
@@ -3610,18 +3613,20 @@ restart:
 	rcu_read_unlock_bh();
 }
 
-static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local)
+static struct in6_addr *extract_addr(struct nlattr *addr, struct nlattr *local,
+				     struct in6_addr **peer_pfx)
 {
 	struct in6_addr *pfx = NULL;
 
+	*peer_pfx = NULL;
+
 	if (addr)
 		pfx = nla_data(addr);
 
 	if (local) {
 		if (pfx && nla_memcmp(local, pfx, sizeof(*pfx)))
-			pfx = NULL;
-		else
-			pfx = nla_data(local);
+			*peer_pfx = pfx;
+		pfx = nla_data(local);
 	}
 
 	return pfx;
@@ -3639,7 +3644,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
-	struct in6_addr *pfx;
+	struct in6_addr *pfx, *peer_pfx;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3647,7 +3652,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 
 	ifm = nlmsg_data(nlh);
-	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
+	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer_pfx);
 	if (pfx == NULL)
 		return -EINVAL;
 
@@ -3705,7 +3710,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net *net = sock_net(skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
-	struct in6_addr *pfx;
+	struct in6_addr *pfx, *peer_pfx;
 	struct inet6_ifaddr *ifa;
 	struct net_device *dev;
 	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
@@ -3717,7 +3722,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return err;
 
 	ifm = nlmsg_data(nlh);
-	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
+	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer_pfx);
 	if (pfx == NULL)
 		return -EINVAL;
 
@@ -3745,7 +3750,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		 * It would be best to check for !NLM_F_CREATE here but
 		 * userspace alreay relies on not having to provide this.
 		 */
-		return inet6_addr_add(net, ifm->ifa_index, pfx,
+		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
 				      ifm->ifa_prefixlen, ifa_flags,
 				      preferred_lft, valid_lft);
 	}
@@ -3802,6 +3807,7 @@ static inline int rt_scope(int ifa_scope)
 static inline int inet6_ifaddr_msgsize(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifaddrmsg))
+	       + nla_total_size(16) /* IFA_LOCAL */
 	       + nla_total_size(16) /* IFA_ADDRESS */
 	       + nla_total_size(sizeof(struct ifa_cacheinfo));
 }
@@ -3840,13 +3846,22 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 		valid = INFINITY_LIFE_TIME;
 	}
 
-	if (nla_put(skb, IFA_ADDRESS, 16, &ifa->addr) < 0 ||
-	    put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0) {
-		nlmsg_cancel(skb, nlh);
-		return -EMSGSIZE;
-	}
+	if (ipv6_addr_type(&ifa->peer_addr) != IPV6_ADDR_ANY) {
+		if (nla_put(skb, IFA_LOCAL, 16, &ifa->addr) < 0 ||
+		    nla_put(skb, IFA_ADDRESS, 16, &ifa->peer_addr) < 0)
+			goto error;
+	} else
+		if (nla_put(skb, IFA_ADDRESS, 16, &ifa->addr) < 0)
+			goto error;
+
+	if (put_cacheinfo(skb, ifa->cstamp, ifa->tstamp, preferred, valid) < 0)
+		goto error;
 
 	return nlmsg_end(skb, nlh);
+
+error:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
 }
 
 static int inet6_fill_ifmcaddr(struct sk_buff *skb, struct ifmcaddr6 *ifmca,
@@ -4046,7 +4061,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	struct net *net = sock_net(in_skb->sk);
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
-	struct in6_addr *addr = NULL;
+	struct in6_addr *addr = NULL, *peer;
 	struct net_device *dev = NULL;
 	struct inet6_ifaddr *ifa;
 	struct sk_buff *skb;
@@ -4056,7 +4071,7 @@ static int inet6_rtm_getaddr(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	if (err < 0)
 		goto errout;
 
-	addr = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
+	addr = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL], &peer);
 	if (addr == NULL) {
 		err = -EINVAL;
 		goto errout;
@@ -4564,11 +4579,26 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 			ip6_ins_rt(ifp->rt);
 		if (ifp->idev->cnf.forwarding)
 			addrconf_join_anycast(ifp);
+		if (ipv6_addr_type(&ifp->peer_addr) != IPV6_ADDR_ANY)
+			addrconf_prefix_route(&ifp->peer_addr, 128,
+					      ifp->idev->dev, 0, 0);
 		break;
 	case RTM_DELADDR:
 		if (ifp->idev->cnf.forwarding)
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
+		if (ipv6_addr_type(&ifp->peer_addr) != IPV6_ADDR_ANY) {
+			struct rt6_info *rt;
+			struct net_device *dev = ifp->idev->dev;
+
+			rt = rt6_lookup(dev_net(dev), &ifp->peer_addr, NULL,
+					dev->ifindex, 1);
+			if (rt) {
+				dst_hold(&rt->dst);
+				if (ip6_del_rt(rt))
+					dst_free(&rt->dst);
+			}
+		}
 		dst_hold(&ifp->rt->dst);
 
 		if (ip6_del_rt(ifp->rt))
-- 
1.8.2.1
