From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/2] vhost: potential integer overflows
Date: Mon, 11 Oct 2010 19:22:57 +0200
Message-ID: <20101011172256.GF5851@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Juan Quintela <quintela@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48079 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab0JKRXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 13:23:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did an audit for potential integer overflows of values which get passed
to access_ok() and here are the results.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index dd3d6f7..c2aa12c 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -429,6 +429,14 @@ static int vq_access_ok(unsigned int num,
 			struct vring_avail __user *avail,
 			struct vring_used __user *used)
 {
+
+	if (num > UINT_MAX / sizeof *desc)
+		return 0;
+	if (num > UINT_MAX / sizeof *avail->ring - sizeof *avail)
+		return 0;
+	if (num > UINT_MAX / sizeof *used->ring - sizeof *used)
+		return 0;
+
 	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
 	       access_ok(VERIFY_READ, avail,
 			 sizeof *avail + num * sizeof *avail->ring) &&
@@ -447,6 +455,9 @@ int vhost_log_access_ok(struct vhost_dev *dev)
 /* Caller should have vq mutex and device mutex */
 static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
 {
+	if (vq->num > UINT_MAX / sizeof *vq->used->ring - sizeof *vq->used)
+		return 0;
+
 	return vq_memory_access_ok(log_base, vq->dev->memory,
 			    vhost_has_feature(vq->dev, VHOST_F_LOG_ALL)) &&
 		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
@@ -606,12 +617,17 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 			}
 
 			/* Also validate log access for used ring if enabled. */
-			if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
-			    !log_access_ok(vq->log_base, a.log_guest_addr,
+			if (a.flags & (0x1 << VHOST_VRING_F_LOG)) {
+				if (vq->num > UINT_MAX / sizeof *vq->used->ring - sizeof *vq->used) {
+					r = -EINVAL;
+					break;
+				}
+				if (!log_access_ok(vq->log_base, a.log_guest_addr,
 					   sizeof *vq->used +
 					   vq->num * sizeof *vq->used->ring)) {
-				r = -EINVAL;
-				break;
+					r = -EINVAL;
+					break;
+				}
 			}
 		}
 
