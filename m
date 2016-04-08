From: Chris Friesen <chris.friesen@windriver.com>
Subject: [PATCH v3] route: do not cache fib route info on local routes with
 oif
Date: Fri, 8 Apr 2016 14:07:26 -0600
Message-ID: <57080F7E.809@windriver.com>
References: <5706B250.1060303@windriver.com> <alpine.LFD.2.11.1604072305400.2154@ja.home.ssi.bg> <5707C950.6060806@windriver.com> <alpine.LFD.2.11.1604082207330.2124@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:57020 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090AbcDHUHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 16:07:38 -0400
In-Reply-To: <alpine.LFD.2.11.1604082207330.2124@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For local routes that require a particular output interface we do not want to
cache the result.  Caching the result causes incorrect behaviour when there are
multiple source addresses on the interface.  The end result being that if the
intended recipient is waiting on that interface for the packet he won't receive
it because it will be delivered on the loopback interface and the IP_PKTINFO
ipi_ifindex will be set to the loopback interface as well.

This can be tested by running a program such as "dhcp_release" which attempts
to inject a packet on a particular interface so that it is received by another
program on the same board.  The receiving process should see an IP_PKTINFO
ipi_ifndex value of the source interface (e.g., eth1) instead of the loopback
interface (e.g., lo).  The packet will still appear on the loopback interface
in tcpdump but the important aspect is that the CMSG info is correct.

Sample dhcp_release command line:

   dhcp_release eth1 192.168.204.222 02:11:33:22:44:66

Signed-off-by: Allain Legacy <allain.legacy@windriver.com>
Signed off-by: Chris Friesen <chris.friesen@windriver.com>
---
 net/ipv4/route.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 02c6229..437a377 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2045,6 +2045,18 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		 */
 		if (fi && res->prefixlen < 4)
 			fi = NULL;
+	} else if ((type == RTN_LOCAL) && (orig_oif != 0) &&
+		   (orig_oif != dev_out->ifindex)) {
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
