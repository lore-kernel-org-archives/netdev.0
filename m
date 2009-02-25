From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 04/26] RDS: Transport code
Date: Tue, 24 Feb 2009 17:30:21 -0800
Message-ID: <1235525443-9007-5-git-send-email-andy.grover@oracle.com>
References: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, general@lists.openfabrics.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:27720 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495AbZBYBbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 20:31:03 -0500
In-Reply-To: <1235525443-9007-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS supports multiple transports. While this initial submission
only supports Infiniband transport, this abstraction allows others
to be added. We're working on an iWARP transport, and also see
UDP over DCB as another possibility.

This code handles transport registration.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/transport.c |  117 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 117 insertions(+), 0 deletions(-)
 create mode 100644 net/rds/transport.c

diff --git a/net/rds/transport.c b/net/rds/transport.c
new file mode 100644
index 0000000..767da61
--- /dev/null
+++ b/net/rds/transport.c
@@ -0,0 +1,117 @@
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
+static LIST_HEAD(rds_transports);
+static DECLARE_RWSEM(rds_trans_sem);
+
+int rds_trans_register(struct rds_transport *trans)
+{
+	BUG_ON(strlen(trans->t_name) + 1 > TRANSNAMSIZ);
+
+	down_write(&rds_trans_sem);
+
+	list_add_tail(&trans->t_item, &rds_transports);
+	printk(KERN_INFO "Registered RDS/%s transport\n", trans->t_name);
+
+	up_write(&rds_trans_sem);
+
+	return 0;
+}
+
+void rds_trans_unregister(struct rds_transport *trans)
+{
+	down_write(&rds_trans_sem);
+
+	list_del_init(&trans->t_item);
+	printk(KERN_INFO "Unregistered RDS/%s transport\n", trans->t_name);
+
+	up_write(&rds_trans_sem);
+}
+
+struct rds_transport *rds_trans_get_preferred(__be32 addr)
+{
+	struct rds_transport *trans;
+	struct rds_transport *ret = NULL;
+
+	if (IN_LOOPBACK(ntohl(addr)))
+		return &rds_loop_transport;
+
+	down_read(&rds_trans_sem);
+	list_for_each_entry(trans, &rds_transports, t_item) {
+		if (trans->laddr_check(addr) == 0) {
+			ret = trans;
+			break;
+		}
+	}
+	up_read(&rds_trans_sem);
+
+	return ret;
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
+	down_read(&rds_trans_sem);
+
+	list_for_each_entry(trans, &rds_transports, t_item) {
+		if (trans->stats_info_copy == NULL)
+			continue;
+
+		part = trans->stats_info_copy(iter, avail);
+		avail -= min(avail, part);
+		total += part;
+	}
+
+	up_read(&rds_trans_sem);
+
+	return total;
+}
+
-- 
1.5.6.3

