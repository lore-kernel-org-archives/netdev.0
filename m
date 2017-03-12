From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 05/27] afnetns: ipv6 integration
Date: Mon, 13 Mar 2017 00:01:29 +0100
Message-ID: <20170312230151.5185-6-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48852 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935587AbdCLXCD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:03 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 3FF772060A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:57 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id A33A12436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:56 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like the previous IPv4 counterpart, this patch associates every IPv6
address with a corresponding afnet namespace. The namespace can be set
via file descriptor and the inode gets reported during dumping.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/if_inet6.h |  3 +++
 net/core/afnetns.c     |  3 +++
 net/ipv6/addrconf.c    | 70 +++++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 64 insertions(+), 12 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index f656f9051acafa..cad645851501f4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -41,6 +41,9 @@ enum {
 struct inet6_ifaddr {
 	struct in6_addr		addr;
 	__u32			prefix_len;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct afnetns		*afnetns;
+#endif
 
 	/* In seconds, relative to tstamp. Expiry is at tstamp + HZ * lft. */
 	__u32			valid_lft;
diff --git a/net/core/afnetns.c b/net/core/afnetns.c
index 12b823ae780796..b96c25b5ebe30d 100644
--- a/net/core/afnetns.c
+++ b/net/core/afnetns.c
@@ -56,6 +56,7 @@ void afnetns_free(struct afnetns *afnetns)
 	put_net(afnetns->net);
 	kfree(afnetns);
 }
+EXPORT_SYMBOL(afnetns_free);
 
 struct afnetns *afnetns_get_by_fd(int fd)
 {
@@ -76,11 +77,13 @@ struct afnetns *afnetns_get_by_fd(int fd)
 	fput(file);
 	return afnetns;
 }
+EXPORT_SYMBOL(afnetns_get_by_fd);
 
 unsigned int afnetns_to_inode(struct afnetns *afnetns)
 {
 	return afnetns->ns.inum;
 }
+EXPORT_SYMBOL(afnetns_to_inode);
 
 struct afnetns *copy_afnet_ns(unsigned long flags, struct nsproxy *old)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c69768a5c4606..c67f6d3c5b9a7a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -910,7 +910,9 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 		return;
 	}
 	ip6_rt_put(ifp->rt);
-
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(ifp->afnetns);
+#endif
 	kfree_rcu(ifp, rcu);
 }
 
@@ -942,9 +944,10 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 /* On success it returns ifp with increased reference count */
 
 static struct inet6_ifaddr *
-ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
-	      const struct in6_addr *peer_addr, int pfxlen,
-	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft)
+__ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
+		const struct in6_addr *peer_addr, int pfxlen,
+		int scope, u32 flags, u32 valid_lft, u32 prefered_lft,
+		struct afnetns *afnetns)
 {
 	struct net *net = dev_net(idev->dev);
 	struct inet6_ifaddr *ifa = NULL;
@@ -1002,7 +1005,9 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->addr = *addr;
 	if (peer_addr)
 		ifa->peer_addr = *peer_addr;
-
+#if IS_ENABLED(CONFIG_AFNETNS)
+	ifa->afnetns = afnetns_get(afnetns);
+#endif
 	spin_lock_init(&ifa->lock);
 	INIT_DELAYED_WORK(&ifa->dad_work, addrconf_dad_work);
 	INIT_HLIST_NODE(&ifa->addr_lst);
@@ -1054,6 +1059,17 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	goto out2;
 }
 
+static struct inet6_ifaddr *ipv6_add_addr(struct inet6_dev *idev,
+					  const struct in6_addr *addr,
+					  const struct in6_addr *peer_addr,
+					  int pfxlen, int scope, u32 flags,
+					  u32 valid_lft, u32 prefered_lft)
+{
+	return __ipv6_add_addr(idev, addr, peer_addr, pfxlen, scope, flags,
+			       valid_lft, prefered_lft,
+			       net_afnetns(dev_net(idev->dev)));
+}
+
 enum cleanup_prefix_rt_t {
 	CLEANUP_PREFIX_RT_NOP,    /* no cleanup action for prefix route */
 	CLEANUP_PREFIX_RT_DEL,    /* delete the prefix route */
@@ -2741,7 +2757,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
 			  const struct in6_addr *pfx,
 			  const struct in6_addr *peer_pfx,
 			  unsigned int plen, __u32 ifa_flags,
-			  __u32 prefered_lft, __u32 valid_lft)
+			  __u32 prefered_lft, __u32 valid_lft,
+			  struct afnetns *afnetns)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -2799,8 +2816,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
 		prefered_lft = timeout;
 	}
 
-	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
-			    valid_lft, prefered_lft);
+	ifp = __ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
+			      valid_lft, prefered_lft, afnetns);
 
 	if (!IS_ERR(ifp)) {
 		if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {
@@ -2885,7 +2902,8 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 	rtnl_lock();
 	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr, NULL,
 			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
-			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
+			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME,
+			     net_afnetns(net));
 	rtnl_unlock();
 	return err;
 }
@@ -4502,6 +4520,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx, *peer_pfx;
 	struct inet6_ifaddr *ifa;
+	struct afnetns *afnetns = NULL;
 	struct net_device *dev;
 	u32 valid_lft = INFINITY_LIFE_TIME, preferred_lft = INFINITY_LIFE_TIME;
 	u32 ifa_flags;
@@ -4537,15 +4556,31 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
 		     IFA_F_NOPREFIXROUTE | IFA_F_MCAUTOJOIN;
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (tb[IFA_AFNETNS_FD]) {
+		int fd = nla_get_s32(tb[IFA_AFNETNS_FD]);
+
+		afnetns = afnetns_get_by_fd(fd);
+		if (IS_ERR(afnetns))
+			return PTR_ERR(afnetns);
+	} else {
+		afnetns = afnetns_get(net_afnetns(net));
+	}
+#else
+	if (tb[IFA_AFNETNS_FD])
+		return -EOPNOTSUPP;
+#endif
+
 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (!ifa) {
 		/*
 		 * It would be best to check for !NLM_F_CREATE here but
 		 * userspace already relies on not having to provide this.
 		 */
-		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
+		err =  inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
 				      ifm->ifa_prefixlen, ifa_flags,
-				      preferred_lft, valid_lft);
+				      preferred_lft, valid_lft, afnetns);
+		goto out;
 	}
 
 	if (nlh->nlmsg_flags & NLM_F_EXCL ||
@@ -4555,6 +4590,10 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		err = inet6_addr_modify(ifa, ifa_flags, preferred_lft, valid_lft);
 
 	in6_ifa_put(ifa);
+out:
+#if IS_ENABLED(CONFIG_AFNETNS)
+	afnetns_put(afnetns);
+#endif
 
 	return err;
 }
@@ -4603,7 +4642,8 @@ static inline int inet6_ifaddr_msgsize(void)
 	       + nla_total_size(16) /* IFA_LOCAL */
 	       + nla_total_size(16) /* IFA_ADDRESS */
 	       + nla_total_size(sizeof(struct ifa_cacheinfo))
-	       + nla_total_size(4)  /* IFA_FLAGS */;
+	       + nla_total_size(4)  /* IFA_FLAGS */
+	       + nla_total_size(4); /* IFA_AFNETNS_INODE */
 }
 
 static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
@@ -4655,6 +4695,12 @@ static int inet6_fill_ifaddr(struct sk_buff *skb, struct inet6_ifaddr *ifa,
 	if (nla_put_u32(skb, IFA_FLAGS, ifa->flags) < 0)
 		goto error;
 
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (nla_put_u32(skb, IFA_AFNETNS_INODE,
+			afnetns_to_inode(ifa->afnetns)))
+		goto error;
+#endif
+
 	nlmsg_end(skb, nlh);
 	return 0;
 
-- 
2.9.3
