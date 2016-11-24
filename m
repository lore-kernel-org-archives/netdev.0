From: Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH 2/3] vringh: kill off ACCESS_ONCE()
Date: Thu, 24 Nov 2016 10:25:13 +0000
Message-ID: <1479983114-17190-3-git-send-email-mark.rutland@arm.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
Cc: dave@stgolabs.net, dbueso@suse.de, dvyukov@google.com,
        jasowang@redhat.com, kvm@vger.kernel.org, mark.rutland@arm.com,
        mst@redhat.com, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:47014 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936175AbcKXKZk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 05:25:40 -0500
In-Reply-To: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite living under drivers/ vringh.c is also used as part of the userspace
virtio tools. Before we can kill off the ACCESS_ONCE()definition in the tools,
we must convert vringh.c to use {READ,WRITE}_ONCE().

This patch does so, along with the required include of <linux/compiler.h> for
the relevant definitions. The userspace tools provide their own definitions in
their own <linux/compiler.h>.

Signed-off-by: Mark Rutland <mark.rutland@arm.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: kvm@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org
---
 drivers/vhost/vringh.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index 3bb02c6..bb8971f 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -3,6 +3,7 @@
  *
  * Since these may be in userspace, we use (inline) accessors.
  */
+#include <linux/compiler.h>
 #include <linux/module.h>
 #include <linux/vringh.h>
 #include <linux/virtio_ring.h>
@@ -820,13 +821,13 @@ EXPORT_SYMBOL(vringh_need_notify_user);
 static inline int getu16_kern(const struct vringh *vrh,
 			      u16 *val, const __virtio16 *p)
 {
-	*val = vringh16_to_cpu(vrh, ACCESS_ONCE(*p));
+	*val = vringh16_to_cpu(vrh, READ_ONCE(*p));
 	return 0;
 }
 
 static inline int putu16_kern(const struct vringh *vrh, __virtio16 *p, u16 val)
 {
-	ACCESS_ONCE(*p) = cpu_to_vringh16(vrh, val);
+	WRITE_ONCE(*p, cpu_to_vringh16(vrh, val));
 	return 0;
 }
 
-- 
2.7.4
