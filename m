From: Chris Friesen <chris.friesen@windriver.com>
Subject: [RFC PATCH] possible bug in handling of ipv4 route caching
Date: Thu, 7 Apr 2016 13:17:36 -0600
Message-ID: <5706B250.1060303@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35939 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbcDGTRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 15:17:39 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
	by mail1.windriver.com (8.15.2/8.15.1) with ESMTPS id u37JHbPJ016675
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 7 Apr 2016 12:17:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We think we may have found a bug in the handling of ipv4 route caching,
and are curious what you think.

For local routes that require a particular output interface we do not
want to cache the result.  Caching the result causes incorrect behaviour
when there are multiple source addresses on the interface.  The end
result being that if the intended recipient is waiting on that interface
for the packet he won't receive it because it will be delivered on the
loopback interface and the IP_PKTINFO ipi_ifindex will be set to the
loopback interface as well.

This can be tested by running a program such as "dhcp_release" which
attempts to inject a packet on a particular interface so that it is
received by another program on the same board.  The receiving process
should see an IP_PKTINFO ipi_ifndex value of the source interface
(e.g., eth1) instead of the loopback interface (e.g., lo).  The packet
will still appear on the loopback interface in tcpdump but the important
aspect is that the CMSG info is correct.

For what it's worth, here's a patch that we've applied locally to deal
with the issue.

Chris



Signed-off-by: Allain Legacy <allain.legacy@windriver.com>
Signed-off-by: Chris Friesen <chris.friesen@windriver.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..e965d4b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2045,6 +2045,17 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		 */
 		if (fi && res->prefixlen < 4)
 			fi = NULL;
+	} else if ((type == RTN_LOCAL) && (orig_oif != 0)) {
+		/* For local routes that require a particular output interface
+                 * we do not want to cache the result.  Caching the result
+                 * causes incorrect behaviour when there are multiple source
+                 * addresses on the interface, the end result being that if the
+                 * intended recipient is waiting on that interface for the
+                 * packet he won't receive it because it will be delivered on
+                 * the loopback interface and the IP_PKTINFO ipi_ifindex will
+                 * be set to the loopback interface as well.
+		 */
+		fi = NULL;
 	}
 
 	fnhe = NULL;
