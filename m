From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/3] vringh: initial virtio 1.0 support
Date: Mon, 15 Dec 2014 23:14:05 +0200
Message-ID: <1418678019-31629-3-git-send-email-mst@redhat.com>
References: <1418678019-31629-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1418678019-31629-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/vringh.h |  33 ++++++++++++++
 drivers/vhost/vringh.c | 121 ++++++++++++++++++++++++++++++-------------------
 2 files changed, 107 insertions(+), 47 deletions(-)

diff --git a/include/linux/vringh.h b/include/linux/vringh.h
index f696dd0..a3fa537 100644
--- a/include/linux/vringh.h
+++ b/include/linux/vringh.h
@@ -24,12 +24,16 @@
 #ifndef _LINUX_VRINGH_H
 #define _LINUX_VRINGH_H
 #include <uapi/linux/virtio_ring.h>
+#include <linux/virtio_byteorder.h>
 #include <linux/uio.h>
 #include <linux/slab.h>
 #include <asm/barrier.h>
 
 /* virtio_ring with information needed for host access. */
 struct vringh {
+	/* Everything is little endian */
+	bool little_endian;
+
 	/* Guest publishes used event idx (note: we always do). */
 	bool event_indices;
 
@@ -222,4 +226,33 @@ static inline void vringh_notify(struct vringh *vrh)
 		vrh->notify(vrh);
 }
 
+static inline u16 vringh16_to_cpu(const struct vringh *vrh, __virtio16 val)
+{
+	return __virtio16_to_cpu(vrh->little_endian, val);
+}
+
+static inline __virtio16 cpu_to_vringh16(const struct vringh *vrh, u16 val)
+{
+	return __cpu_to_virtio16(vrh->little_endian, val);
+}
+
+static inline u32 vringh32_to_cpu(const struct vringh *vrh, __virtio32 val)
+{
+	return __virtio32_to_cpu(vrh->little_endian, val);
+}
+
+static inline __virtio32 cpu_to_vringh32(const struct vringh *vrh, u32 val)
+{
+	return __cpu_to_virtio32(vrh->little_endian, val);
+}
+
+static inline u64 vringh64_to_cpu(const struct vringh *vrh, __virtio64 val)
+{
+	return __virtio64_to_cpu(vrh->little_endian, val);
+}
+
+static inline __virtio64 cpu_to_vringh64(const struct vringh *vrh, u64 val)
+{
+	return __cpu_to_virtio64(vrh->little_endian, val);
+}
 #endif /* _LINUX_VRINGH_H */
diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index ac3fe27..3bb02c6 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -11,6 +11,7 @@
 #include <linux/uaccess.h>
 #include <linux/slab.h>
 #include <linux/export.h>
+#include <uapi/linux/virtio_config.h>
 
 static __printf(1,2) __cold void vringh_bad(const char *fmt, ...)
 {
@@ -28,13 +29,14 @@ static __printf(1,2) __cold void vringh_bad(const char *fmt, ...)
 
 /* Returns vring->num if empty, -ve on error. */
 static inline int __vringh_get_head(const struct vringh *vrh,
-				    int (*getu16)(u16 *val, const u16 *p),
+				    int (*getu16)(const struct vringh *vrh,
+						  u16 *val, const __virtio16 *p),
 				    u16 *last_avail_idx)
 {
 	u16 avail_idx, i, head;
 	int err;
 
-	err = getu16(&avail_idx, &vrh->vring.avail->idx);
+	err = getu16(vrh, &avail_idx, &vrh->vring.avail->idx);
 	if (err) {
 		vringh_bad("Failed to access avail idx at %p",
 			   &vrh->vring.avail->idx);
@@ -49,7 +51,7 @@ static inline int __vringh_get_head(const struct vringh *vrh,
 
 	i = *last_avail_idx & (vrh->vring.num - 1);
 
-	err = getu16(&head, &vrh->vring.avail->ring[i]);
+	err = getu16(vrh, &head, &vrh->vring.avail->ring[i]);
 	if (err) {
 		vringh_bad("Failed to read head: idx %d address %p",
 			   *last_avail_idx, &vrh->vring.avail->ring[i]);
@@ -144,28 +146,32 @@ static inline bool no_range_check(struct vringh *vrh, u64 addr, size_t *len,
 }
 
 /* No reason for this code to be inline. */
-static int move_to_indirect(int *up_next, u16 *i, void *addr,
+static int move_to_indirect(const struct vringh *vrh,
+			    int *up_next, u16 *i, void *addr,
 			    const struct vring_desc *desc,
 			    struct vring_desc **descs, int *desc_max)
 {
+	u32 len;
+
 	/* Indirect tables can't have indirect. */
 	if (*up_next != -1) {
 		vringh_bad("Multilevel indirect %u->%u", *up_next, *i);
 		return -EINVAL;
 	}
 
-	if (unlikely(desc->len % sizeof(struct vring_desc))) {
+	len = vringh32_to_cpu(vrh, desc->len);
+	if (unlikely(len % sizeof(struct vring_desc))) {
 		vringh_bad("Strange indirect len %u", desc->len);
 		return -EINVAL;
 	}
 
 	/* We will check this when we follow it! */
-	if (desc->flags & VRING_DESC_F_NEXT)
-		*up_next = desc->next;
+	if (desc->flags & cpu_to_vringh16(vrh, VRING_DESC_F_NEXT))
+		*up_next = vringh16_to_cpu(vrh, desc->next);
 	else
 		*up_next = -2;
 	*descs = addr;
-	*desc_max = desc->len / sizeof(struct vring_desc);
+	*desc_max = len / sizeof(struct vring_desc);
 
 	/* Now, start at the first indirect. */
 	*i = 0;
@@ -287,22 +293,25 @@ __vringh_iov(struct vringh *vrh, u16 i,
 		if (unlikely(err))
 			goto fail;
 
-		if (unlikely(desc.flags & VRING_DESC_F_INDIRECT)) {
+		if (unlikely(desc.flags &
+			     cpu_to_vringh16(vrh, VRING_DESC_F_INDIRECT))) {
+			u64 a = vringh64_to_cpu(vrh, desc.addr);
+
 			/* Make sure it's OK, and get offset. */
-			len = desc.len;
-			if (!rcheck(vrh, desc.addr, &len, &range, getrange)) {
+			len = vringh32_to_cpu(vrh, desc.len);
+			if (!rcheck(vrh, a, &len, &range, getrange)) {
 				err = -EINVAL;
 				goto fail;
 			}
 
-			if (unlikely(len != desc.len)) {
+			if (unlikely(len != vringh32_to_cpu(vrh, desc.len))) {
 				slow = true;
 				/* We need to save this range to use offset */
 				slowrange = range;
 			}
 
-			addr = (void *)(long)(desc.addr + range.offset);
-			err = move_to_indirect(&up_next, &i, addr, &desc,
+			addr = (void *)(long)(a + range.offset);
+			err = move_to_indirect(vrh, &up_next, &i, addr, &desc,
 					       &descs, &desc_max);
 			if (err)
 				goto fail;
@@ -315,7 +324,7 @@ __vringh_iov(struct vringh *vrh, u16 i,
 			goto fail;
 		}
 
-		if (desc.flags & VRING_DESC_F_WRITE)
+		if (desc.flags & cpu_to_vringh16(vrh, VRING_DESC_F_WRITE))
 			iov = wiov;
 		else {
 			iov = riov;
@@ -336,12 +345,14 @@ __vringh_iov(struct vringh *vrh, u16 i,
 
 	again:
 		/* Make sure it's OK, and get offset. */
-		len = desc.len;
-		if (!rcheck(vrh, desc.addr, &len, &range, getrange)) {
+		len = vringh32_to_cpu(vrh, desc.len);
+		if (!rcheck(vrh, vringh64_to_cpu(vrh, desc.addr), &len, &range,
+			    getrange)) {
 			err = -EINVAL;
 			goto fail;
 		}
-		addr = (void *)(unsigned long)(desc.addr + range.offset);
+		addr = (void *)(unsigned long)(vringh64_to_cpu(vrh, desc.addr) +
+					       range.offset);
 
 		if (unlikely(iov->used == (iov->max_num & ~VRINGH_IOV_ALLOCATED))) {
 			err = resize_iovec(iov, gfp);
@@ -353,14 +364,16 @@ __vringh_iov(struct vringh *vrh, u16 i,
 		iov->iov[iov->used].iov_len = len;
 		iov->used++;
 
-		if (unlikely(len != desc.len)) {
-			desc.len -= len;
-			desc.addr += len;
+		if (unlikely(len != vringh32_to_cpu(vrh, desc.len))) {
+			desc.len = cpu_to_vringh32(vrh,
+				   vringh32_to_cpu(vrh, desc.len) - len);
+			desc.addr = cpu_to_vringh64(vrh,
+				    vringh64_to_cpu(vrh, desc.addr) + len);
 			goto again;
 		}
 
-		if (desc.flags & VRING_DESC_F_NEXT) {
-			i = desc.next;
+		if (desc.flags & cpu_to_vringh16(vrh, VRING_DESC_F_NEXT)) {
+			i = vringh16_to_cpu(vrh, desc.next);
 		} else {
 			/* Just in case we need to finish traversing above. */
 			if (unlikely(up_next > 0)) {
@@ -387,7 +400,8 @@ fail:
 static inline int __vringh_complete(struct vringh *vrh,
 				    const struct vring_used_elem *used,
 				    unsigned int num_used,
-				    int (*putu16)(u16 *p, u16 val),
+				    int (*putu16)(const struct vringh *vrh,
+						  __virtio16 *p, u16 val),
 				    int (*putused)(struct vring_used_elem *dst,
 						   const struct vring_used_elem
 						   *src, unsigned num))
@@ -420,7 +434,7 @@ static inline int __vringh_complete(struct vringh *vrh,
 	/* Make sure buffer is written before we update index. */
 	virtio_wmb(vrh->weak_barriers);
 
-	err = putu16(&vrh->vring.used->idx, used_idx + num_used);
+	err = putu16(vrh, &vrh->vring.used->idx, used_idx + num_used);
 	if (err) {
 		vringh_bad("Failed to update used index at %p",
 			   &vrh->vring.used->idx);
@@ -433,7 +447,9 @@ static inline int __vringh_complete(struct vringh *vrh,
 
 
 static inline int __vringh_need_notify(struct vringh *vrh,
-				       int (*getu16)(u16 *val, const u16 *p))
+				       int (*getu16)(const struct vringh *vrh,
+						     u16 *val,
+						     const __virtio16 *p))
 {
 	bool notify;
 	u16 used_event;
@@ -447,7 +463,7 @@ static inline int __vringh_need_notify(struct vringh *vrh,
 	/* Old-style, without event indices. */
 	if (!vrh->event_indices) {
 		u16 flags;
-		err = getu16(&flags, &vrh->vring.avail->flags);
+		err = getu16(vrh, &flags, &vrh->vring.avail->flags);
 		if (err) {
 			vringh_bad("Failed to get flags at %p",
 				   &vrh->vring.avail->flags);
@@ -457,7 +473,7 @@ static inline int __vringh_need_notify(struct vringh *vrh,
 	}
 
 	/* Modern: we know when other side wants to know. */
-	err = getu16(&used_event, &vring_used_event(&vrh->vring));
+	err = getu16(vrh, &used_event, &vring_used_event(&vrh->vring));
 	if (err) {
 		vringh_bad("Failed to get used event idx at %p",
 			   &vring_used_event(&vrh->vring));
@@ -478,20 +494,22 @@ static inline int __vringh_need_notify(struct vringh *vrh,
 }
 
 static inline bool __vringh_notify_enable(struct vringh *vrh,
-					  int (*getu16)(u16 *val, const u16 *p),
-					  int (*putu16)(u16 *p, u16 val))
+					  int (*getu16)(const struct vringh *vrh,
+							u16 *val, const __virtio16 *p),
+					  int (*putu16)(const struct vringh *vrh,
+							__virtio16 *p, u16 val))
 {
 	u16 avail;
 
 	if (!vrh->event_indices) {
 		/* Old-school; update flags. */
-		if (putu16(&vrh->vring.used->flags, 0) != 0) {
+		if (putu16(vrh, &vrh->vring.used->flags, 0) != 0) {
 			vringh_bad("Clearing used flags %p",
 				   &vrh->vring.used->flags);
 			return true;
 		}
 	} else {
-		if (putu16(&vring_avail_event(&vrh->vring),
+		if (putu16(vrh, &vring_avail_event(&vrh->vring),
 			   vrh->last_avail_idx) != 0) {
 			vringh_bad("Updating avail event index %p",
 				   &vring_avail_event(&vrh->vring));
@@ -503,7 +521,7 @@ static inline bool __vringh_notify_enable(struct vringh *vrh,
 	 * sure it's written, then check again. */
 	virtio_mb(vrh->weak_barriers);
 
-	if (getu16(&avail, &vrh->vring.avail->idx) != 0) {
+	if (getu16(vrh, &avail, &vrh->vring.avail->idx) != 0) {
 		vringh_bad("Failed to check avail idx at %p",
 			   &vrh->vring.avail->idx);
 		return true;
@@ -516,11 +534,13 @@ static inline bool __vringh_notify_enable(struct vringh *vrh,
 }
 
 static inline void __vringh_notify_disable(struct vringh *vrh,
-					   int (*putu16)(u16 *p, u16 val))
+					   int (*putu16)(const struct vringh *vrh,
+							 __virtio16 *p, u16 val))
 {
 	if (!vrh->event_indices) {
 		/* Old-school; update flags. */
-		if (putu16(&vrh->vring.used->flags, VRING_USED_F_NO_NOTIFY)) {
+		if (putu16(vrh, &vrh->vring.used->flags,
+			   VRING_USED_F_NO_NOTIFY)) {
 			vringh_bad("Setting used flags %p",
 				   &vrh->vring.used->flags);
 		}
@@ -528,14 +548,18 @@ static inline void __vringh_notify_disable(struct vringh *vrh,
 }
 
 /* Userspace access helpers: in this case, addresses are really userspace. */
-static inline int getu16_user(u16 *val, const u16 *p)
+static inline int getu16_user(const struct vringh *vrh, u16 *val, const __virtio16 *p)
 {
-	return get_user(*val, (__force u16 __user *)p);
+	__virtio16 v = 0;
+	int rc = get_user(v, (__force __virtio16 __user *)p);
+	*val = vringh16_to_cpu(vrh, v);
+	return rc;
 }
 
-static inline int putu16_user(u16 *p, u16 val)
+static inline int putu16_user(const struct vringh *vrh, __virtio16 *p, u16 val)
 {
-	return put_user(val, (__force u16 __user *)p);
+	__virtio16 v = cpu_to_vringh16(vrh, val);
+	return put_user(v, (__force __virtio16 __user *)p);
 }
 
 static inline int copydesc_user(void *dst, const void *src, size_t len)
@@ -589,6 +613,7 @@ int vringh_init_user(struct vringh *vrh, u64 features,
 		return -EINVAL;
 	}
 
+	vrh->little_endian = (features & (1ULL << VIRTIO_F_VERSION_1));
 	vrh->event_indices = (features & (1 << VIRTIO_RING_F_EVENT_IDX));
 	vrh->weak_barriers = weak_barriers;
 	vrh->completed = 0;
@@ -729,8 +754,8 @@ int vringh_complete_user(struct vringh *vrh, u16 head, u32 len)
 {
 	struct vring_used_elem used;
 
-	used.id = head;
-	used.len = len;
+	used.id = cpu_to_vringh32(vrh, head);
+	used.len = cpu_to_vringh32(vrh, len);
 	return __vringh_complete(vrh, &used, 1, putu16_user, putused_user);
 }
 EXPORT_SYMBOL(vringh_complete_user);
@@ -792,15 +817,16 @@ int vringh_need_notify_user(struct vringh *vrh)
 EXPORT_SYMBOL(vringh_need_notify_user);
 
 /* Kernelspace access helpers. */
-static inline int getu16_kern(u16 *val, const u16 *p)
+static inline int getu16_kern(const struct vringh *vrh,
+			      u16 *val, const __virtio16 *p)
 {
-	*val = ACCESS_ONCE(*p);
+	*val = vringh16_to_cpu(vrh, ACCESS_ONCE(*p));
 	return 0;
 }
 
-static inline int putu16_kern(u16 *p, u16 val)
+static inline int putu16_kern(const struct vringh *vrh, __virtio16 *p, u16 val)
 {
-	ACCESS_ONCE(*p) = val;
+	ACCESS_ONCE(*p) = cpu_to_vringh16(vrh, val);
 	return 0;
 }
 
@@ -848,6 +874,7 @@ int vringh_init_kern(struct vringh *vrh, u64 features,
 		return -EINVAL;
 	}
 
+	vrh->little_endian = (features & (1ULL << VIRTIO_F_VERSION_1));
 	vrh->event_indices = (features & (1 << VIRTIO_RING_F_EVENT_IDX));
 	vrh->weak_barriers = weak_barriers;
 	vrh->completed = 0;
@@ -962,8 +989,8 @@ int vringh_complete_kern(struct vringh *vrh, u16 head, u32 len)
 {
 	struct vring_used_elem used;
 
-	used.id = head;
-	used.len = len;
+	used.id = cpu_to_vringh32(vrh, head);
+	used.len = cpu_to_vringh32(vrh, len);
 
 	return __vringh_complete(vrh, &used, 1, putu16_kern, putused_kern);
 }
-- 
MST
