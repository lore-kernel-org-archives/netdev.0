From: Adrian Bunk <bunk@fs.tum.de>
Subject: [2.6 patch] net/ipv6/route.c: fix inline compile error
Date: Thu, 15 Jul 2004 21:25:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715192516.GC25633@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: roque@di.fc.ul.pt
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trying to compile net/ipv6/route.c in 2.6.8-rc1-mm1 using gcc 3.4 
results in the following compile error:

<--  snip  -->

...
  CC      net/ipv6/route.o
net/ipv6/route.c: In function `ndisc_dst_alloc':
net/ipv6/route.c:587: sorry, unimplemented: inlining failed in call to 
'ipv6_advmss': function body not available
net/ipv6/route.c:611: sorry, unimplemented: called from here
make[2]: *** [net/ipv6/route.o] Error 1

<--  snip  -->


The patch below moves ipv6_advmss above the place where it's called the 
first time.

An alternative approach would be to remove the inline.


diffstat output:
 net/ipv6/route.c |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)


Signed-off-by: Adrian Bunk <bunk@fs.tum.de>

--- linux-2.6.7-mm6-full-gcc3.4/net/ipv6/route.c.old	2004-07-09 02:22:23.000000000 +0200
+++ linux-2.6.7-mm6-full-gcc3.4/net/ipv6/route.c	2004-07-09 02:23:21.000000000 +0200
@@ -584,7 +584,24 @@
 /* Protected by rt6_lock.  */
 static struct dst_entry *ndisc_dst_gc_list;
 static int ipv6_get_mtu(struct net_device *dev);
-static inline unsigned int ipv6_advmss(unsigned int mtu);
+
+static inline unsigned int ipv6_advmss(unsigned int mtu)
+{
+	mtu -= sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
+
+	if (mtu < ip6_rt_min_advmss)
+		mtu = ip6_rt_min_advmss;
+
+	/*
+	 * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and 
+	 * corresponding MSS is IPV6_MAXPLEN - tcp_header_size. 
+	 * IPV6_MAXPLEN is also valid and means: "any MSS, 
+	 * rely only on pmtu discovery"
+	 */
+	if (mtu > IPV6_MAXPLEN - sizeof(struct tcphdr))
+		mtu = IPV6_MAXPLEN;
+	return mtu;
+}
 
 struct dst_entry *ndisc_dst_alloc(struct net_device *dev, 
 				  struct neighbour *neigh,
@@ -687,24 +704,6 @@
 	return mtu;
 }
 
-static inline unsigned int ipv6_advmss(unsigned int mtu)
-{
-	mtu -= sizeof(struct ipv6hdr) + sizeof(struct tcphdr);
-
-	if (mtu < ip6_rt_min_advmss)
-		mtu = ip6_rt_min_advmss;
-
-	/*
-	 * Maximal non-jumbo IPv6 payload is IPV6_MAXPLEN and 
-	 * corresponding MSS is IPV6_MAXPLEN - tcp_header_size. 
-	 * IPV6_MAXPLEN is also valid and means: "any MSS, 
-	 * rely only on pmtu discovery"
-	 */
-	if (mtu > IPV6_MAXPLEN - sizeof(struct tcphdr))
-		mtu = IPV6_MAXPLEN;
-	return mtu;
-}
-
 static int ipv6_get_hoplimit(struct net_device *dev)
 {
 	int hoplimit = ipv6_devconf.hop_limit;
