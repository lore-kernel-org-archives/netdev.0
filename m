From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 4/6] net: mpls: Limit memory allocation for mpls_route
Date: Thu, 30 Mar 2017 09:18:22 -0700
Message-ID: <1490890704-8075-5-git-send-email-dsa@cumulusnetworks.com>
References: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36807 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934406AbdC3QSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:35 -0400
Received: by mail-pg0-f48.google.com with SMTP id g2so43890354pge.3
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:34 -0700 (PDT)
In-Reply-To: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Limit memory allocation size for mpls_route to 4096.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- new patch in v2 of set

 net/mpls/af_mpls.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 1863b94133e4..f84c52b6eafc 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -26,6 +26,9 @@
 
 #define MAX_NEW_LABELS 2
 
+/* max memory we will use for mpls_route */
+#define MAX_MPLS_ROUTE_MEM	4096
+
 /* Maximum number of labels to look ahead at when selecting a path of
  * a multipath route
  */
@@ -477,14 +480,20 @@ static struct mpls_route *mpls_rt_alloc(u8 num_nh, u8 max_alen, u8 max_labels)
 {
 	u8 nh_size = MPLS_NH_SIZE(max_labels, max_alen);
 	struct mpls_route *rt;
+	size_t size;
 
-	rt = kzalloc(sizeof(*rt) + num_nh * nh_size, GFP_KERNEL);
-	if (rt) {
-		rt->rt_nhn = num_nh;
-		rt->rt_nhn_alive = num_nh;
-		rt->rt_nh_size = nh_size;
-		rt->rt_via_offset = MPLS_NH_VIA_OFF(max_labels);
-	}
+	size = sizeof(*rt) + num_nh * nh_size;
+	if (size > MAX_MPLS_ROUTE_MEM)
+		return ERR_PTR(-EINVAL);
+
+	rt = kzalloc(size, GFP_KERNEL);
+	if (!rt)
+		return ERR_PTR(-ENOMEM);
+
+	rt->rt_nhn = num_nh;
+	rt->rt_nhn_alive = num_nh;
+	rt->rt_nh_size = nh_size;
+	rt->rt_via_offset = MPLS_NH_VIA_OFF(max_labels);
 
 	return rt;
 }
@@ -898,8 +907,10 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 
 	err = -ENOMEM;
 	rt = mpls_rt_alloc(nhs, max_via_alen, MAX_NEW_LABELS);
-	if (!rt)
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
 		goto errout;
+	}
 
 	rt->rt_protocol = cfg->rc_protocol;
 	rt->rt_payload_type = cfg->rc_payload_type;
@@ -1970,7 +1981,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	if (limit > MPLS_LABEL_IPV4NULL) {
 		struct net_device *lo = net->loopback_dev;
 		rt0 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
-		if (!rt0)
+		if (IS_ERR(rt0))
 			goto nort0;
 		RCU_INIT_POINTER(rt0->rt_nh->nh_dev, lo);
 		rt0->rt_protocol = RTPROT_KERNEL;
@@ -1984,7 +1995,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
 	if (limit > MPLS_LABEL_IPV6NULL) {
 		struct net_device *lo = net->loopback_dev;
 		rt2 = mpls_rt_alloc(1, lo->addr_len, MAX_NEW_LABELS);
-		if (!rt2)
+		if (IS_ERR(rt2))
 			goto nort2;
 		RCU_INIT_POINTER(rt2->rt_nh->nh_dev, lo);
 		rt2->rt_protocol = RTPROT_KERNEL;
-- 
2.1.4
