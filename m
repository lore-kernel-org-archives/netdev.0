From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/4] net: mpls: bump maximum number of labels
Date: Sat, 25 Mar 2017 10:03:27 -0700
Message-ID: <1490461408-9551-4-git-send-email-dsa@cumulusnetworks.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34665 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdCYRDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 13:03:45 -0400
Received: by mail-pg0-f53.google.com with SMTP id 21so9499618pgg.1
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 10:03:44 -0700 (PDT)
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow users to push down more labels per MPLS route. With the previous
patch no memory allocations for routes are based on MAX_NEW_LABELS, so
the limit is only used to keep userspace in check.

Per discussions, 16 labels has been deemed execessive, 8 seems to handle
most use cases, though 1 user has expressed an interest in up to 12
labels. Since the limit is only used to cap what userspace can push
down to the kernel, set the new limit to 12 which should accommodate all
known segment routing use cases.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 59 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index e402e5148765..3023c261a04b 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -24,7 +24,10 @@
 #include <net/nexthop.h>
 #include "internal.h"
 
-#define MAX_NEW_LABELS 2
+/* put a reasonable limit on the number of labels
+ * we will accept from userspace
+ */
+#define MAX_NEW_LABELS 12
 
 /* Maximum number of labels to look ahead at when selecting a path of
  * a multipath route
@@ -681,9 +684,6 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 		return -ENOMEM;
 
 	err = -EINVAL;
-	/* Ensure only a supported number of labels are present */
-	if (cfg->rc_output_labels > MAX_NEW_LABELS)
-		goto errout;
 
 	nh->nh_labels = cfg->rc_output_labels;
 	for (i = 0; i < nh->nh_labels; i++)
@@ -708,7 +708,7 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 
 static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 			 struct mpls_nh *nh, int oif, struct nlattr *via,
-			 struct nlattr *newdst)
+			 struct nlattr *newdst, u8 max_labels)
 {
 	int err = -ENOMEM;
 
@@ -716,7 +716,7 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 		goto errout;
 
 	if (newdst) {
-		err = nla_get_labels(newdst, MAX_NEW_LABELS,
+		err = nla_get_labels(newdst, max_labels,
 				     &nh->nh_labels, nh->nh_label);
 		if (err)
 			goto errout;
@@ -742,21 +742,19 @@ static int mpls_nh_build(struct net *net, struct mpls_route *rt,
 }
 
 static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
-			      u8 cfg_via_alen, u8 *max_via_alen)
+			      u8 cfg_via_alen, u8 *max_via_alen,
+			      u8 *max_labels)
 {
 	int remaining = len;
 	u8 nhs = 0;
 
-	if (!rtnh) {
-		*max_via_alen = cfg_via_alen;
-		return 1;
-	}
-
 	*max_via_alen = 0;
+	*max_labels = 0;
 
 	while (rtnh_ok(rtnh, remaining)) {
 		struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
 		int attrlen;
+		u8 n_labels;
 
 		attrlen = rtnh_attrlen(rtnh);
 		nla = nla_find(attrs, attrlen, RTA_VIA);
@@ -770,6 +768,12 @@ static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 						      via_alen);
 		}
 
+		nla = nla_find(attrs, attrlen, RTA_NEWDST);
+		if (nla &&
+		    nla_get_labels(nla, MAX_NEW_LABELS, &n_labels, NULL) == 0) {
+			*max_labels = max_t(u8, *max_labels, n_labels);
+		}
+
 		/* number of nexthops is tracked by a u8.
 		 * Check for overflow.
 		 */
@@ -786,7 +790,7 @@ static u8 mpls_count_nexthops(struct rtnexthop *rtnh, int len,
 }
 
 static int mpls_nh_build_multi(struct mpls_route_config *cfg,
-			       struct mpls_route *rt)
+			       struct mpls_route *rt, u8 max_labels)
 {
 	struct rtnexthop *rtnh = cfg->rc_mp;
 	struct nlattr *nla_via, *nla_newdst;
@@ -819,7 +823,8 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 		}
 
 		err = mpls_nh_build(cfg->rc_nlinfo.nl_net, rt, nh,
-				    rtnh->rtnh_ifindex, nla_via, nla_newdst);
+				    rtnh->rtnh_ifindex, nla_via, nla_newdst,
+				    max_labels);
 		if (err)
 			goto errout;
 
@@ -846,6 +851,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	int err = -EINVAL;
 	u8 max_via_alen;
 	unsigned index;
+	u8 max_labels;
 	u8 nhs;
 
 	index = cfg->rc_label;
@@ -884,13 +890,21 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		goto errout;
 
 	err = -EINVAL;
-	nhs = mpls_count_nexthops(cfg->rc_mp, cfg->rc_mp_len,
-				  cfg->rc_via_alen, &max_via_alen);
-	if (nhs == 0)
+	if (cfg->rc_mp) {
+		nhs = mpls_count_nexthops(cfg->rc_mp, cfg->rc_mp_len,
+					  cfg->rc_via_alen, &max_via_alen,
+					  &max_labels);
+	} else {
+		max_via_alen = cfg->rc_via_alen;
+		max_labels = cfg->rc_output_labels;
+		nhs = 1;
+	}
+
+	if (nhs == 0 || max_labels > MAX_NEW_LABELS)
 		goto errout;
 
 	err = -ENOMEM;
-	rt = mpls_rt_alloc(nhs, max_via_alen, MAX_NEW_LABELS);
+	rt = mpls_rt_alloc(nhs, max_via_alen, max_labels);
 	if (!rt)
 		goto errout;
 
@@ -899,7 +913,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 	rt->rt_ttl_propagate = cfg->rc_ttl_propagate;
 
 	if (cfg->rc_mp)
-		err = mpls_nh_build_multi(cfg, rt);
+		err = mpls_nh_build_multi(cfg, rt, max_labels);
 	else
 		err = mpls_nh_build_from_cfg(cfg, rt);
 	if (err)
@@ -1534,7 +1548,8 @@ int nla_get_labels(const struct nlattr *nla,
 			return -EINVAL;
 		}
 
-		label[i] = dec.label;
+		if (label)
+			label[i] = dec.label;
 	}
 	*labels = nla_labels;
 	return 0;
@@ -1941,7 +1956,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	/* In case the predefined labels need to be populated */
 	if (limit > MPLS_LABEL_IPV4NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt0 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
+		rt0 = mpls_rt_alloc(1, lo->addr_len, 0);
 		if (!rt0)
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
@@ -1955,7 +1970,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	}
 	if (limit > MPLS_LABEL_IPV6NULL) {
 		struct net_device *lo = net->loopback_dev;
-		rt2 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
+		rt2 = mpls_rt_alloc(1, lo->addr_len, 0);
 		if (!rt2)
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
-- 
2.1.4
