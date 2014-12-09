From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 19/25] vmci: propagate msghdr all way down to __qp_memcpy_from_queue()
Date: Tue,  9 Dec 2014 22:50:32 +0000
Message-ID: <1418165438-2205-19-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

... and switch it to memcpy_to_msg()

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/misc/vmw_vmci/vmci_queue_pair.c | 17 +++++++++--------
 include/linux/vmw_vmci_api.h            |  5 +++--
 net/vmw_vsock/vmci_transport.c          |  4 ++--
 3 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index 1b7b303..7aaaf51 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -27,6 +27,7 @@
 #include <linux/uio.h>
 #include <linux/wait.h>
 #include <linux/vmalloc.h>
+#include <linux/skbuff.h>
 
 #include "vmci_handle_array.h"
 #include "vmci_queue_pair.h"
@@ -429,11 +430,11 @@ static int __qp_memcpy_from_queue(void *dest,
 			to_copy = size - bytes_copied;
 
 		if (is_iovec) {
-			struct iovec *iov = (struct iovec *)dest;
+			struct msghdr *msg = dest;
 			int err;
 
 			/* The iovec will track bytes_copied internally. */
-			err = memcpy_toiovec(iov, (u8 *)va + page_offset,
+			err = memcpy_to_msg(msg, (u8 *)va + page_offset,
 					     to_copy);
 			if (err != 0) {
 				if (kernel_if->host)
@@ -3264,13 +3265,13 @@ EXPORT_SYMBOL_GPL(vmci_qpair_enquev);
  * of bytes dequeued or < 0 on error.
  */
 ssize_t vmci_qpair_dequev(struct vmci_qp *qpair,
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
@@ -3279,7 +3280,7 @@ ssize_t vmci_qpair_dequev(struct vmci_qp *qpair,
 		result = qp_dequeue_locked(qpair->produce_q,
 					   qpair->consume_q,
 					   qpair->consume_q_size,
-					   iov, iov_size,
+					   msg, iov_size,
 					   qp_memcpy_from_queue_iov,
 					   true);
 
@@ -3308,13 +3309,13 @@ EXPORT_SYMBOL_GPL(vmci_qpair_dequev);
  * of bytes peeked or < 0 on error.
  */
 ssize_t vmci_qpair_peekv(struct vmci_qp *qpair,
-			 void *iov,
+			 struct msghdr *msg,
 			 size_t iov_size,
 			 int buf_type)
 {
 	ssize_t result;
 
-	if (!qpair || !iov)
+	if (!qpair)
 		return VMCI_ERROR_INVALID_ARGS;
 
 	qp_lock(qpair);
@@ -3323,7 +3324,7 @@ ssize_t vmci_qpair_peekv(struct vmci_qp *qpair,
 		result = qp_dequeue_locked(qpair->produce_q,
 					   qpair->consume_q,
 					   qpair->consume_q_size,
-					   iov, iov_size,
+					   msg, iov_size,
 					   qp_memcpy_from_queue_iov,
 					   false);
 
diff --git a/include/linux/vmw_vmci_api.h b/include/linux/vmw_vmci_api.h
index 023430e..5691f75 100644
--- a/include/linux/vmw_vmci_api.h
+++ b/include/linux/vmw_vmci_api.h
@@ -24,6 +24,7 @@
 #define VMCI_KERNEL_API_VERSION_2 2
 #define VMCI_KERNEL_API_VERSION   VMCI_KERNEL_API_VERSION_2
 
+struct msghdr;
 typedef void (vmci_device_shutdown_fn) (void *device_registration,
 					void *user_data);
 
@@ -75,8 +76,8 @@ ssize_t vmci_qpair_peek(struct vmci_qp *qpair, void *buf, size_t buf_size,
 ssize_t vmci_qpair_enquev(struct vmci_qp *qpair,
 			  void *iov, size_t iov_size, int mode);
 ssize_t vmci_qpair_dequev(struct vmci_qp *qpair,
-			  void *iov, size_t iov_size, int mode);
-ssize_t vmci_qpair_peekv(struct vmci_qp *qpair, void *iov, size_t iov_size,
+			  struct msghdr *msg, size_t iov_size, int mode);
+ssize_t vmci_qpair_peekv(struct vmci_qp *qpair, struct msghdr *msg, size_t iov_size,
 			 int mode);
 
 #endif /* !__VMW_VMCI_API_H__ */
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
index c1c0389..20a0ba3 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -1840,9 +1840,9 @@ static ssize_t vmci_transport_stream_dequeue(
 	int flags)
 {
 	if (flags & MSG_PEEK)
-		return vmci_qpair_peekv(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
+		return vmci_qpair_peekv(vmci_trans(vsk)->qpair, msg, len, 0);
 	else
-		return vmci_qpair_dequev(vmci_trans(vsk)->qpair, msg->msg_iov, len, 0);
+		return vmci_qpair_dequev(vmci_trans(vsk)->qpair, msg, len, 0);
 }
 
 static ssize_t vmci_transport_stream_enqueue(
-- 
2.1.3
