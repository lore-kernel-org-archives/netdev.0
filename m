From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] clean-up advmss calculation
Date: Fri, 20 Jun 2003 23:43:49 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620.234349.50405228.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This patch introduces ipv6_advmss() and clean-up advmss calculation.
Thanks.

Index: linux-2.5/net/ipv6/route.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/route.c,v
retrieving revision 1.40
diff -u -r1.40 route.c
--- linux-2.5/net/ipv6/route.c	9 Jun 2003 17:26:52 -0000	1.40
+++ linux-2.5/net/ipv6/route.c	20 Jun 2003 13:28:03 -0000
@@ -600,6 +600,22 @@
 	return mtu;
 }
 
+static inline unsigned int ipv6_advmss(unsigned int mtu)
+{
+	if (mtu < ip6_rt_min_advmss)
+		mtu = ip6_rt_min_advmss;
+
+	/*
+	 * Maximal non-jumbo IPv6 payload is 65535 and 
+	 * corresponding MSS is 65535 - tcp_header_size. 
+	 * 65535 is also valid and means: "any MSS, 
+	 * rely only on pmtu discovery"
+	 */
+	if (mtu > 65535 - sizeof(struct tcphdr))
+		mtu = 65535;
+	return mtu;
+}
+
 static int ipv6_get_hoplimit(struct net_device *dev)
 {
 	int hoplimit = ipv6_devconf.hop_limit;
@@ -790,16 +806,7 @@
 	if (!rt->u.dst.metrics[RTAX_MTU-1])
 		rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(dev);
 	if (!rt->u.dst.metrics[RTAX_ADVMSS-1])
-		rt->u.dst.metrics[RTAX_ADVMSS-1] =
-			max_t(unsigned int, dst_pmtu(&rt->u.dst) - 60,
-			      ip6_rt_min_advmss);
-
-	/* Maximal non-jumbo IPv6 payload is 65535 and corresponding
-	   MSS is 65535 - tcp_header_size. 65535 is also valid and
-	   means: "any MSS, rely only on pmtu discovery"
-	 */
-	if (dst_metric(&rt->u.dst, RTAX_ADVMSS) > 65535-20)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535;
+		rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
 	rt->u.dst.dev = dev;
 	return rt6_ins(rt, nlh, _rtattr);
 
@@ -952,9 +959,7 @@
 	nrt->rt6i_nexthop = neigh_clone(neigh);
 	/* Reset pmtu, it may be better */
 	nrt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(neigh->dev);
-	nrt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, dst_pmtu(&nrt->u.dst) - 60, ip6_rt_min_advmss);
-	if (nrt->u.dst.metrics[RTAX_ADVMSS-1] > 65535-20)
-		nrt->u.dst.metrics[RTAX_ADVMSS-1] = 65535;
+	nrt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&nrt->u.dst));
 
 	if (rt6_ins(nrt, NULL, NULL))
 		goto out;
@@ -1214,9 +1219,7 @@
 	rt->u.dst.output = ip6_output;
 	rt->rt6i_dev = &loopback_dev;
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, dst_pmtu(&rt->u.dst) - 60, ip6_rt_min_advmss);
-	if (rt->u.dst.metrics[RTAX_ADVMSS-1] > 65535-20)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535;
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = ipv6_get_hoplimit(rt->rt6i_dev);
 	rt->u.dst.obsolete = -1;
 
@@ -1312,9 +1315,7 @@
              (dst_pmtu(&rt->u.dst) < arg->mtu &&
 	      dst_pmtu(&rt->u.dst) == idev->cnf.mtu6)))
 		rt->u.dst.metrics[RTAX_MTU-1] = arg->mtu;
-	rt->u.dst.metrics[RTAX_ADVMSS-1] = max_t(unsigned int, arg->mtu - 60, ip6_rt_min_advmss);
-	if (rt->u.dst.metrics[RTAX_ADVMSS-1] > 65535-20)
-		rt->u.dst.metrics[RTAX_ADVMSS-1] = 65535;
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(arg->mtu);
 	return 0;
 }
 



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
