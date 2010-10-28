From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] ipv6: addrconf: don't remove address state on ifdown if the
 address is being kept
Date: Wed, 27 Oct 2010 21:16:49 -0700
Message-ID: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	Brian Haley <brian.haley@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:14805 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819Ab0J1ERP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 00:17:15 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o9S4HDiu015904
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 21:17:13 -0700
Received: from ywh2 (ywh2.prod.google.com [10.192.8.2])
	by hpaq7.eem.corp.google.com with ESMTP id o9S4HAmu027468
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 21:17:12 -0700
Received: by ywh2 with SMTP id 2so384194ywh.27
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 21:17:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, addrconf_ifdown does not delete statically configured IPv6
addresses when the interface is brought down. The intent is that when
the interface comes back up the address will be usable again. However,
this doesn't actually work, because the system stops listening on the
corresponding solicited-node multicast address, so the address cannot
respond to neighbor solicitations and thus receive traffic. Also, the
code notifies the rest of the system that the address is being deleted
(e.g, RTM_DELADDR), even though it is not. Fix it so that none of this
state is updated if the address is being kept on the interface.

--- a/net/ipv6/addrconf.c	2010-10-20 13:30:22.000000000 -0700
+++ b/net/ipv6/addrconf.c	2010-10-27 21:04:39.000000000 -0700
@@ -2737,10 +2737,7 @@ static int addrconf_ifdown(struct net_de
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
 			ifa->state = INET6_IFADDR_STATE_DAD;
-
-			write_unlock_bh(&idev->lock);
-
-			in6_ifa_hold(ifa);
+			continue;
 		} else {
 			list_del(&ifa->if_list);
