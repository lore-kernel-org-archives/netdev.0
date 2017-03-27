From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 2/5] rds: rdma: fix memory leak error
Date: Mon, 27 Mar 2017 03:06:27 -0400
Message-ID: <1490598390-13812-3-git-send-email-yanjun.zhu@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu@oracle.com, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, junxiao.bi@oracle.com, joe.jin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22570 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdC0HH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 03:07:26 -0400
In-Reply-To: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the function __rds_rdma_map, the allocated memory and other
resources should be freed when some error occurs.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 net/rds/rdma.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index f06fac4..ad9b6bd 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -253,6 +253,8 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 	sg = kcalloc(nents, sizeof(*sg), GFP_KERNEL);
 	if (!sg) {
 		ret = -ENOMEM;
+		for (i = 0; i < nents; i++)
+			put_page(pages[i]);
 		goto out;
 	}
 	WARN_ON(!nents);
@@ -293,6 +295,11 @@ static int __rds_rdma_map(struct rds_sock *rs, struct rds_get_mr_args *args,
 		*cookie_ret = cookie;
 
 	if (args->cookie_addr && put_user(cookie, (u64 __user *)(unsigned long) args->cookie_addr)) {
+		for (i = 0; i < nents; i++)
+			put_page(sg_page(&sg[i]));
+		kfree(sg);
+		mr->r_trans->free_mr(mr->r_trans_private, 1);
+		mr->r_trans_private = NULL;
 		ret = -EFAULT;
 		goto out;
 	}
-- 
2.7.4
