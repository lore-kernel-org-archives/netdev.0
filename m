From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 02/14] QLogic VNIC: Netpath - abstraction of
	connection to EVIC/VEx
Date: Tue, 10 Jun 2008 17:03:15 -0400
Message-ID: <20080610210315.11186.97777.stgit@dale>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>

This patch implements the netpath layer of QLogic VNIC. Netpath is an 
abstraction of a connection to EVIC. It primarily includes the 
implementation which maintains the timers to monitor the status of
the connection to EVIC/VEx.

Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c |  109 +++++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h |   80 +++++++++++++++++
 2 files changed, 189 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h

diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c
new file mode 100644
index 0000000..273031c
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.c
@@ -0,0 +1,109 @@
+/*
+ * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
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
+ */
+
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+
+#include "vnic_util.h"
+#include "vnic_main.h"
+#include "vnic_viport.h"
+#include "vnic_netpath.h"
+
+static void vnic_npevent_timeout(unsigned long data)
+{
+	struct netpath *netpath = (struct netpath *)data;
+
+	if (netpath->second_bias)
+		vnic_npevent_queue_evt(netpath, VNIC_SECNP_TIMEREXPIRED);
+	else
+		vnic_npevent_queue_evt(netpath, VNIC_PRINP_TIMEREXPIRED);
+}
+
+void netpath_timer(struct netpath *netpath, int timeout)
+{
+	if (netpath->timer_state == NETPATH_TS_ACTIVE)
+		del_timer_sync(&netpath->timer);
+	if (timeout) {
+		init_timer(&netpath->timer);
+		netpath->timer_state = NETPATH_TS_ACTIVE;
+		netpath->timer.expires = jiffies + timeout;
+		netpath->timer.data = (unsigned long)netpath;
+		netpath->timer.function = vnic_npevent_timeout;
+		add_timer(&netpath->timer);
+	} else
+		vnic_npevent_timeout((unsigned long)netpath);
+}
+
+void netpath_timer_stop(struct netpath *netpath)
+{
+	if (netpath->timer_state != NETPATH_TS_ACTIVE)
+		return;
+	del_timer_sync(&netpath->timer);
+	if (netpath->second_bias)
+		vnic_npevent_dequeue_evt(netpath, VNIC_SECNP_TIMEREXPIRED);
+	else
+		vnic_npevent_dequeue_evt(netpath, VNIC_PRINP_TIMEREXPIRED);
+
+	netpath->timer_state = NETPATH_TS_IDLE;
+}
+
+void netpath_free(struct netpath *netpath)
+{
+	vnic_cleanup_path_files(netpath);
+	if (!netpath->viport)
+		return;
+	viport_free(netpath->viport);
+	netpath->viport = NULL;
+}
+
+void netpath_init(struct netpath *netpath, struct vnic *vnic,
+		  int second_bias)
+{
+	netpath->parent = vnic;
+	netpath->carrier = 0;
+	netpath->viport = NULL;
+	netpath->second_bias = second_bias;
+	netpath->timer_state = NETPATH_TS_IDLE;
+	init_timer(&netpath->timer);
+}
+
+const char *netpath_to_string(struct vnic *vnic, struct netpath *netpath)
+{
+	if (!netpath)
+		return "NULL";
+	else if (netpath == &vnic->primary_path)
+		return "PRIMARY";
+	else if (netpath == &vnic->secondary_path)
+		return "SECONDARY";
+	else
+		return "UNKNOWN";
+}
diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h b/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h
new file mode 100644
index 0000000..0aa3384
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_netpath.h
@@ -0,0 +1,80 @@
+/*
+ * Copyright (c) 2006 QLogic, Inc.  All rights reserved.
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
+ */
+
+#ifndef VNIC_NETPATH_H_INCLUDED
+#define VNIC_NETPATH_H_INCLUDED
+
+#include <linux/spinlock.h>
+
+#include "vnic_sys.h"
+
+struct viport;
+struct vnic;
+
+enum netpath_ts {
+	NETPATH_TS_IDLE		= 0,
+	NETPATH_TS_ACTIVE	= 1,
+	NETPATH_TS_EXPIRED	= 2
+};
+
+struct netpath {
+	int			carrier;
+	struct vnic		*parent;
+	struct viport		*viport;
+	size_t			path_idx;
+	unsigned long		connect_time;
+	int			second_bias;
+	u8			is_primary_path;
+	u8 			delay_reconnect;
+	struct timer_list	timer;
+	enum netpath_ts		timer_state;
+	struct dev_info		dev_info;
+};
+
+void netpath_init(struct netpath *netpath, struct vnic *vnic,
+		  int second_bias);
+void netpath_free(struct netpath *netpath);
+void vnic_cleanup_path_files(struct netpath *path);
+
+void netpath_timer(struct netpath *netpath, int timeout);
+void netpath_timer_stop(struct netpath *netpath);
+
+const char *netpath_to_string(struct vnic *vnic, struct netpath *netpath);
+
+#define netpath_get_hw_addr(netpath, address)		\
+	viport_get_hw_addr((netpath)->viport, address)
+#define netpath_is_connected(netpath)			\
+	(netpath->state == NETPATH_CONNECTED)
+#define netpath_can_tx_csum(netpath)			\
+	viport_can_tx_csum(netpath->viport)
+
+#endif	/* VNIC_NETPATH_H_INCLUDED */
