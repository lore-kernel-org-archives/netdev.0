From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] pmtu check conditions error in IPv6
Date: Wed, 26 May 2004 13:19:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405261319.55787.mashirle@us.ibm.com>
References: <200403171130.30282.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_rvPtAxMQgQLHNyK"
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200403171130.30282.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_rvPtAxMQgQLHNyK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Here is the patch. IPv6 pmtu check conditions were wrong in these two places.
this patch is against 2.6.6 kernel. It has been tested under 2.6.5 kernel for 
IPsec.

-- 
Thanks
Shirley Ma
IBM Linux Technology Center


--Boundary-00=_rvPtAxMQgQLHNyK
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.6.pmtu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.6.pmtu.patch"

diff -urN linux-2.6.6/net/ipv6/route.c linux-2.6.6.pmtu/net/ipv6/route.c
--- linux-2.6.6/net/ipv6/route.c	2004-05-09 19:33:05.000000000 -0700
+++ linux-2.6.6.pmtu/net/ipv6/route.c	2004-05-26 13:15:28.288796272 -0700
@@ -554,6 +554,8 @@
 
 	if (mtu < dst_pmtu(dst) && rt6->rt6i_dst.plen == 128) {
 		rt6->rt6i_flags |= RTF_MODIFIED;
+		if (mtu < IPV6_MIN_MTU)
+			mtu = IPV6_MIN_MTU;
 		dst->metrics[RTAX_MTU-1] = mtu;
 	}
 }
diff -urN linux-2.6.6/net/ipv6/xfrm6_policy.c linux-2.6.6.pmtu/net/ipv6/xfrm6_policy.c
--- linux-2.6.6/net/ipv6/xfrm6_policy.c	2004-05-09 19:32:26.000000000 -0700
+++ linux-2.6.6.pmtu/net/ipv6/xfrm6_policy.c	2004-05-26 13:15:28.322791104 -0700
@@ -236,10 +236,10 @@
 {
 	struct dst_entry *path = dst->path;
 
-	if (mtu >= 1280 && mtu < dst_pmtu(dst))
-		return;
-
-	path->ops->update_pmtu(path, mtu);
+	if (mtu >= IPV6_MIN_MTU && mtu < dst_pmtu(dst))
+		path->ops->update_pmtu(path, mtu);
+	
+	return;
 }
 
 struct dst_ops xfrm6_dst_ops = {

--Boundary-00=_rvPtAxMQgQLHNyK--
