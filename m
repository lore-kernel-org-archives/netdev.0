From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 4/5] RDS: Copy rds_iovecs into kernel memory instead of rereading from userspace
Date: Thu, 28 Oct 2010 18:40:58 -0700
Message-ID: <1288316459-4679-5-git-send-email-andy.grover@oracle.com>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43939 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756306Ab0J2Bl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:41:57 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9T1fth9030892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:41:57 GMT
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change rds_rdma_pages to take a passed-in rds_iovec array instead
of doing copy_from_user itself.

Change rds_cmsg_rdma_args to copy rds_iovec array once only. This
eliminates the possibility of userspace changing it after our
sanity checks.

Implement stack-based storage for small numbers of iovecs, based
on net/socket.c, to save an alloc in the extremely common case.

Although this patch reduces iovec copies in cmsg_rdma_args to 1,
we still do another one in rds_rdma_extra_size. Getting rid of
that one will be trickier, so it'll be a separate patch.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/rdma.c |  104 +++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 65 insertions(+), 39 deletions(-)

diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index 334acdd..caa4d98 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -479,13 +479,38 @@ void rds_atomic_free_op(struct rm_atomic_op *ao)
 
 
 /*
- * Count the number of pages needed to describe an incoming iovec.
+ * Count the number of pages needed to describe an incoming iovec array.
  */
-static int rds_rdma_pages(struct rds_rdma_args *args)
+static int rds_rdma_pages(struct rds_iovec iov[], int nr_iovecs)
+{
+	int tot_pages = 0;
+	unsigned int nr_pages;
+	unsigned int i;
+
+	/* figure out the number of pages in the vector */
+	for (i = 0; i < nr_iovecs; i++) {
+		nr_pages = rds_pages_in_vec(&iov[i]);
+		if (nr_pages == 0)
+			return -EINVAL;
+
+		tot_pages += nr_pages;
+
+		/*
+		 * nr_pages for one entry is limited to (UINT_MAX>>PAGE_SHIFT)+1,
+		 * so tot_pages cannot overflow without first going negative.
+		 */
+		if (tot_pages < 0)
+			return -EINVAL;
+	}
+
+	return tot_pages;
+}
+
+int rds_rdma_extra_size(struct rds_rdma_args *args)
 {
 	struct rds_iovec vec;
 	struct rds_iovec __user *local_vec;
-	unsigned int tot_pages = 0;
+	int tot_pages = 0;
 	unsigned int nr_pages;
 	unsigned int i;
 
@@ -507,16 +532,11 @@ static int rds_rdma_pages(struct rds_rdma_args *args)
 		 * nr_pages for one entry is limited to (UINT_MAX>>PAGE_SHIFT)+1,
 		 * so tot_pages cannot overflow without first going negative.
 		 */
-		if ((int)tot_pages < 0)
+		if (tot_pages < 0)
 			return -EINVAL;
 	}
 
-	return tot_pages;
-}
-
-int rds_rdma_extra_size(struct rds_rdma_args *args)
-{
-	return rds_rdma_pages(args) * sizeof(struct scatterlist);
+	return tot_pages * sizeof(struct scatterlist);
 }
 
 /*
@@ -527,13 +547,12 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 			  struct cmsghdr *cmsg)
 {
 	struct rds_rdma_args *args;
-	struct rds_iovec vec;
 	struct rm_rdma_op *op = &rm->rdma;
 	int nr_pages;
 	unsigned int nr_bytes;
 	struct page **pages = NULL;
-	struct rds_iovec __user *local_vec;
-	unsigned int nr;
+	struct rds_iovec iovstack[UIO_FASTIOV], *iovs = iovstack;
+	int iov_size;
 	unsigned int i, j;
 	int ret = 0;
 
@@ -553,7 +572,22 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 		goto out;
 	}
 
-	nr_pages = rds_rdma_pages(args);
+	/* Check whether to allocate the iovec area */
+	iov_size = args->nr_local * sizeof(struct rds_iovec);
+	if (args->nr_local > UIO_FASTIOV) {
+		iovs = sock_kmalloc(rds_rs_to_sk(rs), iov_size, GFP_KERNEL);
+		if (!iovs) {
+			ret = -ENOMEM;
+			goto out;
+		}
+	}
+
+	if (copy_from_user(iovs, (struct rds_iovec __user *)(unsigned long) args->local_vec_addr, iov_size)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	nr_pages = rds_rdma_pages(iovs, args->nr_local);
 	if (nr_pages < 0) {
 		ret = -EINVAL;
 		goto out;
@@ -606,50 +640,40 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	       (unsigned long long)args->remote_vec.addr,
 	       op->op_rkey);
 
-	local_vec = (struct rds_iovec __user *)(unsigned long) args->local_vec_addr;
-
 	for (i = 0; i < args->nr_local; i++) {
-		if (copy_from_user(&vec, &local_vec[i],
-				   sizeof(struct rds_iovec))) {
-			ret = -EFAULT;
-			goto out;
-		}
-
-		nr = rds_pages_in_vec(&vec);
-		if (nr == 0) {
-			ret = -EINVAL;
-			goto out;
-		}
+		struct rds_iovec *iov = &iovs[i];
+		/* don't need to check, rds_rdma_pages() verified nr will be +nonzero */
+		unsigned int nr = rds_pages_in_vec(iov);
 
-		rs->rs_user_addr = vec.addr;
-		rs->rs_user_bytes = vec.bytes;
+		rs->rs_user_addr = iov->addr;
+		rs->rs_user_bytes = iov->bytes;
 
 		/* If it's a WRITE operation, we want to pin the pages for reading.
 		 * If it's a READ operation, we need to pin the pages for writing.
 		 */
-		ret = rds_pin_pages(vec.addr, nr, pages, !op->op_write);
+		ret = rds_pin_pages(iov->addr, nr, pages, !op->op_write);
 		if (ret < 0)
 			goto out;
 
-		rdsdebug("RDS: nr_bytes %u nr %u vec.bytes %llu vec.addr %llx\n",
-		       nr_bytes, nr, vec.bytes, vec.addr);
+		rdsdebug("RDS: nr_bytes %u nr %u iov->bytes %llu iov->addr %llx\n",
+			 nr_bytes, nr, iov->bytes, iov->addr);
 
-		nr_bytes += vec.bytes;
+		nr_bytes += iov->bytes;
 
 		for (j = 0; j < nr; j++) {
-			unsigned int offset = vec.addr & ~PAGE_MASK;
+			unsigned int offset = iov->addr & ~PAGE_MASK;
 			struct scatterlist *sg;
 
 			sg = &op->op_sg[op->op_nents + j];
 			sg_set_page(sg, pages[j],
-					min_t(unsigned int, vec.bytes, PAGE_SIZE - offset),
+					min_t(unsigned int, iov->bytes, PAGE_SIZE - offset),
 					offset);
 
-			rdsdebug("RDS: sg->offset %x sg->len %x vec.addr %llx vec.bytes %llu\n",
-			       sg->offset, sg->length, vec.addr, vec.bytes);
+			rdsdebug("RDS: sg->offset %x sg->len %x iov->addr %llx iov->bytes %llu\n",
+			       sg->offset, sg->length, iov->addr, iov->bytes);
 
-			vec.addr += sg->length;
-			vec.bytes -= sg->length;
+			iov->addr += sg->length;
+			iov->bytes -= sg->length;
 		}
 
 		op->op_nents += nr;
@@ -665,6 +689,8 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	op->op_bytes = nr_bytes;
 
 out:
+	if (iovs != iovstack)
+		sock_kfree_s(rds_rs_to_sk(rs), iovs, iov_size);
 	kfree(pages);
 	if (ret)
 		rds_rdma_free_op(op);
-- 
1.7.1

