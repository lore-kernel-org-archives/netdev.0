From: "Michal Ruzicka" <michal.ruzicka@comstar.cz>
Subject: Re: Possible leak of multicast source filter sctructure
Date: Mon, 14 Aug 2006 11:56:23 +0100
Message-ID: <200608140956.k7E9uO6u001859@gateplz.comstar.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: <dlstevens@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateplz-adsl.comstar.cz ([193.179.24.196]:20892 "EHLO
	gateplz.comstar.cz") by vger.kernel.org with ESMTP id S932079AbWHNJ6N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 05:58:13 -0400
Content-Disposition: inline
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

 ...
> (Meanwhile, Michal, can I get a Signed-off-by: line from you for these
>  patches?  Thanks a lot.)

no problem :-)

There is a leak of a socket's multicast source filter list structure
on closing a socket with a multicast source filter set on an interface
that does not exist any more.
This patch fixes it:

Signed-off-by: Michal Ruzicka <michal.ruzicka@comstar.cz>

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


Due to a bug in IP_DROP_MEMBERSHIP setsockopt handling code it is not
possible to leave a multicast group joined on an interface that
does not exist any more.
This patch makes leaving a multicast group possible even in that case:

Signed-off-by: Michal Ruzicka <michal.ruzicka@comstar.cz>

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


Michal
