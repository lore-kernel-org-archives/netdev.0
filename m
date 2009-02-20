From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] ip: add loose reverse path filtering
Date: Fri, 20 Feb 2009 10:25:36 -0800
Message-ID: <20090220102536.2d39ddb9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46666 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747AbZBTSZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Feb 2009 13:25:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend existing reverse path filter option to allow strict or loose
filtering. (See http://en.wikipedia.org/wiki/Reverse_path_filtering).

For compatibility with existing usage, the value 1 is chosen for strict mode
and 2 for loose mode.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 Documentation/networking/ip-sysctl.txt |   22 ++++++++++++++--------
 net/ipv4/fib_frontend.c                |    2 +-
 2 files changed, 15 insertions(+), 9 deletions(-)

--- a/Documentation/networking/ip-sysctl.txt	2009-02-20 10:24:04.128692016 -0800
+++ b/Documentation/networking/ip-sysctl.txt	2009-02-20 10:24:09.733192268 -0800
@@ -699,16 +699,22 @@ accept_source_route - BOOLEAN
 	default TRUE (router)
 		FALSE (host)
 
-rp_filter - BOOLEAN
-	1 - do source validation by reversed path, as specified in RFC1812
-	    Recommended option for single homed hosts and stub network
-	    routers. Could cause troubles for complicated (not loop free)
-	    networks running a slow unreliable protocol (sort of RIP),
-	    or using static routes.
-
+rp_filter - INTEGER
 	0 - No source validation.
+	1 - Strict mode as defined in RFC3704 Strict Reverse Path
+	    Each incoming packet is tested against the FIB and if the interface
+	    is not the best reverse path the packet check will fail.
+	    By default failed packets are discarded.
+	2 - Loose mode as defined in RFC3704 Loose Reverse Path
+	    Each incoming packet's source address is also tested against the FIB
+	    and if the source address is not reachable via any interface
+	    the packet check will fail.
+
+        Current recommended practice in RFC3704 is to enable strict mode
+	to prevent IP spoofin from DDos attacks. If using asymmetric routing
+        or other complicated routing,t hen loose mode is recommended.
 
-	conf/all/rp_filter must also be set to TRUE to do source validation
+	conf/all/rp_filter must also be set to non-zero to do source validation
 	on the interface
 
 	Default value is 0. Note that some distributions enable it
--- a/net/ipv4/fib_frontend.c	2009-02-20 10:24:04.140692744 -0800
+++ b/net/ipv4/fib_frontend.c	2009-02-20 10:24:09.733192268 -0800
@@ -275,7 +275,7 @@ int fib_validate_source(__be32 src, __be
 	fib_res_put(&res);
 	if (no_addr)
 		goto last_resort;
-	if (rpf)
+	if (rpf == 1)
 		goto e_inval;
 	fl.oif = dev->ifindex;
 
