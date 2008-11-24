From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 04/39] wimax: internal API for the kernel space WiMAX stack
Date: Mon, 24 Nov 2008 13:50:27 -0800
Message-ID: <b590df397e6895c2d031bfdb1e4d39a42fbcac13.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:57411 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753153AbYKXVvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:15 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file contains declarations and definitions used by the different
submodules of the stack.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/wimax-internal.h |   92 ++++++++++++++++++++++++++++++++++++
 1 files changed, 92 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/wimax/wimax-internal.h

diff --git a/drivers/net/wimax/wimax-internal.h b/drivers/net/wimax/wimax-internal.h
new file mode 100644
index 0000000..4290787
--- /dev/null
+++ b/drivers/net/wimax/wimax-internal.h
@@ -0,0 +1,92 @@
+/*
+ * Linux WiMAX
+ * Internal API for kernel space WiMAX stack
+ *
+ *
+ * Copyright (C) 2007 Intel Corporation <linux-wimax@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ *
+ *
+ * This header file is for declarations and definitions internal to
+ * the WiMAX stack. For public APIs and documentation, see
+ * include/net/wimax.h and include/linux/wimax.h.
+ */
+
+#ifndef __WIMAX_INTERNAL_H__
+#define __WIMAX_INTERNAL_H__
+#ifdef __KERNEL__
+
+#include <linux/device.h>
+#include <net/wimax.h>
+
+
+/*
+ * Decide if a (locked) device is ready for use
+ *
+ * Before using the device structure, it must be locked
+ * (wimax_dev->mutex). As well, most operations need to call this
+ * function to check if the state is the right one.
+ *
+ * An error value will be returned if the state is not the right
+ * one. In that case, the caller should not attempt to use the device
+ * and just unlock it. 
+ */
+static inline __must_check
+int wimax_dev_is_ready(struct wimax_dev *wimax_dev)
+{
+	if (wimax_dev->state == __WIMAX_ST_NULL)
+		return -EINVAL;	/* Device is not even registered! */
+	if (wimax_dev->state == WIMAX_ST_DOWN)
+		return -ENOMEDIUM;
+	if (wimax_dev->state == __WIMAX_ST_QUIESCING)
+		return -ESHUTDOWN;
+	return 0;
+}
+
+
+static inline
+void __wimax_state_set(struct wimax_dev *wimax_dev, enum wimax_st state)
+{
+	wimax_dev->state = state;
+}
+extern void __wimax_state_change(struct wimax_dev *, enum wimax_st);
+
+
+extern void wimax_id_table_add(struct wimax_dev *);
+extern struct wimax_dev *wimax_dev_get_by_genl_info(struct genl_info *);
+extern void wimax_id_table_rm(struct wimax_dev *);
+extern void wimax_id_table_release(void);
+
+extern int wimax_gnl_send_rp_result(struct wimax_dev *, struct genl_info *,
+				    ssize_t);
+extern void __wimax_pipe_rm(struct wimax_dev *, struct wimax_pipe *);
+
+extern int wimax_rfkill_add(struct wimax_dev *);
+extern void wimax_rfkill_rm(struct wimax_dev *);
+
+/*
+ * The concept of a pipe -- we encapsulate it because we want to
+ * detach the usage of it from the implementation, and thus it serves
+ * just as a handle.
+ */ 
+struct wimax_pipe {
+	struct list_head list_node;
+	struct genl_multicast_group mcg;
+};
+
+#endif /* #ifdef __KERNEL__ */
+#endif /* #ifndef __WIMAX_INTERNAL_H__ */
-- 
1.5.6.5

