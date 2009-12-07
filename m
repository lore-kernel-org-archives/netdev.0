From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH/RFC] Adding IP(v6) address with scope link creates global
 address
Date: Mon, 7 Dec 2009 14:41:08 +0100
Message-ID: <20091207134108.GA23087@amd64.fatal.se>
References: <20091125135945.GA7195@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:59079 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934963AbZLGNjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 08:39:45 -0500
Received: from ipb2.telenor.se (195.54.127.165) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA0176A0E1 for netdev@vger.kernel.org; Mon, 7 Dec 2009 14:39:48 +0100
Content-Disposition: inline
In-Reply-To: <20091125135945.GA7195@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello again!

Replying to myself (see http://www.spinics.net/lists/netdev/msg113943.html)
and attaching an untested patch to see if this sparks more interest.

On Wed, Nov 25, 2009 at 02:59:45PM +0100, Andreas Henriksson wrote:
> "Jedasothi" reported problems setting scope with iproute on newly added
> ipv6 addresses in:
> https://bugs.launchpad.net/ubuntu/+source/iproute/+bug/487745
> 
> > To reproduce bug run
> > ip addr add '::4/64' scope link dev eth0
> >
> > This results in a line seen with
> > ip addr show eth0
> > inet6 ::4/64 scope global tentative
> >
> > The label "global" is seen instead of "link".

I'd appreciate if someone could review and test this:


diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1fd0a3d..64d6d35 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2083,13 +2083,12 @@ err_exit:
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
-			  unsigned int plen, __u8 ifa_flags, __u32 prefered_lft,
-			  __u32 valid_lft)
+			  unsigned int plen, __u8 ifa_flags, int scope,
+			  __u32 prefered_lft, __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
 	struct net_device *dev;
-	int scope;
 	u32 flags;
 	clock_t expires;
 	unsigned long timeout;
@@ -2110,7 +2109,8 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	if ((idev = addrconf_add_dev(dev)) == NULL)
 		return -ENOBUFS;
 
-	scope = ipv6_addr_scope(pfx);
+	if (scope == 0)
+		scope = ipv6_addr_scope(pfx);
 
 	timeout = addrconf_timeout_fixup(valid_lft, HZ);
 	if (addrconf_finite_timeout(timeout)) {
@@ -2207,7 +2207,7 @@ int addrconf_add_ifaddr(struct net *net, void __user *arg)
 
 	rtnl_lock();
 	err = inet6_addr_add(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
-			     ireq.ifr6_prefixlen, IFA_F_PERMANENT,
+			     ireq.ifr6_prefixlen, IFA_F_PERMANENT, 0,
 			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	rtnl_unlock();
 	return err;
@@ -3328,6 +3328,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 		 */
 		return inet6_addr_add(net, ifm->ifa_index, pfx,
 				      ifm->ifa_prefixlen, ifa_flags,
+				      ifm->ifa_scope,
 				      preferred_lft, valid_lft);
 	}
 
