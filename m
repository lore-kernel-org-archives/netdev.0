From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 04/18] propagate msghdr all way down to __qp_memcpy_to_queue()
Date: Sat, 31 Jan 2015 03:56:30 +0000
Message-ID: <1422676604-18533-4-git-send-email-viro@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54987 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbbAaD4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 22:56:45 -0500
In-Reply-To: <20150131035513.GK29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/misc/vmw_vmci/vmci_queue_pair.c | 16 ++++++++--------
 include/linux/vmw_vmci_api.h            |  2 +-
 net/vmw_vsock/vmci_transport.c          |  3 +--
 3 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index 7aaaf51..35f19a6 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -370,12 +370,12 @@ static int __qp_memcpy_to_queue(struct vmci_queue *queue,
 			to_copy = size - bytes_copied;
 
 		if (is_iovec) {
-			struct iovec *iov = (struct iovec *)src;
+			struct msghdr *msg = (struct msghdr *)src;
 			int err;
 
 			/* The iovec will track bytes_copied internally. */
-			err = memcpy_fromiovec((u8 *)va + page_offset,
-					       iov, to_copy);
+			err = memcpy_from_msg((u8 *)va + page_offset,
+					      msg, to_copy);
 			if (err != 0) {
 				if (kernel_if->host)
 					kunmap(kernel_if->u.h.page[page_index]);
@@ -580,7 +580,7 @@ static int qp_memcpy_from_queue(void *dest,
  */
 static int qp_memcpy_to_queue_iov(struct vmci_queue *queue,
 				  u64 queue_offset,
-				  const void *src,
+				  const void *msg,
 				  size_t src_offset, size_t size)
 {
 
@@ -588,7 +588,7 @@ static int qp_memcpy_to_queue_iov(struct vmci_queue *queue,
 	 * We ignore src_offset because src is really a struct iovec * and will
 	 * maintain offset internally.
 	 */
-	return __qp_memcpy_to_queue(queue, queue_offset, src, size, true);
+	return __qp_memcpy_to_queue(queue, queue_offset, msg, size, true);
 }
 
 /*
@@ -3223,13 +3223,13 @@ EXPORT_SYMBOL_GPL(vmci_qpair_peek);
  * of bytes enqueued or < 0 on error.
  */
 ssize_t vmci_qpair_enquev(struct vmci_qp *qpair,
-			  void *iov,
+			  struct msghdr *msg,
 			  size_t iov_size,
 			  int buf_type)
 {
 	ssize_t result;
 
-	if (!qpair || !iov)
+	if (!qpair)
 		return VMCI_ERROR_INVALID_ARGS;
 
 	qp_lock(qpair);
@@ -3238,7 +3238,7 @@ ssize_t vmci_qpair_enquev(struct vmci_qp *qpair,
 		result = qp_enqueue_locked(qpair->produce_q,
 					   qpair->consume_q,
 					   qpair->produce_q_size,
-					   iov, iov_size,
+					   msg, iov_size,
 					   qp_memcpy_to_queue_iov);
 
 		if (result == VMCI_ERROR_QUEUEPAIR_NOT_READY &&
diff --git a/include/linux/vmw_vmci_api.h b/include/linux/vmw_vmci_api.h
index 5691f75..63df3a2a 100644
--- a/include/linux/vmw_vmci_api.h
+++ b/include/linux/vmw_vmci_api.h
@@ -74,7 +74,7 @@ ssize_t vmci_qpair_dequeue(struct vmci_qp *qpair,
 ssize_t vmci_qpair_peek(struct vmci_qp *qpair, void *buf, size_t buf_size,
 			int mode);
 ssize_t vmci_qpair_enquev(struct vmci_qp *qpair,
-			  void *iov, size_t iov_size, int mode);
+			  struct msghdr *msg, size_t iov_size, int mode);
 ssize_t vmci_qpair_dequev(struct vmci_qp *qpair,
 			  struct msghdr *msg, size_t iov_size, int mode);
 ssize_t vmci_qpair_peekv(struct vmci_qp *qpair, struct msghdr *msg, size_t iov_size,
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index 02d2e52..7f32550 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1850,8 +1850,7 @@ static ssize_t vmci_transport_stream_enqueue(
 	struct msghdr *msg,
 	size_t len)
 {
-	/* XXX: stripping const */
-	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, (struct iovec *)msg->msg_iter.iov, len, 0);
+	return vmci_qpair_enquev(vmci_trans(vsk)->qpair, msg, len, 0);
 }
 
 static s64 vmci_transport_stream_has_data(struct vsock_sock *vsk)
-- 
2.1.4
