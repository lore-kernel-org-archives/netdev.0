From: Brian Haley <brian.haley@hp.com>
Subject: Re: With disable_ipv6 set to 1 on an interface, ff00:/8 and fe80::/64
 are 	still added on device UP
Date: Tue, 20 Jul 2010 16:34:30 -0400
Message-ID: <4C460856.5090701@hp.com>
References: <AANLkTinHkaL49MS9agf525GRhWXSWIvVmn-Qz33Hcg6Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mahesh Kelkar <maheshkelkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9292 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755406Ab0GTUed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 16:34:33 -0400
In-Reply-To: <AANLkTinHkaL49MS9agf525GRhWXSWIvVmn-Qz33Hcg6Y@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mahesh,

Cc-ing netdev...

On 07/20/2010 12:07 PM, Mahesh Kelkar wrote:
> Brian,
> 
> I came across a patch that you submitted in 2009 (2009-05-29 20:48:49):
> IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
> 
> Question:
> With disable_ipv6 set to 1 on the interface, when device/interface
> reaches UP state, the link local address is not added, but ipv6 routes
> i.e. ff00::/8 & fe80::/64 routes are still added to the route table:
> In net/ipv6/addrconf.c
> addrconf_notify => addrconf_dev_config => addrconf_add_dev =>
> addrconf_add_mroute & addrconf_add_lroute
> The link local address is not assigned because of the check
> (idev->cnf.disable_ipv6) added in ipv6_add_addr.
> 
> - Is there any particular reason for doing this? (i.e. not assigning
> the link local address to interface, but adding link local & mcast
> routes)
> - when disable_ipv6 is set to 1, is there any reason not to skip the
> NETDEV_UP processing in the addrconf_notify in addrconf.c

I believe the easiest way to fix this is the following patch, can
you please test it?

Thanks,

-Brian

---

If the interface has IPv6 disabled, don't add a multicast or
link-local route since we won't be adding a link-local address.

Reported-by: Mahesh Kelkar <maheshkelkar@gmail.com>
Signed-off-by: Brian Haley <brian.haley@hp.com>
---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e81155d..ab70a3f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1763,7 +1763,10 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 
 	idev = ipv6_find_idev(dev);
 	if (!idev)
-		return NULL;
+		return ERR_PTR(-ENOBUFS);
+
+	if (idev->cnf.disable_ipv6)
+		return ERR_PTR(-EACCES);
 
 	/* Add default multicast route */
 	addrconf_add_mroute(dev);
@@ -2132,8 +2135,9 @@ static int inet6_addr_add(struct net *net, int ifindex, struct in6_addr *pfx,
 	if (!dev)
 		return -ENODEV;
 
-	if ((idev = addrconf_add_dev(dev)) == NULL)
-		return -ENOBUFS;
+	idev = addrconf_add_dev(dev);
+	if (IS_ERR(idev))
+		return PTR_ERR(idev);
 
 	scope = ipv6_addr_scope(pfx);
 
@@ -2380,7 +2384,7 @@ static void addrconf_dev_config(struct net_device *dev)
 	}
 
 	idev = addrconf_add_dev(dev);
-	if (idev == NULL)
+	if (IS_ERR(idev))
 		return;
 
 	memset(&addr, 0, sizeof(struct in6_addr));
@@ -2471,7 +2475,7 @@ static void addrconf_ip6_tnl_config(struct net_device *dev)
 	ASSERT_RTNL();
 
 	idev = addrconf_add_dev(dev);
-	if (!idev) {
+	if (IS_ERR(idev)) {
 		printk(KERN_DEBUG "init ip6-ip6: add_dev failed\n");
 		return;
 	}
