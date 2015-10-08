From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] ipv6 route: use err pointers instead of returning pointer by reference
Date: Thu,  8 Oct 2015 10:26:25 -0700
Message-ID: <1444325185-42661-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35777 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965087AbbJHR03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:26:29 -0400
Received: by pabve7 with SMTP id ve7so1784763pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:26:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch makes ip6_route_info_create return err pointer instead of
returning the rt pointer by reference as suggested  by Dave

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
Dave, sorry abt the delay on this one. net-next was closed when i got to it
and its been in my queue since then.

 net/ipv6/route.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4320ddc..b45aa49 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1724,21 +1724,21 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 	return -EINVAL;
 }
 
-int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
+static struct rt6_info *ip6_route_info_create(struct fib6_config *cfg)
 {
-	int err;
 	struct net *net = cfg->fc_nlinfo.nl_net;
 	struct rt6_info *rt = NULL;
 	struct net_device *dev = NULL;
 	struct inet6_dev *idev = NULL;
 	struct fib6_table *table;
 	int addr_type;
+	int err = -EINVAL;
 
 	if (cfg->fc_dst_len > 128 || cfg->fc_src_len > 128)
-		return -EINVAL;
+		goto out;
 #ifndef CONFIG_IPV6_SUBTREES
 	if (cfg->fc_src_len)
-		return -EINVAL;
+		goto out;
 #endif
 	if (cfg->fc_ifindex) {
 		err = -ENODEV;
@@ -1958,9 +1958,7 @@ install_route:
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
-	*rt_ret = rt;
-
-	return 0;
+	return rt;
 out:
 	if (dev)
 		dev_put(dev);
@@ -1969,9 +1967,7 @@ out:
 	if (rt)
 		dst_free(&rt->dst);
 
-	*rt_ret = NULL;
-
-	return err;
+	return ERR_PTR(err);
 }
 
 int ip6_route_add(struct fib6_config *cfg)
@@ -1980,9 +1976,12 @@ int ip6_route_add(struct fib6_config *cfg)
 	struct rt6_info *rt = NULL;
 	int err;
 
-	err = ip6_route_info_create(cfg, &rt);
-	if (err)
+	rt = ip6_route_info_create(cfg);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		rt = NULL;
 		goto out;
+	}
 
 	err = ip6_convert_metrics(&mxc, cfg);
 	if (err)
@@ -2871,9 +2870,12 @@ static int ip6_route_multipath_add(struct fib6_config *cfg)
 				r_cfg.fc_encap_type = nla_get_u16(nla);
 		}
 
-		err = ip6_route_info_create(&r_cfg, &rt);
-		if (err)
+		rt = ip6_route_info_create(&r_cfg);
+		if (IS_ERR(rt)) {
+			err = PTR_ERR(rt);
+			rt = NULL;
 			goto cleanup;
+		}
 
 		err = ip6_route_info_append(&rt6_nh_list, rt, &r_cfg);
 		if (err) {
-- 
1.9.1
