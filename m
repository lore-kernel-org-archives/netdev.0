From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 2/4] ipv6 netns: Make several "global" sysctl
 variables namespace aware.
Date: Sun, 20 Jul 2008 14:21:28 +0900 (JST)
Message-ID: <20080720.142128.12704560.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32817 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbYGTFV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:21:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c      |    8 +++++---
 net/ipv6/anycast.c       |    2 +-
 net/ipv6/exthdrs.c       |    2 +-
 net/ipv6/ip6_input.c     |    2 +-
 net/ipv6/ip6_output.c    |    4 ++--
 net/ipv6/ipv6_sockglue.c |    2 +-
 net/ipv6/mcast.c         |    2 +-
 net/ipv6/ndisc.c         |   11 +++++++----
 net/ipv6/route.c         |    4 ++--
 9 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 30184e0..580ae50 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1863,6 +1863,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 		struct inet6_ifaddr * ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
+		struct net *net = dev_net(dev);
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
@@ -1881,7 +1882,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 
 ok:
 
-		ifp = ipv6_get_ifaddr(dev_net(dev), &addr, dev, 1);
+		ifp = ipv6_get_ifaddr(net, &addr, dev, 1);
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
@@ -1889,7 +1890,7 @@ ok:
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
-			    !ipv6_devconf.forwarding)
+			    !net->ipv6.devconf_all->forwarding)
 				addr_flags = IFA_F_OPTIMISTIC;
 #endif
 
@@ -2314,11 +2315,12 @@ static void init_loopback(struct net_device *dev)
 static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr)
 {
 	struct inet6_ifaddr * ifp;
+	struct net *net = dev_net(idev->dev);
 	u32 addr_flags = IFA_F_PERMANENT;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	if (idev->cnf.optimistic_dad &&
-	    !ipv6_devconf.forwarding)
+	    !net->ipv6.devconf_all->forwarding)
 		addr_flags |= IFA_F_OPTIMISTIC;
 #endif
 
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 4e1b29f..8336cd8 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -60,7 +60,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 	struct inet6_dev *idev;
 	struct ipv6_ac_socklist *pac;
 	struct net *net = sock_net(sk);
-	int	ishost = !ipv6_devconf.forwarding;
+	int	ishost = !net->ipv6.devconf_all->forwarding;
 	int	err = 0;
 
 	if (!capable(CAP_NET_ADMIN))
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 9f1084b..837c830 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -319,7 +319,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	int n, i;
 	struct ipv6_rt_hdr *hdr;
 	struct rt0_hdr *rthdr;
-	int accept_source_route = ipv6_devconf.accept_source_route;
+	int accept_source_route = dev_net(skb->dev)->ipv6.devconf_all->accept_source_route;
 
 	idev = in6_dev_get(skb->dev);
 	if (idev) {
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index ea81c61..7e14ccc 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -249,7 +249,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	/*
 	 *      IPv6 multicast router mode is now supported ;)
 	 */
-	if (ipv6_devconf.mc_forwarding &&
+	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
 	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
 		/*
 		 * Okay, we try to forward - split and duplicate
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 0981c1e..6407c64 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -411,7 +411,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
 
-	if (ipv6_devconf.forwarding == 0)
+	if (net->ipv6.devconf_all->forwarding == 0)
 		goto error;
 
 	if (skb_warn_if_lro(skb))
@@ -458,7 +458,7 @@ int ip6_forward(struct sk_buff *skb)
 	}
 
 	/* XXX: idev->cnf.proxy_ndp? */
-	if (ipv6_devconf.proxy_ndp &&
+	if (net->ipv6.devconf_all->proxy_ndp &&
 	    pneigh_lookup(&nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
 		if (proxied > 0)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 8c6ea07..ea33b26 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1038,7 +1038,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 			dst_release(dst);
 		}
 		if (val < 0)
-			val = ipv6_devconf.hop_limit;
+			val = sock_net(sk)->ipv6.devconf_all->hop_limit;
 		break;
 	}
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bd2fe4c..1b28537 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -151,7 +151,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 #define IGMP6_UNSOLICITED_IVAL	(10*HZ)
 #define MLD_QRV_DEFAULT		2
 
-#define MLD_V1_SEEN(idev) (ipv6_devconf.force_mld_version == 1 || \
+#define MLD_V1_SEEN(idev) (dev_net((idev)->dev)->ipv6.devconf_all->force_mld_version == 1 || \
 		(idev)->cnf.force_mld_version == 1 || \
 		((idev)->mc_v1_seen && \
 		time_before(jiffies, (idev)->mc_v1_seen)))
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 282fdb3..beb48e3 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -784,15 +784,17 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 
 		idev = ifp->idev;
 	} else {
+		struct net *net = dev_net(dev);
+
 		idev = in6_dev_get(dev);
 		if (!idev) {
 			/* XXX: count this drop? */
 			return;
 		}
 
-		if (ipv6_chk_acast_addr(dev_net(dev), dev, &msg->target) ||
+		if (ipv6_chk_acast_addr(net, dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
-		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
+		     (net->ipv6.devconf_all->proxy_ndp || idev->cnf.proxy_ndp) &&
 		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
@@ -921,6 +923,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 
 	if (neigh) {
 		u8 old_flags = neigh->flags;
+		struct net *net = dev_net(dev);
 
 		if (neigh->nud_state & NUD_FAILED)
 			goto out;
@@ -931,8 +934,8 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		 * has already sent a NA to us.
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
-		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
-		    pneigh_lookup(&nd_tbl, dev_net(dev), &msg->target, dev, 0)) {
+		    net->ipv6.devconf_all->forwarding && net->ipv6.devconf_all->proxy_ndp &&
+		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.prixy_ndp */
 			goto out;
 		}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cb8a512..615b328 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -676,7 +676,7 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = ipv6_devconf.forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
+	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 
@@ -1058,7 +1058,7 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 			hoplimit = idev->cnf.hop_limit;
 			in6_dev_put(idev);
 		} else
-			hoplimit = ipv6_devconf.hop_limit;
+			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
 	}
 	return hoplimit;
 }
-- 
1.4.4.4

