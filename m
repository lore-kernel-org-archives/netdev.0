From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Fri, 11 Aug 2006 12:04:53 +0100
Message-ID: <200608111004.k7BA4s6u009263@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:24789 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1751105AbWHKKFm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 06:05:42 -0400
Content-Disposition: inline
To: "David Stevens" <dlstevens@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Michal,
>         This looks correct, but I think a better way to do it is:
> 
>         in_dev = inetdev_by_index(...)
>         (void) ip_mc_leave_src()
>         if (in_dev) {
>                 ip_mc_dec_group()
>                 in_dev_put()
>         }
> 
>         That way, sflist internal details aren't visible at this
> level, and ip_mc_leave_src() collapses to the sock_kfree_s()
> when in_dev is NULL.

You are absolutely right, I just failed to notice that -ENODEV return value
from ip_mc_del_src()/ip_mc_leave_src() is ignored.
Here comes the patch:

--- linux-2.6.17.8/net/ipv4/igmp.c.orig	2006-08-11 11:45:56.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-11 11:51:56.000000000 +0200
@@ -2202,13 +2202,13 @@
 		struct in_device *in_dev;
 		inet->mc_list = iml->next;
 
-		if ((in_dev = inetdev_by_index(iml->multi.imr_ifindex)) != NULL) {
-			(void) ip_mc_leave_src(sk, iml, in_dev);
+		in_dev = inetdev_by_index(iml->multi.imr_ifindex);
+		(void) ip_mc_leave_src(sk, iml, in_dev);
+		if (in_dev != NULL) {
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 			in_dev_put(in_dev);
 		}
 		sock_kfree_s(sk, iml, sizeof(*iml));
-
 	}
 	rtnl_unlock();
 }


>         Also, ip_mc_leave_group() has the same issue; looks
> like it just needs the "if (in_dev)" removed before the call to
> ip_mc_leave_src().

In fact it is a slightly different issue, there is no leak in this
function. Rather the function completely fails to leave a multicast
group joined on an interface that does not exist any more. Actually
this is how I discovered the bug as I was tracking down a problem
with ripd daemon of routing software quagga which failed to join
a multicast group (with -ENOBUFS) on an interface after there were
several (20 to be precise which corresponds to the default value
[IP_MAX_MEMBERSHIPS] of sysctl_igmp_max_memberships) interfaces
added/removed.
Here comes a patch for that:

--- linux-2.6.17.8/net/ipv4/igmp.c.leak	2006-08-11 11:50:46.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-11 11:52:33.000000000 +0200
@@ -1799,19 +1799,15 @@
 
 	rtnl_lock();
 	in_dev = ip_mc_find_dev(imr);
-	if (!in_dev) {
-		rtnl_unlock();
-		return -ENODEV;
-	}
 	ifindex = imr->imr_ifindex;
 	for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
 		if (iml->multi.imr_multiaddr.s_addr == group &&
 		    iml->multi.imr_ifindex == ifindex) {
-			(void) ip_mc_leave_src(sk, iml, in_dev);
-
 			*imlp = iml->next;
 
-			ip_mc_dec_group(in_dev, group);
+			(void) ip_mc_leave_src(sk, iml, in_dev);
+			if (in_dev != NULL)
+				ip_mc_dec_group(in_dev, group);
 			rtnl_unlock();
 			sock_kfree_s(sk, iml, sizeof(*iml));
 			return 0;


>                                         +-DLS
> 

Michal
