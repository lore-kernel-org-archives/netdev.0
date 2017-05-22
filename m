From: Joe Perches <joe@perches.com>
Subject: [PATCH] vhost: Coalesce vq_err formats, pr_fmt misuse, add missing newlines
Date: Mon, 22 May 2017 03:33:43 -0700
Message-ID: <0e8f84aec009831d34ccb2b4ed27364e78b07e02.1495449147.git.joe@perches.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vhost logging uses of vq_err has a few defects and style inconsistencies.

o pr_debug already uses pr_fmt so its use in vq_err is defective
  however no #defines of pr_fmt exist in this code so no actual
  defects exist
o vq_err uses need terminating newlines so add the missing ones
o Coalesce formats and realign arguments

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/vhost/net.c   | 17 ++++++-------
 drivers/vhost/scsi.c  | 17 ++++++-------
 drivers/vhost/test.c  |  4 +--
 drivers/vhost/vhost.c | 70 +++++++++++++++++++++++----------------------------
 drivers/vhost/vhost.h | 11 ++++----
 5 files changed, 54 insertions(+), 65 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index e3d7ea1288c6..7c8c013381e1 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -501,8 +501,8 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		}
 		if (in) {
-			vq_err(vq, "Unexpected descriptor format for TX: "
-			       "out %d, int %d\n", out, in);
+			vq_err(vq, "Unexpected descriptor format for TX: out %d, int %d\n",
+			       out, in);
 			break;
 		}
 		/* Skip header. TODO: support TSO. */
@@ -511,8 +511,7 @@ static void handle_tx(struct vhost_net *net)
 		iov_iter_advance(&msg.msg_iter, hdr_size);
 		/* Sanity check */
 		if (!msg_data_left(&msg)) {
-			vq_err(vq, "Unexpected header len for TX: "
-			       "%zd expected %zd\n",
+			vq_err(vq, "Unexpected header len for TX: %zd expected %zd\n",
 			       len, hdr_size);
 			break;
 		}
@@ -689,8 +688,8 @@ static int get_rx_bufs(struct vhost_virtqueue *vq,
 			goto err;
 		}
 		if (unlikely(out || in <= 0)) {
-			vq_err(vq, "unexpected descriptor format for RX: "
-				"out %d, in %d\n", out, in);
+			vq_err(vq, "unexpected descriptor format for RX: out %d, in %d\n",
+			       out, in);
 			r = -EINVAL;
 			goto err;
 		}
@@ -822,8 +821,8 @@ static void handle_rx(struct vhost_net *net)
 		if (unlikely(vhost_hlen)) {
 			if (copy_to_iter(&hdr, sizeof(hdr),
 					 &fixup) != sizeof(hdr)) {
-				vq_err(vq, "Unable to write vnet_hdr "
-				       "at addr %p\n", vq->iov->iov_base);
+				vq_err(vq, "Unable to write vnet_hdr at addr %p\n",
+				       vq->iov->iov_base);
 				goto out;
 			}
 		} else {
@@ -838,7 +837,7 @@ static void handle_rx(struct vhost_net *net)
 		if (likely(mergeable) &&
 		    copy_to_iter(&num_buffers, sizeof num_buffers,
 				 &fixup) != sizeof num_buffers) {
-			vq_err(vq, "Failed num_buffers write");
+			vq_err(vq, "Failed num_buffers write\n");
 			vhost_discard_vq_desc(vq, headcount);
 			goto out;
 		}
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index fd6c8b66f06f..c0d3746d5ff3 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -473,7 +473,7 @@ vhost_scsi_do_evt_work(struct vhost_scsi *vs, struct vhost_scsi_evt *evt)
 
 	if ((vq->iov[out].iov_len != sizeof(struct virtio_scsi_event))) {
 		vq_err(vq, "Expecting virtio_scsi_event, got %zu bytes\n",
-				vq->iov[out].iov_len);
+		       vq->iov[out].iov_len);
 		vs->vs_events_missed = true;
 		return;
 	}
@@ -885,8 +885,8 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 		 * errors back to the guest.
 		 */
 		if (unlikely(vq->iov[out].iov_len < rsp_size)) {
-			vq_err(vq, "Expecting at least virtio_scsi_cmd_resp"
-				" size, got %zu bytes\n", vq->iov[out].iov_len);
+			vq_err(vq, "Expecting at least virtio_scsi_cmd_resp size, got %zu bytes\n",
+			       vq->iov[out].iov_len);
 			break;
 		}
 		/*
@@ -981,16 +981,14 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 		if (t10_pi) {
 			if (v_req_pi.pi_bytesout) {
 				if (data_direction != DMA_TO_DEVICE) {
-					vq_err(vq, "Received non zero pi_bytesout,"
-						" but wrong data_direction\n");
+					vq_err(vq, "Received non zero pi_bytesout, but wrong data_direction\n");
 					vhost_scsi_send_bad_target(vs, vq, head, out);
 					continue;
 				}
 				prot_bytes = vhost32_to_cpu(vq, v_req_pi.pi_bytesout);
 			} else if (v_req_pi.pi_bytesin) {
 				if (data_direction != DMA_FROM_DEVICE) {
-					vq_err(vq, "Received non zero pi_bytesin,"
-						" but wrong data_direction\n");
+					vq_err(vq, "Received non zero pi_bytesin, but wrong data_direction\n");
 					vhost_scsi_send_bad_target(vs, vq, head, out);
 					continue;
 				}
@@ -1026,9 +1024,8 @@ vhost_scsi_handle_vq(struct vhost_scsi *vs, struct vhost_virtqueue *vq)
 		 * TODO what if cdb was too small for varlen cdb header?
 		 */
 		if (unlikely(scsi_command_size(cdb) > VHOST_SCSI_MAX_CDB_SIZE)) {
-			vq_err(vq, "Received SCSI CDB with command_size: %d that"
-				" exceeds SCSI_MAX_VARLEN_CDB_SIZE: %d\n",
-				scsi_command_size(cdb), VHOST_SCSI_MAX_CDB_SIZE);
+			vq_err(vq, "Received SCSI CDB with command_size: %d that exceeds SCSI_MAX_VARLEN_CDB_SIZE: %d\n",
+			       scsi_command_size(cdb), VHOST_SCSI_MAX_CDB_SIZE);
 			vhost_scsi_send_bad_target(vs, vq, head, out);
 			continue;
 		}
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 3cc98c07dcd3..a48e9747505d 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -69,8 +69,8 @@ static void handle_vq(struct vhost_test *n)
 			break;
 		}
 		if (in) {
-			vq_err(vq, "Unexpected descriptor format for TX: "
-			       "out %d, int %d\n", out, in);
+			vq_err(vq, "Unexpected descriptor format for TX: out %d, int %d\n",
+			       out, in);
 			break;
 		}
 		len = iov_length(vq->iov, out);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 042030e5a035..6730735d31c7 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -802,9 +802,8 @@ static int vhost_copy_from_user(struct vhost_virtqueue *vq, void *to,
 				     ARRAY_SIZE(vq->iotlb_iov),
 				     VHOST_ACCESS_RO);
 		if (ret < 0) {
-			vq_err(vq, "IOTLB translation failure: uaddr "
-			       "%p size 0x%llx\n", from,
-			       (unsigned long long) size);
+			vq_err(vq, "IOTLB translation failure: uaddr %p size 0x%llx\n",
+			       from, (unsigned long long)size);
 			goto out;
 		}
 		iov_iter_init(&f, READ, vq->iotlb_iov, ret, size);
@@ -827,16 +826,14 @@ static void __user *__vhost_get_user_slow(struct vhost_virtqueue *vq,
 			     ARRAY_SIZE(vq->iotlb_iov),
 			     VHOST_ACCESS_RO);
 	if (ret < 0) {
-		vq_err(vq, "IOTLB translation failure: uaddr "
-			"%p size 0x%llx\n", addr,
-			(unsigned long long) size);
+		vq_err(vq, "IOTLB translation failure: uaddr %p size 0x%llx\n",
+		       addr, (unsigned long long)size);
 		return NULL;
 	}
 
 	if (ret != 1 || vq->iotlb_iov[0].iov_len != size) {
-		vq_err(vq, "Non atomic userspace memory access: uaddr "
-			"%p size 0x%llx\n", addr,
-			(unsigned long long) size);
+		vq_err(vq, "Non atomic userspace memory access: uaddr %p size 0x%llx\n",
+		       addr, (unsigned long long)size);
 		return NULL;
 	}
 
@@ -1807,8 +1804,7 @@ int vhost_vq_init_access(struct vhost_virtqueue *vq)
 	}
 	r = vhost_get_used(vq, last_used_idx, &vq->used->idx);
 	if (r) {
-		vq_err(vq, "Can't access used idx at %p\n",
-		       &vq->used->idx);
+		vq_err(vq, "Can't access used idx at %p\n", &vq->used->idx);
 		goto err;
 	}
 	vq->last_used_idx = vhost16_to_cpu(vq, last_used_idx);
@@ -1901,10 +1897,8 @@ static int get_indirect(struct vhost_virtqueue *vq,
 
 	/* Sanity check */
 	if (unlikely(len % sizeof desc)) {
-		vq_err(vq, "Invalid length in indirect descriptor: "
-		       "len 0x%llx not multiple of 0x%zx\n",
-		       (unsigned long long)len,
-		       sizeof desc);
+		vq_err(vq, "Invalid length in indirect descriptor: len 0x%llx not multiple of 0x%zx\n",
+		       (unsigned long long)len, sizeof(desc));
 		return -EINVAL;
 	}
 
@@ -1912,7 +1906,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 			     UIO_MAXIOV, VHOST_ACCESS_RO);
 	if (unlikely(ret < 0)) {
 		if (ret != -EAGAIN)
-			vq_err(vq, "Translation failure %d in indirect.\n", ret);
+			vq_err(vq, "Translation failure %d in indirect\n", ret);
 		return ret;
 	}
 	iov_iter_init(&from, READ, vq->indirect, ret, len);
@@ -1933,8 +1927,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 	do {
 		unsigned iov_count = *in_num + *out_num;
 		if (unlikely(++found > count)) {
-			vq_err(vq, "Loop detected: last one at %u "
-			       "indirect size %u\n",
+			vq_err(vq, "Loop detected: last one at %u indirect size %u\n",
 			       i, count);
 			return -EINVAL;
 		}
@@ -1960,7 +1953,7 @@ static int get_indirect(struct vhost_virtqueue *vq,
 		if (unlikely(ret < 0)) {
 			if (ret != -EAGAIN)
 				vq_err(vq, "Translation failure %d indirect idx %d\n",
-					ret, i);
+				       ret, i);
 			return ret;
 		}
 		/* If this is an input descriptor, increment that count. */
@@ -1975,8 +1968,8 @@ static int get_indirect(struct vhost_virtqueue *vq,
 			/* If it's an output descriptor, they're all supposed
 			 * to come before any input descriptors. */
 			if (unlikely(*in_num)) {
-				vq_err(vq, "Indirect descriptor "
-				       "has out after in: idx %d\n", i);
+				vq_err(vq, "Indirect descriptor has out after in: idx %d\n",
+				       i);
 				return -EINVAL;
 			}
 			*out_num += ret;
@@ -2011,14 +2004,14 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 	if (vq->avail_idx == vq->last_avail_idx) {
 		if (unlikely(vhost_get_avail(vq, avail_idx, &vq->avail->idx))) {
 			vq_err(vq, "Failed to access avail idx at %p\n",
-				&vq->avail->idx);
+			       &vq->avail->idx);
 			return -EFAULT;
 		}
 		vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
 
 		if (unlikely((u16)(vq->avail_idx - last_avail_idx) > vq->num)) {
-			vq_err(vq, "Guest moved used index from %u to %u",
-				last_avail_idx, vq->avail_idx);
+			vq_err(vq, "Guest moved used index from %u to %u\n",
+			       last_avail_idx, vq->avail_idx);
 			return -EFAULT;
 		}
 
@@ -2048,7 +2041,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 
 	/* If their number is silly, that's an error. */
 	if (unlikely(head >= vq->num)) {
-		vq_err(vq, "Guest says index %u > %u is available",
+		vq_err(vq, "Guest says index %u > %u is available\n",
 		       head, vq->num);
 		return -EINVAL;
 	}
@@ -2062,13 +2055,12 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 	do {
 		unsigned iov_count = *in_num + *out_num;
 		if (unlikely(i >= vq->num)) {
-			vq_err(vq, "Desc index is %u > %u, head = %u",
+			vq_err(vq, "Desc index is %u > %u, head = %u\n",
 			       i, vq->num, head);
 			return -EINVAL;
 		}
 		if (unlikely(++found > vq->num)) {
-			vq_err(vq, "Loop detected: last one at %u "
-			       "vq size %u head %u\n",
+			vq_err(vq, "Loop detected: last one at %u vq size %u head %u\n",
 			       i, vq->num, head);
 			return -EINVAL;
 		}
@@ -2085,8 +2077,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 					   log, log_num, &desc);
 			if (unlikely(ret < 0)) {
 				if (ret != -EAGAIN)
-					vq_err(vq, "Failure detected "
-						"in indirect descriptor at idx %d\n", i);
+					vq_err(vq, "Failure detected in indirect descriptor at idx %d\n",
+					       i);
 				return ret;
 			}
 			continue;
@@ -2102,7 +2094,7 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 		if (unlikely(ret < 0)) {
 			if (ret != -EAGAIN)
 				vq_err(vq, "Translation failure %d descriptor idx %d\n",
-					ret, i);
+				       ret, i);
 			return ret;
 		}
 		if (access == VHOST_ACCESS_WO) {
@@ -2118,8 +2110,8 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
 			/* If it's an output descriptor, they're all supposed
 			 * to come before any input descriptors. */
 			if (unlikely(*in_num)) {
-				vq_err(vq, "Descriptor has out after in: "
-				       "idx %d\n", i);
+				vq_err(vq, "Descriptor has out after in: idx %d\n",
+				       i);
 				return -EINVAL;
 			}
 			*out_num += ret;
@@ -2168,15 +2160,15 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
 	used = vq->used->ring + start;
 	if (count == 1) {
 		if (vhost_put_user(vq, heads[0].id, &used->id)) {
-			vq_err(vq, "Failed to write used id");
+			vq_err(vq, "Failed to write used id\n");
 			return -EFAULT;
 		}
 		if (vhost_put_user(vq, heads[0].len, &used->len)) {
-			vq_err(vq, "Failed to write used len");
+			vq_err(vq, "Failed to write used len\n");
 			return -EFAULT;
 		}
 	} else if (vhost_copy_to_user(vq, used, heads, count * sizeof *used)) {
-		vq_err(vq, "Failed to write used");
+		vq_err(vq, "Failed to write used\n");
 		return -EFAULT;
 	}
 	if (unlikely(vq->log_used)) {
@@ -2221,7 +2213,7 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
 	smp_wmb();
 	if (vhost_put_user(vq, cpu_to_vhost16(vq, vq->last_used_idx),
 			   &vq->used->idx)) {
-		vq_err(vq, "Failed to increment used idx");
+		vq_err(vq, "Failed to increment used idx\n");
 		return -EFAULT;
 	}
 	if (unlikely(vq->log_used)) {
@@ -2253,7 +2245,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 		 * interrupts. */
 		smp_mb();
 		if (vhost_get_avail(vq, flags, &vq->avail->flags)) {
-			vq_err(vq, "Failed to get flags");
+			vq_err(vq, "Failed to get flags\n");
 			return true;
 		}
 		return !(flags & cpu_to_vhost16(vq, VRING_AVAIL_F_NO_INTERRUPT));
@@ -2280,7 +2272,7 @@ static bool vhost_notify(struct vhost_dev *dev, struct vhost_virtqueue *vq)
 	smp_mb();
 
 	if (vhost_get_avail(vq, event, vhost_used_event(vq))) {
-		vq_err(vq, "Failed to get used event idx");
+		vq_err(vq, "Failed to get used event idx\n");
 		return true;
 	}
 	vq->last_used_event = vhost16_to_cpu(vq, event);
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index f55671d53f28..18bcfc70459a 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -227,11 +227,12 @@ ssize_t vhost_chr_write_iter(struct vhost_dev *dev,
 			     struct iov_iter *from);
 int vhost_init_device_iotlb(struct vhost_dev *d, bool enabled);
 
-#define vq_err(vq, fmt, ...) do {                                  \
-		pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
-		if ((vq)->error_ctx)                               \
-				eventfd_signal((vq)->error_ctx, 1);\
-	} while (0)
+#define vq_err(vq, fmt, ...)						\
+do {									\
+	pr_debug(fmt, ##__VA_ARGS__);					\
+	if ((vq)->error_ctx)						\
+		eventfd_signal((vq)->error_ctx, 1);			\
+} while (0)
 
 enum {
 	VHOST_FEATURES = (1ULL << VIRTIO_F_NOTIFY_ON_EMPTY) |
-- 
2.10.0.rc2.1.g053435c
