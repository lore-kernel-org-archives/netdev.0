From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] IPv6 Updates for 2.6.21-rc1
Date: Thu, 22 Feb 2007 16:05:15 +0900 (JST)
Message-ID: <20070222.160515.73902189.yoshfuji@linux-ipv6.org>
References: <20070222.131354.132135579.yoshfuji@linux-ipv6.org>
	<20070222.133212.110548597.yoshfuji@linux-ipv6.org>
	<20070221.222400.69214713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	yasuyuki.kozakai@toshiba.co.jp, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57071 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbXBVHFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 02:05:08 -0500
In-Reply-To: <20070221.222400.69214713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070221.222400.69214713.davem@davemloft.net> (at Wed, 21 Feb 2007 22:24:00 -0800 (PST)), David Miller <davem@davemloft.net> says:

> File net/ipv6/addrconf_core.c is still missing even in this
> updated pull, please fix this.
> 
> I ran:
> 
> git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.21-rc1-inet6-20070222b

Urgh...sorry.....

....fixed.  Please pull from new 2.6.21-rc1-inet6-20070222c branch:
  git pull git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git 2.6.21-rc1-inet6-20070222c

Regards,

----
HEADLINES
---------

    [IPV6] ADDRCONF: Statically link __ipv6_addr_type() for sunrpc subsystem.
    [IPV6] IP6TUNNEL: Use update_pmtu() of dst on xmit.
    [IPV6] ADDRCONF: Manage prefix route corresponding to address manually added.
    [IPV6] ADDRCONF: Register inet6_dev earlier.
    [IPV4] devinet: Register inetdev earlier.

DIFFSTAT
--------

 net/ipv4/devinet.c       |    8 ++--
 net/ipv6/Makefile        |    2 -
 net/ipv6/addrconf.c      |   98 ++++++++++------------------------------------
 net/ipv6/addrconf_core.c |   75 +++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_tunnel.c    |    7 +--
 5 files changed, 105 insertions(+), 85 deletions(-)

CHANGESETS
----------

commit c604badbb4e56230915a57b88214fd0c1fec6b89
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Feb 22 02:25:42 2007 +0900

    [IPV6] ADDRCONF: Statically link __ipv6_addr_type() for sunrpc subsystem.
    
    Link __ipv6_addr_type() statically for sunrpc code even if IPv6 is
    built as module.
    
    Signed-off-by: YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 8bacda1..d460017 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -32,6 +32,6 @@ obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 
-obj-y += exthdrs_core.o
+obj-y += addrconf_core.o exthdrs_core.o
 
 obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 569a37d..524bffe 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -211,74 +211,6 @@ const struct in6_addr in6addr_any = IN6ADDR_ANY_INIT;
 #endif
 const struct in6_addr in6addr_loopback = IN6ADDR_LOOPBACK_INIT;
 
-#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
-
-static inline unsigned ipv6_addr_scope2type(unsigned scope)
-{
-	switch(scope) {
-	case IPV6_ADDR_SCOPE_NODELOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
-			IPV6_ADDR_LOOPBACK);
-	case IPV6_ADDR_SCOPE_LINKLOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL) |
-			IPV6_ADDR_LINKLOCAL);
-	case IPV6_ADDR_SCOPE_SITELOCAL:
-		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL) |
-			IPV6_ADDR_SITELOCAL);
-	}
-	return IPV6_ADDR_SCOPE_TYPE(scope);
-}
-
-int __ipv6_addr_type(const struct in6_addr *addr)
-{
-	__be32 st;
-
-	st = addr->s6_addr32[0];
-
-	/* Consider all addresses with the first three bits different of
-	   000 and 111 as unicasts.
-	 */
-	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
-	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
-		return (IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
-
-	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
-		/* multicast */
-		/* addr-select 3.1 */
-		return (IPV6_ADDR_MULTICAST |
-			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
-	}
-
-	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
-		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));		/* addr-select 3.1 */
-	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
-		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
-			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
-
-	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
-		if (addr->s6_addr32[2] == 0) {
-			if (addr->s6_addr32[3] == 0)
-				return IPV6_ADDR_ANY;
-
-			if (addr->s6_addr32[3] == htonl(0x00000001))
-				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
-					IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));	/* addr-select 3.4 */
-
-			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
-				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
-		}
-
-		if (addr->s6_addr32[2] == htonl(0x0000ffff))
-			return (IPV6_ADDR_MAPPED |
-				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
-	}
-
-	return (IPV6_ADDR_RESERVED |
-		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
-}
-
 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
 {
 	if (del_timer(&ifp->timer))
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
new file mode 100644
index 0000000..644e0c7
--- /dev/null
+++ b/net/ipv6/addrconf_core.c
@@ -0,0 +1,75 @@
+/*
+ * IPv6 library code, needed by static components when full IPv6 support is
+ * not configured or static.
+ */
+
+#include <net/ipv6.h>
+
+#define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
+
+static inline unsigned ipv6_addr_scope2type(unsigned scope)
+{
+	switch(scope) {
+	case IPV6_ADDR_SCOPE_NODELOCAL:
+		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_NODELOCAL) |
+			IPV6_ADDR_LOOPBACK);
+	case IPV6_ADDR_SCOPE_LINKLOCAL:
+		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL) |
+			IPV6_ADDR_LINKLOCAL);
+	case IPV6_ADDR_SCOPE_SITELOCAL:
+		return (IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL) |
+			IPV6_ADDR_SITELOCAL);
+	}
+	return IPV6_ADDR_SCOPE_TYPE(scope);
+}
+
+int __ipv6_addr_type(const struct in6_addr *addr)
+{
+	__be32 st;
+
+	st = addr->s6_addr32[0];
+
+	/* Consider all addresses with the first three bits different of
+	   000 and 111 as unicasts.
+	 */
+	if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
+	    (st & htonl(0xE0000000)) != htonl(0xE0000000))
+		return (IPV6_ADDR_UNICAST |
+			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));
+
+	if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
+		/* multicast */
+		/* addr-select 3.1 */
+		return (IPV6_ADDR_MULTICAST |
+			ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)));
+	}
+
+	if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
+		return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST |
+			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));		/* addr-select 3.1 */
+	if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
+		return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST |
+			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_SITELOCAL));		/* addr-select 3.1 */
+
+	if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
+		if (addr->s6_addr32[2] == 0) {
+			if (addr->s6_addr32[3] == 0)
+				return IPV6_ADDR_ANY;
+
+			if (addr->s6_addr32[3] == htonl(0x00000001))
+				return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST |
+					IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_LINKLOCAL));	/* addr-select 3.4 */
+
+			return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST |
+				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
+		}
+
+		if (addr->s6_addr32[2] == htonl(0x0000ffff))
+			return (IPV6_ADDR_MAPPED |
+				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
+	}
+
+	return (IPV6_ADDR_RESERVED |
+		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
+}
+

---
commit d63600593d863d8762f2fa934516f96327ae267e
Author: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Date:   Sun Sep 10 03:59:17 2006 +0900

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
commit 61b4cbe1b9d3ab4cec5ab385c8a574b72be6bbb7
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Wed Feb 7 20:36:26 2007 +0900

    [IPV6] ADDRCONF: Manage prefix route corresponding to address manually added.
    
    It is more natural to manage prefix routes corresponding to address which is
    being added manually.
    
    With help from Masafumi Aramoto <aramoto@linux-ipv6.org>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 524bffe..7a2a715 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1842,6 +1842,7 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 	struct inet6_dev *idev;
 	struct net_device *dev;
 	int scope;
+	u32 flags = RTF_EXPIRES;
 
 	ASSERT_RTNL();
 
@@ -1857,9 +1858,10 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 
 	scope = ipv6_addr_scope(pfx);
 
-	if (valid_lft == INFINITY_LIFE_TIME)
+	if (valid_lft == INFINITY_LIFE_TIME) {
 		ifa_flags |= IFA_F_PERMANENT;
-	else if (valid_lft >= 0x7FFFFFFF/HZ)
+		flags = 0;
+	} else if (valid_lft >= 0x7FFFFFFF/HZ)
 		valid_lft = 0x7FFFFFFF/HZ;
 
 	if (prefered_lft == 0)
@@ -1877,6 +1879,8 @@ static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
 		ifp->tstamp = jiffies;
 		spin_unlock_bh(&ifp->lock);
 
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
+				      jiffies_to_clock_t(valid_lft * HZ), flags);
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 		addrconf_verify(0);
@@ -2056,6 +2060,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
 
 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
 	if (!IS_ERR(ifp)) {
+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
 	}
@@ -2470,10 +2475,6 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags)
 
 	addrconf_join_solict(dev, &ifp->addr);
 
-	if (ifp->prefix_len != 128 && (ifp->flags&IFA_F_PERMANENT))
-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
-					flags);
-
 	net_srandom(ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
@@ -2904,12 +2905,15 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
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
@@ -2928,6 +2932,8 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
 	if (!(ifp->flags&IFA_F_TENTATIVE))
 		ipv6_ifa_notify(0, ifp);
 
+	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
+			      jiffies_to_clock_t(valid_lft * HZ), flags);
 	addrconf_verify(0);
 
 	return 0;

---
commit 95cc3afa51774a3d0bbc1bbbfb300164d7e36913
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Feb 15 02:07:27 2007 +0900

    [IPV6] ADDRCONF: Register inet6_dev earlier.
    
    Allocate inet6_dev earlier to allow users to set up per-interface variables.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7a2a715..f6ac65d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2177,6 +2177,14 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
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
commit 3e6f8dab304a706cbfb65c9f3c382ed954fe0e54
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Feb 22 01:53:47 2007 +0900

    [IPV4] devinet: Register inetdev earlier.
    
    This patch allocates inetdev at registration for all devices
    in line with IPv6.  This allows sysctl configuration on the
    devices to occur before they're brought up or addresses are
    added.
    
    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 8a0ec10..e10794d 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1054,12 +1054,14 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		if (event == NETDEV_REGISTER && dev == &loopback_dev) {
+		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
 			if (!in_dev)
 				panic("devinet: Failed to create loopback\n");
-			in_dev->cnf.no_xfrm = 1;
-			in_dev->cnf.no_policy = 1;
+			if (dev == &loopback_dev) {
+				in_dev->cnf.no_xfrm = 1;
+				in_dev->cnf.no_policy = 1;
+			}
 		}
 		goto out;
 	}

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
