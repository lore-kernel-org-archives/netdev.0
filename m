From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6]: Ensure to learn link-layer address from RA.
Date: Tue, 18 Jan 2005 22:37:18 +0900 (JST)
Message-ID: <20050118.223718.112287192.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Here's a patch to ensure to learn link-layer address from RA.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/ndisc.c 1.107 vs edited =====
--- 1.107/net/ipv6/ndisc.c	2004-12-28 15:19:28 +09:00
+++ edited/net/ipv6/ndisc.c	2005-01-18 22:24:04 +09:00
@@ -985,7 +985,7 @@
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
         struct ra_msg *ra_msg = (struct ra_msg *) skb->h.raw;
-	struct neighbour *neigh;
+	struct neighbour *neigh = NULL;
 	struct inet6_dev *in6_dev;
 	struct rt6_info *rt;
 	int lifetime;
@@ -1053,7 +1053,11 @@
 
 	rt = rt6_get_dflt_router(&skb->nh.ipv6h->saddr, skb->dev);
 
+	if (rt)
+		neigh = rt->rt6i_nexthop;
+
 	if (rt && lifetime == 0) {
+		neigh_clone(neigh);
 		ip6_del_rt(rt, NULL, NULL);
 		rt = NULL;
 	}
@@ -1126,7 +1130,10 @@
 	 *	Process options.
 	 */
 
-	if (rt && (neigh = rt->rt6i_nexthop) != NULL) {
+	if (!neigh)
+		neigh = __neigh_lookup(&nd_tbl, &skb->nh.ipv6h->saddr,
+				       skb->dev, 1);
+	if (neigh) {
 		u8 *lladdr = NULL;
 		int lladdrlen;
 		if (ndopts.nd_opts_src_lladdr) {
@@ -1181,6 +1188,8 @@
 out:
 	if (rt)
 		dst_release(&rt->u.dst);
+	else if (neigh)
+		neigh_release(neigh);
 	in6_dev_put(in6_dev);
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
