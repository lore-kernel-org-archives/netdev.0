From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Kernel oops in ip6t_LOG.c:ip6_nexthdr
Date: Thu, 26 Aug 2004 13:35:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040826113538.GE15409@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="24zk1gE8NUlDmwG9"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

We just ran into a kernel oops after enabling ipv6 packet filtering.
The machine would choke on the IGMPv6 packets sent out when the
interface is taken up. The reason is this code:

                /*stupid rfc2402 */
                case IPPROTO_DSTOPTS:
                case IPPROTO_ROUTING:
                case IPPROTO_HOPOPTS:
                        nexthdr = **hdrptr;
                        hdrlen = *hdrptr[1] * 8 + 8;
			         ^^^^^^^^^^ it dies here
                        *hdrptr = *hdrptr + hdrlen;
                        break;

hdrptr is a u_int8_t **. What you really want to do here is
look at (*hdrptr)[1], but what the expression does is look at
*(hdrptr[1]). Unfortunately, hdrptr[1] is usually random garbage.

The attached patch fixes this.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=netfilter6-logging

Prevent oopses when logging IGMPv6 packets and similar.

Index: linux-2.6.5/net/ipv6/netfilter/ip6t_LOG.c
===================================================================
--- linux-2.6.5.orig/net/ipv6/netfilter/ip6t_LOG.c
+++ linux-2.6.5/net/ipv6/netfilter/ip6t_LOG.c
@@ -55,7 +55,7 @@ static u_int8_t ip6_nexthdr(u_int8_t cur
 		repeatedly...with a large stick...no, an even LARGER
 		stick...no, you're still not thinking big enough */
 			nexthdr = **hdrptr;
-			hdrlen = *hdrptr[1] * 4 + 8;
+			hdrlen = (*hdrptr)[1] * 4 + 8;
 			*hdrptr = *hdrptr + hdrlen;
 			break;
 		/*stupid rfc2402 */
@@ -63,7 +63,7 @@ static u_int8_t ip6_nexthdr(u_int8_t cur
 		case IPPROTO_ROUTING:
 		case IPPROTO_HOPOPTS:
 			nexthdr = **hdrptr;
-			hdrlen = *hdrptr[1] * 8 + 8;
+			hdrlen = (*hdrptr)[1] * 8 + 8;
 			*hdrptr = *hdrptr + hdrlen;
 			break;
 		case IPPROTO_FRAGMENT:

--24zk1gE8NUlDmwG9--
