From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] Fix races in ip6_route_{input,output}().
Date: Sun, 28 Nov 2004 10:36:26 +0900 (JST)
Message-ID: <20041128.103626.88640124.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

We need to hold refcnt before releasing rt6_lock.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Thanks.

===== net/ipv6/route.c 1.101 vs edited =====
--- 1.101/net/ipv6/route.c	2004-11-12 08:07:25 +09:00
+++ edited/net/ipv6/route.c	2004-11-28 10:31:52 +09:00
@@ -476,13 +476,19 @@
 	BACKTRACK();
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP)) {
+		struct rt6_info *nrt;
+		dst_hold(&rt->u.dst);
 		read_unlock_bh(&rt6_lock);
 
-		rt = rt6_cow(rt, &skb->nh.ipv6h->daddr,
-			     &skb->nh.ipv6h->saddr);
-			
+		nrt = rt6_cow(rt, &skb->nh.ipv6h->daddr,
+			      &skb->nh.ipv6h->saddr);
+
+		dst_release(&rt->u.dst);
+		rt = nrt;
+
 		if (rt->u.dst.error != -EEXIST || --attempts <= 0)
 			goto out2;
+
 		/* Race condition! In the gap, when rt6_lock was
 		   released someone could insert this route.  Relookup.
 		*/
@@ -531,9 +537,14 @@
 	}
 
 	if (!rt->rt6i_nexthop && !(rt->rt6i_flags & RTF_NONEXTHOP)) {
+		struct rt6_info *nrt;
+		dst_hold(&rt->u.dst);
 		read_unlock_bh(&rt6_lock);
 
-		rt = rt6_cow(rt, &fl->fl6_dst, &fl->fl6_src);
+		nrt = rt6_cow(rt, &fl->fl6_dst, &fl->fl6_src);
+
+		dst_release(&rt->u.dst);
+		rt = nrt;
 
 		if (rt->u.dst.error != -EEXIST || --attempts <= 0)
 			goto out2;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
