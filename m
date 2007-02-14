From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL] IPv6 Updates
Date: Thu, 15 Feb 2007 02:35:14 +0900 (JST)
Message-ID: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	aramoto@linux-ipv6.org, kozakai@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55599 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbXBNRfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 12:35:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Please consider pulling the following changesets available on the
	2.6.20-net-2.6-20070214-FOR_DAVEM
branch at
	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
(on top of commit 928ba4169dc1d82c83105831f5ddb5472379b440).

Thank you.

HEADLINES
---------

    [IPV6] ADDRCONF: Manage prefix route corresponding to address manually added.
    [IPV6] IP6TUNNEL: Use update_pmtu() of dst on xmit.
    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_err().
    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_rcv().
    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_xmit().
    [IPV6] IP6TUNNEL: Add support to IPv4 over IPv6 tunnel.
    [IPV6] IP6TUNNEL: Rename functions ip6ip6_* to ip6_tnl_*.
    [IPV6] IP6TUNNEL: Enable to control the handled inner protocol.
    [IPV6] ADDRCONF: Register inet6_dev earlier.

DIFFSTAT
--------

 net/ipv6/addrconf.c   |   30 ++
 net/ipv6/ip6_tunnel.c |  630 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 478 insertions(+), 182 deletions(-)

CHANGESETS
----------

commit bda786c68d05984f5d4a1812d3ebd2290d5bea57
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Feb 15 01:09:10 2007 +0900

    [IPV6] ADDRCONF: Manage prefix route corresponding to address manually added.
    
    It is more natural to manage prefix routes corresponding to address which is
    being added manually.
    
    With help from Masafumi Aramoto <aramoto@linux-ipv6.org>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ea0755b..c6683ea 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1911,6 +1911,7 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 	struct inet6_dev *idev;
 	struct net_device *dev;
 	int scope;
+	u32 flags = RTF_EXPIRES;
 
 	ASSERT_RTNL();
 
@@ -1926,9 +1927,10 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 
 	scope = ipv6_addr_scope(pfx);
 
-	if (valid_lft == INFINITY_LIFE_TIME)
+	if (valid_lft == INFINITY_LIFE_TIME) {
 		ifa_flags |= IFA_F_PERMANENT;
-	else if (valid_lft >= 0x7FFFFFFF/HZ)
+		flags = 0;
+	} else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
 	if (prefered_lft == 0)
@@ -1946,6 +1948,8 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 		ifp->tstamp = jiffies;
 		spin_unlock_bh(&ifp->lock);
 
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
+				      jiffies_to_clock_t(valid_lft * HZ), flags);
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
@@ -2125,6 +2129,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
 
 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 	}
@@ -2539,10 +2544,6 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 
 	addrconf_join_solict(dev, &ifp->addr);
 
-	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
-					flags);
-
 	net_srandom(ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
@@ -2973,12 +2974,15 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 			     u32 prefered_lft, u32 valid_lft)
 {
+	u32 flags = RTF_EXPIRES;
+
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 
-	if (valid_lft == INFINITY_LIFE_TIME)
+	if (valid_lft == INFINITY_LIFE_TIME) {
 		ifa_flags |= IFA_F_PERMANENT;
-	else if (valid_lft >= 0x7FFFFFFF/HZ)
+		flags = 0;
+	} else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
 	if (prefered_lft == 0)
@@ -2997,6 +3001,8 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 	if (!(ifp->flags&IFA_F_TENTATIVE))
 		ipv6_ifa_notify(0, ifp);
 
+	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
+			      jiffies_to_clock_t(valid_lft * HZ), flags);
 	addrconf_verify(0);
 
 	return 0;

---
commit b5ea2d4352fab08edd0cbceb280c15c764063f0d
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:11 2007 +0900

    [IPV6] IP6TUNNEL: Use update_pmtu() of dst on xmit.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 662edb8..08d9442 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -727,11 +727,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
-	if (skb->dst && mtu < dst_mtu(skb->dst)) {
-		struct rt6_info *rt = (struct rt6_info *) skb->dst;
-		rt->rt6i_flags |= RTF_MODIFIED;
-		rt->u.dst.metrics[RTAX_MTU-1] = mtu;
-	}
+	if (skb->dst)
+		skb->dst->ops->update_pmtu(skb->dst, mtu);
 	if (skb->len > mtu) {
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
 		goto tx_err_dst_release;

---
commit c4b2af7ef485929b75ce4f8e76b402c25b078b21
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:12 2007 +0900

    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_err().
    
    This enables to add IPv4/IPv6 specific error handling later,
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 08d9442..6022fc5 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -372,16 +372,16 @@ parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
 }
 
 /**
- * ip6ip6_err - tunnel error handler
+ * ip6_tnl_err - tunnel error handler
  *
  * Description:
- *   ip6ip6_err() should handle errors in the tunnel according
+ *   ip6_tnl_err() should handle errors in the tunnel according
  *   to the specifications in RFC 2473.
  **/
 
 static int
-ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
-	   int type, int code, int offset, __be32 info)
+ip6_tnl_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+	    int *type, int *code, int *msg, __be32 *info, int offset)
 {
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *) skb->data;
 	struct ip6_tnl *t;
@@ -402,7 +402,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	err = 0;
 
-	switch (type) {
+	switch (*type) {
 		__u32 teli;
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		__u32 mtu;
@@ -414,7 +414,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		rel_msg = 1;
 		break;
 	case ICMPV6_TIME_EXCEED:
-		if (code == ICMPV6_EXC_HOPLIMIT) {
+		if ((*code) == ICMPV6_EXC_HOPLIMIT) {
 			if (net_ratelimit())
 				printk(KERN_WARNING
 				       "%s: Too small hop limit or "
@@ -425,10 +425,10 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		break;
 	case ICMPV6_PARAMPROB:
 		teli = 0;
-		if (code == ICMPV6_HDR_FIELD)
+		if ((*code) == ICMPV6_HDR_FIELD)
 			teli = parse_tlv_tnl_enc_lim(skb, skb->data);
 
-		if (teli && teli == ntohl(info) - 2) {
+		if (teli && teli == ntohl(*info) - 2) {
 			tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->data[teli];
 			if (tel->encap_limit == 0) {
 				if (net_ratelimit())
@@ -445,7 +445,7 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-		mtu = ntohl(info) - offset;
+		mtu = ntohl(*info) - offset;
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
@@ -458,12 +458,38 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 		break;
 	}
-	if (rel_msg &&  pskb_may_pull(skb, offset + sizeof (*ipv6h))) {
+
+	*type = rel_type;
+	*code = rel_code;
+	*info = rel_info;
+	*msg = rel_msg;
+
+out:
+	read_unlock(&ip6ip6_lock);
+	return err;
+}
+
+static int
+ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+	   int type, int code, int offset, __u32 info)
+{
+	int rel_msg = 0;
+	int rel_type = type;
+	int rel_code = code;
+	__u32 rel_info = info;
+	int err;
+
+	err = ip6_tnl_err(skb, opt, &rel_type, &rel_code, &rel_msg, &rel_info,
+			  offset);
+	if (err < 0)
+		return err;
+
+	if (rel_msg && pskb_may_pull(skb, offset + sizeof(struct ipv6hdr))) {
 		struct rt6_info *rt;
 		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 
 		if (!skb2)
-			goto out;
+			return 0;
 
 		dst_release(skb2->dst);
 		skb2->dst = NULL;
@@ -483,9 +509,8 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 		kfree_skb(skb2);
 	}
-out:
-	read_unlock(&ip6ip6_lock);
-	return err;
+
+	return 0;
 }
 
 static inline void ip6ip6_ecn_decapsulate(struct ipv6hdr *outer_iph,

---
commit 6755e45a94433858930b8ec5d13e7fc1c5835899
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:13 2007 +0900

    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_rcv().
    
    This enables to add IPv4/IPv6 specific handling later,
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6022fc5..985d106 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -513,14 +513,17 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return 0;
 }
 
-static inline void ip6ip6_ecn_decapsulate(struct ipv6hdr *outer_iph,
-					  struct sk_buff *skb)
+static void ip6ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
+					struct ipv6hdr *ipv6h,
+					struct sk_buff *skb)
 {
-	struct ipv6hdr *inner_iph = skb->nh.ipv6h;
+	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
+		ipv6_copy_dscp(ipv6h, skb->nh.ipv6h);
 
-	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
-		IP6_ECN_set_ce(inner_iph);
+	if (INET_ECN_is_ce(ipv6_get_dsfield(ipv6h)))
+		IP6_ECN_set_ce(skb->nh.ipv6h);
 }
+
 static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 {
 	struct ip6_tnl_parm *p = &t->parms;
@@ -546,12 +549,16 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 /**
  * ip6ip6_rcv - decapsulate IPv6 packet and retransmit it locally
  *   @skb: received socket buffer
+ *   @protocol: ethernet protocol ID
+ *   @dscp_ecn_decapsulate: the function to decapsulate DSCP code and ECN
  *
  * Return: 0
  **/
 
-static int
-ip6ip6_rcv(struct sk_buff *skb)
+static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
+		       void (*dscp_ecn_decapsulate)(struct ip6_tnl *t,
+						    struct ipv6hdr *ipv6h,
+						    struct sk_buff *skb))
 {
 	struct ipv6hdr *ipv6h;
 	struct ip6_tnl *t;
@@ -574,16 +581,16 @@ ip6ip6_rcv(struct sk_buff *skb)
 		secpath_reset(skb);
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = skb->data;
-		skb->protocol = htons(ETH_P_IPV6);
+		skb->protocol = htons(protocol);
 		skb->pkt_type = PACKET_HOST;
 		memset(skb->cb, 0, sizeof(struct inet6_skb_parm));
 		skb->dev = t->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
 		nf_reset(skb);
-		if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
-			ipv6_copy_dscp(ipv6h, skb->nh.ipv6h);
-		ip6ip6_ecn_decapsulate(ipv6h, skb);
+
+		dscp_ecn_decapsulate(t, ipv6h, skb);
+
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;
 		netif_rx(skb);
@@ -598,6 +605,11 @@ discard:
 	return 0;
 }
 
+static int ip6ip6_rcv(struct sk_buff *skb)
+{
+	return ip6_tnl_rcv(skb, ETH_P_IPV6, ip6ip6_dscp_ecn_decapsulate);
+}
+
 struct ipv6_tel_txoption {
 	struct ipv6_txoptions ops;
 	__u8 dst_opt[8];

---
commit 2df8f28648dfe839060b1e0fe4e4871bee72efd5
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:13 2007 +0900

    [IPV6] IP6TUNNEL: Split out generic rutine in ip6ip6_xmit().
    
    This enables to add IPv4/IPv6 specific handling later,
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 985d106..4546bb9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -678,9 +678,13 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
 	return ret;
 }
 /**
- * ip6ip6_tnl_xmit - encapsulate packet and send
+ * ip6_tnl_xmit2 - encapsulate packet and send
  *   @skb: the outgoing socket buffer
  *   @dev: the outgoing tunnel device
+ *   @dsfield: dscp code for outer header
+ *   @fl: flow of tunneled packet
+ *   @encap_limit: encapsulation limit
+ *   @pmtu: Path MTU is stored if packet is too big
  *
  * Description:
  *   Build new header and do some sanity checks on the packet before sending
@@ -688,62 +692,35 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
  *
  * Return:
  *   0
+ *   -1 fail
+ *   %-EMSGSIZE message too big. return mtu in this case.
  **/
 
-static int
-ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+static int ip6_tnl_xmit2(struct sk_buff *skb,
+			 struct net_device *dev,
+			 __u8 dsfield,
+			 struct flowi *fl,
+			 int encap_limit,
+			 __u32 *pmtu)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->stat;
 	struct ipv6hdr *ipv6h = skb->nh.ipv6h;
-	int encap_limit = -1;
 	struct ipv6_tel_txoption opt;
-	__u16 offset;
-	struct flowi fl;
 	struct dst_entry *dst;
 	struct net_device *tdev;
 	int mtu;
 	int max_headroom = sizeof(struct ipv6hdr);
 	u8 proto;
-	int err;
+	int err = -1;
 	int pkt_len;
-	int dsfield;
-
-	if (t->recursion++) {
-		stats->collisions++;
-		goto tx_err;
-	}
-	if (skb->protocol != htons(ETH_P_IPV6) ||
-	    !ip6_tnl_xmit_ctl(t) || ip6ip6_tnl_addr_conflict(t, ipv6h))
-		goto tx_err;
-
-	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
-		struct ipv6_tlv_tnl_enc_lim *tel;
-		tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->nh.raw[offset];
-		if (tel->encap_limit == 0) {
-			icmpv6_send(skb, ICMPV6_PARAMPROB,
-				    ICMPV6_HDR_FIELD, offset + 2, skb->dev);
-			goto tx_err;
-		}
-		encap_limit = tel->encap_limit - 1;
-	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
-		encap_limit = t->parms.encap_limit;
-
-	memcpy(&fl, &t->fl, sizeof (fl));
-	proto = fl.proto;
-
-	dsfield = ipv6_get_dsfield(ipv6h);
-	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
-		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
-	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
-		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
 
 	if ((dst = ip6_tnl_dst_check(t)) != NULL)
 		dst_hold(dst);
 	else {
-		dst = ip6_route_output(NULL, &fl);
+		dst = ip6_route_output(NULL, fl);
 
-		if (dst->error || xfrm_lookup(&dst, &fl, NULL, 0) < 0)
+		if (dst->error || xfrm_lookup(&dst, fl, NULL, 0) < 0)
 			goto tx_err_link_failure;
 	}
 
@@ -767,7 +744,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->dst)
 		skb->dst->ops->update_pmtu(skb->dst, mtu);
 	if (skb->len > mtu) {
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+		*pmtu = mtu;
+		err = -EMSGSIZE;
 		goto tx_err_dst_release;
 	}
 
@@ -793,20 +771,21 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb->h.raw = skb->nh.raw;
 
+	proto = fl->proto;
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
 	}
 	skb->nh.raw = skb_push(skb, sizeof(struct ipv6hdr));
 	ipv6h = skb->nh.ipv6h;
-	*(__be32*)ipv6h = fl.fl6_flowlabel | htonl(0x60000000);
+	*(__be32*)ipv6h = fl->fl6_flowlabel | htonl(0x60000000);
 	dsfield = INET_ECN_encapsulate(0, dsfield);
 	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
 	ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
-	ipv6_addr_copy(&ipv6h->saddr, &fl.fl6_src);
-	ipv6_addr_copy(&ipv6h->daddr, &fl.fl6_dst);
+	ipv6_addr_copy(&ipv6h->saddr, &fl->fl6_src);
+	ipv6_addr_copy(&ipv6h->daddr, &fl->fl6_dst);
 	nf_reset(skb);
 	pkt_len = skb->len;
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
@@ -820,13 +799,87 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		stats->tx_aborted_errors++;
 	}
 	ip6_tnl_dst_store(t, dst);
-	t->recursion--;
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
 tx_err_dst_release:
 	dst_release(dst);
+	return err;
+}
+
+static inline int
+ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+	struct ipv6hdr *ipv6h = skb->nh.ipv6h;
+	int encap_limit = -1;
+	__u16 offset;
+	struct flowi fl;
+	__u8 dsfield;
+	__u32 mtu;
+	int err;
+
+	if (!ip6_tnl_xmit_ctl(t) || ip6ip6_tnl_addr_conflict(t, ipv6h))
+		return -1;
+
+	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
+		struct ipv6_tlv_tnl_enc_lim *tel;
+		tel = (struct ipv6_tlv_tnl_enc_lim *) &skb->nh.raw[offset];
+		if (tel->encap_limit == 0) {
+			icmpv6_send(skb, ICMPV6_PARAMPROB,
+				    ICMPV6_HDR_FIELD, offset + 2, skb->dev);
+			return -1;
+		}
+		encap_limit = tel->encap_limit - 1;
+	} else if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+		encap_limit = t->parms.encap_limit;
+
+	memcpy(&fl, &t->fl, sizeof (fl));
+	fl.proto = IPPROTO_IPV6;
+
+	dsfield = ipv6_get_dsfield(ipv6h);
+	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
+		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_TCLASS_MASK);
+	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
+		fl.fl6_flowlabel |= (*(__be32 *) ipv6h & IPV6_FLOWLABEL_MASK);
+
+	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
+	if (err != 0) {
+		if (err == -EMSGSIZE)
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
+		return -1;
+	}
+
+	return 0;
+}
+
+static int
+ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+	struct net_device_stats *stats = &t->stat;
+	int ret;
+
+	if (t->recursion++) {
+		t->stat.collisions++;
+		goto tx_err;
+	}
+
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IPV6):
+		ret = ip6ip6_tnl_xmit(skb, dev);
+		break;
+	default:
+		goto tx_err;
+	}
+
+	if (ret < 0)
+		goto tx_err;
+
+	t->recursion--;
+	return 0;
+
 tx_err:
 	stats->tx_errors++;
 	stats->tx_dropped++;
@@ -1088,7 +1141,7 @@ static void ip6ip6_tnl_dev_setup(struct net_device *dev)
 	SET_MODULE_OWNER(dev);
 	dev->uninit = ip6ip6_tnl_dev_uninit;
 	dev->destructor = free_netdev;
-	dev->hard_start_xmit = ip6ip6_tnl_xmit;
+	dev->hard_start_xmit = ip6_tnl_xmit;
 	dev->get_stats = ip6ip6_tnl_get_stats;
 	dev->do_ioctl = ip6ip6_tnl_ioctl;
 	dev->change_mtu = ip6ip6_tnl_change_mtu;

---
commit c635a40acaeccb97a9df3c38ac5bea1fca8c5411
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:14 2007 +0900

    [IPV6] IP6TUNNEL: Add support to IPv4 over IPv6 tunnel.
    
    Some notes
    - Protocol number IPPROTO_IPIP is used for IPv4 over IPv6 packets.
    - If IP6_TNL_F_USE_ORIG_TCLASS is set, TOS in IPv4 header is copied to
      Traffic Class in outer IPv6 header on xmit.
    - IP6_TNL_F_USE_ORIG_FLOWLABEL is ignored on xmit of IPv4 packets, because
      IPv4 header does not have flow label.
    - Kernel sends ICMP error if IPv4 packet is too big on xmit, even if
      DF flag is not set.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 4546bb9..a654149 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1,14 +1,15 @@
 /*
- *	IPv6 over IPv6 tunnel device
+ *	IPv6 tunneling device
  *	Linux INET6 implementation
  *
  *	Authors:
  *	Ville Nuorvala		<vnuorval@tcs.hut.fi>
+ *	Yasuyuki Kozakai	<kozakai@linux-ipv6.org>
  *
  *	$Id$
  *
  *      Based on:
- *      linux/net/ipv6/sit.c
+ *      linux/net/ipv6/sit.c and linux/net/ipv4/ipip.c
  *
  *      RFC 2473
  *
@@ -24,6 +25,7 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/sockios.h>
+#include <linux/icmp.h>
 #include <linux/if.h>
 #include <linux/in.h>
 #include <linux/ip.h>
@@ -41,6 +43,7 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 
+#include <net/icmp.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
@@ -51,7 +54,7 @@
 #include <net/inet_ecn.h>
 
 MODULE_AUTHOR("Ville Nuorvala");
-MODULE_DESCRIPTION("IPv6-in-IPv6 tunnel");
+MODULE_DESCRIPTION("IPv6 tunneling device");
 MODULE_LICENSE("GPL");
 
 #define IPV6_TLV_TEL_DST_SIZE 8
@@ -63,6 +66,7 @@ MODULE_LICENSE("GPL");
 #endif
 
 #define IPV6_TCLASS_MASK (IPV6_FLOWINFO_MASK & ~IPV6_FLOWLABEL_MASK)
+#define IPV6_TCLASS_SHIFT 20
 
 #define HASH_SIZE  32
 
@@ -470,6 +474,104 @@ out:
 }
 
 static int
+ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+	   int type, int code, int offset, __u32 info)
+{
+	int rel_msg = 0;
+	int rel_type = type;
+	int rel_code = code;
+	__u32 rel_info = info;
+	int err;
+	struct sk_buff *skb2;
+	struct iphdr *eiph;
+	struct flowi fl;
+	struct rtable *rt;
+
+	err = ip6_tnl_err(skb, opt, &rel_type, &rel_code, &rel_msg, &rel_info,
+			  offset);
+	if (err < 0)
+		return err;
+
+	if (rel_msg == 0)
+		return 0;
+
+	switch (rel_type) {
+	case ICMPV6_DEST_UNREACH:
+		if (rel_code != ICMPV6_ADDR_UNREACH)
+			return 0;
+		rel_type = ICMP_DEST_UNREACH;
+		rel_code = ICMP_HOST_UNREACH;
+		break;
+	case ICMPV6_PKT_TOOBIG:
+		if (rel_code != 0)
+			return 0;
+		rel_type = ICMP_DEST_UNREACH;
+		rel_code = ICMP_FRAG_NEEDED;
+		break;
+	default:
+		return 0;
+	}
+
+	if (!pskb_may_pull(skb, offset + sizeof(struct iphdr)))
+		return 0;
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (!skb2)
+		return 0;
+
+	dst_release(skb2->dst);
+	skb2->dst = NULL;
+	skb_pull(skb2, offset);
+	skb2->nh.raw = skb2->data;
+	eiph = skb2->nh.iph;
+
+	/* Try to guess incoming interface */
+	memset(&fl, 0, sizeof(fl));
+	fl.fl4_dst = eiph->saddr;
+	fl.fl4_tos = RT_TOS(eiph->tos);
+	fl.proto = IPPROTO_IPIP;
+	if (ip_route_output_key(&rt, &fl))
+		goto out;
+
+	skb2->dev = rt->u.dst.dev;
+
+	/* route "incoming" packet */
+	if (rt->rt_flags & RTCF_LOCAL) {
+		ip_rt_put(rt);
+		rt = NULL;
+		fl.fl4_dst = eiph->daddr;
+		fl.fl4_src = eiph->saddr;
+		fl.fl4_tos = eiph->tos;
+		if (ip_route_output_key(&rt, &fl) ||
+		    rt->u.dst.dev->type != ARPHRD_TUNNEL) {
+			ip_rt_put(rt);
+			goto out;
+		}
+	} else {
+		ip_rt_put(rt);
+		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos,
+				   skb2->dev) ||
+		    skb2->dst->dev->type != ARPHRD_TUNNEL)
+			goto out;
+	}
+
+	/* change mtu on this route */
+	if (rel_type == ICMP_DEST_UNREACH && rel_code == ICMP_FRAG_NEEDED) {
+		if (rel_info > dst_mtu(skb2->dst))
+			goto out;
+
+		skb2->dst->ops->update_pmtu(skb2->dst, rel_info);
+		rel_info = htonl(rel_info);
+	}
+
+	icmp_send(skb2, rel_type, rel_code, rel_info);
+
+out:
+	kfree_skb(skb2);
+	return 0;
+}
+
+static int
 ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	   int type, int code, int offset, __u32 info)
 {
@@ -513,6 +615,19 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	return 0;
 }
 
+static void ip4ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
+					struct ipv6hdr *ipv6h,
+					struct sk_buff *skb)
+{
+	__u8 dsfield = ipv6_get_dsfield(ipv6h) & ~INET_ECN_MASK;
+
+	if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
+		ipv4_change_dsfield(skb->nh.iph, INET_ECN_MASK, dsfield);
+
+	if (INET_ECN_is_ce(dsfield))
+		IP_ECN_set_ce(skb->nh.iph);
+}
+
 static void ip6ip6_dscp_ecn_decapsulate(struct ip6_tnl *t,
 					struct ipv6hdr *ipv6h,
 					struct sk_buff *skb)
@@ -605,6 +720,11 @@ discard:
 	return 0;
 }
 
+static int ip4ip6_rcv(struct sk_buff *skb)
+{
+	return ip6_tnl_rcv(skb, ETH_P_IP, ip4ip6_dscp_ecn_decapsulate);
+}
+
 static int ip6ip6_rcv(struct sk_buff *skb)
 {
 	return ip6_tnl_rcv(skb, ETH_P_IPV6, ip6ip6_dscp_ecn_decapsulate);
@@ -691,7 +811,7 @@ static inline int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
  *   it.
  *
  * Return:
- *   0
+ *   0 on success
  *   -1 fail
  *   %-EMSGSIZE message too big. return mtu in this case.
  **/
@@ -809,6 +929,44 @@ tx_err_dst_release:
 }
 
 static inline int
+ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ip6_tnl *t = netdev_priv(dev);
+	struct iphdr  *iph = skb->nh.iph;
+	int encap_limit = -1;
+	struct flowi fl;
+	__u8 dsfield;
+	__u32 mtu;
+	int err;
+
+	if (!ip6_tnl_xmit_ctl(t))
+		return -1;
+
+	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
+		encap_limit = t->parms.encap_limit;
+
+	memcpy(&fl, &t->fl, sizeof (fl));
+	fl.proto = IPPROTO_IPIP;
+
+	dsfield = ipv4_get_dsfield(iph);
+
+	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
+		fl.fl6_flowlabel |= ntohl(((__u32)iph->tos << IPV6_TCLASS_SHIFT)
+					  & IPV6_TCLASS_MASK);
+
+	err = ip6_tnl_xmit2(skb, dev, dsfield, &fl, encap_limit, &mtu);
+	if (err != 0) {
+		/* XXX: send ICMP error even if DF is not set. */
+		if (err == -EMSGSIZE)
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+				  htonl(mtu));
+		return -1;
+	}
+
+	return 0;
+}
+
+static inline int
 ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
@@ -867,6 +1025,9 @@ ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		ret = ip4ip6_tnl_xmit(skb, dev);
+		break;
 	case __constant_htons(ETH_P_IPV6):
 		ret = ip6ip6_tnl_xmit(skb, dev);
 		break;
@@ -1199,6 +1360,12 @@ ip6ip6_fb_tnl_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static struct xfrm6_tunnel ip4ip6_handler = {
+	.handler	= ip4ip6_rcv,
+	.err_handler	= ip4ip6_err,
+	.priority	=	1,
+};
+
 static struct xfrm6_tunnel ip6ip6_handler = {
 	.handler	= ip6ip6_rcv,
 	.err_handler	= ip6ip6_err,
@@ -1215,9 +1382,16 @@ static int __init ip6_tunnel_init(void)
 {
 	int  err;
 
+	if (xfrm6_tunnel_register(&ip4ip6_handler, AF_INET)) {
+		printk(KERN_ERR "ip4ip6 init: can't register tunnel\n");
+		err = -EAGAIN;
+		goto out;
+	}
+
 	if (xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6)) {
 		printk(KERN_ERR "ip6ip6 init: can't register tunnel\n");
-		return -EAGAIN;
+		err = -EAGAIN;
+		goto unreg_ip4ip6;
 	}
 	ip6ip6_fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
 					 ip6ip6_tnl_dev_setup);
@@ -1235,6 +1409,9 @@ static int __init ip6_tunnel_init(void)
 	return 0;
 fail:
 	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
+unreg_ip4ip6:
+	xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET);
+out:
 	return err;
 }
 
@@ -1258,6 +1435,9 @@ static void __exit ip6ip6_destroy_tunnels(void)
 
 static void __exit ip6_tunnel_cleanup(void)
 {
+	if (xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET))
+		printk(KERN_INFO "ip4ip6 close: can't deregister tunnel\n");
+
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
 		printk(KERN_INFO "ip6ip6 close: can't deregister tunnel\n");
 

---
commit 2ef4c54a4510772fbc3353068c61926f6bd2b4ae
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:15 2007 +0900

    [IPV6] IP6TUNNEL: Rename functions ip6ip6_* to ip6_tnl_*.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a654149..70684e0 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -74,12 +74,12 @@ MODULE_LICENSE("GPL");
 		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
 		    (HASH_SIZE - 1))
 
-static int ip6ip6_fb_tnl_dev_init(struct net_device *dev);
-static int ip6ip6_tnl_dev_init(struct net_device *dev);
-static void ip6ip6_tnl_dev_setup(struct net_device *dev);
+static int ip6_fb_tnl_dev_init(struct net_device *dev);
+static int ip6_tnl_dev_init(struct net_device *dev);
+static void ip6_tnl_dev_setup(struct net_device *dev);
 
 /* the IPv6 tunnel fallback device */
-static struct net_device *ip6ip6_fb_tnl_dev;
+static struct net_device *ip6_fb_tnl_dev;
 
 
 /* lists for storing tunnels in use */
@@ -88,7 +88,7 @@ static struct ip6_tnl *tnls_wc[1];
 static struct ip6_tnl **tnls[2] = { tnls_wc, tnls_r_l };
 
 /* lock for the tunnel lists */
-static DEFINE_RWLOCK(ip6ip6_lock);
+static DEFINE_RWLOCK(ip6_tnl_lock);
 
 static inline struct dst_entry *ip6_tnl_dst_check(struct ip6_tnl *t)
 {
@@ -119,7 +119,7 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
 }
 
 /**
- * ip6ip6_tnl_lookup - fetch tunnel matching the end-point addresses
+ * ip6_tnl_lookup - fetch tunnel matching the end-point addresses
  *   @remote: the address of the tunnel exit-point
  *   @local: the address of the tunnel entry-point
  *
@@ -130,7 +130,7 @@ static inline void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst)
  **/
 
 static struct ip6_tnl *
-ip6ip6_tnl_lookup(struct in6_addr *remote, struct in6_addr *local)
+ip6_tnl_lookup(struct in6_addr *remote, struct in6_addr *local)
 {
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(local);
@@ -149,18 +149,18 @@ ip6ip6_tnl_lookup(struct in6_addr *remote, struct in6_addr *local)
 }
 
 /**
- * ip6ip6_bucket - get head of list matching given tunnel parameters
+ * ip6_tnl_bucket - get head of list matching given tunnel parameters
  *   @p: parameters containing tunnel end-points
  *
  * Description:
- *   ip6ip6_bucket() returns the head of the list matching the
+ *   ip6_tnl_bucket() returns the head of the list matching the
  *   &struct in6_addr entries laddr and raddr in @p.
  *
  * Return: head of IPv6 tunnel list
  **/
 
 static struct ip6_tnl **
-ip6ip6_bucket(struct ip6_tnl_parm *p)
+ip6_tnl_bucket(struct ip6_tnl_parm *p)
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
@@ -175,36 +175,36 @@ ip6ip6_bucket(struct ip6_tnl_parm *p)
 }
 
 /**
- * ip6ip6_tnl_link - add tunnel to hash table
+ * ip6_tnl_link - add tunnel to hash table
  *   @t: tunnel to be added
  **/
 
 static void
-ip6ip6_tnl_link(struct ip6_tnl *t)
+ip6_tnl_link(struct ip6_tnl *t)
 {
-	struct ip6_tnl **tp = ip6ip6_bucket(&t->parms);
+	struct ip6_tnl **tp = ip6_tnl_bucket(&t->parms);
 
 	t->next = *tp;
-	write_lock_bh(&ip6ip6_lock);
+	write_lock_bh(&ip6_tnl_lock);
 	*tp = t;
-	write_unlock_bh(&ip6ip6_lock);
+	write_unlock_bh(&ip6_tnl_lock);
 }
 
 /**
- * ip6ip6_tnl_unlink - remove tunnel from hash table
+ * ip6_tnl_unlink - remove tunnel from hash table
  *   @t: tunnel to be removed
  **/
 
 static void
-ip6ip6_tnl_unlink(struct ip6_tnl *t)
+ip6_tnl_unlink(struct ip6_tnl *t)
 {
 	struct ip6_tnl **tp;
 
-	for (tp = ip6ip6_bucket(&t->parms); *tp; tp = &(*tp)->next) {
+	for (tp = ip6_tnl_bucket(&t->parms); *tp; tp = &(*tp)->next) {
 		if (t == *tp) {
-			write_lock_bh(&ip6ip6_lock);
+			write_lock_bh(&ip6_tnl_lock);
 			*tp = t->next;
-			write_unlock_bh(&ip6ip6_lock);
+			write_unlock_bh(&ip6_tnl_lock);
 			break;
 		}
 	}
@@ -241,12 +241,12 @@ static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
 		if (i == IP6_TNL_MAX)
 			goto failed;
 	}
-	dev = alloc_netdev(sizeof (*t), name, ip6ip6_tnl_dev_setup);
+	dev = alloc_netdev(sizeof (*t), name, ip6_tnl_dev_setup);
 	if (dev == NULL)
 		goto failed;
 
 	t = netdev_priv(dev);
-	dev->init = ip6ip6_tnl_dev_init;
+	dev->init = ip6_tnl_dev_init;
 	t->parms = *p;
 
 	if ((err = register_netdevice(dev)) < 0) {
@@ -254,19 +254,19 @@ static struct ip6_tnl *ip6_tnl_create(struct ip6_tnl_parm *p)
 		goto failed;
 	}
 	dev_hold(dev);
-	ip6ip6_tnl_link(t);
+	ip6_tnl_link(t);
 	return t;
 failed:
 	return NULL;
 }
 
 /**
- * ip6ip6_tnl_locate - find or create tunnel matching given parameters
+ * ip6_tnl_locate - find or create tunnel matching given parameters
  *   @p: tunnel parameters
  *   @create: != 0 if allowed to create new tunnel if no match found
  *
  * Description:
- *   ip6ip6_tnl_locate() first tries to locate an existing tunnel
+ *   ip6_tnl_locate() first tries to locate an existing tunnel
  *   based on @parms. If this is unsuccessful, but @create is set a new
  *   tunnel device is created and registered for use.
  *
@@ -274,13 +274,13 @@ failed:
  *   matching tunnel or NULL
  **/
 
-static struct ip6_tnl *ip6ip6_tnl_locate(struct ip6_tnl_parm *p, int create)
+static struct ip6_tnl *ip6_tnl_locate(struct ip6_tnl_parm *p, int create)
 {
 	struct in6_addr *remote = &p->raddr;
 	struct in6_addr *local = &p->laddr;
 	struct ip6_tnl *t;
 
-	for (t = *ip6ip6_bucket(p); t; t = t->next) {
+	for (t = *ip6_tnl_bucket(p); t; t = t->next) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
 		    ipv6_addr_equal(remote, &t->parms.raddr))
 			return t;
@@ -291,24 +291,24 @@ static struct ip6_tnl *ip6ip6_tnl_locate(struct ip6_tnl_parm *p, int create)
 }
 
 /**
- * ip6ip6_tnl_dev_uninit - tunnel device uninitializer
+ * ip6_tnl_dev_uninit - tunnel device uninitializer
  *   @dev: the device to be destroyed
  *
  * Description:
- *   ip6ip6_tnl_dev_uninit() removes tunnel from its list
+ *   ip6_tnl_dev_uninit() removes tunnel from its list
  **/
 
 static void
-ip6ip6_tnl_dev_uninit(struct net_device *dev)
+ip6_tnl_dev_uninit(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 
-	if (dev == ip6ip6_fb_tnl_dev) {
-		write_lock_bh(&ip6ip6_lock);
+	if (dev == ip6_fb_tnl_dev) {
+		write_lock_bh(&ip6_tnl_lock);
 		tnls_wc[0] = NULL;
-		write_unlock_bh(&ip6ip6_lock);
+		write_unlock_bh(&ip6_tnl_lock);
 	} else {
-		ip6ip6_tnl_unlink(t);
+		ip6_tnl_unlink(t);
 	}
 	ip6_tnl_dst_reset(t);
 	dev_put(dev);
@@ -400,8 +400,8 @@ ip6_tnl_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	   in trouble since we might need the source address for further
 	   processing of the error. */
 
-	read_lock(&ip6ip6_lock);
-	if ((t = ip6ip6_tnl_lookup(&ipv6h->daddr, &ipv6h->saddr)) == NULL)
+	read_lock(&ip6_tnl_lock);
+	if ((t = ip6_tnl_lookup(&ipv6h->daddr, &ipv6h->saddr)) == NULL)
 		goto out;
 
 	err = 0;
@@ -469,7 +469,7 @@ ip6_tnl_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	*msg = rel_msg;
 
 out:
-	read_unlock(&ip6ip6_lock);
+	read_unlock(&ip6_tnl_lock);
 	return err;
 }
 
@@ -662,7 +662,7 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
 }
 
 /**
- * ip6ip6_rcv - decapsulate IPv6 packet and retransmit it locally
+ * ip6_tnl_rcv - decapsulate IPv6 packet and retransmit it locally
  *   @skb: received socket buffer
  *   @protocol: ethernet protocol ID
  *   @dscp_ecn_decapsulate: the function to decapsulate DSCP code and ECN
@@ -680,17 +680,17 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 
 	ipv6h = skb->nh.ipv6h;
 
-	read_lock(&ip6ip6_lock);
+	read_lock(&ip6_tnl_lock);
 
-	if ((t = ip6ip6_tnl_lookup(&ipv6h->saddr, &ipv6h->daddr)) != NULL) {
+	if ((t = ip6_tnl_lookup(&ipv6h->saddr, &ipv6h->daddr)) != NULL) {
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-			read_unlock(&ip6ip6_lock);
+			read_unlock(&ip6_tnl_lock);
 			goto discard;
 		}
 
 		if (!ip6_tnl_rcv_ctl(t)) {
 			t->stat.rx_dropped++;
-			read_unlock(&ip6ip6_lock);
+			read_unlock(&ip6_tnl_lock);
 			goto discard;
 		}
 		secpath_reset(skb);
@@ -709,10 +709,10 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;
 		netif_rx(skb);
-		read_unlock(&ip6ip6_lock);
+		read_unlock(&ip6_tnl_lock);
 		return 0;
 	}
-	read_unlock(&ip6ip6_lock);
+	read_unlock(&ip6_tnl_lock);
 	return 1;
 
 discard:
@@ -750,7 +750,7 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
 }
 
 /**
- * ip6ip6_tnl_addr_conflict - compare packet addresses to tunnel's own
+ * ip6_tnl_addr_conflict - compare packet addresses to tunnel's own
  *   @t: the outgoing tunnel device
  *   @hdr: IPv6 header from the incoming packet
  *
@@ -764,7 +764,7 @@ static void init_tel_txopt(struct ipv6_tel_txoption *opt, __u8 encap_limit)
  **/
 
 static inline int
-ip6ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)
+ip6_tnl_addr_conflict(struct ip6_tnl *t, struct ipv6hdr *hdr)
 {
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
@@ -978,7 +978,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u32 mtu;
 	int err;
 
-	if (!ip6_tnl_xmit_ctl(t) || ip6ip6_tnl_addr_conflict(t, ipv6h))
+	if (!ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
 	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
@@ -1068,7 +1068,7 @@ static void ip6_tnl_set_cap(struct ip6_tnl *t)
 	}
 }
 
-static void ip6ip6_tnl_link_config(struct ip6_tnl *t)
+static void ip6_tnl_link_config(struct ip6_tnl *t)
 {
 	struct net_device *dev = t->dev;
 	struct ip6_tnl_parm *p = &t->parms;
@@ -1121,17 +1121,17 @@ static void ip6ip6_tnl_link_config(struct ip6_tnl *t)
 }
 
 /**
- * ip6ip6_tnl_change - update the tunnel parameters
+ * ip6_tnl_change - update the tunnel parameters
  *   @t: tunnel to be changed
  *   @p: tunnel configuration parameters
  *   @active: != 0 if tunnel is ready for use
  *
  * Description:
- *   ip6ip6_tnl_change() updates the tunnel parameters
+ *   ip6_tnl_change() updates the tunnel parameters
  **/
 
 static int
-ip6ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
+ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
 {
 	ipv6_addr_copy(&t->parms.laddr, &p->laddr);
 	ipv6_addr_copy(&t->parms.raddr, &p->raddr);
@@ -1141,18 +1141,18 @@ ip6ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
 	t->parms.flowinfo = p->flowinfo;
 	t->parms.link = p->link;
 	ip6_tnl_dst_reset(t);
-	ip6ip6_tnl_link_config(t);
+	ip6_tnl_link_config(t);
 	return 0;
 }
 
 /**
- * ip6ip6_tnl_ioctl - configure ipv6 tunnels from userspace
+ * ip6_tnl_ioctl - configure ipv6 tunnels from userspace
  *   @dev: virtual device associated with tunnel
  *   @ifr: parameters passed from userspace
  *   @cmd: command to be performed
  *
  * Description:
- *   ip6ip6_tnl_ioctl() is used for managing IPv6 tunnels
+ *   ip6_tnl_ioctl() is used for managing IPv6 tunnels
  *   from userspace.
  *
  *   The possible commands are the following:
@@ -1174,7 +1174,7 @@ ip6ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
  **/
 
 static int
-ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip6_tnl_parm p;
@@ -1182,12 +1182,12 @@ ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGETTUNNEL:
-		if (dev == ip6ip6_fb_tnl_dev) {
+		if (dev == ip6_fb_tnl_dev) {
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p))) {
 				err = -EFAULT;
 				break;
 			}
-			t = ip6ip6_tnl_locate(&p, 0);
+			t = ip6_tnl_locate(&p, 0);
 		}
 		if (t == NULL)
 			t = netdev_priv(dev);
@@ -1207,8 +1207,8 @@ ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		err = -EINVAL;
 		if (p.proto != IPPROTO_IPV6)
 			break;
-		t = ip6ip6_tnl_locate(&p, cmd == SIOCADDTUNNEL);
-		if (dev != ip6ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
+		t = ip6_tnl_locate(&p, cmd == SIOCADDTUNNEL);
+		if (dev != ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
 			if (t != NULL) {
 				if (t->dev != dev) {
 					err = -EEXIST;
@@ -1217,9 +1217,9 @@ ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			} else
 				t = netdev_priv(dev);
 
-			ip6ip6_tnl_unlink(t);
-			err = ip6ip6_tnl_change(t, &p);
-			ip6ip6_tnl_link(t);
+			ip6_tnl_unlink(t);
+			err = ip6_tnl_change(t, &p);
+			ip6_tnl_link(t);
 			netdev_state_change(dev);
 		}
 		if (t) {
@@ -1235,15 +1235,15 @@ ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			break;
 
-		if (dev == ip6ip6_fb_tnl_dev) {
+		if (dev == ip6_fb_tnl_dev) {
 			err = -EFAULT;
 			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 				break;
 			err = -ENOENT;
-			if ((t = ip6ip6_tnl_locate(&p, 0)) == NULL)
+			if ((t = ip6_tnl_locate(&p, 0)) == NULL)
 				break;
 			err = -EPERM;
-			if (t->dev == ip6ip6_fb_tnl_dev)
+			if (t->dev == ip6_fb_tnl_dev)
 				break;
 			dev = t->dev;
 		}
@@ -1257,20 +1257,20 @@ ip6ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 }
 
 /**
- * ip6ip6_tnl_get_stats - return the stats for tunnel device
+ * ip6_tnl_get_stats - return the stats for tunnel device
  *   @dev: virtual device associated with tunnel
  *
  * Return: stats for device
  **/
 
 static struct net_device_stats *
-ip6ip6_tnl_get_stats(struct net_device *dev)
+ip6_tnl_get_stats(struct net_device *dev)
 {
 	return &(((struct ip6_tnl *)netdev_priv(dev))->stat);
 }
 
 /**
- * ip6ip6_tnl_change_mtu - change mtu manually for tunnel device
+ * ip6_tnl_change_mtu - change mtu manually for tunnel device
  *   @dev: virtual device associated with tunnel
  *   @new_mtu: the new mtu
  *
@@ -1280,7 +1280,7 @@ ip6ip6_tnl_get_stats(struct net_device *dev)
  **/
 
 static int
-ip6ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
+ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu < IPV6_MIN_MTU) {
 		return -EINVAL;
@@ -1290,22 +1290,22 @@ ip6ip6_tnl_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 /**
- * ip6ip6_tnl_dev_setup - setup virtual tunnel device
+ * ip6_tnl_dev_setup - setup virtual tunnel device
  *   @dev: virtual device associated with tunnel
  *
  * Description:
  *   Initialize function pointers and device parameters
  **/
 
-static void ip6ip6_tnl_dev_setup(struct net_device *dev)
+static void ip6_tnl_dev_setup(struct net_device *dev)
 {
 	SET_MODULE_OWNER(dev);
-	dev->uninit = ip6ip6_tnl_dev_uninit;
+	dev->uninit = ip6_tnl_dev_uninit;
 	dev->destructor = free_netdev;
 	dev->hard_start_xmit = ip6_tnl_xmit;
-	dev->get_stats = ip6ip6_tnl_get_stats;
-	dev->do_ioctl = ip6ip6_tnl_ioctl;
-	dev->change_mtu = ip6ip6_tnl_change_mtu;
+	dev->get_stats = ip6_tnl_get_stats;
+	dev->do_ioctl = ip6_tnl_ioctl;
+	dev->change_mtu = ip6_tnl_change_mtu;
 
 	dev->type = ARPHRD_TUNNEL6;
 	dev->hard_header_len = LL_MAX_HEADER + sizeof (struct ipv6hdr);
@@ -1316,12 +1316,12 @@ static void ip6ip6_tnl_dev_setup(struct net_device *dev)
 
 
 /**
- * ip6ip6_tnl_dev_init_gen - general initializer for all tunnel devices
+ * ip6_tnl_dev_init_gen - general initializer for all tunnel devices
  *   @dev: virtual device associated with tunnel
  **/
 
 static inline void
-ip6ip6_tnl_dev_init_gen(struct net_device *dev)
+ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	t->fl.proto = IPPROTO_IPV6;
@@ -1330,31 +1330,31 @@ ip6ip6_tnl_dev_init_gen(struct net_device *dev)
 }
 
 /**
- * ip6ip6_tnl_dev_init - initializer for all non fallback tunnel devices
+ * ip6_tnl_dev_init - initializer for all non fallback tunnel devices
  *   @dev: virtual device associated with tunnel
  **/
 
 static int
-ip6ip6_tnl_dev_init(struct net_device *dev)
+ip6_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	ip6ip6_tnl_dev_init_gen(dev);
-	ip6ip6_tnl_link_config(t);
+	ip6_tnl_dev_init_gen(dev);
+	ip6_tnl_link_config(t);
 	return 0;
 }
 
 /**
- * ip6ip6_fb_tnl_dev_init - initializer for fallback tunnel device
+ * ip6_fb_tnl_dev_init - initializer for fallback tunnel device
  *   @dev: fallback device
  *
  * Return: 0
  **/
 
 static int
-ip6ip6_fb_tnl_dev_init(struct net_device *dev)
+ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	ip6ip6_tnl_dev_init_gen(dev);
+	ip6_tnl_dev_init_gen(dev);
 	dev_hold(dev);
 	tnls_wc[0] = t;
 	return 0;
@@ -1383,27 +1383,27 @@ static int __init ip6_tunnel_init(void)
 	int  err;
 
 	if (xfrm6_tunnel_register(&ip4ip6_handler, AF_INET)) {
-		printk(KERN_ERR "ip4ip6 init: can't register tunnel\n");
+		printk(KERN_ERR "ip6_tunnel init: can't register ip4ip6\n");
 		err = -EAGAIN;
 		goto out;
 	}
 
 	if (xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6)) {
-		printk(KERN_ERR "ip6ip6 init: can't register tunnel\n");
+		printk(KERN_ERR "ip6_tunnel init: can't register ip6ip6\n");
 		err = -EAGAIN;
 		goto unreg_ip4ip6;
 	}
-	ip6ip6_fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
-					 ip6ip6_tnl_dev_setup);
+	ip6_fb_tnl_dev = alloc_netdev(sizeof(struct ip6_tnl), "ip6tnl0",
+				      ip6_tnl_dev_setup);
 
-	if (!ip6ip6_fb_tnl_dev) {
+	if (!ip6_fb_tnl_dev) {
 		err = -ENOMEM;
 		goto fail;
 	}
-	ip6ip6_fb_tnl_dev->init = ip6ip6_fb_tnl_dev_init;
+	ip6_fb_tnl_dev->init = ip6_fb_tnl_dev_init;
 
-	if ((err = register_netdev(ip6ip6_fb_tnl_dev))) {
-		free_netdev(ip6ip6_fb_tnl_dev);
+	if ((err = register_netdev(ip6_fb_tnl_dev))) {
+		free_netdev(ip6_fb_tnl_dev);
 		goto fail;
 	}
 	return 0;
@@ -1415,7 +1415,7 @@ out:
 	return err;
 }
 
-static void __exit ip6ip6_destroy_tunnels(void)
+static void __exit ip6_tnl_destroy_tunnels(void)
 {
 	int h;
 	struct ip6_tnl *t;
@@ -1436,13 +1436,13 @@ static void __exit ip6ip6_destroy_tunnels(void)
 static void __exit ip6_tunnel_cleanup(void)
 {
 	if (xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET))
-		printk(KERN_INFO "ip4ip6 close: can't deregister tunnel\n");
+		printk(KERN_INFO "ip6_tunnel close: can't deregister ip4ip6\n");
 
 	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
-		printk(KERN_INFO "ip6ip6 close: can't deregister tunnel\n");
+		printk(KERN_INFO "ip6_tunnel close: can't deregister ip6ip6\n");
 
 	rtnl_lock();
-	ip6ip6_destroy_tunnels();
+	ip6_tnl_destroy_tunnels();
 	rtnl_unlock();
 }
 

---
commit cf83f0fa3e9dafab6e9f547a1106bd2540732a1f
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Thu Feb 15 01:09:15 2007 +0900

    [IPV6] IP6TUNNEL: Enable to control the handled inner protocol.
    
    ip6_tunnel before supporting IPv4/IPv6 tunnel allows only IPPROTO_IPV6
    in configurations from userland. This allows userland to set IPPROTO_IPIP
    and 0(wildcard). ip6_tunnel only handles allowed inner protocols.
    
    Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 70684e0..d8c84d8 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -384,7 +384,7 @@ parse_tlv_tnl_enc_lim(struct sk_buff *skb, __u8 * raw)
  **/
 
 static int
-ip6_tnl_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
+ip6_tnl_err(struct sk_buff *skb, __u8 ipproto, struct inet6_skb_parm *opt,
 	    int *type, int *code, int *msg, __be32 *info, int offset)
 {
 	struct ipv6hdr *ipv6h = (struct ipv6hdr *) skb->data;
@@ -404,6 +404,9 @@ ip6_tnl_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if ((t = ip6_tnl_lookup(&ipv6h->daddr, &ipv6h->saddr)) == NULL)
 		goto out;
 
+	if (t->parms.proto != ipproto && t->parms.proto != 0)
+		goto out;
+
 	err = 0;
 
 	switch (*type) {
@@ -487,8 +490,8 @@ ip4ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct flowi fl;
 	struct rtable *rt;
 
-	err = ip6_tnl_err(skb, opt, &rel_type, &rel_code, &rel_msg, &rel_info,
-			  offset);
+	err = ip6_tnl_err(skb, IPPROTO_IPIP, opt, &rel_type, &rel_code,
+			  &rel_msg, &rel_info, offset);
 	if (err < 0)
 		return err;
 
@@ -581,8 +584,8 @@ ip6ip6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u32 rel_info = info;
 	int err;
 
-	err = ip6_tnl_err(skb, opt, &rel_type, &rel_code, &rel_msg, &rel_info,
-			  offset);
+	err = ip6_tnl_err(skb, IPPROTO_IPV6, opt, &rel_type, &rel_code,
+			  &rel_msg, &rel_info, offset);
 	if (err < 0)
 		return err;
 
@@ -671,6 +674,7 @@ static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
  **/
 
 static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
+		       __u8 ipproto,
 		       void (*dscp_ecn_decapsulate)(struct ip6_tnl *t,
 						    struct ipv6hdr *ipv6h,
 						    struct sk_buff *skb))
@@ -683,6 +687,11 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 	read_lock(&ip6_tnl_lock);
 
 	if ((t = ip6_tnl_lookup(&ipv6h->saddr, &ipv6h->daddr)) != NULL) {
+		if (t->parms.proto != ipproto && t->parms.proto != 0) {
+			read_unlock(&ip6_tnl_lock);
+			goto discard;
+		}
+
 		if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 			read_unlock(&ip6_tnl_lock);
 			goto discard;
@@ -722,12 +731,14 @@ discard:
 
 static int ip4ip6_rcv(struct sk_buff *skb)
 {
-	return ip6_tnl_rcv(skb, ETH_P_IP, ip4ip6_dscp_ecn_decapsulate);
+	return ip6_tnl_rcv(skb, ETH_P_IP, IPPROTO_IPIP,
+			   ip4ip6_dscp_ecn_decapsulate);
 }
 
 static int ip6ip6_rcv(struct sk_buff *skb)
 {
-	return ip6_tnl_rcv(skb, ETH_P_IPV6, ip6ip6_dscp_ecn_decapsulate);
+	return ip6_tnl_rcv(skb, ETH_P_IPV6, IPPROTO_IPV6,
+			   ip6ip6_dscp_ecn_decapsulate);
 }
 
 struct ipv6_tel_txoption {
@@ -939,7 +950,8 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u32 mtu;
 	int err;
 
-	if (!ip6_tnl_xmit_ctl(t))
+	if ((t->parms.proto != IPPROTO_IPIP && t->parms.proto != 0) ||
+	    !ip6_tnl_xmit_ctl(t))
 		return -1;
 
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
@@ -978,7 +990,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u32 mtu;
 	int err;
 
-	if (!ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
+	if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
+	    !ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
 	if ((offset = parse_tlv_tnl_enc_lim(skb, skb->nh.raw)) > 0) {
@@ -1140,6 +1153,7 @@ ip6_tnl_change(struct ip6_tnl *t, struct ip6_tnl_parm *p)
 	t->parms.encap_limit = p->encap_limit;
 	t->parms.flowinfo = p->flowinfo;
 	t->parms.link = p->link;
+	t->parms.proto = p->proto;
 	ip6_tnl_dst_reset(t);
 	ip6_tnl_link_config(t);
 	return 0;
@@ -1205,7 +1219,8 @@ ip6_tnl_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof (p)))
 			break;
 		err = -EINVAL;
-		if (p.proto != IPPROTO_IPV6)
+		if (p.proto != IPPROTO_IPV6 && p.proto != IPPROTO_IPIP &&
+		    p.proto != 0)
 			break;
 		t = ip6_tnl_locate(&p, cmd == SIOCADDTUNNEL);
 		if (dev != ip6_fb_tnl_dev && cmd == SIOCCHGTUNNEL) {
@@ -1324,7 +1339,6 @@ static inline void
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
-	t->fl.proto = IPPROTO_IPV6;
 	t->dev = dev;
 	strcpy(t->parms.name, dev->name);
 }
@@ -1355,6 +1369,7 @@ ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	ip6_tnl_dev_init_gen(dev);
+	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
 	tnls_wc[0] = t;
 	return 0;

---
commit bd292ad1ccbf15c72351f79d4a130dd50da81613
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Feb 15 02:07:27 2007 +0900

    [IPV6] ADDRCONF: Register inet6_dev earlier.
    
    Allocate inet6_dev earlier to allow users to set up per-interface variables.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c6683ea..42b5cc5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2246,6 +2246,14 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	int run_pending = 0;
 
 	switch(event) {
+	case NETDEV_REGISTER:
+		if (!idev) {
+			idev = ipv6_add_dev(dev);
+			if (!idev)
+				printk(KERN_WARNING "IPv6: add_dev failed for %s\n",
+					dev->name);
+		}
+		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
 		if (event == NETDEV_UP) {

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
