From: Tore Anderson <tore@fud.no>
Subject: [PATCH] ipv6: Send ICMPv6 RSes only when RAs are accepted
Date: Mon, 29 Aug 2011 14:08:33 +0200
Message-ID: <201108291209.p7TC9KkD002967@wrath.fud.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-40-195-226.dsl.no.powertech.net ([77.40.195.226]:54159 "EHLO
	wrath.fud.no" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752615Ab1H2MOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 08:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves the logic determining when to send ICMPv6 Router
Solicitations, so that they are 1) always sent when the kernel is
accepting Router Advertisements, and 2) never sent when the kernel is
not accepting RAs. In other words, the operational setting of the
"accept_ra" sysctl is used.

The change also makes "Hybrid Router" forwarding mode ("forwarding"
sysctl set to 2) redundant, as the only thing that distinguished it from
the standard Router mode (forwarding=1) was that RSes was being sent. It
has therefore been removed.

Rationale for the change:

Currently, the value of forwarding sysctl is the only thing determining
whether or not to send RSes. If it has the value 0 or 2, they are sent,
otherwise they are not. This leads to inconsistent behaviour in the
following cases:

* accept_ra=0, forwarding=0
* accept_ra=0, forwarding=2
* accept_ra=1, forwarding=2
* accept_ra=2, forwarding=1

In the first three cases, the kernel will send RSes, even though it will
not accept any RAs received in reply. In the last case, it will not send
any RSes, even though it will accept and process any RAs received. (Most
routers will send unsolicited RAs periodically, so suppressing RSes in
the last case will merely delay auto-configuration, not prevent it.)

Also, it is my opinion that having the forwarding sysctl control RS
sending behaviour (completely independent of whether RAs are being
accepted or not) is simply not what most users would intuitively expect
to be the case.

Signed-off-by: Tore Anderson <tore@fud.no>
---
 Documentation/networking/ip-sysctl.txt |   17 ++++++++---------
 net/ipv6/addrconf.c                    |    8 ++++----
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 8154699..98c8d42 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1045,6 +1045,11 @@ conf/interface/*:
 accept_ra - BOOLEAN
 	Accept Router Advertisements; autoconfigure using them.
 
+	It also determines whether or not to transmit Router
+	Solicitations. If and only if the functional setting is to
+	accept Router Advertisements, Router Solicitations will be
+	transmitted.
+
 	Possible values are:
 		0 Do not accept Router Advertisements.
 		1 Accept Router Advertisements if forwarding is disabled.
@@ -1115,14 +1120,14 @@ forwarding - BOOLEAN
 	Possible values are:
 		0 Forwarding disabled
 		1 Forwarding enabled
-		2 Forwarding enabled (Hybrid Mode)
 
 	FALSE (0):
 
 	By default, Host behaviour is assumed.  This means:
 
 	1. IsRouter flag is not set in Neighbour Advertisements.
-	2. Router Solicitations are being sent when necessary.
+	2. If accept_ra is TRUE (default), transmit Router
+	   Solicitations.
 	3. If accept_ra is TRUE (default), accept Router
 	   Advertisements (and do autoconfiguration).
 	4. If accept_redirects is TRUE (default), accept Redirects.
@@ -1133,16 +1138,10 @@ forwarding - BOOLEAN
 	This means exactly the reverse from the above:
 
 	1. IsRouter flag is set in Neighbour Advertisements.
-	2. Router Solicitations are not sent.
+	2. Router Solicitations are not sent unless accept_ra is 2.
 	3. Router Advertisements are ignored unless accept_ra is 2.
 	4. Redirects are ignored.
 
-	TRUE (2):
-
-	Hybrid mode. Same behaviour as TRUE, except for:
-
-	2. Router Solicitations are being sent when necessary.
-
 	Default: 0 (disabled) if global forwarding is disabled (default),
 		 otherwise 1 (enabled).
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f012ebd..d3e51cb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2969,12 +2969,12 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
 
-	/* If added prefix is link local and forwarding is off,
-	   start sending router solicitations.
+	/* If added prefix is link local and we are prepared to process
+	   router advertisements, start sending router solicitations.
 	 */
 
-	if ((ifp->idev->cnf.forwarding == 0 ||
-	     ifp->idev->cnf.forwarding == 2) &&
+	if (((ifp->idev->cnf.accept_ra == 1 && !ifp->idev->cnf.forwarding) ||
+	     ifp->idev->cnf.accept_ra == 2) &&
 	    ifp->idev->cnf.rtr_solicits > 0 &&
 	    (dev->flags&IFF_LOOPBACK) == 0 &&
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
-- 
1.7.6
