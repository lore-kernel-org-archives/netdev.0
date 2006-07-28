From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC] [IPV6] ADDRCONF: Lifetime handling fixes
Date: Fri, 28 Jul 2006 18:25:34 +0900 (JST)
Message-ID: <20060728.182534.15142799.yoshfuji@linux-ipv6.org>
References: <20060727.194929.796987341.takamiya@po.ntts.co.jp>
	<20060728.011103.21926965.davem@davemloft.net>
	<20060728.171818.37443466.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, hsantos@av.it.pt, vnuorval@tcs.hut.fi,
	anttit@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:13575 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161110AbWG1JYK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 05:24:10 -0400
To: davem@davemloft.net
In-Reply-To: <20060728.171818.37443466.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060728.171818.37443466.yoshfuji@linux-ipv6.org> (at Fri, 28 Jul 2006 17:18:18 +0900 (JST)), YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> says:

> In article <20060728.011103.21926965.davem@davemloft.net> (at Fri, 28 Jul 2006 01:11:03 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > Besides this correction, the rest of the changes look fine to me.
> > I think we should get these fixes into 2.6.18, if you don't mind.
> > 
> > So please resubmit with the correction.
> 
> Okay. I'll do this soon.

Here it is.

Changesets, on top of 2.6.18-rc2, are available on
branch "addr-lifetime-20060728b" at:
    git://git.skbuff.net/gitroot/yoshfuji/linux-2.6.18-rc2-addr-lifetime

Regards,

HEADLINES
---------

    [IPV6] ADDRCONF: Check payload length for IFA_LOCAL attribute in RTM_{ADD,DEL}MSG message
    [IPV6] ADDRCONF: Allow user-space to specify address lifetime
    [IPV6] ADDRCONF: Do not verify an address with infinity lifetime
    [IPV6] ADDRCONF: Support get operation of single address
    [IPV6] ADDRCONF: NLM_F_REPLACE support for RTM_NEWADDR

DIFFSTAT
--------

 net/ipv6/addrconf.c |  174 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 166 insertions(+), 8 deletions(-)

CHANGESETS
----------

commit 27fb40230b30534bdc08736d64cab179038591bc
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Jul 28 18:12:09 2006 +0900

    [IPV6] ADDRCONF: Check payload length for IFA_LOCAL attribute in RTM_{ADD,DEL}MSG message
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 2316a43..81702b9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2853,7 +2853,8 @@ inet6_rtm_deladdr(struct sk_buff *skb, s
 		pfx = RTA_DATA(rta[IFA_ADDRESS-1]);
 	}
 	if (rta[IFA_LOCAL-1]) {
-		if (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx)))
+		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*pfx) ||
+		    (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx))))
 			return -EINVAL;
 		pfx = RTA_DATA(rta[IFA_LOCAL-1]);
 	}
@@ -2877,7 +2878,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		pfx = RTA_DATA(rta[IFA_ADDRESS-1]);
 	}
 	if (rta[IFA_LOCAL-1]) {
-		if (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx)))
+		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*pfx) ||
+		    (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx))))
 			return -EINVAL;
 		pfx = RTA_DATA(rta[IFA_LOCAL-1]);
 	}

---
commit 336f472519a05ea493c5ad24de2c39e2c80003a0
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Fri Jul 28 18:12:10 2006 +0900

    [IPV6] ADDRCONF: Allow user-space to specify address lifetime
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 81702b9..c064188 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1869,15 +1869,21 @@ err_exit:
 /*
  *	Manual configuration of address on an interface
  */
-static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen)
+static int inet6_addr_add(int ifindex, struct in6_addr *pfx, int plen,
+			  __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
+	__u8 ifa_flags = 0;
 	int scope;
 
 	ASSERT_RTNL();
 	
+	/* check the lifetime */
+	if (!valid_lft || prefered_lft > valid_lft)
+		return -EINVAL;
+
 	if ((dev = __dev_get_by_index(ifindex)) == NULL)
 		return -ENODEV;
 	
@@ -1889,10 +1895,29 @@ static int inet6_addr_add(int ifindex, s
 
 	scope = ipv6_addr_scope(pfx);
 
-	ifp = ipv6_add_addr(idev, pfx, plen, scope, IFA_F_PERMANENT);
+	if (valid_lft == INFINITY_LIFE_TIME)
+		ifa_flags |= IFA_F_PERMANENT;
+	else if (valid_lft >= 0x7FFFFFFF/HZ)
+		valid_lft = 0x7FFFFFFF/HZ;
+
+	if (prefered_lft == 0)
+		ifa_flags |= IFA_F_DEPRECATED;
+	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
+		 (prefered_lft != INFINITY_LIFE_TIME))
+		prefered_lft = 0x7FFFFFFF/HZ;
+
+	ifp = ipv6_add_addr(idev, pfx, plen, scope, ifa_flags);
+
 	if (!IS_ERR(ifp)) {
+		spin_lock(&ifp->lock);
+		ifp->valid_lft = valid_lft;
+		ifp->prefered_lft = prefered_lft;
+		ifp->tstamp = jiffies;
+		spin_unlock(&ifp->lock);
+
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
+		addrconf_verify(0);
 		return 0;
 	}
 
@@ -1945,7 +1970,8 @@ int addrconf_add_ifaddr(void __user *arg
 		return -EFAULT;
 
 	rtnl_lock();
-	err = inet6_addr_add(ireq.ifr6_ifindex, &ireq.ifr6_addr, ireq.ifr6_prefixlen);
+	err = inet6_addr_add(ireq.ifr6_ifindex, &ireq.ifr6_addr, ireq.ifr6_prefixlen,
+			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	rtnl_unlock();
 	return err;
 }
@@ -2870,6 +2896,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	struct rtattr  **rta = arg;
 	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
 	struct in6_addr *pfx;
+	__u32 valid_lft = INFINITY_LIFE_TIME, prefered_lft = INFINITY_LIFE_TIME;
 
 	pfx = NULL;
 	if (rta[IFA_ADDRESS-1]) {
@@ -2886,7 +2913,18 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	if (pfx == NULL)
 		return -EINVAL;
 
-	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen);
+	if (rta[IFA_CACHEINFO-1]) {
+		struct ifa_cacheinfo *ci;
+		if (RTA_PAYLOAD(rta[IFA_CACHEINFO-1]) < sizeof(*ci))
+			return -EINVAL;
+		ci = RTA_DATA(rta[IFA_CACHEINFO-1]);
+		valid_lft = ci->ifa_valid;
+		prefered_lft = ci->ifa_prefered;
+	}
+
+	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
+			      prefered_lft, valid_lft);
+
 }
 
 /* Maximum length of ifa_cacheinfo attributes */

---
commit 28a22216f2d553020e2d15d3b1a9ab9306623e6b
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Jul 28 18:12:11 2006 +0900

    [IPV6] ADDRCONF: Do not verify an address with infinity lifetime
    
    We also do not try regenarating new temporary address corresponding to an
    address with infinite preferred lifetime.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c064188..93a40a8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2797,12 +2797,16 @@ #ifdef CONFIG_IPV6_PRIVACY
 					ifp->idev->nd_parms->retrans_time / HZ;
 #endif
 
-			if (age >= ifp->valid_lft) {
+			if (ifp->valid_lft != INFINITY_LIFE_TIME &&
+			    age >= ifp->valid_lft) {
 				spin_unlock(&ifp->lock);
 				in6_ifa_hold(ifp);
 				read_unlock(&addrconf_hash_lock);
 				ipv6_del_addr(ifp);
 				goto restart;
+			} else if (ifp->prefered_lft == INFINITY_LIFE_TIME) {
+				spin_unlock(&ifp->lock);
+				continue;
 			} else if (age >= ifp->prefered_lft) {
 				/* jiffies - ifp->tsamp > age >= ifp->prefered_lft */
 				int deprecate = 0;

---
commit eb682da0e66556e23c7c4da73e4808d0b7a29484
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Fri Jul 28 18:12:12 2006 +0900

    [IPV6] ADDRCONF: Support get operation of single address
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 93a40a8..3ef3fe2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3165,6 +3165,62 @@ static int inet6_dump_ifacaddr(struct sk
 	return inet6_dump_addr(skb, cb, type);
 }
 
+static int inet6_rtm_getaddr(struct sk_buff *in_skb,
+		struct nlmsghdr* nlh, void *arg)
+{
+	struct rtattr **rta = arg;
+	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct in6_addr *addr = NULL;
+	struct net_device *dev = NULL;
+	struct inet6_ifaddr *ifa;
+	struct sk_buff *skb;
+	int size = NLMSG_SPACE(sizeof(struct ifaddrmsg) + INET6_IFADDR_RTA_SPACE);
+	int err;
+
+	if (rta[IFA_ADDRESS-1]) {
+		if (RTA_PAYLOAD(rta[IFA_ADDRESS-1]) < sizeof(*addr))
+			return -EINVAL;
+		addr = RTA_DATA(rta[IFA_ADDRESS-1]);
+	}
+	if (rta[IFA_LOCAL-1]) {
+		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*addr) ||
+		    (addr && memcmp(addr, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*addr))))
+			return -EINVAL;
+		addr = RTA_DATA(rta[IFA_LOCAL-1]);
+	}
+	if (addr == NULL)
+		return -EINVAL;
+
+	if (ifm->ifa_index)
+		dev = __dev_get_by_index(ifm->ifa_index);
+
+	if ((ifa = ipv6_get_ifaddr(addr, dev, 1)) == NULL)
+		return -EADDRNOTAVAIL;
+
+	if ((skb = alloc_skb(size, GFP_KERNEL)) == NULL) {
+		err = -ENOBUFS;
+		goto out;
+	}
+
+	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
+	err = inet6_fill_ifaddr(skb, ifa, NETLINK_CB(in_skb).pid,
+				nlh->nlmsg_seq, RTM_NEWADDR, 0);
+	if (err < 0) {
+		err = -EMSGSIZE;
+		goto out_free;
+	}
+
+	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
+	if (err > 0)
+		err = 0;
+out:
+	in6_ifa_put(ifa);
+	return err;
+out_free:
+	kfree_skb(skb);
+	goto out;
+}
+
 static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 {
 	struct sk_buff *skb;
@@ -3407,7 +3463,8 @@ static struct rtnetlink_link inet6_rtnet
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
 	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
-	[RTM_GETADDR - RTM_BASE] = { .dumpit	= inet6_dump_ifaddr, },
+	[RTM_GETADDR - RTM_BASE] = { .doit	= inet6_rtm_getaddr,
+				     .dumpit	= inet6_dump_ifaddr, },
 	[RTM_GETMULTICAST - RTM_BASE] = { .dumpit = inet6_dump_ifmcaddr, },
 	[RTM_GETANYCAST - RTM_BASE] = { .dumpit	= inet6_dump_ifacaddr, },
 	[RTM_NEWROUTE - RTM_BASE] = { .doit	= inet6_rtm_newroute, },

---
commit 1a4b3b795b8d5d3b4a746b038b6ba4ddddf9d32c
Author: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date:   Fri Jul 28 18:12:13 2006 +0900

    [IPV6] ADDRCONF: NLM_F_REPLACE support for RTM_NEWADDR
    
    Based on MIPL2 kernel patch.
    
    Signed-off-by: Noriaki YAKAMIYA <takamiya@po.ntts.co.jp>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3ef3fe2..8ea1e36 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2895,6 +2895,55 @@ inet6_rtm_deladdr(struct sk_buff *skb, s
 }
 
 static int
+inet6_addr_modify(int ifindex, struct in6_addr *pfx,
+		  __u32 prefered_lft, __u32 valid_lft)
+{
+	struct inet6_ifaddr *ifp = NULL;
+	struct net_device *dev;
+	int ifa_flags = 0;
+
+	if ((dev = __dev_get_by_index(ifindex)) == NULL)
+		return -ENODEV;
+
+	if (!(dev->flags&IFF_UP))
+		return -ENETDOWN;
+
+	if (!valid_lft || (prefered_lft > valid_lft))
+		return -EINVAL;
+
+	ifp = ipv6_get_ifaddr(pfx, dev, 1);
+	if (ifp == NULL)
+		return -ENOENT;
+
+	if (valid_lft == INFINITY_LIFE_TIME)
+		ifa_flags = IFA_F_PERMANENT;
+	else if (valid_lft >= 0x7FFFFFFF/HZ)
+		valid_lft = 0x7FFFFFFF/HZ;
+
+	if (prefered_lft == 0)
+		ifa_flags = IFA_F_DEPRECATED;
+	else if ((prefered_lft >= 0x7FFFFFFF/HZ) &&
+		 (prefered_lft != INFINITY_LIFE_TIME))
+		prefered_lft = 0x7FFFFFFF/HZ;
+
+	spin_lock_bh(&ifp->lock);
+	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED|IFA_F_PERMANENT)) | ifa_flags;
+
+	ifp->tstamp = jiffies;
+	ifp->valid_lft = valid_lft;
+	ifp->prefered_lft = prefered_lft;
+
+	spin_unlock_bh(&ifp->lock);
+	if (!(ifp->flags&IFA_F_TENTATIVE))
+		ipv6_ifa_notify(0, ifp);
+	in6_ifa_put(ifp);
+
+	addrconf_verify(0);
+
+	return 0;
+}
+
+static int
 inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct rtattr  **rta = arg;
@@ -2926,6 +2975,14 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 		prefered_lft = ci->ifa_prefered;
 	}
 
+	if (nlh->nlmsg_flags & NLM_F_REPLACE) {
+		int ret;
+		ret = inet6_addr_modify(ifm->ifa_index, pfx,
+					prefered_lft, valid_lft);
+		if (ret == 0 || !(nlh->nlmsg_flags & NLM_F_CREATE))
+			return ret;
+	}
+
 	return inet6_addr_add(ifm->ifa_index, pfx, ifm->ifa_prefixlen,
 			      prefered_lft, valid_lft);
 

---


-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
