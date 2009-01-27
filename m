From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 04/21] RDS: Transport code
Date: Mon, 26 Jan 2009 18:17:41 -0800
Message-ID: <1233022678-9259-5-git-send-email-andy.grover@oracle.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:47399 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbZA0CSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 21:18:18 -0500
In-Reply-To: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS supports multiple transports. While this initial submission
only supports Infiniband transport, this abstraction allows others
to be added. We're working on an iWARP transport, and also see
UDP over DCB as another possibility.

This code handles transport registration.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 drivers/infiniband/ulp/rds/transport.c |  134 ++++++++++++++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/rds/transport.c

diff --git a/drivers/infiniband/ulp/rds/transport.c b/drivers/infiniband/ulp/rds/transport.c
new file mode 100644
index 0000000..e78f8b3
--- /dev/null
+++ b/drivers/infiniband/ulp/rds/transport.c
@@ -0,0 +1,134 @@
+/*
+ * Copyright (c) 2006 Oracle.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/in.h>
+
+#include "rds.h"
+#include "loop.h"
+
+static LIST_HEAD(transports);
+static DECLARE_RWSEM(trans_sem);
+
+int rds_trans_register(struct rds_transport *trans)
+{
+	BUG_ON(strlen(trans->t_name) + 1 >
+	       sizeof(((struct rds_info_connection *)0)->transport));
+
+	down_write(&trans_sem);
+
+	list_add_tail(&trans->t_item, &transports);
+	printk(KERN_INFO "Registered RDS/%s transport\n", trans->t_name);
+
+	up_write(&trans_sem);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rds_trans_register);
+
+void rds_trans_unregister(struct rds_transport *trans)
+{
+	down_write(&trans_sem);
+
+	list_del_init(&trans->t_item);
+	printk(KERN_INFO "Unregistered RDS/%s transport\n", trans->t_name);
+
+	up_write(&trans_sem);
+}
+EXPORT_SYMBOL_GPL(rds_trans_unregister);
+
+struct rds_transport *rds_trans_get_preferred(__be32 addr)
+{
+	struct rds_transport *trans;
+	struct rds_transport *ret = NULL;
+
+        if (IN_LOOPBACK(ntohl(addr)))
+                return &rds_loop_transport;
+
+	down_read(&trans_sem);
+	list_for_each_entry(trans, &transports, t_item) {
+		if (trans->laddr_check(addr) == 0) {
+			ret = trans;
+			break;
+		}
+	}
+	up_read(&trans_sem);
+
+	return ret;
+}
+
+/* TODO remove this, only called in rds_exit, by which point we know
+   all the transports will have been unloaded */
+void rds_trans_stop_listening(void)
+{
+	struct rds_transport *trans;
+
+	down_read(&trans_sem);
+
+	list_for_each_entry(trans, &transports, t_item)
+		trans->listen_stop();
+
+	up_read(&trans_sem);
+}
+
+/*
+ * This returns the number of stats entries in the snapshot and only
+ * copies them using the iter if there is enough space for them.  The
+ * caller passes in the global stats so that we can size and copy while
+ * holding the lock.
+ */
+unsigned int rds_trans_stats_info_copy(struct rds_info_iterator *iter,
+				       unsigned int avail)
+
+{
+	struct rds_transport *trans;
+	unsigned int total = 0;
+	unsigned int part;
+
+	rds_info_iter_unmap(iter);
+	down_read(&trans_sem);
+
+	list_for_each_entry(trans, &transports, t_item) {
+		if (trans->stats_info_copy == NULL)
+			continue;
+
+		part = trans->stats_info_copy(iter, avail);
+		avail -= min(avail, part);
+		total += part;
+	}
+
+	up_read(&trans_sem);
+
+	return total;
+}
+
-- 
1.5.6.3

