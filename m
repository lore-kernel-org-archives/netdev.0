From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 addrconfg warn_on hit: WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
Date: Thu, 16 Jan 2014 16:18:12 +0100
Message-ID: <20140116151812.GI7436@order.stressinduktion.org>
References: <20140116135323.GA7961@minipsycho.orion> <20140116140701.GB7961@minipsycho.orion> <20140116143817.GH7436@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42756 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaAPPSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 10:18:13 -0500
Content-Disposition: inline
In-Reply-To: <20140116143817.GH7436@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 03:38:17PM +0100, Hannes Frederic Sowa wrote:
> On Thu, Jan 16, 2014 at 03:07:01PM +0100, Jiri Pirko wrote:
> > Thu, Jan 16, 2014 at 02:53:23PM CET, jiri@resnulli.us wrote:
> > >Hi Hannes.
> > >
> > >WARN_ON(ifp->idev->valid_ll_addr_cnt < 0);
> > >
> > >We did hit once this warning during the tests. The person who hit this
> > >says that it was during the setup of many macvlan devices.
> > >
> > >I examined the code but I'm not sure how this could happen. Looks like a
> > >race condition between addrconf_dad_completed() and addrconf_ifdown(). 
> > >Not sure how to easily resolve that though.
> 
> That seems to be the case. Actually we don't need to count precisiely
> here, we just must precisiely identify the situation where the first
> LL address comes into operational state. Maybe we can implement this
> somehow differently. I'll play with the code soon.

Maybe something like this and then throw out the whole ll counting stuff:

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6913a82..105105a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3233,6 +3233,19 @@ out:
 	in6_ifa_put(ifp);
 }
 
+/* idev must be at least read locked */
+static bool ipv6_lonely_lladdr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
+{
+	bool ret = true;
+	struct inet6_ifaddr *ifpiter;
+
+	list_for_each_entry(ifpiter, &idev->addr_list, if_list) {
+		if (ifp != ifpiter && ifpiter->scope == IFA_LINK)
+			ret = false;
+	}
+	return ret;
+}
+
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
 	struct net_device *dev = ifp->idev->dev;
@@ -3253,8 +3266,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 	read_lock_bh(&ifp->idev->lock);
 	spin_lock(&ifp->lock);
-	send_mld = ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL &&
-		   ifp->idev->valid_ll_addr_cnt == 1;
+	send_mld = ifp->scope == IFA_LINK && ipv6_lonely_lladdr(ifp->idev, ifp);
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
 		  ifp->idev->cnf.rtr_solicits > 0 &&
