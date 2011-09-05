From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv4: Fix fib_info->fib_metrics leak
Date: Mon, 05 Sep 2011 14:24:20 +0800
Message-ID: <4E646B14.1020801@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>, laijs@cn.fujitsu.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43676 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1IEGYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 02:24:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4670994d(net,rcu: convert call_rcu(fc_rport_free_rcu) to
kfree_rcu()) introduced a memory leak. This patch reverts it.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 33e2c35..80106d8 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -142,6 +142,14 @@ const struct fib_prop fib_props[RTN_MAX + 1] = {
 };
 
 /* Release a nexthop info record */
+static void free_fib_info_rcu(struct rcu_head *head)
+{
+	struct fib_info *fi = container_of(head, struct fib_info, rcu);
+
+	if (fi->fib_metrics != (u32 *) dst_default_metrics)
+		kfree(fi->fib_metrics);
+	kfree(fi);
+}
 
 void free_fib_info(struct fib_info *fi)
 {
@@ -156,7 +164,7 @@ void free_fib_info(struct fib_info *fi)
 	} endfor_nexthops(fi);
 	fib_info_cnt--;
 	release_net(fi->fib_net);
-	kfree_rcu(fi, rcu);
+	call_rcu(&fi->rcu, free_fib_info_rcu);
 }
 
 void fib_release_info(struct fib_info *fi)
