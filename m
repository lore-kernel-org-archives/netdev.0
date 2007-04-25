From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PATCH] [net-2.6.22] IPv6, IPv4 Updates
Date: Wed, 25 Apr 2007 21:55:21 +0900 (JST)
Message-ID: <20070425.215521.118284577.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32998 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030881AbXDYMzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 08:55:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider pulling following commits available on
	net-2.6.22-20070425a-inet6-cleanup-20070425
branch at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.

HEADLINES
---------

    [IPV6] SIT: Unify code path to get hash array index.
    [IPV4] IPIP: Unify code path to get hash array index.
    [IPV4] IP_GRE: Unify code path to get hash array index.
    [IPV6]: Export in6addr_any for future use.
    [IPV6] XFRM: Use ip6addr_any where applicable.
    [IPV6] NDISC: Unify main process of sending ND messages.

DIFFSTAT
--------

 include/linux/in6.h    |    2 
 net/ipv4/ip_gre.c      |   23 ++--
 net/ipv4/ipip.c        |   22 +---
 net/ipv6/addrconf.c    |    2 
 net/ipv6/ndisc.c       |  283 ++++++++++++++----------------------------------
 net/ipv6/sit.c         |   23 ++--
 net/ipv6/xfrm6_input.c |    4 -
 7 files changed, 112 insertions(+), 247 deletions(-)

CHANGESETS
----------

commit ed808452811f1b5b55727ab6c5336a488d5689b4
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:47 2007 +0900

    [IPV6] SIT: Unify code path to get hash array index.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 27fe10f..1efa95a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -99,10 +99,10 @@ static struct ip_tunnel * ipip6_tunnel_lookup(__be32 remote, __be32 local)
 	return NULL;
 }
 
-static struct ip_tunnel ** ipip6_bucket(struct ip_tunnel *t)
+static struct ip_tunnel **__ipip6_bucket(struct ip_tunnel_parm *parms)
 {
-	__be32 remote = t->parms.iph.daddr;
-	__be32 local = t->parms.iph.saddr;
+	__be32 remote = parms->iph.daddr;
+	__be32 local = parms->iph.saddr;
 	unsigned h = 0;
 	int prio = 0;
 
@@ -117,6 +117,11 @@ static struct ip_tunnel ** ipip6_bucket(struct ip_tunnel *t)
 	return &tunnels[prio][h];
 }
 
+static inline struct ip_tunnel **ipip6_bucket(struct ip_tunnel *t)
+{
+	return __ipip6_bucket(&t->parms);
+}
+
 static void ipip6_tunnel_unlink(struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp;
@@ -147,19 +152,9 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int
 	__be32 local = parms->iph.saddr;
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
-	unsigned h = 0;
-	int prio = 0;
 	char name[IFNAMSIZ];
 
-	if (remote) {
-		prio |= 2;
-		h ^= HASH(remote);
-	}
-	if (local) {
-		prio |= 1;
-		h ^= HASH(local);
-	}
-	for (tp = &tunnels[prio][h]; (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip6_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
 			return t;
 	}

---
commit 2f66586f53dd6319323c7d0c6ac0d4a4fb522865
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:47 2007 +0900

    [IPV4] IPIP: Unify code path to get hash array index.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 37ab391..ebd2f2d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -157,10 +157,10 @@ static struct ip_tunnel * ipip_tunnel_lookup(__be32 remote, __be32 local)
 	return NULL;
 }
 
-static struct ip_tunnel **ipip_bucket(struct ip_tunnel *t)
+static struct ip_tunnel **__ipip_bucket(struct ip_tunnel_parm *parms)
 {
-	__be32 remote = t->parms.iph.daddr;
-	__be32 local = t->parms.iph.saddr;
+	__be32 remote = parms->iph.daddr;
+	__be32 local = parms->iph.saddr;
 	unsigned h = 0;
 	int prio = 0;
 
@@ -175,6 +175,10 @@ static struct ip_tunnel **ipip_bucket(struct ip_tunnel *t)
 	return &tunnels[prio][h];
 }
 
+static inline struct ip_tunnel **ipip_bucket(struct ip_tunnel *t)
+{
+	return __ipip_bucket(&t->parms);
+}
 
 static void ipip_tunnel_unlink(struct ip_tunnel *t)
 {
@@ -206,19 +210,9 @@ static struct ip_tunnel * ipip_tunnel_locate(struct ip_tunnel_parm *parms, int c
 	__be32 local = parms->iph.saddr;
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
-	unsigned h = 0;
-	int prio = 0;
 	char name[IFNAMSIZ];
 
-	if (remote) {
-		prio |= 2;
-		h ^= HASH(remote);
-	}
-	if (local) {
-		prio |= 1;
-		h ^= HASH(local);
-	}
-	for (tp = &tunnels[prio][h]; (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipip_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr)
 			return t;
 	}

---
commit e8b22bea08420e24a09e32972f455c21206fe102
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:48 2007 +0900

    [IPV4] IP_GRE: Unify code path to get hash array index.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f49afaa..6328293 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -191,11 +191,11 @@ static struct ip_tunnel * ipgre_tunnel_lookup(__be32 remote, __be32 local, __be3
 	return NULL;
 }
 
-static struct ip_tunnel **ipgre_bucket(struct ip_tunnel *t)
+static struct ip_tunnel **__ipgre_bucket(struct ip_tunnel_parm *parms)
 {
-	__be32 remote = t->parms.iph.daddr;
-	__be32 local = t->parms.iph.saddr;
-	__be32 key = t->parms.i_key;
+	__be32 remote = parms->iph.daddr;
+	__be32 local = parms->iph.saddr;
+	__be32 key = parms->i_key;
 	unsigned h = HASH(key);
 	int prio = 0;
 
@@ -209,6 +209,11 @@ static struct ip_tunnel **ipgre_bucket(struct ip_tunnel *t)
 	return &tunnels[prio][h];
 }
 
+static inline struct ip_tunnel **ipgre_bucket(struct ip_tunnel *t)
+{
+	return __ipgre_bucket(&t->parms);
+}
+
 static void ipgre_tunnel_link(struct ip_tunnel *t)
 {
 	struct ip_tunnel **tp = ipgre_bucket(t);
@@ -240,17 +245,9 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
 	__be32 key = parms->i_key;
 	struct ip_tunnel *t, **tp, *nt;
 	struct net_device *dev;
-	unsigned h = HASH(key);
-	int prio = 0;
 	char name[IFNAMSIZ];
 
-	if (local)
-		prio |= 1;
-	if (remote && !MULTICAST(remote)) {
-		prio |= 2;
-		h ^= HASH(remote);
-	}
-	for (tp = &tunnels[prio][h]; (t = *tp) != NULL; tp = &t->next) {
+	for (tp = __ipgre_bucket(parms); (t = *tp) != NULL; tp = &t->next) {
 		if (local == t->parms.iph.saddr && remote == t->parms.iph.daddr) {
 			if (key == t->parms.i_key)
 				return t;

---
commit 14d6a0aa862954e03a7f1a479a83d153d2137c02
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:49 2007 +0900

    [IPV6]: Export in6addr_any for future use.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/in6.h b/include/linux/in6.h
index d559fac..2a61c82 100644
--- a/include/linux/in6.h
+++ b/include/linux/in6.h
@@ -44,10 +44,8 @@ struct in6_addr
  * NOTE: Be aware the IN6ADDR_* constants and in6addr_* externals are defined
  * in network byte order, not in host byte order as are the IPv4 equivalents
  */
-#if 0
 extern const struct in6_addr in6addr_any;
 #define IN6ADDR_ANY_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 } } }
-#endif
 extern const struct in6_addr in6addr_loopback;
 #define IN6ADDR_LOOPBACK_INIT { { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1 } } }
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index eea7ef4..82290db 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -209,9 +209,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 };
 
 /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 */
-#if 0
 const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
-#endif
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)

---
commit daa416b32ead1dc0608a9cb450ba9a3e2ff9ff06
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:50 2007 +0900

    [IPV6] XFRM: Use ip6addr_any where applicable.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f30ef16..d7ed8aa 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -147,14 +147,12 @@ int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
 {
 	struct xfrm_state *x = NULL;
 	int wildcard = 0;
-	struct in6_addr any;
 	xfrm_address_t *xany;
 	struct xfrm_state *xfrm_vec_one = NULL;
 	int nh = 0;
 	int i = 0;
 
-	ipv6_addr_set(&any, 0, 0, 0, 0);
-	xany = (xfrm_address_t *)&any;
+	xany = (xfrm_address_t *)&in6addr_any;
 
 	for (i = 0; i < 3; i++) {
 		xfrm_address_t *dst, *src;

---
commit 2c97a472d3aa2109bce78211e751febd2ee4ab7e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue Apr 24 20:44:52 2007 +0900

    [IPV6] NDISC: Unify main process of sending ND messages.
    
    Because ndisc_send_na(), ndisc_send_ns() and ndisc_send_rs()
    are almost identical, so let's unify their common part.
    
    With gcc (GCC) 3.3.5 (Debian 1:3.3.5-13) on i386,
    	Before:
    	   text	   data	    bss	    dec	    hex	filename
    	  14689	    364	     24	  15077	   3ae5	net/ipv6/ndisc.o
    	After:
    	   text	   data	    bss	    dec	    hex	filename
    	  12317	    364	     24	  12705	   31a1	net/ipv6/ndisc.o
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 4ee1216..d8b3645 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -427,38 +427,23 @@ static inline void ndisc_flow_init(struct flowi *fl, u8 type,
 	security_sk_classify_flow(ndisc_socket->sk, fl);
 }
 
-static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   struct in6_addr *daddr, struct in6_addr *solicited_addr,
-		   int router, int solicited, int override, int inc_opt)
+static void __ndisc_send(struct net_device *dev,
+			 struct neighbour *neigh,
+			 struct in6_addr *daddr, struct in6_addr *saddr,
+			 struct icmp6hdr *icmp6h, struct in6_addr *target,
+			 int llinfo, int icmp6_mib_outnd)
 {
-	struct in6_addr tmpaddr;
-	struct inet6_ifaddr *ifp;
-	struct inet6_dev *idev;
 	struct flowi fl;
-	struct dst_entry* dst;
+	struct dst_entry *dst;
 	struct sock *sk = ndisc_socket->sk;
-	struct in6_addr *src_addr;
-	struct nd_msg *msg;
-	int len;
 	struct sk_buff *skb;
+	struct icmp6hdr *hdr;
+	struct inet6_dev *idev;
+	int len;
 	int err;
+	u8 *opt;
 
-	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
-
-	/* for anycast or proxy, solicited_addr != src_addr */
-	ifp = ipv6_get_ifaddr(solicited_addr, dev, 1);
-	if (ifp) {
-		src_addr = solicited_addr;
-		if (ifp->flags & IFA_F_OPTIMISTIC)
-			override = 0;
-		in6_ifa_put(ifp);
-	} else {
-		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
-			return;
-		src_addr = &tmpaddr;
-	}
-
-	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr,
+	ndisc_flow_init(&fl, icmp6h->icmp6_type, saddr, daddr,
 			dev->ifindex);
 
 	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
@@ -469,61 +454,57 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	if (err < 0)
 		return;
 
-	if (inc_opt) {
-		if (dev->addr_len)
-			len += ndisc_opt_addr_space(dev);
-		else
-			inc_opt = 0;
-	}
+	if (!dev->addr_len)
+		llinfo = 0;
+
+	len = sizeof(struct icmp6hdr) + (target ? sizeof(*target) : 0);
+	if (llinfo)
+		len += ndisc_opt_addr_space(dev);
 
 	skb = sock_alloc_send_skb(sk,
 				  (MAX_HEADER + sizeof(struct ipv6hdr) +
 				   len + LL_RESERVED_SPACE(dev)),
 				  1, &err);
-
-	if (skb == NULL) {
+	if (!skb) {
 		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 NA: %s() failed to allocate an skb.\n",
+			   "ICMPv6 ND: %s() failed to allocate an skb.\n",
 			   __FUNCTION__);
 		dst_release(dst);
 		return;
 	}
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	ip6_nd_hdr(sk, skb, dev, src_addr, daddr, IPPROTO_ICMPV6, len);
+	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
-	msg = (struct nd_msg *)skb_transport_header(skb);
 
-	msg->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
-	msg->icmph.icmp6_code = 0;
-	msg->icmph.icmp6_cksum = 0;
+	hdr = (struct icmp6hdr *)skb_transport_header(skb);
+	memcpy(hdr, icmp6h, sizeof(*hdr));
 
-	msg->icmph.icmp6_unused = 0;
-	msg->icmph.icmp6_router    = router;
-	msg->icmph.icmp6_solicited = solicited;
-	msg->icmph.icmp6_override  = override;
-
-	/* Set the target address. */
-	ipv6_addr_copy(&msg->target, solicited_addr);
+	opt = skb_transport_header(skb) + sizeof(struct icmp6hdr);
+	if (target) {
+		ipv6_addr_copy((struct in6_addr *)opt, target);
+		opt += sizeof(*target);
+	}
 
-	if (inc_opt)
-		ndisc_fill_addr_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr,
+	if (llinfo)
+		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr,
 				       dev->addr_len, dev->type);
 
-	/* checksum */
-	msg->icmph.icmp6_cksum = csum_ipv6_magic(src_addr, daddr, len,
-						 IPPROTO_ICMPV6,
-						 csum_partial((__u8 *) msg,
-							      len, 0));
+	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, len,
+					   IPPROTO_ICMPV6,
+					   csum_partial((__u8 *) hdr,
+							len, 0));
 
 	skb->dst = dst;
+
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
+
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
+		ICMP6_INC_STATS(idev, icmp6_mib_outnd);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
 	}
 
@@ -531,20 +512,48 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		in6_dev_put(idev);
 }
 
+static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
+		   struct in6_addr *daddr, struct in6_addr *solicited_addr,
+		   int router, int solicited, int override, int inc_opt)
+{
+	struct in6_addr tmpaddr;
+	struct inet6_ifaddr *ifp;
+	struct in6_addr *src_addr;
+	struct icmp6hdr icmp6h = {
+		.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+	};
+
+	/* for anycast or proxy, solicited_addr != src_addr */
+	ifp = ipv6_get_ifaddr(solicited_addr, dev, 1);
+	if (ifp) {
+		src_addr = solicited_addr;
+		if (ifp->flags & IFA_F_OPTIMISTIC)
+			override = 0;
+		in6_ifa_put(ifp);
+	} else {
+		if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr))
+			return;
+		src_addr = &tmpaddr;
+	}
+
+	icmp6h.icmp6_router = router;
+	icmp6h.icmp6_solicited = solicited;
+	icmp6h.icmp6_override = override;
+
+	__ndisc_send(dev, neigh, daddr, src_addr,
+		     &icmp6h, solicited_addr,
+		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0,
+		     ICMP6_MIB_OUTNEIGHBORADVERTISEMENTS);
+}
+
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   struct in6_addr *solicit,
 		   struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	struct flowi fl;
-	struct dst_entry* dst;
-	struct inet6_dev *idev;
-	struct sock *sk = ndisc_socket->sk;
-	struct sk_buff *skb;
-	struct nd_msg *msg;
 	struct in6_addr addr_buf;
-	int len;
-	int err;
-	int send_llinfo;
+	struct icmp6hdr icmp6h = {
+		.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION,
+	};
 
 	if (saddr == NULL) {
 		if (ipv6_get_lladdr(dev, &addr_buf,
@@ -553,86 +562,19 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr,
-			dev->ifindex);
-
-	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
-	if (!dst)
-		return;
-
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0)
-		return;
-
-	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
-	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
-	if (send_llinfo)
-		len += ndisc_opt_addr_space(dev);
-
-	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + LL_RESERVED_SPACE(dev)),
-				  1, &err);
-	if (skb == NULL) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 NA: %s() failed to allocate an skb.\n",
-			   __FUNCTION__);
-		dst_release(dst);
-		return;
-	}
-
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
-
-	skb->transport_header = skb->tail;
-	skb_put(skb, len);
-	msg = (struct nd_msg *)skb_transport_header(skb);
-	msg->icmph.icmp6_type = NDISC_NEIGHBOUR_SOLICITATION;
-	msg->icmph.icmp6_code = 0;
-	msg->icmph.icmp6_cksum = 0;
-	msg->icmph.icmp6_unused = 0;
-
-	/* Set the target address. */
-	ipv6_addr_copy(&msg->target, solicit);
-
-	if (send_llinfo)
-		ndisc_fill_addr_option(msg->opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
-				       dev->addr_len, dev->type);
-
-	/* checksum */
-	msg->icmph.icmp6_cksum = csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-						 daddr, len,
-						 IPPROTO_ICMPV6,
-						 csum_partial((__u8 *) msg,
-							      len, 0));
-	/* send it! */
-	skb->dst = dst;
-	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
-	if (!err) {
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTNEIGHBORSOLICITS);
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
-	}
-
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	__ndisc_send(dev, neigh, daddr, saddr,
+		     &icmp6h, solicit,
+		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0,
+		     ICMP6_MIB_OUTNEIGHBORSOLICITS);
 }
 
 void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 		   struct in6_addr *daddr)
 {
-	struct flowi fl;
-	struct dst_entry* dst;
-	struct inet6_dev *idev;
-	struct sock *sk = ndisc_socket->sk;
-	struct sk_buff *skb;
-	struct icmp6hdr *hdr;
-	__u8 * opt;
+	struct icmp6hdr icmp6h = {
+		.icmp6_type = NDISC_ROUTER_SOLICITATION,
+	};
 	int send_sllao = dev->addr_len;
-	int len;
-	int err;
-
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	/*
@@ -655,67 +597,10 @@ void ndisc_send_rs(struct net_device *dev, struct in6_addr *saddr,
 		}
 	}
 #endif
-	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
-			dev->ifindex);
-
-	dst = ndisc_dst_alloc(dev, NULL, daddr, ip6_output);
-	if (!dst)
-		return;
-
-	err = xfrm_lookup(&dst, &fl, NULL, 0);
-	if (err < 0)
-		return;
-
-	len = sizeof(struct icmp6hdr);
-	if (send_sllao)
-		len += ndisc_opt_addr_space(dev);
-
-	skb = sock_alloc_send_skb(sk,
-				  (MAX_HEADER + sizeof(struct ipv6hdr) +
-				   len + LL_RESERVED_SPACE(dev)),
-				  1, &err);
-	if (skb == NULL) {
-		ND_PRINTK0(KERN_ERR
-			   "ICMPv6 RS: %s() failed to allocate an skb.\n",
-			   __FUNCTION__);
-		dst_release(dst);
-		return;
-	}
-
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
-	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
-
-	skb->transport_header = skb->tail;
-	skb_put(skb, len);
-	hdr = icmp6_hdr(skb);
-	hdr->icmp6_type = NDISC_ROUTER_SOLICITATION;
-	hdr->icmp6_code = 0;
-	hdr->icmp6_cksum = 0;
-	hdr->icmp6_unused = 0;
-
-	opt = (u8*) (hdr + 1);
-
-	if (send_sllao)
-		ndisc_fill_addr_option(opt, ND_OPT_SOURCE_LL_ADDR, dev->dev_addr,
-				       dev->addr_len, dev->type);
-
-	/* checksum */
-	hdr->icmp6_cksum = csum_ipv6_magic(&ipv6_hdr(skb)->saddr, daddr, len,
-					   IPPROTO_ICMPV6,
-					   csum_partial((__u8 *) hdr, len, 0));
-
-	/* send it! */
-	skb->dst = dst;
-	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
-	if (!err) {
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTROUTERSOLICITS);
-		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
-	}
-
-	if (likely(idev != NULL))
-		in6_dev_put(idev);
+	__ndisc_send(dev, NULL, daddr, saddr,
+		     &icmp6h, NULL,
+		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0,
+		     ICMP6_MIB_OUTROUTERSOLICITS);
 }
 
 

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
