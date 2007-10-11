From: Brian Haley <brian.haley@hp.com>
Subject: [IPv6] Update setsockopt(IPV6_MULTICAST_IF) to support RFC 3493,
 try2
Date: Thu, 11 Oct 2007 13:40:08 -0400
Message-ID: <470E5FF8.7050004@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040107000704060301000904"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:59433 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbXJKRlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 13:41:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040107000704060301000904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

 From RFC 3493, Section 5.2:

       IPV6_MULTICAST_IF

          Set the interface to use for outgoing multicast packets.  The
          argument is the index of the interface to use.  If the
          interface index is specified as zero, the system selects the
          interface (for example, by looking up the address in a routing
          table and using the resulting interface).

This patch adds support for (index == 0) to reset the value to it's 
original state, allowing the system to choose the best interface.  IPv4 
already behaves this way.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------040107000704060301000904
Content-Type: text/x-patch;
 name="ipv6.multicast_if.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6.multicast_if.patch"

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 532425d..1334fc1 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -539,12 +539,15 @@ done:
 	case IPV6_MULTICAST_IF:
 		if (sk->sk_type == SOCK_STREAM)
 			goto e_inval;
-		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
-			goto e_inval;
 
-		if (__dev_get_by_index(&init_net, val) == NULL) {
-			retv = -ENODEV;
-			break;
+		if (val) {
+			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != val)
+				goto e_inval;
+
+			if (__dev_get_by_index(&init_net, val) == NULL) {
+				retv = -ENODEV;
+				break;
+			}
 		}
 		np->mcast_oif = val;
 		retv = 0;

--------------040107000704060301000904--
