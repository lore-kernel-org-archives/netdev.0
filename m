From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 05/10] IB/core: Define big endian response for atomic operations
Date: Wed, 13 Aug 2014 14:39:06 +0300
Message-ID: <1407929951-16362-6-git-send-email-eli@mellanox.com>
References: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, rdma@vger.kernel.org, amirv@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: roland@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:63750 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbaHMLjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 07:39:46 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so7245508wiw.12
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 04:39:44 -0700 (PDT)
In-Reply-To: <1407929951-16362-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the option to define response for atomic operations in network order. This
is required by the subsequent patch adding support for Connect-IB extended
atomic operations. Connect-IB extended atomic operations provided masked
compare and swap and multifield fetch and add operations, which were introduced
in ConnectX devices with arguments of 8 bytes, with varying argument sizes.
enum ib_atomic_cap is extended to have big endian variants. The device
attributes struct defines three new fields:

log_atomic_arg_sizes - is a bit mask which encodes which argument sizes are
supported. A set bit at location n (zero based) means an argument of size 2 ^ n
is supported.

max_fa_bit_boundary - Max fetch and add bit boundary. Multi field fetch and add
operations use a bit mask that defines bit locations where carry bit is not
passed to the next higher order bit. So, if this field has the value 64, it
means that the max value subject to fetch and add is 64 bits which means no
carry from bit 63 to 64 or from bit 127 to 128 etc.

log_max_atomic_inline - atomic arguments can be inline in the WQE or be
referenced through a memory key. This value defines the max inline argument
size possible.

Extended atomic operations were first introduced here 5e80ba8ff0bd

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/infiniband/core/uverbs_cmd.c | 17 +++++++++++++++--
 include/rdma/ib_verbs.h              |  7 ++++++-
 include/uapi/rdma/ib_user_verbs.h    | 10 ++++++++++
 3 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 87059fd93649..5ce9848724e4 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -445,6 +445,8 @@ ssize_t ib_uverbs_query_device(struct ib_uverbs_file *file,
 
 	memset(&resp, 0, sizeof resp);
 	copy_query_dev_fields(file, &resp, &attr);
+	if (resp.atomic_cap > IB_ATOMIC_GLOB)
+		resp.atomic_cap = IB_ATOMIC_NONE;
 
 	if (copy_to_user((void __user *) (unsigned long) cmd.response,
 			 &resp, sizeof resp))
@@ -3186,7 +3188,7 @@ int ib_uverbs_ex_query_device(struct ib_uverbs_file *file,
 	if (err)
 		return err;
 
-	if (cmd.comp_mask)
+	if (cmd.comp_mask > IB_UVERBS_EX_QUERY_DEV_MAX_MASK)
 		return -EINVAL;
 
 	err = device->ex_query_device(device, &attr, uhw);
@@ -3197,8 +3199,19 @@ int ib_uverbs_ex_query_device(struct ib_uverbs_file *file,
 	copy_query_dev_fields(file,
 			      (struct ib_uverbs_query_device_resp *)(&resp),
 			      (struct ib_device_attr *)&attr);
-	resp.comp_mask = 0;
 
+	if (cmd.comp_mask & IB_UVERBS_EX_QUERY_DEV_MASKED_ATOMIC) {
+		resp.masked_atomic_cap = attr.masked_atomic_cap;
+		resp.log_atomic_arg_sizes = attr.log_atomic_arg_sizes;
+		resp.max_fa_bit_boundary = attr.max_fa_bit_boundary;
+		resp.log_max_atomic_inline = attr.log_max_atomic_inline;
+		resp.comp_mask |= IB_UVERBS_EX_QUERY_DEV_MASKED_ATOMIC;
+	} else {
+		resp.comp_mask = IB_ATOMIC_NONE;
+		resp.log_atomic_arg_sizes = 0;
+		resp.max_fa_bit_boundary = 0;
+		resp.log_max_atomic_inline = 0;
+	}
 	err = ib_copy_to_udata(ucore, &resp, sizeof(resp));
 	if (err)
 		return err;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ab6560fb1c9a..271f464b609b 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -140,7 +140,9 @@ enum ib_signature_guard_cap {
 enum ib_atomic_cap {
 	IB_ATOMIC_NONE,
 	IB_ATOMIC_HCA,
-	IB_ATOMIC_GLOB
+	IB_ATOMIC_GLOB,
+	IB_ATOMIC_HCA_REPLY_BE,
+	IB_ATOMIC_REPLY_BE_GLOB,
 };
 
 struct ib_device_attr {
@@ -186,6 +188,9 @@ struct ib_device_attr {
 	u8			local_ca_ack_delay;
 	int			sig_prot_cap;
 	int			sig_guard_cap;
+	u32			log_atomic_arg_sizes; /* bit-mask of supported sizes */
+	u32			max_fa_bit_boundary;
+	u32			log_max_atomic_inline;
 };
 
 enum ib_mtu {
diff --git a/include/uapi/rdma/ib_user_verbs.h b/include/uapi/rdma/ib_user_verbs.h
index e005b17b84c7..e076b3c87075 100644
--- a/include/uapi/rdma/ib_user_verbs.h
+++ b/include/uapi/rdma/ib_user_verbs.h
@@ -202,6 +202,12 @@ struct ib_uverbs_query_device_resp {
 	__u8  reserved[4];
 };
 
+/* the ...MAX_MASK value is calculated by the last shift value as below */
+enum {
+	IB_UVERBS_EX_QUERY_DEV_MASKED_ATOMIC	= 1 << 0,
+	IB_UVERBS_EX_QUERY_DEV_MAX_MASK		= (1 << (0 /*last shift value */ + 1)) - 1,
+};
+
 struct ib_uverbs_ex_query_device {
 	__u64 driver_data[0];
 	__u32 comp_mask;
@@ -251,6 +257,10 @@ struct ib_uverbs_ex_query_device_resp {
 	__u8  phys_port_cnt;
 	__u8  reserved[4];
 	__u32 comp_mask;
+	__u32 masked_atomic_cap;
+	__u32 log_atomic_arg_sizes; /* bit-mask of supported sizes */
+	__u32 max_fa_bit_boundary;
+	__u32 log_max_atomic_inline;
 };
 
 struct ib_uverbs_query_port {
-- 
1.9.3
