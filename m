From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] dst allocation problem in ndisc
Date: Wed, 9 Jun 2004 16:00:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406091600.30568.mashirle@us.ibm.com>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com> <200403311326.43647.mashirle@us.ibm.com> <200405261308.54281.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Oa5xAH0hW4Xu7qQ"
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200405261308.54281.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_Oa5xAH0hW4Xu7qQ
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

When creating dst entry from ndisc, the dst entry of pmtu is not set, and the 
outout for this kind of dst entry is set to ip_output2 instead of ip_output. 
This could lead to send bigger packets through these des entries without 
fragmentation, and uninitialized pmtu could lead the network unreachable. 

These problems are easy reproduced when configuring IPSEC for ipv6. IPSEC 
could pick up dst entry created by ndisc as child des entry if ndisc dst 
entry generated earlier. If sending bigger packets through IPSEC, the ip 
output2 will send bigger packets out, the driver will drop these packets on 
receiver side. Also the dst_entry pmtu will be 0, the network is unreachable.

The patch has been tested against 2.6.6. I am not sure why ndisc genereats dst 
entry with output equal to ip6_output2 not ip6_output. If ndisc sends bigger 
packets, it will break also. 

Here is the patch against 2.6.6 kernel. Please review this patch.

-- 
Thanks
Shirley Ma
IBM Linux Technology Center


--Boundary-00=_Oa5xAH0hW4Xu7qQ
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="linux-2.6.6-dst.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.6-dst.patch"

diff -urN linux-2.6.6/net/ipv6/ndisc.c linux-2.6.6-dst/net/ipv6/ndisc.c
--- linux-2.6.6/net/ipv6/ndisc.c	2004-05-09 19:32:39.000000000 -0700
+++ linux-2.6.6-dst/net/ipv6/ndisc.c	2004-06-09 15:35:37.000000000 -0700
@@ -395,7 +395,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_ADVERTISEMENT, src_addr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output2);
+	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
 	if (!dst)
 		return;
 
@@ -486,7 +486,7 @@
 
 	ndisc_flow_init(&fl, NDISC_NEIGHBOUR_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output2);
+	dst = ndisc_dst_alloc(dev, neigh, daddr, ip6_output);
 	if (!dst)
 		return;
 
@@ -562,7 +562,7 @@
 
 	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr);
 
-	dst = ndisc_dst_alloc(dev, NULL, daddr, ip6_output2);
+	dst = ndisc_dst_alloc(dev, NULL, daddr, ip6_output);
 	if (!dst)
 		return;
 
diff -urN linux-2.6.6/net/ipv6/route.c linux-2.6.6-dst/net/ipv6/route.c
--- linux-2.6.6/net/ipv6/route.c	2004-05-09 19:33:05.000000000 -0700
+++ linux-2.6.6-dst/net/ipv6/route.c	2004-06-09 15:41:49.000000000 -0700
@@ -558,6 +558,56 @@
 	}
 }
 
+/* Clean host part of a prefix. Not necessary in radix tree,
+   but results in cleaner routing tables.
+
+   Remove it only when all the things will work!
+ */
+
+static int ipv6_get_mtu(struct net_device *dev)
+{
+	int mtu = IPV6_MIN_MTU;
+	struct inet6_dev *idev;
+
+	idev = in6_dev_get(dev);
+	if (idev) {
+		mtu = idev->cnf.mtu6;
+		in6_dev_put(idev);
+	}
+	return mtu;
+}
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
+
+static int ipv6_get_hoplimit(struct net_device *dev)
+{
+	int hoplimit = ipv6_devconf.hop_limit;
+	struct inet6_dev *idev;
+
+	idev = in6_dev_get(dev);
+	if (idev) {
+		hoplimit = idev->cnf.hop_limit;
+		in6_dev_put(idev);
+	}
+	return hoplimit;
+}
+
 /* Protected by rt6_lock.  */
 static struct dst_entry *ndisc_dst_gc_list;
 
@@ -585,6 +635,8 @@
 	rt->rt6i_metric   = 0;
 	atomic_set(&rt->u.dst.__refcnt, 1);
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = 255;
+	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
+	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_pmtu(&rt->u.dst));
 	rt->u.dst.output  = output;
 
 	write_lock_bh(&rt6_lock);
@@ -641,56 +693,6 @@
 	return (atomic_read(&ip6_dst_ops.entries) > ip6_rt_max_size);
 }
 
-/* Clean host part of a prefix. Not necessary in radix tree,
-   but results in cleaner routing tables.
-
-   Remove it only when all the things will work!
- */
-
-static int ipv6_get_mtu(struct net_device *dev)
-{
-	int mtu = IPV6_MIN_MTU;
-	struct inet6_dev *idev;
-
-	idev = in6_dev_get(dev);
-	if (idev) {
-		mtu = idev->cnf.mtu6;
-		in6_dev_put(idev);
-	}
-	return mtu;
-}
-
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
-static int ipv6_get_hoplimit(struct net_device *dev)
-{
-	int hoplimit = ipv6_devconf.hop_limit;
-	struct inet6_dev *idev;
-
-	idev = in6_dev_get(dev);
-	if (idev) {
-		hoplimit = idev->cnf.hop_limit;
-		in6_dev_put(idev);
-	}
-	return hoplimit;
-}
-
 /*
  *
  */

--Boundary-00=_Oa5xAH0hW4Xu7qQ--
