From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 1/3] ipv6: Remove un-used argument from ip6_dst_alloc()
Date: Fri, 14 Aug 2015 11:05:52 -0700
Message-ID: <1439575554-3823839-2-git-send-email-kafai@fb.com>
References: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:5607 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751642AbbHNSVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 14:21:09 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7EIL3WS024619
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:21:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w9m8m86e9-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:21:08 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 21d9155642b111e59c1d24be0595f910-6dff22b0 for <netdev@vger.kernel.org>;	Fri,
 14 Aug 2015 11:20:25 -0700
In-Reply-To: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After 4b32b5ad31a6 ("ipv6: Stop rt6_info from using inet_peer's metrics"),
ip6_dst_alloc() does not need the 'table' argument.  This patch
cleans it up.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9de4d2b..c95c319 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -318,8 +318,7 @@ static const struct rt6_info ip6_blk_hole_entry_template = {
 /* allocate dst with ip6_dst_ops */
 static struct rt6_info *__ip6_dst_alloc(struct net *net,
 					struct net_device *dev,
-					int flags,
-					struct fib6_table *table)
+					int flags)
 {
 	struct rt6_info *rt = dst_alloc(&net->ipv6.ip6_dst_ops, dev,
 					0, DST_OBSOLETE_FORCE_CHK, flags);
@@ -336,10 +335,9 @@ static struct rt6_info *__ip6_dst_alloc(struct net *net,
 
 static struct rt6_info *ip6_dst_alloc(struct net *net,
 				      struct net_device *dev,
-				      int flags,
-				      struct fib6_table *table)
+				      int flags)
 {
-	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags, table);
+	struct rt6_info *rt = __ip6_dst_alloc(net, dev, flags);
 
 	if (rt) {
 		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
@@ -950,8 +948,7 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 	if (ort->rt6i_flags & (RTF_CACHE | RTF_PCPU))
 		ort = (struct rt6_info *)ort->dst.from;
 
-	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev,
-			     0, ort->rt6i_table);
+	rt = __ip6_dst_alloc(dev_net(ort->dst.dev), ort->dst.dev, 0);
 
 	if (!rt)
 		return NULL;
@@ -983,8 +980,7 @@ static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
 	struct rt6_info *pcpu_rt;
 
 	pcpu_rt = __ip6_dst_alloc(dev_net(rt->dst.dev),
-				  rt->dst.dev, rt->dst.flags,
-				  rt->rt6i_table);
+				  rt->dst.dev, rt->dst.flags);
 
 	if (!pcpu_rt)
 		return NULL;
@@ -1555,7 +1551,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	if (unlikely(!idev))
 		return ERR_PTR(-ENODEV);
 
-	rt = ip6_dst_alloc(net, dev, 0, NULL);
+	rt = ip6_dst_alloc(net, dev, 0);
 	if (unlikely(!rt)) {
 		in6_dev_put(idev);
 		dst = ERR_PTR(-ENOMEM);
@@ -1742,7 +1738,8 @@ int ip6_route_add(struct fib6_config *cfg)
 	if (!table)
 		goto out;
 
-	rt = ip6_dst_alloc(net, NULL, (cfg->fc_flags & RTF_ADDRCONF) ? 0 : DST_NOCOUNT, table);
+	rt = ip6_dst_alloc(net, NULL,
+			   (cfg->fc_flags & RTF_ADDRCONF) ? 0 : DST_NOCOUNT);
 
 	if (!rt) {
 		err = -ENOMEM;
@@ -2399,7 +2396,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 {
 	struct net *net = dev_net(idev->dev);
 	struct rt6_info *rt = ip6_dst_alloc(net, net->loopback_dev,
-					    DST_NOCOUNT, NULL);
+					    DST_NOCOUNT);
 	if (!rt)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.8.1
