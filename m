From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 08/39] wimax: Mappping of generic netlink family IDs to net
	devices
Date: Tue, 25 Nov 2008 23:39:04 -0800
Message-ID: <ece2e8510d0a29bc6c1e447a561b2901a4ebf312.1227684996.git.inaky@linux.intel.com>
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

Low overhead method to map generic netlink family IDs to the WiMAX
device attached to them that optimizes for the case where most systems
have a single WiMAX device, or at most, a very low number of WiMAX
adaptors.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/id-table.c |  141 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 141 insertions(+), 0 deletions(-)
 create mode 100644 net/wimax/id-table.c

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
new file mode 100644
index 0000000..b6b060e
--- /dev/null
+++ b/net/wimax/id-table.c
@@ -0,0 +1,141 @@
+/*
+ * Linux WiMAX
+ * Mappping of generic netlink family IDs to net devices
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
+ *
+ *
+ * We assign a single generic netlink family ID to each device (to
+ * simplify lookup).
+ *
+ * We need a way to map family ID to a wimax_dev pointer.
+ *
+ * The idea is to use a very simple lookup. Using a netlink attribute
+ * with (for example) the interface name implies a heavier search over
+ * all the network devices; seemed kind of a waste given that we know
+ * we are looking for a WiMAX device and that most systems will have
+ * just a single WiMAX adapter.
+ *
+ * We put all the WiMAX devices in the system in a linked list and
+ * match the generic link family ID against the list.
+ *
+ * By using a linked list, the case of a single adapter in the system
+ * becomes (almost) no overhead, while still working for many more. If
+ * it ever goes beyond two, I'll be surprised.
+ */
+#include <linux/device.h>
+#include <net/genetlink.h>
+#include <linux/netdevice.h>
+#include <linux/list.h>
+#include <linux/wimax.h>
+#include "wimax-internal.h"
+
+
+#define D_SUBMODULE id_table
+#include "debug-levels.h"
+
+
+static DEFINE_SPINLOCK(wimax_id_table_lock);
+static struct list_head wimax_id_table = LIST_HEAD_INIT(wimax_id_table);
+
+
+/*
+ * wimax_id_table_add - add a gennetlink familiy ID / wimax_dev mapping
+ *
+ * @wimax_dev: WiMAX device descriptor to associate to the Generic
+ *     Netlink family ID.
+ *
+ * Look for an empty spot in the ID table; if none found, double the
+ * table's size and get the first spot.
+ */
+void wimax_id_table_add(struct wimax_dev *wimax_dev)
+{
+	d_fnstart(3, NULL, "(wimax_dev %p)\n", wimax_dev);
+	spin_lock(&wimax_id_table_lock);
+	list_add(&wimax_dev->id_table_node, &wimax_id_table);
+	spin_unlock(&wimax_id_table_lock);
+	d_fnend(3, NULL, "(wimax_dev %p)\n", wimax_dev);
+}
+
+
+/*
+ * wimax_get_netdev_by_info - lookup a wimax_dev from the gennetlink info
+ *
+ * The generic netlink family ID has been filled out in the
+ * nlmsghdr->nlmsg_type field, so we pull it from there, look it up in
+ * the mapping table and reference the wimax_dev.
+ *
+ * When done, the reference should be dropped with
+ * 'dev_put(wimax_dev->net_dev)'.
+ */
+struct wimax_dev *wimax_dev_get_by_genl_info(struct genl_info *info)
+{
+	struct wimax_dev *wimax_dev;
+	int id = info->nlhdr->nlmsg_type;
+
+	d_fnstart(3, NULL, "(info %p [id %d])\n", info, id);
+	spin_lock(&wimax_id_table_lock);
+	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
+		if (wimax_dev->gnl_family.id == id) {
+			dev_hold(wimax_dev->net_dev);
+			goto out_unlock;
+		}
+	}
+	d_printf(1, NULL, "wimax: no device associated to ID %d\n", id);
+	wimax_dev = NULL;
+out_unlock:
+	spin_unlock(&wimax_id_table_lock);
+	d_fnend(3, NULL, "(info %p) = %p\n", info, wimax_dev);
+	return wimax_dev;
+}
+
+
+/*
+ * wimax_id_table_rm - Remove a gennetlink familiy ID / wimax_dev mapping
+ *
+ * @id: family ID to remove from the table
+ */
+void wimax_id_table_rm(struct wimax_dev *wimax_dev)
+{
+	spin_lock(&wimax_id_table_lock);
+	list_del_init(&wimax_dev->id_table_node);
+	spin_unlock(&wimax_id_table_lock);
+}
+
+
+/*
+ * Release the gennetlink family id / mapping table
+ *
+ * On debug, verify that the table is empty upon removal.
+ */
+void wimax_id_table_release(void)
+{
+#ifndef CONFIG_BUG
+	return;
+#endif
+	struct wimax_dev *wimax_dev;
+
+	spin_lock(&wimax_id_table_lock);
+	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
+		printk(KERN_ERR "BUG: %s wimax_dev %p id %u not cleared\n",
+		       __func__, wimax_dev, wimax_dev->gnl_family.id);
+		WARN_ON(1);
+	}
+	spin_unlock(&wimax_id_table_lock);
+}
-- 
1.5.6.5
