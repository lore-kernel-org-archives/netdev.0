From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] rds: avoid calling sock_kfree_s() on allocation failure
Date: Tue, 14 Oct 2014 12:35:08 -0700
Message-ID: <1413315308-32288-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	Chien Yen <chien.yen@oracle.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <cwang@twopensource.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62269 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbaJNTfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:35:13 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so8416525pab.2
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 12:35:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

It is okay to free a NULL pointer but not okay to mischarge the socket optmem
accounting. Compile test only.

Reported-by: rucsoftsec@gmail.com
Cc: Chien Yen <chien.yen@oracle.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 4e37c1c..40084d8 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -564,12 +564,12 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 
 	if (rs->rs_bound_addr == 0) {
 		ret = -ENOTCONN; /* XXX not a great errno */
-		goto out;
+		goto out_ret;
 	}
 
 	if (args->nr_local > UIO_MAXIOV) {
 		ret = -EMSGSIZE;
-		goto out;
+		goto out_ret;
 	}
 
 	/* Check whether to allocate the iovec area */
@@ -578,7 +578,7 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 		iovs = sock_kmalloc(rds_rs_to_sk(rs), iov_size, GFP_KERNEL);
 		if (!iovs) {
 			ret = -ENOMEM;
-			goto out;
+			goto out_ret;
 		}
 	}
 
@@ -696,6 +696,7 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	if (iovs != iovstack)
 		sock_kfree_s(rds_rs_to_sk(rs), iovs, iov_size);
 	kfree(pages);
+out_ret:
 	if (ret)
 		rds_rdma_free_op(op);
 	else
