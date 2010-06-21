From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ipv6: fix NULL reference in proxy neighbor discovery
Date: Mon, 21 Jun 2010 14:00:13 -0700
Message-ID: <20100621140013.508741df@nehalam>
References: <20100619175352.GA8482@EIS>
	<20100621153018.GA2433@EIS>
	<20100621162518.GA5972@nuttenaction>
	<20100621102508.2075d677@nehalam>
	<20100621200413.GA2280@EIS>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>
To: Andreas Klauer <Andreas.Klauer@metamorpher.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48269 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758211Ab0FUVAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jun 2010 17:00:16 -0400
In-Reply-To: <20100621200413.GA2280@EIS>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addition of TLLAO option created a kernel OOPS regression
for the case where neighbor advertisement is being sent via
proxy path.  When using proxy, ipv6_get_ifaddr() returns NULL
causing the NULL dereference.

Change causing the bug was:
commit f7734fdf61ec6bb848e0bafc1fb8bad2c124bb50
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Fri Oct 2 11:39:15 2009 +0000

    make TLLAO option for NA packets configurable

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch for -net and -stable.
Applies to 2.6.33 and later.

--- a/net/ipv6/ndisc.c	2010-06-11 08:13:13.008657498 -0700
+++ b/net/ipv6/ndisc.c	2010-06-21 13:52:57.961486303 -0700
@@ -586,6 +586,7 @@ static void ndisc_send_na(struct net_dev
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
 			override = 0;
+		inc_opt |= ifp->idev->cnf.force_tllao;
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
@@ -599,7 +600,6 @@ static void ndisc_send_na(struct net_dev
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	inc_opt |= ifp->idev->cnf.force_tllao;
 	__ndisc_send(dev, neigh, daddr, src_addr,
 		     &icmp6h, solicited_addr,
 		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
