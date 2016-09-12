From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 5/7] cxgb4: add support for setting u32 filters
Date: Mon, 12 Sep 2016 13:42:38 +0530
Message-ID: <6a12fb1798c4f18afee3f8181bb633296a6727ee.1473667613.git.rahul.lakkireddy@chelsio.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:25889 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756758AbcILIQT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 04:16:19 -0400
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
References: <cover.1473667613.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for offloading u32 filter onto hardware.  Links are stored
in a jump table to perform necessary jumps to match TCP/UDP header.
When inserting rules in the linked bucket, the TCP/UDP match fields
in the corresponding entry of the jump table are appended to the filter
rule before insertion.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  36 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  | 343 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h  |  55 ++++
 .../ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h    |  12 +
 6 files changed, 450 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index da88981..c6b71f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o cxgb4_filter.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o cxgb4_filter.o cxgb4_tc_u32.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index fbd593a..1adb28f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -867,6 +867,9 @@ struct adapter {
 
 	spinlock_t stats_lock;
 	spinlock_t win0_lock ____cacheline_aligned_in_smp;
+
+	/* TC u32 offload */
+	struct cxgb4_tc_u32_table *tc_u32;
 };
 
 /* Support for "sched-class" command to allow a TX Scheduling Class to be
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index af07f9d..28396f5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -78,6 +78,7 @@
 #include "clip_tbl.h"
 #include "l2t.h"
 #include "sched.h"
+#include "cxgb4_tc_u32.h"
 
 char cxgb4_driver_name[] = KBUILD_MODNAME;
 
@@ -3027,6 +3028,33 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
+int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+		  struct tc_to_netdev *tc)
+{
+	struct adapter *adap = netdev2adap(dev);
+	struct port_info *pi = netdev2pinfo(dev);
+
+	if (!(adap->flags & FULL_INIT_DONE)) {
+		dev_err(adap->pdev_dev,
+			"Failed to setup tc on port %d. Link Down?\n",
+			pi->port_id);
+		return -EINVAL;
+	}
+
+	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
+	    tc->type == TC_SETUP_CLSU32) {
+		switch (tc->cls_u32->command) {
+		case TC_CLSU32_NEW_KNODE:
+		case TC_CLSU32_REPLACE_KNODE:
+			return cxgb4_config_knode(dev, proto, tc->cls_u32);
+		default:
+			return -EOPNOTSUPP;
+		}
+	}
+
+	return -EOPNOTSUPP;
+}
+
 static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_open             = cxgb_open,
 	.ndo_stop             = cxgb_close,
@@ -3050,6 +3078,7 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_busy_poll        = cxgb_busy_poll,
 #endif
 	.ndo_set_tx_maxrate   = cxgb_set_tx_maxrate,
+	.ndo_setup_tc         = cxgb_setup_tc,
 };
 
 #ifdef CONFIG_PCI_IOV
@@ -4781,6 +4810,7 @@ static void free_some_resources(struct adapter *adapter)
 	t4_free_mem(adapter->l2t);
 	t4_cleanup_sched(adapter);
 	t4_free_mem(adapter->tids.tid_tab);
+	cxgb4_cleanup_tc_u32(adapter);
 	kfree(adapter->sge.egr_map);
 	kfree(adapter->sge.ingr_map);
 	kfree(adapter->sge.starving_fl);
@@ -5213,6 +5243,12 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_warn(&pdev->dev, "could not allocate TID table, "
 			 "continuing\n");
 		adapter->params.offload = 0;
+	} else {
+		adapter->tc_u32 = cxgb4_init_tc_u32(adapter,
+						    CXGB4_MAX_LINK_HANDLE);
+		if (!adapter->tc_u32)
+			dev_warn(&pdev->dev,
+				 "could not offload tc u32, continuing\n");
 	}
 
 	if (is_offload(adapter)) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
new file mode 100644
index 0000000..62c1695
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -0,0 +1,343 @@
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
+#include "cxgb4.h"
+#include "cxgb4_tc_u32_parse.h"
+#include "cxgb4_tc_u32.h"
+
+/* Fill ch_filter_specification with parsed match value/mask pair. */
+static int fill_match_fields(struct adapter *adap,
+			     struct ch_filter_specification *fs,
+			     struct tc_cls_u32_offload *cls,
+			     const struct cxgb4_match_field *entry,
+			     bool next_header)
+{
+	unsigned int i, j;
+	int off;
+	u32 val, mask;
+	int err;
+	bool found = false;
+
+	for (i = 0; i < cls->knode.sel->nkeys; i++) {
+		off = cls->knode.sel->keys[i].off;
+		val = cls->knode.sel->keys[i].val;
+		mask = cls->knode.sel->keys[i].mask;
+
+		if (next_header) {
+			/* For next headers, parse only keys with offmask */
+			if (!cls->knode.sel->keys[i].offmask)
+				continue;
+		} else {
+			/* For the remaining, parse only keys without offmask */
+			if (cls->knode.sel->keys[i].offmask)
+				continue;
+		}
+
+		found = false;
+
+		for (j = 0; entry[j].val; j++) {
+			if (off == entry[j].off) {
+				found = true;
+				err = entry[j].val(fs, val, mask);
+				if (err)
+					return err;
+				break;
+			}
+		}
+
+		if (!found)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
+		       struct tc_cls_u32_offload *cls)
+{
+	struct adapter *adapter = netdev2adap(dev);
+	struct cxgb4_tc_u32_table *t;
+	const struct cxgb4_match_field *start, *link_start = NULL;
+	struct cxgb4_link *link;
+	struct ch_filter_specification fs;
+	struct filter_ctx ctx;
+	unsigned int filter_id;
+	u32 uhtid, link_uhtid;
+	int ret;
+	bool is_ipv6 = false;
+
+	if (!can_tc_u32_offload(dev))
+		return -EOPNOTSUPP;
+
+	if ((protocol != htons(ETH_P_IP)) && (protocol != htons(ETH_P_IPV6)))
+		return -EOPNOTSUPP;
+
+	/* Fetch the location to insert the filter. */
+	filter_id = (cls->knode.handle & 0xFFFFF);
+
+	if (filter_id > adapter->tids.nftids) {
+		dev_err(adapter->pdev_dev,
+			"Location %d out of range for insertion. Max: %d\n",
+			filter_id, adapter->tids.nftids);
+		return -ERANGE;
+	}
+
+	t = adapter->tc_u32;
+	uhtid = TC_U32_USERHTID(cls->knode.handle);
+	link_uhtid = TC_U32_USERHTID(cls->knode.link_handle);
+
+	/* Ensure that uhtid is either root u32 (i.e. 0x800)
+	 * or a a valid linked bucket.
+	 */
+	if (uhtid != 0x800 && uhtid >= t->size)
+		return -EINVAL;
+
+	/* Ensure link handle uhtid is sane, if specified. */
+	if (link_uhtid >= t->size)
+		return -EINVAL;
+
+	memset(&fs, 0, sizeof(fs));
+
+	if (protocol == htons(ETH_P_IPV6)) {
+		start = cxgb4_ipv6_fields;
+		is_ipv6 = true;
+	} else {
+		start = cxgb4_ipv4_fields;
+		is_ipv6 = false;
+	}
+
+	if (uhtid != 0x800) {
+		/* Link must exist from root node before insertion. */
+		if (!t->table[uhtid - 1].link_handle)
+			return -EINVAL;
+
+		/* Link must have a valid supported next header. */
+		link_start = (&t->table[uhtid - 1])->match_field;
+		if (!link_start)
+			return -EINVAL;
+	}
+
+	/* Parse links and record them for subsequent jumps to valid
+	 * next headers.
+	 */
+	if (link_uhtid) {
+		const struct cxgb4_next_header *next;
+		unsigned int i, j;
+		int off;
+		u32 val, mask;
+		bool found = false;
+
+		if (t->table[link_uhtid - 1].link_handle) {
+			dev_err(adapter->pdev_dev,
+				"Link handle exists for: 0x%x\n",
+				link_uhtid);
+			return -EINVAL;
+		}
+
+		next = is_ipv6 ? cxgb4_ipv6_jumps : cxgb4_ipv4_jumps;
+
+		/* Try to find matches that allow jumps to next header. */
+		for (i = 0; next[i].jump; i++) {
+			if (next[i].offoff != cls->knode.sel->offoff ||
+			    next[i].shift != cls->knode.sel->offshift ||
+			    next[i].mask != cls->knode.sel->offmask ||
+			    next[i].offset != cls->knode.sel->off)
+				continue;
+
+			/* Found a possible candidate.  Find a key that
+			 * matches the corresponding offset, value, and
+			 * mask to jump to next header.
+			 */
+			for (j = 0; j < cls->knode.sel->nkeys; j++) {
+				off = cls->knode.sel->keys[j].off;
+				val = cls->knode.sel->keys[j].val;
+				mask = cls->knode.sel->keys[j].mask;
+
+				if (next[i].match_off == off &&
+				    next[i].match_val == val &&
+				    next[i].match_mask == mask) {
+					found = true;
+					break;
+				}
+			}
+
+			if (!found)
+				continue; /* Try next candidate. */
+
+			/* Candidate to jump to next header found.
+			 * Translate all keys to internal specification
+			 * and store them in jump table. This spec is copied
+			 * later to set the actual filters.
+			 */
+			ret = fill_match_fields(adapter, &fs, cls,
+						start, false);
+			if (ret)
+				goto out;
+
+			link = &t->table[link_uhtid - 1];
+			link->match_field = next[i].jump;
+			link->link_handle = cls->knode.handle;
+			memcpy(&link->fs, &fs, sizeof(fs));
+			break;
+		}
+
+		/* No candidate found to jump to next header. */
+		if (!found)
+			return -EINVAL;
+
+		return 0;
+	}
+
+	/* Fill ch_filter_specification match fields to be shipped to hardware.
+	 * Copy the linked spec (if any) first.  And then update the spec as
+	 * needed.
+	 */
+	if ((uhtid != 0x800) && t->table[uhtid - 1].link_handle) {
+		/* Copy linked ch_filter_specification */
+		memcpy(&fs, &t->table[uhtid - 1].fs, sizeof(fs));
+		ret = fill_match_fields(adapter, &fs, cls,
+					link_start, true);
+		if (ret)
+			goto out;
+	}
+
+	ret = fill_match_fields(adapter, &fs, cls, start, false);
+	if (ret)
+		goto out;
+
+	/* The filter spec has been completely built from the info
+	 * provided from u32.  We now set some default fields in the
+	 * spec for sanity.
+	 */
+
+	/* Match only packets coming from the ingress port where this
+	 * filter will be created.
+	 */
+	fs.val.iport = netdev2pinfo(dev)->port_id;
+	fs.mask.iport = ~0;
+
+	/* Enable filter hit counts. */
+	fs.hitcnts = 1;
+
+	/* Set type of filter - IPv6 or IPv4 */
+	fs.type = is_ipv6 ? 1 : 0;
+
+	init_completion(&ctx.completion);
+
+	/* Set the filter */
+	ret = cxgb4_set_filter(dev, filter_id, &fs, &ctx);
+	if (ret)
+		goto out;
+
+	/* Wait for reply */
+	ret = wait_for_completion_timeout(&ctx.completion, 10 * HZ);
+	if (!ret)
+		return -ETIMEDOUT;
+
+	ret = ctx.result;
+	if (!ret) {
+		/* If this is a linked bucket, then set the corresponding
+		 * entry in the bitmap to mark it as belonging to this linked
+		 * bucket.
+		 */
+		if ((uhtid != 0x800) && t->table[uhtid - 1].link_handle)
+			set_bit(filter_id, (&t->table[uhtid - 1])->tid_map);
+	}
+
+out:
+	return ret;
+}
+
+void cxgb4_cleanup_tc_u32(struct adapter *adap)
+{
+	struct cxgb4_tc_u32_table *t;
+	unsigned int i;
+
+	if (!adap->tc_u32)
+		return;
+
+	/* Free up all allocated memory. */
+	t = adap->tc_u32;
+	for (i = 0; i < t->size; i++) {
+		struct cxgb4_link *link = &t->table[i];
+
+		t4_free_mem(link->tid_map);
+	}
+	t4_free_mem(adap->tc_u32);
+}
+
+struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap,
+					     unsigned int size)
+{
+	struct cxgb4_tc_u32_table *t;
+	unsigned int i;
+
+	if (!size)
+		return NULL;
+
+	t = t4_alloc_mem(sizeof(*t) +
+			 (size * sizeof(struct cxgb4_link)));
+	if (!t)
+		return NULL;
+
+	t->size = size;
+
+	for (i = 0; i < t->size; i++) {
+		struct cxgb4_link *link = &t->table[i];
+		unsigned int bmap_size;
+		unsigned int max_tids;
+
+		max_tids = adap->tids.nftids;
+		bmap_size = BITS_TO_LONGS(max_tids);
+		link->tid_map = t4_alloc_mem(sizeof(unsigned long) * bmap_size);
+		if (!link->tid_map)
+			goto out_no_mem;
+		bitmap_zero(link->tid_map, max_tids);
+	}
+
+	return t;
+
+out_no_mem:
+	for (i = 0; i < t->size; i++) {
+		struct cxgb4_link *link = &t->table[i];
+
+		if (link->tid_map)
+			t4_free_mem(link->tid_map);
+	}
+
+	if (t)
+		t4_free_mem(t);
+
+	return NULL;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
new file mode 100644
index 0000000..46575843
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
@@ -0,0 +1,55 @@
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
+#ifndef __CXGB4_TC_U32_H
+#define __CXGB4_TC_U32_H
+
+#include <net/pkt_cls.h>
+
+#define CXGB4_MAX_LINK_HANDLE 32
+
+static inline bool can_tc_u32_offload(struct net_device *dev)
+{
+	struct adapter *adap = netdev2adap(dev);
+
+	return (dev->features & NETIF_F_HW_TC) && adap->tc_u32 ? true : false;
+}
+
+int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
+		       struct tc_cls_u32_offload *cls);
+
+void cxgb4_cleanup_tc_u32(struct adapter *adapter);
+struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap,
+					     unsigned int size);
+#endif /* __CXGB4_TC_U32_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h
index 261aa4a..de321bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h
@@ -279,4 +279,16 @@ static const struct cxgb4_next_header cxgb4_ipv6_jumps[] = {
 	  .jump = cxgb4_udp_fields },
 	{ .jump = NULL }
 };
+
+struct cxgb4_link {
+	const struct cxgb4_match_field *match_field;  /* Next header */
+	struct ch_filter_specification fs; /* Match spec associated with link */
+	u32 link_handle;         /* Knode handle associated with the link */
+	unsigned long *tid_map;  /* Bitmap for filter tids */
+};
+
+struct cxgb4_tc_u32_table {
+	unsigned int size;          /* number of entries in table */
+	struct cxgb4_link table[0]; /* Jump table */
+};
 #endif /* __CXGB4_TC_U32_PARSE_H */
-- 
2.5.3
