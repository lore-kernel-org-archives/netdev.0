From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Re: Possible leak of multicast source filter sctructure #4
Date: Fri, 18 Aug 2006 14:55:51 +0100
Message-ID: <200608181255.k7ICtq6u009996@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:49030 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1751263AbWHRM4g convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 08:56:36 -0400
Content-Disposition: inline
To: "David Stevens" <dlstevens@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
First of all, thank you for your comments.

>         If you have a duplicated address and the application is not using
> interface index to identify the interface, then which one you join or 
> leave
> on is not unique, and which one you'll get is not defined. It is, in fact,
> an error to leave the group on an interface with a different index, and
> the duplicate scenario has effectively changed the meaning of that 
> address's
> interface.

Well, yes, I assumed that it is not defined which interface a group is
joined on when joining by an ambiguous address. The scenario was just
to show a violation of a main goal I had in mind when designing
the algorithm:
After successfully joining a group by an arbitrary request (by an index,
by an address, by a multicast address alone ... whatever) an aplication
should not get an error (at least) on the first following attempt to leave
the group by the same request.

>         In the same scenario, if you have not deleted any interfaces and
> attempt to leave the group, your code may get the "pppY" interface from
> ip_mc_find_dev(), not have a matching index for the group you actually
> joined, and will return EADDRNOTAVAIL rather than leaving the group you
> joined on.

No, it would leave the group on "pppX" no matter what ip_mc_find_dev()
returned.
I inline the code (excluding most comments) for reference:

 1: int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 2: {
 3: 	struct inet_sock *inet = inet_sk(sk);
 4: 	struct ip_mc_socklist *iml, **imlp;
 5: 	struct in_device *in_dev;
 6: 	u32 group = imr->imr_multiaddr.s_addr;
 7: 	u32 ifindex;
 8: 
 9: 	rtnl_lock();
10: 	ifindex = imr->imr_ifindex;
11: 	in_dev = ip_mc_find_dev(imr);
12: 	if (ifindex != 0) {
13: 		/* leave by interface index */
14: 		for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
15: 			if (iml->multi.imr_multiaddr.s_addr != group)
16: 				continue;
17: 
18: 			if (iml->multi.imr_ifindex == ifindex)
19: 				goto leave;
20: 		}
21: 	} else {
22: 		/* leave by address / multicast group route */
23: 		struct ip_mc_socklist **cimlp = NULL;
24: 		u32 address = imr->imr_address.s_addr;
25: 
26: 		ifindex = imr->imr_ifindex;
27: 		for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
28: 			if (iml->multi.imr_multiaddr.s_addr != group)
29: 				continue;
30: 
31: 			if (iml->multi.imr_ifindex == ifindex)
32: 				goto leave;
33: 
34: 			if (cimlp == NULL && iml->multi.imr_address.s_addr == address)
35: 				cimlp = imlp;
36: 		}
37: 
38: 		if (cimlp != NULL) {
39: 			iml = *(imlp = cimlp);
40: 
41: 			if (in_dev != NULL) {
42: 				imr->imr_ifindex = iml->multi.imr_ifindex;
43: 				in_dev = ip_mc_find_dev(imr);
44: 			}
45: 
46: 			goto leave;
47: 		}
48: 	}
49: 	rtnl_unlock();
50: 	return (in_dev == NULL) ? -ENODEV : -EADDRNOTAVAIL;
51: 
52: leave:
53: 	*imlp = iml->next;
54: 
55: 	(void) ip_mc_leave_src(sk, iml, in_dev);
56: 	if (in_dev != NULL)
57: 		ip_mc_dec_group(in_dev, group);
58: 	rtnl_unlock();
59: 	sock_kfree_s(sk, iml, sizeof(*iml));
60: 	return 0;
61: }

As the assumed request is a leave by address (ifindex initially == 0) all
the main work will be done by code on lines 22-47.
Should the ip_mc_find_dev() have returned "pppX" a "direct match" would be
found by the test on line 31 and the group would be promptly left
(no suprises here).
Should the "pppY" have been returned, no direct match would be found (since
the group was not joined on "pppY") but a "candidate interface" for leaving
the group on would be selected by code on lines 34-35 since there would
be a match by address at least/just for the "pppX" interface. The work
would be then finished on lines 38-47 by setting up pointers to point to
the selected "candiadate interface" and by another ip_mc_find_dev() lookup
to get proper in_dev pointer for the interface (the lookup would be done
by the interface index obtained from the socket's multicast list this time).

>         In both cases, it'd simply be an error for an application to be
> using address to identify the interface when that is not unique. If the
> addresses are used (or reused) on multiple interfaces, the application
> has to use interface index to work properly.
> 
>                                                                 +-DLS

I agree, but for the time before all applications are fixed ...
(BTW from the IPv6 part of your patch it seems that the multicast group
membership management is done solely by the interface index there
... good idea! :-) )

> > Suppose the following situatuion:
> > 
> > 1) create pppX interface:
> >   IP: A.B.C.D
> > 
> > 2) join a multicast group by address: A.B.C.D
> >   ASSUMPTION: no other interface with the same IP address exists;
> >   the result should be that the group is joined on the pppX interface
> > 
> > 3) create pppY interface
> >   IP: A.B.C.D (Yes the same IP, not unusual on ppp links.)
> > 
> > 4) delete the pppX interace
> > 
> > 5) attempt to leave the multicast group by address: A.B.C.D
> > 
> > 6) * if your algorthim is used -EADDRNOTAVAIL is returned
> >    * if mine is used the multicast group is left on the pppX interface
> > 

Michal

PS: During the writing of this post I realized a bug in my code:
The second ip_mc_find_dev() lookup on lines 42-43 should be done irrespective
of the prior value of in_dev.
And came up with an enhancement to what I had previously done in
ip_mc_find_dev():
In case an interface is found by its index the imr_address is no longer
cleared rather it is set to: INADDR_NONE.
This should result in somewhat smarter behaviour in case of leaving a group
by its multicast address alone.
Here is the corrected version of the patch:

Signed-off-by: Michal Ruzicka <michal.ruzicka@comstar.cz>

--- linux-2.6.17.8/net/ipv4/igmp.c.orig	2006-08-11 11:50:46.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-18 13:04:09.000000000 +0200
@@ -1369,13 +1369,15 @@
 	struct flowi fl = { .nl_u = { .ip4_u =
 				      { .daddr = imr->imr_multiaddr.s_addr } } };
 	struct rtable *rt;
-	struct net_device *dev = NULL;
-	struct in_device *idev = NULL;
+	struct net_device *dev;
 
 	if (imr->imr_ifindex) {
-		idev = inetdev_by_index(imr->imr_ifindex);
-		if (idev)
+		struct in_device *idev = inetdev_by_index(imr->imr_ifindex);
+
+		if (idev) {
+			imr->imr_address.s_addr = INADDR_NONE;
 			__in_dev_put(idev);
+		}
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
@@ -1383,17 +1385,16 @@
 		if (!dev)
 			return NULL;
 		dev_put(dev);
-	}
-
-	if (!dev && !ip_route_output_key(&rt, &fl)) {
+	} else if (!ip_route_output_key(&rt, &fl)) {
 		dev = rt->u.dst.dev;
 		ip_rt_put(rt);
-	}
-	if (dev) {
-		imr->imr_ifindex = dev->ifindex;
-		idev = __in_dev_get_rtnl(dev);
-	}
-	return idev;
+		if (!dev)
+			return NULL;
+	} else
+		return NULL;
+
+	imr->imr_ifindex = dev->ifindex;
+	return __in_dev_get_rtnl(dev);
 }
 
 /*
@@ -1798,27 +1799,77 @@
 	u32 ifindex;
 
 	rtnl_lock();
-	in_dev = ip_mc_find_dev(imr);
-	if (!in_dev) {
-		rtnl_unlock();
-		return -ENODEV;
-	}
 	ifindex = imr->imr_ifindex;
-	for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
-		if (iml->multi.imr_multiaddr.s_addr == group &&
-		    iml->multi.imr_ifindex == ifindex) {
-			(void) ip_mc_leave_src(sk, iml, in_dev);
-
-			*imlp = iml->next;
-
-			ip_mc_dec_group(in_dev, group);
-			rtnl_unlock();
-			sock_kfree_s(sk, iml, sizeof(*iml));
-			return 0;
+	in_dev = ip_mc_find_dev(imr);
+	if (ifindex != 0) {
+		/* leave by interface index */
+		for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
+			if (iml->multi.imr_multiaddr.s_addr != group)
+				continue;
+
+			if (iml->multi.imr_ifindex == ifindex)
+				goto leave;
+		}
+	} else {
+		/* leave by address / multicast group route */
+		struct ip_mc_socklist **cimlp = NULL;
+		u32 address = imr->imr_address.s_addr;
+
+		ifindex = imr->imr_ifindex;
+		for (imlp = &inet->mc_list; (iml = *imlp) != NULL; imlp = &iml->next) {
+			if (iml->multi.imr_multiaddr.s_addr != group)
+				continue;
+
+			if (iml->multi.imr_ifindex == ifindex)
+				/* direct match
+				 * NOTE: We do not have to test for in_dev != NULL
+				 * since we know that ifindex was zero before call
+				 * to ip_mc_find_dev() but is non-zero now (as
+				 * it equals to an interface index which is never
+				 * zero). The ip_mc_find_dev() function modifies
+				 * the ifindex only if it finds an interface
+				 * (in which case it returns non-NULL). Thus the
+				 * in_dev must be non-NULL.
+				 */
+				goto leave;
+
+			if (cimlp == NULL && iml->multi.imr_address.s_addr == address)
+				cimlp = imlp;
+		}
+
+		if (cimlp != NULL) {
+			/* We have found at least one candidate interface
+			 * for leaving by address but not a direct match.
+			 * Since there is no way to tell which interface
+			 * the user wanted to leave the multicast group on
+			 * we are going to leave it on the first candidate
+			 * interface found.
+			 */
+			iml = *(imlp = cimlp);
+
+			/* Lookup the interface again, this time by the index
+			 * stored in the socket's multicast list since it is
+			 * different from what was found by the address
+			 * (if anything was found at all).
+			 */
+			imr->imr_ifindex = iml->multi.imr_ifindex;
+			in_dev = ip_mc_find_dev(imr);
+
+			goto leave;
 		}
 	}
 	rtnl_unlock();
-	return -EADDRNOTAVAIL;
+	return (in_dev == NULL) ? -ENODEV : -EADDRNOTAVAIL;
+
+leave:
+	*imlp = iml->next;
+
+	(void) ip_mc_leave_src(sk, iml, in_dev);
+	if (in_dev != NULL)
+		ip_mc_dec_group(in_dev, group);
+	rtnl_unlock();
+	sock_kfree_s(sk, iml, sizeof(*iml));
+	return 0;
 }
 
 int ip_mc_source(int add, int omode, struct sock *sk, struct
