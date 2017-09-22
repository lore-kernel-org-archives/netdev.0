From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 08/11] net: implement local route cache inside ifaddr
Date: Fri, 22 Sep 2017 23:06:32 +0200
Message-ID: <f9d52b56b1c6fb8c671d23cfb0fc99bf36392239.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752747AbdIVVHM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:07:12 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add storage and helpers to associate an ipv{4,6} address
with the local route to self. This will be used by a
later patch to implement early demux for unconnected UDP
sockets.

The caches are filled on address creation, with DST_OBSOLETE_NONE.
Ipv6 cache are explicitly clearered and refreshed on underlaying
device down/up events.

The above schema is simpler than refreshing the cache every
time the dst expires under the default obsolete schema.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/inetdevice.h |  4 ++++
 include/net/addrconf.h     |  3 +++
 include/net/if_inet6.h     |  4 ++++
 net/ipv4/devinet.c         | 29 ++++++++++++++++++++++++++++-
 net/ipv6/addrconf.c        | 44 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 83 insertions(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 751d051f0bc7..c29982f178bb 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -130,6 +130,8 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
 
+struct dst_entry;
+
 struct in_ifaddr {
 	struct hlist_node	hash;
 	struct in_ifaddr	*ifa_next;
@@ -149,6 +151,7 @@ struct in_ifaddr {
 	__u32			ifa_preferred_lft;
 	unsigned long		ifa_cstamp; /* created timestamp */
 	unsigned long		ifa_tstamp; /* updated timestamp */
+	struct dst_entry	*dst; /* local route to self */
 };
 
 struct in_validator_info {
@@ -180,6 +183,7 @@ __be32 inet_confirm_addr(struct net *net, struct in_device *in_dev, __be32 dst,
 struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix,
 				    __be32 mask);
 struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr);
+struct dst_entry *inet_get_ifaddr_dst_rcu(struct net *net, __be32 addr);
 static __inline__ bool inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 87981cd63180..bdfa3306a4c5 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -87,6 +87,9 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net,
 				     const struct in6_addr *addr,
 				     struct net_device *dev, int strict);
 
+struct dst_entry *inet6_get_ifaddr_dst_rcu_bh(struct net *net,
+					      const struct in6_addr *addr);
+
 int ipv6_dev_get_saddr(struct net *net, const struct net_device *dev,
 		       const struct in6_addr *daddr, unsigned int srcprefs,
 		       struct in6_addr *saddr);
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index d4088d1a688d..1dd42e7c17a4 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -39,6 +39,8 @@ enum {
 	INET6_IFADDR_STATE_DEAD,
 };
 
+struct dst_entry;
+
 struct inet6_ifaddr {
 	struct in6_addr		addr;
 	__u32			prefix_len;
@@ -77,6 +79,8 @@ struct inet6_ifaddr {
 
 	struct rcu_head		rcu;
 	struct in6_addr		peer_addr;
+
+	struct dst_entry	*dst; /* local route to self */
 };
 
 struct ip6_sf_socklist {
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7ce22a2c07ce..a7748f787866 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -179,6 +179,17 @@ struct in_ifaddr *inet_lookup_ifaddr_rcu(struct net *net, __be32 addr)
 	return NULL;
 }
 
+/* called under RCU lock */
+struct dst_entry *inet_get_ifaddr_dst_rcu(struct net *net, __be32 addr)
+{
+	struct in_ifaddr *ifa = inet_lookup_ifaddr_rcu(net, addr);
+
+	if (!ifa)
+		return NULL;
+
+	return dst_access(&ifa->dst, 0);
+}
+
 static void rtmsg_ifa(int event, struct in_ifaddr *, struct nlmsghdr *, u32);
 
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
@@ -337,6 +348,7 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 	struct in_ifaddr *last_prim = in_dev->ifa_list;
 	struct in_ifaddr *prev_prom = NULL;
 	int do_promote = IN_DEV_PROMOTE_SECONDARIES(in_dev);
+	struct dst_entry *dst;
 
 	ASSERT_RTNL();
 
@@ -395,7 +407,12 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 	*ifap = ifa1->ifa_next;
 	inet_hash_remove(ifa1);
 
-	/* 3. Announce address deletion */
+	/* 3. Clear dst cache */
+
+	dst = xchg(&ifa1->dst, NULL);
+	dst_release(dst);
+
+	/* 4. Announce address deletion */
 
 	/* Send message first, then call notifier.
 	   At first sight, FIB update triggered by notifier
@@ -449,6 +466,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	struct in_device *in_dev = ifa->ifa_dev;
 	struct in_ifaddr *ifa1, **ifap, **last_primary;
 	struct in_validator_info ivi;
+	struct rtable *rt;
 	int ret;
 
 	ASSERT_RTNL();
@@ -516,6 +534,15 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	rtmsg_ifa(RTM_NEWADDR, ifa, nlh, portid);
 	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 
+	/* fill the dst cache and transfer the dst ownership to it */
+	rt = ip_local_route_alloc(in_dev->dev, 0, 0, RTN_LOCAL, false);
+	if (rt) {
+		/* the local route will be valid for till the address will be
+		 * up
+		 */
+		rt->dst.obsolete = DST_OBSOLETE_NONE;
+		__dst_update(&ifa->dst, &rt->dst);
+	}
 	return 0;
 }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5940062cac8d..5fa8d1b764ca 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -904,6 +904,26 @@ static int addrconf_fixup_linkdown(struct ctl_table *table, int *p, int newf)
 
 #endif
 
+static void inet6_addr_dst_clear(struct inet6_ifaddr *ifp)
+{
+	dst_release(xchg(&ifp->dst, NULL));
+}
+
+static void inet6_addr_dst_update(struct inet6_dev *idev,
+				  struct inet6_ifaddr *ifp)
+{
+	struct rt6_info *rt = addrconf_dst_alloc(idev, &ifp->addr, false);
+
+	if (IS_ERR(rt))
+		return;
+
+	/* we are going to manully clear the cache when the related dev will
+	 * go down
+	 */
+	rt->dst.obsolete = DST_OBSOLETE_NONE;
+	__dst_update(&ifp->dst, &rt->dst);
+}
+
 /* Nobody refers to this ifaddr, destroy it */
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
@@ -914,6 +934,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 #endif
 
 	in6_dev_put(ifp->idev);
+	inet6_addr_dst_clear(ifp);
 
 	if (cancel_delayed_work(&ifp->dad_work))
 		pr_notice("delayed DAD work was pending while freeing ifa=%p\n",
@@ -1907,6 +1928,18 @@ int ipv6_chk_prefix(const struct in6_addr *addr, struct net_device *dev)
 }
 EXPORT_SYMBOL(ipv6_chk_prefix);
 
+/* called under RCU lock */
+struct dst_entry *inet6_get_ifaddr_dst_rcu_bh(struct net *net,
+					      const struct in6_addr *addr)
+{
+	struct inet6_ifaddr *ifp = ipv6_lookup_ifaddr_rcu_bh(net, addr);
+
+	if (!ifp)
+		return NULL;
+
+	return dst_access(&ifp->dst, 0);
+}
+
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
@@ -3300,6 +3333,15 @@ static int fixup_permanent_addr(struct inet6_dev *idev,
 		ifp->rt = rt;
 		spin_unlock(&ifp->lock);
 
+		/* if dad is not going to start, we must cache the new route
+		 * elsewhere we can just clear the old one
+		 */
+		if (ifp->state == INET6_IFADDR_STATE_PREDAD ||
+		    ifp->flags & IFA_F_TENTATIVE)
+			inet6_addr_dst_clear(ifp);
+		else
+			inet6_addr_dst_update(idev, ifp);
+
 		ip6_rt_put(prev);
 	}
 
@@ -3679,6 +3721,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 		spin_unlock_bh(&ifa->lock);
 
+		inet6_addr_dst_clear(ifa);
 		if (rt)
 			ip6_del_rt(rt);
 
@@ -4009,6 +4052,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp, bool bump_id)
 	 */
 
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
+	inet6_addr_dst_update(ifp->idev, ifp);
 
 	/* If added prefix is link local and we are prepared to process
 	   router advertisements, start sending router solicitations.
-- 
2.13.5
