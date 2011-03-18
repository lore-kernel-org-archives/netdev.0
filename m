From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 4/4] ipv4: optimize route adding on secondary promotion
Date: Sat, 19 Mar 2011 01:21:07 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103190119130.1678@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49109 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754690Ab1CRXP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 19:15:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Optimize the calling of fib_add_ifaddr for all
secondary addresses after the promoted one to start from
their place, not from the new place of the promoted
secondary. It will save some CPU cycles because we
are sure the promoted secondary was first for the subnet
and all next secondaries do not change their place.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp net-next-2.6-bef55ae/linux/net/ipv4/devinet.c linux/net/ipv4/devinet.c
--- net-next-2.6-bef55ae/linux/net/ipv4/devinet.c	2011-03-18 00:57:39.000000000 +0200
+++ linux/net/ipv4/devinet.c	2011-03-18 10:40:08.135271482 +0200
@@ -375,6 +375,7 @@ static void __inet_del_ifa(struct in_dev
  	blocking_notifier_call_chain(&inetaddr_chain, NETDEV_DOWN, ifa1);

  	if (promote) {
+		struct in_ifaddr *next_sec = promote->ifa_next;

  		if (prev_prom) {
  			prev_prom->ifa_next = promote->ifa_next;
@@ -386,7 +387,7 @@ static void __inet_del_ifa(struct in_dev
  		rtmsg_ifa(RTM_NEWADDR, promote, nlh, pid);
  		blocking_notifier_call_chain(&inetaddr_chain,
  				NETDEV_UP, promote);
-		for (ifa = promote->ifa_next; ifa; ifa = ifa->ifa_next) {
+		for (ifa = next_sec; ifa; ifa = ifa->ifa_next) {
  			if (ifa1->ifa_mask != ifa->ifa_mask ||
  			    !inet_ifa_match(ifa1->ifa_address, ifa))
  					continue;
