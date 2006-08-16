From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Re: Possible leak of multicast source filter sctructure #3
Date: Wed, 16 Aug 2006 16:39:22 +0100
Message-ID: <200608161439.k7GEdN6u022040@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>,
	<netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:29079 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S1751180AbWHPOmA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 10:42:00 -0400
Content-Disposition: inline
To: "David Stevens" <dlstevens@us.ibm.com>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
>         I'm not sure the second one is quite right. The case of concern
> is where an interface is deleted. If you joined (or left) the group by
> address and then deleted the interface, then you wouldn't match the
> index (which wouldn't be set) so the leave wouldn't work, still.

That's right I havent thought of this case.

>         Also, if you passed a completely bogus ifindex, it should return
> ENODEV, but with the patch it would return EADDRNOTAVAIL it appears.

The question is what is "completely bogus ifindex" in this case?
An interface that does not exist any more but happen to be on the sockets
multicast list shouldn't be.

>         So, I think the second patch needs some more work. I'll look at
> it some more and see if I can suggest something better.
> 
> 
>                                                         +-DLS

I've tried to implement something more complete but especially in the case
of leaving a group by address it is still just a best effort and not something
absolutely perfect.

I've started with streamlining the ip_mc_find_dev() function with one little
change in its behavior: clearing the imr_address member of the ip_mreqn
request structure in case an interface is found by an index.
This should be no problem since this member is not used in this case and may
contain a random value. So I clear it to get rid of this randomness since
this value might now be used in ip_mc_leave_group()

Well and now the changes in the ip_mc_leave_group():
I've splitted it into two different cases:
 1) leave by an interface index
 2) leave by an interface address / muticast address

In the first case I search for a match by the interface index specified
in the leave request. If a match is found I leave the group on the
interface irrespective of its existence.

In the second case I do a similar search (but this time using the interface
index found in ip_mc_find_dev()) while also checking for a match by
the interface address.
If no match is found by the interface index and there is a match (or more)
by the address I leave the group on the interface corresponding to the first
match by the address.
This certainly could produce weird results but such results could be
produced by the original algorithm as well with the additional problem
that there was no way to leave a group on a deleted interface.

And here is the patch:

Signed-off-by: Michal Ruzicka <michal.ruzicka@comstar.cz>

--- linux-2.6.17.8/net/ipv4/igmp.c.orig	2006-08-11 11:50:46.000000000 +0200
+++ linux-2.6.17.8/net/ipv4/igmp.c	2006-08-16 15:06:18.000000000 +0200
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
+			imr->imr_address.s_addr = 0;
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
@@ -1798,27 +1799,79 @@
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
+				 * to ip_mc_find_dev() but is non-zero now (since
+				 * it equals to an interface index wich is never
+				 * zero). The ip_mc_find_dev() function modifies
+				 * the ifindex only if it finds an interface
+				 * (in wich case it returns non-NULL). Thus the
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
+			 * Since there is no way to tell what interface the user
+			 * wnated to leave the multicast group on we are going
+			 * to leave it on the first candidate interface found.
+			 */
+			iml = *(imlp = cimlp);
+
+			if (in_dev != NULL) {
+				/* If we have found an interface matching the leave
+				 * request chances are that the interface which we
+				 * are about to leave the multicast group on still
+				 * exists. Check if it is the case so as to call
+				 * ip_mc_dec_group() properly.
+				 */
+				imr->imr_ifindex = iml->multi.imr_ifindex;
+				in_dev = ip_mc_find_dev(imr);
+			}
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


Michal
