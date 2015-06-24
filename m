From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] vhost: add ioctl to query nregions upper limit
Date: Wed, 24 Jun 2015 15:49:27 +0200
Message-ID: <1435153753-2686-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Mammedov <imammedo@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Userspace currently simply tries to give vhost as many regions
as it happens to have, but you only have the mem table
when you have initialized a large part of VM, so graceful
failure is very hard to support.

The result is that userspace tends to fail catastrophically.

Instead, add a new ioctl so userspace can find out how much kernel
supports, up front. This returns a positive value that we commit to.

Also, document our contract with legacy userspace: when running on an
old kernel, you get -1 and you can assume at least 64 slots.  Since 0
value's left unused, let's make that mean that the current userspace
behaviour (trial and error) is required, just in case we want it back.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Igor Mammedov <imammedo@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
---
 include/uapi/linux/vhost.h | 17 ++++++++++++++++-
 drivers/vhost/vhost.c      |  5 +++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index ab373191..f71fa6d 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -80,7 +80,7 @@ struct vhost_memory {
  * Allows subsequent call to VHOST_OWNER_SET to succeed. */
 #define VHOST_RESET_OWNER _IO(VHOST_VIRTIO, 0x02)
 
-/* Set up/modify memory layout */
+/* Set up/modify memory layout: see also VHOST_GET_MEM_MAX_NREGIONS below. */
 #define VHOST_SET_MEM_TABLE	_IOW(VHOST_VIRTIO, 0x03, struct vhost_memory)
 
 /* Write logging setup. */
@@ -127,6 +127,21 @@ struct vhost_memory {
 /* Set eventfd to signal an error */
 #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
 
+/* Query upper limit on nregions in VHOST_SET_MEM_TABLE arguments.
+ * Returns:
+ * 	0 < value <= MAX_INT - gives the upper limit, higher values will fail
+ * 	0 - there's no static limit: try and see if it works
+ * 	-1 - on failure
+ */
+#define VHOST_GET_MEM_MAX_NREGIONS   _IO(VHOST_VIRTIO, 0x23)
+
+/* Returned by VHOST_GET_MEM_MAX_NREGIONS to mean there's no static limit:
+ * try and it'll work if you are lucky. */
+#define VHOST_MEM_MAX_NREGIONS_NONE 0
+/* We support at least as many nregions in VHOST_SET_MEM_TABLE:
+ * for use on legacy kernels without VHOST_GET_MEM_MAX_NREGIONS support. */
+#define VHOST_MEM_MAX_NREGIONS_DEFAULT 64
+
 /* VHOST_NET specific defines */
 
 /* Attach virtio net ring to a raw socket, or tap device.
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 9e8e004..3b68f9d 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -917,6 +917,11 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
 	long r;
 	int i, fd;
 
+	if (ioctl == VHOST_GET_MEM_MAX_NREGIONS) {
+		r = VHOST_MEMORY_MAX_NREGIONS;
+		goto done;
+	}
+
 	/* If you are not the owner, you can become one */
 	if (ioctl == VHOST_SET_OWNER) {
 		r = vhost_dev_set_owner(d);
-- 
MST
