From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 12/39] wimax: API call to reset a WiMAX device
Date: Tue, 25 Nov 2008 23:39:08 -0800
Message-ID: <a4ef4add8974b5a4f7a24e0a583dca807b6e30cb.1227684996.git.inaky@linux.intel.com>
References: <cover.1227684995.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1227684995.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

Provides wimax_reset() for the kernel to reset a wimax device as
needed.

Exports wimax_reset() over generic netlink to user space.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-reset.c |  134 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)
 create mode 100644 net/wimax/op-reset.c

diff --git a/net/wimax/op-reset.c b/net/wimax/op-reset.c
new file mode 100644
index 0000000..5ec64f6
--- /dev/null
+++ b/net/wimax/op-reset.c
@@ -0,0 +1,134 @@
+/*
+ * Linux WiMAX
+ * Implement and export a method for resetting a WiMAX device
+ *
+ *
+ * Copyright (C) 2008 Intel Corporation <linux-wimax@intel.com>
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
+ * This implements a simple synchronous call to reset a WiMAX device.
+ *
+ * Resets aim at being warm, keeping the device handles active;
+ * however, when that fails, it falls back to a cold reset (that will
+ * disconnect and reconnect the device).
+ */
+
+#include <net/wimax.h>
+#include <net/genetlink.h>
+#include <linux/wimax.h>
+#include <linux/security.h>
+#include "wimax-internal.h"
+
+#define D_SUBMODULE op_reset
+#include "debug-levels.h"
+
+
+/**
+ * wimax_reset - Reset a WiMAX device
+ *
+ * @wimax_dev: WiMAX device descriptor
+ *
+ * Returns:
+ *
+ * %0 if ok and a warm reset was done (the device still exists in
+ * the system).
+ *
+ * -%ENODEV if a cold/bus reset had to be done (device has
+ * disconnected and reconnected, so current handle is not valid
+ * any more).
+ *
+ * -%EINVAL if the device is not even registered.
+ *
+ * Any other negative error code shall be considered as
+ * non-recoverable.
+ *
+ * Description:
+ *
+ * Called when wanting to reset the device for any reason. Device is
+ * taken back to power on status.
+ *
+ * This call blocks; on succesful return, the device has completed the
+ * reset process and is ready to operate.
+ */
+int wimax_reset(struct wimax_dev *wimax_dev)
+{
+	int result = -EINVAL;
+	struct device *dev = wimax_dev_to_dev(wimax_dev);
+
+	might_sleep();
+	d_fnstart(3, dev, "(wimax_dev %p)\n", wimax_dev);
+	mutex_lock(&wimax_dev->mutex);
+	if (wimax_dev->state >= WIMAX_ST_DOWN)
+		/* Dev is at least registered */
+		result = wimax_dev->op_reset(wimax_dev);
+	mutex_unlock(&wimax_dev->mutex);
+	d_fnend(3, dev, "(wimax_dev %p) = %d\n", wimax_dev, result);
+	return result;
+}
+EXPORT_SYMBOL(wimax_reset);
+
+
+/*
+ * Exporting to user space over generic netlink
+ *
+ * Parse the reset command from user space, return error code.
+ *
+ * No attributes.
+ */
+static
+int wimax_gnl_doit_reset(struct sk_buff *skb, struct genl_info *info)
+{
+	int result, result2;
+	struct wimax_dev *wimax_dev;
+	struct device *dev;
+	struct nlmsghdr *nlh;
+
+	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
+	result = -EPERM;
+	if (security_netlink_recv(skb, CAP_NET_ADMIN))
+		goto error_perm;
+	result = -ENODEV;
+	wimax_dev = wimax_dev_get_by_genl_info(info);
+	if (wimax_dev == NULL)
+		goto error_no_wimax_dev;
+	dev = wimax_dev_to_dev(wimax_dev);
+
+	nlh = (void *) skb->data;
+
+	/* Execute the operation and send the result back to user space */
+	result = wimax_reset(wimax_dev);
+	result2 = wimax_gnl_send_rp_result(wimax_dev, info, result);
+	if (result2 < 0)
+		dev_err(dev, "WIMAX_GNL_RESET: can't send result %d to "
+			"userspace: %d\n", result, result2);
+	result = 0;
+	dev_put(wimax_dev->net_dev);
+error_no_wimax_dev:
+error_perm:
+	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
+	return result;
+}
+
+
+struct genl_ops wimax_gnl_reset = {
+	.cmd = WIMAX_GNL_OP_RESET,
+	.flags = 0,
+	.policy = NULL,
+	.doit = wimax_gnl_doit_reset,
+	.dumpit = NULL,
+};
-- 
1.5.6.5
