From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH RFC 2/5] vringfd base/offset
Date: Sat, 5 Apr 2008 22:04:28 +1000
Message-ID: <200804052204.28518.rusty@rustcorp.com.au>
References: <200804052202.09157.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Max Krasnyansky <maxk@qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48995 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536AbYDEMEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 08:04:51 -0400
In-Reply-To: <200804052202.09157.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It turns out the lguest (and possibly kvm) want the addresses in the
ring buffer to only cover a certain part of memory, and be offset.

It makes sense that this be an ioctl.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 08fb00b8acab Documentation/ioctl-number.txt
--- a/Documentation/ioctl-number.txt	Sat Apr 05 21:31:40 2008 +1100
+++ b/Documentation/ioctl-number.txt	Sat Apr 05 22:00:10 2008 +1100
@@ -183,6 +183,7 @@ 0xAC	00-1F	linux/raw.h
 0xAC	00-1F	linux/raw.h
 0xAD	00	Netfilter device	in development:
 					<mailto:rusty@rustcorp.com.au>	
+0xAE	00-01	linux/vring.h
 0xB0	all	RATIO devices		in development:
 					<mailto:vgo@ratio.de>
 0xB1	00-1F	PPPoX			<mailto:mostrows@styx.uwaterloo.ca>
diff -r 08fb00b8acab fs/vring.c
--- a/fs/vring.c	Sat Apr 05 21:31:40 2008 +1100
+++ b/fs/vring.c	Sat Apr 05 22:00:10 2008 +1100
@@ -38,6 +38,8 @@ struct vring_info
 	u16 mask;
 	u16 __user *last_used;
 	u16 last_avail;
+
+	unsigned long base, limit;
 
 	const struct vring_ops *ops;
 	void *ops_data;
@@ -120,10 +122,30 @@ static int vring_release(struct inode *i
 	return 0;
 }
 
+static int vring_ioctl(struct inode *in, struct file *filp,
+		       unsigned int cmd, unsigned long arg)
+{
+	struct vring_info *vr = filp->private_data;
+
+	switch (cmd) {
+	case VRINGSETBASE:
+		vr->base = arg;
+		break;
+	case VRINGSETLIMIT:
+		vr->limit = arg;
+		break;
+	default:
+		return -ENOTTY;
+	}
+
+	return 0;
+}
+
 static const struct file_operations vring_fops = {
 	.release	= vring_release,
 	.write		= vring_write,
 	.poll		= vring_poll,
+	.ioctl		= vring_ioctl,
 };
 
 asmlinkage long sys_vringfd(void __user *addr,
@@ -166,6 +188,8 @@ asmlinkage long sys_vringfd(void __user 
 	vr->mask = num_descs - 1;
 	vr->ops = NULL;
 	vr->used = NULL;
+	vr->limit = -1UL;
+	vr->base = 0;
 
 	err = get_user(vr->last_avail, &vr->ring.avail->idx);
 	if (err)
@@ -208,12 +232,15 @@ int vring_get_buffer(struct vring_info *
 		out_len = &dummy;
 
 	*in_len = *out_len = 0;
-	
-	if (unlikely(get_user(head, &vr->ring.avail->ring[head]) != 0))
+
+	if (unlikely(get_user(head, &vr->ring.avail->ring[vr->last_avail
+							  % vr->ring.num])))
 		return -EFAULT;
 
 	i = head;
 	do {
+		void __user *base;
+
 		if (unlikely(i >= vr->ring.num)) {
 			pr_debug("vring: bad index: %u\n", i);
 			return -EINVAL;
@@ -222,24 +249,38 @@ int vring_get_buffer(struct vring_info *
 		if (copy_from_user(&d, &vr->ring.desc[i], sizeof(d)) != 0)
 			return -EFAULT;
 
+		if (d.addr + d.len > vr->limit || (d.addr + d.len < d.addr)) {
+			pr_debug("vring: bad addr/len: %u@%p\n", 
+				 d.len, (void *)(unsigned long)d.addr);
+			return -EINVAL;
+		}
+
+		base = (void __user *)(unsigned long)d.addr + vr->base;
+
 		if (d.flags & VRING_DESC_F_WRITE) {
 			/* Check for length and iovec overflows */
-			if (!num_in)
+			if (!num_in) {
+				pr_debug("vring: writable desc %u in ring %p\n",
+				         i, vr->ring.desc);
 				return -EINVAL;
+			}
 			if (in == *num_in || *in_len + d.len < *in_len)
 				return -E2BIG;
 			in_iov[in].iov_len = d.len;
 			*in_len += d.len;
-			in_iov[in].iov_base = (void __user*)(long)d.addr;
+			in_iov[in].iov_base = base;
 			in++;
 		} else {
-			if (!num_out)
+			if (!num_out) {
+				pr_debug("vring: readable desc %u in ring %p\n",
+				         i, vr->ring.desc);
 				return -EINVAL;
+			}
 			if (out == *num_out || *out_len + d.len < *out_len)
 				return -E2BIG;
 			out_iov[out].iov_len = d.len;
 			*out_len += d.len;
-			out_iov[out].iov_base = (void __user*)(long)d.addr;
+			out_iov[out].iov_base = base;
 			out++;
 		}
 
diff -r 08fb00b8acab include/linux/vring.h
--- a/include/linux/vring.h	Sat Apr 05 21:31:40 2008 +1100
+++ b/include/linux/vring.h	Sat Apr 05 22:00:10 2008 +1100
@@ -18,7 +18,13 @@
  */
 #ifndef _LINUX_VRING_H
 #define _LINUX_VRING_H
+#include <linux/types.h>
 
+/* Ioctl defines, as in "ioctls are AEgly". */
+#define VRINGSETBASE	_IO(0xAE, 0)
+#define VRINGSETLIMIT	_IO(0xAE, 1)
+
+#ifdef __KERNEL__
 /* All members are optional */
 struct vring_ops
 {
@@ -51,4 +57,6 @@ void vring_used_buffer_atomic(struct vri
 void vring_used_buffer_atomic(struct vring_info *vr, int id, u32 len);
 
 void vring_wake(struct vring_info *vr);
+#endif /* __KERNEL__ */
+
 #endif /* _LINUX_VRING_H */
