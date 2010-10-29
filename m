From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 5/5] RDS: Let rds_message_alloc_sgs() return NULL
Date: Thu, 28 Oct 2010 18:40:59 -0700
Message-ID: <1288316459-4679-6-git-send-email-andy.grover@oracle.com>
References: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43540 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758797Ab0J2Blg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:41:36 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o9T1fYRI030372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:41:36 GMT
In-Reply-To: <1288316459-4679-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with the previous fix, we still are reading the iovecs once
to determine SGs needed, and then again later on. Preallocating
space for sg lists as part of rds_message seemed like a good idea
but it might be better to not do this. While working to redo that
code, this patch attempts to protect against userspace rewriting
the rds_iovec array between the first and second accesses.

The consequences of this would be either a too-small or too-large
sg list array. Too large is not an issue. This patch changes all
callers of message_alloc_sgs to handle running out of preallocated
sgs, and fail gracefully.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/message.c |    5 +++++
 net/rds/rdma.c    |    8 ++++++++
 net/rds/send.c    |    4 ++++
 3 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/rds/message.c b/net/rds/message.c
index a84545d..848cff4 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -224,6 +224,9 @@ struct scatterlist *rds_message_alloc_sgs(struct rds_message *rm, int nents)
 	WARN_ON(rm->m_used_sgs + nents > rm->m_total_sgs);
 	WARN_ON(!nents);
 
+	if (rm->m_used_sgs + nents > rm->m_total_sgs)
+		return NULL;
+
 	sg_ret = &sg_first[rm->m_used_sgs];
 	sg_init_table(sg_ret, nents);
 	rm->m_used_sgs += nents;
@@ -246,6 +249,8 @@ struct rds_message *rds_message_map_pages(unsigned long *page_addrs, unsigned in
 	rm->m_inc.i_hdr.h_len = cpu_to_be32(total_len);
 	rm->data.op_nents = ceil(total_len, PAGE_SIZE);
 	rm->data.op_sg = rds_message_alloc_sgs(rm, num_sgs);
+	if (!rm->data.op_sg)
+		return ERR_PTR(-ENOMEM);
 
 	for (i = 0; i < rm->data.op_nents; ++i) {
 		sg_set_page(&rm->data.op_sg[i],
diff --git a/net/rds/rdma.c b/net/rds/rdma.c
index caa4d98..8920f2a 100644
--- a/net/rds/rdma.c
+++ b/net/rds/rdma.c
@@ -607,6 +607,10 @@ int rds_cmsg_rdma_args(struct rds_sock *rs, struct rds_message *rm,
 	op->op_recverr = rs->rs_recverr;
 	WARN_ON(!nr_pages);
 	op->op_sg = rds_message_alloc_sgs(rm, nr_pages);
+	if (!op->op_sg) {
+		ret = -ENOMEM;
+		goto out;
+	}
 
 	if (op->op_notify || op->op_recverr) {
 		/* We allocate an uninitialized notifier here, because
@@ -807,6 +811,10 @@ int rds_cmsg_atomic(struct rds_sock *rs, struct rds_message *rm,
 	rm->atomic.op_active = 1;
 	rm->atomic.op_recverr = rs->rs_recverr;
 	rm->atomic.op_sg = rds_message_alloc_sgs(rm, 1);
+	if (!rm->atomic.op_sg) {
+		ret = -ENOMEM;
+		goto err;
+	}
 
 	/* verify 8 byte-aligned */
 	if (args->local_addr & 0x7) {
diff --git a/net/rds/send.c b/net/rds/send.c
index 0bc9db1..35b9c2e 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -973,6 +973,10 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	/* Attach data to the rm */
 	if (payload_len) {
 		rm->data.op_sg = rds_message_alloc_sgs(rm, ceil(payload_len, PAGE_SIZE));
+		if (!rm->data.op_sg) {
+			ret = -ENOMEM;
+			goto out;
+		}
 		ret = rds_message_copy_from_user(rm, msg->msg_iov, payload_len);
 		if (ret)
 			goto out;
-- 
1.7.1

