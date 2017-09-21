From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: add tc flower offload skeleton
Date: Thu, 21 Sep 2017 13:03:34 +0530
Message-ID: <59ea1bf2a3b4b2b61c6777f2b24cb2634058f571.1505977744.git.rahul.lakkireddy@chelsio.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38286 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751588AbdIUHee (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:34:34 -0400
In-Reply-To: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
References: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add basic skeleton to prepare for offloading tc-flower flows.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |  4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 22 +++++++++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 57 ++++++++++++++++++++++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   | 46 +++++++++++++++++
 4 files changed, 128 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index 817212702f0a..fecd7aab673b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,7 +4,9 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o cxgb4_filter.o cxgb4_tc_u32.o cxgb4_ptp.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o \
+	      cxgb4_uld.o sched.o cxgb4_filter.o cxgb4_tc_u32.o \
+	      cxgb4_ptp.o cxgb4_tc_flower.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 92d9d795d874..8923affbdaf8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -79,6 +79,7 @@
 #include "l2t.h"
 #include "sched.h"
 #include "cxgb4_tc_u32.h"
+#include "cxgb4_tc_flower.h"
 #include "cxgb4_ptp.h"
 
 char cxgb4_driver_name[] = KBUILD_MODNAME;
@@ -2873,6 +2874,25 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
+static int cxgb_setup_tc_flower(struct net_device *dev,
+				struct tc_cls_flower_offload *cls_flower)
+{
+	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
+	    cls_flower->common.chain_index)
+		return -EOPNOTSUPP;
+
+	switch (cls_flower->command) {
+	case TC_CLSFLOWER_REPLACE:
+		return cxgb4_tc_flower_replace(dev, cls_flower);
+	case TC_CLSFLOWER_DESTROY:
+		return cxgb4_tc_flower_destroy(dev, cls_flower);
+	case TC_CLSFLOWER_STATS:
+		return cxgb4_tc_flower_stats(dev, cls_flower);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 				 struct tc_cls_u32_offload *cls_u32)
 {
@@ -2907,6 +2927,8 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	switch (type) {
 	case TC_SETUP_CLSU32:
 		return cxgb_setup_tc_cls_u32(dev, type_data);
+	case TC_SETUP_CLSFLOWER:
+		return cxgb_setup_tc_flower(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
new file mode 100644
index 000000000000..16dff71e4d02
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -0,0 +1,57 @@
+/*
+ * This file is part of the Chelsio T4/T5/T6 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2017 Chelsio Communications, Inc. All rights reserved.
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
+#include <net/tc_act/tc_gact.h>
+#include <net/tc_act/tc_mirred.h>
+
+#include "cxgb4.h"
+#include "cxgb4_tc_flower.h"
+
+int cxgb4_tc_flower_replace(struct net_device *dev,
+			    struct tc_cls_flower_offload *cls)
+{
+	return -EOPNOTSUPP;
+}
+
+int cxgb4_tc_flower_destroy(struct net_device *dev,
+			    struct tc_cls_flower_offload *cls)
+{
+	return -EOPNOTSUPP;
+}
+
+int cxgb4_tc_flower_stats(struct net_device *dev,
+			  struct tc_cls_flower_offload *cls)
+{
+	return -EOPNOTSUPP;
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
new file mode 100644
index 000000000000..b321fc205b5a
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
@@ -0,0 +1,46 @@
+/*
+ * This file is part of the Chelsio T4/T5/T6 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2017 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CXGB4_TC_FLOWER_H
+#define __CXGB4_TC_FLOWER_H
+
+#include <net/pkt_cls.h>
+
+int cxgb4_tc_flower_replace(struct net_device *dev,
+			    struct tc_cls_flower_offload *cls);
+int cxgb4_tc_flower_destroy(struct net_device *dev,
+			    struct tc_cls_flower_offload *cls);
+int cxgb4_tc_flower_stats(struct net_device *dev,
+			  struct tc_cls_flower_offload *cls);
+#endif /* __CXGB4_TC_FLOWER_H */
-- 
2.14.1
