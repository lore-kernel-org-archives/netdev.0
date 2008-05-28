From: Thomas Graf <tgraf@suug.ch>
Subject: [IPv6] addrconf: Check range of prefix length
Date: Wed, 28 May 2008 16:54:22 +0200
Message-ID: <20080528145422.GE20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:38731 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079AbYE1OyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 10:54:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of now, the prefix length is not vaildated when adding or deleting
addresses. The value is passed directly into the inet6_ifaddr structure
and later passed on to memcmp() as length indicator which relies on
the value never to exceed 128 (bits).

Due to the missing check, the currently code allows for any 8 bit
value to be passed on as prefix length while using the netlink
interface, and any 32 bit value while using the ioctl interface.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c	2008-05-28 16:32:32.000000000 +0200
+++ net-2.6/net/ipv6/addrconf.c	2008-05-28 16:48:31.000000000 +0200
@@ -2027,7 +2027,7 @@
  *	Manual configuration of address on an interface
  */
 static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
-			  int plen, __u8 ifa_flags, __u32 prefered_lft,
+			  u8 plen, __u8 ifa_flags, __u32 prefered_lft,
 			  __u32 valid_lft)
 {
 	struct inet6_ifaddr *ifp;
@@ -2039,6 +2039,9 @@
 
 	ASSERT_RTNL();
 
+	if (plen > 128)
+		return -EINVAL;
+
 	/* check the lifetime */
 	if (!valid_lft || prefered_lft > valid_lft)
 		return -EINVAL;
@@ -2095,12 +2098,15 @@
 }
 
 static int inet6_addr_del(struct net *net, int ifindex, struct in6_addr *pfx,
-			  int plen)
+			  u8 plen)
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
