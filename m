From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patches
Date: Fri, 30 Jul 2004 11:24:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040730012431.GA21253@gondor.apana.org.au>
References: <20040729181948.5d36f47f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040729181948.5d36f47f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jul 29, 2004 at 06:19:48PM -0700, David S. Miller wrote:
> 
> I've simply lost track of.  Herbert, can you resend the
> patches that I should be reviewing and applying to
> my tree?

Yes it has been a bit chaotic.

Here is the routing headers patch again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/ah6.c 1.34 vs edited =====
--- 1.34/net/ipv6/ah6.c	2004-07-24 14:52:21 +10:00
+++ edited/net/ipv6/ah6.c	2004-07-24 18:35:47 +10:00
@@ -31,6 +31,7 @@
 #include <net/ah.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/string.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
@@ -74,6 +75,45 @@
 	return 0;
 }
 
+/**
+ *	ipv6_rearrange_rthdr - rearrange IPv6 routing header
+ *	@iph: IPv6 header
+ *	@rthdr: routing header
+ *
+ *	Rearrange the destination address in @iph and the addresses in @rthdr
+ *	so that they appear in the order they will at the final destination.
+ *	See Appendix A2 of RFC 2402 for details.
+ */
+static void ipv6_rearrange_rthdr(struct ipv6hdr *iph, struct ipv6_rt_hdr *rthdr)
+{
+	int segments, segments_left;
+	struct in6_addr *addrs;
+	struct in6_addr final_addr;
+
+	segments_left = rthdr->segments_left;
+	if (segments_left == 0)
+		return;
+	rthdr->segments_left = 0; 
+
+	/* The value of rthdr->hdrlen has been verified either by the system
+	 * call if it is locally generated, or by ipv6_rthdr_rcv() for incoming
+	 * packets.  So we can assume that it is even and that segments is
+	 * greater than or equal to segments_left.
+	 *
+	 * For the same reason we can assume that this option is of type 0.
+	 */
+	segments = rthdr->hdrlen >> 1;
+
+	addrs = ((struct rt0_hdr *)rthdr)->addr;
+	ipv6_addr_copy(&final_addr, addrs + segments - 1);
+
+	addrs += segments - segments_left;
+	memmove(addrs + 1, addrs, (segments_left - 1) * sizeof(*addrs));
+
+	ipv6_addr_copy(addrs, &iph->daddr);
+	ipv6_addr_copy(&iph->daddr, &final_addr);
+}
+
 static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len)
 {
 	union {
@@ -101,7 +141,7 @@
 			break;
 
 		case NEXTHDR_ROUTING:
-			exthdr.rth->segments_left = 0; 
+			ipv6_rearrange_rthdr(iph, exthdr.rth);
 			break;
 
 		default :

--pf9I7BMVVzbSWLtt--
