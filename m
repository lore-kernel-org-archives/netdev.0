From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH 09/13] QLogic VNIC: IB Multicast for Ethernet
	broadcast/multicast
Date: Wed, 30 Apr 2008 22:50:25 +0530
Message-ID: <20080430172025.31725.97795.stgit@localhost.localdomain>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poornima.kamath@qlogic.com, amar.mudrankit@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080430171028.31725.86190.stgit@localhost.localdomain>
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

From: Usha Srinivasan <usha.srinivasan@qlogic.com>

Implementation of ethernet broadcasting and multicasting for QLogic
VNIC interface by making use of underlying IB multicasting. 

Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c |  332 +++++++++++++++++++++
 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h |   76 +++++
 2 files changed, 408 insertions(+), 0 deletions(-)
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c
 create mode 100644 drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h

diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c b/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c
new file mode 100644
index 0000000..044d447
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.c
@@ -0,0 +1,332 @@
+/*
+ * Copyright (c) 2008 QLogic, Inc.  All rights reserved.
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
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/jiffies.h>
+#include <rdma/ib_sa.h>
+#include "vnic_viport.h"
+#include "vnic_netpath.h"
+#include "vnic_main.h"
+#include "vnic_config.h"
+#include "vnic_control.h"
+#include "vnic_util.h"
+#include "vnic_ib.h"
+
+#define control_ifcfg_name(p)\
+   ((p)->parent->parent->parent->config->name)
+
+#define SET_MCAST_STATE_INVALID \
+do { \
+	viport->mc_info.state = MCAST_STATE_INVALID; \
+	viport->mc_info.mc = NULL; \
+	memset(&viport->mc_info.mgid, 0, sizeof(union ib_gid)); \
+} while (0);
+
+int vnic_mc_init(struct viport *viport)
+{
+	MCAST_FUNCTION("vnic_mc_init %p\n", viport);
+	SET_MCAST_STATE_INVALID;
+	viport->mc_info.retries = 0;
+	spin_lock_init(&viport->mc_info.lock);
+
+	return 0;
+}
+
+void vnic_mc_uninit(struct viport *viport)
+{
+	unsigned long flags;
+	MCAST_FUNCTION("vnic_mc_uninit %p\n", viport);
+
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	if ((viport->mc_info.state != MCAST_STATE_INVALID) &&
+	    (viport->mc_info.state != MCAST_STATE_RETRIED)) {
+		MCAST_ERROR("%s mcast state is not INVALID or RETRIED %d\n",
+				control_ifcfg_name(&viport->control),
+				viport->mc_info.state);
+	}
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+	MCAST_FUNCTION("vnic_mc_uninit done\n");
+}
+
+
+/* This function is called when NEED_MCAST_COMPLETION is set.
+ * It finishes off the join multicast work.
+ */
+int vnic_mc_join_handle_completion(struct viport *viport)
+{
+	unsigned long flags;
+	unsigned int ret = 0;
+
+	MCAST_FUNCTION("in vnic_mc_join_handle_completion\n");
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	if (viport->mc_info.state != MCAST_STATE_JOINING) {
+		MCAST_ERROR("%s unexpected mcast state in handle_completion: "
+				" %d\n", control_ifcfg_name(&viport->control),
+				viport->mc_info.state);
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		return -1;
+	}
+	viport->mc_info.state = MCAST_STATE_ATTACHING;
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+	MCAST_INFO("%s calling ib_attach_mcast %lx mgid:"
+			VNIC_GID_FMT " mlid:%x\n",
+			control_ifcfg_name(&viport->control), jiffies,
+			VNIC_GID_RAW_ARG(viport->mc_info.mgid.raw),
+					 viport->mc_info.mlid);
+	ret = ib_attach_mcast(viport->mc_data.ib_conn.qp, &viport->mc_info.mgid,
+			viport->mc_info.mlid);
+	if (ret) {
+		MCAST_ERROR("%s attach mcast qp failed %d\n",
+				control_ifcfg_name(&viport->control), ret);
+		return -1;
+	}
+	MCAST_INFO("%s attached\n",
+			control_ifcfg_name(&viport->control));
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	viport->mc_info.state = MCAST_STATE_JOINED_ATTACHED;
+	MCAST_INFO("%s qp attached to mcast group\n",
+			control_ifcfg_name(&viport->control));
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+	return 0;
+}
+
+/* NOTE: ib_sa.h says "returning a non-zero value from this callback will
+ * result in destroying the multicast tracking structure.
+ */
+static int vnic_mc_join_complete(int status,
+				struct ib_sa_multicast *multicast)
+{
+	struct viport *viport = (struct viport *)multicast->context;
+	unsigned long flags;
+
+	MCAST_FUNCTION("in vnic_mc_join_complete status:%x\n", status);
+	if (status) {
+		spin_lock_irqsave(&viport->mc_info.lock, flags);
+		if (status == -ENETRESET) {
+			SET_MCAST_STATE_INVALID;
+			viport->mc_info.retries = 0;
+			spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+			MCAST_ERROR("%s got ENETRESET what's the right thing "
+					"to do?\n",
+					control_ifcfg_name(&viport->control));
+			return status;
+		}
+		/* perhaps the mcgroup hasn't yet been created - retry */
+		viport->mc_info.retries++;
+		viport->mc_info.mc = NULL;
+		if (viport->mc_info.retries > MAX_MCAST_JOIN_RETRIES) {
+			viport->mc_info.state = MCAST_STATE_RETRIED;
+			spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+			MCAST_ERROR("%s join failed 0x%x - max retries:%d "
+					"exceeded\n",
+					control_ifcfg_name(&viport->control),
+					status, viport->mc_info.retries);
+		} else {
+			viport->mc_info.state = MCAST_STATE_INVALID;
+			spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+			spin_lock_irqsave(&viport->lock, flags);
+			viport->updates |= NEED_MCAST_JOIN;
+			spin_unlock_irqrestore(&viport->lock, flags);
+			viport_kick(viport);
+			MCAST_ERROR("%s join failed 0x%x - retrying; "
+					"retries:%d\n",
+					control_ifcfg_name(&viport->control),
+					status, viport->mc_info.retries);
+		}
+		return status;
+	}
+
+	/* finish join work from main state loop for viport - in case
+	 * the work itself cannot be done in a callback environment */
+	spin_lock_irqsave(&viport->lock, flags);
+	viport->mc_info.mlid = be16_to_cpu(multicast->rec.mlid);
+	viport->updates |= NEED_MCAST_COMPLETION;
+	spin_unlock_irqrestore(&viport->lock, flags);
+	viport_kick(viport);
+	MCAST_INFO("%s set NEED_MCAST_COMPLETION %x %x\n",
+			control_ifcfg_name(&viport->control),
+			multicast->rec.mlid, viport->mc_info.mlid);
+	return 0;
+}
+
+void vnic_mc_join_setup(struct viport *viport, union ib_gid *mgid)
+{
+	unsigned long flags;
+
+	MCAST_FUNCTION("in vnic_mc_join_setup\n");
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	if (viport->mc_info.state != MCAST_STATE_INVALID) {
+		if (viport->mc_info.state == MCAST_STATE_DETACHING) {
+			MCAST_ERROR("%s detach in progress\n",
+					control_ifcfg_name(&viport->control));
+		} else if (viport->mc_info.state == MCAST_STATE_RETRIED) {
+			MCAST_ERROR("%s max join retries exceeded\n",
+					control_ifcfg_name(&viport->control));
+		} else {
+			/* join/attach in progress or done */
+			/* verify that the current mgid is same as prev mgid */
+			if (memcmp(mgid, &viport->mc_info.mgid, sizeof(union ib_gid)) != 0) {
+				/* Separate MGID for each IOC */
+				MCAST_ERROR("%s Multicast Group MGIDs not "
+					"unique; mgids: " VNIC_GID_FMT
+					 " " VNIC_GID_FMT "\n",
+					control_ifcfg_name(&viport->control),
+					VNIC_GID_RAW_ARG(mgid->raw),
+					VNIC_GID_RAW_ARG(viport->mc_info.mgid.raw));
+			} else
+				MCAST_INFO("%s join already issued: %d\n",
+					control_ifcfg_name(&viport->control),
+					viport->mc_info.state);
+
+		}
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		return;
+	}
+	viport->mc_info.mgid = *mgid;
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+	spin_lock_irqsave(&viport->lock, flags);
+	viport->updates |= NEED_MCAST_JOIN;
+	spin_unlock_irqrestore(&viport->lock, flags);
+	viport_kick(viport);
+	MCAST_INFO("%s set NEED_MCAST_JOIN \n",
+			control_ifcfg_name(&viport->control));
+}
+
+int vnic_mc_join(struct viport *viport)
+{
+	struct ib_sa_mcmember_rec rec;
+	ib_sa_comp_mask comp_mask;
+	unsigned long flags;
+
+	MCAST_FUNCTION("in vnic_mc_join\n");
+	if (!viport->mc_data.ib_conn.qp) {
+		MCAST_ERROR("%s qp is NULL\n",
+				control_ifcfg_name(&viport->control));
+		return -1;
+	}
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	if (viport->mc_info.state != MCAST_STATE_INVALID) {
+		MCAST_INFO("%s join already issued: %d\n",
+				control_ifcfg_name(&viport->control),
+				viport->mc_info.state);
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		return 0;
+	}
+	viport->mc_info.state = MCAST_STATE_JOINING;
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+
+	memset(&rec, 0, sizeof(rec));
+	rec.join_state = 2; /* bit 1 is Nonmember */
+	rec.mgid = viport->mc_info.mgid;
+	rec.port_gid = viport->config->path_info.path.sgid;
+
+	comp_mask = 	IB_SA_MCMEMBER_REC_MGID     |
+			IB_SA_MCMEMBER_REC_PORT_GID |
+			IB_SA_MCMEMBER_REC_JOIN_STATE;
+
+	MCAST_INFO("%s calling ib_sa_join_multicast %lx mgid:"
+			VNIC_GID_FMT " port_gid: " VNIC_GID_FMT "\n",
+			control_ifcfg_name(&viport->control), jiffies,
+			VNIC_GID_RAW_ARG(rec.mgid.raw),
+			VNIC_GID_RAW_ARG(rec.port_gid.raw));
+
+	viport->mc_info.mc = ib_sa_join_multicast(&vnic_sa_client,
+			viport->config->ibdev, viport->config->port,
+			&rec, comp_mask, GFP_KERNEL,
+			vnic_mc_join_complete, viport);
+
+	if (IS_ERR(viport->mc_info.mc)) {
+		MCAST_ERROR("%s ib_sa_join_multicast failed " VNIC_GID_FMT
+				".\n",
+				control_ifcfg_name(&viport->control),
+				VNIC_GID_RAW_ARG(rec.mgid.raw));
+		spin_lock_irqsave(&viport->mc_info.lock, flags);
+		viport->mc_info.state = MCAST_STATE_INVALID;
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		return -1;
+	}
+	MCAST_INFO("%s join issued ib_sa_join_multicast mgid:"
+			VNIC_GID_FMT " port_gid: " VNIC_GID_FMT "\n",
+			control_ifcfg_name(&viport->control),
+			VNIC_GID_RAW_ARG(rec.mgid.raw),
+			VNIC_GID_RAW_ARG(rec.port_gid.raw));
+
+	return 0;
+}
+
+void vnic_mc_leave(struct viport *viport)
+{
+	unsigned long flags;
+	unsigned int ret;
+	struct ib_sa_multicast *mc;
+
+	MCAST_FUNCTION("vnic_mc_leave \n");
+
+	spin_lock_irqsave(&viport->mc_info.lock, flags);
+	if ((viport->mc_info.state == MCAST_STATE_INVALID) ||
+	    (viport->mc_info.state == MCAST_STATE_RETRIED)) {
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		return;
+	}
+
+	if (viport->mc_info.state == MCAST_STATE_JOINED_ATTACHED) {
+
+		viport->mc_info.state = MCAST_STATE_DETACHING;
+		spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+		ret = ib_detach_mcast(viport->mc_data.ib_conn.qp,
+					 &viport->mc_info.mgid,
+					viport->mc_info.mlid);
+		if (ret) {
+			MCAST_ERROR("%s detach failed %d\n",
+				control_ifcfg_name(&viport->control), ret);
+			return;
+		}
+		MCAST_INFO("%s detached succesfully\n",
+				control_ifcfg_name(&viport->control));
+		spin_lock_irqsave(&viport->mc_info.lock, flags);
+	}
+	mc = viport->mc_info.mc;
+	SET_MCAST_STATE_INVALID;
+	viport->mc_info.retries = 0;
+	spin_unlock_irqrestore(&viport->mc_info.lock, flags);
+
+	if (mc) {
+		MCAST_INFO("%s calling ib_sa_free_multicast\n",
+				control_ifcfg_name(&viport->control));
+		ib_sa_free_multicast(mc);
+	}
+	MCAST_FUNCTION("vnic_mc_leave done\n");
+	return;
+}
+
+
diff --git a/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h b/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h
new file mode 100644
index 0000000..0e5499d
--- /dev/null
+++ b/drivers/infiniband/ulp/qlgc_vnic/vnic_multicast.h
@@ -0,0 +1,76 @@
+/*
+ * Copyright (c) 2008 QLogic, Inc.  All rights reserved.
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
+#ifndef __VNIC_MULTICAST_H__
+#define __VNIC_MULTTCAST_H__
+
+enum {
+	MCAST_STATE_INVALID         = 0x00, /* join not attempted or failed */
+	MCAST_STATE_JOINING         = 0x01, /* join mcgroup in progress */
+	MCAST_STATE_ATTACHING       = 0x02, /* join completed with success,
+					     * attach qp to mcgroup in progress
+					     */
+	MCAST_STATE_JOINED_ATTACHED = 0x03, /* join completed with success */
+	MCAST_STATE_DETACHING       = 0x04, /* detach qp in progress */
+	MCAST_STATE_RETRIED         = 0x05, /* retried join and failed */
+};
+
+#define MAX_MCAST_JOIN_RETRIES 	       5 /* used to retry join */
+
+struct mc_info {
+	u8  			state;
+	spinlock_t 		lock;
+	union ib_gid 		mgid;
+	u16 			mlid;
+	struct ib_sa_multicast 	*mc;
+	u8 			retries;
+};
+
+
+int vnic_mc_init(struct viport *viport);
+void vnic_mc_uninit(struct viport *viport);
+
+/* This function is called when a viport gets a multicast mgid from EVIC
+   and must join the multicast group. It sets up NEED_MCAST_JOIN flag, which
+   results in vnic_mc_join being called later. */
+void vnic_mc_join_setup(struct viport *viport, union ib_gid *mgid);
+
+/* This function is called when NEED_MCAST_JOIN flag is set. */
+int vnic_mc_join(struct viport *viport);
+
+/* This function is called when NEED_MCAST_COMPLETION is set.
+   It finishes off the join multicast work. */
+int vnic_mc_join_handle_completion(struct viport *viport);
+
+void vnic_mc_leave(struct viport *viport);
+
+#endif /* __VNIC_MULTICAST_H__ */
