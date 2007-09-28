From: Brian Haley <brian.haley@hp.com>
Subject: [IPV6] Fix ICMPv6 redirect handling with target multicast address
Date: Fri, 28 Sep 2007 12:26:31 -0400
Message-ID: <46FD2B37.6040502@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080605090304070105040405"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:56720 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152AbXI1Q0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 12:26:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080605090304070105040405
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


--------------080605090304070105040405
Content-Type: text/x-patch;
 name="ipv6.redirect.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv6.redirect.patch"

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 31b3f1b..4f47d29 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -368,6 +368,11 @@ static inline int ipv6_prefix_equal(const struct in6_addr *a1,
 				   prefixlen);
 }
 
+static inline int ipv6_addr_linklocal(const struct in6_addr *a)
+{
+	return ((a->s6_addr32[0] & htonl(0xFFC00000)) == htonl(0xFE800000));
+}
+
 static inline int ipv6_addr_any(const struct in6_addr *a)
 {
 	return ((a->s6_addr32[0] | a->s6_addr32[1] | 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 74c4d8d..8f953a7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1267,7 +1267,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 
 	if (ipv6_addr_equal(dest, target)) {
 		on_link = 1;
-	} else if (!(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	} else if (!ipv6_addr_linklocal(target)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: target address is not link-local.\n");
 		return;
@@ -1343,7 +1343,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	}
 
 	if (!ipv6_addr_equal(&ipv6_hdr(skb)->daddr, target) &&
-	    !(ipv6_addr_type(target) & IPV6_ADDR_LINKLOCAL)) {
+	    !ipv6_addr_linklocal(target)) {
 		ND_PRINTK2(KERN_WARNING
 			"ICMPv6 Redirect: target address is not link-local.\n");
 		return;

--------------080605090304070105040405--
