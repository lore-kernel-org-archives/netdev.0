From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: add support for tx traffic scheduling classes
Date: Mon, 22 Aug 2016 16:29:06 +0530
Message-ID: <c8a01da88072c28b61e86b0cdb2fb04cac4e9d69.1471848005.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:28731 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752683AbcHVLBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:01:02 -0400
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
References: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to create tx traffic scheduling classes with specified
scheduling parameters.  Return an existing class if a match is found
with same scheduling parameters.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  28 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  20 +-
 drivers/net/ethernet/chelsio/cxgb4/sched.c      | 235 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sched.h      |  89 +++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  31 +++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  38 +++-
 7 files changed, 438 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/sched.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/sched.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index fac2157..2461296 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 6b05289..17a6dd0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -347,6 +347,7 @@ struct adapter_params {
 	unsigned int ofldq_wr_cred;
 	bool ulptx_memwrite_dsgl;          /* use of T5 DSGL allowed */
 
+	unsigned int nsched_cls;          /* number of traffic classes */
 	unsigned int max_ordird_qp;       /* Max read depth per RDMA QP */
 	unsigned int max_ird_adapter;     /* Max read depth per adapter */
 };
@@ -495,6 +496,7 @@ struct port_info {
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 	bool rxtstamp;  /* Enable TS */
 	struct hwtstamp_config tstamp_config;
+	struct sched_table *sched_tbl;
 };
 
 struct dentry;
@@ -858,6 +860,27 @@ struct adapter {
 	spinlock_t win0_lock ____cacheline_aligned_in_smp;
 };
 
+/* Support for "sched-class" command to allow a TX Scheduling Class to be
+ * programmed with various parameters.
+ */
+struct ch_sched_params {
+	s8   type;                     /* packet or flow */
+	union {
+		struct {
+			s8   level;    /* scheduler hierarchy level */
+			s8   mode;     /* per-class or per-flow */
+			s8   rateunit; /* bit or packet rate */
+			s8   ratemode; /* %port relative or kbps absolute */
+			s8   channel;  /* scheduler channel [0..N] */
+			s8   class;    /* scheduler class [0..N] */
+			s32  minrate;  /* minimum rate */
+			s32  maxrate;  /* maximum rate */
+			s16  weight;   /* percent weight */
+			s16  pktsize;  /* average packet size */
+		} params;
+	} u;
+};
+
 /* Defined bit width of user definable filter tuples
  */
 #define ETHTYPE_BITWIDTH 16
@@ -1563,6 +1586,9 @@ void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
 			 int filter_index, int *enabled);
 int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 			 u32 addr, u32 val);
+int t4_sched_params(struct adapter *adapter, int type, int level, int mode,
+		    int rateunit, int ratemode, int channel, int class,
+		    int minrate, int maxrate, int weight, int pktsize);
 void t4_sge_decode_idma_state(struct adapter *adapter, int state);
 void t4_free_mem(void *addr);
 void t4_idma_monitor_init(struct adapter *adapter,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0099a0c..2e341bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -76,6 +76,7 @@
 #include "cxgb4_debugfs.h"
 #include "clip_tbl.h"
 #include "l2t.h"
+#include "sched.h"
 
 char cxgb4_driver_name[] = KBUILD_MODNAME;
 
@@ -4024,6 +4025,12 @@ static int adap_init0(struct adapter *adap)
 	adap->clipt_start = val[0];
 	adap->clipt_end = val[1];
 
+	/* We don't yet have a PARAMs calls to retrieve the number of Traffic
+	 * Classes supported by the hardware/firmware so we hard code it here
+	 * for now.
+	 */
+	adap->params.nsched_cls = is_t4(adap->params.chip) ? 15 : 16;
+
 	/* query params related to active filter region */
 	params[0] = FW_PARAM_PFVF(ACTIVE_FILTER_START);
 	params[1] = FW_PARAM_PFVF(ACTIVE_FILTER_END);
@@ -4882,6 +4889,7 @@ static void free_some_resources(struct adapter *adapter)
 	unsigned int i;
 
 	t4_free_mem(adapter->l2t);
+	t4_cleanup_sched(adapter);
 	t4_free_mem(adapter->tids.tid_tab);
 	kfree(adapter->sge.egr_map);
 	kfree(adapter->sge.ingr_map);
@@ -5249,6 +5257,16 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 #endif
+
+	for_each_port(adapter, i) {
+		pi = adap2pinfo(adapter, i);
+		pi->sched_tbl = t4_init_sched(adapter->params.nsched_cls);
+		if (!pi->sched_tbl)
+			dev_warn(&pdev->dev,
+				 "could not activate scheduling on port %d\n",
+				 i);
+	}
+
 	if (is_offload(adapter) && tid_init(&adapter->tids) < 0) {
 		dev_warn(&pdev->dev, "could not allocate TID table, "
 			 "continuing\n");
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
new file mode 100644
index 0000000..6158daf
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -0,0 +1,235 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
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
+#include <linux/module.h>
+#include <linux/netdevice.h>
+
+#include "cxgb4.h"
+#include "sched.h"
+
+/* Spinlock must be held by caller */
+static int t4_sched_class_fw_cmd(struct port_info *pi,
+				 struct ch_sched_params *p,
+				 enum sched_fw_ops op)
+{
+	struct adapter *adap = pi->adapter;
+	struct sched_table *s = pi->sched_tbl;
+	struct sched_class *e;
+	int err = 0;
+
+	e = &s->tab[p->u.params.class];
+	switch (op) {
+	case SCHED_FW_OP_ADD:
+		err = t4_sched_params(adap, p->type,
+				      p->u.params.level, p->u.params.mode,
+				      p->u.params.rateunit,
+				      p->u.params.ratemode,
+				      p->u.params.channel, e->idx,
+				      p->u.params.minrate, p->u.params.maxrate,
+				      p->u.params.weight, p->u.params.pktsize);
+		break;
+	default:
+		err = -ENOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
+/* If @p is NULL, fetch any available unused class */
+static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
+						const struct ch_sched_params *p)
+{
+	struct sched_table *s = pi->sched_tbl;
+	struct sched_class *e, *end;
+	struct sched_class *found = NULL;
+
+	if (!p) {
+		/* Get any available unused class */
+		end = &s->tab[s->sched_size];
+		for (e = &s->tab[0]; e != end; ++e) {
+			if (e->state == SCHED_STATE_UNUSED) {
+				found = e;
+				break;
+			}
+		}
+	} else {
+		/* Look for a class with matching scheduling parameters */
+		struct ch_sched_params info;
+		struct ch_sched_params tp;
+
+		memset(&info, 0, sizeof(info));
+		memset(&tp, 0, sizeof(tp));
+
+		memcpy(&tp, p, sizeof(tp));
+		/* Don't try to match class parameter */
+		tp.u.params.class = SCHED_CLS_NONE;
+
+		end = &s->tab[s->sched_size];
+		for (e = &s->tab[0]; e != end; ++e) {
+			if (e->state == SCHED_STATE_UNUSED)
+				continue;
+
+			memset(&info, 0, sizeof(info));
+			memcpy(&info, &e->info, sizeof(info));
+			/* Don't try to match class parameter */
+			info.u.params.class = SCHED_CLS_NONE;
+
+			if ((info.type == tp.type) &&
+			    (!memcmp(&info.u.params, &tp.u.params,
+				     sizeof(info.u.params)))) {
+				found = e;
+				break;
+			}
+		}
+	}
+
+	return found;
+}
+
+static struct sched_class *t4_sched_class_alloc(struct port_info *pi,
+						struct ch_sched_params *p)
+{
+	struct sched_table *s = pi->sched_tbl;
+	struct sched_class *e;
+	u8 class_id;
+	int err;
+
+	if (!p)
+		return NULL;
+
+	class_id = p->u.params.class;
+
+	/* Only accept search for existing class with matching params
+	 * or allocation of new class with specified params
+	 */
+	if (class_id != SCHED_CLS_NONE)
+		return NULL;
+
+	write_lock(&s->rw_lock);
+	/* See if there's an exisiting class with same
+	 * requested sched params
+	 */
+	e = t4_sched_class_lookup(pi, p);
+	if (!e) {
+		struct ch_sched_params np;
+
+		/* Fetch any available unused class */
+		e = t4_sched_class_lookup(pi, NULL);
+		if (!e)
+			goto out;
+
+		memset(&np, 0, sizeof(np));
+		memcpy(&np, p, sizeof(np));
+		np.u.params.class = e->idx;
+
+		spin_lock(&e->lock);
+		/* New class */
+		err = t4_sched_class_fw_cmd(pi, &np, SCHED_FW_OP_ADD);
+		if (err) {
+			spin_unlock(&e->lock);
+			e = NULL;
+			goto out;
+		}
+		memcpy(&e->info, &np, sizeof(e->info));
+		atomic_set(&e->refcnt, 0);
+		e->state = SCHED_STATE_ACTIVE;
+		spin_unlock(&e->lock);
+	}
+
+out:
+	write_unlock(&s->rw_lock);
+	return e;
+}
+
+/**
+ * cxgb4_sched_class_alloc - allocate a scheduling class
+ * @dev: net_device pointer
+ * @p: new scheduling class to create.
+ *
+ * Returns pointer to the scheduling class created.  If @p is NULL, then
+ * it allocates and returns any available unused scheduling class. If a
+ * scheduling class with matching @p is found, then the matching class is
+ * returned.
+ */
+struct sched_class *cxgb4_sched_class_alloc(struct net_device *dev,
+					    struct ch_sched_params *p)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+	u8 class_id;
+
+	if (!can_sched(dev))
+		return NULL;
+
+	class_id = p->u.params.class;
+	if (!valid_class_id(dev, class_id))
+		return NULL;
+
+	return t4_sched_class_alloc(pi, p);
+}
+
+struct sched_table *t4_init_sched(unsigned int sched_size)
+{
+	struct sched_table *s;
+	unsigned int i;
+
+	s = t4_alloc_mem(sizeof(*s) + sched_size * sizeof(struct sched_class));
+	if (!s)
+		return NULL;
+
+	s->sched_size = sched_size;
+	rwlock_init(&s->rw_lock);
+
+	for (i = 0; i < s->sched_size; i++) {
+		memset(&s->tab[i], 0, sizeof(struct sched_class));
+		s->tab[i].idx = i;
+		s->tab[i].state = SCHED_STATE_UNUSED;
+		spin_lock_init(&s->tab[i].lock);
+		atomic_set(&s->tab[i].refcnt, 0);
+	}
+	return s;
+}
+
+void t4_cleanup_sched(struct adapter *adap)
+{
+	struct sched_table *s;
+	unsigned int i;
+
+	for_each_port(adap, i) {
+		struct port_info *pi = netdev2pinfo(adap->port[i]);
+
+		s = pi->sched_tbl;
+		t4_free_mem(s);
+	}
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.h b/drivers/net/ethernet/chelsio/cxgb4/sched.h
new file mode 100644
index 0000000..60b09e9
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.h
@@ -0,0 +1,89 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2016 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CXGB4_SCHED_H
+#define __CXGB4_SCHED_H
+
+#include <linux/spinlock.h>
+#include <linux/atomic.h>
+
+#define SCHED_CLS_NONE 0xff
+
+enum {
+	SCHED_STATE_ACTIVE,
+	SCHED_STATE_UNUSED,
+};
+
+enum sched_fw_ops {
+	SCHED_FW_OP_ADD,
+};
+
+struct sched_class {
+	u8 state;
+	u8 idx;
+	struct ch_sched_params info;
+	spinlock_t lock; /* Per class lock */
+	atomic_t refcnt;
+};
+
+struct sched_table {      /* per port scheduling table */
+	u8 sched_size;
+	rwlock_t rw_lock; /* Table lock */
+	struct sched_class tab[0];
+};
+
+static inline bool can_sched(struct net_device *dev)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+
+	return !pi->sched_tbl ? false : true;
+}
+
+static inline bool valid_class_id(struct net_device *dev, u8 class_id)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+
+	if ((class_id > pi->sched_tbl->sched_size - 1) &&
+	    (class_id != SCHED_CLS_NONE))
+		return false;
+
+	return true;
+}
+
+struct sched_class *cxgb4_sched_class_alloc(struct net_device *dev,
+					    struct ch_sched_params *p);
+
+struct sched_table *t4_init_sched(unsigned int size);
+void t4_cleanup_sched(struct adapter *adap);
+#endif  /* __CXGB4_SCHED_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2a476cc..de451ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2003-2014 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -8305,3 +8305,32 @@ int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
 
 	return t4_wr_mbox(adapter, adapter->mbox, &cmd, sizeof(cmd), &cmd);
 }
+
+int t4_sched_params(struct adapter *adapter, int type, int level, int mode,
+		    int rateunit, int ratemode, int channel, int class,
+		    int minrate, int maxrate, int weight, int pktsize)
+{
+	struct fw_sched_cmd cmd;
+
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.op_to_write = cpu_to_be32(FW_CMD_OP_V(FW_SCHED_CMD) |
+				      FW_CMD_REQUEST_F |
+				      FW_CMD_WRITE_F);
+	cmd.retval_len16 = cpu_to_be32(FW_LEN16(cmd));
+
+	cmd.u.params.sc = FW_SCHED_SC_PARAMS;
+	cmd.u.params.type = type;
+	cmd.u.params.level = level;
+	cmd.u.params.mode = mode;
+	cmd.u.params.ch = channel;
+	cmd.u.params.cl = class;
+	cmd.u.params.unit = rateunit;
+	cmd.u.params.rate = ratemode;
+	cmd.u.params.min = cpu_to_be32(minrate);
+	cmd.u.params.max = cpu_to_be32(maxrate);
+	cmd.u.params.weight = cpu_to_be16(weight);
+	cmd.u.params.pktsize = cpu_to_be16(pktsize);
+
+	return t4_wr_mbox_meat(adapter, adapter->mbox, &cmd, sizeof(cmd),
+			       NULL, 1);
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index d8f4adb..ffe4bf4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1,7 +1,7 @@
 /*
  * This file is part of the Chelsio T4 Ethernet driver for Linux.
  *
- * Copyright (c) 2009-2014 Chelsio Communications, Inc. All rights reserved.
+ * Copyright (c) 2009-2016 Chelsio Communications, Inc. All rights reserved.
  *
  * This software is available to you under a choice of one of two
  * licenses.  You may choose to be licensed under the terms of the GNU
@@ -681,6 +681,7 @@ enum fw_cmd_opcodes {
 	FW_RSS_IND_TBL_CMD             = 0x20,
 	FW_RSS_GLB_CONFIG_CMD          = 0x22,
 	FW_RSS_VI_CONFIG_CMD           = 0x23,
+	FW_SCHED_CMD                   = 0x24,
 	FW_DEVLOG_CMD                  = 0x25,
 	FW_CLIP_CMD                    = 0x28,
 	FW_LASTC2E_CMD                 = 0x40,
@@ -2962,6 +2963,41 @@ struct fw_rss_vi_config_cmd {
 #define FW_RSS_VI_CONFIG_CMD_UDPEN_V(x)	((x) << FW_RSS_VI_CONFIG_CMD_UDPEN_S)
 #define FW_RSS_VI_CONFIG_CMD_UDPEN_F	FW_RSS_VI_CONFIG_CMD_UDPEN_V(1U)
 
+enum fw_sched_sc {
+	FW_SCHED_SC_PARAMS		= 1,
+};
+
+struct fw_sched_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	union fw_sched {
+		struct fw_sched_config {
+			__u8   sc;
+			__u8   type;
+			__u8   minmaxen;
+			__u8   r3[5];
+			__u8   nclasses[4];
+			__be32 r4;
+		} config;
+		struct fw_sched_params {
+			__u8   sc;
+			__u8   type;
+			__u8   level;
+			__u8   mode;
+			__u8   unit;
+			__u8   rate;
+			__u8   ch;
+			__u8   cl;
+			__be32 min;
+			__be32 max;
+			__be16 weight;
+			__be16 pktsize;
+			__be16 burstsize;
+			__be16 r4;
+		} params;
+	} u;
+};
+
 struct fw_clip_cmd {
 	__be32 op_to_write;
 	__be32 alloc_to_len16;
-- 
2.5.3
