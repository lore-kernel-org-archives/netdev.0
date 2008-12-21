From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 09/29] wimax: debugfs controls
Date: Sat, 20 Dec 2008 16:57:40 -0800
Message-ID: <58ee10bb7cc18e211d3290817f6012a9dac373b9.1229820957.git.inaky@linux.intel.com>
References: <cover.1229820956.git.inaky@linux.intel.com>
Cc: greg@kroah.com, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1229820956.git.inaky@linux.intel.com>
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

Expose knobs to control the stack's debug output.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/debugfs.c |   90 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 90 insertions(+), 0 deletions(-)
 create mode 100644 net/wimax/debugfs.c

diff --git a/net/wimax/debugfs.c b/net/wimax/debugfs.c
new file mode 100644
index 0000000..87cf443
--- /dev/null
+++ b/net/wimax/debugfs.c
@@ -0,0 +1,90 @@
+/*
+ * Linux WiMAX
+ * Debugfs support
+ *
+ *
+ * Copyright (C) 2005-2006 Intel Corporation <linux-wimax@intel.com>
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
+ */
+#include <linux/debugfs.h>
+#include <linux/wimax.h>
+#include "wimax-internal.h"
+
+#define D_SUBMODULE debugfs
+#include "debug-levels.h"
+
+
+/* Debug framework control of debug levels */
+struct d_level D_LEVEL[] = {
+	D_SUBMODULE_DEFINE(debugfs),
+	D_SUBMODULE_DEFINE(id_table),
+	D_SUBMODULE_DEFINE(op_msg),
+	D_SUBMODULE_DEFINE(op_reset),
+	D_SUBMODULE_DEFINE(op_rfkill),
+	D_SUBMODULE_DEFINE(stack),
+};
+size_t D_LEVEL_SIZE = ARRAY_SIZE(D_LEVEL);
+
+#define __debugfs_register(prefix, name, parent)			\
+do {									\
+	result = d_level_register_debugfs(prefix, name, parent);	\
+	if (result < 0)							\
+		goto error;						\
+} while (0)
+
+
+int wimax_debugfs_add(struct wimax_dev *wimax_dev)
+{
+	int result;
+	struct net_device *net_dev = wimax_dev->net_dev;
+	struct device *dev = net_dev->dev.parent;
+	struct dentry *dentry;
+	char buf[128];
+
+	snprintf(buf, sizeof(buf), "wimax:%s", net_dev->name);
+	dentry = debugfs_create_dir(buf, NULL);
+	result = PTR_ERR(dentry);
+	if (IS_ERR(dentry)) {
+		if (result == -ENODEV)
+			result = 0;	/* No debugfs support */
+		else
+			dev_err(dev, "Can't create debugfs dentry: %d\n",
+				result);
+		goto out;
+	}
+	wimax_dev->debugfs_dentry = dentry;
+	__debugfs_register("wimax_dl_", debugfs, dentry);
+	__debugfs_register("wimax_dl_", id_table, dentry);
+	__debugfs_register("wimax_dl_", op_msg, dentry);
+	__debugfs_register("wimax_dl_", op_reset, dentry);
+	__debugfs_register("wimax_dl_", op_rfkill, dentry);
+	__debugfs_register("wimax_dl_", stack, dentry);
+	result = 0;
+out:
+	return result;
+
+error:
+	debugfs_remove_recursive(wimax_dev->debugfs_dentry);
+	return result;
+}
+
+void wimax_debugfs_rm(struct wimax_dev *wimax_dev)
+{
+	debugfs_remove_recursive(wimax_dev->debugfs_dentry);
+}
+
+
-- 
1.5.6.5
