From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 09:49:17 +0900 (JST)
Message-ID: <20080604.094917.75827853.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58040 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbYFDAsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 20:48:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider pulling following fixes on top of net-2.6 tree
available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git net-2.6-misc-20080604b

Regards,

--yoshfuji

HEADLINES
---------

    [SCTP]: Fix NULL dereference of asoc.
    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    [IPv6] addrconf: Check range of prefix length
    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    [IPV6] ADDRCONF: Allow longer lifetime on 64bit archs.
    [IPV6]: Fix the return value of get destination options with NULL data pointer
    [IPV6]: Fix the data length of get destination options with short length
    [IPv6]: Check outgoing interface even if source address is unspecified.
    [IPV6] NETNS: Handle ancillary data in appropriate namespace.

DIFFSTAT
--------

 include/net/addrconf.h     |   22 +++++++++
 include/net/sctp/structs.h |    3 +
 include/net/transp_v6.h    |    3 +
 net/ipv4/tunnel4.c         |    2 -
 net/ipv6/addrconf.c        |  107 ++++++++++++++++++++++++--------------------
 net/ipv6/datagram.c        |   29 +++++++-----
 net/ipv6/ip6_flowlabel.c   |    2 -
 net/ipv6/ipv6_sockglue.c   |    7 ++-
 net/ipv6/raw.c             |    2 -
 net/ipv6/route.c           |   12 +----
 net/ipv6/tunnel6.c         |    2 -
 net/ipv6/udp.c             |    4 +-
 net/sctp/ipv6.c            |    5 +-
 net/sctp/protocol.c        |    3 +
 net/sctp/transport.c       |    2 -
 15 files changed, 121 insertions(+), 84 deletions(-)

CHANGESETS
----------

commit 2e92df9f3f5d8e1d44fa8f74fd189e7f3d63f046
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu May 29 19:55:05 2008 +0900

    [SCTP]: Fix NULL dereference of asoc.
    
    Commit 7cbca67c073263c179f605bdbbdc565ab29d801d introduced
    NULL dereference of asoc to sctp_v6_get_saddr in net/sctp/ipv6.c.
    Pointed out by Johann Felix Soden <johfel@users.sourceforge.net>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0ce0443..917d425 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -548,7 +548,8 @@ struct sctp_af {
 	struct dst_entry *(*get_dst)	(struct sctp_association *asoc,
 					 union sctp_addr *daddr,
 					 union sctp_addr *saddr);
-	void		(*get_saddr)	(struct sctp_association *asoc,
+	void		(*get_saddr)	(struct sctp_sock *sk,
+					 struct sctp_association *asoc,
 					 struct dst_entry *dst,
 					 union sctp_addr *daddr,
 					 union sctp_addr *saddr);
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index e45e44c..e4aac32 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -299,7 +299,8 @@ static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
 /* Fills in the source address(saddr) based on the destination address(daddr)
  * and asoc's bind address list.
  */
-static void sctp_v6_get_saddr(struct sctp_association *asoc,
+static void sctp_v6_get_saddr(struct sctp_sock *sk,
+			      struct sctp_association *asoc,
 			      struct dst_entry *dst,
 			      union sctp_addr *daddr,
 			      union sctp_addr *saddr)
@@ -318,7 +319,7 @@ static void sctp_v6_get_saddr(struct sctp_association *asoc,
 	if (!asoc) {
 		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
 				   &daddr->v6.sin6_addr,
-				   inet6_sk(asoc->base.sk)->srcprefs,
+				   inet6_sk(&sk->inet.sk)->srcprefs,
 				   &saddr->v6.sin6_addr);
 		SCTP_DEBUG_PRINTK("saddr from ipv6_get_saddr: " NIP6_FMT "\n",
 				  NIP6(saddr->v6.sin6_addr));
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 0ec234b..13ee7fa 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -519,7 +519,8 @@ out:
 /* For v4, the source address is cached in the route entry(dst). So no need
  * to cache it separately and hence this is an empty routine.
  */
-static void sctp_v4_get_saddr(struct sctp_association *asoc,
+static void sctp_v4_get_saddr(struct sctp_sock *sk,
+			      struct sctp_association *asoc,
 			      struct dst_entry *dst,
 			      union sctp_addr *daddr,
 			      union sctp_addr *saddr)
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index f4938f6..62082e7 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -291,7 +291,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 	if (saddr)
 		memcpy(&transport->saddr, saddr, sizeof(union sctp_addr));
 	else
-		af->get_saddr(asoc, dst, daddr, &transport->saddr);
+		af->get_saddr(opt, asoc, dst, daddr, &transport->saddr);
 
 	transport->dst = dst;
 	if ((transport->param_flags & SPP_PMTUD_DISABLE) && transport->pathmtu) {

---
commit 1b9c317eb5e2dab9acd205611d825f7f2c401b27
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Jun 4 01:30:25 2008 +0900

    [IPV6] UDP: Possible dst leak in udpv6_sendmsg.
    
    ip6_sk_dst_lookup returns held dst entry. It should be released
    on all paths beyond this point. Add missed release when up->pending
    is set.
    
    Bug report and initial patch by Denis V. Lunev <den@openvz.org>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
    Acked-by: Denis V. Lunev <den@openvz.org>

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1fd784f..47123bf 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -848,12 +848,14 @@ do_append_data:
 		} else {
 			dst_release(dst);
 		}
+		dst = NULL;
 	}
 
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
 out:
+	dst_release(dst);
 	fl6_sock_release(flowlabel);
 	if (!err)
 		return len;

---
commit fa2216e4d0d067196d5b4e1ff38db788dadf41d0
Author: Thomas Graf <tgraf@suug.ch>
Date:   Wed May 28 16:54:22 2008 +0200

    [IPv6] addrconf: Check range of prefix length
    
    As of now, the prefix length is not vaildated when adding or deleting
    addresses. The value is passed directly into the inet6_ifaddr structure
    and later passed on to memcmp() as length indicator which relies on
    the value never to exceed 128 (bits).
    
    Due to the missing check, the currently code allows for any 8 bit
    value to be passed on as prefix length while using the netlink
    interface, and any 32 bit value while using the ioctl interface.
    
    [Use unsigned int instead to generate better code - yoshfuji]
    
    Signed-off-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a83557..c3b20c5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2027,7 +2027,7 @@ err_exit:
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
-			  int plen, __u8 ifa_flags, __u32 prefered_lft,
+			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
 			  __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
@@ -2039,6 +2039,9 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 
 	ASSERT_RTNL();
 
+	if (plen > 128)
+		return -EINVAL;
+
 	/* check the lifetime */
 	if (!valid_lft || prefered_lft > valid_lft)
 		return -EINVAL;
@@ -2095,12 +2098,15 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 }
 
 static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
-			  int plen)
+			  unsigned int plen)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
 
+	if (plen > 128)
+		return -EINVAL;
+
 	dev = __dev_get_by_index(net, ifindex);
 	if (!dev)
 		return -ENODEV;

---
commit c2ef5867d16851caa5bf614f2eb4c12f10e1f3d4
Author: Colin <colins@sjtu.edu.cn>
Date:   Tue May 27 00:04:43 2008 +0800

    [IPV6] TUNNEL6: Fix incoming packet length check for inter-protocol tunnel.
    
    I discover a strange behavior in [ipv4 in ipv6] tunnel. When IPv6 tunnel
    payload is less than 40(0x28), packet can be sent to network, received in
    physical interface, but not seen in IP tunnel interface. No counter increase
    in tunnel interface.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/tunnel6.c b/net/ipv6/tunnel6.c
index 6323921..669f280 100644
--- a/net/ipv6/tunnel6.c
+++ b/net/ipv6/tunnel6.c
@@ -109,7 +109,7 @@ static int tunnel46_rcv(struct sk_buff *skb)
 {
 	struct xfrm6_tunnel *handler;
 
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto drop;
 
 	for (handler = tunnel46_handlers; handler; handler = handler->next)

---
commit de4eae0af5c46f83b6c232deac85b3398a4ce17f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri May 30 11:35:03 2008 +0900

    [IPV4] TUNNEL4: Fix incoming packet length check for inter-protocol tunnel.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/tunnel4.c b/net/ipv4/tunnel4.c
index d3b709a..cb1f0e8 100644
--- a/net/ipv4/tunnel4.c
+++ b/net/ipv4/tunnel4.c
@@ -97,7 +97,7 @@ static int tunnel64_rcv(struct sk_buff *skb)
 {
 	struct xfrm_tunnel *handler;
 
-	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto drop;
 
 	for (handler = tunnel64_handlers; handler; handler = handler->next)

---
commit 3ea31eb2cd7bba919fbe9fc00e13256140e59d3f
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Tue May 27 17:37:49 2008 +0900

    [IPV6] ADDRCONF: Allow longer lifetime on 64bit archs.
    
    - Allow longer lifetimes (>= 0x7fffffff/HZ) on 64bit archs
      by using unsigned long.
    - Shadow this arithmetic overflow workaround by introducing
      helper functions: addrconf_timeout_fixup() and
      addrconf_finite_timeout().
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 0a2f037..7dbb389 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -94,6 +94,28 @@ extern void			addrconf_join_solict(struct net_device *dev,
 extern void			addrconf_leave_solict(struct inet6_dev *idev,
 					struct in6_addr *addr);
 
+static inline unsigned long	addrconf_timeout_fixup(u32 timeout,
+						       unsigned unit)
+{
+	if (timeout == 0xffffffff)
+		return ~0UL;
+
+	/*
+	 * Avoid arithmetic overflow.
+	 * Assuming unit is constant and non-zero, this "if" statement
+	 * will go away on 64bit archs.
+	 */
+	if (0xfffffffe > LONG_MAX / unit && timeout > LONG_MAX / unit)
+		return LONG_MAX / unit;
+
+	return timeout;
+}
+
+static inline int		addrconf_finite_timeout(unsigned long timeout)
+{
+	return (~timeout);
+}
+
 /*
  *	IPv6 Address Label subsystem (addrlabel.c)
  */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c3b20c5..147588f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -731,8 +731,13 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 						onlink = -1;
 
 					spin_lock(&ifa->lock);
-					lifetime = min_t(unsigned long,
-							 ifa->valid_lft, 0x7fffffffUL/HZ);
+
+					lifetime = addrconf_timeout_fixup(ifa->valid_lft, HZ);
+					/*
+					 * Note: Because this address is
+					 * not permanent, lifetime <
+					 * LONG_MAX / HZ here.
+					 */
 					if (time_before(expires,
 							ifa->tstamp + lifetime * HZ))
 						expires = ifa->tstamp + lifetime * HZ;
@@ -1722,7 +1727,6 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	__u32 valid_lft;
 	__u32 prefered_lft;
 	int addr_type;
-	unsigned long rt_expires;
 	struct inet6_dev *in6_dev;
 
 	pinfo = (struct prefix_info *) opt;
@@ -1764,28 +1768,23 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 	 *	2) Configure prefixes with the auto flag set
 	 */
 
-	if (valid_lft == INFINITY_LIFE_TIME)
-		rt_expires = ~0UL;
-	else if (valid_lft >= 0x7FFFFFFF/HZ) {
+	if (pinfo->onlink) {
+		struct rt6_info *rt;
+		unsigned long rt_expires;
+
 		/* Avoid arithmetic overflow. Really, we could
 		 * save rt_expires in seconds, likely valid_lft,
 		 * but it would require division in fib gc, that it
 		 * not good.
 		 */
-		rt_expires = 0x7FFFFFFF - (0x7FFFFFFF % HZ);
-	} else
-		rt_expires = valid_lft * HZ;
+		if (HZ > USER_HZ)
+			rt_expires = addrconf_timeout_fixup(valid_lft, HZ);
+		else
+			rt_expires = addrconf_timeout_fixup(valid_lft, USER_HZ);
 
-	/*
-	 * We convert this (in jiffies) to clock_t later.
-	 * Avoid arithmetic overflow there as well.
-	 * Overflow can happen only if HZ < USER_HZ.
-	 */
-	if (HZ < USER_HZ && ~rt_expires && rt_expires > 0x7FFFFFFF / USER_HZ)
-		rt_expires = 0x7FFFFFFF / USER_HZ;
+		if (addrconf_finite_timeout(rt_expires))
+			rt_expires *= HZ;
 
-	if (pinfo->onlink) {
-		struct rt6_info *rt;
 		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
 				dev->ifindex, 1);
 
@@ -1794,7 +1793,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 			if (valid_lft == 0) {
 				ip6_del_rt(rt);
 				rt = NULL;
-			} else if (~rt_expires) {
+			} else if (addrconf_finite_timeout(rt_expires)) {
 				/* not infinity */
 				rt->rt6i_expires = jiffies + rt_expires;
 				rt->rt6i_flags |= RTF_EXPIRES;
@@ -1803,9 +1802,9 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
 				rt->rt6i_expires = 0;
 			}
 		} else if (valid_lft) {
-			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
 			clock_t expires = 0;
-			if (~rt_expires) {
+			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
+			if (addrconf_finite_timeout(rt_expires)) {
 				/* not infinity */
 				flags |= RTF_EXPIRES;
 				expires = jiffies_to_clock_t(rt_expires);
@@ -2036,6 +2035,7 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	int scope;
 	u32 flags;
 	clock_t expires;
+	unsigned long timeout;
 
 	ASSERT_RTNL();
 
@@ -2055,22 +2055,23 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 
 	scope = ipv6_addr_scope(pfx);
 
-	if (valid_lft == INFINITY_LIFE_TIME) {
-		ifa_flags |= IFA_F_PERMANENT;
-		flags = 0;
-		expires = 0;
-	} else {
-		if (valid_lft >= 0x7FFFFFFF/HZ)
-			valid_lft = 0x7FFFFFFF/HZ;
+	timeout = addrconf_timeout_fixup(valid_lft, HZ);
+	if (addrconf_finite_timeout(timeout)) {
+		expires = jiffies_to_clock_t(timeout * HZ);
+		valid_lft = timeout;
 		flags = RTF_EXPIRES;
-		expires = jiffies_to_clock_t(valid_lft * HZ);
+	} else {
+		expires = 0;
+		flags = 0;
+		ifa_flags |= IFA_F_PERMANENT;
 	}
 
-	if (prefered_lft == 0)
-		ifa_flags |= IFA_F_DEPRECATED;
-	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
-		 (prefered_lft != INFINITY_LIFE_TIME))
-		prefered_lft = 0x7FFFFFFF/HZ;
+	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
+	if (addrconf_finite_timeout(timeout)) {
+		if (timeout == 0)
+			ifa_flags |= IFA_F_DEPRECATED;
+		prefered_lft = timeout;
+	}
 
 	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
 
@@ -3175,26 +3176,28 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 {
 	u32 flags;
 	clock_t expires;
+	unsigned long timeout;
 
 	if (!valid_lft || (prefered_lft > valid_lft))
 		return -EINVAL;
 
-	if (valid_lft == INFINITY_LIFE_TIME) {
-		ifa_flags |= IFA_F_PERMANENT;
-		flags = 0;
-		expires = 0;
-	} else {
-		if (valid_lft >= 0x7FFFFFFF/HZ)
-			valid_lft = 0x7FFFFFFF/HZ;
+	timeout = addrconf_timeout_fixup(valid_lft, HZ);
+	if (addrconf_finite_timeout(timeout)) {
+		expires = jiffies_to_clock_t(timeout * HZ);
+		valid_lft = timeout;
 		flags = RTF_EXPIRES;
-		expires = jiffies_to_clock_t(valid_lft * HZ);
+	} else {
+		expires = 0;
+		flags = 0;
+		ifa_flags |= IFA_F_PERMANENT;
 	}
 
-	if (prefered_lft == 0)
-		ifa_flags |= IFA_F_DEPRECATED;
-	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
-		 (prefered_lft != INFINITY_LIFE_TIME))
-		prefered_lft = 0x7FFFFFFF/HZ;
+	timeout = addrconf_timeout_fixup(prefered_lft, HZ);
+	if (addrconf_finite_timeout(timeout)) {
+		if (timeout == 0)
+			ifa_flags |= IFA_F_DEPRECATED;
+		prefered_lft = timeout;
+	}
 
 	spin_lock_bh(&ifp->lock);
 	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 48534c6..220cffe 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -446,7 +446,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	struct route_info *rinfo = (struct route_info *) opt;
 	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
-	u32 lifetime;
+	unsigned long lifetime;
 	struct rt6_info *rt;
 
 	if (len < sizeof(struct route_info)) {
@@ -472,13 +472,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	if (pref == ICMPV6_ROUTER_PREF_INVALID)
 		pref = ICMPV6_ROUTER_PREF_MEDIUM;
 
-	lifetime = ntohl(rinfo->lifetime);
-	if (lifetime == 0xffffffff) {
-		/* infinity */
-	} else if (lifetime > 0x7fffffff/HZ - 1) {
-		/* Avoid arithmetic overflow */
-		lifetime = 0x7fffffff/HZ - 1;
-	}
+	lifetime = addrconf_timeout_fixup(ntohl(rinfo->lifetime), HZ);
 
 	if (rinfo->length == 3)
 		prefix = (struct in6_addr *)rinfo->prefix;
@@ -506,7 +500,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 				 (rt->rt6i_flags & ~RTF_PREF_MASK) | RTF_PREF(pref);
 
 	if (rt) {
-		if (lifetime == 0xffffffff) {
+		if (!addrconf_finite_timeout(lifetime)) {
 			rt->rt6i_flags &= ~RTF_EXPIRES;
 		} else {
 			rt->rt6i_expires = jiffies + HZ * lifetime;

---
commit 260009881fcd9b493509b6dba3bfdeb6fc0301c0
Author: Yang Hongyang <yanghy@cn.fujitsu.com>
Date:   Wed May 28 16:23:47 2008 +0800

    [IPV6]: Fix the return value of get destination options with NULL data pointer
    
    If we pass NULL data buffer to getsockopt(), it will return 0,
    and the option length is set to -EFAULT:
        getsockopt(sk, IPPROTO_IPV6, IPV6_DSTOPTS, NULL, &len);
    
    This is because ipv6_getsockopt_sticky() will return -EFAULT or
    -EINVAL if some error occur.
    
    This patch fix this problem.
    
    Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 56d55fe..aa7bedf 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -975,6 +975,9 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		len = ipv6_getsockopt_sticky(sk, np->opt,
 					     optname, optval, len);
 		release_sock(sk);
+		/* check if ipv6_getsockopt_sticky() returns err code */
+		if (len < 0)
+			return len;
 		return put_user(len, optlen);
 	}
 

---
commit d012a10181a0ae54e2c45f4917628320cdfa422b
Author: Yang Hongyang <yanghy@cn.fujitsu.com>
Date:   Wed May 28 16:27:28 2008 +0800

    [IPV6]: Fix the data length of get destination options with short length
    
     If get destination options with length which is not enough for that
    option,getsockopt() will still return the real length of the option,
    which is larger then the buffer space.
     This is because ipv6_getsockopt_sticky() returns the real length of
    the option.
    
    This patch fix this problem.
    
    Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index aa7bedf..9293b9f 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -832,7 +832,7 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	len = min_t(unsigned int, len, ipv6_optlen(hdr));
 	if (copy_to_user(optval, hdr, len))
 		return -EFAULT;
-	return ipv6_optlen(hdr);
+	return len;
 }
 
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,

---
commit c878bc2da63acd3b80ba4cf428702f6e98c55b3c
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Jun 2 18:45:23 2008 +0900

    [IPv6]: Check outgoing interface even if source address is unspecified.
    
    The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
    ancillary data, is not checked if the source address (ipi6_addr)
    is unspecified.  If the ipi6_ifindex is the not-exist interface,
    it should be fail and the errno should be set ENODEV.
    
    Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
    
    Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..76d4ab4 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -535,27 +535,29 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 				fl->oif = src_info->ipi6_ifindex;
 			}
 
-			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+			if (fl->oif) {
+				dev = dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			}
 
-			if (addr_type == IPV6_ADDR_ANY)
+			addr_type = ipv6_addr_type(&src_info->ipi6_addr);
+			if (addr_type == IPV6_ADDR_ANY) {
+				if (dev)
+					dev_put(dev);
 				break;
-
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev = dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
 			}
-			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+
+			if (((addr_type & IPV6_ADDR_LINKLOCAL) &&
+			     !src_info->ipi6_ifindex) ||
+			    !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
 				err = -EINVAL;
 				goto exit_f;
 			}
+
 			if (dev)
 				dev_put(dev);
 

---
commit 980d564cdb2c6301738a6ff29e4b78fd9a3337fe
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Jun 2 18:52:16 2008 +0900

    [IPV6] NETNS: Handle ancillary data in appropriate namespace.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 27394e0..112934a 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -40,7 +40,8 @@ extern int			datagram_recv_ctl(struct sock *sk,
 						  struct msghdr *msg,
 						  struct sk_buff *skb);
 
-extern int			datagram_send_ctl(struct msghdr *msg,
+extern int			datagram_send_ctl(struct net *net,
+						  struct msghdr *msg,
 						  struct flowi *fl,
 						  struct ipv6_txoptions *opt,
 						  int *hlimit, int *tclass);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 76d4ab4..19fec90 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -496,7 +496,8 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
+int datagram_send_ctl(struct net *net,
+		      struct msghdr *msg, struct flowi *fl,
 		      struct ipv6_txoptions *opt,
 		      int *hlimit, int *tclass)
 {
@@ -536,7 +537,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 			}
 
 			if (fl->oif) {
-				dev = dev_get_by_index(&init_net, fl->oif);
+				dev = dev_get_by_index(net, fl->oif);
 				if (!dev)
 					return -ENODEV;
 			}
@@ -550,7 +551,7 @@ int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
 
 			if (((addr_type & IPV6_ADDR_LINKLOCAL) &&
 			     !src_info->ipi6_ifindex) ||
-			    !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+			    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index eb7a940..37a4e77 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -354,7 +354,7 @@ fl_create(struct net *net, struct in6_flowlabel_req *freq, char __user *optval,
 		msg.msg_control = (void*)(fl->opt+1);
 		flowi.oif = 0;
 
-		err = datagram_send_ctl(&msg, &flowi, fl->opt, &junk, &junk);
+		err = datagram_send_ctl(net, &msg, &flowi, fl->opt, &junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 9293b9f..3eef8e5 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -416,7 +416,7 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
+		retv = datagram_send_ctl(net, &msg, &fl, opt, &junk, &junk);
 		if (retv)
 			goto done;
 update:
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 232e0dc..603df76 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -813,7 +813,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 47123bf..1b35c47 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -731,7 +731,7 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(msg, &fl, opt, &hlimit, &tclass);
+		err = datagram_send_ctl(sock_net(sk), msg, &fl, opt, &hlimit, &tclass);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
