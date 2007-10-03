From: Brian Haley <brian.haley@hp.com>
Subject: [IPv6] Fix ICMPv6 redirect handling with target multicast address,
 try 3
Date: Wed, 03 Oct 2007 10:44:17 -0400
Message-ID: <4703AAC1.3040500@hp.com>
References: <46FD2B37.6040502@hp.com> <4702997D.6020208@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020801040208040909040900"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:52050 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754309AbXJCOoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 10:44:19 -0400
In-Reply-To: <4702997D.6020208@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020801040208040909040900
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When the ICMPv6 Target address is multicast, Linux processes the 
redirect instead of dropping it.  The problem is in this code in 
ndisc_redirect_rcv():

         if (ipv6_addr_equal(dest, target)) {
                 on_link = 1;
         } else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
                 ND_PRINTK2(KERN_WARNING
                            "ICMPv6 Redirect: target address is not 
link-local.\n");
                 return;
         }

This second check will succeed if the Target address is, for example, 
FF02::1 because it has link-local scope.  Instead, it should be checking 
if it's a unicast link-local address, as stated in RFC 2461/4861 Section 
8.1:

       - The ICMP Target Address is either a link-local address (when
         redirected to a router) or the same as the ICMP Destination
         Address (when redirected to the on-link destination).

I know this doesn't explicitly say unicast link-local address, but it's 
implied.

This bug is preventing Linux kernels from achieving IPv6 Logo Phase II 
certification because of a recent error that was found in the TAHI test 
suite - Neighbor Disovery suite test 206 (v6LC.2.3.6_G) had the 
multicast address in the Destination field instead of Target field, so 
we were passing the test.  This won't be the case anymore.

The patch below fixes this problem, and also fixes ndisc_send_redirect() 
to not send an invalid redirect with a multicast address in the Target 
field.  I re-ran the TAHI Neighbor Discovery section to make sure Linux 
passes all 245 tests now.

-Brian


Signed-off-by: Brian Haley <brian.haley@hp.com>
Acked-by: David L Stevens <dlstevens@us.ibm.com>

--------------020801040208040909040900
Content-Type: text/x-patch;
 name="ipv6.redirect.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6.redirect.patch"

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 74c4d8d..b761dbe 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1267,9 +1267,10 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 
 	if (ipv6_addr_equal(dest, target)) {
 		on_link = 1;
-	} else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	} else if (ipv6_addr_type(target) !=
+		   (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
-			   "ICMPv6 Redirect: target address is not link-local.\n");
+			   "ICMPv6 Redirect: target address is not link-local unicast.\n");
 		return;
 	}
 
@@ -1343,9 +1344,9 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	}
 
 	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
-	    !(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	    ipv6_addr_type(target) != (IPV6_ADDR_UNICAST|IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
-			"ICMPv6 Redirect: target address is not link-local.\n");
+			"ICMPv6 Redirect: target address is not link-local unicast.\n");
 		return;
 	}
 

--------------020801040208040909040900--
